<!---
    File: dsp_ezgi_operation_sablon.cfm
    Folder: Add_Ons\ezgi\e-vts\display
    Author: Ezgi Yazılım
    Date: 04/01/2025
    Description: Şablona bağlı operasyon listesi
--->
<!---
IS_STAGE = 2 Üretim Başladı
IS_STAGE = 3 Kısmi Üretim
IS_STAGE = 4 Üretim Tamamlandı
--->
<cfparam name="attributes.sheet_group_number" default="">
<cfparam name="attributes.station_id" default="">
<cfparam name="attributes.employee_id" default="">

<!--- İstasyon Bilgileri Alınıyor --->
<cfquery name="get_workstation_name" datasource="#dsn3#">
	SELECT STATION_NAME,STATION_ID,EZGI_PACKAGE_CONTROL,ISNULL(EZGI_ORDER_CONTROL,0) AS EZGI_ORDER_CONTROL FROM WORKSTATIONS WHERE STATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.station_id#">
</cfquery>

<cfset get_workstation_name.EZGI_PACKAGE_CONTROL = 6>

<!--- Şablon Bilgilerini Al --->
<cfquery name="get_sablon_info" datasource="#dsn3#">
	SELECT 
		EOR.SHEET_GROUP_NUMBER,
		ISNULL(AVG(EOR.FIRE_PERCENT), 0) AS FIRE_PERCENT,
		COUNT(*) AS SHEET_AMOUNT,
		ISNULL(S.PRODUCT_NAME, 'Bilinmeyen Malzeme') AS PRODUCT_NAME,
		EOR.STOCK_ID
	FROM 
		EZGI_IFLOW_OPTIMIZATION_RESULTS AS EOR WITH (NOLOCK)
		LEFT OUTER JOIN STOCKS AS S WITH (NOLOCK) ON EOR.STOCK_ID = S.STOCK_ID 
	WHERE 
		EOR.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
	GROUP BY 
		EOR.SHEET_GROUP_NUMBER,
		S.PRODUCT_NAME,
		EOR.STOCK_ID
</cfquery>
<cfquery name="get_basket_info" datasource="#dsn3#">
	SELECT TOP (1) 
		E.EMPLOYEE_ID, 
		E.STATION_ID, 
		ISNULL(E.REAL_RATE,0) AS REAL_RATE, 
		E.IS_STAGE
	FROM     
		EZGI_VTS_OPERATION_BASKET AS E WITH (NOLOCK) INNER JOIN
        EZGI_VTS_OPERATION_BASKET_ROW AS ER WITH (NOLOCK) ON E.EZGI_VTS_OPERATION_BASKET_ID = ER.EZGI_VTS_OPERATION_BASKET_ID
	WHERE  
		ER.OPTIMIZITION_SABLON = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
</cfquery>
<!--- Şablona bağlı operasyonları getir --->
<cfinclude template="../query/get_ezgi_operations_sablon.cfm">

