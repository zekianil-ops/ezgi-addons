<cf_xml_page_edit fuseact="sales.list_ezgi_connect">
<cfparam name="attributes.brand_id" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.anamenu" default="1">
<cfparam name="attributes.variation_select" default="">
<cfparam name="attributes.price_value" default="">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default= 20>
<cfparam name="attributes.startrow" default= 1>
<cfparam name="attributes.kategori" default="">
<cfparam name="attributes.model" default="">
<cfparam name="attributes.modul" default="">
<cfparam name="attributes.renk" default="">
<cfparam name="attributes.id_list" default="">
<cfparam name="attributes.categori_id_list" default="">
<cfparam name="attributes.model_id_list" default="">
<cfparam name="attributes.modul_id_list" default="">
<cfparam name="attributes.color_id_list" default="">
<cfparam name="attributes.consumer_reference_code" default="">
<cfparam name="attributes.partner_reference_code" default="">
<cfparam name="attributes.price_catid" default="-2">
<cfparam name="attributes.card_paymethod_id" default="">
<cfparam name="attributes.paymethod_id" default="">
<cfparam name="attributes.paymethod" default="">
<cfset connect_row_id_list = ''>

<cfquery name="get_session" datasource="#dsn#">
	SELECT USERID FROM #dsn_alias#.WRK_SESSION WHERE ACTION_PAGE LIKE N'%sales.list_ezgi_connect&event=upd&connect_id=<cfoutput>#attributes.connect_id#</cfoutput>%' AND USERID <> #session.ep.userid#
</cfquery>
<cfif get_session.recordcount>
	<script type="text/javascript">
		alert("Çalışmak İstediğiniz Sayfa <cfoutput>#get_emp_info(get_session.USERID,0,0)#</cfoutput>tarafından kullanılmaktadır!");
		window.history.go(-1);
	</script>
    <cfabort>
