<!---
    File: cpy_ezgi_product_tree_creative_package_row.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset var_="upd_purchase_basket">
<cfparam name="attributes.urun" default="">
<cfparam name="attributes.sid" default="">
<cfquery name="get_name" datasource="#dsn3#">
	SELECT DESIGN_MAIN_NAME FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
</cfquery>
<cfset urun_adi = get_name.DESIGN_MAIN_NAME> <!---Ürün Adı Tanımı--->
<cfquery name="get_package_control" datasource="#dsn3#"> <!---Kopyalanacak Modülün Paket Tanımı Yapılmış mı--->
	SELECT PACKAGE_NUMBER FROM EZGI_DESIGN_PACKAGE WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
</cfquery>

<cfif len(attributes.sid)>
	<cfquery name="get_package_content" datasource="#dsn3#">
    	SELECT
        	DISTINCT
        	EDP.PIECE_ROW_ID,        
        	EDP.PIECE_TYPE, 
            EDP.PIECE_NAME, 
            EDP.PIECE_CODE, 
            EDP.PIECE_COLOR_ID, 
            EDP.PIECE_RELATED_ID, 
            EDP.PIECE_AMOUNT, 
            EDP.BOYU, 
            EDP.ENI, 
            EDP.PACKAGE_IS_MASTER,	
        	EDP.PACKAGE_PARTNER_ID,
         	EC.COLOR_NAME,
            (
            	SELECT        
                	TOP (1) PPP.PROPERTY_DETAIL
				FROM            
                	#dsn1_alias#.PRODUCT_PROPERTY_DETAIL AS PPP WITH (NOLOCK) INNER JOIN
            		EZGI_DESIGN_DEFAULTS AS EDD WITH (NOLOCK) ON PPP.PRPT_ID = EDD.DEFAULT_THICKNESS_PROPERTY_ID
				WHERE        
                	PPP.PROPERTY_DETAIL_ID = EDP.KALINLIK
            ) AS KALINLIK,
            (SELECT PACKAGE_NUMBER FROM EZGI_DESIGN_PACKAGE WITH (NOLOCK) WHERE PACKAGE_ROW_ID = EDP.DESIGN_PACKAGE_ROW_ID) AS PACKAGE_NUMBER
		FROM            
        	EZGI_DESIGN_PIECE AS EDP WITH (NOLOCK) LEFT OUTER JOIN
         	EZGI_COLORS AS EC WITH (NOLOCK) ON EDP.PIECE_COLOR_ID = EC.COLOR_ID
		WHERE 
        	<cfif isdefined('attributes.main')>       
                EDP.DESIGN_MAIN_ROW_ID = #attributes.sid# AND
					<cfif (isdefined('attributes.package_row_id') and len(attributes.package_row_id)) or not get_package_control.recordcount>
                        EDP.PIECE_TYPE IN (1,2,3,4) AND
                    <cfelse>
                        EDP.PIECE_TYPE IN (1,2,4) AND
                    </cfif>
            <cfelse>
            	EDP.DESIGN_PACKAGE_ROW_ID = #attributes.sid# AND	
            </cfif> 
            EDP.PIECE_STATUS = 1
      	ORDER BY
        	EDP.PIECE_TYPE
    </cfquery>
    <cfset piece_row_id_list = ValueList(get_package_content.PIECE_ROW_ID)>
    <cfloop query="get_package_content">
    	<cfif PIECE_TYPE eq 3>
        	<cfquery name="get_sub_pieces" datasource="#dsn3#">
            	SELECT RELATED_PIECE_ROW_ID FROM EZGI_DESIGN_PIECE_ROW WITH (NOLOCK) WHERE PIECE_ROW_ID = #PIECE_ROW_ID# AND RELATED_PIECE_ROW_ID IS NOT NULL
            </cfquery>
            <cfset 'PIECE_SUB_LIST_#PIECE_ROW_ID#' = ValueList(get_sub_pieces.RELATED_PIECE_ROW_ID)>
        <cfelse>
        	<cfset 'PIECE_SUB_LIST_#PIECE_ROW_ID#' = 0>
        </cfif>
    </cfloop>
<cfelse>
	<cfset get_package_content.recordcount =0>
    <cfset piece_row_id_list = ''>
</cfif>
<cfparam name="attributes.page" default="1">
<cfif isDefined('session.ep.userid')>
	<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfelseif isDefined('session.pp.userid')>
	<cfparam name="attributes.maxrows" default='#session.pp.maxrows#'>
</cfif>
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows)+1 >

