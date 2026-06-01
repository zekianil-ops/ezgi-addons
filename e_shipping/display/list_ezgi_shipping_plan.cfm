<cfsetting showdebugoutput="yes"> 
<cf_get_lang_set module_name="report">
<cf_xml_page_edit fuseact="report.sale_analyse_report_orders">
<cfparam name="attributes.project_id" default="1"><!---Firmaya Göre Değişir--->
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.report_sort"  default="1">
<cfparam name="attributes.product_employee_id" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.employee_name" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.keyword_" default="">
<cfparam name="attributes.employee" default="">
<cfparam name="attributes.employee_id" default="">
<cfparam name="attributes.row_employee" default="">
<cfparam name="attributes.row_employee_id" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.is_kdv" default="1">
<cfparam name="attributes.sup_company" default="">
<cfparam name="attributes.sup_company_id" default="">
<cfparam name="attributes.company" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.commethod_id" default="">
<cfparam name="attributes.pos_code" default="">
<cfparam name="attributes.pos_code_text" default="">
<cfparam name="attributes.brand_name" default="">
<cfparam name="attributes.brand_id" default="">
<cfparam name="attributes.model_name" default="">
<cfparam name="attributes.model_id" default="">
<cfparam name="attributes.department_id" default="">
<cfparam name="attributes.status" default="1">
<cfparam name="attributes.product_cat" default="">
<cfparam name="attributes.search_product_catid" default="" >
<cfparam name="attributes.date1" default="">
<cfparam name="attributes.date2" default="">
<cfparam name="attributes.termin_date1" default="">
<cfparam name="attributes.termin_date2" default="">
<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.project_head" default="">
<cfparam name="attributes.report_type" default="17">
<cfparam name="attributes.is_prom" default="0" >
<cfparam name="attributes.is_other_money" default="0">
<cfparam name="attributes.is_money_info" default="0">
<cfparam name="attributes.is_money2" default="0" >
<cfparam name="attributes.resource_id" default="" >
<cfparam name="attributes.ims_code_id" default="">
<cfparam name="attributes.customer_value_id" default="">
<cfparam name="attributes.zone_id" default="">
<cfparam name="attributes.is_discount" default="0">
<cfparam name="attributes.is_project" default="">
<cfparam name="attributes.segment_id" default="">
<cfparam name="attributes.member_cat_type" default="">
<cfparam name="attributes.kontrol" default="0">
<cfparam name="attributes.cancel_type_id" default="">
<cfparam name="attributes.order_stage" default="">
<cfparam name="attributes.graph_type" default="1">
<cfparam name="attributes.is_excel" default="">
<cfparam name="attributes.is_iptal" default="">
<cfparam name="attributes.order_process_cat" default="">
<cfparam name="attributes.sector_cat_id" default="">
<cfparam name="attributes.sales_member_id" default="">
<cfparam name="attributes.sales_member_type" default="">
<cfparam name="attributes.sales_member" default="">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.city_id" default="">
<cfparam name="attributes.county_id" default="">
<cfparam name="attributes.country_id" default="">
<cfparam name="attributes.sale_add_option" default="">
<cfparam name="attributes.sort_type" default="4">
<cfparam name="attributes.currency_type" default="">
<cfparam name="attributes.get_project_type" default="1">
<cfset t_takim_puan = 0>
<cfset toplam_kalan_tutar=0>
<cfset toplam_satis =0>
<cfset t_amount = 0>
<cfset toplam_brut_satis = 0>
<cfset t_isk=0>
<cfset t_kalan_amount=0>
<cfset t_teslim_amount=0>
<cfset s_takim_puan = 0>
<cfset s_toplam_kalan_tutar=0>
<cfset s_toplam_satis =0>
<cfset s_t_amount = 0>
<cfset s_toplam_brut_satis = 0>
<cfset s_t_isk=0>
<cfset s_t_kalan_amount=0>
<cfset s_t_teslim_amount=0>
<cfset son_row = 0>
<cfif attributes.is_other_money eq 1 and attributes.is_money2 eq 1>
	<cfset attributes.is_money2 = 0>
</cfif>
<cfquery name="get_process_type" datasource="#dsn#">
	 SELECT
		 PTR.STAGE,
		 PTR.PROCESS_ROW_ID 
	 FROM
		 PROCESS_TYPE_ROWS PTR WITH (NOLOCK),
		 PROCESS_TYPE_OUR_COMPANY PTO WITH (NOLOCK),
		 PROCESS_TYPE PT WITH (NOLOCK)
	 WHERE
		 PT.IS_ACTIVE = 1 AND		
		 PT.PROCESS_ID = PTR.PROCESS_ID AND
		 PT.PROCESS_ID = PTO.PROCESS_ID AND
		 PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		 (PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%sales.list_order%"> OR PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%sales.upd_fast_sale%">)
	 ORDER BY
		 PTR.LINE_NUMBER
 </cfquery>

<cfoutput query="get_process_type">
	<cfset 'STAGE_#PROCESS_ROW_ID#' = STAGE>
</cfoutput>

<cfquery name="get_project" datasource="#dsn#">
	SELECT PROJECT_ID,PROJECT_HEAD FROM PRO_PROJECTS
</cfquery>
<cfoutput query="get_project">
	<cfset 'PROJECT_HEAD_#PROJECT_ID#' = PROJECT_HEAD>
