<!---
    File: upd_ezgi_product_tree_creative_main_row_from_efurniturecad.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/04/2025
    Description:
--->
<cfset cad_dsn3 = '#dsn#_efurniturecad_#session.ep.company_id#'>
<!---Defaultlar--->
<cfquery name="get_default" datasource="#dsn3#">
	SELECT 
    	*,
        ISNULL(DEFAULT_TRIM_AMOUNT,0) AS TRIM_RATE 
   	FROM 
    	EZGI_DESIGN_DEFAULTS
</cfquery>
<!---Defaultlar--->
<cfif isdefined('attributes.status') and len(attributes.status)><!---Eğer Status Değiştirilmek İstiyorsa--->
	<cfquery name="upd_efurniturecad_status" datasource="#cad_dsn3#">
		UPDATE WORKCUBE_AUTOCAD_PRODUCT_TREE SET IS_ACTIVE = #attributes.status# WHERE WA_PRODUCT_TREE_ID = #attributes.efurniturecad_id#
	</cfquery>
    <script type="text/javascript">
        alert("EFurnitureCAD dosyasının Aktiflik Durumu Başarıyla Değiştirildi!");
    </script>
    <cflocation url="#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_main_row_from_efurniturecad&design_main_row_id=#attributes.design_main_row_id#" addtoken="no">
