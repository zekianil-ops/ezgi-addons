<!---
    File: upd_ezgi_iflow_production_order_verifaction.cfm
    Folder: AddOns\ezgi\e_production\query
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description:
--->

<!---Master Paketleri Buluyorum (Bölünmemiş Halleri)--->
<cfquery name="Get_new_po" datasource="#dsn3#">
	SELECT 
    	PO.SPEC_MAIN_ID, 
        PO.STOCK_ID, 
        E.QUANTITY, 
        PO.PO_RELATED_ID, 
        PO.START_DATE, 
        PO.FINISH_DATE, 
        PO.LOT_NO, 
        PO.WRK_ROW_ID, 
        PO.IS_STAGE
	FROM     
    	EZGI_IFLOW_PRODUCTION_ORDERS AS E INNER JOIN
        PRODUCTION_ORDERS AS PO ON E.LOT_NO = PO.LOT_NO INNER JOIN
        EZGI_DESIGN_PACKAGE_ROW AS EP ON PO.SPEC_MAIN_ID = EP.PACKAGE_SPECT_RELATED_ID
	WHERE  
    	E.IFLOW_P_ORDER_ID = #attributes.IFLOW_PRODUCTION_ORDER_ID# 
</cfquery>
<cfif Get_new_po.recordcount>
	<cftransaction>
    	<!---PRODUCTION ORDER EKLEME BAŞI--->
        
		<cfoutput query="Get_new_po"> <!---Master Paketleri Döndürüyorum--->
        
        	<!---Master Paketlerin Spect No ile Yakalayıp Bölünmüş Paketlerini Çoğaltıyorum.--->
        	<cfquery name="add_po" datasource="#dsn3#">
            	INSERT INTO 
                	PRODUCTION_ORDERS
                    (
                    	STOCK_ID, 
                        STATION_ID, 
                        START_DATE, 
                        FINISH_DATE, 
                        QUANTITY, 
                        STATUS_ID, 
                        STATUS, 
                        PROJECT_ID, 
                        P_ORDER_NO, 
                        PO_RELATED_ID, 
                        SPECT_VAR_NAME, 
                        DETAIL, 
                        PROD_ORDER_STAGE, 
                        IS_STOCK_RESERVED, 
                        IS_DEMONTAJ, 
                        LOT_NO, 
                        PRODUCTION_LEVEL, 
                        SPEC_MAIN_ID, 
                        PRODUCT_NAME2, 
                        IS_STAGE, 
                        WRK_ROW_ID, 
                        EXIT_DEP_ID, 
                        EXIT_LOC_ID, 
                        PRODUCTION_DEP_ID, 
                        PRODUCTION_LOC_ID, 
                        RECORD_IP, 
                        RECORD_EMP, 
                        RECORD_DATE, 
                        RESULT_AMOUNT, 
                        WRK_ROW_RELATION_ID
                    )
            	SELECT 
                	STOCK_ID, 
                    STATION_ID, 
                    '#Get_new_po.START_DATE#', 
                    '#Get_new_po.FINISH_DATE#', 
                    #Get_new_po.QUANTITY#, 
                    STATUS_ID, 
                    STATUS, 
                    PROJECT_ID, 
                    '00000000',
                    #Get_new_po.PO_RELATED_ID#, 
                    SPECT_VAR_NAME, 
                    DETAIL, 
                    PROD_ORDER_STAGE, 
                    IS_STOCK_RESERVED, 
                    IS_DEMONTAJ, 
                  	'#Get_new_po.LOT_NO#', 
                    PRODUCTION_LEVEL, 
                    SPEC_MAIN_ID, 
                    PRODUCT_NAME2, 
                    4, 
                   	'#Get_new_po.WRK_ROW_ID#'+RIGHT(WRK_ROW_ID, LEN(WRK_ROW_ID) - LEN(WRK_ROW_RELATION_ID)), 
                    EXIT_DEP_ID, 
                    EXIT_LOC_ID, 
                    PRODUCTION_DEP_ID, 
                    PRODUCTION_LOC_ID, 
                    '#cgi.remote_addr#',
                    #session.ep.userid#,
                    #now()#,
                  	0, 
                    '#Get_new_po.WRK_ROW_ID#'
				FROM     
                	PRODUCTION_ORDERS
				WHERE  
                	LOT_NO = '#attributes.LOT_NO#' AND 
                    WRK_ROW_RELATION_ID =
                      					(
                                        	SELECT 
                                            	WRK_ROW_ID
                       						FROM      
                                            	PRODUCTION_ORDERS AS PRODUCTION_ORDERS_1
                       						WHERE   
                                            	LOT_NO = '#attributes.LOT_NO#' AND 
                                                SPEC_MAIN_ID = #Get_new_po.SPEC_MAIN_ID#
                                     	)
            </cfquery>
            
            <cfquery name="upd_new_po" datasource="#DSN3#"> <!---Master Paketler VTS de tekrar bölünmesin diye update ediyorum--->
                UPDATE 
                    PRODUCTION_ORDERS
                SET          
                    WRK_ROW_RELATION_ID = WRK_ROW_ID
                WHERE  
                    WRK_ROW_ID  = '#Get_new_po.WRK_ROW_ID#'
          	</cfquery>
		</cfoutput>
        
        <!---Üretim Emir Noyu Alıyorum--->
        <cfquery name="get_paper" datasource="#dsn3#">
        	SELECT 
            	GENERAL_PAPERS_ID,
            	PROD_ORDER_NUMBER
			FROM     
            	GENERAL_PAPERS
			WHERE  
            	NOT (PROD_ORDER_NUMBER IS NULL)
      	</cfquery>
        <cfif not len(get_paper.PROD_ORDER_NUMBER)>
        	<script type="text/javascript">
				alert("Genel Belge Numaraları Sayfasında Üretim Emir No Tanımı Yapınız!");
				window.history.go(-1);
			</script>
			<cfabort>
        </cfif>
        <!---Üretim Emir No verilecek Yeni eklenen Üretim Emirlerini Buluyorum--->
        <cfquery name="get_not_paper_no" datasource="#dsn3#">
        	SELECT 
            	P_ORDER_ID
			FROM     
            	PRODUCTION_ORDERS
			WHERE  
            	P_ORDER_NO = '00000000'
          	ORDER BY
            	P_ORDER_ID
        </cfquery>
        <cfloop query="get_not_paper_no">
        	<cfset paper_number = get_paper.PROD_ORDER_NUMBER + 1>
            <!---Üretim Emir Noları Sırasıyla Veriyorum--->
            <cfquery name="upd_not_paper_no" datasource="#dsn3#">
            	UPDATE 
                	PRODUCTION_ORDERS
				SET          
                	P_ORDER_NO = '#paper_number#'
				WHERE  
                	P_ORDER_NO = '00000000' AND 
                    P_ORDER_ID = #get_not_paper_no.P_ORDER_ID#
            </cfquery>
        </cfloop>
      	<cfquery name="upd_paper" datasource="#dsn3#">
        	UPDATE 
            	GENERAL_PAPERS
			SET          
            	PROD_ORDER_NUMBER = #paper_number#
			WHERE  
            	GENERAL_PAPERS_ID = #get_paper.GENERAL_PAPERS_ID#
      	</cfquery>
        <!---PRODUCTION ORDER EKLEME SONU--->
        
        <!---PRODUCTION ORDER_STOCKS VE PRODUCTION_OPERATION EKLEME BAŞI--->
        
        <!---Yeni Bölünmüş ve Master Paketlerin Bilgisi Alınıyor--->
        <cfquery name="Get_new_pos" datasource="#dsn3#">
        	SELECT 
            	PO.LOT_NO, 
                PO.P_ORDER_ID, 
                PO.QUANTITY,
                PO.SPEC_MAIN_ID
			FROM     
            	PRODUCTION_ORDERS AS PO INNER JOIN
        		EZGI_DESIGN_PACKAGE_ROW AS EP ON PO.SPEC_MAIN_ID = EP.PACKAGE_SPECT_RELATED_ID
			WHERE  
            	PO.LOT_NO = '#Get_new_po.LOT_NO#'
		</cfquery>
		<cfoutput query="Get_new_pos"> <!---Yeni Bölünmüş ve Master Paketler Paketler Döndürülüyor.--->
        	<cfset attributes.ezg_row_id = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')# & #session.ep.company_id# & #Get_new_pos.currentrow#>
        	
			<!---Master Paketlerin Sarfları Siliniyor--->
        	<cfquery name="del_old_pos" datasource="#dsn3#">
        		DELETE FROM
                	PRODUCTION_ORDERS_STOCKS
             	WHERE
                 	P_ORDER_ID = #Get_new_pos.P_ORDER_ID#   
        	</cfquery>
            
            <!---Daha Önce Bölünmüş ve Master Paketlerin Sarfları Yeni Master ve Bölünmüş Paketlere İş Emri Miktarına Oranlayarak Ekleniyor --->
           	<cfquery name="add_new_pos" datasource="#dsn3#"> 
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
                        RECORD_DATE, 
                        RECORD_EMP, 
                        RECORD_IP, 
                        IS_PHANTOM, 
                        IS_SEVK, 
                        IS_PROPERTY, 
                        IS_FREE_AMOUNT, 
                        FIRE_AMOUNT, 
                        FIRE_RATE, 
                  		SPECT_MAIN_ROW_ID, 
                        IS_FLAG, 
                        WRK_ROW_ID, 
                        LINE_NUMBER
                	)
				SELECT 
                	#Get_new_pos.P_ORDER_ID#, 
                    POS.PRODUCT_ID, 
                    POS.STOCK_ID, 
                    POS.SPECT_MAIN_ID, 
                    POS.AMOUNT / PO.QUANTITY * #Get_new_pos.QUANTITY#, 
                    POS.TYPE, 
                    POS.PRODUCT_UNIT_ID, 
                    #now()#,
                    #session.ep.userid#,
                    '#cgi.remote_addr#',
                    POS.IS_PHANTOM, 
                    POS.IS_SEVK, 
                  	POS.IS_PROPERTY, 
                    POS.IS_FREE_AMOUNT, 
                    POS.FIRE_AMOUNT, 
                    POS.FIRE_RATE, 
                    POS.SPECT_MAIN_ROW_ID, 
                    POS.IS_FLAG, 
                    '#attributes.ezg_row_id#', 
                    POS.LINE_NUMBER
				FROM     
                	PRODUCTION_ORDERS_STOCKS AS POS INNER JOIN
                  	PRODUCTION_ORDERS AS PO ON POS.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
        			EZGI_DESIGN_PACKAGE_ROW AS EP ON PO.SPEC_MAIN_ID = EP.PACKAGE_SPECT_RELATED_ID
				WHERE  
                	PO.LOT_NO = '#attributes.LOT_NO#' AND 
                    PO.SPEC_MAIN_ID = #Get_new_pos.SPEC_MAIN_ID#
      		</cfquery>
            
            <!---Master Paketlerin Operasyonları Siliniyor--->
        	<cfquery name="del_old_pos" datasource="#dsn3#">
        		DELETE FROM
                	PRODUCTION_OPERATION
             	WHERE
                 	P_ORDER_ID = #Get_new_pos.P_ORDER_ID#   
        	</cfquery>
             <!---Daha Önce Bölünmüş ve Master Paketlerin Operasyonları Yeni Master ve Bölünmüş Paketlere İş Emri Miktarına Oranlayarak Ekleniyor --->
            <cfquery name="add_new_por" datasource="#dsn3#">
            	INSERT INTO 
                	PRODUCTION_OPERATION
                  	(
                    	P_ORDER_ID, 
                        AMOUNT, 
                        STATION_ID, 
                        OPERATION_TYPE_ID, 
                        STAGE, 
                        RECORD_EMP, 
                        RECORD_DATE, 
                        RECORD_IP,
                    	O_START_DATE, 
                    	O_FINISH_DATE    
                   	)
            	SELECT  
                	#Get_new_pos.P_ORDER_ID#,  
                    POO.AMOUNT / PO.QUANTITY * #Get_new_pos.QUANTITY#, 
                    POO.STATION_ID, 
                    POO.OPERATION_TYPE_ID, 
                    0 AS STAGE, 
                    #session.ep.userid#,
                    #now()#,
                    '#cgi.remote_addr#',
                    PO.START_DATE, 
                    PO.FINISH_DATE
				FROM     
                	PRODUCTION_OPERATION AS POO INNER JOIN
                  	PRODUCTION_ORDERS AS PO ON POO.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
        			EZGI_DESIGN_PACKAGE_ROW AS EP ON PO.SPEC_MAIN_ID = EP.PACKAGE_SPECT_RELATED_ID
				WHERE  
                	PO.LOT_NO = '#attributes.LOT_NO#' AND 
                    PO.SPEC_MAIN_ID = #Get_new_pos.SPEC_MAIN_ID#
        	</cfquery>
     	</cfoutput>
        <!---PRODUCTION ORDER_STOCKS VE PRODUCTION_OPERATION EKLEME SONU--->
    </cftransaction>
    <script type="text/javascript">
		alert("Eşitleme İşlemi Tamamlandı!");
		window.history.go(-1);
	</script>
<cfelse>
	<script type="text/javascript">
		alert("Master Paketler Bulunamdı!");
		window.history.go(-1);
	</script>
	<cfabort>
</cfif>