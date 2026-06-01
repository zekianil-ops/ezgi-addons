
<cfif get_upd.STATUS eq 1>
	<cfif get_upd.IS_BRANCH eq 0>
    	<cfquery name="get_TOTAL_DETAIL" datasource="#dsn3#">
          	SELECT      
            	ABR.INCOME, 
            	B.BRANCH_NAME,
                B.BRANCH_ID,
             	ABR.LISTE_FIYAT,
             	ABR.SMM AS SMM,
            	ABR.NETTOTAL AS TOTAL_SALES,
             	ABR.TARGET AS TOTAL_COST ,
              	ABR.EXPENSE EXPENSE_GIDER
          	FROM            
            	EZGI_ANALYST_BRANCH_ROW AS ABR INNER JOIN
              	EZGI_ANALYST_BRANCH AS AB ON ABR.EZGI_ANALYST_BRANCH_ID = AB.ANALYST_BRANCH_ID INNER JOIN
             	#dsn_alias#.BRANCH AS B ON AB.BRANCH_ID = B.BRANCH_ID
         	WHERE        
            	ABR.EZGI_ANALYST_BRANCH_ID = #attributes.upd_id# AND
            	ABR.INCOME = 3 AND 
           		AB.MONTH_VALUE = #get_upd.MONTH_VALUE# AND 
           		AB.YEAR_VALUE = #get_upd.YEAR_VALUE#
         	UNION ALL
            SELECT      
            	ABR.INCOME, 
            	B.BRANCH_NAME,
                B.BRANCH_ID,
             	ABR.LISTE_FIYAT,
             	ABR.TARGET AS SMM,
            	ABR.SMM AS TOTAL_SALES,
             	ABR.NETTOTAL TOTAL_COST ,
              	0 AS EXPENSE_GIDER
          	FROM            
            	EZGI_ANALYST_BRANCH_ROW AS ABR INNER JOIN
              	EZGI_ANALYST_BRANCH AS AB ON ABR.EZGI_ANALYST_BRANCH_ID = AB.ANALYST_BRANCH_ID INNER JOIN
             	#dsn_alias#.BRANCH AS B ON AB.BRANCH_ID = B.BRANCH_ID
         	WHERE        
            	AB.IS_BRANCH = 1 AND 
            	ABR.INCOME = 3 AND 
           		AB.MONTH_VALUE = #get_upd.MONTH_VALUE# AND 
           		AB.YEAR_VALUE = #get_upd.YEAR_VALUE#
     	</cfquery>

        <cfquery name="get_TOTAL" dbtype="query">
            SELECT
                SUM(LISTE_FIYAT) AS LISTE_FIYAT, 
                SUM(SMM) AS SMM, 
                SUM(TOTAL_SALES) AS TOTAL_SALES,
                SUM(TOTAL_COST) AS TOTAL_COST,
                SUM(EXPENSE_GIDER) AS EXPENSE_GIDER
            FROM
                get_TOTAL_DETAIL
        </cfquery>
   	<cfelse>
        <cfquery name="get_TOTAL" datasource="#dsn3#">
            SELECT        
                SMM, 
                LISTE_FIYAT, 
                NETTOTAL AS TOTAL_SALES, 
                TARGET AS TOTAL_COST,
                EXPENSE EXPENSE_GIDER
            FROM            
                EZGI_ANALYST_BRANCH_ROW
            WHERE        
                INCOME = 3 AND 
                EZGI_ANALYST_BRANCH_ID = #attributes.upd_id#
        </cfquery>
 	</cfif>
