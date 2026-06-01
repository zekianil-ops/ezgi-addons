<!---
    File: ajax_ezgi_perioad_based_count_operations.cfm
    Folder: Add_Ons\ezgi\e-wm\form
    Author: Ezgi Yazılım
    Date: 01/02/2025
    Description:
--->
<cfquery name="get_count" datasource="#dsn3#">
	SELECT 
        IS_PALETTE_CONTENT_SAVE
	FROM     
     	EZGI_WM_COUNT WITH (NOLOCK)
  	WHERE
    	EZGI_WM_COUNT_ID = #attributes.count_id#
</cfquery>
<cfif attributes.type eq 1>
    <cfquery name="get_count_row" datasource="#dsn3#">
        SELECT 
        	E.WM_COUNT_SERIAL_ROW_ID AS ROW_ID,
        	D.DEPO_NAME,
            E.SERIAL_NO as BARCODE, 
            E.PRODUCT_NAME,
            E.PALET_BARCODE,
            ISNULL(E.IS_CONTROL,0) AS IS_CONTROL, 
            E.CONTROL_DATE, 
            E.CONTROL_EMP
        FROM     
            EZGI_WM_COUNT_SERIAL_ROW AS E WITH (NOLOCK) INNER JOIN
            EZGI_WM_DEPARTMENTS AS D WITH (NOLOCK) ON E.DEPARTMENT_ID = D.DEPARTMENT_ID AND E.LOCATION_ID = D.LOCATION_ID LEFT OUTER JOIN
            EZGI_PRODUCT_PLACE AS P WITH (NOLOCK) ON E.PRODUCT_PLACE_ID = P.PRODUCT_PLACE_ID
        WHERE  
            E.WM_COUNT_ID = #attributes.count_id# AND
            D.DEPO = '#attributes.depo#'
            <cfif attributes.is_control eq 1>
            	AND ISNULL(E.IS_CONTROL,0) =1
            </cfif> 
            <cfif attributes.shelf_id gt 0>
            	AND P.SHELF_TYPE = #attributes.shelf_id#
       		</cfif> 
            <cfif attributes.hucre gt 0>
            	AND E.SHELF_CODE = '#attributes.hucre#'
       		</cfif>
      	ORDER BY
        	E.PRODUCT_NAME,
            E.SERIAL_NO
    </cfquery>
<cfelse>
    <cfquery name="get_count_row" datasource="#dsn3#">
        SELECT 
        	E.WM_COUNT_PACKING_ROW_ID AS ROW_ID,
        	D.DEPO_NAME,
            E.BARCODE, 
            ISNULL(E.IS_CONTROL,0) AS IS_CONTROL,  
            E.CONTROL_DATE, 
            E.CONTROL_EMP
        FROM     
            EZGI_WM_COUNT_PACKING_ROW AS E WITH (NOLOCK) INNER JOIN
            EZGI_WM_DEPARTMENTS AS D WITH (NOLOCK) ON E.STORE = D.DEPARTMENT_ID AND E.STORE_LOCATION = D.LOCATION_ID LEFT OUTER JOIN
            EZGI_PRODUCT_PLACE AS P WITH (NOLOCK) ON E.SHELF_NUMBER = P.PRODUCT_PLACE_ID
        WHERE  
            E.WM_COUNT_ID = #attributes.count_id# AND
            D.DEPO = '#attributes.depo#'
            <cfif attributes.is_control eq 1>
            	AND ISNULL(E.IS_CONTROL,0) =1
            </cfif> 
            <cfif attributes.shelf_id gt 0>
            	AND P.SHELF_TYPE = #attributes.shelf_id#
       		</cfif>   
            <cfif attributes.hucre gt 0>
            	AND P.SHELF_CODE = '#attributes.hucre#'
       		</cfif> 
      	ORDER BY
        	E.BARCODE
    </cfquery>
</cfif>
<cf_basket id="report_side">
	<cf_grid_list sort="0">
         	<thead>
            	<tr>
                	<cfoutput>
                 	<th style="text-align:center; width:30px" colspan="<cfif attributes.type eq 1>6<cfelse>5</cfif>">
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
                        <cfif attributes.is_control eq 1>
                        	Kontrol Edilmiş&nbsp;
                        <cfelse>
                        	Kontrol Edilmemiş&nbsp;
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
                 	<th style="text-align:center; width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                  	<th style="text-align:center;"><cfif attributes.type eq 1><cf_get_lang dictionary_id='57637.Seri No'><cfelse><cf_get_lang dictionary_id='1312.Palet Barkodu'></cfif></th>
                    <cfif attributes.type eq 1>
                    	<th style="text-align:center;"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                    </cfif>
                    <th style="text-align:center;"><cf_get_lang dictionary_id='57032.Kontrol Eden'></th>
                 	<th style="text-align:center;"><cf_get_lang dictionary_id='57094.Kontrol Tarihi'></th>
                  	<th style="text-align:center; width:20px"></th>
             	</tr>
        	</thead>
        	<tbody>
            	<cfif get_count_row.recordcount>
                	<cfoutput query="get_count_row">
                    	<tr>
                        	<td style="text-align:right">#currentrow#</td>
                            <td style="text-align:center">#BARCODE#</td>
                            <cfif attributes.type eq 1>
                            	<td style="text-align:center">#PRODUCT_NAME#</td>
                            </cfif>
                            <td style="text-align:left"><div id="kontrol_emp_area#currentrow#"><cfif len(CONTROL_EMP)>#get_emp_info(CONTROL_EMP,0,0)#</cfif></div></td>
                            <td style="text-align:center"><div id="kontrol_date_area#currentrow#">#DateFormat(CONTROL_DATE,dateformat_style)#</div></td>
                            <td style="text-align:center">
                            	<div id="kontrol_area#currentrow#">	
                            	<cfif IS_CONTROL eq 1>
									<cfif attributes.type eq 1>
                                        <cfif not get_count.IS_PALETTE_CONTENT_SAVE eq 1 or (get_count.IS_PALETTE_CONTENT_SAVE eq 1 and not len(PALET_BARCODE))>
                                            <a style="cursor:pointer" onclick="connectAjax_2(#ROW_ID#,1,#currentrow#);">
                                                <i class="fa fa-minus" title="<cf_get_lang dictionary_id='29695.kaldır'>" alt="<cf_get_lang dictionary_id='29695.kaldır'>"></i>
                                            </a> 
                                        </cfif>
                                    <cfelse>
                                    	<a style="cursor:pointer" onclick="connectAjax_2(#ROW_ID#,2);">
                                         	<i class="fa fa-minus" title="<cf_get_lang dictionary_id='29695.kaldır'>" alt="<cf_get_lang dictionary_id='29695.kaldır'>"></i>
                                    	</a>
                                    </cfif>
                                </cfif>
                                </div>
                            </td>
                        </tr>
                    </cfoutput>
                </cfif>
           	</tbody>
    </cf_grid_list>
</cf_basket>
<script type="text/javascript">
	function connectAjax_2(row_id,type,currentrow)
	{
		document.getElementById('kontrol_area'+currentrow).style.display='none';
		document.getElementById('kontrol_date_area'+currentrow).style.display='none';
		document.getElementById('kontrol_emp_area'+currentrow).style.display='none';
		var cc = '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_perioad_based_count_del_operations&count_id=#attributes.count_id#</cfoutput>&row_id='+row_id+'&type='+type;
		AjaxPageLoad(cc,'kontrol_area',1);
	}
</script>