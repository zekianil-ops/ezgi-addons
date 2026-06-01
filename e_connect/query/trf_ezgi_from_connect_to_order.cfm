<!---<cfdump var="#attributes#"><cfabort>--->
<cf_xml_page_edit fuseact="sales.list_ezgi_connect">
<cfquery name="get_connect_default" datasource="#dsn3#">
	SELECT VALIDATE_DATE, DELIVERY_DATE FROM EZGI_CONNECT_SETUP
</cfquery>
<cfquery name="get_offer_relations" datasource="#dsn3#">
	SELECT 
    	ECR.CONNECT_ROW_ID
	FROM     
    	EZGI_CONNECT_ROW AS ECR INNER JOIN
        OFFER_ROW AS OFR ON ECR.WRK_ROW_RELATION_ID = OFR.WRK_ROW_ID
	WHERE  
    	ECR.CONNECT_ID = #attributes.connect_id#
</cfquery>
<cfif get_offer_relations.recordcount>
	<script type="text/javascript">
		alert("Daha Önce Transfer Yapılmıştır!");
		window.history.go(-1);
	</script>
    <cfabort>
</cfif>
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
<cfquery name="get_connect" datasource="#dsn3#">
	SELECT 
    	* ,
        ISNULL(E.CONNECT_EMPLOYEE_ID,#session.ep.userid#) as SALES_EMPLOYEE_ID,
        (SELECT FULLNAME FROM #dsn_alias#.COMPANY WHERE COMPANY_ID = E.COMPANY_ID) AS FULLNAME,
        (SELECT PROJECT_HEAD FROM #dsn_alias#.PRO_PROJECTS WHERE PROJECT_ID = E.PROJECT_ID) AS PROJECT_HEAD
    FROM 
    	EZGI_CONNECT E
    WHERE 
    	CONNECT_ID = #attributes.connect_ID#
</cfquery>
<cfif len(get_connect_default.VALIDATE_DATE) and isnumeric(get_connect_default.VALIDATE_DATE)>
	<cfset attributes.finishdate = Dateformat(DateAdd('d',get_connect_default.VALIDATE_DATE,now()),dateformat_style)>
<cfelse>
	<cfset attributes.finishdate =''>
</cfif>
<cfif get_connect.PROJECT_ID eq x_ssh> <!---SSH Sepeti mi?--->
	<cfquery name="get_asset" datasource="#dsn3#">
    	SELECT ASSET_FILE_NAME FROM #dsn_alias#.ASSET WHERE MODULE_ID = 13 AND ACTION_ID = #attributes.connect_id# AND ACTION_SECTION = 'OFFER_ID'
    </cfquery>
    <cfif not get_asset.recordcount>
    	<script type="text/javascript">
			alert("Satış Sonrası Hizmet Formarına Mutlaka Görünüm Yüklemelisiniz!");
			window.history.go(-1);
		</script>
		<cfabort>
    </cfif>
<cfelseif len(get_connect.PROJECT_ID)> <!---Kampanya Sepeti mi?--->
	<cfquery name="get_project_info" datasource="#dsn#">
    	SELECT 
        	TARGET_FINISH 
      	FROM     
        	PRO_PROJECTS
		WHERE  
        	PROJECT_ID = #get_connect.PROJECT_ID#
    </cfquery>
    <cfif get_project_info.recordcount and len(get_project_info.TARGET_FINISH)>
    	<cfset attributes.finishdate =DateFormat(get_project_info.TARGET_FINISH,dateformat_style)>
	</cfif>
</cfif>

<cfquery name="get_connect_row" datasource="#dsn3#">
	SELECT 
    	*,
        (SELECT PRODUCT_UNIT_ID FROM #dsn1_alias#.PRODUCT_UNIT WHERE PRODUCT_ID = E.PRODUCT_ID AND IS_MAIN = 1) AS PRODUCT_UNIT_ID,
        (SELECT TOP (1) SPECT_VAR_ID FROM SPECTS WHERE STOCK_ID = E.STOCK_ID ORDER BY SPECT_VAR_ID DESC) as SPECT_VAR_ID,
        (SELECT TOP (1) SPECT_VAR_NAME FROM SPECTS WHERE STOCK_ID = E.STOCK_ID ORDER BY SPECT_VAR_ID DESC) as SPECT_VAR_NAME,
        ISNULL(QUANTITY,0) AS AMOUNT, 
        ISNULL(PRICE,0) AS SALES_PRICE, 
        ISNULL(PRICE_OTHER,0) AS SALES_PRICE_OTHER, 
        ISNULL(OTHER_MONEY,'#session.ep.money#') AS MONEY, 
        ISNULL(DISCOUNT_1,0) AS DISCOUNT, 
        ISNULL(DISCOUNT_2,0) AS DISCOUNT2,
        ISNULL(DISCOUNT_3,0) AS DISCOUNT3,
        ISNULL(DISCOUNT_COST,0) AS DISCOUNT_TUT,
        ISNULL(DELIVER_AMOUNT,0) AS DELIVER_AMOUNT_ 
  	FROM 
    	EZGI_CONNECT_ROW E
   	WHERE 
    	CONNECT_ID = #attributes.connect_ID#
  	ORDER BY
    	CONNECT_ROW_ID
</cfquery>
<cfquery name="get_connect_money" datasource="#dsn3#">
	SELECT        
    	MONEY_TYPE, 
        RATE2, 
        RATE1, 
        IS_SELECTED
	FROM            
    	EZGI_CONNECT_MONEY
	WHERE        
    	ACTION_ID = #attributes.connect_ID#
</cfquery>
<!---<cfdump var="#get_connect#">
<cfdump var="#get_connect_money#">
<cfdump var="#get_connect_row#">--->
<cfif  len(get_connect.company_id) or len(get_connect.consumer_id)>
	<cfif len(get_connect.company_id)>
		<cfset attributes.member_name= get_connect.FULLNAME>
        <cfset attributes.company_id= get_connect.company_id>
        <cfset attributes.partner_id = get_connect.partner_id>
        <cfset attributes.consumer_id= ''>
    <cfelse>
    	<cfquery name="get_consumer" datasource="#dsn#">
        	SELECT        
            	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS MEMBER_NAME
			FROM      
            	CONSUMER
			WHERE        
            	CONSUMER_ID = #get_connect.consumer_id#
        </cfquery>
        <cfset attributes.member_name= get_consumer.MEMBER_NAME>
    	<cfset attributes.consumer_id= get_connect.consumer_id>
        <cfset attributes.company_id= ''>
        <cfset attributes.partner_id = ''>
    </cfif>	
  	<cfset attributes.member_type = get_connect.member_type>
    <cfset attributes.offer_detail= get_connect.CONNECT_DETAIL>
<cfelse>
	Kurumsal veya Bireysel Üye Bulunamamıştır.
	<cfabort>
</cfif>


<cfset attributes.basket_net_total = get_connect.NETTOTAL>
<cfset form.basket_net_total = get_connect.NETTOTAL>
<cfset attributes.genel_indirim = 0>
<cfset attributes.basket_tax_total = get_connect.TAXTOTAL>
<cfset attributes.sales_emp_id = get_connect.SALES_EMPLOYEE_ID>
<cfset attributes.sales_emp = get_emp_info(get_connect.SALES_EMPLOYEE_ID,0,0)>
<cfset attributes.offer_date = DateFormat(get_connect.CONNECT_DATE,dateformat_style)>
<cfif len(get_connect_default.DELIVERY_DATE) and isnumeric(get_connect_default.DELIVERY_DATE)>
	<cfset attributes.deliverdate= Dateformat(DateAdd('d',get_connect_default.DELIVERY_DATE,now()),dateformat_style)>
    <cfset attributes.ship_date= Dateformat(DateAdd('d',get_connect_default.DELIVERY_DATE,now()),dateformat_style)>
<cfelse>
	<cfset attributes.deliverdate= DateFormat(get_connect.DELIVERDATE,dateformat_style)>
    <cfset attributes.ship_date= DateFormat(get_connect.DELIVERDATE,dateformat_style)>
</cfif>

<cfset attributes.offer_head= get_connect.CONNECT_HEAD>
<cfset attributes.branch_id= get_connect.BRANCH_ID>

<cfset attributes.project_head = get_connect.PROJECT_HEAD>
<cfset attributes.project_id= get_connect.PROJECT_ID>
<cfset attributes.ref_no = get_connect.REF_NO>
<cfset attributes.price = 0>
<cfset attributes.process_stage = get_process_id.PROCESS_ROW_ID>
<cfset attributes.paymethod_id = ''>
<cfset attributes.pay_method = ''>
<cfset attributes.card_paymethod_id = ''>
<cfset attributes.commission_rate = ''>
<cfset attributes.ship_method_id = ''>
<cfset attributes.ship_address = ''>
<cfset attributes.sales_add_option= ''>
<cfset attributes.xml_offer_revision= 0>
<cfset attributes.offer_status = 1>
<cfset attributes.ship_address_id =-1>
<cfset form.active_company = session.ep.company_id>
<cfset attributes.rows_ = get_connect_row.recordcount>
<cfset attributes.kur_say = get_connect_money.recordcount>

<cfoutput query="get_connect_money">
	<cfif IS_SELECTED>
		<cfset attributes.basket_money = MONEY_TYPE>
        <cfset form.basket_money = MONEY_TYPE>
        <cfset form.BASKET_RATE1 = RATE1>
        <cfset form.BASKET_RATE2 = RATE2>
        
      	<cfset attributes.basket_money = MONEY_TYPE>
        <cfset attributes.BASKET_RATE1 = RATE1>
        <cfset attributes.BASKET_RATE2 = RATE2>
    </cfif>
    <cfset 'attributes.hidden_rd_money_#currentrow#' = MONEY_TYPE>
    <cfset 'attributes.txt_rate2_#currentrow#' = RATE2>
    <cfset 'attributes.txt_rate1_#currentrow#' = RATE1>
</cfoutput>

<cfloop query="get_connect_row">
	<cfif isnumeric(get_connect_row.SALES_PRICE_OTHER)>
    	<cfset netprice = get_connect_row.SALES_PRICE_OTHER>
  	<cfelse>
    	<cfset netprice = 0>
    </cfif>
    <cfif isnumeric(get_connect_row.DISCOUNT_TUT) and get_connect_row.DISCOUNT_TUT gt 0>
    	<cfset netprice = netprice - get_connect_row.DISCOUNT_TUT>
    </cfif>
    <cfif isnumeric(get_connect_row.DISCOUNT_1) and get_connect_row.DISCOUNT_1 gt 0>
    	<cfset netprice = netprice - (netprice*get_connect_row.DISCOUNT_1/100)>
    </cfif>
    <cfif isnumeric(get_connect_row.DISCOUNT_2) and get_connect_row.DISCOUNT_2 gt 0>
    	<cfset netprice = netprice - (netprice*get_connect_row.DISCOUNT_2/100)>
    </cfif>
    <cfif isnumeric(get_connect_row.DISCOUNT_3) and get_connect_row.DISCOUNT_3 gt 0>
    	<cfset netprice = netprice - (netprice*get_connect_row.DISCOUNT_3/100)>
    </cfif>
    
	<cfset 'attributes.deliver_date#currentrow#' = get_connect_row.DELIVER_DATE>
  	<cfset 'attributes.product_id#currentrow#' = get_connect_row.PRODUCT_ID>
  	<cfset 'attributes.stock_id#currentrow#' = get_connect_row.STOCK_ID>
 	<cfset 'attributes.amount#currentrow#' = get_connect_row.AMOUNT>
  	<cfset 'attributes.amount_other#currentrow#' = get_connect_row.AMOUNT>
   	<cfset 'attributes.unit#currentrow#' = get_connect_row.UNIT>
 	<cfset 'attributes.unit_other#currentrow#' = get_connect_row.UNIT>
  	<cfset 'attributes.unit_id#currentrow#' = get_connect_row.PRODUCT_UNIT_ID>
    <cfset 'attributes.product_name#currentrow#' = get_connect_row.PRODUCT_NAME>
  	<cfset 'attributes.spect_id#currentrow#' = get_connect_row.SPECT_VAR_ID>
  	<cfset 'attributes.spect_name#currentrow#' = get_connect_row.SPECT_VAR_NAME>
  	<cfset 'attributes.product_name_other#currentrow#' = get_connect_row.PRODUCT_NAME2>
    <cfset 'attributes.is_promotion#currentrow#' = 0>
	<cfset 'attributes.list_price#currentrow#' = get_connect_row.LIST_PRICE>
 	<cfset 'attributes.basket_extra_info#currentrow#' = -1>
    <cfset 'attributes.price#currentrow#' = get_connect_row.SALES_PRICE>
  	<cfset 'attributes.other_money_value_#currentrow#' = netprice*get_connect_row.AMOUNT>
  	<cfset 'attributes.price_other#currentrow#' = get_connect_row.SALES_PRICE_OTHER>
  	<cfset 'attributes.other_money_#currentrow#' = get_connect_row.OTHER_MONEY>
  	<cfset 'attributes.tax#currentrow#' = get_connect_row.TAX>
 	<cfset 'attributes.indirim1#currentrow#' = get_connect_row.DISCOUNT_1>
  	<cfset 'attributes.indirim2#currentrow#' = get_connect_row.DISCOUNT_2>
   	<cfset 'attributes.indirim3#currentrow#' = get_connect_row.DISCOUNT_3>
  	<cfset 'attributes.iskonto_tutar#currentrow#' = get_connect_row.DISCOUNT_TUT>
    <cfset 'attributes.wrk_row_id#currentrow#' = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')# & #session.ep.company_id# & #currentrow#>
    <cfquery name="upd_connect" datasource="#dsn3#">
    	UPDATE       
        	EZGI_CONNECT_ROW
		SET                
        	WRK_ROW_RELATION_ID = '#Evaluate('attributes.wrk_row_id#currentrow#')#'
		WHERE        
        	CONNECT_ROW_ID = #get_connect_row.CONNECT_ROW_ID#
    </cfquery>
</cfloop>
<cfset fuseaction='sales.emptypopup_trf_ezgi_connect'>
<!---<cfdump var="#attributes#"><cfabort>--->
<cfinclude template="../../../../v16/sales/query/add_offer.cfm">
<script type="text/javascript">
 	window.location.href="<cfoutput>#request.self#?fuseaction=sales.list_offer&event=upd&offer_id=#get_max_offer.max_id#</cfoutput>";
</script>
