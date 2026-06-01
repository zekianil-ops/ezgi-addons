      <cfset attributes.graph_type = 'bar'>
      <table cellspacing="1" cellpadding="2" border="0" width="98%" height="100%" class="color-border" align="center">
        <tr class="color-row"> 
          <td height="25" align="right" style="text-align:right;"> 
          </td>
        </tr>
		<tr bgcolor="#FFFFFF">
          <td> 
			<cfif isdefined("form.graph_type") and len(form.graph_type)>
                <cfset graph_type = form.graph_type>
            <cfelse>
                <cfset graph_type = "bar">
            </cfif>
            <cfset my_height = ((3*20)+90)>
            <cfset renkler = 'green,red,blue'>
			 <cfchart show3d="yes" labelformat="number" format="jpg" chartheight="#my_height#" chartwidth="220"> 
				<cfchartseries type="#graph_type#" itemcolumn="deneme1" colorlist="#renkler#"> 
                   	<cfchartdata item="Gelirler"  value="#net_total-total_smm#">
                    <cfchartdata item="Giderler" value="#expense_gider#">
                    <cfchartdata item="Kar/Zarar" value="#net_total-total_smm-expense_gider#">
				</cfchartseries>
			</cfchart> 
          </td>
        </tr>
      </table>