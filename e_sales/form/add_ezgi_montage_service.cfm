<!---<cfdump var="#attributes#">--->
<cfset attributes.start_date = wrk_get_today()>
<cfset attributes.start_date_1 = wrk_get_today()>
<!---<cfset attributes.start_date_2 = wrk_get_today()>--->
<cfset toplam_kayit = ListLen(attributes.CONVERT_EZGI_STOCKS_ID)>
<cfset toplam_tutar = 0>
<cfquery name="get_cat" datasource="#dsn3#">
	SELECT SERVICECAT_ID, SERVICECAT FROM SERVICE_APPCAT
</cfquery>
<cfquery name="get_substatus" datasource="#dsn3#">
	SELECT SERVICE_SUBSTATUS, SERVICE_SUBSTATUS_ID FROM SERVICE_SUBSTATUS
</cfquery>
<cfquery name="get_priority" datasource="#dsn#">
	SELECT PRIORITY_ID, PRIORITY, COLOR FROM SETUP_PRIORITY
</cfquery>
<cfquery name="get_add_options" datasource="#dsn3#">
	SELECT SERVICE_ADD_OPTION_ID, SERVICE_ADD_OPTION_NAME FROM SETUP_SERVICE_ADD_OPTIONS ORDER BY SERVICE_ADD_OPTION_ID
</cfquery>
<br>
<table class="dph">
  	<tr>
    	<cfoutput>
            <td class="dpht" style="text-align:center">
                <a href="javascript:gizle_goster_basket(detail_inv_menu);">&raquo;</a>#getLang('call',96)#</a> 
            </td>    
		</cfoutput>					
  	</tr>
