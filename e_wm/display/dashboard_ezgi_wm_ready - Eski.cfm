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

<cfquery name="Get_Transfer_Shelf_Detail" datasource="#dsn3#">
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
        EPP.SHELF_TYPE = 4 AND 
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
    	Get_Transfer_Shelf_Detail
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

<cfquery name="Get_Mixed_Shelf_Detail" datasource="#dsn3#">
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
        EEL.DEPO
	FROM     
    	EZGI_WM_SERIAL_NO_LAST_STATUS AS EEL INNER JOIN
        EZGI_PRODUCT_PLACE AS EPP ON EEL.PRODUCT_PLACE_ID = EPP.PRODUCT_PLACE_ID LEFT OUTER JOIN
        EZGI_WM_PACKING_LAST_STATUS AS EP ON EEL.PACKING_ID = EP.PACKING_ID INNER JOIN
    	EZGI_WM_IS_SERIAL_NO_LIVE AS L ON EEL.SERIAL_NO = L.SERIAL_NO
	WHERE  
    	EEL.DEPO = '#Replace(get_default_departments.SHELF_WAREHOUSE,',','-')#' AND 
        EPP.SHELF_TYPE = 3 AND 
        EPP.PLACE_STATUS = 1
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
        COUNT(*) AS DEPO_STOK
	FROM     
    	Get_Mixed_Shelf_Detail
  	GROUP BY
    	PRODUCT_PLACE_ID, 
        PACKING_ID,
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE, 
      	BARCODE, 
      	PACKING_SIZE_TYPE_CODE
</cfquery>


<cfquery name="Get_Storage_Shelf_Detail" datasource="#dsn3#">
	SELECT 
    	EPP.PRODUCT_PLACE_ID, 
        EPP.SHELF_CODE, 
        EPP.DEPO, 
        EPP.SHELF_SIZE_TYPE, 
        EPL.BARCODE, 
        EPL.PACKING_SIZE_TYPE_CODE,
        EEL.PRODUCT_NAME, 
        EEL.IS_PROTOTYPE, 
        EEL.SERIAL_NO, 
        EEL.STOCK_ID,
        ISNULL(EPL.PACKING_ID, 0) AS PACKING_ID
	FROM     
    	EZGI_PRODUCT_PLACE AS EPP INNER JOIN
        EZGI_WM_PACKING_LAST_STATUS AS EPL ON EPP.PRODUCT_PLACE_ID = EPL.SHELF_NUMBER RIGHT OUTER JOIN
        EZGI_WM_SERIAL_NO_LAST_STATUS AS EEL ON EPL.PACKING_ID = EEL.PACKING_ID INNER JOIN
    	EZGI_WM_IS_SERIAL_NO_LIVE AS L ON EEL.SERIAL_NO = L.SERIAL_NO
	WHERE  
    	EPP.DEPO = '#Replace(get_default_departments.SHELF_WAREHOUSE,',','-')#' AND 
        EPP.SHELF_TYPE = 2 AND 
        EPP.PLACE_STATUS = 1
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
        COUNT(*) AS DEPO_STOK
	FROM     
    	Get_Storage_Shelf_Detail
  	WHERE
    	PACKING_ID >0
  	GROUP BY
    	PRODUCT_PLACE_ID, 
        PACKING_ID,
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE, 
      	BARCODE, 
      	PACKING_SIZE_TYPE_CODE
</cfquery>
<cfquery name="Get_Collect_Shelf_Detail" datasource="#dsn3#">
    SELECT 
    	EPP.PRODUCT_PLACE_ID, 
        EPP.SHELF_CODE, 
        EPP.DEPO, 
        EPP.SHELF_SIZE_TYPE, 
        EEL.SERIAL_NO, 
        ISNULL(EEL.STOCK_ID,0) AS STOCK_ID,
        EEL.PACKING_ID, 
        EEL.PRODUCT_NAME, 
        EEL.IS_PROTOTYPE
    FROM     
    	EZGI_WM_SERIAL_NO_LAST_STATUS AS EEL INNER JOIN
        EZGI_PRODUCT_PLACE AS EPP ON EEL.PRODUCT_PLACE_ID = EPP.PRODUCT_PLACE_ID INNER JOIN
    	EZGI_WM_IS_SERIAL_NO_LIVE AS L ON EEL.SERIAL_NO = L.SERIAL_NO
    WHERE  
    	EPP.SHELF_TYPE = 1 AND 
        EPP.PLACE_STATUS = 1 AND 
        EPP.DEPO = '#Replace(get_default_departments.SHELF_WAREHOUSE,',','-')#' 
