<!---
    File: upd_ezgi_iflow_wastage_tracking.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/05/2023
    Description:
--->
<cfquery name="upd_wastage" datasource="#dsn3#">
	UPDATE   
    	EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE
	SET           
    	DETAIL = '#attributes.detail#', 
        REASON_ID = #attributes.reason_id#, 
        STATUS = <cfif isdefined('attributes.status')>1<cfelse>0</cfif>, 
        WASTAGE_STAGE = #attributes.process_stage#, 
        UPDATE_DATE = #now()#, 
        UPDATE_EMP = #session.ep.userid#,
        UPDATE_IP = '#CGI.REMOTE_ADDR#'
	WHERE     
    	PRODUCTION_WASTAGE_ID = #attributes.wastage_tracking_id#
</cfquery>
<script type="text/javascript">
	window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_iflow_wastage_tracking&event=upd&wastage_tracking_id=#attributes.wastage_tracking_id#</cfoutput>";
</script>
