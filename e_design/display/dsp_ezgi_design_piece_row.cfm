<!---
    File: dsp_ezgi_design_piece_row.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfparam name="attributes.piece_type_select" default="">
<cfparam name="attributes.piece_name_search" default="">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.startrow" default="1">
<cfset attributes.maxrows = 150 />

<cfset piece = createObject("component","AddOns.ezgi.cfc.piece") />
<cfset get_piece_row = piece.get_piece(
    design_package_row_id: attributes.design_package_row_id?:'',
    design_main_row_id: attributes.design_main_row_id?:'',
    design_id: attributes.design_id?:'',
    piece_type_select: attributes.piece_type_select?:'',
	piece_name_search: attributes.piece_name_search?:'',
    sort_id: attributes.sort_id?:'',
    startrow: attributes.startrow,
    maxrows: attributes.maxrows
) />

<!---ERP üzerinde Parça Stok Kartları da açılacaksa Aynı İsimli Kart Varmı--->
<cfif get_design.PROCESS_ID eq 1>
	<cfoutput query="get_piece_row">
        <cfset renk_adi = ''>
        <cfif isdefined('COLOR_NAME_#PIECE_COLOR_ID#')><cfset renk_adi = Evaluate('COLOR_NAME_#PIECE_COLOR_ID#')></cfif>
        <cfset urun_adi = '#get_design.design_name# #PIECE_NAME# (#renk_adi#)'> 
		<cfquery name="get_same_product" datasource="#dsn3#">
        	SELECT STOCK_ID FROM STOCKS WHERE PRODUCT_NAME = '#urun_adi#'
        </cfquery>
        <cfif get_same_product.recordcount>
			<cfset 'same#PIECE_ROW_ID#' = urun_adi>
        </cfif>
	</cfoutput>
</cfif>
<cfsavecontent  variable="piece">
    <cf_get_lang dictionary_id='61.Parçalar'>
</cfsavecontent>
<cfsavecontent  variable="right_images">
	<cfoutput>
      	<span class="icn-md icon-trash-o" style="cursor:pointer;" onclick="design_delete_row();" title="<cf_get_lang dictionary_id="57463.Sil">"></span>&nbsp;&nbsp;
    	<cfif isdefined('attributes.design_main_row_id')>
         	<span class="icn-md icon-copy" style="cursor:pointer;" onclick="cpy_piece();" title="<cf_get_lang dictionary_id="57476.Kopyala">"></span>&nbsp;&nbsp;
      		<span class="icn-md icon-add" style="cursor:pointer;" onclick="add_piece_row();" title="<cf_get_lang dictionary_id="44630.Ekle">"></span>&nbsp;&nbsp;
     	</cfif>
      	<cfif isdefined('attributes.design_main_row_id')>
        	<span class="icn-md icon-exchange" style="cursor:pointer;" onclick="add_import_piece_row();" title="<cf_get_lang dictionary_id='58568.Transfer'>"></span>&nbsp;&nbsp;
       	 </cfif>
    	<a href="javascript://" onClick="setHideShow();gizle_goster(creative_detail);connectAjax();gizle_goster_nested('tasarim_goster','tasarim_gizle');">
         	<img id="tasarim_goster" style="cursor:pointer;" src="/images/list_minus.gif" title="<cf_get_lang dictionary_id='47.Malzeme ve İşçilik Bilgileri'> <cf_get_lang dictionary_id='58596.Göster'>">
        	<img id="tasarim_gizle" style="cursor:pointer;display:none;" src="/images/list_plus.gif" title="<cf_get_lang dictionary_id='47.Malzeme ve İşçilik Bilgileri'> <cf_get_lang dictionary_id='58628.Gizle'>">
  		</a>&nbsp;&nbsp;
	</cfoutput>
