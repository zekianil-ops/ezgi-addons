<!---
    File: get_shipping_ambar.cfm
    Folder: Add_Ons\ezgi\e-pda\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="GET_SEVK_FIS" datasource="#DSN3#">
	SELECT 
     	*,
    	CASE
       		WHEN TBL.COMPANY_ID IS NOT NULL THEN
          		(
                	SELECT     
                     	NICKNAME
                        FROM         
                            #dsn_alias#.COMPANY
                        WHERE     
                            COMPANY_ID = TBL.COMPANY_ID
        		)
        	WHEN TBL.CONSUMER_ID IS NOT NULL THEN      
          		(	
                        SELECT     
                            CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                        FROM         
                            #dsn_alias#.CONSUMER
                        WHERE     
                            CONSUMER_ID = TBL.CONSUMER_ID
          		)
   		END AS UNVAN
 	FROM
     	(
            SELECT     
                ESR.SHIP_RESULT_ID, 
                ESR.NOTE, 
                ESR.SHIP_FIS_NO, 
                ESR.DELIVER_PAPER_NO, 
                ESR.REFERENCE_NO, 
                ESR.DELIVERY_DATE, 
                ESR.DEPARTMENT_ID, 
                ESR.COMPANY_ID, 
                ESR.CONSUMER_ID, 
                ESR.OUT_DATE, 
                ESR.IS_TYPE, 
                ESR.LOCATION_ID, 
                ESR.SHIP_METHOD_TYPE, 
                SM.SHIP_METHOD, 
                E.EMPLOYEE_NAME, 
                E.EMPLOYEE_SURNAME, 
                D.DEPARTMENT_HEAD,
                (
                 SELECT     
                 	ISNULL(SUM(ORR.QUANTITY), 0) AS AMOUNT
				FROM         
                	EZGI_SHIP_RESULT_ROW AS ESRR INNER JOIN
                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                    ORDERS ON ORR.ORDER_ID = ORDERS.ORDER_ID
				WHERE     
                	ESRR.SHIP_RESULT_ID = ESR.SHIP_RESULT_ID 
                ) AS AMOUNT,
                (
                SELECT     
                	SUM(DURUM) AS DURUM
				FROM         
                	(
                    SELECT     
                    	DURUM
                  	FROM          
                    	(
                        SELECT     
                        	CASE 
                            	WHEN ORR.ORDER_ROW_CURRENCY = - 1 THEN 1 
                            	WHEN ORR.ORDER_ROW_CURRENCY = - 2 THEN 1 
                                WHEN ORR.ORDER_ROW_CURRENCY = - 3 THEN 2 
                                WHEN ORR.ORDER_ROW_CURRENCY = - 4 THEN 1 
                                WHEN ORR.ORDER_ROW_CURRENCY = - 5 THEN 1 
                                WHEN ORR.ORDER_ROW_CURRENCY = - 6 THEN 1 
                                WHEN ORR.ORDER_ROW_CURRENCY = - 7 THEN 1 
                                WHEN ORR.ORDER_ROW_CURRENCY = - 8 THEN 2 
                                WHEN ORR.ORDER_ROW_CURRENCY = - 9 THEN 2 
                                WHEN ORR.ORDER_ROW_CURRENCY = - 10 THEN 2 
                                WHEN O.RESERVED = 0 THEN 0 
                  			END AS DURUM
                     	FROM          
                        	EZGI_SHIP_RESULT_ROW AS ESRR INNER JOIN
                            ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                            ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID
                     	WHERE      
                        	ESRR.SHIP_RESULT_ID = ESR.SHIP_RESULT_ID
                     	) AS TBL2
                 	GROUP BY DURUM
                	) AS TBL3
                ) AS DURUM,
		(
                SELECT     
                	SUM(SEVK_DURUM) AS SEVK_DURUM
				FROM         
                	(
                    SELECT     
                    	SEVK_DURUM
                  	FROM          
                    	(
                        SELECT     
                        	CASE 
                            	WHEN ORR.ORDER_ROW_CURRENCY = - 6 THEN 1
                            	ELSE
                                	0
                  			END AS SEVK_DURUM
                     	FROM          
                        	EZGI_SHIP_RESULT_ROW AS ESRR INNER JOIN
                            ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                            ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID
                     	WHERE      
                        	ESRR.SHIP_RESULT_ID = ESR.SHIP_RESULT_ID
                     	) AS TBL2
                 	GROUP BY SEVK_DURUM
                	) AS TBL3
                ) AS SEVK_DURUM
            FROM       	
                EZGI_SHIP_RESULT AS ESR INNER JOIN
                #dsn_alias#.SHIP_METHOD AS SM ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID INNER JOIN
                #dsn_alias#.EMPLOYEES AS E ON ESR.DELIVER_EMP = E.EMPLOYEE_ID INNER JOIN
                #dsn_alias#.DEPARTMENT AS D ON ESR.DEPARTMENT_ID = D.DEPARTMENT_ID
            WHERE 
                IS_TYPE = 1
                <cfif len(attributes.keyword) and  len(attributes.keyword) >
                	AND ESR.DELIVER_PAPER_NO LIKE '%#attributes.keyword#%'
                <cfelse>
					<cfif len(attributes.department_in_id)>
                        AND ESR.DEPARTMENT_ID = #listgetat(attributes.department_in_id,1,'-')# 
                        AND ESR.LOCATION_ID = #listgetat(attributes.department_in_id,2,'-')#
                    </cfif>
                    <cfif len(attributes.date1) and  len(attributes.date2) >
                        AND ESR.OUT_DATE BETWEEN #attributes.date1# AND #attributes.date2#
                    </cfif>
                </cfif>
          	UNION ALL
            SELECT     
                ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID, 
                ESR.NOTE, 
                ESR.SHIP_FIS_NO, 
                CAST(ESR.SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) AS DELIVER_PAPER_NO,
                ESR.REFERENCE_NO, 
                ESR.DELIVERY_DATE, 
                ESR.DEPARTMENT_IN_ID, 
                0 AS COMPANY_ID, 
                0 AS CONSUMER_ID, 
                ESR.OUT_DATE, 
                ESR.IS_TYPE, 
                ESR.LOCATION_ID, 
                ESR.SHIP_METHOD_TYPE, 
                SM.SHIP_METHOD, 
                E.EMPLOYEE_NAME, 
                E.EMPLOYEE_SURNAME, 
                D.DEPARTMENT_HEAD,
                (
                 SELECT     
                 	ISNULL(SUM(ORR.QUANTITY), 0) AS AMOUNT
				FROM         
                	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR INNER JOIN
                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                    ORDERS ON ORR.ORDER_ID = ORDERS.ORDER_ID
				WHERE     
                	ESRR.SHIP_RESULT_INTERNALDEMAND_ID = ESR.SHIP_RESULT_INTERNALDEMAND_ID 
                ) AS AMOUNT,
				CASE
                 	WHEN (SH.SHIP_ID IS NOT NULL AND SH.IS_SHIP_IPTAL = 0) THEN 2
                	WHEN (SH.SHIP_ID IS NULL OR SH.IS_SHIP_IPTAL = 1) THEN 1
               	END AS DURUM,
				(
                SELECT     
                	SUM(SEVK_DURUM) AS SEVK_DURUM
				FROM         
                	(
                    SELECT     
                    	SEVK_DURUM
                  	FROM          
                    	(
                        SELECT     
                        	CASE 
                            	WHEN ORR.ORDER_ROW_CURRENCY = - 6 THEN 1
                            	ELSE
                                	0
                  			END AS SEVK_DURUM
                     	FROM          
                        	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR INNER JOIN
                            ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                            ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID
                     	WHERE      
                        	ESRR.SHIP_RESULT_INTERNALDEMAND_ID = ESR.SHIP_RESULT_INTERNALDEMAND_ID
                     	) AS TBL2
                 	GROUP BY SEVK_DURUM
                	) AS TBL3
                ) AS SEVK_DURUM
            FROM       	
                EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                #dsn_alias#.SHIP_METHOD AS SM ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID INNER JOIN
                #dsn_alias#.EMPLOYEES AS E ON ESR.DELIVER_EMP = E.EMPLOYEE_ID INNER JOIN
                #dsn_alias#.DEPARTMENT AS D ON ESR.DEPARTMENT_IN_ID = D.DEPARTMENT_ID LEFT JOIN
         		#dsn2_alias#.SHIP AS SH WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = SH.DISPATCH_SHIP_ID
            WHERE 
                IS_TYPE = 2
                <cfif len(attributes.keyword) and  len(attributes.keyword) >
                	AND CAST(ESR.SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) LIKE '%#attributes.keyword#%'
                <cfelse>
					<cfif len(attributes.department_in_id)>
                        AND ESR.DEPARTMENT_ID = #listgetat(attributes.department_in_id,1,'-')# 
                        AND ESR.LOCATION_ID = #listgetat(attributes.department_in_id,2,'-')#
                    </cfif>
                    <cfif len(attributes.date1) and  len(attributes.date2) >
                        AND ESR.OUT_DATE BETWEEN #attributes.date1# AND #attributes.date2#
                    </cfif>
                </cfif>
    	) AS TBL
 	WHERE
     	AMOUNT > 0 AND
     	SEVK_DURUM = 1
	ORDER BY
    	IS_TYPE,
     	UNVAN, 
     	SHIP_FIS_NO
</cfquery>
