<!---
    File: add_ezgi_pallets_ship_fis.cfm
    Folder: Add_Ons\ezgi\e_wm\query
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description:
	1-6395-4373-1-10000849-398,
	1-Sıra No
	2-Stok_id
	3-Spect_main_id
	4-Miktar
	5-lot_no
	6-order_row_id
--->
<cfset current_row_list = ''>
<cfset stock_id_list = ''>
<cfset form.process_cat = attributes.process_cat>
<cfset attributes.action_id = attributes.row_info_id>
<cfloop list="#attributes.action_id#" index="i">
	<cfset current_row_list = ListAppend(current_row_list,Listgetat(i,1,'-'))>
    <cfset stock_id_list = ListAppend(stock_id_list,Listgetat(i,2,'-'))>
    <cfset 'STOCK_ID_#Listgetat(i,1,'-')#' = Listgetat(i,2,'-')>
    <cfset 'AMOUNT_#Listgetat(i,1,'-')#' = Listgetat(i,4,'-')>
    <cfset 'SPECT_MAIN_ID_#Listgetat(i,1,'-')#' = Listgetat(i,3,'-')>
    <cfset 'LOT_NO_#Listgetat(i,1,'-')#' = Listgetat(i,5,'-')>
    <cfset 'ORDER_ROW_ID_#Listgetat(i,1,'-')#' = Listgetat(i,6,'-')>
    
    <cfset 'SHELF_#Listgetat(i,1,'-')#' = ''>
    <cfset 'SHELF_ID_#Listgetat(i,1,'-')#' = ''>
    <cfif isdefined('attributes.shelf_fis')> <!---Raf Çalışacaksa--->
    	<cfset 'SHELF_ID_#Listgetat(i,1,'-')#' = Listgetat(i,6,'-')>
        <cfquery name="get_shelf_id" datasource="#dsn2#">
            SELECT 
                SHELF_CODE       
            FROM            
                #dsn3_alias#.PRODUCT_PLACE
            WHERE        
                PRODUCT_PLACE_ID = #Listgetat(i,6,'-')#
        </cfquery>
        <cfset 'SHELF_#Listgetat(i,1,'-')#' = get_shelf_id.SHELF_CODE>
        <cfif isdefined('attributes.change_shelf_fis')> <!---Raf Değiştirme Fişinden Geliyorsa--->
            <cfset 'SHELF_OTHER_ID_#Listgetat(i,1,'-')#' = Listgetat(i,7,'-')>
            <cfquery name="get_shelf_id" datasource="#dsn2#">
                SELECT        
                    SHELF_CODE
                FROM            
                    #dsn3_alias#.PRODUCT_PLACE
                WHERE        
                    PRODUCT_PLACE_ID = #Listgetat(i,7,'-')#
            </cfquery>
            <cfset 'SHELF_OTHER_#Listgetat(i,1,'-')#' =  get_shelf_id.SHELF_CODE>
        </cfif>
    </cfif>
    
    <cfquery name="GET_LOT_K_KONT_ID" datasource="#dsn2#">
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
            S.STOCK_ID = #Evaluate('STOCK_ID_#Listgetat(i,1,'-')#')#
        ORDER BY 	
            S.PRODUCT_NAME
    </cfquery>
    <cfquery name="get_spect" datasource="#dsn2#">
    	SELECT  
        	TOP (1)      
        	SPECT_VAR_ID, 
            SPECT_VAR_NAME
		FROM            
        	#dsn3_alias#.SPECTS
		WHERE        
        	SPECT_VAR_ID IN
                         	(
                            	SELECT        
                                	MAX(SPECT_VAR_ID) AS SPECT_VAR_ID
                               	FROM            
                                	#dsn3_alias#.SPECTS AS SPECTS_1
                               	WHERE   
                                	<cfif Evaluate('SPECT_MAIN_ID_#Listgetat(i,1,'-')#') neq 0>
                                    	SPECT_MAIN_ID = #Evaluate('SPECT_MAIN_ID_#Listgetat(i,1,'-')#')#
                                    <cfelse>
                                		STOCK_ID = #Evaluate('STOCK_ID_#Listgetat(i,1,'-')#')#
                                    </cfif>
                          	)
     	ORDER BY
        	SPECT_VAR_ID
    </cfquery>
    <cfoutput query="GET_LOT_K_KONT_ID">
    	<cfset 'PRODUCT_UNIT_ID_#Listgetat(i,1,'-')#' = GET_LOT_K_KONT_ID.PRODUCT_UNIT_ID>
        <cfset 'MAIN_UNIT_#Listgetat(i,1,'-')#' = GET_LOT_K_KONT_ID.MAIN_UNIT>
        <cfset 'PRICE_#Listgetat(i,1,'-')#' = GET_LOT_K_KONT_ID.PRICE>
        <cfset 'MONEY_#Listgetat(i,1,'-')#' = GET_LOT_K_KONT_ID.MONEY>
        <cfset 'BARCOD_#Listgetat(i,1,'-')#' = GET_LOT_K_KONT_ID.BARCOD>
        <cfset 'TAX_#Listgetat(i,1,'-')#' = GET_LOT_K_KONT_ID.TAX>
        <cfset 'PRODUCT_ID_#Listgetat(i,1,'-')#' = GET_LOT_K_KONT_ID.PRODUCT_ID>
        <cfset 'PRODUCT_NAME_#Listgetat(i,1,'-')#' = GET_LOT_K_KONT_ID.PRODUCT_NAME>
        <cfset 'STOCK_CODE_#Listgetat(i,1,'-')#' = GET_LOT_K_KONT_ID.STOCK_CODE>
    </cfoutput>
    <cfif get_spect.recordcount>
		<cfoutput query="get_spect">
            <cfset 'SPECT_ID#Listgetat(i,1,'-')#' = get_spect.SPECT_VAR_ID>
            <cfset 'SPECT_NAME#Listgetat(i,1,'-')#' = get_spect.SPECT_VAR_NAME>
        </cfoutput>
    <cfelse>
    	<cfset 'SPECT_ID#Listgetat(i,1,'-')#' = ''>
        <cfset 'SPECT_NAME#Listgetat(i,1,'-')#' = ''>
    </cfif>
