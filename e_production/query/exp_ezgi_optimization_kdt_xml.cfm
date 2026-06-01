<!---
    File: exp_ezgi_optimization_kdt_xml.cfm
    Folder: Add_Ons\ezgi\e_production\query
    Author: Ezgi Yazılım
    Date: #dateFormat(now(), "dd/mm/yyyy")#
    Description: KDT markası için optimizasyon sonuçlarını XML formatında export eder (KDT Standart Formatı)
--->

<cfparam name="attributes.optimization_id" default="">
<cfparam name="attributes.sheet_group_number" default="">

<cfif not isdefined('attributes.optimization_id') or not len(attributes.optimization_id) or not isNumeric(attributes.optimization_id)>
	<cfoutput>
		<div style="color:red; padding:20px;">
			<h3>Hata: Geçersiz optimizasyon ID</h3>
		</div>
	</cfoutput>
	<cfabort>
</cfif>

<!--- Optimizasyon bilgilerini al --->
<cfquery name="get_optimization" datasource="#dsn3#">
	SELECT 
		EO.OPTIMIZATION_ID,
		EO.OPTIMIZATION_NUMBER,
		EO.CIRCLE_TESTRE_THICKNESS,
		EO.OUTER_EDGE_TRIMMING_ALLOWANCE,
		EIM.MASTER_PLAN_NUMBER,
		EIM.MASTER_PLAN_DETAIL
	FROM 
		EZGI_IFLOW_OPTIMIZATION AS EO WITH (NOLOCK)
		INNER JOIN EZGI_IFLOW_MASTER_PLAN AS EIM ON EO.MASTER_PLAN_ID = EIM.MASTER_PLAN_ID
	WHERE 
		EO.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
</cfquery>

<cfif not get_optimization.recordcount>
	<cfoutput>
		<div style="color:red; padding:20px;">
			<h3>Hata: Optimizasyon bulunamadı</h3>
		</div>
	</cfoutput>
	<cfabort>
</cfif>

<!--- Kerf thickness ve trim allowance değerlerini al --->
<cfset kerf_thickness = 4.4>
<cfif isNumeric(get_optimization.CIRCLE_TESTRE_THICKNESS) and get_optimization.CIRCLE_TESTRE_THICKNESS GT 0>
	<cfset kerf_thickness = get_optimization.CIRCLE_TESTRE_THICKNESS>
</cfif>

<cfset trim_allowance = 0>
<cfif isNumeric(get_optimization.OUTER_EDGE_TRIMMING_ALLOWANCE)>
	<cfset trim_allowance = get_optimization.OUTER_EDGE_TRIMMING_ALLOWANCE>
</cfif>

<!--- Optimizasyon sonuçlarını al (Sheet Group bazında) --->
<cfquery name="get_sheet_groups" datasource="#dsn3#">
	SELECT DISTINCT
		OER.SHEET_GROUP_NUMBER,
		OER.STOCK_ID,
		ISNULL(S.PRODUCT_NAME, 'Malzeme1') AS PRODUCT_NAME,
		ISNULL(PU.DIMENTION, '2100*2800') AS DIMENTION,
		COUNT(DISTINCT OER.SHEET_NUMBER) AS SHEET_COUNT
	FROM 
		EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER WITH (NOLOCK)
		LEFT OUTER JOIN STOCKS AS S WITH (NOLOCK) ON OER.STOCK_ID = S.STOCK_ID
		LEFT OUTER JOIN PRODUCT_UNIT AS PU WITH (NOLOCK) ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
	WHERE 
		OER.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
		<cfif isdefined('attributes.sheet_group_number') and len(attributes.sheet_group_number) and isNumeric(attributes.sheet_group_number)>
			AND OER.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
		</cfif>
	GROUP BY
		OER.SHEET_GROUP_NUMBER,
		OER.STOCK_ID,
		S.PRODUCT_NAME,
		PU.DIMENTION
	ORDER BY 
		OER.SHEET_GROUP_NUMBER
</cfquery>

