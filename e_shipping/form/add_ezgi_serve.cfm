<!---
    File: add_ezgi_serve.cfm
    Folder: Add_Ons\ezgi\e-shipping\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfquery name="GET_ORDER" datasource="#DSN3#">
	SELECT 
		ORDERS.ORDER_NUMBER,
		ORDERS.ORDER_DATE,
		ORDERS.SHIP_METHOD,
		ORDERS.SHIP_ADDRESS,
		ORDERS.COMPANY_ID,
		ORDERS.PARTNER_ID,
		ORDERS.CONSUMER_ID,
        ORDERS.DELIVER_DEPT_ID, 
        ORDERS.LOCATION_ID, 
        ORDERS.REF_NO,
        ORDERS.ORDER_DETAIL,
        ORDERS.RESERVED,
		COMPANY_CREDIT.SHIP_METHOD_ID SHIP_METHOD_ID
  	FROM
		ORDERS WITH (NOLOCK) LEFT JOIN 
        #dsn_alias#.COMPANY_CREDIT COMPANY_CREDIT ON ORDERS.COMPANY_ID = COMPANY_CREDIT.COMPANY_ID AND COMPANY_CREDIT.OUR_COMPANY_ID = #session.ep.company_id#
	WHERE
		ORDERS.ORDER_ID = #attributes.order_id#
</cfquery>
<cfif not GET_ORDER.DELIVER_DEPT_ID>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='29428.Çıkış Depo'>");
		window.close()
	</script>
    <cfabort>
</cfif>
<cfif len(get_order.ship_method) or len(get_order.ship_method_id)>
	<cfquery name="GET_SHIP_METHOD" datasource="#DSN#">
		SELECT 
        	SHIP_METHOD,
            SHIP_METHOD_ID 
      	FROM 
        	SHIP_METHOD WITH (NOLOCK)
        WHERE 
        	SHIP_METHOD_ID =
				<cfif len(get_order.ship_method)>
                	#get_order.ship_method#
              	<cfelse>
                	#get_order.SHIP_METHOD_ID#
              	</cfif> 
	</cfquery>
</cfif>
<cfquery name="get_service_cat" datasource="#dsn3#">
	SELECT SERVICECAT_ID, SERVICECAT FROM SERVICE_APPCAT ORDER BY SERVICECAT
</cfquery>
<cfquery name="get_service_substatus" datasource="#dsn3#">
	SELECT SERVICE_SUBSTATUS, SERVICE_SUBSTATUS_ID FROM SERVICE_SUBSTATUS ORDER BY SERVICE_SUBSTATUS
</cfquery>
<cfquery name="get_service_code" datasource="#dsn3#">
	SELECT SERVICE_CODE_ID, SERVICE_CODE FROM SETUP_SERVICE_CODE ORDER BY SERVICE_CODE