</cfloop>
<cfset session.ep.our_company_info.is_cost = 1><!---Dikkat Firmaya Göre Değişir--->
<cfif ListLen(current_row_list)>
    <cfquery name="GET_GEN_PAPER" datasource="#dsn2#">
		SELECT * FROM #dsn3_alias#.GENERAL_PAPERS WHERE PAPER_TYPE IS NULL
	</cfquery>
	<cfset paper_code = get_gen_paper.STOCK_FIS_NO>
	<cfset paper_number = (get_gen_paper.STOCK_FIS_NUMBER*1)+1> <!---Stok Fiş No Bir Artırılıyor--->
    <cfset system_paper_no = paper_code & '-' & paper_number>
	<cfset system_paper_no_add = paper_number>
    <cfset attributes.FIS_NO= system_paper_no>
    
    <cfset attributes.ROWS_ = listlen(stock_id_list)>
    <cfset attributes.DEPARTMENT_OUT = ''>
    <cfset attributes.LOCATION_OUT = ''> 
    <cfset attributes.ACTIVE_PERIOD = session.ep.period_id>
    <cfset attributes.DEPARTMENT_IN = Listgetat(attributes.dep_in,1,'-')>
	<cfset attributes.LOCATION_IN = Listgetat(attributes.dep_in,2,'-')> 
    <cfset attributes.EMPLOYEE_ID = session.ep.userid>
    <cfset attributes.DETAIL = 'Seri No Oluşturma İşlemi'> 
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
    <cfset 	attributes.XML_MULTIPLE_COUNTING_FIS =0>
    <cfset attributes.fis_date_m = '00'>
    <cfset attributes.fis_date_h = '00'>
    <cfloop list="#current_row_list#" index="k">
    	<cfset 'attributes.UNIT#k#' = Evaluate('MAIN_UNIT_#k#')>
        <cfset 'attributes.UNIT_ID#k#' = Evaluate('PRODUCT_UNIT_ID_#k#') > 
        <cfset 'attributes.STOCK_CODE#k#' = Evaluate('STOCK_CODE_#k#') > 
        <cfset 'attributes.STOCK_ID#k#' = Evaluate('STOCK_ID_#k#') >  
        <cfset 'attributes.PRODUCT_ID#k#' = Evaluate('PRODUCT_ID_#k#') > 
        <cfset 'attributes.PRODUCT_NAME#k#' = Evaluate('PRODUCT_NAME_#k#') > 
        <cfset 'attributes.AMOUNT#k#' = Evaluate('AMOUNT_#k#')>
        <cfset 'attributes.AMOUNT_OTHER#k#' = Evaluate('AMOUNT_#k#')>
        <cfset 'attributes.ACTION_ROW_ID#k#' = 0>
        <cfset 'attributes.BARCOD#k#' = Evaluate('BARCOD_#k#') >
		<cfset 'attributes.BASKET_ROW_DEPARTMAN#k#' = ''>  
        <cfset 'attributes.DARA#k#' = 0>  
        <cfset 'attributes.DARALI#k#' = 1>  
        <cfset 'attributes.DELIVER_DATE#k#' = ''>  
        <cfset 'attributes.DELIVER_DEPT#k#' = ''> 
        <cfset 'attributes.DUEDATE#k#' = ''>  
        <cfset 'attributes.EK_TUTAR#k#' = ''>  
        <cfset 'attributes.EK_TUTAR_COST#k#' = ''>  
        <cfset 'attributes.EK_TUTAR_MARJ#k#' = ''>  
        <cfset 'attributes.EK_TUTAR_OTHER_TOTAL#k#' = 0>  
        <cfset 'attributes.EK_TUTAR_PRICE#k#' = ''>  
        <cfset 'attributes.EK_TUTAR_TOTAL#k#' = 0>
        <cfset 'attributes.EXTRA_COST#k#' = 0> 
        <cfset 'attributes.INDIRIM10#k#' = 0>  
        <cfset 'attributes.INDIRIM1#k#' = 0>  
        <cfset 'attributes.INDIRIM2#k#' = 0>  
        <cfset 'attributes.INDIRIM3#k#' = 0>  
        <cfset 'attributes.INDIRIM4#k#' = 0>  
        <cfset 'attributes.INDIRIM5#k#' = 0>  
        <cfset 'attributes.INDIRIM6#k#' = 0>  
        <cfset 'attributes.INDIRIM7#k#' = 0>  
        <cfset 'attributes.INDIRIM8#k#' = 0>  
        <cfset 'attributes.INDIRIM9#k#' = 0>  
        <cfset 'attributes.ISKONTO_TUTAR#k#' = 0>  
        <cfset 'attributes.IS_COMMISSION#k#' = 0>
        <cfset 'attributes.IS_INVENTORY#k#' = 1>
        <cfset 'attributes.KARMA_PRODUCT_ID#k#' = ''>
        <cfset 'attributes.IS_PRODUCTION#k#' = 0>  
        <cfset 'attributes.IS_PROMOTION#k#' = 0> 
        <cfset 'attributes.LIST_PRICE#k#' = 0> 
        <cfset 'attributes.LOT_NO#k#' = Evaluate('LOT_NO_#k#')> 
        <cfset 'attributes.LIST_PRICE_DISCOUNT#k#' = ''> 
        <cfset 'attributes.MANUFACT_CODE#k#' = ''>  
        <cfset 'attributes.MARJ#k#' = ''> 
        <cfset 'attributes.NET_MALIYET#k#' = 0>  
        <cfset 'attributes.NUMBER_OF_INSTALLMENT#k#' = 0>  
        <cfset 'attributes.ORDER_CURRENCY#k#' = -1>  
        <cfset 'attributes.OTHER_MONEY_GROSS_TOTAL#k#' = 0> 
        <cfset 'attributes.OTHER_MONEY#k#' = 'TL'>
        <cfset 'attributes.OTHER_MONEY_#k#' = 'TL'>
        <cfset 'attributes.OTV_ORAN#k#' = 0>  
        <cfset 'attributes.PBS_CODE#k#' = ''>  
        <cfset 'attributes.PBS_ID#k#' = ''>  
        <cfset 'attributes.PRICE#k#' = 0> 
        <cfset 'attributes.PRICE_CAT#k#' = ''>  
        <cfset 'attributes.PRICE_NET#k#' = 0>  
        <cfset 'attributes.PRICE_NET_DOVIZ#k#' = 0> 
        <cfset 'attributes.PRICE_OTHER#k#' = 0>  
        <cfset 'attributes.PRODUCT_NAME_OTHER#k#' = Evaluate('ORDER_ROW_ID_#k#')>
        <cfset 'attributes.PROMOSYON_MALIYET#k#' = ''>  
        <cfset 'attributes.PROMOSYON_YUZDE#k#' = ''>  
        <cfset 'attributes.PROM_RELATION_ID#k#' = ''>  
        <cfset 'attributes.PROM_STOCK_ID#k#' = ''>  
        <cfset 'attributes.RELATED_ACTION_ID#k#' = ''>  
        <cfset 'attributes.RELATED_ACTION_TABLE#k#' = ''>  
        <cfset 'attributes.RESERVE_DATE#k#' = ''>  
        <cfset 'attributes.RESERVE_TYPE#k#' = -3> 
        <cfset 'attributes.ROW_CATALOG_ID#k#' = ''>  
        <cfset 'attributes.ROW_HEIGHT#k#' = ''>  
        <cfset 'attributes.ROW_LASTTOTAL#k#' = 0>  
        <cfset 'attributes.ROW_NETTOTAL#k#' = 0>  
        <cfset 'attributes.ROW_OTVTOTAL#k#' = 0>  
        <cfset 'attributes.ROW_PAYMETHOD_ID#k#' = ''>  
        <cfset 'attributes.ROW_PROJECT_ID#k#' = ''>  
        <cfset 'attributes.ROW_PROJECT_NAME#k#' = ''>  
        <cfset 'attributes.ROW_PROMOTION_ID#k#' = ''>  
        <cfset 'attributes.ROW_SERVICE_ID#k#' = ''>  
        <cfset 'attributes.ROW_SHIP_ID#k#' = 0>  
        <cfset 'attributes.ROW_TAXTOTAL#k#' = 0>  
        <cfset 'attributes.ROW_TOTAL#k#' = 0>  
        <cfset 'attributes.ROW_UNIQUE_RELATION_ID#k#' = ''>  
        <cfset 'attributes.ROW_WIDTH#k#' = ''>
        <cfset 'attributes.ROW_DEPTH#k#' = ''>

        <cfset 'attributes.SHELF_NUMBER#k#' = ''>  
     	<cfset 'attributes.SHELF_NUMBER_TXT#k#' = ''> 
    	<cfset 'attributes.TO_SHELF_NUMBER#k#' = ''>  
      	<cfset 'attributes.TO_SHELF_NUMBER_TXT#k#' = ''>
        <cfset 'attributes.SPECIAL_CODE#k#' = ''>  
        <cfset 'attributes.SPECT_ID#k#' = Evaluate('SPECT_ID#k#')>  
        <cfset 'attributes.TAX_PRICE#k#' = ''>  
        <cfset 'attributes.UNIT_OTHER#k#' = ''>  
        <cfset 'attributes.WRK_ROW_RELATION_ID#k#' = ''>
        <cfset 'attributes.TAX#k#' = 0>
        <cfset 'attributes.SPECT_NAME#k#' = Evaluate('SPECT_NAME#k#')>
    	<cfset 'attributes.WRK_ROW_ID#k#' = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')#>
    </cfloop>
