<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_ANALYST_BRANCH WHERE ANALYST_BRANCH_ID = #attributes.upd_id#
</cfquery>
<cfinclude template="../query/get_ezgi_branch_sonuc.cfm">
<table cellspacing="1" cellpadding="2" width="100%" border="0" class="color-border">
  	<tr class="color-list" height="22">
    	<td class="txtboldblue" nowrap>Açıklama</td>
      	<td class="txtboldblue" width="100" >Net Satışlar</td>
        <td class="txtboldblue" width="80" nowrap>SMM</td>
        <td class="txtboldblue" width="80" nowrap>Brüt Kar</td>
        <td class="txtboldblue" width="50" nowrap style="text-align:center">(%)</td>
        <td class="txtboldblue" width="100" nowrap>Faaliyet Giderleri</td>
        <td class="txtboldblue" width="80" nowrap>Faaliyet Karı</td>
        <td class="txtboldblue" width="50" nowrap style="text-align:center">(%)</td>
        <td width="20" align="center"></td>
  	</tr>
    <cfoutput>
        <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
        	<td style="text-align:left"><b><cfif get_upd.IS_BRANCH eq 0>Merkez ve Şubeler Durumu<cfelse>Şube Durumu</cfif></b></td>
            <td style="text-align:right"><b>#TlFormat(sonuc_total_sales,2)#</b></td>
            <td style="text-align:right"><b>#TlFormat(sonuc_smm,2)#</b></td>
            <td style="text-align:right"><b>#TlFormat(sonuc_total_sales-sonuc_smm,2)#</b></td>
            <td style="text-align:center"><b><cfif sonuc_total_sales gt 0>#TlFormat((sonuc_total_sales-sonuc_smm)/sonuc_total_sales*100,0)#<cfelse>0</cfif></b></td>
            <td style="text-align:right"><b>#TlFormat(sonuc_total_expense,2)#</b></td>
            <td style="text-align:right"><b>#TlFormat(sonuc_total_sales-sonuc_smm-sonuc_total_expense,2)#</b></td>
            <td style="text-align:center"><b><cfif sonuc_total_sales gt 0>#TlFormat((sonuc_total_sales-sonuc_smm-sonuc_total_expense)/sonuc_total_sales*100,0)#<cfelse>0</cfif></b></td>
            <td ></td>
        </tr>
        <cfif get_upd.IS_BRANCH eq 0 and get_sonuc_detail.recordcount>
        	<cfloop query="get_sonuc_detail">
             	<tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                    <td style="text-align:left"><cfif INCOME eq 2>Merkez<cfelse>#Branch_name#</cfif></td>
                    <td style="text-align:right">#TlFormat(get_sonuc_detail.TOTAL_SALES,2)#</td>
                    <td style="text-align:right">#TlFormat(SMM,2)#</td>
                    <td style="text-align:right">#TlFormat(get_sonuc_detail.TOTAL_SALES-get_sonuc_detail.SMM,2)#</td>
                    <td style="text-align:center"><cfif get_sonuc_detail.TOTAL_SALES gt 0>#TlFormat((get_sonuc_detail.TOTAL_SALES-get_sonuc_detail.SMM)/get_sonuc_detail.TOTAL_SALES*100,0)#<cfelse>0</cfif></td>
                    <td style="text-align:right">#TlFormat(get_sonuc_detail.expense_gider,2)#</td>
                    <td style="text-align:right">#TlFormat(get_sonuc_detail.TOTAL_SALES-get_sonuc_detail.SMM-get_sonuc_detail.expense_gider,2)#</td>
                    <td style="text-align:center"><cfif get_sonuc_detail.TOTAL_SALES gt 0>#TlFormat((get_sonuc_detail.TOTAL_SALES-get_sonuc_detail.SMM-get_sonuc_detail.expense_gider)/get_sonuc_detail.TOTAL_SALES*100,0)#<cfelse>0</cfif></td>
                    <td style="text-align:center;">
                    	<cfif get_upd.STATUS neq 1> <!---Kilitli Değil İse--->
							<cfif BRANCH_ID gt 0>
                                <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=report.popup_upd_ezgi_analyst_gelirler_row&upd_id=#ANALYST_BRANCH_ID#','longpage');">
                                    <img src="images/palet.gif" border="0" title="Gelir Detayı" />
                                </a>
                            <cfelseif BRANCH_ID eq 0>      
                                <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=report.popup_upd_ezgi_analyst_gelirler_row&upd_id=#attributes.upd_id#','longpage');">
                                    <img src="images/palet.gif" border="0" title="Gelir Detayı" />
                                </a>
                            </cfif>
                        </cfif>
                    </td>
                </tr>
            </cfloop>
        </cfif>
    </cfoutput>
</table>
