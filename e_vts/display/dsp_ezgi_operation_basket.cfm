<!---
    File: dsp_ezgi_operation_basket.cfm
    Folder: Add_Ons\ezgi\e-vts\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---
IS_STAGE = 0 Onaysız Basket
IS_STAGE = 1 Onaylı Basket
IS_STAGE = 2 Üretim Başladı
IS_STAGE = 3 Kısmi Üretim
IS_STAGE = 4 Üretim Tamamlandı
--->
<style>
	.box_yazi {font-size:16px;border-color:#666666;font:bold} 
	.box_yazi_td {font-size:14px;border-color:#666666;} 
	.box_yazi_small {font-size:11px;border-color:#666666;} 
	.a_box_yazi {font-size:16px;border-color:#BDCAC5;font:bold} 
	.a_box_yazi_td {font-size:14px;border-color:#BDCAC5;} 
</style>
<cfparam name="attributes.lot_number" default="">
<cfparam name="attributes.is_show" default="1">
<cfparam name="attributes.master_plan" default="">
<cfquery name="get_operation_basket" datasource="#dsn3#">
	SELECT DISTINCT
    	E.EZGI_VTS_OPERATION_BASKET_ID, 
        E.BASKET_NO, 
        E.EMPLOYEE_ID, 
        E.STATION_ID, 
        ISNULL(E.REAL_RATE,0) AS REAL_RATE, 
        E.IS_STAGE, 
        E.RECORD_DATE, 
        E.RECORD_EMP, 
        E.UPDATE_DATE,
        (SELECT TOP (1) STATION_NAME FROM WORKSTATIONS WHERE STATION_ID = E.STATION_ID) AS STATION_NAME,
        (SELECT TOP (1) OPERATION_TYPE_ID FROM PRODUCTION_OPERATION WHERE P_OPERATION_ID = ER.OPERATION_ID) AS OPERATION_TYPE_ID
	FROM     
    	EZGI_VTS_OPERATION_BASKET AS E INNER JOIN
      	EZGI_VTS_OPERATION_BASKET_ROW AS ER ON E.EZGI_VTS_OPERATION_BASKET_ID = ER.EZGI_VTS_OPERATION_BASKET_ID
	WHERE  
    	E.IS_STAGE < 4 AND
        E.STATION_ID = #attributes.station_id#
  	ORDER BY
    	E.IS_STAGE desc,
        E.RECORD_DATE
</cfquery>
<cfif get_operation_basket.recordcount>
	<cfset operation_type_id_list = ListDeleteDuplicates(ValueList(get_operation_basket.OPERATION_TYPE_ID),',')>
    <cfif Listlen(operation_type_id_list)>
        <cfquery name="get_operation_type_name" datasource="#dsn3#">
            SELECT OPERATION_TYPE_ID, OPERATION_TYPE FROM OPERATION_TYPES WHERE OPERATION_TYPE_ID IN (#operation_type_id_list#)
        </cfquery>
        <cfoutput query="get_operation_type_name">
            <cfset 'OPERATION_TYPE_#OPERATION_TYPE_ID#' = OPERATION_TYPE>
        </cfoutput> 
    </cfif>
</cfif>
<cfquery name="get_operation_basket_stage" dbtype="query">
	SELECT * FROM get_operation_basket WHERE IS_STAGE = 2
</cfquery>
<cfset get_workstation_name.EZGI_PACKAGE_CONTROL = 3>
<table border="1" cellspacing="0" cellpadding="2" width="99%" align="center" style="border-color:#666666;">
	<tr>
		<td style="text-align:right">
			<table border="1" cellspacing="0" cellpadding="2" width="100%" align="center" style="border-color:#666666;">
                <tr height="40" style="background-color:#CCCCCC;">
                	<td class="box_yazi" style="text-align:center" width="6%">Detay</td>
                    <td class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id ='57487.No'></td>
                    <td class="box_yazi" style="text-align:center" width="8%">Sepet No</td>
                    <td class="box_yazi" style="text-align:center" width="8%">Kayıt Tarihi</td>
                    <td class="box_yazi" style="text-align:center">Kaydeden</td>
                    <td class="box_yazi" style="text-align:center">İstasyon</td>
                    <td class="box_yazi" style="text-align:center"><cf_get_lang dictionary_id='29419.Operasyon'></td>
                    <td class="box_yazi" style="text-align:center" width="8%">Son Güncelleme</td>
                    <td class="box_yazi" style="text-align:center" width="8%">Gerçekleşen %</td>
                    <td class="box_yazi" style="text-align:center" width="8%">Kalan %</td>
                    <td class="box_yazi" style="text-align:center" width="10%">Durum</td>
                </tr>
                <cfoutput query="get_operation_basket">
                    <tr height="40" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                    	<td class="box_yazi_td" style="text-align:center">
                        	<a style="cursor:pointer" onclick="row_hide(#currentrow#);">
                            	<cfif get_operation_basket.IS_STAGE eq 0>
                        			<img src="/images/rotate_up.gif" id="rotate_button#currentrow#" style="height:37px">
                                <cfelse>
                                	<img src="/images/rotate_bottom.gif" id="rotate_button#currentrow#" style="height:37px">
                                </cfif>
                            </a>
                        </td>
                        <td class="box_yazi_td" style="text-align:center">#currentrow#</td>
                        <td class="box_yazi_td" style="text-align:center">#BASKET_NO#</td>
                        <td class="box_yazi_td" style="text-align:center">#DateFormat(RECORD_DATE,dateformat_style)#</td>
                        <td class="box_yazi_td" style="text-align:center">#get_emp_info(RECORD_EMP,0,0)#</td>
                        <td class="box_yazi_td" style="text-align:center">#STATION_NAME#</td>
                        <td class="box_yazi_td" style="text-align:center"><cfif isdefined('OPERATION_TYPE_#OPERATION_TYPE_ID#')>#Evaluate('OPERATION_TYPE_#OPERATION_TYPE_ID#')#</cfif></td>
                        <td class="box_yazi_td" style="text-align:center">#DateFormat(UPDATE_DATE,dateformat_style)#</td>
                        <td class="box_yazi_td" style="text-align:center">#REAL_RATE#</td>
                        <td class="box_yazi_td" style="text-align:center">#floor(100-REAL_RATE)#</td>
                        <td class="box_yazi_td" style="text-align:center;background-color:<cfif get_operation_basket.IS_STAGE eq 0>white<cfelseif get_operation_basket.IS_STAGE eq 1><cfif not get_operation_basket_stage.recordcount>orange<cfelse>silver</cfif><cfelseif get_operation_basket.IS_STAGE eq 2>green<cfelseif get_operation_basket.IS_STAGE eq 3><cfif not get_operation_basket_stage.recordcount>orange<cfelse>silver</cfif><cfelseif get_operation_basket.IS_STAGE eq 4>red</cfif>">
                            <cfif get_operation_basket.IS_STAGE eq 0>
                            	<cfif REAL_RATE eq 100> <!---Operasyonlar Kapandığı Halde Sepet Kapatılmamışsa--->
                                    <button  value="" name="sepet_kapat#EZGI_VTS_OPERATION_BASKET_ID#" id="sepet_kapat#EZGI_VTS_OPERATION_BASKET_ID#" onClick="operasyon(4,#EZGI_VTS_OPERATION_BASKET_ID#);" style="width:98%; height:39px; background-color:red; color:white">Sepeti Kapat</button>
                              	<cfelse>
                            	 	<button  value="" name="onayla#EZGI_VTS_OPERATION_BASKET_ID#" id="onayla#EZGI_VTS_OPERATION_BASKET_ID#" onClick="operasyon(1,#EZGI_VTS_OPERATION_BASKET_ID#);" style="width:98%; height:39px; background-color:blue; color:white">Onayla</button>
                              	</cfif>
                            <cfelseif get_operation_basket.IS_STAGE eq 1>
                            	<a id="isebaslat#EZGI_VTS_OPERATION_BASKET_ID#" style="cursor:pointer" <cfif not get_operation_basket_stage.recordcount> onclick="operasyon(2,#EZGI_VTS_OPERATION_BASKET_ID#);"</cfif>>
                                	<span <cfif not get_operation_basket_stage.recordcount>style="background-color:orange;color:white"<cfelse>style="background-color:silver;color:black"</cfif>><cf_get_lang dictionary_id='55703.İşe Başlat'></span>
                                </a>
                            <cfelseif get_operation_basket.IS_STAGE eq 2>
                            	<a id="sonucgir#EZGI_VTS_OPERATION_BASKET_ID#" style="cursor:pointer" onclick="sonuc_gir(#currentrow#,#EZGI_VTS_OPERATION_BASKET_ID#);">
                                <span style="background-color:green;color:white"><cf_get_lang dictionary_id='47883.Sonuç Gir'></span>
                           	<cfelseif get_operation_basket.IS_STAGE eq 3>
                            	<a id="isebaslat#EZGI_VTS_OPERATION_BASKET_ID#" style="cursor:pointer" <cfif not get_operation_basket_stage.recordcount> onclick="operasyon(2,#EZGI_VTS_OPERATION_BASKET_ID#);"</cfif>>
                                	<span <cfif not get_operation_basket_stage.recordcount>style="background-color:orange;color:white"<cfelse>style="background-color:silver;color:black"</cfif>><cf_get_lang dictionary_id='29747.Kısmi Üretim'></span>
                                </a>
                            <cfelseif get_operation_basket.IS_STAGE eq 4>
                                <span style="background-color:red;color:white"><cf_get_lang dictionary_id='305.Bitti'></span>
                            </cfif>
                        </td>
                    </tr>
                    <cfif get_operation_basket.IS_STAGE eq 0>
                    	<input type="hidden" name="kontrol_tr_#currentrow#" id="kontrol_tr_#currentrow#" value="1">
                   	<cfelse>
                    	<input type="hidden" name="kontrol_tr_#currentrow#" id="kontrol_tr_#currentrow#" value="0">
                    </cfif> 
                    <cfif get_operation_basket.IS_STAGE eq 2>
                    	<tr id="sonuc_#currentrow#" style="display:none">
                        	<td style="width:100%" colspan="11">
                        		<table border="1" cellspacing="0" cellpadding="2" width="100%">
                                	<tr>
                                    	<td style="height:255px; width:255px">
                                        	<button type="button" name="cikis#EZGI_VTS_OPERATION_BASKET_ID#" id="cikis#EZGI_VTS_OPERATION_BASKET_ID#" style="background-color:red; color:white;font-size:22px; font-weight:bold;height:100%; width:100%; border:none" title="" onClick="operasyon(-1,#EZGI_VTS_OPERATION_BASKET_ID#);"><cf_get_lang dictionary_id ='55755.Çalışıyor'></button>
                                        </td>
                                    	<td style="text-align:center">
                                        	<table cellspacing="0" cellpadding="1" border="0" align="center" height="98%" width="98%">
                                              	<tr>                  
                                                	<td style="text-align:center"> 
                                                     	<table cellspacing="1" cellpadding="2" border="0" align="center" height="100%" width="100%">
                                                        	<tr >
                                                              	<td style="text-align:center" >
                                                                	<span style="font-size:95px; font-family:'Palatino Linotype', 'Book Antiqua', Palatino, serif; text-align:center; font-weight:bold;">%</span>
                                                                	<input type="hidden" name="remaining"  id="remaining" value="#floor(100-REAL_RATE)#"/>
                                                                  	<input type="text" id="keyword" name="keyword" value="<cfoutput><cfif isdefined("keyword") and len(keyword)>#keyword#</cfif></cfoutput>" style="font-size:95px; font-family:'Palatino Linotype', 'Book Antiqua', Palatino, serif; text-align:right; font-weight:bold; width:150px; height:100px" class="box">
                                                            	</td>
                                                             	<td style="display:none;"><cf_workcube_process_cat slct_width="140"><cf_workcube_process is_upd='0' process_cat_width='130' is_detail='0'></td>
                                                       		</tr>
                                                   		</table>
                                                   	</td>
                                           		</tr>
                                       		</table>
                                        </td>
                                        <td style="width:100px">
                                        	<table cellspacing="0" cellpadding="1" border="0" align="center" height="98%" width="98%">
                                            	<tr  height="255px">                  
                                                 	<td> 
                                                      	<table cellspacing="1" cellpadding="2" border="0" align="center" height="100%" width="100%">
                                                         	<tr height="25%">
                                                               	<td style=" width:25%; text-align:center" >
                                                                  	<button type="button" name="k7" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(7)">7</button>
                                                              	</td> 
                                                            	<td style=" width:25%; text-align:center" >
                                                                 	<button type="button" name="k8" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(8)">8</button>
                                                              	</td>
                                                             	<td style=" width:25%; text-align:center" >
                                                                  	<button type="button" name="k9" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(9)">9</button>
                                                               	</td>
                                                               	<td rowspan="3" style=" width:25%; text-align:center; vertical-align:middle">
                                                                 	<button type="button" name="giris" id="giris" style="background-color:LightGray;font-size:22px; font-weight:bold;height:210px; width:60px" title="" onclick="operation_add(#EZGI_VTS_OPERATION_BASKET_ID#)">
                                                                        <div id="ay" style="font-size:22px; font-weight:bold;writing-mode:tb-rl;filter:fliph flipv; text-align:center; vertical-align:middle">
                                                                            <cf_get_lang dictionary_id='47883.Sonuç Gir'>
                                                                        </div>         
                                                                	</button>
                                                             	</td>
                                                           	</tr>
                                                         	<tr style="height:25%">
                                                             	<td style="text-align:center">
                                                                 	<button type="button" name="k4" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(4)">4</button>
                                                             	</td> 
                                                           		<td style="text-align:center">
                                                               		<button type="button" name="k5" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(5)">5</button>
                                                              	</td>
                                                             	<td style="text-align:center">
                                                              		<button type="button" name="k6" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(6)">6</button>
                                                             	</td>
                                                       		</tr>
                                                        	<tr style="height:25%">
                                                           		<td style="text-align:center">
                                                                	<button type="button" name="k1" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(1)">1</button>
                                                             	</td> 
                                                              	<td style="text-align:center">
                                                                	<button type="button" name="k2" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(2)">2</button>
                                                             	</td>
                                                            	<td style="text-align:center">
                                                                 	<button type="button" name="k3" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(3)">3</button>
                                                              	</td>
                                                           	</tr>
                                                         	<tr style="height:25%">
                                                          		<td colspan="2" style="text-align:center">
                                                                	<button type="button" name="k0" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:135px" title="" onclick="key_control(0)">0</button>
                                                            	</td> 
                                                            	<td style="text-align:center">
                                                                  	<button type="button" name="ks" style="background-color:red;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(-1)"><img src="images/list_minus.gif" border="0" style="text-align:center; vertical-align:middle"></button>
                                                              	</td>
                                                              	<td style="text-align:center">
                                                                 	<button type="button" name="kk" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control('.')">T</button>
                                                             	</td>
                                                        	</tr>
                                                     	</table>
                                                 	</td>
                                              	</tr>
                                         	</table>
                                        </td>
                                  	</tr>
                               	</table>
                           	</td>
                        </tr>
                    </cfif>
                    <tr id="tr_#currentrow#" <cfif get_operation_basket.IS_STAGE neq 0>style="display:none"</cfif>>
                    	<td style="width:100%" colspan="11">
                        	<table border="1" cellspacing="0" cellpadding="2" width="100%">
                                <tr height="30">
                                	<td class="box_yazi" style="text-align:center" width="4%">Detay</td>
                                    <td class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id ='57487.No'></td>
                                    <td class="box_yazi" style="text-align:center" width="8%"><cf_get_lang dictionary_id='57742.Tarih'></td>
                                    <td class="box_yazi" style="text-align:center" width="8%"><cf_get_lang dictionary_id='29474.Emir No'></td>
                                    <td class="box_yazi" style="text-align:center" ><cf_get_lang dictionary_id ='38089.Mamül Adı'></td>
                                    <td class="box_yazi" style="text-align:center" width="15%"><cf_get_lang dictionary_id='29419.Operasyon'></td>
                                    <td class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id='57635.Miktar'></td>
                                    <td class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id='29471.Fire'></td>
                                    <td class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id='302.Biten'></td>
                                    <td class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id='58444.Kalan'></td>
                                    <td class="box_yazi" style="text-align:center" width="3%"><cf_get_lang dictionary_id='1139.OP.'></td>
                                    <cfif get_operation_basket.IS_STAGE eq 0>
                                    	<td class="box_yazi" style="text-align:center" width="3%"></td>
                                    </cfif>
                                </tr>
                                <cfset attributes.lot_number = BASKET_NO>
                                <cfinclude template="../query/get_ezgi_operations.cfm">
                                <cfloop query="get_po_det">
                                	<input type="hidden" name="kontrol_tr_#get_operation_basket.currentrow#_#get_po_det.currentrow#" id="kontrol_tr_#get_operation_basket.currentrow#_#get_po_det.currentrow#" value="0">
                                	<tr>
                                    	<td class="box_yazi_td" style="text-align:center; height:40px">
                                        	<a style="cursor:pointer" onclick="row_sub_hide(#get_operation_basket.currentrow#,#get_po_det.currentrow#);">
                                            	<img src="/images/listele_down.gif" id="rotate_button_#get_operation_basket.currentrow#_#get_po_det.currentrow#" style="height:15px">
                                            </a>
                                        </td>
                                        <td class="box_yazi_td" style="text-align:center">#get_po_det.currentrow#</td>
                                        <td class="box_yazi_td" style="text-align:center">&nbsp;
                                            <cfif len(get_po_det.O_START_DATE)>
                                                #DateFormat(get_po_det.O_START_DATE,dateformat_style)#
                                            <cfelse>
                                                #DateFormat(get_po_det.START_DATE,dateformat_style)#
                                            </cfif>
                                        </td>
                                        <td class="box_yazi_td" style="text-align:center">#get_po_det.P_ORDER_NO#</td>
                                        <td class="box_yazi_td" style="text-align:left">
                            				&nbsp;<cfif len(get_po_det.PRODUCT_NAME)>#get_po_det.PRODUCT_NAME#<cfelse>#get_po_det.NAME_PRODUCT#</cfif>
                            			</td>
										<td class="box_yazi_td" style="text-align:left">&nbsp;#get_po_det.OPERATION_TYPE#</td>
                            			<td class="box_yazi_td" style="text-align:center">#get_po_det.AMOUNT#</td>
										<td class="box_yazi_td" style="text-align:center">#get_po_det.LOSS_AMOUNT#</td>
                            			<td class="box_yazi_td" style="text-align:center">#get_po_det.REAL_AMOUNT#</td>
										<td class="box_yazi_td" style="text-align:center">#get_po_det.AMOUNT-get_po_det.REAL_AMOUNT#</td>
                                        <td class="box_yazi_td" style="text-align:center">
											<cfif not len(get_po_det.STAGE)>
                                                <img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>!">
                                            <cfelseif get_po_det.STAGE eq 0>
                                                <img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='36891.Operatöre Gönderildi'>!">
                                            <cfelseif get_po_det.STAGE eq 1>
                                                <img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='398.Başladı'>!">
                                            <cfelseif get_po_det.STAGE eq 3>
                                                <img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='305.Bitti'>!">
                                            <cfelseif get_po_det.STAGE eq 4>
                                                <img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>!">	
                                            </cfif>
                                        </td>
                                        <cfif get_operation_basket.IS_STAGE eq 0>
                                            <td class="box_yazi_td" style="text-align:center">
                                                <cfif not (get_po_det.STAGE eq 1 or get_po_det.STAGE eq 3)>
                                                    <input type="checkbox" style="font-size:24px" name="select_production" value="#get_operation_basket.EZGI_VTS_OPERATION_BASKET_ID#_#get_po_det.P_OPERATION_ID#">
                                                <cfelse>
                                                    <img src="images/aktif.png" style="width:25px"> 
                                                </cfif>
                                            </td>
                                        </cfif>
                                   	</tr>
                                    <tr id="tr_#get_operation_basket.currentrow#_#get_po_det.currentrow#" style="display:none">
                                    	<td colspan="12" style="height:60px; text-align:center">
                                        	<table cellpadding="0" cellspacing="0" height="100%">
                                            	<tr>
                                                	<td style="width:200px; text-align:center; vertical-align:middle; height:100%">
                                                		<a href="javascript://" onclick="control(1,#P_OPERATION_ID#,#P_ORDER_ID#);">
                                               			 	<button type="button" name="fire" style="background-color:LightGray;font-size:16px; font-weight:bold;height:80%; width:198px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='308.Reçete'></button>
                                            			</a>
                                                  	</td>
                                                    <td style="width:200px; text-align:center; vertical-align:middle; height:100%">
                                                		<a href="javascript://" onclick="control(2,#P_OPERATION_ID#,#P_ORDER_ID#)">
                                                			<button type="button" name="tresim" style="background-color:LightGray;font-size:16px; font-weight:bold;height:80%; width:198px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='32796.Görünüm'></button>
                                            			</a>
                                                  	</td>
                                                    <td style="width:200px; text-align:center; vertical-align:middle; height:100%">
                                                		<a href="javascript://" onclick="control(3,#P_OPERATION_ID#,#P_ORDER_ID#);">
                                                			<button type="button" name="etiket" style="background-color:LightGray;font-size:16px; font-weight:bold;height:80%; width:198px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='51247.Etiket Bas'></button>
                                            			</a>
                                                  	</td>
                                                    <td style="width:200px; text-align:center; vertical-align:middle; height:100%">
                                                		<a href="javascript://" onclick="control(4,#P_OPERATION_ID#,#P_ORDER_ID#);">
                                                			<button type="button" name="utakip" style="background-color:LightGray;font-size:16px; font-weight:bold;height:80%; width:198px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='38033.Üretim Takibi'></button>
                                            			</a>
                                                  	</td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </cfloop>
                                <tr>
                                    <td style="font-size:14px; font-weight:bold; text-align:right" colspan="12">
                                    	<cfif not get_po_det.recordcount>
                                       		<button  value="" name="sil" id="sil" onClick="basket_sil(#EZGI_VTS_OPERATION_BASKET_ID#);" style="width:100px; height:50px; background-color:red; color:white">Sil</button> 
                                    	<cfelseif get_operation_basket.IS_STAGE eq 0 or get_operation_basket.IS_STAGE eq 1>
                                    		<cfif get_operation_basket.IS_STAGE eq 0>
                                            	<button  value="" name="hepsi" onClick="grupla(-1);" style="width:100px; height:50px; background-color:orange"><cf_get_lang dictionary_id='206.Hepsini Seç'></button>
                                   				<button  value="" name="sil" id="sil" onClick="grupla();" style="width:100px; height:50px; background-color:red; color:white">Sil</button>
                                           	<cfelseif get_operation_basket.IS_STAGE eq 1>
                                           		<button  value="" name="kaldir#EZGI_VTS_OPERATION_BASKET_ID#" id="kaldir#EZGI_VTS_OPERATION_BASKET_ID#" onClick="operasyon(0,#EZGI_VTS_OPERATION_BASKET_ID#);" style="width:100px; height:50px; background-color:blue; color:white">Onay Kaldır</button> 
                                            </cfif>
                                        </cfif>
                                    </td>
                                </tr>
                           	</table>
                        </td>
                    </tr>
                </cfoutput>
                 <tr>
                	<td style="font-size:14px; height:40px; font-weight:bold; text-align:right" colspan="11">
                      	<button  value="" name="geri" onClick="geri();" style="width:10%; height:39px; background-color:green;color:white"><cf_get_lang dictionary_id='1065.Tüm Operasyonlar'></button>
                	</td>
               	</tr>
            </table>
       	</td>
 	</tr>
</table>
<script language="javascript">
	function row_hide(c_row)
	{
		if(document.getElementById('kontrol_tr_'+c_row).value == 0)
		{
			document.getElementById('tr_'+c_row).style.display = '';
			document.getElementById('kontrol_tr_'+c_row).value = 1;
			document.getElementById("rotate_button"+c_row).src = "images/rotate_up.gif";
		}
		else
		{
			document.getElementById('tr_'+c_row).style.display = 'none';
			document.getElementById('kontrol_tr_'+c_row).value = 0;
			document.getElementById("rotate_button"+c_row).src = "images/rotate_bottom.gif";
		}
	}
	function row_sub_hide(up_row,sub_row)
	{
		if(document.getElementById('kontrol_tr_'+up_row+'_'+sub_row).value == 0)
		{
			document.getElementById('tr_'+up_row+'_'+sub_row).style.display = '';
			document.getElementById('kontrol_tr_'+up_row+'_'+sub_row).value = 1;
			document.getElementById("rotate_button_"+up_row+'_'+sub_row).src = "images/listele_up.gif";
		}
		else
		{
			document.getElementById('tr_'+up_row+'_'+sub_row).style.display = 'none';
			document.getElementById('kontrol_tr_'+up_row+'_'+sub_row).value = 0;
			document.getElementById("rotate_button_"+up_row+'_'+sub_row).src = "images/listele_down.gif";
		}
	}
	function basket_sil(basket_id)
	{

		sor = confirm("Sepet Silme İşlemi Yapılıyor!!!");
		if(sor==true)
		{
			document.getElementById('sil').disabled = true;
			window.location.href='<cfoutput>#request.self#?fuseaction=production.emptypopup_del_ezgi_operation_basket&station_id=#station_id#&employee_id=#employee_id#&</cfoutput>basket_id='+basket_id;
		}
	}
	function grupla(type)
	{
			operation_id_list = '';
			chck_leng = document.getElementsByName('select_production').length;
			for(ci=0;ci<chck_leng;ci++)
			{
				var my_objets = document.all.select_production[ci];
				if(chck_leng == 1)
					var my_objets =document.all.select_production;
				if(type == -1)
				{//hepsini seç denilmişse	
					if(my_objets.checked == true)
						my_objets.checked = false;
					else
						my_objets.checked = true;
				}
				else
				{
					if(my_objets.checked == true)

						operation_id_list +=my_objets.value+',';
				}
			}
			operation_id_list = operation_id_list.substr(0,operation_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(operation_id_list!='')
			{
				sor = confirm("Seçtiğiniz Operasyonlar Sepetten Çıkartılıyor!!!");
				if(sor==true)
				{
					document.getElementById('sil').disabled = true;
					window.location.href='<cfoutput>#request.self#?fuseaction=production.emptypopup_del_ezgi_operation_basket&station_id=#station_id#&employee_id=#employee_id#</cfoutput>&operation_id_list='+operation_id_list;
				}
			}
	}
	function geri()
	{
		window.location ="<cfoutput>#request.self#?fuseaction=production.list_ezgi_production_operation&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#</cfoutput>";
	}
	function onayla(basket_id)
	{
		sor = confirm("Sepet Onaylanacaktır. Sepet Üzerinde Düzenleme Yapılamaz.");
		if(sor==true)
			window.location.href='<cfoutput>#request.self#?fuseaction=production.emptypopup_upd_ezgi_operation_basket&station_id=#station_id#&employee_id=#employee_id#</cfoutput>&basket_id='+basket_id;
	}
	function kaldir(basket_id)
	{
		sor = confirm("Sepetin Onayı Kaldırılacaktır.");
		if(sor==true)
			window.location.href='<cfoutput>#request.self#?fuseaction=production.emptypopup_upd_ezgi_operation_basket&kaldir=1&station_id=#station_id#&employee_id=#employee_id#</cfoutput>&basket_id='+basket_id;
	}
	function operasyon(secim,basket_id)
	{
		if(secim==-1)
			sor =  confirm("<cf_get_lang dictionary_id='417.Üretim İçin Sonuç Girmeden Çıkmak İstediğinizden Emin misiniz'>?");
		if(secim==0)
			sor = confirm("Sepetin Onayı Kaldırılacaktır.");
		if(secim==1)
			sor = confirm("Sepet Onaylanacaktır. Sepet Üzerinde Düzenleme Yapılamaz.");
		if(secim==2)
			sor = confirm("Üretimler Başlatılacaktır.");
		if(secim==3)
			sor = confirm("Üretimler İçin Sonuç Girilecektir.");
		if(secim==4)
			sor = confirm("Sepeti Kapatıyorum!!!.");
		if(sor==true)
		{
			if(secim==-1)
				document.getElementById('cikis'+basket_id).disabled = true;
			if(secim==0)
				document.getElementById('kaldir'+basket_id).disabled = true;
			if(secim==1)
				document.getElementById('onayla'+basket_id).disabled = true;
			if(secim==4)
				document.getElementById('sepet_kapat'+basket_id).disabled = true;
			if(secim==2)	
				document.getElementById('isebaslat'+basket_id).disabled = true;
				
			window.location ="<cfoutput>#request.self#?fuseaction=production.emptypopup_upd_ezgi_operation_basket&islem="+secim+"&basket_id="+basket_id+"&station_id_=#attributes.station_id#&employee_id_=#attributes.employee_id#</cfoutput>";	
		}
	}
	function sonuc_gir(c_row,basket_id)
	{
		document.getElementById('sonuc_'+c_row).style.display = '';
	}
	function key_control(hkey)
	{
		if (hkey==-1)
		{
				var iLen = String(document.getElementById('keyword').value).length;
				if (iLen>1)
				{
					ezgi = String(document.getElementById('keyword').value).substring(0, iLen - 1);
				}
				else
				{
					ezgi = '';
				}
				document.getElementById('keyword').value = ezgi;
		}
		else
		{
				var kLen = String(document.getElementById('keyword').value).length;
				if(hkey=='.') 
				{
					ezgi= (document.getElementById('remaining').value);
					document.getElementById('keyword').value = ezgi;
				}
				else
				{
					ezgi = (document.getElementById('keyword').value + hkey);
					if(ezgi*1 >document.getElementById('remaining').value*1)
					{
						alert("<cf_get_lang dictionary_id='323.Girdiğiniz Miktar, Kalan Üretim Miktarından Fazla'>.!");
						return false;
					}
					else
						document.getElementById('keyword').value = ezgi;
				}
		}
	}
	function operation_add(basket_id)
	{
		<cfoutput>
			var station_id = #attributes.station_id#;
			var employee_id = #attributes.employee_id#;
		</cfoutput>
		if (document.getElementById('keyword').value == '0' || document.getElementById('keyword').value == '')
		{
			alert("<cf_get_lang dictionary_id='29943.Lütfen miktar giriniz.'>!");
			return false;	
		}
		else if(document.getElementById('keyword').value*1>document.getElementById('remaining').value*1)
		{
			alert("<cf_get_lang dictionary_id='323.Girdiğiniz Miktar, Kalan Üretim Miktarından Fazla'>.!");
			return false;
		}
		else
		{	
			var process_stage= document.getElementById('process_stage').value;
			var process_cat = document.getElementById('process_cat').value;
			if(process_stage>0 && process_cat>0)
			{
				if(document.getElementById('keyword').value*1==document.getElementById('remaining').value*1)
					uretim_durumu = 1;
				else
					uretim_durumu = 0;	
				document.getElementById('giris').disabled = true;
				window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=production.emptypopup_trf_ezgi_result_basket&station_id_='+station_id+'&tamamlan_oran='+document.getElementById('keyword').value+'&employee_id_='+employee_id+'&process_stage='+process_stage+'&process_cat='+process_cat+'&basket_id='+basket_id+'&uretim_durumu='+uretim_durumu;
			}
			else
			{
				alert("<cf_get_lang dictionary_id='57976.Lütfen Süreçlerinizi Tanımlayınız ve/veya Tanımlanan Süreçler Üzerinde Yetkiniz Yok'>.!");
				return false;
			}
		}
	}
	function control(c_key,p_operation_id,p_order_id)
	{
		if (c_key== 1)
			windowopen('<cfoutput>#request.self#?fuseaction=production.popup_dsp_ezgi_material_list&employee_id=#attributes.employee_id#&station_id=#attributes.station_id#</cfoutput>&p_order_id='+p_order_id+'&p_operation_id='+p_operation_id,'wide');
		if (c_key== 2)
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_dsp_ezgi_prod_teknik_resim&p_order_id='+p_order_id+'&p_operation_id='+p_operation_id,'wwide');
		if (c_key== 3)
			windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_print_files&print_type=280</cfoutput>&action_id='+p_order_id,'wide');
		if (c_key== 4)	
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_dsp_ezgi_operasyon_list&p_order_id='+p_order_id,'wwide');
	}
</script>