</cfquery>
<cfif GET_ORDER.recordcount>
	<cfparam name="attributes.reference_no" default="#GET_ORDER.REF_NO#">
    <cfquery name="get_department" datasource="#dsn#">
		SELECT     
        	DEPARTMENT.DEPARTMENT_HEAD, 
            DEPARTMENT.BRANCH_ID, 
            DEPARTMENT.DEPARTMENT_ID, 
            STOCKS_LOCATION.LOCATION_ID, 
            STOCKS_LOCATION.COMMENT
		FROM         
    		DEPARTMENT WITH (NOLOCK) INNER JOIN
        	STOCKS_LOCATION WITH (NOLOCK) ON DEPARTMENT.DEPARTMENT_ID = STOCKS_LOCATION.DEPARTMENT_ID
  	  	WHERE     
        	DEPARTMENT.DEPARTMENT_ID = #GET_ORDER.DELIVER_DEPT_ID# AND 
            STOCKS_LOCATION.LOCATION_ID = #GET_ORDER.LOCATION_ID#    
	</cfquery>
    <cfparam name="attributes.branch_id" default="#get_department.BRANCH_ID#">
    <cfparam name="attributes.department_id" default="#get_department.DEPARTMENT_ID#">
    <cfparam name="attributes.location_id" default="#get_department.LOCATION_ID#">
    <cfparam name="attributes.department_name" default="#get_department.DEPARTMENT_HEAD#-#get_department.COMMENT#">
    	<cfquery name="get_order_det" datasource="#DSN3#">
		SELECT
			ORR.STOCK_ID,
            ORR.QUANTITY,
            ORR.ORDER_ROW_ID,
            ORD.ORDER_ID,
            ORD.ORDER_HEAD, 
            ORD.ORDER_NUMBER,
            ORR.SPECT_VAR_ID,
            ORR.SPECT_VAR_NAME,
            ORD.SALES_ADD_OPTION_ID,
            ORD.ORDER_STAGE,
            S.PRODUCT_NAME,
            S.STOCK_CODE,
            S.STOCK_CODE_2,
            ISNULL(S.IS_KARMA,0) AS IS_KARMA,
            ISNULL(S.IS_PRODUCTION,0) AS IS_PRODUCTION,
            (
            SELECT     
            	SPECT_MAIN_ID
			FROM         
            	SPECTS WITH (NOLOCK)
			WHERE     
            	SPECT_VAR_ID = ORR.SPECT_VAR_ID
            ) AS SPECT_MAIN_ID
            
		FROM
			ORDER_ROW ORR WITH (NOLOCK),
			ORDERS ORD WITH (NOLOCK),
			STOCKS S WITH (NOLOCK)
		WHERE
			ORD.ORDER_ID = ORR.ORDER_ID AND
			ORR.STOCK_ID = S.STOCK_ID AND 
            ORD.ORDER_ID = #attributes.order_id#
	</cfquery>
    <cfset order_row_id_list = Valuelist(get_order_det.ORDER_ROW_ID)>
	<cfquery name="get_ship_det" datasource="#DSN3#">
		SELECT   
        	ORR.ORDER_ROW_ID,      
        	S.SERVICE_NO, 
            S.SERVICE_ID
		FROM            
        	SERVICE AS S WITH (NOLOCK) INNER JOIN
        	ORDER_ROW AS ORR WITH (NOLOCK) ON S.EZGI_ORDER_ROW_ID = ORR.ORDER_ROW_ID
		WHERE        
        	ORR.ORDER_ID = #attributes.order_id#
	</cfquery>
	<cfoutput query="get_ship_det">
    	<cfset 'SERVICE_NO_#ORDER_ROW_ID#' = SERVICE_NO>
        <cfset 'SERVICE_ID_#ORDER_ROW_ID#' = SERVICE_ID>
    </cfoutput>
