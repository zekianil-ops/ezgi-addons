<cfquery name="add_tufe" datasource="#dsn#">
	INSERT INTO 
		EZGI_SETUP_TUFE
	(
		PERIOD_YEAR,
        PERIOD_MONTH,
		TUFE_RATE,
		TEFE_RATE
	)
	VALUES 
	(
		<cfif isdefined("attributes.tufe_year") and len(attributes.tufe_year)>'#attributes.tufe_year#'<cfelse>NULL</cfif>,
		<cfif isdefined("attributes.tufe_month") and len(attributes.tufe_month)>'#attributes.tufe_month#'<cfelse>NULL</cfif>,
		<cfif isdefined("attributes.tufe_rate") and len(attributes.tufe_rate)>#filternum(attributes.tufe_rate)#<cfelse>NULL</cfif>,
		<cfif isdefined("attributes.tefe_rate") and len(attributes.tefe_rate)>#filternum(attributes.tefe_rate)#<cfelse>NULL</cfif>
	)
</cfquery>
<cflocation url="#request.self#?fuseaction=report.add_ezgi_tufe" addtoken="no">
