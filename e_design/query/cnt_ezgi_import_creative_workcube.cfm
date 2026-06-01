<!---
    File: cnt_ezgi_import_creative_workcube.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 	

<cfset is_transfer = 1>
<cfset urun_type = 0>
<cfset attributes.is_configure = 1>
<cfquery name="get_barcode_defaults" datasource="#dsn3#">
 	SELECT EAN FROM EZGI_SHIPPING_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfif get_barcode_defaults.recordcount and (get_barcode_defaults.ean eq 8 or get_barcode_defaults.ean eq 13)>
	<cfset barcode_boy = get_barcode_defaults.ean-1>
	<cfif barcode_boy eq 7>
        <cfset barcode_on_taki = '1000000'>
    <cfelseif barcode_boy eq 12>
        <cfset barcode_on_taki = '100000000000'>
    </cfif>
<cfelse>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='37826.Eksik Parametre Tanımı'> : <cf_get_lang dictionary_id='813.E-Shipping Tanımları'>!");
		window.close()
	</script>
 	<cfabort>
</cfif>
<cfquery name="get_defaults" datasource="#dsn3#">
  	 SELECT * FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfquery name="get_product_cat_piece" datasource="#dsn3#">
  	SELECT HIERARCHY FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = #get_defaults.DEFAULT_PIECE_CAT_ID#
</cfquery>
<cfquery name="get_product_cat_package" datasource="#dsn3#">
  	SELECT HIERARCHY FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = #get_defaults.DEFAULT_PACKAGE_CAT_ID#
</cfquery>
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS  WITH (NOLOCK)ORDER BY COLOR_NAME
</cfquery>
<cfoutput query="get_colors">
	<cfset 'COLOR_NAME_#COLOR_ID#' = COLOR_NAME>
</cfoutput>
<cfquery name="get_design_info" datasource="#dsn3#">
	SELECT 
    	PRODUCT_CAT.HIERARCHY,
        ED.DESIGN_NAME, 
        ED.PROCESS_ID,
       	ED.PRODUCT_CATID,
        ISNULL(ED.IS_PROTOTIP,0) AS IS_PROTOTIP,
        PRODUCT_CAT.PRODUCT_CAT 
   	FROM 
    	EZGI_DESIGN AS ED WITH (NOLOCK) INNER JOIN PRODUCT_CAT WITH (NOLOCK) ON 
        ED.PRODUCT_CATID = PRODUCT_CAT.PRODUCT_CATID 
  	WHERE 
    	ED.DESIGN_ID = #attributes.design_id#
