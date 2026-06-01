<cfquery name="GET_WORKSTATION" datasource="#DSN3#">
	SELECT
		*
	FROM
		WORKSTATIONS
	WHERE
		STATION_ID IS NOT NULL AND
		ACTIVE = 1
		<cfif isdefined("attributes.station_id") and LEN(attributes.station_id)>
			AND
				STATION_ID <> #attributes.station_id#
		</cfif>
	ORDER BY
		STATION_NAME ASC
</cfquery>
<cfquery name="GET_W" datasource="#DSN3#">
	SELECT 
		* 
	FROM	
		WORKSTATIONS
	ORDER BY
		STATION_NAME ASC
</cfquery>
