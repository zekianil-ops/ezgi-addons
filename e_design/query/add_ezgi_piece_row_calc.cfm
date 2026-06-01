
<!---
    File: add_ezgi_piece_row_calc.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 
<cfquery name="get_sira_no" datasource="#dsn3#">
	SELECT        
    	TOP (1) SIRA_NO
	FROM            
    	EZGI_DESIGN_PIECE_ROW WITH (NOLOCK)
	WHERE        
    	PIECE_ROW_ID = #attributes.design_piece_row_id# AND 
        PIECE_ROW_ROW_TYPE = 2
	ORDER BY 
    	SIRA_NO DESC
</cfquery>
<cfif get_sira_no.recordcount>
	<cfset attributes.sira_no = get_sira_no.SIRA_NO>
<cfelse>
	<cfset attributes.sira_no = 0>
</cfif>
<cfset get_max_id.max_id = attributes.design_piece_row_id>
<cfloop list="#attributes.SELECT_PRODUCTION#" index="i">
	<cfset attributes.sira_no = attributes.sira_no+1>
	<cfset attributes.row_row_type = 2>
	<cfset attributes.miktar = FilterNum(Evaluate('amount_#i#'),4)>
    <cfset attributes.stock_id = i>
    <cfinclude template="add_ezgi_product_tree_creative_piece_row_row.cfm">
</cfloop>
<script type="text/javascript">
 	wrk_opener_reload();
 	window.close();
</script>