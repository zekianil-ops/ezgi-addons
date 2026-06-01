<cf_get_lang_set module_name="stock">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.shelve_pro_cat" default="">
<cfparam name="attributes.place_status" default="">
<cfparam name="attributes.stock_id" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.shelves_cat" default="">
<cfif session.ep.isBranchAuthorization>
	<cfset attributes.branch_id = listgetat(session.ep.user_location,2,'-')>
</cfif>
<cfquery name="GET_PRODUCT_CAT" datasource="#DSN3#">
	SELECT 
		PRODUCT_CATID, 
		HIERARCHY, 
		PRODUCT_CAT 
	FROM 
		PRODUCT_CAT
	WHERE 
		PRODUCT_CATID IS NOT NULL
		<cfif isDefined("attributes.id")>
			AND	PRODUCT_CATID = #attributes.id#
		</cfif>
		<cfif session.ep.isBranchAuthorization>
			AND	PRODUCT_CATID IN(SELECT PRODUCT_CATID FROM #dsn1_alias#.PRODUCT_CAT_OUR_COMPANY WHERE OUR_COMPANY_ID = #session.ep.company_id#)
		</cfif>
	ORDER BY
		HIERARCHY
</cfquery>
<cfquery name="get_shelf_cat" datasource="#dsn3#">
	SELECT  EZGI_PLACE_CAT_ID, EZGI_PLACE_CAT FROM EZGI_WM_SETUP_PLACE_CAT
</cfquery>
<cfoutput query="get_shelf_cat">
	<cfset 'EZGI_PLACE_CAT_#EZGI_PLACE_CAT_ID#' = EZGI_PLACE_CAT>
</cfoutput>
<cfif isdefined("attributes.form_submitted")>
	<cfinclude template="../query/get_ezgi_product_place.cfm">
    <cfinclude template="../query/get_ezgi_shelves_type.cfm">
    <cfoutput query="get_shelves_type">
    	<cfset 'SHELF_SIZE_TYPE_CODE_#SHELF_SIZE_TYPE_ID#' = SHELF_SIZE_TYPE_CODE>
    </cfoutput>
<cfelse>
	<cfset get_product_place.recordcount=0>
</cfif>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_product_place.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
		<cfform name="search_product_place" action="#request.self#?fuseaction=stock.list_ezgi_shelves" method="post">
			<cf_box_search>
				<div class="form-group">
					<input type="hidden" name="form_submitted" id="form_submitted" value="1">
					<input name="keyword" id="keyword" type="text" placeholder="<cfoutput>#getLang(48,'Filtre',57460)#</cfoutput>" maxlength="50" value="<cfoutput>#attributes.keyword#</cfoutput>">
				</div>
				<div class="form-group">
					<select name="place_status" id="place_status">
						<option value="1"<cfif isDefined("attributes.place_status") and (attributes.place_status eq 1)> selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
						<option value="0"<cfif isDefined("attributes.place_status") and (attributes.place_status eq 0)> selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
						<option value=""<cfif isDefined("attributes.place_status") and not len(attributes.place_status)> selected</cfif>><cf_get_lang dictionary_id='30111.Durumu'></option>
					</select>
				</div>
				<div class="form-group">
					<label><cf_get_lang dictionary_id="570.Boş"> <cf_get_lang dictionary_id="29944.Raflar"><input type="checkbox" name="empty_shelf" id="empty_shelf" value="1" <cfif isdefined("attributes.empty_shelf")>checked="checked"</cfif> /></label>
				</div>
				<div class="form-group small">
					<cfinput type="text" name="maxrows" value="#attributes.maxrows#" onKeyUp="isNumber(this)" maxlength="3" validate="integer" range="1,250" required="yes" message="#getLang('','Kayıt Sayısı Hatalı',57537)#">
				</div>
				<div class="form-group">
					<cf_wrk_search_button button_type="4">
					<cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'>
				</div>
			</cf_box_search>
			<cf_box_search_detail>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
					<div class="form-group" id="item-store">
						<label class="col col-12"><cf_get_lang dictionary_id='58763.Depo Seçiniz'></label>
						<div class="col col-12">
							<cfinclude template="../../../../v16/product/query/get_stores.cfm">
							<select name="store" id="store">
								<option  value=""><cf_get_lang dictionary_id='45372.Depo Seçiniz'></option>
								<cfoutput query="get_stores">
									<option value="#department_id#" <cfif isDefined("attributes.store") and attributes.store eq department_id>selected</cfif> >#department_head#</option>
								</cfoutput>
							</select>
						</div>
					</div>
					<div class="form-group" id="item-stock">
						<label class="col col-12"><cfoutput>#getLang(245,'Ürün',57657)#</cfoutput></label>
						<div class="col col-12">
							<div class="input-group">
								<input type="hidden" name="stock_id" id="stock_id" <cfif len(attributes.stock_id) and len(attributes.product_name)> value="<cfoutput>#attributes.stock_id#</cfoutput>"</cfif>>
								<input name="product_name" type="text" id="product_name" placeholder="<cfoutput>#getLang(245,'Ürün',57657)#</cfoutput>"  onFocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME','get_product','0','STOCK_ID','stock_id','','3','130');" value="<cfif len(attributes.stock_id) and len(attributes.product_name)><cfoutput>#attributes.product_name#</cfoutput></cfif>" autocomplete="off">
								<span class="input-group-addon icon-ellipsis btnPointer" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=search_product_place.stock_id&field_name=search_product_place.product_name<cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&keyword='+encodeURIComponent(document.search_product_place.product_name.value));"></span>
							</div>
						</div>
					</div>
				</div>
				<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
					<div class="form-group" id="item-shelf_type">
						<label class="col col-12"><cf_get_lang dictionary_id='57630.Tip'></label>
						<div class="col col-12">
							<cfinclude template="../../../../v16/product/query/get_shelves.cfm">
							<select name="shelf_type" id="shelf_type">
								<option value=""><cf_get_lang dictionary_id='57630.Tip'></option>
								<cfoutput query="get_shelves">
									<option value="#shelf_id#" <cfif isDefined("attributes.shelf_type") and (attributes.shelf_type eq SHELF_ID )>selected</cfif> >#SHELF_NAME#</option>
								</cfoutput>
							</select>
						</div>
					</div>
					<div class="form-group" id="item-shelve_pro_cat">
						<label class="col col-12"><cf_get_lang dictionary_id='57486.Kategoriler'></label>
						<div class="col col-12">
							<select name="shelve_pro_cat" id="shelve_pro_cat">
								<option value=""><cf_get_lang dictionary_id='57486.Kategoriler'></option>
								<cfoutput query="get_product_cat">
									<option value="#product_catid#" <cfif attributes.shelve_pro_cat eq product_catid>selected</cfif>>#hierarchy#-#product_cat#</option>
								</cfoutput>
							</select>
						</div>
					</div>
				</div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
					<div class="form-group" id="item-shelves_cat">
						<label class="col col-12">Raf Kategorisi</label>
						<div class="col col-12">
							<select name="shelves_cat" id="shelves_cat">
								<option value="">Tümü</option>
								<cfoutput query="get_shelf_cat">
									<option value="#EZGI_PLACE_CAT_ID#" <cfif attributes.shelves_cat eq EZGI_PLACE_CAT_ID>selected</cfif>>#EZGI_PLACE_CAT#</option>
								</cfoutput>
							</select>
						</div>
					</div>
				</div>
			</cf_box_search_detail>
		</cfform>
	</cf_box>
	<cf_box title="#getLang(2147,'Raflar',29944)#" uidrop="1" hide_table_column="1">
		<cf_grid_list>
			<thead>
				<tr>
					<!-- sil --><th width="20"></th><!-- sil -->
					<th width="35"><cf_get_lang dictionary_id='58577.Sıra'></th>
					<th><cf_get_lang dictionary_id='45539.Raf Kodu'></th>
					<th><cf_get_lang dictionary_id='57630.tip'></th>
                    <th>Raf Kategorisi</th>
                    <th>Adres Tipi</th>
                    <th>Öncelik Sıralaması</th>
                    <th>Toplama Sıralaması</th>
                    <th>Mevcut Stok</th>
                    <th>Min Stok</th>
                    <th>Max Stok</th>
					<th><cf_get_lang dictionary_id='30031.lokasyon'></th>
					<th><cf_get_lang dictionary_id='57501.başlama'></th>
					<th><cf_get_lang dictionary_id='57502.bitiş'></th>
					<th><cf_get_lang dictionary_id='57756.Durum'></th>
					<th width="20" class="header_icn_none text-center">
						<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=stock.list_ezgi_shelves&event=add</cfoutput>','wide');"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a> 
					</th>
				</tr>
			</thead>
			<tbody>
				<cfset prod_place_stock_id_list=''>
				<cfif get_product_place.recordcount>
					<cfoutput query="get_product_place" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
						<cfif len(product_id) and len(place_stock_id) and not listfind(prod_place_stock_id_list,place_stock_id)>
							<cfset prod_place_stock_id_list=listappend(prod_place_stock_id_list,place_stock_id)>
						</cfif>
					</cfoutput>
					<cfif len(prod_place_stock_id_list)>
						<cfquery name="get_stock_names" datasource="#dsn3#">
							SELECT BARCOD,PRODUCT_NAME,PROPERTY,STOCK_ID,PRODUCT_ID FROM STOCKS WHERE STOCK_ID IN (#prod_place_stock_id_list#) ORDER BY STOCK_ID
						</cfquery>
						<cfset prod_place_stock_id_list=valuelist(get_stock_names.STOCK_ID)>
					</cfif>
					<cfoutput query="get_product_place" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
					<tr>
						<!-- sil -->
						<td id="order_row#currentrow#" onClick="gizle_goster(detail#currentrow#);connectAjax('#currentrow#','#PRODUCT_PLACE_ID#');gizle_goster(siparis_goster#currentrow#);gizle_goster(siparis_gizle#currentrow#);">
							<a id="siparis_goster#currentrow#" href="javascript:void(0)"><i class="fa fa-caret-right" title="<cf_get_lang dictionary_id ='58596.Göster'>"></i></a>
							<a id="siparis_gizle#currentrow#" href="javascript:void(0)" style="display:none"><i class="fa fa-caret-left" title="<cf_get_lang dictionary_id ='58628.Gizle'>"></i></a>
						</td>	
						<!-- sil -->			
						<td>#get_product_place.currentrow#</td>
						<td>#shelf_code#</td>
						<td>#shelf_name#</td>
                        <td><cfif isdefined('EZGI_PLACE_CAT_#PLACE_CAT_ID#')>#Evaluate('EZGI_PLACE_CAT_#PLACE_CAT_ID#')#</cfif></td>
                        <td style="text-align:center"><cfif isdefined('SHELF_SIZE_TYPE_CODE_#SHELF_SIZE_TYPE#')>#Evaluate('SHELF_SIZE_TYPE_CODE_#SHELF_SIZE_TYPE#')#</cfif></td>
                        <td style="text-align:center">
                       		<cfif SHELF_SORT eq 1>A
                            <cfelseif SHELF_SORT eq 2>B
                            <cfelseif SHELF_SORT eq 3>C
                            <cfelseif SHELF_SORT eq 4>D
                            <cfelseif SHELF_SORT eq 5>E
                            </cfif>
                        </td>
                        <td style="text-align:center">#collect_sort#</td>
                        <td style="text-align:center">#sayi#</td>
                        <td style="text-align:center">#min_stock#</td>
                        <td style="text-align:center">#max_stock#</td>
						<td>#get_location_info(get_product_place.store_id,get_product_place.location_id,1)#</td>
						<td>#dateformat(start_date,dateformat_style)#</td>
						<td>#dateformat(finish_date,dateformat_style)#</td>
						<td><cfif place_status eq 1><cf_get_lang dictionary_id='57493.Aktif'><cfelse><cf_get_lang dictionary_id='57494.Pasif'></cfif></td>
						<!-- sil -->
						<td>
							<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=stock.list_ezgi_shelves&event=upd&product_place_id=#product_place_id#','wide');"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
						</td>
						<!-- sil -->
					</tr>
					<tr id="detail#currentrow#" class="nohover" style="display:none">
						<td colspan="15"><div align="left" id="DISPLAY#currentrow#"></div></td>
					</tr>
					</cfoutput>
				<cfelse>
					<tr>
						<td colspan="16"><cfif isdefined("attributes.form_submitted")><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !</cfif></td>
					</tr>
				</cfif>
			</tbody>
		</cf_grid_list>
		<cfset adres = "#fusebox.circuit#.list_shelves">
		<cfif isDefined('attributes.cat') and len(attributes.cat)>
			<cfset adres = '#adres#&cat=#attributes.cat#'>
		</cfif>
		<cfif isdefined("attributes.stock_id") and len(attributes.stock_id) and isdefined("attributes.product_name") and len(attributes.product_name)>
			<cfset adres = "#adres#&stock_id=#attributes.stock_id#&product_name=#attributes.product_name#">
		</cfif>
		<cfif isdefined("attributes.place_status") and len(attributes.place_status)>
			<cfset adres = '#adres#&place_status=#attributes.place_status#'>
		</cfif>
		<cfif isdefined("attributes.store") and len(attributes.store)>
			<cfset adres = '#adres#&store=#attributes.store#'>
		</cfif>
		<cfif len(attributes.keyword)>
			<cfset adres = '#adres#&keyword=#attributes.keyword#'>
		</cfif> 
		<cfif isdefined("attributes.shelve_pro_cat") and len(attributes.shelve_pro_cat)>
			<cfset adres = '#adres#&shelve_pro_cat=#attributes.shelve_pro_cat#'>
		</cfif> 
        <cfif isdefined("attributes.shelves_cat") and len(attributes.shelves_cat)>
			<cfset adres = '#adres#&shelves_cat=#attributes.shelves_cat#'>
		</cfif> 
		<cfif isdefined("attributes.shelf_type") and len(attributes.shelf_type)>
			<cfset adres = '#adres#&shelf_type=#attributes.shelf_type#'>
		</cfif>
		<cfif isdefined("attributes.form_submitted") and len(attributes.form_submitted)>
			<cfset adres = '#adres#&form_submitted=#attributes.form_submitted#'>
		</cfif>
		<cf_paging 
			page="#attributes.page#" 
			maxrows="#attributes.maxrows#"
			totalrecords="#attributes.totalrecords#"
			startrow="#attributes.startrow#"
			adres="#adres#">
	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function connectAjax(crtrow,shelf_id)
	{		
		var load_url_ = '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_list_shelf_products</cfoutput>&frm_shlf_list=1&shelf_id='+shelf_id+'&crtrow='+crtrow;
		AjaxPageLoad(load_url_,'DISPLAY'+crtrow,1);
	}
</script>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
