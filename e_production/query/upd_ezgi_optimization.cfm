<!---
    File: upd_ezgi_optimization.cfm
    Folder: AddOns\ezgi\e_production\query
    Author: Ezgi Yazılım
    Date: #dateFormat(now(), "dd/mm/yyyy")#
    Description: Optimizasyon Güncelleme Query
--->
<cfif not isDefined("attributes.optimization_status") or len(attributes.optimization_status) eq 0>
	<cfset attributes.optimization_status = 0>
</cfif>

<cfif isDefined("attributes.optimization_id") and len(attributes.optimization_id)>
	<cfparam name="attributes.circle_testre_thickness" default="">
	<cfparam name="attributes.outer_edge_trimming_allowance" default="">
	
	<cfquery name="upd_optimization" datasource="#dsn3#">
		UPDATE 
			EZGI_IFLOW_OPTIMIZATION
		SET
			OPTIMIZATION_DETAIL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.optimization_detail#">,
			OPTIMIZATION_STATUS = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_status#">,
			OPTIMIZATION_DATE = <cfif len(attributes.optimization_date) and isDate(attributes.optimization_date)>
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.optimization_date#">
			<cfelse>
				NULL
			</cfif>,
			OPTIMIZATION_EMP = <cfif len(attributes.optimization_emp_id) and isNumeric(attributes.optimization_emp_id)>
				<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_emp_id#">
			<cfelse>
				NULL
			</cfif>,
			UPDATE_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
			UPDATE_IP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
			UPDATE_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
		WHERE
			OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
	</cfquery>
	
	<script type="text/javascript">
		alert("Kayıt güncellendi!");
		window.location.href = "<cfoutput>#request.self#?fuseaction=prod.list_ezgi_optimization&event=upd&optimization_id=#attributes.optimization_id#</cfoutput>";
	</script>
<cfelse>
	<script type="text/javascript">
		alert("Geçersiz kayıt ID!");
		window.location.href = "<cfoutput>#request.self#?fuseaction=prod.list_ezgi_optimization&event=upd&optimization_id=#attributes.optimization_id#</cfoutput>";
	</script>
</cfif>

