<!---
    File: add_ezgi_product_tree_creative_import_piece_row.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK) ORDER BY COLOR_NAME 
</cfquery>
<cfquery name="get_design_main_row" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
</cfquery>
<cfsavecontent variable="parça_trnsfr"><cf_get_lang dictionary_id='941.Parça Transfer'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#parça_trnsfr#">
    	<cfform name="add_design_import_piece_row" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_product_tree_creative_import_piece_row" enctype="multipart/form-data">
			<cfoutput>
            	<cfinput type="hidden" name="design_main_row_id" value="#attributes.design_main_row_id#">
                <cf_box_elements>
            		<div class="col col-6 col-md-6 col-sm-9 col-xs-12" type="column" index="1" sort="true">
                    	<div class="form-group" id="modul_name">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='110.Modül Adı'></label>
                            <div class="col col-8 col-xs-12">
                                #get_design_main_row.DESIGN_MAIN_NAME#
                            </div>
                        </div>
                        <div class="form-group" id="import_type">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58530.Aktarım Türü'></label>
                            <div class="col col-8 col-xs-12">
                                <select name="file_type" id="file_type" style="width:200px;">
                                    <option value="0"><cf_get_lang dictionary_id='29731.Excel'></option>
                                    <option value="1"><cf_get_lang dictionary_id='894.CSV'></option>
                                    <option value="2"><cf_get_lang dictionary_id='895.Autocad'></option>
                                    <option value="3"><cf_get_lang dictionary_id='896.TopSolid'></option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="file_format_type">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='37763.Belge Formatı'></label>
                            <div class="col col-8 col-xs-12">
                                <select name="file_format" id="file_format" style="width:200px;">
                                    <option value="UTF-8"><cf_get_lang dictionary_id='43388.UTF-8'></option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="document_type">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57468.Belge'>*</label>
                            <div class="col col-8 col-xs-12">
                                <input type="file" name="uploaded_file" id="uploaded_file">
                            </div>
                        </div>
                  	</div>      
            	</cf_box_elements>
          	</cfoutput>
            <cf_box_footer>
                <div class="col col-12">
                    <cf_workcube_buttons is_upd='0'  add_function='kontrol()'> 
                </div>
            </cf_box_footer>
        </cfform> 
    </cf_box>
</div>
<script type="text/javascript">
	function kontrol()
	{
		if(document.add_design_import_piece_row.uploaded_file.value == '')
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : <cf_get_lang dictionary_id='57468.Belge'> !");
			document.getElementById('uploaded_file').focus();
			return false;
		}
		else
			return true;
	}
</script>
