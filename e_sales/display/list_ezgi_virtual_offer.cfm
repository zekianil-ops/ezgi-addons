<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.offer_stage" default="">
<cfparam name="attributes.sort_type" default="3">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.durum_siparis" default="">
<cfparam name="attributes.member_cat_type" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.member_name" default="">
<cfparam name="attributes.member_type" default="">
<cfparam name="attributes.bayi_consumer_id" default="">
<cfparam name="attributes.bayi_company_id" default="">
<cfparam name="attributes.bayi_member_name" default="">
<cfparam name="attributes.bayi_member_type" default="">
<cfparam name="attributes.record_emp_id" default="">
<cfparam name="attributes.record_emp_name" default="">
<cfparam name="attributes.sales_emp_id" default="">
<cfparam name="attributes.sales_emp_name" default="">
<cfparam name="attributes.category_name" default="">
<cfparam name="attributes.list_type" default="1">
<cfparam name="attributes.currency_id" default="">
<cfparam name="attributes.sales_type" default="">
<cfparam name="attributes.project_type" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.deliver_start_date" default="">
<cfparam name="attributes.deliver_finish_date" default="">
<CFSET t_net_total1 = 0>
<CFSET t_net_total2 = 0>
<cfif isdefined('attributes.start_date') and isdate(attributes.start_date)>
	<cf_date tarih='attributes.start_date'>
</cfif>	
<cfif isdefined('attributes.finish_date') and isdate(attributes.finish_date)>
	<cf_date tarih='attributes.finish_date'>
</cfif>
<cfif isdefined('attributes.deliver_start_date') and isdate(attributes.deliver_start_date)>
	<cf_date tarih='attributes.deliver_start_date'>
</cfif>	
<cfif isdefined('attributes.deliver_finish_date') and isdate(attributes.deliver_finish_date)>
	<cf_date tarih='attributes.deliver_finish_date'>
</cfif>
<cfparam name="attributes.page" default=1>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfscript>
	get_virtual_offers.recordcount=0;
	get_virtual_offers.query_count=0;
	if (isdefined("attributes.is_form_submitted"))
	{
		get_virtual_offer_list_action = createObject("component", "addOns.ezgi.cfc.get_virtual_offers");
		get_virtual_offer_list_action.dsn3 = dsn3;
		get_virtual_offers = get_virtual_offer_list_action.get_virtual_offers_
		(
		 	dsn_alias : '#dsn_alias#',
		 	keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
			offer_stage : '#IIf(IsDefined("attributes.offer_stage"),"attributes.offer_stage",DE(""))#',
			sort_type : '#IIf(IsDefined("attributes.sort_type"),"attributes.sort_type",DE(""))#',
			branch_id : '#IIf(IsDefined("attributes.branch_id"),"attributes.branch_id",DE(""))#',
			durum_siparis : '#IIf(IsDefined("attributes.durum_siparis"),"attributes.durum_siparis",DE(""))#',
			member_cat_type : '#IIf(IsDefined("attributes.member_cat_type"),"attributes.member_cat_type",DE(""))#',
			consumer_id : '#IIf(IsDefined("attributes.consumer_id"),"attributes.consumer_id",DE(""))#',
			company_id : '#IIf(IsDefined("attributes.company_id"),"attributes.company_id",DE(""))#',
			member_name : '#IIf(IsDefined("attributes.member_name"),"attributes.member_name",DE(""))#',
			member_type : '#IIf(IsDefined("attributes.member_type"),"attributes.member_type",DE(""))#',
			bayi_consumer_id : '#IIf(IsDefined("attributes.bayi_consumer_id"),"attributes.bayi_consumer_id",DE(""))#',
			bayi_company_id : '#IIf(IsDefined("attributes.bayi_company_id"),"attributes.bayi_company_id",DE(""))#',
			bayi_member_name : '#IIf(IsDefined("attributes.bayi_member_name"),"attributes.bayi_member_name",DE(""))#',
			bayi_member_type : '#IIf(IsDefined("attributes.bayi_member_type"),"attributes.bayi_member_type",DE(""))#',
			record_emp_id : '#IIf(IsDefined("attributes.record_emp_id"),"attributes.record_emp_id",DE(""))#',
			record_emp_name : '#IIf(IsDefined("attributes.record_emp_name"),"attributes.record_emp_name",DE(""))#',
			sales_emp_id : '#IIf(IsDefined("attributes.sales_emp_id"),"attributes.sales_emp_id",DE(""))#',
			sales_emp_name : '#IIf(IsDefined("attributes.sales_emp_name"),"attributes.sales_emp_name",DE(""))#',
			category_name : '#IIf(IsDefined("attributes.category_name"),"attributes.category_name",DE(""))#',
			list_type : '#IIf(IsDefined("attributes.list_type"),"attributes.list_type",DE(""))#',
			currency_type : '#IIf(IsDefined("attributes.currency_type"),"attributes.currency_type",DE(""))#',
			currency_id : '#IIf(IsDefined("attributes.currency_id"),"attributes.currency_id",DE(""))#',
			sales_type : '#IIf(IsDefined("attributes.sales_type"),"attributes.sales_type",DE(""))#',
			project_type : '#IIf(IsDefined("attributes.project_type"),"attributes.project_type",DE(""))#',
			start_date : '#IIf(IsDefined("attributes.start_date"),"attributes.start_date",DE(""))#',
			finish_date : '#IIf(IsDefined("attributes.finish_date"),"attributes.finish_date",DE(""))#',
			deliver_start_date : '#IIf(IsDefined("attributes.deliver_start_date"),"attributes.deliver_start_date",DE(""))#',
			deliver_finish_date : '#IIf(IsDefined("attributes.deliver_finish_date"),"attributes.deliver_finish_date",DE(""))#',
		 	startrow : '#iif(isdefined("attributes.startrow"),"attributes.startrow",DE(""))#',
			maxrows : '#iif(isdefined("attributes.maxrows"),"attributes.maxrows",DE(""))#'
		);
		arama_yapilmali=0;
		}
	else
	{
		arama_yapilmali=1;
	}
