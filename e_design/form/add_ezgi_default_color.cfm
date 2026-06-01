<!---
    File: add_ezgi_default_color.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_default" datasource="#dsn3#">
	SELECT DEFAULT_COLOR_PROPERTY_ID FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfif not get_default.recordcount or not len(get_default.DEFAULT_COLOR_PROPERTY_ID)>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='219.İlk Olarak Default Renk Özellik ID Giriniz'>!");
		window.close()
	</script>
	<cfabort>
</cfif>
<cfquery name="get_max" datasource="#dsn3#">
	SELECT MAX(CAST(PROPERTY_DETAIL_CODE AS INT)) AS MAX_ID FROM EZGI_COLORS WITH (NOLOCK)
</cfquery>
<cfif len(get_max.max_id) eq 1>
	<cfset  sira = '00#get_max.max_id+1#'>
<cfelseif len(get_max.max_id) eq 2>
	<cfset  sira = '0#get_max.max_id+1#'>
<cfelseif len(get_max.max_id) eq 3>
	<cfset  sira = '#get_max.max_id+1#'>
<cfelse>
	<cfset  sira = '001'>
</cfif>
<cf_catalystHeader>
<div class="col col-12 col-xs-12">
    <cf_box>
		<cfform name="add_default_color" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_default_color">
        	<cf_box_elements>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group" id="item-status">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="checkbox" id="status" name="status" value="1" checked="yes" style="width:20px; height:20px;">
                            </div>
                       	</div> 
                        <div class="form-group" id="item-sira">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='113.Renk Kodu'> *</label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="text" name="default_code" id="default_code" value="#sira#" maxlength="20" >
                            </div>
                      	</div>
                        <div class="form-group" id="item-name">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='111.Renk Adı'> *</label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="text" name="default_name" id="default_name" value="" maxlength="50">
                            </div>
                      	</div>
						<div class="form-group" id="item-special_code">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57789.Özel Kod'> *</label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="text" name="special_code" id="special_code" value="" maxlength="50">
                            </div>
                      	</div>
						  <div class="form-group" id="item-is_pattern">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='76.Desen'></label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="checkbox" name="is_pattern" id="is_pattern" value="1" style="width:20px; height:20px;">
                            </div>
                      	</div>
                        <div class="form-group" id="item-master">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='112.Master Ürün'> *</label>
                            <div class="col col-8 col-xs-12">
                            	<div class="input-group">
                                    <input type="text" name="urun" id="urun" style="width:150px;" >
                                    <input type="hidden" name="pid" id="pid">
                                    <input type="hidden" name="stock_id" id="stock_id"> 
                                    <span class="input-group-addon icon-ellipsis btnPointer" onclick="pencere_ac();"></span>
                                </div>
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
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='111.Renk Adı'> !");
			document.getElementById('default_name').focus();
			return false;
		}
		if(document.getElementById("stock_id").value <=0)
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='112.Master Ürün'> !");
			document.getElementById('stock_id').focus();
			return false;
		}

		if(document.getElementById("default_code").value == "")
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='113.Renk Kodu'> !");
			document.getElementById('default_code').focus();
			return false;
		}
		if(document.getElementById("special_code").value == "")
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='57789.Özel Kod'> !");
			document.getElementById('special_code').focus();
			return false;
		}
	}
	function pencere_ac()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=1&master=1&product_id=add_default_color.pid&field_id=add_default_color.stock_id&field_name=add_default_color.urun",'list');
	}
</script>