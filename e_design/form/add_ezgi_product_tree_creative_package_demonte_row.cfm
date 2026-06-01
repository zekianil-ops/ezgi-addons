<!---
    File: add_ezgi_product_tree_creative_package_demonte_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/10/2024
    Description:
--->

<cfset attributes.DESIGN_MAIN_ROW_ID = get_main_info.DESIGN_MAIN_ROW_ID>
<cfset attributes.sid = get_main_info.MAIN_PROTOTIP_ID>
<cfquery name="get_default" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfquery name="get_design_default" datasource="#dsn3#">
	SELECT PROCESS_ID FROM EZGI_DESIGN WHERE DESIGN_ID = #attributes.DESIGN_ID#
</cfquery>
<cfif len(get_default.PROTOTIP_PIECE_1_ID) and len(get_default.PROTOTIP_PIECE_2_ID) and len(get_default.PROTOTIP_PIECE_3_ID)>
    <cfquery name="get_prototype_piece_1" datasource="#dsn3#">
        SELECT 
        	PIECE_RELATED_ID
        FROM     
        	EZGI_DESIGN_PIECE_ROWS
		WHERE  
        	PIECE_ROW_ID = #get_default.PROTOTIP_PIECE_1_ID#
    </cfquery>
    <cfif get_prototype_piece_1.recordcount and len(get_prototype_piece_1.PIECE_RELATED_ID)>
    
    <cfelse>
    	<script type="text/javascript">
            alert("Design Defaultlarında Tanımlanan Prototype 1 Parçası Hatalı veya Stok ID almamış!");
            window.close()
        </script>
    	<cfabort>
    </cfif> 
    
    <cfquery name="get_prototype_piece_2" datasource="#dsn3#">
        SELECT 
        	PIECE_RELATED_ID
        FROM     
        	EZGI_DESIGN_PIECE_ROWS
		WHERE  
        	PIECE_ROW_ID = #get_default.PROTOTIP_PIECE_2_ID#
    </cfquery>
    <cfif get_prototype_piece_2.recordcount and len(get_prototype_piece_2.PIECE_RELATED_ID)>
    
    <cfelse>
    	<script type="text/javascript">
            alert("Design Defaultlarında Tanımlanan Prototype 1 Parçası Hatalı veya Stok ID almamış!");
            window.close()
        </script>
    	<cfabort>
    </cfif>
    
    <cfquery name="get_prototype_piece_3" datasource="#dsn3#">
        SELECT 
        	PIECE_RELATED_ID
        FROM     
        	EZGI_DESIGN_PIECE_ROWS
		WHERE  
        	PIECE_ROW_ID = #get_default.PROTOTIP_PIECE_3_ID#
    </cfquery>
    <cfif get_prototype_piece_3.recordcount and len(get_prototype_piece_3.PIECE_RELATED_ID)>
    
    <cfelse>
    	<script type="text/javascript">
            alert("Design Defaultlarında Tanımlanan Prototype 1 Parçası Hatalı veya Stok ID almamış!");
            window.close()
        </script>
    	<cfabort>
    </cfif>  
<cfelse>
	<script type="text/javascript">
     	alert("Design Defaultlarında Prototype Parça Tanımları Hatalı!");
        window.close()
   	</script>
    <cfabort>
</cfif>
<cfset GET_DEFAULT_EBATLAMA.OPERATION_TYPE_ID = get_default.DEFAULT_CUTTING_OPERATION_TYPE_ID>
<cfset attributes.PVC_FIRE_AMOUNT = get_default.DEFAULT_PVC_FIRE_AMOUNT>
<cfset attributes.yonga_levha_fire_rate = get_default.DEFAULT_YONGA_LEVHA_FIRE_RATE>
<!---tEMİZLEME bÖLÜMÜ--->
<cfquery name="del_package_rota" datasource="#dsn3#">
	DELETE FROM 
    	EZGI_DESIGN_PIECE_ROTA
	WHERE  
    	PACKAGE_ROW_ID IN
                      	(
                        	SELECT 
                            	PACKAGE_ROW_ID
                       		FROM      
                            	EZGI_DESIGN_PACKAGE_ROW
                       		WHERE   
                            	DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID#
                     	)
</cfquery>
<cfquery name="del_package" datasource="#dsn3#">
	DELETE FROM EZGI_DESIGN_PACKAGE_ROW WHERE DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID#
