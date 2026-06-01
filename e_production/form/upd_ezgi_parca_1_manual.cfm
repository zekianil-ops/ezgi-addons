<!---
    File: upd_ezgi_parca_1_manual.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfparam name="attributes.date1" default="">
<cfparam name="attributes.date2" default="">
<cfparam name="attributes.keyword" default="">
<cfif isdefined("attributes.date1") and isdate(attributes.date1)>
	<cf_date tarih = "attributes.date1">
<cfelse>	
	<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
		<cfset attributes.date1 = ''>
	<cfelse>
		<cfset attributes.date1 = session.ep.period_start_date>
	</cfif>
</cfif>

<cfif isdefined("attributes.date2") and isdate(attributes.date2)>
	<cf_date tarih = "attributes.date2">
<cfelse>	
	<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
		<cfset attributes.date2 = ''>
	<cfelse>
		<cfset attributes.date2 = session.ep.period_finish_date>
	</cfif>
</cfif>
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
    	MASTER_PLAN_ID = #attributes.master_plan_id#
  	ORDER BY
    	MASTER_PLAN_NUMBER
</cfquery>
<cfif isdefined("attributes.form_submitted")>
    <cfquery name="get_up_sub_plan" datasource="#dsn3#">
        SELECT        
            EMAP.RELATED_MASTER_ALT_PLAN_ID, 
            EMAP.PROCESS_ID, 
            EMPS.WORKSTATION_ID
        FROM            
            EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
            EZGI_MASTER_PLAN_SABLON AS EMPS ON EMAP.PROCESS_ID = EMPS.PROCESS_ID
        WHERE        
            EMAP.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
    </cfquery>
    <cfquery name="get_station_times" datasource="#dsn#">
        SELECT * FROM SETUP_SHIFTS WHERE SHIFT_ID=#GET_W.MASTER_PLAN_CAT_ID#
    </cfquery>
    <cfset works_prog = get_station_times.SHIFT_NAME>
    <cfset works_prog_id = get_station_times.SHIFT_ID>
    <cfif get_up_sub_plan.recordcount>
        <cfquery name="GET_EZGI_MIP_1" datasource="#dsn3#">
        	SELECT
            	REAL_STOCK, 
                PRODUCT_STOCK, 
                RESERVED_STOCK, 
                PURCHASE_PROD_STOCK, 
                REAL_STOCK+RESERVE_PURCHASE_ORDER_STOCK-RESERVE_SALE_ORDER_STOCK-RESERVED_PROD_STOCK+PURCHASE_PROD_STOCK AS SALEABLE_STOCK, 
                RESERVE_SALE_ORDER_STOCK, 
                NOSALE_STOCK,
                BELONGTO_INSTITUTION_STOCK, 
                RESERVE_PURCHASE_ORDER_STOCK, 
                PRODUCTION_ORDER_STOCK, 
                NOSALE_RESERVED_STOCK, 
                PRODUCT_ID, 
                STOCK_ID,
                PRODUCT_CODE,
                PRODUCT_NAME,	
                RESERVED_PROD_STOCK,
                MAXIMUM_STOCK,
                MINIMUM_STOCK,
                SPECT_MAIN_ID,
                MAIN_UNIT
          	FROM
            	(
                SELECT        
                    GS.REAL_STOCK, 
                    GS.PRODUCT_STOCK, 
                    GS.RESERVED_STOCK, 
                    GS.PURCHASE_PROD_STOCK, 
                    GS.SALEABLE_STOCK, 
                    GS.RESERVE_SALE_ORDER_STOCK, 
                    GS.NOSALE_STOCK,
                    GS.BELONGTO_INSTITUTION_STOCK, 
                    GS.RESERVE_PURCHASE_ORDER_STOCK, 
                    GS.PRODUCTION_ORDER_STOCK, 
                    GS.NOSALE_RESERVED_STOCK, 
                    GS.PRODUCT_ID, 
                    GS.STOCK_ID,
                    S.PRODUCT_CODE,
                    S.PRODUCT_NAME,
                    ISNULL((
                        SELECT 
                            SUM(STOCK_AZALT) AS URETIM
                        FROM     
                            (
                                                            SELECT 
                                    CASE 
                                    WHEN ISNULL
                                        ((
                                            SELECT 
                                                SUM(POR_.AMOUNT)
                                            FROM      
                                                PRODUCTION_ORDER_RESULTS_ROW POR_, 
                                                PRODUCTION_ORDER_RESULTS POO
                                            WHERE   
                                                POR_.PR_ORDER_ID = POO.PR_ORDER_ID AND 
                                                POO.P_ORDER_ID = PO.P_ORDER_ID AND 
                                                POR_.STOCK_ID = POS.STOCK_ID AND 
                                                POO.IS_STOCK_FIS = 1
                                        ),0) > ISNULL(PO.RESULT_AMOUNT, 0) 
                                    THEN
                                        (
                                            (
                                                SELECT 
                                                    SUM(AMOUNT) AMOUNT
                                                FROM      
                                                    PRODUCTION_ORDERS_STOCKS
                                                WHERE   
                                                    P_ORDER_ID = PO.P_ORDER_ID AND 
                                                    STOCK_ID = POS.STOCK_ID
                                            ) 
                                            /
                                            (
                                                SELECT 
                                                    QUANTITY
                                                FROM      
                                                    PRODUCTION_ORDERS
                                                WHERE   
                                                    P_ORDER_ID = PO.P_ORDER_ID
                                            )
                                            * 
                                            ISNULL(PO.QUANTITY,0) - ISNULL(PO.RESULT_AMOUNT,0)
                                        ) 
                                    ELSE 
                                        (POS.AMOUNT * (ISNULL(PO.QUANTITY, 0) - ISNULL(PO.RESULT_AMOUNT, 0)) / ISNULL(PO.QUANTITY, 0)) 
                                    END AS STOCK_AZALT, 
                                    POS.STOCK_ID, 
                                    PO.START_DATE
                                FROM      
                                    PRODUCTION_ORDERS AS PO INNER JOIN
                                    PRODUCTION_ORDERS_STOCKS AS POS ON PO.P_ORDER_ID = POS.P_ORDER_ID
                                WHERE   
                                    PO.IS_STOCK_RESERVED = 1 AND 
                                    PO.IS_DEMONTAJ = 0 AND 
                                    ISNULL(POS.STOCK_ID, 0) > 0 AND 
                                    POS.IS_SEVK <> 1 AND 
                                    ISNULL(POS.IS_FREE_AMOUNT, 0) = 0 AND 
                                    PO.STATUS = 1
                                    <cfif len(attributes.date1)>
                                        AND PO.START_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.DATE1#">
                                    </cfif>
                                    <cfif len(attributes.date2)>
                                        AND PO.START_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.DATE2#">
                                    </cfif>
                            ) AS TBL
                        WHERE
                            TBL.STOCK_ID = S.STOCK_ID
                        GROUP 
                            BY STOCK_ID	
                    ),0) AS RESERVED_PROD_STOCK,
                    ISNULL((
                        SELECT        
                            MAXIMUM_STOCK
                        FROM            
                            STOCK_STRATEGY
                        WHERE        
                            STOCK_ID = S.STOCK_ID
                    ), 0) AS MAXIMUM_STOCK, 
                    ISNULL((
                        SELECT        
                            MINIMUM_STOCK
                        FROM            
                            STOCK_STRATEGY AS STOCK_STRATEGY_1
                        WHERE        
                            STOCK_ID = S.STOCK_ID
                    ), 0) AS MINIMUM_STOCK,
                    (
                        SELECT        
                            TOP (1) SPECT_MAIN_ID
                        FROM            
                            SPECT_MAIN
                        WHERE        
                            SPECT_STATUS = 1 AND 
                            STOCK_ID = S.STOCK_ID
                        ORDER BY 
                            SPECT_MAIN_ID
                    ) AS SPECT_MAIN_ID,
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
                    #dsn2_alias#.GET_STOCK_LAST_PROFILE AS GS INNER JOIN
                    STOCKS AS S ON GS.STOCK_ID = S.STOCK_ID
                WHERE   
                    S.IS_PRODUCTION = 1 AND 
                    GS.SALEABLE_STOCK < 0 AND
                    S.STOCK_ID IN
                                    (
                                    SELECT        
                                        STOCK_ID
                                    FROM            
                                        WORKSTATIONS_PRODUCTS
                                    WHERE        
                                        WS_ID = #get_up_sub_plan.WORKSTATION_ID#
                                    ) 
                    <cfif isDefined("attributes.keyword") and len(attributes.keyword)>
                        AND 
                            (
                                S.PRODUCT_CODE LIKE<cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> OR
                                S.PRODUCT_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">
                            )
                    </cfif>
          		) AS TBL1
           	 WHERE   
           		REAL_STOCK+RESERVE_PURCHASE_ORDER_STOCK-RESERVE_SALE_ORDER_STOCK-RESERVED_PROD_STOCK+PURCHASE_PROD_STOCK < 0 
        </cfquery>
    </cfif>
