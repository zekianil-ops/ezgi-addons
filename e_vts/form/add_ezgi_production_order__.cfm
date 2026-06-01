<!---
    File: add_ezgi_production_order.cfm
    Folder: Add_Ons\ezgi\e-vts\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<style>
	.box_yazi {font-size:16px;font:bold} 
	.box_yazi_td {font-size:15px;font:bold;color:blue} 
	.box_yazi_td2 {font-size:18px;font:bold}
	.box_yazi_baslik {font-size:15px;font:bold; background-color:LightGray; vertical-align:middle}
</style>
<cfif not isnumeric(attributes.upd)>
	<cfset hata  = 10>
	<cfinclude template="../../../dsp_hata.cfm">
</cfif>
<cfparam name="attributes.employee" default="">
<cfparam name="attributes.asset" default="">
<cfparam name="attributes.serial_no" default="">
<cfparam name="attributes.operation_gurup_id" default="">

<!---Özelleştirilmiş Paketlerin İsmini Değiştirme--->
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT  PROTOTIP_PACKAGE_ID, PROTOTIP_PIECE_1_ID, PROTOTIP_PIECE_2_ID, PROTOTIP_PIECE_3_ID FROM EZGI_DESIGN_DEFAULTS
</cfquery>
<cfif len(get_defaults.PROTOTIP_PACKAGE_ID)>
	<cfquery name="get_prototip_package_ids" datasource="#dsn3#">
    	SELECT 
        	PACKAGE_RELATED_ID AS STOCK_ID
		FROM            
      		EZGI_DESIGN_PACKAGE_ROW
		WHERE        
        	DESIGN_MAIN_ROW_ID = #get_defaults.PROTOTIP_PACKAGE_ID#
    </cfquery>
    <cfset default_prototip_package_stock_ids = ValueList(get_prototip_package_ids.STOCK_ID)>
</cfif>
<!---Özelleştirilmiş Paketlerin İsmini Değiştirme--->
<cfquery name="get_timing_type" datasource="#dsn3#">
	SELECT        
    	TIMING_TYPE
	FROM            
    	EZGI_MASTER_PLAN_SABLON AS EMAS
	WHERE        
    	SHIFT_ID =
            	(
                	SELECT        
                    	TOP (1) EMAS.SHIFT_ID
              		FROM            
                  		EZGI_MASTER_ALT_PLAN AS EMAP1 INNER JOIN
                     	EZGI_MASTER_PLAN_RELATIONS AS EMPR ON EMAP1.MASTER_ALT_PLAN_ID = EMPR.MASTER_ALT_PLAN_ID INNER JOIN
                 		PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                   		EZGI_MASTER_PLAN_SABLON AS EMAS ON EMAP1.PROCESS_ID = EMAS.PROCESS_ID
              		WHERE        
                		PO.P_ORDER_ID = #attributes.upd#
            	) AND 
   		STATUS_ID = 0
</cfquery>
<cfquery name="get_order" datasource="#dsn3#">
	SELECT     	
    	PO.P_ORDER_ID, 
     	PO.OPERATION_TYPE_ID, 
    	ISNULL((	
        		SELECT     	
                	SUM(LOSS_AMOUNT) AS LOSS_AMOUNT
				FROM       	
                	PRODUCTION_OPERATION_RESULT
				WHERE     	
                	OPERATION_ID = PO.P_OPERATION_ID
         		),0) LOSS_AMOUNT,
       	ISNULL((	
        		SELECT     	
                	SUM(REAL_TIME) AS REAL_TIME
				FROM       	
                	PRODUCTION_OPERATION_RESULT
				WHERE     	
                	OPERATION_ID = PO.P_OPERATION_ID
       			),0) REAL_TIME,
     	PRO.STOCK_ID,
     	PRO.STATION_ID, 
    	PRO.START_DATE, 
      	PRO.FINISH_DATE, 
      	PRO.QUANTITY, 
       	PRO.STATUS, 
      	PRO.P_ORDER_NO, 
     	PRO.PO_RELATED_ID, 
      	PRO.SPECT_VAR_ID, 
      	PRO.PROD_ORDER_STAGE, 
      	PRO.IS_DEMONTAJ, 
      	PRO.DEMAND_NO, 
       	PRO.LOT_NO, 
       	PRO.SPEC_MAIN_ID, 
      	PRO.IS_GROUP_LOT, 
      	PRO.IS_STAGE, 
      	PRO.DETAIL, 
      	PRO.SPECT_VAR_NAME, 
      	PRO.PROJECT_ID,
       	PRO.REFERENCE_NO,
     	PRO.RECORD_DATE,
      	S.PRODUCT_ID, 
      	S.PROPERTY, 
      	CASE 
      		WHEN 
            	ISNULL(S.IS_PROTOTYPE,0) = 0
          	THEN 
            	S.PRODUCT_NAME
          	ELSE
             	(
                	SELECT        
                	    TOP (1) DESIGN_MAIN_NAME
                	FROM            
                	    EZGI_DESIGN_MAIN_ROW
                	WHERE        
                	    MAIN_SPECT_RELATED_ID = PRO.SPEC_MAIN_ID
                	ORDER BY 
                	    DESIGN_MAIN_ROW_ID DESC
                	UNION ALL
                	SELECT        
                	    TOP (1) PACKAGE_NAME
                	FROM        
                	    EZGI_DESIGN_PACKAGE_ROW




                	WHERE        
                	    PACKAGE_SPECT_RELATED_ID = PRO.SPEC_MAIN_ID
                	ORDER BY 
                	    PACKAGE_ROW_ID DESC
                	UNION ALL
                	SELECT        
                	    TOP (1) PIECE_NAME
                	FROM            
                	    EZGI_DESIGN_PIECE_ROWS
                	WHERE        
                	    PIECE_SPECT_RELATED_ID = PRO.SPEC_MAIN_ID
                	ORDER BY 
                	    PIECE_ROW_ID DESC
        		)
       	END	AS PRODUCT_NAME,
        S.PRODUCT_NAME NAME_PRODUCT, 
      	S.STOCK_CODE, 
      	S.PRODUCT_CATID,
        ISNULL(S.IS_PROTOTYPE,0) AS IS_PROTOTYPE, 
        ISNULL(S.IS_QUALITY,0) AS IS_QUALITY,
      	PU.MAIN_UNIT, 
       	O.OPERATION_TYPE, 
        O.OPERATION_TYPE_ID,
    	O.OPERATION_CODE,
   		PO.P_OPERATION_ID,
      	ISNULL((
        		SELECT
					SUM(POR_.AMOUNT) ORDER_AMOUNT
				FROM
					PRODUCTION_ORDER_RESULTS_ROW POR_,
					PRODUCTION_ORDER_RESULTS POO
				WHERE
					POR_.PR_ORDER_ID = POO.PR_ORDER_ID
					AND POO.P_ORDER_ID = PO.P_ORDER_ID
					AND POR_.TYPE = 1
					AND POO.IS_STOCK_FIS = 1
				),0) ROW_RESULT_AMOUNT
    	<cfif isdefined('attributes.trace_no') and len(attributes.trace_no)>
       		, ISNULL(EOR.REAL_AMOUNT, -1) AS TRACE_AMOUNT
        	, EPOT.TRACE_NO
        	,EPOT.AMOUNT 
            ,CASE
            	WHEN ISNULL(EOR.REAL_AMOUNT, -1) = -1 THEN 0
              	WHEN ISNULL(EOR.REAL_AMOUNT, -1) = 0 THEN 1
              	WHEN ISNULL(EOR.REAL_AMOUNT, -1) = 1 THEN 3
          	END AS STAGE
            ,ISNULL(EOR.REAL_AMOUNT,0) AS REAL_AMOUNT
     	<cfelse>
        	,ISNULL((	
              	SELECT     	
                	SUM(REAL_AMOUNT) AS REAL_AMOUNT
				FROM       	
                 	PRODUCTION_OPERATION_RESULT
				WHERE     	
                 	OPERATION_ID = PO.P_OPERATION_ID
        		),0) REAL_AMOUNT
         	,0 AS TRACE_AMOUNT
         	,'' AS TRACE_NO
        	,PO.AMOUNT
            ,PO.STAGE
     	</cfif>
	FROM       	
    	PRODUCTION_OPERATION AS PO INNER JOIN
     	PRODUCTION_ORDERS AS PRO ON PO.P_ORDER_ID = PRO.P_ORDER_ID INNER JOIN
     	STOCKS AS S ON PRO.STOCK_ID = S.STOCK_ID INNER JOIN
    	OPERATION_TYPES AS O ON PO.OPERATION_TYPE_ID = O.OPERATION_TYPE_ID LEFT OUTER JOIN
    	PRODUCT_UNIT AS PU ON S.PRODUCT_ID = PU.PRODUCT_ID
        <cfif isdefined('attributes.trace_no') and len(attributes.trace_no)> <!---Takipli Üretim İse--->
       		INNER JOIN
             	EZGI_PRODUCTION_ORDERS_TRACE AS EPOT ON PRO.LOT_NO = EPOT.LOT_NO LEFT OUTER JOIN
               	PRODUCTION_OPERATION_RESULT AS EOR ON EPOT.TRACE_NO = EOR.TRACE_NO AND PO.P_OPERATION_ID = EOR.OPERATION_ID
     	</cfif>
	WHERE     	
    	PO.P_OPERATION_ID = #attributes.p_operation_id#  AND 
        PU.IS_MAIN = 1
        <cfif isdefined('attributes.trace_no') and len(attributes.trace_no)>
        	AND EPOT.TRACE_NO = '#attributes.trace_no#'
        </cfif>
