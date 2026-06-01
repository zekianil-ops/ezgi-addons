<!---
    File: dsp_ezgi_private_design_main_row.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_design_main_row" datasource="#dsn3#">
	SELECT
    	EDMR.*,
    	O.OFFER_NUMBER, 
        O.OFFER_ID, 
        OFR.PRODUCT_NAME2
	FROM            
    	OFFER_ROW AS OFR INNER JOIN
   		OFFER AS O ON OFR.OFFER_ID = O.OFFER_ID RIGHT OUTER JOIN
   		EZGI_DESIGN_MAIN_ROW AS EDMR ON OFR.WRK_ROW_ID = EDMR.WRK_ROW_RELATION_ID
	WHERE        
    	EDMR.DESIGN_ID = #attributes.design_id#
	ORDER BY 
    	OFR.OFFER_ROW_ID
</cfquery>
<cfsavecontent  variable="modüller">
	<cf_get_lang dictionary_id='38748.Modüller'>
</cfsavecontent>            
<cf_seperator title="#modüller#" id="sarf_" is_closed="1">
<div id="sarf_">
    <cf_form_list id="table2">
        <thead>
            <tr style="height:30px">
                <th style="width:20px;text-align:center;cursor: pointer" onclick="imp_main_row();"><img src="/images/workdevxml.gif" style="text-align:center" title="<cf_get_lang dictionary_id='218.Stok Kartı'>"></th>
                <th style="text-align:left; width:100%;cursor: pointer" onclick="imp_main_row();"><cf_get_lang dictionary_id="44019.Ürün"></th>
                <th width="20px" style="text-align:center;cursor: pointer">
                	<span class="icn-md icon-add" onclick="add_main_row();" title="<cf_get_lang dictionary_id='54.Modül Ekle'>"></span>
              	</th>
            </tr>
        </thead>
        <tbody>
			<cfoutput query="get_design_main_row">
                <tr id="frm_row_exit#currentrow#">
                    <td style="text-align:center;cursor: pointer;<cfif isdefined('attributes.design_main_row_id') and attributes.design_main_row_id eq DESIGN_MAIN_ROW_ID>background-color:LightGray</cfif>" <cfif not DESIGN_MAIN_ROW_ID gt 0>onclick="imp_main_row(#DESIGN_MAIN_ROW_ID#);"</cfif>>
                    	<cfif not len(OFFER_ID)>
                        	<img src="/images/ship_delivery.gif" style="text-align:center" title="<cf_get_lang dictionary_id='57909.İlişkilendir'>">
                        <cfelse>
							<cfif MAIN_SPECT_RELATED_ID gt 0>
                            	<span class="icn-md icon-check" title="<cf_get_lang dictionary_id='218.Stok Kartı'>"   onClick="windowopen('#request.self#?fuseaction=objects.popup_detail_product&sid=#DESIGN_MAIN_RELATED_ID#','list');"></span>
                            <cfelse>
                                #currentrow#
                            </cfif>
                        </cfif>                    
                   	</td>
                    <td title="#DESIGN_MAIN_NAME# - #PRODUCT_NAME2#" style="text-align:left;cursor: pointer;<cfif isdefined('attributes.design_main_row_id') and attributes.design_main_row_id eq DESIGN_MAIN_ROW_ID>background-color:LightGray</cfif>" nowrap onclick="imp_main_row(#DESIGN_MAIN_ROW_ID#);">#DESIGN_MAIN_NAME#</td>
                    <td style="text-align:center;cursor: pointer;<cfif isdefined('attributes.design_main_row_id') and attributes.design_main_row_id eq DESIGN_MAIN_ROW_ID>background-color:LightGray</cfif>">
                    	<i onclick="upd_main_row(#DESIGN_MAIN_ROW_ID#);" class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i>
               		</td>
                </tr>
            </cfoutput>
       </tbody>
    </cf_form_list>
</div>
<script type="text/javascript">
	function add_main_row()
	{
		windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_private_product_tree_creative_main_row&design_id=#attributes.design_id#&process_id=#get_design.PROCESS_ID#</cfoutput>','longpage');
	}
	function upd_main_row(main_row_id)
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_upd_ezgi_product_tree_creative_main_row&design_main_row_id='+main_row_id,'small');	
	}
</script>