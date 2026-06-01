<cffunction name="get_operation_time_" returntype="query">
    <cfargument name="keyword" default="">
    <cfargument name="report_sort" default="">
    <cfargument name="operation_type_id" default="">
    <cfargument name="is_active" default="1">
    <cfargument name="is_save" default="">
	<cfargument name="startrow" default="">
    <cfargument name="maxrows" default="#session.ep.maxrows#">
    <cfquery name="get_operation_time" datasource="#this.DSN3#">
		WITH CTE1 AS 
        		(
                	SELECT     
                        PT.STOCK_ID, 
                        PT.OPERATION_TYPE_ID, 
                        S.STOCK_CODE, 
                        S.PRODUCT_NAME, 
                        OT.OPERATION_TYPE, 
                        OT.OPERATION_CODE, 
                        ISNULL(EOOT.OPTIMUM_TIME,0) AS OPTIMUM_TIME, 
                        EOOT.RECORD_EMP, 
                        ISNULL(EOOT.STATUS, 1) AS STATUS, 
                        ISNULL(EOOT.EZGI_OPERATION_OPTIMUM_TIME_ID,0) AS EZGI_OPERATION_OPTIMUM_TIME_ID
                    FROM        
                        PRODUCT_TREE AS PT WITH (NOLOCK) INNER JOIN
                        STOCKS AS S WITH (NOLOCK) ON PT.STOCK_ID = S.STOCK_ID INNER JOIN
                        OPERATION_TYPES AS OT WITH (NOLOCK) ON PT.OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID LEFT OUTER JOIN
                        EZGI_OPERATION_OPTIMUM_TIME AS EOOT WITH (NOLOCK) ON PT.OPERATION_TYPE_ID = EOOT.OPERATION_TYPE_ID AND PT.STOCK_ID = EOOT.STOCK_ID
                    WHERE     
                        PT.OPERATION_TYPE_ID IS NOT NULL AND 
                        PT.STOCK_ID <> 0 AND 
                        S.PRODUCT_STATUS = 1 AND 
                        S.IS_PRODUCTION = 1
                        <cfif len(arguments.keyword)>
                        AND (
                            S.STOCK_CODE LIKE '%#arguments.keyword#%' OR 
                            S.PRODUCT_NAME LIKE '%#arguments.keyword#%' OR
                            OT.OPERATION_TYPE LIKE '%#arguments.keyword#%'
                            )
                        </cfif>
                        <cfif len(arguments.is_active)>
                            AND ISNULL(EOOT.STATUS, 1) = #arguments.is_active#
                        </cfif>
                        <cfif len(arguments.is_save)>
                        	<cfif arguments.is_save eq 1>
                            	AND EOOT.OPTIMUM_TIME IS NOT NULL
                          	<cfelse>
                            	AND EOOT.OPTIMUM_TIME IS NULL
                            </cfif>
                        </cfif>
                        <cfif len(arguments.operation_type_id)>
                            AND PT.OPERATION_TYPE_ID = #arguments.operation_type_id#
                        </cfif>
                ),
        CTE2 AS (
                    SELECT
                        CTE1.*,
                        ROW_NUMBER() OVER (
                                			ORDER BY 
											<cfif arguments.report_sort eq 1 and arguments.report_sort eq ''>
                                                PRODUCT_NAME,OPERATION_TYPE
                                            <cfelse>
                                                OPERATION_TYPE,PRODUCT_NAME
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
	<cfreturn get_operation_time>
</cffunction>
