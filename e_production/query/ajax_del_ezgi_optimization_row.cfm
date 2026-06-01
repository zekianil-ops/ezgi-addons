<!---
    File: ajax_del_ezgi_optimization_row.cfm
    Folder: AddOns\ezgi\e_production\query
    Author: Ezgi Yazılım
    Date: 12/12/2025
    Description: Optimizasyon Satırı Silme (AJAX)
--->
<cfif len(attributes.optimization_id) and isNumeric(attributes.optimization_id)>
	<!--- Optimizasyona henüz girmemiş üretim planlarını getir --->
	<cfquery name="get_available_plans" datasource="#dsn3#">
			SELECT DISTINCT 
				EIF.QUANTITY, 
				EIF.LOT_NO, 
				EIM.MASTER_PLAN_NUMBER, 
				EIF.IFLOW_P_ORDER_ID AS P_ORDER_ID, 
				EIF.PRODUCT_TYPE, 
				EIF.STOCK_ID, 
				EIM.MASTER_PLAN_ID, 
				EIF.P_ORDER_SORT_NO, 
				EIP.P_ORDER_PARTI_NUMBER AS PARTI_NO, 
				EIP.P_ORDER_PARTI_SORT_NO, 
				S.PRODUCT_NAME, 
				S.PRODUCT_CODE
			FROM 
				EZGI_IFLOW_PRODUCTION_ORDERS AS EIF WITH (NOLOCK)
				INNER JOIN EZGI_IFLOW_MASTER_PLAN AS EIM WITH (NOLOCK) ON EIF.MASTER_PLAN_ID = EIM.MASTER_PLAN_ID
				INNER JOIN EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIP WITH (NOLOCK) ON EIF.REL_P_ORDER_ID = EIP.P_ORDER_PARTI_ID
				INNER JOIN EZGI_IFLOW_PRODUCTION_ORDER_LOT_NO_STAGE AS POL WITH (NOLOCK) ON EIF.IFLOW_P_ORDER_ID = POL.IFLOW_P_ORDER_ID
				INNER JOIN STOCKS AS S WITH (NOLOCK) ON EIF.STOCK_ID = S.STOCK_ID
				LEFT OUTER JOIN EZGI_IFLOW_OPTIMIZATION AS EIO WITH (NOLOCK)
					INNER JOIN EZGI_IFLOW_OPTIMIZATION_ROW AS EIOR WITH (NOLOCK) ON EIO.OPTIMIZATION_ID = EIOR.OPTIMIZATION_ID
					ON EIF.IFLOW_P_ORDER_ID = EIOR.IFLOW_P_ORDER_ID
					AND EIO.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
			WHERE 
				(EIO.OPTIMIZATION_ID IS NULL) 
				AND (POL.IS_STAGE IN (0,4)) 
				AND (EIM.MASTER_PLAN_STATUS = 1)
				AND NOT EXISTS (
					SELECT 1 
					FROM EZGI_IFLOW_OPTIMIZATION_ROW AS EIOR2 WITH (NOLOCK)
					WHERE EIOR2.IFLOW_P_ORDER_ID = EIF.IFLOW_P_ORDER_ID
					AND EIOR2.OPTIMIZATION_ID <> <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
				)
				<cfif len(attributes.master_plan_id) and isNumeric(attributes.master_plan_id)>
					AND (EIM.MASTER_PLAN_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.master_plan_id#">)
				</cfif>
			ORDER BY 
				EIM.MASTER_PLAN_NUMBER, 
				EIP.P_ORDER_PARTI_SORT_NO, 
				EIF.P_ORDER_SORT_NO
	</cfquery>
	<cf_box>
		<cfsavecontent variable="available_plans_title">Optimizasyona Henüz Girmemiş Üretim Planları</cfsavecontent>
		<cf_box title="#available_plans_title#">
			<cf_grid_list>
				<thead>
					<tr valign="middle">
						<th style="width:20px; text-align:center"><cf_get_lang dictionary_id='58577.Sıra'></th>
						<th style="text-align:center">Master Plan No</th>
						<th style="text-align:center"><cf_get_lang dictionary_id='36528.Parti No'></th>
						<th style="text-align:center"><cf_get_lang dictionary_id='45498.Lot No'></th>
						<th style="text-align:center"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
						<th style="text-align:right"><cf_get_lang dictionary_id='57635.Miktar'></th>
					</tr>
				</thead>
								<tbody id="available_plans_tbody" name="available_plans_tbody">
									<cfoutput>
									
										<cfloop query="get_available_plans">
											<tr id="available_row_#P_ORDER_ID#" data-p-order-id="#P_ORDER_ID#" draggable="true" ondragstart="dragStart(event)" style="cursor:move">
												<td style="text-align:right">#currentrow#</td>
												<td style="text-align:center"><cfif isDefined("MASTER_PLAN_NUMBER")>#MASTER_PLAN_NUMBER#</cfif></td>
												<td style="text-align:center"><cfif isDefined("PARTI_NO")>#PARTI_NO#</cfif></td>
												<td style="text-align:center"><cfif isDefined("LOT_NO")>#LOT_NO#</cfif></td>
												<td style="text-align:left"><cfif isDefined("PRODUCT_NAME")>#PRODUCT_NAME#</cfif></td>
												<td style="text-align:right"><cfif isDefined("QUANTITY")>#QUANTITY#<cfelse>0</cfif></td>
											</tr>
										</cfloop>
	
									</cfoutput>
								</tbody>
							</cf_grid_list>
		</cf_box>
	</cf_box>
</cfif>