</cfquery>
<!---Kalite Kontrol Var mı --->
<cfset isquality = 0>
<cfif get_order.IS_QUALITY>
	<cfquery name="GET_QUALITY_ROW" datasource="#dsn3#">
        SELECT 
            PQ.QUALITY_TYPE_ID, 
            PQ.DEFAULT_VALUE, 
            QCT.QUALITY_CONTROL_TYPE, 
            QCR.QUALITY_CONTROL_ROW, 
            QCR.QUALITY_CONTROL_ROW_ID
        FROM     
            PRODUCT_QUALITY AS PQ INNER JOIN
            QUALITY_CONTROL_TYPE AS QCT ON PQ.QUALITY_TYPE_ID = QCT.TYPE_ID INNER JOIN
            QUALITY_CONTROL_ROW AS QCR ON QCT.TYPE_ID = QCR.QUALITY_CONTROL_TYPE_ID
        WHERE  
            PQ.PRODUCT_ID = #get_order.PRODUCT_ID# AND 
            PQ.PROCESS_CAT = - 1 AND 
            PQ.OPERATION_TYPE_ID = '#get_order.OPERATION_TYPE_ID#' AND 
            QCT.IS_ACTIVE = 1
        ORDER BY 
            PQ.ORDER_NO
    </cfquery>
    <cfif GET_QUALITY_ROW.recordcount>
    	<cfset isquality = 1>
    </cfif>
</cfif>
<!---Kalite Kontrol Var mı --->

<!---Paket Kontrol Var mı --->
<cfset ispackagecontrol = 0>
<cfquery name="GET_PACKAGE_CONTROL" datasource="#dsn3#">
 	SELECT ISNULL(EZGI_PACKAGE_CONTROL,0) EZGI_PACKAGE_CONTROL FROM WORKSTATIONS WHERE STATION_ID = #attributes.station_id#
</cfquery>
<!---Bölünmüş Üretimde Önceki paket Etiketi Yazdırmak İçin Önceki Üretim Emir ID yi bulmak--->
<cfif GET_PACKAGE_CONTROL.recordcount and (GET_PACKAGE_CONTROL.EZGI_PACKAGE_CONTROL eq 1 or GET_PACKAGE_CONTROL.EZGI_PACKAGE_CONTROL eq 2)>
 	<cfset ispackagecontrol = GET_PACKAGE_CONTROL.EZGI_PACKAGE_CONTROL>
    <cfif ispackagecontrol eq 2>
    	<cfquery name="get_ispackagecontrol" datasource="#dsn3#">
			SELECT 
            	P_ORDER_ID
			FROM     
            	PRODUCTION_OPERATION_RESULT AS POR
			WHERE
           		OPERATION_RESULT_ID =
                      				(
                                    	SELECT 
                                        	MAX(POR.OPERATION_RESULT_ID) AS OPERATION_RESULT_ID
                       					FROM      
                                        	PRODUCTION_ORDERS AS PPO INNER JOIN
                                         	PRODUCTION_OPERATION AS PRO ON PPO.P_ORDER_ID = PRO.P_ORDER_ID INNER JOIN
                                         	PRODUCTION_OPERATION_RESULT AS POR ON PRO.P_OPERATION_ID = POR.OPERATION_ID
                       					WHERE   
                                        	PPO.PO_RELATED_ID =
                                             				(
                                                            	SELECT 
                                                                	P_ORDER_ID
                                              					FROM      
                                                                	PRODUCTION_ORDERS AS PRODUCTION_ORDERS_2
                                              					WHERE   
                                                                	P_ORDER_ID =
                                                                    		(
                                                                            	SELECT 
                                                                                	PO_RELATED_ID
                                                                     			FROM      
                                                                                	PRODUCTION_ORDERS AS PRODUCTION_ORDERS_1
                                                                     			WHERE   
                                                                                	P_ORDER_ID = #attributes.upd#
                                                                           	)
                                                           	) AND 
                                            POR.REAL_AMOUNT <> 0 AND 
                                            POR.ACTION_EMPLOYEE_ID = #attributes.employee_id# AND 
                                            POR.STATION_ID = #attributes.station_id#
                          			)
   		</cfquery>
        <cfif get_ispackagecontrol.recordcount and len(get_ispackagecontrol.P_ORDER_ID)>
        	<cfset onceki_etiket_id = get_ispackagecontrol.P_ORDER_ID>
        </cfif>
   	</cfif>
