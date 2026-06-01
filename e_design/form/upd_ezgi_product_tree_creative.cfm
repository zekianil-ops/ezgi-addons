<!---
    File: upd_ezgi_product_tree_creative.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.sort_id" default="5">
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK) ORDER BY COLOR_NAME
</cfquery>
<cfoutput query="get_colors">
	<cfset 'COLOR_NAME_#COLOR_ID#' = COLOR_NAME>
</cfoutput>
<cfset queryJSONConverter = createObject("component","cfc.queryJSONConverter") />
<cfset colorObject = replace(serializeJSON(queryJSONConverter.returnData(replace(serializeJSON(get_colors),"//",""))),"//","") />
<cfquery name="get_design" datasource="#dsn3#">
	SELECT  * FROM EZGI_DESIGN WITH (NOLOCK) WHERE DESIGN_ID = #attributes.design_id#
</cfquery>
<cfparam name="attributes.product_quantity" default="#get_design.product_quantity#">
<cfset iid = ''>
<cfif isdefined('attributes.design_id') and len(attributes.design_id)>
 	<cfset iid = '#iid#1-#attributes.design_id#,'>
</cfif>
<cfif isdefined('attributes.design_main_row_id') and len(attributes.design_main_row_id)>
 	<cfset iid = '#iid#2-#attributes.design_main_row_id#,'>
</cfif>
<cfif isdefined('attributes.design_package_row_id') and len(attributes.design_package_row_id)>
 	<cfset iid = '#iid#3-#attributes.design_package_row_id#,'>
</cfif>
<cfif isdefined('attributes.design_piece_row_id') and len(attributes.design_piece_row_id)>
 	<cfset iid = '#iid#4-#attributes.design_piece_row_id#,'>
</cfif>
<cfif right(iid,1) eq ','>
	<cfset iid = left(iid,len(iid)-1)>
