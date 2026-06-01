<!---
    File: upd_ezgi_master_sub_plan_manual.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->


<cfset ezgi_gosterim_tip = 1> <!---0 Olduğunda Üst Emri Aynı Emirden Geliyorsa Bu sayfadakilerde Tek Select Geliyor--->
<cfparam name="attributes.islem" default="0">
<cfquery name="get_default" datasource="#dsn3#">
	SELECT       
    	EMAD.POINT_METHOD,
        EMAD.FABRIC_CAT,
        EMAD.CONTROL_METHOD
	FROM            
    	EZGI_MASTER_PLAN_DEFAULTS AS EMAD INNER JOIN
     	EZGI_MASTER_PLAN AS EMAP ON EMAD.SHIFT_ID = EMAP.MASTER_PLAN_CAT_ID
	WHERE        
    	EMAP.MASTER_PLAN_ID = #attributes.master_plan_id#
</cfquery>
<cfquery name="get_master_plan" datasource="#dsn3#">
	SELECT  	
		EMP.MASTER_PLAN_NAME, 
		EMP.MASTER_PLAN_DETAIL, 
		EMP.MASTER_PLAN_STATUS, 
    	EMP.MASTER_PLAN_CAT_ID, 
		EMP.BRANCH_ID, 
		EMP.GROSSTOTAL,
		EMP.MASTER_PLAN_ID, 
		EMP.MASTER_PLAN_NUMBER,
		EMP.MASTER_PLAN_PROJECT_ID,
        ISNULL(EMAP.IS_RESERVED,1) AS IS_RESERVED,
		EMAP.MASTER_ALT_PLAN_NO,
		EMAP.MASTER_ALT_PLAN_STAGE, 
		EMAP.IS_STOCK_FIS, 
		EMAP.RECORD_DATE, 
    	EMAP.RECORD_IP, 
		EMAP.UPDATE_DATE, 
		EMAP.UPDATE_EMP,
    	EMAP.PLAN_START_DATE, 
		EMAP.PLAN_FINISH_DATE,
   		LTRIM(EMAP.PLAN_DETAIL) AS PLAN_DETAIL, 
		EMAP.UPDATE_IP,
     	EMAP.PLAN_POINT,
    	ISNULL(EMAP.PLAN_TYPE,0) AS PLAN_TYPE,
   		EMPS.SIRA,
    	EMAP.PROCESS_ID,
        <cfif get_default.POINT_METHOD eq 1>
    	ISNULL((	
                    SELECT     
                		SUM(PO.QUANTITY) AS P_POINT
                    FROM         
                        EZGI_MASTER_PLAN_RELATIONS AS EMPR INNER JOIN
                        PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID
                    WHERE     
                        EMPR.MASTER_ALT_PLAN_ID =  EMAP.MASTER_ALT_PLAN_ID
    	),0) AS TOTAL_POINT,
        <cfelseif get_default.POINT_METHOD eq 2>
        ISNULL(
                	(	
                    SELECT     
                		SUM(PO.QUANTITY * ISNULL(CAST(PTIP.PROPERTY2 AS float),0)) AS P_POINT
                    FROM         
                        EZGI_MASTER_PLAN_RELATIONS AS EMPR INNER JOIN
                        PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID LEFT OUTER JOIN
                        PRODUCT_TREE_INFO_PLUS AS PTIP ON PO.STOCK_ID = PTIP.STOCK_ID
                    WHERE     
                        EMPR.MASTER_ALT_PLAN_ID =  EMAP.MASTER_ALT_PLAN_ID
              	),0) AS TOTAL_POINT,
        </cfif>
        <cfif get_default.POINT_METHOD eq 1>
        ISNULL((	
                    SELECT     
                		SUM(PO.QUANTITY) AS P_POINT
                    FROM         
                        EZGI_MASTER_PLAN_RELATIONS AS EMPR INNER JOIN
                        PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID
                    WHERE     
                        EMPR.MASTER_ALT_PLAN_ID =  EMAP.MASTER_ALT_PLAN_ID AND PO.IS_STAGE = 2
    	),0) AS G_POINT
        <cfelseif get_default.POINT_METHOD eq 2>
        ISNULL(
                	(	
                    SELECT     
                		SUM(PO.QUANTITY * ISNULL(CAST(PTIP.PROPERTY2 AS float),0)) AS P_POINT
                    FROM         
                        EZGI_MASTER_PLAN_RELATIONS AS EMPR INNER JOIN
                        PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID LEFT OUTER JOIN
                        PRODUCT_TREE_INFO_PLUS AS PTIP ON PO.STOCK_ID = PTIP.STOCK_ID
                    WHERE     
                        EMPR.MASTER_ALT_PLAN_ID =  EMAP.MASTER_ALT_PLAN_ID AND PO.IS_STAGE = 2
              	),0) AS G_POINT
        </cfif>
	FROM       	
    	EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) INNER JOIN
      	EZGI_MASTER_PLAN AS EMP WITH (NOLOCK) ON EMAP.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID INNER JOIN
      	EZGI_MASTER_PLAN_SABLON AS EMPS WITH (NOLOCK) ON EMAP.PROCESS_ID = EMPS.PROCESS_ID
	WHERE     	
    	EMAP.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
</cfquery>
<cfquery name="GET_OPERATION_NULL" datasource="#DSN3#">
	SELECT     
    	EZGI_OPERATION_S.*
	FROM         
    	EZGI_OPERATION_S
	WHERE     
   		MASTER_ALT_PLAN_ID IN
                      			(
                                SELECT     
                                  	MASTER_ALT_PLAN_ID
                           		FROM          
                                   	EZGI_MASTER_ALT_PLAN
                           		WHERE      
                                   	MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id# OR
                                   	RELATED_MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
                               	) AND 
         	O_STATION_IP IS NULL
</cfquery>
<cfquery name="GET_OPERATION_PROCESS" datasource="#DSN3#">
	SELECT     
    	EZGI_OPERATION_S.*
	FROM         
    	EZGI_OPERATION_S WITH (NOLOCK)
	WHERE     
    	MASTER_ALT_PLAN_ID IN
                      			(
                                SELECT     
                                  	MASTER_ALT_PLAN_ID
                           		FROM          
                                   	EZGI_MASTER_ALT_PLAN
                           		WHERE      
                                   	MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id# OR
                                   	RELATED_MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
                               	) AND 
         	O_STATION_IP IS NOT NULL
</cfquery>
<cfquery name="menu_select" datasource="#dsn3#">
    SELECT   	
    	*
    FROM       	 
    	EZGI_MASTER_PLAN_SABLON WITH (NOLOCK)
    WHERE      
    	PROCESS_ID = #get_master_plan.PROCESS_ID#
</cfquery>
<cfif get_master_plan.recordcount>
	<cfset PROCESS_STAGE = get_master_plan.MASTER_ALT_PLAN_STAGE>
