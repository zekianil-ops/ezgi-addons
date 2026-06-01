<!---
    File: add_ezgi_ship_sale.cfm
    Folder: Add_Ons\ezgi\e_shipping\query
    Author: Ezgi Yazılım
    Date: 01/10/2025
    Description: Hızlı Satış İrsaliyesi Oluşturmak
--->
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT TOP (1)    
    	SPC.PROCESS_CAT_ID
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE = 71 AND 
        SPCF.FUSE_NAME = 'stock.form_add_sale' AND 
		SPC.IS_DEFAULT = 1
  	ORDER BY
    	SPC.PROCESS_CAT_ID DESC      
</cfquery>
<cfif not get_process_cat.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='333.İşlem Kategorisi Tanımlayınız!'>");
		window.close();
	</script>
</cfif>

<cfquery name="get_info" datasource="#dsn3#">
	SELECT 
    	CASE
         	WHEN O.COMPANY_ID IS NOT NULL THEN
     		(
                    SELECT     
                      	FULLNAME
					FROM         
                    	#dsn_alias#.COMPANY
					WHERE     
                   		COMPANY_ID = O.COMPANY_ID
        	)
        	WHEN O.CONSUMER_ID IS NOT NULL THEN      
        	(	
                  	SELECT     
                     	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
					FROM         
                      	#dsn_alias#.CONSUMER
					WHERE     
                		CONSUMER_ID = O.CONSUMER_ID
      		)
      	END AS UNVAN,
        O.ORDER_NUMBER,
        O.ORDER_ID,
        O.COMPANY_ID,
        O.PARTNER_ID,
        O.CONSUMER_ID,
        O.SHIP_ADDRESS,
    	CAST(ESR.DEPARTMENT_ID AS VARCHAR)+'-'+CAST(ESR.LOCATION_ID AS VARCHAR) AS DEPO,
    	ESR.SHIP_RESULT_ID, 
        ESR.DEPARTMENT_ID, 
        ESR.LOCATION_ID,
        ORR.ORDER_ROW_ID,
        ORR.STOCK_ID, 
        ORR.PRODUCT_ID, 
        ORR.PRODUCT_NAME, 
        ORR.PRICE, 
        ORR.PRICE_OTHER, 
        ORR.UNIT_ID, 
        ORR.TAX, 
        ORR.NETTOTAL, 
        ORR.QUANTITY, 
        ORR.UNIT, 
        ORR.DISCOUNT_1, 
        ORR.DISCOUNT_2, 
        ORR.DISCOUNT_3, 
        ORR.DISCOUNT_4, 
        ORR.DISCOUNT_5,
        ORR.DISCOUNT_COST, 
        ORR.SPECT_VAR_ID, 
        ORR.SPECT_VAR_NAME, 
        ORR.OTHER_MONEY, 
        ORR.OTHER_MONEY_VALUE, 
        ORR.LOT_NO, 
        ORR.WRK_ROW_ID,
        ORR.ORDER_ROW_CURRENCY,
        ORR.RESERVE_TYPE
	FROM     
    	EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
        EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
        ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID LEFT OUTER JOIN
        ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID
	WHERE  
    	ESR.SHIP_RESULT_ID = #attributes.ship_result_id#
