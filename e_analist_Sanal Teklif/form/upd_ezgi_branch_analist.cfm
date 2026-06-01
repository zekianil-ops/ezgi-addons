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
<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_ANALYST_BRANCH WHERE ANALYST_BRANCH_ID = #attributes.upd_id#
</cfquery>

<cfset attributes.is_branch = get_upd.is_branch>
<cfset attributes.detail = get_upd.detail>
<cfset attributes.analyst_status = get_upd.status>
<cfset attributes.start_date = get_upd.date>
<cfset attributes.branch_id = get_upd.branch_id>
<cfset attributes.price_cat_id = get_upd.PRICE_CATID>
<cfset attributes.rate = get_upd.rate>
<cfset attributes.year_value = get_upd.year_value>
<cfset attributes.month_value = get_upd.month_value>
<cfset attributes.record_employee_id = get_upd.employee_id>
<cfset attributes.record_employee = get_emp_info(get_upd.employee_id,0,0)>
<cfset attributes.process_stage = get_upd.PROCESS_STAGE>
<cf_catalystHeader>
<cfsavecontent variable="right_menu">
        	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=report.popup_add_ezgi_branch_analist_cost&upd_id=#attributes.upd_id#</cfoutput>','list');">
            	<img src="/images/money_plan.gif" title="<cfoutput>#getLang('cash',189)#</cfoutput>">
            </a>
            &nbsp;&nbsp;
        	<a style="cursor:pointer" onclick="input_control(<cfoutput>#get_upd.STATUS#</cfoutput>);">
				<cfif get_upd.STATUS eq 0>
                    <img src="/images/lock_open.gif" title="<cf_get_lang_main no='2068.Tamamlanmadı'>">
                <cfelse>
                    <img src="/images/lock_buton.gif" title="<cf_get_lang_main no='1374.Tamamlandı'>">
                </cfif>
            </a>
