<cfquery name="get_tufe_id" datasource="#dsn#" maxrows="1">
	SELECT
		*
	FROM
		EZGI_SETUP_TUFE
	WHERE
		TUFE_ID = #tufe_id#
</cfquery>
<cfquery name="get_period" datasource="#dsn#">
    SELECT     
        PERIOD_YEAR
    FROM         
        SETUP_PERIOD
    WHERE     
        OUR_COMPANY_ID = #session.ep.company_id#
  	ORDER BY
      	PERIOD_YEAR desc
</cfquery>
<table width="98%" height="35" border="0" align="center" cellpadding="0" cellspacing="0" >
	<tr>
		<td  class="headbold">Tüfe Oranı Güncelle</td>
		<td align="right" style="text-align:right;"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=report.add_ezgi_tufe"><img src="/images/plus1.gif" border="0" alt="Ekle"></a></td>
	</tr>
</table>
<table width="98%" border="0" align="center" cellpadding="2" cellspacing="1" class="color-border">
	<tr class="color-row">
		<td width="200" valign="top">
			<cfinclude template="../query/get_ezgi_tufe.cfm">
			<cfinclude template="../display/list_ezgi_tufe.cfm">
		</td>
		<td valign="top">
		<table>
        	<cfform action="#request.self#?fuseaction=report.emptypopup_upd_ezgi_tufe" method="post" name="upd_tufe" enctype="multipart/form-data">
				<input type="hidden" name="tufe_id" value="<cfoutput>#get_tufe_id.tufe_id#</cfoutput>">
                <tr>
                    <td>Dönem</td>
                    <td>
                        <select name="tufe_month" style="width:75px;">
                            <option value="01" <cfif get_tufe_id.period_month eq '01'>selected</cfif>>Ocak</option>
                            <option value="02" <cfif get_tufe_id.period_month eq '02'>selected</cfif>>Şubat</option>
                            <option value="03" <cfif get_tufe_id.period_month eq '03'>selected</cfif>>Mart</option>
                            <option value="04" <cfif get_tufe_id.period_month eq '04'>selected</cfif>>Nisan</option>
                            <option value="05" <cfif get_tufe_id.period_month eq '05'>selected</cfif>>Mayıs</option>
                            <option value="06" <cfif get_tufe_id.period_month eq '06'>selected</cfif>>Haziran</option>
                            <option value="07" <cfif get_tufe_id.period_month eq '07'>selected</cfif>>Temmuz</option>
                            <option value="08" <cfif get_tufe_id.period_month eq '08'>selected</cfif>>Ağustos</option>
                            <option value="09" <cfif get_tufe_id.period_month eq '09'>selected</cfif>>Eylül</option>
                            <option value="10" <cfif get_tufe_id.period_month eq '10'>selected</cfif>>Ekim</option>
                            <option value="11" <cfif get_tufe_id.period_month eq '11'>selected</cfif>>Kasım</option>
                            <option value="12" <cfif get_tufe_id.period_month eq '12'>selected</cfif>>Aralık</option>
                        </select>
                        <select name="tufe_year">
                            <cfoutput query="get_period">
                                <option value="#PERIOD_YEAR#" <cfif get_tufe_id.period_year eq PERIOD_YEAR>selected</cfif>>#PERIOD_YEAR#</option>
                            </cfoutput>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td width="100">TÜFE Oranı *</td>
                    <td><cfsavecontent variable="message">Tüfe Oranı Girin</cfsavecontent>
                        <cfinput type="text" name="tufe_rate" style="width:50px;" value="#Tlformat(get_tufe_id.tufe_rate,2)#" maxlength="6" required="Yes" message="#message#">
                    </td>
                </tr>
                <tr>
                    <td width="100">ÜFE Oranı *</td>
                    <td><cfsavecontent variable="message">Üfe Oranı Girin</cfsavecontent>
                        <cfinput type="text" name="tefe_rate" style="width:50px;" value="#Tlformat(get_tufe_id.tefe_rate,2)#" maxlength="6" required="Yes" message="#message#">
                    </td>
                </tr>
                <tr height="35">
                <td></td>
                    <td>
                      	<cf_workcube_buttons is_upd='1' delete_page_url='#request.self#?fuseaction=report.emptypopup_del_ezgi_tufe&tufe_id=#url.tufe_id#'>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        
                    </td>
                </tr>
			</cfform>
		</table>
		</td>
	</tr>
</table>
<br>
