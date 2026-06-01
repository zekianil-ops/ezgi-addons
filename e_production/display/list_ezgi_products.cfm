<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.amount" default="1">
<cfparam name="attributes.employee" default="">
<cfparam name="attributes.pos_code" default="">
<cfparam name="attributes.get_company_id" default="">
<cfparam name="attributes.get_company" default="">
<cfparam name="attributes.product_catid" default="">
<cfparam name="attributes.product_cat" default="">
<cfparam name="attributes.brand_id" default="">
<cfparam name="attributes.brand_name" default="">
<cfif not isdefined("attributes.search_status")>
	<cfparam name="attributes.search_status" default=1>
</cfif>
<cfquery name="GET_PROPERTY_VAR" datasource="#DSN1#">
	SELECT
		PP.PROPERTY_ID,
		PP.PROPERTY,
		PPD.PROPERTY_DETAIL_ID,
		PPD.PROPERTY_DETAIL
	FROM
		PRODUCT_PROPERTY PP,
		PRODUCT_PROPERTY_DETAIL PPD
	WHERE
		PP.PROPERTY_ID = PPD.PRPT_ID
	ORDER BY
		PP.PROPERTY,
		PPD.PROPERTY_DETAIL
</cfquery>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<cfif not isdefined("attributes.is_change_sarf_cost")><cfset attributes.is_change_sarf_cost = 0></cfif>
<cfif isdefined("attributes.is_submitted")>
	<cfinclude template="../../../../V16/production_plan/query/get_product_names.cfm">
<cfelse>
	<cfset product_names.QUERY_COUNT = 0>
</cfif>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.totalrecords" default='#product_names.query_count#'>

<cfset string="">
<cfif isDefined("attributes.is_submitted") and len(attributes.is_submitted)>
	<cfset string = "#string#&is_submitted=1">
</cfif>
<cfif isdefined("attributes.call_function_first")>
  	<cfset string="#string#&call_function_first=#attributes.call_function_first#">
</cfif>
<cfif isdefined("attributes.call_function_first_prod")>
  	<cfset string="#string#&call_function_first_prod=#attributes.call_function_first_prod#">
</cfif>
<cfif isdefined("attributes.call_function_first_parameter")>
 	<cfset string="#string#&call_function_first_parameter=#attributes.call_function_first_parameter#">
</cfif>
<cfif isdefined("attributes.call_function")>
  	<cfset string="#string#&call_function=#attributes.call_function#">
</cfif>
<cfif isdefined("attributes.call_function_parameter")>
  	<cfset string="#string#&call_function_parameter=#attributes.call_function_parameter#">
</cfif>
<cfif isdefined("attributes.product_id")>
	<cfset string="#string#&product_id=#attributes.product_id#">
</cfif>
<cfif isdefined("attributes.type")>
  	<cfset string="#string#&type=#attributes.type#">
</cfif>
<cfif isdefined("attributes.spec_field_id")>
  	<cfset string="#string#&spec_field_id=#attributes.spec_field_id#">
</cfif>
<cfif isdefined("attributes.record_num")>
  	<cfset string="#string#&record_num=#attributes.record_num#">
</cfif>
<cfif isdefined("attributes.record_num_exit")>
  	<cfset string="#string#&record_num_exit=#attributes.record_num_exit#">
</cfif>
<cfif isdefined("attributes.record_num_outage")>
  	<cfset string="#string#&record_num_outage=#attributes.record_num_outage#">
</cfif>
<cfif isdefined("attributes.p_order_id")>
  	<cfset string="#string#&p_order_id=#attributes.p_order_id#">
</cfif>
<cfif isdefined("attributes.pr_order_id")>
  	<cfset string="#string#&pr_order_id=#attributes.pr_order_id#">
</cfif>
<cfif isdefined("attributes.field_id")>
	<cfset string="#string#&field_id=#attributes.field_id#">
</cfif>
<cfif isdefined("attributes.stock_id")>
	<cfset string="#string#&stock_id=#attributes.stock_id#">
</cfif>
<cfif isdefined("attributes.field_name")>
	<cfset string="#string#&field_name=#attributes.field_name#">
</cfif>
<cfif isdefined("attributes.is_production")>
	<cfset string="#string#&is_production=#attributes.is_production#">
</cfif>
<cfif isdefined("attributes.stock_code")>
	<cfset string="#string#&stock_code=#attributes.stock_code#">
