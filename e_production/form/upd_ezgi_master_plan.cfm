<!---
    File: upd_ezgi_master_plan.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="paper_project_id" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.start_h" default="">
<cfparam name="attributes.finish_h" default="">
<cfparam name="attributes.start_m" default="">
<cfparam name="attributes.finish_m" default="">
<cfparam name="attributes.detail" default="">
<cfparam name="attributes.is_detail" default="">
<cfparam name="attributes.shift_id" default="">
<cfparam name="attributes.shift_name" default="">
<cfparam name="attributes.shift" default="">
<cfparam name="attributes.get_master_plan_process" default="">
<cfparam name="attributes.shift_employee_id" default="#session.ep.USERID#">
<cfparam name="attributes.master_plan_status" default="">
<cfquery name="get_default" datasource="#dsn3#">
	SELECT       
    	ISNULL(EMAD.POINT_METHOD,1) POINT_METHOD,
        EMAD.FABRIC_CAT,
        EMAD.CONTROL_METHOD
	FROM            
    	EZGI_MASTER_PLAN_DEFAULTS AS EMAD INNER JOIN
     	EZGI_MASTER_PLAN AS EMAP ON EMAD.SHIFT_ID = EMAP.MASTER_PLAN_CAT_ID
	WHERE        
    	EMAP.MASTER_PLAN_ID = #attributes.upd_id#
</cfquery>
<cfquery name="get_shift" datasource="#dsn3#">
	SELECT	
    	MASTER_PLAN_START_DATE,
		MASTER_PLAN_FINISH_DATE,
		MASTER_PLAN_CAT_ID, 
		MASTER_PLAN_NAME, 
		MASTER_PLAN_NUMBER, 
		MASTER_PLAN_DETAIL, 
		MASTER_PLAN_STATUS, 
		MASTER_PLAN_STAGE,
     	ISNULL(MASTER_PLAN_PROCESS,0) MASTER_PLAN_PROCESS,
		EMPLOYYEE_ID, 
		BRANCH_ID, 
		RECORD_EMP, 
		RECORD_IP, 
		RECORD_DATE, 
        UPDATE_EMP, 
		UPDATE_IP, 
		UPDATE_DATE,
		IS_PROCESS, 
		MONEY,
		MASTER_PLAN_PROJECT_ID,
		GROSSTOTAL,
     	ISNULL((
            		SELECT     
                    	SUM(PLAN_POINT) PLAN_POINT
					FROM         
                    	EZGI_MASTER_ALT_PLAN
					WHERE     
                    	MASTER_PLAN_ID = EZGI_MASTER_PLAN.MASTER_PLAN_ID
      	),0) AS H_POINT,
        ISNULL((	
            	SELECT     
                 	SUM(PO.QUANTITY) AS SAYI
				FROM         
                	EZGI_MASTER_PLAN_RELATIONS AS EMPR INNER JOIN
                  	PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                  	EZGI_MASTER_ALT_PLAN AS EMAP ON EMPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
                  	EZGI_MASTER_PLAN_SABLON AS EMAS ON EMAP.PROCESS_ID = EMAS.PROCESS_ID
				WHERE     
               		EMPR.MASTER_PLAN_ID = EZGI_MASTER_PLAN.MASTER_PLAN_ID
    	),0) AS SAYI,
        <cfif get_default.POINT_METHOD eq 1>
  			ISNULL((	
            		SELECT     
                        	SUM(PO.QUANTITY) AS P_POINT
						FROM         
                        	EZGI_MASTER_PLAN_RELATIONS AS EMPR INNER JOIN
                          	PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                          	EZGI_MASTER_ALT_PLAN AS EMAP ON EMPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
                          	EZGI_MASTER_PLAN_SABLON AS EMAS ON EMAP.PROCESS_ID = EMAS.PROCESS_ID
						WHERE     
                        	EMPR.MASTER_PLAN_ID = EZGI_MASTER_PLAN.MASTER_PLAN_ID AND 
                            EMAS.SIRA = 1 AND 
                            PO.IS_STAGE = 2
    		),0) AS G_POINT,
   			ISNULL((	
            		SELECT     
                        	SUM(PO.QUANTITY) AS P_POINT
						FROM         
                        	EZGI_MASTER_PLAN_RELATIONS AS EMPR INNER JOIN
                      		PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                      		EZGI_MASTER_ALT_PLAN AS EMAP ON EMPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
                      		EZGI_MASTER_PLAN_SABLON AS EMAS ON EMAP.PROCESS_ID = EMAS.PROCESS_ID
						WHERE     
                        	EMPR.MASTER_PLAN_ID = EZGI_MASTER_PLAN.MASTER_PLAN_ID AND 
                            EMAS.SIRA = 1
   			),0) AS T_POINT 
     	<cfelseif get_default.POINT_METHOD eq 2>         
        	ISNULL(
                	(	
            		SELECT     
                        	SUM(PO.QUANTITY * ISNULL(CAST(PTIP.PROPERTY2 AS float),0)) AS P_POINT
						FROM         
                        	EZGI_MASTER_PLAN_RELATIONS AS EMPR INNER JOIN
                          	PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                          	EZGI_MASTER_ALT_PLAN AS EMAP ON EMPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
                          	EZGI_MASTER_PLAN_SABLON AS EMAS ON EMAP.PROCESS_ID = EMAS.PROCESS_ID LEFT OUTER JOIN
                          	PRODUCT_TREE_INFO_PLUS AS PTIP ON PO.STOCK_ID = PTIP.STOCK_ID
						WHERE     
                        	EMPR.MASTER_PLAN_ID = EZGI_MASTER_PLAN.MASTER_PLAN_ID AND 
                            EMAS.SIRA = 1 AND 
                            PO.IS_STAGE = 2
      				),0) AS G_POINT,
            ISNULL(
                	(	
            		SELECT     
                        	SUM(PO.QUANTITY * ISNULL(CAST(PTIP.PROPERTY2 AS float),0)) AS P_POINT
						FROM         
                        	EZGI_MASTER_PLAN_RELATIONS AS EMPR INNER JOIN
                      		PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                      		EZGI_MASTER_ALT_PLAN AS EMAP ON EMPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
                      		EZGI_MASTER_PLAN_SABLON AS EMAS ON EMAP.PROCESS_ID = EMAS.PROCESS_ID LEFT OUTER JOIN
                      		PRODUCT_TREE_INFO_PLUS AS PTIP ON PO.STOCK_ID = PTIP.STOCK_ID
						WHERE     
                        	EMPR.MASTER_PLAN_ID = EZGI_MASTER_PLAN.MASTER_PLAN_ID AND 
                            EMAS.SIRA = 1
      		),0) AS T_POINT 
        </cfif>       
	FROM	
    	EZGI_MASTER_PLAN
	WHERE	
    	MASTER_PLAN_ID = #attributes.upd_id#
