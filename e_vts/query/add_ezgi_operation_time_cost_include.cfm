<!---
    File: add_ezgi_operastion_time_cost_include.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/07/2022
    Description:
--->
<cfquery name="add_ezgi_operation_time_cost" datasource="#dsn3#">
	INSERT INTO 
	    EZGI_OPERATION_TIME_COST
	    (
	        TIME_COST_TYPE, 
	        TIME_COST_DATE, 
	        TIME_COST_FINISH_DATE, 
	        TIME_COST_START_DATE,
	        TIME_COST_MINUTE, 
	        OPERATION_RESULT_ID, 
	        EMPLOYEE_ID, 
	        STATION_ID, 
	        STATUS, 
	        OVERTIME_TYPE,
	        RECORD_EMP, 
	        RECORD_DATE, 
	        RECORD_IP
	    )
	VALUES 
	    (
	        1,
	        #now()#,
            <cfif isdefined('attributes.end_date')><!---Operasyon Güncelleme Sayfasından Geliyorsa--->
            	#attributes.end_date#,
			<cfelse>
				#now()#,
            </cfif>
            <cfif isdefined('attributes.action_date')><!---Operasyon Güncelleme Sayfasından Geliyorsa--->
            	#attributes.action_date#,
			<cfelse>
				'#get_result_id.ACTION_START_DATE#',
            </cfif>
	        <cfif isdefined('attributes.real_time_')><!---Operasyon Güncelleme Sayfasından Geliyorsa--->
            	#Filternum(attributes.real_time_,4)#,
			<cfelse>
				<cfif len(get_result_id.ACTION_START_DATE)>#DateDiff('s',get_result_id.ACTION_START_DATE,now())#<cfelse>NULL</cfif>,
            </cfif>
	        #attributes.result_id#,
	        #attributes.work_employee_id#,
	        #attributes.station_id_#,
	        0,
	        0,
	        #session.ep.userid#,
	        #now()#,
	        '#CGI.REMOTE_ADDR#'
	    )
</cfquery>