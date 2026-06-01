<cfquery name="UPD_PRICE_CAT" datasource="#DSN3#">
	UPDATE
		EZGI_VIRTUAL_OFFER_PRICE_LIST
	SET 
		PRICE_CAT = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.price_cat#">,
		COMPANY_CATS =  <cfif isDefined("attributes.company_cat")><cfqueryparam cfsqltype="cf_sql_varchar" value=",#attributes.company_cat#,"><cfelse>NULL</cfif>,
		CONSUMER_CATS = <cfif isDefined("attributes.consumer_cat")><cfqueryparam cfsqltype="cf_sql_varchar" value=",#attributes.consumer_cat#,"><cfelse>NULL</cfif>,
		STATUS = <cfif isdefined("attributes.price_cat_status")>1<cfelse>0</cfif>
	WHERE 
		PRICE_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.price_cat_id#"> 
</cfquery>
<script type="text/javascript">
		window.location.href = "<cfoutput>#request.self#?fuseaction=prod.list_ezgi_virtual_offer_price_cat</cfoutput>";
</script>
