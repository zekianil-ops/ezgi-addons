<!---
    File: dsp_ezgi_sheet_sablon.cfm
    Folder: Add_Ons\ezgi\e-vts\display
    Author: Ezgi Yazılım
    Date: 04/01/2025
    Description: Şablon kesim planı gösterimi
--->
<cfparam name="attributes.sheet_group_number" default="">

<cfif isdefined('attributes.sheet_group_number') and len(attributes.sheet_group_number) and isNumeric(attributes.sheet_group_number)>
	<!--- Sheet Group Number'dan Optimization ID ve Stock ID'yi al --->
	<cfquery name="get_optimization_data" datasource="#dsn3#">
		SELECT TOP 1
			EOR.OPTIMIZATION_ID,
			EOR.STOCK_ID
		FROM 
			EZGI_IFLOW_OPTIMIZATION_RESULTS AS EOR WITH (NOLOCK)
		WHERE 
			EOR.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
	</cfquery>
	
	<cfif get_optimization_data.recordcount>
		<cfset attributes.optimization_id = get_optimization_data.OPTIMIZATION_ID>
		<cfset attributes.stock_id = get_optimization_data.STOCK_ID>
		<cfset attributes.sheet_no = attributes.sheet_group_number>
		
		<!--- ajax_ezgi_optimization_display.cfm dosyasını include et --->
		<cfinclude template="../../e_production/query/ajax_ezgi_optimization_display.cfm">
		
		<!--- "Kapat" butonunu window.close() ile değiştir --->
		<script type="text/javascript">
			document.addEventListener('DOMContentLoaded', function() {
				var closeButton = document.querySelector('button[onclick="optimization_display_close()"]');
				if (closeButton) {
					closeButton.setAttribute('onclick', 'window.close();');
				}
			});
		</script>
	<cfelse>
		<cf_box>
			<cf_box title="Hata">
				<div class="col col-12">
					<p style="color:red;">Optimizasyon bilgileri bulunamadı.</p>
				</div>
			</cf_box>
		</cf_box>
	</cfif>
<cfelse>
	<cf_box>
		<cf_box title="Hata">
			<div class="col col-12">
				<p style="color:red;">Geçersiz şablon numarası.</p>
			</div>
		</cf_box>
	</cf_box>
</cfif>