</cfquery>
<cfquery name="Get_Collect_Shelf_Group_Full" dbtype="query">
	SELECT 
    	PRODUCT_PLACE_ID, 
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE, 
        COUNT(*) AS DEPO_STOK
	FROM     
    	Get_Collect_Shelf_Detail
  	WHERE
    	STOCK_ID >0
  	GROUP BY
    	PRODUCT_PLACE_ID, 
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE
</cfquery>
<cfquery name="Get_Shipment_Shelf_Detail" datasource="#dsn3#">
	SELECT 
    	EPP.PRODUCT_PLACE_ID, 
        EPP.SHELF_CODE, 
        EPP.DEPO, 
        EPP.SHELF_SIZE_TYPE, 
        EEL.SERIAL_NO, 
        ISNULL(EEL.STOCK_ID, 0) AS STOCK_ID, 
        EEL.PACKING_ID, 
        EEL.PRODUCT_NAME, 
        EEL.IS_PROTOTYPE, 
        TBL.DELIVER_PAPER_NO
	FROM     
    	EZGI_WM_SERIAL_NO_LAST_STATUS AS EEL INNER JOIN
        EZGI_PRODUCT_PLACE AS EPP ON EEL.PRODUCT_PLACE_ID = EPP.PRODUCT_PLACE_ID INNER JOIN
        (
        	SELECT 
            	DELIVER_PAPER_NO, 
                SHIPMENT_PRODUCT_PLACE_ID
         	FROM      
            	EZGI_SHIP_RESULT
          	WHERE   
            	NOT (SHIPMENT_PRODUCT_PLACE_ID IS NULL)
        	UNION ALL
            SELECT 
            	CAST(DISPATCH_SHIP_ID AS VARCHAR) AS DISPATCH_SHIP_ID, 
                SHIPMENT_PRODUCT_PLACE_ID
         	FROM     
            	#dsn2_alias#.SHIP_INTERNAL
          	WHERE  
            	NOT (SHIPMENT_PRODUCT_PLACE_ID IS NULL)
      	) AS TBL ON EPP.PRODUCT_PLACE_ID = TBL.SHIPMENT_PRODUCT_PLACE_ID
	WHERE  
    	EPP.SHELF_TYPE = 5 AND 
        EPP.PLACE_STATUS = 1 AND 
        EPP.DEPO = '#Replace(get_default_departments.SHELF_WAREHOUSE,',','-')#' 
</cfquery>
<cfquery name="Get_Shipment_Shelf_Group_Full" dbtype="query">
	SELECT 
    	PRODUCT_PLACE_ID,
        PACKING_ID, 
        SHELF_CODE, 
        DEPO, 
      	SHELF_SIZE_TYPE, 
        DELIVER_PAPER_NO,
        COUNT(*) AS DEPO_STOK
	FROM     
    	Get_Shipment_Shelf_Detail
  	WHERE
    	STOCK_ID >0
  	GROUP BY
    	PRODUCT_PLACE_ID, 
        PACKING_ID,
        SHELF_CODE, 
        DEPO, 
        DELIVER_PAPER_NO,
      	SHELF_SIZE_TYPE
