<!---
    File: ajax_ezgi_perioad_based_count_operations.cfm
    Folder: Add_Ons\ezgi\e-wm\form
    Author: Ezgi Yazılım
    Date: 01/02/2025
    Description:
--->

<cfquery name="get_count_row" datasource="#dsn3#">
    	SELECT DISTINCT
        	D.DEPO_NAME, 
            E.SERIAL_NO as BARCODE, 
            E.PALET_BARCODE,
            E.PRODUCT_NAME
		FROM     
        	EZGI_WM_DEPARTMENTS AS D WITH (NOLOCK) INNER JOIN
            EZGI_WM_SERIAL_NO_LAST_STATUS AS E ON D.DEPARTMENT_ID = E.DEPARTMENT_ID AND D.LOCATION_ID = E.LOCATION_ID INNER JOIN
            EZGI_WM_IS_SERIAL_NO_LIVE AS ESL ON E.SERIAL_NO = ESL.SERIAL_NO LEFT OUTER JOIN
            EZGI_PRODUCT_PLACE AS P WITH (NOLOCK) ON E.PRODUCT_PLACE_ID = P.PRODUCT_PLACE_ID
      	WHERE  
            D.DEPO = '#attributes.depo#'
            <cfif attributes.shelf_id gt 0>
            	AND P.SHELF_TYPE = #attributes.shelf_id#
       		</cfif> 
            <cfif attributes.hucre gt 0>
            	AND E.SHELF_CODE = '#attributes.hucre#'
       		</cfif>
      	ORDER BY
        	E.PALET_BARCODE,
            E.SERIAL_NO
</cfquery>
<cf_basket id="report_side">
	<cf_grid_list sort="0">
         	<thead>
            	<tr>
                	<cfoutput>
                 	<th style="text-align:center; width:30px" colspan="4">
                    	<cfif attributes.shelf_id gt 0>
                        	<cfif attributes.shelf_id eq 1>
                            	Toplama Adresi&nbsp;
                          	<cfelseif attributes.shelf_id eq 2>
                            	Stoklama Adresi&nbsp;
                          	<cfelseif attributes.shelf_id eq 3>
                            	Karma Adresi&nbsp;
                          	<cfelseif attributes.shelf_id eq 4>
                            	Transfer Adresi&nbsp;
                            <cfelseif attributes.shelf_id eq 5>
                            	Sevkiyat Adresi&nbsp;
                            </cfif>
                            
                        <cfelseif attributes.hucre gt 0>
                        	#attributes.hucre# Hücresi&nbsp;
                        <cfelse>
                        	#get_count_row.DEPO_NAME# Lokasyonu&nbsp;
                        </cfif>
                        <cfif attributes.type eq 1>
                            Paketler Listesi
                        <cfelse>
                            Paletler Listesi
                        </cfif>
                    </th>
                    </cfoutput>
             	</tr>
              	<tr>
                 	<th style="text-align:center; width:30px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                  	<th style="text-align:center;"><cf_get_lang dictionary_id='57637.Seri No'></th>
                 	<th style="text-align:center;"><cf_get_lang dictionary_id='1312.Palet Barkodu'></th>
                    <th style="text-align:center;"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
             	</tr>
        	</thead>
        	<tbody>
            	<cfif get_count_row.recordcount>
                	<cfoutput query="get_count_row">
                    	<tr>
                        	<td style="text-align:right">#currentrow#</td>
                            <td style="text-align:center">#BARCODE#</td>
                      		<td style="text-align:center">#PALET_BARCODE#</td>
                            <td style="text-align:left">#PRODUCT_NAME#</td>
                        </tr>
                    </cfoutput>
                </cfif>
           	</tbody>
    </cf_grid_list>
</cf_basket>