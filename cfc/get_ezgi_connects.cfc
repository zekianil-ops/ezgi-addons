<cffunction name="get_ezgi_connects_" returntype="query">
    <cfargument name="keyword" default="">
    <cfargument name="connect_stage" default="">
    <cfargument name="resource_id" default="">
    <cfargument name="sort_type" default="">
    <cfargument name="branch_id" default="">
    <cfargument name="member_cat_type" default="">
    <cfargument name="consumer_id" default="">
    <cfargument name="company_id" default="">
    <cfargument name="employee_id" default="">
    <cfargument name="project_id" default="">
    <cfargument name="project_head" default="">
    <cfargument name="member_name" default="">
    <cfargument name="member_type" default="">
    <cfargument name="record_emp_id" default="">
    <cfargument name="record_emp_name" default="">
    <cfargument name="start_date" default="">
    <cfargument name="finish_date" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_ezgi_connects" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (
        SELECT        
        	O.CONNECT_ID, 
            O.CONNECT_NUMBER,
			O.CONNECT_EMPLOYEE_ID, 
	    	O.CONNECT_HEAD, 
            O.CONNECT_DATE, 
            O.CONNECT_DETAIL, 
            O.CONNECT_STATUS, 
            O.CONNECT_STAGE,
            O.CONSUMER_ID, 
            O.COMPANY_ID, 
            O.PARTNER_ID, 
            O.REF_NO,
            O.RECORD_EMP,
            O.RECORD_DATE,
            O.RECORD_PAR,
            O.MEMBER_TYPE,
            O.PARTNER_COMPANY_ID,
            O.SALES_COMPANY_ID,
            O.BRANCH_ID,
            O.REVISION_NO,
            O.FINISHDATE,
			O.EMPLOYEE_ID,
            O.PROJECT_ID,
            O.RESOURCE_ID,
            ISNULL(O.GROSSTOTAL,0) GROSSTOTAL,
            ISNULL(O.NETTOTAL,0) NETTOTAL,
            ISNULL(O.TAXTOTAL,0) TAXTOTAL,
	    	ISNULL(O.OTHER_MONEY_VALUE,0) OTHER_MONEY_VALUE,
            OTHER_MONEY
		FROM            
        	EZGI_CONNECT AS O WITH (NOLOCK)
      	WHERE
        	CONNECT_STATUS = 1
            <cfif len(arguments.member_name)>
            	<cfif isdefined('arguments.company_id') and len(arguments.company_id)>
                    AND O.COMPANY_ID =#arguments.company_id#
                </cfif>
                <cfif isdefined('arguments.consumer_id') and len(arguments.consumer_id)>
                    AND O.CONSUMER_ID =#arguments.consumer_id# 
                </cfif>
				<cfif isdefined('arguments.employee_id') and len(arguments.employee_id)>
                    AND O.EMPLOYEE_ID =#arguments.employee_id# 
                </cfif>
           	</cfif>
            <cfif len(arguments.keyword)>
            	AND 
                (
                	O.CONNECT_NUMBER LIKE '%#arguments.keyword#%' OR
                    O.CONNECT_DETAIL LIKE '%#arguments.keyword#%' OR
                    O.CONNECT_HEAD LIKE '%#arguments.keyword#%' OR
                    O.CONNECT_TEL LIKE '%#arguments.keyword#%' OR
                    REPLACE(O.CONNECT_TEL,' ','') LIKE '%#arguments.keyword#%'
              	)
            </cfif>
            <cfif len(arguments.record_emp_name) and len(arguments.record_emp_id)>
            	AND O.CONNECT_EMPLOYEE_ID = #arguments.record_emp_id#
            </cfif>
            <cfif session.ep.ISBRANCHAUTHORIZATION eq 1>
            	AND O.BRANCH_ID IN 
                				(
                                SELECT        
                                	BRANCH_ID
								FROM   
                                	#dsn_alias#.EMPLOYEE_POSITION_BRANCHES WITH (NOLOCK)
								WHERE        
                                	POSITION_CODE = #session.ep.POSITION_CODE# AND 
                                    DEPARTMENT_ID IS NULL
                                
                                )
            </cfif>
            <cfif len(arguments.branch_id)>
            	AND O.BRANCH_ID = #arguments.branch_id#
            </cfif>
            <cfif len(arguments.connect_stage)>
            	AND CONNECT_STAGE IN (#arguments.connect_stage#)
            </cfif>
            <cfif len(arguments.resource_id)>
            	AND O.RESOURCE_ID IN (#arguments.resource_id#)
            </cfif>
            <cfif len(arguments.start_date)>
            	AND O.CONNECT_DATE >= #arguments.start_date#
            </cfif>
            <cfif len(arguments.finish_date)>
            	AND O.CONNECT_DATE <= #arguments.finish_date#
            </cfif>
            <cfif len(arguments.project_id) and len(arguments.project_head)>
            	<cfif arguments.project_id eq -1>
                	AND O.PROJECT_ID IS NULL
                <cfelse>
            		AND O.PROJECT_ID = #arguments.project_id#
                </cfif>
            </cfif>
    	),
           CTE2 AS (
				SELECT
					CTE1.*,
					ROW_NUMBER() OVER (	ORDER BY
										<cfif arguments.sort_type eq 2>
                                            CONNECT_NUMBER
                                        <cfelseif arguments.sort_type eq 3>
                                            RECORD_DATE DESC
                                        <cfelseif arguments.sort_type eq 4>
                                            CONNECT_DATE
                                        <cfelseif arguments.sort_type eq 5>
                                            CONNECT_DATE desc
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
	<cfreturn get_ezgi_connects>
</cffunction>
        	