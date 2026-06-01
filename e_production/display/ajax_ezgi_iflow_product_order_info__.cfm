<!---
    File: ajax_ezgi_iflow_product_order_info.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/10/2025
    Description:
--->
<cfset Total_Main = 0>

<cfparam name="attributes.sort_type" default="10">
<cfset attributes.e_iflow_p_order_id_list = attributes.IFLOW_P_ORDER_ID>
<cfinclude template="../query/get_ezgi_iflow_production_order.cfm">
<cfif get_production_orders.recordcount>
	<cfif get_production_orders.recordcount>
		<cfoutput query="get_production_orders">
			<cfif PRODUCT_TYPE eq 2>
				<cfset Total_Main = Total_Main + QUANTITY>
           	</cfif> <!---Modül Sayısı Hesaplama--->
		</cfoutput>
	</cfif>
	<cfset lot_list = ValueList(get_production_orders.LOT_NO)>
    <cfinclude template="../query/get_ezgi_iflow_production_order_include.cfm">
    <cfif get_modul_amount.recordcount and len(get_modul_amount.MODUL_AMOUNT)>
    	<cfset Total_Main_Result = get_modul_amount.MODUL_AMOUNT>
 	<cfelse>
      	<cfset Total_Main_Result = 0>
	</cfif>
	<cfset Total_Package = get_package_list.PAKET_EMIR>
    <cfset Total_Package_Result = get_package_list.PAKET_URETILEN>
    <cfset Total_Order = get_all_p_order_list.TOTAL_EMIR>
    <cfset Total_Order_Result = get_all_p_order_list.TOTAL_URETILEN>
    <cfset Total_Operation = get_operations_all.TOTAL_AMOUNT>
    <cfif get_operation_result_all.recordcount>
        <cfset Total_Operation_Result = get_operation_result_all.TOTAL_REAL_AMOUNT>
    <cfelse>
        <cfset Total_Operation_Result = 0>
    </cfif>
    <cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
    	<!--- 1. Master plan bilgisi --->
        <cfquery name="get_master_plan" datasource="#dsn3#">
            SELECT  
                MASTER_PLAN_ID,
                MASTER_PLAN_CAT_ID,
                MASTER_PLAN_START_DATE,
                MASTER_PLAN_FINISH_DATE,
                MASTER_PLAN_NUMBER,
                MASTER_PLAN_DETAIL
            FROM EZGI_IFLOW_MASTER_PLAN WITH (NOLOCK)
            WHERE MASTER_PLAN_ID = <cfqueryparam value="#attributes.master_plan_id#" cfsqltype="cf_sql_integer">
        </cfquery>
        <!--- 2. İşletme çalışma saatleri (vardiya) --->
        <cfquery name="get_station_sablon" datasource="#dsn3#">
            SELECT 
                { fn HOUR(START_DATE) } AS START_HOUR,
                { fn HOUR(FINISH_DATE) } AS FINISH_HOUR,
                { fn MINUTE(START_DATE) } AS START_MINUTE,
                { fn MINUTE(FINISH_DATE) } AS FINISH_MINUTE,
                START_DATE,
                FINISH_DATE
            FROM EZGI_MASTER_PLAN_DEFAULTS WITH (NOLOCK)
            WHERE SHIFT_ID = <cfqueryparam value="#get_master_plan.MASTER_PLAN_CAT_ID#" cfsqltype="cf_sql_integer">
        </cfquery>
		<!--- 3. Resmi Tatiller --->
        <cfset startDate = get_master_plan.MASTER_PLAN_START_DATE>
        <cfset endDate   = get_master_plan.MASTER_PLAN_FINISH_DATE>
        
        <cfquery name="get_general_offtime" datasource="#dsn#">
            SELECT
                OFFTIME_NAME,
                START_DATE,
                FINISH_DATE,
                IS_HALFOFFTIME
            FROM SETUP_GENERAL_OFFTIMES WITH (NOLOCK)
            WHERE 
                START_DATE <= <cfqueryparam value="#endDate#" cfsqltype="cf_sql_timestamp">
                AND FINISH_DATE >= <cfqueryparam value="#startDate#" cfsqltype="cf_sql_timestamp">
        </cfquery>
        
        
        <!--- 4. Çalışma Süresi Hesaplama Fonksiyonu --->
        
		<cfscript>

			function calculateWorkSeconds(
				startDate,
				endDate,
				shiftStartH,
				shiftStartM,
				shiftEndH,
				shiftEndM,
				holidaysQuery
			) {
				var totalSeconds = 0;
			
				var shiftStartTime = shiftStartH & ":" & shiftStartM & ":00";
				var shiftEndTime   = shiftEndH & ":" & shiftEndM & ":00";
			
				// Tarih objelerine dönüştür
				var currentDayDate = parseDateTime(dateFormat(startDate, "yyyy-mm-dd") & " 00:00:00");
				var lastDayDate    = parseDateTime(dateFormat(endDate, "yyyy-mm-dd") & " 00:00:00");
			
				function isHoliday(dayDate, holidaysQuery) {
					var dStart = parseDateTime(dateFormat(dayDate, "yyyy-mm-dd") & " 00:00:00");
					var dEnd   = parseDateTime(dateFormat(dayDate, "yyyy-mm-dd") & " 23:59:59");
			
					for (row in holidaysQuery) {
						if ( row.START_DATE <= dEnd AND row.FINISH_DATE >= dStart ) {
							return row;
						}
					}
					return false;
				}
			
				// --- ASIL DÖNGÜ ---
				while ( dateCompare(currentDayDate, lastDayDate) LTE 0 ) {
			
					var currentDayStr = dateFormat(currentDayDate, "yyyy-mm-dd");
			
					// Hafta sonu
					if (dayOfWeek(currentDayDate) EQ 7 OR dayOfWeek(currentDayDate) EQ 1) {
						currentDayDate = dateAdd("d", 1, currentDayDate);
						continue;
					}
			
					// Tatil kontrolü
					var holidayInfo = isHoliday(currentDayDate, holidaysQuery);
			
					if (holidayInfo != false) {
						// Yarım gün
						if (holidayInfo.IS_HALFOFFTIME == 1) {
							var fullShiftStart = parseDateTime(currentDayStr & " " & shiftStartTime);
							var fullShiftEnd   = parseDateTime(currentDayStr & " " & shiftEndTime);
							totalSeconds += dateDiff("s", fullShiftStart, fullShiftEnd) / 2;
						}
			
						// Tam tatil ise atla
						currentDayDate = dateAdd("d", 1, currentDayDate);
						continue;
					}
			
					// Normal çalışma günü
					var dayShiftStart = parseDateTime(currentDayStr & " " & shiftStartTime);
					var dayShiftEnd   = parseDateTime(currentDayStr & " " & shiftEndTime);
			
					// İlk gün
					if ( currentDayStr EQ dateFormat(startDate, "yyyy-mm-dd") AND startDate GT dayShiftStart ) {
						dayShiftStart = startDate;
					}
			
					// Son gün
					if ( currentDayStr EQ dateFormat(endDate, "yyyy-mm-dd") AND endDate LT dayShiftEnd ) {
						dayShiftEnd = endDate;
					}
			
					if (dayShiftEnd GT dayShiftStart) {
						totalSeconds += dateDiff("s", dayShiftStart, dayShiftEnd);
					}
			
					currentDayDate = dateAdd("d", 1, currentDayDate);
				}
			
				return totalSeconds;
			}
			
		</cfscript>
        
        <!--- 5. Fonksiyonu çağırıyoruz --->
        
        <cfset workSeconds = calculateWorkSeconds(
            startDate,
            endDate,
            get_station_sablon.START_HOUR,
            get_station_sablon.START_MINUTE,
            get_station_sablon.FINISH_HOUR,
            get_station_sablon.FINISH_MINUTE,
            get_general_offtime
        )>
    </cfif>
    <div class="col col-12 col-xs-12">
    	<div class="col col-6 col-xs-12">
            <cf_box>
                <cf_grid_list>
                    <cfoutput>
                        <thead>
                            <tr>
                                <th style=" text-align:center; font-size:14px; height:15px" colspan="5">Genel Bakış</th> 
                            </tr>
                            <tr valign="middle">
                                <th style=" height:20px; width:10%"></th>
                                <th style=" text-align:center; width:22%;">Modül</th>
                                <th style=" text-align:center; width:22%; font-size:12px">Paket</th>
                                <th style=" text-align:center; width:22%; font-size:12px">İş Emri</th>
                                <th style=" text-align:center; width:24%; font-size:12px">Operasyon</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td style=" text-align:left; font-weight:bold">Toplam</td>
                                <td style=" text-align:center; font-weight:normal">#TlFormat(Total_Main,0)#</td>
                                <td style=" text-align:center; font-weight:normal">#TlFormat(Total_Package,0)#</td>
                                <td style=" text-align:center; font-weight:normal">#TlFormat(Total_Order,0)#</td>
                                <td style=" text-align:center; font-weight:normal">#TlFormat(Total_Operation,0)#</td>
                            </tr>
                            <tr>
                                <td style=" text-align:left; font-weight:bold">Tamamlanan</td>
                                <td style=" text-align:center; font-weight:normal">#TlFormat(Total_Main_Result,0)#</td>
                                <td style=" text-align:center; font-weight:normal">#TlFormat(Total_Package_Result,0)#</td>
                                <td style=" text-align:center; font-weight:normal">#TlFormat(Total_Order_Result,0)#</td>
                                <td style=" text-align:center; font-weight:normal">#TlFormat(Total_Operation_Result,0)#</td>
                            </tr>
                            <tr>
                                <td style=" text-align:left; font-weight:bold">Oran</td>
                                <td style="text-align:center" height="180px">
                                    <cfset graph_type = "pie">
                                     <cfchart show3d="no" labelformat="number" format="jpg" chartheight="180" chartwidth="180" showlegend="false"> 
                                        <cfchartseries type="#graph_type#" itemcolumn="graph1">
                                            <cfsavecontent variable="biten">Gerçekleşen</cfsavecontent>
                                            <cfsavecontent variable="kalan">Kalan</cfsavecontent>
                                            <cfchartdata item="#biten#" value="#Total_Main_Result#">
                                            <cfchartdata item="#kalan#" value="#Total_Main-Total_Main_Result#">
                                        </cfchartseries>
                                    </cfchart>
                                </td>
                                <td style="text-align:center" height="180px">
                                    <cfset graph_type = "pie">
                                     <cfchart show3d="no" labelformat="number" format="jpg" chartheight="180" chartwidth="180" showlegend="false"> 
                                        <cfchartseries type="#graph_type#" itemcolumn="graph2">
                                            <cfsavecontent variable="biten">Gerçekleşen</cfsavecontent>
                                            <cfsavecontent variable="kalan">Kalan</cfsavecontent>
                                            <cfchartdata item="#biten#" value="#Total_Package_Result#">
                                            <cfchartdata item="#kalan#" value="#Total_Package-Total_Package_Result#">
                                        </cfchartseries>
                                    </cfchart>
                                </td>
                                <td style="text-align:center" height="180px">
                                    <cfset graph_type = "pie">
                                     <cfchart show3d="no" labelformat="number" format="jpg" chartheight="180" chartwidth="180" showlegend="false"> 
                                        <cfchartseries type="#graph_type#" itemcolumn="graph3">
                                            <cfsavecontent variable="biten">Gerçekleşen</cfsavecontent>
                                            <cfsavecontent variable="kalan">Kalan</cfsavecontent>
                                            <cfchartdata item="#biten#" value="#Total_Order_Result#">
                                            <cfchartdata item="#kalan#" value="#Total_Order-Total_Order_Result#">
                                        </cfchartseries>
                                    </cfchart>
                                </td>
                                <td style="text-align:center" height="180px">
                                    <cfset graph_type = "pie">
                                     <cfchart show3d="no" labelformat="number" format="png" chartheight="180" chartwidth="180" showlegend="false"> 
                                        <cfchartseries type="#graph_type#" itemcolumn="graph4">
                                            <cfsavecontent variable="biten">Gerçekleşen</cfsavecontent>
                                            <cfsavecontent variable="kalan">Kalan</cfsavecontent>
                                            <cfchartdata item="#biten#" value="#Total_Operation_Result#">
                                            <cfchartdata item="#kalan#" value="#Total_Operation-Total_Operation_Result#">
                                        </cfchartseries>
                                    </cfchart>
                                </td>
                            </tr>
                        </tbody>
                    </cfoutput>
                </cf_grid_list>
            </cf_box>
        </div>
        <div class="col col-6 col-xs-12">
            <cf_box>
                <cf_grid_list>
                    <cfoutput>
                        <thead>
                        	<tr>
                                <th style=" text-align:center; font-size:14px; height:15px" colspan="11">Operasyon Analizi</th>
                            </tr>
                            <tr>
                                <th style=" text-align:center; font-size:12px; height:15px" colspan="7">Planlanan</th>
                                <th style=" text-align:center; font-size:12px;" colspan="4">Gerçekleşen</th> 
                            </tr>
                            <tr valign="middle">
                                <th style=" width:20px; text-align:right">No</th>
                                <th style=" text-align:center;">Operasyon</th>
                                <th style=" text-align:center;">İstasyon</th>
                                <th style=" text-align:center;">Çalışan</th>
                                <th style=" text-align:center;">Miktar</th>
                                <th style=" text-align:center;">B.Süre</th>
                                <th style=" text-align:center;">T.Süre</th>
                                
                                <th style=" text-align:center;">Miktar</th>
                                <th style=" text-align:center;">T.Süre</th>
                                <th style=" text-align:center;">O.Süre</th>
                                <th style=" text-align:center;">Verimlilik</th>
                            </tr>
                        </thead>
                        <tbody>
                        	<cfif get_operations_group.recordcount>
                            	<cfloop query="get_operations_group">
                                	<cfquery name="get_result" dbtype="query">
                                    	SELECT
                                            SUM(REAL_AMOUNT) AS REAL_AMOUNT, 
                                            SUM(LOSS_AMOUNT) AS LOSS_AMOUNT, 
                                            SUM(REAL_TIME) AS  REAL_TIME, 
                                            SUM(WAIT_TIME) AS WAIT_TIME
                                        FROM
                                        	get_operation_result
                                      	WHERE
                                        	OPERATION_TYPE_ID = #get_operations_group.OPERATION_TYPE_ID#
                                    </cfquery>
                                    <tr>
                                    	<td style=" text-align:right; font-weight:bold">#currentrow#</td>
                                        <td style=" text-align:left; font-weight:bold">#OPERATION_TYPE#</td>
                                        <td style=" text-align:center; font-weight:normal">#TlFormat(STATION_COUNT,0)#</td>
                                        <td style=" text-align:center; font-weight:normal">#TlFormat(TOTAL_EMPLOYEE_NUMBER,0)#</td>
                                        <td style=" text-align:center; font-weight:normal">#TlFormat(TOTAL_AMOUNT,0)#</td>
                                        <td style=" text-align:center; font-weight:normal">#TlFormat(TOTAL_OPTIMUM_TIME/TOTAL_AMOUNT,0)#</td>
                                        <td style=" text-align:center; font-weight:normal">#TlFormat(TOTAL_OPTIMUM_TIME,0)#</td>
                                        
                                        <td style=" text-align:center; font-weight:normal">#TlFormat(get_result.REAL_AMOUNT,0)#</td>
                                        <td style=" text-align:center; font-weight:normal">#TlFormat(get_result.REAL_TIME,0)#</td>
                                        <td style=" text-align:center; font-weight:normal">
                                        	<cfif get_result.REAL_AMOUNT gt 0 and get_result.REAL_TIME gt 0>
                                        		#TlFormat(get_result.REAL_TIME/get_result.REAL_AMOUNT,0)#
                                        	<cfelse>
                                            	#TlFormat(0,0)#
                                            </cfif>
                                        </td>
                                        <td style=" text-align:center; font-weight:normal"></td>
                                    </tr>
                            	</cfloop>
                            <cfelse>
                            	<tr>
                                	<td colspan="11">Kayıt Yok</td>
                                </tr>
                            </cfif>
                      	</tbody>
                    </cfoutput>
                </cf_grid_list>
            </cf_box>
        </div>
    </div>
	<div class="col col-12 col-xs-12">
    	<div class="col col-6 col-xs-12">
            <cf_box>
                <cf_grid_list>
                    <cfoutput>
                        <thead>
                        	<tr>
                                <th style=" text-align:center; font-size:14px; height:15px" colspan="9">İstasyon Analizi</th>
                            </tr>
                            <tr>
                                <th style=" text-align:center; font-size:12px; height:15px" colspan="6">Planlanan</th>
                                <th style=" text-align:center; font-size:12px;" colspan="3">Gerçekleşen</th> 
                            </tr>
                            <tr valign="middle">
                                <th style=" width:20px; text-align:right">No</th>
                                <th style=" text-align:center;">İstasyon</th>
                                <th style=" text-align:center;">Çalışan</th>
                                <th style=" text-align:center;">Miktar</th>
                                <th style=" text-align:center;">Beklenen Süre</th>
                                <th style=" text-align:center;">Katsayı</th>
                                
                                <th style=" text-align:center;">Miktar</th>
                                <th style=" text-align:center;">Gerçekleşen Süre</th>
                                <th style=" text-align:center;">Verimlilik</th>
                            </tr>
                        </thead>
                        <tbody>
                        	<cfif get_operations_group.recordcount>
                            	<cfloop query="get_workstation_group">
                                	<cfif len(get_workstation_group.STATION_ID)>
                                        <cfquery name="get_result" dbtype="query">
                                            SELECT
                                                SUM(REAL_AMOUNT) AS REAL_AMOUNT, 
                                                SUM(LOSS_AMOUNT) AS LOSS_AMOUNT, 
                                                SUM(REAL_TIME) AS  REAL_TIME, 
                                                SUM(WAIT_TIME) AS WAIT_TIME
                                            FROM
                                                get_operation_result
                                            WHERE
                                                STATION_ID = #get_workstation_group.STATION_ID#
                                        </cfquery>
                                        <tr>
                                            <td style=" text-align:right; font-weight:bold">#currentrow#</td>
                                            <td style=" text-align:left; font-weight:bold">#STATION_NAME#</td>
                                            <td style=" text-align:center; font-weight:normal">#TlFormat(EMPLOYEE_NUMBER,0)#</td>
                                            <td style=" text-align:center; font-weight:normal">#TlFormat(TOTAL_AMOUNT,0)#</td>
                                            <td style=" text-align:center; font-weight:normal">#TlFormat(TOTAL_OPTIMUM_TIME,0)#</td>
                                            <td style=" text-align:center; font-weight:normal">#TlFormat(EZGI_KATSAYI,2)#</td>
                                            
                                            <td style=" text-align:center; font-weight:normal">#TlFormat(get_result.REAL_AMOUNT,0)#</td>
                                            <td style=" text-align:center; font-weight:normal">#TlFormat(get_result.REAL_TIME,0)#</td>
                                            <td style=" text-align:center; font-weight:normal"></td>
                                        </tr>
                                    </cfif>
                            	</cfloop>
                            <cfelse>
                            	<tr>
                                	<td colspan="9">Kayıt Yok</td>
                                </tr>
                            </cfif>
                      	</tbody>
                    </cfoutput>
                </cf_grid_list>
            </cf_box>
        </div>
        
        <div class="col col-6 col-xs-12">
            <cf_box>
                <cf_grid_list>
                    <cfoutput>
                        <thead>
                        	<tr>
                                <th style=" text-align:center; font-size:14px; height:15px" colspan="8">İstasyon Doluluk Oranları</th>
                            </tr>
                            <tr>
                                <th style=" text-align:center; font-size:12px; height:15px" colspan="4">Planlanan</th>
                                <th style=" text-align:center; font-size:12px;" colspan="6">Kapasite</th> 
                            </tr>
                            <tr valign="middle">
                                <th style=" width:20px; text-align:right">No</th>
                                <th style=" text-align:center;">İstasyon</th>
                                <th style=" text-align:center;">Çalışan</th>
                                <th style=" text-align:center;">Süre (Sn.)</th>
                                
                                <th style=" text-align:center;">Süre (Sn.)</th>
                                <th style=" text-align:center;">Katsayı</th>
                                <th style=" text-align:center;">Net Zaman (Sn.)</th>
                                <th style=" text-align:center;">Oran</th>
                            </tr>
                        </thead>
                        <tbody>
                        	<cfif get_operations_group.recordcount>
                            	<cfloop query="get_workstation_group">
                                	<cfif len(get_workstation_group.STATION_ID)>

                                        <tr>
                                            <td style=" text-align:right; font-weight:bold">#currentrow#</td>
                                            <td style=" text-align:left; font-weight:bold">#STATION_NAME#</td>
                                            <td style=" text-align:center; font-weight:normal">#TlFormat(EMPLOYEE_NUMBER,0)#</td>
                                            <td style=" text-align:center; font-weight:normal">#TlFormat(TOTAL_OPTIMUM_TIME,0)#</td>
                                            
                                            <td style=" text-align:center; font-weight:normal">#workSeconds#</td>
                                            <td style=" text-align:center; font-weight:normal">#EZGI_KATSAYI#</td>
                                            <td style=" text-align:center; font-weight:normal">#workSeconds*EZGI_KATSAYI#</td>
                                            <td style=" text-align:center; font-weight:normal">
												<cfif TOTAL_OPTIMUM_TIME gt 0 and workSeconds gt 0 and EZGI_KATSAYI gt 0>
                                                    #TlFormat((TOTAL_OPTIMUM_TIME/workSeconds*EZGI_KATSAYI)*100,2)#
                                                <cfelse>
                                                	#TlFormat(0,2)#
                                                </cfif>
                                            </td>
                                        </tr>
                                    </cfif>
                            	</cfloop>
                            <cfelse>
                            	<tr>
                                	<td colspan="8">Kayıt Yok</td>
                                </tr>
                            </cfif>
                      	</tbody>
                    </cfoutput>
                </cf_grid_list>
            </cf_box>
        </div>
 	</div>
<cfelse>
	Kayıt Yok.
</cfif>