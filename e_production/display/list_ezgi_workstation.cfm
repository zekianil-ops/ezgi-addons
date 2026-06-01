<cf_xml_page_edit>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.is_active" default="1">
<cfparam name="attributes.branch_id" default="">
<cfparam name="is_active" default="1">
<cfparam name="attributes.page" default=1>
<cfinclude template="../query/get_ezgi_branch.cfm">
<cfif isdefined("attributes.is_submit")>
	<cfinclude template="../query/get_ezgi_workstation_all.cfm">
<cfelse>
	<cfset get_workstation_all.recordcount = 0>    
</cfif>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_workstation_all.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<cfset send_value = "prod.list_ezgi_workstation">

<cfset url_str = send_value>
<cfif isdefined("attributes.is_submit")><cfset url_str = "#url_str#&is_submit=#attributes.is_submit#"></cfif>
<cfif isdefined("attributes.field_id") and len(attributes.field_id)><cfset url_str = "#url_str#&field_id=#attributes.field_id#"></cfif>
<cfif isdefined("attributes.field_name") and len(attributes.field_name)><cfset url_str = "#url_str#&field_name=#attributes.field_name#"></cfif>
<cfif len(attributes.keyword)><cfset url_str = "#url_str#&keyword=#attributes.keyword#"></cfif>
<cfif len(attributes.is_active)><cfset url_str = "#url_str#&is_active=#attributes.is_active#"></cfif>
<cfif len(attributes.branch_id)><cfset url_str = "#url_str#&branch_id=#attributes.branch_id#"></cfif>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
		<cfform action="#request.self#?fuseaction=#send_value#" method="post" name="form">
			<input type="hidden" name="is_submit" id="is_submit" value="1">
			<cf_box_search>
				<div class="form-group">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
					<cfinput type="text" name="keyword" id="keyword" value="#attributes.keyword#" maxlength="50" placeholder="#message#">
				</div>
				<div class="form-group">
					<select name="branch_id" style="width:150px;">
						<option value=""><cf_get_lang dictionary_id='57453.Şube'></option>
						<cfoutput query="get_branch">
							<option value="#branch_id#"<cfif attributes.branch_id eq branch_id>selected</cfif>>#branch_name#</option>
						</cfoutput>
					</select>
				</div>
				<div class="form-group">
					<select name="is_active" id="is_active">
						<option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
						<option value="1" <cfif attributes.is_active eq 1>selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
						<option value="0" <cfif attributes.is_active eq 0>selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
					</select>
				</div>
				<div class="form-group small">
					<!---<cfsavecontent variable="message"><cf_get_lang dictionary_id='125.Sayi_Hatasi_Mesaj'></cfsavecontent>--->
					<cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,250" onKeyUp="isNumber(this)" maxlength="3">
				</div>
				<div class="form-group">
					<cf_wrk_search_button button_type="4">
				</div>
				<div class="form-group">
					<cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'>
					<a href="<cfoutput>#request.self#</cfoutput>?fuseaction=prod.workstation_graph"><img src="../../images/cizelge.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='36954.Üretim İstasyon Grafiği'>" /></a>
				</div>
			</cf_box_search>
		</cfform>
	</cf_box>
	<cfsavecontent variable="message"><cf_get_lang dictionary_id='36326.İş İstasyonları'></cfsavecontent>
	<cf_box title="#message#" uidrop="1" hide_table_column="1">
		<cf_flat_list> 
			<thead>
				<tr>
					<th width="20"><cf_get_lang dictionary_id='58577.Sıra'></th>
					<th><cf_get_lang dictionary_id='36669.İstasyon Adı'></th>
                    <th><cf_get_lang dictionary_id='36455.Katsayı'></th>
                    <th><cf_get_lang dictionary_id='36414.Adam Sayisi'></th>
                    <th><cf_get_lang dictionary_id='34289.Setup(Dk.)'></th>
					<cfif isdefined('is_show_comment') and is_show_comment eq 1>
						<th class="form-title"><cf_get_lang dictionary_id='57629.Açıklama'></th>
					</cfif>
                    
					<th><cf_get_lang dictionary_id='57453.Şube'></th>
					<th><cf_get_lang dictionary_id='57572.Departman'></th>
					<th><cf_get_lang dictionary_id='36409.Dış Kaynak'></th>
                    
					<th><cf_get_lang dictionary_id='57578.Yetkili'></th>
					<cfif is_prod_date eq 1>
						<this><cf_get_lang dictionary_id="29398.Son"> <cf_get_lang dictionary_id="36469.Üretim Tarihi"></th>
					</cfif>
					<cfif is_prod_amount eq 1>
						<th class="form-title"><cf_get_lang dictionary_id="36498.Üretim Miktarı"></th>
					</cfif>
					<!-- sil --><th width="20" class="header_icn_none"><a href="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_workstation&event=add</cfoutput>"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th><!-- sil -->
				</tr>
			</thead>
			<tbody>
				<cfif get_workstation_all.recordcount>
					<cfset emp_position_list = ''>
					<cfoutput query="get_workstation_all" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
						<cfif len(emp_id) and not listfind(emp_position_list,emp_id)>
							<cfset emp_position_list = ListAppend(emp_position_list,emp_id)>
						</cfif>
					</cfoutput>
					<cfif len(emp_position_list)>
						<cfset emp_position_list = listsort(emp_position_list,"numeric","ASC",",")>
						<cfquery name="GET_EMPLOYEES" datasource="#dsn#">
							SELECT  EMPLOYEE_ID, EMPLOYEE_NAME, EMPLOYEE_SURNAME FROM EMPLOYEE_POSITIONS WHERE EMPLOYEE_ID IN (#emp_position_list#) AND IS_MASTER = 1 ORDER BY EMPLOYEE_ID
						</cfquery>
						<cfset emp_position_list = listsort(listdeleteduplicates(valuelist(GET_EMPLOYEES.EMPLOYEE_ID,',')),'numeric','ASC',',')>               
					</cfif>
					<cfoutput query="get_workstation_all" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
						<tr>
							<td>#currentrow#</td>
							<td><cfif len(up_station)>&nbsp;&nbsp;</cfif>
								<cfif isdefined('attributes.field_id')>
									<a href="javascript://"  onClick="add_product('#station_id#','#station_name#','#capacity#','#employee_id#','#employee_name# #employee_surname#')" class="tableyazi">#station_name#</a>
								<cfelse>
									<a href="#request.self#?fuseaction=prod.list_ezgi_workstation&event=upd&station_id=#station_id#" class="tableyazi">#station_name#</a>
								</cfif>
							</td>
                            <td style="text-align:center">#EZGI_KATSAYI#</td>
                            <td style="text-align:center">#EMPLOYEE_NUMBER#</td>
                            <td style="text-align:center">#EZGI_SETUP_TIME#</td>
							<cfif isdefined('is_show_comment') and is_show_comment eq 1>
								<td>#COMMENT#</td>
							</cfif>
							<td>#branch_name#</td>
							<td>#DEPARTMENT_HEAD#</td>
							<td width="175"><cfif len(OUTSOURCE_PARTNER)>#get_par_info(OUTSOURCE_PARTNER,0,-1,1)#</cfif></td>
							<td><a href="javascript://"  onclick="windowopen('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#get_workstation_all.EMP_ID#','medium');" class="tableyazi">#GET_EMPLOYEES.EMPLOYEE_NAME[listfind(emp_position_list,get_workstation_all.EMP_ID,',')]#&nbsp;#GET_EMPLOYEES.EMPLOYEE_SURNAME[listfind(emp_position_list,get_workstation_all.EMP_ID,',')]#</a></td>
                            
							<cfif is_prod_date eq 1>
								<td><cfif len(max_order_date)>#dateformat(max_order_date,dateformat_style)#</cfif></td>
							</cfif>
							<cfif is_prod_amount eq 1>
								<cfquery name="get_prod_orders" datasource="#dsn3#">
									SELECT
										SUM(LAST_AMOUNT) LAST_AMOUNT,
										UNIT
									FROM
									(
										SELECT
											PO.QUANTITY-ISNULL((SELECT SUM(PORR.AMOUNT) FROM PRODUCTION_ORDER_RESULTS POR,PRODUCTION_ORDER_RESULTS_ROW PORR WHERE PORR.TYPE = 1 AND POR.PR_ORDER_ID = PORR.PR_ORDER_ID AND POR.P_ORDER_ID = PO.P_ORDER_ID AND POR.IS_STOCK_FIS = 1),0) LAST_AMOUNT,
											PU.ADD_UNIT UNIT
										FROM
											STOCKS S,
											PRODUCTION_ORDERS PO,
											PRODUCT_UNIT PU
										WHERE
											S.STOCK_ID = PO.STOCK_ID
											AND PO.IS_STAGE <> -1
											AND PO.STATION_ID = #station_id#
											AND S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
											AND (PO.QUANTITY -ISNULL((SELECT SUM(PORR.AMOUNT) FROM PRODUCTION_ORDER_RESULTS POR,PRODUCTION_ORDER_RESULTS_ROW PORR WHERE PORR.TYPE = 1 AND POR.PR_ORDER_ID = PORR.PR_ORDER_ID AND POR.P_ORDER_ID = PO.P_ORDER_ID AND POR.IS_STOCK_FIS = 1),0)) > 0
									)T1
									GROUP BY
										UNIT
								</cfquery>
								<td style="text-align:right">
									<cfloop query="get_prod_orders">
										<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_list_workstation_orders&station_id=#get_workstation_all.station_id#','list');">#tlformat(get_prod_orders.last_amount)#</a> #get_prod_orders.unit#<cfif currentrow neq recordcount><br/></cfif>
									</cfloop>
								</td>
							</cfif>
							<!-- sil --><td width="20"><a href="#request.self#?fuseaction=prod.list_ezgi_workstation&event=upd&station_id=#station_id#" class="tableyazi"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td><!-- sil -->
						</tr>
					</cfoutput>
				<cfelse>
					<tr>
						<cfset colspan = 10>
						<cfif is_prod_date eq 1><cfset colspan = colspan + 1></cfif>
						<cfif is_prod_amount eq 1><cfset colspan = colspan + 1></cfif>
						<td colspan="<cfoutput>#colspan#</cfoutput>"><cfif isdefined("attributes.is_submit")><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'></cfif></td>
					</tr>
				</cfif>
			</tbody>
		</cf_flat_list> 
		<cf_paging
			page="#attributes.page#" 
			maxrows="#attributes.maxrows#" 
			totalrecords="#get_workstation_all.recordcount#" 
			startrow="#attributes.startrow#" 
			adres="#url_str#">
	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function add_product(id,name,capacity,emp_id,emp_name)
	{
		window.close();
		<cfif isdefined("attributes.field_name")>
			opener.<cfoutput>#field_name#</cfoutput>.value = name;
		</cfif>
		<cfif isdefined("attributes.field_capacity")>
			opener.<cfoutput>#field_capacity#</cfoutput>.value = capacity;
		</cfif>
		<cfif isdefined("attributes.field_id")>
			opener.<cfoutput>#field_id#</cfoutput>.value = id;
		</cfif>
		<cfif isdefined("attributes.field_employee_id")>
			opener.<cfoutput>#field_employee_id#</cfoutput>.value = emp_id;
		</cfif>
		<cfif isdefined("attributes.emp_name")>
			opener.<cfoutput>#emp_name#</cfoutput>.value = emp_name;
		</cfif>
	}
</script>
