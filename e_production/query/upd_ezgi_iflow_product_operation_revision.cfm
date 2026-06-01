<!---
    File: upd_ezgi_iflow_product_operation_revision.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset ekle_kontrol = 0>
<cftransaction>
	<cfif attributes.ekle_radio eq 0 or attributes.ekle_radio eq 2><!--- Ekle veya Değiştir seçeneği için Eklenmiş Operasyon Kontrolü Yapılıyor--->
        <cfif isdefined('attributes.record_num') and len(attributes.record_num)>
            <cfloop from="1" to="#attributes.record_num#" index="i">
                <cfif Evaluate('attributes.row_kontrol#i#') eq 1>
                    <cfset ekle_kontrol = 1>
                </cfif>
            </cfloop>
        </cfif>
        <cfif ekle_kontrol eq 1>
        	<cfloop list="#attributes.P_ORDER_ID_LIST#" index="p_order_id"> <!---Her Üretim Emri İçin Tektek Döndürüyoruz--->
            	<cfif attributes.ekle_radio eq 2>
                    <cfquery name="control_operation" datasource="#dsn3#"> <!---Seçilmiş Operasyonlarda Operasyona Başlanmamışları Bulunutor--->
                        SELECT 
                            P_OPERATION_ID 
                        FROM 
                            PRODUCTION_OPERATION 
                        WHERE 
                            OPERATION_TYPE_ID IN (#attributes.OPERATION_ID_LIST#) AND 
                            P_ORDER_ID = #p_order_id# AND 
                            P_OPERATION_ID NOT IN 
                                                (
                                                    SELECT        
                                                        POR.P_OPERATION_ID
                                                    FROM            
                                                        PRODUCTION_OPERATION AS POR INNER JOIN
                                                        PRODUCTION_OPERATION_RESULT AS PORR ON POR.P_OPERATION_ID = PORR.OPERATION_ID
                                                    WHERE        
                                                        POR.P_ORDER_ID = #p_order_id# AND 
                                                        POR.OPERATION_TYPE_ID IN (#attributes.OPERATION_ID_LIST#)
                                                )
                    </cfquery>
               	</cfif>
                <cfif (isdefined('control_operation.recordcount') and control_operation.recordcount) or attributes.ekle_radio eq 0> <!---Silinecek Operasyon Bulunduysa veya Seçim Ekle ise--->
                	<cfquery name="get_operation_rate" datasource="#dsn3#">
                   		SELECT QUANTITY AS ORAN	FROM PRODUCTION_ORDERS WHERE P_ORDER_ID = #p_order_id#
                  	</cfquery>
                    
                	<cfif attributes.ekle_radio eq 2> <!---Seçim Değiştir İse--->
						<cfset p_operation_id_list = ValueList(control_operation.P_OPERATION_ID )>
                        <cfquery name="add_history" datasource="#dsn3#">
                        	INSERT INTO 
                            	PRODUCTION_OPERATION_HISTORY
                  				(
                                	P_OPERATION_ID, 
                                    P_ORDER_ID, 
                                    AMOUNT, 
                                    STATION_ID, 
                                    OPERATION_TYPE_ID, 
                                    STAGE, 
                                    O_MINUTE, 
                                    RECORD_EMP, 
                                    RECORD_DATE, 
                                    RECORD_IP, 
                                    UPDATE_EMP, 
                                    UPDATE_DATE, 
                                    UPDATE_IP, 
                                    RELATED_OP_ID, 
                                    O_START_DATE, 
                  					O_STATION_IP, 
                                    O_TOTAL_PROCESS_TIME, 
                                    O_FINISH_DATE, 
                                    O_EXTRA_PROCESS_TIME, 
                                    O_SETUP_TIME, 
                                    O_CURRENT_NUMBER, 
                                    HISTORY_EMP, 
                                    HISTORY_DATE, 
                                    HISTORY_IP
                             	)
							SELECT  
                            	P_OPERATION_ID, 
                                P_ORDER_ID, 
                                AMOUNT, 
                                STATION_ID, 
                                OPERATION_TYPE_ID, 
                                STAGE, 
                                O_MINUTE, 
                                RECORD_EMP, 
                                RECORD_DATE, 
                                RECORD_IP, 
                                UPDATE_EMP, 
                                UPDATE_DATE, 
                                UPDATE_IP, 
                                RELATED_OP_ID, 
                                O_START_DATE, 
                  				O_STATION_IP, 
                                O_TOTAL_PROCESS_TIME, 
                                O_FINISH_DATE, 
                                O_EXTRA_PROCESS_TIME, 
                                O_SETUP_TIME, 
                                O_CURRENT_NUMBER,
                                #session.ep.userid#,
								#now()#,
								'#cgi.remote_addr#'
							FROM     
                            	PRODUCTION_OPERATION
                         	WHERE 
                            	OPERATION_TYPE_ID IN (#attributes.OPERATION_ID_LIST#) 
                                AND P_ORDER_ID = #p_order_id# 
                                AND P_OPERATION_ID IN (#p_operation_id_list#)
                        </cfquery>
                        <cfquery name="del_operastions" datasource="#dsn3#"><!---Bulunan Operasyonlar Siliniyor--->
                            DELETE FROM PRODUCTION_OPERATION WHERE OPERATION_TYPE_ID IN (#attributes.OPERATION_ID_LIST#) AND P_ORDER_ID = #p_order_id# AND P_OPERATION_ID IN (#p_operation_id_list#)
                        </cfquery>
                    </cfif>
                    <cfloop from="1" to="#attributes.record_num#" index="k"> <!--- Her Üretim Emri İçin Eklenmesi İstenilen Operasyonlar Ekleniyor.--->
                    	<cfif Evaluate('attributes.row_kontrol#k#') eq 1>
                            
                            <cfquery name="add_operations" datasource="#dsn3#">
                                INSERT INTO 
                                    PRODUCTION_OPERATION
                                    (
                                        P_ORDER_ID, 
                                        AMOUNT, 
                                        OPERATION_TYPE_ID, 
                                        STAGE, 
                                        RECORD_EMP, 
                                        RECORD_DATE,
                                        RECORD_IP
                                    )
                                VALUES        
                                    (
                                        #p_order_id#,
                                        <cfif get_operation_rate.recordcount>
                                        	#get_operation_rate.oran#,
                                        <cfelse>
                                        	#FilterNum(Evaluate('QUANTITY#k#'),2)#,
                                        </cfif>
                                        #Evaluate('OPERATION_TYPE_ID#k#')#,
                                        0,
                                        #session.ep.userid#,
										#now()#,
										'#cgi.remote_addr#'
                                    )
                            </cfquery>
                      	</cfif>
                        
                    </cfloop>
                </cfif>
          	</cfloop>
        <cfelse>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='36791.Lütfen operasyon kodu giriniz.'>");
                window.history.go(-1);
            </script>
            <cfabort>
        </cfif>
    <cfelseif attributes.ekle_radio eq 1> <!---Seçim Çıkar İse--->
    	<cfif ListLen(attributes.P_ORDER_ID_LIST)>
        	<cfloop list="#attributes.P_ORDER_ID_LIST#" index="p_order_id"> <!---Her Üretim Emri İçin Tektek Döndürüyoruz--->
          		<cfquery name="control_operation" datasource="#dsn3#"> <!---Seçilmiş Operasyonlarda Operasyona Başlanmamışları Bulunutor--->
                 	SELECT 
                    	P_OPERATION_ID 
                  	FROM 
                    	PRODUCTION_OPERATION 
                 	WHERE 
                   		OPERATION_TYPE_ID IN (#attributes.OPERATION_ID_LIST#) AND 
                     	P_ORDER_ID = #p_order_id# AND 
                      	P_OPERATION_ID NOT IN 
                                         	(
                                             	SELECT        
                                                	POR.P_OPERATION_ID
                                              	FROM            
                                                 	PRODUCTION_OPERATION AS POR INNER JOIN
                                                 	PRODUCTION_OPERATION_RESULT AS PORR ON POR.P_OPERATION_ID = PORR.OPERATION_ID
                                           		WHERE        
                                                	POR.P_ORDER_ID = #p_order_id# AND 
                                                  	POR.OPERATION_TYPE_ID IN (#attributes.OPERATION_ID_LIST#)
                                        	) AND
                    	P_ORDER_ID IN 
                        					(
                                            	SELECT     
                                                	P_ORDER_ID
												FROM            
                                                	PRODUCTION_ORDERS
												WHERE        
                                                	IS_STAGE IN (0, 4) AND
                                            		P_ORDER_ID = #p_order_id#
                                            )
              	</cfquery>
                <cfif control_operation.recordcount> <!---Silinecek Operasyon Bulunduysa --->
					<cfset p_operation_id_list = ValueList(control_operation.P_OPERATION_ID )>
                  	<cfquery name="add_history" datasource="#dsn3#">
                        	INSERT INTO 
                            	PRODUCTION_OPERATION_HISTORY
                  				(
                                	P_OPERATION_ID, 
                                    P_ORDER_ID, 
                                    AMOUNT, 
                                    STATION_ID, 
                                    OPERATION_TYPE_ID, 
                                    STAGE, 
                                    O_MINUTE, 
                                    RECORD_EMP, 
                                    RECORD_DATE, 
                                    RECORD_IP, 
                                    UPDATE_EMP, 
                                    UPDATE_DATE, 
                                    UPDATE_IP, 
                                    RELATED_OP_ID, 
                                    O_START_DATE, 
                  					O_STATION_IP, 
                                    O_TOTAL_PROCESS_TIME, 
                                    O_FINISH_DATE, 
                                    O_EXTRA_PROCESS_TIME, 
                                    O_SETUP_TIME, 
                                    O_CURRENT_NUMBER, 
                                    HISTORY_EMP, 
                                    HISTORY_DATE, 
                                    HISTORY_IP
                             	)
							SELECT  
                            	P_OPERATION_ID, 
                                P_ORDER_ID, 
                                AMOUNT, 
                                STATION_ID, 
                                OPERATION_TYPE_ID, 
                                STAGE, 
                                O_MINUTE, 
                                RECORD_EMP, 
                                RECORD_DATE, 
                                RECORD_IP, 
                                UPDATE_EMP, 
                                UPDATE_DATE, 
                                UPDATE_IP, 
                                RELATED_OP_ID, 
                                O_START_DATE, 
                  				O_STATION_IP, 
                                O_TOTAL_PROCESS_TIME, 
                                O_FINISH_DATE, 
                                O_EXTRA_PROCESS_TIME, 
                                O_SETUP_TIME, 
                                O_CURRENT_NUMBER,
                                #session.ep.userid#,
								#now()#,
								'#cgi.remote_addr#'
							FROM     
                            	PRODUCTION_OPERATION
                         	WHERE 
                            	OPERATION_TYPE_ID IN (#attributes.OPERATION_ID_LIST#) AND 
                                P_ORDER_ID = #p_order_id# AND 
                                P_OPERATION_ID IN (#p_operation_id_list#)
                   	</cfquery>
                 	<cfquery name="del_operastions" datasource="#dsn3#"><!---Bulunan Operasyonlar Siliniyor--->
                    	DELETE FROM PRODUCTION_OPERATION WHERE OPERATION_TYPE_ID IN (#attributes.OPERATION_ID_LIST#) AND P_ORDER_ID = #p_order_id# AND P_OPERATION_ID IN (#p_operation_id_list#)
                 	</cfquery>
             	</cfif>
        	</cfloop>
       	</cfif>
    </cfif>
</cftransaction>
<script type="text/javascript">
	alert("<cf_get_lang dictionary_id='47470.İşlem Tamamlandı'>!");
	window.location ="<cfoutput>#request.self#?fuseaction=prod.popup_dsp_ezgi_iflow_product_operation_revision&p_order_id_list=#attributes.P_ORDER_ID_LIST#</cfoutput>"
</script>