<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.connect_stage" default="">
<cfparam name="attributes.resource_id" default="">
<cfparam name="attributes.sort_type" default="3">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.member_cat_type" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.project_head" default="">
<cfparam name="attributes.employee_id" default="">
<cfparam name="attributes.member_name" default="">
<cfparam name="attributes.member_type" default="">
<cfparam name="attributes.record_emp_id" default="#session.ep.userid#">
<cfparam name="attributes.record_emp_name" default="#get_emp_info(session.ep.userid,0,0)#">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<CFSET t_net_total1 = 0>
<cfif isdefined('attributes.start_date') and isdate(attributes.start_date)>
	<cf_date tarih='attributes.start_date'>
</cfif>	
<cfif isdefined('attributes.finish_date') and isdate(attributes.finish_date)>
	<cf_date tarih='attributes.finish_date'>
</cfif>
<cfif isdefined('attributes.deliver_start_date') and isdate(attributes.deliver_start_date)>
	<cf_date tarih='attributes.deliver_start_date'>
</cfif>	
<cfif isdefined('attributes.deliver_finish_date') and isdate(attributes.deliver_finish_date)>
	<cf_date tarih='attributes.deliver_finish_date'>
</cfif>
<cfparam name="attributes.page" default=1>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfscript>
	get_ezgi_connects.recordcount=0;
	get_ezgi_connects.query_count=0;
	if (isdefined("attributes.is_form_submitted"))
	{
		get_ezgi_connect_list_action = createObject("component", "addOns.ezgi.cfc.get_ezgi_connects");
		get_ezgi_connect_list_action.dsn3 = dsn3;
		get_ezgi_connects = get_ezgi_connect_list_action.get_ezgi_connects_
		(
		 	dsn_alias : '#dsn_alias#',
		 	keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
			connect_stage : '#IIf(IsDefined("attributes.connect_stage"),"attributes.connect_stage",DE(""))#',
			resource_id : '#IIf(IsDefined("attributes.resource_id"),"attributes.resource_id",DE(""))#',
			sort_type : '#IIf(IsDefined("attributes.sort_type"),"attributes.sort_type",DE(""))#',
			branch_id : '#IIf(IsDefined("attributes.branch_id"),"attributes.branch_id",DE(""))#',
			project_id : '#IIf(IsDefined("attributes.project_id"),"attributes.project_id",DE(""))#',
			project_head : '#IIf(IsDefined("attributes.project_head"),"attributes.project_head",DE(""))#',
			member_cat_type : '#IIf(IsDefined("attributes.member_cat_type"),"attributes.member_cat_type",DE(""))#',
			consumer_id : '#IIf(IsDefined("attributes.consumer_id"),"attributes.consumer_id",DE(""))#',
			company_id : '#IIf(IsDefined("attributes.company_id"),"attributes.company_id",DE(""))#',
			employee_id : '#IIf(IsDefined("attributes.employee_id"),"attributes.employee_id",DE(""))#',
			member_name : '#IIf(IsDefined("attributes.member_name"),"attributes.member_name",DE(""))#',
			member_type : '#IIf(IsDefined("attributes.member_type"),"attributes.member_type",DE(""))#',
			record_emp_id : '#IIf(IsDefined("attributes.record_emp_id"),"attributes.record_emp_id",DE(""))#',
			record_emp_name : '#IIf(IsDefined("attributes.record_emp_name"),"attributes.record_emp_name",DE(""))#',
			start_date : '#IIf(IsDefined("attributes.start_date"),"attributes.start_date",DE(""))#',
			finish_date : '#IIf(IsDefined("attributes.finish_date"),"attributes.finish_date",DE(""))#',
		 	startrow : '#iif(isdefined("attributes.startrow"),"attributes.startrow",DE(""))#',
			maxrows : '#iif(isdefined("attributes.maxrows"),"attributes.maxrows",DE(""))#'
		);
		arama_yapilmali=0;
		}
	else
	{
		arama_yapilmali=1;
	}
