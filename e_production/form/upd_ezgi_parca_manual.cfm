<!---
    File: upd_ezgi_parca_manual.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.date1" default="#now()#"> 
<cfparam name="attributes.date2" default="#now()#"> 
<cfparam name="is_equal_group_stations" default="0">
<cfparam name="attributes.production_stage" default="">
<cfparam name="attributes.lot_no" default="">
<cfparam name="attributes.is_submitted" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.order_no" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.member_type" default="">
<cfparam name="attributes.member_name" default="">
<cfparam name="attributes.vardiya_sales" default="">
<cfparam name="attributes.order_employee_id" default="">
<cfparam name="attributes.order_employee" default="">
<cfparam name="attributes.sales_partner_id" default="">
<cfparam name="attributes.sales_partner" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.product_catid" default="">
<cfparam name="attributes.product_cat" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.stock_id" default="">
<cfparam name="attributes.spect_main_id" default="">
<cfparam name="attributes.spect_name" default="">
<cfparam name="attributes.reference_no" default="">
<cfparam name="attributes.result" default="">
<cfparam name="attributes.is_submitted" default="0">
<cfparam name="attributes.master_alt_plan_id_" default="#attributes.master_alt_plan_id#">
<cfquery name="get_station" datasource="#dsn3#">
	SELECT        
    	WORKSTATION_ID
	FROM            
    	EZGI_MASTER_PLAN_SABLON
	WHERE        
    	PROCESS_ID = #attributes.islem_id#
