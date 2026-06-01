<!---
    File: del_ezgi_vts_identity.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="upd_vts_identity" datasource="#dsn3#">
	DELETE
    	EZGI_VTS_IDENTY
  	WHERE 
    	VTS_EMP_ID = #attributes.id#
</cfquery>
<cflocation url="#request.self#?fuseaction=production.add_ezgi_vts_identity" addtoken="No">