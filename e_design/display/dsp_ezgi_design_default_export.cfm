<!---
    File: dsp_ezgi_design_default_export.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.report_type" default="">
<cfsavecontent variable="title"><cfoutput> <cf_get_lang dictionary_id='836.CSV Dosya Export'></cfoutput></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box title="#title#" scroll="0">
    	<cfform name="search__" action="" method="post">
        	<input type="hidden" name="is_submitted" id="is_submitted" value="0">
             <cf_box_elements>
             	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group">
                        <label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='144.Export Edilecek Dosya Tipi'></label>
                        <div class="col col-6 col-xs-12">
                            <select name="report_type" id="report_type" style="width:190px;">
                                <option value="1" <cfif attributes.report_type eq 1>selected</cfif>><cf_get_lang dictionary_id="145.Renk Dosyası"></option>
                                <option value="2" <cfif attributes.report_type eq 2>selected</cfif>><cf_get_lang dictionary_id="146.Kalınlık Dosyası"></option>
                                <option value="3" <cfif attributes.report_type eq 3>selected</cfif>><cf_get_lang dictionary_id='147.Default Parça Dosyası'></option>
                                <option value="4" <cfif attributes.report_type eq 4>selected</cfif>><cf_get_lang dictionary_id='148.PVC Stok Dosyası'></option>
                                <option value="5" <cfif attributes.report_type eq 5>selected</cfif>><cf_get_lang dictionary_id='180.Hammaddeler'></option>
                            </select>
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
   	<cf_box>
</div>
<cfif isdefined('attributes.report_type') and attributes.report_type eq 1>
	<cfinclude template="exp_ezgi_colors.cfm">	
<cfelseif isdefined('attributes.report_type') and attributes.report_type eq 2>
	<cfinclude template="exp_ezgi_thickness.cfm">	
<cfelseif isdefined('attributes.report_type') and attributes.report_type eq 3>
	<cfinclude template="exp_ezgi_pieces.cfm">
<cfelseif isdefined('attributes.report_type') and attributes.report_type eq 4>
	<cfinclude template="exp_ezgi_stocks.cfm">
<cfelseif isdefined('attributes.report_type') and attributes.report_type eq 5>
	<cfinclude template="exp_ezgi_products.cfm">
</cfif>
<script type="text/javascript">
	function kontrol()
	{
		search__.target='';
		search__.action='';
		return true;
	}
</script>