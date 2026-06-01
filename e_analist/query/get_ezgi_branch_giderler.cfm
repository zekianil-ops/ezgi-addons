<cfif get_upd.STATUS eq 1>
	<cfquery name="GET_HEDEF" datasource="#DSN3#">
    	SELECT        
        	ISNULL(NETTOTAL,0) AS GIDER, 
            ISNULL(TARGET,0) AS HEDEF,
            PRODUCT_CAT AS EXPENSE_CAT_NAME, 
            PRODUCT_CATID AS EXPENSE_CAT_ID,
            DETAIL AS EXPENSE_ITEM_NAME, 
            DETAIL_ID AS EXPENSE_ITEM_ID 
		FROM            
        	EZGI_ANALYST_BRANCH_ROW
		WHERE        
        	INCOME = 2 AND 
            EZGI_ANALYST_BRANCH_ID = #attributes.upd_id#
    </cfquery>
<cfelse>
    <cfquery name="GET_HEDEF" datasource="#DSN#">
        SELECT
            SUM(HEDEF) HEDEF,
            SUM(GIDER) GIDER,
            EXPENSE_ITEM_ID, 
            EXPENSE_ITEM_NAME,
            (
                SELECT        
                    EC.EXPENSE_CAT_NAME
                FROM            
                    #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEMS AS EI INNER JOIN
                    #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_CATEGORY AS EC ON EI.EXPENSE_CATEGORY_ID = EC.EXPENSE_CAT_ID
                WHERE        
                    EI.EXPENSE_ITEM_ID = TBL.EXPENSE_ITEM_ID
            ) EXPENSE_CAT_NAME,
            (
                SELECT        
                    EC.EXPENSE_CAT_ID
                FROM            
                    #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEMS AS EI INNER JOIN
                    #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_CATEGORY AS EC ON EI.EXPENSE_CATEGORY_ID = EC.EXPENSE_CAT_ID
                WHERE        
                    EI.EXPENSE_ITEM_ID = TBL.EXPENSE_ITEM_ID
            ) EXPENSE_CAT_ID
        FROM
            (
            SELECT        
                EIE.EXPENSE_ITEM_ID, 
                EI.EXPENSE_ITEM_NAME, 
                0 AS HEDEF,
                SUM(EIE.AMOUNT) AS GIDER
            FROM            
                #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEMS_ROWS AS EIE INNER JOIN
                #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEMS AS EI ON EIE.EXPENSE_ITEM_ID = EI.EXPENSE_ITEM_ID
            WHERE   
                EI.IS_EXPENSE = 1 AND
                EIE.EXPENSE_ID IN
                                (
                                    SELECT        
                                        EXPENSE_ID
                                    FROM            
                                        #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEM_PLANS
                                    WHERE        
                                        MONTH(EXPENSE_DATE) = #get_upd.MONTH_VALUE# AND 
                                        YEAR(EXPENSE_DATE) = #get_upd.YEAR_VALUE#
                                ) AND
            	EIE.EXPENSE_CENTER_ID IN 
                				(
                                	SELECT        
                                    	EXPENSE_ID
									FROM            
                                    	#dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_CENTER
									WHERE        
                                    	ISNULL(IS_PRODUCTION, 0) = 0 AND 
                                        ISNULL(IS_GENERAL, 0) = 1 AND 
                                        EXPENSE_BRANCH_ID = #get_upd.BRANCH_ID#
                                )
            GROUP BY 
                EIE.EXPENSE_ITEM_ID, 
                EI.EXPENSE_ITEM_NAME
            UNION ALL
            SELECT 
                EI.EXPENSE_ITEM_ID, 
                EI.EXPENSE_ITEM_NAME,
                SUM(BPR.ROW_TOTAL_EXPENSE) AS HEDEF, 
                0 AS GIDER
            FROM            
                BUDGET_PLAN_ROW AS BPR INNER JOIN
                #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEMS AS EI ON BPR.BUDGET_ITEM_ID = EI.EXPENSE_ITEM_ID
            WHERE        
                BPR.BUDGET_PLAN_ID IN
                                    (
                                        SELECT        
                                            BUDGET_PLAN_ID
                                        FROM            
                                            BUDGET_PLAN
                                        WHERE        
                                            BUDGET_ID IN
                                                        (
                                                            SELECT        
                                                                BUDGET_ID
                                                            FROM            
                                                                BUDGET
                                                            WHERE        
                                                                PERIOD_YEAR = #get_upd.YEAR_VALUE# AND 
                                                                BRANCH_ID = #get_upd.BRANCH_ID#
                                                        )
                                    ) AND 
                YEAR(BPR.PLAN_DATE) = #get_upd.YEAR_VALUE# AND 
                MONTH(BPR.PLAN_DATE) = #get_upd.MONTH_VALUE# AND 
                BPR.ROW_TOTAL_EXPENSE > 0
            GROUP BY 
                EI.EXPENSE_ITEM_NAME, 
                EI.EXPENSE_ITEM_ID
            ) AS TBL
        GROUP BY
            EXPENSE_ITEM_NAME, 
            EXPENSE_ITEM_ID
        ORDER BY 
            EXPENSE_ITEM_NAME
    </cfquery>
</cfif>
<cfquery name="GET_HEDEF_CATEGORY" dbtype="query">
        SELECT
            SUM(HEDEF) HEDEF,
            SUM(GIDER) GIDER,
            EXPENSE_CAT_NAME,
            EXPENSE_CAT_ID
        FROM
            GET_HEDEF
        GROUP BY
            EXPENSE_CAT_NAME,
            EXPENSE_CAT_ID	   
</cfquery>

<cfquery name="GET_TOTAL_EXPENSE" dbtype="query">
	SELECT
    	SUM(HEDEF) HEDEF,
        SUM(GIDER) GIDER
  	FROM
    	GET_HEDEF_CATEGORY
</cfquery>