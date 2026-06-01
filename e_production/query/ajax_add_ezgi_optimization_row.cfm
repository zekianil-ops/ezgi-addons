<!---
    File: ajax_add_ezgi_optimization_row.cfm
    Folder: AddOns\ezgi\e_production\query
    Author: Ezgi Yazılım
    Date: 12/12/2025
    Description: Optimizasyon Satırı Ekleme (AJAX)
--->
<cfif len(attributes.optimization_id) and isNumeric(attributes.optimization_id)>
	<cfif (isdefined('attributes.add_process') or isdefined('attributes.del_process')) and len(attributes.iflow_p_order_id) and isNumeric(attributes.iflow_p_order_id)>
		<!--- Aynı kayıt daha önce eklenmiş mi kontrol et --->
        
        <cfquery name="check_existing" datasource="#dsn3#">
            SELECT 
                OPTIMIZATION_ROW_ID
            FROM 
                EZGI_IFLOW_OPTIMIZATION_ROW
            WHERE 
                OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
                AND IFLOW_P_ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iflow_p_order_id#">
        </cfquery>
        <cfif not check_existing.recordcount>
            <cfif isdefined('attributes.add_process')>
                <cfquery name="add_optimization_row" datasource="#dsn3#">
                    INSERT INTO 
                        EZGI_IFLOW_OPTIMIZATION_ROW
                        (
                            OPTIMIZATION_ID,
                            IFLOW_P_ORDER_ID
                        )
                        VALUES
                        (
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iflow_p_order_id#">
                        )
                </cfquery>
            </cfif>
        <cfelse>
            <cfif isdefined('attributes.del_process')>
           		<cfquery name="del_optimization_row" datasource="#dsn3#">
                 	DELETE FROM 
                   		EZGI_IFLOW_OPTIMIZATION_ROW
               		WHERE
                    	OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#"> AND
                  		IFLOW_P_ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iflow_p_order_id#">
             	</cfquery>
            </cfif>
        </cfif>
 	</cfif>
	<!--- Optimizasyona katılacak planlar --->
	<cfquery name="get_optimization_rows" datasource="#dsn3#">
			SELECT DISTINCT 
				EIOR.OPTIMIZATION_ROW_ID,
				EIOR.OPTIMIZATION_ID,
				EIOR.IFLOW_P_ORDER_ID,
				EIF.QUANTITY, 
				EIF.LOT_NO, 
				EIM.MASTER_PLAN_NUMBER, 
				EIF.PRODUCT_TYPE, 
				EIF.STOCK_ID, 
				EIM.MASTER_PLAN_ID, 
				EIF.P_ORDER_SORT_NO, 
				EIP.P_ORDER_PARTI_NUMBER AS PARTI_NO, 
				EIP.P_ORDER_PARTI_SORT_NO, 
				S.PRODUCT_NAME, 
				S.PRODUCT_CODE
			FROM 
				EZGI_IFLOW_OPTIMIZATION_ROW AS EIOR WITH (NOLOCK)
				INNER JOIN EZGI_IFLOW_PRODUCTION_ORDERS AS EIF WITH (NOLOCK) ON EIOR.IFLOW_P_ORDER_ID = EIF.IFLOW_P_ORDER_ID
				INNER JOIN EZGI_IFLOW_MASTER_PLAN AS EIM WITH (NOLOCK) ON EIF.MASTER_PLAN_ID = EIM.MASTER_PLAN_ID
				INNER JOIN EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIP WITH (NOLOCK) ON EIF.REL_P_ORDER_ID = EIP.P_ORDER_PARTI_ID
				INNER JOIN STOCKS AS S WITH (NOLOCK) ON EIF.STOCK_ID = S.STOCK_ID
			WHERE 
				EIOR.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
			ORDER BY 
				EIM.MASTER_PLAN_NUMBER, 
				EIP.P_ORDER_PARTI_SORT_NO, 
				EIF.P_ORDER_SORT_NO
	</cfquery>

	<!--- Bu optimizasyon için malzeme oluşmuş mu? --->
	<cfquery name="get_optimization_materials_exist" datasource="#dsn3#">
		SELECT 
			TOP (1) 1 AS HAS_MATERIAL
		FROM 
			EZGI_IFLOW_OPTIMIZATION_MATERIAL WITH (NOLOCK)
		WHERE 
			OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
	</cfquery>
	
	<!--- Bu optimizasyon için şablon (sonuç) oluşmuş mu? --->
	<cfquery name="get_optimization_results_exist" datasource="#dsn3#">
		SELECT 
			TOP (1) 1 AS HAS_RESULT
		FROM 
			EZGI_IFLOW_OPTIMIZATION_RESULTS WITH (NOLOCK)
		WHERE 
			OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
	</cfquery>
	<cfset has_materials = get_optimization_materials_exist.recordcount>
	<cfset has_results = get_optimization_results_exist.recordcount>
	<cf_box>
        <cfsavecontent variable="production_plans_title">Optimizasyona Katılacak Üretim Planları</cfsavecontent>
        <cf_box title="#production_plans_title#">
            <cf_grid_list>
                <thead>
                    <tr valign="middle">
                        <th style="width:20px; text-align:center"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        <th style=" text-align:center">Master Plan No</th>
                        <th style=" text-align:center"><cf_get_lang dictionary_id='36528.Parti No'></th>
                        <th style=" text-align:center"><cf_get_lang dictionary_id='45498.Lot No'></th>
                        <th style="text-align:center"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                    <th style=" text-align:right"><cf_get_lang dictionary_id='57635.Miktar'></th>
					<!-- Sil ikonu sadece malzeme ve şablon yoksa gösterilsin -->
					<cfif not has_materials and not has_results>
                       	<th style="width:25px; text-align:center" class="header_icn_none"></th>
					<cfelse>
						<th style="width:25px; text-align:center" class="header_icn_none"></th>
					</cfif>
                    </tr>
                </thead>
                <tbody id="optimization_plans_tbody" name="optimization_plans_tbody" >
                    <cfif get_optimization_rows.recordcount>
                        <cfoutput query="get_optimization_rows">
                            <tr id="opt_row_#OPTIMIZATION_ROW_ID#" data-p-order-id="#IFLOW_P_ORDER_ID#">
                                <td style="text-align:right">#currentrow#</td>
                                <td style="text-align:center"><cfif isDefined("MASTER_PLAN_NUMBER")>#MASTER_PLAN_NUMBER#</cfif></td>
                                <td style="text-align:center"><cfif isDefined("PARTI_NO")>#PARTI_NO#</cfif></td>
                                <td style="text-align:center"><cfif isDefined("LOT_NO")>#LOT_NO#</cfif></td>
                                <td style="text-align:left"><cfif isDefined("PRODUCT_NAME")>#PRODUCT_NAME#</cfif></td>
                                <td style="text-align:right"><cfif isDefined("QUANTITY")>#QUANTITY#<cfelse>0</cfif></td>
								<!-- Malzemeler veya şablonlar oluştuysa sil ikonu gizlenir -->
								<cfif not has_materials and not has_results>
									<td style="text-align:center">
										<img src="/images/delete_list.gif" style="cursor:pointer" onclick="deleteOptimizationRow(#IFLOW_P_ORDER_ID#, this)" title="Sil">
									</td>
								<cfelse>
									<td style="text-align:center"></td>
								</cfif>
                            </tr>
                        </cfoutput>
                    <cfelse>
                        <tr>
                            <td colspan="7" height="20" style="text-align:center"><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>
                        </tr>
                    </cfif>
                </tbody>
            </cf_grid_list>
        </cf_box>
	</cf_box>
</cfif>


