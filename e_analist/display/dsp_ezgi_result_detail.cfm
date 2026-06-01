<cfsetting showdebugoutput="yes">
<cfquery name="get_upd" datasource="#dsn3#">
	SELECT        
    	A.YEAR_VALUE, 
        A.MONTH_VALUE, 
        ISNULL(B.RATE,0) RATE
	FROM            
    	EZGI_ANALYST_BRANCH AS A INNER JOIN
     	EZGI_ANALYST_BRANCH AS B ON A.YEAR_VALUE = B.YEAR_VALUE AND A.MONTH_VALUE = B.MONTH_VALUE
	WHERE        
    	A.ANALYST_BRANCH_ID = #attributes.upd_id# AND B.BRANCH_ID=#attributes.branch_id#
</cfquery>
<cfif len(get_upd.rate)>
	<cfset rate = get_upd.rate>
<cfelse>
	<cfset rate = 0>
</cfif>
<cfquery name="GET_INVOICE" datasource="#DSN#">
       	SELECT
        	SUM((AMOUNT*LIST_PRICE)-(AMOUNT*LIST_PRICE*#rate#/100)) AS NETTOTAL,
            PRODUCT_CATID,
            PRODUCT_CAT,
            1 AS TYPE
      	FROM 
        	(
            SELECT 
                AMOUNT,
                LIST_PRICE, 
                (
                    SELECT        
                        PC.PRODUCT_CAT
                    FROM            
                        #dsn1_alias#.PRODUCT AS P INNER JOIN
                        #dsn1_alias#.PRODUCT_CAT AS PC ON P.PRODUCT_CATID = PC.PRODUCT_CATID
                    WHERE        
                        P.PRODUCT_ID = INV_TOTAL.PRODUCT_ID
                ) AS PRODUCT_CAT,
                (
                    SELECT        
                        PRODUCT_CATID
                    FROM            
                        #dsn1_alias#.PRODUCT AS P
                    WHERE        
                        PRODUCT_ID = INV_TOTAL.PRODUCT_ID
                ) AS PRODUCT_CATID,
                1 AS TYPE
            FROM
                (
                SELECT
                	IR.INVOICE_ID,	
                    IR.STOCK_ID,
                    IR.PRODUCT_ID,
                    IR.AMOUNT,
                    IR.LIST_PRICE 
                FROM
                    #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.INVOICE I,
                    #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.INVOICE_ROW IR
                WHERE
                    I.INVOICE_ID=IR.INVOICE_ID
                    AND I.INVOICE_CAT IN (48,50,52,53,531,56,58,62,561)
                    AND I.IS_IPTAL=0
                    AND YEAR(I.INVOICE_DATE) = #get_upd.YEAR_VALUE# 
                    AND MONTH(I.INVOICE_DATE) = #get_upd.MONTH_VALUE#
                    AND I.DEPARTMENT_ID IN
                                        (
                                            SELECT        
                                                DEPARTMENT_ID
                                            FROM            
                                                #dsn_alias#.DEPARTMENT
                                            WHERE        
                                                BRANCH_ID = #attributes.BRANCH_ID#
                                        )
                UNION ALL		
                SELECT	
                	IR.INVOICE_ID,
                    IR.STOCK_ID,
                    IR.PRODUCT_ID,
                    IR.AMOUNT,
                    IR.LIST_PRICE
                FROM
                    #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.INVOICE I,
                    #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.INVOICE_ROW IR
                WHERE
                    I.INVOICE_ID=IR.INVOICE_ID
                    AND I.INVOICE_CAT IN (51,54,55,63)
                    AND I.IS_IPTAL=0
                    AND YEAR(I.INVOICE_DATE) = #get_upd.YEAR_VALUE# 
                    AND MONTH(I.INVOICE_DATE) = #get_upd.MONTH_VALUE#
                    AND I.DEPARTMENT_ID IN
                                        (
                                            SELECT        
                                                DEPARTMENT_ID
                                            FROM            
                                                #dsn_alias#.DEPARTMENT
                                            WHERE        
                                                BRANCH_ID = #attributes.BRANCH_ID#
                                        )
                ) AS INV_TOTAL,
                #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.INVOICE_MONEY INV_M,
                #dsn_alias#.SETUP_PERIOD STP
            WHERE
                INV_M.ACTION_ID=INV_TOTAL.INVOICE_ID
                AND STP.PERIOD_ID = #session.ep.period_id# 
                AND INV_M.MONEY_TYPE = ISNULL(STP.OTHER_MONEY,'TL')
       		) AS IRD_TOTAL
       	GROUP BY
        	PRODUCT_CATID,
            PRODUCT_CAT	
        UNION ALL
        SELECT    
            SUM(EIE.AMOUNT) AS NETTOTAL,
            EIC.EXPENSE_CAT_ID AS PRODUCT_CATID,
            EIC.EXPENSE_CAT_NAME AS PRODUCT_CAT, 
            2 AS TYPE
        FROM            
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEMS_ROWS AS EIE INNER JOIN
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEMS AS EI ON EIE.EXPENSE_ITEM_ID = EI.EXPENSE_ITEM_ID INNER JOIN
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_CATEGORY AS EIC ON EI.EXPENSE_CATEGORY_ID = EIC.EXPENSE_CAT_ID INNER JOIN
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEM_PLANS AS EIP ON EIE.EXPENSE_ID = EIP.EXPENSE_ID
        WHERE        
            EIE.EXPENSE_ID IN
                            (
                                SELECT        
                                    EXPENSE_ID
                                FROM            
                                    #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEM_PLANS AS EXPENSE_ITEM_PLANS_1
                                WHERE        
                                    BRANCH_ID = #attributes.BRANCH_ID# AND 
                                    MONTH(EXPENSE_DATE) = #get_upd.MONTH_VALUE# AND 
                                    YEAR(EXPENSE_DATE) = #get_upd.YEAR_VALUE#
                            ) AND 
            EI.IS_EXPENSE = 0
     	GROUP BY
        	EIC.EXPENSE_CAT_NAME,
            EIC.EXPENSE_CAT_ID 
    	ORDER BY
        	TYPE
        	
</cfquery>
<cf_seperator title="#getLang('report',27)#" id="sarf_">
<div id="sarf_" style="display:none; width:100%">
    <cf_form_list id="table2">
        <thead>
            <tr style="height:30px">
                <th width="20px" style="text-align:center"><cf_get_lang_main no='1165.Sıra'></th>
                <th style="text-align:left; width:400px"><cf_get_lang_main no='74.Kategori'></th>
                <th width="105px" style="text-align:center"><cf_get_lang_main no='261.Tutar'></th>
            </tr>
        </thead>
        <tbody>
			<cfoutput query="GET_INVOICE">
                <tr id="frm_row_exit#currentrow#">
                    <td style="text-align:right;cursor:">#currentrow#</td>
                    <td>#PRODUCT_CAT#</td>
                    <td style="text-align:right;">#TlFormat(NETTOTAL,2)#</td>
                </tr>
            </cfoutput>
       </tbody>
    </cf_form_list>
</div>
