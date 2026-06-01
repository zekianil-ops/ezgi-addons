<!---
    File: get_ezgi_product_content.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="GET_CONTENT" datasource="#DSN3#">
	SELECT 
    	POS.STOCK_ID, 
        ISNULL(POS.SPECT_MAIN_ID,0) SPECT_MAIN_ID, 
        FLOOR(POS.AMOUNT/PO.QUANTITY) AS AMOUNT, 
        PU.MAIN_UNIT, 
        S.PRODUCT_NAME, 
        S.PRODUCT_CODE, 
        S.BARCOD, 
        S.PROPERTY,
        0 AS CONTROL_AMOUNT
	FROM     
   		PRODUCTION_ORDERS_STOCKS AS POS INNER JOIN
     	STOCKS AS S ON POS.STOCK_ID = S.STOCK_ID INNER JOIN
       	PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN
      	PRODUCTION_ORDERS AS PO ON POS.P_ORDER_ID = PO.P_ORDER_ID
	WHERE  
    	POS.P_ORDER_ID = #attributes.upd# AND 
        POS.TYPE = 2 AND 
        ISNULL(S.PACKAGE_CONTROL_TYPE, 1) = 1 AND
        FLOOR(POS.AMOUNT/PO.QUANTITY) > 0
</cfquery>
