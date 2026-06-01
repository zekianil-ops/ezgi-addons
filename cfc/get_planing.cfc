<cffunction name="get_planing_" returntype="query">
	<cfargument name="planer_employee" default="">
    <cfargument name="planer_employee_id" default="">
    <cfargument name="department_id" default="">
    <cfargument name="listing_type" default="3">
    <cfargument name="sort_type" default="2">
	<cfargument name="keyword" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_planing" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (
        
        SELECT     
        	D.EZGI_DEMAND_ID, 
            D.DEMAND_HEAD, 
            D.PROCESS_STAGE, 
            D.DEMAND_DATE, 
            D.DEMAND_DELIVER_DATE, 
            D.RECORD_EMP, 
            D.DEMAND_NUMBER, 
           	D.DEMAND_DETAIL,
            D.DEMAND_EMP,
            D.DEMAND_DEPARTMENT_ID
		FROM         
        	EZGI_PRODUCTION_DEMAND AS D LEFT OUTER JOIN
         	(
            	SELECT 
                	EDR.EZGI_DEMAND_ID, 
                    SUM(ISNULL(EDR.QUANTITY, 0) - ISNULL(EPO.QUANTITY, 0)) AS KALAN
				FROM     
                	EZGI_PRODUCTION_DEMAND_ROW AS EDR WITH (NOLOCK) LEFT OUTER JOIN
                    (
                    	SELECT 
                        	ACTION_ID, 
                            SUM(QUANTITY) AS QUANTITY
                       	FROM      
                        	EZGI_IFLOW_PRODUCTION_ORDERS WITH (NOLOCK)
                       	GROUP BY 
                        	ACTION_ID
                  	) AS EPO ON EDR.EZGI_DEMAND_ROW_ID = EPO.ACTION_ID
				GROUP BY 
                	EDR.EZGI_DEMAND_ID
				HAVING 
                	SUM(ISNULL(EDR.QUANTITY, 0) - ISNULL(EPO.QUANTITY, 0)) > 0
            
            	<!---SELECT        
                	EDR.EZGI_DEMAND_ID, 
                    SUM(EDR.QUANTITY - ISNULL(EPO.QUANTITY, 0)) AS KALAN
              	FROM    
                	EZGI_PRODUCTION_DEMAND_ROW AS EDR LEFT OUTER JOIN
                	EZGI_IFLOW_PRODUCTION_ORDERS AS EPO ON EDR.EZGI_DEMAND_ROW_ID = EPO.ACTION_ID
            	WHERE        
                	EDR.QUANTITY - ISNULL(EPO.QUANTITY, 0) > 0
             	GROUP BY 
                	EDR.EZGI_DEMAND_ID--->
          	) AS TBL ON D.EZGI_DEMAND_ID = TBL.EZGI_DEMAND_ID LEFT OUTER JOIN
       		EZGI_PRODUCTION_DEMAND_ROW AS DR WITH (NOLOCK) ON D.EZGI_DEMAND_ID = DR.EZGI_DEMAND_ID
       	WHERE
        	1=1
            <cfif len(arguments.planer_employee)>
             	AND D.DEMAND_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.planer_employee_id#">
          	</cfif>
            <cfif len(arguments.department_id)>
             	AND D.DEMAND_DEPARTMENT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.department_id#">
          	</cfif>
            <cfif arguments.listing_type eq 3>
            	AND ISNULL(TBL.KALAN, 0) > 0
           	<cfelseif arguments.listing_type eq 2>
            	AND ISNULL(TBL.KALAN, 0) = 0
            </cfif>
            <cfif isdefined('arguments.keyword') and len(arguments.keyword)>
            	AND
                	(
                    	D.DEMAND_HEAD LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> OR
                        D.DEMAND_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                    )
            </cfif>
		GROUP BY 
        	D.EZGI_DEMAND_ID, 
            D.DEMAND_HEAD, 
            D.PROCESS_STAGE, 
            D.DEMAND_DATE, 
            D.DEMAND_DELIVER_DATE, 
            D.RECORD_EMP, 
            D.DEMAND_NUMBER, 
           	D.DEMAND_DETAIL,
            D.DEMAND_EMP,
            D.DEMAND_DEPARTMENT_ID
    	),
           CTE2 AS (
				SELECT
					CTE1.*,
					ROW_NUMBER() OVER (	ORDER BY
											<cfif arguments.sort_type eq 2>
                                                DEMAND_NUMBER desc
                                            <cfelse>
                                                DEMAND_NUMBER
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
	<cfreturn get_planing>
</cffunction>     	