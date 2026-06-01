<cflock name="#CREATEUUID()#" timeout="90">
    <cftransaction>
        <cfquery name="add_analyst_branch" datasource="#dsn3#">
           DELETE
                EZGI_ANALYST_BRANCH
         	WHERE
            	ANALYST_BRANCH_ID = #attributes.upd#
        </cfquery>
    </cftransaction>
</cflock>
<cflocation url="#request.self#?fuseaction=report.list_ezgi_branch_analist" addtoken="no">