<!---
    File: upd_ezgi_master_plan.cfm
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
<cfif isdefined("attributes.shift_id") and len(attributes.shift_id)>
	<cfquery name="get_shift" datasource="#dsn#">
		SELECT     	
        	SHIFT_NAME,
			SHIFT_ID,
			BRANCH_ID
		FROM      	
        	SETUP_SHIFTS
		WHERE     	
        	SHIFT_ID = #attributes.shift_id#
	</cfquery>
	<cfset branch_id = get_shift.BRANCH_ID>
</cfif>
<cflock name="#CREATEUUID()#" timeout="90">
	<cfquery name="upd_shift" datasource="#dsn3#">
		UPDATE 	
        	EZGI_MASTER_PLAN
		SET
			MASTER_PLAN_START_DATE = #attributes.start_date#,
			MASTER_PLAN_FINISH_DATE = #attributes.finish_date#,
			MASTER_PLAN_CAT_ID = #attributes.shift_id#,
			MASTER_PLAN_NAME = '#attributes.shift_name#',
			MASTER_PLAN_NUMBER = '#paper_number#',
			MASTER_PLAN_DETAIL = '#attributes.detail#', 
			MASTER_PLAN_STATUS = <cfif isdefined('attributes.master_plan_status')>#attributes.master_plan_status#<cfelse>0</cfif>,
			MASTER_PLAN_STAGE = #attributes.process_stage#,
          	MASTER_PLAN_PROCESS = #attributes.get_master_plan_process#,
            MASTER_PLAN_PROJECT_ID = <cfif isdefined('project_id') and len(project_head)>#project_id#<cfelse>NULL</cfif>
		WHERE 	
        	MASTER_PLAN_ID = #upd_id#
	</cfquery>
</cflock>
<script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#?fuseaction=prod.list_ezgi_master_plan&event=upd&upd_id=#upd_id#</Cfoutput>';
</script>
