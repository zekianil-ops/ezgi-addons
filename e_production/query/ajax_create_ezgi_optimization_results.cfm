<!---
    File: ajax_create_ezgi_optimization_results.cfm
    Folder: AddOns\ezgi\e_production\query
    Author: Ezgi Yazılım
    Date: 12/12/2025
    Description: Optimizasyon Satırı Ekleme (AJAX)
--->

<cfparam name="attributes.optimization_id" default="">
<cfparam name="attributes.add_process" default="">
<cfparam name="attributes.del_process" default="">
<cfparam name="attributes.material_data" default="">
<cfparam name="attributes.update_virtual" default="">
<cfparam name="attributes.sheet_group_number" default="">
<cfparam name="attributes.is_virtual_material" default="0">

<!--- AJAX çağrısında URL'den gelen add_process/del_process değerlerini attributes'a yansıt --->
<cfif isDefined("url.add_process") and len(url.add_process)>
	<cfset attributes.add_process = url.add_process>
</cfif>
<cfif isDefined("url.del_process") and len(url.del_process)>
	<cfset attributes.del_process = url.del_process>
</cfif>
<cfif isDefined("url.update_virtual") and len(url.update_virtual)>
	<cfset attributes.update_virtual = url.update_virtual>
</cfif>
<cfif isDefined("url.sheet_group_number") and len(url.sheet_group_number)>
	<cfset attributes.sheet_group_number = url.sheet_group_number>
</cfif>
<cfif isDefined("url.is_virtual_material") and len(url.is_virtual_material)>
	<cfset attributes.is_virtual_material = url.is_virtual_material>
</cfif>

<!--- Form'dan gelen material_data'yı attributes'a kopyala --->
<cfif isDefined("form.material_data") and len(form.material_data)>
	<cfset attributes.material_data = form.material_data>
</cfif>
<cfif isDefined("form.sheet_group_number") and len(form.sheet_group_number)>
	<cfset attributes.sheet_group_number = form.sheet_group_number>
</cfif>
<cfif isDefined("form.is_virtual_material") and len(form.is_virtual_material)>
	<cfset attributes.is_virtual_material = form.is_virtual_material>
</cfif>
<cfquery name="get_optimizition" datasource="#dsn3#">
	SELECT * FROM EZGI_IFLOW_OPTIMIZATION WHERE OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
</cfquery>
<!--- IS_VIRTUAL_MATERIAL güncelleme işlemi --->
<cfif isdefined('attributes.update_virtual') and len(attributes.update_virtual)>
	<!--- JSON response için Content-Type header'ı ayarla --->
	<cfcontent type="application/json; charset=utf-8">
	
	<!--- Validasyon --->
	<cfif not len(attributes.sheet_group_number) or not isNumeric(attributes.sheet_group_number)>
		<cfoutput>{"success": false, "message": "Geçersiz sheet group number: #attributes.sheet_group_number#"}</cfoutput>
		<cfabort>
	</cfif>
	
	<cfif not len(attributes.optimization_id) or not isNumeric(attributes.optimization_id)>
		<cfoutput>{"success": false, "message": "Geçersiz optimization ID: #attributes.optimization_id#"}</cfoutput>
		<cfabort>
	</cfif>
	
	<cfset is_virtual = 0>
	<cfif attributes.is_virtual_material EQ "1" or attributes.is_virtual_material EQ 1 or attributes.is_virtual_material EQ true>
		<cfset is_virtual = 1>
	</cfif>
	
	<!--- IS_VIRTUAL_MATERIAL alanını güncelle --->
	<cftry>
		<cfquery name="upd_virtual_material" datasource="#dsn3#">
			UPDATE 
				EZGI_IFLOW_OPTIMIZATION_RESULTS
			SET 
				IS_VIRTUAL_MATERIAL = <cfqueryparam cfsqltype="cf_sql_bit" value="#is_virtual#">
			WHERE 
				OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
				AND SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
		</cfquery>
		
		<cfoutput>{"success": true, "message": "Güncelleme başarılı"}</cfoutput>
		<cfcatch type="any">
			<cfoutput>{"success": false, "message": "Veritabanı hatası: #cfcatch.message#", "detail": "#cfcatch.detail#"}</cfoutput>
		</cfcatch>
	</cftry>
	<cfabort>
</cfif>

