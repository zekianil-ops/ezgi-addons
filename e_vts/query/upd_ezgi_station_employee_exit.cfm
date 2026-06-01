<!---
    File: upd_ezgi_station_employee_exit.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfif isdefined('attributes.giris')><!---Toplu VTS den Geliyorsa--->
    <cfif isdefined('attributes.p_operation_id') and isdefined('attributes.station_id')>
    	<cfquery name="del_employee_station" datasource="#dsn3#">
            DELETE FROM         
                PRODUCTION_OPERATION_RESULT
            WHERE  
                <cfif isdefined('attributes.p_operation_id')>   
                    OPERATION_ID = #attributes.p_operation_id# AND 
                </cfif>
                STATION_ID = #attributes.station_id# AND 
                REAL_AMOUNT = 0 AND 
                ACTION_EMPLOYEE_ID = #attributes.id#
                <cfif isdefined('attributes.trace_no') and len(attributes.trace_no)>
                	AND TRACE_NO = '#attributes.trace_no#'
            	</cfif>
        </cfquery>
    	<cfquery name="get_operation_control" datasource="#dsn3#">
            SELECT * FROM PRODUCTION_OPERATION_RESULT WHERE OPERATION_ID = #attributes.p_operation_id#
        </cfquery>
        <cfif not get_operation_control.recordcount>
            <cfquery name="upd_operation" datasource="#dsn3#">
                UPDATE    
                    PRODUCTION_OPERATION
                SET              
                    STAGE =0
                WHERE     
                    P_OPERATION_ID = #attributes.p_operation_id#
            </cfquery>
        </cfif>
        <cflocation url="#request.self#?fuseaction=production.list_ezgi_collect_production&main_menu=1&type=1" addtoken="No">
    <cfelse>
    	<cfquery name="upd_station_employee" datasource="#dsn3#">
            UPDATE    
                EZGI_STATION_EMPLOYEE
            SET              
                FINISH_DATE = #now()#
            WHERE     
                EMPLOYEE_ID = #attributes.id# AND
                FINISH_DATE IS NULL
        </cfquery>
        <cflocation url="#request.self#?fuseaction=production.list_ezgi_collect_production&main_menu=1&type=4" addtoken="No">
    </cfif>
<cfelse><!--- E-VTS veya Personel Takipten geliyorsa--->
	<cfif isdefined('attributes.p_operation_id')>
        <cfquery name="del_employee_station" datasource="#dsn3#">
            DELETE FROM         
                PRODUCTION_OPERATION_RESULT
            WHERE  
                <cfif isdefined('attributes.p_operation_id')>   
                    OPERATION_ID = #attributes.p_operation_id# AND 
                </cfif>
                STATION_ID = #attributes.station_id# AND 
                REAL_AMOUNT = 0 AND 
                ACTION_EMPLOYEE_ID = #attributes.employee_id#
                <cfif isdefined('attributes.trace_no') and len(attributes.trace_no)>
                 	AND TRACE_NO = '#attributes.trace_no#'
            	</cfif>
        </cfquery>
        
        <cfquery name="get_operation_control" datasource="#dsn3#">
            SELECT * FROM PRODUCTION_OPERATION_RESULT WHERE OPERATION_ID = #attributes.p_operation_id#
        </cfquery>
        <cfif not get_operation_control.recordcount>
            <cfquery name="upd_operation" datasource="#dsn3#">
                UPDATE    
                    PRODUCTION_OPERATION
                SET              
                    STAGE =0
                WHERE     
                    P_OPERATION_ID = #attributes.p_operation_id#
            </cfquery>
        </cfif>
  	<cfelse>
    	<cfquery name="upd_station_employee" datasource="#dsn3#">
            UPDATE    
                EZGI_STATION_EMPLOYEE
            SET              
                FINISH_DATE = #now()#
            WHERE     
                EMPLOYEE_ID = #attributes.employee_id# AND
                FINISH_DATE IS NULL
        </cfquery>
    </cfif>
    <script type="text/javascript">
        <cfif isdefined('attributes.production')>
             window.location.href='<cfoutput>#request.self#?fuseaction=prod.popup_display_ezgi_prod_menu_moduler&is_form_submitted=1&master_plan_id=#attributes.master_plan_id#&department_id=#attributes.department_id#&durum=#attributes.durum#</cfoutput>';
        <cfelse>
            window.location.href='<cfoutput>#request.self#?fuseaction=production.list_ezgi_production_operation&is_form_submitted=1&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#</cfoutput>';
        </cfif>
    </script>
</cfif>