</cfquery>
<cfquery name="del_piece_row" datasource="#dsn3#">
	DELETE FROM 
    	EZGI_DESIGN_PIECE_ROW
	WHERE  
    	PIECE_ROW_ID IN
                      (
                      	SELECT 
                        	PIECE_ROW_ID
                       	FROM      
                        	EZGI_DESIGN_PIECE_ROWS
                       	WHERE   
                        	DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID#
                     	)
</cfquery>
<cfquery name="del_piece_rota" datasource="#dsn3#">
	DELETE FROM 
    	EZGI_DESIGN_PIECE_ROTA
	WHERE  
    	PIECE_ROW_ID IN
                      (
                      	SELECT 
                        	PIECE_ROW_ID
                       	FROM      
                        	EZGI_DESIGN_PIECE_ROWS
                       	WHERE   
                        	DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID#
                    	)
</cfquery>
<cfquery name="del_pieces" datasource="#dsn3#">
	DELETE FROM 
    	EZGI_DESIGN_PIECE_ROWS
	WHERE  
    	DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID#
</cfquery>
<!---tEMİZLEME bÖLÜMÜ--->
<cfquery name="get_kitchen_package_row_id" datasource="#dsn3#">
	SELECT        
    	PACKAGE_ROW_ID, 
        POZ_ID,
        EZGI_ID
	FROM            
    	EZGI_VIRTUAL_OFFER_ROW_IMPORT AS EVOR WITH (NOLOCK)
	WHERE        
    	EZGI_ID =
               	(
                	SELECT        
                    	 EVOR.EZGI_ID
                  	FROM            
                    	EZGI_DESIGN_MAIN_ROW AS EDMR WITH (NOLOCK) INNER JOIN
                     	EZGI_VIRTUAL_OFFER_ROW AS EVOR WITH (NOLOCK) ON EDMR.WRK_ROW_RELATION_ID = EVOR.WRK_ROW_RELATION_ID
              		WHERE        
                    	EDMR.DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID#
               	)
     	 AND (NOT (ISNULL(ROW_TYPE, 0) IN (5, 6)))
	GROUP BY 
    	PACKAGE_ROW_ID, 
        POZ_ID,
        EZGI_ID
	HAVING        
    	NOT (POZ_ID IS NULL)
	ORDER BY 
    	POZ_ID
