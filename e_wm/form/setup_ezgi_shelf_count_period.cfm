<!---
    File: setup_ezgi_shelf_count_period.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 15/12/2025
    Description: Raf ve Depo Sayım İşlemi
---> 
<cf_wrk_grid search_header = "Raf Sayım Dönemi Tanımı" table_name="EZGI_WM_SETUP_COUNT_PERIOD" sort_column="EZGI_COUNT_PERIOD" u_id="EZGI_COUNT_PERIOD_ID" datasource="#dsn3#" search_areas = "EZGI_COUNT_PERIOD" dictionary_count="2">
    <cf_wrk_grid_column name="EZGI_COUNT_PERIOD_ID" header="ID" display="no" select="yes"/>
    <cf_wrk_grid_column name="EZGI_COUNT_PERIOD" header="Sayım Dönemi Adı" select="yes" display="yes"/>
    <cf_wrk_grid_column name="EZGI_COUNT_PERIOD_TIME" header="Sayım Dönemi Zamanı (Gün)" width="3" type="number" select="yes" display="yes"/>
</cf_wrk_grid>	