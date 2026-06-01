<cfparam name="attributes.keyword" default="">
<cfif isdefined("attributes.is_submit")>
<cfquery name="GET_PRICE_CAT" datasource="#DSN3#">
	SELECT * FROM EZGI_VIRTUAL_OFFER_PRICE_LIST <cfif len(attributes.keyword)>WHERE PRICE_CAT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> COLLATE SQL_Latin1_General_CP1_CI_AI</cfif> ORDER BY PRICE_CAT
</cfquery>
<cfelse>
	<cfset get_price_cat.recordcount = 0>
</cfif>
<cfquery name="CALCULATE_AC_PRD_ALL" datasource="#DSN3#">
    SELECT PRICE_CAT_ID, COUNT(*) AS SUM_PRD FROM EZGI_VIRTUAL_OFFER_PRICE_ROW GROUP BY PRICE_CAT_ID
</cfquery>
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default="#get_price_cat.recordcount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
		<cfform name="list_price_cat" action="#request.self#?fuseaction=prod.list_ezgi_virtual_offer_price_cat" method="post">
			<input type="hidden" name="is_submit" id="is_submit" value="1">
			<cf_box_search more="0">
				<div class="form-group">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
					<cfinput type="text" name="keyword" id="keyword" maxlength="50" value="#attributes.keyword#" placeholder="#message#">
				</div>
				<div class="form-group small">
					<cfinput type="text" name="maxrows" onKeyUp="isNumber (this)" value="#attributes.maxrows#" validate="integer" range="1,999" maxlength="3">
				</div>
				<div class="form-group">
					<div class="input-group">
						<cf_wrk_search_button button_type="4" search_function="kontrol()">
						<cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'>
					</div>
				</div>
			</cf_box_search>
		</cfform>
	</cf_box>
	<cfsavecontent variable="message">Fiyat Listeleri</cfsavecontent>
	<cf_box title="#message#" uidrop="1" hide_table_column="1">
		<cf_grid_list>
			<thead>
				<tr>
					<th width="20"><cf_get_lang dictionary_id='58577.Sira'></th>
					<th><cf_get_lang dictionary_id='37144.Liste Adı'></th>
					<th><cf_get_lang dictionary_id='37220.Fiyat Geçerlilik Alanları'></th>
					<th class="form-title" width="80" align="center"><cf_get_lang dictionary_id='37221.Aktif Ürün'></th>
					<!-- sil -->
                	<th width="20" class="header_icn_none"></th>
					<th width="20" class="header_icn_none"><a href="<cfoutput>#request.self#?fuseaction=prod.add_ezgi_virtual_offer_price_cat</cfoutput>"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
					<!-- sil -->
				</tr>
			</thead>
			<tbody>
				<cfif get_price_cat.recordcount>
                	<cfset consumer_cat_list = "">
					<cfset company_cat_list = "">
					<cfset branch_list = "">
                    <cfoutput query="get_price_cat" maxrows="#attributes.maxrows#" startrow="#attributes.startrow#">
						<cfif Len(company_cats) and not ListFind(company_cat_list,company_cats,',')>
							<cfset company_cat_list = ListAppend(company_cat_list,company_cats,',')>
						</cfif>
                        <cfif Len(consumer_cats) and not ListFind(consumer_cat_list,consumer_cats,',')>
							<cfset consumer_cat_list = ListAppend(consumer_cat_list,consumer_cats,',')>
						</cfif>
					</cfoutput>
					<cfif ListLen(company_cat_list)>
						<cfset company_cat_list=ListSort(company_cat_list,"numeric","ASC",",")>
						<cfquery name="get_company_cat" datasource="#dsn#">
							SELECT COMPANYCAT_ID, COMPANYCAT FROM COMPANY_CAT WHERE COMPANYCAT_ID IN (#company_cat_list#) ORDER BY COMPANYCAT_ID
						</cfquery>
						<cfset company_cat_list = ListSort(ListDeleteDuplicates(ValueList(get_company_cat.companycat_id)),'numeric','ASC',',')>
					</cfif>
                    <cfoutput query="get_price_cat" maxrows="#attributes.maxrows#" startrow="#attributes.startrow#">
						<cfif Len(company_cats) and not ListFind(company_cat_list,company_cats,',')>
							<cfset company_cat_list = ListAppend(company_cat_list,company_cats,',')>
						</cfif>
					</cfoutput>
					<cfif ListLen(consumer_cat_list)>
						<cfset consumer_cat_list=ListSort(consumer_cat_list,"numeric","ASC",",")>
						<cfquery name="get_consumer_cat" datasource="#dsn#">
							SELECT CONSCAT_ID as CONSUMERCAT_ID,CONSCAT as CONSUMERCAT FROM CONSUMER_CAT ORDER BY CONSUMERCAT
						</cfquery>
						<cfset consumer_cat_list = ListSort(ListDeleteDuplicates(ValueList(get_consumer_cat.consumercat_id)),'numeric','ASC',',')>
					</cfif>
					<cfoutput query="get_price_cat" maxrows="#attributes.maxrows#" startrow="#attributes.startrow#">
						<cfset attributes.pcat_id = price_cat_id>
						<input type="hidden" name="price_catid" id="price_catid" value="#price_cat_id#">
						
						<tr>
							<td width="35">#currentrow#</td>
							<td><a href="#request.self#?fuseaction=prod.upd_ezgi_virtual_offer_price_cat&price_cat_id=#price_cat_id#" class="tableyazi">#price_cat#</a></td>
							<td>
                            	<cfif ListLen(company_cats)>
                                	<b><cf_get_lang dictionary_id='29408.Kurumsal Üyeler'></b>
									<cfloop list="#ListDeleteDuplicates(company_cats)#" index="com">
										<span style="color:blue">#get_company_cat.companycat[ListFind(company_cat_list,com,',')]#,</span>
									</cfloop>
								</cfif>
                                <cfif ListLen(consumer_cats)>
                                	<br/>
                                	<b><cf_get_lang dictionary_id='29406.Bireysel Üyeler'></b>
									<cfloop list="#ListDeleteDuplicates(consumer_cats)#" index="com">
										<span style="color:orange">#get_consumer_cat.CONSUMERCAT[ListFind(consumer_cat_list,com,',')]#,</span>
									</cfloop>
								</cfif>
                            </td>
                            <cfquery name="calculate_ac_prd" dbtype="query">
								SELECT SUM_PRD FROM CALCULATE_AC_PRD_ALL WHERE PRICE_CAT_ID = #attributes.pcat_id#
							</cfquery>
							<td style="text-align:right;">#calculate_ac_prd.sum_prd#</td>
							<!-- sil -->
                            <td width="1%"><a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=prod.upd_ezgi_virtual_offer_price_cat_setup&price_cat_id=#price_cat_id#')" class="tableyazi"><i class="fa fa-bank" title="<cf_get_lang dictionary_id='37018.Fiyat Yetki Tanımları'>" alt="<cf_get_lang dictionary_id='37018.Fiyat Yetki Tanımları'>"></i></a></td>
							<td width="1%"><a href="#request.self#?fuseaction=prod.upd_ezgi_virtual_offer_price_cat&price_cat_id=#price_cat_id#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td>
							<!-- sil -->
						</tr>
					</cfoutput>
				<cfelse>
					<tr>
						<td colspan="6"><cfif isdefined("attributes.is_submit")><cf_get_lang dictionary_id='57484.Kayıt Yok'>!<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !</cfif></td>
					</tr>
				</cfif>
			</tbody>
		</cf_grid_list>
<cfset url_str = "">
<cfif isdefined ("attributes.keyword") and len(attributes.keyword)>
	<cfset url_str ="#url_str#&keyword=#attributes.keyword#">
</cfif>
<cfif isdefined("attributes.is_submit") and len(attributes.is_submit)>
	<cfset url_str = "#url_str#&is_submit=#attributes.is_submit#">
</cfif>
<cf_paging page="#attributes.page#" 
	maxrows="#attributes.maxrows#"
	totalrecords="#attributes.totalrecords#"
	startrow="#attributes.startrow#"
	adres="product.list_price_cat#url_str#">
</cf_box>

</div>
<script type="text/javascript">
	function kontrol(){
		if(!$("#maxrows").val().length){
			alertObject({message: "<cfoutput><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfoutput>"})	
			return false;
		}else
			return true;	
	}
	$('#keyword').focus();
	//document.getElementById('keyword').focus();
</script>
