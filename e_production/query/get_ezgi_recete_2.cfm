<!---
    File: get_ezgi_recete_2.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_recete" datasource="#DSN3#">
	SELECT     
    	RECETE.SIRA, 
        RECETE.R_MAIN_SPEC_ID, 
        RECETE.STOCK_ID, 
        RECETE.MAIN_SPECT_ID, 
        RECETE.TOTAL, 
        ISNULL(STOCKS.IS_PRODUCTION,0) IS_PRODUCTION,
        STOCKS.STOCK_CODE, 
        STOCKS.PRODUCT_ID, 
        STOCKS.PRODUCT_NAME, 
        SPECT_MAIN.STOCK_ID AS R_STOCK_ID, 
        SPECT_MAIN.PRODUCT_ID AS R_PRODUCT_ID, 
       	STOCKS_1.STOCK_CODE AS R_STOCK_CODE, 
        STOCKS_1.PRODUCT_NAME AS R_PRODUCT_NAME,
    	(
        	SELECT     
            	TOP (1) WS_ID
          	FROM          
            	WORKSTATIONS_PRODUCTS WITH (NOLOCK)
          	WHERE      
            	STOCK_ID = SPECT_MAIN.STOCK_ID
       		ORDER BY 
            	WS_P_ID DESC
    	) AS R_WS_ID
	FROM         
    	(
			SELECT 
            	0 AS SIRA,
              	S0_SPECT_MAIN_ID AS R_MAIN_SPEC_ID, 
                S0_OPERATION_TYPE_ID AS OPERATION_TYPE_ID, 
                S0_STOCK_ID AS STOCK_ID, 
                S1_MAIN_SPECT_ID AS MAIN_SPECT_ID, 
                S0_AMOUNT AS TOTAL
         	FROM          
            	EZGI_RECETE2 
          	WHERE 
            	S0_SPECT_MAIN_ID =
             	<cfif isdefined('smid') and len(smid)>
          			#smid#
              	<cfelse>
                	<cfif isdefined('iid') and len(iid)>
                        (
                            SELECT     
                                TOP (1) SPECT_MAIN_ID
                            FROM          
                                SPECT_MAIN
                            WHERE      
                                STOCK_ID = #iid# AND 
                                SPECT_STATUS = 1
                            ORDER BY 
                                SPECT_MAIN_ID DESC
                        )
                   	</cfif>
              	</cfif> 
         	UNION ALL
        	SELECT  
          		1 AS SIRA,
             	S1_MAIN_SPECT_ID AS R_MAIN_SPEC_ID, 
             	S1_OPERATION_TYPE_ID AS OPERATION_TYPE_ID, 
              	S1_STOCK_ID AS STOCK_ID, 
              	S2_MAIN_SPECT_ID AS MAIN_SPECT_ID, 
           		S0_AMOUNT * S1_AMOUNT AS TOTAL
      		FROM         
            	EZGI_RECETE2 AS EZGI_RECETE_11 
        	WHERE 
           		S0_SPECT_MAIN_ID =
           		<cfif isdefined('smid') and len(smid)>
                	#smid#
             	<cfelse>
                	<cfif isdefined('iid') and len(iid)>
                  		(
                           		SELECT     
                                	TOP (1) SPECT_MAIN_ID
                              	FROM          
                                	SPECT_MAIN
                             	WHERE      
                                	STOCK_ID = #iid# AND 
                                    SPECT_STATUS = 1
                               	ORDER BY 
                                	SPECT_MAIN_ID DESC
                     	)
                 	</cfif>
           		</cfif> 
        	UNION ALL
            SELECT 
          		2 AS SIRA,
              	S2_MAIN_SPECT_ID AS R_MAIN_SPEC_ID, 
             	S2_OPERATION_TYPE_ID AS OPERATION_TYPE_ID, 
       			S2_STOCK_ID AS STOCK_ID, 
              	S3_MAIN_SPECT_ID AS MAIN_SPECT_ID, 
              	S0_AMOUNT * S1_AMOUNT * S2_AMOUNT AS TOTAL
         	FROM         
             	EZGI_RECETE2 AS EZGI_RECETE_12
         	WHERE 
           		S0_SPECT_MAIN_ID =
            	<cfif isdefined('smid') and len(smid)>
                	#smid#
              	<cfelse>
                	<cfif isdefined('iid') and len(iid)>
                    	(
                         	SELECT     
                             	TOP (1) SPECT_MAIN_ID
                          	FROM          
                            	SPECT_MAIN
                         	WHERE      
                           		STOCK_ID = #iid# AND 
                             	SPECT_STATUS = 1
                          	ORDER BY 
                            	SPECT_MAIN_ID DESC
                     	)
                   	</cfif>
              	</cfif> 
         	UNION ALL
         	SELECT  
           		3 AS SIRA,
          		S3_MAIN_SPECT_ID AS R_MAIN_SPEC_ID, 
              	S3_OPERATION_TYPE_ID AS OPERATION_TYPE_ID, 
              	S3_STOCK_ID AS STOCK_ID, 
              	S4_MAIN_SPECT_ID AS MAIN_SPECT_ID, 
             	S0_AMOUNT * S1_AMOUNT * S2_AMOUNT * S3_AMOUNT AS TOTAL
         	FROM         
           		EZGI_RECETE2 AS EZGI_RECETE_13
          	WHERE 
             	S0_SPECT_MAIN_ID =
             	<cfif isdefined('smid') and len(smid)>
                	#smid#
               	<cfelse>
                 	<cfif isdefined('iid') and len(iid)>
                     	(
                          	SELECT     
                             	TOP (1) SPECT_MAIN_ID
                           	FROM          
                             	SPECT_MAIN
                         	WHERE      
                            	STOCK_ID = #iid# AND 
                            	SPECT_STATUS = 1
                        	ORDER BY 
                           		SPECT_MAIN_ID DESC
                   		)
                  	</cfif>
               	</cfif> 
       		UNION ALL
         	SELECT  
           		4 AS SIRA,
          		S4_MAIN_SPECT_ID AS R_MAIN_SPEC_ID, 
              	S4_OPERATION_TYPE_ID AS OPERATION_TYPE_ID, 
              	S4_STOCK_ID AS STOCK_ID, 
              	S5_MAIN_SPECT_ID AS MAIN_SPECT_ID, 
             	S0_AMOUNT * S1_AMOUNT * S2_AMOUNT * S3_AMOUNT * S4_AMOUNT AS TOTAL
         	FROM         
           		EZGI_RECETE2 AS EZGI_RECETE_14
          	WHERE 
             	S0_SPECT_MAIN_ID =
             	<cfif isdefined('smid') and len(smid)>
                	#smid#
               	<cfelse>
                 	<cfif isdefined('iid') and len(iid)>
                     	(
                          	SELECT     
                             	TOP (1) SPECT_MAIN_ID
                           	FROM          
                             	SPECT_MAIN
                         	WHERE      
                            	STOCK_ID = #iid# AND 
                            	SPECT_STATUS = 1
                        	ORDER BY 
                           		SPECT_MAIN_ID DESC
                   		)
                  	</cfif>
               	</cfif>
       		UNION ALL
         	SELECT  
           		5 AS SIRA,
          		S5_MAIN_SPECT_ID AS R_MAIN_SPEC_ID, 
              	S5_OPERATION_TYPE_ID AS OPERATION_TYPE_ID, 
              	S5_STOCK_ID AS STOCK_ID, 
              	S6_MAIN_SPECT_ID AS MAIN_SPECT_ID, 
             	S0_AMOUNT * S1_AMOUNT * S2_AMOUNT * S3_AMOUNT * S4_AMOUNT * S5_AMOUNT AS TOTAL
         	FROM         
           		EZGI_RECETE2 AS EZGI_RECETE_15
          	WHERE 
             	S0_SPECT_MAIN_ID =
             	<cfif isdefined('smid') and len(smid)>
                	#smid#
               	<cfelse>
                 	<cfif isdefined('iid') and len(iid)>
                     	(
                          	SELECT     
                             	TOP (1) SPECT_MAIN_ID
                           	FROM          
                             	SPECT_MAIN
                         	WHERE      
                            	STOCK_ID = #iid# AND 
                            	SPECT_STATUS = 1
                        	ORDER BY 
                           		SPECT_MAIN_ID DESC
                   		)
                  	</cfif>
               	</cfif> 
      	) AS RECETE INNER JOIN
       	STOCKS ON RECETE.STOCK_ID = STOCKS.STOCK_ID INNER JOIN
      	SPECT_MAIN ON RECETE.R_MAIN_SPEC_ID = SPECT_MAIN.SPECT_MAIN_ID INNER JOIN
      	STOCKS AS STOCKS_1 ON SPECT_MAIN.STOCK_ID = STOCKS_1.STOCK_ID
	ORDER BY 
    	RECETE.SIRA  
</cfquery>
<!---<cfdump var="#get_recete#" expand="yes">--->
