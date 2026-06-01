<!---
    File: list_ezgi_collect_production.cfm
    Folder: Add_Ons\ezgi\e-vts\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<style>
	.box_yazi {font-size:16px;border-color:#666666;font:bold} 
	.box_yazi_td {font-size:14px;border-color:#666666;} 
	.box_yazi_small {font-size:11px;border-color:#666666;} 
	.a_box_yazi {font-size:16px;border-color:#BDCAC5;font:bold} 
	.a_box_yazi_td {font-size:14px;border-color:#BDCAC5;} 
</style>
<cfparam name="attributes.type" default="1">
<cfparam name="attributes.sub_menu" default="1">
<cfparam name="attributes.main_menu" default="2">
<cfparam name="attributes.master_plan" default="0">
<cfquery name="get_stations_all" datasource="#dsn3#">
	SELECT STATION_ID, STATION_NAME FROM WORKSTATIONS
</cfquery>
<cfoutput query="get_stations_all">
	<cfset 'STATION_NAME_#STATION_ID#' = STATION_NAME>
</cfoutput>
<cfquery name="GET_MASTER_PLAN" datasource="#dsn3#">
    SELECT DISTINCT
    	EMAP.MASTER_PLAN_ID, 
        EMAP.MASTER_ALT_PLAN_NO MASTER_PLAN_NUMBER, 
        EMAP.PLAN_DETAIL MASTER_PLAN_DETAIL, 
        EMAP.RECORD_DATE
	FROM     
    	EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
     	EZGI_MASTER_PLAN_SABLON AS EMAS ON EMAP.PROCESS_ID = EMAS.PROCESS_ID INNER JOIN
      	WORKSTATIONS AS W ON EMAS.WORKSTATION_ID = W.STATION_ID INNER JOIN
      	WORKSTATIONS AS W1 ON W.DEPARTMENT = W1.DEPARTMENT
	WHERE  
    	EMAS.SIRA = 1
  	ORDER BY 
    	EMAP.MASTER_ALT_PLAN_NO
</cfquery>
<cfif attributes.main_menu eq 1><!---İstasyonlar Seçilmişse--->
    <cfquery name="get_stations_emp" datasource="#dsn3#">
        SELECT 
            1 AS TYPE,
            STATION_ID, 
            STATION_NAME, 
            ACTIVE, 
            ACTION_EMPLOYEE_ID,
            '' AS STATION_START_DATE,
            ACTION_START_DATE,
            P_ORDER_ID, 
            LOT_NO, 
            P_ORDER_NO, 
            IS_STAGE, 
            STOCK_CODE, 
            SPEC_MAIN_ID, 
            STOCK_ID, 
            PRODUCT_ID, 
            PRODUCT_NAME, 
            SPECT_VAR_NAME, 
            QUANTITY, 
            P_OPERATION_ID, 
            OPERATION_TYPE_ID, 
            OPERATION_CODE, 
            OPERATION_TYPE, 
            AMOUNT, 
            STAGE, 
            REAL_TIME, 
            WAIT_TIME, 
            LOSS_AMOUNT,
            REAL_AMOUNT,
            MASTER_ALT_PLAN_ID, 
            O_TOTAL_PROCESS_TIME, 
            IS_VIRTUAL
        FROM
            (
            SELECT        
                W.STATION_ID, 
                W.STATION_NAME, 
                W.ACTIVE,
                W.EMP_ID, 
                TBL.P_ORDER_ID, 
                TBL.LOT_NO, 
                TBL.P_ORDER_NO, 
                TBL.IS_STAGE, 
                TBL.START_DATE, 
                TBL.STOCK_CODE, 
                TBL.SPEC_MAIN_ID, 
                TBL.STOCK_ID, 
                TBL.PRODUCT_ID, 
                TBL.PRODUCT_NAME, 
                TBL.SPECT_VAR_NAME, 
                TBL.QUANTITY, 
                TBL.P_OPERATION_ID, 
                TBL.OPERATION_TYPE_ID, 
                TBL.OPERATION_CODE, 
                TBL.OPERATION_TYPE, 
                TBL.AMOUNT, 
                TBL.STAGE, 
                TBL.REAL_TIME, 
                TBL.WAIT_TIME, 
                TBL.LOSS_AMOUNT,
                TBL.REAL_AMOUNT,
                TBL.ACTION_EMPLOYEE_ID, 
                TBL.ACTION_START_DATE, 
                TBL.O_START_DATE, 
                TBL.MASTER_ALT_PLAN_ID, 
                TBL.O_STATION_IP, 
                TBL.O_TOTAL_PROCESS_TIME, 
                TBL.O_FINISH_DATE, 
                TBL.IS_VIRTUAL
            FROM            
                WORKSTATIONS AS W LEFT OUTER JOIN
                (
                    SELECT        
                        P_ORDER_ID, 
                        LOT_NO, 
                        P_ORDER_NO, 
                        IS_STAGE, 
                        START_DATE, 
                        STOCK_CODE, 
                        SPEC_MAIN_ID, 
                        STOCK_ID, 
                        PRODUCT_ID, 
                        PRODUCT_NAME, 
                        SPECT_VAR_NAME, 
                        QUANTITY, 
                        P_OPERATION_ID, 
                        OPERATION_TYPE_ID, 
                        OPERATION_CODE, 
                        OPERATION_TYPE, 
                        AMOUNT, STAGE, 
                        STATION_ID, 
                        REAL_TIME, 
                        WAIT_TIME, 
                        ACTION_EMPLOYEE_ID, 
                        ACTION_START_DATE, 
                        REAL_AMOUNT, 
                        LOSS_AMOUNT, 
                        O_START_DATE, 
                        MASTER_ALT_PLAN_ID, 
                        O_STATION_IP, 
                        O_TOTAL_PROCESS_TIME, 
                        O_FINISH_DATE, 
                        IS_VIRTUAL
                    FROM            
                        EZGI_OPERATION_S
                ) AS TBL ON W.STATION_ID = TBL.STATION_ID
            ) AS TBL2
        WHERE        
            LOSS_AMOUNT = 0 AND 
            REAL_AMOUNT = 0 AND 
            REAL_TIME = 0 AND
            OPERATION_TYPE_ID IN
                					(
                						SELECT DISTINCT 
                                        	OPERATION_TYPE_ID
										FROM            
                                        	WORKSTATIONS_PRODUCTS
										WHERE        
                                        	WS_ID IN
                             						(
                                                    	SELECT        
                                                        	STATION_ID
                               							FROM            
                                                        	WORKSTATIONS
                               							WHERE        
                                                        	EMP_ID LIKE '%,#session.ep.userid#,%' AND 
                                                            NOT (OPERATION_TYPE_ID IS NULL)
                                                  	)
                                	)
        UNION ALL
        SELECT
            2 AS TYPE,
            STATION_ID, 
            STATION_NAME, 
            ACTIVE, 
            EMPLOYEE_ID, 
            STATION_START_DATE,
            '' AS ACTION_START_DATE,
            0 AS P_ORDER_ID, 
            '' AS LOT_NO, 
            '' AS P_ORDER_NO, 
            '' AS IS_STAGE, 
            '' AS STOCK_CODE, 
            0 AS SPEC_MAIN_ID, 
            0 AS STOCK_ID, 
            0 AS PRODUCT_ID, 
            '' AS PRODUCT_NAME, 
            '' AS SPECT_VAR_NAME, 
            0 AS QUANTITY, 
            0 AS P_OPERATION_ID, 
            0 AS OPERATION_TYPE_ID, 
            '' AS OPERATION_CODE, 
            '' AS OPERATION_TYPE, 
            0 AS AMOUNT, 
            '' AS STAGE, 
            0 AS REAL_TIME, 
            0 AS WAIT_TIME, 
            0 AS LOSS_AMOUNT,
            0 AS REAL_AMOUNT,
            0 AS MASTER_ALT_PLAN_ID, 
            0 AS O_TOTAL_PROCESS_TIME, 
            0 AS IS_VIRTUAL
        FROM
            (
            SELECT        
                W.STATION_ID, 
                W.STATION_NAME, 
                W.ACTIVE, 
                W.EMP_ID,
                TBL1.EMPLOYEE_ID, 
                TBL1.START_DATE STATION_START_DATE
            FROM            
                WORKSTATIONS AS W LEFT OUTER JOIN
                (
                    SELECT        
                        STATION_EMPLOYEE_ID, 
                        STATION_ID, 
                        EMPLOYEE_ID, 
                        START_DATE
                    FROM            
                        EZGI_STATION_EMPLOYEE
                    WHERE        
                        FINISH_DATE IS NULL
                ) AS TBL1 ON W.STATION_ID = TBL1.STATION_ID
            ) AS TBL3
        WHERE
            EMP_ID LIKE N'%,#session.ep.userid#,%' AND
            EMPLOYEE_ID IS NOT NULL
        UNION ALL
        SELECT
            3 AS TYPE,
            STATION_ID, 
            STATION_NAME, 
            ACTIVE, 
            EMPLOYEE_ID, 
            STATION_START_DATE,
            '' AS ACTION_START_DATE,
            0 AS P_ORDER_ID, 
            '' AS LOT_NO, 
            '' AS P_ORDER_NO, 
            '' AS IS_STAGE, 
            '' AS STOCK_CODE, 
            0 AS SPEC_MAIN_ID, 
            0 AS STOCK_ID, 
            0 AS PRODUCT_ID, 
            '' AS PRODUCT_NAME, 
            '' AS SPECT_VAR_NAME, 
            0 AS QUANTITY, 
            0 AS P_OPERATION_ID, 
            0 AS OPERATION_TYPE_ID, 
            '' AS OPERATION_CODE, 
            '' AS OPERATION_TYPE, 
            0 AS AMOUNT, 
            '' AS STAGE, 
            0 AS REAL_TIME, 
            0 AS WAIT_TIME, 
            0 AS LOSS_AMOUNT,
            0 AS REAL_AMOUNT,
            0 AS MASTER_ALT_PLAN_ID, 
            0 AS O_TOTAL_PROCESS_TIME, 
            0 AS IS_VIRTUAL
        FROM
            (
            SELECT        
                W.STATION_ID, 
                W.STATION_NAME, 
                W.ACTIVE, 
                W.EMP_ID,
                TBL4.EMPLOYEE_ID, 
                TBL4.START_DATE STATION_START_DATE
            FROM            
                WORKSTATIONS AS W LEFT OUTER JOIN
                (
                    SELECT        
                        STATION_EMPLOYEE_ID, 
                        STATION_ID, 
                        EMPLOYEE_ID, 
                        START_DATE
                    FROM            
                        EZGI_STATION_EMPLOYEE
                    WHERE        
                        FINISH_DATE IS NULL
                ) AS TBL4 ON W.STATION_ID = TBL4.STATION_ID
            ) AS TBL3
        WHERE
            EMP_ID LIKE N'%,#session.ep.userid#,%' AND 
            EMPLOYEE_ID IS NULL
    </cfquery>
    <!---<cfdump var="#get_stations_emp#">--->
    <cfif isdefined('attributes.lot_number') and len(attributes.lot_number)>
        <cfquery name="get_lot_number" dbtype="query"><!--- Okunan Bilgi İş Emri mi--->
            SELECT P_ORDER_ID FROM get_stations_emp	WHERE TYPE = 1 AND (LOT_NO = '#attributes.lot_number#' OR P_ORDER_NO = '#attributes.lot_number#')
        </cfquery>
        <cfset busy_p_order_list = ValueList(get_lot_number.P_ORDER_ID)>
        <cfif not get_lot_number.recordcount>
            <cfquery name="get_emp_id" datasource="#dsn3#">
                SELECT EMP_ID FROM EZGI_VTS_IDENTY WHERE PAROLA = '#attributes.lot_number#'
            </cfquery>
            <cfset busy_emp_id_list = ValueList(get_emp_id.EMP_ID)>
            <cfif ListLen(busy_emp_id_list)>
                <cfquery name="get_lot_number" dbtype="query"><!--- Okunan Bilgi Çalışan mı--->
                    SELECT 
                        P_ORDER_ID 
                    FROM 
                        get_stations_emp	
                    WHERE 
                        TYPE = 1 AND 
                        ACTION_EMPLOYEE_ID IN (#busy_emp_id_list#)
                </cfquery>
                <cfset busy_p_order_list = ValueList(get_lot_number.P_ORDER_ID)>
            </cfif>
        </cfif>
        <cfif not Listlen(busy_p_order_list)>
        	 <!--- Çaışanlarda İş Emri veya Emp Buluamadıysa Çalışamayanlarda Arıyoruz.--->
          	<cfquery name="get_emp_id" datasource="#dsn3#">
              	SELECT EMP_ID FROM EZGI_VTS_IDENTY WHERE PAROLA = '#attributes.lot_number#'
           	</cfquery>
          	<cfset busy_emp_id_list = ValueList(get_emp_id.EMP_ID)>
          	<cfif ListLen(busy_emp_id_list)>
            	<cfquery name="get_lot_number" dbtype="query"><!--- Okunan Bilgi Çalışan mı--->
                 	SELECT * FROM get_stations_emp	WHERE TYPE = 2 AND ACTION_EMPLOYEE_ID IN (#busy_emp_id_list#)
             	</cfquery>
              	<cfset busy_p_order_list = ValueList(get_lot_number.P_ORDER_ID)>
         	</cfif>
            <cfif not Listlen(busy_p_order_list)>
            	<cfif not ListLen(busy_emp_id_list)>
                	<cfquery name="get_product_orders" datasource="#DSN3#">
                        SELECT        
                            P_ORDER_ID, 
                            LOT_NO, 
                            P_ORDER_NO, 
                            IS_STAGE, 
                            START_DATE, 
                            STOCK_CODE, 
                            SPEC_MAIN_ID, 
                            STOCK_ID, 
                            PRODUCT_ID, 
                            PRODUCT_NAME, 
                            SPECT_VAR_NAME, 
                            QUANTITY, 
                            P_OPERATION_ID, 
                            OPERATION_TYPE_ID, 
                            OPERATION_CODE, 
                            OPERATION_TYPE, 
                            AMOUNT, STAGE, 
                            STATION_ID, 
                            REAL_TIME, 
                            WAIT_TIME, 
                            ACTION_EMPLOYEE_ID, 
                            ACTION_START_DATE, 
                            ISNULL(REAL_AMOUNT,0) AS REAL_AMOUNT, 
                            LOSS_AMOUNT, 
                            O_START_DATE, 
                            MASTER_ALT_PLAN_ID, 
                            O_STATION_IP, 
                            O_TOTAL_PROCESS_TIME, 
                            O_FINISH_DATE, 
                            IS_VIRTUAL
                        FROM            
                            EZGI_OPERATION_S
                       	WHERE
                        	(LOT_NO = '#attributes.lot_number#' OR P_ORDER_NO = '#attributes.lot_number#') AND
                        	O_STATION_IP IN 
                            				(
                                            	SELECT
                                                	STATION_ID 
                                               	FROM
                                                	WORKSTATIONS
                                               	WHERE
                                                	EMP_ID LIKE N'%,#session.ep.userid#,%'
                                            )
                    </cfquery>
                    <!---<cfdump var="#get_product_orders#">--->
                    <cfif get_product_orders.recordcount>
                    	<cfquery name="get_act_emp_id" dbtype="query"> <!---Okunan Bilgi Çalışan mı--->
                            SELECT 
                                ACTION_EMPLOYEE_ID
                            FROM 
                                get_stations_emp	
                            WHERE 
                                TYPE = 1
                        </cfquery>
                        <cfset emp_id_list = ValueList(get_act_emp_id.ACTION_EMPLOYEE_ID)>
                        <cfif ListLen(emp_id_list)>
                            <cfquery name="get_emp_id" datasource="#dsn3#">
                                SELECT EMP_ID FROM EZGI_VTS_IDENTY WHERE EMP_ID NOT IN (#emp_id_list#)
                            </cfquery>
                            <cfset busy_emp_id_list = ValueList(get_emp_id.EMP_ID)>
                        </cfif>
                    	<cfset attributes.type = 2>
                    <cfelse>
                		<cfset attributes.type = 0>
                    </cfif>
                <cfelse>
            		<cfset attributes.type = 3>
               	</cfif>
            <cfelse>
            	<cfset attributes.type = 2>	
            </cfif>
        <cfelse>
            <cfset attributes.type = 1>		
        </cfif>
    </cfif>
    <cfif attributes.type eq 4>
        <cfquery name="get_busy_station" dbtype="query">
            SELECT ACTION_EMPLOYEE_ID FROM get_stations_emp	WHERE TYPE = 1
        </cfquery>
        <cfset busy_employee_id_list = ValueList(get_busy_station.ACTION_EMPLOYEE_ID)>
    </cfif>
    <cfquery name="get_po_det" dbtype="query">
        SELECT
            *
        FROM 
            get_stations_emp
        WHERE
            <cfif attributes.type eq 4>
                TYPE = 2
                <cfif ListLen(busy_employee_id_list)>
                    AND ACTION_EMPLOYEE_ID NOT IN (#busy_employee_id_list#)
                </cfif>
            <cfelseif attributes.type eq 3>
                TYPE = #attributes.type#
            <cfelse>
                TYPE = #attributes.type#
                <cfif isdefined('busy_p_order_list') and len(busy_p_order_list)>
                    AND P_ORDER_ID IN (#busy_p_order_list#)
                </cfif>
                <cfif isdefined('busy_emp_id_list') and ListLen(busy_emp_id_list)>
                    AND ACTION_EMPLOYEE_ID IN (#busy_emp_id_list#)
                </cfif>
            </cfif>
    </cfquery>
    <!---<cfdump var="#get_po_det#">--->
    
    <cfparam name="attributes.page" default=1>
    <cfparam name="attributes.maxrows" default='250'>
    <cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
    <cfif get_po_det.recordcount>
        <cfparam name="attributes.totalrecords" default='#get_po_det.recordcount#'>
    <cfelse>
        <cfparam name="attributes.totalrecords" default='0'>
    </cfif>
<cfelse><!---Operasyonlar Seçilmişse--->
 	<cfquery name="get_product_orders" datasource="#DSN3#">
            SELECT 
          		PRODUCT_NAME,
                ACTION_EMPLOYEE_ID,
                OPERATION_TYPE_ID,
             	OPERATION_TYPE,
             	AMOUNT,
         		P_OPERATION_ID,
            	P_ORDER_ID,
                LOT_NO,
                P_ORDER_NO,
                STAGE,
                IS_STAGE,
                STATION_ID,
           		ISNULL(REAL_AMOUNT,0) AS REAL_AMOUNT
            FROM 
                EZGI_OPERATION_S 
            WHERE 
            	<cfif isdefined('attributes.lot_number') and len(attributes.lot_number)>
                	(LOT_NO = '#attributes.lot_number#' OR P_ORDER_NO = '#attributes.lot_number#') AND 
               <cfelse> 
					<cfif attributes.sub_menu eq 1>
                        STAGE = 1 AND
                        REAL_AMOUNT = 0 AND
                    <cfelseif attributes.sub_menu eq 4>
                        STAGE = 0 AND
                        <cfif len(attributes.master_plan)>
                        	MASTER_ALT_PLAN_ID IN
                        					(
                                            	SELECT 
                                                	MASTER_ALT_PLAN_ID
												FROM     
                                                	EZGI_MASTER_ALT_PLAN
												WHERE  
                                                	MASTER_PLAN_ID = #attributes.master_plan#
                                            ) AND
                        </cfif>
                    <cfelseif attributes.sub_menu eq 2>
                        (STAGE = 3 OR REAL_AMOUNT > 0) AND
                        <cfif len(attributes.master_plan)>
                        	MASTER_ALT_PLAN_ID IN
                        					(
                                            	SELECT 
                                                	MASTER_ALT_PLAN_ID
												FROM     
                                                	EZGI_MASTER_ALT_PLAN
												WHERE  
                                                	MASTER_PLAN_ID = #attributes.master_plan#
                                            ) AND
                        </cfif>
                    </cfif>
                </cfif>
                OPERATION_TYPE_ID IN
                					(
                						SELECT DISTINCT 
                                        	OPERATION_TYPE_ID
										FROM            
                                        	WORKSTATIONS_PRODUCTS
										WHERE        
                                        	WS_ID IN
                             						(
                                                    	SELECT        
                                                        	STATION_ID
                               							FROM            
                                                        	WORKSTATIONS
                               							WHERE        
                                                        	EMP_ID LIKE N'%,#session.ep.userid#,%' AND 
                                                            NOT (OPERATION_TYPE_ID IS NULL)
                                                  	)
                                	)
        	ORDER BY
            	P_ORDER_ID,
            	P_OPERATION_ID
            	
	</cfquery>
 	<cfif isdefined('attributes.lot_number') and len(attributes.lot_number)>
        	<cfquery name="get_product_orders_sub" dbtype="query">
            	SELECT
                	PRODUCT_NAME,
                    OPERATION_TYPE_ID,
                    OPERATION_TYPE,
                    AMOUNT,
                    P_OPERATION_ID,
                    P_ORDER_ID,
                    LOT_NO,
                    P_ORDER_NO,
                    STAGE,
                    IS_STAGE,
                    SUM(REAL_AMOUNT) AS REAL_AMOUNT
              	FROM
                	get_product_orders
              	WHERE
                	(LOT_NO = '#attributes.lot_number#' OR P_ORDER_NO = '#attributes.lot_number#')	AND
                    REAL_AMOUNT >0
               	GROUP BY
                	PRODUCT_NAME,
                    OPERATION_TYPE_ID,
                    OPERATION_TYPE,
                    AMOUNT,
                    P_OPERATION_ID,
                    P_ORDER_ID,
                    LOT_NO,
                    P_ORDER_NO,
                    STAGE,
                    IS_STAGE
              	UNION ALL
                SELECT
                	PRODUCT_NAME,
                    OPERATION_TYPE_ID,
                    OPERATION_TYPE,
                    AMOUNT,
                    P_OPERATION_ID,
                    P_ORDER_ID,
                    LOT_NO,
                    P_ORDER_NO,
                    STAGE,
                    IS_STAGE,
                    COUNT(REAL_AMOUNT) AS REAL_AMOUNT
              	FROM
                	get_product_orders
              	WHERE
                	(LOT_NO = '#attributes.lot_number#' OR P_ORDER_NO = '#attributes.lot_number#')	AND
                    REAL_AMOUNT = 0
              	GROUP BY
                	PRODUCT_NAME,
                    OPERATION_TYPE_ID,
                    OPERATION_TYPE,
                    AMOUNT,
                    P_OPERATION_ID,
                    P_ORDER_ID,
                    LOT_NO,
                    P_ORDER_NO,
                    STAGE,
                    IS_STAGE
            </cfquery>
            <cfif get_product_orders_sub.stage neq 0>
                <cfquery name="get_product_orders_sub_sub" dbtype="query">
                    SELECT
                        PRODUCT_NAME,
                        OPERATION_TYPE_ID,
                        OPERATION_TYPE,
                        AMOUNT,
                        P_OPERATION_ID,
                        P_ORDER_ID,
                        LOT_NO,
                        P_ORDER_NO,
                        0 AS STAGE,
                        IS_STAGE,
                        SUM(REAL_AMOUNT) AS REAL_AMOUNT
                    FROM
                        get_product_orders_sub
                    GROUP BY
                        PRODUCT_NAME,
                        OPERATION_TYPE_ID,
                        OPERATION_TYPE,
                        AMOUNT,
                        P_OPERATION_ID,
                        P_ORDER_ID,
                        LOT_NO,
                        P_ORDER_NO,
                        IS_STAGE
                    HAVING
                        AMOUNT>SUM(REAL_AMOUNT)
                </cfquery>
                <cfif get_product_orders_sub_sub.recordcount>
                    <cfquery name="get_product_orders" dbtype="query">
                        SELECT
                            PRODUCT_NAME,
                            ACTION_EMPLOYEE_ID,
                            OPERATION_TYPE_ID,
                            OPERATION_TYPE,
                            AMOUNT,
                            P_OPERATION_ID,
                            P_ORDER_ID,
                            LOT_NO,
                            P_ORDER_NO,
                            STAGE,
                            IS_STAGE,
                            STATION_ID,
                            REAL_AMOUNT
                        FROM
                            get_product_orders
                        UNION ALL     
                        SELECT
                            PRODUCT_NAME,
                            0 AS ACTION_EMPLOYEE_ID,
                            OPERATION_TYPE_ID,
                            OPERATION_TYPE,
                            AMOUNT,
                            P_OPERATION_ID,
                            P_ORDER_ID,
                            LOT_NO,
                            P_ORDER_NO,
                            STAGE,
                            IS_STAGE,
                            0 AS STATION_ID,
                            REAL_AMOUNT
                        FROM
                            get_product_orders_sub_sub
                    </cfquery>
                </cfif>
           	</cfif>
        	<cfif get_product_orders.recordcount>
            	<cfif get_product_orders.STAGE eq 1>
                	<cfset attributes.sub_menu = 1>
                <cfelseif get_product_orders.STAGE eq 0>
                	<cfset attributes.sub_menu = 4>
                <cfelseif get_product_orders.STAGE eq 3>
                	<cfset attributes.sub_menu = 2>
                </cfif>
            </cfif>
	</cfif>
  	<!---<cfdump var="#get_product_orders#">--->
	<cfparam name="attributes.page" default=1>
    <cfparam name="attributes.maxrows" default='250'>
    <cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
    <cfif get_product_orders.recordcount>
        <cfparam name="attributes.totalrecords" default='#get_product_orders.recordcount#'>
    <cfelse>
        <cfparam name="attributes.totalrecords" default='0'>
    </cfif>
</cfif>
<cfform name="search_list" id="search_list" action="#request.self#?fuseaction=production.list_ezgi_collect_production" method="post">
    <table width="98%" align="center" border="0">
        <tr>
        	<cfinput type="hidden" name="main_menu" id="main_menu" value="#attributes.main_menu#">
			<cfinput type="hidden" name="is_form_submitted" value="1">
			<td style="text-align:right">
				<table width="100%">
					<tr>
                    	<td style="text-align:left; width:620px">
                        	<a href="javascript://" onclick="main_menu_select(1);">
                           		<button type="button" name="station" id="station" style="width:150px; font-size:14px;font-weight:bold;height:40px;<cfif attributes.main_menu eq 1>background-color:red;color:white</cfif>"><cfoutput>İstasyonlar</cfoutput></button>
                       		</a>
                            <a href="javascript://" onclick="main_menu_select(2);">
                           		<button type="button" name="p_order" id="p_order" style="width:150px; font-size:14px;font-weight:bold;height:40px;<cfif attributes.main_menu eq 2>background-color:red;color:white</cfif>"><cfoutput>Operasyonlar</cfoutput></button>
                       		</a>
                        </td>
                        <td></td>
                        <td style="vertical-align:middle">
                                <select name="master_plan" id="master_plan" onChange="change_master_plan(this.value);" style="font-size:16px; font-weight:bold; height:40px; width:400px;vertical-align:top; <cfif attributes.sub_menu eq 2 or attributes.sub_menu eq 4><cfelse>display:none</cfif>">
                                    <option value="" <cfif attributes.master_plan eq ''>selected</cfif>>Üretim Seçiniz</option>
                                    <cfoutput query="get_master_plan">
                                        <option value="#MASTER_PLAN_ID#" <cfif week(get_master_plan.RECORD_DATE)-week(now()) eq 0>style="background-color:palegreen"</cfif> <cfif attributes.master_plan eq #MASTER_PLAN_ID#>selected</cfif>>#Dateformat(RECORD_DATE,'DD/MM/YYYY')# - #MASTER_PLAN_NUMBER# - #MASTER_PLAN_DETAIL#</option>
                                    </cfoutput>
                                </select>
                        </td> 
						<td style="text-align:right; width:100px;font-size:16px; font-weight:bold; vertical-align:middle"><cf_get_lang dictionary_id ='57460.Filtre'></td>
						<td style="text-align:right; width:100px"><input name="lot_number" id="lot_number"  type="text" value="" onKeyDown="if(event.keyCode == 13) {return location_production_detail(trim(this.value));}" style="width:200px; height:40px; font-size:24px; font-weight:bold; vertical-align:top">
                        </td
					></tr>
				</table>
			</td>
        </tr>
        <cfif attributes.main_menu eq 1><!---İstasyonlar Seçilmişse--->
            <tr>
                <td style="text-align:right">
                    <table border="1" cellspacing="0" cellpadding="2" width="100%" align="center" style="border-color:#666666;">
                        <tr height="55px" class="color-row">
                            <td class="box_yazi_td" style="text-align:left; width:620px">
                                    <a href="javascript://" onclick="menu_select(3);">
                                        <button type="button" name="bos" style="width:150px; font-size:12px; font-weight:bold;height:50px;<cfif attributes.type eq 3>background-color:red;color:white</cfif>"><cfoutput>Boş İstasyonlar</cfoutput></button>
                                    </a>
                                    <a href="javascript://" onclick="menu_select(2);">
                                        <button type="button" name="dolu" style="width:150px; font-size:12px; font-weight:bold;height:50px;<cfif attributes.type eq 2>background-color:red;color:white</cfif>"><cfoutput>Dolu İstasyonlar</cfoutput></button>
                                    </a>
                                    <a href="javascript://" onclick="menu_select(4);">
                                        <button type="button" name="hazir" style="width:150px; font-size:12px; font-weight:bold;height:50px;<cfif attributes.type eq 4>background-color:red;color:white</cfif>"><cfoutput>Hazır İstasyonlar</cfoutput></button>
                                    </a>
                                    <a href="javascript://" onclick="menu_select(1);">
                                        <button type="button" name="calisan" style="width:150px; font-size:12px; font-weight:bold;height:50px;<cfif attributes.type eq 1>background-color:red;color:white</cfif>"><cfoutput>Çalışan İstasyonlar</cfoutput></button>
                                    </a>
                            </td> 
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <table border="1" cellspacing="0" cellpadding="2" width="100%" align="center" style="border-color:#666666;">
                        <tr height="40" class="color-header">
                            <td class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id ='57487.No'></td>
                            <td class="box_yazi" style="text-align:center" width="25%"><cf_get_lang dictionary_id='58834.İstasyon'></td>
                            <td class="box_yazi" style="text-align:center" width="8%"><cf_get_lang dictionary_id='29474.Emir No'></td>
                            <td class="box_yazi" style="text-align:center" width="8%"><cf_get_lang dictionary_id='301.Operatör'></td>
                            <td class="box_yazi" style="text-align:center" ><cf_get_lang dictionary_id='38089.Mamül Adı'></td>
                            <td class="box_yazi" style="text-align:center" width="15%"><cf_get_lang dictionary_id='29419.Operasyon'></td>
                            <td class="box_yazi" style="text-align:center" width="4%"></td>
                        </tr>
                        	<!---<cfdump var="#get_po_det#">--->
                            <cfquery name="get_empty_employee" datasource="#dsn3#">
                            	SELECT        
                                	EMP_ID,
                                    (SELECT EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ADI FROM #dsn_alias#.EMPLOYEES WHERE EMPLOYEE_ID = V.EMP_ID) AS ADI
								FROM            
                                	EZGI_VTS_IDENTY AS V
								WHERE        
                                	DEFAULT_DEPARTMENT_ID IN
                             								(
                                                            	SELECT        
                                                                	DEPARTMENT
                               									FROM          
                                                                	WORKSTATIONS
                               									WHERE        
                                                                	EMP_ID LIKE '%,#session.ep.userid#,%'
                                                           	) AND 
                             		EMP_ID NOT IN
                             								(
                                                            	SELECT        
                                                                	EMPLOYEE_ID
                               									FROM          
                                                                	EZGI_STATION_EMPLOYEE
                               									WHERE        
                                                                	FINISH_DATE IS NULL
                                                           	)
                              	ORDER BY
                                	ADI
                            </cfquery>
                            <cfoutput query="get_po_det" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                                <tr height="55px" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                                    <td class="box_yazi_td" style="text-align:center">
                                        &nbsp;#currentrow#
                                    </td>
                                    <td class="box_yazi_td" style="text-align:center">&nbsp;#STATION_NAME#</td>
                                    <td class="box_yazi_td" style="text-align:center">&nbsp;#P_ORDER_NO#</td>
                                    <td class="box_yazi_td" style="text-align:center;" nowrap="nowrap">&nbsp;#get_emp_info(ACTION_EMPLOYEE_ID,0,0)#</td>
                                    <td class="box_yazi_td">&nbsp;#PRODUCT_NAME#</td>
                                    <td class="box_yazi_td">&nbsp;#OPERATION_TYPE#</td>
                                    <td class="box_yazi_td" style="text-align:center">
                                        <cfif attributes.type eq 3> <!---Boş İstasyonlar--->
                                                <button type="button" name="ilistirt" style="width:100%; height:100%; background-color:gray" onclick="tusla(1,#get_po_det.currentrow#,#get_po_det.STATION_ID#);">
                                                    <img src="images/rotate_bottom.gif" id="operasyon1_#currentrow#" border="0" title="<cf_get_lang dictionary_id ='1150.Çalışan Göster'>" height="50px" style="text-align:center; vertical-align:middle" />
                                                    <img src="images/rotate_up.gif" id="operasyon2_#currentrow#" border="0" title="<cf_get_lang dictionary_id ='1149.Çalışan Gizle'>" height="50px" style="text-align:center; vertical-align:middle; display:none" />
                                                </button>
                                        <cfelseif attributes.type eq 4> <!---Hazır İstasyonlar--->
                                        	<button type="button" name="ayirt" style="width:100%; height:100%; background-color:green" onclick="ayir(#get_po_det.ACTION_EMPLOYEE_ID#);">
                                             	<img src="images/list_plus.gif" border="0" title="<cf_get_lang dictionary_id ='1148.İstasyondan Çalışan Çıkar'>" height="50px" style="text-align:center; vertical-align:middle" />
                                        	</button>
                                      	<cfelseif attributes.type eq 1> <!---Çalışan İstasyonlar--->
                                        	<button type="button" name="sonlandirt" style="width:100%; height:100%; background-color:red" onclick="sonlandir(#get_po_det.STATION_ID#,#get_po_det.ACTION_EMPLOYEE_ID#,#get_po_det.P_OPERATION_ID#);">
                                             	<img src="images/list_plus.gif" border="0" title="<cf_get_lang dictionary_id ='1147.Operasyondan Çalışanı Ayır'>" height="50px" style="text-align:center; vertical-align:middle" />
                                        	</button>
                                        </cfif>
                                    </td>
                                </tr>
                                <cfinput id="ek_tr#get_po_det.currentrow#" name="ek_tr#get_po_det.currentrow#" type="hidden" value="0">
                            	<cfif attributes.type eq 3>
                               		<cfif get_empty_employee.recordcount>
                                    	<cfloop query="get_empty_employee">
                                        	<tr id="ek_#get_po_det.currentrow#_#get_empty_employee.currentrow#" style="display:none">
                                            	<td class="box_yazi_td" style="text-align:center" colspan="3">&nbsp;</td>
                                               	<td class="box_yazi_td" colspan="3">&nbsp;<cfif get_empty_employee.EMP_ID gt 0>#get_emp_info(get_empty_employee.EMP_ID,0,0)#</cfif></td>
                                            	<td class="box_yazi_td" style="text-align:center">
                                                 	<button type="button" name="git" style="width:100%; height:100%; background-color:red" onclick="ilistir(#get_po_det.STATION_ID#, #get_empty_employee.EMP_ID#);">
                                                    	<img src="images/list_plus.gif" border="0" title="<cf_get_lang dictionary_id ='1146.İstasyona Çalışan Yerleştir'>" height="40px" style="text-align:center; vertical-align:middle" />
                                                 	</button>
                                              	</td>
                                        	</tr>
                                     	</cfloop> 
                                  	</cfif>
                              	</cfif>
                            </cfoutput>
                    </table>	
                </td>
            </tr>
       	<cfelse> <!---Operasyonlar Seçilmişse--->
        	<tr>
                <td style="text-align:right">
                    <table border="1" cellspacing="0" cellpadding="2" width="100%" align="center" style="border-color:#666666;">
                        <tr height="55px" class="color-row">
                            <td class="box_yazi_td" style="text-align:left; width:750px">
                                    <a href="javascript://" onclick="operation_select(4);">
                                        <button type="button" name="no_start" style="width:220px; font-size:12px; font-weight:bold;height:50px;<cfif attributes.sub_menu eq 4>background-color:red;color:white</cfif>"><cfoutput><cf_get_lang dictionary_id='1144.Başlamamış Operasyonlar'></cfoutput></button>
                                    </a>
                                    <a href="javascript://" onclick="operation_select(2);">
                                        <button type="button" name="finishes" style="width:220px; font-size:12px; font-weight:bold;height:50px;<cfif attributes.sub_menu eq 2>background-color:red;color:white</cfif>"><cfoutput><cf_get_lang dictionary_id='1145.Biten Operasyonlar'></cfoutput></button>
                                    </a>
                                    <a href="javascript://" onclick="operation_select(1);">
                                        <button type="button" name="starter" style="width:220px; font-size:12px; font-weight:bold;height:50px;<cfif attributes.sub_menu eq 1>background-color:red;color:white</cfif>"><cfoutput><cf_get_lang dictionary_id='408.İşlemdeki Operasyonlar'></cfoutput></button>
                                    </a>
                            </td> 
                        </tr>
                    </table>
                </td>
            </tr>
      		<tr>
                <td>
                    <table border="1" cellspacing="0" cellpadding="2" width="100%" align="center" style="border-color:#666666;">
                        <tr height="40" class="color-header">
                            <td class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id ='57487.No'></td>
                            <td class="box_yazi" style="text-align:center" width="8%"><cf_get_lang dictionary_id='29474.Emir No'></td>
                            <td class="box_yazi" style="text-align:center" ><cf_get_lang dictionary_id ='38089.Mamül Adı'></td>
                            <td class="box_yazi" style="text-align:center" width="10%"><cf_get_lang dictionary_id='29419.Operasyon'></td>
                            <td class="box_yazi" style="text-align:center" width="12%"><cf_get_lang dictionary_id='301.Operatör'></td>
                            <td class="box_yazi" style="text-align:center" width="23%"><cf_get_lang dictionary_id='58834.İstasyon'></td>
                            <td class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id='57635.Miktar'></td>
                            <td class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id='302.Biten'></td>
                            <td class="box_yazi" style="text-align:center" width="60"></td>
                        </tr>
                        <!---<cfdump var="#get_product_orders#">--->
                        <cfif get_product_orders.recordcount>
                     		<cfoutput query="get_product_orders" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                            	<cfinput id="ek_tr#get_product_orders.currentrow#" name="ek_tr#get_product_orders.currentrow#" type="hidden" value="0">
                                <tr height="50px" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                                    <td class="box_yazi_td" style="text-align:center">&nbsp;#currentrow#</td>
                                    <td class="box_yazi_td" style="text-align:center">&nbsp;#P_ORDER_NO#</td>
                                    <td class="box_yazi_td">&nbsp;#PRODUCT_NAME#</td>
                                    <td class="box_yazi_td">&nbsp;#OPERATION_TYPE#</td>
                                    <td class="box_yazi_td">&nbsp;<cfif ACTION_EMPLOYEE_ID gt 0>#get_emp_info(ACTION_EMPLOYEE_ID,0,0)#</cfif></td>
                                    <td class="box_yazi_td">&nbsp;<cfif isdefined('STATION_NAME_#STATION_ID#')>#Evaluate('STATION_NAME_#STATION_ID#')#</cfif></td>
                                    <td class="box_yazi_td" style="text-align:center">#AMOUNT#</td>
                                    <td class="box_yazi_td" style="text-align:center">#REAL_AMOUNT#</td>
                                    <td class="box_yazi_td" style="text-align:center">
                                        <cfif STAGE eq 0>
                                                <button type="button" name="main_button_#currentrow#" id="main_button_#currentrow#" style="width:100%; height:100%; background-color:gray" onclick="main_row(0,#currentrow#);">
                                                    <img src="images/rotate_bottom.gif" id="station1_#currentrow#" border="0" title="<cf_get_lang dictionary_id='1143.İstasyonları Göster'>" height="50px" style="text-align:center; vertical-align:middle" />
                                                    <img src="images/rotate_up.gif" id="station2_#currentrow#" border="0" title="<cf_get_lang dictionary_id='1142.İstasyonları Gizle'>" height="50px" style="text-align:center; vertical-align:middle; display:none" />
                                                </button>
                                       	<cfelseif STAGE eq 1 and REAL_AMOUNT eq 0>
    										<button type="button" name="git" style="background-color:green ; vertical-align:middle; height:100%; width:100%" onclick="basla(#get_product_orders.STATION_ID#, #get_product_orders.ACTION_EMPLOYEE_ID#,#get_product_orders.p_order_id#,#get_product_orders.p_operation_id#);">
                                             	<img src="images/list_plus.gif" border="0" title="<cf_get_lang dictionary_id='1141.İş Emrine Git'>" style="text-align:center; vertical-align:middle; width:100%; height:50px" />
                                       		</button>
                                      	<cfelseif STAGE eq 3 or (REAL_AMOUNT gt 0 and STAGE eq 1)>
    										<button type="button" name="git" style="background-color:red ; vertical-align:middle; height:100%; width:100%" onclick="basla(#get_product_orders.STATION_ID#, #get_product_orders.ACTION_EMPLOYEE_ID#,#get_product_orders.p_order_id#,#get_product_orders.p_operation_id#);">
                                            	<img src="images/list_plus.gif" border="0" title="<cf_get_lang dictionary_id='1141.İş Emrine Git'>" style="text-align:center; vertical-align:middle; width:100%; height:50px" />
                                       		</button>
                                        </cfif>
                                        
                                    </td>
                                </tr>
                                <cfif STAGE eq 0>
                                	<cfquery name="get_operations" datasource="#dsn3#">
                                        SELECT WS_ID FROM WORKSTATIONS_PRODUCTS WHERE OPERATION_TYPE_ID = #get_product_orders.OPERATION_TYPE_ID#
                                    </cfquery>
                                    <cfset station_id_list = ValueList(get_operations.WS_ID)>
                                    <cfif ListLen(station_id_list)>
                                        <cfquery name="get_stations_#get_product_orders.currentrow#" datasource="#dsn3#">
                                            SELECT
                                                STATION_ID, 
                                                STATION_NAME, 
                                                ACTIVE, 
                                                EMPLOYEE_ID, 
                                                STATION_START_DATE
                                            FROM
                                                (
                                                SELECT        
                                                    W.STATION_ID, 
                                                    W.STATION_NAME, 
                                                    W.ACTIVE, 
                                                    W.EMP_ID,
                                                    TBL1.EMPLOYEE_ID, 
                                                    TBL1.START_DATE STATION_START_DATE
                                                FROM            
                                                    WORKSTATIONS AS W LEFT OUTER JOIN
                                                    (
                                                        SELECT        
                                                            STATION_EMPLOYEE_ID, 
                                                            STATION_ID, 
                                                            EMPLOYEE_ID, 
                                                            START_DATE
                                                        FROM            
                                                            EZGI_STATION_EMPLOYEE
                                                        WHERE        
                                                            FINISH_DATE IS NULL
                                                    ) AS TBL1 ON W.STATION_ID = TBL1.STATION_ID
                                                ) AS TBL3
                                            WHERE
                                                STATION_ID IN (#station_id_list#) AND
                                                EMP_ID LIKE N'%,#session.ep.userid#,%' AND
                                                EMPLOYEE_ID IS NOT NULL AND
                                                EMPLOYEE_ID NOT IN (
                                                						SELECT        
                                                                        	ACTION_EMPLOYEE_ID
																		FROM           
                                                                        	EZGI_OPERATION_S
																		WHERE        
                                                                        	REAL_TIME = 0 AND 
                                                                            REAL_AMOUNT = 0
                                                                   	)
                                        </cfquery>
                                        <cfif Evaluate('get_stations_#get_product_orders.currentrow#').recordcount gt 0>
                                       <!--- <cfdump var="#Evaluate('get_stations_#get_product_orders.currentrow#')#">--->
                                            <cfloop query="get_stations_#get_product_orders.currentrow#">
                                                <tr id="ek_#currentrow#_#get_product_orders.currentrow#" style="display:none">
                                                	<td class="box_yazi_td" style="text-align:center; height:50px" colspan="4">&nbsp;</td>
                                                    <td class="box_yazi_td" style="text-align:center">#get_emp_info(EMPLOYEE_ID,0,0)#</td>
                                                    <td class="box_yazi_td" style="text-align:center">#Evaluate('STATION_NAME_#STATION_ID#')#</td>
                                                    <td class="box_yazi_td" style="text-align:center" colspan="2">&nbsp;</td>
                                                    <td class="box_yazi_td" style="text-align:center; vertical-align:middle">
                                                    	<button type="button" name="git" style="background-color:orange ; vertical-align:middle; height:100%; width:100%" onclick="basla(#Evaluate('get_stations_#get_product_orders.currentrow#').STATION_ID#, #Evaluate('get_stations_#get_product_orders.currentrow#').EMPLOYEE_ID#,#get_product_orders.p_order_id#,#get_product_orders.p_operation_id#);">
                                                        	<img src="images/list_plus.gif" border="0" title="İş Emrine Git" style="text-align:center; vertical-align:middle; width:100%; height:50px" />
                                                    	</button>
                                                    
                                                    </td>
                                                </tr>
                                            </cfloop>
                                        </cfif>
                                   	</cfif>
                                </cfif>
                           	</cfoutput>
                      	</cfif>
                  	</table>
               	</td>
           	</tr>
        </cfif>
    </table>
</cfform>
<script type="text/javascript">
	document.getElementById('lot_number').focus();
	function change_master_plan()
	{
		master_plan_id=document.getElementById('master_plan').value;
		sub_menu = <cfoutput>#attributes.sub_menu#</cfoutput>;
		window.location ="<cfoutput>#request.self#?fuseaction=production.list_ezgi_collect_production&main_menu=#attributes.main_menu#</cfoutput>&sub_menu="+sub_menu+"&master_plan="+master_plan_id;
	}
	function menu_select(type)
	{
		master_plan_id=document.getElementById('master_plan').value;
		window.location ="<cfoutput>#request.self#?fuseaction=production.list_ezgi_collect_production&main_menu=#attributes.main_menu#</cfoutput>&type="+type+"&master_plan="+master_plan_id;
	}
	function tusla(tur, k, station_id)
	{
		if(tur == 1)
		{
			<cfif isdefined('get_empty_employee')>
				z = <cfoutput>#get_empty_employee.recordcount#</cfoutput>;
			</cfif>
			if(document.getElementById('ek_tr'+k).value==0)
			{
				document.getElementById('operasyon1_'+k).style.display='none';
				document.getElementById('operasyon2_'+k).style.display='';
				for(var i=1; i<=z; i++) 
				{
					document.getElementById('ek_'+k+'_'+i).style.display='';
					document.getElementById('ek_tr'+k).value = 1;
				}
			}
			else
			{
				document.getElementById('operasyon1_'+k).style.display='';
				document.getElementById('operasyon2_'+k).style.display='none';
				for(var i=1; i<=z; i++) 
				{
					document.getElementById('ek_'+k+'_'+i).style.display='none';
					document.getElementById('ek_tr'+k).value = 0;
				}
			}
		}
	}
	function ilistir(station_id, employee_id)
	{
		window.location ="<cfoutput>#request.self#</cfoutput>?fuseaction=production.emptypopup_add_ezgi_vts_identity&giris=1&employee_id="+employee_id+"&station_id="+station_id;
	}
	function ayir(employee_id)
	{
		window.location ="<cfoutput>#request.self#</cfoutput>?fuseaction=production.upd_ezgi_station_employee_exit&giris=1&id="+employee_id;
	}
	function sonlandir(station_id, employee_id, p_operation_id)
	{
		sor = confirm('<cf_get_lang dictionary_id='417.Üretim İçin Sonuç Girmeden Çıkmak İstediğinizden Emin misiniz'>?');
		if(sor==true)
		{
			window.location ="<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_upd_ezgi_station_employee_exit&giris=1&id="+employee_id+"&station_id="+station_id+"&p_operation_id="+p_operation_id;
		}
		else
			return false;
	}
	function basla(station_id, action_employee_id, p_order_id, p_operation_id)
	{
		window.open("<cfoutput>#request.self#?fuseaction=production.popup_add_ezgi_production_order&collect=1&start_date=#Dateformat(now(),dateformat_style)#</cfoutput>&upd="+p_order_id+"&station_id="+station_id+"&employee_id="+action_employee_id+"&p_operation_id="+p_operation_id, "_blank", "toolbar=no,scrollbars=no,resizable=no,top=200,left=300,width=1000,height=550");
	}
	
	function main_menu_select(main_menu)
	{
		master_plan_id=document.getElementById('master_plan').value;
		window.location ="<cfoutput>#request.self#</cfoutput>?fuseaction=production.list_ezgi_collect_production&main_menu="+main_menu+"&master_plan="+master_plan_id;
	}
	function operation_select(sub_menu)
	{
		master_plan_id=document.getElementById('master_plan').value;
		window.location ="<cfoutput>#request.self#?fuseaction=production.list_ezgi_collect_production&main_menu=#attributes.main_menu#</cfoutput>&sub_menu="+sub_menu+"&master_plan="+master_plan_id;
	}
	function main_row(row_tur,currentrow)
	{
		<cfif attributes.main_menu eq 2>
			<cfif isdefined('attributes.lot_number') and len(attributes.lot_number) or attributes.sub_menu eq 4>
				<cfif get_product_orders.recordcount>
					<cfoutput query="get_product_orders" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
						<cfif isdefined('get_stations_#get_product_orders.currentrow#')>
							<cfif Evaluate('get_stations_#get_product_orders.currentrow#').recordcount>
								z=#Evaluate('get_stations_#get_product_orders.currentrow#').recordcount#;
								if(document.getElementById('ek_tr'+#get_product_orders.currentrow#).value==0)
								{
									if(#get_product_orders.currentrow#==currentrow)
									{
										document.getElementById('station1_'+#get_product_orders.currentrow#).style.display='none';
										document.getElementById('station2_'+#get_product_orders.currentrow#).style.display='';
										for(var i=1; i<=z; i++) 
										{
											document.getElementById('ek_'+i+'_'+#get_product_orders.currentrow#).style.display='';
											document.getElementById('ek_tr'+#get_product_orders.currentrow#).value = 1;
										}
									}
								}
								else
								{
									if(#get_product_orders.currentrow#==currentrow)
									{
										document.getElementById('station1_'+#get_product_orders.currentrow#).style.display='';
										document.getElementById('station2_'+#get_product_orders.currentrow#).style.display='none';
										for(var i=1; i<=z; i++) 
										{
											document.getElementById('ek_'+i+'_'+#get_product_orders.currentrow#).style.display='none';
											document.getElementById('ek_tr'+#get_product_orders.currentrow#).value = 0;
										}
									}
								}
							</cfif>
						</cfif>
					</cfoutput>
				</cfif>
			</cfif>
		</cfif>
	}
</script>
