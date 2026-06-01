<!---
    File: add_ezgi_alternative_questions_import.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
	Include Sayfası 
	Henüz Çalışmıyor.
	Aynı klasördeki add_ezgi_product_tree_import.cfm içinden çalışacak
	EZGI_PIECE_ROW_ROW_ID üst bloklardan alınıp include içinde kullanılmalı
---> 

<cfquery name="get_alternative_products" datasource="#dsn3#">
	SELECT 
    	A.ALTERNATIVE_PIECE_ROW_ROW_ID, 
        A.ALTERNATIVE_STOCK_ID AS STOCK_ID, 
        S.PRODUCT_ID
	FROM     
    	EZGI_DESIGN_PIECE_PROTOTIP_ALTERNATIVE AS A WITH (NOLOCK) INNER JOIN
        STOCKS AS S WITH (NOLOCK) ON A.ALTERNATIVE_STOCK_ID = S.STOCK_ID
	WHERE  
    	A.EZGI_PIECE_ROW_ROW_ID = #attributes.EZGI_PIECE_ROW_ROW_ID#
	ORDER BY 
    	A.PIECE_ROW_PROTOTIP_ALTERNATIVE_ID
</cfquery>
<cfquery name="get_main_product_id" datasource="#dsn3#">
	SELECT PRODUCT_ID,STOCK_ID FROM #dsn1_alias#.STOCKS WHERE STOCK_ID = #question_tree_stock_id#
</cfquery>
<cfif get_alternative_products.recordcount>
	<cfloop query="get_alternative_products">
        <cfquery name="add_alternative_products" datasource="#dsn3#">
            INSERT INTO 
                ALTERNATIVE_PRODUCTS
                (
                    TREE_STOCK_ID,
                    PRODUCT_ID, 
                    STOCK_ID, 
                    ALTERNATIVE_PRODUCT_ID, 
                    PRODUCT_TREE_ID, 
                    QUESTION_ID, 
                    RECORD_EMP, 
                    RECORD_DATE
                )
            VALUES 
                (
                    #get_main_product_id.STOCK_ID#,
                    #quetion_product_id#,
                    #get_alternative_products.STOCK_ID#,
                    #get_alternative_products.PRODUCT_ID#,
                    #quetion_product_tree_id#,
                    #attributes.alternative_questions#,
                    #session.ep.userid#,
                    #now()#
                )
        </cfquery>
    </cfloop>
</cfif>