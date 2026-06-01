<!---
    File: add_ezgi_metarial_ambar_fisi.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset form.PROCESS_CAT = 88> <!---Dikkat Firmaya Göre Değişir--->
<cfset attributes.PROCESS_CAT = 88><!---Dikkat Firmaya Göre Değişir--->
<cfset CT_PROCESS_TYPE_92 = 113> <!---Dikkat Firmaya Göre Değişir--->
<cfset TXT_DEPARTMAN_OUT = 'Koltuk Üretim-Koltuk Hammadde'><!---Dikkat Firmaya Göre Değişir--->
<cfset TXT_DEPARTMENT_IN = 'Koltuk Üretim-Koltuk Üretim'><!---Dikkat Firmaya Göre Değişir--->
<cfset attributes.XML_MULTIPLE_COUNTING_FIS = 0>
<cfset stock_id_list = ''>
<cfloop list="#attributes.p_order_id_list#" index="i">
	<cfset stock_id_list = ListAppend(stock_id_list,Listgetat(i,1,'_'))>
    <cfset 'AMOUNT_#Listgetat(i,1,'_')#' = Listgetat(i,2,'_')>
</cfloop>
<cfquery name="get_order_detail" datasource="#dsn3#">
	SELECT   TOP (1)  
    	PO.SPECT_VAR_NAME, 
        PO.QUANTITY,
        PO.FINISH_DATE,
        ORR.UNIT, 
        ORR.PRODUCT_NAME2,
        ORR.PRODUCT_NAME,
        O.ORDER_NUMBER, 
        O.REF_NO,
        CASE 
        	WHEN COMPANY_ID IS NOT NULL THEN
                          (SELECT     FULLNAME
                            FROM          #dsn_alias#.COMPANY
                            WHERE      (COMPANY_ID = O.COMPANY_ID)) 
     		WHEN CONSUMER_ID IS NOT NULL THEN
                          (SELECT     CONSUMER_NAME + ' ' + CONSUMER_SURNAME
                            FROM          #dsn_alias#.CONSUMER
                            WHERE      (CONSUMER_ID = O.CONSUMER_ID)) 
          	WHEN EMPLOYEE_ID IS NOT NULL THEN
                          (SELECT     EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME
                            FROM          #dsn_alias#.EMPLOYEES
                            WHERE      (EMPLOYEE_ID = O.EMPLOYEE_ID)
    	) END AS ADI
	FROM         
    	ORDER_ROW AS ORR INNER JOIN
      	PRODUCTION_ORDERS_ROW AS POR ON ORR.ORDER_ROW_ID = POR.ORDER_ROW_ID INNER JOIN
       	ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID RIGHT OUTER JOIN
   		PRODUCTION_ORDERS AS PO ON POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
	WHERE     
    	PO.LOT_NO = N'#lot_no#'
