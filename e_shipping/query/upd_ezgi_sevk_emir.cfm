<cftransaction>
	<cfif attributes.is_type eq 1>
        <cfquery name="upd_row" datasource="#dsn3#">
            UPDATE       
                EZGI_SHIP_RESULT
            SET                
                IS_SEVK_EMIR = #attributes.sevk_emir#, 
                SEVK_EMIR_DATE = #now()#
            WHERE        
                SHIP_RESULT_ID = #attributes.upd_id#
        </cfquery>
  	<cfelse>
    	 <cfquery name="upd_row" datasource="#dsn3#">
		UPDATE       
                EZGI_SHIP_RESULT_INTERNALDEMAND
            SET                
                IS_SEVK_EMIR = #attributes.sevk_emir#, 
                SEVK_EMIR_DATE = #now()#
            WHERE        
                SHIP_RESULT_INTERNALDEMAND_ID = #attributes.upd_id#
        </cfquery>
    </cfif>
</cftransaction>
<script language="javascript">
   window.close();
</script>