<!---
    File: add_ezgi_vts_identity.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfif isdefined('attributes.giris')>
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
    <cflocation url="#request.self#?fuseaction=production.list_ezgi_collect_production&main_menu=1&type=3" addtoken="No">
<cfelse>
    <cfquery name="get_identity" datasource="#dsn3#">
        SELECT PAROLA FROM EZGI_VTS_IDENTY WHERE PAROLA = '#attributes.pass#'
    </cfquery>
    <cfif get_identity.recordcount>
        <script type="text/javascript">
            alert("<cf_get_lang dictionary_id='33834.Yeni Eklenenler'>");
            window.history.go(-1);
        </script>
        <cfabort>
    </cfif>
    <cfquery name="add_vts_identity" datasource="#dsn3#">
        INSERT INTO 
            EZGI_VTS_IDENTY
            (
                PAROLA, 
                EMP_ID, 
                DEFAULT_DEPARTMENT_ID
            )
        VALUES        
            (
                '#attributes.pass#',
                #attributes.employee_id#,
                #attributes.department_id#
            )
    </cfquery>
    <cfquery name="get_max_id" datasource="#dsn3#">
        SELECT MAX(VTS_EMP_ID) AS MAX_ID FROM EZGI_VTS_IDENTY
    </cfquery>
    <cflocation url="#request.self#?fuseaction=production.upd_ezgi_vts_identity&id=#get_max_id.MAX_ID#" addtoken="No">
</cfif>