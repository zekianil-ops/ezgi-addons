<!---
    File: add_ambar_fis.cfm
    Folder: Add_Ons\ezgi\e-pda\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfset current_row_list = ''>
<cfset stock_id_list = ''>
<cfif isdefined('attributes.ambarfis') and (attributes.ambarfis eq 10 or attributes.ambarfis eq 11 or attributes.ambarfis eq 12)><!---Palet-Depodan Rafa veya Palet-Raf Değiştir veya -Palet-Raftan Depoya--->
	<cfset palet_currentrow = 1>
	<cfloop list="#attributes.palet_action_id#" index="p">
        <cfset palet_stock_id = Listgetat(p,2,'-')>
        <cfset palet_amount = Listgetat(p,3,'-')>
    	<cfset palet_shelf = Listgetat(p,4,'-')>
        <cfset palet_shelf_other = Listgetat(p,5,'-')>
        <cfif listlen(p,'-') gte 6>
        	<cfset palet_spect_main_id = Listgetat(p,6,'-')>
       	<cfelse>
        	<cfset palet_spect_main_id = 0>
        </cfif>
        
  		<cfquery name="get_palet_stock" datasource="#dsn3#">
        	SELECT 
            	EP.PACKING_ID, 
                EP.BARCODE, 
                EP.TYPE, 
                ISNULL(EPR.AMOUNT,0) AS AMOUNT, 
                S.STOCK_ID, 
                EPR.SPECT_MAIN_ID, 
                EPR.LOT_NO,
                EPR.SERIAL_NO
			FROM     
            	STOCKS AS S INNER JOIN
                EZGI_PACKING_ROW AS EPR ON S.STOCK_ID = EPR.STOCK_ID INNER JOIN
                EZGI_PACKING AS EP ON EPR.PACKING_ID = EP.PACKING_ID
			WHERE  
            	EP.PACKING_ID = #palet_stock_id#
        </cfquery>
        <cfif get_palet_stock.recordcount>
        	<cfoutput query="get_palet_stock">
                <cfset p_amount = palet_amount*get_palet_stock.AMOUNT>
                <cfset p_action_id = '#palet_currentrow#-#get_palet_stock.STOCK_ID#-#p_amount#-#palet_shelf#-#palet_shelf_other#-#get_palet_stock.SPECT_MAIN_ID#'>
                <cfif isdefined('attributes.action_id')>
                	<cfset attributes.action_id = '#attributes.action_id#,#p_action_id#'>
                <cfelse>
                	<cfset attributes.action_id = '#p_action_id#'>
                </cfif>
                <cfset palet_currentrow = palet_currentrow+1>
			</cfoutput>
        <cfelse>
        	<script type="text/javascript">
				alert("Palet İçinde Herhangi Bir Ürün Tanımlanmamış!");
				window.location.href="<cfoutput>#request.self#?fuseaction=myhome.welcome</cfoutput>";
			</script>
            <cfabort>
        </cfif>     
 	</cfloop>
