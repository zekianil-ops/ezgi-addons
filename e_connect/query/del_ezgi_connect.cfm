<cftransaction>
    <cfquery name="del_connect_row" datasource="#dsn3#">
        DELETE FROM EZGI_CONNECT WHERE CONNECT_ID = #attributes.connect_id#
    </cfquery>
    <cfquery name="del_connect_row" datasource="#dsn3#">
        DELETE FROM EZGI_CONNECT_ROW WHERE CONNECT_ID = #attributes.connect_id#
    </cfquery>
    <cfquery name="del_connect_row" datasource="#dsn3#">
        DELETE FROM EZGI_CONNECT_MONEY WHERE ACTION_ID = #attributes.connect_id#
    </cfquery>
</cftransaction>
<script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_ezgi_connect</Cfoutput>';
</script>