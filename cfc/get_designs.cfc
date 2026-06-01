<cffunction name="get_designs_" returntype="query">
	<cfargument name="keyword" default="">
    <cfargument name="oby" default="">
    <cfargument name="status" default="">
    <cfargument name="design_type" default="">
	<cfargument name="color_type" default="">
	<cfargument name="is_prototip" default="">
    <cfargument name="process_stage" default="">
    <cfargument name="category_name" default="">
	<cfargument name="cat" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_designs" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (
        SELECT  
        	*,
            ISNULL(IS_PROTOTIP,0) PROTOTIP
       	FROM 
        	EZGI_DESIGN WITH (NOLOCK)
      	WHERE 
        	ISNULL(IS_PRIVATE,0) = 0
            <cfif isdefined('arguments.keyword') and len(arguments.keyword)>
            	AND 
                (
                	DESIGN_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> OR
                    DESIGN_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                )
            </cfif>
            <cfif isdefined('arguments.process_stage') and len(arguments.process_stage)>
            	AND PROCESS_STAGE = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_stage#">
            </cfif>
            <cfif arguments.status eq 2>
            	AND STATUS = 1
            <cfelseif arguments.status eq 3>
            	AND STATUS = 0
            </cfif>
            <cfif arguments.is_prototip eq 2>
            	AND ISNULL(IS_PROTOTIP,0) = 0
            <cfelseif arguments.is_prototip eq 1>
            	AND ISNULL(IS_PROTOTIP,0) = 1
            </cfif>
            <cfif arguments.design_type gt 0>
            	AND PROCESS_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.design_type#">
            </cfif>	
            <cfif arguments.color_type gt 0>
            	AND COLOR_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.color_type#">
            </cfif>	
            <cfif isdefined('arguments.category_name') and len(arguments.category_name) and len(arguments.cat)>
            	AND PRODUCT_CAT_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cat#%">
          	</cfif>
    	),
           CTE2 AS (
				SELECT
					CTE1.*,
					ROW_NUMBER() OVER (	ORDER BY
										<cfif arguments.oby eq 1>
                                            PRODUCT_CAT
                                        <cfelseif arguments.oby eq 2>
                                            DESIGN_NAME
                                        <cfelse>
                                            DESIGN_ID desc
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
	<cfreturn get_designs>
</cffunction>
        	