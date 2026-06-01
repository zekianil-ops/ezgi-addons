<!---
    File: del_ezgi_product_place_stock.cfm
    Folder: Add_Ons\ezgi\e-pda\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="del_place" datasource="#dsn3#">
	DELETE FROM 
    	PRODUCT_PLACE_ROWS
	WHERE        
    	STOCK_ID = #attributes.stock_id# AND 
        PRODUCT_PLACE_ID = #attributes.product_place_id#
</cfquery>
<script type="text/javascript">
	alert('<cf_get_lang dictionary_id="56829.Silme İşlemi Başarı İle Tamamlandı">');
	wrk_opener_reload();
	window.close();
</script>