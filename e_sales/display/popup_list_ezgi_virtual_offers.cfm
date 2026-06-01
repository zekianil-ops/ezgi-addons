<cfif isdefined("attributes.attributes_json")>
    <cfset deserialize_atributes = DeserializeJSON(URLDecode(attributes.ATTRIBUTES_JSON))>
    <cfset StructAppend(attributes,deserialize_atributes,true)>
</cfif>

	<cf_get_lang_set module_name="objects">
	<cfparam name="attributes.filtre_by_dept_id" default="">
	<cfif isdefined("attributes.is_form_submitted") or (isdefined("attributes.keyword") and len(attributes.keyword))>
		

		<cfquery name="get_virtual_offers" datasource="#dsn3#">
			SELECT 
				VIRTUAL_OFFER_ID,
				VIRTUAL_OFFER_NUMBER,
				VIRTUAL_OFFER_HEAD
			FROM
				EZGI_VIRTUAL_OFFER
			WHERE
				VIRTUAL_OFFER_STATUS = 1
				<cfif len(attributes.keyword)>
					AND 
					(
						VIRTUAL_OFFER_NUMBER LIKE '%#attributes.keyword#%' OR
						VIRTUAL_OFFER_DETAIL LIKE '%#attributes.keyword#%' OR
						VIRTUAL_OFFER_HEAD LIKE '%#attributes.keyword#%' 
					)
            	</cfif>
				<cfif session.ep.ISBRANCHAUTHORIZATION eq 1>
            		AND BRANCH_ID IN 
						(
						SELECT        
							BRANCH_ID
						FROM   
							#dsn_alias#.EMPLOYEE_POSITION_BRANCHES WITH (NOLOCK)
						WHERE        
							POSITION_CODE = #session.ep.POSITION_CODE# AND 
							DEPARTMENT_ID IS NULL
						
						)
            	</cfif>
		</cfquery>
		<!--- get_virtual_offer_query --->
	<cfelse>
		<cfset get_virtual_offers.recordcount = 0>
	</cfif>

	<!--- Branchler session'daki company_id'ye göre getirilebilir...our_cid paramateresi bu yüzden eklendi--->
	<cfparam name="attributes.keyword" default="">
	<cfparam name="attributes.branch_id" default="">
	<cfparam name="attributes.department_id" default="">
	<cfparam name="attributes.filter_by_hierarchy" default="">
	<cfparam name="attributes.satir" default=""><!--- Basket Çalışmaları için eklendi. Kaldırmayınız. EY20140826--->
	<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
	<cfparam name="attributes.page" default=1>
	<cfparam name="attributes.modal_id" default="">
	<cfparam name="attributes.from_add_rapid" default="0"><!--- Hızlı çalışan ekranından geliyorsa --->
	<cfparam name="attributes.position_cat_id_name" default="0"><!--- Pozisyon id ve name i beraber kullanılan durumlar için --->
	<cfparam name="attributes.totalrecords" default='#GET_VIRTUAL_OFFERS.recordcount#'>
	<cfif isdefined("attributes.field_id_3")><!--- aynı field id ye sahip başka bir alan var ise karışmaması için eklendi. --->
		<cfset attributes.field_id = attributes.field_id_3>
	</cfif>
	<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
	<script type="text/javascript">
	function add_pos(id,name)
	{	

		<cfif isdefined("attributes.field_name") and len(attributes.field_name) and attributes.from_add_rapid eq 0>
			if(<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.<cfoutput>#attributes.field_name#</cfoutput> != undefined)
				<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.<cfoutput>#attributes.field_name#</cfoutput>.value = name;
			else
				<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.getElementById('<cfoutput>#attributes.field_name#</cfoutput>').value = name;
		</cfif>
		<cfif isdefined("attributes.field_id")>
			if(<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.<cfoutput>#attributes.field_id#</cfoutput> != undefined)
				<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.<cfoutput>#attributes.field_id#</cfoutput>.value = id;
			else
				<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.getElementById('<cfoutput>#attributes.field_id#</cfoutput>').value = id;
		</cfif>
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );
	}
	function reloadopener()
	{
		wrk_opener_reload();
		<cfif not isdefined("attributes.draggable")>window.close();<cfelseif isdefined("attributes.draggable")>closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );</cfif>
	}
	</script>
	<cfparam name="select_list" default="1,2,3,4,5,6">
	<cfif not listcontainsnocase(select_list,9) and isdefined("attributes.field_emp_id")>
		<cfset select_list = listappend(select_list,'9')>
	</cfif>
	<cfscript>
		url_string = '';
		
		if (isdefined('attributes.field_name') and len(attributes.field_name)) url_string = '#url_string#&field_name=#attributes.field_name#';
		if (isdefined('attributes.field_id')) url_string = '#url_string#&field_id=#attributes.field_id#';
		if (isdefined("attributes.url_param"))
		{
			if (isdefined(attributes.url_param)) url_string = "#url_string#&#attributes.url_param#=#evaluate('attributes.'&attributes.url_param)#";
		}
		url_string2 = '&is_form_submitted=1';
		if (isdefined('attributes.branch_id')) url_string2 = '#url_string2#&branch_id=#attributes.branch_id#';
		if (isdefined('attributes.department_id')) url_string2 = '#url_string2#&department_id=#attributes.department_id#';
		if (isdefined('attributes.emp_process_row_id')) url_string2 = '#url_string2#&emp_process_row_id=#attributes.emp_process_row_id#';
		if (isdefined("attributes.tree_category_id") and len(attributes.tree_category_id) and isdefined("attributes.sub_tree_category_id"))  url_string2 = '#url_string2#&sub_tree_category_id=#attributes.sub_tree_category_id#';
		if (isdefined("attributes.is_my_extre_page")) url_string = "#url_string#&is_my_extre_page=#attributes.is_my_extre_page#";
		if (isdefined("attributes.satir") and len(attributes.satir))// Basket Çalışmaları için eklendi. Kaldırmayınız. EY20140826
			url_string= "#url_string#&satir=#attributes.satir#";
	</cfscript>
	
	
	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
		<cf_box title="Sanal Teklifler" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
			<!--- <cf_wrk_alphabet keyword="url_string,url_string2" popup_box="#iif(isdefined("attributes.draggable"),1,0)#"> --->
			<cfform name="search" method="post" action="#request.self#?fuseaction=prod.#fusebox.fuseaction##url_string#">
				<cfinput type="hidden" name="satir" value="#attributes.satir#"><!--- Basket Çalışmaları için eklendi. Kaldırmayınız. EY20140826--->
				<cf_box_search more="0">      
					<div class="form-group" id="item-keyword">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
						<cfinput type="text" name="keyword" id="keyword" placeholder="#message#" value="#attributes.keyword#" maxlength="50">
					</div>
					<div class="form-group" id="item-is_form_submitted">
						<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
						<input name="department_id" id="department_id" type="hidden" value="<cfoutput>#attributes.department_id#</cfoutput>">

					</div>
					<cfif isdefined("attributes.tree_category_id") and len(attributes.tree_category_id)>
						<div class="form-group" id="item-sub_tree_category_id">
							<select name="sub_tree_category_id" id="sub_tree_category_id">
								<option value="0" <cfif isdefined('attributes.sub_tree_category_id') and attributes.sub_tree_category_id eq 0>selected</cfif>><cf_get_lang dictionary_id='34274.Alt Tree Yetkilisine Bakmasın'></option>
								<option value="1" <cfif not isdefined('attributes.sub_tree_category_id') or attributes.sub_tree_category_id eq 1>selected</cfif>><cf_get_lang dictionary_id='34275.Alt Tree Yetkilisine Baksın'></option>
							</select>
						</div>
					</cfif>
					<div class="form-group small" id="item-maxrows">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
						<cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" onKeyUp="isNumber(this)" validate="integer" range="1,999" message="#message#" maxlength="3" style="width:30px;">
					</div>
					<div class="form-group">
						<cf_wrk_search_button button_type="4" search_function="#iif(isdefined("attributes.draggable"),DE("loadPopupBox('search' , #attributes.modal_id#)"),DE(""))#">
					</div>
				</cf_box_search>   
			</cfform>
				<cf_flat_list>	
					<thead>
						<tr>
							<cfset colspan = 3>
							<th width="20">Sıra</th>
							<th width="20">Teklif No</th>
							<th width="120">Başlık</th>
						</tr>
					</thead>
					<tbody>
						<cfif GET_VIRTUAL_OFFERS.recordcount>
							<cfoutput query="GET_VIRTUAL_OFFERS" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
								<tr>
									<td nowrap>#currentrow#</td>
									<td nowrap>
										<cfif not isdefined("url.trans")>
											<a href="javascript://" onClick="add_pos('#VIRTUAL_OFFER_ID#','#VIRTUAL_OFFER_NUMBER#');" class="tableyazi">#VIRTUAL_OFFER_NUMBER#</a>
										<cfelse>
											#VIRTUAL_OFFER_NUMBER#
										</cfif>
									</td>
									<td>#VIRTUAL_OFFER_HEAD#</td>
								</tr>
							</cfoutput>
						<cfelse>
							<tr> 
								<td height="20" colspan="8">
									<cfif isdefined("attributes.is_form_submitted") or (isdefined("attributes.keyword") and len(attributes.keyword))>
										<cf_get_lang dictionary_id='57484.Kayıt Yok'>!
									<cfelse>
										<cf_get_lang dictionary_id='57701.Filtre Ediniz '>!
									</cfif>
								</td>
							</tr>
						</cfif>
					</tbody>
				</cf_flat_list>	
		</cf_box>
	</div>
	<script type="text/javascript">
	$(document).ready(function(){
		$( "form[name=search] #keyword" ).focus();
	});
	<cfif isdefined('x_is_process_date_control') and x_is_process_date_control eq 1>
		function open_emp_info(row,employee_id)
		{	
			gizle_goster(eval("document.getElementById('row_emp_info_" + row + "')"));
			gizle_goster(eval("document.getElementById('div_emp_info_" + row + "')"));
			AjaxPageLoad('<cfoutput>#request.self#?fuseaction=objects.emptypopup_ajax_emp_events&emp_id='+employee_id+'&startdate=<cfif isdefined("attributes.process_date")>#attributes.process_date#</cfif><cfif isdefined("attributes.process_row_id") and len(attributes.process_row_id)>&process_row_id=#attributes.process_row_id#</cfif></cfoutput>','div_emp_info_'+row,1);
		}
	</cfif>
	</script>
	<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">