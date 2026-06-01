<!---
    File: list_ezgi_order.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfsetting showdebugoutput="no">
<cf_xml_page_edit fuseact="prod.tracking">
<cfparam name="attributes.short_code_id" default="">
<cfparam name="attributes.brand_id" default="">
<cfparam name="attributes.spect_main_id" default="">
<cfparam name="attributes.spect_name" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.product_id_" default="">
<cfparam name="attributes.stock_id_" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.durum_siparis" default="0">
<cfparam name="attributes.priority" default="">
<cfparam name="attributes.date_filter" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.start_date_order" default="">
<cfparam name="attributes.finish_date_order" default="">
<cfparam name="attributes.category_name" default="">
<cfparam name="attributes.category" default="">
<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.member_cat_type" default="">

<!---Ezgi Bilgisayar Özelleştirme Başlangıç--->
<cfquery name="get_stations" datasource="#dsn3#">
	SELECT        
    	STATION_ID, 
        STATION_NAME, 
        BRANCH, 
        DEPARTMENT
	FROM            
    	WORKSTATIONS WITH (NOLOCK)
  	WHERE
        BRANCH IN
        			(
                    	SELECT 
    						BRANCH_ID
                        FROM 
                            #dsn_alias#.BRANCH WITH (NOLOCK)
                        WHERE
                            COMPANY_ID = #session.ep.COMPANY_ID# AND	
                            BRANCH_ID IN (SELECT BRANCH_ID FROM #dsn_alias#.EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">)
                    )
</cfquery>
<cfif isdefined('attributes.master_alt_plan_id')>
	<cfquery name="get_master_alt_plan" datasource="#dsn3#">
    	SELECT     
        	EMAP.PLAN_START_DATE, 
            EMAP.PLAN_FINISH_DATE, 
            EMP.MASTER_PLAN_PROJECT_ID, EMPS.SHIFT_ID,
            EMP.MASTER_PLAN_ID,
            EMPS.EMIR_SEVIYE,
            EMPS.WORKSTATION_ID
		FROM         
        	EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) INNER JOIN
            EZGI_MASTER_PLAN AS EMP WITH (NOLOCK) ON EMAP.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID INNER JOIN
            EZGI_MASTER_PLAN_SABLON AS EMPS WITH (NOLOCK) ON EMAP.PROCESS_ID = EMPS.PROCESS_ID
		WHERE     
        	EMAP.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
    </cfquery>
    <cfparam name="attributes.stage_info" default="#get_master_alt_plan.EMIR_SEVIYE#">
    <cfif get_master_alt_plan.recordcount>
    	<cfoutput query="get_master_alt_plan">
        	<cfparam name="attributes.station_id" default="#get_master_alt_plan.WORKSTATION_ID#">
			<cfset attributes.START_DATE_ = get_master_alt_plan.PLAN_START_DATE>
            <cfset attributes.FINISH_DATE_ = get_master_alt_plan.PLAN_FINISH_DATE>
            <cfset attributes.PROJECT_ID = get_master_alt_plan.MASTER_PLAN_PROJECT_ID>
            <cfset attributes.SHIFT_ID = get_master_alt_plan.SHIFT_ID>
            <cfset attributes.master_plan_id = get_master_alt_plan.MASTER_PLAN_ID>
    	</cfoutput>
    </cfif>
</cfif>
<!---Ezgi Bilgisayar Özelleştirme Bitiş--->
<cfif isdefined('attributes.start_date') and isdate(attributes.start_date)>
	<cf_date tarih='attributes.start_date'>
<cfelse>
	<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
		<cfset attributes.start_date=''>
	<cfelse>
		<cfset attributes.start_date=wrk_get_today()>
	</cfif>
</cfif>	
<cfif isdefined('attributes.finish_date') and isdate(attributes.finish_date)>
	<cf_date tarih='attributes.finish_date'>
<cfelse>
	<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
		<cfset attributes.finish_date=''>
	<cfelse>
	<cfset attributes.finish_date = date_add('d',1,now())>
	</cfif>
</cfif>
<cfif isdefined('attributes.start_date_order') and isdate(attributes.start_date_order)>
	<cf_date tarih='attributes.start_date_order'>
<cfelse>
	<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
		<cfset attributes.start_date_order=''>
	<cfelse>
		<cfset attributes.start_date_order=wrk_get_today()>
	</cfif>
</cfif>	
<cfif isdefined('attributes.finish_date_order') and isdate(attributes.finish_date_order)>
	<cf_date tarih='attributes.finish_date_order'>
<cfelse>
	<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
		<cfset attributes.finish_date_order=''>
	<cfelse>
	<cfset attributes.finish_date_order = date_add('d',1,now())>
	</cfif>
