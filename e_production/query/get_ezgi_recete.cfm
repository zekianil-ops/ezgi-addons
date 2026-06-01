<!---
    File: get_ezgi_recete.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_product_tree" datasource="#dsn3#">
    SELECT        
        ST.PRODUCT_ID, 
        ST.STOCK_ID, 
        ST.PRODUCT_NAME, 
        ST.PRODUCT_CODE, 
        ST.PRODUCT_CODE_2, 
        E.IS_PRODUCTION, 
        E.IS_TREE,
        E.STOCK_ID2, 
        E.STOCK_CODE, 
        E.PRODUCT_NAME AS TREE_NAME, 
        SUM(E.AMOUNT * E.AMOUNT2 * E.AMOUNT3 * E.AMOUNT4 * E.AMOUNT5) AS AMOUNT
	FROM            
        EZGI_PRODUCT_TREE_BOM1 AS E WITH (NOLOCK) INNER JOIN
    	STOCKS AS ST WITH (NOLOCK) ON E.STOCK_ID = ST.STOCK_ID
 	WHERE
        ISNULL(ST.IS_KARMA,0) = 0 AND
        <cfif isdefined('attributes.product_status')>
        	<cfif attributes.product_status eq 0>
            	ISNULL(ST.PRODUCT_STATUS,0) = 0 AND
            <cfelseif attributes.product_status eq 1>
            	ISNULL(ST.PRODUCT_STATUS,0) = 1 AND
            </cfif>
        <cfelse>
      		ISNULL(ST.PRODUCT_STATUS,0) = 1 AND
        </cfif>
  		(E.STOCK_CODE LIKE '01.150.%' OR E.STOCK_CODE LIKE '02.%') 
    	<cfif len(attributes.keyword)>
        	AND (ST.PRODUCT_NAME LIKE '#attributes.keyword#%' OR ST.PRODUCT_CODE LIKE '#attributes.keyword#%' OR ST.PRODUCT_CODE_2 LIKE '#attributes.keyword#%')
   		</cfif>
      	<cfif len(attributes.category_name)>
            AND ST.PRODUCT_CODE LIKE '#attributes.cat#%'
    	</cfif>
	GROUP BY 
        ST.PRODUCT_ID, 
        ST.STOCK_ID,
        ST.PRODUCT_NAME, 
        ST.PRODUCT_CODE, 
        ST.PRODUCT_CODE_2, 
        E.STOCK_ID2,
    	E.STOCK_CODE, 
    	E.PRODUCT_NAME, 
     	E.IS_PRODUCTION, 
    	E.IS_TREE
 	UNION ALL
 	SELECT        
        ST.PRODUCT_ID, 
        ST.STOCK_ID, 
        ST.PRODUCT_NAME, 
        ST.PRODUCT_CODE, 
        ST.PRODUCT_CODE_2, 
        E.IS_PRODUCTION, 
        E.IS_TREE,
        E.STOCK_ID2, 
        E.STOCK_CODE, 
        E.PRODUCT_NAME AS TREE_NAME, 
        SUM(KP.PRODUCT_AMOUNT * E.AMOUNT * E.AMOUNT2 * E.AMOUNT3 * E.AMOUNT4 * E.AMOUNT5) AS AMOUNT
	FROM            
        #dsn1_alias#.KARMA_PRODUCTS AS KP WITH (NOLOCK) INNER JOIN
      	STOCKS AS ST WITH (NOLOCK) ON KP.KARMA_PRODUCT_ID = ST.PRODUCT_ID INNER JOIN
        EZGI_PRODUCT_TREE_BOM1 AS E WITH (NOLOCK) ON KP.STOCK_ID = E.STOCK_ID
 	WHERE
        ISNULL(ST.IS_KARMA,0) = 1 AND
      	<cfif isdefined('attributes.product_status')>
        	<cfif attributes.product_status eq 0>
            	ISNULL(ST.PRODUCT_STATUS,0) = 0 AND
            <cfelseif attributes.product_status eq 1>
            	ISNULL(ST.PRODUCT_STATUS,0) = 1 AND
            </cfif>
        <cfelse>
      		ISNULL(ST.PRODUCT_STATUS,0) = 1 AND
        </cfif>
     	(E.STOCK_CODE LIKE '01.150.%' OR E.STOCK_CODE LIKE '02.%') 
   		<cfif len(attributes.keyword)>
        	AND (ST.PRODUCT_NAME LIKE '#attributes.keyword#%' OR ST.PRODUCT_CODE LIKE '#attributes.keyword#%' OR ST.PRODUCT_CODE_2 LIKE '#attributes.keyword#%')
      	</cfif>
      	<cfif len(attributes.category_name)>
            AND ST.PRODUCT_CODE LIKE '#attributes.cat#%'
     	</cfif>
	GROUP BY 
   		ST.PRODUCT_ID, 
        ST.STOCK_ID,
        ST.PRODUCT_NAME, 
        ST.PRODUCT_CODE, 
        ST.PRODUCT_CODE_2, 
        E.STOCK_ID2,
     	E.STOCK_CODE, 
      	E.PRODUCT_NAME, 
     	E.IS_PRODUCTION, 
    	E.IS_TREE