</cfif>
<cfinclude template="../../../../v16/stock/query/get_process_cat.cfm">
<cfset attributes.fis_type = get_process_type.PROCESS_TYPE> 
<cf_date tarih = 'attributes.fis_date'>
<cfinclude template="../../../../v16/stock/query/add_ship_fis_2.cfm">
<cfif isdefined("attributes.rows_")>
	<cfinclude template="../../../../v16/stock/query/add_ship_fis_3.cfm">
	<cfinclude template="../../../../v16/stock/query/add_ship_fis_4.cfm">
	<cfif listfind("111,112,113",attributes.fis_type)> <!---sarf,fire,ambar fisleri icin muhasebeleştirme işlemi  --->
		<cfinclude template="../../../../v16/stock/query/add_ship_fis_6.cfm">
	</cfif>
    <cfquery name="get_row_stfis" datasource="#dsn2#">
    	SELECT 
            SFR.FIS_ID, 
            SFR.FIS_NUMBER, 
            SFR.STOCK_ID, 
            SFR.AMOUNT, 
            SFR.UNIT, 
            SFR.UNIT_ID, 
            SFR.SPECT_VAR_ID, 
            SFR.SPECT_VAR_NAME, 
            SFR.LOT_NO, 
            SFR.OTHER_MONEY, 
            CAST(SFR.PRODUCT_NAME2 AS INT) AS ORDER_ROW_ID, 
            SFR.AMOUNT2, 
            SP.SPECT_MAIN_ID, 
            SFR.WRK_ROW_ID
		FROM     
        	STOCK_FIS_ROW AS SFR LEFT OUTER JOIN
          	#dsn3_alias#.SPECTS AS SP ON SFR.SPECT_VAR_ID = SP.SPECT_VAR_ID
		WHERE  
        	FIS_ID = #GET_ID.MAX_ID#
		ORDER BY 
        	STOCK_FIS_ROW_ID
    </cfquery>
    <cfquery name="GET_SERIAL" datasource="#DSN2#">
    	SELECT 
         	EZGI_SERIAL_ID, 
          	COMPANY_ID, 
         	ONTAKI, 
        	NUMARATOR, 
        	SONTAKI, 
         	SAYAC
     	FROM     
        	#dsn3_alias#.EZGI_SERIAL_NO
     	WHERE  
         	COMPANY_ID = 0
   	</cfquery>
    <cfset sayac = GET_SERIAL.SAYAC>
  	<cfset numarator = GET_SERIAL.NUMARATOR>
    <cfloop query="get_row_stfis">
        <cfloop from="1" to="#AMOUNT#" index="k">
            <cfset sayac = sayac + 1>
            <cfif len(GET_SERIAL.NUMARATOR) gt len(sayac)>
                <cfset fark = len(GET_SERIAL.NUMARATOR)-len(sayac)>
                <cfset serino = '#left(GET_SERIAL.NUMARATOR,fark)##sayac#'>
            <cfelse>
                <cfset serino = '#sayac#'>
            </cfif>
            
            <cfif len(GET_SERIAL.ONTAKI)>
                <cfset serino = '#GET_SERIAL.ONTAKI##serino#'>
            </cfif>
            <cfif len(GET_SERIAL.SONTAKI)>
                <cfset serino = '#serino##GET_SERIAL.SONTAKI#'>
            </cfif>
            
            <cfset attributes.wrk_row_id = '#serino#'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')# & '_' &#session.ep.userid# & '_' & #k#>
        
        	<cfquery name="add_serial_no" datasource="#dsn2#">
                INSERT INTO 
                    #dsn3_alias#.SERVICE_GUARANTY_NEW
                    (
                        STOCK_ID, 
                        SERIAL_NO, 
                        LOT_NO, 
                        IN_OUT, 
                        IS_PURCHASE, 
                        IS_SALE, 
                        IS_RETURN, 
                        IS_RMA, 
                        IS_SERVICE, 
                        PROCESS_CAT, 
                        PROCESS_ID, 
                        PROCESS_NO, 
                        PERIOD_ID, 
                        DEPARTMENT_ID, 
                        LOCATION_ID, 
                        PURCHASE_GUARANTY_CATID, 
                        PURCHASE_START_DATE, 
                        PURCHASE_COMPANY_ID, 
                        IS_SARF, 
                        SPECT_ID, 
                        IS_SERI_SONU, 
                        WRK_ID, 
                        RECORD_DATE, 
                        RECORD_EMP, 
                        RECORD_IP, 
                        WRK_ROW_ID, 
                        UNIT_TYPE, 
                        UNIT_ROW_QUANTITY,
                        RESERVE_ORDER_ROW_ID
                    )
                VALUES 
                    (
                        #get_row_stfis.STOCK_ID#,
                        '#serino#',
                        '#get_row_stfis.LOT_NO#',
                        1,
                        1,
                        0,
                        0,
                        0,
                        0,
                        115,
                        #GET_ID.MAX_ID#,
                        '#get_row_stfis.FIS_NUMBER#',
                        #session.ep.period_id#,
                        #Listgetat(attributes.dep_in,1,'-')#,
                        #Listgetat(attributes.dep_in,2,'-')#,
                        1,
                        #now()#,
                        -1,
                        0,
                        <cfif len(get_row_stfis.SPECT_MAIN_ID)>#get_row_stfis.SPECT_MAIN_ID#<cfelse>NULL</cfif>,
                        0,
                        '#attributes.wrk_row_id#',
                        #now()#,
                        #session.ep.userid#,
                        '#cgi.remote_addr#',
                        '#get_row_stfis.WRK_ROW_ID#',
                        1,
                        #get_row_stfis.AMOUNT#,
                        <cfif len(get_row_stfis.ORDER_ROW_ID)>#get_row_stfis.ORDER_ROW_ID#<cfelse>NULL</cfif>
                    )
       		</cfquery>
    	</cfloop>
    </cfloop>
    <cfquery name="GET_SERIAL" datasource="#DSN2#">
        UPDATE #dsn3_alias#.EZGI_SERIAL_NO SET SAYAC = #sayac# WHERE COMPANY_ID = 0
    </cfquery>
