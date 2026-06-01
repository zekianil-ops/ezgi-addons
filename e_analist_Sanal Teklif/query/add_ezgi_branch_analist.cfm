<cf_date tarih = "attributes.start_date">
<cflock name="#CREATEUUID()#" timeout="90">
    <cftransaction>
        <cfquery name="add_analyst_branch" datasource="#dsn3#">
            INSERT INTO 
                EZGI_ANALYST_BRANCH
                (
                    YEAR_VALUE, 
                    MONTH_VALUE, 
                    EMPLOYEE_ID, 
                    DATE, 
                    RATE, 
                    DETAIL, 
                    IS_BRANCH, 
                    PROCESS_STAGE, 
                    BRANCH_ID, 
                    STATUS, 
                    RECORD_EMP, 
                    RECORD_DATE, 
                    RECORD_IP
                )
            VALUES        
                (
                    #attributes.year_value#,
                    #attributes.month_value#,
                    <cfif len(attributes.record_employee_id)>#attributes.record_employee_id#<cfelse>NULL</cfif>,
                    #attributes.start_date#,
                    #FilterNum(attributes.rate,2)#,
                    <cfif len(attributes.detail)>'#left(attributes.detail,500)#'<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.is_branch') and len(attributes.is_branch)>#attributes.is_branch#</cfif>,
                    #attributes.process_stage#,
                    #attributes.branch_id#,
                    0,
                    #session.ep.userid#,
                    #now()#,
                    '#cgi.remote_addr#'
                )
        </cfquery>
        <cfquery name="GET_MAX" datasource="#dsn3#">
        	SELECT 	MAX(ANALYST_BRANCH_ID) AS MAX_ID FROM EZGI_ANALYST_BRANCH
     	</cfquery>
    </cftransaction>
</cflock>
<cflocation url="#request.self#?fuseaction=report.list_ezgi_branch_analist&event=upd&upd_id=#get_max.max_id#" addtoken="no">