<cfparam name="attributes.amount" default="1">
<cftransaction>
	<cflock timeout="90">
        <cfquery name="get_defaults" datasource="#dsn3#">
            SELECT * FROM EZGI_SHIPPING_DEFAULTS
        </cfquery>
        <cfset attributes.barcode = get_defaults.PALET_BARCODE>
        <cfloop from="1" to="#attributes.amount#" index="say">
        	<cfset attributes.barcode = attributes.barcode+1>
            <cfquery name="add_packings" datasource="#dsn3#" >
                INSERT INTO 
                    EZGI_PACKING
                    (
                        BARCODE, 
                        COMPANY_ID, 
                        CONSUMER_ID, 
                        ORDER_ID,
                        ORDER_ROW_ID,
                        LOT_NO,
                        TYPE, 
                        STATUS, 
                        DETAIL,
                        RECORD_IP, 
                        RECORD_EMP, 
                        RECORD_DATE
                    )
                VALUES
                    (
                        '#attributes.barcode#',
                        <cfif isdefined('attributes.company_id') and len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>#attributes.consumer_id#<cfelse>NULL</cfif>,
                        #attributes.order_id#,
                        #attributes.order_row_id#,
                        <cfif isdefined('attributes.lot_no') and len(attributes.lot_no)>#attributes.lot_no#<cfelse>NULL</cfif>,
                        #attributes.type#,
                        <cfif isdeFined('is_active')>1<cfelse>0</cfif>,
                        '#attributes.detail#',
                        '#cgi.remote_addr#',
                        #session.ep.userid#,
                        #now()#
                    )
             </cfquery>
         </cfloop>
        <cfquery name="upd_barcode" datasource="#dsn3#">
            UPDATE EZGI_SHIPPING_DEFAULTS SET PALET_BARCODE = '#attributes.barcode#'
        </cfquery> 
         <cfquery name="GET_MAXID" datasource="#dsn3#">
            SELECT MAX(PACKING_ID) AS MAX_ID FROM EZGI_PACKING
        </cfquery>
	</cflock>
</cftransaction>
<script type="text/javascript">
	<cfif attributes.amount eq 1>
		window.location ="<cfoutput>#request.self#?fuseaction=sales.list_ezgi_packingS&event=upd&packing_id=#get_maxid.max_id#</cfoutput>";
	<cfelse>
		window.location ="<cfoutput>#request.self#?fuseaction=sales.list_ezgi_packings&maxrows=#attributes.amount#&is_submitted=1</cfoutput>";
	</cfif>
</script>