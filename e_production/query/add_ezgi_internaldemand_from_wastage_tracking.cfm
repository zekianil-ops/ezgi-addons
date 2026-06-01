<!---
    File: add_ezgi_internaldemand_from_wastage_tracking.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/05/2023
    Description:
--->
<!---<cfdump var="#attributes#"><cfabort>--->
<cfset rows_ = 0>
<cfif isdefined('attributes.LIST_TYPE') and attributes.LIST_TYPE eq 1>
	<cfparam name="attributes.PROCESS_STAGE" default="87">
	<cfquery name="get_max_no" datasource="#dsn3#">
        SELECT ISNULL(max(DEMAND_NUMBER),10000) AS DEMAND_NUMBER FROM EZGI_PRODUCTION_DEMAND
    </cfquery>
    <cfset demand_no = get_max_no.DEMAND_NUMBER+1>
	<cfif ListLen(attributes.production_wastage_id_list)>
    	 <cfloop from="1" to="#Listlen(attributes.production_wastage_id_list)#" index="i">
         	<cfset WASTAGE_ID = ListgetAt(attributes.production_wastage_id_list,i)>
         	<cfif isdefined('attributes.conversion_product_#WASTAGE_ID#')>  
                <cfset rows_ = rows_+1> 
                <cfquery name="get_info" datasource="#dsn3#">
                    SELECT 
                        S.STOCK_ID, 
                        S.PRODUCT_ID, 
                        S.PRODUCT_NAME, 
                        PO.SPEC_MAIN_ID, 
                        E.WASTAGE_AMOUNT, 
                        E.TRACE_NO,
                        E.STATION_ID,
                        S.PRODUCT_UNIT_ID,
                        (SELECT TOP (1)E_PRODUCTION_TYPE FROM EZGI_DESIGN_STOCK_RELATED WHERE STOCK_ID = S.STOCK_ID) AS TYPE
                    FROM     
                        EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE AS E WITH (NOLOCK) INNER JOIN
                        PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON E.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                        STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID AND PO.STOCK_ID = S.STOCK_ID
                    WHERE  
                        E.PRODUCTION_WASTAGE_ID = #WASTAGE_ID#
            	</cfquery>
                <cfif get_info.recordcount>
                    <cfoutput query="get_info">
                        <cfset 'attributes.stock_id#rows_#'= get_info.STOCK_ID>
                        <cfset 'attributes.quantity#rows_#'= FilterNum(Evaluate('ROW_TOTAL_NEED_#WASTAGE_ID#'),2)>
                        <cfset 'attributes.ezgi_id#rows_#'= ''>
                        <cfset 'attributes.type#rows_#'= get_info.TYPE>
                        <cfset 'attributes.row_kontrol#rows_#'= 1>
                        <cfset 'attributes.wastage_id#rows_#'= WASTAGE_ID>
                    </cfoutput>
                </cfif>
          	</cfif>
        </cfloop>
        <cfquery name="GET_DEPARTMENT" datasource="#DSN3#">
            SELECT 
                DEPARTMENT,
                EXIT_DEP_ID,
                EXIT_LOC_ID
            FROM     
                WORKSTATIONS WITH (NOLOCK)
            WHERE  
                STATION_ID = #get_info.STATION_ID#
        </cfquery>
    	<CFSET attributes.demand_head = 'Fire Talebi'>
        <cfset attributes.date =Dateformat(now(),dateformat_style)>
    	<cfset attributes.termin =Dateformat(now(),dateformat_style)>
        <cfset attributes.detail ='Fire Talebine İstinaden'>
        <cfset attributes.order_employee = '#session.ep.NAME# #session.ep.SURNAME#'>
    	<cfset attributes.demand_employee = '#session.ep.NAME# #session.ep.SURNAME#'>
        <cfset attributes.order_employee_id = session.ep.userid>
    	<cfset attributes.demand_employee_id = session.ep.userid>
        <cfset attributes.department_id = GET_DEPARTMENT.DEPARTMENT>
    	<cfset attributes.project_id = ''>
        <cfset attributes.RECORD_NUM = rows_>
        <cfinclude template="../../e_planing/query/add_ezgi_production_demand.cfm">
    </cfif>
     <script type="text/javascript">
        alert("Üretim Talebi Oluşturulmuştur!");
        windowopen('<cfoutput>#request.self#?fuseaction=prod.list_ezgi_e_planning&event=upd&upd_id=#get_max_id.EZGI_DEMAND_ID#</cfoutput>','longpage');
        window.history.go(-1);
    </script>
