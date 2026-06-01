
<!---
    File: header_ezgi_virtual_offer.cfm
    Folder: Add_Ons\ezgi\e_sales\form
    Author: Ezgi Yazılım
    Date: 01/01/2022
    Description:
--->
<cfoutput>
	<cf_box closable="0">
		<cf_box_elements>
			<div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="1" sort="true">
            	<div class="col col-3 col-md-4 col-sm-12">
                    <div class="col col-3 col-sm-12" id="item-virtual_offer_status">
                        <label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'>
                        <input type="checkbox" name="virtual_offer_status" id="virtual_offer_status" value="1" <cfif isdefined("get_virtual_offer.virtual_offer_status") and get_virtual_offer.virtual_offer_status eq 1>checked</cfif>></label>
                    </div>
                  	<div class="col col-6 col-sm-12" id="item-is_cost_discount">
                    	<label class="col col-12 col-md-12 col-sm-12 col-xs-12">Hizmet İndirime Girmez
                     	<input type="checkbox" name="is_cost_discount" id="is_cost_discount" value="1" onClick="yeniden_hesapla()" <cfif attributes.is_cost_discount eq 1>checked</cfif>></label>
                   	</div>
                    <div class="form-group col col-2 col-md-2 col-sm-6 col-xs-12" id="item-is_cancel">
                    	<cfif isdefined("attributes.virtual_offer_id")>
                        <label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='58506.İptal'>
                        <input type="checkbox" name="is_cancel" id="is_cancel" value="1" onClick="cancel_change();" <cfif isdefined("get_virtual_offer.is_cancel") and get_virtual_offer.is_cancel eq 1>checked</cfif>></label>
                        </cfif>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-12">
                	<div class="col col-6 col-sm-12" id="item-is_foreign">
                    	<label class="col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='39332.Yurtdışı Satış'>
                     	<input type="checkbox" name="is_foreign" id="is_foreign" value="1" onClick="foreign_sales()" <cfif isdefined("get_virtual_offer.is_foreign") and get_virtual_offer.is_foreign eq 1>checked</cfif>></label>
                   	</div>
                </div>
                <cfif isdefined("attributes.virtual_offer_id")>
                    <div class="col col-3 col-md-4 col-sm-12" style="<cfif isdefined("get_virtual_offer.is_cancel") and get_virtual_offer.is_cancel eq 1><cfelse>display:none</cfif>" id="is_cancel_div">
                        <div class="form-group require" id="item-cancel">
                            <label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='58825.İptal Nedeni'></label>
                            <div class="col col-8 col-sm-12">
                                <select name="cancel_id" id="cancel_id">
                                    <option value="" <cfif get_virtual_offer.CANCEL_ID eq ''>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfloop query="get_cancel">
                                        <option value="#get_cancel.EZGI_VIRTUAL_OFFER_CANCEL_ID#" <cfif get_virtual_offer.CANCEL_ID eq get_cancel.EZGI_VIRTUAL_OFFER_CANCEL_ID>selected</cfif>>#get_cancel.EZGI_VIRTUAL_OFFER_CANCEL#</option>
                                    </cfloop>
                                </select>
                            </div>                
                        </div>
                    </div>
                </cfif>
          	</div>
            <div class="col col-3 col-md-4 col-sm-12" type="column" index="2" sort="true">
            	<div class="form-group require" id="item-order_head">
					<label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='58820.Başlık'></label>
					<div class="col col-8 col-sm-12">
						<input type="text" maxlength="50" name="virtual_offer_head" id="virtual_offer_head" value="<cfif isDefined("attributes.virtual_offer_head") and len(attributes.virtual_offer_head)>#attributes.virtual_offer_head#</cfif>" required="yes" style="width:320px; height:20px" <cfif attributes.kilit_stage>readonly</cfif>>
					</div>                
				</div>
                <div class="form-group require" id="item-company">
					<label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='57519.Cari Hesap'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
                        	 <input type="hidden" name="company_id" id="company_id" value="<cfif isdefined('attributes.company_id') and len(attributes.company_id)>#attributes.company_id#</cfif>">
                            <input type="hidden" name="consumer_reference_code" id="consumer_reference_code" value="#attributes.consumer_reference_code#">
                            <input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
                            <input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>#attributes.consumer_id#</cfif>">	
                            <input type="text" name="company" id="company" value="<cfif isdefined('attributes.company_id') and len(attributes.company_id)>#get_par_info(attributes.company_id,1,1,0)#<cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>#get_cons_info(attributes.consumer_id,0,0)#</cfif>" readonly style="width:125px; height:20px">	  
                            <cfset str_linke_ait="&is_period_kontrol=0&field_comp_id=form_basket.company_id&field_partner=form_basket.partner_id&field_consumer=form_basket.consumer_id&field_comp_name=form_basket.company&field_name=form_basket.member_name&field_type=form_basket.member_type">
                            <span class="input-group-addon btnPointer icon-ellipsis" <cfif not attributes.kilit_stage>onClick="windowopen('#request.self#?fuseaction=objects.popup_list_pars#str_linke_ait#&call_function=get_money_type()','list','popup_list_all_pars');"</cfif>></span>
						</div>
					</div>                
				</div>
                <div class="form-group require" id="item-member_name">
					<label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
					<div class="col col-8 col-sm-12">
                    	<input type="hidden" name="partner_reference_code" id="partner_reference_code" value="#attributes.partner_reference_code#">
                		<input type="hidden" name="partner_id" id="partner_id" value="<cfif isdefined('attributes.partner_id') and len(attributes.partner_id)>#attributes.partner_id#</cfif>">
                		<input type="text" name="member_name" id="member_name" value="<cfif isdefined('attributes.partner_id') and len(attributes.partner_id)>#get_par_info(attributes.partner_id,0,-1,0)#<cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>#get_cons_info(attributes.consumer_id,0,0,0)#</cfif>" style="width:125px; height:20px" <cfif attributes.kilit_stage>readonly</cfif>>
					</div>                
				</div>
                <div class="form-group require" id="item-order_employee">
                    <label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='41159.Satış Çalışanı'></label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="hidden" name="order_employee_id" id="order_employee_id" value="<cfif Len(attributes.order_employee_id)>#attributes.order_employee_id#</cfif>">
                            <input type="text" name="order_employee" id="order_employee" value="<cfif Len(attributes.order_employee_id)>#get_emp_info(attributes.order_employee_id,0,0)#</cfif>" onFocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','order_employee_id','','3','125');" autocomplete="off">
                            <cfif session.ep.isBranchAuthorization>
                                <span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.order_employee_id&field_name=form_basket.order_employee&is_store_module=1&select_list=1');"></span>
                            <cfelse>
                                <span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.order_employee_id&field_name=form_basket.order_employee&select_list=1');"></span>
                            </cfif>
                        </div>
                    </div>                
                </div>
                <div class="form-group require" id="item-ref_no">
					<label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='58794.Referans No'></label>
					<div class="col col-8 col-sm-12">
						<input type="text" name="ref_no" id="ref_no" value="<cfif isdefined('attributes.ref_no') and len(attributes.ref_no)>#attributes.ref_no#</cfif>" maxlength="50" <cfif attributes.kilit_stage>readonly</cfif>>
					</div>                
				</div>
           	</div>
            
            <div class="col col-3 col-md-4 col-sm-12" type="column" index="3" sort="true">
				<div class="form-group require" id="item-order_date">
					<label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='46831.Teklif Tarihi'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<cfsavecontent variable="message">Teklif Tarihi Girmelisiniz !</cfsavecontent>
                			<cfinput type="text" name="virtual_offer_date" id="virtual_offer_date" required="yes" value="#attributes.virtual_offer_date#" validate="eurodate" message="#message#" maxlength="10" readonly>
							<span class="input-group-addon"><cfif not attributes.kilit_stage><cf_wrk_date_image date_field="virtual_offer_date"></cfif></span>
						</div>
					</div>                
				</div>
                <div class="form-group require" id="item-deliverdate">
					<label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='1196.Üretim Çıkış Tarihi'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
							<cfinput type="text" name="deliverdate" id="deliverdate" value="#attributes.deliverdate#" validate="eurodate" maxlength="10">
							<span class="input-group-addon"><cf_wrk_date_image date_field="deliverdate"></span>
						</div>
					</div>                
				</div>
                <div class="form-group require" id="item-ship_date">
					<label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='57747.Sözleşme Tarihi'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
                        	<cfif session.ep.admin>
                            	<cfinput type="text" name="finishdate" id="finishdate" value="#attributes.finishdate#" validate="eurodate" maxlength="10">
                            <cfelse>
								<cfinput type="text" name="finishdate" id="finishdate" value="#attributes.finishdate#" validate="eurodate" maxlength="10" readonly="yes">
                            </cfif>
						</div>
					</div>                
				</div>
                <div class="form-group require" id="item-ship_method">
					<label class="col col-3 col-sm-12"><cf_get_lang_main no='1703.Sevk Yontemi'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
                        	<input type="hidden" name="ship_method_id" id="ship_method_id" value="#attributes.ship_method#">
							<cfif len(attributes.ship_method)>
                                <cfinclude template="../../../../v16/sales/query/get_ship_method.cfm">
                                <cfset ship_method = GET_SHIP_METHOD.SHIP_METHOD>
                            <cfelse>
                                <cfset ship_method = ''>
                            </cfif>
	        				<input type="text" name="ship_method_name" id="ship_method_name" value="#SHIP_METHOD#" style="width:125px; height:20px"  <cfif not attributes.kilit_stage>onFocus="AutoComplete_Create('ship_method_name','SHIP_METHOD','SHIP_METHOD','get_ship_method','','SHIP_METHOD_ID','ship_method_id','','3','125');"</cfif>  autocomplete="off">
                            <span class="input-group-addon btnPointer icon-ellipsis" <cfif not attributes.kilit_stage>onClick="windowopen('#request.self#?fuseaction=objects.popup_list_ship_methods&is_form_submitted=1&field_name=ship_method_name&field_id=ship_method_id','list');"</cfif>></span>
						</div>
					</div>                
				</div>
                <div class="form-group require" id="item-ship_address">
                    <label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='58449.Teslim Yeri'></label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                        <!--- Uye Bilgilerinden gelindiginde teslim yeri alaninin dolu gelmesi icin eklendi --->
                            <cfif isdefined('attributes.company_id') and len(attributes.company_id) and not isdefined("attributes.ship_address")><!--- Siparis kopyalandiginda yanlis adres yaziyordu ship_address yazildi --->
                                <cfquery name="get_ship_address" datasource="#dsn#">
                                    SELECT
                                        TOP 1 *
                                    FROM
                                        (	SELECT 0 AS TYPE,COMPBRANCH_ID,COMPBRANCH_ADDRESS AS ADDRESS,POS_CODE,SEMT,COUNTY_ID AS COUNTY,CITY_ID AS CITY,COUNTRY_ID AS COUNTRY FROM COMPANY_BRANCH WHERE IS_SHIP_ADDRESS = 1 AND COMPANY_ID = #attributes.company_id# 
                                            UNION
                                            SELECT 1 AS TYPE,-1 COMPBRANCH_ID,COMPANY_ADDRESS AS ADDRESS,POS_CODE,SEMT,COUNTY,CITY,COUNTRY FROM COMPANY WHERE COMPANY_ID = #attributes.company_id#
                                        ) AS TYPE
                                    ORDER BY
                                        TYPE 
                                </cfquery>
                                <cfset address_ = get_ship_address.address>
                                <cfset attributes.ship_address_id_ = get_ship_address.COMPBRANCH_ID>
                                <cfif len(get_ship_address.pos_code) and len(get_ship_address.semt)>
                                    <cfset address_ = "#address_# #get_ship_address.pos_code# #get_ship_address.semt#">
                                </cfif>
                                <cfif len(get_ship_address.county)>
                                    <cfquery name="get_county_name" datasource="#dsn#">
                                        SELECT COUNTY_ID,COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = #get_ship_address.county#
                                    </cfquery>
                                    <cfset attributes.ship_address_county_id = get_county_name.county_id>
                                    <cfset address_ = "#address_# #get_county_name.county_name#">
                                </cfif>
                                <cfif len(get_ship_address.city)>
                                    <cfquery name="get_city_name" datasource="#dsn#">
                                        SELECT CITY_ID,CITY_NAME FROM SETUP_CITY WHERE CITY_ID = #get_ship_address.city#
                                    </cfquery>
                                    <cfset attributes.ship_city_id = get_city_name.city_id>
                                    <cfset address_ = "#address_# #get_city_name.city_name#">
                                </cfif>
                                <cfif len(get_ship_address.country)>
                                    <cfquery name="get_country_name" datasource="#dsn#">
                                        SELECT COUNTRY_NAME FROM SETUP_COUNTRY WHERE COUNTRY_ID = #get_ship_address.country#
                                    </cfquery>
                                    <cfset address_ = "#address_# #get_country_name.country_name#">
                                </cfif>
                            <cfelseif isdefined("attributes.ship_address")>
                                <cfset address_ = attributes.ship_address>
                            </cfif>
                            <!--- //Uye Bilgilerinden gelindiginde teslim yeri alaninin dolu gelmesi icin eklendi --->
                            <input type="hidden" name="ship_address_city_id" id="ship_address_city_id" value="<cfif isdefined('attributes.ship_city_id') and len(attributes.ship_city_id)>#attributes.ship_city_id#</cfif>">
                            <input type="hidden" name="ship_address_county_id" id="ship_address_county_id" value="<cfif isDefined("attributes.ship_address_county_id") and len(attributes.ship_address_county_id)>#attributes.ship_address_county_id#</cfif>">
                            <input type="hidden" name="deliver_comp_id" id="deliver_comp_id" value="<cfif isdefined('attributes.deliver_comp_id') and len(attributes.deliver_comp_id)>#attributes.deliver_comp_id#</cfif>">
                            <input type="hidden" name="deliver_cons_id" id="deliver_cons_id" value="<cfif isDefined("attributes.deliver_cons_id") and len(attributes.deliver_cons_id)>#attributes.deliver_cons_id#</cfif>">
                            <input type="hidden" name="ship_address_id" id="ship_address_id" value="<cfif isdefined('attributes.ship_address_id_') and len(attributes.ship_address_id_)>#attributes.ship_address_id_#</cfif>">
                            <input type="text" name="ship_address" id="ship_address" maxlength="500" value="<cfif isdefined('address_') and len(address_)>#address_#</cfif>">
                            <span class="input-group-addon icon-ellipsis" onClick="add_adress();"></span>
                        </div>
                    </div>                
                </div> 
         	</div>
            <div class="col col-3 col-md-4 col-sm-12" type="column" index="4" sort="true">
				<div class="form-group require" id="item-process_stage">
				<label class="col col-3 col-sm-12"><cf_get_lang dictionary_id="58859.Süreç"></label>
					<div class="col col-8 col-sm-12">
						<cfif isdefined('attributes.virtual_offer_id') and len(attributes.virtual_offer_id)>
                            <cf_workcube_process is_upd='0' select_value='#get_virtual_offer.virtual_offer_STAGE#' process_cat_width='125' is_detail='1'>
                        <cfelse>
                            <cf_workcube_process is_upd='0' process_cat_width='125' is_detail='0'>
                        </cfif>
					</div>                
				</div>
                <div class="form-group require" id="item-branch">
					<label class="col col-3 col-sm-12"><cf_get_lang_main no='41.Şube'></label>
					<div class="col col-8 col-sm-12">
						<select name="branch_id" style="width:125px; height:20px" <cfif attributes.kilit_stage>disabled</cfif>>
                            <option value=""><cf_get_lang_main no='2329.Şube Seçiniz'></option>
                            <cfloop query="get_branch">
                                <option value="#get_branch.BRANCH_ID#" <cfif get_branch.BRANCH_ID eq attributes.branch_id>selected</cfif>>#BRANCH_NAME#</option>
                            </cfloop>
                        </select>
                        <cfif attributes.kilit_stage>
                        	<cfinput value="#attributes.branch_id#" name="branch_id" type="hidden">
                        </cfif>
					</div>                
				</div>
                <div class="form-group require" id="item-vade">
					<label class="col col-3 col-sm-12"><cf_get_lang_main no ='228.Vade'></label>
					<div class="col col-2 col-sm-12">
						<input type="text" name="basket_due_value" id="basket_due_value" value="<cfif isdefined("attributes.basket_due_value") and len(attributes.basket_due_value)>#attributes.basket_due_value#</cfif>">
                  	</div>
                   	<div class="col col-6 col-sm-12">
                    	<div class="input-group">
                			<cfinput type="text" name="basket_due_value_date_" id="basket_due_value_date_" value="#attributes.basket_due_value_date_#"  validate="eurodate" message="#message#" maxlength="10" style="width:70px; height:20px" readonly>
                        	<span class="input-group-addon"><cfif not attributes.kilit_stage><cf_wrk_date_image date_field="basket_due_value_date_"></cfif></span>
                      	</div>
					</div>                
				</div>
                <div class="form-group require" id="item-priority">
					<label class="col col-3 col-sm-12"><cf_get_lang_main no ='73.Öncelik'></label>
					<div class="col col-8 col-sm-12">
						<select name="priority_id" id="priority_id" style="width:125px; height:20px" <cfif attributes.kilit_stage>disabled</cfif>>
                            <cfloop query="get_priorities">
                            <option value="#priority_id#" <cfif (isdefined("attributes.priority_id") and attributes.priority_id eq priority_id) or (not isdefined("attributes.priority_id") and priority_id eq 1)>selected</cfif>>#priority#</option>
                            </cfloop>
                        </select>
					</div>                
				</div>
                <div class="form-group require" id="item-deliver_dept_name">
                    <label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='58763.Depo'></label>
                    <div class="col col-8 col-sm-12">
                        <cf_wrkdepartmentlocation 
                            returnInputValue="deliver_loc_id,deliver_dept_name,deliver_dept_id,branch_id"
                            returnQueryValue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID,BRANCH_ID"
                            fieldName="deliver_dept_name"
                            fieldid="deliver_loc_id"
                            department_fldId="deliver_dept_id"
                            branch_fldId="branch_id"
                            branch_id="#attributes.branch_id#"
                            department_id="#attributes.deliver_dept_id#"
                            location_id="#attributes.deliver_loc_id#"
                            location_name="#attributes.deliver_dept_name#"
                            user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
                            xml_all_depo = "#IIf(isDefined("x_dsp_all_departmants") and x_dsp_all_departmants eq 1,'1',de('0'))#"
                            width="140">
                    </div>                
                </div>
          	</div>
            <div class="col col-3 col-md-4 col-sm-12" type="column" index="5" sort="true">
            	<div class="form-group require" id="item-bayi">
					<label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='41422.Bayi Adı'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
             				<input type="hidden" name="sales_member_id" id="sales_member_id" value="#attributes.sales_partner_id#">
	          				<input type="hidden" name="sales_member_type" id="sales_member_type" value="partner">
	          				<input type="text" name="sales_member" id="sales_member" value="#get_par_info(attributes.sales_partner_id,0,-1,0)#" <cfif not attributes.kilit_stage>onFocus="AutoComplete_Create('sales_member','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME2,MEMBER_NAME2','get_member_autocomplete','\'1,2\',0,0,0','PARTNER_CODE,MEMBER_TYPE','sales_member_id,sales_member_type','','3','250');"</cfif> autocomplete="off" style="width:200px; height:20px">
                            <span class="input-group-addon btnPointer icon-ellipsis" <cfif not attributes.kilit_stage>onClick="windowopen('#request.self#?fuseaction=objects.popup_list_pars&is_rate_select=1&field_id=form_basket.sales_member_id&field_name=form_basket.sales_member&field_type=form_basket.sales_member_type&select_list=2,3','list','popup_list_pars');"</cfif>></span>
						</div>
					</div>                
				</div>
				<div class="form-group require" id="item-detail">
					<label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
					<div class="col col-8 col-sm-12">
                    	<textarea name="detail" id="detail"><cfif isdefined("attributes.virtual_offer_detail") and len(attributes.virtual_offer_detail)>#attributes.virtual_offer_detail#<cfelseif isdefined("get_subscription.subscription_detail") and len(get_subscription.subscription_detail)>#get_subscription.subscription_detail#</cfif></textarea>
					</div>                
				</div>
                <div class="form-group require" id="item-project_head">
					<label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='57416.Proje'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
                        	<input type="hidden" name="project_id" id="project_id" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id)>#attributes.project_id#</cfif>"> 
                			<input type="text" name="project_head" id="project_head" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id)>#get_project_name(attributes.project_id)#</cfif>" style="width:200px; height:20px" <cfif not attributes.kilit_stage>onFocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','form_basket','3','200')" autocomplete="off"</cfif>>
                            <span class="input-group-addon icon-ellipsis btnPointer" <cfif not attributes.kilit_stage>onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=form_basket.project_head&project_id=form_basket.project_id</cfoutput>');" title="<cf_get_lang no='45.Proje Seçiniz'>"</cfif>></span>

							<span class="input-group-addon btnPointer icon-question" onClick="if(document.getElementById('project_id').value!='')windowopen('#request.self#?fuseaction=project.popup_list_project_actions&from_paper=ORDERS&id='+document.getElementById('project_id').value+'','horizantal');else alert('<cf_get_lang dictionary_id='58797.Proje Seçiniz'> !');"></span>
                        </div>
                  	</div>
               	</div>
                <div class="form-group require" id="item-paymethod">
					<label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='58516.Ödeme Yontemi'></label>
					<div class="col col-8 col-sm-12">
						<div class="input-group">
                        	<cfset card_link="&field_card_payment_id=form_basket.card_paymethod_id&field_card_payment_name=form_basket.paymethod&field_commission_rate=form_basket.commission_rate&field_paymethod_vehicle=form_basket.paymethod_vehicle">
							<cfif len(attributes.paymethod_id)>
                                <cfinclude template="../../../../v16/sales/query/get_paymethod.cfm">
                                <input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="">
                                <input type="hidden" name="commission_rate" id="commission_rate" value="">
                                <input type="hidden" name="paymethod_vehicle" id="paymethod_vehicle" value="#get_paymethod.payment_vehicle#">
                                <input type="hidden" name="paymethod_id" id="paymethod_id" value="#attributes.paymethod_id#">
                                <input type="text" name="paymethod" id="paymethod" value="#get_paymethod.paymethod#" style="width:200px; height:20px" readonly>
                            <cfelse>
                                <input type="hidden" name="paymethod_vehicle" id="paymethod_vehicle" value="">
                                <input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="">
                                <input type="hidden" name="commission_rate" id="commission_rate" value="">
                                <input type="hidden" name="paymethod_id" id="paymethod_id" value="">
                                <input type="text" name="paymethod" id="paymethod" value="" style="width:200px; height:20px" readonly>
                            </cfif>
                            <span class="input-group-addon btnPointer icon-ellipsis" <cfif not attributes.kilit_stage>onClick="windowopen('#request.self#?fuseaction=objects.popup_paymethods&function_name=change_paper_duedate&function_parameter=order_date&field_id=form_basket.paymethod_id&field_name=form_basket.paymethod&field_dueday=form_basket.basket_due_value#card_link#','list');"</cfif>></span>
                        </div>
                  	</div>
              	</div>
          	</div>
       	</cf_box_elements>
		<div class="row formContentFooter"> 
			<div class="col col-12 text-right">    
				<cfif isdefined("attributes.virtual_offer_id")>
                    <cf_record_info query_name="get_virtual_offer">
                    <cfif is_revision_small eq 0>
                        <cfif get_del_control.recordcount or attributes.kilit_stage>
                            <cfif get_del_control.recordcount><span style="color:red; font-weight:bold">Gerçek Teklife Dönüştü</span></cfif>
                            <cf_basket_form_button>
                                <cf_workcube_buttons 
                                    is_upd='1' 
                                    is_delete='0'
                                    add_function='kontrol()'
                                >
                            </cf_basket_form_button>
                        <cfelse>
                            <cf_basket_form_button>
                                <cf_workcube_buttons 
                                    is_upd='1' 
                                    add_function='kontrol()'
                                    del_function_for_submit='del_kontrol()'
                                >
                            </cf_basket_form_button>
                        </cfif>
                    </cfif>
                <cfelse>
                    <cf_basket_form_button><cf_workcube_buttons is_upd='0' add_function='kontrol()'></cf_basket_form_button>
                </cfif>                
			</div>
		</div>	
	</cf_box>