</cfif>
<cfif isdefined("attributes.field_unit_name")>
	<cfset string="#string#&field_unit_name=#attributes.field_unit_name#">
</cfif>
<cfif isdefined("attributes.page_close")>
	<cfset string="#string#&page_close=#attributes.page_close#">
</cfif>
<cfif isdefined("attributes.field_amount")>
	<cfset string="#string#&field_amount=#attributes.field_amount#">
</cfif>
<cfif isdefined("attributes.is_change_sarf_cost")>
	<cfset string="#string#&is_change_sarf_cost=#attributes.is_change_sarf_cost#">
</cfif>
<table class="harfler">
	<tr>
		<td>
			<cfoutput>
				<td>&nbsp;</td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=A">A</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=B">B</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=C">C</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=Ç">Ç</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=D">D</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=E">E</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=F">F</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=G">G</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=H">H</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=I">I</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=İ">İ</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=J">J</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=K">K</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=L">L</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=M">M</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=N">N</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=O">O</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=Ö">Ö</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=P">P</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=Q">Q</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=R">R</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=S">S</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=Ş">Ş</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=T">T</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=U">U</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=Ü">Ü</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=V">V</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=W">W</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=X">X</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=Y">Y</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_add_product#string#&keyword=Z">Z</a></td>
				<td>&nbsp;</td>
			</cfoutput>
		</td> 
	</tr>
