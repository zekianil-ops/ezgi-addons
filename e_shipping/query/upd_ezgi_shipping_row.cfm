<!---
    File: upd_ezgi_shipping_row.cfm
    Folder: Add_Ons\ezgi\e-shipping\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfset shipping_id_list_ =''>
<cfset shipping_internaldemand_id_list_ =''>
<cfquery name="get_general_info" datasource="#dsn#">
	SELECT ISNULL(IS_SERIAL_CONTROL_LOCATION,0) AS IS_SERIAL_CONTROL_LOCATION FROM OUR_COMPANY_INFO WHERE COMP_ID = #session.ep.company_id#
</cfquery>
<cfloop list="#attributes.shipping_id_list#" index="ii">
	<cfif listgetat(ii,1,'-') eq 1 and listgetat(ii,3,'-') eq 1>
		<cfset shipping_id_list_ = ListAppend(shipping_id_list_, listgetat(ii,2,'-'))>
  	<cfelseif listgetat(ii,1,'-') eq 2 and listgetat(ii,3,'-') eq 1>
   		<cfset shipping_internaldemand_id_list_ = ListAppend(shipping_internaldemand_id_list_, listgetat(ii,2,'-'))>
    </cfif>
</cfloop>
<cfif len(shipping_id_list_)>
    <cfquery name="get_min_ship_result_id" datasource="#dsn3#">
        SELECT     
            ESR.COMPANY_ID, 
            ESR.CONSUMER_ID,
            ESR.SHIP_METHOD_TYPE, 
            ISNULL(O.CITY_ID,0) CITY_ID,
            ISNULL(O.COUNTY_ID,0) COUNTY_ID, 
            MIN(ESR.SHIP_RESULT_ID) AS REF_SHIP_RESULT_ID,
            MIN(ESR.DELIVER_PAPER_NO) AS REF_DELIVER_PAPER_NO
        FROM         
            EZGI_SHIP_RESULT AS ESR INNER JOIN
        	EZGI_SHIP_RESULT_ROW AS ESSR ON ESR.SHIP_RESULT_ID = ESSR.SHIP_RESULT_ID INNER JOIN
     		ORDERS AS O ON ESSR.ORDER_ID = O.ORDER_ID
        WHERE     
            ESR.SHIP_RESULT_ID IN (#shipping_id_list_#)
        GROUP BY 
            ESR.COMPANY_ID, 
            ESR.CONSUMER_ID,
            ESR.SHIP_METHOD_TYPE, 
            O.CITY_ID,
            O.COUNTY_ID
    </cfquery>
    <cftransaction>
        <cfloop query="get_min_ship_result_id">
        	<cfquery name="get_old_shipping_row" datasource="#dsn3#">
            	SELECT     
                	ESSR.SHIP_RESULT_ROW_ID,
                    ESSR.SHIP_RESULT_ID
              	FROM         
                 	EZGI_SHIP_RESULT AS ESR INNER JOIN
                   	EZGI_SHIP_RESULT_ROW AS ESSR ON ESR.SHIP_RESULT_ID = ESSR.SHIP_RESULT_ID INNER JOIN
                  	ORDERS AS O ON ESSR.ORDER_ID = O.ORDER_ID
             	WHERE     
                 	ESR.SHIP_RESULT_ID IN (#shipping_id_list_#) 
                    <cfif len(get_min_ship_result_id.COMPANY_ID)>
                  		AND ESR.COMPANY_ID = #get_min_ship_result_id.COMPANY_ID#
                    <cfelseif len(get_min_ship_result_id.CONSUMER_ID)>
                  		AND ESR.CONSUMER_ID = #get_min_ship_result_id.CONSUMER_ID#
                  	</cfif>
                  	<cfif len(get_min_ship_result_id.SHIP_METHOD_TYPE)>
                   		AND ESR.SHIP_METHOD_TYPE = #get_min_ship_result_id.SHIP_METHOD_TYPE#
                 	</cfif>
                  	<cfif get_min_ship_result_id.CITY_ID gt 0>
                     	AND ISNULL(O.CITY_ID,0) = #get_min_ship_result_id.CITY_ID#
                  	</cfif>
					<cfif get_min_ship_result_id.COUNTY_ID gt 0>
                     	AND ISNULL(O.COUNTY_ID,0) = #get_min_ship_result_id.COUNTY_ID#
                	</cfif>	
                </cfquery>
            <cfset new_shipping_id_list =  ListDeleteDuplicates(ValueList(get_old_shipping_row.SHIP_RESULT_ROW_ID))>
            <cfset new_shipping_list =  ListDeleteDuplicates(ValueList(get_old_shipping_row.SHIP_RESULT_ID))>
            <cfdump var="#attributes#"><cfdump var="#get_min_ship_result_id#"><cfdump var="#get_old_shipping_row#"><cfdump var="#new_shipping_list#"><cfabort>
            
            <!---İlgili Sevk Planlarına Ait Kontroller Tek Plana Alınıyor--->
            <cfquery name="upd_package_control" datasource="#dsn3#">
            	UPDATE 
                	EZGI_SHIPPING_PACKAGE_LIST
				SET                
                	SHIPPING_ID = #REF_SHIP_RESULT_ID#
				WHERE        
                	SHIPPING_ID IN (#new_shipping_list#)
            </cfquery>
            <!---İlgili Sevk Planlarına Ait Ambar Fişleri Tek Plana Ayarlanıyor--->
            <cfquery name="upd_stock_fis" datasource="#dsn3#">
            	UPDATE       
                	#dsn2_alias#.STOCK_FIS
				SET                
                	REF_NO = '#REF_DELIVER_PAPER_NO#'
				FROM            
                	EZGI_SHIP_RESULT AS ESR INNER JOIN
                  	EZGI_SHIP_RESULT_ROW AS ESSR ON ESR.SHIP_RESULT_ID = ESSR.SHIP_RESULT_ID INNER JOIN
                  	#dsn2_alias#.STOCK_FIS ON ESR.DELIVER_PAPER_NO = #dsn2_alias#.STOCK_FIS.REF_NO
				WHERE        
                	ESSR.SHIP_RESULT_ROW_ID IN (#new_shipping_id_list#)
            </cfquery>
            <cfif get_general_info.IS_SERIAL_CONTROL_LOCATION>
            <!---sERİ nO aCTİON Table daki Kayıtlar Düzenleniyor--->
                <cfquery name="upd_serial_no" datasource="#dsn3#">
                    UPDATE 
                        EZGI_WM_SERIAL_NO_ACTION
                    SET          
                        SHIP_RESULT_ID = #REF_SHIP_RESULT_ID#
                    WHERE  
                        GUARANTY_ACTION_ID IN
                                            (
                                                SELECT 
                                                    ID
                                                FROM      
                                                    EZGI_WM_SERIAL_NO_LAST_STATUS
                                                WHERE   
                                                    SHIP_RESULT_TYPE = 1 AND 
                                                    SHIP_RESULT_ID IN (#new_shipping_list#)
                                            )
                </cfquery>
            </cfif>
            <!---Sevk Planlarındaki Toplam Paket Sayısı Olmayan sevk Planları Bulunuyor--->
            <cfquery name="get_shipping_null_amount" datasource="#dsn3#">
            	SELECT DISTINCT
                	SHIP_RESULT_ID
              	FROM 
                	EZGI_SHIP_RESULT 
              	WHERE 
                	SHIP_RESULT_ID IN (#new_shipping_list#) AND
                    SHIPMENT_PACKAGE_AMOUNT IS NULL
            </cfquery>
            <cfif get_shipping_null_amount.recordcount> <!---Eğer Sevk Planlarındaki Toplam Paket Sayısı Olmayan sevk Planları Varsa--->
            	<cfloop query="get_shipping_null_amount"> <!---Teker Teker Hesaplayıp Yerine yazıyoruz--->
                	<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
                        SELECT     
                            PAKET_SAYISI AS PAKETSAYISI, 
                            PAKET_ID AS STOCK_ID, 
                            BARCOD, 
                            STOCK_CODE, 
                            PRODUCT_NAME,
                            SPECT_MAIN_ID,
                            COLLECT_SORT,
                            SHELF_CODE
                        FROM         
                            (
                            SELECT
                                SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                                PAKET_ID, 
                                BARCOD, 
                                STOCK_CODE, 
                                PRODUCT_NAME, 
                                PRODUCT_TREE_AMOUNT, 
                                SHIP_RESULT_ID,
                                SPECT_MAIN_ID,
                                COLLECT_SORT,
                                SHELF_CODE
                            FROM
                                (     
                                SELECT 
                                    '' AS SERIAL_NO,
                                    '' AS SHELF_CODE,
                                    '' AS COLLECT_SORT,
                                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                                    EPS.PAKET_ID, 
                                    S.BARCOD, 
                                    S.STOCK_CODE, 
                                    S.PRODUCT_NAME, 
                                    S.PRODUCT_TREE_AMOUNT, 
                                    ESR.SHIP_RESULT_ID,
                                    ISNULL(SP.SPECT_MAIN_ID,0) AS SPECT_MAIN_ID
                                FROM          
                                    STOCKS AS S1 INNER JOIN
                                    EZGI_SHIP_RESULT AS ESR INNER JOIN
                                    EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
                                    SPECTS AS SP ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
                                    STOCKS AS S INNER JOIN
                                    EZGI_PAKET_SAYISI AS EPS ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID 
                                WHERE      
                                    ESR.SHIP_RESULT_ID = #get_shipping_null_amount.SHIP_RESULT_ID# AND
                                    ORR.ORDER_ROW_CURRENCY = -6 AND
                                    ISNULL(S1.IS_PROTOTYPE,0) = 1 
                                GROUP BY 
                                    EPS.PAKET_ID,
                                    EPS.MODUL_SPECT_ID, 
                                    S.BARCOD, 
                                    S.STOCK_CODE, 
                                    S.PRODUCT_NAME, 
                                    S.PRODUCT_TREE_AMOUNT, 
                                    ESR.SHIP_RESULT_ID,
                                    ORR.SPECT_VAR_ID,
                                    SP.SPECT_MAIN_ID
                                UNION ALL
                                SELECT 
                                    '' AS SERIAL_NO,
                                    '' AS SHELF_CODE,
                                    '' AS COLLECT_SORT,    
                                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                                    EPS.PAKET_ID, 
                                    S.BARCOD, 
                                    S.STOCK_CODE, 
                                    S.PRODUCT_NAME, 
                                    S.PRODUCT_TREE_AMOUNT, 
                                    ESR.SHIP_RESULT_ID,
                                    0 AS SPECT_MAIN_ID
                                FROM
                                    EZGI_SHIP_RESULT AS ESR INNER JOIN
                                    EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                    EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                                    STOCKS AS S ON S.STOCK_ID = EPS.PAKET_ID INNER JOIN
                                    STOCKS AS S1 ON S1.STOCK_ID = ORR.STOCK_ID
                                WHERE      
                                    ESR.SHIP_RESULT_ID = #get_shipping_null_amount.SHIP_RESULT_ID# AND
                                    ORR.ORDER_ROW_CURRENCY = -6 AND
                                    ISNULL(S1.IS_PROTOTYPE,0) = 0
                                GROUP BY
                                    EPS.PAKET_ID, 
                                    S.BARCOD, 
                                    S.STOCK_CODE, 
                                    S.PRODUCT_NAME, 
                                    S.PRODUCT_TREE_AMOUNT, 
                                    ESR.SHIP_RESULT_ID,
                                    ORR.SPECT_VAR_ID
                                ) AS TBL1
                            GROUP BY
                                PAKET_ID, 
                                BARCOD, 
                                STOCK_CODE, 
                                PRODUCT_NAME, 
                                PRODUCT_TREE_AMOUNT, 
                                SHIP_RESULT_ID,
                                SPECT_MAIN_ID,
                                COLLECT_SORT,
                                SHELF_CODE
                            ) AS TBL
                    </cfquery>
                	<cfif GET_SHIP_PACKAGE_LIST.recordcount>
                    	<cfquery name="get_total_package" dbtype="query">
                            SELECT sum(PAKETSAYISI) PAKETSAYISI FROM GET_SHIP_PACKAGE_LIST
                        </cfquery>
                    
                        <cfquery name="upd_shipping_amount" datasource="#dsn3#">
                            UPDATE 
                                EZGI_SHIP_RESULT
                            SET          
                                SHIPMENT_PACKAGE_AMOUNT = #get_total_package.PAKETSAYISI#
                            WHERE  
                                SHIP_RESULT_ID = #get_shipping_null_amount.SHIP_RESULT_ID#
                        </cfquery>
                    </cfif>
                </cfloop>
            </cfif>
            <!---Sevk Planlarındaki Toplam Paket Sayısı Tek Plana Toplanıyor--->
            <cfquery name="get_shipping_amount" datasource="#dsn3#">
            	SELECT 
                	SUM(ISNULL(SHIPMENT_PACKAGE_AMOUNT, 0)) AS AMOUNT 
              	FROM 
                	EZGI_SHIP_RESULT 
              	WHERE 
                	SHIP_RESULT_ID IN (#new_shipping_list#)
            </cfquery>
            <cfif len(get_shipping_amount.AMOUNT)>
                <cfquery name="upd_shipping_amount" datasource="#dsn3#">
                    UPDATE 
                        EZGI_SHIP_RESULT
                    SET          
                        SHIPMENT_PACKAGE_AMOUNT = #get_shipping_amount.AMOUNT#
                    WHERE  
                        SHIP_RESULT_ID = #REF_SHIP_RESULT_ID#
                </cfquery>
            </cfif>
            
            <cfquery name="upd_shipping_row" datasource="#dsn3#">
                UPDATE    
                    EZGI_SHIP_RESULT_ROW
                SET              
                    SHIP_RESULT_ID = #get_min_ship_result_id.REF_SHIP_RESULT_ID#
                WHERE     
                    SHIP_RESULT_ROW_ID IN (#new_shipping_id_list#)
            </cfquery>
            <!---İlgili Sevk Planlarına Siliniyor--->
            <cfquery name="del_shipping" datasource="#dsn3#">
            	DELETE FROM 
                	EZGI_SHIP_RESULT
				WHERE  
                	SHIP_RESULT_ID IN (#new_shipping_list#) AND 
                    SHIP_RESULT_ID <> #REF_SHIP_RESULT_ID#
            </cfquery>
        </cfloop>
    </cftransaction>
<cfelseif len(shipping_internaldemand_id_list_)>
	 <cfquery name="get_min_ship_result_id" datasource="#dsn3#">
        SELECT  
        	ESR.DEPARTMENT_IN_ID+'-'+ESR.LOCATION_IN_ID AS DEPO,   
            ESR.SHIP_METHOD_TYPE, 
            MIN(ESR.SHIP_RESULT_INTERNALDEMAND_ID) AS REF_SHIP_RESULT_INTERNALDEMAND_ID,
            MIN(ESR.SHIP_RESULT_INTERNALDEMAND_ID) AS REF_DELIVER_PAPER_NO
        FROM         
            EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
        	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESSR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESSR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
     		ORDERS AS O ON ESSR.ORDER_ID = O.ORDER_ID
        WHERE     
            ESR.SHIP_RESULT_INTERNALDEMAND_ID IN (#shipping_internaldemand_id_list_#)
        GROUP BY 
            ESR.DEPARTMENT_IN_ID,
            ESR.LOCATION_IN_ID,
            ESR.SHIP_METHOD_TYPE
    </cfquery>
    <cftransaction>
        <cfloop query="get_min_ship_result_id">
        	<cfquery name="get_old_shipping_row" datasource="#dsn3#">
            	SELECT     
                	ESSR.SHIP_RESULT_INTERNALDEMAND_ROW_ID,
                    ESSR.SHIP_RESULT_INTERNALDEMAND_ID
              	FROM         
                 	EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                   	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESSR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESSR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                  	ORDERS AS O ON ESSR.ORDER_ID = O.ORDER_ID
             	WHERE     
                 	ESR.SHIP_RESULT_INTERNALDEMAND_ID IN (#shipping_internaldemand_id_list_#) 
                  	<cfif len(get_min_ship_result_id.SHIP_METHOD_TYPE)>
                   		AND ESR.SHIP_METHOD_TYPE = #get_min_ship_result_id.SHIP_METHOD_TYPE#
                 	</cfif>
                  	<cfif len(get_min_ship_result_id.DEPO)>
                     	AND ESR.DEPARTMENT_IN_ID+'-'+ESR.LOCATION_IN_ID = '#get_min_ship_result_id.DEPO#'
                  	</cfif>
                </cfquery>
            <cfset new_shipping_internaldemand_id_list =  ListDeleteDuplicates(ValueList(get_old_shipping_row.SHIP_RESULT_INTERNALDEMAND_ROW_ID))>
            <cfset new_shipping_internaldemand_list =  ListDeleteDuplicates(ValueList(get_old_shipping_row.SHIP_RESULT_INTERNALDEMAND_ID))>
            <!---<cfdump var="#attributes#"><cfdump var="#get_min_ship_result_id#"><cfdump var="#get_old_shipping_row#"><cfdump var="#new_shipping_internaldemand_list#"><cfabort>--->
            
            <!---İlgili Sevk Planlarına Ait Kontroller Tek Plana Alınıyor--->
            <cfquery name="upd_package_control" datasource="#dsn3#">
            	UPDATE 
                	EZGI_SHIPPING_PACKAGE_LIST
				SET                
                	SHIPPING_ID = #REF_SHIP_RESULT_INTERNALDEMAND_ID#
				WHERE        
                	SHIPPING_ID IN (#new_shipping_internaldemand_list#)
            </cfquery>
            <!---İlgili Sevk Planlarına Ait Ambar Fişleri Tek Plana Ayarlanıyor--->
            <cfquery name="upd_stock_fis" datasource="#dsn3#">
            	UPDATE       
                	#dsn2_alias#.STOCK_FIS
				SET                
                	REF_NO = '#REF_DELIVER_PAPER_NO#'
				FROM            
                	EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                  	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESSR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESSR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                  	#dsn2_alias#.STOCK_FIS ON CAST(ESR.SHIP_RESULT_INTERNALDEMAND_ID AS varchar) = #dsn2_alias#.STOCK_FIS.REF_NO
				WHERE        
                	ESSR.SHIP_RESULT_INTERNALDEMAND_ROW_ID IN (#new_shipping_internaldemand_id_list#)
            </cfquery>
            <cfif get_general_info.IS_SERIAL_CONTROL_LOCATION>
            <!---sERİ nO aCTİON Table daki Kayıtlar Düzenleniyor--->
                <cfquery name="upd_serial_no" datasource="#dsn3#">
                    UPDATE 
                        EZGI_WM_SERIAL_NO_ACTION
                    SET          
                        SHIP_RESULT_ID = #REF_SHIP_RESULT_INTERNALDEMAND_ID#
                    WHERE  
                        GUARANTY_ACTION_ID IN
                                            (
                                                SELECT 
                                                    ID
                                                FROM      
                                                    EZGI_WM_SERIAL_NO_LAST_STATUS
                                                WHERE   
                                                    SHIP_RESULT_TYPE = 2 AND 
                                                    SHIP_RESULT_ID IN (#new_shipping_internaldemand_list#)
                                            )
                </cfquery>
            </cfif>
            <!---Sevk Planlarındaki Toplam Paket Sayısı Olmayan sevk Planları Bulunuyor--->
            <cfquery name="get_shipping_null_amount" datasource="#dsn3#">
            	SELECT DISTINCT
                	SHIP_RESULT_INTERNALDEMAND_ID
              	FROM 
                	EZGI_SHIP_RESULT_INTERNALDEMAND 
              	WHERE 
                	SHIP_RESULT_INTERNALDEMAND_ID IN (#new_shipping_internaldemand_list#) AND
                    SHIPMENT_PACKAGE_AMOUNT IS NULL
            </cfquery>
            <cfif get_shipping_null_amount.recordcount> <!---Eğer Sevk Planlarındaki Toplam Paket Sayısı Olmayan sevk Planları Varsa--->
            	<cfloop query="get_shipping_null_amount"> <!---Teker Teker Hesaplayıp Yerine yazıyoruz--->
                	<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
                        SELECT     
                            PAKET_SAYISI AS PAKETSAYISI, 
                            PAKET_ID AS STOCK_ID, 
                            BARCOD, 
                            STOCK_CODE, 
                            PRODUCT_NAME,
                            SPECT_MAIN_ID,
                            COLLECT_SORT,
                            SHELF_CODE
                        FROM         
                            (
                            SELECT
                                SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                                PAKET_ID, 
                                BARCOD, 
                                STOCK_CODE, 
                                PRODUCT_NAME, 
                                PRODUCT_TREE_AMOUNT, 
                                SHIP_RESULT_INTERNALDEMAND_ID,
                                SPECT_MAIN_ID,
                                COLLECT_SORT,
                                SHELF_CODE
                            FROM
                                (     
                                SELECT 
                                    '' AS SERIAL_NO,
                                    '' AS SHELF_CODE,
                                    '' AS COLLECT_SORT,
                                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                                    EPS.PAKET_ID, 
                                    S.BARCOD, 
                                    S.STOCK_CODE, 
                                    S.PRODUCT_NAME, 
                                    S.PRODUCT_TREE_AMOUNT, 
                                    ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                                    ISNULL(SP.SPECT_MAIN_ID,0) AS SPECT_MAIN_ID
                                FROM          
                                    STOCKS AS S1 INNER JOIN
                                    EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                                    EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
                                    SPECTS AS SP ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
                                    STOCKS AS S INNER JOIN
                                    EZGI_PAKET_SAYISI AS EPS ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID 
                                WHERE      
                                    ESR.SHIP_RESULT_INTERNALDEMAND_ID = #get_shipping_null_amount.SHIP_RESULT_INTERNALDEMAND_ID# AND
                                    ORR.ORDER_ROW_CURRENCY = -6 AND
                                    ISNULL(S1.IS_PROTOTYPE,0) = 1 
                                GROUP BY 
                                    EPS.PAKET_ID,
                                    EPS.MODUL_SPECT_ID, 
                                    S.BARCOD, 
                                    S.STOCK_CODE, 
                                    S.PRODUCT_NAME, 
                                    S.PRODUCT_TREE_AMOUNT, 
                                    ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                                    ORR.SPECT_VAR_ID,
                                    SP.SPECT_MAIN_ID
                                UNION ALL
                                SELECT 
                                    '' AS SERIAL_NO,
                                    '' AS SHELF_CODE,
                                    '' AS COLLECT_SORT,    
                                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                                    EPS.PAKET_ID, 
                                    S.BARCOD, 
                                    S.STOCK_CODE, 
                                    S.PRODUCT_NAME, 
                                    S.PRODUCT_TREE_AMOUNT, 
                                    ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                                    0 AS SPECT_MAIN_ID
                                FROM
                                    EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                                    EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                    EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                                    STOCKS AS S ON S.STOCK_ID = EPS.PAKET_ID INNER JOIN
                                    STOCKS AS S1 ON S1.STOCK_ID = ORR.STOCK_ID
                                WHERE      
                                    ESR.SHIP_RESULT_INTERNALDEMAND_ID = #get_shipping_null_amount.SHIP_RESULT_INTERNALDEMAND_ID# AND
                                    ORR.ORDER_ROW_CURRENCY = -6 AND
                                    ISNULL(S1.IS_PROTOTYPE,0) = 0
                                GROUP BY
                                    EPS.PAKET_ID, 
                                    S.BARCOD, 
                                    S.STOCK_CODE, 
                                    S.PRODUCT_NAME, 
                                    S.PRODUCT_TREE_AMOUNT, 
                                    ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                                    ORR.SPECT_VAR_ID
                                ) AS TBL1
                            GROUP BY
                                PAKET_ID, 
                                BARCOD, 
                                STOCK_CODE, 
                                PRODUCT_NAME, 
                                PRODUCT_TREE_AMOUNT, 
                                SHIP_RESULT_INTERNALDEMAND_ID,
                                SPECT_MAIN_ID,
                                COLLECT_SORT,
                                SHELF_CODE
                            ) AS TBL
                    </cfquery>
                	<cfif GET_SHIP_PACKAGE_LIST.recordcount>
                    	<cfquery name="get_total_package" dbtype="query">
                            SELECT sum(PAKETSAYISI) PAKETSAYISI FROM GET_SHIP_PACKAGE_LIST
                        </cfquery>
                    
                        <cfquery name="upd_shipping_amount" datasource="#dsn3#">
                            UPDATE 
                                EZGI_SHIP_RESULT_INTERNALDEMAND
                            SET          
                                SHIPMENT_PACKAGE_AMOUNT = #get_total_package.PAKETSAYISI#
                            WHERE  
                                SHIP_RESULT_INTERNALDEMAND_ID = #get_shipping_null_amount.SHIP_RESULT_INTERNALDEMAND_ID#
                        </cfquery>
                    </cfif>
                </cfloop>
            </cfif>
            <!---Sevk Planlarındaki Toplam Paket Sayısı Tek Plana Toplanıyor--->
            <cfquery name="get_shipping_amount" datasource="#dsn3#">
            	SELECT 
                	SUM(ISNULL(SHIPMENT_PACKAGE_AMOUNT, 0)) AS AMOUNT 
              	FROM 
                	EZGI_SHIP_RESULT_INTERNALDEMAND 
              	WHERE 
                	SHIP_RESULT_INTERNALDEMAND_ID IN (#new_shipping_internaldemand_list#)
            </cfquery>
            <cfif len(get_shipping_amount.AMOUNT)>
                <cfquery name="upd_shipping_amount" datasource="#dsn3#">
                    UPDATE 
                        EZGI_SHIP_RESULT_INTERNALDEMAND
                    SET          
                        SHIPMENT_PACKAGE_AMOUNT = #get_shipping_amount.AMOUNT#
                    WHERE  
                        SHIP_RESULT_INTERNALDEMAND_ID = #REF_SHIP_RESULT_INTERNALDEMAND_ID#
                </cfquery>
            </cfif>
            
            <cfquery name="upd_shipping_row" datasource="#dsn3#">
                UPDATE    
                    EZGI_SHIP_RESULT_INTERNALDEMAND_ROW
                SET              
                    SHIP_RESULT_INTERNALDEMAND_ID = #get_min_ship_result_id.REF_SHIP_RESULT_INTERNALDEMAND_ID#
                WHERE     
                    SHIP_RESULT_INTERNALDEMAND_ROW_ID IN (#new_shipping_internaldemand_id_list#)
            </cfquery>
            <!---İlgili Sevk Planlarına Siliniyor--->
            <cfquery name="del_shipping" datasource="#dsn3#">
            	DELETE FROM 
                	EZGI_SHIP_RESULT_INTERNALDEMAND
				WHERE  
                	SHIP_RESULT_INTERNALDEMAND_ID IN (#new_shipping_internaldemand_list#) AND 
                    SHIP_RESULT_INTERNALDEMAND_ID <> #REF_SHIP_RESULT_INTERNALDEMAND_ID#
            </cfquery>
        </cfloop>
    </cftransaction>
<cfelse>
	<script language="javascript">
	   alert('<cf_get_lang dictionary_id='788.Birleşecek Kayıt Bulunamadı'>');
	</script>
    <cfabort>
</cfif>
<script language="javascript">
	wrk_opener_reload();
   	window.close();
</script>
