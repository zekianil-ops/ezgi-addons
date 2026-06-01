<!---
    File: dashboard_ezgi_wm_ready.cfm
    Folder: Add_Ons\ezgi\e-wm\display
    Author: Ezgi Yazılım
    Date: 01/02/2025
    Description:
--->
<cf_xml_page_edit>
<cfquery name="get_shelf" datasource="#dsn#">
	SELECT SHELF_ID, SHELF_NAME FROM SHELF ORDER BY SHELF_ID
</cfquery>
<cfquery name="get_shelf_total" datasource="#dsn3#">
	SELECT 
    	SHELF_TYPE, 
        DEPO,
        SHELF_CODE 
	FROM     
    	EZGI_PRODUCT_PLACE AS P WITH (NOLOCK)
   	WHERE
    	ISNULL(PLACE_STATUS,0) = 1
</cfquery>
<cfquery name="get_count_serial_row" datasource="#dsn3#">
	SELECT DISTINCT
    	D.DEPO_NAME, 
        D.DEPO, 
        P.SHELF_TYPE, 
        EWM.SERIAL_NO, 
        EWM.STOCK_ID, 
        EWM.PRODUCT_PLACE_ID, 
        EWM.PACKING_ID, 
        EWM.SPECT_ID, 
        EWM.PALET_BARCODE, 
        EWM.PRODUCT_NAME, 
        EWM.IS_PROTOTYPE,
        ISNULL(EWM.SHELF_CODE,0) SHELF_CODE
	FROM     
    	EZGI_WM_IS_SERIAL_NO_LIVE AS EWL INNER JOIN
        EZGI_WM_SERIAL_NO_LAST_STATUS AS EWM ON EWL.SERIAL_NO = EWM.SERIAL_NO INNER JOIN
        EZGI_WM_DEPARTMENTS AS D WITH (NOLOCK) ON EWM.DEPARTMENT_ID = D.DEPARTMENT_ID AND EWM.LOCATION_ID = D.LOCATION_ID LEFT OUTER JOIN
        EZGI_PRODUCT_PLACE AS P WITH (NOLOCK) ON EWM.PRODUCT_PLACE_ID = P.PRODUCT_PLACE_ID
</cfquery>
<cfquery name="get_count_packing_row" datasource="#dsn3#">
	SELECT 
    	D.DEPO_NAME, 
        D.DEPO, 
        ISNULL(P.SHELF_CODE, 0) AS SHELF_CODE, 
        P.PRODUCT_PLACE_ID, 
        P.SHELF_TYPE, 
        EWPL.PACKING_ID, 
        EWPL.BARCODE, 
        EWPL.AMOUNT, 
        EWPL.IS_KARMA,
        (
         	SELECT 
             	COUNT(*) AS SAYI
			FROM     
             	EZGI_WM_IS_SERIAL_NO_LIVE AS EWL INNER JOIN
             	EZGI_WM_SERIAL_NO_LAST_STATUS AS EWM ON EWL.SERIAL_NO = EWM.SERIAL_NO
			WHERE  
           	EWM.PRODUCT_PLACE_ID = P.PRODUCT_PLACE_ID
   		) AS PAKET_SAYI
	FROM     
    	EZGI_WM_PACKING_LAST_STATUS AS EWPL INNER JOIN
        EZGI_WM_DEPARTMENTS AS D WITH (NOLOCK) ON EWPL.STORE = D.DEPARTMENT_ID AND EWPL.STORE_LOCATION = D.LOCATION_ID LEFT OUTER JOIN
        EZGI_PRODUCT_PLACE AS P WITH (NOLOCK) ON EWPL.SHELF_NUMBER = P.PRODUCT_PLACE_ID
</cfquery>
<cfif not (get_count_serial_row.recordcount or get_count_packing_row.recordcount)>
	<script type="text/javascript">
     	alert("Palet veya Paket Kaydı Bulunamadı!");
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
    <cfset depo_list = ValueList(list_department_total_serial.DEPO)>

  	<!---Tüm Depolar--->
    <cfquery name="get_tum_paket_toplam" dbtype="query">
    	SELECT COUNT (*) AS SAYI FROM get_count_serial_row
 	</cfquery>

 	<cfquery name="get_tum_palet_toplam" dbtype="query">
    	SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE PAKET_SAYI >0
  	</cfquery>
	
    <cfquery name="get_tum_full_shelf" dbtype="query">
    	SELECT SHELF_CODE FROM get_count_serial_row WHERE SHELF_CODE <> '0' GROUP BY SHELF_CODE
    </cfquery>
    <cfquery name="get_tum_shelf_total" dbtype="query">
    	SELECT COUNT(*) AS TOPLAM_RAF FROM get_shelf_total 
        WHERE
        	<cfloop from="1" to="#Listlen(depo_list)#" index="i"> 
        		DEPO = '#ListGetAt(depo_list,i)#'
                <cfif Listlen(depo_list) gt i>OR</cfif>
            </cfloop>
    </cfquery>
    <!---Tüm Depolar--->