</cfquery>
<cfset attributes.order_id_listesi = ListDeleteDuplicates(ValueList(get_info.ORDER_ID),',')>
<cfquery name="get_depo_stocks" datasource="#dsn3#">
	SELECT TOP (5)
    	TBL.STOCK_ID, 
        TBL.SPECT_MAIN_ID, 
        TBL.BARCOD, 
        TBL.PRODUCT_CODE, 
        TBL.PRODUCT_NAME, 
        SUM(TBL.QUANTITY * TBL.PAKET_SAYISI) AS PAKET_SAYISI, 
        ISNULL(TBL_1.PRODUCT_STOCK, 0) AS REAL_STOCK,
        ISNULL(TBL_1.PRODUCT_STOCK, 0) - SUM(TBL.QUANTITY * TBL.PAKET_SAYISI) AS FARK
	FROM     
    	(
        	SELECT 
            	EPS.PAKET_ID AS STOCK_ID, 
                0 AS SPECT_MAIN_ID, 
            	S1.BARCOD, 
                S1.PRODUCT_CODE, 
                S1.PRODUCT_NAME, 
                ORR.QUANTITY, 
                EPS.PAKET_SAYISI
         	FROM      
            	EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) INNER JOIN
                ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
                STOCKS AS S1 ON EPS.PAKET_ID = S1.STOCK_ID
         	WHERE   
            	ESRR.SHIP_RESULT_ID = #attributes.ship_result_id# AND 
                ISNULL(S.IS_PROTOTYPE, 0) = 0
      		UNION ALL
          	SELECT 
            	EPS.PAKET_ID AS STOCK_ID, 
                SP.SPECT_MAIN_ID, 
                S1.BARCOD, 
                S1.PRODUCT_CODE, 
                S1.PRODUCT_NAME, 
                ORR.QUANTITY, 
                EPS.PAKET_SAYISI
        	FROM     
            	SPECTS AS SP INNER JOIN
                EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) INNER JOIN
                ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                STOCKS AS S1 INNER JOIN
                EZGI_PAKET_SAYISI AS EPS ON S1.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID
          	WHERE  
            	ESRR.SHIP_RESULT_ID = #attributes.ship_result_id# AND 
                ISNULL(S.IS_PROTOTYPE, 0) = 1
 		) AS TBL LEFT OUTER JOIN
        (
        	SELECT 
            	SUM(SUB_TBL.PRODUCT_STOCK) AS PRODUCT_STOCK,
                SUB_TBL.STOCK_ID, 
                SUB_TBL.SPECT_MAIN_ID, 
                SUB_TBL.DEPO
          	FROM
            	(
                SELECT 
                    STL.PRODUCT_STOCK, 
                    STL.STOCK_ID, 
                    ISNULL(STL.SPECT_MAIN_ID,0) AS SPECT_MAIN_ID, 
                    STL.DEPO
                FROM      
                    #dsn2_alias#.EZGI_GET_SPECT_LOCATION_TOTAL STL INNER JOIN
                    STOCKS AS S ON S.STOCK_ID = STL.STOCK_ID
                WHERE   
                    STL.DEPO = '#get_info.DEPO#' AND
                    ISNULL(S.IS_PROTOTYPE, 0) = 1
                UNION ALL
                SELECT 
                    STL.PRODUCT_STOCK, 
                    STL.STOCK_ID, 
                    0 AS SPECT_MAIN_ID, 
                    STL.DEPO
                FROM      
                    #dsn2_alias#.EZGI_GET_SPECT_LOCATION_TOTAL STL INNER JOIN
                    STOCKS AS S ON S.STOCK_ID = STL.STOCK_ID
                WHERE   
                    STL.DEPO = '#get_info.DEPO#' AND
                    ISNULL(S.IS_PROTOTYPE, 0) = 0
                    ) AS  SUB_TBL
       		GROUP BY
            	SUB_TBL.STOCK_ID, 
                SUB_TBL.SPECT_MAIN_ID, 
                SUB_TBL.DEPO
  		) AS TBL_1 ON TBL.SPECT_MAIN_ID = TBL_1.SPECT_MAIN_ID AND TBL.STOCK_ID = TBL_1.STOCK_ID
	GROUP BY 
    	TBL.STOCK_ID, 
        TBL.SPECT_MAIN_ID, 
        TBL.BARCOD, 
        TBL.PRODUCT_CODE, 
        TBL.PRODUCT_NAME, 
        TBL_1.PRODUCT_STOCK
  	HAVING
    	ISNULL(TBL_1.PRODUCT_STOCK, 0) < SUM(TBL.QUANTITY * TBL.PAKET_SAYISI)
</cfquery>
<cfif get_depo_stocks.recordcount>
	<script type="text/javascript">
     	var msg = "";
		<cfoutput query="get_depo_stocks">
			msg += "#TlFormat(FARK*-1,2)# Adet #PRODUCT_CODE# #Left(PRODUCT_NAME,30)#<cfif len(PRODUCT_CODE) gt 30>...</cfif>\n";
		</cfoutput>
		alert(msg + "Yetersiz Stok");
		window.close();
    </script>
    <cfabort>
