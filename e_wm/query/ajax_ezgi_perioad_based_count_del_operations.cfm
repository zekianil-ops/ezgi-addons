<!---
    File: ajax_ezgi_perioad_based_count_del_operations.cfm
    Folder: Add_Ons\ezgi\e-wm\query
    Author: Ezgi Yazılım
    Date: 01/03/2025
    Description:
--->
<cftransaction>
	<cfquery name="del_count" datasource="#dsn3#">
     	UPDATE 
        	<cfif attributes.type eq 1>
            	EZGI_WM_COUNT_SERIAL_ROW
          	<cfelse>
            	EZGI_WM_COUNT_PACKING_ROW
            </cfif>
			SET            
            	IS_CONTROL = NULL, 
                CONTROL_DATE = NULL, 
                CONTROL_EMP = NULL
			WHERE  
            	WM_COUNT_ID = #attributes.count_id# AND 
                <cfif attributes.type eq 1>
                    WM_COUNT_SERIAL_ROW_ID = #attributes.row_id#
                <cfelse>
                    WM_COUNT_PACKING_ROW_ID  = #attributes.row_id#
                </cfif>
 	</cfquery>
</cftransaction>
