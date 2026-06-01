<!---
    File: del_ezgi_product_tree_creative_package_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cftransaction>
    <!---Sepet Ürünleri Siliniyor--->
    <cfquery name="DEL_ALL_MATERIAL" datasource="#DSN3#">
        DELETE FROM EZGI_DESIGN_ALL_MATERIAL WHERE DESIGN_PACKAGE_ROW_ID = #attributes.design_package_row_id#
    </cfquery>
    <!---Paket Siliniyor--->
    <cfquery name="del_package" datasource="#dsn3#">
        DELETE FROM EZGI_DESIGN_PACKAGE_ROW	WHERE PACKAGE_ROW_ID = #attributes.design_package_row_id#
    </cfquery>
    <!---Paketin Rotası Siliniyor--->
    <cfquery name="del_rota" datasource="#dsn3#">
        DELETE FROM EZGI_DESIGN_PIECE_ROTA WHERE PACKAGE_ROW_ID = #attributes.design_package_row_id#
    </cfquery>
</cftransaction>
<script type="text/javascript">
        wrk_opener_reload();
        window.close();
</script>