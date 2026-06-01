<!---
    File: add_ezgi_iflow_master_plan.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfif isdefined('attributes.start_date') and isdate(attributes.start_date)>
    <cf_date tarih = "attributes.start_date">
    <cfset attributes.start_date = dateadd("n",attributes.start_m,dateadd("h",attributes.start_h ,attributes.start_date))>
<cfelse>
    <cfset attributes.start_date =''>
</cfif>
<cfif isdefined('attributes.finish_date') and isdate(attributes.finish_date)>
    <cf_date tarih = "attributes.finish_date">
    <cfset attributes.finish_date = dateadd("n",attributes.finish_m,dateadd("h",attributes.finish_h ,attributes.finish_date))>
<cfelse>
    <cfset attributes.finish_date =''>
</cfif>
<cfset _paper_number= paper_serious&paper_number>
<cfif isdefined("attributes.shift_id") and len(attributes.shift_id)>
	<cfquery name="get_shift" datasource="#dsn#">
		SELECT SHIFT_NAME, SHIFT_ID, BRANCH_ID FROM SETUP_SHIFTS WHERE SHIFT_ID = #attributes.shift_id#
	</cfquery>
<cfset branch_id = get_shift.BRANCH_ID>
</cfif>
<cflock name="#CREATEUUID()#" timeout="90">
			<cfquery name="add_shift" datasource="#dsn3#">
				INSERT INTO 
                	EZGI_IFLOW_MASTER_PLAN
					(
						GROSSTOTAL,
						MASTER_PLAN_PROCESS,
						MASTER_PLAN_START_DATE,
						MASTER_PLAN_FINISH_DATE,
						MASTER_PLAN_CAT_ID, 
						MASTER_PLAN_NAME, 
						MASTER_PLAN_NUMBER, 
						MASTER_PLAN_DETAIL, 
						MASTER_PLAN_STATUS, 
						MASTER_PLAN_STAGE,
						EMPLOYYEE_ID, 
						BRANCH_ID, 
						RECORD_EMP, 
						RECORD_IP, 
						RECORD_DATE, 
						IS_PROCESS, 
						MASTER_PLAN_PROJECT_ID
					)
				VALUES	
					(
						0,
						<cfif isdefined('attributes.is_stock_reserve')>1<cfelse>0</cfif>,
						#attributes.start_date#,
						#attributes.finish_date#,
						#attributes.shift_id#,
						'#attributes.shift_name#',
						'#_paper_number#',
						'#attributes.detail#',
						#attributes.master_plan_status#,
						#attributes.process_stage#,
						#attributes.shift_employee_id#,
						#branch_id#,
						#session.ep.userid#,
						'#cgi.remote_addr#',
						#now()#,
						0,
						<cfif isdefined('project_id') and len(project_id)>#project_id#<cfelse>NULL</cfif>
					)
			</cfquery>
			<cfquery name="UPD_PAPER" datasource="#dsn3#">
				UPDATE	
                	EZGI_DESIGN_DEFAULTS
				SET 	
                	DEFAULT_IFLOW_MASTER_PAPER_NO = #paper_number#+1 
			</cfquery>
			<cfquery name="get_master_plan_id" datasource="#dsn3#">
				SELECT 	MAX(MASTER_PLAN_ID) AS upd_id FROM EZGI_IFLOW_MASTER_PLAN
			</cfquery>
</cflock>
<script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#?fuseaction=prod.list_ezgi_iflow_master_plan&event=upd&master_plan_id=#get_master_plan_id.upd_id#</Cfoutput>';
</script>