<cfelse>
	<cfquery name="ADD_STOCK_FIS_ROW" datasource="#dsn2#">
		INSERT INTO STOCK_FIS_ROW (FIS_NUMBER,FIS_ID) VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#FIS_NO#">,#GET_ID.MAX_ID#)
	</cfquery>
</cfif>
<!---Ek Bilgiler--->
<cfset attributes.info_id = GET_ID.MAX_ID>
<cfset attributes.is_upd = 0>
<cfset attributes.info_type_id=-22>
<cfinclude template="../../../../v16/objects/query/add_info_plus2.cfm">
<!---Ek Bilgiler
secilen islem kategorisine bir action file eklenmisse --->
<cf_workcube_process_cat 
				process_cat="#attributes.process_cat#"
				action_id = "#GET_ID.MAX_ID#"
				action_table="STOCK_FIS"
				action_column="FIS_ID"
				is_action_file = 1
				action_page='#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.form_upd_fis&upd_id=#GET_ID.MAX_ID#'
				action_file_name='#get_process_type.action_file_name#'
				action_db_type = '#dsn2#'
				is_template_action_file = '#get_process_type.action_file_from_template#'>

<cfquery name="UPD_GEN_PAP" datasource="#dsn2#">
	UPDATE 
		#dsn3_alias#.GENERAL_PAPERS
	SET
		STOCK_FIS_NUMBER = #system_paper_no_add#
	WHERE
		STOCK_FIS_NUMBER IS NOT NULL
</cfquery>
<cflocation url="#request.self#?fuseaction=stock.form_add_fis&event=upd&upd_id=#GET_ID.MAX_ID#" addtoken="No">
