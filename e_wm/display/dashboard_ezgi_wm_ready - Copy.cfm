<cfset total_int = 0>
<cfset total_str = 0>
<cfset total_clt = 0>
<cfset total_shp = 0>
<cfset total_trns = 0>
<cfset total_mxd = 0>
<cfquery name="get_default_departments" datasource="#dsn3#">
	SELECT 
    	INTERMEDIATE_WAREHOUSE, 
        PRODUCTION_WAREHOUSE,
        SHELF_WAREHOUSE,
        FIRST_SHELF_ID
	FROM     
    	EZGI_WM_SETUP_ROW
	WHERE  
    	EMPLOYEE_POSITION_ID = #session.ep.POSITION_CODE#
</cfquery>
<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>
<cfquery name="get_depo" datasource="#dsn#">
	SELECT 
    	D.DEPARTMENT_HEAD + ' - ' + SL.COMMENT AS DEPARTMENT_HEAD,
        CAST(SL.DEPARTMENT_ID AS VARCHAR) + '_' + CAST(SL.LOCATION_ID AS VARCHAR) AS DEPO
	FROM     
    	DEPARTMENT AS D INNER JOIN
        BRANCH AS B ON D.BRANCH_ID = B.BRANCH_ID INNER JOIN
        STOCKS_LOCATION AS SL ON D.DEPARTMENT_ID = SL.DEPARTMENT_ID
	WHERE  
    	B.COMPANY_ID = #session.ep.company_id#
</cfquery>
<cfoutput query="get_depo">
	<cfset 'DEPARTMENT_HEAD_#DEPO#' = DEPARTMENT_HEAD>
</cfoutput>
<cfquery name="get_shelf_info" datasource="#dsn3#">
	SELECT SHELF_SIZE_TYPE_ID, SHELF_SIZE_TYPE_CODE, SHELF_SIZE_TYPE_NAME FROM EZGI_WM_SETUP_SHELF_SIZE_TYPE
</cfquery>
<cfoutput query="get_shelf_info">
	<cfset 'SHELF_SIZE_TYPE_CODE_#SHELF_SIZE_TYPE_ID#' = SHELF_SIZE_TYPE_CODE>
</cfoutput>
<cfquery name="Get_Intermediate_Detail" datasource="#dsn3#">
	SELECT 
    	(
        	SELECT 
            	COMMENT
			FROM     
            	EZGI_WM_DEPARTMENTS
			WHERE  
            	DEPO = EEL.DEPO
        ) DEPO_NAME,
    	EPL.DEPO,
        EPL.BARCODE, 
        EPL.PACKING_SIZE_TYPE_CODE,
        EEL.PRODUCT_NAME, 
        EEL.IS_PROTOTYPE, 
        EEL.SERIAL_NO, 
        EEL.STOCK_ID,
        ISNULL(EPL.IS_KARMA, 0) AS IS_KARMA,
        ISNULL(EPL.PACKING_ID, 0) AS PACKING_ID
	FROM     
    	EZGI_WM_PACKING_LAST_STATUS AS EPL INNER JOIN
  		EZGI_WM_SERIAL_NO_LAST_STATUS AS EEL ON EPL.PACKING_ID = EEL.PACKING_ID INNER JOIN
    	EZGI_WM_IS_SERIAL_NO_LIVE AS L ON EEL.SERIAL_NO = L.SERIAL_NO

	WHERE  
    	EEL.DEPO = '#Replace(get_default_departments.INTERMEDIATE_WAREHOUSE,',','-')#'
	UNION ALL
	SELECT 
    	(
        	SELECT 
            	COMMENT
         	FROM      
            	EZGI_WM_DEPARTMENTS AS EZGI_WM_DEPARTMENTS_1
          	WHERE   
            	DEPO = E.DEPO
       	) AS DEPO_NAME, 
        E.DEPO, 
        '' AS BARCODE, 
        '' AS PACKING_SIZE_TYPE_CODE, 
        E.PRODUCT_NAME, 
        E.IS_PROTOTYPE, 
        E.SERIAL_NO, 
        E.STOCK_ID, 
        0 AS IS_KARMA, 
        0 AS PACKING_ID
	FROM     
   		EZGI_WM_SERIAL_NO_LAST_STATUS AS E INNER JOIN
    	EZGI_WM_IS_SERIAL_NO_LIVE AS L ON E.SERIAL_NO = L.SERIAL_NO
	WHERE  
    	E.DEPO = '#Replace(get_default_departments.INTERMEDIATE_WAREHOUSE,',','-')#' AND 
        E.PACKING_ID IS NULL
</cfquery>
<cfquery name="Get_Intermediate_Group_Full" dbtype="query">
	SELECT 
        DEPO_NAME, 
      	BARCODE, 
      	PACKING_SIZE_TYPE_CODE,
        COUNT(*) AS DEPO_STOK,
        PACKING_ID,
        IS_KARMA
	FROM     
    	Get_Intermediate_Detail
  	GROUP BY
        DEPO_NAME, 
      	BARCODE, 
      	PACKING_SIZE_TYPE_CODE,
        PACKING_ID,
        IS_KARMA
</cfquery>

