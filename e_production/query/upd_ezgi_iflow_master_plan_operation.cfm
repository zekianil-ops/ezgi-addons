<!---
    File: upd_ezgi_iflow_master_plan_operation.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset kapasite_kullanim_orani = 0>
<cfset makine_sayisi = 0>
<cfset biggest_time_day = 0>
<cfparam name="attributes.is_form_submitted" default="1">
<cfparam name="attributes.sort_type" default="10">
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_DEFAULTS
</cfquery>
<cfquery name="get_calc_department" datasource="#dsn3#">
	SELECT        
    	S.DEPARTMENT_ID
	FROM 
    	#dsn_alias#.SETUP_SHIFTS AS S WITH (NOLOCK) INNER JOIN
   		EZGI_IFLOW_MASTER_PLAN AS E WITH (NOLOCK) ON S.SHIFT_ID = E.MASTER_PLAN_CAT_ID
	WHERE        
    	E.MASTER_PLAN_ID = #attributes.master_plan_id#
</cfquery>
<cfparam name="attributes.department_id" default="#get_calc_department.DEPARTMENT_ID#">
<cfif get_defaults.recordcount>
	<cfquery name="get_plan_info" datasource="#dsn3#">
    	SELECT MASTER_PLAN_CAT_ID, GROSSTOTAL,MASTER_PLAN_START_DATE FROM EZGI_IFLOW_MASTER_PLAN WHERE MASTER_PLAN_ID = #attributes.master_plan_id#
    </cfquery>
    <cfset ara_stok = get_plan_info.GROSSTOTAL>
    <cfset attributes.shift_id = get_plan_info.MASTER_PLAN_CAT_ID>
	<cfset toplam_operator_sayisi = get_defaults.DEFAULT_ACTIVE_OPERATOR_AMOUNT>
	<cfset gunluk_caliasma_saat = get_defaults.DEFAULT_DAILY_WORKING_TIME>
    <cfinclude template="../../e_design/query/hsp_ezgi_total_working_day.cfm">
	<cfquery name="get_operations" datasource="#dsn3#">
    	SELECT        
        	OPERATION_TYPE_ID, 
            OPERATION_TYPE, 
            OPERATION_CODE
		FROM            
        	OPERATION_TYPES WITH (NOLOCK)
		WHERE        
        	IS_VIRTUAL = 0 AND 
            OPERATION_STATUS = 1 AND 
            OPERATION_TYPE_ID IN
                             	(
                                	SELECT        
                                    	OPERATION_TYPE_ID
                               		FROM            
                                    	WORKSTATIONS_PRODUCTS WITH (NOLOCK)
                               		WHERE        
                                    	WS_ID IN
                                            	(
                                                	SELECT        
                                                		STATION_ID
                                                  	FROM            
                                                    	WORKSTATIONS WITH (NOLOCK)
                                                 	WHERE        
                                                    	DEPARTMENT = #attributes.department_id# AND 
                                                        ACTIVE = 1 AND
                                                 		OPERATION_TYPE_ID IS NOT NULL
                                            	)
       							)
		ORDER BY 
        	OPERATION_CODE
    </cfquery>
    <cfquery name="GET_EMPLOYEE_NUMBER" datasource="#DSN3#">
        SELECT        
            OPERATION_TYPE_ID, 
            COUNT(*) AS SAYI,
            ISNULL((
            		SELECT        
                    	EZGI_KATSAYI
					FROM            
                    	WORKSTATIONS WITH (NOLOCK)
					WHERE        
                    	STATION_ID =
                             		(
                                    	SELECT        
                                        	TOP (1) WS_ID
                               			FROM            
                                        	WORKSTATIONS_PRODUCTS AS WP WITH (NOLOCK)
                               			WHERE        
                                        	OPERATION_TYPE_ID = WA.OPERATION_TYPE_ID AND 
                                            DEFAULT_STATUS = 1
                               			ORDER BY 
                                        	WS_ID
                                	)
            ),1) AS KATSAYI 
        FROM            
            WORKSTATIONS_PRODUCTS WA WITH (NOLOCK)
        GROUP BY 
            OPERATION_TYPE_ID
        HAVING        
            OPERATION_TYPE_ID IS NOT NULL
    </cfquery>
    <cfoutput query="GET_EMPLOYEE_NUMBER">
		<cfset 'SAYI_#OPERATION_TYPE_ID#' = SAYI>
        <cfset 'KATSAYI_#OPERATION_TYPE_ID#' = KATSAYI>
        <cfif KATSAYI gt 0 AND SAYI gt 0>
        	<cfset kapasite_kullanim_orani = kapasite_kullanim_orani + (KATSAYI * SAYI)>
    		<cfset makine_sayisi = makine_sayisi + SAYI>
        </cfif>
    </cfoutput> 
    <cfinclude template="get_ezgi_iflow_production_order.cfm">
    <cfif get_production_orders.recordcount>
		<cfoutput query="get_production_orders">
            <cfif PRODUCT_TYPE eq 1>
                <cfset attributes.design_id = RELATED_ID>
            <cfelseif PRODUCT_TYPE eq 2>
                <cfset attributes.design_main_row_id = RELATED_ID>
            <cfelseif PRODUCT_TYPE eq 3>
                <cfset attributes.design_package_row_id = RELATED_ID>
            <cfelseif PRODUCT_TYPE eq 4>
                <cfset attributes.design_piece_row_id = RELATED_ID>
            </cfif>
            <cfset attributes.product_quantity = get_production_orders.QUANTITY>
            <cfinclude template="../../e_design/query/get_ezgi_product_tree_creative_station_time.cfm">
            <cfif station_time_cal_group.recordcount>
                <cfloop query="station_time_cal_group">
                    <cfset 'TOTAL_STATION_TIME_#get_production_orders.PRODUCT_TYPE#_#get_production_orders.IFLOW_P_ORDER_ID#_#station_time_cal_group.STATION_ID#' = station_time_cal_group.TOTAL_STATION_TIME * get_production_orders.QUANTITY>
                </cfloop>
            </cfif>
        </cfoutput>
    </cfif>
	<cfset arama_yapilmali = 0>
