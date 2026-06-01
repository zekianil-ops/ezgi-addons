<!---
    File: upd_ezgi_shipping_internaldemand.cfm
    Folder: Add_Ons\ezgi\e_shipping\form
    Author: Ezgi Yazılım
    Date: 01/01/2017
    Description:
--->
<cf_xml_page_edit>
<cfset total_weight = 0>
<cfset total_volume = 0>
<cfquery name="get_general_info" datasource="#dsn#">
	SELECT ISNULL(IS_SERIAL_CONTROL_LOCATION,0) AS IS_SERIAL_CONTROL_LOCATION FROM OUR_COMPANY_INFO WHERE COMP_ID = #session.ep.company_id#
</cfquery>
<cfquery name="get_shippng_plan" datasource="#dsn3#">
	SELECT  
    	ISNULL(ESR.SHIPMENT_PROCESS,0) AS SHIPMENT_PROCESS,   
    	ESR.SHIP_RESULT_INTERNALDEMAND_ID, 
        ESR.DELIVER_EMP, 
        ESR.NOTE, 
        ESR.SHIP_RESULT_INTERNALDEMAND_ID AS DELIVER_PAPER_NO, 
        ESR.REFERENCE_NO, 
        ESR.OUT_DATE, 
        ESR.SHIP_METHOD_TYPE, 
        ESR.DELIVERY_DATE, 
        ESR.DEPARTMENT_ID, 
        ESR.LOCATION_ID,
        ESR.DEPARTMENT_IN_ID, 
        ESR.LOCATION_IN_ID,
        ESR.SHIP_STAGE, 
        ESR.IS_TYPE, 
        ESR.RECORD_EMP, 
        ESR.RECORD_DATE, 
        ESR.UPDATE_EMP, 
        ESR.UPDATE_DATE,
        SM.SHIP_METHOD,
        ISNULL(SH.SHIP_ID,0) AS SHIP_ID,
        SH.SHIP_NUMBER,
        ISNULL(SH.IS_DELIVERED,0) AS IS_DELIVERED
	FROM         
    	EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR LEFT OUTER JOIN
    	#dsn_alias#.SHIP_METHOD AS SM ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID LEFT JOIN
        #dsn2_alias#.SHIP AS SH ON SH.DISPATCH_SHIP_ID = ESR.SHIP_RESULT_INTERNALDEMAND_ID
	WHERE     
    	ESR.SHIP_RESULT_INTERNALDEMAND_ID  = #attributes.iid#
