<table width="98%" height="35" border="0" align="center" cellpadding="0" cellspacing="0" >
	<tr>
		<td  class="headbold">Tüfe Oranı Ekle</td>
	</tr>
</table>
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
<table width="98%" border="0" align="center" cellpadding="2" cellspacing="1" class="color-border">
	<tr class="color-row">
		<td width="200" valign="top">
			<cfinclude template="../query/get_ezgi_tufe.cfm">
			<cfinclude template="../display/list_ezgi_tufe.cfm">
		</td>
		<td valign="top">
		<table>
			<cfform action="#request.self#?fuseaction=report.emptypopup_add_ezgi_tufe" method="post" name="add_tufe" enctype="multipart/form-data">
			<tr>
				<td>Dönem</td>
				<td>
					<select name="tufe_month" style="width:75px;">
						<option value="01">Ocak</option>
                        <option value="02">Şubat</option>
                        <option value="03">Mart</option>
                        <option value="04">Nisan</option>
                        <option value="05">Mayıs</option>
                        <option value="06">Haziran</option>
                        <option value="07">Temmuz</option>
                        <option value="08">Ağustos</option>
                        <option value="09">Eylül</option>
                        <option value="10">Ekim</option>
                        <option value="11">Kasım</option>
                        <option value="12">Aralık</option>
					</select>
                    <select name="tufe_year">
                    	<cfoutput query="get_period">
                        	<option value="#PERIOD_YEAR#">#PERIOD_YEAR#</option>
                    	</cfoutput>
                    </select>
				</td>
			</tr>
			<tr>
				<td width="100">TÜFE Oranı *</td>
				<td><cfsavecontent variable="message">Tüfe Oranı Girin</cfsavecontent>
					<cfinput type="text" name="tufe_rate" style="width:50px;" value="" maxlength="6" required="Yes" message="#message#">
				</td>
			</tr>
			<tr>
				<td width="100">ÜFE Oranı *</td>
				<td><cfsavecontent variable="message">Üfe Oranı Girin</cfsavecontent>
					<cfinput type="text" name="tefe_rate" style="width:50px;" value="" maxlength="6" required="Yes" message="#message#">
				</td>
			</tr>
			<tr height="35">
				<td colspan="2" align="right" style="text-align:right;"><cf_workcube_buttons is_upd='0'></td>
			</tr>
			</cfform>
		</table>
		</td>
	</tr>
</table>
<br>