</cfsavecontent>
<!---<cf_seperator >--->
<cf_box title="#piece#" id="piece_" right_images="#right_images#">
    <div id="piece_">
        <cf_form_list  id="table6">
            <thead>
                <tr>
                    <th style="width:20px;"></th>
                    <th style="text-align:center;width:30px;height:20px;cursor:pointer;"><cf_get_lang dictionary_id="58577.Sıra"></th>
                    <th style="text-align:center;width:30px;cursor:pointer;">&nbsp;<cf_get_lang dictionary_id="835.ÜK">&nbsp;</th>
                    <th style="text-align:center;width:30px;cursor:pointer;">
                        <select name="piece_type_select" id="piece_type_select" style="width:30px; height:20px" onchange="piece_type_select_(this.value);">
                            <option value="" <cfif attributes.piece_type_select eq ''>selected</cfif>><cf_get_lang dictionary_id="39076.Tüm"></option>
                            <option value="1" <cfif attributes.piece_type_select eq 1>selected</cfif>><cf_get_lang dictionary_id="207.YNG"></option>
                            <option value="2" <cfif attributes.piece_type_select eq 2>selected</cfif>><cf_get_lang dictionary_id="208.GNL"></option>
                            <option value="3" <cfif attributes.piece_type_select eq 3>selected</cfif>><cf_get_lang dictionary_id="209.MNJ"></option>
                            <option value="4" <cfif attributes.piece_type_select eq 4>selected</cfif>><cf_get_lang dictionary_id="210.HAM"></option>
                        </select>
                    </th>
                    <th style="text-align:center;width:30px;cursor:pointer;" onclick="sort_piece_row(5);"><cf_get_lang dictionary_id="58585.Kod"></th>
                    <th style="text-align:left;width:200px;cursor:pointer;">
                    	<span style="width:30%" onclick="sort_piece_row(2);">
                        	<cf_get_lang dictionary_id="44019.Ürün">
                       	</span> 
                    	<input type="text" id="piece_name_search" name="piece_name_search" value="<cfoutput>#attributes.piece_name_search#</cfoutput>" style="width:70%; height:20px; border:none;background-color:LightGray;">
                        <span style="width:30%">
                        	<i onclick="serch_piece_row();" class="icn icon-search" title="<cf_get_lang dictionary_id='57565.Ara'>"></i>
                       	</span>
                    </th>
                    <th style="text-align:center;width:40px;cursor:pointer;" onclick="sort_piece_row(1);"><cf_get_lang dictionary_id="99.Boy"></th>
                    <th style="text-align:center;width:40px;cursor:pointer;" onclick="sort_piece_row(6);"><cf_get_lang dictionary_id="98.En"></th>
                    <th style="text-align:center;width:30px;cursor:pointer;" onclick="sort_piece_row(7);"><cf_get_lang dictionary_id="211.Kln"></th>
                    <th style="text-align:center;width:40px;cursor:pointer;" onclick="sort_piece_row(8);"><cf_get_lang dictionary_id="212.Mik"></th>
                    <th style="text-align:center;width:90px;cursor:pointer;" onclick="sort_piece_row(3);"><cf_get_lang dictionary_id="199.Renk"></th>
                    <th style="text-align:center;width:30px;cursor:pointer;" onclick="sort_piece_row(9);"><cf_get_lang dictionary_id="213.Dsn"></th>
                    <th style="text-align:center;width:30px;cursor:pointer;" onclick="sort_piece_row(4);"><cf_get_lang dictionary_id="839.PNo"></th>
                    <th style="text-align:center;width:30px;cursor:pointer;"><cf_get_lang dictionary_id="214.RF"></th>
                    <th style="text-align:center;<cfif not isdefined('attributes.design_package_row_id') and isdefined('attributes.design_main_row_id') and not get_piece_row.recordcount>width:60px;<cfelse>width:20px;</cfif>" nowrap="nowrap"></th>
                    <th style="text-align:center;<cfif not isdefined('attributes.design_package_row_id') and isdefined('attributes.design_main_row_id') and not get_piece_row.recordcount>width:30px;<cfelse>width:20px;</cfif>" nowrap="nowrap">
                        <input type="checkbox" name="all_piece" id="all_piece" onClick="javascript: wrk_select_piece('all_piece','select_piece_row',<cfoutput>#get_piece_row.recordcount#</cfoutput>);">
                    </th>
                </tr>
            </thead>
            <tbody class="sorter">
            <cfoutput query="get_piece_row">
                <tr id="frm_row_exit#currentrow#_piece" data-piece_row_id="#PIECE_ROW_ID#">
                    <td style="text-align: center; padding: 0 10px; width:20px;"><cfif not len(PACKAGE_NUMBER) and not PACKAGE_PARTNER_ID gt 0 and USED_AMOUNT eq 0 and isdefined('attributes.design_main_row_id')><span class="icn-md icon-align-justify handle"></span></cfif></td>
                    <td nowrap="nowrap" title="<cfif PACKAGE_PARTNER_ID gt 0><cf_get_lang dictionary_id="64.Ortak Paket Parçası"></cfif>" style="text-align:right;width:30px;cursor: pointer; vertical-align:middle;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif>">
                        <input type="hidden" name="new_stock_id_3_#PIECE_ROW_ID#" id="new_stock_id_3_#PIECE_ROW_ID#" value="">
                        <input type="hidden" name="new_product_id_3_#PIECE_ROW_ID#" id="new_product_id_3_#PIECE_ROW_ID#" value="">
                        <cfif PIECE_TYPE eq 1 or PIECE_TYPE eq 2>
                            <span class="icn-md icon-copy" style="cursor:pointer;" onclick="copy_piece_row(#PIECE_ROW_ID#);" title="<cf_get_lang dictionary_id='57476.Kopyala'>"></span>
                        </cfif>
                        #currentrow#
                    </td>
                    <td style="text-align:center;width:30px;cursor:pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;<cfelse><cfif PACKAGE_PARTNER_ID gt 0>background-color:MistyRose;<cfelse><cfif ORTAK_PARCA gt 1>background-color:Gainsboro;</cfif></cfif></cfif>">
                        <cfif PIECE_RELATED_ID gt 0>
                            <span class="icn-md icon-check" title="<cfif PACKAGE_PARTNER_ID gt 0><cf_get_lang dictionary_id="64.Ortak Paket Parçası"><cfelse><cfif ORTAK_PARCA gt 1><cf_get_lang dictionary_id="63.Ortak Parça"><cfelse> <cf_get_lang dictionary_id="218.Stok Kartı"></cfif></cfif>" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_detail_product&sid=#PIECE_RELATED_ID#','large')"></span>
                        <cfelseif PACKAGE_PARTNER_ID lte 0>
                            <span class="icn-md icon-link" style="cursor:pointer;" title="<cf_get_lang dictionary_id="840.Stok Kartı İlişkilendir">" onclick="relation_product_row(3,#PIECE_ROW_ID#)"></span>
                        </cfif>
                    </td>
                    <td style="text-align:center;width:30px;cursor:pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif>" onclick="imp_piece_row(#PIECE_ROW_ID#);">
                        <cfif PIECE_TYPE eq 1>
                            <img src="/images/butcegider.gif" title="<cf_get_lang dictionary_id='62.Yonga Levha'>">
                        <cfelseif PIECE_TYPE eq 2>
                            <img src="/images/arrow_up.png" title="<cf_get_lang dictionary_id='402.Genel Reçete'>">
                        <cfelseif PIECE_TYPE eq 3>
                            <img src="/images/elements.gif" title="<cf_get_lang dictionary_id='403.Montaj Ürünü'>">
                        <cfelseif PIECE_TYPE eq 4>
                            <img src="/images/promo_multi.gif" title="<cf_get_lang dictionary_id='404.Hammadde'>">
                        </cfif>
                    </td>
                    <td style="text-align:center;width:30px;cursor:pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">#PIECE_CODE#</td>
                    <td class="showing_drag" <cfif Len(PIECE_NAME) gt 28>title="#PIECE_NAME#"</cfif> style="text-align:left;width:200px;cursor: pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">
                        <input name="productname#currentrow#" type="text" readonly="readonly" value="#PIECE_NAME#" style="width:98%; border:none;cursor:pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif>">
                    </td>
                    <td style="text-align:center;width:40px;cursor:pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">#BOYU#</td>
                    <td style="text-align:center;width:40px;cursor:pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">#ENI#</td>
                    <td style="text-align:center;width:30px;cursor:pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">#KALINLIK_#</td>
                    <td style="text-align:center;width:40px;cursor:pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">#PIECE_AMOUNT#</td>
                    <td title="<cfif isdefined('COLOR_NAME_#PIECE_COLOR_ID#')><cfif Len(Evaluate('COLOR_NAME_#PIECE_COLOR_ID#')) gt 12>#Evaluate('COLOR_NAME_#PIECE_COLOR_ID#')#</cfif></cfif>" style="text-align:left;width:90px;cursor: pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">&nbsp;
                        <cfif isdefined('COLOR_NAME_#PIECE_COLOR_ID#')>&nbsp;#Evaluate('COLOR_NAME_#PIECE_COLOR_ID#')#&nbsp;</cfif>
                    </td>
                    <td style="text-align:center;width:30px;cursor:pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);">
                        <cfif PIECE_TYPE eq 1>
                            <cfif IS_FLOW_DIRECTION eq 0>
                                <img src="images/production/false.png" style="width:15px; height:15px" />
                            <cfelse>
                                <img src="images/production/true.png" style="width:15px; height:15px" />
                            </cfif>
                        </cfif>
                    </td>
                    <td class="package_number" style="text-align:center;width:30px;cursor:pointer;<cfif USED_AMOUNT neq 0><cfif USED_AMOUNT eq PIECE_AMOUNT>background-color:LimeGreen;<cfelseif USED_AMOUNT lt PIECE_AMOUNT>background-color:yellow;<cfelseif USED_AMOUNT gt PIECE_AMOUNT>background-color:coral;</cfif><cfelse><cfif not len(PACKAGE_NUMBER)>background-color:red;<cfelse><cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif></cfif></cfif>" nowrap onclick="imp_piece_row(#PIECE_ROW_ID#);"><cfif USED_AMOUNT neq 0>K-#USED_AMOUNT#<cfelse>#PACKAGE_NUMBER#</cfif></td>
                    <td style="text-align:center;width:30px;cursor:pointer;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif>" >
                        <cfif PIECE_TYPE neq 4>
                            <span class="fa fa-barcode" style="cursor:pointer;" onclick="dsp_piece_row(#PIECE_ROW_ID#);" title="<cf_get_lang dictionary_id='855.İş Emri Görünüm'>"></span>
                        </cfif>
                    </td>
                    <td style="text-align:center;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif>">
                        <cfif PACKAGE_PARTNER_ID gt 0>
                            <img src="/images/lock_buton.gif" title="<cf_get_lang dictionary_id='64.Ortak Paket Parçası'>">
                        <cfelse>
                            <i onclick="upd_piece_row(#PIECE_ROW_ID#);" class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i>
                        </cfif>
                    </td>
                    <td style="text-align:center;<cfif isdefined('attributes.design_piece_row_id') and attributes.design_piece_row_id eq PIECE_ROW_ID>background-color:LightGray;</cfif>">
                        <cfif PACKAGE_PARTNER_ID gt 0>
                        <cfelse>
                            <input type="checkbox" name="select_piece_row_#PIECE_ROW_ID#" value="#PIECE_ROW_ID#" id="select_piece_row#currentrow#" />
                        </cfif>
                    </td>
                </tr>
            </cfoutput>
            </tbody>
        </cf_form_list>
    </div>
