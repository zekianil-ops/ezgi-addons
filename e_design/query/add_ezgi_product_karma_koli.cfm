<!---
    File: add_ezgi_product_karma_koli.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 
<cfquery name="get_stock_info" datasource="#dsn3#">
	SELECT 
    	STOCK_ID
	FROM     
    	#dsn1_alias#.STOCKS WITH (NOLOCK)
	WHERE  
    	PRODUCT_ID = #attributes.main_product_id#
</cfquery>
<cfquery name="ADD_KARMA_PRODUCT" datasource="#dsn3#">
	INSERT INTO 
		#dsn1_alias#.KARMA_PRODUCTS
		(
            KARMA_PRODUCT_ID,
            PRODUCT_ID,
            STOCK_ID,
       		SPEC_MAIN_ID,
            PRODUCT_NAME,
            TAX,
            TAX_PURCHASE,
            PRODUCT_UNIT_ID,
            UNIT,
            MONEY,
            PURCHASE_PRICE,
            SALES_PRICE,
            TOTAL_PRODUCT_PRICE,<!--- Toplam satış fiyatı --->
            PRODUCT_AMOUNT,
            KARMA_PRODUCT_MONEY,
            LIST_PRICE,
            OTHER_LIST_PRICE
    	)
	VALUES   
      	(
            #attributes.main_product_id#,
            #attributes.product_id#,
            #attributes.add_stock_id#,
       		#attributes.spect_main_id#,
            '#attributes.product_name#',
            0,
            0,
            #attributes.UNIT_ID#,
            '#attributes.main_unit#',
            '#session.ep.money#',
            0,
            0,
            0,
            #attributes.AMOUNT#,
            '#session.ep.money#',
            0,
            0
  		)
</cfquery>