<!---
    File: add_ezgi_station_employee.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---<cfdump expand="yes" var="#attributes#">
<cfabort>--->
<cfif isdefined('add_employee')>
	<cfquery name="get_station_employee_control" datasource="#dsn3#">
    	SELECT     
        	STATION_ID, 
            EMPLOYEE_ID, 
            START_DATE
		FROM         
        	EZGI_STATION_EMPLOYEE
		WHERE     
        	FINISH_DATE IS NULL AND 
            EMPLOYEE_ID = #attributes.employee_id#
    </cfquery>
    <cfif get_station_employee_control.recordcount>
    	
    <cfelse>
        <cfquery name="add_station_employee" datasource="#dsn3#">
            INSERT INTO 
                EZGI_STATION_EMPLOYEE
                (
                EMPLOYEE_ID,
                STATION_ID,
                START_DATE
                )
            VALUES     
                (
                #attributes.employee_id#,
                #attributes.station_id#,
                #now()#
                )
        </cfquery>
  	</cfif>
<cfelseif isdefined('upd_employee')>
	<cfquery name="get_station_employee" datasource="#dsn3#">
        SELECT     
            TOP (1) STATION_EMPLOYEE_ID
        FROM         
            EZGI_STATION_EMPLOYEE
        WHERE     
            EMPLOYEE_ID = #attributes.employee_id# AND
            STATION_ID = #attributes.station_id# AND
            FINISH_DATE IS NULL
        ORDER BY 
            START_DATE desc
    </cfquery>
    <cfif get_station_employee.recordcount>
        <cfquery name="upd_station_employee" datasource="#dsn3#">
            UPDATE    
                EZGI_STATION_EMPLOYEE
            SET              
                FINISH_DATE = #now()#
            WHERE     
                STATION_EMPLOYEE_ID = #get_station_employee.STATION_EMPLOYEE_ID#
        </cfquery>
   	</cfif>
    <script type="text/javascript">
		window.location.href='<cfoutput>#request.self#?fuseaction=production.employee_ezgi_identification_1</cfoutput>';
	</script>
</cfif>