<!---
    File: get_ezgi_iflow_production_order.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_DEFAULTS
</cfquery>
<cfif isdefined('attributes.list_type') AND (attributes.list_type eq 2 or attributes.list_type eq 3 or attributes.list_type eq 4 or attributes.list_type eq 5)>
	<cfquery name="get_production_orders" datasource="#dsn3#">
    	SELECT 
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
			ISNULL(PO.PRINT_COUNT,0) PRINT_COUNT,        
        	E.IFLOW_P_ORDER_ID, 
            E.ACTION_TYPE, 
            E.PRODUCT_TYPE, 
            S.PRODUCT_ID, 
            S.PRODUCT_CODE, 
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
            (SELECT P_ORDER_PARTI_NUMBER FROM EZGI_IFLOW_PRODUCTION_ORDERS_PARTI WITH (NOLOCK) WHERE P_ORDER_PARTI_ID = E.REL_P_ORDER_ID) AS P_ORDER_PARTI_NUMBER,
            (SELECT TOP (1) EPR.PACKAGE_NUMBER FROM PRODUCTION_ORDERS AS PP WITH (NOLOCK) INNER JOIN EZGI_DESIGN_PACKAGE_ROW AS EPR ON PP.STOCK_ID = EPR.PACKAGE_RELATED_ID WHERE PP.P_ORDER_ID = PO.PO_RELATED_ID) PACKAGE_NUMBER,
            ISNULL((SELECT TOP (1) PIECE_TYPE FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) WHERE PIECE_RELATED_ID = PO.STOCK_ID),0) PIECE_TYPE,
            PO.P_ORDER_ID,
            PO.P_ORDER_NO, 
            ISNULL(PO.IS_GROUP_LOT,0) AS IS_GROUP_LOT, 
            PO.GROUP_LOT_NO,
            PO.IS_STAGE, 
            PO.STATION_ID, 
         	ISNULL(TBL.AMOUNT,0) AS AMOUNT,
            ISNULL(S.IS_PROTOTYPE,0) IS_PROTOTYPE
		FROM          
        	PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
          	EZGI_IFLOW_PRODUCTION_ORDERS AS E WITH (NOLOCK) ON PO.LOT_NO = E.LOT_NO INNER JOIN
         	PRODUCT_UNIT AS P WITH (NOLOCK) INNER JOIN
           	STOCKS AS S WITH (NOLOCK) ON P.PRODUCT_ID = S.PRODUCT_ID ON PO.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
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
           	) AS TBL ON PO.P_ORDER_ID = TBL.P_ORDER_ID
		WHERE        
        	ISNULL(P.IS_MAIN,0) = 1
            <cfif isdefined('attributes.e_iflow_p_order_id_list') and len(attributes.e_iflow_p_order_id_list)>
            	AND E.IFLOW_P_ORDER_ID IN (#attributes.e_iflow_p_order_id_list#)
           	</cfif>
          	<cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
           		AND E.MASTER_PLAN_ID = #attributes.master_plan_id#
     		</cfif>
            <cfif isdefined('attributes.product_type') and len(attributes.product_type)>
                AND E.PRODUCT_TYPE = #attributes.product_type#
            </cfif>
            <cfif isdefined('attributes.keyword') and len(attributes.keyword)>
                AND 
                (
                	PO.P_ORDER_NO LIKE '%#attributes.keyword#%' OR
                	S.PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
                    E.LOT_NO LIKE '%#attributes.keyword#%'
               	)
            </cfif>
            <cfif isdefined('attributes.station_id') and len(attributes.station_id)>
            	AND PO.STATION_ID = #attributes.station_id#
            </cfif>
            <cfif isdefined('attributes.p_order_id_list') and len(attributes.p_order_id_list)>
            	AND PO.P_ORDER_ID IN (#attributes.p_order_id_list#)
            </cfif>
            <cfif isdefined('attributes.durum_emir') and attributes.durum_emir eq 1>
               AND PO.QUANTITY <= ISNULL(TBL.AMOUNT,0)
         	<cfelseif isdefined('attributes.durum_emir') and attributes.durum_emir eq 2>
            	AND PO.QUANTITY > ISNULL(TBL.AMOUNT,0)
            </cfif>
            <cfif isdefined('attributes.category_name') and len(attributes.category_name) and len(attributes.cat)>
            	AND PO.STOCK_ID IN 
                					(
                                    	SELECT        
                                        	STOCK_ID
										FROM            
                                        	STOCKS WITH (NOLOCK)
										WHERE        
                                        	STOCK_CODE LIKE '#attributes.cat#%'
                                    )
            </cfif>
            <cfif isdefined('attributes.record_emp_name') and len(attributes.record_emp_name) and len(attributes.record_emp_id)>
            	AND PO.RECORD_EMP = #attributes.record_emp_id#
            </cfif>
            <cfif isdefined('attributes.member_name') and len(attributes.member_name) and (len(attributes.company_id) or len(attributes.consumer_id))>
            	AND E.ORDER_ROW_ID IN 
                					(
                                    	SELECT        
                                        	ORR.ORDER_ROW_ID
										FROM            
                                        	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                         					ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID
										WHERE  
                                        	<cfif len(attributes.company_id)>      
                                        		O.COMPANY_ID = #attributes.company_id#
                                          	<cfelseif len(attributes.consumer_id)>
                                            	O.CONSUMER_ID = #attributes.consumer_id#
                                            </cfif>
                                    )
          	</cfif>
            
            <cfif isdefined('attributes.operation_type_id') and len(attributes.operation_type_id)>
                AND PO.P_ORDER_ID <cfif isdefined('attributes.reverse_answer')>NOT</cfif> IN 
                                    (
                                        SELECT        
                                            P_ORDER_ID
                                        FROM           
                                            PRODUCTION_OPERATION WITH (NOLOCK)
                                        WHERE        
                                            OPERATION_TYPE_ID = #attributes.operation_type_id#
                                    
                                    )
            </cfif>
		ORDER BY 
        	<cfif attributes.list_type eq 3>
				LOT_NO,STOCK_ID
            <cfelseif attributes.list_type eq 4>  
               	P_ORDER_PARTI_NUMBER,STOCK_ID
			<cfelseif attributes.list_type eq 5>
            	STOCK_ID
            <cfelse>
				<cfif attributes.sort_type eq 0>
                    S.PRODUCT_NAME
                <cfelseif attributes.sort_type eq 1>
                    S.PRODUCT_NAME desc
                <cfelseif attributes.sort_type eq 2>
                    E.LOT_NO
                <cfelseif attributes.sort_type eq 3>
                    E.LOT_NO desc
                <cfelseif attributes.sort_type eq 4>
                    E.CUTTING_FINISH_DATE
                <cfelseif attributes.sort_type eq 5>
                    E.CUTTING_FINISH_DATE desc
              	<cfelseif attributes.sort_type eq 6>
                    E.LOT_NO,PACKAGE_NUMBER
                <cfelseif attributes.sort_type eq 10>
                    E.DP_ORDER_ID
                </cfif>
            </cfif>
  	</cfquery>
    <!---<cfdump var="#get_production_orders#"><cfabort>--->
<cfelse>
    <cfquery name="get_production_orders" datasource="#dsn3#">
        SELECT   
	    	E.IFLOW_P_ORDER_ID,
            E.ACTION_TYPE,
            E.REL_P_ORDER_ID, 
            E.PROD_ORDER_STAGE,    
            E.PRODUCT_TYPE, 
			S.PRODUCT_ID, 
            S.PRODUCT_NAME, 
            S.PRODUCT_CODE,
            ISNULL(S.IS_PROTOTYPE,0) IS_PROTOTYPE,
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
            ROUND(AMT.URETILEN, 2) AS AMOUNT,
            O.COMPANY_ID,
            O.CONSUMER_ID,
            O.EMPLOYEE_ID,
            O.ORDER_NUMBER,
            O.DELIVERDATE,
            O.ORDER_ID,
            EIPOP.P_ORDER_PARTI_DATE AS P_ORDER_PARTI_DATE,
         	EIPOP.P_ORDER_PARTI_NUMBER AS P_ORDER_PARTI_NUMBER,
        	EIPOP.P_ORDER_PARTI_DETAIL AS P_ORDER_PARTI_DETAIL,
            ISNULL(AMT.TOTAL_URETILEN_EMIR,0) AS TOTAL_URETILEN_EMIR,
            ISNULL(AMT.TOTAL_EMIR,0) AS TOTAL_EMIR,
            ISNULL((SELECT IS_STAGE FROM EZGI_IFLOW_PRODUCTION_ORDER_LOT_NO_STAGE WITH (NOLOCK) WHERE IFLOW_P_ORDER_ID = E.IFLOW_P_ORDER_ID),4) AS IS_STAGE,
            (SELECT TOP (1) PP.PROJECT_ID FROM PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN #dsn_alias#.PRO_PROJECTS AS PP WITH (NOLOCK) ON PO.PROJECT_ID = PP.PROJECT_ID WHERE PO.LOT_NO = E.LOT_NO) AS PROJECT_ID,
            (SELECT TOP (1) PP.PROJECT_NUMBER FROM PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN #dsn_alias#.PRO_PROJECTS AS PP WITH (NOLOCK) ON PO.PROJECT_ID = PP.PROJECT_ID WHERE PO.LOT_NO = E.LOT_NO) AS PROJECT_NUMBER,
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

                        	EZGI_DESIGN_PACKAGE WITH (NOLOCK)
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
          	END AS RELATED_ID
        FROM        
          	EZGI_IFLOW_PRODUCTION_ORDERS AS E WITH (NOLOCK) INNER JOIN
         	STOCKS AS S WITH (NOLOCK) ON E.STOCK_ID = S.STOCK_ID INNER JOIN
       		PRODUCT_UNIT AS P WITH (NOLOCK) ON S.PRODUCT_ID = P.PRODUCT_ID LEFT JOIN 
            (
    			SELECT 
                    LOT_NO, 
                    SUM(URETILEN) / NULLIF(SUM(EMIR), 0) * 100 AS URETILEN,
                    NULLIF(SUM(EMIR),0) AS TOTAL_EMIR,
                    NULLIF(SUM(URETILEN),0) AS TOTAL_URETILEN_EMIR
                FROM 
                	EZGI_IFLOW_PRODUCTION_ORDER_LOT_NO WITH (NOLOCK)
                GROUP BY 
                LOT_NO
			) AS AMT ON AMT.LOT_NO = E.LOT_NO LEFT JOIN 
            ORDER_ROW AS ORR WITH (NOLOCK) ON ORR.ORDER_ROW_ID = E.ORDER_ROW_ID LEFT JOIN 
            ORDERS AS O WITH (NOLOCK) ON O.ORDER_ID = ORR.ORDER_ID INNER JOIN
            EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPOP WITH (NOLOCK) ON EIPOP.P_ORDER_PARTI_ID = E.REL_P_ORDER_ID
        WHERE
            ISNULL(P.IS_MAIN,0) = 1
            <cfif isdefined('attributes.e_iflow_p_order_id_list') and len(attributes.e_iflow_p_order_id_list)>
            	AND E.IFLOW_P_ORDER_ID IN (#attributes.e_iflow_p_order_id_list#)
           	</cfif>
            <cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
              	AND E.MASTER_PLAN_ID = #attributes.master_plan_id#
            </cfif>
            <cfif isdefined('attributes.rel_p_order_id') and len(attributes.rel_p_order_id)>
            	AND E.REL_P_ORDER_ID = #attributes.rel_p_order_id#
            </cfif>
            <cfif isdefined('attributes.product_type') and len(attributes.product_type)>
                AND E.PRODUCT_TYPE = #attributes.product_type#
            </cfif>
            <cfif isdefined('attributes.keyword') and len(attributes.keyword)>
                AND 
                (
                    E.LOT_NO LIKE '%#attributes.keyword#%' OR
                    S.PRODUCT_NAME LIKE '%#attributes.keyword#%' 
               	)
            </cfif>
            
            <cfif isdefined('attributes.durum_emir') and attributes.durum_emir eq 1>
               	AND ISNULL((SELECT IS_STAGE FROM EZGI_IFLOW_PRODUCTION_ORDER_LOT_NO_STAGE WHERE IFLOW_P_ORDER_ID = E.IFLOW_P_ORDER_ID),4) = 2
         	<cfelseif isdefined('attributes.durum_emir') and attributes.durum_emir eq 2>
           		AND ISNULL((SELECT IS_STAGE FROM EZGI_IFLOW_PRODUCTION_ORDER_LOT_NO_STAGE WHERE IFLOW_P_ORDER_ID = E.IFLOW_P_ORDER_ID),4) <> 2
            </cfif>
            <cfif isdefined('attributes.category_name') and len(attributes.category_name) and len(attributes.cat)>
            	AND S.STOCK_ID IN 
                					(
                                    	SELECT        
                                        	STOCK_ID
										FROM            
                                        	STOCKS WITH (NOLOCK)
										WHERE        
                                        	STOCK_CODE LIKE '#attributes.cat#%'
                                    )
            </cfif>
            <cfif isdefined('attributes.record_emp_name') and len(attributes.record_emp_name) and len(attributes.record_emp_id)>
            	AND E.RECORD_EMP = #attributes.record_emp_id#
            </cfif>
            <cfif isdefined('attributes.member_name') and len(attributes.member_name) and (len(attributes.company_id) or len(attributes.consumer_id))>
            	AND E.ORDER_ROW_ID IN 
                					(
                                    	SELECT        
                                        	ORR.ORDER_ROW_ID
										FROM            
                                        	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                         					ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID
										WHERE  
                                        	<cfif len(attributes.company_id)>      
                                        		O.COMPANY_ID = #attributes.company_id#
                                          	<cfelseif len(attributes.consumer_id)>
                                            	O.CONSUMER_ID = #attributes.consumer_id#
                                            </cfif>
                                    )
          	</cfif>
        ORDER BY
            <cfif attributes.sort_type eq 3>
                E.LOT_NO desc
            <cfelseif attributes.sort_type eq 4>
                E.CUTTING_FINISH_DATE
            <cfelseif attributes.sort_type eq 5>
                E.CUTTING_FINISH_DATE desc
          	<cfelse>
            	EIPOP.P_ORDER_PARTI_SORT_NO,
       			E.P_ORDER_SORT_NO,
                EIPOP.P_ORDER_PARTI_NUMBER,
                E.LOT_NO
            </cfif>
    </cfquery>

</cfif>
<!---<cfdump var="#get_production_orders#">--->