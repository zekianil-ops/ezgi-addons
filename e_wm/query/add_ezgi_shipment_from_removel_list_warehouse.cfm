<!---
    File: add_ezgi_shipment_from_removel_list_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\query
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Sevkiyat Listesinden Çıkarma 
--->
<cfif isdefined('attributes.removal_serial')> <!---Sevkten Çıkarma--->    
	<cftransaction>
    	<cfif isdefined('attributes.x_select_process_yontem') and attributes.x_select_process_yontem eq 2> <!---Bulunduğu Yerde Kalır--->
        	<!---*****SERİ NO DURUM DÜZELTME****--->
            <cfquery name="UPD_ROW" datasource="#dsn2#"> <!---Seri No Hareket Tablosundan Sevkiyata Transfer Kaıtlarını Shipping den Koparıyoruz--->
                UPDATE
              		#dsn3_alias#.EZGI_WM_SERIAL_NO_ACTION
               	SET 
                	IS_SHIPMENT_VERIFACTION = NULL,
                 	SHIP_RESULT_ID = NULL, 
                    SHIP_RESULT_TYPE = NULL
                WHERE
                    SERIAL_NO = '#attributes.serial_no#' AND
                    SHIP_RESULT_TYPE = #attributes.is_type# AND
                    SHIP_RESULT_ID = #attributes.ship_id#
            </cfquery>
            <cfquery name="GET_SERIAL_INFO" datasource="#dsn2#"><!---Seri No Bilgilierini Topluyorum--->
            	SELECT 
                	ISNULL(SPECT_ID,0) AS SPECT_ID, 
                	STOCK_ID
				FROM     
                	#dsn3_alias#.EZGI_WM_SERIAL_NO_LAST_STATUS
				WHERE  
                	SERIAL_NO = '#attributes.serial_no#'
            </cfquery>
            <cfquery name="GET_CONTROL_AMOUNT_INFO" datasource="#dsn2#"><!---Shipping Control Miktarını Alıyorum (Dikkat Bu değer altlara da etki ediyor)--->
            	SELECT 
                	ISNULL(CONTROL_AMOUNT,0) AS CONTROL_AMOUNT
				FROM     
                	#dsn3_alias#.EZGI_SHIPPING_PACKAGE_LIST
				WHERE  
                	SHIPPING_ID = #attributes.ship_id# AND 
                    STOCK_ID = #GET_SERIAL_INFO.STOCK_ID# AND 
                    <cfif GET_SERIAL_INFO.SPECT_ID gt 0>
                    	SPECT_MAIN_ID = #GET_SERIAL_INFO.SPECT_ID# AND
                    </cfif>
                    TYPE = #attributes.is_type#
           	</cfquery>
            
            <!---*****PAKET KONTROL DÜZELTME****--->
            <cfif GET_CONTROL_AMOUNT_INFO.recordcount and GET_CONTROL_AMOUNT_INFO.CONTROL_AMOUNT gt 1> <!---Eğer Miktar 1 den Büyükse --->
            	<cfquery name="UPD_CONTROL_AMOUNT_INFO" datasource="#dsn2#"> <!---Control ve Amount alanından 1 adet eksilt--->
            		UPDATE
                        #dsn3_alias#.EZGI_SHIPPING_PACKAGE_LIST
                    SET
                    	CONTROL_AMOUNT =  #GET_CONTROL_AMOUNT_INFO.CONTROL_AMOUNT#-1,
                        AMOUNT =  #GET_CONTROL_AMOUNT_INFO.CONTROL_AMOUNT#-1
                    WHERE  
                        SHIPPING_ID = #attributes.ship_id# AND 
                        STOCK_ID = #GET_SERIAL_INFO.STOCK_ID# AND 
                        <cfif GET_SERIAL_INFO.SPECT_ID gt 0>
                        	SPECT_MAIN_ID = #GET_SERIAL_INFO.SPECT_ID# AND
                        </cfif>
                        TYPE = #attributes.is_type#
            	</cfquery>
            <cfelse><!---Eğer Miktar 1 ise --->
            	<cfquery name="DEL_CONTROL_AMOUNT_INFO" datasource="#dsn2#"> <!---İlgili satırı sil--->
            		DELETE FROM
                        #dsn3_alias#.EZGI_SHIPPING_PACKAGE_LIST
                    WHERE  
                        SHIPPING_ID = #attributes.ship_id# AND 
                        STOCK_ID = #GET_SERIAL_INFO.STOCK_ID# AND 
                        <cfif GET_SERIAL_INFO.SPECT_ID gt 0>
                        	SPECT_MAIN_ID = #GET_SERIAL_INFO.SPECT_ID# AND
                        </cfif>
                        TYPE = #attributes.is_type#
            	</cfquery>
            </cfif>
           
            <!---Düzeltilen Paket Kontrola Göre Toplam Yap--->
            <cfquery name="GET_ALL_CONTROL_AMOUNT_INFO" datasource="#dsn2#"><!---Tüm Shipping Miktarını topla--->
            	SELECT 
                	ISNULL(SUM(CONTROL_AMOUNT),0) AS CONTROL_AMOUNT
				FROM     
                	#dsn3_alias#.EZGI_SHIPPING_PACKAGE_LIST
				WHERE  
                	SHIPPING_ID = #attributes.ship_id# AND
                    TYPE = #attributes.is_type#
           	</cfquery>
            
            <!---*****stok fişi AMBAR FİŞİ BULMA****--->
                
			<cfif attributes.is_type eq 1> <!---Sevk Planı İse--->
              	<cfquery name="get_stock_fis" datasource="#dsn2#"><!---Ambar Fişi Aranıyor--->
                        SELECT 
                            SF.FIS_ID 
                        FROM 
                            STOCK_FIS AS SF INNER JOIN
                            #dsn3_alias#.EZGI_SHIP_RESULT AS E ON SF.REF_NO = E.DELIVER_PAPER_NO
                        WHERE  
                            E.SHIP_RESULT_ID = #attributes.ship_id# AND
                            SF.FIS_TYPE = 113
             	</cfquery> 
         	<cfelse> <!---Sevk Talebi İse--->
              	<cfquery name="get_stock_fis" datasource="#dsn2#"><!---Ambar Fişi Aranıyor--->
                	SELECT 
                            SF.FIS_ID 
                        FROM 
                            STOCK_FIS AS SF INNER JOIN
                            #dsn3_alias#.EZGI_SHIP_RESULT_INTERNALDEMAND AS E ON SF.REF_NO = CAST(E.SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR)
                        WHERE  
                            E.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
                            SF.FIS_TYPE = 113
              	</cfquery>
         	</cfif>
            
            
            <cfif not GET_ALL_CONTROL_AMOUNT_INFO.recordcount or GET_ALL_CONTROL_AMOUNT_INFO.CONTROL_AMOUNT eq 0><!---Eğer Değer Gelmiyorsa Yani Sevkiyatın tamamı çıkartılmışsa--->
            
                <!---*****AMBAR FİŞİNİN REFARANSI SİLİNEREK SEVK PLANINDAN KOPARILIYOR****--->
            	<cfif get_stock_fis.recordcount and len(get_stock_fis.FIS_ID)> <!---Ambar Fişini Kopar--->
                    <cfquery name="upd_stock_fis" datasource="#dsn2#">
                        UPDATE
                            STOCK_FIS
                        SET
                            REF_NO = NULL
                        WHERE 
                            FIS_ID = #get_stock_fis.FIS_ID#
                    </cfquery>
                </cfif>
                
                <!---****SEVK PLANI VEYA SEVK TALEBİ MİKTAR İCMALLERİ SIFIRLANIYOR****--->
                <cfif attributes.is_type eq 1> <!---Sevk Planı İse--->
                    <cfquery name="upd_ship_result" datasource="#dsn2#"> <!---Sevk Planını Düzenle--->
                        UPDATE 
                            #dsn3_alias#.EZGI_SHIP_RESULT
                        SET          
                            SHIPMENT_PROCESS = 0,
                            SHIPMENT_PRODUCT_PLACE_ID = NULL,
                            SHIPMENT_PACKAGE_AMOUNT = 0
                        WHERE  
                            SHIP_RESULT_ID = #attributes.ship_id#
                    </cfquery>
                <cfelse> <!---Sevk Talebi İse--->
                	<cfquery name="upd_ship_result" datasource="#dsn2#"> <!---Sevk Talebini Düzenle--->
                    	UPDATE 
                            #dsn3_alias#.EZGI_SHIP_RESULT_INTERNALDEMAND
                        SET          
                            SHIPMENT_PROCESS = 0,
                            SHIPMENT_PRODUCT_PLACE_ID = NULL,
                            SHIPMENT_PACKAGE_AMOUNT = 0
                        WHERE  
                            SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
                    </cfquery>
                </cfif>
            <cfelse>  <!---Eğer Değer Geliyorsa--->  
                <!---YEDEKLEME STOK FİŞİ AÇILMIŞ MI--->
            	<cfquery name="get_yedek_stok_fis" datasource="#dsn2#">
                	SELECT 
                    	FIS_ID
					FROM     
                    	STOCK_FIS AS STOCK_FIS_1
					WHERE  
                    	REF_NO =
                      			(
                                	SELECT 
                                    	FIS_NUMBER
                       				FROM      
                                    	STOCK_FIS
                       				WHERE   
                                    	FIS_ID = #get_stock_fis.FIS_ID#
                               	)
                </cfquery>
                <!---YEDEKLEME STOK FİŞİ AÇILmamış ise açalım--->
				<cfif not get_yedek_stok_fis.recordcount>
                	<cfquery name="add_yedek_stok_fis" datasource="#dsn2#">
                    	INSERT INTO
                        	STOCK_FIS
                  			(
                            	FIS_TYPE, 
                                FIS_NUMBER, 
                                LOCATION_OUT, 
                                DEPARTMENT_OUT, 
                                LOCATION_IN, 
                                DEPARTMENT_IN, 
                                EMPLOYEE_ID, 
                                FIS_DATE, 
                                DELIVER_DATE, 
                                PROCESS_CAT, 
                                REF_NO, 
                                IS_PRODUCTION,
                                WORK_ID, 
                                RECORD_DATE, 
                                RECORD_EMP, 
                                RECORD_IP 
                        	)
						SELECT 
                        	FIS_TYPE, 
                            FIS_NUMBER, 
                            LOCATION_OUT, 
                            DEPARTMENT_OUT, 
                            LOCATION_IN, 
                            DEPARTMENT_IN, 
                            EMPLOYEE_ID, 
                            FIS_DATE, 
                            DELIVER_DATE, 
                            PROCESS_CAT, 
                            FIS_NUMBER, 
                            IS_PRODUCTION, 
                            WORK_ID,
							#now()#,
                            #session.ep.userid#,
                            '#cgi.remote_addr#'
						FROM     
                        	STOCK_FIS
						WHERE  
                        	FIS_ID = #get_stock_fis.FIS_ID#
                    </cfquery>
                    <!---Yeni Açılan Fişin ID sini alalım--->
                    <cfquery name="get_max_id" datasource="#dsn2#">
                    	SELECT MAX(FIS_ID) AS MAX_ID FROM STOCK_FIS
                    </cfquery>
                    <cfset new_fis = get_max_id.MAX_ID>
                    
                    <!---FİŞ Money Kayıtlarını atıyoruz--->
                    <cfquery name="add_yedek_stok_fis_money" datasource="#dsn2#">
                    	INSERT INTO 
                        	STOCK_FIS_MONEY
                  			(
                            	MONEY_TYPE, 
                                ACTION_ID, 
                                RATE2, 
                                RATE1, 
                                IS_SELECTED
                         	)
						SELECT 
                        	MONEY_TYPE, 
                            #new_fis#, 
                            RATE2, 
                            RATE1, 
                            IS_SELECTED
						FROM     
                        	STOCK_FIS_MONEY
						WHERE  
                        	ACTION_ID = #get_stock_fis.FIS_ID#
                    </cfquery>
                <cfelse> <!---Yedekleme Fişi Açılmış İse--->
                	<cfset new_fis = get_yedek_stok_fis.FIS_ID>	
                </cfif>
                
                <!---****AMBAR FİŞİ SATIRINI FİŞ DEĞİŞTİRİYORUM****--->
                <cfquery name="upd_old_fis_row" datasource="#dsn2#">
                	UPDATE 
                    	STOCK_FIS_ROW
					SET          
                    	FIS_ID = #new_fis#
					WHERE  
                    	FIS_ID = #get_stock_fis.FIS_ID# AND 
                        PRODUCT_NAME2 = '#attributes.serial_no#'
                </cfquery>
                <!---****STOCKS_ROW SATIRINI FİŞ DEĞİŞTİRİYORUM****--->
                
                <!---Önce değiştirilecek Satırları Buluyorum--->
                <cfquery name="get_old_stock_row_ids" datasource="#dsn2#">
                	SELECT TOP (1) 
                    	STOCKS_ROW_ID
					FROM     
                    	STOCKS_ROW
					WHERE  
                    	UPD_ID = #get_stock_fis.FIS_ID# AND 
                        STOCK_ID = #GET_SERIAL_INFO.STOCK_ID# AND 
                        <cfif GET_SERIAL_INFO.SPECT_ID gt 0>
                        	SPECT_VAR_ID = #GET_SERIAL_INFO.SPECT_ID# AND
                        </cfif> 
                        STOCK_IN = 0
					UNION ALL
					SELECT TOP (1) 
                    	STOCKS_ROW_ID
					FROM     
                    	STOCKS_ROW
					WHERE  
                    	UPD_ID = #get_stock_fis.FIS_ID# AND 
                        STOCK_ID = #GET_SERIAL_INFO.STOCK_ID# AND 
                        <cfif GET_SERIAL_INFO.SPECT_ID gt 0>
                        	SPECT_VAR_ID = #GET_SERIAL_INFO.SPECT_ID# AND
                        </cfif> 
                        STOCK_IN = 1
                </cfquery>
                <!---Bulduğum satırları Yeni fiş ile değiştiriyorum--->
                <cfif get_old_stock_row_ids.recordcount>
                	<cfset stocks_row_id_list = ValueList(get_old_stock_row_ids.STOCKS_ROW_ID)>
                    <cfquery name="upd_old_stock_row_ids" datasource="#dsn2#">
                        UPDATE 
                        	STOCKS_ROW
						SET          
                        	UPD_ID = #new_fis#
                        WHERE  
                            STOCKS_ROW_ID IN (#stocks_row_id_list#) AND 
                            UPD_ID = #get_stock_fis.FIS_ID#
                    </cfquery>
                </cfif>
                
                <!---****İÇİNDE SATIR KALMAMIŞ ESKİ STOK FİŞİ SİLİNİYOR ****--->
                <cfquery name="get_eski_fis" datasource="#dsn2#">
                	SELECT TOP (1) STOCK_FIS_ROW_ID FROM STOCK_FIS_ROW WHERE FIS_ID = #get_stock_fis.FIS_ID#
                </cfquery>
                
                <cfif not get_eski_fis.recordcount>
                	<cfquery name="del_stock_fis" datasource="#dsn2#">
                    	DELETE FROM STOCK_FIS WHERE FIS_ID = #get_stock_fis.FIS_ID#
                    </cfquery>
                    <cfquery name="del_stock_fis_money" datasource="#dsn2#">
                    	DELETE FROM STOCK_FIS_MONEY WHERE ACTION_ID = #get_stock_fis.FIS_ID#
                  	</cfquery>
                </cfif>
                
				<!---****SEVK PLANI VEYA SEVK TALEBİ MİKTAR İCMALLERİ YENİDEN HESAPLANIYOR****--->
                <cfif attributes.is_type eq 1> <!---Sevk Planı İse--->
                    <cfquery name="upd_ship_result" datasource="#dsn2#"> <!---Sevk Planını Düzenle--->
                        UPDATE 
                            #dsn3_alias#.EZGI_SHIP_RESULT
                        SET          
                            SHIPMENT_PACKAGE_AMOUNT = #GET_ALL_CONTROL_AMOUNT_INFO.CONTROL_AMOUNT#
                        WHERE  
                            SHIP_RESULT_ID = #attributes.ship_id#
                    </cfquery>
                <cfelse> <!---Sevk Talebi İse--->
                	<cfquery name="upd_ship_result" datasource="#dsn2#"> <!---Sevk Talebini Düzenle--->
                    	UPDATE 
                            #dsn3_alias#.EZGI_SHIP_RESULT_INTERNALDEMAND
                        SET          
                            SHIPMENT_PACKAGE_AMOUNT = #GET_ALL_CONTROL_AMOUNT_INFO.CONTROL_AMOUNT#
                        WHERE  
                            SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
                    </cfquery>
                </cfif>
            </cfif>
        <cfelse>
            <cfquery name="del_row" datasource="#dsn2#"> <!---Seri No Hareket Tablosundan Ambar Fişi Kayıtları Siliniyor--->
                DELETE FROM 
                    #dsn3_alias#.EZGI_WM_SERIAL_NO_ACTION 
                WHERE 
                    SHIP_RESULT_ID = #attributes.ship_id# AND 
                    ISNULL(IS_SHIPMENT_VERIFACTION, 0) = 0 AND 
                    SHIP_RESULT_TYPE = #attributes.is_type#
            </cfquery>
            <cfquery name="del_row" datasource="#dsn2#"> <!---Seri No Hareket Tablosundan Sevkiyata Transfer Kayıdı Siliniyor--->
                DELETE FROM
                     #dsn3_alias#.EZGI_WM_SERIAL_NO_ACTION
                WHERE
                    SERIAL_NO = '#attributes.serial_no#' AND
                    SHIP_RESULT_TYPE = #attributes.is_type# AND
                    SHIP_RESULT_ID = #attributes.ship_id# AND
                    IS_SHIPMENT_VERIFACTION = 1
            </cfquery> 
            <cfif attributes.is_type eq 1> 
                <cfquery name="get_stock_fis" datasource="#dsn2#"><!---Ambar Fişi Aranıyor--->
                    SELECT 
                        SF.FIS_ID 
                    FROM 
                        STOCK_FIS AS SF INNER JOIN
                        #dsn3_alias#.EZGI_SHIP_RESULT AS E ON SF.REF_NO = E.DELIVER_PAPER_NO
                    WHERE  
                        E.SHIP_RESULT_ID = #attributes.ship_id# AND
                        SF.FIS_TYPE = 113
                </cfquery> 
                <cfquery name="upd_ship_result" datasource="#dsn2#"> <!---Shipment_process Düzenleniyor--->
                    UPDATE 
                        #dsn3_alias#.EZGI_SHIP_RESULT
                    SET          
                        SHIPMENT_PROCESS = 0
                    WHERE  
                        SHIP_RESULT_ID = #attributes.ship_id#
                </cfquery>
            <cfelse>
            	<cfquery name="get_stock_fis" datasource="#dsn2#"><!---Ambar Fişi Aranıyor--->
                    SELECT 
                        SF.FIS_ID 
                    FROM 
                        STOCK_FIS AS SF INNER JOIN
                        #dsn3_alias#.EZGI_SHIP_RESULT_INTERNALDEMAND AS E ON SF.REF_NO = CAST(E.SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR)
                    WHERE  
                        E.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
                        SF.FIS_TYPE = 113
                </cfquery> 
                <cfquery name="upd_ship_result" datasource="#dsn2#"> <!---Shipment_process Düzenleniyor--->
                    UPDATE 
                        #dsn3_alias#.EZGI_SHIP_RESULT_INTERNALDEMAND
                    SET          
                        SHIPMENT_PROCESS = 0
                    WHERE  
                        SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
                </cfquery>
            </cfif>
            <cfif get_stock_fis.recordcount> <!---Ambar Fişi Bulunduysa Kayıtlar Siliniyor--->
                <cfset fis_id_list = Valuelist(get_stock_fis.FIS_ID)>
                <cfquery name="del_stock_fis" datasource="#dsn2#">
                    DELETE FROM STOCK_FIS WHERE FIS_ID IN (#fis_id_list#)
                </cfquery>
                <cfquery name="del_stock_fis_row" datasource="#dsn2#">
                    DELETE FROM STOCK_FIS_ROW WHERE FIS_ID IN (#fis_id_list#)
                </cfquery>   
                <cfquery name="del_stock_row" datasource="#dsn2#">
                    DELETE FROM STOCKS_ROW WHERE UPD_ID IN (#fis_id_list#) AND PROCESS_TYPE = 113
                </cfquery>
                <cfquery name="del_ship_control" datasource="#dsn2#"> <!---Sevkiyat Kontrol Geri Alınıyor--->
                    DELETE FROM 
                        #dsn3_alias#.EZGI_SHIPPING_PACKAGE_LIST
                    WHERE  
                        SHIPPING_ID = #attributes.ship_id# AND 
                        TYPE = #attributes.is_type#
                </cfquery>
            </cfif>
        </cfif>
    </cftransaction>
<cfelseif isdefined('attributes.last_process')> <!---Fiş Kaydediliyor--->
    <cflocation url="#request.self#?fuseaction=stock.list_ezgi_shipment_from_removel_list_warehouse" addtoken="No">
</cfif>