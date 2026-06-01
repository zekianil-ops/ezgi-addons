<!---
    File: list_ezgi_production_operation.cfm
    Folder: Add_Ons\ezgi\e-vts\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset fuseaction_ = ListGetAt(attributes.fuseaction,2,'.')>
<cfparam name="authority_station_id_list" default="0">
<cfparam name="attributes.lot_number" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.is_form_submitted" default="">
<cfparam name="attributes.station_id" default="">
<cfparam name="attributes.operation_type_id" default="">
<cfparam name="attributes.is_show" default="1">
<cfparam name="attributes.master_plan" default="">
<cfif isdefined("attributes.start_date") and isdate(attributes.start_date)>
	<cf_date tarih="attributes.start_date">
<cfelse>
	<cfset attributes.start_date = wrk_get_today()>
</cfif>
<cfif isdefined("attributes.finish_date") and isdate(attributes.finish_date)>
	<cf_date tarih="attributes.finish_date">
<cfelse>
	<cfset attributes.finish_date = date_add('d',1,attributes.start_date)>
</cfif>
<!---İstasyon Bilgileri Alınıyor--->
<cfquery name="get_workstation_name" datasource="#dsn3#">
	SELECT STATION_NAME,STATION_ID,EZGI_PACKAGE_CONTROL,ISNULL(EZGI_ORDER_CONTROL,0) AS EZGI_ORDER_CONTROL FROM WORKSTATIONS WHERE STATION_ID = #attributes.station_id#
</cfquery>
<cfif isdefined('attributes.new_employee')>
	<cfset add_employee = 1>
	<cfinclude template="../query/add_ezgi_station_employee.cfm">
</cfif>
<!---Operasyon Bilgileri Alınıyor--->
<cfquery name="get_workstation_operations" datasource="#dsn3#">
	SELECT 
    	WP.OPERATION_TYPE_ID, 
        OT.OPERATION_TYPE
	FROM     
    	WORKSTATIONS_PRODUCTS AS WP INNER JOIN
        OPERATION_TYPES AS OT ON WP.OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID
	WHERE  
    	WP.WS_ID = #attributes.station_id# AND 
        NOT (WP.OPERATION_TYPE_ID IS NULL)
</cfquery>
<!---İstasyonda Çalışanların Bilgileri Alınıyor--->
<cfquery name="get_station_employee" datasource="#dsn3#">
	SELECT EMPLOYEE_ID FROM EZGI_STATION_EMPLOYEE WHERE STATION_ID = #attributes.station_id# AND FINISH_DATE IS NULL AND EMPLOYEE_ID <> #attributes.employee_id#
</cfquery>
<!---Şu an Duraklama var mı? Bilgileri Alınıyor--->
<cfquery name="get_prod_pause" datasource="#dsn3#">
	SELECT     
    	PROD_PAUSE_TYPE_ID
	FROM         
    	SETUP_PROD_PAUSE
	WHERE     
        STATION_ID = #attributes.station_id# AND 
        EMPLOYEE_ID = #attributes.employee_id# AND 
        PROD_DURATION IS NULL
</cfquery>
<!---Duraklama Bilgileri Alınıyor--->
<cfif get_prod_pause.recordcount>
	<cfquery name="get_prod_pause_cat" datasource="#dsn3#">
    	SELECT     
        	PROD_PAUSE_CAT_ID
		FROM         
        	SETUP_PROD_PAUSE_TYPE
		WHERE     
        	PROD_PAUSE_TYPE_ID = #get_prod_pause.PROD_PAUSE_TYPE_ID#
    </cfquery>
    <cfif get_prod_pause_cat.recordcount>
    	<cfset pause_cat = get_prod_pause_cat.PROD_PAUSE_CAT_ID>
    <cfelse>
    	<cfset pause_cat = 0>
    </cfif>
<cfelse>
	<cfset pause_cat = 0>
</cfif>
<!---Üretim Programında Oluşan Plan Bilgileri Alınıyor--->
<cfquery name="GET_MASTER_PLAN_1" datasource="#dsn3#">
	SELECT 
    	EIMAP.MASTER_PLAN_ID,
         EIMAP.MASTER_PLAN_NUMBER, 
         EIMAP.MASTER_PLAN_DETAIL, 
         EIMAP.RECORD_DATE
	FROM     
   		EZGI_IFLOW_MASTER_PLAN AS EIMAP INNER JOIN
      	#dsn_alias#.SETUP_SHIFTS AS SS ON EIMAP.MASTER_PLAN_CAT_ID = SS.SHIFT_ID INNER JOIN
      	WORKSTATIONS AS WW ON SS.DEPARTMENT_ID = WW.DEPARTMENT
	WHERE  
    	SS.IS_PRODUCTION = 1 AND 
        WW.STATION_ID = #attributes.station_id# AND 
        EIMAP.MASTER_PLAN_STATUS = 1
	ORDER BY 
    	MASTER_PLAN_NUMBER
</cfquery>
<!---Master Planda Oluşan Plan Bilgileri Alınıyor--->
<cfquery name="GET_MASTER_PLAN_2" datasource="#dsn3#">
    SELECT 
    	EMAP.MASTER_ALT_PLAN_ID MASTER_PLAN_ID,
        EMAP.MASTER_ALT_PLAN_NO MASTER_PLAN_NUMBER,  
        convert(varchar, EMAP.PLAN_START_DATE,103) MASTER_PLAN_DETAIL, 
        EMAP.RECORD_DATE
	FROM     
    	EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
     	EZGI_MASTER_PLAN_SABLON AS EMAS ON EMAP.PROCESS_ID = EMAS.PROCESS_ID INNER JOIN
      	WORKSTATIONS AS W ON EMAS.WORKSTATION_ID = W.STATION_ID INNER JOIN
      	WORKSTATIONS AS W1 ON W.DEPARTMENT = W1.DEPARTMENT
	WHERE  
        W1.STATION_ID = #attributes.station_id# AND
       	EMAS.WORKSTATION_ID IN
                      		(
                            	SELECT 
                                	UP_STATION
                       			FROM      
                                	WORKSTATIONS AS WW
                       			WHERE   
                                	STATION_ID = #attributes.station_id#
                           	)

  	ORDER BY 
    	EMAP.PLAN_START_DATE
