<!---
    File: add_ezgi_production_order_from_iflow_master.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfif Listlen(attributes.iid)> <!---Parti İş Emirlerine Ait Liste Var mı--->
	<cfquery name="get_virtual_p_order" datasource="#dsn3#"> <!---Parti İş Emirlerine Ait Liste Var mı--->
    	SELECT        
        	E.IFLOW_P_ORDER_ID,
            E.ORDER_ROW_ID,
            (SELECT ORDER_ID FROM ORDER_ROW WITH (NOLOCK) WHERE ORDER_ROW_ID = E.ORDER_ROW_ID) AS ORDER_ID,
            CASE
            	WHEN 
                	E.ACTION_TYPE = 1
                THEN
                	(
                    	SELECT 
                        	TOP (1) ED.PROJECT_ID
						FROM     
                        	EZGI_PRODUCTION_DEMAND_ROW AS EDR WITH (NOLOCK) INNER JOIN
                  			EZGI_PRODUCTION_DEMAND AS ED WITH (NOLOCK) ON EDR.EZGI_DEMAND_ID = ED.EZGI_DEMAND_ID
						WHERE  
                        	EDR.EZGI_DEMAND_ROW_ID = E.ACTION_ID
                    )
              	WHEN 
                	E.ACTION_TYPE = 2
              	THEN
                    (
                    	SELECT TOP (1) 
                        	O.PROJECT_ID
						FROM     
                        	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                  			ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID
						WHERE  
                        	ORR.ORDER_ROW_ID = E.ORDER_ROW_ID
                    )
              	ELSE
                	NULL
           	END AS PROJECT_ID,
            E.PRODUCT_TYPE, 
            E.STOCK_ID, 
            EIPOP.P_ORDER_START_DATE AS START_DATE, 
            EIPOP.P_ORDER_FINISH_DATE AS FINISH_DATE, 
            E.QUANTITY, 
            E.DETAIL, 
            E.LOT_NO, 
            S.PRODUCT_NAME,
            E.SPECT_MAIN_ID,
            (
            	SELECT        
                	TOP (1) SPECT_MAIN_NAME
				FROM     
                	SPECT_MAIN WITH (NOLOCK)
				WHERE        
                	SPECT_MAIN_ID = S.STOCK_ID AND 
                    SPECT_STATUS = 1
				ORDER BY 
                	STOCK_ID DESC
            ) AS SPECT_MAIN_NAME,
            (SELECT MAIN_UNIT FROM #dsn1_alias#.PRODUCT_UNIT WITH (NOLOCK) WHERE PRODUCT_UNIT_STATUS = 1 AND PRODUCT_ID = S.PRODUCT_ID AND IS_MAIN = 1) AS UNIT,
            (SELECT TOP (1) WS_ID FROM WORKSTATIONS_PRODUCTS WITH (NOLOCK) WHERE STOCK_ID = S.STOCK_ID) AS STATION_ID
		FROM            
        	EZGI_IFLOW_PRODUCTION_ORDERS AS E WITH (NOLOCK) INNER JOIN
          	STOCKS AS S WITH (NOLOCK) ON E.STOCK_ID = S.STOCK_ID INNER JOIN
            EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPOP WITH (NOLOCK) ON E.REL_P_ORDER_ID = EIPOP.P_ORDER_PARTI_ID
		WHERE        
        	E.MASTER_PLAN_ID = #attributes.iflow_master_plan_id# AND 
            E.IFLOW_P_ORDER_ID IN (#attributes.iid#) AND 
            ISNULL(S.IS_KARMA,0) = 0 AND <!---Karma Değilse--->
            E.PRODUCT_TYPE IN (2,3,4) 
      	UNION ALL
    	SELECT        
        	E.IFLOW_P_ORDER_ID, 
            E.ORDER_ROW_ID,
            (SELECT ORDER_ID FROM ORDER_ROW WITH (NOLOCK) WHERE ORDER_ROW_ID = E.ORDER_ROW_ID) AS ORDER_ID,
            CASE
            	WHEN 
                	E.ACTION_TYPE = 1
                THEN
                	(
                    	SELECT 
                        	TOP (1) ED.PROJECT_ID
						FROM     
                        	EZGI_PRODUCTION_DEMAND_ROW AS EDR WITH (NOLOCK) INNER JOIN
                  			EZGI_PRODUCTION_DEMAND AS ED WITH (NOLOCK) ON EDR.EZGI_DEMAND_ID = ED.EZGI_DEMAND_ID
						WHERE  
                        	EDR.EZGI_DEMAND_ROW_ID = E.ACTION_ID
                    )
              	WHEN 
                	E.ACTION_TYPE = 2
               	THEN
                    (
                    	SELECT TOP (1) 
                        	O.PROJECT_ID
						FROM     
                        	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                  			ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID
						WHERE  
                        	ORR.ORDER_ROW_ID = E.ORDER_ROW_ID
                    )
              	ELSE
                	NULL
           	END AS PROJECT_ID,
            E.PRODUCT_TYPE, 
            K.STOCK_ID, 
            EIPOP.P_ORDER_START_DATE AS START_DATE, 
            EIPOP.P_ORDER_FINISH_DATE AS FINISH_DATE, 
            K.PRODUCT_AMOUNT * E.QUANTITY AS QUANTITY, 
            E.DETAIL, 
            E.LOT_NO, 
            K.PRODUCT_NAME, 
          	K.SPEC_MAIN_ID SPECT_MAIN_ID,
            (
            	SELECT        
                	TOP (1) SPECT_MAIN_NAME
				FROM     
                	SPECT_MAIN WITH (NOLOCK)
				WHERE        
                	SPECT_MAIN_ID = K.SPEC_MAIN_ID AND 
                    SPECT_STATUS = 1
				ORDER BY 
                	STOCK_ID DESC
            ) AS SPECT_MAIN_NAME,
            (SELECT MAIN_UNIT FROM #dsn1_alias#.PRODUCT_UNIT WHERE PRODUCT_UNIT_STATUS = 1 AND PRODUCT_ID = K.PRODUCT_ID AND IS_MAIN = 1) AS UNIT,
            (SELECT TOP (1) WS_ID FROM WORKSTATIONS_PRODUCTS WHERE STOCK_ID = K.STOCK_ID) AS STATION_ID
		FROM      
        	EZGI_IFLOW_PRODUCTION_ORDERS AS E WITH (NOLOCK) INNER JOIN
          	STOCKS AS S WITH (NOLOCK) ON E.STOCK_ID = S.STOCK_ID INNER JOIN
         	#dsn1_alias#.KARMA_PRODUCTS AS K WITH (NOLOCK) ON S.PRODUCT_ID = K.KARMA_PRODUCT_ID INNER JOIN
        	STOCKS AS S1 WITH (NOLOCK) ON K.STOCK_ID = S1.STOCK_ID INNER JOIN
            EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPOP WITH (NOLOCK) ON E.REL_P_ORDER_ID = EIPOP.P_ORDER_PARTI_ID
		WHERE        
        	E.MASTER_PLAN_ID = #attributes.iflow_master_plan_id# AND 
            E.IFLOW_P_ORDER_ID IN (#attributes.iid#) AND 
            E.PRODUCT_TYPE = 2 AND 
            ISNULL(S.IS_KARMA,0) = 1 AND <!---Karma İse--->
            ISNULL(S1.IS_ADD_XML,0) = 0 <!---İş emri Oluşturma İşaretli Değilse--->
    </cfquery>
</cfif>

<cfset attributes.islem_id = -1>
<cfset attributes.is_collacted = 1>
<cfset attributes.is_manuel = 1>
<cfset attributes.IS_SELECT_SUB_PRODUCT = 1>
<cfset attributes.is_demand = 0>
<cfset attributes.PROCESS_STAGE = get_process_type.PROCESS_ROW_ID>
<cfset attributes.STAGE_INFO= ''>
<cfset attributes.record_num = get_virtual_p_order.recordcount>
<cfset _KEYWORD_ = 'Üretim Emri'>
<cfif get_virtual_p_order.recordcount><!--- Parti İş Emirleri Listesi Döndürülüyor ve Attribute Değişkenleri Tanımlanıyor--->
    <cfloop query="get_virtual_p_order">
        <cfset attributes.master_alt_plan_id = IFLOW_P_ORDER_ID>
        <cfset attributes.PROJECT_HEAD = ''>
		<cfset attributes.PROJECT_ID= PROJECT_ID>
        <cfset 'lot_no#currentrow#' = LOT_NO>
        <cfset 'attributes.demand_no#currentrow#' = ''>
        <cfset 'attributes.finish_date#currentrow#' = DateFormat(finish_date,dateformat_style)>
        <cfset 'attributes.finish_h#currentrow#' = TimeFormat(finish_date,'HH')>
        <cfset 'attributes.finish_m#currentrow#' = TimeFormat(finish_date,'MM')>>
        <cfset 'attributes.start_date#currentrow#' = DateFormat(start_date,dateformat_style)>
        <cfset 'attributes.start_h#currentrow#' = TimeFormat(start_date,'HH')>>
        <cfset 'attributes.start_m#currentrow#' = TimeFormat(start_date,'MM')>
        <cfset 'attributes.is_line_number#currentrow#' = 0>
        <cfset 'attributes.order_id#currentrow#' = ORDER_ID>
        <cfset 'attributes.order_row_id#currentrow#' = ORDER_ROW_ID>
        <cfset 'attributes.product_name#currentrow#' = PRODUCT_NAME>
        <cfset 'attributes.quantity#currentrow#' = QUANTITY>
        <cfset 'attributes.ROW_KONTROL#currentrow#' = 1>
        <cfset 'attributes.SPECT_MAIN_ID#currentrow#' = SPECT_MAIN_ID>
        <cfset 'attributes.SPECT_VAR_ID#currentrow#' = ''>
        <cfset 'attributes.SPECT_VAR_NAME#currentrow#' = SPECT_MAIN_NAME>
        <cfset 'attributes.STATION_ID_#currentrow#_0' = STATION_ID>
        <cfset 'attributes.STATION_NAME_#currentrow#' = ''>
        <cfset 'attributes.STOCK_ID#currentrow#' = STOCK_ID>
        <cfset 'attributes.UNIT#currentrow#' = UNIT>
        <cfset 'attributes.WRK_ROW_RELATION_ID#currentrow#' = ''>
    </cfloop>
    <cfinclude template="add_ezgi_production_order_all_sub.cfm"><!--- Workcube İş Emirleri Oluşuyor--->
</cfif>

<cfquery name="get_master_plan_process_info" datasource="#dsn3#">
	SELECT MASTER_PLAN_PROCESS FROM EZGI_IFLOW_MASTER_PLAN WITH (NOLOCK) WHERE MASTER_PLAN_ID = #attributes.iflow_master_plan_id#
</cfquery>
<cfquery name="upd_p_order" datasource="#dsn3#"> <!---Yeni Açılan Workcube İş Emirlerinin İş Emri No Önündeki - işareti Kaldırışıyor ve Stok Rezerve İşlemi Mater Plan Bilgisine Uyduruluyor--->
	UPDATE       
    	PRODUCTION_ORDERS
	SET                
    	P_ORDER_NO = RIGHT(PRODUCTION_ORDERS.P_ORDER_NO, LEN(PRODUCTION_ORDERS.P_ORDER_NO) - 1),
        IS_STOCK_RESERVED = #get_master_plan_process_info.MASTER_PLAN_PROCESS#
	FROM            
    	EZGI_IFLOW_PRODUCTION_ORDERS AS E INNER JOIN
     	PRODUCTION_ORDERS ON E.LOT_NO = PRODUCTION_ORDERS.LOT_NO
	WHERE        
    	E.IFLOW_P_ORDER_ID IN (#attributes.iid#) AND 
        LEFT(PRODUCTION_ORDERS.P_ORDER_NO, 1) = '-'
</cfquery>

<script type="text/javascript">
	alert('<cf_get_lang dictionary_id='653.Üretim Emirleri Başarıyla Oluşturulmuştur'>');
  	wrk_opener_reload();
 	window.close();
</script>