<!---
    File: upd_ezgi_shipping_clear_order_row_seri_no.cfm
    Folder: Add_Ons\ezgi\e_shipping\query
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Sevkiyat Silme veya Bölme İşlemi - Seri No için Sipariş Satırlarını Düzenleme
--->
<cfif Evaluate('attributes.order_row_row_#i#') eq 1> <!---Tek Satırlık Bağlatı ise--->
	<cfif isdefined('input_#i#_1')> <!---İşaretli İse--->
    	<cfif attributes.is_type eq 1><!--- Sevkiyata Plan ve Taleplerinden Paket Eksiltme İşlemi--->
         	<cfquery name="upd_ship_result" datasource="#dsn3#">
             	UPDATE 
                 	EZGI_SHIP_RESULT
				SET          
               		SHIPMENT_PACKAGE_AMOUNT = SHIPMENT_PACKAGE_AMOUNT - #filternum(Evaluate('attributes.QUANTITY_#i#'),3)#
				WHERE  
                	SHIP_RESULT_ID = #attributes.ship_id#
         	</cfquery>
            <cfquery name="del_ship_result_row" datasource="#dsn3#">
            	DELETE FROM 
                	EZGI_SHIP_RESULT_ROW
				WHERE  
                	ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')#
            </cfquery>
      	<cfelse>
        	<cfquery name="upd_ship_result" datasource="#dsn3#">
             	UPDATE 
                 	EZGI_SHIP_RESULT_INTERNALDEMAND
				SET          
               		SHIPMENT_PACKAGE_AMOUNT = SHIPMENT_PACKAGE_AMOUNT - #filternum(Evaluate('attributes.QUANTITY_#i#'),3)#
				WHERE  
                	SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
         	</cfquery>
            <cfquery name="del_ship_result_row" datasource="#dsn3#">
            	DELETE FROM 
                	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW
				WHERE  
                	ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')#
            </cfquery>
   		</cfif>
  	</cfif>
