<cffunction name="get_piece_" returntype="query">
	<cfargument name="keyword" default="">
    <cfargument name="oby" default="">
    <cfargument name="status" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="GET_piece" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (
        SELECT        
        	*
		FROM            
        	EZGI_DESIGN_PIECE_DEFAULTS WITH (NOLOCK)
      	WHERE  
        	1=1
            <cfif isdefined('arguments.keyword') and len(arguments.keyword)>
            	AND 
                (
                	PIECE_DEFAULT_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> OR
                    PIECE_DEFAULT_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                )
            </cfif>
            <cfif status eq 2>
            	AND STATUS = 1
            <cfelseif status eq 3>
            	AND ISNULL(STATUS,0) = 0
            </cfif>
    	),
           CTE2 AS (
				SELECT
					CTE1.*,
					ROW_NUMBER() OVER (	ORDER BY
											<cfif oby eq 1>
                                                PIECE_DEFAULT_CODE
                                            <cfelseif oby eq 2>
                                                PIECE_DEFAULT_NAME
                                            <cfelse>
                                                PIECE_DEFAULT_ID desc
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
	<cfreturn GET_piece>
</cffunction>
        	