</cfquery>
<!---Plan Bilgileri Birleştiriliyor--->
<cfquery name="GET_MASTER_PLAN" dbtype="query">
    SELECT
    	1 AS TYPE,
    	MASTER_PLAN_ID,
        MASTER_PLAN_NUMBER, 
        MASTER_PLAN_DETAIL, 
        RECORD_DATE	
  	FROM
    	GET_MASTER_PLAN_1
  	UNION ALL
    SELECT
    	2 AS TYPE,
    	MASTER_PLAN_ID,
        MASTER_PLAN_NUMBER, 
        MASTER_PLAN_DETAIL, 
        RECORD_DATE	
  	FROM
    	GET_MASTER_PLAN_2
</cfquery>
<!---Operasyon Bilgileri Alınıyor--->
<cfif isdefined("attributes.is_form_submitted")>
	<cfif get_workstation_name.EZGI_PACKAGE_CONTROL eq 7><!---Şartlı Liste İse Şartlı Liste Oluşturmak Gerekir.--->
		<cfinclude template="/v16/add_options/ezgi/e_furniture/get_ezgi_operations_list.cfm">
	<cfelse>
        <cfquery name="GET_PO_DET" datasource="#dsn3#">
			SELECT
				EOM.P_ORDER_ID, 
				EOM.PO_RELATED_ID, 
				EOM.LOT_NO, 
				EOM.P_ORDER_NO, 
				EOM.IS_STAGE, 
				EOM.START_DATE, 
				EOM.STOCK_ID, 
				EOM.STOCK_CODE_2,
				CASE 
					WHEN 
						(SELECT ISNULL(IS_PROTOTYPE,0) AS IS_PROTOTYPE FROM STOCKS WHERE STOCK_ID = EOM.STOCK_ID) = 0
					THEN 
						EOM.PRODUCT_NAME
					ELSE
					(
						SELECT 
							TOP (1) PRODUCT_NAME
						FROM     
							EZGI_DESIGN_SPECT_RELATED
						WHERE  
							SPECT_MAIN_ID = EOM.SPEC_MAIN_ID
						ORDER BY 
							SPECT_MAIN_ID DESC

					)
				END	AS PRODUCT_NAME,
				EOM.PRODUCT_NAME NAME_PRODUCT,
				EOM.P_OPERATION_ID, 
				EOM.OPERATION_TYPE_ID, 
				EOM.OPERATION_CODE, 
				EOM.OPERATION_TYPE, 
				EOM.O_START_DATE,
				EOM.O_STATION_IP,
				EOM.O_CURRENT_NUMBER,
				EOM.ACTION_EMPLOYEE_ID, 
				ISNULL(sum(EOM.LOSS_AMOUNT),0) LOSS_AMOUNT, 
				ISNULL(
					(
					SELECT
						SUM(POR_.AMOUNT) ORDER_AMOUNT
					FROM
						PRODUCTION_ORDER_RESULTS_ROW POR_,
						PRODUCTION_ORDER_RESULTS POO
					WHERE
						POR_.PR_ORDER_ID = POO.PR_ORDER_ID
						AND POO.P_ORDER_ID = EOM.P_ORDER_ID
						AND POR_.TYPE = 1
						AND POO.IS_STOCK_FIS = 1
					)
				,0) ROW_RESULT_AMOUNT,
				(
					SELECT        
						EM.MASTER_PLAN_NUMBER
					FROM            
						EZGI_IFLOW_PRODUCTION_ORDERS AS EI INNER JOIN
						EZGI_IFLOW_MASTER_PLAN AS EM ON EI.MASTER_PLAN_ID = EM.MASTER_PLAN_ID
					WHERE        
					EI.LOT_NO = EOM.LOT_NO
				) AS MASTER_PLAN_NUMBER
				<cfif isdefined('get_workstation_name.EZGI_PACKAGE_CONTROL') and get_workstation_name.EZGI_PACKAGE_CONTROL eq 4>
					, ISNULL(EOR.REAL_AMOUNT, -1) AS TRACE_AMOUNT
					, EPOT.TRACE_NO
					,EPOT.AMOUNT 
					,ISNULL(EPOT.AMOUNT,0) REAL_AMOUNT
					,CASE
						WHEN ISNULL(EOR.REAL_AMOUNT, -1) = -1 THEN 0
						WHEN ISNULL(EOR.REAL_AMOUNT, -1) = 0 THEN 1
						WHEN ISNULL(EOR.REAL_AMOUNT, -1) = 1 THEN 3
					END AS STAGE
				<cfelse>
					,0 AS TRACE_AMOUNT
					,'' AS TRACE_NO
					,EOM.AMOUNT
					,ISNULL(EOM.OPERATION_GRUP_ID,0) AS OPERATION_GRUP_ID
					,ISNULL(sum(EOM.REAL_AMOUNT),0) REAL_AMOUNT
					,EOM.STAGE
				</cfif>
			FROM         
				EZGI_OPERATION_M EOM
				<cfif isdefined('get_workstation_name.EZGI_PACKAGE_CONTROL') and get_workstation_name.EZGI_PACKAGE_CONTROL eq 4>
					INNER JOIN
					EZGI_PRODUCTION_ORDERS_TRACE AS EPOT ON EOM.LOT_NO = EPOT.LOT_NO LEFT OUTER JOIN
					PRODUCTION_OPERATION_RESULT AS EOR ON EPOT.TRACE_NO = EOR.TRACE_NO AND EOM.P_OPERATION_ID = EOR.OPERATION_ID
				</cfif>
			WHERE
				<cfif get_workstation_name.EZGI_ORDER_CONTROL eq 1><!--- Günlük Planlar İse--->
					<cfif pause_cat eq 0><!---Duraklama Veya Arıza Yoksa--->
						EOM.P_OPERATION_ID IN 
											(
												SELECT
													P_OPERATION_ID
												FROM
													PRODUCTION_OPERATION
												WHERE
													O_STATION_IP = #attributes.station_id# AND
													O_STATION_START_DATE = #attributes.start_date#
											) AND
					<cfelse><!---Duraklama Veya Arıza Varsa Operasyonlar Listelenmesin--->
						1=0 AND
					</cfif>
					EOM.STAGE <> 3
				<cfelse>
					EOM.OPERATION_TYPE_ID IN
										(	
										SELECT     	
											OPERATION_TYPE_ID
										FROM      	
											WORKSTATIONS_PRODUCTS
										WHERE      	
											WS_ID = #attributes.station_id# AND 
											STOCK_ID IS NULL AND 
											OPERATION_TYPE_ID IS NOT NULL
										) AND 
				
					EOM.IS_STAGE IN (0,1,2,3,4)
					<cfif isdefined('attributes.all_info') and len(attributes.all_info)>
						AND EOM.IS_STAGE IN (0,1,3,4)
						<cfif len(attributes.lot_number)>
							AND 
								(
									EOM.PRODUCT_NAME LIKE '%#attributes.lot_number#%'
								)
						</cfif>
					<cfelse>
						<cfif isdefined('attributes.lot_number') and len(attributes.lot_number)> <!---Barkod Okutularak Gelirse--->
							AND(
									<cfif isdefined('get_workstation_name.EZGI_PACKAGE_CONTROL') and get_workstation_name.EZGI_PACKAGE_CONTROL eq 4><!---Takip No İle Üret İse--->
										EPOT.TRACE_NO = '#attributes.lot_number#' 
									<cfelse>
										<cfif left(attributes.lot_number,1) eq 2>
											EOM.P_ORDER_NO LIKE '#attributes.lot_number#%'       
										<cfelseif left(attributes.lot_number,1) eq 1>
											EOM.LOT_NO LIKE '#attributes.lot_number#%' 
										<cfelseif isdefined('get_workstation_name.EZGI_PACKAGE_CONTROL') and get_workstation_name.EZGI_PACKAGE_CONTROL eq 3 and left(attributes.lot_number,1)> <!---Gurupla Üret İse--->
											EOM.P_OPERATION_ID IN
																(
																	SELECT 
																		EVR.OPERATION_ID
																	FROM     
																		EZGI_VTS_OPERATION_BASKET AS EV INNER JOIN
																		EZGI_VTS_OPERATION_BASKET_ROW AS EVR ON EV.EZGI_VTS_OPERATION_BASKET_ID = EVR.EZGI_VTS_OPERATION_BASKET_ID
																	WHERE  
																		EV.BASKET_NO = #attributes.lot_number#
																)
										<cfelse>
											EOM.PRODUCT_NAME LIKE '%#attributes.lot_number#%'
										</cfif>   
									</cfif>                         
								)
						<cfelse><!--- Ara Tuşuyla Gelirse--->
							AND EOM.ACTION_EMPLOYEE_ID = #employee_id# AND 
							EOM.REAL_AMOUNT = 0 AND 
							EOM.LOSS_AMOUNT = 0 AND 
							ISNULL(EOM.REAL_TIME,0)=0 AND 
							EOM.WAIT_TIME IS NULL AND
							EOM.STAGE <> 3
							<cfif isdefined('get_workstation_name.EZGI_PACKAGE_CONTROL') and get_workstation_name.EZGI_PACKAGE_CONTROL eq 4><!---Takip No İle Üret İse--->
								AND NOT (EOR.TRACE_NO IS NULL)
							</cfif>
						</cfif>
					</cfif>
					<cfif ListLen(attributes.master_plan,'-')> <!---Master Plan Seçilmişse--->
						<cfif  ListGetat(attributes.master_plan,1,'-') eq 1> <!---Üretim Programından Seçilmişse--->
							AND EOM.LOT_NO IN 
										(
											SELECT        
												LOT_NO
											FROM          
												EZGI_IFLOW_PRODUCTION_ORDERS
											WHERE        
												MASTER_PLAN_ID = #ListGetat(attributes.master_plan,2,'-')#
										)
						<cfelse> <!---Master Plandan Seçilmişse--->
							AND EOM.LOT_NO IN 
										(
											SELECT 
												PO.LOT_NO
											FROM     
												EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
												EZGI_MASTER_PLAN_RELATIONS AS EMAR ON EMAP.MASTER_ALT_PLAN_ID = EMAR.MASTER_ALT_PLAN_ID INNER JOIN
												PRODUCTION_ORDERS AS PO ON EMAR.P_ORDER_ID = PO.P_ORDER_ID
											WHERE  
												EMAP.MASTER_ALT_PLAN_ID = #ListGetat(attributes.master_plan,2,'-')# OR
												EMAP.RELATED_MASTER_ALT_PLAN_ID = #ListGetat(attributes.master_plan,2,'-')#
										) 
						</cfif> 
					</cfif>
					<cfif get_workstation_operations.recordcount gt 1 and isdefined('attributes.operation_type_id') and len(attributes.operation_type_id)>
						AND EOM.OPERATION_TYPE_ID = #attributes.operation_type_id#
					</cfif>
				</cfif>
			GROUP BY
				EOM.P_ORDER_ID, 
				EOM.PO_RELATED_ID, 
				EOM.LOT_NO, 
				EOM.P_ORDER_NO, 
				EOM.IS_STAGE, 
				EOM.START_DATE, 
				EOM.STOCK_ID, 
				EOM.SPEC_MAIN_ID,
				EOM.STOCK_CODE_2,
				EOM.PRODUCT_NAME, 
				EOM.P_OPERATION_ID, 
				EOM.OPERATION_TYPE_ID, 
				EOM.OPERATION_CODE, 
				EOM.OPERATION_TYPE, 
				EOM.STAGE, 
				EOM.O_START_DATE,
				EOM.O_STATION_IP,
				EOM.O_CURRENT_NUMBER,
				EOM.ACTION_EMPLOYEE_ID
				<cfif isdefined('get_workstation_name.EZGI_PACKAGE_CONTROL') and get_workstation_name.EZGI_PACKAGE_CONTROL eq 4>
					,EOR.REAL_AMOUNT
					,EPOT.TRACE_NO
					,EPOT.AMOUNT 
				<cfelse>
					,EOM.AMOUNT
					,EOM.OPERATION_GRUP_ID
				</cfif>
			ORDER BY
				<cfif isdefined('attributes.all_info') and len(attributes.all_info)>
					EOM.STAGE,
					EOM.P_ORDER_ID,
					EOM.O_CURRENT_NUMBER,
					EOM.O_START_DATE,
					EOM.OPERATION_TYPE 
				<cfelse>
					EOM.STAGE,
					EOM.O_CURRENT_NUMBER,
					EOM.P_ORDER_NO DESC ,
					EOM.OPERATION_TYPE   
				</cfif>         
    	</cfquery>
	</cfif>
    <cfset ezgi_operation_id_list = ValueList(GET_PO_DET.P_OPERATION_ID)>
