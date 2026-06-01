<cfquery name="add_tufe" datasource="#dsn#">
	UPDATE
		EZGI_SETUP_TUFE
	SET
		PERIOD_YEAR = <cfif isdefined("attributes.tufe_year") and len(attributes.tufe_year)>'#attributes.tufe_year#'<cfelse>NULL</cfif>,
        PERIOD_MONTH = <cfif isdefined("attributes.tufe_month") and len(attributes.tufe_month)>'#attributes.tufe_month#'<cfelse>NULL</cfif>,
		TUFE_RATE = <cfif isdefined("attributes.tufe_rate") and len(attributes.tufe_rate)>#filternum(attributes.tufe_rate)#<cfelse>NULL</cfif>,
		TEFE_RATE = <cfif isdefined("attributes.tefe_rate") and len(attributes.tefe_rate)>#filternum(attributes.tefe_rate)#<cfelse>NULL</cfif>
	WHERE
    	TUFE_ID = #attributes.tufe_id#
</cfquery>
<cflocation url="#request.self#?fuseaction=report.upd_ezgi_tufe&tufe_id=#attributes.tufe_id#" addtoken="no">
