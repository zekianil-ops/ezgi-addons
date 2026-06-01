<!---
    File: del_ezgi_iflow_production_order_result.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfquery name="get_general_info" datasource="#dsn#">
	SELECT ISNULL(IS_SERIAL_CONTROL_LOCATION,0) AS IS_SERIAL_CONTROL_LOCATION FROM OUR_COMPANY_INFO WHERE COMP_ID = #session.ep.company_id#
</cfquery>
	
<cflock name="#CREATEUUID()#" timeout="90">
    <cftransaction>
		<cfloop list="#attributes.pr_order_id_list#" index="i">
        	<cfquery name="get_stock_info" datasource="#dsn3#">
                SELECT 
                    PR.PRODUCTION_DEP_ID,
                    PR.PRODUCTION_LOC_ID,
                    PR.PR_ORDER_ID, 
                    PR.STATION_ID, 
                    PR.RESULT_NO, 
                    ISNULL(PR.IS_STOCK_FIS,0) AS IS_STOCK_FIS, 
                    PRR.AMOUNT, 
                    PRR.SPEC_MAIN_ID, 
                    ISNULL(S.IS_SERIAL_NO,0) AS IS_SERIAL_NO
                FROM     
                    PRODUCTION_ORDER_RESULTS AS PR INNER JOIN
                    PRODUCTION_ORDER_RESULTS_ROW AS PRR ON PR.PR_ORDER_ID = PRR.PR_ORDER_ID INNER JOIN
                    STOCKS AS S ON PRR.STOCK_ID = S.STOCK_ID
                WHERE  
                    PR.PR_ORDER_ID = #i# AND 
                    PRR.TYPE = 1
            </cfquery>
            <cfif get_stock_info.recordcount>
            	
                <!---ŞİRKET BAZINDA SERİ NO ÇALIŞACAKSA--->
                <cfif get_general_info.IS_SERIAL_CONTROL_LOCATION eq 1>
                	<!---ÜRÜN SERİ NO LU İSE--->
					<cfif get_stock_info.IS_SERIAL_NO eq 1>
                        <cfquery name="get_serial" datasource="#dsn3#">
                            SELECT 
                                SERIAL_NO
                            FROM     
                                SERVICE_GUARANTY_NEW
    						WHERE  
                            	PROCESS_ID = #i# AND 
                                PROCESS_CAT = 171 AND 
                                NOT (SERIAL_NO IS NULL)
                        </cfquery>
                        <!---SERİ NO BULUNDUYSA--->
                        <cfif get_serial.recordcount>
                            <cfloop query="get_serial">
                            	<!---SERİ NO DOĞUM KAYIDINI SİL--->
                            	<cfquery name="del_serial_1" datasource="#dsn3#">
                                    DELETE FROM
                                        SERVICE_GUARANTY_NEW
                                    WHERE 
                                        SERIAL_NO = '#get_serial.SERIAL_NO#'  
                            	</cfquery> 
                                <!---SERİ NO HAREKET KAYITLARINI SİL--->
                                <cfquery name="del_serial_2" datasource="#dsn3#">
                                    DELETE FROM 
                                    	EZGI_WM_SERIAL_NO_ACTION
									WHERE  
                                    	SERIAL_NO = '#get_serial.SERIAL_NO#'  
                            	</cfquery>
                                <!---SERİ NO SİPARİŞ BAĞLANTI KAYITLARINI SİL--->
                                <cfquery name="del_serial_3" datasource="#dsn3#">
                                    DELETE FROM 
                                    	EZGI_WM_SERIAL_NO_ORDER_ACTION
									WHERE  
                                    	SERIAL_NO = '#get_serial.SERIAL_NO#'  
                            	</cfquery>
                                <!---SERİ NO ÜRETİM SİPARİŞ YUVALARINI BOŞALT--->
                                <cfquery name="upd_serial_1" datasource="#dsn3#">
                                	UPDATE 	
                                    	PRODUCTION_ORDERS_ROW
									SET          
                                    	SERIAL_NO = NULL
									WHERE  
                                    	SERIAL_NO = '#get_serial.SERIAL_NO#'  AND 
                                        PRODUCTION_ORDER_ID = #attributes.p_order_id#
                             	</cfquery>
                            </cfloop>
                        </cfif>
                        <!---SEİ NO BULUNDUYSA--->
                    </cfif>
                    <!---ÜRÜN SERİ NO LU İSE--->
                </cfif>
                <!---ŞİRKET BAZINDA SERİ NO ÇALIŞACAKSA--->
				
				<!---STOK HAREKETİ YAPILMIŞSA--->
                <cfif get_stock_info.IS_STOCK_FIS eq 1>
                	<cfquery name="get_stock_fis" datasource="#dsn3#">
                    	SELECT 
                        	FIS_ID
						FROM     
                        	#dsn2_alias#.STOCK_FIS
						WHERE  
                        	FIS_TYPE IN (110,111) AND
                            PROD_ORDER_RESULT_NUMBER = #i#
                    </cfquery>
                    <cfif get_stock_fis.recordcount>
                    	<cfset stock_fis_id_list = ValueList(get_stock_fis.FIS_ID)>
                        <!---STOK FİŞİNİ SİL--->
                        <cfquery name="del_stock_fis" datasource="#dsn3#">
                        	DELETE FROM #dsn2_alias#.STOCK_FIS WHERE FIS_ID IN (#stock_fis_id_list#)
                        </cfquery>
                        <!---STOK FİŞ SATIRLARINI SİL--->
                        <cfquery name="del_stock_fis_row" datasource="#dsn3#">
                        	DELETE FROM #dsn2_alias#.STOCK_FIS_ROW WHERE FIS_ID IN (#stock_fis_id_list#)
                        </cfquery>
                        <!---STOK FİŞ money sil--->
                        <cfquery name="del_stock_fis_money" datasource="#dsn3#">
                        	DELETE FROM #dsn2_alias#.STOCK_FIS_MONEY WHERE ACTION_ID IN (#stock_fis_id_list#)
                        </cfquery>
                        <!---STOK ROW SATIRLARINI SİL--->
                        <cfquery name="del_stock_fis_money" datasource="#dsn3#">
                        	DELETE FROM #dsn2_alias#.STOCKS_ROW WHERE UPD_ID IN (#stock_fis_id_list#)
                        </cfquery>
                 	</cfif>
                </cfif>
                <!---STOK HAREKETİ YAPILMIŞSA--->
                
                <!---OPERASYON HAREKETİ YAPILMIŞSA--->
                <cfquery name="get_operation_result" datasource="#dsn3#">
                	SELECT TOP (1) 
                    	PORR.OPERATION_ID, 
                        PORR.OPERATION_RESULT_ID, 
                        PO.STAGE
					FROM     
                    	PRODUCTION_ORDER_RESULTS AS POR INNER JOIN
                  		PRODUCTION_OPERATION_RESULT AS PORR ON POR.P_ORDER_ID = PORR.P_ORDER_ID AND POR.STATION_ID = PORR.STATION_ID AND POR.RECORD_EMP = PORR.RECORD_EMP INNER JOIN
                  		PRODUCTION_ORDER_RESULTS_ROW AS POOR ON POR.PR_ORDER_ID = POOR.PR_ORDER_ID AND PORR.REAL_AMOUNT = POOR.AMOUNT INNER JOIN
                  		PRODUCTION_OPERATION AS PO ON PORR.OPERATION_ID = PO.P_OPERATION_ID
					WHERE  
                    	POR.PR_ORDER_ID = #i#  AND 
                        POOR.TYPE = 1
					ORDER BY 
                    	PORR.OPERATION_RESULT_ID DESC
                </cfquery>
                <!---ENSON YAPILAN OPERASYONU SİL (bİTİREN kİŞİ = bİTEN mİKTAR = bİTEN İSTASYON AYNI İSE)--->
                <cfif get_operation_result.recordcount>
                	
                    <!---OPERASYON SONUCUNU SİL--->
                	<cfquery name="del_operation_result" datasource="#dsn3#">
                    	DELETE FROM 
                        	PRODUCTION_OPERATION_RESULT
						WHERE  
                        	OPERATION_ID = #get_operation_result.OPERATION_ID# AND 
                            OPERATION_RESULT_ID = #get_operation_result.OPERATION_RESULT_ID#
                    </cfquery>
                    <!---OPERASYONA BAĞLI BAŞKA SONUÇ VARMI--->
                    <cfquery name="get_operation" datasource="#dsn3#">
                    	SELECT 
                        	PO.AMOUNT, 
                            SUM(PORR.REAL_AMOUNT) AS REAL_AMOUNT
						FROM     
                        	PRODUCTION_OPERATION_RESULT AS PORR INNER JOIN
                  			PRODUCTION_OPERATION AS PO ON PORR.OPERATION_ID = PO.P_OPERATION_ID
						WHERE  
                        	PO.P_OPERATION_ID = #get_operation_result.OPERATION_ID#
						GROUP BY 
                        	PO.AMOUNT
                    </cfquery>
                    <!---EĞER BAŞKA OPERASYON SONUCU VARSA--->
                    <cfif get_operation.recordcount>
                    	<cfif get_operation.AMOUNT lte get_operation.REAL_AMOUNT>
                        	<!---OPERASYON SONUCU OPERASYON MİKTARINDAN DAHA FAZLA VEYA EŞİR İSE OPERASYONU BİTTİ DURUMUNA GETİR--->
                        	<cfquery name="get_operation" datasource="#dsn3#">
                                UPDATE 
                                    PRODUCTION_OPERATION
                                SET          
                                    STAGE = 3
                                WHERE  
                                    P_OPERATION_ID = #get_operation_result.OPERATION_ID#
                            </cfquery>
                        <cfelse>
                        	<!---OPERASYON SONUCU OPERASYON MİKTARINDAN DAHA AZ İSE OPERASYONU BAŞLADI DURUMUNA GETİR--->
                        	<cfquery name="get_operation" datasource="#dsn3#">
                                UPDATE 
                                    PRODUCTION_OPERATION
                                SET          
                                    STAGE = 1
                                WHERE  
                                    P_OPERATION_ID = #get_operation_result.OPERATION_ID#
                            </cfquery>
                        </cfif>
                    <cfelse>
                    	<!---EĞER BAŞKA OPERASYON SONUCU YOKSA OPERASYONU BAŞLAMADI KONUMUNA GETİR.--->
                    	<cfquery name="get_operation" datasource="#dsn3#">
                        	UPDATE 
                            	PRODUCTION_OPERATION
                            SET          
                            	STAGE = 0
                            WHERE  
                            	P_OPERATION_ID = #get_operation_result.OPERATION_ID#
                        </cfquery>
                    </cfif>
                </cfif>
                <!---OPERASYON HAREKETİ YAPILMIŞSA--->
                
                <!---ÜRETİM SONUCUNU SİL--->
                <cfquery name="del_result" datasource="#dsn3#">
                    DELETE FROM     
                        PRODUCTION_ORDER_RESULTS
                    WHERE  
                        PR_ORDER_ID = #i#	
                </cfquery>
                <!---ÜRETİM SONUÇ SATIRLARINI SİL--->
                <cfquery name="del_result_row" datasource="#dsn3#">
                    DELETE FROM     
                        PRODUCTION_ORDER_RESULTS_ROW
                    WHERE  
                        PR_ORDER_ID = #i#	
                </cfquery>
                <!---ÜRETİM EMRİNE BAĞLI BAŞKA SONUÇ VARMI--->
               	<cfquery name="get_order_info" datasource="#dsn3#">
                	SELECT 
                    	PO.QUANTITY, 
                        PO.P_ORDER_ID, 
                        SUM(POOR.AMOUNT) AS AMOUNT
                    FROM     
                    	PRODUCTION_ORDER_RESULTS AS POR INNER JOIN
                        PRODUCTION_ORDER_RESULTS_ROW AS POOR ON POR.PR_ORDER_ID = POOR.PR_ORDER_ID INNER JOIN
                        PRODUCTION_ORDERS AS PO ON POR.P_ORDER_ID = PO.P_ORDER_ID
                    WHERE  
                    	POOR.TYPE = 1
                    GROUP BY 
                    	PO.QUANTITY, 
                        PO.P_ORDER_ID
                    HAVING 
                    	PO.P_ORDER_ID = #attributes.p_order_id#
                </cfquery>
                <!---ÜRETİM EMRİNE BAĞLI BAŞKA SONUÇ varsa--->
                <cfif get_order_info.recordcount>
                	<cfif get_order_info.QUANTITY lte get_order_info.AMOUNT>
                    	<!---ÜRETİM EMRİ KDAR VEYA DAHA FAZLA ÜRETİM SONUCU VARSA ÜRETİMİ KAPALI HALE GETİR--->
                    	<cfquery name="upd_order_stage" datasource="#dsn3#">
                            UPDATE 
                                PRODUCTION_ORDERS
                            SET          
                                IS_STOCK_RESERVED = 0, 
                                IS_STAGE = 2
                            WHERE  
                                P_ORDER_ID = #attributes.p_order_id#
                        </cfquery>
                    <cfelse>
                    <!---ÜRETİM EMRİNDEN DAHA AZ ÜRETİM SONUÇLANMIŞSA ÜRETİMİ BAŞLADI YAP --->
                    	<cfquery name="upd_order_stage" datasource="#dsn3#">
                            UPDATE 
                                PRODUCTION_ORDERS
                            SET          
                                IS_STOCK_RESERVED = 1, 
                                IS_STAGE = 1
                            WHERE  
                                P_ORDER_ID = #attributes.p_order_id#
                        </cfquery>
                    </cfif> 
                <cfelse>
                	<!---ÜRETİM EMRİNE BAĞLI BAŞKA SONUÇ yoksA ÜRETİMİ AÇIK HALE GETİR.--->
                	<cfquery name="upd_order_stage" datasource="#dsn3#">
                    	UPDATE 
                        	PRODUCTION_ORDERS
						SET          
                        	IS_STOCK_RESERVED = 1, 
                            IS_STAGE = 0
						WHERE  
                        	P_ORDER_ID = #attributes.p_order_id#
                    </cfquery>
                </cfif> 
                <!---ÜRETİM SONUCUNU SİL--->
            </cfif>
        </cfloop>
    </cftransaction>
</cflock>
<script type="text/javascript">
 	alert('Üretim Sonucu Silinmiştir!');
   	window.location ="<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_iflow_production_order_result&p_order_id=#p_order_id#</cfoutput>";
</script>