<cfelse><!---Eğer Status Değiştirilmek İstemiyorsa--->
    <!---Modül Üzerinde Kayıtlı Paket Varmı --->
    <cfquery name="get_design_package_row" datasource="#dsn3#">
        SELECT PACKAGE_NUMBER FROM EZGI_DESIGN_PACKAGE WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
    </cfquery>
    <cfif get_design_package_row.recordcount>
        <script type="text/javascript">
            alert("Tasarımda Modüle ait Paketler Mevcut Aktarım Yapılamaz!");
            window.close()
        </script>
        <cfabort>
    </cfif>

    <!---E-FurnitureCad ROW table çekiyorum ve kontrol ediyorum--->
   
    <cfquery name="get_efurniturecad_row" datasource="#cad_dsn3#">
        SELECT * FROM WORKCUBE_AUTOCAD_PRODUCT_TREE_ROW WHERE WA_PRODUCT_TREE_ID = #attributes.efurniturecad_id#
    </cfquery>
    <cfif not get_efurniturecad_row.recordcount>
        <script type="text/javascript">
            alert("EFurnitureCAD dosyasında Satır Bilgisi Bulunamdı!");
            window.close()
        </script>
        <cfabort>
    </cfif>

    <!---E-FurnitureCad OPERATION table çekiyorum ve kontrol ediyorum--->
    <cfquery name="get_efurniturecad_operation" datasource="#cad_dsn3#">
        SELECT 
            OP.WA_PRODUCT_TREE_OPERATION_TYPE_ID,
            OP.OPERATION_TYPE_ID, 
            OP.OPERATION_TYPE, 
            OP.AMOUNT, 
            OP.G_CODE, 
            OP.PICTURE, 
            ROW.PIECE_NUMBER
        FROM     
            WORKCUBE_AUTOCAD_PRODUCT_TREE_OPERATION_TYPE AS OP INNER JOIN
            WORKCUBE_AUTOCAD_PRODUCT_TREE_ROW AS ROW ON OP.WA_PRODUCT_TREE_ROW_ID = ROW.WA_PRODUCT_TREE_ROW_ID
        WHERE  
            ROW.WA_PRODUCT_TREE_ID = #attributes.efurniturecad_id#
    </cfquery>
    <cfif not get_efurniturecad_operation.recordcount>
        <script type="text/javascript">
            alert("EFurnitureCAD dosyasında Operasyon Bilgisi Bulunamdı!");
            window.close()
        </script>
        <cfabort>
    </cfif>


    <!---E-FurnitureCad ROW table çekiTİĞİM Paket Numaralarını Gurupluyorum ve Kontrol ediyorum--->
    <cfquery name="get_efurniturecad_row_package" datasource="#cad_dsn3#">
        SELECT
            CAST(PACKAGE_NUMBER AS integer) PACKAGE_NUMBER
        FROM
            WORKCUBE_AUTOCAD_PRODUCT_TREE_ROW
        WHERE
            ISNULL(PACKAGE_NUMBER,0) >0 AND
            WA_PRODUCT_TREE_ID = #attributes.efurniturecad_id#
        GROUP BY
            PACKAGE_NUMBER
        ORDER BY
            PACKAGE_NUMBER
    </cfquery>

    <cfset sira = 1>
    <cfoutput query="get_efurniturecad_row_package">
        <cfif get_efurniturecad_row_package.PACKAGE_NUMBER neq sira>
            <script type="text/javascript">
                alert("#sira# Nolu Paket Bulunamadı!");
                window.close()
            </script>
        </cfif>
        <cfset sira = sira+1>
    </cfoutput>
    <cfquery name="get_efurniturecad_package" datasource="#cad_dsn3#">
        SELECT
            PACKAGE_NUMBER,
            PACKAGE_NAME, 
            COLOR_NAME, 
            PACKAGE_DEPTH, 
            PACKAGE_LENGTH, 
            PACKAGE_WIDTH, 
            PACKAGE_WEIGHT
        FROM
            WORKCUBE_AUTOCAD_PRODUCT_TREE_PACKAGE_INFO
        WHERE
            ISNULL(PACKAGE_NUMBER,0) >0 AND
            WA_PRODUCT_TREE_ID = #attributes.efurniturecad_id#
        ORDER BY
            PACKAGE_NUMBER
    </cfquery>
    <cfset sira = 1>
    <cfoutput query="get_efurniturecad_package">
        <cfif get_efurniturecad_package.PACKAGE_NUMBER neq sira>
            <script type="text/javascript">
                alert("#sira# Nolu Paket Bulunamadı!");
                window.close()
            </script>
        </cfif>
        <cfset sira = sira+1>
    </cfoutput>
    <cfoutput query="get_efurniturecad_package">
        <cfif len(get_efurniturecad_package.COLOR_NAME)>
            <cfquery name="get_color_info" datasource="#dsn3#">
                SELECT COLOR_ID, COLOR_NAME FROM EZGI_COLORS WHERE COLOR_NAME = '#get_efurniturecad_package.COLOR_NAME#'
            </cfquery>
            <cfset 'PACKAGE_COLOR_ID_#get_efurniturecad_package.PACKAGE_NUMBER#' = get_color_info.COLOR_ID>
        </cfif>
    </cfoutput>
    <!---Default Paketleme Operasyonunu buluyorum ve Kontrol ediyorum--->
    <cfquery name="GET_DEFAULT_PACKING" datasource="#dsn3#">
        SELECT        
            OTT.OPERATION_TYPE_ID
        FROM           
            OPERATION_TYPES AS OTT WITH (NOLOCK) INNER JOIN
            EZGI_DESIGN_DEFAULTS AS EDD WITH (NOLOCK) ON OTT.OPERATION_TYPE_ID = EDD.DEFAULT_PACKAGE_OPERATION_TYPE_ID
    </cfquery>
    <cfif not GET_DEFAULT_PACKING.recordcount>
        <script type="text/javascript">
            alert(<cf_get_lang dictionary_id='1171.Genel Default Tanımlarda Paketleme Operasyonu Tanımlı Değil. Düzenleyip Tekrar Deneyin'>);
            window.close()
        </script>
        <cfabort>
    </cfif>

    <!---Eklenecek Modülün Bilgilerini Topluyorum.--->
    <cfquery name="get_design_main_row" datasource="#dsn3#">
        SELECT 	
            *,
            (
                SELECT 
                    TOP (1) MAIN_ROW_SETUP_NAME 
                FROM 
                    EZGI_DESIGN_MAIN_ROW_SETUP 
                WHERE 
                    MAIN_ROW_SETUP_ID = E.MAIN_ROW_SETUP_ID
            ) AS MAIN_ROW_SETUP_NAME   
        FROM 
            EZGI_DESIGN_MAIN_ROW AS E WITH (NOLOCK) 
        WHERE 
            DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
    </cfquery>

    <!---*********Paketleri Oluşturuyorum*************--->
    <cftransaction>
        <cfloop query="get_efurniturecad_row_package">
            <cfset package_number = get_efurniturecad_row_package.PACKAGE_NUMBER>
            <cfinclude template="add_ezgi_product_tree_creative_package_row_insert.cfm">
        </cfloop>

        <!---Parçaları Oluşturmak İçin Bilgi Topluyorum.--->
        <cfinclude template="cnt_ezgi_product_tree_creative_main_row_from_efurniturecad.cfm"><!---Kontrol Dosyasına Gidiyoruz--->
        <cfif Last_Row gt 0><!---Eğer Kontrolden Geçen Parçalar varsa--->
            <cfset EZGI_VIRTUAL_OFFER_ROW_IMPORT = queryNew("EZGI_ID, POZ_ID, PACKAGE_ROW_ID, PIECE_ID, PIECE_ROW_ID, PIECE_TYPE, PIECE_COLOR_ID, STOCK_ID, PRODUCT_NAME, AMOUNT, BOY, EN, KALINLIK, YON, DETAY, PVC1, PVC2, PVC3, PVC4, CANAL_DETAIL, COVER_MODEL, HOLE_QUANTITY, MATERIAL_MEASURE1, MATERIAL_MEASURE2, MATERIAL_AMOUNT, PACKAGE_DETAIL, OPERATION_CODE1, OPERATION_CODE2, YUZEY1, YUZEY2, BOYA1, BOYA2,PIECE_WEIGHT,PIECE_PARAMS,PICTURE,RASER,ADD_WIDTH,ADD_LENGTH,TRIM_TYPE,TRIM_RATE","integer, integer, integer, integer, integer, integer, integer, integer, VarChar, Decimal, Decimal, Decimal, Decimal, Bit, VarChar, integer, integer, integer, integer, VarChar, VarChar, Decimal, Decimal, Decimal, Decimal, VarChar, VarChar, VarChar, Decimal, Decimal, Decimal, Decimal, Decimal, VarChar, VarChar,integer, Decimal, Decimal,integer,Decimal") />
        
            <cfloop from="1" to="#parca_listesi.recordcount#" index="i">
                <cfset temp = QueryAddRow(EZGI_VIRTUAL_OFFER_ROW_IMPORT)>
                <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "EZGI_ID", 1)> 
                <cfif isdefined('POZ_ID_#i#') and len(Evaluate('POZ_ID_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "POZ_ID", Evaluate('POZ_ID_#i#'))> 
                </cfif>
                <cfif isdefined('PACKAGE_ROW_ID_#i#') and len(Evaluate('PACKAGE_ROW_ID_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PACKAGE_ROW_ID", Evaluate('PACKAGE_ROW_ID_#i#'))> 
                </cfif>
                <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PIECE_ID", i)>
                <cfif isdefined('PIECE_ROW_ID_#i#') and len(Evaluate('PIECE_ROW_ID_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PIECE_ROW_ID", Evaluate('PIECE_ROW_ID_#i#'))> 
                </cfif>
                <cfif isdefined('PIECE_TYPE_#i#') and len(Evaluate('PIECE_TYPE_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PIECE_TYPE", Evaluate('PIECE_TYPE_#i#'))> 
                </cfif>
                <cfif isdefined('COLOR_ID_#i#') and len(Evaluate('COLOR_ID_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PIECE_COLOR_ID", Evaluate('COLOR_ID_#i#'))>
                </cfif> 
                <cfif Evaluate('PIECE_TYPE_#i#') eq 4>
                    <cfif isdefined('STOCK_ID_#i#') and len(Evaluate('STOCK_ID_#i#'))>
                        <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "STOCK_ID", Evaluate('STOCK_ID_#i#'))>
                    </cfif>
                <cfelseif Evaluate('PIECE_TYPE_#i#') eq 1>
                    <cfif isdefined('YONGA_LEVHA_ID_#i#') and len(Evaluate('YONGA_LEVHA_ID_#i#'))>
                        <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "STOCK_ID", Evaluate('YONGA_LEVHA_ID_#i#'))>
                    </cfif>
                <cfelse>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "STOCK_ID", 0)> 
                </cfif>
                <cfif isdefined('PIECE_NAME_#i#') and len(Evaluate('PIECE_NAME_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PRODUCT_NAME", Evaluate('PIECE_NAME_#i#'))>
                </cfif> 
                <cfif isdefined('PIECE_AMOUNT_#i#') and len(Evaluate('PIECE_AMOUNT_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "AMOUNT", FilterNum(Evaluate('PIECE_AMOUNT_#i#'),4))> 
                <cfelse>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "AMOUNT", 1)>
                </cfif> 
                <cfif isdefined('BOY_#i#') and len(Evaluate('BOY_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "BOY", FilterNum(Evaluate('BOY_#i#'),2))>
                </cfif>
                <cfif isdefined('EN_#i#') and len(Evaluate('EN_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "EN", FilterNum(Evaluate('EN_#i#'),2))> 
                </cfif>
                <cfif isdefined('KALINLIK_#i#') and len(Evaluate('KALINLIK_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "KALINLIK", Evaluate('KALINLIK_#i#'))>
                </cfif>
                <cfif isdefined('YON_#i#') and len(Evaluate('YON_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "YON", Evaluate('YON_#i#'))>
                </cfif> 
                <cfif isdefined('PIECE_DETAIL_#i#') and len(Evaluate('PIECE_DETAIL_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "DETAY", Evaluate('PIECE_DETAIL_#i#'))>
                </cfif> 
                <cfif isdefined('KENAR1_#i#') and len(Evaluate('KENAR1_#i#'))>               
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PVC1", Evaluate('KENAR1_#i#'))>
                </cfif>
                <cfif isdefined('KENAR2_#i#') and len(Evaluate('KENAR2_#i#'))>               
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PVC2", Evaluate('KENAR2_#i#'))>
                </cfif>
                <cfif isdefined('KENAR3_#i#') and len(Evaluate('KENAR3_#i#'))>               
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PVC3", Evaluate('KENAR3_#i#'))>
                </cfif>
                <cfif isdefined('KENAR4_#i#') and len(Evaluate('KENAR4_#i#'))>               
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PVC4", Evaluate('KENAR4_#i#'))>
                </cfif>
                <cfif isdefined('CANAL_DETAIL_#i#') and len(Evaluate('CANAL_DETAIL_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "CANAL_DETAIL", Evaluate('CANAL_DETAIL_#i#'))>
                </cfif>
                <cfif isdefined('COVER_MODEL_#i#') and len(Evaluate('COVER_MODEL_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "COVER_MODEL", Evaluate('COVER_MODEL_#i#'))>
                </cfif>
                <cfif isdefined('HOLE_QUANTITY_#i#') and len(Evaluate('HOLE_QUANTITY_#i#'))> 
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "HOLE_QUANTITY", Evaluate('HOLE_QUANTITY_#i#'))> 
                </cfif>
                <cfif isdefined('MATERIAL_MEASURE1_#i#') and len(Evaluate('MATERIAL_MEASURE1_#i#'))> 
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "MATERIAL_MEASURE1", Evaluate('MATERIAL_MEASURE1_#i#'))>        
                </cfif>
                <cfif isdefined('MATERIAL_MEASURE2_#i#') and len(Evaluate('MATERIAL_MEASURE2_#i#'))> 
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "MATERIAL_MEASURE2", Evaluate('MATERIAL_MEASURE2_#i#'))>        
                </cfif>
                <cfif isdefined('MATERIAL_AMOUNT_#i#') and len(Evaluate('MATERIAL_AMOUNT_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "MATERIAL_AMOUNT", Evaluate('MATERIAL_AMOUNT_#i#'))>
                </cfif>
                <cfif isdefined('PACKAGE_DETAIL_#i#') and len(Evaluate('PACKAGE_DETAIL_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PACKAGE_DETAIL", Evaluate('PACKAGE_DETAIL_#i#'))>
                </cfif>
                <cfif isdefined('OPERATION_CODE1_#i#') and len(Evaluate('OPERATION_CODE1_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "OPERATION_CODE1", Evaluate('OPERATION_CODE1_#i#'))>
                </cfif>
                <cfif isdefined('OPERATION_CODE2_#i#') and len(Evaluate('OPERATION_CODE2_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "OPERATION_CODE2", Evaluate('OPERATION_CODE2_#i#'))>
                </cfif>
                <cfif isdefined('YUZEY1_#i#') and len(Evaluate('YUZEY1_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "YUZEY1", Evaluate('YUZEY1_#i#'))>
                <cfelse>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "YUZEY1", 0)>
                </cfif>
                <cfif isdefined('YUZEY2_#i#') and len(Evaluate('YUZEY2_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "YUZEY2", Evaluate('YUZEY2_#i#'))>
                <cfelse>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "YUZEY2", 0)>
                </cfif>
                <cfif isdefined('BOYA1_#i#') and len(Evaluate('BOYA1_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "BOYA1", Evaluate('BOYA1_#i#'))>
                <cfelse>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "BOYA1", 0)>
                </cfif>
                <cfif isdefined('BOYA2_#i#') and len(Evaluate('BOYA2_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "BOYA2", Evaluate('BOYA2_#i#'))>
                <cfelse>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "BOYA2", 0)>
                </cfif>
                <cfif isdefined('PIECE_WEIGHT_#i#') and len(Evaluate('PIECE_WEIGHT_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PIECE_WEIGHT", FilterNum(Evaluate('PIECE_WEIGHT_#i#'),2))>
                <cfelse>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PIECE_WEIGHT", 0)>
                </cfif>
                <cfif isdefined('PIECE_PARAMS_#i#') and len(Evaluate('PIECE_PARAMS_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PIECE_PARAMS", Evaluate('PIECE_PARAMS_#i#'))>
                </cfif>
                <cfif isdefined('PICTURE_#i#') and len(Evaluate('PICTURE_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "PICTURE", Evaluate('PICTURE_#i#'))>
                </cfif>
                <cfif isdefined('RASER_#i#') and len(Evaluate('RASER_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "RASER", Evaluate('RASER_#i#'))>
                </cfif>
                <cfif isdefined('ADD_WIDTH_#i#') and len(Evaluate('ADD_WIDTH_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "ADD_WIDTH",  FilterNum(Evaluate('ADD_WIDTH_#i#'),4))>
                <cfelse>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "ADD_WIDTH", 0)>
                </cfif>
                <cfif isdefined('ADD_LENGTH_#i#') and len(Evaluate('ADD_LENGTH_#i#'))>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "ADD_LENGTH",  FilterNum(Evaluate('ADD_LENGTH_#i#'),4))>
                <cfelse>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "ADD_LENGTH", 0)>
                </cfif>
                <cfif get_default.DEFAULT_TRIM_TYPE eq 1 or get_default.DEFAULT_TRIM_TYPE eq 2>
                	<cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "TRIM_TYPE", get_default.DEFAULT_TRIM_TYPE)>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "TRIM_RATE", get_default.TRIM_RATE)>
              	<cfelseif get_default.DEFAULT_TRIM_TYPE eq 0>
                	<cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "TRIM_TYPE", 0)>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "TRIM_RATE", 0)>
             	<cfelseif get_default.DEFAULT_TRIM_TYPE eq 3>
                	<cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "TRIM_TYPE", get_default.DEFAULT_TRIM_TYPE)>
                    <cfset Temp = QuerySetCell(EZGI_VIRTUAL_OFFER_ROW_IMPORT, "TRIM_RATE", 1)>
             	</cfif>
            </cfloop>
        </cfif>
        
        <cfquery name="get_package_rows" datasource="#dsn3#">
            SELECT PACKAGE_ROW_ID,PACKAGE_NUMBER FROM EZGI_DESIGN_PACKAGE_ROW WHERE DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID#
        </cfquery>
        <cfquery name="get_piece_row" datasource="#dsn3#">
            SELECT PIECE_ROW_ID FROM EZGI_DESIGN_PIECE_ROWS WHERE PIECE_TYPE = 3 AND DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID#
        </cfquery>
        
        <cfset attributes.DESIGN_ID = get_design_main_row.DESIGN_ID>
        <cfset GET_DEFAULT_EBATLAMA.OPERATION_TYPE_ID = get_default.DEFAULT_CUTTING_OPERATION_TYPE_ID>
        <cfset attributes.PVC_FIRE_AMOUNT = get_default.DEFAULT_PVC_FIRE_AMOUNT>
        <cfset attributes.yonga_levha_fire_rate = get_default.DEFAULT_YONGA_LEVHA_FIRE_RATE>
        
        <cfquery name="get_pieces" dbtype="query"> <!---Sanal Teklif İmalat Dosyasındaki Parçalar listeleniyor --->
            SELECT 
                PACKAGE_ROW_ID,
                YON,
                PIECE_ROW_ID,
                PIECE_ID, 
                PIECE_TYPE,
                PIECE_COLOR_ID,
                STOCK_ID,
                PRODUCT_NAME,
                BOY BOYU,
                EN ENI,
                DETAY,
                KALINLIK,
                AMOUNT MIKTARI,
                PVC1,
                PVC2,
                PVC3,
                PVC4, 
                MATERIAL_MEASURE1, 
                MATERIAL_MEASURE2, 
                MATERIAL_AMOUNT,
                YUZEY1,
                YUZEY2,
                BOYA1,
                BOYA2,
                PIECE_WEIGHT,
                PIECE_PARAMS,
                PICTURE,
                RASER,
                ADD_WIDTH,
                ADD_LENGTH,
                TRIM_TYPE,
                TRIM_RATE
            FROM 
                EZGI_VIRTUAL_OFFER_ROW_IMPORT 
            ORDER BY 
                PIECE_TYPE
        </cfquery>
        
        <cfif get_pieces.recordcount> <!---Bulunan Parçalar Döndürülüyor--->
        
            <cfset record_num_yrm = 0>
            <cfset record_num_hzm = 0>
            <cfset record_num = 0>
            <cfset attributes.piece_detail =''>
            
            <cfloop query="get_pieces">
                <!---Paket Bölümü--->
                <cfif len(get_pieces.PACKAGE_ROW_ID)>
                    <cfset package_no = get_pieces.PACKAGE_ROW_ID>
                <cfelse>
                    <cfset package_no = ''>
                </cfif>
                <!---Paket Bölümü--->
                <cfif get_pieces.PIECE_TYPE neq 4> <!---Parça Hammadde değil ise--->
                    <cfquery name="get_operations" datasource="#dsn3#"> <!---İmalat Dosyasındaki Belirtilen Örnek  Parçalar ait operasyonlar Özel Tasarıma Kayıt için listeleniyor--->
                        SELECT 
                            OPERATION_TYPE_ID, 
                            SIRA, 
                            QUANTITY AS AMOUNT
                        FROM     
                            EZGI_DESIGN_PIECE_DEFAULTS_ROTA
                        WHERE  
                            PIECE_DEFAULT_ID = #get_pieces.PIECE_ROW_ID#
                        ORDER BY
                            SIRA
                    </cfquery>
                    <!---PVC Bölümü--->
                    <cfloop from="1" to="4" index="i">
                        <cfif Evaluate('get_pieces.pvc#i#') eq 0> <!---PVC Yok Denmişse--->
                            <cfset 'attributes.PVC_MATERIALS_#i#' = 0>
                            <cfset 'attributes.anahtar_#i#' = 0>
                        <cfelse> <!---STOCK_ID Gönderilmişse--->
                            <cfset 'attributes.PVC_MATERIALS_#i#' = Evaluate('get_pieces.pvc#i#')>
                            <cfset 'attributes.anahtar_#i#' = 1>
                        </cfif> 
                    </cfloop>
                    <!---PVC Bölümü--->
                                
                    <!---Yonga Levha ve Kalınlık Bölümü --->
                    <cfset attributes.PIECE_YONGA_LEVHA = get_pieces.STOCK_ID>
                    <cfset attributes.PIECE_KALINLIK = get_pieces.KALINLIK>
                    <!---Yonga Levha Bölümü--->
                                
                    <!---Hizmetler Bölümü--->
                    <cfset satir = 0>
                    <cfif get_pieces.YUZEY1 gt 0>
                        <cfset satir = satir+1>
                        <cfset 'attributes.row_kontrol_hzm#satir#' = 1>
                        <cfset 'attributes.stock_id_hzm#satir#' = get_pieces.YUZEY1>
                        <cfset 'attributes.quantity_hzm#satir#' = TlFormat(1,4)>
                    </cfif>
                    <cfif get_pieces.YUZEY2 gt 0>
                        <cfif get_pieces.YUZEY1 eq get_pieces.YUZEY2>
                            <cfset 'attributes.row_kontrol_hzm#satir#' = 1>
                            <cfset 'attributes.stock_id_hzm#satir#' = get_pieces.YUZEY2>
                            <cfset 'attributes.quantity_hzm#satir#' = TlFormat(2,4)>
                        <cfelse>
                            <cfset satir = satir+1>
                            <cfset 'attributes.row_kontrol_hzm#satir#' = 1>
                            <cfset 'attributes.stock_id_hzm#satir#' = get_pieces.YUZEY2>
                            <cfset 'attributes.quantity_hzm#satir#' = TlFormat(1,4)>
                        </cfif>
                    </cfif>
                    <cfif get_pieces.BOYA1 gt 0>
                        <cfset satir = satir+1>
                        <cfset 'attributes.row_kontrol_hzm#satir#' = 1>
                        <cfset 'attributes.stock_id_hzm#satir#' = get_pieces.BOYA1>
                        <cfset 'attributes.quantity_hzm#satir#' = TlFormat(1,4)>
                    </cfif>
                    <cfif get_pieces.BOYA2 gt 0>
                        <cfif get_pieces.BOYA1 eq get_pieces.BOYA2>
                            <cfset 'attributes.row_kontrol_hzm#satir#' = 1>
                            <cfset 'attributes.stock_id_hzm#satir#' = get_pieces.BOYA2>
                            <cfset 'attributes.quantity_hzm#satir#' = TlFormat(2,4)>
                        <cfelse>
                            <cfset satir = satir+1>
                            <cfset 'attributes.row_kontrol_hzm#satir#' = 1>
                            <cfset 'attributes.stock_id_hzm#satir#' = get_pieces.BOYA2>
                            <cfset 'attributes.quantity_hzm#satir#' = TlFormat(1,4)>
                        </cfif>
                    </cfif>
                    <cfset record_num_hzm = satir>
                    <!---Hizmetler Bölümü--->
                    
                    <!---Eksik Kalanlar--->
                    <cfset attributes.piece_trim_type = 0>
                    <cfset attributes.trim_type = 0>
                    <!---Eksik Kalanlar--->
        
                    <cfset attributes.COLOR_TYPE = get_pieces.PIECE_COLOR_ID>
                    <cfset attributes.DEFAULT_TYPE = get_pieces.PIECE_ROW_ID>
                    <cfset attributes.PIECE_SU_YONU = get_pieces.YON>
                    <cfset attributes.piece_package_floor_no = ''>
                    <cfset attributes.piece_package_rota = ''>
                    <cfset attributes.piece_detail = get_pieces.DETAY>
                <cfelse>
                    <cfset rawmaterial_detail = ''>
                    <cfif len(get_pieces.MATERIAL_MEASURE1)>
                        <cfset rawmaterial_detail = '#get_pieces.MATERIAL_MEASURE1#X'>
                    </cfif>
                    <cfif len(get_pieces.MATERIAL_MEASURE2)>
                        <cfset rawmaterial_detail = '#rawmaterial_detail##get_pieces.MATERIAL_MEASURE2#X'>
                    </cfif>
                    <cfif len(get_pieces.MATERIAL_AMOUNT)>
                        <cfset rawmaterial_detail = '#rawmaterial_detail# - #MATERIAL_AMOUNT# Adet'>
                    </cfif>
                    <cfset attributes.piece_detail = rawmaterial_detail>
                </cfif>
                <cfset record_num = 0>
                <cfset attributes.DESIGN_CODE_PIECE_ROW = get_pieces.PIECE_ID>
                <cfset attributes.PIECE_TYPE = get_pieces.PIECE_TYPE>
                <cfset attributes.related_stock_id = get_pieces.STOCK_ID>
                <cfset attributes.RELATED_PRODUCT_NAME = get_pieces.PRODUCT_NAME>
                <cfset attributes.DESIGN_NAME_PIECE_ROW = '#get_design_main_row.MAIN_ROW_SETUP_NAME# #get_pieces.PRODUCT_NAME#'>
                <cfset attributes.PIECE_BOY = TlFormat(get_pieces.BOYU,1)>
                <cfset attributes.PIECE_EN = TlFormat(get_pieces.ENI,1)>
                <cfset attributes.piece_package_no = package_no>
                <cfset attributes.PIECE_AMOUNT = TlFormat(get_pieces.MIKTARI,4)>
                <cfset attributes.boy_fark = TlFormat(get_pieces.ADD_LENGTH,1)>
                <cfset attributes.en_fark = TlFormat(get_pieces.ADD_WIDTH,1)>
                <cfset attributes.piece_style = get_pieces.RASER>
                <cfset attributes.trim_type = TRIM_TYPE>
                <cfset attributes.trim_rate =  TlFormat(get_pieces.TRIM_RATE,1)>
                
                <!---Attributlere bilgi yükleme Bölümü Bitti--->
                <cfquery name="get_autocad_materials" dbtype="query">
                    SELECT * FROM materials WHERE PIECE_ID = #get_pieces.PIECE_ID#
                </cfquery>     
                <cfquery name="get_autocad_operations" dbtype="query">
                    SELECT * FROM operations WHERE PIECE_ID = #get_pieces.PIECE_ID#
                </cfquery>  
                
                <!---E-Design Parça Ekleme Sorgusuna Gönderiliyor--->
                <cftransaction>
                    <cfinclude template="add_ezgi_product_tree_creative_piece_row_insert.cfm"> <!---Parça Kayıt  ediliyor--->
                    <cfset 'attributes.parca_id_#get_pieces.PIECE_ID#' = get_max_id.max_id>
                    <cfif get_autocad_materials.recordcount>
                        <cfloop query="get_autocad_materials">
                            <cfset attributes.miktar = round(get_autocad_materials.amount*10000)/10000>
                            <cfset attributes.sira_no = get_autocad_materials.currentrow>
                            <cfset attributes.row_row_type = get_autocad_materials.type>
                            <cfif get_autocad_materials.type eq 2><!---Aksesuar---> 
                                <cfset attributes.stock_id = get_autocad_materials.stock_id>
                            <cfelseif get_autocad_materials.type eq 3><!---Hizmet---> 
                                <cfset attributes.stock_id = get_autocad_materials.stock_id>
                            <cfelse>
                                <cfset attributes.stock_id = Evaluate('attributes.parca_id_#get_autocad_materials.stock_id#')>
                            </cfif>
                            <cfinclude template="add_ezgi_product_tree_creative_piece_row_row.cfm">
                        </cfloop>
                    </cfif>
                    
                    <!---Parçanın Operasyonları için Kayıt Yapılıyor--->
                    <cfif get_autocad_operations.recordcount>
                        <cfquery name="del_rota" datasource="#dsn3#">
                            DELETE FROM EZGI_DESIGN_PIECE_ROTA WHERE PIECE_ROW_ID = #get_max_id.MAX_ID#
                        </cfquery>
                        <cfloop query="get_autocad_operations">
                            <cfquery name="add_rota" datasource="#dsn3#">
                                INSERT INTO 
                                    EZGI_DESIGN_PIECE_ROTA
                                    (
                                        PIECE_ROW_ID, 
                                        OPERATION_TYPE_ID, 
                                        SIRA, 
                                        AMOUNT
                                    )
                                VALUES
                                    (
                                        #get_max_id.MAX_ID#, 
                                        #get_autocad_operations.Operation_Type_Id#,
                                        #get_autocad_operations.Number#,
                                        #get_autocad_operations.Amount#
                                    )
                            </cfquery>
                        </cfloop>
                    </cfif>
                    <!---Parçanın Image için Kayıt Yapılıyor--->
                    <cfif len(get_pieces.PICTURE)>
                        <cfinclude template="add_ezgi_product_tree_creative_import_piece_image_efurniturecad.cfm">
                    </cfif>
                </cftransaction>
            </cfloop>
            
            
            <cfif get_piece_row.recordcount eq 1 and ListLen(piece_id_list)> <!---Eğer Modül için bir adet Montajlı Parça Bulunduysa--->
                <cfquery name="get_pieces_selected" datasource="#dsn3#"> <!---Montajlı Parçaya Eklenecek yonga Levha ve Genel Reçete Parçaları lsiteleniyor --->
                    SELECT PIECE_ROW_ID,PIECE_AMOUNT FROM EZGI_DESIGN_PIECE_ROWS WHERE DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID# AND PIECE_TYPE IN (1, 2) AND PIECE_ROW_ID IN (#piece_id_list#) 
                </cfquery>
                <cfif get_pieces_selected.recordcount>
                    <cfloop query="get_pieces_selected">
                        <cfquery name="add_piece_row" datasource="#dsn3#">
                            INSERT INTO 
                                EZGI_DESIGN_PIECE_ROW
                                (
                                    PIECE_ROW_ID, 
                                    SIRA_NO,
                                    PIECE_ROW_ROW_TYPE,
                                    AMOUNT,
                                    RELATED_PIECE_ROW_ID
        
                                )
                            VALUES        
                                (
                                    #get_piece_row.PIECE_ROW_ID#,
                                    #get_pieces_selected.currentrow#,
                                    4,
                                    #get_pieces_selected.PIECE_AMOUNT#,
                                    #get_pieces_selected.PIECE_ROW_ID#
                                )
                        </cfquery>
                        <cfquery name="upd_piece_package_id" datasource="#dsn3#"> <!---Paket Numarası Temizleniyor--->
                            UPDATE 
                                EZGI_DESIGN_PIECE_ROWS 
                            SET 
                                DESIGN_PACKAGE_ROW_ID = NULL ,
                                PIECE_FLOOR = NULL ,
                                PIECE_PACKAGE_ROTA = NULL 
                            WHERE 
                                PIECE_ROW_ID IN (#piece_id_list#)
                        </cfquery>
                    </cfloop>
                    <cfquery name="upd_ezgi_piece_row_row" datasource="#dsn3#"> <!---Yeni Parça ID si EZGI Id ye güncelleniyor--->
                        UPDATE 
                            EZGI_DESIGN_PIECE_ROW 
                        SET 
                            EZGI_PIECE_ROW_ROW_ID = PIECE_ROW_ROW_ID
                        WHERE 
                            PIECE_ROW_ID IN (#piece_id_list#) AND
                            EZGI_PIECE_ROW_ROW_ID IS NULL
                    </cfquery>
                </cfif>
            </cfif>
        <cfelse>
            Kaydedilecek Parça Bulunamadı
            <cfdump var="#get_pieces#">
            <cfabort>
        </cfif>
    </cftransaction>
    <cfif isdefined('attributes.efurniturecad')> <!---Toplu Özel Mobilya Tasarım Oluşturma İşleminden Geliyorsa--->

    <cfelse>
        <script type="text/javascript">
            alert("<cf_get_lang dictionary_id='260.Aktarım Başarıyla Tamamlanmıştır'>");
            wrk_opener_reload();
            window.close();
        </script>
    </cfif>
</cfif>