</cfif>
<cfquery name="get_prod_order" datasource="#dsn3#">
	<cfif menu_select.IS_CONTROL eq 1>
    	SELECT DISTINCT
            PO.P_ORDER_ID, 
            S.PRODUCT_CODE, 
            S.PRODUCT_NAME, 
            S.STOCK_ID, 
            S.PRODUCT_ID, 
            ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO,
            PO.STATION_ID, 
            PO.START_DATE, 
            PO.FINISH_DATE,
            ISNULL(PO.PRINT_COUNT, 0) AS PRINT_COUNT, 
            PO.QUANTITY, 
            PO.STATUS, 
            PO.P_ORDER_NO, 
            PO.PO_RELATED_ID, 
            PO.ORDER_ROW_ID, 
            PO.SPECT_VAR_NAME,
            PO.SPECT_VAR_ID, 
            PO.PROD_ORDER_STAGE, 
            PO.IS_STOCK_RESERVED, 
            PO.SPEC_MAIN_ID, 
            PO.PRODUCTION_LEVEL, 
            ISNULL(PO.IS_GROUP_LOT, 0) AS IS_GROUP_LOT, 
            PO.IS_STAGE, 
            PO.DETAIL,
            W.STATION_NAME, 
            W.BRANCH,
            PTR.STAGE,
            ISNULL(CAST(PTIP.PROPERTY2 AS FLOAT), 0) AS PRODUCT_POINT,
            ISNULL(CAST(PTIP.PROPERTY2 AS FLOAT), 0) * PO.QUANTITY AS P_ORDER_POINT,
            (
                SELECT 
                	S1.PRODUCT_NAME
                FROM 
                	PRODUCTION_ORDERS AS PO1 INNER JOIN STOCKS AS S1 ON PO1.STOCK_ID = S1.STOCK_ID
                WHERE 
                	PO1.P_ORDER_ID = PO.PO_RELATED_ID
            ) AS UST_EMIR,
            ISNULL(
                (
                    SELECT 
                    	TOP (1) P_ORDER_ID
                    FROM 
                    	PRODUCTION_ORDERS
                    WHERE 
                    	PO_RELATED_ID = PO.P_ORDER_ID
                ), 0
            ) AS ALT_EMIR,
            CASE 
                WHEN LEFT(PO.LOT_NO, 1) = '-' THEN SUBSTRING(PO.LOT_NO, 2, LEN(PO.LOT_NO) - 1)
                ELSE PO.LOT_NO
            END AS LOT_NO,
            ISNULL(O.ORDER_ID, 0) AS ORDER_ID, 
            O.ORDER_NUMBER, 
            O.ORDER_DATE, 
            O.ORDER_STATUS, 
            O.DELIVERDATE,
            O.IS_INSTALMENT,
            ORRR.DELIVER_DATE,
            ORRR.PRODUCT_NAME2,
            ORRR.QUANTITY AS ORDER_QUANTITY,
            CASE
                WHEN O.COMPANY_ID IS NOT NULL THEN (
                    SELECT NICKNAME
                    FROM #dsn_alias#.COMPANY
                    WHERE COMPANY_ID = O.COMPANY_ID
                )
                WHEN O.CONSUMER_ID IS NOT NULL THEN (
                    SELECT CONSUMER_NAME + ' ' + CONSUMER_SURNAME
                    FROM #dsn_alias#.CONSUMER
                    WHERE CONSUMER_ID = O.CONSUMER_ID
                )
                WHEN O.EMPLOYEE_ID IS NOT NULL THEN (
                    SELECT EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME
                    FROM #dsn_alias#.EMPLOYEES
                    WHERE EMPLOYEE_ID = O.EMPLOYEE_ID
                )
                ELSE 'Stok Üretim'
            END AS UNVAN
        FROM 
        	PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN 
            STOCKS AS S WITH (NOLOCK) ON S.STOCK_ID = PO.STOCK_ID INNER JOIN 
            WORKSTATIONS AS W WITH (NOLOCK) ON PO.STATION_ID = W.STATION_ID INNER JOIN 
            #dsn_alias#.PROCESS_TYPE_ROWS AS PTR WITH (NOLOCK) ON PO.PROD_ORDER_STAGE = PTR.PROCESS_ROW_ID INNER JOIN 
            EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) ON PO.P_ORDER_ID = EMPR.P_ORDER_ID LEFT JOIN 
            PRODUCT_TREE_INFO_PLUS AS PTIP WITH (NOLOCK) ON S.STOCK_ID = PTIP.STOCK_ID LEFT JOIN 
            PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) ON POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID LEFT JOIN 
            ORDERS AS O WITH (NOLOCK) ON O.ORDER_ID = POR.ORDER_ID LEFT JOIN 
            ORDER_ROW AS ORRR WITH (NOLOCK) ON POR.ORDER_ROW_ID = ORRR.ORDER_ROW_ID
        WHERE 
            EMPR.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id# 
            AND PO.STATION_ID = #menu_select.WORKSTATION_ID#
        ORDER BY 
            PO.START_DATE,
            PO.P_ORDER_NO
	<cfelse>
    	SELECT DISTINCT
            PO.P_ORDER_ID, 
            S.PRODUCT_CODE, 
            S.PRODUCT_NAME, 
            S.STOCK_ID, 
            S.PRODUCT_ID, 
            ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO,
            PO.STATION_ID, 
            PO.START_DATE, 
            PO.FINISH_DATE,
            ISNULL(PO.PRINT_COUNT, 0) AS PRINT_COUNT, 
            PO.QUANTITY, 
            PO.STATUS, 
            PO.P_ORDER_NO, 
            PO.PO_RELATED_ID, 
            PO.ORDER_ROW_ID, 
            PO.SPECT_VAR_NAME,
            PO.SPECT_VAR_ID, 
            PO.PROD_ORDER_STAGE, 
            PO.IS_STOCK_RESERVED, 
            PO.SPEC_MAIN_ID, 
            PO.PRODUCTION_LEVEL, 
            ISNULL(PO.IS_GROUP_LOT, 0) AS IS_GROUP_LOT, 
            PO.IS_STAGE, 
            PO.DETAIL,
            W.STATION_NAME, 
            W.BRANCH,
            PTR.STAGE,
            ISNULL(CAST(PTIP.PROPERTY2 AS FLOAT), 0) AS PRODUCT_POINT,
            ISNULL(CAST(PTIP.PROPERTY2 AS FLOAT), 0) * PO.QUANTITY AS P_ORDER_POINT,
            (
                SELECT S1.PRODUCT_NAME
                FROM PRODUCTION_ORDERS AS PO1
                INNER JOIN STOCKS AS S1 ON PO1.STOCK_ID = S1.STOCK_ID
                WHERE PO1.P_ORDER_ID = PO.PO_RELATED_ID
            ) AS UST_EMIR,
            ISNULL(
                (
                    SELECT TOP (1) P_ORDER_ID
                    FROM PRODUCTION_ORDERS
                    WHERE PO_RELATED_ID = PO.P_ORDER_ID
                ), 0
            ) AS ALT_EMIR,
            CASE 
                WHEN LEFT(PO.LOT_NO, 1) = '-' THEN SUBSTRING(PO.LOT_NO, 2, LEN(PO.LOT_NO) - 1)
                ELSE PO.LOT_NO
            END AS LOT_NO,
            0 AS ORDER_ID, 
            '' AS ORDER_NUMBER, 
            '' AS ORDER_DATE, 
            1 AS ORDER_STATUS, 
            '' AS DELIVERDATE,
            '' AS DELIVER_DATE,
            '' AS PRODUCT_NAME2,
            0 AS ORDER_QUANTITY,
            1 AS IS_INSTALMENT,
            '' AS UNVAN
        FROM STOCKS AS S WITH (NOLOCK)
        INNER JOIN PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON S.STOCK_ID = PO.STOCK_ID
        INNER JOIN WORKSTATIONS AS W WITH (NOLOCK) ON PO.STATION_ID = W.STATION_ID
        INNER JOIN #dsn_alias#.PROCESS_TYPE_ROWS AS PTR WITH (NOLOCK) ON PO.PROD_ORDER_STAGE = PTR.PROCESS_ROW_ID
        INNER JOIN EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) ON PO.P_ORDER_ID = EMPR.P_ORDER_ID
        LEFT OUTER JOIN PRODUCT_TREE_INFO_PLUS AS PTIP WITH (NOLOCK) ON S.STOCK_ID = PTIP.STOCK_ID
        WHERE 
            EMPR.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id# 
            AND PO.STATION_ID = #menu_select.WORKSTATION_ID#
        ORDER BY 
            PO.START_DATE,
            PO.P_ORDER_NO

    </cfif>    	           
</cfquery>
<cfset control_list=Valuelist(get_prod_order.P_ORDER_ID)>
<cfquery name="GET_W" datasource="#dsn3#">
	WITH WorkstationCTE AS 
    (
        SELECT WORKSTATION_ID
        FROM EZGI_MASTER_PLAN_SABLON
        WHERE PROCESS_ID = #get_master_plan.PROCESS_ID#
    ),
    PlanCategoryCTE AS (
        SELECT MASTER_PLAN_CAT_ID
        FROM EZGI_MASTER_PLAN
        WHERE MASTER_PLAN_ID = #attributes.master_plan_id#
    ),
    TotalPointCTE AS (
        SELECT 
            EMPR.MASTER_ALT_PLAN_ID,
            SUM(PO.QUANTITY * ISNULL(CAST(PTIP.PROPERTY2 AS float), 0)) AS TOTAL_POINT
        FROM 
            EZGI_MASTER_PLAN_RELATIONS EMPR
        INNER JOIN 
            PRODUCTION_ORDERS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID
        LEFT OUTER JOIN 
            PRODUCT_TREE_INFO_PLUS PTIP ON PO.STOCK_ID = PTIP.STOCK_ID
        GROUP BY 
            EMPR.MASTER_ALT_PLAN_ID
    )
    SELECT 
        EMAP.MASTER_ALT_PLAN_NO, 
        EMAP.MASTER_ALT_PLAN_ID, 
        EMAP.MASTER_PLAN_ID, 
        EMAP.PROCESS_ID, 
        EMAP.PLAN_FINISH_DATE, 
        EMAP.PLAN_START_DATE,
        EMAP.PLAN_TYPE,
        EMAP.PLAN_DETAIL,
        EMP.MASTER_PLAN_NUMBER,
        ISNULL(EMAP.PLAN_POINT, 0) AS W_POINT,
        EPN.WORKSTATION_ID,
        EPN.SHIFT_ID,
        EPN.SIRA,
        ISNULL(TP.TOTAL_POINT, 0) AS TOTAL_POINT
    FROM 
        EZGI_MASTER_PLAN_SABLON AS EPN WITH (NOLOCK) INNER JOIN 
        EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) ON EPN.PROCESS_ID = EMAP.PROCESS_ID INNER JOIN 
        EZGI_MASTER_PLAN AS EMP WITH (NOLOCK) ON EMAP.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID LEFT JOIN 
        TotalPointCTE TP ON EMAP.MASTER_ALT_PLAN_ID = TP.MASTER_ALT_PLAN_ID
    WHERE 
        EPN.WORKSTATION_ID = (SELECT WORKSTATION_ID FROM WorkstationCTE)
        AND EMAP.MASTER_ALT_PLAN_ID <> #attributes.master_alt_plan_id#
        AND EMP.MASTER_PLAN_STATUS = 1
        AND EMP.MASTER_PLAN_PROCESS = 1
        AND EMP.MASTER_PLAN_CAT_ID = (SELECT MASTER_PLAN_CAT_ID FROM PlanCategoryCTE)
    ORDER BY 
        EMAP.PLAN_START_DATE