<cfelse> <!---Bir Satırdan Fazla Bağlantıysa--->
	<cfif new_rate neq 1> <!---Eğer Tüm Seri Nolar Tıklanıp Çıkar Denmişse Yeni Bir Sipariş Satırı Açılmasına Gerek Yoktur--->
    	
        <!---Sipariş Satırlaraı Düzenleniyor--->
        <cfquery name="add_order_history" datasource="#dsn3#"> <!---History Dosyasına Ekle--->
            INSERT INTO  
                ORDER_ROW_HISTORY
                (			
                    ORDER_ID,
                    ORDER_ROW_ID,
                    STOCK_ID,
                    PRODUCT_ID,
                    PAYMETHOD_ID,
                    PRODUCT_NAME,
                    DESCRIPTION,
                    DUEDATE,
                    QUANTITY,
                    PRICE,
                    PRICE_OTHER,UNIT,
                    UNIT_ID,
                    TAX,
                    NETTOTAL,
                    PAY_METHOD,
                    ORDER_ROW_CURRENCY,
                    DELIVER_DATE,
                    DELIVER_DEPT,
                    DELIVER_LOCATION,
                    DISCOUNT_1,
                    DISCOUNT_2,
                    DISCOUNT_3,
                    DISCOUNT_4,
                    DISCOUNT_5,
                    DISCOUNT_6,
                    DISCOUNT_7,
                    DISCOUNT_8,
                    DISCOUNT_9,
                    DISCOUNT_10,
                    SPECT_VAR_ID,
                    SPECT_VAR_NAME,
                    OTHER_MONEY,
                    OTHER_MONEY_VALUE,
                    LOT_NO,COST_ID,
                    COST_PRICE,EXTRA_COST,
                    MARJ,PROM_COMISSION,
                    PROM_COST,
                    DISCOUNT_COST,
                    IS_PROMOTION,
                    PROM_ID,
                    PROM_STOCK_ID,
                    IS_COMMISSION,
                    UNIQUE_RELATION_ID,
                    PRODUCT_NAME2,
                    EXTRA_PRICE_OTHER_TOTAL,
                    UNIT2,
                    EXTRA_PRICE,
                    SHELF_NUMBER,
                    PRODUCT_MANUFACT_CODE,
                    ROW_DISCOUNTTOTAL,
                    EXTRA_PRICE_TOTAL,
                    OTV_ORAN,
                    OTVTOTAL,
                    BASKET_EXTRA_INFO_ID,
                    PROM_RELATION_ID,
                    RESERVE_TYPE,
                    RESERVE_DATE,
                    PRICE_CAT,
                    CATALOG_ID,
                    LIST_PRICE,
                    NUMBER_OF_INSTALLMENT,
                    BASKET_EMPLOYEE_ID,
                    KARMA_PRODUCT_ID,
                    AMOUNT2,
                    EK_TUTAR_PRICE,
                    ROW_INTERNALDEMAND_ID,
                    RELATED_INTERNALDEMAND_ROW_ID,
                    ROW_PRO_MATERIAL_ID,
                    IS_GENERAL_PROM,
                    IS_PRODUCT_PROMOTION_NONEFFECT,
                    WRK_ROW_ID,
                    WRK_ROW_RELATION_ID,
                    RELATED_ACTION_ID,
                    RELATED_ACTION_TABLE,
                    DEPTH_VALUE,
                    WIDTH_VALUE,
                    HEIGHT_VALUE,
                    ROW_PROJECT_ID,
                    CANCEL_TYPE_ID,
                    CANCEL_AMOUNT,
                    DELIVER_AMOUNT,
                    ROW_WORK_ID,
                    SELECT_INFO_EXTRA,
                    DETAIL_INFO_EXTRA
                )
            SELECT					
                ORDER_ID,
                ORDER_ROW_ID,
                STOCK_ID,
                PRODUCT_ID,
                PAYMETHOD_ID,
                PRODUCT_NAME,
                DESCRIPTION,
                DUEDATE,
                QUANTITY,
                PRICE,
                PRICE_OTHER,
                UNIT,
                UNIT_ID,
                TAX,
                NETTOTAL,
                PAY_METHOD,
                ORDER_ROW_CURRENCY,
                DELIVER_DATE,
                DELIVER_DEPT,
                DELIVER_LOCATION,
                DISCOUNT_1,
                DISCOUNT_2,
                DISCOUNT_3,
                DISCOUNT_4,
                DISCOUNT_5,
                DISCOUNT_6,
                DISCOUNT_7,
                DISCOUNT_8,
                DISCOUNT_9,
                DISCOUNT_10,
                SPECT_VAR_ID,
                SPECT_VAR_NAME,
                OTHER_MONEY,
                OTHER_MONEY_VALUE,
                LOT_NO,
                COST_ID,
                COST_PRICE,
                EXTRA_COST,
                MARJ,
                PROM_COMISSION,
                PROM_COST,
                DISCOUNT_COST,
                IS_PROMOTION,
                PROM_ID,
                PROM_STOCK_ID,
                IS_COMMISSION,
                UNIQUE_RELATION_ID,
                PRODUCT_NAME2,
                EXTRA_PRICE_OTHER_TOTAL,
                UNIT2,
                EXTRA_PRICE,
                SHELF_NUMBER,
                PRODUCT_MANUFACT_CODE,
                ROW_DISCOUNTTOTAL,
                EXTRA_PRICE_TOTAL,
                OTV_ORAN,
                OTVTOTAL,
                BASKET_EXTRA_INFO_ID,
                PROM_RELATION_ID,
                RESERVE_TYPE,
                RESERVE_DATE,
                PRICE_CAT,
                CATALOG_ID,
                LIST_PRICE,
                NUMBER_OF_INSTALLMENT,
                BASKET_EMPLOYEE_ID,
                KARMA_PRODUCT_ID,
                AMOUNT2,
                EK_TUTAR_PRICE,
                ROW_INTERNALDEMAND_ID,
                RELATED_INTERNALDEMAND_ROW_ID,
                ROW_PRO_MATERIAL_ID,
                IS_GENERAL_PROM,
                IS_PRODUCT_PROMOTION_NONEFFECT,
                WRK_ROW_ID,
                WRK_ROW_RELATION_ID,
                RELATED_ACTION_ID,
                RELATED_ACTION_TABLE,
                DEPTH_VALUE,
                WIDTH_VALUE,
                HEIGHT_VALUE,
                ROW_PROJECT_ID,
                CANCEL_TYPE_ID,
                CANCEL_AMOUNT,
                DELIVER_AMOUNT,
                ROW_WORK_ID,
                SELECT_INFO_EXTRA,
                DETAIL_INFO_EXTRA
            FROM   
                ORDER_ROW 
            WHERE 
                ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')#
            SELECT SCOPE_IDENTITY() AS MAX_ID
        </cfquery>
        <cfscript>
            temp_wrk_row_id ="WRK#round(rand()*65)##dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmssL')##session.ep.userid##round(rand()*100)#";
        </cfscript>
        <cfquery name="add_order_row" datasource="#dsn3#"> <!---İlave Satır Ekle--->
            INSERT INTO  
                ORDER_ROW
                (			
                    ORDER_ID,
                    STOCK_ID,
                    PRODUCT_ID,
                    PAYMETHOD_ID,
                    PRODUCT_NAME,
                    DESCRIPTION,
                    DUEDATE,
                    QUANTITY,
                    PRICE,
                    PRICE_OTHER,UNIT,
                    UNIT_ID,
                    TAX,
                    NETTOTAL,
                    PAY_METHOD,
                    ORDER_ROW_CURRENCY,
                    DELIVER_DATE,
                    DELIVER_DEPT,
                    DELIVER_LOCATION,
                    DISCOUNT_1,
                    DISCOUNT_2,
                    DISCOUNT_3,
                    DISCOUNT_4,
                    DISCOUNT_5,
                    DISCOUNT_6,
                    DISCOUNT_7,
                    DISCOUNT_8,
                    DISCOUNT_9,
                    DISCOUNT_10,
                    SPECT_VAR_ID,
                    SPECT_VAR_NAME,
                    OTHER_MONEY,
                    OTHER_MONEY_VALUE,
                    LOT_NO,COST_ID,
                    COST_PRICE,EXTRA_COST,
                    MARJ,PROM_COMISSION,
                    PROM_COST,
                    DISCOUNT_COST,
                    IS_PROMOTION,
                    PROM_ID,
                    PROM_STOCK_ID,
                    IS_COMMISSION,
                    UNIQUE_RELATION_ID,
                    PRODUCT_NAME2,
                    EXTRA_PRICE_OTHER_TOTAL,
                    UNIT2,
                    EXTRA_PRICE,
                    SHELF_NUMBER,
                    PRODUCT_MANUFACT_CODE,
                    ROW_DISCOUNTTOTAL,
                    EXTRA_PRICE_TOTAL,
                    OTV_ORAN,
                    OTVTOTAL,
                    BASKET_EXTRA_INFO_ID,
                    PROM_RELATION_ID,
                    RESERVE_TYPE,
                    RESERVE_DATE,
                    PRICE_CAT,
                    CATALOG_ID,
                    LIST_PRICE,
                    NUMBER_OF_INSTALLMENT,
                    BASKET_EMPLOYEE_ID,
                    KARMA_PRODUCT_ID,
                    AMOUNT2,
                    EK_TUTAR_PRICE,
                    ROW_INTERNALDEMAND_ID,
                    RELATED_INTERNALDEMAND_ROW_ID,
                    ROW_PRO_MATERIAL_ID,
                    IS_GENERAL_PROM,
                    IS_PRODUCT_PROMOTION_NONEFFECT,
                    WRK_ROW_ID,
                    WRK_ROW_RELATION_ID,
                    RELATED_ACTION_ID,
                    RELATED_ACTION_TABLE,
                    DEPTH_VALUE,
                    WIDTH_VALUE,
                    HEIGHT_VALUE,
                    ROW_PROJECT_ID,
                    CANCEL_TYPE_ID,
                    CANCEL_AMOUNT,
                    DELIVER_AMOUNT,
                    ROW_WORK_ID,
                    SELECT_INFO_EXTRA,
                    DETAIL_INFO_EXTRA
                )
            SELECT					
                ORDER_ID,
                STOCK_ID,
                PRODUCT_ID,
                PAYMETHOD_ID,
                PRODUCT_NAME,
                DESCRIPTION,
                DUEDATE,
                #new_amount#,
                PRICE,
                PRICE_OTHER,
                UNIT,
                UNIT_ID,
                TAX,
                Round(NETTOTAL*#new_rate#,8),
                PAY_METHOD,
                ORDER_ROW_CURRENCY,
                DELIVER_DATE,
                DELIVER_DEPT,
                DELIVER_LOCATION,
                DISCOUNT_1,
                DISCOUNT_2,
                DISCOUNT_3,
                DISCOUNT_4,
                DISCOUNT_5,
                DISCOUNT_6,
                DISCOUNT_7,
                DISCOUNT_8,
                DISCOUNT_9,
                DISCOUNT_10,
                SPECT_VAR_ID,
                SPECT_VAR_NAME,
                OTHER_MONEY,
                Round(OTHER_MONEY_VALUE*#new_rate#,8),
                LOT_NO,
                COST_ID,
                COST_PRICE,
                EXTRA_COST,
                MARJ,
                PROM_COMISSION,
                PROM_COST,
                DISCOUNT_COST,
                IS_PROMOTION,
                PROM_ID,
                PROM_STOCK_ID,
                IS_COMMISSION,
                UNIQUE_RELATION_ID,
                PRODUCT_NAME2,
                EXTRA_PRICE_OTHER_TOTAL,
                UNIT2,
                EXTRA_PRICE,
                SHELF_NUMBER,
                PRODUCT_MANUFACT_CODE,
                ROW_DISCOUNTTOTAL,
                EXTRA_PRICE_TOTAL,
                OTV_ORAN,
                OTVTOTAL,
                BASKET_EXTRA_INFO_ID,
                PROM_RELATION_ID,
                RESERVE_TYPE,
                RESERVE_DATE,
                PRICE_CAT,
                CATALOG_ID,
                LIST_PRICE,
                NUMBER_OF_INSTALLMENT,
                BASKET_EMPLOYEE_ID,
                KARMA_PRODUCT_ID,
                AMOUNT2,
                EK_TUTAR_PRICE,
                ROW_INTERNALDEMAND_ID,
                RELATED_INTERNALDEMAND_ROW_ID,
                ROW_PRO_MATERIAL_ID,
                IS_GENERAL_PROM,
                IS_PRODUCT_PROMOTION_NONEFFECT,
                '#temp_wrk_row_id#',
                WRK_ROW_RELATION_ID,
                RELATED_ACTION_ID,
                RELATED_ACTION_TABLE,
                DEPTH_VALUE,
                WIDTH_VALUE,
                HEIGHT_VALUE,
                ROW_PROJECT_ID,
                NULL,
                0,
                0,
                ROW_WORK_ID,
                SELECT_INFO_EXTRA,
                DETAIL_INFO_EXTRA
            FROM   
                ORDER_ROW 
            WHERE 
                ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')#
            SELECT SCOPE_IDENTITY() AS MAX_ID
        </cfquery>
        <cfset new_order_row_id = add_order_row.MAX_ID>
        <cfquery name="upd_order_row" datasource="#dsn3#"> <!---Eski Order_Row Satırı Güncelle--->
            UPDATE
                ORDER_ROW
            SET
                QUANTITY=#old_amount#,
                NETTOTAL= Round(NETTOTAL*#old_rate#,8),
                OTHER_MONEY_VALUE = Round(OTHER_MONEY_VALUE*#old_rate#,8)
            WHERE
                ORDER_ROW_ID= #Evaluate('attributes.order_row_id_#i#')#
        </cfquery>
        <cfquery name="upd_order_row_reserved" datasource="#dsn3#"> <!---Eski Order_Reserve Satırı Düzelt--->
            UPDATE      
                ORDER_ROW_RESERVED
            SET                
                RESERVE_STOCK_OUT = #old_amount#
            WHERE        
                ORDER_WRK_ROW_ID =
                                (
                                    SELECT        
                                        WRK_ROW_ID
                                    FROM            
                                        ORDER_ROW
                                    WHERE      
                                        ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')#
                                )
        </cfquery>
        <cfquery name="add_order_row_reserved" datasource="#dsn3#"> <!---Yeni Reserve satırı Ekle--->
            INSERT INTO
                ORDER_ROW_RESERVED
                (
                    STOCK_ID,
                    PRODUCT_ID,
                    SPECT_VAR_ID,
                    DEPARTMENT_ID,
                    LOCATION_ID,
                    ORDER_ID,
                    ORDER_WRK_ROW_ID,
                    RESERVE_STOCK_OUT,
                    SHELF_NUMBER		
                )
            SELECT
                STOCK_ID,
                PRODUCT_ID,
                SPECT_VAR_ID,
                DEPARTMENT_ID,
                LOCATION_ID,
                ORDER_ID,
                '#temp_wrk_row_id#',
                #new_amount#,
                SHELF_NUMBER
            FROM
                ORDER_ROW_RESERVED AS ORDER_ROW_RESERVED_1
            WHERE        
                ORDER_WRK_ROW_ID =
                                    (
                                        SELECT        
                                            WRK_ROW_ID
                                        FROM            
                                            ORDER_ROW
                                        WHERE      
                                            ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')#
                                    )	
        </cfquery>
        <!---Sipariş Satırlaraı Düzenleniyor--->
	</cfif>
    
    
	<!---Sipariş Üretim Bağlantıları Düzenleniyor--->
 	<cfloop from="1" to="#Evaluate('attributes.order_row_row_#i#')#" index="z">
    	<cfif isdefined('attributes.SERINO_#i#_#z#') and len(Evaluate('attributes.SERINO_#i#_#z#'))> <!---Satırda Seri no Tanımlı ise--->
            <cfif isdefined('input_#i#_#z#')> <!---İşaretli İse--->
            
            	<!---Plan veya Talep için Toplam Miktar Düzenlemesi--->
                <cfif attributes.is_type eq 1><!--- Sevkiyata Plan ve Taleplerinden Paket Eksiltme İşlemi--->
                    <cfquery name="upd_ship_result" datasource="#dsn3#">
                        UPDATE 
                            EZGI_SHIP_RESULT
                        SET          
                            SHIPMENT_PACKAGE_AMOUNT = SHIPMENT_PACKAGE_AMOUNT-1
                        WHERE  
                            SHIP_RESULT_ID = #attributes.ship_id#
                    </cfquery>
                <cfelse>
                    <cfquery name="upd_ship_internal" datasource="#dsn3#">
                    	UPDATE 
                            EZGI_SHIP_RESULT_INTERNALDEMAND
                        SET          
                            SHIPMENT_PACKAGE_AMOUNT = SHIPMENT_PACKAGE_AMOUNT-1
                        WHERE  
                            SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
                    </cfquery>
                </cfif>
                <!---Plan veya Talep için Toplam Miktar Düzenlemesi--->
                
                
                	
				<!---Seri Noyu Yeni Sipariş Satırına Bağlama İşlemi--->	
             	<cfquery name="del_serial_action" datasource="#dsn3#"><!--- Varsa Sevkiyata Transfer İşlemini Geri al--->
                	DELETE FROM 
                     	EZGI_WM_SERIAL_NO_ACTION
                  	WHERE  
                      	SERIAL_NO = '#Evaluate('attributes.SERINO_#i#_#z#')#' AND 
                     	SHIP_RESULT_ID = #attributes.ship_id# AND 
                     	SHIP_RESULT_TYPE = #attributes.is_type#
             	</cfquery>
                
              	<cfif new_rate neq 1> <!---Eğer Tüm Seri Nolar Tıklanıp Çıkar Denmişse Başka Bir Sipariş Satırı Açılmadığından Yeni Satıra Bağlamaya Gerek Yoktur--->
                    <cfquery name="add_serial_order_action" datasource="#dsn3#"> <!---Sipariş Bağlantısı Tablosuna Yeni Siparişi ORDER_ROW_ID ekle--->
                        INSERT INTO	
                            EZGI_WM_SERIAL_NO_ORDER_ACTION
                            (
                                SERIAL_NO, 
                                ORDER_ROW_ID, 
                                RECORD_EMP, 
                                RECORD_IP, 
                                RECORD_DATE
                            )
                        VALUES 
                            (
                                '#Evaluate('attributes.SERINO_#i#_#z#')#',
                                #new_order_row_id#,
                                #session.ep.userid#,
                                '#cgi.remote_addr#',
                                #now()#
                            )
                    </cfquery> 
                    <cfquery name="get_serial_number_this_p_order_row" datasource="#dsn3#"><!--- Varsa Üretim-Sipariş Bağlantıları Kontrol Ediliyor --->
                        SELECT 
                            PRODUCTION_ORDER_ROW_ID, 
                            ORDER_ROW_ID, 
                            SERIAL_NO
                        FROM     
                            PRODUCTION_ORDERS_ROW
                        WHERE  
                            ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')#
                    </cfquery>
                    <cfif get_serial_number_this_p_order_row.recordcount>
                        <cfquery name="get_this_serial_number_this_p_order_row" dbtype="query"> <!---Siparişe Bağlı Üretim Varsa İçinde Seri No aranıyor--->
                            SELECT * FROM get_serial_number_this_p_order_row WHERE SERIAL_NO = '#Evaluate('attributes.SERINO_#i#_#z#')#'
                        </cfquery>
                        <cfif get_this_serial_number_this_p_order_row.recordcount><!---Bulunduysa Yeni ORDER_ROW_ID ye set ediliyor--->
                            <cfquery name="upd_row" datasource="#dsn3#">
                                UPDATE 
                                    PRODUCTION_ORDERS_ROW
                                SET          
                                    ORDER_ROW_ID = #new_order_row_id#
                                WHERE  
                                    PRODUCTION_ORDER_ROW_ID = #get_this_serial_number_this_p_order_row.PRODUCTION_ORDER_ROW_ID#
                            </cfquery>
                        </cfif>
                    </cfif>
                <cfelse> <!---Eğer Tüm Seri Nolar Tıklanıp Çıkar Denmişse Satır Sevk Planından Çıkartılacaktır--->
                	
                    <cfif attributes.is_type eq 1><!--- Sevkiyata Plan ve Taleplerinden Paket Eksiltme İşlemi--->
                        <cfquery name="upd_ship_result" datasource="#dsn3#">
                        	DELETE FROM 
                            	EZGI_SHIP_RESULT_ROW
							WHERE  
                            	SHIP_RESULT_ID = #attributes.ship_id# AND 
                                ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')#
                        </cfquery>
                    <cfelse>
                        <cfquery name="upd_ship_internal" datasource="#dsn3#">
                        	DELETE FROM 
                            	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW
							WHERE  
                            	SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND 
                                ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')#
                        </cfquery>
                    </cfif>
                	
                </cfif>
                <!---Seri Noyu Yeni Sipariş Satırına Bağlama İşlemi--->
                
            </cfif>
      	<cfelse><!---Satırda Seri no Tanımlı Değil ise--->
        	<cfif isdefined('input_#i#_#z#')> <!---İşaretli İse--->
            	<cfif attributes.is_type eq 1><!--- Sevkiyata Plan ve Taleplerinden Paket Eksiltme İşlemi--->
                    <cfquery name="upd_ship_result" datasource="#dsn3#">
                        UPDATE 
                            EZGI_SHIP_RESULT
                        SET          
                            SHIPMENT_PACKAGE_AMOUNT = SHIPMENT_PACKAGE_AMOUNT-#filternum(Evaluate('attributes.rate_#i#_#z#'),3)#
                        WHERE  
                            SHIP_RESULT_ID = #attributes.ship_id#
                    </cfquery>
                <cfelse>
                    <cfquery name="upd_ship_internal" datasource="#dsn3#">
                        UPDATE 
                            EZGI_SHIP_RESULT_INTERNALDEMAND
                        SET          
                            SHIPMENT_PACKAGE_AMOUNT = SHIPMENT_PACKAGE_AMOUNT-#filternum(Evaluate('attributes.rate_#i#_#z#'),3)#
                        WHERE  
                            SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
                    </cfquery>
                </cfif>
                <cfquery name="get_old_related" datasource="#dsn3#">
                	SELECT TOP (#filternum(Evaluate('attributes.rate_#i#_#z#'),3)#)
                    	PRODUCTION_ORDER_ROW_ID
                    FROM
                    	PRODUCTION_ORDERS_ROW
                 	WHERE  
                   		ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')# AND
                    	SERIAL_NO IS NULL
                 	ORDER BY
                    	PRODUCTION_ORDER_ROW_ID DESC
                </cfquery>
                
                <cfif get_old_related.recordcount eq filternum(Evaluate('attributes.rate_#i#_#z#'),3)>
                	<cfset id_list = ValueList(get_old_related.PRODUCTION_ORDER_ROW_ID)>
                 	<cfquery name="upd_row" datasource="#dsn3#">
                    	UPDATE 
                       		PRODUCTION_ORDERS_ROW
                    	SET          
                         	ORDER_ROW_ID = #new_order_row_id#
                      	WHERE  
                       		PRODUCTION_ORDER_ROW_ID IN (#id_list#)
                  	</cfquery>
                <cfelse>
                	<!---<cfdump var="#get_old_related#">
                	Sevkiyattan Çıkarmak İstediğiniz Miktar Kadar Planda Seri Numarasız Emir Kalmamış. Sistem Yöneticinize Başvurun
                    <cfabort>--->
                </cfif>
            </cfif>
        </cfif>	
    </cfloop>
</cfif>   		