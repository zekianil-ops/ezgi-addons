<cfset attributes.bugun = Dateformat(now(),dateformat_style)>
<cf_date tarih="attributes.bugun">
<cfset attributes.yarin = DateAdd('d',1,attributes.bugun)>
<cfquery name="get_default_departments" datasource="#dsn3#">
	SELECT 
    	INTERMEDIATE_WAREHOUSE, 
        PRODUCTION_WAREHOUSE,
        SHELF_WAREHOUSE,
        FIRST_SHELF_ID,
        SHIPMENT_WAREHOUSE,
        ORDER_PAGE_AUTHORITY
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
<cfif ListLen(get_default_departments.ORDER_PAGE_AUTHORITY) and ListFind(get_default_departments.ORDER_PAGE_AUTHORITY,1)>
    <cfquery name="Get_Intermediate_Store_Pallets" datasource="#dsn3#">
          SELECT TOP (20) 
            PACKING_ID, 
            PROCESS_DATE, 
            BARCODE, 
            PACKING_SIZE_TYPE_ID, 
            PACKING_SIZE_TYPE_CODE, 
            SHELF_SIZE_TYPE_ID, 
            PACKING_SIZE_TYPE_NAME,
            DEPO,
            (
             	SELECT 
               		COUNT(*) AS SAYI
				FROM     
                	EZGI_PACKING_ROW AS EPR INNER JOIN
                  	EZGI_WM_IS_SERIAL_NO_LIVE AS ESL ON EPR.SERIAL_NO = ESL.SERIAL_NO
				WHERE  
                	EPR.PACKING_ID = EZGI_WM_PACKING_LAST_STATUS.PACKING_ID
        	)AS SAYI
        FROM     
            EZGI_WM_PACKING_LAST_STATUS
        WHERE  
            EZGI_PACKING_ACTION_TYPE_ID = 1 AND
            PROCESS_STATUS = 2
        ORDER BY 
            PROCESS_DATE
    </cfquery>
</cfif>
<cfif ListLen(get_default_departments.ORDER_PAGE_AUTHORITY) and ListFind(get_default_departments.ORDER_PAGE_AUTHORITY,2)>
    <cfquery name="Get_Transfer_Store_Pallets" datasource="#dsn3#">
        SELECT TOP (20) 
            E.PACKING_ID, 
            E.PROCESS_DATE, 
            E.BARCODE, 
            E.PACKING_SIZE_TYPE_ID, 
            E.PACKING_SIZE_TYPE_CODE, 
            E.SHELF_SIZE_TYPE_ID, 
            E.PACKING_SIZE_TYPE_NAME, 
            P.SHELF_CODE,
            (
             	SELECT 
               		COUNT(*) AS SAYI
				FROM     
                	EZGI_PACKING_ROW AS EPR INNER JOIN
                  	EZGI_WM_IS_SERIAL_NO_LIVE AS ESL ON EPR.SERIAL_NO = ESL.SERIAL_NO
				WHERE  
                	EPR.PACKING_ID = E.PACKING_ID
        	)AS SAYI
        FROM     
            EZGI_WM_PACKING_LAST_STATUS AS E INNER JOIN
            PRODUCT_PLACE AS P ON E.SHELF_NUMBER = P.PRODUCT_PLACE_ID
        WHERE  
            E.EZGI_PACKING_ACTION_TYPE_ID = 2 AND 
            E.PROCESS_STATUS = 2
        ORDER BY 
            E.PROCESS_DATE
    </cfquery>
