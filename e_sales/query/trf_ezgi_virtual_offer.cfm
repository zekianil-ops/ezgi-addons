<!---
    File: trf_ezgi_virtual_offer.cfm
    Folder: Add_Ons\ezgi\e_sales\query
    Author: Ezgi Yazılım
    Date: 01/01/2022
    Description:
--->

<!---<cfdump var="#attributes#"><cfabort>--->
<cfquery name="get_process_id" datasource="#dsn#">
	SELECT        
    	TOP (1) PTR.PROCESS_ROW_ID
	FROM            
    	PROCESS_TYPE AS PT INNER JOIN
    	PROCESS_TYPE_OUR_COMPANY AS PTOC ON PT.PROCESS_ID = PTOC.PROCESS_ID INNER JOIN
     	PROCESS_TYPE_ROWS AS PTR ON PT.PROCESS_ID = PTR.PROCESS_ID
	WHERE        
    	PT.IS_ACTIVE = 1 AND 
        PTOC.OUR_COMPANY_ID = #session.ep.company_id# AND 
        CAST(PT.FACTION AS NVARCHAR(2500)) + ',' LIKE '%sales.list_offer,%'
	ORDER BY 
    	PTR.PROCESS_ROW_ID
</cfquery>
<cfif not get_process_id.recordcount>
	<script type="text/javascript">
		alert("Satış Teklifi Üzerinde Yetkili Olmalısınız!");
		window.history.go(-1);
	</script>
    <cfabort>
</cfif>
<cfquery name="GET_MAX_PAPER" datasource="#DSN3#">
	SELECT        
    	OFFER_NUMBER, 
        OFFER_NO
	FROM  
    	GENERAL_PAPERS
	WHERE
		PAPER_TYPE = 1 AND
		ZONE_TYPE = 0
