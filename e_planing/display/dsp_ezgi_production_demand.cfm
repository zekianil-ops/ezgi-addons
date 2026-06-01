<cfparam name="attributes.keyword" default=''>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.is_form_submitted" default="1">
<cfquery name="get_product_name" datasource="#dsn3#">
	SELECT     
        PRODUCT_NAME
	FROM         
    	STOCKS
	WHERE     
    	STOCK_ID = #attributes.sid#
</cfquery>
<cfif isdefined("attributes.is_form_submitted")>
	<cfquery name="get_demand_list" datasource="#DSN3#">
    	SELECT     
        	E.DEMAND_DATE, 
            E.DEMAND_HEAD, 
            E.DEMAND_DELIVER_DATE, 
            R.QUANTITY, 
            ISNULL(SUM(PO.QUANTITY), 0) AS P_QUANTITY
		FROM         
        		EZGI_IFLOW_PRODUCTION_ORDERS AS EPR INNER JOIN
              	PRODUCTION_ORDERS AS PO ON EPR.REL_P_ORDER_ID = PO.P_ORDER_ID RIGHT OUTER JOIN
             	EZGI_PRODUCTION_DEMAND_ROW AS R INNER JOIN
         		EZGI_PRODUCTION_DEMAND AS E ON R.EZGI_DEMAND_ID = E.EZGI_DEMAND_ID ON EPR.IFLOW_P_ORDER_ID = R.EZGI_ID
      	WHERE
        	 R.STOCK_ID = #attributes.sid#
            <cfif len(attributes.keyword)>
            	AND E.DEMAND_HEAD LIKE '%attributes.keyword%'
            </cfif>
		GROUP BY 
        	E.DEMAND_DATE, 
            E.DEMAND_HEAD, 
            E.DEMAND_DELIVER_DATE, 
            R.QUANTITY
      	HAVING      
        	ISNULL(SUM(PO.QUANTITY), 0) < R.QUANTITY
	</cfquery>
<cfelse>
	<cfset get_demand_list.recordcount =0>
</cfif>
<!---<cfdump expand="yes" var="#get_demand_list#">
<cfabort>--->
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default=#get_demand_list.recordcount#>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfform action="#request.self#?fuseaction=prod.popup_dsp_ezgi_production_demand&sid=#attributes.sid#" method="post">
	<cf_medium_list_search title="Üretim Talepleri">
		<cf_medium_list_search_area>
			<table>
				<tr>
					<cfinput type="hidden" name="is_form_submitted" value="1">
					<td><cf_get_lang dictionary_id='57460.Filtre'></td>
					<td><cfinput type="text" name="keyword" style="width:100px;" value="#attributes.keyword#"></td>
					<td>
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='34135.Sayi_Hatasi_Mesaj'></cfsavecontent>
						<cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#message#" maxlength="3" style="width:25px;">
					</td>
					<td><cf_wrk_search_button></td>
				</tr>
			</table>
		</cf_medium_list_search_area>
	</cf_medium_list_search>
</cfform>
<table width="100%">
	<tr>
    	<td>
            <cf_box title="<cfoutput>#get_product_name.PRODUCT_NAME#</cfoutput>" style="width:99%; margin-top:10px;">
                <cf_ajax_list>
                    <thead>
                        <tr>
                            <th><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th><cf_get_lang dictionary_id='33361.Talep Tarihi'></th>
                            <th><cf_get_lang dictionary_id='290.Termin Tarihi'></th>
                            <th><cf_get_lang dictionary_id='57629.Açıklama'></th>
                            <th><cf_get_lang dictionary_id='291.Talep Miktarı'></th>
                            <th><cf_get_lang dictionary_id='192.Emir Miktarı'></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfif get_demand_list.recordcount>
                            <cfoutput query="get_demand_list" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                                <tr>
									<td>#currentrow#</td>
									<td nowrap>#dateformat(DEMAND_DATE,'dd/mm/yyyy')#</td>
                                    <td nowrap>#dateformat(DEMAND_DELIVER_DATE,'dd/mm/yyyy')#</td>
                                    <td nowrap>#DEMAND_HEAD#</td>
                                    <td align="right">#QUANTITY#</td>
                                    <td align="right">#P_QUANTITY#</td>
                                </tr>
                            </cfoutput>
                        <cfelse>
                            <tr>
                                <td colspan="6"><cf_get_lang dictionary_id='58486.Kayit Bulunamadi'>!</td>
                            </tr>
                        </cfif>
                    </tbody>
                </cf_ajax_list>
            </cf_box>
        </td>
    </tr>
</table>
<cf_popup_box_footer>
<cfif attributes.totalrecords gt attributes.maxrows>
	<table width="99%" cellpadding="0" cellspacing="0" border="0" align="center" height="35">
		<tr>
			<td>
				<cfset adres = attributes.fuseaction & "&sid=#attributes.sid#">
				<cfif len(attributes.keyword)>
				  <cfset adres = "#adres#&keyword=#attributes.keyword#">
				</cfif>
				<cf_pages page="#attributes.page#" 
						maxrows="#attributes.maxrows#"
						totalrecords="#attributes.totalrecords#"
						startrow="#attributes.startrow#"
						adres="#adres#">
				</td>
			<td style="text-align:right;"><cf_get_lang dictionary_id='57492.Toplam'>:<cfoutput>#attributes.totalrecords#-&nbsp;<cf_get_lang dictionary_id='57581.Sayfa'>:#attributes.page#/#lastpage#</cfoutput></td>
		</tr>
	</table>
</cfif>
</cf_popup_box_footer>