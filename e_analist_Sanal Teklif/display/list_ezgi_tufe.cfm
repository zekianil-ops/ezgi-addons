<table width="200" cellpadding="0" cellspacing="0" border="0">
	<tr> 
		<td class="txtbold" height="20" colspan="4">&nbsp;&nbsp;Tüfe - Üfe Oranları</td>
	</tr>
    <tr>
    	<td width="100" align="left" valign="baseline" style="text-align:right;" colspan="2" class="txtbold">Dönem</td>
        <td width="40" align="right" valign="baseline" style="text-align:right;" class="txtbold">Tüfe</td>
        <td width="40" align="right" valign="baseline" style="text-align:right;" class="txtbold">Üfe</td>
    </tr>
	<cfif get_tufe.recordcount>
		<cfoutput query="get_tufe">
			<tr>
				<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif" width="13"></td>
				<td width="80"><a href="#request.self#?fuseaction=report.upd_ezgi_tufe&tufe_id=#tufe_id#" class="tableyazi">#period_month#/#period_year#</a></td>
				<td>#Tlformat(tufe_rate,2)#</td>
                <td>#Tlformat(tefe_rate,2)#</td>
            </tr>
		</cfoutput>
	<cfelse>
		<tr>
			<td width="20" align="right" valign="baseline" style="text-align:right;" ></td>
			<td width="180" colspan="3"><font class="tableyazi"><img src="/images/tree_1.gif" width="13"><cf_get_lang_main no='72.Kayıt Bulunamadı'>!</font></td>
		</tr>
	</cfif>
</table>