</cfquery>
<cfquery name="order_group_control" dbtype="query">
	SELECT SPEC_MAIN_ID FROM GET_PROD_ORDER WHERE IS_STAGE <> 1 AND IS_STAGE <> 2 GROUP BY SPEC_MAIN_ID HAVING (COUNT(*) > 1)
</cfquery>
<cfquery name="order_related_control" dbtype="query">
	SELECT SPEC_MAIN_ID FROM GET_PROD_ORDER WHERE PO_RELATED_ID IS NOT NULL
</cfquery>
<cfquery name="p_order_is_group_control" dbtype="query">
	SELECT P_ORDER_ID FROM GET_PROD_ORDER WHERE IS_GROUP_LOT = 0 AND IS_STAGE <> 1 AND IS_STAGE <> 2
</cfquery>
<cfquery name="transfer_for_reason" datasource="#dsn3#">
	SELECT * FROM EZGI_MASTER_ALT_PLAN_REASON_FOR_TRANSFER ORDER BY REASON_FOR_TRANSFER
</cfquery>
<cfparam name="attributes.master_alt_plan_start_date" default="#get_master_plan.PLAN_START_DATE#">
<cfparam name="attributes.master_alt_plan_finish_date" default="#get_master_plan.PLAN_FINISH_DATE#">
<cfparam name="attributes.master_alt_plan_start_h" default="">
<cfparam name="attributes.master_alt_plan_finish_h" default="">
<cfparam name="attributes.master_alt_plan_start_m" default="">
<cfparam name="attributes.master_alt_plan_finish_m" default="">
<cfparam name="attributes.form_basket_submitted" default="">
<cfparam name="attributes.islem_id" default="">
<cfset islem_id = #get_master_plan.PROCESS_ID#>
<cfsavecontent variable="right_menu"></cfsavecontent>
<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id="1067.Alt Plan Güncelle"></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="ust_menu">
        	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.popup_list_ezgi_master_alt_plan_plus&master_alt_plan_id=#master_alt_plan_id#</cfoutput>','list');"><img src="/images/add_not.gif" title="<cf_get_lang dictionary_id='585.Takipler'>" border="0"></a>&nbsp;&nbsp;
        	<a href="javascript://"  onClick="grupla(-11);"><img src="/images/target_micro.gif" title="<cf_get_lang dictionary_id='480.Alt Plan Malzeme Kontrol Sistemi'>" border="0"></a>&nbsp;&nbsp;
       		<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.popup_list_ezgi_internaldemand_relation&subject=#get_master_plan.MASTER_ALT_PLAN_NO#</cfoutput>','list');"><img src="/images/stockstrategy.gif" title="<cf_get_lang dictionary_id='586.Alt Plan Malzeme İç Talep Karşılama Raporu'>" border="0"></a>&nbsp;&nbsp;
			<a href="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_master_plan&event=upd&upd_id=#master_plan_id#"><img src="/images/outsource.gif" title="<cf_get_lang dictionary_id='587.Master Plana Geri Dön'>" border="0"></cfoutput></a>&nbsp;&nbsp;
  	</cfsavecontent>
	<cf_box id="plan_detail" title="#ezgi_header#" right_images="#ust_menu#">
    	<cfform name="form_master_alt_plan" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_master_sub_plan">
			<input type="hidden" name="form_master_alt_plan_submitted" value="1" />
          	<input type="hidden" name="master_plan_id" value="<cfoutput>#master_plan_id#</cfoutput>">
			<input type="hidden" name="master_alt_plan_id" value="<cfoutput>#master_alt_plan_id#</cfoutput>">
          	<input type="hidden" name="islem_id" value="<cfoutput>#get_master_plan.PROCESS_ID#</cfoutput>" />
            <input type="hidden" name="expense_employee_id" value="<cfoutput>#session.ep.userid#</cfoutput>">
			<input type="hidden" name="expense_employee" value="<cfoutput>#get_emp_info(session.ep.userid,0,0)#</cfoutput>" readonly="yes">
            <cfoutput>
        	<cf_box_elements>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                	<cfif menu_select.SIRA eq 1>
                        <div class="form-group" id="item-reserve">
                            <div class="col col-4 col-md-4 col-sm-4 col-xs-12"></div>
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='41185.Stok Rezerve Et'></label>
                            <div class="col col-4 col-md-4 col-sm-4 col-xs-12">
                                 <input type="checkbox" name="is_stock_reserve" value="1" <cfif get_master_plan.IS_RESERVED eq 1>checked="checked"</cfif> >
                            </div>
                        </div>
                    </cfif>
					<div class="form-group" id="item-surec">
						<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='41129.Süreç/Asama'></label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        	 <cf_workcube_process is_upd='0' select_value='#get_master_plan.MASTER_ALT_PLAN_STAGE#' process_cat_width='125' is_detail='1'>
                        </div>
                  	</div>
                    <div class="form-group" id="item-paperno">
						<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id="1020.Master Plan No"> </label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        	 <input type="text" name="master_plan_number" readonly="readonly" value="#get_master_plan.master_plan_NUMBER#"  maxlength="75">
                        </div>
                  	</div>
                    <div class="form-group" id="item-alyplanno">
						<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='1019.Alt Plan No'> </label>
						<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                        	 <input name="paper_serious" type="text" value="#get_master_plan.MASTER_ALT_PLAN_NO#" />
                        </div>
                  	</div>
                    
            	</div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                	<div class="form-group" id="item-master_alt_plan_start_date">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57655.Baslama Tarihi'> *</label>
                     	<div class="col col-4 col-xs-12">
                        	<div class="input-group">
                            	<cfsavecontent variable="message"><cf_get_lang dictionary_id ='1333.Baslama Tarihi Girmelisiniz'> !</cfsavecontent>
                       			<input required="Yes"  message="#message#" type="text" name="master_alt_plan_start_date" id="master_alt_plan_start_date"  validate="eurodate" style="width:75px;" value="#dateformat(attributes.master_alt_plan_start_date,dateformat_style)#"> 
                            	<span class="input-group-addon"><cf_wrk_date_image date_field="master_alt_plan_start_date"></span>
                            </div>
                      	</div>
                        <div class="col col-2 col-xs-12">
                        	<select name="master_alt_plan_start_h" id="master_alt_plan_start_h">
                               	<cfloop from="0" to="23" index="i">
                               		<option value="#i#" <cfif isdefined('attributes.master_alt_plan_start_date') and timeformat(attributes.master_alt_plan_start_date,'HH') eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#</option>
                               	</cfloop>
                          	</select>
                      	</div>
                        <div class="col col-2 col-xs-12">
                       		<select name="master_alt_plan_start_m" id="master_alt_plan_start_m">
                          		<cfloop from="0" to="59" index="i">
                                	<option value="#i#" <cfif isdefined('attributes.master_alt_plan_start_date') and timeformat(attributes.master_alt_plan_start_date,'MM') eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#</option>
                             	</cfloop>
                         	</select>
                      	</div>
                    </div>
                    <div class="form-group" id="item-master_alt_plan_finish_date">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57655.Baslama Tarihi'> *</label>
                     	<div class="col col-4 col-xs-12">
                        	<div class="input-group">
                            	<cfsavecontent variable="message"><cf_get_lang dictionary_id ='531.Baslama Tarihi Girmelisiniz'> !</cfsavecontent>
                       			<input required="Yes"  message="#message#" type="text" name="master_alt_plan_finish_date" id="master_alt_plan_finish_date"  validate="eurodate" style="width:75px;" value="#dateformat(attributes.master_alt_plan_finish_date,dateformat_style)#"> 
                            	<span class="input-group-addon"><cf_wrk_date_image date_field="master_alt_plan_finish_date"></span>
                            </div>
                      	</div>
                        <div class="col col-2 col-xs-12">
                        	<select name="master_alt_plan_finish_h" id="master_alt_plan_finish_h">
                               	<cfloop from="0" to="23" index="i">
                               		<option value="#i#" <cfif isdefined('attributes.master_alt_plan_finish_date') and timeformat(attributes.master_alt_plan_finish_date,'HH') eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#</option>
                               	</cfloop>
                          	</select>
                      	</div>
                        <div class="col col-2 col-xs-12">
                       		<select name="master_alt_plan_finish_m" id="master_alt_plan_finish_m">
                          		<cfloop from="0" to="59" index="i">
                                	<option value="#i#" <cfif isdefined('attributes.master_alt_plan_finish_date') and timeformat(attributes.master_alt_plan_finish_date,'MM') eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#</option>
                             	</cfloop>
                         	</select>
                      	</div>
                    </div>
                	<div class="form-group" id="item-plan_type">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='1051.Alt Plan Tipi'></label>
                     	<div class="col col-8 col-xs-12">
                        	<select name="plan_type" style="width:100px">
                              	<option value="0" <cfif get_master_plan.plan_type eq 0>selected</cfif>>Normal Plan</option>
                             	<option value="1" <cfif get_master_plan.plan_type eq 1>selected</cfif>><cf_get_lang dictionary_id='588.Torba Plan'></option> 
                          	</select>
                      	</div>
                 	</div>
                    
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                    <div class="form-group" id="item-shift_project_id">
                  		<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                     	<div class="col col-8 col-xs-12">
                       		<div class="input-group">
                            	<input type="hidden" name="project_id" value="#get_master_plan.MASTER_PLAN_PROJECT_ID#" />
								<input type="text" name="project_name" value="<cfif len(get_master_plan.MASTER_PLAN_PROJECT_ID)><cfoutput>#get_project_name(get_master_plan.MASTER_PLAN_PROJECT_ID)#</cfoutput></cfif>" readonly style="width:140px;">
								<span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_head=list_works.project_head&project_id=list_works.project_id');"></span>
                        	</div>
                   		</div>
                	</div>
                    <div class="form-group" id="item-detail">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açiklama'> </label>
                     	<div class="col col-8 col-xs-12">
                        	<textarea name="detail" maxlength="500" style="width:167px;height:70px;" 
							onkeydown="counter(this.form.reference_no,this.form.detailLen,500);return ismaxlength(this);" 
							onkeyup="counter(this.form.reference_no,this.form.detailLen,500);return ismaxlength(this);" onBlur="return ismaxlength(this);">#get_master_plan.PLAN_DETAIL#</textarea>
                      	</div>
                 	</div>
                    
                </div>
                <div class="col col-2 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                	<div class="form-group" id="item-point">
                     	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='548.Hedef İş Puanı'> *</label>
                     	<div class="col col-6 col-xs-12">
                        	<input name="work_point" type="text" value="#TlFormat(get_master_plan.PLAN_POINT,2)#" style="text-align:center;font-weight:bold" />
                      	</div>
                 	</div>
                	<div class="form-group" id="plan-point">
                     	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='58869.Planlanan'> </label>
                     	<div class="col col-6 col-xs-12">
                        	<input name="plan_point" type="text" value="#TlFormat(get_master_plan.TOTAL_POINT,2)#" style="text-align:center; background-color:gainsboro; font-weight:bold" readonly="readonly" />
                      	</div>
                 	</div>
                	<div class="form-group" id="real-point">
                     	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id="47001.Gerçekleşen"> </label>
                     	<div class="col col-6 col-xs-12">
                        	<input name="realized_point" type="text" value="#TlFormat(get_master_plan.G_POINT,2)#" style="text-align:center; background-color:gainsboro; font-weight:bold" readonly="readonly" />
                      	</div>
                 	</div>
                </div>
                <div class="col col-1 col-md-4 col-sm-6 col-xs-12" type="column" index="5" sort="true">





                	<table style="text-align:center; vertical-align:middle; height:90%; width:100%" border="1" cellpadding="0" cellspacing="0" bordercolor="silver">
                    	<tr>
                        	<td style="text-align:center; vertical-align:middle; height:100%; width:100%">
                		<cfif GET_OPERATION_PROCESS.recordcount and GET_OPERATION_NULL.recordcount>
                        	<cfif menu_select.SIRA eq 1>
                                <a href="<cfoutput>#request.self#?fuseaction=prod.emptypopup_display_ezgi_hesap&master_plan_id=#master_plan_id#&master_alt_plan_id=#master_alt_plan_id#&islem_id=#islem_id#&islem=2</cfoutput>">
                                    <img src="/images/production/eksik_plan.png" title="<cf_get_lang dictionary_id='592.Operasyon Planı Yarım'>" border="0">
                                </a> 
                            <cfelse>
                            	<img src="/images/production/eksik_plan.png" title="<cf_get_lang dictionary_id='592.Operasyon Planı Yarım'>" border="0">
                            </cfif>    
                      	<cfelseif GET_OPERATION_PROCESS.recordcount>
							<cfif menu_select.SIRA eq 1>
                                <a href="<cfoutput>#request.self#?fuseaction=prod.emptypopup_display_ezgi_hesap&master_plan_id=#master_plan_id#&master_alt_plan_id=#master_alt_plan_id#&islem_id=#islem_id#&islem=2</cfoutput>">
                                    <img src="/images/production/tam_plan.jpg" title="<cf_get_lang dictionary_id='593.Operasyon Planı Tamam'>" border="0">
                                </a>
                            <cfelse>
                                <img src="/images/production/tam_plan.jpg" title="<cf_get_lang dictionary_id='593.Operasyon Planı Tamam'>" border="0">
                            </cfif>
                       	<cfelseif GET_OPERATION_NULL.recordcount>
                        	<cfif menu_select.SIRA eq 1>
                                <a href="<cfoutput>#request.self#?fuseaction=prod.emptypopup_display_ezgi_hesap&master_plan_id=#master_plan_id#&master_alt_plan_id=#master_alt_plan_id#&islem_id=#islem_id#&islem=1</cfoutput>">
                                    <img src="/images/production/plan_yok.png" title="<cf_get_lang dictionary_id='594.Operasyon Planı Yapılmamış'>" border="0">     
                                </a>
                      		<cfelse>
                            	<img src="/images/production/plan_yok.png" title="<cf_get_lang dictionary_id='594.Operasyon Planı Yapılmamış'>" border="0">
                            </cfif>
                    	</cfif>
                        		</td>
                         	</tr>
                   	</table>
                </div>
            </cf_box_elements>
       		</cfoutput>
            <cf_box_footer>
				<div class="col col-6">
					<cf_record_info 
						query_name="get_master_plan"
						record_emp="record_emp" 
						record_date="record_date"
						update_emp="update_emp"
						update_date="update_date">
				</div>
				<div class="col col-6">
					<cfif attributes.islem_id gt 0>
                    	<cf_workcube_buttons is_upd='1' add_function='kontrol()' is_delete='0'>
                  	<cfelse>
                        <cf_workcube_buttons add_function='kontrol()' is_delete='0'>
                  	</cfif>
				</div>      
			</cf_box_footer><br /> 
            <cfsavecontent variable="right_menu">
            	<cfoutput>
                    <cfif menu_select.SSH_P_ORDER eq 1>
                      	<a href="#request.self#?fuseaction=prod.popup_upd_ssh_manual&master_plan_id=#master_plan_id#&master_alt_plan_id=#master_alt_plan_id#&islem_id=#islem_id#">
                          	<img src="/images/care_plus.gif" alt="SSH <cf_get_lang dictionary_id='597.Emir Oluştur'>" border="0">                                	
                     	</a>
                        &nbsp;&nbsp;
                 	</cfif>
                    <cfif menu_select.FROM_UP_P_ORDER eq 1>
                    	<a href="#request.self#?fuseaction=prod.popup_ezgi_upd_parca_manual&master_plan_id=#master_plan_id#&master_alt_plan_id=#master_alt_plan_id#&islem_id=#islem_id#">
                          	<img src="/images/messenger4.gif" title="<cf_get_lang dictionary_id='485.Plan İhtiyacı'>" alt="<cf_get_lang dictionary_id='485.Plan İhtiyacı'>" border="0">                                	
                      	</a>
                        &nbsp;&nbsp;
                 	</cfif>
                    <cfif menu_select.P_ORDER_FREE eq 1>
                    	<a href="#request.self#?fuseaction=prod.popup_ezgi_upd_parca_1_manual&master_plan_id=#master_plan_id#&master_alt_plan_id=#master_alt_plan_id#&islem_id=#islem_id#">
                          	<img src="/images/messenger7.gif" title="<cf_get_lang dictionary_id='503.Optimum İhtiyaç'>" alt="<cf_get_lang dictionary_id='503.Optimum İhtiyaç'>" border="0">
                      	</a>
                        &nbsp;&nbsp;
                 	</cfif>
                    <cfif menu_select.FROM_DEMAND eq 1>
                    	<a href="#request.self#?fuseaction=prod.popup_ezgi_upd_parca_manual&master_plan_id=#master_plan_id#&master_alt_plan_id=#master_alt_plan_id#&islem_id=#islem_id#&from_demand=1">
                          	<img src="/images/messenger8.gif" title="<cf_get_lang dictionary_id='533.Planlama Talebinden Ekleme'>" alt="<cf_get_lang dictionary_id='533.Planlama Talebinden Ekleme'>" border="0">
                      	</a>
                        &nbsp;&nbsp;
                 	</cfif>
                    <cfif menu_select.P_ORDER_FROM_ORDER eq 1>
                     	<a href="#request.self#?fuseaction=prod.ezgi_tracking&master_plan_id=#master_plan_id#&master_alt_plan_id=#master_alt_plan_id#&islem_id=#islem_id#">
                         	<img src="/images/messenger3.gif" title="<cf_get_lang dictionary_id='534.Satış Siparişinden Ekleme'>" alt="<cf_get_lang dictionary_id='534.Satış Siparişinden Ekleme'>" border="0">                                	
                    	</a>
                        &nbsp;&nbsp;
                	</cfif>
                    <cfif menu_select.TOPLU_P_ORDERS eq 1>
                     	<a href="#request.self#?fuseaction=prod.add_ezgi_prod_order&master_alt_plan_id=#master_alt_plan_id#&is_collacted=1&islem_id=#islem_id#">
                        	<img src="/images/messenger5.gif" title="<cf_get_lang dictionary_id='535.Serbest Ekleme'>" alt="<cf_get_lang dictionary_id='535.Serbest Ekleme'>" border="0">
                       	</a>
                        &nbsp;&nbsp;
                	</cfif>
                    <a href="#request.self#?fuseaction=prod.add_ezgi_prod_order_rework&master_alt_plan_id=#master_alt_plan_id#&is_collacted=1&islem_id=#islem_id#">
                    	<img src="/images/arrow_up.png" alt="<cf_get_lang dictionary_id='38134.Rework'>" title="<cf_get_lang dictionary_id='38134.Rework'>" border="0">
                 	</a>&nbsp;&nbsp;
                   	<a href="javascript://" onClick="grupla(-2);"><img src="/images/print3.gif" alt="<cf_get_lang dictionary_id='57474.Yazdır'>" title="<cf_get_lang dictionary_id='57474.Yazdır'>" border="0"></a>&nbsp;&nbsp;
             	</cfoutput>
            </cfsavecontent>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id="638.İlişkili Üretim Emirleri"></cfsavecontent>
    		<cf_box title="#title#" scroll="1" right_images="#right_menu#">
      			<cf_grid_list sort="1">
                	<thead>
                        <tr>
                            <th style="width:30px;text-align:center; height:20px" class="header_icn_txt"><cf_get_lang dictionary_id='58577.Sira'></th>
                            <input type="hidden" name="islem" value="1" />
                     		<th width="60"><cf_get_lang dictionary_id='29474.Emir No'></th>
                            <th width="60">Lot No</th>
                          	<th width="70"><cf_get_lang dictionary_id='58211.Sipariş No'></th>
                         	<th width="60"><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></th>
                          	<th width="60"><cf_get_lang dictionary_id='290.Termin Tarihi'></th>
                        	<cfif menu_select.IS_CONTROL eq 1 and menu_select.SIRA eq 1>
                             	<th ><cf_get_lang dictionary_id='1035.Cari Ünvan'></th>
                          	<cfelse>
                           		<th ><cf_get_lang dictionary_id='595.İlişkili Üst Emir'></th>
                         	</cfif> 
                            <th width="50"><cf_get_lang dictionary_id='40235.Sipariş Miktarı'></th>
                         	<th ><cf_get_lang dictionary_id='57657.Ürün'></th>
                          	<th width="90" ><cf_get_lang dictionary_id='57647.Spec'></th>
                          	<th width="60"><cf_get_lang dictionary_id='58859.Süreç'></th>
                         	<th width="80" align="center"><cf_get_lang dictionary_id='36604.Hedef Başlangıç'><br /><cf_get_lang dictionary_id='36606.Hedef Bitiş'></th>
                          	<th width="50" align="center"><cf_get_lang dictionary_id='57635.Miktar'></th>
                          	<th width="50" align="center"><cf_get_lang dictionary_id='58984.Puan'></th>
                           	<cfif menu_select.IS_CONTROL eq 1>
                             	<th width="20" align="center"><cf_get_lang dictionary_id='1036.OPT'></th>
                              	<th width="20" align="center"><cf_get_lang dictionary_id='1037.MLZ'></th>
                          	</cfif>
                         	<th width="1%"></th>
                           	<th width="1%" align="center"></th>
                          	<th width="1%" align="center">
                              	<input type="checkbox" alt="<cf_get_lang dictionary_id ='206.Hepsini Seç'>" onClick="grupla(-1);">
                         	</th>
						</tr>
                  	</thead>
                    <tbody>
                    	<cfif get_prod_order.recordcount>
                            <cfset row_p_order_id = ''>
                         	<cfoutput query="get_prod_order">
                            	<cfif IS_SERIAL_NO eq 1>
                                	<cfquery name="get_order" datasource="#dsn3#">
                                     	SELECT DISTINCT 
                                        	CASE
                                                WHEN O.COMPANY_ID IS NOT NULL THEN
                                                   (
                                                    SELECT     
                                                        NICKNAME
                                                    FROM         
                                                        #dsn_alias#.COMPANY
                                                    WHERE     
                                                        COMPANY_ID = O.COMPANY_ID
                                                    )
                                                WHEN O.CONSUMER_ID IS NOT NULL THEN      
                                                    (	
                                                    SELECT     
                                                        CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                                                    FROM         
                                                        #dsn_alias#.CONSUMER
                                                    WHERE     
                                                        CONSUMER_ID = O.CONSUMER_ID
                                                    )
                                                WHEN O.EMPLOYEE_ID IS NOT NULL THEN
                                                    (
                                                    SELECT     
                                                        EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
                                                    FROM         
                                                        #dsn_alias#.EMPLOYEES
                                                    WHERE     
                                                        EMPLOYEE_ID = O.EMPLOYEE_ID
                                                    )
                                                ELSE      
                                                        'Stok Üretim'
                                            END AS UNVAN,
                                        	O.ORDER_NUMBER, 
                                            O.ORDER_ID, 
                                            O.ORDER_DATE, 
                                            O.ORDER_STATUS, 
                                            O.DELIVERDATE,
                                            ORR.QUANTITY,
                                            ORR.PRODUCT_NAME2
										FROM     
                                        	PRODUCTION_ORDERS_ROW AS E INNER JOIN
                  							ORDER_ROW AS ORR ON E.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                  							ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID
										WHERE  
                                        	E.PRODUCTION_ORDER_ID = #get_prod_order.P_ORDER_ID# AND 
                                            O.ORDER_STATUS = 1 AND
                                            O.PURCHASE_SALES = 1
										ORDER BY 
                                        	O.ORDER_ID
                                	</cfquery>
                                    <cfset row_span = 1>
                                    <cfset say =1>
                                <cfelse>
									<cfif row_p_order_id neq P_ORDER_ID>
                                        <cfquery name="get_group" dbtype="query">
                                            SELECT
                                                P_ORDER_ID
                                            FROM
                                                get_prod_order
                                            WHERE
                                                P_ORDER_ID =#get_prod_order.P_ORDER_ID#
                                        </cfquery>
                                        <cfset say = get_group.recordcount>
                                        <cfset row_span = 1>
                                    <cfelse>
                                        <cfset row_span = 0>
                                    </cfif> 
                                    <cfset get_order.PRODUCT_NAME2 = ''>  
                                </cfif>
                           		<tr height="25" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                                 	<td style="text-align:right">
                                    	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.popup_list_ezgi_master_sub_plan_manual_history&upd=#P_ORDER_ID#','list');">
                                    		#currentrow#
                                        </a>
                                    </td>
                                    <cfif row_span eq 1>
                                		<td rowspan="#say#" align="center"><a href="#request.self#?fuseaction=prod.order&event=upd&upd=#P_ORDER_ID#" class="tableyazi" target="_blank">#P_ORDER_NO#</a></td>
                                        <td rowspan="#say#" style="text-align:center">#LOT_NO#</td>
                                    </cfif>
                                 	<cfif is_instalment eq 1>
										<cfset page_type = 'list_order_instalment&event=upd'>
                                 	<cfelse>
                                   		<cfset page_type = 'list_order&event=upd'>
                                 	</cfif>
                                 	<td align="center" title="<cfif IS_SERIAL_NO eq 1>#get_order.PRODUCT_NAME2#<cfelse>#get_prod_order.PRODUCT_NAME2#</cfif>">
                                    	<cfif IS_SERIAL_NO eq 1>
                                        	<cfif get_order.recordcount>
                                        		<a href="#request.self#?fuseaction=sales.#page_type#&order_id=#get_order.ORDER_ID#" class="tableyazi" target="_blank">#get_order.ORDER_NUMBER#</a>
                                                <cfif get_order.recordcount gt 1><span style="color:red">...</span></cfif>
                                            </cfif>
                                        <cfelse>
                                    		<a href="#request.self#?fuseaction=sales.#page_type#&order_id=#ORDER_ID#" class="tableyazi" target="_blank">#ORDER_NUMBER#</a>
                                        </cfif>
                                  	</td>
                                	<td style="text-align:center">
                                    	<cfif IS_SERIAL_NO eq 1>
                                        	<cfif get_order.recordcount>
                                        		#DateFormat(get_order.ORDER_DATE,dateformat_style)#
                                            </cfif>
                                        <cfelse>
                                    		#DateFormat(ORDER_DATE,dateformat_style)#
                                        </cfif>
                                    </td>
                                  	<td style="text-align:center">
                                    	<cfif IS_SERIAL_NO eq 1>
                                        	<cfif get_order.recordcount>
                                        		#DateFormat(get_order.DELIVERDATE,dateformat_style)#
                                            </cfif>
                                        <cfelse>
                                    		#DateFormat(DELIVER_DATE,dateformat_style)#
                                        </cfif>
                                    </td>
                                   	<cfif menu_select.IS_CONTROL eq 1>
                                    	<cfif IS_SERIAL_NO eq 1>
                                     		<td align="left"><Cfif len(get_order.unvan)>#get_order.unvan#<cfelse>Stok Üretim</Cfif></td>
                                      	<cfelse>
                                        	<td align="left">#unvan#</td>
                                        </cfif>
                                  	<cfelse>
                                     	<td align="left">#UST_EMIR#</td>
                                 	</cfif>
                                    <td align="right">
                                    	<cfif IS_SERIAL_NO eq 1>
                                        	#TlFormat(get_order.QUANTITY,2)#
                                        <cfelse>
                                    		#TlFormat(ORDER_QUANTITY,2)#
                                        </cfif>
                                        </td>
                                    <cfif row_span eq 1>
										<cfset row_p_order_id = P_ORDER_ID>
                                        <td rowspan="#say#"><a href="#request.self#?fuseaction=prod.list_product_tree&event=upd&stock_id=#stock_id#" class="tableyazi" target="_blank">#product_name#</a></td>
                                        <td rowspan="#say#" align="center" title="#SPECT_VAR_NAME#">
                                            <cfif len(SPECT_VAR_ID)>
                                                <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_upd_spect&id=#SPECT_VAR_ID#&stock_id=#stock_id#','list');" class="tableyazi">#spec_main_id#-#spect_var_id#</a>	
                                            </cfif>
                                        </td>
                                 		<td rowspan="#say#" align="center">#STAGE#</td>
                                 		<td rowspan="#say#" align="center" nowrap>#DateFormat(start_date,dateformat_style)#<br />#DateFormat(finish_date,dateformat_style)#</td>
                                    
                                        <td rowspan="#say#" style="text-align:right">#TlFormat(QUANTITY,2)#</td>
                                        <td rowspan="#say#" style="text-align:right">#TlFormat(P_ORDER_POINT,2)#</td>
                                        <cfif menu_select.IS_CONTROL eq 1>
                                            <cfquery name="get_kontrol_0" datasource="#dsn3#"> <!---Optimizasyona ve Var-yok a giren emirler soruluyor--->
                                                SELECT DISTINCT 
                                                    POS.STOCK_ID, 
                                                    POS.AMOUNT,
                                                    EMC.STATUS
                                                FROM         
                                                    EZGI_METARIAL_CONTROL AS EMC WITH (NOLOCK) INNER JOIN
                                                    PRODUCTION_ORDERS_STOCKS AS POS WITH (NOLOCK) ON EMC.POR_STOCK_ID = POS.POR_STOCK_ID
                                                WHERE     
                                                    <cfif get_default.CONTROL_METHOD eq 1 or ORDER_ID eq 0>
                                                        EMC.LOT_NO = '#lot_no#'
                                                    <cfelseif get_default.CONTROL_METHOD eq 2 and ORDER_ID gt 0>
                                                        EMC.ORDER_ID = #order_id# AND
                                                        POS.POR_STOCK_ID IN 
                                                                                (
                                                                                    SELECT        
                                                                                        POSS.POR_STOCK_ID
                                                                                    FROM           
                                                                                        PRODUCTION_ORDERS_ROW AS PORR INNER JOIN
                                                                                        PRODUCTION_ORDERS_STOCKS AS POSS ON PORR.PRODUCTION_ORDER_ID = POSS.P_ORDER_ID
                                                                                    WHERE        
                                                                                        PORR.ORDER_ID = #order_id#  AND 
                                                                                        PORR.TYPE = 1
                                                                                
                                                                                )
                                                    </cfif>
                                            </cfquery>
                                            <cfquery name="get_kontrol_1" dbtype="query"> <!---Var Denilenler Bulunuyor--->
                                                SELECT STOCK_ID,AMOUNT FROM get_kontrol_0 WHERE STATUS = 1
                                            </cfquery>
                                            <cfquery name="get_kontrol_2" dbtype="query"> <!---Yok Denilenler Bulunuyor--->
                                                SELECT STOCK_ID,AMOUNT FROM get_kontrol_0 WHERE STATUS = 2
                                            </cfquery>
                                            <cfquery name="get_ezgi_metarial_control" dbtype="query"> <!---Yok Denilenler Guruplanıyor--->
                                                SELECT STOCK_ID, SUM(AMOUNT) AS AMOUNT FROM get_kontrol_2 GROUP BY STOCK_ID
                                            </cfquery>
                                            <cfquery name="get_ezgi_metarial_control_0" dbtype="query"> <!---Optimizasyondan Geçen heşey guruplanıyor--->
                                                SELECT STOCK_ID,SUM(AMOUNT) AS AMOUNT FROM get_kontrol_0 GROUP BY STOCK_ID
                                            </cfquery>
                                            <cfloop query="get_ezgi_metarial_control_0">
                                                <cfset 'CONTROL_#get_prod_order.lot_no#_#get_ezgi_metarial_control_0.STOCK_ID#'= get_ezgi_metarial_control_0.AMOUNT>
                                            </cfloop>
                                            <cfquery name="get_ic_talep" datasource="#dsn3#">
                                                SELECT     
                                                    I.INTERNAL_NUMBER, 
                                                    EMR.ACTION_ID, 
                                                    IR.STOCK_ID
                                                FROM         
                                                    EZGI_METARIAL_RELATIONS AS EMR WITH (NOLOCK) INNER JOIN
                                                    INTERNALDEMAND AS I WITH (NOLOCK) ON EMR.ACTION_ID = I.INTERNAL_ID INNER JOIN
                                                    INTERNALDEMAND_ROW AS IR WITH (NOLOCK) ON I.INTERNAL_ID = IR.I_ID
                                                WHERE     
                                                    EMR.TYPE = 1 AND 
                                                    <cfif get_default.CONTROL_METHOD eq 1 or ORDER_ID eq 0>
                                                        EMR.LOT_NO = '#lot_no#' AND 
                                                    <cfelseif get_default.CONTROL_METHOD eq 2 and ORDER_ID gt 0>
                                                        EMR.LOT_NO = '#ORDER_NUMBER#' AND 
                                                    </cfif>
                                                    IR.STOCK_ID IN 
                                                                    (
                                                                        SELECT     
                                                                            STOCK_ID
                                                                        FROM         
                                                                            STOCKS
                                                                        WHERE     
                                                                            STOCK_CODE LIKE N'#get_default.FABRIC_CAT#%'
                                                                    )
                                            </cfquery>
                                            <cfquery name="get_period" datasource="#dsn3#">
                                                SELECT     
                                                    PERIOD_ID
                                                FROM         
                                                    EZGI_METARIAL_RELATIONS WITH (NOLOCK)
                                                WHERE     
                                                    TYPE = 2 AND 
                                                    <cfif get_default.CONTROL_METHOD eq 1 or get_prod_order.ORDER_ID eq 0>
                                                        LOT_NO = '#lot_no#' 
                                                    <cfelseif get_default.CONTROL_METHOD eq 2 and get_prod_order.ORDER_ID gt 0>
                                                        ORDER_ID = #get_prod_order.ORDER_ID#
                                                    </cfif>
                                            </cfquery>
                                            <cfset teslim = 0>
                                            <cfset teslim_1 = 0>
                                            <cfif get_period.recordcount>
                                                <cfset period_list = ValueList(get_period.PERIOD_ID)>
                                                <cfquery name="get_period_ship_dsns" datasource="#dsn3#">
                                                    SELECT PERIOD_YEAR,OUR_COMPANY_ID,PERIOD_ID FROM #dsn_alias#.SETUP_PERIOD WHERE PERIOD_ID IN (#period_list#)
                                                </cfquery>
                                            </cfif>
                                            <cfif isdefined('period_list') and listlen(period_list) and period_list neq 0>
                                                <cfquery name="get_control_ambar_fis" datasource="#DSN3#">
                                                    SELECT 
                                                        STOCK_ID,
                                                        SUM(AMOUNT) AMOUNT
                                                    FROM
                                                        (
                                                            <cfloop query="get_period_ship_dsns">
                                                                SELECT     
                                                                    SFR.STOCK_ID, 
                                                                    SFR.AMOUNT
                                                                FROM         
                                                                    EZGI_METARIAL_RELATIONS WITH (NOLOCK) INNER JOIN
                                                                    #dsn#_#get_period_ship_dsns.PERIOD_YEAR#_#get_period_ship_dsns.OUR_COMPANY_ID#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON EZGI_METARIAL_RELATIONS.ACTION_ID = SFR.FIS_ID
                                                                WHERE     
                                                                    EZGI_METARIAL_RELATIONS.TYPE = 2 AND 
                                                                    EZGI_METARIAL_RELATIONS.PERIOD_ID = #get_period_ship_dsns.period_id# AND 
                                                                    <cfif get_default.CONTROL_METHOD eq 1 or get_prod_order.ORDER_ID eq 0>
                                                                        EZGI_METARIAL_RELATIONS.LOT_NO = '#get_prod_order.lot_no#' AND
                                                                    <cfelseif get_default.CONTROL_METHOD eq 2 and get_prod_order.ORDER_ID gt 0>
                                                                        EZGI_METARIAL_RELATIONS.ORDER_ID = #get_prod_order.ORDER_ID# AND
                                                                    </cfif> 
                                                                    SFR.STOCK_ID IN (
                                                                                    SELECT     
                                                                                        STOCK_ID
                                                                                    FROM         
                                                                                        STOCKS
                                                                                    WHERE     
                                                                                        STOCK_CODE LIKE N'#get_default.FABRIC_CAT#%'
                                                                                    )
                                                                <cfif currentrow neq get_period_ship_dsns.recordcount> UNION ALL </cfif> 
                                                            </cfloop>
                                                        ) TBL
                                                    GROUP BY
                                                        STOCK_ID 			
                                                </cfquery>
                                                <cfif get_control_ambar_fis.recordcount>
                                                    <cfif get_control_ambar_fis.recordcount neq get_ezgi_metarial_control_0.recordcount>
                                                        <cfset teslim = 2>		
                                                    <cfelse>
                                                        <cfset teslim = 1>
                                                    </cfif>
                                                <cfelse>
                                                    <cfset teslim = 0>
                                                </cfif>
                                            </cfif>
                                            <td rowspan="#say#" align="center" title="#PRODUCT_NAME2#">
                                                <cfif get_kontrol_0.recordcount eq 0>
                                                    <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_metarial_control&lot_no=#LOT_NO#&master_plan_id=#attributes.master_plan_id#','wide');"> 
                                                        <img src="/images/production/offlineuser.gif" tittle="<cf_get_lang dictionary_id='516.Optimizasyon Onay Verilmedi'>" border="0">
                                                    </a>
                                                <cfelse>
                                                    <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_metarial_control&lot_no=#LOT_NO#&master_plan_id=#attributes.master_plan_id#','wide');"> 
                                                         <img src="/images/production/onlineuser_1.gif" tittle="<cf_get_lang dictionary_id='517.Optimizasyon Onay Verildi'>">
                                                    </a>
                                                </cfif> 
                                            </td>
                                            <td rowspan="#say#" align="center">
                                                <cfif get_kontrol_0.recordcount>
                                                    <cfif get_kontrol_1.recordcount neq get_kontrol_0.recordcount>	
                                                        <cfif get_ic_talep.recordcount eq 0>
                                                            <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_metarial_control&lot_no=#LOT_NO#&master_plan_id=#attributes.master_plan_id#','wide');"> 
                                                                <img src="/images/production/offlineuser.gif" tittle="<cf_get_lang dictionary_id='518.İç Talep Verilmedi'>">
                                                            </a>
                                                        <cfelse>
                                                            <cfif get_ic_talep.recordcount neq get_ezgi_metarial_control.recordcount>
                                                                <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_metarial_control&lot_no=#LOT_NO#&master_plan_id=#attributes.master_plan_id#','wide');"> 
                                                                    <img src="/images/production/onlineuser.gif" tittle="<cf_get_lang dictionary_id='519.İç Talep Eksik Verildi'>">
                                                                </a>
                                                            <cfelse>
                                                                <cfif teslim eq 0>
                                                                    <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_metarial_ambar_fisi&lot_no=#LOT_NO#&master_plan_id=#attributes.master_plan_id#','page');"> 
                                                                        <img src="/images/production/onlineuser_2.gif" tittle="<cf_get_lang dictionary_id='520.İç Talep Tam Verildi'>">
                                                                    </a>
                                                                <cfelseif teslim eq 1>
                                                                    <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_metarial_ambar_fisi&lot_no=#LOT_NO#&master_plan_id=#attributes.master_plan_id#','page');">
                                                                        <img src="/images/production/onlineuser_1.gif" tittle="<cf_get_lang dictionary_id='521.Tam Ambar Fişi'>">
                                                                    </a>
                                                                <cfelseif teslim eq 2>
                                                                    <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_metarial_ambar_fisi&lot_no=#LOT_NO#&master_plan_id=#attributes.master_plan_id#','page');">
                                                                        <img src="/images/production/onlineuser_3.gif" tittle="<cf_get_lang dictionary_id='522.Eksik Ambar Fişi'>">
                                                                    </a>
                                                                </cfif>      
                                                            </cfif>
                                                        </cfif>
                                                    <cfelse>
                                                        <cfif teslim eq 0>
                                                            <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_metarial_ambar_fisi&lot_no=#LOT_NO#&master_plan_id=#attributes.master_plan_id#','page');"> 
                                                                <img src="/images/production/onlineuser_2.gif" tittle="<cf_get_lang dictionary_id='523.Kumaşlar Mevcut'>">
                                                            </a>
                                                        <cfelseif teslim eq 1>
                                                            <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_metarial_ambar_fisi&lot_no=#LOT_NO#&master_plan_id=#attributes.master_plan_id#','page');">
                                                                <img src="/images/production/onlineuser_1.gif" tittle="<cf_get_lang dictionary_id='521.Tam Ambar Fişi'>">
                                                            </a>
                                                        <cfelseif teslim eq 2>
                                                            <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_metarial_ambar_fisi&lot_no=#LOT_NO#&master_plan_id=#attributes.master_plan_id#','page');">
                                                                <img src="/images/production/onlineuser_3.gif" tittle="<cf_get_lang dictionary_id='522.Eksik Ambar Fişi'>">
                                                            </a>
                                                        </cfif>
                                                    </cfif>
                                                </cfif>              
                                            </td>
                                        </cfif>
                                        <td rowspan="#say#" style="text-align:center" <cfif menu_select.IS_COLLECT><cfif ALT_EMIR gt 0>bgcolor="orange"</cfif></cfif>>
                                            <cfif IS_STAGE eq 4>
                                                <cfif IS_GROUP_LOT eq 1>
                                                    <img src="/images/g_blue_glob.gif" title="<cf_get_lang dictionary_id ='36892.Gruplandı Fakat Operatöre Gönderilmedi'>">
                                                <cfelse>
                                                    <img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id ='476.Başlamadı'>">
                                                </cfif>       
                                            <cfelseif IS_STAGE eq 0>
                                                <img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id ='36891.Operatöre Gönderildi'>">
                                            <cfelseif IS_STAGE eq 1>
                                                <img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id ='398.Başladı'>">
                                            <cfelseif IS_STAGE eq 2>
                                                <img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id ='305.Bitti'>">
                                            <cfelseif IS_STAGE eq 3>
                                                <img src="/images/grey_glob.gif" title="<cf_get_lang dictionary_id ='476.Başlamadı'>">
                                            </cfif>
                                        </td>
                                        <td rowspan="#say#" style="text-align:center">
                                            <a href="#request.self#?fuseaction=prod.order&event=upd&upd=#P_ORDER_ID#" class="tableyazi" target="_blank"> 
                                                <img src="/images/update_list.gif" alt="<cf_get_lang dictionary_id='36436.Üretim Emri Düzenle'>" border="0">
                                            </a>
                                        </td>
                                        <td rowspan="#say#" style="text-align:center" <cfif PRINT_COUNT gt 0>bgcolor="orange"</cfif>>
                                            <!---<cfif IS_STAGE neq 1 and IS_STAGE neq 2>--->
                                                <input type="checkbox" name="select_production" value="#P_ORDER_ID#">
                                            <!---<cfelse>
                                                &nbsp;
                                            </cfif>--->
                                        </td>
                                    </cfif>
                           		</tr>
                         	</cfoutput>
                    	<cfelse>
                         	<cfif menu_select.IS_CONTROL eq 1>
                              	<cfset colspan_e = 19>
                          	<cfelse>
                            	<cfset colspan_e = 18>
                          	</cfif>
                          	<tr>
                           		<td class="color-row" colspan="<cfoutput>#colspan_e#</cfoutput>"> <cf_get_lang dictionary_id='602.Üretim Emri Giriniz'></td>
                        	</tr>
                    	</cfif>
                    </tbody>
              	</cf_grid_list>	
          	</cf_box>
     	</cfform>
            <cf_box>
                <table style="width:100%">
                    <tr>
                        <td style="width:55%" align="left">
                            <cfset b = 1>
                            <select name="master_alt_plan" id="master_alt_plan" style="width:490px;font-weight:bold; height:25px" onchange="masterplan_change(this.value)">
                                <option value=""><cf_get_lang dictionary_id='662.Alt Plan Seçiniz'></option>
                                <cfoutput query="get_w">
                                    <option value="#MASTER_ALT_PLAN_ID#,#MASTER_PLAN_ID#,#PROCESS_ID#"> (#MASTER_PLAN_NUMBER#) - #MASTER_ALT_PLAN_NO# - <cfif PLAN_TYPE eq 0>#Dateformat (PLAN_START_DATE, dateformat_style)# - #Dateformat (PLAN_FINISH_DATE, dateformat_style)# - #W_POINT# / #Tlformat(TOTAL_POINT,2)# - #PLAN_DETAIL#<cfelse><strong>Torba Plan - #PLAN_DETAIL#</strong></font></cfif>
                                    </option>
                                </cfoutput>
                            </select>
                            <cfif menu_select.is_movie eq 1>
                                <button  value="" name="gonder" onClick="grupla(-5);" style="height:25px; width:120px">&nbsp;<cf_get_lang dictionary_id='603.Alt Plana Gönder'></button>
                            </cfif>
                            <button  value="" name="git" onClick="grupla(-6);" style="height:25px; width:110px">&nbsp;<cf_get_lang dictionary_id='604.Alt Plana Git'></button><br />
                            <span style="display:none" id="reason_for_transfer_">
                            	<select name="reason_for_transfer" id="reason_for_transfer" style="width:490px;height:25px; font-style:italic">
                                    <option value=""><cf_get_lang dictionary_id='60743.Değişiklik Nedeni'></option>
                                    <cfoutput query="transfer_for_reason">
                                        <option value="#REASON_FOR_TRANSFER_ID#">#REASON_FOR_TRANSFER#</option>
                                    </cfoutput>
                                </select>	
                            </span>
                        </td>
                        <cfif menu_select.IS_CONTROL eq 1><cfset colspan_e = 10><cfelse><cfset colspan_e = 9></cfif>
                        <td style="width:45%" align="right">
                            <cfif menu_select.IS_DELETE>
                                <button  value="" name="git" onClick="grupla(-10);" style="height:25px; width:70px">&nbsp;<cf_get_lang dictionary_id='57463.Sil'></button>
                            </cfif>
                            <cfif menu_select.IS_GROUP and p_order_is_group_control.recordcount>
                                <button  value="" name="different" onClick="grupla(-4);" style="height:25px; width:60px">&nbsp;<cf_get_lang dictionary_id='36815.Grupla'></button>
                            <cfelse>
                                <cfif menu_select.IS_COLLECT and (order_related_control.recordcount or order_group_control.recordcount)>
                                    <button  value="" name="different_1" onClick="grupla(-7);" style="height:25px; width:90px">&nbsp;<cf_get_lang dictionary_id='605.Emirleri Birleştir'></button>
                                </cfif>
                                <button  value="" name="different_2" onClick="grupla(-3);" style="height:25px; width:110px">&nbsp;<cf_get_lang dictionary_id='58834.İstasyon'> M.İ</button>
                                <cfif get_w.SIRA eq 1>
                                    <button  value="" name="different_3" onClick="grupla(-8);" style="height:25px; width:140px">&nbsp;<cf_get_lang dictionary_id='608.İlişkili Alt Emirler'> M.İ</button>
                                    <button  value="" name="different_4" onClick="metarial(-1);" style="height:25px; width:140px">&nbsp;<cf_get_lang dictionary_id='609.İlişkili Alt Planlar'> M.İ</button>
                                    <cfif get_default.CONTROL_METHOD eq 1>
                                    	<button  value="" name="different_5" onClick="grupla(-9);" style="height:25px; width:100px">&nbsp;<cf_get_lang dictionary_id='583.Optimizasyon'></button>
                                    </cfif>
                                </cfif>      
                            </cfif>
                        </td>
                    </tr>
                </table>
            </cf_box>
      	
 	</cf_box>
</div>
<script language="javascript">
	function grupla(type)
	{
		p_order_id_list = '';
		chck_leng = document.getElementsByName('select_production').length;
		for(ci=0;ci<chck_leng;ci++)
		{
			var my_objets = document.all.select_production[ci];
			if(chck_leng == 1)
				var my_objets =document.all.select_production;
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
		if(type == -6)
		{
			chng_master_alt_plan=document.getElementById('master_alt_plan').value;
			master_plan_id = list_getat(chng_master_alt_plan,2);
			master_alt_plan_id = list_getat(chng_master_alt_plan,1);
			islem_id = list_getat(chng_master_alt_plan,3);
			window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=prod.upd_ezgi_master_sub_plan_manual&master_plan_id='+master_plan_id+'&master_alt_plan_id='+master_alt_plan_id+'&islem_id='+islem_id;	
		}
		if(list_len(p_order_id_list,','))
		{
			if(type == -2)
				{
					var master_alt_plan_id=document.form_master_alt_plan.master_alt_plan_id.value;
					var master_plan_id=document.form_master_alt_plan.master_plan_id.value;
					var islem_id=document.form_master_alt_plan.islem_id.value;
					windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_print_files&print_type=281</cfoutput>&iid='+p_order_id_list+'&master_alt_plan_id='+master_alt_plan_id,'page');
				}
	
			else if(type == -3)
				{
					var master_alt_plan_id=document.form_master_alt_plan.master_alt_plan_id.value;
					var master_plan_id=document.form_master_alt_plan.master_plan_id.value;
					var islem_id=document.form_master_alt_plan.islem_id.value;
					windowopen('<cfoutput>#request.self#?fuseaction=prod.emptypopup_get_ezgi_sub_plan_metarial&type=1</cfoutput>&p_order_id_list='+p_order_id_list+'&islem_id='+islem_id+'&master_plan_id='+master_plan_id+'&master_alt_plan_id='+master_alt_plan_id,'longpage');
				}
				else if(type == -8)
				{
					var master_alt_plan_id=document.form_master_alt_plan.master_alt_plan_id.value;
					var master_plan_id=document.form_master_alt_plan.master_plan_id.value;
					var islem_id=document.form_master_alt_plan.islem_id.value;
					windowopen('<cfoutput>#request.self#?fuseaction=prod.emptypopup_get_ezgi_sub_plan_metarial&type=2</cfoutput>&p_order_id_list='+p_order_id_list+'&islem_id='+islem_id+'&master_plan_id='+master_plan_id+'&master_alt_plan_id='+master_alt_plan_id,'longpage');
				}
			else if(type == -4)
				{
					var master_alt_plan_id=document.form_master_alt_plan.master_alt_plan_id.value;
					var master_plan_id=document.form_master_alt_plan.master_plan_id.value;
					var islem_id=document.form_master_alt_plan.islem_id.value;
					window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_upd_ezgi_p_order_operator&p_order_id_list='+p_order_id_list+'&islem_id='+islem_id+'&master_plan_id='+master_plan_id+'&master_alt_plan_id='+master_alt_plan_id;
				}
			else if(type == -5)
				{
					var reason_id=document.getElementById('reason_for_transfer').value;
					if(reason_id =='')
					{
						alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='60743.Değişiklik Nedeni'>");
						document.getElementById('reason_for_transfer_').focus();
						return false;
					}
					else
					{
						var master_alt_plan_id=document.form_master_alt_plan.master_alt_plan_id.value;
						var master_plan_id=document.form_master_alt_plan.master_plan_id.value;
						var islem_id=document.form_master_alt_plan.islem_id.value;
						chng_master_alt_plan=list_getat(document.getElementById('master_alt_plan').value,1);
						AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_upd_ezgi_p_order_send&reason_id='+reason_id+'&p_order_list='+p_order_id_list+'&chng_master_alt_plan='+chng_master_alt_plan+'&master_alt_plan_id='+master_alt_plan_id+'','groups_p',1);
					}
		
				}
			else if(type == -7)
				{
					var answer = confirm("<cf_get_lang dictionary_id='607.Seçtiğiniz Emirler Türüne Göre Birleştirilecek.'> <cf_get_lang dictionary_id='58588.Emin misiniz ?'>")
					if (answer)
					{
					var master_alt_plan_id=document.form_master_alt_plan.master_alt_plan_id.value;
					var master_plan_id=document.form_master_alt_plan.master_plan_id.value;
					var islem_id=document.form_master_alt_plan.islem_id.value;
					window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_upd_ezgi_p_order_group&p_order_id_list='+p_order_id_list+'&islem_id='+islem_id+'&master_plan_id='+master_plan_id+'&master_alt_plan_id='+master_alt_plan_id;
					}
				}
			else if(type == -9)
			{
				var master_plan_id=document.form_master_alt_plan.master_plan_id.value;
				windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_add_ezgi_metarial_control&p_order_id_list='+p_order_id_list+'&master_plan_id='+master_plan_id,'wide');
			}
			else if(type == -10)
			{
				var answer1 = confirm("<cf_get_lang dictionary_id='606.Seçtiğiniz Emirler Silinecek.'> <cf_get_lang dictionary_id='58588.Emin misiniz ?'>")
				if (answer1)
				{
					var master_alt_plan_id=document.form_master_alt_plan.master_alt_plan_id.value;
					var master_plan_id=document.form_master_alt_plan.master_plan_id.value;
					var islem_id=document.form_master_alt_plan.islem_id.value;
					window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_del_ezgi_p_order_group&p_order_id_list='+p_order_id_list+'&islem_id='+islem_id+'&master_plan_id='+master_plan_id+'&master_alt_plan_id='+master_alt_plan_id;
				}
			}
			else if(type == -11)
			{
				var master_alt_plan_id=document.form_master_alt_plan.master_alt_plan_id.value;
				var master_plan_id=document.form_master_alt_plan.master_plan_id.value;
				var islem_id=document.form_master_alt_plan.islem_id.value;
				windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_dsp_ezgi_iflow_product_metarial_need&iid='+p_order_id_list+'&master_alt_plan_id=#master_alt_plan_id#</cfoutput>','longpage');
			}
		}
	}
	function metarial(type)
	{
		if(type == -1)
		{
			var master_alt_plan_id=document.form_master_alt_plan.master_alt_plan_id.value;
			var master_plan_id=document.form_master_alt_plan.master_plan_id.value;
			var islem_id=document.form_master_alt_plan.islem_id.value;
			windowopen('<cfoutput>#request.self#?fuseaction=prod.emptypopup_get_ezgi_sub_plan_metarial&type=4</cfoutput>&islem_id='+islem_id+'&master_plan_id='+master_plan_id+'&master_alt_plan_id='+master_alt_plan_id,'longpage');
			
		}
	}
	function masterplan_change(master_alt_plan_id)
	{
		if(<cfoutput>#attributes.master_alt_plan_id#</cfoutput> != master_alt_plan_id)
		{
			document.getElementById('reason_for_transfer_').style.display='';	
		}
	}
	function kontrol()
	{
		if((document.getElementById('master_alt_plan_start_date').value != "") && (document.getElementById('master_alt_plan_finish_date').value != ""))
		return time_check(document.getElementById('master_alt_plan_start_date'), document.getElementById('master_alt_plan_start_h'), document.getElementById('master_alt_plan_start_m'), document.getElementById('master_alt_plan_finish_date'),  document.getElementById('master_alt_plan_finish_h'), document.getElementById('master_alt_plan_finish_m'), "<cf_get_lang dictionary_id='545.Başlama ve Bitiş Tarihlerini Kontrol Ediniz'> !");
		else
		{alert("<cf_get_lang dictionary_id='545.Başlama ve Bitiş Tarihlerini Kontrol Ediniz'>");return false;}
		return true;
		if(process_cat_control())
			return true;
		else
			return false;
	}
</script>