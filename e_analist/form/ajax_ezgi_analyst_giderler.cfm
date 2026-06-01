<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_ANALYST_BRANCH WHERE ANALYST_BRANCH_ID = #attributes.upd_id#
</cfquery>
<cfinclude template="../query/get_ezgi_branch_giderler.cfm">
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
    <cfoutput query="GET_HEDEF_CATEGORY">
        <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
            <td onclick="seviyelendir_demonte(#currentrow#)"><b>#EXPENSE_CAT_NAME#</b></td>
            <td style="text-align:right"><b>#TlFormat(GET_HEDEF_CATEGORY.GIDER,2)#</b></td>
            <td style="text-align:right"><b>#TlFormat(GET_HEDEF_CATEGORY.HEDEF,2)#</b></td>
            <td style="text-align:right"><b>#TlFormat(GET_HEDEF_CATEGORY.HEDEF - GET_HEDEF_CATEGORY.GIDER,2)#</b></td>
            <td style="text-align:center; color:white;background-color:<cfif GET_HEDEF_CATEGORY.GIDER gt 0 and GET_HEDEF_CATEGORY.HEDEF gt 0><cfif GET_HEDEF_CATEGORY.GIDER/GET_HEDEF_CATEGORY.HEDEF*100 lte 100>green<cfelse>red</cfif></cfif>"><b><cfif GET_HEDEF_CATEGORY.GIDER gt 0 and GET_HEDEF_CATEGORY.HEDEF gt 0>#TlFormat(GET_HEDEF_CATEGORY.GIDER/GET_HEDEF_CATEGORY.HEDEF*100,2)#<cfelse>0</cfif></b></td>
            <td ></td>
        </tr>
        <cfquery name="GET_HEDEF_ITEM" dbtype="query">
            SELECT * FROM GET_HEDEF WHERE EXPENSE_CAT_ID = #EXPENSE_CAT_ID#
        </cfquery>
        <cfif GET_HEDEF_ITEM.recordcount>
        	<cfloop query="GET_HEDEF_ITEM">
                <tr id="gizle_#GET_HEDEF_CATEGORY.currentrow#_#GET_HEDEF_ITEM.currentrow#" height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row" style="display:none">
                    <td>#EXPENSE_ITEM_NAME#</td>
                    <td style="text-align:right">#TlFormat(GET_HEDEF_ITEM.GIDER,2)#</td>
                    <td style="text-align:right">#TlFormat(GET_HEDEF_ITEM.HEDEF,2)#</td>
                    <td style="text-align:right">#TlFormat(GET_HEDEF_ITEM.HEDEF - GET_HEDEF_ITEM.GIDER,2)#</td>
                    <td style="text-align:center"><cfif GET_HEDEF_ITEM.GIDER gt 0 and GET_HEDEF_ITEM.HEDEF gt 0>#TlFormat(GET_HEDEF_ITEM.GIDER/GET_HEDEF_ITEM.HEDEF*100,2)#<cfelse>0</cfif></td>
                    <td ></td>
                </tr>
            </cfloop>
        </cfif>
    </cfoutput>
    <tr class="color-row">
    	<td colspan="8" align="right"></td>
	</tr>
</table>
<script language="javascript">
	function seviyelendir()
	{
		<cfif GET_HEDEF_CATEGORY.recordcount>
			<cfoutput query="GET_HEDEF_CATEGORY">
				seviyelendir_demonte(#currentrow#);
			</cfoutput>
		</cfif>
	}
	function seviyelendir_demonte(row_count)
	{
		for(i=1;i<=1000;i++)
		{
			if(document.getElementById('gizle_'+row_count+'_'+i) != undefined)
			{	
				if (document.getElementById('gizle_'+row_count+'_'+i).style.display == 'none')
				{
					document.getElementById('gizle_'+row_count+'_'+i).style.display = '';
				}
				else
				{
					document.getElementById('gizle_'+row_count+'_'+i).style.display = 'none';
				}
			}
		}
	}
</script>