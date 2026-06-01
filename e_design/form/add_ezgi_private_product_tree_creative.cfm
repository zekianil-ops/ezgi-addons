<!---
    File: add_ezgi_private_product_tree_creative.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.product_quantity" default="1">
<cf_catalystHeader>
<div class="col col-12 col-xs-12">
    <cf_box>
    	<cfform name="add_design" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_private_product_tree_creative">
        	<cf_box_elements>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group" id="item-is_active">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="checkbox" id="is_active" name="is_active" value="1" checked="yes">
                            </div>
                       	</div>
                        <div class="form-group" id="item-process">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58859.Süreç'>*</label>
                            <div class="col col-8 col-xs-12">
                                <cf_workcube_process is_upd='0' process_cat_width='100' is_detail='0'>
                            </div>
                      	</div> 
                        <div class="form-group" id="item-design_type">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='58651.Türü'> *</label>
                            <div class="col col-8 col-xs-12">
                                <select name="design_type" id="design_type" style="width:160px;height:20px">
                                    <option value="0"><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <option value="1"><cf_get_lang dictionary_id ='141.Modül'>+<cf_get_lang dictionary_id ='100.Paket'>+<cf_get_lang dictionary_id ='45.Parça'></option>
                                    <option value="2"><cf_get_lang dictionary_id ='141.Modül'>+<cf_get_lang dictionary_id ='100.Paket'></option>
                                    <option value="3"><cf_get_lang dictionary_id ='141.Modül'></option>
                                </select>
                            </div>
                       	</div>
                        <div class="form-group" id="item-cat">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57519.Cari Hesap'> *</label>
                            <div class="col col-8 col-xs-12">
                            	<div class="input-group">
                                    <input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
                                    <input type="hidden" name="company_id"  id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
                                    <input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
                                    <input type="text" name="member_name"   id="member_name" style="width:130px; height:20px"  value="<cfif isdefined("attributes.member_name") and len(attributes.member_name)><cfoutput>#attributes.member_name#</cfoutput></cfif>" onfocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2\'','CONSUMER_ID,COMPANY_ID,MEMBER_TYPE','consumer_id,company_id,member_type','','3','250');" autocomplete="off">
                                    <span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&field_consumer=add_design.consumer_id&field_comp_id=add_design.company_id&field_member_name=add_design.member_name&field_type=add_design.member_type&select_list=7,8&keyword='+encodeURIComponent(document.add_design.member_name.value),'list');"></span>
                                </div>
                            </div>
                      	</div>	
                        <div class="form-group" id="item-detail">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                            <div class="col col-8 col-xs-12">
                                <textarea name="detail" id="detail" style="width:150px;height:100px;" maxlength="250"></textarea>
                            </div>
                      	</div> 
              	</div> 
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-12">
                <cf_workcube_buttons type_format="1" is_upd='0' add_function='kontrol()'>
                </div>
            </cf_box_footer>
        </cfform> 
    </cf_box>
</div>
<script type="text/javascript">
	function kontrol()
	{
		if(document.getElementById('design_type').value == 0)
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : <cf_get_lang dictionary_id='58651.Türü'> !");
			document.getElementById('design_type').focus();
			return false;
		}
		if(document.member_type.value == '')
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : Üye!");
			document.getElementById('member_type').focus();
			return false;
		}
		return process_cat_control();
		return true;
	}
</script>