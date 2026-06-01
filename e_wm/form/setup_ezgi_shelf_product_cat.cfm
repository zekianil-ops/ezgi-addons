<!---
    File: setup_ezgi_shelf_product_cat.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 15/12/2025
    Description: Raf ve Depo Sayım İşlemi
---> 
<cf_wrk_grid search_header = "Raf Ürün Kategori Tanımı" table_name="EZGI_WM_SETUP_PLACE_CAT" sort_column="EZGI_PLACE_CAT" u_id="EZGI_PLACE_CAT_ID" datasource="#dsn3#" search_areas = "EZGI_PLACE_CAT" dictionary_count="2">
    <cf_wrk_grid_column name="EZGI_PLACE_CAT_ID" header="ID" display="no" select="yes"/>
    <cf_wrk_grid_column name="EZGI_PLACE_CAT" header="Kategori Adı" select="yes" display="yes"/>
</cf_wrk_grid>	