</cfif>
<cfparam name="attributes.sales_partner_id" default="">
<cfparam name="attributes.sales_partner" default="">
<cfparam name="attributes.order_employee_id" default="">
<cfparam name="attributes.order_employee" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.member_type" default="">
<cfparam name="attributes.member_name" default="">
<cfparam name="attributes.position_code" default="">
<cfparam name="attributes.position_name" default="">

<cfquery name="GET_PRIORITIES" datasource="#DSN#">
	SELECT PRIORITY_ID, PRIORITY FROM SETUP_PRIORITY ORDER BY PRIORITY_ID
</cfquery>
<cfquery name="GET_COMPANY_CAT" datasource="#DSN#">
	SELECT COMPANYCAT_ID,COMPANYCAT FROM COMPANY_CAT ORDER BY COMPANYCAT
</cfquery>
<cfquery name="GET_CONSUMER_CAT" datasource="#DSN#">
	SELECT CONSCAT_ID,CONSCAT FROM CONSUMER_CAT ORDER BY HIERARCHY
</cfquery>
<cfquery name="get_tree_xml_amount" datasource="#dsn#">
	SELECT 
		PROPERTY_VALUE,
		PROPERTY_NAME
	FROM
		FUSEACTION_PROPERTY
	WHERE
		OUR_COMPANY_ID = #session_base.company_id# AND
		FUSEACTION_NAME = 'prod.add_product_tree' AND
		PROPERTY_NAME = 'is_show_prod_amount'
</cfquery>
<cfif get_tree_xml_amount.recordcount>
	<cfset is_show_prod_amount = get_tree_xml_amount.PROPERTY_VALUE>
<cfelse>
	<cfset is_show_prod_amount = 1>
</cfif>
<cfquery name="get_prod_xml" datasource="#dsn#">
	SELECT 
		PROPERTY_VALUE,
		PROPERTY_NAME
	FROM
		FUSEACTION_PROPERTY
	WHERE
		OUR_COMPANY_ID = #session_base.company_id# AND
		FUSEACTION_NAME = 'prod.add_prod_order' AND
		PROPERTY_NAME = 'is_select_sub_product'
</cfquery>
<cfif get_prod_xml.recordcount>
	<cfset is_select_sub_product = get_prod_xml.PROPERTY_VALUE>
<cfelse>
	<cfset is_select_sub_product = 1>
</cfif>
<cfset order_priority_list = valuelist(get_priorities.priority_id)>