</cfif>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
   <cf_box>
    	<cfform name="upd_design" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_product_tree_creative">
        	<cfinput name="design_id" id="design_id" value="#attributes.design_id#" type="hidden">
         	<cf_basket_form id="upd_design">
                <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
								<cf_box_elements>
                                    
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                                    	<div class="form-group" id="item-status">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                                            <div class="col col-8 col-xs-12">
                                                <input type="checkbox" name="is_active" id="is_active" value="1" <cfif get_design.status eq 1>checked</cfif>>
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-name">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='43440.Tasarım Adı'>*</label>
                                            <div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'>!</cfsavecontent>
                                                    <cfinput type="text" name="design_name" value="#get_design.design_name#" maxlength="200" required="Yes" message="#message#" style="width:150px; height:20px">
                                                    <span class="input-group-addon">
                                                        <cf_language_info 
                                                        table_name="EZGI_DESIGN" 
                                                        column_name="DESIGN_NAME" 
                                                        column_id_value="#attributes.design_id#" 
                                                        maxlength="500" 
                                                        datasource="#dsn3#" 
                                                        column_id="DESIGN_ID" 
                                                        control_type="0">
                                                    </span>
                                    			</div>
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-cat">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57486.Kategori'> *</label>
                                            <div class="col col-8 col-xs-12">
                                                <div class="input-group">
													<input type="hidden" name="old_product_catid" id="old_product_catid" value="<cfoutput>#get_design.product_catid#</cfoutput>">
                                                    <input type="hidden" name="product_cat_code" id="product_cat_code" value="<cfif len(get_design.product_cat)><cfoutput>#get_design.product_cat_code#</cfoutput></cfif>">
													<input type="hidden" name="product_catid" id="product_catid" value="<cfoutput>#get_design.product_catid#</cfoutput>">
													<cfinput type="text" name="product_cat" id="product_cat" value="#get_design.product_cat#" onFocus="AutoComplete_Create('product_cat','PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','1','PRODUCT_CATID','product_catid','','3','455');">
													<span class="input-group-addon icon-ellipsis btnPoniter" title="<cf_get_lang dictionary_id='42989.Ürün Kategorisi Ekle'> !" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_cat_names&field_code=upd_design.product_cat_code&field_id=upd_design.product_catid&field_name=upd_design.product_cat&field_min=upd_design.MIN_MARGIN&field_max=upd_design.MAX_MARGIN');"></span>
                                             	</div>   
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                                    	<div class="form-group" id="item-is_prototip">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="34139.Özelleştirme"></label>
                                            <div class="col col-8 col-xs-12">
                                                <input type="checkbox" name="is_prototip" id="is_prototip" value="1" <cfif get_design.is_prototip eq 1>checked</cfif>>
                                            </div>
                                        </div>
                                    	
                                        <div class="form-group" id="item-design_type">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='58651.Türü'> *</label>
                                            <div class="col col-8 col-xs-12">
                                                <select name="design_type" id="design_type" style="width:160px; height:20px">
                                                    <option value="0"><cf_get_lang dictionary_id="57734.Seçiniz"></option>
                                                    <option value="1" <cfif get_design.PROCESS_ID eq 1>selected</cfif>><cfoutput><cf_get_lang dictionary_id="36742.Modül">+<cf_get_lang dictionary_id="45548.Paket">+<cf_get_lang dictionary_id="45.Parça"></cfoutput></option>
                                                    <option value="2" <cfif get_design.PROCESS_ID eq 2>selected</cfif>><cfoutput><cf_get_lang dictionary_id="36742.Modül">+<cf_get_lang dictionary_id="45548.Paket"></cfoutput></option>
                                                    <option value="3" <cfif get_design.PROCESS_ID eq 3>selected</cfif>><cfoutput><cf_get_lang dictionary_id="36742.Modül"></cfoutput></option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-color_type">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='111.Renk Adı'> *</label>
                                            <div class="col col-8 col-xs-12">
                                                <select name="color_type" id="color_type" style="width:130px; height:20px">
                                                <option value="0"><cf_get_lang dictionary_id="57734.Seçiniz"></option>
                                                <cfoutput query="get_colors">
                                                    <option value="#COLOR_ID#" <cfif get_design.color_id eq COLOR_ID>selected</cfif>>#COLOR_NAME#</option>
                                                </cfoutput>
                                            </select>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                                    	<div class="form-group" id="item-1b">
                                            <label class="col col-4 col-xs-12">&nbsp;</label>
                                            <div class="col col-8 col-xs-12">
                                                &nbsp;
                                            </div>
                                        </div>
                                       <div class="form-group" id="item-process">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç">*</label>
                                            <div class="col col-8 col-xs-12">
                                                <cf_workcube_process is_upd='0' select_value='#get_design.process_stage#' is_detail='1'>
                                            </div>
                                        </div> 
                                        <div class="form-group" id="item-quantity">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="36498.Üretim Miktarı"> *</label>
                                            <div class="col col-8 col-xs-12">
                                                <cfsavecontent variable="message1"><cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'>!</cfsavecontent>
                                				<cfinput type="text" name="product_quantity" value="#get_design.product_quantity#" maxlength="5" required="Yes" message="#message1#" style="width:100px; text-align:right">
                                            </div>
                                        </div> 
                                    </div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                                    	<div class="form-group" id="item-1a">
                                            <label class="col col-4 col-xs-12">&nbsp;</label>
                                            <div class="col col-8 col-xs-12">&nbsp;</div>
                                        </div>
                                        <div class="form-group" id="item-detail">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                                            <div class="col col-8 col-xs-12">
                                               <textarea name="detail" id="detail" style="width:150px;height:50px;"><cfoutput>#get_design.detail#</cfoutput></textarea>
                                            </div>
                                        </div>
                                  	</div>
								</cf_box_elements>
                                <cf_box_footer>
                                    <div class="col col-12">
                                    	<cf_record_info 
                                            query_name="get_design"
                                            record_emp="RECORD_EMP" 
                                            record_date="record_date"
                                            update_emp="UPDATE_EMP"
                                            update_date="update_date">
                                        <cf_workcube_buttons 
                                            is_upd='1' 
                                            add_function='kontrol()'
                                            del_function='sil_kontrol()'>
                                    </div>
                                </cf_box_footer>
                          	</div>
                     	</div>
          		</div>   
          	</cf_basket_form> 
            <table style="width:100%; height:400px" cellpadding="0" cellspacing="0" border="1" bordercolor="silver">
             	<tr>
                	<td style="width:25%; height:400px; vertical-align:top">
						<table style="width:100%;">
							<tr valign="top">
								<td width="100%" valign="top"><cfinclude template="../display/dsp_ezgi_design_main_row.cfm"></td>
							</tr>
							<tr valign="top">
								<td width="100%" valign="top"><cfinclude template="../display/dsp_ezgi_design_package_row.cfm"></td>
							</tr>
						</table>
					</td>
					<td id="piece_row_panel" style="width:75%; height:100%;" valign="top">
						<table style="width:100%; height:400px">
							<tr valign="top">
								<td width="100%" valign="top"><cfinclude template="../display/dsp_ezgi_design_piece_row.cfm"></td>
							</tr>
						</table>
					</td>
					<td id="creative_detail" class="nohover" style="display:none;  width:25%; vertical-align:top" >
						<div align="left" id="DISPLAY_CREATIVE_DETAIL" style="border:none;"></div>
					</td>
				</tr>
          	</table>  
		</cfform>
	</cf_box>
