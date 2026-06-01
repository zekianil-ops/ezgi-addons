<!---<cf_get_lang_set module_name="report">
<cfset adres="#listgetat(attributes.fuseaction,1,'.')#.list_ezgi_branch_analist">
<cfif isDefined('attributes.keyword') and len(attributes.keyword)>
	<cfset adres = '#adres#&keyword=#attributes.keyword#'>
</cfif>

<cfif isdefined('attributes.is_form_submitted') and len(attributes.is_form_submitted)>
	<cfset adres = adres&"&is_form_submitted=1">
</cfif>--->
<cfset total_ezgi_gelir = 0>
<cfset total_ezgi_gider = 0>
<cfset total_ezgi_sonuc = 0>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.record_emp_id" default="">
<cfparam name="attributes.record_emp_name" default="">
<cfparam name="attributes.month_value" default="">
<cfparam name="attributes.year_value" default="">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.oby" default="1">
<cfparam name="attributes.analyst_status" default="">
<cfif isdefined("attributes.is_form_submitted")>
	<cfinclude template="../query/get_ezgi_branch_analist.cfm">
	<cfset arama_yapilmali = 0>
<cfelse>
	<cfset get_analyst_branch.recordcount = 0>
	<cfset arama_yapilmali = 1>
</cfif>
<cfquery name="get_period" datasource="#dsn#">
	SELECT        
    	TOP (5) PERIOD_YEAR
	FROM            
    	SETUP_PERIOD
	WHERE        
    	OUR_COMPANY_ID = #session.ep.company_id#
	ORDER BY 
    	PERIOD_YEAR DESC
</cfquery>
<cfquery name="get_branch" datasource="#dsn#">
	SELECT BRANCH_ID,BRANCH_NAME FROM BRANCH WHERE COMPANY_ID = #session.ep.company_id# ORDER BY BRANCH_NAME
</cfquery>
<cfoutput query="get_branch">
	<cfset 'BRANCH_NAME_#BRANCH_ID#' = BRANCH_NAME>
</cfoutput>
<cfquery name="get_price_cat" datasource="#dsn3#">
	SELECT PRICE_CATID, BRANCH, PRICE_CAT FROM PRICE_CAT WHERE PRICE_CAT_STATUS = 1 AND IS_SALES = 1
