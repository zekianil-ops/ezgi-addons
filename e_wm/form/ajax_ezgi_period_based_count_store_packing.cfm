<!---
    File: _ajax_ezgi_period_based_count_store_packing.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/03/2025
    Description: Palet İçeriği Sayım İşlemi Ajax
---> 

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
        E.PALET_BARCODE = '#attributes.packing_barcode#' 
</cfquery>
<cfif attributes.type eq 1><!--- Update Modundaysa--->
	<cfset bulundu = 1><!---Sorun Yok--->
	<cfquery name="get_barcode" dbtype="query"> <!---Önce Seri No Ara--->
    	SELECT ROW_ID, PALET_BARCODE, PACKING_ID, SERIAL_NO,IS_CONTROL FROM get_count_serial_row WHERE SERIAL_NO = '#attributes.barcode#'
 	</cfquery>
    <cfif not get_barcode.recordcount><!--- Palet ve Seri No Bulunamadıysa--->
    	<script type="text/javascript">
            alert("Girilen Barkod <cfoutput>#attributes.packing_barcode#</cfoutput> Nolu Palet İçinde Buluamadı!");
        </script>
        <cfset bulundu = 0><!--- Sorun Var--->
    <cfelse> <!--- Palet veya Seri No Bulunduysa--->
    	<cfif get_barcode.IS_CONTROL eq 1><!---Paket Daha Önce Okutulmuş ise--->
        	<script type="text/javascript">
				alert("Girilen Seri No Barkodu Daha Önce Okutulmuş!");
			</script>
            <cfset bulundu = 0><!--- Sorun Var--->
        <cfelse> <!---İlk Defa Okutuluyorsa Kaydet--->
        	<cfif bulundu gt 0> <!---Sorun Yoksa--->
                <cfquery name="upd_barcode" datasource="#dsn3#">
                    UPDATE 
                    	EZGI_WM_COUNT_SERIAL_ROW
                    SET          
                        IS_CONTROL = 1, 
                        CONTROL_DATE = #now()#, 
                        CONTROL_EMP = #session.ep.userid#
                    WHERE 
                 		WM_COUNT_SERIAL_ROW_ID = #get_barcode.ROW_ID#
                </cfquery>
            	<cfloop query="get_count_serial_row">
               		<cfif ROW_ID eq get_barcode.ROW_ID>
                     	<cfset QuerySetCell(get_count_serial_row, "IS_CONTROL", 1, currentRow)> <!---Subquery deki Datayı da güncelliyorum --->
                 	</cfif>
              	</cfloop>
          	</cfif>
      	</cfif>
    </cfif>
</cfif>
<cfif not (get_count_serial_row.recordcount or get_count_packing_row.recordcount)>
	<script type="text/javascript">
     	alert("Palet İçinde Seri No Bulunamadı!");
  	</script>
	<cfabort>
<cfelse>
    <cfquery name="get_tum_paket_toplam" dbtype="query">
    	SELECT COUNT (*) AS SAYI FROM get_count_serial_row
 	</cfquery>
  	<cfquery name="get_tum_paket_sayilan" dbtype="query">
    	SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE IS_CONTROL = 1
 	</cfquery>
</cfif>
<cf_basket id="report_side">
	<cf_grid_list sort="0">
         	<thead>
              	<tr>
                    <th style="text-align:center;" colspan="2"><cf_get_lang dictionary_id='100.Paket'></th>
            	</tr>
                <tr>
                	<th style="text-align:center; height:10px; width:50%"><cf_get_lang dictionary_id='57492.Toplam'></th>
                   	<th style="text-align:center;"><cf_get_lang dictionary_id='54680.Sayılan'></th>
                </tr>
        	</thead>
            
        	<tbody>
            	<tr>
                	<cfif get_count_serial_row.recordcount or get_count_packing_row.recordcount>

                    	<cfoutput>
                 		<td style="text-align:right">#AmountFormat(get_tum_paket_toplam.SAYI)#</td>
                     	<td style="text-align:right">#AmountFormat(get_tum_paket_sayilan.SAYI)#</td>
                        </cfoutput>
                	</cfif>
              	</tr>
           	</tbody>
    </cf_grid_list>
</cf_basket>