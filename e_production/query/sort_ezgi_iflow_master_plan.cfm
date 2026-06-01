<!---
    File: sort_ezgi_iflow_master_plan.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description:
--->
<cfquery name="GET_MASTER_PLAN_INFO" datasource="#dsn3#">
	SELECT 
    	EPO.MASTER_PLAN_ID, 
        EMP.MASTER_PLAN_CAT_ID
	FROM     
    	EZGI_IFLOW_PRODUCTION_ORDERS AS EPO INNER JOIN
        EZGI_IFLOW_MASTER_PLAN AS EMP ON EPO.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID
	WHERE  
    	EPO.IFLOW_P_ORDER_ID = #ornek_iflow_p_order_id#
</cfquery>
<cfif GET_MASTER_PLAN_INFO.recordcount and len(GET_MASTER_PLAN_INFO.MASTER_PLAN_ID)>
	<cfset attributes.iflow_master_plan_id = GET_MASTER_PLAN_INFO.MASTER_PLAN_ID>
	<cfinclude template="upd_ezgi_iflow_production_parti_operations.cfm">
<cfelse>
	<cfdump var="#GET_MASTER_PLAN_INFO#"><cfabort>
</cfif>