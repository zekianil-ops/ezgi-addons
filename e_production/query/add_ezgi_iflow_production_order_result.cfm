<!---
    File: add_ezgi_iflow_production_order_result.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset default_process_type = 171>
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT TOP (1)    
    	SPC.PROCESS_CAT_ID
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE = #default_process_type# AND 
        SPCF.FUSE_NAME = 'prod.popup_add_ezgi_iflow_production_order_result' 
  	ORDER BY
    	SPC.PROCESS_CAT_ID DESC      
</cfquery>
<cfif not get_process_cat.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='333.İşlem Kategorisi Tanımlayınız!'>");
		history.back();	
	</script>
<cfelse>
	<cfset attributes.process_cat = get_process_cat.PROCESS_CAT_ID>
</cfif>
<cfif not len(attributes.process_stage)>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='647.Süreç Tanımlarınız Eksiktir'>!");
		window.history.go(-1);
	</script>
    <cfabort>
</cfif>
<cftransaction>
	<cfset attributes.upd_id = attributes.p_order_id>
    <cfset attributes.station_id_ = attributes.station_id>
    <cfset attributes.employee_id_ = session.ep.userid>
    <cfset attributes.realized_amount_ = filterNum(attributes.AMOUNT,2)>
    <cfset get_end_operation.REAL_OPERATION = filterNum(attributes.PRODUCED_AMOUNT,2) + filternum(attributes.AMOUNT,2)>
    <cfset get_end_operation.URETILEN = filterNum(attributes.PRODUCED_AMOUNT,2)>
	<cfinclude template="/AddOns/ezgi/e_vts/query/add_ezgi_prod_order_result.cfm">
    <cfif GET_DET_PO.recordcount gt 0>
     	<cfparam name="attributes.pr_order_id" default="#ADD_PRODUCTION_ORDER.MAX_ID#">
     	<cfinclude template="/AddOns/ezgi/e_vts/query/add_ezgi_prod_order_result_stock.cfm">
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
  	</cfif>
    <cfquery name="get_stage" datasource="#dsn3#">
    	SELECT IS_STAGE FROM PRODUCTION_ORDERS WHERE P_ORDER_ID = #attributes.upd_id#
    </cfquery>
    <cfquery name="upd_operation_result" datasource="#dsn3#">
    	UPDATE       
        	PRODUCTION_OPERATION
		SET                
        	STAGE = 
				<cfif get_stage.IS_STAGE eq 4 or get_stage.IS_STAGE eq 0>
                	0
				<cfelseif get_stage.IS_STAGE eq 2>
                	3
				<cfelseif get_stage.IS_STAGE eq 1>
                    1
              	</cfif>
		WHERE        
        	P_ORDER_ID = #attributes.upd_id#
    </cfquery>
</cftransaction>
<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='648.Üretim Sonucu Kaydedilmiştir'>!");
		wrk_opener_reload();
        window.close();
</script>