<!--- Malzeme bazında istasyon ayarlarını al (OUTER_EDGE_TRIMMING_ALLOWANCE için) --->
<cfquery name="get_material_settings" datasource="#dsn3#">
	SELECT 
		ER.STOCK_ID AS SELECTED_STOCK_ID,
		ISNULL(W.OUTER_EDGE_TRIMMING_ALLOWANCE, 0) AS OUTER_EDGE_TRIMMING_ALLOWANCE,
		ISNULL(W.CUTTING_STARTING_DIRECTION, 1) AS CUTTING_STARTING_DIRECTION
	FROM 
		EZGI_IFLOW_OPTIMIZATION_MATERIAL AS E 
		INNER JOIN EZGI_IFLOW_OPTIMIZATION_MATERIAL_ROW AS ER ON E.OPTIMIZATION_MATERIAL_ID = ER.OPTIMIZATION_MATERIAL_ID 
		LEFT OUTER JOIN WORKSTATIONS AS W ON ER.WORKSTATION_ID = W.STATION_ID
	WHERE 
		E.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
</cfquery>
<cfset materialSettingsMap = structNew()>
<cfloop query="get_material_settings">
	<cfif not structKeyExists(materialSettingsMap, SELECTED_STOCK_ID)>
		<cfset materialSettingsMap[SELECTED_STOCK_ID] = structNew()>
		<cfset materialSettingsMap[SELECTED_STOCK_ID].trimAllowance = (isNumeric(OUTER_EDGE_TRIMMING_ALLOWANCE) and val(OUTER_EDGE_TRIMMING_ALLOWANCE) GT 0) ? val(OUTER_EDGE_TRIMMING_ALLOWANCE) : 0>
		<cfset materialSettingsMap[SELECTED_STOCK_ID].cuttingStartingDirection = (isNumeric(CUTTING_STARTING_DIRECTION) and (val(CUTTING_STARTING_DIRECTION) EQ 1 or val(CUTTING_STARTING_DIRECTION) EQ 2)) ? val(CUTTING_STARTING_DIRECTION) : 1>
	</cfif>
</cfloop>

<!--- Tüm parçaları topla (parts bölümü için) --->
<cfquery name="get_all_parts_summary" datasource="#dsn3#">
	SELECT 
		OERR.PIECE_NAME,
		OERR.WIDTH,
		OERR.HEIGHT,
		COUNT(*) AS PART_COUNT
	FROM 
		EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS OERR WITH (NOLOCK)
		INNER JOIN EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER ON OERR.OPTIMIZATION_RESULT_ID = OER.OPTIMIZATION_RESULT_ID
	WHERE 
		OER.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
		<cfif isdefined('attributes.sheet_group_number') and len(attributes.sheet_group_number) and isNumeric(attributes.sheet_group_number)>
			AND OER.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
		</cfif>
	GROUP BY
		OERR.PIECE_NAME,
		OERR.WIDTH,
		OERR.HEIGHT
	ORDER BY
		OERR.PIECE_NAME,
		OERR.WIDTH,
		OERR.HEIGHT
</cfquery>

<!--- XML içeriğini oluştur --->
<cfset xml_content = '<?xml version="1.0" encoding="UTF-8"?><project>'>
<cfset part_code_counter = 1>
<cfset part_code_map = structNew()>
<cfset cut_counter = 1>