</cfquery>
<br>
<div class="display_area">	
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

                                    	<cfquery name="Get_Intermediate_Group_Serial" dbtype="query">
                                            SELECT 
                                              	PRODUCT_NAME, 
                                              	IS_PROTOTYPE, 
                                             	SERIAL_NO, 
                                              	STOCK_ID
                                            FROM     
                                                Get_Intermediate_Detail
                                            WHERE
                                                PACKING_ID = #PACKING_ID#
                                        </cfquery>
                                        <input type="hidden" name="frm_int_alt#Get_Intermediate_Group_Full.currentrow#" id="frm_int_alt#Get_Intermediate_Group_Full.currentrow#" value="#Get_Intermediate_Group_Serial.recordcount#">
                                        <cfloop query="Get_Intermediate_Group_Serial">
                                            <tr id="frm_int_#Get_Intermediate_Group_Full.currentrow#_#Get_Intermediate_Group_Serial.currentrow#" style=" font-weight:normal; display:none">
                                                <td style="text-align:right">#currentrow#</td>
                                                <td style="text-align:center">#SERIAL_NO#</td>
                                                <td style="text-align:left" colspan="3">#PRODUCT_NAME#</td>
                                            </tr>
                                        </cfloop>
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
                                        <cfquery name="Get_Transfer_Shelf_Group_Serial" dbtype="query">
                                            SELECT 
                                              	PRODUCT_NAME, 
                                              	IS_PROTOTYPE, 
                                             	SERIAL_NO, 
                                              	STOCK_ID
                                            FROM     
                                                Get_Transfer_Shelf_Detail
                                            WHERE
                                                PRODUCT_PLACE_ID = #PRODUCT_PLACE_ID# AND PACKING_ID =#PACKING_ID#
                                        </cfquery>
                                        <input type="hidden" name="frm_trns_alt#Get_Transfer_Shelf_Group_Full.currentrow#" id="frm_trns_alt#Get_Transfer_Shelf_Group_Full.currentrow#" value="#Get_Transfer_Shelf_Group_Serial.recordcount#">	
                                        <cfloop query="Get_Transfer_Shelf_Group_Serial">
                                            <tr id="frm_trns_#Get_Transfer_Shelf_Group_Full.currentrow#_#Get_Transfer_Shelf_Group_Serial.currentrow#" style=" font-weight:normal; display:none">
                                                <td style="text-align:right">#currentrow#</td>
                                                <td style="text-align:center">#SERIAL_NO#</td>
                                                <td style="text-align:left" colspan="3">#PRODUCT_NAME#</td>
                                            </tr>
                                        </cfloop>
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
                                        <cfquery name="Get_Mixed_Shelf_Group_Serial" dbtype="query">
                                            SELECT 
                                              	PRODUCT_NAME, 
                                              	IS_PROTOTYPE, 
                                             	SERIAL_NO, 
                                              	STOCK_ID
                                            FROM     
                                                Get_Mixed_Shelf_Detail
                                            WHERE
                                                PRODUCT_PLACE_ID = #PRODUCT_PLACE_ID# AND PACKING_ID =#PACKING_ID#
                                        </cfquery>
                                        <input type="hidden" name="frm_mxd_alt#Get_Mixed_Shelf_Group_Full.currentrow#" id="frm_mxd_alt#Get_Mixed_Shelf_Group_Full.currentrow#" value="#Get_Mixed_Shelf_Group_Serial.recordcount#">	
                                        <cfloop query="Get_Mixed_Shelf_Group_Serial">
                                            <tr id="frm_mxd_#Get_Mixed_Shelf_Group_Full.currentrow#_#Get_Mixed_Shelf_Group_Serial.currentrow#" style=" font-weight:normal; display:none">
                                                <td style="text-align:right">#currentrow#</td>
                                                <td style="text-align:center">#SERIAL_NO#</td>
                                                <td style="text-align:left" colspan="4">#PRODUCT_NAME#</td>
                                            </tr>
                                        </cfloop>
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
                                        <cfquery name="Get_Storage_Shelf_Group_Serial" dbtype="query">
                                            SELECT 
                                              	PRODUCT_NAME, 
                                              	IS_PROTOTYPE, 
                                             	SERIAL_NO, 
                                              	STOCK_ID
                                            FROM     
                                                Get_Storage_Shelf_Detail
                                            WHERE
                                                PRODUCT_PLACE_ID = #PRODUCT_PLACE_ID# AND PACKING_ID =#PACKING_ID#
                                        </cfquery>
                                        <input type="hidden" name="frm_str_alt#Get_Storage_Shelf_Group_Full.currentrow#" id="frm_str_alt#Get_Storage_Shelf_Group_Full.currentrow#" value="#Get_Storage_Shelf_Group_Serial.recordcount#">	
                                        <cfloop query="Get_Storage_Shelf_Group_Serial">
                                            <tr id="frm_str_#Get_Storage_Shelf_Group_Full.currentrow#_#Get_Storage_Shelf_Group_Serial.currentrow#" style=" font-weight:normal; display:none">
                                                <td style="text-align:right">#currentrow#</td>
                                                <td style="text-align:center">#SERIAL_NO#</td>
                                                <td style="text-align:left" colspan="4">#PRODUCT_NAME#</td>
                                            </tr>
                                        </cfloop>
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
                                        <cfquery name="Get_Collect_Shelf_Group_Serial" dbtype="query">
                                            SELECT 
                                              	PRODUCT_NAME, 
                                              	IS_PROTOTYPE, 
                                             	SERIAL_NO, 
                                              	STOCK_ID
                                            FROM     
                                                Get_Collect_Shelf_Detail
                                            WHERE
                                                PRODUCT_PLACE_ID = #PRODUCT_PLACE_ID#
                                        </cfquery>
                                        <input type="hidden" name="frm_clt_alt#Get_Collect_Shelf_Group_Full.currentrow#" id="frm_clt_alt#Get_Collect_Shelf_Group_Full.currentrow#" value="#Get_Collect_Shelf_Group_Serial.recordcount#">	
                                        <cfloop query="Get_Collect_Shelf_Group_Serial">
                                            <tr id="frm_clt_#Get_Collect_Shelf_Group_Full.currentrow#_#Get_Collect_Shelf_Group_Serial.currentrow#" style=" font-weight:normal; display:none">
                                                <td style="text-align:right">#currentrow#</td>
                                                <td style="text-align:center">#SERIAL_NO#</td>
                                                <td style="text-align:left" colspan="2">#PRODUCT_NAME#</td>
                                            </tr>
                                        </cfloop>
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
	<div class="col col-2 col-md-3 col-sm-6 col-xs-12">
    	<div class="dashboard-stat2">
        	<div class="display">
            	<div class="number">
                	<h4 class="font-blue-sharp">
                    	<span data-counter="counterup"><cfoutput><!---#Get_Transfer_Store_Pallets.recordcount#---></cfoutput></span>
                       	<small class="font-red-haze"></small>
                   	</h4>
                   	<small>SEVKİYAT ALANI</small>
               	</div>
            	<div class="icon">
                 	<img src="css/assets/icons/catalyst-icon-svg/ctl-016-loader.svg" width="40px" height="55px" style="cursor:pointer" onClick="genisle_frm(<cfoutput>#Get_Shipment_Shelf_Group_Full.recordcount#</cfoutput>,'shp')">
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
                                    <th>Transfer Alanı</th>
                                    <th>Sevk No</th>
                                    <th>Miktar</th>
                                </tr>
                            </thead>
                            <tbody>
								<cfif Get_Shipment_Shelf_Group_Full.recordcount>
                                    <cfoutput query="Get_Shipment_Shelf_Group_Full">
                                    	<input type="hidden" name="frm_shp_#Get_Shipment_Shelf_Group_Full.currentrow#" id="frm_shp_#Get_Shipment_Shelf_Group_Full.currentrow#" value="0">	
                                    	<tr onClick="genisle_frm_shp(#Get_Shipment_Shelf_Group_Full.currentrow#,#Get_Shipment_Shelf_Group_Full.DEPO_STOK#)">
                                        	<td style="text-align:right">#currentrow#&nbsp;&nbsp;</td>
                                            <td style="text-align:center">#SHELF_CODE#</td>
                                            <td style="text-align:center">#DELIVER_PAPER_NO#</td>
                                            <td style="text-align:right">#DEPO_STOK#</td>
                                        </tr>
                                        <cfset total_shp = total_shp + DEPO_STOK>
                                        <cfif len(Get_Shipment_Shelf_Group_Full.PRODUCT_PLACE_ID) and len(Get_Shipment_Shelf_Group_Full.PACKING_ID)>
                                            <cfquery name="Get_Shipment_Shelf_Group_Serial" dbtype="query">
                                                SELECT 
                                                    PRODUCT_NAME, 
                                                    IS_PROTOTYPE, 
                                                    SERIAL_NO, 
                                                    STOCK_ID
                                                FROM     
                                                    Get_Shipment_Shelf_Detail
                                                WHERE
                                                    PRODUCT_PLACE_ID = #Get_Shipment_Shelf_Group_Full.PRODUCT_PLACE_ID# AND PACKING_ID =#Get_Shipment_Shelf_Group_Full.PACKING_ID#
                                            </cfquery>
                                            <input type="hidden" name="frm_shp_alt#Get_Shipment_Shelf_Group_Full.currentrow#" id="frm_shp_alt#Get_Shipment_Shelf_Group_Full.currentrow#" value="#Get_Shipment_Shelf_Group_Serial.recordcount#">
                                            <cfloop query="Get_Shipment_Shelf_Group_Serial">
                                                <tr id="frm_shp_#Get_Shipment_Shelf_Group_Full.currentrow#_#Get_Shipment_Shelf_Group_Serial.currentrow#" style=" font-weight:normal; display:none">
                                                    <td style="text-align:right">#currentrow#</td>
                                                    <td style="text-align:center">#SERIAL_NO#</td>
                                                    <td style="text-align:left" colspan="2">#PRODUCT_NAME#</td>
                                                </tr>
                                            </cfloop>
                                      	</cfif>
                                    </cfoutput>
                                </cfif>
                            </tbody>
                            <tfoot>
                            	<tr>
                                	<td colspan="3">Toplam</td>
                                    <td style="text-align:right"><cfoutput>#total_shp#</cfoutput></td>
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