<cfelse>
	<cfparam name="attributes.TO_POSITION_CODE" default="#session.ep.POSITION_CODE#">
	<cfif ListLen(attributes.production_wastage_row_id_list)>
        <cfquery name="GET_DEPARTMENT" datasource="#DSN3#">
            SELECT 
                W.DEPARTMENT,
                W.EXIT_DEP_ID,
                W.EXIT_LOC_ID
            FROM     
                EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE_ROW AS ER WITH (NOLOCK) INNER JOIN
                EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE AS E WITH (NOLOCK) ON ER.PRODUCTION_WASTAGE_ID = E.PRODUCTION_WASTAGE_ID INNER JOIN
                WORKSTATIONS AS W WITH (NOLOCK) ON E.STATION_ID = W.STATION_ID
            WHERE  
                ER.PRODUCTION_WASTAGE_ROW_ID = #ListGetAt(attributes.production_wastage_row_id_list,1)#
        </cfquery>
        <cfloop from="1" to="#Listlen(attributes.production_wastage_row_id_list)#" index="i">
            <cfset WASTAGE_ROW_ID = ListgetAt(attributes.production_wastage_row_id_list,i)>
            <cfif isdefined('attributes.conversion_product_#WASTAGE_ROW_ID#')>  
                <cfset rows_ = rows_+1>  
                <cfquery name="get_info" datasource="#dsn3#">
                    SELECT 
                        S.STOCK_ID, 
                        S.PRODUCT_ID, 
                        S.PRODUCT_NAME,
                        E.MAIN_SPECT_ID, 
                        E.AMOUNT, 
                        E.WRK_ROW_ID, 
                        E.PRODUCT_UNIT_ID, 
                        (SELECT MAIN_UNIT FROM PRODUCT_UNIT WHERE PRODUCT_UNIT_ID = E.PRODUCT_UNIT_ID) MAIN_UNIT,
                        E.POR_STOCK_ID
                    FROM     
                        EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE_ROW E WITH (NOLOCK),
                        STOCKS S WITH (NOLOCK)
                    WHERE  
                        E.PRODUCTION_WASTAGE_ROW_ID = #WASTAGE_ROW_ID# AND
                        E.STOCK_ID=S.STOCK_ID
                </cfquery>
                <cfif get_info.recordcount>
                    <cfoutput query="get_info">
                        <cfset 'attributes.product_id#rows_#'= get_info.PRODUCT_ID>
                        <cfset 'attributes.stock_id#rows_#'= get_info.STOCK_ID>
                        <cfset 'attributes.amount#rows_#'= FilterNum(Evaluate('ROW_TOTAL_NEED_#WASTAGE_ROW_ID#'),4)>
                        <cfset 'attributes.unit#rows_#'= get_info.MAIN_UNIT>
                        <cfset 'attributes.unit_id#rows_#'= get_info.PRODUCT_UNIT_ID>
                        <cfset 'attributes.product_name#rows_#'= get_info.PRODUCT_NAME>
                        <cfset 'attributes.wrk_row_relation_id#rows_#'= WRK_ROW_ID>
                        <cfset 'attributes.wrk_row_id#rows_#' = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')# & #session.ep.company_id# & #rows_#>
                    </cfoutput>
                </cfif>
            </cfif>
        </cfloop>
        <cfset attributes.rows_ = rows_>
        <cfset attributes.kur_say = 3>
        <cfset attributes.hidden_rd_money_1 = 'TL'>
        <cfset attributes.hidden_rd_money_2 = 'USD'>
        <cfset attributes.hidden_rd_money_3 = 'EUR'>
        <cfset attributes.basket_money = 'TL'>
        <cfset attributes.txt_rate2_1 = 1>
        <cfset attributes.txt_rate2_2 = 1>
        <cfset attributes.txt_rate2_3 = 1>
        
        <cfset attributes.txt_rate1_1 = 1>
        <cfset attributes.txt_rate1_2 = 1>
        <cfset attributes.txt_rate1_3 = 1>
        <cfset attributes.notes = ''>
        <cfset attributes.priority = 3>
        <cfset attributes.FROM_POSITION_CODE = session.ep.POSITION_CODE>
        <cfset attributes.from_position_name = '#session.ep.NAME# #session.ep.SURNAME#'>
        <cfset attributes.is_active = 1>
        <cfset attributes.target_date = Dateformat(now(),dateformat_style)>
        <cfset attributes.subject = 'Fire Talebi'>
        <cfset attributes.emp_department_id = GET_DEPARTMENT.DEPARTMENT>
        <cfset emp_department = 'Ezgi'>
        <cfset department_in_txt = 'Ezgi'>
        <cfset attributes.department_in_id = GET_DEPARTMENT.EXIT_DEP_ID>
        <cfset attributes.location_in_id = GET_DEPARTMENT.EXIT_LOC_ID>
        <cfset attributes.is_demand = 0>
        <cfset fusebox.circuit = 'purchase'> 
        <cfset attributes.webService = 1>
        <cfinclude template="/V16/correspondence/query/add_internaldemand.cfm">
    </cfif>
    <script type="text/javascript">
        alert("İç Talep Oluşturulmuştur!");
        windowopen('<cfoutput>#request.self#?fuseaction=#fusebox.circuit#.#page_type#&id=#internal_id_#</cfoutput>','longpage');
        window.history.go(-1);
    </script>
</cfif>