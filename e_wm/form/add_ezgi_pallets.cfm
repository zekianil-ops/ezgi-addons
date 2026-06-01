<cf_xml_page_edit>
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfset attributes.barcode = get_defaults.PALET_BARCODE+1>
<cf_catalystHeader>
<div class="col col-12 col-xs-12">
    <cf_box>
    	<cfform name="add_packings" method="post" action="#request.self#?fuseaction=stock.emptypopup_add_ezgi_pallets">
        	<cfif isdefined('x_palette_size')>
        		<cfinput type="hidden" name="palette_size" id="palette_size" value="#x_palette_size#">
            </cfif>
        	<cf_box_elements>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group" id="item-is_active">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="checkbox" id="is_active" name="is_active" value="1" checked="yes" readonly="yes">
                            </div>
                       	</div>
                        <div class="form-group" id="item-type">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='825.Palet Türü'>*</label>
                            <div class="col col-8 col-xs-12">
                             	<select name="palet_tur" id="palet_tur" style="width:120px; height:20px">
            						<option value="1" <cfif x_palette_type eq 1>selected</cfif>><cf_get_lang dictionary_id='1330.Karma Palet'></option>
                               		<option value="0" <cfif x_palette_type eq 0>selected</cfif>><cf_get_lang dictionary_id='820.Standart Palet'></option>
                             	</select>
                            </div>
                      	</div> 
                        <div class="form-group" id="item-barcode">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='1304.Başlangıç Barkodu'>*</label>
                            <div class="col col-8 col-xs-12">
                             	<cfinput type="text"  maxlength="50" name="barcode" value="#attributes.barcode#" readonly="yes">
                            </div>
                      	</div> 
                        <div class="form-group" id="item-amount">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57635.Miktar'>*</label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="text"  maxlength="3" name="amount" id="amount" value="1">
                            </div>
                      	</div> 
              	</div> 
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-12" id="buton">
                	<cf_workcube_buttons type_format="1" is_upd='0' add_function='kontrol()'>
                </div>
            </cf_box_footer>
        </cfform> 
    </cf_box>
</div>
<script type="text/javascript">
	function kontrol()
	{
			if(document.getElementById('amount').value == 0)
			{
				alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : <cf_get_lang dictionary_id='57635.Miktar'>!");
				return false;
			}
			else
			{
				return true;	
			}
	}
</script>