</cfif>
<cfinclude template="basket_ezgi_connect_queries.cfm">
<style>
	/* Tab Navigation Modernizasyonu */
	.tabNav {
		background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
		border-radius: 12px 12px 0 0;
		padding: 8px 8px 0 8px;
		margin-bottom: 0;
		border-bottom: 2px solid #e9ecef;
		list-style: none;
		display: flex;
		flex-wrap: wrap;
	}
	.tabNav li {
		transition: all 0.3s ease;
		margin-right: 4px;
		border-radius: 8px 8px 0 0;
		list-style: none;
	}
	.tabNav li a {
		padding: 12px 20px;
		font-weight: 600;
		color: #495057;
		transition: all 0.3s ease;
		border-radius: 8px 8px 0 0;
		display: block;
		text-decoration: none;
	}
	.tabNav li:hover a {
		background-color: rgba(95, 142, 225, 0.1);
		color: #5f8ee1;
	}
	.tabNav li.active {
		background: linear-gradient(135deg, #5f8ee1 0%, #44b6ae 100%);
		box-shadow: 0 -2px 8px rgba(68, 182, 174, 0.3);
	}
	.tabNav li.active a {
		color: #fff;
		background: transparent;
	}
	.tabNav li.active:hover a {
		color: #fff;
		background: transparent;
	}
	/* Üst Tab Navigation (Sepet Numaraları) */
	#tab-head:first-of-type .tabNav {
		background: transparent;
		border-bottom: none;
		padding: 0;
		margin-bottom: 0;
	}
	#tab-head:first-of-type .tabNav li {
		margin-right: 8px;
		border-radius: 8px;
		background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
		border: 2px solid #e9ecef;
	}
	#tab-head:first-of-type .tabNav li a {
		padding: 8px 16px;
		border-radius: 6px;
		color: #495057;
	}
	#tab-head:first-of-type .tabNav li:hover {
		background: linear-gradient(135deg, #e9ecef 0%, #dee2e6 100%);
		border-color: #5f8ee1;
	}
	#tab-head:first-of-type .tabNav li:hover a {
		color: #5f8ee1;
		background: transparent;
	}
	#tab-head:first-of-type .tabNav li.active {
		background: linear-gradient(135deg, #5f8ee1 0%, #44b6ae 100%);
		border-color: #5f8ee1;
		box-shadow: 0 2px 8px rgba(68, 182, 174, 0.3);
	}
	#tab-head:first-of-type .tabNav li.active a {
		color: #fff;
	}
	/* Tab Content Modernizasyonu */
	#tab-content {
		background: #fff;
		border-radius: 0 0 12px 12px;
		padding: 20px;
		padding-top: 0;
		padding-bottom: 0;
		box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
		min-height: 400px;
	}
	/* Müşteri Bilgisi sekmesi için padding'i tamamen kaldır */
	#tab-content:has(#minfo:not([style*="display: none"])) {
		padding-bottom: 0 !important;
		padding: 20px 20px 0 20px !important;
		margin-bottom: 0 !important;
		min-height: auto !important;
		height: auto !important;
	}
	/* Müşteri Bilgisi aktifken tab-content'in tüm alt boşluklarını kaldır */
	#tab-content:has(#minfo:not([style*="display: none"])) * {
		margin-bottom: 0 !important;
	}
	#tab-content:has(#minfo:not([style*="display: none"])) > *:last-child {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Müşteri Bilgisi aktifken tab-content'in kendisini de kontrol et */
	body:has(#minfo:not([style*="display: none"])) #tab-content {
		padding-bottom: 0 !important;
		margin-bottom: 0 !important;
		min-height: auto !important;
		height: auto !important;
		max-height: none !important;
	}
	#minfo.content {
		margin-top: 0 !important;
		margin-bottom: 0 !important;
		padding-top: 0 !important;
		padding-bottom: 0 !important;
	}
	#minfo.content .col {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	#minfo.content .row {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Müşteri Bilgisi sekmesi içindeki cf_box boşluklarını kaldır */
	#minfo.content .cf_box,
	#minfo.content .cf_box_elements {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	#minfo.content .col.col-12 {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Sepet sekmesi için padding'i tamamen kaldır */
	#tab-content:has(#sepet:not([style*="display: none"])) {
		padding-bottom: 0 !important;
		padding: 20px 20px 0 20px !important;
		margin-bottom: 0 !important;
		min-height: auto !important;
		height: auto !important;
	}
	/* Sepet aktifken tab-content'in tüm alt boşluklarını kaldır */
	#tab-content:has(#sepet:not([style*="display: none"])) * {
		margin-bottom: 0 !important;
	}
	#tab-content:has(#sepet:not([style*="display: none"])) > *:last-child {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Sepet aktifken tab-content'in kendisini de kontrol et */
	body:has(#sepet:not([style*="display: none"])) #tab-content {
		padding-bottom: 0 !important;
		margin-bottom: 0 !important;
		min-height: auto !important;
		height: auto !important;
		max-height: none !important;
	}
	#tab-content #sepet:not([style*="display: none"]) ~ * {
		display: none;
	}
	#tab-content.margin-top-10 {
		margin-top: 0 !important;
		margin-bottom: 0 !important;
	}
	#sepet.content {
		margin-top: 0 !important;
		margin-bottom: 0 !important;
		padding-top: 0 !important;
		padding-bottom: 0 !important;
	}
	#sepet.content .col {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	#sepet.content .row {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	#sepet.content > * {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	#sepet.content > *:last-child {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Sepet içeriği için özel stil - Tüm boşlukları kaldır */
	.sepet-content-modern {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Sepet içindeki tüm son elementlerin boşluğunu kaldır */
	#sepet > div:last-child,
	#sepet .col:last-child,
	#sepet .row:last-child {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	#sepet .cf_box,
	#sepet .cf_box_footer,
	#sepet .cf_box_elements,
	#sepet #basket_bar {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
		margin-top: 0 !important;
	}
	#sepet table,
	#sepet .cf_grid_list,
	#sepet .cf_grid_list tbody,
	#sepet .cf_grid_list tbody tr:last-child {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	#sepet .cf_box:last-child,
	#sepet #basket_bar:last-child {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Sepet aktifken tab-content padding'ini kaldır */
	body:has(#sepet:not([style*="display: none"])) #tab-content {
		padding-bottom: 0 !important;
	}
	/* Sepet içindeki tüm son elementlerin boşluğunu kaldır */
	#sepet > div:last-child,
	#sepet .col:last-child,
	#sepet .row:last-child {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* cf_box custom tag'inin boşluklarını kaldır */
	#sepet .portBox,
	#sepet .portBoxBodyStandart,
	#sepet .boxRow,
	#sepet .uniqueBox,
	#sepet #basket_bar,
	#sepet #basket_bar .portBox,
	#sepet #basket_bar .portBoxBodyStandart,
	#sepet #body_basket_bar {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	#sepet #basket_bar:last-child,
	#sepet #basket_bar .portBoxBodyStandart:last-child,
	#sepet #body_basket_bar:last-child {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Sepet içindeki footer ve son elementler */
	#sepet .footer,
	#sepet #footer_basket_bar {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Sepet içindeki tüm tablo ve grid elementleri */
	#sepet .cf_grid_list tbody tr:last-child td,
	#sepet table tbody tr:last-child td,
	#sepet table tfoot,
	#sepet .cf_grid_list tfoot {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Sepet içindeki tüm div'lerin son child'ları */
	#sepet div:last-child {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Sepet içindeki TÜM elementlerin alt boşluklarını kaldır */
	#sepet * {
		margin-bottom: 0 !important;
	}
	#sepet > *:last-child,
	#sepet > *:last-child > *:last-child,
	#sepet > *:last-child > *:last-child > *:last-child {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Sepet div'inin kendisi */
	#sepet {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
		margin: 0 !important;
		padding: 0 !important;
		min-height: auto !important;
		height: auto !important;
		max-height: none !important;
	}
	/* Sepet içindeki col container */
	#sepet .col {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
		margin: 0 !important;
		padding: 0 !important;
	}
	/* Footer dosyasındaki cf_box elementleri */
	#body_basket_bar .cf_box:last-child,
	#body_basket_bar .portBox:last-child,
	#body_basket_bar .portBoxBodyStandart:last-child,
	#body_basket_bar .cf_box,
	#body_basket_bar .portBox,
	#body_basket_bar .portBoxBodyStandart {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
		margin: 0 !important;
		padding: 0 !important;
		min-height: auto !important;
		height: auto !important;
		max-height: none !important;
	}
	/* Footer dosyasındaki tüm elementler */
	#body_basket_bar * {
		margin-bottom: 0 !important;
	}
	#body_basket_bar > *:last-child {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Sepet içindeki tüm son elementler - çok agresif */
	#sepet .cf_box:last-child,
	#sepet #basket_bar:last-child,
	#sepet #body_basket_bar:last-child,
	#sepet .portBox:last-child,
	#sepet .portBoxBodyStandart:last-child,
	#sepet .boxRow:last-child,
	#sepet .uniqueBox:last-child {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
		height: auto !important;
		min-height: 0 !important;
	}
	/* Footer dosyasından gelen elementler */
	#sepet script:last-child,
	#sepet #body_basket_bar script:last-child,
	#body_basket_bar script:last-child {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Sepet içindeki tüm script ve include elementleri */
	#sepet script,
	#body_basket_bar script {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Footer dosyasındaki cf_box elementleri */
	#body_basket_bar .cf_box:last-child,
	#body_basket_bar .portBox:last-child,
	#body_basket_bar .portBoxBodyStandart:last-child {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	/* Ürün Sil Butonu Modernizasyonu */
	.modern-delete-product-btn {
		background: linear-gradient(135deg, #ff8c42 0%, #ff6b35 100%);
		border: none;
		border-radius: 8px;
		color: white;
		font-weight: 600;
		font-size: 13px;
		padding: 0;
		height: 30px;
		min-height: 30px;
		cursor: pointer;
		transition: all 0.3s ease;
		box-shadow: 0 4px 12px rgba(255, 140, 66, 0.3);
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 6px;
		min-width: 140px;
		text-align: center;
		line-height: 30px;
		margin: 0;
	}
	.modern-delete-product-btn:hover {
		background: linear-gradient(135deg, #ff6b35 0%, #ff8c42 100%);
		box-shadow: 0 6px 16px rgba(255, 140, 66, 0.4);
		transform: translateY(-2px);
	}
	.modern-delete-product-btn:active {
		transform: translateY(0);
		box-shadow: 0 2px 8px rgba(255, 140, 66, 0.3);
	}
	.modern-delete-product-btn i {
		font-size: 16px;
		display: inline-block;
		line-height: 30px;
		vertical-align: middle;
		margin: 0;
		padding: 0;
	}
	.modern-delete-product-btn * {
		vertical-align: middle;
		line-height: 1.2;
		margin: 0;
		padding: 0;
	}
	/* Sepet Tablosu Satır Yüksekliği Düzeltmesi */
	#sepet .cf_grid_list tbody tr,
	#sepet table tbody tr {
		height: auto !important;
		min-height: 30px;
		padding: 2px 4px;
		margin: 0 !important;
		border-spacing: 0 !important;
	}
	#sepet .cf_grid_list tbody tr + tr,
	#sepet table tbody tr + tr {
		margin-top: 0 !important;
		padding-top: 0 !important;
	}
	#sepet .cf_grid_list tbody tr td,
	#sepet table tbody tr td {
		padding: 4px 6px !important;
		vertical-align: middle;
		height: auto !important;
		min-height: 30px;
		margin: 0 !important;
		border-spacing: 0 !important;
	}
	#sepet .cf_grid_list thead tr th,
	#sepet table thead tr th {
		padding: 14px 6px !important;
		vertical-align: middle;
		min-height: 45px;
	}
	/* Sepet tablosu input ve select elementleri */
	#sepet .cf_grid_list tbody tr td input,
	#sepet .cf_grid_list tbody tr td select,
	#sepet table tbody tr td input,
	#sepet table tbody tr td select {
		height: auto !important;
		min-height: 32px;
		padding: 6px 8px;
		margin: 0 !important;
	}
	/* Sepet tablosu satır arası boşlukları azalt */
	#sepet .cf_grid_list tbody,
	#sepet table tbody {
		border-spacing: 0 !important;
		border-collapse: collapse !important;
	}
	#sepet .cf_grid_list,
	#sepet table {
		border-spacing: 0 !important;
		border-collapse: collapse !important;
		margin: 0 !important;
	}
	/* Checkbox boyutları - başlıktaki checkbox boyutuna göre */
	#sepet .cf_grid_list thead tr th input[type="checkbox"],
	#sepet table thead tr th input[type="checkbox"] {
		width: 16px !important;
		height: 16px !important;
		margin: 0 auto;
		padding: 0;
		cursor: pointer;
		display: block;
		text-align: center;
	}
	#sepet .cf_grid_list thead tr th,
	#sepet table thead tr th {
		text-align: center;
		vertical-align: middle;
	}
	/* Satırdaki checkbox'ı hücrede yatay ve dikey olarak ortala */
	#sepet .cf_grid_list tbody tr td:first-child,
	#sepet table tbody tr td:first-child {
		text-align: center !important;
		vertical-align: middle !important;
		padding: 10px 6px !important;
	}
	#sepet .cf_grid_list tbody tr td:first-child input[type="checkbox"],
	#sepet table tbody tr td:first-child input[type="checkbox"] {
		width: 16px !important;
		height: 16px !important;
		margin: 0 auto;
		padding: 0;
		cursor: pointer;
		display: block;
	}
	/* Footer satırları arasındaki boşlukları azalt */
	#body_basket_bar table tr {
		margin: 0 !important;
		padding: 0 !important;
		height: auto !important;
		min-height: 0 !important;
	}
	#body_basket_bar table tr + tr {
		margin-top: 0 !important;
		padding-top: 0 !important;
	}
	#body_basket_bar table tr td {
		padding: 3px 8px !important;
		margin: 0 !important;
		height: auto !important;
		min-height: 0 !important;
		vertical-align: middle;
	}
	#body_basket_bar table tr:first-child td {
		padding-top: 4px !important;
	}
	#body_basket_bar table tr:last-child td {
		padding-bottom: 4px !important;
	}
	/* Footer Bilgileri Aralık Düzeltmesi */
	#body_basket_bar .cf_box .cf_box_elements .col {
		padding: 8px !important;
		margin-bottom: 0 !important;
	}
	#body_basket_bar table {
		margin: 0 !important;
		border-spacing: 0 !important;
		border-collapse: collapse !important;
	}
	#body_basket_bar table tr {
		height: auto !important;
		min-height: 0 !important;
		padding: 0 !important;
		margin: 0 !important;
	}
	#body_basket_bar table tr td {
		padding: 4px 8px !important;
		height: auto !important;
		min-height: 0 !important;
		vertical-align: middle;
	}
	#body_basket_bar table tr:first-child td {
		padding-top: 8px !important;
	}
	#body_basket_bar table tr:last-child td {
		padding-bottom: 8px !important;
	}
	#body_basket_bar .form-group {
		margin-bottom: 0 !important;
		padding-bottom: 0 !important;
	}
	#body_basket_bar .cf_box_elements {
		padding: 8px !important;
		margin-bottom: 0 !important;
	}
	/* Sepet Input Alanları Arasındaki Boşlukları Düzenle */
	#sepet .cf_box .cf_box_elements .col.col-3,
	#sepet .cf_box .cf_box_elements .col[type="column"],
	#body_basket_bar .cf_box .cf_box_elements .col.col-3,
	#body_basket_bar .cf_box .cf_box_elements .col[type="column"] {
		margin-right: 15px !important;
		margin-left: 0 !important;
		margin-bottom: 8px !important;
		padding: 0 !important;
		display: inline-block !important;
		vertical-align: top !important;
	}
	#sepet .cf_box .cf_box_elements .col.col-3:last-child,
	#sepet .cf_box .cf_box_elements .col[type="column"]:last-child,
	#body_basket_bar .cf_box .cf_box_elements .col.col-3:last-child,
	#body_basket_bar .cf_box .cf_box_elements .col[type="column"]:last-child {
		margin-right: 0 !important;
	}
	#sepet .cf_box .cf_box_elements .form-group,
	#body_basket_bar .cf_box .cf_box_elements .form-group {
		margin-bottom: 0 !important;
		padding: 0 !important;
	}
	#sepet .cf_box .cf_box_elements .form-group input,
	#sepet .cf_box .cf_box_elements .form-group select,
	#sepet .cf_box .cf_box_elements .form-group textarea,
	#body_basket_bar .cf_box .cf_box_elements .form-group input,
	#body_basket_bar .cf_box .cf_box_elements .form-group select,
	#body_basket_bar .cf_box .cf_box_elements .form-group textarea {
		margin: 0 !important;
		padding: 6px 8px !important;
		width: 100% !important;
		box-sizing: border-box !important;
	}
	/* Responsive */
	@media screen and (max-width: 768px) {
		.tabNav li a {
			padding: 10px 12px;
			font-size: 13px;
		}
		#tab-head:first-of-type .tabNav li a {
			padding: 6px 12px;
			font-size: 12px;
		}
		#tab-content {
			padding: 15px;
		}
	}
