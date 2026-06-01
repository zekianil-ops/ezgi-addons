<!---
    File: add_ezgi_operastion_time_cost.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/07/2022
    Description:
--->
<cfquery name="get_work_team" datasource="#DSN3#">
	SELECT 
    	EMPLOYEE_ID
	FROM     
    	EZGI_STATION_EMPLOYEE
	WHERE  
    	STATION_ID = #attributes.station_id_# AND 
        FINISH_DATE IS NULL
</cfquery>
<cfif get_work_team.recordcount>
    <cfloop query="get_work_team">
    	<cfset attributes.work_employee_id = get_work_team.EMPLOYEE_ID>	
        <cfinclude template="add_ezgi_operation_time_cost_include.cfm">
    </cfloop>
</cfif>