<!---
    File: upd_ezgi_product_tree_creative_main_row_from_efurniturecad.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/04/2025
    Description:
--->
<cfparam name="attributes.status" default="2">
<cf_xml_page_edit>
<cfif not len(x_parca_1)>
	<script type="text/javascript">
    	alert("XML Ayarlarında Ahşap Yonga Levha için default parça ID tanımlanmamış. Sistem Yöneticinize Başvurun!");
 	</script>
 	<cfabort>
</cfif>
<cfif not len(x_parca_2)>
	<script type="text/javascript">
    	alert("XML Ayarlarında Genel Reçete Parçası için default parça ID tanımlanmamış. Sistem Yöneticinize Başvurun!");
 	</script>
 	<cfabort>
</cfif>
<cfif not len(x_parca_3)>
	<script type="text/javascript">
    	alert("XML Ayarlarında Montajlı Parça için default parça ID tanımlanmamış. Sistem Yöneticinize Başvurun!");
 	</script>
 	<cfabort>
</cfif>
<cfparam name="attributes.keyword" default="">
<cfset cad_dsn3 = '#dsn#_efurniturecad_#session.ep.company_id#'>
<cfquery name="get_efurniturecad" datasource="#cad_dsn3#">
	SELECT 
    	WA_PRODUCT_TREE_ID, 
        USER_NAME, 
        PRODUCT_TREE_NAME, 
        TYPE, 
        DETAIL, 
        PICTURE, 
        E_DESIGN_MAIN_ROW_ID, 
        IS_ACTIVE
	FROM     
    	dbo.WORKCUBE_AUTOCAD_PRODUCT_TREE
 	WHERE
    	WRK_ROW_ID IS NULL AND
    	E_DESIGN_MAIN_ROW_ID IS NULL
		<cfif attributes.status eq 2>
			AND ISNULL(IS_ACTIVE,0) = 1
		<cfelseif attributes.status eq 3>
			AND ISNULL(IS_ACTIVE,0) = 0
		</cfif>
        <cfif len(attributes.keyword)>
        	AND PRODUCT_TREE_NAME LIKE '%#attributes.keyword#%'
        </cfif>
</cfquery>

<cfsavecontent variable="message"><cf_get_lang dictionary_id="1369.E-Furniture CAD"></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#message#" hide_table_column="1" collapsable="0">
		<cfform name="search_form" id="search_form" method="post" action="#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_main_row_from_efurniturecad">
			<cfinput type="hidden" name="design_main_row_id" value="#attributes.design_main_row_id#">	
			<cfsavecontent  variable="filtre"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
    		<cf_box_search>
                <div class="form-group">
                    <cfinput type="text" name="keyword"  placeholder="#filtre#" value="#attributes.keyword#" maxlength="255">
                </div>
				<div class="form-group">
					<select name="status" id="status" style="width:100px;">
						<option value="1" <cfif attributes.status eq 1>selected</cfif>><cf_get_lang dictionary_id="57708.Tümü"></option>
						<option value="2" <cfif attributes.status eq 2>selected</cfif>><cf_get_lang dictionary_id="57493.Aktif"></option>
						<option value="3" <cfif attributes.status eq 3>selected</cfif>><cf_get_lang dictionary_id="57494.Pasif"></option>
					</select>
				</div>
                <div class="form-group">
                    <cf_wrk_search_button button_type="4">
                </div>
    		</cf_box_search>
		</cfform>
		<cf_grid_list>
			<thead>
				<tr>
					<th width="20"><cf_get_lang dictionary_id="58577.Sıra"></th>
                    <th><cf_get_lang dictionary_id="1369.E-Furniture CAD"> <cf_get_lang dictionary_id="57897.Adı"></th>
                    <th><cf_get_lang dictionary_id="57629.Açıklama"></th>
                    <th><cf_get_lang dictionary_id="57899.Kaydeden"></th>
                    <th><cf_get_lang dictionary_id="57493.Aktif"></th>
                    <th width="20"></th>
				</tr>
			</thead>
			<tbody>
				<cfif get_efurniturecad.recordcount>
                	<input type="hidden" id="selected_id" name="selected_id" value="">
					<cfoutput query="get_efurniturecad">
						<tr>
							<td style="text-align:right">#currentrow#</td>
                            <td>#PRODUCT_TREE_NAME#</td>
                            <td>#DETAIL#</td>
                            <td>#USER_NAME#</td>
							<td style="text-align:center">
                            	<input type="checkbox" name="IS_ACTIVE_#WA_PRODUCT_TREE_ID#" id="is_active_#WA_PRODUCT_TREE_ID#" value="#IS_ACTIVE#" <cfif IS_ACTIVE eq 1>checked</cfif> onchange="efurniturecad_status_change(#WA_PRODUCT_TREE_ID#);">
                            </td>
                            <td style="text-align:center">
                            	<input type="radio" name="WA_PRODUCT_TREE_ID" id="wa_product_tree_id" value="#WA_PRODUCT_TREE_ID#" onclick="display_button(#WA_PRODUCT_TREE_ID#);" />
                            </td>
						</td>
					</cfoutput>
                    <tfoot id="save_button" style="display:none">
                    	<tr>
                        	<td colspan="5" style="text-align:right">
                            	<button style="height:30px; width:100px; background-color:orange; color:white; font-weight:bold" onclick="efurniturecad_save()">Kaydet</button>
                            </td>
                        </tr>
                    </tfoot>
				<cfelse>
					<tr>
						<td colspan="5"><cfif isdefined("attributes.form_submitted")><cf_get_lang dictionary_id="58486.Kayıt Bulunamadı"> !<cfelse><cf_get_lang_main no='289.Filtre Ediniz '> !</cfif></td>
					</tr>
				</cfif>
			</tbody>
		</cf_grid_list>
	</cf_box>
</div>
<script type="text/javascript">
	$(document).ready(function(){

    $( "#keyword" ).focus();

});
	function display_button(selected_id)
	{
		document.getElementById('save_button').style.display='';
		document.getElementById('selected_id').value=selected_id;
	}
	function efurniturecad_save()
	{
		efurniturecad_id = document.getElementById('selected_id').value;
		sor = confirm('Transfer İşlemine Başlıyorum?')
		if(sor==true)
			window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_upd_ezgi_product_tree_creative_main_row_from_efurniturecad&design_main_row_id=#attributes.design_main_row_id#&parca_1=#x_parca_1#&parca_2=#x_parca_2#&parca_3=#x_parca_3#</cfoutput>&efurniturecad_id="+efurniturecad_id;
		else
			return false
	}
	function efurniturecad_status_change(wa_product_tree_id)
	{
		if(document.getElementById('is_active_'+wa_product_tree_id).checked)
			status = 1;
		else
			status = 0;
		sor = confirm('Aktiflik Durumunu Değiştirmek İstiyormusunuz? ')
		if(sor===true)
			window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_upd_ezgi_product_tree_creative_main_row_from_efurniturecad&design_main_row_id=#attributes.design_main_row_id#</cfoutput>&status="+status+"&efurniturecad_id="+wa_product_tree_id;
		else
			return false
	}
</script>
