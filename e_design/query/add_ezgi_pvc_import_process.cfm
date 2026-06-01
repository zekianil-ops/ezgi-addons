<!---
    File: add_ezgi_pvc_import_process.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfif len(get_defaults.DEFAULT_MASTER_PVC_STOCK_ID)>
	<!---Ham PVC Ürün İmport--->
    <cfquery name="get_design_pvc_master_info" datasource="#dsn3#">
       	SELECT 
       		*, 
         	(SELECT MAIN_UNIT FROM PRODUCT_UNIT WHERE PRODUCT_ID = STOCKS.PRODUCT_ID AND IS_MAIN = 1) as MAIN_UNIT,
         	(SELECT PRODUCT_PERIOD_CAT_ID FROM PRODUCT_PERIOD WHERE PRODUCT_ID = STOCKS.PRODUCT_ID AND PERIOD_ID = #session.ep.period_id#) as PRODUCT_PERIOD_CAT_ID
       	FROM 
         	STOCKS 
      	WHERE 
      		STOCK_ID = #get_defaults.DEFAULT_MASTER_PVC_STOCK_ID#	
    </cfquery>
    <cfif not len(get_design_pvc_master_info.PRODUCT_PERIOD_CAT_ID)>
    	<script type="text/javascript">
			alert(<cf_get_lang dictionary_id='57730.Seçtiğiniz Ürünün Muhasebe Kodu Tanımlanmamış!'>)
			window.history.go(-1);
		</script>
		<cfabort>
    </cfif>
	<cfif get_design_pvc_master_info.recordcount>
        <cfset attributes.location = '#session.ep.company_id#,#ListGetAt(session.ep.USER_LOCATION,1,"-")#,#ListGetAt(session.ep.USER_LOCATION,2,"-")#'>
        <cfset attributes.HIERARCHY = ''>
        <cfset urun_adi = #Evaluate('attributes.PVC_PRODUCT_NAME_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#')#>
        <cfquery name="get_same_stock_control" datasource="#dsn3#">
            SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE PRODUCT_NAME = '#urun_adi#'
        </cfquery>
        <cfif not get_same_stock_control.recordcount><!--- Yeni Açılacak Ham Ürün Kontrolü--->
            <cfquery name="get_barcode_no" datasource="#dsn3#"> <!---Barkod Tanımı--->
                SELECT PRODUCT_NO AS BARCODE FROM #dsn1_alias#.PRODUCT_NO WITH (NOLOCK)
            </cfquery>
            <cfset barcode_on_taki = '100000000000'>
            <cfset barcode = get_barcode_no.barcode>
            <cfset barcode_len = len(barcode)>
            <cfset barcode = left(barcode_on_taki,12-barcode_len)&barcode>
            <cfset barcode_tek = 0>
            <cfset barcode_cift =0>
            <cfif len(barcode) eq 12>
                <cfloop from="1" to="11" step="2" index="i">
                    <cfset barcode_kontrol_1 = mid(barcode,i,1)>
                    <cfset barcode_kontrol_2 = mid(barcode,i+1,1)>
                    <cfset barcode_tek = (barcode_tek*1) + (barcode_kontrol_1*1)>
                    <cfset barcode_cift = (barcode_cift*1) + (barcode_kontrol_2*1)>
                </cfloop>
                <cfset barcode_toplam = (barcode_cift*3)+(barcode_tek*1)>
                <cfset barcode_control_char = right(barcode_toplam,1)*1>
                <cfif barcode_control_char gt 0>
                    <cfset barcode_control_char = 10-barcode_control_char>
                <cfelse>
                    <cfset barcode_control_char = 0>
                </cfif>
                <cfset barcode_no = '#barcode##barcode_control_char#'>
            <cfelse>
                <cfset barcode_no = ''>
            </cfif>
            <cfset short_code = ''>
            <cfset short_code_id = ''>
            <cfscript>
                surec_id = get_defaults.DEFAULT_PRODUCT_PROCESS_STAGE;
                kategori_id = get_design_pvc_master_info.PRODUCT_CATID;
                is_sales = get_design_pvc_master_info.IS_SALES;
                is_purchase = get_design_pvc_master_info.IS_PURCHASE;
                detail = get_design_pvc_master_info.PRODUCT_DETAIL;
                purchase_money = session.ep.money;
                sales_money = session.ep.money;
                birim = get_design_pvc_master_info.MAIN_UNIT;
                product_code_2 = '';
                uye_kodu = '';
                cesit_adı = '';
                detail_2 = '';
                uretici_urun_kodu = '';
                shelf_life = '';
                segment_id = '';
                brand_id = '';
                dimention = '';
                volume = '';
                weight = '';
		density='';
                is_inventory = 1;
                is_production = 0;
                is_internet = 1;
				is_zero_stock = 0;
                is_extranet = 1;
                fiyat_yetkisi = 1;
                is_limited_stock = 0;
                is_quality = 0;
                min_margin = 0;
                max_margin = 0;
                alis_fiyat_kdvsiz = 0;
                alis_fiyat_kdvli = 0;
                alis_kdv = 0;
                satis_fiyat_kdvsiz = 0;
                satis_fiyat_kdvli = 0;
                satis_kdv = 0;
				bsmv = 0;
				oiv = 0;
            </cfscript>
		<cfset attributes.company_id = "">
            <cfinclude template="../../../../v16/settings/query/add_import_product.cfm">
            <cfinclude template="../../../../v16/settings/query/add_import_product_barcode.cfm">
            <cfquery name="GET_PID" datasource="#dsn3#">
                SELECT MAX(PRODUCT_ID) AS PRODUCT_ID FROM #dsn1_alias#.PRODUCT WITH (NOLOCK)
            </cfquery>
            <cfquery name="GET_SID" datasource="#dsn3#">
                SELECT MAX(STOCK_ID) AS STOCK_ID FROM #dsn1_alias#.STOCKS WITH (NOLOCK)
            </cfquery>
            <cfquery name="upd_packege_control_type" datasource="#dsn3#">
                UPDATE #dsn1_alias#.PRODUCT SET PACKAGE_CONTROL_TYPE = 1, IS_ZERO_STOCK = 0, IS_SALES = 1, IS_PURCHASE = 1 WHERE PRODUCT_ID = #GET_PID.PRODUCT_ID#
            </cfquery>
            <cfquery name="add_account_code" datasource="#dsn3#">
                INSERT INTO PRODUCT_PERIOD
                    (
                    PRODUCT_ID, PERIOD_ID, 
                    ACCOUNT_CODE, ACCOUNT_CODE_PUR, ACCOUNT_DISCOUNT, ACCOUNT_PRICE, ACCOUNT_PRICE_PUR, ACCOUNT_PUR_IADE, ACCOUNT_IADE, ACCOUNT_YURTDISI, 
                    ACCOUNT_YURTDISI_PUR, ACCOUNT_DISCOUNT_PUR, EXPENSE_CENTER_ID, EXPENSE_ITEM_ID, INCOME_ITEM_ID, EXPENSE_TEMPLATE_ID, ACTIVITY_TYPE_ID, COST_EXPENSE_CENTER_ID, 
                    INCOME_ACTIVITY_TYPE_ID, INCOME_TEMPLATE_ID, ACCOUNT_LOSS, ACCOUNT_EXPENDITURE, OVER_COUNT, UNDER_COUNT, PRODUCTION_COST, HALF_PRODUCTION_COST, SALE_PRODUCT_COST,
                    MATERIAL_CODE, KONSINYE_PUR_CODE, KONSINYE_SALE_CODE, KONSINYE_SALE_NAZ_CODE, DIMM_CODE, DIMM_YANS_CODE, PROMOTION_CODE, PRODUCT_PERIOD_CAT_ID, INVENTORY_CODE, 
                    INVENTORY_CAT_ID, AMORTIZATION_METHOD_ID, AMORTIZATION_TYPE_ID, AMORTIZATION_EXP_CENTER_ID, AMORTIZATION_EXP_ITEM_ID, AMORTIZATION_CODE, PROD_GENERAL_CODE,
                    PROD_LABOR_COST_CODE, RECEIVED_PROGRESS_CODE, PROVIDED_PROGRESS_CODE, SALE_MANUFACTURED_COST, SCRAP_CODE, MATERIAL_CODE_SALE, PRODUCTION_COST_SALE, 
                    SCRAP_CODE_SALE
                    )
                SELECT        
                     #GET_PID.PRODUCT_ID#, #session.ep.period_id#,
                    ACCOUNT_CODE, ACCOUNT_CODE_PUR, ACCOUNT_DISCOUNT, ACCOUNT_PRICE, ACCOUNT_PRICE_PUR, ACCOUNT_PUR_IADE, ACCOUNT_IADE, ACCOUNT_YURTDISI, 
                    ACCOUNT_YURTDISI_PUR, ACCOUNT_DISCOUNT_PUR,EXP_CENTER_ID,    EXP_ITEM_ID,   INC_ITEM_ID, EXP_TEMPLATE_ID,   EXP_ACTIVITY_TYPE_ID,     INC_CENTER_ID,
                    INC_ACTIVITY_TYPE_ID, INC_TEMPLATE_ID, ACCOUNT_LOSS,   ACCOUNT_EXPENDITURE, OVER_COUNT, UNDER_COUNT, PRODUCTION_COST, HALF_PRODUCTION_COST, SALE_PRODUCT_COST,
                    MATERIAL_CODE,KONSINYE_PUR_CODE, KONSINYE_SALE_CODE, KONSINYE_SALE_NAZ_CODE, DIMM_CODE, DIMM_YANS_CODE, PROMOTION_CODE, PRO_CODE_CATID,   INVENTORY_CODE,
                    INVENTORY_CAT_ID,AMORTIZATION_METHOD_ID, AMORTIZATION_TYPE_ID, AMORTIZATION_EXP_CENTER_ID, AMORTIZATION_EXP_ITEM_ID, AMORTIZATION_CODE, PROD_GENERAL_CODE,
                    PROD_LABOR_COST_CODE, RECEIVED_PROGRESS_CODE, PROVIDED_PROGRESS_CODE, SALE_MANUFACTURED_COST , SCRAP_CODE, MATERIAL_CODE_SALE, PRODUCTION_COST_SALE,
                    SCRAP_CODE_SALE
                FROM            
                    SETUP_PRODUCT_PERIOD_CAT WITH (NOLOCK)
                WHERE        
                    PRO_CODE_CATID = #get_design_pvc_master_info.PRODUCT_PERIOD_CAT_ID#
            </cfquery>
        </cfif>
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
                	#GET_PID.PRODUCT_ID#,
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
              		#GET_PID.PRODUCT_ID#,
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
              		#GET_PID.PRODUCT_ID#,
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
    <cfelse>
    	<script type="text/javascript">
			alert(<cf_get_lang dictionary_id='951.Tasarım Genel Tanımlarında PVC Master Ürün Tanımı Yapılmamış. Lütfen Düzenleyiniz!'>)
			window.history.go(-1);
		</script>
		<cfabort>
    </cfif>
    <!---Ham PVC Ürün İmport--->
<cfelse>
	<script type="text/javascript">
		alert(<cf_get_lang dictionary_id='951.Tasarım Genel Tanımlarında PVC Master Ürün Tanımı Yapılmamış. Lütfen Düzenleyiniz!'>)
		window.history.go(-1);
	</script>
    <cfabort>
</cfif>
