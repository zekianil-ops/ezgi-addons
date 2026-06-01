<!---
    File: add_ezgi_product_import.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfquery name="get_urun_adi_control" datasource="#dsn3#">
	SELECT PRODUCT_NAME FROM #dsn1_alias#.PRODUCT WHERE PRODUCT_NAME = '#urun_adi#'
</cfquery>
<cfif get_urun_adi_control.recordcount>
	<script type="text/javascript">
		alert("<cfoutput>#get_urun_adi_control.PRODUCT_NAME#</cfoutput> <cf_get_lang dictionary_id='983.Ürünü Daha önce Tanımlanmış!'>");
		window.close()
	</script>
	<cfdump var="#attributes.iid_list#"><cfabort>
    <cfabort>
</cfif>
<cfset attributes.location = '#session.ep.company_id#,#ListGetAt(session.ep.USER_LOCATION,1,"-")#,#ListGetAt(session.ep.USER_LOCATION,2,"-")#'>
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
<cfelseif len(barcode) eq 7>
	<cfloop from="1" to="7" step="2" index="i">
    	<cfset barcode0 = '#barcode#0'> 
    	<cfset barcode_kontrol_1 = mid(barcode0,i,1)>
        <cfset barcode_kontrol_2 = mid(barcode0,i+1,1)>
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
	surec_id = product_process_stage;
	kategori_id = products_cat_id;
	is_sales = sales_type;
	is_purchase = purchase_type;
	detail = details;
	purchase_money = session.ep.money;
	sales_money = session.ep.money;
	birim = main_units;
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
	is_inventory = 1;
	is_production = 1;
	is_internet = 1;
	is_extranet = 1;
	is_zero_stock = 1;
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
</cfscript>
<cfinclude template="add_ezgi_product.cfm">
<cfinclude template="add_ezgi_product_barcode.cfm">
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
    	PRO_CODE_CATID = #default_account_ids#
</cfquery>