</cfif>
<!---Bölünmüş Üretimde Önceki paket Etiketi Yazdırmak İçin Önceki Üretim Emir ID yi bulmak--->
<!---Paket Kontrol Var mı --->

<!---Ürün ve Lot Bilgileri --->
<cfquery name="get_lot_no" datasource="#dsn3#">
	SELECT        
    	POS.STOCK_ID, 
        POS.AMOUNT, 
        POS.PRODUCT_UNIT_ID, 
        POS.LOT_NO, 
        S.PRODUCT_NAME, 
        S.PRODUCT_CODE, 
        S.IS_ZERO_STOCK, 
        ISNULL(S.IS_LOT_NO, 0) AS IS_LOT_NO, 
        ISNULL(S.IS_LIMITED_STOCK, 0) AS LIMITED_STOCK, 
        PU.MAIN_UNIT
	FROM           
    	PRODUCTION_ORDERS_STOCKS AS POS INNER JOIN
      	STOCKS AS S ON POS.STOCK_ID = S.STOCK_ID INNER JOIN
   		PRODUCT_UNIT AS PU ON POS.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
	WHERE        
    	POS.P_ORDER_ID = #attributes.upd# AND 
        POS.TYPE = 2 AND 
        ISNULL(S.IS_LOT_NO, 0) = 1
</cfquery>
<!---Ürün ve Lot Bilgileri --->

