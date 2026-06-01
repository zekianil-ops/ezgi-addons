<cfquery name="get_stage_default" datasource="#dsn3#">
 	SELECT VIRTUAL_OFFER_STAGES_1 FROM EZGI_VIRTUAL_OFFER_DEFAULTS
</cfquery>
<cfquery name="get_invoice_temp" datasource="#dsn3#">
	SELECT
    	*,
        CASE
       		WHEN O.COMPANY_ID IS NOT NULL THEN
                   (
                    SELECT     
                      	NICKNAME
					FROM         
                    	#dsn_alias#.COMPANY
					WHERE     
                   		COMPANY_ID = O.COMPANY_ID
                  	)
          	WHEN O.CONSUMER_ID IS NOT NULL THEN      
                   	(	
                  	SELECT     
                     	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
					FROM         
                      	#dsn_alias#.CONSUMER
					WHERE     
                		CONSUMER_ID = O.CONSUMER_ID
               		)
          	WHEN O.EMPLOYEE_ID IS NOT NULL THEN
                  	(
                   	SELECT     
                    	EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
					FROM         
                  		#dsn_alias#.EMPLOYEES
					WHERE     
                     	EMPLOYEE_ID = O.EMPLOYEE_ID
                 	)
   		END AS UNVAN
  	FROM
    	(
        	SELECT 
            	ISNULL((
                    SELECT     
                        TOP (1) RATE2
                    FROM        
                        EZGI_VIRTUAL_OFFER_MONEY
                    WHERE     
                        ACTION_ID = EVO.VIRTUAL_OFFER_ID AND 
                        MONEY_TYPE = EVOR.OTHER_MONEY
                 ),1) AS PRICE_RATE2,
            	ISNULL((
                    SELECT     
                        TOP (1) RATE2
                    FROM        
                        EZGI_VIRTUAL_OFFER_MONEY
                    WHERE     
                        ACTION_ID = EVO.VIRTUAL_OFFER_ID AND 
                        MONEY_TYPE = ISNULL(EVOR.COST_PRICE_MONEY,'#session.ep.money#')
                 ),1) AS COST_RATE2,
                 ISNULL((
                    SELECT     
                        TOP (1) RATE2
                    FROM        
                        EZGI_VIRTUAL_OFFER_MONEY
                    WHERE     
                        ACTION_ID = EVO.VIRTUAL_OFFER_ID AND 
                        MONEY_TYPE = ISNULL(EVOR.PURCHASE_PRICE_MONEY,'#session.ep.money#')
                 ),1) AS PURCHASE_RATE2,
                PC.PRODUCT_CATID,    
            	PC.PRODUCT_CAT, 
                EVOR.QUANTITY,
                EVOR.PRICE SALES_PRICE, 
                EVOR.TAX, 
                EVOR.DISCOUNT_1, 
                EVOR.DISCOUNT_2, 
                EVOR.DISCOUNT_3, 
                EVOR.DISCOUNT_COST, 
                EVOR.OTHER_MONEY, 
                EVOR.COST, 
                EVOR.COST_PRICE, 
                EVOR.COST_PRICE_MONEY, 
                EVOR.PURCHASE_PRICE, 
                EVOR.PURCHASE_PRICE_MONEY, 
                EVOR.PRODUCT_NAME,
                EVO.VIRTUAL_OFFER_ID,
                EVO.COMPANY_ID,
                EVO.CONSUMER_ID, 
                EVO.EMPLOYEE_ID,
                EVO.VIRTUAL_OFFER_DATE,
                EVO.VIRTUAL_OFFER_NUMBER 
			FROM        
            	EZGI_VIRTUAL_OFFER_ROW AS EVOR INNER JOIN
                STOCKS AS S ON EVOR.STOCK_ID = S.STOCK_ID INNER JOIN
                #dsn1_alias#.PRODUCT_CAT AS PC ON S.PRODUCT_CATID = PC.PRODUCT_CATID INNER JOIN
             	EZGI_VIRTUAL_OFFER AS EVO ON EVOR.VIRTUAL_OFFER_ID = EVO.VIRTUAL_OFFER_ID
			WHERE     
            	EVO.VIRTUAL_OFFER_STATUS = 1 AND 
                ISNULL(EVO.IS_CANCEL,0) = 0 AND 
                EVO.REVISION_ID IS NULL AND
                MONTH(EVO.VIRTUAL_OFFER_DATE) = #get_upd.MONTH_VALUE# AND 
              	YEAR(EVO.VIRTUAL_OFFER_DATE) = #get_upd.YEAR_VALUE# AND
              	EVO.BRANCH_ID = #get_upd.BRANCH_ID# 
                <cfif len(get_stage_default.VIRTUAL_OFFER_STAGES_1)>
                	AND EVO.VIRTUAL_OFFER_STAGE IN (#get_stage_default.VIRTUAL_OFFER_STAGES_1#)
                </cfif>
      	) AS O
	ORDER BY 
     	VIRTUAL_OFFER_ID DESC
</cfquery>