<cfelse>
    <cfquery name="GET_INVOICE" datasource="#DSN3#">
        SELECT        
            IR.STOCK_ID, 
            <cfif get_upd.IS_BRANCH eq 1>
                CASE
                    WHEN IR.LIST_PRICE >0 THEN IR.AMOUNT * IR.LIST_PRICE
                    ELSE IR.AMOUNT * IR.PRICE
                END AS LISTE_FIYAT,
                ISNULL(IR.LIST_PRICE,0) LIST_PRICE,
            <cfelse>
                (IR.COST_PRICE + IR.EXTRA_COST) * IR.AMOUNT AS LISTE_FIYAT,
                IR.COST_PRICE + IR.EXTRA_COST AS LIST_PRICE,
            </cfif>
            (IR.COST_PRICE + IR.EXTRA_COST) * IR.AMOUNT AS ROW_COST,
            IR.PRICE, 
            IR.PRICE_CAT, 
            IR.PRODUCT_ID, 
            IR.NETTOTAL, 
            IR.NAME_PRODUCT, 
            I.INVOICE_DATE, 
            I.INVOICE_NUMBER
        FROM            
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.INVOICE AS I INNER JOIN
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.INVOICE_ROW AS IR ON I.INVOICE_ID = IR.INVOICE_ID
        WHERE        
            I.PURCHASE_SALES = 1 AND 
            YEAR(I.INVOICE_DATE) = #get_upd.YEAR_VALUE# AND 
            MONTH(I.INVOICE_DATE) = #get_upd.MONTH_VALUE# AND 
            I.DEPARTMENT_ID IN
                            (
                                SELECT        
                                    DEPARTMENT_ID
                                FROM            
                                    #dsn_alias#.DEPARTMENT
                                WHERE        
                                    BRANCH_ID = #get_upd.BRANCH_ID#
                            )
    </cfquery>
    <cfquery name="get_control" dbtype="query">
        select * from GET_INVOICE where LIST_PRICE <= 0 order by INVOICE_NUMBER
    </cfquery>
    <cfif len(get_upd.RATE)>
        <cfset rate = get_upd.RATE>
    <cfelse>
        <cfset rate = 0>
    </cfif>
    <cfif get_upd.IS_BRANCH eq 0>
    	<cfquery name="get_TOTAL_center" datasource="#dsn3#">
          	SELECT      
            	ABR.INCOME, 
                B.BRANCH_ID,
            	B.BRANCH_NAME,
             	ABR.LISTE_FIYAT,
             	ABR.TARGET AS SMM,
            	ABR.SMM AS TOTAL_SALES,
             	ABR.NETTOTAL TOTAL_COST ,
              	ABR.EXPENSE EXPENSE_GIDER
          	FROM            
            	EZGI_ANALYST_BRANCH_ROW AS ABR INNER JOIN
              	EZGI_ANALYST_BRANCH AS AB ON ABR.EZGI_ANALYST_BRANCH_ID = AB.ANALYST_BRANCH_ID INNER JOIN
             	#dsn_alias#.BRANCH AS B ON AB.BRANCH_ID = B.BRANCH_ID
         	WHERE        
            	AB.IS_BRANCH = 1 AND 
            	ABR.INCOME = 3 AND 
           		AB.MONTH_VALUE = #get_upd.MONTH_VALUE# AND 
           		AB.YEAR_VALUE = #get_upd.YEAR_VALUE#
     	</cfquery>
  	</cfif>
	<cfif len(get_sales_TOTAL.NETTOTAL)>
        <cfset satis_total = get_sales_TOTAL.NETTOTAL>
    <cfelse>
        <cfset satis_total = 0>
    </cfif>
    <cfif len(GET_TOTAL_EXPENSE.GIDER)>
     	<cfset expense_gider = GET_TOTAL_EXPENSE.GIDER>
  	<cfelse>
     	<cfset expense_gider = 0>
  	</cfif>
    <cfquery name="get_TOTAL_DETAIL" dbtype="query">
      	<cfif get_upd.IS_BRANCH eq 0>
        	SELECT 
                2 AS INCOME,
                '' AS BRANCH_NAME,
                0 AS BRANCH_ID,
                SUM(LISTE_FIYAT) AS LISTE_FIYAT, 
              	SUM(LISTE_FIYAT) AS SMM, 
                #satis_total# AS TOTAL_SALES,
                SUM(ROW_COST) AS TOTAL_COST,
                #expense_gider# AS EXPENSE_GIDER
            FROM   
                GET_INVOICE  
            UNION ALL
            SELECT      
            	INCOME, 
                BRANCH_NAME,
             	BRANCH_ID,
             	LISTE_FIYAT,
           		SMM,
              	TOTAL_SALES,
            	TOTAL_COST,
                0 AS EXPENSE_GIDER
          	FROM            
            	get_TOTAL_center
       	<cfelse>
        	SELECT 
                2 AS INCOME,
                '' AS BRANCH_NAME,
                0 AS BRANCH_ID,
            	SUM(LISTE_FIYAT) - SUM(LISTE_FIYAT) * #rate# / 100 AS SMM, 
                SUM(LISTE_FIYAT) AS LISTE_FIYAT,
                #satis_total# AS TOTAL_SALES,
                SUM(ROW_COST) AS TOTAL_COST,
                #expense_gider# AS EXPENSE_GIDER
            FROM   
                GET_INVOICE  
        </cfif>
    </cfquery>
    <cfquery name="get_TOTAL" dbtype="query">
    	SELECT
        	SUM(LISTE_FIYAT) AS LISTE_FIYAT, 
        	SUM(SMM) AS SMM, 
            SUM(TOTAL_SALES) AS TOTAL_SALES,
            SUM(TOTAL_COST) AS TOTAL_COST,
            SUM(EXPENSE_GIDER) AS EXPENSE_GIDER
     	FROM
        	get_TOTAL_DETAIL
    </cfquery>
    <cfif get_control.recordcount>
		<cfif get_upd.IS_BRANCH eq 1>
			<script type="text/javascript">
             	alert("<cfoutput query='get_control'>#INVOICE_NUMBER# Nolu Faturada #NAME_PRODUCT#, </cfoutput> Ürünü Fiyat Listesinde Bulunamamıştır.");
          	</script>
     	<cfelse>
        	<script type="text/javascript">
             	alert("<cfoutput query='get_control'>#INVOICE_NUMBER# Nolu Faturada #NAME_PRODUCT#, </cfoutput> Ürünün Maliyeti Bulunamamıştır.");
          	</script>
        </cfif>
    </cfif>
</cfif>