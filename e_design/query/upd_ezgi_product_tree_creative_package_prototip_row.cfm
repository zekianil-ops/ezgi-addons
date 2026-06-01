<!---
    File: upd_ezgi_product_tree_creative_package_prototip_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfset attributes.piece_name_type = 1>
<cfquery name="get_default" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_DEFAULTS
</cfquery>
<cfset GET_DEFAULT_EBATLAMA.OPERATION_TYPE_ID = get_default.DEFAULT_CUTTING_OPERATION_TYPE_ID>
<cfset attributes.PVC_FIRE_AMOUNT = get_default.DEFAULT_PVC_FIRE_AMOUNT>
<cfset attributes.yonga_levha_fire_rate = get_default.DEFAULT_YONGA_LEVHA_FIRE_RATE>
<cfquery name="get_prototip_pieces" datasource="#dsn3#"> <!---Sanal Teklifte Belirtilen Özellikler Aranıyor--->
	SELECT        
    	EVOD.LAST_AMOUNT MIKTARI, 
        EVOD.AMOUNT QUANTITY,
        EVOD.PIECE_TYPE, 
        EVOD.PIECE_ROW_ID, 
        EVOD.STOCK_ID,
        EDPR.PIECE_CODE, 
        EDPR.PIECE_NAME,
        EVOD.DESIGN_EN, 
        EVOD.DESIGN_BOY
	FROM            
    	EZGI_DESIGN_PIECE_ROWS AS EDPR WITH (NOLOCK) INNER JOIN
     	EZGI_VIRTUAL_OFFER_ROW_DETAIL AS EVOD WITH (NOLOCK) ON EDPR.PIECE_ROW_ID = EVOD.PIECE_ROW_ID
	WHERE        
    	EDPR.DESIGN_MAIN_ROW_ID =
                             	(
                                	SELECT        
                                   		MAIN_PROTOTIP_ID
                               		FROM         
                                    	EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
                               		WHERE        
                                    	DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID#
                               	) AND 
   		EVOD.EZGI_ID =
                   	(
                    	SELECT        
                        	EVOR.EZGI_ID
                    	FROM            
                      		EZGI_DESIGN_MAIN_ROW AS EDMR WITH (NOLOCK) INNER JOIN
                        	EZGI_VIRTUAL_OFFER_ROW AS EVOR WITH (NOLOCK) ON EDMR.WRK_ROW_RELATION_ID = EVOR.WRK_ROW_RELATION_ID
                    	WHERE        
                        	EDMR.DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID#
                  	)
