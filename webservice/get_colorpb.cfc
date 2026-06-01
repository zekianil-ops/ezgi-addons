<cfcomponent>
<cfset dsn=application.systemParam.systemParam().dsn>
<cfset dsn3="#dsn#_1"><cffunction name="METODCALISTIR"  access="remote"  httpMethod="Post" returntype="any" returnFormat="json">
    	<cfargument name="ka">
    	<cfargument name="pw">
    	<cfargument name="metod">
		
        <cfif ka eq"ahmet" and pw eq "1234">
			<cfreturn get_color_(keyword='#arguments.keyword#')>
            <cfelse>
            <cfreturn "şifreHatalı">
        </cfif>
    </cffunction>

<cffunction name="get_color_" httpMethod="Post" returntype="any" returnFormat="json">
	<cfargument name="keyword" default="">
    <cfargument name="oby" default="1">
    <cfargument name="status" default="1">
    <cfargument name="startrow" default="1">
    <cfargument name="maxrows" default="100">
    <cfquery name="GET_COLOR" datasource="#DSN3#">
		WITH CTE1 AS 
        (
        SELECT        
        	*
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
<cfset ReturnArr=arraynew(1)>
<cfloop query="GET_COLOR">
	<cfset COLOR=structnew()>
    <cfset COLOR.COLOR_ID=COLOR_ID>
        <cfset COLOR.COLOR_NAME=COLOR_NAME>
        <cfscript>
        	arrayappend(ReturnArr,COLOR);
        </cfscript>
        
</cfloop>
<cfreturn replace(serializeJSON(ReturnArr),"//","")>
</cffunction>

  </cfcomponent>