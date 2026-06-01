<!---
    File: add_ambar_fis_shipping_control_include.cfm
    Folder: Add_Ons\ezgi\e-pda\query
    Author: Ezgi Yazılım
    Date: 01/10/2024
    Description:
--->
<cfif attributes.is_type eq 1>
    <cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn2#">
        SELECT     
        	PAKET_SAYISI AS PAKETSAYISI, 
            PAKET_ID AS STOCK_ID, 
            BARCOD, 
            STOCK_CODE, 
            PRODUCT_ID,
            PRODUCT_NAME,
            SPECT_MAIN_ID,
         	ISNULL((
            		SELECT 
                  		SUM(CONTROL_AMOUNT) CONTROL_AMOUNT
                   	FROM
                     	( 
                       	SELECT        
                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                        FROM   
                                   
                            STOCK_FIS AS SF INNER JOIN
                            STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                            #dsn3_alias#.SPECTS AS SP ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                            #dsn3_alias#.STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                        WHERE        
                            SF.FIS_TYPE = 113 AND 
                            SF.REF_NO = '#attributes.ref_no#' AND 
                            SFR.STOCK_ID = TBL.PAKET_ID AND
                            ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                            ISNULL(S.IS_PROTOTYPE,0) = 1
                        UNION ALL
                        SELECT        
                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                        FROM   
                            STOCK_FIS AS SF INNER JOIN
                            STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                            #dsn3_alias#.STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                        WHERE        
                            SF.FIS_TYPE = 113 AND 
                            SF.REF_NO = '#attributes.ref_no#' AND 
                            SFR.STOCK_ID = TBL.PAKET_ID AND
                            ISNULL(S.IS_PROTOTYPE,0) = 0
                		) AS TBL_5
        	),0) AS CONTROL_AMOUNT,
            SHIP_RESULT_ID
		FROM         
        	(
            SELECT
            	SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                PAKET_ID, 
                PRODUCT_ID,
                BARCOD, 
                STOCK_CODE, 
                PRODUCT_NAME, 
                SHIP_RESULT_ID,
                SPECT_MAIN_ID
           	FROM
            	(     
                SELECT     
                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_ID, 
                    ESR.SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID,
                    0 AS SPECT_MAIN_ID
                FROM          
                 	#dsn3_alias#.STOCKS AS S1 INNER JOIN
                 	#dsn3_alias#.EZGI_SHIP_RESULT AS ESR INNER JOIN
                  	#dsn3_alias#.EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                  	#dsn3_alias#.ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
                  	#dsn3_alias#.STOCKS AS S INNER JOIN
                 	#dsn3_alias#.EZGI_PAKET_SAYISI AS EPS ON S.STOCK_ID = EPS.PAKET_ID ON S1.STOCK_ID = EPS.MODUL_ID
                WHERE      
                    ESR.SHIP_RESULT_ID = #attributes.ship_id# AND
                    ISNULL(S1.IS_PROTOTYPE,0) = 0
                GROUP BY 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_ID, 
                    ESR.SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID
              	UNION ALL
                SELECT
                	SUM(ORR.QUANTITY) AS PAKET_SAYISI, 
                    S1.STOCK_ID AS PAKET_ID,
                    S1.BARCOD,
                    S1.STOCK_CODE,
                    S1.PRODUCT_NAME,
                    S1.PRODUCT_ID,
                	ESR.SHIP_RESULT_ID, 
                    ESRR.ORDER_ROW_ID, 
                    SP.SPECT_MAIN_ID
				FROM            
                	#dsn3_alias#.SPECTS AS SP INNER JOIN
                    #dsn3_alias#.EZGI_SHIP_RESULT AS ESR INNER JOIN
                    #dsn3_alias#.EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                    #dsn3_alias#.ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                    #dsn3_alias#.STOCKS AS S1 ON ORR.STOCK_ID = S1.STOCK_ID
				WHERE        
                	ESR.SHIP_RESULT_ID = #attributes.ship_id# AND 
                    ISNULL(S1.IS_PROTOTYPE, 0) = 1
				GROUP BY 
                	S1.STOCK_ID,
                	SP.SPECT_MAIN_ID, 
                    ESR.SHIP_RESULT_ID, 
                    ESRR.ORDER_ROW_ID, 
                    S1.STOCK_CODE, 
                    S1.PRODUCT_NAME,
                    S1.PRODUCT_ID, 
                    S1.BARCOD
             	) AS TBL1
          	GROUP BY
            	PAKET_ID, 
                BARCOD, 
                PRODUCT_ID,
                STOCK_CODE, 
                PRODUCT_NAME, 
                SHIP_RESULT_ID,
                SPECT_MAIN_ID
        	) AS TBL
		ORDER BY
			PRODUCT_NAME
  	</cfquery>