</cfquery>
<!---<cfdump var="#get_prototip_pieces#"><cfabort>--->
<Cfif get_prototip_pieces.recordcount><!--- Eğer Bulunduysa--->
	<cfloop query="get_prototip_pieces"> <!---Parçalar Döndürülüyor--->
    	<cfif PIECE_TYPE eq 4> <!---Eğer Hammadde İse--->
        	<cfquery name="GET_NEW_PIECE" datasource="#DSN3#"> <!---Sanal Teklifte Belirtilen Parça Bulunuyor--->
            	SELECT        
                	EDPR.PIECE_ROW_ID,
                    DESIGN_PACKAGE_ROW_ID
				FROM            
               		EZGI_DESIGN_MAIN_ROW AS EDMR WITH (NOLOCK) INNER JOIN
                  	EZGI_DESIGN_PIECE_ROWS AS EDPR WITH (NOLOCK) ON EDMR.DESIGN_MAIN_ROW_ID = EDPR.DESIGN_MAIN_ROW_ID
				WHERE        
                	EDMR.DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID# AND 
                    EDPR.PIECE_NAME = '#get_prototip_pieces.PIECE_NAME#' AND 
                    EDPR.PIECE_CODE = '#get_prototip_pieces.PIECE_CODE#' AND 
                    EDPR.PIECE_TYPE = 4
            </cfquery>
            <cfif get_prototip_pieces.MIKTARI eq 0> <!---Eğer Sanal Teklifte Miktar 0 verilmişse Hammadde Parçası Özel Mob. Tasarımdan Siliniyor--->
            	<cfquery name="delete_piece_row" datasource="#dsn3#">
                	DELETE FROM EZGI_DESIGN_PIECE_ROWS WHERE PIECE_ROW_ID = #get_new_piece.PIECE_ROW_ID#
              	</cfquery>
           	<cfelse> <!---Eğer Sanal Teklifte Miktar 0 san büyükse Hammadde Parçası Özel Mob. Tasarımda Düzenleniyor--->
            	<cfif not len(get_prototip_pieces.MIKTARI)>
                	Sanal Teklif Güncellemesi Yapınız
                	<cfabort>
                </cfif>
				<cfif get_new_piece.recordcount eq 1>
                	<cfif get_prototip_pieces.STOCK_ID neq get_prototip_pieces.PIECE_ROW_ID> 
                        <cfquery name="get_stock_name" datasource="#dsn3#"> <!---Sanal Teklifte Hammadde Değişmiş ise Değişen hammaddenin adı alınıyor--->
                            SELECT PRODUCT_NAME,STOCK_ID FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_prototip_pieces.STOCK_ID#
                        </cfquery>
                   	<cfelse>
                    	<cfquery name="get_stock_name" datasource="#dsn3#"> <!---Sanal Teklifte Hammadde aynı ise hammaddenin adı alınıyor--->
                            SELECT 
                            	PIECE_NAME PRODUCT_NAME, 
                                PIECE_RELATED_ID STOCK_ID
                           	FROM 
                            	EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
                           	WHERE 
                            	PIECE_ROW_ID = #get_prototip_pieces.PIECE_ROW_ID#
                        </cfquery>
                    </cfif>
                    <cfset rawmaterial_detail = ''> <!---Sanal Teklifte Hammaddeye Ölçü verildiyse Hammadde Detayına Değer atanıyor--->
                    <cfif len(get_prototip_pieces.DESIGN_BOY)>
                    	<cfset rawmaterial_detail = '#get_prototip_pieces.DESIGN_BOY#X'>
                    </cfif>
                    <cfif len(get_prototip_pieces.DESIGN_EN)>
                    	<cfset rawmaterial_detail = '#rawmaterial_detail##get_prototip_pieces.DESIGN_EN#'>
                    </cfif>
                    <cfquery name="upd_new_piece" datasource="#dsn3#"><!---Hammaddenin Özel Mobilya Tasarımda Güncellemesi Yapılıyor--->
                        UPDATE       
                            EZGI_DESIGN_PIECE_ROWS
                        SET                
                            PIECE_NAME ='#get_stock_name.PRODUCT_NAME#', 
                            PIECE_RELATED_ID = #get_stock_name.STOCK_ID#,
                            PIECE_AMOUNT = #get_prototip_pieces.MIKTARI#, 
                            PIECE_DETAIL = '#rawmaterial_detail#',
                            AGIRLIK = #get_prototip_pieces.QUANTITY#
                        WHERE        
                            PIECE_ROW_ID = #get_new_piece.PIECE_ROW_ID#
                    </cfquery>
                <cfelse>
                    <cfdump var="#GET_NEW_PIECE#">
                    Hammadde Burada Hata Var<cfabort>
                </cfif>
            </cfif>
        <cfelse> <!---Hammadde Değilse--->
        	<cfquery name="GET_NEW_PIECE" datasource="#DSN3#"> <!---Sanal Tekliften gelen Parçanın Özel Mobilya Tasarımdaki ID si bulunuyor --->
        		SELECT       
                	 EDPR.PIECE_ROW_ID,
                     DESIGN_PACKAGE_ROW_ID,
                     EDPR.PIECE_NAME,
                     EDPR.PIECE_CODE
				FROM            
                	EZGI_DESIGN_MAIN_ROW AS EDMR WITH (NOLOCK) INNER JOIN
                   	EZGI_DESIGN_PIECE_ROWS AS EDPR WITH (NOLOCK) ON EDMR.DESIGN_MAIN_ROW_ID = EDPR.DESIGN_MAIN_ROW_ID
				WHERE        
                	EDMR.DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID# AND 
                    EDPR.PIECE_CODE = '#get_prototip_pieces.PIECE_CODE#' AND 
                    EDPR.PIECE_TYPE = #get_prototip_pieces.PIECE_TYPE#
           	</cfquery>
            
            <cfif get_new_piece.recordcount eq 1> <!---Eğer Doğru Kayıt Bulunduysa--->
            	<cfquery name="get_piece_info" datasource="#dsn3#"> <!---Bulunan Parçanın Bilgileri Alınıyor--->
                	SELECT * FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) WHERE PIECE_ROW_ID = #GET_NEW_PIECE.PIECE_ROW_ID#
                </cfquery>
               
                <cfif get_piece_info.PIECE_TYPE eq get_prototip_pieces.PIECE_TYPE> <!---Sanal Teklifteki Seçilen Parça Tipi Özel Tasarımdakiyle aynı ise--->
                	<cfif get_piece_info.PIECE_ROW_ID eq get_prototip_pieces.STOCK_ID> <!---Sanal Teklifteki Seçilen Parça İle Özel Tasarımdaki Parça aynı ise--->
                        <cfquery name="get_piece_row_info" datasource="#dsn3#">
                            SELECT * FROM EZGI_DESIGN_PIECE_ROW WITH (NOLOCK) WHERE PIECE_ROW_ID = #GET_NEW_PIECE.PIECE_ROW_ID#
                        </cfquery>
                        
                   	<cfelse><!---Sanal Teklifteki Seçilen Parça Tipi Özel Tasarımdakiyle Farklı İse--->
                    	<cfquery name="get_piece_info" datasource="#dsn3#"> <!---Değişen Parçanın Bilgileri Alınıyor--->
                            SELECT * FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) WHERE PIECE_ROW_ID = #get_prototip_pieces.STOCK_ID#

                        </cfquery>

                        <cfif get_piece_info.recordcount neq 1>
                        	<cfdump var="#get_piece_info#">
                            Sanal Teklifte <cfoutput>#get_piece_info.PIECE_NAME#</cfoutput> Parçasına Karşılık Seçilen Üründe Sorun Var
                        	<cfabort>
                        </cfif>
                        <cfquery name="get_piece_row_info" datasource="#dsn3#">
                            SELECT * FROM EZGI_DESIGN_PIECE_ROW WITH (NOLOCK) WHERE PIECE_ROW_ID = #get_prototip_pieces.STOCK_ID#
                        </cfquery>
                   	</cfif>    
                   	<cfset attributes.design_piece_row_id = get_new_piece.PIECE_ROW_ID>
					<cfset attributes.COLOR_TYPE = get_piece_info.PIECE_COLOR_ID>
                 	<cfset attributes.DEFAULT_TYPE = get_piece_info.MASTER_PRODUCT_ID>
                   	<cfset attributes.trim_type = get_piece_info.TRIM_TYPE>
                  	<cfset attributes.trim_rate = TlFormat(get_piece_info.TRIM_SIZE,1)>
                  	<cfset attributes.PIECE_SU_YONU = get_piece_info.IS_FLOW_DIRECTION>
                   	<cfset attributes.piece_package_floor_no = get_piece_info.PIECE_FLOOR>
                    <cfset attributes.piece_package_rota = get_piece_info.PIECE_PACKAGE_ROTA>
                  	<cfset attributes.PIECE_KALINLIK = get_piece_info.KALINLIK>
                  	
                  	<cfset attributes.PIECE_TYPE = get_piece_info.PIECE_TYPE>
                    <cfif attributes.piece_name_type eq 1>
                    	<cfset attributes.DESIGN_NAME_PIECE_ROW = get_new_piece.PIECE_NAME>
                        <cfset attributes.DESIGN_CODE_PIECE_ROW = get_new_piece.PIECE_CODE>
                    <cfelse>
                   		<cfset attributes.DESIGN_NAME_PIECE_ROW = get_piece_info.PIECE_NAME>
                        <cfset attributes.DESIGN_CODE_PIECE_ROW = get_piece_info.PIECE_CODE>
                    </cfif>
                   	<cfset attributes.piece_package_no = get_new_piece.DESIGN_PACKAGE_ROW_ID>
                   	<cfset attributes.piece_detail = ''>
                    
                    <cfset attributes.PIECE_BOY = get_prototip_pieces.DESIGN_BOY>
                 	<cfset attributes.PIECE_EN = get_prototip_pieces.DESIGN_EN>
                 	<cfset attributes.PIECE_AMOUNT = TlFormat(get_prototip_pieces.MIKTARI,4)>
                    
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
                    
                    <cfinclude template="upd_ezgi_product_tree_creative_piece_row_insert.cfm"> <!---Güncelleme Sorgusuna Gidiyor--->
              	<cfelse>
                	<cfoutput>#get_prototip_pieces.PIECE_NAME#</cfoutput> Parçasına Karşılık Seçilen Parçanın Parça Tipi Farklıdır.
                	<cfabort>
             	</cfif>
            <cfelse>
            	<cfdump var="#GET_NEW_PIECE#">
            	Parça İşlemi Burada Hata Var<cfabort>
            </cfif>
        </cfif>
    </cfloop>
</Cfif>
