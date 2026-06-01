<!---
    File: get_ezgi_iflow_production_operations.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfparam name="attributes.x_is_parti" default="0">
<cfif attributes.x_is_parti eq 0> <!---parti Seöeneği Hayır İse--->
    <cfquery name="get_production_operations" datasource="#dsn3#">
        SELECT  
            CASE
                WHEN
                    EOM.PO_RELATED_ID IS NULL
                THEN
                    EOM.P_ORDER_ID
                ELSE
                    EOM.PO_RELATED_ID  
            END AS  SIRA_ID, 
            CASE 
                WHEN 
                    ISNULL(S.IS_PROTOTYPE,0) = 0
                THEN 
                    S.PRODUCT_NAME
                ELSE
                    (
                        
                            
                            SELECT        
                                TOP (1) DESIGN_MAIN_NAME
                            FROM            
                                EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
                            WHERE        
                                MAIN_SPECT_RELATED_ID = PO.SPEC_MAIN_ID
                            ORDER BY 
                                DESIGN_MAIN_ROW_ID DESC
                            UNION ALL
                            SELECT        
                                TOP (1) PACKAGE_NAME
                            FROM        
                                EZGI_DESIGN_PACKAGE_ROW WITH (NOLOCK)
                            WHERE        
                                PACKAGE_SPECT_RELATED_ID = PO.SPEC_MAIN_ID
                            ORDER BY 
                                PACKAGE_ROW_ID DESC
                            UNION ALL
                            SELECT        
                                TOP (1) PIECE_NAME
                            FROM            
                                EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
                            WHERE        
                                PIECE_SPECT_RELATED_ID = PO.SPEC_MAIN_ID
                            ORDER BY 
                                PIECE_ROW_ID DESC
                    )
            END	AS PRODUCT_NAME,
            S.PRODUCT_NAME as NAME_PRODUCT,
            E.IFLOW_P_ORDER_ID, 
            E.ACTION_TYPE, 
            E.PRODUCT_TYPE, 
            E.START_DATE, 
            E.FINISH_DATE, 
            E.PLANNING_DATE, 
            E.CUTTING_FINISH_DATE,
            E.QUANTITY AS IFLOW_QUANTITY,
            (SELECT TOP (1) TYPE FROM EZGI_DESIGN_STOCK_RELATED WHERE STOCK_ID = EOM.STOCK_ID) AS TYPE,  
            (SELECT PRODUCT_NAME FROM STOCKS WHERE STOCK_ID = E.STOCK_ID) AS IFLOW_PRODUCT_NAME,
            (SELECT MASTER_PLAN_NUMBER FROM EZGI_IFLOW_MASTER_PLAN WHERE MASTER_PLAN_ID = E.MASTER_PLAN_ID) AS MASTER_PLAN_NUMBER,
            (SELECT P_ORDER_PARTI_NUMBER FROM EZGI_IFLOW_PRODUCTION_ORDERS_PARTI WHERE P_ORDER_PARTI_ID = E.REL_P_ORDER_ID) AS P_ORDER_PARTI_NUMBER, 
            EOM.LOT_NO, 
            EOM.P_ORDER_NO, 
            EOM.P_ORDER_ID,
            EOM.PO_RELATED_ID,
            EOM.PRODUCTION_LEVEL, 
            EOM.IS_STAGE, 
            EOM.STOCK_CODE, 
            EOM.STOCK_ID,
            EOM.PRODUCT_ID, 
            EOM.QUANTITY, 
            EOM.P_OPERATION_ID, 
            EOM.OPERATION_TYPE_ID, 
            EOM.OPERATION_CODE, 
            EOM.OPERATION_TYPE, 
            EOM.AMOUNT, 
            EOM.STAGE, 
            EOM.REAL_TIME, 
            EOM.WAIT_TIME, 
            EOM.ACTION_EMPLOYEE_ID,
            EOM.ACTION_START_DATE,
            ISNULL(EOM.REAL_AMOUNT,0) REAL_AMOUNT, 
            EOM.LOSS_AMOUNT, 
            EOM.STATION_NAME O_STATION_NAME, 
            EOM.O_START_DATE, 
            EOM.O_STATION_IP, 
            EOM.O_TOTAL_PROCESS_TIME, 
            EOM.IS_VIRTUAL, 
            EOM.OPERATION_GRUP_ID, 
            EOM.OPERATION_RESULT_ID, 
            EOM.OPERATION_GRUP_END_ID, 
            EOM.O_CURRENT_NUMBER,
            PO.STATION_ID,
            (SELECT STATION_NAME FROM WORKSTATIONS WITH (NOLOCK) WHERE STATION_ID = PO.STATION_ID) STATION_NAME ,
            ISNULL((SELECT COUNT(P_ORDER_ID) AS SAY FROM PRODUCTION_OPERATION_RESULT WITH (NOLOCK) WHERE REAL_AMOUNT = 0 AND LOSS_AMOUNT = 0 AND REAL_TIME = 0 AND OPERATION_ID = EOM.P_OPERATION_ID),0) SAY,
            ISNULL((SELECT TOP (1) EDPR.SIRA FROM EZGI_DESIGN_PIECE_ROTA AS EDPR WITH (NOLOCK) INNER JOIN EZGI_DESIGN_PIECE_ROWS AS EDP WITH (NOLOCK) ON EDPR.PIECE_ROW_ID = EDP.PIECE_ROW_ID WHERE EDP.PIECE_RELATED_ID = EOM.STOCK_ID AND EDPR.OPERATION_TYPE_ID = EOM.OPERATION_TYPE_ID),999) AS ASIRA
        FROM            
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
            EZGI_IFLOW_PRODUCTION_ORDERS AS E WITH (NOLOCK) ON PO.LOT_NO = E.LOT_NO INNER JOIN
            EZGI_OPERATION_M AS EOM WITH (NOLOCK) ON PO.P_ORDER_ID = EOM.P_ORDER_ID INNER JOIN
            STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID 
        WHERE        
            1 = 1 
            <cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
                AND E.MASTER_PLAN_ID = #attributes.master_plan_id#
            </cfif>
            <cfif isdefined('attributes.product_type') and len(attributes.product_type)>
                AND E.PRODUCT_TYPE = #attributes.product_type#
            </cfif>
            <cfif isdefined('attributes.keyword') and len(attributes.keyword)>
                    AND 
                    (
                        EOM.PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
                        EOM.LOT_NO LIKE '%#attributes.keyword#%' OR
                        EOM.P_ORDER_NO LIKE '%#attributes.keyword#%' OR
                        E.REL_P_ORDER_ID IN (
                                                SELECT
                                                    P_ORDER_PARTI_ID  
                                                FROM 
                                                    EZGI_IFLOW_PRODUCTION_ORDERS_PARTI 
                                                WHERE  
                                                    P_ORDER_PARTI_NUMBER LIKE '%#attributes.keyword#%'
                                            )
                    )
            </cfif>
            <cfif isdefined('attributes.station_id') and len(attributes.station_id)>
                AND PO.STATION_ID = #attributes.station_id#
            </cfif>
            <cfif isdefined('attributes.operation_type_id') and len(attributes.operation_type_id)>
                AND EOM.OPERATION_TYPE_ID = #attributes.operation_type_id#
            </cfif>
            <cfif isdefined('attributes.p_order_id_list') and len(attributes.p_order_id_list)>
                AND PO.P_ORDER_ID IN (#attributes.p_order_id_list#)
            </cfif>
            <cfif isdefined('attributes.durum_emir') and len(attributes.durum_emir)>
                <cfif attributes.durum_emir eq 2>
                    AND EOM.STAGE IN (0,1)
                <cfelseif attributes.durum_emir eq 5>
                    AND ISNULL((SELECT COUNT(P_ORDER_ID) AS SAY FROM PRODUCTION_OPERATION_RESULT WITH (NOLOCK) WHERE REAL_AMOUNT = 0 AND LOSS_AMOUNT = 0 AND REAL_TIME = 0 AND OPERATION_ID = EOM.P_OPERATION_ID),0) > 0
                <cfelse>
                    AND EOM.STAGE = #attributes.durum_emir#
                </cfif>
            </cfif>
        ORDER BY 
            <cfif attributes.sort_type eq 0>
                EOM.PRODUCT_NAME
            <cfelseif attributes.sort_type eq 1>
                EOM.PRODUCT_NAME desc
            <cfelseif attributes.sort_type eq 2>
                EOM.LOT_NO
            <cfelseif attributes.sort_type eq 3>
                EOM.LOT_NO desc
            <cfelseif attributes.sort_type eq 4>
                E.CUTTING_FINISH_DATE
            <cfelseif attributes.sort_type eq 5>
                E.CUTTING_FINISH_DATE desc
            <cfelseif attributes.sort_type eq 10>
                E.DP_ORDER_ID
            </cfif>

     </cfquery>
     <cfquery name="get_production_operations_group" dbtype="query">
            SELECT
                IFLOW_P_ORDER_ID, 
                ACTION_TYPE, 
                PRODUCT_TYPE, 
                START_DATE, 
                FINISH_DATE, 
                PLANNING_DATE, 
                IFLOW_PRODUCT_NAME,
                MASTER_PLAN_NUMBER,
                P_ORDER_PARTI_NUMBER, 
                LOT_NO,
                IFLOW_QUANTITY
            FROM
                get_production_operations
            GROUP BY
                IFLOW_P_ORDER_ID, 
                ACTION_TYPE, 
                PRODUCT_TYPE, 
                START_DATE, 
                FINISH_DATE, 
                PLANNING_DATE, 
                IFLOW_PRODUCT_NAME,
                MASTER_PLAN_NUMBER,
                P_ORDER_PARTI_NUMBER, 
                LOT_NO,
                IFLOW_QUANTITY
 	</cfquery>
<cfelse> <!---parti Seöeneği Evet İse--->
	<!---<cfset attributes.point_code = '01.151.01.01'>--->
	<cfquery name="get_production_operations" datasource="#dsn3#">
		SELECT 
        	EIPO.P_ORDER_PARTI_SORT_NO,
       		EPO.P_ORDER_SORT_NO,
            EIPO.P_ORDER_PARTI_ID, 
            PORR.OPERATION_TYPE_ID, 
            PORR.O_START_DATE, 
            EPO.QUANTITY, 
            EIPO.P_ORDER_PARTI_NUMBER, 
            EIPO.P_ORDER_START_DATE,
            EIPO.P_ORDER_FINISH_DATE,
            EPO.LOT_NO, 
            EPO.IFLOW_P_ORDER_ID,
            EPO.TOTAL_PRODUCTION_TIME,
            EPO.START_DATE,
            EPO.FINISH_DATE,
            OT.OPERATION_TYPE,
            EIM.MASTER_PLAN_ID, 
            EIM.MASTER_PLAN_NUMBER,
            EIM.MASTER_PLAN_START_DATE,
            S.PRODUCT_CODE, 
            S.PRODUCT_NAME
            <cfif attributes.x_station_level eq 1>
            , W1.STATION_ID
            , W1.STATION_NAME
            </cfif>
        FROM     
            EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPO WITH (NOLOCK) INNER JOIN
            EZGI_IFLOW_PRODUCTION_ORDERS AS EPO WITH (NOLOCK) ON EIPO.P_ORDER_PARTI_ID = EPO.REL_P_ORDER_ID INNER JOIN
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EPO.LOT_NO = PO.LOT_NO INNER JOIN
            PRODUCTION_OPERATION AS PORR WITH (NOLOCK) ON PO.P_ORDER_ID = PORR.P_ORDER_ID INNER JOIN
            OPERATION_TYPES AS OT WITH (NOLOCK) ON PORR.OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID INNER JOIN
            EZGI_IFLOW_MASTER_PLAN AS EIM WITH (NOLOCK) ON EPO.MASTER_PLAN_ID = EIM.MASTER_PLAN_ID INNER JOIN
        	STOCKS AS S  WITH (NOLOCK) ON EPO.STOCK_ID = S.STOCK_ID
            <cfif attributes.x_station_level eq 1><!---Üst İstasyon Bazında--->
            	INNER JOIN WORKSTATIONS_PRODUCTS AS WP ON OT.OPERATION_TYPE_ID = WP.OPERATION_TYPE_ID 
                INNER JOIN WORKSTATIONS AS W ON WP.WS_ID = W.STATION_ID 
                INNER JOIN WORKSTATIONS AS W1 ON W.UP_STATION = W1.STATION_ID
            </cfif>
        WHERE
            1=1
            <cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
                AND EPO.MASTER_PLAN_ID IN (#attributes.master_plan_id#)
            </cfif>
            <cfif isdefined('attributes.product_type') and len(attributes.product_type)>
                AND EPO.PRODUCT_TYPE = #attributes.product_type#
            </cfif>
            <cfif len(attributes.start_date)>
            	AND EIPO.P_ORDER_START_DATE >= #attributes.start_date#
           	</cfif>
           	<cfif len(attributes.finish_date)>
            	AND EIPO.P_ORDER_START_DATE < #DateAdd('d',1,attributes.finish_date)#
        	</cfif>
            <cfif isdefined('attributes.keyword') and len(attributes.keyword)>
                AND 
                    (
                        EIM.MASTER_PLAN_NUMBER LIKE '%#attributes.keyword#%' OR
                        EPO.LOT_NO LIKE '%#attributes.keyword#%' OR
                        EIPO.P_ORDER_PARTI_NUMBER LIKE '%#attributes.keyword#%'
                    )
            </cfif>
        GROUP BY 
        	EIPO.P_ORDER_PARTI_SORT_NO,
       		EPO.P_ORDER_SORT_NO,
            EIPO.P_ORDER_PARTI_ID, 
            PORR.OPERATION_TYPE_ID, 
            PORR.O_START_DATE, 
            EPO.QUANTITY, 
            EIPO.P_ORDER_PARTI_NUMBER, 
            EIPO.P_ORDER_START_DATE,
            EIPO.P_ORDER_FINISH_DATE,
            EPO.LOT_NO, 
            EPO.IFLOW_P_ORDER_ID,
            EPO.TOTAL_PRODUCTION_TIME,
            EPO.START_DATE,
            EPO.FINISH_DATE,
            OT.OPERATION_TYPE, 
            EIM.MASTER_PLAN_ID, 
            EIM.MASTER_PLAN_NUMBER,
            EIM.MASTER_PLAN_START_DATE,
            S.PRODUCT_CODE, 
            S.PRODUCT_NAME
            <cfif attributes.x_station_level eq 1>
            , W1.STATION_ID
            , W1.STATION_NAME
            </cfif>
        ORDER BY 
            EIPO.P_ORDER_PARTI_SORT_NO,
       		EPO.P_ORDER_SORT_NO
	</cfquery>
    <cfquery name="get_operations_group" dbtype="query">
    	<!---Yatay Satırlar--->
    	<cfif attributes.x_station_level eq 1>	<!---İstasyon Bazında--->
        	SELECT 
            	STATION_ID, 
                STATION_NAME, 
                MIN(O_START_DATE) AS O_START_DATE
          	FROM
            	get_production_operations
          	GROUP BY 
            	STATION_ID, 
                STATION_NAME
			ORDER BY 
            	O_START_DATE,
                STATION_NAME
      	<cfelse> <!---Operasyon Bazında--->
        	SELECT 
            	OPERATION_TYPE_ID, 
                OPERATION_TYPE, 
                MIN(O_START_DATE) AS O_START_DATE
          	FROM
            	get_production_operations
          	GROUP BY 
            	OPERATION_TYPE_ID, 
                OPERATION_TYPE
			ORDER BY 
            	O_START_DATE,
                OPERATION_TYPE
        </cfif>
        <!---Yatay Satırlar--->
  	</cfquery>
    <!---Üretim Emir Satırları--->
    <cfquery name="get_production_operations_group" dbtype="query">
        	SELECT 
            	P_ORDER_PARTI_SORT_NO,
       			P_ORDER_SORT_NO,
            	P_ORDER_PARTI_ID, 
               	P_ORDER_START_DATE,
            	P_ORDER_FINISH_DATE,
                TOTAL_PRODUCTION_TIME,
                QUANTITY, 
                P_ORDER_PARTI_NUMBER, 
                LOT_NO,
                IFLOW_P_ORDER_ID,
                MASTER_PLAN_ID, 
                MASTER_PLAN_NUMBER,
                MASTER_PLAN_START_DATE, 
              	START_DATE,
            	FINISH_DATE,
                PRODUCT_CODE, 
                PRODUCT_NAME
          	FROM
            	get_production_operations
          	GROUP BY 
            	P_ORDER_PARTI_SORT_NO,
       			P_ORDER_SORT_NO,
            	P_ORDER_PARTI_ID,
                P_ORDER_START_DATE,
            	P_ORDER_FINISH_DATE,
                START_DATE,
            	FINISH_DATE, 
                TOTAL_PRODUCTION_TIME,
                QUANTITY, 
                P_ORDER_PARTI_NUMBER, 
                LOT_NO, 
                IFLOW_P_ORDER_ID,
                MASTER_PLAN_ID, 
                MASTER_PLAN_NUMBER, 
                MASTER_PLAN_START_DATE,
                PRODUCT_CODE, 
                PRODUCT_NAME
			ORDER BY 
            	MASTER_PLAN_ID, 
                P_ORDER_PARTI_SORT_NO,
       			P_ORDER_SORT_NO,
                P_ORDER_PARTI_ID,
                O_START_DATE
  	</cfquery>
    <!---Üretim Emir Satırları--->
    <cfset iflow_p_order_id_list = ListDeleteDuplicates(ValueList(get_production_operations.IFLOW_P_ORDER_ID))>
    <cfif ListLen(iflow_p_order_id_list)>
    	<!---Operasyon Sonuç Tarama--->
    	<cfquery name="get_operation_result" datasource="#dsn3#">
    		SELECT 
            	OPERATION_TYPE_ID, 
                IFLOW_P_ORDER_ID, 
                SUM(STAGE) AS STAGE
			FROM     
            	(
                	SELECT 
                    	CASE 
                        	WHEN STAGE = 0 THEN 1
                            WHEN STAGE = 1 THEN 0.5
                         	WHEN STAGE = 3 THEN 3
                      	END AS STAGE,
                    	PORR.OPERATION_TYPE_ID, 
                        EPO.IFLOW_P_ORDER_ID
                  	FROM      
                    	EZGI_IFLOW_PRODUCTION_ORDERS AS EPO WITH (NOLOCK) INNER JOIN
                        PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EPO.LOT_NO = PO.LOT_NO INNER JOIN
                        PRODUCTION_OPERATION AS PORR WITH (NOLOCK) ON PO.P_ORDER_ID = PORR.P_ORDER_ID
                  	GROUP BY 	
                    	PORR.OPERATION_TYPE_ID, 
                        EPO.IFLOW_P_ORDER_ID, 
                        PORR.STAGE
                  	HAVING  
                    	EPO.IFLOW_P_ORDER_ID IN (#iflow_p_order_id_list#)
              	) AS TBL
			GROUP BY 
            	OPERATION_TYPE_ID, 
                IFLOW_P_ORDER_ID
  		</cfquery>
        <cfif get_operation_result.recordcount>
        	<cfoutput query="get_operation_result">
            	<cfset 'STAGE_#IFLOW_P_ORDER_ID#_#OPERATION_TYPE_ID#' = STAGE>
            </cfoutput>
        </cfif>
        <!---Operasyon Sonuç Tarama--->
        
       <!---Operasyon Hesaplama--->
        <cfquery name="GET_MASTER_PLAN_INFO" datasource="#dsn3#">
            SELECT 
                EPO.MASTER_PLAN_ID, 
                EMP.MASTER_PLAN_CAT_ID
            FROM     
                EZGI_IFLOW_PRODUCTION_ORDERS AS EPO INNER JOIN
                EZGI_IFLOW_MASTER_PLAN AS EMP ON EPO.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID
            WHERE  
                EPO.IFLOW_P_ORDER_ID = #ListGetAt(iflow_p_order_id_list,1)#
        </cfquery>
        <cfinclude template="../query/hsp_ezgi_iflow_production_operations.cfm">
         <!---Operasyon Hesaplama--->
 	</cfif>
</cfif>