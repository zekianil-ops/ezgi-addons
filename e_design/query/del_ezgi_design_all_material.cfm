<!---
    File: del_ezgi_design_all_material.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 	

<cfif attributes.type eq 1>
   	<cfquery name="del_all_material" datasource="#dsn3#">
     	DELETE FROM EZGI_DESIGN_ALL_MATERIAL WHERE DESIGN_PACKAGE_ROW_ID = #attributes.type_id#
 	</cfquery>
    <cflocation url="#request.self#?fuseaction=prod.popup_add_ezgi_design_all_material&design_main_row_id=#attributes.type_id#" addtoken="No">
<cfelse>
 	<cfquery name="del_all_material" datasource="#dsn3#">
     	DELETE FROM EZGI_DESIGN_ALL_MATERIAL WHERE DESIGN_MAIN_ROW_ID  = #attributes.type_id# AND DESIGN_PACKAGE_ROW_ID IS NULL
  	</cfquery>
    <cflocation url="#request.self#?fuseaction=prod.popup_add_ezgi_design_all_material&design_main_row_id=#attributes.type_id#" addtoken="No">
</cfif>