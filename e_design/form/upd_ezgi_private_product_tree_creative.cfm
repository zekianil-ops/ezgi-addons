<!---
    File: upd_ezgi_private_product_tree_creative.cfm
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
<cfquery name="get_design" datasource="#dsn3#">
	SELECT  * FROM EZGI_DESIGN WHERE DESIGN_ID = #attributes.design_id#
</cfquery>
<cfset is_related_product = 0>
<cfquery name="get_design_main_row_cntrl" datasource="#dsn3#">
	SELECT
		MAIN_SPECT_RELATED_ID
	FROM            
   		EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
	WHERE        
    	DESIGN_ID = #attributes.design_id# AND
        MAIN_SPECT_RELATED_ID IS NULL
</cfquery>
<cfif get_design_main_row_cntrl.recordcount><cfset is_related_product = 1></cfif>
<cfif get_design.PROCESS_ID gt 1 and is_related_product eq 0>
    <cfquery name="get_design_package_row_cntrl" datasource="#dsn3#">
        SELECT
            PACKAGE_SPECT_RELATED_ID
        FROM            
            EZGI_DESIGN_PACKAGE WITH (NOLOCK)
        WHERE        
            DESIGN_ID = #attributes.design_id# AND
            PACKAGE_SPECT_RELATED_ID IS NULL
    </cfquery>
    <cfif get_design_package_row_cntrl.recordcount><cfset is_related_product = 1></cfif>
</cfif>
<cfif get_design.PROCESS_ID gt 2 and is_related_product eq 0>
    <cfquery name="get_design_piece_row_cntrl" datasource="#dsn3#">
        SELECT
            PIECE_SPECT_RELATED_ID
        FROM            
            EZGI_DESIGN_PIECE WITH (NOLOCK)
        WHERE        
            DESIGN_ID = #attributes.design_id# AND
            PIECE_SPECT_RELATED_ID IS NULL
    </cfquery>
    <cfif get_design_piece_row_cntrl.recordcount><cfset is_related_product = 1></cfif>