</cfquery>
<cfset paper_full = '#GET_MAX_PAPER.OFFER_NO#-#GET_MAX_PAPER.OFFER_NUMBER#'>
<cfquery name="get_virtual_offer" datasource="#dsn3#">
	SELECT 
    	* ,
        ISNULL(IS_COST_DISCOUNT,0) AS N_IS_COST_DISCOUNT,
        ISNULL(E.VIRTUAL_OFFER_EMPLOYEE_ID,#session.ep.userid#) as SALES_EMPLOYEE_ID,
        (SELECT FULLNAME FROM #dsn_alias#.COMPANY WHERE COMPANY_ID = E.COMPANY_ID) AS FULLNAME,
        (SELECT PROJECT_HEAD FROM #dsn_alias#.PRO_PROJECTS WHERE PROJECT_ID = E.PROJECT_ID) AS PROJECT_HEAD
    FROM 
    	EZGI_VIRTUAL_OFFER E
    WHERE 
    	VIRTUAL_OFFER_ID = #attributes.VIRTUAL_OFFER_ID#
</cfquery>
<cfquery name="get_virtual_offer_row" datasource="#dsn3#">
	SELECT 
    	*,
        (SELECT PRODUCT_UNIT_ID FROM #dsn1_alias#.PRODUCT_UNIT WHERE PRODUCT_ID = E.PRODUCT_ID AND IS_MAIN = 1) AS PRODUCT_UNIT_ID,
        (SELECT TOP (1) SPECT_VAR_ID FROM SPECTS WHERE IS_TREE=1 AND STOCK_ID = E.STOCK_ID ORDER BY SPECT_VAR_ID DESC) as SPECT_VAR_ID,
        (SELECT TOP (1) SPECT_VAR_NAME FROM SPECTS WHERE IS_TREE=1 AND STOCK_ID = E.STOCK_ID ORDER BY SPECT_VAR_ID DESC) as SPECT_VAR_NAME,
        ISNULL(QUANTITY,0) AS AMOUNT, 
        ISNULL(PRICE,0)+ISNULL(COST,0) AS SALES_PRICE,
        ISNULL(PRICE,0) AS N_PRICE,
        ISNULL(COST,0) AS N_COST, 
        ISNULL(OTHER_MONEY,'#session.ep.money#') AS MONEY, 
        ISNULL(DISCOUNT_1,0) AS DISCOUNT, 
        ISNULL(DISCOUNT_2,0) AS DISCOUNT2,
        ISNULL(DISCOUNT_3,0) AS DISCOUNT3,
        ISNULL(DISCOUNT_COST,0) AS DISCOUNT_TUT,
        ISNULL(DELIVER_AMOUNT,0) AS DELIVER_AMOUNT_ 
  	FROM 
    	EZGI_VIRTUAL_OFFER_ROW E
   	WHERE 
    	VIRTUAL_OFFER_ID = #attributes.VIRTUAL_OFFER_ID# AND
        VIRTUAL_OFFER_ROW_CURRENCY = 2
  	ORDER BY
    	VIRTUAL_OFFER_ROW_ID
</cfquery>
<cfquery name="get_virtual_offer_money" datasource="#dsn3#">
	SELECT        
    	MONEY_TYPE, 
        RATE2, 
        RATE1, 
        IS_SELECTED
	FROM            
    	EZGI_VIRTUAL_OFFER_MONEY
	WHERE        
    	ACTION_ID = #attributes.VIRTUAL_OFFER_ID#
</cfquery>
<cfif  len(get_virtual_offer.PARTNER_COMPANY_ID)> <!---Eğer Sanal Teklif Bayi Tarafından Girilmişse--->
	<cfquery name="get_partner" datasource="#dsn#">
    	SELECT        
        	CP.COMPANY_ID, 
            C.FULLNAME, 
            CP.COMPANY_PARTNER_NAME, 
            CP.COMPANY_PARTNER_SURNAME
		FROM            
        	COMPANY_PARTNER AS CP INNER JOIN
          	COMPANY AS C ON CP.COMPANY_ID = C.COMPANY_ID
		WHERE        
        	CP.PARTNER_ID = #get_virtual_offer.PARTNER_COMPANY_ID#
    </cfquery>
    <cfset attributes.member_name= get_partner.FULLNAME>
	<cfset attributes.company_id= get_partner.company_id>
    <cfset attributes.partner_id = get_virtual_offer.PARTNER_COMPANY_ID>
    <cfset attributes.member_type = 'partner'>,
    <cfset attributes.consumer_id= ''>
    <cfif len(get_virtual_offer.company_id)>
    	<cfquery name="get_nihai" datasource="#dsn#">
            SELECT FULLNAME AS MEMBER_NAME FROM COMPANY WHERE COMPANY_ID = #get_virtual_offer.company_id#
        </cfquery>
    	<cfset attributes.ref_member_id = get_virtual_offer.partner_id>
		<cfset attributes.ref_company_id = get_virtual_offer.company_id>
        <cfset attributes.ref_member_type = 'partner'>
   	<cfelse>
    	<cfquery name="get_nihai" datasource="#dsn#">
        	SELECT CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS MEMBER_NAME FROM CONSUMER WHERE CONSUMER_ID = #get_virtual_offer.consumer_id#
        </cfquery>
    	<cfset attributes.ref_member_id = get_virtual_offer.consumer_id>
        <cfset attributes.ref_member_type = 'consumer'>
    </cfif> 
    <cfset attributes.offer_detail= '#get_nihai.MEMBER_NAME# - #get_virtual_offer.virtual_offer_DETAIL#'>
<cfelse>
	<cfif len(get_virtual_offer.company_id)>
		<cfset attributes.member_name= get_virtual_offer.FULLNAME>
        <cfset attributes.company_id= get_virtual_offer.company_id>
        <cfset attributes.partner_id = get_virtual_offer.partner_id>
        <cfset attributes.consumer_id= ''>
    <cfelse>
    	<cfquery name="get_consumer" datasource="#dsn#">
        	SELECT        
            	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS MEMBER_NAME
			FROM      
            	CONSUMER
			WHERE        
            	CONSUMER_ID = #get_virtual_offer.consumer_id#
        </cfquery>
        <cfset attributes.member_name= get_consumer.MEMBER_NAME>
    	<cfset attributes.consumer_id= get_virtual_offer.consumer_id>
        <cfset attributes.company_id= ''>
        <cfset attributes.partner_id = ''>
    </cfif>	
  	<cfset attributes.member_type = get_virtual_offer.member_type>
    <cfset attributes.offer_detail= get_virtual_offer.virtual_offer_DETAIL>
</cfif>

<cfset attributes.sales_emp_id = get_virtual_offer.SALES_EMPLOYEE_ID>
<cfset attributes.sales_emp = get_emp_info(get_virtual_offer.SALES_EMPLOYEE_ID,0,0)>
<cfset attributes.offer_date = DateFormat(now(),'dd/mm/yyyy')>
<cfset attributes.deliverdate= DateFormat(get_virtual_offer.DELIVERDATE,'dd/mm/yyyy')>
<cfset attributes.ship_date= DateFormat(get_virtual_offer.DELIVERDATE,'dd/mm/yyyy')>
<cfset attributes.finishdate = ''>
<cfset attributes.offer_head= '#get_virtual_offer.VIRTUAL_OFFER_NUMBER# - #get_virtual_offer.virtual_offer_HEAD#'>

<cfset attributes.project_head = get_virtual_offer.PROJECT_HEAD>
<cfset attributes.project_id= get_virtual_offer.PROJECT_ID>
<cfset attributes.ref_no = get_virtual_offer.REF_NO>
<cfset attributes.price = 0>
<cfset attributes.process_stage = get_process_id.PROCESS_ROW_ID>
<cfset attributes.paymethod_id = ''>
<cfset attributes.pay_method = ''>
<cfset attributes.card_paymethod_id = ''>
<cfset attributes.commission_rate = ''>
<cfset attributes.ship_method_id = ''>
<cfset attributes.ship_address = get_virtual_offer.SHIP_ADDRESS>
<cfset attributes.ship_address_id =get_virtual_offer.SHIP_ADDRESS_ID>
<cfset attributes.sales_add_option= ''>
<cfset attributes.xml_offer_revision= 0>
<cfset attributes.offer_status = 1>
<cfset form.active_company = session.ep.company_id>
<cfset attributes.rows_ = get_virtual_offer_row.recordcount>
<cfset attributes.kur_say = get_virtual_offer_money.recordcount>
<cfoutput query="get_virtual_offer_money">
	<cfif IS_SELECTED>
		<cfset attributes.basket_money = MONEY_TYPE>
        <cfset form.basket_money = MONEY_TYPE>
        <cfset form.BASKET_RATE1 = RATE1>
        <cfset form.BASKET_RATE2 = RATE2>
        <cfset attributes.BASKET_RATE1 = RATE1>
        <cfset attributes.BASKET_RATE2 = RATE2>
    </cfif>
    <cfset 'attributes.hidden_rd_money_#currentrow#' = MONEY_TYPE>
    <cfset 'attributes.txt_rate2_#currentrow#' = RATE2>
    <cfset 'attributes.txt_rate1_#currentrow#' = RATE1>
</cfoutput>
<cfset form.basket_net_total = 0>
<cfset attributes.basket_net_total = 0>
<cfloop query="get_virtual_offer_row">
	<cfset 'attributes.deliver_date#currentrow#' = get_virtual_offer_row.DELIVER_DATE>
  	<cfset 'attributes.product_id#currentrow#' = get_virtual_offer_row.PRODUCT_ID>
  	<cfset 'attributes.stock_id#currentrow#' = get_virtual_offer_row.STOCK_ID>
 	<cfset 'attributes.amount#currentrow#' = get_virtual_offer_row.AMOUNT>
  	<cfset 'attributes.amount_other#currentrow#' = get_virtual_offer_row.AMOUNT>
   	<cfset 'attributes.unit#currentrow#' = get_virtual_offer_row.UNIT>
 	<cfset 'attributes.unit_other#currentrow#' = get_virtual_offer_row.UNIT>
  	<cfset 'attributes.unit_id#currentrow#' = get_virtual_offer_row.PRODUCT_UNIT_ID>
    <cfset 'attributes.product_name#currentrow#' = get_virtual_offer_row.PRODUCT_NAME>
  	<cfset 'attributes.spect_id#currentrow#' = get_virtual_offer_row.SPECT_VAR_ID>
  	<cfset 'attributes.spect_name#currentrow#' = get_virtual_offer_row.SPECT_VAR_NAME>
  	<cfset 'attributes.product_name_other#currentrow#' = get_virtual_offer_row.PRODUCT_NAME2>
    <cfset 'attributes.is_promotion#currentrow#' = 0>
	<cfset 'attributes.list_price#currentrow#' = 0>
 	<cfset 'attributes.basket_extra_info#currentrow#' = -1>
	<cfif  len(get_virtual_offer.PARTNER_COMPANY_ID)> <!---Eğer Sanal Teklif Bayi Tarafından Girilmişse--->
    	<cfquery name="GET_PURCHASE" datasource="#DSN3#">
            SELECT        
            	ISNULL(PURCHASE_PRICE * SM.RATE2,0) AS PURCHASE_PRICE
			FROM            
           		EZGI_VIRTUAL_OFFER_ROW AS EVOR INNER JOIN
              	#dsn_alias#.SETUP_MONEY AS SM ON EVOR.PURCHASE_PRICE_MONEY = SM.MONEY
			WHERE        
            	EVOR.EZGI_ID = #get_virtual_offer_row.ezgi_id# AND
                SM.PERIOD_ID = #session.ep.period_id#    
        </cfquery>
        <cfquery name="GET_COST" datasource="#DSN3#"> <!---Bayinin merkez tarfından talep ettiği hizmetlerin toplamı--->
        	SELECT        
            	 ISNULL(SUM(ROW_TOTAL), 0) AS COST
			FROM           
            	EZGI_MONTAGE_ROW
			WHERE        
            	EZGI_ID = #get_virtual_offer_row.ezgi_id# AND 
                ISNULL(IS_HZM, 0) = 1
        </cfquery>
        <cfset 'attributes.price#currentrow#' = GET_PURCHASE.PURCHASE_PRICE+GET_COST.COST>
        <cfset 'attributes.other_money_value_#currentrow#' = GET_PURCHASE.PURCHASE_PRICE+GET_COST.COST>
        <cfset 'attributes.price_other#currentrow#' = GET_PURCHASE.PURCHASE_PRICE+GET_COST.COST>
        <cfset 'attributes.other_money_#currentrow#' = session.ep.money>
        <cfset 'attributes.tax#currentrow#' = get_virtual_offer_row.TAX>
    <cfelse>
        <cfset 'attributes.price#currentrow#' = get_virtual_offer_row.SALES_PRICE>
        <cfset 'attributes.other_money_value_#currentrow#' = get_virtual_offer_row.SALES_PRICE>
        <cfset 'attributes.price_other#currentrow#' = get_virtual_offer_row.SALES_PRICE>
        <cfset 'attributes.other_money_#currentrow#' = get_virtual_offer_row.OTHER_MONEY>
        <cfset 'attributes.tax#currentrow#' = get_virtual_offer_row.TAX>
        <cfif get_virtual_offer.N_IS_COST_DISCOUNT eq 1> <!---Eğer Hizmet İndirime Girmez İse Yüzde İskontolar Tutar İskontoya Çevriliyor.--->
        	<cfset total_brut_other_ = get_virtual_offer_row.AMOUNT*(get_virtual_offer_row.N_PRICE+get_virtual_offer_row.N_COST)>
                            
         	<cfset total_net_other_ = get_virtual_offer_row.AMOUNT*get_virtual_offer_row.N_PRICE>
          	<cfset total_net_other_ = total_net_other_-(get_virtual_offer_row.DISCOUNT_TUT*get_virtual_offer_row.AMOUNT)>
           	<cfset total_net_other_ = total_net_other_-(total_net_other_*get_virtual_offer_row.DISCOUNT_1/100)>
          	<cfset total_net_other_ = total_net_other_-(total_net_other_*get_virtual_offer_row.DISCOUNT_2/100)>
         	<cfset total_net_other_ = total_net_other_-(total_net_other_*get_virtual_offer_row.DISCOUNT_3/100)>
           	<cfset total_net_other_ = total_net_other_+(get_virtual_offer_row.N_COST*get_virtual_offer_row.AMOUNT)>
			
			<cfset 'attributes.indirim1#currentrow#' = 0>
            <cfset 'attributes.indirim2#currentrow#' = 0>
            <cfset 'attributes.indirim3#currentrow#' = 0>
            <cfset 'attributes.iskonto_tutar#currentrow#' = (total_brut_other_- total_net_other_)/get_virtual_offer_row.AMOUNT>
            
        <cfelse>
			<cfset 'attributes.indirim1#currentrow#' = get_virtual_offer_row.DISCOUNT_1>
            <cfset 'attributes.indirim2#currentrow#' = get_virtual_offer_row.DISCOUNT_2>
            <cfset 'attributes.indirim3#currentrow#' = get_virtual_offer_row.DISCOUNT_3>
            <cfset 'attributes.iskonto_tutar#currentrow#' = get_virtual_offer_row.DISCOUNT_TUT>
        </cfif>
    </cfif>
    <cfset 'attributes.wrk_row_id#currentrow#' = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')# & #session.ep.company_id# & #currentrow#>
    <cfquery name="upd_VIRTUAL_OFFER" datasource="#dsn3#">
    	UPDATE       
        	EZGI_VIRTUAL_OFFER_ROW
		SET                
        	WRK_ROW_RELATION_ID = '#Evaluate('attributes.wrk_row_id#currentrow#')#',
            VIRTUAL_OFFER_ROW_CURRENCY = 3
		WHERE        
        	VIRTUAL_OFFER_ROW_ID = #get_virtual_offer_row.virtual_offer_ROW_ID#
    </cfquery>
</cfloop>
<cfset fuseaction='sales.emptypopup_trf_ezgi_virtual_offer'>
<cfinclude template="../../../../v16/sales/query/add_offer.cfm">
<cfquery name="upd_offer_branch" datasource="#dsn3#">
	UPDATE
    	OFFER
  	SET
    	BRANCH_ID = #get_virtual_offer.BRANCH_ID#
  	WHERE
    	OFFER_ID = #get_max_offer.max_id#
</cfquery>
<script type="text/javascript">
	alert("Satış Teklifine Transfer İşlemi Tamamlanmıştır.!");
	window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_virtual_offer&event=upd&virtual_offer_id=#attributes.VIRTUAL_OFFER_ID#</cfoutput>";
</script>
