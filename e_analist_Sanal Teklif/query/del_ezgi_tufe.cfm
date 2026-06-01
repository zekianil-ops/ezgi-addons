<cfquery name="del_tufe" datasource="#dsn#">
	DELETE
		EZGI_SETUP_TUFE

	WHERE
    	TUFE_ID = #attributes.tufe_id#
</cfquery>
<cflocation url="#request.self#?fuseaction=report.add_ezgi_tufe" addtoken="no">
