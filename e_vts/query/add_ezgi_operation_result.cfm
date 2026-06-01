<!---
    File: add_ezgi_operation_result.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfinclude template="add_ezgi_operation_result_control.cfm">
<cfquery name="ADD_RESULT" datasource="#dsn3#">
	INSERT INTO
	    PRODUCTION_OPERATION_RESULT
	(
		<cfif isdefined('attributes.operation_gurup_id') and len(attributes.operation_gurup_id)>
	    	OPERATION_GRUP_ID,
	    </cfif>
	    P_ORDER_ID,
	    OPERATION_ID,
	    STATION_ID,
	    REAL_AMOUNT,
	    LOSS_AMOUNT,
	    REAL_TIME,
	    WAIT_TIME,
	    RECORD_EMP,
	    RECORD_DATE,
	    RECORD_IP,
	    ACTION_EMPLOYEE_ID,
	    ACTION_START_DATE
	    <cfif isdefined('attributes.trace_no') and len(attributes.trace_no)>
	    	,TRACE_NO
		</cfif>
	)
	VALUES
	(
		<cfif isdefined('attributes.operation_gurup_id') and len(attributes.operation_gurup_id)>
	    	#attributes.operation_gurup_id#,
	    </cfif>
	    #attributes.upd_id#,
	    #attributes.operation_id_#,
	    #attributes.station_id_#,
	    <cfif isdefined('attributes.realized_amount_') and len(attributes.realized_amount_)>#attributes.realized_amount_#<cfelse>NULL</cfif>,
	    <cfif isdefined('attributes.loss_amount_') and len(attributes.loss_amount_)>#attributes.loss_amount_#<cfelse>NULL</cfif>,
	    <cfif isdefined('product_time_') and len(product_time_)>#product_time_#<cfelse>NULL</cfif>,
	    <cfif isdefined('attributes.duration_time_') and len(attributes.duration_time_)>#attributes.duration_time_#<cfelse>NULL</cfif>,
	    #SESSION.EP.USERID#,
	    #NOW()#,
	    '#CGI.REMOTE_ADDR#',
	    <cfif isdefined('attributes.employee_id_') and len(attributes.employee_id_)>#attributes.employee_id_#<cfelse>NULL</cfif>,
	    #NOW()#
	    <cfif isdefined('attributes.trace_no') and len(attributes.trace_no)>
	    	,'#attributes.trace_no#'
		</cfif>
	)
</cfquery>