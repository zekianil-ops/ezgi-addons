<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_ANALYST_BRANCH WHERE ANALYST_BRANCH_ID = #attributes.upd_id#
</cfquery>
<cfinclude template="../query/get_ezgi_branch_gelirler.cfm">
<cfinclude template="../query/get_ezgi_branch_giderler.cfm">
<cfinclude template="../query/get_ezgi_branch_sonuc.cfm">
<cfsetting showdebugoutput="no">
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
    	<cfif len(get_TOTAL.SMM)>
        	<cfset total_smm = get_TOTAL.SMM>
        <cfelse>
        	<cfset total_smm = 0>
        </cfif>
        <cfif len(GET_TOTAL_EXPENSE.GIDER)>
        	<cfset expense_gider = GET_TOTAL_EXPENSE.GIDER>
        <cfelse>
        	<cfset expense_gider = 0>
        </cfif>
        <cfif len(GET_TOTAL.TOTAL_SALES)>
        	<cfset net_total = GET_TOTAL.TOTAL_SALES>
        <cfelse>
        	<cfset net_total = 0>
        </cfif>
        <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
        	<td style="text-align:left"><b><cfif get_upd.IS_BRANCH eq 0>Merkez ve Şubeler Durumu<cfelse>Şube Durumu</cfif></b></td>
            <td style="text-align:right"><b>#TlFormat(net_total,2)#</b></td>
            <td style="text-align:right"><b>#TlFormat(total_smm,2)#</b></td>
            <td style="text-align:right"><b>#TlFormat(net_total-total_smm,2)#</b></td>
            <td style="text-align:center"><b><cfif net_total gt 0>#TlFormat((net_total-total_smm)/net_total*100,0)#<cfelse>0</cfif></b></td>
            <td style="text-align:right"><b>#TlFormat(expense_gider,2)#</b></td>
            <td style="text-align:right"><b>#TlFormat(net_total-total_smm-expense_gider,2)#</b></td>
            <td style="text-align:center"><b><cfif net_total gt 0>#TlFormat((net_total-total_smm-expense_gider)/net_total*100,0)#<cfelse>0</cfif></b></td>
            <td ></td>
        </tr>
        <cfif get_upd.IS_BRANCH eq 0 and get_TOTAL_DETAIL.recordcount>
        	<cfloop query="get_TOTAL_DETAIL">
             	<tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                    <td style="text-align:left"><cfif INCOME eq 2>Merkez<cfelse>#Branch_name#</cfif></td>
                    <td style="text-align:right">
                    	<cfif BRANCH_ID gt 0>
                    	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=report.popup_dsp_ezgi_result_detail&upd_id=#attributes.upd_id#&branch_id=#BRANCH_ID#</cfoutput>','small');" class="tableyazi">
                    		#TlFormat(get_TOTAL_DETAIL.TOTAL_SALES,2)#
                      	</a>
                        <cfelse>
                        	#TlFormat(get_TOTAL_DETAIL.TOTAL_SALES,2)#
                        </cfif>
                    </td>
                    <td style="text-align:right">#TlFormat(SMM,2)#</td>
                    <td style="text-align:right">#TlFormat(get_TOTAL_DETAIL.TOTAL_SALES-get_TOTAL_DETAIL.SMM,2)#</td>
                    <td style="text-align:center"><cfif get_TOTAL_DETAIL.TOTAL_SALES gt 0>#TlFormat((get_TOTAL_DETAIL.TOTAL_SALES-get_TOTAL_DETAIL.SMM)/get_TOTAL_DETAIL.TOTAL_SALES*100,0)#<cfelse>0</cfif></td>
                    <td style="text-align:right">#TlFormat(get_TOTAL_DETAIL.expense_gider,2)#</td>
                    <td style="text-align:right">#TlFormat(get_TOTAL_DETAIL.TOTAL_SALES-get_TOTAL_DETAIL.SMM-get_TOTAL_DETAIL.expense_gider,2)#</td>
                    <td style="text-align:center"><cfif get_TOTAL_DETAIL.TOTAL_SALES gt 0>#TlFormat((get_TOTAL_DETAIL.TOTAL_SALES-get_TOTAL_DETAIL.SMM-get_TOTAL_DETAIL.expense_gider)/get_TOTAL_DETAIL.TOTAL_SALES*100,0)#<cfelse>0</cfif></td>
                    <td ></td>
                </tr>
            </cfloop>
        </cfif>
    </cfoutput>
    <tr class="color-row">
    	<td colspan="9" align="right"></td>
	</tr>
</table>
