<!---
    File: setup_ezgi_wm.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 15/12/2025
    Description: Raf ve Depo Sayım İşlemi
---> 
<cfquery name="get_emp_wm_defaults" datasource="#dsn3#">
	SELECT 
    	*,
        (SELECT  EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ADI FROM #dsn_alias#.EMPLOYEE_POSITIONS WHERE POSITION_CODE = E.EMPLOYEE_POSITION_ID) AS ADI 
   	FROM 
   		EZGI_WM_SETUP_ROW E
</cfquery>
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfquery name="get_departments" datasource="#dsn#">
	SELECT        
    	D.DEPARTMENT_STATUS, 
        S.LOCATION_ID, 
        S.DEPARTMENT_ID, 
        D.DEPARTMENT_HEAD + '-' + S.COMMENT AS DEPO, 
        S.DEPARTMENT_LOCATION
	FROM            
   		DEPARTMENT AS D INNER JOIN
      	STOCKS_LOCATION AS S ON D.DEPARTMENT_ID = S.DEPARTMENT_ID INNER JOIN
        BRANCH AS B ON D.BRANCH_ID = B.BRANCH_ID
  	WHERE
        B.COMPANY_ID = #session.ep.company_id#
	ORDER BY 
    	D.BRANCH_ID, 
        D.DEPARTMENT_HEAD
</cfquery>
<cfquery name="get_user_process_cat1" datasource="#dsn3#">
		SELECT
			DISTINCT
			SPC.PROCESS_CAT_ID,
			SPC.PROCESS_CAT,
			SPC.PROCESS_TYPE,
			SPC.IS_ACCOUNT,
			SPC.IS_DEFAULT
		FROM
			SETUP_PROCESS_CAT_ROWS AS SPCR,
			SETUP_PROCESS_CAT_FUSENAME AS SPCF,
			#dsn_alias#.EMPLOYEE_POSITIONS AS EP,
			SETUP_PROCESS_CAT SPC
		WHERE
			SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID AND
			SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID AND
			SPC.PROCESS_TYPE = 115
		ORDER BY
			SPC.PROCESS_CAT
</cfquery>
<cfquery name="get_user_process_cat2" datasource="#dsn3#">
		SELECT
			DISTINCT
			SPC.PROCESS_CAT_ID,
			SPC.PROCESS_CAT,
			SPC.PROCESS_TYPE,
			SPC.IS_ACCOUNT,
			SPC.IS_DEFAULT
		FROM
			SETUP_PROCESS_CAT_ROWS AS SPCR,
			SETUP_PROCESS_CAT_FUSENAME AS SPCF,
			#dsn_alias#.EMPLOYEE_POSITIONS AS EP,
			SETUP_PROCESS_CAT SPC
		WHERE
			SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID AND
			SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID AND
			SPC.PROCESS_TYPE = 112
		ORDER BY
			SPC.PROCESS_CAT
</cfquery>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="title_"><cf_get_lang dictionary_id='1333.WM Tanımları'></cfsavecontent>
	<cf_box title = "#title_#">
    	<cfform name="upd_e_wm_setup" method="post" action="#request.self#?fuseaction=stock.emptypopup_setup_ezgi_wm">
        	<cfinput type="hidden" name="lot_zorunlu" value="#get_defaults.PALET_BARCODE_LOT#">
            <cfinput type="hidden" name="ambar_control" value="#get_defaults.SHIPPING_CONTROL_TYPE#">
            <cfinput type="hidden" name="e_shipping_control" value="#get_defaults.IS_AMOUNT_INPUT_FREE#">
        	<cf_basket_form id="e_shipping_setup">
                <div class="row">
                  	<div class="col col-12 uniqueRow">
                     	<div class="row formContent">
                         		<cf_box_elements>
                                    
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                                        <div class="form-group" id="item-control_type">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='1113.PDA Kontrol Tipi'></label>
	                            			<div class="col col-8 col-xs-12">
                                            	<select name="pda_control_type" style="width:120px; height:20px">
                                                    <option value="1" <cfif get_defaults.PDA_CONTROL_TYPE eq 1>selected</cfif>><cf_get_lang dictionary_id='29539.Satır Bazında'></option>
                                                    <option value="2" <cfif get_defaults.PDA_CONTROL_TYPE eq 2>selected</cfif>><cf_get_lang dictionary_id='57660.Belge Bazında'></option>
                                                </select>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-ean">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='34183.Barkod Sayısı'> *</label>
	                            			<div class="col col-8 col-xs-12">
                                            	<cfinput type="text" name="ean" id="ean" value="#get_defaults.EAN#" style="width:50px">
                                          	</div>
                                     	</div>
                                 	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                                        <div class="form-group" id="item-sayım">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="29632.Sayım Fişi"> *</label>
                                            <div class="col col-8 col-xs-12">
                                            	<select name="process_cat1" id="process_cat1" style="width:150px;">
                                                    <option value="" selected><cf_get_lang dictionary_id ='57734.Seçiniz'></option>
                                                    <cfoutput query="get_user_process_cat1">
                                                        <option value="#PROCESS_CAT_ID#" <cfif get_defaults.SAYIM_FIS eq PROCESS_CAT_ID>selected</cfif>>#PROCESS_CAT#</option>
                                                    </cfoutput>
                                                </select>
                                            </div>
                                       	</div>
                                        <div class="form-group" id="item-fire">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="29629.Fire Fişi"> *</label>
                                            <div class="col col-8 col-xs-12">
                                            	<select name="process_cat2" id="process_cat2" style="width:150px;">
                                                    <option value="" selected><cf_get_lang dictionary_id ='57734.Seçiniz'></option>
                                                    <cfoutput query="get_user_process_cat2">
                                                        <option value="#PROCESS_CAT_ID#" <cfif get_defaults.FIRE_FIS eq PROCESS_CAT_ID>selected</cfif>>#PROCESS_CAT#</option>
                                                    </cfoutput>
                                                </select>
                                            </div>
                                       	</div>
                                   	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                                        <div class="form-group" id="item-control_type">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='37244.Palet'> <cf_get_lang dictionary_id='57633.Barkod'></label>
	                            			<div class="col col-8 col-xs-12">
                                            	<cfinput type="text" id="barcode"  maxlength="20" name="barcode" value="#get_defaults.palet_barcode#" style="width:130px">
                                          	</div>
                                     	</div>
                                   	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">

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
                        	<th style="text-align:center; width:20px" rowspan="2">
                            	 <a href="javascript:add_row_emp();"><img src="/images/plus_list.gif"  border="0" title="<cf_get_lang dictionary_id='44630.Ekle'>"></a>
                                <input type="hidden" name="record_num_emp" id="record_num_emp" value="<cfoutput>#get_emp_wm_defaults.recordcount#</cfoutput>">
                            </th>
                            <th style="text-align:center; width:30px" rowspan="2"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th style="text-align:center; width:250px" rowspan="2"><cf_get_lang dictionary_id='44688.Çalışan Adı'></th>
                        	<th style="text-align:center;" colspan="4"><cf_get_lang dictionary_id='58763.Depo'> / <cf_get_lang dictionary_id='30031.Lokasyon'></th>
                            <th style="text-align:center;" colspan="4"><cf_get_lang dictionary_id='1354.Emirler Sayfa Yetkisi'></th>
                        </tr>
                        <tr>
                        	
                            <th style="text-align:center; width:280px" ><cf_get_lang dictionary_id='573.Default Üretim Depo'></th>
                            <th style="text-align:center; width:290px" ><cf_get_lang dictionary_id='1334.Default Paletleme Depo'></th>
                            <th style="text-align:center; width:290px" ><cf_get_lang dictionary_id='1335.Default WM Depo'></th>
                            <th style="text-align:center; width:290px" ><cf_get_lang dictionary_id='1336.Default Sevkiyat Alanı'></th>
                            
                            <th style="text-align:center; width:30px" title="TRANSFER DEPO EMİRLERİ">
                            	<div class="icon">
                                    <img src="css/assets/icons/catalyst-icon-svg/ctl-trucking.svg" width="30px" height="30px">
                                </div>
                            </th>
                            <th style="text-align:center; width:30px" title="STOKLAMA RAF EMİRLERİ">
                            	<div class="icon">
                                    <img src="css/assets/icons/catalyst-icon-svg/ctl-016-loader.svg" width="30px" height="30px">
                                </div>
                            </th>
                            <th style="text-align:center; width:30px" title="TOPLAMA RAF EMİRLERİ">
                            	<div class="icon">
                                    <img src="css/assets/icons/catalyst-icon-svg/ctl-016-loader.svg" width="30px" height="30px">
                                </div>
                            </th>
                            <th style="text-align:center; width:30px" title="SEVKİYAT EMİRLERİ">
                            	<div class="icon">
                                    <img src="css/assets/icons/catalyst-icon-svg/ctl-packing-2.svg" width="30px" height="30px">
                                </div>
                            </th>
                    	</tr>
                	</thead>
                	<tbody name="new_row_emp" id="new_row_emp">
                    	<cfif get_emp_wm_defaults.recordcount>
                    		<cfoutput query="get_emp_wm_defaults">
                               	<tr name="frm_row_emp" id="frm_row_emp#currentrow#">
                                 	<td style="height:20px; text-align:center">
                                        <a style="cursor:pointer" onclick="sil_emp(#currentrow#);">
                                       	 	<img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>">
                                       	</a>
                                     	<input type="hidden" name="row_kontrol_emp#currentrow#" id="row_kontrol_emp#currentrow#" value="1">
                                    </td>
                                    <td style="text-align:right">#currentrow#</td>
                                    <td style="text-align:left">
                                    	<input type="hidden" name="employee_id_#currentrow#" id="employee_id_#currentrow#" value="#get_emp_wm_defaults.EMPLOYEE_POSITION_ID#">
                                     	<input type="text" name="employee_#currentrow#" id="employee_#currentrow#" value="#get_emp_wm_defaults.ADI# " style="width:235px;">
                                      	<a style="cursor:pointer" href"javascript://" onClick="pencere_ac_emp(#currentrow#);">
                                        	<img src="/images/plus_thin.gif" align="absmiddle" border="0">
                                       	</a>
                                    </td>
                                    <td style="text-align:left">
										<select name="product_#currentrow#" style="width:280px; height:20px">
                                        	<option value="">Seçiniz</option>
                                            <cfloop query="get_departments">
                                            	<option value="#Replace(get_departments.DEPARTMENT_LOCATION,'-',',')#" <cfif listlen(get_emp_wm_defaults.PRODUCTION_WAREHOUSE)><cfif ListgetAt(get_emp_wm_defaults.PRODUCTION_WAREHOUSE,1) eq get_departments.DEPARTMENT_ID and ListgetAt(get_emp_wm_defaults.PRODUCTION_WAREHOUSE,2) eq get_departments.LOCATION_ID>selected</cfif></cfif>>#get_departments.depo#</option>
                                            </cfloop>
                                        </select>
                                    </td>
                                    <td style="text-align:left">
                                    	<select name="paletting_#currentrow#" style="width:280px; height:20px">
                                        	<option value="">Seçiniz</option>
                                            <cfloop query="get_departments">
                                            	<option value="#Replace(get_departments.DEPARTMENT_LOCATION,'-',',')#" <cfif listlen(get_emp_wm_defaults.INTERMEDIATE_WAREHOUSE)><cfif ListgetAt(get_emp_wm_defaults.INTERMEDIATE_WAREHOUSE,1) eq get_departments.DEPARTMENT_ID and ListgetAt(get_emp_wm_defaults.INTERMEDIATE_WAREHOUSE,2) eq get_departments.LOCATION_ID>selected</cfif></cfif>>#get_departments.depo#</option>
                                            </cfloop>
                                        </select>
                                    </td>
                                    <td style="text-align:left">
                                    	<select name="wm_#currentrow#" style="width:280px; height:20px">
                                        	<option value="">Seçiniz</option>
                                            <cfloop query="get_departments">
                                            	<option value="#Replace(get_departments.DEPARTMENT_LOCATION,'-',',')#" <cfif listlen(get_emp_wm_defaults.SHELF_WAREHOUSE)><cfif ListgetAt(get_emp_wm_defaults.SHELF_WAREHOUSE,1) eq get_departments.DEPARTMENT_ID and ListgetAt(get_emp_wm_defaults.SHELF_WAREHOUSE,2) eq get_departments.LOCATION_ID>selected</cfif></cfif>>#get_departments.depo#</option>
                                            </cfloop>
                                        </select>
                                    </td>
                                    <td style="text-align:left">
                                    	<select name="shipping_#currentrow#" style="width:280px; height:20px">
                                        	<option value="">Seçiniz</option>
                                            <cfloop query="get_departments">
                                            	<option value="#Replace(get_departments.DEPARTMENT_LOCATION,'-',',')#" <cfif listlen(get_emp_wm_defaults.SHIPMENT_WAREHOUSE)><cfif ListgetAt(get_emp_wm_defaults.SHIPMENT_WAREHOUSE,1) eq get_departments.DEPARTMENT_ID and ListgetAt(get_emp_wm_defaults.SHIPMENT_WAREHOUSE,2) eq get_departments.LOCATION_ID>selected</cfif></cfif>>#get_departments.depo#</option>
                                            </cfloop>
                                        </select>
                                  	</td>
                                    <td style="text-align:left">
                                   		<input type="checkbox" name="select_1_#currentrow#" id="select_1_#currentrow#" value="1" <cfif ListLen(get_emp_wm_defaults.ORDER_PAGE_AUTHORITY) and ListFind(get_emp_wm_defaults.ORDER_PAGE_AUTHORITY,1)>checked</cfif>
                                  	</td>
                                    <td style="text-align:left">
                                   		<input type="checkbox" name="select_2_#currentrow#" id="select_2_#currentrow#" value="2" <cfif ListLen(get_emp_wm_defaults.ORDER_PAGE_AUTHORITY) and ListFind(get_emp_wm_defaults.ORDER_PAGE_AUTHORITY,2)>checked</cfif>
                                  	</td>
                                    <td style="text-align:left">
                                   		<input type="checkbox" name="select_3_#currentrow#" id="select_3_#currentrow#" value="3" <cfif ListLen(get_emp_wm_defaults.ORDER_PAGE_AUTHORITY) and ListFind(get_emp_wm_defaults.ORDER_PAGE_AUTHORITY,3)>checked</cfif>
                                  	</td>
                                    <td style="text-align:left">
                                   		<input type="checkbox" name="select_4_#currentrow#" id="select_4_#currentrow#" value="4" <cfif ListLen(get_emp_wm_defaults.ORDER_PAGE_AUTHORITY) and ListFind(get_emp_wm_defaults.ORDER_PAGE_AUTHORITY,4)>checked</cfif>
                                  	</td>
                              	</tr>
                         	</cfoutput>
                    	<cfelse>
                        </cfif>
                 	</tbody>
               	</cf_grid_list>
            </cf_basket>
 		</cfform>
   	</cf_box>
</div>
<script type="text/javascript">
	var row_count_emp=document.upd_e_wm_setup.record_num_emp.value;
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
		
		document.upd_e_wm_setup.record_num_emp.value = row_count_emp;
		newCell_emp = newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.style.textAlign = 'center';
		newCell_emp.innerHTML = '<input type="hidden" name="row_kontrol_emp' + row_count_emp +'" id="row_kontrol_emp' + row_count_emp +'" value="1"><a style="cursor:pointer" onclick="sil_emp(' + row_count_emp + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang_main no='51.Sil'>" border="0"></a>';	
		
		newCell_emp = newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.style.textAlign = 'right';
		newCell_emp.innerHTML = row_count_emp;
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute('nowrap','nowrap');
		newCell_emp.innerHTML = '<input type="hidden" name="employee_id_' + row_count_emp +'" id="employee_id_' + row_count_emp +'" value=""><input type="text" name="employee_' + row_count_emp +'" id="employee_' + row_count_emp +'" value="" style="width:235px;"> <a style="cursor:pointer" href"javascript://" onClick="pencere_ac_emp('+ row_count_emp +');"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>';
		
		newCell_emp = newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute("nowrap","nowrap");
		b = '<select name="product_' + row_count_emp +'" id="product_' + row_count_emp +'" style="width:280px; height:20px"><option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>';
		<cfoutput query="get_departments">
			b += '<option value="#Replace(get_departments.DEPARTMENT_LOCATION,'-',',')#">#get_departments.depo#</option>';
		</cfoutput>
		newCell_emp.innerHTML = b + '</select>';
		
		newCell_emp = newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute("nowrap","nowrap");
		b = '<select name="paletting_' + row_count_emp +'" id="paletting_' + row_count_emp +'" style="width:280px; height:20px"><option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>';
		<cfoutput query="get_departments">
			b += '<option value="#Replace(get_departments.DEPARTMENT_LOCATION,'-',',')#">#get_departments.depo#</option>';
		</cfoutput>
		newCell_emp.innerHTML = b + '</select>';
		
		newCell_emp = newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute("nowrap","nowrap");
		b = '<select name="wm_' + row_count_emp +'" id="wm_' + row_count_emp +'" style="width:280px; height:20px"><option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>';
		<cfoutput query="get_departments">
			b += '<option value="#Replace(get_departments.DEPARTMENT_LOCATION,'-',',')#">#get_departments.depo#</option>';
		</cfoutput>
		newCell_emp.innerHTML = b + '</select>';
		
		newCell_emp = newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute("nowrap","nowrap");
		b = '<select name="shipping_' + row_count_emp +'" id="shipping_' + row_count_emp +'" style="width:280px; height:20px"><option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>';
		<cfoutput query="get_departments">
			b += '<option value="#Replace(get_departments.DEPARTMENT_LOCATION,'-',',')#">#get_departments.depo#</option>';
		</cfoutput>
		newCell_emp.innerHTML = b + '</select>';
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute('nowrap','nowrap');
		newCell_emp.innerHTML = '<input type="checkbox" name="select_1_' + row_count_emp +'" id="select_1_' + row_count_emp +'" value="1">';
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute('nowrap','nowrap');
		newCell_emp.innerHTML = '<input type="checkbox" name="select_2_' + row_count_emp +'" id="select_2_' + row_count_emp +'" value="2">';
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute('nowrap','nowrap');
		newCell_emp.innerHTML = '<input type="checkbox" name="select_3_' + row_count_emp +'" id="select_3_' + row_count_emp +'" value="3">';
		
		newCell_emp=newRow_emp.insertCell(newRow_emp.cells.length);
		newCell_emp.setAttribute('nowrap','nowrap');
		newCell_emp.innerHTML = '<input type="checkbox" name="select_4_' + row_count_emp +'" id="select_4_' + row_count_emp +'" value="4">';
		
	}
	function pencere_ac_emp(no_emp)
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_code=employee_id_" + no_emp +"&field_name=employee_" + no_emp +"&select_list=1",'list','popup_list_positions');
	}

	function sil_emp(sy_emp)
	{
		
		var element_emp=eval("upd_e_wm_setup.row_kontrol_emp"+sy_emp);
		element_emp.value=0;
		var element_emp=eval("frm_row_emp"+sy_emp);
		element_emp.style.display="none";		
	} 
</script>