</table>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="message"><cf_get_lang dictionary_id='57564.Ürünler'></cfsavecontent>
	<cf_box  title="#message#">
		<cfform name="search_event" method="post" action="#request.self#?fuseaction=prod.popup_add_ezgi_product#string#">
			<input type="hidden" name="is_submitted" id="is_submitted" value="1" />
			<input type="hidden" name="list_property_id" id="list_property_id" value="<cfif isdefined("attributes.list_property_id")><cfoutput>#attributes.list_property_id#</cfoutput></cfif>">
			<input type="hidden" name="list_variation_id" id="list_variation_id" value="<cfif isdefined("attributes.list_variation_id")><cfoutput>#attributes.list_variation_id#</cfoutput></cfif>">
			<cf_box_search>
				<div class="form-group" id="item-keyword">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
					<cfinput type="text" name="keyword" value="#attributes.keyword#" maxlength="50" placeholder="#message#">
				</div>
				<div class="form-group" id="">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57635.Miktar'></cfsavecontent>
					<cfinput type="text" name="amount" style="width:60px;" value="#tlformat(attributes.amount)#" validate="float" class="moneybox" maxlength="255" placeholder="#message#">
				</div>
				<div class="form-group" id="item-search_status">
					<select name="search_status" id="search_status">			
						<option value="" <cfif isDefined('attributes.search_status') and not len(attributes.search_status)>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
						<option value="1" <cfif isDefined('attributes.search_status') and attributes.search_status is 1>selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
						<option value="0" <cfif isDefined('attributes.search_status') and attributes.search_status is 0>selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
					</select>		
				</div>
				<div class="form-group small">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
					<cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" onKeyUp="isNumber(this)" validate="integer" range="1,999" message="#message#" maxlength="3" style="width:25px;">
				</div>
				<div class="form-group">
					<cf_wrk_search_button search_function='search_kontrol()' button_type='4'>
				</div>
			</cf_box_search>
			<cf_box_search_detail>
				<div class="col col-4 col-md-4 col-sm-4 col-xs-12" index="1" type="column" sort="true">
					<div class="form-group" id="item-employee">
						<div class="input-group">							
							<input type="text" name="employee" id="employee" placeholder="<cf_get_lang dictionary_id='57544.Sorumlu'>" value="<cfoutput>#attributes.employee#</cfoutput>" maxlength="255" style="width:90px;">
							<input type="hidden" name="pos_code" id="pos_code" value="<cfoutput>#attributes.pos_code#</cfoutput>">
							<span class="input-group-addon btnPointer icon-ellipsis" href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_code=search_event.pos_code&field_name=search_event.employee&select_list=1&is_form_submitted=1&keyword='+encodeURIComponent(document.search_event.employee.value),'medium');"></span>
						</div>	
					</div>
					<div class="form-group" id="item-get_company_id">
						<div class="input-group">
							<input type="hidden" name="get_company_id" id="get_company_id" value="<cfoutput>#attributes.get_company_id#</cfoutput>">
							<input type="text" name="get_company" id="get_company" placeholder="<cf_get_lang dictionary_id='29533.Tedarikçi'>" value="<cfoutput>#attributes.get_company#</cfoutput>" style="width:90px;">
							<span class="input-group-addon btnPointer icon-ellipsis" href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_comp_name=search_event.get_company&field_comp_id=search_event.get_company_id&select_list=2,3&is_form_submitted=1&keyword='+encodeURIComponent(document.search_event.get_company.value),'medium');"></span>
						</div>
					</div>
				</div>
				<div class="col col-4 col-md-4 col-sm-4 col-xs-12" index="2" type="column" sort="true">
					<div class="form-group" id="item-product_cat">
						<div class="input-group">
							<input type="hidden" name="product_catid" id="product_catid" value="<cfoutput>#attributes.product_catid#</cfoutput>">
							<input type="text" name="product_cat" id="product_cat" placeholder="<cf_get_lang dictionary_id='57486.Kategori'>" value="<cfoutput>#attributes.product_cat#</cfoutput>" style="width:90px;" onFocus="AutoComplete_Create('product_cat','PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','','PRODUCT_CATID','product_catid','','3','200');">
							<span class="input-group-addon btnPointer icon-ellipsis" href="javascript://" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_cat_names&is_sub_category=1&field_id=search_event.product_catid&field_name=search_event.product_cat&keyword='+encodeURIComponent(document.search_event.product_cat.value)</cfoutput>);"></span>
						</div>
					</div>
					<div class="form-group" id="item-product_cat">
						<div class="input-group"> 
							<cfif len(attributes.brand_id) and len(attributes.brand_name)>
								<cfquery name="get_brand_name" datasource="#DSN3#">
									SELECT BRAND_NAME FROM PRODUCT_BRANDS WHERE BRAND_ID = #attributes.brand_id#
								</cfquery>
							</cfif>
							<input type="hidden" name="brand_id" id="brand_id" value="<cfoutput>#attributes.brand_id#</cfoutput>">
							<input type="text" name="brand_name" id="brand_name" placeholder="<cf_get_lang dictionary_id='58847.Marka'>" value="<cfoutput>#attributes.brand_name#</cfoutput>" style="width:90px;">
							<span class="input-group-addon btnPointer icon-ellipsis" href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_product_brands&brand_id=search_event.brand_id&brand_name=search_event.brand_name</cfoutput>','medium');"></span>
						</div>
					</div>
				</div>
				<div class="col col-4 col-md-4 col-sm-4 col-xs-12" index="3" type="column" sort="true">
					<cfinclude template="../../../../V16/production_plan/display/detailed_product_search.cfm" />
				</div>
    		</cf_box_search_detail>
		</cfform>
		<cf_grid_list>
			<thead>
				<tr>
					<th width="25"><cf_get_lang dictionary_id='57487.No'></th>
					<th width="80"><cf_get_lang dictionary_id ='57518.Stok Kodu'></th>
					<th><cf_get_lang dictionary_id ='57657.Ürün'></th>
					<th><cf_get_lang dictionary_id ='36889.Spec M'></th>
					<th><cf_get_lang dictionary_id='58120.Gerçek Stok'></th>
					<th width="20"><a href="javascript://"><i class="icon-detail"></i></a></th>
				</tr>
			</thead>
			<tbody>
				<cfif len(product_names.query_count) and product_names.query_count>
					<cfoutput query="product_names" >
						<cfset price_kdv = (price*tax)/100> <!---  <cfset price_kdv = (price*tax_purchase)/100> --->
						<cfset price_total = price + price_kdv>
						<tr>
							<td width="25">#rownum#</td>
							<td>#stock_code#</td>
							<td><a href="javascript:add_product('#stock_id#','#product_id#','#product_name#','#attributes.amount#','#price#','#price_kdv#','#price_total#','#tax#','#barcod#','#product_unit_id#','#main_unit#','#money#','#property#','#is_production#','#STOCK_CODE#','#SPECT_MAIN_ID#','#dimention#','#company_id#','#member_name#','#member_code#','#product_cost#','#product_cost2#')"> #product_name#&nbsp;#property#</a></td>
							<td>#SPECT_MAIN_ID#</td>
							<td class="moneybox">#tlformat(product_stock)# #main_unit#</td>
							<td><a href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_detail_product&pid=#product_names.PRODUCT_ID#&sid=#stock_id#','list')"><i class="icon-detail"></i></a></td>
						</tr>
					</cfoutput>
				<cfelse>
					<tr>
						<td colspan="6"><cfif isdefined("attributes.is_submitted")><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'><cfelse><cf_get_lang dictionary_id="57701.Filtre Ediniz!"></cfif> !</td>
					</tr>
				</cfif>
			</tbody>
		</cf_grid_list>
		<cfif len(attributes.keyword)>
		<cfset string="#string#&keyword=#attributes.keyword#">
		</cfif>
		<cfif len(attributes.employee)>
		<cfset string="#string#&employee=#attributes.employee#">
		</cfif>
		<cfif len(attributes.pos_code)>
		<cfset string="#string#&pos_code=#attributes.pos_code#">
		</cfif>
		<cfif len(attributes.get_company_id)>
		<cfset string="#string#&get_company_id=#attributes.get_company_id#">
		</cfif>
		<cfif len(attributes.get_company)>
		<cfset string="#string#&get_company=#attributes.get_company#">
		</cfif>
		<cfif len(attributes.product_catid)>
		<cfset string="#string#&product_catid=#attributes.product_catid#">
		</cfif>
		<cfif len(attributes.product_cat)>
		<cfset string="#string#&product_cat=#attributes.product_cat#">
		</cfif>
		<cfif len(attributes.brand_id)>
		<cfset string="#string#&brand_id=#attributes.brand_id#">
		</cfif>
		<cfif len(attributes.brand_name)>
		<cfset string="#string#&brand_name=#attributes.brand_name#">
		</cfif>
		<cfif isdefined("attributes.search_status")>
			<cfset string="#string#&search_status=#attributes.search_status#">
		</cfif>
		<cfif isDefined('attributes.list_property_id') and len(attributes.list_property_id)>
			<cfset string = '#string#&list_property_id=#attributes.list_property_id#'>
		</cfif>	
		<cfif isDefined('attributes.list_variation_id') and len(attributes.list_variation_id)>
			<cfset string = '#string#&list_variation_id=#attributes.list_variation_id#'>
		</cfif>	
		<cfif attributes.totalrecords gt attributes.maxrows>
			<cf_paging 
				page="#attributes.page#" 
				maxrows="#attributes.maxrows#" 
				totalrecords="#attributes.totalrecords#" 
				startrow="#attributes.startrow#" 
				adres="prod.popup_add_product#string#">
		</cfif>
	</cf_box>