<cfquery name="Get_Transfer_Shelf_All" datasource="#dsn3#">
	SELECT 
    	EEL.PRODUCT_NAME, 
        EEL.IS_PROTOTYPE, 
        EEL.SERIAL_NO, 
        EEL.STOCK_ID, 
        EPP.SHELF_CODE, 
        EPP.SHELF_TYPE, 
        EEL.PALET_BARCODE AS BARCODE, 
        ISNULL(EEL.PACKING_ID, 0) AS PACKING_ID,
        EPP.SHELF_SIZE_TYPE, 
      	EP.PACKING_SIZE_TYPE_CODE,
        EPP.PRODUCT_PLACE_ID,
        EEL.DEPO,
        ISNULL(EP.IS_KARMA, 0) AS IS_KARMA
	FROM     
    	EZGI_WM_SERIAL_NO_LAST_STATUS AS EEL INNER JOIN
        EZGI_PRODUCT_PLACE AS EPP ON EEL.PRODUCT_PLACE_ID = EPP.PRODUCT_PLACE_ID LEFT OUTER JOIN
        EZGI_WM_PACKING_LAST_STATUS AS EP ON EEL.PACKING_ID = EP.PACKING_ID INNER JOIN
    	EZGI_WM_IS_SERIAL_NO_LIVE AS L ON EEL.SERIAL_NO = L.SERIAL_NO
	WHERE  
    	EEL.DEPO = '#Replace(get_default_departments.SHELF_WAREHOUSE,',','-')#' AND 
        EPP.PLACE_STATUS = 1
</cfquery>
<cfquery name="Get_Transfer_Shelf_Group_Full" dbtype="query">
	SELECT 
    	PRODUCT_PLACE_ID, 
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE, 
      	BARCODE, 
      	PACKING_SIZE_TYPE_CODE,
        IS_KARMA,
        PACKING_ID,
        COUNT(*) AS DEPO_STOK
	FROM     
    	Get_Transfer_Shelf_All
  	WHERE
    	SHELF_TYPE = 4
  	GROUP BY
    	PRODUCT_PLACE_ID, 
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE, 
      	BARCODE, 
      	PACKING_SIZE_TYPE_CODE,
        PACKING_ID,
        IS_KARMA
</cfquery>

<cfquery name="Get_Sevkiyat_Shelf_Group_Full" dbtype="query">
	SELECT 
    	PRODUCT_PLACE_ID, 
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE, 
      	BARCODE, 
      	PACKING_SIZE_TYPE_CODE,
        IS_KARMA,
        PACKING_ID,
        COUNT(*) AS DEPO_STOK
	FROM     
    	Get_Transfer_Shelf_All
  	WHERE
    	SHELF_TYPE = 5
  	GROUP BY
    	PRODUCT_PLACE_ID, 
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE, 
      	BARCODE, 
      	PACKING_SIZE_TYPE_CODE,
        PACKING_ID,
        IS_KARMA
</cfquery>

<cfquery name="Get_Mixed_Shelf_Group_Full" dbtype="query">
	SELECT 
    	PRODUCT_PLACE_ID, 
        PACKING_ID,
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE, 
      	BARCODE, 
      	PACKING_SIZE_TYPE_CODE,
        COUNT(*) AS DEPO_STOK,
        IS_KARMA
	FROM     
    	Get_Transfer_Shelf_All
  	WHERE
    	SHELF_TYPE = 3
  	GROUP BY
    	PRODUCT_PLACE_ID, 
        PACKING_ID,
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE, 
      	BARCODE, 
      	PACKING_SIZE_TYPE_CODE,
        IS_KARMA
</cfquery>

<cfquery name="Get_Storage_Shelf_Group_Full" dbtype="query">
	SELECT 
    	PRODUCT_PLACE_ID, 
        PACKING_ID,
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE, 
      	BARCODE, 
      	PACKING_SIZE_TYPE_CODE,
        COUNT(*) AS DEPO_STOK,
        IS_KARMA
	FROM     
    	Get_Transfer_Shelf_All
  	WHERE
    	SHELF_TYPE = 2 AND
    	PACKING_ID >0
  	GROUP BY
    	PRODUCT_PLACE_ID, 
        PACKING_ID,
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE, 
      	BARCODE, 
      	PACKING_SIZE_TYPE_CODE,
        IS_KARMA
</cfquery>
<cfquery name="Get_Collect_Shelf_Group_Full" dbtype="query">
	SELECT 
    	PRODUCT_PLACE_ID, 
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE, 
        COUNT(*) AS DEPO_STOK
	FROM     
    	Get_Transfer_Shelf_All
  	WHERE
    	SHELF_TYPE = 1 AND
    	STOCK_ID >0
  	GROUP BY
    	PRODUCT_PLACE_ID, 
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE
</cfquery>

<cfquery name="get_shelf_type" datasource="#dsn#">
	SELECT 
    	SHELF_ID, 
        SHELF_NAME
	FROM     
    	SHELF
	ORDER BY 
    	SHELF_ID
</cfquery>
<cfquery name="get_shelf_all" datasource="#dsn3#">
	SELECT 
    	SHELF_CODE, 
        PLACE_STATUS, 
        DEPO, 
        SHELF_TYPE, 
        SHELF_SIZE_TYPE, 
        SHELF_SORT
	FROM     
    	EZGI_PRODUCT_PLACE
	WHERE  
    	PLACE_STATUS = 1
