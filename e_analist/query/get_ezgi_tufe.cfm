<cfquery name="GET_TUFE" datasource="#dsn#">
	SELECT 
		* 
	FROM 
		EZGI_SETUP_TUFE
	ORDER BY 
		PERIOD_YEAR desc, PERIOD_MONTH DESC
</cfquery>