</div>
<cfoutput>
<cfset new_string = ""><!--- record_num değerini oluşturduğumuz new_stringe almıyoruz. satır eklerken add_product_production sayfasında yeniden ekleyip gönderiyoruz. --->
<cfloop list="#string#" delimiters="&" index="xx">
	<cfif not (xx contains 'record_num')>
		<cfset new_string = ListAppend(new_string,xx,'&')>
	</cfif>
</cfloop>
</cfoutput>
<form name="form_add_production" method="post" action="">
	<input type="hidden" name="product_cost_date" id="product_cost_date" value=""><!--- Satıra Ürün Eklenirken Maliyeti Üretim Sonucunun Bitiş Tarihine Göre HEsaplaması için eklendi.M.ER --->
	<cfif isdefined("attributes.type")>
		<input type="hidden" name="type" id="type" value="<cfoutput>#attributes.type#</cfoutput>">
	</cfif>
	<cfif isdefined("attributes.record_num")>
		<input type="hidden" name="record_num" id="record_num" value="<cfoutput>#attributes.record_num#</cfoutput>">
	</cfif>
	<cfif isdefined("attributes.record_num_exit")>
		<input type="hidden" name="record_num_exit" id="record_num_exit" value="<cfoutput>#attributes.record_num_exit#</cfoutput>">
	</cfif>
	<cfif isdefined("attributes.record_num_outage")>
		<input type="hidden" name="record_num_outage" id="record_num_outage" value="<cfoutput>#attributes.record_num_outage#</cfoutput>">
	</cfif> 
	<cfif isdefined("attributes.p_order_id")>
		<input type="hidden" name="p_order_id" id="p_order_id" value="<cfoutput>#attributes.p_order_id#</cfoutput>">
	</cfif>
	<cfif isdefined("attributes.pr_order_id")>
		<input type="hidden" name="pr_order_id" id="pr_order_id" value="<cfoutput>#attributes.pr_order_id#</cfoutput>">
	</cfif>
    <input type="hidden" name="amount" id="amount" value="">
	<input type="hidden" name="STOCK_CODE" id="STOCK_CODE" value="">
	<input type="hidden" name="stock_id" id="stock_id" value="">
	<input type="hidden" name="product_id" id="product_id" value="">
	<input type="hidden" name="product_name" id="product_name" value="">
	<input type="hidden" name="dimention" id="dimention" value="">
	<input type="hidden" name="price" id="price" value="">
	<input type="hidden" name="price_kdv" id="price_kdv" value="">
	<input type="hidden" name="price_total" id="price_total" value="">
	<input type="hidden" name="tax" id="tax" value="">
	<input type="hidden" name="money" id="money" value="">
	<input type="hidden" name="barcode" id="barcode" value="">
	<input type="hidden" name="unit_id" id="unit_id" value="">
	<input type="hidden" name="unit" id="unit" value="">
	<input type="hidden" name="property" id="property" value="">
	<input type="hidden" name="is_production" id="is_production" value="">
	<input type="hidden" name="SPECT_MAIN_ID" id="SPECT_MAIN_ID" value="">
	<input type="hidden" name="expiration_date" id="expiration_date" value="">
	<input type="hidden" name="is_change_sarf_cost" id="is_change_sarf_cost" value="<cfoutput>#attributes.is_change_sarf_cost#</cfoutput>">
	<input type="hidden" name="pre_url_info" id="pre_url_info" value="<cfoutput>#new_string#</cfoutput>">
