<cfif isdefined('attributes.ezgi_design') and isdefined('attributes.product_type') and (attributes.product_type eq 2 or attributes.product_type eq 3 or attributes.product_type eq 4)> <!---I Flow Sipariş Sayfasından Geliyorsa--->
	<cfquery name="PRODUCTS" datasource="#DSN3#">
    	SELECT
			*
      	FROM
        	(
			<cfif attributes.product_type eq 2>
                SELECT        
                    2 AS TYPE, 
                    '' AS PROPERTY,
                    'Adet' AS MAIN_UNIT,
                    EDMR.DESIGN_MAIN_NAME PRODUCT_NAME, 
                    EDMR.DESIGN_ID PRODUCT_ID, 
                    EDMR.DESIGN_MAIN_ROW_ID STOCK_ID,
                    PC.HIERARCHY + '.2' + CAST(EDMR.DESIGN_MAIN_ROW_ID AS VARCHAR) AS STOCK_CODE, 
                    PC.PRODUCT_CATID
                FROM            
                    EZGI_DESIGN_MAIN_ROW AS EDMR INNER JOIN
                    EZGI_DESIGN AS ED ON EDMR.DESIGN_ID = ED.DESIGN_ID INNER JOIN
                    PRODUCT_CAT AS PC ON ED.PRODUCT_CATID = PC.PRODUCT_CATID
                WHERE     
                    1=1   
                    AND EDMR.DESIGN_MAIN_STATUS = 1  
                    AND ED.STATUS = 1
           	<cfelseif attributes.product_type eq 3>
            	SELECT     
                	3 AS TYPE, 
                    '' AS PROPERTY, 
                    'Adet' AS MAIN_UNIT, 
                	EDPR.PACKAGE_NAME PRODUCT_NAME, 
                    EDPR.DESIGN_ID PRODUCT_ID,
                    EDPR.PACKAGE_ROW_ID STOCK_ID,
                    PC.HIERARCHY + '.3' + CAST(EDPR.PACKAGE_ROW_ID AS VARCHAR) AS STOCK_CODE,
                    PC.PRODUCT_CATID  
				FROM            
                	EZGI_DESIGN AS ED INNER JOIN
                 	PRODUCT_CAT AS PC ON ED.PRODUCT_CATID = PC.PRODUCT_CATID INNER JOIN
                  	EZGI_DESIGN_PACKAGE AS EDPR ON ED.DESIGN_ID = EDPR.DESIGN_ID
				WHERE        
                	ED.STATUS = 1
                    <cfif isdefined('attributes.ezgi_design') and attributes.ezgi_design eq 2>
            			AND PACKAGE_IS_MASTER = 1
                    </cfif>
           	<cfelseif attributes.product_type eq 4>
            	SELECT      
                	4 AS TYPE,  
                    '' AS PROPERTY,
                    'Adet' AS MAIN_UNIT,
                    ED.DESIGN_NAME+' '+EDP.PIECE_NAME + ' (' + EC.COLOR_NAME + ')' AS PRODUCT_NAME,
                    EDP.DESIGN_ID PRODUCT_ID,
                    EDP.PIECE_ROW_ID STOCK_ID,
                    PC.HIERARCHY + '.4' + CAST(EDP.PIECE_ROW_ID AS VARCHAR) AS STOCK_CODE,
                    PC.PRODUCT_CATID
				FROM            
                	EZGI_DESIGN AS ED INNER JOIN
                 	PRODUCT_CAT AS PC ON ED.PRODUCT_CATID = PC.PRODUCT_CATID INNER JOIN
                 	EZGI_DESIGN_PIECE AS EDP ON ED.DESIGN_ID = EDP.DESIGN_ID INNER JOIN
                  	EZGI_COLORS AS EC ON EDP.PIECE_COLOR_ID = EC.COLOR_ID
				WHERE        
                	ED.STATUS = 1 AND 
                    EDP.PIECE_STATUS = 1
           	</cfif>
            ) AS TBL
     	WHERE
        	1=1
    		<cfif isDefined("attributes.keyword") and len(attributes.keyword)>
                AND 
                (
                <cfif len(attributes.keyword) eq 1 >
                    PRODUCT_NAME LIKE '#attributes.keyword#%' 
                <cfelseif len(attributes.keyword) gt 1>
                    <cfif listlen(attributes.keyword,"+") gt 1>
                        (
                            <cfloop from="1" to="#listlen(attributes.keyword,'+')#" index="pro_index">
                                PRODUCT_NAME LIKE '%#ListGetAt(attributes.keyword,pro_index,"+")#%' 
                                <cfif pro_index neq listlen(attributes.keyword,'+')>AND</cfif>
                            </cfloop>
                        )		
                    <cfelse>
                        PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
                        STOCK_CODE LIKE '<cfif len(attributes.keyword) gt 1>%</cfif>#attributes.keyword#%'
                    </cfif>
                </cfif>		
                ) 
            </cfif>
            <cfif isDefined("attributes.product_catid") and len(attributes.product_catid)>
                AND PRODUCT_CATID = #attributes.product_catid#
            </cfif>
            
      	ORDER BY
            PRODUCT_NAME
    </cfquery>
