<!---
    File: upd_ezgi_iflow_master_plan.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cf_xml_page_edit>
<cfset Total_Main_Result = 0>
<cfset Total_Main = 0>
<cfset Total_Package = 0>
<cfset Total_Package_Result = 0>
<cfset Total_Order = 0>
<cfset Total_Order_Result = 0>
<cfset Total_Operation_Time = 0>
<cfset Total_Kalan_Operation_Time = 0>
	<style>
			/* ---------------------------------- */
			/* ÜRETİM BİLGİ TABLOSU STİLLERİ (BİLGİ KARTLARI) */
			/* ---------------------------------- */
	
			.production-info-table {
				width: 100%;
				height: 100%;
				border-collapse: separate; /* Hücreler arasında boşluk bırakmak için */
				border-spacing: 10px 5px; /* Hücreler arası yatay boşluk */
			}
	
			/* Tablonun tüm hücreleri için ortak stil */
			.production-info-table td {
				vertical-align: middle;
				text-align: center;
				padding: 0; /* İç dolguyu hücre stillerine taşıyalım */
				height: 60px; /* Butonlarla aynı hizada kalması için toplam yükseklik */
				
				/* Hücreleri tek bir kart gibi göstermek için */
				border: ; /* Tablo kenarlığı kaldırıldı */
				border-radius: 8px; /* Yumuşak köşe */
				box-shadow: 0 4px 8px rgba(0, 0, 0, 0.08); /* Modern, hafif gölge */
				background-color: #e0e2e3; /* Temiz beyaz kart arka planı */
			}
	
			/* Başlık Hücreleri (Toplam Modül, Biten Paket vb.) */
			.card-header {
				background-color: #f7f7f7; /* Başlık kısmı için çok hafif gri arka plan */
				color: #6c757d; /* Yumuşak gri metin */
				font-size: 15px;
				font-weight: 600;
				height: 30px; /* Başlık yüksekliği */
				padding-top: 5px; /* Başlık için üstten boşluk */
				/* Sadece üst kenarları yuvarlak yapmak için (Alt kısım değer hücresine yaslanacak) */
				border-top-left-radius: 8px; 
				border-top-right-radius: 8px;
			}
	
			/* Değer Hücreleri (Rakamlar) */
			.card-value {
				/* Değerler için kalan yüksekliği kullan */
				height: 90px;
				font-size: 36px; /* Daha büyük ve dikkat çekici */
				font-weight: 800; /* Ekstra kalın */
				padding-bottom: 10px; /* Alttan boşluk */
				/* Sadece alt kenarları yuvarlak yapmak için */
				border-bottom-left-radius: 8px; 
				border-bottom-right-radius: 8px;
			}
	
			/* RENK KODLAMASI - Daha kolay okuma ve vurgu için */
	
			/* 1. Birincil/Toplam Değerler (Örn: Toplam Modül, Toplam Paket) */
			.card-value.primary {
				color: #007bff; /* Mavi */
			}
	
			/* 2. Başarılı/Tamamlanmış Değerler (Örn: Biten Modül, Biten İş Emri) */
			.card-value.success {
				color: #28a745; /* Yeşil */
			}
	
			/* 3. Uyarı/Performans Değerleri (Örn: Oran %, Kritik İş Emri) */
			.card-value.warning {
				color: #ffc107; /* Sarı/Turuncu */
			}
	
			/* 4. Tüm Değerler için Varsayılan Renk (Eğer özel bir sınıf yoksa) */
			.card-value {
				color: #343a40; /* Koyu gri */
			}
			/* Modern Buton Temel Stilleri */
			.modern-action-button {
				/* Boyut ve Görünüm */
				width: 100%;
				height: 120px; /* Görselden korunmuştur, gerektiğinde ayarlanabilir */
				padding: 10px 5px; /* İç boşluk */
		
				border-radius: 8px; /* Yumuşak köşe */
				
				/* Renkler (Örnek, kurumsal renklere göre değiştirin) */
				background-color: #f6f8fa; /* Açık, modern bir arka plan */
				color: #333; /* Koyu metin */
				
				/* Tipografi */
				font-size: 12px; /* Biraz büyütüldü */
				font-weight: 600; /* Kalınlık korundu */
				text-align: center;
				line-height: 1.4;
				
				/* Geçiş Efekti (Daha yumuşak bir etkileşim için) */
				transition: all 0.3s ease;
				
				/* Butonun içindeki resim ve metni dikey ortalamak için Flexbox */
				display: flex;
				flex-direction: column; /* İçerikleri üst üste hizala */
				justify-content: center; /* Dikeyde ortala */
				align-items: center; /* Yatayda ortala */
				cursor: pointer;
			}
			
			/* Butonun Üzerine Gelme (Hover) Efekti */
			.modern-action-button:hover {
				background-color: #e0e6ed; /* Biraz daha koyu arka plan */
				box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); /* Hafif gölge */
				transform: translateY(-3px); /* Hafif yukarı kaydırma efekti */
			}
			
			/* Buton İçindeki Resimler İçin Stil (Eski resimlerinizin boyutunu ayarlar) */
			.modern-action-button img {
				/* Veya 40px daha belirgin olması için */
				height: 25px;
				margin-bottom: 5px; /* Metinle arasına boşluk */
				filter: drop-shadow(0 1px 1px rgba(0, 0, 0, 0,2)); /* İkona hafif gölge */
			}
			
	</style>
	
	<cfparam name="attributes.sort_type" default="10">
	
	<cfquery name="get_plan_info" datasource="#dsn#">
		SELECT        
			SS.DEPARTMENT_ID,
			SS.CONTROL_HOUR_1,
			E.MASTER_PLAN_ID, 
			E.MASTER_PLAN_START_DATE, 
			E.MASTER_PLAN_FINISH_DATE, 
			E.MASTER_PLAN_NAME, 
			E.MASTER_PLAN_NUMBER, 
			E.MASTER_PLAN_DETAIL, 
			E.MASTER_PLAN_STATUS, 
			E.MASTER_PLAN_STAGE, 
			E.IS_PROCESS, 
			E.EMPLOYYEE_ID, 
			E.MASTER_PLAN_PROJECT_ID,
			E.MASTER_PLAN_CAT_ID,
			E.GROSSTOTAL,
			E.MASTER_PLAN_PROCESS,
			CASE
				WHEN 
                	E.UPDATE_DATE > 0 
               	THEN 
                	E.UPDATE_DATE
				ELSE 
                	E.RECORD_DATE
			END MASTER_PLAN_PLANNING_DATE
		FROM            
			SETUP_SHIFTS AS SS WITH (NOLOCK) INNER JOIN
			#dsn3_alias#.EZGI_IFLOW_MASTER_PLAN AS E WITH (NOLOCK) ON SS.SHIFT_ID = E.MASTER_PLAN_CAT_ID
		WHERE        
			E.MASTER_PLAN_ID = #attributes.master_plan_id#
	</cfquery>
	<cfset attributes.shift_id = get_plan_info.MASTER_PLAN_CAT_ID>
	<cfset attributes.start_date = get_plan_info.MASTER_PLAN_START_DATE>
	<cfset attributes.finish_date = get_plan_info.MASTER_PLAN_FINISH_DATE>
    
	<!---Üretim Emirleri Alınıyor--->
	<cfinclude template="../query/get_ezgi_iflow_production_order.cfm">
	<cfif get_production_orders.recordcount>
    	<cfset Total_Main = 0>
		<cfset iflow_product_id_list = ValueList(get_production_orders.IFLOW_P_ORDER_ID)>
		<cfset iflow_product_id_list = ListDeleteDuplicates(iflow_product_id_list,',')>
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
        </cfif>
        <cfif get_package_list.recordcount>
			<cfset Total_Package = get_package_list.PAKET_EMIR>
            <cfset Total_Package_Result = get_package_list.PAKET_URETILEN>
        </cfif>
        <cfif get_all_p_order_list.recordcount>
			<cfset Total_Order = get_all_p_order_list.TOTAL_EMIR>
            <cfset Total_Order_Result = get_all_p_order_list.TOTAL_URETILEN>
        </cfif>
        <cfif get_operations_all.recordcount>
			<cfset Total_Operation = get_operations_all.TOTAL_AMOUNT>
            <cfset Total_Operation_Time = get_operations_all.TOTAL_OPTIMUM_TIME>
        </cfif>
        <cfif get_operation_result_all.recordcount>
        	<cfset Total_Kalan_Operation_Time = get_operation_result_all.KALAN_OPTIMUM_TIME>
        </cfif>
	<cfelse>
		<cfset arama_yapilmali = 1>
	</cfif>

	<cf_catalystHeader>
	<div class="col col-12 col-xs-12">
		<cf_box>
			<cfform name="form_basket" method="post" action="">
				<cfinput type="hidden" name="ara_stok" id="ara_stok" value="0">
				<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
				<input name="operation_time_key" id="operation_time_key" value="0" type="hidden">
				<cfinput name="master_plan_id" id="master_plan_id" type="hidden" value="#attributes.master_plan_id#">
				<cf_box_elements>
					 <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
						<div class="form-group" id="item-planstatus">
							<div class="col col-1 col-xs-12">
								   <input type="checkbox" name="master_plan_status" value="1" <cfif get_plan_info.MASTER_PLAN_STATUS eq 1>checked="checked"</cfif> >
							  </div>
							<div class="col col-3 col-xs-12">
								   <label><cf_get_lang dictionary_id='57493.Aktif'></label>
							  </div>
							<div class="col col-1 col-xs-12">
								   <input type="checkbox" name="is_stock_reserve" value="1" <cfif get_plan_info.MASTER_PLAN_PROCESS eq 1>checked="checked"</cfif> >
							  </div>
							<div class="col col-7 col-xs-12">
								   <label><cf_get_lang dictionary_id='41185.Stok Rezerve Et'></label>
							  </div>
						  </div>
						  <div class="form-group" id="item-plantype">
							 <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='1030.Planlama Türü'></label>
							<div class="col col-8 col-xs-12">
								   <cfinput type="text" name="plantype" id="plantype" value="#get_plan_info.MASTER_PLAN_NAME#" readonly>
							  </div>
						  </div>
						 <div class="form-group" id="item-planno">
							<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57880.Belge No'></label>
							 <div class="col col-8 col-xs-12">
								<cfinput type="text" name="plantyno" id="planno" value="#get_plan_info.MASTER_PLAN_NUMBER#" readonly>
							 </div>
						  </div>
					</div>
					<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
						  <div class="form-group" id="item-plandate">
							 <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></label>
							<div class="col col-8 col-xs-12">
								   <div class="input-group">	
									<cfsavecontent variable="message"><cf_get_lang dictionary_id='292.Planlama Tarihi Girmelisiniz'> !</cfsavecontent>
									<cfinput type="text" name="planning_date" id="planning_date" required="yes" value="#dateformat(get_plan_info.MASTER_PLAN_PLANNING_DATE,dateformat_style)#" validate="eurodate" message="#message#" maxlength="10" style="width:70px;" readonly>
									   <span class="input-group-addon"><cf_wrk_date_image date_field="planning_date"></span>
								   </div>     
							  </div>
						  </div>
						 <div class="form-group" id="item-planrecord">
							<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57899.Kaydeden'></label>
							 <div class="col col-8 col-xs-12">
								<cfinput type="text" name="planrecord" id="planrecord" value="#get_emp_info(get_plan_info.EMPLOYYEE_ID,0,0)#" readonly>
							 </div>
						  </div>
					</div>
					<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
						  <div class="form-group" id="item-planstart">
							 <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></label>
							<div class="col col-4 col-xs-12">
								   <div class="input-group">	
									<cfinput type="text" name="start_date" id="start_date" value="#dateformat(attributes.start_date,dateformat_style)#" validate="eurodate" maxlength="10" style="width:70px;" readonly>
									   <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
								   </div>     
							  </div>
							<cfoutput>
							<div class="col col-2 col-xs-12">
								<select name="start_h" id="start_h">
									<cfloop from="0" to="23" index="i">
										<option value="#i#" 
											<cfif isdefined('attributes.start_date') and timeformat(attributes.start_date,'HH') eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#
										</option>
									</cfloop>
								</select>
							</div>
							<div class="col col-2 col-xs-12">
								<select name="start_m" id="start_m">
									<cfloop from="0" to="59" index="i">
										<option value="#i#" 
											<cfif isdefined('attributes.start_date') and timeformat(attributes.start_date,'MM') eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#
										</option>
									</cfloop>
								</select>
							</div> 
							</cfoutput>   
						  </div>
						 <div class="form-group" id="item-planfinish">
							 <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></label>
							<div class="col col-4 col-xs-12">
								   <div class="input-group">	
									<cfinput type="text" name="finish_date" id="finish_date" value="#dateformat(attributes.finish_date,dateformat_style)#" validate="eurodate" maxlength="10" style="width:70px;">
									   <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
								   </div>     
							  </div>
							<cfoutput>
							<div class="col col-2 col-xs-12">
								<select name="finish_h" id="finish_h">
									<cfloop from="0" to="23" index="i">
										<option value="#i#" 
											<cfif isdefined('attributes.finish_date') and timeformat(attributes.finish_date,'HH') eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#
										</option>
									</cfloop>
								</select>
							</div>
							<div class="col col-2 col-xs-12">
								<select name="finish_m" id="finish_m">
									<cfloop from="0" to="59" index="i">
										<option value="#i#" 
											<cfif isdefined('attributes.finish_date') and timeformat(attributes.finish_date,'MM') eq i> selected</cfif>><cfif i lt 10>0</cfif>#i#
										</option>
									</cfloop>
								</select>
							</div> 
							</cfoutput>
						  </div>
					</div>
					<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
						  <div class="form-group" id="item-planstage">
							 <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41129.Süreç/Asama'></label>
							<div class="col col-8 col-xs-12">
								  <cf_workcube_process is_upd='0' select_value='#get_plan_info.MASTER_PLAN_STAGE#' process_cat_width='128' is_detail='1'>
							  </div>
						  </div>
						 <div class="form-group" id="item-plandetail">
							<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
							 <div class="col col-8 col-xs-12">
								<cfinput name="detail" type="text" value="#get_plan_info.MASTER_PLAN_DETAIL#" maxlength="500">
							 </div>
						  </div>
					</div>
				</cf_box_elements>
				<cf_box>
					<cfoutput>
                         <table width="100%" cellpadding="1" cellspacing="1" border="0">
                             <tr>
                                <td style="height:120px">
                                    <table class="production-info-table">
                                        <tr >
                                            
                                            <td class="card-header" nowrap="nowrap"><cf_get_lang dictionary_id='1064.Toplam Modül'></td>
                                            <td class="card-header" nowrap="nowrap"><cf_get_lang dictionary_id='1063.Biten Modül'></td>
                                            <td class="card-header" nowrap="nowrap"><cf_get_lang dictionary_id='1059.Toplam Paket'></td>
                                            <td class="card-header" nowrap="nowrap"><cf_get_lang dictionary_id='1062.Biten Paket'></td>
                                            
                                            <td class="card-header"  nowrap="nowrap"><cf_get_lang dictionary_id='57492.Toplam'> <cf_get_lang dictionary_id='58868.İş Emri'></td>
                                            <td class="card-header"  nowrap="nowrap"><cf_get_lang dictionary_id='302.Biten'> <cf_get_lang dictionary_id='58868.İş Emri'></td>
                                            <td class="card-header"  nowrap="nowrap"><cf_get_lang dictionary_id='58456.Oran'> %</td>
                                        </tr>
                                        <tr >
                                            
                                            <td class="card-value primary" nowrap="nowrap">#TlFormat(Total_Main,0)#</td>
                                            <td class="card-value success" nowrap="nowrap">#TlFormat(Total_Main_Result,0)#</td>
                                            <td class="card-value primary" nowrap="nowrap">#TlFormat(Total_Package,0)#</td>
                                            <td class="card-value success" nowrap="nowrap">#TlFormat(Total_Package_Result,0)#</td>
                                            
                                            <td class="card-value primary" nowrap="nowrap">#TlFormat(Total_Order,0)#</td>
                                            <td class="card-value success" nowrap="nowrap">#TlFormat(Total_Order_Result,0)#</td>
                                            <td class="card-value warning" nowrap="nowrap">
                                            	<cfif x_rate_display eq 1> <!---Miktara Oranla--->
													<cfif Total_Order_Result gt 0 and Total_Order gt 0>
                                                        #AmountFormat(Total_Order_Result/Total_Order*100)#
                                                    <cfelse>
                                                        0
                                                    </cfif>
                                                <cfelse> <!---Operasyon Zamanına Oranla--->
                                                	<cfif Total_Operation_Time gt 0 and Total_Kalan_Operation_Time gt 0>
                                                        #AmountFormat((Total_Operation_Time-Total_Kalan_Operation_Time)/Total_Operation_Time*100)#
                                                    <cfelse>
                                                        #AmountFormat(100)#
                                                    </cfif>
                                                </cfif>
                                          	</td>
                                        </tr>
                                    </table>
                                </td>
                                <td style="vertical-align:middle; width:5%">
                                    <a style="cursor:pointer" onclick="production_operations();">
                                        <button type="button" name="operations_form" class="modern-action-button">
                                            <img src="/images/action.gif" alt="Operasyonlar" border="0"><br>
                                            <cf_get_lang dictionary_id='36376.Operasyonlar'>
                                        </button>
                                    </a>
                                </td>
                                
                                <td style="vertical-align:middle; width:5%">
                                       <a style="cursor:pointer" onclick="production_plans();">
                                           <button type="button" name="production_form"  class="modern-action-button">
                                            <img src="/images/action_plus.gif" alt="<cf_get_lang dictionary_id='1066.Tüm Emirler'>" border="0"><br>
                                            <cf_get_lang dictionary_id='51318.Üretim Emirleri'>
                                        </button>
                                     </a>
                                  </td>
                                   <td style="vertical-align:middle; width:5%">
                                       <a style="cursor:pointer" onclick="workstation_load()">
                                           <button type="button" name="refresh_form"  class="modern-action-button">
                                            <img src="/images/workdevanalys.gif" alt="<cf_get_lang dictionary_id='1380.Manuel İş Yükleme'>" border="0"><br>
                                            <cf_get_lang dictionary_id='1380.Manuel İş Yükleme'>
                                        </button>
                                     </a>
                                  </td>
                                <td style="vertical-align:middle; width:5%">
                                       <a style="cursor:pointer" onclick="grupla(-3);">
                                           <button type="button" name="metarial_list"  class="modern-action-button">
                                            <img src="/images/forklift.gif" alt="<cf_get_lang dictionary_id='443.Malzeme İhtiyacı'>" border="0"><br>
                                            <cf_get_lang dictionary_id='444.Malzeme'>
                                        </button>
                                     </a>
                                  </td>
                                <td style="vertical-align:middle; width:5%">
                                       <a style="cursor:pointer" onclick="del_form();">
                                           <button type="button" name="delete_form" class="modern-action-button">
                                            <img src="/images/delete.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"><br>
                                            <cf_get_lang dictionary_id='57463.Sil'>
                                        </button>
                                     </a>
                                  </td>
                                <td style="vertical-align:middle; width:5%">
                                       <a style="cursor:pointer" onclick="upd_form();">
                                           <button type="button" name="upd_form"  class="modern-action-button">
                                            <img src="/images/enabled.gif" alt="<cf_get_lang dictionary_id='57464.Güncelle'>" border="0"><br>
                                            <cf_get_lang dictionary_id='57464.Güncelle'>
                                        </button>
                                     </a>
                                  </td>
                                <td style="vertical-align:middle; width:5%">
                                       <a style="cursor:pointer" onclick="window.history.go(-1);">
                                           <button type="button" name="exit_form"  class="modern-action-button">
                                            <img src="/images/exit.gif" alt="<cf_get_lang dictionary_id='57462.Vazgeç'>" border="0"><br>
                                            <cf_get_lang dictionary_id='57462.Vazgeç'>
                                        </button>
                                     </a>
                                  </td>
                                <td style="vertical-align:middle; width:5%">
                                       <a style="cursor:pointer" onclick="grupla(-4);">
                                           <button type="button" name="trasferring" class="modern-action-button">
                                            <img src="/images/transfer.gif" alt="<cf_get_lang dictionary_id='583.Optimizasyon'>" border="0"><br><cf_get_lang dictionary_id='583.Optimizasyon'>
                                        </button>
                                     </a>
                                  </td>
                                <td style="vertical-align:middle; width:5%">
                                       <a style="cursor:pointer" onclick="grupla(-2);">
                                           <button type="button" name="print_form"  class="modern-action-button">
                                            <img src="/images/print_plus.gif" alt="<cf_get_lang dictionary_id='57474.Yazdır'>" border="0"><br>
                                            <cf_get_lang dictionary_id='57474.Yazdır'>
                                        </button>
                                     </a>
                                  </td>
                            </tr>
                       	</table>
                    </cfoutput>
				</cf_box>	
				<cf_box>
				  	<cf_grid_list>
                    <thead>
                        <tr valign="middle">
                            <!-- sil -->
                            <th style="width:1%; text-align:center" onclick="gizle_goster(product_order_detail);connectHeadAjax();gizle_goster_nested('siparis_goster','siparis_gizle');">
                                <img id="siparis_goster" style="cursor:pointer;" src="/images/listele.gif" title="<cf_get_lang dictionary_id ='58596.Göster'>">
                                <img id="siparis_gizle" style="cursor:pointer;display:none;" src="/images/listele_down.gif" title="<cf_get_lang dictionary_id ='58628.Gizle'>">
                            </th>
                            <th style="width:20px; text-align:center; vertical-align:middle">
                                <input type="checkbox" alt="<cf_get_lang dictionary_id ='206.Hepsini Seç'>" onClick="grupla(-1);">
                            </th>
                            <th style="width:20px; text-align:center; vertical-align:middle" class="header_icn_none" >
                                <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_iflow_production_order_parti&master_plan_id=#attributes.master_plan_id#</cfoutput>','wide');">
                                    <img src="/images/copy_list.gif" title="<cf_get_lang dictionary_id='1355.Parti Transfer'>">
                                  </a>
                                <a href="javascript://" onclick="window.open('<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_iflow_production_order&master_plan_id=#attributes.master_plan_id#</cfoutput>','_blank');">
                                    <img src="/images/plus_list.gif" title="<cf_get_lang dictionary_id='57582.Ekle'>">
                                  </a>
                              </th>
                            <!-- sil -->
                            <th style="width:25px; text-align:center; vertical-align:middle;" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='470.Parti'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='45498.Lot No'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57416.Proje'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57630.Tip'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57657.Ürün'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57635.Miktar'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='302.Biten'> %</th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57629.Açıklama'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='1059.Toplam Paket'></th>
                            
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58211.Sipariş No'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='60609.Termin Tarihi'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57571.Ünvan'></th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr id="product_order_detail" class="nohover" style="display:none" >
                            <td colspan="16">
                                <div align="left" id="DISPLAY_PRODUCT_ORDER_INFO" style="border:none;"></div>
                            </td>
                        </tr>
                        <cfset delete_control = 1>
						<cfif get_production_orders.recordcount>
                            <cfset total_row = get_production_orders.recordcount + 1>
                            <cfoutput query="get_production_orders">
                                <tr>
                                    <!-- sil --> 
                                    <td align="center" id="order_row#currentrow#" class="color-row" onclick="gizle_goster(product_order_detail#currentrow#);connectAjax('#currentrow#','#IFLOW_P_ORDER_ID#');gizle_goster_nested('siparis_goster#currentrow#','siparis_gizle#currentrow#');">
                                        <img id="siparis_goster#currentrow#" style="cursor:pointer;" src="/images/listele.gif" title="<cf_get_lang dictionary_id ='58596.Göster'>">
                                         <img id="siparis_gizle#currentrow#" style="cursor:pointer;display:none;" src="/images/listele_down.gif" title="<cf_get_lang dictionary_id ='58628.Gizle'>">
                                    </td>
                                    <td style="text-align:center;">
                                        <input type="checkbox" name="select_production" value="#IFLOW_P_ORDER_ID#">
                                    </td>
                                    <td style="text-align:center;">
                                        <cfif IS_STAGE eq 4>
                                            <img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='1058.Sanal Üretim Emri'>">
                                        <cfelseif IS_STAGE eq 0>
                                             <img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                         <cfelseif IS_STAGE eq 1>
                                              <img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='398.Başladı'>">
                                            <cfset delete_control = 0>
                                          <cfelseif IS_STAGE eq 2>
                                               <img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='305.Bitti'>">
                                            <cfset delete_control = 0>
                                        <cfelseif IS_STAGE eq 3>
                                            <img src="/images/grey_glob.gif" title="<cf_get_lang dictionary_id='298.Arıza'>">
                                            <cfset delete_control = 0>
                                         </cfif>
                                    </td>
                                    <input type="hidden" name="sira_#currentrow#_#IFLOW_P_ORDER_ID#" id="sira_#currentrow#_#IFLOW_P_ORDER_ID#" value="#currentrow#">
                                    <td style="text-align:center;">#currentrow#</td>
                                    <td style="text-align:center; font-weight:bold">
                                        <a href="javascript://" onclick="window.open('#request.self#?fuseaction=prod.popup_upd_ezgi_iflow_production_order&rel_p_order_id=#rel_p_order_id#&master_plan_id=#attributes.master_plan_id#','_blank');" class="tableyazi">
                                            #P_ORDER_PARTI_NUMBER#
                                          </a>
                                      </td>
                                    <td style="text-align:center;">
                                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.popup_list_ezgi_iflow_production_operations&is_form_submitted=1&keyword=#LOT_NO#','longpage');">
                                            #LOT_NO#
                                        </a>
                                    </td>
                                    <td style="text-align:center;">
                                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=Project.projects&event=det&id=#project_id#','longpage');" class="tableyazi">
                                            #project_number#
                                          </a>
                                      </td>
                                    <td style="text-align:center;">
                                        <cfif PRODUCT_TYPE eq 1><cf_get_lang dictionary_id='58511.Takım'>
                                        <cfelseif PRODUCT_TYPE eq 2><cf_get_lang dictionary_id='141.Modül'>
                                        <cfelseif PRODUCT_TYPE eq 3><cf_get_lang dictionary_id='100.Paket'>
                                        <cfelseif PRODUCT_TYPE eq 4><cf_get_lang dictionary_id='45.Parça'>
                                        <cfelse><cf_get_lang dictionary_id='404.Hammadde'>
                                        </cfif>
                                    </td>
                                    <td style="text-align:left;" nowrap="nowrap" title="#PRODUCT_NAME#"><cfinput type="text" name="product_name_#currentrow#" value="#PRODUCT_NAME#" style="border:none; width:95%"></td>
                                    <td style="text-align:center;">#AmountFormat(QUANTITY,0)#</td>
                                    <td style="text-align:right;">#AmountFormat(AMOUNT,2)#</td>
                                    <td nowrap title="#DETAIL#"><cfinput type="text" name="detail_#currentrow#" value="#detail#" style="border:none; width:95%"></td>
                                    <td style="text-align:center;">#AmountFormat(PAKET_SAYI,0)#</td>
                                     <td style="text-align:center;">#ORDER_NUMBER#</td>
                                    <td style="text-align:center;">#DateFormat(DELIVERDATE,dateformat_style)#</td>
                                    <td style="text-align:left;">
                                        <cfif len(COMPANY_ID)>
                                            #get_par_info(COMPANY_ID,1,1,0)#
                                        <cfelseif len(CONSUMER_ID)>
                                            #get_cons_info(CONSUMER_ID,0,0)#
                                        </cfif>
                                    </td>
                                </tr>
                                <tr id="product_order_detail#currentrow#" class="nohover" style="display:none" >
                                    <td colspan="16">
                                        <div align="left" id="DISPLAY_PRODUCT_ORDER_INFO#currentrow#" style="border:none;"></div>
                                    </td>
                                </tr>
                            </cfoutput>
                            <tfoot>
                                <tr><td colspan="50" class="color-header"></td></tr>
                            </tfoot>  	
                        <cfelse>
                            <tr> 
                                <td colspan="50" height="20"><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>
                            </tr>
                        </cfif>
					</tbody>
					</cf_grid_list>
		   		</cf_box>
      		</cfform>
      	<cf_box>
	</div>      
	<script type="text/javascript">
		function connectAjax(crtrow,IFLOW_P_ORDER_ID)
		{
			var bb = '<cfoutput>#request.self#?fuseaction=prod.emptypopup_ezgi_iflow_ajax_product_order_info</cfoutput>&IFLOW_P_ORDER_ID='+IFLOW_P_ORDER_ID;
			AjaxPageLoad(bb,'DISPLAY_PRODUCT_ORDER_INFO'+crtrow,1);
		}
		function connectHeadAjax()
		{
			var master_plan_id=document.form_basket.master_plan_id.value;
			iflow_p_order_id_list = '';
			chck_leng = document.getElementsByName('select_production').length;
			for(ci=0;ci<chck_leng;ci++)
			{
				var my_objets = document.all.select_production[ci];
				if(chck_leng == 1)
					var my_objets =document.all.select_production;
					
				if(my_objets.checked == true)
					iflow_p_order_id_list +=my_objets.value+',';
			}
			iflow_p_order_id_list = iflow_p_order_id_list.substr(0,iflow_p_order_id_list.length-1);
			var bbb = '<cfoutput>#request.self#?fuseaction=prod.emptypopup_ezgi_iflow_ajax_product_order_info</cfoutput>&IFLOW_P_ORDER_ID='+iflow_p_order_id_list+'&master_plan_id='+master_plan_id;
			AjaxPageLoad(bbb,'DISPLAY_PRODUCT_ORDER_INFO',1);
		}
		function hesapla()
		{
			windowopen('<cfoutput>#request.self#?fuseaction=prod.emptypopup_upd_ezgi_iflow_master_plan_operation&master_plan_id=#attributes.master_plan_id#</cfoutput>','small');	
		}
		function grupla(type)
		{
			var master_plan_id=document.form_basket.master_plan_id.value;
			iflow_p_order_id_list = '';
			chck_leng = document.getElementsByName('select_production').length;
			for(ci=0;ci<chck_leng;ci++)
			{
				var my_objets = document.all.select_production[ci];
				if(chck_leng == 1)
					var my_objets =document.all.select_production;
				if(type == -1){//hepsini seç denilmişse	
					if(my_objets.checked == true)
						my_objets.checked = false;
					else
						my_objets.checked = true;
				}
				else
				{
					if(my_objets.checked == true)
						iflow_p_order_id_list +=my_objets.value+',';
				}
			}
			iflow_p_order_id_list = iflow_p_order_id_list.substr(0,iflow_p_order_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(type < -1)
			{
				if(list_len(iflow_p_order_id_list,','))
				{
					if(type == -2)
					windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_print_files&print_type=289</cfoutput>&iid='+iflow_p_order_id_list+'&master_plan_id='+master_plan_id,'page');
					if(type == -3)
					window.open('<cfoutput>#request.self#?fuseaction=prod.popup_dsp_ezgi_iflow_product_metarial_need</cfoutput>&iid='+iflow_p_order_id_list+'&master_plan_id='+master_plan_id,'_blank');
					if(type == -4)
					windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_iflow_transferring</cfoutput>&iid='+iflow_p_order_id_list+'&master_plan_id='+master_plan_id,'small');
				}
				else
				alert("<cf_get_lang dictionary_id='578.İşlem Yapmak İstediğiniz Üretim Emirlerini Seçiniz'>!")
			}
		}
		function upd_form()
		{
			if (form_basket.start_date.value.length == 0)
			{
				alert("<cf_get_lang dictionary_id='531.Plan Başlama Tarihi Girmelisiniz'> !");
				return false;
			}
			if (form_basket.finish_date.value.length == 0)
			{
				alert("<cf_get_lang dictionary_id='532.Plan Bitiş Tarihi Girmelisiniz'> !");
				return false;
			}
			if(process_cat_control())
			{
				sor=confirm("<cf_get_lang dictionary_id='579.Bilgileri Güncelliyorum. Emin misiniz'>?");
				if (sor == true)
				{
					document.getElementById("form_basket").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_upd_ezgi_iflow_master_plan";
					document.getElementById("form_basket").submit();
				}
				else
					return false;
			}
			else
				return false;
		}
		function del_form()
		{
			<cfif delete_control eq 1>
				if(process_cat_control())
				{
					sor=confirm("<cf_get_lang dictionary_id='580.Üretim Planı ve Tüm Emirler Tamamen Silinecektir. Emin misiniz'>?");
					if (sor == true)
					{
						window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_iflow_master_plan&master_plan_id=#attributes.master_plan_id#</cfoutput>";
					}
					else
						return false;
				}
				else
					return false;
			<cfelse>
				alert("<cf_get_lang dictionary_id='581.Plana Ait Ürünlerin Üretimi Başladığından Toplu Silme Yapamazsınız'> !");
				return false;
			</cfif>
		}
		function upd_operation(operation_type_id)
		{
			windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_upd_ezgi_iflow_operation_rate&master_plan_id=#attributes.master_plan_id#</cfoutput>&operation_type_id='+operation_type_id,'small');
		}
		function production_plans()
		{
			var master_plan_id=document.form_basket.master_plan_id.value;
			iflow_p_order_id_list = '';
			chck_leng = document.getElementsByName('select_production').length;
			for(ci=0;ci<chck_leng;ci++)
			{
				var my_objets = document.all.select_production[ci];
				if(chck_leng == 1)
					var my_objets =document.all.select_production;
					
				if(my_objets.checked == true)
					iflow_p_order_id_list +=my_objets.value+',';
			}
			iflow_p_order_id_list = iflow_p_order_id_list.substr(0,iflow_p_order_id_list.length-1);
			window.open('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_iflow_production_order&is_form_submitted=1&master_plan_id=#attributes.master_plan_id#</cfoutput>&iflow_p_order_id_list='+iflow_p_order_id_list,'_blank');	
		}
		function production_operations()
		{
			window.open('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_iflow_production_operations&is_form_submitted=1&master_plan_id=#attributes.master_plan_id#&x_is_parti=#1#&x_station_level=#x_station_level#</cfoutput>','_blank');	
		}
		function workstation_load()
		{
			window.open('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_iflow_workstation_load&master_plan_id=#attributes.master_plan_id#&x_is_parti=1&x_station_level=#x_station_level#</cfoutput>','_blank');	
		}
	</script>
	