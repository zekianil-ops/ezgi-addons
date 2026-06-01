<!---
    File: get_ezgi_operations.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/07/2022
    Description:
--->
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
                ,0) ROW_RESULT_AMOUNT
            FROM         
                EZGI_OPERATION_M
            WHERE
            	P_ORDER_ID NOT IN (SELECT P_ORDER_ID FROM EZGI_OPERATION_S) AND
                <cfif attributes.is_show eq 0>
                    O_STATION_IP = #attributes.station_id# AND
                <cfelse>
                    OPERATION_TYPE_ID IN
                                        (	
                                        SELECT     	
                                            OPERATION_TYPE_ID
                                        FROM      	
                                            WORKSTATIONS_PRODUCTS
                                        WHERE      	
                                            WS_ID = #attributes.station_id# AND 
                                            STOCK_ID IS NULL AND 
                                            OPERATION_TYPE_ID IS NOT NULL
                                        ) AND 
                </cfif>
                IS_STAGE IN (0,1,2,3,4)
                <cfif isdefined('attributes.all_info') and len(attributes.all_info)>
                    AND IS_STAGE IN (0,1,3,4)
                    <cfif len(attributes.lot_number)>
                        AND PRODUCT_NAME LIKE '%#attributes.lot_number#%'
                    </cfif>
                <cfelse>
                    <cfif isdefined('attributes.lot_number') and len(attributes.lot_number)>
                        AND(
                            <cfif left(attributes.lot_number,1) eq 2>
                                P_ORDER_NO LIKE '#attributes.lot_number#%'       
                            <cfelseif left(attributes.lot_number,1) eq 1>
                                LOT_NO LIKE '#attributes.lot_number#%' 
                         	<cfelseif isdefined('get_workstation_name.EZGI_PACKAGE_CONTROL') and get_workstation_name.EZGI_PACKAGE_CONTROL eq 3 and left(attributes.lot_number,1) eq 4> <!---Gurupla Üret İse--->
                				P_OPERATION_ID IN
                                					(
                                                    	SELECT 
                                                        	EVR.OPERATION_ID
														FROM     
                                                        	EZGI_VTS_OPERATION_BASKET AS EV INNER JOIN
                  											EZGI_VTS_OPERATION_BASKET_ROW AS EVR ON EV.EZGI_VTS_OPERATION_BASKET_ID = EVR.EZGI_VTS_OPERATION_BASKET_ID
														WHERE  
                                                        	EV.BASKET_NO = #attributes.lot_number#
                                                    )
                			</cfif>
                            )
                    <cfelse>
                        AND ACTION_EMPLOYEE_ID = #employee_id# AND 
                        REAL_AMOUNT = 0 AND 
                        LOSS_AMOUNT = 0 AND 
                        ISNULL(REAL_TIME,0)=0 AND 
                        WAIT_TIME IS NULL
                    </cfif>
                </cfif>
                <cfif len(attributes.master_plan)>
                    AND LOT_NO IN 
                                (
                                    SELECT        
                                        LOT_NO
                                    FROM          
                                        EZGI_IFLOW_PRODUCTION_ORDERS
                                    WHERE        
                                        MASTER_PLAN_ID = #attributes.master_plan#
                                ) 
                </cfif>
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
                ,0) ROW_RESULT_AMOUNT
            FROM         
                EZGI_OPERATION_S
            WHERE
                <cfif attributes.is_show eq 0>
                    O_STATION_IP = #attributes.station_id# AND
                <cfelse>
                    OPERATION_TYPE_ID IN
                                        (	
                                        SELECT     	
                                            OPERATION_TYPE_ID
                                        FROM      	
                                            WORKSTATIONS_PRODUCTS
                                        WHERE      	
                                            WS_ID = #attributes.station_id# AND 
                                            STOCK_ID IS NULL AND 
                                            OPERATION_TYPE_ID IS NOT NULL
                                        ) AND 
                </cfif>
                IS_STAGE IN (0,1,2,3,4)
                <cfif isdefined('attributes.all_info') and len(attributes.all_info)>
                    <!---AND START_DATE < #Dateadd('d',1,attributes.start_date)#
                    AND START_DATE >= #attributes.start_date#
                    AND IS_STAGE IN (0,1,3,4)--->
                <cfelse>
                    <cfif isdefined('attributes.lot_number') and len(attributes.lot_number)>
                        AND(
                            <cfif left(attributes.lot_number,1) eq 2>
                                P_ORDER_NO LIKE '#attributes.lot_number#%'       
                            <cfelseif left(attributes.lot_number,1) eq 1>
                                LOT_NO LIKE '#attributes.lot_number#%' 
                         	<cfelseif isdefined('get_workstation_name.EZGI_PACKAGE_CONTROL') and get_workstation_name.EZGI_PACKAGE_CONTROL eq 3 and left(attributes.lot_number,1) eq 4> <!---Gurupla Üret İse--->
                				P_OPERATION_ID IN
                                					(
                                                    	SELECT 
                                                        	EVR.OPERATION_ID
														FROM     
                                                        	EZGI_VTS_OPERATION_BASKET AS EV INNER JOIN
                  											EZGI_VTS_OPERATION_BASKET_ROW AS EVR ON EV.EZGI_VTS_OPERATION_BASKET_ID = EVR.EZGI_VTS_OPERATION_BASKET_ID
														WHERE  
                                                        	EV.BASKET_NO = #attributes.lot_number#
                                                    )
                			</cfif>
                            )
                    <cfelse>
                        AND ACTION_EMPLOYEE_ID = #employee_id# AND 
                        REAL_AMOUNT = 0 AND 
                        LOSS_AMOUNT = 0 AND 
                        ISNULL(REAL_TIME,0)=0 AND 
                        WAIT_TIME IS NULL
                    </cfif>
                </cfif>
                <cfif len(attributes.master_plan)>
                    AND LOT_NO IN 
                                (
                                    SELECT 
                                        PO.LOT_NO
                                    FROM     
                                        EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
                                        EZGI_MASTER_PLAN_RELATIONS AS EMAR ON EMAP.MASTER_ALT_PLAN_ID = EMAR.MASTER_ALT_PLAN_ID INNER JOIN
                                        PRODUCTION_ORDERS AS PO ON EMAR.P_ORDER_ID = PO.P_ORDER_ID
                                    WHERE  
                                        EMAP.MASTER_ALT_PLAN_ID = #attributes.master_plan# OR
                                        EMAP.RELATED_MASTER_ALT_PLAN_ID = #attributes.master_plan#
                                ) 
                </cfif>
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
        	<cfif isdefined('attributes.all_info') and len(attributes.all_info)>
            	P_ORDER_ID,
            	O_START_DATE,
                OPERATION_TYPE 
            <cfelse>
                P_ORDER_NO DESC ,
                OPERATION_TYPE   
            </cfif>         
    </cfquery>