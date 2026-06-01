<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_ANALYST_BRANCH WHERE ANALYST_BRANCH_ID = #attributes.upd_id#
</cfquery>
<cfinclude template="../query/get_ezgi_branch_gelirler.cfm">
<cfif len(get_sales_TOTAL.NETTOTAL)>
	<cfset satis_total = get_sales_TOTAL.NETTOTAL>
<cfelse>
	<cfset satis_total = 0>
</cfif>
<cfif len(get_hedef_sales.HEDEF)>
	<cfset satis_hedef = get_hedef_sales.HEDEF>
<cfelse>
	<cfset satis_hedef = 0>
</cfif>
<cfsetting showdebugoutput="no">
<table cellspacing="1" cellpadding="2" width="100%" border="0" class="color-border">
  	<tr class="color-list" height="22">
      	<td class="txtboldblue" >Açıklama</td>
        <td class="txtboldblue" width="120" nowrap>Gerçekleşen</td>
        <td class="txtboldblue" width="120" nowrap>Hedef</td>
        <td class="txtboldblue" width="120" nowrap>Fark</td>
        <td class="txtboldblue" width="80">Fark (%)</td>
        <td width="20" align="center"></td>
  	</tr>
    <cfoutput>
        <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
            <td onclick="seviyelendirme()"><b>Toplam Satışlar (Net - KDV Hariç)</b></td>
            <td style="text-align:right"><b>#TlFormat(satis_total,2)#</b></td>
            <td style="text-align:right"><b>#TlFormat(satis_hedef,2)#</b></td>
            <td style="text-align:right"><b>#TlFormat((satis_hedef - satis_total)*-1,2)#</b></td>
            <td style="text-align:center; <cfif satis_total gt 0>color:white<cfelse>color:black</cfif>;background-color:<cfif satis_total gt 0 and satis_hedef gt 0><cfif satis_total/satis_hedef*100 lt 50>red<cfelseif satis_total/satis_hedef*100 lt 100>orange<cfelse>green</cfif></cfif>"><b><cfif satis_total gt 0 and satis_hedef gt 0>#TlFormat(satis_total/satis_hedef*100,2)#<cfelse>0</cfif></b></td>
            <td >
            	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=report.popup_upd_ezgi_analyst_gelirler_row&upd_id=#attributes.upd_id#','longpage');">
          			<img src="images/palet.gif" border="0" title="Gelir Detayı" />
              	</a>
          	</td>
        </tr>
        <cfloop query="get_sales">
        	<tr id="gizleme_#get_sales.currentrow#" height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row" style="display:none">
            	<td>#PRODUCT_CAT#</td>
              	<td style="text-align:right">#TlFormat(NETTOTAL,2)#</td>
             	<td style="text-align:right"></td>
              	<td style="text-align:right"></td>
            	<td style="text-align:center"></td>
              	<td ></td>
          	</tr>
     	</cfloop>
    </cfoutput>
    <tr class="color-row">
    	<td colspan="8" align="right"></td>
	</tr>
    
</table>
<script language="javascript">
	function seviyelendirme()
	{
		var k = <cfoutput>#get_sales.recordcount#</cfoutput>;
		for(i=1;i<=k;i++)
		{
			if(document.getElementById('gizleme_'+i) != undefined)
			{	
				if (document.getElementById('gizleme_'+i).style.display == 'none')
				{
					document.getElementById('gizleme_'+i).style.display = '';
				}
				else
				{
					document.getElementById('gizleme_'+i).style.display = 'none';
				}
			}
		}
	}
</script>