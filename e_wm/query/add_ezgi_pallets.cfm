<cftransaction>
	<cflock timeout="90">
        <cfquery name="get_defaults" datasource="#dsn3#">
            SELECT * FROM EZGI_SHIPPING_DEFAULTS
        </cfquery>
        <cfset attributes.barcode = get_defaults.PALET_BARCODE>
        <cfloop from="1" to="#attributes.amount#" index="i">
			<cfset attributes.barcode = attributes.barcode+1>
            <cfquery name="add_packings" datasource="#dsn3#" >
                INSERT INTO 
                    EZGI_PACKING
                    (
                        BARCODE, 
                        STATUS, 
						PROCESS_STATUS,
                        IS_KARMA,
                        RECORD_IP, 
                        RECORD_EMP, 
                        RECORD_DATE
                        <cfif isdefined('attributes.palette_size') and len(attributes.palette_size)>
                        	,PACKING_SIZE_TYPE_ID
                        </cfif>
                    )
                VALUES
                    (
                        '#attributes.barcode#',
                        <cfif isdeFined('is_active')>1<cfelse>0</cfif>,
						0,
                        <cfif isdefined('attributes.palet_tur') and len(attributes.palet_tur)>#attributes.palet_tur#<cfelse>0</cfif>,
                        '#cgi.remote_addr#',
                        #session.ep.userid#,
                        #now()#
                        <cfif isdefined('attributes.palette_size') and len(attributes.palette_size)>
                        	,#attributes.palette_size#
                        </cfif>
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
<cfif attributes.amount eq 1>
	<script type="text/javascript">
        window.location ="<cfoutput>#request.self#?fuseaction=stock.list_ezgi_pallets&event=upd&packing_id=#get_maxid.max_id#</cfoutput>";
    </script>
<cfelse>
	<script type="text/javascript">
        window.location ="<cfoutput>#request.self#?fuseaction=stock.list_ezgi_pallets</cfoutput>";
    </script>
</cfif>