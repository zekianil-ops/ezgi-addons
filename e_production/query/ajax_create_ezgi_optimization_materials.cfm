<!---
    File: ajax_create_ezgi_optimization_materials.cfm
    Folder: AddOns\ezgi\e_production\query
    Author: Ezgi Yazılım
    Date: #dateFormat(now(), "dd/mm/yyyy")#
    Description: Optimizasyon Malzemelerini Oluşturma (AJAX)
--->

<cfparam name="attributes.optimization_id" default="">
<cfparam name="attributes.add_process" default="0">

<!--- URL veya FORM parametrelerini attributes'a kopyala --->
<cfif isDefined("url.optimization_id") and len(url.optimization_id)>
	<cfset attributes.optimization_id = url.optimization_id>
<cfelseif isDefined("form.optimization_id") and len(form.optimization_id)>
	<cfset attributes.optimization_id = form.optimization_id>
</cfif>

<cfif isDefined("url.add_process") and len(url.add_process)>
	<cfset attributes.add_process = url.add_process>
<cfelseif isDefined("form.add_process") and len(form.add_process)>
	<cfset attributes.add_process = form.add_process>
</cfif>

<cfif len(attributes.optimization_id) and isNumeric(attributes.optimization_id)>
    <!--- Ebatlama operasyonu ID'sini al --->
    <cfquery name="get_cutting_operation" datasource="#dsn3#">
	    SELECT DEFAULT_CUTTING_OPERATION_TYPE_ID FROM EZGI_DESIGN_DEFAULTS
    </cfquery>
		
    <cfif get_cutting_operation.recordcount and len(get_cutting_operation.DEFAULT_CUTTING_OPERATION_TYPE_ID)>
        <!--- Ebatlama operasyonuna bağlı default istasyonu bul --->
	    <cfquery name="get_default_workstation" datasource="#dsn3#">
				SELECT        
					W.STATION_ID AS WORKSTATION_ID,
					W.STATION_NAME AS WORKSTATION_NAME,
                    ISNULL(WP.DEFAULT_STATUS, 0) AS DEFAULT_STATUS
				FROM            
					WORKSTATIONS_PRODUCTS WP WITH (NOLOCK) INNER JOIN
					WORKSTATIONS W ON WP.WS_ID = W.STATION_ID
				WHERE        
					OPERATION_TYPE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_cutting_operation.DEFAULT_CUTTING_OPERATION_TYPE_ID#">
				ORDER BY
					ISNULL(DEFAULT_STATUS, 0) DESC
	    </cfquery>
	    <cfif not get_default_workstation.recordcount>
				<script type="text/javascript">
					alert("Ebatlama operasyonuna İstasyon Atanmamış!");
				</script>
				<cfabort>
	    </cfif>
	    <cfset default_workstation_id = get_default_workstation.WORKSTATION_ID>
    <cfelse>
			<script type="text/javascript">
				alert("Ebatlama operasyonu tanımlanmamış!");
			</script>
			<cfabort>
    </cfif>
	<!--- Malzeme oluşturma işlemi --->
	<cfif attributes.add_process eq 1>	
		<!--- Optimizasyona katılacak üretim planlarına ait yonga levha malzemelerini tespit et --->
		<cfquery name="get_orders" datasource="#dsn3#">
			SELECT DISTINCT        
				P_ORDER_ID
			FROM            
				(
					SELECT
						EI.LOT_NO, 
						PO.P_ORDER_ID, 
						PO.STOCK_ID, 
						EPR.PIECE_TYPE
					FROM            
						EZGI_IFLOW_PRODUCTION_ORDERS AS EI INNER JOIN
						PRODUCTION_ORDERS AS PO ON EI.LOT_NO = PO.LOT_NO INNER JOIN
						EZGI_DESIGN_PIECE_ROWS AS EPR ON PO.STOCK_ID = EPR.PIECE_RELATED_ID INNER JOIN
						EZGI_IFLOW_OPTIMIZATION_ROW AS EOR ON EI.IFLOW_P_ORDER_ID = EOR.IFLOW_P_ORDER_ID
					WHERE        
						EPR.PIECE_TYPE = 1 AND 
						EOR.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
				) AS TBL
	</cfquery>
       <cfif get_orders.recordcount>
		<cfset satirlar = queryNew("parca_adi, malzeme, kesim_boy, kesim_en, adet, yon, lot_no, emir_no", "cf_sql_varchar, cf_sql_integer, Decimal, Decimal, Decimal, cf_sql_integer, cf_sql_varchar, cf_sql_varchar")> 
		<cfset product_cat_id_list = ''>
		<cfloop query="get_orders">
			<cfquery name="get_related_tree" datasource="#dsn3#">
					<!---Standart Parçalar --->
					SELECT      
						2 AS TYPE,
						PO.STOCK_ID, 
						MIN(E1.PIECE_ROW_ID) AS PIECE_ROW_ID, 
						PO.P_ORDER_ID, 
						PO.QUANTITY, 
						PO.P_ORDER_NO,
						PO.LOT_NO
					FROM            
						EZGI_DESIGN_PIECE_ROWS AS E1 INNER JOIN
						PRODUCTION_ORDERS AS PO ON E1.PIECE_RELATED_ID = PO.STOCK_ID INNER JOIN
						EZGI_DESIGN_PIECE_ROW AS EDPR ON E1.PIECE_ROW_ID = EDPR.RELATED_PIECE_ROW_ID INNER JOIN
						STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID
					WHERE        
						PO.P_ORDER_ID = #get_orders.P_ORDER_ID# AND 
						E1.PIECE_TYPE = 1 AND 
						PO.IS_DEMONTAJ = 0 AND
						ISNULL(S.IS_PROTOTYPE,0) = 0
					GROUP BY
						PO.STOCK_ID, 
						PO.P_ORDER_ID, 
						PO.QUANTITY, 
						PO.P_ORDER_NO,
						PO.LOT_NO
					UNION ALL
					SELECT       
						2 AS TYPE, 
						PO.STOCK_ID, 
						MIN(E1.PIECE_ROW_ID) AS PIECE_ROW_ID, 
						PO.P_ORDER_ID, 
						PO.QUANTITY, 
						PO.P_ORDER_NO, 
						PO.LOT_NO
					FROM            
						EZGI_DESIGN_PIECE_ROWS AS E1 INNER JOIN
						PRODUCTION_ORDERS AS PO ON E1.PIECE_RELATED_ID = PO.STOCK_ID LEFT OUTER JOIN
						EZGI_DESIGN_PIECE_ROW AS EDPR ON E1.PIECE_ROW_ID = EDPR.RELATED_PIECE_ROW_ID INNER JOIN
						STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID
					WHERE        
						PO.P_ORDER_ID = #get_orders.P_ORDER_ID# AND 
						E1.PIECE_TYPE = 1 AND 
						EDPR.PIECE_ROW_ROW_ID IS NULL AND 
						PO.IS_DEMONTAJ = 0 AND
						ISNULL(S.IS_PROTOTYPE,0) = 0
					GROUP BY
						PO.STOCK_ID, 
						PO.P_ORDER_ID, 
						PO.QUANTITY, 
						PO.P_ORDER_NO, 
						PO.LOT_NO
					<!---Özel Parçalar --->
					UNION ALL
					SELECT DISTINCT        
						2 AS TYPE,
						PO.STOCK_ID, 
						E1.PIECE_ROW_ID, 
						PO.P_ORDER_ID, 
						PO.QUANTITY, 
						PO.P_ORDER_NO,
						PO.LOT_NO
					FROM            
						EZGI_DESIGN_PIECE_ROWS AS E1 INNER JOIN
						PRODUCTION_ORDERS AS PO ON E1.PIECE_SPECT_RELATED_ID = PO.SPEC_MAIN_ID INNER JOIN
						EZGI_DESIGN_PIECE_ROW AS EDPR ON E1.PIECE_ROW_ID = EDPR.RELATED_PIECE_ROW_ID INNER JOIN
						STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID
					WHERE        
						PO.P_ORDER_ID = #get_orders.P_ORDER_ID# AND 
						E1.PIECE_TYPE = 1 AND 
						PO.IS_DEMONTAJ = 0 AND
						ISNULL(S.IS_PROTOTYPE,0) = 1
					UNION ALL
					SELECT DISTINCT        
						2 AS TYPE, 
						PO.STOCK_ID, 
						E1.PIECE_ROW_ID, 
						PO.P_ORDER_ID, 
						PO.QUANTITY, 
						PO.P_ORDER_NO,
						PO.LOT_NO
					FROM            
						EZGI_DESIGN_PIECE_ROWS AS E1 INNER JOIN
						PRODUCTION_ORDERS AS PO ON E1.PIECE_SPECT_RELATED_ID = PO.SPEC_MAIN_ID LEFT OUTER JOIN
						EZGI_DESIGN_PIECE_ROW AS EDPR ON E1.PIECE_ROW_ID = EDPR.RELATED_PIECE_ROW_ID INNER JOIN
						STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID
					WHERE        
						PO.P_ORDER_ID = #get_orders.P_ORDER_ID# AND 
						E1.PIECE_TYPE = 1 AND 
						EDPR.PIECE_ROW_ROW_ID IS NULL AND 
						PO.IS_DEMONTAJ = 0 AND
						ISNULL(S.IS_PROTOTYPE,0) = 1
				</cfquery>
			<cfif get_related_tree.recordcount>
				<cfloop query="get_related_tree">
					<cfset attributes.design_piece_row_id = get_related_tree.PIECE_ROW_ID>
					<cfset attributes.product_quantity = get_related_tree.QUANTITY>
					<cfquery name="get_product" datasource="#dsn3#">
							SELECT 
								MATERIAL_ID
							FROM 
								EZGI_DESIGN_PIECE_ROWS
							WHERE 
								PIECE_ROW_ID = #attributes.design_piece_row_id#
				</cfquery>
				<cfif get_product.recordcount and len(get_product.MATERIAL_ID)>
					<cfset product_cat_id_list = ListAppend(product_cat_id_list,get_product.MATERIAL_ID)>
				</cfif>
				</cfloop>
			</cfif>
			</cfloop>
		</cfif>
		
       <cfif ListLen(product_cat_id_list)>
           <cfset product_cat_id_list = ListDeleteDuplicates(product_cat_id_list,',')>
		    <cfquery name="get_malzeme" datasource="#dsn3#">
				    SELECT        
					    PT.STOCK_ID,
					    PT.RELATED_ID
				    FROM            
					    PRODUCT_TREE AS PT INNER JOIN
					    STOCKS AS S ON PT.RELATED_ID = S.STOCK_ID
					WHERE        
						PT.STOCK_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#product_cat_id_list#" list="true">) AND 
				        PT.RELATED_ID IS NOT NULL
				    GROUP BY 
					    PT.STOCK_ID, 
					    PT.RELATED_ID
		    </cfquery>
		    <!--- Bulunan yonga levhaları tablolara kaydet --->
		    <cfif get_malzeme.recordcount>
                <cfloop query="get_malzeme"> 
					<cfquery name="get_material_exist" datasource="#dsn3#">
						SELECT        
							POS.STOCK_ID, 
							round(SUM(POS.AMOUNT),4) AS AMOUNT
						FROM            
							PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
							PRODUCTION_ORDERS_STOCKS AS POS WITH (NOLOCK) ON PO.P_ORDER_ID = POS.P_ORDER_ID INNER JOIN
							STOCKS AS S WITH (NOLOCK) ON POS.STOCK_ID = S.STOCK_ID INNER JOIN
							EZGI_IFLOW_PRODUCTION_ORDERS AS EI WITH (NOLOCK) ON EI.LOT_NO = PO.LOT_NO
						WHERE  
							EI.IFLOW_P_ORDER_ID IN (SELECT IFLOW_P_ORDER_ID FROM EZGI_IFLOW_OPTIMIZATION_ROW WHERE OPTIMIZATION_ID = #attributes.optimization_id#) AND 
							S.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_malzeme.RELATED_ID#">
						GROUP BY 
							POS.STOCK_ID 
					</cfquery>
					<cfif not get_material_exist.recordcount>
						<script type="text/javascript">
							alert("<cfoutput>#get_malzeme.RELATED_ID#</cfoutput> Stok Bulunamadı Bulunamadı!");
						</script>
						<cfabort>
					</cfif>
                    <cfquery name="add_material" datasource="#dsn3#">
                            INSERT INTO EZGI_IFLOW_OPTIMIZATION_MATERIAL
                            (
                                OPTIMIZATION_ID,
                                STOCK_ID,
								MRP_AMOUNT
                            )
                            VALUES
                            (
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_malzeme.RELATED_ID#">,
                                <cfqueryparam cfsqltype="cf_sql_decimal" scale="4" value="#get_material_exist.AMOUNT#">
                            )
                    </cfquery>
                    <cfquery name="max_material_id" datasource="#dsn3#" result="max_id">    
                            SELECT MAX(OPTIMIZATION_MATERIAL_ID) AS MAX_MATERIAL_ID FROM EZGI_IFLOW_OPTIMIZATION_MATERIAL
                    </cfquery>
                    <cfquery name="add_material_row" datasource="#dsn3#">
                            INSERT INTO EZGI_IFLOW_OPTIMIZATION_MATERIAL_ROW
                            (
                                OPTIMIZATION_MATERIAL_ID,
                                STOCK_ID,
                                LOT_NO,
                                AMOUNT,
                                PRIORITY,
                                WORKSTATION_ID
                            )
                            VALUES
                            (
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#max_material_id.MAX_MATERIAL_ID#">,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_malzeme.RELATED_ID#">,
                                NULL,
                                0,
                                <cfqueryparam cfsqltype="cf_sql_integer" value="1">,
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#default_workstation_id#">
                            )
                    </cfquery>
                </cfloop>
            </cfif>
		</cfif>
		<!--- Malzemeler başarıyla oluşturuldu, parent pencereye bildir --->
		<script type="text/javascript">
			if (parent && parent.hasOptimizationMaterials !== undefined) {
				parent.hasOptimizationMaterials = true;
			}
		</script>
	</cfif>
	
	<!--- Malzeme listesini göster --->
	<cfquery name="get_optimization_materials" datasource="#dsn3#">
        SELECT 
            E.OPTIMIZATION_MATERIAL_ID, 
            E.OPTIMIZATION_ID, 
            E.STOCK_ID, 
            S.PRODUCT_NAME, 
            S1.PRODUCT_NAME AS SELECT_PRODUCT_NAME, 
            ER.STOCK_ID AS SELECT_STOCK_ID, 
            ER.WORKSTATION_ID,
            ER.OPTIMIZATION_MATERIAL_ROW_ID
        FROM     
            EZGI_IFLOW_OPTIMIZATION_MATERIAL AS E INNER JOIN
            EZGI_IFLOW_OPTIMIZATION_MATERIAL_ROW AS ER ON E.OPTIMIZATION_MATERIAL_ID = ER.OPTIMIZATION_MATERIAL_ID INNER JOIN
            STOCKS AS S ON E.STOCK_ID = S.STOCK_ID INNER JOIN
            STOCKS AS S1 ON ER.STOCK_ID = S1.STOCK_ID
        WHERE 
            E.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
	</cfquery>
	<cf_box>
		<cfsavecontent variable="materials_title">Optimizasyona Girecek Yonga Levhalar</cfsavecontent>
		<cf_box title="#materials_title#">
			<cf_grid_list>
				<thead>
					<tr>
						<th style="width:20px; text-align:center"><cf_get_lang dictionary_id='58577.Sıra'></th>
						<th style="text-align:center"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
						<th style="text-align:center"><cf_get_lang dictionary_id='58834.İstasyon'></th>
					</tr>
				</thead>
				<tbody>
					<cfif get_optimization_materials.recordcount>
						<cfoutput query="get_optimization_materials">
                            <cfquery name="get_related_stocks" datasource="#dsn3#">
                                SELECT 
                                    STOCK_ID,
                                    PRODUCT_NAME,
                                    1 AS DEFAULT_STOCKS
                                FROM     
                                    STOCKS
                                WHERE  
                                    STOCK_ID = #get_optimization_materials.STOCK_ID#
                                UNION ALL
                                SELECT 
                                    S.STOCK_ID,
                                    S.PRODUCT_NAME,
                                    0 AS DEFAULT_STOCKS
                                FROM     
                                    RELATED_PRODUCT AS RP INNER JOIN
                                    STOCKS AS S ON RP.RELATED_PRODUCT_ID = S.PRODUCT_ID INNER JOIN
                                    STOCKS AS S1 ON RP.PRODUCT_ID = S1.PRODUCT_ID
                                WHERE  
                                    S1.STOCK_ID = #get_optimization_materials.STOCK_ID#
                                    ORDER BY DEFAULT_STOCKS DESC
                            </cfquery>
						<tr>
							<td style="text-align:right">#currentrow#</td>
							<td style="text-align:left">
                                   <select name="select_stock_id_#currentrow#" id="select_stock_id_#currentrow#" class="material_stock_select" data-row-id="#get_optimization_materials.OPTIMIZATION_MATERIAL_ROW_ID#" style="width:100%; height:20px"> 
                                       <cfloop query="get_related_stocks">
                                           <option value="#get_related_stocks.STOCK_ID#" <cfif get_optimization_materials.SELECT_STOCK_ID eq get_related_stocks.STOCK_ID>selected</cfif>>#get_related_stocks.PRODUCT_NAME#</option>
                                       </cfloop>
                                   </select>
                               </td>
							<td style="text-align:center">
                                   <select name="select_workstation_id_#currentrow#" id="select_workstation_id_#currentrow#" class="material_workstation_select" data-row-id="#get_optimization_materials.OPTIMIZATION_MATERIAL_ROW_ID#" style="width:100%; height:20px">
                                       <option value="">Seçiniz</option>
                                       <cfloop query="get_default_workstation">
                                           <option value="#get_default_workstation.WORKSTATION_ID#" <cfif get_default_workstation.WORKSTATION_ID eq get_optimization_materials.WORKSTATION_ID>selected</cfif>>#get_default_workstation.WORKSTATION_NAME#</option>
                                       </cfloop>
                                   </select>
                               </td>
						</tr>
						</cfoutput>
					<cfelse>
						<tr>
							<td colspan="3" height="20" style="text-align:center">
								<cf_get_lang dictionary_id='57484.Kayıt Yok'>!
							</td>
						</tr>
					</cfif>
				</tbody>
			</cf_grid_list>
		<cf_box_footer>
			<div style="text-align:center; padding:10px;">
				<cfif not get_optimization_materials.recordcount>
					<button type="button" style="width:150px; height:30px;" class="btn btn-success" onclick="parent.createOptimizationMaterials()">
						<i class="fa fa-plus"></i> Malzeme Oluştur
					</button>
				<cfelse>
					<!-- Malzemeler varsa iki buton göster: Malzeme Sil (kırmızı) ve Şablonları Oluştur (mavi) -->
					<button type="button" id="btn_delete_materials" style="width:150px; height:30px; margin-right:10px;" class="btn btn-danger">
						<i class="fa fa-trash"></i> Malzeme Sil
					</button>
					<button type="button" id="btn_create_templates" style="width:150px; height:30px;" class="btn btn-primary">
						<i class="fa fa-magic"></i> Şablonları Oluştur
					</button>
				<script type="text/javascript">
					// Malzeme Sil butonu
					document.getElementById('btn_delete_materials').addEventListener('click', function() {
						if (confirm('Malzemeleri silmek istediğinizden emin misiniz?')) {
							if (parent && parent.deleteMaterials) {
								parent.deleteMaterials();
							} else {
								alert('Hata: Malzeme silme fonksiyonu bulunamadı!');
							}
						}
					});
					
					// Şablonları Oluştur butonu
					document.getElementById('btn_create_templates').addEventListener('click', function() {
						// Malzeme verilerini topla
						var materialData = [];
						var stockSelects = document.querySelectorAll('.material_stock_select');
						var workstationSelects = document.querySelectorAll('.material_workstation_select');
						
						for (var i = 0; i < stockSelects.length; i++) {
							var rowId = stockSelects[i].getAttribute('data-row-id');
							var stockId = stockSelects[i].value;
							var workstationId = workstationSelects[i].value;
							
							if (rowId && stockId && workstationId) {
								materialData.push({
									row_id: rowId,
									stock_id: stockId,
									workstation_id: workstationId
								});
							}
						}
						
						// Parent fonksiyonunu çağır
						if (parent && parent.OptimizationResultsAjax) {
							// Malzeme verisini parent'a geçir
							parent.optimizationMaterialData = JSON.stringify(materialData);
							parent.OptimizationResultsAjax(1);
						} else {
							alert('Hata: Şablon oluşturma fonksiyonu bulunamadı!');
						}
					});
				</script>
				</cfif>
			</div>
		</cf_box_footer>
		</cf_box>
	</cf_box>
</cfif>
