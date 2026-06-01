<!---
    File: hsp_ezgi_iflow_production_order_master.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/11/2024
    Description:
--->

<cfset attributes.iflow_master_plan_id = attributes.master_plan_id>
<cfquery name="GET_MASTER_PLAN_INFO" datasource="#DSN3#">
 	SELECT MASTER_PLAN_PROCESS, MASTER_PLAN_CAT_ID FROM EZGI_IFLOW_MASTER_PLAN WHERE MASTER_PLAN_ID = #attributes.master_plan_id#
</cfquery>
<cfinclude template="upd_ezgi_iflow_production_parti_operations.cfm">
<script type="text/javascript">
 	alert("Sıralama Yeniden Hesaplama İşlemi Tamamlanmıştır.!");
	window.opener.location.reload()
	window.close();
</script>