<cffunction name="get_pallets_" returntype="query">
	<cfargument name="dsn_alias" default="">
	<cfargument name="keyword" default="">
    <cfargument name="oby" default="">
	<cfargument name="process_status" default="">
    <cfargument name="collect_type" default="">
    <cfargument name="department_id" default="">
    <cfargument name="list_type" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_pallets" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (

                            SELECT  
                                O.PACKING_ID,
                                O.BARCODE,
                                O.RECORD_DATE,
                                O.UPDATE_DATE,
                                O.DETAIL,
								O.PROCESS_STATUS,
                                O.PACKING_SIZE_TYPE_ID,
                                <cfif isdefined('arguments.list_type') and arguments.list_type eq 2>
                                    ORR.SERIAL_NO,
                                    ORR.SPECT_MAIN_ID,
                                    ORR.STOCK_ID,
                                    ORR.AMOUNT,
                                    (SELECT PRODUCT_NAME FROM STOCKS WHERE STOCK_ID = ORR.STOCK_ID) AS PRODUCT_NAME,
                                </cfif>
                                (
                                	SELECT TOP (1) 
                                    	SHELF_SIZE_TYPE_CODE
									FROM     
                                    	EZGI_WM_SETUP_SHELF_SIZE_TYPE
									WHERE  
                                    	SHELF_SIZE_TYPE_ID = O.PACKING_SIZE_TYPE_ID
                                ) SHELF_SIZE_TYPE_CODE,
                                CAST(O.DEPARTMENT_ID AS VARCHAR) + '-' + CAST(O.LOCATION_ID AS VARCHAR) AS DEPO
                                
                            FROM 
                                EZGI_PACKING O
                                <cfif isdefined('arguments.list_type') and arguments.list_type eq 2>
                                	, EZGI_PACKING_ROW ORR
                                </cfif>
                            WHERE 
                            	(SELECT TOP (1) EZGI_PACKING_ACTION_TYPE_ID FROM EZGI_PACKING_ACTION WHERE PACKING_ID = O.PACKING_ID ORDER BY PROCESS_DATE DESC) = 1
                                <cfif isdefined('arguments.list_type') and arguments.list_type eq 2>
                                	AND O.PACKING_ID = ORR.PACKING_ID
                                </cfif>
                                <cfif isdefined('arguments.department_id') and Len(arguments.department_id)>
                                	AND O.PACKING_ID IN 
                                    					(
                                                        	SELECT 
                                                            	PACKING_ID
															FROM     
                                                            	EZGI_WM_PACKING_LAST_STATUS
															WHERE  
                                                            	DEPO = '#arguments.department_id#'
                                                      	)
                                </cfif>
								<cfif isdefined('arguments.collect_type') and len(arguments.collect_type)>
                                    AND O.PACKING_SIZE_TYPE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.collect_type#">
                                </cfif>
								<cfif len(arguments.process_status)>
                                    AND O.PROCESS_STATUS = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.process_status#">
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
                        ROW_NUMBER() OVER (	ORDER BY
                                            <cfif arguments.oby eq 1>
                                                SHELF_SIZE_TYPE_CODE
                                            <cfelseif arguments.oby eq 2>
                                                UPDATE_DATE
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
        	