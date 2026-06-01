<!---
    File: add_ezgi_revision_tracing.cfm
    Folder: Add_Ons\ezgi\e_sales\query
    Author: Ezgi Yazılım
    Date: 01/05/2026
    Description:
---> 
<cfset is_transfer = 1>
<cfset urun_type = 0>
<cfset attributes.is_configure = 1>

<!---Sanal Teklif Hangi Aşamaya Kadar İlerlermiş---> 
<cfquery name="get_process" datasource="#dsn3#">
     SELECT
	    EOR.VIRTUAL_OFFER_STAGE, 
	    EOR.VIRTUAL_OFFER_NUMBER, 
	    EOR.VIRTUAL_OFFER_DATE, 
	    EOR.COMPANY_ID, 
	    EOR.CONSUMER_ID, 
	    EOR.NAME_PRODUCT, 
	    EOR.QUANTITY, 
	    EOR.PRODUCT_NAME, 
	    EOR.SPECT_MAIN_ID, 
        EOR.OFFER_NUMBER, 
	    EOR.ORDER_NUMBER, 
	    EOR.LOT_NO, 
	    EOR.MASTER_PLAN_NAME, 
	    EOR.MASTER_PLAN_NUMBER, 
	    EOR.EZGI_ID, 
	    EOR.VIRTUAL_OFFER_ID, 
	    EOR.STOCK_ID, 
	    EOR.PRODUCT_ID, 
	    EOR.PRODUCT_NAME2, 
	    EOR.P_ORDER_ID, 
	    EOR.ORDER_ID, 
	    EOR.OFFER_ID, 
	    EOR.MASTER_PLAN_ID, 
	    EOR.PROJECT_ID, 
	    EOR.IS_STAGE, 
	    EOR.UNIT,
	    EOR.OR_QUANTITY,
	    EOR.OF_QUANTITY,
	    EOR.PO_QUANTITY,
	    ISNULL(EOR.ORDER_ROW_ID,0) AS ORDER_ROW_ID,
	    ISNULL(TBL.DESIGN_MAIN_ROW_ID,0) AS DESIGN_MAIN_ROW_ID, 
        ISNULL(TBL.DESIGN_ID,0) AS DESIGN_ID,
	    ISNULL(TBB.IS_TREE,0) AS IS_TREE,
	    EVORD.VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID,
	    EVORD.IS_CONFIRM,
	    EVORD.CONFIRM_EMP, 
	    EVORD.CONFIRM_DATE,
	    EVORD.UPDATE_DATE,
	    ISNULL(EVORD.IS_REVISION,0) as IS_REVISION
    FROM     
        EZGI_ORGE_RELATIONS AS EOR LEFT OUTER JOIN
	    EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY AS EVORD ON EOR.EZGI_ID = EVORD.EZGI_ID LEFT OUTER JOIN
	    (
	    	SELECT 
	        	EDMR.DESIGN_MAIN_ROW_ID, 
	            EDMR.DESIGN_ID, 
	            EVOR.EZGI_ID
		    FROM     
	        	EZGI_DESIGN_MAIN_ROW AS EDMR INNER JOIN
	          	OFFER_ROW AS OFR ON EDMR.WRK_ROW_RELATION_ID = OFR.WRK_ROW_ID INNER JOIN
	          	OFFER AS O ON OFR.OFFER_ID = O.OFFER_ID INNER JOIN
	          	EZGI_VIRTUAL_OFFER_ROW AS EVOR ON OFR.WRK_ROW_ID = EVOR.WRK_ROW_RELATION_ID
		    WHERE  
	        	NOT (EVOR.EZGI_ID IS NULL)
	    ) AS TBL ON TBL.EZGI_ID = EOR.EZGI_ID LEFT OUTER JOIN
	    (
	    	SELECT 
	        	IS_TREE, 
	            SPECT_MAIN_ID
		    FROM     
	        	SPECT_MAIN
		    WHERE  
	            IS_TREE = 1
	    ) AS TBB ON TBB.SPECT_MAIN_ID = EOR.SPECT_MAIN_ID
    WHERE  
	    ISNULL(EVORD.IS_REVISION,0) = 1 AND
        EOR.VIRTUAL_OFFER_STATUS = 1 AND 
	    EVORD.IS_CONFIRM IS NULL AND
	    EVORD.VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID = <cfqueryparam value="#attributes.history_id#" cfsqltype="cf_sql_integer"> 