</cfif>
<cfif ListLen(get_default_departments.ORDER_PAGE_AUTHORITY) and ListFind(get_default_departments.ORDER_PAGE_AUTHORITY,3)>
    <cfquery name="Get_Transfer_Pallets_To_Collect_Shelf" datasource="#dsn3#">
        SELECT 
            EWM.PRODUCT_PLACE_ID, 
            EWM.SHELF_CODE, 
            EWM.MAX_STOCK, 
            EWM.MIN_STOCK, 
            EWM.STOCK_ID, 
            EWM.READY_AMOUNT, 
            EWM.PLACE_STATUS, 
            EWM.PRODUCT_NAME, 
            EPL.BARCODE, 
            EWM.SHELF_SIZE_TYPE, 
            EPP.SHELF_CODE AS NEW_SHELF_CODE, 
            EPL.AMOUNT, 
            EPL.AMOUNT + EWM.READY_AMOUNT AS NEW_AMOUNT, 
            EPL.PACKING_SIZE_TYPE_CODE, 
            EPL.SHELF_SIZE_TYPE_ID, 
            EPL.STATUS, 
            EPL.EZGI_PACKING_ACTION_TYPE_ID,
            EWS.SHELF_SIZE_TYPE_CODE,
            CASE 
                WHEN 
                    ISNULL(EWM.COLLECT_SORT, 0) - ISNULL(EPP.COLLECT_SORT, 0) < 0 
                THEN 
                    (ISNULL(EWM.COLLECT_SORT, 0) - ISNULL(EPP.COLLECT_SORT, 0)) * - 1 
                ELSE 
                    ISNULL(EWM.COLLECT_SORT, 0) - ISNULL(EPP.COLLECT_SORT, 0) 
            END 
                AS YAKINLIK
        FROM     
            EZGI_PRODUCT_PLACE AS EPP INNER JOIN
            EZGI_WM_PACKING_LAST_STATUS AS EPL ON EPP.PRODUCT_PLACE_ID = EPL.SHELF_NUMBER INNER JOIN
            EZGI_WM_COLLECT_SHELF_STATUS AS EWM ON EPL.STOCK_ID = EWM.STOCK_ID INNER JOIN
            EZGI_WM_SETUP_SHELF_SIZE_TYPE AS EWS ON EWM.SHELF_SIZE_TYPE = EWS.SHELF_SIZE_TYPE_ID
        WHERE  
            EWM.DEPO = '#Replace(get_default_departments.SHELF_WAREHOUSE,',','-')#' AND 
            EWM.MIN_STOCK >= EWM.READY_AMOUNT
    </cfquery>
    <cfquery name="Get_Transfer_Pallets_To_Collect_Shelf_group" dbtype="query">
        SELECT 
            SHELF_CODE, 
            STOCK_ID, 
            READY_AMOUNT, 
            PRODUCT_NAME, 
            SHELF_SIZE_TYPE_CODE
        FROM     
            Get_Transfer_Pallets_To_Collect_Shelf
        GROUP BY
            SHELF_CODE, 
            STOCK_ID, 
            READY_AMOUNT, 
            PRODUCT_NAME, 
            SHELF_SIZE_TYPE_CODE  
    </cfquery>
