<cffunction name="get_orders_" returntype="query">
	<cfargument name="dsn_alias" default="">
	<cfargument name="keyword" default="">
    <cfargument name="depo" default="">
    <cfargument name="date1" default="">
    <cfargument name="date2" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_orders" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (
            SELECT 
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
                  	WHEN 
                    	O.CONSUMER_ID IS NOT NULL THEN
                      	(
                        	SELECT 
                            	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                       		FROM      
                            	#dsn_alias#.CONSUMER
                       		WHERE   CONSUMER_ID = O.CONSUMER_ID
                     	) 
         		END AS UNVAN, 
             	O.ORDER_ID, 
                O.ORDER_NUMBER, 
                O.ORDER_DATE, 
                O.COMPANY_ID, 
                O.CONSUMER_ID
			FROM     
            	ORDERS AS O INNER JOIN
                (
                	SELECT DISTINCT 
                    	ORDER_ID
                 	FROM      
                    	ORDER_ROW
                  	WHERE   
                    	NOT (ORDER_ROW_CURRENCY IN (- 3, - 8, - 9, - 10))
             	) AS TBL ON O.ORDER_ID = TBL.ORDER_ID
			WHERE  
            	O.ORDER_STATUS = 1 AND 
                O.PURCHASE_SALES = 1 AND 
                O.RESERVED = 1
                <cfif len(arguments.keyword) and  len(arguments.keyword) >
                 	 AND O.ORDER_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
             	<cfelse>      
                	<cfif len(arguments.date1) and  len(arguments.date2) >
                     	AND O.ORDER_DATE BETWEEN #arguments.date1# AND #arguments.date2#
                 	</cfif>
             	</cfif>
   		),
        CTE2 AS (
                    SELECT
                        CTE1.*,
                        ROW_NUMBER() OVER (	ORDER BY ORDER_NUMBER) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
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
	<cfreturn get_orders>
</cffunction>
        	