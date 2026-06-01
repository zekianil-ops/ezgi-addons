<!---
    File: add_ezgi_import_creative_workcube.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 
<cfquery name="get_barcode_defaults" datasource="#dsn3#">
 	SELECT EAN FROM EZGI_SHIPPING_DEFAULTS
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
<cfif len(attributes.main_row_id_list)>
	<cfset new_main_row_id_list = ''>
    <cfloop list="#attributes.main_row_id_list#" index="i">
    	<cfif isdefined('attributes.transfer_main_id#i#') and Evaluate('attributes.transfer_main_id#i#') eq 1>
        	<cfset new_main_row_id_list = ListAppend(new_main_row_id_list,i)>
        </cfif>
    </cfloop>
	<cfif not len(new_main_row_id_list)>
    	<script type="text/javascript">
			alert('<cf_get_lang dictionary_id='263.Dikkat. Transfer Etmek İstediğiniz Modülü Seçiniz!'>');
			window.history.go(-1);
		</script>
		<cfabort>
    </cfif>
<cfelse>
	<script type="text/javascript">
		alert('<cf_get_lang dictionary_id='262.Dikkat. İşlem Yapmak İçin Kayıt Seçiniz !'>');
		window.history.go(-1);
	</script>
    <cfabort>
</cfif>
<cfset is_find = 0>
<!---Design Sorgusu--->
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK) ORDER BY COLOR_NAME
</cfquery>
<cfoutput query="get_colors">
	<cfset 'COLOR_NAME_#COLOR_ID#' = COLOR_NAME>
</cfoutput>
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfquery name="get_product_cat_piece" datasource="#dsn3#">
  	SELECT HIERARCHY FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = #get_defaults.DEFAULT_PIECE_CAT_ID#
</cfquery>
<cfquery name="get_product_cat_package" datasource="#dsn3#">
  	SELECT HIERARCHY FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = #get_defaults.DEFAULT_PACKAGE_CAT_ID#
