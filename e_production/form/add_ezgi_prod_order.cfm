<!---
    File: add_ezgi_prod_order.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---Ezgi Bilgisayar Özelleştirme ZAG - 01/12/2017--->
<!---Ezgi Bilgisayar Özelleştirme Başlangıç--->
<cfinclude template="../../../../v16/objects/functions/auto_complete_functions.js">
<!---Ezgi Bilgisayar Özelleştirme Başlangıç--->
<cf_xml_page_edit fuseact="prod.add_prod_order">
<cfparam name="paper_project_id" default="">
<cfparam name="attributes.station_id" default="">
<cfparam name="attributes.station_name" default="">
<cfparam name="attributes.start_hour" default="#timeformat(dateadd('h',session.ep.time_zone, now()),'HH')#">
<cfparam name="attributes.finish_hour" default="#timeformat(dateadd('h',session.ep.time_zone, now()),'HH')#">
<cfparam name="attributes.start_mnt" default="#timeformat(dateadd('h',session.ep.time_zone, now()),'MM')#">
<cfparam name="attributes.finish_mnt" default="#timeformat(dateadd('h',session.ep.time_zone, now()),'MM')#">
<!---Ezgi Bilgisayar Özelleştirme Başlangıç--->
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.islem_id" default="">
<cfparam name="attributes.master_alt_plan_id" default="">
<cfif len(attributes.master_alt_plan_id)>
	<cfquery name="get_emir_seviye" datasource="#dsn3#">
    	SELECT P.EMIR_SEVIYE FROM EZGI_MASTER_ALT_PLAN AS E INNER JOIN EZGI_MASTER_PLAN_SABLON AS P ON E.PROCESS_ID = P.PROCESS_ID WHERE E.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
    </cfquery>	
</cfif>
<cfparam name="attributes.stage_info" default="#get_emir_seviye.EMIR_SEVIYE#"><!---Sablonda Belirtilen Seviye Kadar Seviye Üretim Emri Çalışıyor--->
<!---Ezgi Bilgisayar Özelleştirme Bitiş--->
<script type="text/javascript">
  temp_var = 0;
</script>
<cfquery name="GET_MONEY" datasource="#dsn#">
	SELECT	PERIOD_ID,MONEY,RATE1,RATE2 FROM SETUP_MONEY WHERE PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.period_id#"> AND MONEY_STATUS = 1