</form>
<script language="javascript1.3">
	document.getElementById('keyword').focus();
	function search_kontrol()
	{
		row_count=<cfoutput>#get_property_var.recordcount#</cfoutput>;
		for(r=1;r<=row_count;r++)
		{  
			deger_variation_id = eval("document.search_event.variation_id"+r);
			if(deger_variation_id!=undefined && deger_variation_id.value != "")
			{  
				deger_property_id = eval("document.search_event.property_id"+r);
				if(document.search_event.list_property_id.value.length==0) ayirac=''; else ayirac=',';
				document.search_event.list_property_id.value=document.search_event.list_property_id.value+ayirac+deger_property_id.value;
				document.search_event.list_variation_id.value=document.search_event.list_variation_id.value+ayirac+deger_variation_id.value;
			}
		}
		if(search_event.amount.value>0)
			search_event.amount.value=filterNum(search_event.amount.value);
		else
			search_event.amount.value=1;
		return true;
	}
	document.search_event.list_property_id.value="";
	document.search_event.list_variation_id.value="";
	function add_product(stock_id,product_id,product_name,amount,price,price_kdv,price_total,tax,barcode,unit_id,unit,money,property,is_production,STOCK_CODE,SPECT_MAIN_ID,dimention,company_id,member_name,member_code,product_cost,product_cost2)
	{
		amount = document.search_event.amount.value;
		<cfif isdefined("attributes.record_num") or isdefined("attributes.record_num_exit") or isdefined("attributes.record_num_outage")>//record_num değeri gelmiyorssa sayfa submit olmuyor direk verilen text alanlara atıyor değerleri
			if(window.opener.document.getElementById('finish_date'))
				form_add_production.product_cost_date.value = window.opener.document.getElementById('finish_date').value +'-'+ window.opener.document.getElementById('finish_h').value +'-'+ window.opener.document.getElementById('finish_m').value;
		
			form_add_production.SPECT_MAIN_ID.value = (SPECT_MAIN_ID!=undefined)?SPECT_MAIN_ID:'';
			form_add_production.amount.value = filterNum(amount);
			form_add_production.stock_id.value = stock_id;
			form_add_production.product_id.value = product_id;
			form_add_production.product_name.value = product_name;
			form_add_production.price.value = price;
			form_add_production.price_kdv.value = price_kdv;
			form_add_production.price_total.value = price_total;
			form_add_production.tax.value = tax;
			form_add_production.money.value = money;
			form_add_production.barcode.value = barcode;
			form_add_production.unit_id.value = unit_id;
			form_add_production.unit.value = unit;
			form_add_production.dimention.value = dimention;
			form_add_production.property.value = property;
			form_add_production.is_production.value = is_production;
			form_add_production.expiration_date.value = '';
			form_add_production.STOCK_CODE.value = STOCK_CODE;
			form_add_production.action = '<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_add_product_production';//empty
			form_add_production.submit();
		<cfelse>
			<cfif isdefined('attributes.call_function_first_prod')>
				window.opener.<cfoutput>#attributes.call_function_first_prod#(stock_id,product_name,document.search_event.amount.value,unit);</cfoutput>
			<cfelseif isdefined('attributes.call_function_first')>
				window.opener.<cfoutput>#attributes.call_function_first#(stock_id,product_name,document.search_event.amount.value,unit,product_id,unit_id,price,price_kdv,price_total,tax,STOCK_CODE,company_id,member_name,member_code,product_cost,product_cost2);</cfoutput>
			<cfelse>
				<cfif isdefined("attributes.field_id")>
					<cfset _field_id_ = ListGetAt(attributes.field_id,2,'.')><!--- Formu olmayan Sayfalara Değer Taşımak İçin Konuldu M.ER 01052008 --->
					if(window.opener.document.getElementById(<cfoutput>'#_field_id_#'</cfoutput>) != undefined)
						window.opener.document.getElementById(<cfoutput>'#_field_id_#'</cfoutput>).value = stock_id;
					else	
						opener.<cfoutput>#attributes.field_id#</cfoutput>.value = stock_id;
				</cfif>
				<cfif isdefined("attributes.spec_field_id")>
					<cfset _spec_field_id_ = ListGetAt(attributes.spec_field_id,2,'.')><!--- Formu olmayan Sayfalara Değer Taşımak İçin Konuldu M.ER 01052008 --->
					if(window.opener.document.getElementById(<cfoutput>'#_spec_field_id_#'</cfoutput>) != undefined)
						window.opener.document.getElementById(<cfoutput>'#_spec_field_id_#'</cfoutput>).value = SPECT_MAIN_ID;
					else	
						opener.<cfoutput>#attributes.spec_field_id#</cfoutput>.value = SPECT_MAIN_ID;
				</cfif>
				<cfif isdefined("attributes.field_unit_name")>
					<cfset _field_unit_name_ = ListGetAt(attributes.field_unit_name,2,'.')><!--- Formu olmayan Sayfalara Değer Taşımak İçin Konuldu M.ER 01052008 --->
					if(window.opener.document.getElementById(<cfoutput>'#_field_unit_name_#'</cfoutput>) != undefined)
						window.opener.document.getElementById(<cfoutput>'#_field_unit_name_#'</cfoutput>).value = unit;
					else	
						opener.<cfoutput>#attributes.spec_field_id#</cfoutput>.value = unit;
				</cfif>		
				<cfif isdefined("attributes.product_id")>
					opener.<cfoutput>#attributes.product_id#</cfoutput>.value = product_id;
				</cfif>
				<cfif isdefined("attributes.field_amount")>
					opener.<cfoutput>#attributes.field_amount#</cfoutput>.value = amount;
				</cfif>
				<cfif isdefined("attributes.stock_code")>
					opener.<cfoutput>#attributes.stock_code#</cfoutput>.value = STOCK_CODE;
				</cfif>
				<cfif isdefined("attributes.field_name")>
					<cfset _field_name_ = ListGetAt(attributes.field_name,2,'.')><!--- Formu olmayan Sayfalara Değer Taşımak İçin Konuldu M.ER 01052008--->
					if(window.opener.document.getElementById(<cfoutput>'#_field_name_#'</cfoutput>) != undefined)
						window.opener.document.getElementById(<cfoutput>'#_field_name_#'</cfoutput>).value = product_name;
					else	
						opener.<cfoutput>#attributes.field_name#</cfoutput>.value = product_name;
				</cfif>
				<cfif isdefined('attributes.call_function')>
					<cfif isdefined('attributes.call_function_parameter')>
						window.opener.<cfoutput>#attributes.call_function#('#attributes.call_function_parameter#');</cfoutput>
					<cfelse>
						window.opener.<cfoutput>#attributes.call_function#();</cfoutput>
					</cfif>
				</cfif>
			</cfif>
			<cfif not isdefined("attributes.page_close")>
				window.close();
			</cfif>
		</cfif>
		get_note = wrk_safe_query('prdp_get_note','dsn',0,stock_id);
		if(get_note.recordcount > 0)
			window.open('<cfoutput>#request.self#?fuseaction=objects.popup_detail_company_note&stock_id='+stock_id+'</cfoutput>','','scrollbars=0, resizable=0,width=500,height=500,left='+(screen.width-500)/2+',top='+(screen.height-500)/2+"'");
	}
</script>
