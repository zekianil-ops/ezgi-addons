
<cfquery name="PRODUCTS" datasource="#DSN3#">
        SELECT
            PRODUCT.COMPANY_ID,
            PRODUCT.PRODUCT_ID,
            PRODUCT.PRODUCT_CODE,
            PRODUCT.PRODUCT_CODE_2,
            PRODUCT.PRODUCT_NAME,
            PRODUCT.MANUFACT_CODE,
            PRODUCT.TAX,
            PRODUCT.TAX_PURCHASE,
            PRODUCT.PRODUCT_CATID,
            PRODUCT.IS_SERIAL_NO,
            PRODUCT.PRODUCT_DETAIL2,
          	<cfif isdefined("attributes.price_catid") and attributes.price_catid gt 0>
            	ISNULL((SELECT SALES_PRICE FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PRICE_CAT_ID = #attributes.price_catid# AND STOCK_ID = STOCKS.STOCK_ID),0) AS PRICE,
                (SELECT SALES_PRICE_MONEY FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PRICE_CAT_ID = #attributes.price_catid# AND STOCK_ID = STOCKS.STOCK_ID) AS MONEY,
                ISNULL((SELECT PURCHASE_PRICE FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PRICE_CAT_ID = #attributes.price_catid# AND STOCK_ID = STOCKS.STOCK_ID),0) AS PURCHASE_PRICE,
                (SELECT PURCHASE_PRICE_MONEY FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PRICE_CAT_ID = #attributes.price_catid# AND STOCK_ID = STOCKS.STOCK_ID) AS PURCHASE_PRICE_MONEY,
                ISNULL((SELECT COST_PRICE FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PRICE_CAT_ID = #attributes.price_catid# AND STOCK_ID = STOCKS.STOCK_ID),0) AS COST_PRICE,
                (SELECT COST_PRICE_MONEY FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PRICE_CAT_ID = #attributes.price_catid# AND STOCK_ID = STOCKS.STOCK_ID) AS COST_PRICE_MONEY,
        	<CFELSE>
            	0 AS PRICE,
                '#session.ep.money#' AS MONEY,
                0 AS PURCHASE_PRICE,
                '#session.ep.money#' AS PURCHASE_PRICE_MONEY,
                0 AS COST_PRICE,
                '#session.ep.money#' AS COST_PRICE_MONEY,
            </cfif>			
            PRODUCT_UNIT.ADD_UNIT,
            PRODUCT_UNIT.PRODUCT_UNIT_ID,
            PRODUCT_UNIT.MAIN_UNIT,
            PRODUCT_UNIT.MULTIPLIER,
            STOCKS.STOCK_ID,
            STOCKS.PROPERTY,
            STOCKS.STOCK_CODE,
            STOCKS.BARCOD,
            STOCKS.IS_PRODUCTION,
            (SELECT SP.SPECT_MAIN_ID FROM SPECT_MAIN SP WHERE SP.STOCK_ID = STOCKS.STOCK_ID AND SP.SPECT_MAIN_ID = (SELECT MAX(SMM.SPECT_MAIN_ID) FROM SPECT_MAIN SMM WHERE SMM.STOCK_ID = STOCKS.STOCK_ID AND SMM.IS_TREE = 1)) SPECT_MAIN_ID,
            (SELECT SP.SPECT_MAIN_NAME FROM SPECT_MAIN SP WHERE SP.STOCK_ID = STOCKS.STOCK_ID AND SP.SPECT_MAIN_ID = (SELECT MAX(SMM.SPECT_MAIN_ID) FROM SPECT_MAIN SMM WHERE SMM.STOCK_ID = STOCKS.STOCK_ID AND SMM.IS_TREE = 1)) SPECT_MAIN_NAME
        FROM
            PRODUCT,
            PRODUCT_CAT,
            PRODUCT_UNIT,
            STOCKS
        WHERE
            PRODUCT.PRODUCT_STATUS = 1 AND 	
            STOCKS.PRODUCT_ID = PRODUCT.PRODUCT_ID AND
            PRODUCT_UNIT.PRODUCT_ID = PRODUCT.PRODUCT_ID AND 
            PRODUCT_UNIT.PRODUCT_UNIT_STATUS = 1 AND 
            PRODUCT_CAT.PRODUCT_CATID = PRODUCT.PRODUCT_CATID AND 
            PRODUCT_UNIT.IS_MAIN = 1
            <!---<cfif isDefined("attributes.product_cat") and len(attributes.product_cat)>
                AND PRODUCT.PRODUCT_CODE LIKE '#attributes.product_cat#.%'
            </cfif>--->
        <cfif isDefined("attributes.product_cat_code") and len(attributes.product_cat_code)>
            AND PRODUCT.PRODUCT_CODE LIKE '#attributes.product_cat_code#.%'
        </cfif>
        <cfif len(attributes.product_cat) and len(attributes.product_catid)>
            AND STOCKS.PRODUCT_CODE LIKE (SELECT HIERARCHY FROM PRODUCT_CAT WHERE PRODUCT_CATID=#attributes.product_catid#)+'.%' <!---kategori hiyerarşisine gore arama yapıyor --->
        </cfif>
        <cfif isDefined("attributes.product_id") and len(attributes.product_id)>
            AND PRODUCT.PRODUCT_ID = #attributes.product_id#
        </cfif>
        <cfif isDefined("attributes.keyword") and len(attributes.keyword)>
            AND 
            (
            <cfif len(attributes.keyword) eq 1 >
                PRODUCT.PRODUCT_NAME LIKE '#attributes.keyword#%' 
            <cfelseif len(attributes.keyword) gt 1>
                <cfif listlen(attributes.keyword,"+") gt 1>
                    (
                        <cfloop from="1" to="#listlen(attributes.keyword,'+')#" index="pro_index">
                            PRODUCT.PRODUCT_NAME LIKE '%#ListGetAt(attributes.keyword,pro_index,"+")#%' 
                            <cfif pro_index neq listlen(attributes.keyword,'+')>AND</cfif>
                        </cfloop>
                    )		
                <cfelse>
                    PRODUCT.PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
                    PRODUCT.PRODUCT_CODE LIKE '<cfif len(attributes.keyword) gt 1>%</cfif>#attributes.keyword#%' OR
                    PRODUCT.BARCOD='#attributes.keyword#' OR 
                    PRODUCT.MANUFACT_CODE LIKE '<cfif len(attributes.keyword) gt 1>%</cfif>#attributes.keyword#%' 
                </cfif>
            </cfif>		
            ) 
        </cfif>
        <cfif len(attributes.employee_id) and isdefined("attributes.employee") and len(attributes.employee)>
            AND PRODUCT.PRODUCT_MANAGER = #attributes.employee_id#
        </cfif>
        <cfif len(attributes.search_company_id) and isdefined("attributes.search_company") and len(attributes.search_company)>
            AND PRODUCT.COMPANY_ID = #attributes.search_company_id#
        </cfif>
        <cfif attributes.list_type eq 1>
        	AND STOCKS.IS_SALES =1
        </cfif>
        <cfif isdefined("attributes.price_catid") and attributes.price_catid gt 0>
        	AND STOCKS.STOCK_ID IN (SELECT STOCK_ID FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PRICE_CAT_ID = #attributes.price_catid#)
        </cfif>
        ORDER BY
            PRODUCT.PRODUCT_NAME
    </cfquery>