</cfquery>
<cfset money_str ='&search_process_date=#DateFormat(now(),"DD/MM/YYYY")#&company_id=1'>
<cfoutput query="GET_MONEY">
<cfset money_str = '#money_str#&#MONEY#=#RATE2#'>
</cfoutput>
<cfif isdefined("attributes.upd")><!---Üretim Emri Kopyalama --->
    <cfquery name="GET_DET_PO" datasource="#DSN3#">
        SELECT
            P.IS_PRODUCTION,
            P.IS_PROTOTYPE,
            PO.P_ORDER_ID,
            PO.STOCK_ID,
            PO.STATION_ID,
            PO.DEMAND_NO,
            PO.PO_RELATED_ID,
            PO.ORDER_ID,
            PO.QUANTITY,
            PO.P_ORDER_NO,
            PO.START_DATE,
            PO.FINISH_DATE,
            PO.STATUS,
            PO.IS_STOCK_RESERVED,
            PO.IS_DEMONTAJ,
            PO.PROD_ORDER_STAGE,
            PO.LOT_NO,
            PO.PROJECT_ID,
            PO.REFERENCE_NO,
            PO.SPEC_MAIN_ID,
            PO.SPECT_VAR_ID,
            PO.SPECT_VAR_NAME,
            PO.DETAIL,
            PO.DP_ORDER_ID,
            PO.RECORD_EMP,
            PO.RECORD_DATE,
            PO.UPDATE_EMP,
            PO.UPDATE_DATE,
            PO.PRINT_COUNT,
            PO.IS_STAGE,
            PO.WRK_ROW_RELATION_ID,
            S.PROPERTY,
            P.PRODUCT_NAME,
            P.PRODUCT_ID,
            S.STOCK_ID,
            S.STOCK_CODE,
            S.PRODUCT_UNIT_ID,
            ISNULL(PO.RESULT_AMOUNT,0) ROW_RESULT_AMOUNT,
            ISNULL((SELECT
                SUM(POR_.AMOUNT) ORDER_AMOUNT
            FROM
                PRODUCTION_ORDER_RESULTS_ROW POR_,
                PRODUCTION_ORDER_RESULTS POO
            WHERE
                POR_.PR_ORDER_ID = POO.PR_ORDER_ID
                AND POO.P_ORDER_ID = PO.P_ORDER_ID
                AND POR_.TYPE = 1
                AND POR_.SPEC_MAIN_ID IN (SELECT PRODUCTION_ORDERS.SPEC_MAIN_ID FROM PRODUCTION_ORDERS WHERE PRODUCTION_ORDERS.P_ORDER_ID = POO.P_ORDER_ID)
            ),0) RESULT_AMOUNT
        FROM
            PRODUCTION_ORDERS PO,
            STOCKS S,
            PRODUCT P
        WHERE
            PO.P_ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.upd#"> AND
            PO.STOCK_ID = S.STOCK_ID AND
            S.PRODUCT_ID = P.PRODUCT_ID
    </cfquery>
    <cfif GET_DET_PO.recordcount>    
    	<cfset attributes.IS_PRODUCTION = GET_DET_PO.IS_PRODUCTION>
        <cfset attributes.IS_PROTOTYPE = GET_DET_PO.IS_PROTOTYPE>
        <cfset attributes.STOCK_ID = GET_DET_PO.STOCK_ID>
        <cfset attributes.STATION_ID = GET_DET_PO.STATION_ID>
        <cfset attributes.DEMAND_NO = GET_DET_PO.DEMAND_NO>
        <cfset attributes.PO_RELATED_ID = GET_DET_PO.PO_RELATED_ID>
        <cfset attributes.ORDER_ID = GET_DET_PO.ORDER_ID>
        <cfset attributes.QUANTITY = GET_DET_PO.QUANTITY>
        <cfset attributes.P_ORDER_NO = GET_DET_PO.P_ORDER_NO>
        <cfset attributes.START_DATE = GET_DET_PO.START_DATE>
		<cfset attributes.FINISH_DATE = GET_DET_PO.FINISH_DATE>
		<cfset attributes.STATUS = GET_DET_PO.STATUS>
        <cfset attributes.IS_STOCK_RESERVED = GET_DET_PO.IS_STOCK_RESERVED>
        <cfset attributes.IS_DEMONTAJ = GET_DET_PO.IS_DEMONTAJ>
        <cfset attributes.PROD_ORDER_STAGE = GET_DET_PO.PROD_ORDER_STAGE>
        <cfset attributes.LOT_NO = GET_DET_PO.LOT_NO>
        <cfset attributes.PROJECT_ID = GET_DET_PO.PROJECT_ID>
        <cfset attributes.REFERENCE_NO = GET_DET_PO.REFERENCE_NO>
        <cfset attributes.SPECT_MAIN_ID = GET_DET_PO.SPEC_MAIN_ID>
        <cfset attributes.SPECT_VAR_ID = GET_DET_PO.SPECT_VAR_ID>
        <cfset attributes.SPECT_VAR_NAME = GET_DET_PO.SPECT_VAR_NAME>
        <cfset attributes.DETAIL = GET_DET_PO.DETAIL>
        <cfset attributes.DP_ORDER_ID = GET_DET_PO.DP_ORDER_ID>
        <cfset attributes.PRINT_COUNT = GET_DET_PO.PRINT_COUNT>
        <cfset attributes.IS_STAGE = GET_DET_PO.IS_STAGE>
		<cfset attributes.PROPERTY = GET_DET_PO.PROPERTY>
        <cfset attributes.PRODUCT_NAME = GET_DET_PO.PRODUCT_NAME>
        <cfset attributes.PRODUCT_ID = GET_DET_PO.PRODUCT_ID>
        <cfset attributes.STOCK_ID = GET_DET_PO.STOCK_ID>
        <cfset attributes.STOCK_CODE = GET_DET_PO.STOCK_CODE>
        <cfset attributes.ROW_RESULT_AMOUNT = GET_DET_PO.ROW_RESULT_AMOUNT>
        <cfset attributes.RESULT_AMOUNT = GET_DET_PO.RESULT_AMOUNT>
        <cfset attributes.PRODUCT_UNIT_ID = GET_DET_PO.PRODUCT_UNIT_ID>
        <cfset attributes.WRK_ROW_RELATION_ID = GET_DET_PO.WRK_ROW_RELATION_ID>
        <cfquery name="GET_ORDER_ROW" datasource="#DSN3#">
            SELECT DISTINCT
                ORDERS.ORDER_ID,
                ORDERS.ORDER_NUMBER
            FROM
                ORDERS,
                PRODUCTION_ORDERS_ROW
            WHERE
                PRODUCTION_ORDERS_ROW.PRODUCTION_ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.upd#"> AND
                PRODUCTION_ORDERS_ROW.ORDER_ID = ORDERS.ORDER_ID
        </cfquery>
        <cfif GET_ORDER_ROW.RECORDCOUNT>
            <cfset attributes.order_id = GET_ORDER_ROW.ORDER_ID>
            <cfset attributes.ORDER_NUMBER = GET_ORDER_ROW.ORDER_number>
            <cfquery name="GET_ORDER_ROW_1" datasource="#DSN3#">
                SELECT
                    ORDER_ROW.ORDER_ROW_ID,
                    ORDER_ROW.SPECT_VAR_ID,
                    ORDER_ROW.SPECT_VAR_NAME
                FROM
                    ORDER_ROW
                WHERE
                    ORDER_ROW.ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_ORDER_ROW.ORDER_ID#"> AND
                    ORDER_ROW.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.STOCK_ID#"> 
            </cfquery>
            <cfset attributes.order_row_id_ = GET_ORDER_ROW_1.ORDER_ROW_ID>
        </cfif>
        <cfif len(attributes.PRODUCT_UNIT_ID)>
        	<cfquery name="GET_UNIT" datasource="#DSN3#">
            	SELECT  
                    S.UNIT
				FROM 
                    PRODUCT_UNIT P,
                    #DSN_ALIAS#.SETUP_UNIT S
				WHERE 
                    P.UNIT_ID = S.UNIT_ID AND
                    P.PRODUCT_UNIT_ID = #attributes.PRODUCT_UNIT_ID#
            </cfquery>
            <cfset attributes.unit_name = get_unit.unit>
        </cfif>
        <cfif len(attributes.STATION_ID)>
            <cfquery name="get_station" datasource="#dsn3#">
                SELECT STATION_NAME FROM WORKSTATIONS WHERE STATION_ID = #attributes.STATION_ID#
            </cfquery>
            <cfset attributes.station_name = get_station.STATION_NAME>
        </cfif>
    </cfif>
