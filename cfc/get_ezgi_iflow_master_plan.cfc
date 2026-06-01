<cffunction name="get_ezgi_iflow_master_plan_" returntype="query">
    <cfargument name="keyword" default="">
	<cfargument name="record_emp_id" default="">
    <cfargument name="record_emp_name" default="">
    <cfargument name="record_date1" default="">
    <cfargument name="record_date2" default="">
    <cfargument name="oby" default="1">
    <cfargument name="process_stage" default="">
    <cfargument name="master_plan_status" default="1">
    <cfargument name="shift_id" default="">
	<cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_ezgi_iflow_master_plan" datasource="#this.DSN3#">
		WITH CTE1 AS 
        		(
                	SELECT     	
                        E.MASTER_PLAN_ID, 
                        E.MASTER_PLAN_START_DATE,
                        E.MASTER_PLAN_FINISH_DATE, 
                        E.MASTER_PLAN_NAME, 
                        E.MASTER_PLAN_NUMBER, 
                        E.MASTER_PLAN_DETAIL, 
                        E.MASTER_PLAN_STATUS, 
                        E.MASTER_PLAN_STAGE,
                        E.MASTER_PLAN_PROCESS, 
                        E.BRANCH_ID, 
                        E.GROSSTOTAL, 
                        E.RECORD_EMP, 
                        E.RECORD_IP, 
                        E.RECORD_DATE,
                        E.IS_PROCESS,
                        PTR.STAGE,
                        ISNULL(PRO.TOPLAM_PAKET,0) AS TOPLAM_PAKET,
                        ISNULL(PRO.BITEN_PAKET,0) AS BITEN_PAKET,
                        ISNULL(PRO_1.TOPLAM_MODUL,0) AS TOPLAM_MODUL,
                        ISNULL(PRO_2.BITEN_MODUL,0) AS BITEN_MODUL,
                        ISNULL(ALL_P_ORDER.TOPLAM_EMIR,0) AS TOPLAM_EMIR,
                        ISNULL(ALL_P_ORDER.BITEN_EMIR,0) AS BITEN_EMIR
                    FROM       	
                        EZGI_IFLOW_MASTER_PLAN E WITH (NOLOCK) INNER JOIN 
                        #this.DSN#.PROCESS_TYPE_ROWS AS PTR ON E.MASTER_PLAN_STAGE = PTR.PROCESS_ROW_ID LEFT JOIN
                        (
                            SELECT 
                            	SUM(ISNULL(PO.QUANTITY,0)) AS TOPLAM_EMIR, 
                                SUM(ISNULL(TBL_2.AMOUNT,0)) AS BITEN_EMIR, 
                                EP.MASTER_PLAN_ID
                            FROM 
                            	PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN 
                                EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) ON PO.LOT_NO = EP.LOT_NO INNER JOIN 
                                STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID LEFT JOIN 
                                (
                                	SELECT 
                                    	POR.P_ORDER_ID, 
                                        SUM(PORR.AMOUNT) AS AMOUNT
                                	FROM 
                                    	PRODUCTION_ORDER_RESULTS AS POR WITH (NOLOCK) INNER JOIN 
                                        PRODUCTION_ORDER_RESULTS_ROW AS PORR WITH (NOLOCK) ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
                                	WHERE 
                                    	POR.IS_STOCK_FIS = 1 AND 
                                        PORR.TYPE = 1
                                	GROUP BY 
                                    	POR.P_ORDER_ID
                            	) AS TBL_2 ON PO.P_ORDER_ID = TBL_2.P_ORDER_ID
                            GROUP BY 
                            	EP.MASTER_PLAN_ID
                        ) AS ALL_P_ORDER ON ALL_P_ORDER.MASTER_PLAN_ID = E.MASTER_PLAN_ID LEFT JOIN
                        (
                            SELECT 
                            	SUM(ISNULL(PO.QUANTITY,0)) AS TOPLAM_PAKET, 
                                SUM(ISNULL(TBL_2.AMOUNT,0)) AS BITEN_PAKET, 
                                EP.MASTER_PLAN_ID
                            FROM 
                            	PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN 
                                EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) ON PO.LOT_NO = EP.LOT_NO INNER JOIN 
                                STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID LEFT JOIN 
                                (
                                	SELECT 
                                    	POR.P_ORDER_ID, 
                                        SUM(PORR.AMOUNT) AS AMOUNT
                                	FROM 
                                    	PRODUCTION_ORDER_RESULTS AS POR WITH (NOLOCK) INNER JOIN 
                                        PRODUCTION_ORDER_RESULTS_ROW AS PORR WITH (NOLOCK) ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
                                	WHERE 
                                    	POR.IS_STOCK_FIS = 1 AND 
                                        PORR.TYPE = 1
                                	GROUP BY 
                                    	POR.P_ORDER_ID
                            	) AS TBL_2 ON PO.P_ORDER_ID = TBL_2.P_ORDER_ID
                            WHERE 
                            	S.PRODUCT_CATID = (SELECT DEFAULT_PACKAGE_CAT_ID FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK))
                            GROUP BY 
                            	EP.MASTER_PLAN_ID
                        ) AS PRO ON PRO.MASTER_PLAN_ID = E.MASTER_PLAN_ID LEFT JOIN
                        (
                            SELECT 
                            	SUM(ISNULL(QUANTITY,0)) AS TOPLAM_MODUL, 
                                MASTER_PLAN_ID
                            FROM 
                            	EZGI_IFLOW_PRODUCTION_ORDERS WITH (NOLOCK)
                            WHERE 
                            	PRODUCT_TYPE = 2
                            GROUP BY 
                            	MASTER_PLAN_ID
                        ) PRO_1 ON PRO_1.MASTER_PLAN_ID = E.MASTER_PLAN_ID OUTER APPLY
                        (
                            SELECT 
                            	SUM(ISNULL(AMOUNT,0)) AS BITEN_MODUL
                            FROM 
                            	(
                                	SELECT 
                                    	MIN(ISNULL(TBL_1.AMOUNT, 0)) AS AMOUNT
                                	FROM 
                                    	PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN 
                                        EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) ON PO.LOT_NO = EP.LOT_NO INNER JOIN 
                                        STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID LEFT JOIN 
                                        (
                                    		SELECT 
                                            	POR.P_ORDER_ID,
                                        		SUM(ISNULL(PORR.AMOUNT,0)) AS AMOUNT
                                    		FROM 
                                            	PRODUCTION_ORDER_RESULTS AS POR WITH (NOLOCK) INNER JOIN 
                                                PRODUCTION_ORDER_RESULTS_ROW AS PORR WITH (NOLOCK) ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
                                    		WHERE 
                                            	POR.IS_STOCK_FIS = 1 AND 
                                                PORR.TYPE = 1
                                    		GROUP BY 
                                            	POR.P_ORDER_ID
                                		) AS TBL_1 ON PO.P_ORDER_ID = TBL_1.P_ORDER_ID
                                	WHERE 
                                    	S.PRODUCT_CATID = 
                                        				(
                                    						SELECT 
                                                            	DEFAULT_PACKAGE_CAT_ID
                                    						FROM 
                                                            	EZGI_DESIGN_DEFAULTS AS EZGI_DESIGN_DEFAULTS_1 WITH (NOLOCK)
                                						) AND 
                                 		EP.MASTER_PLAN_ID = E.MASTER_PLAN_ID AND 
                                        EP.PRODUCT_TYPE = 2
                                	GROUP BY 
                                    	EP.LOT_NO
                            	) AS TBL2
                        ) AS PRO_2
                    WHERE		
                        1=1
                        <cfif isDefined("arguments.keyword") and len(arguments.keyword)>
                            AND
                                (
                                    <cfif len(arguments.keyword) gt 3>
                                        E.MASTER_PLAN_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                                    <cfelse>
                                        E.MASTER_PLAN_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#">
                                    </cfif> OR
                                    <cfif len(arguments.keyword) gt 3>
                                        E.MASTER_PLAN_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                                    <cfelse>
                                        E.MASTER_PLAN_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#%">
                                    </cfif> OR
                                    <cfif len(arguments.keyword) gt 3>
                                        E.MASTER_PLAN_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                                    <cfelse>
                                        E.MASTER_PLAN_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#%">
                                    </cfif>
                                )
                        </cfif>
                        <cfif isdefined('arguments.master_plan_status') and len(arguments.master_plan_status)>
                            AND E.MASTER_PLAN_STATUS = #arguments.master_plan_status#
                        </cfif>
                        <cfif isDefined("arguments.paper_number") and len(arguments.paper_number)>
                            AND E.MASTER_PLAN_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.paper_number#%">
                        </cfif>
                        <cfif len(arguments.date1)>
                            AND E.MASTER_PLAN_START_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.DATE1#">
                        </cfif>
                        <cfif len(arguments.date2)>
                            AND E.MASTER_PLAN_START_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.DATE2#">
                        </cfif>
                        <cfif isdefined("arguments.record_emp_id") and len(arguments.record_emp_id) and isdefined("arguments.record_emp_name") and len(arguments.record_emp_name)>
                            AND E.RECORD_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.record_emp_id#">
                        </cfif>
                        <cfif isDefined("arguments.prod_order_stage") and len(arguments.prod_order_stage)>
                            AND E.MASTER_PLAN_STAGE =#arguments.prod_order_stage#
                        </cfif>
                        <cfif len(arguments.record_date1)>
                            AND E.RECORD_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.record_date1#">
                        </cfif>
                        <cfif len(arguments.record_date2)>
                            AND E.RECORD_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.record_date2#">
                        </cfif>
                        <cfif isdefined('arguments.shift_id') and len(arguments.shift_id)>
                            AND E.MASTER_PLAN_CAT_ID = #arguments.shift_id#
                        </cfif>
                ),
        CTE2 AS (
                    SELECT
                        CTE1.*,
                        ROW_NUMBER() OVER (
                                			ORDER BY 
											<cfif isDefined('arguments.oby') and arguments.oby eq 1>
                                                MASTER_PLAN_START_DATE DESC
                                            <cfelse>
                                                MASTER_PLAN_START_DATE 
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
	<cfreturn get_ezgi_iflow_master_plan>
</cffunction>