</table>     
<cfform name="form_basket" method="post" action="#request.self#?fuseaction=service.emptypopup_add_ezgi_montage_service">
	<cfinput type="hidden" name="toplam_kayit" value="#toplam_kayit#">
	<cf_basket_form id="detail_inv_menu">     
        <cf_object_main_table>	
            <cf_object_table column_width_list="60,220">
                <cfsavecontent variable="header_"><cf_get_lang_main no='157.Görevli'></cfsavecontent>
                <cf_object_tr id="form_ul_virtual_offer_head" Title="#header_#">
                    <cf_object_td type="text"><cf_get_lang_main no='157.Görevli'>*</cf_object_td>
                    <cf_object_td colspan="3">
                      	<input type="hidden" name="task_emp_id" id="task_emp_id" value="">
                     	<input type="hidden" name="task_company_id" id="task_company_id" value="">
                    	<input type="hidden" name="task_partner_id" id="task_partner_id" value="">
                    	<cfinput type="text" name="task_person_name" id="task_person_name" value="" style="width:200px;  vertical-align:top" onFocus="AutoComplete_Create('task_person_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,3\',0,0','EMPLOYEE_ID,COMPANY_ID,PARTNER_ID','task_emp_id,task_company_id,task_partner_id','','3','250','return_company()');" >
                      	<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_positions&field_comp_id=form_basket.task_company_id&field_partner=form_basket.task_partner_id&field_name=form_basket.task_person_name&field_emp_id=form_basket.task_emp_id&select_list=1,2</cfoutput>&keyword='+encodeURIComponent(document.form_basket.task_person_name.value),'list');">
                        	<img src="/images/plus_thin.gif" border="0">
                      	</a>
                    </cf_object_td>
                </cf_object_tr>
            </cf_object_table>
	
            <cf_object_table column_width_list="50,140">
                <cfsavecontent variable="header_"><cf_get_lang_main no='1447.Süreç'></cfsavecontent>
                <cf_object_tr id="form_ul_virtual_offer_head" Title="#header_#">
                    <cf_object_td type="text"><cf_get_lang_main no='1447.Süreç'>*</cf_object_td>
                    <cf_object_td colspan="3">
                       <cf_workcube_process is_upd='0' process_cat_width='130' is_detail='0'>
                    </cf_object_td>
                </cf_object_tr>
            </cf_object_table>
	
            <cf_object_table column_width_list="90,90">
                <cfsavecontent variable="header_">Başvuru Tarihi</cfsavecontent>
                <cf_object_tr id="form_ul_virtual_offer_head" Title="#header_#">
                    <cf_object_td type="text">Başvuru Tarihi*</cf_object_td>
                    <cf_object_td colspan="3">
                       <cfinput type="text" name="start_date" value="#dateformat(attributes.start_date,'dd/mm/yyyy')#" validate="eurodate" maxlength="10" style="width:65px;">
                       <cf_wrk_date_image date_field="start_date">
                    </cf_object_td>
                </cf_object_tr>
            </cf_object_table>
            
            <cf_object_table column_width_list="90,90">
                <cfsavecontent variable="header_">Kabul Tarihi</cfsavecontent>
                <cf_object_tr id="form_ul_virtual_offer_head" Title="#header_#">
                    <cf_object_td type="text">Kabul Tarihi*</cf_object_td>
                    <cf_object_td colspan="3">
                       <cfinput type="text" name="start_date_1" value="#dateformat(attributes.start_date_1,'dd/mm/yyyy')#" validate="eurodate" maxlength="10" style="width:65px;">
                       <cf_wrk_date_image date_field="start_date_1">
                    </cf_object_td>
                </cf_object_tr>
            </cf_object_table>
            
            <!---<cf_object_table column_width_list="100,90">
                <cfsavecontent variable="header_">Müdehale Tarihi</cfsavecontent>
                <cf_object_tr id="form_ul_virtual_offer_head" Title="#header_#">
                    <cf_object_td type="text">Müdehale Tarihi*</cf_object_td>
                    <cf_object_td colspan="3">
                       <cfinput type="text" name="start_date_2" value="#dateformat(attributes.start_date_2,'dd/mm/yyyy')#" validate="eurodate" maxlength="10" style="width:65px;">
                       <cf_wrk_date_image date_field="start_date_2">
                    </cf_object_td>
                </cf_object_tr>
            </cf_object_table>--->
            <cf_object_table column_width_list="70,200">
                <cfsavecontent variable="header_">Açıklama</cfsavecontent>
                <cf_object_tr id="form_ul_virtual_offer_head" Title="#header_#">
                    <cf_object_td type="text">Açıklama*</cf_object_td>
                    <cf_object_td colspan="3">
                   		<textarea name="montage_detail" value="" maxlength="500" style="width:200px; height:25px"></textarea>
                    </cf_object_td>
                </cf_object_tr>
            </cf_object_table>
            
            <cf_object_table column_width_list="50">
                <cf_object_tr id="form_ul_virtual_offer_head">
                    <cf_object_td colspan="3">
                       <cf_workcube_buttons is_upd='0' add_function='control()'>
                    </cf_object_td>
                </cf_object_tr>
            </cf_object_table>

        </cf_object_main_table>
  	</cf_basket_form>
    <table id="sepet_table" align="center" cellpadding="0" cellspacing="0" style="table-layout:fixed; width:99%;">
        <tr valign="top" id="basket_tr">
            <td class="sepetim_td" width="100%">
                <table id="table_list" class="basket_list" cellpadding="0" cellspacing="0" width="100%">
                    <div id="sepetim" style="width:100%">
                        <thead>
                            <th style="width:20px;"><cf_get_lang_main no='75.No'></th>
                            <th style="width:60px;">Teklif <cf_get_lang_main no='75.No'></th>
                            <th style="width:230px;" >Ürün</th>
                            <th >Açıklama</th>
                            <th style="width:50px;"><cf_get_lang_main no='223.Miktar'></th>
                            <th style="width:170px;">Hizmet</th>
                            <th style="width:50px;"><cf_get_lang_main no='223.Miktar'></th>
                            <th style="width:40px;">Birim</th>
                            <th style="width:70px;"><cf_get_lang_main no='226.Birim Fiyat'></th>
                            <th style="width:70px;">Tutar</th>
                            <th style="width:110px;">
                            	<select name="cat_" id="cat_" style="width:110px; height:20px" onChange="cat_change(this.value)">
                                	<option value=""><cf_get_lang_main no='74.Kategori'></option>
                                	<cfoutput query="get_cat">
                                   		<option value="#SERVICECAT_ID#">#SERVICECAT#</option>
                                 	</cfoutput>
                             	</select>
                            </th>
                            <th style="width:70px;">
                            	<select name="priority_" id="priority_" style="width:70px; height:20px" onChange="priority_change(this.value)">
                                  	<option value=""><cf_get_lang_main no='73.Öncelik'></option>
                                  	<cfoutput query="get_priority">
                                     	<option value="#PRIORITY_ID#">#PRIORITY#</option>
                                  	</cfoutput>
                             	</select>
                            </th>
                            <th style="width:110px;">
                            	<select name="substatus_" id="substatus_" style="width:110px; height:20px" onChange="substatus_change(this.value)">
                                 	<option value=""><cf_get_lang_main no='70.Aşama'></option>
                                  	<cfoutput query="get_substatus">
                                     	<option value="#SERVICE_SUBSTATUS_ID#">#SERVICE_SUBSTATUS#</option>
                                   	</cfoutput>
                              	</select>
                            </th>
                            <th style="width:110px;">
                            	<select name="cat_" id="add_options_" style="width:110px; height:20px" onChange="add_options_change(this.value)">
                                	<option value=""><cf_get_lang_main no='2575.Servis Özel Tanım'></option>
                                	<cfoutput query="get_add_options">
                                   		<option value="#SERVICE_ADD_OPTION_ID#">#SERVICE_ADD_OPTION_NAME#</option>
                                 	</cfoutput>
                             	</select>
                            </th>
                        </thead>
                        <tbody name="new_row" id="new_row">
                        	<cfoutput>
                        	<cfif ListLen(attributes.CONVERT_EZGI_STOCKS_ID)>
                                <cfloop from="1" to="#toplam_kayit#" index="i">
                                	<cfset crow = ListGetAt(attributes.CONVERT_EZGI_STOCKS_ID,i)>
                                	<cfset ezgiid = ListFirst(crow,'_')>
                                    <cfset stockid = ListGetat(crow,2,'_')>
                                    <cfset miktar = ListGetAt(CONVERT_AMOUNT_EZGI_STOCKS_ID,i)>
                                    <cfquery name="get_service" datasource="#dsn3#">
                                        SELECT  * FROM  EZGI_ORGE_RELATIONS WHERE EZGI_ID = #ezgiid#
                                    </cfquery>
									<cfquery name="get_hizmet_info" datasource="#dsn3#">
                                    	SELECT     
                                        	EMR.STOCK_ID, 
                                            EMR.PRODUCT_NAME, 
                                            EMR.AMOUNT, 
                                            EMR.MAIN_UNIT, 
                                            ISNULL(TBL2.PRICE, 0) AS PRICE, 
                                            TBL2.MONEY
										FROM        
                                        	EZGI_MONTAGE_ROW AS EMR INNER JOIN
                  							#dsn1_alias#.STOCKS AS S ON EMR.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
                      						(
                                            	SELECT     
                                                	PRODUCT_ID, 
                                                    PRICE, 
                                                    MONEY
                       							FROM        
                                                	#dsn1_alias#.PRICE_STANDART
                       							WHERE    
                                                	PRICESTANDART_STATUS = 1 AND 
                                                    PURCHASESALES = 0
                                         	) AS TBL2 ON S.PRODUCT_ID = TBL2.PRODUCT_ID
										WHERE     
                                        	EMR.EZGI_ID = #ezgiid# AND 
                                            EMR.STOCK_ID = #stockid#
                                    </cfquery>
                                    <input type="hidden" name="ezgi_id_#i#" value="#ezgiid#">
                                    <input type="hidden" name="stock_id_#i#" value="#stockid#">
                                    <tr id="frm_row#crow#">
                                        <td style="text-align:right">#i#</td>
                                        <td style="text-align:center;">#get_service.VIRTUAL_OFFER_NUMBER#</td>
                                        <td style="text-align:left;">#get_service.NAME_PRODUCT#</td>
                                        <td>#Left(get_service.PRODUCT_NAME2,40)#<cfif Len(get_service.PRODUCT_NAME2) gt 40>...</cfif></td>
                                        <td style="text-align:right">
                                        	<input type="text" name="miktar_#i#" id="miktar_#i#" value="#AmountFormat(miktar,2)#" class="box" readonly style="width:50px">
                                        </td>
                                        <td>#get_hizmet_info.PRODUCT_NAME#</td>
                                        
                                        <td style="text-align:right">
                                        	<input type="text" name="amount_#i#" id="amount_#i#" value="#AmountFormat(get_hizmet_info.amount*miktar,2)#" class="box" readonly style="width:50px">
                                        </td>
                                        <td>#get_hizmet_info.MAIN_UNIT#</td>
                                        <td style="text-align:right">
                                        	<input type="text" name="price_#i#" id="price_#i#" value="#TlFormat(get_hizmet_info.PRICE)#" style="width:70px; text-align:right" onChange="hesapla(#i#)">
                                        </td>
                                        <td style="text-align:right">
                                        	<input type="text" name="total_#i#" id="total_#i#" value="#TlFormat(get_hizmet_info.PRICE*get_hizmet_info.amount*miktar)#" class="box" style="width:70px" readonly>
                                        </td>
                                        <td>
                                            <select name="cat_#i#" id="cat_#i#" style="width:110px; height:20px">
                                            	<option value=""><cf_get_lang_main no='74.Kategori'></option>
                                                <cfloop query="#get_cat#">
                                                    <option value="#SERVICECAT_ID#">#SERVICECAT#</option>
                                                </cfloop>
                                            </select>
                                        </td>
                                        <td>
                                            <select name="priority_#i#" id="priority_#i#" style="width:70px; height:20px">
                                            	<option value=""><cf_get_lang_main no='73.Öncelik'></option>
                                                <cfloop query="#get_priority#">
                                                    <option value="#PRIORITY_ID#">#PRIORITY#</option>
                                                </cfloop>
                                            </select>
                                        </td>
                                        <td>
                                            <select name="substatus_#i#" id="substatus_#i#" style="width:110px; height:20px">
                                            	<option value=""><cf_get_lang_main no='70.Aşama'></option>
                                                <cfloop query="#get_substatus#">
                                                    <option value="#SERVICE_SUBSTATUS_ID#">#SERVICE_SUBSTATUS#</option>
                                                </cfloop>
                                            </select>
                                        </td>
                                        <td>
                                            <select name="add_options_#i#" id="add_options_#i#" style="width:110px; height:20px">
                                            	<option value=""><cf_get_lang_main no='2575.Servis Özel Tanım'></option>
                                                <cfloop query="#get_add_options#">
                                                    <option value="#SERVICE_ADD_OPTION_ID#">#SERVICE_ADD_OPTION_NAME#</option>
                                                </cfloop>
                                            </select>
                                        </td>
                                    </tr>
                                    <cfset toplam_tutar = toplam_tutar + (get_hizmet_info.PRICE*get_hizmet_info.amount*miktar)>
                                </cfloop>
                            </cfif>
                            </cfoutput>
                       	</tbody>
                    </div>
                    <tfoot>
                    	<tr>
                        	<td colspan="9" style="text-align:right; font-weight:bold; padding-right:10px">Toplam</td>
                            <td style="text-align:right; font-weight:bold">
                            	<input type="text" name="toplam_tutar" id="toplam_tutar" value="<cfoutput>#Tlformat(toplam_tutar,2)#</cfoutput>" class="box" readonly style="width:50px; font-weight:bold; padding-right:2px">
                            </td>
                           <td colspan="4"></td> 
                    </tfoot>
                </table>
            </td>
        </tr>
    </table>
