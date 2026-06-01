<!---
    File: upd_ezgi_iflow_production_operation_result.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->


<cfset module_name="prod">
<cfset station_type = 2>
<cfquery name="get_production_operations" datasource="#dsn3#">
	SELECT 
    	EOM.LOT_NO, 
        EOM.P_ORDER_NO, 
        EOM.P_ORDER_ID,
        EOM.IS_STAGE, 
        EOM.STOCK_CODE, 
      	EOM.STOCK_ID,
        EOM.PRODUCT_ID, 
        EOM.PRODUCT_NAME, 
        EOM.P_OPERATION_ID, 
        EOM.OPERATION_TYPE_ID, 
        EOM.OPERATION_CODE, 
        EOM.OPERATION_TYPE, 
        EOM.AMOUNT, 
     	EOM.STAGE, 
        ISNULL(EOM.REAL_TIME,0) REAL_TIME, 
        ISNULL(EOM.WAIT_TIME,0) WAIT_TIME,
        EOM.ACTION_EMPLOYEE_ID,
        DateAdd(hour,#session.ep.time_zone#,EOM.ACTION_START_DATE) AS ACTION_START_DATE,
        EOM.O_STATION_IP,
        EOM.STATION_ID,
        EOM.OPERATION_RESULT_ID,
        ISNULL(EOM.REAL_AMOUNT,0) REAL_AMOUNT, 
        EOM.LOSS_AMOUNT, 
        EOM.STATION_NAME,
        ISNULL((SELECT SUM(REAL_AMOUNT) AS REAL_AMOUNT FROM EZGI_OPERATION_M WHERE P_OPERATION_ID=EOM.P_OPERATION_ID),0) TOTAL_AMOUNT,
        ISNULL((SELECT TIME_COST_ID FROM #dsn_alias#.TIME_COST WHERE P_OPERATION_RESULT_ID = 6120 AND OUR_COMPANY_ID = #session.ep.company_id#),0) AS TIME_COST_ID,
        (SELECT DateAdd(hour,#session.ep.time_zone#,UPDATE_DATE) AS UPDATE_DATE FROM PRODUCTION_OPERATION_RESULT WHERE OPERATION_RESULT_ID = EOM.OPERATION_RESULT_ID) AS UPDATE_DATE
	FROM            
    	PRODUCTION_ORDERS AS PO INNER JOIN
     	EZGI_IFLOW_PRODUCTION_ORDERS AS E ON PO.LOT_NO = E.LOT_NO INNER JOIN
		EZGI_OPERATION_M AS EOM ON PO.P_ORDER_ID = EOM.P_ORDER_ID
	WHERE 
    	EOM.OPERATION_RESULT_ID = #attributes.upd_id#
</cfquery>
<cfif get_production_operations.TIME_COST_ID gt 0>
	<script type="text/javascript">
		alert("Operasyon Sonucu Proje İşler Bölümünde Zaman Harcamasına Bağlıdır. Öncelikle İptal Ederek Düzenlemeye Gidebilirsiniz.");
	</script>
</cfif>
<cfquery name="get_employee" datasource="#dsn3#">
	SELECT     
    	EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ADI,
      	EMPLOYEE_ID AS EMP_ID
	FROM        
    	CatalystFurmet.EMPLOYEES AS E
	WHERE     
    	EMPLOYEE_STATUS = 1
</cfquery>
<cfquery name="get_stations" datasource="#dsn3#">
	SELECT 
    	STATION_ID, 
        UP_STATION, 
        STATION_NAME 
  	FROM 
    	WORKSTATIONS 
  	WHERE 
    	STATION_ID IN
        			(
                    	SELECT 
                        	WS_ID
						FROM     
                        	WORKSTATIONS_PRODUCTS
						WHERE  
                        	OPERATION_TYPE_ID = #get_production_operations.OPERATION_TYPE_ID#
                    ) 
  	ORDER BY
    	UP_STATION, 
        STATION_NAME
</cfquery>
<cfquery name="get_partner" datasource="#dsn3#">
	SELECT 
    	EO.EMPLOYEE_ID, 
        E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS ADI
	FROM     
    	EZGI_OPERATION_TIME_COST AS EO INNER JOIN
        #dsn_alias#.EMPLOYEES AS E ON EO.EMPLOYEE_ID = E.EMPLOYEE_ID
	WHERE  
    	EO.OPERATION_RESULT_ID = #attributes.upd_id# AND
        EO.EMPLOYEE_ID <> #get_production_operations.ACTION_EMPLOYEE_ID#
	ORDER BY 
    	EO.EZGI_OPERATION_TIME_COST_ID
</cfquery>
<cfsavecontent variable="right"></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="module"><cf_get_lang dictionary_id='36387.Operasyon Güncelle'></cfsavecontent>
	<cf_box title="#module#" right_images="#right#">
		<cfform name="upd_operation" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_iflow_production_order_result">
        	<cfinput type="hidden" name="upd_id" value="#attributes.upd_id#">
            <cfinput type="hidden" name="operation_id" value="#get_production_operations.P_OPERATION_ID#">
        	<cf_box_elements>
            	<div class="col col-6 col-md-6 col-sm-8 col-xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="surec" style="display:none">
                      	<cf_workcube_process_cat slct_width="140">
    					<cf_workcube_process is_upd='0' process_cat_width='130' is_detail='0'>
                	</div>
                	<div class="form-group" id="lotno" style="height:30px">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36698.Lot No'></label>
                     	<div class="col col-8 col-xs-12">
                        	<label class="col col-8 col-xs-12"><cfoutput>#get_production_operations.LOT_NO#</cfoutput></label>
                     	</div>
                	</div>
                    <div class="form-group" id="porderno" style="height:30px">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29474.Emir No'></label>
                     	<div class="col col-8 col-xs-12">
                        	<label class="col col-8 col-xs-12"><cfoutput>#get_production_operations.P_ORDER_NO#</cfoutput></label>
                     	</div>
                	</div>
                    <div class="form-group" id="pname" style="height:30px">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58221.Ürün Adı'></label>
                     	<div class="col col-8 col-xs-12">
                        <label class="col col-8 col-xs-12"><cfoutput>#get_production_operations.PRODUCT_NAME#</cfoutput></label>
                     	</div>
                	</div>
                    <div class="form-group" id="islem" style="height:30px">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57692.İşlem'></label>
                     	<div class="col col-8 col-xs-12">
                        <label class="col col-8 col-xs-12"><cfoutput>#get_production_operations.OPERATION_TYPE#</cfoutput></label>
                     	</div>
                	</div>
                    <div class="form-group" id="amount" style="height:30px">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='60554.Operasyon Miktarı'>	 / <cf_get_lang dictionary_id='36608.Üretilen'></label>
                     	<div class="col col-4 col-xs-12">
                        	<label class="col col-8 col-xs-12"><cfoutput>#TlFormat(get_production_operations.AMOUNT,8)#</cfoutput></label>
                     	</div>
                        <div class="col col-4 col-xs-12">
                        	<label class="col col-8 col-xs-12"><cfoutput>#TlFormat(get_production_operations.TOTAL_AMOUNT-get_production_operations.REAL_AMOUNT,8)#</cfoutput></label>
                           	<cfinput name="kalan" id="kalan" type="hidden" value="#get_production_operations.TOTAL_AMOUNT-get_production_operations.REAL_AMOUNT#"> 
                     	</div>
                	</div>
                    <div class="form-group" id="gerceklestiren" style="height:30px">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36519.Gerçekleştiren'></label>
                     	<div class="col col-7 col-xs-12">
                        	<select name="employee_id" id="employee_id" style="width:200px; height:20px">
								<cfoutput query="get_employee">
                                 	<option value="#get_employee.EMP_ID#" <cfif get_production_operations.ACTION_EMPLOYEE_ID eq get_employee.EMP_ID>selected</cfif>>#ADI#</option>
                              	</cfoutput>
                       		</select>
                     	</div>
                        <div class="col col-1 col-xs-12">
                        	<i onClick="add_eployee()" class="fa fa-plus" title="Partner Ekle" alt="Partner Ekle"></i>
                     	</div>
                	</div>
                    <div class="form-group" id="station" style="height:30px">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58834.İstasyon'></label>
                     	<div class="col col-8 col-xs-12">
                        	<select name="station_id" id="station_id" style="width:200px; height:20px">
								<cfoutput query="get_stations">
                                 	<option value="#STATION_ID#" <cfif get_production_operations.STATION_ID eq get_stations.STATION_ID>selected</cfif>>#STATION_NAME#</option>
                            	</cfoutput>
                         	</select>
                     	</div>
                	</div>
                    <div class="form-group" id="tarih" >
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='55154.İşe Başlama Tarihi'></label>
                     	<div class="col col-4 col-xs-12">
                        	<div class="input-group x-14">
                        		<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
								<cfinput type="text" name="action_date" id="action_date" placeholder="#message#" value="#DateFormat(get_production_operations.ACTION_START_DATE, dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10">
                            	<span class="input-group-addon"><cf_wrk_date_image date_field="action_date"></span>
                            </div>
                     	</div>
                        <cfset action_date_h = TimeFormat(get_production_operations.ACTION_START_DATE,'HH')>
                    	<cfset action_date_m = TimeFormat(get_production_operations.ACTION_START_DATE,'MM')>
                        <div class="col col-2 col-xs-12">
                        	<cfoutput>
                        	<select name="action_date_h" id="action_date_h" style="width:45px; height:20px">
                                	<cfloop from="0" to="23" index="h">
                                    	<cfif len(h) eq 1>
                                        	<cfset hh = '0#h#'>
                                        <cfelse>
                                        	<cfset hh = h>
                                        </cfif>
                                    	<option value="#hh#" <cfif action_date_h eq hh>selected</cfif>>#hh#</option>
                                    </cfloop>
                          	</select>
                            </cfoutput>
                      	</div>
                        <div class="col col-2 col-xs-12">
                        	<cfoutput>
                        	<select name="action_date_m" id="action_date_m" style="width:45px; height:20px">
                             	<cfloop from="0" to="59" index="m">
                               		<cfif len(m) eq 1>
                                    	<cfset mm = '0#m#'>
                                 	<cfelse>
                                   		<cfset mm = m>
                                  	</cfif>
                                 	<option value="#mm#" <cfif action_date_m eq mm>selected</cfif>>#mm#</option>
                               	</cfloop>
                         	</select>
                            </cfoutput>
                        </div>
                    </div>
                 	<div class="form-group" id="son_tarih" >
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='62619.İşin Bitiş Tarihi'></label>
                     	<div class="col col-4 col-xs-12">
                        	<div class="input-group x-14">
                        		<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
								<cfinput type="text" name="end_date" id="end_date" placeholder="#message#" value="#DateFormat(get_production_operations.UPDATE_DATE, dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10">
                            	<span class="input-group-addon"><cf_wrk_date_image date_field="end_date"></span>
                            </div>
                     	</div>
                        <cfset end_date_h = TimeFormat(get_production_operations.UPDATE_DATE,'HH')>
                    	<cfset end_date_m = TimeFormat(get_production_operations.UPDATE_DATE,'MM')>
                        <div class="col col-2 col-xs-12">
                        	<cfoutput>
                        	<select name="end_date_h" id="end_date_h" style="width:45px; height:20px">
                                	<cfloop from="0" to="23" index="h">
                                    	<cfif len(h) eq 1>
                                        	<cfset hh = '0#h#'>
                                        <cfelse>
                                        	<cfset hh = h>
                                        </cfif>
                                    	<option value="#hh#" <cfif end_date_h eq hh>selected</cfif>>#hh#</option>
                                    </cfloop>
                          	</select>
                            </cfoutput>
                      	</div>
                        <div class="col col-2 col-xs-12">
                        	<cfoutput>
                        	<select name="end_date_m" id="end_date_m" style="width:45px; height:20px">
                             	<cfloop from="0" to="59" index="m">
                               		<cfif len(m) eq 1>
                                    	<cfset mm = '0#m#'>
                                 	<cfelse>
                                   		<cfset mm = m>
                                  	</cfif>
                                 	<option value="#mm#" <cfif end_date_m eq mm>selected</cfif>>#mm#</option>
                               	</cfloop>
                         	</select>
                            </cfoutput>
                        </div>
                	</div>
                    <div class="form-group" id="sure">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36512.Gerçekleşen Süre'></label>
                     	<div class="col col-8 col-xs-12">
                        	<cfinput name="real_time" id="real_time" type="text" style="width:85px; text-align:right" value="#get_production_operations.real_time#">
                     	</div>
                	</div>
                    <div class="form-group" id="miktar">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='62566.Gerçekleşen Operasyon Miktarı'></label>
                     	<div class="col col-8 col-xs-12">
                        	<cfif get_production_operations.REAL_AMOUNT eq 0>
                             	<cfset uretim_miktar = get_production_operations.AMOUNT>	
                          	<cfelse>
                             	<cfset uretim_miktar = get_production_operations.REAL_AMOUNT>
                          	</cfif>
                        	<cfinput name="amount" id="amount" type="text" style="width:85px; text-align:right" value="#TlFormat(uretim_miktar,8)#">
                     	</div>
                	</div>
                    <div class="form-group" id="durum">
                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57756.Durum'></label>
                     	<div class="col col-8 col-xs-12">
                        	<select name="stage" id="stage" style="width:200px; height:20px">
                             	<option value="0" <cfif get_production_operations.STAGE eq 0>selected</cfif>><cf_get_lang dictionary_id='476.Başlamadı'></option>
								<option value="1" <cfif get_production_operations.STAGE eq 1>selected</cfif>><cf_get_lang dictionary_id='398.Başladı'></option>
								<option value="3" <cfif get_production_operations.STAGE eq 3>selected</cfif>><cf_get_lang dictionary_id='305.Bitti'></option>
                         	</select>
                     	</div>
                	</div>
           		</div>
                <div class="col col-6 col-md-5 col-sm-8 col-xs-12" type="column" index="2" sort="true">
                	<div class="form-group" id="durum">
                    	<div class="col col-12 col-xs-12">
                        	<legend id="legenalan" style="height:173px; width:100%; border:none">
                            	<li>
                                	<b>Dikkat :</b> Yapılacak Değişiklik Sadece Operasyon Değerleri Üzerinde Etkilidir. Üretim Sonucuna ait Kayıtları İş Emri Üzerinden Doğrulamalısınız.
                                </li>
                            </legend>
                        </div>
                    </div>
                    <div class="form-group" id="partner">
                    	<div class="col col-12 col-xs-12">
                        	<table style="height:200px; width:100%" cellpadding="0" cellspacing="0" border="1" bordercolor="#E4E4E4">
                            	<tr>
                                	<td style="width:100%; height:100%" valign="top">
                                        <cf_form_list id="_aksesuar">
                                            <thead>
                                                <tr>
                                                    <th width="20px" style="text-align:center">
                                                    	<cfinput type="hidden" name="record_num" id="record_num" value="#get_partner.recordcount#">
                                                    </th>
                                                    <th width="100%" nowrap="nowrap">Parner Adı Soyadı</th>
                                                </tr>
                                            </thead>
                                            <tbody name="new_row" id="new_row">
                                                <cfif get_partner.recordcount>
                                                    <cfoutput query="get_partner">
                                                        <tr name="frm_row" id="frm_row#currentrow#">
                                                            <td style="text-align:center">
                                                                <a style="cursor:pointer" onclick="sil(#currentrow#);">
                                                                    <img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0">
                                                                </a>
                                                                <input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                                                            </td>
                                                            <td><input type="text" name="employee_name_#currentrow#" id="employee_name_#currentrow#" value="#get_partner.ADI#"></td>
                                                            <input type="hidden" name="employee_id_#currentrow#" id="employee_id_#currentrow#" value="#get_partner.employee_id#">
                                                        </tr>
                                                    </cfoutput>
                                                </cfif>
                                            </tbody>
                                     	</cf_form_list>
                             		</td>
                            	</tr>
                            </table>
                        </div>
                    </div>
                </div>
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-12">
                	<cfif get_production_operations.TIME_COST_ID eq 0>
						<cfif get_production_operations.REAL_AMOUNT eq 0>
                            <cf_workcube_buttons 
                                    is_upd='1' 
                                    is_delete = '1' 
                                    add_function='kontrol()'>
    
                        <cfelse>
                            <cf_workcube_buttons 
                                    is_upd='1' 
                                    is_delete = '0' 
                                    add_function='kontrol()'>
                        </cfif>
                    </cfif>
                </div>
            </cf_box_footer>
      	</cfform>
  	</cf_box>
</div>
<script type="text/javascript">
	var row_count=document.upd_operation.record_num.value;
	function kontrol()
	{	
		if(document.getElementById("amount").value <= 0)
		{
			alert("<cf_get_lang dictionary_id='540.Üretim 0 dan büyük olmalıdır.'> !");
			document.getElementById('amount').focus();
			return false;
		}
		if(document.getElementById("action_date").value <= 0)
		{
			alert("<cf_get_lang dictionary_id='541.Tarih Değerini Kontrol Ediniz.'> !");
			document.getElementById('action_date').focus();
			return false;
		}
		if(document.getElementById("end_date").value <= 0)
		{
			alert("<cf_get_lang dictionary_id='541.Tarih Değerini Kontrol Ediniz.'> !");
			document.getElementById('end_date').focus();
			return false;
		}
		
	}
	function add_eployee()
	{
		employee_id = document.getElementById('employee_id').value;
		<cfoutput query="get_employee">
			worker_employee_id = #get_employee.EMP_ID#;
			if(employee_id==worker_employee_id)
				employee_name =	'#get_employee.ADI#';
		</cfoutput>
		row_count++;
		var newRow;
		var newCell;
		newRow = document.getElementById("new_row").insertRow(document.getElementById("new_row").rows.length);
		newRow.className = 'color-row';
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);
		newRow.setAttribute("NAME","frm_row" + row_count);
		newRow.setAttribute("ID","frm_row" + row_count);
		document.upd_operation.record_num.value = row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a>';	
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'" id="row_kontrol'+row_count+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="text" name="employee_name_' + row_count + '" id="employee_name_' + row_count + '" value="'+employee_name+'"><input type="hidden" name="employee_id_' + row_count + '" id="employee_id_' + row_count + '" value="'+employee_id+'">';
	}
	
	function sil(sy)
	{
	
		var element=eval("upd_operation.row_kontrol"+sy);
		element.value=0;
		var element=eval("frm_row"+sy); 
		element.style.display="none";		
	} 
</script>