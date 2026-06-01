<!---
    File: dsp_ezgi_design_main_row.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfsetting showdebugoutput="yes">
<cfquery name="get_design_main_row" datasource="#dsn3#">
	SELECT 
    	*,
        (
        	SELECT        
            	MAIN_ROW_SETUP_CODE
			FROM            
            	EZGI_DESIGN_MAIN_ROW_SETUP
			WHERE        
            	MAIN_ROW_SETUP_ID = EZGI_DESIGN_MAIN_ROW.MAIN_ROW_SETUP_ID
        ) AS CODE
  	FROM 
    	EZGI_DESIGN_MAIN_ROW 
  	WHERE 
    	DESIGN_ID = #attributes.design_id# 
  	ORDER BY 
    	CODE
</cfquery>
<cfsavecontent  variable="modüller">
	<cf_get_lang dictionary_id='38748.Modüller'>
</cfsavecontent>
<cf_box title="#modüller#" id="sarf_" >
    <div id="sarf_">
        <cf_grid_list sort="0" id="table2">
            <thead>
                <tr style="height:30px">
                    <th width="20px" style="text-align:center;cursor: pointer" onclick="imp_main_row();"></th>
                    <th style="text-align:left; width:100%;cursor: pointer" onclick="imp_main_row();"><cf_get_lang dictionary_id="44019.Ürün"></th>
                    <th width="20px" style="text-align:center;cursor: pointer">
                        <span class="icn-md icon-add" onclick="add_main_row();" title="<cf_get_lang dictionary_id='54.Modül Ekle'>"></span>
                    </th>
                </tr>
            </thead>
            <tbody>
                <cfoutput query="get_design_main_row">
                    <tr id="frm_row_exit#currentrow#">
                        <td style="text-align:right;cursor: pointer;<cfif isdefined('attributes.design_main_row_id') and attributes.design_main_row_id eq DESIGN_MAIN_ROW_ID>background-color:LightGray</cfif>" <cfif not DESIGN_MAIN_ROW_ID gt 0>onclick="imp_main_row(#DESIGN_MAIN_ROW_ID#);"</cfif>>
                            <cfif DESIGN_MAIN_RELATED_ID gt 0>
                                <span class="icn-md icon-check" title="<cf_get_lang dictionary_id='218.Stok Kartı'>" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_detail_product&sid=#DESIGN_MAIN_RELATED_ID#','large');"></span>
                            <cfelse>
                                <!---#currentrow#--->
                                 <span class="icn-md icon-link" style="cursor:pointer;" title="<cf_get_lang dictionary_id="840.Stok Kartı İlişkilendir">" onclick="relation_product_row(1,#DESIGN_MAIN_ROW_ID#)"></span>
                            </cfif>
                        </td>
                        <td title="#DESIGN_MAIN_NAME#" style="text-align:left;cursor: pointer;<cfif isdefined('attributes.design_main_row_id') and attributes.design_main_row_id eq DESIGN_MAIN_ROW_ID>background-color:LightGray</cfif>" nowrap onclick="imp_main_row(#DESIGN_MAIN_ROW_ID#);">#DESIGN_MAIN_NAME#</td>
                        <td style="text-align:center;cursor: pointer;<cfif isdefined('attributes.design_main_row_id') and attributes.design_main_row_id eq DESIGN_MAIN_ROW_ID>background-color:LightGray</cfif>">
                            <i onclick="upd_main_row(#DESIGN_MAIN_ROW_ID#);" class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i>
                        </td>
                    </tr>
                </cfoutput>
           </tbody>
        </cf_grid_list>
    </div>
</cf_box>
<script type="text/javascript">
	function add_main_row()
	{
		windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_product_tree_creative_main_row&design_id=#attributes.design_id#</cfoutput>','small');
	}
	function upd_main_row(main_row_id)
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_upd_ezgi_product_tree_creative_main_row&design_main_row_id='+main_row_id,'small');	
	}
</script>