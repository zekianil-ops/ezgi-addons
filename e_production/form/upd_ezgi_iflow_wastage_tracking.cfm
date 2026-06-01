<!---
    File: upd_ezgi_iflow_wastage_tracking.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/05/2023
    Description:
--->
<cfquery name="get_reason" datasource="#dsn3#">
	SELECT 
    	LOST_REASON_ID, 
        LOST_REASON_NAME, 
        LOST_REASON_TYPE
	FROM     
    	EZGI_VTS_LOST_REASON
	ORDER BY 
    	LOST_REASON_NAME 
</cfquery>
<cfquery name="get_upd" datasource="#dsn3#">
	SELECT 
    	OT.OPERATION_TYPE,
    	S.PRODUCT_NAME,
        S.PRODUCT_CODE,
        S.STOCK_ID,
        S.PRODUCT_ID,
        PO.P_ORDER_NO,
        PO.LOT_NO,
        EW.P_ORDER_ID, 
        EW.P_OPERATION_ID, 
        EW.STATION_ID, 
        EW.EMPLOYEE_IDS, 
        EW.WASTAGE_DATE, 
        EW.DETAIL, 
        EW.REASON_ID, 
        EW.IS_DEMAND, 
        EW.STATUS, 
        EW.WASTAGE_NO, 
        EW.WASTAGE_STAGE, 
        EW.TRACE_NO, 
        EW.WASTAGE_AMOUNT, 
        EW.PROJECT_ID, 
        EW.RECORD_DATE, 
        EW.RECORD_EMP, 
        EW.RECORD_IP, 
        EW.UPDATE_DATE, 
        EW.UPDATE_EMP, 
        EW.UPDATE_IP,
        ISNULL((SELECT SUM(QUANTITY) AS QUANTITY FROM EZGI_PRODUCTION_DEMAND_ROW WHERE PRODUCTION_WASTAGE_ID = EW.PRODUCTION_WASTAGE_ID),0) AS PRODUCTION_DEMAND_QUANTITY
	FROM     
    	EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE EW,
        PRODUCTION_ORDERS PO,
        STOCKS S,
        PRODUCTION_OPERATION POR,
        OPERATION_TYPES OT
	WHERE  
    	PO.P_ORDER_ID = EW.P_ORDER_ID AND
        PO.STOCK_ID = S.STOCK_ID AND
        EW.P_OPERATION_ID = POR.P_OPERATION_ID AND
        POR.OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID AND
    	EW.PRODUCTION_WASTAGE_ID = #attributes.wastage_tracking_id#
</cfquery>
<cfquery name="get_upd_row" datasource="#dsn3#">
	SELECT 
    	PRODUCTION_WASTAGE_ROW_ID, 
        STOCK_ID, 
        PRODUCT_ID, 
        MAIN_SPECT_ID, 
        AMOUNT, 
        WRK_ROW_ID, 
        PRODUCT_UNIT_ID, 
        POR_STOCK_ID,
        ISNULL((SELECT SUM(QUANTITY) AS QUANTITY FROM INTERNALDEMAND_ROW WHERE WRK_ROW_RELATION_ID = EWR.WRK_ROW_ID),0) AS DEMAND_QUANTITY
	FROM     
    	EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE_ROW EWR
	WHERE  
    	PRODUCTION_WASTAGE_ID = #attributes.wastage_tracking_id#
</cfquery>
<cfoutput query="get_upd_row">
	<cfset 'AMOUNT_#POR_STOCK_ID#' = AMOUNT>
    <cfset 'DEMAND_QUANTITY_#POR_STOCK_ID#' = DEMAND_QUANTITY>
</cfoutput>
<cfquery name="get_upd_row_kontrol" dbtype="query">
	SELECT * FROM get_upd_row WHERE DEMAND_QUANTITY >1
