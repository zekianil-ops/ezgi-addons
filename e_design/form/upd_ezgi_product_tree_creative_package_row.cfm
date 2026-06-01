<!---
    File: upd_ezgi_product_tree_creative_package_row.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cf_xml_page_edit>
<cfquery name="get_design_package_row" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_PACKAGE_ROW WITH (NOLOCK) WHERE PACKAGE_ROW_ID = #attributes.design_package_row_id#
</cfquery>
<cfquery name="get_design_main_row" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #get_design_package_row.DESIGN_MAIN_ROW_ID#
</cfquery>
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK) ORDER BY COLOR_NAME
</cfquery>
<cfset total_weight =0>
<cfif x_is_weight eq 1>
	<cfinclude template="../query/get_ezgi_product_tree_creative_material.cfm">
    <cfif get_material.recordcount>
        <CFQuery NAme="get_weight" DBtype="Query" >
            SELECT
                SUM(AMOUNT*WEIGHT) AS TOTAL_WEIGHT
            FROM
                get_material
        </cfquery>	
        <cfset total_weight = get_weight.TOTAL_WEIGHT>
    </cfif>
</cfif>


<cfquery name="get_partner_package" datasource="#dsn3#"> <!---Master Pakete Bağlı mı--->
	SELECT        
    	PACKAGE_ROW_ID
	FROM            
    	EZGI_DESIGN_PACKAGE WITH (NOLOCK)
	WHERE        
    	PACKAGE_ROW_ID =
                    	(
                        	SELECT        
                            	PACKAGE_PARTNER_ID
                       		FROM            
                            	EZGI_DESIGN_PACKAGE AS EZGI_DESIGN_PACKAGE_1 WITH (NOLOCK)
                        	WHERE        
                            	PACKAGE_ROW_ID = #attributes.design_package_row_id# AND 
                                PACKAGE_IS_MASTER = 0
                      	)
</cfquery>
<cfquery name="get_partner_package_control" datasource="#dsn3#"> <!---Master Paket mi--->
	SELECT       
    	EZGI_DESIGN_PACKAGE.PACKAGE_ROW_ID, 
      	EZGI_DESIGN_PACKAGE.DESIGN_MAIN_ROW_ID, 
     	EZGI_DESIGN_PACKAGE.PACKAGE_AMOUNT, 
        EZGI_DESIGN_PACKAGE.PACKAGE_NUMBER,
      	EZGI_DESIGN_MAIN_ROW.DESIGN_MAIN_NAME, 
     	EZGI_DESIGN_MAIN_ROW.DESIGN_ID
	FROM            
    	EZGI_DESIGN_PACKAGE WITH (NOLOCK) INNER JOIN
      	EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) ON EZGI_DESIGN_PACKAGE.DESIGN_MAIN_ROW_ID = EZGI_DESIGN_MAIN_ROW.DESIGN_MAIN_ROW_ID
	WHERE        
    	EZGI_DESIGN_PACKAGE.PACKAGE_PARTNER_ID = #attributes.design_package_row_id#
</cfquery>
<cfif get_partner_package_control.recordcount>
	<cfquery name="get_partner_package_used_control" datasource="#dsn3#"> <!---Master Paket ortak paket olarak kullanılmış mı--->
		SELECT     
        	PACKAGE_ROW_ID
		FROM         
        	EZGI_DESIGN_PACKAGE AS EZGI_DESIGN_PACKAGE WITH (NOLOCK)
		WHERE     
        	PACKAGE_IS_MASTER = 0 AND 
            PACKAGE_PARTNER_ID = #attributes.design_package_row_id#
	</cfquery>
<cfelse>
	<cfset get_partner_package_used_control.recordcount = 0>
</cfif>
<cfif get_partner_package.recordcount>
	<cfquery name="get_design_package_image" datasource="#dsn3#">
        SELECT TOP (1) * FROM EZGI_DESIGN_PACKAGE_IMAGES WITH (NOLOCK) WHERE DESIGN_PACKAGE_ROW_ID = #get_partner_package.PACKAGE_ROW_ID# ORDER BY DESIGN_PACKAGE_ROW_ID DESC
    </cfquery>