</cfquery>
<cfif get_shippng_plan.recordcount>
	<cfparam name="attributes.reference_no" default="#get_shippng_plan.REFERENCE_NO#">
    <cfparam name="attributes.ship_method_id" default="#get_shippng_plan.SHIP_METHOD_TYPE#">
    <cfparam name="attributes.ship_method_name" default="#get_shippng_plan.SHIP_METHOD#">
    
    <cfquery name="get_department" datasource="#dsn#">
		SELECT     
        	DEPARTMENT.DEPARTMENT_HEAD, 
            DEPARTMENT.BRANCH_ID, 
            DEPARTMENT.DEPARTMENT_ID, 
            STOCKS_LOCATION.LOCATION_ID, 
            STOCKS_LOCATION.COMMENT
		FROM         
    		DEPARTMENT INNER JOIN
        	STOCKS_LOCATION ON DEPARTMENT.DEPARTMENT_ID = STOCKS_LOCATION.DEPARTMENT_ID
  	  	WHERE     
        	DEPARTMENT.DEPARTMENT_ID = #get_shippng_plan.DEPARTMENT_ID# AND 
            STOCKS_LOCATION.LOCATION_ID = #get_shippng_plan.LOCATION_ID#    
	</cfquery>
    <cfparam name="attributes.branch_id" default="#get_department.BRANCH_ID#">
    <cfparam name="attributes.department_id" default="#get_department.DEPARTMENT_ID#">
    <cfparam name="attributes.location_id" default="#get_department.LOCATION_ID#">
    <cfparam name="attributes.department_name" default="#get_department.DEPARTMENT_HEAD#-#get_department.COMMENT#">
    
    <cfquery name="get_department_in" datasource="#dsn#">
		SELECT     
        	DEPARTMENT.DEPARTMENT_HEAD, 
            DEPARTMENT.BRANCH_ID, 
            DEPARTMENT.DEPARTMENT_ID, 
            STOCKS_LOCATION.LOCATION_ID, 
            STOCKS_LOCATION.COMMENT
		FROM         
    		DEPARTMENT INNER JOIN
        	STOCKS_LOCATION ON DEPARTMENT.DEPARTMENT_ID = STOCKS_LOCATION.DEPARTMENT_ID
  	  	WHERE     
        	DEPARTMENT.DEPARTMENT_ID = #get_shippng_plan.DEPARTMENT_IN_ID# AND 
            STOCKS_LOCATION.LOCATION_ID = #get_shippng_plan.LOCATION_IN_ID#    
	</cfquery>
    <cfparam name="attributes.branch_in_id" default="#get_department_in.BRANCH_ID#">
    <cfparam name="attributes.department_in_id" default="#get_department_in.DEPARTMENT_ID#">
    <cfparam name="attributes.location_in_id" default="#get_department_in.LOCATION_ID#">
    <cfparam name="attributes.department_in_name" default="#get_department_in.DEPARTMENT_HEAD#-#get_department_in.COMMENT#">
    
	<cfquery name="get_order_det" datasource="#DSN3#">
		SELECT
        	ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO, 
        	ISNULL(PU.WEIGHT,0) AS WEIGHT,
            ISNULL(PU.VOLUME,0) AS VOLUME,
			ORR.STOCK_ID,
            ORR.QUANTITY,
            ORR.ORDER_ROW_ID,
            ORD.IS_INSTALMENT,
            ORD.ORDER_ID,
            ORD.ORDER_HEAD, 
            ORD.ORDER_NUMBER,
            ORR.SPECT_VAR_ID,
            ORR.SPECT_VAR_NAME,
            ORR.PRODUCT_NAME2,
            S.PRODUCT_NAME,
            S.STOCK_CODE,
            S.STOCK_CODE_2,
            ISNULL(S.IS_KARMA,0) AS IS_KARMA,
            (
                SELECT     
                    SPECT_MAIN_ID
                FROM         
                    SPECTS
                WHERE     
                    SPECT_VAR_ID = ORR.SPECT_VAR_ID
            ) AS SPECT_MAIN_ID,
            ESRR.ORDER_ROW_AMOUNT,
            ESRR.SHIP_RESULT_INTERNALDEMAND_ID,
            ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID,
            ORR.ORDER_ROW_CURRENCY
		FROM         
        	ORDER_ROW AS ORR INNER JOIN
            ORDERS AS ORD ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
            STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ORR.ORDER_ROW_ID = ESRR.ORDER_ROW_ID INNER JOIN
            PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
		WHERE     
        	ESRR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.iid#
      	ORDER BY
        	ORR.ORDER_ROW_ID
	</cfquery>
    <cfif get_general_info.IS_SERIAL_CONTROL_LOCATION>
        <cfquery name="get_shipping_serial_control" datasource="#dsn3#">
            SELECT 
                EVM.IS_SHIPMENT_VERIFACTION, 
                EVM.SERIAL_NO, 
                EVM.PRODUCT_NAME
            FROM     
                ORDER_ROW AS ORR INNER JOIN
                EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESR ON ORR.ORDER_ROW_ID = ESR.ORDER_ROW_ID INNER JOIN
                EZGI_WM_SERIAL_NO_LAST_STATUS AS EVM ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = EVM.SHIP_RESULT_ID
            WHERE  
                EVM.SHIP_RESULT_TYPE = 2 AND 
                ORR.ORDER_ROW_CURRENCY = - 6 AND 
                ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.iid#
        </cfquery>
    <cfelse>
    	<cfset get_shipping_serial_control.recordcount = 0>
    </cfif>
    <cfset order_row_id_list = Valuelist(get_order_det.ORDER_ROW_ID)>
</cfif>
<cfsavecontent variable="title_"><cf_get_lang dictionary_id='375.Talep No'> : <cfoutput>#get_shippng_plan.DELIVER_PAPER_NO#</cfoutput></cfsavecontent>
<cfsavecontent variable="right_menu_">
	<cfif ListFind(session.ep.power_user_level_id,2178)>
	 	<a href="<cfoutput>#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_divide&ship_id=#attributes.iid#&is_type=2</cfoutput>" class="tableyazi"><img src="images/clinick.gif"  title="" border="0"></a>&nbsp;&nbsp;
        <cfif get_shippng_plan.SHIP_ID gt 0>
        	<cfoutput>
        		<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=stock.add_ship_dispatch&event=upd&ship_id=#get_shippng_plan.SHIP_ID#','longpage');" class="tableyazi"><img src="images/<cfif get_shippng_plan.IS_DELIVERED eq 0>branch_plus.gif<cfelse>branch_change.gif</cfif>"  title="#get_shippng_plan.SHIP_NUMBER#" border="0"></a>&nbsp;&nbsp;
            </cfoutput>
        </cfif>
  	</cfif>
</cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#title_#" right_images="#right_menu_#">
    	<cfform name="add_packet_ship" id="add_packet_ship" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_ezgi_shipping_internaldemand&iid=#attributes.iid#">
        	<cfinput type="hidden" name="today_value" id="today_value" value="#DateFormat(now(),dateformat_style)#">
        	<cfinput type="hidden" name="ship_result_internaldemand_id" value="#attributes.iid#">
            <cfif isdefined('order_row_id_list')>
            	<cfinput type="hidden" name="order_row_id_list" value="#order_row_id_list#">
            </cfif>
			<cfif len(get_shippng_plan.ship_method)>
				<input type="hidden" name="order_type" id="order_type" value="<cfoutput>#get_shippng_plan.ship_method#</cfoutput>">
			<cfelse>
				<input type="hidden" name="order_type" id="order_type" value="">
			</cfif>
            <cf_basket_form id="upd_default_measure">
                <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
            						<div class="col col-6 col-xs-12" type="column" index="1" sort="true">
                                    	<div class="form-group" id="item-stage">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58859.Süreç'>*</label>
	                            			<div class="col col-8 col-xs-12">
                                                <cf_workcube_process is_upd='0' select_value='#get_shippng_plan.SHIP_STAGE#' is_detail='1'>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-code">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29428.Çıkış Depo'>*</label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                            	<input type="hidden" name="branch_id" id="branch_id" value="<cfif isdefined("attributes.branch_id")><cfoutput>#attributes.branch_id#</cfoutput></cfif>">
                                                <input type="hidden" name="department_id" id="department_id" value="<cfif isdefined("attributes.department_id")><cfoutput>#attributes.department_id#</cfoutput></cfif>">
                                                <input type="hidden" name="location_id" id="location_id" value="<cfif isdefined("attributes.location_id")><cfoutput>#attributes.location_id#</cfoutput></cfif>">
                                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='45473.Yaptığınız İşleme Bağlı Olarak Depo Girmelisiniz'> !</cfsavecontent>
                                                <cfif isdefined("attributes.department_name")>
                                                    <cfinput type="text" name="department_name" id="department_name" value="#attributes.department_name#" passthrough="readonly=yes" message="#message#" style="width:170px;">
                                                <cfelse>
                                                    <cfinput type="text" name="department_name" id="department_name" value="" passthrough="readonly=yes" message="#message#" style="width:170px;">
                                                </cfif>
                                                <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_stores_locations&form_name=add_packet_ship&field_name=department_name&field_id=department_id&field_location_id=location_id&branch_id=branch_id','list')"></span>
                                				</div>
                                          	</div>
                                     	</div>
                                        
                                        <div class="form-group" id="item-sevk">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29500.Sevk Yöntemi'> *</label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                	<input type="hidden" name="ship_method_id" id="ship_method_id" value="<cfif isdefined("attributes.ship_method_id")><cfoutput>#attributes.ship_method_id#</cfoutput><cfelseif isdefined('get_ship_method')><cfoutput>#get_ship_method.ship_method_id#</cfoutput></cfif>">
													<input type="text" name="ship_method_name" id="ship_method_name" value="<cfif isdefined("attributes.ship_method_name")><cfoutput>#attributes.ship_method_name#</cfoutput><cfelseif isdefined('get_ship_method')><cfoutput>#get_ship_method.ship_method#</cfoutput></cfif>" readonly style="width:170px;">
                                                	<span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_ship_methods&field_name=add_packet_ship.ship_method_name&field_id=add_packet_ship.ship_method_id','medium');"></span>
                                				</div>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-detail">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
	                            			<div class="col col-8 col-xs-12">
                                             	<textarea name="note" id="note" style="height:60px"><cfoutput>#get_shippng_plan.NOTE#</cfoutput></textarea>
                                          	</div>
                                     	</div>

                                 	</div>
                                    <div class="col col-6 col-xs-12" type="column" index="2" sort="true">
                                        <div class="form-group" id="item-department">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58794.Referans No'></label>
	                            			<div class="col col-8 col-xs-12">
                                             	<input type="text" name="reference_no" id="reference_no" readonly="readonly" value="<cfoutput>#attributes.reference_no#</cfoutput>" maxlength="25" style="width:100px;">
                                          	</div>
                                     	</div>


                                        
                                        <div class="form-group" id="item-department-in">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='56969.Giriş Depo'>*</label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                            	<input type="hidden" name="branch_in_id" id="branch_in_id" value="<cfif isdefined("attributes.branch_in_id")><cfoutput>#attributes.branch_in_id#</cfoutput></cfif>">
                                                <input type="hidden" name="department_in_id" id="department_in_id" value="<cfif isdefined("attributes.department_in_id")><cfoutput>#attributes.department_in_id#</cfoutput></cfif>">
                                                <input type="hidden" name="location_in_id" id="location_in_id" value="<cfif isdefined("attributes.location_in_id")><cfoutput>#attributes.location_in_id#</cfoutput></cfif>">
                                                <cfsavecontent variable="message_in"><cf_get_lang dictionary_id='45473.Yaptığınız İşleme Bağlı Olarak Depo Girmelisiniz'> !</cfsavecontent>
                                                <cfif isdefined("attributes.department_in_name")>
                                                    <cfinput type="text" name="department_in_name" id="department_in_name" value="#attributes.department_in_name#" passthrough="readonly=yes" message="#message_in#" style="width:170px;">
                                                <cfelse>
                                                    <cfinput type="text" name="department_in_name" id="department_in_name" value="" passthrough="readonly=yes" message="#message_in#" style="width:170px;">
                                                </cfif>
                                                <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_stores_locations&form_name=add_packet_ship&field_name=department_in_name&field_id=department_in_id&field_location_id=location_in_id&branch_id=branch_in_id','list')"></span>
                                				</div>
                                          	</div>
                                     	</div>
                                        
                                        <div class="form-group" id="item-outdate">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='45463.Depo Çıkış Tarihi'></label>
	                            			<div class="col col-4 col-xs-12">
                                            	<div class="input-group">
                                             		<cfsavecontent variable="message"><cf_get_lang dictionary_id='45464.Depo Çıkış Tarihi Girmelisiniz'> !</cfsavecontent>
													<cfinput type="text" name="action_date" id="action_date" value="#dateformat(get_shippng_plan.OUT_DATE,'dd/mm/yyyy')#" validate="eurodate" required="Yes" message="#message#">
                                                	<span class="input-group-addon"><cf_wrk_date_image date_field="action_date"></span>
                                                </div>
                                          	</div>
                                            <div class="col col-2 col-xs-12">
                                            	<select name="start_h" id="start_h">
													<cfoutput>
                                                        <cfloop from="0" to="23" index="i">
                                                            <option value="#numberformat(i,00)#">#numberformat(i,00)#</option>
                                                        </cfloop>
                                                    </cfoutput>
                                                </select>
                                           	</div>
                                            <div class="col col-2 col-xs-12">
                                                <select name="start_m" id="start_m">
                                                    <cfoutput>
                                                        <cfloop from="0" to="59" index="i">
                                                            <option value="#numberformat(i,00)#">#numberformat(i,00)#</option>
                                                        </cfloop>
                                                    </cfoutput>
                                                </select>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-deliverdate">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57645.Teslim Tarihi'></label>
	                            			<div class="col col-4 col-xs-12">
                                            	<div class="input-group">
                                             		<cfsavecontent variable="message"><cf_get_lang dictionary_id='45647.Lütfen Teslim Tarihi Formatını Doğru Giriniz'>!</cfsavecontent>
													<cfinput type="text" name="deliver_date" id="deliver_date" value="#dateformat(get_shippng_plan.DELIVERY_DATE,'dd/mm/yyyy')#" validate="eurodate" style="width:65px;" message="#message#">
                                                	<span class="input-group-addon"><cf_wrk_date_image date_field="deliver_date"></span>
                                                </div>
                                          	</div>
                                            <div class="col col-2 col-xs-12">
                                            	<select name="deliver_h" id="deliver_h">
													<cfoutput>
                                                        <cfloop from="0" to="23" index="i">
                                                            <option value="#numberformat(i,00)#">#numberformat(i,00)#</option>
                                                        </cfloop>
                                                    </cfoutput>
                                                </select>
                                           	</div>
                                            <div class="col col-2 col-xs-12">
                                                <select name="deliver_m" id="deliver_m">
                                                    <cfoutput>
                                                        <cfloop from="0" to="59" index="i">
                                                            <option value="#numberformat(i,00)#">#numberformat(i,00)#</option>
                                                        </cfloop>
                                                    </cfoutput>
                                                </select>
                                          	</div>
                                     	</div>
                                    	<div class="form-group" id="item-deliveremp">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='276.Talep Eden'></label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                	<input type="hidden" name="deliver_id2" id="deliver_id2" value="<cfoutput>#get_shippng_plan.DELIVER_EMP#</cfoutput>">
													<input type="text" name="deliver_name2" id="deliver_name2" value="<cfoutput>#get_emp_info(get_shippng_plan.DELIVER_EMP,0,0)#</cfoutput>" readonly>
                                                	<span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id2=add_packet_ship.deliver_id2&field_name=add_packet_ship.deliver_name2&select_list=1','list');"></span>
                                				</div>
                                          	</div>
                                     	</div>    
                                        
                                 	</div>
                               	</cf_box_elements>
                                <cf_box_footer>
									<div class="col col-12 col-xs-12">
                                        <cf_record_info 
                                            query_name="get_shippng_plan"
                                            record_emp="RECORD_EMP" 
                                            record_date="record_date"
                                            update_emp="UPDATE_EMP"
                                            update_date="update_date">
                                     	<cfif get_shippng_plan.SHIPMENT_PROCESS eq 1 or get_shipping_serial_control.recordcount>
                                        	<cf_workcube_buttons 
                                                is_upd='1' 
                                                add_function='kontrol()'
                                                is_delete='0'>
                                        <cfelse>
                                            <cf_workcube_buttons 
                                                is_upd='1' 
                                                add_function='kontrol()'
                                                del_function='del_kontrol()'>
                                      	</cfif>
                                    </div>
                				</cf_box_footer>
                          	</div>
                      	</div>
             	</div>
         	</cf_basket_form> 
            <cf_basket id="upd_default_measure_bask">
            	<cf_grid_list sort="0">
                	<thead>
                        <tr>

                           	<th style="width:25px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th style="width:80px"><cf_get_lang dictionary_id='38047.Sipariş No'></th>
                            <th style="width:100px"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                            <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                            <th><cf_get_lang dictionary_id='57629.Açıklama'></th>
                            <th style="width:90px"><cf_get_lang dictionary_id='57482.Aşama'></th>
                            <th style="width:80px"><cf_get_lang dictionary_id='57647.Spec'></th>
                            <th style="width:40px"><cf_get_lang dictionary_id='29784.Ağırlık'></th>
                            <th style="width:40px"><cf_get_lang dictionary_id='30114.Hacim'></th>
                            <th style="text-align:right; width:60px"><cf_get_lang dictionary_id='57611.Sipariş'></th>
                		</tr>
                  	</thead>
                    <tbody id="table2">
                        <cfset irs_top=0>
                        <cfif get_order_det.recordcount>
                            <cfoutput query="get_order_det">
                                <cfset stock_id=get_order_det.STOCK_ID>
                                <tr>
                                    <td style="text-align:right; height:20px">#currentrow#</td>
                                    <td>  
                                    	<cfif IS_INSTALMENT eq 1>
                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.list_order_instalment&event=upd&order_id=#get_order_det.order_id#','longpage');" class="tableyazi" title="<cf_get_lang dictionary_id='728.Satış Siparişine Git'>">
                                        <cfelse>
                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.list_order&event=upd&order_id=#get_order_det.order_id#','longpage');" class="tableyazi" title="<cf_get_lang dictionary_id='728.Satış Siparişine Git'>">
                                        </cfif>
                                        #get_order_det.ORDER_NUMBER#
                                        </a>
                                    </td>
                                    <td>#get_order_det.STOCK_CODE#</td>
                                    <td>#get_order_det.PRODUCT_NAME#</td>
                                    <td>#get_order_det.PRODUCT_NAME2#</td>
                                    <td style="text-align:center">
                                    	<cfif order_row_currency eq -8><cf_get_lang_main no ='1952.Fazla Teslimat'>
										<cfelseif order_row_currency eq -7><cf_get_lang_main no ='1951.Eksik Teslimat'>
                                   		<cfelseif order_row_currency eq -6><cf_get_lang_main no='1349.Sevk'>
                                       	<cfelseif order_row_currency eq -5><cf_get_lang_main no ='44.Üretim'>
                                      	<cfelseif order_row_currency eq -4><cf_get_lang_main no ='1950.Kismi Üretim'>
                                      	<cfelseif order_row_currency eq -3><cf_get_lang_main no ='1949.Kapatildi'>
                                      	<cfelseif order_row_currency eq -2><cf_get_lang_main no ='1948.Tedarik'>
                                     	<cfelseif order_row_currency eq -1><cf_get_lang_main no='1305.Açık'>
                                      	<cfelseif order_row_currency eq -9><cf_get_lang_main no ='1094.İptal'>
                                      	<cfelseif order_row_currency eq -10><cf_get_lang dictionary_id='40876.Kapatıldı(Manuel)'></cfif>
                                    </td>
                                    <td>
                                        <cfif len(SPECT_VAR_ID)>
                                            <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_upd_spect&id=#SPECT_VAR_ID#&stock_id=#stock_id#','list');" class="tableyazi">#spect_main_id#-#spect_var_id#</a>	
                                        </cfif>
                                    </td>
                                     <td style="text-align:right;">#AmountFormat(get_order_det.WEIGHT*get_order_det.QUANTITY)#</td>
                                    <td style="text-align:right;">#AmountFormat(get_order_det.VOLUME/1000000*get_order_det.QUANTITY)#</td>
                                    <cfset total_weight = total_weight + (get_order_det.WEIGHT*get_order_det.QUANTITY)>
                                    <cfset total_volume = total_volume + (get_order_det.VOLUME/1000000*get_order_det.QUANTITY)>
                                    <input type="hidden"  name="volume_#currentrow#" id="volume_#currentrow#" value="#round(get_order_det.VOLUME/1000000*get_order_det.QUANTITY*100)/100#" />
                                    <input type="hidden"  name="weight_#currentrow#" id="weight_#currentrow#" value="#round(get_order_det.WEIGHT*get_order_det.QUANTITY*100)/100#" />
                                    
                                    <td style="text-align:right;">#AmountFormat(QUANTITY)#</td>
                                </tr>
                            </cfoutput>
                        </cfif>
                    </tbody>
                    <tfoot>
                    	<cfoutput>
                    	<tr>
                        	<td style="text-align:left; font-weight:bold" colspan="7"><cf_get_lang dictionary_id='57492.Toplam'></td>
                            <td style="text-align:right; font-weight:bold">
                            	<input style="text-align:right; font-weight:bold; border:none; width:95%" type="text" name="total_weight" id="total_weight" value="#AmountFormat(total_weight,2)#">
                            </td>
                            <td style="text-align:right; font-weight:bold">
                            	<input style="text-align:right; font-weight:bold; border:none; width:95%" type="text" name="total_volume" id="total_volume" value="#AmountFormat(total_volume,2)#">
                            </td>
                            <td colspan="1"></td>
                        </tr>
                        </cfoutput>
                    </tfoot>
               	</cf_grid_list>  
          	</cf_basket>
        </cfform>
    </cf_box>