<cfelse>
	<cfset get_operations.recordcount = 0>
	<cfset get_production_orders.recordcount = 0>
    <cfset arama_yapilmali = 1>
</cfif>
<cfif get_production_orders.recordcount>
	<cftransaction>
			<cfset total_row = get_production_orders.recordcount>
            <cfoutput query="get_production_orders">
                <cfif get_production_orders.is_stage eq 0 or get_production_orders.is_stage eq 4 or get_production_orders.is_stage eq 1 or get_production_orders.is_stage eq 2>
                	<cfquery name="del_production_operation" datasource="#dsn3#"> <!---Operasyonlar Siliniyor--->
                        DELETE FROM EZGI_IFLOW_PRODUCTION_OPERATION WHERE IFLOW_P_ORDER_ID = #get_production_orders.iflow_p_order_id#
                    </cfquery>
                    <cfloop query="get_operations">
                        <cfif isdefined('TOTAL_STATION_TIME_#get_production_orders.PRODUCT_TYPE#_#get_production_orders.IFLOW_P_ORDER_ID#_#get_operations.OPERATION_TYPE_ID#') and Evaluate('TOTAL_STATION_TIME_#get_production_orders.PRODUCT_TYPE#_#get_production_orders.IFLOW_P_ORDER_ID#_#get_operations.OPERATION_TYPE_ID#') gt 0>
                            <cfquery name="add_production_operation" datasource="#dsn3#"> <!---Operasyonlar Ekleniyor--->
                                INSERT INTO 
                                    EZGI_IFLOW_PRODUCTION_OPERATION
                                    (
                                        IFLOW_P_ORDER_ID, 
                                        AMOUNT, 
                                        OPERATION_TYPE_ID, 
                                        O_MAKINA_SAYISI, 
                                        O_KATSAYI, 
                                        O_TOTAL_PROCESS_TIME,
                                        RECORD_EMP, 
                                        RECORD_DATE, 
                                        RECORD_IP 
                                    )
                                VALUES        
                                    (
                                        #get_production_orders.iflow_p_order_id#,
                                        #get_production_orders.QUANTITY#,
                                        #get_operations.operation_type_id#,
                                        #Evaluate('SAYI_#get_operations.OPERATION_TYPE_ID#')#,
                                        #Evaluate('KATSAYI_#get_operations.OPERATION_TYPE_ID#')#,
                                        #Round(Evaluate('TOTAL_STATION_TIME_#get_production_orders.PRODUCT_TYPE#_#get_production_orders.IFLOW_P_ORDER_ID#_#get_operations.OPERATION_TYPE_ID#'))#,
                                        #session.ep.userid#,
                                        #now()#,
                                        '#cgi.remote_addr#'
                                    )
                            </cfquery>
                        </cfif>
                    </cfloop>
                    <!---<cfquery name="upd_production_orders" datasource="#dsn3#"> <!---Planlandı Yapılıyor--->
                        UPDATE EZGI_IFLOW_PRODUCTION_ORDERS SET IS_STAGE = 0 WHERE  IFLOW_P_ORDER_ID = #get_production_orders.iflow_p_order_id# AND IS_STAGE = 4
                    </cfquery>--->
                </cfif>
            </cfoutput>
            <cfquery name="get_p_order_" datasource="#dsn3#"> <!---Sıralama Alınıyor--->
            	SELECT        
                	IFLOW_P_ORDER_ID, DP_ORDER_ID
				FROM            
                	EZGI_IFLOW_PRODUCTION_ORDERS WITH (NOLOCK)
            </cfquery>
            <cfquery name="get_p_orders" dbtype="query">
            	SELECT * FROM get_p_order_ ORDER BY DP_ORDER_ID
            </cfquery>
            <cfoutput query="get_p_orders">
            	<cfset 'IFLOW_P_ORDER_ID_#currentrow#' = IFLOW_P_ORDER_ID>
            </cfoutput>
            <cfset sayi = get_p_orders.recordcount>
            <cfloop from="1" to="#sayi#" index="i"><!---Sıralama Yapılıyor--->
            	<cfquery name="upd_production_order_dp_order" datasource="#dsn3#">
                	UPDATE EZGI_IFLOW_PRODUCTION_ORDERS SET DP_ORDER_ID = #i# WHERE IFLOW_P_ORDER_ID = #Evaluate('IFLOW_P_ORDER_ID_#i#')#
                </cfquery>
            </cfloop>
            <cfinclude template="upd_ezgi_iflow_production_order_time.cfm">
  	</cftransaction>
</cfif>
