<cffunction name="get_ezgi_iflow_wastage_tracking_" returntype="query">
    <cfargument name="keyword" default="">
	<cfargument name="record_emp_id" default="">
    <cfargument name="record_emp_name" default="">
    <cfargument name="record_date1" default="">
    <cfargument name="record_date2" default="">
    <cfargument name="oby" default="1">
    <cfargument name="list_type" default="1">
    <cfargument name="process_stage" default="">
    <cfargument name="wastage_tracking_status" default="1">
    <cfargument name="shift_id" default="">
	<cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_ezgi_iflow_wastage_tracking" datasource="#this.DSN3#">
		WITH CTE1 AS 
        		(
                	SELECT 
                    	EW.PRODUCTION_WASTAGE_ID, 
                        EW.P_ORDER_ID, 
                        EW.P_OPERATION_ID, 
                        EW.STATION_ID, 
                        EW.EMPLOYEE_IDS, 
                        EW.WASTAGE_DATE, 
                        EW.DETAIL, 
                        EW.REASON_ID, 
                        EW.IS_DEMAND, 
                        EW.STATUS, 
                        EW.WASTAGE_NO, 
                  		EW.WASTAGE_STAGE, 
                        EW.TRACE_NO, 
                        EW.WASTAGE_AMOUNT, 
                        EW.PROJECT_ID, 
                        EW.RECORD_DATE, 
                        EW.RECORD_EMP, 
                        EW.RECORD_IP, 
                        EW.UPDATE_DATE, 
                        EW.UPDATE_EMP, 
                        EW.UPDATE_IP, 
                        POO.OPERATION_TYPE_ID, 
                  		PO.STOCK_ID,
                    	PO.P_ORDER_NO, 
                        PO.LOT_NO,
                        EIM.MASTER_PLAN_CAT_ID,
                        S.PRODUCT_NAME,
                        OTT.OPERATION_TYPE, 
                        EVT.LOST_REASON_NAME,
                        W.STATION_NAME
                        <cfif isDefined("arguments.list_type") and arguments.list_type eq 2>
                        	,
                            EWR.PRODUCTION_WASTAGE_ROW_ID, 
                            EWR.STOCK_ID RAW_STOCK_ID, 
                            EWR.MAIN_SPECT_ID AS RAW_MAIN_SPECT_ID, 
                            ISNULL(EWR.AMOUNT,0) AS RAW_AMOUNT, 
                            EWR.WRK_ROW_ID, 
                            EWR.POR_STOCK_ID,
                            S1.PRODUCT_NAME AS RAW_PRODUCT_NAME,
                            S1.PRODUCT_CODE AS RAW_PRODUCT_CODE,
                            PU.MAIN_UNIT AS RAW_MAIN_UNIT,
                            ISNULL((SELECT SUM(QUANTITY) AS QUANTITY FROM INTERNALDEMAND_ROW WITH (NOLOCK) WHERE WRK_ROW_RELATION_ID = EWR.WRK_ROW_ID),0) AS DEMAND_QUANTITY
                      	<cfelse>
                        	,ISNULL((SELECT SUM(QUANTITY) AS QUANTITY FROM EZGI_PRODUCTION_DEMAND_ROW WITH (NOLOCK) WHERE PRODUCTION_WASTAGE_ID = EW.PRODUCTION_WASTAGE_ID),0) AS PRODUCTION_DEMAND_QUANTITY
                        </cfif>
                        
					FROM     
                    	EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE AS EW WITH (NOLOCK) INNER JOIN
                  		PRODUCTION_OPERATION AS POO WITH (NOLOCK) ON EW.P_OPERATION_ID = POO.P_OPERATION_ID INNER JOIN
                  		PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EW.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                 		EZGI_IFLOW_PRODUCTION_ORDERS AS EIF WITH (NOLOCK) ON PO.LOT_NO = EIF.LOT_NO INNER JOIN
                  		EZGI_IFLOW_MASTER_PLAN AS EIM WITH (NOLOCK) ON EIF.MASTER_PLAN_ID = EIM.MASTER_PLAN_ID INNER JOIN
                  		STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID	INNER JOIN
                  		OPERATION_TYPES AS OTT WITH (NOLOCK) ON POO.OPERATION_TYPE_ID = OTT.OPERATION_TYPE_ID INNER JOIN
                  		EZGI_VTS_LOST_REASON AS EVT WITH (NOLOCK) ON EW.REASON_ID = EVT.LOST_REASON_ID INNER JOIN
                  		WORKSTATIONS AS W WITH (NOLOCK) ON EW.STATION_ID = W.STATION_ID
                        <cfif isDefined("arguments.list_type") and arguments.list_type eq 2>
                      		INNER JOIN EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE_ROW AS EWR WITH (NOLOCK) ON EWR.PRODUCTION_WASTAGE_ID = EW.PRODUCTION_WASTAGE_ID
                            INNER JOIN STOCKS AS S1 WITH (NOLOCK) ON EWR.STOCK_ID = S1.STOCK_ID 
                            INNER JOIN PRODUCT_UNIT AS PU WITH (NOLOCK) ON PU.PRODUCT_UNIT_ID = EWR.PRODUCT_UNIT_ID
                        </cfif>
                 	WHERE       
                        1=1
                        <cfif isDefined("arguments.keyword") and len(arguments.keyword)>
                            AND
                                (
                                    <cfif len(arguments.keyword) gt 3>
                                       S.PRODUCT_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                                    <cfelse>
                                       S.PRODUCT_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#">
                                    </cfif> OR
                                    <cfif len(arguments.keyword) gt 3>
                                        EVT.LOST_REASON_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                                    <cfelse>
                                        EVT.LOST_REASON_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#%">
                                    </cfif>
                                )
                        </cfif>
                        <cfif isdefined('arguments.wastage_tracking_status') and len(arguments.wastage_tracking_status)>
                            AND EW.STATUS = #arguments.wastage_tracking_status#
                        </cfif>
                        <cfif isDefined("arguments.paper_number") and len(arguments.paper_number)>
                            AND EW.WASTAGE_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.paper_number#%">
                        </cfif>
                        <cfif len(arguments.date1)>
                            AND EW.WASTAGE_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.DATE1#">
                        </cfif>
                        <cfif len(arguments.date2)>
                            AND EW.WASTAGE_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('d',1,arguments.DATE2)#">
                        </cfif>
                        <cfif isdefined("arguments.record_emp_id") and len(arguments.record_emp_id) and isdefined("arguments.record_emp_name") and len(arguments.record_emp_name)>
                            AND EW.RECORD_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.record_emp_id#">
                        </cfif>
                        <cfif isDefined("arguments.prod_order_stage") and len(arguments.prod_order_stage)>
                            AND EW.WASTAGE_STAGE =#arguments.prod_order_stage#
                        </cfif>
                        <cfif len(arguments.record_date1)>
                            AND EW.RECORD_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.record_date1#">
                        </cfif>
                        <cfif len(arguments.record_date2)>
                            AND EW.RECORD_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('d',1,arguments.record_date2)#">
                        </cfif>
                        <cfif isdefined('arguments.shift_id') and len(arguments.shift_id)>
                            AND EIM.MASTER_PLAN_CAT_ID = #arguments.shift_id#
                        </cfif>
                 	UNION ALL
                	SELECT 
                    	EW.PRODUCTION_WASTAGE_ID, 
                        EW.P_ORDER_ID, 
                        EW.P_OPERATION_ID, 
                        EW.STATION_ID, 
                        EW.EMPLOYEE_IDS, 
                        EW.WASTAGE_DATE, 
                        EW.DETAIL, 
                        EW.REASON_ID, 
                        EW.IS_DEMAND, 
                        EW.STATUS, 
                        EW.WASTAGE_NO, 
                  		EW.WASTAGE_STAGE, 
                        EW.TRACE_NO, 
                        EW.WASTAGE_AMOUNT, 
                        EW.PROJECT_ID, 
                        EW.RECORD_DATE, 
                        EW.RECORD_EMP, 
                        EW.RECORD_IP, 
                        EW.UPDATE_DATE, 
                        EW.UPDATE_EMP, 
                        EW.UPDATE_IP, 
                        POO.OPERATION_TYPE_ID, 
                  		PO.STOCK_ID,
                    	PO.P_ORDER_NO, 
                        PO.LOT_NO,
                        EM.MASTER_PLAN_CAT_ID,
                        S.PRODUCT_NAME,
                        OTT.OPERATION_TYPE, 
                        EVT.LOST_REASON_NAME,
                        W.STATION_NAME
                        <cfif isDefined("arguments.list_type") and arguments.list_type eq 2>
                        	,
                            EWR.PRODUCTION_WASTAGE_ROW_ID, 
                            EWR.STOCK_ID RAW_STOCK_ID, 
                            EWR.MAIN_SPECT_ID AS RAW_MAIN_SPECT_ID, 
                            ISNULL(EWR.AMOUNT,0) AS RAW_AMOUNT, 
                            EWR.WRK_ROW_ID, 
                            EWR.POR_STOCK_ID,
                            S1.PRODUCT_NAME AS RAW_PRODUCT_NAME,
                            S1.PRODUCT_CODE AS RAW_PRODUCT_CODE,
                            PU.MAIN_UNIT AS RAW_MAIN_UNIT,
                            ISNULL((SELECT SUM(QUANTITY) AS QUANTITY FROM INTERNALDEMAND_ROW WITH (NOLOCK) WHERE WRK_ROW_RELATION_ID = EWR.WRK_ROW_ID),0) AS DEMAND_QUANTITY
                      	<cfelse>
                        	,ISNULL((SELECT SUM(QUANTITY) AS QUANTITY FROM EZGI_PRODUCTION_DEMAND_ROW WITH (NOLOCK) WHERE PRODUCTION_WASTAGE_ID = EW.PRODUCTION_WASTAGE_ID),0) AS PRODUCTION_DEMAND_QUANTITY
                        </cfif>
                        
					FROM     
                   		EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE AS EW WITH (NOLOCK) INNER JOIN
                  		PRODUCTION_OPERATION AS POO WITH (NOLOCK) ON EW.P_OPERATION_ID = POO.P_OPERATION_ID INNER JOIN
                  		PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EW.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                  		STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID INNER JOIN
                  		OPERATION_TYPES AS OTT WITH (NOLOCK) ON POO.OPERATION_TYPE_ID = OTT.OPERATION_TYPE_ID INNER JOIN
                  		EZGI_VTS_LOST_REASON AS EVT WITH (NOLOCK) ON EW.REASON_ID = EVT.LOST_REASON_ID INNER JOIN
                  		WORKSTATIONS AS W WITH (NOLOCK) ON EW.STATION_ID = W.STATION_ID INNER JOIN
                  		EZGI_MASTER_PLAN_RELATIONS AS EMP WITH (NOLOCK) ON PO.P_ORDER_ID = EMP.P_ORDER_ID INNER JOIN
                  		EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) ON EMP.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
                  		EZGI_MASTER_PLAN AS EM WITH (NOLOCK) ON EMAP.MASTER_PLAN_ID = EM.MASTER_PLAN_ID
                        <cfif isDefined("arguments.list_type") and arguments.list_type eq 2>
                      		INNER JOIN EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE_ROW AS EWR WITH (NOLOCK) ON EWR.PRODUCTION_WASTAGE_ID = EW.PRODUCTION_WASTAGE_ID
                            INNER JOIN STOCKS AS S1 WITH (NOLOCK) ON EWR.STOCK_ID = S1.STOCK_ID 
                            INNER JOIN PRODUCT_UNIT AS PU WITH (NOLOCK) ON PU.PRODUCT_UNIT_ID = EWR.PRODUCT_UNIT_ID
                        </cfif>
                 	WHERE       
                        1=1
                        <cfif isDefined("arguments.keyword") and len(arguments.keyword)>
                            AND
                                (
                                    <cfif len(arguments.keyword) gt 3>
                                       S.PRODUCT_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                                    <cfelse>
                                       S.PRODUCT_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#">
                                    </cfif> OR
                                    <cfif len(arguments.keyword) gt 3>
                                        EVT.LOST_REASON_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                                    <cfelse>
                                        EVT.LOST_REASON_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#%">
                                    </cfif>
                                )
                        </cfif>
                        <cfif isdefined('arguments.wastage_tracking_status') and len(arguments.wastage_tracking_status)>
                            AND EW.STATUS = #arguments.wastage_tracking_status#
                        </cfif>
                        <cfif isDefined("arguments.paper_number") and len(arguments.paper_number)>
                            AND EW.WASTAGE_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.paper_number#%">
                        </cfif>
                        <cfif len(arguments.date1)>
                            AND EW.WASTAGE_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.DATE1#">
                        </cfif>
                        <cfif len(arguments.date2)>
                            AND EW.WASTAGE_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('d',1,arguments.DATE2)#">
                        </cfif>
                        <cfif isdefined("arguments.record_emp_id") and len(arguments.record_emp_id) and isdefined("arguments.record_emp_name") and len(arguments.record_emp_name)>
                            AND EW.RECORD_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.record_emp_id#">
                        </cfif>
                        <cfif isDefined("arguments.prod_order_stage") and len(arguments.prod_order_stage)>
                            AND EW.WASTAGE_STAGE =#arguments.prod_order_stage#
                        </cfif>
                        <cfif len(arguments.record_date1)>
                            AND EW.RECORD_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.record_date1#">
                        </cfif>
                        <cfif len(arguments.record_date2)>
                            AND EW.RECORD_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('d',1,arguments.record_date2)#">
                        </cfif>
                        <cfif isdefined('arguments.shift_id') and len(arguments.shift_id)>
                            AND EM.MASTER_PLAN_CAT_ID = #arguments.shift_id#
                        </cfif>
                ),
        CTE2 AS (
                    SELECT
                        CTE1.*,
                        ROW_NUMBER() OVER (
                                			ORDER BY 
											<cfif isDefined('arguments.oby') and arguments.oby eq 1>
                                                WASTAGE_DATE DESC
                                            <cfelse>
                                                WASTAGE_DATE 
                                            </cfif>
                                					
                                      		) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
                    FROM
                        CTE1
				)
      	SELECT
			CTE2.*
		FROM
			CTE2
		WHERE
			RowNum BETWEEN #startrow# and #startrow#+(#maxrows#-1)
	</cfquery>
	<cfreturn get_ezgi_iflow_wastage_tracking>
</cffunction>
