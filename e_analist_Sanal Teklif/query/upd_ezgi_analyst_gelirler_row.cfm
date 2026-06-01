<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_ANALYST_BRANCH WHERE ANALYST_BRANCH_ID = #attributes.upd_id#
</cfquery>
<cfif listlen(attributes.INVOICE_ROW_1)>
	<cftransaction>
        <cfloop list="#attributes.INVOICE_ROW_1#" index="i">
            <cfquery name="upd_invoice_row" datasource="#dsn#">
                UPDATE       
                    #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.INVOICE_ROW
                SET                
                    LIST_PRICE = #FilterNum(Evaluate('attributes.LIST_PRICE#i#'),2)#
                WHERE        
                    INVOICE_ROW_ID = #i#
            </cfquery>
        </cfloop>
    </cftransaction>
</cfif>
<cflocation url="#request.self#?fuseaction=report.popup_upd_ezgi_analyst_gelirler_row&upd_id=#attributes.upd_id#" addtoken="No">
