<cffunction name="get_production_orders_" returntype="query">
	<cfargument name="product_id" default="">
    <cfargument name="product_name" default="">
    <cfargument name="stock_id" default="">
    <cfargument name="keyword" default="">
    <cfargument name="start_date" default="">
	<cfargument name="finish_date" default="">
    <cfargument name="sort_type" default="">
    <cfargument name="is_in_package" default="">
    <cfargument name="list_type" default="">
    <cfargument name="durum_emir" default="">
    <cfargument name="master_plan_id" default="">
    <cfargument name="member_cat_type" default="">
    <cfargument name="consumer_id" default="">
    <cfargument name="company_id" default="">
    <cfargument name="color_id" default="">
    <cfargument name="thickness_id" default="">
    <cfargument name="member_name" default="">
    <cfargument name="member_type" default="">
    <cfargument name="record_emp_id" default="">
    <cfargument name="record_emp_name" default="">
    <cfargument name="category_name" default="">
    <cfargument name="station_id" default="">
    <cfargument name="cat_id" default="">
    <cfargument name="cat" default="">
    <cfargument name="department_id" default="">
    <cfargument name="PRODUCT_TYPE" default="">
    <cfargument name="operation_type_id" default="">
    <cfargument name="iflow_p_order_id_list" default="">
    <cfargument name="reverse_answer" default="">
	<cfargument name="startrow" default="">
    <cfargument name="maxrows" default="">
    <cfquery name="get_defaults" datasource="#this.DSN3#">
        SELECT * FROM EZGI_DESIGN_DEFAULTS
    </cfquery>
    <cfquery name="get_production_orders" datasource="#this.DSN3#">
		WITH CTE1 AS 
        		(
                	<cfif isdefined('arguments.list_type') AND (arguments.list_type eq 2 or arguments.list_type eq 3 or arguments.list_type eq 4 or arguments.list_type eq 5)>
                		SELECT DISTINCT
                            CASE 
                                WHEN 
                                    ISNULL(S.IS_PROTOTYPE,0) = 0
                                THEN 
                                    S.PRODUCT_NAME
                                ELSE
                                    (
                                        SELECT TOP (1) 
                                        	PRODUCT_NAME
                       					FROM      
                                        	EZGI_DESIGN_SPECT_RELATED WITH (NOLOCK)
                       					WHERE   
                                        	SPECT_MAIN_ID = PO.SPEC_MAIN_ID
                       					ORDER BY 
                                        	SPECT_MAIN_ID DESC
                                    )
                            END	AS PRODUCT_NAME,
                            S.PRODUCT_NAME AS NAME_PRODUCT,   
                            ISNULL(PO.PRINT_COUNT,0) PRINT_COUNT,        
                            E.IFLOW_P_ORDER_ID, 
                            E.ACTION_TYPE, 
                            E.PRODUCT_TYPE, 
                            S.PRODUCT_ID, 
                            S.PRODUCT_CODE, 
                            S.PRODUCT_CODE_2, 
                            PO.STOCK_ID,
                            PO.PO_RELATED_ID,
                            E.START_DATE, 
                            E.FINISH_DATE, 
                            E.PLANNING_DATE, 
                            PO.QUANTITY, 
                            PO.LOT_NO, 
                            E.DETAIL, 
                            E.TOTAL_PRODUCTION_TIME, 
                            E.CUTTING_FINISH_DATE, 
                            P.MAIN_UNIT AS UNIT,
                            (SELECT MASTER_PLAN_NUMBER FROM EZGI_IFLOW_MASTER_PLAN WITH (NOLOCK) WHERE MASTER_PLAN_ID = E.MASTER_PLAN_ID) AS MASTER_PLAN_NUMBER, 
                            EIOP.P_ORDER_PARTI_NUMBER,
                            (SELECT TOP (1) EPR.PACKAGE_NUMBER FROM PRODUCTION_ORDERS AS PP WITH (NOLOCK) INNER JOIN EZGI_DESIGN_PACKAGE_ROW AS EPR ON PP.STOCK_ID = EPR.PACKAGE_RELATED_ID WHERE PP.P_ORDER_ID = PO.PO_RELATED_ID) PACKAGE_NUMBER,
                            ISNULL((SELECT TOP (1) PIECE_TYPE FROM EZGI_DESIGN_PIECE_ROWS WHERE PIECE_RELATED_ID = PO.STOCK_ID),0) PIECE_TYPE,
                            PO.P_ORDER_ID,
                            PO.P_ORDER_NO, 
                            ISNULL(PO.IS_GROUP_LOT,0) AS IS_GROUP_LOT, 
                            PO.GROUP_LOT_NO,
                            PO.IS_STAGE, 
                            PO.STATION_ID, 
                            ISNULL(TBL.AMOUNT,0) AS AMOUNT,
                            E.DP_ORDER_ID<!---,
                            EDPR.KALINLIK Üretim Emirleri Sayfasında Özel Üretimlerde Çoklama Yapıyordu Kaldırdım.--->
                        FROM      

                        
                            
                            PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
                            EZGI_IFLOW_PRODUCTION_ORDERS AS E WITH (NOLOCK) ON PO.LOT_NO = E.LOT_NO INNER JOIN
                            PRODUCT_UNIT AS P WITH (NOLOCK) INNER JOIN
                            STOCKS AS S WITH (NOLOCK) ON P.PRODUCT_UNIT_ID = S.PRODUCT_UNIT_ID  ON PO.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
                            (
                                SELECT        
                                    POR.P_ORDER_ID, 
                                    SUM(PORR.AMOUNT) AS AMOUNT
                                FROM      
                                    PRODUCTION_ORDER_RESULTS AS POR WITH (NOLOCK) INNER JOIN
                                    PRODUCTION_ORDER_RESULTS_ROW AS PORR WITH (NOLOCK) ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
                                WHERE        
                                    PORR.TYPE = 1 AND 
                                    POR.IS_STOCK_FIS = 1
                                GROUP BY 
                                    POR.P_ORDER_ID
                            ) AS TBL ON PO.P_ORDER_ID = TBL.P_ORDER_ID INNER JOIN
                            EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIOP WITH (NOLOCK) ON EIOP.P_ORDER_PARTI_ID = E.REL_P_ORDER_ID LEFT OUTER JOIN
                            EZGI_DESIGN_PIECE_ROWS AS EDPR ON EDPR.PIECE_RELATED_ID = S.STOCK_ID
                        WHERE        
                            1= 1
                            <cfif len(arguments.product_name) and len(arguments.product_id) and len(arguments.stock_id)>
            					AND S.STOCK_ID = #arguments.stock_id# 
                         	</cfif>
                            <cfif len(arguments.color_id)>
            					AND S.STOCK_ID IN (SELECT PIECE_RELATED_ID FROM EZGI_DESIGN_PIECE_ROWS WHERE PIECE_COLOR_ID = #arguments.color_id#) 
                         	</cfif>
                            <cfif len(arguments.thickness_id)>
            					AND S.STOCK_ID IN (SELECT PIECE_RELATED_ID FROM EZGI_DESIGN_PIECE_ROWS WHERE KALINLIK = #arguments.thickness_id#) 
                         	</cfif>
                            <cfif len(arguments.start_date)>
            					AND E.FINISH_DATE >= #arguments.start_date#
                         	</cfif>
                           	<cfif len(arguments.finish_date)>
            					AND E.FINISH_DATE < #DateAdd('d',1,arguments.finish_date)#
                         	</cfif>
                            <cfif isdefined('arguments.master_plan_id') and len(arguments.master_plan_id)>
                                AND E.MASTER_PLAN_ID IN (#arguments.master_plan_id#)
                            </cfif>
                            <cfif isdefined('arguments.product_type') and len(arguments.product_type)>
                                AND E.PRODUCT_TYPE = #arguments.product_type#
                            </cfif>
                            <cfif isdefined('arguments.keyword') and len(arguments.keyword)>
                                AND 
                                (
                                    PO.P_ORDER_NO LIKE '%#arguments.keyword#%' OR
                                    S.PRODUCT_NAME LIKE '%#arguments.keyword#%' OR
                                    E.LOT_NO LIKE '%#arguments.keyword#%' OR
                                    EIOP.P_ORDER_PARTI_NUMBER LIKE '%#arguments.keyword#%'
                                )
                            </cfif>
                            <cfif isdefined('arguments.station_id') and len(arguments.station_id)>
                                AND PO.STATION_ID = #arguments.station_id#
                            </cfif>
                            <cfif isdefined('arguments.p_order_id_list') and len(arguments.p_order_id_list)>
                                AND PO.P_ORDER_ID IN (#arguments.p_order_id_list#)
                            </cfif>
                            <cfif isdefined('arguments.durum_emir') and arguments.durum_emir eq 1>
                               AND ROUND(PO.QUANTITY,4) <= ISNULL(ROUND(TBL.AMOUNT,4),0)
                            <cfelseif isdefined('arguments.durum_emir') and arguments.durum_emir eq 2>
                                AND ROUND(PO.QUANTITY,4) > ISNULL(ROUND(TBL.AMOUNT,4),0)
                            </cfif>
                            <cfif isdefined('arguments.category_name') and len(arguments.category_name) and len(arguments.cat)>
                                AND PO.STOCK_ID IN 
                                                    (
                                                        SELECT        
                                                            STOCK_ID
                                                        FROM            
                                                            STOCKS
                                                        WHERE        
                                                            STOCK_CODE LIKE '#arguments.cat#%'
                                                    )
                            </cfif>
                            <cfif isdefined('arguments.record_emp_name') and len(arguments.record_emp_name) and len(arguments.record_emp_id)>
                                AND PO.RECORD_EMP = #arguments.record_emp_id#
                            </cfif>
                            <cfif isdefined('arguments.member_name') and len(arguments.member_name) and (len(arguments.company_id) or len(arguments.consumer_id))>
                                AND E.ORDER_ROW_ID IN 
                                                    (
                                                        SELECT        
                                                            ORR.ORDER_ROW_ID
                                                        FROM            
                                                            ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                                                            ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID
                                                        WHERE  
                                                            <cfif len(arguments.company_id)>      
                                                                O.COMPANY_ID = #arguments.company_id#
                                                            <cfelseif len(arguments.consumer_id)>
                                                                O.CONSUMER_ID = #arguments.consumer_id#
                                                            </cfif>
                                                    )
                            </cfif>
                            <cfif isdefined('arguments.operation_type_id') and len(arguments.operation_type_id)>
                                AND PO.P_ORDER_ID <cfif arguments.reverse_answer eq 1>NOT</cfif> IN 
                                                    (
                                                        SELECT        
                                                            P_ORDER_ID
                                                        FROM           
                                                            PRODUCTION_OPERATION WITH (NOLOCK)
                                                        WHERE        
                                                            OPERATION_TYPE_ID IN (#arguments.operation_type_id#)
                                                    
                                                    )
                            </cfif>
                            <cfif isdefined('arguments.iflow_p_order_id_list') and len(arguments.iflow_p_order_id_list)>
                            	AND E.IFLOW_P_ORDER_ID IN (#arguments.iflow_p_order_id_list#)
                            </cfif>
                    <cfelse>
                    	SELECT   
                        	ISNULL(E.PRINT_COUNT,0) PRINT_COUNT,  
                        	E.DP_ORDER_ID,
                            E.IFLOW_P_ORDER_ID,
                            E.ACTION_TYPE,
                            E.REL_P_ORDER_ID, 
                            E.PROD_ORDER_STAGE,    
                            E.PRODUCT_TYPE, 
                            S.PRODUCT_ID, 
                            S.PRODUCT_NAME, 
                            S.PRODUCT_CODE,
                            E.STOCK_ID, 
                            E.START_DATE, 
                            E.FINISH_DATE,
                            E.PLANNING_DATE, 
                            E.QUANTITY, 
                            E.LOT_NO, 
                            E.DETAIL, 
                            E.RECORD_EMP, 
                            E.RECORD_DATE, 
                            E.RECORD_IP,
                            E.TOTAL_PRODUCTION_TIME,
                            ISNULL((SELECT ORDER_ID FROM ORDER_ROW AS ORR WITH (NOLOCK) WHERE ORDER_ROW_ID = E.ORDER_ROW_ID),0) AS ORDER_ID,
                            ISNULL((SELECT IS_STAGE FROM EZGI_IFLOW_PRODUCTION_ORDER_LOT_NO_STAGE WITH (NOLOCK) WHERE IFLOW_P_ORDER_ID = E.IFLOW_P_ORDER_ID),4) AS IS_STAGE,
                            (SELECT P_ORDER_PARTI_DATE FROM EZGI_IFLOW_PRODUCTION_ORDERS_PARTI WITH (NOLOCK) WHERE P_ORDER_PARTI_ID = E.REL_P_ORDER_ID) AS P_ORDER_PARTI_DATE,
                            EIOP.P_ORDER_PARTI_NUMBER,
                            (SELECT P_ORDER_PARTI_DETAIL FROM EZGI_IFLOW_PRODUCTION_ORDERS_PARTI WITH (NOLOCK) WHERE P_ORDER_PARTI_ID = E.REL_P_ORDER_ID) AS P_ORDER_PARTI_DETAIL,
                            E.CUTTING_FINISH_DATE,
                            P.MAIN_UNIT UNIT,
                            E.SPECT_MAIN_ID,
                            (
                                SELECT        
                                    MASTER_PLAN_NUMBER
                                FROM      
                                    EZGI_IFLOW_MASTER_PLAN WITH (NOLOCK)
                                WHERE        
                                    MASTER_PLAN_ID = E.MASTER_PLAN_ID
                            ) AS MASTER_PLAN_NUMBER,
                            ISNULL((
                                SELECT        
                                    SUM(PO.QUANTITY) AS QUANTITY
                                FROM            
                                    PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
                                    STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID
                                WHERE        
                                    S.PRODUCT_CATID =
                                                    (
                                                        SELECT        
                                                            DEFAULT_PACKAGE_CAT_ID 
                                                        FROM            
                                                            EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
                                                    ) AND 
                                    PO.LOT_NO = E.LOT_NO
                            ),0) AS PAKET_SAYI,
                            CASE
                                WHEN 
                                    PRODUCT_TYPE = 2
                                THEN
                                    (
                                        SELECT   TOP (1) DESIGN_MAIN_ROW_ID 
                                        FROM            
                                            EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
                                        WHERE        
                                            DESIGN_MAIN_RELATED_ID = S.STOCK_ID
                                    )
                                WHEN PRODUCT_TYPE = 3
                                THEN
                                    (
                                        SELECT    TOP (1)    
                                            PACKAGE_ROW_ID
                                        FROM            
                
                                            EZGI_DESIGN_PACKAGE
                                        WHERE        
                                            PACKAGE_RELATED_ID = S.STOCK_ID
                                            
                                    )
                                WHEN PRODUCT_TYPE = 4
                                THEN
                                    (
                                        SELECT   TOP (1)      
                                            PIECE_ROW_ID
                                        FROM            
                                            EZGI_DESIGN_PIECE WITH (NOLOCK)
                                        WHERE        
                                            PIECE_RELATED_ID = S.STOCK_ID
                                    )
                            END AS RELATED_ID,
                            (
                                SELECT 
                                    ROUND(SUM(URETILEN) / SUM(EMIR) * 100, 2) AS URETILEN
                                FROM     
                                    EZGI_IFLOW_PRODUCTION_ORDER_LOT_NO
                                WHERE  
                                    LOT_NO = E.LOT_NO
                            ) AS AMOUNT
                        FROM        
                            EZGI_IFLOW_PRODUCTION_ORDERS AS E WITH (NOLOCK) INNER JOIN
                            STOCKS AS S WITH (NOLOCK) ON E.STOCK_ID = S.STOCK_ID INNER JOIN
                            PRODUCT_UNIT AS P WITH (NOLOCK) ON P.PRODUCT_UNIT_ID = S.PRODUCT_UNIT_ID INNER JOIN
                          	EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIOP WITH (NOLOCK) ON EIOP.P_ORDER_PARTI_ID = E.REL_P_ORDER_ID
                        WHERE
                            1=1
                            <cfif len(arguments.product_name) and len(arguments.product_id) and len(arguments.stock_id)>
            					AND S.STOCK_ID = #arguments.stock_id# 
                         	</cfif>
                            <cfif len(arguments.start_date)>
            					AND E.FINISH_DATE >= #arguments.start_date#
                         	</cfif>
                           	<cfif len(arguments.finish_date)>
            					AND E.FINISH_DATE < #DateAdd('d',1,arguments.finish_date)#
                         	</cfif>
                            <cfif isdefined('arguments.master_plan_id') and len(arguments.master_plan_id)>
                                AND E.MASTER_PLAN_ID IN (#arguments.master_plan_id#)
                            </cfif>
                            <cfif isdefined('arguments.rel_p_order_id') and len(arguments.rel_p_order_id)>
                                AND E.REL_P_ORDER_ID = #arguments.rel_p_order_id#
                            </cfif>
                            <cfif isdefined('arguments.product_type') and len(arguments.product_type)>
                                AND E.PRODUCT_TYPE = #arguments.product_type#
                            </cfif>
                            <cfif isdefined('arguments.keyword') and len(arguments.keyword)>
                                AND 
                                (
                                    E.LOT_NO LIKE '%#arguments.keyword#%' OR
                                    S.PRODUCT_NAME LIKE '%#arguments.keyword#%' OR
                                    EIOP.P_ORDER_PARTI_NUMBER LIKE '%#arguments.keyword#%'
                                )
                            </cfif>
                            
                            <cfif isdefined('arguments.durum_emir') and arguments.durum_emir eq 1>
                                AND ISNULL((SELECT IS_STAGE FROM EZGI_IFLOW_PRODUCTION_ORDER_LOT_NO_STAGE WITH (NOLOCK) WHERE IFLOW_P_ORDER_ID = E.IFLOW_P_ORDER_ID),4) = 2
                            <cfelseif isdefined('arguments.durum_emir') and arguments.durum_emir eq 2>
                                AND ISNULL((SELECT IS_STAGE FROM EZGI_IFLOW_PRODUCTION_ORDER_LOT_NO_STAGE WITH (NOLOCK) WHERE IFLOW_P_ORDER_ID = E.IFLOW_P_ORDER_ID),4) <> 2
                            </cfif>
                            <cfif isdefined('arguments.category_name') and len(arguments.category_name) and len(arguments.cat)>
                                AND S.STOCK_ID IN 
                                                    (
                                                        SELECT        
                                                            STOCK_ID
                                                        FROM            
                                                            STOCKS WITH (NOLOCK)
                                                        WHERE        
                                                            STOCK_CODE LIKE '#arguments.cat#%'
                                                    )
                            </cfif>
                            <cfif isdefined('arguments.record_emp_name') and len(arguments.record_emp_name) and len(arguments.record_emp_id)>
                                AND E.RECORD_EMP = #arguments.record_emp_id#
                            </cfif>
                            <cfif isdefined('arguments.member_name') and len(arguments.member_name) and (len(arguments.company_id) or len(arguments.consumer_id))>
                                AND E.ORDER_ROW_ID IN 
                                                    (
                                                        SELECT        
                                                            ORR.ORDER_ROW_ID
                                                        FROM            
                                                            ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                                                            ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID
                                                        WHERE  
                                                            <cfif len(arguments.company_id)>      
                                                                O.COMPANY_ID = #arguments.company_id#
                                                            <cfelseif len(arguments.consumer_id)>
                                                                O.CONSUMER_ID = #arguments.consumer_id#
                                                            </cfif>
                                                    )
                            </cfif>
                            <cfif isdefined('arguments.iflow_p_order_id_list') and len(arguments.iflow_p_order_id_list)>
                            	AND E.IFLOW_P_ORDER_ID IN (#arguments.iflow_p_order_id_list#)
                            </cfif>
                    </cfif>
                ),
        CTE2 AS (
                    SELECT
                        CTE1.*,
                        ROW_NUMBER() OVER (
                                
                                					<cfif isdefined('arguments.list_type') AND (arguments.list_type eq 2 or arguments.list_type eq 3 or arguments.list_type eq 4 or arguments.list_type eq 5)>	
                                                    	ORDER BY 
														<cfif arguments.list_type eq 3>
                                                            LOT_NO,STOCK_ID
                                                        <cfelseif arguments.list_type eq 4>  
                                                            P_ORDER_PARTI_NUMBER,STOCK_ID
                                                        <cfelseif arguments.list_type eq 5>
                                                            STOCK_ID
                                                        <cfelse>
                                                            <cfif arguments.sort_type eq 0>
                                                                PRODUCT_NAME
                                                            <cfelseif arguments.sort_type eq 1>
                                                                PRODUCT_NAME desc
                                                            <cfelseif arguments.sort_type eq 2>
                                                                LOT_NO
                                                            <cfelseif arguments.sort_type eq 3>
                                                                LOT_NO desc
                                                            <cfelseif arguments.sort_type eq 4>
                                                                CUTTING_FINISH_DATE
                                                            <cfelseif arguments.sort_type eq 5>
                                                                CUTTING_FINISH_DATE desc
                                                            <cfelseif arguments.sort_type eq 6>
                                                               	LOT_NO,PACKAGE_NUMBER
                                                            <cfelseif arguments.sort_type eq 7>
                                                                DP_ORDER_ID
                                                          	<cfelseif arguments.sort_type eq 8>
                                                                LOT_NO,
                                                                PIECE_TYPE
                                                            </cfif>
                                                        </cfif>
                                                    <cfelse>
                                                    	ORDER BY
														<cfif arguments.sort_type eq 3>
                                                            LOT_NO desc
                                                        <cfelseif arguments.sort_type eq 4>
                                                            CUTTING_FINISH_DATE
                                                        <cfelseif arguments.sort_type eq 5>
                                                            CUTTING_FINISH_DATE desc
                                                        <cfelse>
                                                            DP_ORDER_ID
                                                        </cfif>
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
	<cfreturn get_production_orders>
</cffunction>
