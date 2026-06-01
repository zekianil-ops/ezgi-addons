<!---
    File: _ajax_ezgi_period_based_count_store_shelf.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/03/2025
    Description: Raf ve Depo Sayım İşlemi Ajax
---> 
<cfquery name="get_count" datasource="#dsn3#">
	SELECT 
        ISNULL(IS_PALETTE_CONTENT_SAVE,0) IS_PALETTE_CONTENT_SAVE
	FROM     
     	EZGI_WM_COUNT WITH (NOLOCK)
  	WHERE
    	EZGI_WM_COUNT_ID = #attributes.count_id#
</cfquery>
<cfquery name="get_count_serial_row" datasource="#dsn3#">
	SELECT 
    	E.WM_COUNT_SERIAL_ROW_ID AS ROW_ID,
    	E.SERIAL_NO, 
        E.STOCK_ID, 
        E.PRODUCT_PLACE_ID, 
        ISNULL(E.PACKING_ID,0) AS PACKING_ID, 
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
    	E.WM_COUNT_ID = #attributes.count_id# AND
        D.DEPO = '#attributes.depo#' 
        <cfif isdefined('attributes.hucre') and len(attributes.hucre)>
       		AND E.SHELF_CODE = '#attributes.hucre#'
        </cfif>
</cfquery>
<cfquery name="get_count_packing_row" datasource="#dsn3#">
	SELECT 
    	E.WM_COUNT_PACKING_ROW_ID AS ROW_ID,
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
    	E.WM_COUNT_ID = #attributes.count_id# AND
        D.DEPO = '#attributes.depo#' 
        <cfif isdefined('attributes.hucre') and len(attributes.hucre)>
       		AND P.SHELF_CODE = '#attributes.hucre#'
        </cfif>