<cfsavecontent variable="message"><cfif isdefined('attributes.main')><cf_get_lang dictionary_id='65.Modülden Parça Kopyala'> - <cfelse><cf_get_lang dictionary_id='66.Modüle Paket Kopyala'> - </cfif><cfoutput>#urun_adi#</cfoutput></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#message#" collapsable="0" resize="0" scroll="1">
    	<cfform name="add_piece_relation" id="add_piece_relation" method="post" action="#request.self#?fuseaction=prod.emptypopup_cpy_ezgi_product_tree_creative_package_row">
        	<cfif isdefined('attributes.private')> <!---Özel Tasarımdan Geliyorsa--->
             	<cfinput name="private" id="private" value="#attributes.private#" type="hidden">
           	</cfif>
        	<cfinput name="design_main_row_id" id="design_main_row_id" value="#attributes.design_main_row_id#" type="hidden">
          	<cfinput name="design_main_name" id="design_main_name" value="#urun_adi#" type="hidden">
          	<cfinput name="piece_row_id_list" id="piece_row_id_list" value="#piece_row_id_list#" type="hidden">
          	<cfif isdefined('attributes.package_row_id') and len(attributes.package_row_id)>
            	<cfinput name="package_row_id" value="#attributes.package_row_id#" type="hidden">
         	</cfif>
          	<cfif isdefined('attributes.main')><input type="hidden" name="main" value="1"></cfif>
            <cf_box_elements>
            	<div class="col col-12">
                    <div class="form-group" id="urun">
                        <div class="input-group">
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'>!</cfsavecontent>
                            <cfsavecontent variable="message1"><cfif isdefined('attributes.main')><cf_get_lang dictionary_id='68.Kopyalanacak Modül'><cfelse><cf_get_lang dictionary_id='67.Kopyalanacak Paket'></cfif></cfsavecontent>
                            <cfinput type="text" name="urun" id="urun" value="#attributes.urun#" style="vertical-align:middle" placeholder="#message1#">
                            <cfinput type="hidden" name="sid" id="sid" value="#attributes.sid#">
                            <span class="input-group-addon"><span class="icn-md icon-add" style="cursor:pointer" onclick="relation_product_row();" title="<cf_get_lang dictionary_id='57582.Ekle'>"></span></span>
                        </div>
                    </div>
                </div>
            	<div class="col col-12">
                 	<div class="form-group" id="check1_">
                      	<div class="col col-4">
                         	<div class="input-group">
                            	<span style="height:30px">
                             	<input type="checkbox" name="workcube_select" id="workcube_select" value="1" <cfif isdefined('attributes.workcube_select')>checked</cfif> />&nbsp;<cf_get_lang dictionary_id='69.Workcube Bağlantılı Ortak Parça Olarak Kopyala'> <!---Seçiliyse Modül - Paket - Parça Tasarımlarda Parçanın STOCK_ID bağlantıları aynı olacaktır--->
                                </span>
                        	</div>
                    	</div>
                      	<div class="col col-4">
                         	<div class="input-group">
                            	<span style="height:30px">
                             	<input type="checkbox" name="workcube_select2" id="workcube_select2" value="1" <cfif isdefined('attributes.workcube_select2')>checked</cfif> />&nbsp;<cf_get_lang dictionary_id='1283.Parça Adını Tasarıma Uygula'> <!---Seçiliyse Gelen Parçanın Adını Gönderilecek Tasarıma Uydurur --->
                                </span>
                        	</div>
                    	</div>
                        
                  	</div>
            	</div>
               	<div class="col col-12">
               		<div class="form-group" id="check2_">
                      	<div class="col col-12">
                          	<div class="input-group">
                            	<span style="height:30px">
                             	<cfif isdefined('attributes.package_row_id') and len(attributes.package_row_id)>
                            		<input type="checkbox" name="to_package_select" id="to_package_select" value="1" <cfif isdefined('attributes.to_package_select')>checked</cfif> />&nbsp;<cf_get_lang_main no='2873.Tüm Parçaları Seçilen Pakete Dahil Et'>
                               	<cfelseif not get_package_control.recordcount> <!---Eğer Modüle Paket Tanımı Yapılmamışsa--->
                                	<input type="checkbox" name="package_piece_select" id="package_piece_select" value="1" onChange="tumunu_sec()" <cfif isdefined('attributes.package_piece_select')>checked</cfif> />&nbsp;<cf_get_lang_main no='2874.Tüm Paketleri ve Parçaları Uyumlu Kopyala'>
                             	</cfif>
                                </span>
                       		</div>
                     	</div>
                  	</div>
               	</div>
      		</cf_box_elements>
            <cf_flat_list>
                <thead>
                    <tr>
                        <th style="text-align:center;width:20px;"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        <cfif isdefined('attributes.main')>
                            <th style="text-align:center;width:20px;"></th>
                        </cfif>
                        <th style="text-align:center;width:20px;"><cf_get_lang dictionary_id='835.ÜK'></th>
                        <th style="text-align:center;width:20px;"></th>
                        <th style="text-align:center;width:30px;"><cf_get_lang dictionary_id='45548.Paket'></th>
                        <th style="text-align:center;width:20px;"><cf_get_lang dictionary_id='58585.Kod'></th>
                        <th style="text-align:center;width:290px;"><cf_get_lang dictionary_id='399.Parça Adı'></th>
                        <th style="text-align:center;width:40px;"><cf_get_lang dictionary_id='99.Boy'></th>
                        <th style="text-align:center;width:40px;"><cf_get_lang dictionary_id='98.En'></th>
                        <th style="text-align:center;width:20px;"><cf_get_lang dictionary_id='57696.Yükseklik'></th>
                        <th style="text-align:center;width:20px;"><cf_get_lang dictionary_id='57635.Miktar'></th>
                        <th style="text-align:center;width:110px;"><cf_get_lang dictionary_id='199.Renk'></th>
                    </tr>
                </thead>
                <tbody>
                    <cfif get_package_content.recordcount>
                        <cfoutput query="get_package_content">
                            <cfif len(attributes.sid)>
                                <cfinput type="hidden" name="record_count" value="#PIECE_ROW_ID#">
                                <input type="hidden" name="piece_type_#PIECE_ROW_ID#" value="#PIECE_TYPE#">
                                <input type="hidden" name="piece_sub_id_#PIECE_ROW_ID#" id="piece_sub_id_#PIECE_ROW_ID#" value="#Evaluate('PIECE_SUB_LIST_#PIECE_ROW_ID#')#" />
                            </cfif>
                            <cfif PACKAGE_IS_MASTER gt 0>
                                <input type="hidden" name="piece_ortak_#PIECE_ROW_ID#" value="M">
                            <cfelse>
                                <cfif PACKAGE_PARTNER_ID gt 0>
                                    <input type="hidden" name="piece_ortak_#PIECE_ROW_ID#" value="O">
                                <cfelse>
                                    <input type="hidden" name="piece_ortak_#PIECE_ROW_ID#" value=""> 
                                </cfif>
                            </cfif>
                            <tr id="frm_row_exit#currentrow#">
                                <td style="text-align:right;vertical-align:middle;">#currentrow#</td>
                                <cfif isdefined('attributes.main')>
                                    <td style="text-align:center;vertical-align:middle;" >
                                        <input type="checkbox" id="a_#PIECE_ROW_ID#" name="a_#PIECE_ROW_ID#" onClick="control_piece_type(#PIECE_TYPE#,#PIECE_ROW_ID#)" value="1" <cfif isdefined('attributes.package_piece_select')>checked disabled</cfif>/>
                                     </td>
                                </cfif>
                                <td 
                                    title="
                                        <cfif PACKAGE_IS_MASTER gt 0>
                                            <cf_get_lang dictionary_id='204.Master Paket Parçası'>
                                        <cfelse>
                                            <cfif PACKAGE_PARTNER_ID gt 0>
                                                <cf_get_lang dictionary_id='64.Ortak Paket Parçası'>
                                            </cfif>
                                        </cfif>" 
                                    style="text-align:center;
                                    <cfif PACKAGE_IS_MASTER gt 0>
                                        background-color:lightseagreen
                                    <cfelse>
                                        <cfif PACKAGE_PARTNER_ID gt 0>
                                            background-color:MistyRose
                                        </cfif>
                                    </cfif>">
                                        <cfif PIECE_RELATED_ID gt 0>
                                            <img src="/images/c_ok.gif">
                                        </cfif>
                                </td>
                                <td style="text-align:center;">
                                    <cfif PIECE_TYPE eq 1>
                                        <img src="/images/butcegider.gif" title="<cf_get_lang dictionary_id='62.Yonga Levha'>">
                                    <cfelseif PIECE_TYPE eq 2>
                                        <img src="/images/arrow_up.png" title="<cf_get_lang dictionary_id='402.Genel Reçete'>">
                                    <cfelseif PIECE_TYPE eq 3>
                                        <img src="/images/elements.gif" title="<cf_get_lang dictionary_id='403.Montaj Ürünü'>">
                                    <cfelseif PIECE_TYPE eq 4>
                                        <img src="/images/promo_multi.gif" title="<cf_get_lang dictionary_id='404.Hammadde'>">
                                    </cfif>
                                </td>
                                <td style="text-align:center;">#PACKAGE_NUMBER#</td>
                                <td style="text-align:center;">#PIECE_CODE#</td>
                                <td nowrap style="width:170px;text-align:left;">
                                    <input type="text" style="width:100%; border:none;cursor:pointer;" readonly="readonly" value="#PIECE_NAME#" />
                                </td>
                                <td style="text-align:center;">#BOYU#</td>
                                <td style="text-align:center;">#ENI#</td>
                                <td style="text-align:center;">#KALINLIK#</td>
                                <td style="text-align:center;">#PIECE_AMOUNT#</td>
                                <td style="text-align:center;" nowrap>#COLOR_NAME#</td>
                            </tr>
                        </cfoutput>
                        <tfoot>
                            <tr>
                                <td colspan="8" style="text-align:left; vertical-align:bottom; height:30px;" >
                                	<cfif isdefined('attributes.main')>
                                        <cfsavecontent variable="sec"><cf_get_lang dictionary_id='206.Hepsini Seç'></cfsavecontent>
                                        <cfsavecontent variable="kaldir"><cf_get_lang dictionary_id='205.Hepsini Kaldır'></cfsavecontent>
                                    	<cfinput type="button" name="buton" id="buton" value="#sec#" onclick="hesini_sec(-1);" />
                                    	<cfinput type="button" name="buton_sil" id="buton_sil" value="#kaldir#" style="display:none" onclick="hesini_sec(-2);" />
                                    </cfif>
                                    
                                </td>
                                <td colspan="4" style="text-align:right; vertical-align:bottom;" >
                                    <cfsavecontent variable="vazgec"><cf_get_lang dictionary_id='57462.Vazgeç'></cfsavecontent>
                                    <cfsavecontent variable="kaydet"><cf_get_lang dictionary_id='57461.Kaydet'></cfsavecontent>
                                    <cfinput type="button" value="#vazgec#" name="cnc_buton" onClick="window.close();">
                                    <cfinput type="submit" value="#kaydet#" name="upd_buton" id="upd_buton" onClick="input_control();">
                                </td>
                            </tr>
                        </tfoot>
                    </cfif>
                </tbody>
           	</cf_flat_list>
       	</cfform> 
	</cf_box>