</style>
<cf_catalystHeader>
<div id="basket_main_div">
	<cfform name="form_basket" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_ezgi_connect&id_list=#attributes.id_list#&categori_id_list=#attributes.categori_id_list#&model_id_list=#attributes.model_id_list#&modul_id_list=#attributes.modul_id_list#&color_id_list=#attributes.color_id_list#&connect_id=#attributes.connect_id#">
     	<cfinput type="hidden" name="connect_id" value="#attributes.connect_id#">
        <cfinput type="hidden" name="connect_money" id="connect_money" value="#get_connect_money_selected.MONEY_TYPE#">
        <cfinput type="hidden" name="connect_rate2" id="connect_rate2" value="#TlFormat(get_connect_money_selected.RATE2,4)#">
        <cfinput type="hidden" name="employee_max_disc_rate" value="#max_rate#" />
        <div class="row">
			<div class="col col-12 uniqueRow">
				<cf_basket_form id="upd_connect" class="row">
					<div id="tab-head" style="display: flex; width: 100%; align-items: center; margin-bottom: 10px;">
						<ul class="tabNav" style="margin: 0; display: flex; flex: 1;">
							<cfif get_related_connect.recordcount>
								<cfoutput query="get_related_connect">
									<li class="<cfif attributes.connect_id eq get_related_connect.connect_id>active</cfif>">
										<a id="plus_#get_related_connect.connect_id#" style="cursor:pointer" onclick="change_rel_connect(#get_related_connect.connect_id#);">
											#get_related_connect.CONNECT_NUMBER#
										</a>
									</li>
								</cfoutput>
								<li class="">
									<a id="plus_1" style="cursor:pointer" onclick="add_rel_connect(<cfoutput>#get_connect.CONNECT_REL_ID#</cfoutput>);">+</a>
								</li>
							<cfelse>
								<li class="active">
									<a id="plus_0" style="cursor:pointer" onclick="add_rel_connect(0);">+</a>
								</li>
							</cfif>
						</ul>
						<div class="basket-counter-modern" style="margin-left: auto; display: flex; align-items: center; justify-content: flex-end;">
							<cfset totalAmount = 0>
							<cfloop query="get_connect_row">
								<cfset totalAmount = totalAmount + AMOUNT>
							</cfloop>
							<div id="topTotalAmount" class="modern-basket-display">
								<div class="basket-icon-wrapper">
									<i class="fa fa-shopping-basket"></i>
									<cfif totalAmount gt 0>
										<span class="basket-badge"><cfoutput>#totalAmount#</cfoutput></span>
									</cfif>
								</div>
							</div>
						</div>
					</div>
					<div id="tab-head">
						<ul class="tabNav">
							<li class="<cfif attributes.anamenu eq 1>active</cfif>"><a id="href_urunler" href="#urunler"><cfoutput>#getLang('main',152,'ürünler')#</cfoutput></a></li>
							<li style="display:<cfif x_consumer_info neq 1>none</cfif>" class="<cfif attributes.anamenu eq 2>active</cfif>"><a id="href_minfo" href="#minfo"><cfoutput>#getLang('crm',678,'Müşteri Bilgisi')#</cfoutput></a></li>
							<li class="<cfif attributes.anamenu eq 3>active</cfif>"><a id="href_sepet" href="#sepet" onclick="basketAfterFunction()">Sepet</a></li>
						</ul>
					</div>
					<div id="tab-content" class="margin-top-10 tab-content-modern" style="padding-bottom: 0 !important;"> 
						<div id="urunler" class="content row">
							<cfinclude template="products_ezgi_connect.cfm">
						</div>
						<div id="minfo" class="content row" style="display:none;">
							<cfinclude template="header_ezgi_connect.cfm">
						</div>
						<div id="sepet" class="content row sepet-content-modern" style="display:none; margin: 0 !important; padding: 0 !important; margin-bottom: 0 !important; padding-bottom: 0 !important;">
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12" style="margin: 0 !important; padding: 0 !important; margin-bottom: 0 !important; padding-bottom: 0 !important;">
								<cfinclude template="basket_ezgi_connect.cfm">
							</div>
						</div>
						<div id="ext_sepet" class="content row">
							<div class="col col-12 col-md-12 col-sm-12 col-xs-12">

							</div>
						</div>
					</div>
				</div>
              	</cf_basket_form>
			</div>
		</div>
   	</cfform>
