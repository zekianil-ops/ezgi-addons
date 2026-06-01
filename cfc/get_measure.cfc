<cffunction name="get_measure_" returntype="query">
	<cfargument name="keyword" default="">
    <cfargument name="oby" default="">
    <cfargument name="status" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="GET_measure" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (
        SELECT        
        	*
		FROM            
        	EZGI_VIRTUAL_OFFER_ROW_MEASURE WITH (NOLOCK)
      	WHERE 
        	1=1
            <cfif isdefined('arguments.keyword') and len(arguments.keyword)>
            	AND 
                (
                	MEASURE_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> 
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
                                                MEASURE_CODE
                                            <cfelseif oby eq 2>
                                                MEASURE_NAME
                                            <cfelse>
                                                MEASURE_ID desc
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
	<cfreturn GET_measure>
</cffunction>
        	