</cfscript>
<cfparam name="attributes.totalrecords" default='#get_ezgi_connects.query_count#'>
<cfquery name="GET_COMPANY_CAT" datasource="#DSN#">
	SELECT COMPANYCAT_ID,COMPANYCAT FROM COMPANY_CAT ORDER BY COMPANYCAT
</cfquery>
<cfquery name="GET_CONSUMER_CAT" datasource="#DSN#">
	SELECT CONSCAT_ID,CONSCAT FROM CONSUMER_CAT ORDER BY HIERARCHY
</cfquery>
<cfquery name="get_branch" datasource="#dsn#">
	SELECT        
    	BRANCH_ID, BRANCH_NAME
	FROM            
    	BRANCH
	WHERE        
    	BRANCH_ID IN
                  	(
                    	SELECT        
                        	BRANCH_ID
                    	FROM            
                        	EMPLOYEE_POSITION_BRANCHES
                    	WHERE        
                        	POSITION_CODE = #session.ep.POSITION_CODE# AND 
                            DEPARTMENT_ID IS NULL
                   	)
      	AND COMPANY_ID = #session.ep.company_id# 
        AND BRANCH_STATUS = 1
</cfquery>
<cfoutput query="get_branch">
	<cfset 'BRANCH_NAME_#BRANCH_ID#' = BRANCH_NAME>
</cfoutput>
<cfquery name="GET_PROCESS_TYPE" datasource="#DSN#">
	SELECT
		PTR.STAGE,
		PTR.PROCESS_ROW_ID
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%ezgi_connect%">
	ORDER BY
		PTR.LINE_NUMBER
</cfquery>
<cfoutput query="GET_PROCESS_TYPE">
	<cfset 'STAGE_#PROCESS_ROW_ID#' = STAGE>
</cfoutput>
<cfquery name="get_resource" datasource="#dsn#">
	SELECT RESOURCE_ID, RESOURCE FROM COMPANY_PARTNER_RESOURCE ORDER BY RESOURCE
</cfquery>
<cfoutput query="get_resource">
	<cfset 'RESOURCE_#RESOURCE_ID#' = RESOURCE>
