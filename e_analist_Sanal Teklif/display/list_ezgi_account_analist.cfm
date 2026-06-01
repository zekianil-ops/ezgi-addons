<table width="98%" border="0" cellspacing="0" cellpadding="0" height="35" align="center">
    <tr>
        <td class="headbold">E-Analiz</td>
    </tr>
</table>
<table width="98%" border="0" align="center" cellpadding="2" cellspacing="1" class="color-border">
     <tr class="color-row">
        <td>
        	<table>
            	<tr class="txtbold" height="20"> 
                  <td colspan="2">&nbsp;&nbsp;Temel Tablolar</td>
                </tr>
                 <cfif not listfindnocase(denied_pages,'report.list_ezgi_bilanco_analist')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right; width:20"><img src="/images/tree_1.gif"></td>
						<td><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=report.list_ezgi_bilanco_analist&LIST_TYPE=1&REPORT_TYPE=9
" class="tableyazi">Mizan Tablosu</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'report.list_ezgi_bilanco_analist')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right; width:20"><img src="/images/tree_1.gif"></td>
						<td><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=report.list_ezgi_bilanco_analist&LIST_TYPE=1&REPORT_TYPE=10
" class="tableyazi">Detaylı Mizan Tablosu</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'report.list_ezgi_bilanco_analist')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right; width:20"><img src="/images/tree_1.gif"></td>
						<td><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=report.list_ezgi_bilanco_analist&LIST_TYPE=1&REPORT_TYPE=1
" class="tableyazi">Bilanço Tablosu</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'report.list_ezgi_bilanco_analist')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=report.list_ezgi_bilanco_analist&LIST_TYPE=1&REPORT_TYPE=2" class="tableyazi">Stok Girişleri</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'report.list_ezgi_bilanco_analist')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=report.list_ezgi_bilanco_analist&LIST_TYPE=1&REPORT_TYPE=3" class="tableyazi">Gelir Tablosu</a></td>
					</tr>
                </cfif>
                <tr class="txtbold" height="20"> 
                  <td colspan="2">&nbsp;&nbsp;Analizler</td>
                </tr>
                <cfif not listfindnocase(denied_pages,'report.list_ezgi_bilanco_analist')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=report.list_ezgi_bilanco_analist&LIST_TYPE=1&REPORT_TYPE=4" class="tableyazi">Bilanço Dikey Analiz
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'report.list_ezgi_bilanco_analist')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=report.list_ezgi_bilanco_analist&LIST_TYPE=1&REPORT_TYPE=5" class="tableyazi">Bilanço Trend Analiz
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'report.list_ezgi_bilanco_analist')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=report.list_ezgi_bilanco_analist&LIST_TYPE=1&REPORT_TYPE=6" class="tableyazi">Gelir Tablosu Dikey Analiz
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'report.list_ezgi_bilanco_analist')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=report.list_ezgi_bilanco_analist&LIST_TYPE=1&REPORT_TYPE=7" class="tableyazi">Gelir Tablosu Trend Analiz
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'report.list_rasyo_analiz')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=report.list_ezgi_rasyo_analist&LIST_TYPE=1&REPORT_TYPE=8" class="tableyazi">Rasyo Analiz
					</tr>
                </cfif>
                 <tr class="txtbold" height="20"> 
                  <td colspan="2">&nbsp;&nbsp;Tanımlar</td>
                </tr>
                <cfif not listfindnocase(denied_pages,'report.list_ezgi_bilanco_analist')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=report.add_ezgi_tufe" class="tableyazi">TÜFE - ÜFE Oranları
					</tr>
                </cfif>

            </table>
        </td>
    </tr>
</table>

