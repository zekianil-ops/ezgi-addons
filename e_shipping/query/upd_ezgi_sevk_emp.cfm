<cftransaction>
	<cfif attributes.is_type eq 1>
        <cfquery name="upd_row" datasource="#dsn3#">
            UPDATE       
                EZGI_SHIP_RESULT
            SET                
                SEVK_EMP = #attributes.sevk_emp_id#, 
                SEVK_DATE = #now()#
            WHERE        
                SHIP_RESULT_ID = #attributes.action_id#
        </cfquery>
	<cfelse>    
    	<cfquery name="upd_row" datasource="#dsn3#">
        	UPDATE       
                EZGI_SHIP_RESULT_INTERNALDEMAND
            SET                
                SEVK_EMP = #attributes.sevk_emp_id#, 
                SEVK_DATE = #now()#
            WHERE        
                SHIP_RESULT_INTERNALDEMAND_ID = #attributes.action_id#
    	</cfquery>
    </cfif>
</cftransaction>
<script language="javascript">
   window.close();
   wrk_opener_reload();
</script>