</cfif>
<cfif ListLen(get_default_departments.ORDER_PAGE_AUTHORITY) and ListFind(get_default_departments.ORDER_PAGE_AUTHORITY,4)>
    <cfquery name="Get_Transfer_Pallets_To_Shipment" datasource="#dsn3#">
        SELECT
            *,
            CASE
            	WHEN TBL.COMPANY_ID IS NOT NULL THEN
                        (
                        SELECT     
                            NICKNAME
                            FROM         
                                #dsn_alias#.COMPANY WITH (NOLOCK)
                            WHERE     
                                COMPANY_ID = TBL.COMPANY_ID
                        )
             	 WHEN TBL.CONSUMER_ID IS NOT NULL THEN      
                        (	
                            SELECT     
                                CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                            FROM         
                                #dsn_alias#.CONSUMER WITH (NOLOCK)
                            WHERE     
                                CONSUMER_ID = TBL.CONSUMER_ID
                        )
    		END AS UNVAN
        FROM
            (
       		SELECT
             	ISNULL(SUM(ORR.QUANTITY), 0) AS AMOUNT,
           		ESR.SHIP_RESULT_ID, 
                ESR.NOTE, 
                ESR.SHIP_FIS_NO, 
                ESR.DELIVER_PAPER_NO, 
                ESR.REFERENCE_NO, 
                ESR.DELIVERY_DATE, 
                ESR.DEPARTMENT_ID, 
                O.COMPANY_ID, 
                O.CONSUMER_ID, 
                ESR.OUT_DATE, 
                ESR.IS_TYPE, 
                ESR.LOCATION_ID, 
                ESR.SHIP_METHOD_TYPE, 
                SM.SHIP_METHOD, 
                D.DEPARTMENT_HEAD,
                (
                    SELECT     
                        SUM(SEVK_DURUM) AS SEVK_DURUM
                    FROM         
                        (
                        SELECT     
                            SEVK_DURUM
                        FROM          
                            (
                            SELECT     
                                CASE 
                                    WHEN ORR.ORDER_ROW_CURRENCY = - 6 THEN 1
                                    ELSE
                                        0
                                END AS SEVK_DURUM
                            FROM          
                                EZGI_SHIP_RESULT_ROW AS ESRR INNER JOIN
                                ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID
                            WHERE      
                                ESRR.SHIP_RESULT_ID = ESR.SHIP_RESULT_ID
                            ) AS TBL2
                        GROUP BY SEVK_DURUM
                        ) AS TBL3
               	) AS SEVK_DURUM,
                (
                    SELECT 
                        SHELF_CODE
                    FROM     
                        EZGI_PRODUCT_PLACE
                    WHERE  
                        PRODUCT_PLACE_ID = ESR.SHIPMENT_PRODUCT_PLACE_ID
                ) AS SHELF_CODE
         	FROM 
             	EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) JOIN 
             	#dsn_alias#.SHIP_METHOD AS SM WITH (NOLOCK) ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID JOIN 
              	#dsn_alias#.DEPARTMENT AS D WITH (NOLOCK) ON ESR.DEPARTMENT_ID = D.DEPARTMENT_ID LEFT JOIN 
            	EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID LEFT JOIN 
             	ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID LEFT JOIN 
             	ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID LEFT JOIN 
             	STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID
         	WHERE 
                ESR.IS_TYPE = 1 AND 
                ESR.DEPARTMENT_ID = #listgetat(get_default_departments.SHIPMENT_WAREHOUSE,1,',')# AND 
                ESR.LOCATION_ID = #listgetat(get_default_departments.SHIPMENT_WAREHOUSE,2,',')# AND 
             	ESR.OUT_DATE BETWEEN #attributes.bugun# AND #attributes.yarin#
          	GROUP BY
            	ESR.SHIP_RESULT_ID, 
                ESR.NOTE, 
                ESR.SHIP_FIS_NO, 
                ESR.DELIVER_PAPER_NO, 
                ESR.REFERENCE_NO, 
                ESR.DELIVERY_DATE, 
                ESR.DEPARTMENT_ID, 
                O.COMPANY_ID, 
                O.CONSUMER_ID, 
                ESR.OUT_DATE, 
                ESR.IS_TYPE, 
                ESR.LOCATION_ID, 
                ESR.SHIP_METHOD_TYPE, 
                SM.SHIP_METHOD, 
                D.DEPARTMENT_HEAD,
                ESR.SHIPMENT_PRODUCT_PLACE_ID
            UNION ALL
            SELECT
             	ISNULL(SUM(ORR.QUANTITY), 0) AS AMOUNT,
           		ESR.SHIP_RESULT_INTERNALDEMAND_ID SHIP_RESULT_ID, 
                ESR.NOTE, 
                ESR.SHIP_FIS_NO, 
                CAST(ESR.SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) AS DELIVER_PAPER_NO, 
                ESR.REFERENCE_NO, 
                ESR.DELIVERY_DATE, 
                ESR.DEPARTMENT_ID, 
                O.COMPANY_ID, 
                O.CONSUMER_ID, 
                ESR.OUT_DATE, 
                ESR.IS_TYPE, 
                ESR.LOCATION_ID, 
                ESR.SHIP_METHOD_TYPE, 
                SM.SHIP_METHOD, 
                D.DEPARTMENT_HEAD,
                (
                    SELECT     
                        SUM(SEVK_DURUM) AS SEVK_DURUM
                    FROM         
                        (
                        SELECT     
                            SEVK_DURUM
                        FROM          
                            (
                            SELECT     
                                CASE 
                                    WHEN ORR.ORDER_ROW_CURRENCY = - 6 THEN 1
                                    ELSE
                                        0
                                END AS SEVK_DURUM
                            FROM          
                                EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR INNER JOIN
                                ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID
                            WHERE      
                                ESRR.SHIP_RESULT_INTERNALDEMAND_ID = ESR.SHIP_RESULT_INTERNALDEMAND_ID
                            ) AS TBL2
                        GROUP BY SEVK_DURUM
                        ) AS TBL3
               	) AS SEVK_DURUM,
                (
                    SELECT 
                        SHELF_CODE
                    FROM     
                        EZGI_PRODUCT_PLACE
                    WHERE  
                        PRODUCT_PLACE_ID = ESR.SHIPMENT_PRODUCT_PLACE_ID
                ) AS SHELF_CODE
         	FROM 
             	EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) JOIN 
             	#dsn_alias#.SHIP_METHOD AS SM WITH (NOLOCK) ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID JOIN 
              	#dsn_alias#.DEPARTMENT AS D WITH (NOLOCK) ON ESR.DEPARTMENT_IN_ID = D.DEPARTMENT_ID LEFT JOIN 
            	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID LEFT JOIN 
             	ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID LEFT JOIN 
             	ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID LEFT JOIN 
             	STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID
         	WHERE 
                ESR.IS_TYPE = 2 AND 
                ESR.DEPARTMENT_ID = #listgetat(get_default_departments.SHIPMENT_WAREHOUSE,1,',')# AND 
                ESR.LOCATION_ID = #listgetat(get_default_departments.SHIPMENT_WAREHOUSE,2,',')# AND 
             	ESR.OUT_DATE BETWEEN #attributes.bugun# AND #attributes.yarin#
          	GROUP BY
            	ESR.SHIP_RESULT_INTERNALDEMAND_ID, 
                ESR.NOTE, 
                ESR.SHIP_FIS_NO, 
                ESR.REFERENCE_NO, 
                ESR.DELIVERY_DATE,
                ESR.DEPARTMENT_IN_ID, 
                ESR.DEPARTMENT_ID, 
                O.COMPANY_ID, 
                O.CONSUMER_ID, 
                ESR.OUT_DATE, 
                ESR.IS_TYPE, 
                ESR.LOCATION_ID, 
                ESR.SHIP_METHOD_TYPE, 
                SM.SHIP_METHOD, 
                D.DEPARTMENT_HEAD,
                ESR.SHIPMENT_PRODUCT_PLACE_ID
            ) AS TBL
        WHERE
            AMOUNT > 0 AND
            SEVK_DURUM = 1
        ORDER BY
            SHELF_CODE
    </cfquery>
