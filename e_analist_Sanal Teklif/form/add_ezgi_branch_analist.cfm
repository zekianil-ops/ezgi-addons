<cfparam name="attributes.detail" default="">
<cfparam name="attributes.analyst_status" default="">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.rate" default="20">
<cfparam name="attributes.start_date" default="">
<cfsetting showdebugoutput="yes">
<cfif isdefined("attributes.start_date") and isdate(attributes.start_date)>
	<cf_date tarih="attributes.start_date">
<cfelse>
	<cfset attributes.start_date = wrk_get_today()>
</cfif>
<cfquery name="get_period" datasource="#dsn#">
	SELECT        
    	TOP (5) PERIOD_YEAR
	FROM            
    	SETUP_PERIOD
	WHERE        
    	OUR_COMPANY_ID = #session.ep.company_id#
	ORDER BY 
    	PERIOD_YEAR DESC
</cfquery>
<cfquery name="get_branch" datasource="#dsn#">
	SELECT BRANCH_ID,BRANCH_NAME FROM BRANCH WHERE COMPANY_ID = #session.ep.company_id# ORDER BY BRANCH_NAME
</cfquery>
<cfquery name="get_price_cat" datasource="#dsn3#">
	SELECT PRICE_CATID, BRANCH, PRICE_CAT FROM PRICE_CAT WHERE PRICE_CAT_STATUS = 1 AND IS_SALES = 1
