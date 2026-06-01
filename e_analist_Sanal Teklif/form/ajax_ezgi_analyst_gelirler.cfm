<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_ANALYST_BRANCH WHERE ANALYST_BRANCH_ID = #attributes.upd_id#
</cfquery>
<cfinclude template="../query/get_ezgi_branch_gelirler.cfm">

<table cellspacing="1" cellpadding="2" width="100%" border="0" class="color-border">
	<tr class="color-list" height="22">
    	<td class="txtboldblue" rowspan="2" >Açıklama</td>
        <td class="txtboldblue" colspan="3" >Gerçekleşen</td>
        <td class="txtboldblue" colspan="3" >Hedef</td>
        <td class="txtboldblue" colspan="3" >Başarı</td>
        <td class="txtboldblue" colspan="2" >Sonuç</td>
        <td class="txtboldblue" width="20" rowspan="2"></td>
    </tr>
  	<tr class="color-list" height="22">
    	<td class="txtboldblue" width="90">Miktar</td>
		<td class="txtboldblue" width="90">Ciro</td>
        <td class="txtboldblue" width="90">Birim Satış</td>
        
        <td class="txtboldblue" width="90">Miktar</td>
		<td class="txtboldblue" width="90">Ciro</td>
        <td class="txtboldblue" width="90">Birim Satış</td>
        
        <td class="txtboldblue" width="90">Miktar</td>
		<td class="txtboldblue" width="90">Ciro</td>
        <td class="txtboldblue" width="90">Birim Satış</td>
        
        <td class="txtboldblue" width="90">Maliyet</td>
        <td class="txtboldblue" width="90">Karlılık</td>
  	</tr>
    <cfoutput>
        <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
            <td onclick="seviyelendirme()"><b>Toplam Satışlar (Net - KDV Hariç)</b></td>
            <td style="text-align:right"><b>#TlFormat(satis_quantity,2)#</b></td>
            <td style="text-align:right"><b>#TlFormat(satis_total,2)#</b></td>
            <td style="text-align:right"><b><cfif len(satis_total) and satis_quantity gt 0>#TlFormat(satis_total/satis_quantity,2)#<cfelse>#TlFormat(0,2)#</cfif></b></td>
            
            <td style="text-align:right"><b>#TlFormat(hedef_quantity,2)#</b></td>
            <td style="text-align:right"><b>#TlFormat(hedef_total,2)#</b></td>
            <td style="text-align:right"><b><cfif len(hedef_total) and hedef_quantity gt 0>#TlFormat(hedef_total/hedef_quantity,2)#<cfelse>#TlFormat(0,2)#</cfif></b></td>
            
            <td style="text-align:center; <cfif satis_quantity gt 0>color:white<cfelse>color:black</cfif>;background-color:<cfif satis_quantity gt 0 and hedef_quantity gt 0><cfif satis_quantity/hedef_quantity*100 lt 50>red<cfelseif satis_quantity/hedef_quantity*100 lt 100>orange<cfelse>green</cfif></cfif>"><b><cfif satis_quantity gt 0 and hedef_quantity gt 0>#TlFormat(satis_quantity/hedef_quantity*100,2)#<cfelse>#TlFormat(0,2)#</cfif></b></td>
            <td style="text-align:center; <cfif satis_total gt 0>color:white<cfelse>color:black</cfif>;background-color:<cfif satis_total gt 0 and hedef_total gt 0><cfif satis_total/hedef_total*100 lt 50>red<cfelseif satis_total/hedef_total*100 lt 100>orange<cfelse>green</cfif></cfif>"><b><cfif satis_total gt 0 and hedef_total gt 0>#TlFormat(satis_total/hedef_total*100,2)#<cfelse>#TlFormat(0,2)#</cfif></b></td>
            <td style="text-align:center; <cfif satis_total gt 0 and satis_quantity gt 0 and hedef_quantity gt 0 and hedef_total gt 0>color:white<cfelse>color:black</cfif>;background-color:<cfif satis_total gt 0 and satis_quantity gt 0 and hedef_quantity gt 0 and hedef_total gt 0><cfif (satis_total/satis_quantity)/(hedef_total/hedef_quantity)*100 lt 50>red<cfelseif (satis_total/satis_quantity)/(hedef_total/hedef_quantity)*100 lt 100>orange<cfelse>green</cfif></cfif>"><b><cfif satis_total gt 0 and satis_quantity gt 0 and hedef_quantity gt 0 and hedef_total gt 0>#TlFormat((satis_total/satis_quantity)/(hedef_total/hedef_quantity)*100,2)#<cfelse>#TlFormat(0,2)#</cfif></b></td>
            
            <td style="text-align:right"><b>#TlFormat(purchase_total,2)#</b></td>
            <td style="text-align:right"><b>#TlFormat(satis_total-purchase_total,2)#</b></td>
            <td style="text-align:center;">
            	<cfif get_upd.STATUS neq 1> <!---Kilitli Değil İse--->
            	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=report.popup_upd_ezgi_analyst_gelirler_row&upd_id=#attributes.upd_id#','longpage');">
          			<img src="images/palet.gif" border="0" title="Gelir Detayı" />
              	</a>
                </cfif>
          	</td>
        </tr>
        <cfif get_sales.recordcount gt 0>
            <cfloop query="get_sales">
                <tr id="gizleme_#get_sales.currentrow#" height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row" style="display:none;<cfif type eq 3>background-color:powderblue<cfelseif type eq 2>background-color:cornsilk</cfif>">
                    <td>#PRODUCT_CAT#</td>
                    
                    <td style="text-align:right">#TlFormat(QUANTITY,2)#</td>
                    <td style="text-align:right">#TlFormat(NETTOTAL,2)#</td>
                    <td style="text-align:right"><cfif len(NETTOTAL) and QUANTITY gt 0>#TlFormat(NETTOTAL/QUANTITY,2)#<cfelse>#TlFormat(0,2)#</cfif></td>
                    
                    <td style="text-align:right">#TlFormat(H_QUANTITY,2)#</td>
                    <td style="text-align:right">#TlFormat(H_NETTOTAL,2)#</td>
                    <td style="text-align:right"><cfif len(H_NETTOTAL) and H_QUANTITY gt 0>#TlFormat(H_NETTOTAL/H_QUANTITY,2)#<cfelse>#TlFormat(0,2)#</cfif></td>
                    
                    <td style="text-align:right"><cfif len(QUANTITY) and H_QUANTITY gt 0>#TlFormat(QUANTITY/H_QUANTITY*100,2)#<cfelse>#TlFormat(0,2)#</cfif></td>
                    <td style="text-align:right"><cfif len(NETTOTAL) and H_NETTOTAL gt 0>#TlFormat(NETTOTAL/H_NETTOTAL*100,2)#<cfelse>#TlFormat(0,2)#</cfif></td>
                    <td style="text-align:right"><cfif len(QUANTITY) and QUANTITY gt 0 and H_QUANTITY gt 0 and len(NETTOTAL) and NETTOTAL gt 0 and H_NETTOTAL gt 0>#TlFormat((NETTOTAL/QUANTITY)/(H_NETTOTAL/H_QUANTITY)*100,2)#<cfelse>#TlFormat(0,2)#</cfif></td>
                    
                    <td style="text-align:right">#TlFormat(PURCHASETOTAL,2)#</td>
                    <td style="text-align:right">#TlFormat(NETTOTAL-PURCHASETOTAL,2)#</td>
                    <td style="text-align:center;">
                    	<cfif get_upd.STATUS neq 1> <!---Kilitli Değil İse--->
                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=report.popup_upd_ezgi_analyst_gelirler_row&upd_id=#attributes.upd_id#&type=#type#&cat_id=#PRODUCT_CATID#','longpage');">
                            <img src="images/palet.gif" border="0" title="Gelir Detayı" />
                        </a>
                        </cfif>
                    </td>
                </tr>
            </cfloop>
        </cfif>
    </cfoutput>
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