<!---
    File: upd_ezgi_default_color.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 
<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK) WHERE COLOR_ID = #attributes.color_id#
</cfquery>
<cfquery name="get_thickness" datasource="#dsn3#">
	SELECT THICKNESS_ID, THICKNESS_VALUE, THICKNESS_NAME, UNIT, THICKNESS_PLUS_VALUE FROM EZGI_THICKNESS WITH (NOLOCK) WHERE IS_ACTIVE = 1 ORDER BY THICKNESS_NAME
</cfquery>
<cfquery name="get_thickness_ext" datasource="#dsn3#">
	SELECT THICKNESS_ID, THICKNESS_VALUE, THICKNESS_PRODUCT_NAME, UNIT FROM EZGI_THICKNESS_EXT WITH (NOLOCK) WHERE IS_ACTIVE = 1 ORDER BY THICKNESS_NAME
</cfquery>
<cfquery name="get_stock_info" datasource="#dsn3#">
	SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #attributes.STOCK_ID#
</cfquery>
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfif not get_defaults.recordcount or not len(get_defaults.DEFAULT_COLOR_PROPERTY_ID) or not len(get_defaults.DEFAULT_THICKNESS_PROPERTY_ID) or not len(get_defaults.DEFAULT_THICKNESS_EXT_PROPERTY_ID)>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='975.Önce Tasarım Genel Default Bilgilerini Tanımlayınız!'> ")
		window.history.go(-1);
	</script>	
</cfif>
<!---Renk Özel Kodu Kontrol İşlemi--->
<cfif isdefined('attributes.special_code') and len(attributes.special_code)> <!---Renk Özel Kodu Tanımlanmamışsa--->
	<cfif attributes.special_code neq attributes.old_special_code> <!---Renk Özel Kodu Değişmiş İse--->
    	<cfquery name="get_color_code" datasource="#dsn3#">
        	SELECT COLOR_NAME,PROP_CODE FROM EZGI_COLORS WITH (NOLOCK) WHERE PROP_CODE = '#attributes.special_code#'
        </cfquery>
        <cfif get_color_code.recordcount> <!---Değişen Özel Kod Kayıtlarda var mı--->
        	<script type="text/javascript">
				alert('<cf_get_lang dictionary_id='199.Renk'>: <cfoutput>#get_color_code.COLOR_NAME#</cfoutput> <cf_get_lang dictionary_id='994.Girilen Renk Kodu Bu Renkte Tanımlıdır. Değiştiriniz!'>')
				window.history.go(-1);
			</script>
        </cfif>
	</cfif>
<cfelse>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='976.Zorunlu Alan - Renk Kodu Tanımlayınız!'>")
		window.history.go(-1);
	</script>
    <cfabort>
</cfif>
<!---Renk Özel Kodu Kontrol İşlemi--->