</cfquery>
<cfif Listlen(get_upd.EMPLOYEE_IDS)>
    <cfquery name="get_employee" datasource="#dsn#">
        SELECT 
            EMPLOYEE_ID, 
            EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ADI
        FROM     
            EMPLOYEES
        WHERE  
            EMPLOYEE_ID IN (#get_upd.EMPLOYEE_IDS#)
    </cfquery>
</cfif>
<cfquery name="GET_LOST_ROW" datasource="#dsn3#">
	SELECT 
    	POS.AMOUNT/PO.QUANTITY AS AMOUNT, 
        POS.POR_STOCK_ID,
    	POS.PRODUCT_ID, 
        POS.STOCK_ID, 
        POS.SPECT_MAIN_ID, 
        POS.PRODUCT_UNIT_ID, 
        PU.MAIN_UNIT,
        S.PRODUCT_NAME, 
        S.PRODUCT_CODE, 
        S.IS_PRODUCTION
	FROM     
    	PRODUCTION_ORDERS_STOCKS AS POS INNER JOIN
        STOCKS AS S ON POS.STOCK_ID = S.STOCK_ID  INNER JOIN
      	PRODUCT_UNIT AS PU ON POS.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID  INNER JOIN
      	PRODUCTION_ORDERS AS PO ON POS.P_ORDER_ID = PO.P_ORDER_ID
	WHERE  
    	POS.P_ORDER_ID = #GET_UPD.P_ORDER_ID# AND 
        ISNULL(S.IS_ADD_XML, 0) = 0 AND 
        POS.TYPE = 2
</cfquery>
<cfif get_upd.PRODUCTION_DEMAND_QUANTITY neq 0 or get_upd_row_kontrol.RECORDCOUNT>
	<cfset del_kontrol = 1>
<cfelse>	
	<cfset del_kontrol = 0>
</cfif>
<cfif get_upd_row.recordcount>
	<cfset recordnum = get_upd_row.recordcount>
<cfelse>
	<cfset recordnum = 0>
</cfif>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
    	<cfform name="upd_wastage_tracking" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_iflow_wastage_tracking">
          	<cfinput type="hidden" name="wastage_tracking_id" value="#attributes.wastage_tracking_id#">
            <cf_basket_form id="upd_wastage_tracking">
                <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
                                	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                                        <div class="form-group" id="item-status">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                                            <div class="col col-8 col-xs-12">
                                                <input type="checkbox" id="status" name="status" value="1" <cfif get_upd.STATUS>checked</cfif>>
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-paper_no">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57880.Belge No'> *</label>
                                            <div class="col col-8 col-xs-12">
                                                <cfinput type="text" name="paper_no" id="paper_no" readonly="yes" value="#get_upd.WASTAGE_NO#" maxlength="20">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-process_date">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57073.Belge Tarihi'> *</label>
                                            <div class="col col-8 col-xs-12">
                                                <cfinput type="text" name="process_date" id="process_date" readonly="yes" value="#DateFormat(get_upd.WASTAGE_DATE,dateformat_style)#" maxlength="20">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-process_stage">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58859.Süreç'> *</label>
                                            <div class="col col-8 col-xs-12">
                                            	<cf_workcube_process is_upd='0' select_value='#get_upd.WASTAGE_STAGE#' process_cat_width='125' is_detail='1'>
                                            </div>
                                        </div>
                                  	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                                        <div class="form-group" id="item-product_code">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58800.Ürün Kodu'> *</label>
                                            <div class="col col-8 col-xs-12">
                                                <cfinput type="text" name="product_code" id="product_code" readonly="yes" value="#get_upd.PRODUCT_CODE#" >
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-product_name">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58221.Ürün Adı'> *</label>
                                            <div class="col col-8 col-xs-12">
                                           		<cfinput type="text" name="product_name" id="product_name" value="#get_upd.PRODUCT_NAME#" readonly="yes">
                                            </div>
                                        </div>
                                      	<div class="form-group" id="item-reason_name">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='320.Fire Sebebi'> *</label>
                                            <div class="col col-8 col-xs-12">
                                            	<select name="reason_id" style="width:150px; height:20px">
													<cfoutput query="get_reason">
                                                        <option value="#LOST_REASON_ID#"<cfif get_upd.reason_id eq get_reason.LOST_REASON_ID>selected</cfif>>#get_reason.LOST_REASON_NAME#</option>
                                                    </cfoutput>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-wastage_amount">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='137.Fire Miktarı'> *</label>
                                            <div class="col col-8 col-xs-12">
                                            	 <cfinput type="text" name="wastage_amount" id="wastage_amount" value="#TlFormat(get_upd.wastage_amount,2)#">
                                            </div>
                                        </div>
                                  	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                                    	<div class="form-group" id="item-lotno">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='45498.Lot No'> *</label>
                                            <div class="col col-8 col-xs-12">
                                                <cfinput type="text" name="lot_no" id="lot_no" readonly="yes" value="#get_upd.LOT_NO#" maxlength="20">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-porderno">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='45276.Üretim Emir No'> *</label>
                                            <div class="col col-8 col-xs-12">
                                                <cfinput type="text" name="p_order_no" id="p_order_no" readonly="yes" value="#get_upd.p_order_no#" maxlength="20">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-operation">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29419.Operasyon'> *</label>
                                            <div class="col col-8 col-xs-12">
                                                <cfinput type="text" name="operation" id="operation" readonly="yes" value="#get_upd.OPERATION_TYPE#" maxlength="20">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-production_amount">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36388.Üretim Talebi'> </label>
                                            <div class="col col-8 col-xs-12">
                                        		<cfif not get_upd.IS_DEMAND>
                                                    <cfinput type="text" name="production_amount" id="production_amount" style="color:red" value="Üretim Talebi Yapılmayacak" readonly="">
                                               	<cfelse>
                                                	<cfinput type="text" name="production_amount" id="production_amount" value="#TlFormat(get_upd.PRODUCTION_DEMAND_QUANTITY,2)#" readonly="">
                                            	</cfif>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                                    	<div class="form-group" id="item-detail">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                                            <div class="col col-8 col-xs-12">
                                                <textarea name="detail" id="detail" style="height:60px"><cfoutput>#get_upd.DETAIL#</cfoutput></textarea>
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-operastors">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58875.Çalışanlar'> *</label>
                                            <div class="col col-8 col-xs-12">
                                            	<table style="width:100%; height:100%" cellspacing="0" cellpadding="0">
                                            		<cfif Listlen(get_upd.EMPLOYEE_IDS)>
														<cfoutput query="get_employee">
                                                        	<tr>
                                                            	<td style="text-align:right; width:20px">#get_employee.CURRENTROW#-</td>
                                                            	<td>#get_employee.ADI#</td>
                                                            </tr>
                                                        </cfoutput>
                                                    </cfif>
                                            	</table>
                                            </div>
                                        </div>
                                    </div>
                              	</cf_box_elements>
                    			<cf_box_footer>
                                	<cf_record_info 
                                        query_name="get_upd"
                                        record_emp="RECORD_EMP" 
                                        record_date="record_date"
                                        update_emp="UPDATE_EMP"
                                        update_date="update_date">
                                        
									<cfif del_kontrol eq 0>
                                        <cf_workcube_buttons 
                                            is_upd='1' 
                                            add_function='kontrol()'
                                            del_function_for_submit='del_kontrol()'>
                                    </cfif>
                				</cf_box_footer>
                			</div>
            			</div>
        		</div>
    		</cf_basket_form>
            <cf_basket id="upd_default_piece_bask">
            	<cf_grid_list sort="0">
                	<thead>
                     	<tr>
                        	<th width="40px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        	<th width="150px"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                            <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                         	<th width="150px"><cf_get_lang dictionary_id='40186.Üretim Sarf Miktar'></th>
                            <th width="40px"><cf_get_lang dictionary_id='57636.Birim'></th>
                            <th width="150px"><cf_get_lang dictionary_id='137.Fire Miktarı'></th>
                            <th width="150px"><cf_get_lang dictionary_id='1032.Verilen İç Talep Miktarı'></th>
                       	</tr>
                  	</thead>
                    <tbody name="new_row" id="new_row">
                   		<cfif GET_LOST_ROW.recordcount>
                       		<cfoutput query="GET_LOST_ROW">
                             	<tr name="frm_row#currentrow#" id="frm_row#currentrow#" <cfif isdefined('AMOUNT_#POR_STOCK_ID#')>style="font-weight:bold"</cfif>>
                                 	<td style="text-align:right">#currentrow#</td>
                               		<td style="text-align:center">#PRODUCT_CODE#</td>
                                    <td style="text-align:left">#PRODUCT_NAME#</td>
                                 	<td style="text-align:right">#AmountFormat(AMOUNT*get_upd.wastage_amount,4)#</td>
                                    <td style="text-align:left">#MAIN_UNIT#</td>
                                    <td style="text-align:right">
                                    	<cfif isdefined('AMOUNT_#POR_STOCK_ID#')>
                                    		#AmountFormat(Evaluate('AMOUNT_#POR_STOCK_ID#'),4)#
                                    	<cfelse>
                                        	#AmountFormat(0,4)#
                                        </cfif>
                                    </td>
                                    <td style="text-align:right">
                                    	<cfif isdefined('DEMAND_QUANTITY_#POR_STOCK_ID#')>
                                    		#AmountFormat(Evaluate('DEMAND_QUANTITY_#POR_STOCK_ID#'),4)#
                                    	<cfelse>
                                        	#AmountFormat(0,4)#
                                        </cfif>
                                    </td>
                             	</tr>
                          	</cfoutput>
                   		</cfif>
                 	</tbody>
               	</cf_grid_list>
            </cf_basket>
 		</cfform>
   	</cf_box>
</div>
<script type="text/javascript">
	function kontrol()
	{
		if(process_cat_control())
			return true;
		else
			return false;
	}
	function del_kontrol()
	{
		window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_iflow_wastage_tracking&wastage_tracking_id=#attributes.wastage_tracking_id#</cfoutput>";
		return true;
	}
</script>