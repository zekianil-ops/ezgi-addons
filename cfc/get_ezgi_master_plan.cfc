<cffunction name="get_ezgi_master_plan_" returntype="query">
    <cfargument name="keyword" default="">
	<cfargument name="record_emp_id" default="">
    <cfargument name="record_emp_name" default="">
    <cfargument name="record_date1" default="">
    <cfargument name="record_date2" default="">
    <cfargument name="date1" default="">
    <cfargument name="date2" default="">
    <cfargument name="oby" default="1">
    <cfargument name="process_stage" default="">
    <cfargument name="master_plan_status" default="1">
    <cfargument name="department_id" default="">
	<cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_default" datasource="#this.DSN3#">
            SELECT       
                POINT_METHOD,
                FABRIC_CAT,
                CONTROL_METHOD
            FROM            
                EZGI_MASTER_PLAN_DEFAULTS WITH (NOLOCK)
            WHERE        
                SHIFT_ID IN 
                            (
                                SELECT        
                                    SHIFT_ID
                                FROM            
                                    #this.dsn_alias#.SETUP_SHIFTS WITH (NOLOCK)
                                WHERE        
                                    DEPARTMENT_ID IN (#arguments.department_id#)
                            )
    </cfquery>
    <cfquery name="get_ezgi_master_plan" datasource="#this.DSN3#">
		WITH CTE1 AS 
        		(
                SELECT     	
                    MASTER_PLAN_ID, 
                    MASTER_PLAN_START_DATE,
                    MASTER_PLAN_FINISH_DATE, 
                    MASTER_PLAN_NAME, 
                    MASTER_PLAN_NUMBER, 
                    MASTER_PLAN_DETAIL, 
                    MASTER_PLAN_STATUS, 
                    MASTER_PLAN_STAGE,
                    MASTER_PLAN_PROCESS, 
                    BRANCH_ID, 
                    GROSSTOTAL, 
                    RECORD_EMP, 
                    RECORD_IP, 
                    RECORD_DATE,
                    MONEY,
                    IS_PROCESS,
                    ISNULL((
                                    SELECT     
                                        SUM(PLAN_POINT) PLAN_POINT
                                    FROM         
                                        EZGI_MASTER_ALT_PLAN WITH (NOLOCK)
                                    WHERE     
                                        MASTER_PLAN_ID = EZGI_MASTER_PLAN.MASTER_PLAN_ID
                    ),0) AS H_POINT,
                     <cfif get_default.point_method eq 1>
                        ISNULL((	
                                        SELECT     
                                            SUM(PO.QUANTITY) AS P_POINT
                                        FROM         
                                            EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) INNER JOIN
                                            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                                            EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) ON EMPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
                                            EZGI_MASTER_PLAN_SABLON AS EMAS WITH (NOLOCK) ON EMAP.PROCESS_ID = EMAS.PROCESS_ID
                                        WHERE     
                                            EMPR.MASTER_PLAN_ID = EZGI_MASTER_PLAN.MASTER_PLAN_ID AND 
                                            EMAS.SIRA = 1 AND 
                                         	PO.IS_STAGE = 2
                        ),0) AS G_POINT,
                        ISNULL((	
                                        SELECT     
                                            SUM(PO.QUANTITY) AS P_POINT
                                        FROM         
                                            EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) INNER JOIN
                                            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                                            EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) ON EMPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
                                            EZGI_MASTER_PLAN_SABLON AS EMAS WITH (NOLOCK) ON EMAP.PROCESS_ID = EMAS.PROCESS_ID
                                        WHERE     
                                            EMPR.MASTER_PLAN_ID = EZGI_MASTER_PLAN.MASTER_PLAN_ID AND 
                                            EMAS.SIRA = 1
                        ),0) AS T_POINT 
                    <cfelseif get_default.point_method eq 2>   
                        ISNULL(
                                (	
                                SELECT     
                                        SUM(PO.QUANTITY * ISNULL(CAST(PTIP.PROPERTY2 AS float),0)) AS P_POINT
                                    FROM         
                                        EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) INNER JOIN
                                        PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                                        EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) ON EMPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
                                        EZGI_MASTER_PLAN_SABLON AS EMAS WITH (NOLOCK) ON EMAP.PROCESS_ID = EMAS.PROCESS_ID LEFT OUTER JOIN
                                        PRODUCT_TREE_INFO_PLUS AS PTIP WITH (NOLOCK) ON PO.STOCK_ID = PTIP.STOCK_ID
                                    WHERE     
                                        EMPR.MASTER_PLAN_ID = EZGI_MASTER_PLAN.MASTER_PLAN_ID AND 
                                        EMAS.SIRA = 1 AND 
                                        PO.IS_STAGE = 2
                                ),0) AS G_POINT,
                        ISNULL(
                                (	
                                SELECT     
                                        SUM(PO.QUANTITY * ISNULL(CAST(PTIP.PROPERTY2 AS float),0)) AS P_POINT
                                    FROM         
                                        EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) INNER JOIN
                                        PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                                        EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) ON EMPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
                                        EZGI_MASTER_PLAN_SABLON AS EMAS WITH (NOLOCK) ON EMAP.PROCESS_ID = EMAS.PROCESS_ID LEFT OUTER JOIN
                                        PRODUCT_TREE_INFO_PLUS AS PTIP WITH (NOLOCK) ON PO.STOCK_ID = PTIP.STOCK_ID
                                    WHERE     
                                        EMPR.MASTER_PLAN_ID = EZGI_MASTER_PLAN.MASTER_PLAN_ID AND 
                                        EMAS.SIRA = 1
                        ),0) AS T_POINT
                    <cfelse>
                        0 AS G_POINT,
                        0 AS T_POINT
                    </cfif>
                FROM       	
                    EZGI_MASTER_PLAN WITH (NOLOCK)
                WHERE		
                    1=1
                    <cfif isDefined("arguments.keyword") and len(arguments.keyword)>
                        AND
                            (
                                <cfif len(arguments.keyword) gt 3>
                                    MASTER_PLAN_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                                <cfelse>
                                    MASTER_PLAN_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#">
                                </cfif> OR
                                <cfif len(arguments.keyword) gt 3>
                                    MASTER_PLAN_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                                <cfelse>
                                    MASTER_PLAN_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#%">
                                </cfif> OR
                                <cfif len(arguments.keyword) gt 3>
                                    MASTER_PLAN_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                                <cfelse>
                                    MASTER_PLAN_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#%">
                                </cfif>
                            )
                    </cfif>
                    <cfif len(arguments.date1)>
                        AND MASTER_PLAN_START_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.DATE1#">
                    </cfif>
                    <cfif len(arguments.date2)>
                        AND MASTER_PLAN_START_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.DATE2#">
                    </cfif>
                    <cfif isdate(arguments.record_date1) and not isdate(arguments.record_date2)>
                        AND RECORD_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.record_date1#">
                    <cfelseif isdate(arguments.record_date2) and not isdate(arguments.record_date)>
                        AND RECORD_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateadd("d",1,arguments.record_date2)#">
                    <cfelseif isdate(arguments.record_date1) and  isdate(arguments.record_date2)>
                        AND RECORD_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.record_date1#"> AND RECORD_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateadd("d",1,arguments.record_date2)#">
                    </cfif>
                    <cfif isdefined("arguments.record_emp_id") and len(arguments.record_emp_id) and isdefined("arguments.record_emp_name") and len(arguments.record_emp_name)>
                        AND RECORD_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.record_emp_id#">
                    </cfif>
                    <cfif isDefined("arguments.process_stage") and len(arguments.process_stage)>
                        AND MASTER_PLAN_STAGE =#arguments.process_stage#
                    </cfif>
                    <cfif isDefined("arguments.master_plan_status") and len(arguments.master_plan_status)>
                        AND MASTER_PLAN_PROCESS =#arguments.master_plan_status#
                    </cfif>
                    <cfif isdefined('arguments.department_id') AND len (arguments.department_id)>
                        AND MASTER_PLAN_CAT_ID IN 
                                                        (
                                                        SELECT        
                                                            SHIFT_ID
                                                        FROM            
                                                            #this.dsn_alias#.SETUP_SHIFTS
                                                        WHERE        
                                                            DEPARTMENT_ID IN (#arguments.department_id#)
                                                        )
                                
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
	<cfreturn get_ezgi_master_plan>
</cffunction>
