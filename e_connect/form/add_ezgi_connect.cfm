<cf_xml_page_edit fuseact="sales.list_ezgi_connect">
<cfparam name="attributes.order_employee_id" default="#session.ep.USERID#">
<cfparam name="attributes.consumer_reference_code" default="">
<cfparam name="attributes.partner_reference_code" default="">
<cfparam name="attributes.price_catid" default="-2">
<cfparam name="attributes.card_paymethod_id" default="">
<cfparam name="attributes.paymethod" default="">
<cfparam name="attributes.keyword" default="">
<cfquery name="get_order_connect_id" datasource="#dsn3#">
	SELECT  
    	MEMBER_TYPE, 
        MEMBER_ID,
        ISNULL(IS_CUSTOMER_SELECT,0) AS IS_CUSTOMER_SELECT,
        ISNULL(CASH_DISCOUNT_RATE,0) CASH_DISCOUNT_RATE,
        ISNULL(FUTURE_DISCOUNT_RATE,0) FUTURE_DISCOUNT_RATE,
        ISNULL(CAMP_DISCOUNT_RATE,0) CAMP_DISCOUNT_RATE
    FROM 
    	EZGI_CONNECT_SETUP_ROW 
   	WHERE 
    	EMPLOYEE_ID = #session.ep.userid#
</cfquery>
<cfquery name="get_resource" datasource="#dsn#">
	SELECT RESOURCE_ID, RESOURCE FROM COMPANY_PARTNER_RESOURCE ORDER BY RESOURCE
</cfquery>
<cfif get_order_connect_id.recordcount>
	<cfif get_order_connect_id.MEMBER_TYPE eq 'consumer' and len(get_order_connect_id.MEMBER_ID)>
    	<cfset attributes.consumer_id = get_order_connect_id.MEMBER_ID>
    </cfif>
    <cfif get_order_connect_id.MEMBER_TYPE eq 'company' and len(get_order_connect_id.MEMBER_ID)>
    	<cfset attributes.company_id = get_order_connect_id.MEMBER_ID>
        <cfquery name="GET_PARTNER" datasource="#DSN#">
        	SELECT        
            	TOP (1) PARTNER_ID, 
                COMPANY_PARTNER_NAME +' '+ COMPANY_PARTNER_SURNAME AS PARTNER
			FROM            
            	COMPANY_PARTNER
			WHERE        
            	COMPANY_ID = #attributes.company_id# AND 
                COMPANY_PARTNER_STATUS = 1
			ORDER BY 
            	PARTNER_ID
        </cfquery>
        <cfset attributes.partner_id = GET_PARTNER.PARTNER_ID>
    </cfif>
<cfelse>
	<script type="text/javascript">
		alert("Öncelikle Hızlı Sepet Tanımlarını Yapmalısınız!");
		window.close()
	</script>
    <cfabort>
</cfif>
<cfif isdefined('attributes.ssh') and attributes.ssh eq 1>
	<cfif len(x_ssh) and isnumeric(x_ssh)>
    	<cfparam name="attributes.project_id" default="">
        <cfset attributes.x_ssh = x_ssh>
        <cfif len(x_ssh_price_cat) and isnumeric(x_ssh_price_cat)>
            <cfset attributes.x_ssh_price_cat = x_ssh_price_cat>
        </cfif>
   	<cfelse>     
      	<script type="text/javascript">
			alert("Öncelikle Sayfa Setting Bölümünden Proje ID Girmelisiniz!");
			window.close()
		</script>
		<cfabort>  	
    </cfif>
