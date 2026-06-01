<!---Parametreye Bağlanmalı--->
<cfset form.PROCESS_CAT = 57> <!---Mal Alım İrsaliyesi--->
<cfset CT_PROCESS_TYPE_162 = 76>
<cfset CT_PROCESS_TYPE_55 = 74>
<cfset CT_PROCESS_TYPE_57 = 76>

<cfset attributes.PROCESS_CAT = 57>
<cfset attributes.LOCATION_ID = 1>
<cfset attributes.DEPARTMENT_ID = 8>
<cfset attributes.TXT_DEPARTMAN_ =  'Merkez Depo - Hammadde Depo'>
<!---Parametreye Bağlanmalı--->
<cfset attributes.ACTIVE_PERIOD = session.ep.period_id>
<cfif Right(attributes.CONVERT_EZGI_STOCKS_ID,1) eq ',' and Len(attributes.CONVERT_EZGI_STOCKS_ID)>
	<Cfset attributes.CONVERT_EZGI_STOCKS_ID = Left(attributes.CONVERT_EZGI_STOCKS_ID,Len(attributes.CONVERT_EZGI_STOCKS_ID)-1)>
</cfif>
<cfif Right(attributes.CONVERT_AMOUNT_EZGI_STOCKS_ID,1) eq ',' and Len(attributes.CONVERT_AMOUNT_EZGI_STOCKS_ID)>
	<Cfset attributes.CONVERT_AMOUNT_EZGI_STOCKS_ID = Left(attributes.CONVERT_AMOUNT_EZGI_STOCKS_ID,Len(attributes.CONVERT_AMOUNT_EZGI_STOCKS_ID)-1)>
</cfif>
<cfset attributes.rows_ = ListLen(attributes.CONVERT_EZGI_STOCKS_ID)>

