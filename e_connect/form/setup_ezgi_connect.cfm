<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_CONNECT_SETUP
</cfquery>
<cfquery name="get_emp_defaults" datasource="#dsn3#">
	SELECT 
   		CONNECT_EMPLOYEE_ID, 
        EMPLOYEE_ID, 
        MEMBER_TYPE, 
        MEMBER_ID,
    	ISNULL(IS_PRICE,0) AS IS_PRICE, 
        ISNULL(IS_PRICE_KDV,0) AS IS_PRICE_KDV, 
        ISNULL(IS_EXPORT,0) AS IS_EXPORT,
        ISNULL(IS_CUSTOMER_SELECT,0) AS IS_CUSTOMER_SELECT,
        ISNULL(CASH_DISCOUNT_RATE,0) AS CASH_DISCOUNT_RATE,
        ISNULL(FUTURE_DISCOUNT_RATE,0) AS FUTURE_DISCOUNT_RATE,
        ISNULL(CAMP_DISCOUNT_RATE,0) AS CAMP_DISCOUNT_RATE
    FROM 
    	EZGI_CONNECT_SETUP_ROW
</cfquery>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="title_"><cf_get_lang dictionary_id='813.E-Shipping Tanımları'></cfsavecontent>
	<cf_box title = "#title_#">
    	<cfform name="upd_e_connect_setup" method="post" action="#request.self#?fuseaction=sales.emptypopup_setup_ezgi_connect">
        	<cf_basket_form id="e_shipping_setup">
                <div class="row">
                  	<div class="col col-12 uniqueRow">
                     	<div class="row formContent">
                         		<cf_box_elements>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                                        <div class="form-group" id="item-shipping_control">
                                            <label class="col col-8 col-xs-12">Liste Resim Yüksekliği (px)</label>
                                            <div class="col col-4 col-xs-12">
                                               <cfinput type="text" id="IMAGE_SMALL_HEIGHT"  maxlength="10" name="IMAGE_SMALL_HEIGHT" value="#get_defaults.IMAGE_SMALL_HEIGHT#" style="width:130px">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-pda_control">
                                            <label class="col col-8 col-xs-12">Liste Resim Genişliği (px)</label>
                                            <div class="col col-4 col-xs-12">
                                                 <cfinput type="text" id="IMAGE_SMALL_WIDTH"  maxlength="10" name="IMAGE_SMALL_WIDTH" value="#get_defaults.IMAGE_SMALL_WIDTH#" style="width:130px">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-pda_control">
                                            <label class="col col-8 col-xs-12">Liste Resim Kalitesi (px)</label>
                                            <div class="col col-4 col-xs-12">
                                                 <cfinput type="text" id="IMAGE_SMALL_PIXEL"  maxlength="10" name="IMAGE_SMALL_PIXEL" value="#get_defaults.IMAGE_SMALL_PIXEL#" style="width:130px">
                                            </div>
                                        </div>
                                  	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                                         <div class="form-group" id="item-shipping_control">
                                            <label class="col col-8 col-xs-12">Detay Resim Yüksekliği (px)</label>
                                            <div class="col col-4 col-xs-12">
                                               <cfinput type="text" id="IMAGE_MEDIUM_HEIGHT"  maxlength="10" name="IMAGE_MEDIUM_HEIGHT" value="#get_defaults.IMAGE_MEDIUM_HEIGHT#" style="width:130px">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-pda_control">
                                            <label class="col col-8 col-xs-12">Detay Resim Genişliği (px)</label>
                                            <div class="col col-4 col-xs-12">
                                                 <cfinput type="text" id="IMAGE_MEDIUM_WIDTH"  maxlength="10" name="IMAGE_MEDIUM_WIDTH" value="#get_defaults.IMAGE_MEDIUM_WIDTH#" style="width:130px">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-pda_control">
                                            <label class="col col-8 col-xs-12">Detay Resim Kalitesi (px)</label>
                                            <div class="col col-4 col-xs-12">
                                                 <cfinput type="text" id="IMAGE_MEDIUM_PIXEL"  maxlength="10" name="IMAGE_MEDIUM_PIXEL" value="#get_defaults.IMAGE_MEDIUM_PIXEL#" style="width:130px">
                                            </div>
                                        </div>
                                 	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
										<div class="form-group" id="item-validate_date">
                                            <label class="col col-8 col-xs-12">Teklif Geçerlilik Süresi (Gün)</label>
                                            <div class="col col-4 col-xs-12">
                                               <cfinput type="text" id="VALIDATE_DATE"  maxlength="10" name="VALIDATE_DATE" value="#TlFormat(get_defaults.VALIDATE_DATE,0)#" style="width:130px">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-delivery_date">
                                            <label class="col col-8 col-xs-12">Teklif Teslim Süresi (Gün)</label>
                                            <div class="col col-4 col-xs-12">
                                                 <cfinput type="text" id="DELIVERY_DATE"  maxlength="3" name="DELIVERY_DATE" value="#TlFormat(get_defaults.DELIVERY_DATE,0)#" style="width:130px">
                                            </div>
                                        </div>
                                   	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                                    
                                   	</div>
                               	</cf_box_elements>
                                <cf_box_footer>
									<div class="col col-12 col-xs-12">
                                        <cf_workcube_buttons 
                                        	is_upd='1' 
                                            add_function='kontrol()'
                                            is_delete = '0'>
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
                        	<th style="text-align:center; width:20px">
                            	 <a href="javascript:add_row_emp();"><img src="/images/plus_list.gif"  border="0" title="<cf_get_lang dictionary_id='44630.Ekle'>"></a>
                                <input type="hidden" name="record_num_emp" id="record_num_emp" value="<cfoutput>#get_emp_defaults.recordcount#</cfoutput>">
                            </th>
                            <th style="text-align:center; width:30px" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th style="text-align:center; width:290px" ><cf_get_lang dictionary_id='44688.Çalışan Adı'></th>
                            <th style="text-align:center;" ><cf_get_lang dictionary_id='50118.Bağlı Kurumsal Üyeler'></th>
                            <th style="text-align:center; width:70px" ><cf_get_lang dictionary_id='58645.Nakit'><cf_get_lang dictionary_id='63316.Maximum Marj'></th>
                            <th style="text-align:center; width:70px" ><cf_get_lang dictionary_id='57798.Vadeli'><cf_get_lang dictionary_id='63316.Maximum Marj'></th>
                            <th style="text-align:center; width:70px" ><cf_get_lang dictionary_id='57446.Kampanya'><cf_get_lang dictionary_id='63316.Maximum Marj'></th>
                            <th style="text-align:center; width:100px" ><cf_get_lang dictionary_id='46074.Toplam Göster'></th>
                            <th style="text-align:center; width:100px" ><cf_get_lang dictionary_id='64382.KDV Dahil Fiyat'></th>
                            <th style="text-align:center; width:100px" ><cf_get_lang dictionary_id='29692.Yurtdışı'></th>
                            <th style="text-align:center; width:100px" ><cf_get_lang dictionary_id='1352.Müşteri Seçerek Başla'></th>
                    	</tr>
                	</thead>
                	<tbody name="new_row_emp" id="new_row_emp">
                    	<cfif get_emp_defaults.recordcount>
                    		<cfoutput query="get_emp_defaults">
                            	<cfif MEMBER_TYPE eq 'consumer'>
                                	<cfset attributes.consumer_id = MEMBER_ID>
                                    <cfset attributes.company_id = ''>
                                    <cfset attributes.company = get_cons_info(MEMBER_ID,0,0)>
                                <cfelseif MEMBER_TYPE eq 'company'>
                                	<cfset attributes.company_id = MEMBER_ID>
                                    <cfset attributes.consumer_id = ''>
                                    <cfset attributes.company = get_par_info(MEMBER_ID,1,1,0)>
                               	<cfelse>
                                	<cfset attributes.company_id = ''>
                                    <cfset attributes.consumer_id = ''>
                                    <cfset attributes.company = ''>
                                </cfif>
                               	<tr name="frm_row_emp" id="frm_row_emp#currentrow#">
                                 	<td style="height:20px; text-align:center">
                                        <a style="cursor:pointer" onclick="sil_emp(#currentrow#);">
                                       	 	<img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>">
                                       	</a>
                                     	<input type="hidden" name="row_kontrol_emp#currentrow#" id="row_kontrol_emp#currentrow#" value="1">
                                    </td>
                                    <td style="text-align:right">#currentrow#</td>
                                    <td style="text-align:left">
                                    	<input type="hidden" name="employee_id_#currentrow#" id="employee_id_#currentrow#" value="#get_emp_defaults.EMPLOYEE_ID#">
                                     	<input type="text" name="employee_#currentrow#" id="employee_#currentrow#" value="#get_emp_info(get_emp_defaults.EMPLOYEE_ID,0,0)# " style="width:270px;" onFocus="AutoComplete_Create('record_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','record_employee_id','','3','125');" autocomplete="off">
                                      	<a style="cursor:pointer" href"javascript://" onClick="pencere_ac_emp(#currentrow#);">
                                        	<img src="/images/plus_thin.gif" align="absmiddle" border="0">
                                       	</a>
                                    </td>
                                    <td style="text-align:left" nowrap>
                                    	<input type="hidden" name="consumer_id_#currentrow#" id="consumer_id_#currentrow#" value="<cfif len(attributes.consumer_id) and len(attributes.company)>#attributes.consumer_id#</cfif>">
										<input type="hidden" name="company_id_#currentrow#" id="company_id_#currentrow#" value="<cfif len(attributes.company) and len(attributes.company_id)>#attributes.company_id#</cfif>">
										<input type="text" name="company_#currentrow#" id="company_#currentrow#" style="width:95%;" value="<cfif len(attributes.company)>#attributes.company#</cfif>">
                                    	<a style="cursor:pointer" href"javascript://" onClick="pencere_ac_mem(#currentrow#);">
                                        	<img src="/images/plus_thin.gif" align="absmiddle" border="0">
                                       	</a>
                                    </td>
                                    <td style="text-align:center">
                                    	<input type="text" name="DISC_RATE_1_#currentrow#" id="DISC_RATE_1_#currentrow#" value="#TlFormat(get_emp_defaults.CASH_DISCOUNT_RATE,2)#" style="text-align:right; width:70px">
                                  	</td>
                                    <td style="text-align:center">
                                    	<input type="text" name="DISC_RATE_2_#currentrow#" id="DISC_RATE_2_#currentrow#" value="#TlFormat(get_emp_defaults.FUTURE_DISCOUNT_RATE,2)#" style="text-align:right; width:70px">
                                  	</td>
                                    <td style="text-align:center">
                                    	<input type="text" name="DISC_RATE_3_#currentrow#" id="DISC_RATE_3_#currentrow#" value="#TlFormat(get_emp_defaults.CAMP_DISCOUNT_RATE,2)#" style="text-align:right; width:70px">
                                  	</td>
                                    <td style="text-align:center">
                                    	<input type="checkbox" name="IS_PRICE_#currentrow#" id="IS_PRICE_#currentrow#" value="1" <cfif get_emp_defaults.IS_PRICE eq 1>checked</cfif>>
                                  	</td>
                                    <td style="text-align:center">
                                    	<input type="checkbox" name="IS_PRICE_KDV_#currentrow#" id="IS_PRICE_KDV_#currentrow#" value="1" <cfif get_emp_defaults.IS_PRICE_KDV eq 1>checked</cfif>>
                                  	</td>
                                    <td style="text-align:center">
                                    	<input type="checkbox" name="IS_EXPORT_#currentrow#" id="IS_EXPORT_#currentrow#" value="1" <cfif get_emp_defaults.IS_EXPORT eq 1>checked</cfif>>
                                  	</td>
                                    <td style="text-align:center">
                                    	<input type="checkbox" name="IS_CUSTOMER_SELECT_#currentrow#" id="IS_CUSTOMER_SELECT_#currentrow#" value="1" <cfif get_emp_defaults.IS_CUSTOMER_SELECT eq 1>checked</cfif>>
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
	var row_count_emp=document.upd_e_connect_setup.record_num_emp.value;
	document.getElementById('ean').focus();
	function kontrol()
	{
		return true;
	}
	function add_row_emp()
	{
		
		row_count_emp++;
		var newRow_emp;
		var newCell_emp;
		newRow_emp = document.getElementById("new_row_emp").insertRow(document.getElementById("new_row_emp").rows.length);
		newRow_emp.setAttribute("name","frm_row_emp" + row_count_emp);
		newRow_emp.setAttribute("id","frm_row_emp" + row_count_emp);
		newRow_emp.setAttribute("NAME","frm_row_emp" + row_count_emp);
		newRow_emp.setAttribute("ID","frm_row_emp" + row_count_emp);
		
		document.upd_e_connect_setup.record_num_emp.value = row_count_emp;
		newCell_emp = newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.innerHTML = '<input type="hidden" name="row_kontrol_emp' + row_count_emp +'" id="row_kontrol_emp' + row_count_emp +'" value="1"><a style="cursor:pointer" onclick="sil_emp(' + row_count_emp + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang_main no='51.Sil'>" border="0"></a>';	
		
		newCell_emp = newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.style.textAlign = 'right';
		newCell_emp.innerHTML = row_count_emp;
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute('nowrap','nowrap');
		newCell_emp.innerHTML = '<input type="hidden" name="employee_id_' + row_count_emp +'" id="employee_id_' + row_count_emp +'" value=""><input type="text" name="employee_' + row_count_emp +'" id="employee_' + row_count_emp +'" value="" style="width:270px;" autocomplete="off"><a style="cursor:pointer" href"javascript://" onClick="pencere_ac_emp('+ row_count_emp +');"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>';
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute('nowrap','nowrap');
		newCell_emp.innerHTML = '<input type="hidden" name="consumer_id_' + row_count_emp +'" id="consumer_id_' + row_count_emp +'" value=""><input type="hidden" name="company_id_' + row_count_emp +'" id="company_id_' + row_count_emp +'" value=""><input type="text" name="company_' + row_count_emp +'" id="company_' + row_count_emp +'" style="width:350px;" value=""><a style="cursor:pointer" href"javascript://" onClick="pencere_ac_mem('+ row_count_emp +');"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>';
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute('nowrap','nowrap');
		newCell_emp.innerHTML = '<input type="text" name="disc_rate_1_' + row_count_emp +'" id="disc_rate_1_' + row_count_emp +'" value="<cfoutput>#TlFormat(0,2)#</cfoutput>" style="text-align:right; width:70px">';
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute('nowrap','nowrap');
		newCell_emp.innerHTML = '<input type="text" name="disc_rate_2_' + row_count_emp +'" id="disc_rate_2_' + row_count_emp +'" value="<cfoutput>#TlFormat(0,2)#</cfoutput>" style="text-align:right; width:70px">';
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute('nowrap','nowrap');
		newCell_emp.innerHTML = '<input type="text" name="disc_rate_3_' + row_count_emp +'" id="disc_rate_3_' + row_count_emp +'" value="<cfoutput>#TlFormat(0,2)#</cfoutput>" style="text-align:right; width:70px">';
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.style.textAlign = 'center';
		newCell_emp.innerHTML = '<input type="checkbox" name="is_price_' + row_count_emp +'" id="is_price_' + row_count_emp +'" value="1">';
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.style.textAlign = 'center';
		newCell_emp.innerHTML = '<input type="checkbox" name="is_price_kdv_' + row_count_emp +'" id="is_price_kdv_' + row_count_emp +'" value="1">';
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.style.textAlign = 'center';
		newCell_emp.innerHTML = '<input type="checkbox" name="is_export_' + row_count_emp +'" id="is_export_' + row_count_emp +'" value="1">';
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.style.textAlign = 'center';
		newCell_emp.innerHTML = '<input type="checkbox" name="is_customer_select_' + row_count_emp +'" id="is_customer_select_' + row_count_emp +'" value="1">';
	}
	function pencere_ac_emp(no_emp)
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=employee_id_" + no_emp +"&field_name=employee_" + no_emp +"&select_list=1",'list','popup_list_positions');
	}
	function pencere_ac_mem(no_emp)
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_comp_name=upd_e_connect_setup.company_' + no_emp +'&field_comp_id=upd_e_connect_setup.company_id_' + no_emp +'&field_consumer=upd_e_connect_setup.consumer_id_' + no_emp +'&field_member_name=upd_e_connect_setup.company_' + no_emp +'&select_list=2,3','list');
	}
	function sil_emp(sy_emp)
	{
		
		var element_emp=eval("upd_e_connect_setup.row_kontrol_emp"+sy_emp);
		element_emp.value=0;
		var element_emp=eval("frm_row_emp"+sy_emp);
		element_emp.style.display="none";		
	} 
</script>