<cfelse>
	<cfquery name="get_design_package_image" datasource="#dsn3#">
        SELECT TOP (1) * FROM EZGI_DESIGN_PACKAGE_IMAGES WITH (NOLOCK) WHERE DESIGN_PACKAGE_ROW_ID = #attributes.design_package_row_id# ORDER BY DESIGN_PACKAGE_ROW_ID DESC
    </cfquery>
</cfif>
<cfsavecontent variable="right">
	<span class="fa fa-gears" style="cursor:pointer" onclick="add_package_rota();" title="<cf_get_lang dictionary_id='36329.Rota Ekle'>"></span>&nbsp;
    <span class="fa fa-camera" style="cursor:pointer" onclick="add_package_images();" title="<cf_get_lang dictionary_id='57514.Resim Ekle'>"></span>&nbsp;
	<cfif get_partner_package.recordcount> <!---Master Pakete Bağlı ise Master Pakete Git--->
   		<span class="icn-md icon-link" style="cursor:pointer" onclick="go_related_package();" title="<cf_get_lang dictionary_id='57.İlişkili Master Paket'>"></span>
	<cfelse>
    	<span class="fa fa-shopping-basket" style="cursor:pointer" onclick="add_material();" title="<cf_get_lang dictionary_id="890.Sepet Detayı">"></span>
  	</cfif>
</cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="module"><cf_get_lang dictionary_id='1170.Paket Güncelle'> </cfsavecontent>
	<cf_box title="#module#" right_images="#right#">
    	<cfform name="upd_design_package_row" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_product_tree_creative_package_row">
    		<cfinput type="hidden" name="design_package_row_id" value="#attributes.design_package_row_id#">
        	<cf_box_elements>
            	<div class="col col-6 col-md-6 col-sm-8 col-xs-12" type="column" index="1" sort="true">
                	<cfif get_partner_package.recordcount><!---Master Pakete Bağlı mı--->
                        <cfinput type="hidden" name="design_package_partner_id" value="#get_partner_package.PACKAGE_ROW_ID#">
                    <cfelse> <!---Bağlı Ortak Paket Değilse Master Paket Olmalı mı--->
                        <div class="form-group" id="item-package_is_master">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='838.Master Ortak Paket'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="checkbox" name="package_is_master" id="package_is_master" value="1" <cfif get_design_package_row.PACKAGE_IS_MASTER eq 1>checked</cfif> />
                            </div>
                        </div>
                    </cfif>
                    <div class="form-group" id="item-paket_number">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='400.Paket No'></label>
                      	<div class="col col-8 col-xs-12">
                        	<div class="input-group">
                                <cfinput type="text" name="paket_number" id="paket_number" value="#get_design_package_row.PACKAGE_NUMBER#"  validate="integer" maxlength="2" style="width:70px; text-align:right">
                                <cfif get_partner_package.recordcount gt 0>
                                    <span class="input-group-addon" style=" font-weight:bold; color:orange">
                                        &nbsp;<cf_get_lang dictionary_id='59.Ortak Paket'>
                                    </span>
                                </cfif>
                            </div>
                      	</div>
                	</div>
                 	<div class="form-group" id="item-design_name_package_row">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='889.Paket Adı'> *</label>
                    	<div class="col col-8 col-xs-12">
                        	<div class="input-group">
                         		<cfinput type="text" name="design_name_package_row" id="design_name_package_row" value="#get_design_package_row.PACKAGE_NAME#" maxlength="80" style="width:230px;" >
                                
                                <span class="input-group-addon">
                               	 	<cfif not get_partner_package.recordcount>
                                	<cf_language_info 
                                        table_name="EZGI_DESIGN_PACKAGE" 
                                        column_name="PACKAGE_NAME" 
                                        column_id_value="#attributes.design_package_row_id#" 
                                        maxlength="500" 
                                        datasource="#dsn3#" 
                                        column_id="PACKAGE_ROW_ID" 
                                        control_type="0">
                                	</cfif>
                                </span>
                                
                            </div>
                      	</div>
                 	</div>
                    <div class="form-group" id="item-color_type">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='29765.Renk Düzenle'> *</label>
                    	<div class="col col-8 col-xs-12">
                         	<select name="color_type" id="color_type" style="width:130px; height:20px">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_colors">
                                    <option value="#COLOR_ID#" <cfif get_design_package_row.PACKAGE_COLOR_ID eq COLOR_ID>selected</cfif> <cfif  get_design_main_row.DESIGN_MAIN_COLOR_ID eq COLOR_ID>style="font-weight:bold" </cfif>>#COLOR_NAME#</option>
                                </cfoutput>
                            </select>
                      	</div>
                 	</div>
                    <div class="form-group" id="item-paket_boy">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='42844.Uzunluk'> (cm.) </label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="paket_boy" id="paket_boy" value="#Tlformat(get_design_package_row.PACKAGE_BOYU,1)#" maxlength="8" style="width:70px; text-align:right">
                      	</div>
                 	</div>
                    <div class="form-group" id="item-paket_en">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='39470.En'> (cm.) </label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="paket_en" id="paket_en" value="#Tlformat(get_design_package_row.PACKAGE_ENI,1)#" maxlength="8" style="width:70px; text-align:right">
                      	</div>
                 	</div>
                    <div class="form-group" id="item-paket_kalinlik">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='39511.Boy'> (cm.) </label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="paket_kalinlik" id="paket_kalinlik" value="#Tlformat(get_design_package_row.PACKAGE_KALINLIK,1)#" maxlength="7" style="width:70px; text-align:right">
                      	</div>
                 	</div>
                    <div class="form-group" id="item-paket_weight">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29784.Ağırlık'> (kg.) </label>
                    	<div class="col col-4 col-xs-12">
                         	<cfinput type="text" name="auto_paket_weight" readonly="yes" id="auto_paket_weight" value="#Tlformat(total_weight,1)#" maxlength="7" style=" font-weight:bolder; text-align:right; background-color:gainsboro">
                      	</div>
                      	<div class="col col-4 col-xs-12">
                         	<cfinput type="text" name="paket_weight" id="paket_weight" value="#Tlformat(get_design_package_row.PACKAGE_WEIGHT,1)#" maxlength="7" style="text-align:right">
                      	</div>
                 	</div>
                    <div class="form-group" id="item-paket_amount">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='918.Paket Adedi'> </label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="paket_amount" id="paket_amount" value="#get_design_package_row.PACKAGE_AMOUNT#" validate="integer" maxlength="3" style="width:70px; text-align:right">
                      	</div>
                 	</div>
              	</div>
                <div class="col-sm-4 col-xs-12" type="column" index="2" sort="true">
                	<div class="form-group" id="photo" style="text-align:center; vertical-align:middle">
                    	<div class="col col-12 col-xs-12">
                    	<cfif len(get_design_package_image.PATH)>
                    		<img src="/documents/product/<cfoutput>#get_design_package_image.PATH#</cfoutput>" style="height:160px; width:160px;text-align:center;vertical-align:middle">
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
            <br />
            <cf_box_elements>
            	<div class="col col-12">
                	<cf_seperator title="İlişkili Ortak Paketler" id="relared_package_" is_closed="1">
                    <div id="relared_package_" style="width:600px">
                        <cf_form_list id="relared_package_">
                            <thead>
                                <tr style="height:30px">
                                    <th style="text-align:right;width:25px"><cf_get_lang dictionary_id="58577.Sıra"></th>
                                    <th style="text-align:left;width:500px"><cf_get_lang dictionary_id="34970.Modül"></th>
                                    <th style="text-align:right;width:50px"><cf_get_lang dictionary_id="400.Paket No"></th>
                                    <th style="text-align:center;width:40px"><cf_get_lang dictionary_id="58082.Adet"></th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfif get_partner_package_control.recordcount>
                                    <cfoutput query="get_partner_package_control">
                                        <tr>
                                            <td style="text-align:right">#currentrow#&nbsp;</td>
                                            <td nowrap>&nbsp;
                                                <a href="javascript://" onClick="go_related_package_sub(#PACKAGE_ROW_ID#);" class="tableyazi">
                                                    #DESIGN_MAIN_NAME#
                                                </a>
                                            </td>
                                            <td style="text-align:center;">#PACKAGE_NUMBER#</td>
                                            <td style="text-align:center;">#PACKAGE_AMOUNT#</td>
                                        </tr>
                                    </cfoutput>
                                <cfelse>
                                	<tr>
                                    	<td colspan="4" style="text-align:left"><cf_get_lang dictionary_id="57484.Kayıt Yok"></td>
                                    </tr>
                                </cfif>
                           </tbody>
                        </cf_form_list>
                    </div>
                </div>
         	</cf_box_elements>
        </cfform> 
    </cf_box>
