<!---
    File: add_ezgi_fast_production_order.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/10/2024
    Description:
--->

<cfset attributes.realized_amount_ =1>
<cfset attributes.duration_time_ =0>
<cfset attributes.loss_amount_ =0>
<cfset attributes.product_time_ =0>
<cfset attributes.upd_id = attributes.p_order_id>
<cfset attributes.operation_id_ = attributes.p_operation_id>
<cfset attributes.station_id_ = attributes.station_id>
<cfset attributes.employee_id_ = attributes.employee_id>
<cfquery name="ADD_RESULT" datasource="#dsn3#">
	INSERT INTO
	    PRODUCTION_OPERATION_RESULT
	(
	    P_ORDER_ID,
	    OPERATION_ID,
	    STATION_ID,
	    REAL_AMOUNT,
	    LOSS_AMOUNT,
	    REAL_TIME,
	    WAIT_TIME,
	    RECORD_EMP,
	    RECORD_DATE,
	    RECORD_IP,
	    ACTION_EMPLOYEE_ID,
	    ACTION_START_DATE
	)
	VALUES
	(
	    #attributes.upd_id#,
	    #attributes.operation_id_#,
	    #attributes.station_id_#,
	    <cfif isdefined('attributes.realized_amount_') and len(attributes.realized_amount_)>#attributes.realized_amount_#<cfelse>NULL</cfif>,
	    <cfif isdefined('attributes.loss_amount_') and len(attributes.loss_amount_)>#attributes.loss_amount_#<cfelse>NULL</cfif>,
	    <cfif isdefined('product_time_') and len(product_time_)>#product_time_#<cfelse>NULL</cfif>,
	    <cfif isdefined('attributes.duration_time_') and len(attributes.duration_time_)>#attributes.duration_time_#<cfelse>NULL</cfif>,
	    #SESSION.EP.USERID#,
	    #NOW()#,
	    '#CGI.REMOTE_ADDR#',
	    <cfif isdefined('attributes.employee_id_') and len(attributes.employee_id_)>#attributes.employee_id_#<cfelse>NULL</cfif>,
	    #NOW()#
	)
</cfquery>
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
                <cfparam name="attributes.pr_order_id" default="#ADD_PRODUCTION_ORDER.MAX_ID#">
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
<cflocation url="#request.self#?fuseaction=production.add_ezgi_fast_production_order&station_id=#attributes.station_id#&employee_id=#attributes.employee_id_#&p_operation_id=#attributes.operation_id_#" addtoken="No">
