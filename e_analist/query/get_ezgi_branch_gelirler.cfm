<cfif get_upd.STATUS eq 1>
	<cfquery name="get_sales" datasource="#dsn3#">
    	SELECT        
        	NETTOTAL, 
            PRODUCT_CAT, 
            PRODUCT_CATID, TYPE
		FROM            
        	EZGI_ANALYST_BRANCH_ROW
		WHERE        
        	INCOME = 1 AND 
            EZGI_ANALYST_BRANCH_ID = #attributes.upd_id#
    </cfquery>
    <cfquery name="GET_HEDEF_sales" datasource="#DSN3#">
    	SELECT TOP (1) ISNULL(TARGET,0) AS HEDEF FROM EZGI_ANALYST_BRANCH_ROW WHERE INCOME = 1 AND EZGI_ANALYST_BRANCH_ID = #attributes.upd_id#
    </cfquery>
<cfelse>
    <cfquery name="get_sales" datasource="#dsn#">
        SELECT        
            ISNULL(SUM(IRD.NETTOTAL), 0) AS NETTOTAL, 
            PC.PRODUCT_CAT, 
            PC.PRODUCT_CATID,
            1 AS TYPE
        FROM            
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.INVOICE_ROW_SALES_DETAIL AS IRD INNER JOIN
            #dsn1_alias#.PRODUCT AS P ON IRD.PRODUCT_ID = P.PRODUCT_ID INNER JOIN
            #dsn1_alias#.PRODUCT_CAT AS PC ON P.PRODUCT_CATID = PC.PRODUCT_CATID
        WHERE        
            YEAR(IRD.INVOICE_DATE) = #get_upd.YEAR_VALUE# AND 
            MONTH(IRD.INVOICE_DATE) = #get_upd.MONTH_VALUE# AND 
            IRD.DEPARTMENT_ID IN
                            (
                                SELECT        
                                    DEPARTMENT_ID
                                FROM            
                                    #dsn_alias#.DEPARTMENT
                                WHERE        
                                    BRANCH_ID = #get_upd.BRANCH_ID#
                            )
        GROUP BY
            PC.PRODUCT_CAT, 
            PC.PRODUCT_CATID
        UNION ALL
        SELECT        
            SUM(EIE.AMOUNT) AS NETTOTAL, 
            EIC.EXPENSE_CAT_NAME PRODUCT_CAT, 
            EIC.EXPENSE_CAT_ID PRODUCT_CATID,
            2 AS TYPE
        FROM            
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEMS_ROWS AS EIE INNER JOIN
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEMS AS EI ON EIE.EXPENSE_ITEM_ID = EI.EXPENSE_ITEM_ID INNER JOIN
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_CATEGORY AS EIC ON EI.EXPENSE_CATEGORY_ID = EIC.EXPENSE_CAT_ID
        WHERE        
            EIE.EXPENSE_ID IN
                            (
                                SELECT        
                                    EXPENSE_ID
                                FROM            
                                    #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEM_PLANS
                                WHERE        
                                    MONTH(EXPENSE_DATE) = #get_upd.MONTH_VALUE# AND 
                                    YEAR(EXPENSE_DATE) = #get_upd.YEAR_VALUE# AND
                                    BRANCH_ID = #get_upd.BRANCH_ID#
                            ) AND 
            EI.IS_EXPENSE = 0
        GROUP BY 
            EIC.EXPENSE_CAT_NAME, 
            EIC.EXPENSE_CAT_ID
        ORDER BY
            PRODUCT_CAT
    </cfquery>
    
    <cfquery name="GET_HEDEF_sales" datasource="#DSN#">
        SELECT        
            ISNULL(SUM(ROW_TOTAL_INCOME),0) AS HEDEF
        FROM            
            BUDGET_PLAN_ROW
        WHERE        
            BUDGET_PLAN_ID IN
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
            YEAR(PLAN_DATE) = #get_upd.YEAR_VALUE# AND 
            MONTH(PLAN_DATE) = #get_upd.MONTH_VALUE# AND 
            ROW_TOTAL_INCOME > 0
        
    </cfquery>
</cfif>
<cfquery name="get_sales_TOTAL" dbtype="query">
 	SELECT SUM(NETTOTAL) AS NETTOTAL FROM get_sales
</cfquery>
