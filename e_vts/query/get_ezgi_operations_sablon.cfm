<!---
    File: get_ezgi_operations_sablon.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 04/01/2025
    Description: Şablona bağlı operasyonları getirir
--->
<!--- Şablona bağlı P_ORDER_NO listesini bul --->
<cfquery name="get_sablon_p_order_no" datasource="#dsn3#">
	SELECT DISTINCT
		OERR.P_ORDER_NO
	FROM     
		EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS OERR INNER JOIN
		EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER ON OERR.OPTIMIZATION_RESULT_ID = OER.OPTIMIZATION_RESULT_ID
	WHERE  
		OER.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
		AND OERR.P_ORDER_NO IS NOT NULL
		AND OERR.P_ORDER_NO <> ''
</cfquery>

<cfif get_sablon_p_order_no.recordcount>
	<cfset p_order_no_list = ValueList(get_sablon_p_order_no.P_ORDER_NO)>
	
	<cfquery name="GET_PO_DET" datasource="#dsn3#">
		SELECT DISTINCT
			*
		FROM
			(
				SELECT 
					P_ORDER_ID, 
					PO_RELATED_ID, 
					LOT_NO, 
					P_ORDER_NO, 
					IS_STAGE, 
					START_DATE, 
					STOCK_ID, 
					CASE 
						WHEN 
							(SELECT ISNULL(IS_PROTOTYPE,0) AS IS_PROTOTYPE FROM STOCKS WHERE STOCK_ID = EZGI_OPERATION_M.STOCK_ID) = 0
						THEN 
							PRODUCT_NAME
					ELSE
						(
							SELECT        
								TOP (1) DESIGN_MAIN_NAME
							FROM            
								EZGI_DESIGN_MAIN_ROW
							WHERE        
								MAIN_SPECT_RELATED_ID = EZGI_OPERATION_M.SPEC_MAIN_ID
							ORDER BY 
								DESIGN_MAIN_ROW_ID DESC
							UNION ALL
							SELECT        
								TOP (1) PACKAGE_NAME
							FROM        
								EZGI_DESIGN_PACKAGE_ROW
							WHERE        
								PACKAGE_SPECT_RELATED_ID = EZGI_OPERATION_M.SPEC_MAIN_ID
							ORDER BY 
								PACKAGE_ROW_ID DESC
							UNION ALL
							SELECT        
								TOP (1) PIECE_NAME
							FROM            
								EZGI_DESIGN_PIECE_ROWS
							WHERE        
								PIECE_SPECT_RELATED_ID = EZGI_OPERATION_M.SPEC_MAIN_ID
							ORDER BY 
								PIECE_ROW_ID DESC
						)
					END	AS PRODUCT_NAME,
					PRODUCT_NAME AS NAME_PRODUCT,
					P_OPERATION_ID, 
					OPERATION_TYPE_ID, 
					OPERATION_CODE, 
					OPERATION_TYPE, 
					AMOUNT, 
					STAGE, 
					O_START_DATE,
					O_STATION_IP,
					ACTION_EMPLOYEE_ID, 
					ISNULL(sum(REAL_AMOUNT),0) REAL_AMOUNT, 
					ISNULL(sum(LOSS_AMOUNT),0) LOSS_AMOUNT, 
					ISNULL(OPERATION_GRUP_ID,0) AS OPERATION_GRUP_ID,
					ISNULL(
						(
						SELECT
							SUM(POR_.AMOUNT) ORDER_AMOUNT
						FROM
							PRODUCTION_ORDER_RESULTS_ROW POR_,
							PRODUCTION_ORDER_RESULTS POO
						WHERE
							POR_.PR_ORDER_ID = POO.PR_ORDER_ID
							AND POO.P_ORDER_ID = EZGI_OPERATION_M.P_ORDER_ID
							AND POR_.TYPE = 1
							AND POO.IS_STOCK_FIS = 1
						)
					,0) ROW_RESULT_AMOUNT,
					ISNULL(
						(
						SELECT
							COUNT(DISTINCT OERR.OPTIMIZATION_RESULT_ROW_ID)
						FROM
							EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS OERR INNER JOIN
							EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER ON OERR.OPTIMIZATION_RESULT_ID = OER.OPTIMIZATION_RESULT_ID
						WHERE
							OER.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
							AND OERR.P_ORDER_NO = EZGI_OPERATION_M.P_ORDER_NO
						)
					,0) AS SABLON_MIKTARI,
					ISNULL(
						(
						SELECT
							TOP 1 OERR.HEIGHT
						FROM
							EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS OERR INNER JOIN
							EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER ON OERR.OPTIMIZATION_RESULT_ID = OER.OPTIMIZATION_RESULT_ID
						WHERE
							OER.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
							AND OERR.P_ORDER_NO = EZGI_OPERATION_M.P_ORDER_NO
						)
					,0) AS PARCA_BOYU,
					ISNULL(
						(
						SELECT
							TOP 1 OERR.WIDTH
						FROM
							EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS OERR INNER JOIN
							EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER ON OERR.OPTIMIZATION_RESULT_ID = OER.OPTIMIZATION_RESULT_ID
						WHERE
							OER.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
							AND OERR.P_ORDER_NO = EZGI_OPERATION_M.P_ORDER_NO
						)
					,0) AS PARCA_ENI
				FROM         
					EZGI_OPERATION_M
				WHERE
					P_ORDER_ID NOT IN (SELECT P_ORDER_ID FROM EZGI_OPERATION_S) AND
					P_ORDER_NO IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#p_order_no_list#" list="true">) AND
					OPERATION_TYPE_ID IN
										(	
										SELECT     	
											OPERATION_TYPE_ID
										FROM      	
											WORKSTATIONS_PRODUCTS
										WHERE      	
											WS_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.station_id#"> AND 
											STOCK_ID IS NULL AND 
											OPERATION_TYPE_ID IS NOT NULL
										) AND 
					IS_STAGE IN (0,1,2,3,4)
				GROUP BY
					P_ORDER_ID, 
					PO_RELATED_ID, 
					LOT_NO, 
					P_ORDER_NO, 
					IS_STAGE, 
					START_DATE, 
					STOCK_ID, 
					PRODUCT_NAME, 
					P_OPERATION_ID, 
					OPERATION_TYPE_ID, 
					OPERATION_CODE, 
					OPERATION_TYPE, 
					AMOUNT, 
					STAGE, 
					O_START_DATE,
					O_STATION_IP,
					ACTION_EMPLOYEE_ID,
					OPERATION_GRUP_ID,
					SPEC_MAIN_ID
				UNION ALL
				SELECT
					P_ORDER_ID, 
					PO_RELATED_ID, 
					LOT_NO, 
					P_ORDER_NO, 
					IS_STAGE, 
					START_DATE, 
					STOCK_ID,
					PRODUCT_NAME, 
					PRODUCT_NAME AS NAME_PRODUCT, 
					P_OPERATION_ID, 
					OPERATION_TYPE_ID, 
					OPERATION_CODE, 
					OPERATION_TYPE, 
					AMOUNT, 
					STAGE, 
					O_START_DATE,
					O_STATION_IP,
					ACTION_EMPLOYEE_ID, 
					ISNULL(sum(REAL_AMOUNT),0) REAL_AMOUNT, 
					ISNULL(sum(LOSS_AMOUNT),0) LOSS_AMOUNT, 
					ISNULL(OPERATION_GRUP_ID,0) AS OPERATION_GRUP_ID,
					ISNULL(
						(
						SELECT
							SUM(POR_.AMOUNT) ORDER_AMOUNT
						FROM
							PRODUCTION_ORDER_RESULTS_ROW POR_,
							PRODUCTION_ORDER_RESULTS POO
						WHERE
							POR_.PR_ORDER_ID = POO.PR_ORDER_ID
							AND POO.P_ORDER_ID = EZGI_OPERATION_S.P_ORDER_ID
							AND POR_.TYPE = 1
							AND POO.IS_STOCK_FIS = 1
						)
					,0) ROW_RESULT_AMOUNT,
					ISNULL(
						(
						SELECT
							COUNT(DISTINCT OERR.OPTIMIZATION_RESULT_ROW_ID)
						FROM
							EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS OERR INNER JOIN
							EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER ON OERR.OPTIMIZATION_RESULT_ID = OER.OPTIMIZATION_RESULT_ID
						WHERE
							OER.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
							AND OERR.P_ORDER_NO = EZGI_OPERATION_S.P_ORDER_NO
						)
					,0) AS SABLON_MIKTARI,
					ISNULL(
						(
						SELECT
							TOP 1 OERR.HEIGHT
						FROM
							EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS OERR INNER JOIN
							EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER ON OERR.OPTIMIZATION_RESULT_ID = OER.OPTIMIZATION_RESULT_ID
						WHERE
							OER.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
							AND OERR.P_ORDER_NO = EZGI_OPERATION_S.P_ORDER_NO
						)
					,0) AS PARCA_BOYU,
					ISNULL(
						(
						SELECT
							TOP 1 OERR.WIDTH
						FROM
							EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS OERR INNER JOIN
							EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER ON OERR.OPTIMIZATION_RESULT_ID = OER.OPTIMIZATION_RESULT_ID
						WHERE
							OER.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
							AND OERR.P_ORDER_NO = EZGI_OPERATION_S.P_ORDER_NO
						)
					,0) AS PARCA_ENI
				FROM         
					EZGI_OPERATION_S
				WHERE
					P_ORDER_NO IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#p_order_no_list#" list="true">) AND
					OPERATION_TYPE_ID IN
										(	
										SELECT     	
											OPERATION_TYPE_ID
										FROM      	
											WORKSTATIONS_PRODUCTS
										WHERE      	
											WS_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.station_id#"> AND 
											STOCK_ID IS NULL AND 
											OPERATION_TYPE_ID IS NOT NULL
										) AND 
					IS_STAGE IN (0,1,2,3,4)
				GROUP BY
					P_ORDER_ID, 
					PO_RELATED_ID, 
					LOT_NO, 
					P_ORDER_NO, 
					IS_STAGE, 
					START_DATE, 
					STOCK_ID, 
					SPEC_MAIN_ID,
					PRODUCT_NAME, 
					P_OPERATION_ID, 
					OPERATION_TYPE_ID, 
					OPERATION_CODE, 
					OPERATION_TYPE, 
					AMOUNT, 
					STAGE, 
					O_START_DATE,
					O_STATION_IP,
					ACTION_EMPLOYEE_ID,
					OPERATION_GRUP_ID,
					MASTER_ALT_PLAN_ID
			) AS TBL
		ORDER BY
			P_ORDER_NO DESC,
			OPERATION_TYPE   
	</cfquery>
<cfelse>
	<cfset GET_PO_DET.recordcount = 0>
</cfif>