</cfquery>
<cfif Listlen(attributes.iid_list)>
  	<cfloop list="#attributes.iid_list#" index="i"> <!---Kontrol Döngüsü--->
    	<cfif isdefined('attributes.select_#i#') and len(Evaluate('attributes.select_#i#'))>
			<cfif Evaluate('attributes.upd_type_#i#') eq 2><!---Düzenleme Şekli - Ürün Ağacı İçerik Düzenleme İse--->
                <cfif isdefined('attributes.STOCK_ID_#i#')>
                    <cfif ListGetAt(i,1,'_') eq 1> <!---Parça İse--->
                        
                    <cfelseif ListGetAt(i,1,'_') eq 2> <!---Paket İse--->
                       
                    <cfelseif ListGetAt(i,1,'_') eq 3> <!---Modül İse--->
                        <cfquery name="get_stock_control" datasource="#dsn3#">
                            SELECT 
                            	DESIGN_MAIN_NAME 
                           	FROM 
                            	EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) 
                           	WHERE 
                            	DESIGN_MAIN_RELATED_ID = #Evaluate('attributes.STOCK_ID_#i#')# AND 
                                DESIGN_MAIN_ROW_ID <> #ListGetAt(i,2,'_')# AND 
                                MAIN_PROTOTIP_ID <> #ListGetAt(i,2,'_')#
                        </cfquery>
                        <cfif get_stock_control.recordcount>
                        	<br />
                            <cfoutput>#get_stock_control.DESIGN_MAIN_NAME# - Bu Modül Adı Ürün Mevcut.</cfoutput> <cfabort>
                        </cfif>
                    </cfif>
                </cfif>
            <cfelseif Evaluate('attributes.upd_type_#i#') eq 1><!---Düzenleme Şekli - Ürün Yeni Açılacak İse--->
            	<cfif ListGetAt(i,1,'_') eq 1> <!---Parça İse--->
                    <cfquery name="get_piece_all" datasource="#dsn3#">
                        SELECT        
                            E.PIECE_ROW_ID, 
                            E.PIECE_NAME, 
                            E.PIECE_CODE, 
                            E.PIECE_COLOR_ID,
                            E.PIECE_AMOUNT, 
                            E.PIECE_DETAIL,
                            ISNULL(TBL_1.AMOUNT, 0) AS USED_AMOUNT, 
                            E.DESIGN_PACKAGE_ROW_ID, 
                            E.DESIGN_MAIN_ROW_ID, 
                            E.PIECE_RELATED_ID, 
                            E.PIECE_TYPE,
                            0 AS SAME_PIECE_ID
                        FROM            
                            EZGI_DESIGN_PIECE AS E WITH (NOLOCK) LEFT OUTER JOIN
                            (
                                SELECT        
                                    RELATED_PIECE_ROW_ID, 
                                    SUM(AMOUNT) AS AMOUNT
                                FROM            
                                    EZGI_DESIGN_PIECE_ROW WITH (NOLOCK)
                                GROUP BY 
                                    RELATED_PIECE_ROW_ID
                            ) AS TBL_1 ON E.PIECE_ROW_ID = TBL_1.RELATED_PIECE_ROW_ID
                        WHERE        
                            E.PIECE_ROW_ID = #ListGetAt(i,2,'_')#
                    </cfquery>
                    <cfif get_piece_all.recordcount>
                        <cfquery name="get_piece_1_control" dbtype="query"> <!---Paket Tanımlanmamış Parça Kontrolü--->
                            SELECT * FROM  get_piece_all WHERE PIECE_TYPE IN (1, 2, 3) AND DESIGN_PACKAGE_ROW_ID IS NULL AND USED_AMOUNT = 0
                        </cfquery>
                        <!---Pakete Girmemiş Parça Var mı?--->
                        <cfif get_piece_1_control.recordcount>
                            <script type="text/javascript">
                                alert(<cf_get_lang dictionary_id='954.Parçalar İçinde Paket Tanımlanmamış Satırlar Mevcut Önce Düzenleme Yapınız!'>);
                                window.close();
                            </script>
                            <cfabort>
                        </cfif>
                    <cfelse>
                        <script type="text/javascript">
                          	alert(<cf_get_lang dictionary_id='955.Parça Silinmiş!'>);
                          	window.close();
                     	</script>
                    	<cfabort>
                    </cfif>
                    <!---Workcube Ürünleri İçinde Aynı İsimli Parça Var mı?--->
                    <cfset urun_adi = '#get_design_info.DESIGN_NAME# #get_piece_all.PIECE_NAME#'> <!---Ürün Adı Tanımı--->
					<cfif isdefined('COLOR_NAME_#get_piece_all.PIECE_COLOR_ID#')>
                        <cfset urun_adi = "#urun_adi# (#Evaluate('COLOR_NAME_#get_piece_all.PIECE_COLOR_ID#')#)">
                    </cfif>
                    <cfquery name="get_stock_info" datasource="#dsn3#">
                         SELECT PRODUCT_NAME, PRODUCT_CODE FROM STOCKS WITH (NOLOCK) WHERE PRODUCT_NAME = '#urun_adi#'
                    </cfquery>
                    <cfif get_stock_info.recordcount>
						<script type="text/javascript">
                            alert("<cfoutput>#get_stock_info.PRODUCT_NAME# <cf_get_lang dictionary_id='956.Ürün Adı İle Daha Önce Açılmış'> #get_stock_info.recordcount#</cfoutput> Kayıt Var !");
                            window.close();
                        </script>
                        <cfabort>
                    </cfif>
              	<cfelseif ListGetAt(i,1,'_') eq 2> <!---Paket İse--->
                	<cfquery name="get_package_all" datasource="#dsn3#">
                        SELECT        
                            PACKAGE_ROW_ID, 
                            PACKAGE_NUMBER, 
                            PACKAGE_NAME, 
                            PACKAGE_BOYU, 
                            PACKAGE_ENI, 
                            PACKAGE_KALINLIK, 
                            PACKAGE_WEIGHT, 
                            PACKAGE_AMOUNT, 
                            PACKAGE_DETAIL, 
                            PACKAGE_RELATED_ID,
                            DESIGN_MAIN_ROW_ID,
                            (
                            	SELECT 
                                	DESIGN_MAIN_NAME 
                               	FROM 
                                	EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) 
                               	WHERE 
                                	DESIGN_MAIN_ROW_ID = EZGI_DESIGN_PACKAGE.DESIGN_MAIN_ROW_ID AND 
                                    DESIGN_MAIN_STATUS = 1
                          	) AS DESIGN_MAIN_NAME,
                            ISNULL((
                                SELECT        
                                    COUNT(*) AS PARCA_SAYISI
                                FROM            
                                    EZGI_DESIGN_PIECE WITH (NOLOCK)
                                WHERE        
                                    PIECE_STATUS = 1
                                GROUP BY 
                                    DESIGN_PACKAGE_ROW_ID
                                HAVING        
                                    DESIGN_PACKAGE_ROW_ID = EZGI_DESIGN_PACKAGE.PACKAGE_ROW_ID
                            ), 0) AS PARCA_SAYISI
                        FROM            
                            EZGI_DESIGN_PACKAGE WITH (NOLOCK)
                        WHERE        
                            PACKAGE_ROW_ID = #ListGetAt(i,2,'_')#
                    </cfquery>
                    <cfquery name="get_package_piece_control" dbtype="query">
                        SELECT PACKAGE_ROW_ID, PACKAGE_NAME, PACKAGE_NUMBER FROM get_package_all WHERE PARCA_SAYISI=0
                    </cfquery>
                    <cfif get_package_piece_control.recordcount><!---Parça Tanımlanmamış Paket Var mı?--->
						<script type="text/javascript">
                            alert("<cf_get_lang dictionary_id='100.Paket'>: <cfoutput>#get_package_piece_control.PACKAGE_NAME#</cfoutput> <cf_get_lang dictionary_id='957.Bu Pakete Parça Tanımlanmamıştır. Lütfen Düzenleme Yapınız!'>");
                            window.close();
                        </script>
                        <cfabort>
                    </cfif>
                	<cfquery name="get_package_main_control" dbtype="query">
                        SELECT PACKAGE_ROW_ID, PACKAGE_NAME, PACKAGE_NUMBER FROM get_package_all WHERE DESIGN_MAIN_NAME IS NULL
                    </cfquery>
                    <cfif get_package_main_control.recordcount><!---Modüle Bağlı Olmayan Paket Var mı?--->
                        <script type="text/javascript">
                            alert("<cf_get_lang dictionary_id='100.Paket'>: <cfoutput>#get_package_main_control.PACKAGE_NAME#</cfoutput>  <cf_get_lang dictionary_id='958.Bu Paket Herhangi Bir Modüle Bağlı Değildir. Lütfen Düzenleme Yapınız!'>");
                            window.close();
                        </script>
                        <cfabort>
                    </cfif>
                    <!---Workcube Ürünleri İçinde Aynı İsimli Paket Var mı?--->
                    <cfset urun_adi = get_package_all.PACKAGE_NAME> <!---Ürün Adı Tanımı--->
                    <cfquery name="get_stock_info" datasource="#dsn3#">
                         SELECT PRODUCT_NAME, PRODUCT_CODE FROM STOCKS WITH (NOLOCK) WHERE PRODUCT_NAME = '#urun_adi#'
                    </cfquery>
                    <cfif get_stock_info.recordcount>
						<script type="text/javascript">
                            alert("<cfoutput>#get_stock_info.PRODUCT_NAME# <cf_get_lang dictionary_id='956.Ürün Adı İle Daha Önce Açılmış'> #get_stock_info.recordcount#</cfoutput><cf_get_lang dictionary_id='958.Kayıt Var !'> ");
                            window.close();
                        </script>
                        <cfabort>
                    </cfif>
                <cfelseif ListGetAt(i,1,'_') eq 3> <!---Modül İse--->
                	<cfquery name="get_main_all" datasource="#dsn3#">
                        SELECT        
                            EDM.DESIGN_MAIN_ROW_ID, 
                            EDM.DESIGN_MAIN_NAME, 
                            EDP.PACKAGE_RELATED_ID, 
                            EDP.PACKAGE_ROW_ID, 
                            EDP.PACKAGE_NUMBER, 
                            EDP.PACKAGE_DETAIL,
                            EDP.PACKAGE_AMOUNT
                        FROM            
                            EZGI_DESIGN_MAIN_ROW AS EDM WITH (NOLOCK) LEFT OUTER JOIN
                            EZGI_DESIGN_PACKAGE AS EDP WITH (NOLOCK) ON EDM.DESIGN_MAIN_ROW_ID = EDP.DESIGN_MAIN_ROW_ID
                        WHERE        
                            EDM.DESIGN_MAIN_ROW_ID = #ListGetAt(i,2,'_')# 
                    </cfquery>
                	<cfquery name="get_main_control" dbtype="query">
                        SELECT * FROM get_main_all WHERE PACKAGE_ROW_ID IS NULL
                    </cfquery>
                    <cfif get_main_control.recordcount> <!---Boş Modül Tanımı Var mı?--->
                        <script type="text/javascript">
                            alert("<cf_get_lang dictionary_id='141.Modül'>: <cfoutput>#get_main_control.DESIGN_MAIN_NAME#</cfoutput> <cf_get_lang dictionary_id='960.Bu Modüle Paket Tanımlanmamıştır. Lütfen Düzenleme Yapınız!'>");
                            window.close();
                        </script>
                        <cfabort>
                    </cfif>
                    <!---Workcube Ürünleri İçinde Aynı İsimli Modül Var mı?--->
                    <cfset urun_adi = get_main_all.DESIGN_MAIN_NAME> <!---Ürün Adı Tanımı--->
                    <cfquery name="get_stock_info" datasource="#dsn3#">
                         SELECT PRODUCT_NAME, PRODUCT_CODE FROM STOCKS WITH (NOLOCK) WHERE PRODUCT_NAME = '#urun_adi#'
                    </cfquery>
                    <cfif get_stock_info.recordcount>
						<script type="text/javascript">
                            alert("<cfoutput>#get_stock_info.PRODUCT_NAME# <cf_get_lang dictionary_id='956.Ürün Adı İle Daha Önce Açılmış'> #get_stock_info.recordcount#</cfoutput><cf_get_lang dictionary_id='958.Kayıt Var !'>");
                            window.close();
                        </script>
                        <cfabort>
                    </cfif>
                </cfif>
            </cfif>
        </cfif>
 	</cfloop>
    <!---Buraya Kadar Gelmişse Sorun Yok Demektir. Öncelikle Açılması gereken Ürünleri Kaydediyoruz--->
    <cflock timeout="90">
    <cftransaction>
        <cfloop list="#attributes.iid_list#" index="i"> <!---Yeniden Döndürüyoruz--->
            <cfif isdefined('attributes.select_#i#') and len(Evaluate('attributes.select_#i#'))>
                <cfif Evaluate('attributes.upd_type_#i#') eq 1><!---Düzenleme Şekli - Ürün Ağacı İçerik Düzenleme İse--->
                    <cfif ListGetAt(i,1,'_') eq 1> <!---Parça İse--->
                    	 <cfquery name="get_piece_all" datasource="#dsn3#">
                            SELECT        
                                PIECE_ROW_ID, 
                                PIECE_NAME,
                                PIECE_COLOR_ID,
                                PIECE_DETAIL
                            FROM            
                                EZGI_DESIGN_PIECE WITH (NOLOCK)
                            WHERE        
                                PIECE_ROW_ID = #ListGetAt(i,2,'_')#
                        </cfquery>
                        <cfset attributes.HIERARCHY = get_product_cat_piece.HIERARCHY>
                    	<cfset urun_adi = '#get_design_info.DESIGN_NAME# #get_piece_all.PIECE_NAME#'> <!---Ürün Adı Tanımı--->
						<cfif isdefined('COLOR_NAME_#get_piece_all.PIECE_COLOR_ID#')>
                            <cfset urun_adi = "#urun_adi# (#Evaluate('COLOR_NAME_#get_piece_all.PIECE_COLOR_ID#')#)">
                        </cfif>
                        <cfquery name="get_barcode_no" datasource="#dsn3#"> <!---Barkod Tanımı--->
                            SELECT PRODUCT_NO AS BARCODE FROM #dsn1_alias#.PRODUCT_NO WITH (NOLOCK)
                        </cfquery>
                        <cfset barcode = get_barcode_no.barcode>
                        <cfset barcode_len = len(barcode)>
                        <cfset barcode = left(barcode_on_taki,barcode_boy-barcode_len)&barcode>
                        <cfset products_cat_id = get_defaults.DEFAULT_PIECE_CAT_ID>
                        <cfset details = get_piece_all.PIECE_DETAIL>
                        <cfset sales_type = 0>
                        <cfset purchase_type = 0>
                        <cfset product_process_stage = get_defaults.DEFAULT_PRODUCT_PROCESS_STAGE>
                        <cfset product_tree_workstation_id = get_defaults.DEFAULT_PIECE_WORKSTATION_ID>
                        <cfset main_units = get_defaults.DEFAULT_PIECE_UNIT>
                        <cfset default_account_ids = get_defaults.DEFAULT_PIECE_ACCOUNT_ID>
                        <cfinclude template="../query/add_ezgi_product_import.cfm"> <!---Yeni Kart Açıyoruz--->
                        <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Yeni Açılan ürün Kartı İle Parçayı İlşkilendiriyoruz.--->
                            UPDATE EZGI_DESIGN_PIECE_ROWS SET PIECE_RELATED_ID = #GET_SID.STOCK_ID# WHERE PIECE_ROW_ID = #get_piece_all.PIECE_ROW_ID#
                        </cfquery>
                        <cfquery name="upd_product_info" datasource="#dsn3#">
                         	UPDATE      
                             	PRODUCT
							SET                
                            	<cfif get_design_info.IS_PROTOTIP eq 1>
                                  	IS_PROTOTYPE =1
                            	<cfelse>
                                 	IS_PROTOTYPE =0
                           		</cfif>
							WHERE        
                          		PRODUCT_ID = #GET_PID.PRODUCT_ID#
                  		</cfquery>
                        <cfset 'attributes.upd_type_#i#' = 2> <!---Artık Reçete Yapılabilir Hale Getiriyoruz--->
                        <cfset 'attributes.STOCK_ID_#i#' = GET_SID.STOCK_ID>
                    <cfelseif ListGetAt(i,1,'_') eq 2> <!---Paket İse--->
                    	<cfquery name="get_package_all" datasource="#dsn3#">
                            SELECT        
                                PACKAGE_ROW_ID, 
                                PACKAGE_NAME,
                                PACKAGE_DETAIL
                            FROM            
                                EZGI_DESIGN_PACKAGE WITH (NOLOCK)
                            WHERE        
                                PACKAGE_ROW_ID = #ListGetAt(i,2,'_')#
                        </cfquery>
                    	<cfset urun_adi = get_package_all.PACKAGE_NAME> <!---Ürün Adı Tanımı--->
                        <cfset attributes.HIERARCHY = get_product_cat_package.HIERARCHY>
                        <cfquery name="get_barcode_no" datasource="#dsn3#"> <!---Barkod Tanımı--->
                            SELECT PRODUCT_NO AS BARCODE FROM #dsn1_alias#.PRODUCT_NO WITH (NOLOCK)
                        </cfquery>
                        <cfset barcode = get_barcode_no.barcode>
                        <cfset barcode_len = len(barcode)>
                        <cfset barcode = left(barcode_on_taki,barcode_boy-barcode_len)&barcode>
                        <cfset products_cat_id = get_defaults.DEFAULT_PACKAGE_CAT_ID>
                        <cfset details = get_package_all.PACKAGE_DETAIL>
                        <cfset sales_type = 0>
                        <cfset purchase_type = 0>
                        <cfset product_process_stage = get_defaults.DEFAULT_PRODUCT_PROCESS_STAGE>
                        <cfset product_tree_workstation_id = get_defaults.DEFAULT_PACKAGE_WORKSTATION_ID>
                        <cfset main_units = get_defaults.DEFAULT_PACKAGE_UNIT>
                        <cfset default_account_ids = get_defaults.DEFAULT_PACKAGE_ACCOUNT_ID>
                        <cfinclude template="../query/add_ezgi_product_import.cfm"> <!---Yeni Kart Açıyoruz--->
                        <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Yeni Açılan ürün Kartı İle İlşkilendiriyoruz.--->
                            UPDATE 
                            	EZGI_DESIGN_PACKAGE_ROW 
                          	SET 
                            	PACKAGE_RELATED_ID = #GET_SID.STOCK_ID# 
                          	WHERE  
                            	PACKAGE_ROW_ID = #get_package_all.PACKAGE_ROW_ID#
                        </cfquery>
                     	<cfquery name="upd_product_info" datasource="#dsn3#">
                         	UPDATE      
                             	PRODUCT
							SET                
                            	<cfif get_design_info.IS_PROTOTIP eq 1>
                                  	IS_PROTOTYPE =1
                            	<cfelse>
                                 	IS_PROTOTYPE =0
                           		</cfif>
							WHERE        
                          		PRODUCT_ID = #GET_PID.PRODUCT_ID#
                  		</cfquery>
                        <!---Paket İse Ölçüleri Güncelle--->
                        <cfquery name="upd_packege_unit" datasource="#dsn3#">
                            UPDATE 
                                #dsn1_alias#.PRODUCT_UNIT
                            SET          
                                DIMENTION =  CAST(EP.PACKAGE_BOYU AS VARCHAR) + '*' + CAST(EP.PACKAGE_ENI AS VARCHAR) + '*' + CAST(EP.PACKAGE_KALINLIK AS VARCHAR), 
                                WEIGHT =ISNULL(EP.PACKAGE_WEIGHT,0), 
                                VOLUME =EP.PACKAGE_BOYU * EP.PACKAGE_ENI * EP.PACKAGE_KALINLIK
                            FROM     
                                EZGI_DESIGN_PACKAGE_ROW AS EP INNER JOIN
                                STOCKS AS S ON EP.PACKAGE_RELATED_ID = S.STOCK_ID INNER JOIN
                                #dsn1_alias#.PRODUCT_UNIT ON S.PRODUCT_ID = #dsn1_alias#.PRODUCT_UNIT.PRODUCT_ID
                            WHERE  
                                EP.PACKAGE_ROW_ID =#get_package_all.PACKAGE_ROW_ID# AND 
                                NOT (EP.PACKAGE_BOYU IS NULL) AND 
                                NOT (EP.PACKAGE_ENI IS NULL) AND 
                                NOT (EP.PACKAGE_KALINLIK IS NULL)
                        </cfquery>
                        <cfset 'attributes.upd_type_#i#' = 2> <!---Artık Reçete Yapılabilir Hale Getiriyoruz--->
                        <cfset 'attributes.STOCK_ID_#i#' = GET_SID.STOCK_ID>
                    <cfelseif ListGetAt(i,1,'_') eq 3> <!---Modül İse--->
                    	<cfquery name="get_main_all" datasource="#dsn3#">
                            SELECT        
                                DESIGN_MAIN_ROW_ID, 
                                DESIGN_MAIN_NAME 
                            FROM            
                                EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
                            WHERE        
                                DESIGN_MAIN_ROW_ID = #ListGetAt(i,2,'_')# 
                        </cfquery>
                        <cfset urun_adi = get_main_all.DESIGN_MAIN_NAME> <!---Ürün Adı Tanımı--->
                        <cfset attributes.HIERARCHY = get_design_info.HIERARCHY>
                        <cfquery name="get_barcode_no" datasource="#dsn3#">
                            SELECT LEFT(BARCODE, 12) AS BARCODE FROM #dsn1_alias#.PRODUCT_NO WITH (NOLOCK)
                        </cfquery>
                        <cfset barcode = (get_barcode_no.barcode*1)+1>
                        <cfquery name="upd_barcode_no" datasource="#dsn3#">
                            UPDATE #dsn1_alias#.PRODUCT_NO SET BARCODE = '#barcode#X'
                        </cfquery>
                        <cfset products_cat_id = get_design_info.PRODUCT_CATID>
                        <cfset details = ''>
                        <cfset sales_type = 1>
                        <cfset purchase_type = 1>
                        <cfset product_process_stage = get_defaults.DEFAULT_PRODUCT_PROCESS_STAGE>
                        <cfset product_tree_workstation_id = get_defaults.DEFAULT_MAIN_WORKSTATION_ID>
                        <cfset main_units = get_defaults.DEFAULT_MAIN_UNIT>
                        <cfset default_account_ids = get_defaults.DEFAULT_MAIN_ACCOUNT_ID>
                        <cfinclude template="../query/add_ezgi_product_import.cfm"> <!---Yeni Kart Açıyoruz--->
                        <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Yeni Açılan ürün Kartı İle İlşkilendiriyoruz.--->
                            UPDATE EZGI_DESIGN_MAIN_ROW SET DESIGN_MAIN_RELATED_ID = #GET_SID.STOCK_ID# WHERE DESIGN_MAIN_ROW_ID = #get_main_all.DESIGN_MAIN_ROW_ID#
                        </cfquery>
                        <cfset 'attributes.upd_type_#i#' = 2> <!---Artık Reçete Yapılabilir Hale Getiriyoruz--->
                        <cfset 'attributes.STOCK_ID_#i#' = GET_SID.STOCK_ID>
                        <cfset 'attributes.PRODUCT_ID_#i#' = GET_PID.PRODUCT_ID>
                        <cfif get_defaults.DEFAULT_MAIN_TRANSFER_TYPE eq 2 and get_design_info.IS_PROTOTIP neq 1> <!---Karma Koli İse ve Özelleştirilebilir Değil ise--->
                        	<cfquery name="upd_karma_koli" datasource="#dsn3#">
                            	UPDATE      
                                	#dsn1_alias#.PRODUCT
								SET                
                                	IS_PRODUCTION = 0, 
                                    IS_ZERO_STOCK = 1, 
                                    IS_KARMA = 1, 
                                    IS_COST = 0,
                                    IS_PROTOTYPE =0
								WHERE        
                                	PRODUCT_ID = #GET_PID.PRODUCT_ID#
                            </cfquery>
                        <cfelse>
                        	<cfquery name="upd_karma_koli" datasource="#dsn3#">
                            	UPDATE      
                                	#dsn1_alias#.PRODUCT
								SET                
                                	IS_PRODUCTION = 1, 
                                    IS_ZERO_STOCK = 0, 
                                    IS_KARMA = 0, 
                                    IS_COST = 1,
                                    <cfif get_design_info.IS_PROTOTIP eq 1>
                                      	IS_PROTOTYPE =1
                                    <cfelse>
                                    	IS_PROTOTYPE =0
                                    </cfif>
								WHERE        
                                	PRODUCT_ID = #GET_PID.PRODUCT_ID#
                            </cfquery>
                        </cfif>
                    </cfif>
                	<cfquery name="upd_workstations_products_table" datasource="#dsn3#"> <!---Ürün Ağacı İçin istasyon Kaydı Yapıyoruz.--->
                     	INSERT INTO 
                        	WORKSTATIONS_PRODUCTS
                          		(
                             	WS_ID, 
                              	STOCK_ID, 
                              	CAPACITY, 
                               	PRODUCTION_TIME, 
                            	PRODUCTION_TIME_TYPE, 
                              	SETUP_TIME, MIN_PRODUCT_AMOUNT, 
                              	PRODUCTION_TYPE, 
                              	PROCESS, 
                             	MAIN_STOCK_ID, 
                              	OPERATION_TYPE_ID, 
                              	ASSET_ID, 
                              	RECORD_EMP, 
                             	RECORD_IP, 
                              	RECORD_DATE
                           		)
                         	VALUES
                            	(
                             	#product_tree_workstation_id#, 
                               	#GET_SID.STOCK_ID#,
                              	60, 
                               	1, 
                              	1, 
                              	10, 
                               	1, 
                              	0, 
                            	NULL, 
                            	#GET_SID.STOCK_ID#, 
                              	NULL,  
                               	NULL, 
                              	#session.ep.userid#, 
                              	'#CGI.REMOTE_ADDR#', 
                               	#now()#
                            	)
                 	</cfquery>
                </cfif>
            </cfif>
        </cfloop>
     	<!---Ürün Reçete Kaydı veya Düzeltme Başlangıcı--->
        <cfloop list="#attributes.iid_list#" index="i"> <!---İşlem Döngüsü--->
        	<cfif isdefined('attributes.select_#i#') and len(Evaluate('attributes.select_#i#'))>
            	<cfif Evaluate('attributes.upd_type_#i#') eq 3 or Evaluate('attributes.upd_type_#i#') eq 4> <!---Düzenleme Şekli - Ürün Adı Düzeltme veya Pasif Düzeltme--->
					<cfif isdefined('attributes.STOCK_ID_#i#')>
                        <cfinclude template="cnt_ezgi_product_tree_import_1.cfm">
                    </cfif>
            	<cfelseif Evaluate('attributes.upd_type_#i#') eq 2> <!---Düzenleme Şekli - Ürün Reçetesi Farklı İse--->
					<cfif isdefined('STOCK_ID_#i#')> <!---Tanımlı Bir Ürüne Bağlı İse Spect_Main_Id Bulunuyor--->
                        <cfquery name="del_product_tree" datasource="#dsn3#"> <!---İlgili Ürüne ait Ürün Ağacı Dosyasından Row lar siliniyor--->
                            DELETE FROM PRODUCT_TREE WHERE STOCK_ID = #Evaluate('attributes.STOCK_ID_#i#')#
                        </cfquery>
                        <cfquery name="get_product_id" datasource="#dsn3#">
                        	SELECT PRODUCT_ID FROM  #dsn1_alias#.STOCKS WITH (NOLOCK) WHERE STOCK_ID = #Evaluate('attributes.STOCK_ID_#i#')#
                        </cfquery>
                        <cfset attributes.main_product_id = get_product_id.PRODUCT_ID>
                        <cfquery name="del_karma_koli" datasource="#dsn3#"> <!---İlgili Ürüne ait kARMA kOLİ Dosyasından Row lar siliniyor--->
                            DELETE FROM #dsn1_alias#.KARMA_PRODUCTS WHERE KARMA_PRODUCT_ID =  #attributes.main_product_id#
                        </cfquery>
                        <cfset attributes.main_stock_id = Evaluate('STOCK_ID_#i#')>
                        <cfquery name="get_old_spect_id" datasource="#dsn3#">
                            SELECT TOP (1) SPECT_MAIN_ID FROM SPECT_MAIN WITH (NOLOCK) WHERE STOCK_ID = #attributes.main_stock_id# ORDER BY SPECT_MAIN_ID DESC
                        </cfquery>
                        <cfif get_old_spect_id.recordcount>
                            <cfset attributes.old_main_spec_id = get_old_spect_id.SPECT_MAIN_ID>
                        <cfelse>
                        	<cfset attributes.old_main_spec_id = 0>
                        </cfif>
                    <cfelse> <!---Yeni Bir Ürün Tanımlanması gerekiyorsa--->
                    	Ürün Tanımında Sorun Var - Bu arada Silinmiş Olabilir<cfabort>
                    </cfif>
                    <cfif ListGetAt(i,1,'_') eq 1> <!---Parça İse Parça Tipini Arıyoruz--->
                        <cfquery name="get_stock_control" datasource="#dsn3#">
                            SELECT PIECE_TYPE FROM EZGI_DESIGN_PIECE WITH (NOLOCK) WHERE PIECE_ROW_ID = #ListGetAt(i,2,'_')#
                        </cfquery>
                        <cfset PIECE_TYPE = get_stock_control.PIECE_TYPE >
                    <cfelse>
                        <cfset PIECE_TYPE = 0>
                    </cfif>
                    <cfif ListGetAt(i,1,'_') eq 2> <!---Paket İse Paketin Sevkte Birleştirme Parametresi Sorgulanıyor--->
                        <cfif get_defaults.DEFAULT_SEVKTE_BIRLESTIR eq 1>
                            <cfset attributes.is_sevk = 1>
                        <cfelse>
                            <cfset attributes.is_sevk = ''>
                        </cfif>
                    <cfelse>
                        <cfset attributes.is_sevk = ''>	
                    </cfif>
                    <cfset type = ListGetAt(i,1,'_')>
                    <cfset IID = ListGetAt(i,2,'_')>
                    <cfinclude template="../query/cnt_ezgi_product_tree_import_ortak.cfm">
                   
                    <cfif get_product_tree.recordcount>
                        <cfloop query="#get_product_tree#">
                            <cfif get_product_tree.RELATED_ID eq 0> <!---Operasyon İse--->
                                <cfset attributes.add_stock_id = ''>
                                <cfset attributes.UNIT_ID = ''>
                                <cfset attributes.spect_main_id = ''>
                                <cfset attributes.product_id = ''>
                                <cfset attributes.product_name = ''>
                                <!---<cfset attributes.MAIN_PRODUCT_ID = ''>--->
                                <cfset attributes.operation_type_id = get_product_tree.OPERATION_TYPE_ID>
                                <cfset attributes.AMOUNT = get_product_tree.AMOUNT>
                                <cfset attributes.line_number = get_product_tree.LINE_NUMBER>
                                <cfset attributes.process_stage_ = get_defaults.DEFAULT_PRODUCT_TREE_PROCESS_STAGE>
                            <cfelse><!---Ürün İse--->
                                <cfquery name="get_stock_info" datasource="#dsn3#"><!--- Stok Bilgileri Toplanıyor--->
                                    SELECT        
                                        S.PRODUCT_ID, 
                                        P.PRODUCT_CODE, 
                                        P.PRODUCT_NAME, 
                                        PU.MAIN_UNIT, 
                                        PU.PRODUCT_UNIT_ID,
                                        (
                                        SELECT        
                                            TOP (1) SPECT_MAIN_ID
                                        FROM            
                                            SPECT_MAIN WITH (NOLOCK)
                                        WHERE        
                                            STOCK_ID = S.STOCK_ID
                                        ORDER BY 
                                            SPECT_MAIN_ID DESC
                                        ) AS SPECT_MAIN_ID,
                                         <cfif get_defaults.IS_HIZMET_PHANTOM eq 1>
                                            ISNULL((SELECT PRODUCT_CATID FROM PRODUCT_CAT WHERE LIST_ORDER_NO IN (1,5) AND PRODUCT_CATID = S.PRODUCT_CATID),0) AS IS_PHANTOM
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
                                	<cfif get_design_info.IS_PROTOTIP eq 1> <!---Özelleştirilebilir ve Özellştirme Tipi Koltuk ise--->
                                        <cfquery name="get_question_different" datasource="#dsn3#">
                                            SELECT 
                                                PIECE_ROW_ID, 
                                                QUESTION_ID, 
                                                PT_QUESTION_ID
                                            FROM     
                                                (
                                                    SELECT 
                                                        ED.PIECE_ROW_ID, 
                                                        EDP.QUESTION_ID, 
                                                        ISNULL(PT.QUESTION_ID, 0) AS PT_QUESTION_ID
                                                    FROM      
                                                        EZGI_DESIGN_PIECE_ROW AS ED WITH (NOLOCK) INNER JOIN
                                                        EZGI_DESIGN_PIECE_PROTOTIP AS EDP WITH (NOLOCK) ON ED.EZGI_PIECE_ROW_ROW_ID = EDP.EZGI_PIECE_ROW_ROW_ID LEFT OUTER JOIN
                                                        PRODUCT_TREE AS PT WITH (NOLOCK) ON EDP.EZGI_PIECE_ROW_ROW_ID = PT.PRODUCT_SAMPLE_ID
                                                    WHERE   
                                                        ED.PIECE_ROW_ID = #IID# AND
                                                        ED.STOCK_ID = #get_product_tree.RELATED_ID#
                                                ) AS TBL
                                            WHERE  
                                                QUESTION_ID <> PT_QUESTION_ID
                                        </cfquery>
                                        <!---<cfdump var="#get_question_different#">--->
                                        <cfif get_question_different.recordcount and len(get_question_different.QUESTION_ID)>
                                         	<cfset attributes.alternative_questions = get_question_different.QUESTION_ID>
                                       	<cfelse>
                                        	<cfset attributes.alternative_questions = ''>
                                        </cfif>
                                    </cfif>
                                   <!--- <cfset attributes.MAIN_PRODUCT_ID = ''>--->
                                    <cfset attributes.product_id = get_stock_info.PRODUCT_ID>
                                    <cfset attributes.product_name = get_stock_info.PRODUCT_NAME>
                                    <cfset attributes.add_stock_id = get_product_tree.RELATED_ID>
                                    <cfset attributes.UNIT_ID = get_stock_info.PRODUCT_UNIT_ID>
                                    <cfset attributes.main_unit = get_stock_info.MAIN_UNIT>
                                    <cfset attributes.AMOUNT = get_product_tree.AMOUNT>
                                    <cfset attributes.line_number = get_product_tree.LINE_NUMBER>
                                    <cfset attributes.spect_main_id = get_stock_info.SPECT_MAIN_ID>
                                    <cfset attributes.process_stage_ = get_defaults.DEFAULT_PRODUCT_TREE_PROCESS_STAGE>
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
                            </cfif>
                            <cfif get_defaults.DEFAULT_MAIN_TRANSFER_TYPE eq 2 and ListGetAt(i,1,'_') eq 3 and get_design_info.IS_PROTOTIP neq 1 and (get_design_info.PROCESS_ID eq 1 or get_design_info.PROCESS_ID eq 2)> <!---Ürün Modül ve Karma Koli İse ve Özelleştirilebilir Değilse ve Transfer Şekili Modül ise--->
                            	<cfif get_product_tree.RELATED_ID gt 0> <!---Operasyon Değilse--->
                            		<cfinclude template="add_ezgi_product_karma_koli.cfm">
                                </cfif>
                            <cfelse>
                            	<cfinclude template="add_ezgi_product_tree.cfm">
                            </cfif>
                        </cfloop>
                        
                        <cfif get_defaults.DEFAULT_MAIN_TRANSFER_TYPE eq 2 and ListGetAt(i,1,'_') eq 3 and get_design_info.IS_PROTOTIP neq 1 and (get_design_info.PROCESS_ID eq 1 or get_design_info.PROCESS_ID eq 2)> <!---Ürün Modül ve Karma Koli İse ve Özelleştirilebilir Değilse ve Transfer Şekili Modül ise--->
                        
                        <cfelse>
							<cfset attributes.stock_id = attributes.main_stock_id>
                            <cfinclude template="add_ezgi_spect_main_ver.cfm">
                        </cfif>
                    </cfif>
                </cfif>
            </cfif>
        </cfloop>
  	</cftransaction>
    </cflock>
    <cfif isdefined('attributes.popup_window')>
    	
		<script type="text/javascript">
            wrk_opener_reload();
            window.close()
        </script>
    <cfelse>
    	<cfif isdefined('attributes.design_main_row_id')>
    		<cflocation url="#request.self#?fuseaction=prod.popup_cnt_ezgi_product_tree_import&design_id=#attributes.design_id#&design_main_row_id=#attributes.design_main_row_id#" addtoken="No">
        <cfelse>
        	<cflocation url="#request.self#?fuseaction=prod.popup_cnt_ezgi_product_tree_import&design_id=#attributes.design_id#" addtoken="No">
        </cfif>
    </cfif>
<cfelse>
   	Eşitleme Yapılacak Tasarım Kaydı Bulunamadı
	<cfabort>
</cfif>