<cfset form.BASKET_GROSS_TOTAL = 0>
<cfset form.BASKET_NET_TOTAL = 0>
<cfset form.BASKET_TAX_TOTAL= 0>
<cfif ListLen(attributes.CONVERT_EZGI_STOCKS_ID)>
	<cfset tur = 1>
	<cfloop list="#attributes.CONVERT_EZGI_STOCKS_ID#" index="i">
    	<cfif ListLen(i,'_') eq 2>
            <cfquery name="get_stock_info" datasource="#dsn3#">
                SELECT     
                    EMR.STOCK_ID, 
                    EMR.SERVICE_ID, 
                    EMR.WRK_ROW_RELATION_ID, 
                    SRV.SERVICE_EMPLOYEE_ID, 
                    SRV.RELATED_COMPANY_ID, 
                    SRVO.PRODUCT_ID, 
                    SRVO.PRODUCT_NAME, 
                    SRVO.UNIT_ID, 
                    SRVO.UNIT, 
                    ISNULL(SRVO.PRICE,0) PRICE, 
                    SRVO.TOTAL_PRICE, 
                    SRVO.STOCK_CODE, 
                    SRV.SERVICE_HEAD, 
                    EMR.EZGI_ID,
                    S.IS_INVENTORY, 
                    ISNULL(S.TAX_PURCHASE,0) TAX
                FROM        
               		STOCKS AS S INNER JOIN
                	SERVICE_OPERATION AS SRVO ON S.STOCK_ID = SRVO.STOCK_ID RIGHT OUTER JOIN
                  	EZGI_MONTAGE_TRACING_ROW AS EMR INNER JOIN
                 	EZGI_MONTAGE_TRACING AS EM ON EMR.MONTAGE_TRACING_ID = EM.MONTAGE_TRACING_ID INNER JOIN
                	SERVICE AS SRV ON EMR.SERVICE_ID = SRV.SERVICE_ID ON SRVO.SERVICE_ID = EMR.SERVICE_ID
                WHERE     
                    EMR.EZGI_ID = #ListGetAt(i,1,'_')# AND 
                    SRVO.STOCK_ID = #ListGetAt(i,2,'_')#
            </cfquery>

            <cfif get_stock_info.recordcount>
                <cfset 'attributes.STOCK_CODE#tur#' = get_stock_info.STOCK_CODE>
                <cfset 'attributes.STOCK_ID#tur#' = get_stock_info.STOCK_ID>
                <cfset 'attributes.PRODUCT_ID#tur#' = get_stock_info.PRODUCT_ID>
                <cfset 'attributes.PRODUCT_NAME#tur#' = get_stock_info.PRODUCT_NAME>
                <cfset 'attributes.PRICE#tur#' = get_stock_info.PRICE>
                <cfset 'attributes.PRICE_OTHER#tur#' = get_stock_info.PRICE>
                <cfset 'attributes.list_price#tur#' = get_stock_info.PRICE>
                <cfset 'attributes.TAX#tur#'	= get_stock_info.TAX>
                <cfset 'attributes.UNIT#tur#' = get_stock_info.UNIT>
                <cfset 'attributes.UNIT_ID#tur#' = get_stock_info.UNIT_ID>
				<cfset 'attributes.UNIT_OTHER#tur#' = get_stock_info.UNIT>	
                <cfset 'attributes.WRK_ROW_RELATION_ID#tur#' = get_stock_info.WRK_ROW_RELATION_ID>
                <cfset 'attributes.product_name_other#tur#' = Left(Replace(get_stock_info.SERVICE_HEAD,',','.','All'),600)>
                <cfset 'attributes.amount#tur#' = ListGetAt(attributes.CONVERT_AMOUNT_EZGI_STOCKS_ID,tur)>	
                <cfset 'attributes.amount_other#tur#' = ListGetAt(attributes.CONVERT_AMOUNT_EZGI_STOCKS_ID,tur)>	
                <cfset 'attributes.other_money_#tur#' = session.ep.money>		
                <cfset 'attributes.row_nettotal#tur#' = FilterNum(TlFormat(get_stock_info.PRICE,4),4)*FilterNum(TlFormat(ListGetAt(attributes.CONVERT_AMOUNT_EZGI_STOCKS_ID,tur),4),4)>
                <cfset 'attributes.other_money_value_#tur#' = FilterNum(TlFormat(get_stock_info.PRICE,4),4)*FilterNum(TlFormat(ListGetAt(attributes.CONVERT_AMOUNT_EZGI_STOCKS_ID,tur),4),4)>
                <cfset 'attributes.row_taxtotal#tur#' = FilterNum(TlFormat(FilterNum(TlFormat(get_stock_info.PRICE,4),4)*FilterNum(TlFormat(ListGetAt(attributes.CONVERT_AMOUNT_EZGI_STOCKS_ID,tur),4),4)*get_stock_info.TAX/100,4),4)>
                <cfset 'attributes.row_lasttotal#tur#' = Evaluate('attributes.row_nettotal#tur#')+ Evaluate('attributes.row_taxtotal#tur#')>
                <cfset 'attributes.other_money_gross_total#tur#' =  Evaluate('attributes.row_nettotal#tur#')+ Evaluate('attributes.row_taxtotal#tur#')>
                <cfset 'attributes.wrk_row_id#tur#' = 'EZG'&dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*1000)>
                <cfset 'attributes.is_inventory#tur#' = get_stock_info.IS_INVENTORY>
                <cfset 'attributes.dara#tur#' = 0>
                <cfset 'attributes.darali#tur#' = 1>
                <cfset 'attributes.iskonto_tutar#tur#' = 0>
                <cfset form.BASKET_GROSS_TOTAL = form.BASKET_GROSS_TOTAL+Evaluate('attributes.row_nettotal#tur#')>
				<cfset form.BASKET_NET_TOTAL = form.BASKET_NET_TOTAL+Evaluate('attributes.row_lasttotal#tur#')>
                <cfset form.BASKET_TAX_TOTAL= form.BASKET_TAX_TOTAL+Evaluate('attributes.row_taxtotal#tur#')>
            <cfelse>
            	get_stock_info.recordcount Hatası
                <cfdump var="#get_stock_info#">
            	<cfabort>
            </cfif>
     	<cfelse>
        	ListLen(i,'_') eq 2 Hatası
			<cfabort>
        </cfif>
        <cfset tur = tur+1>
  	</cfloop>		
<cfelse>
	attributes.CONVERT_EZGI_STOCKS_ID ListLen Hatası
	<cfabort>
</cfif>
<cfset attributes.AMOUNT = attributes.CONVERT_AMOUNT_EZGI_STOCKS_ID>
<cfset attributes.AMOUNT_OTHER = attributes.CONVERT_AMOUNT_EZGI_STOCKS_ID>
<cfset attributes.BARCOD = ''>
<cfset attributes.CARD_PAYMETHOD_ID = ''>
<cfset attributes.CIRCUIT = 'stock'>
<cfset attributes.COMMETHOD_ID = ''>
<cfset attributes.COMMISSION_RATE = ''>
<cfset attributes.DELIVER_DATE_FRM = DateFormat(now(),'DD/MM/YYYY')>
<cfset attributes.ACTION_DATE = DateFormat(now(),'DD/MM/YYYY')>
<cfset attributes.DELIVER_DATE_H = 10>
<cfset attributes.DELIVER_DATE_M = 10>
<cfset attributes.DELIVER_GET = '#session.ep.name# #session.ep.surname#'>
<cfset attributes.DELIVER_GET_ID = session.ep.userid>
<cfset attributes.DELIVER_MEMBER_TYPE = 'employee'>
<cfset attributes.DETAIL = ''>
<cfset attributes.EMPLOYEE_ID = ''>
<cfset attributes.FORM_ACTION_ADDRESS = 'stock.emptypopup_add_purchase'>
<cfset attributes.FRAME_FUSEACTION = ''>
<cfset attributes.INFO_TYPE_ID = -14>
<cfset attributes.IRSALIYE = ''>
<cfset attributes.IRSALIYE_ID_LISTESI = ''>
<cfset attributes.IRSALIYE_PROJECT_ID_LISTESI = ''>
<cfset attributes.MANUFACT_CODE = ''>
<cfset attributes.NET_MALIYET = ''>
<cfset attributes.ORDER_ID = ''>
<cfset attributes.ORDER_ID_LISTESI = ''>
<cfset attributes.PAYMETHOD_ID = ''>
<cfset attributes.SEARCH_PROCESS_DATE = 'ship_date'>
<cfset attributes.SERVICE_ID = ''>
<cfset attributes.SERVICE_SERIAL_NO = ''>
<cfset attributes.SERVICE_STOCK_ID = ''>
<cfset attributes.SHIP_DATE	= DateFormat(now(),'DD/MM/YYYY')>
<cfset attributes.SHIP_METHOD = ''>
<cfset attributes.SHIP_METHOD_NAME = ''>
<cfset SHIP_NUMBER = "H-#Dateformat(now(),'MMDD')##Timeformat(now(),'HHMMSS')#">
<cfset attributes.SIPARIS_DATE_LISTESI = ''>
<cfset attributes.ROW_SHIP_ID = ''>
<cfset attributes.SUBSCRIPTION_NO = ''>
<cfset attributes.fuseaction = 'stock.emptypopup_add_purchase'>