</cfform>
<script language="javascript">
	function cat_change(cat_id)
	{
		<cfoutput>
			<cfloop from="1" to="#toplam_kayit#" index="c">
				document.getElementById('cat_#c#').value = cat_id;
			</cfloop>	
		</cfoutput>
	}
	function priority_change(priority_id)
	{
		<cfoutput>
			<cfloop from="1" to="#toplam_kayit#" index="c">
				document.getElementById('priority_#c#').value = priority_id;
			</cfloop>	
		</cfoutput>
	}
	function substatus_change(substatus_id)
	{
		<cfoutput>
			<cfloop from="1" to="#toplam_kayit#" index="c">
				document.getElementById('substatus_#c#').value = substatus_id;
			</cfloop>	
		</cfoutput>
	}
	function add_options_change(add_options_id)
	{
		<cfoutput>
			<cfloop from="1" to="#toplam_kayit#" index="c">
				document.getElementById('add_options_#c#').value = add_options_id;
			</cfloop>	
		</cfoutput>
	}
	function hesapla(row_)
	{
		toplam_ttr = 0;
		<cfoutput>
			<cfloop from="1" to="#toplam_kayit#" index="c">
				toplam_row = parseFloat(filterNum(document.getElementById('miktar_#c#').value,2))*parseFloat(filterNum(document.getElementById('amount_#c#').value,2))*parseFloat(filterNum(document.getElementById('price_#c#').value,2));
				document.getElementById('total_#c#').value = commaSplit(toplam_row,2);
				toplam_ttr = toplam_ttr + toplam_row;
			</cfloop>	
		</cfoutput>
		document.getElementById('toplam_tutar').value = commaSplit(toplam_ttr,2);
	}
	function control()
	{
		if(document.getElementById('task_person_name').value == '')
		{
			alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='157.Görevli'>.");
			document.getElementById('task_person_name').focus();
			return false;
		}
		if(document.getElementById('start_date').value == '')
		{
			alert("<cf_get_lang_main no='59.Eksik Veri'> : Başvuru Tarihi.");
			document.getElementById('start_date').focus();
			return false;
		}
		if(document.getElementById('start_date_1').value == '')
		{
			alert("<cf_get_lang_main no='59.Eksik Veri'> : Kabul Tarihi.");
			document.getElementById('start_date_1').focus();
			return false;
		}
		if(document.getElementById('start_date_2').value == '')
		{
			alert("<cf_get_lang_main no='59.Eksik Veri'> : Müdehale Tarihi.");
			document.getElementById('start_date_2').focus();
			return false;
		}
		<cfoutput>
			<cfloop from="1" to="#toplam_kayit#" index="c">
				if(document.getElementById('cat_#c#').value == '')
				{
					alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='74.Kategori'>.");
					document.getElementById('cat_#c#').focus();
					return false;
				}
				if(document.getElementById('substatus_#c#').value == '')
				{
					alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='70.Aşama'>.");
					document.getElementById('substatus_#c#').focus();
					return false;
				}
				if(document.getElementById('priority_#c#').value == '')
				{
					alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='73.Öncelik'>.");
					document.getElementById('priority_#c#').focus();
					return false;
				}
				if(document.getElementById('add_options_#c#').value == '')
				{
					alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='2575.Servis Özel Tanım'>.");
					document.getElementById('add_options_#c#').focus();
					return false;
				}
			</cfloop>	
		</cfoutput>
		if(process_cat_control())
			return true;
		else
			return false;
	}
</script>