</cfquery>
<!---<cfdump var="#get_kitchen_package_row_id#"><cfabort>--->
<cfif get_kitchen_package_row_id.recordcount>
        <cfloop query="get_kitchen_package_row_id">
            <cfquery name="add_package_row" datasource="#dsn3#"> <!---Sanal Teklit İmalat Dosyasındaki paketler Özel tasarıma kaydediliyor--->
                INSERT INTO 
                    EZGI_DESIGN_PACKAGE_ROW
                    (
                        DESIGN_ID, 
                        DESIGN_MAIN_ROW_ID, 
                        PACKAGE_RELATED_ID, 
                        PACKAGE_NUMBER, 
                        PACKAGE_NAME, 
                        PACKAGE_COLOR_ID, 
                        PACKAGE_DETAIL, 
                        PACKAGE_AMOUNT, 
                        PACKAGE_BOYU, 
                        PACKAGE_ENI, 
                        PACKAGE_KALINLIK, 
                        PACKAGE_WEIGHT
                    )
                SELECT        
                    #attributes.DESIGN_ID#,
                    #attributes.DESIGN_MAIN_ROW_ID#,
                    PACKAGE_RELATED_ID, 
                    #get_kitchen_package_row_id.POZ_ID#, 
                    PACKAGE_NAME, 
                    PACKAGE_COLOR_ID, 
                    PACKAGE_DETAIL, 
                    1, 
                    PACKAGE_BOYU, 
                    PACKAGE_ENI, 
                    PACKAGE_KALINLIK, 
                    PACKAGE_WEIGHT
                FROM            
                    EZGI_DESIGN_PACKAGE_ROW WITH (NOLOCK)
                WHERE        
                    PACKAGE_ROW_ID = #get_kitchen_package_row_id.PACKAGE_ROW_ID#
            </cfquery>
            <cfquery name="get_max_package_id" datasource="#dsn3#"> <!---Yeni Özel Tasarım Paket Id bulunuyor--->
            	SELECT MAX(PACKAGE_ROW_ID) AS PACKAGE_ROW_ID FROM EZGI_DESIGN_PACKAGE_ROW  WITH (NOLOCK)
            </cfquery>
            <cfquery name="add_package_rota" datasource="#dsn3#">
                INSERT INTO 
                    EZGI_DESIGN_PIECE_ROTA
                    (
                        OPERATION_TYPE_ID, 
                        SIRA, 
                        AMOUNT, 
                        PACKAGE_ROW_ID
                    )
                VALUES 
                    (
                        #get_design_defults.DEFAULT_PACKAGE_OPERATION_TYPE_ID#, 
                        1, 
                        1, 
                        #get_max_package_id.PACKAGE_ROW_ID#
                    )
            </cfquery>
            <cfquery name="get_pieces_ham" datasource="#dsn3#"> <!---Sanal Teklit İmalat Dosyasındaki Parçalar Özel Tasarıma Kayıt için liteleniyor--->
            	SELECT 
                	PIECE_ROW_ID,
                	PIECE_ID, 
                    PIECE_TYPE,
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
                    ROW_TYPE,
                    SPECIAL_FIELD,
                    LEFT(SPECIAL_FIELD, CHARINDEX('_', SPECIAL_FIELD) - 1) AS LEFT_SPECIAL_FIELD, 
                    SUBSTRING(SPECIAL_FIELD, CHARINDEX('_', SPECIAL_FIELD) + 1, LEN(SPECIAL_FIELD)) AS RIGHT_SPECIAL_FIELD
               	FROM 
                	EZGI_VIRTUAL_OFFER_ROW_IMPORT WITH (NOLOCK)
               	WHERE 
                	EZGI_ID = #get_kitchen_package_row_id.EZGI_ID# AND 
                    POZ_ID = #get_kitchen_package_row_id.POZ_ID# AND 
                    (PACKAGE_ROW_ID = #get_kitchen_package_row_id.PACKAGE_ROW_ID# OR PACKAGE_ROW_ID IS NULL)
              	UNION ALL
              	SELECT 
              		PIECE_ROW_ID,
                	PIECE_ID, 
                    PIECE_TYPE,
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
                    ROW_TYPE,
                    SPECIAL_FIELD,
                  	0 AS LEFT_SPECIAL_FIELD, 
                  	0 AS RIGHT_SPECIAL_FIELD
				FROM     
                	EZGI_VIRTUAL_OFFER_ROW_IMPORT AS EZGI_VIRTUAL_OFFER_ROW_IMPORT_1 WITH (NOLOCK)
				WHERE  
                	EZGI_ID = #get_kitchen_package_row_id.EZGI_ID# AND 
                    ROW_TYPE = 5
               	ORDER BY 
                	PIECE_TYPE
            </cfquery>
            <cfquery name="get_pieces" dbtype="query">
            	SELECT * FROM get_pieces_ham WHERE PIECE_TYPE <> 0  
            </cfquery>
            <!---<cfdump var="#get_pieces#">--->
            <cfif get_pieces.recordcount> <!---Bulunan Parçalar Döndürülüyor--->
            	<cfloop query="get_pieces">
                	<cfif get_pieces.PIECE_TYPE neq 4> <!---Parça Hammadde değil ise--->
                    	<cfquery name="get_operations" datasource="#dsn3#"> <!---Sanal Teklit İmalat Dosyasındaki Parçalar ait operasyonlar Özel Tasarıma Kayıt için listeleniyor--->
                            SELECT        
                                OPERATION_TYPE_ID, 
                                AMOUNT
                            FROM            
                                EZGI_VIRTUAL_OFFER_ROW_IMPORT_ROTA WITH (NOLOCK)
                            WHERE        
                            	EZGI_ID = #get_kitchen_package_row_id.EZGI_ID# AND 
                                PIECE_ID = #get_pieces.PIECE_ID#
                        </cfquery>
                        <cfquery name="get_pieces_info" datasource="#dsn3#">  <!---Mobilya Tasarımda Tanımı yapılan Parçaların Mobilya Tasarım bilgileri çekiliyor--->
                          	SELECT * FROM EZGI_DESIGN_PIECE_ROWS WHERE PIECE_ROW_ID = #get_pieces.PIECE_ROW_ID#
                        </cfquery>
                        <cfif not get_pieces_info.recordcount> <!---Eğer Parça Bilgileri bulunamadıysa--->
                         	Parça Bilgileri Bulunamadı
                         	<cfdump var="#get_pieces_info#">
                         	<cfabort>
                        </cfif>
                        
                        <cfquery name="get_piece_row_info" datasource="#dsn3#">  <!---Mobilya Tasarımda Tanımı yapılan Parçaların Hizmet,Aksesuar,PVC ve Yonga Levha bilgileri çekiliyor--->
                            SELECT * FROM EZGI_DESIGN_PIECE_ROW WITH (NOLOCK) WHERE PIECE_ROW_ID = #get_pieces.PIECE_ROW_ID#
                        </cfquery>
                        
                        <cfquery name="get_pvc_info" dbtype="query"> <!---PVC--->
                            SELECT * FROM get_piece_row_info WHERE PIECE_ROW_ROW_TYPE = 1
                        </cfquery>
                        <cfloop query="get_pvc_info">
                        	<cfset 'varsayilan_pvc_#get_pieces.PIECE_ID#_#SIRA_NO#' = get_pvc_info.STOCK_ID>
                        </cfloop>
                        
                        <cfquery name="get_material_info" dbtype="query"><!---Yonga Levha--->
                            SELECT * FROM get_piece_row_info WHERE PIECE_ROW_ROW_TYPE = 0
                        </cfquery>
                        <cfquery name="get_hzm_info" dbtype="query"> <!---Hizmet Satırı--->
                        	SELECT * FROM get_piece_row_info WHERE PIECE_ROW_ROW_TYPE = 3
                        </cfquery>
                        <cfquery name="get_aks_info" dbtype="query"> <!---Aksesuar Satırı--->
                        	SELECT * FROM get_piece_row_info WHERE PIECE_ROW_ROW_TYPE = 2
                        </cfquery>
                        <!---Attributlere bilgi yükleme Bölümü--->
                        
                        <!---PVC Bölümü--->
                        <cfloop from="1" to="4" index="i">
                        	<cfif get_pieces.PIECE_TYPE eq 1 or get_pieces.PIECE_TYPE eq 3> <!---Yonga Levha ve Montajlı Parça İse--->
								<cfif Evaluate('get_pieces.pvc#i#') eq 0> <!---PVC Yok Denmişse--->
                                    <cfset 'attributes.PVC_MATERIALS_#i#' = 0>
                                    <cfset 'attributes.anahtar_#i#' = 0>
                                <cfelseif Evaluate('get_pieces.pvc#i#') eq -1><!---PVC Varsayılan Denmişse--->
                                    <cfif isdefined('varsayilan_pvc_#get_pieces.PIECE_ID#_#i#')> <!---Varsayılan Üründe PVC Varsa--->
                                        <cfquery name="GET_PVC_STOCK_ID" datasource="#DSN3#">
                                            SELECT        
                                                E2.STOCK_ID, 
                                                E2.PRODUCT_NAME
                                            FROM            
                                                EZGI_DESIGN_PRODUCT_PROPERTIES_UST AS E1 WITH (NOLOCK) INNER JOIN
                                                EZGI_DESIGN_PRODUCT_PROPERTIES_UST AS E2 WITH (NOLOCK) ON E1.COLOR_ID = E2.COLOR_ID AND E1.KALINLIK_ETKISI_ID = E2.KALINLIK_ETKISI_ID
                                            WHERE        
                                                E1.STOCK_ID = #Evaluate('varsayilan_pvc_#get_pieces.PIECE_ID#_#i#')# AND 
                                                NOT (E2.KALINLIK_ETKISI_ID IS NULL) AND 
                                                E2.THICKNESS_VALUE = '#get_pieces.KALINLIK#'
                                        </cfquery>
                                        <cfif GET_PVC_STOCK_ID.recordcount gt 1>
                                            <script type="text/javascript">
                                                alert("<cf_get_lang dictionary_id='75.Kalınlık'>: <cfoutput>#get_pieces.KALINLIK#</cfoutput><cf_get_lang dictionary_id='1000.Bu Kalınlıkta Birden Fazla PVC Bulunmuştur Renk Değerlerini Kontrol Ediniz!'> ");
                                                window.close()
                                            </script>
                                            <cfdump var="#GET_PVC_STOCK_ID#">
                                            <cfabort>
                                        <cfelseif not GET_PVC_STOCK_ID.recordcount>
                                            <script type="text/javascript">
                                                alert("<cf_get_lang dictionary_id='75.Kalınlık'>: <cfoutput>#get_pieces.KALINLIK#</cfoutput> <cf_get_lang dictionary_id='1001.Bu Kalınlıkta PVC Bulunamamıştır Renk Değerlerini Kontrol Ediniz!'>");
                                                window.close()
                                            </script>
                                            <cfdump var="#GET_PVC_STOCK_ID#">
                                            <cfabort>
                                        <cfelse> 
                                            <cfset 'attributes.PVC_MATERIALS_#i#' = get_pvc_info.STOCK_ID>
                                            <cfset 'attributes.anahtar_#i#' = 1>
                                        </cfif>
                                    <cfelse> <!---Varsayılan Üründe PVC Yoks--->
                                        <cfset 'attributes.PVC_MATERIALS_#i#' = 0>
                                        <cfset 'attributes.anahtar_#i#' = 0>
                                    </cfif>
                                <cfelse><!---PVC stock ID Gönderilmişse--->
                                    <cfquery name="get_pvc_stock_id_verify" datasource="#dsn3#">
                                        SELECT        
                                            STOCK_ID
                                        FROM     
                                            EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK)
                                        WHERE        
                                            STOCK_ID = #Evaluate('get_pieces.pvc#i#')# AND 
                                            LIST_ORDER_NO = 3
                                    </cfquery>
                                    <cfif get_pvc_stock_id_verify.recordcount>
                                        <cfset 'attributes.PVC_MATERIALS_#i#' = get_pvc_stock_id_verify.STOCK_ID>
                                        <cfset 'attributes.anahtar_#i#' = 1>
                                    <cfelse>
                                        <script type="text/javascript">
                                            alert("<cfoutput>#Evaluate('get_pieces.pvc#i#')#</cfoutput> <cf_get_lang dictionary_id='1002.STOCK_ID ile Kayıtlı PVC  Bulunamamıştır!'>");
                                            window.close()
                                        </script>
                                        <cfdump var="#get_pvc_stock_id_verify#">
                                        <cfabort>
                                    </cfif>
                                </cfif> 
                         	<cfelse>
                            	<cfset 'attributes.anahtar_#i#' = 0>
                                <cfset 'attributes.PVC_MATERIALS_#i#' = ''>
                            </cfif>
                        </cfloop>
						<!---PVC Bölümü--->
                        
                        
                        <!---Yonga Levha Bölümü--->
                        <cfif get_pieces.PIECE_TYPE eq 1> <!---Yonga Levha İse--->
							<cfif get_material_info.recordcount>
                                <cfquery name="get_thickness_piece" datasource="#dsn3#">
                                    SELECT        
                                        STOCK_ID,
                                        THICKNESS_ID
                                    FROM            
                                        EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK)
                                    WHERE        
                                        LIST_ORDER_NO = 1 AND 
                                        COLOR_ID = #get_pieces_info.PIECE_COLOR_ID# AND 
                                        THICKNESS_VALUE = '#get_pieces.KALINLIK#'
                                </cfquery>
                                <cfif not get_thickness_piece.recordcount>
                                    #currentrow#. Sıradaki Kalınlık #product_file_row.col_5# Malzemesinin Yonga Levha Kalınlığı Renk Tanımlarında #product_file_row.col_9# mm. Tanımlı Değildir.
                                    <cfdump var="#get_thickness_piece#">
                                    <cfabort>
                                </cfif>
                                <cfset attributes.PIECE_YONGA_LEVHA = get_thickness_piece.STOCK_ID>
                                <cfset attributes.PIECE_KALINLIK = get_thickness_piece.THICKNESS_ID>
                            </cfif>
                        <cfelse>
                        	<cfset attributes.PIECE_YONGA_LEVHA = ''>
                        </cfif>
                        <!---Yonga Levha Bölümü--->
                        
                        <!---Hizmetler Bölümü--->
                        <!---Sadece Örnek Parçadan Gelen Aksesuarlar--->
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
                        <!---Hizmetler Bölümü--->
                        
                        <!---Aksesuarlar Bölümü--->
                        <cfquery name="get_aks_row_info" dbtype="query">
                        	SELECT * FROM get_pieces_ham WHERE ROW_TYPE = 5 AND SPECIAL_FIELD = #PIECE_ID#
                        </cfquery>
                        <cfset record_num = get_aks_row_info.recordcount>
                        <cfif get_aks_row_info.recordcount>
                       		<cfloop query="get_aks_row_info">
                            	<cfset 'attributes.row_kontrol#currentrow#' = 1>
                        		<cfset 'attributes.stock_id#currentrow#' = get_aks_row_info.STOCK_ID>
                                <cfset 'attributes.quantity#currentrow#' = TlFormat(get_aks_row_info.MIKTARI,4)>
                            </cfloop> 	
                        </cfif>
                        <!---Aksesuarlar Bölümü--->
                        
                        <!---Montaj Bölümü--->
                        <cfif get_pieces.PIECE_TYPE eq 3> <!---Montaj Ürünü İse--->
                            <cfquery name="get_yrm_row_info" dbtype="query">
                                SELECT * FROM get_pieces_ham WHERE ROW_TYPE = 6 AND LEFT_SPECIAL_FIELD = #PIECE_ID#
                            </cfquery>
                            <cfset record_num_yrm = get_yrm_row_info.recordcount>
                            <cfif get_yrm_row_info.recordcount>
                                <cfloop query="get_yrm_row_info">
                                	<cfif get_yrm_row_info.recordcount and len(get_yrm_row_info.RIGHT_SPECIAL_FIELD)>
                                        <cfquery name="get_piece_row_id" datasource="#dsn3#">
                                            SELECT 
                                                PIECE_ROW_ID
                                            FROM     
                                                EZGI_DESIGN_PIECE_ROWS
                                            WHERE  
                                                DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID# AND 
                                                PIECE_CODE = '#get_yrm_row_info.RIGHT_SPECIAL_FIELD#'
                                            ORDER BY 
                                                PIECE_ROW_ID DESC
                                        </cfquery>
                                    <cfelse>
                                    
                                    </cfif>
                                    <cfset 'attributes.row_kontrol_yrm#currentrow#' = 1>
                                    <cfset 'attributes.piece_yari_mamul#currentrow#' = get_piece_row_id.PIECE_ROW_ID>
                                    <cfset 'attributes.quantity_yrm#currentrow#' = TlFormat(get_yrm_row_info.MIKTARI,4)>
                                </cfloop> 	
                            </cfif>
                        </cfif>
                        <!---Montaj Bölümü--->
                        
                        <cfset attributes.COLOR_TYPE = get_pieces_info.PIECE_COLOR_ID>
						<cfset attributes.DEFAULT_TYPE = get_pieces_info.MASTER_PRODUCT_ID>
                        <cfset attributes.PIECE_SU_YONU = get_pieces_info.IS_FLOW_DIRECTION>
                        <cfset attributes.piece_package_floor_no = get_pieces_info.PIECE_FLOOR>
                 		<cfset attributes.piece_package_rota = get_pieces_info.PIECE_PACKAGE_ROTA>
                        <cfset attributes.piece_detail = get_pieces.DETAY>
                    <cfelse> <!---Hammadde İse--->
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
                    <cfset attributes.DESIGN_CODE_PIECE_ROW = get_pieces.PIECE_ID>
                   	<cfset attributes.PIECE_TYPE = get_pieces.PIECE_TYPE>
                  	<cfset attributes.related_stock_id = get_pieces.STOCK_ID>
                   	<cfset attributes.RELATED_PRODUCT_NAME = get_pieces.PRODUCT_NAME>
                   	<cfset attributes.DESIGN_NAME_PIECE_ROW = get_pieces.PRODUCT_NAME>
                  	<cfset attributes.PIECE_BOY = get_pieces.BOYU>
                   	<cfset attributes.PIECE_EN = get_pieces.ENI>
                   	<cfset attributes.piece_package_no = get_max_package_id.PACKAGE_ROW_ID>
                  	<cfset attributes.PIECE_AMOUNT = TlFormat(get_pieces.MIKTARI,4)>
                    <!---Attributlere bilgi yükleme Bölümü Bitti--->
                    
                    <!---E-Design Parça Ekleme Sorgusuna Gönderiliyor--->
                    <cftransaction>
                   	 	<cfinclude template="add_ezgi_product_tree_creative_piece_row_insert.cfm"> <!---Parça Kayıt  ediliyor--->
                    </cftransaction>
                    <cfif get_pieces.PIECE_TYPE neq 4> <!---Hammadde Değilse--->
                    	<cfif len(get_pieces.STOCK_ID)> <!---Eğer Örnek Parça Stok Bağlantılı ise--->
                        	<cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Kaydedilen Parça Özelleştirilebilir Stok ID ile ilişkilendiriliyor--->
                                UPDATE 
                                	EZGI_DESIGN_PIECE_ROWS 
                               	SET 
                                    PIECE_RELATED_ID = #get_pieces.STOCK_ID#
                               	WHERE 
                                	PIECE_ROW_ID = #get_max_id.MAX_ID#
                            </cfquery>
                        <cfelse><!---Eğer Örnek Parça Stok Bağlantılı Değilse--->
                        	<cfif get_design_default.PROCESS_ID eq 1> <!---Özel Mobilya Tasarım Modül-Paket-Parça İse--->
                            	<cfif get_pieces.PIECE_TYPE eq 1>
                                	<cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Kaydedilen Parça Design Defaultlarda Tanımlanan Prototype  Stok ID ile ilişkilendiriliyor--->
                                        UPDATE 
                                            EZGI_DESIGN_PIECE_ROWS 
                                        SET 
                                            PIECE_RELATED_ID = #get_prototype_piece_1.PIECE_RELATED_ID#
                                        WHERE 
                                            PIECE_ROW_ID = #get_max_id.MAX_ID#
                                    </cfquery>
                                </cfif>
                                <cfif get_pieces.PIECE_TYPE eq 2>
                                	<cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Kaydedilen Parça Design Defaultlarda Tanımlanan Prototype  Stok ID ile ilişkilendiriliyor--->
                                        UPDATE 
                                            EZGI_DESIGN_PIECE_ROWS 
                                        SET 
                                            PIECE_RELATED_ID = #get_prototype_piece_2.PIECE_RELATED_ID#
                                        WHERE 
                                            PIECE_ROW_ID = #get_max_id.MAX_ID#
                                    </cfquery>
                                </cfif>
                                <cfif get_pieces.PIECE_TYPE eq 3>
                                	<cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Kaydedilen Parça Design Defaultlarda Tanımlanan Prototype  Stok ID ile ilişkilendiriliyor--->
                                        UPDATE 
                                            EZGI_DESIGN_PIECE_ROWS 
                                        SET 
                                            PIECE_RELATED_ID = #get_prototype_piece_3.PIECE_RELATED_ID#
                                        WHERE 
                                            PIECE_ROW_ID = #get_max_id.MAX_ID#
                                    </cfquery>
                                </cfif>
                            </cfif>
                        </cfif>
						<cfif get_operations.recordcount> <!---Eğer Operasyon Gelmişse --->
                            <cfloop query="get_operations"> <!---Operasyonlar Kaydediliyor--->
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
                                            #get_operations.OPERATION_TYPE_ID#, 
                                            #get_operations.currentrow#,
                                            #FilterNum(get_operations.AMOUNT,4)#
                                        )
                                </cfquery>
                            </cfloop>
                        </cfif>
                    <cfelse> <!---Hammadde İse--->
                    	<cfquery name="get_pricate_piece_spect_main_id" datasource="#dsn3#">
                            SELECT        
                                TOP (1) SPECT_MAIN_ID
                            FROM            
                                SPECT_MAIN WITH (NOLOCK)
                            WHERE        
                                STOCK_ID = #attributes.related_stock_id# AND 
                                IS_TREE = 1
                            ORDER BY 
                                SPECT_MAIN_ID DESC
                        </cfquery>
                        <cfif get_pricate_piece_spect_main_id.recordcount>
                        	<cfquery name="upd_piece" datasource="#dsn3#">
                            	UPDATE     
                                	EZGI_DESIGN_PIECE_ROWS 
								SET                
                                	PIECE_SPECT_RELATED_ID = #get_pricate_piece_spect_main_id.SPECT_MAIN_ID#
								WHERE        
                                	PIECE_ROW_ID = #get_max_id.MAX_ID#
                            </cfquery>
                        </cfif>
                    </cfif>
                </cfloop>
            <cfelse>
            	Kaydedilecek Parça Bulunamadı
                <cfdump var="#get_pieces#">
                <cfabort>
            </cfif>
        </cfloop>
<cfelse>
	İmalat Dosyası Yok veya İçinde Modül Yok
	<cfdump var="#get_kitchen_package_row_id#">
	<cfabort>
</cfif>