</div>
<script type="text/javascript">
	$(document).ready(function(){
    	$( "#keyword" ).focus();
	});
	
	$(function () {
                if(1==2){
                }
                else{
                    setTabBar();			
                }
    
                function setTabBar() {
                    $("#tabMenu").find("li.dropdown").each(function () {
                        if($(this).find("a").text().includes("<cfif x_create_copy_center eq 1>Dönüştür<cfelse>Oluştur</cfif>")){
                            $(this).remove();
                        }
                    });   
                }
                $( window ).resize(function(){
                    setTabBar();
                });
    
            });
	function kontrol()
	{
		<cfoutput>
			is_campaign_product = #attributes.is_campaign_product#;
		</cfoutput>
		if(is_campaign_product == 1) //Eğer Sepet İçinde Hediye Ürün eklenmişse
		{
			alert('Sepet İçinde Kampanya Hediye Ürünü Vardır. Güncelleme İşlemi Yapılamaz');
			return false;
		}
		if(form_basket.process_stage.value.length == 0)
		{
			alert("<cf_get_lang_main no='1430.Lütfen Süreç Seçiniz'>");
			return false;
		}
		if(form_basket.company_id.value.length == 0 && form_basket.consumer_id.value.length == 0 && form_basket.company.value.length == 0)
		{
			alert("<cf_get_lang no='254.Cari Hesap Secmelisiniz'>");
			document.getElementById('company').focus();
			return false;
		}
		if (form_basket.order_date.value.length == 0)
		{
			alert('<cf_get_lang dictionary_id="45761.Tarih Alanı Boş Olmamalıdır !">');
			document.getElementById('order_date').focus();
			return false;
		}
		if(process_cat_control())
			return true;
		else
			return false;
	}
	function sil_kontrol()
	{
		window.location ="<cfoutput>#request.self#?fuseaction=sales.emptypopup_del_ezgi_connect&connect_id=#attributes.connect_id#</cfoutput>";
		return true;
	}
	function add_rel_connect(connectrelid)
	{
		campaign_project_id ='';
		sor=confirm('Yeni Bir İlişkili Sepet Açılıyor.')
		if(sor==true)
		{
			<cfif ListLen(x_projects)>
				sor1=confirm('Kampanyalı Satış?')
				if(sor1==true)
					campaign_project_id =<cfoutput>#x_projects#</cfoutput>
			</cfif>
			window.location ="<cfoutput>#request.self#?fuseaction=sales.emptypopup_add_ezgi_connect&connect_id=#attributes.connect_id#</cfoutput>&connect_rel_id="+connectrelid+"&is_project="+campaign_project_id;
		}
	}
	function change_rel_connect(connectid)
	{
		if(connectid != <cfoutput>#attributes.connect_id#</cfoutput>)
		{
			window.location ="<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_ezgi_connect&event=upd&connect_id="+connectid;
		}
	}
	function change_header_info()
	{
		document.getElementById('connect_head').value=document.getElementById('connect_head_2').value;
		document.getElementById('detail').value=document.getElementById('detail_2').value;
	}
    function removeSepetBottomSpacing() {
        var sepetDiv = document.getElementById('sepet');
        var tabContent = document.getElementById('tab-content');
        if(sepetDiv && sepetDiv.style.display !== 'none' && tabContent) {
            tabContent.style.paddingBottom = '0';
            tabContent.style.padding = '20px 20px 0 20px';
            tabContent.style.marginBottom = '0';
            tabContent.style.minHeight = 'auto';
            tabContent.style.height = 'auto';
            tabContent.style.maxHeight = 'none';
            // Sepet içindeki tüm son elementlerin boşluğunu kaldır
            var sepetElements = sepetDiv.querySelectorAll('*');
            sepetElements.forEach(function(el) {
                el.style.marginBottom = '0';
                el.style.paddingBottom = '0';
            });
            // Sepet div'inin kendisini de kontrol et
            sepetDiv.style.marginBottom = '0';
            sepetDiv.style.paddingBottom = '0';
            sepetDiv.style.margin = '0';
            sepetDiv.style.padding = '0';
            sepetDiv.style.minHeight = 'auto';
            sepetDiv.style.height = 'auto';
            sepetDiv.style.maxHeight = 'none';
            // Son child element
            var lastChild = sepetDiv.lastElementChild;
            if(lastChild) {
                lastChild.style.marginBottom = '0';
                lastChild.style.paddingBottom = '0';
                // Son child'ın içindeki son elementleri de kontrol et
                var lastChildInner = lastChild.lastElementChild;
                if(lastChildInner) {
                    lastChildInner.style.marginBottom = '0';
                    lastChildInner.style.paddingBottom = '0';
                }
            }
            // body_basket_bar elementini kontrol et
            var bodyBasketBar = document.getElementById('body_basket_bar');
            if(bodyBasketBar) {
                bodyBasketBar.style.marginBottom = '0';
                bodyBasketBar.style.paddingBottom = '0';
                var bodyBasketBarLast = bodyBasketBar.lastElementChild;
                if(bodyBasketBarLast) {
                    bodyBasketBarLast.style.marginBottom = '0';
                    bodyBasketBarLast.style.paddingBottom = '0';
                }
            }
            // basket_bar ve parent elementlerini kontrol et
            var basketBar = document.getElementById('basket_bar');
            if(basketBar) {
                basketBar.style.marginBottom = '0';
                basketBar.style.paddingBottom = '0';
                var basketBarParent = basketBar.parentElement;
                if(basketBarParent) {
                    basketBarParent.style.marginBottom = '0';
                    basketBarParent.style.paddingBottom = '0';
                }
                // basket_bar içindeki tüm elementleri kontrol et
                var basketBarElements = basketBar.querySelectorAll('*');
                basketBarElements.forEach(function(el) {
                    if(el === basketBarElements[basketBarElements.length - 1]) {
                        el.style.marginBottom = '0';
                        el.style.paddingBottom = '0';
                    }
                });
            }
            // Footer dosyasındaki cf_box elementlerini kontrol et
            var footerBoxes = sepetDiv.querySelectorAll('#body_basket_bar .cf_box, #body_basket_bar .portBox, #body_basket_bar .portBoxBodyStandart');
            footerBoxes.forEach(function(el) {
                el.style.marginBottom = '0';
                el.style.paddingBottom = '0';
                var lastChild = el.lastElementChild;
                if(lastChild) {
                    lastChild.style.marginBottom = '0';
                    lastChild.style.paddingBottom = '0';
                }
            });
            // Sepet içindeki tüm col ve row elementlerini kontrol et
            var colElements = sepetDiv.querySelectorAll('.col, .row');
            colElements.forEach(function(el) {
                el.style.marginBottom = '0';
                el.style.paddingBottom = '0';
            });
            // Sepet içindeki tüm son elementleri recursive olarak kontrol et
            function removeBottomSpacingRecursive(element) {
                if(!element) return;
                element.style.marginBottom = '0';
                element.style.paddingBottom = '0';
                // Son child ise height özelliklerini de kontrol et
                if(element.parentElement && element === element.parentElement.lastElementChild) {
                    element.style.minHeight = 'auto';
                    element.style.height = 'auto';
                    element.style.maxHeight = 'none';
                }
                var children = element.children;
                for(var i = 0; i < children.length; i++) {
                    removeBottomSpacingRecursive(children[i]);
                }
            }
            removeBottomSpacingRecursive(sepetDiv);
            // Sepet içindeki son cf_box elementini özellikle kontrol et
            var lastBox = sepetDiv.querySelector('.cf_box:last-child, #basket_bar:last-child, .portBox:last-child');
            if(lastBox) {
                lastBox.style.marginBottom = '0';
                lastBox.style.paddingBottom = '0';
                lastBox.style.minHeight = 'auto';
                lastBox.style.height = 'auto';
                lastBox.style.maxHeight = 'none';
            }
            // Footer dosyasındaki son cf_box'u kontrol et
            var footerLastBox = document.querySelector('#body_basket_bar .cf_box:last-child');
            if(footerLastBox) {
                footerLastBox.style.marginBottom = '0';
                footerLastBox.style.paddingBottom = '0';
                footerLastBox.style.minHeight = 'auto';
                footerLastBox.style.height = 'auto';
                footerLastBox.style.maxHeight = 'none';
            }
        }
    }
    function basketAfterFunction() {
        AjaxPageLoad("<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_ezgi_connect&event=getBasket&connect_id=<cfoutput>#attributes.connect_id#</cfoutput>&<cfoutput>#url_str#</cfoutput>&id_list="+id_list, 'body_basket_bar');
        // AJAX tamamlandıktan sonra boşlukları kaldır
        setTimeout(function() {
            removeSepetBottomSpacing();
        }, 300);
        // Ekstra kontrol için bir kez daha
        setTimeout(function() {
            removeSepetBottomSpacing();
        }, 600);
    }
	// Tab navigation click event'lerini dinle
	$(document).ready(function() {
		$('#href_sepet').on('click', function() {
			setTimeout(function() {
				removeSepetBottomSpacing();
			}, 150);
			setTimeout(function() {
				removeSepetBottomSpacing();
			}, 400);
		});
		$('#href_urunler, #href_minfo').on('click', function() {
			var tabContent = document.getElementById('tab-content');
			if(tabContent) {
				tabContent.style.paddingBottom = '20px';
				tabContent.style.padding = '20px';
			}
		});
		// Sepet sekmesi görünür olduğunda kontrol et (MutationObserver)
		var observer = new MutationObserver(function(mutations) {
			var sepetDiv = document.getElementById('sepet');
			if(sepetDiv && sepetDiv.style.display !== 'none') {
				setTimeout(function() {
					removeSepetBottomSpacing();
				}, 100);
			}
		});
		var sepetDiv = document.getElementById('sepet');
		if(sepetDiv) {
			observer.observe(sepetDiv, { attributes: true, attributeFilter: ['style'] });
		}
	});
	basketAfterFunction();
</script>