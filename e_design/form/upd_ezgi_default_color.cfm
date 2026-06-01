<!---
    File: upd_ezgi_default_color.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfif not get_defaults.recordcount or not len(get_defaults.DEFAULT_MASTER_PVC_STOCK_ID)>
	<script type="text/javascript">
		alert('<cf_get_lang dictionary_id='2952.Önce Tasarım Genel Default Bilgilerini Tanımlayınız'>!')
		window.history.go(-1);
	</script>	
</cfif>
<cfquery name="get_pvc_info" datasource="#dsn3#">
  	SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_defaults.DEFAULT_MASTER_PVC_STOCK_ID#
</cfquery>
<cfquery name="get_upd" datasource="#dsn3#">
	SELECT *, ISNULL(IS_FLAG,0) AS IS_PATTERN FROM EZGI_COLORS WITH (NOLOCK) WHERE COLOR_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.color_id#">
</cfquery>
<cfquery name="get_thickness" datasource="#dsn3#">
	SELECT THICKNESS_ID, THICKNESS_VALUE, THICKNESS_NAME, UNIT, THICKNESS_PLUS_VALUE FROM EZGI_THICKNESS WITH (NOLOCK) WHERE IS_ACTIVE = 1 ORDER BY THICKNESS_NAME
</cfquery>
<cfquery name="get_thickness_ext" datasource="#dsn3#">
	SELECT THICKNESS_ID, THICKNESS_VALUE, THICKNESS_PRODUCT_NAME, UNIT FROM EZGI_THICKNESS_EXT WITH (NOLOCK) WHERE IS_ACTIVE = 1 ORDER BY THICKNESS_NAME
</cfquery>
<cfif len(get_upd.RELATED_STOCK_ID)>
    <cfquery name="get_stock_info" datasource="#dsn3#">
        SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_upd.RELATED_STOCK_ID#
    </cfquery>
<cfelse>
	<script type="text/javascript">
		alert("Renk İçin Master Ürün Seçmelisiniz!");
		window.close()
	</script>
</cfif>
<cfquery name="get_yonga_levha" datasource="#dsn3#">
	SELECT STOCK_ID, PRODUCT_NAME, THICKNESS_ID FROM EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK) WHERE COLOR_ID = #get_upd.color_id# AND LIST_ORDER_NO = 1
</cfquery>
<cfloop query="get_yonga_levha">
	<cfset 'yonga_levha_stock_id_#THICKNESS_ID#' = STOCK_ID>
    <cfset 'yonga_levha_product_name_#THICKNESS_ID#' = PRODUCT_NAME>
</cfloop>
<cfquery name="get_pvc" datasource="#dsn3#">
	SELECT STOCK_ID, PRODUCT_NAME, THICKNESS_ID, KALINLIK_ETKISI_ID FROM EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK) WHERE COLOR_ID = #get_upd.color_id# AND LIST_ORDER_NO = 3
</cfquery>
<cfloop query="get_pvc">
	<cfset 'pvc_stock_id_#THICKNESS_ID#_#KALINLIK_ETKISI_ID#' = STOCK_ID>
    <cfset 'pvc_product_name_#THICKNESS_ID#_#KALINLIK_ETKISI_ID#' = PRODUCT_NAME>