</cfquery>
<cfquery name="GET_LOT_K_KONT_ID" datasource="#dsn3#">
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
    	STOCKS AS S INNER JOIN
        PRICE_STANDART AS PS ON S.PRODUCT_ID = PS.PRODUCT_ID INNER JOIN
        PRODUCT_UNIT AS PU ON S.PRODUCT_ID = PU.PRODUCT_ID
	WHERE     
    	PU.IS_MAIN = 1 AND 
        PS.PRICESTANDART_STATUS = 1 AND 
        PS.PURCHASESALES = 0 AND
        S.STOCK_ID IN (#stock_id_list#)
	ORDER BY 	
    	S.PRODUCT_NAME
</cfquery>
<cfif GET_LOT_K_KONT_ID.recordcount>
    <cf_papers paper_type="stock_fis">
    <cfif isdefined("paper_full") and isdefined("paper_number")>
        <cfset system_paper_no = paper_full>
    <cfelse>
        <cfset system_paper_no = "">
    </cfif>
    <cfset attributes.fis_tipi = CT_PROCESS_TYPE_92>
    <cfset attributes.ROWS_ = listlen(stock_id_list)>
    <cfset attributes.DEPARTMENT_IN = dept_in>
    <cfset attributes.DEPARTMENT_OUT = dept_out>
    <cfset attributes.LOCATION_IN = loc_in> 
    <cfset attributes.LOCATION_OUT = loc_out>
    <cfset attributes.ACTIVE_PERIOD = session.ep.period_id>
    <cfset attributes.EMPLOYEE_ID = session.ep.userid>
    <cfset attributes.DETAIL = ' TERMİN : '&DateFormat(get_order_detail.FINISH_DATE,dateformat_style)&' LOT NO : '&lot_no&' SİPARİŞ NO : '&get_order_detail.ORDER_NUMBER&' MÜŞTERİ : '&get_order_detail.ADI&' ÜRÜN ADI : '&get_order_detail.PRODUCT_NAME&' - '&get_order_detail.SPECT_VAR_NAME&' MIKTAR : '&get_order_detail.QUANTITY&' '&get_order_detail.UNIT&' - '&get_order_detail.PRODUCT_NAME2&' NİHAİ MÜŞTERİ : '&get_order_detail.REF_NO> 
    <cfset attributes.BASKET_DISCOUNT_TOTAL = 0>
    <cfset attributes.BASKET_EMPLOYEE1 = ''>  
    <cfset attributes.BASKET_EMPLOYEE_ID1 = ''> 
    <cfset attributes.BASKET_EXTRA_INFO1 = -1>  
    <cfset attributes.BASKET_GROSS_TOTAL = 0>  
    <cfset attributes.BASKET_ID = 12> 
    <cfset attributes.BASKET_MEMBER_PRICECAT = '' > 
    <cfset attributes.BASKET_MONEY = 'TL'>
    <cfset attributes.BASKET_NET_TOTAL = 0>  
    <cfset attributes.BASKET_OTV_1 = 0> 
    <cfset attributes.BASKET_OTV_COUNT = 1>  
    <cfset attributes.BASKET_OTV_FROM_TAX_PRICE = 0>
    <cfset attributes.BASKET_OTV_TOTAL = 0>
    <cfset attributes.BASKET_OTV_VALUE_1 = 0>
    <cfset attributes.BASKET_TAX_1 = 0>
    <cfset attributes.BASKET_TAX_VALUE_1 = 0>
    <cfset attributes.BASKET_PRICE_ROUND_NUMBER = 4>  
    <cfset attributes.BASKET_RATE1 = 1>
    <cfset attributes.BASKET_RATE2 = 1> 
    <cfset attributes.BASKET_RATE_ROUND_NUMBER_ =4>
    <cfset attributes.BASKET_SPECT_TYPE =0> 
    <cfset attributes.BASKET_TOTAL_ROUND_NUMBER_ = 2>
    <cfset attributes.BASKET_TAX_COUNT = 1>  
    <cfset attributes.BASKET_TAX_TOTAL = 0> 
    <cfset attributes.COMPANY_ID = ''>  
    <cfset attributes.CONSUMER_ID = ''> 
    <cfset attributes.CONTROL_FIELD_VALUE =-1>
    <cfset attributes.HIDDEN_RD_MONEY_1 = 'TL' >
    <cfset attributes.EXTRA_COST_RATE =''> 
    <cfset attributes.FIS_DATE = Dateformat(now(),dateformat_style)>
    <cfset attributes.FIS_DATE_H = '00'>
    <cfset attributes.FIS_DATE_M = '00'>
    <cfset attributes.FIS_NO_ = system_paper_no> 
    <cfset attributes.INDIRIM_TOTAL = 0>
    <cfset attributes.INTERNALDEMAND_ID_LIST = ''>
    <cfset attributes.IS_BASKET_HIDDEN = 0>  
    <cfset attributes.IS_GENERAL_PROM = 0> 
    <cfset attributes.KUR_SAY = 1> 
    <cfset attributes.MEMBER_NAME = get_emp_info(session.ep.userid,0,0)>  
    <cfset attributes.MEMBER_TYPE = 'employee'>  
    <cfset attributes.OLD_GENERAL_PROM_AMOUNT = ''>  
    <cfset attributes.OTHER_MONEY_VALUE_1 = 0> 
    <cfset attributes.OTHER_MONEY_1 = 'TL'>
    <cfset attributes.PARTNER_ID = ''>  
    <cfset attributes.PROD_ORDER = ''>  
    <cfset attributes.PROD_ORDER_NUMBER = ''>  
    <cfset attributes.PROJECT_HEAD = ''> 
    <cfset attributes.PROJECT_HEAD_IN = ''>  
    <cfset attributes.PROJECT_ID = ''>  
    <cfset attributes.PROJECT_ID_IN = ''>  
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
    
    <!---<cfoutput>#attributes.DETAIL#</cfoutput>
    <cfdump expand="yes" var="#attributes#">
	<cfabort>--->
    <cfoutput query="GET_LOT_K_KONT_ID">
    	<cfset 'attributes.UNIT#currentrow#' = MAIN_UNIT>
        <cfset 'attributes.UNIT_ID#currentrow#' = PRODUCT_UNIT_ID> 
        <cfset 'attributes.STOCK_CODE#currentrow#' = STOCK_CODE> 
        <cfset 'attributes.STOCK_ID#currentrow#' = STOCK_ID>  
        <cfset 'attributes.PRODUCT_ID#currentrow#' = PRODUCT_ID> 
        <cfset 'attributes.PRODUCT_NAME#currentrow#' = PRODUCT_NAME> 
        <cfset 'attributes.AMOUNT#currentrow#' = Evaluate('AMOUNT_#STOCK_ID#')>
        <cfset 'attributes.AMOUNT_OTHER#currentrow#' = Evaluate('AMOUNT_#STOCK_ID#')>
        <cfset 'attributes.ACTION_ROW_ID#currentrow#' = 0>
        <cfset 'attributes.BARCOD#currentrow#' = BARCOD>
		<cfset 'attributes.BASKET_ROW_DEPARTMAN#currentrow#' = ''>  
        <cfset 'attributes.DARA#currentrow#' = 0>  
        <cfset 'attributes.DARALI#currentrow#' = 1>  
        <cfset 'attributes.DELIVER_DATE#currentrow#' = ''>  
        <cfset 'attributes.DELIVER_DEPT#currentrow#' = ''> 
        <cfset 'attributes.DUEDATE#currentrow#' = ''>  
        <cfset 'attributes.EK_TUTAR#currentrow#' = ''>  
        <cfset 'attributes.EK_TUTAR_COST#currentrow#' = ''>  
        <cfset 'attributes.EK_TUTAR_MARJ#currentrow#' = ''>  

        <cfset 'attributes.EK_TUTAR_OTHER_TOTAL#currentrow#' = 0>  
        <cfset 'attributes.EK_TUTAR_PRICE#currentrow#' = ''>  
        <cfset 'attributes.EK_TUTAR_TOTAL#currentrow#' = 0>
        <cfset 'attributes.EXTRA_COST#currentrow#' = 0> 
        <cfset 'attributes.INDIRIM10#currentrow#' = 0>  
        <cfset 'attributes.INDIRIM1#currentrow#' = 0>  
        <cfset 'attributes.INDIRIM2#currentrow#' = 0>  
        <cfset 'attributes.INDIRIM3#currentrow#' = 0>  
        <cfset 'attributes.INDIRIM4#currentrow#' = 0>  
        <cfset 'attributes.INDIRIM5#currentrow#' = 0>  
        <cfset 'attributes.INDIRIM6#currentrow#' = 0>  
        <cfset 'attributes.INDIRIM7#currentrow#' = 0>  
        <cfset 'attributes.INDIRIM8#currentrow#' = 0>  
        <cfset 'attributes.INDIRIM9#currentrow#' = 0>  
        <cfset 'attributes.ISKONTO_TUTAR#currentrow#' = 0>  
        <cfset 'attributes.IS_COMMISSION#currentrow#' = 0>
        <cfset 'attributes.IS_INVENTORY#currentrow#' = 1>
        <cfset 'attributes.KARMA_PRODUCT_ID#currentrow#' = ''>
        <cfset 'attributes.IS_PRODUCTION#currentrow#' = 0>  
        <cfset 'attributes.IS_PROMOTION#currentrow#' = 0> 
        <cfset 'attributes.LIST_PRICE#currentrow#' = 0> 
        <cfset 'attributes.LOT_NO#currentrow#' = ''> 
        <cfset 'attributes.LIST_PRICE_DISCOUNT#currentrow#' = ''> 
        <cfset 'attributes.MANUFACT_CODE#currentrow#' = ''>  
        <cfset 'attributes.MARJ#currentrow#' = ''> 
        <cfset 'attributes.NET_MALIYET#currentrow#' = 0>  
        <cfset 'attributes.NUMBER_OF_INSTALLMENT#currentrow#' = 0>  
        <cfset 'attributes.ORDER_CURRENCY#currentrow#' = -1>  
        <cfset 'attributes.OTHER_MONEY_GROSS_TOTAL#currentrow#' = 0> 
        <cfset 'attributes.OTV_ORAN#currentrow#' = 0>  
        <cfset 'attributes.PBS_CODE#currentrow#' = ''>  
        <cfset 'attributes.PBS_ID#currentrow#' = ''>  
        <cfset 'attributes.PRICE#currentrow#' = 0> 
        <cfset 'attributes.PRICE_CAT#currentrow#' = ''>  
        <cfset 'attributes.PRICE_NET#currentrow#' = 0>  
        <cfset 'attributes.PRICE_NET_DOVIZ#currentrow#' = 0> 
        <cfset 'attributes.PRICE_OTHER#currentrow#' = 0>  
        <cfset 'attributes.PRODUCT_NAME_OTHER#currentrow#' = ''>
        <cfset 'attributes.PROMOSYON_MALIYET#currentrow#' = ''>  
        <cfset 'attributes.PROMOSYON_YUZDE#currentrow#' = ''>  
        <cfset 'attributes.PROM_RELATION_ID#currentrow#' = ''>  
        <cfset 'attributes.PROM_STOCK_ID#currentrow#' = ''>  
        <cfset 'attributes.RELATED_ACTION_ID#currentrow#' = ''>  
        <cfset 'attributes.RELATED_ACTION_TABLE#currentrow#' = ''>  
        <cfset 'attributes.RESERVE_DATE#currentrow#' = ''>  
        <cfset 'attributes.RESERVE_TYPE#currentrow#' = -3> 
        <cfset 'attributes.ROW_CATALOG_ID#currentrow#' = ''>  
        <cfset 'attributes.ROW_HEIGHT#currentrow#' = ''>  
        <cfset 'attributes.ROW_LASTTOTAL#currentrow#' = 0>  
        <cfset 'attributes.ROW_NETTOTAL#currentrow#' = 0>  
        <cfset 'attributes.ROW_OTVTOTAL#currentrow#' = 0>  
        <cfset 'attributes.ROW_PAYMETHOD_ID#currentrow#' = ''>  
        <cfset 'attributes.ROW_PROJECT_ID#currentrow#' = ''>  
        <cfset 'attributes.ROW_PROJECT_NAME#currentrow#' = ''>  
        <cfset 'attributes.ROW_PROMOTION_ID#currentrow#' = ''>  
        <cfset 'attributes.ROW_SERVICE_ID#currentrow#' = ''>  
        <cfset 'attributes.ROW_SHIP_ID#currentrow#' = 0>  
        <cfset 'attributes.ROW_TAXTOTAL#currentrow#' = 0>  
        <cfset 'attributes.ROW_TOTAL#currentrow#' = 0>  
        <cfset 'attributes.ROW_UNIQUE_RELATION_ID#currentrow#' = ''>  
        <cfset 'attributes.ROW_WIDTH#currentrow#' = ''>
        <cfset 'attributes.ROW_DEPTH#currentrow#' = ''>
        <cfset 'attributes.SHELF_NUMBER#currentrow#' = ''>  
        <cfset 'attributes.SHELF_NUMBER_TXT#currentrow#' = ''>  
        <cfset 'attributes.SPECIAL_CODE#currentrow#' = ''>  
        <cfset 'attributes.SPECT_ID#currentrow#' = ''>  
        <cfset 'attributes.TAX_PRICE#currentrow#' = ''>  
        <cfset 'attributes.TO_SHELF_NUMBER#currentrow#' = ''>  
        <cfset 'attributes.TO_SHELF_NUMBER_TXT#currentrow#' = ''>  
        <cfset 'attributes.UNIT_OTHER#currentrow#' = ''>  
        <cfset 'attributes.WRK_ROW_RELATION_ID#currentrow#' = ''>
        <cfset 'attributes.TAX#currentrow#' = 0>
        <cfset 'attributes.SPECT_NAME#currentrow#' = ''>
    	<cfset 'attributes.WRK_ROW_ID#currentrow#' = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')#>
    </cfoutput>
</cfif>
<cf_get_lang_set module_name="stock"><!--- sayfanin en altinda kapanisi var --->
<cfinclude template="../../../../v16/stock/query/check_our_period.cfm">  
<cfinclude template="../../../../v16/stock/query/get_process_cat.cfm">
<cfset attributes.fis_type = get_process_type.PROCESS_TYPE> 
<!--- kontroller  & tanimlamalar --->
<cfinclude template="../../../../v16/stock/query/add_ship_fis_1.cfm">
<!---  // kontroller & tanimlamalar --->
<cflock name="#CreateUUID()#" timeout="60">
	<cftransaction>
		<cfinclude template="../../../../v16/stock/query/add_ship_fis_2.cfm">
		<cfif isdefined("attributes.rows_")>
			<cfinclude template="../../../../v16/stock/query/add_ship_fis_3.cfm">
			<cfinclude template="../../../../v16/stock/query/add_ship_fis_4.cfm">
			<cfif listfind("111,112,113",attributes.fis_type)><!--- sarf,fire,ambar fisleri icin muhasebeleştirme işlemi  --->
				<cfinclude template="../../../../v16/stock/query/add_ship_fis_6.cfm">
			</cfif>
		<cfelse>
			<cfquery name="ADD_STOCK_FIS_ROW" datasource="#dsn2#">
				INSERT INTO STOCK_FIS_ROW (FIS_NUMBER,FIS_ID) VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#FIS_NO#">,#GET_ID.MAX_ID#)
			</cfquery>
		</cfif>
		<cfquery name="ADD_RELATION" datasource="#dsn2#">
            INSERT INTO 
                #dsn3_alias#.EZGI_METARIAL_RELATIONS
                (
                <cfif isdefined('attributes.p_order_id') and len(attributes.p_order_id)>
                	P_ORDER_ID,
                </cfif>
                <cfif isdefined('attributes.control_method') and len(attributes.control_method)>
                	<cfif attributes.control_method eq 1 or attributes.ORDER_ID eq 0>
                        LOT_NO,
                    <cfelseif attributes.control_method eq 2 and attributes.ORDER_ID gt 0>
                        ORDER_ID,
                    </cfif> 
                <cfelse>
                	LOT_NO, 
                </cfif>
                ACTION_ID,
                PERIOD_ID, 
                TYPE
                )
            VALUES     
                (
                <cfif isdefined('attributes.p_order_id') and len(attributes.p_order_id)>
                	#attributes.p_order_id#,
                </cfif>
                <cfif isdefined('attributes.control_method') and len(attributes.control_method)>
                	<cfif attributes.control_method eq 1 or attributes.ORDER_ID eq 0>
                        '#attributes.lot_no#',
                    <cfelseif attributes.control_method eq 2 and attributes.ORDER_ID gt 0>
                        #attributes.ORDER_ID#,
                    </cfif> 
                <cfelse>
                	'#lot_no#',
                </cfif>
                #GET_ID.MAX_ID#,
                #session.ep.period_id#,
                2
                )
        </cfquery>
		<!---Ek Bilgiler--->
        <cfset attributes.info_id = GET_ID.MAX_ID>
        <cfset attributes.is_upd = 0>
        <cfset attributes.info_type_id=-22>
        <cfinclude template="../../../../v16/objects/query/add_info_plus2.cfm">
        <!---Ek Bilgiler--->
		<!--- secilen islem kategorisine bir action file eklenmisse --->
			<cf_workcube_process_cat 
				process_cat="#form.process_cat#"
				action_id = "#GET_ID.MAX_ID#"
				action_table="STOCK_FIS"
				action_column="FIS_ID"
				is_action_file = 1
				action_page='#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.form_upd_fis&upd_id=#GET_ID.MAX_ID#'
				action_file_name='#get_process_type.action_file_name#'
				action_db_type = '#dsn2#'
				is_template_action_file = '#get_process_type.action_file_from_template#'>
	</cftransaction>
</cflock>
<cfquery name="UPD_GEN_PAP" datasource="#DSN3#">
	UPDATE 
		GENERAL_PAPERS
	SET
		STOCK_FIS_NUMBER = #system_paper_no_add#
	WHERE
		STOCK_FIS_NUMBER IS NOT NULL
</cfquery>
<cfif  isDefined("attributes.fire_fisi_kaydet") and isDefined("fire_fisi_gerekiyor") and len(session_list)>
	<cfquery name="UPD_GEN_PAP" datasource="#DSN3#">
		UPDATE 
			GENERAL_PAPERS
		SET
			STOCK_FIS_NUMBER = #system_paper_no_add_fire#
		WHERE
			STOCK_FIS_NUMBER IS NOT NULL
	</cfquery>
</cfif>
<cfif not isdefined("attributes.is_mobile")>
	<cfif session.ep.our_company_info.is_cost eq 1 and get_process_type.IS_COST eq 1><!--- sirket maliyet takip ediliyorsa not js le yonlenioyr cunku cost_action locationda calismiyor --->
        <cfscript>
            cost_action(action_type:3,action_id:GET_ID.MAX_ID,query_type:1);
        </cfscript>
        <script type="text/javascript">
            window.location.href="<cfoutput>#request.self#?fuseaction=stock.form_add_fis&event=upd&upd_id=#GET_ID.MAX_ID#</cfoutput>";
        </script>
    <cfelse>
        <cflocation url="#request.self#?fuseaction=stock.form_add_fis&event=upd&upd_id=#GET_ID.MAX_ID#" addtoken="No">
    </cfif>
<cfelse>    
    <script type="text/javascript">
        wrk_opener_reload();
		window.close();
 	</script>
</cfif>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#"><!--- sayfanin en ustunde acilisi var --->