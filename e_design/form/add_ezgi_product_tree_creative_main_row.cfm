<!---
    File: add_ezgi_product_tree_creative_main_row.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK) WHERE IS_ACTIVE = 1 ORDER BY COLOR_NAME
</cfquery>
<cfquery name="get_design_main_row_setup" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_MAIN_ROW_SETUP WITH (NOLOCK) ORDER BY MAIN_ROW_SETUP_NAME
</cfquery>
<cfquery name="get_design" datasource="#dsn3#">
	SELECT  * FROM EZGI_DESIGN WITH (NOLOCK) WHERE DESIGN_ID = #attributes.design_id#
</cfquery>
<cfquery name="get_design_main_row" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE DESIGN_ID = #attributes.design_id#
</cfquery>
<cfquery name="get_design_defaults" datasource="#dsn3#">
	SELECT ISNULL(EZGI_DESIGN_IFLOW,0) AS EZGI_DESIGN_IFLOW FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfquery name="get_money" datasource="#dsn#">
	SELECT MONEY FROM SETUP_MONEY WITH (NOLOCK) WHERE PERIOD_ID = #session.ep.period_id# ORDER BY MONEY_SYMBOL
</cfquery>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="ekle">
		<cf_get_lang dictionary_id='54.Modül Ekle'>
	</cfsavecontent>
	<cf_box title="#ekle#">
    <cf_box>
    	<cfform name="add_design_main_row" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_product_tree_creative_main_row">
    		<cfinput type="hidden" name="design_id" value="#attributes.design_id#">
           	<cf_box_elements>
            	<div class="col col-6 col-md-6 col-sm-9 col-xs-12" type="column" index="1" sort="true">
					<cfif Len(get_design.IS_PROTOTIP) and get_design.IS_PROTOTIP eq 1>
                        <cfquery name="get_measure" datasource="#dsn3#">
                            SELECT       
                                MEASURE_ID, 
                                MEASURE_NAME
                            FROM            
                                EZGI_VIRTUAL_OFFER_ROW_MEASURE WITH (NOLOCK)
                            ORDER BY 
                                MEASURE_NAME
                        </cfquery>
                        <div class="form-group" id="spect_tur">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="34004.Spekt Tipi"></label>
                            <div class="col col-8 col-xs-12">
                                <select name="spect_type" id="spect_type" style="width:150px; height:20px" onchange="is_door(this.value)">
                             		<option value="0"><cf_get_lang dictionary_id="58156.Diğer"></option>
                                	<option value="1"><cf_get_lang dictionary_id="802.Kapı"></option>
                                 	<option value="2"><cf_get_lang dictionary_id="803.Mutfak"></option>
                                	<option value="3"><cf_get_lang dictionary_id="58937.Transfer İşlemi"></option>
                                    <option value="4"><cf_get_lang dictionary_id='64184.Koltuk'></option>
                             	</select>
                            </div>
                        </div>
                        <div class="form-group" id="spect_type_" style="display:none">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="933.Ölçü Tipi"> *</label>
                            <div class="col col-8 col-xs-12">
                                <select name="measure_id" id="measure_id" style="width:150px; height:20px">
                                   	<cfoutput query="get_measure">
                                      	<option value="#MEASURE_ID#" >#MEASURE_NAME#</option>
                                  	</cfoutput>
                              	</select>
                            </div>
                        </div>
                        <div class="form-group" id="private_price_type_" style="display:none">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="812.Özel Ölçü Fiyat Türü"> *</label>
                            <div class="col col-8 col-xs-12">
                           		<select name="private_price_type" id="private_price_type" onchange="private_field();">
                                 	<option value="0"><cf_get_lang dictionary_id="58546.Yok"></option>
                                 	<option value="1"><cf_get_lang dictionary_id="58544.Sabit"></option>
                                  	<option value="2"><cf_get_lang dictionary_id="47476.Yüzde"></option>
                                    <option value="3">Ölçü Adları Tablo Değerine Bak</option>
                              	</select>
                            </div>
                        </div>
                     	<div class="form-group" id="private_price_" style="display:none">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="58084.Fiyat"> *</label>
                            <div class="col col-8 col-xs-12">
                                  	<cfinput type="text" name="private_price" id="private_price" value="#TlFormat(0,2)#" style="text-align:right">
                            </div>
                        </div>
                        <div class="form-group" id="private_price_money_" style="display:none">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="48861.Döviz Birimi"> *</label>
                            <div class="col col-8 col-xs-12">
                                	<select name="private_price_money" id="private_price_money" >
                                      	<cfoutput query="get_money">
                                       		<option value="#money#">#money#</option> 
                                    	</cfoutput>
                                	</select>
                            </div>
                        </div>
                  	</cfif>
                    <div class="form-group" id="design_name_main_row_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="110.Modül Adı">*</label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="design_name_main_row" id="design_name_main_row" value="#get_design.DESIGN_NAME#" maxlength="100">
                      	</div>
                 	</div>
                    <div class="form-group" id="setup_type_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="141.Modül"> *</label>
                    	<div class="col col-8 col-xs-12">
                         	<select name="setup_type" id="setup_type" style="width:130px; height:20px" onChange="hesapla();">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_design_main_row_setup">
                                    <option value="#MAIN_ROW_SETUP_ID#" >#MAIN_ROW_SETUP_NAME#</option>
                                </cfoutput>
                            </select>
                      	</div>
                 	</div>
                    <div class="form-group" id="color_type_">
                     	<label class="col col-4 col-xs-12"> <cf_get_lang dictionary_id ='29765.Renk Düzenle'> *</label>
                    	<div class="col col-8 col-xs-12">
                         	<select name="color_type" id="color_type" style="width:130px; height:20px" onChange="hesapla();">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_colors">
                                    <option value="#COLOR_ID#" <cfif  get_design.color_id eq COLOR_ID>style="font-weight:bold" selected </cfif>>#COLOR_NAME#</option>
                                </cfoutput>
                            </select>
                      	</div>
                 	</div>
                    <div class="form-group" id="olcu1_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57686.Ölçü'> - 1 (cm.) </label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="olcu1" id="olcu1" value="" maxlength="3" validate="integer" style="width:70px;" onChange="hesapla();">
                      	</div>
                 	</div>
                    <div class="form-group" id="olcu2_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57686.Ölçü'> - 2 (cm.) </label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="olcu2" id="olcu2" value="" maxlength="3" validate="integer" style="width:70px;" onChange="hesapla();">
                      	</div>
                 	</div>
                    <div class="form-group" id="olcu3_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57686.Ölçü'> - 3 (cm.) </label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="olcu3" id="olcu3" value="" maxlength="3" validate="integer" style="width:70px;" onChange="hesapla();">
                      	</div>
                 	</div>
                    <div class="form-group" id="main_row_amount_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='924.Karma Koli Miktar'> </label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="main_row_amount" value="1" maxlength="3" validate="integer" style="width:70px; text-align:right">
                      	</div>
                 	</div>
                 	<cfif get_design_defaults.EZGI_DESIGN_IFLOW eq 1>
					 	<div class="form-group" id="sales_price_">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36474.Satış Fiyatı'> (<cf_get_lang dictionary_id='45383.KDV Hariç'> )</label>
                            <div class="col col-8 col-xs-12">
                            	<div class="input-group">
                                    <cfinput type="text" name="sales_price" value="#TlFormat(0,2)#" maxlength="10" style="width:70px; text-align:right; height:20px">
                                    <select name="money" id="money" style="width:40px; height:20px">
                                        <cfoutput query="get_money">
                                            <option value="#money#">#money#</option>
                                        </cfoutput>
                                    </select>
                                </div>
                            </div>
                        </div>
                  	</cfif>
              	</div>      
            </cf_box_elements>
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
		if(document.add_design_main_row.setup_type.value == '')
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> !");
			document.getElementById('setup_type').focus();
			return false;
		}
		if(document.add_design_main_row.color_type.value == '')
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> !");
			document.getElementById('color_type').focus();
			return false;
		}
		<cfif Len(get_design.IS_PROTOTIP) and get_design.IS_PROTOTIP eq 1>
			if(document.getElementById('spect_type').value==1)
			{
				if(document.getElementById('measure_id').value=='')
				{
					alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> !");
					document.getElementById('measure_id').focus();
					return false;
				}
			}
		</cfif>
	}
	function hesapla()
	{
		var main_row_name = <cfoutput>'#get_design.design_name#'</cfoutput>;
			
		if(document.getElementById('setup_type').value > 0)
		{
			<cfloop query="get_design_main_row_setup">
				main_row_setup_id = <cfoutput>#get_design_main_row_setup.main_row_setup_id#</cfoutput>;
				main_row_setup_name = <cfoutput>'#get_design_main_row_setup.main_row_setup_name#'</cfoutput>;
				if(document.getElementById('setup_type').value == main_row_setup_id)
				{
					main_row_name = main_row_name +' '+ main_row_setup_name
				}
			</cfloop>
		}
		if(document.getElementById('color_type').value > 0)
		{
			<cfloop query="get_colors">
				color_id = <cfoutput>#get_colors.color_id#</cfoutput>;
				color_name = <cfoutput>'#get_colors.color_name#'</cfoutput>;
				if(document.getElementById('color_type').value == color_id)
				{
					main_row_name = main_row_name +' ('+ color_name +') '
				}

			</cfloop>
		}
		if(document.getElementById('olcu1').value > 0)
		{
			main_row_name = main_row_name + ' - ' + document.getElementById('olcu1').value;
		}
		if(document.getElementById('olcu2').value > 0)
		{
			main_row_name = main_row_name + ' X ' + document.getElementById('olcu2').value;
		}
		if(document.getElementById('olcu3').value > 0)
		{
			main_row_name = main_row_name + ' X ' + document.getElementById('olcu3').value;
		}
		document.getElementById('design_name_main_row').value = main_row_name;
	}
	function is_door(spect_type_)
	{
		if(document.getElementById('spect_type').value==1)
		{
			document.getElementById('spect_type_').style.display='';
			document.getElementById('private_price_type_').style.display='';
		}
		else
		{
			document.getElementById('spect_type_').style.display='none';
			document.getElementById('private_price_type_').style.display='none';
		}
	}
	function private_field()
	{
		private_= document.getElementById('private_price_type').value;
		if(private_ == 0 || private_ == 3)
		{
			document.getElementById('private_price_').style.display='none';	
			document.getElementById('private_price_money_').style.display='none';	
		}
		else if(private_ == 1)
		{
			document.getElementById('private_price_').style.display='';	
			document.getElementById('private_price_money_').style.display='';	
		}
		else if(private_ == 2)
		{
			document.getElementById('private_price_').style.display='';	
			document.getElementById('private_price_money_').style.display='none';	
		}
	}
</script>