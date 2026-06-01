<cfquery name="DEL_OFFER_PLUS" datasource="#dsn3#">
	DELETE
		EZGI_VIRTUAL_OFFER_PLUS
	WHERE
		<cfif isdefined("attributes.OFFER_PLUS_ID")>
		VIRTUAL_OFFER_PLUS_ID = #attributes.VIRTUAL_OFFER_PLUS_ID#
		<cfelse>
		VIRTUAL_OFFER_PLUS_ID = #VIRTUAL_OFFER_PLUS_ID#
		</cfif>
		
</cfquery>
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
