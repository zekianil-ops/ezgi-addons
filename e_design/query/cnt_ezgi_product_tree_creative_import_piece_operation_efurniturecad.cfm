<!---
    File:cnt_ezgi_product_tree_creative_import_piece_operation_efurniturecad.cfm
    Folder: V16\add_options\ezgi\e_furniture
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description: 
---> 
<cfquery name="get_op_list" dbtype="query">
	SELECT * FROM get_efurniturecad_operation WHERE PIECE_NUMBER = #kesim_listesi.PIECE_NUMBER# ORDER BY WA_PRODUCT_TREE_OPERATION_TYPE_ID
</cfquery>
<cfset sira_no = 0>
<cfloop query="get_op_list">
	<cfif len(get_op_list.OPERATION_TYPE_ID)>
    	<cfset sira_no = sira_no+1>
		<cfset temp = QueryAddRow(operations)>
     	<cfset Temp = QuerySetCell(operations, "Last_Row", kesim_listesi.PIECE_NUMBER)> 
       	<cfset Temp = QuerySetCell(operations, "Piece_Id", kesim_listesi.PIECE_NUMBER)> 
  		<cfset Temp = QuerySetCell(operations, "Operation_Type_Id", get_op_list.OPERATION_TYPE_ID)>
      	<cfset Temp = QuerySetCell(operations, "Amount",1)>
        <cfset Temp = QuerySetCell(operations, "Number",sira_no)> <!---Operasyon Sıra No--->
    </cfif>
</cfloop>