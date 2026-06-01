<cfif get_upd.STATUS eq 1> <!---Kilitli İse--->
   	<cfquery name="get_sonuc_detail" datasource="#dsn3#">
     	SELECT
        	3 AS INCOME,    
        	EAB.ANALYST_BRANCH_ID, 
        	EBR.SALES TOTAL_SALES, 
          	EBR.SMM, 
         	EBR.EXPENSE AS EXPENSE_GIDER, 
           	EBR.BRANCH_ID, 
          	EBR.BRANCH_NAME
		FROM        
         	EZGI_ANALYST_BRANCH_RESULT AS EBR INNER JOIN
         	EZGI_ANALYST_BRANCH AS EAB ON EBR.EZGI_ANALYST_BRANCH_ID = EAB.ANALYST_BRANCH_ID
		WHERE     
         	EBR.EZGI_ANALYST_BRANCH_ID = #attributes.upd_id#
    	<cfif get_upd.IS_BRANCH eq 0><!---Merkez İse--->
         	UNION ALL
            SELECT 
            	2 AS INCOME,    
        		EAB.ANALYST_BRANCH_ID,    
                EBR.SALES TOTAL_SALES, 
                EBR.SMM, 
                EBR.EXPENSE AS EXPENSE_GIDER, 
                EBR.BRANCH_ID, 
                EBR.BRANCH_NAME
            FROM        
                EZGI_ANALYST_BRANCH_RESULT AS EBR INNER JOIN
                EZGI_ANALYST_BRANCH AS EAB ON EBR.EZGI_ANALYST_BRANCH_ID = EAB.ANALYST_BRANCH_ID
            WHERE     
                EBR.EZGI_ANALYST_BRANCH_ID <> #attributes.upd_id# AND 
                EAB.IS_BRANCH = 1 AND 
                EAB.MONTH_VALUE = #get_upd.MONTH_VALUE# AND 
                EAB.YEAR_VALUE = #get_upd.YEAR_VALUE#
 		</cfif>
  	</cfquery>
<cfelse><!---Cari Dönemden Hesapla--->
	<cfinclude template="../query/get_ezgi_branch_gelirler.cfm">
	<cfinclude template="../query/get_ezgi_branch_giderler.cfm">
 	<cfset rate = 0>
    <cfset get_sonuc_detail = queryNew("ANALYST_BRANCH_ID, INCOME, BRANCH_ID, BRANCH_NAME, TOTAL_SALES, SMM, EXPENSE_GIDER","integer, integer, integer, VarChar, Decimal, Decimal, Decimal") />
    <cfif get_upd.IS_BRANCH eq 0> <!---Merkez İse--->
    	<cfquery name="get_TOTAL_center" datasource="#dsn3#">
        	SELECT 
            	3 AS INCOME,    
        		EAB.ANALYST_BRANCH_ID,    
                EBR.SALES, 
                EBR.SMM TOTAL_SALES,
                EBR.COST SMM,
                0 AS EXPENSE_GIDER, 
                EBR.BRANCH_ID, 
                EBR.BRANCH_NAME
            FROM        
                EZGI_ANALYST_BRANCH_RESULT AS EBR INNER JOIN
                EZGI_ANALYST_BRANCH AS EAB ON EBR.EZGI_ANALYST_BRANCH_ID = EAB.ANALYST_BRANCH_ID
            WHERE     
                EAB.IS_BRANCH = 1 AND 
                EAB.MONTH_VALUE = #get_upd.MONTH_VALUE# AND 
                EAB.YEAR_VALUE = #get_upd.YEAR_VALUE#
     	</cfquery>
        <cfif get_TOTAL_center.recordcount>
        	<cfoutput query="get_TOTAL_center">
        		<cfset temp = QueryAddRow(get_sonuc_detail)>
                <cfset Temp = QuerySetCell(get_sonuc_detail, "ANALYST_BRANCH_ID", ANALYST_BRANCH_ID)>
  				<cfset Temp = QuerySetCell(get_sonuc_detail, "INCOME", INCOME)>
                <cfset Temp = QuerySetCell(get_sonuc_detail, "BRANCH_ID", BRANCH_ID)> 
              	<cfset Temp = QuerySetCell(get_sonuc_detail, "BRANCH_NAME", BRANCH_NAME)>  
                <cfset Temp = QuerySetCell(get_sonuc_detail, "TOTAL_SALES", TOTAL_SALES)>
                <cfset Temp = QuerySetCell(get_sonuc_detail, "SMM", SMM)>
                <cfset Temp = QuerySetCell(get_sonuc_detail, "EXPENSE_GIDER", EXPENSE_GIDER)>
        	</cfoutput>
     	</cfif>       
  	</cfif>
    <cfif get_upd.IS_BRANCH eq 0> <!---Merkez İse--->
		<cfset temp = QueryAddRow(get_sonuc_detail)>
        <cfset Temp = QuerySetCell(get_sonuc_detail, "ANALYST_BRANCH_ID", 0)>
        <cfset Temp = QuerySetCell(get_sonuc_detail, "INCOME", 2)>
        <cfset Temp = QuerySetCell(get_sonuc_detail, "BRANCH_ID", 0)> 
      	<cfset Temp = QuerySetCell(get_sonuc_detail, "BRANCH_NAME", '')>  
      	<cfset Temp = QuerySetCell(get_sonuc_detail, "TOTAL_SALES", satis_total)>
      	<cfset Temp = QuerySetCell(get_sonuc_detail, "SMM", purchase_total)>
      	<cfset Temp = QuerySetCell(get_sonuc_detail, "EXPENSE_GIDER", expense_gider)>
 	<cfelse> <!---Şube İse--->
    	<cfset temp = QueryAddRow(get_sonuc_detail)>
        <cfset Temp = QuerySetCell(get_sonuc_detail, "ANALYST_BRANCH_ID", 0)>
        <cfset Temp = QuerySetCell(get_sonuc_detail, "INCOME", 2)>
        <cfset Temp = QuerySetCell(get_sonuc_detail, "BRANCH_ID", 0)> 
      	<cfset Temp = QuerySetCell(get_sonuc_detail, "BRANCH_NAME", '')>  
      	<cfset Temp = QuerySetCell(get_sonuc_detail, "TOTAL_SALES", satis_total)>
      	<cfset Temp = QuerySetCell(get_sonuc_detail, "SMM", purchase_total)>
      	<cfset Temp = QuerySetCell(get_sonuc_detail, "EXPENSE_GIDER", expense_gider)>
    </cfif>   
</cfif>
<cfquery name="get_sonuc_total" dbtype="query">
    	SELECT
        	SUM(SMM) AS SMM, 
            SUM(TOTAL_SALES) AS TOTAL_SALES,
            SUM(EXPENSE_GIDER) AS EXPENSE_GIDER
     	FROM
        	get_sonuc_detail
    </cfquery>
    <cfquery name="get_sonuc_detail" dbtype="query">
    	SELECT * FROM get_sonuc_detail ORDER BY BRANCH_NAME
    </cfquery>
<cfset sonuc_smm = 0>
<cfset sonuc_total_sales = 0>
<cfset sonuc_total_expense = 0>
<cfif get_sonuc_total.recordcount>
	<cfset sonuc_smm = get_sonuc_total.smm>
	<cfset sonuc_total_sales = get_sonuc_total.total_sales>
    <cfset sonuc_total_expense = get_sonuc_total.expense_gider>
</cfif>