</cfif>
<cfset form.process_cat = attributes.process_cat>
<cfloop list="#attributes.action_id#" index="i">
	<cfset current_row_list = ListAppend(current_row_list,Listgetat(i,1,'-'))>
    <cfset stock_id_list = ListAppend(stock_id_list,Listgetat(i,2,'-'))>
    <cfset 'STOCK_ID_#Listgetat(i,1,'-')#' = Listgetat(i,2,'-')>
    <cfset 'AMOUNT_#Listgetat(i,1,'-')#' = Listgetat(i,3,'-')>
    <cfset 'SHELF_#Listgetat(i,1,'-')#' = Listgetat(i,4,'-')>
    <cfif Listlen(i,'-') gte 6>
    	<cfset 'SPECT_MAIN_ID_#Listgetat(i,1,'-')#' = Listgetat(i,6,'-')>
  	<cfelse>
    	<cfset 'SPECT_MAIN_ID_#Listgetat(i,1,'-')#' = 0>
    </cfif>	
    <cfquery name="get_shelf_id" datasource="#dsn3#">
    	SELECT        
        	PRODUCT_PLACE_ID
		FROM            
        	PRODUCT_PLACE
		WHERE        
        	SHELF_CODE = '#Listgetat(i,4,'-')#'
    </cfquery>
    <cfset 'SHELF_ID_#Listgetat(i,1,'-')#' = get_shelf_id.PRODUCT_PLACE_ID>
    <cfif isdefined('attributes.change_shelf_fis')> <!---Raf Değiştirme Fişinden Geliyorsa--->
    	<cfset 'SHELF_OTHER_#Listgetat(i,1,'-')#' = Listgetat(i,5,'-')>
        <cfquery name="get_shelf_id" datasource="#dsn3#">
            SELECT        
                PRODUCT_PLACE_ID
            FROM            
                PRODUCT_PLACE
            WHERE        
                SHELF_CODE = '#Listgetat(i,5,'-')#'
        </cfquery>
    	<cfset 'SHELF_OTHER_ID_#Listgetat(i,1,'-')#' = get_shelf_id.PRODUCT_PLACE_ID>
    </cfif>
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
            S.STOCK_ID = #Evaluate('STOCK_ID_#Listgetat(i,1,'-')#')#
        ORDER BY 	
            S.PRODUCT_NAME
    </cfquery>
    <cfquery name="get_spect" datasource="#dsn3#">
    	SELECT  
        	TOP (1)      
        	SPECT_VAR_ID, 
            SPECT_VAR_NAME
		FROM            
        	SPECTS
		WHERE        
        	SPECT_VAR_ID IN
                         	(
                            	SELECT        
                                	MAX(SPECT_VAR_ID) AS SPECT_VAR_ID
                               	FROM            
                                	SPECTS AS SPECTS_1
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
    <cf_papers paper_type="stock_fis">
    <cfif isdefined("paper_full") and isdefined("paper_number")>
        <cfset system_paper_no = paper_full>
    <cfelse>
        <cfset system_paper_no = "">
    </cfif>
    <cfset attributes.ROWS_ = listlen(stock_id_list)>
    <cfset attributes.DEPARTMENT_OUT = Listgetat(attributes.dep_out,1,'-')>
    <cfset attributes.LOCATION_OUT = Listgetat(attributes.dep_out,2,'-')> 
    <cfset attributes.ACTIVE_PERIOD = session.ep.period_id>
    <cfif isdefined('attributes.dep_in')>
    	<cfset attributes.DEPARTMENT_IN = Listgetat(attributes.dep_in,1,'-')>
		<cfset attributes.LOCATION_IN = Listgetat(attributes.dep_in,2,'-')> 
    <cfelse>
    	<cfset attributes.DEPARTMENT_IN = ''>
    	<cfset attributes.LOCATION_IN = ''> 
    </cfif>
    <cfset attributes.EMPLOYEE_ID = session.ep.userid>
    <cfif not isdefined('attributes.detail')>
    	<cfset attributes.DETAIL = ''> 
    </cfif>
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
    <cfif isdefined('attributes.p_order_id') and len(attributes.p_order_id)>
    	<cfset attributes.PROD_ORDER_NUMBER = attributes.p_order_id> 
    <cfelse>
    	<cfset attributes.PROD_ORDER_NUMBER = ''>  
    </cfif> 
    <cfset attributes.PROJECT_HEAD = ''> 
    <cfset attributes.PROJECT_HEAD_IN = ''>  
    <cfset attributes.PROJECT_ID = ''>  
    <cfset attributes.PROJECT_ID_IN = ''>  
    <cfset attributes.RD_MONEY = 1>  
    <cfif isdefined('attributes.ref_no')>
    	<cfset attributes.REF_NO = attributes.ref_no>
    <cfelse>
    	<cfset attributes.REF_NO = ''> 
    </cfif>
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
        <cfset 'attributes.LOT_NO#k#' = ''> 
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
        <cfset 'attributes.PRODUCT_NAME_OTHER#k#' =''>
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
        <cfif isdefined('attributes.change_shelf_fis')> <!---Raf Değiştirme Fişinden Geliyorsa--->
        	<cfset 'attributes.SHELF_NUMBER#k#' = Evaluate('SHELF_ID_#k#')>  
          	<cfset 'attributes.SHELF_NUMBER_TXT#k#' = Evaluate('SHELF_#k#')> 
           	<cfset 'attributes.TO_SHELF_NUMBER#k#' = Evaluate('SHELF_OTHER_ID_#k#')>  
          	<cfset 'attributes.TO_SHELF_NUMBER_TXT#k#' = Evaluate('SHELF_OTHER_#k#')>
        <cfelse>
			<cfif isdefined('attributes.tersfis')> <!---Ambardan Mal Kabule Fişinden Geliyorsa--->
                <cfset 'attributes.SHELF_NUMBER#k#' = Evaluate('SHELF_ID_#k#')>  
                <cfset 'attributes.SHELF_NUMBER_TXT#k#' = Evaluate('SHELF_#k#')> 
                <cfset 'attributes.TO_SHELF_NUMBER#k#' = ''>  
                <cfset 'attributes.TO_SHELF_NUMBER_TXT#k#' = ''>
            <cfelse> <!---Mal Kabulden Ambara Fişinden Geliyorsa--->
                <cfset 'attributes.SHELF_NUMBER#k#' = ''>  
                <cfset 'attributes.SHELF_NUMBER_TXT#k#' = ''> 
                <cfset 'attributes.TO_SHELF_NUMBER#k#' = Evaluate('SHELF_ID_#k#') >  
                <cfset 'attributes.TO_SHELF_NUMBER_TXT#k#' = Evaluate('SHELF_#k#')>
            </cfif>
       	</cfif>
        <cfif isdefined('attributes.ambarfis') and attributes.ambarfis eq 13> <!---İç Talep Bazlı Ambar Fişi İse--->
        	<cfquery name="GET_EZGI_INTERNAL_ROW" datasource="#dsn3#">
            	SELECT 
                	I_ROW_ID, 
                    WRK_ROW_ID
				FROM     
                	INTERNALDEMAND_ROW
				WHERE  
                	I_ID = #attributes.e_internaldemand_id# AND 
                    STOCK_ID = #Evaluate('STOCK_ID_#k#')#
            </cfquery>
        	<cfset 'attributes.ROW_INTERNALDEMAND_ID#k#' = '#GET_EZGI_INTERNAL_ROW.I_ROW_ID#'>
            <cfset 'attributes.WRK_ROW_RELATION_ID#k#' = '#GET_EZGI_INTERNAL_ROW.WRK_ROW_ID#'>
        <cfelse>
        	<cfset 'attributes.WRK_ROW_RELATION_ID#k#' = ''>
        </cfif>
        <cfset 'attributes.SPECIAL_CODE#k#' = ''>  
        <cfset 'attributes.SPECT_ID#k#' = Evaluate('SPECT_ID#k#')>  
        <cfset 'attributes.TAX_PRICE#k#' = ''>  
        <cfset 'attributes.UNIT_OTHER#k#' = ''>  
        <cfset 'attributes.TAX#k#' = 0>
        <cfset 'attributes.SPECT_NAME#k#' = Evaluate('SPECT_NAME#k#')>
    	<cfset 'attributes.WRK_ROW_ID#k#' = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')#>
    </cfloop>
</cfif>
<!---<cfinclude template="../../../../v16/stock/query/check_our_period.cfm"> --->
<cfinclude template="../../../../v16/stock/query/get_process_cat.cfm">
<cfset attributes.fis_type = get_process_type.PROCESS_TYPE> 
<!--- kontroller  & tanimlamalar --->
<cfinclude template="add_ship_fis_1_1.cfm">
<cfif not isDefined("get_stock_amount")>
	<cfinclude template="add_ship_fis_1_2.cfm">
</cfif>
  <!---// kontroller & tanimlamalar --->
<cflock name="#CreateUUID()#" timeout="60">
	<cftransaction>
		<cfinclude template="../../../../v16/stock/query/add_ship_fis_2.cfm">
		<cfif isdefined("attributes.rows_")>
			<cfinclude template="../../../../v16/stock/query/add_ship_fis_3.cfm">
			<cfinclude template="../../../../v16/stock/query/add_ship_fis_4.cfm">
			<cfif listfind("111,112,113",attributes.fis_type)> sarf,fire,ambar fisleri icin muhasebeleştirme işlemi  
				<cfinclude template="../../../../v16/stock/query/add_ship_fis_6.cfm">
			</cfif>
		<cfelse>
			<cfquery name="ADD_STOCK_FIS_ROW" datasource="#dsn2#">
				INSERT INTO STOCK_FIS_ROW (FIS_NUMBER,FIS_ID) VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#FIS_NO#">,#GET_ID.MAX_ID#)
			</cfquery>
		</cfif>
        
        <cfif isdefined('attributes.ambarfis') and attributes.ambarfis eq 13> <!---İç Talep Bazlı Ambar Fişi İse--->
         	<cfquery name="get_relation_info" datasource="#dsn2#">
            		SELECT 
                    	SFR.AMOUNT, 
                        SFR.WRK_ROW_RELATION_ID, 
                        SFR.SPECT_VAR_ID, 
                        SFR.STOCK_ID, 
                        SFR.SHELF_NUMBER, 
                        SFR.FIS_ID, 
                        SFR.ROW_INTERNALDEMAND_ID,
                        S.PRODUCT_ID
					FROM     
                    	STOCK_FIS_ROW AS SFR INNER JOIN
                  		#dsn3_alias#.STOCKS AS S ON SFR.STOCK_ID = S.STOCK_ID
					WHERE  
                    	SFR.FIS_ID = #GET_ID.MAX_ID#
          	</cfquery>
			<cfif get_relation_info.recordcount>
            	<cfloop query="get_relation_info">
                	<cfquery name="add_ezgi_relation" datasource="#dsn2#">
                    	INSERT INTO 
                        	#dsn3_alias#.INTERNALDEMAND_RELATION_ROW
                  			(
                            	INTERNALDEMAND_ID, 
                                INTERNALDEMAND_ROW_ID, 
                                TO_STOCK_FIS_ID, 
                                PERIOD_ID, 
                                PRODUCT_ID, 
                                STOCK_ID, 
                                SPECT_VAR_ID, 
                                SHELF_NUMBER, 
                                AMOUNT
                         	)
						VALUES 
                        	(
                            	#attributes.e_internaldemand_id#,
                                <cfif len(get_relation_info.ROW_INTERNALDEMAND_ID)>#get_relation_info.ROW_INTERNALDEMAND_ID#<cfelse>NULL</cfif>,
                                #GET_ID.MAX_ID#,
                                #session.ep.period_id#,
                                #get_relation_info.PRODUCT_ID#,
                                #get_relation_info.STOCK_ID#,
                                <cfif len(get_relation_info.SPECT_VAR_ID)>#get_relation_info.SPECT_VAR_ID#<cfelse>NULL</cfif>,
                                <cfif len(get_relation_info.SHELF_NUMBER)>#get_relation_info.SHELF_NUMBER#<cfelse>NULL</cfif>,
                                #get_relation_info.AMOUNT#
                          	)
                    </cfquery>
                </cfloop>
            </cfif>
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
		<!---Palet İçin Raf Hareketi--->
		<cfif isdefined('attributes.ambarfis') and (attributes.ambarfis eq 10 or attributes.ambarfis eq 11 or attributes.ambarfis eq 12)><!---Palet-Depodan Rafa veya Palet-Raf Değiştir veya Palet-Raftan Depoya--->
        	<cfset palet_currentrow = 1>
            <cfloop list="#attributes.palet_action_id#" index="p">
                <cfset palet_stock_id = Listgetat(p,2,'-')>
                <cfif isdefined('attributes.ambarfis') and attributes.ambarfis eq 10>
                	<cfset palet_shelf = Listgetat(p,4,'-')>
                <cfelseif isdefined('attributes.ambarfis') and attributes.ambarfis eq 11>
                	<cfset palet_shelf = Listgetat(p,5,'-')>
                </cfif>
                <cfif len(palet_shelf) and len(palet_stock_id)>
                    <cfquery name="get_move_shelf_id" datasource="#dsn2#">
                        SELECT        
                            PRODUCT_PLACE_ID,
                            SHELF_TYPE
                        FROM            
                            #dsn3_alias#.PRODUCT_PLACE
                        WHERE        
                            SHELF_CODE = '#palet_shelf#'
                    </cfquery>
                </cfif>
                <cfif isdefined('attributes.palet_killer') or get_move_shelf_id.SHELF_TYPE eq 1>
                	<cfquery name="get_move_shelf_id" datasource="#dsn2#">
                    	UPDATE
                        	#dsn3_alias#.EZGI_PACKING
                     	SET
                        	STATUS = 0	
                      	WHERE
                        	PACKING_ID = #palet_stock_id#
                    </cfquery>
                </cfif>
                <cfif isdefined('get_move_shelf_id.PRODUCT_PLACE_ID') and get_move_shelf_id.recordcount and len(get_move_shelf_id.PRODUCT_PLACE_ID)>
                	<cfquery name="add_packing_action" datasource="#dsn2#">
                    	INSERT INTO 
                        	#dsn3_alias#.EZGI_PACKING_ACTION
                  			(
                            	PACKING_ID, 
                                STORE, 
                                STORE_LOCATION, 
                                SHELF_NUMBER, 
                                PROCESS_DATE, 
                                RECORD_IP, 
                                RECORD_EMP
                          	)
						VALUES 
                        	(
                            	#palet_stock_id#,
                                <cfif isdefined('attributes.DEPARTMENT_IN') and len(attributes.DEPARTMENT_IN)>#attributes.DEPARTMENT_IN#<cfelse>NULL</cfif>,
                                <cfif isdefined('attributes.LOCATION_IN') and len(attributes.LOCATION_IN)>#attributes.LOCATION_IN#<cfelse>NULL</cfif>,
                                #get_move_shelf_id.PRODUCT_PLACE_ID#,
                                #now()#,
                                '#cgi.remote_addr#',
                                #session.ep.userid#
                          	)
                    </cfquery>
                </cfif>
            </cfloop>
      	</cfif>
        <!---Palet İçin Raf Hareketi--->
        
        <!---Ambar Fişi İle BeraberPaket Kontrolün Tamamlanması--->
        <cfif isdefined('attributes.x_is_pda_control') and attributes.x_is_pda_control eq 1>
        	<cfinclude template="add_ambar_fis_shipping_control_include.cfm">
        </cfif>
        <!---Ambar Fişi İle BeraberPaket Kontrolün Tamamlanması--->
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
	<cfif session.ep.our_company_info.is_cost eq 1 and get_process_type.IS_COST eq 1> sirket maliyet takip ediliyorsa not js le yonlenioyr cunku cost_action locationda calismiyor 
        <cfscript>
            cost_action(action_type:3,action_id:GET_ID.MAX_ID,query_type:1);
        </cfscript>
        <script type="text/javascript">
            window.location.href="<cfoutput>#request.self#?fuseaction=pda.stock_welcome</cfoutput>";
        </script>
    <cfelse>
        <cfif isdefined('attributes.ambarfis') and attributes.ambarfis eq 1>
            <cflocation url="#request.self#?fuseaction=pda.form_add_ambar_fis_1" addtoken="No">
      	<cfelseif isdefined('attributes.ambarfis') and attributes.ambarfis eq 2>
        	<cfif isdefined('attributes.param')>
            	<cflocation url="#request.self#?fuseaction=pda.form_add_ambar_fis_2&param=2" addtoken="No">
            <cfelse>
        		<cflocation url="#request.self#?fuseaction=pda.form_add_ambar_fis_2" addtoken="No">
            </cfif>
      	<cfelseif isdefined('attributes.ambarfis') and attributes.ambarfis eq 3>
        	<cflocation url="#request.self#?fuseaction=pda.form_add_ambar_fis_3" addtoken="No">
       	<cfelseif isdefined('attributes.ambarfis') and attributes.ambarfis eq 4>
        	<cflocation url="#request.self#?fuseaction=pda.form_add_stock_fis" addtoken="No">
     	<cfelseif isdefined('attributes.ambarfis') and attributes.ambarfis eq 5>
        	<cflocation url="#request.self#?fuseaction=pda.form_add_stock_fis_loc" addtoken="No">
       	<cfelseif isdefined('attributes.ambarfis') and attributes.ambarfis eq 6>
        	<cflocation url="#request.self#?fuseaction=pda.form_shipping_ambar_fis&date1=#attributes.date1#&date2=#attributes.date2#&department_in_id=#attributes.dep_in#&department_out_id=#attributes.dep_out#&date1=#attributes.date1#&date2=#attributes.date2#&keyword=#attributes.keyword#&is_type=#attributes.is_type#&deliver_paper_no=#attributes.ref_no#&ship_id=#attributes.ship_id#" addtoken="No">
        <cfelseif isdefined('attributes.ambarfis') and attributes.ambarfis eq 10> <!---Palet-Depodan Rafa--->
        	<cflocation url="#request.self#?fuseaction=pda.add_ezgi_palet_from_store_to_shelf" addtoken="No">
   		<cfelseif isdefined('attributes.ambarfis') and attributes.ambarfis eq 11> <!---Palet-Raf Değiştir--->
        	<cflocation url="#request.self#?fuseaction=pda.add_ezgi_palet_from_shelf_to_shelf" addtoken="No">
      	<cfelseif isdefined('attributes.ambarfis') and attributes.ambarfis eq 12> <!---Palet-Raftan Depoya--->
        	<cflocation url="#request.self#?fuseaction=pda.add_ezgi_palet_from_shelf_to_store" addtoken="No">
      	<cfelseif isdefined('attributes.ambarfis') and attributes.ambarfis eq 13> <!---İç Talep Bazlı Ambar Fişi--->
        	<cflocation url="#request.self#?fuseaction=pda.add_ambar_fis_4" addtoken="No">
     	<cfelseif isdefined('attributes.ambarfis') and attributes.ambarfis eq 15> <!---Lot Bazlı Ambar Fişi--->
        	<cflocation url="#request.self#?fuseaction=pda.add_ambar_fis_5" addtoken="No">
       	<cfelseif isdefined('attributes.ambarfis') and attributes.ambarfis eq 16> <!---Sipariş Bazlı Ambar Fişi--->
        	<cflocation url="#request.self#?fuseaction=pda.add_ambar_fis_6&order_id=#attributes.order_id#">
      	<cfelseif isdefined('attributes.ambarfis') and attributes.ambarfis eq 14> <!---Kargo Eşleme--->

        <cfelse>
            <cflocation url="#request.self#?fuseaction=pda.form_add_ambar_fis" addtoken="No">
        </cfif>
    </cfif>
</cfif>
