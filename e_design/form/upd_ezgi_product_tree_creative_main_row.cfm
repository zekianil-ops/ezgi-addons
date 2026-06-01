<!---
    File: upd_ezgi_product_tree_creative_main_row.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK) ORDER BY COLOR_NAME
</cfquery>
<cfquery name="get_design_main_row_setup" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_MAIN_ROW_SETUP WITH (NOLOCK) ORDER BY MAIN_ROW_SETUP_NAME
</cfquery>
<cfquery name="get_design_main_row" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
</cfquery>
<cfquery name="get_design_main_image" datasource="#dsn3#">
	SELECT TOP (1) * FROM EZGI_DESIGN_MAIN_IMAGES WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id# ORDER BY DESIGN_MAIN_ROW_ID DESC
</cfquery>
<cfquery name="get_design" datasource="#dsn3#">
	SELECT  *,ISNULL(IS_PROTOTIP,0) AS PROTOTIP FROM EZGI_DESIGN WITH (NOLOCK) WHERE DESIGN_ID = #get_design_main_row.design_id#
</cfquery>
<cfquery name="get_design_all" datasource="#dsn3#">
	SELECT  
    	ED.PRODUCT_CAT, 
    	ED.DESIGN_ID, 
        ED.DESIGN_NAME, 
        EC.COLOR_NAME
	FROM            
    	EZGI_DESIGN AS ED WITH (NOLOCK) INNER JOIN
        EZGI_COLORS AS EC WITH (NOLOCK) ON ED.COLOR_ID = EC.COLOR_ID
	WHERE        
    	ISNULL(ED.IS_PROTOTIP,0) = #get_design.PROTOTIP#
 	ORDER BY
    	ED.DESIGN_NAME, 
        EC.COLOR_NAME,
        ED.PRODUCT_CAT
</cfquery>
<cfquery name="get_design_defaults" datasource="#dsn3#">
	SELECT ISNULL(EZGI_DESIGN_IFLOW,0) AS EZGI_DESIGN_IFLOW FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfquery name="get_money" datasource="#dsn#">
	SELECT MONEY FROM SETUP_MONEY WITH (NOLOCK) WHERE PERIOD_ID = #session.ep.period_id# ORDER BY MONEY_SYMBOL
</cfquery>
<cfsavecontent variable="right">
	<span class="fa fa-buysellads" style="cursor:pointer" onclick="add_main_transfer();" title="<cf_get_lang dictionary_id='1369.E-Furniture Cad'>"></span>&nbsp;&nbsp;
	<span class="fa fa-gears" style="cursor:pointer" onclick="add_main_rota();" title="<cf_get_lang dictionary_id='36329.Rota Ekle'>"></span>&nbsp;&nbsp;
    <cfif not get_design_main_row.MAIN_PROTOTIP_ID gte 0>
		<span class="fa fa-sign-out" style="cursor:pointer" onclick="design_name_display();" title="<cf_get_lang dictionary_id='43440.Tasarım Adı'>"></span>&nbsp;&nbsp;
    </cfif>
	<span class="fa fa-camera" style="cursor:pointer" onclick="add_main_images();" title="<cf_get_lang dictionary_id='57514.Resim Ekle'>"></span>&nbsp;&nbsp;
 	<span class="fa fa-shopping-basket" style="cursor:pointer" onclick="add_material();" title="<cf_get_lang dictionary_id='890.Sepet Detayı'>"></span>&nbsp;&nbsp;
</cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="module"><cf_get_lang dictionary_id='52.Modül Güncelle'> </cfsavecontent>
	<cf_box title="#module#" right_images="#right#">
    <cf_box>
    	<cfform name="upd_design_main_row" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_product_tree_creative_main_row" enctype="multipart/form-data">
    		<cfinput type="hidden" name="design_main_row_id" value="#attributes.design_main_row_id#">
            <cfinput type="hidden" name="design_id" value="#get_design_main_row.design_id#">
           	<cf_box_elements>
            	<div class="col col-6 col-md-6 col-sm-8 col-xs-12" type="column" index="1" sort="true">
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
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='34004.Spekt Tipi'></label>
                            <div class="col col-8 col-xs-12">
                                <select name="spect_type" id="spect_type" style="width:150px; height:20px" onchange="is_door(this.value)">
                                  	<option value="0" <cfif get_design_main_row.MAIN_PROTOTIP_TYPE eq 0>selected</cfif>><cf_get_lang dictionary_id='58156.Diğer'></option>
                                   	<option value="1" <cfif get_design_main_row.MAIN_PROTOTIP_TYPE eq 1>selected</cfif>><cf_get_lang dictionary_id='802.Kapı'></option>
                                  	<option value="2" <cfif get_design_main_row.MAIN_PROTOTIP_TYPE eq 2>selected</cfif>><cf_get_lang dictionary_id='803.Mutfak'></option>
                                 	<option value="3" <cfif get_design_main_row.MAIN_PROTOTIP_TYPE eq 3>selected</cfif>><cf_get_lang dictionary_id='58937.Transfer İşlemi'></option>
                                    <option value="4" <cfif get_design_main_row.MAIN_PROTOTIP_TYPE eq 4>selected</cfif>><cf_get_lang dictionary_id='64184.Koltuk'></option>
                            	</select>
                            </div>
                        </div>
                        <div class="form-group" id="spect_type_" style="display:<cfif get_design_main_row.MAIN_PROTOTIP_TYPE neq 1>none</cfif>">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='933.Ölçü Tipi'> *</label>
                            <div class="col col-8 col-xs-12">
                                <select name="measure_id" id="measure_id" style="width:150px; height:20px">
                                  	<cfoutput query="get_measure">
                                    	<option value="#MEASURE_ID#" <cfif get_design_main_row.measure_id eq get_measure.MEASURE_ID>selected</cfif>>#MEASURE_NAME#</option>
                                   	</cfoutput>
                           		</select>
                            </div>
                        </div>
                        <div class="form-group" id="private_price_type_" style="display:<cfif get_design_main_row.MAIN_PROTOTIP_TYPE neq 1>none</cfif>">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='812.Özel Ölçü Fiyat Türü'>*</label>
                            <div class="col col-8 col-xs-12">
                            	<select name="private_price_type" id="private_price_type" style="width:90px; height:20px" onchange="private_field();">
                                	<option value="0" <cfif get_design_main_row.private_price_type eq 0>selected</cfif>><cf_get_lang dictionary_id='58546.Yok'></option>
                                	<option value="1" <cfif get_design_main_row.private_price_type eq 1>selected</cfif>><cf_get_lang dictionary_id='58544.Sabit'></option>
                                 	<option value="2" <cfif get_design_main_row.private_price_type eq 2>selected</cfif>><cf_get_lang dictionary_id='47476.Yüzde'></option>
                                 	<option value="3" <cfif get_design_main_row.private_price_type eq 3>selected</cfif>>Ölçü Adları Tablo Değerine Bak</option>
                             	</select>
                            </div>
                        </div>
                     	<div class="form-group" id="private_price_" style="display:<cfif get_design_main_row.MAIN_PROTOTIP_TYPE neq 1>none</cfif>">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="58084.Fiyat"> *</label>
                            <div class="col col-8 col-xs-12">
                              	<cfif len(get_design_main_row.private_price)>
                                 	<cfset private_price = get_design_main_row.private_price>
                               	<cfelse>
                                 	<cfset private_price = 0>
                            	</cfif>
                             	<cfinput type="text" name="private_price" id="private_price" value="#TlFormat(private_price,2)#" style="width:50px; height:20px; text-align:right">
                            </div>
                        </div>
                        <div class="form-group" id="private_price_money_" style="display:<cfif not get_design_main_row.recordcount or get_design_main_row.private_price_type neq 1>none</cfif>">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="48861.Döviz Birimi"> *</label>
                            <div class="col col-8 col-xs-12">
                              	<select name="private_price_money" id="private_price_money" style="width:50px; height:20px">
                                 	<cfoutput query="get_money">
                                  		<option value="#money#" <cfif get_design_main_row.private_price_money eq get_money.money>selected</cfif>>#money#</option> 
                                	</cfoutput>
                             	</select>
                            </div>
                        </div>
                  	</cfif>
                    <cfif not get_design_main_row.MAIN_PROTOTIP_ID gte 0> <!---Özel Mobilya Tasarım Modülü Değilse--->
                        <input type="hidden" name="design-name_display" id="design-name_display" value="1" />
                        <div class="form-group" id="design_name_" style="display:none">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="43440.Tasarım Adı"> *</label>
                            <div class="col col-8 col-xs-12">
                                <select name="new_design_id" id="new_design_id" style="width:130px; height:20px" onChange="hesapla();">
                                    <cfoutput query="get_design_all">
                                        <option value="#DESIGN_ID#" <cfif get_design_main_row.DESIGN_ID eq DESIGN_ID>selected</cfif>>#DESIGN_NAME# - #COLOR_NAME# - #PRODUCT_CAT#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </cfif>
                    <div class="form-group" id="design_name_main_row_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="110.Modül Adı"> *</label>
                    	<div class="col col-8 col-xs-12">
                        	<div class="input-group">
                          		<cfinput type="text" name="design_name_main_row" id="design_name_main_row" value="#get_design_main_row.DESIGN_MAIN_NAME#" maxlength="100" style="width:180px;" >
                          		<span class="input-group-addon">
                                    <cf_language_info 
                                        table_name="EZGI_DESIGN_MAIN_ROW" 
                                        column_name="DESIGN_MAIN_NAME" 
                                        column_id_value="#attributes.design_main_row_id#" 
                                        maxlength="500" 
                                        datasource="#dsn3#" 
                                        column_id="DESIGN_MAIN_ROW_ID" 
                                        control_type="0">
                               	</span>
                          	</div>
                      	</div>
                 	</div>
                    <div class="form-group" id="setup_type_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="36742.Modül"> *</label>
                    	<div class="col col-8 col-xs-12">
                         	<select name="setup_type" id="setup_type" style="width:130px; height:20px" onChange="hesapla();">
                                <option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                                <cfoutput query="get_design_main_row_setup">
                                    <option value="#MAIN_ROW_SETUP_ID#" <cfif get_design_main_row.MAIN_ROW_SETUP_ID eq MAIN_ROW_SETUP_ID>selected</cfif>>#MAIN_ROW_SETUP_NAME#</option>
                                </cfoutput>
                            </select>
                      	</div>
                 	</div>
                    <div class="form-group" id="color_type_">
                     	<label class="col col-4 col-xs-12"> <cf_get_lang dictionary_id='29765.Renk Düzenle'> *</label>
                    	<div class="col col-8 col-xs-12">
                         	<select name="color_type" id="color_type" style="width:130px; height:20px" onChange="hesapla();">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_colors">
                                    <option value="#COLOR_ID#" <cfif get_design_main_row.DESIGN_MAIN_COLOR_ID eq COLOR_ID>selected</cfif> <cfif  get_design.color_id eq COLOR_ID>style="font-weight:bold" </cfif>>#COLOR_NAME#</option>
                                </cfoutput>
                            </select>
                      	</div>
                 	</div>
                    <div class="form-group" id="olcu1_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57686.Ölçü'> - 1 (cm.) </label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="olcu1" id="olcu1" value="#get_design_main_row.olcu1#" maxlength="3" validate="integer" style="width:70px;" onChange="hesapla();">
                      	</div>
                 	</div>
                    <div class="form-group" id="olcu2_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57686.Ölçü'> - 2 (cm.) </label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="olcu2" id="olcu2" value="#get_design_main_row.olcu2#" maxlength="3" validate="integer" style="width:70px;" onChange="hesapla();">
                      	</div>
                 	</div>
                    <div class="form-group" id="olcu3_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57686.Ölçü'> - 3 (cm.) </label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="olcu3" id="olcu3" value="#get_design_main_row.olcu3#" maxlength="3" validate="integer" style="width:70px;" onChange="hesapla();">
                      	</div>
                 	</div>
                    <div class="form-group" id="main_row_amount_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='924.Karma Koli Miktar'> </label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="main_row_amount" value="#get_design_main_row.KARMA_KOLI_MIKTAR#" maxlength="3" validate="integer" style="width:70px; text-align:right">
                      	</div>
                 	</div>
				 	<div class="form-group" id="sales_price_">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36474.Satış Fiyatı'> (<cf_get_lang dictionary_id='45383.KDV Hariç'>) </label>
                      	<div class="col col-6 col-xs-12">
                          	<cfinput type="text" name="sales_price" value="#TlFormat(get_design_main_row.SALES_PRICE,2)#" maxlength="10" style="width:70px; text-align:right">
                      	</div>
                        <div class="col col-2 col-xs-12">
                         	<select name="money" id="money" style="width:40px; height:20px">
                              	<cfoutput query="get_money">
                                 	<option value="#money#" <cfif get_design_main_row.money eq money>selected</cfif>>#money#</option>
                           		</cfoutput>
                        	</select>
                    	</div>
                	</div>
              	</div>
                <div class="col-sm-4 col-xs-12" type="column" index="2" sort="true">
                	<div class="form-group" id="photo" style="text-align:center; vertical-align:middle">
                    	<div class="col col-12 col-xs-12">
                    	<cfif len(get_design_main_image.PATH)>
                    		<img src="/documents/product/<cfoutput>#get_design_main_image.PATH#</cfoutput>" style="height:160px; width:130px;text-align:center;vertical-align:middle">
                        </cfif>
                        </div>
                	</div>
                </div>      
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-12">
                    <cf_workcube_buttons is_upd='1' is_cancel="0"
                            del_function_for_submit='sil()'
                            add_function='kontrol()'>
                </div>
            </cf_box_footer>
        </cfform> 
    </cf_box>
