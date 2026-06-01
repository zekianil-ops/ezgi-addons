<!---
    File: add_ezgi_period_based_count_result.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/03/2025
    Description: Palet İçeriği Sayım İşlemi
---> 
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
        P.SHELF_TYPE,
        ISNULL(E.IS_LOST_ITEM,0) AS IS_LOST_ITEM,
        FI.FILE_NAME,
        ISNULL(FI.I_ID,0) AS I_ID 
	FROM     
    	EZGI_WM_COUNT_SERIAL_ROW AS E WITH (NOLOCK) INNER JOIN
     	EZGI_WM_DEPARTMENTS AS D WITH (NOLOCK) ON E.DEPARTMENT_ID = D.DEPARTMENT_ID AND E.LOCATION_ID = D.LOCATION_ID LEFT OUTER JOIN
      	(
            SELECT 
                I_ID, 
                SOURCE_SYSTEM, 
                FILE_NAME,
                DEPARTMENT_ID, 
                DEPARTMENT_LOCATION
            FROM     
                #dsn2_alias#.FILE_IMPORTS
            WHERE  
                SOURCE_SYSTEM = #attributes.count_id#
      	) AS FI ON E.DEPARTMENT_ID = FI.DEPARTMENT_ID AND E.LOCATION_ID = FI.DEPARTMENT_LOCATION LEFT OUTER JOIN
 		EZGI_PRODUCT_PLACE AS P WITH (NOLOCK) ON E.PRODUCT_PLACE_ID = P.PRODUCT_PLACE_ID
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
  	<cfquery name="get_tum_paket_sayilmayan" dbtype="query">
    	SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE IS_CONTROL = 0
 	</cfquery>
    <!---Tüm Depolar--->
</cfif>
<div class="col col-12 col-xs-12">
	<cf_box>
    	<div id="depo_div" class="col col-12">
         	<cf_basket id="report_bask">
              	<cf_grid_list sort="0">
                	<thead>
                     	<tr>
                         	<th style="text-align:center; width:30px" rowspan="2"><cf_get_lang dictionary_id='58577.Sıra'></th>
                          	<th style="text-align:center;" rowspan="2"><cf_get_lang dictionary_id='58763.Depo'> / <cf_get_lang dictionary_id='30031.Lokasyon'></th>
                        	<th style="text-align:center; width:120px" colspan="2"><cf_get_lang dictionary_id='100.Paket'></th>
                            <th style="text-align:center; width:100px" rowspan="2"><cf_get_lang dictionary_id='29629.Fire Fişi'></th>
                            <th style="text-align:center; width:100px" rowspan="2"><cf_get_lang dictionary_id='13.Depo Sayım Belgesi'></th>
                     	</tr>
                      	<tr>
                      		<th style="text-align:center; width:60px"><cf_get_lang dictionary_id='57492.Toplam'></th>
                        	<th style="text-align:center; width:60px"><cf_get_lang dictionary_id='54681.Sayılmayan'></th>
                   		</tr>
             		</thead>
                    <tbody>
                     	<cfif list_department_total_serial.recordcount>
                         	<cfoutput query="list_department_total_serial">
                           		 <!---Ana Depolar--->
								<cfquery name="get_paket_sayilmayan" dbtype="query">
                                 	SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE IS_CONTROL = 0 AND DEPO = '#DEPO#'
                             	</cfquery>
                                <cfquery name="get_paket_sayilmayan_fire" dbtype="query">
                                 	SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE IS_CONTROL = 0 AND DEPO = '#DEPO#' AND IS_LOST_ITEM = 1
                             	</cfquery>
                                <cfquery name="get_paket_sayilmayan_sayim" dbtype="query">
                                 	SELECT FILE_NAME FROM get_count_serial_row WHERE DEPO = '#DEPO#' AND IS_LOST_ITEM = 1 AND I_ID >0
                             	</cfquery>
                            	<!---Ana Depolar--->
                                <tr>
                                	<td style="text-align:right">#currentrow#</td>
                                	<td style="text-align:left">#DEPO_NAME#</td>
                                    <td style="text-align:right">#AmountFormat(SAYI)#</td>
                              		<td style="text-align:right">#AmountFormat(get_paket_sayilmayan.SAYI)#</td>
                                    <td style="text-align:center">
                                    	<cfif get_paket_sayilmayan.recordcount>
                                        	<cfif get_paket_sayilmayan_fire.recordcount>
                                        		<img src="images/d_ok.gif"  title="<cf_get_lang dictionary_id='47470.İşlem Tamamlandı'>" border="0">
                                          	<cfelse>
                                                <a href="javascript://" onclick="window.open('#request.self#?fuseaction=stock.add_ezgi_create_loss_receipt_warehouse&convert=1&count_id=#attributes.count_id#&depo=#depo#','_blank');">
                                                    <img src="images/b_ok.gif"  title="<cf_get_lang dictionary_id='1341.Fire Fişi Oluştur'>" border="0">	
                                                </a>
                                            </cfif>
                                       	<cfelse>
                                        	<img src="images/c_ok.gif"  title="<cf_get_lang dictionary_id='1364.İşlem Gerekmiyor'>" border="0">	
                                        </cfif>	 
                                    </td>
                                    <td style="text-align:center">
                                    	<cfif get_paket_sayilmayan.recordcount>
                                        	<cfif get_paket_sayilmayan_fire.recordcount>
                                            	<cfif get_paket_sayilmayan_sayim.recordcount>
                                                    <img src="images/d_ok.gif"  title="<cf_get_lang dictionary_id='47470.İşlem Tamamlandı'>" border="0">
                                                <cfelse>
                                                    <a href="#request.self#?fuseaction=stock.emptypopup_add_ezgi_period_based_count_result&convert=1&count_id=#attributes.count_id#&depo=#depo#">
                                                        <img src="images/b_ok.gif"  title="<cf_get_lang dictionary_id='36156.Sayım Belgesi Ekle'>" border="0">	
                                                    </a>
                                                </cfif>
                                            <cfelse>
                                            	<img src="images/b_ok.gif"  title="<cf_get_lang dictionary_id='36156.Sayım Belgesi Ekle'>" border="0">
                                            </cfif>
											
                                      	<cfelse>
                                        	<img src="images/c_ok.gif"  title="<cf_get_lang dictionary_id='1364.İşlem Gerekmiyor'>" border="0">
                                        </cfif>
                                    </td>
                             	</tr>
                         	</cfoutput>
                      	</cfif>
                  	</tbody>
             	</cf_grid_list>
         	</cf_basket>
    	</div>
   	</cf_box>
</div>     