</cfquery>
<cfquery name="get_product" dbtype="query">
 	SELECT
   		STOCK_ID,
    	PRODUCT_ID,
     	PRODUCT_CODE, 
      	PRODUCT_NAME	
  	FROM
     	get_product_tree
  	GROUP BY
    	STOCK_ID,
     	PRODUCT_ID,
    	PRODUCT_CODE, 
     	PRODUCT_NAME	
 	<cfif len(attributes.sort_type)>
     	ORDER BY
   		<cfif attributes.sort_type eq 0>	
         	PRODUCT_NAME
     	<cfelseif attributes.sort_type eq 1>
         	PRODUCT_NAME desc
      	<cfelseif attributes.sort_type eq 2>
        	PRODUCT_CODE
    	<cfelseif attributes.sort_type eq 3>
         	PRODUCT_CODE desc
      	</cfif>
	</cfif>
</cfquery>      
<cfquery name="get_recete_1" dbtype="query">
  	SELECT
     	STOCK_ID2 STOCK_ID,
     	STOCK_CODE PRODUCT_CODE, 
      	TREE_NAME PRODUCT_NAME	
  	FROM
    	get_product_tree
	GROUP BY
    	STOCK_ID2,
     	STOCK_CODE, 
    	TREE_NAME	
</cfquery>
<cfset stock_id_list= ValueList(get_recete_1.STOCK_ID, "," )>
<cfif ListLen(stock_id_list)>
 	<cfquery name="get_recete_stock_id" datasource="#dsn1#">
    	SELECT   	
        	PU.MAIN_UNIT, 
         	S.STOCK_ID,
         	ISNULL((
                        SELECT     
                            PRICE
                        FROM          
                            PRICE_STANDART WITH (NOLOCK)
                        WHERE      
                            (PRODUCT_ID = S.PRODUCT_ID) AND 
                            (PRICESTANDART_STATUS = 1) AND 
                            (PURCHASESALES = 0)
          	),0) AS STANDART_ALIS,
         	(
                        SELECT     
                            MONEY
                        FROM          
                            PRICE_STANDART AS PRICE_STANDART_1 WITH (NOLOCK)
                        WHERE      
                            (PRODUCT_ID = S.PRODUCT_ID) AND (PRICESTANDART_STATUS = 1) AND (PURCHASESALES = 0)
        	) AS STANDART_ALIS_MONEY,
         	ISNULL((
                        SELECT     
                            TOP (1) IR.PRICE_OTHER
                        FROM          
                            #dsn2_alias#.INVOICE AS I WITH (NOLOCK) INNER JOIN
                            #dsn2_alias#.INVOICE_ROW AS IR WITH (NOLOCK) ON I.INVOICE_ID = IR.INVOICE_ID
                        WHERE      
                            ((I.INVOICE_CAT = 59) AND (IR.STOCK_ID = S.STOCK_ID)) OR
                            ((I.INVOICE_CAT = 591) AND (IR.STOCK_ID = S.STOCK_ID))
                        ORDER BY 
                            I.INVOICE_DATE DESC
         	),0) AS SON_ALIS,
          	(
                        SELECT     
                            TOP (1) IR.OTHER_MONEY
                        FROM          
                            #dsn2_alias#.INVOICE AS I WITH (NOLOCK) INNER JOIN
                            #dsn2_alias#.INVOICE_ROW AS IR WITH (NOLOCK) ON I.INVOICE_ID = IR.INVOICE_ID
                        WHERE      
                            ((I.INVOICE_CAT = 59) AND (IR.STOCK_ID = S.STOCK_ID)) OR
                            ((I.INVOICE_CAT = 591) AND (IR.STOCK_ID = S.STOCK_ID))
                        ORDER BY 
                            I.INVOICE_DATE DESC
        	) AS SON_ALIS_MONEY
    	FROM     	
        	#dsn3_alias#.STOCKS AS S WITH (NOLOCK) INNER JOIN
          	PRODUCT_UNIT AS PU WITH (NOLOCK) ON S.PRODUCT_ID = PU.PRODUCT_ID
    	WHERE     	
         	PU.PRODUCT_UNIT_STATUS = 1 AND 
      		PU.IS_MAIN = 1 AND 
         	S.STOCK_ID IN (#stock_id_list#)
    	ORDER BY 	
         	S.PRODUCT_NAME
 	</cfquery>
  	<cfoutput query="get_recete_stock_id">
    	<cfset 'MAIN_UNIT_#STOCK_ID#'=MAIN_UNIT>
      	<cfset 'fiyat1_#STOCK_ID#'=STANDART_ALIS>
     	<cfset 'money1_#STOCK_ID#'=STANDART_ALIS_MONEY> 
     	<cfset 'fiyat3_#STOCK_ID#'=SON_ALIS>
    	<cfset 'money3_#STOCK_ID#'=SON_ALIS_MONEY>
  	</cfoutput>
</cfif>