</div>
<script type="text/javascript">
	function sil(type,ship_result_internaldemand_row_id,ship_result_internaldemand_id)
	{
		
		sor = confirm("<cf_get_lang dictionary_id='767.Silmek İstediğiniz Satır Kalıcı Olarak Silinecektir'>!");
		if(sor == true)
			window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_del_ezgi_shipping_internaldemand&ship_result_internaldemand_row_id='+ship_result_internaldemand_row_id+'&ship_result_internaldemand_id='+ship_result_internaldemand_id+'&type='+type;
			else
				return false;
	}
	function kontrol()
	{
		<cfif x_out_date_control eq 1>
		if (!date_check(add_packet_ship.today_value,add_packet_ship.action_date,"Sevk tarihi Bugünden Önceye Yapılamaz.!"))
			return false;
		</cfif>
		if(document.getElementById("ship_method_id").value == "")	
		{
			alert("<cf_get_lang dictionary_id='764.Lütfen Sevk Yöntemi Seçiniz'> !");
			return false;
		}
		if(process_cat_control())
			return true;
		else
			return false;
	}
	function del_kontrol()
	{
		if(process_cat_control())
			window.location ='<cfoutput>#request.self#?fuseaction=sales.emptypopup_del_ezgi_shipping_internaldemand&ship_result_internaldemand_id=#attributes.iid#&type=2</cfoutput>';
		else
			return false;
	}
</script>