</cfoutput>
<script type="text/javascript">
	function cancel_change()
	{
		if(document.getElementById('is_cancel').checked==true)
			document.getElementById('is_cancel_div').style.display='';
		else
			document.getElementById('is_cancel_div').style.display='none';
	}
	function foreign_sales()
	{
		sor = confirm('<cf_get_lang dictionary_id='60056.Ürünlerin KDV Oranları Sıfırlanacaktır'>');
		if(sor == true)
		{
			for (var r=1;r<=document.form_basket.record_num.value;r++)
			{
				document.getElementById('tax'+r).value =0;	
				hesapla(r);
			}
		}
			
	}
	function get_money_type()
	{
		/*alert(document.getElementById('company_id').value);
		var money_sql = "SELECT CCM.MONEY_TYPE FROM COMPANY_CREDIT AS CC INNER JOIN COMPANY_CREDIT_MONEY AS CCM ON CC.COMPANY_CREDIT_ID = CCM.ACTION_ID WHERE CCM.IS_SELECTED = 1 AND COMPANY_ID = "+document.getElementById('company_id').value;
		var get_vitrual_offer_money = wrk_query(money_sql,'dsn');*/

	
	}
	function kontrol()
	{
		<cfif isdefined("attributes.virtual_offer_id")>
			<cfif len(GET_DEFAULTS.VIRTUAL_OFFER_STAGES_1)>
				listem = <cfoutput>#GET_DEFAULTS.VIRTUAL_OFFER_STAGES_1#;</cfoutput>
				/*var sql = "SELECT ISNULL(SUM(TOTAL), 0) AS TOPLAM FROM EZGI_VIRTUAL_OFFER_PAYMENT WHERE VIRTUAL_OFFER_ID = "+<cfoutput>#virtual_offer_id#</cfoutput>;*/
				/*cnt_offer = wrk_query(sql,'dsn3');*/
				
				var listParam = <cfoutput>#virtual_offer_id#</cfoutput>;
				var cnt_offer = wrk_safe_query('get_v_offer_stage_virtual_offer_id_ezgi','dsn3',0,listParam);
			
				if(list_find(listem,form_basket.process_stage.value)  && cnt_offer.TOPLAM != parseFloat(filterNum(document.getElementById('sub_total_end_other').value,2))) 
				{
					alert('Sözleşme İmzalandı Sürecinden Önce - Lütfen Ödeme Bilgilerini Tam Olarak Giriniz!!!');
					return false;
				}
			</cfif>
		</cfif>
		for (var r=1;r<=document.form_basket.record_num.value;r++)
		{
			if(parseFloat(filterNum(document.getElementById('quantity'+r).value,2))==0)
			{
				alert("<cf_get_lang dictionary_id='60509.Ürün Miktarı 0 Olamaz'>");
				return false;	
			}
		}
		if(row_count==0)
		{
			alert("<cf_get_lang dictionary_id='646.Kaydedilecek Satır Bulunamadı'>");
			return false;
		}
		if(document.getElementById('is_cancel').checked==true && document.getElementById('cancel_id').value=='')
		{

			alert("<cf_get_lang dictionary_id='41140.İptal Nedeni Seçmediniz'>");
			return false;
		}
		if(form_basket.process_stage.value.length == 0)
		{
			alert("<cf_get_lang_main no='1430.Lütfen Süreç Seçiniz'>");
			return false;
		}
		if(form_basket.company_id.value.length == 0 && form_basket.consumer_id.value.length == 0)
		{
			alert("<cf_get_lang no='254.Cari Hesap Secmelisiniz'>");
			return false;
		}
		if (form_basket.deliverdate.value.length == 0)
		{
			alert("Teslim Tarihi Girmelisiniz!");
			return false;
		}
		if (!date_check(document.form_basket.virtual_offer_date,document.form_basket.deliverdate,"Sipariş Teslim Tarihi, Sipariş Tarihinden Önce Olamaz !"))
			return false;
		if(process_cat_control())
			return true;
		else
			return false;

	}
	function add_adress()
	{
		if(!(form_basket.company_id.value=="") || !(form_basket.consumer_id.value==""))
		{
			if(form_basket.company_id.value!="")
				{
					str_adrlink = '&field_long_adres=form_basket.ship_address&field_adress_id=form_basket.ship_address_id';
					str_adrlink = str_adrlink+'&company_id='+form_basket.company_id.value+'&member_type=partner&member_name='+encodeURIComponent(form_basket.company.value)+'';
	//				str_adrlink = str_adrlink+'&company_id='+form_basket.company_id.value+'&member_type='+form_basket.member_type.value+'&member_name='+encodeURIComponent(form_basket.company.value)+'';
					if(form_basket.ship_address_city_id!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.ship_address_city_id';
					if(form_basket.ship_address_county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.ship_address_county_id&field_id=form_basket.deliver_comp_id';
					openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=1&select_list=1'+ str_adrlink);
					document.getElementById('deliver_cons_id').value = '';
					return true;
				}
			else
				{
					str_adrlink = '&field_long_adres=form_basket.ship_address&field_adress_id=form_basket.ship_address_id'; 
					str_adrlink = str_adrlink+'&consumer_id='+form_basket.consumer_id.value+'&member_type=consumer&member_name='+encodeURIComponent(form_basket.member_name.value)+'';
	//				str_adrlink = str_adrlink+'&consumer_id='+form_basket.consumer_id.value+'&member_type='+form_basket.member_type.value+'&member_name='+encodeURIComponent(form_basket.member_name.value)+'';
					if(form_basket.ship_address_city_id!=undefined) str_adrlink = str_adrlink+'&field_city=form_basket.ship_address_city_id';
					if(form_basket.ship_address_county_id!=undefined) str_adrlink = str_adrlink+'&field_county=form_basket.ship_address_county_id&field_id=form_basket.deliver_cons_id';
					openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_member_address&is_comp=0&select_list=2'+ str_adrlink);
					document.getElementById('deliver_comp_id').value = '';
					return true;
				}
		}
		else
		{
			alert("<cfoutput>#getLang('','Cari Hesap Secmelisiniz',41056)#</cfoutput>");
			return false;
		}
	}
	
	<cfif isdefined("attributes.virtual_offer_id")>
	function del_kontrol()
	{
		window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_virtual_offer&virtual_offer_id=#attributes.virtual_offer_id#</cfoutput>";
		return true;
	}
	</cfif>
</script>         