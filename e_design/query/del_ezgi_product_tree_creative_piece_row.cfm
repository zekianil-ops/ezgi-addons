<!---
    File: del_ezgi_product_tree_creative_piece_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfquery name="del_process" datasource="#dsn3#">
	DELETE FROM EZGI_DESIGN_PIECE_ROWS WHERE PIECE_ROW_ID = #attributes.design_piece_row_id#
</cfquery>
<cfquery name="del_process_row" datasource="#dsn3#">
	DELETE FROM EZGI_DESIGN_PIECE_ROW WHERE PIECE_ROW_ID = #attributes.design_piece_row_id#
</cfquery>
<cfquery name="del_rota" datasource="#dsn3#">
 	DELETE FROM EZGI_DESIGN_PIECE_ROTA WHERE PIECE_ROW_ID = #attributes.design_piece_row_id#
</cfquery>
<cfif attributes.fuseaction eq 'prod.emptypopup_del_ezgi_product_tree_creative_piece_row'>
	<script type="text/javascript">
        wrk_opener_reload();
        window.close();
    </script>
</cfif>