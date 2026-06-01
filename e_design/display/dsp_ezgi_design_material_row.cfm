<!---
    File: dsp_ezgi_design_material_row.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfsetting showdebugoutput="yes">
<cfinclude template="../query/get_ezgi_product_tree_creative_material.cfm">
<cfsavecontent  variable="malzeme_listesi">
    <cf_get_lang dictionary_id='37330.Malzeme Listesi'>
</cfsavecontent>
<cf_box  title="#malzeme_listesi#" id="material_">
    <div id="material_">
        <cf_grid_list sort="1" id="material_">
            <thead>
                <tr style="height:30px">
                    <th style="text-align:right;width:30px"><cf_get_lang dictionary_id="58577.Sıra"></th>
                    <th style="text-align:left;width:100%"><cf_get_lang dictionary_id="44019.Ürün"></th>
                    <th style="text-align:right;width:50px"><cf_get_lang dictionary_id="57635.Miktar"></th>  
                    <th style="text-align:left;width:30px"><cf_get_lang dictionary_id="57636.Birim"></th>             
                </tr>
            </thead>
            <tbody>
            <cfoutput query="get_material">
                <tr id="frm_row_exit#currentrow#">
                    <td style="text-align:right">#currentrow#&nbsp;</td>
                    <td title="#PRODUCT_NAME#" style="width:100%; height:15px">
                        <a href="javascript://" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_detail_product&pid=#product_id#&sid=#stock_id#','large');">
                            <input name="materialproductname#currentrow#" type="text" readonly="readonly" value="#PRODUCT_NAME#" style="width:100%; border:none;cursor:pointer;">
                        </a>
                    </td>
                    <td style="text-align:right;">#AmountFormat(AMOUNT)#&nbsp;</td>
                    <td style="text-align:left;" <cfif len(MAIN_UNIT) gte 2>title="#MAIN_UNIT#"</cfif>>&nbsp;#Left(MAIN_UNIT,2)#<cfif len(MAIN_UNIT) gt 2>.</cfif></td>
                </tr>
            </cfoutput>
           </tbody>
        </cf_grid_list>
    </div>
</cf_box>