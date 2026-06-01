<!---
    File: add_ezgi_default_measure.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cf_catalystHeader>
<div class="col col-12 col-xs-12">
    <cf_box>
		<cfform name="add_default_measure" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_default_measure">
        	<cf_box_elements>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group" id="item-status">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="checkbox" id="status" name="status" value="1" checked="yes">
                            </div>
                       	</div> 
                        <div class="form-group" id="item-sira">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="36570.Ölçü Kodu"> *</label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="text" name="default_code" id="default_code" value="" maxlength="20" style="width:150px;">
                            </div>
                      	</div>
                        <div class="form-group" id="item-name">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="36569.Ölçü Adı"> *</label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="text" name="default_name" id="default_name" value="" maxlength="50" style="width:150px;">
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
	document.getElementById('default_name').focus();
	function kontrol()
	{
		if(document.getElementById("default_name").value == "")
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='36569.Ölçü Adı'> !");
			document.getElementById('default_name').focus();
			return false;
		}
		if(document.getElementById("default_code").value == "")
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='36570.Ölçü Kodu'> !");
			document.getElementById('default_code').focus();
			return false;
		}
	}
	function pencere_ac()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=1&master=1&product_id=add_default_measure.pid&field_id=add_default_measure.stock_id&field_name=add_default_measure.urun",'list');
	}
</script>