</cfif>
<cfif ListLen(get_default_departments.ORDER_PAGE_AUTHORITY)>
	<cfset respon = 12/ListLen(get_default_departments.ORDER_PAGE_AUTHORITY)>
</cfif>
<div class="display_area">	
	<cfif ListLen(get_default_departments.ORDER_PAGE_AUTHORITY) and ListFind(get_default_departments.ORDER_PAGE_AUTHORITY,1)>
 	<div class="col col-<cfoutput>#respon#</cfoutput> col-md-3 col-sm-6 col-xs-12">
    	<div class="dashboard-stat2">
        	<div class="display">
            	<div class="number">
                	<h4 class="font-red-haze">
                    	<span data-counter="counterup"><cfoutput>#Get_Intermediate_Store_Pallets.recordcount#</cfoutput></span>
                       	<small class="font-red-haze"></small>
                   	</h4>
                   	<small>TRANSFER DEPO EMİRLERİ</small>
               	</div>
            	<div class="icon">
                	 <img src="css/assets/icons/catalyst-icon-svg/ctl-trucking.svg" width="30px" height="50px">
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
                                    <th>Barkod</th>
                                    <th>Palet Tip</th>
                                    <th>Tarih-Saat</th>
                                    <th>Depo</th>
                                    <th>PK.</th>
                                    
                                </tr>
                            </thead>
                            <tbody>
								<cfif Get_Intermediate_Store_Pallets.recordcount>
                                    <cfoutput query="Get_Intermediate_Store_Pallets">
                                    	<tr>
                                        	<td style="text-align:right">#currentrow#</td>
                                         	<td style="text-align:center">#BARCODE#</td>   
                                            <td style="text-align:left">#PACKING_SIZE_TYPE_CODE#</td> 
                                            <td style="text-align:right">#DateFormat(PROCESS_DATE,dateformat_style)# #TimeFormat(PROCESS_DATE,'hh:mm')#</td>
                                            <td style="text-align:left">#Evaluate('DEPARTMENT_HEAD_#Replace(DEPO,'-','_')#')#</td>
                                            <td style="text-align:center">#SAYI#</td> 
                                        </tr>
                                    </cfoutput>
                                </cfif>
                            </tbody>
                        </cf_grid_list>
                    </cf_box>
               	</div>
       		</div>
      	</div>
	</div>  
    </cfif>
    <cfif ListLen(get_default_departments.ORDER_PAGE_AUTHORITY) and ListFind(get_default_departments.ORDER_PAGE_AUTHORITY,2)>
	<div class="col col-<cfoutput>#respon#</cfoutput> col-md-3 col-sm-6 col-xs-12">
    	<div class="dashboard-stat2">
        	<div class="display">
            	<div class="number">
                	<h4 class="font-blue-sharp">
                    	<span data-counter="counterup"><cfoutput>#Get_Transfer_Store_Pallets.recordcount#</cfoutput></span>
                       	<small class="font-red-haze"></small>
                   	</h4>
                   	<small>STOKLAMA RAF EMİRLERİ</small>
               	</div>
            	<div class="icon">
                 	<img src="css/assets/icons/catalyst-icon-svg/ctl-016-loader.svg" width="40px" height="55px">
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
                                    <th>Barkod</th>
                                    <th>Palet Tip</th>
                                    <th>Tarih-Saat</th>
                                    <th>Transfer Alanı</th>
                                    <th>PK.</th>
                                </tr>
                            </thead>
                            <tbody>
								<cfif Get_Transfer_Store_Pallets.recordcount>
                                    <cfoutput query="Get_Transfer_Store_Pallets">
                                    	<tr>
                                        	<td style="text-align:right">#currentrow#</td>
                                         	<td style="text-align:center">#BARCODE#</td>   
                                            <td style="text-align:left">#PACKING_SIZE_TYPE_CODE#</td> 
                                            <td style="text-align:right">#DateFormat(PROCESS_DATE,dateformat_style)# #TimeFormat(PROCESS_DATE,'hh:mm')#</td>
                                            <td style="text-align:center">#SHELF_CODE#</td>
                                            <td style="text-align:center">#SAYI#</td>
                                        </tr>
                                    </cfoutput>
                                </cfif>
                            </tbody>
                        </cf_grid_list>
                    </cf_box>
               	</div>
       		</div>
      	</div>
	</div>
    </cfif>
    <cfif ListLen(get_default_departments.ORDER_PAGE_AUTHORITY) and ListFind(get_default_departments.ORDER_PAGE_AUTHORITY,3)>
    <div class="col col-<cfoutput>#respon#</cfoutput> col-md-3 col-sm-6 col-xs-12">
    	<div class="dashboard-stat2">
        	<div class="display">
            	<div class="number">
                	<h4 class="font-blue-sharp">
                    	<span data-counter="counterup"><cfoutput>#Get_Transfer_Pallets_To_Collect_Shelf_group.recordcount#</cfoutput></span>
                       	<small class="font-red-haze"></small>
                   	</h4>
                   	<small>TOPLAMA RAF EMİRLERİ</small>
               	</div>
            	<div class="icon">
                 	<img src="css/assets/icons/catalyst-icon-svg/ctl-016-loader.svg" width="40px" height="55px">
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
                                    <th>Toplama Rafı</th>
                                    <th>Miktar</th>
                                    <th>Raf Tip</th>
                                    <th>Stoklama Rafı</th>
                                </tr>
                            </thead>
                            <tbody>
								<cfif Get_Transfer_Pallets_To_Collect_Shelf_group.recordcount>
                                    <cfoutput query="Get_Transfer_Pallets_To_Collect_Shelf_group">
                                    	<cfquery name="get_detail" dbtype="query">
                                        	SELECT
                                            	NEW_SHELF_CODE,
                                                YAKINLIK
                                           	FROM
                                            	Get_Transfer_Pallets_To_Collect_Shelf
                                          	WHERE
                                            	SHELF_CODE = '#Get_Transfer_Pallets_To_Collect_Shelf_group.SHELF_CODE#'	
                                          	ORDER BY
                                            	YAKINLIK
                                        </cfquery>
                                    	<tr>
                                        	<td style="text-align:right">#currentrow#</td>
                                         	<td style="text-align:center">#SHELF_CODE#</td> 
                                            <td style="text-align:center">#READY_AMOUNT#</td>  
                                            <td style="text-align:left">#SHELF_SIZE_TYPE_CODE#</td> 
                                            <td style="text-align:center">
                                            	<cfloop query="get_detail" startrow="1" endrow="5">
                                            		#NEW_SHELF_CODE#<cfif get_detail.currentrow lt get_detail.recordcount><br/></cfif>
                                            	</cfloop>
                                            </td>
                                        </tr>
                                    </cfoutput>
                                </cfif>
                            </tbody>
                        </cf_grid_list>
                    </cf_box>
               	</div>
       		</div>
      	</div>
	</div>
    </cfif>
    <cfif ListLen(get_default_departments.ORDER_PAGE_AUTHORITY) and ListFind(get_default_departments.ORDER_PAGE_AUTHORITY,4)>
    <div class="col col-<cfoutput>#respon#</cfoutput> col-md-3 col-sm-6 col-xs-12">
    	<div class="dashboard-stat2">
         	<div class="display">
             	<div class="number">
                  	<h4 class="font-green-sharp">
                      	<span data-counter="counterup"><cfoutput>#Get_Transfer_Pallets_To_Shipment.recordcount#</cfoutput></span>
                 		<small class="font-green-sharp"></small>
                  	</h4>
                 	<small>SEVKİYAT EMİRLERİ</small>
             	</div>
           		<div class="icon">
                    <img src="css/assets/icons/catalyst-icon-svg/ctl-packing-2.svg" width="30px" height="50px">
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
                                    <th>Sevk No</th>
                                    <th>Müşteri/Şube</th>
                                    <th>Sevk Alanı</th>
                                    <th>PK.</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
								<cfif Get_Transfer_Pallets_To_Shipment.recordcount>
                                	<cfquery name="get_plan_id" dbtype="query">
                                        SELECT SHIP_RESULT_ID FROM Get_Transfer_Pallets_To_Shipment WHERE IS_TYPE =1
                                    </cfquery>
                                    <cfset sevk_plan_id_list = ValueList(get_plan_id.SHIP_RESULT_ID)>
                                    <cfquery name="get_plan_id" dbtype="query">
                                        SELECT SHIP_RESULT_ID FROM Get_Transfer_Pallets_To_Shipment WHERE IS_TYPE =2
                                    </cfquery>
                                    <cfset sevk_talep_id_list = ValueList(get_plan_id.SHIP_RESULT_ID)>
                                    <cfif ListLen(sevk_plan_id_list)>
                                    	<cfquery name="GET_PLAN_SEVK" datasource="#DSN3#">
                 							SELECT     
                                                ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
                                                ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT,
                                                SHIP_RESULT_ID
                                            FROM         
                                                (
                                                SELECT     
                                                    PAKET_SAYISI AS PAKETSAYISI, 
                                                    PAKET_ID AS STOCK_ID, 
                                                    BARCOD, 
                                                    STOCK_CODE, 
                                                    PRODUCT_NAME,
                                                    SHIP_RESULT_ID,
                                                    (
                                                    SELECT     
                                                        SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                                                    FROM          
                                                        EZGI_SHIPPING_PACKAGE_LIST WITH (NOLOCK)
                                                    WHERE      
                                                        TYPE = 1 AND 
                                                        STOCK_ID = TBL.PAKET_ID AND 
                                                        SHIPPING_ID = TBL.SHIP_RESULT_ID
                                                    ) AS CONTROL_AMOUNT
                                                FROM         
                                                    (
                                                    SELECT
                                                        SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                                                        PAKET_ID, 
                                                        BARCOD, 
                                                        STOCK_CODE, 
                                                        PRODUCT_NAME, 
                                                        PRODUCT_TREE_AMOUNT, 
                                                        SHIP_RESULT_ID
                                                    FROM
                                                        (     
                                                        SELECT     
                                                            round(SUM(ORR.QUANTITY * EPS.PAKET_SAYISI),2) AS PAKET_SAYISI, 
                                                            EPS.PAKET_ID, 
                                                            S.BARCOD, 
                                                            S.STOCK_CODE, 
                                                            S.PRODUCT_NAME, 
                                                            S.PRODUCT_TREE_AMOUNT, 
                                                            ESR.SHIP_RESULT_ID,
                                                            ESRR.ORDER_ROW_ID
                                                        FROM 
                                                            SPECTS AS SP WITH (NOLOCK) INNER JOIN
                                                            EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
                                                            EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                                                            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                                                            STOCKS AS S WITH (NOLOCK) INNER JOIN
                                                            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID INNER JOIN
                                                            STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID   
                                                        WHERE      
                                                            ESR.SHIP_RESULT_ID IN (#sevk_plan_id_list#) AND
                                                            ISNULL(S1.IS_PROTOTYPE,0) = 1
                                                        GROUP BY 
                                                            EPS.PAKET_ID, 
                                                            S.BARCOD, 
                                                            S.STOCK_CODE, 
                                                            S.PRODUCT_NAME, 
                                                            S.PRODUCT_TREE_AMOUNT, 
                                                            ESR.SHIP_RESULT_ID,
                                                            ESRR.ORDER_ROW_ID
                                                        UNION ALL
                                                        SELECT     
                                                            round(SUM(ORR.QUANTITY * EPS.PAKET_SAYISI),2) AS PAKET_SAYISI, 
                                                            EPS.PAKET_ID, 
                                                            S.BARCOD, 
                                                            S.STOCK_CODE, 
                                                            S.PRODUCT_NAME, 
                                                            S.PRODUCT_TREE_AMOUNT, 
                                                            ESR.SHIP_RESULT_ID,
                                                            ESRR.ORDER_ROW_ID
                                                        FROM          
                                                            EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
                                                            EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                                                            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                                            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                                                            STOCKS AS S WITH (NOLOCK) ON EPS.PAKET_ID = S.STOCK_ID INNER JOIN
                                                            STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID
                                                        WHERE      
                                                            ESR.SHIP_RESULT_ID IN (#sevk_plan_id_list#) AND
                                                            ISNULL(S1.IS_PROTOTYPE,0) = 0
                                                        GROUP BY 
                                                            EPS.PAKET_ID, 
                                                            S.BARCOD, 
                                                            S.STOCK_CODE, 
                                                            S.PRODUCT_NAME, 
                                                            S.PRODUCT_TREE_AMOUNT, 
                                                            ESR.SHIP_RESULT_ID,
                                                            ESRR.ORDER_ROW_ID
                                                        ) AS TBL1
                                                    GROUP BY
                                                        PAKET_ID, 
                                                        BARCOD, 
                                                        STOCK_CODE, 
                                                        PRODUCT_NAME,
                                                        PRODUCT_TREE_AMOUNT, 
                                                        SHIP_RESULT_ID
                                                    ) AS TBL
                                                ) AS TBL2
                                         	GROUP BY
                                            	SHIP_RESULT_ID
                						</cfquery>
                                  	<cfelse>
										<cfset GET_PLAN_SEVK.recordcount =0>
                                    </cfif>
                                    <cfif ListLen(sevk_talep_id_list)>
                                    	<cfquery name="GET_TALEP_SEVK" datasource="#DSN3#">
                							SELECT     
                                                ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
                                                ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT,
                                                SHIP_RESULT_ID
                                            FROM         
                                                (		
                                                SELECT     
                                                    PAKET_SAYISI AS PAKETSAYISI, 
                                                    PAKET_ID AS STOCK_ID, 
                                                    BARCOD, 
                                                    STOCK_CODE, 
                                                    PRODUCT_NAME,
                                                    SHIP_RESULT_ID,
                                                    (
                                                    SELECT     
                                                        SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                                                    FROM          
                                                        EZGI_SHIPPING_PACKAGE_LIST WITH (NOLOCK)
                                                    WHERE      
                                                        TYPE = 2 AND 
                                                        STOCK_ID = TBL.PAKET_ID AND 
                                                        SHIPPING_ID = TBL.SHIP_RESULT_ID
                                                    ) AS CONTROL_AMOUNT
                                                FROM         
                                                    (
                                                    SELECT     
                                                        SUM(PAKET_SAYISI) AS PAKET_SAYISI, 
                                                        PAKET_ID, 
                                                        BARCOD, 
                                                        STOCK_CODE, 
                                                        PRODUCT_NAME, 
                                                        SHIP_RESULT_ID
                                                    FROM          
                                                        (
                                                        SELECT     
                                                            round(SUM(ORR.QUANTITY * EPS.PAKET_SAYISI),2) AS PAKET_SAYISI, 
                                                            EPS.PAKET_ID, 
                                                            S.BARCOD, 
                                                            S.STOCK_CODE, 
                                                            S.PRODUCT_NAME, 
                                                            S.PRODUCT_TREE_AMOUNT, 
                                                            ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
                                                            ESRR.ORDER_ROW_ID
                                                        FROM 
                                                            SPECTS AS SP WITH (NOLOCK) INNER JOIN
                                                            EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
                                                            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                                                            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                                                            STOCKS AS S WITH (NOLOCK) INNER JOIN
                                                            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID INNER JOIN
                                                            STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID   
                                                        WHERE      
                                                            ESR.SHIP_RESULT_INTERNALDEMAND_ID IN (#sevk_plan_id_list#) AND
                                                            ISNULL(S1.IS_PROTOTYPE,0) = 1
                                                        GROUP BY 
                                                            EPS.PAKET_ID, 
                                                            S.BARCOD, 
                                                            S.STOCK_CODE, 
                                                            S.PRODUCT_NAME, 
                                                            S.PRODUCT_TREE_AMOUNT, 
                                                            ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                                                            ESRR.ORDER_ROW_ID
                                                        UNION ALL
                                                        SELECT     
                                                            round(SUM(ORR.QUANTITY * EPS.PAKET_SAYISI),2) AS PAKET_SAYISI, 
                                                            EPS.PAKET_ID, 
                                                            S.BARCOD, 
                                                            S.STOCK_CODE, 
                                                            S.PRODUCT_NAME, 
                                                            S.PRODUCT_TREE_AMOUNT, 
                                                            ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
                                                            ESRR.ORDER_ROW_ID
                                                        FROM          
                                                            EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
                                                            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                                                            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                                            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                                                            STOCKS AS S WITH (NOLOCK) ON EPS.PAKET_ID = S.STOCK_ID INNER JOIN
                                                            STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID
                                                        WHERE      
                                                            ESR.SHIP_RESULT_INTERNALDEMAND_ID IN (#sevk_plan_id_list#) AND
                                                            ISNULL(S1.IS_PROTOTYPE,0) = 0
                                                        GROUP BY 
                                                            EPS.PAKET_ID, 
                                                            S.BARCOD, 
                                                            S.STOCK_CODE, 
                                                            S.PRODUCT_NAME, 
                                                            S.PRODUCT_TREE_AMOUNT, 
                                                            ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                                                            ESRR.ORDER_ROW_ID
                                                        ) AS TBL1
                                                    GROUP BY 
                                                        PAKET_ID, 
                                                        BARCOD, 
                                                        STOCK_CODE, 
                                                        PRODUCT_NAME, 
                                                        SHIP_RESULT_ID
                                                    ) AS TBL
                                                ) AS TBL2
                							GROUP BY
                                            	SHIP_RESULT_ID
        								</cfquery>
                                   	<cfelse>
                                    	<cfset GET_TALEP_SEVK.recordcount =0>
                                    </cfif> 
                                    
                                    
                                    <cfoutput query="Get_Transfer_Pallets_To_Shipment">
                                    	<tr>
                                        	<td style="text-align:right" rowspan="2">#currentrow#</td>
                                         	<td style="text-align:center">#DELIVER_PAPER_NO#</td>   
                                            <td style="text-align:left">
                                            	<cfif IS_TYPE eq 1>
                                                	<cfif LEN(COMPANY_ID)>
                                                    	#get_par_info(COMPANY_ID,1,1,0)#
                                                    <cfelseif Len(CONSUMER_ID)>
                                                    	#get_cons_info(CONSUMER_ID,0,0)#
                                                    </cfif>
                                                <cfelse>
                                                	#DEPARTMENT_HEAD#
                                                </cfif>
                                            </td> 
                                            <td style="text-align:center">#SHELF_CODE#</td>
                                            <cfif IS_TYPE eq 1>    
                     							<cfquery name="PACKEGE_CONTROL" dbtype="query"><!---Sevk Kontrol Indicator için Kalan Bul---> 
                                                    SELECT
                                                        PAKET_SAYISI,
                                                        CONTROL_AMOUNT
                                                    FROM
                                                        GET_PLAN_SEVK
                                                    WHERE     
                                                        SHIP_RESULT_ID = #SHIP_RESULT_ID#
                                                </cfquery>
                                            <cfelse>
                                              	<cfquery name="PACKEGE_CONTROL" dbtype="query"><!---Sevk Kontrol Indicator için Kalan Bul---> 
                                                    SELECT
                                                        PAKET_SAYISI,
                                                        CONTROL_AMOUNT
                                                    FROM
                                                        GET_TALEP_SEVK
                                                    WHERE     
                                                        SHIP_RESULT_ID = #SHIP_RESULT_ID#
                                                </cfquery>  
                                            </cfif>
                                            <td style="text-align:center">
                                            	#PACKEGE_CONTROL.PAKET_SAYISI#
                                            </td>
                                            <td style="text-align:center">
                                             <cfif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI eq 0 and PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                                <img src="/images/plus_ques.gif" border="0" title="<cf_get_lang dictionary_id='29975.Barkod Yok'>">
                                             <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI - PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                                <img src="/images/c_ok.gif" border="0" title="<cf_get_lang dictionary_id='334.Sevk Edildi'>.">
                                             <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                                <img src="/images/caution_small.gif" border="0" title="<cf_get_lang dictionary_id='335.Sevk Edilmedi'>.">
                                             <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI gt PACKEGE_CONTROL.CONTROL_AMOUNT>
                                                <img src="/images/warning.gif" border="0" title="<cf_get_lang dictionary_id='336.Eksik Sevkiyat'>.">
                                             <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI lt PACKEGE_CONTROL.CONTROL_AMOUNT>
                                                <img src="/images/control.gif" border="0" title="<cf_get_lang dictionary_id='337.Fazla Sevkiyat'>">  
                                             </cfif>
                                        	</td>    
                                        </tr>
                                        <tr>
                                        	<td colspan="5" style="font-weight:normal">#UNVAN#</td>
                                        </tr>
                                    </cfoutput>
                                </cfif>
                            </tbody>
                        </cf_grid_list>
                    </cf_box>
             	</div>
          	</div>
     	</div>
 	</div>  
    </cfif> 
</div>
<script language="javascript">
	pn_kontrol();
	function pn_kontrol()
	{
		geciktir1 = setTimeout("window.location.href='<cfoutput>#request.self#?fuseaction=stock.dashboard_ezgi_wm_orders</cfoutput>'", 100000);
	}
</script>
        
      
        