</div>
<script type="text/javascript">
	function relation_product_row(product_type, creative_id, satir_no)
	{
		<cfif isdefined('attributes.main')>
			windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_ezgi_stocks&ezgi_design=2&product_type=2&price_cat=-2&add_product_cost=1&module_name=product&var_=#var_#&is_action=1&startdate=&price_lists=&product_id=add_piece_relation.pid&field_id=add_piece_relation.sid&field_name=add_piece_relation.urun'</cfoutput>,'page');
		<cfelse>
			windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_ezgi_stocks&ezgi_design=2&product_type=3&price_cat=-2&add_product_cost=1&module_name=product&var_=#var_#&is_action=1&startdate=&price_lists=&product_id=add_piece_relation.pid&field_id=add_piece_relation.sid&field_name=add_piece_relation.urun'</cfoutput>,'page');
		</cfif>
	}
	function add_ezgi_row(stock_id,product_name)
	{
		document.getElementById('urun').value = product_name;
		document.getElementById('sid').value = stock_id;
		document.getElementById("add_piece_relation").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_cpy_ezgi_product_tree_creative_package_row";
		document.getElementById("add_piece_relation").submit();
	}
	function control_piece_type(piece_type,piece_row_id)
	{
		var sub_list = document.getElementById('piece_sub_id_'+piece_row_id).value;
		sub_list_len = list_len(sub_list);
		for (i = 1; i <= sub_list_len; i++) 
		{ 
			list_value = list_getat(sub_list,i);
			if(list_value > 0)
			{
					if(eval('document.all.a_'+piece_row_id).checked==false)						   
						document.getElementById('a_'+list_value).checked = false;
					else
						document.getElementById('a_'+list_value).checked = true;
						
			}
		}
	}
	function hesini_sec(type)
	{
		var piece_row_id_list = document.getElementById('piece_row_id_list').value;
		piece_row_id_list_len = list_len(piece_row_id_list);
		for (j = 1; j <= piece_row_id_list_len; j++) 
		{
			piece_list_value = list_getat(piece_row_id_list,j);
			if(piece_list_value > 0)
			{
				if(type == -1)
					document.getElementById('a_'+piece_list_value).checked = true;
				else
					document.getElementById('a_'+piece_list_value).checked = false;
			}
		}
		if(type == -1)
		{
			document.getElementById('buton').style.display="none";
			document.getElementById('buton_sil').style.display="";
		}
		else
		{
			document.getElementById('buton').style.display="";
			document.getElementById('buton_sil').style.display="none";
		}
	}
	function input_control()
	{
		
		document.getElementById('upd_buton').style.display = 'none';
		return true;	
	}
</script>