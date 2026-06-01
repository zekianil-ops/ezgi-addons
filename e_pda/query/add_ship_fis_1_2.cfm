	<cfset get_stock_amount = 1>
	<cffunction name="get_stock_amount">
		<cfargument name="stock_id">
		<cfquery name="get_pro_stock" datasource="#DSN2#">
			SELECT
				SUM(SR.STOCK_IN - SR.STOCK_OUT) AS PRODUCT_STOCK
			FROM
				#dsn_alias#.DEPARTMENT D,
				#dsn3_alias#.PRODUCT P,
				#dsn3_alias#.STOCKS S,
				STOCKS_ROW SR
			WHERE
				P.PRODUCT_ID = S.PRODUCT_ID AND
				S.STOCK_ID = SR.STOCK_ID AND
				D.DEPARTMENT_ID = SR.STORE AND
				D.DEPARTMENT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.department_in#"> AND
				S.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#stock_id#">
			GROUP BY
				P.PRODUCT_ID, 
				S.STOCK_ID, 
				S.STOCK_CODE, 
				S.PROPERTY, 
				S.BARCOD, 
				D.DEPARTMENT_ID, 
				D.DEPARTMENT_HEAD
		</cfquery>
		<cfreturn get_pro_stock.product_stock>
	</cffunction>