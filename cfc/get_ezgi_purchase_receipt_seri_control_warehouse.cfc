<cffunction name="get_shipment_" returntype="query">
	<cfargument name="dsn_alias" default="">
	<cfargument name="keyword" default="">
    <cfargument name="date1" default="">
    <cfargument name="date2" default="">
    <cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_shipment" datasource="#this.DSN3#">
		WITH CTE1 AS 
        (
            SELECT
            	(SELECT NICKNAME FROM #dsn_alias#.COMPANY WHERE COMPANY_ID = SH.COMPANY_ID) AS UNVAN,     
            	SH.SHIP_ID, 
                E.OUR_COMPANY_ID, 
                SH.COMPANY_ID, 
                SH.PARTNER_ID, 
                SH.DEPARTMENT_IN, 
                SH.LOCATION_IN, 
                SH.SHIP_NUMBER, 
                SH.SHIP_TYPE, 
                SH.SHIP_DATE, 
                SH.IS_DELIVERED
			FROM            
            	#dsn2_alias#.SHIP AS SH INNER JOIN
             	#dsn_alias#.EZGI_COMPANY_OUR_COMPANY_RELATED AS E ON SH.COMPANY_ID = E.COMPANY_ID
			WHERE        
            	SH.PURCHASE_SALES = 0 AND 
                SH.SHIP_STATUS = 1 AND 
               	ISNULL(SH.IS_DELIVERED, 0) = 0
                <cfif len(arguments.keyword) and  len(arguments.keyword) >
                	AND SH.SHIP_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keyword#%">
           		<cfelse>
               		<cfif len(arguments.date1) and  len(arguments.date2) >
                     	AND SH.SHIP_DATE BETWEEN #arguments.date1# AND #arguments.date2#
                	</cfif>
           		</cfif>
   		),
        CTE2 AS (
                    SELECT
                        CTE1.*,
                        ROW_NUMBER() OVER (	ORDER BY SHIP_DATE) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
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
        	