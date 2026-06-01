<!---
    File: upd_ezgi_iflow_production_order_result.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfset employee_id_list = ''>
<cfset default_process_type = 171>
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT TOP (1)    
    	SPC.PROCESS_CAT_ID
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE = #default_process_type# AND 
        SPCF.FUSE_NAME = 'prod.popup_add_ezgi_iflow_production_order_result' 
  	ORDER BY
    	SPC.PROCESS_CAT_ID DESC      
</cfquery>
<cfif not get_process_cat.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='333.İşlem Kategorisi Tanımlayınız!'>");
		history.back();	
	</script>
<cfelse>
	<cfset attributes.process_cat = get_process_cat.PROCESS_CAT_ID>
</cfif>
<cfif not len(attributes.process_stage)>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='647.Süreç Tanımlarınız Eksiktir'>!");
		window.history.go(-1);
	</script>
    <cfabort>
</cfif>
<cftransaction>
    <cf_date tarih="attributes.action_date">
    <cfset attributes.action_date = Dateadd('h',attributes.action_date_h,attributes.action_date)>
    <cfset attributes.action_date = Dateadd('n',attributes.action_date_m,attributes.action_date)>
    <cfset attributes.action_date = Dateadd('h',-1*session.ep.time_zone,attributes.action_date)>
    <cfset attributes.finish_date = Dateadd('h',-1*session.ep.time_zone,attributes.action_date)>
    
    <cf_date tarih="attributes.end_date">
    <cfset attributes.end_date = Dateadd('h',attributes.end_date_h,attributes.end_date)>
    <cfset attributes.end_date = Dateadd('n',attributes.end_date_m,attributes.end_date)>
    <cfset attributes.end_date = Dateadd('h',-1*session.ep.time_zone,attributes.end_date)>
    <cfset attributes.finish_date = Dateadd('h',-1*session.ep.time_zone,attributes.end_date)>
    <cfquery name="upd_operation_result" datasource="#dsn3#">
    	UPDATE 
        	PRODUCTION_OPERATION_RESULT
		SET          
        	REAL_AMOUNT =#filternum(attributes.amount,8)#, 
            REAL_TIME =#attributes.real_time#, 
            STATION_ID =#attributes.station_id#, 
            ACTION_EMPLOYEE_ID =#attributes.employee_id#,
            UPDATE_EMP = #session.ep.userid#, 
            UPDATE_DATE = #attributes.end_date#, 
            UPDATE_IP = '#cgi.remote_addr#', 
            ACTION_START_DATE = #attributes.action_date#,
            FUSEACTION_NAME = '#attributes.fuseaction#'
		WHERE  
        	OPERATION_RESULT_ID = #attributes.upd_id#
    </cfquery>
    <cfquery name="upd_operation" datasource="#dsn3#">
    	UPDATE       
        	PRODUCTION_OPERATION
		SET                
        	STAGE = #attributes.stage#,
            UPDATE_EMP = #session.ep.userid#,
            UPDATE_DATE = #now()#,
            UPDATE_IP = '#cgi.remote_addr#'
		WHERE        
        	P_OPERATION_ID = #attributes.operation_id#
    </cfquery>
    <cfset attributes.work_employee_id = attributes.employee_id>
    <cfset attributes.result_id = attributes.upd_id>	
    <cfset attributes.station_id_ = attributes.station_id>
    <cfset attributes.real_time_ = attributes.real_time>
    <cfquery name="add_opetaion_time_cost_history" datasource="#dsn3#">
    	INSERT INTO 
        	EZGI_OPERATION_TIME_COST_HISTORY
            (
            	EZGI_OPERATION_TIME_COST_ID, 
                TIME_COST_TYPE, 
                TIME_COST_DATE, 
                TIME_COST_MINUTE, 
                OPERATION_RESULT_ID, 
                EMPLOYEE_ID, 
                STATION_ID, 
                STATUS, 
                OVERTIME_TYPE, 
                RECORD_EMP, 
                RECORD_DATE, 
                RECORD_IP, 
                UPDATE_EMP, 
                UPDATE_DATE, 
                UPDATE_IP, 
                TIME_COST_START_DATE, 
                TIME_COST_FINISH_DATE, 
                HISTORY_RECORD_EMP, 
                HISTORY_RECORD_DATE, 
                HISTORY_RECORD_IP
          	)
       	SELECT
        	EZGI_OPERATION_TIME_COST_ID, 
        	TIME_COST_TYPE, 
        	TIME_COST_DATE, 
        	TIME_COST_MINUTE, 
        	OPERATION_RESULT_ID, 
        	EMPLOYEE_ID, 
        	STATION_ID, 
        	STATUS, 
        	OVERTIME_TYPE, 
        	RECORD_EMP, 
        	RECORD_DATE, 
        	RECORD_IP, 
        	UPDATE_EMP, 
        	UPDATE_DATE, 
        	UPDATE_IP, 
        	TIME_COST_START_DATE, 
        	TIME_COST_FINISH_DATE, 
        	#session.ep.userid# AS HISTORY_RECORD_EMP, 
        	#now()# AS HISTORY_RECORD_DATE, 
        	'#cgi.remote_addr#' AS HISTORY_RECORD_IP
    	FROM
        	EZGI_OPERATION_TIME_COST
      	WHERE
        	OPERATION_RESULT_ID = #attributes.upd_id#	
    </cfquery>
    <cfquery name="del_opetaion_time_cost" datasource="#dsn3#">
    	DELETE FROM EZGI_OPERATION_TIME_COST WHERE OPERATION_RESULT_ID = #attributes.upd_id#
    </cfquery>
    <cfinclude template="../../e_vts/query/add_ezgi_operation_time_cost_include.cfm">
    <cfset employee_id_list = ListAppend(employee_id_list,attributes.employee_id)>
    <cfloop from="1" to="#attributes.RECORD_NUM#" index="i">
    	<cfset emp_id = Evaluate('attributes.EMPLOYEE_ID_#i#')>
    	<cfif Evaluate('attributes.ROW_KONTROL#i#') eq 1 and not ListFind(employee_id_list,emp_id)>
        	<cfset attributes.work_employee_id = emp_id>
            <cfinclude template="../../e_vts/query/add_ezgi_operation_time_cost_include.cfm">
        </cfif>
    </cfloop>
</cftransaction>
<script type="text/javascript">
	alert("<cf_get_lang dictionary_id='648.Üretim Sonucu Kaydedilmiştir'>!");
	wrk_opener_reload();
 	window.close();
</script>