</cfscript>
<cfparam name="attributes.totalrecords" default='#get_virtual_offers.query_count#'>
<cfquery name="GET_COMPANY_CAT" datasource="#DSN#">
	SELECT COMPANYCAT_ID,COMPANYCAT FROM COMPANY_CAT ORDER BY COMPANYCAT
</cfquery>
<cfquery name="GET_CONSUMER_CAT" datasource="#DSN#">
	SELECT CONSCAT_ID,CONSCAT FROM CONSUMER_CAT ORDER BY HIERARCHY
</cfquery>
<cfquery name="get_branch" datasource="#dsn#">
	SELECT        
    	BRANCH_ID, BRANCH_NAME
	FROM            
    	BRANCH
	WHERE        
    	BRANCH_ID IN
                  	(
                    	SELECT        
                        	BRANCH_ID
                    	FROM            
                        	EMPLOYEE_POSITION_BRANCHES
                    	WHERE        
                        	POSITION_CODE = #session.ep.POSITION_CODE# AND 
                            DEPARTMENT_ID IS NULL
                   	)
      	AND COMPANY_ID = #session.ep.company_id# 
        AND BRANCH_STATUS = 1
</cfquery>
<cfoutput query="get_branch">
	<cfset 'BRANCH_NAME_#BRANCH_ID#' = BRANCH_NAME>
</cfoutput>
<cfquery name="GET_PROCESS_TYPE" datasource="#DSN#">
	SELECT
		PTR.STAGE,
		PTR.PROCESS_ROW_ID
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%virtual_offer%">
	ORDER BY
		PTR.LINE_NUMBER
</cfquery>
<cfoutput query="GET_PROCESS_TYPE">
	<cfset 'STAGE_#PROCESS_ROW_ID#' = STAGE>
