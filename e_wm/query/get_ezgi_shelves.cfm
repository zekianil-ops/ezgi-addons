<cfquery name="GET_SHELVES" datasource="#DSN#">
	SELECT
		*
	FROM
		SHELF		
		<cfif isDefined("attributes.shelf_type_id")>
	WHERE 
		SHELF_ID = #attributes.shelf_type_id#
		</cfif>	
	ORDER BY
		SHELF_NAME
</cfquery>