</cfquery>
<cfif attributes.type eq 1><!--- Update Modundaysa--->
	<cfset bulundu = 2><!---Palet Bulundu--->
	<cfquery name="get_barcode" dbtype="query"> <!---Önce Seri No Ara--->
    	SELECT ROW_ID, PALET_BARCODE, PACKING_ID, SERIAL_NO,IS_CONTROL FROM get_count_serial_row WHERE SERIAL_NO = '#attributes.barcode#'
 	</cfquery>
    <cfif not get_barcode.recordcount><!---Seri No Bulunamadıysa Palet Ara--->
    	<cfquery name="get_barcode" dbtype="query">
            SELECT ROW_ID, BARCODE,IS_CONTROL FROM get_count_packing_row WHERE BARCODE = '#attributes.barcode#'
        </cfquery>
    <cfelse>
        <cfif len(get_barcode.PALET_BARCODE)>
        	<!---<script type="text/javascript">
				alert("Girdiğiniz Seri No <cfoutput>#get_barcode.PALET_BARCODE#</cfoutput> Barkodlu Palet İçindedir.!");
			</script>--->
            <cfset bulundu = 1><!---Seri No Bulundu ve Sorun Var--->
        <cfelse>
        	<cfset bulundu = 1><!---Seri No Bulundu ve Sorun Yok--->
        </cfif>
    </cfif>
    <cfif not get_barcode.recordcount><!--- Palet ve Seri No Bulunamadıysa--->
    	<script type="text/javascript">
            alert("Girilen Barkod İlgili Lokasyonda Palet ve Seri No olarak Buluamadı!");
        </script>
    <cfelse> <!--- Palet veya Seri No Bulunduysa--->
    	<cfif get_barcode.IS_CONTROL eq 1><!---Palet veya Paket Daha Önce Okutulmuş ise--->
        	<script type="text/javascript">
				alert("Girilen <cfif bulundu eq 1>Seri No<cfelseif bulundu eq 2>Palet</cfif> Barkodu Daha Önce Okutulmuş!");
			</script>
        <cfelse> <!---İlk Defa Okutuluyorsa Kaydet--->
        	<cfif bulundu gt 0> <!---Sorun Yoksa--->
                <cfquery name="upd_barcode" datasource="#dsn3#">
                    UPDATE 
                        <cfif bulundu eq 1>
                            EZGI_WM_COUNT_SERIAL_ROW
                        <cfelseif bulundu eq 2>
                            EZGI_WM_COUNT_PACKING_ROW
                        </cfif>
                    SET          
                        IS_CONTROL = 1, 
                        CONTROL_DATE = #now()#, 
                        CONTROL_EMP = #session.ep.userid#
                    WHERE 
                        <cfif bulundu eq 1>
                            WM_COUNT_SERIAL_ROW_ID = #get_barcode.ROW_ID#
                        <cfelseif bulundu eq 2>
                            WM_COUNT_PACKING_ROW_ID = #get_barcode.ROW_ID#
                        </cfif> 
                </cfquery>
                <cfif bulundu eq 1>
                    <cfloop query="get_count_serial_row">
                        <cfif ROW_ID eq get_barcode.ROW_ID>
                            <cfset QuerySetCell(get_count_serial_row, "IS_CONTROL", 1, currentRow)> <!---Subquery deki Datayı da güncelliyorum --->
                        </cfif>
                    </cfloop>
                <cfelseif bulundu eq 2>
                    <cfloop query="get_count_packing_row">
                        <cfif ROW_ID eq get_barcode.ROW_ID>
                            <cfset QuerySetCell(get_count_packing_row, "IS_CONTROL", 1, currentRow)> <!---Subquery deki Datayı da güncelliyorum --->
                        </cfif>
                    </cfloop>
                    <cfif get_count.IS_PALETTE_CONTENT_SAVE eq 1> <!---Palet Okutulduğunda Palet İçeriği de Control edilecekse--->
                    	<cfquery name="get_serial_packing" dbtype="query">
                        	SELECT ROW_ID FROM get_count_serial_row WHERE PALET_BARCODE = '#attributes.barcode#' <!---Palete Bağlı Seri No Listesi Çekiliyor--->
                        </cfquery>
                        <cfset serial_packing_list = ValueList(get_serial_packing.ROW_ID)>
                        <cfif ListLen(serial_packing_list)>
                            <cfquery name="upd_barcode" datasource="#dsn3#"> <!---Seri nolar da control işlemi yapılıyor--->
                                UPDATE 
                                	EZGI_WM_COUNT_SERIAL_ROW
                                SET          
                                    IS_CONTROL = 1, 
                                    CONTROL_DATE = #now()#, 
                                    CONTROL_EMP = #session.ep.userid#
                                WHERE 
                                	WM_COUNT_SERIAL_ROW_ID IN (#serial_packing_list#)
                            </cfquery>
                        </cfif>
                    </cfif>
                </cfif>
          	</cfif>
      	</cfif>
    </cfif>
</cfif>
<cfif not (get_count_serial_row.recordcount or get_count_packing_row.recordcount)>
	<script type="text/javascript">
     	alert("Raf İçinde Paket veya Palet Yoktur!");
  	</script>
	<cfabort>
<cfelse>
    <cfquery name="get_tum_paket_paletli_toplam" dbtype="query">
    	SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE PACKING_ID > 0
 	</cfquery>
    <cfquery name="get_tum_paket_paletsiz_toplam" dbtype="query">
    	SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE PACKING_ID = 0
 	</cfquery>
  	<cfquery name="get_tum_paket_paletli_sayilan" dbtype="query">
    	SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE IS_CONTROL = 1 AND PACKING_ID > 0
 	</cfquery>
    <cfquery name="get_tum_paket_paletsiz_sayilan" dbtype="query">
    	SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE IS_CONTROL = 1 AND PACKING_ID = 0
 	</cfquery>
 	<cfquery name="get_tum_palet_toplam" dbtype="query">
    	SELECT COUNT (*) AS SAYI FROM get_count_packing_row
  	</cfquery>
  	<cfquery name="get_tum_palet_sayilan" dbtype="query">
     	SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE IS_CONTROL = 1
 	</cfquery>
</cfif>
<cf_basket id="report_side">
	<cf_grid_list sort="0">
         	<thead>
              	<tr>
                    <th style="text-align:center;" colspan="4"><cf_get_lang dictionary_id='100.Paket'></th>
                 	<th style="text-align:center;" colspan="2"><cf_get_lang dictionary_id='37244.Palet'></th>
             	</tr>
                <tr>
                	<th style="text-align:center; height:10px" colspan="2"><cf_get_lang dictionary_id='57492.Toplam'></th>
                   	<th style="text-align:center;" colspan="2"><cf_get_lang dictionary_id='54680.Sayılan'></th>
                 	<th style="text-align:center; width:60px" rowspan="2"><cf_get_lang dictionary_id='57492.Toplam'></th>
                	<th style="text-align:center; width:60px" rowspan="2"><cf_get_lang dictionary_id='54680.Sayılan'></th>
                </tr>
                <tr>
                	<th style="text-align:center; width:50px; height:10px"><cf_get_lang dictionary_id='1362.Palet İçi'></th>
                   	<th style="text-align:center; width:50px"><cf_get_lang dictionary_id='1363.Paletsiz'></th>
                    <th style="text-align:center; width:50px; height:10px"><cf_get_lang dictionary_id='1362.Palet İçi'></th>
                   	<th style="text-align:center; width:50px"><cf_get_lang dictionary_id='1363.Paletsiz'></th>
                </tr>
        	</thead>
            
        	<tbody>
            	<tr>
                	<cfif get_count_serial_row.recordcount or get_count_packing_row.recordcount>

                    	<cfoutput>
                 		<td style="text-align:right">#AmountFormat(get_tum_paket_paletli_toplam.SAYI)#</td>
                        <td style="text-align:right">#AmountFormat(get_tum_paket_paletsiz_toplam.SAYI)#</td>
                     	<td style="text-align:right">#AmountFormat(get_tum_paket_paletli_sayilan.SAYI)#</td>
                        <td style="text-align:right">#AmountFormat(get_tum_paket_paletsiz_sayilan.SAYI)#</td>
                     	<td style="text-align:right">#AmountFormat(get_tum_palet_toplam.SAYI)#</td>
                     	<td style="text-align:right">#AmountFormat(get_tum_palet_sayilan.SAYI)#</td>
                        </cfoutput>
                	</cfif>
              	</tr>
           	</tbody>
    </cf_grid_list>
</cf_basket>