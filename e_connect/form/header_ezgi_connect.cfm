<div class="col col-12 col-xs-12">
	<cf_box>
          	<cfinput type="hidden" name="connect_money" id="connect_money" value="#get_connect_money_selected.MONEY_TYPE#">
           	<cfinput type="hidden" name="connect_rate2" id="connect_rate2" value="#TlFormat(get_connect_money_selected.RATE2,4)#">
        	<input type="hidden" name="basket_due_value" value="" />
        	<cf_box_elements>
            	<cfoutput>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="item-head">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58820.Başlık'></label>
                      	<div class="col col-8 col-xs-12">
							<cfinput type="text" name="connect_head" id="connect_head" value="#attributes.connect_head#" maxlength="150">
                     	</div>
               		</div>	
                	<div class="form-group" id="item-cat">
                     	<label class="col col-4 col-xs-12"><cf_get_lang_main no ='107.Cari Hesap'> *</label>
                      	<div class="col col-8 col-xs-12">
                         	<div class="input-group" id="item-member">
                            	<input type="hidden" name="company_id" id="company_id" value="<cfif isdefined('attributes.company_id') and len(attributes.company_id)>#attributes.company_id#</cfif>">
                            	<input type="hidden" name="consumer_reference_code" id="consumer_reference_code" value="#attributes.consumer_reference_code#">
                            	<input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
                            	<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>#attributes.consumer_id#</cfif>">	
                            	<input type="text" name="company" id="company" value="<cfif isdefined('attributes.company_id') and len(attributes.company_id)>#get_par_info(attributes.company_id,1,1,0)#<cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>#get_cons_info(attributes.consumer_id,0,0)#</cfif>" readonly style="width:125px; height:20px">	  
                            	<cfset str_linke_ait="&is_period_kontrol=0&field_comp_id=form_basket.company_id&field_partner=form_basket.partner_id&field_consumer=form_basket.consumer_id&field_comp_name=form_basket.company&field_name=form_basket.member_name&field_type=form_basket.member_type&field_revmethod_id=form_basket.paymethod_id&field_revmethod=form_basket.paymethod&field_basket_due_value_rev=form_basket.basket_due_value&field_card_payment_id=form_basket.card_paymethod_id">
                            	<span class="input-group-addon btnPointer icon-ellipsis" onClick="windowopen('#request.self#?fuseaction=objects.popup_list_all_pars#str_linke_ait#&select_list=2,3','list','popup_list_all_pars');"></span>
                         	</div>
                     	</div>
               		</div>	
                    
                    <div class="form-group require" id="item-member_name">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
                        <div class="col col-8 col-sm-12">
                            <input type="hidden" name="partner_reference_code" id="partner_reference_code" value="#attributes.partner_reference_code#">
                            <input type="hidden" name="partner_id" id="partner_id" value="<cfif isdefined('attributes.partner_id') and len(attributes.partner_id)>#attributes.partner_id#</cfif>">
                            <input type="text" name="member_name" id="member_name" readonly value="<cfif isdefined('attributes.partner_id') and len(attributes.partner_id)>#get_par_info(attributes.partner_id,0,-1,0)#<cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>#get_cons_info(attributes.consumer_id,0,0,0)#</cfif>" style="width:125px; height:20px">
                        </div>                
                    </div>
                    <div class="form-group" id="item-order_employee_id">
                  		<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="56987.Satış yapan"> *</label>
                     	<div class="col col-8 col-xs-12">
                       		<div class="input-group">
                            	<input type="hidden" name="order_employee_id" id="order_employee_id" value="<cfif Len(attributes.order_employee_id)>#attributes.order_employee_id#</cfif>">
								<input type="text" name="order_employee" id="order_employee" readonly value="<cfif Len(attributes.order_employee_id)>#get_emp_info(attributes.order_employee_id,0,0)#</cfif>" style="width:175px;" onFocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','order_employee_id','','3','125');" autocomplete="off">
                             	<span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=order_employee_id&field_name=order_employee&select_list=1','list','popup_list_positions');"></span>
                        	</div>
                   		</div>
                	</div>
              	</div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                	<div class="form-group" id="item-tel">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='63896.Telefon'></label>
                      	<div class="col col-8 col-xs-12">
                        	<div class="input-group">
								<cfinput type="text" name="connect_tel" id="connect_tel" value="#attributes.connect_tel#" maxlength="50" mask="999-999 99 99">
                                <span class="input-group-addon btnPointer icon-question" onClick="if(document.getElementById('connect_tel').value!='')windowopen('#request.self#?fuseaction=sales.popup_list_ezgi_connect_telephone&id=#attributes.connect_id#&tel='+document.getElementById('connect_tel').value+'','list');else alert('<cf_get_lang dictionary_id='30230.Telefon Girmelisiniz !'> !');"></span>
                            </div>
                     	</div>
               		</div>
                	<div class="form-group" id="item-order_date">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="30631.Tarih"> *</label>
                     	<div class="col col-8 col-xs-12">
                        	<div class="input-group">
                        	<cfsavecontent variable="message"><cf_get_lang_main no='1091.Lütfen Tarih Giriniz'></cfsavecontent>
							<cfinput type="text" name="order_date" id="order_date" placeholder="#message#" value="#Dateformat(attributes.CONNECT_DATE,dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="order_date"></span>
                            </div>
                      	</div>
                 	</div>
                    <div class="form-group" id="item-deliverdate">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57645.Teslim Tarihi'></label>
                        <div class="col col-8 col-sm-12">
                            <div class="input-group">
                                <cfinput type="text" name="deliverdate" id="deliverdate" value="#attributes.deliverdate#" validate="eurodate" maxlength="10">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="deliverdate"></span>
                            </div>
                        </div>                
                    </div>
                    <div class="form-group" id="item-process_cat">
                     	<label class="col col-4 col-xs-12"><cf_get_lang_main no='642.Süreç/Asama'> *</label>
                     	<div class="col col-8 col-xs-12">
                        	<cf_workcube_process is_upd='0' process_cat_width='125' is_detail='0' select_value='#attributes.process_stage#'>
                      	</div>
                 	</div>
                    
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                	<div class="form-group" id="item-project_head">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                        <div class="col col-8 col-sm-12">
                        <cfif attributes.sales_type eq 3>
                        	<input type="hidden" name="project_id" id="project_id" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id)>#attributes.project_id#</cfif>"> 
                       		<input type="text" name="project_head" id="project_head" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id)>#get_project_name(attributes.project_id)#</cfif>" style="width:200px; height:20px">
                        <cfelse>
                            <div class="input-group">
                                <input type="hidden" name="project_id" id="project_id" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id)>#attributes.project_id#</cfif>"> 
                                <input type="text" name="project_head" id="project_head" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id)>#get_project_name(attributes.project_id)#</cfif>" style="width:200px; height:20px" onFocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','form_basket','3','200')"autocomplete="off">
                                <span class="input-group-addon icon-ellipsis btnPointer" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=form_basket.project_head&project_id=form_basket.project_id</cfoutput>');" title="<cf_get_lang no='45.Proje Seçiniz'>"></span>

                            </div>
                      	</cfif>
                        </div>
                    </div>
                	<div class="form-group" id="item-paymethod_id">	
						<label class="col col-4"><cf_get_lang dictionary_id='58516.Ödeme Yöntemi'></label>				
						<div class="col col-8">
							<div class="input-group">
								<input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="<cfif isdefined("attributes.card_paymethod_id") and len(attributes.card_paymethod_id)>#attributes.card_paymethod_id#</cfif>">
								<input type="hidden" name="paymethod_id" id="paymethod_id" value="<cfif isdefined("attributes.paymethod_id") and len(attributes.paymethod_id)>#attributes.paymethod_id#</cfif>">
								<input type="text" name="paymethod" placeholder="" id="paymethod" value="<cfif isdefined("attributes.paymethod") and len(attributes.paymethod)>#attributes.paymethod#</cfif>">
									<span class="input-group-addon btnPointer icon-ellipsis"onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_paymethods&field_id=form_basket.paymethod_id&field_name=form_basket.paymethod&field_card_payment_id=form_basket.card_paymethod_id&field_card_payment_name=form_basket.paymethod</cfoutput>','list');"></span>
							</div>
						</div>
					</div>
                    <div class="form-group" id="item-ship_method">
                        <label class="col col-4 col-sm-12"><cf_get_lang_main no='1703.Sevk Yontemi'></label>
                        <div class="col col-8 col-sm-12">
                            <div class="input-group">
                                <input type="hidden" name="ship_method_id" id="ship_method_id" value="#attributes.ship_method#">
                                <cfif len(attributes.ship_method)>
                                    <cfinclude template="../../../../v16/sales/query/get_ship_method.cfm">
                                    <cfset ship_method = GET_SHIP_METHOD.SHIP_METHOD>
                                <cfelse>
                                    <cfset ship_method = ''>
                                </cfif>
                                <input type="text" name="ship_method_name" id="ship_method_name" value="#SHIP_METHOD#" style="width:125px; height:20px"  onFocus="AutoComplete_Create('ship_method_name','SHIP_METHOD','SHIP_METHOD','get_ship_method','','SHIP_METHOD_ID','ship_method_id','','3','125');"  autocomplete="off">
                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="windowopen('#request.self#?fuseaction=objects.popup_list_ship_methods&field_name=ship_method_name&field_id=ship_method_id','list');"></span>
                            </div>
                        </div>                
                    </div>
                    <div class="form-group" id="item-sales_type">
                        <label class="col col-4"><cf_get_lang dictionary_id='37215.Satış Tipi'></label>				
						<div class="col col-8">
							<select name="sales_type" id="sales_type">
                            	<cfif attributes.sales_type neq 3>
                                    <cfif ListFind(x_default_sales_display,1)><option value="1" <cfif attributes.sales_type eq 1>selected</cfif>><cf_get_lang dictionary_id='58645.Nakit'></option></cfif>
                                    <cfif ListFind(x_default_sales_display,2)><option value="2" <cfif attributes.sales_type eq 2>selected</cfif>><cf_get_lang dictionary_id='57798.Vadeli'></option> </cfif>
                                    <cfif ListFind(x_default_sales_display,4)><option value="4" <cfif attributes.sales_type eq 4>selected</cfif>>Kategori Bazlı İskonto</option></cfif>
                                <cfelse>
                                	<option value="3" <cfif attributes.sales_type eq 3>selected</cfif>><cf_get_lang dictionary_id='57446.Kampanya'></option>
                                </cfif> 
                            </select>
						</div>                
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                	<div class="form-group" id="item-detail">
                     	<label class="col col-4 col-xs-12"><cf_get_lang_main no='217.Açiklama'> </label>
                     	<div class="col col-8 col-xs-12">
                        	<textarea name="detail" id="detail" style="width:200px;height:100px;">#attributes.connect_detail#</textarea>
                      	</div>
                 	</div>
                    <div class="form-group" id="item-resource">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58830.İlişki Şekli'></label>
                        <div class="col col-8 col-xs-12">
                            <cf_wrk_combo 
                                name="resource"
                                query_name="GET_PARTNER_RESOURCE"
                                value="#attributes.resource_id#"
                                option_name="resource"
                                option_value="resource_id"
                                width="150">
                        </div>
                    </div>
                </div>
                </cfoutput>
         	</cf_box_elements>
    </cf_box>
</div>