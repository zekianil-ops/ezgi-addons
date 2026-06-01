<!---
    File: del_ezgi_product_tree_creative_piece_rota.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 
<cftransaction>
    <cfquery name="del_rota" datasource="#dsn3#">
        DELETE FROM 
        	EZGI_DESIGN_PIECE_ROTA 
       	WHERE 
        	<cfif isdefined('attributes.piece_id')>
                PIECE_ROW_ID = #attributes.piece_id# 
            <cfelseif isdefined('attributes.package_id')>
                PACKAGE_ROW_ID = #attributes.package_id#
            <cfelseif isdefined('attributes.main_id')>
                MAIN_ROW_ID = #attributes.main_id#
            </cfif>
    </cfquery>
</cftransaction>
<script type="text/javascript">
	alert('<cf_get_lang dictionary_id="972.Operasyonlar Silinmiştir.">');
  	window.close();
</script>