<cfset attributes.CONSUMER_ID = ''>
<cfif len(get_stock_info.RELATED_COMPANY_ID)>
	<cfquery name="GET_COMPANY" datasource="#DSN#">
    	SELECT     
        	C.COMPANY_ID, 
            C.FULLNAME, 
            CP.PARTNER_ID
		FROM       
        	COMPANY AS C INNER JOIN
          	COMPANY_PARTNER AS CP ON C.COMPANY_ID = CP.COMPANY_ID
		WHERE     
        	C.COMPANY_ID = #get_stock_info.RELATED_COMPANY_ID#
       	ORDER BY 
        	CP.PARTNER_ID DESC
    </cfquery>
    <cfset attributes.COMPANY_ID = get_stock_info.RELATED_COMPANY_ID>
    <cfset attributes.DELIVER_COMP_ID = get_stock_info.RELATED_COMPANY_ID>
    <cfset attributes.COMP_NAME = GET_COMPANY.FULLNAME>
    <cfset attributes.PARTNER_ID = GET_COMPANY.PARTNER_ID>
<cfelseif len(get_stock_info.SERVICE_EMPLOYEE_ID)>
	<cfset attributes.employee_id = get_stock_info.SERVICE_EMPLOYEE_ID>
</cfif>

<cfquery name="get_money" datasource="#dsn#">
	SELECT     
    	MONEY, 
        RATE1,
        RATE2
	FROM     
    	SETUP_MONEY
	WHERE     
    	COMPANY_ID = #session.ep.company_id# AND 
        PERIOD_ID = #session.ep.period_id# AND 
        MONEY_STATUS = 1
   	ORDER BY 
    	MONEY_ID
</cfquery>
<cfif get_money.recordcount>
	<cfloop query="get_money">
    	<cfset 'attributes.HIDDEN_RD_MONEY_#currentrow#' = MONEY>
        <cfset 'attributes.TXT_RATE1_#currentrow#' = RATE1>
    	<cfset 'attributes.TXT_RATE2_#currentrow#' = RATE2>
    </cfloop>
    <cfset attributes.KUR_SAY = get_money.recordcount>
<cfelse>
	Hata: Para Tanımları Eksik
</cfif>
<cfset form.BASKET_RATE1 = 1>
<cfset form.BASKET_RATE2 = 1>
<cfset form.BASKET_DISCOUNT_TOTAL = 0>
<cfset form.BASKET_DUE_VALUE = ''>
<cfset form.BASKET_MONEY = session.ep.money>
<cfset attributes.BASKET_MONEY = session.ep.money>
<cfset form.BASKET_OTV_TOTAL = ''>
<cfset form.BASKET_TAX_COUNT = 1>
<cfset form.BASKET_GROSS_TOTAL = FilterNum(TlFormat(form.BASKET_GROSS_TOTAL,2),2)>
<cfset form.BASKET_NET_TOTAL = FilterNum(TlFormat(form.BASKET_NET_TOTAL,2),2)>
<cfset form.BASKET_TAX_TOTAL= FilterNum(TlFormat(form.BASKET_TAX_TOTAL,2),2)>
<cfset attributes.basket_net_total = form.BASKET_NET_TOTAL>
<cfset attributes.basket_gross_total = form.BASKET_GROSS_TOTAL>
<cfset attributes.basket_tax_total = form.BASKET_TAX_TOTAL>
<!---<cfdump var="#attributes#"><cfabort>--->
<cfinclude template="/V16/stock/query/add_purchase.cfm">