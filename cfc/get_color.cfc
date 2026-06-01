<cffunction name="get_color_" returntype="query">
	<cfargument name="keyword" default="">
    <cfargument name="oby" default="">
    <cfargument name="status" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="GET_COLOR" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (
        SELECT        
		COLOR_ID, COLOR_NAME, RECORD_EMP, PROPERTY_DETAIL_CODE, RECORD_DATE, IS_ACTIVE, RELATED_STOCK_ID, PROP_CODE, ISNULL(IS_FLAG,0) AS IS_FLAG
		FROM            
        	EZGI_COLORS WITH (NOLOCK)
      	WHERE 
        	1=1
            <cfif isdefined('arguments.keyword') and len(arguments.keyword)>
            	AND 
                (
                	COLOR_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> OR
                    PROPERTY_DETAIL_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                )
            </cfif>
            <cfif status eq 2>
            	AND IS_ACTIVE = 1
            <cfelseif status eq 3>
            	AND ISNULL(IS_ACTIVE,0) = 0
            </cfif>
    	),
           CTE2 AS (
				SELECT
					CTE1.*,
					ROW_NUMBER() OVER (	ORDER BY
											<cfif oby eq 1>
                                                PROPERTY_DETAIL_CODE
                                            <cfelseif oby eq 2>
                                                COLOR_NAME
                                            <cfelse>
                                                COLOR_ID desc
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
	<cfreturn GET_COLOR>
</cffunction>
        	