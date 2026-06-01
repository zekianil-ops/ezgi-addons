<cftransaction>
	<cfquery name="upd_price_row" datasource="#dsn3#">
    	DELETE FROM
        	EZGI_VIRTUAL_OFFER_PRICE_ROW
       	WHERE 
        	PRICE_CAT_ROW_ID = #attributes.PRICE_CAT_ROW_ID#
    </cfquery>
</cftransaction>
<script language="javascript">
	window.opener.location.reload()
	window.close();
</script>