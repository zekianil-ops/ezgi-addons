<!--- Sayfa Hem Stok Detayından Hemde ÜretimPlanlama=>Siparişler Sayfasından ajax ile çağırlıyor.Değişiklik yapılırken kontrol edilmelidir.
stok emirlerden is_from_stock parametresi ile çağrılıyor queryleri farklı çekiyor
  -dept_id ve loc_id eklendi. Depo filtresi seçili ise, filtreleme yapıyor.(hgul)
 --->
<cf_xml_page_edit fuseact ="objects.popup_reserved_orders">
<cfsetting showdebugoutput="no">
<cfif not isdefined("attributes.row_id")><cfset attributes.row_id = 1></cfif>
<cfquery name="GET_S" datasource="#DSN#">
	SELECT SHIP_METHOD,SHIP_METHOD_ID FROM SHIP_METHOD
</cfquery>
<cfquery name="GET_PRODUCT_NAME" datasource="#DSN3#">
	SELECT
		TOP 1
        PRODUCT_NAME,
        PRODUCT_ID
	FROM
		STOCKS
	WHERE
    	<cfif isdefined('attributes.pid')>
			PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pid#">
        <cfelse>
	        STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sid#">
        </cfif>
     ORDER BY STOCK_ID ASC   
</cfquery>
<cfif isdefined('attributes.sid')>
	<cfset body_class = "body">
    <cfset table_class="pod_box">
    <cfset tr_class="header">
    <cfset td_class="txtboldblue">
	<cfset attributes.pid = get_product_name.product_id>
<cfelse>
	<cfset body_class = "color-list">
	<cfset table_class="color-border">
    <cfset tr_class="color-list">
    <cfset td_class="txtboldblue">
</cfif>
<cfif attributes.taken eq 1>
	<cfinclude template="list_ezgi_reserved_orders_sale.cfm">
<cfelse>
	<cfinclude template="list_ezgi_reserved_orders_purchase.cfm">
</cfif>

