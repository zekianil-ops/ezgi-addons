<!---
    File: dsp_ezgi_iflow_product_metarial_need.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfif session.ep.userid eq 1053>

</cfif>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.oby" default="1">
<cfparam name="attributes.department_id" default="">
<cfparam name="attributes.list_type" default="1">
<cfparam name="attributes.list_tur" default="1">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.price_cat" default="-1">
<cfparam name="attributes.is_excel" default="">
<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.project_head" default="">
<cfparam name="attributes.category_name" default="">
<cfparam name="attributes.cat" default="">
<cfparam name="attributes.cat_id" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.stock_id" default="">
<cf_xml_page_edit>
<cfquery name="get_money" datasource="#dsn2#">
	SELECT MONEY, RATE1, RATE2 FROM SETUP_MONEY WITH (NOLOCK)
</cfquery>
<cfset _t1_fiyat = 0>
<cfset t1_fiyat = 0>
<cfset t1_fiyat0 = 0>
<cfoutput query="get_money">
 	<cfset 't1_fiyat#MONEY#'=0>
</cfoutput>
<cfquery name="get_department" datasource="#dsn#">
	SELECT 
		DEPARTMENT_ID,
		DEPARTMENT_HEAD
	FROM
		BRANCH B WITH (NOLOCK),
		DEPARTMENT D WITH (NOLOCK)
	WHERE
		B.COMPANY_ID = #session.ep.company_id# AND
		B.BRANCH_ID = D.BRANCH_ID AND
        D.DEPARTMENT_STATUS = 1 AND
        D.IS_PRODUCTION = 1 AND
		B.BRANCH_ID IN(SELECT BRANCH_ID FROM EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE = #session.ep.position_code#)
	ORDER BY 
		DEPARTMENT_HEAD
</cfquery>
<cfset branch_dep_list=valuelist(get_department.department_id,',')>
<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT * FROM STOCKS_LOCATION WITH (NOLOCK) WHERE STATUS = 1
</cfquery>
<cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
  	<cfquery name="get_master_plan_info" datasource="#dsn3#">
   		SELECT * FROM EZGI_IFLOW_MASTER_PLAN WITH (NOLOCK) WHERE MASTER_PLAN_ID = #attributes.master_plan_id#
  	</cfquery>
</cfif>
<cfif isdefined('attributes.master_alt_plan_id') and len(attributes.master_alt_plan_id)>
  	<cfquery name="get_master_plan_info" datasource="#dsn3#">
   		SELECT MASTER_ALT_PLAN_NO MASTER_PLAN_NUMBER FROM EZGI_MASTER_ALT_PLAN WITH (NOLOCK) WHERE MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
  	</cfquery>
</cfif>
<cfif isdefined('attributes.master_plan_id_list') and len(attributes.master_plan_id_list)>
    <cfquery name="get_master_ids" datasource="#dsn3#">
        SELECT        
            PO.P_ORDER_ID
        FROM            
            EZGI_IFLOW_MASTER_PLAN AS EM WITH (NOLOCK) INNER JOIN
            EZGI_IFLOW_PRODUCTION_ORDERS AS EI WITH (NOLOCK) ON EM.MASTER_PLAN_ID = EI.MASTER_PLAN_ID INNER JOIN
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EI.LOT_NO = PO.LOT_NO
        WHERE        
            EM.MASTER_PLAN_ID IN (#attributes.master_plan_id_list#)
	</cfquery>
   	<cfif get_master_ids.recordcount>
    	<cfset attributes.p_order_id_list = ValueList(get_master_ids.P_ORDER_ID)>
    </cfif>

<cfelseif isdefined('attributes.master_up_plan_id_list') and len(attributes.master_up_plan_id_list)>
	<cfset sub_p_order_id = ''>
	<cfquery name="get_master_ids" datasource="#dsn3#">
        SELECT 
        	EMPR.P_ORDER_ID
		FROM     
        	EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) INNER JOIN
            EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) ON EMAP.MASTER_ALT_PLAN_ID = EMPR.MASTER_ALT_PLAN_ID
		WHERE  
        	EMAP.MASTER_ALT_PLAN_ID IN (#attributes.master_up_plan_id_list#)
	</cfquery>
   	<cfif get_master_ids.recordcount>
        <cfset sub_p_order_id = ValueList(get_master_ids.P_ORDER_ID)>
    <cfelse>
    	<script type="text/javascript">
            alert("Seçilen Alt Planlarda Üretim Planı Bulunmamaktadır.!");
            window.close()
        </script>
    	<cfabort>
    </cfif>
</cfif>
<cfif isdefined('is_form_submitted')>
	<cfif isdefined('attributes.p_order_id_list') or isdefined('attributes.master_plan_id_list') >
    	<cfquery name="get_sub_product_id" datasource="#dsn3#">
            SELECT        
                P_ORDER_ID
            FROM            
                (
                    SELECT        
                        PPO2.P_ORDER_ID
                    FROM        
                   		PRODUCTION_ORDERS AS PPO1 WITH (NOLOCK) LEFT OUTER JOIN
                    	PRODUCTION_ORDERS AS PPO2 WITH (NOLOCK) ON PPO1.P_ORDER_ID = PPO2.PO_RELATED_ID
                    WHERE        
                        <cfif isdefined('attributes.master_plan_id_list') and len(attributes.master_plan_id_list)>
                        	PPO1.P_ORDER_ID IN 
                            				(
                                            	SELECT        
                                                    PO.P_ORDER_ID
                                                FROM            
                                                    EZGI_IFLOW_MASTER_PLAN AS EM WITH (NOLOCK) INNER JOIN
                                                    EZGI_IFLOW_PRODUCTION_ORDERS AS EI WITH (NOLOCK) ON EM.MASTER_PLAN_ID = EI.MASTER_PLAN_ID INNER JOIN
                                                    PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EI.LOT_NO = PO.LOT_NO
                                                WHERE        
                                                    EM.MASTER_PLAN_ID IN (#attributes.master_plan_id_list#)
                                            )
                       	<cfelse>        
                        	PPO1.P_ORDER_ID IN (#attributes.p_order_id_list#)
                        </cfif>
                    UNION ALL
                    SELECT        
                        PPO3.P_ORDER_ID
                    FROM            
                        PRODUCTION_ORDERS AS PPO3 WITH (NOLOCK) RIGHT OUTER JOIN
                        PRODUCTION_ORDERS AS PPO2 WITH (NOLOCK) ON PPO3.PO_RELATED_ID = PPO2.P_ORDER_ID RIGHT OUTER JOIN
                        PRODUCTION_ORDERS AS PPO1 WITH (NOLOCK) ON PPO2.PO_RELATED_ID = PPO1.P_ORDER_ID
                    WHERE 
                    	<cfif isdefined('attributes.master_plan_id_list') and len(attributes.master_plan_id_list)>
                        	PPO1.P_ORDER_ID IN 
                            				(
                                            	SELECT        
                                                    PO.P_ORDER_ID
                                                FROM            
                                                    EZGI_IFLOW_MASTER_PLAN AS EM WITH (NOLOCK) INNER JOIN
                                                    EZGI_IFLOW_PRODUCTION_ORDERS AS EI WITH (NOLOCK) ON EM.MASTER_PLAN_ID = EI.MASTER_PLAN_ID INNER JOIN
                                                    PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EI.LOT_NO = PO.LOT_NO
                                                WHERE        
                                                    EM.MASTER_PLAN_ID IN (#attributes.master_plan_id_list#)
                                            )
                       	<cfelse>        
                        	PPO1.P_ORDER_ID IN (#attributes.p_order_id_list#)
                        </cfif>
                    UNION ALL
                    SELECT        
                        PPO4.P_ORDER_ID
                    FROM            
                        PRODUCTION_ORDERS AS PPO1 WITH (NOLOCK) LEFT OUTER JOIN
                        PRODUCTION_ORDERS AS PPO2 WITH (NOLOCK) LEFT OUTER JOIN
                        PRODUCTION_ORDERS AS PPO3 WITH (NOLOCK) LEFT OUTER JOIN
                        PRODUCTION_ORDERS AS PPO4 WITH (NOLOCK) ON 
                        											PPO3.P_ORDER_ID = PPO4.PO_RELATED_ID ON 
                                                                    PPO2.P_ORDER_ID = PPO3.PO_RELATED_ID ON 
                             										PPO1.P_ORDER_ID = PPO2.PO_RELATED_ID
                    WHERE        
                        <cfif isdefined('attributes.master_plan_id_list') and len(attributes.master_plan_id_list)>
                        	PPO1.P_ORDER_ID IN 
                            				(
                                            	SELECT        
                                                    PO.P_ORDER_ID
                                                FROM            
                                                    EZGI_IFLOW_MASTER_PLAN AS EM WITH (NOLOCK) INNER JOIN
                                                    EZGI_IFLOW_PRODUCTION_ORDERS AS EI WITH (NOLOCK) ON EM.MASTER_PLAN_ID = EI.MASTER_PLAN_ID INNER JOIN
                                                    PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EI.LOT_NO = PO.LOT_NO
                                                WHERE        
                                                    EM.MASTER_PLAN_ID IN (#attributes.master_plan_id_list#)
                                            )
                       	<cfelse>        
                        	PPO1.P_ORDER_ID IN (#attributes.p_order_id_list#)
                        </cfif>
                    UNION ALL
                    SELECT        
                        PPO5.P_ORDER_ID
                    FROM            
                        PRODUCTION_ORDERS AS PPO1 WITH (NOLOCK) LEFT OUTER JOIN
                        PRODUCTION_ORDERS AS PPO2 WITH (NOLOCK) LEFT OUTER JOIN
                        PRODUCTION_ORDERS AS PPO3 WITH (NOLOCK) LEFT OUTER JOIN
                        PRODUCTION_ORDERS AS PPO5 WITH (NOLOCK) RIGHT OUTER JOIN
                        PRODUCTION_ORDERS AS PPO4 WITH (NOLOCK) ON 
                        											PPO5.PO_RELATED_ID = PPO4.P_ORDER_ID ON 
                                                                    PPO3.P_ORDER_ID = PPO4.PO_RELATED_ID ON 
                                                                    PPO2.P_ORDER_ID = PPO3.PO_RELATED_ID ON 
                             										PPO1.P_ORDER_ID = PPO2.PO_RELATED_ID
                    WHERE        
                        <cfif isdefined('attributes.master_plan_id_list') and len(attributes.master_plan_id_list)>
                        	PPO1.P_ORDER_ID IN 
                            				(
                                            	SELECT        
                                                    PO.P_ORDER_ID
                                                FROM            
                                                    EZGI_IFLOW_MASTER_PLAN AS EM WITH (NOLOCK) INNER JOIN
                                                    EZGI_IFLOW_PRODUCTION_ORDERS AS EI WITH (NOLOCK) ON EM.MASTER_PLAN_ID = EI.MASTER_PLAN_ID INNER JOIN
                                                    PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EI.LOT_NO = PO.LOT_NO
                                                WHERE        
                                                    EM.MASTER_PLAN_ID IN (#attributes.master_plan_id_list#)
                                            )
                       	<cfelse>        
                        	PPO1.P_ORDER_ID IN (#attributes.p_order_id_list#)
                        </cfif>
                ) AS TBL
            WHERE        
                NOT (P_ORDER_ID IS NULL)
      	</cfquery>
        <cfset sub_p_order_id = ValueList(get_sub_product_id.P_ORDER_ID)>
        <cfif ListLen(sub_p_order_id)>
        	<cfset sub_p_order_id = '#attributes.p_order_id_list#,#sub_p_order_id#'>
		<cfelse>
        	<cfset sub_p_order_id = attributes.p_order_id_list>
        </cfif>
    </cfif>

	
    <cfif (isdefined('attributes.iid') and listlen(attributes.iid)) or (isdefined('attributes.p_order_id_list') and ListLen(attributes.p_order_id_list)) or (isdefined('attributes.master_plan_id_list') and len (attributes.master_plan_id_list)) or (isdefined('attributes.master_up_plan_id_list') and len (attributes.master_up_plan_id_list))>
    	<cfif attributes.list_type eq 3>
        	<cfquery name="get_total_material" datasource="#dsn3#">
        		SELECT        
                	EDPR.PIECE_DETAIL, 
                    S.STOCK_ID, 
                    S.PRODUCT_ID, 
                    S.PROPERTY, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_CODE,
                    S.PRODUCT_CODE_2,
                    S.PRODUCT_CATID, 
                    PU.MAIN_UNIT, 
                    SUM(EPO.QUANTITY * ISNULL(EDPR.AGIRLIK, 1)) AS ADET, 
               		SUM(EPO.QUANTITY * EDPR.PIECE_AMOUNT) AS AMOUNT
                    <cfif isdefined('attributes.is_lot_group')>
                    	,EPO.LOT_NO
                    </cfif>
				FROM            
                	EZGI_DESIGN_MAIN_ROW AS EDMR WITH (NOLOCK) INNER JOIN
                 	EZGI_DESIGN_PIECE_ROWS AS EDPR WITH (NOLOCK) ON EDMR.DESIGN_MAIN_ROW_ID = EDPR.DESIGN_MAIN_ROW_ID INNER JOIN
                  	EZGI_IFLOW_PRODUCTION_ORDERS AS EPO WITH (NOLOCK) ON EDMR.MAIN_SPECT_RELATED_ID = EPO.SPECT_MAIN_ID INNER JOIN
                	STOCKS AS S WITH (NOLOCK) ON EDPR.PIECE_RELATED_ID = S.STOCK_ID INNER JOIN
                 	PRODUCT_UNIT AS PU WITH (NOLOCK) ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
				WHERE        
                	EPO.IFLOW_P_ORDER_ID IN (#attributes.iid#) AND 
                    S.PRODUCT_CODE LIKE N'01.150%'
                    <cfif len(attributes.keyword)>
                        AND
                        (
                            S.PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
                            S.PRODUCT_CODE LIKE '%#attributes.keyword#%' OR
                            S.PRODUCT_CODE_2 LIKE '%#attributes.keyword#%'
                        )
                    </cfif> 
                    <cfif not  attributes.list_type eq 4> <!---Tümü değilse--->
						<cfif attributes.list_type eq 1><!--- MRP Ürünler--->
                            AND ISNULL(S.IS_LIMITED_STOCK,0) = 0
                        <cfelseif attributes.list_type eq 2><!--- Kanban Ürünler--->
                            AND S.IS_LIMITED_STOCK = 1
                        </cfif>
                  	</cfif>
                    <cfif isdefined('attributes.cat') and len(attributes.cat) and len(attributes.category_name)>
                        AND S.PRODUCT_CODE LIKE '#attributes.cat#%' 
                    </cfif>  
                    <cfif len(attributes.product_name) and len(attributes.stock_id)>
                        AND S.STOCK_ID = #attributes.stock_id# 
                    </cfif> 
              	GROUP BY
                	EDPR.PIECE_DETAIL, 
                    S.STOCK_ID, 
                    S.PRODUCT_ID, 
                    S.PROPERTY, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_CODE, 
                    S.PRODUCT_CODE_2,
                    S.IS_LIMITED_STOCK,
                    S.PRODUCT_CATID,
                    PU.MAIN_UNIT
                    <cfif isdefined('attributes.is_lot_group')>
                    ,EPO.LOT_NO
                    </cfif>
                    UNION ALL
                    SELECT        
                        EDPRR.PIECE_DETAIL, 
                        S.STOCK_ID, 
                        S.PRODUCT_ID, 
                        S.PROPERTY, 
                        S.PRODUCT_NAME, 
                        S.PRODUCT_CODE,
                        S.PRODUCT_CODE_2,
                        S.PRODUCT_CATID, 
                        PU.MAIN_UNIT, 
                        SUM(EPO.QUANTITY * ISNULL(EDPR.AGIRLIK, 1)) AS ADET, 
                        SUM(EPO.QUANTITY * EDPR.PIECE_AMOUNT * EDPRR.AMOUNT) AS AMOUNT
                        <cfif isdefined('attributes.is_lot_group')>
                            ,EPO.LOT_NO
                        </cfif>
                    FROM            
                        EZGI_DESIGN_PIECE_ROW AS EDPRR INNER JOIN
                        EZGI_DESIGN_MAIN_ROW AS EDMR WITH (NOLOCK) INNER JOIN
                        EZGI_DESIGN_PIECE_ROWS AS EDPR WITH (NOLOCK) ON EDMR.DESIGN_MAIN_ROW_ID = EDPR.DESIGN_MAIN_ROW_ID INNER JOIN
                        EZGI_IFLOW_PRODUCTION_ORDERS AS EPO WITH (NOLOCK) ON EDMR.MAIN_SPECT_RELATED_ID = EPO.SPECT_MAIN_ID ON EDPRR.PIECE_ROW_ID = EDPR.PIECE_ROW_ID INNER JOIN
                        PRODUCT_UNIT AS PU WITH (NOLOCK) INNER JOIN
                        STOCKS AS S WITH (NOLOCK) ON PU.PRODUCT_UNIT_ID = S.PRODUCT_UNIT_ID ON EDPRR.STOCK_ID = S.STOCK_ID
                    WHERE
                        EDPRR.PIECE_DETAIL IS NOT NULL AND
                        EPO.IFLOW_P_ORDER_ID IN (#attributes.iid#) AND 
                        S.PRODUCT_CODE LIKE N'01.150%'
                        <cfif len(attributes.keyword)>
                            AND
                            (
                                S.PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
                                S.PRODUCT_CODE LIKE '%#attributes.keyword#%' OR
                                S.PRODUCT_CODE_2 LIKE '%#attributes.keyword#%'
                            )
                        </cfif> 
                        <cfif not  attributes.list_type eq 4> <!---Tümü değilse--->
                            <cfif attributes.list_type eq 1><!--- MRP Ürünler--->
                                AND ISNULL(S.IS_LIMITED_STOCK,0) = 0
                            <cfelseif attributes.list_type eq 2><!--- Kanban Ürünler--->
                                AND S.IS_LIMITED_STOCK = 1
                            </cfif>
                        </cfif>
                        <cfif isdefined('attributes.cat') and len(attributes.cat) and len(attributes.category_name)>
                            AND S.PRODUCT_CODE LIKE '#attributes.cat#%' 
                        </cfif>  
                        <cfif len(attributes.product_name) and len(attributes.stock_id)>
                            AND S.STOCK_ID = #attributes.stock_id# 
                        </cfif> 
                    GROUP BY
                        EDPRR.PIECE_DETAIL, 
                        S.STOCK_ID, 
                        S.PRODUCT_ID, 
                        S.PROPERTY, 
                        S.PRODUCT_NAME, 
                        S.PRODUCT_CODE, 
                        S.PRODUCT_CODE_2,
                        S.IS_LIMITED_STOCK,
                        S.PRODUCT_CATID,
                        PU.MAIN_UNIT
                        <cfif isdefined('attributes.is_lot_group')>
                        ,EPO.LOT_NO
                        </cfif>
                    ORDER BY
                        <cfif isdefined('attributes.is_lot_group')>
                            EPO.LOT_NO,
                        </cfif>
                        <cfif attributes.oby eq 1>
                            S.PRODUCT_CODE
                        <cfelse>
                            S.PRODUCT_NAME
                        </cfif>
          	</cfquery>
        <cfelse>
            <cfquery name="get_total_material" datasource="#dsn3#">
                SELECT        
                    POS.STOCK_ID, 
                    S.PRODUCT_ID, 
                    S.PROPERTY, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_CODE, 
                    S.PRODUCT_CODE_2,
                    S.PRODUCT_CATID,
                    S.IS_LIMITED_STOCK, 
                    (SELECT MAIN_UNIT FROM #dsn1_alias#.PRODUCT_UNIT WHERE PRODUCT_ID = S.PRODUCT_ID AND IS_MAIN = 1) AS MAIN_UNIT,
                    <cfif isdefined('attributes.real_material')>
                        SUM(POS.AMOUNT*ISNULL((PO.QUANTITY - TBL.AMOUNT) / PO.QUANTITY, 1)) AS AMOUNT
                    <cfelse>
                        SUM(POS.AMOUNT) AS AMOUNT
                    </cfif>
                    <cfif isdefined('attributes.is_lot_group')>
                    ,PO.LOT_NO
                    </cfif>
                FROM            
                    PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
                    PRODUCTION_ORDERS_STOCKS AS POS WITH (NOLOCK) ON PO.P_ORDER_ID = POS.P_ORDER_ID INNER JOIN
                    STOCKS AS S WITH (NOLOCK) ON POS.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
                    (
                        SELECT        
                            POR.P_ORDER_ID, SUM(PORR.AMOUNT) AS AMOUNT
                        FROM            
                            PRODUCTION_ORDER_RESULTS AS POR WITH (NOLOCK) INNER JOIN
                            PRODUCTION_ORDER_RESULTS_ROW AS PORR WITH (NOLOCK) ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
                        WHERE        
                            PORR.TYPE = 1 AND 
                            POR.IS_STOCK_FIS = 1
                        GROUP BY POR.P_ORDER_ID
                    ) AS TBL ON PO.P_ORDER_ID = TBL.P_ORDER_ID
                WHERE  
                	1=1
                    <cfif len(attributes.product_name) and len(attributes.stock_id)>
                        AND S.STOCK_ID = #attributes.stock_id# 
                    </cfif> 
                	<cfif isdefined('attributes.project_id') and len(attributes.project_id) and len(attributes.project_head)>
                    	AND PO.P_ORDER_ID IN (#attributes.project_id#) 
                    </cfif>
                	<cfif isdefined('attributes.master_plan_id_list') and len(attributes.master_plan_id_list)>
                     	AND PO.P_ORDER_ID IN 
                            				(
                                            	SELECT        
                                                    PO.P_ORDER_ID
                                                FROM            
                                                    EZGI_IFLOW_MASTER_PLAN AS EM WITH (NOLOCK) INNER JOIN
                                                    EZGI_IFLOW_PRODUCTION_ORDERS AS EI WITH (NOLOCK) ON EM.MASTER_PLAN_ID = EI.MASTER_PLAN_ID INNER JOIN
                                                    PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EI.LOT_NO = PO.LOT_NO
                                                WHERE        
                                                    EM.MASTER_PLAN_ID IN (#attributes.master_plan_id_list#)
                                            ) 
                    <cfelseif isdefined('attributes.p_order_id_list')>
                        AND PO.P_ORDER_ID IN (#sub_p_order_id#) 
                  	<cfelseif isdefined('attributes.master_up_plan_id_list') and len(attributes.master_up_plan_id_list)>
                    	AND PO.LOT_NO IN
                             			(
                                            SELECT 
                                                LOT_NO
                                            FROM 
                                                PRODUCTION_ORDERS E WITH (NOLOCK)
                                            WHERE 
                                                P_ORDER_ID IN (#sub_p_order_id#)
                                        ) 
                    <cfelseif isdefined('attributes.iid')> 
                    	<cfif isdefined('attributes.master_alt_plan_id')>   
                        	 AND PO.LOT_NO IN
                             			(
                                            SELECT 
                                                LOT_NO
                                            FROM 
                                                PRODUCTION_ORDERS E WITH (NOLOCK)
                                            WHERE 
                                                P_ORDER_ID IN (#attributes.iid#)
                                        ) 

                        <cfelse> 
                            AND PO.LOT_NO IN
                                        (
                                            SELECT 
                                                LOT_NO
                                            FROM 
                                                EZGI_IFLOW_PRODUCTION_ORDERS E WITH (NOLOCK)
                                            WHERE 
                                                IFLOW_P_ORDER_ID IN (#attributes.iid#)
                                        ) 
                     	</cfif>
                   </cfif>
                    <cfif len(attributes.keyword)>
                        AND
                        (
                            S.PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
                            S.PRODUCT_CODE LIKE '%#attributes.keyword#%' OR
                            S.PRODUCT_CODE_2 LIKE '%#attributes.keyword#%'
                        )
                    </cfif> 
                    <cfif isdefined('attributes.cat') and len(attributes.cat) and len(attributes.category_name)>
                        AND S.PRODUCT_CODE LIKE '#attributes.cat#%' 
                    </cfif>
					<cfif attributes.list_type eq 1><!--- MRP Ürünler İse--->
                     	AND ISNULL(S.IS_LIMITED_STOCK,0) = 0
                     	AND S.IS_PURCHASE = 1 
                    	AND S.IS_PRODUCTION = 0
                	<cfelseif attributes.list_type eq 2><!--- Kanban Ürünler İse--->
                      	AND 
                        	(
                          		((S.IS_LIMITED_STOCK = 1 AND S.IS_PURCHASE = 1 AND S.IS_PRODUCTION = 0)) OR
                                ((S.IS_PRODUCTION = 1 AND S.IS_ADD_XML = 1))
                          	)
                 	<cfelse> <!--- Tümü veya Detaylı İse--->
                   		AND 
                        	(
                           		((S.IS_PURCHASE = 1 AND S.IS_PRODUCTION = 0)) OR
                           		((S.IS_PRODUCTION = 1 AND S.IS_ADD_XML = 1))
                       		)
                	</cfif>
                GROUP BY 
                    POS.STOCK_ID, 
                    S.PRODUCT_ID, 
                    S.PROPERTY, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_CODE, 
                    S.PRODUCT_CODE_2,
                    S.PRODUCT_CATID,
                    S.IS_LIMITED_STOCK
                    <cfif isdefined('attributes.is_lot_group')>
                    ,PO.LOT_NO
                    </cfif>
                ORDER BY
                	<cfif isdefined('attributes.is_lot_group')>
                    	PO.LOT_NO,
                    </cfif>
                    <cfif attributes.oby eq 1>
                        S.PRODUCT_CODE
                    <cfelse>
                        S.PRODUCT_NAME
                    </cfif>
            </cfquery>
        </cfif>
        <cfif isdefined('attributes.is_lot_group')>
            	<cfset lot_no_list = ValueList(get_total_material.LOT_NO)>
                <cfset lot_no_list = ListDeleteDuplicates(lot_no_list,',')>
                <cfquery name="get_lot_order" datasource="#dsn3#">
                	SELECT  
                    	CASE
                            WHEN O.COMPANY_ID IS NOT NULL THEN
                           (
                            SELECT     
                                NICKNAME
                            FROM         
                                #dsn_alias#.COMPANY WITH (NOLOCK)
                            WHERE     
                                COMPANY_ID = O.COMPANY_ID
                            )
                            WHEN O.CONSUMER_ID IS NOT NULL THEN      
                            (	
                            SELECT     
                                CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                            FROM         
                                #dsn_alias#.CONSUMER WITH (NOLOCK)
                            WHERE     
                                CONSUMER_ID = O.CONSUMER_ID
                            )
                            WHEN O.EMPLOYEE_ID IS NOT NULL THEN
                            (
                            SELECT     
                                EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
                            FROM         
                                #dsn_alias#.EMPLOYEES WITH (NOLOCK)
                            WHERE     
                                EMPLOYEE_ID = O.EMPLOYEE_ID
                            )
                    	END AS UNVAN ,     
                    	PO.LOT_NO, 
                        O.ORDER_NUMBER
					FROM            
                   		PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
                      	PRODUCTION_ORDERS_ROW AS PORR WITH (NOLOCK) ON PO.P_ORDER_ID = PORR.PRODUCTION_ORDER_ID INNER JOIN
                      	ORDERS AS O WITH (NOLOCK) ON PORR.ORDER_ID = O.ORDER_ID
					WHERE        
                    	PO.LOT_NO IN (#lot_no_list#) AND 
                        PO.PRODUCTION_LEVEL = '0'
                </cfquery>
                <cfoutput query="get_lot_order">
                	<cfset "UNVAN_#Replace(LOT_NO,' ','','All')#" = UNVAN>
                    <cfset "ORDER_NUMBER_#Replace(LOT_NO,' ','','All')#" = ORDER_NUMBER>
                </cfoutput>
   		</cfif>
    <cfelse>
        <cfset get_total_material.recordcount = 0>
    </cfif>	
    <cfif get_total_material.recordcount>
        <cfset stock_id_list= ValueList( get_total_material.STOCK_ID, ", " )>
		<cfset stock_id_list = listdeleteduplicates(stock_id_list)>
        <!--- DEPOLAR BAZINDA GERÇEK STOKLAR--->
   		<cfquery name="GET_STOCKS_ALL" datasource="#DSN2#">
			SELECT 
				SUM(SR.STOCK_IN-SR.STOCK_OUT) PRODUCT_STOCK,
				SR.STOCK_ID
			FROM 
				STOCKS_ROW AS SR WITH (NOLOCK) INNER JOIN
             	#dsn_alias#.STOCKS_LOCATION AS SL WITH (NOLOCK) ON SR.STORE = SL.DEPARTMENT_ID AND SR.STORE_LOCATION = SL.LOCATION_ID
			WHERE
            	SL.IS_SCRAP = 0 AND 
                <cfif listLen(attributes.department_id)>
                  (
                    <cfloop from="1" to="#listlen(attributes.department_id)#" index="k">
                        SR.STORE = #ListGetAt(ListGetAt(attributes.department_id,k),1,'-')# AND 
                        SR.STORE_LOCATION = #ListGetAt(ListGetAt(attributes.department_id,k),2,'-')#
                        <cfif k neq listlen(attributes.department_id)>OR</cfif>
                    </cfloop>
                    ) AND 
                </cfif>
             	SR.STOCK_ID IN (#stock_id_list#)
			GROUP BY
				SR.STOCK_ID    	
       	</cfquery>
        <cfoutput query="GET_STOCKS_ALL">
            <cfset 'PRODUCT_STOCK_#STOCK_ID#'= PRODUCT_STOCK>
        </cfoutput>
		<!--- DEPOLAR BAZINDA GERÇEK STOKLAR BİTTİ--->
        
    	<!--- DEPOLARA GÖRE ÜRETİM EMİRLERİ REZERVELER --->
      	<cfquery name="get_product_rezerv_dep" datasource="#dsn3#">
           	SELECT    
            	S1.STOCK_ID,
             	S1.PRODUCT_ID,
            	PO.EXIT_DEP_ID,    
              	<cfif isdefined('attributes.real_material')>
                	SUM(POS.AMOUNT*ISNULL((PO.QUANTITY - TBL.AMOUNT) / PO.QUANTITY, 1)) AS STOCK_AZALT
             	<cfelse>
                 	SUM(POS.AMOUNT) AS STOCK_AZALT
              	</cfif>
          	FROM            
            	PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
              	PRODUCTION_ORDERS_STOCKS AS POS WITH (NOLOCK) ON PO.P_ORDER_ID = POS.P_ORDER_ID INNER JOIN
             	STOCKS AS S1 WITH (NOLOCK) ON POS.STOCK_ID = S1.STOCK_ID LEFT OUTER JOIN
             	(
                	SELECT        
                  		POR.P_ORDER_ID, SUM(PORR.AMOUNT) AS AMOUNT
                 	FROM            
                    	PRODUCTION_ORDER_RESULTS AS POR WITH (NOLOCK) INNER JOIN
                    	PRODUCTION_ORDER_RESULTS_ROW AS PORR WITH (NOLOCK) ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
                 	WHERE        
                     	PORR.TYPE = 1 AND 
                      	POR.IS_STOCK_FIS = 1
                 	GROUP BY POR.P_ORDER_ID
            	) AS TBL ON PO.P_ORDER_ID = TBL.P_ORDER_ID
        	WHERE
            	PO.IS_STOCK_RESERVED = 1 AND
              	PO.P_ORDER_ID = POS.P_ORDER_ID AND
             	PO.IS_DEMONTAJ=0 AND
              	ISNULL(POS.STOCK_ID,0)>0 AND
              	POS.IS_SEVK <> 1 AND
				ISNULL(IS_FREE_AMOUNT,0) = 0 AND
            	<cfif listLen(attributes.department_id)>
            		(

                    <cfloop from="1" to="#listlen(attributes.department_id)#" index="k">
                       	PO.EXIT_DEP_ID = #ListGetAt(ListGetAt(attributes.department_id,k),1,'-')#
                        <cfif k neq listlen(attributes.department_id)>OR</cfif>
                    </cfloop>
                    ) AND 
                </cfif>
            	POS.STOCK_ID IN (#stock_id_list#) AND
                PO.QUANTITY > 0
       		GROUP BY 
            	S1.STOCK_ID,
             	S1.PRODUCT_ID,
            	PO.EXIT_DEP_ID
      	</cfquery>
        <cfoutput query="get_product_rezerv_dep">
            <cfset 'PRODUCTION_STOCK_AZALT_#STOCK_ID#'= STOCK_AZALT>
        </cfoutput>
		<!--- DEPOLARA GÖRE ÜRETİM EMİRLERİ REZERVELER BİTTİ--->
        
        <!--- DEPOLARA GÖRE STRATEJİLERDEN MIN STOCK --->
     	<cfquery name="GET_STOCT_STR_DEP" datasource="#DSN3#">
					SELECT 
                    	DEPARTMENT_ID,
                        ISNULL(MINIMUM_STOCK,0) AS MINIMUM_STOCK,
                        ISNULL(REPEAT_STOCK_VALUE,0) AS REPEAT_STOCK_VALUE,
                        ISNULL(PROVISION_TIME,0) AS PROVISION_TIME,
                        ISNULL(MINIMUM_ORDER_STOCK_VALUE,0) AS MINIMUM_ORDER_STOCK_VALUE,
                        ISNULL(STRATEGY_ORDER_TYPE,1) AS STRATEGY_ORDER_TYPE,
                        STOCK_ID 
					FROM 
                    	STOCK_STRATEGY WITH (NOLOCK)
					WHERE 
                    	STOCK_ID IN (#stock_id_list#)
      	</cfquery>
        <cfoutput query="GET_STOCT_STR_DEP">
            <cfset 'MINIMUM_STOCK_#STOCK_ID#'=MINIMUM_STOCK>
            <cfset 'REPEAT_STOCK_VALUE_#STOCK_ID#'=REPEAT_STOCK_VALUE>
            <cfset 'PROVISION_TIME_#STOCK_ID#'=PROVISION_TIME>
            <cfset 'MINIMUM_ORDER_STOCK_VALUE_#STOCK_ID#'=MINIMUM_ORDER_STOCK_VALUE>
            <cfset 'STRATEGY_ORDER_TYPE_#STOCK_ID#'=STRATEGY_ORDER_TYPE>
        </cfoutput>
        <!--- DEPOLARA GÖRE STRATEJİLERDEN MIN STOCK bitti --->
        
         <!--- ÜRÜN FİYATLAR --->
   		<cfquery name="GET_PRICE" datasource="#DSN3#">
         	SELECT
             	P.MONEY,
              	P.PRICE,
              	S.STOCK_ID
          	FROM
				<cfif attributes.price_cat eq -1>
					PRICE_STANDART P WITH (NOLOCK),
				<cfelse>
					PRICE P WITH (NOLOCK),
				</cfif>
           		STOCKS S WITH (NOLOCK)
         	WHERE
            	S.PRODUCT_ID = P.PRODUCT_ID AND
             	S.STOCK_ID IN (#stock_id_list#) AND
				<cfif attributes.price_cat eq -1>
					P.PRICESTANDART_STATUS = 1 AND
					P.PURCHASESALES = 0
				<cfelse>
					ISNULL(P.STOCK_ID,0)=0 AND
					ISNULL(P.SPECT_VAR_ID,0)=0 AND
					P.STARTDATE <= #now()# AND
					(P.FINISHDATE >= #now()# OR P.FINISHDATE IS NULL) AND
					P.PRICE_CATID = #attributes.price_cat#
				</cfif>
       	</cfquery>
        <cfoutput query="GET_PRICE">
            <cfset 'PRICE_#STOCK_ID#'=PRICE>
            <cfset 'MONEY_#STOCK_ID#'=MONEY> 
        </cfoutput>  
        <!--- ÜRÜN FİYATLAR BİTTİ --->
        
        <!--- SATIALMA SİPARİŞ REZERVELER ---> 
        <cfquery name="GET_STOCK_RESERVED" datasource="#DSN3#"><!--- siparisler stoktan dusulecek veya eklenecekse toplamını alalım--->
			SELECT
				STOCK_ID,
				SUM(STOCK_ARTIR) AS ARTAN
			FROM
				GET_STOCK_RESERVED_ROW_LOCATION WITH (NOLOCK)
			WHERE 
				STOCK_ID IN (#stock_id_list#)
                <cfif listLen(attributes.department_id)>
            		AND
                    (
                    <cfloop from="1" to="#listlen(attributes.department_id)#" index="k">
                       	DEPARTMENT_ID = #ListGetAt(ListGetAt(attributes.department_id,k),1,'-')#
                        <cfif k neq listlen(attributes.department_id)>OR</cfif>
                    </cfloop>
                    )
                </cfif>
			GROUP BY 
            	STOCK_ID  
      	</cfquery> 
        <cfoutput query="GET_STOCK_RESERVED">
            <cfset 'PURCHASE_ORDER_ARTAN_#STOCK_ID#'=ARTAN>

        </cfoutput> 
        <!--- SATIALMA SİPARİŞ REZERVELER BİTTİ---> 
        <cfif attributes.list_tur eq 1 or attributes.list_tur eq 3>
			<!--- AÇIK İÇ TALEPLER veya AÇIK SATINALMA TALEPLERİ --->
           	<cfquery name="GET_INTERNALDEMAND" datasource="#dsn3#">
            	<cfif x_internaldemant_yontem eq 0>
                    SELECT 
                        STOCK_ID, 
                        SUM(TBL.QUANTITY - TBL.KARSILANAN) AS IC_TALEP
                    FROM     
                        (
                            SELECT 
                                IR.STOCK_ID, 
                                IR.QUANTITY, 
                                CASE 
                                    WHEN 
                                        IR.QUANTITY > IR2.QUANTITY 
                                    THEN 
                                        IR2.QUANTITY ELSE IR.QUANTITY 
                                END AS KARSILANAN
                            FROM      
                                INTERNALDEMAND AS I WITH (NOLOCK) INNER JOIN
                                INTERNALDEMAND_ROW AS IR WITH (NOLOCK) ON I.INTERNAL_ID = IR.I_ID
                                OUTER APPLY(
                                            SELECT 
                                                ISNULL(SUM(QUANTITY),0) AS QUANTITY
                                            FROM 
                                                ORDER_ROW WITH (NOLOCK)
                                            WHERE 
                                                RELATED_INTERNALDEMAND_ROW_ID = IR.I_ROW_ID
                                ) AS IR2
                            WHERE 
                            	I.IS_ACTIVE = 1 AND   
                                IR.STOCK_ID IN (#stock_id_list#) AND
                                <cfif attributes.list_tur eq 1>
                                    I.DEMAND_TYPE = 0
                                <cfELSEif attributes.list_tur eq 3>
                                    I.DEMAND_TYPE = 1
                                </cfif>
                                <cfif listLen(attributes.department_id)>
                                    AND
                                    (
                                    <cfloop from="1" to="#listlen(attributes.department_id)#" index="k">
                                        I.DEPARTMENT_IN = #ListGetAt(ListGetAt(attributes.department_id,k),1,'-')#
                                        <cfif k neq listlen(attributes.department_id)>OR</cfif>
                                    </cfloop>
                                    )
                                </cfif>
                        ) AS TBL
                    GROUP BY 
                    	STOCK_ID
         		<cfelseif x_internaldemant_yontem eq 1>
                    SELECT 
                        STOCK_ID, 
                        SUM(TBL.QUANTITY - TBL.KARSILANAN) AS IC_TALEP
                    FROM     
                        (
                            SELECT 
                                IR.STOCK_ID, 
                                IR.QUANTITY, 
                                CASE
                                    WHEN 
                                        IR.QUANTITY > ISNULL((SELECT SUM(QUANTITY) AS QUANTITY FROM ORDER_ROW WHERE RELATED_INTERNALDEMAND_ROW_ID = IR.I_ROW_ID),0) 
                                    THEN
                                        ISNULL((
                                                    SELECT        
                                                        SUM(ORR1.QUANTITY) AS QUANTITY
                                                    FROM            
                                                        INTERNALDEMAND_ROW AS IRR INNER JOIN
                                                        INTERNALDEMAND_ROW AS IRR_1 ON IRR.WRK_ROW_ID = IRR_1.WRK_ROW_RELATION_ID INNER JOIN
                                                        ORDER_ROW AS ORR1 ON IRR_1.I_ROW_ID = ORR1.RELATED_INTERNALDEMAND_ROW_ID
                                                    WHERE        
                                                        IRR.I_ROW_ID = IR.I_ROW_ID 
                                                
                                                ), 0) 
                                    ELSE
                                        IR.QUANTITY
                                END AS KARSILANAN
                            FROM      
                                INTERNALDEMAND AS I WITH (NOLOCK) INNER JOIN
                                INTERNALDEMAND_ROW AS IR WITH (NOLOCK) ON I.INTERNAL_ID = IR.I_ID
                            WHERE   
                                IR.STOCK_ID IN (#stock_id_list#) AND
                                <cfif attributes.list_tur eq 1>
                                    I.DEMAND_TYPE = 0
                                <cfELSEif attributes.list_tur eq 3>
                                    I.DEMAND_TYPE = 1
                                </cfif>
                                <cfif listLen(attributes.department_id)>
                                    AND
                                    (
                                    <cfloop from="1" to="#listlen(attributes.department_id)#" index="k">
                                        I.DEPARTMENT_IN = #ListGetAt(ListGetAt(attributes.department_id,k),1,'-')#
                                        <cfif k neq listlen(attributes.department_id)>OR</cfif>
                                    </cfloop>
                                    )
                                </cfif>
                        ) AS TBL
                    GROUP BY 
                    	STOCK_ID
         		</cfif>
            </cfquery>
            <cfoutput query="GET_INTERNALDEMAND">
                <cfset 'IC_TALEP_#STOCK_ID#'= IC_TALEP>
            </cfoutput> 
            <cfif isdefined('attributes.is_net_demand')>
                <cfquery name="GET_INTERNALDEMAND_MASTER_PLAN" datasource="#dsn3#">
                    SELECT        
                        IR.STOCK_ID, 
                        SUM(IR.QUANTITY )AS IC_TALEP
                    FROM            
                        INTERNALDEMAND AS I WITH (NOLOCK) INNER JOIN
                        INTERNALDEMAND_ROW AS IR WITH (NOLOCK) ON I.INTERNAL_ID = IR.I_ID
                    WHERE  
                    	      
                        IR.STOCK_ID IN (#stock_id_list#)
                        <cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id) or isdefined('attributes.master_alt_plan_id') and len(attributes.master_alt_plan_id)> 
                            AND I.REF_NO = '#get_master_plan_info.MASTER_PLAN_NUMBER#'
                        <cfelse>
                            AND I.REF_NO = '-1'
                        </cfif>
                        <cfif attributes.list_tur eq 1>
                         	AND I.DEMAND_TYPE = 0
                       	<cfELSEif attributes.list_tur eq 3>
                         	AND I.DEMAND_TYPE = 1
                     	</cfif>
                    GROUP BY
                        IR.STOCK_ID	
                </cfquery>
                <cfoutput query="GET_INTERNALDEMAND_MASTER_PLAN">
                    <cfset 'IC_TALEP_MASTER_PLAN_#STOCK_ID#'= IC_TALEP>
                </cfoutput>
            </cfif> 
            <!--- AÇIK İÇ TALEPLER BITTI--->
      	<cfelse>
        	<!--- AMBAR FİŞLERİ --->
         	<cfquery name="get_period" datasource="#dsn#">
                SELECT     
                    TOP (2)
                    PERIOD_YEAR
                FROM         
                    SETUP_PERIOD WITH (NOLOCK)
                WHERE     
                    OUR_COMPANY_ID = #session.ep.company_id#
                ORDER BY
                    PERIOD_YEAR desc      
            </cfquery>
            <cfset our_company_years = Valuelist(get_period.PERIOD_YEAR)>
            <cfif isdefined('attributes.is_net_demand') and  isdefined('get_master_plan_info.MASTER_PLAN_NUMBER')>
                <cfquery name="get_ambar_fis" datasource="#dsn3#">
                    SELECT
                        SUM(STOCK_IN) AS AMBAR_STOCK,
                        STOCK_ID
                    FROM
                        (      
                        <cfloop list="#our_company_years#" index="comp_ii">
                            SELECT     
                                SR.STOCK_IN,
                                SR.STOCK_ID
                            FROM         
                                #dsn#_#comp_ii#_#session.ep.company_id#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                                #dsn#_#comp_ii#_#session.ep.company_id#.STOCKS_ROW AS SR WITH (NOLOCK) ON SF.FIS_ID = SR.UPD_ID
                            WHERE     
                                SF.FIS_TYPE = 113 AND 
                                SF.REF_NO = '#get_master_plan_info.MASTER_PLAN_NUMBER#' AND 
                                SR.STOCK_IN > 0 AND 
                                SR.STOCK_ID IN (#stock_id_list#)
                                <cfif listlen(our_company_years) neq 1 and comp_ii neq listlast(our_company_years,',')> UNION ALL </cfif>
                        </cfloop>
                        ) AS TBL
                    GROUP BY
                        STOCK_ID
                </cfquery>
                <cfoutput query="get_ambar_fis">
                    <cfset 'AMBAR_STOCK_#STOCK_ID#' = AMBAR_STOCK>
                </cfoutput>
           	</cfif>
            <!--- AMBAR FİŞLERİ BİTTİ--->
            
        </cfif>
    </cfif>
	<cfset arama_yapilmali = 0>
<cfelse>
	<cfset get_total_material.recordcount = 0>
	<cfset arama_yapilmali = 1>
</cfif>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_total_material.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfform name="list_meterials" method="post" action="#request.self#?fuseaction=#url.fuseaction#" enctype="multipart/form-data">
    	<cf_box scroll="0">
            <input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <cfif isdefined('attributes.iid')>
                <cfinput type="hidden" name="iid" value="#attributes.iid#">
           	</cfif>
            <cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
            	<cfinput type="hidden" name="master_plan_id" value="#attributes.master_plan_id#">
           	</cfif>
            <cfif isdefined('attributes.p_order_id_list') and len(attributes.p_order_id_list)>
                <cfinput type="hidden" name="p_order_id_list" value="#attributes.p_order_id_list#">
            </cfif>
            <cfif isdefined('attributes.master_plan_id_list') and len(attributes.master_plan_id_list)>
                <cfinput type="hidden" name="master_plan_id_list" value="#attributes.master_plan_id_list#">
            </cfif>
            <cfif isdefined('attributes.master_up_plan_id_list') and len(attributes.master_up_plan_id_list)>
                <cfinput type="hidden" name="master_up_plan_id_list" value="#attributes.master_up_plan_id_list#">
            </cfif>
            <cfif isdefined('attributes.master_alt_plan_id')>
            	<cfinput type="hidden" name="master_alt_plan_id" value="#attributes.master_alt_plan_id#">
            </cfif>
            <cf_box_search>
                <div class="form-group">
                    <cfsavecontent variable="filtre"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                	 <cfinput type="text" style="width:150px;" placeholder="#filtre#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group">
                	<cf_get_lang dictionary_id='440.Kalan Üretim İçin Hesapla'>&nbsp;
                  	<input type="checkbox" name="real_material" value="1" <cfif isdefined('attributes.real_material')>checked</cfif>>
                </div>
                <div class="form-group">
                	<cf_get_lang dictionary_id="486.İç Talep Miktarı">&nbsp;
                 	<input type="checkbox" name="demand_amount" value="1" <cfif isdefined('attributes.demand_amount')>checked</cfif>>
                </div>
                <div class="form-group">
                	<cf_get_lang dictionary_id='441.İç Talebi MRP Hesapla'>&nbsp;
                 	<input type="checkbox" name="demand_type" value="1" <cfif isdefined('attributes.demand_type')>checked</cfif>>
                </div>
                <div class="form-group">
                	<cf_get_lang dictionary_id='664.Lot Grupla'>&nbsp;
                  	<input type="checkbox" name="is_lot_group" value="1" <cfif isdefined('attributes.is_lot_group')>checked</cfif>>
                </div>
                <div class="form-group">
                	<cf_get_lang dictionary_id='615.Gerçek İhtiyaç'>&nbsp;
                   	<input type="checkbox" name="is_net_demand" value="1" <cfif isdefined('attributes.is_net_demand')>checked</cfif>>
                </div>
                <div class="form-group">
                	<select name="list_type" id="list_type" style="width:80px; height:20px">
                    	<option value="1" <cfif attributes.list_type eq 1>selected</cfif>><cf_get_lang dictionary_id="1033.MRP Ürünler"></option>
                     	<option value="2" <cfif attributes.list_type eq 2>selected</cfif>><cf_get_lang dictionary_id="1034.Kanban Ürünler"></option>
                     	<option value="3" <cfif attributes.list_type eq 3>selected</cfif>><cf_get_lang dictionary_id='58785.Detaylı'></option>
                        <option value="4" <cfif attributes.list_type eq 4>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                 	</select>
                </div>
                <div class="form-group" id="list_tur_td">
                	<select name="list_tur" id="list_tur" style="width:90px; height:20px">
                   		<option value="1" <cfif attributes.list_tur eq 1>selected</cfif>><cf_get_lang dictionary_id='58798.İç Talep'></option>
                    	<option value="2" <cfif attributes.list_tur eq 2>selected</cfif>><cf_get_lang dictionary_id='29630.Ambar Fişi'></option>
                        <option value="3" <cfif attributes.list_tur eq 3>selected</cfif>><cf_get_lang dictionary_id='49752.Satınalma Talebi'></option>
                	</select>
                </div>
                <div class="form-group">
                	<input type="checkbox" name="is_excel" id="is_excel" value="1" <cfif attributes.is_excel eq 1>checked</cfif>>
                	<cf_get_lang_main no='446.Excel Getir'>
                </div>
          		<!---<div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>--->
          		<div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="1">
                </div>
          	</cf_box_search>
            <cf_box_search_detail>
            	<div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="form_ul_depo">
                     	<label class="col col-2"><cf_get_lang dictionary_id='58763.Depo'></label>
                      	<div class="col col-10">
                         	<div class="input-group">
                            	<select name="department_id" style="width:145px; height:90px" multiple>
									<cfoutput query="get_department">
                                     	<optgroup label="#department_head#">
                                         	<cfquery name="GET_LOCATION" dbtype="query">
                                            	SELECT * FROM GET_ALL_LOCATION WHERE DEPARTMENT_ID = #get_department.department_id[currentrow]#
                                        	</cfquery>
                                          	<cfif get_location.recordcount>
                                            	<cfloop from="1" to="#get_location.recordcount#" index="s">
                                                	<option value="#department_id#-#get_location.location_id[s]#" <cfif listfind(attributes.department_id,'#department_id#-#get_location.location_id[s]#',',')>selected</cfif>>&nbsp;&nbsp;#get_location.comment[s]#</option>
                                              	</cfloop>
                                       		</cfif>
                                     	</optgroup>					  
                                  	</cfoutput>
                             	</select>
                         	</div>
                      	</div>
                 	</div>
            	</div>
            	<div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="2" sort="true">
                	<div class="form-group" id="form_ul_depo">
                     	<label class="col col-2 col-sm-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                      	<div class="col col-10">
                         	<div class="input-group">
                            	<cfoutput>
                            	<input type="hidden" name="project_id" id="project_id" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id) and len(attributes.project_head)>#attributes.project_id#</cfif>"> 
                				<input type="text" name="project_head" id="project_head" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id) and len(attributes.project_head)>#get_project_name(attributes.project_id)#</cfif>" style="width:200px; height:20px"onFocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','list_meterials','3','200')" autocomplete="off">
                            	<span class="input-group-addon icon-ellipsis btnPointer" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_head=list_meterials.project_head&project_id=list_meterials.project_id');" title="<cf_get_lang no='45.Proje Seçiniz'>"></span>
                                </cfoutput>
                        	</div>
                  		</div>
					</div>
                    <div class="form-group" id="item-cat_id">
                        <label class="col col-2 col-sm-12"><cf_get_lang dictionary_id='57486.Kategori'></label>
                        <div class="col col-10">
                            <div class="input-group">
                                <input type="hidden" name="cat_id" id="cat_id" value="<cfif len(attributes.cat_id) and len(attributes.category_name)><cfoutput>#attributes.cat_id#</cfoutput></cfif>">
                                <input type="hidden" name="cat" id="cat" value="<cfif len(attributes.cat) and len(attributes.category_name)><cfoutput>#attributes.cat#</cfoutput></cfif>">
                                <input name="category_name" type="text" id="category_name"  onfocus="AutoComplete_Create('category_name','PRODUCT_CATID,PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','','PRODUCT_CATID,HIERARCHY','cat_id,cat','','3','200','','1');" value="<cfif len(attributes.category_name)><cfoutput>#attributes.category_name#</cfoutput></cfif>" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_cat_names&is_sub_category=1&field_id=list_meterials.cat_id&field_code=list_meterials.cat&field_name=list_meterials.category_name</cfoutput>');"></span>
                            </div>
                        </div>
                    </div>
                    
                     <div class="form-group" id="item-product">
                        <label class="col col-2 col-sm-12"><cf_get_lang_main no='245.Ürün'></label>
                        <div class="col col-10">
                            <div class="input-group">
                               	<input type="hidden" name="stock_id" id="stock_id" value="<cfoutput>#attributes.stock_id#</cfoutput>">
                                <input type="hidden" name="product_id" id="product_id" value="<cfoutput>#attributes.product_id#</cfoutput>">
                                <input type="text"   name="product_name"  id="product_name" placeholder=""  value="<cfoutput>#attributes.product_name#</cfoutput>" passthrough="readonly=yes" onfocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME','get_product_autocomplete','0','PRODUCT_ID,STOCK_ID','product_id,stock_id','','3','225');" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis btnPoniter" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=list_meterials.stock_id&product_id=list_meterials.product_id&field_name=list_meterials.product_name');"></span>
                            </div>
                        </div>
                    </div>
                    
             	</div>
            </cf_box_search_detail>
        </cf_box>
        <cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
			<cfset filename = "#createuuid()#">
            <cfheader name="Expires" value="#Now()#">
            <cfcontent type="application/vnd.msexcel;charset=utf-8">
            <cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
            <cfset attributes.startrow=1>
            <cfset attributes.maxrows = get_total_material.recordcount>
        </cfif>
        <cfsavecontent variable="title"><cf_get_lang dictionary_id='444.Malzeme'></cfsavecontent>
        <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
            <cf_grid_list>
            	<cfset renk = 1>
            	<cfif attributes.list_type eq 1 or attributes.list_type eq 4><!--- MRP Ürünler İse--->
                    <thead>
                        <tr valign="middle">
                            <th rowspan="2" style=" text-align:center; width:20px; height:20px"><cf_get_lang dictionary_id='57496.No'></th>
                            <cfif isdefined('attributes.is_lot_group')>
                                <th rowspan="2" style=" text-align:center; width:20px; height:20px"><cf_get_lang dictionary_id='45498.Lot No'></th>
                            </cfif>
                            <th rowspan="2" style=" text-align:center; width:90px"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                            <th rowspan="2" style=" text-align:center;"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                            <th rowspan="2" style=" text-align:center; width:150px"><cf_get_lang dictionary_id='57789.Özel Kod'></th>
                            <th rowspan="2" style=" text-align:center; width:60px"><br /><cf_get_lang dictionary_id='485.Plan İhtiyacı'></th>
                            <th rowspan="2" style=" text-align:center; width:30px"><cf_get_lang dictionary_id='57636.Birim'></th>
                            <th rowspan="2" style=" text-align:center; width:50px; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>"><cf_get_lang dictionary_id='58084.Fiyat'></th>
                            <th rowspan="2" style=" text-align:center; width:20px; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>">&nbsp;</th>
                            <th rowspan="2" style=" text-align:center; width:60px; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>"><cf_get_lang dictionary_id='57673.Tutar'></th>
                            <th rowspan="2" style=" text-align:center; width:20px; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>">&nbsp;</th>
                            <th colspan="3" style=" text-align:center;"><cf_get_lang dictionary_id='29826.Artan'></th>
                            <th colspan="2" style=" text-align:center;"><cf_get_lang dictionary_id='29827.Azalan'></th>
                            <th rowspan="2" style=" text-align:center; width:50px" title="<cf_get_lang dictionary_id='443.Malzeme İhtiyacı'>"><cf_get_lang dictionary_id='443.Malzeme İhtiyacı'><br /></th>
                            <th rowspan="2" style=" text-align:center; width:50px" title="<cfif attributes.list_tur eq 1><cf_get_lang dictionary_id='450.İç Talepler'><cfELSEif attributes.list_tur eq 2><cf_get_lang dictionary_id='29630.Ambar Fişi'><cfELSEif attributes.list_tur eq 3><cf_get_lang dictionary_id='49752.Satınalma Talebi'></cfif>">
                                <cfif attributes.list_tur eq 1>
                                    <cf_get_lang dictionary_id='450.İç Talepler'>
                                <cfELSEif attributes.list_tur eq 2>
                                    <cf_get_lang dictionary_id='29630.Ambar Fişi'>
                             	<cfELSEif attributes.list_tur eq 3>
                                	<cf_get_lang dictionary_id='49752.Satınalma Talebi'>
                                </cfif>
                            </th>
                            <!---<th rowspan="2" style=" text-align:center; width:50px" title="Minimum Sipariş Miktarı">Minimum<br />Sipariş</th>--->
                            <th rowspan="2" style=" text-align:center; width:50px" title="<cf_get_lang dictionary_id='1023.Gönderilecek İç Talep'>"><cf_get_lang dictionary_id='49752.Satınalma Talebi'></th>
                            <!-- sil -->
                            <th rowspan="2" style=" text-align:center; width:25px" >
                                
                            </th>
                            <!-- sil -->
                        </tr>
                        <tr>
                            <th style=" text-align:center; width:50px; height:10px" title="<cf_get_lang dictionary_id='58120.Gerçek Stok'>"><cf_get_lang dictionary_id='454.G.Stok'></th>
                            <th style=" text-align:center; width:50px" title="<cf_get_lang dictionary_id='1024.Açık Satınalma Siparişleri'>">	<cf_get_lang dictionary_id='448.S. Rezerve'> </th>
                            <th style=" text-align:center; width:50px" title="<cf_get_lang dictionary_id='1025.Toplam Açık İç Talepler'>"><cf_get_lang dictionary_id='449.A.İç Talep'></th>
                            <th style=" text-align:center; width:50px" title="<cf_get_lang dictionary_id='1026.Açık Üretim Planları'>"><cf_get_lang dictionary_id='452.Ü.Rezerve'></th>

                            <th style=" text-align:center; width:50px" title="<cf_get_lang dictionary_id='453.Yeniden Sipariş Noktası'>"> <cf_get_lang dictionary_id='44731.Minimum Stok'></th>
                        </tr>
                    </thead>
                <cfelseif attributes.list_type eq 2><!--- Kanban Ürünler İse--->
                    <thead>
                        <tr valign="middle">
                            <th rowspan="2" style=" text-align:center; width:20px; height:20px">No</th>
                            <cfif isdefined('attributes.is_lot_group')>
                                <th rowspan="2" style=" text-align:center; width:20px; height:20px"><cf_get_lang dictionary_id='45498.Lot No'></th>
                            </cfif>
                            <th rowspan="2" style=" text-align:center; width:90px"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                            <th rowspan="2" style=" text-align:center;"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                            <th rowspan="2" style=" text-align:center; width:150px"><cf_get_lang dictionary_id='57789.Özel Kod'></th>
                            <th rowspan="2" style=" text-align:center; width:60px"><br /><cf_get_lang dictionary_id='485.Plan İhtiyacı'></th>
                            <th rowspan="2" style=" text-align:center; width:30px"><cf_get_lang dictionary_id='57636.Birim'></th>
                            <th rowspan="2" style=" text-align:center; width:50px; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>"><cf_get_lang dictionary_id='58084.Fiyat'></th>
                            <th rowspan="2" style=" text-align:center; width:20px; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>">&nbsp;</th>
                            <th rowspan="2" style=" text-align:center; width:60px; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>"><cf_get_lang dictionary_id='57673.Tutar'></th>
                            <th rowspan="2" style=" text-align:center; width:20px; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>">&nbsp;</th>
                            <th colspan="3" style=" text-align:center;"><cf_get_lang dictionary_id='29826.Artan'></th>
                            <th colspan="2" style=" text-align:center;"><cf_get_lang dictionary_id='29827.Azalan'></th>
                            <th rowspan="2" style=" text-align:center; width:50px" title="<cf_get_lang dictionary_id='443.Malzeme İhtiyacı'>"><cf_get_lang dictionary_id='443.Malzeme İhtiyacı'></th>
                            <th rowspan="2" style=" text-align:center; width:50px" title="Minimum Sipariş Miktarı"><br /><cf_get_lang dictionary_id='1027.Minimum Sipariş'></th>
                            <th rowspan="2" style=" text-align:center; width:50px" title="<cf_get_lang dictionary_id='1023.Gönderilecek İç Talep'>"><cf_get_lang dictionary_id='49752.Satınalma Talebi'></th>
                            <!-- sil -->
                            <th rowspan="2" style=" text-align:center; width:25px"></th>
                            <!-- sil -->
                        </tr>
                        <tr>
                            <th style=" text-align:center; width:50px; height:10px" title="<cf_get_lang dictionary_id='58120.Gerçek Stok'>"><cf_get_lang dictionary_id='454.G.Stok'></th>
                            <th style=" text-align:center; width:50px" title="<cf_get_lang dictionary_id='1024.Açık Satınalma Siparişleri'>">	<cf_get_lang dictionary_id='448.S. Rezerve'> </th>
                            <th style=" text-align:center; width:50px" title="<cf_get_lang dictionary_id='1025.Toplam Açık İç Talepler'>"><cf_get_lang dictionary_id='449.A.İç Talep'></th>
                            <th style=" text-align:center; width:50px" title="<cf_get_lang dictionary_id='1026.Açık Üretim Planları'>"><cf_get_lang dictionary_id='452.Ü.Rezerve'></th>
                            <th style=" text-align:center; width:50px" title="<cf_get_lang dictionary_id='453.Yeniden Sipariş Noktası'>"> <cf_get_lang dictionary_id='44731.Minimum Stok'></th>
                        </tr>
                    </thead>
                <cfelseif attributes.list_type eq 3><!--- Detaylı İse--->
                    <thead>
                        <tr valign="middle">
                            <th style=" text-align:center; width:20px; height:20px">No</th>
                            <cfif isdefined('attributes.is_lot_group')>
                            <th style=" text-align:center; width:20px; height:20px"><cf_get_lang dictionary_id='45498.Lot No'></th>
                            </cfif>
                            <th style=" text-align:center; width:90px"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                            <th style=" text-align:center;"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                            <th rowspan="2" style=" text-align:center; width:150px"><cf_get_lang dictionary_id='57789.Özel Kod'></th>
                            <th style=" text-align:center; width:60px"><cf_get_lang dictionary_id='485.Plan İhtiyacı'></th>
                            <th style=" text-align:center; width:30px"><cf_get_lang dictionary_id='57636.Birim'></th>
                            <th style=" text-align:center; width:50px; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>"><cf_get_lang dictionary_id='58084.Fiyat'></th>
                            <th style=" text-align:center; width:20px; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>">&nbsp;</th>
                            <th style=" text-align:center; width:60px; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>"><cf_get_lang dictionary_id='57673.Tutar'></th>
                            <th style=" text-align:center; width:20px; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>">&nbsp;</th>
                            <th style=" text-align:center; width:150px"><cf_get_lang dictionary_id='57771.Detay'></th>
                            <th rowspan="2" style=" text-align:center; width:50px" title="<cfif attributes.list_tur eq 1><cf_get_lang dictionary_id='450.İç Talepler'><cfELSEif attributes.list_tur eq 2><cf_get_lang dictionary_id='29630.Ambar Fişi'><cfELSEif attributes.list_tur eq 3><cf_get_lang dictionary_id='49752.Satınalma Talebi'></cfif>">
                                <cfif attributes.list_tur eq 1>
                                    <cf_get_lang dictionary_id='450.İç Talepler'>
                                <cfELSEif attributes.list_tur eq 2>
                                    <cf_get_lang dictionary_id='29630.Ambar Fişi'>
                             	<cfELSEif attributes.list_tur eq 3>
                                	<cf_get_lang dictionary_id='49752.Satınalma Talebi'>
                                </cfif>
                            </th>
                            <th style=" text-align:center; width:50px"><cf_get_lang dictionary_id='49752.Satınalma Talebi'></th>
                            <!-- sil -->
                            <th rowspan="2" style=" text-align:center; width:25px"></th>
                            <!-- sil -->
                        </tr>
                    </thead>
              	</cfif>
                <tbody>
					<cfif get_total_material.recordcount> 
                    	<cfset category = get_total_material.PRODUCT_CATID>
                        <cfloop query="get_total_material">
                        	<cfif category neq get_total_material.PRODUCT_CATID> 
                            	<cfif renk eq 1>
                                 	<cfset renk = 2>
                              	<cfelse>
                                 	<cfset renk = 1>
                             	</cfif>
                              	<cfset category = get_total_material.PRODUCT_CATID>
                          	</cfif>
                            <cfif attributes.list_type eq 1 or attributes.list_type eq 4>
                                <cfoutput>
                                    <tr style="background-color:<cfif renk eq 1>mintcream<cfelse>white</cfif>"> 
                                        <td style="text-align:right; height:15px">#currentrow#&nbsp;</td>
                                        <cfif isdefined('attributes.is_lot_group')>
                                            <td title="<cfif isdefined("ORDER_NUMBER_#Replace(LOT_NO,' ','','All')#")>
                                            	#Evaluate("ORDER_NUMBER_#Replace(LOT_NO,' ','','All')#")#</cfif> - <cfif isdefined("UNVAN_#Replace(LOT_NO,' ','','All')#")>#Evaluate("UNVAN_#Replace(LOT_NO,' ','','All')#")#</cfif>">&nbsp;#get_total_material.LOT_NO#
                                         	</td>
                                        </cfif>
                                        <td>
                                        	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
                                                #get_total_material.PRODUCT_CODE#
                                            <cfelse>
                                            <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_detail_product&pid=#product_id#&sid=#stock_id#</cfoutput>','wide');"  class="tableyazi">
                                                #get_total_material.PRODUCT_CODE#
                                            </a>
                                            </cfif>
                                        </td>
                                        <td>#get_total_material.PRODUCT_NAME#</td>
                                        <td>#get_total_material.PRODUCT_CODE_2#</td>
                                        <td title="Master Plan <cf_get_lang dictionary_id='455.Üretim İhtiyacı'>" style="text-align:right; font-weight:bold">
                                            <cfif (isdefined('attributes.iid') and listlen(attributes.iid))>
                                            	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
                                                	#TlFormat(get_total_material.AMOUNT,2)#
                                                <cfelse>
                                                <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_upd_ezgi_production_material&pid=#product_id#&sid=#stock_id#&iid=#attributes.iid#&total=#get_total_material.AMOUNT#</cfoutput>','list');"  class="tableyazi">
                                                    #TlFormat(get_total_material.AMOUNT,2)#
                                                </a>
                                                </cfif>
                                            <cfelse>
                                                #TlFormat(get_total_material.AMOUNT,2)#
                                            </cfif>
                                        </td>
                                        <td>#MAIN_UNIT#</td>
                                        <td title="<cf_get_lang dictionary_id='57638.Birim Fiyat'>" style="text-align:right; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>">
                                            <cfif isdefined('PRICE_#STOCK_ID#')>
                                                #TlFormat(Evaluate('PRICE_#STOCK_ID#'),4)#
                                                <cfset row_price = Evaluate('PRICE_#STOCK_ID#')>
                                                 <input type="hidden" name="row_price_unit_#stock_id#" id="row_price_unit_#stock_id#" value="#tlformat(row_price)#">
                                            <cfelse>
                                            <cfset row_price = 0>
                                                #TlFormat(0,4)#
                                                 <input type="hidden" name="row_price_unit_#stock_id#" id="row_price_unit_#stock_id#" value="#tlformat(0)#">
                                            </cfif>
                                        </td>
                                        <td style="<cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>" title="<cf_get_lang dictionary_id='57677.Döviz'>">
                                            <cfif isdefined('MONEY_#STOCK_ID#')>
                                                #Evaluate('MONEY_#STOCK_ID#')#
                                                <input type="hidden" name="row_stock_money_#stock_id#" id="row_stock_money_#stock_id#" value="#Evaluate('MONEY_#STOCK_ID#')#" />
                                            <cfelse>
                                                <input type="hidden" name="row_stock_money_#stock_id#" id="row_stock_money_#stock_id#" value="#session.ep.money#" />
                                                #session.ep.money#
                                            </cfif>
                                        </td>
                                        <td title="<cf_get_lang dictionary_id='57673.Tutar'>" style="text-align:right; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>">
                                            <cfif isdefined('PRICE_#STOCK_ID#')>
                                                #TlFormat(Evaluate('PRICE_#STOCK_ID#')*get_total_material.AMOUNT,2)#
                                            <cfelse>
                                                #TlFormat(0,4)#
                                            </cfif>
                                        </td>
                                        <td style="<cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>" title="<cf_get_lang dictionary_id='57677.Döviz'>">
                                            <cfif isdefined('MONEY_#STOCK_ID#')>
                                                #Evaluate('MONEY_#STOCK_ID#')#
                                            <cfelse>
                                                #session.ep.money#
                                            </cfif>
                                        </td>
                                        <cfset row_total_need = 0>
                                        <td title="<cf_get_lang dictionary_id='58120.Gerçek Stok'>" style="text-align:right;background-color:LightCyan">
                                            <cfif isdefined('PRODUCT_STOCK_#STOCK_ID#')>
                                            	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
                                                	#TlFormat(Evaluate('PRODUCT_STOCK_#STOCK_ID#'),2)#
                                                <cfelse>
                                                <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=stock.detail_store_stock_popup&stock_id=#stock_id#&product_id=#product_id#</cfoutput>','list');">
                                                    <span style="<cfif Evaluate('PRODUCT_STOCK_#STOCK_ID#') lt 0>color:red</cfif>">
                                                        #TlFormat(Evaluate('PRODUCT_STOCK_#STOCK_ID#'),2)#
                                                    </span>
                                                </a>
                                                </cfif>
                                                <cfset row_total_need = row_total_need + Evaluate('PRODUCT_STOCK_#STOCK_ID#')>
                                            <cfelse>
                                                #TlFormat(0,2)#
                                            </cfif>
                                        </td>
                                        <td title="<cf_get_lang dictionary_id='1028.Açık Satınalma Siparişi'>" style="text-align:right;background-color:LightCyan">
                                            <cfif isdefined('PURCHASE_ORDER_ARTAN_#STOCK_ID#')>
                                            	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
                                                	#TlFormat(Evaluate('PURCHASE_ORDER_ARTAN_#STOCK_ID#'),2)#
                                                <cfelse>
                                                <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_reserved_orders&taken=0&pid=#product_id#&nosale_order_location=0</cfoutput>','list');">
                                                #TlFormat(Evaluate('PURCHASE_ORDER_ARTAN_#STOCK_ID#'),2)#
                                                </a>
                                                </cfif>
                                                <cfset row_total_need = row_total_need + Evaluate('PURCHASE_ORDER_ARTAN_#STOCK_ID#')>
                                            <cfelse>
                                                #TlFormat(0,2)#
                                            </cfif>
                                        </td>
                                        <td title="<cf_get_lang dictionary_id='457.Master Plana Özel İç Talepler'>" style="text-align:right;background-color:LightCyan">
                                        	<cfif isdefined('demand_amount')>
												<cfif isdefined('IC_TALEP_#STOCK_ID#')>
                                                	<cfif Evaluate('IC_TALEP_#STOCK_ID#') gt 0>
                                                        #TlFormat(Evaluate('IC_TALEP_#STOCK_ID#'),2)#
                                                        <cfset row_total_need = row_total_need + Evaluate('IC_TALEP_#STOCK_ID#')>
                                                   	<cfelse>
                                                    	#TlFormat(0,2)#
                                                    </cfif>
                                                <cfelse>
                                                    #TlFormat(0,2)#
                                                </cfif>
                                           	<cfelse>
                                            	#TlFormat(0,2)#
                                            </cfif>
                                        </td>
                                        <td title="<cf_get_lang dictionary_id='458.Tüm Açık Üretim Planları Rezerve'>" style="text-align:right;background-color:Seashell">
                                            <cfif isdefined('PRODUCTION_STOCK_AZALT_#STOCK_ID#')>
                                            	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
                                                	#TlFormat(Evaluate('PRODUCTION_STOCK_AZALT_#STOCK_ID#'),2)#
                                                <cfelse>
                                                <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_reserved_production_orders&type=2&pid=#product_id#</cfoutput>','list');">
                                                    #TlFormat(Evaluate('PRODUCTION_STOCK_AZALT_#STOCK_ID#'),2)#
                                                </a>
                                                </cfif>
                                                <cfset row_total_need = row_total_need - Evaluate('PRODUCTION_STOCK_AZALT_#STOCK_ID#')>
                                            <cfelse>
                                                #TlFormat(0,2)#
                                            </cfif>
                                        </td>
                                        <td title="Minimum <cf_get_lang dictionary_id='57452.Stok'>" style="text-align:right;background-color:Seashell">
                                            <cfif isdefined('MINIMUM_STOCK_#STOCK_ID#')>
                                                #TlFormat(Evaluate('MINIMUM_STOCK_#STOCK_ID#'),2)#
                                                <cfset row_total_need = row_total_need - Evaluate('MINIMUM_STOCK_#STOCK_ID#')>
                                            <cfelse>
                                                #TlFormat(0,2)#
                                            </cfif>
                                        </td>
                                        <td title="MRP" style="text-align:right;background-color:Gainsboro;font-weight:bold">
                                            #TlFormat(row_total_need*-1,2)#
                                        </td>
                                        <td title="<cf_get_lang dictionary_id='459.Plana Bağlı Açık Talepler'>" style="text-align:right">
                                            <cfif attributes.list_tur eq 1 or attributes.list_tur eq 3><!---İç Talep İse--->
                                                <cfif isdefined('attributes.demand_type')> <!---Klasik MRP İse--->
                                                    <cfif isdefined('IC_TALEP_MASTER_PLAN_#STOCK_ID#')>
                                                        #TlFormat(Evaluate('IC_TALEP_MASTER_PLAN_#STOCK_ID#'),2)#
                                                        <cfset row_total_need = (row_total_need *-1)- Evaluate('IC_TALEP_MASTER_PLAN_#STOCK_ID#')>
                                                    <cfelse>
                                                        #TlFormat(0,2)#
                                                        <cfset row_total_need = row_total_need *-1>
                                                    </cfif>
                                                <cfelse><!---Ambar Fişi--->
                                                    <cfset row_total_need = 0>
                                                    <cfif isdefined('IC_TALEP_MASTER_PLAN_#STOCK_ID#')>
                                                        #TlFormat(Evaluate('IC_TALEP_MASTER_PLAN_#STOCK_ID#'),2)#
                                                        <cfset row_total_need = get_total_material.AMOUNT - Evaluate('IC_TALEP_MASTER_PLAN_#STOCK_ID#')>
                                                    <cfelse>
                                                        #TlFormat(0,2)#
                                                        <cfset row_total_need = get_total_material.AMOUNT>
                                                    </cfif>
                                                </cfif>
                                            <cfelse>
                                                <cfif isdefined('attributes.demand_type')> <!---Klasik MRP İse--->
                                                    <cfif isdefined('AMBAR_STOCK_#STOCK_ID#')>
                                                        #TlFormat(Evaluate('AMBAR_STOCK_#STOCK_ID#'),2)#
                                                        <cfset row_total_need = (row_total_need *-1)- Evaluate('AMBAR_STOCK_#STOCK_ID#')>
                                                    <cfelse>
                                                        #TlFormat(0,2)#
                                                        <cfset row_total_need = row_total_need *-1>
                                                    </cfif>
                                                <cfelse><!---Ambar Fişi--->
                                                    <cfset row_total_need = 0>
                                                    <cfif isdefined('AMBAR_STOCK_#STOCK_ID#')>
                                                        #TlFormat(Evaluate('AMBAR_STOCK_#STOCK_ID#'),2)#
                                                        <cfset row_total_need = get_total_material.AMOUNT - Evaluate('AMBAR_STOCK_#STOCK_ID#')>
                                                    <cfelse>
                                                        #TlFormat(0,2)#
                                                        <cfset row_total_need = get_total_material.AMOUNT>
                                                    </cfif>
                                                </cfif>
                                            </cfif>
                                        </td>
                                        <td title="Master Plan <cf_get_lang dictionary_id='455.Üretim İhtiyacı'> - <cf_get_lang dictionary_id='58798.İç Talep'>" style="text-align:right">
                                            <cfif row_total_need lt 0><cfset row_total_need = 0></cfif>
                                            <input type="text" name="row_total_need_#stock_id#" id="row_total_need_#stock_id#" value="#tlformat(row_total_need,2)#" class="box" style="width:60px;" onKeyup="return(FormatCurrency(this,event));" onBlur="hesapla(#stock_id#);">
                                            <input type="hidden" name="row_price_#stock_id#" id="row_price_#stock_id#" value="#tlformat(row_total_need*row_price)#" class="box" style="width:60px;" onKeyup="return(FormatCurrency(this,event));">
                                        </td>
                                        <!-- sil -->

                                        <td style="text-align:center">
                                             <input type="checkbox" name="conversion_product_#stock_id#" value="#stock_id#" id="_conversion_product_#currentrow#">
                                        </td>
                                        <!-- sil -->
                                    </tr>
                                    <cfif isdefined('PRICE_#STOCK_ID#')>
                                        <cfset "t1_fiyat#Evaluate('MONEY_#STOCK_ID#')#" = Evaluate("t1_fiyat#Evaluate('MONEY_#STOCK_ID#')#") + (Evaluate('PRICE_#STOCK_ID#')*get_total_material.AMOUNT)>
                                    </cfif>
                                </cfoutput>
                            </cfif>
                        </cfloop>
                        <cfloop query="get_total_material">
                        	<cfif category neq get_total_material.PRODUCT_CATID> 
                            	<cfif renk eq 1>
                                 	<cfset renk = 2>
                              	<cfelse>
                                 	<cfset renk = 1>
                             	</cfif>
                              	<cfset category = get_total_material.PRODUCT_CATID>
                          	</cfif>
                            <cfif attributes.list_type eq 2>
                                <cfoutput>
                                    <tr style="background-color:<cfif renk eq 1>mintcream<cfelse>white</cfif>"> 
                                        <td style="text-align:right; height:15px">#currentrow#</td>
                                        <cfif isdefined('attributes.is_lot_group')>
                                            <td title="#Evaluate("ORDER_NUMBER_#Replace(LOT_NO,' ','','All')#")# - #Evaluate("UNVAN_#Replace(LOT_NO,' ','','All')#")#">#get_total_material.LOT_NO#</td>
                                        </cfif>
                                        <td>
                                        	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
                                            	#get_total_material.PRODUCT_CODE#
                                            <cfelse>
                                            <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_detail_product&pid=#product_id#&sid=#stock_id#</cfoutput>','wide');"  class="tableyazi">
                                                #get_total_material.PRODUCT_CODE#
                                            </a>
                                            </cfif>
                                        </td>
                                        <td>#get_total_material.PRODUCT_NAME#</td>
                                        <td>#get_total_material.PRODUCT_CODE_2#</td>
                                        <td title="<cf_get_lang dictionary_id='455.Üretim İhtiyacı'>" style="text-align:right; font-weight:bold">#TlFormat(get_total_material.AMOUNT,2)#</td>
                                        <td>#MAIN_UNIT#</td>
                                        <td title="<cf_get_lang dictionary_id='57638.Birim Fiyat'>" style="text-align:right; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>">
                                            <cfif isdefined('PRICE_#STOCK_ID#')>
                                                #TlFormat(Evaluate('PRICE_#STOCK_ID#'),4)#
                                                <cfset row_price = Evaluate('PRICE_#STOCK_ID#')>
                                                 <input type="hidden" name="row_price_unit_#stock_id#" id="row_price_unit_#stock_id#" value="#tlformat(row_price)#">
                                            <cfelse>
                                            <cfset row_price = 0>
                                                #TlFormat(0,4)#
                                                 <input type="hidden" name="row_price_unit_#stock_id#" id="row_price_unit_#stock_id#" value="#tlformat(0)#">
                                            </cfif>
                                        </td>
                                        <td style="<cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>" title="<cf_get_lang dictionary_id='57677.Döviz'>">
                                            <cfif isdefined('MONEY_#STOCK_ID#')>
                                                #Evaluate('MONEY_#STOCK_ID#')#
                                                <input type="hidden" name="row_stock_money_#stock_id#" id="row_stock_money_#stock_id#" value="#Evaluate('MONEY_#STOCK_ID#')#" />
                                            <cfelse>
                                                <input type="hidden" name="row_stock_money_#stock_id#" id="row_stock_money_#stock_id#" value="#session.ep.money#" />
                                                #session.ep.money#
                                            </cfif>
                                        </td>
                                        <td title="<cf_get_lang dictionary_id='57673.Tutar'>" style="text-align:right; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>">
                                            <cfif isdefined('PRICE_#STOCK_ID#')>
                                                #TlFormat(Evaluate('PRICE_#STOCK_ID#')*get_total_material.AMOUNT,2)#
                                            <cfelse>
                                                #TlFormat(0,4)#
                                            </cfif>
                                        </td>
                                        <td style="<cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>" title="<cf_get_lang dictionary_id='57677.Döviz'>">
                                            <cfif isdefined('MONEY_#STOCK_ID#')>
                                                #Evaluate('MONEY_#STOCK_ID#')#
                                            <cfelse>
                                                #session.ep.money#
                                            </cfif>
                                        </td>
                                        <cfset row_total_need = 0>
                                        <td title="<cf_get_lang dictionary_id='58120.Gerçek Stok'>" style="text-align:right;background-color:LightCyan">
                                            <cfif isdefined('PRODUCT_STOCK_#STOCK_ID#')>
                                            	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>

                                                	#TlFormat(Evaluate('PRODUCT_STOCK_#STOCK_ID#'),2)#
                                                <cfelse>
                                                <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=stock.detail_store_stock_popup&stock_id=#stock_id#&department=#attributes.department_id#&product_id=#product_id#</cfoutput>','list');">
                                                    <span style="<cfif Evaluate('PRODUCT_STOCK_#STOCK_ID#') lt 0>color:red</cfif>">
                                                        #TlFormat(Evaluate('PRODUCT_STOCK_#STOCK_ID#'),2)#
                                                    </span>
                                                </a>
                                                </cfif>
                                                <cfset row_total_need = row_total_need + Evaluate('PRODUCT_STOCK_#STOCK_ID#')>
                                            <cfelse>
                                                #TlFormat(0,2)#
                                            </cfif>
                                        </td>
                                        <td title="<cf_get_lang dictionary_id='1028.Açık Satınalma Siparişi'>" style="text-align:right;background-color:LightCyan">
                                            <cfif isdefined('PURCHASE_ORDER_ARTAN_#STOCK_ID#')>
                                            	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
                                                	#TlFormat(Evaluate('PURCHASE_ORDER_ARTAN_#STOCK_ID#'),2)#
                                                <cfelse>
                                                <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_reserved_orders&taken=0&pid=#product_id#&nosale_order_location=0</cfoutput>','list');">
                                                #TlFormat(Evaluate('PURCHASE_ORDER_ARTAN_#STOCK_ID#'),2)#
                                                </a>
                                                </cfif>
                                                <cfset row_total_need = row_total_need + Evaluate('PURCHASE_ORDER_ARTAN_#STOCK_ID#')>
                                            <cfelse>
                                                #TlFormat(0,2)#
                                            </cfif>
                                        </td>
                                        <td title="<cf_get_lang dictionary_id='457.Master Plana Özel İç Talepler'>" style="text-align:right;background-color:LightCyan">
                                        	<cfif isdefined('demand_amount')>
												<cfif isdefined('IC_TALEP_#STOCK_ID#')>
                                                	<cfif Evaluate('IC_TALEP_#STOCK_ID#') gt 0>
                                                        #TlFormat(Evaluate('IC_TALEP_#STOCK_ID#'),2)#
                                                        <cfset row_total_need = row_total_need + Evaluate('IC_TALEP_#STOCK_ID#')>
                                                   	<cfelse>
                                                    	#TlFormat(0,2)#
                                                    </cfif>
                                                <cfelse>
                                                    #TlFormat(0,2)#
                                                </cfif>
                                           	<cfelse>
                                            	#TlFormat(0,2)#
                                            </cfif>
                                        </td>
                                        <td title="<cf_get_lang dictionary_id='458.Tüm Açık Üretim Planları Rezerve'>" style="text-align:right;background-color:Seashell">
                                            <cfif isdefined('PRODUCTION_STOCK_AZALT_#STOCK_ID#')>
                                            	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
                                                	#TlFormat(Evaluate('PRODUCTION_STOCK_AZALT_#STOCK_ID#'),2)#
                                                <cfelse>
                                                <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_reserved_production_orders&type=2&pid=#product_id#</cfoutput>','list');">
                                                    #TlFormat(Evaluate('PRODUCTION_STOCK_AZALT_#STOCK_ID#'),2)#
                                                </a>
                                                </cfif>
                                                <cfset row_total_need = row_total_need - Evaluate('PRODUCTION_STOCK_AZALT_#STOCK_ID#')>
                                            <cfelse>
                                                #TlFormat(0,2)#
                                            </cfif>
                                        </td>
                                        <td title="Minimum <cf_get_lang dictionary_id='57452.Stok'>" style="text-align:right;background-color:Seashell">
                                            <cfif isdefined('MINIMUM_STOCK_#STOCK_ID#')>
                                                #TlFormat(Evaluate('MINIMUM_STOCK_#STOCK_ID#'),2)#
                                                <cfset row_total_need = row_total_need - Evaluate('MINIMUM_STOCK_#STOCK_ID#')>
                                            <cfelse>
                                                #TlFormat(0,2)#
                                            </cfif>
                                        </td>
                                        
                                        <td title="MRP" style="text-align:right;background-color:Gainsboro;font-weight:bold">
                                            #TlFormat(row_total_need*-1,2)#
                                        </td>
                                        <td title="<cf_get_lang dictionary_id='36977.Üretim Emri Id sine Göre Azalan'>" style="text-align:right;background-color:white">
                                            <cfif isdefined('MINIMUM_ORDER_STOCK_VALUE_#STOCK_ID#')>
                                                #TlFormat(Evaluate('MINIMUM_ORDER_STOCK_VALUE_#STOCK_ID#'),2)#
                                                <cfif isdefined('PRODUCT_STOCK_#STOCK_ID#') and isdefined('MINIMUM_STOCK_#STOCK_ID#') and Evaluate('PRODUCT_STOCK_#STOCK_ID#') lte Evaluate('MINIMUM_STOCK_#STOCK_ID#')>
                                                    <cfset row_total_need = Evaluate('MINIMUM_ORDER_STOCK_VALUE_#STOCK_ID#')>
                                                <cfelse>
                                                    <cfset row_total_need = 0>
                                                </cfif>
                                            <cfelse>
                                                #TlFormat(0,2)#
                                            </cfif>
                                        </td>
                                        <td title="<cf_get_lang dictionary_id='460.Gerçek Stok Minimum Stoktan Küçükse Minimum Sipariş Miktarı'>" style="text-align:right">
                                            <cfif row_total_need lt 0><cfset row_total_need = 0></cfif>
                                            <input type="text" name="row_total_need_#stock_id#" id="row_total_need_#stock_id#" value="#tlformat(row_total_need,2)#" class="box" style="width:60px;" onKeyup="return(FormatCurrency(this,event));" onBlur="hesapla(#stock_id#);">
                                            <input type="hidden" name="row_price_#stock_id#" id="row_price_#stock_id#" value="#tlformat(row_total_need*row_price)#" class="box" style="width:60px;" onKeyup="return(FormatCurrency(this,event));">
                                            
                                        </td>
                                        <!-- sil -->
                                        <td style="text-align:center">
                                             <input type="checkbox" name="conversion_product_#stock_id#" value="#stock_id#" id="_conversion_product_#currentrow#"><!--- onClick="aktif_yap();" --->
                                        </td>
                                        <!-- sil -->
                                    </tr>
                                    <cfif isdefined('PRICE_#STOCK_ID#')>
                                        <cfset "t1_fiyat#Evaluate('MONEY_#STOCK_ID#')#" = Evaluate("t1_fiyat#Evaluate('MONEY_#STOCK_ID#')#") + (Evaluate('PRICE_#STOCK_ID#')*get_total_material.AMOUNT)>
                                    </cfif>
                                </cfoutput>
                            </cfif>
                        </cfloop>
                        <cfloop query="get_total_material">
                        	<cfif category neq get_total_material.PRODUCT_CATID> 
                            	<cfif renk eq 1>
                                 	<cfset renk = 2>
                              	<cfelse>
                                 	<cfset renk = 1>
                             	</cfif>
                              	<cfset category = get_total_material.PRODUCT_CATID>
                          	</cfif>
                            <cfif attributes.list_type eq 3>
                                <cfoutput>
                                    <tr style="background-color:<cfif renk eq 1>mintcream<cfelse>white</cfif>"> 
                                        <td style="text-align:right; height:15px">#currentrow#</td>
                                        <cfif isdefined('attributes.is_lot_group')>
                                            <td title="#Evaluate("ORDER_NUMBER_#Replace(LOT_NO,' ','','All')#")# - #Evaluate("UNVAN_#Replace(LOT_NO,' ','','All')#")#">#get_total_material.LOT_NO#</td>
                                        </cfif>
                                        <td>
                                        	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
                                            	#get_total_material.PRODUCT_CODE#
                                            <cfelse>
                                            <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_detail_product&pid=#product_id#&sid=#stock_id#</cfoutput>','wide');"  class="tableyazi">
                                                #get_total_material.PRODUCT_CODE#
                                            </a>
                                            </cfif>
                                        </td>
                                        <td>#get_total_material.PRODUCT_NAME#</td>
                                        <td>#get_total_material.PRODUCT_CODE_2#</td>
                                        <td title="Master Plan <cf_get_lang dictionary_id='455.Üretim İhtiyacı'>" style="text-align:right; font-weight:bold">#TlFormat(get_total_material.AMOUNT,2)#</td>
                                        <td>#MAIN_UNIT#</td>
                                       	<td title="<cf_get_lang dictionary_id='57638.Birim Fiyat'>" style="text-align:right;<cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>">
                                            <cfif isdefined('PRICE_#STOCK_ID#')>
                                                #TlFormat(Evaluate('PRICE_#STOCK_ID#'),4)#
                                                <cfset row_price = Evaluate('PRICE_#STOCK_ID#')>
                                                 <input type="hidden" name="row_price_unit_#stock_id#" id="row_price_unit_#stock_id#" value="#tlformat(row_price)#">
                                            <cfelse>
                                            <cfset row_price = 0>
                                                #TlFormat(0,4)#
                                                 <input type="hidden" name="row_price_unit_#stock_id#" id="row_price_unit_#stock_id#" value="#tlformat(0)#">
                                            </cfif>
                                        </td>
                                        <td style="<cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>" title="<cf_get_lang dictionary_id='57677.Döviz'>">
                                            <cfif isdefined('MONEY_#STOCK_ID#')>
                                                #Evaluate('MONEY_#STOCK_ID#')#
                                                <input type="hidden" name="row_stock_money_#stock_id#" id="row_stock_money_#stock_id#" value="#Evaluate('MONEY_#STOCK_ID#')#" />
                                            <cfelse>
                                                <input type="hidden" name="row_stock_money_#stock_id#" id="row_stock_money_#stock_id#" value="#session.ep.money#" />
                                                #session.ep.money#
                                            </cfif>
                                        </td>
                                        <td title="<cf_get_lang dictionary_id='57673.Tutar'>" style="text-align:right; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>">
                                            <cfif isdefined('PRICE_#STOCK_ID#')>
                                                #TlFormat(Evaluate('PRICE_#STOCK_ID#')*get_total_material.AMOUNT,2)#
                                            <cfelse>
                                                #TlFormat(0,4)#
                                            </cfif>
                                        </td>
                                        <td style="<cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>" title="<cf_get_lang dictionary_id='57677.Döviz'>">
                                            <cfif isdefined('MONEY_#STOCK_ID#')>
                                                #Evaluate('MONEY_#STOCK_ID#')#
                                            <cfelse>
                                                #session.ep.money#
                                            </cfif>
                                        </td>
                                        <cfsavecontent variable="birim_"><cf_get_lang dictionary_id='58082.Adet'></cfsavecontent>
                                        <cfif len(PIECE_DETAIL)>
                                            <cfset detail = '#PIECE_DETAIL# - #ADET# #birim_#'>
                                        <cfelse>
                                            <cfset detail = ''>
                                        </cfif>
                                        <td title="<cf_get_lang dictionary_id='57771.Detay'>">
                                            #detail#
                                        </td>
                                        <cfset row_total_need = 0>
                                        <td title="<cf_get_lang dictionary_id='459.Plana Bağlı Açık Talepler'>" style="text-align:right">
                                            <cfif attributes.list_tur eq 1 or attributes.list_tur eq 3><!---İç Talep İse--->
                                                <cfif isdefined('IC_TALEP_MASTER_PLAN_#STOCK_ID#')>
                                                    #TlFormat(Evaluate('IC_TALEP_MASTER_PLAN_#STOCK_ID#'),2)#
                                                    <cfset row_total_need = get_total_material.AMOUNT - Evaluate('IC_TALEP_MASTER_PLAN_#STOCK_ID#')>
                                                <cfelse>
                                                    #TlFormat(0,2)#
                                                    <cfset row_total_need = get_total_material.AMOUNT>
                                                </cfif>
                                            <cfelse><!---Ambar Fişi İse--->
                                                <cfif isdefined('AMBAR_STOCK_#STOCK_ID#')>
                                                    #TlFormat(Evaluate('AMBAR_STOCK_#STOCK_ID#'),2)#
                                                    <cfset row_total_need = get_total_material.AMOUNT - Evaluate('AMBAR_STOCK_#STOCK_ID#')>
                                                <cfelse>
                                                    #TlFormat(0,2)#
                                                    <cfset row_total_need = get_total_material.AMOUNT>
                                                </cfif>
                                            </cfif>
                                        </td>
                                         <td title="<cf_get_lang dictionary_id='460.Gerçek Stok Minimum Stoktan Küçükse Minimum Sipariş Miktarı'>" style="text-align:right">
                                            <cfif row_total_need lt 0><cfset row_total_need = 0></cfif>
                                            <input type="text" name="row_total_need_#stock_id#" id="row_total_need_#stock_id#" value="#tlformat(row_total_need,2)#" class="box" style="width:60px;" onKeyup="return(FormatCurrency(this,event));" onBlur="hesapla(#stock_id#);">
                                            <input type="hidden" name="row_price_#stock_id#" id="row_price_#stock_id#" value="#tlformat(row_total_need*row_price)#" class="box" style="width:60px;" onKeyup="return(FormatCurrency(this,event));">
                                        </td>
                                        <!-- sil -->
                                        <td style="text-align:center">
                                             <input type="checkbox" name="conversion_product_#stock_id#" value="#stock_id#" id="_conversion_product_#currentrow#">
                                        </td>
                                        <!-- sil -->
                                    </tr>
                                </cfoutput>
                            </cfif>
                        </cfloop>
                    <cfelse>
                        <tr> 
                            <td colspan="20" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
                        </tr>
                    </cfif>
                    <tfoot>
                        <tr>
                            <td colspan="<cfif isdefined('attributes.is_lot_group')>7<cfelse>6</cfif>" style="text-align:left; height:10px">
                                <strong><cf_get_lang dictionary_id='57680.Genel Toplam'></strong> &nbsp;&nbsp; <cfoutput>#get_total_material.recordcount#</cfoutput>    <cf_get_lang dictionary_id='58082.Adet'> <cf_get_lang dictionary_id='57657.Ürün'>
                            </td>
                            <td style="text-align:right; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>">
                                <strong>
                                    <cfoutput query="get_money">
                                        <cfif evaluate('t1_fiyat#money#') gt 0>
                                            #TlFormat(evaluate('t1_fiyat#money#'),2)#<br>
                                            <cfset _t1_fiyat = _t1_fiyat + (evaluate('t1_fiyat#money#')*RATE2)>
                                        </cfif>      	            
                                    </cfoutput>
                                </strong>
                            </td>
                            <td style="text-align:left; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>">
                                <strong>
                                    <cfoutput query="get_money">
                                        <cfif evaluate('t1_fiyat#money#') gt 0>
                                            &nbsp;#money#<br>

                                        </cfif>       	            
                                    </cfoutput>
                                </strong>
                            </td>
                            <td style="text-align:right; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>"><strong><cfoutput>#TlFormat(_t1_fiyat,2)#</cfoutput></strong></td>
                            <td style="text-align:left; <cfif not ListFind(session.ep.power_user_level_id,2177)>display:none</cfif>"><strong><cfoutput>&nbsp;#session.ep.money#</cfoutput></strong></td>
                            <td id="alt_buton" colspan="<cfif attributes.list_type eq 3>3<cfelse>8</cfif>" style="text-align:right;">
                            	 <!-- sil -->
                                <cfif attributes.list_tur eq 1>
                                    <button  value="" name="satin_alma_talebi" id="satin_alma_talebi" onClick="kota_kontrol(3);" style="width:140px; height:30px;"><img src="/images/action_plus.gif" alt="<cf_get_lang dictionary_id='51117.İç Talep Ekle'>" border="0">&nbsp;<cf_get_lang dictionary_id='51117.İç Talep Ekle'></button>
                                <cfelseif attributes.list_tur eq 3>
                                	<button  value="" name="satin_alma_talebi" id="satin_alma_talebi" onClick="kota_kontrol(4);" style="width:140px; height:30px;"><img src="/images/action_plus.gif" alt="<cf_get_lang dictionary_id='49752.Satınalma Talebi'>" border="0">&nbsp;<cf_get_lang dictionary_id='49752.Satınalma Talebi'></button>
                                <cfelse>
                                    <button value="" name="ambar_fisi" id="ambar_fisi" onClick="kota_kontrol(2);" style="width:140px; height:30px;"><img src="/images/action_plus.gif" alt="<cf_get_lang dictionary_id='29630.Ambar Fişi'>" border="0">&nbsp;<cf_get_lang dictionary_id='29630.Ambar Fişi'></button>
                                </cfif>
                             	 <!-- sil -->   
                            </td>
                             <!-- sil -->
                            <td title="<cf_get_lang dictionary_id='206.Hepsini Seç'>" style="text-align:center"><cfif (isdefined("attributes.is_form_submitted") eq 1)><input type="checkbox" name="all_conv_product" id="all_conv_product" onClick="javascript: all_select_control('all_conv_product','_conversion_product_',<cfoutput>#get_total_material.recordcount#</cfoutput>);"></cfif></td>
                             <!-- sil -->
                        </tr>


                    </tfoot>
                </tbody>
          	</cf_grid_list>
      	</cf_box>
  	</cfform>
</div>
<form name="aktar_form" method="post">
    <input type="hidden" name="list_price" id="list_price" value="0">
    <input type="hidden" name="price_cat" id="price_cat" value="">
    <input type="hidden" name="CATALOG_ID" id="CATALOG_ID" value="">
    <input type="hidden" name="NUMBER_OF_INSTALLMENT" id="NUMBER_OF_INSTALLMENT" value="">
    <input type="hidden" name="convert_stocks_id" id="convert_stocks_id" value="">
	<input type="hidden" name="convert_amount_stocks_id" id="convert_amount_stocks_id" value="">
	<input type="hidden" name="convert_price" id="convert_price" value="">
	<input type="hidden" name="convert_price_other" id="convert_price_other" value="">
	<input type="hidden" name="convert_money" id="convert_money" value="">
</form>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		if(document.getElementById('is_excel').checked==false)
			return true;	
	}
	
	function kota_kontrol(type)
		/*
		___Type__
		1:Sevk İrsaliyesi
		2:Ambar Fişi
		*/
	{
		 var convert_list ="";
		 var convert_list_amount ="";
		 var convert_list_price ="";
		 var convert_list_price_other="";
		 var convert_list_money ="";
		 //
		 <cfif isdefined("attributes.is_form_submitted")>
			 <cfoutput query="get_total_material">
				 if(document.all.conversion_product_#stock_id#.checked && filterNum(document.getElementById('row_total_need_#stock_id#').value) > 0)
				 {
					convert_list += "#stock_id#,";
					convert_list_amount += filterNum(document.getElementById('row_total_need_#stock_id#').value)+',';

					convert_list_price_other += filterNum(document.getElementById('row_price_unit_#stock_id#').value,4)+',';
					convert_list_price += list_getat(document.getElementById('row_stock_money_#stock_id#').value,2,',')*filterNum(document.getElementById('row_price_unit_#stock_id#').value,4)+',';
					convert_list_money += list_getat(document.getElementById('row_stock_money_#stock_id#').value,1,',')+',';
				 }
			 </cfoutput>
		</cfif>
		document.getElementById('convert_stocks_id').value=convert_list;
		document.getElementById('convert_amount_stocks_id').value=convert_list_amount;
		document.getElementById('convert_price').value=convert_list_price;
		document.getElementById('convert_price_other').value=convert_list_price_other;
		document.getElementById('convert_money').value=convert_list_money;
		if(convert_list)//Ürün Seçili ise
		{
			 if(type==1)
			 {
				 aktar_form.action="<cfoutput>#request.self#</cfoutput>?fuseaction=stock.add_ship_dispatch&type=convert";
				 document.getElementById('sevk_irsaliyesi').disabled=true;
				 aktar_form.target='_blank';
			 }
			 if(type==2)
			 {
				 aktar_form.action="<cfoutput>#request.self#?fuseaction=stock.form_add_fis&type=convert<cfif isdefined('is_form_submitted') and isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>&ref_no=#get_master_plan_info.MASTER_PLAN_NUMBER#</cfif><cfif isdefined('attributes.project_id') and len(attributes.project_id) and len(attributes.project_head)>&project_id=#attributes.project_id#</cfif></cfoutput>";
				 document.getElementById('ambar_fisi').disabled=true;
				 aktar_form.target='_blank';
			 }
			 if(type==3)
			 {
				sor=confirm('<cf_get_lang dictionary_id='461.Seçilen Ürünler İçin Talep Oluşturulacaktır'>');
				if(sor==true)
				{

					aktar_form.action="<cfoutput>#request.self#?fuseaction=purchase.list_internaldemand&event=add&type=convert<cfif isdefined('is_form_submitted') and isdefined('attributes.master_plan_id') and len(attributes.master_plan_id) or isdefined('attributes.master_alt_plan_id') and len(attributes.master_alt_plan_id)>&ref_no=#get_master_plan_info.MASTER_PLAN_NUMBER#</cfif></cfoutput>";
					document.getElementById('satin_alma_talebi').disabled=true;
					aktar_form.target='_blank';
				}
				else
					return false;
				
			 }
			 if(type==4)
			 {
				sor=confirm('<cf_get_lang dictionary_id='461.Seçilen Ürünler İçin Talep Oluşturulacaktır'>');
				if(sor==true)

				{
					aktar_form.action="<cfoutput>#request.self#?fuseaction=purchase.list_purchasedemand&event=add&type=convert<cfif isdefined('is_form_submitted') and isdefined('attributes.master_plan_id') and len(attributes.master_plan_id) or isdefined('attributes.master_alt_plan_id') and len(attributes.master_alt_plan_id)>&ref_no=#get_master_plan_info.MASTER_PLAN_NUMBER#</cfif></cfoutput>";
					document.getElementById('satin_alma_talebi').disabled=true;
					aktar_form.target='_blank';
				}
				else
					return false;
				
			 }
			 aktar_form.submit();
		 }
		 else
		 	alert("<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='57657.Ürün'>.");
	}
	function all_select_control(all_conv_product,_conversion_product_,number)
	{
		for(var cl_ind=1; cl_ind <= number; cl_ind++)
		{
			if(document.getElementById(all_conv_product).checked == true)
			{
				if(document.getElementById('_conversion_product_'+cl_ind) != undefined && document.getElementById('_conversion_product_'+cl_ind).checked == false)
					document.getElementById('_conversion_product_'+cl_ind).checked = true;
			}
			else
			{
				if(document.getElementById('_conversion_product_'+cl_ind) != undefined && document.getElementById('_conversion_product_'+cl_ind).checked == true)
					document.getElementById('_conversion_product_'+cl_ind).checked = false;
			}
		}
	}
	function hesapla(stock_id)
	{
		document.getElementById('row_price_'+stock_id+'').value = commaSplit(parseFloat(document.getElementById('row_price_unit_'+stock_id+'').value*filterNum(document.getElementById('row_total_need_'+stock_id+'').value)));
	}
</script>