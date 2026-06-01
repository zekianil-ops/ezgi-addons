<cffunction name="get_pallets_" returntype="query">
	<cfargument name="dsn_alias" default="">
	<cfargument name="keyword" default="">
    <cfargument name="collect_type" default="">
    <cfargument name="depo" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_pallets" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (
			SELECT 
            	EWM.PRODUCT_PLACE_ID, 
                EWM.SHELF_CODE, 
                EWM.MAX_STOCK, 
                EWM.MIN_STOCK, 
                EWM.STOCK_ID, 
                EWM.READY_AMOUNT, 
                EWM.PLACE_STATUS, 
                EWM.PRODUCT_NAME, 
                EPL.BARCODE, 
                EWM.SHELF_SIZE_TYPE, 
                EPP.SHELF_CODE AS NEW_SHELF_CODE, 
                EPL.AMOUNT, 
                EPL.AMOUNT + EWM.READY_AMOUNT AS NEW_AMOUNT, 
                EPL.PACKING_SIZE_TYPE_CODE, 
                EPL.SHELF_SIZE_TYPE_ID, 
                EPL.STATUS, 
                EPL.EZGI_PACKING_ACTION_TYPE_ID,
                EWS.SHELF_SIZE_TYPE_CODE
			FROM     
            	EZGI_PRODUCT_PLACE AS EPP INNER JOIN
                EZGI_WM_PACKING_LAST_STATUS AS EPL ON EPP.PRODUCT_PLACE_ID = EPL.SHELF_NUMBER INNER JOIN
                EZGI_WM_COLLECT_SHELF_STATUS AS EWM ON EPL.STOCK_ID = EWM.STOCK_ID INNER JOIN
              	EZGI_WM_SETUP_SHELF_SIZE_TYPE AS EWS ON EWM.SHELF_SIZE_TYPE = EWS.SHELF_SIZE_TYPE_ID
			WHERE  
            	EWM.DEPO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.depo#"> AND 
                EWM.MIN_STOCK >= EWM.READY_AMOUNT
                <cfif isdefined('arguments.collect_type') and len(arguments.collect_type)>
                 	AND  EWM.SHELF_SIZE_TYPE = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.collect_type#">
          		</cfif>
            	<cfif isdefined('arguments.keyword') and len(arguments.keyword)>
                 	AND 
               		(
                     	O.BARCODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                	)
        		</cfif>
   		),
        CTE2 AS (
                    SELECT
                        CTE1.*,
                        ROW_NUMBER() OVER (	ORDER BY EZGI_PACKING_ACTION_TYPE_ID, NEW_SHELF_CODE) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
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
        	