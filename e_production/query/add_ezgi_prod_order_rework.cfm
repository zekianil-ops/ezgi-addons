<!---
    File: add_ezgi_prod_order_rework.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/09/2025
    Description:
--->

<cfif isdefined('attributes.p_order_lot_list') and Listlen(attributes.p_order_lot_list) and len(attributes.master_alt_plan_id)>
	<cfquery name="get_master_plan_info" datasource="#dsn3#">
    	SELECT 
        	MASTER_PLAN_ID, 
            MASTER_ALT_PLAN_ID
		FROM     
        	EZGI_MASTER_ALT_PLAN
		WHERE  
        	MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id# AND 
            RELATED_MASTER_ALT_PLAN_ID IS NULL
		UNION ALL
		SELECT 
        	MASTER_PLAN_ID, 
            RELATED_MASTER_ALT_PLAN_ID
		FROM     
        	EZGI_MASTER_ALT_PLAN AS EZGI_MASTER_ALT_PLAN_1
		WHERE  
        	MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id# AND 
            RELATED_MASTER_ALT_PLAN_ID IS NOT NULL
    </cfquery>
	<cfquery name="get_sablon" datasource="#dsn3#">
    	SELECT DISTINCT 
        	EMAP.PROCESS_ID, 
            EMS.WORKSTATION_ID, 
            EMAP.MASTER_ALT_PLAN_ID
		FROM     
        	EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
            EZGI_MASTER_PLAN_SABLON AS EMS ON EMAP.PROCESS_ID = EMS.PROCESS_ID
		WHERE  
        	EMAP.MASTER_ALT_PLAN_ID = #get_master_plan_info.MASTER_ALT_PLAN_ID# OR EMAP.RELATED_MASTER_ALT_PLAN_ID = #get_master_plan_info.MASTER_ALT_PLAN_ID#
    </cfquery>
    <cfif get_sablon.recordcount>
        <cftransaction>
            <cfloop list="#attributes.p_order_lot_list#" index="i">
            	<cfquery name="get_p_orders" datasource="#dsn3#">
                	SELECT P_ORDER_ID,STATION_ID FROM PRODUCTION_ORDERS WHERE LOT_NO = '#i#' AND NOT (STATION_ID IS NULL)
                </cfquery>
                <cfif get_p_orders.recordcount>
                    <cfquery name="upd_p_order" datasource="#dsn3#">
                        UPDATE 
                            PRODUCTION_ORDERS
                        SET          
                            IS_STOCK_RESERVED =1, 
                            IS_GROUP_LOT =1, 
                            IS_STAGE =0
                        WHERE  
                            IS_STAGE = - 1 AND 
                            LOT_NO = '#i#'
                    </cfquery>
                    <cfquery name="upd_p_order" datasource="#dsn3#">
                        UPDATE 
                            PRODUCTION_ORDERS
                        SET          
                            P_ORDER_NO =RIGHT(P_ORDER_NO, LEN(P_ORDER_NO) - 1) 
                        WHERE  
                            LOT_NO = '#i#' AND
                            LEFT(P_ORDER_NO, 1) = '-'
                    </cfquery>
                    <cfif Left(i,1) eq '-'>
                        <cfquery name="upd_p_order" datasource="#dsn3#">
                            UPDATE 
                                PRODUCTION_ORDERS
                            SET          
                                LOT_NO =RIGHT(LOT_NO, LEN(LOT_NO) - 1) 
                            WHERE  
                                LOT_NO = '#i#'
                        </cfquery>
                    </cfif>
                    <cfloop query="get_p_orders">
                        <cfloop query="get_sablon">
                        	<cfif get_p_orders.STATION_ID eq get_sablon.WORKSTATION_ID>
                            	<cfquery name="ADD_MASTER_PLAN_RELATION" datasource="#dsn3#">
                                 	INSERT INTO   
                                    	EZGI_MASTER_PLAN_RELATIONS
                                      	(
                                            MASTER_ALT_PLAN_ID, 
                                            PROCESS, 
                                            P_ORDER_ID, 
                                            PROCESS_ID, 
                                            MASTER_PLAN_ID,
                                            STATION_ID
                                     	)
                                  	VALUES
                                      	(
                                            #get_sablon.MASTER_ALT_PLAN_ID#,
                                            'Üretim Planı',
                                            #get_p_orders.P_ORDER_ID#,
                                            #get_sablon.PROCESS_ID#,
                                            #get_master_plan_info.MASTER_PLAN_ID#,
                                            #get_p_orders.STATION_ID#
                                     	)       
                           		</cfquery>
                            </cfif>
                        </cfloop>
                    </cfloop>
                </cfif>
            </cfloop>
        </cftransaction>
	</cfif>
</cfif>
<cflocation url="#request.self#?fuseaction=prod.upd_ezgi_master_sub_plan_manual&master_plan_id=#get_master_plan_info.MASTER_PLAN_ID#&master_alt_plan_id=#attributes.master_alt_plan_id#&islem_id=#attributes.islem_id#" addtoken="No">