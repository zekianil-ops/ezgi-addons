<!---
    File: ajax_ezgi_perioad_based_count_cadde_operations.cfm
    Folder: Add_Ons\ezgi\e-wm\form
    Author: Ezgi Yazılım
    Date: 01/02/2025
    Description:
--->
<cfquery name="GET_HUCRE" datasource="#dsn3#">
	SELECT 
    	PRODUCT_PLACE_ID,
     	RIGHT(SHELF_CODE,LEN(SHELF_CODE)-#attributes.x_cadde#-1) AS HUCRE, 
    	SHELF_TYPE 
	FROM     
      	EZGI_PRODUCT_PLACE WITH (NOLOCK)
	WHERE  
     	SHELF_TYPE = #attributes.shelf_id# AND 
     	DEPO = '#attributes.depo#' AND
        SHELF_CODE LIKE '#attributes.cadde#%'
 	ORDER BY 
   		HUCRE
</cfquery>
<cfset place_id_list = Valuelist(GET_HUCRE.PRODUCT_PLACE_ID)>
<cfif ListLen(place_id_list)>
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
            RIGHT(E.SHELF_CODE,LEN(E.SHELF_CODE)-#attributes.x_cadde#-1) AS HUCRE,
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
            E.PRODUCT_PLACE_ID IN (#place_id_list#)
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
            P.SHELF_TYPE,
            RIGHT(P.SHELF_CODE,LEN(P.SHELF_CODE)-#attributes.x_cadde#-1) AS HUCRE
        FROM     
            EZGI_WM_COUNT_PACKING_ROW AS E WITH (NOLOCK) INNER JOIN
            EZGI_WM_DEPARTMENTS AS D WITH (NOLOCK) ON E.STORE = D.DEPARTMENT_ID AND E.STORE_LOCATION = D.LOCATION_ID LEFT OUTER JOIN
            EZGI_PRODUCT_PLACE AS P WITH (NOLOCK) ON E.SHELF_NUMBER = P.PRODUCT_PLACE_ID
        WHERE  
            E.WM_COUNT_ID = #attributes.count_id# AND
            P.PRODUCT_PLACE_ID IN (#place_id_list#)
    </cfquery>
</cfif>
<cf_basket id="report_side">
	<cf_grid_list sort="0">
         	<thead>
            	<tr>
                	<th style="text-align:center;height:10px" colspan="7"><cf_get_lang dictionary_id='51492.Cadde'> : <cfoutput>#attributes.cadde#</cfoutput></th>
                </tr>
              	<tr>
                 	<th style="text-align:center; width:10px; height:20px" rowspan="2"><cf_get_lang dictionary_id='58577.Sıra'></th>
                  	<th style="text-align:center;" rowspan="2">Hücre</th>
                    <th style="text-align:center;" colspan="2"><cf_get_lang dictionary_id='100.Paket'></th>
                 	<th style="text-align:center;" colspan="2"><cf_get_lang dictionary_id='37244.Palet'></th>
                 	<th style="text-align:center; width:80px" rowspan="2"><cf_get_lang dictionary_id='58456.Oran'></th>
             	</tr>
                <tr>
                	<th style="text-align:center; width:80px; height:10px"><cf_get_lang dictionary_id='57492.Toplam'></th>
                   	<th style="text-align:center; width:80px"><cf_get_lang dictionary_id='54680.Sayılan'></th>
                 	<th style="text-align:center; width:80px"><cf_get_lang dictionary_id='57492.Toplam'></th>
                	<th style="text-align:center; width:80px"><cf_get_lang dictionary_id='54680.Sayılan'></th>
                </tr>
        	</thead>
        	<tbody>
            	<cfif GET_HUCRE.recordcount>
                	<cfoutput query="GET_HUCRE">
                    	<!---Hücre Tipleri--->
                       	<cfquery name="get_paket_hucre_toplam" dbtype="query">
                          	SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE HUCRE = '#GET_HUCRE.HUCRE#'
                    	</cfquery>
                    	<cfquery name="get_paket_hucre_sayilan" dbtype="query">
                    	    SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE IS_CONTROL = 1 AND HUCRE = '#GET_HUCRE.HUCRE#'
                    	</cfquery>
                    	<cfquery name="get_palet_hucre_toplam" dbtype="query">
                    	    SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE HUCRE = '#GET_HUCRE.HUCRE#'
                    	</cfquery>
                    	<cfquery name="get_palet_hucre_sayilan" dbtype="query">
                    	    SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE IS_CONTROL = 1 AND HUCRE = '#GET_HUCRE.HUCRE#'
                    	</cfquery>
                    	<!---Hücre Tipleri--->
                    	<tr>
                        	<td style="text-align:right">#currentrow#</td>
                            <td style="text-align:center">#hucre#</td>
                            <td style="text-align:right">
                            	<cfif get_paket_hucre_toplam.SAYI gt 0>
                                    <a style="cursor:pointer" onclick="connectAjax('#attributes.depo#',#attributes.shelf_id#,'#attributes.cadde#.#GET_HUCRE.HUCRE#',1,0,'#attributes.cadde#');">
                                        #AmountFormat(get_paket_hucre_toplam.SAYI)#
                                    </a>
                                <cfelse>
                                	#AmountFormat(get_paket_hucre_toplam.SAYI)#
                                </cfif>
                            </td>
                            <td style="text-align:right">
                            	<cfif get_paket_hucre_sayilan.SAYI gt 0>
                                    <a style="cursor:pointer" onclick="connectAjax('#attributes.depo#',#attributes.shelf_id#,'#attributes.cadde#.#GET_HUCRE.HUCRE#',1,1,'#attributes.cadde#');">
                                        #AmountFormat(get_paket_hucre_sayilan.SAYI)#
                                    </a>
                                <cfelse>
                                	#AmountFormat(get_paket_hucre_sayilan.SAYI)#
                                </cfif>
                            </td>
                            <td style="text-align:right">
                            	<cfif get_palet_hucre_toplam.SAYI gt 0>
                                    <a style="cursor:pointer" onclick="connectAjax('#attributes.depo#',#attributes.shelf_id#,'#attributes.cadde#.#GET_HUCRE.HUCRE#',2,0,'#attributes.cadde#');">
                                        #AmountFormat(get_palet_hucre_toplam.SAYI)#
                                    </a>
                                <cfelse>
                                	#AmountFormat(get_palet_hucre_toplam.SAYI)#
                                </cfif>
                            </td>
                            <td style="text-align:right">
                            	<cfif get_palet_hucre_sayilan.SAYI gt 0>
                                    <a style="cursor:pointer" onclick="connectAjax('#attributes.depo#',#attributes.shelf_id#,'#attributes.cadde#.#GET_HUCRE.HUCRE#',2,1,'#attributes.cadde#');">
                                        #AmountFormat(get_palet_hucre_sayilan.SAYI)#
                                    </a>
                                <cfelse>
                                	#AmountFormat(get_palet_hucre_sayilan.SAYI)#
                                </cfif>
                            </td>
                            <td style="text-align:right">
                            	<cfif get_paket_hucre_sayilan.SAYI gt 0>
                                	#AmountFormat(get_paket_hucre_sayilan.SAYI/get_paket_hucre_toplam.SAYI*100,2)#
                              	<cfelse>
                                	#AmountFormat(0,2)#
                              	</cfif>
                            </td>
                        </tr>
                    </cfoutput>
                </cfif>
           	</tbody>
    </cf_grid_list>
</cf_basket>