</cfoutput>
<cfparam name="attributes.totalrecords" default='#get_virtual_offers.query_count#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search" method="post" action="#request.self#?fuseaction=prod.list_ezgi_virtual_offer">
			<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <cf_box_search>
                <div class="form-group" id="form_ul_keyword">
                	<cfinput type="text" style="width:150px;" placeholder="#getLang(48,'Filtre',57460)#" maxlength="50" name="keyword" value="#attributes.keyword#">
              	</div>
                <div id="currency_id_" class="form-group medium"  style="display:<cfif attributes.list_type eq 1>none</cfif>">
                	<select name="currency_id" id="currency_id" style="width:100px; height:20px">
                   		<option value="" <cfif attributes.currency_id eq ''>selected</cfif>><cf_get_lang_main no='296.Tümü'></option>
                      	<option value="1" <cfif attributes.currency_id eq 1>selected</cfif>><cf_get_lang dictionary_id='58717.Açık'></option>
                    	<option value="2" <cfif attributes.currency_id eq 2>selected</cfif>><cf_get_lang dictionary_id='30975.Onaylandı'></option>
                     	<option value="3" <cfif attributes.currency_id eq 3>selected</cfif>><cf_get_lang dictionary_id='40941.İşlendi'></option>
                    	<option value="4" <cfif attributes.currency_id eq 4>selected</cfif>><cf_get_lang dictionary_id='41522.Son Onay'></option>
                  	</select>
                    <cf_get_lang dictionary_id='30056.Olmayanlar'>
                  	<input type="checkbox" name="currency_type" id="currency_type" <cfif isdefined('attributes.currency_type')>checked</cfif>>
                </div>
				<div class="form-group medium" id="form_ul_branch_id">
                	<select name="branch_id" id="branch_id" style="width:120px; height:20px">
                    	<option value=""><cf_get_lang_main no='296.Tümü'></option>
                  		<cfoutput query="get_branch">
                        	<option value="#get_branch.branch_id#" <cfif attributes.branch_id eq get_branch.branch_id>selected</cfif>>#get_branch.branch_name#</option>
                      	</cfoutput>
                	</select>
                </div>
                <div class="form-group medium" id="form_ul_list_type">
                	<select name="list_type" id="list_type" style="width:100px; height:20px">
                     	<option value="1" <cfif attributes.list_type eq 1>selected</cfif>><cf_get_lang dictionary_id='57660.Belge Bazında'></option>
                      	<option value="2" <cfif attributes.list_type eq 2>selected</cfif>><cf_get_lang dictionary_id='29539.Satır Bazında'></option>
                 	</select>
                </div>
                <div class="form-group medium" id="form_ul_sales_type">
                	<select name="sales_type" id="sales_type" style="width:100px; height:20px">
                   		<option value="" <cfif attributes.sales_type eq "">selected</cfif>><cf_get_lang_main no='296.Tümü'></option>
                     	<option value="1" <cfif attributes.sales_type eq 1>selected</cfif>>Bayi Teklif</option>
                     	<option value="2" <cfif attributes.sales_type eq 2>selected</cfif>>Şube Teklif</option>
                 	</select>
                </div>
                <div class="form-group medium" id="form_ul_project_type">
                	<select name="project_type" id="project_type" style="width:100px; height:20px">
                   		<option value="" <cfif attributes.project_type eq "">selected</cfif>><cf_get_lang_main no='296.Tümü'></option>
                     	<option value="1" <cfif attributes.project_type eq 1>selected</cfif>>Projeli İşler</option>
                     	<option value="2" <cfif attributes.project_type eq 2>selected</cfif>>Perakende İşler</option>
                 	</select>
                </div>
                <div class="form-group medium" id="form_ul_sort_type">
					<select name="sort_type" id="sort_type" style="width:175px; height:20px">
                     	<option value="2" <cfif attributes.sort_type eq 2>selected</cfif>><cf_get_lang dictionary_id='40928.Teklif Noya Göre Artan'></option>
                      	<option value="3" <cfif attributes.sort_type eq 3>selected</cfif>><cf_get_lang dictionary_id='40929.Teklif Noya Göre Azalan'></option>
                      	<option value="4" <cfif attributes.sort_type eq 4>selected</cfif>><cf_get_lang dictionary_id='40909.Teklif Tarihine Göre Artan'></option>
                    	<option value="5" <cfif attributes.sort_type eq 5>selected</cfif>><cf_get_lang dictionary_id='40911.Teklif Tarihine Göre Azalan'></option>
                 	</select>
                </div>
                <div class="form-group" id="form_ul_durum_siparis">
                 	<select name="durum_siparis" id="durum_siparis" style="width:120px; height:20px">
                      	<option value="" <cfif attributes.durum_siparis eq "">selected</cfif>><cf_get_lang_main no='296.Tümü'></option>
                    	<option value="1" <cfif attributes.durum_siparis eq 1>selected</cfif>><cf_get_lang dictionary_id='51074.Teklife Dönüşenler'></option>
                     	<option value="2" <cfif attributes.durum_siparis eq 2>selected</cfif>><cf_get_lang dictionary_id='38576.İşlem Görmeyenler'></option>
               		</select>
               	</div>
                <div class="form-group small">
                 	<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Kayıt Sayısı Hatalı!'></cfsavecontent>
                 	<cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,1250" required="yes" message="#message#">
            	</div>
               	<div class="form-group">
                	<cf_wrk_search_button search_function='input_control()' button_type="4">
             	</div>
          	</cf_box_search>
          	<cf_box_search_detail> 
             	<div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="form_ul_record_emp_id">
                     	<label class="col col-12"><cf_get_lang_main no='487.Kaydeden'></label>
                      	<div class="col col-12">
                         	<div class="input-group">
                            	<input type="hidden" name="record_emp_id" id="record_emp_id" value="<cfif isdefined("attributes.record_emp_id")><cfoutput>#attributes.record_emp_id#</cfoutput></cfif>">
								<input name="record_emp_name" type="text" id="record_emp_name" style="width:175px;" onfocus="AutoComplete_Create('record_emp_name','FULLNAME','FULLNAME','get_emp_pos','','EMPLOYEE_ID','record_emp_id','','3','130');" value="<cfif isdefined("attributes.record_emp_id") and len(attributes.record_emp_id)><cfoutput>#attributes.record_emp_name#</cfoutput></cfif>" maxlength="255" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=search.record_emp_id&field_name=search.record_emp_name<cfif fusebox.circuit is "store">&is_store_module=1</cfif>&select_list=1&is_form_submitted=1&keyword='+encodeURIComponent(document.search.record_emp_name.value),'list','popup_list_positions');"></span>
                            </div>
                      	</div>
              		</div>
                   <div class="form-group" id="form_ul_sales_emp_id">
                     	<label class="col col-12"><cf_get_lang dictionary_id='56987.Satış Yapan'></label>
                      	<div class="col col-12">
                         	<div class="input-group">
                            	<input type="hidden" name="sales_emp_id" id="sales_emp_id" value="<cfif isdefined("attributes.sales_emp_id")><cfoutput>#attributes.sales_emp_id#</cfoutput></cfif>">
								<input name="sales_emp_name" type="text" id="sales_emp_name" style="width:175px;" onfocus="AutoComplete_Create('sales_emp_name','FULLNAME','FULLNAME','get_emp_pos','','EMPLOYEE_ID','sales_emp_id','','3','130');" value="<cfif isdefined("attributes.sales_emp_id") and len(attributes.sales_emp_id)><cfoutput>#attributes.sales_emp_name#</cfoutput></cfif>" maxlength="255" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=search.sales_emp_id&field_name=search.sales_emp_name<cfif fusebox.circuit is "store">&is_store_module=1</cfif>&select_list=1&is_form_submitted=1&keyword='+encodeURIComponent(document.search.sales_emp_name.value),'list','popup_list_positions');"></span>
                            </div>
                      	</div>
              		</div>
               	</div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="2" sort="true">
                	<label class="col col-12"><cf_get_lang_main no='1447.Süreç'></label>
                 	<div class="col col-12">
                		<select name="offer_stage" id="offer_stage" style="height:100px; width:95%" multiple="multiple">
							<option value=""><cf_get_lang_main no='1447.Süreç'></option>
							<cfoutput query="get_process_type">
								<option value="#process_row_id#"<cfif Listfind(attributes.offer_stage, process_row_id)>selected</cfif>>#stage#</option>
							</cfoutput>
						</select>
                	</div>
                </div> 
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="3" sort="true">
                	<div class="form-group" id="form_ul_member_name">
                     	<label class="col col-12"><cf_get_lang_main no='107.Cari Hesap'></label>
                      	<div class="col col-12">
                         	<div class="input-group">
                            	<input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#attributes.consumer_id#</cfoutput>">
                   				<input type="hidden" name="company_id"  id="company_id" value="<cfoutput>#attributes.company_id#</cfoutput>">
                       			<input type="hidden" name="member_type" id="member_type" value="<cfoutput>#attributes.member_type#</cfoutput>">
                      			<input type="text"   name="member_name" id="member_name" style="width:175px;"  value="<cfoutput>#attributes.member_name#</cfoutput>" onFocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2\'','COMPANY_ID,CONSUMER_ID,MEMBER_TYPE','company_id,consumer_id,member_type','','3','250');" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&field_consumer=search.consumer_id&field_comp_id=search.company_id&field_member_name=search.member_name&field_type=search.member_type&select_list=7,8&keyword='+encodeURIComponent(document.search.member_name.value),'list');"></span>
                            </div>
                      	</div>
              		</div>
                    <div class="form-group" id="form_ul_durum_siparis">
                        <label class="col col-12"><cf_get_lang dictionary_id='35997.Bayi'></label>
                        <div class="col col-12">
                        	<div class="input-group">
                            	<input type="hidden" name="bayi_consumer_id" id="bayi_consumer_id" value="<cfoutput>#attributes.bayi_consumer_id#</cfoutput>">
                   				<input type="hidden" name="bayi_company_id"  id="bayi_company_id" value="<cfoutput>#attributes.bayi_company_id#</cfoutput>">
                       			<input type="hidden" name="bayi_member_type" id="bayi_member_type" value="<cfoutput>#attributes.bayi_member_type#</cfoutput>">
                      			<input type="text"   name="bayi_member_name" id="bayi_member_name" style="width:175px;"  value="<cfoutput>#attributes.bayi_member_name#</cfoutput>" onFocus="AutoComplete_Create('bayi_member_name','BAYI_MEMBER_NAME,BAYI_MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2\'','COMPANY_ID,CONSUMER_ID,MEMBER_TYPE','bayi_company_id,bayi_consumer_id,bayi_member_type','','3','250');" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&field_consumer=search.bayi_consumer_id&field_comp_id=search.bayi_company_id&field_member_name=search.bayi_member_name&field_type=search.bayi_member_type&select_list=7,8&keyword='+encodeURIComponent(document.search.member_name.value),'list');"></span>
                            </div>
                        </div>
                  	</div>
             	</div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="4" sort="true">
                	<div class="form-group" id="form_ul_start_date">
                        <label class="col col-12"><cf_get_lang dictionary_id='38420.Teklif Tarihi'></label>
                        <div class="col col-12">
                            <div class="col col-6 pl-0">
                                <div class="input-group">
                                    <cfinput type="text" name="start_date" value="#dateformat(attributes.start_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                                </div>
                            </div>
                            <div class="col col-6 pr-0">  
                                <div class="input-group">
                                    <cfinput type="text" name="finish_date" value="#dateformat(attributes.finish_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                                </div>
                            </div>
                        </div>    
                  	</div>
                    <div class="form-group" id="form_ul_finish_date">
                        <label class="col col-12"><cf_get_lang dictionary_id='57747.Sözleşme Tarihi'></label>
                        <div class="col col-12">
                            <div class="col col-6 pl-0">
                                <div class="input-group">
                                    <cfinput type="text" name="deliver_start_date" value="#dateformat(attributes.deliver_start_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="deliver_start_date"></span>
                                </div>
                            </div>
                            <div class="col col-6 pr-0">  
                                <div class="input-group">
                                    <cfinput type="text" name="deliver_finish_date" value="#dateformat(attributes.deliver_finish_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="deliver_finish_date"></span>
                                </div>
                            </div>
                        </div>    
                  	</div>
                </div>
                
          	 </cf_box_search_detail> 
        </cfform>
    </cf_box>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id="801.Sanal Teklif"></cfsavecontent>
    <cf_box title="#message#" uidrop="1" hide_table_column="1" woc_setting = "#{ checkbox_name : 'print_invoice_id', print_type : 10 }#">
    	<cf_grid_list sort="1">
        	<thead>
             	<tr>
                	<th><cf_get_lang dictionary_id='55657.Sıra No'></th>
                    <th><cf_get_lang dictionary_id='58212.Teklif No'></th>
                    <th><cf_get_lang dictionary_id='46831.Teklif Tarihi'></th>
                    <th><cf_get_lang dictionary_id='57747.Sözleşme Tarihi'></th>
                    <th><cf_get_lang dictionary_id='57457.Müşteri'></th>
                    <th><cf_get_lang dictionary_id='57899.Kaydeden'></th>
                    <th><cf_get_lang dictionary_id='41659.İlgili Bayi Şube'></th>
                    <cfif attributes.list_type eq 2>
                    	<th><cf_get_lang dictionary_id='57756.Durum'></th>
                        <th><cf_get_lang dictionary_id='58800.Ürün Kodu'></th>
                        <th><cf_get_lang dictionary_id='57635.Miktar'></th>
                        <th><cf_get_lang dictionary_id='57636.Birim'></th>
                    </cfif>
                    <th><cf_get_lang dictionary_id='58820.Başlık'></th>
                    <th style="width:100px"><cf_get_lang_main no='1447.Surec'></th>
                    <cfif attributes.list_type eq 1>
                        <th><cf_get_lang dictionary_id='57673.Tutar'><br />(<cf_get_lang dictionary_id='49998.KDV Dahil'>)</th>
                        <th><cf_get_lang dictionary_id='57677.Döviz'></th>
                        <th><cf_get_lang dictionary_id='57673.Tutar'> - <cfoutput>#session.ep.money#</cfoutput><br />(<cf_get_lang dictionary_id='48656.KDV Hariç'>)</th>
                        <th><cf_get_lang dictionary_id='57673.Tutar'> - <cfoutput>#session.ep.money#</cfoutput><br />(<cf_get_lang dictionary_id='49998.KDV Dahil'>)</th>
                    </cfif>    
                    <!-- sil -->
                    <th width="20" class="header_icn_none">
                  		<a href="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_virtual_offer&event=add</cfoutput>"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
            		</th>
                	<!-- sil -->
              	 </tr>
        	</thead>
        	<tbody>
            	<cfif get_virtual_offers.recordcount>
                	<cfoutput query="get_virtual_offers">
						<cfif len(RECORD_PAR)>
                            <cfquery name="get_par_name" datasource="#dsn#">
                                SELECT COMPANY_PARTNER_NAME, COMPANY_PARTNER_SURNAME FROM COMPANY_PARTNER WHERE PARTNER_ID = #RECORD_PAR#
                            </cfquery>
                        </cfif>
                        <cfquery name="get_money" datasource="#dsn3#">
                        	SELECT MONEY_TYPE, RATE2 FROM EZGI_VIRTUAL_OFFER_MONEY WHERE ACTION_ID = #VIRTUAL_OFFER_ID# AND IS_SELECTED = 1
                        </cfquery>
                       	<tr oncontextmenu="javascript:wrk_right_menu('VIRTUAL_OFFER_ID',#VIRTUAL_OFFER_ID#);return false;"> 
                        	<td>#rownum#</td>
                            <td style="text-align:left;"><a href="#request.self#?fuseaction=prod.list_ezgi_virtual_offer&event=upd&virtual_offer_id=#get_virtual_offers.virtual_offer_id#" class="tableyazi">#VIRTUAL_OFFER_NUMBER#<cfif len(REVISION_NO)> <span style="font-weight:bold; color:red">Rev:#REVISION_NO#</span></cfif></a></td>
                        	<td style="text-align:center;">#DateFormat(VIRTUAL_OFFER_DATE,dateformat_style)#</td>
                        	<td style="text-align:center;">#DateFormat(FINISHDATE,dateformat_style)#</td>
                        	<td style="text-align:LEFT;">
								<cfif  get_virtual_offers.MEMBER_TYPE eq 'partner'>
                                    #get_par_info(get_virtual_offers.COMPANY_ID,1,1,0)#
                                <cfelseif get_virtual_offers.MEMBER_TYPE eq 'consumer'>
                                    #get_cons_info(get_virtual_offers.CONSUMER_ID,0,0)#
                                </cfif>
                            </td>
                            <td nowrap="nowrap"><cfif len(RECORD_EMP)>#get_emp_info(RECORD_EMP,0,0)#<cfelseif len(RECORD_PAR)>#get_par_name.COMPANY_PARTNER_NAME# #get_par_name.COMPANY_PARTNER_SURNAME#</cfif></td>
                            <td nowrap="nowrap">
                                <cfif len(get_virtual_offers.SALES_COMPANY_ID)>
                                    #get_par_info(get_virtual_offers.SALES_COMPANY_ID,1,1,0)#
                                <cfelse>
                                    <cfif isdefined('BRANCH_NAME_#BRANCH_ID#')>
                                        #Evaluate('BRANCH_NAME_#BRANCH_ID#')#
                                    </cfif>
                                </cfif>
                            </td>
                            <cfif attributes.list_type eq 2>
                                <td>
                                    <cfif VIRTUAL_OFFER_ROW_CURRENCY eq 1><cf_get_lang dictionary_id='58717.Açık'></cfif>
                                    <cfif VIRTUAL_OFFER_ROW_CURRENCY eq 2><cf_get_lang dictionary_id='30975.Onaylandı'></cfif>	
                                    <cfif VIRTUAL_OFFER_ROW_CURRENCY eq 3><cf_get_lang dictionary_id='40941.İşlendi'></cfif>	
                                    <cfif VIRTUAL_OFFER_ROW_CURRENCY eq 4><cf_get_lang dictionary_id='41522.Son Onay'></cfif>	
                                </td>
                                <td nowrap="nowrap">#Left(PRODUCT_NAME,80)#<cfif len(PRODUCT_NAME) gt 80>...</cfif></td>
                                <td style="text-align:right;">#AmountFormat(QUANTITY)#</td>
                                <td>#UNIT#</td>
                            </cfif>
                            <td title="<cfif attributes.list_type eq 2>#product_name2#<cfelse>#VIRTUAL_OFFER_HEAD#</cfif>">
                                <cfif attributes.list_type eq 2>
                                    #Left(product_name2,40)#<cfif len(PRODUCT_NAME2) gt 40>...</cfif>
                                <cfelse>
                                    #Left(VIRTUAL_OFFER_HEAD,40)#<cfif len(VIRTUAL_OFFER_HEAD) gt 40>...</cfif>
                                </cfif>
                            </td>
                            <td nowrap="nowrap"><cfif isdefined('STAGE_#VIRTUAL_OFFER_STAGE#')>#Evaluate('STAGE_#VIRTUAL_OFFER_STAGE#')#</cfif></td>
                            <cfif attributes.list_type eq 1>
                            	<td style="text-align:right;" nowrap><cfif NETTOTAL gt 0><cfif get_money.RATE2 neq 1 and get_money.RATE2 neq ''>#AmountFormat(NETTOTAL/get_money.RATE2,2)#<cfelse>#AmountFormat(NETTOTAL,2)#</cfif> </cfif></td>
                                <td>#get_money.MONEY_TYPE#</td>
                                <td style="text-align:right;">#AmountFormat(NETTOTAL-TAXTOTAL)#</td>
                                <td style="text-align:right;">#AmountFormat(NETTOTAL,2)#</td>
                                <CFSET t_net_total1 = t_net_total1 + NETTOTAL-TAXTOTAL>
                                <CFSET t_net_total2 = t_net_total2 + NETTOTAL>
                            </cfif>
                            <!-- sil -->
                                <td>
                                    <a href="#request.self#?fuseaction=prod.list_ezgi_virtual_offer&event=upd&virtual_offer_id=#get_virtual_offers.virtual_offer_id#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                                </td>
                         	<!-- sil -->
                      	</tr>
                	</cfoutput>
                	<cfif attributes.list_type eq 1>
                        <tr>
                            <td colspan="11" style="height:20px"><strong><cf_get_lang dictionary_id='55447.Sayfa Toplam'></strong></td>
                            <td style="text-align:right;"><strong><cfoutput>#AmountFormat(t_net_total1,2)#</cfoutput></strong></td>
                            <td style="text-align:right;"><strong><cfoutput>#AmountFormat(t_net_total2,2)#</cfoutput></strong></td>
                            <TD ></TD>
                        </tr>
                    </cfif>
                <cfelse>
                    <tr> 
                        <td colspan="15" height="20"><cfif arama_yapilmali eq 1><cf_get_lang_main no='289.Filtre Ediniz'> !<cfelse><cf_get_lang_main no='72.Kayıt Yok'>!</cfif></td>
                    </tr>
                </cfif>
            </tbody>
      	</cf_grid_list>
        <cfset adres = url.fuseaction>
		<cfif isdefined("attributes.is_form_submitted") and attributes.totalrecords gt attributes.maxrows>
            <cfif len(attributes.member_name)>
              <cfset adres = '#adres#&company_id=#attributes.company_id#'>
              <cfset adres = '#adres#&consumer_id=#attributes.consumer_id#'>
              <cfset adres = '#adres#&member_name=#attributes.member_name#'>
              <cfset adres = '#adres#&member_type=#attributes.member_type#'>
            </cfif>
            <cfif len(attributes.bayi_member_name)>
              <cfset adres = '#adres#&bayi_company_id=#attributes.bayi_company_id#'>
              <cfset adres = '#adres#&bayi_consumer_id=#attributes.bayi_consumer_id#'>
              <cfset adres = '#adres#&bayi_member_name=#attributes.bayi_member_name#'>
              <cfset adres = '#adres#&bayi_member_type=#attributes.bayi_member_type#'>
            </cfif>		
            <cfif len(attributes.keyword)>
              <cfset adres = '#adres#&keyword=#URLEncodedFormat(attributes.keyword)#'>
            </cfif>
            <cfif len(attributes.sales_type)>
                <cfset adres = '#adres#&sales_type=#attributes.sales_type#'>
            </cfif>
            <cfif len(attributes.project_type)>
                <cfset adres = '#adres#&project_type=#attributes.project_type#'>
            </cfif>
            <cfif len(attributes.sort_type)>
                <cfset adres = '#adres#&sort_type=#attributes.sort_type#'>
            </cfif>
            <cfif len(attributes.list_type)>
                <cfset adres = '#adres#&list_type=#attributes.list_type#'>
            </cfif>
            <cfif len(attributes.durum_siparis)>
                <cfset adres = '#adres#&durum_siparis=#attributes.durum_siparis#'>
            </cfif>
            <cfif len(attributes.offer_stage)>
                <cfset adres = '#adres#&offer_stage=#attributes.offer_stage#'>
            </cfif>
            <cfif len(attributes.record_emp_name)>
                <cfset adres = '#adres#&record_emp_name=#attributes.record_emp_name#'>
                <cfset adres = '#adres#&record_emp_id=#attributes.record_emp_id#'>
            </cfif>
            <cfif len(attributes.sales_emp_name)>
                <cfset adres = '#adres#&sales_emp_name=#attributes.sales_emp_name#'>
                <cfset adres = '#adres#&record_emp_id=#attributes.record_emp_id#'>
            </cfif>
            <cfif len(attributes.currency_id)>
                <cfset adres = '#adres#&currency_id=#attributes.currency_id#'>
            </cfif>
            <cfif isdefined('attributes.currency_type')>
                <cfset adres = '#adres#&currency_type=#attributes.currency_type#'>
            </cfif>
            <cfif isdate(attributes.start_date)>
                <cfset adres = adres & "&start_date=#dateformat(attributes.start_date,dateformat_style)#">
            </cfif>
            <cfif isdate(attributes.finish_date)>
                <cfset adres = adres & "&finish_date=#dateformat(attributes.finish_date,dateformat_style)#">
            </cfif>
            
            <cfif isdate(attributes.deliver_start_date)>
                <cfset adres = adres & "&deliver_start_date=#dateformat(attributes.deliver_start_date,dateformat_style)#">
            </cfif>
            <cfif isdate(attributes.deliver_finish_date)>
                <cfset adres = adres & "&deliver_finish_date=#dateformat(attributes.deliver_finish_date,dateformat_style)#">
            </cfif>
            <cf_paging 
                page="#attributes.page#"
                maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                startrow="#attributes.startrow#"
                adres="#adres#&is_form_submitted=1">
        </cfif>
  	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;
	}
</script>