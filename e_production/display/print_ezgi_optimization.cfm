<!---
    File: print_ezgi_optimization.cfm
    Folder: AddOns\ezgi\e_production\display
    Author: Ezgi Yazılım
    Date: #dateFormat(now(), "dd/mm/yyyy")#
    Description: Optimizasyon Print Çıktısı (A4)
--->

<cfsetting showdebugoutput="no">

<!--- action_id = optimization_id --->
<cfparam name="attributes.action_id" default="">
<cfparam name="attributes.optimization_id" default="">

<cfif not len(attributes.optimization_id) and len(attributes.action_id)>
	<cfset attributes.optimization_id = attributes.action_id>
</cfif>

<cfif len(attributes.optimization_id) and isNumeric(attributes.optimization_id)>
	<!--- Optimizasyon Bilgileri --->
	<cfquery name="get_optimization" datasource="#dsn3#">
		SELECT 
			OPTIMIZATION_ID,
			OPTIMIZATION_NUMBER,
			OPTIMIZATION_DETAIL,
			OPTIMIZATION_STATUS,
			OPTIMIZATION_DATE,
			OPTIMIZATION_EMP,
			MASTER_PLAN_ID,
			CIRCLE_TESTRE_THICKNESS,
			OUTER_EDGE_TRIMMING_ALLOWANCE,
			RECORD_DATE,
			RECORD_EMP,
			UPDATE_DATE,
			UPDATE_EMP
		FROM 
			EZGI_IFLOW_OPTIMIZATION
		WHERE 
			OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
	</cfquery>
	
	<cfif get_optimization.recordcount>
		<!--- Master Plan Bilgisi --->
		<cfif len(get_optimization.MASTER_PLAN_ID) and isNumeric(get_optimization.MASTER_PLAN_ID)>
			<cfquery name="get_master_plan" datasource="#dsn3#">
				SELECT 
					MASTER_PLAN_ID,
					MASTER_PLAN_NUMBER,
					MASTER_PLAN_DETAIL
				FROM 
					EZGI_IFLOW_MASTER_PLAN
				WHERE 
					MASTER_PLAN_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_optimization.MASTER_PLAN_ID#">
			</cfquery>
		<cfelse>
			<cfquery name="get_master_plan" datasource="#dsn3#">
				SELECT 
					MASTER_PLAN_ID,
					MASTER_PLAN_NUMBER,
					MASTER_PLAN_DETAIL
				WHERE 
					1 = 0
			</cfquery>
		</cfif>
		
		<!--- Optimizasyon Sonuçları (Şablonlar) --->
		<cfquery name="get_optimization_results" datasource="#dsn3#">
			SELECT 
				EOR.OPTIMIZATION_RESULT_ID,
				EOR.OPTIMIZATION_ID,
				EOR.STOCK_ID,
				EOR.SHEET_NUMBER,
				EOR.SHEET_GROUP_NUMBER,
				EOR.USED_AREA,
				EOR.FIRE_AREA,
				EOR.FIRE_PERCENT,
				ISNULL(S.PRODUCT_NAME, 'Bilinmeyen Malzeme') AS PRODUCT_NAME
			FROM 
				EZGI_IFLOW_OPTIMIZATION_RESULTS AS EOR WITH (NOLOCK)
				LEFT OUTER JOIN STOCKS AS S WITH (NOLOCK) ON EOR.STOCK_ID = S.STOCK_ID
			WHERE 
				EOR.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
			ORDER BY 
				EOR.STOCK_ID, 
				EOR.SHEET_GROUP_NUMBER, 
				EOR.SHEET_NUMBER
		</cfquery>
		
		<!--- Şablon Grupları (Malzeme bazında) --->
		<cfquery name="get_results_grouped" dbtype="query">
			SELECT 
				PRODUCT_NAME,
				STOCK_ID,
				COUNT(*) AS SHEET_COUNT,
				SUM(USED_AREA) AS TOTAL_USED_AREA,
				SUM(FIRE_AREA) AS TOTAL_FIRE_AREA,
				AVG(FIRE_PERCENT) AS AVG_FIRE_PERCENT
			FROM
				get_optimization_results
			GROUP BY
				PRODUCT_NAME,
				STOCK_ID
			ORDER BY
				PRODUCT_NAME,
				STOCK_ID
		</cfquery>
		
		<!--- Şablon Detayları (Grup bazında) - Ekrandaki tablo ile aynı query --->
		<cfquery name="get_optimization_results_row" datasource="#dsn3#">
			SELECT 
				OER.SHEET_GROUP_NUMBER, 
				OER.STOCK_ID, 
				OERR.OPTIMIZATION_RESULT_ID, 
				SUM(OERR.WIDTH * OERR.HEIGHT / 1000000) AS USED_AMOUNT
			FROM     
				EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS OERR WITH (NOLOCK) INNER JOIN
				EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER ON OERR.OPTIMIZATION_RESULT_ID = OER.OPTIMIZATION_RESULT_ID
			WHERE  
				OER.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
			GROUP BY 
				OER.SHEET_GROUP_NUMBER, 
				OER.STOCK_ID, 
				OERR.OPTIMIZATION_RESULT_ID
		</cfquery>
		
		<!--- Kaydeden Kullanıcı Bilgisi --->
		<cfif len(get_optimization.OPTIMIZATION_EMP) and isNumeric(get_optimization.OPTIMIZATION_EMP)>
			<cfset optimization_emp_name = get_emp_info(get_optimization.OPTIMIZATION_EMP, 0, 0)>
		<cfelse>
			<cfset optimization_emp_name = "">
		</cfif>
		
		<cfif isDate(get_optimization.OPTIMIZATION_DATE)>
			<cfset optimization_date_value = dateformat(get_optimization.OPTIMIZATION_DATE, dateformat_style)>
		<cfelse>
			<cfset optimization_date_value = "">
		</cfif>
		
		<!--- A4 Print Stilleri --->
		<style type="text/css">
			@media print {
				@page {
					size: A4;
					margin: 15mm;
				}
				body {
					font-family: Arial, Helvetica, sans-serif;
					font-size: 10pt;
					color: #000;
					background: #fff;
				}
				.page-break {
					page-break-after: always;
				}
			}
			@media screen {
				body {
					font-family: Arial, Helvetica, sans-serif;
					font-size: 11pt;
					color: #333;
					background: #f5f5f5;
					padding: 20px;
				}
			}
			.print-container {
				width: 100%;
				max-width: 210mm;
				margin: 0 auto;
				background: #fff;
				padding: 10mm;
				position: relative;
			}
			/* Filigran (logo) için stil - her sayfanın ortasında görünecek şekilde */
			.watermark-logo {
				position: fixed; /* print'te her sayfada tekrarlar */
				top: 50%;
				left: 50%;
				transform: translate(-50%, -50%);
				opacity: 0.10; /* Biraz daha belirgin, yine de arka planda kalacak */
				z-index: 0;
				pointer-events: none;
			}
			.print-content {
				position: relative;
				z-index: 1;
			}
			.header-section {
				border-bottom: 3px solid #000;
				padding-bottom: 10px;
				margin-bottom: 15px;
			}
			.header-title {
				font-size: 16pt;
				font-weight: bold;
				text-align: center;
				margin-bottom: 10px;
			}
			.info-table {
				width: 100%;
				border-collapse: collapse;
				margin-bottom: 20px;
			}
			.info-table td {
				padding: 5px;
				border: 1px solid #000;
				vertical-align: top;
			}
			.info-table td.label {
				width: 30%;
				font-weight: bold;
				background-color: #fff;
				border-left: 2px solid #000;
				color: #000;
				font-size: 10pt;
			}
			.results-table {
				width: 100%;
				border-collapse: collapse;
				margin-top: 15px;
				font-size: 9pt;
			}
			.results-table th {
				background-color: #fff;
				color: #000;
				padding: 8px;
				text-align: center;
				border: 2px solid #000;
				font-weight: bold;
			}
			.results-table td {
				padding: 6px;
				border: 1px solid #000;
				text-align: right;
			}
			.results-table td.left-align {
				text-align: left;
			}
			.results-table td.center-align {
				text-align: center;
			}
			.group-header {
				background-color: #fff !important;
				font-weight: bold;
				border-top: 2px solid #000;
				border-bottom: 1px solid #000;
			}
			.group-total {
				background-color: #fff;
				font-weight: bold;
			}
			.footer-section {
				margin-top: 20px;
				padding-top: 10px;
				border-top: 1px solid #000;
				font-size: 8pt;
				text-align: center;
				color: #000;
			}
		</style>
		
		<div class="print-container">
			<!--- Filigran Logo --->
			<div class="watermark-logo">
				<img src="/AddOns/ezgi/images/logo.png" alt="Ezgi Logo" style="width: 140mm; height: auto;">
			</div>
			
			<div class="print-content">
			<!--- Başlık Bölümü --->
			<div class="header-section">
				<div class="header-title">OPTİMİZASYON BİLGİLERİ</div>
			</div>
			
			<!--- Optimizasyon Bilgileri Tablosu --->
			<table class="info-table">
				<tr>
					<td class="label">Belge No:</td>
					<td><cfoutput>#get_optimization.OPTIMIZATION_NUMBER#</cfoutput></td>
					<td class="label">Belge Tarihi:</td>
					<td><cfoutput>#optimization_date_value#</cfoutput></td>
				</tr>
				<tr>
					<td class="label">Master Plan:</td>
					<td colspan="3">
						<cfoutput>
							<cfif get_master_plan.recordcount>
								#get_master_plan.MASTER_PLAN_NUMBER# - #get_master_plan.MASTER_PLAN_DETAIL#
							<cfelse>
								-
							</cfif>
						</cfoutput>
					</td>
				</tr>
				<tr>
					<td class="label">Kaydeden:</td>
					<td><cfoutput>#optimization_emp_name#</cfoutput></td>
					<td class="label">Durum:</td>
					<td><cfoutput><cfif get_optimization.OPTIMIZATION_STATUS>Aktif<cfelse>Pasif</cfif></cfoutput></td>
				</tr>
				<tr>
					<td class="label">Daire Testre Kalınlığı:</td>
					<td><cfoutput><cfif len(get_optimization.CIRCLE_TESTRE_THICKNESS)>#get_optimization.CIRCLE_TESTRE_THICKNESS# mm<cfelse>-</cfif></cfoutput></td>
					<td class="label">Dış Kenar Traşlama Payı:</td>
					<td><cfoutput><cfif len(get_optimization.OUTER_EDGE_TRIMMING_ALLOWANCE)>#get_optimization.OUTER_EDGE_TRIMMING_ALLOWANCE# mm<cfelse>-</cfif></cfoutput></td>
				</tr>
				<cfif len(get_optimization.OPTIMIZATION_DETAIL)>
					<tr>
						<td class="label">Açıklama:</td>
						<td colspan="3"><cfoutput>#get_optimization.OPTIMIZATION_DETAIL#</cfoutput></td>
					</tr>
				</cfif>
			</table>
			
			<!--- Optimizasyon Sonuçları Başlığı --->
			<div class="header-section" style="margin-top: 25px;">
				<div class="header-title">OPTİMİZASYON SONUÇLARI</div>
			</div>
			
			<!--- Şablonlar Tablosu (Gruplanmış) --->
			<cfif get_results_grouped.recordcount>
				<table class="results-table">
					<thead>
						<tr>
							<th style="width: 40px;">Sıra</th>
							<th style="text-align: left;">Malzeme</th>
							<th style="width: 60px;">Miktar</th>
							<th style="width: 80px;">Kullanım (m²)</th>
							<th style="width: 70px;">Fire (m²)</th>
							<th style="width: 60px;">Oran (%)</th>
						</tr>
					</thead>
					<tbody>
						<cfoutput query="get_results_grouped">
							<!--- Malzeme Grubu Başlığı --->
							<tr class="group-header">
								<td class="center-align">#currentRow#</td>
								<td class="left-align">#PRODUCT_NAME#</td>
								<td class="center-align">#SHEET_COUNT#</td>
								<td>#AmountFormat(TOTAL_USED_AREA / 1000000, 2)#</td>
								<td>#AmountFormat(TOTAL_FIRE_AREA / 1000000, 2)#</td>
								<td>#AmountFormat(AVG_FIRE_PERCENT, 2)#%</td>
							</tr>
							
							<!--- Bu malzeme için şablon grupları - Ekrandaki tablo ile aynı hesaplama --->
							<cfquery name="get_sheet_groups" dbtype="query">
								SELECT 
									SHEET_GROUP_NUMBER,
									STOCK_ID,
									COUNT(*) AS SHEET_COUNT,
									SUM(USED_AMOUNT) AS TOTAL_USED_AMOUNT
								FROM
									get_optimization_results_row
								WHERE
									STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#STOCK_ID#">
								GROUP BY
									SHEET_GROUP_NUMBER,
									STOCK_ID
								ORDER BY
									SHEET_GROUP_NUMBER
							</cfquery>
							
							<cfif get_sheet_groups.recordcount>
								<cfloop query="get_sheet_groups">
									<!--- Ekrandaki tablo ile aynı hesaplama: Fire = (5.88*SHEET_COUNT)-TOTAL_USED_AMOUNT --->
									<cfset fire_area_calc = (5.88 * SHEET_COUNT) - TOTAL_USED_AMOUNT>
									<cfset fire_percent_calc = 0>
									<cfif (5.88 * SHEET_COUNT) gt 0>
										<cfset fire_percent_calc = (fire_area_calc / (5.88 * SHEET_COUNT)) * 100>
									</cfif>
									<tr>
										<td></td>
										<td class="left-align" style="padding-left: 20px;">Şablon No: #SHEET_GROUP_NUMBER#</td>
										<td class="center-align">#SHEET_COUNT#</td>
										<td>#AmountFormat(TOTAL_USED_AMOUNT, 2)#</td>
										<td>#AmountFormat(fire_area_calc, 2)#</td>
										<td>#AmountFormat(fire_percent_calc, 2)#%</td>
									</tr>
								</cfloop>
							</cfif>
						</cfoutput>
					</tbody>
				</table>
			<cfelse>
				<p style="text-align: center; padding: 20px; color: #999;">Henüz şablon oluşturulmamış.</p>
			</cfif>
			
			<!--- Footer --->
			<div class="footer-section">
				<cfoutput>
					Oluşturulma Tarihi: #dateFormat(now(), "dd/mm/yyyy HH:nn")# | 
					Sayfa: 1
				</cfoutput>
			</div>
			</div> <!-- /.print-content -->
		</div>
	<cfelse>
		<p style="text-align: center; padding: 20px; color: #f00;">Optimizasyon kaydı bulunamadı!</p>
	</cfif>
<cfelse>
	<p style="text-align: center; padding: 20px; color: #f00;">Geçersiz optimizasyon ID!</p>
</cfif>

