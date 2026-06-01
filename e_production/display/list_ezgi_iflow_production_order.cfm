<!---
    File: list_ezgi_iflow_production_order.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cf_xml_page_edit>
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.stock_id" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.sort_type" default="#x_list_sort#">
<cfparam name="attributes.is_in_package" default="">
<cfparam name="attributes.list_type" default="1">
<cfparam name="attributes.durum_emir" default="">
<cfparam name="attributes.master_plan_id" default="">
<cfparam name="attributes.member_cat_type" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.member_name" default="">
<cfparam name="attributes.member_type" default="">
<cfparam name="attributes.record_emp_id" default="">
<cfparam name="attributes.record_emp_name" default="">
<cfparam name="attributes.category_name" default="">
<cfparam name="attributes.station_id" default="">
<cfparam name="attributes.cat_id" default="">
<cfparam name="attributes.cat" default="">
<cfparam name="attributes.department_id" default="">
<cfparam name="attributes.PRODUCT_TYPE" default="">
<cfparam name="attributes.operation_type_id" default="">
<cfparam name="attributes.thickness_id" default="">
<cfparam name="attributes.color_id" default="">
<cfparam name="attributes.reverse_answer" default="">
<cfparam name="attributes.iflow_p_order_id_list" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.is_excel" default="">

<cfif isdefined("attributes.start_date") and isdate(attributes.start_date)>
	<cf_date tarih="attributes.start_date">
<cfelse>
	<cfset attributes.start_date = ''>
</cfif>
<cfif isdefined("attributes.finish_date") and isdate(attributes.finish_date)>
	<cf_date tarih="attributes.finish_date">
<cfelse>
	<cfset attributes.finish_date = ''>