</cfquery>
<cfif get_process.recordcount>
    <cfquery name="get_defaults" datasource="#dsn3#">
        SELECT * FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
    </cfquery>    
    <cfquery name="get_colors" datasource="#dsn3#">
	    SELECT * FROM EZGI_COLORS ORDER BY COLOR_NAME
    </cfquery>
    <cfoutput query="get_colors">
        <cfset 'COLOR_NAME_#COLOR_ID#' = COLOR_NAME>
    </cfoutput>
    <cfquery name="get_product_cat_piece" datasource="#dsn3#">
  	    SELECT HIERARCHY FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = #get_defaults.DEFAULT_PIECE_CAT_ID#
    </cfquery>
    <cfquery name="get_product_cat_package" datasource="#dsn3#">
        SELECT HIERARCHY FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = #get_defaults.DEFAULT_PACKAGE_CAT_ID#
    </cfquery>

    <cfquery name="get_process_group" dbtype="query">
        SELECT
            VIRTUAL_OFFER_STAGE, 
            VIRTUAL_OFFER_NUMBER, 
            VIRTUAL_OFFER_DATE, 
            COMPANY_ID, 
            CONSUMER_ID, 
            NAME_PRODUCT, 
            QUANTITY, 
            PRODUCT_NAME, 
            OFFER_NUMBER, 
            EZGI_ID, 
            VIRTUAL_OFFER_ID, 
            STOCK_ID, 
            PRODUCT_ID, 
            PRODUCT_NAME2, 
            OFFER_ID, 
            PROJECT_ID, 
            UNIT,
            OF_QUANTITY,
            DESIGN_MAIN_ROW_ID, 
            DESIGN_ID,
            SPECT_MAIN_ID,
            IS_TREE, 
            VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID,
            IS_CONFIRM,
            CONFIRM_EMP, 
            CONFIRM_DATE,
            UPDATE_DATE,
            IS_REVISION,
            LOT_NO
        FROM
            get_process
        GROUP BY
            VIRTUAL_OFFER_STAGE, 
            VIRTUAL_OFFER_NUMBER, 
            VIRTUAL_OFFER_DATE, 
            COMPANY_ID, 
            CONSUMER_ID, 
            NAME_PRODUCT, 
            QUANTITY, 
            PRODUCT_NAME, 
            OFFER_NUMBER, 
            EZGI_ID, 
            VIRTUAL_OFFER_ID, 
            STOCK_ID, 
            PRODUCT_ID, 
            PRODUCT_NAME2, 
            OFFER_ID , 
            PROJECT_ID,
            UNIT,
            OF_QUANTITY,
            DESIGN_MAIN_ROW_ID, 
            DESIGN_ID,
            SPECT_MAIN_ID,
            IS_TREE,
            VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID,
            IS_CONFIRM,
            CONFIRM_EMP, 
            CONFIRM_DATE,
            UPDATE_DATE,
            IS_REVISION,
            LOT_NO
    </cfquery>
    
    <!---Değişim Alanlarını buluyoruz.---> 
    <cfquery name="get_history" datasource="#dsn3#">
            SELECT 
                EVHR.STOCK_ID, 
                EVHR.QUESTION_ID, 
                EVHR.PIECE_TYPE, 
                EVHR.PIECE_ROW_ID, 
                EVH.EZGI_ID, 
                EVHR.DESIGN_EN, 
                EVHR.DESIGN_BOY, 
                EVHR.AMOUNT, 
                EVHR.PRODUCT_NAME,
                EVOD.PRODUCT_NAME AS NEW_PRODUCT_NAME, 
                EVOD.STOCK_ID AS NEW_STOCK_ID, 
                EVOR.BOY AS NEW_BOY, 
                EVOR.EN AS NEW_EN, 
                EVOR.DERINLIK AS NEW_DERINLIK, 
                EVOR.YON AS NEW_YON, 
                EVOD.DESIGN_EN AS NEW_DESIGN_EN, 
                EVOD.DESIGN_BOY AS NEW_DESIGN_BOY, 
                EVOD.AMOUNT AS NEW_AMOUNT,
                EVOR.PRODUCT_ID,
                EDPR.PIECE_NAME,
                EDPR.PIECE_AMOUNT,
                EDPR.DESIGN_PACKAGE_ROW_ID                
            FROM     
                EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY AS EVH INNER JOIN
                EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ROW AS EVHR ON EVH.VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID = EVHR.VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID INNER JOIN
                EZGI_VIRTUAL_OFFER_ROW_DETAIL AS EVOD ON EVHR.EZGI_ID = EVOD.EZGI_ID AND EVHR.PIECE_ROW_ID = EVOD.PIECE_ROW_ID AND EVHR.PIECE_TYPE = EVOD.PIECE_TYPE AND EVHR.QUESTION_ID = EVOD.QUESTION_ID 	INNER JOIN
                EZGI_VIRTUAL_OFFER_ROW AS EVOR ON EVOD.EZGI_ID = EVOR.EZGI_ID LEFT OUTER JOIN
                EZGI_DESIGN_PIECE_ROWS AS EDPR ON EVHR.PIECE_ROW_ID = EDPR.PIECE_ROW_ID
            WHERE  
                EVH.VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID = #attributes.history_id# 
    </cfquery>
    <cfquery name="get_design_info" datasource="#dsn3#">
        SELECT 
            ED.DESIGN_NAME, 
            ED.PROCESS_ID,
            ISNULL(ED.IS_PROTOTIP,0) AS IS_PROTOTIP
        FROM 
            EZGI_DESIGN AS ED WITH (NOLOCK)
        WHERE 
            ED.DESIGN_ID = #get_process_group.DESIGN_ID#
    </cfquery>

    <!---Değişim Detaylarını Arıyoruz--->
    <cfset change_package_row_id_list = "">
    <cfset change_piece_row_id_list = "">
    <cftransaction>
        <!---TAKİP BAŞLIYOR--->
                
        <!---1.Takip- Eğer Özel Mobilya Tasarıma Transfer Edilmiş İse---> 
        <cfif len(get_process_group.DESIGN_MAIN_ROW_ID)>
            <cfloop query="get_history">
                <cfif (get_history.NEW_STOCK_ID neq get_history.STOCK_ID) or  (get_history.NEW_DESIGN_BOY neq get_history.DESIGN_BOY) or (get_history.NEW_DESIGN_EN neq get_history.DESIGN_EN) or (get_history.NEW_AMOUNT neq get_history.AMOUNT)><!---Eğer Değişim Var İse--->
                
                    <!---Mobilya Tasarımda Yapılan Master Ürüne giderek İlgili Parçanın Sıra Nosunu sini alır.--->
                    <cfquery name="get_master_piece_row" datasource="#dsn3#">
                            SELECT 
                                PIECE_NAME,
                                PIECE_CODE,
                                PIECE_TYPE
                            FROM 
                                EZGI_DESIGN_PIECE_ROWS
                            WHERE 
                                PIECE_ROW_ID = <cfqueryparam value="#get_history.PIECE_ROW_ID#" cfsqltype="cf_sql_integer">
                    </cfquery>
                
                
                    <!---Özel Mobilya Tasarımdaki Parçayı Bul--->
                    <cfquery name="get_design_pieces_control" datasource="#dsn3#">
                        SELECT 
                            PIECE_ROW_ID,
                            PIECE_CODE,
                            DESIGN_PACKAGE_ROW_ID,
                            PIECE_DETAIL,
                            PIECE_FLOOR,
                            PIECE_PACKAGE_ROTA
                        FROM 
                            EZGI_DESIGN_PIECE_ROWS
                        WHERE 
                            DESIGN_MAIN_ROW_ID = #get_process_group.DESIGN_MAIN_ROW_ID# AND
                            PIECE_TYPE = #get_master_piece_row.PIECE_TYPE# AND
                            PIECE_CODE = '#get_master_piece_row.PIECE_CODE#'        
                    </cfquery>
                    <cfset change_package_row_id_list = ListAppend(change_package_row_id_list, get_design_pieces_control.DESIGN_PACKAGE_ROW_ID)>
                    <cfset change_piece_row_id_list = ListAppend(change_piece_row_id_list, get_design_pieces_control.PIECE_ROW_ID)>
                    <!---Eğer Listede Yok İse--->
                    <cfif not get_design_pieces_control.recordcount>
                        <script type="text/javascript">
                            alert("<cfoutput>#get_history.PIECE_ROW_ID#</cfoutput> nolu Parça, Değişen Ürün Parça Listesinde Bulunamadı!");
                        </script>
                        <cfabort>
                    </cfif>
                    <!---Eğer Listede Birden Fazla İse--->
                    <cfif get_design_pieces_control.recordcount gt 1>
                        <script type="text/javascript">
                            alert("<cfoutput>#get_history.PIECE_ROW_ID#</cfoutput> nolu Parça, Değişen Ürün Parça Listesinde Birden Fazla Var!");
                            window.close()
                        </script>
                        <cfabort>
                    </cfif>
                    
                    <!---Default Değerler--->
                    <cfset attributes.yonga_levha_fire_rate = get_defaults.DEFAULT_YONGA_LEVHA_FIRE_RATE>
                    <cfset attributes.pvc_fire_amount = get_defaults.DEFAULT_PVC_FIRE_AMOUNT>
                    <cfset attributes.piece_trim_type = get_defaults.DEFAULT_TRIM_TYPE>

                    <!---Guuruptan Gelen Bilgiler--->
                    <cfset attributes.design_id = get_process_group.DESIGN_ID>
                    <cfset attributes.design_main_row_id = get_process_group.DESIGN_MAIN_ROW_ID>

                    <!---Eğer sorun Yok İse--->
                    <cfif get_history.PIECE_TYPE eq 4> <!---Sadece Parça 4 için yazıldı diğerleri için düzenleme yapılacak--->
                        <cfquery name="UPDATE_PIECE_ROWS" datasource="#dsn3#">
                            UPDATE 
                                EZGI_DESIGN_PIECE_ROWS
                            SET  
                                PIECE_TYPE = #get_history.PIECE_TYPE#
                                <cfif (get_history.NEW_STOCK_ID neq get_history.STOCK_ID)>     
                                    ,PIECE_NAME = '#get_history.NEW_PRODUCT_NAME#' 
                                    ,PIECE_RELATED_ID = #get_history.NEW_STOCK_ID#
                                </cfif>
                                <cfif (get_history.NEW_AMOUNT neq get_history.AMOUNT)>
                                    ,PIECE_AMOUNT = #get_history.NEW_AMOUNT#
                                </cfif>
                                <cfif (get_history.NEW_DESIGN_EN neq get_history.DESIGN_EN) or (get_history.NEW_AMOUNT neq get_history.AMOUNT)>
                                    ,ENI = #get_history.NEW_DESIGN_EN#
                                    ,BOYU = #get_history.NEW_DESIGN_BOY#
                                </cfif>
                            WHERE  
                                PIECE_ROW_ID = #get_design_pieces_control.PIECE_ROW_ID#
                        </cfquery>
                    <cfelseif get_history.PIECE_TYPE neq 4> 
                        <cfquery name="get_piece_info" datasource="#dsn3#"> <!---Özelliklerini alacağımız Yeni Seçilen Parçanın Bilgileri Alınıyor--->
                            SELECT * FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) WHERE PIECE_ROW_ID = #get_history.NEW_STOCK_ID#<!---Özelliklerini alacağımız Yeni Seçilen Parça ID--->
                        </cfquery>
                        <cfif get_piece_info.recordcount neq 1>
                            <cfdump var="#get_piece_info#">
                            Sanal Teklifte <cfoutput>#get_history.PIECE_NAME#</cfoutput> Parçasına Karşılık Seçilen Üründe Sorun Var
                            <cfabort>
                        </cfif>
                        
                        <cfquery name="get_piece_row_info" datasource="#dsn3#"><!---Aksesuar Özelliklerini alacağımız Yeni Seçilen Parçanın Alt Bilgileri Alınıyor--->
                            SELECT * FROM EZGI_DESIGN_PIECE_ROW WITH (NOLOCK) WHERE PIECE_ROW_ID = #get_history.NEW_STOCK_ID#
                        </cfquery>
                        

                        <!---Halihazır Parçadan Gelen Bilgiler--->
                        <cfset attributes.piece_package_no = get_design_pieces_control.DESIGN_PACKAGE_ROW_ID>
                        <cfset attributes.design_piece_row_id = get_design_pieces_control.PIECE_ROW_ID><!---Üzerinde Değişiklik Yapacağımız Eski ve Hala devam eden Parça ID--->
                        <cfset attributes.piece_detail = get_design_pieces_control.PIECE_DETAIL>
                        <cfset attributes.piece_package_floor_no = get_design_pieces_control.PIECE_FLOOR>
                        <cfset attributes.piece_package_rota = get_design_pieces_control.PIECE_PACKAGE_ROTA>

                        <!---Parçaya Yeni Atayacağımız Parça Bilgileri (Değişim Esnasında Seçilen Parçanın Özellikleri)--->
                        <cfset attributes.COLOR_TYPE = get_piece_info.PIECE_COLOR_ID>
                        <cfset attributes.DEFAULT_TYPE = get_piece_info.MASTER_PRODUCT_ID>
                        <cfset attributes.trim_type = get_piece_info.TRIM_TYPE>
                        <cfset attributes.trim_rate = TlFormat(get_piece_info.TRIM_SIZE,1)>
                        <cfset attributes.PIECE_SU_YONU = get_piece_info.IS_FLOW_DIRECTION>
                        <cfset attributes.PIECE_KALINLIK = get_piece_info.KALINLIK>
                        <cfset attributes.PIECE_TYPE = get_piece_info.PIECE_TYPE>
                        
                        <!---Mobilya Tasarımda Yapılmış İlk Halinden Gelen Bilgiler--->
                        <cfset attributes.DESIGN_NAME_PIECE_ROW = get_master_piece_row.PIECE_NAME>
                        <cfset attributes.DESIGN_CODE_PIECE_ROW = get_master_piece_row.PIECE_CODE>
                        
                        <!---Değişiklik talebinden Gelen Bilgiler--->
                        <cfset attributes.PIECE_BOY = TlFormat(get_history.NEW_DESIGN_BOY,1)>
                        <cfset attributes.PIECE_EN = TlFormat(get_history.NEW_DESIGN_EN,1)>
                        <cfset attributes.PIECE_AMOUNT = TlFormat(get_history.NEW_AMOUNT,4)>
                        
                        <cfquery name="get_pvc_info" dbtype="query">
                            SELECT * FROM get_piece_row_info WHERE PIECE_ROW_ROW_TYPE = 1
                        </cfquery>
                        <cfquery name="get_material_info" dbtype="query">
                            SELECT * FROM get_piece_row_info WHERE PIECE_ROW_ROW_TYPE = 0
                        </cfquery>
                        <cfquery name="get_hzm_info" dbtype="query">
                            SELECT * FROM get_piece_row_info WHERE PIECE_ROW_ROW_TYPE = 3
                        </cfquery>
                        <cfquery name="get_aks_info" dbtype="query">
                            SELECT * FROM get_piece_row_info WHERE PIECE_ROW_ROW_TYPE = 2
                        </cfquery>
                        <cfloop from="1" to="4" index="i">
                            <cfset 'attributes.PVC_MATERIALS_#i#' = 0>
                            <cfset 'attributes.anahtar_#i#' = 0>
                        </cfloop>
                        <cfloop query="get_pvc_info">
                            <cfset 'attributes.PVC_MATERIALS_#SIRA_NO#' = get_pvc_info.STOCK_ID>
                            <cfset 'attributes.anahtar_#SIRA_NO#' = 1>
                        </cfloop>
                        <cfif get_material_info.recordcount>
                            <cfset attributes.PIECE_YONGA_LEVHA = get_material_info.STOCK_ID>
                        </cfif>
                        <cfif get_hzm_info.recordcount>
                            <cfset record_num_hzm = get_hzm_info.recordcount>
                            <cfloop query="get_hzm_info">
                                <cfset 'attributes.row_kontrol_hzm#currentrow#' = 1>
                                <cfset 'attributes.stock_id_hzm#currentrow#' = get_hzm_info.STOCK_ID>
                                <cfset 'attributes.quantity_hzm#currentrow#' = TlFormat(get_hzm_info.AMOUNT,4)>
                            </cfloop>
                        <cfelse>
                            <cfset record_num_hzm = 0>
                        </cfif>
                        <cfif get_aks_info.recordcount>
                            <cfset record_num = get_aks_info.recordcount>
                            <cfloop query="get_aks_info">
                                <cfset 'attributes.row_kontrol#currentrow#' = 1>
                                <cfset 'attributes.stock_id#currentrow#' = get_aks_info.STOCK_ID>
                                <cfset 'attributes.quantity#currentrow#' = TlFormat(get_aks_info.AMOUNT,4)>
                            </cfloop>
                        <cfelse>
                            <cfset record_num = 0>
                        </cfif>
                        <cfinclude template="../../e_design/query/upd_ezgi_product_tree_creative_piece_row_insert.cfm"> <!---Güncelleme Sorgusuna Gidiyor--->
                    </cfif>
                </cfif>
            </cfloop>
        </cfif> 
        <cfset change_spect_main_id_list = "">
        <!---2.Takip- Eğer Özel Mobilya Tasarımada Spect Oluşmuşsa (Ürün Ağacı Kontrol Yapılmışsa)---> 
        <cfif len(get_process_group.SPECT_MAIN_ID) and get_process_group.SPECT_MAIN_ID gt 0>
            <cfinclude template="../../e_design/query/get_ezgi_private_product_tree_import.cfm">
            
            <cfoutput query="get_satirlar">
                <cfif LEN(get_satirlar.SPECT_MAIN_ID)> <!--- Spect Main Tanımlı İse--->
                    <cfquery name="del_product_tree" datasource="#dsn3#"> <!---Spect_Main_row lar siliniyor. Operasyonlarda Kayıt Değişikliği Yapmayacağız İlerde Yapılmak istenirse Düzenleme Yapınız--->
                        DELETE FROM SPECT_MAIN_ROW WHERE SPECT_MAIN_ID = #get_satirlar.SPECT_MAIN_ID# AND NOT(STOCK_ID IS NULL)
                    </cfquery>
                </cfif>
                <cfset i = get_satirlar..recordcount>
                <cfset 'attributes.SPECT_MAIN_ID_#i#' = get_satirlar.SPECT_MAIN_ID>
                <cfset change_spect_main_id_list = ListAppend(change_spect_main_id_list, get_satirlar.SPECT_MAIN_ID)>
                <cfset type = get_satirlar.type> 
                <cfset IID = get_satirlar.IID>  
                <cfinclude template="../../e_design/query/cnt_ezgi_product_tree_import_ortak.cfm">

                <cfquery name="get_product_tree" dbtype="query">
                    SELECT * FROM get_product_tree ORDER BY OPERATION_TYPE_ID DESC, RELATED_ID
                </cfquery>

                <cfif get_product_tree.recordcount>
                    <cfloop query="get_product_tree">
                        <cfif get_product_tree.RELATED_ID eq 0> <!---Operasyon İse--->
                            <cfset attributes.add_stock_id = ''>
                            <cfset attributes.UNIT_ID = ''>
                            <cfset attributes.spect_main_id = ''>
                            <cfset attributes.product_id = ''>
                            <cfset attributes.product_name = ''>
                            <cfset attributes.operation_type_id = get_product_tree.OPERATION_TYPE_ID>
                            <cfset attributes.AMOUNT = get_product_tree.AMOUNT>
                            <cfset attributes.process_stage_ = get_defaults.DEFAULT_PRODUCT_TREE_PROCESS_STAGE>
                            <cfset attributes.spect_related_id = 0>
                        <cfelse><!---Ürün İse--->
                            <cfif not len(get_product_tree.RELATED_ID)>
                                Hata : Stok ID bağlantı sorunu
                                <cfdump var="#get_product_tree#"><cfdump var="#get_material_3#"><cfabort>                                    
                            </cfif>
                            <!---Spect Satırlarını Düzenlemek için Satırları oluşturan Ürünlerin Bilgileri toplanıyor--->
                            <cfquery name="get_stock_info" datasource="#dsn3#"><!--- Stok Bilgileri Toplanıyor--->
                                SELECT        
                                    S.PRODUCT_ID, 
                                    P.PRODUCT_CODE, 
                                    P.PRODUCT_NAME,
                                    ISNULL(P.IS_PROTOTYPE,0) AS IS_PROTOTYPE,
                                    ISNULL(P.IS_PRODUCTION,0) AS IS_PRODUCTION,
                                    PU.MAIN_UNIT, 
                                    PU.PRODUCT_UNIT_ID,
                                    <cfif get_defaults.IS_HIZMET_PHANTOM eq 1>
                                        CASE
                                            WHEN 
                                                ISNULL(P.IS_PRODUCTION,0) = 0
                                            THEN 
                                                0
                                            ELSE
                                                ISNULL((
                                                            SELECT 
                                                                PRODUCT_CATID 
                                                            FROM 
                                                                PRODUCT_CAT WITH (NOLOCK) 
                                                            WHERE 
                                                                LIST_ORDER_NO IN (1,5) AND PRODUCT_CATID = S.PRODUCT_CATID
                                                ),0) 
                                            END AS IS_PHANTOM
                                    <cfelse>
                                        0 AS IS_PHANTOM
                                    </cfif>
                                FROM            
                                    STOCKS AS S WITH (NOLOCK) INNER JOIN
                                    PRODUCT AS P WITH (NOLOCK) ON S.PRODUCT_ID = P.PRODUCT_ID INNER JOIN
                                    PRODUCT_UNIT AS PU WITH (NOLOCK) ON P.PRODUCT_ID = PU.PRODUCT_ID
                                WHERE        
                                    S.STOCK_ID = #get_product_tree.RELATED_ID# AND 
                                    PU.IS_MAIN = 1
                            </cfquery>
                            <cfif get_stock_info.recordcount>
                                <cfif get_stock_info.IS_PRODUCTION>
                                    <cfif get_stock_info.IS_PROTOTYPE>
                                        <cfset attributes.spect_related_id = get_product_tree.SPECT_RELATED_ID>
                                    <cfelse>
                                        <cfquery name="get_spect_main_id" datasource="#dsn3#">
                                            SELECT        
                                                TOP (1) SPECT_MAIN_ID
                                            FROM   
                                                SPECT_MAIN WITH (NOLOCK)
                                            WHERE        
                                                STOCK_ID = #get_product_tree.RELATED_ID#
                                            ORDER BY 
                                                SPECT_MAIN_ID DESC
                                        </cfquery>
                                        <cfset attributes.spect_related_id = get_spect_main_id.SPECT_MAIN_ID>
                                    </cfif>
                                <cfelse>
                                    <cfset attributes.spect_related_id = get_product_tree.SPECT_RELATED_ID>
                                </cfif>
                                    
                                <cfset attributes.product_id = get_stock_info.PRODUCT_ID>
                                <cfset attributes.product_name = get_stock_info.PRODUCT_NAME>
                                <cfset attributes.add_stock_id = get_product_tree.RELATED_ID>
                                <cfset attributes.UNIT_ID = get_stock_info.PRODUCT_UNIT_ID>
                                <cfset attributes.main_unit = get_stock_info.MAIN_UNIT>
                                <cfset attributes.AMOUNT = get_product_tree.AMOUNT>
                                <cfset attributes.process_stage_ = get_defaults.DEFAULT_PRODUCT_TREE_PROCESS_STAGE>
                                <cfset attributes.operation_type_id = ''>
                                <cfif get_defaults.IS_HIZMET_PHANTOM eq 1>
                                    <cfif GET_STOCK_INFO.IS_PHANTOM gt 0>
                                        <cfset attributes.is_phantom = 1>
                                    <cfelse>
                                        <cfset attributes.is_phantom = ''>
                                    </cfif>
                                <cfelse>
                                    <cfset attributes.is_phantom = ''>
                                </cfif>
                            <cfelse>
                                <cfoutput>#get_product_tree.RELATED_ID#</cfoutput> STOCK_ID ile Eklenecek Ürüne Ait Bilgi Bulunamadı.
                                <cfabort>
                            </cfif>
                            <!---Ürünün spect satırları düzenleniyor--->
                            <cfinclude template="../../e_design/query/add_ezgi_private_spect_main_row.cfm">
                        </cfif>
                    </cfloop>
                </cfif>
            </cfoutput>
        </cfif>

        <!---3.Takip- Eğer Üretim Planı Yapılmışsa---> 
        <cfif len(get_process_group.LOT_NO) and Listlen(change_spect_main_id_list)>
            <cfquery name="get_production_plan" datasource="#dsn3#">
                SELECT 
                    QUANTITY,
                    P_ORDER_ID,
                    SPEC_MAIN_ID
                FROM     
                    PRODUCTION_ORDERS
                WHERE  
                    LOT_NO = '#get_process_group.LOT_NO#' AND 
                    SPEC_MAIN_ID IN (#change_spect_main_id_list#)
            </cfquery>
            <cfif get_production_plan.recordcount>
                <cfloop query="get_production_plan">
                    <cfquery name="del_production_order_stocks" datasource="#dsn3#">
                        DELETE FROM     
                            PRODUCTION_ORDERS_STOCKS
                        WHERE  
                            P_ORDER_ID = #Get_production_plan.P_ORDER_ID#
                    </cfquery>
                    <cfquery name="get_sub_product" datasource="#dsn3#">
                        SELECT 
                            SMM.SPECT_MAIN_ID, 
                            SMM.SPECT_MAIN_ROW_ID, 
                            SMM.PRODUCT_ID, 
                            SMM.STOCK_ID, 
                            SMM.AMOUNT, 
                            SMM.IS_PHANTOM, 
                            SMM.RELATED_MAIN_SPECT_ID, 
                            SMM.IS_SEVK, 
                            SMM.IS_PROPERTY, 
                            ISNULL(SMM.FIRE_AMOUNT, 0) AS FIRE_AMOUNT, 
                            ISNULL(SMM.FIRE_RATE, 0) AS FIRE_RATE, 
                            ISNULL(SMM.LINE_NUMBER, 0) AS LINE_NUMBER, 
                            ISNULL(SMM.LINE_NUMBER, 0) AS MAIN_LINE_NUMBER,
                            ISNULL(SMM.IS_FREE_AMOUNT, 0) AS IS_FREE_AMOUNT, 
                            S.PRODUCT_UNIT_ID
                        FROM     
                            SPECT_MAIN_ROW AS SMM INNER JOIN
                            STOCKS AS S ON SMM.STOCK_ID = S.STOCK_ID
                        WHERE  
                            SMM.SPECT_MAIN_ID = #get_production_plan.SPEC_MAIN_ID# AND 
                            SMM.IS_PHANTOM = 0 AND 
                            NOT (SMM.PRODUCT_ID IS NULL)
                        UNION ALL
                        SELECT 
                            SMR.SPECT_MAIN_ID, 
                            SMM.SPECT_MAIN_ROW_ID, 
                            SMM.PRODUCT_ID, 
                            SMM.STOCK_ID, 
                            SMM.AMOUNT * SMR.AMOUNT AS AMOUNT, 
                            SMR.IS_PHANTOM, 
                            SMM.RELATED_MAIN_SPECT_ID, 
                            SMM.IS_SEVK, 
                            SMM.IS_PROPERTY, 
                            ISNULL(SMM.FIRE_AMOUNT, 0) AS FIRE_AMOUNT, 
                            ISNULL(SMM.FIRE_RATE, 0) AS FIRE_RATE, 
                            ISNULL(SMM.LINE_NUMBER, 0) AS LINE_NUMBER, 
                            ISNULL(SMR.LINE_NUMBER, 0) AS MAIN_LINE_NUMBER, 
                            ISNULL(SMM.IS_FREE_AMOUNT, 0) AS IS_FREE_AMOUNT, 
                            S.PRODUCT_UNIT_ID
                        FROM     
                            SPECT_MAIN_ROW AS SMR INNER JOIN
                            SPECT_MAIN AS SM ON SMR.STOCK_ID = SM.STOCK_ID INNER JOIN
                            SPECT_MAIN_ROW AS SMM ON SM.SPECT_MAIN_ID = SMM.SPECT_MAIN_ID INNER JOIN
                            STOCKS AS S ON SMM.STOCK_ID = S.STOCK_ID
                        WHERE  
                            SMR.SPECT_MAIN_ID = #get_production_plan.SPEC_MAIN_ID# AND 
                            NOT (SMR.PRODUCT_ID IS NULL) AND 
                            SMR.IS_PHANTOM = 1
                        ORDER BY
                            MAIN_LINE_NUMBER,
                            LINE_NUMBER
                    </cfquery>
                    <cfif get_sub_product.recordcount>
						<cfoutput query="get_sub_product">
                            <cfset wrk_id_new_sarf = 'WRK#round(rand()*65)##dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmssL')##session.ep.userid##round(rand()*100)#U#Get_production_plan.P_ORDER_ID#S#get_sub_product.STOCK_ID#'>
                            <cfstoredproc procedure="ADD_PRODUCTION_ORDERS_STOCKS" datasource="#dsn3#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#Get_production_plan.P_ORDER_ID#">    
                                <cfprocparam cfsqltype="cf_sql_integer" value="#get_sub_product.PRODUCT_ID#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#get_sub_product.STOCK_ID#">
                                <cfif len(get_sub_product.RELATED_MAIN_SPECT_ID)>
                                    <cfprocparam cfsqltype="cf_sql_integer" value="#get_sub_product.RELATED_MAIN_SPECT_ID#">
                                <cfelse>
                                    <cfprocparam cfsqltype="cf_sql_integer" value="NULL" null="yes">
                                </cfif>
                                <cfprocparam cfsqltype="cf_sql_float" value="#get_sub_product.AMOUNT*get_production_plan.QUANTITY#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="2">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#get_sub_product.PRODUCT_UNIT_ID#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
                                <cfprocparam cfsqltype="cf_sql_timestamp" value="#now()#">
                                <cfprocparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">
                                <cfprocparam cfsqltype="cf_sql_bit" value="#get_sub_product.IS_PHANTOM#">
                                <cfprocparam cfsqltype="cf_sql_bit" value="#get_sub_product.IS_SEVK#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#get_sub_product.IS_PROPERTY#">
                                <cfprocparam cfsqltype="cf_sql_bit" value="#get_sub_product.IS_FREE_AMOUNT#">
                                <cfprocparam cfsqltype="cf_sql_float" value="#get_sub_product.FIRE_AMOUNT#">
                                <cfprocparam cfsqltype="cf_sql_float" value="#get_sub_product.FIRE_RATE#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#get_sub_product.SPECT_MAIN_ROW_ID#">
                                <cfprocparam cfsqltype="cf_sql_bit" value="1">
                                <cfprocparam cfsqltype="cf_sql_varchar" value="#wrk_id_new_sarf#">
                                <cfprocparam cfsqltype="cf_sql_integer" value="#get_sub_product.MAIN_LINE_NUMBER#">
                            </cfstoredproc>
                        </cfoutput>
                    </cfif>      
                </cfloop>
            <cfelse>
                <script type="text/javascript">
                    alert("Sanal Teklifteki Lot No'ya Ait Üretim Planı Bulunamadı!");
                    window.close()
                </script>
                <cfabort>
            </cfif>
        </cfif>

        <!---History Tablosu Güncelleniyor...--->
        <cfquery name="update_history" datasource="#dsn3#">
            UPDATE 
                EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY
            SET 
                IS_CONFIRM = 1,
                CONFIRM_EMP = #session.ep.userid#,
                CONFIRM_DATE = #now()#,  
                CONFIRM_IP = '#cgi.REMOTE_ADDR#' 
            WHERE 
                VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID = #attributes.history_id#
        </cfquery>
    </cftransaction> 
</cfif>    
 <script type="text/javascript">
    alert("Onaylama Sonrası Gerekli Kayıt Değişiklikleri Yapılmıştır.!");
    window.close()
</script>