<cf_wrk_grid search_header = "Fire Sebepleri" dictionary_count="3" table_name="EZGI_VTS_LOST_REASON" sort_column="LOST_REASON_NAME" u_id="LOST_REASON_ID" datasource="#dsn3#" search_areas = "LOST_REASON_NAME" right_images="">
    <cf_wrk_grid_column name="LOST_REASON_ID" header="Fire Sebep ID" display="no" select="yes"/>
    <cf_wrk_grid_column name="LOST_REASON_NAME" required="true" header="Fire Sebebi" select="yes" display="yes"/>
    <cf_wrk_grid_column name="LOST_REASON_TYPE" width="200" header="Tür No" select="yes" display="yes"/>
    <cf_wrk_grid_column name="LOST_REASON_STATUS" width="250" header="Statü" type="boolean" select="yes" display="yes"/>
    <cf_wrk_grid_column name="LOST_REASON_DETAIL" required="true" header="Açıklama" select="yes" display="yes"/>
	<cf_wrk_grid_column name="RECORD_DATE" header="#getLang('main',215)#" type="date" mask="date" width="100" select="no" display="yes"/>
    <cf_wrk_grid_column name="UPDATE_DATE" header="#getLang('settings',1180)#" type="date" mask="date" width="100" select="no" display="yes"/>
</cf_wrk_grid>