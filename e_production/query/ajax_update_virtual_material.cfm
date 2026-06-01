<!---
    File: ajax_update_virtual_material.cfm
    Folder: AddOns\ezgi\e_production\query
    Author: Ezgi Yazılım
    Date: 12/12/2025
    Description: IS_VIRTUAL_MATERIAL alanını güncelleme (AJAX)
--->

<!--- JSON response için Content-Type header'ı ayarla --->
<cfcontent type="application/json; charset=utf-8">

<cfparam name="attributes.sheet_group_number" default="">
<cfparam name="attributes.is_virtual_material" default="0">
<cfparam name="attributes.optimization_id" default="">

<!--- URL'den gelen parametreleri attributes'a yansıt --->
<cfif isDefined("url.sheet_group_number") and len(url.sheet_group_number)>
	<cfset attributes.sheet_group_number = url.sheet_group_number>
</cfif>
<cfif isDefined("url.is_virtual_material") and len(url.is_virtual_material)>
	<cfset attributes.is_virtual_material = url.is_virtual_material>
</cfif>
<cfif isDefined("url.optimization_id") and len(url.optimization_id)>
	<cfset attributes.optimization_id = url.optimization_id>
</cfif>

<!--- Form'dan gelen parametreleri attributes'a kopyala --->
<cfif isDefined("form.sheet_group_number") and len(form.sheet_group_number)>
	<cfset attributes.sheet_group_number = form.sheet_group_number>
</cfif>
<cfif isDefined("form.is_virtual_material") and len(form.is_virtual_material)>
	<cfset attributes.is_virtual_material = form.is_virtual_material>
</cfif>
<cfif isDefined("form.optimization_id") and len(form.optimization_id)>
	<cfset attributes.optimization_id = form.optimization_id>
</cfif>

<!--- Validasyon --->
<cfif not len(attributes.sheet_group_number) or not isNumeric(attributes.sheet_group_number)>
	<cfoutput>{"success": false, "message": "Geçersiz sheet group number: #attributes.sheet_group_number#"}</cfoutput>
	<cfabort>
</cfif>

<cfif not len(attributes.optimization_id) or not isNumeric(attributes.optimization_id)>
	<cfoutput>{"success": false, "message": "Geçersiz optimization ID: #attributes.optimization_id#"}</cfoutput>
	<cfabort>
</cfif>

<cfset is_virtual = 0>
<cfif attributes.is_virtual_material EQ "1" or attributes.is_virtual_material EQ 1 or attributes.is_virtual_material EQ true>
	<cfset is_virtual = 1>
</cfif>

<!--- IS_VIRTUAL_MATERIAL alanını güncelle --->
<cftry>
	<cfquery name="upd_virtual_material" datasource="#dsn3#">
		UPDATE 
			EZGI_IFLOW_OPTIMIZATION_RESULTS
		SET 
			IS_VIRTUAL_MATERIAL = <cfqueryparam cfsqltype="cf_sql_bit" value="#is_virtual#">
		WHERE 
			OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
			AND SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
	</cfquery>
	
	<cfif upd_virtual_material.recordcount EQ -1>
		<cfoutput>{"success": true, "message": "Güncelleme başarılı", "affected_rows": "#upd_virtual_material.recordcount#"}</cfoutput>
	<cfelse>
		<cfoutput>{"success": true, "message": "Güncelleme başarılı"}</cfoutput>
	</cfif>
	<cfcatch type="any">
		<cfoutput>{"success": false, "message": "Veritabanı hatası: #cfcatch.message#", "detail": "#cfcatch.detail#"}</cfoutput>
	</cfcatch>
</cftry>