<cfquery name="get_order_result" datasource="#dsn3#">
	SELECT     	
    	EOR.OPERATION_RESULT_ID, 
    	EOR.ACTION_START_DATE
	FROM        
    	PRODUCTION_OPERATION_RESULT AS EOR
        <cfif isdefined('attributes.trace_no') and len(attributes.trace_no)>
       		INNER JOIN
         	EZGI_PRODUCTION_ORDERS_TRACE AS EPOT ON EPOT.TRACE_NO = EOR.TRACE_NO
     	</cfif>
	WHERE     	
    	(EOR.ACTION_EMPLOYEE_ID = #attributes.employee_id#) AND 
    	(EOR.STATION_ID = #attributes.station_id#) AND 
        (EOR.OPERATION_ID = #attributes.p_operation_id#) AND 
        (EOR.REAL_AMOUNT = 0) AND 
        (EOR.LOSS_AMOUNT = 0)
        <cfif isdefined('attributes.trace_no') and len(attributes.trace_no)>
        	AND EPOT.TRACE_NO = '#attributes.trace_no#'
        </cfif>
</cfquery>
<cfif get_order_result.recordcount>
	<cfset result_id = get_order_result.OPERATION_RESULT_ID>
	<cfset time_start = get_order_result.ACTION_START_DATE>
<cfelse>
	<cfset result_id = ''>
	<cfset time_start = now()>
</cfif>
<!---Duraklama Kontrol --->
<cfquery name="get_prod_pause" datasource="#dsn3#">
	SELECT     
    	PROD_PAUSE_TYPE_ID
	FROM         
    	SETUP_PROD_PAUSE
	WHERE     
    	P_ORDER_ID = #attributes.upd# AND 
        STATION_ID = #attributes.station_id# AND 
        EMPLOYEE_ID = #attributes.employee_id# AND 
        OPERATION_ID = #attributes.p_operation_id# AND 
        PROD_DURATION IS NULL
</cfquery>
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
<!---Duraklama Kontrol --->
<cfif isdefined('attributes.trace_no') and len(attributes.trace_no)><!---Takipli Üretim İse--->
	<cfparam name="attributes.keyword" default="#get_order.AMOUNT#">
</cfif>
<cfset deliver_get = get_emp_info(attributes.employee_id,0,0)>
<cfif not get_order.recordcount>
	<cfset hata  = 10>
	<cfinclude template="../../../dsp_hata.cfm">
<cfelse>
	<cfquery name="get_prod_pause_type" datasource="#dsn3#">
		SELECT DISTINCT
			SPPT.PROD_PAUSE_TYPE_ID,
			SPPT.PROD_PAUSE_TYPE
		FROM
			SETUP_PROD_PAUSE_TYPE SPPT,
			SETUP_PROD_PAUSE_TYPE_ROW SPPTR
		WHERE
			SPPT.PROD_PAUSE_TYPE_ID=SPPTR.PROD_PAUSE_TYPE_ID AND
			SPPTR.PROD_PAUSE_PRODUCTCAT_ID = #get_order.product_catid#
	</cfquery>
	<cfquery name="GET_ROW" datasource="#dsn3#">
		SELECT
        	ORDERS.ORDER_ID,
			ORDERS.ORDER_NUMBER,
			PRODUCTION_ORDERS_ROW.PRODUCTION_ORDER_ID P_ORDER_ID
		FROM
			PRODUCTION_ORDERS_ROW,
			ORDERS
		WHERE
			PRODUCTION_ORDERS_ROW.PRODUCTION_ORDER_ID = #attributes.upd# AND
			PRODUCTION_ORDERS_ROW.ORDER_ID = ORDERS.ORDER_ID 
	</cfquery>
	<cfquery name="get_serial" datasource="#dsn3#">	
		SELECT SERIAL_NO,GUARANTY_ID FROM SERVICE_GUARANTY_NEW WHERE PROCESS_ID = #attributes.upd#
	</cfquery>
	<cfif len(get_order.station_id)>
		<cfquery name="GET_STATION_INFO" datasource="#dsn3#">
			SELECT 
				DEPARTMENT,
				STATION_NAME,
				EXIT_DEP_ID,
				EXIT_LOC_ID,
				ENTER_DEP_ID,
				ENTER_LOC_ID,
				PRODUCTION_DEP_ID,
				PRODUCTION_LOC_ID
			FROM 
				WORKSTATIONS 
			WHERE 
				STATION_ID = #get_order.STATION_ID#
		</cfquery>
	<cfelse>
		<cfset get_station_info.recordcount = 0>
	</cfif>
    <cfquery name="get_bottom_station" datasource="#dsn3#">
			SELECT 
				STATION_NAME
			FROM 
				WORKSTATIONS 
			WHERE 
				STATION_ID = #attributes.station_id#
		</cfquery>
	<cfif GET_STATION_INFO.recordcount and len(GET_STATION_INFO.DEPARTMENT)>
		<cfquery name="get_employees" datasource="#dsn#">
			SELECT EMPLOYEE_NAME +' '+ EMPLOYEE_SURNAME EMPLOYEE,EMPLOYEE_ID FROM EMPLOYEE_POSITIONS WHERE DEPARTMENT_ID = #GET_STATION_INFO.DEPARTMENT# AND EMPLOYEE_ID IS NOT NULL
		</cfquery>
	<cfelse>
		<cfset get_employees.recordcount = 0>
		<cfset get_employees.EMPLOYEE = ''>
		<cfset get_employees.EMPLOYEE_ID = ''>
	</cfif>
    <table cellspacing="0" cellpadding="0" width="99%" height="99%" align="center" border="2">
        <tr>
            <td width="100%" height="100%" colspan="2" valign="top">
            <cfform name="timeform" id="timeform" method="post" action="#request.self#?fuseaction=production.form_add_production_order&upd=#attributes.upd#">
                <input type="hidden" name="start_date" id="start_date" value="">
                <input type="hidden" name="record_num" id="record_num" value="">
                <input type="hidden" name="operation_gurup_id" id="operation_gurup_id" value="<cfoutput>#attributes.operation_gurup_id#</cfoutput>">
                <cfif isdefined('onceki_etiket_id')>
                	<input type="hidden" name="last_p_order_id" id="last_p_order_id" value="<cfoutput>#onceki_etiket_id#</cfoutput>">
                <cfelse>
                	<input type="hidden" name="last_p_order_id" id="last_p_order_id" value="0">	
                </cfif>
                <table cellspacing="0" cellpadding="3" width="100%" height="100%" align="center" border="0">
                    <cfoutput query="get_order">
                        <tr>
                            <td>
                                <table cellspacing="0" cellpadding="0" width="100%" align="center" border="1">
                                    <tr>
                                        <td class="box_yazi" width="100" height="30px" align="center">
											<cfif isdefined('attributes.trace_no') and len(attributes.trace_no)>
                                                Takip No 
                                            <cfelse> 
                                                <cf_get_lang dictionary_id='29474.Emir No'> :
                                            </cfif>
                                        </td>
                                        <td class="box_yazi_td" style="width:100px;" align="center">
                                        	<cfif isdefined('attributes.trace_no') and len(attributes.trace_no)>
                                                #attributes.trace_no#
                                            <cfelse> 
                                                #p_order_no#
                                            </cfif>
                                        </td>
                                        <td class="box_yazi" width="120" align="center"><cf_get_lang dictionary_id='38047.Sipariş No'></td>
                                        <td class="box_yazi_td" style="width:100px;" align="center">#get_row.order_number#</td>
                                        <td class="box_yazi" width="140" align="center"><cf_get_lang dictionary_id='36669.İstasyon Adı'> </td>
                                        <td class="box_yazi_td" style="width:230px;" align="center"><cfif len(get_bottom_station.station_name)>#get_bottom_station.station_name#</cfif></td>
                                        <td class="box_yazi" width="110" align="center"><cf_get_lang dictionary_id='301.Operatör'></td>
                                        <td class="box_yazi_td" style="width:230px;" align="center"><cfif len(get_order.station_id)>#deliver_get#</cfif>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <cfset emir_no = p_order_no>
                    </cfoutput>
                    <cfquery name="get_operations" datasource="#dsn3#">
                        SELECT * FROM PRODUCTION_ORDER_OPERATIONS WHERE P_ORDER_ID = #attributes.upd#
                    </cfquery>
                    <cfquery name="get_serial_count" dbtype="query">
                        SELECT 
                            COUNT(SERIAL_NO),
                            EMPLOYEE_ID,
                            ASSET_ID,
                            AMOUNT,
                            SERIAL_NO
                        FROM 
                            get_operations 
                        GROUP BY 
                            SERIAL_NO,
                            EMPLOYEE_ID,
                            ASSET_ID,
                            AMOUNT,
                            SERIAL_NO
                    </cfquery>
                    <tr><td height="10px">&nbsp;</td></tr>
                    <tr valign="top" height="60px">
                        <td>
                            <table cellspacing="0" cellpadding="0" width="100%" align="center" border="1">
                                <tr height="30px">
                                    <td class="box_yazi_td2" style="width:400px;text-align:center"><cf_get_lang dictionary_id='38050.Üretilen Ürün Adı'></td>
                                    <td class="box_yazi_td2" style="width:200px;text-align:center"><cf_get_lang dictionary_id='1135.Operasyon Türü'></td>
                                    <td class="box_yazi_td2" style="width:100px;text-align:center"><cf_get_lang dictionary_id='38052.Ü.E. Adedi'></td>
                                    <td class="box_yazi_td2" style="width:100px;text-align:center"><cf_get_lang dictionary_id='36608.Üretilen'></td>
                                    <td class="box_yazi_td2" style="width:100px;text-align:center"><cf_get_lang dictionary_id='29471.Fire'></td>
                                    <td class="box_yazi_td2" style="width:100px;text-align:center"><cf_get_lang dictionary_id='58444.Kalan'></td>
                                    <td class="box_yazi_td2" style="text-align:center"><cf_get_lang dictionary_id='57636.Birim'></td>
                                    <td class="box_yazi_td2" style="width:150px;text-align:center;<cfif get_order.STAGE neq 3>display:none;</cfif>"><cf_get_lang dictionary_id='315.Toplam Üretim Zamanı (Sn)'></td>
                                </tr>
                                <tr height="30px">
                                    <cfoutput>
                                        <cfset kalan = get_order.AMOUNT - get_order.REAL_AMOUNT>
                                        <td class="box_yazi_td" style="text-align:center">&nbsp;<cfif len(get_order.PRODUCT_NAME)>#get_order.PRODUCT_NAME#<cfelse>#get_order.NAME_PRODUCT#</cfif></td>
                                        <td class="box_yazi_td" style="text-align:center">&nbsp;#get_order.OPERATION_TYPE#</td>
                                        <td class="box_yazi_td" style="text-align:center">&nbsp;#get_order.AMOUNT#</td>
                                        <td class="box_yazi_td" style="text-align:center">&nbsp;#get_order.REAL_AMOUNT#</td>
                                        <td class="box_yazi_td" style="text-align:center">&nbsp;#get_order.LOSS_AMOUNT#</td>
                                        <td class="box_yazi_td" style="text-align:center">
                                            <input type="text" name="remaining"  id="remaining" value="#kalan#" class="box" style="text-align:center; font-size:14px; width:100px; color:blue" readonly="readonly" />
                                        </td>
                                        <td class="box_yazi_td" style="width:180px;text-align:center">&nbsp;#get_order.MAIN_UNIT#</td>
                                        <td class="box_yazi_td" style="text-align:center;<cfif get_order.STAGE neq 3>display:none;</cfif>">&nbsp;#get_order.REAL_TIME#</td>
                                    </cfoutput>
                                </tr>
                            </table>
                        </td>
                    </tr>
                 	<tr>
                            <td style=" height:420px">
                                <table cellspacing="0" cellpadding="1" width="100%" align="center" border="0" >
                                    <tr height="420px" id="p_tamam"<cfif get_order.STAGE neq 3>style="display:none;"</cfif>>
                                        <td align="center" valign="middle" style="font-family:Arial, Helvetica, sans-serif; font-size:56px; font-weight:bold; color:#900; text-align:center">
                                            <cf_get_lang dictionary_id='316.Üretim Tamamlanmıştır'>.!!!
                                        </td>
                                    </tr>
                                    <cfif get_order.STAGE neq 3>
                                        <tr id="p_starts"<cfif get_order_result.recordcount>style="display:none;"</cfif>>
                                            <td style="text-align:left; height:420px">
                                                <cfif pause_cat eq 0>
                                                    <a href="javascript://" onclick="sw_start(1);">
                                                        <button type="button" name="uretim_basla" id="uretim_basla" style="background-color:LightGray;font-size:18px; font-weight:bold;height:150px; width:200px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>" autofocus><cf_get_lang dictionary_id='38059.ÜRETİME BAŞLA'></button>&nbsp;
                                                    </a>
                                                <cfelse>
                                                    <button type="button" name="uretim_bos" style="font-size:18px; font-weight:bold;height:150px; width:200px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"></button>&nbsp;
                                                </cfif>     
                                            </td>
                                        </tr>
                                        <tr id="p_finish"<cfif not get_order_result.recordcount>style="display:none;"</cfif>>
                                        	<cfif ispackagecontrol gt 0>
                                            	<cfinclude template="cnt_ezgi_product_content_control.cfm">
                                          	<cfelse>
                                                <td style="text-align:left">
                                                    <cfif pause_cat eq 0>	
                                                        <a href="javascript://" onclick="sw_start(2);">
                                                            <button type="button" name="uretim_bitir" style="background-color:LightGray;font-size:18px; font-weight:bold;height:150px; width:200px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>" autofocus><cf_get_lang dictionary_id='38063.ÜRETİMİ SONLANDIR'></button>&nbsp;
                                                        </a>
                                                    <cfelse>
                                                        <button type="button" name="uretim_bos" style="font-size:18px; font-weight:bold;height:150px; width:200px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"></button>&nbsp;
                                                    </cfif>       
                                                </td>
                                                <cfif pause_cat eq 0>
                                                        <td align="center" valign="middle" style="font-family:Arial, Helvetica, sans-serif; font-size:56px; font-weight:bold; color:green">
                                                            <cf_get_lang dictionary_id='318.Üretim Başladı'>.
                                                        </td>
                                                    
                                                <cfelse>
                                                    <td align="center" valign="middle" style="font-family:Arial, Helvetica, sans-serif; font-size:56px; font-weight:bold; color:orange">
                                                        <cf_get_lang dictionary_id='319.Duraklama Zamanı'>.
                                                    </td>
                                                </cfif>
                                         	</cfif>
                                        </tr>
                                    </cfif>
                                    <tr id="p_amount" style="display:none;" height="100%">
                                        <td valign="middle">
                                            <table width="100%">
                                                <tr>
                                                    <td align="left" width="75%">
                                                        <table cellspacing="0" cellpadding="1" border="0" align="center" height="98%" width="98%">
                                                            <tr class="color-border" height="280px">                  
                                                                <td> 
                                                                    <table cellspacing="1" cellpadding="2" border="0" align="center" height="100%" width="100%" class="tableyazi">
                                                                        <tr class="color-row" height="50%" id="p_fire">
                                                                            <td align="center" width="50%" style = "font-size:48px; font-family:'Palatino Linotype', 'Book Antiqua', Palatino, serif; font-weight:bold; color:#900"><cf_get_lang dictionary_id='320.Fire Sebebi'></td>
                                                                            
                                                                            <td align="center" width="50%" style = "font-size:48px; font-family:'Palatino Linotype', 'Book Antiqua', Palatino, serif; font-weight:bold; color:#900"><cf_get_lang dictionary_id='137.Fire Miktarı'></td>
                                                                            
                                                                        </tr>
                                                                        <tr class="color-row" height="50%" id="p_product">
                                                                            <td style = "font-size:48px; font-family:'Palatino Linotype', 'Book Antiqua', Palatino, serif; font-weight:bold; width:100%; text-align:center"><cf_get_lang dictionary_id='321.Üretilen Miktar'></td>
                                                                        </tr>
                                                                        <tr class="color-row" height="50%">
                                                                            <td style="text-align:center">
                                                                                <input type="text" id="keyword" name="keyword" value="<cfoutput><cfif isdefined("attributes.keyword") and len(attributes.keyword)>#attributes.keyword#</cfif></cfoutput>" style="font-size:65px; font-family:'Palatino Linotype', 'Book Antiqua', Palatino, serif; text-align:right; font-weight:bold; width:280px; height:70px" class="box">
                                                                                <input type="hidden" name="fire" id="fire" value="">
                                                                                <input type="hidden" name="product_status" id="product_status" value="">
                                                                                <input type="hidden" name="result_id" id="result_id" value="<cfoutput>#result_id#</cfoutput>">
                                                                                <input type="hidden" name="time_start" id="time_start" value="<cfoutput>#time_start#</cfoutput>">
                                                                            </td>
                                                                            <td style="display:none;"><cf_workcube_process_cat slct_width="140"><cf_workcube_process is_upd='0' process_cat_width='130' is_detail='0'></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>                 
                                                     <td align="left" width="25%">
                                                        <table cellspacing="0" cellpadding="1" border="0" align="center" height="98%" width="98%">
                                                            <tr class="color-border" height="255px">                  
                                                                <td> 
                                                                    <table cellspacing="1" cellpadding="2" border="0" align="center" height="100%" width="100%" class="tableyazi">
                                                                        <tr class="color-row" height="25%">
                                                                            <td style=" width:25%; text-align:center" >
                                                                                <button type="button" name="k7" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(7)">7</button>
                                                                            </td> 
                                                                            <td style=" width:25%; text-align:center" >
                                                                                <button type="button" name="k8" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(8)">8</button>
                                                                            </td>
                                                                            <td style=" width:25%; text-align:center" >
                                                                                <button type="button" name="k9" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(9)">9</button>
                                                                            </td>
                                                                            <td rowspan="3" style=" width:25%; text-align:center; vertical-align:middle">
                                                                                <button type="button" name="giris" id="giris" style="background-color:LightGray;font-size:22px; font-weight:bold;height:210px; width:60px" title="" onclick="operation_add(1)">
                                                                                    <div id="Ay" style="font-size:22px; font-weight:bold;writing-mode:tb-rl;filter:fliph flipv; text-align:center; vertical-align:middle">
                                                                                        <cf_get_lang dictionary_id='47883.Sonuç Gir'>
                                                                                    </div>         
                                                                                </button>
                                                                            </td>
                                                                        </tr>
                                                                        <tr class="color-row" style="height:25%">
                                                                            <td style="text-align:center">
                                                                                <button type="button" name="k4" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(4)">4</button>
                                                                            </td> 
                                                                            <td style="text-align:center">
                                                                                <button type="button" name="k5" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(5)">5</button>
                                                                            </td>
                                                                            <td style="text-align:center">
                                                                                <button type="button" name="k6" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(6)">6</button>
                                                                            </td>
                                                                        </tr>
                                                                        <tr class="color-row" style="height:25%">
                                                                            <td style="text-align:center">
                                                                                <button type="button" name="k1" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(1)">1</button>
                                                                            </td> 
                                                                            <td style="text-align:center">
                                                                                <button type="button" name="k2" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(2)">2</button>
                                                                            </td>
                                                                            <td style="text-align:center">
                                                                                <button type="button" name="k3" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(3)">3</button>
                                                                            </td>
                                                                        </tr>
                                                                        <tr class="color-row" style="height:25%">
                                                                            <td colspan="2" style="text-align:center">
                                                                                <button type="button" name="k0" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:135px" title="" onclick="key_control(0)">0</button>
                                                                            </td> 
                                                                            <td style="text-align:center">
                                                                                <button type="button" name="ks" style="background-color:red;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control(-1)"><img src="images/list_minus.gif" border="0" style="text-align:center; vertical-align:middle"></button>
                                                                            </td>
                                                                            <td style="text-align:center">
                                                                                <button type="button" name="kk" style="background-color:LightGray;font-size:22px; font-weight:bold;height:60px; width:60px" title="" onclick="key_control('.')">,</button>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>                   
                                                    </td>
                                                    <td style="display:none;"><cf_workcube_process_cat slct_width="140"><cf_workcube_process is_upd='0' process_cat_width='130' is_detail='0'></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                    </tr>
                    <tr height="100px" valign="bottom">
                        <td>
                            <table style="width:100%; height:100%" cellpadding="0" cellspacing="3" border="0">
                                <tr>
                                    <td style="width:100px; text-align:center" id="p_mola"<cfif get_order.STAGE eq 0 or get_order.STAGE eq 3>style="display:none;"</cfif>>
                                            <cfif pause_cat eq 1 or pause_cat eq 0>
                                                <a href="javascript://" onclick="prod_pause(1);">
                                                    <button type="button" name="mola" style="background-color:LightGray;font-size:16px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>" <cfif pause_cat neq 0>autofocus</cfif>><cf_get_lang dictionary_id='299.Mola'></button>&nbsp;
                                                </a>
                                            <cfelse>
                                                <button type="button" name="mola_bos" style="font-size:18px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"></button>&nbsp;
                                            </cfif>
                                    </td>
    
                                    <td style="width:98px; text-align:center">
                                        <cfif pause_cat eq 0>
                                            <a href="javascript://" onclick="sw_start();">
                                                <button type="button" name="fire" style="background-color:LightGray;font-size:16px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='29471.Fire'></button>&nbsp;
                                            </a>
                                        <cfelse>
                                            <button type="button" name="fire_bos" style="font-size:18px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"></button>&nbsp;
                                        </cfif>      
                                    </td>
                                    <td style="width:98px; text-align:center">
                                        <cfif pause_cat eq 0>
                                            <a href="javascript://" onclick="control(2);">
                                                <button type="button" name="fire" style="background-color:LightGray;font-size:16px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='308.Reçete'></button>&nbsp;
                                            </a>
                                        <cfelse>
                                            <button type="button" name="recete_bos" style="font-size:18px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"></button>&nbsp;
                                        </cfif>
                                    </td>
                                    <td style="width:98px; text-align:center">
                                        <cfoutput>
                                        <cfif pause_cat eq 0>
                                            <a href="javascript://" onclick="control(9)">
                                                <button type="button" name="tresim" style="background-color:LightGray;font-size:16px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='32796.Görünüm'></button>&nbsp;
                                            </a>
                                        <cfelse>
                                            <button type="button" name="tresim_bos" style="font-size:18px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"></button>&nbsp;
                                        </cfif>
                                        </cfoutput>
                                    </td>
                                    
                                    <td style="width:98px; text-align:center">
                                        <cfif pause_cat eq 0>
                                            <a href="javascript://" onclick="etiket(1);">
                                                <button type="button" name="etiket" style="background-color:LightGray;font-size:16px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='51247.Etiket Bas'></button>&nbsp;
                                            </a>
                                        <cfelse>
                                            <button type="button" name="etiket_bos" style="font-size:18px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"></button>&nbsp;
                                        </cfif>
                                    </td>
                                    <cfif isdefined('attributes.sonraki_tur') and isdefined('onceki_etiket_id')>
                                    	<td style="width:98px; text-align:center">
											<cfif pause_cat eq 0>
                                                <a href="javascript://" onclick="etiket(2);">
                                                    <button type="button" name="etiket" style="background-color:LightGray;font-size:16px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>">Bölünmüş<br /><cf_get_lang dictionary_id='51247.Etiket Bas'></button>&nbsp;
                                                </a>
                                            <cfelse>
                                                <button type="button" name="etiket_bos" style="font-size:18px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"></button>&nbsp;
                                            </cfif>
                                        </td>
                                    </cfif>
                                    <td style="width:98px; text-align:center">
                                        <cfif pause_cat eq 0>
                                            <a href="javascript://" onclick="control(10);">
                                                <button type="button" name="uretim_takip" style="background-color:Orange;font-size:16px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='38033.Üretim Takibi'></button>&nbsp;
                                            </a>
                                        <cfelse>
                                            <button type="button" name="uretim_takip_bos" style="font-size:18px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"></button>&nbsp;
                                        </cfif>
                                    </td>
                                    <cfif GET_ROW.recordcount>
                                        <td style="width:98px; text-align:center">
                                            <cfif pause_cat eq 0>
                                                <a href="javascript://" onclick="siparis();">
                                                    <button type="button" name="siparis" style="background-color:LightGray;font-size:16px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='47241.Üretim Siparişler'></button>&nbsp;
                                                </a>
                                            <cfelse>
                                                <button type="button" name="siparis_bos" style="font-size:18px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"></button>&nbsp;
                                            </cfif>
                                        </td>
                                    </cfif>
                                    <td style="width:98px; text-align:center">
                                        <cfif pause_cat eq 0>
                                            <a href="javascript://" onclick="control(1);">
                                            <button type="button" name="rapor" style="background-color:DodgerBlue;font-size:16px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='40659.Günlük Çalışma'></button>&nbsp;
                                            </a>
                                        <cfelse>
                                            <button type="button" name="rapor_bos" style="font-size:18px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"></button>&nbsp;
                                        </cfif>      
                                    </td>
                                    <cfif not isdefined('attributes.collect')>
                                        <td style="width:98px; text-align:center">
                                            <a href="javascript://" onclick="operation_add(2);">
                                                <button type="button" name="geri" style="background-color:Khaki;font-size:16px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='57432.Geri'></button>&nbsp;
                                            
                                            </a>
                                        </td>    	
                                    
                                        <td style="width:98px; text-align:center">
                                            <a href="javascript://" onclick="operation_add(3);"> 
                                                <button type="button" name="cik" style="background-color:Gold;font-size:16px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='1136.Kullanıcı Değiştir'></button>&nbsp;
                                            </a>
                                        </td>
                                    <cfelse>
                                    	<td style="width:98px; text-align:center">
                                            <a href="javascript://" onclick="window.close();"> 
                                                <button type="button" name="kapat" style="background-color:red;font-size:16px; font-weight:bold;height:100px; width:100px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='57553.Kapat'></button>&nbsp;
                                            </a>
                                        </td>

                                    </cfif>
                                    <td>&nbsp;</td>
                                </tr>
                            </table>
                        </td>
                    </tr>									

                </table>	
            </cfform>
            </td>
        </tr>
    </table>
</cfif>
<script type="text/javascript">
	function sw_start(type)
	{
		if(type == 1)
		{
			document.timeform.product_status.value = "1";
			<cfoutput>
				var p_order_id = #attributes.upd#;
				var p_operation_id = #attributes.p_operation_id#;
				var station_id = #attributes.station_id#;
				var employee_id = #attributes.employee_id#;
				var operation_amount = #get_order.AMOUNT#;
				<cfif isdefined('attributes.trace_no') and len(attributes.trace_no)> <!---Takipli Üretim İse--->
					var trace_no = '#attributes.trace_no#';
				<cfelse>
					var trace_no = '';
				</cfif>
			</cfoutput>
			var operation_gurup_id = document.getElementById('operation_gurup_id').value;
			<cfif isdefined('attributes.collect')> <!---Toplu VTS den Geliyorsa--->
				window.location='<cfoutput>#request.self#</cfoutput>?fuseaction=production.addoperationresult_ezgi&collect=1&operasyon=1&realized_amount_=0&upd_id='+p_order_id+'&operation_id_='+p_operation_id+'&station_id_='+station_id+'&employee_id_='+employee_id+'&operation_gurup_id='+operation_gurup_id;
			<cfelse>
				window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=production.addoperationresult_ezgi&operasyon=1&realized_amount_=0&upd_id='+p_order_id+'&operation_id_='+p_operation_id+'&station_id_='+station_id+'&employee_id_='+employee_id+'&operation_gurup_id='+operation_gurup_id+'&trace_no='+trace_no);
			</cfif>
			document.getElementById('uretim_basla').disabled = true;
		}
		if(type == 2)
		{
			<cfif isdefined('attributes.trace_no') and len(attributes.trace_no)> <!---Takipli Üretim İse--->
			<cfelse>
				/*var new_sql = "SELECT SUM(REAL_AMOUNT) AS REAL_AMOUNT FROM PRODUCTION_OPERATION_RESULT WHERE OPERATION_ID = <cfoutput>#attributes.p_operation_id#</cfoutput>";*/
				/*var get_amount = wrk_query(new_sql,'dsn3');*/
				
				var listParam = <cfoutput>#attributes.p_operation_id#</cfoutput>;
				var get_amount = wrk_safe_query('get_production_result_poperationid_ezgi','dsn3',0,listParam);
				
				if (get_amount.REAL_AMOUNT != undefined)
				{
					var operation_amount = <cfoutput>#get_order.AMOUNT#;</cfoutput>
					document.getElementById('remaining').value = operation_amount - get_amount.REAL_AMOUNT;
				}
			</cfif>
			p_starts.style.display='none';
			p_finish.style.display='none';
			p_amount.style.display='';
			p_product.style.display='';
			p_fire.style.display='none';
			document.timeform.fire.value = "0";
			document.getElementById('keyword').focus();
		}
		if(type == 3)
		{
			var status = document.timeform.product_status.value;
			if(status ==1)
			{
				alert("<cf_get_lang dictionary_id='322.Üretim Sonuçlandırtıktan Sonra Fire Giriniz'>");	
			}
			else
			{
				p_starts.style.display='none';
				p_tamam.style.display='none';
				p_finish.style.display='none';
				p_amount.style.display='';
				p_product.style.display='none';
				p_fire.style.display='';
				document.timeform.fire.value = "1";
			}
		}
		if(type == 4)
		{
			p_starts.style.display='none';
			p_finish.style.display='';
			p_mola.style.display='';
			p_amount.style.display='none';
			document.timeform.product_status.value = "1";
			timestart_= document.timeform.time_start.value;
		}
	}
	function key_control(hkey)
		{
			if (hkey==-1)
			{
				var iLen = String(document.timeform.keyword.value).length;
				if (iLen>1)
				{
					ezgi = String(document.timeform.keyword.value).substring(0, iLen - 1);
				}
				else
				{
					ezgi = '';
				}
				document.timeform.keyword.value = ezgi;
			}
			else
			{
				var kLen = String(document.timeform.keyword.value).length;
				if(kLen<1&&hkey=='.') 
				{
				ezgi= (document.timeform.remaining.value);
				document.timeform.keyword.value = ezgi;
				}
				else
				{
				ezgi = (document.timeform.keyword.value + hkey);
				document.timeform.keyword.value = ezgi;
				}
			}
		}
		function prod_pause(tkey)
		{

			<cfoutput>
				var p_order_no_ = '#get_order.p_order_no#';
				var p_order_id = #attributes.upd#;
				var p_operation_id = #attributes.p_operation_id#;
				var station_id = #attributes.station_id#;
				var employee_id = #attributes.employee_id#;
				var kalan_ = #kalan#
				var pause_cat = #pause_cat#
			</cfoutput>
			if(pause_cat==0)
			{
				if(tkey==1||tkey==2||tkey==3)
				{
					windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_form_add_ezgi_prod_pause&upd_id='+p_order_id+'&operation_id_='+p_operation_id+'&station_id_='+station_id+'&employee_id_='+employee_id+'&type_id='+tkey+'&p_order_no='+p_order_no_,'list');
				}
			}
			else
			{
				windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.emptypopup_add_ezgi_prod_pause&p_order_id='+p_order_id+'&station_id='+station_id+'&operation_id='+p_operation_id+'&employee_id='+employee_id+'&pause_cat='+pause_cat,'list');	
			}
		}
	function operation_add(type)
		{
			<cfoutput>
				var p_order_id = #attributes.upd#;
				var p_operation_id = #attributes.p_operation_id#;
				var station_id = #attributes.station_id#;
				var employee_id = #attributes.employee_id#;
				var amount_=#get_order.AMOUNT#;
				var real_amount_= #get_order.REAL_AMOUNT#;
				var loss_amount_=#get_order.LOSS_AMOUNT#;
				<cfif isdefined('attributes.trace_no') and len(attributes.trace_no)> <!---Takipli Üretim İse--->
					var trace_no = '#attributes.trace_no#';
				<cfelse>
					var trace_no = '';
				</cfif>
			</cfoutput>
			document.getElementById('giris').disabled = true;
			if (type== 1)
			{
				var kalan_miktar = document.getElementById('remaining').value;
				var product_amount = document.timeform.keyword.value;
				var fire_= document.timeform.fire.value;
				if (product_amount == '0' || product_amount == '')
				{
					alert("<cf_get_lang dictionary_id='29943.Lütfen miktar giriniz.'>!");
				}
				else if(product_amount*1>kalan_miktar*1 && fire_!=1)
				{
					alert("<cf_get_lang dictionary_id='323.Girdiğiniz Miktar, Kalan Üretim Miktarından Fazla'>.!");
					document.getElementById('giris').disabled = false;
					return false;
				}
				else
				{	
					if(fire_==1)
					{
						if(product_amount>amount_-loss_amount_)
						{
							alert("<cf_get_lang dictionary_id='324.Girdiğiniz Fire, Üretim Miktarından Fazla'>.!");
							document.getElementById('giris').disabled = false;
							return false;
						}
						else
						{
							var operation_gurup_id = document.getElementById('operation_gurup_id').value;
							window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=production.addoperationresult_ezgi&realized_amount_= 0&upd_id='+p_order_id+'&operation_id_='+p_operation_id+'&station_id_='+station_id+'&loss_amount_='+product_amount+'&employee_id_='+employee_id+'&operation_gurup_id='+operation_gurup_id+'&trace_no='+trace_no);
							window.opener.location.reload();
						}
					}
					else
					{
						var operation_gurup_id = document.getElementById('operation_gurup_id').value;
						var process_stage= document.getElementById('process_stage').value;
						var process_cat = document.getElementById('process_cat').options[1].value;
						if(<cfoutput>#isquality#</cfoutput>==1) <!---Kalite Kontrol Varsa--->
						{
							windowopen('<cfoutput>#request.self#?fuseaction=production.popup_add_ezgi_quality_control_result&operation_type_id=#get_order.OPERATION_TYPE_ID#&product_id=#get_order.PRODUCT_ID#</cfoutput>&upd_id='+p_order_id+'&operation_id_='+p_operation_id+'&station_id_='+station_id+'&realized_amount_='+product_amount+'&employee_id_='+employee_id+'&operation_gurup_id='+operation_gurup_id+'&process_stage='+process_stage+'&process_cat='+process_cat+'&trace_no='+trace_no,'longpage');
							window.opener.location.reload();
						}
						else
						{
							<cfif isdefined('attributes.collect')> <!---Toplu VTS den Geliyorsa--->
								document.getElementById("timeform").action ='<cfoutput>#request.self#</cfoutput>?fuseaction=production.addoperationresult_ezgi&collect=1&upd_id='+p_order_id+'&operation_id_='+p_operation_id+'&station_id_='+station_id+'&realized_amount_='+product_amount+'&employee_id_='+employee_id+'&operation_gurup_id='+operation_gurup_id+'&process_stage='+process_stage+'&process_cat='+process_cat+'&trace_no='+trace_no;
								document.getElementById("timeform").submit();
							<cfelse>
								window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=production.addoperationresult_ezgi&upd_id='+p_order_id+'&operation_id_='+p_operation_id+'&station_id_='+station_id+'&realized_amount_='+product_amount+'&employee_id_='+employee_id+'&operation_gurup_id='+operation_gurup_id+'&process_stage='+process_stage+'&process_cat='+process_cat+'&trace_no='+trace_no);
								window.opener.location.reload();
							</cfif>
						}
					}
				}
			}
			else
			{
				if (type== 2)
				{
					<cfif not isdefined('attributes.collect')>
						<cfif get_timing_type.TIMING_TYPE eq 3>
							window.location.href='<cfoutput>#request.self#?fuseaction=production.list_ezgi_production_operation&is_form_submitted=1&station_id=#station_id#&employee_id=#employee_id#&lot_number=#get_order.LOT_NO#</cfoutput>';
						<cfelse>
							window.location.href='<cfoutput>#request.self#?fuseaction=production.list_ezgi_production_operation&is_form_submitted=1&station_id=#station_id#&employee_id=#employee_id#&lot_number=#get_order.LOT_NO#</cfoutput>';
						</cfif>
					<cfelse>
						window.location.href='<cfoutput>#request.self#</cfoutput>?fuseaction=production.list_ezgi_collect_production';
					</cfif>
				}
				else if (type== 3)
				{
					window.location.href='<cfoutput>#request.self#?fuseaction=production.employee_ezgi_identification_1</cfoutput>';
				}
			}
		}
	function control(c_key)
	{
		<cfoutput>
			var p_order_id = #attributes.upd#;
			var p_operation_id = #attributes.p_operation_id#;
			var station_id = #attributes.station_id#;
			var employee_id = #attributes.employee_id#;
		</cfoutput>
		if (c_key== 1)
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_dsp_ezgi_prod_pause&employee_id='+employee_id,'wwide');
		if (c_key== 2)
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_dsp_ezgi_material_list&p_order_id='+p_order_id+'&p_operation_id='+p_operation_id+'&employee_id='+employee_id+'&station_id='+station_id,'wwide');
		if (c_key== 9)
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_dsp_ezgi_prod_teknik_resim&p_order_id='+p_order_id+'&p_operation_id='+p_operation_id,'wwide');
		if (c_key== 10)
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_dsp_ezgi_operasyon_list&p_order_id='+p_order_id,'wwide');
	}
	function etiket(type)
	{
		if(type==1)
		{
			<cfoutput>var p_order_id = #attributes.upd#;</cfoutput>
			windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_ezgi_print_files&print_type=280</cfoutput>&action_id='+p_order_id,'wide');
		}
		else if(type==2)
		{
			if(document.getElementById('last_p_order_id').value >0)
			{
				windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_ezgi_print_files&print_type=280</cfoutput>&action_id='+document.getElementById('last_p_order_id').value,'wide');
			}
		}
	}
	function siparis()
	{
		<cfif GET_ROW.recordcount>
			<cfoutput>var order_id = #get_row.order_id#;</cfoutput>
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_dsp_ezgi_orders&order_id='+order_id,'wwide'); 
		</cfif>
	}
	function emirler()
	{
		<cfoutput>var station_id = #attributes.station_id#; var employee_id = #attributes.employee_id#;</cfoutput>
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_dsp_ezgi_production&station_id='+station_id,'wwide');
	}
</script>
