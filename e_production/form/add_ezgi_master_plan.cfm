<!---
    File: add_ezgi_master_plan.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->


<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.start_h" default="08">
<cfparam name="attributes.finish_h" default="18">
<cfparam name="attributes.start_m" default="00">
<cfparam name="attributes.finish_m" default="00">
<cfparam name="attributes.shift_employee_id" default="#session.ep.USERID#">
<cfparam name="attributes.master_plan_status" default="">
<cfquery name="get_master_plan_sablon" datasource="#dsn3#">
	SELECT * FROM EZGI_MASTER_PLAN_SABLON WHERE PROCESS_ID = 1
</cfquery>
<cf_catalystHeader>
<div class="col col-12 col-xs-12">
	<cf_box>
    	<cfform name="form_basket" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_master_plan">
        	<cf_box_elements>
            	<cfoutput>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="item-is_active">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                     	<div class="col col-8 col-xs-12">
                        	<cfinput type="checkbox" id="master_plan_status" name="master_plan_status" value="1" checked="yes">
                      	</div>
                 	</div>
                    <div class="form-group" id="item-process_cat">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41129.Süreç/Aşama'> *</label>
                     	<div class="col col-8 col-xs-12">
                        	<cf_workcube_process is_upd='0' process_cat_width='125' is_detail='0'>
                      	</div>
                 	</div>
                    <div class="form-group" id="item-shift_id">
                  		<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='396.Master Plan Adı'>*</label>
                     	<div class="col col-8 col-xs-12">
                       		<div class="input-group">
                            	<input type="hidden" name="shift_id" id="shift_id" value="">
								<input type="text" name="shift_name" id="shift_name" value="" style="width:175px;" >
                             	<span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('#request.self#?fuseaction=prod.popup_list_ezgi_shift&field_name=shift_name&field_id=shift_id','list');"></span>
                        	</div>
                   		</div>
                	</div>
                    <div class="form-group" id="item-shift_employee_id">
                  		<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='543.Planı Ekleyen'>*</label>
                     	<div class="col col-8 col-xs-12">
                       		<div class="input-group">
                            	<input type="hidden" name="shift_employee_id" id="shift_employee_id" value="<cfif Len(attributes.shift_employee_id)>#attributes.shift_employee_id#</cfif>">
								<input type="text" name="shift_employee" id="shift_employee" value="<cfif Len(attributes.shift_employee_id)>#get_emp_info(attributes.shift_employee_id,0,0)#</cfif>" style="width:175px;" onFocus="AutoComplete_Create('shift_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','shift_employee_id','','3','125');" autocomplete="off">
                             	<span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=shift_employee_id&field_name=shift_employee&select_list=1');"></span>
                        	</div>
                   		</div>
                	</div>
                    <div class="form-group" id="item-paper_serious">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57880.Belge No'> *</label>
                        <div class="col col-2 col-xs-12">
                        	<input name="paper_serious" type="text" readonly="" value="#Trim(get_master_plan_sablon.PAPER_SERIOUS)#" maxlength="1" style="width:30px;" />
                      	</div>
                        <div class="col col-6 col-xs-12">
                        	<input name="paper_number" type="text"  value="#get_master_plan_sablon.PAPER_NO#" maxlength="15" style="width:80px;" />
                      	</div>
                 	</div>
                    <div class="form-group" id="item-start_date">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57655.Başlama Tarihi'> *</label>
                     	<div class="col col-4 col-xs-12">
                        	<div class="input-group x-14">
                        	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
							<cfinput type="text" name="start_date" placeholder="#message#" value="" style="width:65px;" validate="#validate_style#" maxlength="10">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                            </div>
                      	</div>
                        <div class="col col-2 col-xs-12">
                        	<select name="start_h" id="start_h">
                             	<cfloop from="0" to="23" index="i">
                                  	<option value="#i#" 
										<cfif attributes.start_h eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#
                                 	</option>
                              	</cfloop>
                         	</select>
                      	</div>
                        <div class="col col-2 col-xs-12">
                        	<select name="start_m" id="start_m">
                              	<cfloop from="0" to="59" index="i">
                                  	<option value="#i#" 
										<cfif attributes.start_m eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#
                                  	</option>
                           		</cfloop>
                         	</select>
                      	</div>
                 	</div>
                    <div class="form-group" id="item-finish_date">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'> *</label>
                     	<div class="col col-4 col-xs-12">
                        	<div class="input-group x-14">
                        	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
							<cfinput type="text" name="finish_date" placeholder="#message#" value="" style="width:65px;" validate="#validate_style#" maxlength="10">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                            </div>
                      	</div>
                        <div class="col col-2 col-xs-12">
                        	<select name="finish_h" id="finish_h">
                             	<cfloop from="0" to="23" index="i">
                                  	<option value="#i#" 
										<cfif attributes.finish_h eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#
                                 	</option>
                              	</cfloop>
                         	</select>
                      	</div>
                        <div class="col col-2 col-xs-12">
                        	<select name="finish_m" id="finish_m">
                              	<cfloop from="0" to="59" index="i">
                                  	<option value="#i#" 
										<cfif attributes.finish_m eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#
                                  	</option>
                           		</cfloop>
                         	</select>
                      	</div>
                 	</div>
                    <div class="form-group" id="item-shift_project_id">
                  		<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                     	<div class="col col-8 col-xs-12">
                       		<div class="input-group">
                            	<input type="hidden" name="project_id" id="project_id" value="<cfoutput>#attributes.project_id#</cfoutput>">
								<input name="project_head" type="text" id="project_head" value="<cfif Len(attributes.project_id) and len(attributes.project_head)><cfoutput>#get_project_name(attributes.project_id)#</cfoutput></cfif>"  onfocus="AutoComplete_Create('project_head','PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','list_works','3','250');" >
								<span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=list_works.project_head&project_id=list_works.project_id</cfoutput>');"></span>
                        	</div>
                   		</div>
                	</div>
                    <div class="form-group" id="item-detail">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açiklama'> *</label>
                     	<div class="col col-8 col-xs-12">
                        	<textarea name="detail" id="detail" style="width:200px;height:80px;"></textarea>
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
	if (form_basket.shift_id.value.length == 0)
		{
			alert("<cf_get_lang dictionary_id='530.Plan Adı Girmelisiniz'> !");
			return false;
		}
		if (form_basket.start_date.value.length == 0)
		{
			alert("<cf_get_lang dictionary_id='531.Plan Başlama Tarihi Girmelisiniz'> !");
			return false;
		}
		if (form_basket.finish_date.value.length == 0)
		{
			alert("<cf_get_lang dictionary_id='532.Plan Bitiş Tarihi Girmelisiniz'> !");
			return false;
		}
		if(process_cat_control())
			return true;
		else
			return false;
	}
</script>
