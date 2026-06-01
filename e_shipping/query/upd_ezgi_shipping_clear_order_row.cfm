<!---
    File: upd_ezgi_shipping_clear_order_row.cfm
    Folder: Add_Ons\ezgi\e_shipping\query
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Sevkiyat Silme veya Bölme İşlemi - Lot No için Sipariş Satırlarını Düzenleme
--->
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

<!---Sipariş Üretim Bağlantıları Düzenleniyor--->
<cfif Evaluate('attributes.order_row_row_#i#') eq 1> <!---Tek Satırlık Bağlatı ise--->
    <cfquery name="add_production_order_row" datasource="#dsn3#"> <!---Üretim Planı Bağlı İse Yeni Oluşan Order_Row Satırını da Bağlama--->
        INSERT INTO
            PRODUCTION_ORDERS_ROW
            (
                PRODUCTION_ORDER_ID, 
                ORDER_ROW_ID, 
                ORDER_ID, 
                TYPE
            )
        SELECT        
            PRODUCTION_ORDER_ID, 
            #new_order_row_id#, 
            ORDER_ID, 
            TYPE
        FROM            
            PRODUCTION_ORDERS_ROW
        WHERE        
            ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')#
    </cfquery>
    <cfquery name="add_iflow_production_order_row" datasource="#dsn3#"> <!---Sipariş Toplu Üretime Sonradan Bağlandı İse Yeni Oluşan Order_Row Satırını da Bağlama--->
        INSERT INTO
            EZGI_IFLOW_PRODUCTION_ORDERS_ROW
            (
                PRODUCTION_ORDER_ID, 
                ORDER_ROW_ID, 
                ORDER_ID, 
                TYPE
            )
        SELECT        
            PRODUCTION_ORDER_ID, 
            #new_order_row_id#, 
            ORDER_ID, 
            TYPE
        FROM            
            EZGI_IFLOW_PRODUCTION_ORDERS_ROW
        WHERE        
            ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')#
    </cfquery> 
<cfelse> <!---Bir Satırdan Fazla Bağlantıysa--->
	<cfloop from="1" to="#Evaluate('attributes.order_row_row_#i#')#" index="z">
    	<cfif Evaluate('p_order_id_#i#_#z#') gt 0> <!---Üretim Planı Olan Satırlarda İse --->
        	<cfif isdefined('input_#i#_#z#')><!---İşaretlenmişse Bu sipariş satırı için ilişkilendirilen Tüm Üretim planını Yeni Oluşan Siparişe Bağla---> 
            	
                <!---<cfquery name="upd_production_order_row" datasource="#dsn3#">
                 	UPDATE
                    	PRODUCTION_ORDERS_ROW
                  	SET
                    	ORDER_ROW_ID = #new_order_row_id#
                  	WHERE
                    	ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')# AND
                    	PRODUCTION_ORDER_ID IN
                        					(
                                            	SELECT
                                                	P_ORDER_ID
                                               	FROM
                                                	PRODUCTION_ORDERS
                                              	WHERE
                                                	LOT_NO =
                                                    		(
                                                            
                                                            	SELECT
                                                                    LOT_NO
                                                                FROM
                                                                    PRODUCTION_ORDERS
                                                                WHERE
                                                                	P_ORDER_ID = #Evaluate('p_order_id_#i#_#z#')#
                                                            )
                        					)
                </cfquery>
                <cfquery name="upd_iflow_production_order_row" datasource="#dsn3#">
                 	UPDATE
                    	EZGI_IFLOW_PRODUCTION_ORDERS_ROW
                  	SET
                    	ORDER_ROW_ID = #new_order_row_id#
                  	WHERE
                    	ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')# AND
                    	PRODUCTION_ORDER_ID  = #Evaluate('p_order_id_#i#_#z#')#
                </cfquery>--->
                
                
            <cfelse><!---İşaretlenmemişse ---> 
            	<cfif Filternum(Evaluate('p_order_amount_#i#_#z#'),3) neq Filternum(Evaluate('rate_#i#_#z#'),3)> <!---Sevk Miktarı Üretim Miktarından Farklı ise--->
                
                    <!---<cfquery name="add_production_order_row" datasource="#dsn3#"> <!---Üretim Planı Bağlı İse Yeni Oluşan Order_Row Satırını da Bağlama--->
                        INSERT INTO
                            PRODUCTION_ORDERS_ROW
                            (
                                PRODUCTION_ORDER_ID, 
                                ORDER_ROW_ID, 
                                ORDER_ID, 
                                TYPE
                            )
                        SELECT        
                            PRODUCTION_ORDER_ID, 
                            #new_order_row_id#, 
                            ORDER_ID, 
                            TYPE
                        FROM            
                            PRODUCTION_ORDERS_ROW
                        WHERE        
                            ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')#
                    </cfquery>
                    <cfquery name="add_iflow_production_order_row" datasource="#dsn3#"> <!---Sipariş Toplu Üretime Sonradan Bağlandı İse Yeni Oluşan Order_Row Satırını da Bağlama--->
                        INSERT INTO
                            EZGI_IFLOW_PRODUCTION_ORDERS_ROW
                            (
                                PRODUCTION_ORDER_ID, 
                                ORDER_ROW_ID, 
                                ORDER_ID, 
                                TYPE
                            )
                        SELECT        
                            PRODUCTION_ORDER_ID, 
                            #new_order_row_id#, 
                            ORDER_ID, 
                            TYPE
                        FROM            
                            EZGI_IFLOW_PRODUCTION_ORDERS_ROW
                        WHERE        
                            ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')#
                    </cfquery>--->
                    
              	<cfelse>
                
                	<cfquery name="upd_production_order_row" datasource="#dsn3#">
                 	UPDATE
                    	PRODUCTION_ORDERS_ROW
                  	SET
                    	ORDER_ROW_ID = #new_order_row_id#
                  	WHERE
                    	ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')# AND
                    	PRODUCTION_ORDER_ID IN
                        					(
                                            	SELECT
                                                	P_ORDER_ID
                                               	FROM
                                                	PRODUCTION_ORDERS
                                              	WHERE
                                                	LOT_NO =
                                                    		(
                                                            
                                                            	SELECT
                                                                    LOT_NO
                                                                FROM
                                                                    PRODUCTION_ORDERS
                                                                WHERE
                                                                	P_ORDER_ID = #Evaluate('p_order_id_#i#_#z#')#
                                                            )
                        					)
                </cfquery>
                <cfquery name="upd_iflow_production_order_row" datasource="#dsn3#">
                 	UPDATE
                    	EZGI_IFLOW_PRODUCTION_ORDERS_ROW
                  	SET
                    	ORDER_ROW_ID = #new_order_row_id#
                  	WHERE
                    	ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')# AND
                    	PRODUCTION_ORDER_ID  = #Evaluate('p_order_id_#i#_#z#')#
                </cfquery>
                
                </cfif>
            </cfif>
        <CFELSE> <!---Üretim Planına Bağlı Olmayan Satırlar İçin Birşey Yapılmıyor.--->
        
        </cfif>
        
    </cfloop>
