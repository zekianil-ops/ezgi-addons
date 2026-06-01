<cfquery name="GET_SHELVES_TYPE" datasource="#DSN3#">
	SELECT
		*
	FROM
		EZGI_WM_SETUP_SHELF_SIZE_TYPE		
	ORDER BY
		SHELF_SIZE_TYPE_code desc
</cfquery>