</cfquery>
<cf_catalystHeader>
<div class="col col-12 col-xs-12">
	<cf_box>
    	<cfform name="add_branch_analist" method="post" action="#request.self#?fuseaction=report.emptypopup_add_ezgi_branch_analist">
        	<input type="hidden" name="basket_due_value" value="" />
        	<cf_box_elements>
            	<cfoutput>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="item-item-process_id_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang_main no='642.Süreç/Asama'></label>
                      	<div class="col col-8 col-xs-12">
                        	<cf_workcube_process is_upd='0' process_cat_width='125' is_detail='0'>
                      	</div>
               		</div>
                	<div class="form-group" id="item-item-date_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="30631.Tarih"> *</label>
                      	<div class="col col-8 col-xs-12" id="item-date">
                        	<div class="input-group x-14">
                                <cfsavecontent variable="message"><cf_get_lang_main no='1091.Lütfen Tarih Giriniz'></cfsavecontent>
                                 <cfinput type="text" name="start_date"  value="#dateformat(attributes.start_date,'dd/mm/yyyy')#" validate="eurodate" maxlength="10" message="#message#" style="width:65px;">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                         	</div>
                     	</div>
               		</div>
                	<div class="form-group" id="item-is_branch_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='64164.Analiz Metodu'> </label>
                      	<div class="col col-8 col-xs-12">
                        	<select name="is_branch" id="is_branch" style="width:95px; height:20px">
                             	<option value="1"><cf_get_lang_main no='41.Sube'></option>
                             	<option value="0"><cf_get_lang_main no='1161.Merkez'></option>
                         	</select>
                     	</div>
               		</div>	
                    <div class="form-group" id="item-item-branch_id_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57453.Şube'> </label>
                      	<div class="col col-8 col-xs-12">
                         	<select name="branch_id" id="branch_id" style="width:80px;height:20px">
                             	<option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                              	<cfloop query="get_branch">
                                 	<option value="#branch_id#" <cfif isdefined("attributes.branch_id") and branch_id eq attributes.branch_id>selected</cfif>>#branch_name#</option>
                             	</cfloop>
                        	</select> 
                     	</div>
               		</div>
                    
                    <div class="form-group" id="item-item-year_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58455.Yıl'> </label>
                      	<div class="col col-8 col-xs-12">
                        	<select name="year_value" id="year_value" style="width:65px; height:20px">
                           		<cfloop query="get_period">
                                 	<option value="#PERIOD_YEAR#">#PERIOD_YEAR#</option>
                              	</cfloop>
                          	</select> 
                     	</div>
               		</div>
                    
                    <div class="form-group" id="item-item-month_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58724.Ay'> </label>
                      	<div class="col col-8 col-xs-12">
                            	<select name="month_value" id="month_value" style="width:65px; height:20px">
                                	<option value="1"><cf_get_lang_main no='180.Ocak'></option>
                                	<option value="2"><cf_get_lang_main no='181.Şubat'></option>
                                    <option value="3"><cf_get_lang_main no='182.Mart'></option>
                                    <option value="4"><cf_get_lang_main no='183.Nisan'></option>
                                    <option value="5"><cf_get_lang_main no='184.Mayıs'></option>
                                    <option value="6"><cf_get_lang_main no='185.Haziran'></option>
                                    <option value="7"><cf_get_lang_main no='186.Temmuz'></option>
                                    <option value="8"><cf_get_lang_main no='187.Ağustos'></option>
                                    <option value="9"><cf_get_lang_main no='188.Eylül'></option>
                                    <option value="10"><cf_get_lang_main no='189.Ekim'></option>
                                    <option value="11"><cf_get_lang_main no='190.Kasım'></option>
                                    <option value="12"><cf_get_lang_main no='191.Aralık'></option>
                                </select>
                     	</div>
               		</div>
                    <div class="form-group" id="item-item-rate_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58456.Oran'> *</label>
                      	<div class="col col-8 col-xs-12">
                        	<cfinput type="text" name="rate" id="rate" maxlength="5" style="width:50px; text-align:right" value="#TlFormat(attributes.rate,2)#">
                     	</div>
               		</div>
					<div class="form-group" id="item-recorder_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57899.Kaydeden'> *</label>
                      	<div class="col col-8 col-xs-12">
                       		<div class="input-group">
                            	<input type="hidden" name="record_employee_id" id="record_employee_id" value="">
                                <input type="text" name="shift_employee" id="shift_employee" value="" style="width:125px;" onFocus="AutoComplete_Create('shift_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','record_employee_id','','3','125');" autocomplete="off">
                             	<span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=record_employee_id&field_name=shift_employee&select_list=1','list','popup_list_positions');"></span>
                         	</div>
                     	</div>
               		</div>
                    <div class="form-group" id="item-item-detail_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'> </label>
                      	<div class="col col-8 col-xs-12">
							<textarea name="detail" id="detail" style="width:200px;height:90px;"><cfif isdefined("attributes.order_row_id")>#get_amount.order_detail#</cfif></textarea>
                     	</div>
               		</div>
               	</div>
                </cfoutput>
          	</cf_box_elements>
            <cf_box_footer>
                <div class="col col-12">
                	<cf_workcube_buttons type_format="1" is_upd='0' add_function='kontrol()'>
                </div>
            </cf_box_footer>
        </cfform> 
    </cf_box>
</div>
<script language="JavaScript">
	function kontrol()
	{
		if(document.getElementById('shift_employee').value == "")
		{
			alert("<cf_get_lang_main no='782.Zorunlu Alan'> : <cf_get_lang_main no='487.Kaydeden'>!");
			document.getElementById('shift_employee').focus();
			return false;
		}
		if(document.getElementById('branch_id').value == "")
		{
			alert("<cf_get_lang_main no='782.Zorunlu Alan'> : <cf_get_lang_main no='41.Sube'>!");
			document.getElementById('branch_id').focus();
			return false;
		}
		if(document.getElementById('start_date').value == "")
		{
			alert("<cf_get_lang_main no='782.Zorunlu Alan'> : <cf_get_lang_main no='330.Tarih'>!");
			document.getElementById('start_date').focus();
			return false;
		}
		if(document.getElementById('rate').value == "")
		{
			alert("<cf_get_lang_main no='782.Zorunlu Alan'> : <cf_get_lang_main no='3361.Katsayı'>!");
			document.getElementById('rate').focus();
			return false;
		}
		if(process_cat_control())
			return true;
		else
			return false;
	}
</script>