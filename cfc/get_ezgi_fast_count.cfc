<cffunction name="get_fast_count_" returntype="query">
	<cfargument name="dsn_alias" default="">
	<cfargument name="keyword" default="">
    <cfargument name="list_type" default="">
    <cfargument name="shelf_type" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfargument name="department_id" default="">
    <cfquery name="get_fast_count" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (
        	<cfif isdefined('arguments.list_type') and arguments.list_type eq 2>
                SELECT        
                    EFC.EZGI_WM_FAST_COUNT_ID, 
                    EFC.PROCESS_DATE, 
                    EFC.PROCESS_NUMBER, 
                    EFC.PRODUCT_PLACE_ID, 
                    EFC.COUNT_TIME, 
                    EFC.PERIOD_ID, 
                    EFC.STOCK_FIS_ID, 
                    EWD.DEPO_NAME, 
                    PP.SHELF_CODE
                FROM            
                    EZGI_WM_FAST_COUNT AS EFC INNER JOIN
                    EZGI_WM_DEPARTMENTS AS EWD ON EFC.DEPARTMENT_ID = EWD.DEPARTMENT_ID AND EFC.LOCATION_ID = EWD.LOCATION_ID INNER JOIN
                    PRODUCT_PLACE AS PP ON EFC.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID
                WHERE
                    1=1
                    <cfif isdefined('arguments.department_id') and Len(arguments.department_id)>
                        AND EWD.DEPO = '#arguments.department_id#'
                    </cfif>
                    <cfif isdefined('arguments.keyword') and len(arguments.keyword)>
                        AND 
                            (
                                EFC.PROCESS_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%"> OR
                                PP.SHELF_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                            )
                    </cfif>
                    <cfif isdefined('arguments.shelf_type') and len(arguments.shelf_type)>
                        AND EFC.PRODUCT_PLACE_ID IN
                                                    (
                                                        SELECT 
                                                            PRODUCT_PLACE_ID
                                                        FROM     
                                                            EZGI_PRODUCT_PLACE
                                                        WHERE  
                                                            SHELF_TYPE = #arguments.shelf_type#
                                                    )
                    </cfif>
            
            <cfelse>
            	SELECT
                	EDM.DEPO_NAME, 
                    EDM.DEPO, 
                    PP.SHELF_SORT, 
                    PP.COLLECT_SORT,      
                	PP.SHELF_CODE, 
                    ISNULL(E.EZGI_COUNT_PERIOD_TIME, 1) AS EZGI_COUNT_PERIOD_TIME, 
                    TBL.GUN_FARKI,
                    TBL1.SAYI
				FROM            
            		PRODUCT_PLACE AS PP INNER JOIN
                 	EZGI_WM_SETUP_COUNT_PERIOD AS E ON PP.EZGI_COUNT_PERIOD_ID = E.EZGI_COUNT_PERIOD_ID INNER JOIN
               		EZGI_WM_DEPARTMENTS AS EDM ON PP.STORE_ID = EDM.DEPARTMENT_ID AND PP.LOCATION_ID = EDM.LOCATION_ID LEFT OUTER JOIN
                 	(
                    	SELECT        
                        	PRODUCT_PLACE_ID, 
                            ISNULL(MAX(DATEDIFF(DAY, PROCESS_DATE, GETDATE())), 0) AS GUN_FARKI
                      	FROM            
                        	EZGI_WM_FAST_COUNT
                     	GROUP BY PRODUCT_PLACE_ID
                 	) AS TBL ON ISNULL(E.EZGI_COUNT_PERIOD_TIME, 1) < ISNULL(TBL.GUN_FARKI, 0) AND PP.PRODUCT_PLACE_ID = TBL.PRODUCT_PLACE_ID INNER JOIN
                    (
                    	SELECT        
                        	EWL.SHELF_CODE,
                        	COUNT(*) AS SAYI
						FROM            
                        	EZGI_WM_SERIAL_NO_LAST_STATUS AS EWL INNER JOIN
                         	EZGI_WM_IS_SERIAL_NO_LIVE AS EL ON EWL.SERIAL_NO = EL.SERIAL_NO
                     	GROUP BY
							EWL.SHELF_CODE
                    ) AS TBL1 ON TBL1.SHELF_CODE = PP.SHELF_CODE
              	WHERE
             		TBL1.SAYI>0
                    <cfif isdefined('arguments.department_id') and Len(arguments.department_id)>
                        AND EDM.DEPO = '#arguments.department_id#'
                    </cfif>
                    <cfif isdefined('arguments.keyword') and len(arguments.keyword)>
                        AND PP.SHELF_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
                    </cfif>
                    <cfif isdefined('arguments.shelf_type') and len(arguments.shelf_type)>
                        AND PP.SHELF_TYPE = #arguments.shelf_type#
                    </cfif>
            </cfif>    
   		),
        CTE2 AS (
                    SELECT
                        CTE1.*,
                        ROW_NUMBER() OVER (	ORDER BY
                        						<cfif isdefined('arguments.list_type') and arguments.list_type eq 2>
                                                	PROCESS_DATE desc
                                                <cfelse>
                                                	GUN_FARKI,
                                                   	SHELF_SORT, 
                                                 	COLLECT_SORT
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
	<cfreturn get_fast_count>
</cffunction>
        	