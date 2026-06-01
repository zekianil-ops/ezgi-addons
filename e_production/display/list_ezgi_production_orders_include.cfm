<!---
    File: list_ezgi_production_orders_include.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---Ezgi Bilgisayar Özelleştirme ZAG - 01/12/2017--->
<cfquery name="GET_W" datasource="#dsn#">
	SELECT 
    	STATION_ID,
        STATION_NAME,
        ISNULL(EXIT_DEP_ID,0) AS EXIT_DEP_ID,
        ISNULL(EXIT_LOC_ID,0) AS EXIT_LOC_ID,
        ISNULL(PRODUCTION_DEP_ID,0) AS PRODUCTION_DEP_ID,
        ISNULL(PRODUCTION_LOC_ID,0) AS PRODUCTION_LOC_ID
	FROM 
    	#dsn3_alias#.WORKSTATIONS WITH (NOLOCK)
	WHERE 
    	DEPARTMENT IN (SELECT DEPARTMENT.DEPARTMENT_ID FROM DEPARTMENT,EMPLOYEE_POSITION_BRANCHES WHERE DEPARTMENT.BRANCH_ID = EMPLOYEE_POSITION_BRANCHES.BRANCH_ID AND EMPLOYEE_POSITION_BRANCHES.POSITION_CODE = #session.ep.position_code# ) 
	ORDER BY 
    	STATION_NAME ASC
</cfquery>
<cfif not isdefined("attributes.is_demand")><cfset attributes.is_demand = 0></cfif>
<cfif not isdefined('attributes.is_group_page')>
	<thead>
   		 <tr>
			<th width="15"><cf_get_lang dictionary_id='55657.Sıra No'></th>
            <th width="15">&nbsp;</th>
			<th width="50"><cf_get_lang dictionary_id='57611.Sipariş'></th>
            <th><cf_get_lang dictionary_id='57742.Tarih'></th>
			<th><cf_get_lang dictionary_id='494.Teslim'></th>
			<cfif is_show_stock_code eq 1>
				<th><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
			</cfif>
			<th><cf_get_lang dictionary_id='57657.Ürün'></th>
			<cfif isdefined("is_order_detail") and is_order_detail eq 1><th><cf_get_lang dictionary_id='36708.Sipariş Açıklaması'></th></cfif>
			<cfif isdefined('is_show_spec') and is_show_spec eq 1 or not isdefined('is_show_spec')>
				<th><cf_get_lang dictionary_id='57647.spec'></th>
			</cfif>
			<th><cf_get_lang dictionary_id='57519.Cari Hesap'></th>
			<th><cf_get_lang dictionary_id='57635.Miktar'></th>
			<th><cf_get_lang dictionary_id='57636.Birim'></th>
			<cfif isdefined('is_show_unit2') and is_show_unit2 eq 1 or not isdefined('is_show_unit2')>
				<th>2.<cf_get_lang dictionary_id='57636.Birim'></th>
			</cfif>
			<th><cf_get_lang dictionary_id='36418.Verilen Talep'></th>
			<th><cf_get_lang dictionary_id='36800.Verilen Ü.E'></th>
			<th><cf_get_lang dictionary_id='58444.Kalan'></th>
			<cfif is_show_work_prog eq 1>
				<th><cf_get_lang dictionary_id='36432.Çalışma Prog'></th>
			</cfif>
			<th><cf_get_lang dictionary_id='57635.Miktar'></th>
			<th><cf_get_lang dictionary_id='57655.Başlama Tarihi'><br/>
				<input type="text" name="temp_date" id="temp_date" value="<cfoutput>#dateformat(now(),dateformat_style)#</cfoutput>" style="width:70px;" class="box" onBlur="change_date_info();" validate="eurodate" message="<cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'> !">
				<input type="text" name="temp_hour" id="temp_hour" value="00" style="width:30px;" class="box" onKeyUp="isNumber(this);" onBlur="change_date_info();" validate="integer" message="<cf_get_lang dictionary_id='58781.Lütfen Saat Giriniz'> !">
				<input type="text" name="temp_min" id="temp_min" value="00" style="width:30px;" class="box" onKeyUp="isNumber(this);" onBlur="change_date_info();" validate="integer" message="<cf_get_lang dictionary_id='58781.Lütfen Saat Giriniz'> !">
			</th>
            <th>&nbsp;</th>
            <th width="1%">
				<cfif not(isdefined('attributes.is_excel') and attributes.is_excel eq 1) and(isdefined("attributes.is_submitted") eq 1)>
                	<input type="checkbox" name="allSelectOrder" id="allSelectOrder" onclick="wrk_select_all('allSelectOrder','is_active');">                
                 </cfif>
            </th>      
		</tr>
	</thead>
	<cfif get_orders.recordcount>
		<cfset company_name_list =''>
		<cfset consumer_name_list =''>
		<cfset spect_name_list =''>
		<cfset order_row_id_list=''>
        <cfset stock_id_list=''>
		<cfoutput query="get_orders">
			<cfif len(ORDER_ROW_ID)>
				<cfset order_row_id_list = ListAppend(order_row_id_list,ORDER_ROW_ID)>
			</cfif>
			<cfif len(COMPANY_ID) and not listfind(company_name_list,COMPANY_ID)>
				<cfset company_name_list = ListAppend(company_name_list,COMPANY_ID)>
			</cfif>
			<cfif len(CONSUMER_ID) and not listfind(consumer_name_list,CONSUMER_ID)>
				  <cfset consumer_name_list = ListAppend(consumer_name_list,CONSUMER_ID)>
			</cfif>
			<cfif len(SPECT_VAR_ID) and not listfind(spect_name_list,SPECT_VAR_ID)>
				<cfset spect_name_list = ListAppend(spect_name_list,SPECT_VAR_ID)>
			</cfif>
			<cfif len(STOCK_ID) and not listfind(stock_id_list,STOCK_ID)>
				<cfset stock_id_list = listappend(stock_id_list,STOCK_ID)>
            </cfif>
		</cfoutput>
        <cfif len(stock_id_list)>
        	<cfquery name="GET_STOCK_STATIONS" datasource="#DSN3#">
                SELECT
                	WP.STOCK_ID,
                    0 AS MAIN_STOCK_ID ,
                    W.STATION_ID AS STATION_ID_ ,
                    W.STATION_NAME,
                    WP.OPERATION_TYPE_ID,
                    ISNULL(WP.PRODUCTION_TIME,0) P_TIME
                FROM 
                    WORKSTATIONS W WITH (NOLOCK),
                    WORKSTATIONS_PRODUCTS WP WITH (NOLOCK)
                WHERE
                    W.STATION_ID = WP.WS_ID 
                    AND WP.STOCK_ID IN (#stock_id_list#)
                    AND WP.OPERATION_TYPE_ID IS NULL
            UNION ALL
                SELECT
                	WP.STOCK_ID,
                    WP.MAIN_STOCK_ID,
                    W.STATION_ID AS STATION_ID_ ,
                    W.STATION_NAME,
                    WP.OPERATION_TYPE_ID,
                    ISNULL(WP.PRODUCTION_TIME,0) P_TIME
                FROM 
                    WORKSTATIONS W WITH (NOLOCK),
                    WORKSTATIONS_PRODUCTS WP WITH (NOLOCK)
                WHERE
                    W.STATION_ID = WP.WS_ID 
                    AND WP.MAIN_STOCK_ID IN (#stock_id_list#)
            </cfquery>
            <cfloop query="GET_STOCK_STATIONS">
				<cfif not isdefined('stock_defined_stations_list_#STOCK_ID#')>
                    <cfset 'stock_defined_stations_list_#STOCK_ID#' = STATION_ID_>
                <cfelse>
                    <cfset 'stock_defined_stations_list_#STOCK_ID#' = listdeleteduplicates(ListAppend(Evaluate('stock_defined_stations_list_#STOCK_ID#'),STATION_ID_,','))>
                </cfif>
            </cfloop>
        </cfif>
		<cfif len(company_name_list)>
			<cfset company_name_list=listsort(company_name_list,"numeric","ASC",",")>
			<cfquery name="get_company_name" datasource="#DSN#">
				SELECT FULLNAME,COMPANY_ID FROM COMPANY WHERE COMPANY_ID IN (#company_name_list#) ORDER BY COMPANY_ID
			</cfquery>
			<cfset company_name_list = listsort(listdeleteduplicates(valuelist(get_company_name.COMPANY_ID,',')),'numeric','ASC',',')>
		</cfif>
		<cfif len(consumer_name_list)>
			<cfset consumer_name_list=listsort(consumer_name_list,"numeric","ASC",",")>
			<cfquery name="get_consumer_name" datasource="#DSN#">
				SELECT CONSUMER_NAME+' '+CONSUMER_SURNAME AS CONSUMER_NAME,CONSUMER_ID FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_name_list#) ORDER BY CONSUMER_ID
			</cfquery>
			<cfset consumer_name_list = listsort(listdeleteduplicates(valuelist(get_consumer_name.CONSUMER_ID,',')),'numeric','ASC',',')>
		</cfif>
		<cfif len(order_row_id_list)>
			<cfset order_row_id_list=listsort(order_row_id_list,"numeric","ASC",",")>
			<cfquery name="GET_PRODUCTION_INFO" datasource="#DSN3#">
            	SELECT 
                	ORDER_ROW_ID, 
                    TYPE,
                    SUM(QUANTITY) AS QUANTITY
				FROM     
                	(
                    	SELECT DISTINCT 
                        	ISNULL(POR.TYPE,1) AS TYPE,
                        	PO.QUANTITY, 
                            POR.PRODUCTION_ORDER_ID, 
                            OR_.ORDER_ROW_ID
                  		FROM      
                        	ORDER_ROW AS OR_ WITH (NOLOCK) INNER JOIN
                            PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) ON OR_.ORDER_ROW_ID = POR.ORDER_ROW_ID INNER JOIN
                            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON OR_.STOCK_ID = PO.STOCK_ID AND POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
                  		WHERE   
                        	PO.PRODUCTION_LEVEL = '0' AND 
                            POR.ORDER_ROW_ID IN (#order_row_id_list#)
                	) AS TBL
				GROUP BY 
                	ORDER_ROW_ID,
                    TYPE
			</cfquery>
            <cfscript>
            	for(gpi_ind=1;gpi_ind lte GET_PRODUCTION_INFO.recordcount;gpi_ind=gpi_ind+1){//ayrı ayrı göstereceğimiz için grupladık
					if(GET_PRODUCTION_INFO.TYPE[gpi_ind] eq 1)
						'verilen_uretim_emri_#GET_PRODUCTION_INFO.ORDER_ROW_ID[gpi_ind]#' = GET_PRODUCTION_INFO.QUANTITY[gpi_ind];
					else
						'verilen_talep_#GET_PRODUCTION_INFO.ORDER_ROW_ID[gpi_ind]#' = GET_PRODUCTION_INFO.QUANTITY[gpi_ind];
					if(not isdefined('toplam_#GET_PRODUCTION_INFO.ORDER_ROW_ID[gpi_ind]#'))
						'toplam_#GET_PRODUCTION_INFO.ORDER_ROW_ID[gpi_ind]#' =GET_PRODUCTION_INFO.QUANTITY[gpi_ind];
					else
						'toplam_#GET_PRODUCTION_INFO.ORDER_ROW_ID[gpi_ind]#' = Evaluate('toplam_#GET_PRODUCTION_INFO.ORDER_ROW_ID[gpi_ind]#')+GET_PRODUCTION_INFO.QUANTITY[gpi_ind];
				}
            </cfscript>
		</cfif>
		<cfif len(spect_name_list)>
			<cfset spect_name_list=listsort(spect_name_list,"numeric","ASC",",")>
			<cfquery name="GET_SPECT_NAME" datasource="#DSN3#">
				SELECT SPECT_VAR_NAME,SPECT_VAR_ID,SPECT_MAIN_ID FROM SPECTS WHERE SPECT_VAR_ID IN (#spect_name_list#) ORDER BY SPECT_VAR_ID
			</cfquery>
			<cfset spect_name_list = listsort(listdeleteduplicates(valuelist(GET_SPECT_NAME.SPECT_VAR_ID,',')),'numeric','ASC',',')>
		</cfif>
		<cfset _now_ = date_add('h',session.ep.TIME_ZONE,now())>
        <!---Ezgi Bilgisayar Özelleştirme Başlangıç--->
        <cfquery name="get_ezgi_order_detail" datasource="#dsn3#">
        	SELECT ORDER_ROW_ID, PRODUCT_NAME2 FROM ORDER_ROW WHERE ORDER_ROW_ID IN (#order_row_id_list#)
        </cfquery>
        <cfoutput query="get_ezgi_order_detail">
        	<cfset 'PRODUCT_NAME2_#ORDER_ROW_ID#' = PRODUCT_NAME2>
        </cfoutput>
		<cfquery name="get_station_times" datasource="#dsn#">
			SELECT * FROM SETUP_SHIFTS WHERE IS_PRODUCTION = 1 AND FINISHDATE > #_now_# AND SHIFT_ID = #attributes.SHIFT_ID#
		</cfquery>
        <!---Ezgi Bilgisayar Özelleştirme Başlangıç (AND SHIFT_ID = #attributes.SHIFT_ID# eklendi)  --->
		<cfquery name="get_station_times" datasource="#dsn#">
			SELECT * FROM SETUP_SHIFTS WHERE IS_PRODUCTION = 1 AND FINISHDATE > #_now_#
		</cfquery>
		<cfset works_prog = get_station_times.SHIFT_NAME>
		<cfset works_prog_id = get_station_times.SHIFT_ID>
		<cfoutput query="get_orders" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
			<cfif len(SPECT_VAR_ID)>
				<cfset _spect_main_id = GET_SPECT_NAME.SPECT_MAIN_ID[listfind(spect_name_list,get_orders.SPECT_VAR_ID,',')]>
				<cfset _spect_name = GET_SPECT_NAME.SPECT_VAR_NAME[listfind(spect_name_list,get_orders.SPECT_VAR_ID,',')]> 
			<cfelse>
				<cfset _spect_main_id =  '' >
				<cfset _spect_name = ''>
			</cfif>
            <tbody>
			<cfif isdefined('toplam_#ORDER_ROW_ID#')>
				<cfset kalan_uretim_emri = QUANTITY-Evaluate('toplam_#ORDER_ROW_ID#')>
			<cfelse>
				<cfset kalan_uretim_emri = QUANTITY>
			</cfif>
			<tr>
				<td width="1%">#currentrow#</td>
				<!-- sil -->
					<td align="center" id="order_row#currentrow#" onClick="gizle_goster(order_stocks_detail#currentrow#);connectAjax('#currentrow#','#PRODUCT_ID#','#STOCK_ID#','#kalan_uretim_emri#','#ORDER_ID#','#_spect_main_id#');gizle_goster(siparis_goster#currentrow#);gizle_goster(siparis_gizle#currentrow#);">
						<img id="siparis_goster#currentrow#" src="/images/listele.gif" border="0" title="<cf_get_lang dictionary_id ='58596.Göster'>" />
						<img id="siparis_gizle#currentrow#" src="/images/listele_down.gif" border="0" title="<cf_get_lang dictionary_id ='58628.Gizle'>" style="display:none;" />
					</td>
				<!-- sil -->
				<td nowrap="nowrap">
				<cfif attributes.fuseaction eq 'prod.popuptracking'>
					<a onClick="send_to_production(#order_id#,#order_row_id#,'#unit#','#attributes.is_demand#','#currentrow#')">#order_number#</a>
				<cfelse>
					<a href="#request.self#?fuseaction=prod.tracking&event=det&unit_name=#unit#&order_id=#order_id#&order_row_id=#order_row_id#">#order_number#</a>
				</cfif>
				</td>
				<td>#dateformat(order_date,dateformat_style)#</td>
				<td>
					<cfif is_show_delivery_date eq 1 and len(row_deliver_date)>
		                #dateformat(row_deliver_date,dateformat_style)#
					<cfelse>
    	                #dateformat(deliverdate,dateformat_style)#
					</cfif>
                </td>
				<cfif is_show_stock_code eq 1>
					<td>#STOCK_CODE#</td>
				</cfif>
				<td>
					<a href="#request.self#?fuseaction=prod.list_product_tree&event=upd&stock_id=#stock_id#" class="tableyazi">#product_name# #property#</a>
				</td>
				<cfif isdefined("is_order_detail") and is_order_detail eq 1><td>#order_detail# - <span style="font-style:italic">#Evaluate('PRODUCT_NAME2_#ORDER_ROW_ID#')#</span></td></cfif>
				<cfif isdefined('is_show_spec') and is_show_spec eq 1 or not isdefined('is_show_spec')>
				 <td>
					<cfif len(SPECT_VAR_ID)>
						<cfif is_show_spec_no eq 1>
							<a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_upd_spect&id=#SPECT_VAR_ID#&stock_id=#stock_id#','list');" class="tableyazi">
								#_spect_main_id#-#spect_var_id#
							</a>
						<cfelse>
							#_spect_name#	
						</cfif>
					</cfif>
				</td>
				</cfif>
				<td>
				<cfif len(COMPANY_ID)>
					#get_company_name.FULLNAME[listfind(company_name_list,get_orders.COMPANY_ID,',')]#
				<cfelseif len(CONSUMER_ID)>

					#get_consumer_name.CONSUMER_NAME[listfind(consumer_name_list,get_orders.CONSUMER_ID,',')]#
				</cfif>
				</td>
				<td style="text-align:right;">#tlformat(quantity)#</td>
				<td>#unit#</td>
				  <cfset attributes.stock_id=stock_id>
				  <cfset attributes.order_id=order_id>
				<cfif isdefined('is_show_unit2') and is_show_unit2 eq 1 or not isdefined('is_show_unit2')>
				 <td>#AMOUNT2# #UNIT2#</td>
				</cfif>
				<td style="text-align:right;">
					<cfif isdefined('verilen_talep_#ORDER_ROW_ID#')>
                        #Evaluate('verilen_talep_#ORDER_ROW_ID#')#
                    <cfelse>
                        0
                    </cfif>
				</td>
				<td style="text-align:right;">
					<cfif isdefined('verilen_uretim_emri_#ORDER_ROW_ID#')>
                        #Evaluate('verilen_uretim_emri_#ORDER_ROW_ID#')#
                    <cfelse>
                        0
                    </cfif>
				</td>
				<td nowrap style="text-align:right;">
                	<cfif isdefined('toplam_#ORDER_ROW_ID#')>
						<cfset kalan_uretim_emri = QUANTITY-Evaluate('toplam_#ORDER_ROW_ID#')>
					<cfelse>
                    	<cfset kalan_uretim_emri = QUANTITY>
					</cfif>
                    #kalan_uretim_emri#
				</td>
				<!-- sil -->
				<td style="display:none;">
                <cfset _stock_id_ = STOCK_ID>
					<select name="station_id_#currentrow#" id="station_id_#currentrow#" style="width:120px;">
						<cfloop query="get_w">
                        	<cfif isdefined('stock_defined_stations_list_#_stock_id_#') and ListFind(Evaluate('stock_defined_stations_list_#_stock_id_#'),get_w.station_id,',')>
								<option value="#station_id#,0,0,0,-1,#EXIT_DEP_ID#,#EXIT_LOC_ID#,#PRODUCTION_DEP_ID#,#PRODUCTION_LOC_ID#">#station_name#</option>
                            </cfif>
						</cfloop>
					</select>
				</td>
				<!-- sil -->
				<cfif attributes.fuseaction contains 'autoexcelpopuppage'>
					<cfif is_show_work_prog eq 1>
						<td>#works_prog#</td>
					</cfif>
				<cfelse>
					<cfif is_show_work_prog eq 1>
						<td nowrap width="140" valign="top">
                        	<div class="nohover_div">
                                <input type="text" name="work_prog_#currentrow#" id="work_prog_#currentrow#" readonly value="#works_prog#" style="width:120px;">
                                <input type="hidden" name="work_prog_id_#currentrow#" id="work_prog_id_#currentrow#" value="#works_prog_id#">
                                <a href="javascript://" onClick="goster(open_works_prog_#currentrow#);AjaxPageLoad('#request.self#?fuseaction=prod.popup_list_work_prog&rows=#currentrow#&divId=open_works_prog_#currentrow#&fieldName=work_prog_#currentrow#&fieldId=work_prog_id_#currentrow#','open_works_prog_#currentrow#',1);"><img src="/images/plus_thin.gif" border="0" align="absbottom" /></a>
                                <div style="position:absolute; margin-left:-150px; margin-top:10px; vertical-align:top;" id="open_works_prog_#currentrow#"></div>
                           </div>
                        </td>
					<cfelse>
						<input type="hidden" name="work_prog_#currentrow#" id="work_prog_#currentrow#" readonly value="#works_prog#" style="width:120px;">
						<input type="hidden" name="work_prog_id_#currentrow#" id="work_prog_id_#currentrow#"  value="#works_prog_id#">
					</cfif>
				</cfif>
				<cfif attributes.fuseaction contains 'autoexcelpopuppage'>
					<td><cfif kalan_uretim_emri lt 0>#tlformat(0)#<cfelse>#tlformat(kalan_uretim_emri)#</cfif></td>
					<td>
						#DateFormat(_now_,dateformat_style)#
					</td>
				<cfelse>
					<td><input type="text" name="production_amount_#currentrow#" id="production_amount_#currentrow#" style="width:65px;" value="<cfif kalan_uretim_emri lt 0>#tlformat(0)#<cfelse>#tlformat(kalan_uretim_emri)#</cfif>" class="moneybox" onKeyup="return(FormatCurrency(this,event,3));"></td>
					<td nowrap>
						<input maxlength="10" type="text" name="production_start_date_#currentrow#" id="production_start_date_#currentrow#"  validate="eurodate" style="width:65px;" value="#DateFormat(_now_,dateformat_style)#"><cf_wrk_date_image date_field="production_start_date_#currentrow#">
						<select name="production_start_h_#currentrow#" id="production_start_h_#currentrow#">
							<cfloop from="0" to="23" index="i">
								<option value="#i#"><cfif i lt 10>0</cfif>#i#</option>
							</cfloop>
						</select>
						<select name="production_start_m_#currentrow#" id="production_start_m_#currentrow#">
							<cfloop from="0" to="59" index="i">
								<option value="#i#"><cfif i lt 10>0</cfif>#i#</option>
							</cfloop>
						</select>
					</td>
				</cfif>
				<!-- sil -->
					<cfif attributes.fuseaction neq 'prod.popuptracking'>
						<td width="1%" align="center"><a href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_print_files&action_id=#order_id#&alt_module_name=sales&print_type=73','print_page');" class="tableyazi"><img src="/images/print2.gif" border="0" title="<cf_get_lang dictionary_id='57611.Sipariş'> Print"></a></td>
					</cfif>
					<td width="1%" align="center"><input type="checkbox" name="is_active" id="is_active" value="#order_id#-#order_row_id#-#_spect_main_id#-#unit#-#stock_code#"/></td>
				       
                <!-- sil -->
			</tr>
			<tr id="order_stocks_detail#currentrow#" style="display:none;" class="nohover">
				<td colspan="#colspan_info_new#">
					<div align="left" id="DISPLAY_ORDER_STOCK_INFO#currentrow#"></div>
				</td>
			</tr>
		</tbody>
		</cfoutput>
		<!-- sil -->
		<cfif is_add_order eq 1 or is_add_demand eq 1>
			<tfoot>
				<!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
				<form name="add_production_demand" method="post" action="<cfoutput>#request.self#?</cfoutput>fuseaction=prod.emptypopup_add_ezgi_production_order_all_sub">
                <input type="hidden" name="master_alt_plan_id" id="master_alt_plan_id"  value="<cfoutput>#attributes.master_alt_plan_id#</cfoutput>">
                <input type="hidden" name="master_plan_id" id="master_plan_id"  value="<cfoutput>#attributes.master_plan_id#</cfoutput>">
                <input type="hidden" name="islem_id" id="islem_id"  value="<cfoutput>#attributes.islem_id#</cfoutput>">	
                <!---Ezgi Bilgisayar Özelleştirme Bitiş--->
					<tr>
						<td colspan="<cfoutput>#colspan_info_new#</cfoutput>" style="text-align:right;">
							<input name="is_time_calculation"  id="is_time_calculation" type="hidden" value="<cfoutput>#is_time_calculation#</cfoutput>">
							<input name="is_cue_theory"  id="is_cue_theory" type="hidden" value="<cfoutput>#is_cue_theory#</cfoutput>">
							<input name="is_add_multi_demand"  id="is_add_multi_demand" type="hidden" value="<cfoutput>#is_add_multi_demand#</cfoutput>">
							<input name="station_id_list"  id="station_id_list" type="hidden" value="">
							<input name="works_prog_id_list"  id="works_prog_id_list" type="hidden" value="">
							<input name="production_amount_list"  id="production_amount_list" type="hidden" value="">
							<input name="order_row_id"  id="order_row_id" type="hidden" value="">
							<input name="order_id"  id="order_id" type="hidden" value="">
                            
							<input name="production_start_date_list"  id="production_start_date_list" type="hidden" value="">
							<input name="production_start_h_list"  id="production_start_h_list" type="hidden" value="">
							<input name="production_start_m_list"  id="production_start_m_list" type="hidden" value="">
							<input type="hidden" name="is_demand" id="is_demand" value="">
							<cfif not attributes.fuseaction contains 'popup'>
								<cf_get_lang dictionary_id="58859.Süreç"> : <cf_workcube_process is_upd='0' process_cat_width='120' is_detail='0'>
								<!---<cf_get_lang dictionary_id="36438.Talep Numarası">---><input type="text" name="demand_no" id="demand_no" style="display:none" value="" onKeyPress="if(event.keyCode==13)send_to_production('','',1,1);">
								<div id="user_message_" style="display:none;"></div>
								<cfif is_add_demand eq 1>
									<input type="button" name="demand_create_" id="demand_create_" style="display:none" value="<cf_get_lang dictionary_id="36441.Talep Oluştur">"  onClick="send_to_production('','',1,1);">
								</cfif>
							</cfif>
							<cfif is_add_order eq 1>
								<input type="button" name="send_to_production_" id="send_to_production_" value="<cf_get_lang dictionary_id="36825.Üretime Gönder">" onClick="send_to_production('','','','<cfoutput>#attributes.is_demand#</cfoutput>',0);">
							</cfif>
							<input type="button" name="production_material" id="production_material" style="display:none" value="<cf_get_lang dictionary_id="36523.Malzeme İhtiyaç Listesi">" onClick="demand_convert_to_production(3);" >
							<input type="button" name="production_material_all" id="production_material_all" style="display:none" value="<cf_get_lang dictionary_id="36524.Tümüne Malzeme İhtiyaç Listesi">" onClick="demand_convert_to_production(4);">
						</td>
					</tr> 
				</form>
				<form name="go_stock_list" method="post" action="<cfoutput>#request.self#?</cfoutput>fuseaction=prod.tracking">
					<input type="hidden" name="is_submitted" id="is_submitted" value="1">
					<input type="hidden" name="start_date" id="start_date" value="">
					<input type="hidden" name="finish_date" id="finish_date" value="">
					<input type="hidden" name="list_type" id="list_type" value="2">
					<input type="hidden" name="from_order_list" id="from_order_list" value="1">
					<input type="hidden" name="row_stock_all" id="row_stock_all" value="<cfoutput query="get_orders">#STOCK_CODE#<cfif currentrow neq recordcount>,</cfif></cfoutput>">
					<cfif get_orders.recordcount>
						<cfset kalan_uretim_emri__ =''>
						<cfoutput query="get_orders">
							<cfif isdefined('toplam_#ORDER_ROW_ID#')>
								<cfset 'kalan_uretim_emri_#ORDER_ROW_ID#' = QUANTITY-Evaluate('toplam_#ORDER_ROW_ID#')>
							<cfelse>
								<cfset 'kalan_uretim_emri_#ORDER_ROW_ID#' = QUANTITY>
							</cfif>
							<cfset kalan_uretim_emri__ = ListAppend(kalan_uretim_emri__,evaluate('kalan_uretim_emri_#ORDER_ROW_ID#'))>
						</cfoutput>
					</cfif>
					<input type="hidden" name="row_spect_all" id="row_spect_all" value="<cfoutput query="get_orders"><cfif len(SPECT_VAR_ID)>#GET_SPECT_NAME.SPECT_MAIN_ID[listfind(spect_name_list,get_orders.SPECT_VAR_ID,',')]#<cfelse>0</cfif><cfif currentrow neq recordcount>,</cfif></cfoutput>">
					<input type="hidden" name="row_amount_all" id="row_amount_all" value="<cfoutput>#kalan_uretim_emri__#</cfoutput>">
				</form>
				<form name="go_stock_list2" method="post" action="<cfoutput>#request.self#?</cfoutput>fuseaction=prod.tracking">
					<input type="hidden" name="is_submitted" id="is_submitted" value="1">
					<input type="hidden" name="start_date" id="start_date" value="">
					<input type="hidden" name="finish_date" id="finish_date" value="">
					<input type="hidden" name="list_type" id="list_type" value="2">
					<input type="hidden" name="from_order_list" id="from_order_list" value="1">
					<input type="hidden" name="row_stock_all_" id="row_stock_all_" value="">
					<input type="hidden" name="row_spect_all_" id="row_spect_all_" value="">
					<input type="hidden" name="row_amount_all_" id="row_amount_all_" value="">
				</form>
			</tfoot>
		</cfif>
		<!-- sil -->
	<cfelse>
    	<tbody>
            <tr>
                <td colspan="<cfoutput>#colspan_info_new#</cfoutput>"><cfif isdefined("attributes.is_submitted")><cf_get_lang dictionary_id='58486.Kayıt Bulunamadı'> !<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz '> !</cfif></td>
            </tr>
        </tbody>
	</cfif>
<cfelse>
	<cfif GET_ORDERS.recordcount>
		<cfset order_id_list = ValueList(GET_ORDERS.ORDER_ID,',')>
		<cfset order_row_id_list = ValueList(GET_ORDERS.ORDER_ROW_ID,',')>
		<cfquery name="get_order_inv_periods" datasource="#dsn3#">
			SELECT DISTINCT PERIOD_ID FROM ORDERS_INVOICE WHERE ORDER_ID IN(#order_id_list#)
		</cfquery>
		<cfif get_order_inv_periods.recordcount>
			<cfset orders_ship_period_list = valuelist(get_order_inv_periods.PERIOD_ID)>
			<cfif listlen(orders_ship_period_list) eq 1 and orders_ship_period_list eq session.ep.period_id>
				<cfquery name="get_processed_amount" datasource="#dsn2#">
					SELECT
						SUM(IR.AMOUNT) AS SHIP_AMOUNT,
						IR.STOCK_ID,
						ISNULL(IR.SPECT_VAR_ID,0) AS SPECT_VAR_ID,
						ISNULL(IR.WRK_ROW_RELATION_ID,0) AS WRK_ROW_RELATION_ID
					FROM
						INVOICE I WITH (NOLOCK),
						INVOICE_ROW IR WITH (NOLOCK)
					WHERE
						I.INVOICE_ID=IR.INVOICE_ID
						AND IR.ORDER_ID IN(#order_id_list#)
					GROUP BY
						IR.STOCK_ID,
						IR.SPECT_VAR_ID,
						ISNULL(IR.WRK_ROW_RELATION_ID,0)
				</cfquery>
			<cfelse>
				<cfquery name="get_period_dsns" datasource="#dsn#">
					SELECT PERIOD_YEAR,OUR_COMPANY_ID,PERIOD_ID FROM SETUP_PERIOD WITH (NOLOCK) WHERE PERIOD_ID IN (#orders_ship_period_list#)
				</cfquery>
				<cfquery name="get_processed_amount" datasource="#dsn2#">
					SELECT
						SUM(A1.SHIP_AMOUNT) AS SHIP_AMOUNT,
						A1.STOCK_ID,
						A1.SPECT_VAR_ID,
						A1.WRK_ROW_RELATION_ID
					FROM
					(
					<cfloop query="get_period_dsns">
						SELECT
							SUM(IR.AMOUNT) AS SHIP_AMOUNT,
							IR.STOCK_ID,
							ISNULL(IR.SPECT_VAR_ID,0) AS SPECT_VAR_ID,
							ISNULL(IR.WRK_ROW_RELATION_ID,0) AS WRK_ROW_RELATION_ID
						FROM
							#dsn#_#get_period_dsns.PERIOD_YEAR#_#get_period_dsns.OUR_COMPANY_ID#.INVOICE I WITH (NOLOCK),
							#dsn#_#get_period_dsns.PERIOD_YEAR#_#get_period_dsns.OUR_COMPANY_ID#.INVOICE_ROW IR WITH (NOLOCK)
						WHERE
							I.INVOICE_ID=IR.INVOICE_ID
							AND IR.ORDER_ID IN(#order_id_list#)
						GROUP BY
							IR.STOCK_ID,
							IR.SPECT_VAR_ID,
							ISNULL(IR.WRK_ROW_RELATION_ID,0)
						<cfif currentrow neq get_period_dsns.recordcount> UNION ALL </cfif>					
					</cfloop> ) AS A1
						GROUP BY
							A1.STOCK_ID,
							A1.SPECT_VAR_ID,
							A1.WRK_ROW_RELATION_ID
				</cfquery>
			</cfif>
		<cfelse>
			<cfquery name="get_order_ship_periods" datasource="#dsn3#">
				SELECT DISTINCT PERIOD_ID FROM ORDERS_SHIP WHERE ORDER_ID IN(#order_id_list#)
			</cfquery>
			<cfif get_order_ship_periods.recordcount>
				<cfset orders_ship_period_list = valuelist(get_order_ship_periods.PERIOD_ID)>
				<cfif listlen(orders_ship_period_list) eq 1 and orders_ship_period_list eq session.ep.period_id>
					<cfquery name="get_processed_amount" datasource="#dsn2#">
						SELECT
							SUM(SR.AMOUNT) AS SHIP_AMOUNT,
							SR.STOCK_ID,
							ISNULL(SR.SPECT_VAR_ID,0) AS SPECT_VAR_ID
						FROM
							SHIP S WITH (NOLOCK),
							SHIP_ROW SR WITH (NOLOCK)
						WHERE
							S.SHIP_ID=SR.SHIP_ID
							AND SR.ROW_ORDER_ID IN(#order_id_list#)
						GROUP BY
							SR.STOCK_ID,
							SR.SPECT_VAR_ID
					</cfquery>
				<cfelse>
						<cfquery name="get_period_dsns" datasource="#dsn2#">
							SELECT PERIOD_YEAR,OUR_COMPANY_ID,PERIOD_ID FROM #dsn_alias#.SETUP_PERIOD WITH (NOLOCK) WHERE PERIOD_ID IN (#orders_ship_period_list#)
						</cfquery>
						<cfquery name="get_processed_amount" datasource="#dsn2#">
							SELECT
								SUM(A1.SHIP_AMOUNT) AS SHIP_AMOUNT,
								A1.STOCK_ID,
								A1.SPECT_VAR_ID
							FROM
							(
							<cfloop query="get_period_dsns">
								SELECT
									SUM(SR.AMOUNT) AS SHIP_AMOUNT,
									SR.STOCK_ID,
									ISNULL(SR.SPECT_VAR_ID,0) AS SPECT_VAR_ID
								FROM
									#dsn#_#get_period_dsns.PERIOD_YEAR#_#get_period_dsns.OUR_COMPANY_ID#.SHIP S WITH (NOLOCK),
									#dsn#_#get_period_dsns.PERIOD_YEAR#_#get_period_dsns.OUR_COMPANY_ID#.SHIP_ROW SR WITH (NOLOCK)
								WHERE
									S.SHIP_ID=SR.SHIP_ID
									AND SR.ROW_ORDER_ID IN(#order_id_list#)
								GROUP BY
									SR.STOCK_ID,
									SR.SPECT_VAR_ID
								<cfif currentrow neq get_period_dsns.recordcount> UNION ALL </cfif>					
							</cfloop> ) AS A1
								GROUP BY
									A1.STOCK_ID,
									A1.SPECT_VAR_ID
						</cfquery>
					</cfif>
			<cfelse>
				<cfset get_order_ship_periods.recordcount =0>
			</cfif>
		</cfif>
		<cfscript>
			if(isdefined("get_processed_amount"))
				for(xxx=1; xxx lte get_processed_amount.recordcount; xxx=xxx+1)
					'processed_amount_#get_processed_amount.STOCK_ID[xxx]#_#get_processed_amount.SPECT_VAR_ID[xxx]#' = get_processed_amount.SHIP_AMOUNT[xxx];
		</cfscript>
	</cfif>
	<!---Ezgi Bilgisayar Özelleştirme Başlangıç--->
	<cfinclude template="../../../../v16/workdata/get_main_spect_id.cfm">
    <!---Ezgi Bilgisayar Özelleştirme Bitişi--->
	<cfif isdefined("attributes.is_submitted")>
		<cfsavecontent variable="lang_message"><cf_get_lang dictionary_id='36916.Teslim Tarihini Hesapla'></cfsavecontent>
		<cfset scrap_location = ''>
		<cfquery name="get_scrap_locations" datasource="#dsn#">
			SELECT
				SL.LOCATION_ID,
				SL.DEPARTMENT_ID
			FROM 
				STOCKS_LOCATION SL WITH (NOLOCK),
				DEPARTMENT D WITH (NOLOCK)
			WHERE
				SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND SL.IS_SCRAP = 1
		</cfquery>
		<cfif get_scrap_locations.recordcount>
			<cfsavecontent variable="scrap_location">
				<cfoutput>
				<cfloop query="get_scrap_locations">
				  AND NOT ( STORE_LOCATION = #LOCATION_ID# AND STORE = #DEPARTMENT_ID#)
				</cfloop>
				</cfoutput>
			</cfsavecontent>
		</cfif>
		<cfscript>
			stock__list ='';specm__list ='';
			for(o_ind=attributes.startrow;o_ind lt attributes.startrow+attributes.maxrows and GET_ORDERS.recordcount gte o_ind;o_ind=o_ind+1){
					
					'add_product_amount_#GET_ORDERS.STOCK_ID[o_ind]#_#GET_ORDERS.SPECT_VAR_ID[o_ind]#'=GET_ORDERS.QUANTITY[o_ind];
					row_dsp_amount_ = 0;
					if(isdefined('processed_amount_#GET_ORDERS.STOCK_ID[o_ind]#_#GET_ORDERS.SPECT_VAR_ID[o_ind]#') and len(evaluate('processed_amount_#GET_ORDERS.STOCK_ID[o_ind]#_#GET_ORDERS.SPECT_VAR_ID[o_ind]#')) and evaluate('processed_amount_#GET_ORDERS.STOCK_ID[o_ind]#_#GET_ORDERS.SPECT_VAR_ID[o_ind]#') gt 0 ){
						if (evaluate('add_product_amount_#GET_ORDERS.STOCK_ID[o_ind]#_#GET_ORDERS.SPECT_VAR_ID[o_ind]#') gt 0 and evaluate('processed_amount_#GET_ORDERS.STOCK_ID[o_ind]#_#GET_ORDERS.SPECT_VAR_ID[o_ind]#') gte evaluate('add_product_amount_#GET_ORDERS.STOCK_ID[o_ind]#_#GET_ORDERS.SPECT_VAR_ID[o_ind]#'))
							row_dsp_amount_=row_dsp_amount_+evaluate('add_product_amount_#GET_ORDERS.STOCK_ID[o_ind]#_#GET_ORDERS.SPECT_VAR_ID[o_ind]#');
						else if (evaluate('add_product_amount_#GET_ORDERS.STOCK_ID[o_ind]#_#GET_ORDERS.SPECT_VAR_ID[o_ind]#') gt 0 and evaluate('processed_amount_#GET_ORDERS.STOCK_ID[o_ind]#_#GET_ORDERS.SPECT_VAR_ID[o_ind]#') lt evaluate('add_product_amount_#GET_ORDERS.STOCK_ID[o_ind]#_#GET_ORDERS.SPECT_VAR_ID[o_ind]#'))
							row_dsp_amount_=row_dsp_amount_+evaluate('processed_amount_#GET_ORDERS.STOCK_ID[o_ind]#_#GET_ORDERS.SPECT_VAR_ID[o_ind]#');
					}
					SPECT_MAIN_ID_G = GET_ORDERS.SPECT_MAIN_ID[o_ind];
					STOCK_ID_G =GET_ORDERS.STOCK_ID[o_ind];
					if(not isdefined('order_row_g_#STOCK_ID_G#_#SPECT_MAIN_ID_G#')){
						ORDER_NUMBER_G = GET_ORDERS.ORDER_NUMBER[o_ind];
						ORDER_ROW_ID_G = GET_ORDERS.ORDER_ROW_ID[o_ind];
						ORDER_ID_G = GET_ORDERS.ORDER_ID[o_ind];
						PRODUCT_NAME_G = '#GET_ORDERS.PRODUCT_NAME[o_ind]# #GET_ORDERS.PROPERTY[o_ind]#';
						QUANTITY_G =  GET_ORDERS.QUANTITY[o_ind]-row_dsp_amount_;//sipariş miktarından sevk edilenler düşülüyor..
						STOCK_CODE_G = GET_ORDERS.STOCK_CODE[o_ind];
						stock__list = ListAppend(stock__list,STOCK_ID_G,',');
						specm__list = ListAppend(specm__list,SPECT_MAIN_ID_G,',');
					}	
					else{
						ORDER_NUMBER_G = '#GET_ORDERS.ORDER_NUMBER[o_ind]#,#ListGetAt(Evaluate('order_row_g_#STOCK_ID_G#_#SPECT_MAIN_ID_G#'),1,'§')#';
						ORDER_ROW_ID_G = '#GET_ORDERS.ORDER_ROW_ID[o_ind]#,#ListGetAt(Evaluate('order_row_g_#STOCK_ID_G#_#SPECT_MAIN_ID_G#'),2,'§')#';
						ORDER_ID_G = '#GET_ORDERS.ORDER_ID[o_ind]#,#ListGetAt(Evaluate('order_row_g_#STOCK_ID_G#_#SPECT_MAIN_ID_G#'),3,'§')#';
						QUANTITY_G = '#GET_ORDERS.QUANTITY[o_ind]-row_dsp_amount_+ListGetAt(Evaluate('order_row_g_#STOCK_ID_G#_#SPECT_MAIN_ID_G#'),5,'§')#';
					}
					//'order_row_g_#STOCK_ID_G#_#SPECT_MAIN_ID_G#' = '#ORDER_NUMBER_G#§#ORDER_ROW_ID_G#§#ORDER_ID_G#§#PRODUCT_NAME_G#§#QUANTITY_G#§#STOCK_CODE_G#';
					'order_row_g_#STOCK_ID_G#_#SPECT_MAIN_ID_G#' = '#ORDER_NUMBER_G#§#ORDER_ROW_ID_G#§#ORDER_ID_G#§#GET_ORDERS.PRODUCT_NAME[o_ind]# #GET_ORDERS.PROPERTY[o_ind]#§#QUANTITY_G#§#GET_ORDERS.STOCK_CODE[o_ind]#§#GET_ORDERS.PRODUCT_ID[o_ind]#';
			}
			if(listlen(stock__list,',')){
				//stok stratejileri
					sqlStrStrategy = '
						SELECT
							DISTINCT
							STOCK_ID,
							ISNULL(MAXIMUM_STOCK,0) AS MAXIMUM_STOCK,
							ISNULL(PROVISION_TIME,0) AS PROVISION_TIME ,
							ISNULL(REPEAT_STOCK_VALUE,0) AS REPEAT_STOCK_VALUE,
							ISNULL(MINIMUM_STOCK,0) AS MINIMUM_STOCK,
							ISNULL(MINIMUM_ORDER_STOCK_VALUE,0) AS MINIMUM_ORDER_STOCK_VALUE
						FROM
							STOCK_STRATEGY 
						WHERE
							STOCK_ID IN(#stock__list#) AND
							DEPARTMENT_ID IS NULL
						';
					getStockStrategy = cfquery(SQLString : sqlStrStrategy, Datasource : dsn3);
					for(strteg_ind=1;strteg_ind lte getStockStrategy.recordcount;strteg_ind=strteg_ind+1)
						'stock_strategy#getStockStrategy.STOCK_ID[strteg_ind]#'='#getStockStrategy.MINIMUM_STOCK[strteg_ind]#';//'#getStockStrategy.MAXIMUM_STOCK[strteg_ind]#,#getStockStrategy.PROVISION_TIME[strteg_ind]#,#getStockStrategy.REPEAT_STOCK_VALUE[strteg_ind]#,#getStockStrategy.MINIMUM_ORDER_STOCK_VALUE[strteg_ind]#';
					sqlStr = 'SELECT 
								SUM(SR.STOCK_IN - SR.STOCK_OUT) AS PRODUCT_STOCK,
								STOCK_ID
							FROM 
								STOCKS_ROW SR 
							WHERE 
								STOCK_ID IN (#stock__list#) 
								#scrap_location#
							GROUP BY
								 STOCK_ID';
					getProductStock = cfquery(SQLString : sqlStr, Datasource : dsn2);
					for(r_ind=1;r_ind lte getProductStock.recordcount;r_ind=r_ind+1){
						//'product_stock_#getProductStock.STOCK_ID[r_ind]#_#getProductStock.SPECT_MAIN_ID[r_ind]#'= getProductStock.PRODUCT_STOCK[r_ind];
						'product_stock_#getProductStock.STOCK_ID[r_ind]#'= getProductStock.PRODUCT_STOCK[r_ind];
						}
				 //--ürünün gerçek stokları	
				 //Ürünün Beklenen Sipariş ve Üretimleri
				 //siparişler için query
				 SqlStrStockRezer='
								SELECT
									SUM(STOCK_ARTIR) AS ARTAN,
									STOCK_ID
								FROM
									GET_STOCK_RESERVED
								WHERE
									STOCK_ID IN (#stock__list#)
								GROUP BY STOCK_ID';
				 getStockRezer = cfquery(SQLString : SqlStrStockRezer, Datasource : dsn3);
				SqlStrStockRezer2='
								SELECT
									SUM(STOCK_AZALT) AS ARTAN,
									STOCK_ID
								FROM
									GET_STOCK_RESERVED
								WHERE
									STOCK_ID IN (#stock__list#)
								GROUP BY STOCK_ID';
				getStockRezer2 = cfquery(SQLString : SqlStrStockRezer2, Datasource : dsn3);
				for(rez_ind=1;rez_ind lte getStockRezer.recordcount;rez_ind=rez_ind+1)
				{
					'rezerved_orders#getStockRezer.STOCK_ID[rez_ind]#'= getStockRezer.ARTAN[rez_ind];
				}
				for(rez_ind=1;rez_ind lte getStockRezer2.recordcount;rez_ind=rez_ind+1)
				{
					'all_rezerved_orders#getStockRezer2.STOCK_ID[rez_ind]#'= getStockRezer2.ARTAN[rez_ind];
				}
				//Üretimler için Rezerve					
				SqlStrProdRezer	='			
								SELECT
									SUM(STOCK_ARTIR) AS ARTAN,
									STOCK_ID
								FROM
									GET_PRODUCTION_RESERVED
								WHERE
									STOCK_ID IN (#stock__list#)
								GROUP BY STOCK_ID';
				getProdRezer = cfquery(SQLString : SqlStrProdRezer, Datasource : dsn3);	
				for(pro_r_ind=1;pro_r_ind lte getStockRezer.recordcount;pro_r_ind=pro_r_ind+1)
					'rezerved_prod#getProdRezer.STOCK_ID[pro_r_ind]#'= getProdRezer.ARTAN[pro_r_ind];
				 //---Ürünün Beklenen Sipariş ve Üretimleri
				if(is_show_total_order eq 1)
					new_td = '<th class="form-title" width="80" style="text-align:right;" title="Toplam Sipariş Miktarı">Toplam Sipariş Miktarı</th>';
				else
					new_td = '';
			}
			else
				new_td = '';
			if(isdefined('is_show_spec') and is_show_spec eq 1 or not isdefined('is_show_spec'))
				spect_td_ = '<th width="50" class="form-title">Main Spec</th>';
			else
				spect_td_ = '';
			writeoutput("
			<thead>
				<tr>
					<!-- sil -->
					<th width='1%'></th>
					<!-- sil -->
					<th class='form-title' width='80'><cf_get_lang dictionary_id='57611.Sipariş'></th>
					<th class='form-title' width='150'><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
					<th class='form-title' width='350'><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
					#spect_td_#
					<th width='1%' align='cente' class='form-title'><cfoutput><cf_get_lang dictionary_id='40235.Sipariş Miktarı'></th>
					<th class='form-title' width='80' style='text-align:right;'><cf_get_lang dictionary_id='496.Sipariş Toplamı'></th>
					#new_td#
					<th class='form-title' width='80' style='text-align:right;'><cf_get_lang dictionary_id='58120.Gerçek Stok'></th>
					<th class='form-title' width='70' style='text-align:right;'><cf_get_lang dictionary_id='497.Acil İhtiyaç'></th>
					<th class='form-title' width='40' style='text-align:right;'><cf_get_lang dictionary_id='499.Min. Seviye'></th>	
					<th class='form-title' width='80' style='text-align:right;'><cf_get_lang dictionary_id='500.İhtiyaç Miktarı'></th>
					<th class='form-title' width='80' style='text-align:right;'><cf_get_lang dictionary_id='57456.Üretim'></th>
					<th class='form-title' width='80' style='text-align:right;'><cf_get_lang dictionary_id='57611.Sipariş'></th>
					<!--- <th class='form-title' width='80' style='text-align:right;' title='Diğer Satış Siparişleri'><cf_get_lang dictionary_id='1085.Satış Sipariş'></th> --->
					<th class='form-title' width='120' style='text-align:right;'><cf_get_lang dictionary_id='57611.Üretim Miktarı'></th>
					<!-- sil -->
					<th class='form-title'  width='1%' align='center'></th>
					<th class='form-title'  width='1%' align='center'></th>
					<!-- sil -->
				</tr>
			</thead>	
			");
			if(listlen(stock__list,',')){
				for(ss_ind=1;ss_ind lte listlen(stock__list,',');ss_ind=ss_ind+1){
					_stock_id_ = ListGetAt(stock__list,ss_ind,',');
					_spec_main_id_ = ListGetAt(specm__list,ss_ind,',');
					all_values = Evaluate("order_row_g_#_stock_id_#_#_spec_main_id_#");
					siparis_toplami = ListGetAt(all_values,5,'§');//
					order_row_ids_ =ListGetAt(all_values,2,'§');
					order_ids_ = ListGetAt(all_values,3,'§');
					stock_code = ListGetAt(all_values,6,'§');
					product_name = ListGetAt(all_values,4,'§');
					product_id = ListGetAt(all_values,7,'§');
					if(not isdefined('rezerved_prod#_stock_id_#'))
						'rezerved_prod#_stock_id_#' =0;
					if(not isdefined('rezerved_orders#_stock_id_#'))
						'rezerved_orders#_stock_id_#'=0;
					if(not isdefined('all_rezerved_orders#_stock_id_#'))
						'all_rezerved_orders#_stock_id_#'=0;
					if(isdefined('stock_strategy#_stock_id_#'))	min_seviye= Evaluate('stock_strategy#_stock_id_#');	else min_seviye= 0;	
					if(not isdefined('product_stock_#_stock_id_#'))
						gercek_stok = 0; else gercek_stok = Evaluate('product_stock_#_stock_id_#');
						
					if(isdefined("is_calc_total_order") and is_calc_total_order eq 1)
						ihtiyac_miktari =  evaluate("all_rezerved_orders#_stock_id_#")-gercek_stok+min_seviye;//Üretilecek miktar = ÜrünMiktarı-GerçekStok+MinStok		
					else
						ihtiyac_miktari = siparis_toplami-gercek_stok+min_seviye;//Üretilecek miktar = ÜrünMiktarı-GerçekStok+MinStok
					
						
					if(ihtiyac_miktari lte 0) 
					{
						if(isdefined("is_calc_total_order") and is_calc_total_order eq 1)
							ihtiyac_miktari = evaluate("all_rezerved_orders#_stock_id_#");
						else
							ihtiyac_miktari = siparis_toplami;
					}
					satir_siparisler = ListGetAt(all_values,1,'§');
					if(_spec_main_id_ lte 0){//siparişte ürün için spec seçilmemiş ise bu listede ürünün ağacındaki mevcut varyasyonundaki spec'i ile gösteriliyor.
						_xxxxxx_ = get_main_spect_id(_stock_id_);
						if(len(_xxxxxx_.SPECT_MAIN_ID)){
							s_link = "&upd_main_spect=1&spect_main_id=#_xxxxxx_.SPECT_MAIN_ID#";
							_spec_main_id_ = _xxxxxx_.SPECT_MAIN_ID;
						}
						else
						s_link = "";
					}
					else
						s_link = '&upd_main_spect=1&spect_main_id=#_spec_main_id_#';
					if(isdefined("is_calc_total_order") and is_calc_total_order eq 1)
						acil_ihtiyac = evaluate("all_rezerved_orders#_stock_id_#")-gercek_stok;//Siparişteki toplam Miktar - Ürünün gerçek stoğu,eğer siparişteki miktarlar ürünün gerçek stoğundan küçük ise,acil ihtiyaç - değer olmasın diye 0 atıyoruz.
					else
						acil_ihtiyac = siparis_toplami-gercek_stok;//Siparişteki toplam Miktar - Ürünün gerçek stoğu,eğer siparişteki miktarlar ürünün gerçek stoğundan küçük ise,acil ihtiyaç - değer olmasın diye 0 atıyoruz.
					acil_ihtiyac_txt_color = 'red';
					if(acil_ihtiyac lte 0)
					{
							acil_ihtiyac = 0; acil_ihtiyac_txt_color ='';
							if(isdefined("is_calc_total_order") and is_calc_total_order eq 1)
								ihtiyac_miktari = min_seviye + evaluate("all_rezerved_orders#_stock_id_#") - gercek_stok;
							else
								ihtiyac_miktari = min_seviye + siparis_toplami - gercek_stok;
					}
					
					//Üretim için gerekli miktarı gerekli miktardan ürünün verilmiş olan üretim emirlerini ve satınalma siparişlerindkei rezerve miktarlarının çıkartarak
					//burda yeniden set ediyoruz.Bunu yapmamızın sebebi stoğun şişmesini engellemek...İhtiyaç:200 Ür:50 Sip:150 olsun..200 üretitsem siparişten ve önceki üretimden toplam 350 tane daha stoğuma girer bu durumda fazladan stoğum olmuş olur..İşte bunu engelliyoruz..
					optimum_ihtiyac = ihtiyac_miktari-Evaluate("rezerved_prod#_stock_id_#")-Evaluate("rezerved_orders#_stock_id_#");	
					if(optimum_ihtiyac lte 0)	//eğerki ihtiyaç miktarı 0 ise optimum ihtiyaçda 0 olmalıdır...
						optimum_ihtiyac =0;
					if(is_show_total_order eq 1)
						new_td = '<td style="text-align:right;">#tlformat(evaluate("all_rezerved_orders#_stock_id_#"))#</td>';
					else
						new_td = '';
					if(is_add_order eq 1 or is_add_demand eq 1)
					{
						order_td = '<td nowrap>';
						if(is_add_order eq 1)
						{
							order_td = '#order_td#<img src="/images/workdevwork.gif" align="absmiddle" onclick="send_to_production_group(#ss_ind#);" style="cursor:pointer;" border="0">';
						}
						if(is_add_demand eq 1)
						{
							order_td = '#order_td#<img src="/images/action.gif" align="absmiddle" onclick="send_to_production_group(#ss_ind#,1);" style="cursor:pointer;"m border="0">';
						}
						order_td = '#order_td#</td>';
					}
					else
						order_td = '';
					if(isdefined('is_show_spec') and is_show_spec eq 1 or not isdefined('is_show_spec'))
						spect_td = '<td style="text-align:right;"><a onClick=windowopen("#request.self#?fuseaction=objects.popup_upd_spect#s_link#","list"); style="cursor:pointer;" class="tableyazi">#_spec_main_id_#</a></td>';
					else
						spect_td = '';
					writeoutput('<tbody>
									<tr height="20" onMouseOver=this.className="color-light"; onMouseOut=this.className="color-row"; class="color-row">
									<!-- sil -->
									<td align="center" id="order_row#ss_ind#" class="color-row" onClick="gizle_goster(order_stocks_detail#ss_ind#);connectAjax(#ss_ind#,0,#_stock_id_#,#optimum_ihtiyac#,0,#_spec_main_id_#,#optimum_ihtiyac#);gizle_goster(siparis_goster#ss_ind#);gizle_goster(siparis_gizle#ss_ind#);">
										<input type="hidden" name="order_ids_#ss_ind#" id="order_ids_#ss_ind#" value="#order_ids_#">
										<input type="hidden" name="order_row_ids_#ss_ind#" id="order_row_ids_#ss_ind#" value="#order_row_ids_#">
										<img id="siparis_goster#ss_ind#" src="/images/listele.gif" border="0" alt="Göster" style="cursor:pointer;">
										<img id="siparis_gizle#ss_ind#" src="/images/listele_down.gif" border="0" alt="Gizle" style="cursor:pointer;display:none">
									</td>
									<!-- sil -->
									<td>
										<a style="cursor:pointer;" class="tableyazi" onClick="show_order_detail(#ss_ind#);">#left(satir_siparisler,7)#....</a>
										<!-- sil -->
										<div style="width:200px;position:absolute;" id="order_det_info#ss_ind#" class="nohover_div"></div>
										<!-- sil -->
									</td>								
									<td width="150"><a href="#request.self#?fuseaction=stock.list_stock&event=det&pid=#product_id#" class="tableyazi">#stock_code#</a></td>
									<td width="350"><a href="#request.self#?fuseaction=prod.list_product_tree&event=upd&stock_id=#_stock_id_#" class="tableyazi">#product_name#</a></td>
									#spect_td#
									<td style="text-align:right;">#listlen(satir_siparisler,',')#</td>
									<td style="text-align:right;">#tlformat(siparis_toplami)#</td>
									#new_td#
									<td style="text-align:right;">#tlformat(gercek_stok)#</td>
									<td style="text-align:right;"><font color="#acil_ihtiyac_txt_color#">#tlformat(acil_ihtiyac)#</font></td>
									<td style="text-align:right;">#tlformat(min_seviye)#</td>
									<td style="text-align:right;">#tlformat(ihtiyac_miktari)#<input type="hidden" value="#optimum_ihtiyac#" name="production_amount#ss_ind#" id="production_amount#ss_ind#"></td>
									<td style="text-align:right;">
										<div>
											<div style="position:absolute;z-index:2;margin-left:-300px;width:300px; vertical-align:top;" id="deliver_date_info#ss_ind#"></div>
											<div style="margin-left:-400px;height:200px;position:absolute;overflow:auto;height:200px;" id="show_rezerved_orders_detail#ss_ind#"></div>
											<div style="margin-left:-700px;height:200px; position:absolute; overflow:auto;height:200px;" id="show_rezerved_prod_detail#ss_ind#"></div>									
										</div>
										<a style="cursor:pointer;" onClick="show_rezerved_prod_detail(#ss_ind#,#_stock_id_#);"  class="tableyazi">#tlformat(Evaluate("rezerved_prod#_stock_id_#"))#</a>
									</td>
									<td style="text-align:right;"><a style="cursor:pointer;" class="tableyazi" onClick="show_rezerved_orders_detail(#ss_ind#,#_stock_id_#,0);">#tlformat(Evaluate("rezerved_orders#_stock_id_#"))#</a></td>
									<td style="text-align:right;">#tlformat(optimum_ihtiyac)#
									<input type="hidden" name="production_amount_#ss_ind#" id="production_amount_#ss_ind#" value="#tlformat(optimum_ihtiyac)#">
									</td>
									<!-- sil -->
									<td>
										<img src="/images/calendar.gif" style="cursor:pointer;"  class="tableyazi" onClick="calc_deliver_date(#ss_ind#,#_stock_id_#,#optimum_ihtiyac#,#_spec_main_id_#);"  align="absmiddle" border="0" alt="#lang_message#">
									</td>
									#order_td#
									<!-- sil -->
								</tr>
								<!-- sil -->
								<tr id="order_stocks_detail#ss_ind#" style="display:none" class="nohover">
									<td colspan="20">
										<div align="left" id="DISPLAY_ORDER_STOCK_INFO#ss_ind#">
										</div>
									</td>
								</tr>
								<!-- sil -->
								</tbody>
								');
				}				
			}

			else
			writeoutput('<tbody><tr class="color-row"><td colspan="20">Kayıt Bulunamadı!</td></tr></tbody>');
		</cfscript>
	</cfif>  
</cfif>
<script type="text/javascript">
	function calc_deliver_date(row_id,stock_id,amount,spec_main_id){
		document.getElementById('deliver_date_info'+row_id+'').style.display='';
		stock_id_list=''+stock_id+'-'+spec_main_id+'-'+amount+'-1';
		AjaxPageLoad(<cfoutput>'#request.self#?fuseaction=prod.popup_ajax_deliver_date_calc&from_p_order_list=1&row_id='+row_id+'&stock_id_list='+stock_id_list+''</cfoutput>,'deliver_date_info'+row_id+'',1,"Teslim Tarihi Hesaplanıyor");
	}
	function send_to_production_group(row_id,_type){
		if(_type != undefined && _type == 1)
			demand_ = '&is_demand=1';
		else
			demand_ = '';
		window.location="<cfoutput>#request.self#?</cfoutput>fuseaction=prod.order&event=add&production_amount="+document.getElementById('production_amount'+row_id).value+"&order_row_id="+document.getElementById('order_row_ids_'+row_id).value+"&order_id="+document.getElementById('order_ids_'+row_id).value+""+demand_;
	}
	function show_order_detail(row_id){
		order_ids =document.getElementById('order_ids_'+row_id).value;
		AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_ajax_list_order_comp_det&order_ids='+order_ids+'&row_id='+row_id+'&order_row_id='+document.getElementById('order_row_ids_'+row_id).value+'','order_det_info'+row_id);
	}
	function show_rezerved_orders_detail(row_id,stock_id,type){
		document.getElementById('show_rezerved_orders_detail'+row_id+'').style.display='';
		AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_reserved_orders&taken='+type+'&sid='+stock_id+'&row_id='+row_id+'&order_row_id='+document.getElementById('order_row_ids_'+row_id).value+'','show_rezerved_orders_detail'+row_id+'',1);
	}
	function show_rezerved_prod_detail(row_id,stock_id){
		document.getElementById('show_rezerved_prod_detail'+row_id+'').style.display='';
		AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_reserved_production_orders&type=1&sid='+stock_id+'&row_id='+row_id+'','show_rezerved_prod_detail'+row_id+'',1);
	}
	function send_to_production(order_id,order_row_id,unit_name,_type,row)
	{
		if(_type != undefined)// && _type == 1
		{
			if(_type == 1)
				demand_ = '&is_demand=1';
			else
				demand_ = '';
		}
		else
			demand_ = '';
		if(order_id >0 && order_row_id > 0){//sadece 1 siparişe tıklanıyorsa 
			if(document.getElementById('production_amount_'+row).value == "" || filterNum(document.getElementById('production_amount_'+row).value) == 0){
				alert('<cf_get_lang dictionary_id='506.Girilen Miktar 0 Olamaz'>...');
				document.getElementById('production_amount_'+row).focus();
				return false;
			}
			row_amount = document.getElementById('production_amount_'+row).value;
			window.opener.location="<cfoutput>#request.self#?</cfoutput>fuseaction=prod.order&event=add&production_amount="+row_amount+"&unit_name="+unit_name+"&order_row_id="+order_row_id+"&order_id="+order_id+""+demand_;
			window.close();
			return false;
		}
		else if(document.getElementsByName('is_active').length > 0){
			 var order_row_id_list="";
			 var order_id_list="";
			 var station_id_list = "";
			 var production_start_date_list = "";
			 var production_start_h_list = "";
			 var production_start_m_list = "";
			 var works_prog_id_list = "";
			 var spect_main_id_list ="";
			 var production_amount_list = "";
			 var unit_name = "";
			 production_amount_ = 0;
			 if(document.getElementsByName('is_active').length ==1){
				order_id_list+=list_getat(document.all.is_active.value,1,'-')+',';
				order_row_id_list+=list_getat(document.all.is_active.value,2,'-')+',';
				spect_main_id_list+=list_getat(document.all.is_active.value,3,'-')+',';
				if(document.getElementById('station_id_1').value != "")
					station_id_list += document.getElementById('station_id_1').value+'@';
				else
					station_id_list +='0,0,0,0,0,0,0,0,0@';
				production_start_date_list += document.getElementById('production_start_date_1').value+',';
				production_start_h_list += document.getElementById('production_start_h_1').value+',';
				production_start_m_list += document.getElementById('production_start_m_1').value+',';
				works_prog_id_list+= document.getElementById('work_prog_id_1').value+',';
				if(filterNum(document.getElementById('production_amount_1').value) == 0 || document.getElementById('production_amount_1').value == ""){
					alert('<cf_get_lang dictionary_id='506.Girilen Miktar 0 Olamaz'>..');document.getElementById('production_amount_1').focus();return false;
				}
				else
					production_amount_list+=filterNum(document.getElementById('production_amount_1').value,3)+',';
				production_amount_=parseFloat(production_amount_)+parseFloat(filterNum(document.getElementById('production_amount_1').value,3));
				var unit_name = list_getat(document.all.is_active.value,4,'-');
			 }
			 else {
				  unit_name+=list_getat(document.all.is_active[0].value,4,'-')+',';
				  <cfoutput>
				  for (i=0;i<document.getElementsByName('is_active').length;i++){
						if( list_getat(document.all.is_active[i].value,3,'-') == "")
							var _spec_main_id = -1;
						else
							var _spec_main_id = list_getat(document.all.is_active[i].value,3,'-');
							
						if(document.all.is_active[i].checked==true)
						{
							order_id_list+=list_getat(document.all.is_active[i].value,1,'-')+',';//1.ci alan order id'yi tutuyor
							order_row_id_list+=list_getat(document.all.is_active[i].value,2,'-')+',';//2.ci alan order_row id'yi tutuyor
							new_row_number = parseInt(#attributes.startrow#+i);
							if(document.getElementById('station_id_'+new_row_number).value != "")
								station_id_list+=document.getElementById('station_id_'+new_row_number).value+'@';
							else
								station_id_list +='0,0,0,0,0,0,0,0,0@';
							if(document.getElementById('production_start_date_'+new_row_number) != undefined)
							{
								production_start_date_list+=document.getElementById('production_start_date_'+new_row_number).value+',';
								production_start_h_list +=document.getElementById('production_start_h_'+new_row_number).value+',';
								production_start_m_list +=document.getElementById('production_start_m_'+new_row_number).value+',';
								works_prog_id_list+=document.getElementById('work_prog_id_'+new_row_number).value+',';
							}
							else
							{
								production_start_date_list+=''+',';
								production_start_h_list +=''+',';
								production_start_m_list +=''+',';
								works_prog_id_list+=''+',';
							}
							if(document.getElementById('production_amount_'+new_row_number).value == "" || filterNum(document.getElementById('production_amount_'+new_row_number).value) == 0){
								alert('<cf_get_lang dictionary_id='506.Girilen Miktar 0 Olamaz'>...');
								document.getElementById('production_amount_'+new_row_number).focus();
								return false;
							}
							else
								production_amount_list+=filterNum(document.getElementById('production_amount_'+new_row_number).value,3)+',';
							production_amount_=parseFloat(production_amount_)+parseFloat(filterNum(document.getElementById('production_amount_'+new_row_number).value,3));
							if(!list_find(spect_main_id_list,_spec_main_id,','))
								spect_main_id_list+=_spec_main_id+',';
						}	
					}
				  </cfoutput>	
				  }
			if(list_len(order_row_id_list,',') > 1)
			{//sipariş seçilmiş ise
				order_id_list = order_id_list.substr(0,order_id_list.length-1);//sondaki virgülden kurtarıyoruz.
				order_row_id_list = order_row_id_list.substr(0,order_row_id_list.length-1);
				station_id_list = station_id_list.substr(0,station_id_list.length-1);
				production_start_date_list = production_start_date_list.substr(0,production_start_date_list.length-1);
				production_start_h_list = production_start_h_list.substr(0,production_start_h_list.length-1);
				production_start_m_list = production_start_m_list.substr(0,production_start_m_list.length-1);
				works_prog_id_list = works_prog_id_list.substr(0,works_prog_id_list.length-1);
				production_amount_list= production_amount_list.substr(0,production_amount_list.length-1);
				spect_main_id_list = spect_main_id_list.substr(0,spect_main_id_list.length-1);
				unit_name = unit_name.substr(0,unit_name.length-1);
				<cfif attributes.fuseaction neq 'prod.popuptracking'>
						process_stage = document.getElementById('process_stage').value;
						demand_no = document.getElementById('demand_no').value;
						if(demand_no =="" && _type != undefined && _type == 1){
							alert('<cf_get_lang dictionary_id='507.Talep Numarası'>');
							document.getElementById('demand_no').focus();
							return false;
						}
						if(process_stage ==""){
							alert('<cf_get_lang dictionary_id='58859.Süreç'>');
							document.getElementById('process_stage').focus();
							return false;
						}
						is_ok = 1;
						if(_type != undefined && _type == 1){
							var get_demend_control = wrk_safe_query('prdp_get_demend_control','dsn3',0,demand_no);
							if(get_demend_control.recordcount){
								if(confirm('<cf_get_lang dictionary_id='508.Bu Talep Numarası Daha Önceden Kullanılmış,Devam Ederseniz Seçtiğiniz Siparişler Bu Talep Numarasına Eklenecektir.Devam Etmek İstiyor musunuz?'>'))
									is_ok = 1;
								else
									is_ok = 0;
							}
						}
						if(is_ok == 1){
							document.getElementById('is_demand').value = _type;
							document.getElementById('station_id_list').value = station_id_list;
							document.getElementById('works_prog_id_list').value = works_prog_id_list;
							document.getElementById('production_amount_list').value = production_amount_list;
							document.getElementById('order_row_id').value = order_row_id_list;
							document.getElementById('order_id').value = order_id_list;
							document.getElementById('production_start_m_list').value = production_start_m_list;
							document.getElementById('production_start_h_list').value = production_start_h_list;
							document.getElementById('production_start_date_list').value = production_start_date_list;
							if(document.getElementById('demand_create_') != undefined)
								document.getElementById('demand_create_').disabled=true;
							if(document.getElementById('send_to_production_') != undefined)
								document.getElementById('send_to_production_').disabled=true;
							if(_type==1)
								document.getElementById('user_message_').innerHTML = '<cf_get_lang dictionary_id='510.Talepler Oluşturuluyor'>..<cf_get_lang dictionary_id='509.Sayfayı Yenilemeyiniz..Lütfen Bekleyiniz...'>';
							else if(_type==0)
								document.getElementById('user_message_').innerHTML = '<cf_get_lang dictionary_id='511.Üretime Gönderiliyor'>...<cf_get_lang dictionary_id='509.Sayfayı Yenilemeyiniz..Lütfen Bekleyiniz...'>';
							document.getElementById('user_message_').style.display='';
							document.add_production_demand.submit();
						}
				<cfelse>
					var get_order_control = wrk_safe_query('prdp_get_order_control','dsn3',0,order_row_id_list);
					if(get_order_control.recordcount == 1)
					{
						window.opener.location="<cfoutput>#request.self#?</cfoutput>fuseaction=prod.order&event=add&production_amount="+production_amount_+"&unit_name="+unit_name+"&order_row_id="+order_row_id_list+"&order_id="+order_id_list+""+demand_;
						window.close();
					}
					else
					{
						alert("<cf_get_lang dictionary_id='512.Farklı Ürün veya Spec İçin Seçim Yapamazsınız'> !");
						return false;
					}
				</cfif>
			}
			else{
				alert("<cf_get_lang dictionary_id='513.Üretime Göndermek İçin Sipariş Seçiniz'>");
				return false;
			}		
		}
	}
	
	function demand_convert_to_production(type)
	{
		
		if(type==4)// type 4 ise
		{
			
			document.getElementById("production_material_all").value='<cfoutput>#getLang("main",293)#</cfoutput>';
			document.getElementById("production_material_all").disabled = true;
			window.go_stock_list.action = "<cfoutput>#request.self#</cfoutput>?fuseaction=prod.list_materials_total";
			document.go_stock_list.submit();
		}
                    
		else if(type==3)
		{
			if(document.getElementsByName('is_active').length > 0)
			{
				var row_stock_all_list ="";
				var row_spect_all_list = "";
				var row_amount_all_list = "";
				if(document.getElementsByName('is_active').length ==1)
				{
					if( list_getat(document.all.is_active.value,3,'-') == "")
						var _spec_main_id = 0;
					else
						var _spec_main_id = list_getat(document.all.is_active.value,3,'-');
					row_spect_all_list+=_spec_main_id+',';
					row_stock_all_list+=list_getat(document.all.is_active.value,5,'-')+',';
					if(filterNum(document.getElementById('production_amount_1').value) == 0 || document.getElementById('production_amount_1').value == "")
					{
						alert('<cf_get_lang dictionary_id='506.Girilen Miktar 0 Olamaz'>...');
						document.getElementById('production_amount_1').focus();
						return false;
					}
					else
						row_amount_all_list+=filterNum(document.getElementById('production_amount_1').value,3)+',';
				}
				else
				{
					<cfoutput>
						for (i=0;i<document.getElementsByName('is_active').length;i++)
						{
							if( list_getat(document.all.is_active[i].value,3,'-') == "")
								var _spec_main_id = 0;
							else
								var _spec_main_id = list_getat(document.all.is_active[i].value,3,'-');
							
							if(document.all.is_active[i].checked==true)
							{
								new_row_number = parseInt(#attributes.startrow#+i);
								if(document.getElementById('production_amount_'+new_row_number).value == "" || filterNum(document.getElementById('production_amount_'+new_row_number).value) == 0)
								{
									alert('<cf_get_lang dictionary_id='506.Girilen Miktar 0 Olamaz'>...');
									document.getElementById('production_amount_'+new_row_number).focus();
									return false;
								}
								else
									row_amount_all_list+=filterNum(document.getElementById('production_amount_'+new_row_number).value,3)+',';
								
								row_spect_all_list+=_spec_main_id+',';
								row_stock_all_list+=list_getat(document.all.is_active[i].value,5,'-')+',';
							}
						}
					</cfoutput>
				}
				
				if(list_len(row_stock_all_list,',') > 1)
				{
					document.getElementById("production_material").value='<cfoutput>#getLang("main",293)#</cfoutput>';
					document.getElementById("production_material").disabled = true;
					document.getElementById('row_stock_all_').value = row_stock_all_list;
					document.getElementById('row_spect_all_').value = row_spect_all_list;
					document.getElementById('row_amount_all_').value = row_amount_all_list;
					window.go_stock_list2.action = "<cfoutput>#request.self#</cfoutput>?fuseaction=prod.list_materials_total";
					document.go_stock_list2.submit();
				}
			}
			else
			{
				alert("<cf_get_lang dictionary_id='57725.Ürün Seçiniz'>");
				return false;
			}	
		}
	}
	function product_control(){/*Ürün seçmeden spec seçemesin.*/
		if(document.getElementById('stock_id_').value=="" || document.getElementById('product_name').value == "" ){
			alert("<cf_get_lang dictionary_id='514.Spect seçmek için öncelikle ürün seçmeniz gerekmektedir'>");
			return false;
		}
		else
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_spect_main&field_main_id=search.spect_main_id&field_name=search.spect_name&is_display=1&stock_id='+document.getElementById('stock_id_').value,'list');
	}
</script>