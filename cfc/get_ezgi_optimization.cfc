<cfcomponent>
	<cfset this.DSN = "">
	<cfset this.DSN3 = "">
	
	<cffunction name="get_ezgi_optimization_" returntype="query">
		<cfargument name="keyword" default="">
		<cfargument name="record_emp_id" default="">
		<cfargument name="record_emp_name" default="">
		<cfargument name="record_date1" default="">
		<cfargument name="record_date2" default="">
		<cfargument name="date1" default="">
		<cfargument name="date2" default="">
		<cfargument name="oby" default="1">
		<cfargument name="optimization_status" default="">
		<cfargument name="startrow" default="">
		<cfargument name="maxrows" default="">
		
		<cfquery name="get_ezgi_optimization" datasource="#this.DSN3#">
			WITH CTE1 AS 
			(
			SELECT 
				OPTIMIZATION_ID,
				OPTIMIZATION_NUMBER,
				OPTIMIZATION_DETAIL,
				OPTIMIZATION_STATUS,
				OPTIMIZATION_DATE,
				OPTIMIZATION_EMP,
				RECORD_DATE,
				RECORD_EMP,
				UPDATE_DATE,
				UPDATE_EMP
			FROM 
				EZGI_IFLOW_OPTIMIZATION WITH (NOLOCK)
				WHERE 
					1=1
					<cfif len(arguments.keyword)>
						AND (
							OPTIMIZATION_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
							OR OPTIMIZATION_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
						)
					</cfif>
					<cfif len(arguments.record_emp_id) and isNumeric(arguments.record_emp_id)>
						AND RECORD_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.record_emp_id#">
					</cfif>
					<cfif len(arguments.record_date1) and isDate(arguments.record_date1)>
						AND RECORD_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.record_date1#">
					</cfif>
					<cfif len(arguments.record_date2) and isDate(arguments.record_date2)>
						AND RECORD_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateAdd('d', 1, arguments.record_date2)#">
					</cfif>
					<cfif len(arguments.date1) and isDate(arguments.date1)>
						AND RECORD_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.date1#">
					</cfif>
					<cfif len(arguments.date2) and isDate(arguments.date2)>
						AND RECORD_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateAdd('d', 1, arguments.date2)#">
					</cfif>
					<cfif len(arguments.optimization_status)>
						AND OPTIMIZATION_STATUS = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.optimization_status#">
					</cfif>
			),
			CTE2 AS (
				SELECT
					CTE1.*,
					ROW_NUMBER() OVER (
						ORDER BY 
						<cfif isDefined('arguments.oby') and arguments.oby eq 2>
							RECORD_DATE ASC
						<cfelse>
							RECORD_DATE DESC
						</cfif>
					) AS RowNum,
					(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
				FROM
					CTE1
			)
			SELECT
				CTE2.*
			FROM
				CTE2
			WHERE
				RowNum BETWEEN #startrow# and #startrow#+(#maxrows#-1)
		</cfquery>
		<cfreturn get_ezgi_optimization>
	</cffunction>
</cfcomponent>
