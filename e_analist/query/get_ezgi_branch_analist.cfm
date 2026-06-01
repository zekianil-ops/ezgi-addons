<cfquery name="get_analyst_branch" datasource="#dsn3#">
	SELECT        
    	*,
	(SELECT BRANCH_NAME FROM #dsn_alias#.BRANCH WHERE BRANCH_ID = EZGI_ANALYST_BRANCH.BRANCH_ID) as BRANCH_NAME
	FROM            
   		EZGI_ANALYST_BRANCH
	WHERE   
    	1=1
        <cfif len(attributes.branch_id)>
        	AND BRANCH_ID = #attributes.branch_id#
        </cfif>  
        <cfif len(attributes.analyst_status)>  
        	AND ISNULL(STATUS, 0) = #analyst_status#  
       	</cfif>
        <cfif len(attributes.year_value)>
        	AND YEAR_VALUE = #year_value#  
       	</cfif>
        <cfif len(attributes.month_value)>
        	AND MONTH_VALUE = #attributes.month_value# 
        </cfif>
        <cfif len(attributes.record_emp_name)>
        	AND EMPLOYEE_ID = #attributes.record_emp_id#
       	</cfif>
        <cfif len(attributes.keyword)>
        	AND (DETAIL LIKE N'%#attributes.keyword#%')
      	</cfif>
 	ORDER BY
	<cfif attributes.oby eq 2>
    		YEAR_VALUE,MONTH_VALUE,IS_BRANCH,BRANCH_NAME
        <CFELSE>
        	YEAR_VALUE DESC,MONTH_VALUE DESC,IS_BRANCH,BRANCH_NAME
        </cfif>
	
</cfquery>