</cfoutput>
<cfif isdefined('attributes.is_form_submitted')>
	<cfset connect_id_list = ValueList(get_ezgi_connects.connect_id)>
    <cfif ListLen(connect_id_list)>
        <cfquery name="get_relations" datasource="#dsn3#">
            SELECT 
                ECR.CONNECT_ID,
                OFR.OFFER_ID
            FROM     
                EZGI_CONNECT_ROW AS ECR INNER JOIN
                OFFER_ROW AS OFR ON ECR.WRK_ROW_RELATION_ID = OFR.WRK_ROW_ID
            WHERE  
                ECR.CONNECT_ID IN (#connect_id_list#)
        </cfquery>
        <cfoutput query="get_relations">
            <cfset 'CONNECT_#CONNECT_ID#' = 1>
            <cfset 'RELATION_#CONNECT_ID#' = OFFER_ID>
        </cfoutput>
        <cfquery name="get_relations" datasource="#dsn#">
        	SELECT        
            	FROM_CONNECT_ID as CONNECT_ID,
                0 AS OFFER_ID
			FROM            
            	ORDER_RELATION_COMPANY
			WHERE        
            	FROM_CONNECT_ID IN (#connect_id_list#) AND
                FROM_COMPANY_ID = #session.ep.company_id#
        </cfquery>
        <cfoutput query="get_relations">
            <cfset 'CONNECT_#CONNECT_ID#' = 2>
            <cfset 'RELATION_#CONNECT_ID#' = OFFER_ID>
        </cfoutput>
    </cfif>
</cfif>
<cfparam name="attributes.totalrecords" default='#get_ezgi_connects.query_count#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search" method="post" action="#request.self#?fuseaction=sales.list_ezgi_connect">
			<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <cf_box_search>
                <div class="form-group" id="form_ul_keyword">
                	<cfinput type="text" style="width:150px;" placeholder="#getLang(48,'Filtre',57460)#" maxlength="50" name="keyword" value="#attributes.keyword#">
              	</div>
				<div class="form-group medium" id="form_ul_branch_id">
                	<select name="branch_id" id="branch_id" style="width:120px; height:20px">
                    	<option value=""><cf_get_lang_main no='296.Tümü'></option>
                  		<cfoutput query="get_branch">
                        	<option value="#get_branch.branch_id#" <cfif attributes.branch_id eq get_branch.branch_id>selected</cfif>>#get_branch.branch_name#</option>
                      	</cfoutput>
                	</select>
                </div>
              	<div class="form-group medium" id="form_ul_stage">
                	<select name="connect_stage" id="connect_stage">
						<option value=""><cf_get_lang_main no='1447.Süreç'></option>
						<cfoutput query="get_process_type">
							<option value="#process_row_id#"<cfif Listfind(attributes.connect_stage, process_row_id)>selected</cfif>>#stage#</option>
						</cfoutput>
					</select>
              	</div>
                <div class="form-group medium" id="form_ul_resource">
                	<select name="resource_id" id="resource_id" class="styled-select">
                     	<option value=""><cf_get_lang dictionary_id='51676.İlişki Tipi'></option>
                      	<cfoutput query="get_resource">
                        	<option value="#get_resource.RESOURCE_ID#" <cfif attributes.resource_id eq get_resource.RESOURCE_ID>selected</cfif>>#get_resource.RESOURCE#</option>
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
                <div class="form-group">
					<a  class="ui-btn ui-btn-gray2" href="javascript://" onclick="add_ezgi_ssh()">
                    	<i class="fa fa-legal" title="<cf_get_lang dictionary_id='709.SSH'>"></i>
                  	</a>
                </div>
          	</cf_box_search>
          	<cf_box_search_detail> 
             	<div class="col-sm-3 col xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="form_ul_record_emp_id">
                     	<label class="col col-12"><cf_get_lang dictionary_id="56987.Satış yapan"></label>
                      	<div class="col col-12">
                         	<div class="input-group">
                            	<input type="hidden" name="record_emp_id" id="record_emp_id" value="<cfif isdefined("attributes.record_emp_id")><cfoutput>#attributes.record_emp_id#</cfoutput></cfif>">
								<input name="record_emp_name" type="text" id="record_emp_name" style="width:175px;" onfocus="AutoComplete_Create('record_emp_name','FULLNAME','FULLNAME','get_emp_pos','','EMPLOYEE_ID','record_emp_id','','3','130');" value="<cfif isdefined("attributes.record_emp_id") and len(attributes.record_emp_id)><cfoutput>#attributes.record_emp_name#</cfoutput></cfif>" maxlength="255" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=search.record_emp_id&field_name=search.record_emp_name<cfif fusebox.circuit is "store">&is_store_module=1</cfif>&select_list=1&is_form_submitted=1&keyword='+encodeURIComponent(document.search.record_emp_name.value),'list','popup_list_positions');"></span>
                            </div>
                      	</div>
              		</div>
                    <div class="form-group" id="form_ul_member_name">
                     	<label class="col col-12"><cf_get_lang_main no='107.Cari Hesap'></label>
                      	<div class="col col-12">
                         	<div class="input-group">
                            	<input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#attributes.consumer_id#</cfoutput>">
                   				<input type="hidden" name="company_id"  id="company_id" value="<cfoutput>#attributes.company_id#</cfoutput>">
                       			<input type="hidden" name="member_type" id="member_type" value="<cfoutput>#attributes.member_type#</cfoutput>">
                      			<input type="text"   name="member_name" id="member_name" style="width:175px;"  value="<cfoutput>#attributes.member_name#</cfoutput>" onFocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2\'','COMPANY_ID,CONSUMER_ID,MEMBER_TYPE','company_id,consumer_id,member_type','','3','250');" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&field_consumer=search.consumer_id&field_comp_id=search.company_id&field_member_name=search.member_name&field_type=search.member_type&select_list=7,8&keyword='+encodeURIComponent(document.search.member_name.value),'list');"></span>
                            </div>
                      	</div>
              		</div>
               	</div>
                <div class="col-sm-3 col xs-12" type="column" index="2" sort="true">
                	<div class="form-group" id="form_ul_start_date">
                        <label class="col col-12"><cf_get_lang dictionary_id='38420.Teklif Tarihi'></label>
                        <div class="col col-12">
                            <div class="col col-6 pl-0">
                                <div class="input-group">
                                    <cfinput type="text" name="start_date" value="#dateformat(attributes.start_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                                </div>
                            </div>
                            <div class="col col-6 pr-0">  
                                <div class="input-group">
                                    <cfinput type="text" name="finish_date" value="#dateformat(attributes.finish_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                                </div>
                            </div>
                        </div>    
                  	</div>
                    <div class="form-group" id="form_ul_durum_siparis">
                        <label class="col col-12"><cf_get_lang dictionary_id='58924.Sıralama'></label>
                        <div class="col col-12">
                        	<select name="sort_type" id="sort_type" style="width:175px; height:20px">
                                <option value="2" <cfif attributes.sort_type eq 2>selected</cfif>><cf_get_lang dictionary_id='40928.Teklif Noya Göre Artan'></option>
                                <option value="3" <cfif attributes.sort_type eq 3>selected</cfif>><cf_get_lang dictionary_id='40929.Teklif Noya Göre Azalan'></option>
                                <option value="4" <cfif attributes.sort_type eq 4>selected</cfif>><cf_get_lang dictionary_id='40909.Teklif Tarihine Göre Artan'></option>
                                <option value="5" <cfif attributes.sort_type eq 5>selected</cfif>><cf_get_lang dictionary_id='40911.Teklif Tarihine Göre Azalan'></option>
                            </select>
                        </div>
                  	</div>
             	</div>
                <div class="col-sm-3 col xs-12" type="column" index="3" sort="true">
                	<div class="form-group" id="item-project_head">
                        <label class="col col-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                        <div class="col col-12">
                            <div class="input-group">
                            	<cfoutput>
                                <input type="hidden" name="project_id" id="project_id" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id) and len(attributes.project_head)>#attributes.project_id#</cfif>"> 
                                <input type="text" name="project_head" id="project_head" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id) and len(attributes.project_head)>#get_project_name(attributes.project_id)#</cfif>" style="width:200px; height:20px" onFocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','form_basket','3','200')"autocomplete="off">
                                </cfoutput>
                                <span class="input-group-addon icon-ellipsis btnPointer" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=form_basket.project_head&project_id=form_basket.project_id</cfoutput>');" title="<cf_get_lang no='45.Proje Seçiniz'>"></span>
                            </div>
                        </div>
                  	</div>
            	</div>
          	 </cf_box_search_detail> 
        </cfform>
    </cf_box>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id="30815.Satışlar"></cfsavecontent>
    <cf_box title="#message#" uidrop="1" hide_table_column="1" woc_setting = "#{ checkbox_name : 'print_invoice_id', print_type : 10 }#">
    	<cf_grid_list sort="1">
        	<thead>
             	<tr>
                	<th style="width:30px"><cf_get_lang dictionary_id='55657.Sıra No'></th>
                    <th width="100"><cf_get_lang dictionary_id='39653.Satış No'></th>
                    <th width="100"><cf_get_lang dictionary_id='33498.Satış Tarihi'></th>
                    <th><cf_get_lang dictionary_id='57457.Müşteri'></th>
                    <th><cf_get_lang dictionary_id='58820.Başlık'></th>
                    <th><cf_get_lang dictionary_id='57416.Proje'></th>
                    <th style="width:150px"><cf_get_lang dictionary_id='57756.Durum'></th>
                    <th style="width:100px"><cf_get_lang dictionary_id="56987.Satış yapan"></th>
                    <th style="width:100px"><cf_get_lang dictionary_id='51676.İlişki Tipi'></th>
                    <th style="width:100px"><cf_get_lang dictionary_id='58859.Surec'></th>
                    <th width="100"><cf_get_lang dictionary_id='57673.Tutar'><br />(<cf_get_lang dictionary_id='58121.İşlem Dövizi'>)</th>
                    <th width="40"><cf_get_lang dictionary_id='57677.Döviz'></th>
                 	<th width="100"><cf_get_lang dictionary_id='57673.Tutar'><br />(<cf_get_lang dictionary_id='58905.Sistem Dövizi'>)</th>
                    <!-- sil -->
                    <th width="20" class="header_icn_none">
                  		<a href="<cfoutput>#request.self#?fuseaction=sales.list_ezgi_connect&event=add</cfoutput>"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
            		</th>
                	<!-- sil -->
              	 </tr>
        	</thead>
        	<tbody>
            	<cfif get_ezgi_connects.recordcount>
                	<cfoutput query="get_ezgi_connects">
						<cfif len(RECORD_PAR)>
                            <cfquery name="get_par_name" datasource="#dsn#">
                                SELECT COMPANY_PARTNER_NAME, COMPANY_PARTNER_SURNAME FROM COMPANY_PARTNER WHERE PARTNER_ID = #RECORD_PAR#
                            </cfquery>
                        </cfif>
                       	<tr oncontextmenu="javascript:wrk_right_menu('CONNECT_ID',#CONNECT_ID#);return false;"> 
                        	<td>#rownum#</td>
                            <td style="text-align:left;"><a href="#request.self#?fuseaction=sales.list_ezgi_connect&event=upd&connect_id=#get_ezgi_connects.connect_id#" class="tableyazi">#CONNECT_NUMBER#</a></td>
                        	<td style="text-align:center;">#DateFormat(CONNECT_DATE,dateformat_style)#</td>
                        	<td style="text-align:LEFT;">
								<cfif len(get_ezgi_connects.COMPANY_ID)>
                                    #get_par_info(get_ezgi_connects.COMPANY_ID,1,1,0)#
                                <cfelseif len(get_ezgi_connects.CONSUMER_ID)>
                                    #get_cons_info(get_ezgi_connects.CONSUMER_ID,0,0)#
                              	<cfelseif len(get_ezgi_connects.EMPLOYEE_ID)>
                                	#get_emp_info(get_ezgi_connects.EMPLOYEE_ID,0,0)#
                                </cfif>
                            </td>
                            <td title="#CONNECT_HEAD#">#Left(CONNECT_HEAD,40)#<cfif len(CONNECT_HEAD) gt 40>...</cfif></td>
                            <td><cfif len(get_ezgi_connects.project_id)>#get_project_name(get_ezgi_connects.project_id)#</cfif></td>
                            <td >
								<cfif isdefined('CONNECT_#CONNECT_ID#')>
                                	<cfif Evaluate('CONNECT_#CONNECT_ID#') eq 1>
                                    	<cfif isdefined('RELATION_#CONNECT_ID#')>
                                        	<cfset offer_id = Evaluate('RELATION_#CONNECT_ID#')>
                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.list_offer&event=upd&offer_id=#offer_id#','longpage');">
                                            	<span style="color:red"><cf_get_lang dictionary_id='51074.Teklife Dönüştürülenler'></span>
                                            </a>
                                        <cfelse>
                                        	<span style="color:red"><cf_get_lang dictionary_id='51074.Teklife Dönüştürülenler'></span>
                                        </cfif>
                                    <cfelseif Evaluate('CONNECT_#CONNECT_ID#') eq 2>
                                   		<span style="color:blue"><cf_get_lang dictionary_id='51060.Siparişe Dönüştürülenler'></span>
                                    </cfif>
                              	</cfif>
                           	</td>
                            <td>#get_emp_info(CONNECT_EMPLOYEE_ID,0,0)#</td>
                            <td><cfif isdefined('RESOURCE_#RESOURCE_ID#')>#Evaluate('RESOURCE_#RESOURCE_ID#')#</cfif></td>
                            <td><cfif isdefined('STAGE_#CONNECT_STAGE#')>#Evaluate('STAGE_#CONNECT_STAGE#')#</cfif></td>
                        	<td style="text-align:right;">#AmountFormat(OTHER_MONEY_VALUE)#</td>
                            <td style="text-align:left;">#other_money#</td>
                          	<td style="text-align:right; font-weight:bold">#AmountFormat(NETTOTAL,2)#</td>
                          	<CFSET t_net_total1 = t_net_total1 + NETTOTAL>
                            <!-- sil -->
                                <td>
                                    <a href="#request.self#?fuseaction=sales.list_ezgi_connect&event=upd&connect_id=#get_ezgi_connects.connect_id#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                                </td>
                         	<!-- sil -->
                      	</tr>
                	</cfoutput>
                	<tr>
                   		<td colspan="12" style="height:20px"><strong><cf_get_lang dictionary_id='55447.Sayfa Toplam'></strong></td>
                      	<td style="text-align:right;"><strong><cfoutput>#AmountFormat(t_net_total1,2)#</cfoutput></strong></td>
                     	<TD ></TD>
                 	</tr>
                <cfelse>
                    <tr> 
                        <td colspan="13" height="20"><cfif arama_yapilmali eq 1><cf_get_lang_main no='289.Filtre Ediniz'> !<cfelse><cf_get_lang_main no='72.Kayıt Yok'>!</cfif></td>
                    </tr>
                </cfif>
            </tbody>
      	</cf_grid_list>
        <cfset adres = url.fuseaction>
		<cfif isdefined("attributes.is_form_submitted") and attributes.totalrecords gt attributes.maxrows>
            <cfif len(attributes.member_name)>
              <cfset adres = '#adres#&company_id=#attributes.company_id#'>
              <cfset adres = '#adres#&member_name=#attributes.member_name#'>
            </cfif>		
            <cfif len(attributes.keyword)>
              <cfset adres = '#adres#&keyword=#URLEncodedFormat(attributes.keyword)#'>
            </cfif>
            <cfif len(attributes.sort_type)>
                <cfset adres = '#adres#&sort_type=#attributes.sort_type#'>
            </cfif>
            <cfif len(attributes.connect_stage)>
                <cfset adres = '#adres#&connect_stage=#attributes.connect_stage#'>
            </cfif>
            <cfif len(attributes.resource_id)>
                <cfset adres = '#adres#&resource_id=#attributes.resource_id#'>
            </cfif>
            <cfif len(attributes.record_emp_name)>
                <cfset adres = '#adres#&record_emp_name=#attributes.record_emp_name#'>
                <cfset adres = '#adres#&record_emp_id=#attributes.record_emp_id#'>
            </cfif>
            <cfif isdate(attributes.start_date)>
                <cfset adres = adres & "&start_date=#dateformat(attributes.start_date,dateformat_style)#">
            </cfif>
            <cfif isdate(attributes.finish_date)>
                <cfset adres = adres & "&finish_date=#dateformat(attributes.finish_date,'dd/mm/yyyy')#">
            </cfif>
            <cfif len(attributes.branch_id)>
                <cfset adres = '#adres#&branch_id=#attributes.branch_id#'>
            </cfif>
            <cfif len(attributes.project_id) and len(attributes.project_head)>
                <cfset adres = '#adres#&project_id=#attributes.project_id#&project_head=#attributes.project_head#'>
            </cfif>
            <cf_paging 
                page="#attributes.page#"
                maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                startrow="#attributes.startrow#"
                adres="#adres#&is_form_submitted=1">
        </cfif>
  	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;
	}
	function add_ezgi_ssh()
	{
		window.location ="<cfoutput>#request.self#?fuseaction=sales.list_ezgi_connect&event=add&ssh=1</cfoutput>";
	}
</script>