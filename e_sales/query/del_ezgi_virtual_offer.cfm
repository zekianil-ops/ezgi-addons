<cfquery name="is_revision_id" datasource="#dsn3#">
  	SELECT        
    	ISNULL(REVISION_ID,0) AS REVISION_ID
  	FROM            
    	EZGI_VIRTUAL_OFFER AS EZGI_VIRTUAL_OFFER_1
  	WHERE        
    	VIRTUAL_OFFER_ID = #attributes.virtual_offer_id#
</cfquery>

<cfquery name="get_revision_id" datasource="#dsn3#">
	SELECT
    	TOP (1) VIRTUAL_OFFER_ID
	FROM            
    	EZGI_VIRTUAL_OFFER
	WHERE        
    	REVISION_ID =
                  	(
                    	SELECT        
                        	REVISION_ID
                      	FROM            
                        	EZGI_VIRTUAL_OFFER AS EZGI_VIRTUAL_OFFER_1
                      	WHERE        
                        	VIRTUAL_OFFER_ID = #attributes.virtual_offer_id#
                   	) AND 
       	VIRTUAL_OFFER_ID <> #attributes.virtual_offer_id#
	ORDER BY 
    	REVISION_NO DESC
</cfquery>
<cfquery name="get_ezgi_id" datasource="#dsn3#">
	SELECT EZGI_ID FROM EZGI_VIRTUAL_OFFER_ROW WHERE VIRTUAL_OFFER_ID = #attributes.virtual_offer_id#
</cfquery>
<cfset ezgi_id_list = ValueList(get_ezgi_id.EZGI_ID)>
<cflock name="#CREATEUUID()#" timeout="90">
    <cftransaction>
    	<cfif is_revision_id.REVISION_ID gt 0>
			<cfif get_revision_id.recordcount>
                <cfquery name="upd_revision_id" datasource="#dsn3#">
                    UPDATE EZGI_VIRTUAL_OFFER SET VIRTUAL_OFFER_STATUS =1 WHERE VIRTUAL_OFFER_ID = #get_revision_id.VIRTUAL_OFFER_ID#
                </cfquery>
            <cfelse>
                <cfquery name="upd_revision_id" datasource="#dsn3#">
                    UPDATE EZGI_VIRTUAL_OFFER SET VIRTUAL_OFFER_STATUS =1 WHERE VIRTUAL_OFFER_ID = #is_revision_id.REVISION_ID#
                </cfquery>
            </cfif>
        </cfif>
        <cfset is_delete_ezgi = 1>
        <cfinclude template="upd_ezgi_virtual_offer_include.cfm">
    	<cfquery name="del_virtual_offer_row_detail" datasource="#dsn3#">
       		DELETE FROM EZGI_VIRTUAL_OFFER_ROW_DETAIL WHERE EZGI_ID IN (SELECT EZGI_ID FROM EZGI_VIRTUAL_OFFER_ROW WHERE VIRTUAL_OFFER_ID = #attributes.virtual_offer_id#)
     	</cfquery>
		<cfquery name="del_virtual_offer_row_money" datasource="#dsn3#">
         	DELETE FROM EZGI_VIRTUAL_OFFER_MONEY WHERE ACTION_ID = #attributes.virtual_offer_id#
     	</cfquery>
    	<cfquery name="del_virtual_offer_row" datasource="#dsn3#">
       		DELETE FROM EZGI_VIRTUAL_OFFER_ROW WHERE VIRTUAL_OFFER_ID = #attributes.virtual_offer_id#
     	</cfquery>
        <cfquery name="del_virtual_offer" datasource="#dsn3#">
       		DELETE FROM EZGI_VIRTUAL_OFFER WHERE VIRTUAL_OFFER_ID = #attributes.virtual_offer_id#
     	</cfquery>
        <cfif ListLen(ezgi_id_list)>
            <cfquery name="del_virtual_offer_delail" datasource="#dsn3#">
                DELETE FROM EZGI_VIRTUAL_OFFER_ROW_DETAIL WHERE EZGI_ID IN (#ezgi_id_list#)
            </cfquery>
            <cfquery name="del_virtual_offer_import" datasource="#dsn3#">
                DELETE FROM EZGI_VIRTUAL_OFFER_ROW_IMPORT WHERE EZGI_ID IN (#ezgi_id_list#)
            </cfquery>
            <cfquery name="del_virtual_offer_import_file" datasource="#dsn3#">
                DELETE FROM EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE WHERE EZGI_ID IN (#ezgi_id_list#)
            </cfquery>
            <cfquery name="del_virtual_offer_import_rota" datasource="#dsn3#">
                DELETE FROM EZGI_VIRTUAL_OFFER_ROW_IMPORT_ROTA WHERE EZGI_ID IN (#ezgi_id_list#)
            </cfquery>
            <cfquery name="del_virtual_offer_import_MONTAGE" datasource="#dsn3#">
                DELETE FROM EZGI_MONTAGE_ROW WHERE EZGI_ID IN (#ezgi_id_list#)
            </cfquery>
        </cfif>
  	</cftransaction>
</cflock>
<cfif is_revision_id.REVISION_ID gt 0>
	<cfif get_revision_id.recordcount>
        <cflocation url="#request.self#?fuseaction=prod.list_ezgi_virtual_offer&event=upd&virtual_offer_id=#get_revision_id.VIRTUAL_OFFER_ID#" addtoken="No">
    <cfelse>
        <cflocation url="#request.self#?fuseaction=prod.list_ezgi_virtual_offer&event=upd&virtual_offer_id=#is_revision_id.REVISION_ID#" addtoken="No">
   	</cfif>
<cfelse>
	<script type="text/javascript">
		window.location.href = '<cfoutput>#request.self#?fuseaction=prod.list_ezgi_virtual_offer</Cfoutput>';
	</script>
</cfif>