</cfquery>
<cfquery name="GET_W" datasource="#dsn3#">
	SELECT        
    	MASTER_PLAN_ID, 
        MASTER_PLAN_START_DATE, 
        MASTER_PLAN_FINISH_DATE, 
        MASTER_PLAN_NUMBER, 
        MASTER_PLAN_CAT_ID
	FROM            
    	EZGI_MASTER_PLAN
	WHERE        
    	MASTER_PLAN_ID IN (#attributes.master_plan_id#)
  	ORDER BY
    	MASTER_PLAN_NUMBER
</cfquery>
<cfquery name="get_up_sub_plan" datasource="#dsn3#">
	SELECT        
    	EMAP.RELATED_MASTER_ALT_PLAN_ID, 
        EMAP.PROCESS_ID, 
        EMPS.WORKSTATION_ID
	FROM            
    	EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
      	EZGI_MASTER_PLAN_SABLON AS EMPS ON EMAP.PROCESS_ID = EMPS.PROCESS_ID
	WHERE        
    	EMAP.MASTER_ALT_PLAN_ID IN (#attributes.master_alt_plan_id_#)
</cfquery>
<cfset related_master_plan_id_list = ValueList(get_up_sub_plan.RELATED_MASTER_ALT_PLAN_ID)>
<cfquery name="get_station_times" datasource="#dsn#">
	SELECT * FROM SETUP_SHIFTS WHERE SHIFT_ID=#GET_W.MASTER_PLAN_CAT_ID#
</cfquery>
<cfset works_prog = get_station_times.SHIFT_NAME>
<cfset works_prog_id = get_station_times.SHIFT_ID>
<cfquery name="get_master_plans" datasource="#dsn3#">
	SELECT        
    	MASTER_ALT_PLAN_ID ALT_PLAN_ID, 
        PLAN_START_DATE, 
        PLAN_FINISH_DATE, 
        PLAN_DETAIL
	FROM            
    	EZGI_MASTER_ALT_PLAN
	WHERE        
    	PROCESS_ID = #attributes.islem_id# AND
        MASTER_PLAN_ID = #attributes.master_plan_id#
	ORDER BY 
    	PLAN_START_DATE
</cfquery>
<cfif isdefined('form_submitted')>
	<cfif get_up_sub_plan.recordcount and ListLen(related_master_plan_id_list)>
        <cfquery name="GET_EZGI_MIP_1" datasource="#dsn3#">
            SELECT   	 
                SUM(PO.QUANTITY * SMR.AMOUNT) AS MIKTAR, 
                SUM(PO.QUANTITY * SMR.AMOUNT) AS PRODUCT_STOCK,
                SMR.STOCK_ID, 
                S.PRODUCT_NAME, 
                SMR.OPERATION_TYPE_ID, 
                SMR.RELATED_MAIN_SPECT_ID AS SPECT_MAIN_ID, 
                S.PRODUCT_ID, 
                S.PRODUCT_CODE,
                S.STOCK_CODE,
                ISNULL((
                    SELECT        
                        MAXIMUM_STOCK
                    FROM            
                        STOCK_STRATEGY
                    WHERE        
                        STOCK_ID = SMR.STOCK_ID
                ), 0) AS MAXIMUM_STOCK, 
                                     
                ISNULL((
                    SELECT        
                        MINIMUM_STOCK
                    FROM            
                        STOCK_STRATEGY AS STOCK_STRATEGY_1
                    WHERE        
                        STOCK_ID = SMR.STOCK_ID
                ), 0) AS MINIMUM_STOCK,
                (
                    SELECT     
                        MAIN_UNIT
                    FROM          
                        PRODUCT_UNIT
                    WHERE      
                        IS_MAIN = 1 AND 
                        PRODUCT_ID = S.PRODUCT_ID
                ) AS MAIN_UNIT
            FROM            
                EZGI_MASTER_PLAN_RELATIONS AS VPR INNER JOIN
                PRODUCTION_ORDERS AS PO ON VPR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                SPECT_MAIN_ROW AS SMR ON PO.SPEC_MAIN_ID = SMR.SPECT_MAIN_ID INNER JOIN
                EZGI_MASTER_ALT_PLAN AS EMAP ON VPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
                EZGI_MASTER_PLAN AS E ON EMAP.MASTER_PLAN_ID = E.MASTER_PLAN_ID LEFT OUTER JOIN
                STOCKS AS S ON SMR.STOCK_ID = S.STOCK_ID
            WHERE   
                S.IS_PRODUCTION = 1 AND 
                E.MASTER_PLAN_PROCESS = 1 AND 
                SMR.STOCK_ID IN
                                (
                                SELECT        
                                    STOCK_ID
                                FROM            
                                    WORKSTATIONS_PRODUCTS
                                WHERE        
                                    WS_ID = #get_up_sub_plan.WORKSTATION_ID#
                                )  AND
                (
                    EMAP.MASTER_ALT_PLAN_ID IN (#related_master_plan_id_list#) OR
                    EMAP.RELATED_MASTER_ALT_PLAN_ID IN (#related_master_plan_id_list#)
                )
            GROUP BY 
                SMR.STOCK_ID, 
                SMR.OPERATION_TYPE_ID, 
                SMR.RELATED_MAIN_SPECT_ID, 
                S.PRODUCT_ID, 
                S.PRODUCT_CODE, 
                S.STOCK_CODE, 
                S.PRODUCT_NAME
            ORDER BY	
                S.PRODUCT_NAME 
        </cfquery>  
    <cfelse>
    	<cfset GET_EZGI_MIP_1.recordcount = 0>
    </cfif>
<cfelse>
	<cfset GET_EZGI_MIP_1.recordcount = 0>
</cfif>
<br />
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
        <cfform name="form_master_alt_plan" method="post" action="#request.self#?fuseaction=prod.popup_ezgi_upd_parca_manual">
            <input type="hidden" name="form_submitted" value="1" />
            <input type="hidden" name="master_plan_id" value="<cfoutput>#attributes.master_plan_id#</cfoutput>">
            <input type="hidden" name="master_alt_plan_id" value="<cfoutput>#attributes.master_alt_plan_id#</cfoutput>">
            <input type="hidden" name="islem_id" value="<cfoutput>#attributes.islem_id#</cfoutput>" />
            <cfif isdefined('attributes.from_demand')>
                <cfinput type="hidden" name="from_demand" value="1">
            </cfif>
             <cf_box_search>
                <div class="form-group"  id="item-keyword">
                    <select name="master_alt_plan_id_" style="width:300px; height:70px" multiple>
                        <cfoutput query="get_master_plans">
                            <option value="#ALT_PLAN_ID#" <cfif ListFind(attributes.master_alt_plan_id_, ALT_PLAN_ID)>selected</cfif>>#PLAN_DETAIL# - (#Dateformat(PLAN_START_DATE,dateformat_style)# - #DateFormat(PLAN_FINISH_DATE,dateformat_style)#)</option>
                        </cfoutput>
                    </select>
                </div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
            </cf_box_search>
		</cfform>
        <cfsavecontent variable="header_">
            <cfif isdefined('attributes.from_demand')>
                <cf_get_lang dictionary_id="462.Üretim Talep Listesi">
            <cfelse>
                <cf_get_lang dictionary_id='610.Plan İhtiyaç Karşılama Raporu'>
            </cfif>
        </cfsavecontent>
        <cf_box title="#header_#" uidrop="1" hide_table_column="1" scroll="1" right_images="">
      		<cf_grid_list>
                <thead>
                    <tr>
                        <th width="2%" height="30px" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        <th width="7%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                        <th width="24%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                        <th width="6%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='615.Gerçek İhtiyaç'></th>
                        <th width="4%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='57636.Birim'></th>
                        <th width="6%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='616.İş Emri Miktarı'></th>
                        <th class="form-title" align="center" width="1%" title="<cf_get_lang dictionary_id='206.Hepsini Seç'>"><input type="checkbox" name="allSelectDemand" id="allSelectDemand" onClick="wrk_select_all('allSelectDemand','is_active');"></th>
                    </tr>
                </thead>
                <tbody>
                    <cfif isdefined('form_submitted') and get_up_sub_plan.recordcount and ListLen(related_master_plan_id_list)>
                        <cfinclude template="ezgi_production_plan_include.cfm">
                    <cfelse>
                        <tr class="color-row" height="20">
                            <td colspan="16"><cfif isdefined("attributes.form_submitted")><cf_get_lang dictionary_id='57484.Kayıt Yok'><cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'></cfif> !</td>
                        </tr>
                    </cfif>
                </tbody>
        	</cf_grid_list>
		</cf_box>
  	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;	
	}
</script>