</cfif>
<cfif get_info.recordcount>
    <cftransaction>
        <cfquery name="get_paper" datasource="#dsn2#">
            SELECT SHIP_NO, SHIP_NUMBER FROM #dsn3_alias#.PAPERS_NO WHERE EMPLOYEE_ID = #SESSION.EP.USERID#
        </cfquery>
        <cfif len(get_info.COMPANY_ID)>
            <cfset attributes.company_id = get_info.COMPANY_ID>
            <cfif len(get_info.PARTNER_ID)>
            	<cfset  attributes.partner_id = get_info.PARTNER_ID>
         	<cfelse>
            	<cfquery name="get_partner" datasource="#dsn2#">
                	SELECT TOP (1) PARTNER_ID FROM #dsn_alias#.COMPANY_PARTNER WHERE COMPANY_ID = #attributes.company_id# AND COMPANY_PARTNER_STATUS = 1 ORDER BY PARTNER_ID
                </cfquery>
                <cfif get_partner.recordcount>
                	<cfset  attributes.partner_id = get_partner.PARTNER_ID>
                <cfelse>
                	<script type="text/javascript">
						alert("Kurumsal Üyenin Çalışanı Bulunamamıştır.!!!");
						window.close();
					</script>
					<cfabort>
                </cfif>
            </cfif>
        <cfelseif len(get_info.CONSUMER_ID)>
            <cfset attributes.consumer_id = get_info.CONSUMER_ID>
        <cfelse>
            <script type="text/javascript">
                alert("Kurumsal veya Bireysel Üye Kaydı Bulunamamıştır.!!!");
                window.close();
            </script>
            <cfabort>
        </cfif>
	
        <cfset adres = get_info.SHIP_ADDRESS>
        <cfset attributes.comp_name = get_info.UNVAN>
        <cfset attributes.paper_number = get_paper.SHIP_NUMBER+1>
        <cfset attributes.ship_number = '#get_paper.SHIP_NO#-#attributes.paper_number#'>
        <cfset SHIP_NUMBER = '#get_paper.SHIP_NO#-#attributes.paper_number#'>
        <cfset attributes.ROWS_ = get_info.recordcount>
        <cfset attributes.department_id = get_info.DEPARTMENT_ID>
        <cfset attributes.location_id = get_info.LOCATION_ID> 
        <cfset attributes.ACTIVE_PERIOD = session.ep.period_id>
        <cfset attributes.DEPARTMENT_IN_ID = ''>
        <cfset attributes.LOCATION_IN_ID = ''> 
        <cfset attributes.EMPLOYEE_ID = session.ep.userid>
        <cfset attributes.ship_detail = 'Sipariş No : #get_info.ORDER_NUMBER# - Sevk Talep No : #attributes.ship_result_id#'> 
        <cfset attributes.sale_ship_id = attributes.ship_result_id>
      
        <cfset form.BASKET_DISCOUNT_TOTAL = 0>
        <cfset form.BASKET_EMPLOYEE1 = ''>  
        <cfset form.BASKET_EMPLOYEE_ID1 = ''> 
        <cfset form.BASKET_EXTRA_INFO1 = -1>  
        <cfset form.BASKET_GROSS_TOTAL = 0>  
        <cfset form.BASKET_ID = 12> 
        <cfset form.BASKET_MEMBER_PRICECAT = '' > 
        <cfset form.BASKET_MONEY = session.ep.money>
        <cfset form.BASKET_NET_TOTAL = 0>  
        <cfset form.BASKET_OTV_1 = 0> 
        <cfset form.BASKET_OTV_COUNT = 1>  
        <cfset form.BASKET_OTV_FROM_TAX_PRICE = 0>
        <cfset form.BASKET_OTV_TOTAL = 0>
        <cfset form.BASKET_OTV_VALUE_1 = 0>
        <cfset form.BASKET_TAX_1 = 0>
        <cfset form.BASKET_TAX_VALUE_1 = 0>
        <cfset form.BASKET_PRICE_ROUND_NUMBER = 4>  
        <cfset form.BASKET_RATE1 = 1>
        <cfset form.BASKET_RATE2 = 1> 
        <cfset form.BASKET_RATE_ROUND_NUMBER_ =4>
        <cfset form.BASKET_SPECT_TYPE =0> 
        <cfset form.BASKET_TOTAL_ROUND_NUMBER_ = 2>
        <cfset form.BASKET_TAX_COUNT = 1>  
        <cfset form.BASKET_TAX_TOTAL = 0> 
        <cfset attributes.CONTROL_FIELD_VALUE =-1>
        <cfset attributes.HIDDEN_RD_MONEY_1 = session.ep.money>
        <cfset attributes.EXTRA_COST_RATE =''> 
        <cfset attributes.ship_date = Dateformat(now(),Dateformat_style)>
        <cfset attributes.deliver_date_frm = Dateformat(now(),Dateformat_style)>
        <cfset attributes.INDIRIM_TOTAL = 0>
        <cfset attributes.SALE_ID_LIST = ''>
        <cfset attributes.IS_BASKET_HIDDEN = 0>  
        <cfset attributes.IS_GENERAL_PROM = 0> 
        <cfset attributes.KUR_SAY = 1> 
        <cfset attributes.MEMBER_NAME = get_emp_info(session.ep.userid,0,0)>  
        <cfset attributes.MEMBER_TYPE = 'employee'>  
        <cfset attributes.OLD_GENERAL_PROM_AMOUNT = ''>  
        <cfset attributes.PROD_ORDER = ''>  
        <cfset attributes.PROD_ORDER_NUMBER = ''>  
        <cfset attributes.PROJECT_HEAD = ''> 
        <cfset attributes.PROJECT_ID = ''>  
        <cfset attributes.RD_MONEY = 1>  
        <cfset attributes.REF_NO = ''> 
        <cfset attributes.ROW_COST_TOTAL =0>
        <cfset attributes.SALE_PRODUCT = ''>  
        <cfset attributes.SEARCH_PROCESS_DATE = 'fis_date'>
        <cfset attributes.SERVICE_ID = ''>  
        <cfset attributes.SERVICE_NAME = ''>
        <cfset attributes.TODAY_DATE_ = now()>
        <cfset attributes.TXT_RATE1_1 = 1>
        <cfset attributes.TXT_RATE2_1 =1>  
        <cfset attributes.USE_BASKET_PROJECT_DISCOUNT_ = 0>   
        <cfset attributes.WORK_HEAD = 0>  
        <cfset attributes.WORK_ID = 0> 
        <cfset attributes.WRK_SUBMIT_BUTTON = 'Kaydet'> 
        <cfset attributes.X_COST_ACC = 1>
        <cfset BASKET_KUR_EKLE = 0>
        <cfset 	attributes.XML_MULTIPLE_COUNTING_FIS =0>
        <cfset attributes.fis_date_m = '00'>
        <cfset attributes.fis_date_h = '00'>
        <cfset attributes.DELIVER_DATE_M = '00'>
        <cfset attributes.DELIVER_DATE_H = '00'>
    
        <cfloop query="get_info">   
            <cfquery name="get_stock_info" datasource="#dsn2#">
                SELECT     
                    PU.PRODUCT_UNIT_ID, 
                    PU.MAIN_UNIT, 
                    PS.PRICE, 
                    PS.MONEY,
                    S.BARCOD,
                    S.PRODUCT_NAME, 
                    S.TAX, 
                    S.STOCK_ID, 
                    S.PRODUCT_ID,
                    S.STOCK_CODE
                FROM         
                    #dsn3_alias#.STOCKS AS S INNER JOIN
                    #dsn3_alias#.PRICE_STANDART AS PS ON S.PRODUCT_ID = PS.PRODUCT_ID INNER JOIN
                    #dsn3_alias#.PRODUCT_UNIT AS PU ON S.PRODUCT_ID = PU.PRODUCT_ID
                WHERE     
                    PU.IS_MAIN = 1 AND 
                    PS.PRICESTANDART_STATUS = 1 AND 
                    PS.PURCHASESALES = 0 AND
                    S.STOCK_ID = #get_info.STOCK_ID#
            </cfquery>
            <cfset k = get_info.currentrow>
            <cfset 'attributes.PRICE_NET#k#' = 0> 
            <cfset 'attributes.PRICE_NET_DOVIZ#k#' = 0> 
            <cfset 'attributes.PRODUCT_NAME_OTHER#k#' =''>
            <cfset 'attributes.PROMOSYON_MALIYET#k#' = ''>  
            <cfset 'attributes.PROMOSYON_YUZDE#k#' = ''>  
            <cfset 'attributes.PROM_RELATION_ID#k#' = ''>  
            <cfset 'attributes.PROM_STOCK_ID#k#' = ''>  
            <cfset 'attributes.RELATED_ACTION_ID#k#' = ''>  
            <cfset 'attributes.RELATED_ACTION_TABLE#k#' = ''>  
            <cfset 'attributes.RESERVE_DATE#k#' = ''>  
            <cfset 'attributes.RESERVE_TYPE#k#' = get_info.RESERVE_TYPE> 
            <cfset 'attributes.ORDER_CURRENCY#k#' = get_info.ORDER_ROW_CURRENCY>
            <cfset 'attributes.ROW_CATALOG_ID#k#' = ''>  
            <cfset 'attributes.ROW_HEIGHT#k#' = ''>  
            <cfset 'attributes.ROW_OTVTOTAL#k#' = 0>  
            <cfset 'attributes.ROW_PAYMETHOD_ID#k#' = ''>  
            <cfset 'attributes.ROW_PROJECT_ID#k#' = ''>  
            <cfset 'attributes.ROW_PROJECT_NAME#k#' = ''>  
            <cfset 'attributes.ROW_PROMOTION_ID#k#' = ''>  
            <cfset 'attributes.ROW_SERVICE_ID#k#' = ''> 
         	<cfset 'attributes.EK_TUTAR#k#' = ''>  
            <cfset 'attributes.EK_TUTAR_COST#k#' = ''>  
            <cfset 'attributes.EK_TUTAR_MARJ#k#' = ''>  
            <cfset 'attributes.EK_TUTAR_OTHER_TOTAL#k#' = 0>  
            <cfset 'attributes.EK_TUTAR_PRICE#k#' = ''>  
            <cfset 'attributes.EK_TUTAR_TOTAL#k#' = 0>
            <cfset 'attributes.EXTRA_COST#k#' = 0>
       		<cfset 'attributes.DARA#k#' = 0>  
            <cfset 'attributes.DARALI#k#' = 1> 
            <cfset 'attributes.BASKET_ROW_DEPARTMAN#k#' = ''>  
            <cfset 'attributes.DELIVER_DATE#k#' = ''>  
            <cfset 'attributes.DELIVER_DEPT#k#' = ''> 
            <cfset 'attributes.DUEDATE#k#' = ''> 
        	<cfset 'attributes.ROW_UNIQUE_RELATION_ID#k#' = ''>  
            <cfset 'attributes.ROW_WIDTH#k#' = ''>
            <cfset 'attributes.ROW_DEPTH#k#' = ''>
            <cfset 'attributes.SPECIAL_CODE#k#' = ''> 
            
             
            <cfset 'attributes.ROW_SHIP_ID#k#' = 0> 
            <cfset 'attributes.PRICE_CAT#k#' = ''> 
            <cfset 'attributes.ROW_TOTAL#k#' = 0>  
            
            <cfset 'attributes.ORDER_ROW_ID#k#' = get_info.ORDER_ROW_ID>
            <cfset 'attributes.UNIT#k#' = get_stock_info.MAIN_UNIT>
            <cfset 'attributes.UNIT_ID#k#' = get_stock_info.PRODUCT_UNIT_ID> 
            <cfset 'attributes.STOCK_CODE#k#' = get_stock_info.STOCK_CODE> 
            <cfset 'attributes.STOCK_ID#k#' = get_stock_info.STOCK_ID>  
            <cfset 'attributes.PRODUCT_ID#k#' = get_stock_info.PRODUCT_ID> 
            <cfset 'attributes.PRODUCT_NAME#k#' = get_stock_info.PRODUCT_NAME> 
            <cfset 'attributes.AMOUNT#k#' = get_info.QUANTITY>
            <cfset 'attributes.AMOUNT_OTHER#k#' = get_info.QUANTITY>
            <cfset 'attributes.ACTION_ROW_ID#k#' = 0>
            <cfset 'attributes.BARCOD#k#' = get_stock_info.BARCOD>
             
 
            <cfset 'attributes.INDIRIM10#k#' = 0>  
            <cfset 'attributes.INDIRIM1#k#' = get_info.DISCOUNT_1>  
            <cfset 'attributes.INDIRIM2#k#' = get_info.DISCOUNT_2>  
            <cfset 'attributes.INDIRIM3#k#' = get_info.DISCOUNT_3>  
            <cfset 'attributes.INDIRIM4#k#' = get_info.DISCOUNT_4>  
            <cfset 'attributes.INDIRIM5#k#' = get_info.DISCOUNT_5>  
            <cfset 'attributes.INDIRIM6#k#' = 0>  
            <cfset 'attributes.INDIRIM7#k#' = 0>  
            <cfset 'attributes.INDIRIM8#k#' = 0>  
            <cfset 'attributes.INDIRIM9#k#' = 0>  
            <cfset 'attributes.ISKONTO_TUTAR#k#' = get_info.DISCOUNT_COST>  
            <cfset 'attributes.IS_COMMISSION#k#' = 0>
            <cfset 'attributes.IS_INVENTORY#k#' = 1>
            <cfset 'attributes.KARMA_PRODUCT_ID#k#' = ''>
            <cfset 'attributes.IS_PRODUCTION#k#' = 0>  
            <cfset 'attributes.IS_PROMOTION#k#' = 0> 
            <cfset 'attributes.LIST_PRICE#k#' = 0> 
            <cfset 'attributes.LOT_NO#k#' = ''> 
            <cfset 'attributes.LIST_PRICE_DISCOUNT#k#' = ''> 
            <cfset 'attributes.MANUFACT_CODE#k#' = ''>  
            <cfset 'attributes.MARJ#k#' = ''> 
            <cfset 'attributes.NET_MALIYET#k#' = 0>  
            <cfset 'attributes.NUMBER_OF_INSTALLMENT#k#' = 0>  
              
            <cfset 'attributes.OTHER_MONEY_GROSS_TOTAL#k#' = 0> 
            <cfset 'attributes.OTHER_MONEY#k#' = session.ep.money>
            <cfset 'attributes.OTHER_MONEY_#k#' = get_info.OTHER_MONEY>
            <cfset 'attributes.OTHER_MONEY_VALUE_#k#' = get_info.OTHER_MONEY_VALUE>
            <cfset 'attributes.OTV_ORAN#k#' = 0>  
            <cfset 'attributes.PBS_CODE#k#' = ''>  
            <cfset 'attributes.PBS_ID#k#' = ''>  
            <cfset 'attributes.PRICE#k#' = get_info.PRICE> 
            <cfset 'attributes.PRICE_OTHER#k#' = get_info.PRICE_OTHER> 
            <cfset 'attributes.ROW_LASTTOTAL#k#' = get_info.NETTOTAL+(get_info.NETTOTAL*get_info.TAX)>  
            <cfset 'attributes.ROW_NETTOTAL#k#' = get_info.NETTOTAL>  
            <cfset 'attributes.ROW_TAXTOTAL#k#' = get_info.NETTOTAL*get_info.TAX>  
            <cfset 'attributes.SPECT_ID#k#' = get_info.SPECT_VAR_ID>  
            <cfset 'attributes.TAX_PRICE#k#' = ''>  
            <cfset 'attributes.UNIT_OTHER#k#' = ''>  
            <cfset 'attributes.WRK_ROW_RELATION_ID#k#' = get_info.WRK_ROW_ID>
            <cfset 'attributes.TAX#k#' = get_info.TAX>
            <cfset 'attributes.SPECT_NAME#k#' = get_info.SPECT_VAR_NAME>
            <cfset 'attributes.WRK_ROW_ID#k#' = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')#>
            <cfset attributes.webService = 1>
        </cfloop>
        <cfset form.process_cat = get_process_cat.PROCESS_CAT_ID>	
        <cfinclude template="add_ezgi_ship_sale_fis_include.cfm">
    </cftransaction>
    <script type="text/javascript">
        alert("Kayıt Tamamlanmıştır. Sizi Fişe Yönlendiriyorum!");
        window.location ="<cfoutput>#request.self#?fuseaction=stock.form_add_sale&event=upd&ship_id=#MAX_ID.IDENTITYCOL#</cfoutput>";
        window.opener.location.reload()
    </script>
</cfif>
