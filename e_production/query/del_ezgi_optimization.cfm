<!---
    File: del_ezgi_optimization.cfm
    Folder: AddOns\ezgi\e_production\query
    Author: Ezgi Yazılım
    Date: #dateFormat(now(), "dd/mm/yyyy")#
    Description: Optimizasyon Silme Query
--->

<cfparam name="attributes.optimization_id" default="">

<cfif len(attributes.optimization_id) and isNumeric(attributes.optimization_id)>
	<cflock name="#CREATEUUID()#" timeout="90">
		<cftransaction>
			<!--- Önce sonuç satırlarını sil --->
			<cfquery name="del_optimization_results_row" datasource="#dsn3#">
				DELETE FROM 
					EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW
				WHERE 
					OPTIMIZATION_RESULT_ID IN (
						SELECT 
							OPTIMIZATION_RESULT_ID
						FROM 
							EZGI_IFLOW_OPTIMIZATION_RESULTS
						WHERE 
							OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
					)
			</cfquery>
			
			<!--- Sonuçları sil --->
			<cfquery name="del_optimization_results" datasource="#dsn3#">
				DELETE FROM 
					EZGI_IFLOW_OPTIMIZATION_RESULTS
				WHERE 
					OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
			</cfquery>
			
		<!--- Optimizasyon satırlarını sil --->
		<cfquery name="del_optimization_row" datasource="#dsn3#">
			DELETE FROM 
				EZGI_IFLOW_OPTIMIZATION_ROW
			WHERE 
				OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
		</cfquery>
		
		<!--- Ana optimizasyon kaydını sil --->
		<cfquery name="del_optimization" datasource="#dsn3#">
			DELETE FROM 
				EZGI_IFLOW_OPTIMIZATION
			WHERE 
				OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
		</cfquery>
		</cftransaction>
	</cflock>
</cfif>

<cflocation url="#request.self#?fuseaction=prod.list_ezgi_optimization" addtoken="No">
