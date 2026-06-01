<cffunction name="get_pallets_" returntype="query">
	<cfargument name="dsn_alias" default="">
	<cfargument name="keyword" default="">
    <cfargument name="oby" default="">
    <cfargument name="status" default="">
	<cfargument name="process_status" default="">
    <cfargument name="collect_type" default="">
    <cfargument name="list_type" default="">
    <cfargument name="shelf_type" default="">
    <cfargument name="member_name" default="">
    <cfargument name="company_id" default="">
    <cfargument name="consumer_id" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfargument name="product_name" default="">
    <cfargument name="product_id" default="">
    <cfargument name="stock_id" default="">
    <cfargument name="product_cat_code" default="">
    <cfargument name="product_cat" default="">
    <cfargument name="product_catid" default="">
    <cfargument name="spect_name" default="">
    <cfargument name="spect_main_id" default="">
    <cfargument name="department_id" default="">
    <cfquery name="get_pallets" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (

                            SELECT  
                            	ISNULL(O.IS_KARMA,0) AS IS_KARMA,
                                O.PACKING_ID,
                                O.BARCODE,
                                O.RECORD_DATE,
                                O.LOT_NO,
                                O.DETAIL,
				O.PROCESS_STATUS,
				ISNULL(O.IS_PRINT,0) AS IS_PRINT,
                                O.PACKING_SIZE_TYPE_ID,
                                (
                                	SELECT 
                                    	COUNT(*) AS SAYI
									FROM     
                                    	EZGI_PACKING_ROW AS EPR INNER JOIN
                  						EZGI_WM_IS_SERIAL_NO_LIVE AS ESL ON EPR.SERIAL_NO = ESL.SERIAL_NO
									WHERE  
                                    	EPR.PACKING_ID = O.PACKING_ID
                                )AS SAYI,
                                (
                                	SELECT
                                    	ORDER_ID
                                  	FROM
                                    	ORDERS WITH (NOLOCK)
                                 	WHERE
                                   		ORDER_ID = O.ORDER_ID 	      
                                ) AS ORDER_ID,
                                (
                                	SELECT TOP (1) 
                                    	SHELF_SIZE_TYPE_CODE
									FROM     
                                    	EZGI_WM_SETUP_SHELF_SIZE_TYPE WITH (NOLOCK)
									WHERE  
                                    	SHELF_SIZE_TYPE_ID = O.PACKING_SIZE_TYPE_ID
                                ) SHELF_SIZE_TYPE_CODE,
                                <cfif isdefined('arguments.list_type') and arguments.list_type eq 2>
                                	ORR.LOT_NO AS I_LOT_NO,	
                                    ORR.SERIAL_NO,
                                    ORR.SPECT_MAIN_ID,
                                    ORR.STOCK_ID,
                                    ORR.AMOUNT,
                                    (SELECT PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = ORR.STOCK_ID) AS PRODUCT_NAME,
                                    ISNULL((
                                    	SELECT top (1)
                                        	ORD.ORDER_ID
										FROM     
                                        	ORDERS AS ORD WITH (NOLOCK) INNER JOIN
                  							ORDER_ROW AS ORW WITH (NOLOCK) ON ORD.ORDER_ID = ORW.ORDER_ID INNER JOIN
                  							PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) ON ORW.ORDER_ROW_ID = POR.ORDER_ROW_ID INNER JOIN
                  							PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
										WHERE  
                                            PO.PRODUCTION_LEVEL = '0' AND 
                                            PO.LOT_NO = ORR.LOT_NO
                                    	
                                    ),0) AS D_ORDER_ID,
                                </cfif>
                                CASE
                                    WHEN O.COMPANY_ID IS NOT NULL THEN
                                       (
                                        SELECT     
                                            FULLNAME
                                        FROM         
                                            #dsn_alias#.COMPANY WITH (NOLOCK)
                                        WHERE     
                                            COMPANY_ID = O.COMPANY_ID
                                        )
                                    WHEN O.CONSUMER_ID IS NOT NULL THEN      
                                        (	
                                        SELECT     
                                            CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                                        FROM         
                                            #dsn_alias#.CONSUMER WITH (NOLOCK)
                                        WHERE     
                                            CONSUMER_ID = O.CONSUMER_ID
                                        )
                                END
                                    AS UNVAN,
                              	(SELECT ORDER_NUMBER FROM ORDERS WHERE ORDER_ID = O.ORDER_ID) AS ORDER_NUMBER,
                                (
                                	SELECT 
                                    	SHELF_CODE
									FROM     
                  						PRODUCT_PLACE WITH (NOLOCK) 
                                  	WHERE
                                    	PRODUCT_PLACE_ID = E.SHELF_NUMBER
                                ) AS SHELF_CODE,
                                E.DEPO
                            FROM 
                            	EZGI_PACKING AS O WITH (NOLOCK) LEFT OUTER JOIN
              					EZGI_WM_PACKING_LAST_STATUS AS E WITH (NOLOCK) ON O.PACKING_ID = E.PACKING_ID
                                <cfif isdefined('arguments.list_type') and arguments.list_type eq 2>
                                	, EZGI_PACKING_ROW ORR
                                </cfif>
                            WHERE 
                            	1=1
                                <cfif isdefined('arguments.list_type') and arguments.list_type eq 2>
                                	AND O.PACKING_ID = ORR.PACKING_ID
                                </cfif>
                                <cfif isdefined('arguments.department_id') and Len(arguments.department_id)>
                                	AND E.DEPO = '#arguments.department_id#'
                                </cfif>
								<cfif isdefined('arguments.collect_type') and len(arguments.collect_type)>
                                    AND O.PACKING_SIZE_TYPE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.collect_type#">
                                </cfif>
                                <cfif len(arguments.company_id) and len(arguments.member_name)>
                                    AND O.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.company_id#">
                                </cfif>
                                <cfif len(arguments.consumer_id) and len(arguments.member_name)>
                                    AND O.CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.consumer_id#">
                                </cfif>
                                <cfif isdefined('arguments.list_type') and arguments.list_type eq 2>
									<cfif len(arguments.stock_id) and len(arguments.product_name)>
                                        AND ORR.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stock_id#">
                                    </cfif>
                                    <cfif len(arguments.spect_main_id) and len(arguments.spect_name)>
                                        AND ORR.SPECT_MAIN_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.spect_main_id#">
                                    </cfif>
                                    <cfif len(arguments.product_cat) and len(arguments.product_cat_code)>
                                        AND ORR.STOCK_ID IN (SELECT STOCK_ID FROM STOCKS WHERE PRODUCT_CODE LIKE '#arguments.product_cat_code#%')
                                    </cfif>
                                </cfif>
                                <cfif arguments.status eq 2>
                                    AND O.STATUS = 1
                                <cfelseif arguments.status eq 3>
                                    AND O.STATUS = 0
                                </cfif>
								<cfif len(arguments.process_status)>
                                    AND O.PROCESS_STATUS = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_status#">
                                </cfif>
                                <cfif isdefined('arguments.keyword') and len(arguments.keyword)>
                                    AND 
                                    (
                                        O.BARCODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> OR
                                        (SELECT ORDER_NUMBER FROM ORDERS WHERE ORDER_ID = O.ORDER_ID) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> OR
                                        O.LOT_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                                        <cfif isdefined('arguments.list_type') and arguments.list_type eq 2> 
                                            OR ORR.LOT_NO LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> OR
                                            (SELECT PRODUCT_NAME FROM STOCKS WHERE STOCK_ID = ORR.STOCK_ID) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                                        </cfif>
                                    )
                                </cfif>
								<cfif isdefined('arguments.shelf_type') and len(arguments.shelf_type)>
                                	AND E.SHELF_NUMBER IN
                                    					(
                                                            SELECT 
                                                                PRODUCT_PLACE_ID
                                                            FROM     
                                                                EZGI_PRODUCT_PLACE
                                                            WHERE  
                                                                SHELF_TYPE = #arguments.shelf_type#
                                                    	)
                                </cfif>
                
   		),
        CTE2 AS (
                    SELECT
                        CTE1.*,
                        ROW_NUMBER() OVER (	ORDER BY
                                            <cfif arguments.oby eq 1>
                                                SHELF_SIZE_TYPE_CODE
                                            <cfelseif arguments.oby eq 2>
                                                RECORD_DATE
                                            <cfelse>
                                                PACKING_ID desc
                                            </cfif>
                                        ) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
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
	<cfreturn get_pallets>
</cffunction>
        	