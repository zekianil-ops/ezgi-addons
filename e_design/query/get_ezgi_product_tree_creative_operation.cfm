<!---
    File: get_ezgi_product_tree_creative_operation.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfquery name="get_operation" datasource="#dsn3#">
	SELECT
    	0 AS RELATED_ID,        
    	PIECE_ROW_ID, 
        OPERATION_TYPE_ID, 
        SIRA AS LINE_NUMBER, 
        AMOUNT
	FROM            
    	EZGI_DESIGN_PIECE_ROTA WITH (NOLOCK)
	WHERE        
    	PIECE_ROW_ID = #attributes.design_piece_row_id#
  	ORDER BY
    	SIRA
</cfquery>