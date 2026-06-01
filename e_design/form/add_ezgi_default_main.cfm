<!---
    File: add_ezgi_default_main.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_max" datasource="#dsn3#">
	SELECT MAX(MAIN_ROW_SETUP_ID) AS MAX_ID FROM EZGI_DESIGN_MAIN_ROW_SETUP WITH (NOLOCK)
</cfquery>
<cfif not len(get_max.max_id)>
	<cfset  sira = '001'>
<cfelseif len(get_max.max_id) eq 1>
	<cfset  sira = '00#get_max.max_id+1#'>
<cfelseif len(get_max.max_id) eq 2>
	<cfset  sira = '0#get_max.max_id+1#'>
<cfelse>
	<cfset  sira = '#get_max.max_id+1#'>
</cfif>
<cf_catalystHeader>
<div class="col col-12 col-xs-12">
    <cf_box>
		<cfform name="add_default_main" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_default_main">
        	<cf_box_elements>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group" id="item-status">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="checkbox" id="status" name="status" value="1" checked="yes">
                            </div>
                       	</div> 
                        <div class="form-group" id="item-sira">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="849.Modül Kodu"> *</label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="text" name="default_code" id="default_code" value="#sira#" maxlength="20" style="width:150px;">
                            </div>
                      	</div>
                        <div class="form-group" id="item-name">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="110.Modül Adı"> *</label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="text" name="default_type" id="default_type" value="" maxlength="50" style="width:150px;">
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
	document.getElementById('default_type').focus();
	function kontrol()
	{
		if(document.getElementById("default_type").value == "")
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id="110.Modül Adı"> !");
			document.getElementById('default_type').focus();
			return false;
		}
	}
</script>