</cf_box>
<script type="text/javascript">
	function add_piece_row()
	{
		<cfif isdefined('attributes.design_main_row_id')>
			windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_product_tree_creative_piece_row&design_main_row_id=#attributes.design_main_row_id#<cfif isdefined("attributes.design_package_row_id") and len(attributes.design_package_row_id)>&package_row_id=#attributes.design_package_row_id#</cfif></cfoutput>','list');
		</cfif>
	}
	function add_import_piece_row()
	{
		<cfif isdefined('attributes.design_main_row_id')>
			windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_product_tree_creative_import_piece_row&design_main_row_id=#attributes.design_main_row_id#</cfoutput>','small');
		</cfif>
	}
	function upd_piece_row(piece_row_id)
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_upd_ezgi_product_tree_creative_piece_row&design_piece_row_id='+piece_row_id,'list');
	}
	function copy_piece_row(piece_row_id)
	{
		window.location ="<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_cpy_ezgi_product_tree_creative_piece_row&design_piece_row_id="+piece_row_id;	
	}
	function dsp_piece_row(piece_row_id)
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_dsp_ezgi_product_tree_creative_piece_row&design_piece_row_id='+piece_row_id,'wide');
	}
	function cpy_piece()
	{
		<cfif isdefined('attributes.design_main_row_id')>
			windowopen("<cfoutput>#request.self#?fuseaction=prod.popup_cpy_ezgi_product_tree_creative_package_row&main=1&design_main_row_id=#attributes.design_main_row_id#&piece_name_search=#attributes.piece_name_search#&piece_type_select=#attributes.piece_type_select#&sort_id=#attributes.sort_id#<cfif isdefined("attributes.design_package_row_id") and len(attributes.design_package_row_id)>&package_row_id=#attributes.design_package_row_id#</cfif>"</cfoutput>,'list');
		</cfif>
	}
	function wrk_select_piece(all_piece,select_piece_row,number)
	{
		for(var pic_rws=1; pic_rws <= number; pic_rws++)
		{
			if(document.getElementById('select_piece_row'+pic_rws)==undefined)
			{
				
			}
			else
			{
				if(document.getElementById(all_piece).checked == true)
				{
					if(document.getElementById('select_piece_row'+pic_rws).checked == false)
						document.getElementById('select_piece_row'+pic_rws).checked = true;
				}
				else
				{
					if(document.getElementById('select_piece_row'+pic_rws).checked == true)
						document.getElementById('select_piece_row'+pic_rws).checked = false;
				}
			}
		}
	}
</script>