<cfelseif isdefined('attributes.ezgi_production') and isdefined('attributes.product_type') and (attributes.product_type eq 2 or attributes.product_type eq 3 )> <!---I Flow Üretim Sayfasından Geliyorsa--->
	<cfquery name="PRODUCTS" datasource="#DSN3#">
    	SELECT
			*
      	FROM
        	(
			<cfif attributes.product_type eq 2>
            	SELECT        
                	2 AS TYPE, 
                    '' AS PROPERTY,
                    PU.MAIN_UNIT, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_ID, 
                    S.STOCK_ID, 
                    S.PRODUCT_CODE AS STOCK_CODE, 
                    PC.PRODUCT_CATID
				FROM            
                	EZGI_DESIGN_MAIN_ROW AS EDMR INNER JOIN
                  	EZGI_DESIGN AS ED ON EDMR.DESIGN_ID = ED.DESIGN_ID INNER JOIN
                    #dsn1_alias#.PRODUCT_CAT AS PC ON ED.PRODUCT_CATID = PC.PRODUCT_CATID INNER JOIN
                 	STOCKS AS S ON EDMR.DESIGN_MAIN_RELATED_ID = S.STOCK_ID INNER JOIN
                   	#dsn1_alias#.PRODUCT_UNIT AS PU ON S.PRODUCT_ID = PU.PRODUCT_ID
				WHERE        
                	EDMR.DESIGN_MAIN_STATUS = 1 AND 
                    ED.STATUS = 1 AND 
                    PU.IS_MAIN = 1
           	<cfelseif attributes.product_type eq 3>
            	SELECT        
                	3 AS TYPE, 
                    '' AS PROPERTY,
                    PU.MAIN_UNIT, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_ID, 
                    S.STOCK_ID, 
                    S.PRODUCT_CODE AS STOCK_CODE, 
                    PC.PRODUCT_CATID
				FROM           
                	#dsn1_alias#.PRODUCT_UNIT AS PU INNER JOIN
               		STOCKS AS S ON PU.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
                   	EZGI_DESIGN_PACKAGE AS EDP ON S.STOCK_ID = EDP.PACKAGE_RELATED_ID INNER JOIN
                 	EZGI_DESIGN AS ED INNER JOIN
                	#dsn1_alias#.PRODUCT_CAT AS PC ON ED.PRODUCT_CATID = PC.PRODUCT_CATID ON EDP.DESIGN_ID = ED.DESIGN_ID
				WHERE      
                	ED.STATUS = 1 AND 
                    PU.IS_MAIN = 1
                    <cfif isdefined('attributes.ezgi_design') and attributes.ezgi_design eq 2>
            			AND PACKAGE_IS_MASTER = 1
                    </cfif>
           	<cfelseif attributes.product_type eq 4>
            	SELECT        
                	4 AS TYPE, 
                    '' AS PROPERTY,
                    PU.MAIN_UNIT, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_ID, 
                    S.STOCK_ID, 
                    S.PRODUCT_CODE AS STOCK_CODE, 
                    PC.PRODUCT_CATID
				FROM            
               		EZGI_DESIGN_PIECE AS EDP INNER JOIN
                  	EZGI_DESIGN AS ED INNER JOIN
                 	PRODUCT_CAT AS PC ON ED.PRODUCT_CATID = PC.PRODUCT_CATID ON EDP.DESIGN_ID = ED.DESIGN_ID INNER JOIN
                  	#dsn1_alias#.PRODUCT_UNIT AS PU INNER JOIN
                 	#dsn1_alias#.STOCKS AS S ON PU.PRODUCT_ID = S.PRODUCT_ID ON EDP.PIECE_RELATED_ID = S.STOCK_ID
				WHERE    
                	ED.STATUS = 1 AND 
                    PU.IS_MAIN = 1 AND 
                    EDP.PIECE_TYPE <> 4 AND 
                    EDP.PIECE_STATUS = 1
           	</cfif>
            ) AS TBL
     	WHERE
        	1=1
    		<cfif isDefined("attributes.keyword") and len(attributes.keyword)>
                AND 
                (
                <cfif len(attributes.keyword) eq 1 >
                    PRODUCT_NAME LIKE '#attributes.keyword#%' 
                <cfelseif len(attributes.keyword) gt 1>
                    <cfif listlen(attributes.keyword,"+") gt 1>
                        (
                            <cfloop from="1" to="#listlen(attributes.keyword,'+')#" index="pro_index">
                                PRODUCT_NAME LIKE '%#ListGetAt(attributes.keyword,pro_index,"+")#%' 
                                <cfif pro_index neq listlen(attributes.keyword,'+')>AND</cfif>
                            </cfloop>
                        )		
                    <cfelse>
                        PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
                        STOCK_CODE LIKE '<cfif len(attributes.keyword) gt 1>%</cfif>#attributes.keyword#%'
                    </cfif>
                </cfif>		
                ) 
            </cfif>
            <cfif isDefined("attributes.product_catid") and len(attributes.product_catid)>
                AND PRODUCT_CATID = #attributes.product_catid#
            </cfif>
            
      	ORDER BY
            PRODUCT_NAME
    </cfquery>
