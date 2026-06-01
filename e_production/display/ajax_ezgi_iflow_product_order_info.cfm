<!---
    File: ajax_ezgi_iflow_product_order_info.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Description: Kurumsal dashboard tasarımı
--->

<cfset Total_Main = 0>
<cfset Total_Package = 0>
<cfset Total_Package_Result = 0>
<cfset Total_Order          = 0>
<cfset Total_Order_Result   = 0>
<cfset Total_Operation = 0>

<cfparam name="attributes.sort_type" default="10">
<cfset attributes.e_iflow_p_order_id_list = attributes.IFLOW_P_ORDER_ID>
<cfinclude template="../query/get_ezgi_iflow_production_order.cfm">

<!-- Kurumsal dashboard CSS -->
<link rel="stylesheet" type="text/css" href="/AddOns/ezgi/css/ezgi.css">
<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<cfif get_production_orders.recordcount>

    <!-- Modül sayısı hesaplama -->
    <cfoutput query="get_production_orders">
        <cfif PRODUCT_TYPE eq 2>
            <cfset Total_Main = Total_Main + QUANTITY>
        </cfif>
    </cfoutput>

    <cfset lot_list = ValueList(get_production_orders.LOT_NO)>
    <cfinclude template="../query/get_ezgi_iflow_production_order_include.cfm">

    <cfif get_modul_amount.recordcount and len(get_modul_amount.MODUL_AMOUNT)>
        <cfset Total_Main_Result = get_modul_amount.MODUL_AMOUNT>
    <cfelse>
        <cfset Total_Main_Result = 0>
    </cfif>
	<cfif get_package_list.recordcount>
		<cfset Total_Package        = get_package_list.PAKET_EMIR>
        <cfset Total_Package_Result = get_package_list.PAKET_URETILEN>
    </cfif>
    <cfif get_all_p_order_list.recordcount>
		<cfset Total_Order          = get_all_p_order_list.TOTAL_EMIR>
        <cfset Total_Order_Result   = get_all_p_order_list.TOTAL_URETILEN>
    </cfif>
    <cfif get_operations_all.recordcount>
    	<cfset Total_Operation      = get_operations_all.TOTAL_AMOUNT>
    </cfif>

    <cfif get_operation_result_all.recordcount>
        <cfset Total_Operation_Result = get_operation_result_all.TOTAL_REAL_AMOUNT>
    <cfelse>
        <cfset Total_Operation_Result = 0>
    </cfif>

    <!-- Master plan / vardiya / resmi tatil & çalışma süresi -->
    <cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
        <!-- 1. Master plan bilgisi -->
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

        <!-- 2. İşletme çalışma saatleri (vardiya) -->
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

        <!-- 3. Resmi Tatiller -->
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

        <!-- 4. Çalışma Süresi Hesaplama Fonksiyonu -->
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
                        if (holidayInfo.IS_HALFOFFTIME == 1) {
                            var fullShiftStart = parseDateTime(currentDayStr & " " & shiftStartTime);
                            var fullShiftEnd   = parseDateTime(currentDayStr & " " & shiftEndTime);
                            totalSeconds += dateDiff("s", fullShiftStart, fullShiftEnd) / 2;
                        }

                        currentDayDate = dateAdd("d", 1, currentDayDate);
                        continue;
                    }

                    var dayShiftStart = parseDateTime(currentDayStr & " " & shiftStartTime);
                    var dayShiftEnd   = parseDateTime(currentDayStr & " " & shiftEndTime);

                    if ( currentDayStr EQ dateFormat(startDate, "yyyy-mm-dd") AND startDate GT dayShiftStart ) {
                        dayShiftStart = startDate;
                    }

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

        <!-- 5. Fonksiyonu çağırıyoruz -->
        <cfset workSeconds = calculateWorkSeconds(
            startDate,
            endDate,
            get_station_sablon.START_HOUR,
            get_station_sablon.START_MINUTE,
            get_station_sablon.FINISH_HOUR,
            get_station_sablon.FINISH_MINUTE,
            get_general_offtime
        )>
    <cfelse>
        <cfset workSeconds = 0>
    </cfif>

    <!-- KPI hesaplamaları -->
    <cfset moduleRemaining    = max(Total_Main - Total_Main_Result, 0)>
    <cfset packageRemaining   = max(Total_Package - Total_Package_Result, 0)>
    <cfset orderRemaining     = max(Total_Order - Total_Order_Result, 0)>
    <cfset operationRemaining = max(Total_Operation - Total_Operation_Result, 0)>

    <cfset moduleRate    = (Total_Main GT 0 ? (Total_Main_Result/Total_Main)*100 : 0)>
    <cfset packageRate   = (Total_Package GT 0 ? (Total_Package_Result/Total_Package)*100 : 0)>
    <cfset orderRate     = (Total_Order GT 0 ? (Total_Order_Result/Total_Order)*100 : 0)>
    <cfset operationRate = (Total_Operation GT 0 ? (Total_Operation_Result/Total_Operation)*100 : 0)>

    <div class="ezgi-dashboard">
		<cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
        <!-- GENEL BAKIŞ + KPI KARTLARI -->
            <div class="ezgi-row">
                <div class="ezgi-col-12">
                    <div class="ezgi-card">
                        <div class="ezgi-card-header">
                            <div>
                                <div class="ezgi-card-header-title">Genel Bakış</div>
                                <div class="ezgi-subtitle">
                                    <cfoutput>
                                        Planlanan ve gerçekleşen üretim özet görünümü
                                        <cfif isDefined("get_master_plan.MASTER_PLAN_DETAIL")>
                                            – #get_master_plan.MASTER_PLAN_DETAIL#
                                        </cfif>
                                    </cfoutput>
                                </div>
                            </div>
                            <cfif workSeconds GT 0>
                                <div class="ezgi-subtitle">
                                    <cfset _hours = workSeconds/3600>
                                    <cfset _days  = _hours / 10> <!-- 10 saat/gün varsayımı -->
                                    <cfoutput>
                                        Çalışma süresi: #NumberFormat(_hours,"9.9")# saat · yaklaşık #NumberFormat(_days,"9.9")# iş günü
                                    </cfoutput>
                                </div>
                            </cfif>
                        </div>
                        <div class="ezgi-kpi-grid">
                            <div class="col col-12 col-xs-12">
                            
                                <cfoutput>
                                <!-- Modül -->
                                <div class="col col-3 col-xs-12">
                                <div class="ezgi-kpi-card">
                                    <div>
                                        <div class="ezgi-kpi-title">Modül</div>
                                        <div class="ezgi-kpi-main-value">#TlFormat(Total_Main_Result,0)#</div>
                                        <div class="ezgi-kpi-detail">
                                            Toplam: #TlFormat(Total_Main,0)#<br>
                                            Kalan: #TlFormat(moduleRemaining,0)#
                                        </div>
                                        <div class="ezgi-kpi-percent #moduleRate EQ 0 ? 'zero' : ''#">
                                            #NumberFormat(moduleRate,"99.9")#%
                                        </div>
                                    </div>
                                    <div class="ezgi-kpi-chart-wrapper">
                                        <canvas id="chart-module"></canvas>
                                    </div>
                                </div>
                                </div>
                                
                                <!-- Paket -->
                                <div class="col col-3 col-xs-12">
                                <div class="ezgi-kpi-card">
                                    <div>
                                        <div class="ezgi-kpi-title">Paket</div>
                                        <div class="ezgi-kpi-main-value">#TlFormat(Total_Package_Result,0)#</div>
                                        <div class="ezgi-kpi-detail">
                                            Toplam: #TlFormat(Total_Package,0)#<br>
                                            Kalan: #TlFormat(packageRemaining,0)#
                                        </div>
                                        <div class="ezgi-kpi-percent #packageRate EQ 0 ? 'zero' : ''#">
                                            #NumberFormat(packageRate,"99.9")#%
                                        </div>
                                    </div>
                                    <div class="ezgi-kpi-chart-wrapper">
                                        <canvas id="chart-package"></canvas>
                                    </div>
                                </div>
                                </div>
                                <!-- İş Emri -->
                                <div class="col col-3 col-xs-12">
                                <div class="ezgi-kpi-card">
                                    <div>
                                        <div class="ezgi-kpi-title">İş Emri</div>
                                        <div class="ezgi-kpi-main-value">#TlFormat(Total_Order_Result,0)#</div>
                                        <div class="ezgi-kpi-detail">
                                            Toplam: #TlFormat(Total_Order,0)#<br>
                                            Kalan: #TlFormat(orderRemaining,0)#
                                        </div>
                                        <div class="ezgi-kpi-percent #orderRate EQ 0 ? 'zero' : ''#">
                                            #NumberFormat(orderRate,"99.9")#%
                                        </div>
                                    </div>
                                    <div class="ezgi-kpi-chart-wrapper">
                                        <canvas id="chart-order"></canvas>
                                    </div>
                                </div>
                                </div>
                                <!-- Operasyon -->
                                <div class="col col-3 col-xs-12">
                                <div class="ezgi-kpi-card">
                                    <div>
                                        <div class="ezgi-kpi-title">Operasyon</div>
                                        <div class="ezgi-kpi-main-value">#TlFormat(Total_Operation_Result,0)#</div>
                                        <div class="ezgi-kpi-detail">
                                            Toplam: #TlFormat(Total_Operation,0)#<br>
                                            Kalan: #TlFormat(operationRemaining,0)#
                                        </div>
                                        <div class="ezgi-kpi-percent #operationRate EQ 0 ? 'zero' : ''#">
                                            #NumberFormat(operationRate,"99.9")#%
                                        </div>
                                    </div>
                                    <div class="ezgi-kpi-chart-wrapper">
                                        <canvas id="chart-operation"></canvas>
                                    </div>
                                </div>
                                </div>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- İSTASYON DOLULUK ORANLARI -->
            <div class="ezgi-row">
                <div class="ezgi-col-12">
                    <div class="ezgi-card ezgi-table-card">
                        <table>
                            <thead>
                                <tr class="title-row">
                                    <th colspan="7">İstasyon Doluluk Oranları</th>
                                </tr>
                                <tr class="section-sub">
                                    <th colspan="4">Planlanan</th>
                                    <th colspan="3">Kapasite (<cfoutput>#workSeconds#</cfoutput> Sn.)</th>
                                </tr>
                                <tr class="columns">
                                    <th class="ezgi-td-right">No</th>
                                    <th>İstasyon</th>
                                    <th>Çalışan</th>
                                    <th>Planlanan Brüt Süre (Sn.)</th>
                                    
                                    <th>Katsayı</th>
                                    <th>Planlanan Net Süre (Sn.)</th>
                                    <th>Oran</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfif get_operations_group.recordcount>
                                    <cfloop query="get_workstation_group">
                                        <cfif len(get_workstation_group.STATION_ID)>
                                            <tr>
                                                <td class="ezgi-td-right"><cfoutput>#currentrow#</cfoutput></td>
                                                <td class="ezgi-td-left"><cfoutput>#STATION_NAME#</cfoutput></td>
                                                <td class="ezgi-td-center"><cfoutput>#TlFormat(EMPLOYEE_NUMBER,0)#</cfoutput></td>
                                                <td class="ezgi-td-center"><cfoutput>#TlFormat(TOTAL_OPTIMUM_TIME,0)#</cfoutput></td>
    
                                                <td class="ezgi-td-center"><cfoutput>#EZGI_KATSAYI#</cfoutput></td>
                                                <td class="ezgi-td-center"><cfoutput>#TlFormat(TOTAL_OPTIMUM_TIME/EZGI_KATSAYI,0)#</cfoutput></td>
                                                <td class="ezgi-td-center">
                                                    <cfif TOTAL_OPTIMUM_TIME gt 0 and workSeconds gt 0 and EZGI_KATSAYI gt 0>
                                                        <cfset _ratio = ((TOTAL_OPTIMUM_TIME/EZGI_KATSAYI)/workSeconds)*100>
                                                        <span class="ezgi-badge <cfif _ratio lt 100>ezgi-badge-danger<cfelse>ezgi-badge-success</cfif>">
                                                            <cfoutput>#TlFormat(_ratio,2)#%</cfoutput>
                                                        </span>
                                                    <cfelse>
                                                        <span class="ezgi-badge ezgi-badge-danger">0,00%</span>
                                                    </cfif>
                                                </td>
                                            </tr>
                                        </cfif>
                                    </cfloop>
                                <cfelse>
                                    <tr>
                                        <td colspan="7" class="ezgi-td-center ezgi-text-muted">Kayıt yok</td>
                                    </tr>
                                </cfif>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
		</cfif>
        <!-- OPERASYON & İSTASYON ANALİZLERİ -->
        <div class="ezgi-row">
			<div class="col col-12 col-xs-12">
            <!-- Operasyon Analizi -->
            <div class="col col-6 col-xs-12">
                <div class="ezgi-card ezgi-table-card">
                    <table>
                        <thead>
                            <tr class="title-row">
                                <th colspan="11">Operasyon Analizi</th>
                            </tr>
                            <tr class="section-sub">
                                <th colspan="7">Planlanan</th>
                                <th colspan="4">Gerçekleşen</th>
                            </tr>
                            <tr class="columns">
                                <th class="ezgi-td-right">No</th>
                                <th>Operasyon</th>
                                <th>İstasyon</th>
                                <th>Çalışan</th>
                                <th>Miktar</th>
                                <th>B.Süre</th>
                                <th>T.Süre</th>
                                <th>Miktar</th>
                                <th>T.Süre</th>
                                <th>O.Süre</th>
                                <th>Verimlilik</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfif get_operations_group.recordcount>
                                <cfloop query="get_operations_group">
                                    <cfquery name="get_result" dbtype="query">
                                        SELECT
                                            SUM(REAL_AMOUNT) AS REAL_AMOUNT, 
                                            SUM(LOSS_AMOUNT) AS LOSS_AMOUNT, 
                                            SUM(REAL_TIME)  AS REAL_TIME, 
                                            SUM(WAIT_TIME)  AS WAIT_TIME
                                        FROM
                                            get_operation_result
                                        WHERE
                                            OPERATION_TYPE_ID = #get_operations_group.OPERATION_TYPE_ID#
                                    </cfquery>
                                    <tr>
                                        <td class="ezgi-td-right"><cfoutput>#currentrow#</cfoutput></td>
                                        <td class="ezgi-td-left"><cfoutput>#OPERATION_TYPE#</cfoutput></td>
                                        <td class="ezgi-td-center"><cfoutput>#TlFormat(STATION_COUNT,0)#</cfoutput></td>
                                        <td class="ezgi-td-center"><cfoutput>#TlFormat(TOTAL_EMPLOYEE_NUMBER,0)#</cfoutput></td>
                                        <td class="ezgi-td-center"><cfoutput>#TlFormat(TOTAL_AMOUNT,0)#</cfoutput></td>
                                        <td class="ezgi-td-center"><cfoutput>#TlFormat(TOTAL_OPTIMUM_TIME/TOTAL_AMOUNT,0)#</cfoutput></td>
                                        <td class="ezgi-td-center"><cfoutput>#TlFormat(TOTAL_OPTIMUM_TIME,0)#</cfoutput></td>

                                        <td class="ezgi-td-center"><cfoutput>#TlFormat(get_result.REAL_AMOUNT,0)#</cfoutput></td>
                                        <td class="ezgi-td-center"><cfoutput>#TlFormat(get_result.REAL_TIME,0)#</cfoutput></td>
                                        <td class="ezgi-td-center">
                                            <cfif get_result.REAL_AMOUNT gt 0 and get_result.REAL_TIME gt 0>
                                            	<cfset operation_avg = get_result.REAL_TIME/get_result.REAL_AMOUNT>
                                            	<cfset operation_ratio = (TOTAL_OPTIMUM_TIME/TOTAL_AMOUNT)/operation_avg*100>
                                            <cfelse>
                                              	<cfset operation_avg = 0>
                                            	<cfset operation_ratio = 0>  
                                            </cfif>
                                            <cfoutput>#TlFormat(operation_avg,0)#</cfoutput>
                                        </td>
                                        <td class="ezgi-td-center">
                                        	<span class="ezgi-badge <cfif operation_ratio lt 100>ezgi-badge-danger<cfelse>ezgi-badge-success</cfif>">
                                             	<cfoutput>#TlFormat(operation_ratio,2)#%</cfoutput>
                                         	</span>
                                        </td>
                                    </tr>
                                </cfloop>
                            <cfelse>
                                <tr>
                                    <td colspan="11" class="ezgi-td-center ezgi-text-muted">Kayıt yok</td>
                                </tr>
                            </cfif>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- İstasyon Analizi -->
            <div class="col col-6 col-xs-12">
                <div class="ezgi-card ezgi-table-card">
                    <table>
                        <thead>
                            <tr class="title-row">
                                <th colspan="9">İstasyon Analizi</th>
                            </tr>
                            <tr class="section-sub">
                                <th colspan="6">Planlanan</th>
                                <th colspan="3">Gerçekleşen</th>
                            </tr>
                            <tr class="columns">
                                <th class="ezgi-td-right">No</th>
                                <th>İstasyon</th>
                                <th>Çalışan</th>
                                <th>Miktar</th>
                                <th>Beklenen Süre</th>
                                <th>Katsayı</th>
                                <th>Miktar</th>
                                <th>Gerçekleşen Süre</th>
                                <th>Verimlilik</th>
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
                                                SUM(REAL_TIME)  AS REAL_TIME, 
                                                SUM(WAIT_TIME)  AS WAIT_TIME
                                            FROM
                                                get_operation_result
                                            WHERE
                                                STATION_ID = #get_workstation_group.STATION_ID#
                                        </cfquery>
                                        <tr>
                                            <td class="ezgi-td-right"><cfoutput>#currentrow#</cfoutput></td>
                                            <td class="ezgi-td-left"><cfoutput>#STATION_NAME#</cfoutput></td>
                                            <td class="ezgi-td-center"><cfoutput>#TlFormat(EMPLOYEE_NUMBER,0)#</cfoutput></td>
                                            <td class="ezgi-td-center"><cfoutput>#TlFormat(TOTAL_AMOUNT,0)#</cfoutput></td>
                                            <td class="ezgi-td-center"><cfoutput>#TlFormat(TOTAL_OPTIMUM_TIME,0)#</cfoutput></td>
                                            <td class="ezgi-td-center"><cfoutput>#TlFormat(EZGI_KATSAYI,2)#</cfoutput></td>

                                            <td class="ezgi-td-center"><cfoutput>#TlFormat(get_result.REAL_AMOUNT,0)#</cfoutput></td>
                                            <td class="ezgi-td-center"><cfoutput>#TlFormat(get_result.REAL_TIME,0)#</cfoutput></td>
                                            <td class="ezgi-td-center">
												<cfif TOTAL_OPTIMUM_TIME gt 0 and get_result.REAL_TIME gt 0>
                                                    <cfset station_ratio = TOTAL_OPTIMUM_TIME/get_result.REAL_TIME*100>
                                                    <span class="ezgi-badge <cfif station_ratio lt 100>ezgi-badge-danger<cfelse>ezgi-badge-success</cfif>">
                                                        <cfoutput>#TlFormat(station_ratio,2)#%</cfoutput>
                                                    </span>
                                                <cfelse>
                                                    <cfoutput>#TlFormat(0,0)#</cfoutput>
                                                </cfif>
                                        	</td>
                                        </tr>
                                    </cfif>
                                </cfloop>
                            <cfelse>
                                <tr>
                                    <td colspan="9" class="ezgi-td-center ezgi-text-muted">Kayıt yok</td>
                                </tr>
                            </cfif>
                        </tbody>
                    </table>
                </div>
            </div>
            </div>
        </div>

    </div><!-- /.ezgi-dashboard -->

    <!-- KPI Donut Chart'ların çizimi -->
    <cfoutput>
    <script>
        (function() {
            const kpiConfig = [
                {
                    el: 'chart-module',
                    done: #Total_Main_Result#,
                    remaining: #moduleRemaining#
                },
                {
                    el: 'chart-package',
                    done: #Total_Package_Result#,
                    remaining: #packageRemaining#
                },
                {
                    el: 'chart-order',
                    done: #Total_Order_Result#,
                    remaining: #orderRemaining#
                },
                {
                    el: 'chart-operation',
                    done: #Total_Operation_Result#,
                    remaining: #operationRemaining#
                }
            ];

            kpiConfig.forEach(cfg => {
                const canvas = document.getElementById(cfg.el);
                if (!canvas) return;

                const ctx = canvas.getContext('2d');
                new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: ['Gerçekleşen', 'Kalan'],
                        datasets: [{
                            data: [cfg.done, cfg.remaining],
                            backgroundColor: [
                                'rgba(37,99,235,0.95)',   // mavi
                                'rgba(209,213,219,0.9)'  // gri
                            ],
                            borderWidth: 0
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        cutout: '65%',
                        plugins: {
                            legend: {
                                display: false
                            },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        const value = context.raw || 0;
                                        return context.label + ': ' + value.toLocaleString('tr-TR');
                                    }
                                }
                            }
                        }
                    }
                });
            });
        })();
    </script>
    </cfoutput>
<cfelse>
    <div class="ezgi-dashboard">
        <div class="ezgi-card">
            <span class="ezgi-text-muted">Kayıt yok.</span>
        </div>
    </div>
</cfif>
