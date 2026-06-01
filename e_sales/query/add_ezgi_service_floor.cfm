<cfif ListLen(attributes.floor_id_list)>
	<cfloop list="#attributes.floor_id_list#" index="i">
        <cfquery name="add_montage" datasource="#dsn3#">
            INSERT INTO 
                EZGI_VIRTUAL_OFFER_ROW_FLOOR_MONTAGE
                (
                    EZGI_VIRTUAL_OFFER_ROW_FLOOR_ID, 
                    MONTAGE_TRACING_ID
                )
            VALUES     
                (
                    #i#,
                    #attributes.montage_tracing_id#
                )
        </cfquery>
	</cfloop>
</cfif>
<script type="text/javascript">
	window.close()
</script>