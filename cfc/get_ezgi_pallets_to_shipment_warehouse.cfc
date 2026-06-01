<cffunction name="get_shipment_" returntype="query">
	<cfargument name="dsn_alias" default="">
	<cfargument name="keyword" default="">
    <cfargument name="depo" default="">
    <cfargument name="date1" default="">
    <cfargument name="date2" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_shipment" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (
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
                END
                    AS UNVAN
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
                    ) AS SEVK_DURUM,
                    (
                    	SELECT 
                        	SHELF_CODE
						FROM     
                        	EZGI_PRODUCT_PLACE
						WHERE  
                        	PRODUCT_PLACE_ID = ESR.SHIPMENT_PRODUCT_PLACE_ID
                    ) AS SHELF_CODE
                FROM       	
                    EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
                    #dsn_alias#.SHIP_METHOD AS SM WITH (NOLOCK) ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID INNER JOIN
                    #dsn_alias#.EMPLOYEES AS E WITH (NOLOCK) ON ESR.DELIVER_EMP = E.EMPLOYEE_ID INNER JOIN
                    #dsn_alias#.DEPARTMENT AS D WITH (NOLOCK) ON ESR.DEPARTMENT_ID = D.DEPARTMENT_ID
                WHERE 
                    IS_TYPE = 1
                    <cfif len(arguments.keyword) and  len(arguments.keyword) >
                        AND ESR.DELIVER_PAPER_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                    <cfelse>
                        <cfif len(arguments.depo)>
                            AND ESR.DEPARTMENT_ID = #listgetat(arguments.depo,1,'-')# 
                            AND ESR.LOCATION_ID = #listgetat(arguments.depo,2,'-')#
                        </cfif>
                        <cfif len(arguments.date1) and  len(arguments.date2) >
                            AND ESR.OUT_DATE BETWEEN #arguments.date1# AND #arguments.date2#
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
                    ESR.DEPARTMENT_ID, 
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
                    ) AS SEVK_DURUM,
                    (
                    	SELECT 
                        	SHELF_CODE
						FROM     
                        	EZGI_PRODUCT_PLACE
						WHERE  
                        	PRODUCT_PLACE_ID = ESR.SHIPMENT_PRODUCT_PLACE_ID
                    ) AS SHELF_CODE
                FROM       	
                    EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
                    #dsn_alias#.SHIP_METHOD AS SM WITH (NOLOCK) ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID INNER JOIN
                    #dsn_alias#.EMPLOYEES AS E WITH (NOLOCK) ON ESR.DELIVER_EMP = E.EMPLOYEE_ID INNER JOIN
                    #dsn_alias#.DEPARTMENT AS D WITH (NOLOCK) ON ESR.DEPARTMENT_IN_ID = D.DEPARTMENT_ID
                WHERE 
                    IS_TYPE = 2
                    <cfif len(arguments.keyword) and  len(arguments.keyword) >
                        AND CAST(ESR.SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                    <cfelse>
                        <cfif len(arguments.depo)>
                            AND ESR.DEPARTMENT_ID = #listgetat(arguments.depo,1,'-')# 
                            AND ESR.LOCATION_ID = #listgetat(arguments.depo,2,'-')#
                        </cfif>
                        <cfif len(arguments.date1) and  len(arguments.date2) >
                            AND ESR.OUT_DATE BETWEEN #arguments.date1# AND #arguments.date2#
                        </cfif>
                    </cfif>
                ) AS TBL
            WHERE
                AMOUNT > 0 AND
                SEVK_DURUM = 1
   		),
        CTE2 AS (
                    SELECT
                        CTE1.*,
                        ROW_NUMBER() OVER (	ORDER BY IS_TYPE,UNVAN, SHIP_FIS_NO) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
                    FROM
                        CTE1
				)
      	SELECT

			CTE2.*
		FROM
			CTE2
		WHERE
			RowNum BETWEEN #startrow# and #startrow#+(#maxrows#-1)
	</cfquery>
	<cfreturn get_shipment>
</cffunction>
        	