</div>
<script type="text/javascript">
	function kontrol()
	{
		<cfif not get_design_main_row.MAIN_PROTOTIP_ID gte 0> <!---Özel Mobilya Tasarım Modülü Değilse--->
			if(document.getElementById('new_design_id').value != document.getElementById('design_id').value)
			{
				sor=confirm('Modülü Başka Bir Tasarıma Gönderiyorsunuz. Modüle Ait Paket ve Parçalar da Birlikte İlgili Tasarıma Transfer Olacak.');
				if(sor==false)
					return false;
			}
		</cfif>
		if(document.upd_design_main_row.setup_type.value == 0)
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : <cf_get_lang dictionary_id='888.Modül Tipi'>!");
			document.getElementById('setup_type').focus();
			return false;
		}
		else if(document.upd_design_main_row.color_type.value == '')
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='3002.Renk'>!");
			document.getElementById('color_type').focus();
			return false;
		}
		else
		document.getElementById("upd_design_main_row").submit();
	}
	function sil()
	{
		sor = confirm("<cf_get_lang dictionary_id='217.Modülü Silmek İstediğinizden Emin Misiniz'>?");
		if(sor==true)
		window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_product_tree_creative_main_row&design_main_row_id=#attributes.design_main_row_id#</cfoutput>";
		else
		return false;
		
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
	function add_main_images()
	{
		<cfif get_design_main_image.recordcount>
			windowopen('<cfoutput>#request.self#?fuseaction=prod.form_upd_ezgi_popup_image&id=#attributes.design_main_row_id#&type=product&detail=#get_design_main_row.DESIGN_MAIN_NAME#&table=EZGI_DESIGN_MAIN_IMAGES</cfoutput>','small');
		<cfelse>
			windowopen('<cfoutput>#request.self#?fuseaction=prod.form_add_ezgi_popup_image&id=#attributes.design_main_row_id#&type=product&detail=#get_design_main_row.DESIGN_MAIN_NAME#&table=EZGI_DESIGN_MAIN_IMAGES</cfoutput>','small');
		</cfif>
	}
	function add_material()
	{
		windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_design_all_material&design_main_row_id=#attributes.design_main_row_id#&detail=#get_design_main_row.DESIGN_MAIN_NAME#</cfoutput>','small');
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
	function design_name_display()
	{
		if(document.getElementById('design-name_display').value == 	0)
		{
			document.getElementById('design-name_display').value = 1;
			document.getElementById('design_name_').style.display = 'none';
		}
		else
		{
			document.getElementById('design-name_display').value = 0;
			document.getElementById('design_name_').style.display = '';
		}
	}
	function add_main_rota()
	{
		windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_piece_rota&main_id=#attributes.design_main_row_id#</cfoutput>','small');
	}
	function add_main_transfer()
	{
		window.location ="<cfoutput>#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_main_row_from_efurniturecad&design_main_row_id=#attributes.design_main_row_id#</cfoutput>";
	}
</script>