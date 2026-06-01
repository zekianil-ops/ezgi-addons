<!---
    File: get_ezgi_iflow_production_order_include.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/11/2025
    Description:
--->
<cfif ListLen(lot_list)>
    <cfquery name="get_modul_amount" datasource="#dsn3#"> <!---Biten Modül Hesaplama--->
		SELECT        
			SUM(AMOUNT) AS MODUL_AMOUNT
		FROM            
			(
				 SELECT        
					MIN(ISNULL(TBL.AMOUNT, 0)) AS AMOUNT
				 FROM            
					PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
					EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) ON PO.LOT_NO = EP.LOT_NO INNER JOIN
					STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
					(
						 SELECT        
							POR.P_ORDER_ID, SUM(PORR.AMOUNT) AS AMOUNT
						 FROM            
							PRODUCTION_ORDER_RESULTS AS POR WITH (NOLOCK) INNER JOIN
							PRODUCTION_ORDER_RESULTS_ROW AS PORR WITH (NOLOCK) ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
						 WHERE        
							  POR.IS_STOCK_FIS = 1 AND 
							PORR.TYPE = 1
						  GROUP BY 
							 POR.P_ORDER_ID
					 ) AS TBL ON PO.P_ORDER_ID = TBL.P_ORDER_ID
				 WHERE        
					 S.PRODUCT_CATID =
									   (
										SELECT        
											DEFAULT_PACKAGE_CAT_ID
										FROM            
											EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
									 	) AND 
                	EP.LOT_NO IN (#lot_list#) AND
					EP.PRODUCT_TYPE = 2
				GROUP BY 
					EP.LOT_NO
			 ) AS TBL2
	</cfquery>
    <!---<cfdump var="#get_modul_amount#">--->
    <cfquery name="get_package_cat" datasource="#dsn3#">
    	SELECT DEFAULT_PACKAGE_CAT_ID FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
    </cfquery>
    <cfif not get_package_cat.recordcount and not len(get_package_cat.DEFAULT_PACKAGE_CAT_ID)>
    	<script type="text/javascript">
			alert("Mobilya Tasarım Genel Tanımlarını Yapınız veya Paket Kategorisini Tanımlayın!");
		 </script>
		<cfabort>
    </cfif>
    <cfquery name="get_orders_list" datasource="#dsn3#"><!---Toplam ve Biten İş Emri Listeleme--->
    	SELECT 
        	E.LOT_NO, 
            E.EMIR, 
            E.URETILEN, 
            E.KALAN, 
            E.P_ORDER_ID, 
            E.IS_STAGE, 
            E.STOCK_ID, 
            E.SPEC_MAIN_ID, 
            S.PRODUCT_CODE, 
            S.PRODUCT_CATID
		FROM     
        	EZGI_IFLOW_PRODUCTION_ORDER_P_ORDER AS E INNER JOIN
            STOCKS AS S ON E.STOCK_ID = S.STOCK_ID
		WHERE  
        	E.LOT_NO IN (#lot_list#)
	</cfquery>
    <cfquery name="get_package_list" dbtype="query"> <!---Toplam Paket İşemri ve Sonuç Sayısı--->
    	SELECT
        	SUM(EMIR) AS PAKET_EMIR,
            SUM(URETILEN) AS PAKET_URETILEN
      	FROM
        	get_orders_list
      	WHERE
        	PRODUCT_CATID = #get_package_cat.DEFAULT_PACKAGE_CAT_ID#
    </cfquery>
    <cfquery name="get_all_p_order_list" dbtype="query"> <!---Toplam Tüm İşemri ve Sonuç Sayısı--->
    	SELECT
        	SUM(EMIR) AS TOTAL_EMIR,
            SUM(URETILEN) AS TOTAL_URETILEN
      	FROM
        	get_orders_list
    </cfquery>
	<cfquery name="get_operations" datasource="#dsn3#"><!---Toplam Operasyon Listeleme--->
        SELECT 
        	POR.P_OPERATION_ID, 
            POR.P_ORDER_ID, 
            POR.AMOUNT, 
            POR.STATION_ID, 
            POR.OPERATION_TYPE_ID, 
            POR.STAGE, 
            POR.O_START_DATE, 
            POR.O_TOTAL_PROCESS_TIME, 
            POR.O_FINISH_DATE, 
            POR.O_STATION_IP, 
            POR.O_CURRENT_NUMBER, 
            POR.O_STATION_START_DATE, 
            ISNULL(TBL.OPTIMUM_TIME, 1) AS OPTIMUM_TIME, 
            W.STATION_NAME, 
            ISNULL(W.EMPLOYEE_NUMBER,0) AS EMPLOYEE_NUMBER, 
            ISNULL(W.EZGI_KATSAYI,1) AS EZGI_KATSAYI, 
            ISNULL(W.EZGI_SETUP_TIME,1) AS EZGI_SETUP_TIME,
            OT.OPERATION_TYPE,
            ISNULL(TBB.REAL_AMOUNT,0) AS REAL_AMOUNT,
            CASE 
            	WHEN 
                	POR.STAGE = 3
                THEN 
                	0
          		ELSE
            		POR.AMOUNT - ISNULL(TBB.REAL_AMOUNT,0) 
         	END AS KALAN_AMOUNT
		FROM     
        	PRODUCTION_OPERATION AS POR INNER JOIN
            PRODUCTION_ORDERS AS PO ON PO.P_ORDER_ID = POR.P_ORDER_ID LEFT OUTER JOIN
            WORKSTATIONS AS W ON POR.STATION_ID = W.STATION_ID LEFT OUTER JOIN
            (
            	SELECT 
                	STOCK_ID, 
                    OPERATION_TYPE_ID, 
                    OPTIMUM_TIME
            	FROM      
                	EZGI_OPERATION_OPTIMUM_TIME
             	WHERE   
                	STATUS = 1
        	) AS TBL ON POR.OPERATION_TYPE_ID = TBL.OPERATION_TYPE_ID AND PO.STOCK_ID = TBL.STOCK_ID INNER JOIN
      		OPERATION_TYPES AS OT ON POR.OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID LEFT OUTER JOIN
            (
            	SELECT
            		SUM(REAL_AMOUNT) AS REAL_AMOUNT,
                    OPERATION_ID
				FROM     
    				PRODUCTION_OPERATION_RESULT
              	GROUP BY
                	OPERATION_ID
            )AS TBB ON TBB.OPERATION_ID = POR.P_OPERATION_ID
		WHERE  
        	PO.LOT_NO IN (#lot_list#)
 	</cfquery>
    <cfquery name="get_operations_pre_group" dbtype="query"><!---Toplam Operasyon Detay Listeleme--->
    	SELECT
        	SUM(AMOUNT) AS TOTAL_AMOUNT,
            SUM(AMOUNT*OPTIMUM_TIME) AS TOTAL_OPTIMUM_TIME,
            OPERATION_TYPE_ID,
            OPERATION_TYPE,
            STATION_ID,
            STATION_NAME,
            EMPLOYEE_NUMBER, 
        	EZGI_KATSAYI, 
         	EZGI_SETUP_TIME
      	FROM
        	get_operations
     	GROUP BY
        	OPERATION_TYPE_ID,
            OPERATION_TYPE,
            STATION_ID,
            STATION_NAME,
            EMPLOYEE_NUMBER, 
        	EZGI_KATSAYI, 
         	EZGI_SETUP_TIME	
    </cfquery>
    <cfquery name="get_operations_group" dbtype="query"><!---Toplam Operasyon Guruplama--->
    	SELECT
        	SUM(TOTAL_AMOUNT) AS TOTAL_AMOUNT,
            SUM(TOTAL_OPTIMUM_TIME) AS TOTAL_OPTIMUM_TIME,
            COUNT(STATION_ID) AS STATION_COUNT,
            SUM(EMPLOYEE_NUMBER) AS TOTAL_EMPLOYEE_NUMBER,
            AVG(EZGI_KATSAYI) AS AVG_EZGI_KATSAYI,
            OPERATION_TYPE_ID,
            OPERATION_TYPE
      	FROM
        	get_operations_pre_group
     	GROUP BY
        	OPERATION_TYPE_ID,
            OPERATION_TYPE
    </cfquery>
    <cfquery name="get_workstation_group" dbtype="query"><!---Toplam İstasyon Guruplama--->
    	SELECT
        	SUM(AMOUNT) AS TOTAL_AMOUNT,
            SUM(AMOUNT*OPTIMUM_TIME) AS TOTAL_OPTIMUM_TIME,
            MIN(O_START_DATE) AS START_DATE,
            MAX(O_FINISH_DATE) AS FINISH_DATE, 
            STATION_ID,
            STATION_NAME,
            EMPLOYEE_NUMBER, 
        	EZGI_KATSAYI, 
         	EZGI_SETUP_TIME
      	FROM
        	get_operations
     	GROUP BY
        	STATION_ID,
            STATION_NAME,
            EMPLOYEE_NUMBER, 
        	EZGI_KATSAYI, 
         	EZGI_SETUP_TIME	
     	ORDER BY
        	STATION_NAME
    </cfquery>
<cfelse>
	<script type="text/javascript">
   		alert("Seçiminizde Hiç Emir Bulunamadı!");
	 </script>
  	<cfabort>
</cfif>
<cfif NOT get_operations.recordcount>
	<script type="text/javascript">
   		alert("Seçiminizde Hiç Operasyon Bulunamadı!");
	 </script>
  	<cfabort>
</cfif>
<cfset p_operation_id_list = ValueList(get_operations.P_OPERATION_ID)>
<cfquery name="get_operation_result" datasource="#dsn3#"><!---Toplam Biten Operasyon Guruplama--->
	SELECT 
    	PR.OPERATION_ID, 
        PR.STATION_ID, 
        ISNULL(PR.REAL_AMOUNT,0) AS REAL_AMOUNT, 
        ISNULL(PR.LOSS_AMOUNT,0) AS LOSS_AMOUNT, 
        ISNULL(PR.REAL_TIME,0) AS  REAL_TIME, 
        ISNULL(PR.WAIT_TIME,0) AS WAIT_TIME, 
        PR.ACTION_EMPLOYEE_ID, 
        PR.UPDATE_DATE, 
        PR.ACTION_START_DATE,
        POR.OPERATION_TYPE_ID,
        ISNULL(PR.REAL_AMOUNT,0)*ISNULL(OPTIMUM_TIME,0) AS REAL_OPTIMUM_TIME
	FROM     
    	PRODUCTION_OPERATION_RESULT AS PR INNER JOIN
 		PRODUCTION_OPERATION AS POR ON PR.OPERATION_ID = POR.P_OPERATION_ID INNER JOIN 
        PRODUCTION_ORDERS AS PO ON PR.P_ORDER_ID = PO.P_ORDER_ID LEFT JOIN 
        EZGI_OPERATION_OPTIMUM_TIME AS EOP ON PO.STOCK_ID = EOP.STOCK_ID AND EOP.OPERATION_TYPE_ID = POR.OPERATION_TYPE_ID AND EOP.STATUS = 1
  	WHERE
    	PR.OPERATION_ID IN (#p_operation_id_list#)
</cfquery>
<cfquery name="get_operations_all" dbtype="query"> <!---Toplam Tüm Operasyon Sayısı--->
  	SELECT
    	SUM(AMOUNT) AS TOTAL_AMOUNT,
        SUM(AMOUNT*OPTIMUM_TIME) AS TOTAL_OPTIMUM_TIME
 	FROM
 		get_operations
</cfquery>
<cfquery name="get_operation_result_all" dbtype="query"> <!---Kalan Toplam Operasyon Sonuç Sayısı--->
  	SELECT
    	SUM(KALAN_AMOUNT) AS KALAN_AMOUNT,
        SUM(KALAN_AMOUNT*OPTIMUM_TIME) AS KALAN_OPTIMUM_TIME,
        SUM(REAL_AMOUNT) AS TOTAL_REAL_AMOUNT
 	FROM
 		get_operations
 	WHERE
    	KALAN_AMOUNT > 0
</cfquery>
<cfquery name="get_operation_result_2" datasource="#dsn3#"><!---Toplam Biten Operasyon Guruplama (Birden Fazla Personelli)--->
    SELECT 
    	EOC.OPERATION_RESULT_ID, 
        EOC.TIME_COST_TYPE, 
        EOC.TIME_COST_MINUTE, 
        EOC.EMPLOYEE_ID, 
        EOC.STATUS, 
        EOC.OVERTIME_TYPE, 
        POR.OPERATION_ID
    FROM     
    	EZGI_OPERATION_TIME_COST AS EOC INNER JOIN
        PRODUCTION_OPERATION_RESULT AS POR ON EOC.OPERATION_RESULT_ID = POR.OPERATION_RESULT_ID
    WHERE  
    	POR.OPERATION_ID IN (#p_operation_id_list#)
</cfquery>
