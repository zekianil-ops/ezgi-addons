<!---
    File: add_ezgi_optimization.cfm
    Folder: AddOns\ezgi\e_production\query
    Author: Ezgi Yazılım
    Date: #dateFormat(now(), "dd/mm/yyyy")#
    Description: Optimizasyon Ekleme Query
--->

<!--- optimization_status her zaman aktif (1) olarak kaydedilir --->
<cfset attributes.optimization_status = 1>

<cfparam name="attributes.optimization_number" default="">
<cfparam name="attributes.optimization_detail" default="">
<cfparam name="attributes.optimization_date" default="">
<cfparam name="attributes.optimization_emp_id" default="#session.ep.userid#">
<cfparam name="attributes.master_plan_id" default="">
<cfparam name="attributes.circle_testre_thickness" default="">
<cfparam name="attributes.outer_edge_trimming_allowance" default="">

<!--- Belge numarası form sayfasından gelir, eğer gelmezse hata ver --->
<cfif not len(attributes.optimization_number)>
	<script type="text/javascript">
		alert("Belge numarası bulunamadı!");
		window.location.href = "<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_ezgi_optimization</cfoutput>";
	</script>
	<cfexit method="exittemplate">
</cfif>

<cflock name="#CREATEUUID()#" timeout="90">
	<cfquery name="add_optimization" datasource="#dsn3#">
		INSERT INTO 
			EZGI_IFLOW_OPTIMIZATION
		(
			OPTIMIZATION_NUMBER,
			OPTIMIZATION_DETAIL,
			OPTIMIZATION_STATUS,
			OPTIMIZATION_DATE,
			OPTIMIZATION_EMP,
			MASTER_PLAN_ID,
			RECORD_EMP,
			RECORD_IP,
			RECORD_DATE
		)
		VALUES
		(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.optimization_number#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.optimization_detail#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_status#">,
			<cfif len(attributes.optimization_date) and isDate(attributes.optimization_date)>
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.optimization_date#">
			<cfelse>
				NULL
			</cfif>,
			<cfif len(attributes.optimization_emp_id) and isNumeric(attributes.optimization_emp_id)>
				<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_emp_id#">
			<cfelse>
				NULL
			</cfif>,
			<cfif len(attributes.master_plan_id) and isNumeric(attributes.master_plan_id)>
				<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.master_plan_id#">
			<cfelse>
				NULL
			</cfif>,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
		)
	</cfquery>
	
	<!---
		SCOPE_IDENTITY() bazı ortamlarda boş dönebiliyor; 
		bu yüzden yeni oluşturulan kaydı OPTIMIZATION_NUMBER'a göre
		bularak MAX(OPTIMIZATION_ID) ile ID'yi alıyoruz.
	--->
	<cfquery name="get_last_id" datasource="#dsn3#">
		SELECT 
			MAX(OPTIMIZATION_ID) AS OPTIMIZATION_ID
		FROM 
			EZGI_IFLOW_OPTIMIZATION
		WHERE 
			OPTIMIZATION_NUMBER = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.optimization_number#">
	</cfquery>
</cflock>

<script type="text/javascript">
	alert("Optimizasyon başarıyla oluşturuldu!");	
	window.location.href = "<cfoutput>#request.self#?fuseaction=prod.list_ezgi_optimization&event=upd&optimization_id=#get_last_id.OPTIMIZATION_ID#</cfoutput>";
</script>

