<cfset cost_total = 0>
<cfset purchase_total = 0>
<cfset satis_total = 0>
<cfset hedef_total = 0>
<cfset satis_quantity = 0>
<cfset hedef_quantity = 0>
<cfset get_sales.recordcount = 0>
<cfif get_upd.STATUS eq 1> <!---Kilitliyse--->
	<cfquery name="get_sales" datasource="#dsn3#">
    	SELECT 
        	NETTOTAL, 
            QUANTITY, 
            PRODUCT_CAT, 
            PRODUCT_CATID, 
            TYPE, 
            TARGET_NETTOTAL H_NETTOTAL, 
            TARGET_QUANTITY H_QUANTITY, 
            EXPENSE,
            0 AS PURCHASETOTAL,
            0 AS COSTTOTAL
		FROM            
        	EZGI_ANALYST_BRANCH_ROW
		WHERE        
        	INCOME = 1 AND 
            EZGI_ANALYST_BRANCH_ID = #attributes.upd_id#
    </cfquery>
<cfelse> <!---Cari Dönemse--->
	<cfquery name="GET_HEDEF_sales" datasource="#DSN3#"> <!---Satış Hedefleri - Kotlardan--->
    	SELECT     
            SQR.CATEGORY_ID, 
            SUM(SQR.QUANTITY) AS QUANTITY, 
            SUM(SQR.ROW_TOTAL) AS TOTAL,
            (SELECT PRODUCT_CAT FROM #dsn1_alias#.PRODUCT_CAT WHERE PRODUCT_CATID = SQR.CATEGORY_ID) AS PRODUCT_CAT,
            (SELECT HIERARCHY FROM #dsn1_alias#.PRODUCT_CAT WHERE PRODUCT_CATID = SQR.CATEGORY_ID) AS HIERARCHY
		FROM        
       		SALES_QUOTAS AS SQ INNER JOIN
           	SALES_QUOTAS_ROW AS SQR ON SQ.SALES_QUOTA_ID = SQR.SALES_QUOTA_ID
		WHERE     
        	SQ.IS_ACTIVE = 1 AND
            SQ.BRANCH_ID = #get_upd.BRANCH_ID# AND 
            MONTH(SQ.PLAN_DATE) = #get_upd.MONTH_VALUE# AND
            YEAR(SQ.PLAN_DATE) = #get_upd.YEAR_VALUE#
		GROUP BY 
            SQR.CATEGORY_ID
    </cfquery>
    <cfquery name="get_sales_gelir" datasource="#dsn#"> <!---Gelirler--->
        SELECT
            SUM(EIE.AMOUNT) AS NETTOTAL, 
            EIC.EXPENSE_CAT_NAME PRODUCT_CAT, 
            EIC.EXPENSE_CAT_ID PRODUCT_CATID,
            COUNT(*) AS QUANTITY,
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
                                    YEAR(EXPENSE_DATE) = #get_upd.YEAR_VALUE# 
                            ) AND 
            ISNULL(EI.IS_EXPENSE,0) = 0 AND
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
            EIC.EXPENSE_CAT_NAME, 
            EIC.EXPENSE_CAT_ID
        ORDER BY
            PRODUCT_CAT
    </cfquery>
    <cfquery name="get_stage_default" datasource="#dsn3#">
       	SELECT VIRTUAL_OFFER_STAGES_2 FROM EZGI_VIRTUAL_OFFER_DEFAULTS
    </cfquery>
    <cfquery name="get_sanal_teklif" datasource="#dsn3#"><!--- Satışlar--->
       	SELECT 
            	ISNULL((
                    SELECT     
                        TOP (1) RATE2
                    FROM        
                        EZGI_VIRTUAL_OFFER_MONEY
                    WHERE     
                        ACTION_ID = EVO.VIRTUAL_OFFER_ID AND 
                        MONEY_TYPE = EVOR.OTHER_MONEY
                 ),1) AS PRICE_RATE2,
            	ISNULL((
                    SELECT     
                        TOP (1) RATE2
                    FROM        
                        EZGI_VIRTUAL_OFFER_MONEY
                    WHERE     
                        ACTION_ID = EVO.VIRTUAL_OFFER_ID AND 
                        MONEY_TYPE = ISNULL(EVOR.COST_PRICE_MONEY,'#session.ep.money#')
                 ),1) AS COST_RATE2,
                 ISNULL((
                    SELECT     
                        TOP (1) RATE2
                    FROM        
                        EZGI_VIRTUAL_OFFER_MONEY
                    WHERE     
                        ACTION_ID = EVO.VIRTUAL_OFFER_ID AND 
                        MONEY_TYPE = ISNULL(EVOR.PURCHASE_PRICE_MONEY,'#session.ep.money#')
                 ),1) AS PURCHASE_RATE2,
                PC.PRODUCT_CATID,    
            	PC.PRODUCT_CAT, 
                EVOR.QUANTITY,
                EVOR.PRICE,
                EVOR.OTHER_MONEY, 
                EVOR.COST_PRICE, 
                EVOR.COST_PRICE_MONEY, 
                EVOR.PURCHASE_PRICE, 
                EVOR.PURCHASE_PRICE_MONEY, 
                EVOR.DISCOUNT_1, 
                EVOR.DISCOUNT_2, 
                EVOR.DISCOUNT_3, 
                EVOR.DISCOUNT_COST, 
                EVOR.COST, 
                EVO.VIRTUAL_OFFER_DATE 
			FROM        
            	EZGI_VIRTUAL_OFFER_ROW AS EVOR INNER JOIN
                STOCKS AS S ON EVOR.STOCK_ID = S.STOCK_ID INNER JOIN
                #dsn1_alias#.PRODUCT_CAT AS PC ON S.PRODUCT_CATID = PC.PRODUCT_CATID INNER JOIN
             	EZGI_VIRTUAL_OFFER AS EVO ON EVOR.VIRTUAL_OFFER_ID = EVO.VIRTUAL_OFFER_ID
			WHERE     
            	EVO.VIRTUAL_OFFER_STATUS = 1 AND 
                ISNULL(EVO.IS_CANCEL,0) = 0 AND 
                EVO.REVISION_ID IS NULL AND
                MONTH(EVO.FINISHDATE) = #get_upd.MONTH_VALUE# AND 
              	YEAR(EVO.FINISHDATE) = #get_upd.YEAR_VALUE# AND
              	EVO.BRANCH_ID = #get_upd.BRANCH_ID# 
                <cfif len(get_stage_default.VIRTUAL_OFFER_STAGES_2)>
                	AND EVO.VIRTUAL_OFFER_STAGE NOT IN (#get_stage_default.VIRTUAL_OFFER_STAGES_2#)
                </cfif>
			ORDER BY 
            	EVOR.VIRTUAL_OFFER_ID DESC
    </cfquery>
    <cfset get_sales_temp = queryNew("TYPE_, PRODUCT_CATID_, PRODUCT_CAT_, NETTOTAL_,QUANTITY_,PURCHASE_,COST_","integer, integer, VarChar, Decimal, Decimal, Decimal, Decimal") />
    <cfif get_sanal_teklif.recordcount>
       	<cfoutput query="get_sanal_teklif"> <!---Net Tutatrlar Hesaplanıyor--->
     		<cfset total_row_cost_ = quantity*(COST_PRICE*cost_rate2+cost*cost_rate2)>
            <cfif get_upd.IS_BRANCH eq 0><!---Merkez İse--->
       			<cfset total_row_purchase_ = quantity*(COST_PRICE*cost_rate2+cost*cost_rate2)>
          	<cfelse><!---Şube İse--->
            	<cfset total_row_purchase_ = quantity*(PURCHASE_PRICE*purchase_rate2+cost*price_rate2)>
            </cfif>
         	<cfset row_net_other_ = price+cost-discount_cost>
          	<cfset row_net_other_ = row_net_other_*price_rate2>
         	<cfset row_net_other_ = row_net_other_-(row_net_other_*discount_1/100)>
          	<cfset row_net_other_ = row_net_other_-(row_net_other_*discount_2/100)>
          	<cfset row_net_other_ = row_net_other_-(row_net_other_*discount_3/100)>
          	<cfset row_net_other_ = row_net_other_*quantity>
         	<cfset temp = QueryAddRow(get_sales_temp)>
           	<cfset Temp = QuerySetCell(get_sales_temp, "TYPE_", 1)>
           	<cfset Temp = QuerySetCell(get_sales_temp, "PRODUCT_CATID_", PRODUCT_CATID)>
           	<cfset Temp = QuerySetCell(get_sales_temp, "PRODUCT_CAT_", PRODUCT_CAT)>
          	<cfset Temp = QuerySetCell(get_sales_temp, "NETTOTAL_", row_net_other_)> 
          	<cfset Temp = QuerySetCell(get_sales_temp, "QUANTITY_", QUANTITY)> 
            <cfset Temp = QuerySetCell(get_sales_temp, "PURCHASE_", total_row_purchase_)>
            <cfset Temp = QuerySetCell(get_sales_temp, "COST_", total_row_cost_)>
        </cfoutput>
    </cfif>
    <cfset get_sales = queryNew("TYPE, PRODUCT_CATID, PRODUCT_CAT, NETTOTAL, QUANTITY, H_QUANTITY, H_NETTOTAL, PURCHASETOTAL, COSTTOTAL","integer, integer, VarChar, Decimal, Decimal, Decimal, Decimal, Decimal, Decimal") />
    <cfif get_sales_temp.recordcount>
       	<cfquery name="get_sales_temp" dbtype="query">
            	SELECT
                	SUM(COST_) COST_,
                	SUM(PURCHASE_) PURCHASE_,
                	SUM(NETTOTAL_) NETTOTAL_,
                    SUM(QUANTITY_) QUANTITY_,
                    PRODUCT_CATID_,
            		PRODUCT_CAT_,
                    TYPE_
             	FROM
                	get_sales_temp
              	GROUP BY
                	PRODUCT_CATID_,
            		PRODUCT_CAT_,
                    TYPE_
        </cfquery>
        <cfset all_sales_cat_id_list = ValueList(get_sales_temp.PRODUCT_CATID_)>
        <cfif get_sales_temp.recordcount>
           	<cfoutput query="get_sales_temp">
            	<cfset 'COST_#PRODUCT_CATID_#' = COST_>
            	<cfset 'PURCHASE_#PRODUCT_CATID_#' = PURCHASE_>
            	<cfset 'NETTOTAL_#PRODUCT_CATID_#' = NETTOTAL_>
                <cfset 'QUANTITY_#PRODUCT_CATID_#' = QUANTITY_>
            </cfoutput>
        </cfif>
       	<cfset hedef_cat_id_list = ''> 
        
        <cfoutput query="GET_HEDEF_sales"><!---hEDEFLERE sATIŞLAR MONTE EDİLİYOR--->
        	<cfquery name="get_cat" datasource="#dsn1#">
            	SELECT     
                	PRODUCT_CATID
				FROM        
                	PRODUCT_CAT
				WHERE     
                	HIERARCHY LIKE '#HIERARCHY#%'
            </cfquery>
            
			<cfset temp = QueryAddRow(get_sales)>
          	<cfset Temp = QuerySetCell(get_sales, "TYPE", 1)>
           	<cfset Temp = QuerySetCell(get_sales, "PRODUCT_CATID", CATEGORY_ID)>
         	<cfset Temp = QuerySetCell(get_sales, "PRODUCT_CAT", PRODUCT_CAT)>
          	<cfset Temp = QuerySetCell(get_sales, "H_NETTOTAL", TOTAL)> 
          	<cfset Temp = QuerySetCell(get_sales, "H_QUANTITY", QUANTITY)>
           	<cfset sub_cost = 0>
            <cfset sub_purchase = 0>
            <cfset sub_sales = 0>
            <cfset sub_quantity = 0> 
            <cfloop query="get_cat"> <!---Üst Kategori Hedefler için Alt Kategori Satışları Birleştiriryoruz--->
            	<cfset hedef_cat_id_list = ListAppend(hedef_cat_id_list,PRODUCT_CATID)>
            	<cfif isdefined('COST_#PRODUCT_CATID#')> 
					<cfset sub_cost = sub_cost + Evaluate('COST_#PRODUCT_CATID#')> 
                </cfif>
                <cfif isdefined('PURCHASE_#PRODUCT_CATID#')> 
					<cfset sub_purchase = sub_purchase + Evaluate('PURCHASE_#PRODUCT_CATID#')> 
                </cfif>
                <cfif isdefined('NETTOTAL_#PRODUCT_CATID#')> 
					<cfset sub_sales = sub_sales + Evaluate('NETTOTAL_#PRODUCT_CATID#')> 
                </cfif>
                <cfif isdefined('QUANTITY_#PRODUCT_CATID#')> 
					<cfset sub_quantity = sub_quantity + Evaluate('QUANTITY_#PRODUCT_CATID#')> 
                </cfif>
            </cfloop>
          	<cfset Temp = QuerySetCell(get_sales, "COSTTOTAL",sub_cost)> 
          	<cfset Temp = QuerySetCell(get_sales, "PURCHASETOTAL",sub_purchase)> 
         	<cfset Temp = QuerySetCell(get_sales, "NETTOTAL",sub_sales)> 
         	<cfset Temp = QuerySetCell(get_sales, "QUANTITY",sub_quantity)> 
      	</cfoutput>
        <cfoutput query="get_sales_gelir"><!---gELİRLER le Satışlar Birleştiriliyor--->
        	<cfset temp = QueryAddRow(get_sales)>
          	<cfset Temp = QuerySetCell(get_sales, "TYPE", 2)>
           	<cfset Temp = QuerySetCell(get_sales, "PRODUCT_CATID", get_sales_gelir.PRODUCT_CATID)>
         	<cfset Temp = QuerySetCell(get_sales, "PRODUCT_CAT", get_sales_gelir.PRODUCT_CAT)>
          	<cfset Temp = QuerySetCell(get_sales, "H_NETTOTAL", 0)> 
          	<cfset Temp = QuerySetCell(get_sales, "H_QUANTITY", 0)>
            <cfset Temp = QuerySetCell(get_sales, "COSTTOTAL", 0)> 
            <cfset Temp = QuerySetCell(get_sales, "PURCHASETOTAL", 0)>
            <cfset Temp = QuerySetCell(get_sales, "NETTOTAL", get_sales_gelir.NETTOTAL)>
          	<cfset Temp = QuerySetCell(get_sales, "QUANTITY", get_sales_gelir.QUANTITY)>
        </cfoutput>
        <cfset hedef_cat_id_list = ListSort(ListDeleteDuplicates(hedef_cat_id_list,','),"Numeric","asc")>
        <cfset all_sales_cat_id_list = ListSort(ListDeleteDuplicates(all_sales_cat_id_list,','),"Numeric","asc")>
		<cfloop list="#all_sales_cat_id_list#" index="j"> <!---Hedef Konmayan Satışlar Birleştiriliyor--->
        	<cfif not ListFind(hedef_cat_id_list,j)>
            	<cfquery name="get_cat_" dbtype="query">
                        SELECT  
                        	PRODUCT_CAT_,   
                            PRODUCT_CATID_,
                            COST_,
                            PURCHASE_,
                            NETTOTAL_,
                            QUANTITY_
                        FROM        
                            get_sales_temp
                        WHERE     
                            PRODUCT_CATID_ = #j#
            	</cfquery>
				<cfset temp = QueryAddRow(get_sales)>
            	<cfset Temp = QuerySetCell(get_sales, "TYPE", 3)>
             	<cfset Temp = QuerySetCell(get_sales, "PRODUCT_CATID", get_cat_.PRODUCT_CATID_)>
             	<cfset Temp = QuerySetCell(get_sales, "PRODUCT_CAT", get_cat_.PRODUCT_CAT_)>
             	<cfset Temp = QuerySetCell(get_sales, "H_NETTOTAL", 0)> 
              	<cfset Temp = QuerySetCell(get_sales, "H_QUANTITY", 0)>
              	<cfset Temp = QuerySetCell(get_sales, "COSTTOTAL", get_cat_.COST_)> 
              	<cfset Temp = QuerySetCell(get_sales, "PURCHASETOTAL", get_cat_.PURCHASE_)>
               	<cfset Temp = QuerySetCell(get_sales, "NETTOTAL", get_cat_.NETTOTAL_)>
             	<cfset Temp = QuerySetCell(get_sales, "QUANTITY", get_cat_.QUANTITY_)>
    		</cfif>
        </cfloop>
    </cfif>
</cfif>
<cfif get_sales.recordcount neq 0>
    <cfquery name="get_sales_TOTAL" dbtype="query">
        SELECT 
            SUM(COSTTOTAL) AS COSTTOTAL, 
            SUM(PURCHASETOTAL) AS PURCHASETOTAL, 
            SUM(NETTOTAL) AS NETTOTAL, 
            SUM(QUANTITY) AS QUANTITY, 
            SUM(H_NETTOTAL) AS H_NETTOTAL, 
            SUM(H_QUANTITY) AS H_QUANTITY 
        FROM 
            get_sales
    </cfquery>
    <cfif len(get_sales_TOTAL.COSTTOTAL)>
        <cfset cost_total = get_sales_TOTAL.COSTTOTAL>
    <cfelse>
        <cfset cost_total = 0>
    </cfif>
    <cfif len(get_sales_TOTAL.PURCHASETOTAL)>
        <cfset purchase_total = get_sales_TOTAL.PURCHASETOTAL>
    <cfelse>
        <cfset purchase_total = 0>
    </cfif>
    <cfif len(get_sales_TOTAL.NETTOTAL)>
        <cfset satis_total = get_sales_TOTAL.NETTOTAL>
    <cfelse>
        <cfset satis_total = 0>
    </cfif>
    <cfif len(get_sales_TOTAL.H_NETTOTAL)>
        <cfset hedef_total = get_sales_TOTAL.H_NETTOTAL>
    <cfelse>
        <cfset hedef_total = 0>
    </cfif>
    <cfif len(get_sales_TOTAL.QUANTITY)>
        <cfset satis_quantity = get_sales_TOTAL.QUANTITY>
    <cfelse>
        <cfset satis_quantity = 0>
    </cfif>
    <cfif len(get_sales_TOTAL.H_QUANTITY)>
        <cfset hedef_quantity = get_sales_TOTAL.H_QUANTITY>
    <cfelse>
        <cfset hedef_quantity = 0>
    </cfif>
</cfif>