</cfif>
<cfparam name="attributes.product_quantity" default="1">
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
   	<cf_box>
   		<cfform name="add_design" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_private_product_tree_creative">
        	<cfinput name="design_id" id="design_id" value="#attributes.design_id#" type="hidden">
         	<cf_basket_form id="upd_design">
                <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
								<cf_box_elements>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                                    	<div class="col col-12">
                                            <div class="form-group" id="item-status">
                                                <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                                                <div class="col col-9 col-xs-12">
                                                    <input type="checkbox" name="is_active" id="is_active" value="1" <cfif get_design.status eq 1>checked</cfif>>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col col-12">
                                        	<div class="form-group" id="item-design_type">
                                                <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id ='58651.Türü'> </label>
                                                
                                                    <label class="col col-9 col-xs-12">
                                                        <cfif get_design.PROCESS_ID eq 1><cf_get_lang dictionary_id="36742.Modül">+<cf_get_lang dictionary_id="45548.Paket">+<cf_get_lang dictionary_id="45.Parça">
                                                        <cfelseif get_design.PROCESS_ID eq 2><cf_get_lang dictionary_id="36742.Modül">+<cf_get_lang dictionary_id="45548.Paket">
                                                        <cfelseif get_design.PROCESS_ID eq 3><cf_get_lang dictionary_id="36742.Modül">
                                                        </cfif>                                                    
                                                  	</label>
                                                
                                            </div>
                                        </div>
                                   	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                                        <div class="form-group" id="item-process">
                                            <label class="col col-2 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç">*</label>
                                            <div class="col col-10 col-xs-12">
                                                <cf_workcube_process is_upd='0' select_value='#get_design.process_stage#' is_detail='1'>
                                            </div>
                                        </div>
                                   	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                                        <div class="form-group" id="item-cat">
                                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id ='57486.Kategori'>*</label>
                                            <div class="col col-9 col-xs-12">
                                                <div class="input-group">
                                                	<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("get_design.consumer_id")><cfoutput>#get_design.consumer_id#</cfoutput></cfif>">
                                                	<input type="hidden" name="company_id"  id="company_id" value="<cfif isdefined("get_design.company_id")><cfoutput>#get_design.company_id#</cfoutput></cfif>">
                                                	<input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("get_design.member_type")><cfoutput>#get_design.member_type#</cfoutput></cfif>">
                                                	<input type="text" name="member_name"   id="member_name" style="width:130px; height:20px"  value="<cfif isdefined("get_design.member_name") and len(get_design.member_name)><cfoutput>#get_design.member_name#</cfoutput></cfif>" onfocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2\'','CONSUMER_ID,COMPANY_ID,MEMBER_TYPE','consumer_id,company_id,member_type','','3','250');" autocomplete="off">
                                        			<span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&field_consumer=add_design.consumer_id&field_comp_id=add_design.company_id&field_member_name=add_design.member_name&field_type=add_design.member_type&select_list=7,8&keyword='+encodeURIComponent(document.add_design.member_name.value),'list');"></span>
                                             	</div>   
                                            </div>
                                        </div>
                                   	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                                        <div class="form-group" id="item-detail">
                                            <label class="col col-2 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                                            <div class="col col-10 col-xs-12">
                                                <textarea name="detail" id="detail" style="width:150px;height:30px;"><cfoutput>#get_design.detail#</cfoutput></textarea>
                                            </div>
                                        </div>
                                   	</div>
                             	</cf_box_elements>
                                <cf_box_footer>
                                	<div class="col col-8">
                                    	<cf_record_info 
                                            query_name="get_design"
                                            record_emp="RECORD_EMP" 
                                            record_date="record_date"
                                            update_emp="UPDATE_EMP"
                                            update_date="update_date">
                                    </div>
                                    <div class="col col-2">
                                    	<cfif is_related_product eq 1>
                                        	<span style="color:red; font-weight:bold">
                                            	<cf_get_lang dictionary_id ='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='52888.Ürün Aktarım'>
                                            </span>
                                        </cfif>
                                    </div>
                                    <div class="col col-2">
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
                                	<td width="100%" valign="top"><cfinclude template="../display/dsp_ezgi_private_design_main_row.cfm"></td>
                                </tr>
                                <tr valign="top">
                                	<td width="100%" valign="top"><cfinclude template="../display/dsp_ezgi_private_design_package_row.cfm"></td>
                                </tr>
                        	</table>
                        </td>
                        <td width="52%" height="100%" valign="top">
                        	<table style="width:100%; height:400px">
                        		<tr valign="top">
                                	<td width="100%" valign="top"><cfinclude template="../display/dsp_ezgi_private_design_piece_row.cfm"></td>
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
<script type="text/javascript">
	function connectAjax()
	{
		
		var bb = '<cfoutput>#request.self#?fuseaction=prod.emptypopup_ajax_ezgi_product_tree_creative_info&PRODUCT_QUANTITY=#attributes.PRODUCT_QUANTITY#&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif><cfif isdefined('attributes.design_package_row_id')>&design_package_row_id=#attributes.design_package_row_id#</cfif><cfif isdefined('attributes.design_piece_row_id')>&design_piece_row_id=#attributes.design_piece_row_id#</cfif></cfoutput>';
		AjaxPageLoad(bb,'DISPLAY_CREATIVE_DETAIL',1);
	}
	function kontrol()
	{
		if(document.member_type.value == '')
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : <cf_get_lang dictionary_id='57658.Üye'>!");
			document.getElementById('member_name').focus();
			return false;
		}
	}
	function imp_main_row(main_row_id)
	{
		if(main_row_id==undefined)
			window.location ='<cfoutput>#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd&piece_type_select=#attributes.piece_type_select#&sort_id=#attributes.sort_id#&design_id=#attributes.design_id#</cfoutput>';
		else
			window.location ='<cfoutput>#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd&piece_type_select=#attributes.piece_type_select#&sort_id=#attributes.sort_id#&design_id=#attributes.design_id#</cfoutput>&design_main_row_id='+main_row_id;
	}
	function imp_package_row(package_row_id)
	{
		if(package_row_id==undefined)
			window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd&piece_type_select=#attributes.piece_type_select#&sort_id=#attributes.sort_id#&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif></cfoutput>";
		else
			window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd&piece_type_select=#attributes.piece_type_select#&sort_id=#attributes.sort_id#&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif></cfoutput>&design_package_row_id="+package_row_id;
	}
	function imp_piece_row(piece_row_id)
	{
		if(piece_row_id==undefined)
			window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd&piece_type_select=#attributes.piece_type_select#&sort_id=#attributes.sort_id#&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif><cfif isdefined('attributes.design_package_row_id')>&design_package_row_id=#attributes.design_package_row_id#</cfif></cfoutput>";
		else
			window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd&piece_type_select=#attributes.piece_type_select#&sort_id=#attributes.sort_id#&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif><cfif isdefined('attributes.design_package_row_id')>&design_package_row_id=#attributes.design_package_row_id#</cfif></cfoutput>&design_piece_row_id="+piece_row_id;
	}
	function sort_piece_row(sort_id)
	{
		window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd&piece_type_select=#attributes.piece_type_select#&sort_id="+sort_id+"&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif><cfif isdefined('attributes.design_package_row_id')>&design_package_row_id=#attributes.design_package_row_id#</cfif></cfoutput>";
	}
	function relation_product_row(type,satir_no)
	{
		if(type == 3) /*Parça İlişkilendirme*/
		{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_add_ezgi_product_tree_creative_piece_relation&piece_id="+satir_no,'wide');
		}
		if(type == 2) /*Paket İlişkilendirme*/
		{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_add_ezgi_product_tree_creative_piece_relation&package_id="+satir_no,'wide');
		}
	}
	function piece_type_select_(selected_value)
	{
		window.location ="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd&sort_id=#attributes.sort_id#&piece_type_select="+selected_value+"&design_id=#attributes.design_id#<cfif isdefined('attributes.design_main_row_id')>&design_main_row_id=#attributes.design_main_row_id#</cfif><cfif isdefined('attributes.design_package_row_id')>&design_package_row_id=#attributes.design_package_row_id#</cfif></cfoutput>";
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
				window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_private_product_tree_creative_rows&iid=#iid#&sort_id=#attributes.sort_id#</cfoutput>&type=3&pic_row_list="+pic_row_list;
			}
			else
				return false;
		}
		else
			return false;
	}
	function sil_kontrol()
	{
		sor=confirm('Dikkat Tüm Tasarımı Siliyorsunuz!!!! Tasarıma Bağlı Specler Sistemde Kaldığı Halde Tasarımdaki Modül Paket ve Parçalar Kalıcı Olarak Silinecektir.');
		if(sor==true)
			window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_product_tree_creative&is_private=1&design_id=#attributes.design_id#</cfoutput>";
		else
			return false;	
	}
</script>