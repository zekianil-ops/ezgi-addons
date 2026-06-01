<!---
    File: add_ezgi_product_tree_creative.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.product_cat" default="">
<cfparam name="attributes.product_catid" default="">
<cfquery name="get_default" datasource="#dsn3#">
	SELECT ISNULL(DEFAULT_PRODUCTION_AMOUNT,1) AS DEFAULT_PRODUCTION_AMOUNT, DEFAULT_IS_STATION_OR_IS_OPERATION FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfif not get_default.recordcount or get_default.DEFAULT_PRODUCTION_AMOUNT lte 0>
	<script type="text/javascript">
		alert('<cf_get_lang dictionary_id="149.Önce Tasarım Genel Default Bilgilerini Tanımlayınız">!');
		window.history.go(-1);
	</script>
	<cfabort>
</cfif>
<cfparam name="attributes.product_quantity" default="#get_default.DEFAULT_PRODUCTION_AMOUNT#">
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WHERE IS_ACTIVE = 1 ORDER BY COLOR_NAME
</cfquery>
<cf_catalystHeader>
<div class="col col-12 col-xs-12">
    <cf_box>
    	<cfform name="add_design" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_product_tree_creative">
        	<cf_box_elements>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group" id="item-is_active">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="checkbox" id="is_active" name="is_active" value="1" checked="yes">
                            </div>
                       	</div>
                        <div class="form-group" id="item-design_name">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='43440.Tasarım Adı'>*</label>
                            <div class="col col-8 col-xs-12">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : <cf_get_lang dictionary_id ='43440.Tasarım Adı'>!</cfsavecontent>
                    			<cfinput type="text" name="design_name" value="" maxlength="200" required="Yes" message="#message#" style="width:150px;">
                            </div>
                       	</div>
                        <div class="form-group" id="item-process">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç">*</label>
                            <div class="col col-8 col-xs-12">
                                <cf_workcube_process is_upd='0' process_cat_width='100' is_detail='0'>
                            </div>
                      	</div> 
                      	<div class="form-group" id="item-cat">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57486.Kategori'> *</label>
                            <div class="col col-8 col-xs-12">
                            	<div class="input-group">
                                	<cfinput type="hidden" name="product_catid" value="">
									<cfsavecontent variable="message"><cf_get_lang dictionary_id='53158.Kategori Girmelisiniz'></cfsavecontent>
									<input type="hidden" name="product_cat_code" id="product_cat_code" value="<cfif len(attributes.product_cat)><cfoutput>#attributes.product_cat_code#</cfoutput></cfif>">
									<cfinput type="text" name="product_cat" id="product_cat" required="yes" message="#message#" value="" onFocus="AutoComplete_Create('product_cat','PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','1','PRODUCT_CATID','product_catid','','3','455');">
									<span class="input-group-addon icon-ellipsis btnPoniter" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_cat_names&field_code=add_design.product_cat_code&field_id=product_catid&field_name=add_design.product_cat&field_min=add_design.MIN_MARGIN&field_max=add_design.MAX_MARGIN');" title="<cf_get_lang dictionary_id='37157.Ürün Kategorisi Ekle'>!"></span>
                                    
                                    <!---<cfsavecontent variable="message"><cf_get_lang_main no='782.Girilmesi Zorunlu Alan'>!</cfsavecontent>
                                    <input type="hidden" name="product_cat_code" id="product_cat_code" value="<cfif len(attributes.product_cat)><cfoutput>#attributes.product_cat_code#</cfoutput></cfif>">
                                    <input type="hidden" name="product_catid" id="product_catid" value="<cfoutput>#attributes.product_catid#</cfoutput>">
                                    <cfinput type="text" name="product_cat" id="product_cat" style="width:150px; height:20px" value="#attributes.product_cat#" onFocus="AutoComplete_Create('product_cat','PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','','PRODUCT_CATID','product_catid','','3','200');"> 
                                    <span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_cat_names&field_code=add_design.product_cat_code&is_sub_category=1&field_id=add_design.product_catid&field_name=add_design.product_cat','list');"></span>--->
                                </div>
                            </div>
                      	</div>
                        <div class="form-group" id="item-process">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='111.Renk Adı'> *</label>
                            <div class="col col-8 col-xs-12">
                                <select name="color_type" id="color_type" style="width:130px; height:20px">
                                    <option value="0"><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="get_colors">
                                        <option value="#COLOR_ID#">#COLOR_NAME#</option>
                                    </cfoutput>
                                </select>
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
                        <div class="form-group" id="item-quantity">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='36498.Üretim Miktarı'>*</label>
                            <div class="col col-8 col-xs-12">
                            	<cfsavecontent variable="message1"><cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'>!</cfsavecontent>
                                <cfinput type="text" name="product_quantity" value="#attributes.product_quantity#" maxlength="5" required="Yes" message="#message1#" style="width:100px; height:20px; text-align:right">
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
		if(document.add_design.design_type.value == 0)
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : <cf_get_lang dictionary_id='58651.Türü'> !");
			document.getElementById('design_type').focus();
			return false;
		}
		if(document.add_design.color_type.value == 0)
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : <cf_get_lang dictionary_id='199.Renk'> !");
			document.getElementById('color_type').focus();
			return false;
		}
		if(document.add_design.product_cat.value == '')
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : <cf_get_lang dictionary_id='57486.Kategori'>!");
			document.getElementById('product_cat').focus();
			return false;
		}
		return process_cat_control();
		return true;
	}
</script>