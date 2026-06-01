<!---
    File: upd_ezgi_image.cfm
    Folder: Add_Ons\ezgi\e_connect\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->    
<cfquery name="UPD_UNIT" datasource="#dsn3#">
	DELETE 
 		EZGI_CONNECT_ROW_IMAGES
	WHERE 
    	CONNECT_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.image_action_id#">
</cfquery>
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