<cfif isdefined("attributes.is_submitted")>
	<cfscript>
		get_order_action = createObject("component", "addOns.ezgi.cfc.get_ezgi_orders");
		get_order_action.dsn3 = dsn3;
		get_order_action.dsn_alias = dsn_alias;
		GET_ORDERS = get_order_action.get_orders_fnc(
			ajax : '#IIf(IsDefined("attributes.ajax"),"attributes.ajax",DE(""))#',
			branch_id : '#IIf(IsDefined("attributes.branch_id"),"attributes.branch_id",DE(""))#',
			station_id : '#IIf(IsDefined("attributes.station_id"),"attributes.station_id",DE(""))#',
			department_id : '#IIf(IsDefined("attributes.department_id"),"attributes.department_id",DE(""))#',
			stock_id_ : '#IIf(IsDefined("attributes.stock_id_"),"attributes.stock_id_",DE(""))#',
			product_name : '#IIf(IsDefined("attributes.product_name"),"attributes.product_name",DE(""))#',
			durum_siparis : '#IIf(IsDefined("attributes.durum_siparis"),"attributes.durum_siparis",DE(""))#',
			priority : '#IIf(IsDefined("attributes.priority"),"attributes.priority",DE(""))#',
			position_code : '#IIf(IsDefined("attributes.position_code"),"attributes.position_code",DE(""))#',
			position_name : '#IIf(IsDefined("attributes.position_name"),"attributes.position_name",DE(""))#',
			short_code_id : '#IIf(IsDefined("attributes.short_code_id"),"attributes.short_code_id",DE(""))#',
			short_code_name : '#IIf(IsDefined("attributes.short_code_name"),"attributes.short_code_name",DE(""))#',
			keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
			start_date : '#IIf(IsDefined("attributes.start_date"),"attributes.start_date",DE(""))#',
			finish_date : '#IIf(IsDefined("attributes.finish_date"),"attributes.finish_date",DE(""))#',
			start_date_order : '#IIf(IsDefined("attributes.start_date_order"),"attributes.start_date_order",DE(""))#',
			finish_date_order : '#IIf(IsDefined("attributes.finish_date_order"),"attributes.finish_date_order",DE(""))#',
			sales_partner : '#IIf(IsDefined("attributes.sales_partner"),"attributes.sales_partner",DE(""))#',
			sales_partner_id : '#IIf(IsDefined("attributes.sales_partner_id"),"attributes.sales_partner_id",DE(""))#',
			order_employee : '#IIf(IsDefined("attributes.order_employee"),"attributes.order_employee",DE(""))#',
			order_employee_id : '#IIf(IsDefined("attributes.order_employee_id"),"attributes.order_employee_id",DE(""))#',
			member_name : '#IIf(IsDefined("attributes.member_name"),"attributes.member_name",DE(""))#',
			company_id : '#IIf(IsDefined("attributes.company_id"),"attributes.company_id",DE(""))#',
			consumer_id : '#IIf(IsDefined("attributes.consumer_id"),"attributes.consumer_id",DE(""))#',
			project_head : '#IIf(IsDefined("attributes.project_head"),"attributes.project_head",DE(""))#',
			project_id : '#IIf(IsDefined("attributes.project_id"),"attributes.project_id",DE(""))#',
			member_cat_type : '#IIf(IsDefined("attributes.member_cat_type"),"attributes.member_cat_type",DE(""))#',
			spect_main_id : '#IIf(IsDefined("attributes.spect_main_id"),"attributes.spect_main_id",DE(""))#',
			product_id_ : '#IIf(IsDefined("attributes.product_id_"),"attributes.product_id_",DE(""))#',
			product_name : '#IIf(IsDefined("attributes.product_name"),"attributes.product_name",DE(""))#',
			spect_name : '#IIf(IsDefined("attributes.spect_name"),"attributes.spect_name",DE(""))#',
			member_cat_type : '#IIf(IsDefined("attributes.member_cat_type"),"attributes.member_cat_type",DE(""))#',
			category : '#IIf(IsDefined("attributes.category"),"attributes.category",DE(""))#',
			category_name : '#IIf(IsDefined("attributes.category_name"),"attributes.category_name",DE(""))#',
			brand_id : '#iif(isdefined("attributes.brand_id"),"attributes.brand_id",DE(""))#',
			brand_name : '#iif(isdefined("attributes.brand_name"),"attributes.brand_name",DE(""))#',
			date_filter : '#IIf(IsDefined("attributes.date_filter"),"attributes.date_filter",DE(""))#'
		);
	</cfscript>
    <!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
    <cfquery name="get_orders" dbtype="query">
    	SELECT * FROM get_orders WHERE ORDER_ROW_CURRENCY = -5
    </cfquery>
    <!---Ezgi Bilgisayar Özelleştirme Bitiş--->
<cfelse>
	<cfset get_orders.recordcount = 0>
</cfif>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.modal_id" default="">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_orders.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfscript>wrkUrlStrings('url_str','durum_siparis','is_submitted','keyword','priority','date_filter','sales_partner_id','sales_partner','order_employee_id','order_employee','consumer_id','company_id','member_type','member_name','stock_id_','product_id_','product_name','is_group_page');</cfscript>
<cfif isdate(attributes.start_date)>
	<cfset url_str = url_str & "&start_date=#dateformat(attributes.start_date,dateformat_style)#">
</cfif>
<cfif isdate(attributes.finish_date)>
	<cfset url_str = url_str & "&finish_date=#dateformat(attributes.finish_date,dateformat_style)#">
</cfif>
<cfif isdate(attributes.start_date)>
	<cfset url_str = url_str & "&start_date=#dateformat(attributes.start_date,dateformat_style)#">
</cfif>
<cfif isdate(attributes.finish_date_order)>
	<cfset url_str = url_str & "&finish_date_order=#dateformat(attributes.finish_date_order,dateformat_style)#">
</cfif>
<cfif isdate(attributes.start_date_order)>
	<cfset url_str = url_str & "&start_date_order=#dateformat(attributes.start_date_order,dateformat_style)#">
</cfif>
<cfif  len(attributes.member_cat_type)>
	<cfset url_str = "#url_str#&member_cat_type=#attributes.member_cat_type#">
</cfif>
<cfif isDefined('attributes.project_id') and len(attributes.project_id)>
	<cfset url_str = '#url_str#&project_id=#attributes.project_id#'>
</cfif>
<cfif isDefined('attributes.project_head') and len(attributes.project_head)>
	<cfset url_str = '#url_str#&project_head=#attributes.project_head#'>
</cfif>
<cfif isDefined('attributes.short_code_id') and len(attributes.short_code_id)>
	<cfset url_str = '#url_str#&short_code_id=#attributes.short_code_id#'>