<cfelse>
    <cfquery name="PRODUCTS" datasource="#DSN3#">
        SELECT
        	5 AS TYPE,
            PRODUCT.COMPANY_ID,
            PRODUCT.PRODUCT_ID,
            PRODUCT.PRODUCT_NAME,
            PRODUCT.MANUFACT_CODE,
            PRODUCT.TAX,
            PRODUCT.TAX_PURCHASE,
            PRODUCT.PRODUCT_CATID,
            PRODUCT.IS_SERIAL_NO,
        <cfif isdefined("attributes.price_catid") and attributes.price_catid gt 0>
            PRICE.PRICE,
            PRICE.MONEY,
        <cfelse>
            PRICE_STANDART.PRICE,
            PRICE_STANDART.MONEY,
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
            STOCKS,
        <cfif isdefined("attributes.price_catid") and attributes.price_catid gt 0>
            PRICE, PRICE_CAT
        <cfelse>
            PRICE_STANDART
        </cfif>
        WHERE
            PRODUCT.PRODUCT_STATUS = 1 AND 	
            STOCKS.PRODUCT_ID = PRODUCT.PRODUCT_ID AND
            PRODUCT_UNIT.PRODUCT_ID = PRODUCT.PRODUCT_ID AND 
            PRODUCT_UNIT.PRODUCT_UNIT_STATUS = 1 AND 
            PRODUCT_CAT.PRODUCT_CATID = PRODUCT.PRODUCT_CATID AND 
            PRODUCT_UNIT.IS_MAIN = 1
        <cfif isdefined("attributes.price_catid") and attributes.price_catid gt 0><!--- dinamik bir fiyat kategorisi istenmisse --->
            AND PRICE_CAT.PRICE_CATID = #attributes.price_catid#			
            AND	PRICE_CAT.PRICE_CAT_STATUS = 1
            AND	PRICE_CAT.PRICE_CATID = PRICE.PRICE_CATID
            AND PRICE.STARTDATE <= #now()#
            AND	(PRICE.FINISHDATE >= #now()# OR PRICE.FINISHDATE IS NULL)
            AND PRICE.UNIT = PRODUCT_UNIT.PRODUCT_UNIT_ID
            AND	ISNULL(PRICE.STOCK_ID,0) =0
            AND	ISNULL(PRICE.SPECT_VAR_ID,0) =0
        <cfelseif isdefined("attributes.price_catid") and attributes.price_catid eq '-1'><!--- Standart alis Fiyatlari Default Gelsin --->
            <cfif isdefined('attributes.add_product_cost')><!--- Karma kolide kullanılıyor,eğer bu değişken gönderiliyorsa satış fiyatları gelsin,kaldırmayın M.ER--->
                AND PRICE_STANDART.PURCHASESALES = 1
            <cfelse>
                AND PRICE_STANDART.PURCHASESALES = 0
            </cfif>	
            AND PRODUCT_UNIT.PRODUCT_UNIT_ID = PRICE_STANDART.UNIT_ID
            AND PRICE_STANDART.PRICESTANDART_STATUS = 1			
        <cfelse>
            AND PRICE_STANDART.PRICESTANDART_STATUS = 1			
            AND PRICE_STANDART.PURCHASESALES = 0
            AND PRODUCT_UNIT.PRODUCT_UNIT_ID = PRICE_STANDART.UNIT_ID
        </cfif>
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
        ORDER BY
            PRODUCT.PRODUCT_NAME
    </cfquery>
</cfif>