<cfelse>
	<cfset GET_EZGI_MIP_1.recordcount = 0>
    <cfset get_up_sub_plan.recordcount = 0>
</cfif>
<br />
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
        <cfform name="form_master_alt_plan" method="post" action="#request.self#?fuseaction=prod.popup_ezgi_upd_parca_1_manual">
            <input type="hidden" name="form_submitted" value="1" />
            <input type="hidden" name="master_plan_id" value="<cfoutput>#attributes.master_plan_id#</cfoutput>">
            <input type="hidden" name="master_alt_plan_id" value="<cfoutput>#attributes.master_alt_plan_id#</cfoutput>">
            <input type="hidden" name="islem_id" value="<cfoutput>#attributes.islem_id#</cfoutput>" />
            <cf_box_search>
                <div class="form-group"  id="item-keyword">
                	 <cfinput type="text" style="width:150px;" placeholder="#getLang(48,'Filtre',57460)#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                 <div class="form-group" id="item-start_date">
					<div class="input-group x-14">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></cfsavecontent>
						<cfinput type="text" name="date1" placeholder="#message#" value="#dateformat(attributes.date1, dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10">
						<span class="input-group-addon"><cf_wrk_date_image date_field="date1"></span>
					</div>
				</div>		
				<div class="form-group" id="item-finish_date">
					<div class="input-group x-14">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></cfsavecontent>
						<cfinput type="text" name="date2" placeholder="#message#" value="#dateformat(attributes.date2, dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10">
						<span class="input-group-addon"><cf_wrk_date_image date_field="date2"></span>
					</div>
				</div>	
                <!---<div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>--->
          		<div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
			</cf_box_search>
      	</cfform>

        <cfsavecontent variable="header_">
            <cf_get_lang dictionary_id='610.Plan İhtiyaç Karşılama Raporu'>
        </cfsavecontent>
        <cf_box title="#header_#" uidrop="1" hide_table_column="1" scroll="1" right_images="">
      		<cf_grid_list>
                <thead>
                    <tr>
                        <th width="2%" height="30px" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        <th width="7%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                        <th width="24%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                        <th width="4%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='57636.Birim'></th>
                        <th width="6%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='58120.Gerçek Stok'></th>
                        <th width="6%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='611.Verilen Sipariş Rezerve'></th>
                        <th width="6%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='612.Alınan Sipariş Rezerve'></th>
                        <th width="6%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='613.Tüm Üretim İhtiyaçları'></th>
                        <th width="6%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='614.Tüm Üretim Beklenen'></th>
                        <th width="6%" align="center" valign="middle" class="form-title"> <cf_get_lang dictionary_id='1068.Optimum Stok'></th>
                        <th width="6%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='615.Gerçek İhtiyaç'></th>
                        <th width="6%" align="center" valign="middle" class="form-title"><cf_get_lang dictionary_id='616.İş Emri Miktarı'></th>
                        <th class="form-title" align="center" width="1%" title="<cf_get_lang dictionary_id='206.Hepsini Seç'>"><input type="checkbox" name="allSelectDemand" id="allSelectDemand" onClick="wrk_select_all('allSelectDemand','is_active');"></th>
                    </tr>
                </thead>
                <tbody>
                    <cfif get_up_sub_plan.recordcount>
                        <cfset islem_type=1>
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