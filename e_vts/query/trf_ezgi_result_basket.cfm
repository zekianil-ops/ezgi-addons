<!---
    File: trf_ezgi_result_basket.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/10/2022
    Description:
--->
<cfparam name="attributes.lot_number" default="">
<cfparam name="attributes.is_show" default="1">
<cfparam name="attributes.master_plan" default="">
<cfset get_workstation_name.EZGI_PACKAGE_CONTROL = 3>
<cfparam name="attributes.loss_amount_" default="0">
<cfparam name="attributes.action_start_date_" default="0">
<cfparam name="attributes.ezgi_time_cost" default="1">
<cfset attributes.station_id = attributes.station_id_>
<cfif not isdefined('product_time')>
	<cfset product_time_ = 0>
</cfif>
<cflock name="#createUUID()#" timeout="90">	
    <cftransaction>
        <cfquery name="get_operation_basket" datasource="#dsn3#">
        	SELECT 
            	E.EZGI_VTS_OPERATION_BASKET_ID, 
                E.BASKET_NO, 
                E.EMPLOYEE_ID, 
                E.STATION_ID, 
                ISNULL(E.REAL_RATE, 0) AS REAL_RATE, 
                E.IS_STAGE, 
                E.RECORD_DATE, 
                E.RECORD_EMP, 
                E.UPDATE_DATE, 
                SUM(POR.AMOUNT - TBL.REAL_AMOUNT) AS KALAN_AMOUNT
			FROM     
            	EZGI_VTS_OPERATION_BASKET AS E WITH (NOLOCK) INNER JOIN
                EZGI_VTS_OPERATION_BASKET_ROW AS ER WITH (NOLOCK) ON E.EZGI_VTS_OPERATION_BASKET_ID = ER.EZGI_VTS_OPERATION_BASKET_ID INNER JOIN
                PRODUCTION_OPERATION AS POR WITH (NOLOCK) ON ER.OPERATION_ID = POR.P_OPERATION_ID LEFT OUTER JOIN
             	(
                	SELECT 
                    	OPERATION_ID, 
                        SUM(REAL_AMOUNT) AS REAL_AMOUNT
                	FROM      
                    	PRODUCTION_OPERATION_RESULT WITH (NOLOCK)
                 	GROUP BY 
                    	OPERATION_ID
             	) AS TBL ON POR.P_OPERATION_ID = TBL.OPERATION_ID
			GROUP BY 
            	E.EZGI_VTS_OPERATION_BASKET_ID, 
                E.BASKET_NO, 
                E.EMPLOYEE_ID, 
                E.STATION_ID, 
                ISNULL(E.REAL_RATE, 0), 
                E.IS_STAGE, 
                E.RECORD_DATE, 
                E.RECORD_EMP, 
                E.UPDATE_DATE
			HAVING 
            	E.IS_STAGE < 4 AND 
                E.EZGI_VTS_OPERATION_BASKET_ID = #attributes.basket_id#
        	 ORDER BY
                E.RECORD_DATE
        </cfquery>
        <cfset operation_result_id_list = ''>
        <cfif get_operation_basket.recordcount and len(get_operation_basket.BASKET_NO)>
            <cfset attributes.lot_number = get_operation_basket.BASKET_NO>
            <cfinclude template="../query/get_ezgi_operations.cfm">
            <cfif get_po_det.recordcount>
                <cfloop query="get_po_det">
                	<!---Üretim Oranını Tamamlanan Miktar a çeviriyoruz--->
                	<cfif attributes.uretim_durumu eq 0> <!---Üretime %100 tamamlanmadıysa--->
                    	<cfset attributes.realized_amount_ = get_po_det.amount*attributes.tamamlan_oran/100>
                        <cfif attributes.realized_amount_ gt get_po_det.amount-get_po_det.real_amount>
                        	Girilen Oran Fazla Üretim Yapmak İstiyor.
                            <cfabort>
                        </cfif>
                    <cfelse><!---Üretime %100 tamamlandıysa--->
                    	<cfset attributes.realized_amount_ = get_po_det.amount-get_po_det.real_amount>
                    </cfif>
                	<cfset attributes.upd_id = get_po_det.P_ORDER_ID>
        			<cfset attributes.operation_id_ = get_po_det.P_OPERATION_ID>
                  	<!---OPERASYON BİTİRME ---> 
                	<cfinclude template="add_ezgi_operation_result_control.cfm"> <!---Operasyon Bittiğinde Malzeme veya Alt Operasyon Sorunu Varmı?--->
                    <cfquery name="get_result_id" datasource="#dsn3#"> <!---Kişinin İstasyonda Başladığı ve Sonuç Girmediği İlgili Operasyonun Başlama Zamanı Bulunuyor--->
                        SELECT
                            OPERATION_RESULT_ID,
                            ACTION_START_DATE
                        FROM
                            PRODUCTION_OPERATION_RESULT
                        WHERE     	
                            ACTION_EMPLOYEE_ID = #attributes.employee_id_# AND 
                            STATION_ID = #attributes.station_id_# AND 
                            OPERATION_ID = #attributes.operation_id_# AND 
                            REAL_AMOUNT = 0	 AND 
                            LOSS_AMOUNT = 0	
                    </cfquery>
                    <cfif get_result_id.recordcount and len(get_result_id.OPERATION_RESULT_ID)>
                    	<cfif isdefined('attributes.realized_amount_') and len(attributes.realized_amount_) and get_operation_basket.KALAN_AMOUNT gt 0>
                        	<cfset result_oran = attributes.realized_amount_/get_operation_basket.KALAN_AMOUNT> <!---Bu Operasyona Düşen zamanı hesaplamak için oran bulunuyor--->
                        <cfelse>
                        	<cfset result_oran = 1>
                        </cfif>
                    	<cfset operation_result_id_list = ListAppend(operation_result_id_list,get_result_id.OPERATION_RESULT_ID)>
                        <cfset attributes.result_id = get_result_id.OPERATION_RESULT_ID>
                        <!---Operasyon Kapatılıyor (Sonuç Giriliyor)--->
                        <cfquery name="UPDATE_RESULT" datasource="#dsn3#">
                            UPDATE    
                                PRODUCTION_OPERATION_RESULT
                            SET              
                                REAL_AMOUNT = <cfif isdefined('attributes.realized_amount_') and len(attributes.realized_amount_)>#attributes.realized_amount_#<cfelse>NULL</cfif>, 
                                LOSS_AMOUNT = <cfif isdefined('attributes.loss_amount_') and len(attributes.loss_amount_)>#attributes.loss_amount_#<cfelse>NULL</cfif>, 
                                REAL_TIME = <cfif len(get_result_id.ACTION_START_DATE)>#round(DateDiff('s',get_result_id.ACTION_START_DATE,now())*result_oran)#<cfelse>NULL</cfif>,
                                UPDATE_EMP = #SESSION.EP.USERID#,
                                UPDATE_DATE = #NOW()#,
                                UPDATE_IP = '#CGI.REMOTE_ADDR#'
                            WHERE  
                                OPERATION_RESULT_ID = #attributes.result_id# 	
                        </cfquery>
                        <!---Zaman Harcama İşlemi Yapılacaksa--->
                        <cfif attributes.ezgi_time_cost eq 1>
                            <cfinclude template="add_ezgi_operation_time_cost.cfm">
                        </cfif>
                        <!---OPERASYON BİTİRME ---> 
                        <!---Son Operasyon mu Kontrol ediliyor--->
                        <cfquery name="get_end_operation" datasource="#dsn3#">
                            SELECT     
                                P_ORDER_ID, 
                                QUANTITY, 
                                ISNULL(
                                        (
                                        SELECT     
                                            sum(PORR.AMOUNT) AS AMOUNT
                                        FROM         
                                            PRODUCTION_ORDER_RESULTS AS POR INNER JOIN
                                            PRODUCTION_ORDER_RESULTS_ROW AS PORR ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
                                        WHERE     
                                            POR.P_ORDER_ID = PO.P_ORDER_ID AND 
                                            PORR.TYPE = 1
                                        )
                                    , 0) AS URETILEN,
                                (
                                SELECT     
                                    MIN(REAL_AMOUNT) AS REAL_AMOUNT
                                FROM          
                                    (
                                    SELECT     
                                        ISNULL(
                                                (
                                                SELECT     
                                                    SUM(REAL_AMOUNT) * PO.QUANTITY  AS REAL_AMOUNT
                                                FROM         
                                                    PRODUCTION_OPERATION_RESULT
                                                WHERE     
                                                    OPERATION_ID = POO.P_OPERATION_ID
                                                )
                                            , 0) / AMOUNT AS REAL_AMOUNT
                                    FROM          
                                        PRODUCTION_OPERATION AS POO
                                    WHERE      
                                        P_ORDER_ID = PO.P_ORDER_ID
                                    ) AS TBL1
                                ) AS REAL_OPERATION
                            FROM         
                                PRODUCTION_ORDERS AS PO
                            WHERE     
                                P_ORDER_ID = #attributes.upd_id#
                        </cfquery>
                        <!---Eğer Son Operasyon İse Üretim Sonucu Giriliyor--->
                        <cfif get_end_operation.REAL_OPERATION gt get_end_operation.URETILEN>
                            <cfif isdefined('attributes.realized_amount_') and attributes.realized_amount_ gt 0>
                                <cfset AMOUNT = get_end_operation.REAL_OPERATION-get_end_operation.URETILEN>
                                <cfinclude template="add_ezgi_prod_order_result.cfm">
                                <!---Üretim Emri RESULT_AMOUNT Alanı için Durum Güncellemesi Yapılıyor--->
                                <cfquery name="upd_result_amount" datasource="#dsn3#">
                                    UPDATE 
                                        PRODUCTION_ORDERS
                                    SET          
                                        RESULT_AMOUNT = TBL.ORDER_AMOUNT
                                    FROM     
                                        (
                                            SELECT 
                                                SUM(POR_.AMOUNT) AS ORDER_AMOUNT, 
                                                POO.P_ORDER_ID
                                            FROM      
                                                PRODUCTION_ORDER_RESULTS_ROW AS POR_ INNER JOIN
                                                PRODUCTION_ORDER_RESULTS AS POO ON POR_.PR_ORDER_ID = POO.PR_ORDER_ID
                                            WHERE   
                                                POR_.TYPE = 1
                                            GROUP BY 
                                                POO.P_ORDER_ID
                                        ) AS TBL INNER JOIN
                                        PRODUCTION_ORDERS ON TBL.P_ORDER_ID = PRODUCTION_ORDERS.P_ORDER_ID
                                    WHERE  
                                        PRODUCTION_ORDERS.P_ORDER_ID = #attributes.upd_id#
                                </cfquery>
                                <cfif GET_DET_PO.recordcount gt 0>
                                    <cfset attributes.pr_order_id = ADD_PRODUCTION_ORDER.MAX_ID>
                                    <cfinclude template="add_ezgi_prod_order_result_stock.cfm">
                                <cfelse>
                                    <cf_get_lang dictionary_id='314.Üretim Emirleri Bulunamamıştır'>.!!!!!
                                    <cfabort>
                                </cfif> 
                            </cfif>
                        </cfif>
                        <cfquery name="get_order" datasource="#dsn3#">
                            SELECT     	
                                PO.AMOUNT, 
                                ISNULL((	
                                        SELECT     	
                                            SUM(REAL_AMOUNT) AS REAL_AMOUNT
                                        FROM       
                                            PRODUCTION_OPERATION_RESULT
                                        WHERE     	
                                            OPERATION_ID = PO.P_OPERATION_ID
                                ),0) REAL_AMOUNT,
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
                            FROM       	
                                PRODUCTION_OPERATION AS PO INNER JOIN
                                PRODUCTION_ORDERS AS PRO ON PO.P_ORDER_ID = PRO.P_ORDER_ID INNER JOIN
                                STOCKS AS S ON PRO.STOCK_ID = S.STOCK_ID INNER JOIN
                                OPERATION_TYPES AS O ON PO.OPERATION_TYPE_ID = O.OPERATION_TYPE_ID LEFT OUTER JOIN
                                PRODUCT_UNIT AS PU ON S.PRODUCT_ID = PU.PRODUCT_ID
                            WHERE     	
                                PO.P_OPERATION_ID = #attributes.operation_id_#
                        </cfquery>
                        <!---Üretim Emri Operasyon Kaydı Durum Güncellemesi Yapılıyor--->
                        <cfset kalan = get_order.AMOUNT - get_order.REAL_AMOUNT>
                        <cfquery name="UPD_OPERATION" datasource="#dsn3#">
                            UPDATE  
                                PRODUCTION_OPERATION
                            SET     
                                STAGE = <cfif kalan eq 0>3<cfelse>1</cfif>
                            WHERE 	
                                P_OPERATION_ID = #attributes.operation_id_#
                        </cfquery>
                  	</cfif>  
                </cfloop>
            	<cfif attributes.uretim_durumu eq 0>
                	<cfquery name="UPD_OPERATION_BASKET" datasource="#dsn3#">
                    	UPDATE 
                        	EZGI_VTS_OPERATION_BASKET
						SET          
                        	REAL_RATE = #get_operation_basket.REAL_RATE+attributes.tamamlan_oran#, 
                            IS_STAGE = 3
						WHERE  
                        	EZGI_VTS_OPERATION_BASKET_ID = #attributes.basket_id#
                    </cfquery>
                <cfelse>
                	<cfquery name="UPD_OPERATION_BASKET" datasource="#dsn3#">
                    	UPDATE 
                        	EZGI_VTS_OPERATION_BASKET
						SET          
                        	REAL_RATE = 100, 
                            IS_STAGE = 4
						WHERE  
                        	EZGI_VTS_OPERATION_BASKET_ID = #attributes.basket_id#
                    </cfquery>
                </cfif>
                <cfif attributes.ezgi_time_cost eq 1 and ListLen(operation_result_id_list)>
                     <cfquery name="get_total" datasource="#dsn3#">
                     	SELECT SUM(REAL_AMOUNT) AS TOTAL_PRODUCTION, MIN(REAL_TIME) AS TOTAL_TIME FROM PRODUCTION_OPERATION_RESULT WHERE OPERATION_RESULT_ID IN (#operation_result_id_list#)
                     </cfquery>   
                     <cfif get_total.TOTAL_PRODUCTION gt 0 and get_total.TOTAL_TIME gt 0>
                     	<cfset operation_time_rate = get_total.TOTAL_TIME/get_total.TOTAL_PRODUCTION>
                        <cfquery name="upd_operation_time_cost" datasource="#dsn3#">
                        	UPDATE 
                            	EZGI_OPERATION_TIME_COST
							SET          
                            	TIME_COST_MINUTE = POR.REAL_AMOUNT * #operation_time_rate#
							FROM     
                            	EZGI_OPERATION_TIME_COST INNER JOIN
                  				PRODUCTION_OPERATION_RESULT AS POR ON EZGI_OPERATION_TIME_COST.OPERATION_RESULT_ID = POR.OPERATION_RESULT_ID
							WHERE  
                            	EZGI_OPERATION_TIME_COST.OPERATION_RESULT_ID IN (#operation_result_id_list#)
                        </cfquery>
                     </cfif>
              	</cfif>
            </cfif>
        </cfif>
    </cftransaction>   
</cflock> 
<script type="text/javascript">
	alert("Basket Sonuçlandırma İşlemi Başarıyla tamamlanmıştır.!");
	window.location ="<cfoutput>#request.self#?fuseaction=production.dsp_ezgi_operation_basket&is_form_submitted=1&station_id=#attributes.station_id_#&employee_id=#attributes.employee_id_#</cfoutput>";
</script>