</cfoutput>
<cfquery name="GET_DEPARTMENT" datasource="#DSN#">
	SELECT
		DEPARTMENT_ID,
		DEPARTMENT_HEAD
	FROM
		BRANCH B WITH (NOLOCK),
		DEPARTMENT D WITH (NOLOCK)
	WHERE
		B.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		B.BRANCH_ID = D.BRANCH_ID AND
		D.IS_STORE <> 2
		AND D.DEPARTMENT_STATUS = 1 
		<cfif isdefined("x_bring_to_response") and x_bring_to_response eq 1>
			AND B.BRANCH_ID IN
				(SELECT 
					BRANCH_ID 
				 FROM  
					EMPLOYEE_POSITION_BRANCHES WITH (NOLOCK)
				 WHERE 
					POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">)
		</cfif>
	ORDER BY
		DEPARTMENT_HEAD
</cfquery>
<cfquery name="get_money" datasource="#dsn#"><!--- Onceki Donemlerin Para Birimleri De Gerektiginden Dsnden Cekiliyor FBS --->
	SELECT MONEY FROM SETUP_MONEY WITH (NOLOCK) GROUP BY MONEY
</cfquery>
<cfoutput query="get_money">
	<cfset 'total_grosstotal_doviz_#money#' = 0>
</cfoutput>
<cfset branch_dep_list=valuelist(get_department.department_id,',')>
<cfif isdefined("attributes.form_submitted")>
	<!--- Query blogu --->
    <cfset arama_yapilmali = 0>
	<cfinclude template="/v16/add_options/report/query/get_sale_analyse_orders.cfm">
    <cfif get_total_purchase.recordcount>
    	<cfset ezgiorder_id_list = Valuelist(get_total_purchase.ORDER_ID)>
        <cfquery name="get_project" datasource="#dsn3#">
            SELECT     
                ORDER_ID,
                PROJECT_ID
            FROM         
                ORDERS WITH (NOLOCK)
            WHERE 
                <cfif len(attributes.project_head) and len(attributes.project_id)>
                	<cfif attributes.project_id eq -1>
                    	(ISNULL(PROJECT_ID,0) = 0 OR LEN(PROJECT_ID) = 0  AND
                    <cfelse>
						PROJECT_ID = #attributes.project_id# AND
                    </cfif>
                </cfif>
                ORDER_ID IN (#ezgiorder_id_list#)
        </cfquery>
        <cfoutput query="get_project">
        	<cfif len(get_project.PROJECT_ID)>
            	<cfset 'PROJECT_ID_#ORDER_ID#' = PROJECT_ID>
            </cfif>
        </cfoutput>
        <cfif get_project.recordcount>
        	<cfset ezgi_project_id_list = ValueList(get_project.ORDER_ID)>
       	<cfelse>
        	<cfset ezgi_project_id_list = ''>
        </cfif>
        <cfquery name="get_adreslist" datasource="#dsn3#">
            SELECT 
            	ORDER_ID,
                (SELECT COUNTY_NAME FROM #dsn#.SETUP_COUNTY WITH (NOLOCK) WHERE COUNTY_ID = ORDERS.COUNTY_ID) as COUNTY_NAME, 
                (SELECT CITY_NAME FROM #dsn#.SETUP_CITY WITH (NOLOCK) WHERE CITY_ID = ORDERS.CITY_ID) as CITY_NAME
           	FROM 
            	ORDERS WITH (NOLOCK)
          	WHERE 
            	ORDER_ID IN (#ezgiorder_id_list#)
        </cfquery>
        <cfoutput query="get_adreslist">
        	<cfset 'COUNTY_NAME_#ORDER_ID#' = COUNTY_NAME>
            <cfset 'CITY_NAME_#ORDER_ID#' = CITY_NAME>
        </cfoutput>
        <cfset order_product_id_list = ValueList(get_total_purchase.product_id)>
        <cfquery name="get_total_purchase_e" dbtype="query">
            SELECT 
                *
            FROM
                get_total_purchase
           	WHERE
            	1=1
                <cfif len(ezgi_project_id_list)>
                	AND ORDER_ID IN (#ezgi_project_id_list#)	
                </cfif>
                <cfif len(attributes.keyword_)>
                	AND <cfif isdefined('is_reverse') and  len(is_reverse)>NOT</cfif>
                    	(
                        	ORDER_NUMBER LIKE '%#attributes.keyword_#%' OR
                            ORDER_DETAIL LIKE '%#attributes.keyword_#%' OR
                            MUSTERI LIKE '%#attributes.keyword_#%' OR
                        	REF_NO LIKE '%#attributes.keyword_#%'
                        )
                </cfif>
                <cfif attributes.graph_type eq 1> 
					AND QUANTITY-deliver_amount > 0
               	<cfelseif attributes.graph_type eq 2> 
                	AND QUANTITY-deliver_amount = 0     
               	</cfif> 
                <cfif len(attributes.currency_type)>
                	AND ORDER_ROW_CURRENCY = #attributes.currency_type# 
               	<cfelse>
                	AND ORDER_ROW_CURRENCY <> -9 
                	AND ORDER_ROW_CURRENCY <> -10
                </cfif>
        </cfquery>
        <cfif get_total_purchase_e.recordcount>
            <cfoutput query="get_total_purchase_e">
            	<cfif isnumeric(DISCOUNT)>
                	<cfset DISCOUNT_ = DISCOUNT>
                <cfelse>
                	<cfset DISCOUNT_ = 0>
                </cfif>
            	<cfif isdefined('PROPERTY1_#PRODUCT_ID#') and isnumeric(Evaluate('PROPERTY1_#PRODUCT_ID#'))>
                	<cfset s_takim_puan = s_takim_puan + PRODUCT_STOCK * Evaluate('PROPERTY1_#PRODUCT_ID#')>
                </cfif>
           		<cfset s_t_amount=s_t_amount+PRODUCT_STOCK>
              	<cfset s_t_teslim_amount=s_t_teslim_amount+deliver_amount>
               	<cfset remain_amount = product_stock-deliver_amount>
           		<cfif x_show_remains_as_zero eq 1 and remain_amount lt 0>
                  	<cfset remain_amount = 0>
                </cfif> 
                <cfset s_t_kalan_amount=s_t_kalan_amount+remain_amount>
              	<cfif attributes.is_other_money eq 1>
                  	<cfset net_fiyat_=OTHER_MONEY_VALUE/QUANTITY>
               	<cfelseif len(ROW_LASTTOTAL)>
                 	<cfset net_fiyat_=ROW_LASTTOTAL/QUANTITY>
              	<cfelse>
                 	<cfset net_fiyat_=0>
               	</cfif>
               		<cfset s_toplam_brut_satis = s_toplam_brut_satis + GROSSTOTAL>
               	<cfif DISCOUNT_ gt 0>
					<cfset isk_= DISCOUNT_/birim_fiyat/PRODUCT_STOCK*100>
               	<cfelse>
                   	<cfset isk_=0>
                </cfif>
                <cfif DISCOUNT_ gt 0>
                	<cfset s_t_isk = s_t_isk + DISCOUNT_>
                </cfif>
                <cfif ROW_LASTTOTAL gt 0>
                	<cfset s_toplam_satis =s_toplam_satis+ROW_LASTTOTAL>
                </cfif>
                <cfset remain = product_stock-deliver_amount>
                <cfset s_toplam_kalan_tutar=s_toplam_kalan_tutar+(remain*ROW_LASTTOTAL/QUANTITY)>
           	</cfoutput>
        </cfif>
        <cfquery name="get_total_purchase_e" dbtype="query">
        	 SELECT 
                ORDER_ID,
                MEMBER_TYPE,
                COMPANY_ID,
                ORDER_DETAIL,
                ORDER_STAGE,
                ORDER_NUMBER,
                ORDER_DATE,
                REF_NO,
                MUSTERI
            FROM
                get_total_purchase_e
            GROUP BY
            	ORDER_ID,
                MEMBER_TYPE,
                COMPANY_ID,
                ORDER_DETAIL,
                ORDER_STAGE,
                ORDER_NUMBER,
                ORDER_DATE,
                REF_NO,
                MUSTERI
        	ORDER BY
                <cfif attributes.sort_type eq 1>
                    MUSTERI,ORDER_DATE
                <cfelseif attributes.sort_type eq 3>
                    DELIVERDATE_,MUSTERI
              	<cfelse>
                    ORDER_DATE desc     
                </cfif>
        </cfquery>
  	<cfelse>
    	<cfset get_total_purchase_e.recordcount = 0>
    </cfif>
    <cfset arama_yapilmali = 1>
<cfelse>
	<cfset get_total_purchase_e.recordcount = 0>
    <cfset arama_yapilmali = 1>
</cfif>

<cfparam name="attributes.page" default=1>
<cfparam name="attributes.totalrecords" default="#get_total_purchase_e.recordcount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfif isdefined('attributes.is_excel') and  attributes.is_excel eq 1>
	<cfset attributes.startrow=1>
	<cfset attributes.maxrows=get_total_purchase.recordcount>
</cfif>
<cfquery name="SZ" datasource="#DSN#">
	SELECT * FROM SALES_ZONES WHERE IS_ACTIVE=1 ORDER BY SZ_NAME
</cfquery>
<cfquery name="GET_COMPANY_CAT" datasource="#DSN#">
	SELECT DISTINCT	
		COMPANYCAT_ID,
		COMPANYCAT
	FROM
		GET_MY_COMPANYCAT WITH (NOLOCK)
	WHERE
		EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"> AND
		OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
	ORDER BY
		COMPANYCAT
</cfquery>
<cfquery name="GET_CONSUMER_CAT" datasource="#DSN#">
	SELECT DISTINCT	
		CONSCAT_ID,
		CONSCAT,
		HIERARCHY
	FROM
		GET_MY_CONSUMERCAT WITH (NOLOCK)
	WHERE
		EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"> AND
		OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
	ORDER BY
		HIERARCHY		
</cfquery>
<cfquery name="get_branch_" datasource="#dsn#">
	SELECT 
		BRANCH_NAME,BRANCH_ID
	FROM
		BRANCH WITH (NOLOCK)
	WHERE
		COMPANY_ID = #session.ep.company_id#
		AND BRANCH_STATUS = 1
        and BRANCH_ID IN
				(SELECT 
					BRANCH_ID 
				 FROM  
					EMPLOYEE_POSITION_BRANCHES WITH (NOLOCK)
				 WHERE 
					POSITION_CODE = #session.ep.position_code#
                    )
</cfquery>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
        <cfform name="order_form" method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
            <input type="hidden" name="form_submitted" id="form_submitted" value="">
        	 <cf_box_search>
                <div class="form-group">
                	 <cfinput type="text" style="width:150px;" placeholder="#getLang(48,'Filtre',57460)#" maxlength="50" name="keyword_" value="#attributes.keyword_#">
                     <input type="checkbox" name="is_reverse" value="1" title="Olmayanlar" <cfif isdefined('attributes.is_reverse')>checked</cfif>>
               	</div>
        		<div class="form-group">
                	<select name="graph_type" >
						<option value="" selected>Tümü</option>
						<option value="1" <cfif attributes.graph_type eq 1> selected</cfif>>Bekleyen Siparişler</option>
						<option value="2" <cfif attributes.graph_type eq 2> selected</cfif>>Teslim Edilmişler</option>
					</select>
                </div>
                <div class="form-group">
                	<select name="sort_type" id="sort_type">
						<option value="1" <cfif attributes.sort_type eq 1>selected</cfif>>Üye Adına Göre</option>
                        <option value="3" <cfif attributes.sort_type eq 3>selected</cfif>>Termin Tarihine Göre</option>
                        <option value="4" <cfif attributes.sort_type eq 4>selected</cfif>>Sipariş Tarihine Göre</option>
                  	</select>
                </div>
                <div class="form-group">
					<select name="branch_id" id="branch_id">
                    	<option value="">Tüm Şubeler</option>
						<cfoutput query="get_branch_">
							<option value="#branch_id#"<cfif attributes.branch_id eq branch_id>selected</cfif>>#branch_name#</option>
						</cfoutput>
					</select>
                </div>
                <div class="form-group">
					<select name="zone_id" id="zone_id">
                      	<option value=""><cf_get_lang_main no='247.Satis Bölgesi'></option>
                     	<cfoutput query="sz">
                        	<option value="#sz_id#" <cfif attributes.zone_id eq sz_id>selected</cfif>>#sz_name#</option>
                     	</cfoutput>
                  	</select>
                </div>

                <div class="form-group">
					<select name="currency_type" id="currency_type" style="width:120px; height:20px">
                    	<option value="" <cfif attributes.currency_type eq -1>selected</cfif>>Aşama</option>
						<option value="-1" <cfif attributes.currency_type eq -1>selected</cfif>><cf_get_lang_main no='1305.Açık'></option>
                        <option value="-2" <cfif attributes.currency_type eq -2>selected</cfif>><cf_get_lang_main no ='1948.Tedarik'></option>
                        <option value="-3" <cfif attributes.currency_type eq -3>selected</cfif>><cf_get_lang_main no ='1949.Kapatildi'></option>
                        <option value="-4" <cfif attributes.currency_type eq -4>selected</cfif>><cf_get_lang_main no ='1950.Kismi Üretim'></option>
                        <option value="-5" <cfif attributes.currency_type eq -5>selected</cfif>><cf_get_lang_main no ='44.Üretim'></option>
                        <option value="-6" <cfif attributes.currency_type eq -6>selected</cfif>><cf_get_lang_main no='1349.Sevk'></option>
                        <option value="-7" <cfif attributes.currency_type eq -7>selected</cfif>><cf_get_lang_main no ='1951.Eksik Teslimat'></option>
                        <option value="-8" <cfif attributes.currency_type eq -8>selected</cfif>><cf_get_lang_main no ='1952.Fazla Teslimat'></option>
                        <option value="-9" <cfif attributes.currency_type eq -9>selected</cfif>><cf_get_lang_main no ='1094.İptal'></option>
                        <option value="-10" <cfif attributes.currency_type eq -10>selected</cfif>>Kapatıldı(Manuel)</option>
                  	</select>
                </div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,2000" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="4" style="width:35px;">
                </div>
        		<div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
          	</cf_box_search>
            <cf_box_search_detail>
                <div id="detail_search_div" class="col col-12" style="display:table-row;">
                	<div class="col col-3">
                    	<div class="col col-12">
                    		<div class="col col-3">
                            	<label><cf_get_lang_main no='74.Kategori'></label>
                        	</div>
                            <div class="col col-9">
                                <div class="form-group medium">
                                    <div class="input-group">
                                    	<cf_wrk_product_cat form_name='order_form' hierarchy_code='search_product_catid' product_cat_name='product_cat'>
										<input type="hidden" name="search_product_catid" id="search_product_catid" value="<cfif len(attributes.product_cat)><cfoutput>#attributes.search_product_catid#</cfoutput></cfif>">
										<input type="text" name="product_cat" id="product_cat" value="<cfif len(attributes.product_cat)><cfoutput>#attributes.product_cat#</cfoutput></cfif>" onkeyup="get_product_cat();">
                                        <span class="input-group-addon icon-ellipsis btnPoniter" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_cat_names&is_sub_category=1&field_code=order_form.search_product_catid&field_name=order_form.product_cat&field_min=add_design.MIN_MARGIN&field_max=add_design.MAX_MARGIN');" title="<cf_get_lang dictionary_id='37157.Ürün Kategorisi Ekle'>!"></span>
                                    </div>
                                </div>
                            </div>
                       	</div>
                        <div class="col col-12">
                    		<div class="col col-3">
                            	<label><cf_get_lang_main no='245.Ürün'></label>
                        	</div>
                            <div class="col col-9">
                                <div class="form-group medium">
                                    <div class="input-group">
                                    	<cf_wrk_products form_name = 'order_form' product_name='product_name' product_id='product_id'>
										<input type="hidden" name="product_id" id="product_id" value="<cfif len(attributes.product_name)><cfoutput>#attributes.product_id#</cfoutput></cfif>">
										<input type="text" name="product_name" id="product_name" value="<cfoutput>#attributes.product_name#</cfoutput>" passthrough="readonly=yes" onkeyup="get_product();">
										<span class="input-group-addon icon-ellipsis btnPoniter" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=order_form.product_id&field_name=order_form.product_name<cfif fusebox.circuit is 'store'>&is_store_module=1</cfif>','list');"></span>
                                    </div>
                                </div>
                            </div>
                       	</div>
                        <div class="col col-12">
                    		<div class="col col-3">
                            	<label><cf_get_lang_main no='1703.Sevk Yöntemi'></label>
                        	</div>
                            <div class="col col-9">
                                <div class="form-group medium">
                                	<div class="input-group">
                                    	<input type="hidden" name="ship_method_id" id="ship_method_id" value="<cfif isdefined('attributes.ship_method_id') and len(attributes.ship_method_name)><cfoutput>#attributes.ship_method_id#</cfoutput></cfif>">
										<input type="text" name="ship_method_name" id="ship_method_name" style="width:150px;" value="<cfif isdefined("attributes.ship_method_name") and len(attributes.ship_method_name)><cfoutput>#attributes.ship_method_name#</cfoutput></cfif>" onfocus="AutoComplete_Create('ship_method_name','SHIP_METHOD','SHIP_METHOD','get_ship_method','','SHIP_METHOD_ID','ship_method_id','','3','125');" autocomplete="off">
                                        <span class="input-group-addon icon-ellipsis btnPoniter" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_ship_methods&field_name=order_form.ship_method_name&field_id=order_form.ship_method_id','list');"></span>
                                	</div>
                                </div>
                            </div>
                       	</div>
                   	</div>
                    <div class="col col-3">
                    	<div class="col col-12">
                    		<div class="col col-3">
                            	<label><cf_get_lang_main no='45.Müsteri'></label>
                        	</div>
                            <div class="col col-9">
                                <div class="form-group medium">
                                	<div class="input-group">
                                    <input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined('attributes.consumer_id') and len(attributes.company)><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
									<input type="hidden" name="company_id" id="company_id" value="<cfif len(attributes.company)><cfoutput>#attributes.company_id#</cfoutput></cfif>">
									<input type="text" name="company" id="company" style="width:150px;" value="<cfif len(attributes.company)><cfoutput>#attributes.company#</cfoutput></cfif>">
									<span class="input-group-addon icon-ellipsis btnPoniter" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_comp_name=order_form.company&field_comp_id=order_form.company_id&field_consumer=order_form.consumer_id&field_member_name=order_form.company&select_list=2,3','list');"></span>
                                    </div>
                                </div>
                            </div>
                       	</div>
                    	<div class="col col-12">
                    		<div class="col col-3">
                            	<label>Kaydeden</label>
                        	</div>
                            <div class="col col-9">
                                <div class="form-group medium">
                                	<div class="input-group">
                                    	<input type="hidden" name="employee_id" id="employee_id" value="<cfif isdefined('attributes.employee_id') and len(attributes.employee_id) and isdefined('attributes.employee') and len(attributes.employee)><cfoutput>#attributes.employee_id#</cfoutput></cfif>">
                        				<input name="employee" type="text" id="employee" style="width:150px;" onfocus="AutoComplete_Create('employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','employee_id','','3','125');" value="<cfif isdefined('attributes.employee_id') and len(attributes.employee_id) and isdefined('attributes.employee') and len(attributes.employee)><cfoutput>#attributes.employee#</cfoutput></cfif>" autocomplete="off">	
                                        <span class="input-group-addon icon-ellipsis btnPoniter" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=order_form.employee_id&field_name=order_form.employee&is_form_submitted=1&select_list=1','list');"></span>
                                	</div>
                                </div>
                            </div>
                       	</div>
                   		<div class="col col-12">
                    		<div class="col col-3">
                            	<label>Temsilci</label>
                        	</div>
                            <div class="col col-9">
                                <div class="form-group medium">
                                	<div class="input-group">
                                    	<input type="hidden" name="pos_code" id="pos_code" value="<cfif isdefined('attributes.pos_code') and len(attributes.pos_code) and isdefined('attributes.pos_code_text') and len(attributes.pos_code_text)><cfoutput>#attributes.pos_code#</cfoutput></cfif>">
                        				<input name="pos_code_text" type="text" id="pos_code_text" style="width:150px;" onfocus="AutoComplete_Create('pos_code_text','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','pos_code','','3','125');" value="<cfif isdefined('attributes.pos_code') and len(attributes.pos_code) and isdefined('attributes.pos_code_text') and len(attributes.pos_code_text)><cfoutput>#attributes.pos_code_text#</cfoutput></cfif>" autocomplete="off">	
                                        <span class="input-group-addon icon-ellipsis btnPoniter" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=order_form.pos_code&field_name=order_form.pos_code_text&is_form_submitted=1&select_list=1','list');"></span>
                                	</div>
                                </div>
                            </div>
                       	</div>
                   	</div> 
                    <div class="col col-3">
                    	<div class="col col-12">
                        	<div class="col col-3">
                            	<label>Süreç</label>
                        	</div>
                            <div class="col col-9">
                    			<div class="form-group medium">
                    				<select name="order_process_cat" id="order_process_cat" style="height:110px;" multiple>
										<cfoutput query="get_process_type">
											<option value="#process_row_id#"<cfif listfind(attributes.order_process_cat,process_row_id)>selected</cfif>>#stage#</option>
										</cfoutput>
									</select>	
                         		</div>
                          	</div>
                     	</div> 
                        
                   	</div> 
                    <div class="col col-3">
                    	<div class="col col-12">
                        	<div class="col col-4">
								<label class="col col-3 col-sm-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                         	</div>
							<div class="col col-8">
                            	<div class="form-group medium">
                                    <div class="input-group">
                                        <input type="hidden" name="project_id" id="project_id" value="<cfif isdefined("attributes.project_id") and len (attributes.project_head)><cfoutput>#attributes.project_id#</cfoutput></cfif>">
										<input type="text" name="project_head"  id="project_head" placeholder="<cfoutput><cf_get_lang dictionary_id='57416.Proje'></cfoutput>" value="<cfif Len(attributes.project_head)><cfoutput>#get_project_name(attributes.project_id)#</cfoutput></cfif>" onfocus="AutoComplete_Create('project_head','PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','','3','200');" autocomplete="off">
										<span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_projects&project_id=order_form.project_id&project_head=order_form.project_head');"></span>
                                    </div>
                                </div>
                  			</div>
						</div>
                    	<div class="col col-12">
                    		<div class="col col-4">
                            	<label>İşlem Tarihi</label>
                        	</div>
                            <cfsavecontent variable="mesaj">İşlem Tarihi Başlangıç Değeri Giriniz</cfsavecontent>
                            <div class="col col-4">
                            	<div class="form-group medium">
                                    <div class="input-group x-14">
                                        <cfinput type="text" name="date1" placeholder="" value="#dateformat(attributes.date1, dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10" required="yes" message="#mesaj#">
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="date1"></span>
                                    </div>
                                </div>
                            </div>
                            <cfsavecontent variable="mesaj">İşlem Tarihi Bitiş Değeri Giriniz</cfsavecontent>
                            <div class="col col-4">
                            	<div class="form-group medium">
                                    <div class="input-group x-14">
                                        <cfinput type="text" name="date2" placeholder="" value="#dateformat(attributes.date2, dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10" required="yes" message="#mesaj#">
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="date2"></span>
                                    </div>
                                </div>
                            </div>
                       	</div>
                        <div class="col col-12">
                    		<div class="col col-4">
                            	<label>Termin Tarihi</label>
                        	</div>
                            <div class="col col-4">
                            	<div class="form-group medium">
                                    <div class="input-group x-14">
                                        <cfinput type="text" name="termin_date1" placeholder="" value="#dateformat(attributes.termin_date1, dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10" >
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="termin_date1"></span>
                                    </div>
                                </div>
                            </div>
                            <div class="col col-4">
                            	<div class="form-group medium">
                                    <div class="input-group x-14">
                                        <cfinput type="text" name="termin_date2" placeholder="" value="#dateformat(attributes.termin_date2, dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10">
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="termin_date2"></span>
                                    </div>
                                </div>
                            </div>
                       	</div>
                    </div>
               	</div>
        	</cf_box_search_detail> 
      	</cfform>
    </cf_box>
    <cfsavecontent variable="title">Sevkiyat Planlama</cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" right_images="">
		<cf_grid_list>
            <thead>  
                 <tr>
                    <th width="35" style="text-align:center;"><cf_get_lang dictionary_id='58577.Sira'></th>
                    <th width="80px"><cf_get_lang_main no='799.Siparis No'></th>
                    <th width="70px"><cf_get_lang_main no='1704.Siparis Tarihi'></th>
                    <th ><cf_get_lang dictionary_id='57416.Proje'></th>
                    <th ><cf_get_lang_main no='45.Müşteri'></th>
                    <th width="200px"><cf_get_lang_main no='1226.İlçe'></th>
                    <th width="190px">Nihai Müşteri</th>
                    <th width="150px"><cf_get_lang dictionary_id='58859.Süreç'></th>

                    <th><cf_get_lang_main no='217.Açıklama'></th>
                    <th width="30px"></th>
                    <th width="30px"></th>
                </tr>
            </thead>
         	<tbody>
            	<!---<cfdump var="#get_total_purchase_e#">--->
            	<cfif get_total_purchase_e.recordcount>
               		<cfoutput query="get_total_purchase_e" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                    	<cfquery name="get_order_rows" dbtype="query">
                        	SELECT * FROM get_total_purchase WHERE ORDER_ID = #ORDER_ID# ORDER BY ORDER_ROW_ID
                        </cfquery>
                        <!---<cfdump var="#get_order_rows#">--->
                        <cfif get_order_rows.recordcount>
                        	<cfset order_rows_id_list = ValueList(get_order_rows.ORDER_ROW_ID)>
                            <cfset order_rows_id_list = ListDeleteDuplicates(order_rows_id_list,',')>
                        <cfelse>
                        	<cfset order_rows_id_list = ''>
                        </cfif>
                    	<cfquery name="get_order_det" datasource="#DSN3#">
                            SELECT     
                                ORR.STOCK_ID, 
                                ORR.QUANTITY, 
                                ORR.ORDER_ROW_ID, 
                                ORD.ORDER_ID, 
                                ORD.ORDER_HEAD, 
                                ORD.ORDER_NUMBER, 
                                ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
                                ORR.SPECT_VAR_NAME, 
                                ORR.ORDER_ROW_CURRENCY,
                                S.PRODUCT_NAME, 
                                S.STOCK_CODE, 
                                S.STOCK_CODE_2, 
                                PO.LOT_NO, 
                                PO.FINISH_DATE, 
                                PO.P_ORDER_ID, 
                                POR.TYPE
                            FROM         
                                ORDERS AS ORD WITH (NOLOCK) RIGHT OUTER JOIN
                                ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                                STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
                                PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
                                PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) ON PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID ON ORR.ORDER_ROW_ID = POR.ORDER_ROW_ID ON 
                                ORD.ORDER_ID = ORR.ORDER_ID
                            WHERE     
                                ORD.ORDER_ID = #get_total_purchase_e.order_id# AND 
                                ISNULL(PO.PRODUCTION_LEVEL, 0) = N'0' AND
                                S.IS_PRODUCTION = 1 AND
                                ISNULL(S.IS_SERIAL_NO, 0) = 0
                            UNION ALL
                            SELECT     
                                ORR.STOCK_ID, 
                                ORR.QUANTITY, 
                                ORR.ORDER_ROW_ID, 
                                ORD.ORDER_ID, 
                                ORD.ORDER_HEAD, 
                                ORD.ORDER_NUMBER, 
                                ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
                                ORR.SPECT_VAR_NAME,
                                ORR.ORDER_ROW_CURRENCY, 
                                S.PRODUCT_NAME, 
                                S.STOCK_CODE, 
                                S.STOCK_CODE_2, 
                                O1.ORDER_NUMBER AS LOT_NO, 
                                O1.ORDER_DATE AS FINISH_DATE, 
                                O1.ORDER_ID AS P_ORDER_ID, 
                                3 AS TYPE
                            FROM         
                                ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                                ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
                                STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
                                ORDER_ROW AS ORR1 WITH (NOLOCK) ON ORR.WRK_ROW_ID = ORR1.WRK_ROW_RELATION_ID INNER JOIN
                                ORDERS AS O1 WITH (NOLOCK) ON ORR1.ORDER_ID = O1.ORDER_ID
                            WHERE  
                            	ISNULL(S.IS_SERIAL_NO, 0) = 0 AND   
                                ORD.ORDER_ID = #get_total_purchase_e.order_id# AND 
                                S.IS_PURCHASE = 1
                            UNION ALL
                            SELECT     
                                ORR.STOCK_ID, 
                                ORR.QUANTITY, 
                                ORR.ORDER_ROW_ID, 
                                ORD.ORDER_ID, 
                                ORD.ORDER_HEAD, 
                                ORD.ORDER_NUMBER, 
                                ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
                                ORR.SPECT_VAR_NAME, 
                                ORR.ORDER_ROW_CURRENCY,
                                S.PRODUCT_NAME, 
                                S.STOCK_CODE, 
                                S.STOCK_CODE_2, 
                                ORD1.ORDER_NUMBER AS LOT_NO, 
                                ORD1.ORDER_DATE AS FINISH_DATE, 
                                ORD1.ORDER_ID AS P_ORDER_ID, 
                                4 AS TYPE
                            FROM         
                                ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                                ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
                                STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
                                EZGI_ORDERS_ORDERS_REL WITH (NOLOCK) ON ORR.ORDER_ROW_ID = EZGI_ORDERS_ORDERS_REL.S_ORDER_ROW_ID AND 
                                ORR.ORDER_ID = EZGI_ORDERS_ORDERS_REL.S_ORDER_ID INNER JOIN
                                ORDER_ROW AS ORR1 WITH (NOLOCK) ON EZGI_ORDERS_ORDERS_REL.P_ORDER_ID = ORR1.ORDER_ID AND 
                                EZGI_ORDERS_ORDERS_REL.P_ORDER_ROW_ID = ORR1.ORDER_ROW_ID INNER JOIN
                                ORDERS AS ORD1 WITH (NOLOCK) ON ORR1.ORDER_ID = ORD1.ORDER_ID
                            WHERE  
                            	ISNULL(S.IS_SERIAL_NO, 0) = 0 AND   
                                ORD.ORDER_ID = #get_total_purchase_e.order_id# AND 
                                (S.IS_PRODUCTION = 1 OR S.IS_PURCHASE = 1)
                            UNION ALL
                            SELECT DISTINCT 
                  				ORR.STOCK_ID, 
                                ORR.QUANTITY, 
                                ORR.ORDER_ROW_ID, 
                                ORD.ORDER_ID, 
                                ORD.ORDER_HEAD, 
                                ORD.ORDER_NUMBER, 
                                ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
                                ORR.SPECT_VAR_NAME, 
                                ORR.ORDER_ROW_CURRENCY, 
                  				S.PRODUCT_NAME, 
                                S.STOCK_CODE, 
                                S.STOCK_CODE_2, 
                                PO.LOT_NO, 
                                PO.FINISH_DATE, 
                                EP.IFLOW_P_ORDER_ID AS P_ORDER_ID, 
                                6 AS TYPE
							FROM     
                            	EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) INNER JOIN
                  				PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EP.LOT_NO = PO.LOT_NO INNER JOIN
                  				PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) ON PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID INNER JOIN
                  				ORDER_ROW AS ORR ON POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                  				ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
                  				STOCKS AS S ON EP.STOCK_ID = S.STOCK_ID
							WHERE  
                            	ORD.ORDER_ID = #get_total_purchase_e.order_id# AND 
                                S.IS_KARMA = 1 AND
                                ISNULL(S.IS_SERIAL_NO, 0) = 0
                          	UNION ALL
                         	<!---Sipariş - Üretim Planı seri No--->
                            SELECT DISTINCT
                                ORR.STOCK_ID, 
                                ORR.QUANTITY, 
                                ORR.ORDER_ROW_ID, 
                                ORD.ORDER_ID, 
                                ORD.ORDER_HEAD, 
                                ORD.ORDER_NUMBER, 
                                ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
                                ORR.SPECT_VAR_NAME, 
                                ORR.ORDER_ROW_CURRENCY, 
                                S.PRODUCT_NAME, 
                                S.STOCK_CODE, 
                                S.STOCK_CODE_2,
                                PO.LOT_NO, 
                                PO.FINISH_DATE, 
                                PO.P_ORDER_ID,
                                11 AS TYPE
                            FROM     
                                PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
                                PRODUCTION_ORDERS_ROW AS EWM ON PO.P_ORDER_ID = EWM.PRODUCTION_ORDER_ID RIGHT OUTER JOIN
                                ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                                STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
                                ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID ON EWM.ORDER_ROW_ID = ORR.ORDER_ROW_ID
                            WHERE  
                                ORD.ORDER_ID = #get_total_purchase_e.order_id# AND 
                                ISNULL(PO.PRODUCTION_LEVEL, 0) = '0' AND 
                                S.IS_PRODUCTION = 1 AND 
                                ISNULL(S.IS_SERIAL_NO, 0) = 1 AND
                                NOT (EWM.PRODUCTION_ORDER_ROW_ID IS NULL)
                        </cfquery>
                        <!---<cfdump var="#get_order_det#">--->
                        <cfif get_order_det.recordcount>
                        	<cfset order_det_id_list = ValueList(get_order_det.ORDER_ROW_ID)>
                            <cfset order_det_id_list = ListDeleteDuplicates(order_det_id_list,',')>
                        <cfelse>
                        	<cfset order_det_id_list = ''>
                        </cfif>
                        <cfif not ListLen(order_det_id_list)>
                        	<cfset renk = 'orange'> 
						<cfelseif ListLen(order_det_id_list) eq ListLen(order_rows_id_list)>
                        	<cfset renk = 'salmon'>
                        <cfelse>
                        	<cfset renk = 'turquoise'>
                        </cfif>
                     	<tr>
                        	<td style="text-align:right; font-weight:bold" onclick="seviyelendir_rows(#currentrow#)">#currentrow#</td>
                         	<td nowrap style="text-align:center">
								<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.list_order&event=upd&order_id=#order_id#','longpage');" class="tableyazi">
								   #ORDER_NUMBER#
								</a>
                          	</td>
                          	<td style="text-align:center">#dateformat(ORDER_DATE,dateformat_style)#</td>
                            <td>
                            	<cfif isdefined('PROJECT_ID_#ORDER_ID#')>
                                	<cfset proje = Evaluate('PROJECT_ID_#ORDER_ID#')>
                                    <cfif isdefined('PROJECT_HEAD_#proje#')>
                                        #Evaluate('PROJECT_HEAD_#proje#')# 
                                    </cfif>
                                </cfif>
                         	</td>
                         	<td>
								<cfif MEMBER_TYPE eq 1><!--- kurumsallar icin --->
                                  	<a href="javascript://"  class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_com_det&company_id=#COMPANY_ID#','list')">#MUSTERI#</a>
                              	<cfelse>
                                 	<a href="javascript://"  class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_con_det&con_id=#COMPANY_ID#','list')">#MUSTERI#</a>
                              	</cfif>
                        	</td>
                         	<td>
                           		<cfif isdefined('COUNTY_NAME_#ORDER_ID#')>
                                	#Evaluate('COUNTY_NAME_#ORDER_ID#')# 
                                   	#Evaluate('CITY_NAME_#ORDER_ID#')#
                             	</cfif>
                         	</td>
                          	<td>#REF_NO#</td>
                            <td><cfif isdefined('STAGE_#ORDER_STAGE#')>#Evaluate('STAGE_#ORDER_STAGE#')#</cfif></td>
                            <td>#ORDER_DETAIL#</td>
							<td>
                            	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_add_ezgi_shipping&order_id=#ORDER_ID#','wide');"><i class="fa fa-truck" title="<cf_get_lang dictionary_id='58871.Sevk Planı Oluştur'>" alt="<cf_get_lang dictionary_id='58871.Sevk Planı Oluştur'>"></i></a>
                            </td>
                            <td style="background-color:#renk#">
                            	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id=#ORDER_ID#','wide');"><i class="fa fa-chain" title="<cf_get_lang dictionary_id='189.Ürün Bağlantı Listesi'>" alt="<cf_get_lang dictionary_id='189.Ürün Bağlantı Listesi'>"></i></a>
                            </td>
                      	</tr>
                        <!-- sil -->
                        <tr id="order_rows1_#get_total_purchase_e.currentrow#" style="display:none"><td colspan="11" style="height:1mm;background-color:gainsboro"></td></tr>
                        <thead style="width:100%">
                            <tr id="order_rows_#get_total_purchase_e.currentrow#" style="display:none;">
                            	<th style="text-align:right; font-size:10px; height:12px"><cf_get_lang_main no='1165.Sıra'></th>
                                <th style="font-size:10px"><cf_get_lang dictionary_id='57482.Asama'></th>
                                <th style="font-size:10px"><cf_get_lang_main no='106.Stok Kodu'></th>
                                <th colspan="2" style="font-size:10px"><cf_get_lang_main no='245.Ürün'></th>
                                <th style=" text-align:right;font-size:10px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                <th style=" text-align:right; font-size:10px"><cf_get_lang dictionary_id='57636.Birim'></th>
                                <th colspan="3" style=" text-align:right; font-size:10px"><cf_get_lang_main no='217.Açıklama'></th>
                                <th style=" text-align:right;font-size:10px"></th>
                            </tr>
                       	</thead>
                    	<cfloop query="get_order_rows">
                      		<tr id="order_rows_#get_total_purchase_e.currentrow#_#get_order_rows.currentrow#" style="display:none">
                           		<td style="height:10px;text-align:right; font-size:10px">#get_order_rows.CURRENTROW#</td>
                             	<td style="text-align:left; font-size:10px">#get_order_rows.CURRENTROW#
                                  	<cfswitch expression = "#get_order_rows.ORDER_ROW_CURRENCY#">
                                      	<cfcase value="-7"><cf_get_lang dictionary_id='29748.Eksik Teslimat'></cfcase>
                                      	<cfcase value="-8"><cf_get_lang dictionary_id='29749.Fazla Teslimat'> </cfcase>
                                      	<cfcase value="-6"><cf_get_lang dictionary_id='58761.Sevk'></cfcase>
                                      	<cfcase value="-5"><cf_get_lang dictionary_id='57456.Uretim'></cfcase>
                                      	<cfcase value="-4"><cf_get_lang dictionary_id='29747.Kismi Uretim'></cfcase>
                                      	<cfcase value="-3"><cf_get_lang dictionary_id='29746.Kapatildi'></cfcase>
                                       	<cfcase value="-2"><cf_get_lang dictionary_id='29745.Tedarik'></cfcase>
                                     	<cfcase value="-1"><cf_get_lang dictionary_id='58717.Aik'></cfcase>
                                  	</cfswitch>
                               	</td>
                              	<td style="text-align:left; font-size:10px">#get_order_rows.STOCK_CODE#</td>
                               	<td colspan="2" style="text-align:left; font-size:10px">#get_order_rows.PRODUCT_NAME#</td>
                             	<td style="text-align:right; font-size:10px">#get_order_rows.QUANTITY#</td>
                             	<td style="text-align:left; font-size:10px">#get_order_rows.BIRIM#</td>
                              	<td colspan="3" style="text-align:left; font-size:10px">#get_order_rows.PRODUCT_NAME2#</td>
                              	<td style="text-align:left; font-size:10px"></td>
                         	</tr>
                            <!-- sil -->
                       	</cfloop>
                        <tr id="order_rows2_#get_total_purchase_e.currentrow#" style="display:none"><td colspan="10" style="height:1mm; background-color:gainsboro"></td></tr>
                	</cfoutput>
              	</cfif>
         	</tbody>
   		</cf_grid_list> 
  	</cf_box>

	<cfset adres = '#attributes.fuseaction#'>
    <cfif len(attributes.report_sort)>
        <cfset adres = "#adres#&report_sort=#attributes.report_sort#">
    </cfif>
    <cfif len(attributes.product_id)>
        <cfset adres = "#adres#&product_id=#attributes.product_id#&product_name=#attributes.product_name#">
    </cfif>
    <cfif len(attributes.pos_code) and len(attributes.pos_code_text)>
        <cfset adres = "#adres#&pos_code=#attributes.pos_code#&pos_code_text=#attributes.pos_code_text#">
    </cfif> 
    <cfif len(attributes.employee_id) and len(attributes.employee)>
        <cfset adres = "#adres#&employee_id=#attributes.employee_id#&employee=#attributes.employee#">
    </cfif>
    <cfif len(attributes.employee_name) and len(attributes.product_employee_id)>
        <cfset adres = "#adres#&employee_name=#attributes.employee_name#&product_employee_id=#attributes.product_employee_id#">
    </cfif>
    <cfif len(attributes.sup_company_id)>
        <cfset adres = "#adres#&sup_company_id=#attributes.sup_company_id#&sup_company=#attributes.sup_company#">
    </cfif>
    <cfif len(attributes.company_id)>
        <cfset adres = "#adres#&company_id=#attributes.company_id#&company=#attributes.company#">
    </cfif>
    <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
        <cfset adres = "#adres#&consumer_id=#attributes.consumer_id#&company=#attributes.company#">
    </cfif>
    <cfif len(attributes.search_product_catid)>
        <cfset adres = "#adres#&search_product_catid=#attributes.search_product_catid#&product_cat=#attributes.product_cat#">
    </cfif>
    <cfif len(attributes.date1)>
        <cfset adres = "#adres#&date1=#attributes.date1#">
    </cfif>
    <cfif len(attributes.date2)>
        <cfset adres = "#adres#&date2=#attributes.date2#">
    </cfif>
    <cfif len(attributes.termin_date1)>
        <cfset adres = "#adres#&termin_date1=#attributes.termin_date1#">
    </cfif>
    <cfif len(attributes.termin_date2)>
        <cfset adres = "#adres#&termin_date2=#attributes.termin_date2#">
    </cfif>
    <cfif len(attributes.report_type)>
        <cfset adres = "#adres#&report_type=#attributes.report_type#">
    </cfif>
    <cfif len(attributes.zone_id)>
        <cfset adres = "#adres#&zone_id=#attributes.zone_id#">
    </cfif>
    <cfif isDefined("attributes.is_kdv") and len(attributes.is_kdv)>
        <cfset adres = "#adres#&is_kdv=#attributes.is_kdv#">
    </cfif>
    <cfif isDefined("attributes.member_cat_type") and len(attributes.member_cat_type)>
        <cfset adres = "#adres#&member_cat_type=#attributes.member_cat_type#">
    </cfif>
    <cfif isDefined("attributes.project_id") and len(attributes.project_id)>
        <cfset adres = "#adres#&project_id=#attributes.project_id#">
    </cfif>
    <cfif isDefined("attributes.project_head") and len(attributes.project_head)>
        <cfset adres = "#adres#&project_head=#attributes.project_head#">
    </cfif>
    <cfif isDefined("attributes.department_id") and len(attributes.department_id)>
        <cfset adres = "#adres#&department_id=#attributes.department_id#">
    </cfif>
    <cfif isDefined("attributes.is_project") and len(attributes.is_project)>
        <cfset adres = "#adres#&is_project=#attributes.is_project#">
    </cfif>
    <cfif isDefined("attributes.branch_id") and len(attributes.branch_id)>
        <cfset adres = "#adres#&branch_id=#attributes.branch_id#">
    </cfif>
    <cfif isDefined("attributes.sort_type") and len(attributes.sort_type)>
        <cfset adres = "#adres#&sort_type=#attributes.sort_type#">
    </cfif>
    <cfif isDefined("attributes.currency_type") and len(attributes.currency_type)>
        <cfset adres = "#adres#&currency_type=#attributes.currency_type#">
    </cfif>
    <cfif len(attributes.graph_type)>
        <cfset adres = "#adres#&graph_type=#attributes.graph_type#">
    </cfif>
    <cfif len(attributes.get_project_type)>
        <cfset adres = "#adres#&get_project_type=#attributes.get_project_type#">
    </cfif>	
    <cfif len(attributes.order_process_cat)>
        <cfset adres = "#adres#&get_project_type=#attributes.order_process_cat#">
    </cfif>	
    <cf_paging 
            page="#attributes.page#"
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#adres#&form_submitted=1">	
</div>	
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;
	}
	function seviyelendir_rows(row_count)
	{
		for(i=1;i<=1000;i++)
		{
			if(document.getElementById('order_rows_'+row_count+'_'+i) != undefined)
			{	
				if (document.getElementById('order_rows_'+row_count+'_'+i).style.display == 'none')
				{
					document.getElementById('order_rows_'+row_count+'_'+i).style.display = '';
				}
				else
				{
					document.getElementById('order_rows_'+row_count+'_'+i).style.display = 'none';
				}
			}
		}
		if(document.getElementById('order_rows_'+row_count) != undefined)
		{	
			if (document.getElementById('order_rows_'+row_count).style.display == 'none')
			{
				document.getElementById('order_rows_'+row_count).style.display = '';
				document.getElementById('order_rows1_'+row_count).style.display = '';
				document.getElementById('order_rows2_'+row_count).style.display = '';
			}
			else
			{
				document.getElementById('order_rows_'+row_count).style.display = 'none';
				document.getElementById('order_rows1_'+row_count).style.display = 'none';
				document.getElementById('order_rows2_'+row_count).style.display = 'none';
			}
		}
	}
</script>