</cfif>
<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id='709.SSH'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#ezgi_header#">
    	<cfform name="add_ssh" id="add_ssh" method="post" action="#request.self#?fuseaction=sales.emptypopup_add_ezgi_serve&order_id=#url.order_id#">
        	<cfinput type="hidden" name="order_row_id_list" value="#order_row_id_list#">
			<input type="hidden" name="order_comp" id="order_comp" value="<cfoutput>#get_par_info(get_order.company_id,1,0,0)#</cfoutput>">
			<input type="hidden" name="order_cons" id="order_cons" value="<cfoutput>#get_cons_info(get_order.consumer_id,1,0,0)#</cfoutput>">
			<input type="hidden" name="order_number" id="order_number" value="<cfoutput>#get_order.order_number#</cfoutput>">
			<cfif len(get_order.ship_address)>
				<input type="hidden" name="order_adress" id="order_adress" value="<cfoutput>#get_order.ship_address#</cfoutput>">
			<cfelse>
				<input type="hidden" name="order_adress" id="order_adress" value="">
			</cfif>
			<cfif len(get_order.ship_method)>
				<input type="hidden" name="order_type" id="order_type" value="<cfoutput>#get_ship_method.ship_method#</cfoutput>">
			<cfelse>
				<input type="hidden" name="order_type" id="order_type" value="">
			</cfif>
			<input type="hidden" name="order_date" id="order_date" value="<cfoutput>#dateformat(get_order.order_date,'dd/mm/yyyy')#</cfoutput>">
            <cf_basket_form id="add_ssh_">
            	<div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
            						<div class="col col-6 col-xs-12" type="column" index="1" sort="true">
                                    	<div class="form-group" id="item-stage">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58859.Süreç'>*</label>
	                            			<div class="col col-8 col-xs-12">
                                             	<cf_workcube_process is_upd='0' is_detail='0'>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-company">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57519.Cari Hesap'> *</label>
	                            			<div class="col col-8 col-xs-12">
                                             	<cfif len(attributes.order_id)>
                                                    <input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#get_order.consumer_id#</cfoutput>">
                                                    <input type="hidden" name="company_id" id="company_id" value="<cfoutput>#get_order.company_id#</cfoutput>">
                                                    <input type="hidden" name="partner_id" id="partner_id" value="<cfoutput>#get_order.partner_id#</cfoutput>">
                                                    <input type="text" name="company" id="company" value="<cfoutput>#get_par_info(get_order.company_id,1,0,0)#</cfoutput>" readonly>
                                                <cfelse>
                                                    <input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
                                                    <input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
                                                    <input type="hidden" name="partner_id" id="partner_id" value="<cfif isdefined("attributes.partner_id")><cfoutput>#attributes.partner_id#</cfoutput></cfif>">
                                                    <input type="text" name="company" id="company" value="<cfif isdefined("attributes.company")><cfoutput>#attributes.company#</cfoutput></cfif>" readonly>
                                                </cfif>
                                          	</div>
                                      	</div>
                                        <div class="form-group" id="item-yetkili">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57578.Yetkili'> *</label>
	                            			<div class="col col-8 col-xs-12">
                                             	<cfif len(attributes.order_id)>
													<cfif Len(GET_ORDER.CONSUMER_ID)>
                                                        <input type="text" name="member_name" id="member_name" value="<cfoutput>#get_cons_info(get_order.CONSUMER_ID,0,0)#</cfoutput>" readonly style="width:170px;">
                                                    <CFELSE>
                                                        <input type="text" name="member_name" id="member_name" value="<cfoutput>#get_par_info(get_order.partner_id,0,-1,0)#</cfoutput>" readonly style="width:170px;">
                                                    </cfif>
                                                <cfelse>
                            
                                                    <input type="text" name="member_name" id="member_name" value="<cfif isdefined("attributes.member_name")><cfoutput>#attributes.member_name#</cfoutput></cfif>" readonly>
                                                </cfif>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-sevk">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29500.Sevk Yöntemi'> *</label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                	<input type="hidden" name="ship_method_id" id="ship_method_id" value="<cfif isdefined("attributes.ship_method_id")><cfoutput>#attributes.ship_method_id#</cfoutput><cfelseif isdefined('get_ship_method')><cfoutput>#get_ship_method.ship_method_id#</cfoutput></cfif>">
													<input type="text" name="ship_method_name" id="ship_method_name" value="<cfif isdefined("attributes.ship_method_name")><cfoutput>#attributes.ship_method_name#</cfoutput><cfelseif isdefined('get_ship_method')><cfoutput>#get_ship_method.ship_method#</cfoutput></cfif>" readonly style="width:170px;">
                                                	<span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_ship_methods&field_name=add_ssh.ship_method_name&field_id=add_ssh.ship_method_id','medium');"></span>
                                				</div>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-sevk">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57899.Kaydeden'></label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                
                                                	<input type="hidden" name="deliver_id2" id="deliver_id2" value="<cfoutput>#session.ep.userid#</cfoutput>">
													<input type="text" name="deliver_name2" id="deliver_name2" value="<cfoutput>#get_emp_info(session.ep.userid,0,0)#</cfoutput>" readonly style="width:170px;">
                                                	<span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id2=add_ssh.deliver_id2&field_name=add_ssh.deliver_name2&select_list=1','list');"></span>
                                				</div>
                                          	</div>
                                     	</div>
                                 	</div>
                                    <div class="col col-6 col-xs-12" type="column" index="2" sort="true">
                                    	<div class="form-group" id="item-paper">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='39463.Servis Kategorileri'> *</label>
	                            			<div class="col col-8 col-xs-12">
                                             	<select name="service_cat" id="service_cat" style="width:170px; height:20px">
                                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                    <cfoutput query="get_service_cat">
                                                            <option value="#SERVICECAT_ID#">#SERVICECAT#</option>
                                                    </cfoutput>
                                                </select>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-paper">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='42159.Servis Alt Durumları'> *</label>
	                            			<div class="col col-8 col-xs-12">
                                             	<select name="service_substatus" id="service_substatus" style="width:170px; height:20px">
                                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                    <cfoutput query="get_service_substatus">
                                                            <option value="#SERVICE_SUBSTATUS_ID#">#SERVICE_SUBSTATUS#</option>
                                                    </cfoutput>
                                                </select>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-reference">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58794.Referans No'></label>
	                            			<div class="col col-8 col-xs-12">
                                             	<input type="text" name="reference_no" id="reference_no" readonly="readonly" value="<cfoutput>#attributes.reference_no#</cfoutput>" maxlength="25" style="width:100px;">
                                          	</div>
                                     	</div>
                                         <div class="form-group" id="item-outdate">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='49292.Başvuru Tarihi'></label>
	                            			<div class="col col-4 col-xs-12">
                                            	<div class="input-group">
                                             		<cfsavecontent variable="message"><cf_get_lang dictionary_id='45464.Depo Çıkış Tarihi Girmelisiniz'> !</cfsavecontent>
													<cfinput type="text" name="action_date" id="action_date" value="#dateformat(GET_ORDER.ORDER_DATE,'dd/mm/yyyy')#" validate="eurodate" required="Yes" message="#message#" style="width:65px;">
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
                                                <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_stores_locations&form_name=add_ssh&field_name=department_name&field_id=department_id&field_location_id=location_id&branch_id=branch_id','list')"></span>
                                				</div>
                                          	</div>
                                     	</div>
                                       
                                        
                                    	<div class="form-group" id="item-deliveremp">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='42848.Arıza Kodları'> *</label>
	                            			<div class="col col-8 col-xs-12">
                                            	<select name="service_code" id="service_code" style="width:170px; height:75px" multiple>
                                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                    <cfoutput query="get_service_code">
                                                            <option value="#SERVICE_CODE_ID#">#SERVICE_CODE#</option>
                                                    </cfoutput>
                                                </select>
                                          	</div>
                                     	</div>    
                                        
                                 	</div>
                               	</cf_box_elements>
                          	</div>
                      	</div>
             	</div>
         	</cf_basket_form>
            <cf_basket id="upd_default_measure_bask">
            	<cf_grid_list sort="0">
                	<thead>
                        <tr> 
                            <th style="width:100px"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                            <th style="width:350px"><cf_get_lang dictionary_id='57657.Ürün'></th>
                            <th style="width:90px"><cf_get_lang dictionary_id='33026.Servis Numarası'></th>
                            <th style="width:80px"><cf_get_lang dictionary_id='57647.Spec'></th>
                            <th style="text-align:right; width:60px"><cf_get_lang dictionary_id='57611.Sipariş'></th>
                            <th width="70"style="text-align:right;"><cf_get_lang dictionary_id='41898.Serviste'></th>
                            <th style="text-align:right; width:50px"><cf_get_lang dictionary_id='58444.Kalan'></th>
                            <th style="text-align:center; width:15px">&nbsp;</th>
                            <th style="text-align:center; width:15px">&nbsp;
                                <input type="checkbox" name="all_conv_product" id="all_conv_product" onClick="javascript: wrk_select_all2('all_conv_product','_conversion_product_',<cfoutput>#get_order_det.recordcount#</cfoutput>);">
                           </th>
                        </tr>
                    </thead>
                    <tbody id="table2">
                        <cfset irs_top=0>
                        <cfif get_order_det.recordcount>
                            <cfoutput query="get_order_det">
                                <cfset stock_id=get_order_det.STOCK_ID>
                                <tr>
                                    <td>#get_order_det.STOCK_CODE#</td>
                                    <td>#get_order_det.PRODUCT_NAME#</td>
                                    <td>

                                        <cfif isdefined('SERVICE_ID_#ORDER_ROW_ID#')>
                                            <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=service.list_service&event=upd&service_id=#Evaluate('SERVICE_ID_#ORDER_ROW_ID#')#&service_no=#Evaluate('SERVICE_NO_#ORDER_ROW_ID#')#','longpage');" class="tableyazi">
                                                #Evaluate('SERVICE_NO_#ORDER_ROW_ID#')#
                                            </a>
                                        </cfif>
                                    </td>
                                    <td>
                                        <cfif len(SPECT_VAR_ID)>
                                            <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_upd_spect&id=#SPECT_VAR_ID#&stock_id=#stock_id#','list');" class="tableyazi">#spect_main_id#-#spect_var_id#</a>	
                                        </cfif>
                                    </td>
                                    <td style="text-align:right;">#AmountFormat(get_order_det.QUANTITY)#</td>
                                    <td style="text-align:right;">
                                        <cfif isdefined('SERVICE_ID_#ORDER_ROW_ID#')>
                                            #AmountFormat(get_order_det.QUANTITY)#
                                        <cfelse>
                                           -
                                        </cfif>
                                    </td>
                                    <td style="text-align:right;">
                                  		<cfset row_amount = get_order_det.QUANTITY>
                                    	<input type="text" style="text-align:right; width:40px" readonly="readonly" name="row_amount_#ORDER_ROW_ID#" value="#amountformat(row_amount)#" />
                                    </td>
                                     <td style="text-align:center;">
                                     	<cfif IS_KARMA eq 1 or IS_PRODUCTION eq 1>
											<cfif not isdefined('SERVICE_ID_#ORDER_ROW_ID#')>
                                                <a href="#request.self#?fuseaction=sales.popup_list_ezgi_iflow_serve_product_tree&order_id=#attributes.order_id#&stock_id=#stock_id#&spect_main_id=#spect_main_id#">
                                                    <i class="fa fa-tree" title="<cf_get_lang dictionary_id='140.Ürün Ağacı'>" alt="<cf_get_lang dictionary_id='140.Ürün Ağacı'>"></i>
                                                </a>
                                            </cfif>
                                        </cfif>
                                   	</td>
                                    <td style="text-align:center;">
                                        <cfif not isdefined('SERVICE_ID_#ORDER_ROW_ID#')>
                                            <input type="checkbox" name="select_order_row_#ORDER_ROW_ID#" value="1" id="_conversion_product_#currentrow#"
                                                     checked="checked" readonly="readonly"
                                            >
                                        <cfelse>
                                            <img src="/images/c_ok.gif" border="0" title="<cf_get_lang dictionary_id='41898.Serviste'>">
                                        </cfif>
                                    </td>
                                </tr>
                            </cfoutput>
                        </cfif>
                    </tbody>
               	</cf_grid_list>
                <cf_popup_box_footer>
                    <cf_workcube_buttons is_upd='0' add_function='control()'>
                </cf_popup_box_footer>  
            </cf_basket>
        </cfform>
    </cf_box>
