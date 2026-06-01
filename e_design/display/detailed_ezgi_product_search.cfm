<!---
    File: detailed_ezgi_product_search.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.mode" default="4">
<table class="nohover">
	<cfoutput>
		<cfset a=0>
		<cfloop from="1" to="#get_property_var.recordcount#" index="row">
			<cfif ((a mod attributes.mode is 0)) or (a eq 0)><tr id="frm_row#row#"></cfif>
			<cfif get_property_var.property_id[row] neq get_property_var.property_id[row-1]>
				<td>
					<input type="hidden" name="row_kontrol#row#" id="row_kontrol#row#" value="1">
					<input type="hidden" name="property_id#row#" id="property_id#row#" value="#get_property_var.property_id[row]#">
					<select name="variation_id#row#" id="variation_id#row#" style="width:150px;">
						<option value="">#get_property_var.property[row]#</option>
						<cfloop from="#row#" to="#get_property_var.recordcount#" index="str">
							<cfif get_property_var.property_id[row] eq get_property_var.property_id[str]>
								<option value="#get_property_var.property_detail_id[str]#" <cfif isDefined("attributes.variation_id#row#") and Evaluate("attributes.variation_id#row#") eq get_property_var.property_detail_id[str]>selected</cfif>>#get_property_var.property_detail[str]#</option>
							<cfelse>
								<cfbreak>
							</cfif>
						</cfloop>
					</select>
					<cfset a=a+1>
				</td>
			</cfif>
			<cfif ((a mod attributes.mode eq 0)) or (a eq get_property_var.recordcount)></tr></cfif>
		</cfloop>
	</cfoutput>
</table>