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
        	<cfif not len(arguments.ship_id)>
            SELECT 
            	UNVAN,
              	COMPANY_ID, 
                CONSUMER_ID,
              	SHELF_CODE, 
                SHIP_RESULT_ID, 
                DELIVER_PAPER_NO,
                IS_TYPE
                <cfif not len(arguments.ship_id)>
                        ,
                        ISNULL((
                        	SELECT 
                            	COUNT(*) AS CONTROL_AMOUNT
							FROM     
                            	EZGI_WM_SERIAL_NO_LAST_STATUS
							WHERE 
                            	SHIP_RESULT_TYPE = TBL.IS_TYPE AND 
                                ISNULL(IS_SHIPMENT_VERIFACTION,0)  = 1
							GROUP BY 
                            	SHIP_RESULT_ID
							HAVING 
                            	SHIP_RESULT_ID = TBL.SHIP_RESULT_ID
                        ),0) AS CONTROL_AMOUNT,
                        ISNULL((
                        	SELECT 
                            	COUNT(*) AS AMOUNT
							FROM     
                            	EZGI_WM_SERIAL_NO_LAST_STATUS
							WHERE 
                            	SHIP_RESULT_TYPE = TBL.IS_TYPE
							GROUP BY 
                            	SHIP_RESULT_ID
							HAVING 
                            	SHIP_RESULT_ID = TBL.SHIP_RESULT_ID
                        ),0) AS AMOUNT
         		</cfif>
           	FROM
                (
          	</cfif>
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
                    	EMS.SERIAL_NO, 
                        EMS.STOCK_ID, 
                        EMS.PRODUCT_PLACE_ID, 
                        EMS.DEPO, 
                        EMS.SPECT_ID, 
                        EMS.PALET_BARCODE, 
                        EMS.PRODUCT_NAME, 
                        EMS.IS_PROTOTYPE, 
                        EMS.SHELF_CODE, 
                        EMS.SHIP_RESULT_ID, 
                  		ISNULL(EMS.IS_SHIPMENT_VERIFACTION,0) IS_SHIPMENT_VERIFACTION, 
                        E.OUT_DATE, 
                        E.DELIVER_PAPER_NO, 
                        E.COMPANY_ID, 
                        E.PARTNER_ID, 
                        E.CONSUMER_ID,
                        '' AS DEPARTMENT_HEAD
                        <cfif not len(arguments.ship_id)>
                        ,
                        ISNULL((
                        	SELECT 
                            	COUNT(*) AS CONTROL_AMOUNT
							FROM     
                            	EZGI_WM_SERIAL_NO_LAST_STATUS
							WHERE 
                            	SHIP_RESULT_TYPE = 1 AND 
                                ISNULL(IS_SHIPMENT_VERIFACTION,0)  = 1
							GROUP BY 
                            	SHIP_RESULT_ID
							HAVING 
                            	SHIP_RESULT_ID = EMS.SHIP_RESULT_ID
                        ),0) AS CONTROL_AMOUNT,
                        ISNULL((
                        	SELECT 
                            	COUNT(*) AS AMOUNT
							FROM     
                            	EZGI_WM_SERIAL_NO_LAST_STATUS
							WHERE 
                            	SHIP_RESULT_TYPE = 1
							GROUP BY 
                            	SHIP_RESULT_ID
							HAVING 
                            	SHIP_RESULT_ID = EMS.SHIP_RESULT_ID
                        ),0) AS AMOUNT
                        </cfif>
					FROM     
                    	EZGI_WM_SERIAL_NO_LAST_STATUS AS EMS INNER JOIN
                  		EZGI_SHIP_RESULT AS E ON EMS.SHIP_RESULT_ID = E.SHIP_RESULT_ID
					WHERE  
                    	EMS.SHIP_RESULT_TYPE = 1 AND 
                        E.IS_TYPE = 1 
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
                            AND EMS.SHIP_RESULT_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ship_id#">
                      	</cfif>
                 	UNION ALL
                    SELECT 
                    	'' AS UNVAN,
                    	E.IS_TYPE,
                    	EMS.SERIAL_NO, 
                        EMS.STOCK_ID, 
                        EMS.PRODUCT_PLACE_ID, 
                        EMS.DEPO, 
                        EMS.SPECT_ID, 
                        EMS.PALET_BARCODE, 
                        EMS.PRODUCT_NAME, 
                        EMS.IS_PROTOTYPE, 
                        EMS.SHELF_CODE, 
                        EMS.SHIP_RESULT_ID, 
                  		ISNULL(EMS.IS_SHIPMENT_VERIFACTION,0) IS_SHIPMENT_VERIFACTION, 
                        E.OUT_DATE, 
                        CAST(E.SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) AS DELIVER_PAPER_NO, 
                        0 AS COMPANY_ID, 
                        0 AS PARTNER_ID, 
                        0 AS CONSUMER_ID,
                        D.DEPARTMENT_HEAD
                        <cfif not len(arguments.ship_id)>
                        ,
                        ISNULL((
                        	SELECT 
                            	COUNT(*) AS CONTROL_AMOUNT
							FROM     
                            	EZGI_WM_SERIAL_NO_LAST_STATUS
							WHERE 
                            	SHIP_RESULT_TYPE = 2 AND 
                                ISNULL(IS_SHIPMENT_VERIFACTION,0)  = 1
							GROUP BY 
                            	SHIP_RESULT_ID
							HAVING 
                            	SHIP_RESULT_ID = EMS.SHIP_RESULT_ID
                        ),0) AS CONTROL_AMOUNT,
                        ISNULL((
                        	SELECT 
                            	COUNT(*) AS AMOUNT
							FROM     
                            	EZGI_WM_SERIAL_NO_LAST_STATUS
							WHERE 
                            	SHIP_RESULT_TYPE = 2
							GROUP BY 
                            	SHIP_RESULT_ID
							HAVING 
                            	SHIP_RESULT_ID = EMS.SHIP_RESULT_ID
                        ),0) AS AMOUNT
                        </cfif>
					FROM     
                    	EZGI_WM_SERIAL_NO_LAST_STATUS AS EMS INNER JOIN
                  		EZGI_SHIP_RESULT_INTERNALDEMAND AS E ON EMS.SHIP_RESULT_ID = E.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                    	#dsn_alias#.DEPARTMENT AS D ON E.DEPARTMENT_IN_ID = D.DEPARTMENT_ID
					WHERE  
                    	EMS.SHIP_RESULT_TYPE = 2 AND 
                        E.IS_TYPE = 2 
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
                            AND EMS.SHIP_RESULT_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ship_id#">
                      	</cfif>
         	<cfif not len(arguments.ship_id)>
                ) AS TBL
          	GROUP BY
            	UNVAN,
            	COMPANY_ID, 
                CONSUMER_ID,
              	SHELF_CODE, 
                SHIP_RESULT_ID, 
                DELIVER_PAPER_NO,
                CONTROL_AMOUNT,
                AMOUNT,
                IS_TYPE
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
	</cfquery>
	<cfreturn get_shipment>
</cffunction>
        	