</div>
<script type="text/javascript">
	
	function wrk_select_all2(all_conv_product,_conversion_product_,number)
	{
		for(var cl_ind=1; cl_ind <= number; cl_ind++)
		{
			if(document.getElementById(all_conv_product).checked == true)
			{
				if(document.getElementById('_conversion_product_'+cl_ind).checked == false)
					document.getElementById('_conversion_product_'+cl_ind).checked = true;
			}
			else
			{
				if(document.getElementById('_conversion_product_'+cl_ind).checked == true)
					document.getElementById('_conversion_product_'+cl_ind).checked = false;
			}
		}
	}
	function control()
	{
		
		if (document.getElementById("company_id").value == "" && document.getElementById("consumer_id").value == "")
		{
			alert("<cf_get_lang dictionary_id='58965.Önce Cari Hesap Seçiniz'>");
			return false;
		}	

		if(document.getElementById("service_cat").value == "")	
		{
			alert("<cf_get_lang dictionary_id='43390.Kategori Kodu Girmelisiniz'>!");
			document.getElementById('service_cat').focus();
			return false;
		}
		if(document.getElementById("service_substatus").value == "")	
		{
			alert("<cf_get_lang dictionary_id='42159.Servis Alt Durumları'>!");
			document.getElementById('service_substatus').focus();
			return false;
		}
		if(document.getElementById("service_code").value == "")	
		{
			alert("<cf_get_lang dictionary_id='42848.Arıza Kodları'>!");
			document.getElementById('service_code').focus();
			return false;
		}
		if(document.getElementById("department_name").value == "")	
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='29428.Çıkış Depo'>!");
			document.getElementById('department_name').focus();
			return false;
		}
		secim = 0;
		<cfoutput query="get_order_det">
			sira = #currentrow#;
			if (document.getElementById('_conversion_product_'+sira).checked == true)
				secim = 1;
		</cfoutput>
		if(secim == 0)
		{
			alert("<cf_get_lang dictionary_id='57041.Ürün Seçmediniz. Lütfen Ürün Seçiniz.'>!");
			return false;
		}
	}
</script>