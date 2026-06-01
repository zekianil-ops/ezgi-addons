<cfif isDefined("attributes.optimization_id") and len(attributes.optimization_id) and isNumeric(attributes.optimization_id)>
	<!--- Önce satırları sil --->
	<cfquery name="del_optimization_material_rows" datasource="#dsn3#">
		DELETE FROM
			EZGI_IFLOW_OPTIMIZATION_MATERIAL_ROW
		WHERE
			OPTIMIZATION_MATERIAL_ID IN (
				SELECT
					OPTIMIZATION_MATERIAL_ID
				FROM
					EZGI_IFLOW_OPTIMIZATION_MATERIAL
				WHERE
					OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
			)
	</cfquery>

	<!--- Sonra ana kayıtları sil --->
	<cfquery name="del_optimization_materials" datasource="#dsn3#">
		DELETE FROM
			EZGI_IFLOW_OPTIMIZATION_MATERIAL
		WHERE
			OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
	</cfquery>
	
	<cfoutput>OK</cfoutput>
<cfelse>
	<cfoutput>ERROR: Invalid optimization_id</cfoutput>
</cfif>