</cfif>
<style>
	/* Modern CSS Variables */
	:root {
		--primary-color: #2563eb;
		--primary-hover: #1d4ed8;
		--secondary-color: #10b981;
		--danger-color: #ef4444;
		--danger-hover: #dc2626;
		--text-primary: #1f2937;
		--text-secondary: #6b7280;
		--border-color: #e5e7eb;
		--bg-primary: #ffffff;
		--bg-secondary: #f9fafb;
		--bg-tertiary: #f3f4f6;
		--shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
		--shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
		--shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
		--radius-sm: 6px;
		--radius-md: 8px;
		--radius-lg: 12px;
		--transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	}


	/* Campaign Container - Modern Card Design */
	.campaign-container {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		min-height: auto;
		background: linear-gradient(135deg, var(--bg-primary) 0%, var(--bg-secondary) 100%);
		border-radius: var(--radius-lg);
		padding: 40px 32px;
		box-shadow: var(--shadow-lg);
		margin: 40px auto;
		border: 1px solid var(--border-color);
		max-width: 500px;
		position: relative;
		overflow: hidden;
	}

	/* Compact container when only button exists - better browser support */
	.campaign-container.compact {
		padding: 32px 40px;
		min-height: auto;
	}

	.campaign-container::before {
		content: '';
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 4px;
		background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
	}

	/* Campaign Label */
	.campaign-label {
		display: flex;
		align-items: center;
		justify-content: space-between;
		width: 100%;
		font-size: 18px;
		font-weight: 600;
		color: var(--text-primary);
		margin-bottom: 32px;
		padding: 16px;
		background: var(--bg-tertiary);
		border-radius: var(--radius-md);
	}

	.campaign-label span {
		margin-right: 16px;
		flex: 1;
	}

	/* Modern Toggle Switch */
	.switch {
		position: relative;
		display: inline-block;
		width: 56px;
		height: 30px;
		flex-shrink: 0;
	}

	.switch input {
		opacity: 0;
		width: 0;
		height: 0;
	}

	.slider {
		position: absolute;
		cursor: pointer;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background-color: #cbd5e1;
		transition: var(--transition);
		border-radius: 34px;
		box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
	}

	.slider:before {
		position: absolute;
		content: "";
		height: 24px;
		width: 24px;
		left: 3px;
		bottom: 3px;
		background-color: white;
		transition: var(--transition);
		border-radius: 50%;
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
	}

	input:checked + .slider {
		background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
	}

	input:checked + .slider:before {
		transform: translateX(26px);
	}

	input:focus + .slider {
		box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
	}

	/* Modern Button */
	.start-button {
		width: 100%;
		max-width: 320px;
		padding: 16px 32px;
		font-size: 18px;
		font-weight: 600;
		color: #ffffff;
		background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-hover) 100%);
		border: none;
		border-radius: var(--radius-md);
		cursor: pointer;
		transition: var(--transition);
		margin-top: 0;
		box-shadow: var(--shadow-md);
		letter-spacing: 0.5px;
		text-transform: uppercase;
		position: relative;
		overflow: hidden;
	}

	/* When button is alone in container */
	.campaign-container.compact .start-button {
		max-width: 280px;
		padding: 18px 40px;
		font-size: 16px;
		margin: 0;
	}

	.start-button::before {
		content: '';
		position: absolute;
		top: 50%;
		left: 50%;
		width: 0;
		height: 0;
		border-radius: 50%;
		background: rgba(255, 255, 255, 0.2);
		transform: translate(-50%, -50%);
		transition: width 0.6s, height 0.6s;
	}

	.start-button:hover {
		background: linear-gradient(135deg, var(--primary-hover) 0%, #1e40af 100%);
		transform: translateY(-2px);
		box-shadow: 0 12px 20px -5px rgba(37, 99, 235, 0.4);
	}

	.start-button:hover::before {
		width: 300px;
		height: 300px;
	}

	.start-button:active {
		transform: translateY(0);
		box-shadow: var(--shadow-sm);
	}

	/* Modern Select Styling */
	.styled-select {
		width: 100%;
		max-width: 320px;
		padding: 14px 18px;
		font-size: 16px;
		font-weight: 500;
		color: var(--text-primary);
		border: 2px solid var(--border-color);
		border-radius: var(--radius-md);
		background-color: var(--bg-primary);
		box-shadow: var(--shadow-sm);
		margin-bottom: 24px;
		transition: var(--transition);
		appearance: none;
		background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%23374151' d='M6 9L1 4h10z'/%3E%3C/svg%3E");
		background-repeat: no-repeat;
		background-position: right 18px center;
		background-size: 12px;
		padding-right: 42px;
		cursor: pointer;
	}

	.styled-select:hover {
		border-color: var(--primary-color);
		box-shadow: var(--shadow-md);
	}

	.styled-select:focus {
		border-color: var(--primary-color);
		outline: none;
		box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
	}

	.styled-select option {
		padding: 12px;
		font-weight: 500;
	}

	/* Form Group Enhancements */
	.form-group {
		margin-bottom: 24px;
	}

	.form-group label {
		font-weight: 600;
		color: var(--text-primary);
		margin-bottom: 8px;
		display: block;
		font-size: 14px;
		letter-spacing: 0.3px;
	}

	/* Modern Input Enhancements */
	.modern-input,
	.modern-textarea {
		width: 100%;
		transition: var(--transition);
		border: 2px solid var(--border-color);
		border-radius: var(--radius-sm);
		padding: 12px 16px;
		font-size: 14px;
		font-weight: 500;
		color: var(--text-primary);
		background-color: var(--bg-primary);
		box-shadow: var(--shadow-sm);
	}

	.modern-input:focus,
	.modern-textarea:focus {
		border-color: var(--primary-color);
		outline: none;
		box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1), var(--shadow-md);
	}

	.modern-input:hover,
	.modern-textarea:hover {
		border-color: #d1d5db;
	}

	.modern-input:read-only {
		background-color: var(--bg-tertiary);
		cursor: not-allowed;
		opacity: 0.8;
	}

	.modern-textarea {
		resize: vertical;
		min-height: 80px;
		font-family: inherit;
		line-height: 1.5;
	}

	/* Input Enhancements */
	input[type="text"],
	textarea,
	select {
		transition: var(--transition);
		border: 2px solid var(--border-color);
		border-radius: var(--radius-sm);
		padding: 10px 14px;
		font-size: 14px;
		color: var(--text-primary);
	}

	input[type="text"]:focus,
	textarea:focus,
	select:focus {
		border-color: var(--primary-color);
		outline: none;
		box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
	}

	/* Modern Form Container */
	.modern-form-container {
		background: var(--bg-primary);
		border-radius: var(--radius-lg);
		box-shadow: var(--shadow-lg);
		padding: 32px;
		min-height: 700px;
	}

	/* Responsive Design */
	@media (max-width: 768px) {
		.campaign-container {
			padding: 32px 24px;
			margin: 20px;
		}

		.campaign-container.compact {
			padding: 28px 24px;
		}

		.start-button,
		.styled-select {
			max-width: 100%;
		}

		.campaign-container.compact .start-button {
			max-width: 100%;
			padding: 16px 24px;
		}
	}

	/* Loading State */
	.start-button:disabled {
		opacity: 0.6;
		cursor: not-allowed;
		transform: none !important;
	}

	/* Animation */
	@keyframes fadeIn {
		from {
			opacity: 0;
			transform: translateY(10px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	.campaign-container {
		animation: fadeIn 0.5s ease-out;
	}

	/* Campaign Wrapper Styles */
	.campaign-wrapper {
		min-height: 600px;
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
	}

	.campaign-spacer {
		flex: 1;
		min-height: 200px;
	}

	.campaign-content-wrapper {
		display: flex;
		justify-content: center;
		align-items: center;
		flex-wrap: wrap;
		padding: 20px 0;
	}

	.campaign-button-wrapper {
		display: flex;
		justify-content: center;
		align-items: center;
		padding: 20px 0;
		min-height: 70px;
	}

	/* Input Group Enhancements */
	.input-group {
		position: relative;
		display: flex;
		align-items: stretch;
		width: 100%;
	}

	.input-group .modern-input {
		border-top-right-radius: 0;
		border-bottom-right-radius: 0;
	}

	.input-group-addon {
		display: flex;
		align-items: center;
		padding: 12px 16px;
		background-color: var(--bg-tertiary);
		border: 2px solid var(--border-color);
		border-left: none;
		border-radius: 0 var(--radius-sm) var(--radius-sm) 0;
		cursor: pointer;
		transition: var(--transition);
	}

	.input-group-addon:hover {
		background-color: var(--primary-color);
		color: white;
		border-color: var(--primary-color);
	}
</style>
<cf_catalystHeader>
<div class="col col-12 col-xs-12">
	<cf_box class="modern-form-container">
    	<cfform name="form_basket" method="post" action="#request.self#?fuseaction=sales.emptypopup_add_ezgi_connect">
        	<input type="hidden" name="basket_due_value" value="" />
            <cfinput type="hidden" name="employee_cash_disc_rate" value="#get_order_connect_id.CASH_DISCOUNT_RATE#" />
            <cfinput type="hidden" name="employee_future_disc_rate" value="#get_order_connect_id.FUTURE_DISCOUNT_RATE#" />
            <cfinput type="hidden" name="employee_camp_disc_rate" value="#get_order_connect_id.CAMP_DISCOUNT_RATE#" />
            <cfinput type="hidden" name="x_default_sales_type" value="#x_default_sales_type#">
        	<cf_box_elements>
            	<cfoutput>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true" <cfif get_order_connect_id.IS_CUSTOMER_SELECT eq 0>style="display:none;"</cfif>>
                        <div class="form-group" id="item-cat">
                            <label class="col col-4 col-xs-12"><cf_get_lang_main no ='107.Cari Hesap'> *</label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group" id="item-member">
                                    <input type="hidden" name="company_id" id="company_id" value="<cfif isdefined('attributes.company_id') and len(attributes.company_id)>#attributes.company_id#</cfif>">
                                    <input type="hidden" name="consumer_reference_code" id="consumer_reference_code" value="#attributes.consumer_reference_code#">
                                    <input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
                                    <input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>#attributes.consumer_id#</cfif>">	
                                    <input type="text" name="company" id="company" class="modern-input" value="<cfif isdefined('attributes.company_id') and len(attributes.company_id)>#get_par_info(attributes.company_id,1,1,0)#<cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>#get_cons_info(attributes.consumer_id,0,0)#</cfif>" readonly>	  
                                    <cfset str_linke_ait="&is_period_kontrol=0&field_comp_id=form_basket.company_id&field_partner=form_basket.partner_id&field_consumer=form_basket.consumer_id&field_comp_name=form_basket.company&field_name=form_basket.member_name&field_type=form_basket.member_type&field_revmethod_id=form_basket.paymethod_id&field_revmethod=form_basket.paymethod&field_basket_due_value_rev=form_basket.basket_due_value&field_card_payment_id=form_basket.card_paymethod_id">
                                    <span class="input-group-addon btnPointer icon-ellipsis" onClick="windowopen('#request.self#?fuseaction=objects.popup_list_pars#str_linke_ait#','list','popup_list_all_pars');"></span>
                                </div>
                            </div>
                        </div>	
                        <div class="form-group require" id="item-member_name">
                            <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
                            <div class="col col-8 col-sm-12">
                                <input type="hidden" name="partner_reference_code" id="partner_reference_code" value="#attributes.partner_reference_code#">
                                <input type="hidden" name="partner_id" id="partner_id" value="<cfif isdefined('attributes.partner_id') and len(attributes.partner_id)>#attributes.partner_id#</cfif>">
                                <input type="text" name="member_name" id="member_name" class="modern-input" value="<cfif isdefined('attributes.partner_id') and len(attributes.partner_id)>#get_par_info(attributes.partner_id,0,-1,0)#<cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>#get_cons_info(attributes.consumer_id,0,0,0)#</cfif>">
                            </div>                
                        </div>
                        <div class="form-group" id="item-process_cat">
                            <label class="col col-4 col-xs-12"><cf_get_lang_main no='642.Süreç/Asama'> *</label>
                            <div class="col col-8 col-xs-12">
                                <cf_workcube_process is_upd='0' process_cat_width='125' is_detail='0'>
                            </div>
                        </div>

                        <div class="form-group" id="item-order_employee_id">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="56987.Satış yapan"> *</label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <input type="hidden" name="order_employee_id" id="order_employee_id" value="<cfif Len(attributes.order_employee_id)>#attributes.order_employee_id#</cfif>">
                                    <input type="text" name="order_employee" id="order_employee" class="modern-input" value="<cfif Len(attributes.order_employee_id)>#get_emp_info(attributes.order_employee_id,0,0)#</cfif>" onFocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','order_employee_id','','3','125');" autocomplete="off">
                                    <span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=order_employee_id&field_name=order_employee&select_list=1','list','popup_list_positions');"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-order_date">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="30631.Tarih"> *</label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group x-14">
                                <cfsavecontent variable="message"><cf_get_lang_main no='1091.Lütfen Tarih Giriniz'></cfsavecontent>
                                <cfinput type="text" name="order_date" class="modern-input" placeholder="#message#" value="#Dateformat(now(),dateformat_style)#" validate="#validate_style#" maxlength="10">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="order_date"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-paymethod_id">	
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58516.Ödeme Yöntemi'></label>				
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="<cfif isdefined("attributes.card_paymethod_id") and len(attributes.card_paymethod_id)>#attributes.card_paymethod_id#</cfif>">
                                    <input type="hidden" name="paymethod_id" id="paymethod_id" value="<cfif isdefined("attributes.paymethod_id") and len(attributes.paymethod_id)>#attributes.paymethod_id#</cfif>">
                                    <input type="text" name="paymethod" placeholder="" id="paymethod" value="<cfif isdefined("attributes.paymethod") and len(attributes.paymethod)>#attributes.paymethod#</cfif>">
                                        <span class="input-group-addon btnPointer icon-ellipsis"onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_paymethods&field_id=form_basket.paymethod_id&field_name=form_basket.paymethod&field_card_payment_id=form_basket.card_paymethod_id&field_card_payment_name=form_basket.paymethod</cfoutput>','list');"></span>
                                </div>
                            </div>
                        </div>
                        <cfif x_default_resource_id gt 0 and get_order_connect_id.IS_CUSTOMER_SELECT eq 1>
                            <div class="form-group" id="item-resurce_type">
                            	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='51676.İlişki Tipi'></label>				
                              	<div class="col col-8 col-xs-12">
                               		<select name="resource_id" id="resource_id" class="styled-select">
                                    	<option value="0"><cf_get_lang dictionary_id='51676.İlişki Tipi'></option>
                                    	<cfloop query="get_resource">
                                        	<option value="#get_resource.RESOURCE_ID#" <cfif x_default_resource_id eq get_resource.RESOURCE_ID>selected</cfif>>#get_resource.RESOURCE#</option>
                                      	</cfloop>
                                	</select>
                            	</div>
                            </div>
                        </cfif>
                        <div class="form-group" id="item-sales_type">	
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='37215.Satış Tipi'></label>				
                            <div class="col col-8 col-xs-12">
                                <select name="sales_type" id="sales_type" class="styled-select">
                                	<cfif x_default_sales_type eq 1>
										<cfif ListFind(x_default_sales_display,1)><option value="1" selected><cf_get_lang dictionary_id='58645.Nakit'></option></cfif>
                                        <cfif ListFind(x_default_sales_display,2)><option value="2"><cf_get_lang dictionary_id='57798.Vadeli'></option></cfif>
                                        <cfif ListFind(x_default_sales_display,3)><option value="3"><cf_get_lang dictionary_id='57446.Kampanya'></option></cfif> 
                                        <cfif ListFind(x_default_sales_display,4)><option value="4">Kategori Bazlı İskonto</option></cfif>
                                    <cfelseif x_default_sales_type eq 2>
                                    	<cfif ListFind(x_default_sales_display,2)><option value="2"><cf_get_lang dictionary_id='57798.Vadeli'></option></cfif>
                                    	<cfif ListFind(x_default_sales_display,1)><option value="1" selected><cf_get_lang dictionary_id='58645.Nakit'></option></cfif>
                                        <cfif ListFind(x_default_sales_display,3)><option value="3"><cf_get_lang dictionary_id='57446.Kampanya'></option></cfif> 
                                        <cfif ListFind(x_default_sales_display,4)><option value="4">Kategori Bazlı İskonto</option></cfif>
                                    <cfelseif x_default_sales_type eq 3>
                                    	<cfif ListFind(x_default_sales_display,3)><option value="3"><cf_get_lang dictionary_id='57446.Kampanya'></option></cfif> 
                                    	<cfif ListFind(x_default_sales_display,1)><option value="1" selected><cf_get_lang dictionary_id='58645.Nakit'></option></cfif>
                                        <cfif ListFind(x_default_sales_display,2)><option value="2"><cf_get_lang dictionary_id='57798.Vadeli'></option></cfif>
                                        <cfif ListFind(x_default_sales_display,4)><option value="4">Kategori Bazlı İskonto</option></cfif>
                                    <cfelseif x_default_sales_type eq 4>
                                    	<cfif ListFind(x_default_sales_display,4)><option value="4">Kategori Bazlı İskonto</option></cfif>
                                    	<cfif ListFind(x_default_sales_display,1)><option value="1" selected><cf_get_lang dictionary_id='58645.Nakit'></option></cfif>
                                        <cfif ListFind(x_default_sales_display,2)><option value="2"><cf_get_lang dictionary_id='57798.Vadeli'></option></cfif>
                                        <cfif ListFind(x_default_sales_display,3)><option value="3"><cf_get_lang dictionary_id='57446.Kampanya'></option></cfif> 
                                    </cfif>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-detail">
                            <label class="col col-4 col-xs-12"><cf_get_lang_main no='217.Açiklama'> *</label>
                            <div class="col col-8 col-xs-12">
                                <textarea name="detail" id="detail" class="modern-textarea" rows="4"></textarea>
                            </div>
                        </div>
                    </div>
                </cfoutput>
         	</cf_box_elements>
            <cfif get_order_connect_id.IS_CUSTOMER_SELECT eq 1>
                <cf_box_footer>
                    <div class="col col-12">
                    	<cf_workcube_buttons type_format="1" is_upd='0' add_function='kontrol()'>
                    </div>
                </cf_box_footer>
            </cfif>
            <cfif ListLen(x_projects) and not isdefined('attributes.ssh')>
            	<div class="col col-12 campaign-wrapper">
                	<cfif get_order_connect_id.IS_CUSTOMER_SELECT eq 0>
                        <div class="col col-12 campaign-spacer"></div>
                        <div class="col col-12 campaign-content-wrapper">
                            <div class="col col-4 col-xs-12"></div>
                            <div class="col col-4 col-xs-12">
                            	<cfif ListLen(x_projects) gt 1>
                                	<cfquery name="get_project" datasource="#dsn#">
                                    	SELECT 
                                        	PROJECT_ID, 
                                            PROJECT_HEAD
										FROM     
                                        	PRO_PROJECTS
										WHERE  
                                        	PROJECT_ID IN (#x_projects#) AND 
                                            PROJECT_STATUS = 1
                                    </cfquery>
                                    <div class="campaign-container">
                                     	<select name="is_project" id="is_project" class="styled-select">
                                        	<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                         	<cfoutput query="get_project">
                                              	<option value="#get_project.PROJECT_ID#">#get_project.PROJECT_HEAD#</option>
                                        	</cfoutput>
                                     	</select>
                                        <cfif x_default_resource_id gt 0>
                                            <select name="resource_id" id="resource_id" class="styled-select">
                                                <option value="0"><cf_get_lang dictionary_id='51676.İlişki Tipi'></option>
                                                <cfoutput query="get_resource">
                                                    <option value="#get_resource.RESOURCE_ID#" <cfif x_default_resource_id eq get_resource.RESOURCE_ID>selected</cfif>>#get_resource.RESOURCE#</option>
                                                </cfoutput>
                                            </select>
                                    	</cfif>
                                        <button type="button" id="submit_button" class="start-button" onclick="if(kontrol()){document.forms['form_basket'].submit();}">ŞİMDİ BAŞLA</button>
                                    </div>
                                <cfelse>
                                	<div class="campaign-container">
                                    	<label class="campaign-label">
                                            <span>Kampanyalı Satış</span>
                                            <label class="switch">
                                                <input type="checkbox" name="is_project" id="is_project" checked value="<cfoutput>#x_projects#</cfoutput>">
                                                <span class="slider"></span>
                                            </label>
                                        </label>
                                        <cfif x_default_resource_id gt 0>
                                            <select name="resource_id" id="resource_id" class="styled-select">
                                                <option value="0"><cf_get_lang dictionary_id='51676.İlişki Tipi'></option>
                                                <cfoutput query="get_resource">
                                                    <option value="#get_resource.RESOURCE_ID#" <cfif x_default_resource_id eq get_resource.RESOURCE_ID>selected</cfif>>#get_resource.RESOURCE#</option>
                                                </cfoutput>
                                            </select>
                                    	</cfif>
                                        <button type="button" id="submit_button" class="start-button" onclick="if(kontrol()){document.forms['form_basket'].submit();}">ŞİMDİ BAŞLA</button>
                                    </div>
                                </cfif>
                            </div>
                            <div class="col col-4 col-xs-12"></div>
                        </div>
                        <div class="col col-12 campaign-spacer"></div>
                    </cfif>
                </div>
          	<cfelse>
            	<cfif isdefined('attributes.ssh') and attributes.ssh eq 1>
                	<input type="hidden" name="is_project" id="is_project" value="<cfoutput>#x_ssh#</cfoutput>" />
                    <input type="hidden" name="x_ssh" id="x_ssh" value="1" />
                    <cfif len(x_ssh_price_cat) and isnumeric(x_ssh_price_cat)>
                        <cfinput type="hidden" name="x_ssh_price_cat" id="x_ssh_price_cat" value="#x_ssh_price_cat#" />
                    </cfif>
                </cfif>
                <cfif get_order_connect_id.IS_CUSTOMER_SELECT eq 0>
                <div class="col col-12 campaign-wrapper">
                	<div class="col col-12 campaign-spacer"></div>
                 	<div class="col col-12 campaign-content-wrapper">
                     	<div class="col col-4 col-xs-12"></div>
                     	<div class="col col-4 col-xs-12">
                            <div class="campaign-container<cfif x_default_resource_id eq 0> compact</cfif>">
                                <cfif x_default_resource_id gt 0>
                                    <select name="resource_id" id="resource_id" class="styled-select">
                                        <option value="0"><cf_get_lang dictionary_id='51676.İlişki Tipi'></option>
                                        <cfoutput query="get_resource">
                                            <option value="#get_resource.RESOURCE_ID#" <cfif x_default_resource_id eq get_resource.RESOURCE_ID>selected</cfif>>#get_resource.RESOURCE#</option>
                                        </cfoutput>
                                    </select>
                                </cfif>
                                <button type="button" id="submit_button" class="start-button" onclick="if(kontrol()){document.forms['form_basket'].submit();}">ŞİMDİ BAŞLA</button>
                            </div>
                     	</div>
                      	<div class="col col-4 col-xs-12"></div>
                        </div>
                     	<div class="col col-12 campaign-spacer"></div>
                  	</div>   
              	</div>      
                </cfif>
           	</cfif>
        </cfform> 
    </cf_box>
</div>
<script type="text/javascript">
	/**
	 * Modern form validation function
	 * Performs comprehensive validation with user-friendly error messages
	 */
	function kontrol() {
		const form = document.forms['form_basket'];
		const errors = [];

		// Validate process stage
		if (!form.process_stage || form.process_stage.value.trim().length === 0) {
			errors.push({
				field: 'process_stage',
				message: "<cf_get_lang_main no='1430.Lütfen Süreç Seçiniz'>"
			});
		}

		// Validate customer/company selection
		const companyId = form.company_id ? form.company_id.value : '';
		const consumerId = form.consumer_id ? form.consumer_id.value : '';
		const companyName = form.company ? form.company.value : '';
		
		if (companyId.length === 0 && consumerId.length === 0 && companyName.trim().length === 0) {
			errors.push({
				field: 'company',
				message: "<cf_get_lang no='254.Cari Hesap Secmelisiniz'>"
			});
		}

		// Validate order date
		if (!form.order_date || form.order_date.value.trim().length === 0) {
			errors.push({
				field: 'order_date',
				message: '<cf_get_lang dictionary_id="45761.Tarih Alanı Boş Olmamalıdır !">'
			});
		}

		// Validate sales type
		const salesTypeEl = document.getElementById('sales_type');
		if (!salesTypeEl || salesTypeEl.value === '') {
			errors.push({
				field: 'sales_type',
				message: '<cf_get_lang dictionary_id="57471.Eksik Veri"> : <cf_get_lang dictionary_id="37215.Satış Tipi">'
			});
		}

		// Validate resource type if required
		<cfif x_default_resource_id gt 0>
		const resourceEl = document.getElementById('resource_id');
		if (resourceEl && resourceEl.value === '0') {
			errors.push({
				field: 'resource_id',
				message: '<cf_get_lang dictionary_id="57471.Eksik Veri"> : <cf_get_lang dictionary_id="51676.İlişki Tipi">'
			});
		}
		</cfif>

		// Display first error and focus on field
		if (errors.length > 0) {
			const firstError = errors[0];
			alert(firstError.message);
			
			const errorField = document.getElementById(firstError.field);
			if (errorField) {
				errorField.focus();
				errorField.style.borderColor = 'var(--danger-color)';
				setTimeout(() => {
					errorField.style.borderColor = '';
				}, 3000);
			}
			
			return false;
		}

		// Validate process category control
		if (typeof process_cat_control === 'function') {
			return process_cat_control();
		}
		
		return true;
	}

	// Add modern form enhancements on page load
	document.addEventListener('DOMContentLoaded', function() {
		// Add compact class to campaign containers with only button
		const campaignContainers = document.querySelectorAll('.campaign-container');
		campaignContainers.forEach(container => {
			const children = Array.from(container.children);
			const hasOnlyButton = children.length === 1 && 
				(children[0].classList.contains('start-button') || 
				 children[0].tagName === 'BUTTON' && children[0].classList.contains('start-button'));
			
			if (hasOnlyButton) {
				container.classList.add('compact');
			}
		});

		// Add smooth focus transitions to all inputs
		const inputs = document.querySelectorAll('.modern-input, .modern-textarea, .styled-select');
		inputs.forEach(input => {
			input.addEventListener('focus', function() {
				this.parentElement?.classList.add('focused');
			});
			
			input.addEventListener('blur', function() {
				this.parentElement?.classList.remove('focused');
			});
		});

		// Enhance submit button with loading state
		const submitButton = document.getElementById('submit_button');
		if (submitButton) {
			submitButton.addEventListener('click', function(e) {
				const form = document.forms['form_basket'];
				if (form && typeof kontrol === 'function') {
					if (kontrol()) {
						// Add loading state
						this.disabled = true;
						this.style.opacity = '0.6';
						this.style.cursor = 'wait';
						this.innerHTML = 'Yükleniyor...';
						form.submit();
					}
				}
			});
		}
	});
</script>