<cfloop query="get_sheet_groups">
	<!--- Malzeme boyutlarını parse et --->
	<!--- DIMENTION formatı: eni*boy*kalınlık (width*height*thickness) = 2100*2800*18 --->
	<cfset sheet_width = 2100>
	<cfset sheet_height = 2800>
	<cfset sheet_thickness = 18>
	<cfif len(get_sheet_groups.DIMENTION) and ListLen(get_sheet_groups.DIMENTION, '*') gte 2>
		<cfif isNumeric(ListGetAt(get_sheet_groups.DIMENTION, 1, '*'))>
			<cfset sheet_width = ListGetAt(get_sheet_groups.DIMENTION, 1, '*')>
		</cfif>
		<cfif isNumeric(ListGetAt(get_sheet_groups.DIMENTION, 2, '*'))>
			<cfset sheet_height = ListGetAt(get_sheet_groups.DIMENTION, 2, '*')>
		</cfif>
		<cfif ListLen(get_sheet_groups.DIMENTION, '*') gte 3 and isNumeric(ListGetAt(get_sheet_groups.DIMENTION, 3, '*'))>
			<cfset sheet_thickness = ListGetAt(get_sheet_groups.DIMENTION, 3, '*')>
		</cfif>
	</cfif>
	
	<!--- Bu malzeme için OUTER_EDGE_TRIMMING_ALLOWANCE ve CUTTING_STARTING_DIRECTION değerlerini al --->
	<cfset material_rim = 0>
	<cfset cutting_direction = 1>
	<cfif structKeyExists(materialSettingsMap, get_sheet_groups.STOCK_ID)>
		<cfset material_rim = materialSettingsMap[get_sheet_groups.STOCK_ID].trimAllowance>
		<cfset cutting_direction = materialSettingsMap[get_sheet_groups.STOCK_ID].cuttingStartingDirection>
	</cfif>
	
	<!--- Malzeme adını temizle (XML için) --->
	<cfset material_name = Replace(Replace(Replace(get_sheet_groups.PRODUCT_NAME, '"', ''), '<', ''), '>', '')>
	<cfif len(material_name) EQ 0>
		<cfset material_name = "Malzeme1">
	</cfif>
	
	<!--- Panel başlangıcı --->
	<cfset xml_content = xml_content & '<panel#get_sheet_groups.SHEET_GROUP_NUMBER# code="1" l="#Int(sheet_height)#" material="#material_name#" num="#get_sheet_groups.SHEET_COUNT#" trim="#material_rim#" saw="#kerf_thickness#" thickness="#Int(sheet_thickness)#" w="#Int(sheet_width)#">'>
	
	<!--- Bu sheet group için tüm sheet'leri al --->
	<cfquery name="get_sheets" datasource="#dsn3#">
		SELECT DISTINCT
			OER.OPTIMIZATION_RESULT_ID,
			OER.SHEET_NUMBER,
			OER.SHEET_GROUP_NUMBER
		FROM 
			EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER WITH (NOLOCK)
		WHERE 
			OER.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
			AND OER.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_sheet_groups.SHEET_GROUP_NUMBER#">
		ORDER BY 
			OER.SHEET_NUMBER
	</cfquery>
	
	<!--- Her sheet için parçaları al ve kesim katmanlarını oluştur --->
	<cfloop query="get_sheets">
		<!--- Bu sheet'e ait parçaları al (sıralama kesim yönüne göre) --->
		<cfquery name="get_pieces" datasource="#dsn3#">
			SELECT 
				OERR.OPTIMIZATION_RESULT_ROW_ID,
				OERR.PIECE_NAME,
				OERR.LOT_NO,
				OERR.P_ORDER_NO,
				OERR.X_POINT,
				OERR.Y_POINT,
				OERR.WIDTH,
				OERR.HEIGHT
			FROM 
				EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS OERR WITH (NOLOCK)
			WHERE 
				OERR.OPTIMIZATION_RESULT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_sheets.OPTIMIZATION_RESULT_ID#">
			ORDER BY 
				<cfif cutting_direction EQ 2>
					OERR.X_POINT, OERR.Y_POINT
				<cfelse>
					OERR.Y_POINT, OERR.X_POINT
				</cfif>
		</cfquery>
		
		<cfif get_pieces.recordcount>
			<cfif cutting_direction EQ 1>
				<!--- ========== YATAY KESİM ÖNCELİKLİ ========== --->
				<!--- Layer 1: İlk kesim yatay (Y ekseni boyunca) --->
				<cfset layer1_height = sheet_height - (material_rim * 2)>
				<cfset xml_content = xml_content & '<no.#cut_counter# id="0" l="#Int(layer1_height)#" layer="1" trim="#material_rim#" w="#Int(sheet_width)#" x="0" y="0">'>
				
				<cfset prev_y = material_rim>
				<cfloop query="get_pieces">
					<cfset current_y = Int(get_pieces.Y_POINT)>
					<cfif current_y GT prev_y>
						<cfset cut_dist = current_y - prev_y>
						<cfset xml_content = xml_content & '<part code="" cut="#Int(cut_dist)#" id="#get_pieces.OPTIMIZATION_RESULT_ROW_ID#" type="2"/>'>
					</cfif>
					<cfset prev_y = current_y + Int(get_pieces.HEIGHT)>
				</cfloop>
				
				<cfset xml_content = xml_content & '</no.#cut_counter#'>
				<cfset cut_counter = cut_counter + 1>
				
				<!--- Layer 2 ve 3: Parçalar (dikey kesimler) --->
				<cfloop query="get_pieces">
					<cfset part_key = "#get_pieces.PIECE_NAME#_#Int(get_pieces.WIDTH)#_#Int(get_pieces.HEIGHT)#">
					<cfif not structKeyExists(part_code_map, part_key)>
						<cfset part_code_map[part_key] = part_code_counter>
						<cfset part_code_counter = part_code_counter + 1>
					</cfif>
					<cfset current_part_code = part_code_map[part_key]>
					
					<cfset pX = Int(get_pieces.X_POINT)>
					<cfset pY = Int(get_pieces.Y_POINT)>
					<cfset pW = Int(get_pieces.WIDTH)>
					<cfset pH = Int(get_pieces.HEIGHT)>
					
					<!--- Layer 2: Yatay şerit içinde dikey kesim (l=sheet_width, w=parça_eni, cut=parça_boyu) --->
					<cfset xml_content = xml_content & '<no.#cut_counter# id="#get_pieces.OPTIMIZATION_RESULT_ROW_ID#" l="#Int(sheet_width)#" layer="2" trim="#material_rim#" w="#pW#" x="0" y="#pY#">'>
					<cfset xml_content = xml_content & '<part code="#current_part_code#" cut="#pH#" id="#get_pieces.OPTIMIZATION_RESULT_ROW_ID#" type="1"/>'>
					<cfset xml_content = xml_content & '</no.#cut_counter#'>
					<cfset cut_counter = cut_counter + 1>
					
					<!--- Layer 3: Final parça --->
					<cfset xml_content = xml_content & '<no.#cut_counter# id="#get_pieces.OPTIMIZATION_RESULT_ROW_ID#" l="#pH#" layer="3" trim="0" w="#pW#" x="#pX#" y="#pY#"/>'>
					<cfset cut_counter = cut_counter + 1>
				</cfloop>
				
			<cfelse>
				<!--- ========== DİKEY KESİM ÖNCELİKLİ ========== --->
				<!--- Layer 1: İlk kesim dikey (X ekseni boyunca) --->
				<cfset layer1_width = sheet_width - (material_rim * 2)>
				<cfset xml_content = xml_content & '<no.#cut_counter# id="0" l="#Int(sheet_height)#" layer="1" trim="#material_rim#" w="#Int(layer1_width)#" x="0" y="0">'>
				
				<cfset prev_x = material_rim>
				<cfloop query="get_pieces">
					<cfset current_x = Int(get_pieces.X_POINT)>
					<cfif current_x GT prev_x>
						<cfset cut_dist = current_x - prev_x>
						<cfset xml_content = xml_content & '<part code="" cut="#Int(cut_dist)#" id="#get_pieces.OPTIMIZATION_RESULT_ROW_ID#" type="2"/>'>
					</cfif>
					<cfset prev_x = current_x + Int(get_pieces.WIDTH)>
				</cfloop>
				
				<cfset xml_content = xml_content & '</no.#cut_counter#'>
				<cfset cut_counter = cut_counter + 1>
				
				<!--- Layer 2 ve 3: Parçalar (yatay kesimler) --->
				<cfloop query="get_pieces">
					<cfset part_key = "#get_pieces.PIECE_NAME#_#Int(get_pieces.WIDTH)#_#Int(get_pieces.HEIGHT)#">
					<cfif not structKeyExists(part_code_map, part_key)>
						<cfset part_code_map[part_key] = part_code_counter>
						<cfset part_code_counter = part_code_counter + 1>
					</cfif>
					<cfset current_part_code = part_code_map[part_key]>
					
					<cfset pX = Int(get_pieces.X_POINT)>
					<cfset pY = Int(get_pieces.Y_POINT)>
					<cfset pW = Int(get_pieces.WIDTH)>
					<cfset pH = Int(get_pieces.HEIGHT)>
					
					<!--- Layer 2: Dikey şerit içinde yatay kesim (l=sheet_height, w=parça_boyu, cut=parça_eni) --->
					<cfset xml_content = xml_content & '<no.#cut_counter# id="#get_pieces.OPTIMIZATION_RESULT_ROW_ID#" l="#Int(sheet_height)#" layer="2" trim="#material_rim#" w="#pH#" x="#pX#" y="0">'>
					<cfset xml_content = xml_content & '<part code="#current_part_code#" cut="#pW#" id="#get_pieces.OPTIMIZATION_RESULT_ROW_ID#" type="1"/>'>
					<cfset xml_content = xml_content & '</no.#cut_counter#'>
					<cfset cut_counter = cut_counter + 1>
					
					<!--- Layer 3: Final parça --->
					<cfset xml_content = xml_content & '<no.#cut_counter# id="#get_pieces.OPTIMIZATION_RESULT_ROW_ID#" l="#pW#" layer="3" trim="0" w="#pH#" x="#pX#" y="#pY#"/>'>
					<cfset cut_counter = cut_counter + 1>
				</cfloop>
			</cfif>
		</cfif>
	</cfloop>
	
	<cfset xml_content = xml_content & '</panel#get_sheet_groups.SHEET_GROUP_NUMBER#>'>