</cfif>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfscript>
	get_production_orders.recordcount=0;
	get_production_orders.query_count=0;
	if (isdefined("attributes.is_submitted"))
	{
		get_production_orders_action = createObject("component", "addOns.ezgi.cfc.get_production_orders");
		get_production_orders_action.dsn3 = dsn3;
		get_production_orders = get_production_orders_action.get_production_orders_
		(
		 	start_date : '#iif(isdefined("attributes.start_date"),"attributes.start_date",DE(""))#',
			finish_date : '#iif(isdefined("attributes.finish_date"),"attributes.finish_date",DE(""))#',
		 	sort_type : '#iif(isdefined("attributes.sort_type"),"attributes.sort_type",DE(""))#',
			is_in_package : '#iif(isdefined("attributes.is_in_package"),"attributes.is_in_package",DE(""))#',
			keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
			list_type : '#IIf(IsDefined("attributes.list_type"),"attributes.list_type",DE(""))#',
			durum_emir : '#IIf(IsDefined("attributes.durum_emir"),"attributes.durum_emir",DE(""))#',
			master_plan_id : '#IIf(IsDefined("attributes.master_plan_id"),"attributes.master_plan_id",DE(""))#',
			member_cat_type : '#iif(isdefined("attributes.member_cat_type"),"attributes.member_cat_type",DE(""))#',
			consumer_id : '#iif(isdefined("attributes.consumer_id"),"attributes.consumer_id",DE(""))#',
			company_id : '#IIf(IsDefined("attributes.company_id"),"attributes.company_id",DE(""))#',
			member_name : '#IIf(IsDefined("attributes.member_name"),"attributes.member_name",DE(""))#',
			member_type : '#IIf(IsDefined("attributes.member_type"),"attributes.member_type",DE(""))#',
			record_emp_id : '#IIf(IsDefined("attributes.record_emp_id"),"attributes.record_emp_id",DE(""))#',
			record_emp_name : '#iif(isdefined("attributes.record_emp_name"),"attributes.record_emp_name",DE(""))#',
			category_name : '#iif(isdefined("attributes.category_name"),"attributes.category_name",DE(""))#',
			station_id : '#IIf(IsDefined("attributes.station_id"),"attributes.station_id",DE(""))#',
			cat_id : '#IIf(IsDefined("attributes.cat_id"),"attributes.cat_id",DE(""))#',
			cat : '#IIf(IsDefined("attributes.cat"),"attributes.cat",DE(""))#',
			color_id : '#IIf(IsDefined("attributes.color_id"),"attributes.color_id",DE(""))#',
			thickness_id : '#IIf(IsDefined("attributes.thickness_id"),"attributes.thickness_id",DE(""))#',
			department_id : '#IIf(IsDefined("attributes.department_id"),"attributes.department_id",DE(""))#',
			product_type : '#iif(isdefined("attributes.product_type"),"attributes.product_type",DE(""))#',
			product_name : '#iif(isdefined("attributes.product_name"),"attributes.product_name",DE(""))#',
			product_id : '#iif(isdefined("attributes.product_id"),"attributes.product_id",DE(""))#',
			stock_id : '#iif(isdefined("attributes.stock_id"),"attributes.stock_id",DE(""))#',
			operation_type_id : '#iif(isdefined("attributes.operation_type_id"),"attributes.operation_type_id",DE(""))#',
			iflow_p_order_id_list : '#iif(isdefined("attributes.iflow_p_order_id_list"),"attributes.iflow_p_order_id_list",DE(""))#',
			reverse_answer : '#iif(isdefined("attributes.reverse_answer"),"attributes.reverse_answer",DE(""))#',
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
<cfquery name="get_master_plan" datasource="#dsn3#">
	SELECT        
    	MASTER_PLAN_ID, 
        MASTER_PLAN_NUMBER, 
        MASTER_PLAN_DETAIL
	FROM            
    	EZGI_IFLOW_MASTER_PLAN WITH (NOLOCK)
  	WHERE
    	1=1
    	
  	<cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
    	AND (
        		MASTER_PLAN_STATUS = 1 OR (MASTER_PLAN_ID IN (#attributes.master_plan_id#) AND MASTER_PLAN_STATUS = 0)
         	)
    	AND MASTER_PLAN_CAT_ID IN  
            
                    (
                        SELECT        
                            MASTER_PLAN_CAT_ID
                        FROM       
                            EZGI_IFLOW_MASTER_PLAN AS M WITH (NOLOCK)
                        WHERE        
                            MASTER_PLAN_ID IN (#attributes.master_plan_id#)
                    )
    <cfelse>
    	AND MASTER_PLAN_STATUS = 1
    </cfif>
	ORDER BY 
    	MASTER_PLAN_NUMBER
</cfquery>
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK) WHERE  IS_ACTIVE = 1 ORDER BY COLOR_NAME
</cfquery>
<cfquery name="get_thickness" datasource="#dsn3#">
	SELECT DISTINCT      
    	THICKNESS_ID, 
        THICKNESS_NAME
	FROM            
    	EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK)
	WHERE        
        LIST_ORDER_NO = 1
	ORDER BY 
    	THICKNESS_NAME
</cfquery>
<cfquery name="get_stations" datasource="#dsn3#">
	SELECT        
    	PO.STATION_ID
	FROM            
     	EZGI_IFLOW_MASTER_PLAN AS M WITH (NOLOCK) INNER JOIN
     	EZGI_IFLOW_MASTER_PLAN AS M1 WITH (NOLOCK) ON M.MASTER_PLAN_CAT_ID = M1.MASTER_PLAN_CAT_ID INNER JOIN
      	EZGI_IFLOW_PRODUCTION_ORDERS AS POL WITH (NOLOCK) ON M1.MASTER_PLAN_ID = POL.MASTER_PLAN_ID INNER JOIN
     	PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON POL.LOT_NO = PO.LOT_NO
	WHERE   
     	(NOT (PO.STATION_ID IS NULL)) 
      	<cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
         	AND M.MASTER_PLAN_ID IN (#attributes.master_plan_id#)
      	</cfif>
	GROUP BY 
     	PO.STATION_ID
</cfquery>
<cfif get_stations.recordcount>
	<cfset v_list = ValueList(get_stations.STATION_ID)>
    <cfquery name="get_station" datasource="#dsn3#">
        SELECT        
            W.STATION_ID, 
            W.STATION_NAME
        FROM            
            WORKSTATIONS W WITH (NOLOCK)
        WHERE        
            W.UP_STATION IS NULL AND 
            W.STATION_ID IN (#v_list#)
        ORDER BY 
            W.STATION_NAME
    </cfquery>
    <cfoutput query="get_station">
        <cfset 'STATION_NAME_#STATION_ID#' = STATION_NAME>
    </cfoutput>
</cfif>
<cfif isdefined("attributes.is_submitted")>
	<cfif get_production_orders.recordcount>
    	<cfset iflow_p_order_list = ValueList(get_production_orders.iflow_p_order_id)>
   		<cfset iflow_p_order_list = ListDeleteDuplicates(iflow_p_order_list,',')>
        <cfif attributes.list_type eq 1>
        	<cfset iflow_order_list = ValueList(get_production_orders.order_id)>
            <cfquery name="get_orders" datasource="#dsn3#">
                SELECT        
                    ORDER_ID, 
                    ORDER_HEAD, 
                    ORDER_NUMBER, 
                    ORDER_DATE,
                    DELIVERDATE,
                    CASE
                        WHEN O.COMPANY_ID IS NOT NULL THEN
                       (
                        SELECT     
                            NICKNAME
                        FROM         
                            #dsn_alias#.COMPANY WITH (NOLOCK)
                        WHERE     
                            COMPANY_ID = O.COMPANY_ID
                        )
                        WHEN O.CONSUMER_ID IS NOT NULL THEN      
                        (	
                        SELECT     
                            CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                        FROM         
                            #dsn_alias#.CONSUMER WITH (NOLOCK)
                        WHERE     
                            CONSUMER_ID = O.CONSUMER_ID
                        )
                        WHEN O.EMPLOYEE_ID IS NOT NULL THEN
                        (
                        SELECT     
                            EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
                        FROM         
                            #dsn_alias#.EMPLOYEES WITH (NOLOCK)
                        WHERE     
                            EMPLOYEE_ID = O.EMPLOYEE_ID
                        )
                        END
                            AS UNVAN
                FROM            
                    ORDERS AS O WITH (NOLOCK)
                WHERE        
                    ORDER_ID IN (#iflow_order_list#)
            </cfquery>
            <cfoutput query="get_orders">
                <cfset 'ORDER_NUMBER_#ORDER_ID#' = ORDER_NUMBER>
                <cfset 'ORDER_DATE_#ORDER_ID#' = ORDER_DATE>
                <cfset 'UNVAN_#ORDER_ID#' = UNVAN>
                <cfset 'DELIVERDATE_#ORDER_ID#' = DELIVERDATE>
            </cfoutput>
        <cfelseif attributes.list_type eq 3 or attributes.list_type eq 4 or attributes.list_type eq 5>
        	<cfquery name="get_group" dbtype="query">
            	SELECT
                	COUNT(*) AS SAY,
                    STOCK_ID
              	FROM
                	get_production_orders
              	WHERE
               		IS_GROUP_LOT = 1 	
              	GROUP BY
                	<cfif attributes.list_type eq 3>
                        LOT_NO,STOCK_ID
                    <cfelseif attributes.list_type eq 4>  
                        P_ORDER_PARTI_NUMBER,STOCK_ID
                    <cfelseif attributes.list_type eq 5>
                        STOCK_ID
                  	</cfif>
       		</cfquery>
            <cfif get_group.recordcount>
				<cfoutput query="get_group">
                    <cfset 'SAY_#STOCK_ID#' = SAY>
                </cfoutput>
            	<cfset gurup_button = 1>
            <cfelse>
                <cfset gurup_button = 0>    
            </cfif>
        <cfelse>
        	<cfquery name="get_orders" datasource="#dsn3#">
            	SELECT 
                	CASE
                        WHEN O.COMPANY_ID IS NOT NULL THEN
                       (
                        SELECT     
                            NICKNAME
                        FROM         
                            #dsn_alias#.COMPANY WITH (NOLOCK)
                        WHERE     
                            COMPANY_ID = O.COMPANY_ID
                        )
                        WHEN O.CONSUMER_ID IS NOT NULL THEN      
                        (	
                        SELECT     
                            CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                        FROM         
                            #dsn_alias#.CONSUMER WITH (NOLOCK)
                        WHERE     
                            CONSUMER_ID = O.CONSUMER_ID
                        )
                        WHEN O.EMPLOYEE_ID IS NOT NULL THEN
                        (
                        SELECT     
                            EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
                        FROM         
                            #dsn_alias#.EMPLOYEES WITH (NOLOCK)
                        WHERE     
                            EMPLOYEE_ID = O.EMPLOYEE_ID
                        )
                  	END AS UNVAN,      
                	EP.IFLOW_P_ORDER_ID, 
                    O.ORDER_NUMBER
				FROM            
               		EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) INNER JOIN
                 	PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EP.LOT_NO = PO.LOT_NO INNER JOIN
                 	PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) ON PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID INNER JOIN
                 	ORDERS AS O WITH (NOLOCK) ON POR.ORDER_ID = O.ORDER_ID
				WHERE        
                	EP.IFLOW_P_ORDER_ID IN (#iflow_p_order_list#)
              	GROUP BY 
                	EP.IFLOW_P_ORDER_ID, 
                    O.ORDER_NUMBER,
                    O.CONSUMER_ID,
                    O.COMPANY_ID,
                    O.EMPLOYEE_ID
            </cfquery>
            <cfoutput query="get_orders">
                <cfset 'ORDER_NUMBER_#IFLOW_P_ORDER_ID#' = ORDER_NUMBER>
                <cfset 'UNVAN_#IFLOW_P_ORDER_ID#' = UNVAN>
            </cfoutput>
        </cfif>
    </cfif>
<cfelse>
	<cfset get_production_orders.recordcount = 0>
    <cfset arama_yapilmali = 1>
</cfif>
<cfquery name="GET_COMPANY_CAT" datasource="#DSN#">
	SELECT COMPANYCAT_ID,COMPANYCAT FROM COMPANY_CAT ORDER BY COMPANYCAT
</cfquery>
<cfquery name="GET_CONSUMER_CAT" datasource="#DSN#">
	SELECT CONSCAT_ID,CONSCAT FROM CONSUMER_CAT ORDER BY HIERARCHY
</cfquery>
<cfquery name="get_operations" datasource="#dsn3#">
	SELECT OPERATION_TYPE_ID, OPERATION_TYPE FROM OPERATION_TYPES WHERE OPERATION_STATUS = 1 ORDER BY OPERATION_TYPE
</cfquery>
<cfparam name="attributes.totalrecords" default='#get_production_orders.query_count#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
			<input name="is_submitted" id="is_submitted" type="hidden" value="1">
            <cfinput type="hidden" name="iflow_p_order_id_list" id="iflow_p_order_id_list" value="#attributes.iflow_p_order_id_list#"> 
            <cf_box_search>
                <div class="form-group">
                    <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group medium">
                	<select name="list_type" id="list_type" style="width:100px; height:20px" onchange="change_list_type()">
                   		<option value="1" <cfif attributes.list_type eq 1>selected</cfif>><cf_get_lang dictionary_id='472.Üst Emirler'></option>
                    	<option value="2" <cfif attributes.list_type eq 2>selected</cfif>><cf_get_lang dictionary_id='473.Alt Emirler'></option>
                      	<option value="3" <cfif attributes.list_type eq 3>selected</cfif>><cf_get_lang dictionary_id='664.Lot Grupla'></option>
                       	<option value="4" <cfif attributes.list_type eq 4>selected</cfif>><cf_get_lang dictionary_id='665.Parti Grupla'></option>
                       	<option value="5" <cfif attributes.list_type eq 5>selected</cfif>><cf_get_lang dictionary_id='1044.Plan Grupla'></option>
                 	</select>
               	</div>
                <div id="sort_type_" class="form-group medium">
                	<select name="sort_type" id="sort_type" style="width:160px;height:20px">
                        <option value="0" <cfif attributes.sort_type eq 0>selected</cfif>><cf_get_lang dictionary_id='37959.Ürün Adına Göre Artan'></option>
                        <option value="1" <cfif attributes.sort_type eq 1>selected</cfif>><cf_get_lang dictionary_id='37960.Ürün Adına Göre Azalan'></option>
                        <option value="2" <cfif attributes.sort_type eq 2>selected</cfif>><cf_get_lang dictionary_id='465.Emir Nosuna Göre Artan'></option>
                        <option value="3" <cfif attributes.sort_type eq 3>selected</cfif>><cf_get_lang dictionary_id='466.Emir Nosuna Göre Azalan'></option>
                        <option value="4" <cfif attributes.sort_type eq 4>selected</cfif>><cf_get_lang dictionary_id='467.Emir Tarihine Göre Artan'></option>
                        <option value="5" <cfif attributes.sort_type eq 5>selected</cfif>><cf_get_lang dictionary_id='468.Emir Tarihine Göre Azalan'></option>
                        <option value="6" <cfif attributes.sort_type eq 6>selected</cfif>><cf_get_lang dictionary_id='35.Paket No Artan'></option>
                        <option value="7" <cfif attributes.sort_type eq 7>selected</cfif>><cf_get_lang dictionary_id='57456.Üretim'><cf_get_lang dictionary_id='34667.Sıra No'></option>
                        <option value="8" <cfif attributes.sort_type eq 8>selected</cfif>><cf_get_lang dictionary_id='35843.Renk'></option>
                 	</select>
                </div>
                <div class="form-group medium">
                	<select name="durum_emir" id="durum_emir" style="width:100px;height:20px">
                    	<option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                      	<option value="1" <cfif attributes.durum_emir eq 1>selected</cfif>><cf_get_lang dictionary_id='1045.Kapalı Emirler'></option>
                    	<option value="2" <cfif attributes.durum_emir eq 2>selected</cfif>><cf_get_lang dictionary_id='1046.Açık Emirler'></option>
                 	</select>
                </div>
                <div class="form-group medium">
                	<select name="station_id" style="width:150px;height:20px">
                    	<option value="" <cfif attributes.station_id eq ''>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
						<cfoutput query="get_station">
                         	<option value="#STATION_ID#" <cfif attributes.station_id eq STATION_ID>selected</cfif>>#STATION_NAME#</option>
                     	</cfoutput>
                	</select>
                </div>
                <div class="form-group medium">
                	<select name="is_in_package" id="is_in_package" style="width:100px;height:20px">
                      	<option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                     	<option value="1" <cfif attributes.is_in_package eq 1>selected</cfif>><cf_get_lang dictionary_id='40162.Alt Ürünler'></option>
                   		<option value="2" <cfif attributes.is_in_package eq 2>selected</cfif>><cf_get_lang dictionary_id='40161.Ana Ürün'></option>
                  	</select>
                </div>
                <div class="form-group" id="form_ul_date">
                	<div class="col col-12">
                     	<div class="col col-6 pl-0">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='30122.Başlangıç Tarihini Kontrol Ediniz'></cfsavecontent>
                                <cfinput type="text" name="start_date" value="#dateformat(attributes.start_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                            </div>
                       	</div>
                        <div class="col col-6 pl-0">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='30123.Bitiş Tarihini Kontrol Ediniz'></cfsavecontent>
                                <cfinput type="text" name="finish_date" value="#dateformat(attributes.finish_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                            </div>
                       	</div>
                   	</div>
                </div>
                <div class="form-group medium">
                	<input type="checkbox" name="is_excel" id="is_excel" value="1" <cfif attributes.is_excel eq 1>checked</cfif>>
                	<cf_get_lang_main no='446.Excel Getir'>
                </div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>
          		<div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
          	</cf_box_search>
            <cf_box_search_detail>
                <!---<div id="detail_search_div" style="display:table-row;">--->
                	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                  		<div class="form-group" id="form_ul_company">
                        	<div class="input-group">
                        	<input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#attributes.consumer_id#</cfoutput>">
                            <input type="hidden" name="company_id"  id="company_id" value="<cfoutput>#attributes.company_id#</cfoutput>">
                            <input type="hidden" name="member_type" id="member_type" value="<cfoutput>#attributes.member_type#</cfoutput>">
                            <input type="text"   name="member_name" id="member_name" style="width:175px;height:20px" placeholder="<cf_get_lang dictionary_id='57519.Cari Hesap'>" value="<cfoutput>#attributes.member_name#</cfoutput>" onFocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2\'','COMPANY_ID,CONSUMER_ID,MEMBER_TYPE','company_id,consumer_id,member_type','','3','250');" autocomplete="off">
                        	<span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&field_consumer=search.consumer_id&field_comp_id=search.company_id&field_member_name=search.member_name&field_type=search.member_type&select_list=7,8&keyword='+encodeURIComponent(document.search.member_name.value),'list');"></span>
                            </div>
                        </div>
                        <div class="form-group" id="form_ul_employee">
                        	<div class="input-group">
                        	<input type="hidden" name="record_emp_id" id="record_emp_id" value="<cfif isdefined("attributes.record_emp_id")><cfoutput>#attributes.record_emp_id#</cfoutput></cfif>">
							<input name="record_emp_name" type="text" id="record_emp_name" style="width:150px;height:20px" placeholder="<cf_get_lang dictionary_id='57899.Kaydeden'>" onfocus="AutoComplete_Create('record_emp_name','FULLNAME','FULLNAME','get_emp_pos','','EMPLOYEE_ID','record_emp_id','','3','130');" value="<cfif isdefined("attributes.record_emp_id") and len(attributes.record_emp_id)><cfoutput>#attributes.record_emp_name#</cfoutput></cfif>" maxlength="255" autocomplete="off">
                        	<span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=search.record_emp_id&field_name=search.record_emp_name<cfif fusebox.circuit is "store">&is_store_module=1</cfif>&select_list=1&is_submitted=1&keyword='+encodeURIComponent(document.search.record_emp_name.value),'list','popup_list_positions');"></span>
                            </div>
                        </div>
                        <div class="form-group" id="form_ul_cat">
                        	<div class="input-group">
                                <input type="hidden" name="cat_id" id="cat_id" value="<cfif len(attributes.cat_id) and len(attributes.category_name)><cfoutput>#attributes.cat_id#</cfoutput></cfif>">
                                <input type="hidden" name="cat" id="cat" value="<cfif len(attributes.cat) and len(attributes.category_name)><cfoutput>#attributes.cat#</cfoutput></cfif>">
                                <input name="category_name" type="text" id="category_name" placeholder="<cf_get_lang dictionary_id='57486.Kategori'>" style="width:170px;height:20px" onfocus="AutoComplete_Create('category_name','PRODUCT_CATID,PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','','PRODUCT_CATID,HIERARCHY','cat_id,cat','','3','200','','1');" value="<cfif len(attributes.category_name)><cfoutput>#attributes.category_name#</cfoutput></cfif>" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_product_cat_names&is_sub_category=1&field_id=search.cat_id&field_code=search.cat&field_name=search.category_name</cfoutput>','list');"></span>
                            </div>
                        </div>
                  	</div>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                    	<div class="form-group" id="form_ul_master">
                            <select name="master_plan_id" style="width:150px;height:120px" onchange="change_iflow_master_plan_id()" multiple>
                                <option value="" <cfif attributes.master_plan_id eq ''>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_master_plan">
                                    <option value="#MASTER_PLAN_ID#" <cfif ListFind(attributes.master_plan_id,MASTER_PLAN_ID)>selected</cfif>>#MASTER_PLAN_NUMBER# - #MASTER_PLAN_DETAIL#</option>
                                </cfoutput>
                            </select>
                        </div>
                   	</div>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                     	
                        <div class="form-group" id="form_ul_product">
                        	<div class="input-group">
                                <input type="hidden" name="stock_id" id="stock_id" value="<cfoutput>#attributes.stock_id#</cfoutput>">
                                <input type="hidden" name="product_id" id="product_id" value="<cfoutput>#attributes.product_id#</cfoutput>">
                                <input type="text"   name="product_name"  id="product_name" placeholder="<cf_get_lang_main no='245.Ürün'>"  value="<cfoutput>#attributes.product_name#</cfoutput>" passthrough="readonly=yes" onfocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME','get_product_autocomplete','0','PRODUCT_ID,STOCK_ID','product_id,stock_id','','3','225');" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis btnPoniter" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=search.stock_id&product_id=search.product_id&field_name=search.product_name');"></span>
                            </div>
                        </div>
                        <div class="form-group" id="form_ul_color">
							<select name="color_id" id="color_id" style="width:130px;height:20px">
                                <option value=""><cf_get_lang dictionary_id='199.Renk'></option>
                                <cfoutput query="get_colors">
                                    <option value="#COLOR_ID#" <cfif  attributes.color_id eq COLOR_ID>style="font-weight:bold" selected </cfif>>#COLOR_NAME#</option>
                                </cfoutput>
                            </select>
                        </div>
                        <div class="form-group" id="form_ul_tickness">
                        	<select name="thickness_id" id="thickness_id" style="width:70px;height:20px">
                                <option value=""><cf_get_lang dictionary_id='75.Kalınlık'></option>
                                <cfoutput query="get_thickness">
                                    <option value="#THICKNESS_ID#" <cfif attributes.thickness_id eq THICKNESS_ID>selected</cfif>>#THICKNESS_NAME#</option>
                                </cfoutput>
                            </select>
                        </div>
                  	</div>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                        
                        
                         <div class="form-group" id="form_ul_operation">
                        	<div class="col col-6">
                                <select name="operation_type_id" id="operation_type_id" style="width:190px; height:120px" multiple>
                                    <cfoutput query="get_operations">
                                        <option value="#OPERATION_TYPE_ID#" <cfif ListFind(attributes.operation_type_id,OPERATION_TYPE_ID)>selected</cfif>>#OPERATION_TYPE#</option>
                                    </cfoutput>
                                </select>
                            </div>
                            <div class="col col-6">
                                <cf_get_lang dictionary_id='30056.Olmayanlar'>
                                <input name="reverse_answer" type="checkbox" value="1" <cfif isdefined('attributes.reverse_answer') and attributes.reverse_answer eq 1>checked</cfif>>
                        	</div>
                        </div>
                        
                	</div>
               	<!---</div>--->
          	</cf_box_search_detail>
    	</cfform>
  	</cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='649.Üretim Emirleri'></cfsavecontent>
    <cfsavecontent variable="right">
    	<cfif attributes.list_type eq 1 or attributes.list_type eq 2>
     	<a href="javascript://" onClick="gecim(-2);"><img src="../images/print.gif" border="0"></a>&nbsp;&nbsp;&nbsp;
        </cfif>
	</cfsavecontent>
    <cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
			<cfset filename = "#createuuid()#">
            <cfheader name="Expires" value="#Now()#">
            <cfcontent type="application/vnd.msexcel;charset=utf-8">
            <cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
            <cfset attributes.startrow=1>
            <cfset attributes.maxrows = get_production_orders.recordcount>
	</cfif>

    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1" right_images="#right#">
      	<cf_grid_list>
        	<thead>
                <tr valign="middle">
                    <th style="width:25px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th style="width:65px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='536.Planlama Tarihi'></th>
                    <th style="width:50px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='695.Plan No'></th>
                    <th style="width:50px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='32496.Parti No'></th>
                    <th style="width:50px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='32916.Lot No'></th>
                    <cfif attributes.list_type eq 1>
                        <th style="width:50px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='537.Ürün Tipi'></th>
                    <cfelse>
                    	<!-- sil -->
                        <th style="width:20px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57630.Tip'></th>
                        <!-- sil -->
                        <th style="width:50px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='29474.Emir No'></th>
                        <th style="width:50px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='1047.Grup Lot No'></th>
                        <th style="width:40px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='400.Paket No'></th>
                        <th style="width:80px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57789.Özel Kod'></th>
                    </cfif>
                    <th style="width:100px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                    <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                    <th style="width:95px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='1043.Kesim Bitiş'></th>
                    <th style="width:95px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='1042.Paket Teslim'></th>
                    <cfif attributes.list_type eq 2>
                    <th style="width:70px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58211.Sipariş No'></th>
                    <th style="width:200px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57457.Müşteri'></th>
                    </cfif>
                    
                    <cfif attributes.list_type eq 1>
                    	<th style="width:40px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57635.Miktar'></th>
                        <th style="width:40px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='36608.Üretilen'>%</th>
                        <th style="width:70px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58211.Sipariş No'></th>
                        <th style="width:70px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></th>
                        <th style="width:70px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='290.Termin Tarihi'></th>
                        <th style="width:200px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57457.Müşteri'></th>
                    <cfelse>
                    	<th style="width:40px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57635.Miktar'></th>
                        <th style="width:40px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='36608.Üretilen'></th>
                        <th style="width:40px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58444.Kalan'></th>
                    	<!-- sil -->
                        <th style="width:20px; text-align:center; vertical-align:middle" class="header_icn_none" ></th>
                        <!-- sil -->
                    </cfif>
                    <!-- sil -->
                    
                    <th style="width:20px; text-align:center; vertical-align:middle" class="header_icn_none" ></th>
                    <th style="width:20px; text-align:center; vertical-align:middle" class="header_icn_none" >
                        <cfif not attributes.is_excel eq 1><input type="checkbox" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="gecim(-1);"></cfif>
                    </th>
                    <!-- sil -->
                </tr>
            </thead>
            
            <tbody>
				<cfif get_production_orders.recordcount>
                    <cfoutput query="get_production_orders">
                        <cfif attributes.list_type eq 2 or attributes.list_type eq 3 or attributes.list_type eq 4 or attributes.list_type eq 5>
                            <cfif isdefined('AMOUNT_#IFLOW_P_ORDER_ID#_#PRODUCT_TYPE#_#STOCK_ID#')>
                                <cfset amount_result = Evaluate('AMOUNT_#IFLOW_P_ORDER_ID#_#PRODUCT_TYPE#_#STOCK_ID#')>
                            <cfelse>
                                <cfset amount_result = 0>
                            </cfif>
                        <cfelse>
                            <cfif isdefined('AMOUNT_#IFLOW_P_ORDER_ID#')>
                                <cfset amount_result = Evaluate('AMOUNT_#IFLOW_P_ORDER_ID#')>
                            <cfelse>
                                <cfset amount_result = 0>
                            </cfif>
                        </cfif>
                        <tr>
                            <td style="text-align:right;">#RowNum#</td>
                            <td style="text-align:center;" nowrap>#DateFormat(PLANNING_DATE, dateformat_style)#</td>
                            <td style="text-align:center;">#MASTER_PLAN_NUMBER#</td>
                            <td style="text-align:center;">#P_ORDER_PARTI_NUMBER#</td>
                            <td style="text-align:center;">
                            	<a href="javascript://" onclick="window.open('#request.self#?fuseaction=prod.popup_list_ezgi_iflow_production_operations&is_form_submitted=1&keyword=#LOT_NO#','_blank');">
                            		#LOT_NO#
                             	</a>
                            </td>
                            <cfif attributes.list_type eq 1>
                                <td style="text-align:center;">
                                    <cfif PRODUCT_TYPE eq 1><cf_get_lang dictionary_id='58511.Takım'>
                                    <cfelseif PRODUCT_TYPE eq 2><cf_get_lang dictionary_id='141.Modül'>
                                    <cfelseif PRODUCT_TYPE eq 3><cf_get_lang dictionary_id='100.Paket'>
                                    <cfelseif PRODUCT_TYPE eq 4><cf_get_lang dictionary_id='45.Parça'>
                                    <cfelse><cf_get_lang dictionary_id='404.Hammadde'>
                                    </cfif>
                                </td>
                            <cfelse>
                            	<!-- sil -->
                                <td style="text-align:center;">
                                	<cfif not attributes.is_excel eq 1>
                                    <cfif PIECE_TYPE eq 1>
                                        <img src="/images/butcegider.gif" title="<cf_get_lang dictionary_id='62.Yonga Levha'>"><span style="display:none">1</span>
                                    <cfelseif PIECE_TYPE eq 2>
                                        <img src="/images/arrow_up.png" title="<cf_get_lang dictionary_id='402.Genel Reçete'>"><span style="display:none">2</span>
                                    <cfelseif PIECE_TYPE eq 3>
                                        <img src="/images/elements.gif" title="<cf_get_lang dictionary_id='403.Montaj Ürünü'>"><span style="display:none">3</span>
                                    <cfelseif PIECE_TYPE eq 4>
                                        <img src="/images/promo_multi.gif" title="<cf_get_lang dictionary_id='404.Hammadde'>"><span style="display:none">4</span>
                                    <cfelseif PIECE_TYPE eq 0>
                                    	<cfquery name="get_type" datasource="#dsn3#">
                                        	SELECT 
                                            	TOP (1) DESIGN_MAIN_RELATED_ID AS STOCK_ID, 1 AS TYPE
                                            FROM     
                                            	EZGI_DESIGN_MAIN_ROW
                                            WHERE  
                                            	DESIGN_MAIN_RELATED_ID = #STOCK_ID#
                                            UNION ALL
                                            SELECT 
                                            	TOP (1) PACKAGE_RELATED_ID AS STOCK_ID, 2 AS TYPE
                                            FROM     
                                            	EZGI_DESIGN_PACKAGE_ROW
                                            WHERE  
                                            	PACKAGE_RELATED_ID = #STOCK_ID#
                                        </cfquery>
                                      	<cfif get_type.recordcount and get_type.TYPE eq 2>
                                        	<img src="/images/package.gif" title="<cf_get_lang dictionary_id='100.Paket'>"><span style="display:none">0</span>
                                       	<cfelseif get_type.recordcount and get_type.TYPE eq 1>
                                        	<img src="/images/asset.gif" title="<cf_get_lang dictionary_id='141.Modül'>"><span style="display:none">0</span>
                                      	<cfelse>
                                        	<img src="/images/promo_multi.gif" title="<cf_get_lang dictionary_id='404.Hammadde'>"><span style="display:none">4</span>
                                        </cfif>
                                    </cfif>
                                    </cfif>
                                </td>
                                <!-- sil -->
                                <td style="text-align:center;">
                                    <cfif attributes.list_type eq 2>
                                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.order&event=upd&upd=#p_order_id#','longpage');" class="tableyazi">
                                            #P_ORDER_NO#
                                        </a>
                                    <cfelse>
                                        #P_ORDER_NO#
                                    </cfif>
                                </td> 
                                <td style="text-align:center;">#GROUP_LOT_NO#</td>  
                                <td style="text-align:center;">#PACKAGE_NUMBER#</td> 
                                <td style="text-align:left;">#PRODUCT_CODE_2#</td> 
                            </cfif>
                            <td style="text-align:center;">#PRODUCT_CODE#</td>
                            <td style="text-align:left;" nowrap="nowrap">
                            	<cfif len(PRODUCT_NAME)><cfset p_name = PRODUCT_NAME><cfelse><cfset p_name = NAME_PRODUCT></cfif>
                            	#Left(p_name,80)#<cfif len(p_name) gt 80>...</cfif>
                           	</td>
                            <td style="text-align:center;" nowrap>
                                <cfif len(CUTTING_FINISH_DATE)>
                                    #DateFormat(CUTTING_FINISH_DATE, dateformat_style)# - (#TimeFormat(CUTTING_FINISH_DATE, 'HH:MM')#)
                                </cfif>


                            </td>
                            <td style="text-align:center;" nowrap>
                                <cfif len(FINISH_DATE)>
                                    #DateFormat(FINISH_DATE, dateformat_style)# - (#TimeFormat(finish_date, 'HH:MM')#)
                                </cfif>
                            </td>

                            <cfif attributes.list_type eq 1>
                                <td style="text-align:right;">#AmountFormat(QUANTITY)#</td>
                                <td style="text-align:right;">#AmountFormat(AMOUNT)#</td>
                                <td style="text-align:center;" nowrap="nowrap">
                                    <cfif isdefined('ORDER_NUMBER_#ORDER_ID#')>
                                        #Evaluate('ORDER_NUMBER_#ORDER_ID#')#
                                    </cfif>
                                </td>
                                <td style="text-align:center;">
                                    <cfif isdefined('ORDER_DATE_#ORDER_ID#')>
                                        #DateFormat(Evaluate('ORDER_DATE_#ORDER_ID#'),dateformat_style)#
                                    </cfif>
                                </td>
                                <td style="text-align:center;">
                                    <cfif isdefined('DELIVERDATE_#ORDER_ID#')>
                                        #DateFormat(Evaluate('DELIVERDATE_#ORDER_ID#'),dateformat_style)#
                                    </cfif>
                                </td>
                                <td style="text-align:center;">
                                    <cfif isdefined('UNVAN_#ORDER_ID#')>
                                        #Evaluate('UNVAN_#ORDER_ID#')#
                                    </cfif>
                                </td>
                                <!-- sil --> 
                                <td style="text-align:center;">
                                	<cfif not attributes.is_excel eq 1>
										<cfif IS_STAGE eq 4>
                                            <img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='475.Onaylanmadı'>">
                                        <cfelseif IS_STAGE eq 0>
                                            <img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                        <cfelseif IS_STAGE eq 1>
                                            <img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='398.Başladı'>">
                                        <cfelseif IS_STAGE eq 2>
                                            <img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='305.Bitti'>">
                                        <cfelseif IS_STAGE eq 3>
                                            <img src="/images/grey_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                        </cfif>
                                    </cfif>
                                </td>
                                
                                <!-- sil -->
                            <cfelse>
                            	<cfif attributes.list_type eq 2>
                                    <td style="text-align:center;" nowrap="nowrap">
                                        <cfif isdefined('ORDER_NUMBER_#IFLOW_P_ORDER_ID#')>
                                            #Evaluate('ORDER_NUMBER_#IFLOW_P_ORDER_ID#')#
                                        </cfif>
                                    </td>
                                    <td style="text-align:center;" nowrap="nowrap">
										<cfif isdefined('UNVAN_#IFLOW_P_ORDER_ID#')>
                                            #Left(Evaluate('UNVAN_#IFLOW_P_ORDER_ID#'),25)#
                                        </cfif>
                                    </td>
                                </cfif>
                                <td style="text-align:right;">#AmountFormat(QUANTITY)#</td>
                                <td style="text-align:right;">#AmountFormat(AMOUNT)#</td>
                                <td style="text-align:right;">#AmountFormat(QUANTITY-AMOUNT)#</td>
                                <!-- sil -->
                                <td style="text-align:center;" nowrap>
                                	<cfif not attributes.is_excel eq 1>
                                    <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_iflow_production_order_result&p_order_id=#p_order_id#','small');"><img src="/images/plus_list.gif" title="<cf_get_lang dictionary_id='57582.Ekle'>"></a>
                                    </cfif>
                                </td>
                                <td style="text-align:center;">
                                	<cfif not attributes.is_excel eq 1>
										<cfif AMOUNT eq 0>
                                            <img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                        <cfelseif (round(QUANTITY*100)/100)-(round(AMOUNT*100)/100) eq 0>
                                        	<a style="cursor:pointer" onclick="windowopen('#request.self#?fuseaction=prod.popup_list_ezgi_iflow_production_order_result&p_order_id=#p_order_id#','list');">
                                            	<img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='305.Bitti'>">
                                            </a>
                                        <cfelseif AMOUNT gt 0>
                                        	<a style="cursor:pointer" onclick="windowopen('#request.self#?fuseaction=prod.popup_list_ezgi_iflow_production_order_result&p_order_id=#p_order_id#','list');">
                                            	<img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='398.Başladı'>">
                                            </a>
                                        </cfif>
                                    </cfif>
                                </td>
                                <!-- sil -->
                            </cfif>
                            <!-- sil -->
                            
							<cfif attributes.list_type eq 1>
                            	<td style="text-align:center; <cfif PRINT_COUNT gt 0>background-color:orange</cfif>"><cfif not attributes.is_excel eq 1><input type="checkbox" name="select_sub_plan" value="#PRODUCT_TYPE#-#IFLOW_P_ORDER_ID#"></cfif></td> 
                        	<cfelse>
                             	<td style="text-align:center; <cfif PRINT_COUNT gt 0>background-color:orange</cfif>">
                               		<cfif attributes.list_type eq 2 or ((attributes.list_type eq 3 or attributes.list_type eq 4 or attributes.list_type eq 5))>
                                     	<cfif not attributes.is_excel eq 1>
                                            <input type="checkbox" name="select_sub_plan" value="#P_ORDER_ID#">
                                     	</cfif>
                                 	</cfif>
                             	</td> 
                        	</cfif>
                            <!-- sil -->
                        </tr>
                    </cfoutput>
                    <!-- sil -->
                    <tfoot>
                        <tr>
                            <td colspan="22" style="height:35px; text-align:right">
                            	<cfif not attributes.is_excel eq 1>
									<cfif attributes.list_type neq 1 and attributes.list_type neq 2>
                                        <cfif gurup_button eq 0>
                                            <button type="button" name="gecim_button" id="gecim_button" onclick="gecim(-3);" style="width:100px; height:30px; text-align:center;font-size:10px; font-weight:bold">
                                                <img src="/images/action_plus.gif" alt="Gurupla" border="0">&nbsp;<cf_get_lang dictionary_id='36815.Grupla'>
                                            </button>
                                        <cfelse>
                                        	<button type="button" name="birles_button" id="birles_button" onclick="gecim(-7);" style="width:100px; height:30px; text-align:center;font-size:10px; font-weight:bold">
                                                <img src="/images/replyall.gif" alt="<cf_get_lang dictionary_id='747.Birleştir'>" border="0">&nbsp;<cf_get_lang dictionary_id='747.Birleştir'>
                                            </button>&nbsp;
                                            <button type="button" name="gecim_button" id="gecim_button" onclick="gecim(-4);" style="width:100px; height:30px; text-align:center;font-size:10px; font-weight:bold">
                                                <img src="/images/action.gif" alt="<cf_get_lang dictionary_id='477.Grup Çöz'>" border="0">&nbsp;<cf_get_lang dictionary_id='477.Grup Çöz'>
                                            </button>
                                        </cfif>
                                    <cfelse>
                                        <cfif attributes.list_type eq 2>
                                            <button type="button" name="operation_button" id="operation_button" onclick="gecim(-6);" style="width:200px; height:30px; text-align:center;font-size:10px; font-weight:bold">
                                                <img src="/images/action.gif" alt="<cf_get_lang dictionary_id='623.Operasyon Bilgisi Güncelle'>" border="0">&nbsp;<cf_get_lang dictionary_id='623.Operasyon Bilgisi Güncelle'>
                                            </button>
                                        
                                        
                                            <button type="button" name="material_button" id="material_button" onclick="gecim(-5);" style="width:100px; height:30px; text-align:center;font-size:10px; font-weight:bold">
                                                <img src="/images/forklift.gif" alt="<cf_get_lang dictionary_id='444.Malzeme'>" border="0">&nbsp;<cf_get_lang dictionary_id='444.Malzeme'>
                                            </button>
                                            </cfif>
                                    </cfif>
                                </cfif>
                            </td>
                        </tr>
                    </tfoot>
                    <!-- sil -->
              	<cfelse>
                    <tr> 
                        <td colspan="22" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
                    </tr>
                </cfif>
            </tbody>
       	</cf_grid_list>
        <cfset adres = url.fuseaction>
		<cfif len(attributes.cat) and len(attributes.category_name)>
          <cfset adres = '#adres#&cat=#attributes.cat#&category_name=#attributes.category_name#'>
        </cfif>
        <cfif isDefined('attributes.company_id') and len(attributes.company_id) and isDefined('attributes.member_name') and len(attributes.member_name)>
          <cfset adres = '#adres#&company_id=#attributes.company_id#&member_name=#attributes.member_name#'>
        </cfif>	
        <cfif isDefined('attributes.consumer_id') and len(attributes.consumer_id) and isDefined('attributes.member_name') and len(attributes.member_name)>
          <cfset adres = '#adres#&consumer_id=#attributes.consumer_id#&member_name=#attributes.member_name#'>
        </cfif>	
        <cfif isDefined('attributes.record_emp_id') and len(attributes.record_emp_id) and isDefined('attributes.record_emp_name') and len(attributes.record_emp_name)>
          <cfset adres = '#adres#&record_emp_id=#attributes.record_emp_id#&record_emp_name=#attributes.record_emp_name#'>
        </cfif>	
        <cfif isDefined('attributes.cat_id') and len(attributes.cat_id) and isDefined('attributes.cat') and len(attributes.category_name) and len(attributes.category_name)>
          <cfset adres = '#adres#&cat_id=#attributes.cat_id#&cat=#attributes.cat#&category_name=#attributes.category_name#'>
        </cfif>	
        <cfif len(attributes.keyword)>
          <cfset adres = '#adres#&keyword=#URLEncodedFormat(attributes.keyword)#'>
        </cfif>
        <cfif len(attributes.sort_type)>
            <cfset adres = '#adres#&sort_type=#attributes.sort_type#'>
		</cfif>
       	<cfif isDefined('attributes.is_in_package') and len(attributes.is_in_package)>
            <cfset adres = '#adres#&is_in_package=#attributes.is_in_package#'>
		</cfif>
        <cfif isDefined('attributes.list_type') and len(attributes.list_type)>
            <cfset adres = '#adres#&list_type=#attributes.list_type#'>
		</cfif>
        <cfif isDefined('attributes.durum_emir') and len(attributes.durum_emir)>
            <cfset adres = '#adres#&durum_emir=#attributes.durum_emir#'>
		</cfif>
        <cfif isDefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
            <cfset adres = '#adres#&master_plan_id=#attributes.master_plan_id#'>
		</cfif>
        <cfif isDefined('attributes.member_cat_type') and len(attributes.member_cat_type)>
            <cfset adres = '#adres#&member_cat_type=#attributes.member_cat_type#'>
		</cfif>
        <cfif isDefined('attributes.station_id') and len(attributes.station_id)>
            <cfset adres = '#adres#&station_id=#attributes.station_id#'>
		</cfif>
        <cfif isDefined('attributes.department_id') and len(attributes.department_id)>
            <cfset adres = '#adres#&department_id=#attributes.department_id#'>
		</cfif>
        <cfif isDefined('attributes.operation_type_id') and len(attributes.operation_type_id)>
            <cfset adres = '#adres#&operation_type_id=#attributes.operation_type_id#'>
		</cfif>
        <cfif isDefined('attributes.product_type') and len(attributes.product_type)>
            <cfset adres = '#adres#&product_type=#attributes.product_type#'>
		</cfif>
        <cfif isDefined('attributes.thickness_id') and len(attributes.thickness_id)>
            <cfset adres = '#adres#&thickness_id=#attributes.thickness_id#'>
		</cfif>
        <cfif isDefined('attributes.color_id') and len(attributes.color_id)>
            <cfset adres = '#adres#&color_id=#attributes.color_id#'>
		</cfif>
        <cfif isDefined('attributes.product_id') and len(attributes.product_id)>
			<cfset adres = '#adres#&product_id=#attributes.product_id#&stock_id=#attributes.stock_id#'>
        </cfif>
        <cfif isDefined('attributes.product_name') and len(attributes.product_name)>
            <cfset adres = '#adres#&product_name=#attributes.product_name#'>
        </cfif>
        <cfif isDefined('attributes.iflow_p_order_id_list') and len(attributes.iflow_p_order_id_list)>
            <cfset adres = '#adres#&iflow_p_order_id_list=#attributes.iflow_p_order_id_list#'>
        </cfif>
        <cf_paging 
            page="#attributes.page#"
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#adres#&is_submitted=1">
  	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		if(document.getElementById('is_excel').checked==false)
			return true;	
	}
	function change_list_type()
	{
		if(document.getElementById('list_type').value == 2 || document.getElementById('list_type').value == 1)
		{
			document.getElementById('sort_type_').style.display = '';
		}
		else if(document.getElementById('list_type').value == 3 || document.getElementById('list_type').value == 4 || document.getElementById('list_type').value == 5)
		{
			document.getElementById('sort_type_').style.display = 'none';
		}
	}	
	function gecim(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
		p_order_id_list = '';
		chck_leng = document.getElementsByName('select_sub_plan').length;
		for(ci=0;ci<chck_leng;ci++)
		{
			var my_objets = document.all.select_sub_plan[ci];
			if(chck_leng == 1)
				var my_objets =document.all.select_sub_plan;
			if(type == -1){//hepsini seç denilmişse	
				if(my_objets.checked == true)
					my_objets.checked = false;
				else
					my_objets.checked = true;
			}
			else
			{
				if(my_objets.checked == true)
					p_order_id_list +=my_objets.value+',';
			}
		}
		p_order_id_list = p_order_id_list.substr(0,p_order_id_list.length-1);//sondaki virgülden kurtarıyoruz.
		if(list_len(p_order_id_list,','))
		{
			if(type == -2)
				windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_ezgi_print_files&print_type=286</cfoutput>&action_id='+p_order_id_list,'wide');	
			else if(type == -3)
				windowopen('<cfoutput>#request.self#?fuseaction=prod.emptypopup_upd_ezgi_iflow_production_order_group&gurupla=1&master_plan_id=#attributes.master_plan_id#&list_type=#attributes.list_type#</cfoutput>&p_order_id_list='+p_order_id_list,'small');
			else if(type == -4)
				windowopen('<cfoutput>#request.self#?fuseaction=prod.emptypopup_upd_ezgi_iflow_production_order_group&gurupla=0&master_plan_id=#attributes.master_plan_id#&list_type=#attributes.list_type#</cfoutput>&p_order_id_list='+p_order_id_list,'small');
			else if(type == -7)<!---Birleştir--->
				windowopen('<cfoutput>#request.self#?fuseaction=prod.emptypopup_upd_ezgi_iflow_production_order_group&gurupla=2&master_plan_id=#attributes.master_plan_id#&list_type=#attributes.list_type#</cfoutput>&p_order_id_list='+p_order_id_list,'small');
			else if(type == -5)
				<cfif Listlen(attributes.master_plan_id) gt 1>
					windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_dsp_ezgi_iflow_product_metarial_need&master_plan_id_list=#attributes.master_plan_id#</cfoutput>&p_order_id_list='+p_order_id_list,'longpage');
				<cfelse>
					windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_dsp_ezgi_iflow_product_metarial_need&master_plan_id=#attributes.master_plan_id#</cfoutput>&p_order_id_list='+p_order_id_list,'longpage');
				</cfif>
			else if(type == -6)
				windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_dsp_ezgi_iflow_product_operation_revision</cfoutput>&p_order_id_list='+p_order_id_list,'wide');
		}
	}
	function change_iflow_master_plan_id()
	{
		document.getElementById('iflow_p_order_id_list').value='';	
	}
</script>