</cfquery>
<cfset attributes.start_date=get_shift.MASTER_PLAN_START_DATE>
<cfset attributes.finish_date=get_shift.MASTER_PLAN_FINISH_DATE>
<cfset shift_id=get_shift.MASTER_PLAN_CAT_ID>
<cfset shift_name=get_shift.MASTER_PLAN_NAME>
<cfset paper_number=get_shift.MASTER_PLAN_NUMBER>
<cfset detail=get_shift.MASTER_PLAN_DETAIL>
<cfset MASTER_PLAN_status=get_shift.MASTER_PLAN_STATUS>
<cfset process_stage=get_shift.MASTER_PLAN_STAGE>
<cfset shift_employee_id=get_shift.EMPLOYYEE_ID>
<cfset branch_id=get_shift.BRANCH_ID>
<cfset record_id=get_shift.RECORD_EMP>
<cfset record_time=get_shift.RECORD_DATE>
<cfset update_id=get_shift.RECORD_EMP>
<cfset update_time=get_shift.RECORD_DATE>
<cfset money=get_shift.MONEY>
<cfset paper_project_id=get_shift.MASTER_PLAN_PROJECT_ID>
<cfquery name="get_menu" datasource="#dsn3#">
    SELECT   	
    	*
    FROM       	
    	EZGI_MASTER_PLAN_SABLON
    WHERE     	
    	SHIFT_ID = #shift_id# AND 
        SIRA > 0
    ORDER BY	
    	SIRA	
</cfquery>
<cfquery name="get_ust_menu" datasource="#dsn3#">
	SELECT   	
    	*
    FROM       	
    	EZGI_MASTER_PLAN_SABLON
    WHERE     	
    	SHIFT_ID = #shift_id# AND 
        SIRA = 0
</cfquery>
<cfquery name="alt_plan_control" datasource="#dsn3#">
	SELECT     	
    	*
	FROM       	
    	EZGI_MASTER_ALT_PLAN
	WHERE     	
    	MASTER_PLAN_ID = #attributes.upd_id#