</cfif> 

<cfquery name="GET_PAKET_SAYISI" datasource="#DSN3#">
	SELECT
    	ISNULL(SUM(PAKET_SAYISI),0) AS PAKET_SAYISI
   	FROM
    	(
        	SELECT 
            	ISNULL(SUM(EPS.PAKET_SAYISI),0) AS PAKET_SAYISI
			FROM     
            	STOCKS AS S INNER JOIN
                ORDER_ROW AS ORR ON S.STOCK_ID = ORR.STOCK_ID INNER JOIN
                EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID
			WHERE  
            	ORR.ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')# AND 
                ISNULL(S.IS_PROTOTYPE, 0) = 0
			UNION ALL
			SELECT 
            	ISNULL(SUM(EPS.PAKET_SAYISI),0) AS PAKET_SAYISI
			FROM     
            	STOCKS AS S INNER JOIN
                ORDER_ROW AS ORR ON S.STOCK_ID = ORR.STOCK_ID INNER JOIN
                SPECTS AS SP ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
                EZGI_PAKET_SAYISI AS EPS ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID
			WHERE  
            	ORR.ORDER_ROW_ID = #Evaluate('attributes.order_row_id_#i#')# AND 
                ISNULL(S.IS_PROTOTYPE, 0) = 1
    	) AS TBL
</cfquery>
<cfif GET_PAKET_SAYISI.recordcount and GET_PAKET_SAYISI.PAKET_SAYISI gt 0><!--- Paket Satısı Bulunduysa--->
			<cfif attributes.is_type eq 1><!--- Sevkiyata Plan ve Taleplerinden Paket Eksiltme İşlemi--->
                <cfquery name="upd_ship_result" datasource="#dsn3#">
                    UPDATE 
                        EZGI_SHIP_RESULT
                    SET          
                        SHIPMENT_PACKAGE_AMOUNT = ISNULL(SHIPMENT_PACKAGE_AMOUNT,0)-#new_amount*GET_PAKET_SAYISI.PAKET_SAYISI#
                    WHERE  
                        SHIP_RESULT_ID = #attributes.ship_id#
                </cfquery>
            <cfelse>
                <cfquery name="upd_ship_internal" datasource="#dsn3#">
                    UPDATE 
                        EZGI_SHIP_RESULT_INTERNALDEMAND
                    SET          
                        SHIPMENT_PACKAGE_AMOUNT = ISNULL(SHIPMENT_PACKAGE_AMOUNT,0)-#new_amount*GET_PAKET_SAYISI.PAKET_SAYISI#
                    WHERE  
                        SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
                </cfquery>
            </cfif>
</cfif>     		