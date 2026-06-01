<!---
    File: upd_ezgi_p_order_group.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_sub_p_order_control" datasource="#dsn3#">
	SELECT P_ORDER_ID FROM PRODUCTION_ORDERS WHERE PO_RELATED_ID IN (#p_order_id_list#)	
</cfquery>
<cfif get_sub_p_order_control.recordcount>
	<script language="javascript">
        alert ('<cf_get_lang dictionary_id='659.Birleştirmek İstediğiniz Emirlerin İlişkili Alt Emirleri Mevcut. Lütfen Önce Alt Emirleri Birleştiriniz .'>!');
		history.back();
    </script>
<cfelse>
		<cfquery name="get_station_id" datasource="#dsn3#">
        	SELECT     
             	EMS.WORKSTATION_ID
			FROM         
               	EZGI_MASTER_ALT_PLAN AS EMP INNER JOIN
            	EZGI_MASTER_PLAN_SABLON AS EMS ON EMP.PROCESS_ID = EMS.PROCESS_ID
			WHERE     
               	EMP.MASTER_ALT_PLAN_ID = #master_alt_plan_id#
        </cfquery>
        <cfset p_station_id = get_station_id.WORKSTATION_ID>
        <cfquery name="get_p_orders" datasource="#dsn3#">
        	SELECT     
              	P_ORDER_ID
            FROM          
               	(
                SELECT     
                   	P_ORDER_ID,	(
                       			SELECT     
                                   	SUM(AMOUNT) AS AMOUNT
                               	FROM          
                                   	(
                                    SELECT     
                                       	ISNULL(POR.REAL_AMOUNT, 0) AS AMOUNT
                                   	FROM          
                                       	PRODUCTION_OPERATION AS PO LEFT OUTER JOIN
                                        PRODUCTION_OPERATION_RESULT AS POR ON PO.P_ORDER_ID = POR.P_ORDER_ID
                                   	WHERE      
                                       	PO.P_ORDER_ID = PRODUCTION_ORDERS_2.P_ORDER_ID
                                    UNION ALL
                                    SELECT     
                                       	ISNULL(POR.LOSS_AMOUNT, 0) AS AMOUNT
                                   	FROM         
                                       	PRODUCTION_OPERATION AS PO LEFT OUTER JOIN
                                        PRODUCTION_OPERATION_RESULT AS POR ON PO.P_ORDER_ID = POR.P_ORDER_ID
                                   	WHERE     
                                       	PO.P_ORDER_ID = PRODUCTION_ORDERS_2.P_ORDER_ID
                            		) AS TBL) AS AMOUNT
            	FROM          
                   	PRODUCTION_ORDERS AS PRODUCTION_ORDERS_2
                WHERE      
                   	STATION_ID = #p_station_id# AND 
                    IS_STAGE IN (0, 4) AND
                    LOT_NO IN (
                       			SELECT     
                                   	LOT_NO
                               	FROM          
                                  	PRODUCTION_ORDERS AS PRODUCTION_ORDERS_1
                               	WHERE      
                                  	P_ORDER_ID IN (#p_order_id_list#)
                              	) 
                ) AS TBL2
            WHERE      
              	AMOUNT = 0
        </cfquery>
        <cfset _p_order_id_list = Valuelist(get_p_orders.P_ORDER_ID)>
        <cfif len(_p_order_id_list)>
        	<!---Seçilen Emirlerin İşe yarar olanlarını çekiyoruz--->
        	<cfquery name="get_p_orders" datasource="#dsn3#">
            	SELECT * FROM PRODUCTION_ORDERS WHERE P_ORDER_ID IN (#_p_order_id_list#)
            </cfquery>
            <cfquery name="get_p_orders_spec_main_id" dbtype="query">
            	SELECT SPEC_MAIN_ID	FROM get_p_orders GROUP BY SPEC_MAIN_ID
            </cfquery>
            <cfset spec_main_id_list = Valuelist(get_p_orders_spec_main_id.SPEC_MAIN_ID)>
            <!---Seçilen Emirlerin Operasyonlarını Belirliyoruz--->
            <cfquery name="get_p_order_operations" datasource="#dsn3#">
            	SELECT * FROM PRODUCTION_OPERATION WHERE P_ORDER_ID IN (#_p_order_id_list#)
            </cfquery>
            <cfset p_operation_list = Valuelist(get_p_order_operations.P_OPERATION_ID)>
            <!---Seçilen Emirlerin Stok ID lerini Belirliyoruz--->
        	<cfquery name="get_p_order_stocks" datasource="#dsn3#">
            	SELECT 
                	POR_STOCK_ID, P_ORDER_ID, PRODUCT_ID, STOCK_ID,AMOUNT, TYPE, PRODUCT_UNIT_ID, RECORD_DATE, RECORD_EMP, 
                    RECORD_IP, IS_PHANTOM, IS_SEVK, IS_PROPERTY, IS_FREE_AMOUNT, FIRE_AMOUNT, FIRE_RATE, SPECT_MAIN_ROW_ID, 
                    IS_FLAG, WRK_ROW_ID,ISNULL(SPECT_MAIN_ID,0)	SPECT_MAIN_ID 
             	FROM 
                	PRODUCTION_ORDERS_STOCKS 
              	WHERE 
                	P_ORDER_ID IN (#_p_order_id_list#)
            </cfquery>
            <cfset p_stock_list = Valuelist(get_p_order_stocks.POR_STOCK_ID)>
			<cfif len(spec_main_id_list)>
                <cfloop list="#spec_main_id_list#" index="i">
                	<!---Döngüdeki Bir SPEC_MAIN_ID ye ait Birleşecek Emirler Bulunuyor--->
                	<cfquery name="get_spec_main_p_order_id" dbtype="query">
                		SELECT P_ORDER_ID FROM get_p_orders WHERE SPEC_MAIN_ID = #i#
                    </cfquery>
                    <cfset old_p_order_id_list = Valuelist(get_spec_main_p_order_id.P_ORDER_ID)>
                    <cfset 'p_order_list_#i#' = Valuelist(get_spec_main_p_order_id.P_ORDER_ID)>>
                    <!---Döngüdeki Bir SPEC_MAIN_ID En Son Girilen Emir Numarası Bulunuyor--->
                    <cfquery name="get_max_p_order_row" dbtype="query">
                		SELECT MAX(P_ORDER_ID) P_ORDER_ID FROM get_p_orders WHERE SPEC_MAIN_ID = #i#
                    </cfquery>
                    <cfset 'max_p_order_#i#' = get_max_p_order_row.P_ORDER_ID>
                    <!---Döngüdeki Bir SPEC_MAIN_ID Birleştirilecek emirlerin miktarı toplanıyor--->
                    <cfquery name="get_sum_amount_p_order_row" dbtype="query">
                		SELECT SUM(QUANTITY) QUANTITY FROM get_p_orders WHERE SPEC_MAIN_ID = #i#
                    </cfquery>
                    <cfset 'sum_p_order_#i#' = get_sum_amount_p_order_row.QUANTITY>
                    <!---Birleşecek Operasyonlar Operasyon Tiplerine Miktarlar Toplanıyor.--->
                    <cfquery name="get_sum_amount_p_order_operations" dbtype="query">
                		SELECT 
                        	SUM(AMOUNT) AS AMOUNT, 
                            OPERATION_TYPE_ID 
                       	FROM 
                        	get_p_order_operations 
                       	WHERE 
                        	P_ORDER_ID IN (#old_p_order_id_list#)
						GROUP BY 
                        	OPERATION_TYPE_ID
                    </cfquery>
                    <cfoutput query="get_sum_amount_p_order_operations">
                    	<cfset 'AMOUNT_#i#_#OPERATION_TYPE_ID#' = AMOUNT>
                    </cfoutput>
                    <!---Birleşecek Operasyonlar Operasyon Tiplerine Max ID ler Bulunuyor.--->
                    <cfquery name="get_max_p_operation_id" dbtype="query">	
                    	SELECT     
                        	MAX(P_OPERATION_ID) AS P_OPERATION_ID
						FROM         
                        	get_p_order_operations
						WHERE     
                        	P_ORDER_ID IN (#old_p_order_id_list#)
						GROUP BY 
                        	OPERATION_TYPE_ID
                    </cfquery>
                    <cfset 'operation_id_list_#i#' = Valuelist(get_max_p_operation_id.P_OPERATION_ID)>
                    <!---Birleşecek Stoklar SPECT_MAIN_ID lerine göre Miktarlar Toplanıyor.--->
                    <cfquery name="get_sum_amount_p_order_stocks" dbtype="query">
						SELECT     
                        	STOCK_ID, 
                            SPECT_MAIN_ID, 
                            SUM(AMOUNT) AS AMOUNT
						FROM         
                        	get_p_order_stocks
						WHERE     
                        	P_ORDER_ID IN (#old_p_order_id_list#)
						GROUP BY 
                        	STOCK_ID, 
                        	SPECT_MAIN_ID
					</cfquery>
                    <cfoutput query="get_sum_amount_p_order_stocks">
                    	<cfset 'AMOUNT_#i#_#SPECT_MAIN_ID#_#STOCK_ID#' = AMOUNT>
                    </cfoutput>
                    <!---Birleşecek Stoklar SPECT_MAIN_ID lerine göre Max ID ler Bulunuyor--->
                    <cfquery name="get_max_por_stock_id" dbtype="query">
                    	SELECT     
                        	MAX(POR_STOCK_ID) AS POR_STOCK_ID
						FROM         
                        	get_p_order_stocks
						WHERE     
                        	P_ORDER_ID IN (#old_p_order_id_list#)
						GROUP BY 
                        	STOCK_ID, 
                            SPECT_MAIN_ID
                    </cfquery>
                    <cfset 'stock_id_list_#i#' = Valuelist(get_max_por_stock_id.POR_STOCK_ID)>
                </cfloop>
                <cftransaction>
                	<cfquery name="add_ezgi_p_orders" datasource="#dsn3#">
                        INSERT INTO 
                            EZGI_PRODUCTION_ORDERS
                            (
                            P_ORDER_ID, STOCK_ID, DP_ORDER_ID, ORDER_ID, STATION_ID, START_DATE, FINISH_DATE, QUANTITY, STATUS_ID, STATUS, PROJECT_ID, 
                            P_ORDER_NO, PO_RELATED_ID, ORDER_ROW_ID, SPECT_VAR_ID, SPECT_VAR_NAME, DETAIL, PROD_ORDER_STAGE, IS_STOCK_RESERVED, PRINT_COUNT, 
                            IS_DEMONTAJ, LOT_NO, REFERENCE_NO, PRODUCTION_LEVEL, SPEC_MAIN_ID, PRODUCT_NAME2, IS_GROUP_LOT, IS_STAGE, WRK_ROW_ID, EXIT_DEP_ID, 
                            EXIT_LOC_ID, DEMAND_NO, PRODUCTION_DEP_ID, PRODUCTION_LOC_ID, RECORD_IP, RECORD_EMP, RECORD_DATE, UPDATE_EMP, UPDATE_DATE, 
                            UPDATE_IP, WORK_ID, RESULT_AMOUNT, WRK_ROW_RELATION_ID	
                            )
                           SELECT
                                P_ORDER_ID, STOCK_ID, DP_ORDER_ID, ORDER_ID, STATION_ID, START_DATE, FINISH_DATE, QUANTITY, STATUS_ID, STATUS, PROJECT_ID, 
                                P_ORDER_NO, PO_RELATED_ID, ORDER_ROW_ID, SPECT_VAR_ID, SPECT_VAR_NAME, DETAIL, PROD_ORDER_STAGE, IS_STOCK_RESERVED, PRINT_COUNT, 
                                IS_DEMONTAJ, LOT_NO, REFERENCE_NO, PRODUCTION_LEVEL, SPEC_MAIN_ID, PRODUCT_NAME2, IS_GROUP_LOT, IS_STAGE, WRK_ROW_ID, EXIT_DEP_ID, 
                                EXIT_LOC_ID, DEMAND_NO, PRODUCTION_DEP_ID, PRODUCTION_LOC_ID, RECORD_IP, RECORD_EMP, RECORD_DATE, UPDATE_EMP, UPDATE_DATE, 
                                UPDATE_IP, WORK_ID, RESULT_AMOUNT, WRK_ROW_RELATION_ID
                            FROM
                              PRODUCTION_ORDERS
                            WHERE
                                P_ORDER_ID IN (#_p_order_id_list#)               
                    </cfquery>
                    <cfquery name="add_ezgi_p_operatios" datasource="#dsn3#">
                        INSERT INTO
                            EZGI_PRODUCTION_OPERATION
                            (
                            P_OPERATION_ID, P_ORDER_ID, AMOUNT, STATION_ID, OPERATION_TYPE_ID, STAGE, O_MINUTE, RELATED_OP_ID, RECORD_EMP, RECORD_DATE, RECORD_IP, 
                            UPDATE_EMP, UPDATE_DATE, UPDATE_IP
                            )
                            SELECT
                                P_OPERATION_ID, P_ORDER_ID, AMOUNT, STATION_ID, OPERATION_TYPE_ID, STAGE, O_MINUTE, RELATED_OP_ID, RECORD_EMP, RECORD_DATE, RECORD_IP, 
                                UPDATE_EMP, UPDATE_DATE, UPDATE_IP
                            FROM         
                                PRODUCTION_OPERATION
                            WHERE            
                                P_ORDER_ID IN (#_p_order_id_list#)
                    </cfquery>
                    <cfquery name="add_ezgi_p_stocks" datasource="#dsn3#">
                        INSERT INTO
                            EZGI_PRODUCTION_ORDERS_STOCKS
                            (
                            POR_STOCK_ID, P_ORDER_ID, PRODUCT_ID, STOCK_ID, SPECT_MAIN_ID, AMOUNT, TYPE, PRODUCT_UNIT_ID, RECORD_DATE, RECORD_EMP, 
                              RECORD_IP, IS_PHANTOM, IS_SEVK, IS_PROPERTY, IS_FREE_AMOUNT, FIRE_AMOUNT, FIRE_RATE, SPECT_MAIN_ROW_ID, IS_FLAG, WRK_ROW_ID
                            )
                            SELECT
                                POR_STOCK_ID, P_ORDER_ID, PRODUCT_ID, STOCK_ID, SPECT_MAIN_ID, AMOUNT, TYPE, PRODUCT_UNIT_ID, RECORD_DATE, RECORD_EMP, 
                              RECORD_IP, IS_PHANTOM, IS_SEVK, IS_PROPERTY, IS_FREE_AMOUNT, FIRE_AMOUNT, FIRE_RATE, SPECT_MAIN_ROW_ID, IS_FLAG, WRK_ROW_ID
                            FROM
                                PRODUCTION_ORDERS_STOCKS
                            WHERE            
                                P_ORDER_ID IN (#_p_order_id_list#)
                    </cfquery>
                    <cfloop list="#spec_main_id_list#" index="i">
                    	<cf_papers paper_type="production_lot"><!--- Lotnumarası her üretim için tek tek alınıyor!--->
						<cfscript>
                            lot_system_paper_no=paper_code & '-' & paper_number;
                            lot_system_paper_no_add=paper_number;
                        </cfscript>
                        <cfstoredproc procedure="UPD_GENERAL_PAPERS_LOT_NUMBER" datasource="#dsn3#">
                            <cfprocparam cfsqltype="cf_sql_integer" value="#lot_system_paper_no_add#">
                        </cfstoredproc>
                        
                        <cf_papers paper_type="prod_order"><!--- Belge Numarası her üretim için tek tek alınıyor! --->
                        <cfscript>
                            system_paper_no=paper_code & '-' & paper_number;
                            system_paper_no_add=paper_number;
                        </cfscript>
                    	<cfset new_keyword_ = "#system_paper_no#">
                        <cfset wrk_id_new = 'WRK#round(rand()*65)##dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmssL')##session.ep.userid##round(rand()*100)#'>
                        <cfquery name="add_new_production_order" datasource="#dsn3#"> 	     
           					INSERT INTO 
                                PRODUCTION_ORDERS
                                (
                                STOCK_ID, 
                                STATION_ID, 
                                START_DATE, 
                                FINISH_DATE, 
                                STATUS, 
                                SPECT_VAR_NAME, 
                                DETAIL, 
                                PROD_ORDER_STAGE, 
                                IS_STOCK_RESERVED, 
                                SPEC_MAIN_ID, 
                                EXIT_DEP_ID, 
                                EXIT_LOC_ID, 
                                PRODUCTION_DEP_ID, 
                                PRODUCTION_LOC_ID, 
                                PROJECT_ID,
                                IS_DEMONTAJ,
                                P_ORDER_NO, 
                                WRK_ROW_ID, 
                                QUANTITY, 
                                LOT_NO, 
                                PRODUCTION_LEVEL, 
                                IS_GROUP_LOT, 
                                IS_STAGE	
                                )
                               SELECT
                                    STOCK_ID, STATION_ID, START_DATE, FINISH_DATE, STATUS, SPECT_VAR_NAME, DETAIL, PROD_ORDER_STAGE, IS_STOCK_RESERVED, SPEC_MAIN_ID, 
                                    EXIT_DEP_ID, EXIT_LOC_ID, PRODUCTION_DEP_ID, PRODUCTION_LOC_ID, PROJECT_ID, IS_DEMONTAJ, #new_keyword_#, 
                                    '#wrk_id_new#', '#Evaluate('sum_p_order_#i#')#', '#lot_system_paper_no#', 0, NULL, 4
                                FROM
                                  EZGI_PRODUCTION_ORDERS
                                WHERE
                                    P_ORDER_ID = #Evaluate('max_p_order_#i#')#
      					</cfquery>
                        <cfstoredproc procedure="UPD_GENERAL_PAPERS_PROD_ORDER_NUMBER" datasource="#dsn3#">
                            <cfprocparam cfsqltype="cf_sql_integer" value="#system_paper_no_add#">
                        </cfstoredproc>
                        <cfstoredproc procedure="GET_PRODUCTION_ORDER_MAX" datasource="#dsn3#">
                            <cfprocparam cfsqltype="cf_sql_varchar" value="#wrk_id_new#">
                            <cfprocresult name="GET_MAX">
                        </cfstoredproc>
                        <cfset new_p_order_id = GET_MAX.PID>
                        <cfquery name="upd_ezgi_p_orders" datasource="#dsn3#">
                        	UPDATE 
                            	EZGI_PRODUCTION_ORDERS
                           	SET
                            	OLD_P_ORDER_ID = #new_p_order_id#    
                        	WHERE
                            	P_ORDER_ID IN (#Evaluate('p_order_list_#i#')#)
                        </cfquery>
                        <cfquery name="ADD_MASTER_PLAN_RELATION" datasource="#dsn3#">
                        	INSERT INTO   
                               	EZGI_MASTER_PLAN_RELATIONS
                               	(
                                MASTER_ALT_PLAN_ID, 
                                PROCESS, 
                                P_ORDER_ID, 
                                PROCESS_ID, 
                                MASTER_PLAN_ID,
                                STATION_ID
                            	)
                            VALUES
                               	(
                                #attributes.master_alt_plan_id#,
                                'Üretim Planı',
                                #new_p_order_id#,
                                #islem_id#,
                                #master_plan_id#,
                                #p_station_id#
                                )       
                      	</cfquery>
                        <cfloop list="#Evaluate('operation_id_list_#i#')#" index="J">
                      		<cfquery name="get_new_operation_type_id" dbtype="query">
                        		SELECT OPERATION_TYPE_ID FROM get_p_order_operations WHERE P_OPERATION_ID = #J#
                        	</cfquery>
                            <cfset new_operation_type_id = get_new_operation_type_id.OPERATION_TYPE_ID>
                            <cfquery name="add_new_production_operations" datasource="#dsn3#">
                            	INSERT INTO
                                	PRODUCTION_OPERATION
                                    (
                                    OPERATION_TYPE_ID, 
                                    P_ORDER_ID, 
                                    AMOUNT, 
                                    STAGE,
                                    RECORD_IP, 
                                    RECORD_EMP, 
                                    RECORD_DATE
                                    )
                               	VALUES
                                	(     
                                	#new_operation_type_id#, 
                                    #new_p_order_id#, 
                                    #Evaluate('AMOUNT_#i#_#new_operation_type_id#')#, 
                                    0, 
                                    '#CGI.REMOTE_ADDR#', 
                                    #session.ep.userid#, 
                                    #now()#
								   	)
                            </cfquery>
                        </cfloop>
                        <cfloop list="#Evaluate('stock_id_list_#i#')#" index="k">
                      		<cfquery name="get_new_stock_id" dbtype="query">
                        		SELECT  STOCK_ID, SPECT_MAIN_ID FROM get_p_order_stocks WHERE POR_STOCK_ID = #k#
                        	</cfquery>
                            <cfset new_stock_id = get_new_stock_id.STOCK_ID>
                            <cfset new_spect_main_id = get_new_stock_id.SPECT_MAIN_ID>
                           
                            <cfquery name="add_new_production_stocks" datasource="#dsn3#">
                            	INSERT INTO
                                	PRODUCTION_ORDERS_STOCKS
                                    ( 
                                    PRODUCT_ID, 
                                    STOCK_ID, 
                                    SPECT_MAIN_ID, 
                                    TYPE, 
                                    PRODUCT_UNIT_ID, 
                                    IS_PHANTOM, 
                                    IS_SEVK, 
                                    IS_PROPERTY, 
                                    IS_FREE_AMOUNT, 
                                    FIRE_AMOUNT, 
                                    FIRE_RATE, 
                      				SPECT_MAIN_ROW_ID, 
                                    IS_FLAG, 
                                    P_ORDER_ID, 
                                    AMOUNT, 
                                    WRK_ROW_ID, 
                                    RECORD_IP, 
                                    RECORD_EMP, 
                      				RECORD_DATE
                                    )
                             	SELECT
                                    PRODUCT_ID, 
                                    STOCK_ID, 
                                    SPECT_MAIN_ID, 
                                    TYPE, 
                                    PRODUCT_UNIT_ID, 
                                    IS_PHANTOM, 
                                    IS_SEVK, 
                                    IS_PROPERTY, 
                                    IS_FREE_AMOUNT, 
                                    FIRE_AMOUNT, 
                                    FIRE_RATE, 
                      				SPECT_MAIN_ROW_ID, 
                                    IS_FLAG, 
                                    #new_p_order_id#, 
                                    #Evaluate('AMOUNT_#i#_#new_spect_main_id#_#new_stock_id#')#, 
                                    '#wrk_id_new#', 
                                    '#CGI.REMOTE_ADDR#', 
                                    #session.ep.userid#, 
                                    #now()#
                               	FROM
                                 	EZGI_PRODUCTION_ORDERS_STOCKS 
                              	WHERE
                                	POR_STOCK_ID = #k#         
                            </cfquery>
                    	</cfloop>             
            		</cfloop>
                    <cfquery name="DEL_ROW" datasource="#dsn3#">
                        DELETE FROM PRODUCTION_ORDERS_ROW WHERE PRODUCTION_ORDER_ID IN(#_p_order_id_list#)
                    </cfquery>        
                    <cfquery name="DEL_PROD_ORDER" datasource="#dsn3#">
                        DELETE FROM PRODUCTION_OPERATION WHERE P_ORDER_ID IN(#_p_order_id_list#)
                    </cfquery>
                    <cfquery name="DEL_PROD_ORDER" datasource="#dsn3#">
                        DELETE FROM PRODUCTION_ORDERS WHERE P_ORDER_ID IN(#_p_order_id_list#)
                    </cfquery>
                    <cfquery name="DEL_PROD_ORDER_STOCKS" datasource="#dsn3#">
                        DELETE FROM PRODUCTION_ORDERS_STOCKS WHERE P_ORDER_ID IN(#_p_order_id_list#)
                    </cfquery>
              	</cftransaction>      
            <cfelse>
            	<script language="javascript">
					alert ('<cf_get_lang dictionary_id='660.Birleştirecek Emir Bulunamadı'>.!');
					history.back();
				</script>    
            </cfif>
        <cfelse>
        	<script language="javascript">
				alert ('<cf_get_lang dictionary_id='661.Birleşmeye Uygun Emir Bulunamadı'>.!');
				history.back();
			</script>
        </cfif>
	<cflocation url="#request.self#?fuseaction=prod.upd_ezgi_master_sub_plan_manual&master_plan_id=#attributes.master_plan_id#&master_alt_plan_id=#attributes.master_alt_plan_id#&islem_id=#attributes.islem_id#" addtoken="No">
</cfif>