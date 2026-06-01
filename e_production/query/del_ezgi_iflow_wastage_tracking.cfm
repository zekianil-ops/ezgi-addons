<!---
    File: del_ezgi_iflow_wastage_tracking.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/05/2023
    Description:
--->
<cftransaction>
	<cfquery name="del_wastage_tracking" datasource="#dsn3#">
    	DELETE FROM EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE WHERE PRODUCTION_WASTAGE_ID = #attributes.wastage_tracking_id#
    </cfquery>
    <cfquery name="del_wastage_tracking_row" datasource="#dsn3#">
    	DELETE FROM EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE_ROW WHERE PRODUCTION_WASTAGE_ID = #attributes.wastage_tracking_id#
    </cfquery>
</cftransaction>
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_iflow_wastage_tracking" addtoken="No">