</cfsavecontent>
<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id='57464.Güncelle'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box id="plan_detail" title="#ezgi_header#" right_images="#right_menu#">
		<cfform name="upd_branch_analist" method="post" action="#request.self#?fuseaction=report.emptypopup_upd_ezgi_branch_analist">
          	<cfinput type="hidden" value="#attributes.upd_id#" name="upd_id">
            <cfoutput>
            <cf_basket_form id="upd_design">
                <div class="row">
                  	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
							<cf_box_elements>
                             	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                                  	<div class="form-group" id="item-demand_satge">
                                      	<label class="col col-4 col-xs-12"><cf_get_lang_main no='642.Süreç/Asama'></label>
                                     	<div class="col col-8 col-xs-12">
                                         	<cf_workcube_process is_upd='0' select_value='#attributes.process_stage#' process_cat_width='125' is_detail='1'>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-demand_is_branch">
                                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='64164.Analiz Metodu'></label>

                                     	<div class="col col-8 col-xs-12">
                                         	 <select name="is_branch" id="is_branch" style="width:95px; height:20px">
                                                <option value="1" <cfif attributes.is_branch eq 1>selected</cfif>><cf_get_lang_main no='41.Sube'></option>
                                                <option value="0" <cfif attributes.is_branch eq 0>selected</cfif>><cf_get_lang_main no='1161.Merkez'></option>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-demand_branch">
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
                               	</div>
                                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                                	<div class="form-group" id="item-demand_rate">
                                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58456.Oran'> *</label>
                                     	<div class="col col-8 col-xs-12">
                                         	<cfinput type="text" name="rate" id="rate" maxlength="5" style="width:50px;" value="#TlFormat(attributes.rate,2)#">
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-demand_year">
                                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58455.Yıl'></label>
                                     	<div class="col col-8 col-xs-12">
                                         	<select name="year_value" id="year_value" style="width:65px; height:20px">
                                                <cfloop query="get_period">
                                                    <option value="#PERIOD_YEAR#" <cfif attributes.year_value eq PERIOD_YEAR>selected</cfif>>#PERIOD_YEAR#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-demand_month">
                                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58724.Ay'></label>
                                     	<div class="col col-8 col-xs-12">
                                         	<select name="month_value" id="month_value" style="width:65px; height:20px">
                                                <option value="1" <cfif attributes.month_value eq 1>selected</cfif>><cf_get_lang_main no='180.Ocak'></option>
                                                <option value="2" <cfif attributes.month_value eq 2>selected</cfif>><cf_get_lang_main no='181.Şubat'></option>
                                                <option value="3" <cfif attributes.month_value eq 3>selected</cfif>><cf_get_lang_main no='182.Mart'></option>
                                                <option value="4" <cfif attributes.month_value eq 4>selected</cfif>><cf_get_lang_main no='183.Nisan'></option>
                                                <option value="5" <cfif attributes.month_value eq 5>selected</cfif>><cf_get_lang_main no='184.Mayıs'></option>
                                                <option value="6" <cfif attributes.month_value eq 6>selected</cfif>><cf_get_lang_main no='185.Haziran'></option>
                                                <option value="7" <cfif attributes.month_value eq 7>selected</cfif>><cf_get_lang_main no='186.Temmuz'></option>
                                                <option value="8" <cfif attributes.month_value eq 8>selected</cfif>><cf_get_lang_main no='187.Ağustos'></option>
                                                <option value="9" <cfif attributes.month_value eq 9>selected</cfif>><cf_get_lang_main no='188.Eylül'></option>
                                                <option value="10" <cfif attributes.month_value eq 10>selected</cfif>><cf_get_lang_main no='189.Ekim'></option>
                                                <option value="11" <cfif attributes.month_value eq 11>selected</cfif>><cf_get_lang_main no='190.Kasım'></option>
                                                <option value="12" <cfif attributes.month_value eq 12>selected</cfif>><cf_get_lang_main no='191.Aralık'></option>
                                            </select>
                                      	</div>
                                 	</div>
                               	</div>
                                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                                	<div class="form-group" id="item-demand_date">
                                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="30631.Tarih"> *</label>
                                     	<div class="col col-8 col-xs-12">
                                       		<div class="input-group x-14">
                                				<cfsavecontent variable="message"><cf_get_lang_main no='1091.Lütfen Tarih Giriniz'></cfsavecontent>
                                 				<cfinput type="text" name="start_date"  value="#dateformat(attributes.start_date,'dd/mm/yyyy')#" validate="eurodate" maxlength="10" message="#message#" style="width:65px;">
                   					          	<span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                         					</div>
                                      	</div>
                                 	</div>
                                	<div class="form-group" id="item-demand_recorder">
                                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57899.Kaydeden'> *</label>
                                     	<div class="col col-8 col-xs-12">
                                        	<div class="input-group">
                                         	<input type="hidden" name="record_employee_id" id="record_employee_id" value="#attributes.record_employee_id#">
                                            <input type="text" name="record_employee" id="record_employee" value="#attributes.record_employee#" style="width:150px;" onFocus="AutoComplete_Create('record_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','record_employee_id','','3','125');" autocomplete="off">
                                            <span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=record_employee_id&field_name=record_employee&select_list=1','list','popup_list_positions');"></span>
                                            </div>
                                      	</div>
                                 	</div>	
                                </div>
                                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                                	<div class="form-group" id="item-demand_date">
                                      	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                                     	<div class="col col-8 col-xs-12">
                                       		<textarea name="detail" id="detail" style="width:200px;height:90px;"><cfif len(attributes.detail)>#attributes.detail#</cfif></textarea>
                                      	</div>
                                 	</div
                              	></div>
                          	</cf_box_elements>
                            <cf_box_footer>
                              	<div class="col col-12">
                                  	<cf_workcube_buttons 
                                       	is_upd='1' 
                                      	add_function ='kontrol()'
                                   		delete_page_url='#request.self#?fuseaction=report.emptypopup_del_ezgi_branch_analist&upd=#attributes.upd_id#'
                                  	>
                             	</div>
                         	</cf_box_footer>
                    	</div>
                	</div>
          		</div>   
        	</cf_basket_form>
       		</cfoutput>
		</cfform>
   	</cf_box>
    <cf_box title="">
    	<cf_box_elements>
        	<div class="col col-12">
            <cfsavecontent variable="message"><font color="black"><b>Gelirler</b></font></cfsavecontent>
           	<cf_show_ajax page_style="off" table_align="left" title="#message#" tr_id="upd_id_1" page_url="#request.self#?fuseaction=report.ajax_ezgi_analyst_gelirler&upd_id=#attributes.upd_id#">
        	</div>
        </cf_box_elements>
	</cf_box>
    <cf_box title="">
    	<cf_box_elements>
        	<div class="col col-12">
            <cfsavecontent variable="message"><font color="black"><b>Giderler</b></font></cfsavecontent>
          	<cf_show_ajax page_style="off" table_align="left" title="#message#" tr_id="upd_id_2" page_url="#request.self#?fuseaction=report.ajax_ezgi_analyst_giderler&upd_id=#attributes.upd_id#">
        	</div>
        </cf_box_elements>
	</cf_box>
    <cf_box title="">
    	<cf_box_elements>
        	<div class="col col-12">
            <cfsavecontent variable="message"><font color="black"><b>Sonuç</b></font></cfsavecontent>
         	<cf_show_ajax page_style="off" table_align="left" title="#message#" tr_id="upd_id_3" page_url="#request.self#?fuseaction=report.ajax_ezgi_analyst_sonuc&upd_id=#attributes.upd_id#">
            </div>
        </cf_box_elements>
	</cf_box>
</div>

<script language="JavaScript">
	function kontrol()
	{
		if(document.getElementById('record_employee').value == "")
		{
         	alert("<cf_get_lang_main no='782.Zorunlu Alan'> : <cf_get_lang_main no='487.Kaydeden'>!");
          	document.getElementById('record_employee').focus();
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
	function input_control(status)
 	{
     	if(status==1)
     	{
          	sor=confirm('Belgenin Kilidi Açılacaktır?');
         	if (sor == true)
         	{
             	document.getElementById("upd_branch_analist").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=report.emptypopup_upd_ezgi_branch_analist&status=0";
              	document.getElementById("upd_branch_analist").submit();
        	}
          	else
                return false;
   		}
     	else if(status==0)
     	{
          	sor=confirm('Belge Kilitlenecektir?');
          	if (sor == true)
           	{
             	document.getElementById("upd_branch_analist").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=report.emptypopup_upd_ezgi_branch_analist&status=1";
             	document.getElementById("upd_branch_analist").submit();
          	}
         	else
                return false;
 		}
 	}
</script>	