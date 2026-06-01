<!---
    File: del_ezgi_iflow_production_order.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cflock name="#CREATEUUID()#" timeout="90">
	<cfquery name="del_vardiya_sales" datasource="#dsn3#">
		DELETE FROM 
        	EZGI_MASTER_ALT_PLAN
		WHERE 
        	MASTER_ALT_PLAN_ID = #master_alt_plan_id#
	</cfquery>
</cflock>
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_master_plan&event=upd&upd_id=#master_plan_id#" addtoken="no">
