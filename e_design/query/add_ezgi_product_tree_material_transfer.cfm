<!---
    File: add_ezgi_product_tree_material_transfer.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfquery name="get_package_info" datasource="#dsn3#">
	SELECT PACKAGE_ROW_ID, DESIGN_ID, DESIGN_MAIN_ROW_ID FROM EZGI_DESIGN_PACKAGE WHERE PACKAGE_ROW_ID = #attributes.design_package_row_id#
</cfquery>
<cfquery name="get_all_material" datasource="#dsn3#">
	SELECT        
    	E.PRODUCT_ID, 
        E.STOCK_ID, 
        E.AMOUNT, 
        S.PRODUCT_NAME
	FROM            
    	EZGI_DESIGN_ALL_MATERIAL AS E WITH (NOLOCK) INNER JOIN
      	STOCKS AS S WITH (NOLOCK) ON E.STOCK_ID = S.STOCK_ID
	WHERE        
    	E.DESIGN_PACKAGE_ROW_ID = #attributes.design_package_row_id#
</cfquery>	
<cfquery name="get_piece_code" datasource="#dsn3#">
	SELECT        
    	TOP (1) 
        CASE 
        	WHEN LEFT(PIECE_CODE, 1) = 0 
            THEN RIGHT(PIECE_CODE, 1) 
            ELSE PIECE_CODE 
      	END AS PIECE_CODE
	FROM            
    	EZGI_DESIGN_PIECE WITH (NOLOCK)
	WHERE        
    	DESIGN_MAIN_ROW_ID = #get_package_info.DESIGN_MAIN_ROW_ID#
	ORDER BY 
    	PIECE_CODE DESC
</cfquery>
<cfif get_piece_code.recordcount>
	<cfset piece_code = get_piece_code.PIECE_CODE>
<cfelse>
	<cfset piece_code = 0>
</cfif>

<cfif get_all_material.recordcount>
	<cftransaction>
        <cfloop query="get_all_material">
            <cfset piece_code = piece_code+1>
            <cfset attributes.PIECE_TYPE = 4>
            <cfset attributes.related_stock_id = STOCK_ID>
            <cfset attributes.RELATED_PRODUCT_NAME = PRODUCT_NAME>
            <cfset attributes.piece_detail = ''>
            <cfset attributes.design_main_row_id = get_package_info.DESIGN_MAIN_ROW_ID>
            <cfset attributes.design_id = get_package_info.DESIGN_ID>
            <cfset attributes.piece_package_no = attributes.design_package_row_id>
            <cfset attributes.PIECE_AMOUNT = AMOUNT>
            <cfif len(piece_code) gt 1>
                <cfset attributes.DESIGN_CODE_PIECE_ROW = piece_code>
            <cfelse>
                <cfset attributes.DESIGN_CODE_PIECE_ROW = '0#piece_code#'>
            </cfif>
            <cfset attributes.import_files = 1>
            <cfinclude template="add_ezgi_product_tree_creative_piece_row.cfm">
        </cfloop>
        <cfquery name="del_design_all_material" datasource="#dsn3#">
            DELETE FROM EZGI_DESIGN_ALL_MATERIAL WHERE DESIGN_PACKAGE_ROW_ID = #attributes.design_package_row_id#
        </cfquery>
    </cftransaction>
    <script type="text/javascript">
        alert('<cf_get_lang dictionary_id='253.Transfer Başarıyla Tamamlandı'> !');
		wrk_opener_reload();
        window.close();
    </script>
<cfelse>
	<script type="text/javascript">
        alert('<cf_get_lang dictionary_id='254.Transfer Edilecek Malzeme Bulunamadı'> !');
        window.close();
    </script>
</cfif>