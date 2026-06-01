<!---
    File: upd_ezgi_optimization.cfm
    Folder: AddOns\ezgi\e_production\form
    Author: Ezgi Yazılım
    Date: #dateFormat(now(), "dd/mm/yyyy")#
    Description: Optimizasyon Güncelleme Sayfası
--->

<cfparam name="attributes.optimization_id" default="">
<cf_xml_page_edit>

<cfif isDefined("attributes.optimization_id") and len(attributes.optimization_id) and isNumeric(attributes.optimization_id)>
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
			ISNULL(IS_MATERIAL_UPDATE, 0) AS IS_MATERIAL_UPDATE,
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
		<cfif len(get_optimization.MASTER_PLAN_ID) and isNumeric(get_optimization.MASTER_PLAN_ID)>
			<cfquery name="get_master_plan_info" datasource="#dsn3#">
				SELECT 
					MASTER_PLAN_ID,
					MASTER_PLAN_DETAIL,
					MASTER_PLAN_NUMBER
				FROM 
					EZGI_IFLOW_MASTER_PLAN
				WHERE 
					MASTER_PLAN_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_optimization.MASTER_PLAN_ID#">
			</cfquery>
		<cfelse>
			<cfquery name="get_master_plan_info" datasource="#dsn3#">
				SELECT 
					MASTER_PLAN_ID,
					MASTER_PLAN_DETAIL,
					MASTER_PLAN_NUMBER
				WHERE 
					1 = 0
			</cfquery>
		</cfif>
	<cfquery name="get_optimization_material" datasource="#dsn3#">
		SELECT 
			OPTIMIZATION_MATERIAL_ID, 
			OPTIMIZATION_ID, 
			STOCK_ID
		FROM 
			EZGI_IFLOW_OPTIMIZATION_MATERIAL WHERE OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
	</cfquery>
	
	<!--- Şablon var mı kontrol et --->
	<cfquery name="get_optimization_results" datasource="#dsn3#">
		SELECT 
			OPTIMIZATION_RESULT_ID
		FROM 
			EZGI_IFLOW_OPTIMIZATION_RESULTS 
		WHERE 
			OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
	</cfquery>
	
	<cf_catalystHeader>
		<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
			<cf_box>
		    	<cfform name="form_basket" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_optimization&optimization_id=#attributes.optimization_id#">
		        	<cfinput type="hidden" name="optimization_id" id="optimization_id" value="#attributes.optimization_id#">
		        	<cf_basket_form id="form_basket">
		                <div class="row">
		                        <div class="col col-12 uniqueRow">
		                            <div class="row formContent">
		                                <cf_box_elements>
		                                    <cfoutput>
		                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
		                                        <div class="form-group" id="item-optimization_status">
		                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
		                                            <div class="col col-8 col-xs-12">
		                                                <input type="checkbox" id="optimization_status" name="optimization_status" value="1" <cfif get_optimization.OPTIMIZATION_STATUS>checked</cfif>>
		                                            </div>
		                                        </div>
		                                        <div class="form-group" id="item-optimization_number">
		                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57880.Belge No'></label>
		                                            <div class="col col-8 col-xs-12">
		                                                <cfinput type="text" name="optimization_number" id="optimization_number" readonly="yes" value="#get_optimization.OPTIMIZATION_NUMBER#" maxlength="20">
		                                            </div>
		                                        </div>
		                                        <div class="form-group" id="item-master_plan">
		                                            <label class="col col-4 col-xs-12">Master Plan</label>
		                                            <div class="col col-8 col-xs-12">
		                                                <input name="master_plan_id" type="text" id="master_plan_id" value="<cfif isDefined("get_master_plan_info") and get_master_plan_info.recordcount>#get_master_plan_info.MASTER_PLAN_NUMBER# <cfif len(get_master_plan_info.MASTER_PLAN_DETAIL)>- #get_master_plan_info.MASTER_PLAN_DETAIL#</cfif></cfif>" readonly="readonly" style="width:200px;">
		                                            </div>
		                                        </div>
		                                    </div>
		                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                                                <div class="form-group" id="item-optimization_date">
		                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57073.Belge Tarihi'></label>
		                                            <div class="col col-8 col-xs-12">
		                                                <div class="input-group">
		                                                    <cfinput type="text" name="optimization_date" id="optimization_date" value="#optimization_date_value#" style="width:100px;" validate="#validate_style#" maxlength="10">
		                                                    <span class="input-group-addon"><cf_wrk_date_image date_field="optimization_date"></span>
		                                                </div>
		                                            </div>
		                                        </div>
												<div class="form-group" id="item-optimization_emp">
		                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57899.Kaydeden'></label>
		                                            <div class="col col-8 col-xs-12">
		                                                <div class="input-group">
		                                                    <input type="hidden" name="optimization_emp_id" id="optimization_emp_id" value="<cfif len(get_optimization.OPTIMIZATION_EMP)>#get_optimization.OPTIMIZATION_EMP#<cfelse>#session.ep.userid#</cfif>">
		                                                    <input name="optimization_emp_name" type="text" id="optimization_emp_name" style="width:120px;" placeholder="<cf_get_lang dictionary_id='57899.Kaydeden'>" onFocus="AutoComplete_Create('optimization_emp_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','optimization_emp_id','form_basket','3','125');" value="<cfif len(optimization_emp_name)>#optimization_emp_name#</cfif>" autocomplete="off" readonly="readonly">
		                                                    <span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_name=form_basket.optimization_emp_name&field_emp_id=form_basket.optimization_emp_id&select_list=1,9','list');return false"></span>
		                                                </div>
		                                            </div>
		                                        </div>
                                                
		                                    </div>
		                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
												<div class="form-group" id="item-optimization_detail">
		                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
		                                            <div class="col col-8 col-xs-12">
		                                                <textarea name="optimization_detail" id="optimization_detail" style="width:200px; height:65px" maxlength="500">#get_optimization.OPTIMIZATION_DETAIL#</textarea>
		                                            </div>
		                                        </div>
		                                    </div>
											<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
		                                        
		                                    </div>
		                                    </cfoutput>
		                                </cf_box_elements>
		                                <cf_box_footer>
		                                    <cf_record_info 
		                                        query_name="get_optimization"
		                                        record_emp="RECORD_EMP" 
		                                        record_date="RECORD_DATE"
		                                        update_emp="UPDATE_EMP"
		                                        update_date="UPDATE_DATE">
		                                    <cfif get_optimization.IS_MATERIAL_UPDATE eq 1>    
		                                    <cf_workcube_buttons 
		                                        is_upd='1' 
												 is_delete='0'
		                                        add_function='kontrol()'
												>
		                                    <cfelse>
		                                        <cf_workcube_buttons 
		                                            is_upd='1' 
		                                            add_function='kontrol()'
												del_function='sil_kontrol()'
												>
		                                    </cfif>
		                                </cf_box_footer>
		                            </div>
		                        </div>
		                    </div>
		                </cf_basket_form>
		        </cfform>
		    </cf_box>
		</div>
		
		<!--- Üç Sütunlu Bölüm: Üretim Planları ve Optimizasyon Sonuçları --->
		<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
			<div class="row">
            	<!--- Gizli Sütün (Simulasyon için) --->
				<div class="col col-8 col-md-8 col-sm-12 col-xs-12" style="display:none" id="optimization_display_div">
					
				</div>
				<!--- Sol Sütun: Optimizasyona Henüz Girmemiş Üretim Planları (Sürükle-Bırak için) --->
				<div class="col col-4 col-md-4 col-sm-12 col-xs-12" id="available_plans_div">
					
				</div>
			<!--- Orta Sütun: Optimizasyona Katılacak Üretim Planları --->
			<div class="col col-4 col-md-4 col-sm-12 col-xs-12" ondrop="dropHandler(event)" ondragover="allowDrop(event)" id="optimization_plans_div">
				
			</div>
			<cfif get_optimization_results.recordcount>
				<!--- Sağ Sütun: Optimizasyon Sonucu Oluşan Şablonlar --->
				<div class="col col-4 col-md-4 col-sm-12 col-xs-12" id="optimization_results_div">
					
				</div>
			<cfelse>
				<!--- Sağ Sütun: Optimizasyona Girecek Yonga Levhalar --->
				<div class="col col-4 col-md-4 col-sm-12 col-xs-12" id="optimization_materials_div">
					
				</div>
			</cfif>
			</div>
		</div>
		
	<script type="text/javascript">
		// Şablonlar oluştu mu? Varsayılan: hayır. AJAX sonuç sayfası bu değişkeni güncelleyecek.
		var hasOptimizationResults = false;
		// Malzemeler oluştu mu? Varsayılan: <cfif get_optimization_material.recordcount>true<cfelse>false</cfif>
		var hasOptimizationMaterials = <cfif get_optimization_material.recordcount>true<cfelse>false</cfif>;
			
	function createOptimizationMaterials()
	{
		// Malzeme oluşturma animasyonu göster
		showOptimizationLoading('Malzemeler Oluşturuluyor...', 'Yonga levhalar tespit ediliyor, lütfen bekleyiniz');
		
		// XMLHttpRequest ile malzeme oluştur
		var xhr = new XMLHttpRequest();
		var url = '<cfoutput>#request.self#?fuseaction=prod.ajax_create_ezgi_optimization_materials&add_process=1&optimization_id=#attributes.optimization_id#</cfoutput>';
		
		xhr.open('GET', url, true);
		xhr.onreadystatechange = function() {
			if (xhr.readyState === 4) {
				if (xhr.status === 200) {
					// Malzemeler oluşturuldu, sayfayı yenile
					setTimeout(function() {
						window.location.reload();
					}, 500);
				} else {
					hideOptimizationLoading();
					alert('Malzemeler oluşturulurken bir hata oluştu. Lütfen tekrar deneyiniz.');
				}
			}
		};
		xhr.onerror = function() {
			hideOptimizationLoading();
			alert('Malzemeler oluşturulurken bir bağlantı hatası oluştu. Lütfen tekrar deneyiniz.');
		};
		xhr.send();
	}
	
	function deleteMaterials()
	{
		// Malzemeleri sil - Özel mesaj göster
		showOptimizationLoading('Malzemeler Siliniyor...', 'Lütfen bekleyiniz');
		
		var xhr = new XMLHttpRequest();
		var url = '<cfoutput>#request.self#?fuseaction=prod.ajax_delete_ezgi_optimization_materials&optimization_id=#attributes.optimization_id#</cfoutput>';
		
		xhr.open('GET', url, true);
		xhr.onreadystatechange = function() {
			if (xhr.readyState === 4) {
				hideOptimizationLoading();
				if (xhr.status === 200) {
					// Malzemeler silindi, flag'i sıfırla
					window.hasOptimizationMaterials = false;
					
					// Boş malzeme listesini göster
					AjaxPageLoad('<cfoutput>#request.self#?fuseaction=prod.ajax_create_ezgi_optimization_materials&optimization_id=#attributes.optimization_id#</cfoutput>','optimization_materials_div',1);
					
					// Plan listesini tazele ki sil ikonları hemen geri gelsin
					AjaxPageLoad('<cfoutput>#request.self#?fuseaction=prod.ajax_add_ezgi_optimization_row&optimization_id=#attributes.optimization_id#</cfoutput>','optimization_plans_div',1);
				} else {
					alert('Malzemeler silinirken bir hata oluştu. Lütfen tekrar deneyiniz.');
				}
			}
		};
		xhr.onerror = function() {
			hideOptimizationLoading();
			alert('Malzemeler silinirken bir bağlantı hatası oluştu. Lütfen tekrar deneyiniz.');
		};
		xhr.send();
	}
	
	function OptimizationMaterialsAjax()
	{
		AjaxPageLoad('<cfoutput>#request.self#?fuseaction=prod.ajax_create_ezgi_optimization_materials&optimization_id=#attributes.optimization_id#</cfoutput>','optimization_materials_div',1);
	}
		
	function collectMaterialData()
	{
		// Tüm select box'lardan veri topla (iframe içinden de çalışmalı)
		var materialData = [];
		
		// Önce kendi document'ımızda ara
		var stockSelects = document.querySelectorAll('.material_stock_select');
		var workstationSelects = document.querySelectorAll('.material_workstation_select');
		
		// Eğer bulunamazsa, iframe içinde ara
		if (stockSelects.length === 0) {
			var materialsDiv = document.getElementById('optimization_materials_div');
			if (materialsDiv && materialsDiv.querySelector('iframe')) {
				var iframe = materialsDiv.querySelector('iframe');
				if (iframe && iframe.contentDocument) {
					stockSelects = iframe.contentDocument.querySelectorAll('.material_stock_select');
					workstationSelects = iframe.contentDocument.querySelectorAll('.material_workstation_select');
				}
			}
		}
		
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
		
		return JSON.stringify(materialData);
	}

			function kontrol()
			{
				if (form_basket.optimization_date.value.length == 0)
				{
					alert("<cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'> !");
					return false;
				}
				if (form_basket.optimization_emp_id.value.length == 0 || form_basket.optimization_emp_id.value == 0)
				{
					alert("<cf_get_lang dictionary_id='57899.Kaydeden'> seçmelisiniz !");
					return false;
				}
				return true;
			}
			function sil_kontrol()
			{
				sor=confirm('Dikkat Tüm Optimizasyon ve Şablonlar Silinecektir. Emin misiniz?');
				if(sor==true)
				{
					window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_optimization&optimization_id=#attributes.optimization_id#</cfoutput>";
					return true;
				}
				else
					return false;
			}
			function OptimizationPlansAjax()
			{
				AjaxPageLoad('<cfoutput>#request.self#?fuseaction=prod.ajax_del_ezgi_optimization_row&optimization_id=#attributes.optimization_id#&master_plan_id=#get_master_plan_info.master_plan_id#</cfoutput>','available_plans_div',1);
				AjaxPageLoad('<cfoutput>#request.self#?fuseaction=prod.ajax_add_ezgi_optimization_row&optimization_id=#attributes.optimization_id#</cfoutput>','optimization_plans_div',1);
				
			}
		// Sürükle-Bırak Fonksiyonları
		function allowDrop(ev) 
		{
			// Malzemeler veya şablonlar oluştuysa sürükle-bırak devre dışı
			if (window.hasOptimizationMaterials || window.hasOptimizationResults) {
				ev.preventDefault();
				return;
			}
			ev.preventDefault();
		}
		function dragStart(ev) 
		{
			// Malzemeler veya şablonlar oluştuysa sürükle-bırak başlatma
			if (window.hasOptimizationMaterials) {
				alert("Malzemeler oluşturulduktan sonra üretim planı ekleyemezsiniz.");
				ev.preventDefault();
				return false;
			}
			if (window.hasOptimizationResults) {
				alert("Şablonlar oluşturulduktan sonra üretim planı ekleyemezsiniz.");
				ev.preventDefault();
				return false;
			}
			ev.dataTransfer.setData("text", ev.target.id);
			ev.dataTransfer.effectAllowed = "move";
		}
		function dropHandler(ev) 
		{
			// Malzemeler veya şablonlar oluştuysa sürükle-bırak işlem yapmasın
			if (window.hasOptimizationMaterials) {
				ev.preventDefault();
				alert("Malzemeler oluşturulduktan sonra üretim planı ekleyemezsiniz.");
				return false;
			}
			if (window.hasOptimizationResults) {
				ev.preventDefault();
				alert("Şablonlar oluşturulduktan sonra üretim planı ekleyemezsiniz.");
				return false;
			}
				ev.preventDefault();
				var data = ev.dataTransfer.getData("text");
				var draggedElement = document.getElementById(data);
				
				if (draggedElement && draggedElement.tagName === 'TR') 
				{
					// IFLOW_P_ORDER_ID'yi al
					var iflowPOrderId = draggedElement.getAttribute('data-p-order-id');
				
					if (!iflowPOrderId) 
					{
						alert("Hata: Üretim planı bilgisi bulunamadı!");
						return;
					}
					else
					{
						AjaxPageLoad('<cfoutput>#request.self#?fuseaction=prod.ajax_add_ezgi_optimization_row&add_process=1&optimization_id=#attributes.optimization_id#</cfoutput>&iflow_p_order_id='+iflowPOrderId,'optimization_plans_div',1);	
						AjaxPageLoad('<cfoutput>#request.self#?fuseaction=prod.ajax_del_ezgi_optimization_row&optimization_id=#attributes.optimization_id#&master_plan_id=#get_master_plan_info.master_plan_id#</cfoutput>','available_plans_div',1);
					}
				}
			}
			
		function deleteOptimizationRow(iflowPOrderId) 
		{
			// Malzemeler veya şablonlar oluştuysa silme yapmasın
			if (window.hasOptimizationMaterials) {
				alert("Malzemeler oluşturulduktan sonra üretim planı silemezsiniz!");
				return;
			}
			if (window.hasOptimizationResults) {
				alert("Şablonlar oluşturulduktan sonra üretim planı silemezsiniz!");
				return;
			}
			
			if (!iflowPOrderId) 
			{
				alert("Hata: Üretim planı bilgisi bulunamadı!");
				return;
			}
			else
			{
				AjaxPageLoad('<cfoutput>#request.self#?fuseaction=prod.ajax_add_ezgi_optimization_row&del_process=1&optimization_id=#attributes.optimization_id#</cfoutput>&iflow_p_order_id='+iflowPOrderId,'optimization_plans_div',1);
				AjaxPageLoad('<cfoutput>#request.self#?fuseaction=prod.ajax_del_ezgi_optimization_row&optimization_id=#attributes.optimization_id#&master_plan_id=#get_master_plan_info.master_plan_id#</cfoutput>','available_plans_div',1);
			}
		}
			
	function showOptimizationLoading(mainText, subText) {
		// Varsayılan mesajlar
		if (!mainText) mainText = 'Optimizasyon Hesaplanıyor...';
		if (!subText) subText = 'Parçalar yerleştiriliyor, lütfen bekleyiniz';
		
		// Önce results_div'i dene, yoksa materials_div'i kullan
		var resultsDiv = document.getElementById('optimization_results_div');
		if (!resultsDiv) {
			resultsDiv = document.getElementById('optimization_materials_div');
		}
		if (resultsDiv) {
				// Mevcut içeriği sakla
				var existingContent = resultsDiv.innerHTML;
				if (existingContent && existingContent.trim() !== '') {
					resultsDiv.setAttribute('data-original-content', existingContent);
				}
				
				// Loading overlay oluştur
				var overlay = document.createElement('div');
				overlay.id = 'optimization_loading_overlay';
				overlay.style.cssText = 'position: relative; width: 100%; min-height: 300px; background-color: rgba(255, 255, 255, 0.98); border: 2px solid #3498db; border-radius: 8px; display: flex; flex-direction: column; align-items: center; justify-content: center; z-index: 1000; box-shadow: 0 4px 6px rgba(0,0,0,0.1);';
				
				// Spinner container
				var spinnerContainer = document.createElement('div');
				spinnerContainer.style.cssText = 'margin-bottom: 25px;';
				
				// Ana spinner
				var spinner = document.createElement('div');
				spinner.style.cssText = 'width: 60px; height: 60px; border: 6px solid #f3f3f3; border-top: 6px solid #3498db; border-right: 6px solid #2ecc71; border-radius: 50%; animation: optimizationSpin 1s linear infinite; margin: 0 auto;';
				
				// İç spinner (çift animasyon için)
				var innerSpinner = document.createElement('div');
				innerSpinner.style.cssText = 'width: 40px; height: 40px; border: 4px solid transparent; border-top: 4px solid #e74c3c; border-radius: 50%; animation: optimizationSpinReverse 0.8s linear infinite; margin: 5px auto;';
				
				spinnerContainer.appendChild(spinner);
				spinnerContainer.appendChild(innerSpinner);
				
				// Mesaj container
				var messageContainer = document.createElement('div');
				messageContainer.style.cssText = 'text-align: center;';
				
				var mainMessage = document.createElement('div');
				mainMessage.style.cssText = 'font-size: 18px; font-weight: bold; color: #2c3e50; margin-bottom: 10px;';
				mainMessage.innerHTML = mainText;
				
				var subMessage = document.createElement('div');
				subMessage.style.cssText = 'font-size: 14px; color: #7f8c8d; font-style: italic;';
				subMessage.innerHTML = subText;
					
					// Progress dots (animasyonlu)
					var progressDots = document.createElement('div');
					progressDots.id = 'optimization_progress_dots';
					progressDots.style.cssText = 'font-size: 20px; color: #3498db; margin-top: 15px; letter-spacing: 5px;';
					progressDots.innerHTML = '...';
					
					messageContainer.appendChild(mainMessage);
					messageContainer.appendChild(subMessage);
					messageContainer.appendChild(progressDots);
					
					overlay.appendChild(spinnerContainer);
					overlay.appendChild(messageContainer);
					
					// CSS animasyonları ekle
					if (!document.getElementById('optimization_spinner_style')) {
						var style = document.createElement('style');
						style.id = 'optimization_spinner_style';
						style.textContent = '@keyframes optimizationSpin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } } @keyframes optimizationSpinReverse { 0% { transform: rotate(360deg); } 100% { transform: rotate(0deg); } } @keyframes optimizationDots { 0%, 20% { content: "."; } 40% { content: ".."; } 60%, 100% { content: "..."; } }';
						document.head.appendChild(style);
					}
					
					// Progress dots animasyonu
					var dotCount = 0;
					var dotInterval = setInterval(function() {
						dotCount = (dotCount % 3) + 1;
						var dots = '';
						for (var i = 0; i < dotCount; i++) {
							dots += '.';
						}
						if (progressDots && document.getElementById('optimization_loading_overlay')) {
							progressDots.innerHTML = dots;
						} else {
							clearInterval(dotInterval);
						}
					}, 500);
					overlay.setAttribute('data-dot-interval-id', dotInterval.toString());
					
					// Overlay'i göster - önce tüm içeriği temizle
					while (resultsDiv.firstChild) {
						resultsDiv.removeChild(resultsDiv.firstChild);
					}
					resultsDiv.appendChild(overlay);
				}
			}
			
			function hideOptimizationLoading() {
				var overlay = document.getElementById('optimization_loading_overlay');
				if (overlay) {
					// Interval'i temizle
					var dotIntervalId = overlay.getAttribute('data-dot-interval-id');
					if (dotIntervalId) {
						clearInterval(parseInt(dotIntervalId));
					}
					// Overlay'i tamamen kaldır
					if (overlay.parentNode) {
						overlay.parentNode.removeChild(overlay);
					}
				}
		// Ekstra kontrol: Eğer hala overlay varsa, tüm div'i temizle
		var resultsDiv = document.getElementById('optimization_results_div');
		if (!resultsDiv) {
			resultsDiv = document.getElementById('optimization_materials_div');
		}
		if (resultsDiv) {
			var remainingOverlay = resultsDiv.querySelector('#optimization_loading_overlay');
			if (remainingOverlay) {
				remainingOverlay.remove();
			}
		}
	}
			
	function OptimizationResultsAjax(process)
	{
		if (process == 1)
		{
			// Loading göster
			showOptimizationLoading();
			
			// Malzeme verilerini al (iframe'den gelebilir)
			var materialData = window.optimizationMaterialData || collectMaterialData();
			
			console.log('Material Data:', materialData);
			
			// Önce optimizasyonu oluştur, sonra sonuçları göster
			var xhr = new XMLHttpRequest();
			var url = '<cfoutput>#request.self#?fuseaction=prod.ajax_create_ezgi_optimization_results&add_process=1&optimization_id=#attributes.optimization_id#</cfoutput>';
			
			xhr.open('POST', url, true);
			xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
			xhr.onreadystatechange = function() {
				if (xhr.readyState === 4) {
					if (xhr.status === 200) {
						// Optimizasyon oluşturuldu, sayfayı yenile
						setTimeout(function() {
							hideOptimizationLoading();
							// Sayfayı yenile ki sütunlar düzgün görünsün
							window.location.reload();
						}, 500);
					} else {
						hideOptimizationLoading();
						alert('Optimizasyon oluşturulurken bir hata oluştu. Lütfen tekrar deneyiniz.');
					}
				}
			};
			xhr.onerror = function() {
				hideOptimizationLoading();
				alert('Optimizasyon oluşturulurken bir bağlantı hatası oluştu. Lütfen tekrar deneyiniz.');
			};
			xhr.send('material_data=' + encodeURIComponent(materialData));
		}
			else if (process == 2)
			{
				// Şablonları silerken de senkron bir akış kullan (önce sil, sonra ekranı güncelle)
				showOptimizationLoading('Şablonlar Siliniyor...', 'Lütfen bekleyiniz');

					var xhrDel = new XMLHttpRequest();
					var delUrl = '<cfoutput>#request.self#?fuseaction=prod.ajax_create_ezgi_optimization_results&del_process=1&optimization_id=#attributes.optimization_id#</cfoutput>';

					xhrDel.open('GET', delUrl, true);
				xhrDel.onreadystatechange = function() {
					if (xhrDel.readyState === 4) {
						if (xhrDel.status === 200) {
							// Şablonlar ve malzemeler silindi, sayfayı yenile ki doğru sütunlar görünsün
							setTimeout(function() {
								window.location.reload();
							}, 500);
						} else {
							hideOptimizationLoading();
							alert('Şablonlar silinirken bir hata oluştu. Lütfen tekrar deneyiniz.');
						}
					}
				};
					xhrDel.onerror = function() {
						hideOptimizationLoading();
						alert('Şablonlar silinirken bir bağlantı hatası oluştu. Lütfen tekrar deneyiniz.');
					};
					xhrDel.send();
				}
				else if (process == 0)
				{
					// İlk yükleme için normal AjaxPageLoad kullan
					AjaxPageLoad('<cfoutput>#request.self#?fuseaction=prod.ajax_create_ezgi_optimization_results&optimization_id=#attributes.optimization_id#</cfoutput>','optimization_results_div',1);
				}
			}
			function optimization_display(sheetno,stockid,optimizitionid)
			{
				var availableDiv = document.getElementById('available_plans_div');
				var plansDiv = document.getElementById('optimization_plans_div');
				var displayDiv = document.getElementById('optimization_display_div');
				
				// CSS transition için style ekle
				if (!document.getElementById('optimization_animation_style')) {
					var style = document.createElement('style');
					style.id = 'optimization_animation_style';
					style.textContent = '.optimization-column { transition: opacity 0.4s ease-out, transform 0.4s ease-out; } .optimization-column-hide { opacity: 0; transform: translateX(-30px); } .optimization-column-show { opacity: 1; transform: translateX(0); }';
					document.head.appendChild(style);
				}
				
				// Sütunlara class ekle
				availableDiv.classList.add('optimization-column');
				plansDiv.classList.add('optimization-column');
				displayDiv.classList.add('optimization-column');
				
				// Önce gizleme animasyonu başlat
				availableDiv.style.opacity = "1";
				plansDiv.style.opacity = "1";
				availableDiv.classList.add('optimization-column-hide');
				plansDiv.classList.add('optimization-column-hide');
				
				// Animasyon bitince display'i none yap ve yeni sütunu göster
				setTimeout(function() {
					availableDiv.style.display = "none";
					plansDiv.style.display = "none";
					availableDiv.classList.remove('optimization-column-hide');
					plansDiv.classList.remove('optimization-column-hide');
					
					// Yeni sütunu göster (başlangıçta görünmez)
					displayDiv.style.display = "";
					displayDiv.style.opacity = "0";
					displayDiv.style.transform = "translateX(30px)";
					
					// AJAX çağrısını yap
					AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.ajax_ezgi_optimization_display&optimization_id='+optimizitionid+'&stock_id='+stockid+'&sheet_no='+sheetno,'optimization_display_div',1);
					
					// Kısa bir gecikme sonrası gösterim animasyonu başlat
					setTimeout(function() {
						displayDiv.classList.add('optimization-column-show');
						displayDiv.style.opacity = "1";
						displayDiv.style.transform = "translateX(0)";
					}, 100);
				}, 400);
			}
			
			function optimization_display_close()
			{
				var availableDiv = document.getElementById('available_plans_div');
				var plansDiv = document.getElementById('optimization_plans_div');
				var displayDiv = document.getElementById('optimization_display_div');
				
				// Önce display sütununu gizle
				displayDiv.classList.add('optimization-column-hide');
				displayDiv.style.opacity = "0";
				displayDiv.style.transform = "translateX(30px)";
				
				// Animasyon bitince display'i none yap ve diğer sütunları göster
				setTimeout(function() {
					displayDiv.style.display = "none";
					displayDiv.classList.remove('optimization-column-hide', 'optimization-column-show');
					
					// Diğer sütunları göster (başlangıçta görünmez)
					availableDiv.style.display = "";
					plansDiv.style.display = "";
					availableDiv.style.opacity = "0";
					plansDiv.style.opacity = "0";
					availableDiv.style.transform = "translateX(-30px)";
					plansDiv.style.transform = "translateX(-30px)";
					
					// Kısa bir gecikme sonrası gösterim animasyonu başlat
					setTimeout(function() {
						availableDiv.classList.add('optimization-column-show');
						plansDiv.classList.add('optimization-column-show');
						availableDiv.style.opacity = "1";
						plansDiv.style.opacity = "1";
						availableDiv.style.transform = "translateX(0)";
						plansDiv.style.transform = "translateX(0)";
					}, 50);
				}, 400);
			}
		OptimizationPlansAjax();
		<cfif get_optimization_results.recordcount>
			OptimizationResultsAjax(0);
		<cfelse>
			OptimizationMaterialsAjax();
		</cfif>
		</script>
	<cfelse>
		<script type="text/javascript">
			alert("<cf_get_lang dictionary_id='57484.Kayıt Yok'>");
			window.location.href = "<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_ezgi_optimization</cfoutput>";
		</script>
	</cfif>
<cfelse>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='57484.Kayıt Yok'>");
		window.location.href = "<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_ezgi_optimization</cfoutput>";
	</script>
</cfif>