</cfloop>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
    	<cfform name="upd_default_color" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_default_color">
        	<cfinput type="hidden" name="color_id" value="#attributes.color_id#">
         	<cfinput type="hidden" name="old_stock_id" value="#get_upd.RELATED_STOCK_ID#">
        	<cf_basket_form id="upd_default_color">
                <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                                        <div class="form-group" id="item-status">
                                            <label class="col col-2 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                                            <div class="col col-2 col-xs-12">
                                                <input type="checkbox" id="status" name="status" value="1" <cfif get_upd.IS_ACTIVE>checked</cfif>>
                                            </div>
                                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57789.Özel Kod'></label>
                                            <div class="col col-5 col-xs-12">
                                            	<cfinput type="text" name="special_code" id="special_code" value="#get_upd.PROP_CODE#" maxlength="20" >
                            					<cfinput type="hidden" name="old_special_code" value="#get_upd.PROP_CODE#">
                                          	</div>
                                        </div>
										<div class="form-group" id="item-status">
                                            <label class="col col-2 col-xs-12"><cf_get_lang dictionary_id='76.Desen'></label>
                                            <div class="col col-2 col-xs-12">
                                                <input type="checkbox" id="is_pattern" name="is_pattern" value="1" <cfif get_upd.IS_PATTERN>checked</cfif>>
                                            </div>
                                        </div>
                                  	</div>
                                	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                                        <div class="form-group" id="item-code">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='113.Renk Kodu'> *</label>
	                            			<div class="col col-8 col-xs-12">
                                            	<cfinput type="text" name="default_code" id="default_code" value="#get_upd.PROPERTY_DETAIL_CODE#" maxlength="20" >
                            					<cfinput type="hidden" name="old_default_code" value="#get_upd.PROPERTY_DETAIL_CODE#">
                                          	</div>
                                     	</div>
                                 	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                                        <div class="form-group" id="item-name">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='111.Renk Adı'> *</label>
                                            <div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                <cfinput type="hidden" name="old_default_name" value="#get_upd.COLOR_NAME#">
                                                <cfinput type="text" name="default_name" id="default_name" value="#get_upd.COLOR_NAME#" maxlength="90" style="width:240px;" >
                                                <span class="input-group-addon">
                                                <cf_language_info 
                                                    table_name="PRODUCT_PROPERTY_DETAIL" 
                                                    column_name="PROPERTY_DETAIL" 
                                                    column_id_value="#attributes.color_id#" 
                                                    maxlength="500" 
                                                    datasource="#dsn1#" 
                                                    column_id="PROPERTY_DETAIL_ID" 
                                                    control_type="0">
                                              	</div>
                                                </span>
                                            </div>
                                        </div>
                                  	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                                        <div class="form-group" id="item-master">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='112.Master Ürün'> *</label>
                                            <div class="col col-8 col-xs-12">
                                                <div class="input-group">
                                                    <input type="text" name="urun" id="urun" style="width:240px;" readonly="readonly" value="<cfoutput><cfif len(get_upd.RELATED_STOCK_ID)>#get_stock_info.PRODUCT_NAME#</cfif></cfoutput>">
                           							<input type="hidden" name="pid" id="pid" value="<cfoutput><cfif len(get_upd.RELATED_STOCK_ID)>#get_stock_info.PRODUCT_ID#</cfif></cfoutput>">
                          							<input type="hidden" name="stock_id" id="stock_id" value="<cfoutput><cfif len(get_upd.RELATED_STOCK_ID)>#get_stock_info.STOCK_ID#</cfif></cfoutput>">
                                                    <span class="input-group-addon icon-ellipsis btnPointer" onclick="pencere_ac();"></span>
                                                </div>
                                            </div>
                                        </div>
                                  	</div>
                              	</cf_box_elements>
                    			<cf_box_footer>
									<div class="col col-6 col-xs-12">
                                        <cf_workcube_buttons 
                                        	is_upd='1' 
                                            add_function='kontrol()'
                                            is_delete = '0'>
                                      	<cf_record_info 
                                            query_name="get_upd"


                                            record_emp="RECORD_EMP" 
                                            record_date="record_date"
                                            update_emp="UPDATE_EMP"
                                            update_date="update_date">
                                    </div>
                				</cf_box_footer>
                			</div>
            			</div>
        		</div>
    		</cf_basket_form>
    		<cf_basket id="upd_default_color_bask">
            	<cf_grid_list sort="0">
                    <thead>
                        <tr>
                            <th style="text-align:center; width:30px" rowspan="2" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th style="text-align:center; width:50px" rowspan="2" >&nbsp;<cf_get_lang dictionary_id='151.Kalınlıklar'></th>
                            <th style="text-align:center" rowspan="2" colspan="3" >&nbsp;<cf_get_lang dictionary_id='62.Yonga Levha'></th>
                            <th style="text-align:center" colspan="<cfoutput>#get_thickness_ext.recordcount*3#</cfoutput>">&nbsp;<cf_get_lang dictionary_id='943.PVC'></th>
						</tr>
                        <tr height="20px">
                        	<cfoutput query="get_thickness_ext">
                            	<th style="text-align:center" colspan="3">&nbsp;#THICKNESS_PRODUCT_NAME# #UNIT#</th>
                            </cfoutput>
                        </tr>
                	</thead>
                    <tbody name="table1" id="table1">
                    	<cfif get_thickness.recordcount>
                    		<cfoutput query="get_thickness">
                                <cfif isdefined('yonga_levha_stock_id_#THICKNESS_ID#')>
                                   	<cfset yonga_levha_stock_id = Evaluate('yonga_levha_stock_id_#THICKNESS_ID#')>
                                   	<cfset yonga_levha_product_name = Evaluate('yonga_levha_product_name_#THICKNESS_ID#')>
                                    <cfset new_yonga_product_name = ''>
                                   	<cfset old_type = 1>    		
                            	<cfelse>
                               		<cfset yonga_levha_stock_id = 0>
                                   	<cfset yonga_levha_product_name = ''>
                                    <cfif len(get_upd.RELATED_STOCK_ID)>
                                    	<cfset new_yonga_product_name = '#get_stock_info.PRODUCT_NAME# #get_upd.COLOR_NAME# #get_thickness.THICKNESS_VALUE# #get_thickness.UNIT#'>
                                   	<cfelse>
                                    	<cfset new_yonga_product_name = '#get_upd.COLOR_NAME# #get_thickness.THICKNESS_VALUE# #get_thickness.UNIT#'>
                                    </cfif>
                                    <cfset old_type = 0>
                           		</cfif>
                    			<tr id="frm_row#currentrow#">
                                	<td style="width:30px; height:30px; text-align:right">#currentrow#&nbsp;</td>
                                    <td style="text-align:center">&nbsp;#THICKNESS_VALUE# #UNIT#</td>
                                    <td style="width:25px; text-align:center">
                                     	<cfif old_type eq 1>
                                           	<img src="/images/delete_list.gif" id="eok_#THICKNESS_ID#" style="cursor:pointer" align="absmiddle" border="0" onClick="sil(#THICKNESS_ID#);">
                                            <input type="hidden" name="yonga_levha_thickness_id_#THICKNESS_ID#" id="yonga_levha_thickness_id_#THICKNESS_ID#" value="2">
                                    	<cfelse>
                                        	<img src="images/b_ok.gif" id="ok_#THICKNESS_ID#" style="cursor:pointer" align="absmiddle" border="0" onclick="sec_yonga_levha(#THICKNESS_ID#);" />
                                        	<input type="hidden" name="yonga_levha_thickness_id_#THICKNESS_ID#" id="yonga_levha_thickness_id_#THICKNESS_ID#" value="0">
                                     	</cfif>
                                    </td>
                                    <td style="width:25px; text-align:center">
                                    	<cfif old_type eq 0>
                                  		<a style="cursor:pointer" href"javascript://" onClick="pencere_ac_yonga_levha(#THICKNESS_ID#);">
                                         	<img src="/images/plus_thin.gif" align="absmiddle" border="0">
                                    	</a> 
                                        </cfif>

                                    </td>
                                    <td style="text-align:left">&nbsp;
                                     	&nbsp;
                                        <input type="hidden" name="new_yonga_levha_product_name_#THICKNESS_ID#" id="new_yonga_levha_product_name_#THICKNESS_ID#" value="#new_yonga_product_name#"> 
                                      	<input type="text" name="yonga_levha_product_name_#THICKNESS_ID#" id="yonga_product_name_#THICKNESS_ID#" value="#yonga_levha_product_name#" style="text-align:left; vertical-align:middle; width:95%; border:none"> 
                                        <input type="hidden" name="yonga_levha_stock_id_#THICKNESS_ID#" id="yonga_stock_id_#THICKNESS_ID#" value="#yonga_levha_stock_id#"> 
                                  	</td>
                                    <cfloop query="get_thickness_ext">
                                    	 <cfif isdefined('pvc_stock_id_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#')>
											<cfset pvc_stock_id = Evaluate('pvc_stock_id_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#')>
                                            <cfset pvc_product_name = Evaluate('pvc_product_name_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#')>
                                            <cfset pvc_old_type = 1>    		
                                        <cfelse>
                                            <cfset pvc_stock_id = 0>
                                            <cfset pvc_product_name = ''>
                                            <cfset new_pvc_product_name = '#get_pvc_info.product_name# #get_upd.COLOR_NAME# #get_thickness.THICKNESS_VALUE+get_thickness.THICKNESS_PLUS_VALUE#*#get_thickness_ext.THICKNESS_PRODUCT_NAME#'>
                                            <cfset pvc_old_type = 0>
                                        </cfif>
                                       	<td style="width:30px;text-align:center">
											<cfif pvc_old_type eq 1>
                                                <img src="/images/delete_list.gif" id="pvc_eok_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#" style="cursor:pointer" align="absmiddle" border="0" onClick="pvc_sil(#get_thickness.THICKNESS_ID#,#get_thickness_ext.THICKNESS_ID#);">
                                                <input type="hidden" name="pvc_thickness_id_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#" id="pvc_thickness_id_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#" value="2">
                                            <cfelse>
                                                <img src="images/b_ok.gif" id="pvc_ok_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#" style="cursor:pointer" align="absmiddle" border="0" onclick="sec_pvc(#get_thickness.THICKNESS_ID#,#get_thickness_ext.THICKNESS_ID#);" />
                                                <input type="hidden" name="pvc_thickness_id_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#" id="pvc_thickness_id_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#" value="0">
                                            </cfif>
                                        </td>
                                        <td style="width:30px;text-align:center">
                                        	<cfif pvc_old_type eq 0>
                                            <a style="cursor:pointer" href"javascript://" onClick="pencere_ac_pvc(#get_thickness.THICKNESS_ID#,#get_thickness_ext.THICKNESS_ID#);">
                                                <img src="/images/plus_thin.gif" align="absmiddle" border="0">
                                            </a> 
                                            </cfif>
                                        </td>
                                    	<td style="text-align:left">&nbsp;	
                                        	&nbsp;
                                        	<input type="hidden" name="new_pvc_product_name_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#" id="new_pvc_product_name_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#" value="#new_pvc_product_name#"> 
                                      		<input type="text" name="pvc_product_name_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#" id="pvc_product_name_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#" value="#pvc_product_name#" style="text-align:left; vertical-align:middle; width:95%; border:none"> 
                                        	<input type="hidden" name="pvc_stock_id_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#" id="pvc_stock_id_#get_thickness.THICKNESS_ID#_#get_thickness_ext.THICKNESS_ID#" value="#pvc_stock_id#">
                                        </td>
                                    </cfloop>
                                </tr>
                         	</cfoutput>
                      	</cfif>
                    </tbody>
            	</cf_grid_list>
            </cf_basket>
 		</cfform>
   	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('default_name').focus();
	function kontrol()
	{
		if(document.getElementById("default_name").value == "")
		{
			alert("<cf_get_lang dictionary_id='782.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='111.Renk Adı'> !");
			document.getElementById('default_name').focus();
			return false;
		}
		if(document.getElementById("default_code").value == "")
		{
			alert("<cf_get_lang dictionary_id='782.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='113.Renk Kodu'> !");
			document.getElementById('default_code').focus();
			return false;

		}
		if(document.getElementById("urun").value == "")
		{
			alert("<cf_get_lang dictionary_id='782.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='112.Master Ürün'> !");
			document.getElementById('urun').focus();
			return false;
		}
		stock_id_list = '';
		<cfif get_thickness.recordcount>
        	<cfloop query="get_thickness">
				<cfoutput>
					thickness = #thickness_id#;
				</cfoutput>
				if(document.getElementById('yonga_stock_id_'+thickness).value > 0)
				{
					if(list_len(stock_id_list,','))
					{
						<!---if(stock_id_list.indexOf(document.getElementById('yonga_stock_id_'+thickness).value) != -1)
						{
							alert(document.getElementById('yonga_product_name_'+thickness).value + '<cf_get_lang dictionary_id='153.Ürünü Birden Fazla Satırda Kullanılmış. Tekrar Düzenleyin'>');
							return false;
						}--->
					}
					stock_id_list +=document.getElementById('yonga_stock_id_'+thickness).value+',';
				}
				<cfif get_thickness_ext.recordcount>
        			<cfloop query="get_thickness_ext">
						<cfoutput>
							thickness_ext = #thickness_id#;
						</cfoutput>
						if(document.getElementById('pvc_stock_id_'+thickness+'_'+thickness_ext).value > 0)
						{
							if(list_len(stock_id_list,','))
							{
								<!---if(stock_id_list.indexOf(document.getElementById('pvc_stock_id_'+thickness+'_'+thickness_ext).value) != -1)
								{
									alert(document.getElementById('pvc_product_name_'+thickness+'_'+thickness_ext).value + '<cf_get_lang dictionary_id='153.Ürünü Birden Fazla Satırda Kullanılmış. Tekrar Düzenleyin'>');
									return false;
								}--->
							}
							stock_id_list +=document.getElementById('pvc_stock_id_'+thickness+'_'+thickness_ext).value+',';
						}
						
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>
	}
	function pencere_ac()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=1&master=1&product_id=upd_default_color.pid&field_id=upd_default_color.stock_id&field_name=upd_default_color.urun",'list');
	}
	function pencere_ac_yonga_levha(thickness)
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=1&eleme=1&field_id=upd_default_color.yonga_levha_stock_id_"+thickness+"&field_name=upd_default_color.yonga_levha_product_name_"+thickness,'list');
	}
	function pencere_ac_pvc(thickness,ext)
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=3&eleme=1&field_id=upd_default_color.pvc_stock_id_"+thickness+"_"+ext+"&field_name=upd_default_color.pvc_product_name_"+thickness+"_"+ext,'list');
	}
	function sec_yonga_levha(thickness)
	{
		if(document.getElementById('yonga_levha_thickness_id_'+thickness).value == 0)
		{
			document.getElementById('yonga_product_name_'+thickness).value = document.getElementById('new_yonga_levha_product_name_'+thickness).value;
			document.getElementById('yonga_levha_thickness_id_'+thickness).value = 1;
			document.getElementById('ok_'+thickness).src = "images/c_ok.gif";
		}
		else
		{
			document.getElementById('yonga_product_name_'+thickness).value = '';
			document.getElementById('yonga_levha_thickness_id_'+thickness).value = 0;
			document.getElementById('ok_'+thickness).src = "images/b_ok.gif";
		}
	}
	function sil(thickness)
	{
		if(document.getElementById('yonga_levha_thickness_id_'+thickness).value == 2)
		{
			document.getElementById('yonga_product_name_'+thickness).value = '';
			document.getElementById('yonga_levha_thickness_id_'+thickness).value = 3;
			document.getElementById('eok_'+thickness).src = "images/d_ok.gif";
		}
		else
		{
			document.getElementById('yonga_product_name_'+thickness).value = document.getElementById('new_yonga_levha_product_name_'+thickness).value;
			document.getElementById('yonga_levha_thickness_id_'+thickness).value = 2;
			document.getElementById('eok_'+thickness).src = "images/delete_list.gif";
		}
	}
	function sec_pvc(thickness,ext)
	{
		if(document.getElementById('pvc_thickness_id_'+thickness+'_'+ext).value == 0)
		{
			document.getElementById('pvc_product_name_'+thickness+'_'+ext).value = document.getElementById('new_pvc_product_name_'+thickness+'_'+ext).value;
			document.getElementById('pvc_thickness_id_'+thickness+'_'+ext).value = 1;
			document.getElementById('pvc_ok_'+thickness+'_'+ext).src = "images/c_ok.gif";
		}
		else
		{
			document.getElementById('pvc_product_name_'+thickness+'_'+ext).value = '';
			document.getElementById('pvc_thickness_id_'+thickness+'_'+ext).value = 0;
			document.getElementById('pvc_ok_'+thickness+'_'+ext).src = "images/b_ok.gif";
		}
	}
	function pvc_sil(thickness,ext)
	{
		if(document.getElementById('pvc_thickness_id_'+thickness+'_'+ext).value == 2)
		{
			document.getElementById('pvc_product_name_'+thickness+'_'+ext).value = '';
			document.getElementById('pvc_thickness_id_'+thickness+'_'+ext).value = 3;
			document.getElementById('pvc_eok_'+thickness+'_'+ext).src = "images/d_ok.gif";
		}
		else
		{
			document.getElementById('pvc_product_name_'+thickness+'_'+ext).value = document.getElementById('new_pvc_product_name_'+thickness+'_'+ext).value;
			document.getElementById('pvc_thickness_id_'+thickness+'_'+ext).value = 2;
			document.getElementById('pvc_eok_'+thickness+'_'+ext).src = "images/delete_list.gif";
		}
	}
</script>