<!---Renk Kodu Kontrol İşlemi--->
<cfif isdefined('attributes.default_code') and len(attributes.default_code)> <!---Renk Kodu Tanımlanmamışsa--->
	<cfif attributes.default_code neq attributes.old_default_code> <!---Renk Kodu Değişmiş İse--->
    	<cfquery name="get_color_code" datasource="#dsn3#">
        	SELECT COLOR_NAME,PROPERTY_DETAIL_CODE FROM EZGI_COLORS WITH (NOLOCK) WHERE PROPERTY_DETAIL_CODE = '#attributes.default_code#'
        </cfquery>
        <cfif get_color_code.recordcount> <!---Değişen Kod Kayıtlarda var mı--->
        	<script type="text/javascript">
				alert('<cf_get_lang dictionary_id='199.Renk'>: <cfoutput>#get_color_code.COLOR_NAME#</cfoutput> <cf_get_lang dictionary_id='994.Girilen Renk Kodu Bu Renkte Tanımlıdır. Değiştiriniz!'>')
				window.history.go(-1);
			</script>
        <cfelse>
			<cfif get_thickness.recordcount>
                <cfoutput query="get_thickness">
                    <cfif Evaluate('attributes.YONGA_LEVHA_STOCK_ID_#THICKNESS_ID#') gt 0> <!---Yonga Levha Tanımlanmış mı--->
                        <script type="text/javascript">
                            alert('<cf_get_lang dictionary_id='62.Yonga Levha'> : #Evaluate('attributes.YONGA_LEVHA_PRODUCT_NAME_#THICKNESS_ID#')# <cf_get_lang dictionary_id='995.Bu Levha Tanımlandığından, Renk Kodu Değiştirilemez!'>')
                            window.history.go(-1);
                        </script>
                        <cfabort>
                    </cfif>
                	<cfif get_thickness_ext.recordcount>
						<cfloop query="get_thickness_ext">
                        	 <cfif Evaluate('attributes.PVC_STOCK_ID_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#') gt 0><!---PVC Levha Tanımlanmış mı--->
                             	<script type="text/javascript">
									alert('#Evaluate('attributes.PVC_PRODUCT_NAME_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#')# <cf_get_lang dictionary_id='996.Tanımlandığından, Renk Kodu Değiştirilemez!'>')
									window.history.go(-1);
								</script>
								<cfabort>
                             </cfif>
                        </cfloop>
					</cfif>
				</cfoutput>
            </cfif>
        </cfif>
	</cfif>
<cfelse>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='976.Zorunlu Alan - Renk Kodu Tanımlayınız!'>")
		window.history.go(-1);
	</script>
    <cfabort>
</cfif>
<!---Renk Kodu Kontrol İşlemi--->

<!---Renk Adı Kontrol İşlemi--->
<cfset color_name_change = 0>
<cfif isdefined('attributes.default_name') and len(attributes.default_name)> <!---Renk Adı Tanımlanmamışsa--->
	<cfif attributes.default_name neq attributes.old_default_name> <!---Renk Adı Değişmiş İse--->
    	<cfquery name="get_color_name" datasource="#dsn3#">
        	SELECT COLOR_NAME FROM EZGI_COLORS WITH (NOLOCK) WHERE COLOR_NAME = '#attributes.default_name#'
        </cfquery>
        <cfif get_color_name.recordcount> <!---Değişen Kod Kayıtlarda var mı--->
        	<script type="text/javascript">
				alert("<cf_get_lang dictionary_id='977.Girilen Renk Adı Tanımlıdır. Değiştiriniz!'>")
				window.history.go(-1);
			</script>
        <cfelse>
			<cfif get_thickness.recordcount>
                <cfoutput query="get_thickness">
                    <cfif Evaluate('attributes.YONGA_LEVHA_STOCK_ID_#THICKNESS_ID#') gt 0> <!---Yonga Levha Tanımlanmış mı--->
                    	<cfset color_name_change = 1>
                    </cfif>
                	<cfif get_thickness_ext.recordcount>
						<cfloop query="get_thickness_ext">
                        	 <cfif Evaluate('attributes.PVC_STOCK_ID_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#') gt 0><!---PVC Levha Tanımlanmış mı--->
                             	<cfset color_name_change = 1>
                             </cfif>
                        </cfloop>
					</cfif>
				</cfoutput>
            </cfif>
        </cfif>
	</cfif>
<cfelse>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='976.Zorunlu Alan - Renk Kodu Tanımlayınız!'>")
		window.history.go(-1);
	</script>
    <cfabort>
</cfif>
<cfif color_name_change eq 1> <!---Eğer Yonga Levha ve PVC tanımlanmışsa Tasarım Başlamış Olabilir--->
	<cfquery name="get_workcube_product_relation_control" datasource="#dsn3#"> <!---Tasarımdaki Paket ve Modüller Workcube Transfer Edilmiş mi?--->
     	SELECT       	
         	E.DESIGN_MAIN_NAME
		FROM            
        	EZGI_DESIGN_MAIN_ROW AS E WITH (NOLOCK) INNER JOIN
          	#dsn1_alias#.STOCKS AS S WITH (NOLOCK) ON E.DESIGN_MAIN_RELATED_ID = S.STOCK_ID
		WHERE        
         	E.DESIGN_MAIN_NAME LIKE N'%#attributes.old_default_name#%' AND 
          	NOT (S.STOCK_ID IS NULL)
    	UNION ALL
    	SELECT        
        	EZGI_DESIGN_PACKAGE_ROW.PACKAGE_NAME as DESIGN_MAIN_NAME
		FROM            
       		#dsn1_alias#.STOCKS AS S WITH (NOLOCK) INNER JOIN
     		EZGI_DESIGN_PACKAGE_ROW WITH (NOLOCK) ON S.STOCK_ID = EZGI_DESIGN_PACKAGE_ROW.PACKAGE_RELATED_ID
		WHERE        
        	EZGI_DESIGN_PACKAGE_ROW.PACKAGE_NAME LIKE N'%#attributes.old_default_name#%' AND 
       		NOT (S.STOCK_ID IS NULL)
 	</cfquery>
  	<cfif get_workcube_product_relation_control.recordcount>
       	<script type="text/javascript">
			alert('<cf_get_lang dictionary_id='43440.Tasarım Adı'>: <cfoutput>#get_workcube_product_relation_control.DESIGN_MAIN_NAME#</cfoutput> <cf_get_lang dictionary_id='1017.Bu Tasarım İçin Ürün Kartı Açıldığından, İlgili Ürünleri Güncelleyin!'>')
			<!---window.history.go(-1);--->
		</script>
     	<!---<cfabort>--->
  	</cfif>
</cfif>
<!---Renk Adı Kontrol İşlemi--->

<!---Master Ürün Kontrol İşlemi--->
<cfif (isdefined('attributes.stock_id') and attributes.stock_id gt 0) and len(attributes.urun)> <!---Master Ürün Tanımlanmamışsa--->
	<cfif attributes.stock_id neq attributes.old_stock_id> <!---Master Ürün Değişmiş İse--->
    	<cfif get_thickness.recordcount>
        	<cfoutput query="get_thickness">
            	<cfif Evaluate('attributes.YONGA_LEVHA_STOCK_ID_#THICKNESS_ID#') gt 0> <!---Yonga Levha Tanımlanmış mı--->
                	<script type="text/javascript">
						alert('<cf_get_lang dictionary_id='62.Yonga Levha'> :#Evaluate('attributes.YONGA_LEVHA_PRODUCT_NAME_#THICKNESS_ID#')# <cf_get_lang dictionary_id='997.Bu Levha Tanımlandığından, Master Ürün Değiştirilemez!'> ')
						window.history.go(-1);
					</script>
					<cfabort>
                </cfif>
            </cfoutput>
        </cfif>
	</cfif>
<cfelse>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='978.Zorunlu Alan - Master Ürün Tanımlayınız!'>")
		window.history.go(-1);
	</script>
    <cfabort>
</cfif>
<!---Master Ürün Kontrol İşlemi--->

<!---Yonga Levha Kontrol İşlemi--->
<cfif get_thickness.recordcount>
 	<cfoutput query="get_thickness">
    	<cfif Evaluate('attributes.YONGA_LEVHA_THICKNESS_ID_#THICKNESS_ID#') eq 1> <!---Renge Yeni Yonga Levha Ekleme--->
        	<cfquery name="get_yonga_levha_name_control" datasource="#dsn1#">
            	SELECT        
                	PRODUCT_CODE, 
                    PRODUCT_NAME
				FROM            
                	PRODUCT WITH (NOLOCK)
				WHERE        
                	PRODUCT_NAME = '#Evaluate('attributes.YONGA_LEVHA_PRODUCT_NAME_#THICKNESS_ID#')#'
            </cfquery>
            <cfif get_yonga_levha_name_control.recordcount>
            	<cfloop query="get_yonga_levha_name_control">
                	<script type="text/javascript">
						alert('<cf_get_lang dictionary_id='57657.Ürün'>: #get_yonga_levha_name_control.PRODUCT_NAME# <cf_get_lang dictionary_id='58800.Ürün Kodu'>: #get_yonga_levha_name_control.PRODUCT_CODE# <cf_get_lang dictionary_id='998.Yeni girilen Ürün Bu Ürün Kodu ile Kayıtlı Olduğundan Yeni Yonga Levha Ürünü Ekleme Yapılamaz!'> ')
						window.history.go(-1);
					</script>
                    <cfabort>
                </cfloop>
            </cfif>
     	<cfelseif Evaluate('attributes.YONGA_LEVHA_THICKNESS_ID_#THICKNESS_ID#') eq 3>  <!---Renkten Varolan Yonga Levha Silme Kontrolü--->
            <cfquery name="get_yonga_levha_control" datasource="#dsn3#">
            	SELECT        
                	D.DESIGN_NAME + ' ' + C.COLOR_NAME + ' ' + E.PIECE_NAME AS PARCA
				FROM            
                	EZGI_DESIGN_PIECE_ROW AS R WITH (NOLOCK) INNER JOIN
                 	EZGI_DESIGN_PIECE AS E WITH (NOLOCK) ON R.PIECE_ROW_ID = E.PIECE_ROW_ID INNER JOIN
                   	EZGI_DESIGN AS D WITH (NOLOCK) ON E.DESIGN_ID = D.DESIGN_ID INNER JOIN
                  	EZGI_COLORS AS C WITH (NOLOCK) ON E.PIECE_COLOR_ID = C.COLOR_ID
				WHERE        
                 	R.STOCK_ID = #Evaluate('attributes.YONGA_LEVHA_STOCK_ID_#THICKNESS_ID#')#
        	</cfquery>
        	<cfif get_yonga_levha_control.recordcount>
            	<cfloop query="get_yonga_levha_control">
                	<script type="text/javascript">
						alert('<cf_get_lang dictionary_id='45.Parça'>: #get_yonga_levha_control.PARCA# <cf_get_lang dictionary_id='1016.Bunun Tasarımında Kullanıldığından Silme İşlemi Yapamazsınız!'>')
						window.history.go(-1);
					</script>
                    <cfabort>
            	</cfloop>
         	</cfif>    
     	</cfif>
  	</cfoutput>
</cfif>
<!---Yonga Levha Kontrol İşlemi--->

<!---PVC Kontrol İşlemi--->
<cfif get_thickness.recordcount>
 	<cfoutput query="get_thickness">
    	<cfloop query="get_thickness_ext">
			<cfif Evaluate('attributes.PVC_THICKNESS_ID_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#') eq 1> <!---Renge Yeni PVC Ekleme--->
                <cfquery name="get_PVC_name_control" datasource="#dsn1#">
                    SELECT        
                        PRODUCT_CODE, PRODUCT_NAME
                    FROM            
                        PRODUCT WITH (NOLOCK)
                    WHERE        
                        PRODUCT_NAME = '#Evaluate('attributes.PVC_PRODUCT_NAME_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#')#'
                </cfquery>
                <cfif get_PVC_name_control.recordcount>
                    <cfloop query="get_PVC_name_control">
                        <script type="text/javascript">
                            alert('<cf_get_lang dictionary_id='57657.Ürün'>: #get_PVC_name_control.PRODUCT_NAME# <cf_get_lang dictionary_id='58800.Ürün Kodu'>: #get_PVC_name_control.PRODUCT_CODE# <cf_get_lang dictionary_id='999.Girmek İstediğiniz Ürün Bu Ürün Kodu ile Kayıtlı Olduğundan Yeni PVC Ürünü Ekleme Yapılamaz!'>')
                            window.history.go(-1);
                        </script>
                        <cfabort>
                    </cfloop>
                </cfif>
            <cfelseif Evaluate('attributes.PVC_THICKNESS_ID_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#') eq 3>  <!---Renkten Varolan PVC Silme Kontrolü--->
                <cfquery name="get_PVC_control" datasource="#dsn3#">
                    SELECT        
                        D.DESIGN_NAME + ' ' + C.COLOR_NAME + ' ' + E.PIECE_NAME AS PARCA
                    FROM            
                        EZGI_DESIGN_PIECE_ROW AS R WITH (NOLOCK) INNER JOIN
                        EZGI_DESIGN_PIECE AS E WITH (NOLOCK) ON R.PIECE_ROW_ID = E.PIECE_ROW_ID INNER JOIN
                        EZGI_DESIGN AS D WITH (NOLOCK) ON E.DESIGN_ID = D.DESIGN_ID INNER JOIN
                        EZGI_COLORS AS C WITH (NOLOCK) ON E.PIECE_COLOR_ID = C.COLOR_ID
                    WHERE        
                        R.STOCK_ID = #Evaluate('attributes.PVC_STOCK_ID_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#')#
                </cfquery>
                <cfif get_PVC_control.recordcount>
                    <cfloop query="get_PVC_control">
                        <script type="text/javascript">
                            alert('<cf_get_lang dictionary_id='45.Parça'>: #get_PVC_control.PARCA# <cf_get_lang dictionary_id='1016.Bunun Tasarımında Kullanıldığından Silme İşlemi Yapamazsınız!'>')
                            window.history.go(-1);
                        </script>
                        <cfabort>
                    </cfloop>
                </cfif>    
            </cfif>
        </cfloop>
  	</cfoutput>
</cfif>
<!---PVC Kontrol İşlemi--->


<!---<cftransaction>--->
	<!---Yonga Levha İşlemi--->
	<cfif get_thickness.recordcount>
        <cfoutput query="get_thickness">
            <cfif Evaluate('attributes.YONGA_LEVHA_THICKNESS_ID_#THICKNESS_ID#') eq 1> <!---Renge Yeni Yonga Levha Ekleme--->
                <cfinclude template="add_ezgi_yonga_levha_import_process.cfm"> 
            <cfelseif Evaluate('attributes.YONGA_LEVHA_THICKNESS_ID_#THICKNESS_ID#') eq 2> <!---Renkte Varolan Yonga Levha Değişmedi--->
                
            <cfelseif Evaluate('attributes.YONGA_LEVHA_THICKNESS_ID_#THICKNESS_ID#') eq 3> <!---Renkten Varolan Yonga Levha Silme--->
            	<cfquery name="get_product_id" datasource="#dsn1#">
                 	SELECT PRODUCT_ID FROM STOCKS WHERE STOCK_ID =  #Evaluate('attributes.YONGA_LEVHA_STOCK_ID_#THICKNESS_ID#')#
             	</cfquery>
                <cfquery name="del_yonga_levha_related" datasource="#dsn1#">
                	DELETE FROM 
                    	PRODUCT_DT_PROPERTIES 
                   	WHERE 
                    	PRODUCT_ID = #get_product_id.PRODUCT_ID# AND 
                    	(VARIATION_ID = #attributes.COLOR_ID# OR VARIATION_ID = #THICKNESS_ID#)
                </cfquery>
            <cfelseif Evaluate('attributes.YONGA_LEVHA_THICKNESS_ID_#THICKNESS_ID#') eq 0> <!---Renge Varolan Yonga Levha Ekleme Olabilir--->
                <cfif Evaluate('attributes.YONGA_LEVHA_STOCK_ID_#THICKNESS_ID#') gt 0> <!---Renge Varolan Yonga Levha Ekleme --->
                	<cfquery name="get_product_id" datasource="#dsn1#">
                    	SELECT PRODUCT_ID FROM STOCKS WHERE STOCK_ID =  #Evaluate('attributes.YONGA_LEVHA_STOCK_ID_#THICKNESS_ID#')#
                    </cfquery>
                    <cfquery name="add_yonga_levha_related_1" datasource="#dsn1#">
                    	INSERT INTO 
                        	PRODUCT_DT_PROPERTIES
                         	(
                            PRODUCT_ID, 
                            PROPERTY_ID, 
                            VARIATION_ID, 
                            LINE_VALUE, 
                            AMOUNT, 
                            IS_OPTIONAL, 
                            IS_EXIT, 
                            IS_INTERNET, 
                            RECORD_DATE,
                            RECORD_IP,
                            RECORD_EMP 
                            )
						VALUES        
                        	(
                            #get_product_id.PRODUCT_ID#,
                            #get_defaults.DEFAULT_COLOR_PROPERTY_ID#,
                            #attributes.color_id#,
                            1,
                            0,
                            0,
                            0,
                            0,
                            #now()#,
                            '#CGI.REMOTE_ADDR#',
                            #session.ep.userid#
                            )
                    </cfquery>
                    <cfquery name="add_yonga_levha_related_2" datasource="#dsn1#">
                    	INSERT INTO 
                        	PRODUCT_DT_PROPERTIES
                         	(
                            PRODUCT_ID, 
                            PROPERTY_ID, 
                            VARIATION_ID, 
                            LINE_VALUE, 
                            AMOUNT, 
                            IS_OPTIONAL, 
                            IS_EXIT, 
                            IS_INTERNET, 
                            RECORD_DATE,
                            RECORD_IP,
                            RECORD_EMP 
                            )
						VALUES        
                        	(
                            #get_product_id.PRODUCT_ID#,
                            #get_defaults.DEFAULT_THICKNESS_PROPERTY_ID#,
                            #THICKNESS_ID#,
                            2,
                            0,
                            0,
                            0,
                            0,
                            #now()#,
                            '#CGI.REMOTE_ADDR#',
                            #session.ep.userid#
                            )
                    </cfquery>
                </cfif>
            </cfif>
        </cfoutput>
    </cfif>
    <!---Yonga Levha İşlemi--->
    
    <!---PVC İşlemi--->
    <cfif get_thickness.recordcount>
 		<cfoutput query="get_thickness">
    		<cfloop query="get_thickness_ext">
				<cfif Evaluate('attributes.PVC_THICKNESS_ID_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#') eq 1> <!---Renge Yeni PVC Ekleme--->
                	<cfinclude template="add_ezgi_pvc_import_process.cfm"> 
                <cfelseif Evaluate('attributes.PVC_THICKNESS_ID_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#') eq 2>  <!----Renkte Varolan PVC Değişmedi--->
                
                <cfelseif Evaluate('attributes.PVC_THICKNESS_ID_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#') eq 3>  <!----Renkten Varolan PVC Silme--->
                	<cfquery name="get_product_id" datasource="#dsn1#">
                    	SELECT PRODUCT_ID FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID =  #Evaluate('attributes.PVC_STOCK_ID_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#')#
                 	</cfquery>
                	<cfquery name="del_pvc_related" datasource="#dsn1#">
                        DELETE FROM 
                            PRODUCT_DT_PROPERTIES 
                        WHERE 
                        	PRODUCT_ID = #get_product_id.PRODUCT_ID# AND 
                            (VARIATION_ID = #attributes.COLOR_ID# OR VARIATION_ID = #get_thickness.THICKNESS_ID# OR VARIATION_ID = #get_thickness_ext.THICKNESS_ID#)
                    </cfquery>
                <cfelseif Evaluate('attributes.PVC_THICKNESS_ID_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#') eq 0> <!---Renge Varolan PVC Ekleme Olabilir--->
                	<cfif Evaluate('attributes.PVC_STOCK_ID_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#') gt 0> <!---Renge Varolan PVC Ekleme --->
                    	<cfquery name="get_product_id" datasource="#dsn1#">
                    		SELECT PRODUCT_ID FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID =  #Evaluate('attributes.PVC_STOCK_ID_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#')#
                    	</cfquery>
                    	<cfquery name="add_pvc_related_1" datasource="#dsn1#">
                            INSERT INTO 
                                PRODUCT_DT_PROPERTIES
                                (
                                PRODUCT_ID, 
                                PROPERTY_ID, 
                                VARIATION_ID, 
                                LINE_VALUE, 
                                AMOUNT, 
                                IS_OPTIONAL, 
                                IS_EXIT, 
                                IS_INTERNET, 
                                RECORD_DATE,
                                RECORD_IP,
                                RECORD_EMP 
                                )
                            VALUES        
                                (
                                #get_product_id.PRODUCT_ID#,
                                #get_defaults.DEFAULT_COLOR_PROPERTY_ID#,
                                #attributes.color_id#,
                                1,
                                0,
                                0,
                                0,
                                0,
                                #now()#,
                                '#CGI.REMOTE_ADDR#',
                                #session.ep.userid#
                                )
                        </cfquery>
                        <cfquery name="add_pvc_related_2" datasource="#dsn1#">
                            INSERT INTO 
                                PRODUCT_DT_PROPERTIES
                                (
                                PRODUCT_ID, 
                                PROPERTY_ID, 
                                VARIATION_ID, 
                                LINE_VALUE, 
                                AMOUNT, 
                                IS_OPTIONAL, 
                                IS_EXIT, 
                                IS_INTERNET, 
                                RECORD_DATE,
                                RECORD_IP,
                                RECORD_EMP 
                                )
                            VALUES        
                                (
                                #get_product_id.PRODUCT_ID#,
                                #get_defaults.DEFAULT_THICKNESS_PROPERTY_ID#,
                                #get_thickness.THICKNESS_ID#,
                                2,
                                0,
                                0,
                                0,
                                0,
                                #now()#,
                                '#CGI.REMOTE_ADDR#',
                                #session.ep.userid#
                                )
                        </cfquery>
                        <cfquery name="add_pvc_related_3" datasource="#dsn1#">
                            INSERT INTO 
                                PRODUCT_DT_PROPERTIES
                                (
                                PRODUCT_ID, 
                                PROPERTY_ID, 
                                VARIATION_ID, 
                                LINE_VALUE, 
                                AMOUNT, 
                                IS_OPTIONAL, 
                                IS_EXIT, 
                                IS_INTERNET, 
                                RECORD_DATE,
                                RECORD_IP,
                                RECORD_EMP 
                                )
                            VALUES        
                                (
                                #get_product_id.PRODUCT_ID#,
                                #get_defaults.DEFAULT_THICKNESS_EXT_PROPERTY_ID#,
                                #get_thickness_ext.THICKNESS_ID#,
                                3,
                                0,
                                0,
                                0,
                                0,
                                #now()#,
                                '#CGI.REMOTE_ADDR#',
                                #session.ep.userid#
                                )
                        </cfquery>
                    </cfif>
             	</cfif>
        	</cfloop>
   		</cfoutput>
  	</cfif>
    
    <!---Ürün Adının Etkilendiği Kayıtların Düzeltmesi--->
    <cfif color_name_change eq 1>
    
    	<cfquery name="get_product_id" datasource="#dsn3#">
        	SELECT        
            	PRODUCT_ID
			FROM            
            	EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK)
			WHERE        
            	COLOR_ID = #attributes.color_id#
			UNION ALL
			SELECT        
            	PT.PRODUCT_ID
			FROM            
            	EZGI_DESIGN_PRODUCT_PROPERTIES_UST AS E WITH (NOLOCK) INNER JOIN
            	PRODUCT_TREE AS PT WITH (NOLOCK) ON E.STOCK_ID = PT.STOCK_ID
			WHERE        
            	E.COLOR_ID = #attributes.color_id# AND 
                E.LIST_ORDER_NO = 1 AND 
                NOT PT.PRODUCT_ID IS NULL
        </cfquery>
        
        <cfif get_product_id.recordcount>
        	<cfset product_id_list = ValueList(get_product_id.product_id)>
            <cfquery name="upd_product_name" datasource="#dsn1#">
            	UPDATE       
                	PRODUCT
				SET                
                	PRODUCT_NAME = REPLACE(PRODUCT_NAME, '#attributes.old_default_name#', '#attributes.default_name#')
				WHERE        
                	PRODUCT_NAME LIKE N'%#attributes.old_default_name#%' AND 
                    PRODUCT_ID IN (#product_id_list#)
            </cfquery>
        </cfif>
    	<cfquery name="upd_main_row_name" datasource="#dsn3#"> <!---Modül Adları Değişimi--->
        	UPDATE 
            	EZGI_DESIGN_MAIN_ROW 
          	SET 
            	DESIGN_MAIN_NAME = REPLACE(DESIGN_MAIN_NAME, '(#attributes.old_default_name#)', '(#attributes.default_name#)')
			WHERE        
            	DESIGN_MAIN_NAME LIKE '%(#attributes.old_default_name#)%'
        </cfquery>
        <cfquery name="upd_main_row_name" datasource="#dsn3#"> <!---Paket Adları Değişimi--->
        	UPDATE       
            	EZGI_DESIGN_PACKAGE_ROW
			SET                
            	PACKAGE_NAME = REPLACE(PACKAGE_NAME, '(#attributes.old_default_name#)', '(#attributes.default_name#)')
			WHERE        
            	PACKAGE_NAME LIKE '%(#attributes.old_default_name#)%'
        </cfquery>
    	  
    </cfif>
    
    <cfquery name="upd_renk_table" datasource="#dsn1#">
     	UPDATE 
        	PRODUCT_PROPERTY_DETAIL 
      	SET 
        	IS_ACTIVE = <cfif isdefined('attributes.status') and len(attributes.status)>1<cfelse>0</cfif> ,
            IS_FLAG = <cfif isdefined('attributes.is_pattern')>1<cfelse>0</cfif>,
            RELATED_STOCK_ID = #attributes.stock_id#,
            PROPERTY_DETAIL = '#attributes.default_name#',
            PROPERTY_DETAIL_CODE = '#attributes.default_code#',
            PROP_CODE = '#attributes.special_code#'
      	WHERE 
        	PROPERTY_DETAIL_ID = #attributes.color_id#
 	</cfquery>
<!---</cftransaction>--->
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_default_color&event=upd&color_id=#attributes.color_id#" addtoken="no">

