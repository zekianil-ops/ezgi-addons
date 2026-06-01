<!---
    File: add_ezgi_package_inquiry_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Paket Sorgulama
---> 
<cfparam name="attributes.add_other_barcod" default="">
<cfif isdefined('attributes.is_submitted')>
	<cfquery name="get_serial" datasource="#dsn3#">
    	SELECT 
        	E.SERIAL_NO, 
            E.STOCK_ID, 
            E.DEPARTMENT_ID, 
            E.LOCATION_ID, 
            E.PRODUCT_PLACE_ID, 
            E.PACKING_ID, 
            E.DEPO, 
            E.SPECT_ID, 
            E.PALET_BARCODE, 
            E.PRODUCT_NAME, 
            E.IS_PROTOTYPE, 
            E.SHELF_CODE,
            ISNULL(E.IS_SHIPMENT_VERIFACTION,0) IS_SHIPMENT_VERIFACTION, 
            W.DEPO_NAME, 
            ISNULL(E.SHIP_RESULT_ID,0) SHIP_RESULT_ID,
            O.ORDER_ID, 
        	O.ORDER_NUMBER
      	FROM 
       		ORDERS AS O INNER JOIN
          	ORDER_ROW AS ORR ON O.ORDER_ID = ORR.ORDER_ID RIGHT OUTER JOIN
          	EZGI_WM_SERIAL_NO_LAST_STATUS AS E WITH (NOLOCK) INNER JOIN
       		EZGI_WM_DEPARTMENTS AS W WITH (NOLOCK) ON E.DEPO = W.DEPO LEFT OUTER JOIN
       		EZGI_WM_ORDER_LAST_STATUS AS ES ON ES.SERIAL_NO = E.SERIAL_NO ON ORR.ORDER_ROW_ID = ES.ORDER_ROW_ID
      	WHERE 
        	E.SERIAL_NO = '#attributes.add_other_barcod#'
    </cfquery>
    <cfif get_serial.recordcount>
        <cfquery name="get_serial_row" datasource="#dsn3#">
            SELECT 
                CASE
                    WHEN 
                        E.SHIP_RESULT_TYPE = 1
                    THEN
                        (SELECT DELIVER_PAPER_NO FROM EZGI_SHIP_RESULT WHERE SHIP_RESULT_ID = E.SHIP_RESULT_ID)
                    ELSE
                        CAST(E.SHIP_RESULT_ID AS varchar)
                END AS DELIVER_PAPER_NO,
                E.TYPE, 
                E.PROCESS_DATE, 
                E.PROCESS_CAT, 
                E.PROCESS_ID, 
                E.SERIAL_NO, 
                E.DEPARTMENT_ID, 
                E.LOCATION_ID, 
                E.OUT_DEPARTMENT_ID, 
                E.OUT_LOCATION_ID, 
                E.PRODUCT_PLACE_ID, 
                E.OUT_PRODUCT_PLACE_ID, 
                E.PACKING_ID, 
                E.RECORD_EMP, 
                E.RECORD_IP, 
                E.SHIP_RESULT_ID, 
                E.SHIP_RESULT_TYPE, 
                E.IS_SHIPMENT_VERIFACTION,
                (SELECT DEPO_NAME FROM EZGI_WM_DEPARTMENTS WHERE DEPARTMENT_ID = E.DEPARTMENT_ID AND LOCATION_ID = E.LOCATION_ID) AS DEPO,
                0 AS SALE_COMPANY_ID, 
                0 AS SALE_CONSUMER_ID
            FROM     
                EZGI_WM_SERIAL_NO_ALL_ACTION E WITH (NOLOCK)
            WHERE  
                E.SERIAL_NO = '#attributes.add_other_barcod#'
            UNION ALL
            SELECT 
                '' AS DELIVER_PAPER_NO,
                0 AS TYPE, 
                RECORD_DATE AS PROCESS_DATE, 
                PROCESS_CAT, 
                PROCESS_ID, 
                SERIAL_NO, 
                DEPARTMENT_ID, 
                LOCATION_ID, 
                0 AS OUT_DEPARTMENT_ID, 
                0 AS OUT_LOCATION_ID, 
                0 AS PRODUCT_PLACE_ID, 
                0 AS OUT_PRODUCT_PLACE_ID, 
                0 AS PACKING_ID, 
                RECORD_EMP, 
                RECORD_IP, 
                0 AS SHIP_RESULT_ID, 
                0 AS SHIP_RESULT_TYPE, 
                0 AS IS_SHIPMENT_VERIFACTION, 
                PROCESS_NO AS DEPO,
                SALE_COMPANY_ID, 
                SALE_CONSUMER_ID
            FROM     
                SERVICE_GUARANTY_NEW WITH (NOLOCK)
            WHERE  
                SERIAL_NO = '#attributes.add_other_barcod#' AND 
                (IN_OUT = 0 OR IS_SALE = 1)
            ORDER BY 
                PROCESS_DATE
        </cfquery>
   	<cfelse>
    	<cfquery name="get_serial" datasource="#dsn3#">
            SELECT 
                E.SERIAL_NO, 
                E.STOCK_ID, 
                E.DEPARTMENT_ID, 
                E.LOCATION_ID, 
                E.PRODUCT_PLACE_ID, 
                E.PACKING_ID, 
                E.DEPO, 
                E.SPECT_ID, 
                E.PALET_BARCODE, 
                E.PRODUCT_NAME, 
                E.IS_PROTOTYPE, 
                E.SHELF_CODE,
                ISNULL(E.IS_SHIPMENT_VERIFACTION,0) IS_SHIPMENT_VERIFACTION, 
                W.DEPO_NAME, 
                ISNULL(E.SHIP_RESULT_ID,0) SHIP_RESULT_ID,
                O.ORDER_ID, 
                O.ORDER_NUMBER
            FROM 
                ORDERS AS O INNER JOIN
                ORDER_ROW AS ORR ON O.ORDER_ID = ORR.ORDER_ID RIGHT OUTER JOIN
                EZGI_WM_SERIAL_NO_LAST_STATUS_TEMP AS E WITH (NOLOCK) LEFT OUTER JOIN
                EZGI_WM_DEPARTMENTS AS W WITH (NOLOCK) ON E.DEPO = W.DEPO LEFT OUTER JOIN
                EZGI_WM_ORDER_LAST_STATUS_TEMP AS ES ON ES.SERIAL_NO = E.SERIAL_NO ON ORR.ORDER_ROW_ID = ES.ORDER_ROW_ID
            WHERE 
                E.SERIAL_NO = '#attributes.add_other_barcod#'
        </cfquery>
        <cfif get_serial.recordcount>
        	<cfset arsiv = 1>
            <cfquery name="get_serial_row" datasource="#dsn3#">
                SELECT 
                    CASE
                        WHEN 
                            E.SHIP_RESULT_TYPE = 1
                        THEN
                            (SELECT DELIVER_PAPER_NO FROM EZGI_SHIP_RESULT WHERE SHIP_RESULT_ID = E.SHIP_RESULT_ID)
                        ELSE
                            CAST(E.SHIP_RESULT_ID AS varchar)
                    END AS DELIVER_PAPER_NO,
                    E.TYPE, 
                    E.PROCESS_DATE, 
                    E.PROCESS_CAT, 
                    E.PROCESS_ID, 
                    E.SERIAL_NO, 
                    E.DEPARTMENT_ID, 
                    E.LOCATION_ID, 
                    E.OUT_DEPARTMENT_ID, 
                    E.OUT_LOCATION_ID, 
                    E.PRODUCT_PLACE_ID, 
                    E.OUT_PRODUCT_PLACE_ID, 
                    E.PACKING_ID, 
                    E.RECORD_EMP, 
                    E.RECORD_IP, 
                    E.SHIP_RESULT_ID, 
                    E.SHIP_RESULT_TYPE, 
                    E.IS_SHIPMENT_VERIFACTION,
                    (SELECT DEPO_NAME FROM EZGI_WM_DEPARTMENTS WHERE DEPARTMENT_ID = E.DEPARTMENT_ID AND LOCATION_ID = E.LOCATION_ID) AS DEPO,
                    0 AS SALE_COMPANY_ID, 
                    0 AS SALE_CONSUMER_ID
                FROM     
                    EZGI_WM_SERIAL_NO_ALL_ACTION_TEMP E WITH (NOLOCK)
                WHERE  
                    E.SERIAL_NO = '#attributes.add_other_barcod#' AND
                    ISNULL(E.PROCESS_CAT,0) <> 71
                UNION ALL
                SELECT 
                    '' AS DELIVER_PAPER_NO,
                    0 AS TYPE, 
                    RECORD_DATE AS PROCESS_DATE, 
                    PROCESS_CAT, 
                    PROCESS_ID, 
                    SERIAL_NO, 
                    DEPARTMENT_ID, 
                    LOCATION_ID, 
                    0 AS OUT_DEPARTMENT_ID, 
                    0 AS OUT_LOCATION_ID, 
                    0 AS PRODUCT_PLACE_ID, 
                    0 AS OUT_PRODUCT_PLACE_ID, 
                    0 AS PACKING_ID, 
                    RECORD_EMP, 
                    RECORD_IP, 
                    0 AS SHIP_RESULT_ID, 
                    0 AS SHIP_RESULT_TYPE, 
                    0 AS IS_SHIPMENT_VERIFACTION, 
                    PROCESS_NO AS DEPO,
                    SALE_COMPANY_ID, 
                    SALE_CONSUMER_ID
                FROM     
                    SERVICE_GUARANTY_NEW_TEMP WITH (NOLOCK)
                WHERE  
                    SERIAL_NO = '#attributes.add_other_barcod#' AND 
                    (IN_OUT = 0 OR IS_SALE = 1)
                ORDER BY 
                    PROCESS_DATE
            </cfquery>
        <cfelse>
        	<script type="text/javascript">
				alert("Seri No Bulunamadı!");
			</script>
        </cfif>
    </cfif>
    <cfset place_id_list = ListDeleteDuplicates(Valuelist(get_serial_row.PRODUCT_PLACE_ID),',')>
    <cfset packing_id_list = ListDeleteDuplicates(Valuelist(get_serial_row.PACKING_ID),',')>
    <cfif ListLen(place_id_list)>
    	<cfquery name="get_product_place" datasource="#dsn3#">
        	SELECT 
            	PRODUCT_PLACE_ID, 
                SHELF_CODE
			FROM     
            	EZGI_PRODUCT_PLACE WITH (NOLOCK)
			WHERE  
            	PRODUCT_PLACE_ID IN (#place_id_list#)
        </cfquery>
        <cfoutput query="get_product_place">
        	<cfset 'SHELF_CODE_#PRODUCT_PLACE_ID#' = SHELF_CODE>
        </cfoutput>
    </cfif>
    <cfif ListLen(packing_id_list)>
    	<cfquery name="get_packing" datasource="#dsn3#">
        	SELECT 
            	PACKING_ID, 
                BARCODE
			FROM   
            	EZGI_PACKING WITH (NOLOCK)
			WHERE  
            	PACKING_ID IN (#packing_id_list#)
        </cfquery>
        <cfoutput query="get_packing">
        	<cfset 'BARCODE_#PACKING_ID#' = BARCODE>
        </cfoutput>
    </cfif>
    <cfquery name="Get_Trace" datasource="#dsn3#">
    	SELECT 
        	SERIAL_NO, 
            LOT_NO, 
            REFERENCE_NO,
            (SELECT P_ORDER_ID FROM PRODUCTION_ORDER_RESULTS WHERE PR_ORDER_ID = S.PROCESS_ID) AS P_ORDER_ID
      	FROM 
        	SERVICE_GUARANTY_NEW S WITH (NOLOCK)
      	WHERE 
        	PROCESS_CAT = 171 AND 
            SERIAL_NO = '#attributes.add_other_barcod#'
    </cfquery>
    <cfif Get_Trace.recordcount and len(Get_Trace.REFERENCE_NO)>
    	<cfquery name="Get_Quality" datasource="#dsn3#">
    		SELECT 
            	POR.OPERATION_RESULT_ID, 
                POR.OPERATION_ID, 
                POR.ACTION_EMPLOYEE_ID, 
                POR.TRACE_NO, 
                ORQ.OR_Q_ID
			FROM     
            	PRODUCTION_OPERATION_RESULT AS POR WITH (NOLOCK) INNER JOIN
                ORDER_RESULT_QUALITY AS ORQ WITH (NOLOCK) ON POR.OPERATION_RESULT_ID = ORQ.PROCESS_RESULT_ROW_ID INNER JOIN
                PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON POR.P_ORDER_ID = PO.P_ORDER_ID
			WHERE  
                POR.TRACE_NO = '#Get_Trace.REFERENCE_NO#'
		</cfquery>
   	<cfelse>
    	<cfset Get_Quality.recordcount=0> 
    </cfif> 
<cfelse>
	<cfset get_serial_row.recordcount =0>
    <cfset Get_Quality.recordcount=0> 
    <cfset Get_Trace.recordcount=0> 
</cfif> 
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
      	<cfform name="add_ezgi_package_inquiry_warehouse" id="add_ezgi_package_inquiry_warehouse" action="" method="post">
        	<input name="is_submitted" type="hidden" value="1">	
            <cf_basket_form id="add_ezgi_package_transfer">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
                         	<cf_box_elements>
                            	<div class="col col-12 uniqueRow" id="first_area">
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><b><cf_get_lang dictionary_id='57637.Seri No'></b></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group" id="item-barcod">
                                                <input id="add_other_barcod" name="add_other_barcod" type="text" value="">
                                            </div>
                                        </div>
                                    </div>
                               	</div>
                                <cfif isdefined('attributes.is_submitted')>
                                <div class="col col-12" id="second_area">
  
                                    <div class="col col-12">
                                        <div class="col col-8">
											<label><b><cf_get_lang dictionary_id='58221.Ürün Adı'></b></label>
                                        </div>
                                        <div class="col col-4">
                                            <label><b><cf_get_lang dictionary_id='63519.Sipariş Rezerve Edilen'></b></label>
                                        </div>
                                    </div>
                                    <div class="col col-12">
                                        
                                        <div class="col col-8">
                                            <div class="form-group" id="item-cikis_depo">
                                          		<cfinput type="text" name="txt_product_name" id="txt_product_name" value="#get_serial.PRODUCT_NAME#">
                                        	</div>
                                        </div>
                                        <div class="col col-4">
                                            <div class="form-group" id="item-cikis_depo">
                                          		<cfinput type="text" name="txt_rezerve" id="txt_rezerve" value="#get_serial..ORDER_NUMBER#">
                                        	</div>
                                        </div>
                                    </div>
                                    <div class="col col-12">
                                        <div class="col col-4">
											<b><label><cf_get_lang dictionary_id='37244.Palet'></label></b>
                                        </div>
                                        <div class="col col-4">
                                           <b><label><cf_get_lang dictionary_id='45667.Raf'></label> </b>
                                        </div>
                                        <div class="col col-4">
                                            <b><label><cf_get_lang dictionary_id='58763.Depo'></label></b>
                                        </div>
                                    </div>
                                    <div class="col col-12">
                                        <div class="col col-4">
                                            <div class="form-group" id="item-cikis_raf">
                                            	<cfinput type="text" name="txt_shelf_out_name" id="txt_shelf_out_name" value="#get_serial.PALET_BARCODE#">
                                            </div>
                                        </div>
                                        <div class="col col-4">
                                            <div class="form-group" id="item-cikis_palet">
                                            	<cfinput type="text" name="txt_packing_out_name" id="txt_packing_out_name" value="#get_serial.SHELF_CODE#">
                                            </div>
                                        </div>
                                        <div class="col col-4">
                                        	<div class="form-group" id="item-cikis_depo">
                                          		<cfinput type="text" name="txt_department_out_name" id="txt_department_out_name" value="#get_serial.DEPO_NAME#">
                                        	</div>
                                        </div>
                                    </div>
                                    
                              	</div>
                                </cfif>
               				</cf_box_elements>
                    		<cf_box_footer>
                            	<div class="col col-12">
                                    <div class="col col-6" style="text-align:right">
                                    	<cfif isdefined('arsiv')>
                                        	<span style="font-weight:bold;color:red"><cf_get_lang dictionary_id="64311.Arşiv"></span>
                                        </cfif>
                               		</div>
                                    <div class="col col-6" style="text-align:right;" id="onay_div">
                                        
                                 	</div>
                              	</div>
              				</cf_box_footer>
                       	</div>
                  	</div>
              	</div>
    		</cf_basket_form>
            <cfsavecontent variable="title">
            	<cf_get_lang dictionary_id="57919.Hareketler"> : 
				<cfoutput>
                	#attributes.add_other_barcod#
					<cfif Get_Trace.recordcount and len(Get_Trace.LOT_NO)>
						- #Get_Trace.LOT_NO#
					</cfif>
                    <cfif Get_Trace.recordcount and len(Get_Trace.REFERENCE_NO)>
						- #Get_Trace.REFERENCE_NO#
					</cfif>
				</cfoutput>
			</cfsavecontent>
            <cfsavecontent variable="right_menu">
            	
                <cfif Get_Trace.recordcount and len(Get_Trace.P_ORDER_ID)>
					<cfif len(Get_Trace.REFERENCE_NO)>
                        <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_ezgi_print_files&print_type=280&iid=#Get_Trace.REFERENCE_NO#&action_id=#Get_Trace.P_ORDER_ID#</cfoutput>','wide');">
                     		 <img src="images/print.gif" title="<cf_get_lang dictionary_id="57474.Yazdır">">
                     	</a>
                    <cfelse>
                     	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_ezgi_print_files&print_type=280&iid=#attributes.add_other_barcod#&action_id=#Get_Trace.P_ORDER_ID#</cfoutput>','wide');">

                     		 <img src="images/print.gif" title="<cf_get_lang dictionary_id="57474.Yazdır">">
                     	</a>
                    </cfif>
                    &nbsp;
             	</cfif>
            	<cfif Get_Quality.recordcount and len(Get_Quality.OR_Q_ID)>
                    <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=stock.list_quality_controls&event=upd&or_q_id=#Get_Quality.OR_Q_ID#</cfoutput>','wide');">
                        <img src="images/quiz_paper.gif" title="<cf_get_lang dictionary_id="45359.Kalite Kontrol">">
                    </a>&nbsp;
                </cfif>
            </cfsavecontent>
        	<cf_box title="#title#" right_images="#right_menu#">
            	<cf_grid_list>
                   	<thead>
                       	<tr>
                        	<th><cf_get_lang dictionary_id="58577.Sıra"></th>
                            <th><cf_get_lang dictionary_id="57742.Tarih"></th>
                            <th><cf_get_lang dictionary_id="37244.Palet"></th>
                            <th><cf_get_lang dictionary_id="45667.Raf"></th>
                            <th><cf_get_lang dictionary_id="48190.Sevk No"></th>
                        	<th><cf_get_lang dictionary_id="58763.Depo"></th>
                     	</tr>
                 	</thead>
                 	<tbody name="table1" id="table1">
                    	<cfif get_serial_row.recordcount>
							<cfoutput query="get_serial_row">
                            	<cfif TYPE eq 0>
                                	<tr>
                                        <td style="text-align:center;color:red">#currentrow#</td>
                                        <td style="text-align:center;color:red">#DateFormat(PROCESS_DATE,dateformat_style)#</td>
                                        <td style="text-align:center;color:red" colspan="2">
                                        	<cfif len(SALE_COMPANY_ID)> 
												#get_par_info(SALE_COMPANY_ID,1,1,0)#
											<cfelseif len(SALE_CONSUMER_ID)>
                                                #get_cons_info(SALE_CONSUMER_ID,0,0)#
                                            </cfif>
                                        </td>
                                        <td></td>
                                        <td style="text-align:left;color:red">#DEPO#</td>
                                    </tr>
                                <cfelse>
                                    <tr>
                                        <td style="text-align:center">#currentrow#</td>
                                        <td style="text-align:center">#DateFormat(PROCESS_DATE,dateformat_style)#</td>
                                        <td style="text-align:center"><cfif isdefined('BARCODE_#PACKING_ID#')>#Evaluate('BARCODE_#PACKING_ID#')#</cfif></td>
                                        <td style="text-align:center"><cfif isdefined('SHELF_CODE_#PRODUCT_PLACE_ID#')>#Evaluate('SHELF_CODE_#PRODUCT_PLACE_ID#')#</cfif></td>
                                        <td style="text-align:center">#DELIVER_PAPER_NO#</td>
                                        <td style="text-align:left">#DEPO#</td>
                                    </tr>
                                </cfif>
                            </cfoutput>
                        </cfif>
                    </tbody>
           		</cf_grid_list>
          	</cf_box>
      	</cfform>
   	</cf_box>
</div>
<script language="javascript" type="text/javascript">
	document.getElementById('add_other_barcod').focus();
	setTimeout("document.getElementById('add_other_barcod').select();",1000);
	document.onkeydown = checkKeycode
	function checkKeycode(e) /*Barkod Okuyup Enter Basıldığında*/
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			document.getElementById("add_ezgi_package_inquiry_warehouse").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=stock.add_ezgi_package_inquiry_warehouse";
			document.getElementById("add_ezgi_package_inquiry_warehouse").submit();	
		}
	}
</script>