<style>
	.box_yazi {font-size:16px;border-color:#666666;font:bold} 
	.box_yazi_td {font-size:14px;border-color:#666666;} 
	.box_yazi_small {font-size:11px;border-color:#666666;} 
	.a_box_yazi {font-size:16px;border-color:#BDCAC5;font:bold} 
	.a_box_yazi_td {font-size:14px;border-color:#BDCAC5;} 
</style>

<cfif get_sablon_info.recordcount>
	<table border="1" cellspacing="0" cellpadding="2" width="99%" align="center" style="border-color:#666666;">
		<tr>
			<td style="text-align:right">
				<table border="1" cellspacing="0" cellpadding="2" width="100%" align="center" style="border-color:#666666;">
					<tr height="30">
						<td class="box_yazi" style="text-align:center" width="10%"><strong>Şablon Numarası</strong></td>
						<td class="box_yazi" style="text-align:center" width="10%"><strong>Fire Oranı</strong></td>
						<td class="box_yazi" style="text-align:center" width="10%"><strong>Sheet Miktarı</strong></td>
						<td class="box_yazi" style="text-align:center"><strong>Malzeme Adı</strong></td>
						<td class="box_yazi" style="text-align:center" width="5%"><strong>Biten (%)</strong></td>
						<td class="box_yazi" style="text-align:center" width="5%"><strong>Kalan (%)</strong></td>
						<td class="box_yazi" style="text-align:center" width="15%" rowspan="2">
							<cfif not get_basket_info.recordcount>
								<button value="" name="uretime_basla" onClick="uretimeBasla(1);" style="width:100%; height:60px; background-color:orange;color:white"><cf_get_lang dictionary_id='55703.İşe Başlat'></button>
							<cfelseif get_basket_info.recordcount and get_basket_info.IS_STAGE eq 2>
								<button value="" name="uretime_basla" onClick="uretimeBasla(2);" style="width:100%; height:60px; background-color:green;color:white"><cf_get_lang dictionary_id='47883.Sonuç Gir'></button>
							<cfelseif get_basket_info.recordcount and get_basket_info.IS_STAGE eq 3>
								<button value="" name="uretime_basla" onClick="uretimeBasla(3);" style="width:100%; height:60px; background-color:orange;color:white"><cf_get_lang dictionary_id='29747.Kısmi Üretim'></button>
							<cfelseif get_basket_info.recordcount and get_basket_info.IS_STAGE eq 4>
								<button value="" name="uretime_basla" style="width:100%; height:60px; background-color:red;color:white"><cf_get_lang dictionary_id='305.Bitti'></button>
							</cfif>
						</td>
					</tr>
					<tr height="30">
						<td class="box_yazi_td" style="text-align:center">
							<cfoutput>#get_sablon_info.SHEET_GROUP_NUMBER#</cfoutput>
						</td>
						<td class="box_yazi_td" style="text-align:center">
							<cfoutput>#NumberFormat(get_sablon_info.FIRE_PERCENT, "9.99")#%</cfoutput>
						</td>
						<td class="box_yazi_td" style="text-align:center">
							<cfoutput>#get_sablon_info.SHEET_AMOUNT#</cfoutput>
						</td>
						<td class="box_yazi_td" style="text-align:center">
							<cfoutput>#get_sablon_info.PRODUCT_NAME#</cfoutput>
						</td>
						<td class="box_yazi_td" style="text-align:center">
							<cfoutput>
								<cfif get_basket_info.REAL_RATE gt 0>
									#AmountFormat(get_basket_info.REAL_RATE,2)#%
								<cfelse>
									#AmountFormat(0,2)#%
								</cfif>
							</cfoutput>
						</td>
						<td class="box_yazi_td" style="text-align:center">
							<cfoutput>
								<cfif get_basket_info.REAL_RATE gt 0>
									#AmountFormat(100-get_basket_info.REAL_RATE,2)#%
								<cfelse>
									#AmountFormat(100,2)#%
								</cfif>
							</cfoutput>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>

	<table cellspacing="0" cellpadding="2" width="99%" align="center" style="border-color:#666666;">
		<tr id="sonuc_gir" style="display:none">
			<td style="width:100%" colspan="11">
				<table border="1" cellspacing="0" cellpadding="2" width="100%">
					<tr>
						<td style="height:255px; width:255px">
							<button type="button" name="cikis" id="cikis" style="background-color:red; color:white;font-size:22px; font-weight:bold;height:100%; width:100%; border:none" title="" onClick="operasyon();"><cf_get_lang dictionary_id ='55755.Çalışıyor'></button>
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
	</table>
</cfif>
<table border="1" cellspacing="0" cellpadding="2" width="99%" align="center" style="border-color:#666666;">
	<tr>
		<td style="text-align:right">
			<table border="1" cellspacing="0" cellpadding="2" width="100%" align="center" style="border-color:#666666;">
				<tr height="30">
					<td class="box_yazi" style="text-align:center" width="4%">Detay</td>
					<td class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id ='57487.No'></td>
					<td class="box_yazi" style="text-align:center" width="8%"><cf_get_lang dictionary_id='57742.Tarih'></td>
					<td class="box_yazi" style="text-align:center" width="8%"><cf_get_lang dictionary_id='29474.Emir No'></td>
					<td class="box_yazi" style="text-align:center" ><cf_get_lang dictionary_id ='38089.Mamül Adı'></td>
					<td class="box_yazi" style="text-align:center" width="15%"><cf_get_lang dictionary_id='29419.Operasyon'></td>
					<td class="box_yazi" style="text-align:center" width="4%">Emir Miktarı</td>
					<td class="box_yazi" style="text-align:center" width="4%">Şablon Miktarı</td>
					<td class="box_yazi" style="text-align:center" width="4%">Parça Boyu</td>
					<td class="box_yazi" style="text-align:center" width="4%">Parça Eni</td>
					<td class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id='29471.Fire'></td>
					<td class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id='302.Biten'></td>
					<td class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id='58444.Kalan'></td>
					<td class="box_yazi" style="text-align:center" width="3%"><cf_get_lang dictionary_id='1139.OP.'></td>
				</tr>
				<cfif get_po_det.recordcount>
					<cfoutput query="get_po_det">
						<input type="hidden" name="kontrol_tr_#get_po_det.currentrow#" id="kontrol_tr_#get_po_det.currentrow#" value="0">
						<tr height="40" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
							<td class="box_yazi_td" style="text-align:center; height:40px">
								<a style="cursor:pointer" onclick="row_sub_hide(#get_po_det.currentrow#);">
									<img src="/images/listele_down.gif" id="rotate_button_#get_po_det.currentrow#" style="height:15px">
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
							<td class="box_yazi_td" style="text-align:center">#get_po_det.P_ORDER_NO#<br>#get_po_det.LOT_NO#</td>
							<td class="box_yazi_td" style="text-align:left">
								&nbsp;<cfif len(get_po_det.PRODUCT_NAME)>#get_po_det.PRODUCT_NAME#<cfelse>#get_po_det.NAME_PRODUCT#</cfif>
							</td>
							<td class="box_yazi_td" style="text-align:left">&nbsp;#get_po_det.OPERATION_TYPE#</td>
							<td class="box_yazi_td" style="text-align:center">#get_po_det.AMOUNT#</td>
							<td class="box_yazi_td" style="text-align:center">#get_po_det.SABLON_MIKTARI#</td>
							<td class="box_yazi_td" style="text-align:center">#NumberFormat(get_po_det.PARCA_BOYU, "9.99")#</td>
							<td class="box_yazi_td" style="text-align:center">#NumberFormat(get_po_det.PARCA_ENI, "9.99")#</td>
							<td class="box_yazi_td" style="text-align:center">#get_po_det.LOSS_AMOUNT#</td>
							<td class="box_yazi_td" style="text-align:center">#get_po_det.REAL_AMOUNT#</td>
							<td class="box_yazi_td" style="text-align:center">#get_po_det.SABLON_MIKTARI-get_po_det.REAL_AMOUNT#</td>
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
						</tr>
						<tr id="tr_#get_po_det.currentrow#" style="display:none">
							<td colspan="14" style="height:60px; text-align:center">
								<table cellpadding="0" cellspacing="0" height="100%">
									<tr>
										<td style="width:200px; text-align:center; vertical-align:middle; height:100%">
											<a href="javascript://" onclick="control(1,#get_po_det.P_OPERATION_ID#,#get_po_det.P_ORDER_ID#);">
												<button type="button" name="fire" style="background-color:LightGray;font-size:16px; font-weight:bold;height:80%; width:198px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='308.Reçete'></button>
											</a>
										</td>
										<td style="width:200px; text-align:center; vertical-align:middle; height:100%">
											<a href="javascript://" onclick="control(2,#get_po_det.P_OPERATION_ID#,#get_po_det.P_ORDER_ID#)">
												<button type="button" name="tresim" style="background-color:LightGray;font-size:16px; font-weight:bold;height:80%; width:198px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='32796.Görünüm'></button>
											</a>
										</td>
										<td style="width:200px; text-align:center; vertical-align:middle; height:100%">
											<a href="javascript://" onclick="control(3,#get_po_det.P_OPERATION_ID#,#get_po_det.P_ORDER_ID#);">
												<button type="button" name="etiket" style="background-color:LightGray;font-size:16px; font-weight:bold;height:80%; width:198px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='51247.Etiket Bas'></button>
											</a>
										</td>
										<td style="width:200px; text-align:center; vertical-align:middle; height:100%">
											<a href="javascript://" onclick="control(4,#get_po_det.P_OPERATION_ID#,#get_po_det.P_ORDER_ID#);">
												<button type="button" name="utakip" style="background-color:LightGray;font-size:16px; font-weight:bold;height:80%; width:198px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='38033.Üretim Takibi'></button>
											</a>
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</cfoutput>
				<cfelse>
					<tr>
						<td colspan="14" style="text-align:center; padding:20px;">
							<p style="font-size:16px; color:#999;">Bu şablon için operasyon bulunamadı.</p>
						</td>
					</tr>
				</cfif>
				<tr>
					<td style="font-size:14px; height:40px; font-weight:bold; text-align:right" colspan="14">
						<a href="javascript://" onclick="geri();">
							<button type="button" name="geri" style="width:10%; height:39px; background-color:orange;color:white; margin-right:10px;">Geri</button>
						</a>
						<button value="" name="kesim_plani" onClick="kesimPlaniGoster();" style="width:10%; height:39px; background-color:blue;color:white; margin-right:10px;">Kesim Planı Göster</button>
						
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<script language="javascript">
	function row_sub_hide(sub_row)
	{
		if(document.getElementById('kontrol_tr_'+sub_row).value == 0)
		{
			document.getElementById('tr_'+sub_row).style.display = '';
			document.getElementById('kontrol_tr_'+sub_row).value = 1;
			document.getElementById("rotate_button_"+sub_row).src = "images/listele_up.gif";
		}
		else
		{
			document.getElementById('tr_'+sub_row).style.display = 'none';
			document.getElementById('kontrol_tr_'+sub_row).value = 0;
			document.getElementById("rotate_button_"+sub_row).src = "images/listele_down.gif";
		}
	}
	function kesimPlaniGoster()
	{
		windowopen('<cfoutput>#request.self#?fuseaction=production.dsp_ezgi_sheet_sablon&sheet_group_number=#attributes.sheet_group_number#</cfoutput>','wwide');
	}
	function uretimeBasla(type)
	{
		if(type==1)
		{
			sor=confirm('Şablon Üretimine Başlıyorum')
			if(sor===true)
				window.location.href='<cfoutput>#request.self#?fuseaction=production.emptypopup_add_ezgi_operation_sablon&SHEET_GROUP_NUMBER=#attributes.sheet_group_number#&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#</cfoutput>';
			else
				return false;
		}
		else if(type==2)
		{
			document.getElementById('sonuc_gir').style.display = '';
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
	function geri()
	{
		window.location.href='<cfoutput>#request.self#?fuseaction=production.list_ezgi_production_operation_sablon&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&sheet_group_number=#attributes.sheet_group_number#&is_submitted=1</cfoutput>';
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

</script>