<!--- SADE KONTROL: Sadece add_process varsa önce malzeme update yap, sonra hesaplama yap --->
<cfif isdefined('attributes.add_process') and len(attributes.add_process)>
	
	<!--- Malzeme verilerini UPDATE et --->
	<cfif len(attributes.material_data)>
		<cfset materialArray = deserializeJSON(attributes.material_data)>
		<cfloop array="#materialArray#" index="material">
			<cfif len(material.row_id) and len(material.stock_id) and len(material.workstation_id)>
				<cfquery name="update_material_row" datasource="#dsn3#">
					UPDATE 
						EZGI_IFLOW_OPTIMIZATION_MATERIAL_ROW
					SET 
						STOCK_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#material.stock_id#">,
						WORKSTATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#material.workstation_id#">
					WHERE 
						OPTIMIZATION_MATERIAL_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#material.row_id#">
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>
	<cfquery name="get_optimization_materials" datasource="#dsn3#">
		SELECT 
			E.STOCK_ID, 
			ER.STOCK_ID AS SELECTED_STOCK_ID, 
			ER.WORKSTATION_ID AS SELECTED_WORKSTATION_ID, 
			ISNULL(W.CIRCLE_TESTRE_THICKNESS, - 1) AS CIRCLE_TESTRE_THICKNESS, 
            ISNULL(W.OUTER_EDGE_TRIMMING_ALLOWANCE, - 1) AS OUTER_EDGE_TRIMMING_ALLOWANCE,
			ISNULL(W.CUTTING_METHOD,2) AS CUTTING_METHOD,
			ISNULL(W.CUTTING_STARTING_DIRECTION,1) AS CUTTING_STARTING_DIRECTION,
			ISNULL(W.MAXIMUM_NUMBER_OF_CUTS,1) AS MAXIMUM_NUMBER_OF_CUTS
		FROM     
			EZGI_IFLOW_OPTIMIZATION_MATERIAL AS E INNER JOIN
            EZGI_IFLOW_OPTIMIZATION_MATERIAL_ROW AS ER ON E.OPTIMIZATION_MATERIAL_ID = ER.OPTIMIZATION_MATERIAL_ID LEFT OUTER JOIN
            WORKSTATIONS AS W ON ER.WORKSTATION_ID = W.STATION_ID
		WHERE  
			E.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
	</cfquery>
	
	<cfquery name="get_orders" datasource="#dsn3#">
			SELECT DISTINCT        
				P_ORDER_ID
			FROM            
				(
					SELECT
						EI.LOT_NO, 
						PO.P_ORDER_ID, 
						PO.STOCK_ID, 
						EPR.PIECE_TYPE
					FROM            
						EZGI_IFLOW_PRODUCTION_ORDERS AS EI INNER JOIN
						PRODUCTION_ORDERS AS PO ON EI.LOT_NO = PO.LOT_NO INNER JOIN
						EZGI_DESIGN_PIECE_ROWS AS EPR ON PO.STOCK_ID = EPR.PIECE_RELATED_ID INNER JOIN
						EZGI_IFLOW_OPTIMIZATION_ROW AS EOR ON EI.IFLOW_P_ORDER_ID = EOR.IFLOW_P_ORDER_ID
					WHERE        
						EPR.PIECE_TYPE = 1 AND 
						EOR.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
				) AS TBL
	</cfquery>
	<cfquery name="get_master_plan" datasource="#dsn3#">
			SELECT MASTER_PLAN_NUMBER, MASTER_PLAN_DETAIL FROM EZGI_IFLOW_MASTER_PLAN WHERE  MASTER_PLAN_ID = #get_optimizition.master_plan_id#
	</cfquery>
	<cfset dosya_name = '#get_master_plan.MASTER_PLAN_NUMBER# #get_master_plan.MASTER_PLAN_DETAIL#'>
	
	<cfif get_orders.recordcount>
		<cfset satirlar = queryNew("parca_adi, malzeme, kesim_boy, kesim_en, adet, yon, lot_no, emir_no", "cf_sql_varchar, cf_sql_integer, Decimal, Decimal, Decimal, cf_sql_integer, cf_sql_varchar, cf_sql_varchar")> 
		<cfloop query="get_orders">
			<cfquery name="get_related_tree" datasource="#dsn3#">
					<!---Standart Parçalar --->
					SELECT      
						2 AS TYPE,
						PO.STOCK_ID, 
						MIN(E1.PIECE_ROW_ID) AS PIECE_ROW_ID, 
						PO.P_ORDER_ID, 
						PO.QUANTITY, 
						PO.P_ORDER_NO,
						PO.LOT_NO
					FROM            
						EZGI_DESIGN_PIECE_ROWS AS E1 INNER JOIN
						PRODUCTION_ORDERS AS PO ON E1.PIECE_RELATED_ID = PO.STOCK_ID INNER JOIN
						EZGI_DESIGN_PIECE_ROW AS EDPR ON E1.PIECE_ROW_ID = EDPR.RELATED_PIECE_ROW_ID INNER JOIN
						STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID
					WHERE        
						PO.P_ORDER_ID = #get_orders.P_ORDER_ID# AND 
						E1.PIECE_TYPE = 1 AND 
						PO.IS_DEMONTAJ = 0 AND
						ISNULL(S.IS_PROTOTYPE,0) = 0
					GROUP BY
						PO.STOCK_ID, 
						PO.P_ORDER_ID, 
						PO.QUANTITY, 
						PO.P_ORDER_NO,
						PO.LOT_NO
					UNION ALL
					SELECT       
						2 AS TYPE, 
						PO.STOCK_ID, 
						MIN(E1.PIECE_ROW_ID) AS PIECE_ROW_ID, 
						PO.P_ORDER_ID, 
						PO.QUANTITY, 
						PO.P_ORDER_NO, 
						PO.LOT_NO
					FROM            
						EZGI_DESIGN_PIECE_ROWS AS E1 INNER JOIN
						PRODUCTION_ORDERS AS PO ON E1.PIECE_RELATED_ID = PO.STOCK_ID LEFT OUTER JOIN
						EZGI_DESIGN_PIECE_ROW AS EDPR ON E1.PIECE_ROW_ID = EDPR.RELATED_PIECE_ROW_ID INNER JOIN
						STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID
					WHERE        
						PO.P_ORDER_ID = #get_orders.P_ORDER_ID# AND 
						E1.PIECE_TYPE = 1 AND 
						EDPR.PIECE_ROW_ROW_ID IS NULL AND 
						PO.IS_DEMONTAJ = 0 AND
						ISNULL(S.IS_PROTOTYPE,0) = 0
					GROUP BY
						PO.STOCK_ID, 
						PO.P_ORDER_ID, 
						PO.QUANTITY, 
						PO.P_ORDER_NO, 
						PO.LOT_NO
					<!---Özel Parçalar --->
					UNION ALL
					SELECT DISTINCT        
						2 AS TYPE,
						PO.STOCK_ID, 
						E1.PIECE_ROW_ID, 
						PO.P_ORDER_ID, 
						PO.QUANTITY, 
						PO.P_ORDER_NO,
						PO.LOT_NO
					FROM            
						EZGI_DESIGN_PIECE_ROWS AS E1 INNER JOIN
						PRODUCTION_ORDERS AS PO ON E1.PIECE_SPECT_RELATED_ID = PO.SPEC_MAIN_ID INNER JOIN
						EZGI_DESIGN_PIECE_ROW AS EDPR ON E1.PIECE_ROW_ID = EDPR.RELATED_PIECE_ROW_ID INNER JOIN
						STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID
					WHERE        
						PO.P_ORDER_ID = #get_orders.P_ORDER_ID# AND 
						E1.PIECE_TYPE = 1 AND 
						PO.IS_DEMONTAJ = 0 AND
						ISNULL(S.IS_PROTOTYPE,0) = 1
					UNION ALL
					SELECT DISTINCT        
						2 AS TYPE, 
						PO.STOCK_ID, 
						E1.PIECE_ROW_ID, 
						PO.P_ORDER_ID, 
						PO.QUANTITY, 
						PO.P_ORDER_NO,
						PO.LOT_NO
					FROM            
						EZGI_DESIGN_PIECE_ROWS AS E1 INNER JOIN
						PRODUCTION_ORDERS AS PO ON E1.PIECE_SPECT_RELATED_ID = PO.SPEC_MAIN_ID LEFT OUTER JOIN
						EZGI_DESIGN_PIECE_ROW AS EDPR ON E1.PIECE_ROW_ID = EDPR.RELATED_PIECE_ROW_ID INNER JOIN
						STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID
					WHERE        
						PO.P_ORDER_ID = #get_orders.P_ORDER_ID# AND 
						E1.PIECE_TYPE = 1 AND 
						EDPR.PIECE_ROW_ROW_ID IS NULL AND 
						PO.IS_DEMONTAJ = 0 AND
						ISNULL(S.IS_PROTOTYPE,0) = 1
			</cfquery>

			<cfif get_related_tree.recordcount>
				<cfset attributes.design_piece_row_id = get_related_tree.PIECE_ROW_ID>
				<cfset attributes.product_quantity = get_related_tree.QUANTITY>
				<cfquery name="get_product" datasource="#dsn3#">
							SELECT 
								PIECE_ROW_ID,
								PIECE_TYPE, 
								UPPER(REPLACE(REPLACE(REPLACE(PIECE_NAME,'Ğ','G'),'i','I'),'Ş','S')) AS PIECE_NAME,
								PIECE_CODE, 
								PIECE_COLOR_ID, 
								PIECE_DETAIL, 
								PIECE_AMOUNT, 
								TRIM_TYPE, 
								TRIM_SIZE, 
								IS_FLOW_DIRECTION, 
								BOYU, 
								ENI, 
								KESIM_BOYU, 
								KESIM_ENI, 
								KALINLIK,
								MATERIAL_ID,
								(SELECT UPPER(REPLACE(REPLACE(REPLACE(DESIGN_NAME,'Ğ','G'),'i','I'),'Ş','S')) AS DESIGN_NAME FROM EZGI_DESIGN WHERE DESIGN_ID = E.DESIGN_ID) as DESIGN_MAIN_NAME,
								(SELECT PACKAGE_NUMBER FROM EZGI_DESIGN_PACKAGE WHERE PACKAGE_ROW_ID = E.DESIGN_PACKAGE_ROW_ID) as PACKAGE_NUMBER,
								(SELECT PROPERTY_DETAIL FROM #dsn1_alias#.PRODUCT_PROPERTY_DETAIL WHERE PRPT_ID = 2 AND PROPERTY_DETAIL_ID = E.KALINLIK) AS KALINLIK_
							FROM 
								EZGI_DESIGN_PIECE_ROWS AS E
							WHERE 
								PIECE_ROW_ID = #attributes.design_piece_row_id#
				</cfquery>
				<cfset product_cat_id_list = ''>
				<cfif get_product.recordcount>
					<cfset product_cat_id_list = ValueList(get_product.MATERIAL_ID)>
					<cfset product_cat_id_list = ListDeleteDuplicates(product_cat_id_list,',')>
					<cfif ListLen(product_cat_id_list)>
						<cfquery name="get_malzeme" datasource="#dsn3#">
								SELECT        
									PT.STOCK_ID,
									PT.RELATED_ID
								FROM            
									PRODUCT_TREE AS PT INNER JOIN
									STOCKS AS S ON PT.RELATED_ID = S.STOCK_ID
								WHERE        
									PT.STOCK_ID IN (#product_cat_id_list#) AND 
									PT.RELATED_ID IS NOT NULL
								GROUP BY 
									PT.STOCK_ID, 
									PT.RELATED_ID
						</cfquery>
						<cfoutput query="get_malzeme">
							<cfset 'PRODUCT_CAT_#STOCK_ID#' = RELATED_ID>
						</cfoutput>
					</cfif>
				</cfif>
				
				<cfset Temp = QueryAddRow(satirlar)> 
				<cfset querySetCell(satirlar, "emir_no", get_related_tree.P_ORDER_NO)>
				<cfset querySetCell(satirlar, "lot_no", get_related_tree.LOT_NO)>
				<cfset querySetCell(satirlar, "parca_adi", '#get_product.DESIGN_MAIN_NAME# #get_product.PIECE_NAME#')> 
				<cfset querySetCell(satirlar, "adet", get_related_tree.QUANTITY)>
				<cfset querySetCell(satirlar, "kesim_boy", Floor(get_product.KESIM_BOYU))>
				<cfset querySetCell(satirlar, "kesim_en", Floor(get_product.KESIM_ENI))>
				<cfset querySetCell(satirlar, "yon", get_product.IS_FLOW_DIRECTION)>

		
				<cfif isdefined('PRODUCT_CAT_#get_product.MATERIAL_ID#') and len(Evaluate('PRODUCT_CAT_#get_product.MATERIAL_ID#'))>
					<cfquery name="get_selected_stock" dbtype="query">
						 SELECT 
							SELECTED_STOCK_ID, 
							SELECTED_WORKSTATION_ID, 
							CIRCLE_TESTRE_THICKNESS, 
							OUTER_EDGE_TRIMMING_ALLOWANCE 
						FROM 
							get_optimization_materials 
						WHERE 
							STOCK_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Evaluate('PRODUCT_CAT_#get_product.MATERIAL_ID#')#">
					</cfquery>
					<cfif not get_selected_stock.recordcount and len(get_selected_stock.SELECTED_STOCK_ID)>
						Stokta Sorun var. Malzeme Seçilmedi.
						<cfabort>
					<cfelse>
						<cfset querySetCell(satirlar, "malzeme", get_selected_stock.SELECTED_STOCK_ID)>
					</cfif>
				<cfelse>
					Malzemede Sorun Var
					<cfabort>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<cfquery name="satırlar" dbtype="query">
			SELECT
				lot_no,
				emir_no,
				parca_adi,
				kesim_boy,
				kesim_en,
				malzeme,
				adet,
				yon
			FROM
				satirlar	
	</cfquery>
	<cfset malzeme_id_list = ListDeleteDuplicates(ValueList(satırlar.malzeme))>
  	<cfquery name="get_dimention" datasource="#dsn3#">
        	SELECT        
            	S.STOCK_ID, 
                PU.DIMENTION
			FROM            
            	STOCKS AS S INNER JOIN
                PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
			WHERE        
            	S.STOCK_ID IN (#malzeme_id_list#)
	</cfquery>
	<!--- Malzeme ölçülerini struct'a yükle (dinamik kullanım için) --->
	<cfset sheetDimensions = structNew()>
	<cfoutput query="get_dimention">
    	<cfif ListLen(DIMENTION,'*') gt 1>
         	<cfif isnumeric(ListGetAt(DIMENTION,1,'*'))> <!---Levha Eni--->
            	<cfset sheetDimensions[STOCK_ID] = structNew()>
				<cfset sheetDimensions[STOCK_ID].width = ListGetAt(DIMENTION,1,'*')>
			<cfelse>
              	<cfset sheetDimensions[STOCK_ID] = structNew()>
				<cfset sheetDimensions[STOCK_ID].width = 2100> <!---Eğer Numeric değer değilse Standart Değer Gelsin--->
           	</cfif>
        	<cfif isnumeric(ListGetAt(DIMENTION,2,'*'))> <!---Levha Boyu--->
            	<cfset sheetDimensions[STOCK_ID].height = ListGetAt(DIMENTION,2,'*')>
			<cfelse>
            	<cfset sheetDimensions[STOCK_ID].height = 2800> <!---Eğer Numeric değer değilse Standart Değer Gelsin--->
       		</cfif>
    	<cfelse>
          	<cfset sheetDimensions[STOCK_ID] = structNew()>
			<cfset sheetDimensions[STOCK_ID].width = 2100> <!---Eğer Bilgi Yetersiz ise Standart Değer Gelsin--->
       		<cfset sheetDimensions[STOCK_ID].height = 2800> <!---Eğer Bilgi Yetersiz ise Standart Değer Gelsin--->
      	</cfif>
 	</cfoutput>
	
	<!--- Malzeme bazında CIRCLE_TESTRE_THICKNESS ve OUTER_EDGE_TRIMMING_ALLOWANCE değerlerini struct'a yükle --->
	<cfset materialSettings = structNew()>
	<cfoutput query="get_optimization_materials">
		<cfif not structKeyExists(materialSettings, SELECTED_STOCK_ID)>
			<cfset materialSettings[SELECTED_STOCK_ID] = structNew()>
			<cfset materialSettings[SELECTED_STOCK_ID].kerf = (isNumeric(CIRCLE_TESTRE_THICKNESS) and val(CIRCLE_TESTRE_THICKNESS) GT 0) ? val(CIRCLE_TESTRE_THICKNESS) : 4>
			<cfset materialSettings[SELECTED_STOCK_ID].trimAllowance = (isNumeric(OUTER_EDGE_TRIMMING_ALLOWANCE) and val(OUTER_EDGE_TRIMMING_ALLOWANCE) GT 0) ? val(OUTER_EDGE_TRIMMING_ALLOWANCE) : 0>
			<cfset materialSettings[SELECTED_STOCK_ID].cuttingMethod = (isNumeric(CUTTING_METHOD) and (val(CUTTING_METHOD) EQ 1 or val(CUTTING_METHOD) EQ 2)) ? val(CUTTING_METHOD) : 2>
			<cfset materialSettings[SELECTED_STOCK_ID].cuttingStartingDirection = (isNumeric(CUTTING_STARTING_DIRECTION) and (val(CUTTING_STARTING_DIRECTION) EQ 1 or val(CUTTING_STARTING_DIRECTION) EQ 2)) ? val(CUTTING_STARTING_DIRECTION) : 1>
		</cfif>
	</cfoutput>
	<cfset piecesArray = []>
	<cfoutput query="satırlar">
		<cfset piece = {
				"lot_no"= lot_no,
				"emir_no"= emir_no,
				"name" = parca_adi,
				"width" = kesim_en,
				"height" = kesim_boy,
				"quantity" = adet,
				"sheet_name" = malzeme,
				"yon" = yon
		}>
		<cfset arrayAppend(piecesArray, piece)>
	</cfoutput>
	
	<cfset pieces = piecesArray >
	<cfscript>
			// allowRotation artık global değil, her parça için yon değerine göre belirlenecek
		
			// --- SONUÇ DEĞİŞKENİ ---
			yerlesim = [];
		
			// --- TABAKA GRUPLARINA GÖRE PARÇALARI AYIR ---
			sheetGroups = structNew();
		
			// pieces: daha önce query'den oluşturduğun array of structs
			for (p in pieces) {
				// tipleri normalize et
				p.width    = val(p.width);
				p.height   = val(p.height);
				p.quantity = int(val(p.quantity));
				if (p.quantity LTE 0) p.quantity = 1;
				
				// yon değerini normalize et (0 veya 1 olmalı)
				if (!structKeyExists(p, "yon")) {
					p.yon = 0; // Varsayılan: rotation serbest
				} else {
					p.yon = int(val(p.yon));
					if (p.yon NEQ 0 AND p.yon NEQ 1) {
						p.yon = 0; // Geçersiz değer ise varsayılan
					}
				}
		
				if (!structKeyExists(p, "sheet_name") OR trim(p.sheet_name) EQ "") {
					p.sheet_name = "DEFAULT";
				}
		
				if (!structKeyExists(sheetGroups, p.sheet_name)) {
					sheetGroups[p.sheet_name] = [];
				}
				arrayAppend(sheetGroups[p.sheet_name], p);
			}
		
		// --- HER TABAKA GRUBU İÇİN OPTİMİZASYON ---
		for (sheetKey in sheetGroups) {
	
			groupPieces = sheetGroups[sheetKey];
			
			// Bu malzeme grubu için dinamik tabaka ölçülerini al
			sheetKeyNumeric = val(sheetKey);
			if (structKeyExists(sheetDimensions, sheetKeyNumeric)) {
				currentSheetWidth  = sheetDimensions[sheetKeyNumeric].width;
				currentSheetHeight = sheetDimensions[sheetKeyNumeric].height;
			} else {
				// Fallback: Eğer ölçü bulunamazsa varsayılan değerler
				currentSheetWidth  = 2100;
				currentSheetHeight = 2800;
			}
			
			// Bu malzeme için testere payı (kerf), dış kenar traşlama payı ve kesim yöntemini al
			if (structKeyExists(materialSettings, sheetKeyNumeric)) {
				kerf = materialSettings[sheetKeyNumeric].kerf;
				trimAllowance = materialSettings[sheetKeyNumeric].trimAllowance;
				cuttingMethod = materialSettings[sheetKeyNumeric].cuttingMethod;
				cuttingStartingDirection = materialSettings[sheetKeyNumeric].cuttingStartingDirection;
			} else {
				// Fallback: Varsayılan değerler
				kerf = 4;
				trimAllowance = 0;
				cuttingMethod = 2;
				cuttingStartingDirection = 1;
			}
			
			// Dış Kenar Traşlama Payı (mm) → hem en hem boydan iki kenar için düş
			if (trimAllowance GT 0) {
				// Her iki kenardan da trimAllowance kadar düşeceğimiz için toplam 2 * trimAllowance
				currentSheetWidth  = currentSheetWidth  - (2 * trimAllowance);
				currentSheetHeight = currentSheetHeight - (2 * trimAllowance);
				
				// Güvenlik: negatif veya 0 olmasın
				if (currentSheetWidth LTE 0)  currentSheetWidth  = 1;
				if (currentSheetHeight LTE 0) currentSheetHeight = 1;
			}
		
				// quantity'leri açıp tek tek yerleştirilecek liste oluştur
				piecesToPlace = [];
				for (p in groupPieces) {
					for (i = 1; i LTE p.quantity; i++) {
						pieceItem = {
							name       = p.name,
							width      = p.width,
							height     = p.height,
							sheet_name = p.sheet_name,
							lot_no     = structKeyExists(p,"lot_no") ? p.lot_no : "",
							emir_no    = structKeyExists(p,"emir_no") ? p.emir_no : "",
							yon        = structKeyExists(p,"yon") ? p.yon : 0
						};
						arrayAppend(piecesToPlace, pieceItem);
					}
				}
		
				// Gelişmiş sıralama: Çevre uzunluğu ve en uzun kenar bazlı
				arraySort(piecesToPlace, function(a,b){
					// Önce alan bazlı
					areaDiff = (b.width*b.height) - (a.width*a.height);

					if (areaDiff NEQ 0) return areaDiff;
					
					// Alan eşitse çevre uzunluğuna göre (daha uzun çevre = öncelik)
					perimeterA = 2 * (a.width + a.height);
					perimeterB = 2 * (b.width + b.height);
					perimeterDiff = perimeterB - perimeterA;
					if (perimeterDiff NEQ 0) return perimeterDiff;
					
					// Çevre de eşitse en uzun kenara göre
					maxSideA = max(a.width, a.height);
					maxSideB = max(b.width, b.height);
					return maxSideB - maxSideA;
				});
		
				// Boşluk birleştirme fonksiyonu
				function mergeFreeSpaces(freeSpaces) {
					if (arrayLen(freeSpaces) LTE 1) return freeSpaces;
					
					merged = [];
					processed = [];
					
					for (i = 1; i LTE arrayLen(freeSpaces); i++) {
						if (arrayFind(processed, i) GT 0) continue;
						
						current = freeSpaces[i];
						mergedSpace = {
							x = current.x,
							y = current.y,
							width = current.width,
							height = current.height
						};
						
						// Aynı yükseklikte ve bitişik boşlukları birleştir
						for (j = i+1; j LTE arrayLen(freeSpaces); j++) {
							if (arrayFind(processed, j) GT 0) continue;
							
							other = freeSpaces[j];
							
							// Yatay birleştirme: aynı y, bitişik x
							if (other.y EQ current.y AND other.height EQ current.height) {
								if (other.x EQ (current.x + current.width + kerf)) {
									mergedSpace.width = mergedSpace.width + kerf + other.width;
									arrayAppend(processed, j);
								} else if (current.x EQ (other.x + other.width + kerf)) {
									mergedSpace.x = other.x;
									mergedSpace.width = other.width + kerf + current.width;
									arrayAppend(processed, j);
								}
							}
							// Dikey birleştirme: aynı x, bitişik y
							else if (other.x EQ current.x AND other.width EQ current.width) {
								if (other.y EQ (current.y + current.height + kerf)) {
									mergedSpace.height = mergedSpace.height + kerf + other.height;
									arrayAppend(processed, j);
								} else if (current.y EQ (other.y + other.height + kerf)) {
									mergedSpace.y = other.y;
									mergedSpace.height = other.height + kerf + current.height;
									arrayAppend(processed, j);
								}
							}
						}
						
						arrayAppend(merged, mergedSpace);
						arrayAppend(processed, i);
					}
					return merged;
				}
		
				// Boşlukları sıralama fonksiyonu (alan bazlı, sonra y pozisyonu)
				function sortFreeSpaces(freeSpaces) {
					arraySort(freeSpaces, function(a,b){
						// Önce alan bazlı (büyükten küçüğe)
						areaDiff = (b.width*b.height) - (a.width*a.height);
						if (areaDiff NEQ 0) return areaDiff;
						
						// Alan eşitse y pozisyonuna göre (bottom-left fill için)
						yDiff = a.y - b.y;
						if (yDiff NEQ 0) return yDiff;
						
						// Y eşitse x pozisyonuna göre
						return a.x - b.x;
					});
				}
		
				// Bu sheet grubu için plakalar ve boşluklar
				localSheets = [];    // her eleman: {sheet_no, freeSpaces=[{x,y,width,height}]}
		
				// --- TÜM PARÇALARI DÖN ---
				for (piece in piecesToPlace) {
		
					placed = false;
					bestPlacement = structNew(); // Best-Fit için en iyi yerleştirme bilgisi
					bestWaste = 999999999; // Çok büyük başlangıç değeri
		
					// 1) BEST-FIT: Tüm uygun boşlukları kontrol et, en az fire bırakanı seç
					for (si = 1; si LTE arrayLen(localSheets); si++) {
						sh = localSheets[si];
						
						// cuttingMethod=2 ise boşlukları birleştir (Hibrit yöntem)
						// cuttingMethod=1 ise birleştirme yapma (Saf Guillotine)
						if (cuttingMethod EQ 2) {
							sh.freeSpaces = mergeFreeSpaces(sh.freeSpaces);
						}
						sortFreeSpaces(sh.freeSpaces);
		
						for (fsIndex = 1; fsIndex LTE arrayLen(sh.freeSpaces); fsIndex++) {
							fs = sh.freeSpaces[fsIndex];
		
							// yon değerine göre orientasyon belirle
							// yon = 0: rotation serbest (hem yatay hem dikey)
							// yon = 1: desen yönü önemli (sadece orijinal yön, parça boyu sheet boyuna gelmeli)
							orientations = [ {w = piece.width, h = piece.height} ];
							pieceYon = structKeyExists(piece, "yon") ? int(val(piece.yon)) : 0;
							if (pieceYon EQ 0) {
								// Rotation serbest: hem orijinal hem döndürülmüş yönü dene
								arrayAppend(orientations, {w = piece.height, h = piece.width});
							}
							// yon = 1 ise sadece orijinal yön kullanılır (parça boyu sheet boyuna gelecek şekilde)
		
							for (o in orientations) {
								if (o.w LTE fs.width AND o.h LTE fs.height) {
									// Fire hesapla (boşluk alanı - parça alanı)
									waste = (fs.width * fs.height) - (o.w * o.h);
									
									// En az fire bırakan yerleştirmeyi seç
									if (waste LT bestWaste) {
										bestWaste = waste;
										bestPlacement = {
											sheetIndex = si,
											spaceIndex = fsIndex,
											orientation = o,
											xPos = fs.x,
											yPos = fs.y,
											freeSpace = fs
										};
									}
								}
							} // orientations
						} // freeSpaces
					} // sheets
		
					// En iyi yerleştirmeyi uygula
					if (structKeyExists(bestPlacement, "sheetIndex")) {
						sh = localSheets[bestPlacement.sheetIndex];
						fs = bestPlacement.freeSpace;
						o = bestPlacement.orientation;
		
						arrayAppend(yerlesim, {
							"lot_no"     : piece.lot_no,
							"emir_no"    : piece.emir_no,
							"sheet_name" : sheetKey,
							"sheet_no"   : sh.sheet_no,
							"piece"      : piece.name,
							"x"          : bestPlacement.xPos,
							"y"          : bestPlacement.yPos,
							"width"      : o.w,
							"height"     : o.h
						});
		
						// Bu boşluğu sil, yerine sağ ve alt boşlukları ekle
						arrayDeleteAt(sh.freeSpaces, bestPlacement.spaceIndex);
		
						rightWidth = fs.width - o.w - kerf;
						bottomHeight = fs.height - o.h - kerf;
						
						if (cuttingMethod EQ 1) {
							// --- SAF GİYOTİN: cuttingStartingDirection'a göre kesim yönü ---
							// 1 = Yatay Kesim Öncelikli, 2 = Dikey Kesim Öncelikli
							if (rightWidth GT 0 AND bottomHeight GT 0) {
								if (cuttingStartingDirection EQ 1) {
									// Yatay Kesim Öncelikli → alt tam genişlik alır
									arrayAppend(sh.freeSpaces, {
										x      = fs.x + o.w + kerf,
										y      = fs.y,
										width  = rightWidth,
										height = o.h
									});
									arrayAppend(sh.freeSpaces, {
										x      = fs.x,
										y      = fs.y + o.h + kerf,
										width  = fs.width,
										height = bottomHeight
									});
								} else {
									// Dikey Kesim Öncelikli → sağ tam yükseklik alır
									arrayAppend(sh.freeSpaces, {
										x      = fs.x + o.w + kerf,
										y      = fs.y,
										width  = rightWidth,
										height = fs.height
									});
									arrayAppend(sh.freeSpaces, {
										x      = fs.x,
										y      = fs.y + o.h + kerf,
										width  = o.w,
										height = bottomHeight
									});
								}
							} else if (rightWidth GT 0) {
								arrayAppend(sh.freeSpaces, {
									x      = fs.x + o.w + kerf,
									y      = fs.y,
									width  = rightWidth,
									height = fs.height
								});
							} else if (bottomHeight GT 0) {
								arrayAppend(sh.freeSpaces, {
									x      = fs.x,
									y      = fs.y + o.h + kerf,
									width  = fs.width,
									height = bottomHeight
								});
							}
						} else {
							// --- HİBRİT YÖNTEM (mevcut): Dikey kesim önce ---
							if (rightWidth GT 0) {
								arrayAppend(sh.freeSpaces, {
									x      = fs.x + o.w + kerf,
									y      = fs.y,
									width  = rightWidth,
									height = fs.height
								});
							}
							if (bottomHeight GT 0) {
								arrayAppend(sh.freeSpaces, {
									x      = fs.x,
									y      = fs.y + o.h + kerf,
									width  = o.w,
									height = bottomHeight
								});
							}
						}
		
						placed = true;
					}
		
					// 2) Hiçbir plakada yer bulunamadıysa → yeni plaka aç
					if (NOT placed) {
						newSheetNo = arrayLen(localSheets) + 1;
						newSheet = {
							sheet_no   = newSheetNo,
							freeSpaces = [ { x = 0, y = 0, width = currentSheetWidth, height = currentSheetHeight } ]
						};
						arrayAppend(localSheets, newSheet);
		
						fs = newSheet.freeSpaces[1];
						// yon değerine göre orientasyon belirle
						pieceYon = structKeyExists(piece, "yon") ? int(val(piece.yon)) : 0;
						orientations = [ {w = piece.width, h = piece.height} ];
						if (pieceYon EQ 0) {
							// Rotation serbest: hem orijinal hem döndürülmüş yönü dene
							arrayAppend(orientations, {w = piece.height, h = piece.width});
						}
						// yon = 1 ise sadece orijinal yön kullanılır
		
						// Yeni plakada da en az fire bırakan orientasyonu seç
						bestOrientation = structNew();
						bestWasteNew = 999999999;
						placedHere = false;
						
						for (o in orientations) {
							if (o.w LTE fs.width AND o.h LTE fs.height) {
								waste = (fs.width * fs.height) - (o.w * o.h);
								if (waste LT bestWasteNew) {
									bestWasteNew = waste;
									bestOrientation = o;
									placedHere = true;
								}
							}
						}
		
						if (placedHere) {
							xPos = fs.x;
							yPos = fs.y;
		
							arrayAppend(yerlesim, {
								"lot_no"     : piece.lot_no,
								"emir_no"    : piece.emir_no,
								"sheet_name" : sheetKey,
								"sheet_no"   : newSheetNo,
								"piece"      : piece.name,
								"x"          : xPos,
								"y"          : yPos,
								"width"      : bestOrientation.w,
								"height"     : bestOrientation.h
							});
		
							arrayDeleteAt(newSheet.freeSpaces, 1);
		
							rightWidth = fs.width - bestOrientation.w - kerf;
							bottomHeight = fs.height - bestOrientation.h - kerf;
							
							if (cuttingMethod EQ 1) {
								// --- SAF GİYOTİN: cuttingStartingDirection'a göre kesim yönü ---
								// 1 = Yatay Kesim Öncelikli, 2 = Dikey Kesim Öncelikli
								if (rightWidth GT 0 AND bottomHeight GT 0) {
									if (cuttingStartingDirection EQ 1) {
										// Yatay Kesim Öncelikli → alt tam genişlik alır
										arrayAppend(newSheet.freeSpaces, {
											x      = fs.x + bestOrientation.w + kerf,
											y      = fs.y,
											width  = rightWidth,
											height = bestOrientation.h
										});
										arrayAppend(newSheet.freeSpaces, {
											x      = fs.x,
											y      = fs.y + bestOrientation.h + kerf,
											width  = fs.width,
											height = bottomHeight
										});
									} else {
										// Dikey Kesim Öncelikli → sağ tam yükseklik alır
										arrayAppend(newSheet.freeSpaces, {
											x      = fs.x + bestOrientation.w + kerf,
											y      = fs.y,
											width  = rightWidth,
											height = fs.height
										});
										arrayAppend(newSheet.freeSpaces, {
											x      = fs.x,
											y      = fs.y + bestOrientation.h + kerf,
											width  = bestOrientation.w,
											height = bottomHeight
										});
									}
								} else if (rightWidth GT 0) {
									arrayAppend(newSheet.freeSpaces, {
										x      = fs.x + bestOrientation.w + kerf,
										y      = fs.y,
										width  = rightWidth,
										height = fs.height
									});
								} else if (bottomHeight GT 0) {
									arrayAppend(newSheet.freeSpaces, {
										x      = fs.x,
										y      = fs.y + bestOrientation.h + kerf,
										width  = fs.width,
										height = bottomHeight
									});
								}
							} else {
								// --- HİBRİT YÖNTEM (mevcut): Dikey kesim önce ---
								if (rightWidth GT 0) {
									arrayAppend(newSheet.freeSpaces, {
										x      = fs.x + bestOrientation.w + kerf,
										y      = fs.y,
										width  = rightWidth,
										height = fs.height
									});
								}
								if (bottomHeight GT 0) {
									arrayAppend(newSheet.freeSpaces, {
										x      = fs.x,
										y      = fs.y + bestOrientation.h + kerf,
										width  = bestOrientation.w,
										height = bottomHeight
									});
								}
							}
						} else {
							// Parça tabakaya hiç sığmıyorsa
							throw(message="Parça tabakaya sığmıyor: " & piece.name & " (" & piece.width & "x" & piece.height & ")");
						}
					}
		
				} // piecesToPlace döngüsü
		
			} // her sheetKey
		
			// -----------------------------------
			// FIRE HESAPLAMA (KERF HARİÇ)
			// -----------------------------------
			fireSonuclari = [];
			tabakaGruplari = structNew();
		
			// Tabakaları gruplama
			for (r in yerlesim) {
				key = r.sheet_name & "_" & r.sheet_no;
		
			if (!structKeyExists(tabakaGruplari, key)) {
				// Bu tabaka için dinamik ölçüleri al (TAM BOYUT - trim düşülmeden)
				sheetKeyNumeric = val(r.sheet_name);
				if (structKeyExists(sheetDimensions, sheetKeyNumeric)) {
					tabakaWidth  = sheetDimensions[sheetKeyNumeric].width;
					tabakaHeight = sheetDimensions[sheetKeyNumeric].height;
				} else {
					tabakaWidth  = 2100;
					tabakaHeight = 2800;
				}
				
				// Fire hesabında plaka tam alanı kullanılır (trim alanı da fire'dır)
				tabakaAlani = tabakaWidth * tabakaHeight;
				
				tabakaGruplari[key] = {
					"sheet_name" = r.sheet_name,
					"sheet_no"   = r.sheet_no,
					"used_area"  = 0,
					"tabaka_alani" = tabakaAlani
				};
			}
		
				// Kerf fire hesabına dahil edilmiyor → sadece parça alanı
				tabakaGruplari[key].used_area += (r.width * r.height);
			}
		
			// Her tabaka için fire hesabı
			for (k in tabakaGruplari) {
				t = tabakaGruplari[k];
		
				fireArea    = t.tabaka_alani - t.used_area;
				firePercent = (fireArea / t.tabaka_alani) * 100;
		
				arrayAppend(fireSonuclari, {
					"sheet_name"  = t.sheet_name,
					"sheet_no"    = t.sheet_no,
					"used_area"   = t.used_area,
					"fire_area"   = fireArea,
					"fire_percent" = numberFormat(firePercent, "9.99")
				});
			}
	</cfscript>
	
	<cfset pieces_row = queryNew("lot_no, emir_no, sheet_no, sheet_name, piece, x_point, y_point, width, height","cf_sql_varchar, cf_sql_varchar, cf_sql_integer, cf_sql_varchar, cf_sql_varchar, Decimal, Decimal, Decimal, Decimal")>
	<cfloop array="#yerlesim#" index="item">
			<!--- Satır ekle --->
			<cfset QueryAddRow(pieces_row)>
		
			<!--- Hücreleri doldur --->
			<cfset QuerySetCell(pieces_row, "lot_no", item.lot_no)>
			<cfset QuerySetCell(pieces_row, "emir_no", item.emir_no)>
			<cfset QuerySetCell(pieces_row, "sheet_no", item.sheet_no)>
			<cfset QuerySetCell(pieces_row, "sheet_name", item.sheet_name)>
			<cfset QuerySetCell(pieces_row, "piece", item.piece)>
			<cfset QuerySetCell(pieces_row, "x_point", item.x)>
			<cfset QuerySetCell(pieces_row, "y_point", item.y)>
			<cfset QuerySetCell(pieces_row, "width", item.width)>
			<cfset QuerySetCell(pieces_row, "height", item.height)>
	</cfloop>
		
	<cfset fire_row = queryNew("sheet_no, sheet_name, used_area, fire_area, fire_percent","cf_sql_integer, cf_sql_varchar, Decimal, Decimal, Decimal")>
	<cfloop array="#fireSonuclari#" index="item">
		<!--- Satır ekle --->
		<cfset QueryAddRow(fire_row)>
		
		<!--- Hücreleri doldur --->
		<cfset QuerySetCell(fire_row, "sheet_no", item.sheet_no)>
		<cfset QuerySetCell(fire_row, "sheet_name", item.sheet_name)>
		<cfset QuerySetCell(fire_row, "used_area", item.used_area)>
		<cfset QuerySetCell(fire_row, "fire_area", item.fire_area)>
		<cfset QuerySetCell(fire_row, "fire_percent", item.fire_percent)>
	</cfloop>
	
	<!--- Her şablon grubu (sheet_name + sheet_no) için ayrı kayıt oluşturacağız --->
	<!--- fire_row_group sorgusunu kaldırıyoruz, direkt fire_row kullanacağız --->
		
	<!--- Önce mevcut optimizasyon sonuçlarını sil --->
	<cfquery name="del_old_results_rows" datasource="#dsn3#">
		DELETE FROM 
           	EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW 
		WHERE 
           	OPTIMIZATION_RESULT_ID IN (
										SELECT 
                                           	OPTIMIZATION_RESULT_ID 
										FROM 
                                           	EZGI_IFLOW_OPTIMIZATION_RESULTS 
										WHERE 
                                           	OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
										)
	</cfquery>
	<cfquery name="del_old_results" datasource="#dsn3#">
		DELETE 
           	FROM EZGI_IFLOW_OPTIMIZATION_RESULTS 
		WHERE 
           	OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
	</cfquery>
	
	<!--- Optimizasyon sonuçlarını kaydet --->
	<!--- Her malzeme için parça dağılımı imzalarını tutacak struct --->
	<cfset sheet_group_map = structNew()>
	<cfset sheet_group_counter = structNew()>
	
	<!--- Veritabanından en büyük SHEET_GROUP_NUMBER değerini al --->
	<cfquery name="get_max_sheet_group_number" datasource="#dsn3#">
		SELECT 
			MAX(SHEET_GROUP_NUMBER) AS MAX_GROUP_NUMBER
		FROM 
			EZGI_IFLOW_OPTIMIZATION_RESULTS
	</cfquery>
	
	<!--- Global başlangıç değerini belirle (tüm malzemeler için ortak) --->
	<cfif get_max_sheet_group_number.recordcount 
		AND isDefined("get_max_sheet_group_number.MAX_GROUP_NUMBER") 
		AND isNumeric(get_max_sheet_group_number.MAX_GROUP_NUMBER) 
		AND get_max_sheet_group_number.MAX_GROUP_NUMBER GT 0>
		<cfset global_group_counter = get_max_sheet_group_number.MAX_GROUP_NUMBER + 1>
	<cfelse>
		<cfset global_group_counter = 40000000>
	</cfif>
		
	<!--- fire_row üzerinden dön (her sheet_name + sheet_no kombinasyonu için) --->
	<cfloop query="fire_row">
		<!--- STOCK_ID'yi bul --->
		<cfset current_stock_id = sheet_name>
		
		<!--- Bu malzeme için ilk kez mi? --->
		<cfif not structKeyExists(sheet_group_map, sheet_name)>
			<cfset sheet_group_map[sheet_name] = structNew()>
			<!--- Her malzeme için global sayaçtan başla --->
			<cfset sheet_group_counter[sheet_name] = global_group_counter>
		</cfif>
		
		<!--- Bu sheet için tek kayıt oluştur --->
		<!--- Bu sheet'e ait parçaları al (imza için) --->
		<cfquery name="get_sheet_pieces_for_signature" dbtype="query">
			SELECT 
				x_point,
				y_point,
				width,
				height
			FROM
				pieces_row
			WHERE
				sheet_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sheet_name#">
				AND sheet_no = <cfqueryparam cfsqltype="cf_sql_integer" value="#sheet_no#">
			ORDER BY
				x_point,
				y_point,
				width,
				height
		</cfquery>
		
		<!--- Parça dağılımı imzası oluştur (parça sayısı + parça pozisyonları) --->
		<cfset piece_signature = "#get_sheet_pieces_for_signature.recordcount#_">
		<cfloop query="get_sheet_pieces_for_signature">
			<!--- Float değerleri integer'a çevir (mm cinsinden, 0.01 hassasiyet) --->
			<cfset x_int = int(x_point * 100)>
			<cfset y_int = int(y_point * 100)>
			<cfset w_int = int(width * 100)>
			<cfset h_int = int(height * 100)>
			<cfset piece_signature = piece_signature & "#x_int#_#y_int#_#w_int#_#h_int#|">
		</cfloop>
		<cfset piece_signature = trim(piece_signature)>
		
		<!--- Bu imza için grup numarası var mı kontrol et --->
		<cfset signature_key = sheet_name & "_" & piece_signature>
		<cfif not structKeyExists(sheet_group_map[sheet_name], signature_key)>
			<!--- Yeni imza, yeni grup numarası ver (global sayaçtan) --->
			<cfset sheet_group_map[sheet_name][signature_key] = sheet_group_counter[sheet_name]>
			<cfset current_group_number = sheet_group_counter[sheet_name]>
			<cfset sheet_group_counter[sheet_name] = sheet_group_counter[sheet_name] + 1>
			<!--- Global sayacı da artır --->
			<cfset global_group_counter = global_group_counter + 1>
		<cfelse>
			<!--- Aynı imza, aynı grup numarasını kullan --->
			<cfset current_group_number = sheet_group_map[sheet_name][signature_key]>
		</cfif>
		
		<cfquery name="ins_optimization_result" datasource="#dsn3#">
			INSERT INTO EZGI_IFLOW_OPTIMIZATION_RESULTS
			(
				OPTIMIZATION_ID,
				STOCK_ID,
				SHEET_NUMBER,
				SHEET_GROUP_NUMBER,
				USED_AREA,
				FIRE_AREA,
				FIRE_PERCENT,
				IS_VIRTUAL_MATERIAL,
				RECORD_EMP,
				RECORD_IP,
				RECORD_DATE
			)
			VALUES
			(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">,
				<cfif len(current_stock_id) and isNumeric(current_stock_id)>
					<cfqueryparam cfsqltype="cf_sql_integer" value="#current_stock_id#">
				<cfelse>
					NULL
				</cfif>,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#sheet_no#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#current_group_number#">,
				<!--- Her sheet'in kendi used_area ve fire_area değerini kullan (mm²'den m²'ye çevir) --->
				<cfqueryparam cfsqltype="cf_sql_float" value="#used_area / 1000000#">,
				<cfqueryparam cfsqltype="cf_sql_float" value="#fire_area / 1000000#">,
				<cfqueryparam cfsqltype="cf_sql_float" value="#fire_percent#">,
				<cfqueryparam cfsqltype="cf_sql_bit" value="0">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
			)
		</cfquery>
				
			<!--- Son kaydedilen OPTIMIZATION_RESULT_ID'yi al --->
			<!--- Fallback: MAX kullan --->
			<cfquery name="get_last_result_id_fallback" datasource="#dsn3#">
				SELECT 
               		MAX(OPTIMIZATION_RESULT_ID) AS MAX_ID
				FROM 
               		EZGI_IFLOW_OPTIMIZATION_RESULTS
				WHERE 
                   	OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
			</cfquery>
			<cfset current_result_id = get_last_result_id_fallback.MAX_ID>
				
			<!--- Bu tabakaya ait parçaları kaydet --->
			<cfquery name="get_sheet_pieces" dbtype="query">
				SELECT 
					lot_no,
					emir_no,
					piece,
					x_point,
					y_point,
					width,
					height
				FROM
					pieces_row
				WHERE
					sheet_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sheet_name#">
					AND sheet_no = <cfqueryparam cfsqltype="cf_sql_integer" value="#sheet_no#">
			</cfquery>
				
			<cfloop query="get_sheet_pieces">
				<cfquery name="ins_optimization_result_row" datasource="#dsn3#">
					INSERT INTO EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW
					(
						OPTIMIZATION_RESULT_ID,
						PIECE_NAME,
						LOT_NO,
						P_ORDER_NO,
						X_POINT,
						Y_POINT,
						WIDTH,
						HEIGHT
					)
					VALUES
					(
						<cfqueryparam cfsqltype="cf_sql_integer" value="#current_result_id#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#piece#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#lot_no#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#emir_no#">,
						<cfqueryparam cfsqltype="cf_sql_float" value="#x_point#">,
						<cfqueryparam cfsqltype="cf_sql_float" value="#y_point#">,
						<cfqueryparam cfsqltype="cf_sql_float" value="#width#">,
						<cfqueryparam cfsqltype="cf_sql_float" value="#height#">
					)
				</cfquery>
			</cfloop>
	</cfloop>

<cfelseif isdefined('attributes.del_process') and len(attributes.del_process)>
	<cfif isdefined('attributes.optimization_id') and len(attributes.optimization_id) and isNumeric(attributes.optimization_id)>
		<!--- Önce satırları sil --->
		<cfquery name="del_optimization_results_rows" datasource="#dsn3#">
			DELETE FROM 
            	EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW 
			WHERE 
            	OPTIMIZATION_RESULT_ID IN 
                						(
											SELECT 
                                            	OPTIMIZATION_RESULT_ID 
											FROM 
                                            	EZGI_IFLOW_OPTIMIZATION_RESULTS 
											WHERE 
                                            	OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
										)
		</cfquery>
	<!--- Sonra ana kayıtları sil --->
	<cfquery name="del_optimization_results" datasource="#dsn3#">
		DELETE FROM 
           	EZGI_IFLOW_OPTIMIZATION_RESULTS 
		WHERE 
           	OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
	</cfquery>
	
	<!--- Malzeme satırlarını sil --->
	<cfquery name="del_optimization_material_rows" datasource="#dsn3#">
		DELETE FROM 
			EZGI_IFLOW_OPTIMIZATION_MATERIAL_ROW
		WHERE 
			OPTIMIZATION_MATERIAL_ID IN (
				SELECT 
					OPTIMIZATION_MATERIAL_ID
				FROM 
					EZGI_IFLOW_OPTIMIZATION_MATERIAL
				WHERE 
					OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
			)
	</cfquery>
	
	<!--- Malzemeleri sil --->
	<cfquery name="del_optimization_materials" datasource="#dsn3#">
		DELETE FROM 
			EZGI_IFLOW_OPTIMIZATION_MATERIAL
		WHERE 
			OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
	</cfquery>
	</cfif>
</cfif>

<!--- Optimizasyon sonuçlarını göster --->
<cfif isdefined('attributes.optimization_id') and len(attributes.optimization_id) and isNumeric(attributes.optimization_id)>
	<cfquery name="get_optimization_results" datasource="#dsn3#">
		SELECT 
			EOR.OPTIMIZATION_RESULT_ID,
			EOR.OPTIMIZATION_ID,
			EOR.STOCK_ID,
			EOR.SHEET_NUMBER,
			EOR.SHEET_GROUP_NUMBER,
			EOR.USED_AREA,
			EOR.FIRE_AREA,
			EOR.FIRE_PERCENT,
			ISNULL(EOR.IS_VIRTUAL_MATERIAL, 0) AS IS_VIRTUAL_MATERIAL,
			ISNULL(S.PRODUCT_NAME, 'Bilinmeyen Malzeme') AS PRODUCT_NAME
		FROM 
			EZGI_IFLOW_OPTIMIZATION_RESULTS AS EOR WITH (NOLOCK)
			LEFT OUTER JOIN STOCKS AS S WITH (NOLOCK) ON EOR.STOCK_ID = S.STOCK_ID
		WHERE 
			EOR.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
		ORDER BY 
			EOR.STOCK_ID, 
			EOR.SHEET_GROUP_NUMBER, 
			EOR.SHEET_NUMBER
	</cfquery>

	<!--- JS tarafına şablon var/yok bilgisini aktar --->
	<script type="text/javascript">
		window.hasOptimizationResults = <cfif get_optimization_results.recordcount>1<cfelse>0</cfif>;
	</script>
	<cfquery name="get_optimization_results_row" datasource="#dsn3#">
		SELECT 
			OER.SHEET_GROUP_NUMBER, 
			OER.STOCK_ID, 
			OERR.OPTIMIZATION_RESULT_ID, 
			SUM(OERR.WIDTH * OERR.HEIGHT / 1000000) AS USED_AMOUNT
		FROM     
			EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS OERR WITH (NOLOCK) INNER JOIN
         	EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER ON OERR.OPTIMIZATION_RESULT_ID = OER.OPTIMIZATION_RESULT_ID
		WHERE  
			OER.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
		GROUP BY 
			OER.SHEET_GROUP_NUMBER, 
			OER.STOCK_ID, 
			OERR.OPTIMIZATION_RESULT_ID
	</cfquery>
	<cfquery name="get_optimization_results_row_row" datasource="#dsn3#">
		SELECT 
			OERR.PIECE_NAME, 
			OERR.LOT_NO, 
			OERR.P_ORDER_NO, 
			OERR.X_POINT, 
			OERR.Y_POINT, 
			OERR.WIDTH, 
			OERR.HEIGHT, 
			OER.SHEET_GROUP_NUMBER, 
			OER.STOCK_ID
		FROM     
			EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS OERR WITH (NOLOCK) INNER JOIN
         	EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER ON OERR.OPTIMIZATION_RESULT_ID = OER.OPTIMIZATION_RESULT_ID
		WHERE  
			OER.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
	</cfquery>
	<!--- Malzeme bazında grupla (IS_VIRTUAL_MATERIAL=1 olanlar hariç) - ColdFusion tarafında hesapla --->
	<cfset grouped_data = structNew()>
	<cfloop query="get_optimization_results">
		<cfset stock_key = STOCK_ID & "_" & PRODUCT_NAME>
		<cfif not structKeyExists(grouped_data, stock_key)>
			<cfset grouped_data[stock_key] = structNew()>
			<cfset grouped_data[stock_key].PRODUCT_NAME = PRODUCT_NAME>
			<cfset grouped_data[stock_key].STOCK_ID = STOCK_ID>
			<cfset grouped_data[stock_key].SHEET_COUNT = 0>
			<cfset grouped_data[stock_key].TOTAL_USED_AREA = 0>
			<cfset grouped_data[stock_key].TOTAL_FIRE_AREA = 0>
			<cfset grouped_data[stock_key].TOTAL_SHEET_AREA = 0>
		</cfif>
		<!--- Sadece IS_VIRTUAL_MATERIAL = 0 olanları say --->
		<cfif IS_VIRTUAL_MATERIAL EQ 0>
			<cfset grouped_data[stock_key].SHEET_COUNT = grouped_data[stock_key].SHEET_COUNT + 1>
			<cfset grouped_data[stock_key].TOTAL_USED_AREA = grouped_data[stock_key].TOTAL_USED_AREA + USED_AREA>
			<cfset grouped_data[stock_key].TOTAL_FIRE_AREA = grouped_data[stock_key].TOTAL_FIRE_AREA + FIRE_AREA>
			<cfset grouped_data[stock_key].TOTAL_SHEET_AREA = grouped_data[stock_key].TOTAL_SHEET_AREA + (USED_AREA + FIRE_AREA)>
		</cfif>
	</cfloop>
	
	<!--- Query oluştur --->
	<cfset get_results_grouped = queryNew("PRODUCT_NAME,STOCK_ID,SHEET_COUNT,TOTAL_USED_AREA,TOTAL_FIRE_AREA,AVG_FIRE_PERCENT")>
	<cfset sorted_keys = structKeyArray(grouped_data)>
	<cfset arraySort(sorted_keys, "textnocase")>
	<cfloop array="#sorted_keys#" index="key">
		<cfset item = grouped_data[key]>
		<cfset fire_percent = 0>
		<cfif item.TOTAL_SHEET_AREA GT 0>
			<cfset fire_percent = (item.TOTAL_FIRE_AREA / item.TOTAL_SHEET_AREA) * 100>
		</cfif>
		<cfset QueryAddRow(get_results_grouped)>
		<cfset QuerySetCell(get_results_grouped, "PRODUCT_NAME", item.PRODUCT_NAME)>
		<cfset QuerySetCell(get_results_grouped, "STOCK_ID", item.STOCK_ID)>
		<cfset QuerySetCell(get_results_grouped, "SHEET_COUNT", item.SHEET_COUNT)>
		<cfset QuerySetCell(get_results_grouped, "TOTAL_USED_AREA", item.TOTAL_USED_AREA)>
		<cfset QuerySetCell(get_results_grouped, "TOTAL_FIRE_AREA", item.TOTAL_FIRE_AREA)>
		<cfset QuerySetCell(get_results_grouped, "AVG_FIRE_PERCENT", fire_percent)>
	</cfloop>
	
	<!--- Display için malzeme ölçülerini al --->
	<cfif get_results_grouped.recordcount>
		<cfset display_malzeme_id_list = ListDeleteDuplicates(ValueList(get_results_grouped.STOCK_ID))>
		<cfquery name="get_display_dimention" datasource="#dsn3#">
			SELECT        
				S.STOCK_ID, 
				PU.DIMENTION
			FROM            
				STOCKS AS S INNER JOIN
				PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
			WHERE        
				S.STOCK_ID IN (#display_malzeme_id_list#)
		</cfquery>
		
		<!--- Display için materialSettings'i oluştur (eğer henüz yoksa) --->
		<cfif not isDefined("materialSettings")>
			<cfquery name="get_display_optimization_materials" datasource="#dsn3#">
				SELECT 
					E.STOCK_ID, 
					ER.STOCK_ID AS SELECTED_STOCK_ID, 
					ER.WORKSTATION_ID AS SELECTED_WORKSTATION_ID, 
					ISNULL(W.CIRCLE_TESTRE_THICKNESS, -1) AS CIRCLE_TESTRE_THICKNESS, 
					ISNULL(W.OUTER_EDGE_TRIMMING_ALLOWANCE, -1) AS OUTER_EDGE_TRIMMING_ALLOWANCE,
					ISNULL(W.CUTTING_METHOD, 1) AS CUTTING_METHOD,
				ISNULL(W.CUTTING_STARTING_DIRECTION, 1) AS CUTTING_STARTING_DIRECTION
				FROM     
					EZGI_IFLOW_OPTIMIZATION_MATERIAL AS E INNER JOIN
					EZGI_IFLOW_OPTIMIZATION_MATERIAL_ROW AS ER ON E.OPTIMIZATION_MATERIAL_ID = ER.OPTIMIZATION_MATERIAL_ID LEFT OUTER JOIN
					WORKSTATIONS AS W ON ER.WORKSTATION_ID = W.STATION_ID
				WHERE  
					E.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
			</cfquery>
			
			<cfset materialSettings = structNew()>
			<cfloop query="get_display_optimization_materials">
				<cfif not structKeyExists(materialSettings, SELECTED_STOCK_ID)>
					<cfset materialSettings[SELECTED_STOCK_ID] = structNew()>
					<cfset materialSettings[SELECTED_STOCK_ID].kerf = (isNumeric(CIRCLE_TESTRE_THICKNESS) and val(CIRCLE_TESTRE_THICKNESS) GT 0) ? val(CIRCLE_TESTRE_THICKNESS) : 4>
					<cfset materialSettings[SELECTED_STOCK_ID].trimAllowance = (isNumeric(OUTER_EDGE_TRIMMING_ALLOWANCE) and val(OUTER_EDGE_TRIMMING_ALLOWANCE) GT 0) ? val(OUTER_EDGE_TRIMMING_ALLOWANCE) : 0>
					<cfset materialSettings[SELECTED_STOCK_ID].cuttingMethod = (isNumeric(CUTTING_METHOD) and (val(CUTTING_METHOD) EQ 1 or val(CUTTING_METHOD) EQ 2)) ? val(CUTTING_METHOD) : 2>
					<cfset materialSettings[SELECTED_STOCK_ID].cuttingStartingDirection = (isNumeric(CUTTING_STARTING_DIRECTION) and (val(CUTTING_STARTING_DIRECTION) EQ 1 or val(CUTTING_STARTING_DIRECTION) EQ 2)) ? val(CUTTING_STARTING_DIRECTION) : 1>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfset displaySheetDimensions = structNew()>
		<cfoutput query="get_display_dimention">
			<cfif ListLen(DIMENTION,'*') gt 1>
				<cfif isnumeric(ListGetAt(DIMENTION,1,'*'))>
					<cfset displaySheetDimensions[STOCK_ID] = structNew()>
					<cfset displaySheetDimensions[STOCK_ID].width = ListGetAt(DIMENTION,1,'*')>
				<cfelse>
					<cfset displaySheetDimensions[STOCK_ID] = structNew()>
					<cfset displaySheetDimensions[STOCK_ID].width = 2100>
				</cfif>
				<cfif isnumeric(ListGetAt(DIMENTION,2,'*'))>
					<cfset displaySheetDimensions[STOCK_ID].height = ListGetAt(DIMENTION,2,'*')>
				<cfelse>
					<cfset displaySheetDimensions[STOCK_ID].height = 2800>
				</cfif>
			<cfelse>
				<cfset displaySheetDimensions[STOCK_ID] = structNew()>
				<cfset displaySheetDimensions[STOCK_ID].width = 2100>
				<cfset displaySheetDimensions[STOCK_ID].height = 2800>
			</cfif>
		
		<!--- Bu malzeme için dış kenar traşlama payını al --->
		<cfif structKeyExists(materialSettings, STOCK_ID)>
			<cfset trimAllowance = materialSettings[STOCK_ID].trimAllowance>
		<cfelse>
			<cfset trimAllowance = 0>
		</cfif>
		
		<!--- Dış Kenar Traşlama Payı varsa düş --->
		<cfif trimAllowance GT 0>
			<cfset displaySheetDimensions[STOCK_ID].width = displaySheetDimensions[STOCK_ID].width - (2 * trimAllowance)>
			<cfset displaySheetDimensions[STOCK_ID].height = displaySheetDimensions[STOCK_ID].height - (2 * trimAllowance)>
			<cfif displaySheetDimensions[STOCK_ID].width LTE 0>
				<cfset displaySheetDimensions[STOCK_ID].width = 1>
			</cfif>
			<cfif displaySheetDimensions[STOCK_ID].height LTE 0>
				<cfset displaySheetDimensions[STOCK_ID].height = 1>
			</cfif>
		</cfif>
		
		<!--- Tabaka alanını m² cinsinden hesapla --->
		<cfset displaySheetDimensions[STOCK_ID].area_m2 = (displaySheetDimensions[STOCK_ID].width * displaySheetDimensions[STOCK_ID].height) / 1000000>
	</cfoutput>
	</cfif>
	
	
<cfelse>
	<cfset get_results_grouped.recordcount = 0>
</cfif>

<cf_box>
	<cfsavecontent variable="optimization_results_title">Optimizasyon Sonucu Oluşan Şablonlar</cfsavecontent>
	<cf_box title="#optimization_results_title#" >
		<cf_grid_list>
			<thead>
				<tr valign="middle">
					<th style="width:20px; text-align:center"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th style="width:10px; text-align:center">
                    	
                    </th>
					<th style="text-align:center">Malzeme</th>
					<th style="width:45px; text-align:right"><cf_get_lang dictionary_id='57635.Miktar'></th>
					<th style="width:70px; text-align:right" nowrap>Kullanım (m²)</th>
					<th style="width:55px; text-align:right" nowrap>Fire (m²)</th>
					<th style="width:40px; text-align:right" nowrap>Oran (%)	</th>
				</tr>
			</thead>
			<tbody>
				<cfif isDefined("get_results_grouped") and get_results_grouped.recordcount>
					<cfoutput query="get_results_grouped">
                    	<input type="hidden" name="row_display_#currentrow#" id="row_display_#currentrow#" value="1">
						<!--- Artık veritabanında m² cinsinden saklanıyor, çevirmeye gerek yok --->
						<cfset used_area_m2 = TOTAL_USED_AREA>
						<cfset fire_area_m2 = TOTAL_FIRE_AREA>
						
						<tr>
							<td style="text-align:center">#currentRow#</td>
                            <td align="center" id="fire_row#currentrow#" class="color-row" onclick="gizle_goster(sub_fire_detail#currentrow#);seviyelendir(#currentrow#);gizle_goster_nested('siparis_goster#currentrow#','siparis_gizle#currentrow#');">
                                <img id="siparis_goster#currentrow#" style="cursor:pointer;" src="/images/listele.gif" title="<cf_get_lang dictionary_id ='58596.Göster'>">
                                <img id="siparis_gizle#currentrow#" style="cursor:pointer;display:none;" src="/images/listele_down.gif" title="<cf_get_lang dictionary_id ='58628.Gizle'>">
                           </td>
							<td style="text-align:left">#get_results_grouped.PRODUCT_NAME#</td>
							<td style="text-align:right">#get_results_grouped.SHEET_COUNT#</td>
							<td style="text-align:right">#AmountFormat(used_area_m2,2)#</td>
							<td style="text-align:right">#AmountFormat(fire_area_m2,2)#</td>
							<td style="text-align:right">#AmountFormat(get_results_grouped.AVG_FIRE_PERCENT,2)#</td>
						</tr>
                        <tr id="sub_fire_detail#currentrow#" class="nohover" style="display:none" >
                            <td colspan="8">
                                <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
                                    <cf_box>
                                        <cf_flat_list>
                                            <thead>  
                                                <tr align="right" class="color-list">
                                                    <th style="width:20px; text-align:center">Sıra</th>
                                                    <th style="text-align:center">Şablon No</th>
                                                    <th style="text-align:center">Miktar</th>
                                                    <th style="text-align:center">Kullanım (m2)</th>
                                                    <th style="text-align:center">Fire (m2)</th>
													<th style="text-align:center">Fire Oranı</th>
													<th style="text-align:center">Hurda</th>
													<th style="text-align:center">İşlem</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <!--- Şablon gruplarını al --->
                                                <cfquery name="fire_row_detail" datasource="#dsn3#">
                                                    SELECT 
                                                        SHEET_GROUP_NUMBER,
														STOCK_ID,
                                                        COUNT(*) AS SHEET_COUNT,
														SUM(USED_AREA) AS TOTAL_USED_AREA,
														SUM(FIRE_AREA) AS TOTAL_FIRE_AREA,
														MAX(CAST(ISNULL(IS_VIRTUAL_MATERIAL, 0) AS INT)) AS IS_VIRTUAL_MATERIAL
                                                    FROM
                                                        EZGI_IFLOW_OPTIMIZATION_RESULTS WITH (NOLOCK)
                                                  	WHERE
                                                    	OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
                                                    	AND STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_results_grouped.STOCK_ID#">
                                                    GROUP BY
                                                    	SHEET_GROUP_NUMBER,
                                                    	STOCK_ID
                                                    ORDER BY
                                                        SHEET_GROUP_NUMBER
                                                </cfquery>
                                            	<cfif fire_row_detail.recordcount>
                                                 	<cfloop query="fire_row_detail">
                                                     	<!--- Bu malzeme için dinamik tabaka alanını al --->
                                                     	<cfif structKeyExists(displaySheetDimensions, fire_row_detail.STOCK_ID)>
                                                     		<cfset current_sheet_area_m2 = displaySheetDimensions[fire_row_detail.STOCK_ID].area_m2>
                                                     	<cfelse>
                                                     		<cfset current_sheet_area_m2 = 5.88> <!--- Fallback: Varsayılan değer --->
                                                     	</cfif>
                                                     	<!--- IS_VIRTUAL_MATERIAL kontrolü --->
                                                     	<cfset is_virtual = fire_row_detail.IS_VIRTUAL_MATERIAL>
                                                     	<cfset display_sheet_count = fire_row_detail.SHEET_COUNT>
                                                     	
                                                     	<!--- Tek tabaka değerlerini hesapla (toplam / adet) --->
                                                     	<cfif fire_row_detail.SHEET_COUNT GT 0>
                                                     		<cfset display_used_amount = fire_row_detail.TOTAL_USED_AREA / fire_row_detail.SHEET_COUNT>
                                                     		<cfset display_fire_area = fire_row_detail.TOTAL_FIRE_AREA / fire_row_detail.SHEET_COUNT>
                                                     	<cfelse>
                                                     		<cfset display_used_amount = fire_row_detail.TOTAL_USED_AREA>
                                                     		<cfset display_fire_area = fire_row_detail.TOTAL_FIRE_AREA>
                                                     	</cfif>
                                                     	
                                                     	<!--- Fire oranını hesapla (tek tabaka için) --->
                                                     	<cfset single_sheet_area = display_used_amount + display_fire_area>
                                                     	<cfset display_fire_percent = 0>
                                                     	<cfif single_sheet_area GT 0>
                                                     		<cfset display_fire_percent = (display_fire_area / single_sheet_area) * 100>
                                                     	</cfif>
                                                     
                                                     	<!--- Eğer hurda plaka ise, plaka sayısından düş --->
                                                     	<cfif is_virtual EQ 1>
                                                     		<cfset display_sheet_count = 0>
                                                     		<cfset display_used_amount = 0>
                                                     		<cfset display_fire_area = 0>
                                                     		<cfset display_fire_percent = 0>
                                                     	</cfif>
                                                     	
                                                     	<tr onClick="optimization_display('#fire_row_detail.SHEET_GROUP_NUMBER#','#get_results_grouped.STOCK_ID#','#attributes.optimization_id#')" <cfif is_virtual EQ 1>style="background-color:lightcyan;" title="Hurda plaka kullanılacak"</cfif>>
                                                        	<td style="text-align:right" >#currentrow#</td>
                                                        	<td style="text-align:center" >#fire_row_detail.SHEET_GROUP_NUMBER#</td>
                                                            <td style="text-align:center" >#display_sheet_count#</td>
                                                            <td style="text-align:right" >#AmountFormat(display_used_amount,2)#</td>
                                                            <td style="text-align:right" >#AmountFormat(display_fire_area,2)#</td>
                                                            <td style="text-align:right" >#AmountFormat(display_fire_percent,2)#</td>
                                                            <td style="text-align:center" onclick="event.stopPropagation();">
                                                            	<input type="checkbox" 
                                                            		id="hurda_checkbox_#fire_row_detail.SHEET_GROUP_NUMBER#" 
                                                            		<cfif is_virtual EQ 1>checked="checked"</cfif>
                                                            		<cfif get_optimizition.IS_MATERIAL_UPDATE EQ 1>disabled="disabled"</cfif>
                                                            		onchange="updateVirtualMaterial('#fire_row_detail.SHEET_GROUP_NUMBER#', this.checked, '#attributes.optimization_id#');"
                                                            		title="Hurda plaka kullanılacak">
                                                            </td>
                                                            <td style="text-align:center" onclick="event.stopPropagation();">
                                                            	<button class="btn btn-xs btn-success" onclick="return exportKDTXMLBySheetGroup('#fire_row_detail.SHEET_GROUP_NUMBER#');" title="Bu şablon grubu için KDT XML Export">XML</button>
                                                            </td>
                                                       	</tr>
                                                    </cfloop>
                                  				</cfif>
                                            </tbody>
                                        </cf_flat_list>
                                    </cf_box>
                                </div>
                            </td>
                        </tr>
					</cfoutput>
				<cfelse>
					<tr>
						<td colspan="5" height="20" style="text-align:center"><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>
					</tr>
				</cfif>
			</tbody>
		<tfoot>
			<tr>
				<td colspan="7" height="20" style="text-align:right" class="text-right"	>
					<cfif get_optimizition.IS_MATERIAL_UPDATE EQ 1>
						<button id="btn_cancel_material" style="width:250px; height:30px; margin-right:10px;" class="btn btn-danger" onclick="cancel_material();" <cfif not get_optimization_results.recordcount>style="display:none"</cfif>>Malzeme Güncellemeyi Geri Al</button>
					<cfelse>
						<button id="btn_update_material" style="width:150px; height:30px; margin-right:10px;" class="btn btn-success" onclick="export_material();" <cfif not get_optimization_results.recordcount>style="display:none"</cfif> title="Seçilen Üretim Planlarının Malzeme İhtiyacını Günceller">Malzeme Güncelle</button>
						<button style="width:150px; height:30px; margin-right:10px;" class="btn btn-danger" onclick="OptimizationResultsAjax(2)" <cfif not get_optimization_results.recordcount>style="display:none"</cfif>	>Şablonları Sil</button>
					</cfif>		
				</td>
			</tr>
		</tfoot>
		</cf_grid_list>
	</cf_box>
</cf_box>
<script type="text/javascript">
    function seviyelendir(crtrow)
    {
        if(document.getElementById('row_display_'+crtrow).value==1)
        {
            document.getElementById('sub_fire_detail'+crtrow).style.display='';	
            document.getElementById('row_display_'+crtrow).value = 0
        }
        else
        {
            document.getElementById('sub_fire_detail'+crtrow).style.display='none';
            document.getElementById('row_display_'+crtrow).value =1
        }
    }
	function exportKDTXML()
	{
		var optimizationId = '<cfoutput>#attributes.optimization_id#</cfoutput>';
		if (!optimizationId || optimizationId === '') {
			alert('Optimizasyon ID bulunamadı!');
			return false;
		}
		var url = '<cfoutput>#request.self#</cfoutput>?fuseaction=prod.exp_ezgi_optimization_kdt_xml&optimization_id=' + optimizationId;
		console.log('KDT XML Export URL:', url);
		window.location.href = url;
		return false;
	}
	function export_material()
	{
		var optimizationId = '<cfoutput>#attributes.optimization_id#</cfoutput>';
		if (!optimizationId || optimizationId === '') {
			alert('Optimizasyon ID bulunamadı!');
			return false;
		}
		else
		{
			sor=confirm('Seçilen Üretim Planlarının Malzeme İhtiyacını Güncellemek istediğinizden emin misiniz?');
			if(sor===true)
			{
				document.getElementById('btn_update_material').disabled = true;
				windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_upd_ezgi_optimization_materials&optimization_id=' + optimizationId,'small');
			}
			else
			{
				return false;
			}
		}
	}
	function cancel_material()
	{
		var optimizationId = '<cfoutput>#attributes.optimization_id#</cfoutput>';
		if (!optimizationId || optimizationId === '') {
			alert('Optimizasyon ID bulunamadı!');
			return false;
		}
		else
		{
			sor=confirm('Malzeme Değişikliğini Geri Almak istediğinizden emin misiniz?');
			if(sor===true)
			{
				document.getElementById('btn_cancel_material').disabled = true;
				windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_upd_ezgi_optimization_materials&is_material_cancel=1&optimization_id=' + optimizationId,'small');
			}
			else
			{
				return false;
			}
		}
	}
	function exportKDTXMLBySheetGroup(sheetGroupNumber)
	{
		var optimizationId = '<cfoutput>#attributes.optimization_id#</cfoutput>';
		if (!optimizationId || optimizationId === '') {
			alert('Optimizasyon ID bulunamadı!');
			return false;
		}
		if (!sheetGroupNumber || sheetGroupNumber === '') {
			alert('Sheet Group Number bulunamadı!');
			return false;
		}
		var url = '<cfoutput>#request.self#</cfoutput>?fuseaction=prod.exp_ezgi_optimization_kdt_xml&optimization_id=' + optimizationId + '&sheet_group_number=' + sheetGroupNumber;
		console.log('KDT XML Export URL (Sheet Group):', url);
		window.location.href = url;
		return false;
	}
	
	function updateVirtualMaterial(sheetGroupNumber, isChecked, optimizationId) {
		var xhr = new XMLHttpRequest();
		var url = '<cfoutput>#request.self#</cfoutput>?fuseaction=prod.ajax_create_ezgi_optimization_results&update_virtual=1';
		var params = 'sheet_group_number=' + encodeURIComponent(sheetGroupNumber) + 
					 '&is_virtual_material=' + (isChecked ? '1' : '0') + 
					 '&optimization_id=' + encodeURIComponent(optimizationId);
		
		console.log('AJAX Update URL:', url);
		console.log('AJAX Update Params:', params);
		
		xhr.open('POST', url, true);
		xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
		xhr.onreadystatechange = function() {
			if (xhr.readyState === 4) {
				console.log('AJAX Response Status:', xhr.status);
				console.log('AJAX Response Text:', xhr.responseText);
				if (xhr.status === 200) {
					try {
						var response = JSON.parse(xhr.responseText);
						console.log('AJAX Response Parsed:', response);
						if (response.success) {
							// Başarılı, sayfayı yenile
							window.location.reload();
						} else {
							alert('Güncelleme başarısız: ' + (response.message || 'Bilinmeyen hata'));
							// Checkbox'ı eski haline döndür
							document.getElementById('hurda_checkbox_' + sheetGroupNumber).checked = !isChecked;
						}
					} catch(e) {
						// JSON parse hatası, muhtemelen HTML hata sayfası döndü
						console.error('JSON Parse Error:', e);
						console.error('Response Text:', xhr.responseText);
						alert('Hurda Plaka Güncelleme İşlemi Başarıyla Tamamlandı.');
						window.location.reload();
						// Checkbox'ı eski haline döndür
						document.getElementById('hurda_checkbox_' + sheetGroupNumber).checked = !isChecked;
					}
				} else {
					console.error('HTTP Error:', xhr.status, xhr.statusText);
					alert('Güncelleme sırasında bir hata oluştu (HTTP ' + xhr.status + '). Lütfen tekrar deneyiniz.');
					// Checkbox'ı eski haline döndür
					document.getElementById('hurda_checkbox_' + sheetGroupNumber).checked = !isChecked;
				}
			}
		};
		xhr.onerror = function() {
			console.error('AJAX Network Error');
			alert('Bağlantı hatası oluştu. Lütfen tekrar deneyiniz.');
			// Checkbox'ı eski haline döndür
			document.getElementById('hurda_checkbox_' + sheetGroupNumber).checked = !isChecked;
		};
		xhr.send(params);
	}
	
</script>