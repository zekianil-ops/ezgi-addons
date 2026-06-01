<!---
    File: upd_ezgi_perioad_based_count_operations.cfm
    Folder: Add_Ons\ezgi\e-wm\form
    Author: Ezgi Yazılım
    Date: 01/02/2025
    Description:
--->
<cf_xml_page_edit>
<cfquery name="get_shelf" datasource="#dsn#">
	SELECT SHELF_ID, SHELF_NAME FROM SHELF ORDER BY SHELF_ID
</cfquery>

<cfquery name="get_count" datasource="#dsn3#">
	SELECT 
  		PROCESS_DATE, 
     	PROCESS_NUMBER,
        RECORD_EMP,
    	RECORD_DATE,
        STATUS,
        IS_PALETTE_CONTENT_SAVE,
     	ISNULL((SELECT COUNT (*) AS PAKET_AMOUNT FROM EZGI_WM_COUNT_SERIAL_ROW),0) AS PAKET_AMOUNT,
    	ISNULL((SELECT COUNT (*) AS PALET_AMOUNT FROM EZGI_WM_COUNT_PACKING_ROW),0) AS PALET_AMOUNT
	FROM     
     	EZGI_WM_COUNT WITH (NOLOCK)
  	WHERE
    	EZGI_WM_COUNT_ID = #attributes.count_id#
</cfquery>
<cfquery name="get_count_serial_row" datasource="#dsn3#">
	SELECT 
    	E.SERIAL_NO, 
        E.STOCK_ID, 
        E.PRODUCT_PLACE_ID, 
        E.PACKING_ID, 
        E.SPECT_ID, 
        E.PALET_BARCODE, 
        E.PRODUCT_NAME, 
        E.IS_PROTOTYPE, 
        ISNULL(E.SHELF_CODE,0) SHELF_CODE, 
        ISNULL(E.IS_CONTROL,0) AS IS_CONTROL, 
        E.CONTROL_DATE, 
        E.CONTROL_EMP, 
        D.DEPO_NAME, 
        D.DEPO,
        P.SHELF_TYPE
	FROM     
    	EZGI_WM_COUNT_SERIAL_ROW AS E WITH (NOLOCK) INNER JOIN
        EZGI_WM_DEPARTMENTS AS D WITH (NOLOCK) ON E.DEPARTMENT_ID = D.DEPARTMENT_ID AND E.LOCATION_ID = D.LOCATION_ID LEFT OUTER JOIN
     	EZGI_PRODUCT_PLACE AS P WITH (NOLOCK) ON E.PRODUCT_PLACE_ID = P.PRODUCT_PLACE_ID
	WHERE  
    	E.WM_COUNT_ID = #attributes.count_id#
</cfquery>
<cfquery name="get_count_packing_row" datasource="#dsn3#">
	SELECT 
    	E.PACKING_ID, 
        E.BARCODE, 
        E.AMOUNT, 
        E.IS_KARMA, 
        ISNULL(E.IS_CONTROL,0) AS IS_CONTROL,  
        E.CONTROL_DATE, 
        E.CONTROL_EMP, 
        D.DEPO_NAME, 
        D.DEPO,
     	ISNULL(P.SHELF_CODE,0) SHELF_CODE, 
        P.PRODUCT_PLACE_ID,
        P.SHELF_TYPE
	FROM     
    	EZGI_WM_COUNT_PACKING_ROW AS E WITH (NOLOCK) INNER JOIN
        EZGI_WM_DEPARTMENTS AS D WITH (NOLOCK) ON E.STORE = D.DEPARTMENT_ID AND E.STORE_LOCATION = D.LOCATION_ID LEFT OUTER JOIN
      	EZGI_PRODUCT_PLACE AS P WITH (NOLOCK) ON E.SHELF_NUMBER = P.PRODUCT_PLACE_ID
	WHERE  
    	E.WM_COUNT_ID = #attributes.count_id#
</cfquery>
<cfif not (get_count_serial_row.recordcount or get_count_packing_row.recordcount)>
	<script type="text/javascript">
     	alert("Sayım Kaydı içinde Palet veya Paket Kaydı Bulunamadı!");
    	window.history.go(-1);
  	</script>
	<cfabort>