</cfquery>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_analyst_branch.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="branch_analist" action="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_ezgi_branch_analist" method="post">
			<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <cf_box_search>
                <div class="form-group" id="form_ul_year_value">
                	<cfinput type="text" style="width:150px;" placeholder="#getLang(48,'Filtre',57460)#" maxlength="50" name="keyword" value="#attributes.keyword#">
              	</div>
                <div class="form-group" id="form_ul_keyword">
                	<select name="year_value" id="year_value" style="width:65px; height:20px">
                    	<option value="" <cfif attributes.month_value eq ''>selected</cfif>><cf_get_lang_main no='322.Seçiniz'></option>
                     	<cfoutput query="get_period">
                        	<option value="#PERIOD_YEAR#" <cfif attributes.year_value eq PERIOD_YEAR>selected</cfif>>#PERIOD_YEAR#</option>
                     	</cfoutput>
               		</select>
                </div>
                <div class="form-group" id="form_ul_month_value">
                	<select name="month_value" id="month_value" style="width:70px; height:20px">
                     	<option value="" <cfif attributes.month_value eq ''>selected</cfif>><cf_get_lang_main no='322.Seçiniz'></option>
                       	<option value="1" <cfif attributes.month_value eq 1>selected</cfif>><cf_get_lang_main no='180.Ocak'></option>
                       	<option value="2" <cfif attributes.month_value eq 2>selected</cfif>><cf_get_lang_main no='181.Şubat'></option>
                      	<option value="3" <cfif attributes.month_value eq 3>selected</cfif>><cf_get_lang_main no='182.Mart'></option>
                       	<option value="4" <cfif attributes.month_value eq 4>selected</cfif>><cf_get_lang_main no='183.Nisan'></option>
                     	<option value="5" <cfif attributes.month_value eq 5>selected</cfif>><cf_get_lang_main no='184.Mayıs'></option>
                       	<option value="6" <cfif attributes.month_value eq 6>selected</cfif>><cf_get_lang_main no='185.Haziran'></option>
                     	<option value="7" <cfif attributes.month_value eq 7>selected</cfif>><cf_get_lang_main no='186.Temmuz'></option>
                      	<option value="8" <cfif attributes.month_value eq 8>selected</cfif>><cf_get_lang_main no='187.Ağustos'></option>
                       	<option value="9" <cfif attributes.month_value eq 9>selected</cfif>><cf_get_lang_main no='188.Eylül'></option>
                      	<option value="10" <cfif attributes.month_value eq 10>selected</cfif>><cf_get_lang_main no='189.Ekim'></option>
                      	<option value="11" <cfif attributes.month_value eq 11>selected</cfif>><cf_get_lang_main no='190.Kasım'></option>
                     	<option value="12" <cfif attributes.month_value eq 12>selected</cfif>><cf_get_lang_main no='191.Aralık'></option>
                 	</select>
                </div>
                <div class="form-group" id="form_ul_branch_id">
                	<select name="branch_id" id="branch_id" style="width:95px;height:20px">
                    	<option value=""><cf_get_lang_main no='41.Sube'></option>
                      	<cfoutput query="get_branch">
                        	<option value="#branch_id#" <cfif isdefined("attributes.branch_id") and branch_id eq attributes.branch_id>selected</cfif>>#branch_name#</option>
                      	</cfoutput>
                 	</select> 
                </div>
                 <div class="form-group small">
                 	<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Kayıt Sayısı Hatalı!'></cfsavecontent>
                 	<cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,1250" required="yes" message="#message#">
            	</div>
               	<div class="form-group">
                	<cf_wrk_search_button search_function='input_control()' button_type="4">
             	</div>
          	</cf_box_search>
            <cf_box_search_detail> 
             	<div class="col-sm-6 col xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="form_ul_record_emp_id">
                     	<label class="col col-12"><cf_get_lang_main no='487.Kaydeden'></label>
                      	<div class="col col-12">
                         	<div class="input-group">
                            	<input type="hidden" name="record_emp_id" id="record_emp_id" value="<cfif isdefined("attributes.record_emp_id")><cfoutput>#attributes.record_emp_id#</cfoutput></cfif>">
								<input name="record_emp_name" type="text" id="record_emp_name" style="width:175px;" onfocus="AutoComplete_Create('record_emp_name','FULLNAME','FULLNAME','get_emp_pos','','EMPLOYEE_ID','record_emp_id','','3','130');" value="<cfif isdefined("attributes.record_emp_id") and len(attributes.record_emp_id)><cfoutput>#attributes.record_emp_name#</cfoutput></cfif>" maxlength="255" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=branch_analist.record_emp_id&field_name=branch_analist.record_emp_name<cfif fusebox.circuit is "store">&is_store_module=1</cfif>&select_list=1&is_form_submitted=1&keyword='+encodeURIComponent(document.branch_analist.record_emp_name.value),'list','popup_list_positions');"></span>
                            </div>
                      	</div>
              		</div>
              	</div>
          	 </cf_box_search_detail> 
        </cfform>
    </cf_box>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id="799.Şube Aylık Analiz"></cfsavecontent>
    <cf_box title="#message#" uidrop="1" hide_table_column="1" woc_setting = "#{ checkbox_name : 'print_invoice_id', print_type : 10 }#">
    	<cf_grid_list sort="1">
        	<thead>
                <tr>
                    <th style="width:30px;text-align:center; height:20px" class="header_icn_txt"><cf_get_lang_main no='1165.Sira'></th>
                    <th style="width:65px;text-align:center"><cf_get_lang_main no='1043.Yıl'></th>
                    <th style="width:65px;text-align:center"><cf_get_lang_main no='1312.Ay'></th>
                    <th style="width:65px;text-align:center"><cf_get_lang_main no='41.Sube'></th>
                    <th style="width:90px;text-align:center"><cf_get_lang_main no='677.Gelirler'></th>
                    <th style="width:90px;text-align:center"><cfoutput>#getLang('budget',47)#</cfoutput></th>
                    <th style="width:90px;text-align:center"><cfoutput>#getLang('report',832)# / #getLang('report',833)#</cfoutput></th>
                    
                    <th style="width:70px;text-align:center"><cf_get_lang_main no='215.Kayıt Tarihi'></th>
                    <th style="width:170px;text-align:center"><cf_get_lang_main no='487.Kaydeden'></th>
                    <th style="text-align:center"><cf_get_lang_main no='217.Açıklama'></th>
                    <th style="width:15px;text-align:center">&nbsp;</th>
                    <th style="width:25px;text-align:center"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=report.list_ezgi_branch_analist&event=add"><img src="/images/plus_list.gif" title="<cf_get_lang_main no='3200.İşlem Tipi Ekle'>"> </a></th>
                </tr>
            </thead>
            <tbody>
                <cfif get_analyst_branch.recordcount>
                    <cfoutput query="get_analyst_branch" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                        <cfquery name="get_upd" datasource="#dsn3#">
                            SELECT * FROM EZGI_ANALYST_BRANCH WHERE ANALYST_BRANCH_ID = #get_analyst_branch.ANALYST_BRANCH_ID#
                        </cfquery>
                        <cfset attributes.upd_id = get_analyst_branch.ANALYST_BRANCH_ID>
                        <cfinclude template="../query/get_ezgi_branch_gelirler.cfm">
                        <cfinclude template="../query/get_ezgi_branch_giderler.cfm">
                        <cfinclude template="../query/get_ezgi_branch_sonuc.cfm">
                        
                        <cfif len(get_TOTAL.SMM)>
                            <cfset total_smm = get_TOTAL.SMM>
                        <cfelse>
                            <cfset total_smm = 0>
                        </cfif>
                        <cfif len(GET_TOTAL_EXPENSE.GIDER)>
                            <cfset expense_gider = GET_TOTAL_EXPENSE.GIDER>
                        <cfelse>
                            <cfset expense_gider = 0>
                        </cfif>
                        <cfif len(GET_TOTAL.TOTAL_SALES)>
                            <cfset net_total = GET_TOTAL.TOTAL_SALES>
                        <cfelse>
                            <cfset net_total = 0>
                        </cfif>
                        <tr>
                            <td style="text-align:right">#currentrow#&nbsp;</td>
                            <td style="text-align:center">
                                <a href="#request.self#?fuseaction=report.list_ezgi_branch_analist&event=upd&upd_id=#ANALYST_BRANCH_ID#" class="tableyazi">
                                    #YEAR_VALUE#
                                </a>
                            </td>
                            <td style="text-align:center">
                                <a href="#request.self#?fuseaction=report.list_ezgi_branch_analist&event=upd&upd_id=#ANALYST_BRANCH_ID#" class="tableyazi">
                                    #MONTH_VALUE#
                                </a>
                            </td>
                            <td style="text-align:center">
                                <a href="#request.self#?fuseaction=report.list_ezgi_branch_analist&event=upd&upd_id=#ANALYST_BRANCH_ID#" class="tableyazi">
                                    <cfif IS_BRANCH eq 1>
                                        #Evaluate('BRANCH_NAME_#BRANCH_ID#')#
                                    <cfelse>
                                        <strong>
                                        #Evaluate('BRANCH_NAME_#BRANCH_ID#')#
                                        </strong>
                                    </cfif>
                                </a>
                            </td>
                            <td style="text-align:right">#TlFormat(net_total-total_smm,2)#</td>
                            <td style="text-align:right">#TlFormat(expense_gider,2)#</td>
                            <td style="text-align:right;background-color:<cfif net_total-total_smm-expense_gider gt 0>PaleTurquoise<cfelseif net_total-total_smm-expense_gider lt 0>Bisque</cfif>">
                                    #TlFormat(net_total-total_smm-expense_gider,2)#
                            </td>
                            <td style="text-align:center">#dateformat(get_analyst_branch.DATE,'dd/mm/yyyy')#</td>
                            <td>#get_emp_info(employee_id,0,0)#</td>
                            <td>#DETAIL#</td>
                            <td style="text-align:center;">
                                <cfif STATUS eq 0>
                                     <img src="/images/lock_open.gif" title="<cf_get_lang_main no='2068.Tamamlanmadı'>">
                                <cfelse>
                                     <img src="/images/lock_buton.gif" title="<cf_get_lang_main no='1374.Tamamlandı'>">
                                </cfif>       
                            </td>
                            
                            <td align="center"><a href="#request.self#?fuseaction=report.list_ezgi_branch_analist&event=upd&upd_id=#ANALYST_BRANCH_ID#" class="tableyazi"> <img src="/images/update_list.gif" title="<cf_get_lang_main no='52.Düzenle'>" border="0"></a>
                            </td>
                        </tr>
                        <cfset total_ezgi_gelir = total_ezgi_gelir + (net_total-total_smm)>
                        <cfset total_ezgi_gider = total_ezgi_gider + (expense_gider)>
                    </cfoutput>
                    <cfoutput>
                        <tr class="color-row" height="20">
                            <td colspan="4" align="right" class="txtbold" style="text-align:right;"><cf_get_lang_main no='80.Toplam'></td>
                            <td style="text-align:right"><strong>#TlFormat(total_ezgi_gelir,2)#</strong></td>
                            <td style="text-align:right"><strong>#TlFormat(total_ezgi_gider,2)#</strong></td>
                            <td style="text-align:right"><strong>#TlFormat(total_ezgi_gelir-total_ezgi_gider,2)#</strong></td>
                            <td colspan="5">&nbsp;</td>
                        </tr>
                    </cfoutput>
                <cfelse>
                    <tr height="20" class="color-row">
                        <td colspan="14"><cfif arama_yapilmali eq 1><cf_get_lang_main no='289.Filtre Ediniz'><cfelse><cf_get_lang_main no='72.Kayıt Yok'></cfif>!</td>
                    </tr>
                </cfif>
            </tbody>
      	</cf_grid_list>
        <cfset adres = url.fuseaction>
        <cfif len(attributes.keyword)>
        	<cfset adres = '#adres#&keyword=#URLEncodedFormat(attributes.keyword)#'>
       	</cfif>
       	<cfif len(attributes.month_value)>
         	<cfset adres = '#adres#&month_value=#attributes.month_value#'>
      	</cfif>
        <cfif len(attributes.year_value)>
         	<cfset adres = '#adres#&year_value=#attributes.year_value#'>
      	</cfif>
        <cfif len(attributes.branch_id)>
         	<cfset adres = '#adres#&branch_id=#attributes.branch_id#'>
      	</cfif>
      	<cfif len(attributes.record_emp_name)>
          	<cfset adres = '#adres#&record_emp_name=#attributes.record_emp_name#'>
           	<cfset adres = '#adres#&record_emp_id=#attributes.record_emp_id#'>
     	</cfif>
     	<cf_paging 
                page="#attributes.page#"
                maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                startrow="#attributes.startrow#"
                adres="#adres#&is_form_submitted=1">
  	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{return true;}
</script>