<cfelse>
   	<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn2#">
    	SELECT     
        	PAKET_SAYISI AS PAKETSAYISI, 
            PAKET_ID AS STOCK_ID, 
            BARCOD, 
            STOCK_CODE, 
            PRODUCT_ID,
            PRODUCT_NAME,
            SPECT_MAIN_ID,
         	ISNULL((
            		SELECT 
                  		SUM(CONTROL_AMOUNT) CONTROL_AMOUNT
                   	FROM
                     	( 
                       	SELECT        
                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                        FROM   
                                   
                            STOCK_FIS AS SF INNER JOIN
                            STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                            #dsn3_alias#.SPECTS AS SP ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                            #dsn3_alias#.STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                        WHERE        
                            SF.FIS_TYPE = 113 AND 
                            SF.REF_NO = '#attributes.ref_no#' AND 
                            SFR.STOCK_ID = TBL.PAKET_ID AND
                            ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                            ISNULL(S.IS_PROTOTYPE,0) = 1
                        UNION ALL
                        SELECT        
                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                        FROM   
                            STOCK_FIS AS SF INNER JOIN
                            STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                            #dsn3_alias#.STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                        WHERE        
                            SF.FIS_TYPE = 113 AND 
                            SF.REF_NO = '#attributes.ref_no#' AND 
                            SFR.STOCK_ID = TBL.PAKET_ID AND
                            ISNULL(S.IS_PROTOTYPE,0) = 0
                		) AS TBL_5
        	),0) AS CONTROL_AMOUNT,
            SHIP_RESULT_ID
		FROM         
        	(
            SELECT
            	SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                PAKET_ID, 
                PRODUCT_ID,
                BARCOD, 
                STOCK_CODE, 
                PRODUCT_NAME, 
                SHIP_RESULT_ID,
                SPECT_MAIN_ID
           	FROM
            	( 
                SELECT     
                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_ID, 
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID  AS SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID,
                    0 AS SPECT_MAIN_ID
                FROM          
                 	#dsn3_alias#.STOCKS AS S1 INNER JOIN
                 	#dsn3_alias#.EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                  	#dsn3_alias#.EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                  	#dsn3_alias#.ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
                  	#dsn3_alias#.STOCKS AS S INNER JOIN
                 	#dsn3_alias#.EZGI_PAKET_SAYISI AS EPS ON S.STOCK_ID = EPS.PAKET_ID ON S1.STOCK_ID = EPS.MODUL_ID
                WHERE      
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
                    ISNULL(S1.IS_PROTOTYPE,0) = 0
                GROUP BY 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_ID, 
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                    ESRR.ORDER_ROW_ID
              	UNION ALL
                SELECT
                	SUM(ORR.QUANTITY) AS PAKET_SAYISI, 
                    S1.STOCK_ID AS PAKET_ID,
                    S1.BARCOD,
                    S1.STOCK_CODE,
                    S1.PRODUCT_NAME,
                    S1.PRODUCT_ID,
                	ESR.SHIP_RESULT_INTERNALDEMAND_ID   AS SHIP_RESULT_ID, 
                    ESRR.ORDER_ROW_ID, 
                    SP.SPECT_MAIN_ID
				FROM            
                	#dsn3_alias#.SPECTS AS SP INNER JOIN
                    #dsn3_alias#.EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                    #dsn3_alias#.EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                    #dsn3_alias#.ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                    #dsn3_alias#.STOCKS AS S1 ON ORR.STOCK_ID = S1.STOCK_ID
				WHERE        
                	ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND 
                    ISNULL(S1.IS_PROTOTYPE, 0) = 1
				GROUP BY 
                	S1.STOCK_ID,
                	SP.SPECT_MAIN_ID, 
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID, 
                    ESRR.ORDER_ROW_ID, 
                    S1.STOCK_CODE, 
                    S1.PRODUCT_NAME,
                    S1.PRODUCT_ID, 
                    S1.BARCOD
             	) AS TBL1
          	GROUP BY
            	PAKET_ID, 
                BARCOD, 
                PRODUCT_ID,
                STOCK_CODE, 
                PRODUCT_NAME, 
                SHIP_RESULT_ID,
                SPECT_MAIN_ID
        	) AS TBL
		ORDER BY
			PRODUCT_NAME
    </cfquery>
</cfif>
<cfif GET_SHIP_PACKAGE_LIST.recordcount>
	<cfquery name="DELETE_PACKAGE_LIST" datasource="#DSN2#">
		DELETE #dsn3_alias#.EZGI_SHIPPING_PACKAGE_LIST WHERE SHIPPING_ID = #attributes.SHIP_ID# AND TYPE = #attributes.is_type#
	</cfquery>
	<cfloop query="GET_SHIP_PACKAGE_LIST">
		<cfquery name="ADD_PACKAGE_LIST" datasource="#dsn2#">
			INSERT INTO 
                #dsn3_alias#.EZGI_SHIPPING_PACKAGE_LIST
                (
                    SHIPPING_ID,
                    STOCK_ID,
                    SPECT_MAIN_ID,
                    AMOUNT,
                    CONTROL_AMOUNT,
                    CONTROL_STATUS,
                    TYPE,
                    RECORD_DATE,
                    RECORD_EMP
                )
        	VALUES
                (
                    #attributes.SHIP_ID#,
                    #GET_SHIP_PACKAGE_LIST.STOCK_ID#,
                    #GET_SHIP_PACKAGE_LIST.SPECT_MAIN_ID#,
                    #GET_SHIP_PACKAGE_LIST.PAKETSAYISI#,
                    #GET_SHIP_PACKAGE_LIST.CONTROL_AMOUNT#,
                    2,
                    #attributes.is_type#,
                    #now()#,
                    #session.ep.userid#
                )
		</cfquery>
	</cfloop>
</cfif>
