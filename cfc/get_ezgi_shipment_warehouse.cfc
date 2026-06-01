<cffunction name="get_shipment_" returntype="query">
	<cfargument name="dsn_alias" default="">
	<cfargument name="keyword" default="">
    <cfargument name="depo" default="">
    <cfargument name="date1" default="">
    <cfargument name="date2" default="">
    <cfargument name="is_type" default="">
    <cfargument name="ship_id" default="">
    <cfargument name="removel" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_shipment" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (

                	SELECT 
                    	CASE
                            WHEN E.COMPANY_ID IS NOT NULL THEN
                                (
                                SELECT     
                                    NICKNAME
                                    FROM         
                                        #dsn_alias#.COMPANY
                                    WHERE     
                                        COMPANY_ID = E.COMPANY_ID
                                )
                            WHEN E.CONSUMER_ID IS NOT NULL THEN      
                                (	
                                    SELECT     
                                        CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                                    FROM         
                                        #dsn_alias#.CONSUMER
                                    WHERE     
                                        CONSUMER_ID = E.CONSUMER_ID
                                )
                        END AS UNVAN,
                    	E.IS_TYPE,
                        (SELECT SHELF_CODE FROM PRODUCT_PLACE WHERE PRODUCT_PLACE_ID = E.SHIPMENT_PRODUCT_PLACE_ID) AS SHELF_CODE,
                        E.SHIP_RESULT_ID, 
                        E.OUT_DATE, 
                        E.DELIVER_PAPER_NO, 
                        E.COMPANY_ID, 
                        E.PARTNER_ID, 
                        E.CONSUMER_ID,
                        E.SHIPMENT_PRODUCT_PLACE_ID,
                        '' AS DEPARTMENT_HEAD,
                        ISNULL((
                       		SELECT 
                            	COUNT(*) AS AMOUNT
							FROM     
                            	EZGI_WM_SERIAL_NO_LAST_STATUS AS EV INNER JOIN
                                EZGI_WM_IS_SERIAL_NO_LIVE AS EL ON EV.SERIAL_NO = EL.SERIAL_NO
							WHERE 
                            	EV.SHIP_RESULT_TYPE = 1
							GROUP BY 
                            	EV.SHIP_RESULT_ID
							HAVING 
                            	EV.SHIP_RESULT_ID = E.SHIP_RESULT_ID        
                        ),0) AS AMOUNT,
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
                                    ESRR.SHIP_RESULT_ID = E.SHIP_RESULT_ID
                                ) AS TBL2
                            GROUP BY SEVK_DURUM
                            ) AS TBL3
                        ) AS SEVK_DURUM
					FROM     
                  		EZGI_SHIP_RESULT AS E
					WHERE  
                    	(
                        	SELECT 
                            	SUM(ORR.QUANTITY) AS ROW_AMOUNT
							FROM     
                            	EZGI_SHIP_RESULT_ROW AS ESRR INNER JOIN
                  				ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
							WHERE  
                            	ESRR.SHIP_RESULT_ID = E.SHIP_RESULT_ID
                      	) >0
						<cfif len(arguments.keyword) and  len(arguments.keyword) >
                            AND E.DELIVER_PAPER_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                        <cfelse>
                        	<cfif not len(arguments.removel)>
                        		AND ISNULL(E.SHIPMENT_PROCESS,0) = 0 
                            </cfif>
                            <cfif len(arguments.depo)>
                                AND E.DEPARTMENT_ID = #listgetat(arguments.depo,1,'-')# 
                                AND E.LOCATION_ID = #listgetat(arguments.depo,2,'-')#
                            </cfif>
                            <cfif len(arguments.date1) and  len(arguments.date2) >
                                AND E.OUT_DATE BETWEEN #arguments.date1# AND #arguments.date2#
                            </cfif>
                        </cfif>
                        <cfif len(arguments.ship_id) >
                            AND E.SHIP_RESULT_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ship_id#">
                      	</cfif>
                 	UNION ALL
                    SELECT 
                    	'' AS UNVAN,
                    	2 AS IS_TYPE,
                        (SELECT SHELF_CODE FROM PRODUCT_PLACE WHERE PRODUCT_PLACE_ID = E.SHIPMENT_PRODUCT_PLACE_ID) AS SHELF_CODE,
                        E.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID, 
                        E.OUT_DATE, 
                        CAST(E.SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) AS DELIVER_PAPER_NO, 
                        0 AS COMPANY_ID, 
                        0 AS PARTNER_ID, 
                        0 AS CONSUMER_ID,
                        E.SHIPMENT_PRODUCT_PLACE_ID,
                        D.DEPARTMENT_HEAD,
                        ISNULL((
                       		SELECT 
                            	COUNT(*) AS AMOUNT
							FROM     
                            	EZGI_WM_SERIAL_NO_LAST_STATUS AS EV INNER JOIN
                                EZGI_WM_IS_SERIAL_NO_LIVE AS EL ON EV.SERIAL_NO = EL.SERIAL_NO
							WHERE 
                            	EV.SHIP_RESULT_TYPE = 2
							GROUP BY 
                            	EV.SHIP_RESULT_ID
							HAVING 
                            	EV.SHIP_RESULT_ID = E.SHIP_RESULT_INTERNALDEMAND_ID        
                        ),0) AS AMOUNT,
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
                                    ESRR.SHIP_RESULT_INTERNALDEMAND_ID = E.SHIP_RESULT_INTERNALDEMAND_ID
                                ) AS TBL2
                            GROUP BY SEVK_DURUM
                            ) AS TBL3
                        ) AS SEVK_DURUM
					FROM     
                  		EZGI_SHIP_RESULT_INTERNALDEMAND AS E INNER JOIN
                    	#dsn_alias#.DEPARTMENT AS D ON E.DEPARTMENT_IN_ID = D.DEPARTMENT_ID
					WHERE  
                    	(
                        	SELECT 
                            	SUM(ORR.QUANTITY) AS ROW_AMOUNT
							FROM     
                            	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR INNER JOIN
                  				ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
							WHERE  
                            	ESRR.SHIP_RESULT_INTERNALDEMAND_ID = E.SHIP_RESULT_INTERNALDEMAND_ID
                      	) >0
						<cfif len(arguments.keyword) and  len(arguments.keyword) >
                            AND CAST(E.SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                        <cfelse>
                        	<cfif not len(arguments.removel)>
                        		AND ISNULL(E.SHIPMENT_PROCESS,0) = 0 
                            </cfif>
                            <cfif len(arguments.depo)>
                                AND E.DEPARTMENT_ID = #listgetat(arguments.depo,1,'-')# 
                                AND E.LOCATION_ID = #listgetat(arguments.depo,2,'-')#
                            </cfif>
                            <cfif len(arguments.date1) and  len(arguments.date2) >
                                AND E.OUT_DATE BETWEEN #arguments.date1# AND #arguments.date2#
                            </cfif>
                        </cfif>
                        <cfif len(arguments.ship_id) >
                            AND E.SHIP_RESULT_INTERNALDEMAND_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ship_id#">
                      	</cfif>
         				
   		),
        CTE2 AS (
                    SELECT
                        CTE1.*,
                        ROW_NUMBER() OVER (	ORDER BY UNVAN, DELIVER_PAPER_NO) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
                    FROM
                        CTE1
				)
      	SELECT

			CTE2.*
		FROM
			CTE2
      	ORDER BY
        	SHIPMENT_PRODUCT_PLACE_ID desc,
            DELIVER_PAPER_NO desc
	</cfquery>
	<cfreturn get_shipment>
</cffunction>
        	