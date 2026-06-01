<!---
    File: add_ezgi_yonga_levha_import_process.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 	

<cfquery name="get_design_yonga_levha_master_info" datasource="#dsn3#">
	SELECT 
    	E.STOCK_ID, 
        E.STOCK_ID2, 
        E.PRODUCT_NAME,
        E.AMOUNT
	FROM            
    	EZGI_PRODUCT_TREE_BOM1 AS E WITH (NOLOCK) INNER JOIN
      	STOCKS AS S WITH (NOLOCK) ON E.STOCK_ID2 = S.STOCK_ID INNER JOIN
      	EZGI_DESIGN_DEFAULTS AS D WITH (NOLOCK) ON S.SHORT_CODE_ID = D.DEFAULT_MASTER_SHORT_CODE_ID
	WHERE        
    	E.STOCK_ID = #attributes.STOCK_ID#
</cfquery>
<cfif get_design_yonga_levha_master_info.recordcount>
	<!---Ham Yonga Levha Ürün İmport--->
	<cfloop query="get_design_yonga_levha_master_info">
        <cfquery name="get_design_yonga_levha_ham_master_info" datasource="#dsn3#">
            SELECT   
            	S.IS_SALES,     
                S.IS_PURCHASE,
                S.PRODUCT_DETAIL,
                S.PRODUCT_CATID,
                S.PRODUCT_NAME,
                PU.MAIN_UNIT,
                PU.DIMENTION,
                (SELECT PRODUCT_PERIOD_CAT_ID FROM PRODUCT_PERIOD WITH (NOLOCK) WHERE PRODUCT_ID = S.PRODUCT_ID AND PERIOD_ID = #session.ep.period_id#) AS PRODUCT_PERIOD_CAT_ID
            FROM            
                STOCKS AS S WITH (NOLOCK) INNER JOIN
                PRODUCT_UNIT AS PU WITH (NOLOCK) ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
            WHERE        
                S.STOCK_ID = #get_design_yonga_levha_master_info.STOCK_ID2# 
        </cfquery>
        <cfset attributes.location = '#session.ep.company_id#,#ListGetAt(session.ep.USER_LOCATION,1,"-")#,#ListGetAt(session.ep.USER_LOCATION,2,"-")#'>
        <cfset attributes.HIERARCHY = ''>
        <cfif ListLen(get_design_yonga_levha_ham_master_info.PRODUCT_NAME,'-') gt 1><!---Ürün Adı Tanımı--->
            <cfset urun_adi = "#ListGetAt(get_design_yonga_levha_ham_master_info.PRODUCT_NAME,1,'-')# #get_upd.COLOR_NAME# #get_thickness.THICKNESS_VALUE# #get_thickness.UNIT# #ListGetAt(get_design_yonga_levha_ham_master_info.PRODUCT_NAME,2,'-')#"> 
        <cfelse>
            <cfset urun_adi = "#get_design_yonga_levha_ham_master_info.PRODUCT_NAME# #get_upd.COLOR_NAME# #get_thickness.THICKNESS_VALUE# #get_thickness.UNIT#">
        </cfif>
        <cfif Listlen(get_design_yonga_levha_ham_master_info.DIMENTION,'*') eq 3>
        	<cfset dimention_ = '#ListGetAt(get_design_yonga_levha_ham_master_info.DIMENTION,1,'*')#*#ListGetAt(get_design_yonga_levha_ham_master_info.DIMENTION,2,'*')#*#get_thickness.THICKNESS_VALUE#'>
       	<cfelse>
        	<cfset dimention_ = ''>	
        </cfif>
        <cfquery name="get_same_stock_control" datasource="#dsn3#">
            SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WHERE PRODUCT_NAME = '#urun_adi#'
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
                kategori_id = get_design_yonga_levha_ham_master_info.PRODUCT_CATID;
                is_sales = get_design_yonga_levha_ham_master_info.IS_SALES;
                is_purchase = get_design_yonga_levha_ham_master_info.IS_PURCHASE;
                detail = get_design_yonga_levha_ham_master_info.PRODUCT_DETAIL;
                purchase_money = session.ep.money;
                sales_money = session.ep.money;
                birim = get_design_yonga_levha_ham_master_info.MAIN_UNIT;
                product_code_2 = '';
                uye_kodu = '';
                cesit_adı = '';
                detail_2 = '';
                uretici_urun_kodu = '';
                shelf_life = '';
                segment_id = '';
                brand_id = '';
                dimention = dimention_;
                volume = '';
                weight = '';
				density='';
                is_inventory = 1;
                is_production = 0;
                is_internet = 1;
                is_extranet = 1;
				is_zero_stock=0;
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
                SELECT MAX(PRODUCT_ID) AS PRODUCT_ID FROM #dsn1_alias#.PRODUCT
            </cfquery>
            <cfquery name="GET_SID" datasource="#dsn3#">
                SELECT MAX(STOCK_ID) AS STOCK_ID FROM #dsn1_alias#.STOCKS
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
                    PRO_CODE_CATID = #get_design_yonga_levha_ham_master_info.PRODUCT_PERIOD_CAT_ID#
            </cfquery>
            <cfset 'RECETE_STOCK_ID_#get_design_yonga_levha_master_info.STOCK_ID2#' = GET_SID.stock_id>
        <cfelse>
            <cfset 'RECETE_STOCK_ID_#get_design_yonga_levha_master_info.STOCK_ID2#' = get_same_stock_control.stock_id>
        </cfif>
    </cfloop>
    <!---Ham Yonga Levha Ürün İmport--->
    
    <!---Kesilmiş Yonga Levha Ürün İmport--->
    <cfquery name="get_design_yonga_levha_kesilmis_master_info" datasource="#dsn3#">
        SELECT 
            *, 
            (SELECT MAIN_UNIT FROM PRODUCT_UNIT WITH (NOLOCK) WHERE PRODUCT_ID = STOCKS.PRODUCT_ID AND IS_MAIN = 1) as MAIN_UNIT,
            (SELECT PRODUCT_PERIOD_CAT_ID FROM PRODUCT_PERIOD WITH (NOLOCK) WHERE PRODUCT_ID = STOCKS.PRODUCT_ID AND PERIOD_ID = #session.ep.period_id#) as PRODUCT_PERIOD_CAT_ID
        FROM 
            STOCKS WITH (NOLOCK)
        WHERE 
            STOCK_ID = #attributes.STOCK_ID# 
    </cfquery>
    <cfif not len(get_design_yonga_levha_kesilmis_master_info.PRODUCT_PERIOD_CAT_ID)>
    	<script type="text/javascript">
			alert("<cfoutput>#get_design_yonga_levha_ham_master_info.PRODUCT_NAME# : <cf_get_lang dictionary_id='59059.Tanımsız Hesap Kodları'></cfoutput>");
			window.history.go(-1);
		</script>
        <cfabort>
    </cfif>
    <cfset attributes.location = '#session.ep.company_id#,#ListGetAt(session.ep.USER_LOCATION,1,"-")#,#ListGetAt(session.ep.USER_LOCATION,2,"-")#'>
	<cfset attributes.HIERARCHY = ''>
    <!---Ürün Adı Tanımı--->
 	<cfset urun_adi = "#get_design_yonga_levha_kesilmis_master_info.PRODUCT_NAME# #get_upd.COLOR_NAME# #get_thickness.THICKNESS_VALUE# #get_thickness.UNIT#">
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
      	kategori_id = get_design_yonga_levha_kesilmis_master_info.PRODUCT_CATID;
    	is_sales = get_design_yonga_levha_kesilmis_master_info.IS_SALES;
     	is_purchase = get_design_yonga_levha_kesilmis_master_info.IS_PURCHASE;
      	detail = get_design_yonga_levha_kesilmis_master_info.PRODUCT_DETAIL;
     	purchase_money = session.ep.money;
      	sales_money = session.ep.money;
      	birim = get_design_yonga_levha_kesilmis_master_info.MAIN_UNIT;
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
     	is_production = 1;
     	is_internet = 1;
       	is_extranet = 1;
		is_zero_stock = 0;
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
		bsmv = '';
		oiv = '';
  	</cfscript>
   	<cfinclude template="../../../../v16/settings/query/add_import_product.cfm">
	<cfinclude template="../../../../v16/settings/query/add_import_product_barcode.cfm">
  	<cfquery name="GET_PID" datasource="#dsn3#">
     	SELECT MAX(PRODUCT_ID) AS PRODUCT_ID FROM #dsn1_alias#.PRODUCT
   	</cfquery>
   	<cfquery name="GET_SID" datasource="#dsn3#">
     	SELECT MAX(STOCK_ID) AS STOCK_ID FROM #dsn1_alias#.STOCKS
  	</cfquery>
  	<cfquery name="upd_packege_control_type" datasource="#dsn3#">
    	UPDATE #dsn1_alias#.PRODUCT SET PACKAGE_CONTROL_TYPE = 1, IS_ZERO_STOCK = 0, IS_SALES = 0, IS_PURCHASE = 0 WHERE PRODUCT_ID = #GET_PID.PRODUCT_ID#
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
         	PRO_CODE_CATID = #get_design_yonga_levha_kesilmis_master_info.PRODUCT_PERIOD_CAT_ID#
	</cfquery>
 	<!---Kesilmiş Yonga Levha Ürün İmport--->   
    
    <!---Kesilmiş Yonga Levha Product_Tree İmport--->
    <cfquery name="get_product_tree" datasource="#dsn3#"> <!---Kesilmiş Yonga Levha Bilgi Toplama--->
    	SELECT        
        	RELATED_ID, 
            AMOUNT, 
            IS_CONFIGURE, 
            IS_SEVK, 
            OPERATION_TYPE_ID, 
            IS_PHANTOM, 
            PROCESS_STAGE,
            LINE_NUMBER,
            ISNULL((SELECT  WS_ID FROM WORKSTATIONS_PRODUCTS WITH (NOLOCK) WHERE STOCK_ID = PRODUCT_TREE.STOCK_ID),0) as WORKSTATION_ID
		FROM            
        	PRODUCT_TREE WITH (NOLOCK)
		WHERE        
        	STOCK_ID = #attributes.STOCK_ID#
       	ORDER BY
        	RELATED_ID DESC
    </cfquery>
    <cfif get_product_tree.recordcount>
		<cfset is_sevk = get_product_tree.IS_SEVK>
      	<cfset is_phantom = get_product_tree.IS_PHANTOM>
  		<cfset is_configure =  get_product_tree.IS_CONFIGURE>
     	<cfset product_tree_process_stage = get_product_tree.PROCESS_STAGE>
   		<cfset product_tree_workstation_id = get_product_tree.WORKSTATION_ID>
     	<cfinclude template="../query/add_ezgi_product_tree_import.cfm"> <!---Ürün Ağacı Oluşturuyoruz--->
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
                	#GET_PID.PRODUCT_ID#,
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
    <!---Kesilmiş Yonga Levha Product_Tree İmport---> 
<cfelse>
	<script type="text/javascript">
		alert(<cf_get_lang dictionary_id='953.Master Ürün Hatası - Master Kesilmiş Yonga Levha Ürünü veya Master Ham Yonga Levha Ürünü ait Ürün tanımlamasında veya Reçete İşleminde Hata!'>)
		window.history.go(-1);
	</script>
    <cfabort>
</cfif>