</cfquery>
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
<cfset is_transfer = 1>
<!---Design Sorgusu--->
<!---Parça Sorgusu--->
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
    	E.PIECE_STATUS = 1 AND 
        E.DESIGN_ID = #attributes.design_id# AND
        E.DESIGN_MAIN_ROW_ID IN (#new_main_row_id_list#)
</cfquery>
<!---Parça Sorgusu--->
<!---Parça Transfer--->
<cflock timeout="90">
<cftransaction>
	<cfif get_piece_all.recordcount>
        <cfif get_design_info.PROCESS_ID eq 1> <!---Modül+Paket+Parça ise--->
            <cfquery name="get_piece_1" dbtype="query"> <!---İmport Edilecek Parçalar Listeleniyor.--->
                SELECT * FROM  get_piece_all WHERE PIECE_TYPE IN (1,2) AND PIECE_RELATED_ID IS NULL
            </cfquery>
            <cfif get_piece_1.recordcount> <!---1. ve 2. Parçalar Döndürülüyor--->
                <cfoutput query="get_piece_1">
                    <cfset attributes.HIERARCHY = get_product_cat_piece.HIERARCHY>
                    <cfset urun_adi = '#get_design_info.DESIGN_NAME# #PIECE_NAME#'> <!---Ürün Adı Tanımı--->
                    <cfif isdefined('COLOR_NAME_#PIECE_COLOR_ID#')>
                        <cfset urun_adi = "#urun_adi# (#Evaluate('COLOR_NAME_#PIECE_COLOR_ID#')#)">
                    </cfif>
                    
                    <cfquery name="get_product_info_piece" datasource="#dsn3#">
                        SELECT TOP (1) STOCK_ID, PRODUCT_ID FROM STOCKS WITH (NOLOCK) WHERE PRODUCT_NAME = '#urun_adi#' ORDER BY STOCK_ID
                    </cfquery>
                    <cfif not get_product_info_piece.recordcount>
                        <cfquery name="get_barcode_no" datasource="#dsn3#"> <!---Barkod Tanımı--->
                            SELECT PRODUCT_NO AS BARCODE FROM #dsn1_alias#.PRODUCT_NO WITH (NOLOCK)
                        </cfquery>
                        <cfset barcode = get_barcode_no.barcode>
                        <cfset barcode_len = len(barcode)>
                        <cfset barcode = left(barcode_on_taki,barcode_boy-barcode_len)&barcode>
                        <cfset products_cat_id = get_defaults.DEFAULT_PIECE_CAT_ID>
                        <cfset details = PIECE_DETAIL>
                        <cfset sales_type = 0>
                        <cfset purchase_type = 0>
                        <cfset product_process_stage = get_defaults.DEFAULT_PRODUCT_PROCESS_STAGE>
                        <cfset main_units = get_defaults.DEFAULT_PIECE_UNIT>
                        <cfset default_account_ids = get_defaults.DEFAULT_PIECE_ACCOUNT_ID>
                        <cfinclude template="../query/add_ezgi_product_import.cfm"> <!---Yeni Kart Açıyoruz--->
                        <cfquery name="get_product_id" datasource="#dsn3#">
                            SELECT PRODUCT_ID FROM  #dsn1_alias#.STOCKS WITH (NOLOCK) WHERE STOCK_ID = #GET_SID.STOCK_ID# 
                        </cfquery>
                        <cfif get_design_info.IS_PROTOTIP eq 1> <!---Özelleştirilmiş Ürün İse--->
                            <cfquery name="upd_standart_urun" datasource="#dsn3#">
                                UPDATE 
                                    #dsn1_alias#.PRODUCT 
                                SET 
                                    IS_PROTOTYPE =1 
                                WHERE 
                                    PRODUCT_ID = #get_product_id.PRODUCT_ID#
                            </cfquery>
                        </cfif>
                        <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Yeni Açılan ürün Kartı İle İlşkilendiriyoruz.--->
                            UPDATE EZGI_DESIGN_PIECE_ROWS SET PIECE_RELATED_ID = #GET_SID.STOCK_ID# WHERE PIECE_ROW_ID = #PIECE_ROW_ID#
                        </cfquery>
                        <cfset attributes.design_piece_row_id = PIECE_ROW_ID>
                        <cfset IID = PIECE_ROW_ID>
                        <cfset TYPE = 1>
                        <cfinclude template="cnt_ezgi_product_tree_import_ortak.cfm">
                        <cfif get_product_tree.recordcount>
                            <cfset is_sevk = 0>
                            <cfset is_phantom = 0>
                            <cfset is_configure =  0>
                            <cfset product_tree_process_stage = get_defaults.DEFAULT_PRODUCT_TREE_PROCESS_STAGE>
                            <cfset product_tree_workstation_id = get_defaults.DEFAULT_PIECE_WORKSTATION_ID>
                            <cfinclude template="../query/add_ezgi_product_tree_import.cfm"> <!---Ürün Ağacı Oluşturuyoruz--->
                        </cfif>
                    <cfelse>
                        <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Var Olsn Ürün Kartı İle İlşkilendiriyoruz.--->
                            UPDATE EZGI_DESIGN_PIECE_ROWS SET PIECE_RELATED_ID = #get_product_info_piece.STOCK_ID# WHERE PIECE_ROW_ID = #PIECE_ROW_ID#
                        </cfquery>
                    </cfif>
                </cfoutput>
                <cfset is_find = 0>
            <cfelse>
                <cfset is_find = 1>
            </cfif>
            <cfquery name="get_piece_3" dbtype="query"> <!---İmport Edilecek Parçalar Listeleniyor.--->
                SELECT * FROM  get_piece_all WHERE PIECE_TYPE IN (3) AND PIECE_RELATED_ID IS NULL
            </cfquery>
            <cfif get_piece_3.recordcount> <!--- 3. Parçalar Döndürülüyor--->
                <cfoutput query="get_piece_3">
                    <cfset attributes.HIERARCHY = get_product_cat_piece.HIERARCHY>
                    <cfset urun_adi = '#get_design_info.DESIGN_NAME# #PIECE_NAME#'> <!---Ürün Adı Tanımı--->
                    <cfif isdefined('COLOR_NAME_#PIECE_COLOR_ID#')>
                        <cfset urun_adi = "#urun_adi# (#Evaluate('COLOR_NAME_#PIECE_COLOR_ID#')#)">
                    </cfif>
                    <cfquery name="get_product_info_piece3" datasource="#dsn3#">
                        SELECT TOP (1) STOCK_ID, PRODUCT_ID FROM STOCKS WITH (NOLOCK) WHERE PRODUCT_NAME = '#urun_adi#' ORDER BY STOCK_ID
                    </cfquery>
                    <cfif not get_product_info_piece3.recordcount>
                        <cfquery name="get_barcode_no" datasource="#dsn3#"> <!---Barkod Tanımı--->
                            SELECT PRODUCT_NO AS BARCODE FROM #dsn1_alias#.PRODUCT_NO WITH (NOLOCK)
                        </cfquery>
                        <cfset barcode = get_barcode_no.barcode>
                        <cfset barcode_len = len(barcode)>
                        <cfset barcode = left(barcode_on_taki,barcode_boy-barcode_len)&barcode>
                        <cfset products_cat_id = get_defaults.DEFAULT_PIECE_CAT_ID>
                        <cfset details = PIECE_DETAIL>
                        <cfset sales_type = 0>
                        <cfset purchase_type = 1>
                        <cfset product_process_stage = get_defaults.DEFAULT_PRODUCT_PROCESS_STAGE>
                        <cfset main_units = get_defaults.DEFAULT_PIECE_UNIT>
                        <cfset default_account_ids = get_defaults.DEFAULT_PIECE_ACCOUNT_ID>
                        <cfinclude template="../query/add_ezgi_product_import.cfm"> <!---Yeni Kart Açıyoruz--->
                        <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Yeni Açılan ürün Kartı İle İlşkilendiriyoruz.--->
                            UPDATE EZGI_DESIGN_PIECE_ROWS SET PIECE_RELATED_ID = #GET_SID.STOCK_ID# WHERE PIECE_ROW_ID = #PIECE_ROW_ID#
                        </cfquery>
                        <cfquery name="get_product_id" datasource="#dsn3#">
                            SELECT PRODUCT_ID FROM  #dsn1_alias#.STOCKS WITH (NOLOCK) WHERE STOCK_ID = #GET_SID.STOCK_ID# 
                        </cfquery>
                        <cfif get_design_info.IS_PROTOTIP eq 1> <!---Özelleştirilmiş Ürün İse--->
                            <cfquery name="upd_standart_urun" datasource="#dsn3#">
                                UPDATE 
                                    #dsn1_alias#.PRODUCT 
                                SET 
                                    IS_PROTOTYPE =1 
                                WHERE 
                                    PRODUCT_ID = #get_product_id.PRODUCT_ID#
                            </cfquery>
                        </cfif>
                        <cfset attributes.design_piece_row_id = PIECE_ROW_ID>
                        <cfset IID = PIECE_ROW_ID>
                        <cfset TYPE = 1>
                        <cfinclude template="cnt_ezgi_product_tree_import_ortak.cfm">
                        <cfif get_product_tree.recordcount>
                            <cfset is_sevk = 0>
                            <cfset is_phantom = 0>
                            <cfset is_configure =  0>
                            <cfset product_tree_process_stage = get_defaults.DEFAULT_PRODUCT_TREE_PROCESS_STAGE>
                            <cfset product_tree_workstation_id = get_defaults.DEFAULT_PIECE_WORKSTATION_ID>
                            <cfinclude template="../query/add_ezgi_product_tree_import.cfm"> <!---Ürün Ağacı Oluşturuyoruz--->
                        </cfif>
                    <cfelse>
                        <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Var Olan Ürün Kartı İle İlşkilendiriyoruz.--->
                            UPDATE EZGI_DESIGN_PIECE_ROWS SET PIECE_RELATED_ID = #get_product_info_piece3.STOCK_ID# WHERE PIECE_ROW_ID = #PIECE_ROW_ID#
                        </cfquery>
                    </cfif>
                </cfoutput>
                <cfset is_find = 0>
            <cfelse>
                <cfset is_find = 1>
            </cfif>
        </cfif>
    </cfif>
	<!---Parça Transfer--->
    <!---Paket Sorgusu--->
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
            (SELECT DESIGN_MAIN_NAME FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = EZGI_DESIGN_PACKAGE.DESIGN_MAIN_ROW_ID AND DESIGN_MAIN_STATUS = 1) AS DESIGN_MAIN_NAME,
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
            DESIGN_ID = #attributes.design_id# AND
            PACKAGE_RELATED_ID IS NULL AND
            DESIGN_MAIN_ROW_ID IN (#new_main_row_id_list#)
    </cfquery>
    <cfquery name="get_package_1" dbtype="query">
        SELECT        
            PACKAGE_NUMBER, 
            PACKAGE_NAME, 
            PACKAGE_BOYU, 
            PACKAGE_ENI, 
            PACKAGE_KALINLIK, 
            PACKAGE_WEIGHT, 
            PACKAGE_AMOUNT, 
            PACKAGE_DETAIL, 
            PACKAGE_ROW_ID
        FROM
            get_package_all
        GROUP BY 
            PACKAGE_NUMBER, 
            PACKAGE_NAME, 
            PACKAGE_BOYU, 
            PACKAGE_ENI, 
            PACKAGE_KALINLIK, 
            PACKAGE_WEIGHT, 
            PACKAGE_AMOUNT, 
            PACKAGE_DETAIL, 
            PACKAGE_ROW_ID
        ORDER BY 
            PACKAGE_NAME
    </cfquery>
    <!---Paket Sorgusu--->
    <!---Paket Transfer--->
	<cfif get_package_all.recordcount>
        <cfif get_design_info.PROCESS_ID eq 1 or get_design_info.PROCESS_ID eq 2> <!---Modül+Paket+Parça ise veya Modül+Paket ise---> 
            <cfoutput query="get_package_1">
                <cfset attributes.HIERARCHY = get_product_cat_package.HIERARCHY>
                <cfset urun_adi = get_package_1.PACKAGE_NAME> <!---Ürün Adı Tanımı--->
                <cfquery name="get_product_info_package" datasource="#dsn3#">
                    SELECT TOP (1) STOCK_ID, PRODUCT_ID FROM STOCKS WHERE PRODUCT_NAME = '#urun_adi#' ORDER BY STOCK_ID
                </cfquery>
                <cfif not get_product_info_package.recordcount>
                    <cfquery name="get_barcode_no" datasource="#dsn3#"> <!---Barkod Tanımı--->
                        SELECT PRODUCT_NO AS BARCODE FROM #dsn1_alias#.PRODUCT_NO
                    </cfquery>
                    <cfset barcode = get_barcode_no.barcode>
                    <cfset barcode_len = len(barcode)>
                    <cfset barcode = left(barcode_on_taki,barcode_boy-barcode_len)&barcode>
                    <cfset products_cat_id = get_defaults.DEFAULT_PACKAGE_CAT_ID>
                    <cfset details = PACKAGE_DETAIL>
                    <cfset sales_type = 0>
                    <cfset purchase_type = 0>
                    <cfset product_process_stage = get_defaults.DEFAULT_PRODUCT_PROCESS_STAGE>
                    <cfset main_units = get_defaults.DEFAULT_PACKAGE_UNIT>
                    <cfset default_account_ids = get_defaults.DEFAULT_PACKAGE_ACCOUNT_ID>
                    <cfinclude template="../query/add_ezgi_product_import.cfm"> <!---Yeni Kart Açıyoruz--->
                    <cfquery name="get_product_id" datasource="#dsn3#">
                        SELECT PRODUCT_ID FROM  #dsn1_alias#.STOCKS WHERE STOCK_ID = #GET_SID.STOCK_ID# 
                    </cfquery>
                    <cfif get_design_info.IS_PROTOTIP eq 1> <!---Özelleştirilmiş Ürün İse--->
                        <cfquery name="upd_standart_urun" datasource="#dsn3#">
                            UPDATE 
                                #dsn1_alias#.PRODUCT 
                            SET 
                                IS_PROTOTYPE =1 
                            WHERE 
                                PRODUCT_ID = #get_product_id.PRODUCT_ID#
                        </cfquery>
                    </cfif>
                    <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Yeni Açılan ürün Kartı İle İlşkilendiriyoruz.--->
                        UPDATE EZGI_DESIGN_PACKAGE_ROW SET PACKAGE_RELATED_ID = #GET_SID.STOCK_ID# WHERE  PACKAGE_ROW_ID = #PACKAGE_ROW_ID#
                    </cfquery>
                    <cfset attributes.design_piece_row_id = PACKAGE_ROW_ID>
                    <cfset IID = PACKAGE_ROW_ID>
                    <cfset TYPE = 2>
                    <cfinclude template="cnt_ezgi_product_tree_import_ortak.cfm">
                    <cfif get_product_tree.recordcount>
                        <cfset is_sevk = 0>
                        <cfset is_phantom = 0>
                        <cfset is_configure =  0>
                        <cfset product_tree_process_stage = get_defaults.DEFAULT_PRODUCT_TREE_PROCESS_STAGE>
                        <cfset product_tree_workstation_id = get_defaults.DEFAULT_PACKAGE_WORKSTATION_ID>
                        <cfquery name="get_product_tree" dbtype="query">
                            SELECT * FROM get_product_tree WHERE AMOUNT > 0
                        </cfquery>
                        <cfinclude template="../query/add_ezgi_product_tree_import.cfm"> <!---Ürün Ağacı Oluşturuyoruz--->
                    </cfif>
                <cfelse>
                    <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Var OlAn Ürün Kartı İle İlşkilendiriyoruz.--->
                        UPDATE EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) SET PIECE_RELATED_ID = #get_product_info_package.STOCK_ID# WHERE DESIGN_PACKAGE_ROW_ID = #PACKAGE_ROW_ID#
                    </cfquery>
                </cfif>
            </cfoutput>
            <cfset is_find = 0>
        </cfif>
    </cfif>
	<!---Paket Transfer--->
    <!---Modül Sorgusu--->
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
            EDM.DESIGN_ID = #attributes.design_id# AND 
            EDM.DESIGN_MAIN_ROW_ID IN (#new_main_row_id_list#) AND
            EDM.DESIGN_MAIN_STATUS = 1
    </cfquery>
    <cfquery name="get_main_1" dbtype="query">
        SELECT        
            DESIGN_MAIN_ROW_ID, 
            DESIGN_MAIN_NAME
        FROM
            get_main_all
        GROUP BY 
            DESIGN_MAIN_ROW_ID, 
            DESIGN_MAIN_NAME
        ORDER BY 
            DESIGN_MAIN_NAME
    </cfquery>
    <!---Modül Sorgusu--->
    <!---Modül Transfer--->
	<cfif get_main_all.recordcount>
        <cfoutput query="get_main_1">
            <cfset attributes.HIERARCHY = get_design_info.HIERARCHY>
            <cfset urun_adi = get_main_1.DESIGN_MAIN_NAME> <!---Ürün Adı Tanımı--->
            <cfquery name="get_product_info_main" datasource="#dsn3#">
                SELECT TOP (1) STOCK_ID, PRODUCT_ID FROM STOCKS WITH (NOLOCK) WHERE PRODUCT_NAME = '#urun_adi#' ORDER BY STOCK_ID
            </cfquery>
            <cfif not get_product_info_main.recordcount>
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
                <cfset main_units = get_defaults.DEFAULT_MAIN_UNIT>
                <cfset default_account_ids = get_defaults.DEFAULT_MAIN_ACCOUNT_ID>
                <cfinclude template="../query/add_ezgi_product_import.cfm"> <!---Yeni Kart Açıyoruz--->
                <cfset attributes.design_piece_row_id = DESIGN_MAIN_ROW_ID>
                <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Yeni Açılan ürün Kartı İle İlşkilendiriyoruz.--->
                    UPDATE EZGI_DESIGN_MAIN_ROW SET DESIGN_MAIN_RELATED_ID = #GET_SID.STOCK_ID# WHERE DESIGN_MAIN_ROW_ID = #DESIGN_MAIN_ROW_ID#
                </cfquery>
                <cfset attributes.design_piece_row_id = ''>
                <cfset attributes.design_package_row_id = ''>
                <cfset attributes.design_main_row_id = DESIGN_MAIN_ROW_ID>
                <cfset IID = DESIGN_MAIN_ROW_ID>
                <cfset TYPE = 3>
                <cfinclude template="cnt_ezgi_product_tree_import_ortak.cfm">
                <cfif get_product_tree.recordcount>
                    <cfset is_sevk = 0>
                    <cfset is_phantom = 0>
                    <cfset is_configure =  0>
                    <cfset product_tree_process_stage = get_defaults.DEFAULT_PRODUCT_TREE_PROCESS_STAGE>
                    <cfset product_tree_workstation_id = get_defaults.DEFAULT_MAIN_WORKSTATION_ID>
                    <cfif get_defaults.DEFAULT_MAIN_TRANSFER_TYPE eq 2 and get_design_info.IS_PROTOTIP eq 0 and (get_design_info.PROCESS_ID eq 1 or get_design_info.PROCESS_ID eq 2)> <!---Karma Koli İse ve Özel Ürün Değilse--->
                        <cfquery name="get_product_id" datasource="#dsn3#">
                            SELECT PRODUCT_ID FROM  #dsn1_alias#.STOCKS WITH (NOLOCK) WHERE STOCK_ID = #GET_SID.STOCK_ID# 
                        </cfquery>
                        <cfset attributes.main_product_id = get_product_id.PRODUCT_ID>
                        <cfquery name="upd_karma_koli" datasource="#dsn3#">
                            UPDATE      
                                #dsn1_alias#.PRODUCT
                            SET                
                                IS_PRODUCTION = 0, 
                                IS_ZERO_STOCK = 1, 
                                IS_KARMA = 1, 
                                IS_COST = 0
                            WHERE        
                                PRODUCT_ID = #attributes.main_product_id#
                        </cfquery>
                        <cfloop query="#get_product_tree#">
                            <cfif get_product_tree.RELATED_ID gt 0> <!---Operasyon Değil İse--->
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
                                            ) AS SPECT_MAIN_ID
                                        FROM            
                                            STOCKS AS S WITH (NOLOCK) INNER JOIN
                                            PRODUCT AS P WITH (NOLOCK) ON S.PRODUCT_ID = P.PRODUCT_ID INNER JOIN
                                            PRODUCT_UNIT AS PU WITH (NOLOCK) ON P.PRODUCT_ID = PU.PRODUCT_ID
                                        WHERE        
                                            S.STOCK_ID = #get_product_tree.RELATED_ID# AND 
                                            PU.IS_MAIN = 1
                                    </cfquery>
                                    <cfif get_stock_info.recordcount>
                                        <cfset attributes.product_id = get_stock_info.PRODUCT_ID>
                                        <cfset attributes.product_name = get_stock_info.PRODUCT_NAME>
                                        <cfset attributes.add_stock_id = get_product_tree.RELATED_ID>
                                        <cfset attributes.UNIT_ID = get_stock_info.PRODUCT_UNIT_ID>
                                        <cfset attributes.main_unit = get_stock_info.MAIN_UNIT>
                                        <cfset attributes.AMOUNT = get_product_tree.AMOUNT>
                                        <cfset attributes.spect_main_id = get_stock_info.SPECT_MAIN_ID>
                                        <cfset attributes.process_stage_ = get_defaults.DEFAULT_PRODUCT_TREE_PROCESS_STAGE>
                                    <cfelse>
                                        <cfoutput>#get_product_tree.RELATED_ID#</cfoutput> STOCK_ID ile Eklenecek Ürüne Ait Bilgi Bulunamadı.
                                        <cfabort>
                                    </cfif>
                                <cfinclude template="add_ezgi_product_karma_koli.cfm">
                            </cfif>
                        </cfloop>
                        <cfif len(get_defaults.DEFAULT_MAIN_WORKSTATION_ID)>
                            <cfquery name="del_workstation_product" datasource="#dsn3#">
                                DELETE FROM WORKSTATIONS_PRODUCTS WHERE STOCK_ID = #GET_SID.STOCK_ID# AND OPERATION_TYPE_ID IS NULL
                            </cfquery>
                            <cfquery name="add_workstation_product" datasource="#dsn3#">
                             	INSERT INTO 
                                 	WORKSTATIONS_PRODUCTS
                                        (
                                        	WS_ID, 
                                            STOCK_ID, 
                                            CAPACITY, 
                                            PRODUCTION_TIME, 
                                            PRODUCTION_TIME_TYPE, 
                                            SETUP_TIME, 
                                            MIN_PRODUCT_AMOUNT, 
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
                                        	#get_defaults.DEFAULT_MAIN_WORKSTATION_ID#, 
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
                    <cfelse> <!---Standart Ürün İse--->
                        <cfquery name="get_product_id" datasource="#dsn3#">
                            SELECT PRODUCT_ID FROM  #dsn1_alias#.STOCKS WHERE STOCK_ID = #GET_SID.STOCK_ID# 
                        </cfquery>
                        <cfset attributes.main_product_id = get_product_id.PRODUCT_ID>
                        <cfquery name="upd_standart_urun" datasource="#dsn3#">
                            UPDATE      
                                #dsn1_alias#.PRODUCT
                            SET                
                                IS_PRODUCTION = 1, 
                                IS_ZERO_STOCK = 0, 
                                IS_KARMA = 0, 
                                IS_COST = 1
                                <cfif get_design_info.IS_PROTOTIP eq 1>
                                    , IS_PROTOTYPE =1
                                </cfif>
                            WHERE        
                                PRODUCT_ID = #attributes.main_product_id#
                        </cfquery>
                        <cfquery name="get_product_tree" dbtype="query">
                            SELECT * FROM get_product_tree WHERE AMOUNT > 0
                        </cfquery>
                        <cfinclude template="../query/add_ezgi_product_tree_import.cfm"> <!---Ürün Ağacı Oluşturuyoruz--->
                    </cfif>
                </cfif>
            <cfelse>
                <cfquery name="upd_relation_id" datasource="#dsn3#"> <!---Var Olan Ürün Kartı İle İlşkilendiriyoruz.--->
                    UPDATE EZGI_DESIGN_MAIN_ROW SET DESIGN_MAIN_RELATED_ID = #get_product_info_main.STOCK_ID# WHERE DESIGN_MAIN_ROW_ID = #DESIGN_MAIN_ROW_ID#
                </cfquery>
            </cfif>
        </cfoutput>
        <cfset is_find = 0>
    </cfif>
</cftransaction>
</cflock>
<!---Modül Transfer--->
<cfif is_find eq 1>
	<script type="text/javascript">
   		alert("<cf_get_lang dictionary_id='261.Aktarım Yapılacak Satır Bulunamadı!'>");
      	window.close();
 	</script>
    <cfabort>
<cfelse>
	<script type="text/javascript">
   		alert("<cf_get_lang dictionary_id='260.Aktarım Başarıyla Tamamlanmıştır!'>");
		wrk_opener_reload();
      	window.close();
 	</script>
    <cfabort>
</cfif>