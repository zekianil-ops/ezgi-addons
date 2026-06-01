<!---
    File: list_ezgi_iflow_transferring.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.transfer_type" default="">
<cfparam name="attributes.operation_type_id" default="">
<br />
<cfquery name="get_operations" datasource="#dsn3#">
	SELECT OPERATION_TYPE_ID, OPERATION_TYPE FROM OPERATION_TYPES WHERE OPERATION_STATUS = 1 ORDER BY OPERATION_TYPE
</cfquery>
<cfsavecontent variable="aktarim"><cf_get_lang dictionary_id='36012.Aktarım'></cfsavecontent>
<div class="col col-12 col-xs-12">
    <cf_box title="#aktarim#">
		<cfform name="search__" action="" method="post">
        	<input type="hidden" name="is_submitted" id="is_submitted" value="0">
        	<cf_box_elements>
                <div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group" id="item-status">
                            <label class="col col-4 col-xs-12">İşlem Tipi</label>
                            <div class="col col-8 col-xs-12">
                                <select name="transfer_type" id="transfer_type" style="width:190px; height:20px">
                                    <option value="1" <cfif attributes.transfer_type eq 1>selected</cfif>>Nesting İçin Excel Dosyası Oluştur</option>
                                    <!---<option value="2" <cfif attributes.transfer_type eq 2>selected</cfif>>Ahşap Levha Optimizasyon</option>--->
                                </select>
                            </div>
                       	</div> 
                        <div class="form-group" id="item-sira">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='401.İlişkili Operasyonlar'></label>
                            <div class="col col-6 col-xs-12">
                                <select name="operation_type_id" id="operation_type_id" style="width:190px; height:20px">
                                    <option value="" <cfif attributes.operation_type_id eq ''>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="get_operations">
                                        <option value="#OPERATION_TYPE_ID#" <cfif attributes.operation_type_id eq OPERATION_TYPE_ID>selected</cfif>>#OPERATION_TYPE#</option>
                                    </cfoutput>
                                </select>
                          	</div>
                            <div class="col col-2 col-xs-12">
                                <cf_get_lang dictionary_id='30056.Olmayanlar'>
                                <input name="reverse_answer" type="checkbox" <cfif isdefined('attributes.reverse_answer')>selected</cfif>>
                            </div>
                      	</div>
             	</div> 
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-12">
                	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58966.Oluştur'></cfsavecontent>
            		<cf_workcube_buttons is_upd=1 insert_info='#message#' is_delete=0 add_function='kontrol()'>
                </div>
            </cf_box_footer>
        </cfform>
  	</cf_box>
</div>
<cfif isdefined('attributes.transfer_type') and attributes.transfer_type eq 1>
	<cfinclude template="/v16/add_options/ezgi/e_furniture/exp_cutting_list.cfm">	
<cfelseif isdefined('attributes.transfer_type') and attributes.transfer_type eq 2>
	<cfinclude template="/v16/add_options/ezgi/e_furniture/net_exp_cutting_list.cfm">
<cfelseif isdefined('attributes.transfer_type') and attributes.transfer_type eq 3>
	<cfinclude template="/v16/add_options/ezgi/e_furniture/net_cutting_list.cfm">
</cfif>
<script type="text/javascript">
	function kontrol()
	{
		search__.target='';
		search__.action='';
		return true;
	}
</script>