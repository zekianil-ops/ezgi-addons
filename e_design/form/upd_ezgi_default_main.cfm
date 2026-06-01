<!---
    File: upd_ezgi_default_main.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_MAIN_ROW_SETUP WITH (NOLOCK) WHERE MAIN_ROW_SETUP_ID = #attributes.main_id#
</cfquery>
<cfquery name="get_delete_control" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE MAIN_ROW_SETUP_ID = #attributes.main_id#
</cfquery>
<cf_catalystHeader>
<div class="col col-12 col-xs-12">
    <cf_box>
    	<cfform name="upd_default_main" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_default_main">
        	<cfinput type="hidden" name="main_id" value="#attributes.main_id#">
          	<cf_box_elements>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group" id="item-status">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="checkbox" id="status" name="status" value="1"<cfif get_upd.STATUS eq 1>checked</cfif>>
                            </div>
                       	</div> 
                        <div class="form-group" id="item-sira">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="849.Modül Kodu"> *</label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="text" name="default_code" id="default_code"  value="#get_upd.MAIN_ROW_SETUP_CODE#" maxlength="20">
                            </div>
                      	</div>
                        <div class="form-group" id="item-name">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="110.Modül Adı"> *</label>
                            <div class="col col-8 col-xs-12">
                            	<div class="input-group">
                                <cfinput type="text" name="default_type" id="default_type" value="#get_upd.MAIN_ROW_SETUP_NAME#" maxlength="50">
                               	<span class="input-group-addon">
                                <cf_language_info 
                                    table_name="EZGI_DESIGN_MAIN_ROW_SETUP" 
                                    column_name="MAIN_ROW_SETUP_NAME" 
                                    column_id_value="#attributes.main_id#" 
                                    maxlength="500" 
                                    datasource="#dsn3#" 
                                    column_id="MAIN_ROW_SETUP_ID" 
                                    control_type="0"></span>
                             	</div>
                            </div>
                      	</div>
             	</div> 
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-12">
               		<cfif not get_delete_control.recordcount>
                    	<cf_workcube_buttons 
                                is_upd='1' 
                               	del_function_for_submit='del_kontrol()'
                                add_function='kontrol()'>
                  	<cfelse>
                    	<cf_workcube_buttons 
                                is_upd='1' 
                                is_delete = '0' 
                                add_function='kontrol()'>
                 	</cfif>
                        <cf_record_info 
                            query_name="get_upd"
                            record_emp="RECORD_EMP" 
                            record_date="record_date"
                            update_emp="UPDATE_EMP"
                            update_date="update_date">
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
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='110.Modül Adı'> !");
			document.getElementById('default_type').focus();
			return false;
		}
	}
	function del_kontrol()
	{
		window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_default_main&main_id=#attributes.main_id#</cfoutput>";
		return true;
	}
</script>