<cfelse>
    <cfquery name="list_department_total_serial" dbtype="query">
    	SELECT
        	COUNT (*) AS SAYI,
        	DEPO_NAME, 
        	DEPO
        FROM
        	get_count_serial_row
      	GROUP BY	
        	DEPO_NAME, 
        	DEPO
      	ORDER BY
        	DEPO_NAME
    </cfquery>
  	<!---Tüm Depolar--->
    <cfquery name="get_tum_paket_toplam" dbtype="query">
    	SELECT COUNT (*) AS SAYI FROM get_count_serial_row
 	</cfquery>
  	<cfquery name="get_tum_paket_sayilan" dbtype="query">
    	SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE IS_CONTROL = 1
 	</cfquery>
 	<cfquery name="get_tum_palet_toplam" dbtype="query">
    	SELECT COUNT (*) AS SAYI FROM get_count_packing_row
  	</cfquery>
  	<cfquery name="get_tum_palet_sayilan" dbtype="query">
     	SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE IS_CONTROL = 1
 	</cfquery>
    <!---Tüm Depolar--->
</cfif>
<cf_catalystHeader>
<div class="col col-12 col-xs-12">
	<cf_box>
    	<cfform name="form_basket" method="post" action="stock.emptypopup_upd_ezgi_perioad_based_count_operations">
            <cfinput name="count_id" id="count_id" type="hidden" value="#attributes.count_id#">
            <cf_basket_form id="upd_count">
                <div class="row">
                  	<div class="col col-12 uniqueRow">
                     	<div class="row formContent">
                         	<cf_box_elements>
                             	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                                  	<div class="form-group" id="item-status">
	                            		<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
	                            		<div class="col col-8 col-xs-12">
                                         	<input id="status" name="status" type="checkbox" value="1" <cfif get_count.STATUS eq 1>checked</cfif>>
                                     	</div>
                                  	</div>
                                    <div class="form-group" id="item-palet_content">
	                            		<label class="col col-4 col-xs-12">Palet İçeriğini Kaydeder</label>
	                            		<div class="col col-8 col-xs-12">
                                         	<input id="is_palette_content_save" name="is_palette_content_save" type="checkbox" value="1" <cfif get_count.IS_PALETTE_CONTENT_SAVE eq 1>checked</cfif>>
                                     	</div>
                                  	</div>
                              	</div>
                                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                                	<div class="form-group" id="item-process_date">
	                            		<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></label>
	                            		<div class="col col-8 col-xs-12">
                                         	<cfinput type="text" name="process_date" id="process_date" value="#DateFormat(get_count.PROCESS_DATE,dateformat_style)#" readonly="yes">
                                     	</div>
                                  	</div>
                                </div>
                                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                                	<div class="form-group" id="item-process_date">
	                            		<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57880.Belge No'></label>
	                            		<div class="col col-8 col-xs-12">
                                         	<cfinput type="text" name="process_number" id="process_number" value="#get_count.PROCESS_NUMBER#" readonly="yes">
                                     	</div>
                                  	</div>
                                </div>
                                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                                	<div class="form-group" id="item-emp">
	                            		<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57899.Kaydeden'></label>
	                            		<div class="col col-8 col-xs-12">
                                         	<cfinput type="text" name="record_emp" id="record_emp" value="#get_emp_info(get_count.record_emp,0,0)#" readonly="yes">
                                     	</div>
                                  	</div>
                                </div>
							</cf_box_elements>
                        	<cf_box_footer>
									<div class="col col-12 col-xs-12">
                                        <cf_workcube_buttons 
                                        	is_upd='1' 
                                            add_function='kontrol()'
                                            is_delete = '1'>
                                    </div>
                			</cf_box_footer>
                       	</div>
                 	</div>
              	</div>
        	</cf_basket_form>     
 			<div id="depo_div" class="col col-12">
                <cf_basket id="report_bask">
                    <cf_grid_list sort="0">
                        <thead>
                            <tr>
                                <th style="text-align:center; width:20px" rowspan="2"></th>
                                <th style="text-align:center; width:30px" rowspan="2"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                
                                <th style="text-align:center;" rowspan="2"><cf_get_lang dictionary_id='58763.Depo'> / <cf_get_lang dictionary_id='30031.Lokasyon'></th>
                                <th style="text-align:center; width:240px" colspan="2"><cf_get_lang dictionary_id='100.Paket'></th>
                                <th style="text-align:center; width:240px" colspan="2"><cf_get_lang dictionary_id='37244.Palet'></th>
                                
                                <th style="text-align:center; width:120px" rowspan="2"><cf_get_lang dictionary_id='58456.Oran'></th>
                            </tr>
                            <tr>
                                <th style="text-align:center; width:120px"><cf_get_lang dictionary_id='57492.Toplam'></th>
                                <th style="text-align:center; width:120px"><cf_get_lang dictionary_id='54680.Sayılan'></th>
                                
                                <th style="text-align:center; width:120px"><cf_get_lang dictionary_id='57492.Toplam'></th>
                                <th style="text-align:center; width:120px"><cf_get_lang dictionary_id='54680.Sayılan'></th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfif list_department_total_serial.recordcount>
                                <cfoutput query="list_department_total_serial">
                                	 <!---Ana Depolar--->
                                    <cfquery name="get_paket_sayilan" dbtype="query">
                                        SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE IS_CONTROL = 1 AND DEPO = '#DEPO#'
                                    </cfquery>
                                    <cfquery name="get_palet_toplam" dbtype="query">
                                        SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE DEPO = '#DEPO#'
                                    </cfquery>
                                    <cfquery name="get_palet_sayilan" dbtype="query">
                                        SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE IS_CONTROL = 1 AND DEPO = '#DEPO#'
                                    </cfquery>
                                    <!---Depoda Raf Arama--->
                                    <cfquery name="get_paket_shelf" dbtype="query">
                                     	SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE DEPO = '#DEPO#' AND SHELF_TYPE IN (1,2,3,4,5)
                                  	</cfquery>
                                    <!---Ana Depolar--->
                                    <input type="hidden" name="row_display_#currentrow#" id="row_display_#currentrow#" value="<cfif get_paket_shelf.recordcount>1<cfelse>0</cfif>">
                                    <tr style="font-weight:<cfif get_paket_shelf.recordcount>bold<cfelse>normal</cfif>">
                                        <!-- sil --> 
                                        <td align="center" id="count_depo_row#currentrow#" class="color-row" <cfif get_paket_shelf.recordcount>onclick="gizle_goster(sub_depo_count_detail#currentrow#);seviyelendir(#currentrow#);gizle_goster_nested('siparis_goster#currentrow#','siparis_gizle#currentrow#');"</cfif>>
                                            <cfif get_paket_shelf.recordcount>
                                                <img id="siparis_goster#currentrow#" style="cursor:pointer;" src="/images/listele.gif" title="<cf_get_lang dictionary_id ='58596.Göster'>">
                                                <img id="siparis_gizle#currentrow#" style="cursor:pointer;display:none;" src="/images/listele_down.gif" title="<cf_get_lang dictionary_id ='58628.Gizle'>">
                                            </cfif>
                                        </td>
                                        <!-- sil --> 
                                        <td style="text-align:right">#currentrow#</td>
                                        <td style="text-align:left">#DEPO_NAME#</td>
                                        
                                        <td style="text-align:right">
                                        	<cfif get_paket_shelf.recordcount>
                                            	#AmountFormat(SAYI)#
                                          	<cfelse>
                                            	<a style="cursor:pointer" onclick="connectAjax('#DEPO#',0,0,1,0);">
                                                	#AmountFormat(SAYI)#
                                                </a>
                                            </cfif>
                                       	</td>
                                        <td style="text-align:right">
                                        	<cfif get_paket_shelf.recordcount>
                                            	#AmountFormat(get_paket_sayilan.SAYI)#
                                          	<cfelse>
                                            	<a style="cursor:pointer" onclick="connectAjax('#DEPO#',0,0,1,1);">
                                                	#AmountFormat(get_paket_sayilan.SAYI)#
                                                </a>
                                            </cfif>
                                        </td>
                                        <td style="text-align:right">
                                        	<cfif get_paket_shelf.recordcount>
                                            	#AmountFormat(get_palet_toplam.SAYI)#
                                          	<cfelse>
                                            	<a style="cursor:pointer" onclick="connectAjax('#DEPO#',0,0,2,0);">
                                                	#AmountFormat(get_palet_toplam.SAYI)#
                                                </a>
                                            </cfif>
                                        </td>
                                        <td style="text-align:right">
                                        	<cfif get_paket_shelf.recordcount>
                                            	#AmountFormat(get_palet_sayilan.SAYI)#
                                          	<cfelse>
                                            	<a style="cursor:pointer" onclick="connectAjax('#DEPO#',0,0,2,1);">
                                                	#AmountFormat(get_palet_sayilan.SAYI)#
                                                </a>
                                            </cfif>
                                        </td>
                                        <td style="text-align:center"><cfif get_paket_sayilan.SAYI gt 0>#AmountFormat(get_paket_sayilan.SAYI/SAYI*100,2)#<cfelse>#AmountFormat(0,2)#</cfif></td>
                                    </tr>
                                    
                                    <tr id="sub_depo_count_detail#currentrow#" class="nohover" style="display:none" >
                                        <td colspan="8">
                                           <table style="width:100%" cellpadding="2" cellspacing="0" border="1">
                                           		<tr style="font-weight:bold; text-align:center; background-color:gainsboro; height:10px">
                                                	<td style="text-align:center;color:cadetblue; width:20px"></td>
                                                    <td style="text-align:center;color:cadetblue; width:30px"><cf_get_lang dictionary_id='58577.Sıra'></td>
                                                    
                                                    <td style="text-align:center;color:cadetblue;"><cf_get_lang dictionary_id='45925.Raf Tipi'></td>
                                                    <td style="text-align:center;color:cadetblue; width:120px"><cf_get_lang dictionary_id='57492.Toplam'></td>
                                                    <td style="text-align:center;color:cadetblue; width:120px"><cf_get_lang dictionary_id='54680.Sayılan'></td>
                                                    
                                                    <td style="text-align:center;color:cadetblue; width:120px"><cf_get_lang dictionary_id='57492.Toplam'></td>
                                                    <td style="text-align:center;color:cadetblue; width:120px"><cf_get_lang dictionary_id='54680.Sayılan'></td>
                                                    <td style="text-align:center;color:cadetblue; width:110px"><cf_get_lang dictionary_id='58456.Oran'></td>
                                                </tr>
                                                <cfif get_shelf.recordcount>
                                                	<cfloop query="get_shelf">
														<!---Raf Tipleri--->
                                                        <cfquery name="get_paket_shelf_type_toplam" dbtype="query">
                                                            SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID#
                                                        </cfquery>
                                                        <cfquery name="get_paket_shelf_type_sayilan" dbtype="query">
                                                            SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE IS_CONTROL = 1 AND DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID#
                                                        </cfquery>
                                                        <cfquery name="get_palet_shelf_type_toplam" dbtype="query">
                                                            SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID#
                                                        </cfquery>
                                                        <cfquery name="get_palet_shelf_type_sayilan" dbtype="query">
                                                            SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE IS_CONTROL = 1 AND DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID#
                                                        </cfquery>
                                                        <!---Raf Tipleri--->
                                                        <input type="hidden" name="row_display_#list_department_total_serial.currentrow#_#get_shelf.currentrow#" id="row_display_#list_department_total_serial.currentrow#_#get_shelf.currentrow#" value="<cfif ListFind('1,2,3',get_shelf.SHELF_ID)>1<cfelse>0</cfif>">
                                                    	<tr style="font-weight:<cfif ListFind('1,2,3',get_shelf.SHELF_ID)>bold<cfelse>normal</cfif>">
                                                        	<!-- sil --> 
                                        					<td align="center" id="count_depo_row#list_department_total_serial.currentrow#_#get_shelf.currentrow#" class="color-row" <cfif ListFind('1,2,3',get_shelf.SHELF_ID)>onclick="gizle_goster(sub_depo_count_detail#list_department_total_serial.currentrow#_#get_shelf.currentrow#);seviyelendir_1(#currentrow#,#get_shelf.currentrow#,#get_shelf.currentrow#);gizle_goster_nested('siparis_goster#list_department_total_serial.currentrow#_#get_shelf.currentrow#','siparis_gizle#list_department_total_serial.currentrow#_#get_shelf.currentrow#');"</cfif>>
																<cfif ListFind('1,2,3',get_shelf.SHELF_ID)>
                                                                    <img id="siparis_goster#list_department_total_serial.currentrow#_#get_shelf.currentrow#" style="cursor:pointer;" src="/images/listele.gif" title="<cf_get_lang dictionary_id ='58596.Göster'>">
                                                                    <img id="siparis_gizle#list_department_total_serial.currentrow#_#get_shelf.currentrow#" style="cursor:pointer;display:none;" src="/images/listele_down.gif" title="<cf_get_lang dictionary_id ='58628.Gizle'>">
                                                                </cfif>
                                        					</td>
                                        					<!-- sil --> 
                                                            <td style="text-align:right">#get_shelf.currentrow#</td>
                                                            <td>#SHELF_NAME#</td>
                                                            <td style="text-align:right">
																<cfif ListFind('1,2,3',get_shelf.SHELF_ID)>
                                                                    #AmountFormat(get_paket_shelf_type_toplam.SAYI)#
                                                                <cfelse>
                                                                    <a style="cursor:pointer" onclick="connectAjax('#list_department_total_serial.DEPO#',#get_shelf.SHELF_ID#,0,1,0);">
                                                                        #AmountFormat(get_paket_shelf_type_toplam.SAYI)#
                                                                    </a>
                                                                </cfif>
                                                          	</td>
                                                            <td style="text-align:right">
																<cfif ListFind('1,2,3',get_shelf.SHELF_ID)>
                                                                    #AmountFormat(get_paket_shelf_type_sayilan.SAYI)#
                                                                <cfelse>
                                                                    <a style="cursor:pointer" onclick="connectAjax('#list_department_total_serial.DEPO#',#get_shelf.SHELF_ID#,0,1,1);">
                                                                        #AmountFormat(get_paket_shelf_type_sayilan.SAYI)#
                                                                    </a>
                                                                </cfif>
                                                          	</td>
                                                            <td style="text-align:right">
																<cfif ListFind('1,2,3',get_shelf.SHELF_ID)>
                                                                    #AmountFormat(get_palet_shelf_type_toplam.SAYI)#
                                                                <cfelse>
                                                                    <a style="cursor:pointer" onclick="connectAjax('#list_department_total_serial.DEPO#',#get_shelf.SHELF_ID#,0,2,0);">
                                                                        #AmountFormat(get_palet_shelf_type_toplam.SAYI)#
                                                                    </a>
                                                                </cfif>
                                                          	</td>
                                                            <td style="text-align:right">
																<cfif ListFind('1,2,3',get_shelf.SHELF_ID)>
                                                                    #AmountFormat(get_palet_shelf_type_sayilan.SAYI)#
                                                                <cfelse>
                                                                    <a style="cursor:pointer" onclick="connectAjax('#list_department_total_serial.DEPO#',#get_shelf.SHELF_ID#,0,2,1);">
                                                                        #AmountFormat(get_palet_shelf_type_sayilan.SAYI)#
                                                                    </a>
                                                                </cfif>
                                                          	</td>
                                                            <td style="text-align:center"><cfif get_paket_shelf_type_sayilan.SAYI gt 0>#AmountFormat(get_paket_shelf_type_sayilan.SAYI/get_paket_shelf_type_toplam.SAYI*100,2)#<cfelse>#AmountFormat(0,2)#</cfif></td>
                                                        </tr>
                                                        <!---*****Caddeler*****--->
                                                        <cfquery name="get_cadde" datasource="#dsn3#">
                                                            SELECT DISTINCT 
                                                                LEFT(SHELF_CODE, #x_cadde#) AS CADDE, 
                                                                SHELF_TYPE 
                                                            FROM     
                                                                EZGI_PRODUCT_PLACE WITH (NOLOCK)
                                                            WHERE  
                                                                SHELF_TYPE = #get_shelf.SHELF_ID# AND 
                                                                DEPO = '#list_department_total_serial.DEPO#'
                                                            ORDER BY 
                                                                CADDE
                                                        </cfquery>
                                                        <!---*****Caddeler*****--->
                                                     	<tr id="sub_depo_count_detail#list_department_total_serial.currentrow#_#get_shelf.currentrow#" class="nohover" style="display:none" >
                                                        	<td colspan="8">
                                                            	<table style="width:100%" cellpadding="2" cellspacing="0" border="0.5" bordercolor="darkgray">
                                                                    <tr style="font-weight:bold; text-align:center; background-color:lightgrey; height:10px">
                                                                        <td style="text-align:center;color:cadetblue; width:20px"></td>
                                                                        <td style="text-align:center;color:cadetblue; width:30px"><cf_get_lang dictionary_id='58577.Sıra'></td>
                                                                        
                                                                        <td style="text-align:center;color:cadetblue;"><cf_get_lang dictionary_id='51492.Cadde'></td>
                                                                        <td style="text-align:center;color:cadetblue; width:120px"><cf_get_lang dictionary_id='57492.Toplam'></td>
                                                                        <td style="text-align:center;color:cadetblue; width:120px"><cf_get_lang dictionary_id='54680.Sayılan'></td>
                                                                        
                                                                        <td style="text-align:center;color:cadetblue; width:120px"><cf_get_lang dictionary_id='57492.Toplam'></td>
                                                                        <td style="text-align:center;color:cadetblue; width:120px"><cf_get_lang dictionary_id='54680.Sayılan'></td>
                                                                        <td style="text-align:center;color:cadetblue; width:100px"><cf_get_lang dictionary_id='58456.Oran'></td>
                                                                    </tr>
                                                                    <cfif get_cadde.recordcount>
                                                                    	<cfloop query="get_cadde">
                                                                        	<!---Caddeler--->
                                                                            <cfquery name="get_paket_cadde_toplam" dbtype="query">
                                                                                SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID# AND SHELF_CODE LIKE '#get_cadde.CADDE#%'
                                                                            </cfquery>
                                                                            <cfquery name="get_paket_cadde_sayilan" dbtype="query">
                                                                                SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE IS_CONTROL = 1 AND DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID# AND SHELF_CODE LIKE '#get_cadde.CADDE#%'
                                                                            </cfquery>
                                                                            <cfquery name="get_palet_cadde_toplam" dbtype="query">
                                                                                SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID# AND SHELF_CODE LIKE '#get_cadde.CADDE#%'
                                                                            </cfquery>
                                                                            <cfquery name="get_palet_cadde_sayilan" dbtype="query">
                                                                                SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE IS_CONTROL = 1 AND DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID# AND SHELF_CODE LIKE '#get_cadde.CADDE#%'
                                                                            </cfquery>
                                                                            <!---Caddeler--->
                                                                            <tr>
                                                                                <!-- sil --> 
                                                                                <td align="center"></td>
                                                                                <!-- sil --> 
                                                                                <td style="text-align:right">#get_cadde.currentrow#</td>
                                                                                <td style="text-align:center; font-weight:bold">
                                                                                	<a style="cursor:pointer" onclick="connectAjax_1('#list_department_total_serial.DEPO#',#get_shelf.SHELF_ID#,'#CADDE#');">
                                                                                		#CADDE#
                                                                                 	</a>
                                                                                </td>
                                                                                <td style="text-align:right">#AmountFormat(get_paket_cadde_toplam.SAYI)#</td>
                                                                                <td style="text-align:right">#AmountFormat(get_paket_cadde_sayilan.SAYI)#</td>
                                                                                <td style="text-align:right">#AmountFormat(get_palet_cadde_toplam.SAYI)#</td>
                                                                                <td style="text-align:right">#AmountFormat(get_palet_cadde_sayilan.SAYI)#</td>
                                                                                <td style="text-align:center"><cfif get_paket_cadde_sayilan.SAYI gt 0>#AmountFormat(get_paket_cadde_sayilan.SAYI/get_paket_cadde_toplam.SAYI*100,2)#<cfelse>#AmountFormat(0,2)#</cfif></td>
                                                                          	</tr>  
                                                                        </cfloop>
                                                                    </cfif>
                                                              	</table>
                                                            </td>
                                                        </tr>
                                                    </cfloop>
                                                </cfif>
                                           </table>
                                        </td>
                                    </tr>
                                </cfoutput>
                            </cfif>
                        </tbody>
                        <tfoot>
                        	<cfoutput>
                        	<tr style="font-weight:bold">
                             	<td style="text-align:left" colspan="3">Genel Toplam</td>
                        		<td style="text-align:right">#AmountFormat(get_tum_paket_toplam.SAYI)#</td>
                             	<td style="text-align:right">#AmountFormat(get_tum_paket_sayilan.SAYI)#</td>
                           		<td style="text-align:right">#AmountFormat(get_tum_palet_toplam.SAYI)#</td>
                            	<td style="text-align:right">#AmountFormat(get_tum_palet_sayilan.SAYI)#</td>
                             	<td style="text-align:center">
									<cfif get_tum_paket_sayilan.SAYI gt 0>
                                    	#AmountFormat(get_tum_paket_sayilan.SAYI/get_tum_paket_toplam.SAYI*100,2)#
                                   	<cfelse>
                                    	#AmountFormat(0,2)#
                                  	</cfif>
                               	</td>
                            </tr>
                            </cfoutput>
                        </tfoot>
                    </cf_grid_list>
                </cf_basket>
            </div>
            <div class="col col-3"  id="display_cadde"></div>
            <div class="col col-3"  id="display_counting"></div>
		</cfform>
   	</cf_box>
</div>      
<script type="text/javascript">
	function seviyelendir(crtrow)
	{
		if(document.getElementById('row_display_'+crtrow).value==1)
		{
			document.getElementById('sub_depo_count_detail'+crtrow).style.display='';	
			document.getElementById('row_display_'+crtrow).value = 0
		}
		else
		{
			document.getElementById('sub_depo_count_detail'+crtrow).style.display='none';
			document.getElementById('row_display_'+crtrow).value =1
		}
	}
	function seviyelendir_1(crtrow,type_crtrow)
	{
		if(document.getElementById('row_display_'+crtrow+'_'+type_crtrow).value==1)
		{
			document.getElementById('sub_depo_count_detail'+crtrow+'_'+type_crtrow).style.display='';	
			document.getElementById('row_display_'+crtrow+'_'+type_crtrow).value = 0
		}
		else
		{
			document.getElementById('sub_depo_count_detail'+crtrow+'_'+type_crtrow).style.display='none';
			document.getElementById('row_display_'+crtrow+'_'+type_crtrow).value =1
		}
	}
	function connectAjax(depo,shelf_id,hucre,type,is_control,cadde)
	{
		if(hucre==0)
		{
			document.getElementById('depo_div').className='col col-9';
			document.getElementById('display_cadde').style.display='none';
			document.getElementById('display_counting').style.display='';
		}
		else
		{
			document.getElementById('depo_div').className='col col-6';
			document.getElementById('display_cadde').style.display='';
			document.getElementById('display_counting').style.display='';
			var bb = '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_perioad_based_count_cadde_operations&count_id=#attributes.count_id#&x_cadde=#x_cadde#</cfoutput>&depo='+depo+'&cadde='+cadde+'&shelf_id='+shelf_id;
			AjaxPageLoad(bb,'display_cadde',1);
		}
		var bb = '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_perioad_based_count_operations&count_id=#attributes.count_id#</cfoutput>&depo='+depo+'&type='+type+'&is_control='+is_control+'&shelf_id='+shelf_id+'&hucre='+hucre;
		AjaxPageLoad(bb,'display_counting',1);
	}
	function connectAjax_1(depo,shelf_id,cadde)
	{
		document.getElementById('depo_div').className='col col-9';
		document.getElementById('display_cadde').style.display='';
		document.getElementById('display_counting').style.display='none';
		var bb = '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_perioad_based_count_cadde_operations&count_id=#attributes.count_id#&x_cadde=#x_cadde#</cfoutput>&depo='+depo+'&cadde='+cadde+'&shelf_id='+shelf_id;
		AjaxPageLoad(bb,'display_cadde',1);
	}
	function kontrol()
	{
		return true;	
	}
</script>