</cfquery>
<div class="dash_area">
	<div class="col col-12 col-md-6 col-sm-6 col-xs-12" type="column" index="1" sort="true">
    	<cf_box title="Raf Kategorileri">
            <div class="col col-9 col-md-6 col-sm-6 col-xs-6">
                <cf_grid_list>
                    <thead>
                        <tr>
                            <th><cf_get_lang dictionary_id='57486.Kategori'></th>
                            <th class="text-center">Karma Palet</th>
                            <th class="text-center">Standart Palet</th>
                            <th class="text-center">Paket Sayısı</th>
                            <th class="text-center">Dolu Raf</th>
                            <th class="text-center">Boş Raf</th>
                            <th class="text-center">Toplam Raf</th>
                            <th class="text-center">Oran</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfif get_shelf_type.recordcount>
                        	<cfset t_total_raf = 0>
                           	<cfset t_dolu_raf = 0>
                           	<cfset t_karma_palet = 0>
                          	<cfset t_standart_palet = 0>
                           	<cfset t_total_paket = 0>
                            <cfoutput query="get_shelf_type">
                            	<cfset total_raf = 0>
                                <cfset dolu_raf = 0>
                                <cfset karma_palet = 0>
                                <cfset standart_palet = 0>
                                <cfset total_paket = 0>
                            	<cfif SHELF_ID eq 4> <!---Transfer Adresi--->
                                	<cfquery name="Total_Shelf" dbtype="query">
                                		SELECT 
                                        	COUNT(*) AS SAYI
										FROM
                                        	get_shelf_all
                                      	WHERE
                                      		SHELF_TYPE = 4
                                    </cfquery>
                                    <cfif Total_Shelf.recordcount>
                                    	<cfset total_raf = Total_Shelf.SAYI>
                                    </cfif>
                                    <cfquery name="get_paket_info" dbtype="query">
                                    	SELECT
                                        	SUM(DEPO_STOK) AS SAYI
                                       	FROM
                                        	Get_Transfer_Shelf_Group_Full
                                    </cfquery>
                                    <cfif get_paket_info.recordcount>
                                    	<cfset total_paket = get_paket_info.SAYI>
                                    </cfif>
                                    <cfquery name="get_karma_palet" dbtype="query">
                                    	SELECT
                                        	COUNT(*) AS SAYI
                                       	FROM
                                        	Get_Transfer_Shelf_Group_Full
                                      	WHERE
                                        	IS_KARMA = 1
                                    </cfquery>
                                    <cfif get_karma_palet.recordcount>
                                    	<cfset karma_palet = get_karma_palet.SAYI>
                                    </cfif>
                                    <cfquery name="get_Standart_palet" dbtype="query">
                                    	SELECT
                                        	COUNT(*) AS SAYI
                                       	FROM
                                        	Get_Transfer_Shelf_Group_Full
                                      	WHERE
                                        	IS_KARMA = 0
                                    </cfquery>
                                    <cfif get_Standart_palet.recordcount>
                                    	<cfset standart_palet = get_Standart_palet.SAYI>
                                    </cfif>
                                    <cfquery name="get_dolu_raf" dbtype="query">
                                    	SELECT
                                        	PRODUCT_PLACE_ID
                                       	FROM
                                        	Get_Transfer_Shelf_Group_Full
                                      	WHERE
                                        	PRODUCT_PLACE_ID > 0
                                      	GROUP BY
                                        	PRODUCT_PLACE_ID
                                    </cfquery>
                                    <cfif get_dolu_raf.recordcount>
                                    	<cfset dolu_raf = get_dolu_raf.recordcount>
                                    </cfif>
                              	<cfelseif SHELF_ID eq 1> <!---Toplama Adres--->
                                	<cfquery name="Total_Shelf" dbtype="query">
                                		SELECT 
                                        	COUNT(*) AS SAYI
										FROM
                                        	get_shelf_all
                                      	WHERE
                                      		SHELF_TYPE = 1
                                    </cfquery>
                                    <cfif Total_Shelf.recordcount>
                                    	<cfset total_raf = Total_Shelf.SAYI>
                                    </cfif>
                                    <cfquery name="get_paket_info" dbtype="query">
                                    	SELECT
                                        	SUM(DEPO_STOK) AS SAYI
                                       	FROM
                                        	Get_Collect_Shelf_Group_Full
                                    </cfquery>
                                    <cfif get_paket_info.recordcount>
                                    	<cfset total_paket = get_paket_info.SAYI>
                                    </cfif>
                                    <cfquery name="get_dolu_raf" dbtype="query">
                                    	SELECT
                                        	PRODUCT_PLACE_ID
                                       	FROM
                                        	Get_Collect_Shelf_Group_Full
                                      	WHERE
                                        	PRODUCT_PLACE_ID > 0
                                      	GROUP BY
                                        	PRODUCT_PLACE_ID
                                    </cfquery>
                                    <cfif get_dolu_raf.recordcount>
                                    	<cfset dolu_raf = get_dolu_raf.recordcount>
                                    </cfif>
                              	<cfelseif SHELF_ID eq 2> <!---Stoklama Adres--->
                                	<cfquery name="Total_Shelf" dbtype="query">
                                		SELECT 
                                        	COUNT(*) AS SAYI
										FROM
                                        	get_shelf_all
                                      	WHERE
                                      		SHELF_TYPE = 2
                                    </cfquery>
                                    <cfif Total_Shelf.recordcount>
                                    	<cfset total_raf = Total_Shelf.SAYI>
                                    </cfif>
                                    <cfquery name="get_paket_info" dbtype="query">
                                    	SELECT
                                        	SUM(DEPO_STOK) AS SAYI
                                       	FROM
                                        	Get_Storage_Shelf_Group_Full
                                    </cfquery>
                                    <cfif get_paket_info.recordcount>
                                    	<cfset total_paket = get_paket_info.SAYI>
                                    </cfif>
                                    <cfquery name="get_karma_palet" dbtype="query">
                                    	SELECT
                                        	COUNT(*) AS SAYI
                                       	FROM
                                        	Get_Storage_Shelf_Group_Full
                                      	WHERE
                                        	IS_KARMA = 1 AND
                                            BARCODE >0
                                    </cfquery>
                                    <cfif get_karma_palet.recordcount>
                                    	<cfset karma_palet = get_karma_palet.SAYI>
                                    </cfif>
                                    <cfquery name="get_Standart_palet" dbtype="query">
                                    	SELECT
                                        	COUNT(*) AS SAYI
                                       	FROM
                                        	Get_Storage_Shelf_Group_Full
                                      	WHERE
                                        	IS_KARMA = 0 AND
                                            BARCODE >0
                                    </cfquery>
                                    <cfif get_Standart_palet.recordcount>
                                    	<cfset standart_palet = get_Standart_palet.SAYI>
                                    </cfif>
                                    <cfquery name="get_dolu_raf" dbtype="query">
                                    	SELECT
                                        	PRODUCT_PLACE_ID
                                       	FROM
                                        	Get_Storage_Shelf_Group_Full
                                      	WHERE
                                        	PRODUCT_PLACE_ID > 0
                                      	GROUP BY
                                        	PRODUCT_PLACE_ID
                                    </cfquery>
                                    <cfif get_dolu_raf.recordcount>
                                    	<cfset dolu_raf = get_dolu_raf.recordcount>
                                    </cfif>
                               	<cfelseif SHELF_ID eq 3> <!---Karma Adres--->
                                	<cfquery name="Total_Shelf" dbtype="query">
                                		SELECT 
                                        	COUNT(*) AS SAYI
										FROM
                                        	get_shelf_all
                                      	WHERE
                                      		SHELF_TYPE = 3
                                    </cfquery>
                                    <cfif Total_Shelf.recordcount>
                                    	<cfset total_raf = Total_Shelf.SAYI>
                                    </cfif>
                                    <cfquery name="get_paket_info" dbtype="query">
                                    	SELECT
                                        	SUM(DEPO_STOK) AS SAYI
                                       	FROM
                                        	Get_Mixed_Shelf_Group_Full
                                    </cfquery>
                                    <cfif get_paket_info.recordcount>
                                    	<cfset total_paket = get_paket_info.SAYI>
                                    </cfif>
                                    <cfquery name="get_karma_palet" dbtype="query">
                                    	SELECT
                                        	COUNT(*) AS SAYI
                                       	FROM
                                        	Get_Mixed_Shelf_Group_Full
                                      	WHERE
                                        	IS_KARMA = 1 AND
                                            BARCODE >0
                                    </cfquery>
                                    <cfif get_karma_palet.recordcount>
                                    	<cfset karma_palet = get_karma_palet.SAYI>
                                    </cfif>
                                    <cfquery name="get_Standart_palet" dbtype="query">
                                    	SELECT
                                        	COUNT(*) AS SAYI
                                       	FROM
                                        	Get_Mixed_Shelf_Group_Full
                                      	WHERE
                                        	IS_KARMA = 0 AND
                                            BARCODE >0
                                    </cfquery>
                                    <cfif get_Standart_palet.recordcount>
                                    	<cfset standart_palet = get_Standart_palet.SAYI>
                                    </cfif>
                                    <cfquery name="get_dolu_raf" dbtype="query">
                                    	SELECT
                                        	PRODUCT_PLACE_ID
                                       	FROM
                                        	Get_Mixed_Shelf_Group_Full
                                      	WHERE
                                        	PRODUCT_PLACE_ID > 0
                                      	GROUP BY
                                        	PRODUCT_PLACE_ID
                                    </cfquery>
                                    <cfif get_dolu_raf.recordcount>
                                    	<cfset dolu_raf = get_dolu_raf.recordcount>
                                    </cfif>
                                <cfelseif SHELF_ID eq 5> <!---Sevkiyat Adresi--->
                                	<cfquery name="Total_Shelf" dbtype="query">
                                		SELECT 
                                        	COUNT(*) AS SAYI
										FROM
                                        	get_shelf_all
                                      	WHERE
                                      		SHELF_TYPE = 5
                                    </cfquery>
                                    <cfif Total_Shelf.recordcount>
                                    	<cfset total_raf = Total_Shelf.SAYI>
                                    </cfif>
                                    <cfquery name="get_paket_info" dbtype="query">
                                    	SELECT
                                        	SUM(DEPO_STOK) AS SAYI
                                       	FROM
                                        	Get_Sevkiyat_Shelf_Group_Full
                                    </cfquery>
                                    <cfif get_paket_info.recordcount>
                                    	<cfset total_paket = get_paket_info.SAYI>
                                    </cfif>
                                    <cfquery name="get_karma_palet" dbtype="query">
                                    	SELECT
                                        	COUNT(*) AS SAYI
                                       	FROM
                                        	Get_Sevkiyat_Shelf_Group_Full
                                      	WHERE
                                        	IS_KARMA = 1 AND
                                            BARCODE >0
                                    </cfquery>
                                    <cfif get_karma_palet.recordcount>
                                    	<cfset karma_palet = get_karma_palet.SAYI>
                                    </cfif>
                                    <cfquery name="get_Standart_palet" dbtype="query">
                                    	SELECT
                                        	COUNT(*) AS SAYI
                                       	FROM
                                        	Get_Sevkiyat_Shelf_Group_Full
                                      	WHERE
                                        	IS_KARMA = 0 AND
                                            BARCODE >0
                                    </cfquery>
                                    <cfif get_Standart_palet.recordcount>
                                    	<cfset standart_palet = get_Standart_palet.SAYI>
                                    </cfif>
                                    <cfquery name="get_dolu_raf" dbtype="query">
                                    	SELECT
                                        	PRODUCT_PLACE_ID
                                       	FROM
                                        	Get_Sevkiyat_Shelf_Group_Full
                                      	WHERE
                                        	PRODUCT_PLACE_ID > 0
                                      	GROUP BY
                                        	PRODUCT_PLACE_ID
                                    </cfquery>
                                    <cfif get_dolu_raf.recordcount>
                                    	<cfset dolu_raf = get_dolu_raf.recordcount>
                                    </cfif>
                                </cfif>
                                <tr>
                                    <td>#SHELF_NAME#</td>
                                    <td class="text-center">#karma_palet#</td>
                                    <td class="text-center">#standart_palet#</td>
                                    <td class="text-center">#total_paket#</td>
                                    <td class="text-center">#dolu_raf#</td>
                                    <td class="text-center">#total_raf-dolu_raf#</td>
                                    <td class="text-center">#total_raf#</td>
                                    <td class="text-center">% 
                                    	<cfif total_raf gt 0 and dolu_raf gt 0>
                                        	#TlFormat(dolu_raf/total_raf*100,0)#
                                        <cfelse>
                                        	0
                                        </cfif>
                                    </td>
                                </tr>
                                <cfset t_karma_palet = t_karma_palet + karma_palet>
                                <cfset t_standart_palet = t_standart_palet + standart_palet>
                                <cfset t_total_paket = t_total_paket + total_paket>
                                <cfset t_dolu_raf = t_dolu_raf + dolu_raf>
                                <cfset t_total_raf = t_total_raf + total_raf>
                            </cfoutput>
                            <cfoutput>
                            <tr style="font-weight:bold">
                            	<td>Toplam</td>
                               	<td class="text-center">#t_karma_palet#</td>
                              	<td class="text-center">#t_standart_palet#</td>
                             	<td class="text-center">#t_total_paket#</td>
                              	<td class="text-center">#t_dolu_raf#</td>
                              	<td class="text-center">#t_total_raf-t_dolu_raf#</td>
                              	<td class="text-center">#t_total_raf#</td>
                              	<td class="text-center">% 
                                	<cfif t_total_raf gt 0 and t_dolu_raf gt 0>
                                  		#TlFormat(t_dolu_raf/t_total_raf*100,0)#
                                  	<cfelse>
                                    	0
                                 	</cfif>
                             	</td>
                            </tr>
                            </cfoutput>
                        <cfelse>
                            <tr>
                                <td colspan="8"><cf_get_lang dictionary_id="58486.Kayıt Bulunamadı"></td>
                            </tr>
                        </cfif>
                    </tbody>
                </cf_grid_list>
            </div>
         	<div class="col col-3 col-md-6 col-sm-6 col-xs-6">
                <div class="col-12" style="margin-left:auto;margin-right:auto;">
                    <cfif t_total_raf gt 0 and t_dolu_raf gt 0>
                     	<cfset 'value_1' = "#t_dolu_raf#">
                     	<cfset 'item_1' = "Dolu Raflar">
                        <cfset 'value_2' = "#t_total_raf-t_dolu_raf#">
                     	<cfset 'item_2' = "Boş Raflar">
                        <canvas id="active_orders" style="height:100%;"></canvas>
                        <script>
                            var active_orders = document.getElementById('active_orders');
                            var active_orders_pie = new Chart(active_orders, {
                                type: 'pie',
                                data: {
                                        labels: [<cfloop from="1" to="2" index="i">
                                            <cfoutput>"#evaluate("item_#i#")#(%)"</cfoutput>,</cfloop>],
                                        datasets: [{
                                            label: "Depo Kullanım Oranı %",
                                            backgroundColor: [<cfloop from="1" to="2" index="j">'rgba('+Math.floor((Math.random()*255) + 1) + ',' +Math.floor((Math.random()*255) + 1) + ','+ Math.floor((Math.random()*255) + 1)+',0.60)',</cfloop>],
                                            data: [<cfloop from="1" to="2" index="x"><cfoutput>"#wrk_round(evaluate("value_#x#")*100/t_total_raf,0)#"</cfoutput>,</cfloop>],
                                        }]
                                    },
                                options: {
                                    legend: {
                                        display: false
                                    }
                                }
                            });
                        </script>
                    </cfif>
                </div>
            </div>
    	</cf_box>
    </div>
</div>
<div class="display_area" style=" display:none">	
	<div class="col col-2 col-md-3 col-sm-6 col-xs-12">
    	<div class="dashboard-stat2">
        	<div class="display">
            	<div class="number">
                	<h4 class="font-blue-sharp">
                    	<span data-counter="counterup"><cfoutput><!---#Get_Transfer_Store_Pallets.recordcount#---></cfoutput></span>
                       	<small class="font-red-haze"></small>
                   	</h4>
                   	<small>ARA DEPO</small>
               	</div>
            	<div class="icon">
                 	<img src="css/assets/icons/catalyst-icon-svg/ctl-045-warehouse.svg" width="30px" height="50px" style="cursor:pointer" onClick="genisle_frm(<cfoutput>#Get_Intermediate_Group_Full.recordcount#</cfoutput>,'int')">
              	</div>
         	</div>
         	<div class="progress-info">
              	<div class="progress">
                	<span style="width: 100%;" class="progress-bar progress-bar-success blue-sharp"></span>
            	</div>
              	<div class="status">
                 	<cf_box>
                    	<cf_grid_list>
                        	<thead>
                            	<tr>
                                    <th>S.No</th>
                                    <th>Palet</th>
                                    <th>Palet Tipi</th>
                                    <th>Depo</th>
                                    <th>Miktar</th>
                                </tr>
                            </thead>
                            <tbody>
								<cfif Get_Intermediate_Group_Full.recordcount>
                                    <cfoutput query="Get_Intermediate_Group_Full">
                                    	<input type="hidden" name="frm_int_#Get_Intermediate_Group_Full.currentrow#" id="frm_int_#Get_Intermediate_Group_Full.currentrow#" value="0">	
                                    	<tr onClick="genisle_frm_int(#Get_Intermediate_Group_Full.currentrow#,#Get_Intermediate_Group_Full.DEPO_STOK#)">
                                        	<td style="text-align:right">#currentrow#&nbsp;&nbsp;</td>
                                            <td style="text-align:center">#BARCODE#</td>
                                            <td style="text-align:center" nowrap>#PACKING_SIZE_TYPE_CODE#<cfif IS_KARMA><span style="color:red"> (*)</cfif></td>
                                            <td style="text-align:left">#DEPO_NAME#</td>
                                            <td style="text-align:right">#DEPO_STOK#</td>
                                        </tr>
                                        <cfset total_int = total_int + DEPO_STOK>
                                    </cfoutput>
                                </cfif>
                            </tbody>
                            <tfoot>
                            	<tr>
                                	<td colspan="4">Toplam</td>
                                    <td style="text-align:right"><cfoutput>#total_int#</cfoutput></td>
                                </tr>
                            </tfoot>
                        </cf_grid_list>
                    </cf_box>
               	</div>
       		</div>
      	</div>
	</div>

	<div class="col col-2 col-md-3 col-sm-6 col-xs-12">
    	<div class="dashboard-stat2">
         	<div class="display">
             	<div class="number">
                  	<h4 class="font-green-sharp">
                      	<span data-counter="counterup"><cfoutput><!---#Get_Transfer_Shelf_Group_Full.recordcount#---></cfoutput></span>
                 		<small class="font-green-sharp"></small>
                  	</h4>
                 	<small>TRANSFER ALANI</small>
             	</div>
           		<div class="icon">
                    <img src="css/assets/icons/catalyst-icon-svg/ctl-012-stocks.svg" width="30px" height="50px" style="cursor:pointer" onClick="genisle_frm(<cfoutput>#Get_Transfer_Shelf_Group_Full.recordcount#</cfoutput>,'trns')">
              	</div>
         	</div>
        	<div class="progress-info">
              	<div class="progress">
                 	<span style="width: 100%;" class="progress-bar progress-bar-success green-sharp"></span>
              	</div>
             	<div class="status">
                    <cf_box>
                    	<cf_grid_list>
                        	<thead>
                            	<tr>
                                    <th>S.No</th>
                                    <th>Raf Kodu</th>
                                    <th>Palet</th>
                                    <th>Palet Tipi</th>
                                    <th>Miktar</th>
                                </tr>
                            </thead>
                            <tbody>
								<cfif Get_Transfer_Shelf_Group_Full.recordcount>
                                    <cfoutput query="Get_Transfer_Shelf_Group_Full">
                                    	<input type="hidden" name="frm_trns_#Get_Transfer_Shelf_Group_Full.currentrow#" id="frm_trns_#Get_Transfer_Shelf_Group_Full.currentrow#" value="0">	

                                    	<tr onClick="genisle_frm_trns(#Get_Transfer_Shelf_Group_Full.currentrow#,#Get_Transfer_Shelf_Group_Full.DEPO_STOK#)">
                                        	<td style="text-align:right">#currentrow#&nbsp;&nbsp;</td>
                                            <td style="text-align:center">#SHELF_CODE#</td>
                                         	<td style="text-align:center">#BARCODE#</td>   
                                          	<td style="text-align:center">#PACKING_SIZE_TYPE_CODE# <cfif IS_KARMA><span style="color:red"> (*)</cfif></td>
                                            <td style="text-align:right">#DEPO_STOK#</td>
                                        </tr>
                                        <cfset total_trns = total_trns + DEPO_STOK>
                                     </cfoutput>
                                </cfif>
                            </tbody>
                            <tfoot>
                            	<tr>
                                	<td colspan="4">Toplam</td>
                                    <td style="text-align:right"><cfoutput>#total_trns#</cfoutput></td>
                                </tr>
                            </tfoot>
                        </cf_grid_list>
                    </cf_box>
             	</div>
          	</div>
     	</div>
 	</div>   
    
    <div class="col col-2 col-md-3 col-sm-6 col-xs-12">
    	<div class="dashboard-stat2">
         	<div class="display">
             	<div class="number">
                  	<h4 class="font-green-sharp">
                      	<span data-counter="counterup"><cfoutput><!---#Get_Mixed_Shelf_Group_Full.recordcount#---></cfoutput></span>
                 		<small class="font-green-sharp"></small>
                  	</h4>
                 	<small>KARMA RAFLAR</small>
             	</div>
           		<div class="icon">
                    <img src="css/assets/icons/catalyst-icon-svg/ctl-011-stocks.svg" width="30px" height="50px" style="cursor:pointer" onClick="genisle_frm(<cfoutput>#Get_Mixed_Shelf_Group_Full.recordcount#</cfoutput>,'mxd')">
              	</div>
         	</div>
        	<div class="progress-info">
              	<div class="progress">
                 	<span style="width: 100%;" class="progress-bar progress-bar-success green-sharp"></span>
              	</div>

             	<div class="status">
                    <cf_box>
                    	<cf_grid_list>
                        	<thead>
                            	<tr>
                                    <th>S.No</th>
                                    <th>Raf Kodu</th>
                                    <th>Raf Tipi</th>
                                    <th>Palet</th>
                                    <th>Palet Tipi</th>
                                    <th>Miktar</th>
                                </tr>
                            </thead>
                            <tbody>
								<cfif Get_Mixed_Shelf_Group_Full.recordcount>
                                    <cfoutput query="Get_Mixed_Shelf_Group_Full">
                                    	<input type="hidden" name="frm_mxd_#Get_Mixed_Shelf_Group_Full.currentrow#" id="frm_mxd_#Get_Mixed_Shelf_Group_Full.currentrow#" value="0">	
                                    	<tr onClick="genisle_frm_mxd(#Get_Mixed_Shelf_Group_Full.currentrow#,#Get_Mixed_Shelf_Group_Full.DEPO_STOK#)">
                                        	<td style="text-align:right">#currentrow#&nbsp;&nbsp;</td>
                                            <td style="text-align:center">#SHELF_CODE#</td>
                                            <td style="text-align:center"><cfif isdefined('SHELF_SIZE_TYPE_CODE_#SHELF_SIZE_TYPE#')>#Evaluate('SHELF_SIZE_TYPE_CODE_#SHELF_SIZE_TYPE#')#</cfif></td>
                                         	<td style="text-align:center">#BARCODE#</td>   
                                          	<td style="text-align:center">#PACKING_SIZE_TYPE_CODE#</td>
                                            <td style="text-align:right">#DEPO_STOK#</td>
                                        </tr>
                                        <cfset total_mxd = total_mxd + DEPO_STOK>

                                    </cfoutput>
                                </cfif>
                            </tbody>
                            <tfoot>
                            	<tr>
                                	<td colspan="5">Toplam</td>
                                    <td style="text-align:right"><cfoutput>#total_mxd#</cfoutput></td>
                                </tr>
                            </tfoot>
                        </cf_grid_list>
                    </cf_box>
             	</div>
          	</div>
     	</div>
 	</div>   

	<div class="col col-2 col-md-3 col-sm-6 col-xs-12">
    	<div class="dashboard-stat2">
         	<div class="display">
             	<div class="number">
                  	<h4 class="font-green-sharp">
                      	<span data-counter="counterup"><cfoutput><!---#Get_Storage_Shelf_Group_Full.recordcount#---></cfoutput></span>
                 		<small class="font-green-sharp"></small>
                  	</h4>
                 	<small>STOKLAMA RAFLARI</small>
             	</div>
           		<div class="icon">
                    <img src="css/assets/icons/catalyst-icon-svg/ctl-011-stocks.svg" width="30px" height="50px" style="cursor:pointer" onClick="genisle_frm(<cfoutput>#Get_Storage_Shelf_Group_Full.recordcount#</cfoutput>,'str')">
              	</div>
         	</div>
        	<div class="progress-info">
              	<div class="progress">
                 	<span style="width: 100%;" class="progress-bar progress-bar-success green-sharp"></span>
              	</div>
             	<div class="status">
                    <cf_box>
                    	<cf_grid_list>
                        	<thead>
                            	<tr>
                                    <th>S.No</th>
                                    <th>Raf Kodu</th>
                                    <th>Raf Tipi</th>
                                    <th>Palet</th>
                                    <th>Palet Tipi</th>
                                    <th>Miktar</th>
                                </tr>
                            </thead>
                            <tbody>
								<cfif Get_Storage_Shelf_Group_Full.recordcount>
                                    <cfoutput query="Get_Storage_Shelf_Group_Full">
                                    	<input type="hidden" name="frm_str_#Get_Storage_Shelf_Group_Full.currentrow#" id="frm_str_#Get_Storage_Shelf_Group_Full.currentrow#" value="0">	
                                    	<tr onClick="genisle_frm_str(#Get_Storage_Shelf_Group_Full.currentrow#,#Get_Storage_Shelf_Group_Full.DEPO_STOK#)">
                                        	<td style="text-align:right">#currentrow#&nbsp;&nbsp;</td>
                                            <td style="text-align:center">#SHELF_CODE#</td>
                                            <td style="text-align:center"><cfif isdefined('SHELF_SIZE_TYPE_CODE_#SHELF_SIZE_TYPE#')>#Evaluate('SHELF_SIZE_TYPE_CODE_#SHELF_SIZE_TYPE#')#</cfif></td>
                                         	<td style="text-align:center">#BARCODE#</td>   
                                          	<td style="text-align:center">#PACKING_SIZE_TYPE_CODE#</td>
                                            <td style="text-align:right">#DEPO_STOK#</td>
                                        </tr>
                                        <cfset total_str = total_str + DEPO_STOK>
                                    </cfoutput>
                                </cfif>
                            </tbody>
                            <tfoot>
                            	<tr>
                                	<td colspan="5">Toplam</td>
                                    <td style="text-align:right"><cfoutput>#total_str#</cfoutput></td>
                                </tr>
                            </tfoot>
                        </cf_grid_list>
                    </cf_box>
             	</div>
          	</div>
     	</div>
 	</div>   
 	<div class="col col-2 col-md-3 col-sm-6 col-xs-12">
    	<div class="dashboard-stat2">
        	<div class="display">
            	<div class="number">
                	<h4 class="font-red-haze">
                    	<span data-counter="counterup"><cfoutput><!---#Get_Intermediate_Store_Pallets.recordcount#---></cfoutput></span>
                       	<small class="font-red-haze"></small>
                   	</h4>
                   	<small>TOPLAMA RAFLARI</small>
               	</div>
            	<div class="icon">
                	 <img src="css/assets/icons/catalyst-icon-svg/ctl-011-stocks.svg" width="30px" height="50px" style="cursor:pointer" onClick="genisle_frm(<cfoutput>#Get_Collect_Shelf_Group_Full.recordcount#</cfoutput>,'clt')">
              	</div>
         	</div>
         	<div class="progress-info">
              	<div class="progress">
                	<span style="width: 100%;" class="progress-bar progress-bar-success red-haze"></span>
            	</div>
              	<div class="status">
					<cf_box>
                    	<cf_grid_list>
                        	<thead>
                            	<tr>
                                    <th>S.No</th>
                                    <th>Raf Kodu</th>
                                    <th>Raf Tipi</th>
                                    <th>Miktar</th>
                                </tr>
                            </thead>
                            <tbody>
								<cfif Get_Collect_Shelf_Group_Full.recordcount>
                                    <cfoutput query="Get_Collect_Shelf_Group_Full">
                                    	<input type="hidden" name="frm_clt_#Get_Collect_Shelf_Group_Full.currentrow#" id="frm_clt_#Get_Collect_Shelf_Group_Full.currentrow#" value="0">	
                                    	<tr onClick="genisle_frm_clt(#Get_Collect_Shelf_Group_Full.currentrow#,#Get_Collect_Shelf_Group_Full.DEPO_STOK#)">
                                        	<td style="text-align:right">#currentrow#&nbsp;&nbsp;</td>
                                            <td style="text-align:center">#SHELF_CODE#</td>
                                            <td style="text-align:center"><cfif isdefined('SHELF_SIZE_TYPE_CODE_#SHELF_SIZE_TYPE#')>#Evaluate('SHELF_SIZE_TYPE_CODE_#SHELF_SIZE_TYPE#')#</cfif></td>
                                            <td style="text-align:right">#DEPO_STOK#</td>
                                        </tr>
                                        <cfset total_clt = total_clt + DEPO_STOK>
                                    </cfoutput>
                                </cfif>
                            </tbody>
                            <tfoot>
                            	<tr>
                                	<td colspan="3">Toplam</td>
                                    <td style="text-align:right"><cfoutput>#total_clt#</cfoutput></td>
                                </tr>
                            </tfoot>
                        </cf_grid_list>
                    </cf_box>
               	</div>
       		</div>
      	</div>
	</div>  
</div>
<script type="text/javascript">
	function genisle_frm(total_sira,bolum)
	{
		for(j=1;j<=total_sira;j++)
		{
			adet=document.getElementById('frm_'+bolum+'_alt'+j).value;
			if(bolum=='int')
				genisle_frm_int(j,adet);
			else if(bolum=='str')
				genisle_frm_str(j,adet);
			else if(bolum=='clt')
				genisle_frm_clt(j,adet);
			else if(bolum=='shp')
				genisle_frm_shp(j,adet);
			else if(bolum=='trns')
				genisle_frm_trns(j,adet);
			else if(bolum=='mxd')
				genisle_frm_mxd(j,adet);
		}
	}
	function genisle_frm_int(sira,adet)
	{	
		if(document.getElementById('frm_int_'+sira).value==0)
		{
			for(i=1;i<=adet;i++)
			{
				document.getElementById('frm_int_'+sira+'_'+i).style.display='';
			}
			document.getElementById('frm_int_'+sira).value=1
		}
		else
		{
			for(i=1;i<=adet;i++)
			{
				document.getElementById('frm_int_'+sira+'_'+i).style.display='none';
			}			
			document.getElementById('frm_int_'+sira).value=0
		}
	}
	function genisle_frm_str(sira,adet)
	{	
		if(document.getElementById('frm_str_'+sira).value==0)
		{
			for(i=1;i<=adet;i++)
			{
				document.getElementById('frm_str_'+sira+'_'+i).style.display='';
			}
			document.getElementById('frm_str_'+sira).value=1
		}
		else
		{
			for(i=1;i<=adet;i++)
			{

				document.getElementById('frm_str_'+sira+'_'+i).style.display='none';
			}			
			document.getElementById('frm_str_'+sira).value=0
		}
	}
	function genisle_frm_trns(sira,adet)
	{	
		if(document.getElementById('frm_trns_'+sira).value==0)
		{
			for(i=1;i<=adet;i++)
			{
				document.getElementById('frm_trns_'+sira+'_'+i).style.display='';
			}
			document.getElementById('frm_trns_'+sira).value=1
		}
		else
		{
			for(i=1;i<=adet;i++)
			{
				document.getElementById('frm_trns_'+sira+'_'+i).style.display='none';
			}			
			document.getElementById('frm_trns_'+sira).value=0
		}
	}
	function genisle_frm_mxd(sira,adet)
	{	
		if(document.getElementById('frm_mxd_'+sira).value==0)
		{
			for(i=1;i<=adet;i++)
			{
				document.getElementById('frm_mxd_'+sira+'_'+i).style.display='';
			}
			document.getElementById('frm_mxd_'+sira).value=1
		}
		else
		{
			for(i=1;i<=adet;i++)
			{
				document.getElementById('frm_mxd_'+sira+'_'+i).style.display='none';
			}			
			document.getElementById('frm_mxd_'+sira).value=0
		}
	}
	function genisle_frm_clt(sira,adet)
	{	
		if(document.getElementById('frm_clt_'+sira).value==0)
		{
			for(i=1;i<=adet;i++)
			{
				document.getElementById('frm_clt_'+sira+'_'+i).style.display='';
			}
			document.getElementById('frm_clt_'+sira).value=1
		}
		else
		{
			for(i=1;i<=adet;i++)
			{
				document.getElementById('frm_clt_'+sira+'_'+i).style.display='none';
			}			
			document.getElementById('frm_clt_'+sira).value=0
		}
	}
	function genisle_frm_shp(sira,adet)
	{	
		if(document.getElementById('frm_shp_'+sira).value==0)
		{
			for(i=1;i<=adet;i++)
			{
				document.getElementById('frm_shp_'+sira+'_'+i).style.display='';
			}
			document.getElementById('frm_shp_'+sira).value=1
		}
		else
		{
			for(i=1;i<=adet;i++)
			{
				document.getElementById('frm_shp_'+sira+'_'+i).style.display='none';
			}			
			document.getElementById('frm_shp_'+sira).value=0
		}
	}
</script>