</cfloop>

<!--- Parts bölümü: Tüm parçaların özeti --->
<cfset xml_content = xml_content & '<parts>'>
<cfloop query="get_all_parts_summary">
	<!--- Parça kodu bul --->
	<cfset part_key = "#PIECE_NAME#_#Int(WIDTH)#_#Int(HEIGHT)#">
	<cfif structKeyExists(part_code_map, part_key)>
		<cfset current_part_code = part_code_map[part_key]>
		<cfset xml_content = xml_content & '<part code="#current_part_code#" l="#Int(HEIGHT)#" rc="0" sq="#PART_COUNT#" uc="#PART_COUNT#" w="#Int(WIDTH)#"/>'>
	</cfif>
</cfloop>
<cfset xml_content = xml_content & '</parts>'>
<cfset xml_content = xml_content & '</project>'>

<!--- XML'i dosyaya yaz --->
<cfset file_name = "KDT_Optimization_#get_optimization.OPTIMIZATION_NUMBER#_#DateFormat(now(), 'YYYYMMDD')#_#TimeFormat(now(), 'HHMMSS')#.xml">
<cfif isdefined('attributes.sheet_group_number') and len(attributes.sheet_group_number) and isNumeric(attributes.sheet_group_number)>
	<cfset file_name = "KDT_Optimization_#get_optimization.OPTIMIZATION_NUMBER#_SheetGroup_#attributes.sheet_group_number#_#DateFormat(now(), 'YYYYMMDD')#_#TimeFormat(now(), 'HHMMSS')#.xml">
</cfif>

<cfset file_path = "#upload_folder#production/#file_name#">
<cffile action="write" file="#file_path#" output="#xml_content#" addnewline="no" charset="UTF-8">

<!--- Dosyayı indir --->
<cfheader name="Content-Disposition" value="attachment; filename=#file_name#">
<cfcontent type="application/xml" file="#file_path#" deletefile="yes">