</div>
<style>
	#table6{ width: 100%; }
	.hidden_element {
		height:0px !important;
		line-height:0px !important;
		overflow:hidden;
		visibility:hidden;
		border-bottom:none !important;
	}
	.hidden_element > td, .hidden_element > td > table tr, .hidden_element > td > table tr td{
		border:none !important;
		height:0px !important;
		/* padding:0px !important; */
	}
</style>
<script type="text/javascript">
	function setHideShow() {
        if($("#creative_detail").css('display') == 'none'){
            $("#piece_row_panel").css({"width":"50%"});
        }else $("#piece_row_panel").css({"width":"75%"});
    }
	function connectAjax()
	{
		
		var bb = '<cfoutput>#request.self#?fuseaction=prod.emptypopup_ajax_ezgi_product_tree_creative_info&PRODUCT_QUANTITY=#attributes.PRODUCT_QUANTITY#&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif><cfif isdefined('attributes.design_package_row_id')>&design_package_row_id=#attributes.design_package_row_id#</cfif><cfif isdefined('attributes.design_piece_row_id')>&design_piece_row_id=#attributes.design_piece_row_id#</cfif></cfoutput>';
		AjaxPageLoad(bb,'DISPLAY_CREATIVE_DETAIL',1);
	}
	function kontrol()
	{
		if(document.upd_design.design_type.value == 0)
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : <cf_get_lang dictionary_id='57630.Tip'>  !");
			document.getElementById('design_type').focus();
			return false;
		}
		if(document.upd_design.color_type.value == 0)
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : <cf_get_lang dictionary_id='199.Renk'>  !");
			document.getElementById('color_type').focus();
			return false;
		}
		if(document.upd_design.product_catid.value <= 0 || document.upd_design.product_cat.value == '')
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : <cf_get_lang dictionary_id='57486.Kategori'>!");
			document.getElementById('product_cat').focus();
			return false;
		}
		if(process_cat_control())
			return true;
		else
			return false;
	}
	function sil_kontrol()
	{
		sor=confirm('Dikkat Tüm Tasarımı Siliyorsunuz!!!! Tasarıma Bağlı Ürün Kartları Sistemde Kaldığı Halde Tasarımdaki Modül Paket ve Parçalar Kalıcı Olarak Silinecektir.');
		if(sor==true)
			window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_product_tree_creative&design_id=#attributes.design_id#</cfoutput>";
		else
			return false;
	}
	function imp_main_row(main_row_id)
	{
		if(main_row_id==undefined <cfif isdefined('attributes.design_main_row_id') and len(attributes.design_main_row_id)>|| (main_row_id!=undefined&&main_row_id==<cfoutput>#attributes.design_main_row_id#</cfoutput>)</cfif>)
			window.location ='<cfoutput>#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&piece_name_search=#attributes.piece_name_search#&piece_type_select=#attributes.piece_type_select#&sort_id=#attributes.sort_id#&design_id=#attributes.design_id#</cfoutput>';
		else
			window.location ='<cfoutput>#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&piece_name_search=#attributes.piece_name_search#&piece_type_select=#attributes.piece_type_select#&sort_id=#attributes.sort_id#&design_id=#attributes.design_id#</cfoutput>&design_main_row_id='+main_row_id;
	}
	function imp_package_row(package_row_id)
	{
		if(package_row_id==undefined <cfif isdefined('attributes.design_package_row_id') and len(attributes.design_package_row_id)>|| (package_row_id!=undefined&&package_row_id==<cfoutput>#attributes.design_package_row_id#</cfoutput>)</cfif>)
			window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&piece_name_search=#attributes.piece_name_search#&piece_type_select=#attributes.piece_type_select#&sort_id=#attributes.sort_id#&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif></cfoutput>";
		else
			window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&piece_name_search=#attributes.piece_name_search#&piece_type_select=#attributes.piece_type_select#&sort_id=#attributes.sort_id#&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif></cfoutput>&design_package_row_id="+package_row_id;
	}
	function imp_piece_row(piece_row_id)
	{
		if(piece_row_id==undefined <cfif isdefined('attributes.design_piece_row_id') and len(attributes.design_piece_row_id)>|| (piece_row_id!=undefined&&piece_row_id==<cfoutput>#attributes.design_piece_row_id#</cfoutput>)</cfif>)
			window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&piece_name_search=#attributes.piece_name_search#&piece_type_select=#attributes.piece_type_select#&sort_id=#attributes.sort_id#&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif><cfif isdefined('attributes.design_package_row_id')>&design_package_row_id=#attributes.design_package_row_id#</cfif></cfoutput>";
		else
			window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&piece_name_search=#attributes.piece_name_search#&piece_type_select=#attributes.piece_type_select#&sort_id=#attributes.sort_id#&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif><cfif isdefined('attributes.design_package_row_id')>&design_package_row_id=#attributes.design_package_row_id#</cfif></cfoutput>&design_piece_row_id="+piece_row_id;
	}
	function sort_piece_row(sort_id)
	{
		window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&piece_name_search=#attributes.piece_name_search#&piece_type_select=#attributes.piece_type_select#&sort_id="+sort_id+"&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif><cfif isdefined('attributes.design_package_row_id')>&design_package_row_id=#attributes.design_package_row_id#</cfif></cfoutput>";
	}
	function serch_piece_row()
	{
		piece_name_search = document.getElementById('piece_name_search').value;
		window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&piece_type_select=#attributes.piece_type_select#&sort_id=#attributes.sort_id#&piece_name_search="+piece_name_search+"&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif><cfif isdefined('attributes.design_package_row_id')>&design_package_row_id=#attributes.design_package_row_id#</cfif></cfoutput>";
			
	}
	function relation_product_row(type,satir_no)
	{
		if(type == 3) /*Parça İlişkilendirme*/
			windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_add_ezgi_product_tree_creative_piece_relation&piece_id="+satir_no,'wide');
		if(type == 2) /*Paket İlişkilendirme*/
			windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_add_ezgi_product_tree_creative_piece_relation&package_id="+satir_no,'wide');
		if(type == 1) /*Modül İlişkilendirme*/
			windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_add_ezgi_product_tree_creative_piece_relation&main_id="+satir_no,'wide');
	}
	function piece_type_select_(selected_value)
	{
		window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&sort_id=#attributes.sort_id#&piece_type_select="+selected_value+"&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif><cfif isdefined('attributes.design_package_row_id')>&design_package_row_id=#attributes.design_package_row_id#</cfif></cfoutput>";
	}
	function design_delete_row()
	{
			
		<cfoutput>pic_number =#get_piece_row.recordcount#;</cfoutput>
		pic_row_list = '';
		for(var pic_rws=1; pic_rws <= pic_number; pic_rws++)
		{
			if(document.getElementById('select_piece_row'+pic_rws)==undefined)
			{
		
			}
			else
			{
				if(document.getElementById('select_piece_row'+pic_rws).checked == true)
				{
					pic_row_list += document.getElementById('select_piece_row'+pic_rws).value+',';
				}
			}
		}
		if(list_len(pic_row_list))
		{
			delete_question = confirm('<cf_get_lang dictionary_id='767.Silmek İstediğiniz Satır Kalıcı Olarak Silinecektir'>')
			if(delete_question == true)
			{
				pic_row_list = pic_row_list.substr(0,pic_row_list.length-1);//sondaki virgülden kurtariyoruz.
				window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_private_product_tree_creative_rows&standart=1&iid=#iid#&sort_id=#attributes.sort_id#</cfoutput>&type=3&pic_row_list="+pic_row_list;
			}
			else
				return false;
		}
		else
			return false;
	}

	//Sortable
	const packagePanel = $("#table3"), piecePanel = $("#table6");
	var clone, before, parent;

    var sortableSettings = {

		package: {
            connectWith: '.sorter',
			handle: '.handle'
        },
        piece: {
            helper: 'clone',
            connectWith: '.sorter',
            handle: '.handle',
            cursor: 'move',
            opacity: '0.6',
            start: function (event, ui) {
                $(ui.item).show();
                clone = $(ui.item).clone();
                before = $(ui.item).prev();
                parent = $(ui.item).parent();
				
				packagePanel.find("> tbody tr[type = columnSort]").removeClass("hidden_element");

				var showing_drag = "";
				$(ui.item).find("> td").each(function () {
					if($(this).hasClass('showing_drag')) showing_drag = $(this).find("input").val();
				});

				$(ui.helper).html("<td>"+ showing_drag +"</td>").css({"width":"100px"});

            },
            stop: function (event, ui) {
				/* ui.item.html(ui.item.startHtml); */
                if (before.length) before.after(clone);
                else parent.prepend(clone);

				var design_package_row_id = $(ui.item).closest('tbody').data('design_package_row_id');
				var design_package_number = $(ui.item).closest('tbody').data('design_package_number');
				var piece_row_id = $(ui.item).data('piece_row_id');

				if( design_package_row_id != undefined ){
					clone.find('span.handle').remove();
					//$(ui.item).find('span.handle').remove();
					$(ui.item).remove();

					var data = new FormData();
					data.append("design_package_row_id", design_package_row_id);
					data.append("piece_row_id", piece_row_id);

					AjaxControlPostDataJson( "AddOns/ezgi/cfc/piece.cfc?method=set_piece", data, function (response) {
						if( response.STATUS ) clone.find(".package_number").css({"background-color":'white'}).text(design_package_number);
						else{
							clone.html('<span class="icn-md icon-align-justify handle ui-sortable-handle"></span>');
							alert("Bir hata oluştu!");
						}
					});
				}else{
					clone.remove();
				}

				packagePanel.find("> tbody tr[type = columnSort]").addClass("hidden_element");

            }

        }

    };

    packagePanel.find("> tbody tr[type=columnSort] tbody").sortable(sortableSettings.package);
	piecePanel.find("tbody").sortable(sortableSettings.piece);

	$(document).keyup(function(e) {
		if (e.which === 27 || e.keyCode === 27) {
			packagePanel.find("> tbody tr[type=columnSort] tbody").sortable("cancel");
			piecePanel.find("tbody").sortable("cancel");
		}
	});

	//scrool down.
	var page = 2
		,maxrows = <cfoutput>#attributes.maxrows#</cfoutput>
		,counter = 0
		,totalCount = 0
		,oldHeight = 0
		,pageEnd = false
		,design_piece_row_id = "<cfoutput>#attributes.design_piece_row_id?:''#</cfoutput>"
		,colorObject = <cfoutput>#colorObject#</cfoutput>;

	window.onscroll = function(){
		
		var winScroll = Math.round(document.body.scrollTop || document.documentElement.scrollTop);
		var height = Math.round(document.documentElement.scrollHeight - document.documentElement.clientHeight);
		if((winScroll == height) && (oldHeight != height)){
			if(!pageEnd) dataTemplate();	
		}
		
	}

	function getColorById(color_id) {
		var filteredColor = colorObject.filter((el) => { return el.COLOR_ID == color_id });
		if(filteredColor.length > 0) return filteredColor.map(((elm) => { return { color_id: elm.COLOR_ID, color_name: elm.COLOR_NAME } }))[0];
		else return { color_id: '', color_name: '' };
	}

	function dataTemplate() {

		startrow = ((page - 1) * maxrows) + 1;

		if( totalCount != 0 && startrow - 1 >= totalCount ){
			pageEnd = true;
			return;
		}

		var data = new FormData();
		data.append("design_package_row_id", "<cfoutput>#attributes.design_package_row_id?:''#</cfoutput>");
		data.append("design_main_row_id", "<cfoutput>#attributes.design_main_row_id?:''#</cfoutput>");
		data.append("design_id", "<cfoutput>#attributes.design_id?:''#</cfoutput>");
		data.append("piece_type_select", "<cfoutput>#attributes.piece_type_select?:''#</cfoutput>");
		data.append("piece_name_search", "<cfoutput>#attributes.piece_name_search?:''#</cfoutput>");
		data.append("sort_id", "<cfoutput>#attributes.sort_id?:''#</cfoutput>");
		data.append("startrow", startrow);
		data.append("maxrows", maxrows);

		AjaxControlPostDataJson( "AddOns/ezgi/cfc/piece.cfc?method=get_piece_json", data, function (response) {

			$("#table6 > tbody").find("#divPageLoad").remove();

			if( response.length > 0 ){

				counter = startrow;
				totalCount = response[0].QUERY_COUNT;
				response.forEach(el => {

					var iconHandle = "", rowTitle = "", iconCopy = "", iconUrl = "", iconType = "", iconIsFlowDirection = "", packageNumberColor = "", iconBarcode = "", iconUpd = "";

					iconHandle 	= (el.PACKAGE_NUMBER == '' && (el.PACKAGE_PARTNER_ID == "" || el.PACKAGE_PARTNER_ID <= 0) && el.USED_AMOUNT == 0) ? $("<span>").addClass("icn-md icon-align-justify handle") : '';
					iconCopy 	= (el.PIECE_TYPE == 1 || el.PIECE_TYPE == 2) ? $("<span>").addClass("icn-md icon-copy").css({ "cursor": "pointer" }).attr({"title": "<cf_get_lang dictionary_id='57476.Kopyala'>","onclick": "copy_piece_row(3," + el.PIECE_ROW_ID +")"}) : '';
					iconUrl 	= (el.PIECE_RELATED_ID > 0)
									? $("<span>").addClass("icn-md icon-check").attr({"title": ( el.PACKAGE_PARTNER_ID > 0 ? "<cf_get_lang dictionary_id="64.Ortak Paket Parçası">" : ( el.ORTAK_PARCA > 1 ? "<cf_get_lang dictionary_id="63.Ortak Parça">" : "<cf_get_lang dictionary_id="218.Stok Kartı">" ) ), "onclick": "openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_detail_product&sid=" + el.PIECE_RELATED_ID + "','large')"})
									: (el.PACKAGE_PARTNER_ID <= 0) ? $("<span>").addClass("icn-md icon-link").css({ "cursor": "pointer" }).attr({"title": "<cf_get_lang dictionary_id="840.Stok Kartı İlişkilendir">","onclick": "relation_product_row(3," + el.PIECE_ROW_ID +")"}) : '';
					
					if(el.PIECE_TYPE == 1) iconType = $("<img>").attr({"src": "/images/butcegider.gif", "title": "<cf_get_lang dictionary_id='62.Yonga Levha'>"});
					else if(el.PIECE_TYPE == 2) iconType = $("<img>").attr({"src": "/images/arrow_up.png", "title": "<cf_get_lang dictionary_id='402.Genel Reçete'>"});
					else if(el.PIECE_TYPE == 3) iconType = $("<img>").attr({"src": "/images/elements.gif", "title": "<cf_get_lang dictionary_id='403.Montaj Ürünü'>"});
					else if(el.PIECE_TYPE == 4) iconType = $("<img>").attr({"src": "/images/promo_multi.gif", "title": "<cf_get_lang dictionary_id='404.Hammadde'>"});
										

					iconIsFlowDirection = el.PIECE_TYPE == 1 ? ((el.IS_FLOW_DIRECTION == 0) ? $("<img>").attr({"src": "images/production/false.png"}).css({"width": "15px", "height": "15px"}) : $("<img>").attr({"src": "images/production/true.png"}).css({"width": "15px", "height": "15px"}) ) : '';

					if(el.USED_AMOUNT != 0){
						if(el.USED_AMOUNT == el.PIECE_AMOUNT) packageNumberColor = "LimeGreen";
						else if(el.USED_AMOUNT < el.PIECE_AMOUNT) packageNumberColor = "yellow";
						else if(el.USED_AMOUNT > el.PIECE_AMOUNT) packageNumberColor = "coral";
					}else{
						if(el.PACKAGE_NUMBER == "") packageNumberColor = "red";
						else if(design_piece_row_id == el.PIECE_ROW_ID) packageNumberColor = "LightGray";
					}

					iconBarcode = el.PIECE_TYPE != 4 ?  $("<span>").css({"cursor": "pointer"}).attr({"onclick": "dsp_piece_row("+ el.PIECE_ROW_ID +")", "title": "<cf_get_lang dictionary_id='855.İş Emri Görünüm'>"}).addClass("fa fa-barcode") : "";
					iconUpd = el.PACKAGE_PARTNER_ID > 0 ? $("<img>").attr({"src": "/images/lock_buton.gif", "title": "<cf_get_lang dictionary_id='64.Ortak Paket Parçası'>"}) : $("<i>").attr({"onclick": "upd_piece_row(" + el.PIECE_ROW_ID + ")", "title": "<cf_get_lang dictionary_id='57464.Güncelle'>"}).addClass("fa fa-pencil");

					$("<tr>").attr({"id": "frm_row_exit" + counter + "_piece", "data-piece_row_id": el.PIECE_ROW_ID}).append(
						/*1*/
						$("<td>").css({"text-align": "center", "padding": "0 10px", "width": "20px"}).append( iconHandle ),
						/*2*/
						$("<td>").attr({"nowrap": "nowrap", "title": el.PACKAGE_PARTNER_ID > 0 ? '<cf_get_lang dictionary_id="64.Ortak Paket Parçası">' : "" }).css({"text-align": "right", "width": "30px", "cursor": "pointer", "vertical-align": "middle", "background-color": (design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : "none")}).append(
							$("<input>").attr({"type": "hidden", "name": "new_stock_id_3_" + el.PIECE_ROW_ID + "", "id": "new_stock_id_3_" + el.PIECE_ROW_ID + ""}),
							$("<input>").attr({"type": "hidden", "name": "new_product_id_3_" + el.PIECE_ROW_ID + "", "id": "new_product_id_3_" + el.PIECE_ROW_ID + ""}),
							iconCopy,
							counter
						),
						/*3*/
						$("<td>").css({"text-align": "center", "width": "30px", "cursor": "pointer", "background-color": ( design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : ( el.PACKAGE_PARTNER_ID > 0 ? "MistyRose" : ( el.ORTAK_PARCA > 1 ? "Gainsboro" : "none" )) )}).append( iconUrl ),
						/*4*/
						$("<td>").css({"text-align": "center", "width": "30px", "cursor": "pointer", "background-color": ( design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : "" )}).attr({"onclick": "imp_piece_row(" + el.PIECE_ROW_ID + ")"}).append( iconType ),
						/*5*/
						$("<td>").css({"text-align": "center", "width": "30px", "cursor": "pointer", "background-color": ( design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : "" )}).attr({"onclick": "imp_piece_row(" + el.PIECE_ROW_ID + ")"}).text( el.PIECE_CODE ),
						/*6*/
						$("<td>").css({"text-align": "left", "width": "200px", "cursor": "pointer", "background-color": ( design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : "" )}).attr({"onclick": "imp_piece_row(" + el.PIECE_ROW_ID + ")"}).attr({"title": el.PIECE_NAME}).addClass("showing_drag").append(
							$("<input>").css({"width": "100%", "border": "none", "cursor": "pointer", "background-color": ( design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : "" )}).attr({"type": "text", "name": "productname" + counter + "", "readonly": "readonly"}).val(el.PIECE_NAME)
						),
						/*7*/
						$("<td>").css({"text-align": "center", "width": "30px", "cursor": "pointer", "background-color": ( design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : "" )}).attr({"onclick": "imp_piece_row(" + el.PIECE_ROW_ID + ")"}).text( el.BOYU ),
						/*8*/
						$("<td>").css({"text-align": "center", "width": "30px", "cursor": "pointer", "background-color": ( design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : "" )}).attr({"onclick": "imp_piece_row(" + el.PIECE_ROW_ID + ")"}).text( el.ENI ),
						/*9*/
						$("<td>").css({"text-align": "center", "width": "30px", "cursor": "pointer", "background-color": ( design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : "" )}).attr({"onclick": "imp_piece_row(" + el.PIECE_ROW_ID + ")"}).text( el.KALINLIK_ ),
						/*10*/
						$("<td>").css({"text-align": "center", "width": "30px", "cursor": "pointer", "background-color": ( design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : "" )}).attr({"onclick": "imp_piece_row(" + el.PIECE_ROW_ID + ")"}).text( el.PIECE_AMOUNT ),
						/*11*/
						$("<td>").css({"text-align": "left", "width": "90px", "cursor": "pointer", "background-color": ( design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : "" )}).attr({"onclick": "imp_piece_row(" + el.PIECE_ROW_ID + ")"}).html( '&nbsp; &nbsp;' + getColorById( el.PIECE_COLOR_ID ).color_name + '&nbsp;' ),
						/*12*/
						$("<td>").css({"text-align": "center", "width": "30px", "cursor": "pointer", "background-color": ( design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : "" )}).attr({"onclick": "imp_piece_row(" + el.PIECE_ROW_ID + ")"}).append( iconIsFlowDirection ),
						/*13*/
						$("<td>").css({"text-align": "center", "width": "30px", "cursor": "pointer", "background-color": packageNumberColor}).attr({"onclick": "imp_piece_row(" + el.PIECE_ROW_ID + ")"}).addClass("package_number").text( el.USED_AMOUNT != 0 ? ("K-"+ el.USED_AMOUNT +"") : el.PACKAGE_NUMBER ),
						/*14*/
						$("<td>").css({"text-align": "center", "width": "30px", "cursor": "pointer", "background-color": ( design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : "" )}).append( iconBarcode ),
						/*15*/
						$("<td>").css({"text-align": "center", "width": "30px", "cursor": "pointer", "background-color": ( design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : "" )}).append( iconUpd ),
						/*16*/
						$("<td>").css({"text-align": "center", "width": "30px", "cursor": "pointer", "background-color": ( design_piece_row_id == el.PIECE_ROW_ID ? "LightGray" : "" )}).append( el.PACKAGE_PARTNER_ID <= 0 ? $("<input>").attr({"type": "checkbox", "name": "select_piece_row_" + el.PIECE_ROW_ID + "", "id": "select_piece_row_" + el.PIECE_ROW_ID + ""}).val(el.PIECE_ROW_ID) : "" )

					).appendTo($("#table6 > tbody"));
					counter++;
				});
			}else pageEnd = true;
			page++;
		},
		function () {
			$("#table6 > tbody").append(
				'<tr id="divPageLoad"><td colspan="16" style="text-align:center;"><?xml version="1.0" encoding="utf-8"?><svg width="32px" height="32px" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid" class="uil-ring-alt"><rect x="0" y="0" width="100" height="100" fill="none" class="bk"></rect><circle cx="50" cy="50" r="40" stroke="rgba(255,255,255,0)" fill="none" stroke-width="10" stroke-linecap="round"></circle><circle cx="50" cy="50" r="40" stroke="#ff8a00" fill="none" stroke-width="6" stroke-linecap="round"><animate attributeName="stroke-dashoffset" dur="2s" repeatCount="indefinite" from="0" to="502"></animate><animate attributeName="stroke-dasharray" dur="2s" repeatCount="indefinite" values="150.6 100.4;1 250;150.6 100.4"></animate></circle></svg></td></tr>'
			);
			oldHeight = Math.round(document.documentElement.scrollHeight - document.documentElement.clientHeight);
		}
		);
	}

</script>