</div>
<script type="text/javascript">
	function add_material()
	{
		window.location ="<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_design_all_material&design_package_row_id=#attributes.design_package_row_id#</cfoutput>";
	}
	function go_related_package()
	{
		window.location ="<cfoutput>#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_package_row&design_package_row_id=#get_partner_package.PACKAGE_ROW_ID#</cfoutput>";
	}
	function go_related_package_sub(package_row_id)
	{
		window.location ="<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_upd_ezgi_product_tree_creative_package_row&design_package_row_id="+package_row_id;
	}
	function add_package_rota()
	{
		windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_piece_rota&package_id=#attributes.design_package_row_id#</cfoutput>','small');
	}
	function kontrol()
	{
		if(document.upd_design_package_row.design_name_package_row == 0)
		{


			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : <cf_get_lang dictionary_id='889.Paket Adı'>!");
			document.getElementById('design_name_package_row').focus();
			return false;
		}
		else if(document.upd_design_package_row.color_type.value == '')
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='199.Renk'>!");
			document.getElementById('color_type').focus();
			return false;
		}
		else
		document.getElementById("upd_design_package_row").submit();
	}
	function sil()
	{
		sor = confirm("<cf_get_lang dictionary_id='200.Paketi Silmek İstediğinizden Emin misiniz'>?");
		if(sor==true)
		window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_product_tree_creative_package_row&design_package_row_id=#attributes.design_package_row_id#</cfoutput>";
		else
		return false;
		
	}
	function add_package_images()
	{
		<cfif get_partner_package.recordcount>
			<cfif get_design_package_image.recordcount>
				windowopen('<cfoutput>#request.self#?fuseaction=prod.form_upd_ezgi_popup_image&id=#get_partner_package.PACKAGE_ROW_ID#&type=package&detail=#get_design_package_row.PACKAGE_NAME#&table=EZGI_DESIGN_PACKAGE_IMAGES</cfoutput>','small');
			<cfelse>
				windowopen('<cfoutput>#request.self#?fuseaction=prod.form_add_ezgi_popup_image&id=#get_partner_package.PACKAGE_ROW_ID#&type=package&detail=#get_design_package_row.PACKAGE_NAME#&table=EZGI_DESIGN_PACKAGE_IMAGES</cfoutput>','small');
			</cfif>
		<cfelse>
			<cfif get_design_package_image.recordcount>
				windowopen('<cfoutput>#request.self#?fuseaction=prod.form_upd_ezgi_popup_image&id=#attributes.design_package_row_id#&type=package&detail=#get_design_package_row.PACKAGE_NAME#&table=EZGI_DESIGN_PACKAGE_IMAGES</cfoutput>','small');
			<cfelse>
				windowopen('<cfoutput>#request.self#?fuseaction=prod.form_add_ezgi_popup_image&id=#attributes.design_package_row_id#&type=package&detail=#get_design_package_row.PACKAGE_NAME#&table=EZGI_DESIGN_PACKAGE_IMAGES</cfoutput>','small');
			</cfif>
		</cfif>
	}
</script>