</cfquery>
<cf_catalystHeader>
<cfsavecontent variable="right_menu"></cfsavecontent>
<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id='627.Üretim Master Planı Güncelle'></cfsavecontent>
<div class="col col-10 col-md-10 col-sm-10 col-xs-12">
	<cf_box id="plan_detail" title="#ezgi_header#" right_images="#right_menu#">
    	<cfform name="add_shift" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_master_plan">
        	<cfoutput>
       		<input type="hidden" name="upd_id" id="upd_id" value="#upd_id#">
        	<cf_box_elements>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
					<div class="form-group" id="item-planname">
						<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='396.Master Plan Adı'>*</label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        	<input type="hidden" name="shift_id" id="shift_id" readonly="yes" value="<cfif isdefined("shift_id") and len(shift_id)>#shift_id#</cfif>">
                         	<input type="text" name="shift_name" id="shift_name" readonly="yes" value="<cfif isdefined("shift_name") and len(shift_name)>#shift_name#</cfif>" style="width:175px;" >
                      	</div>
                 	</div>
                    <div class="form-group" id="item-yetkili">
						<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='543.Planı Ekleyen'>*</label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        	<div class="input-group">
                        		<input type="hidden" name="shift_employee_id" id="shift_employee_id" readonly="yes" value="<cfif Len(shift_employee_id)>#shift_employee_id#</cfif>">
                         		<input type="text" name="shift_employee" id="shift_employee" value="<cfif Len(shift_employee_id)>#get_emp_info(shift_employee_id,0,0)#</cfif>" style="width:175px;" onFocus="AutoComplete_Create('shift_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','shift_employee_id','','3','125');" autocomplete="off">
                            	<span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=shift_employee_id&field_name=shift_employee&select_list=1');"></span>
                          	</div>
                      	</div>
                 	</div>
                    <div class="form-group" id="item-paperno">
						<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57880.Belge No'>*</label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        	 <input name="paper_number"  type="text"  value="#paper_number#" maxlength="15" style="width:80px;" />
                        </div>
                  	</div>
				</div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                	<div class="form-group" id="item-status">
						<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        	 <input type="checkbox" name="master_plan_status" <cfif master_plan_status eq 1>checked</cfif> value="1">
                        </div>
                  	</div>
                	<div class="form-group" id="item-surec">
						<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='41129.Süreç/Asama'></label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        	 <cf_workcube_process is_upd='0' select_value='#get_shift.MASTER_PLAN_PROCESS#' process_cat_width='125' is_detail='1'>
                        </div>
                  	</div>
                    <div class="form-group" id="item-proses">
						<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='54272.Plan Durumu'></label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        	<select name="get_master_plan_process" style="width:90px">
                             	<option value="1" <cfif get_shift.MASTER_PLAN_PROCESS eq 1>selected</cfif>><cf_get_lang dictionary_id='57705.İşleniyor'></option>
                              	<option value="0" <cfif get_shift.MASTER_PLAN_PROCESS eq 0>selected</cfif>><cf_get_lang dictionary_id='633.İşlem Bitti'></option>
                           	</select>
                        </div>
                  	</div>
               	</div> 
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                	<div class="form-group" id="item-start_date">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57655.Baslama Tarihi'> *</label>
                     	<div class="col col-4 col-xs-12">
                        	<div class="input-group">
                            	<cfsavecontent variable="message"><cf_get_lang dictionary_id ='531.Baslama Tarihi Girmelisiniz'> !</cfsavecontent>
                       			<input required="Yes"  message="#message#" type="text" name="start_date" id="start_date"  validate="eurodate" style="width:75px;" value="#dateformat(attributes.start_date,dateformat_style)#"  <cfif alt_plan_control.recordcount>readonly="yes"</cfif>> 
                            	<span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                            </div>
                      	</div>
                        <div class="col col-2 col-xs-12">
                        	<select name="start_h" id="start_h">
                               	<cfloop from="0" to="23" index="i">
                               		<option value="#i#" <cfif isdefined('attributes.start_date') and timeformat(attributes.start_date,'HH') eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#</option>
                               	</cfloop>
                          	</select>
                      	</div>
                        <div class="col col-2 col-xs-12">
                       		<select name="start_m" id="start_m">
                          		<cfloop from="0" to="59" index="i">
                                	<option value="#i#" <cfif isdefined('attributes.start_date') and timeformat(attributes.start_date,'MM') eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#</option>
                             	</cfloop>
                         	</select>
                      	</div>
                    </div>
                    <div class="form-group" id="item-finish_date">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57655.Baslama Tarihi'> *</label>
                     	<div class="col col-4 col-xs-12">
                        	<div class="input-group">
                            	<cfsavecontent variable="message"><cf_get_lang dictionary_id ='531.Baslama Tarihi Girmelisiniz'> !</cfsavecontent>
                       			<input required="Yes"  message="#message#" type="text" name="finish_date" id="finish_date"  validate="eurodate" style="width:75px;" value="#dateformat(attributes.finish_date,dateformat_style)#"  <cfif alt_plan_control.recordcount>readonly="yes"</cfif>> 
                            	<span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                            </div>
                      	</div>
                        <div class="col col-2 col-xs-12">
                        	<select name="finish_h" id="finish_h">
                               	<cfloop from="0" to="23" index="i">
                               		<option value="#i#" <cfif isdefined('attributes.finish_date') and timeformat(attributes.finish_date,'HH') eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#</option>
                               	</cfloop>
                          	</select>
                      	</div>
                        <div class="col col-2 col-xs-12">
                       		<select name="finish_m" id="finish_m">
                          		<cfloop from="0" to="59" index="i">
                                	<option value="#i#" <cfif isdefined('attributes.finish_date') and timeformat(attributes.finish_date,'MM') eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#</option>
                             	</cfloop>
                         	</select>
                      	</div>
                    </div>
                    
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                	<div class="form-group" id="item-project">
                      	<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                     	<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        	<div class="input-group">
                                <input type="hidden" name="project_id" id="project_id" value="#paper_project_id#">
                                <input type="text" name="project_head" id="project_head" value="<cfif len(paper_project_id)>#GET_PROJECT_NAME(paper_project_id)#</cfif>" style="width:200px;"onFocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','','3','135')"autocomplete="off">
                                <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_head=list_works.project_head&project_id=list_works.project_id');"></span>
                            </div>
                      	</div>
                    </div>
                    <div class="form-group" id="item-detail">
						<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açiklama'></label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        	<textarea name="detail" id="detail" style="width:200px;height:60px;">#detail#</textarea>
                        </div>
                  	</div>
                </div>
          	</cf_box_elements>
            <cf_box_footer>
				<div class="col col-6">
					<cf_record_info 
						query_name="get_shift"
						record_emp="record_emp" 
						record_date="record_date"
						update_emp="update_emp"
						update_date="update_date">
				</div>
				<div class="col col-6">
					<cfif get_shift.sayi gt 0>
						<cf_workcube_buttons is_upd='1' is_delete='0' add_function='kontrol()'>
					<cfelse>
						<cf_workcube_buttons is_upd='1' is_delete='1' add_function='kontrol()'>
					</cfif> 
				</div>            
			</cf_box_footer>
            </cfoutput>
      	</cfform>
   	</cf_box>
    <cfset _ajax_str_ = "&upd=#upd_id#">
    <cfsavecontent variable="master_plan"><cf_get_lang dictionary_id='29473.İstasyonlar'></cfsavecontent>
	<cf_box title="#master_plan#">
    	<cf_box_elements>
            <cfloop query="get_menu">
                <div class="col col-12">
                    <cfsavecontent variable="message"><font color="black"><b><cfoutput>#MENU_HEAD#</cfoutput></b></font></cfsavecontent>
                    <cf_show_ajax page_style="off" table_align="left" title="#message#" tr_id="upd_id_#PROCESS_ID#" page_url="#request.self#?fuseaction=prod.popup_ajax_ezgi_sub_plan&islem_id=#PROCESS_ID##_ajax_str_#">
                </div>
            </cfloop>
        </cf_box_elements>
	</cf_box>
</div>
<div class="col col-2 col-md-2 col-sm-2 col-xs-12" id="master_plan_boxes">
	<!--- Varliklar --->
   	<cf_get_workcube_asset asset_cat_id="-3" module_id='35' action_section='PRODUCT_TREE' action_id='#attributes.upd_id#'><br>
  	<!--- Notlar --->
  	<cf_get_workcube_note  company_id="#session.ep.company_id#" action_section='upd_id' action_id='#upd_id#'><br>
  	<!--- İç Taleplar --->
   	<cfinclude template="list_ezgi_ic_talep.cfm"><br>
   	<!---Planlama Oranı--->
   	<cfinclude template="master_plan_graph.cfm" ><br>
</div>
<script language="JavaScript">
	function kontrol()
	{
		if(process_cat_control())
			return true;
		else
			return false;
	}
</script>	