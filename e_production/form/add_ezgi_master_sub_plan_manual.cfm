<!---
    File: add_ezgi_master_sub_plan_manual.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_master_plan" datasource="#dsn3#">
	SELECT * FROM	EZGI_MASTER_PLAN WHERE	MASTER_PLAN_ID = #attributes.master_plan_id#
</cfquery>
<cfparam name="attributes.master_alt_plan_start_date" default="#get_master_plan.MASTER_PLAN_START_DATE#">
<cfparam name="attributes.master_alt_plan_finish_date" default="#get_master_plan.MASTER_PLAN_FINISH_DATE#">
<cfparam name="attributes.master_alt_plan_start_h" default="">
<cfparam name="attributes.master_alt_plan_finish_h" default="">
<cfparam name="attributes.master_alt_plan_start_m" default="">
<cfparam name="attributes.master_alt_plan_finish_m" default="">
<cfparam name="attributes.form_basket_submitted" default="">
<cfquery name="get_paper_no" datasource="#dsn3#">
	SELECT * FROM EZGI_MASTER_PLAN_SABLON WHERE PROCESS_ID = #attributes.islem_id#
</cfquery>
<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id="549.Alt Plan Oluştur"></cfsavecontent>
<div class="col col-12 col-xs-12">
	<cf_box title="#ezgi_header#">
    	<cfform name="form_basket" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_master_sub_plan">
        	<input type="hidden" name="form_basket_submitted" value="1" />
        	<input type="hidden" name="islem_id" value="<cfoutput>#attributes.islem_id#</cfoutput>" />
         	<input type="hidden" name="master_plan_id" value="<cfoutput>#attributes.master_plan_id#</cfoutput>">
        	<cf_box_elements>
            	<cfoutput>
                <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="item-reserve">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41185.Stok Rezerve Et'></label>
                     	<div class="col col-8 col-xs-12">
                        	<input type="checkbox" name="is_stock_reserve" value="1" checked="checked">
                      	</div>
                 	</div>
                	<div class="form-group" id="item-process_cat">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41129.Süreç/Aşama'> *</label>
                     	<div class="col col-8 col-xs-12">
                        	<cf_workcube_process is_upd='0' process_cat_width='125' is_detail='0'>
                      	</div>
                 	</div>
                    <div class="form-group" id="item-master">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="1020.Master Plan No">  </label>
                     	<div class="col col-8 col-xs-12">
                        	<input type="text" name="master_plan_number" readonly="readonly" value="#get_master_plan.MASTER_PLAN_NUMBER#"  maxlength="25" style="width:140px;">
                      	</div>
                 	</div>
                    <div class="form-group" id="item-paper_serious">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="1019.Alt Plan No">  </label>
                        <div class="col col-2 col-xs-12">
                            <input name="paper_serious" type="text"  value="#Trim(get_paper_no.PAPER_SERIOUS)#" maxlength="1" />
                      	</div>
                        <div class="col col-6 col-xs-12">
                        	<input name="paper_number" type="text"    value="#get_paper_no.PAPER_NO#" maxlength="15" />
                      	</div>
                 	</div>
                    <div class="form-group" id="item-plan_type">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='1051.Alt Plan Tipi'></label>
                     	<div class="col col-8 col-xs-12">
                        	<select name="plan_type" style="width:100px">
                             	<option value="0" ><cf_get_lang dictionary_id="1052.Standart Plan"></option>
                             	<option value="1" ><cf_get_lang dictionary_id='588.Torba Plan'></option> 
                       		</select>
                      	</div>
                 	</div>
                    <div class="form-group" id="item-shift_employee_id">
                  		<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='543.Planı Ekleyen'>*</label>
                     	<div class="col col-8 col-xs-12">
                       		<div class="input-group">
                            	<input type="hidden" name="employee_id" value="#session.ep.userid#">
								<input type="text" name="employee" value="#get_emp_info(session.ep.userid,0,0)#" readonly="yes" style="width:140px;">
                             	<span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=employee_id&field_name=employee&select_list=1');"></span>
                        	</div>
                   		</div>
                	</div>
                    <div class="form-group" id="item-point">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='548.Hedef İş Puanı'> *</label>
                     	<div class="col col-8 col-xs-12">
                        	<input name="work_point" type="text" value="#TlFormat(get_paper_no.CURRENT_POINT,2)#" style="width:65px; text-align:center" />
                      	</div>
                 	</div>
                    <div class="form-group" id="item-master_alt_plan_start_date">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57655.Baslama Tarihi'> *</label>
                     	<div class="col col-4 col-xs-12">
                        	<div class="input-group x-14">
                        	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
							<cfinput type="text" name="master_alt_plan_start_date" placeholder="#message#" value="#dateformat(attributes.master_alt_plan_start_date,dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10" required="yes">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="master_alt_plan_start_date"></span>
                            </div>
                      	</div>
                        <div class="col col-2 col-xs-12">
                        	<select name="master_alt_plan_start_h" id="master_alt_plan_start_h">
                             	<cfloop from="0" to="23" index="i">
                                  	<option value="#i#" 
										<cfif attributes.master_alt_plan_start_h eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#
                                 	</option>
                              	</cfloop>
                         	</select>
                      	</div>
                        <div class="col col-2 col-xs-12">
                        	<select name="master_alt_plan_start_m" id="master_alt_plan_start_m">
                              	<cfloop from="0" to="59" index="i">
                                  	<option value="#i#" 
										<cfif attributes.master_alt_plan_start_m eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#
                                  	</option>
                           		</cfloop>
                         	</select>
                      	</div>
                 	</div>
                    <div class="form-group" id="item-master_alt_plan_finish_date">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57700.Bitis Tarihi'> *</label>
                     	<div class="col col-4 col-xs-12">
                        	<div class="input-group x-14">
                        	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
							<cfinput type="text" name="master_alt_plan_finish_date" placeholder="#message#" value="#dateformat(attributes.master_alt_plan_finish_date,dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10" required="yes">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="master_alt_plan_finish_date"></span>
                            </div>
                      	</div>
                        <div class="col col-2 col-xs-12">
                        	<select name="master_alt_plan_finish_h" id="master_alt_plan_finish_h">
                             	<cfloop from="0" to="23" index="i">
                                  	<option value="#i#" 
										<cfif attributes.master_alt_plan_finish_h eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#
                                 	</option>
                              	</cfloop>
                         	</select>
                      	</div>
                        <div class="col col-2 col-xs-12">
                        	<select name="master_alt_plan_finish_m" id="master_alt_plan_finish_m">
                              	<cfloop from="0" to="59" index="i">
                                  	<option value="#i#" 
										<cfif attributes.master_alt_plan_finish_m eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#
                                  	</option>
                           		</cfloop>
                         	</select>
                      	</div>
                 	</div>
                    <div class="form-group" id="item-shift_project_id">
                  		<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                     	<div class="col col-8 col-xs-12">
                       		<div class="input-group">
                            	<input type="hidden" name="project_id" value="#get_master_plan.MASTER_PLAN_PROJECT_ID#" />
								<input type="text" name="project_name" value="<cfif len(get_master_plan.MASTER_PLAN_PROJECT_ID)>#get_project_name(get_master_plan.MASTER_PLAN_PROJECT_ID)#</cfif>" readonly style="width:130px;">
								<span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_head=list_works.project_head&project_id=list_works.project_id');"></span>
                        	</div>
                   		</div>
                	</div>
                    <div class="form-group" id="item-detail">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açiklama'> *</label>
                     	<div class="col col-8 col-xs-12">
                        	<textarea name="reference_no" maxlength="500" style="width:167px;height:73px;" 
							onkeydown="counter(this.form.reference_no,this.form.detailLen,500);return ismaxlength(this);" 
							onkeyup="counter(this.form.reference_no,this.form.detailLen,500);return ismaxlength(this);" onBlur="return ismaxlength(this);"></textarea>
                      	</div>
                 	</div>
                    </cfoutput>
              	</div>
			</cf_box_elements>
         	<cf_box_footer>
           		<div class="col col-6">
                	<cf_workcube_buttons type_format="1" is_upd='0' is_cancel="1" add_function='kontrol()'>
              	</div>
        	</cf_box_footer>
        </cfform> 
    </cf_box>
</div>
<script language="JavaScript">
	function kontrol()
	{
		if((document.getElementById('master_alt_plan_start_date').value != "") && (document.getElementById('master_alt_plan_finish_date').value != ""))
		return time_check(document.getElementById('master_alt_plan_start_date'), document.getElementById('master_alt_plan_start_h'), document.getElementById('master_alt_plan_start_m'), document.getElementById('master_alt_plan_finish_date'),  document.getElementById('master_alt_plan_finish_h'), document.getElementById('master_alt_plan_finish_m'), "<cf_get_lang dictionary_id='545.Başlama ve Bitiş Tarihlerini Kontrol Ediniz'> !");
		else
		{alert("<cf_get_lang dictionary_id='545.Başlama ve Bitiş Tarihlerini Kontrol Ediniz'>");return false;}
		return true;
		if(process_cat_control())
			return true;
		else
			return false;
	}
</script>								
