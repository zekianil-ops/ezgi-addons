<cfquery name="UPD_PRICE_CAT" datasource="#DSN3#">
	DELETE FROM
		EZGI_VIRTUAL_OFFER_PRICE_LIST
	WHERE 
		PRICE_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.price_cat_id#"> 
</cfquery>
<cfquery name="UPD_PRICE_CAT_ROW" datasource="#DSN3#">
	DELETE FROM 
    	EZGI_VIRTUAL_OFFER_PRICE_ROW
	WHERE  
    	PRICE_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.price_cat_id#"> 
</cfquery>
<script type="text/javascript">
	window.location.href = "<cfoutput>#request.self#?fuseaction=prod.list_ezgi_virtual_offer_price_cat</cfoutput>";
</script>
