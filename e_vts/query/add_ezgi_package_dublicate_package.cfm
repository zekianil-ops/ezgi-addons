<!---
    File: add_ezgi_package_dublicate_package.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<!---<cfdump var="#attributes#"><cfabort>--->
<cfset attributes.old_operation_id = attributes.operation_id>
<cftransaction>
	<cflock timeout="90">
        <cfquery name="get_default_master_main" datasource="#dsn3#">
            SELECT PROTOTIP_PACKAGE_ID FROM EZGI_DESIGN_DEFAULTS
        </cfquery>
        <cfif not len(get_default_master_main.PROTOTIP_PACKAGE_ID) or get_default_master_main.PROTOTIP_PACKAGE_ID eq 0>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id='149.Önce Tasarım Genel Default Bilgilerini Tanımlayınız'> : <cf_get_lang dictionary_id='884.Özel Modül'>!");
                window.close()
            </script>
            <cfabort>
        </cfif>
        
		 <!---Master Paketlerin Listesini Çekiyorum--->
        <cfquery name="get_master_packages" datasource="#dsn3#">
            SELECT 
                EDPR.PACKAGE_ROW_ID, 
                EDPR.DESIGN_ID, 
                EDPR.DESIGN_MAIN_ROW_ID, 
                EDPR.PACKAGE_NUMBER, 
                EDPR.PACKAGE_NAME, 
                S.STOCK_ID, 
                S.PRODUCT_ID, 
                S.PRODUCT_NAME, 
                S.PRODUCT_CODE, 
                S.PRODUCT_BARCOD
            FROM     
                EZGI_DESIGN_PACKAGE_ROW AS EDPR INNER JOIN
                STOCKS AS S ON EDPR.PACKAGE_RELATED_ID = S.STOCK_ID
            WHERE  
                EDPR.DESIGN_MAIN_ROW_ID = #get_default_master_main.PROTOTIP_PACKAGE_ID# AND 
                S.IS_PROTOTYPE = 1 AND 
                S.IS_PRODUCTION = 1 AND 
                S.PRODUCT_STATUS = 1
            ORDER BY 
                EDPR.PACKAGE_NUMBER
        </cfquery>
       <!--- Master Paketlerin Listesini Çekiyorum
        <cfdump var="#get_master_packages#">--->
         <!---Bu Üretime Ait paketin Üretim Plan Bilgilerini Çekiyorum--->
        <cfquery name="get_old_package_production_order" datasource="#dsn3#">
            SELECT 
                P_ORDER_ID, 
                STOCK_ID, 
                QUANTITY,
                P_ORDER_NO, 
                PO_RELATED_ID, 
                SPECT_VAR_NAME, 
                PROD_ORDER_STAGE, 
                IS_STOCK_RESERVED, 
                IS_DEMONTAJ, 
                LOT_NO, 
                PRODUCTION_LEVEL, 
                SPEC_MAIN_ID, 
                IS_STAGE, 
                WRK_ROW_ID, 
                EXIT_DEP_ID, 
                EXIT_LOC_ID, 
                PRODUCTION_DEP_ID, 
                PRODUCTION_LOC_ID, 
                RECORD_IP, 
                RECORD_EMP, 
                RECORD_DATE
            FROM     
                PRODUCTION_ORDERS
            WHERE  
                P_ORDER_ID = #attributes.upd#
        </cfquery>
        <!---Bu Üretime Ait paketin Üretim Plan Bilgilerini Çekiyorum
        <cfdump var="#get_old_package_production_order#">--->
        <!---Bu Üretime Ait Tüm paketlerin Listesini ve Bilgilerini Çekiyorum--->
        <cfquery name="get_main_product_orders_stocks" datasource="#dsn3#">
            SELECT 
                PO.PO_RELATED_ID, 
                POS.POR_STOCK_ID, 
                POS.P_ORDER_ID, 
                POS.PRODUCT_ID, 
                POS.STOCK_ID, 
                POS.SPECT_MAIN_ID, 
                POS.AMOUNT, 
                POS.TYPE, 
                POS.PRODUCT_UNIT_ID, 
                POS.RECORD_DATE, 
                POS.RECORD_EMP, 
                POS.RECORD_IP, 
                POS.IS_PHANTOM, 
                POS.IS_SEVK, 
                POS.IS_PROPERTY, 
                POS.IS_FREE_AMOUNT, 
                POS.FIRE_AMOUNT, 
                POS.FIRE_RATE, 
                POS.SPECT_MAIN_ROW_ID, 
                POS.IS_FLAG, 
                POS.WRK_ROW_ID, 
                POS.LINE_NUMBER, 
                POS.LOT_NO, 
                POS.SPECT_VAR_ID, 
                S.PRODUCT_CATID
            FROM 
                STOCKS AS S INNER JOIN
                PRODUCTION_ORDERS_STOCKS AS POS ON S.STOCK_ID = POS.STOCK_ID INNER JOIN
                PRODUCTION_ORDERS AS PO ON POS.P_ORDER_ID = PO.PO_RELATED_ID INNER JOIN
                EZGI_DESIGN_DEFAULTS AS EDD ON S.PRODUCT_CATID = EDD.DEFAULT_PACKAGE_CAT_ID
            WHERE  
                PO.P_ORDER_ID = #attributes.upd# AND 
                POS.TYPE = 2
        </cfquery>
        <!---Bu Üretime Ait Tüm paketlerin Listesini ve Bilgilerini Çekiyorum
        <cfdump var="#get_main_product_orders_stocks#">--->
        <cfif get_main_product_orders_stocks.recordcount>
            <cfset old_package_spect_main_id_list = ValueList(get_main_product_orders_stocks.SPECT_MAIN_ID)>
            <!---<cfdump var="#old_package_spect_main_id_list#">--->
        <cfelse>
            <script type="text/javascript">
                alert("Listelenecek Paket Bulunamadı!");
                window.close()
            </script>
            <cfabort>
        </cfif>
       
        <!---Bu Üretimin Modül Bilgilerini Çekiyorum--->
        <cfquery name="get_main_production_order" datasource="#dsn3#">
            SELECT 
            	PO1.P_ORDER_ID,
                PO1.STOCK_ID, 
                PO1.SPECT_VAR_NAME, 
                PO1.LOT_NO, 
                PO1.SPEC_MAIN_ID, 
                PO1.QUANTITY
            FROM     
                PRODUCTION_ORDERS AS PO INNER JOIN
                PRODUCTION_ORDERS AS PO1 ON PO.PO_RELATED_ID = PO1.P_ORDER_ID
            WHERE  
                PO.P_ORDER_ID = #attributes.upd#
        </cfquery>
        <!---Bu Üretimin Modül Bilgilerini Çekiyorum
        <cfdump var="#get_main_production_order#">--->
        <cfif Listlen(old_package_spect_main_id_list) and len(get_main_production_order.SPEC_MAIN_ID)>
            <!---Tüm Paketlerin Yada Modülün Spect_Main_Row Tablo Bilgisini Çekiyorum  --->
            <cfquery name="get_main_main_spect_row" datasource="#dsn3#">
                SELECT 
                    SPECT_MAIN_ID, 
                    PRODUCT_ID, 
                    STOCK_ID, 
                    AMOUNT, 
                    PRODUCT_NAME, 
                    IS_PROPERTY, 
                    IS_CONFIGURE, 
                    IS_SEVK, 
                    RELATED_MAIN_SPECT_ID, 
                    LINE_NUMBER, 
                    IS_PHANTOM, 
                    QUESTION_ID, 
                    STATION_ID, 
                    IS_FREE_AMOUNT, 
                    FIRE_AMOUNT, 
                    FIRE_RATE, 
                    DETAIL
                FROM     
                    SPECT_MAIN_ROW
                WHERE  
                    SPECT_MAIN_ID = #get_main_production_order.SPEC_MAIN_ID# AND 
                    RELATED_MAIN_SPECT_ID IN (#old_package_spect_main_id_list#)
            </cfquery>
            <!---Tüm Paketlerin Yada Modülün Spect_Main_Row Tablo Bilgisini Çekiyorum
            <cfdump var="#get_main_main_spect_row#">--->
        <cfelse>
            <script type="text/javascript">
                alert("Paketlerin Main Spectleri Mevcut Değil!");
                window.close()
            </script>
            <cfabort>
        </cfif>
        <!---Eski paketin Design Bilgilerini Çekiyorum--->
        <cfquery name="get_package_design_info" datasource="#dsn3#">
            SELECT 
                PACKAGE_ROW_ID, 
                DESIGN_ID, 
                DESIGN_MAIN_ROW_ID, 
                PACKAGE_RELATED_ID, 
                PACKAGE_NUMBER, 
                PACKAGE_NAME
            FROM     
                EZGI_DESIGN_PACKAGE_ROW
            WHERE  
                PACKAGE_SPECT_RELATED_ID = #get_old_package_production_order.SPEC_MAIN_ID#
        </cfquery>
        <!---Eski paketin Design Bilgilerini Çekiyorum
        <cfdump var="#get_package_design_info#">--->
        <cfif not get_package_design_info.recordcount or not len(get_package_design_info.DESIGN_MAIN_ROW_ID)>
            <script type="text/javascript">
                alert("Paketin Design Bilgileri Mevcut Değil!");
                window.close()
            </script>
            <cfabort>
        </cfif>
        <!---Master paketlerin En son numarasını Çekiyorum--->
        <cfquery name="get_max_master_package_no" dbtype="query">
        	SELECT MAX(PACKAGE_NUMBER) AS MAX_MASTER_PACKAGE_NUMBER FROM get_master_packages
        </cfquery>
        <!---Master paketlerin En son numarasını Çekiyorum
         <cfdump var="#get_max_master_package_no#">--->
        <!---Eğer Master Paketler Yeni Eklenecek Paketten Büyük Değilse--->
        <cfif get_max_master_package_no.MAX_MASTER_PACKAGE_NUMBER lte get_main_product_orders_stocks.recordcount>
        	<script type="text/javascript">
                alert("Eklenecek Yeni Paket Master Paket Sayısını Aşıyor. Yeni Master Paketler Açmalısınız.");
                window.close()
            </script>
            <cfabort>
        </cfif>
        <!---Eski pakete ait Modülün En son paket numarasını Çekiyorum--->
        <cfquery name="max_design_package_no" datasource="#dsn3#">
            SELECT 
                MAX(PACKAGE_NUMBER) AS MAX_PACKAGE_NUMBER
            FROM     
                EZGI_DESIGN_PACKAGE_ROW
            WHERE  
                DESIGN_MAIN_ROW_ID = #get_package_design_info.DESIGN_MAIN_ROW_ID#
        </cfquery>
        <!---Eski pakete ait Modülün En son paket numarasını Çekiyorum
        <cfdump var="#max_design_package_no#">--->
        
        <!---Yeni Eklenecek Paket İçin Master Paketten Bilgiler Çekiliyor.--->
        <cfquery name="get_max_master_package_info" dbtype="query">
        	SELECT * FROM get_master_packages WHERE PACKAGE_NUMBER = #max_design_package_no.MAX_PACKAGE_NUMBER+1#
        </cfquery>
        <!---Yeni Eklenecek Paket İçin Master Paketten Bilgiler Çekiliyor
        <cfdump var="#get_max_master_package_info#">--->
         <!---Bölmek İstediğim Paketin Spect Main Bilgilerini Çekiyorum--->
         <cfquery name="get_old_package_spect_main" datasource="#dsn3#">
         	SELECT 
            	WRK_ID, 
                SPECT_MAIN_NAME, 
                SPECT_TYPE, 
                PRODUCT_ID, 
                STOCK_ID, 
                IS_TREE, 
                SPECT_STATUS, 
                FUSEACTION, 
                IS_LIMITED_STOCK, 
                RECORD_EMP, 
                RECORD_IP, 
                RECORD_DATE, 
                IS_MIX_PRODUCT
			FROM     
            	SPECT_MAIN
          	WHERE  
            	SPECT_MAIN_ID = #get_old_package_production_order.SPEC_MAIN_ID#
   		</cfquery>
        <!---Bölmek İstediğim Paketin Spect Main Bilgilerini Çekiyorum
        <cfdump var="#get_old_package_spect_main#">--->
        <cfset new_pakage_number= get_main_product_orders_stocks.recordcount+1>
		<cfquery name="new_get_master_packages" dbtype="query">
        	SELECT * FROM get_master_packages WHERE PACKAGE_NUMBER = #new_pakage_number#
        </cfquery>
        <!---****DÜZENLEMELER Başladı****--->
        
        <!---Spect_main Yeni Paketi Ekliyorum--->
        <cfquery name="add_package_spect_main" datasource="#dsn3#">
        	INSERT INTO 
            	SPECT_MAIN
             	(
                	WRK_ID, 
                    SPECT_MAIN_NAME, 
                    SPECT_TYPE, 
                    PRODUCT_ID, 
                    STOCK_ID, 
                    IS_TREE, 
                    SPECT_STATUS, 
                    FUSEACTION, 
                    IS_LIMITED_STOCK, 
                    IS_MIX_PRODUCT,
                    RECORD_EMP, 
                    RECORD_IP, 
                    RECORD_DATE
              	)
			VALUES
            	(
                	'#get_old_package_spect_main.WRK_ID#_#new_pakage_number#',
                    '#Replace(get_old_package_spect_main.SPECT_MAIN_NAME,'1 .','#new_pakage_number# .')#',
                    #get_old_package_spect_main.SPECT_TYPE#,
                    #new_get_master_packages.PRODUCT_ID#,
                    #new_get_master_packages.STOCK_ID#,
                    #get_old_package_spect_main.IS_TREE#,
                    #get_old_package_spect_main.SPECT_STATUS#,
                    '#get_old_package_spect_main.FUSEACTION#',
                    #get_old_package_spect_main.IS_LIMITED_STOCK#,
                    #get_old_package_spect_main.IS_MIX_PRODUCT#,
                    #session.ep.userid#,
                    '#cgi.remote_addr#',
                    #now()#
                )
        </cfquery>
        <!---Yeni SPECT_MAIN_ID yi çekiyoruz--->
        <cfquery name="GET_MAX_SPECT_MAIN_ID" datasource="#DSN3#">
        	SELECT MAX(SPECT_MAIN_ID) MAX_ID FROM SPECT_MAIN
        </cfquery>
        <!--- Yeni Açılan Paketi Modüle Bağlıyoruz--->
        
        <!---Yeni İlave--->
       	<cfquery name="add_package_for_modul_spect_row" datasource="#dsn3#">
        	INSERT INTO 
            	SPECT_MAIN_ROW
            	(
                    SPECT_MAIN_ID, 
                    PRODUCT_ID, 
                    STOCK_ID, 
                    AMOUNT, 
                    PRODUCT_NAME, 
                    IS_PROPERTY, 
                    IS_CONFIGURE, 
                    IS_SEVK, 
                    CALCULATE_TYPE, 
                    RELATED_MAIN_SPECT_ID, 
                    LINE_NUMBER, 
                    IS_PHANTOM, 
                    QUESTION_ID, 
                    STATION_ID, 
                    IS_FREE_AMOUNT, 
                    FIRE_AMOUNT, 
                    FIRE_RATE, 
                    DETAIL
                )
        	SELECT 
            	SPECT_MAIN_ID, 
                #new_get_master_packages.PRODUCT_ID#, 
                #new_get_master_packages.STOCK_ID#, 
                AMOUNT, 
                Replace(PRODUCT_NAME,'1 .','#new_pakage_number# .'), 
                IS_PROPERTY, 
                IS_CONFIGURE, 
                IS_SEVK, 
                CALCULATE_TYPE, 
                #GET_MAX_SPECT_MAIN_ID.MAX_ID#, 
                LINE_NUMBER, 
                IS_PHANTOM, 
                QUESTION_ID, 
                STATION_ID, 
                IS_FREE_AMOUNT, 
                FIRE_AMOUNT, 
                FIRE_RATE, 
                DETAIL
			FROM     
            	SPECT_MAIN_ROW
			WHERE  
            	SPECT_MAIN_ID = #get_main_production_order.SPEC_MAIN_ID# AND 
                STOCK_ID = #get_old_package_production_order.STOCK_ID# AND 
                RELATED_MAIN_SPECT_ID = #get_old_package_production_order.SPEC_MAIN_ID#
		</cfquery>
        <!---Yeni Paketin SPECT_MAIN_ROW_ID yi çekiyoruz--->
        <cfquery name="GET_MAX_PACKAGE_SPECT_MAIN_ROW_ID" datasource="#DSN3#">
        	SELECT MAX(SPECT_MAIN_ROW_ID) MAX_ID FROM SPECT_MAIN_ROW
        </cfquery>
        <!---Yeni İlave--->
        
        <!---MOBİLYA TASARIM--->
        <!---Mobilya Tasarımda Eski PaketBilgilerini Sepect Main ID üzerinden Buluyorum.--->
        <cfquery name="get_old_package" datasource="#dsn3#">
        	SELECT PACKAGE_ROW_ID FROM EZGI_DESIGN_PACKAGE_ROW WHERE PACKAGE_SPECT_RELATED_ID = #get_old_package_production_order.SPEC_MAIN_ID#
        </cfquery>
        <!---Mobilya Tasarımda Eski Paket Üzerinden Yeni paket Oluşturuyorum--->
        <cfquery name="add_new_package" datasource="#dsn3#">
        	INSERT INTO 
            	EZGI_DESIGN_PACKAGE_ROW
                (
                    DESIGN_ID, 
                    DESIGN_MAIN_ROW_ID, 
                    MASTER_PRODUCT_ID, 
                    PACKAGE_RELATED_ID, 
                    PACKAGE_NUMBER, 
                    PACKAGE_NAME, 
                    PACKAGE_COLOR_ID, 
                    PACKAGE_DETAIL, 
                    PACKAGE_AMOUNT, 
                    PACKAGE_BOYU, 
                    PACKAGE_ENI, 
                    PACKAGE_KALINLIK, 
                    PACKAGE_WEIGHT, 
                    PACKAGE_PARTNER_ID, 
                    PACKAGE_IS_MASTER, 
                    PACKAGE_SPECT_RELATED_ID
              	)
			SELECT        
            	DESIGN_ID, 
                DESIGN_MAIN_ROW_ID, 
                MASTER_PRODUCT_ID, 
                #new_get_master_packages.STOCK_ID#, 
             	#new_pakage_number#,
             	PACKAGE_NAME + '-' + CAST(PACKAGE_NUMBER AS VARCHAR) + '-' + '#new_pakage_number#',  
                PACKAGE_COLOR_ID, 
                PACKAGE_DETAIL, 
                PACKAGE_AMOUNT, 
            	PACKAGE_BOYU, 
                PACKAGE_ENI, 
                PACKAGE_KALINLIK, 
                PACKAGE_WEIGHT, 
                PACKAGE_PARTNER_ID, 
                PACKAGE_IS_MASTER, 
                #GET_MAX_SPECT_MAIN_ID.MAX_ID#
			FROM            
            	EZGI_DESIGN_PACKAGE_ROW
			WHERE        
            	PACKAGE_ROW_ID = #get_old_package.PACKAGE_ROW_ID#
        </cfquery>
        <!---Yeni Paketin SPECT_MAIN_ROW_ID yi çekiyoruz--->
        <cfquery name="GET_MAX_PACKAGE_ROW_ID" datasource="#DSN3#">
        	SELECT MAX(PACKAGE_ROW_ID) MAX_ID FROM EZGI_DESIGN_PACKAGE_ROW
        </cfquery>
        
        <!---MOBİLYA TASARIM--->
        
        <!---İlk Paketin Operasyonlarının aynısı yeni pakete de ekliyorum. --->
        <cfquery name="add_operation" datasource="#dsn3#">
        	INSERT INTO 
            	SPECT_MAIN_ROW
                (
                	SPECT_MAIN_ID, 
                    AMOUNT, 
                    IS_PROPERTY, 
                    IS_CONFIGURE, 
                    IS_SEVK, 
                    LINE_NUMBER, 
                    IS_PHANTOM, 
                    OPERATION_TYPE_ID, 
                    QUESTION_ID, 
                    STATION_ID, 
                    IS_FREE_AMOUNT, 
                    FIRE_AMOUNT, 
                    FIRE_RATE, DETAIL
          		)
          	SELECT 
            	#GET_MAX_SPECT_MAIN_ID.MAX_ID#, 
                AMOUNT, 
                IS_PROPERTY, 
                IS_CONFIGURE, 
                IS_SEVK, 
                LINE_NUMBER, 
                IS_PHANTOM, 
                OPERATION_TYPE_ID, 
                QUESTION_ID, 
                STATION_ID, 
                IS_FREE_AMOUNT, 
                FIRE_AMOUNT, 
                FIRE_RATE, 
                DETAIL
			FROM     
            	SPECT_MAIN_ROW
			WHERE  
            	SPECT_MAIN_ID =  #get_old_package_production_order.SPEC_MAIN_ID#
                AND PRODUCT_ID IS NULL
        </cfquery>
        
       
        
        <!--- Üretim Emir No için Bilgi alıyoruz--->
       	<cfquery name="get_paperno" datasource="#dsn3#">
         	SELECT PROD_ORDER_NUMBER FROM GENERAL_PAPERS WHERE GENERAL_PAPERS_ID = 1
      	</cfquery>
   		<cfset new_paperno = get_paperno.PROD_ORDER_NUMBER+1>
    	<cfquery name="upd_paperno" datasource="#dsn3#">
          	UPDATE
             	GENERAL_PAPERS
           	SET
             	PROD_ORDER_NUMBER = #new_paperno#
         	WHERE 
            	GENERAL_PAPERS_ID = 1
     	</cfquery>
     	<!---Üretim Emirlerine İlave Ediyorum.--->
		<cfquery name="add_product_orders" datasource="#dsn3#">
            	INSERT INTO 
                	PRODUCTION_ORDERS
                  	(
                    	STOCK_ID, 
                        STATION_ID, 
                        START_DATE, 
                        FINISH_DATE, 
                        QUANTITY, 
                        STATUS, 
                        PROJECT_ID, 
                        P_ORDER_NO, 
                        PO_RELATED_ID, 
                        SPECT_VAR_NAME, 
                        PROD_ORDER_STAGE, 
                        IS_STOCK_RESERVED, 
                        IS_DEMONTAJ, 
                        LOT_NO, 
                  		PRODUCTION_LEVEL, 
                        SPEC_MAIN_ID, 
                        IS_STAGE, 
                        WRK_ROW_ID, 
                        EXIT_DEP_ID, 
                        EXIT_LOC_ID, 
                        PRODUCTION_DEP_ID, 
                        PRODUCTION_LOC_ID,
                        RECORD_IP, 
                        RECORD_EMP, 
                        RECORD_DATE,
                        WRK_ROW_RELATION_ID
                 	)
				SELECT 
                	#new_get_master_packages.STOCK_ID#, 
                    STATION_ID, 
                    START_DATE, 
                    FINISH_DATE, 
                    QUANTITY, 
                    STATUS, 
                    PROJECT_ID, 
                    #new_paperno#, 
                    PO_RELATED_ID, 
                    '#Replace(get_main_main_spect_row.PRODUCT_NAME,'1 .','#new_pakage_number# .')#', 
                    PROD_ORDER_STAGE, 
                    IS_STOCK_RESERVED, 
                    IS_DEMONTAJ, 
                    LOT_NO, 
                  	PRODUCTION_LEVEL, 
                    #GET_MAX_SPECT_MAIN_ID.MAX_ID#, 
                    IS_STAGE, 
                    WRK_ROW_ID+CAST(#new_pakage_number# AS VARCHAR) AS WRK_ROW, 
                    EXIT_DEP_ID, 
                    EXIT_LOC_ID, 
                    PRODUCTION_DEP_ID, 
                    PRODUCTION_LOC_ID, 
                    '#cgi.remote_addr#',
					#session.ep.userid#,
                    #now()#,
                    WRK_ROW_ID
				FROM     
                	PRODUCTION_ORDERS
				WHERE  
                	P_ORDER_ID = #attributes.upd#
     	</cfquery>
        
        <!---Yeni P_ORDER_ID yi çekiyoruz--->
        <cfquery name="GET_MAX_P_ORDER_ID" datasource="#DSN3#">
        	SELECT MAX(P_ORDER_ID) MAX_ID FROM PRODUCTION_ORDERS
        </cfquery>
        
        <!---Yeni Açılan Paket Emrini Siparişe Bağlıyorum.--->
        <cfquery name="add_production_order_row" datasource="#dsn3#">
        	INSERT INTO 
            	PRODUCTION_ORDERS_ROW
                (
                	PRODUCTION_ORDER_ID, 
                    ORDER_ROW_ID, 
                    ORDER_ID, 
                    TYPE, 
                    PLAN_ID, 
                    OP_ID, 
                    P_ORDER_ID
               	)
			SELECT        
            	#GET_MAX_P_ORDER_ID.MAX_ID#,
                ORDER_ROW_ID, 
                ORDER_ID, 
                TYPE, 
                PLAN_ID, 
                OP_ID, 
                P_ORDER_ID
			FROM            
            	PRODUCTION_ORDERS_ROW
			WHERE        
            	PRODUCTION_ORDER_ID = #attributes.upd#
        </cfquery>
        
        
        
        <!---Yeni Açılan Paket Emrini Üst Emre Bağlıyorum İlave Ediyorum.--->
        
		<cfquery name="add_product_operation" datasource="#dsn3#">
        	INSERT INTO
            	PRODUCTION_ORDERS_STOCKS
                (
                	P_ORDER_ID, 
                    PRODUCT_ID, 
                    STOCK_ID, 
                    SPECT_MAIN_ID, 
                    AMOUNT, 
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
                    WRK_ROW_ID, 
                    LINE_NUMBER,
                    RECORD_DATE, 
                    RECORD_EMP, 
                    RECORD_IP
           		)
        	SELECT 
            	P_ORDER_ID, 
                #new_get_master_packages.PRODUCT_ID#, 
                #new_get_master_packages.STOCK_ID#,  
                #GET_MAX_SPECT_MAIN_ID.MAX_ID#,  
                AMOUNT, 
                TYPE, 
                PRODUCT_UNIT_ID, 
                IS_PHANTOM, 
                IS_SEVK, 
                IS_PROPERTY, 
                IS_FREE_AMOUNT, 
                FIRE_AMOUNT, 
                FIRE_RATE, 
               	#GET_MAX_PACKAGE_SPECT_MAIN_ROW_ID.MAX_ID#, 
                IS_FLAG, 
                WRK_ROW_ID+CAST(#new_pakage_number# AS VARCHAR) AS WRK_ROW,
                LINE_NUMBER,
                #now()#,
                #session.ep.userid#,
                '#cgi.remote_addr#'
			FROM     
            	PRODUCTION_ORDERS_STOCKS
			WHERE  
            	P_ORDER_ID = #get_main_production_order.P_ORDER_ID# AND 
                STOCK_ID = #get_old_package_production_order.STOCK_ID# AND 
                SPECT_MAIN_ID = #get_old_package_production_order.SPEC_MAIN_ID#
        </cfquery>
        
        <!---Üretim Operasyonlarına İlave Ediyorum.--->
		<cfquery name="add_product_operation" datasource="#dsn3#">
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
        	SELECT 
            	#GET_MAX_P_ORDER_ID.MAX_ID#, 
                AMOUNT, 
                OPERATION_TYPE_ID, 
                STAGE,
                #session.ep.userid#,
             	#now()#,
                '#cgi.remote_addr#'
			FROM     
            	PRODUCTION_OPERATION
			WHERE  
            	P_ORDER_ID = #attributes.upd#
       	</cfquery>
        <!---Yeni P_OPERATION_ID yi çekiyoruz--->
        <cfquery name="GET_MAX_P_OPERATION_ID" datasource="#DSN3#">
        	SELECT MAX(P_OPERATION_ID) MAX_ID FROM PRODUCTION_OPERATION
        </cfquery>
        
         <!---Yeni Açılan Üretim Operasyonlarına Sonuç İlave Ediyorum.--->
		<cfquery name="add_product_operation_result" datasource="#dsn3#">
        	INSERT INTO 
            	PRODUCTION_OPERATION_RESULT
              	(
                	P_ORDER_ID, 
                    OPERATION_ID, 
                    STATION_ID, 
                    REAL_AMOUNT, 
                    LOSS_AMOUNT, 
                    REAL_TIME, 
                    ACTION_EMPLOYEE_ID, 
                    ACTION_START_DATE, 
                    RECORD_EMP, 
                    RECORD_DATE, 
                    RECORD_IP
              	)
          	SELECT 
            	#GET_MAX_P_ORDER_ID.MAX_ID#, 
                #GET_MAX_P_OPERATION_ID.MAX_ID#, 
                STATION_ID, 
                REAL_AMOUNT, 
                LOSS_AMOUNT, 
                REAL_TIME, 
                ACTION_EMPLOYEE_ID, 
                ACTION_START_DATE, 
                #session.ep.userid#,
             	#now()#,
                '#cgi.remote_addr#'
			FROM     
            	PRODUCTION_OPERATION_RESULT
			WHERE  
            	P_ORDER_ID = #attributes.upd#
       	</cfquery>
        
        <!---Yeni OPERATION_RESULT_ID yi çekiyoruz--->
        <cfquery name="GET_MAX_OPERATION_RESULT_ID" datasource="#DSN3#">
        	SELECT MAX(OPERATION_RESULT_ID) MAX_ID FROM PRODUCTION_OPERATION_RESULT
        </cfquery>
        
        <cfquery name="get_last_p_operation_result_info" datasource="#dsn3#">
        	SELECT 
            	AMOUNT,
                ISNULL((
                		SELECT 
                        	SUM(REAL_AMOUNT) AS REAL_AMOUNT
                       	FROM      
                        	PRODUCTION_OPERATION_RESULT
                       	WHERE   
                        	OPERATION_ID = PO.P_OPERATION_ID
           		),0) AS REAL_AMOUNT
			FROM     
            	PRODUCTION_OPERATION AS PO
			WHERE  
            	P_OPERATION_ID = #GET_MAX_P_OPERATION_ID.MAX_ID#
        </cfquery>
        
        <!---Eski Üretim Operasyonların Sonusundaki Başlama zamanını Update Ediyorum.--->
		<cfquery name="updd_product_operation_result" datasource="#dsn3#">
        	UPDATE
            	PRODUCTION_OPERATION_RESULT
           	SET
            	 ACTION_START_DATE = #now()#
			WHERE  
            	OPERATION_ID = #attributes.old_operation_id# AND
                STATION_ID = #attributes.station_id# AND
                ACTION_EMPLOYEE_ID = #attributes.employee_id# 
        </cfquery>
        
        <!---Satırları Döndürüyorum--->
        <cfloop list="#row_info_content#" index="i">
        	<cfset change_stock_id = ListGetAt(i,3,'-')>
            <cfset change_spect_main_id = ListGetAt(i,2,'-')>
            <cfset change_amount = ListGetAt(i,4,'-')>
            <!---Bölünmek İstenilen Paketin Satırdaki Miktarına Bakıyorum--->
            
            <cfquery name="get_change_spect_main_row" datasource="#dsn3#">
            	SELECT 
                	AMOUNT
				FROM     
                	SPECT_MAIN_ROW
				WHERE  
                	SPECT_MAIN_ID = #get_old_package_production_order.SPEC_MAIN_ID# AND 
                    STOCK_ID = #change_stock_id# 
                    <cfif change_spect_main_id gt 0>
                    	AND RELATED_MAIN_SPECT_ID = #change_spect_main_id#
                  	</cfif>
            </cfquery>
            <cfif not get_change_spect_main_row.recordcount>
            	<cfdump var="#get_change_spect_main_row#">
            	<script type="text/javascript">
					alert("Pakette İlgili Ürün Bulunamadı!");
					window.close()
				</script>
				<cfabort>
            </cfif>
            <cfif get_change_spect_main_row.AMOUNT lt change_amount>
            	<script type="text/javascript">
					alert("Pakette İlgili Ürün Yeteri Kadar Bulunamadı!");
					window.close()
				</script>
				<cfabort>
            </cfif>
            
            <!---Yeni Açılan pakette Benzer Ürün Varmı Miktarı Nedir?--->
            <cfquery name="get_same_spect_row" datasource="#dsn3#">
            	SELECT 
                	ISNULL(AMOUNT,0) AS AMOUNT
				FROM     
                	SPECT_MAIN_ROW
				WHERE  
                	SPECT_MAIN_ID = #GET_MAX_SPECT_MAIN_ID.MAX_ID# AND 
                    STOCK_ID = #change_stock_id# 
                    <cfif change_spect_main_id gt 0>
                    	AND RELATED_MAIN_SPECT_ID = #change_spect_main_id#
                    </cfif>
            </cfquery>
            
            <!---<cfdump var="#get_same_spect_row#"><cfabort>--->
            
            <cfif get_same_spect_row.recordcount><!--- Eğer Benzer Ürün Varsa Yani Ürün 2 ve daha üsütüne ise ve az önce kaydı oluşmuşsa--->
            
            	<!---Yeni paketTEKİ iLGİLİ SATIRIN MİKTARINI GÜNCELLİYORUM.--->
                <cfset new_amount = get_same_spect_row.AMOUNT+change_amount>
                <!---MAIN SPECT--->
                <cfquery name="upd_piece_amount_spect" datasource="#dsn3#">
                    UPDATE
                        SPECT_MAIN_ROW
                    SET
                        AMOUNT = #new_amount#
                    WHERE  
                        SPECT_MAIN_ID = #GET_MAX_SPECT_MAIN_ID.MAX_ID# AND 
                        STOCK_ID = #change_stock_id# 
                        <cfif change_spect_main_id gt 0>
                        	AND RELATED_MAIN_SPECT_ID = #change_spect_main_id#
                        </cfif>
               	</cfquery>
                <!---MAIN SPECT--->
                
                <!---ÜRETİM PLANLAMA--->
                <!---Yeni paketTEKİ iLGİLİ SATIRIN MİKTARINI GÜNCELLİYORUM.--->
                <cfquery name="upd_piece_amount_order" datasource="#dsn3#">
                    UPDATE
                        PRODUCTION_ORDERS_STOCKS
                    SET
                        AMOUNT = #new_amount*get_old_package_production_order.QUANTITY#
                   	WHERE  
                    	P_ORDER_ID = #GET_MAX_P_ORDER_ID.MAX_ID# AND 
                        STOCK_ID = #change_stock_id# 
                        <cfif change_spect_main_id gt 0>
                        	AND SPECT_MAIN_ID = #change_spect_main_id#
                        </cfif>
               	</cfquery>
                <!---ÜRETİM PLANLAMA--->
                
                <!---MOBİLYA TASARIM--->
                <cfquery name="upd_piece_amount_spect" datasource="#dsn3#">
                    UPDATE
                        EZGI_DESIGN_PIECE_ROWS
                    SET
                        PIECE_AMOUNT = #new_amount#
                    WHERE  
                        DESIGN_PACKAGE_ROW_ID = #GET_MAX_PACKAGE_ROW_ID.MAX_ID# AND
                        PIECE_RELATED_ID = #change_stock_id# 
                        <cfif change_spect_main_id gt 0>
                            AND PIECE_SPECT_RELATED_ID = #change_spect_main_id#
                        </cfif>
               	</cfquery>
                <!---MOBİLYA TASARIM--->
                
            <cfelse><!--- Eğer Benzer Ürün Yoksa--->
            
            	<!---MAIN SPECT--->
				<!---İlgili Satırları Yeni pakete Kopyalıyorum--->
                <cfquery name="add_piece_for_new_package" datasource="#dsn3#">
                    INSERT INTO 
                        SPECT_MAIN_ROW
                        (
                            SPECT_MAIN_ID, 
                            PRODUCT_ID, 
                            STOCK_ID, 
                            AMOUNT, 
                            PROPERTY_ID, 
                            VARIATION_ID, 
                            TOTAL_MIN, 
                            TOTAL_MAX, 
                            PRODUCT_NAME, 
                            IS_PROPERTY, 
                            IS_CONFIGURE, 
                            IS_SEVK, 
                            TOTAL_VALUE, 
                            TOLERANCE, 
                            PRODUCT_SPACE, 
                            PRODUCT_DISPLAY, 
                            PRODUCT_RATE, 
                            PRODUCT_LIST_PRICE, 
                            CALCULATE_TYPE, 
                            RELATED_MAIN_SPECT_ID, 
                            RELATED_MAIN_SPECT_NAME, 
                            LINE_NUMBER, DIMENSION, 
                            CONFIGURATOR_VARIATION_ID, 
                            IS_PHANTOM, 
                            RELATED_TREE_ID, 
                            OPERATION_TYPE_ID, 
                            QUESTION_ID, 
                            STATION_ID, 
                            IS_FREE_AMOUNT, 
                            FIRE_AMOUNT, 
                            FIRE_RATE, 
                            DETAIL, 
                            IS_QUALITY_TYPE, 
                            QUALITY_TYPE_ID, 
                            QUALITY_STANDART_VALUE, 
                            QUALITY_MEASURE, 
                            QUALITY_TOLERANCE
                        )
                    SELECT
                		#GET_MAX_SPECT_MAIN_ID.MAX_ID#,
                        PRODUCT_ID, 
                        STOCK_ID, 
                        #change_amount#, 
                        PROPERTY_ID, 
                        VARIATION_ID, 
                        TOTAL_MIN, 
                        TOTAL_MAX, 
                        PRODUCT_NAME, 
                        IS_PROPERTY, 
                        IS_CONFIGURE, 
                        IS_SEVK, 
                        TOTAL_VALUE, 
                        TOLERANCE, 
                  		PRODUCT_SPACE, 
                        PRODUCT_DISPLAY, 
                        PRODUCT_RATE, 
                        PRODUCT_LIST_PRICE, 
                        CALCULATE_TYPE, 
                        RELATED_MAIN_SPECT_ID, 
                        RELATED_MAIN_SPECT_NAME, 
                        LINE_NUMBER, DIMENSION, 
                        CONFIGURATOR_VARIATION_ID, 
                  		IS_PHANTOM, 
                        RELATED_TREE_ID, 
                        OPERATION_TYPE_ID, 
                        QUESTION_ID, 
                        STATION_ID, 
                        IS_FREE_AMOUNT, 
                        FIRE_AMOUNT, 
                        FIRE_RATE, 
                        DETAIL, 
                        IS_QUALITY_TYPE, 
                        QUALITY_TYPE_ID, 
                        QUALITY_STANDART_VALUE, 
                  		QUALITY_MEASURE, 
                        QUALITY_TOLERANCE 
                    FROM    
                        SPECT_MAIN_ROW
                    WHERE  
                        SPECT_MAIN_ID = #get_old_package_production_order.SPEC_MAIN_ID# AND 
                        STOCK_ID = #change_stock_id# 
                        <cfif change_spect_main_id gt 0>
                        	AND RELATED_MAIN_SPECT_ID = #change_spect_main_id#
                       	</cfif>
                </cfquery>
                <!---Yeni SPECT_MAIN_ROW_ID yi çekiyoruz--->
                <cfquery name="GET_MAX_SPECT_MAIN_ROW_ID" datasource="#DSN3#">
                    SELECT MAX(SPECT_MAIN_ROW_ID) MAX_ID FROM SPECT_MAIN_ROW
                </cfquery>
                <!---MAIN SPECT--->
                
                <!---ÜRETİM PLANLAMA--->
                <!---İlgili Satırları Yeni pakete Kopyalıyorum--->
                <cfquery name="add_piece_for_new_package_order" datasource="#dsn3#">
                	INSERT INTO 
                    	PRODUCTION_ORDERS_STOCKS
                  		(
                        	P_ORDER_ID, 
                            PRODUCT_ID, 
                            STOCK_ID, 
                            SPECT_MAIN_ID, 
                            AMOUNT, 
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
                            WRK_ROW_ID, 
                            LINE_NUMBER,
                            RECORD_IP,
                            RECORD_EMP, 
                            RECORD_DATE
                     	)
					SELECT
                    		#GET_MAX_P_ORDER_ID.MAX_ID#, 
                            PRODUCT_ID, 
                            STOCK_ID, 
                            SPECT_MAIN_ID, 
                            #change_amount*get_old_package_production_order.QUANTITY#, 
                            TYPE, 
                            PRODUCT_UNIT_ID, 
                            IS_PHANTOM, 
                            IS_SEVK, 
                            IS_PROPERTY, 
                            IS_FREE_AMOUNT, 
                            FIRE_AMOUNT, 
                            FIRE_RATE, 
                  			#GET_MAX_SPECT_MAIN_ROW_ID.MAX_ID#, 
                            IS_FLAG, 
                            WRK_ROW_ID+CAST(#new_pakage_number# AS VARCHAR) AS WRK_ROW,
                            LINE_NUMBER,
                            '#cgi.remote_addr#',
                            #session.ep.userid#,
                            #now()#
					FROM     
                    	PRODUCTION_ORDERS_STOCKS
					WHERE  
                    	P_ORDER_ID = #attributes.upd# AND 
                        STOCK_ID = #change_stock_id# 
                        <cfif change_spect_main_id gt 0>
                        	AND SPECT_MAIN_ID = #change_spect_main_id#
                        </cfif>
             	</cfquery>  
                <!---ÜRETİM PLANLAMA--->
                
                <!---MOBİLYA TASARIM--->
                <!---İlgili Satırı Yeni Açtığım pakete Kopyalamak İçin Parça ID sini buluyorum--->
                <cfquery name="get_piece_for_new_package" datasource="#dsn3#">
                	SELECT
                    	PIECE_ROW_ID
               		FROM 
                    	EZGI_DESIGN_PIECE_ROWS
                    WHERE 
                      	DESIGN_PACKAGE_ROW_ID = #get_old_package.PACKAGE_ROW_ID# AND
                        PIECE_RELATED_ID = #change_stock_id# 
                        <cfif change_spect_main_id gt 0>
                            AND PIECE_SPECT_RELATED_ID = #change_spect_main_id#
                        </cfif>
                </cfquery>
                <!---İlgili Satırları Yeni Açtığım pakete Kopyalıyorum--->
                <cfquery name="add_piece_for_new_package" datasource="#dsn3#">
                	INSERT INTO 
                    	EZGI_DESIGN_PIECE_ROWS 
                        (
                            DESIGN_MAIN_ROW_ID,
                            DESIGN_PACKAGE_ROW_ID,
                            DESIGN_ID,
                            MASTER_PRODUCT_ID,
                            PIECE_TYPE,
                            PIECE_NAME,
                            PIECE_CODE,
                            PIECE_STATUS,
                            PIECE_COLOR_ID,
                            PIECE_RELATED_ID,
                            PIECE_DETAIL,
                            PIECE_AMOUNT,
                            MATERIAL_ID,
                            TRIM_TYPE,
                            TRIM_SIZE,
                            IS_FLOW_DIRECTION,
                            BOYU,
                            ENI,
                            KESIM_BOYU,
                            KESIM_ENI,
                            KALINLIK,
                            AGIRLIK,
                            PIECE_PARTNER_ID,
                            PIECE_IS_MASTER,
                            PIECE_PRICE,
                            PIECE_PRICE_MONEY,
                            PIECE_FLOOR,
                            PIECE_PACKAGE_ROTA,
                            RECORD_EMP,
                            RECORD_IP,
                            RECORD_DATE,
                            UPDATE_EMP,
                            UPDATE_IP,
                            UPDATE_DATE,
                            PIECE_SPECT_RELATED_ID,
                            TRIM_1,
                            TRIM_2,
                            TRIM_3,
                            TRIM_4,
                            PIECE_STYLE,
                            BOY_FARK,
                            EN_FARK,
                            PIECE_PARAMS,
                            CANALIZING_TYPE,
                            IS_LABEL
                        )
                    SELECT 
                    	DESIGN_MAIN_ROW_ID,
                        #GET_MAX_PACKAGE_ROW_ID.MAX_ID#,
                        DESIGN_ID,
                        MASTER_PRODUCT_ID,
                        PIECE_TYPE,
                        PIECE_NAME,
                        PIECE_CODE,
                        PIECE_STATUS,
                        PIECE_COLOR_ID,
                        PIECE_RELATED_ID,
                        PIECE_DETAIL,
                        #change_amount#,
                        MATERIAL_ID,
                        TRIM_TYPE,
                        TRIM_SIZE,
                        IS_FLOW_DIRECTION,
                        BOYU,
                        ENI,
                        KESIM_BOYU,
                        KESIM_ENI,
                        KALINLIK,
                        AGIRLIK,
                        PIECE_PARTNER_ID,
                        PIECE_IS_MASTER,
                        PIECE_PRICE,
                        PIECE_PRICE_MONEY,
                        PIECE_FLOOR,
                        PIECE_PACKAGE_ROTA,
                        RECORD_EMP,
                        RECORD_IP,
                        RECORD_DATE,
                        UPDATE_EMP,
                        UPDATE_IP,
                        UPDATE_DATE,
                        PIECE_SPECT_RELATED_ID,
                        TRIM_1,
                        TRIM_2,
                        TRIM_3,
                        TRIM_4,
                        PIECE_STYLE,
                        BOY_FARK,
                        EN_FARK,
                        PIECE_PARAMS,
                        CANALIZING_TYPE,
                        IS_LABEL
                    FROM 
                    	EZGI_DESIGN_PIECE_ROWS
                    WHERE 
                        PIECE_ROW_ID = #get_piece_for_new_package.PIECE_ROW_ID#
              	</cfquery>
                <!---Yeni SPECT_MAIN_ROW_ID yi çekiyoruz--->
                <cfquery name="GET_MAX_PIECE_ROW_ID" datasource="#DSN3#">
                    SELECT MAX(PIECE_ROW_ID) MAX_ID FROM EZGI_DESIGN_PIECE_ROWS
                </cfquery>   
                <!---Yeni Açtığım PARÇANIN Malzeme bilgilerini ekliyorum--->
                <cfquery name="add_piece_material_for_new_package" datasource="#dsn3#">
                	INSERT INTO 
                    	EZGI_DESIGN_PIECE_ROW
                        (
                        	PIECE_ROW_ID, 
                            RELATED_PIECE_ROW_ID, 
                            STOCK_ID, 
                            AMOUNT, 
                            SIRA_NO, 
                            PIECE_ROW_ROW_TYPE, 
                            EZGI_PIECE_ROW_ROW_ID, 
                            PIECE_DETAIL
                      	)
					SELECT        
                    	#GET_MAX_PIECE_ROW_ID.MAX_ID#, 
                        RELATED_PIECE_ROW_ID, 
                        STOCK_ID, 
                        AMOUNT, 
                        SIRA_NO, 
                        PIECE_ROW_ROW_TYPE, 
                        EZGI_PIECE_ROW_ROW_ID, 
                        PIECE_DETAIL
					FROM            
                    	EZGI_DESIGN_PIECE_ROW
					WHERE        
                    	PIECE_ROW_ID = #get_piece_for_new_package.PIECE_ROW_ID#
                </cfquery>
                 <!---Yeni Açtığım PARÇANIN Rota bilgilerini ekliyorum--->
                <cfquery name="add_piece_rota_for_new_package" datasource="#dsn3#">
                	INSERT INTO 
                    	EZGI_DESIGN_PIECE_ROTA
                        (
                        	PIECE_ROW_ID, 
                            OPERATION_TYPE_ID, 
                            SIRA, AMOUNT, 
                            PACKAGE_ROW_ID, 
                            MAIN_ROW_ID
                      	)
					SELECT        
                    	#GET_MAX_PIECE_ROW_ID.MAX_ID#, 
                        OPERATION_TYPE_ID, 
                        SIRA, 
                        AMOUNT, 
                        PACKAGE_ROW_ID, 
                        MAIN_ROW_ID
					FROM            
                    	EZGI_DESIGN_PIECE_ROTA
					WHERE        
                    	PIECE_ROW_ID = #get_piece_for_new_package.PIECE_ROW_ID#
                </cfquery>
				<!---MOBİLYA TASARIM--->
          	</cfif>
            <!---Eğer Eklenecek Satırla Bölünecek satırların miktarı aynıysa Bölünecek pakettlen ilgili satırı siliyorum. --->
            <cfif get_change_spect_main_row.AMOUNT eq change_amount>
            	<cfquery name="del_piece_from_old_package_spect" datasource="#dsn3#">
                	DELETE FROM    
                        SPECT_MAIN_ROW
                    WHERE  
                        SPECT_MAIN_ID = #get_old_package_production_order.SPEC_MAIN_ID# AND 
                        STOCK_ID = #change_stock_id# 
                        <cfif change_spect_main_id gt 0>
                        	AND RELATED_MAIN_SPECT_ID = #change_spect_main_id#
                        </cfif>
                </cfquery>
                <cfquery name="del_piece_from_old_package_order" datasource="#dsn3#">
                	DELETE FROM    
                        PRODUCTION_ORDERS_STOCKS
                    WHERE  
                        P_ORDER_ID = #attributes.upd# AND 
                        STOCK_ID = #change_stock_id# 
                        <cfif change_spect_main_id gt 0>
                        	AND SPECT_MAIN_ID = #change_spect_main_id#
                       	</cfif>
                </cfquery>
            <cfelse><!---Eğer Eklenecek Satırla Bölünecek satırların miktarı farklıysa Bölünecek pakettlen ilgili satırı güncelliyorum. --->
            	<cfquery name="del_piece_from_old_package_spect" datasource="#dsn3#">
                	UPDATE    
                        SPECT_MAIN_ROW
                   	SET
                    	AMOUNT = AMOUNT-#change_amount#
                    WHERE  
                        SPECT_MAIN_ID = #get_old_package_production_order.SPEC_MAIN_ID# AND 
                        STOCK_ID = #change_stock_id# 
                        <cfif change_spect_main_id gt 0>
                        	AND RELATED_MAIN_SPECT_ID = #change_spect_main_id#
                        </cfif>
                </cfquery>
                <cfquery name="del_piece_from_old_package_order" datasource="#dsn3#">
                	UPDATE    
                        PRODUCTION_ORDERS_STOCKS
                   	SET
                    	AMOUNT = AMOUNT-#change_amount*get_old_package_production_order.QUANTITY#
                    WHERE  
                        P_ORDER_ID = #attributes.upd# AND 
                        STOCK_ID = #change_stock_id# 
                        <cfif change_spect_main_id gt 0>
                        	AND SPECT_MAIN_ID = #change_spect_main_id#
                      	</cfif>
                </cfquery>
            </cfif>
        </cfloop>
        <!---****DÜZENLEMELER tamamlandı****--->
		<cfset attributes.package_dublicate =1>
        <cfset attributes.employee_id_=attributes.employee_id>
        <cfset attributes.station_id_=attributes.station_id>
        <cfset attributes.upd_id=GET_MAX_P_ORDER_ID.MAX_ID>
        <cfset attributes.operation_id_ = GET_MAX_P_OPERATION_ID.MAX_ID>
        <cfset attributes.realized_amount_= 1>
    	<cfinclude template="addOperationResult_ezgi.cfm">
        <cfset upd_operation_id = attributes.old_operation_id>
        <cfset upd_porder_id = attributes.upd>
        <!---<cfdump var="#attributes#">
        <cfdump var="#get_last_p_operation_result_info#">
        <cfabort>--->
        <cfif attributes.sonraki_tur eq 0> <!---1. Paket İse--->
			<cfif get_last_p_operation_result_info.AMOUNT eq 1> <!---Eğer Üretim Miktarı 1 ise--->
            	<!---Hiç Birşey Yapma--->
                
        	<cfelse> <!---Eğer Bölünmüş paket Üretimi Eksik Kalmışsa 1. Paketin Operasyon Başlangıcını Yeni Pakete Çeviriyorum--->
            	<cfquery name="updd_product_operation_result" datasource="#dsn3#">
                    UPDATE
                        PRODUCTION_OPERATION_RESULT
                    SET
                         OPERATION_ID = #GET_MAX_P_OPERATION_ID.MAX_ID#,
                         P_ORDER_ID = #GET_MAX_P_ORDER_ID.MAX_ID#
                    WHERE  
                        OPERATION_ID = #attributes.old_operation_id# AND
                        STATION_ID = #attributes.station_id# AND
                        ACTION_EMPLOYEE_ID = #attributes.employee_id# 
                </cfquery>
            	<cfset upd_operation_id = GET_MAX_P_OPERATION_ID.MAX_ID> <!---Dönüş Linkteki Operasyon ID si Yeni Bölünmüş Pakete Çevriliyor--->
                <cfset upd_porder_id = GET_MAX_P_ORDER_ID.MAX_ID> <!---Dönüş Linkteki P_ORDER_ID si Yeni Bölünmüş Pakete Çevriliyor--->
            </cfif>
        </cfif>
    </cflock>
</cftransaction> 
<cflocation url="#request.self#?fuseaction=production.add_ezgi_production_order&upd=#upd_porder_id#&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&p_operation_id=#upd_operation_id#" addtoken="No">