</cfif>
<cf_papers paper_type="prod_order">
<cfif isdefined("attributes.order_row_id")>
    <cfquery name="GET_AMOUNT" datasource="#DSN3#">
        SELECT
            CASE WHEN (QUANTITY-ISNULL((SELECT SUM(QUANTITY) FROM PRODUCTION_ORDERS WHERE P_ORDER_ID IN(SELECT PRODUCTION_ORDER_ID FROM PRODUCTION_ORDERS_ROW WHERE PRODUCTION_ORDERS_ROW.ORDER_ROW_ID = ORDER_ROW.ORDER_ROW_ID)),0))< 0
            THEN QUANTITY 
            ELSE 
            (QUANTITY-ISNULL((SELECT SUM(QUANTITY) FROM PRODUCTION_ORDERS WHERE P_ORDER_ID IN(SELECT PRODUCTION_ORDER_ID FROM PRODUCTION_ORDERS_ROW WHERE PRODUCTION_ORDERS_ROW.ORDER_ROW_ID = ORDER_ROW.ORDER_ROW_ID)),0)) END
            QUANTITY,
            ORDERS.PROJECT_ID,
            ORDERS.ORDER_NUMBER,
            ORDERS.ORDER_DETAIL,
            ORDER_ROW.SPECT_VAR_ID,
            ORDERS.DELIVERDATE AS DELIVER_DATE,
            ORDER_ROW.STOCK_ID,
            STOCKS.PRODUCT_NAME,
            STOCKS.IS_PROTOTYPE
        FROM
            ORDER_ROW,
            ORDERS,
            STOCKS
        WHERE 
            ORDER_ROW.ORDER_ROW_ID IN(#attributes.order_row_id#) AND
            ORDER_ROW.ORDER_ID = ORDERS.ORDER_ID AND
            STOCKS.STOCK_ID = ORDER_ROW.STOCK_ID
    </cfquery>
    <cfif GET_AMOUNT.recordcount>
        <cfquery name="get_min_order_date" dbtype="query"><!--- Birden fazla sipariş geliyorsa teslim tarihi bu siparişlerin en erkenine alınıyor. --->
            SELECT MIN(DELIVER_DATE) AS DELIVER_DATE FROM GET_AMOUNT WHERE  DELIVER_DATE > #NOW()#
        </cfquery>
        <cfset all_quantity= 0>
	    <cfloop query="GET_AMOUNT"><cfset all_quantity = all_quantity + quantity></cfloop>
  	    <cfset attributes.start_date =date_add('h',session.ep.time_zone,now())>
		<cfif get_min_order_date.recordcount>
			<cfset GET_AMOUNT.deliver_date = get_min_order_date.DELIVER_DATE>
        <cfelse>
        	<cfset GET_AMOUNT.deliver_date = date_add('d',1,now())>
        </cfif>
        <cfset GET_AMOUNT.quantity = all_quantity>
        <cfset GET_AMOUNT.order_number = ValueList(GET_AMOUNT.ORDER_NUMBER,',')>
        <cfquery name="get_product_station" datasource="#dsn3#">
            SELECT
                (SELECT STATION_NAME FROM WORKSTATIONS WHERE STATION_ID =WSP.WS_ID) AS STATION_NAME,
                WS_ID
            FROM 
                WORKSTATIONS_PRODUCTS WSP
            WHERE 
                STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_AMOUNT.STOCK_ID#">
        </cfquery>
        <cfif get_product_station.recordcount>
			<cfset attributes.station_id= get_product_station.WS_ID>
			<cfset attributes.station_name= get_product_station.STATION_NAME>
		</cfif>
    </cfif>
</cfif>
<!---Ezgi Bilgisayar Özelleştirme Başlangıç--->
<cfif isdefined('attributes.master_alt_plan_id')>
	<cfquery name="get_master_alt_plan" datasource="#dsn3#">
    	SELECT     
        	EMAP.PLAN_START_DATE, 
            EMAP.PLAN_FINISH_DATE, 
            EMP.MASTER_PLAN_PROJECT_ID
		FROM         
        	EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
          	EZGI_MASTER_PLAN AS EMP ON EMAP.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID
		WHERE     
        	EMAP.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
    </cfquery>
    <cfif get_master_alt_plan.recordcount>
    	<cfoutput query="get_master_alt_plan">
			<cfset attributes.START_DATE = get_master_alt_plan.PLAN_START_DATE>
            <cfset attributes.FINISH_DATE = get_master_alt_plan.PLAN_FINISH_DATE>
            <cfset attributes.PROJECT_ID = get_master_alt_plan.MASTER_PLAN_PROJECT_ID>
    	</cfoutput>
    </cfif>
</cfif>
<!---Ezgi Bilgisayar Özelleştirme Bitiş--->
<cfoutput>
	<cfif isdefined("attributes.is_collacted")><!---toplu eklemeyse toplu ekleme sayfasını açıyor --->
            <!---Ezgi Bilgisayar Özelleştirme Başlangıç--->
            <cfinclude template="add_ezgi_prod_order_demand.cfm">
            <!---Ezgi Bilgisayar Özelleştirme Bitiş--->
    <cfelse>
   		<cfif isdefined('attributes.po_related_id')><input type="hidden" name="po_related_id" id="po_related_id" value="#attributes.po_related_id#"></cfif>
        <cfif isdefined('attributes.WRK_ROW_RELATION_ID')><input type="hidden" name="wrk_row_relation_id" id="wrk_row_relation_id" value="#attributes.WRK_ROW_RELATION_ID#"></cfif>
        <cfif isdefined('attributes.DEMAND_NO')><input type="hidden" name="copy_demand_no" id="copy_demand_no" value="#attributes.DEMAND_NO#"></cfif>
        <cf_catalystHeader>      
        <cf_basket_form id="prod_order">
        	<cfform name="submit_form" action="#request.self#?fuseaction=prod.add_prod_order" method="post">
           	<cf_object_main_table>
            <div class="row">
        	<div class="col col-12 uniqueRow">
            	<div class="row formContent">
                	<div class="row" type="row">
                    	<div class="col col-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                        	<div class="form-group" id="item-order_id">
                            	<label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57611.Sipariş'></label>
                                <div class="col col-9 col-xs-12">
                                	<div class="input-group">
                                    	<cfif isdefined('attributes.is_demand') and attributes.is_demand eq 1>
											<cfset is_demand = 'is_demand=1'>
			                            <cfelse>
											<cfset is_demand = 'is_demand=0'>
			                            </cfif>
										<cfif isdefined("attributes.order_row_id")>
			                                <input type="hidden" name="order_id" id="order_id"  value="#attributes.order_id#">
			                                <input type="hidden" name="order_row_id" id="order_row_id" value="#attributes.order_row_id#">
			                                <input type="text" name="order_id_" id="order_id_" value="#get_amount.order_number#" readonly style="width:200px;">
                                            <!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
                                            <input type="hidden" name="master_alt_plan_id" id="master_alt_plan_id"  value="#attributes.master_alt_plan_id#">
                                            <input type="hidden" name="islem_id" id="islem_id"  value="#attributes.islem_id#">	
                                            <!---Ezgi Bilgisayar Özelleştirme Bitiş--->
                                            <span class="input-group-addon icon-ellipsis btnPointer" title="<cf_get_lang dictionary_id ='58586.İşlem Yapan'>" onClick="windowopen('#request.self#?fuseaction=prod.popuptracking&#is_demand#','longpage')"></span>
	                                	 <cfelseif isdefined("attributes.order_row_id_")>
			                                <input type="hidden" name="order_id" id="order_id"  value="#attributes.order_id#">
			                                <input type="hidden" name="order_row_id" id="order_row_id" value="#attributes.order_row_id_#">
			                                <input type="text" name="order_id_" id="order_id_" value="#attributes.order_number#" readonly style="width:200px;">
                                            <!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
                                            <input type="hidden" name="master_alt_plan_id" id="master_alt_plan_id"  value="#attributes.master_alt_plan_id#">
                                            <input type="hidden" name="islem_id" id="islem_id"  value="#attributes.islem_id#">	
                                            <!---Ezgi Bilgisayar Özelleştirme Bitiş--->
                                            <span class="input-group-addon icon-ellipsis btnPointer" title="<cf_get_lang dictionary_id ='58586.İşlem Yapan'>" onClick="windowopen('#request.self#?fuseaction=prod.popuptracking&#is_demand#','longpage')"></span>
                                    	<cfelse>
			                                <input type="hidden" name="order_id" id="order_id" value="">
			                                <input type="hidden"name="order_row_id" id="order_row_id" value="">
			                                <input type="text" name="order_id_" id="order_id_" value="" readonly style="width:200px;">
                                            <!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
                                            <input type="hidden" name="master_alt_plan_id" id="master_alt_plan_id"  value="#attributes.master_alt_plan_id#">
                                            <input type="hidden" name="islem_id" id="islem_id"  value="#attributes.islem_id#">	
                                            <!---Ezgi Bilgisayar Özelleştirme Bitiş--->
                                            <span class="input-group-addon icon-ellipsis btnPointer" title="<cf_get_lang dictionary_id ='58586.İşlem Yapan'>" onClick="windowopen('#request.self#?fuseaction=prod.popuptracking&#is_demand#','longpage')"></span>
			                            </cfif>
                                    </div>
                            	</div>
                            </div>
                            <div class="form-group" id="item-product_name">
                            	<label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57657.Ürün'> *</label>
                                <div class="col col-9 col-xs-12">
                                	<div class="input-group">A
                                    	<cfif isdefined("attributes.stock_id")>
			                                <input type="hidden" name="stock_id"  id="stock_id" value="#attributes.stock_id#">
			                                <input name="product_name" type="text" id="product_name" style="width:200px;" onfocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME,STOCK_CODE','get_product','0','STOCK_ID','stock_id','','2','200','get_product_main_spec()');" value="#attributes.product_name#" autocomplete="off">
			                            <cfelse> 
			                                <cfif isdefined("attributes.order_row_id")>
			                                    <input type="hidden" name="stock_id" id="stock_id" value="#get_amount.stock_id#">
			                                    <input type="text" name="product_name" id="product_name" value="#get_amount.product_name#" style="width:200px;">
			                                <cfelse>
			                                    <input type="hidden" name="stock_id"  id="stock_id" value="">
			                                    <input type="text" name="product_name" id="product_name"  style="width:200px;" onfocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME,STOCK_CODE,','get_product','0','STOCK_ID,MAIN_UNIT','stock_id,unit','','2','200','get_product_main_spec()');" value="" autocomplete="off">
			                                </cfif>
			                            </cfif>
	                                    <!---<span class="input-group-addon icon-ellipsis btnPointer" onClick="windowopen('#request.self#?fuseaction=prod.popup_add_product&call_function=get_product_main_spec&call_function_parameter=1&field_unit_name=add_production_order.unit&spec_field_id=add_production_order.spect_main_id&field_name=add_production_order.product_name&field_id=add_production_order.stock_id&is_production=1','list')"></span>--->
                                        <span class="input-group-addon icon-ellipsis btnPointer" onClick="openBoxDraggable('#request.self#?fuseaction=prod.popup_add_product&call_function=get_product_main_spec&call_function_parameter=1&field_unit_name=add_production_order.unit&spec_field_id=add_production_order.spect_main_id&field_name=add_production_order.product_name&field_id=add_production_order.stock_id&is_production=1')"></span>
	                                </div>
                            	</div>
                            </div>
                        	<div class="form-group" id="item-spect_var_name">
                            	<label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='34299.Spec'></label>
                                <div class="col col-9 col-xs-12">
                                	<div class="input-group">
                                    	<cfif isdefined("get_amount.spect_var_id") and len(get_amount.spect_var_id)><!--- Siparişten geliyorsa buraya girecek --->
		                                <cfquery name="GET_SPECT" datasource="#DSN3#">
		                                    SELECT
		                                        SPECT_VAR_ID,SPECT_MAIN_ID,SPECT_VAR_NAME
		                                    FROM
		                                        SPECTS
		                                    WHERE
		                                        SPECT_VAR_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_amount.spect_var_id#">
		                                </cfquery>
		                                <input type="text" name="spect_main_id" id="spect_main_id" value="#get_spect.spect_main_id#" readonly style="width:43px;">
                                        <span class="input-group-addon no-bg"></span>
		                                <input type="text" name="spect_var_id" id="spect_var_id" value="#get_amount.spect_var_id#" readonly style="width:40px;">
                                        <span class="input-group-addon no-bg"></span>
		                                <input type="text" name="spect_var_name" id="spect_var_name" value="#get_spect.spect_var_name#" readonly style="width:110px;">
                                    	<cfelseif isdefined('attributes.spect_main_id') and len(attributes.spect_main_id)><!--- Buraya giriyorsa bu bir üretimin alt üretimidir --->
										<cfscript>
											create_spect_new=specer(
												dsn_type:dsn3,
												spec_type:1,
												main_spec_id=attributes.spect_main_id,
												add_to_main_spec=1
											);
											new_spect_id=ListGetAt(create_spect_new,2,',');
											new_spect_name=ListGetAt(create_spect_new,3,',');
		                                </cfscript>
		                                <input type="text" name="spect_main_id" id="spect_main_id" value="#attributes.spect_main_id#"  readonly style="width:43px;">
                                        <span class="input-group-addon no-bg"></span>
		                                <input type="text" name="spect_var_id" id="spect_var_id" value="#new_spect_id#" readonly style="width:40px;">
                                        <span class="input-group-addon no-bg"></span>
		                                <input type="text" name="spect_var_name" id="spect_var_name" value="#new_spect_name#" readonly style="width:110px;">
                                    	 <cfelse>	
			                                <input type="text" name="spect_main_id" id="spect_main_id" value=""  readonly style="width:43px;">
                                            <span class="input-group-addon no-bg"></span>
			                                <input type="text" name="spect_var_id" id="spect_var_id" value="" readonly style="width:40px;">
                                            <span class="input-group-addon no-bg"></span>
			                                <input type="text" name="spect_var_name" id="spect_var_name" value="" readonly style="width:110px;">
			                            </cfif>
                                        <cfif not isdefined('GET_AMOUNT') or (isdefined('GET_AMOUNT') and GET_AMOUNT.IS_PROTOTYPE eq 1)>
	                                    <span class="input-group-addon icon-ellipsis btnPointer" onClick="open_spec();"></span>
	                                	</cfif>
                                       </div>
                                    </div>
                            	</div>
                            <div class="form-group" id="item-quantity">
                            	<label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57635.Miktar'></label>
                                <div class="col col-9 col-xs-12">
                                	<div class="input-group">
                                    	<cfif isdefined("get_amount.quantity")>
											<cfif isdefined('attributes.production_amount')><cfset get_amount.quantity =attributes.production_amount></cfif>
			                                <input type="text" name="quantity" id="quantity" required="yes" value="#get_amount.quantity#" validate="integer" maxlength="100" onkeyup="return(FormatCurrency(this,event,8));" style="width:105px;">
			                            <cfelseif isdefined("attributes.quantity") and len(attributes.quantity)>
			                                <input type="text" name="quantity" id="quantity" required="yes" value="#tlformat(attributes.quantity,8)#" validate="integer" maxlength="100" onkeyup="return(FormatCurrency(this,event,8));" style="width:105px;">
			                            <cfelse>	
			                                <input type="text" name="quantity" id="quantity" required="yes" value="" validate="integer"  maxlength="100" onkeyup="return(FormatCurrency(this,event,8));" style="width:105px;">
			                            </cfif>
                                        <span class="input-group-addon no-bg"></span>
			                            <input type="text" style="width:92px;" readonly name="unit" id="unit" value="<cfif isdefined('attributes.unit_name') and len(attributes.unit_name)>#attributes.unit_name#</cfif>">
	                                </div>
                            	</div>
                            </div>
                        </div>
                        <div class="col col-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                        	<div class="form-group" id="item-start_date">
	                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57655.Başlama Tarihi'></label>
	                            <div class="col col-4 col-xs-12">
	                                <div class="input-group">
                                    	<cfif is_time_calculation eq 0 and not (isdefined('attributes.is_demand') and attributes.is_demand eq 1)>
	                                    <input required="Yes"  type="text" name="start_date" id="start_date"  validate="eurodate" style="width:65px;" value=""> 
			                            <cfelse>
											<cfif isdefined('attributes.start_date') and isdate(attributes.start_date)>
			                                    <input required="Yes" type="text" name="start_date" id="start_date"  validate="eurodate" style="width:65px;" value="#dateformat(attributes.start_date,dateformat_style)#"> 
			                                <cfelse>
			                                    <input required="Yes" type="text" name="start_date" id="start_date"  validate="eurodate" style="width:65px;" value="#dateformat(now(),dateformat_style)#">
			                                </cfif>
			                            </cfif>
	                                    <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
	                                </div>
	                            </div>
                                <div class="col col-5 col-xs-12">
                                	<div class="input-group">
                                        <select name="start_h" id="start_h">
			                                <cfloop from="0" to="23" index="i">
											<cfif is_time_calculation eq 0 and not (isdefined('attributes.is_demand') and attributes.is_demand eq 1)>
			                                    <option value="#i#"><cfif i lt 10>0</cfif>#i#</option>
			                                <cfelse>
			                                    <option value="#i#" <cfif isdefined('attributes.start_date') and timeformat(attributes.start_date,'HH') eq i> selected<cfelseif attributes.start_hour eq i>selected</cfif>><cfif i lt 10>0</cfif>#i#</option>
			                                </cfif>
			                                </cfloop>
			                            </select>
                                        <span class="input-group-addon no-bg"></span>
                                        <select name="start_m" id="start_m">
			                                <cfloop from="0" to="59" index="i">
											<cfif is_time_calculation eq 0 and not (isdefined('attributes.is_demand') and attributes.is_demand eq 1)>
			                                    <option value="#i#"><cfif i lt 10>0</cfif>#i#</option>
			                                <cfelse>                                    
			                                	<option value="#i#" <cfif isdefined('attributes.start_date') and timeformat(attributes.start_date,'MM') eq i> selected<cfelseif attributes.start_mnt eq i>selected</cfif>><cfif i lt 10>0</cfif>#i#</option>
			                                </cfif>
			                                </cfloop>
			                            </select>
                                             
                                    </div>
                                </div>
	                        </div>
                            <div class="form-group" id="item-finish_date">
	                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></label>
	                            <div class="col col-4 col-xs-12">
	                                <div class="input-group">
                                    	<cfif is_time_calculation eq 0 and not (isdefined('attributes.is_demand') and attributes.is_demand eq 1)>
				                            <input required="Yes"  type="text" name="finish_date" id="finish_date" value="" validate="eurodate" style="width:65px;"> 
				                        <cfelse>
											<cfif isdefined('attributes.finish_date')  and isdate(attributes.finish_date)>
				                                <input required="Yes"  type="text" name="finish_date" id="finish_date" value="#dateformat(attributes.finish_date,dateformat_style)#" validate="eurodate" style="width:65px;"> 
				                            <cfelseif isdefined("get_amount.deliver_date")>
				                                <input required="Yes"  type="text" name="finish_date" id="finish_date" value="#dateformat(get_amount.deliver_date,dateformat_style)#" validate="eurodate" style="width:65px;">
				                            <cfelse>
				                                <input required="Yes"  type="text" name="finish_date" id="finish_date" value="#dateformat(now(),dateformat_style)#" validate="eurodate" style="width:65px;">
				                            </cfif>
				                         </cfif>
	                                    <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                                        </div>
                                </div>
                                <div class="col col-5 col-xs-12">
                                	<div class="input-group">
                                        <select name="finish_h" id="finish_h">
			                                <cfloop from="0" to="23" index="i">
											<cfif is_time_calculation eq 0 and not (isdefined('attributes.is_demand') and attributes.is_demand eq 1)>
			                                    <option value="#i#"><cfif i lt 10>0</cfif>#i#</option>
			                                <cfelse>                                    
			                                	<option value="#i#" <cfif isdefined('attributes.finish_date') and timeformat(attributes.finish_date,'HH') eq i> selected<cfelseif attributes.start_hour eq i>selected</cfif>><cfif i lt 10>0</cfif>#i#</option>
			                                </cfif>
			                                </cfloop>
			                            </select>
                                        <span class="input-group-addon no-bg"></span>
                                        <select name="finish_m" id="finish_m">
			                                <cfloop from="0" to="59" index="i">
			                                <cfif is_time_calculation eq 0 and not (isdefined('attributes.is_demand') and attributes.is_demand eq 1)>
			                                    <option value="#i#"><cfif i lt 10>0</cfif>#i#</option>
			                                <cfelse>
			                                    <option value="#i#"<cfif isdefined('attributes.finish_date') and timeformat(attributes.finish_date,'MM') eq i> selected<cfelseif attributes.finish_mnt eq i>selected</cfif>><cfif i lt 10>0</cfif>#i#</option>
			                                </cfif>
			                                </cfloop>
			                            </select>
                                        <span class="input-group-addon catalyst-calculator bold btnPointer" onclick="calc_deliver_date();" title="<cf_get_lang dictionary_id='36495.Tarih Hesapla'>"></span>
                                        </div>
                                    <div style="position:absolute;z-index:9999999" id="deliver_date_info"></div>
	                        	</div>
                            </div>
                            <div class="form-group" id="item-station_name">
                            	<label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='58834.İstasyon'></label>
                                <div class="col col-9 col-xs-12">
                                	<div class="input-group">
                                    	<input type="hidden" name="station_id_1_0" id="station_id_1_0" value="#attributes.station_id#">
			                            <input type="hidden" name="function_value_station" id="function_value_station" value="">
			                            <input type="text" name="station_name" id="station_name"  value="#attributes.station_name#"  style="width:170px;" onkeyup="station_stock_control(1);">
                                        <span class="input-group-addon icon-ellipsis btnPointer" title="<cf_get_lang dictionary_id ='58586.İşlem Yapan'>" onClick="station_stock_control(2);"></span>
                                    </div>
                            	</div>
                            </div>
                            <div class="form-group" id="item-reference_no">
                            	<label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='58784.Referans'></label>
                                <div class="col col-9 col-xs-12">
                                    <input type="text" name="reference_no" id="reference_no" value="<cfif isdefined("attributes.reference_no") and len(attributes.reference_no)>#attributes.reference_no#</cfif>" style="width:170px;">
                            	</div>
                            </div>
                        </div>
                        <div class="col col-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                        	<div class="form-group" id="item-project_head">
	                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'></label>
	                            <div class="col col-9 col-xs-12">
	                                <div class="input-group">
	                                	<cfif isdefined("get_amount.project_id") and len(get_amount.project_id)>
			                                <cfset paper_project_id = get_amount.project_id>
			                            <cfelseif isdefined("attributes.project_id") and len(attributes.project_id)>
			                                <cfset paper_project_id = attributes.project_id>
			                            <cfelseif isdefined("attributes.pj_id") and len(attributes.pj_id)>
			                                <cfset paper_project_id = attributes.pj_id>
			                            </cfif>

			                            <input type="hidden" name="project_id" id="project_id" value="#paper_project_id#">
			                            <input type="text" name="project_head" id="project_head" value="<cfif len(paper_project_id)>#GET_PROJECT_NAME(paper_project_id)#</cfif>" style="width:200px;"onfocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','','3','135')"autocomplete="off">
	                                    <span class="input-group-addon icon-ellipsis btnPointer" title="" onClick="windowopen('#request.self#?fuseaction=objects.popup_list_projects&project_id=add_production_order.project_id&project_head=add_production_order.project_head','list');"></span>
	                                </div>
	                            </div>
                        	</div>
                            <div class="form-group" id="item-work_head">
	                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='58445.İş'></label>
	                            <div class="col col-9 col-xs-12">
	                                <div class="input-group">
	                                	<cfif isdefined("attributes.work_id") and len(attributes.work_id)>
			                                <cfquery name="get_work" datasource="#dsn#">
			                                    SELECT 
			                                       WORK_ID,
			                                       WORK_HEAD,
			                                       PROJECT_ID
			                                    FROM 
			                                        PRO_WORKS 
			                                    WHERE 
			                                        WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.work_id#">
			                                </cfquery>
											<cfset attributes.project_id = get_work.project_id>
			                                <cfset attributes.work_head = get_work.work_head>
			                            <cfelse>
			                            	<cfset attributes.work_head = ''>
			                            </cfif>
			                            <input type="hidden" name="work_id" id="work_id" value="<cfif isdefined("attributes.work_id") and len(attributes.work_id)>#attributes.work_id#</cfif>">
			                            <input type="text" name="work_head" id="work_head" style="width:200px;" value="#attributes.work_head#" onfocus="AutoComplete_Create('work_head','WORK_HEAD','WORK_HEAD','get_work','','WORK_ID','work_id','','3','110')">
	                                    <span class="input-group-addon icon-ellipsis btnPointer" title="" onClick="pencere_ac_work();"></span>
	                                </div>
	                            </div>
                        	</div>
                            <div class="form-group" id="item-detail">
                            	<label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                                <div class="col col-9 col-xs-12">
                                	<textarea name="detail" id="detail" style="width:200px;height:50px;"><cfif isdefined("attributes.order_row_id")>#get_amount.order_detail#<cfelseif isdefined("attributes.detail") and len(attributes.detail)>#attributes.detail#</cfif></textarea>
                            	</div>
                            </div>
                        </div>
                    </div>
                    <div class="row formContentFooter ">
	                    <div class="col col-12 text-right ">
	                        <input type="button" value="<cfif isdefined('attributes.is_demand') and attributes.is_demand eq 1><cf_get_lang dictionary_id ='58877.Talep Detayları'><cfelse><cf_get_lang dictionary_id ='36829.Üretim Detayları'></cfif>" onclick="show_product_tree_info();">
	                    </div>
                	</div>
                </div>
            </div>
        </div>
            </cf_object_main_table>
            </cfform>
        </cf_basket_form>
        <div id="prod_order_bask">
        	<div class="row" id="PRODUCT_TREE"></div>	            
        </div>
    </cfif>
</cfoutput>
<cfoutput>
<script type="text/javascript">
	<cfif isdefined("attributes.order_row_id")> <!--- Siparişten geliyorsa bilgilerin doğru olduğu düşünelerek spect ağacını çalıştıralım. --->
		$(document).ready(function(){		
			show_product_tree_info();
		});
	</cfif>
	function show_product_tree_info()
	{
		_kontol_ = date_control();
		if(_kontol_ == true)
		_kontol_ = kontrol_form();
		if(_kontol_ == true)
		{
			var spect_var_id = list_getat(document.getElementById('spect_var_id').value,1,',');
			var spect_main_id = list_getat(document.getElementById('spect_main_id').value,1,',');
			if(document.getElementById('po_related_id')!= undefined)
				var po_related_id = document.getElementById('po_related_id').value;
			else
				var po_related_id = '';
			project_id_ = document.getElementById('project_id').value;
			var order_id = document.getElementById('order_id').value;
			var order_row_id = document.getElementById('order_row_id').value;
			var quantity = filterNum(document.getElementById('quantity').value,8);
			var stock_id = document.getElementById('stock_id').value;
			var start_m = document.getElementById('start_m').value;
			var start_h = document.getElementById('start_h').value;
			var finish_h = document.getElementById('finish_h').value;
			var finish_m = document.getElementById('finish_m').value;
			var start_date = document.getElementById('start_date').value;
			var deliver_date = document.getElementById('finish_date').value;
			var finish_date = document.getElementById('finish_date').value;
			if(document.getElementById('detail').value.indexOf("'") > -1)
				document.getElementById('detail').value = document.getElementById('detail').value.split("'").join(' ');
			var detail = document.getElementById('detail').value;
			var work_id = document.getElementById('work_id').value;
			var work_head = document.getElementById('work_head').value;
			if(document.getElementById('copy_demand_no')!= undefined)
				var demand_no = document.getElementById('copy_demand_no').value;
			else
				var demand_no = '';
			if(document.getElementById('wrk_row_relation_id')!= undefined)
				var wrk_row_relation_id = document.getElementById('wrk_row_relation_id').value;
			else
				var wrk_row_relation_id = '';
			var url_str = '&demand_no='+demand_no+'&wrk_row_relation_id='+wrk_row_relation_id+'&project_id='+project_id_+'&po_related_id='+po_related_id+'&spect_main_id='+spect_main_id+'&deliver_date='+deliver_date+'&start_date='+start_date+'&stock_id='+stock_id+'&order_row_id='+order_row_id+'&order_amount='+quantity+'&order_id='+order_id+'&spect_var_id='+spect_var_id+'';
				url_str +='&start_m='+start_m+'&start_h='+start_h+'&finish_h='+finish_h+'&finish_m='+finish_m+'&detail='+detail+'&finish_date='+finish_date+'&work_id='+work_id+'&work_head='+work_head+''; 
			AjaxPageLoad('#request.self#?fuseaction=prod.popup_ajax_display_product_tree<cfif isdefined('attributes.is_demand') and attributes.is_demand eq 1>&is_demand=1</cfif>&#xml_str#'+url_str+'','PRODUCT_TREE',1);
		}
	}
	function temizle_spect()
	{
		document.all.spect_main_id.value="";
		document.all.spect_var_id.value="";
		document.all.spect_var_name.value="";
	}
	function open_spec(row_info)
	{
		if(row_info == undefined)
		{
			if(document.getElementById('stock_id').value.length > 0 && document.getElementById('product_name').value.length > 0){
				if(document.getElementById('spect_var_id').value == "" && document.getElementById('spect_main_id').value == "")	
				windowopen('#request.self#?fuseaction=objects.popup_add_spect_list#money_str#&field_main_id=spect_main_id&field_name=spect_var_name&field_id=spect_var_id&stock_id='+document.getElementById('stock_id').value+'','project');
				else if(document.getElementById('spect_var_id').value == "")	
					windowopen('#request.self#?fuseaction=objects.popup_list_spect_main&is_from_prod_order=1&main_to_add_spect=1&basket_id=1&field_name=add_production_order.spect_var_name&field_main_id=add_production_order.spect_main_id&field_id=add_production_order.spect_var_id&create_main_spect_and_add_new_spect_id=1&stock_id='+document.getElementById('stock_id').value,'project');
				else if(document.getElementById('spect_var_id').value != "")	
					windowopen('#request.self#?fuseaction=objects.popup_upd_spect&create_main_spect_and_add_new_spect_id=1&field_name=spect_var_name&field_id=spect_var_id&field_main_id=spect_main_id&id='+document.getElementById('spect_var_id').value+'&stock_id='+document.getElementById('stock_id').value,'project');
			}	
			else
				alert("<cf_get_lang dictionary_id='58194.Zorunlu alan'> : <cf_get_lang dictionary_id ='57657.Ürün'>");
		}
		else
		{
			if(document.getElementById('stock_id'+row_info).value.length > 0 && document.getElementById('product_name'+row_info).value.length > 0){
				if(document.getElementById('spect_var_id'+row_info).value == "" && document.getElementById('spect_main_id'+row_info).value == "")	
				windowopen('#request.self#?fuseaction=objects.popup_add_spect_list#money_str#&field_main_id=spect_main_id'+row_info+'&field_name=spect_var_name'+row_info+'&field_id=spect_var_id'+row_info+'&stock_id='+document.getElementById('stock_id'+row_info).value+'','project');
				else if(document.getElementById('spect_var_id'+row_info).value == "")	
					windowopen('#request.self#?fuseaction=objects.popup_list_spect_main&main_to_add_spect=1&basket_id=1&field_name=add_production_order.spect_var_name'+row_info+'&field_main_id=add_production_order.spect_main_id'+row_info+'&field_id=add_production_order.spect_var_id'+row_info+'&create_main_spect_and_add_new_spect_id=1&stock_id='+document.getElementById('stock_id'+row_info).value,'project');
				else if(document.getElementById('spect_var_id'+row_info).value != "")	
					windowopen('#request.self#?fuseaction=objects.popup_upd_spect&create_main_spect_and_add_new_spect_id=1&field_name=spect_var_name'+row_info+'&field_id=spect_var_id'+row_info+'&field_main_id=spect_main_id'+row_info+'&id='+document.getElementById('spect_var_id'+row_info).value+'&stock_id='+document.getElementById('stock_id'+row_info).value,'project');
			}	
			else
				alert("<cf_get_lang dictionary_id='58194.Zorunlu alan'> : <cf_get_lang dictionary_id ='57657.Ürün'>");
		}
	}
	function kontrol_form()
	{ 
		if(document.getElementById('stock_id').value == "")
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu alan'> : <cf_get_lang dictionary_id ='57657.Ürün'>");
			return false;
		}
		if(document.getElementById('quantity').value == "")
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id ='57635.Miktar'>!");
			return false;
		}
		if((document.getElementById('station_id_1_0').value == ""))
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id ='58834.İstasyon'>");
			return false;
		}
		
		
		<cfif is_station_amount_kontrol eq 1>
			var listParam = document.getElementById('stock_id').value + "*" + document.getElementById('station_id_1_0').value ;					
			var get_station = wrk_safe_query("prdp_get_station_2",'dsn3',0,listParam);
		
			if(get_station.recordcount > 0 && get_station.MIN_PRODUCT_AMOUNT > 0)
			{				
				if(get_station.MIN_PRODUCT_AMOUNT <= parseFloat(filterNum(document.getElementById('quantity').value)))
				{					
					_production_type = get_station.PRODUCTION_TYPE;
					if(_production_type == 1 && (filterNum(document.getElementById('quantity').value)%get_station.MIN_PRODUCT_AMOUNT)!= 0)
					{//üretim tipi katları şeklinde girilmişse verilen üretim miktarı istasyonun üretim miktarının katları şeklinde olmlıdır.
						alert("<cf_get_lang dictionary_id ='36871.Bu İstasyonda Üretilecek Ürününün Miktarı'> "+ get_station.MIN_PRODUCT_AMOUNT +" <cf_get_lang dictionary_id ='36872.ve Katları Şeklinde Girilmelidir'> !");
						return false;
					}	
				}
				else if(get_station.MIN_PRODUCT_AMOUNT > parseFloat(filterNum(document.getElementById('quantity').value)))
				{				
					alert("<cf_get_lang dictionary_id ='1053.Miktar,İstasyonun Min Üretim Miktarından Küçük Olamaz'> !");
					return false;
				}
			}
		</cfif>
		return true;
	}
	function pencere_ac_work()
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_add_work&field_id=all.work_id&field_name=all.work_head','list');
	}
	
	function date_control()
	{<cfif is_time_calculation eq 0 and not (isdefined('attributes.is_demand') and attributes.is_demand eq 1)>
		if((document.getElementById('start_date').value != "") && (document.getElementById('finish_date').value != ""))
		return time_check(document.getElementById('start_date'), document.getElementById('start_h'), document.getElementById('start_m'), document.getElementById('finish_date'),  document.getElementById('finish_h'), document.getElementById('finish_m'), "<cf_get_lang dictionary_id ='1054.Üretim Başlama Tarihi,Bitiş Tarihinden Önce Olmalıdır'> !");
		else if((document.getElementById('start_date').value == ""))
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu alan'> : <cf_get_lang dictionary_id='58053.başlangıç tarihi'>");
		return false;
		}
		else if((document.getElementById('finish_date').value == ""))
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu alan'> : <cf_get_lang dictionary_id='57700.Bitiş tarihi'> ");
			return false;
		}
		</cfif>
		return true;
	}
	function station_stock_control(type)
	{
		<cfif isdefined('is_product_station_relation') and is_product_station_relation eq 1>
			if(document.getElementById('stock_id').value ==""){
				document.getElementById('station_id_1_0').value = "";
				document.getElementById('station_name').value = "";
				alert("<cf_get_lang dictionary_id ='36831.Önce Ürün Seçiniz'>!");
				return false;
			  }
			
			else{
				if(type==1){
				var my_deger ="get_auto_complete('get_station','station_name','STATION_NAME','station_id_1_0','STATION_ID','show_station','25','"+document.getElementById('stock_id').value+"',0,'','','function_value_station');"
				document.getElementById('function_value_station').value = my_deger;
				eval(my_deger);		
				}
				else if(type==2)
					windowopen('#request.self#?fuseaction=prod.popup_list_workstation&field_name=add_production_order.station_name&field_id=add_production_order.station_id_1_0&c=1&stock_id='+document.getElementById('stock_id').value+'','list');
				}
			
		<cfelse>
				if(type==1)
				{
				var my_deger ="get_auto_complete('get_station','station_name','STATION_NAME','station_id_1_0','STATION_ID','show_station','25','',0,'','','function_value_station');"
				document.getElementById('function_value_station').value = my_deger;
				eval(my_deger);		
				}
				else if(type==2)
					windowopen('#request.self#?fuseaction=prod.popup_list_workstation&field_name=add_production_order.station_name&field_id=add_production_order.station_id_1_0&c=1','list');
		</cfif>
	}
	function open_product_tree(){
		if(document.getElementById('stock_id').value != "" && document.getElementById('product_name').value != "")
			windowopen('#request.self#?fuseaction=prod.list_product_tree&event=add&stock_id='+document.getElementById('stock_id').value+'','list_horizantal');
		else
			alert('<cf_get_lang dictionary_id="36831.Önce Ürün Seçiniz">');
	}
	function get_product_main_spec(type){
		if(document.getElementById('stock_id').value != "" && document.getElementById('product_name').value != ""){
			//type'in undefined oplması demek autocompleteden geldiği anlamına geliyor,autocomplete sadece ürün adı ve id'sini düşürdüğü için burda tekrardan çekiyoruz.Ancak ürün popup'undan düşürdüğümüz zaman ise
			//spec_main_id de düştüğü için bu bloğa sokmuyoruz sadece istasyonunu seçili getiriyoruz.
			if(type == undefined){
				var get_main_spec_id = wrk_safe_query('prdp_get_main_spec_id','dsn3',0,document.getElementById('stock_id').value);
				if(get_main_spec_id.recordcount){
					document.getElementById('spect_main_id').value = get_main_spec_id.SPECT_MAIN_ID ;
					document.getElementById('spect_var_name').value = get_main_spec_id.SPECT_MAIN_NAME ;
				}
				else{
					document.getElementById('spect_main_id').value = "";
					document.getElementById('spect_var_name').value = "";
				}
			}
			
			var get_product_station = wrk_safe_query('prdp_get_product_station','dsn3',0,document.getElementById('stock_id').value);
			if(get_product_station.recordcount){
				document.getElementById('station_id_1_0').value = get_product_station.STATION_ID ;
				document.getElementById('station_name').value = get_product_station.STATION_NAME ;
			}
			else{
				document.getElementById('station_id_1_0').value = "" ;
				document.getElementById('station_name').value = "";
			}
		}	
		else
			alert('<cf_get_lang dictionary_id="36831.Önce Ürün Seçiniz">');
	}
	function calc_deliver_date()
	{
		stock_id_list = '';
		var row_c = document.getElementsByName('stock_id').length;
		if(row_c != 0)
		{
			if(document.getElementById('quantity').value == "")
			{
				alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id ='57635.Miktar'>!");
				return false;
			}
			else
			{
				var n_stock_id =document.all.stock_id.value;
				var n_amount = filterNum(document.all.quantity.value,6);
				var n_spect_id = document.all.spect_var_id.value;
				var n_is_production = 1;
				if(n_spect_id == "") n_spect_id =0;
				if(n_stock_id != "" && n_is_production ==1)//ürün silinmemiş ise
					stock_id_list +=n_stock_id+'-'+n_spect_id+'-'+n_amount+'-'+n_is_production+',';
				document.getElementById('deliver_date_info').style.display='';
				AjaxPageLoad('#request.self#?fuseaction=prod.popup_ajax_deliver_date_calc&from_p_order_list=1&is_from_order=1&stock_id_list='+stock_id_list+'','deliver_date_info',1,"<cf_get_lang dictionary_id ='36483.Tarih Hesaplanıyor'>");
			}
		}
		else
			alert("<cf_get_lang dictionary_id='58194.Zorunlu alan'> : <cf_get_lang dictionary_id ='57657.Ürün'>");	
	}
</script>
</cfoutput>
