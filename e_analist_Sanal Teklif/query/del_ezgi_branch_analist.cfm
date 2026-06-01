<cflock name="#CREATEUUID()#" timeout="90">
    <cftransaction>
        <cfquery name="del_analyst_branch" datasource="#dsn3#">
           DELETE EZGI_ANALYST_BRANCH WHERE ANALYST_BRANCH_ID = #attributes.upd#
        </cfquery>
        <cfquery name="del_analyst_branch_row" datasource="#dsn3#">
        	DELETE FROM EZGI_ANALYST_BRANCH_ROW WHERE EZGI_ANALYST_BRANCH_ID = #attributes.upd#
      	</cfquery>
        <cfquery name="del_analyst_branch_row" datasource="#dsn3#">
        	DELETE FROM EZGI_ANALYST_BRANCH_ROW WHERE EZGI_ANALYST_BRANCH_ID = #attributes.upd#
      	</cfquery>
    </cftransaction>
</cflock>
<cflocation url="#request.self#?fuseaction=report.list_ezgi_branch_analist" addtoken="no">