</cfif>
<cf_catalystHeader>
<div class="col col-12 col-xs-12">
	<cf_box>
    	<cfform name="form_basket" method="post" action="stock.dashboard_ezgi_wm_ready">
 			<div id="depo_div" class="col col-12">
                <cf_basket id="report_bask">
                    <cf_grid_list sort="0">
                        <thead>
                            <tr>
                                <th style="text-align:center; width:20px" ></th>
                                <th style="text-align:center; width:30px" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                                
                                <th style="text-align:center;" ><cf_get_lang dictionary_id='58763.Depo'> / <cf_get_lang dictionary_id='30031.Lokasyon'></th>
                                <th style="text-align:center; width:80px" ><cf_get_lang dictionary_id='100.Paket'></th>
                                <th style="text-align:center; width:80px" ><cf_get_lang dictionary_id='37244.Palet'></th>
                                <th style="text-align:center; width:80px" ><cf_get_lang dictionary_id='1371.Toplam Raf'></th>
                                <th style="text-align:center; width:80px" ><cf_get_lang dictionary_id='1373.Dolu Raf'></th>
                                <th style="text-align:center; width:80px" ><cf_get_lang dictionary_id='58456.Oran'></th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfif list_department_total_serial.recordcount>
                                <cfoutput query="list_department_total_serial">
                                	 <!---Ana Depolar--->

                                    <cfquery name="get_palet_toplam" dbtype="query">
                                        SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE DEPO = '#DEPO#' AND PAKET_SAYI >0
                                    </cfquery>
                                    <!---Depoda Raf Arama--->
                                    <cfquery name="get_paket_shelf" dbtype="query">
                                     	SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE DEPO = '#DEPO#' AND SHELF_TYPE IN (1,2,3,4,5)
                                  	</cfquery>
                                    
                                    <cfquery name="get_depo_full_shelf" dbtype="query">
                                        SELECT SHELF_CODE FROM get_count_serial_row WHERE SHELF_CODE <> '0' AND DEPO = '#DEPO#' GROUP BY SHELF_CODE
                                    </cfquery>
                                    <cfquery name="get_depo_shelf_total" dbtype="query">
                                        SELECT COUNT(*) AS TOPLAM_RAF FROM get_shelf_total WHERE DEPO = '#DEPO#'
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
                                            	#AmountFormat(get_palet_toplam.SAYI)#
                                          	<cfelse>
                                            	<a style="cursor:pointer" onclick="connectAjax('#DEPO#',0,0,2,0);">
                                                	#AmountFormat(get_palet_toplam.SAYI)#
                                                </a>
                                            </cfif>
                                        </td>
                                        <td style="text-align:right">#AmountFormat(get_depo_shelf_total.TOPLAM_RAF)#</td>
                                        <td style="text-align:right">#AmountFormat(get_depo_full_shelf.recordcount)#</td>
                                        <td style="text-align:center">
                                            <cfif get_depo_shelf_total.TOPLAM_RAF gt 0 and get_depo_full_shelf.recordcount>
                                                #AmountFormat(get_depo_full_shelf.recordcount/get_depo_shelf_total.TOPLAM_RAF*100)#
                                            </cfif>
                                        </td>
                                    </tr>
                                    
                                    <tr id="sub_depo_count_detail#currentrow#" class="nohover" style="display:none" >
                                        <td colspan="8">
                                           <table style="width:100%" cellpadding="2" cellspacing="0" border="1">
                                           		<tr style="font-weight:bold; text-align:center; background-color:gainsboro; height:10px">
                                                	<td style="text-align:center;color:cadetblue; width:20px"></td>
                                                    <td style="text-align:center;color:cadetblue; width:30px"><cf_get_lang dictionary_id='58577.Sıra'></td>
                                                    
                                                    <td style="text-align:center;color:cadetblue;"><cf_get_lang dictionary_id='45925.Raf Tipi'></td>
                                                    
                                                    <td style="text-align:center;color:cadetblue; width:80px"><cf_get_lang dictionary_id='100.Paket'></td>
                                                    <td style="text-align:center;color:cadetblue; width:80px"><cf_get_lang dictionary_id='37244.Palet'></td>
                                                    <td style="text-align:center;color:cadetblue; width:80px"><cf_get_lang dictionary_id='1371.Toplam Raf'></td>
                                                    <td style="text-align:center;color:cadetblue; width:80px"><cf_get_lang dictionary_id='1373.Dolu Raf'></td>
                                                    <td style="text-align:center;color:cadetblue; width:80px"><cf_get_lang dictionary_id='58456.Oran'></td>
                                                </tr>
                                                <cfif get_shelf.recordcount>
                                                	<cfloop query="get_shelf">
														<!---Raf Tipleri--->
                                                        <cfquery name="get_paket_shelf_type_toplam" dbtype="query">
                                                            SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID#
                                                        </cfquery>

                                                        <cfquery name="get_palet_shelf_type_toplam" dbtype="query">
                                                            SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE PAKET_SAYI >0 AND DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID#
                                                        </cfquery>
                                                        
                                                        <cfquery name="get_shelf_type_full_shelf" dbtype="query">
                                                            SELECT SHELF_CODE FROM get_count_serial_row WHERE SHELF_CODE <> '0' AND DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID# GROUP BY SHELF_CODE
                                                        </cfquery>
                                                        <cfquery name="get_shelf_type_shelf_total" dbtype="query">
                                                            SELECT COUNT(*) AS TOPLAM_RAF FROM get_shelf_total WHERE DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID#
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
                                                                    #AmountFormat(get_palet_shelf_type_toplam.SAYI)#
                                                                <cfelse>
                                                                    <a style="cursor:pointer" onclick="connectAjax('#list_department_total_serial.DEPO#',#get_shelf.SHELF_ID#,0,2,0);">
                                                                        #AmountFormat(get_palet_shelf_type_toplam.SAYI)#
                                                                    </a>
                                                                </cfif>
                                                          	</td>
                                                            <td style="text-align:right">#AmountFormat(get_shelf_type_shelf_total.TOPLAM_RAF)#</td>
                                                            <td style="text-align:right">#AmountFormat(get_shelf_type_full_shelf.recordcount)#</td>
                                                            <td style="text-align:center">
                                                                <cfif get_shelf_type_shelf_total.TOPLAM_RAF gt 0 and get_shelf_type_full_shelf.recordcount>
                                                                    #AmountFormat(get_shelf_type_full_shelf.recordcount/get_shelf_type_shelf_total.TOPLAM_RAF*100)#
                                                                </cfif>
                                                            </td>

                                                        </tr>
                                                        <!---*****Caddeler*****--->
                                                        <cfquery name="get_cadde" datasource="#dsn3#">
                                                            SELECT DISTINCT 
                                                                LEFT(SHELF_CODE, #x_cadde#) AS CADDE, 
                                                                SHELF_TYPE 
                                                            FROM     
                                                                EZGI_PRODUCT_PLACE WITH (NOLOCK)
                                                            WHERE 
                                                            	ISNULL(PLACE_STATUS,0) = 1 AND 
                                                                SHELF_TYPE = #get_shelf.SHELF_ID# AND 
                                                                DEPO = '#list_department_total_serial.DEPO#'
                                                            ORDER BY 
                                                                CADDE
                                                        </cfquery>
                                                        <!---*****Caddeler*****--->
                                                     	<tr id="sub_depo_count_detail#list_department_total_serial.currentrow#_#get_shelf.currentrow#" class="nohover" style="display:none" >
                                                        	<td colspan="8">
                                                            	<table style="width:100%" cellpadding="2" cellspacing="0" border="0.5" bordercolor="darkgray">
                                                                    <tr style="font-weight:bold; text-align:center; background-color:silver; height:10px">
                                                                        <td style="text-align:center;color:cadetblue; width:20px"></td>
                                                                        <td style="text-align:center;color:cadetblue; width:30px"><cf_get_lang dictionary_id='58577.Sıra'></td>
                                                                        
                                                                        <td style="text-align:center;color:cadetblue;"><cf_get_lang dictionary_id='51492.Cadde'></td>
                                                                              
                                                                        <td style="text-align:center;color:cadetblue; width:80px"><cf_get_lang dictionary_id='100.Paket'></td>
                                                                        <td style="text-align:center;color:cadetblue; width:80px"><cf_get_lang dictionary_id='37244.Palet'></td>
                                                                        <td style="text-align:center;color:cadetblue; width:80px"><cf_get_lang dictionary_id='1371.Toplam Raf'></td>
                                                                        <td style="text-align:center;color:cadetblue; width:80px"><cf_get_lang dictionary_id='1373.Dolu Raf'></td>
                                                                        <td style="text-align:center;color:cadetblue; width:80px"><cf_get_lang dictionary_id='58456.Oran'></td>
                                                                    </tr>
                                                                    <cfif get_cadde.recordcount>
                                                                    	<cfloop query="get_cadde">
                                                                        	<!---Caddeler--->
                                                                            <cfquery name="get_paket_cadde_toplam" dbtype="query">
                                                                                SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID# AND SHELF_CODE LIKE '#get_cadde.CADDE#%'
                                                                            </cfquery>

                                                                            <cfquery name="get_palet_cadde_toplam" dbtype="query">
                                                                                SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE PAKET_SAYI >0 AND DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID# AND SHELF_CODE LIKE '#get_cadde.CADDE#%'
                                                                            </cfquery>
                                                                            
                                                                            <cfquery name="get_cadde_full_shelf" dbtype="query">
                                                                                SELECT SHELF_CODE FROM get_count_serial_row WHERE SHELF_CODE <> '0' AND DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID# AND SHELF_CODE LIKE '#get_cadde.CADDE#%' GROUP BY SHELF_CODE
                                                                            </cfquery>
                                                                            <cfquery name="get_cadde_shelf_total" dbtype="query">
                                                                                SELECT COUNT(*) AS TOPLAM_RAF FROM get_shelf_total WHERE DEPO = '#list_department_total_serial.DEPO#' AND SHELF_TYPE = #get_shelf.SHELF_ID# AND SHELF_CODE LIKE '#get_cadde.CADDE#%'
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
                                                                                <td style="text-align:right">#AmountFormat(get_palet_cadde_toplam.SAYI)#</td>
                                                                             	<td style="text-align:right">#AmountFormat(get_cadde_shelf_total.TOPLAM_RAF)#</td>
                                                                                <td style="text-align:right">#AmountFormat(get_cadde_full_shelf.recordcount)#</td>
                                                                                <td style="text-align:center">
                                                                                    <cfif get_cadde_shelf_total.TOPLAM_RAF gt 0 and get_cadde_full_shelf.recordcount>
                                                                                        #AmountFormat(get_cadde_full_shelf.recordcount/get_cadde_shelf_total.TOPLAM_RAF*100)#
                                                                                    </cfif>
                                                                                </td>
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
                           		<td style="text-align:right">#AmountFormat(get_tum_palet_toplam.SAYI)#</td>
                            	
                           		<td style="text-align:right">#AmountFormat(get_tum_shelf_total.TOPLAM_RAF)#</td>
                                <td style="text-align:right">#AmountFormat(get_tum_full_shelf.recordcount)#</td>
                            	<td style="text-align:center">
                               		<cfif get_tum_shelf_total.TOPLAM_RAF gt 0 and get_tum_full_shelf.recordcount>
                                   		#AmountFormat(get_tum_full_shelf.recordcount/get_tum_shelf_total.TOPLAM_RAF*100)#
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
			var bb = '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_wm_ready_cadde&x_cadde=#x_cadde#</cfoutput>&depo='+depo+'&cadde='+cadde+'&shelf_id='+shelf_id;
			AjaxPageLoad(bb,'display_cadde',1);
		}
		var bb = '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_wm_ready</cfoutput>&depo='+depo+'&type='+type+'&is_control='+is_control+'&shelf_id='+shelf_id+'&hucre='+hucre;
		AjaxPageLoad(bb,'display_counting',1);
	}
	function connectAjax_1(depo,shelf_id,cadde)
	{
		document.getElementById('depo_div').className='col col-9';
		document.getElementById('display_cadde').style.display='';
		document.getElementById('display_counting').style.display='none';
		var bb = '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_wm_ready_cadde&x_cadde=#x_cadde#</cfoutput>&depo='+depo+'&cadde='+cadde+'&shelf_id='+shelf_id;
		AjaxPageLoad(bb,'display_cadde',1);
	}
	function kontrol()
	{
		return true;	
	}
</script>