<cfelse>
	<cfset GET_PO_DET.recordcount = 0>
</cfif>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='250'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfif get_po_det.recordcount>
	<cfparam name="attributes.totalrecords" default='#get_po_det.recordcount#'>
<cfelse>
	<cfparam name="attributes.totalrecords" default='0'>
</cfif>
<cfif get_po_det.recordcount>
	<cfset p_order_id_list = ''>
	<cfset po_related_id_list = ''>
	<cfset station_id_list = ''>
	<cfoutput query="get_po_det" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
		<cfif len(p_order_id) and not listfind(p_order_id_list,p_order_id)>
			<cfset p_order_id_list=listappend(p_order_id_list,p_order_id)>
		</cfif>
		<cfif len(po_related_id) and not listfind(po_related_id_list,po_related_id)>
			<cfset po_related_id_list=listappend(po_related_id_list,po_related_id)>
		</cfif>
		<cfif len(station_id) and not listfind(station_id_list,station_id)>
			<cfset station_id_list=listappend(station_id_list,station_id)>
		</cfif>
	</cfoutput>
    <!---Sipariş Bilgileri Alınıyor--->
	<cfquery name="GET_ROW" datasource="#dsn3#">
		SELECT
			ORDER_NUMBER,
			PRODUCTION_ORDERS_ROW.PRODUCTION_ORDER_ID P_ORDER_ID
		FROM
			PRODUCTION_ORDERS_ROW,
			ORDERS
		WHERE
			PRODUCTION_ORDERS_ROW.PRODUCTION_ORDER_ID IN(#p_order_id_list#) AND
			PRODUCTION_ORDERS_ROW.ORDER_ID = ORDERS.ORDER_ID 
	</cfquery>
	<cfloop query="GET_ROW">
		<cfif not isdefined('order_list_#p_order_id#')>
			<cfset 'order_list_#p_order_id#' = ORDER_NUMBER>
		<cfelse>
			<cfset 'order_list_#p_order_id#' = listdeleteduplicates(ListAppend(Evaluate('order_list_#p_order_id#'),ORDER_NUMBER,','))>
		</cfif>
	</cfloop>
	<cfif len(po_related_id_list)>
    	<!---Üst Plan Bilgileri Alınıyor--->
		<cfquery name="get_related_order" datasource="#DSN3#">
			SELECT P_ORDER_ID,P_ORDER_NO,PO_RELATED_ID FROM PRODUCTION_ORDERS WHERE PO_RELATED_ID IN (#po_related_id_list#) ORDER BY P_ORDER_ID
		</cfquery>
		<cfloop query="get_related_order">
			<cfif not isdefined('po_related_list_#p_order_id#')>
				<cfset 'po_related_list_#p_order_id#' = P_ORDER_NO>
			<cfelse>
				<cfset 'po_related_list_#p_order_id#' = listdeleteduplicates(ListAppend(Evaluate('po_related_list_#p_order_id#'),P_ORDER_NO,','))>
			</cfif>
		</cfloop>
	</cfif>
	<cfif len(station_id_list)>
		<cfset station_id_list=listsort(station_id_list,"numeric","ASC",",")>
        
		<cfquery name="get_w" datasource="#dsn3#">
			SELECT STATION_NAME,STATION_ID FROM WORKSTATIONS WHERE STATION_ID IN (#station_id_list#) ORDER BY STATION_ID
		</cfquery>
		<cfset station_id_list = listsort(listdeleteduplicates(valuelist(get_w.STATION_ID,',')),'numeric','ASC',',')>
	</cfif>
</cfif>
<cfscript>wrkUrlStrings('url_str','is_form_submitted','lot_number');</cfscript>
<cfset url_str = url_str & "&station_id=#station_id#&employee_id=#employee_id#">
<cfif isdate(attributes.start_date)>
	<cfset url_str = url_str & "&start_date=#dateformat(attributes.start_date,dateformat_style)#">
</cfif>
<cfif isdate(attributes.finish_date)>
	<cfset url_str = url_str & "&finish_date=#dateformat(attributes.finish_date,dateformat_style)#">
</cfif>




<cfif isdate(attributes.master_plan)>
	<cfset url_str = url_str & "&master_plan=#attributes.master_plan#">
</cfif>
<!---İstasyon ve Çalışan için Guruplama Varmı Bilgileri Alınıyor--->
<cfquery name="get_employee_durum" datasource="#dsn3#">
	SELECT  
    	ISNULL(REAL_AMOUNT, 0) AS REAL_AMOUNT,
        P_OPERATION_ID,
        ISNULL(OPERATION_GRUP_ID,0) AS OPERATION_GRUP_ID
	FROM        
    	EZGI_OPERATION_M
	WHERE     
    	ACTION_EMPLOYEE_ID = #attributes.employee_id# AND 
        STATION_ID = #attributes.station_id# AND
        STAGE = 1 AND
        LOSS_AMOUNT=0 AND
        REAL_AMOUNT=0 
</cfquery>
<cfquery name="get_employee_durum_gurup" dbtype="query">
	SELECT
    	OPERATION_GRUP_ID
   	FROM
 		get_employee_durum
    GROUP BY
    	OPERATION_GRUP_ID
</cfquery>
<cfif get_employee_durum_gurup.recordcount>
	<cfset ezgi_operation_gurup_id = get_employee_durum_gurup.OPERATION_GRUP_ID>
    <cfquery name="get_gurup_durum" datasource="#dsn3#">
        SELECT     
            IS_RESULT
        FROM         
            EZGI_OPERATION_GRUP_NO
        WHERE     
            OPERATION_GRUP_ID = #ezgi_operation_gurup_id#
    </cfquery>
    <cfset ezgi_operation_gurup_id_durum = get_gurup_durum.IS_RESULT>
<cfelse>
	<cfset ezgi_operation_gurup_id_durum = 0>
</cfif>


<cfset p_operation_id_list = Valuelist(get_employee_durum.P_OPERATION_ID)>
<cfif get_workstation_name.EZGI_PACKAGE_CONTROL eq 3 and isdefined('ezgi_operation_id_list') and ListLen(ezgi_operation_id_list)>
	<cfquery name="get_operation_basket" datasource="#dsn3#">
    	SELECT 
        	EVR.OPERATION_ID
		FROM     
        	EZGI_VTS_OPERATION_BASKET AS EV INNER JOIN
            EZGI_VTS_OPERATION_BASKET_ROW AS EVR ON EV.EZGI_VTS_OPERATION_BASKET_ID = EVR.EZGI_VTS_OPERATION_BASKET_ID
		WHERE  
        	EVR.OPERATION_ID IN (#ezgi_operation_id_list#)
    </cfquery>
    <cfif get_operation_basket.recordcount>
    	<cfset operation_basket_id_list = ValueList(get_operation_basket.OPERATION_ID)>
    <cfelse>
    	<cfset operation_basket_id_list = ''>
    </cfif>
</cfif>
<style>
	.box_yazi {font-size:16px;border-color:#666666;font:bold} 
	.box_yazi_td {font-size:18px!important;border-color:#666666;padding:12px 5px!important;} 
	.box_yazi_small {font-size:11px;border-color:#666666;} 
	.a_box_yazi {font-size:16px;border-color:#BDCAC5;font:bold} 
	.a_box_yazi_td {font-size:14px;border-color:#BDCAC5;} 
	.tablesorter-header-inner{font-size:20px!important;}
	.ui-btn{padding: 9px 20px!important;}
	.portBox .portHeadLightTitle span a{
		font-size:30px!important;
	}
</style>
<cf_box>
	<cfform name="search_list" id="search_list" action="#request.self#?fuseaction=production.#fuseaction_#" method="post">
		<cfinput type="hidden" name="all_info" id="all_info" value="">
		<cfinput type="hidden" name="is_form_submitted" value="1">
		<cfinput type="hidden" name="station_id" value="#station_id#">
		<cfinput type="hidden" name="employee_id" value="#employee_id#">
		<cf_box_search>
        	<cfif get_workstation_name.EZGI_ORDER_CONTROL eq 1><!---Sadece Günlük Planlanan Emirler Gelecekse--->
            	<div class="form-group">
                	 <cfif get_employee_durum.recordcount and get_employee_durum.REAL_AMOUNT eq 0><!--- Üretim Başladıysa ve Operatörün elinde iş varsa--->
                         <a href="javascript://" onclick="delete_control(0,'');">
                            <button type="button" name="worked" class="ui-ripple-btn act" style="margin:5px 5px;background-color:#f35d5d;width:120px;height:50px;"><cf_get_lang dictionary_id='40137.Çalışıyor'></button>
                        </a>
                   	<cfelse>
                    	<cfif pause_cat eq 0>
                            <a href="javascript://" onclick="myworks(0);">
                                <button type="button" name="my_works" class="ui-ripple-btn act" style="margin:5px 5px;width:120px;height:50px;"><cf_get_lang dictionary_id='33399.İşlerim'></button>
                            </a>
                        <cfelse>
                            <button type="button" name="degistir" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"></button>
                        </cfif>    
                     	<cfif pause_cat eq 0>
                            <a href=<cfoutput>"#request.self#?fuseaction=production.upd_ezgi_station_employee&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&upd_employee=1"</cfoutput>>
                                <button type="button" name="degistir" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"><cf_get_lang dictionary_id='57431.Çıkış'></button>
                            </a>
                        <cfelse>
                            <button type="button" name="degistir" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"></button>
                        </cfif>
                        <cfif pause_cat eq 3 or pause_cat eq 0>
                            <a href="javascript://" onclick="prod_pause(3);">
                                <button type="button" name="ariza" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"><cf_get_lang dictionary_id='298.Arıza'></button>
                            </a>
                        <cfelse>
                            <button type="button" name="ariza" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"></button>
                        </cfif>
                        
                        <cfif pause_cat eq 2 or pause_cat eq 0>
                            <a href="javascript://" onclick="prod_pause(2);">
                                <button type="button" name="duraklama" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"><cf_get_lang dictionary_id='300.Duraklama'></button>
                            </a>
                        <cfelse>
                            <button type="button" name="duraklama" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"></button>
                        </cfif>
                  	</cfif>
                    <a href="javascript://" onclick="geri();">
                        <button type="button" name="geri" class="ui-ripple-btn" style="margin:5px 5px;background-color: #ff9b05;width:120px;height:50px;">Partner Ekle</button>
                    </a>  
                </div>
            <cfelse>
                <div class="form-group">
                    <cfif get_employee_durum.recordcount and get_employee_durum.REAL_AMOUNT eq 0><!--- Üretim Başladıysa ve Operatörün elinde iş varsa--->
                        <cfif not get_workstation_name.EZGI_PACKAGE_CONTROL eq 3><!--- Toplu Üret Değil İse--->
                            <a href="javascript://" onclick="delete_control(0,'');">
                                
                                <button type="button" name="worked" class="ui-ripple-btn act" style="margin:5px 5px;background-color:#f35d5d;width:120px;height:50px;"><cf_get_lang dictionary_id='40137.Çalışıyor'></button>
                            </a>
                            <a href="javascript://" onclick="myworks(0);">
                                <button type="button" name="my_works" class="ui-ripple-btn act" style="margin:5px 5px;width:120px;height:50px;"><cf_get_lang dictionary_id='33399.İşlerim'></button>
                            </a>
                        </cfif>
                    <cfelse>
                        <cfif pause_cat eq 0>
                            <a href=<cfoutput>"#request.self#?fuseaction=production.upd_ezgi_station_employee&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&upd_employee=1"</cfoutput>>
                                <button type="button" name="degistir" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"><cf_get_lang dictionary_id='57431.Çıkış'></button>
                            </a>
                        <cfelse>
                            <button type="button" name="degistir" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"></button>
                        </cfif>
                        <cfif pause_cat eq 3 or pause_cat eq 0>
                            <a href="javascript://" onclick="prod_pause(3);">
                                <button type="button" name="ariza" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"><cf_get_lang dictionary_id='298.Arıza'></button>
                            </a>
                        <cfelse>
                            <button type="button" name="ariza" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"></button>
                        </cfif>
                        
                        <cfif pause_cat eq 2 or pause_cat eq 0>
                            <a href="javascript://" onclick="prod_pause(2);">
                                <button type="button" name="duraklama" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"><cf_get_lang dictionary_id='300.Duraklama'></button>
                            </a>
                        <cfelse>
                            <button type="button" name="duraklama" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"></button>
                        </cfif>
                    </cfif>
                    <a href="javascript://" onclick="geri();">
                        <button type="button" name="geri" class="ui-ripple-btn" style="margin:5px 5px;background-color: #ff9b05;width:120px;height:50px;">Partner Ekle</button>
                    </a>
                </div>
                <div class="form-group">
                    <cfif get_workstation_operations.recordcount gt 1>
                        <select name="operation_type_id" id="operation_type_id" style="font-size:16px; font-weight:bold; height:50px; width:200px">
                            <cfoutput query="get_workstation_operations">
                                <option value="#OPERATION_TYPE_ID#" <cfif attributes.operation_type_id eq OPERATION_TYPE_ID>selected</cfif>>#OPERATION_TYPE#</option>
                            </cfoutput>
                        </select>
                    </cfif>
                </div>
                <div class="form-group">
                    <select name="master_plan" id="master_plan" style="font-size:16px; font-weight:bold; height:50px; width:200px">
                        <option value="" <cfif attributes.master_plan eq ''>selected</cfif>>Üretim Seçiniz</option>
                        <cfoutput query="get_master_plan">
                            <option value="#TYPE#-#MASTER_PLAN_ID#" <cfif week(get_master_plan.RECORD_DATE)-week(now()) eq 0>style="background-color:palegreen"</cfif> <cfif Listlen(attributes.master_plan,'-') and ListGetat(attributes.master_plan,2,'-') eq #MASTER_PLAN_ID# and ListGetat(attributes.master_plan,1,'-') eq #TYPE#>selected</cfif>>#MASTER_PLAN_NUMBER# - #MASTER_PLAN_DETAIL#</option>
                        </cfoutput>
                    </select>
                </div>
                <div class="form-group" style="margin: 0px 15px 0px 15px!important;">
                    <cfsavecontent variable="baslik"><cf_get_lang dictionary_id='36698.Lot No'> / <cf_get_lang dictionary_id='29474.Emir No'></cfsavecontent>
                    <input name="lot_number" id="lot_number"  type="text" value="" placeholder="<cfoutput>#baslik#</cfoutput>" onKeyDown="if(event.keyCode == 13) {return location_production_detail(trim(this.value));}" style="width:140px; height:50px!important; font-size:17px; font-weight:bold; vertical-align:top">
                </div>
                <div class="form-group">
                    <cfif pause_cat eq 3 or pause_cat eq 0>
                        <a class="ui-btn ui-btn-green" href="javascript://" onclick="tumu();">
                            <button type="button" name="tumu" style="cursor:pointer; vertical-align:bottom;  background-color:transparent; border:none"><i class="fa fa-search"></i></button>
                         </a>
                    <cfelse>
                        <button type="button" name="tumu" style="cursor:pointer; vertical-align:bottom;  background-color:transparent; border:none"><i class="fa fa-search"></i></button>
                    </cfif>
                </div>
                <div class="form-group" id="form_ul_data_explorer">
                    <a class="ui-btn ui-btn-gray2" onclick="yazdir()"><i class="fa fa-print"></i></a>						
                </div>
                <div class="form-group">
                    
                </div>
            </cfif>
		</cf_box_search>
	</cfform>
</cf_box>
	<cf_box title="Üretim Listesi" uidrop="1" hide_table_column="1">
		<cf_grid_list>
			<thead>
				<tr>
					<th class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id ='57487.No'></th>
					<th class="box_yazi" style="text-align:center" width="8%"><cf_get_lang dictionary_id='57742.Tarih'></th>
					<cfif isdefined('get_workstation_name.EZGI_PACKAGE_CONTROL') and get_workstation_name.EZGI_PACKAGE_CONTROL eq 4>
						<th class="box_yazi" style="text-align:center" width="8%">Takip No</th>
					<cfelse>
						<th class="box_yazi" style="text-align:center" width="8%"><cf_get_lang dictionary_id='29474.Emir No'></th>
					</cfif>
					<cfif not get_workstation_name.EZGI_PACKAGE_CONTROL eq 3><!--- Toplu Üret İse--->
						<th class="box_yazi" style="text-align:center" width="8%"><cf_get_lang dictionary_id='301.Operatör'></th>
					</cfif>
					<th class="box_yazi" style="text-align:center" ><cf_get_lang dictionary_id ='38089.Mamül Adı'></th>
					<th class="box_yazi" style="text-align:center" width="15%"><cf_get_lang dictionary_id='29419.Operasyon'></th>
					<th class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id='57635.Miktar'></th>
					<th class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id='29471.Fire'></th>
					<th class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id='302.Biten'></th>
					<th class="box_yazi" style="text-align:center" width="4%"><cf_get_lang dictionary_id='58444.Kalan'></th>
					<th class="box_yazi" style="text-align:center" width="3%"><cf_get_lang dictionary_id='1139.OP.'></th>
					<th class="box_yazi" style="text-align:center" width="3%"><cf_get_lang dictionary_id='1140.IE.'></th>
					<cfif get_workstation_name.EZGI_PACKAGE_CONTROL eq 3><!--- Toplu Üret İse--->
						<th class="box_yazi" style="text-align:center" width="3%"></th>
					</cfif>
				</tr>
			</thead>
			<tbody>
				<cfoutput query="get_po_det">
					<tr height="50" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
						<td class="box_yazi_td" style="text-align:center">
							<cfif (get_workstation_name.EZGI_PACKAGE_CONTROL neq 4 and get_employee_durum.recordcount and ACTION_EMPLOYEE_ID eq attributes.employee_id and STAGE eq 1) or (get_workstation_name.EZGI_PACKAGE_CONTROL eq 4 and ACTION_EMPLOYEE_ID eq attributes.employee_id and STAGE eq 1)>
								<a href="javascript://" onclick="delete_control(#P_OPERATION_ID#,'#TRACE_NO#');">
									<button type="button" name="worked" class="ui-ripple-btn act" style="width:120px; background-color:##f35d5d;;font-size:18px; font-weight:bold;height:40px">Çık</button>
								</a>
							<cfelse>
								&nbsp;#currentrow#
							</cfif>
						</td>
						<td class="box_yazi_td" style="text-align:center">&nbsp;
							<cfif len(O_START_DATE)>
								#DateFormat(O_START_DATE,dateformat_style)#
							<cfelse>
								#DateFormat(START_DATE,dateformat_style)#
							</cfif>
						</td>
						<td class="box_yazi_td" style="text-align:center">
							<cfif isdefined('get_workstation_name.EZGI_PACKAGE_CONTROL') and get_workstation_name.EZGI_PACKAGE_CONTROL eq 4>
								&nbsp;#TRACE_NO#
							<cfelse>
								&nbsp;#P_ORDER_NO#<br>#LOT_NO#
							</cfif>
						</td>
						<cfif not get_workstation_name.EZGI_PACKAGE_CONTROL eq 3><!--- Toplu Üret İse--->
							<td class="box_yazi_td" style="text-align:center;" nowrap="nowrap">&nbsp;
								<cfif not get_workstation_name.EZGI_PACKAGE_CONTROL eq 4>  <!---Takipli Üret Değilse--->
									<cfif (get_employee_durum.recordcount and not ListContains(p_operation_id_list,P_OPERATION_ID,',') and STAGE neq 3 and OPERATION_GRUP_ID eq 0) >
										<a href="#request.self#?fuseaction=production.add_ezgi_production_order&upd=#p_order_id#&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&p_operation_id=#P_OPERATION_ID#&start_date=#Dateformat(attributes.start_date,dateformat_style)#&operation_gurup_id=#ezgi_operation_gurup_id#" style="font-size:14px" class="tableyazi">
											<button type="button" name="gurupla" style="background-color:MediumBlue; color:white;width:120px; font-size:14px; font-weight:bold;height:40px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id ='36815.Grupla'></button>
										</a>
									<cfelseif (get_employee_durum.recordcount and ListContains(p_operation_id_list,P_OPERATION_ID,',') and STAGE neq 3 and OPERATION_GRUP_ID gt 0)>
										<a href="#request.self#?fuseaction=production.add_ezgi_production_order&upd=#p_order_id#&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&p_operation_id=#P_OPERATION_ID#&start_date=#Dateformat(attributes.start_date,dateformat_style)#&operation_gurup_id=#ezgi_operation_gurup_id#" style="font-size:14px" class="tableyazi">
											<button type="button" name="seciniz" style="width:120px; font-size:14px; font-weight:bold;height:40px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='57734.Seçiniz'></button>
										</a>
									<cfelseif (get_employee_durum.recordcount and ListContains(p_operation_id_list,P_OPERATION_ID,',') and STAGE neq 3) or ACTION_EMPLOYEE_ID eq '' or (real_amount neq 0 or loss_amount neq 0 and stage eq 1)>
										<a href="#request.self#?fuseaction=production.add_ezgi_production_order&upd=#p_order_id#&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&p_operation_id=#P_OPERATION_ID#&start_date=#Dateformat(attributes.start_date,dateformat_style)#" style="font-size:14px" class="tableyazi">
											<button type="button" name="seciniz" style="width:120px; font-size:14px; font-weight:bold;height:40px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='57734.Seçiniz'></button>
										</a>
									<cfelseif (not get_employee_durum.recordcount and ACTION_EMPLOYEE_ID neq attributes.employee_id and STAGE neq 3)> 
										<a href="#request.self#?fuseaction=production.add_ezgi_production_order&upd=#p_order_id#&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&p_operation_id=#P_OPERATION_ID#&start_date=#Dateformat(attributes.start_date,dateformat_style)#" style="font-size:14px" class="tableyazi">
											<button type="button" name="isleniyor" style="background-color:Gold; color:white;width:120px; font-size:14px; font-weight:bold;height:40px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='57705.İşleniyor'></button>
										</a>
									<cfelse>
										#get_emp_info(ACTION_EMPLOYEE_ID,0,0)#
									</cfif>
								<cfelse>
									<cfif get_employee_durum.recordcount and TRACE_AMOUNT eq -1>
										<a href="#request.self#?fuseaction=production.add_ezgi_production_order&trace_no=#TRACE_NO#&upd=#p_order_id#&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&p_operation_id=#P_OPERATION_ID#&start_date=#Dateformat(attributes.start_date,dateformat_style)#&operation_gurup_id=#ezgi_operation_gurup_id#" style="font-size:14px" class="tableyazi">
											<button type="button" name="gurupla" style="background-color:MediumBlue; color:white;width:120px; font-size:14px; font-weight:bold;height:40px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id ='36815.Grupla'></button>
										</a>
									<cfelseif (get_employee_durum.recordcount and ListContains(p_operation_id_list,P_OPERATION_ID,',') and STAGE neq 3)>
										<a href="#request.self#?fuseaction=production.add_ezgi_production_order&trace_no=#TRACE_NO#&upd=#p_order_id#&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&p_operation_id=#P_OPERATION_ID#&start_date=#Dateformat(attributes.start_date,dateformat_style)#&operation_gurup_id=#ezgi_operation_gurup_id#" style="font-size:14px" class="tableyazi">
											<button type="button" name="seciniz" style="width:120px; font-size:14px; font-weight:bold;height:40px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='57734.Seçiniz'></button>
										</a>
									<cfelseif (get_employee_durum.recordcount and ListContains(p_operation_id_list,P_OPERATION_ID,',') and STAGE neq 3) or ACTION_EMPLOYEE_ID eq '' or (real_amount neq 0 or loss_amount neq 0 and stage eq 1)>
										<a href="#request.self#?fuseaction=production.add_ezgi_production_order&trace_no=#TRACE_NO#&upd=#p_order_id#&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&p_operation_id=#P_OPERATION_ID#&start_date=#Dateformat(attributes.start_date,dateformat_style)#" style="font-size:14px" class="tableyazi">
											<button type="button" name="seciniz" style="width:120px; font-size:14px; font-weight:bold;height:40px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='57734.Seçiniz'></button>
										</a>
									<cfelseif (not get_employee_durum.recordcount and ACTION_EMPLOYEE_ID neq attributes.employee_id and STAGE neq 3)> 
										<a href="#request.self#?fuseaction=production.add_ezgi_production_order&trace_no=#TRACE_NO#&upd=#p_order_id#&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&p_operation_id=#P_OPERATION_ID#&start_date=#Dateformat(attributes.start_date,dateformat_style)#" style="font-size:14px" class="tableyazi">
											<button type="button" name="isleniyor" style="background-color:Gold; color:white;width:120px; font-size:14px; font-weight:bold;height:40px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='57705.İşleniyor'></button>
										</a>
									<cfelse>
										#get_emp_info(ACTION_EMPLOYEE_ID,0,0)#
									</cfif>
								</cfif>
								&nbsp;
							</td>
						</cfif>
						<td class="box_yazi_td">
							&nbsp;<cfif len(PRODUCT_NAME)>#PRODUCT_NAME#<cfelse>#NAME_PRODUCT#</cfif>
						</td>
						<td class="box_yazi_td">&nbsp;#OPERATION_TYPE#</td>
						<td class="box_yazi_td" style="text-align:center">#AMOUNT#</td>
						<td class="box_yazi_td" style="text-align:center">#LOSS_AMOUNT#</td>
						<td class="box_yazi_td" style="text-align:center">#REAL_AMOUNT#</td>
						<td class="box_yazi_td" style="text-align:center">#AMOUNT-REAL_AMOUNT#</td>
						<td class="box_yazi_td" style="text-align:center">
							<cfif not len(STAGE)>
								<img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>!">
							<cfelseif STAGE eq 0>
								<img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='36891.Operatöre Gönderildi'>!">

							<cfelseif STAGE eq 1>
								<img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='398.Başladı'>!">
							<cfelseif STAGE eq 3>
								<img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='305.Bitti'>!">
							<cfelseif STAGE eq 4>
								<img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>!">	
							</cfif>
						</td>
						<td class="box_yazi_td" style="text-align:center">
							<cfif IS_STAGE eq 4>
								<img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id ='476.Başlamadı'>">
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
						<cfif get_workstation_name.EZGI_PACKAGE_CONTROL eq 3><!--- Toplu Üret İse--->
							<td class="box_yazi_td" style="text-align:center">
								<cfif ListFind(operation_basket_id_list,P_OPERATION_ID) or STAGE eq 3 or STAGE eq 1>
									<img src="images/aktif.png" style="width:25px"> 
								<cfelse>
									<input type="checkbox" style="font-size:24px" name="select_production" value="#P_OPERATION_ID#">
								</cfif>
							</td>
						</cfif>
					</tr>
				</cfoutput>
				<tr>
                	<td style="font-size:17px; font-weight:bold; ">Operatör</td>
                    <td style="font-size:17px; font-weight:bold; " colspan="2"><cfoutput>#get_emp_info(employee_id,0,0)#</cfoutput></td>
					<td style="font-size:17px; font-weight:bold; text-align:center; height:50px">
						<cfoutput query="get_station_employee">
							#get_emp_info(get_station_employee.employee_id,0,0)#,&nbsp;
						</cfoutput>
					</td>
                    <td style="font-size:17px; font-weight:bold; ">
						<cfoutput>#get_workstation_name.station_name#</cfoutput>
					</td>
					<td style="font-size:18px; font-weight:bold; text-align:center" colspan="9" nowrap>
						<cfif get_workstation_name.EZGI_PACKAGE_CONTROL eq 3><!--- Toplu Üret İse--->
							<button  value="" name="hepsi" onClick="grupla(-1);" class="ui-ripple-btn act" style="background-color:orange;margin:5px 5px;width:30%;height:50px;"><cf_get_lang dictionary_id='206.Hepsini Seç'></button>
							<button  value="" name="gonder" id="gonder" onClick="grupla();" class="ui-ripple-btn act" style="background-color:blue; color:white;margin:5px 5px;width:30%;height:50px;"><cf_get_lang dictionary_id='58788.Sepete At'></button>
							<button  value="" name="git" onClick="grupla(-3);" class="ui-ripple-btn act" style="background-color:green; color:white;margin:5px 5px;width:30%;height:50px;"><cf_get_lang dictionary_id='35873.Sepete Dön'></button>
						</cfif>
					</td>
				</tr>
			</tbody>
		</cf_grid_list>
	</cf_box>

<script language="javascript">
	document.search_list.lot_number.select();
	function yazdir()
	{
		if(document.getElementById('master_plan').value == '')
		{
			alert('Önce Master Plan Seçiniz..!');
			return false;
		}
		else
			windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_print_files&print_type=284</cfoutput>&iid='+document.getElementById('master_plan').value,'page');
	}
	function tumu()
	{
		if(document.getElementById('lot_number').value=='' && document.getElementById('master_plan').value=='')
		{
			alert('Filtre Giriniz');
			return false;
		}
		else
		{
			document.getElementById("all_info").value = 1;
			document.getElementById("search_list").submit();
		}
	}
	function delete_control(p_operation_id,trace_no)
	{
		sor = confirm(trace_no+" <cf_get_lang dictionary_id='417.Üretim İçin Sonuç Girmeden Çıkmak İstediğinizden Emin misiniz'>?");
		if(sor==true)
		{
			if(p_operation_id==0)
				window.location.href='<cfoutput>#request.self#?fuseaction=production.upd_ezgi_station_employee_exit&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&p_operation_id=#get_employee_durum.p_operation_id#</cfoutput>';
			else
				window.location.href='<cfoutput>#request.self#?fuseaction=production.upd_ezgi_station_employee_exit&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#</cfoutput>&p_operation_id='+p_operation_id+'&trace_no='+trace_no;
		}
	}

	function prod_pause(tkey)
	{
		<cfoutput>
			var station_id = #station_id#;
			var employee_id = #employee_id#;
			var pause_cat = #pause_cat#
		</cfoutput>
		if(pause_cat==0)
		{
			if(tkey==1||tkey==2||tkey==3)

			{
				windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_form_add_ezgi_prod_pause&station_id_='+station_id+'&employee_id_='+employee_id+'&type_id='+tkey,'small');
			}
		}
		else
		{
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.emptypopup_add_ezgi_prod_pause&station_id='+station_id+'&employee_id='+employee_id+'&pause_cat='+pause_cat,'small');	
		}
	}
	function geri()
	{
		window.location.href='<cfoutput>#request.self#?fuseaction=production.employee_ezgi_identification_1</cfoutput>';
	}
	function grupla(type)
	{
		if (type == -3)
		{
			<cfif left(attributes.lot_number,1) eq 4>
				paper_no = <cfoutput>#attributes.lot_number#</cfoutput>;
			<cfelse>
				paper_no = 0;
			</cfif>
			window.location.href='<cfoutput>#request.self#?fuseaction=production.dsp_ezgi_operation_basket&station_id=#station_id#&employee_id=#employee_id#</cfoutput>';
		}
		else
		{
			operation_id_list = '';
			chck_leng = document.getElementsByName('select_production').length;
			for(ci=0;ci<chck_leng;ci++)
			{
				var my_objets = document.all.select_production[ci];
				if(chck_leng == 1)
					var my_objets =document.all.select_production;
				if(type == -1)
				{//hepsini seç denilmişse	
					if(my_objets.checked == true)
						my_objets.checked = false;
					else
						my_objets.checked = true;
				}
				else
				{
					if(my_objets.checked == true)

						operation_id_list +=my_objets.value+',';
				}
			}
			operation_id_list = operation_id_list.substr(0,operation_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(operation_id_list!='')
			{
				document.getElementById('gonder').disabled = true;
				window.location.href='<cfoutput>#request.self#?fuseaction=production.emptypopup_add_ezgi_operation_basket&station_id=#station_id#&employee_id=#employee_id#</cfoutput>&operation_id_list='+operation_id_list;
			}
		}
	}
	function myworks()
	{
		window.location.href='<cfoutput>#request.self#?fuseaction=production.list_ezgi_production_operation&is_form_submitted=1&station_id=#station_id#&employee_id=#employee_id#</cfoutput>';
	}
</script>