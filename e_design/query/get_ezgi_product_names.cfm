<!---
    File: get_ezgi_product_names.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfquery name="PRODUCT_NAMES" datasource="#DSN3#">
	WITH CTE1 AS   
    (
    	SELECT 	DISTINCT
			STOCKS.TAX_PURCHASE,
			STOCKS.OTV,
			STOCKS.TAX,
			STOCKS.IS_PRODUCTION,
			STOCKS.STOCK_ID,
			STOCKS.PRODUCT_ID,
			STOCKS.PROPERTY,
			STOCKS.STOCK_CODE,
			STOCKS.STOCK_CODE_2,
			STOCKS.PRODUCT_UNIT_ID,
			STOCKS.PRODUCT_NAME,
			STOCKS.COMPANY_ID,
			STOCKS.IS_SERIAL_NO,
			STOCKS.BARCOD,
			STOCKS.IS_INVENTORY,
			STOCKS.PRODUCT_CODE,
			STOCKS.PRODUCT_CODE_2,
			PRODUCT_UNIT.MAIN_UNIT,
			PRODUCT_UNIT.MAIN_UNIT_ID,
			PRODUCT_CAT.PROFIT_MARGIN,
            PRODUCT_CAT.PRODUCT_CATID,
            PRODUCT_CAT.PRODUCT_CAT,
            PRODUCT_CAT.HIERARCHY
			<cfif isdefined("attributes.is_only_alternative") and isdefined("attributes.alternative_product") and len(attributes.alternative_product)>
				,ISNULL((SELECT TOP 1 ALTERNATIVE_PRODUCT_AMOUNT FROM ALTERNATIVE_PRODUCTS WHERE ALTERNATIVE_PRODUCTS.STOCK_ID = STOCKS.STOCK_ID  AND PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.alternative_product#">
				<cfif isdefined('attributes.tree_stock_id')> AND TREE_STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.tree_stock_id#"><cfelseif isdefined('attributes.tree_info_null_') and tree_info_null_ eq 1>AND TREE_STOCK_ID IS NULL</cfif>),1) AMOUNT
			<cfelse>
				,1 AMOUNT
			</cfif><!--- sadece alternatif ürünleri gelmesi için --->
           <cfif isdefined('attributes.field_product_cost')>
           		,ISNULL((P_COST.PURCHASE_EXTRA_COST_SYSTEM +  P_COST.PURCHASE_NET_SYSTEM),0) AS PRODUCT_COST
           </cfif>
            
		FROM
			PRODUCT_CAT WITH (NOLOCK),
			STOCKS WITH (NOLOCK)
            <cfif isdefined('attributes.field_product_cost')>
                OUTER APPLY
                (
                    SELECT  TOP 1 
                        PRODUCT_ID,
                        PURCHASE_NET_SYSTEM,
                        PURCHASE_EXTRA_COST_SYSTEM,
                        START_DATE,
                        RECORD_DATE
                    FROM
                        #dsn1_alias#.PRODUCT_COST WITH (NOLOCK)
                    WHERE 
                        PRODUCT_ID = STOCKS.PRODUCT_ID  
                        <cfif isdefined('attributes.expense_date') and isdate(attributes.expense_date)>AND START_DATE <= #attributes.expense_date#</cfif> 
                    ORDER BY START_DATE DESC,RECORD_DATE DESC			
                ) AS P_COST
            </cfif>
			<cfif isDefined("attributes.keyword") and len(attributes.keyword)>
            	LEFT JOIN #dsn1_alias#.SETUP_COMPANY_STOCK_CODE WITH (NOLOCK) ON SETUP_COMPANY_STOCK_CODE.STOCK_ID = STOCKS.STOCK_ID AND (COMPANY_STOCK_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> OR COMPANY_PRODUCT_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">)
			</cfif>
            ,PRODUCT_UNIT WITH (NOLOCK)
          
		  <cfif isDefined("attributes.barcod")  and len(attributes.barcod)>	 	
			,STOCKS_BARCODES WITH (NOLOCK)
		  </cfif>
		WHERE
			STOCKS.PRODUCT_STATUS = 1 AND
			STOCKS.STOCK_STATUS = 1 AND
			STOCKS.PRODUCT_CATID = PRODUCT_CAT.PRODUCT_CATID AND
			PRODUCT_UNIT.PRODUCT_ID = STOCKS.PRODUCT_ID AND
			PRODUCT_UNIT.IS_MAIN = 1
      	<cfif isdefined('attributes.list_order_no') and listlen(attributes.list_order_no)>
        	AND PRODUCT_CAT.LIST_ORDER_NO IN (#attributes.list_order_no#)
     	</cfif>
		<cfif isdefined('attributes.master') and attributes.master eq 1>
         	AND STOCKS.SHORT_CODE_ID = (SELECT TOP (1) DEFAULT_MASTER_SHORT_CODE_ID FROM EZGI_DESIGN_DEFAULTS)
     	</cfif>
        <cfif isdefined('attributes.eleme') and attributes.eleme eq 1>
        	AND STOCKS.STOCK_ID NOT IN (
            							SELECT        
                                        	STOCK_ID
										FROM            
                                        	EZGI_DESIGN_PRODUCT_PROPERTIES_UST
                                     	WHERE      
                                        	STOCK_ID IS NOT NULL
                                     	) 
     	</cfif>
		<cfif isdefined("attributes.from_promotion")>
			AND STOCKS.IS_SALES = 1
		</cfif>
		<cfif isdefined("attributes.is_hizmet") and (attributes.is_hizmet eq 1)>
			AND STOCKS.IS_INVENTORY = 0
		</cfif>	
		<cfif len(attributes.product_cat_code)>
			AND STOCKS.STOCK_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#PRODUCT_CAT_CODE#%">
		</cfif>
		<cfif isDefined("attributes.keyword") and len(attributes.keyword)and attributes.filter_type neq 1>
			AND
			(
			<cfif listlen(attributes.keyword,"+") gt 1 >
				(
					<cfloop from="1" to="#listlen(attributes.keyword,'+')#" index="pro_index">
						STOCKS.PRODUCT_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ListGetAt(attributes.keyword,pro_index,"+")#%">
						<cfif pro_index neq listlen(attributes.keyword,'+')>AND</cfif>
					</cfloop>
				)	
			<cfelse>
				STOCKS.PRODUCT_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">
			</cfif>
				OR STOCKS.STOCK_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">
				OR STOCKS.STOCK_CODE_2 LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">
				OR STOCKS.MANUFACT_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">
				OR STOCKS.PRODUCT_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">
			)
		</cfif>
		<cfif isDefined("attributes.barcod")  and len(attributes.barcod) >
    		AND STOCKS_BARCODES.STOCK_ID = STOCKS.STOCK_ID
			AND STOCKS.BARCOD LIKE ('%#attributes.barcod#%')
		</cfif>
		<cfif isDefined("attributes.special_code") and len(attributes.special_code)>
			AND STOCKS.STOCK_CODE_2 LIKE '<cfif len(attributes.special_code) gt 3>%</cfif>#attributes.special_code#%'
		</cfif>
		<cfif isdefined("attributes.is_only_alternative") and isdefined("attributes.alternative_product") and len(attributes.alternative_product)><!--- sadece alternatif ürünleri gelmesi için --->
			AND
			(
				STOCKS.PRODUCT_ID IN (SELECT ALTERNATIVE_PRODUCT_ID FROM ALTERNATIVE_PRODUCTS WITH (NOLOCK) WHERE 
             	PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.alternative_product#">
				<cfif isdefined('attributes.tree_stock_id')>
                 AND TREE_STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.tree_stock_id#"><cfelseif isdefined('attributes.tree_info_null_') and tree_info_null_ eq 1>
                 AND TREE_STOCK_ID IS NULL</cfif>)
			)
			AND STOCKS.PRODUCT_ID NOT IN (SELECT PRODUCT_ID FROM ALTERNATIVE_PRODUCTS_EXCEPT WITH (NOLOCK) WHERE ALTERNATIVE_PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.alternative_product#">)
		</cfif>	
		<cfif isdefined("attributes.is_store_module")>
			AND STOCKS.PRODUCT_ID IN (SELECT PRODUCT_ID FROM #dsn1_alias#.PRODUCT_BRANCH WITH (NOLOCK) WHERE BRANCH_ID IN(SELECT BRANCH_ID FROM #dsn_alias#.EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">))
		</cfif>
		<cfif isdefined("attributes.is_production")>
			AND STOCKS.IS_PRODUCTION = 1
		</cfif>
		<cfif isdefined("attributes.list_product_id") and len(attributes.list_product_id)>
			AND STOCKS.PRODUCT_ID IN (#attributes.list_product_id#)
		</cfif>
		<cfif isdefined('xml_use_project_filter') and xml_use_project_filter eq 1 and isdefined("attributes.project_id") and len(attributes.project_id) and isdefined('attributes.project_head') and len(attributes.project_head)>
			<!--- xml de proje filtresi secilmisse, secilen projenin masraf merkezine baglı urunler listelenir --->
			AND STOCKS.PRODUCT_ID IN (
										SELECT 
											DISTINCT CP.PRODUCT_ID
										FROM
											#dsn3_alias#.PRODUCT_PERIOD CP WITH (NOLOCK),
											#dsn2_alias#.EXPENSE_CENTER EXC WITH (NOLOCK),
											#dsn_alias#.PRO_PROJECTS PRJ WITH (NOLOCK)
										WHERE
											CP.PRODUCT_ID =STOCKS.PRODUCT_ID
											AND CP.PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.period_id#">
											AND PRJ.PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_id#">
											AND (CP.EXPENSE_CENTER_ID=EXC.EXPENSE_ID OR CP.COST_EXPENSE_CENTER_ID=EXC.EXPENSE_ID)
											AND SUBSTRING(PRJ.EXPENSE_CODE,1,3) = EXC.EXPENSE_CODE
										)
		</cfif>
		<cfif isdefined("attributes.list_property_id") and len(attributes.list_property_id) and len(attributes.list_variation_id)>
			AND
			STOCKS.PRODUCT_ID IN
			(
				SELECT
					PRODUCT_ID
				FROM
					#dsn1_alias#.PRODUCT_DT_PROPERTIES PRODUCT_DT_PROPERTIES WITH (NOLOCK)
				WHERE
					(
				  <cfloop from="1" to="#listlen(attributes.list_property_id,',')#" index="pro_index">
					(PROPERTY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ListGetAt(attributes.list_property_id,pro_index,",")#"> AND VARIATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ListGetAt(attributes.list_variation_id,pro_index,",")#">)
					<cfif pro_index lt listlen(attributes.list_property_id,',')>OR</cfif>
				  </cfloop>
					)
				GROUP BY
					PRODUCT_ID
				HAVING
					COUNT(PRODUCT_ID)> = <cfqueryparam cfsqltype="cf_sql_integer" value="#listlen(attributes.list_property_id,',')#">
			)
		</cfif>
        <cfif isdefined("attributes.main_id")>
        	AND STOCKS.STOCK_ID NOT IN 
            (
            	SELECT DISTINCT 
                	DESIGN_MAIN_RELATED_ID
				FROM     
                	EZGI_DESIGN_MAIN_ROW AS EDM WITH (NOLOCK)
				WHERE  
                	NOT (DESIGN_MAIN_RELATED_ID IS NULL)
          	)
        </cfif>
        <cfif isdefined("attributes.package_id")>
        	AND STOCKS.STOCK_ID NOT IN 
            (
            	SELECT DISTINCT 
                	PACKAGE_RELATED_ID
				FROM     
                	EZGI_DESIGN_PACKAGE_ROW WITH (NOLOCK)
				WHERE  
                	NOT (PACKAGE_RELATED_ID IS NULL)
            
            )
        </cfif>
		),CTE2 AS 
		(
		SELECT
				CTE1.*,
				ROW_NUMBER() OVER (ORDER BY PRODUCT_NAME,PROPERTY DESC) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
			FROM
				CTE1
		)
		SELECT
			CTE2.*
		FROM
			CTE2
		WHERE
			RowNum BETWEEN #attributes.startrow# and #attributes.startrow#+(#attributes.maxrows#-1)
	</cfquery>
    <!---<cfdump var="#PRODUCT_NAMES#">--->