</cfif>
<cfif isDefined('attributes.short_code_name') and len(attributes.short_code_name)>
	<cfset url_str = '#url_str#&short_code_name=#attributes.short_code_name#'>
</cfif>
<cfif len(attributes.position_code) and len(attributes.position_name)>
	<cfset url_str = "#url_str#&position_code=#attributes.position_code#&position_name=#attributes.position_name#">
</cfif>
<cfif len(attributes.category)>
	<cfset url_str ="#url_str#&category=#attributes.category#">
</cfif>
<cfif len(attributes.category_name)>
	<cfset url_str= "#url_str#&category_name=#attributes.category_name#">
</cfif>
<!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
<cfif isDefined('attributes.master_alt_plan_id') and len(attributes.master_alt_plan_id)>
	<cfset url_str = '#url_str#&master_alt_plan_id=#attributes.master_alt_plan_id#'>
</cfif>
<cfif isDefined('attributes.islem_id') and len(attributes.islem_id)>
	<cfset url_str = '#url_str#&islem_id=#attributes.islem_id#'>
</cfif>
<!---Ezgi Bilgisayar Özelleştirme Bitiş--->
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#getLang('','Üretim Siparişler',47241)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
		<cfform name="search" method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
			<input type="hidden" name="is_submitted" id="is_submitted" value="1">
            <!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
            <input type="hidden" name="master_alt_plan_id" id="master_alt_plan_id"  value="<cfoutput>#attributes.master_alt_plan_id#</cfoutput>">
            <input type="hidden" name="master_plan_id" id="master_plan_id"  value="<cfoutput>#attributes.master_plan_id#</cfoutput>">
            <input type="hidden" name="islem_id" id="islem_id"  value="<cfoutput>#attributes.islem_id#</cfoutput>">	
            <input type="hidden" name="stage_info" id="stage_info"  value="<cfoutput>#attributes.stage_info#</cfoutput>">
            <!---Ezgi Bilgisayar Özelleştirme Bitiş--->
			<cfif isdefined('attributes.is_demand') and attributes.is_demand eq 1>
				<input type="hidden" name="is_demand" id="is_demand" value="<cfoutput>#attributes.is_demand#</cfoutput>">
			</cfif>
			<cf_box_search>
				<div class="form-group">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
					<cfinput type="text" name="keyword" id="keyword" value="#attributes.keyword#" placeholder="#message#">
				</div>
				<div class="form-group">
					<select name="priority" id="priority">
						<option value=""><cf_get_lang dictionary_id='57485.Öncelik'></option>
						<cfoutput query="get_priorities">
							<option value="#priority_id#" <cfif attributes.priority eq priority_id>selected</cfif>>#priority#</option>
						</cfoutput>
					</select>
				</div>
				<div class="form-group">
					<select name="date_filter" id="date_filter">
						<option value=""><cf_get_lang dictionary_id='36754.Tüm Tarihler'></option>
						<option value="1" <cfif attributes.date_filter eq 1>selected</cfif>><cf_get_lang dictionary_id ='36816.Sipariş Tarihine Göre Artan'></option>
						<option value="0" <cfif attributes.date_filter eq 0>selected</cfif>><cf_get_lang dictionary_id ='36817.Sipariş Tarihine Göre Azalan'></option>
						<option value="2" <cfif attributes.date_filter eq 2>selected</cfif>><cf_get_lang dictionary_id ='36818.Tesim Tarihine Göre Artan'></option>
						<option value="3" <cfif attributes.date_filter eq 3>selected</cfif>><cf_get_lang dictionary_id ='36819.Teslim Tarihine Göre Azalan'></option>
						<option value="4" <cfif attributes.date_filter eq 4>selected</cfif>><cf_get_lang dictionary_id ='36820.Ürün İsmine Göre Artan'></option>
						<option value="5" <cfif attributes.date_filter eq 5>selected</cfif>><cf_get_lang dictionary_id ='36821.Ürün İsmine Göre Azalan'></option>
						<option value="6" <cfif attributes.date_filter eq 6>selected</cfif>><cf_get_lang dictionary_id ='36822.Cari İsmine Göre Artan'></option>
						<option value="7" <cfif attributes.date_filter eq 7>selected</cfif>><cf_get_lang dictionary_id ='36823.Cari İsmine Göre Azalan'></option>
						<option value="8" <cfif attributes.date_filter eq 8>selected</cfif>><cf_get_lang dictionary_id ='36352.Stok Koduna Göre Artan'></option>
						<option value="9" <cfif attributes.date_filter eq 9>selected</cfif>><cf_get_lang dictionary_id ='36354.Stok Koduna Göre Azalan'></option>
					</select>
				</div>
				<div class="form-group small">
					<cfinput type="text" name="maxrows" id="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#getLang('','Kayıt Sayısı Hatalı',57537)#" maxlength="3">
				</div>
				<div class="form-group">
					<label id="col-12"><input type="checkbox" name="is_group_page" id="is_group_page"<cfif isdefined('attributes.is_group_page')>checked</cfif>><cf_get_lang dictionary_id ='36815.Grupla'></label>
				</div>
				<div class="form-group">
					<cf_wrk_search_button button_type="4" search_function="#iif(isdefined("attributes.draggable"),DE("loadPopupBox('search' , #attributes.modal_id#)"),DE(""))#">
					<cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'>
				</div>
			</cf_box_search>
			<cf_box_search_detail search_function="#iif(isdefined("attributes.draggable"),DE("loadPopupBox('search' , #attributes.modal_id#)"),DE(""))#">
				<cfset colspan_info_new = 19>
				<cfif isdefined("is_show_unit2") and is_show_unit2 eq 1><cfset colspan_info_new = colspan_info_new + 1></cfif>
				<cfif isdefined("is_show_work_prog") and is_show_work_prog eq 1><cfset colspan_info_new = colspan_info_new + 1></cfif>
				<cfif isdefined("is_order_detail") and is_order_detail eq 1><cfset colspan_info_new = colspan_info_new + 1></cfif>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
					<div class="form-group" id="item-product">
						<label class="col col-12"><cf_get_lang dictionary_id='57657.Ürün'></label>
						<div class="col col-12">
							<div class="input-group">
								<input type="hidden" name="stock_id_" id="stock_id_" value="<cfoutput>#attributes.stock_id_#</cfoutput>">
								<input type="hidden" name="product_id_" id="product_id_" value="<cfoutput>#attributes.product_id_#</cfoutput>">
								<input type="text"   name="product_name" id="product_name" value="<cfoutput>#attributes.product_name#</cfoutput>" onFocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME,STOCK_CODE','get_product_autocomplete','0','PRODUCT_ID,STOCK_ID','product_id_,stock_id_','','3','225','get_tree()');" autocomplete="off">
								<span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&stock_and_spect=1&field_spect_main_id=search.spect_main_id&field_spect_main_name=search.spect_name&field_id=search.stock_id_&product_id=search.product_id_&field_name=search.product_name&keyword='+encodeURIComponent(document.search.product_name.value));"></span>
							</div>
						</div>
					</div>
					<div class="form-group" id="item-member_name">
						<label class="col col-12"><cf_get_lang dictionary_id='57519.Cari Hesap'></label>
						<div class="col col-12">
							<div class="input-group">
								<input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#attributes.consumer_id#</cfoutput>">
								<input type="hidden" name="company_id"  id="company_id" value="<cfoutput>#attributes.company_id#</cfoutput>">
								<input type="hidden" name="member_type" id="member_type" value="<cfoutput>#attributes.member_type#</cfoutput>">
								<input type="text" name="member_name" id="member_name"  value="<cfoutput>#attributes.member_name#</cfoutput>" onFocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2\'','COMPANY_ID,CONSUMER_ID,MEMBER_TYPE','company_id,consumer_id,member_type','','3','250');" autocomplete="off">
								<span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&field_consumer=search.consumer_id&field_comp_id=search.company_id&field_member_name=search.member_name&field_type=search.member_type&select_list=7,8&keyword='+encodeURIComponent(document.search.member_name.value));"></span>
							</div>
						</div>
					</div>
					<div class="form-group" id="item-order_employee">
						<label class="col col-12"><cf_get_lang dictionary_id='36785.Satış Çalışanı'></label>
						<div class="col col-12">
							<div class="input-group">
								<input type="hidden" name="order_employee_id" id="order_employee_id" value="<cfoutput>#attributes.order_employee_id#</cfoutput>">
								<input type="text"   name="order_employee"  id="order_employee" value="<cfoutput>#attributes.order_employee#</cfoutput>" onFocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','order_employee_id','','3','135');" autocomplete="off">
								<span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=search.order_employee_id&field_name=search.order_employee&select_list=1','list');"></span>
							</div>
						</div>
					</div>
					<div class="form-group" id="item-durum_siparis">
						<label class="col col-12"><cf_get_lang dictionary_id="57756.Durum"></label>
						<div class="col col-12">
								<select name="durum_siparis" id="durum_siparis">
								<option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
								<option value="1" <cfif attributes.durum_siparis eq 1>selected</cfif>><cf_get_lang dictionary_id ='36752.Üretim Emri Verilenler'></option>
								<option value="0" <cfif attributes.durum_siparis eq 0>selected</cfif>><cf_get_lang dictionary_id ='36753.Üretim Emri Verilmeyenler'></option>
								<option value="2" <cfif attributes.durum_siparis eq 2>selected</cfif>><cf_get_lang dictionary_id ='36393.Talebe Dönüşenler'></option>
								<option value="3" <cfif attributes.durum_siparis eq 3>selected</cfif>><cf_get_lang dictionary_id ='36395.Talebe Dönüşmeyenler'></option>
								<option value="5" <cfif attributes.durum_siparis eq 5>selected</cfif>><cf_get_lang dictionary_id ='60535.Kısmi ÜE Verilen'></option>
								<option value="6" <cfif attributes.durum_siparis eq 6>selected</cfif>><cf_get_lang dictionary_id ='60536.Kısmi Talebe Dönüşen'></option>
								<option value="4" <cfif attributes.durum_siparis eq 4>selected</cfif>><cf_get_lang dictionary_id ='36411.İşlem Görmeyenler'></option>
							</select>
						</div>
					</div>
				</div>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
					<div class="form-group" id="item-project">
						<label class="col col-12"><cf_get_lang dictionary_id='57416.Proje'></label>
						<div class="col col-12">
							<cfif isdefined('attributes.project_head') and len(attributes.project_head)>
								<cfset project_id_ = #attributes.project_id#>
							<cfelse>
								<cfset project_id_ = ''>
							</cfif>
							<cf_wrkProject
								project_Id="#project_id_#"
								width="90"
								AgreementNo="1" Customer="2" Employee="3" Priority="4" Stage="5"
								boxwidth="600"
								boxheight="400">
							</div>
					</div>
					<div class="form-group" id="item-position_name">
						<label class="col col-12"><cf_get_lang dictionary_id='57544.Sorumlu'></label>
						<div class="col col-12">
							<div class="input-group">
								<input type="hidden" name="position_code" id="position_code" value="<cfif len(attributes.position_code) and len(attributes.position_name)><cfoutput>#attributes.position_code#</cfoutput></cfif>">
								<input type="text" name="position_name" id="position_name" value="<cfif len(attributes.position_code) and len(attributes.position_name)><cfoutput>#attributes.position_name#</cfoutput></cfif>" maxlength="255" onFocus="AutoComplete_Create('position_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','POSITION_CODE','position_code','','3','135');" autocomplete="off">
								<span class="input-group-addon icon-ellipsis" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_code=search.position_code&field_name=search.position_name&select_list=1&is_form_submitted=1&keyword='+encodeURIComponent(document.search.position_name.value,'list'));"></span>
							</div>
						</div>
					</div>
					<div class="form-group" id="item-sales_partner">
						<label class="col col-12"><cf_get_lang dictionary_id='36786.Satış Ortağı'></label>
						<div class="col col-12">
							<div class="input-group">
								<input type="hidden" name="sales_partner_id" id="sales_partner_id" value="<cfoutput>#attributes.sales_partner_id#</cfoutput>">
								<input type="text"   name="sales_partner"  id="sales_partner" onFocus="AutoComplete_Create('sales_partner','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_PARTNER_NAME,MEMBER_NAME','get_member_autocomplete','\'1,2\',0,0,0','PARTNER_ID','sales_partner_id','','3','250');" value="<cfoutput>#attributes.sales_partner#</cfoutput>" autocomplete="off">
								<span class="input-group-addon icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_id=search.sales_partner_id&field_name=search.sales_partner&select_list=2,3');"></span>
							</div>
						</div>
					</div>
					<div class="form-group" id="item-member_cat_type">
						<label class="col col-12"><cf_get_lang dictionary_id='58609.Üye Kategoris'></label>
						<div class="col col-12">
							<select name="member_cat_type" id="member_cat_type">
								<option value="" selected><cf_get_lang dictionary_id='57734.Üye Kategorisi Seçiniz'></option>
								<option value="1" <cfif attributes.member_cat_type eq 1>selected</cfif>><cf_get_lang dictionary_id='58039.Kurumsal Üye Kategorileri'></option>
								<cfoutput query="get_company_cat">
									<option value="1-#COMPANYCAT_ID#" <cfif attributes.member_cat_type is '1-#COMPANYCAT_ID#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#COMPANYCAT#</option>
								</cfoutput>
								<option value="2" <cfif attributes.member_cat_type eq 2>selected</cfif>><cf_get_lang dictionary_id='58040.Bireysel Üye Kategorileri'></option>
								<cfoutput query="get_consumer_cat">
									<option value="2-#CONSCAT_ID#" <cfif attributes.member_cat_type is '2-#CONSCAT_ID#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#CONSCAT#</option>
								</cfoutput>
							</select>
						</div>
					</div>
				</div>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
					<div class="form-group" id="item-brand_id">
						<label class="col col-12"><cf_get_lang dictionary_id='58847.Marka'></label>
						<div class="col col-12">
							<cf_wrkproductbrand
							width="100"
							compenent_name="getProductBrand"               
							boxwidth="240"
							boxheight="150"
							brand_id="#attributes.brand_id#">
						</div>
					</div>
					<div class="form-group" id="item-model">
						<label class="col col-12"><cf_get_lang dictionary_id='58225.Model'></label>
						<div class="col col-12">
							<cf_wrkProductModel
								returnInputValue="short_code_id,short_code_name"
								returnQueryValue="MODEL_ID,MODEL_NAME"
								width="90"
								fieldName="short_code_name"
								fieldId="short_code_id"
								compenent_name="getProductModel"
								boxwidth="300"
								boxheight="150"
								model_ID="#attributes.short_code_id#">
						</div>
					</div>
					<div class="form-group" id="item-spect_name">
						<label class="col col-12"><cf_get_lang dictionary_id='57647.Spec'></label>
						<div class="col col-12">
							<div class="input-group">
								<input type="hidden" name="spect_main_id" id="spect_main_id" value="<cfoutput>#attributes.spect_main_id#</cfoutput>">
								<input type="text" name="spect_name" id="spect_name" value="<cfoutput>#attributes.spect_name#</cfoutput>">
								<span class="input-group-addon icon-ellipsis btnPointer" onclick="product_control();"></span>
							</div>
						</div>
					</div>
					<div class="form-group" id="item-is_less_min_stock">
						<label class="col col-12">&nbsp;</label>
						<div class="col col-12">
							<!--- <input type="checkbox" name="is_less_min_stock" id="is_less_min_stock" <cfif isdefined('attributes.is_less_min_stock')>checked</cfif>><cfoutput>#getLang("store",9)#</cfoutput> ---><!--- Minimum Stoğun Altındaki Ürünleri De Getir --->
						</div>
					</div>
				</div>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
					<div class="form-group" id="item-category_name">
						<label class="col col-12"><cf_get_lang dictionary_id='57486.Kategori'></label>
						<div class="col col-12">
							<div class="input-group">
								<input type="hidden" name="category" id="category" value="<cfif len(attributes.category) and len(attributes.category_name)><cfoutput>#attributes.category#</cfoutput></cfif>">
								<input type="text" name="category_name" id="category_name" onFocus="AutoComplete_Create('category_name','PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','','HIERARCHY','category','','3','125');" value="<cfif len(attributes.category_name)><cfoutput>#attributes.category_name#</cfoutput></cfif>" autocomplete="off">
								<span class="input-group-addon icon-ellipsis btnPointer" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_cat_names&is_sub_category=1&field_code=search.category&field_name=search.category_name</cfoutput>');"></span>
							</div>
						</div>
					</div>
					<div class="form-group" id="item-start_date_order">
						<label class="col col-12"><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></label>
						<div class="col col-12">
							<div class="input-group">
								<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
									<input maxlength="10" type="text" name="start_date_order" id="start_date_order"  validate="#validate_style#" value="<cfoutput>#dateformat(attributes.start_date_order,dateformat_style)#</cfoutput>">
									<cfelse>
									<input required="Yes" maxlength="10" type="text" name="start_date_order" id="start_date_order"  validate="#validate_style#" value="<cfoutput>#dateformat(attributes.start_date_order,dateformat_style)#</cfoutput>">
								</cfif>
								<span class="input-group-addon"><cf_wrk_date_image date_field="start_date_order"></span>
								<span class="input-group-addon no-bg"></span>
								<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
									<input maxlength="10" type="text" name="finish_date_order" id="finish_date_order" value="<cfoutput>#dateformat(attributes.finish_date_order,dateformat_style)#</cfoutput>" validate="#validate_style#">
								<cfelse>
									<cfinput required="Yes" maxlength="10" type="text" name="finish_date_order" id="finish_date_order" value="#dateformat(attributes.finish_date_order,dateformat_style)#"  validate="#validate_style#">
								</cfif>
								<span class="input-group-addon"><cf_wrk_date_image date_field="finish_date_order"></span>
							</div>
						</div>
					</div>
					<div class="form-group" id="item-start_date">
						<label class="col col-12"><cf_get_lang dictionary_id="57645.Teslim Tarihi"></label>
						<div class="col col-12">
						<div class="input-group">
								<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
									<input maxlength="10" type="text" name="start_date" id="start_date" validate="#validate_style#" value="<cfoutput>#dateformat(attributes.start_date,dateformat_style)#</cfoutput>">
								<cfelse>
									<cfinput type="text" name="start_date" id="start_date" required="Yes" maxlength="10"  validate="#validate_style#" value="#dateformat(attributes.start_date,dateformat_style)#">
								</cfif>
								<span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
								<span class="input-group-addon no-bg"></span>
								<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
									<input maxlength="10" type="text" name="finish_date" id="finish_date" value="<cfoutput>#dateformat(attributes.finish_date,dateformat_style)#</cfoutput>" validate="#validate_style#">
								<cfelse>
									<input required="Yes" maxlength="10" type="text" name="finish_date" id="finish_date" value="<cfoutput>#dateformat(attributes.finish_date,dateformat_style)#</cfoutput>"  validate="#validate_style#">
								</cfif>
								<span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
							</div>
						</div>
					</div>
				</div>
			</cf_box_search_detail>
		</cfform>
		<cf_grid_list>
			<!---Ezgi Bilgisayar Özelleştirme Başlamgıç--->
            <cfinclude template="list_ezgi_production_orders_include.cfm">
            <!---Ezgi Bilgisayar Özelleştirme Bitiş--->
		</cf_grid_list>
		<cfif attributes.totalrecords gt attributes.maxrows>
		<cf_paging 
			page="#attributes.page#"
			maxrows="#attributes.maxrows#"
			totalrecords="#attributes.totalrecords#"
			startrow="#attributes.startrow#"
			adres="#attributes.fuseaction##url_str#"
			isAjax="#iif(isdefined("attributes.draggable"),1,0)#">
		</cfif>
		
	</cf_box>
</div>
<script type="text/javascript">
document.getElementById('keyword').focus();	
function get_tree(){
		if($("#stock_id_").val().length)
		{
			deneme = wrk_safe_query("get_stock_production",'dsn3',0,$("#stock_id_").val());
			//console.log('SELECT IS_PRODUCTION FROM STOCKS S WHERE S.STOCK_ID = ' + $("#stock_id_").val());
			deneme2 = wrk_safe_query("get_product_spect_main",'dsn3',0,$("#stock_id_").val());
			
			if(deneme.IS_PRODUCTION == 1 && (deneme2.recordcount == 0 || deneme2.SPECT_MAIN_ID == '') ){
				alert("<cf_get_lang dictionary_id='33963.Ürünü Üretildiği Halde Bir Ağacı Yok Görünüyor Üretilen Ürünü Ağaca Eklemek İçin Önce Ürünün Kendi Ağacını Oluşturmalısınız'>");
					$("#stock_id_").val('');
				$("#product_name").val('');
				return false;
			}
		}
	}

function change_date_info()
{
	if(document.getElementById('temp_hour').value == '' || document.getElementById('temp_hour').value > 23)
		document.getElementById('temp_hour').value = '00';
	if(document.getElementById('temp_min').value == '' || document.getElementById('temp_min').value > 59)
		document.getElementById('temp_min').value = '00';
	if(document.getElementById('temp_date').value!= '')
		for (i=0;i<document.getElementsByName('is_active').length;i++)
		{
			new_row_number = parseInt(<cfoutput>#attributes.startrow#</cfoutput>+i);
			document.getElementById('production_start_date_'+new_row_number).value = document.getElementById('temp_date').value;
			document.getElementById('production_start_h_'+new_row_number).value = parseFloat(document.getElementById('temp_hour').value);
			document.getElementById('production_start_m_'+new_row_number).value = parseFloat(document.getElementById('temp_min').value);
		}
}
function connectAjax(crtrow,prod_id,stock_id,order_amount,order_id,spect_main_id,optimum_ihtiyac){
	if(order_id==0) var order_id = document.getElementById('order_ids_'+crtrow).value;
	if(optimum_ihtiyac == undefined) optimum_ihtiyac = 1;
	if(order_amount == 0) order_amount=1;
	var bb = '<cfoutput>#request.self#?fuseaction=objects.emptypopup_ajax_product_stock_info&this_production_amount='+optimum_ihtiyac+'&tree_stock_status=1&is_show_prod_amount=#is_show_prod_amount#</cfoutput>&row_number='+crtrow+'&pid='+prod_id+'&sid='+ stock_id+'&amount='+ order_amount+'&order_id='+ order_id+'&spect_main_id='+spect_main_id;
	AjaxPageLoad(bb,'DISPLAY_ORDER_STOCK_INFO'+crtrow,1);
}
</script>