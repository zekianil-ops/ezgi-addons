<!---
    File: ajax_ezgi_wm_ready_cadde.cfm
    Folder: Add_Ons\ezgi\e-wm\form
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description:
--->
<cfquery name="get_shelf_cat" datasource="#dsn3#">
	SELECT  EZGI_PLACE_CAT_ID, EZGI_PLACE_CAT FROM EZGI_WM_SETUP_PLACE_CAT
</cfquery>
<cfoutput query="get_shelf_cat">
	<cfset 'EZGI_PLACE_CAT_#EZGI_PLACE_CAT_ID#' = EZGI_PLACE_CAT>
</cfoutput>
<cfquery name="GET_HUCRE" datasource="#dsn3#">
	SELECT 
    	PRODUCT_PLACE_ID,
        PLACE_CAT_ID,
     	RIGHT(SHELF_CODE,LEN(SHELF_CODE)-#attributes.x_cadde#-1) AS HUCRE, 
    	SHELF_TYPE,
      	ISNULL(WIDTH,0) AS WIDTH, 
        ISNULL(HEIGHT,0) AS HEIGHT, 
        ISNULL(DEPTH,0) AS DEPTH, 
        ISNULL(MAX_STOCK,0) AS MAX_STOCK, 
        ISNULL(MIN_STOCK,0) AS MIN_STOCK 
	FROM     
      	EZGI_PRODUCT_PLACE WITH (NOLOCK)
	WHERE  
    	ISNULL(PLACE_STATUS,0) = 1 AND
     	SHELF_TYPE = #attributes.shelf_id# AND 
     	DEPO = '#attributes.depo#' AND
        SHELF_CODE LIKE '#attributes.cadde#%'
 	ORDER BY 
   		HUCRE
</cfquery>
<cfset place_id_list = Valuelist(GET_HUCRE.PRODUCT_PLACE_ID)>
<cfif ListLen(place_id_list)>
	<cfquery name="get_shelf_total" datasource="#dsn3#">
        SELECT 
            SHELF_TYPE, 
            DEPO,
            SHELF_CODE,
            RIGHT(SHELF_CODE,LEN(SHELF_CODE)-#attributes.x_cadde#-1) AS HUCRE
        FROM     
            EZGI_PRODUCT_PLACE AS P WITH (NOLOCK)
      	WHERE
        	SHELF_CODE LIKE '#attributes.cadde#%'
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
            ISNULL(EWM.SHELF_CODE,0) SHELF_CODE,
            CASE 
    			WHEN LEN(ISNULL(P.SHELF_CODE, '')) > #attributes.x_cadde# + 1 
    			THEN RIGHT(P.SHELF_CODE, LEN(P.SHELF_CODE) - #attributes.x_cadde# -1)
    			ELSE ''
			END AS HUCRE
        FROM     
         	EZGI_WM_IS_SERIAL_NO_LIVE AS EWL INNER JOIN
         	EZGI_WM_SERIAL_NO_LAST_STATUS AS EWM ON EWL.SERIAL_NO = EWM.SERIAL_NO INNER JOIN
           	EZGI_WM_DEPARTMENTS AS D WITH (NOLOCK) ON EWM.DEPARTMENT_ID = D.DEPARTMENT_ID AND EWM.LOCATION_ID = D.LOCATION_ID LEFT OUTER JOIN
        	EZGI_PRODUCT_PLACE AS P WITH (NOLOCK) ON EWM.PRODUCT_PLACE_ID = P.PRODUCT_PLACE_ID
 	   WHERE  
            EWM.PRODUCT_PLACE_ID IN (#place_id_list#)
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
            CASE 
    			WHEN LEN(ISNULL(P.SHELF_CODE, '')) > #attributes.x_cadde# + 1 
    			THEN RIGHT(P.SHELF_CODE, LEN(P.SHELF_CODE) - #attributes.x_cadde# -1)
    			ELSE ''
			END AS HUCRE,
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
     	 WHERE  
            P.PRODUCT_PLACE_ID IN (#place_id_list#)
    </cfquery>

</cfif>
<cfif GET_HUCRE.recordcount>
<cf_basket id="report_side">
	<cf_grid_list sort="0">
         	<thead>
            	<tr>
                	<th style="text-align:center;height:10px" colspan="<cfif get_count_serial_row.SHELF_TYPE  eq 1>7<cfelse>5</cfif>"><cf_get_lang dictionary_id='51492.Cadde'> : <cfoutput>#attributes.cadde#</cfoutput></th>
                </tr>
                
                 <tr>
                 	<th style="text-align:center; width:30px" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                                
                 	<th style="text-align:center;" ><cf_get_lang dictionary_id='1374.Hücre'></th>
                    <th style="text-align:center;" >Raf Kategorisi</th>
                 	<th style="text-align:center; width:80px" ><cf_get_lang dictionary_id='100.Paket'></th>
               		
                    <cfif get_count_serial_row.SHELF_TYPE  eq 1>
                    	<th style="text-align:center; width:80px" ><cf_get_lang dictionary_id='63814.Maximum'></th>
                        <th style="text-align:center; width:80px" ><cf_get_lang dictionary_id='37321.Minimum'></th>
                        <th style="text-align:center; width:80px" ><cf_get_lang dictionary_id='58456.Oran'></th>
                  	<cfelse>
                    	<th style="text-align:center; width:80px" ><cf_get_lang dictionary_id='37244.Palet'></th>
                    </cfif>
          		</tr>
        	</thead>
        	<tbody>
            	<cfif GET_HUCRE.recordcount>
                	<cfoutput query="GET_HUCRE">
                    	<!---Hücre Tipleri--->
                       	<cfquery name="get_paket_hucre_toplam" dbtype="query">
                          	SELECT COUNT (*) AS SAYI FROM get_count_serial_row WHERE HUCRE = '#GET_HUCRE.HUCRE#'
                    	</cfquery>
                    	<cfquery name="get_palet_hucre_toplam" dbtype="query">
                    	    SELECT COUNT (*) AS SAYI FROM get_count_packing_row WHERE PAKET_SAYI >0 AND HUCRE = '#GET_HUCRE.HUCRE#'
                    	</cfquery>
                        
                        <cfquery name="get_hucre_full_shelf" dbtype="query">
                         	SELECT HUCRE FROM get_count_serial_row WHERE SHELF_CODE <> '0' AND HUCRE = '#GET_HUCRE.HUCRE#' GROUP BY HUCRE
                     	</cfquery>
                        
                    	<!---Hücre Tipleri--->
                    	<tr>
                        	<td style="text-align:right">#currentrow#</td>
                            <td style="text-align:center">#hucre#</td>
                            <td style="text-align:left"><cfif isdefined('EZGI_PLACE_CAT_#PLACE_CAT_ID#')>#Evaluate('EZGI_PLACE_CAT_#PLACE_CAT_ID#')#</cfif></td>
                            <td style="text-align:right">
                            	<cfif get_paket_hucre_toplam.SAYI gt 0>
                                    <a style="cursor:pointer" onclick="connectAjax('#attributes.depo#',#attributes.shelf_id#,'#attributes.cadde#.#GET_HUCRE.HUCRE#',1,0,'#attributes.cadde#');">
                                        #AmountFormat(get_paket_hucre_toplam.SAYI)#
                                    </a>
                                <cfelse>
                                	#AmountFormat(get_paket_hucre_toplam.SAYI)#
                                </cfif>
                            </td>
                            
                            <cfif get_count_serial_row.SHELF_TYPE  eq 1>
                                <td style="text-align:right">#AmountFormat(MAX_STOCK)#</td>
                                <td style="text-align:right">#AmountFormat(MIN_STOCK)#</td>
                                <td style="text-align:center;  <cfif MIN_STOCK gt 0 and MIN_STOCK gte get_paket_hucre_toplam.SAYI>background-color:red; color:white</cfif>">
                                    <cfif MAX_STOCK gt 0 and get_paket_hucre_toplam.SAYI GT 0>
                                        #AmountFormat(get_paket_hucre_toplam.SAYI/MAX_STOCK*100)#
                                    </cfif>
                                </td>
                            <cfelse>
                                <td style="text-align:right">
                                    <cfif get_palet_hucre_toplam.SAYI gt 0>
                                        <a style="cursor:pointer" onclick="connectAjax('#attributes.depo#',#attributes.shelf_id#,'#attributes.cadde#.#GET_HUCRE.HUCRE#',2,0,'#attributes.cadde#');">
                                            #AmountFormat(get_palet_hucre_toplam.SAYI)#
                                        </a>
                                    <cfelse>
                                        #AmountFormat(get_palet_hucre_toplam.SAYI)#
                                    </cfif>
                                </td>
                            </cfif>
                        </tr>
                    </cfoutput>
                </cfif>
           	</tbody>
    </cf_grid_list>
</cf_basket>
</cfif>