<!---
    File: list_ezgi_iflow_master_plan.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.record_emp_id" default="">
<cfparam name="attributes.record_emp_name" default="">
<cfparam name="attributes.record_date1" default="">
<cfparam name="attributes.record_date2" default="">
<cfparam name="attributes.oby" default="1">
<cfparam name="attributes.process_stage" default="">
<cfparam name="attributes.master_plan_status" default="1">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.shift_id" default="">
<cfparam name="attributes.page" default=1>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfif isdefined("attributes.date1") and isdate(attributes.date1)>
	<cf_date tarih = "attributes.date1">
<cfelse>	
	<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
		<cfset attributes.date1 = ''>
	<cfelse>
		<cfset attributes.date1 = session.ep.period_start_date>
	</cfif>
</cfif>

<cfif isdefined("attributes.date2") and isdate(attributes.date2)>
	<cf_date tarih = "attributes.date2">
<cfelse>	
	<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
		<cfset attributes.date2 = ''>
	<cfelse>
		<cfset attributes.date2 = session.ep.period_finish_date>
	</cfif>
</cfif>
<cfset type = "">
<cfset genel_bakiye = 0>
<cfscript>
	get_ezgi_iflow_master_plan.recordcount=0;
	get_ezgi_iflow_master_plan.query_count=0;
	if (isdefined("attributes.is_submitted"))
	{
		get_ezgi_iflow_master_plan_action = createObject("component", "addOns.ezgi.cfc.get_ezgi_iflow_master_plan");
		get_ezgi_iflow_master_plan_action.dsn = dsn;
		get_ezgi_iflow_master_plan_action.dsn3 = dsn3;
		get_ezgi_iflow_master_plan = get_ezgi_iflow_master_plan_action.get_ezgi_iflow_master_plan_
		(
		 	keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
			record_emp_id : '#IIf(IsDefined("attributes.record_emp_id"),"attributes.record_emp_id",DE(""))#',
			record_emp_name : '#iif(isdefined("attributes.record_emp_name"),"attributes.record_emp_name",DE(""))#',
			record_date1 : '#iif(isdefined("attributes.record_date1"),"attributes.record_date1",DE(""))#',
			record_date2 : '#iif(isdefined("attributes.record_date2"),"attributes.record_date2",DE(""))#',
			date1 : '#iif(isdefined("attributes.date1"),"attributes.date1",DE(""))#',
			date2 : '#iif(isdefined("attributes.date2"),"attributes.date2",DE(""))#',
		 	oby : '#iif(isdefined("attributes.oby"),"attributes.oby",DE(""))#',
			master_plan_status : '#IIf(IsDefined("attributes.master_plan_status"),"attributes.master_plan_status",DE(""))#',
			process_stage : '#iif(isdefined("attributes.process_stage"),"attributes.process_stage",DE(""))#',
			shift_id : '#IIf(IsDefined("attributes.shift_id"),"attributes.shift_id",DE(""))#',
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
<cfif isdefined("attributes.is_submitted")>
	<cfif get_ezgi_iflow_master_plan.recordcount>
    	<cfset master_plan_list = ValueList(get_ezgi_iflow_master_plan.MASTER_PLAN_ID)>
        <cfquery name="get_master_ids" datasource="#dsn3#">
            SELECT        
                EM.MASTER_PLAN_ID, PO.P_ORDER_ID
            FROM            
            	EZGI_IFLOW_MASTER_PLAN AS EM INNER JOIN
              	EZGI_IFLOW_PRODUCTION_ORDERS AS EI ON EM.MASTER_PLAN_ID = EI.MASTER_PLAN_ID INNER JOIN
            	PRODUCTION_ORDERS AS PO ON EI.LOT_NO = PO.LOT_NO
            WHERE        
                EM.MASTER_PLAN_ID IN (#master_plan_list#)
		</cfquery>
        <cfoutput query="get_master_ids">
        	<cfif isdefined('MASTER_PLAN_#MASTER_PLAN_ID#')>
            	<cfset 'MASTER_PLAN_#MASTER_PLAN_ID#' = ListAppend(Evaluate('MASTER_PLAN_#MASTER_PLAN_ID#'),P_ORDER_ID)>
            <cfelse>
            	<cfset 'MASTER_PLAN_#MASTER_PLAN_ID#' = P_ORDER_ID>
            </cfif>
        </cfoutput>
  	</cfif>
</cfif>

<cfquery name="get_shift" datasource="#dsn#">
	SELECT        
    	SHIFT_ID, 
        SHIFT_NAME, 
        BRANCH_ID
	FROM            
    	SETUP_SHIFTS
	WHERE        
    	IS_PRODUCTION = 1 AND 
        BRANCH_ID IN
        			(
                    	SELECT 
    						BRANCH_ID
                        FROM 
                            BRANCH 
                        WHERE
                            COMPANY_ID = #session.ep.COMPANY_ID# AND	
                            BRANCH_ID IN (SELECT BRANCH_ID FROM EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">)
                    )
</cfquery>
<cfquery name="GET_PROCESS_TYPE" datasource="#DSN#">
	SELECT
		PTR.STAGE,
		PTR.PROCESS_ROW_ID 
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%master_plan%">
</cfquery>
<cfparam name="attributes.totalrecords" default='#get_ezgi_iflow_master_plan.query_count#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
			<input name="is_submitted" id="is_submitted" type="hidden" value="1">
            <cf_box_search>
                <div class="form-group"  id="item-keyword">
                    <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group medium" id="item-oby">
                	<select name="oby" style="width:120px; height:20px">
                     	<option value="1" <cfif attributes.oby eq 1>selected</cfif>><cf_get_lang dictionary_id='57926.Azalan Tarih'></option>
                      	<option value="2" <cfif attributes.oby eq 2>selected</cfif>><cf_get_lang dictionary_id='57925.Artan Tarih'></option>
                  	</select>
               	</div>
                <div class="form-group medium" id="item-shift_id">
                	<select name="shift_id" style="width:150px; height:20px">
						<cfoutput query="get_shift">
							<option value="#SHIFT_ID#"<cfif isdefined('attributes.shift_id') and attributes.shift_id eq SHIFT_ID>selected</cfif>>#SHIFT_NAME#</option>
						</cfoutput>
					</select>
               	</div>
                <div class="form-group medium" id="item-master_plan_status">
                	<select name="master_plan_status" style="width:80px; height:20px">
                    	<option value=""><cf_get_lang dictionary_id='57708 .Tümü'></option>
                      	<option value="1"<cfif isDefined("attributes.master_plan_status") and (attributes.master_plan_status eq 1)> selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                      	<option value="0"<cfif isDefined("attributes.master_plan_status") and (attributes.master_plan_status eq 0)> selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                  	</select>
               	</div>
                <div class="form-group medium" id="item-process_stage">
                	<select name="prod_order_stage" style="width:125px; height:20px">
						<option value=""><cf_get_lang dictionary_id='58859.Süreç'></option>
						<cfoutput query="get_process_type">
							<option value="#process_row_id#"<cfif isdefined('attributes.process_stage') and attributes.process_stage eq process_row_id>selected</cfif>>#stage#</option>
						</cfoutput>
					</select>
               	</div>
                <div class="form-group" id="item-start_date">
					<div class="input-group x-14">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></cfsavecontent>
						<cfinput type="text" name="date1" placeholder="#message#" value="#dateformat(attributes.date1, dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10">
						<span class="input-group-addon"><cf_wrk_date_image date_field="date1"></span>
					</div>
				</div>		
				<div class="form-group" id="item-finish_date">
					<div class="input-group x-14">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></cfsavecontent>
						<cfinput type="text" name="date2" placeholder="#message#" value="#dateformat(attributes.date2, dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10">
						<span class="input-group-addon"><cf_wrk_date_image date_field="date2"></span>
					</div>
				</div>	
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>
          		<div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
			</cf_box_search>
           	<cf_box_search_detail>
                <div id="detail_search_div" class="col col-12" style="display:table-row;">
                	<div class="col col-3">
                    	<div class="col col-10">
                       		<div class="form-group medium">
                        		<div class="input-group">
                                        <input type="hidden" name="record_emp_id" id="record_emp_id" value="<cfif len(attributes.record_emp_id)><cfoutput>#attributes.record_emp_id#</cfoutput></cfif>">
                                        <input name="record_emp_name" type="text" id="record_emp_name" style="width:120px;" placeholder="<cf_get_lang dictionary_id='57899.Kaydeden'>" onFocus="AutoComplete_Create('record_emp_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','record_emp_id','search','3','125');" value="<cfif len(attributes.record_emp_name)><cfoutput>#attributes.record_emp_name#</cfoutput> </cfif>" autocomplete="off">
                                        <span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_name=search.record_emp_name&field_emp_id=search.record_emp_id<cfif fusebox.circuit is "store">&is_store_module=1</cfif>&select_list=1,9','list');return false"></span>
                                </div>
                            </div>
                       	</div>
                   	</div>
                  	<div class="col col-3">
                    	<div class="col col-12">	
                        	<div class="form-group medium">
                            	<div class="col col-2">
                                	<label><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></label>
                                </div>
                                <div class="col col-4">
                                    <div class="input-group">
                                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                                        <cfinput type="text" maxlength="10" name="record_date1" value="#dateformat(attributes.record_date1,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="record_date1"></span>
                                    </div>
                               </div>
                               <div class="col col-4"> 
                                    <div class="input-group">
                                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                                        <cfinput type="text" maxlength="10" name="record_date2" value="#dateformat(attributes.record_date2,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="record_date2"></span>
                                    </div>
                             	</div>  
                          	</div>
                       	</div>
                  	</div>
             	</div>
        	</cf_box_search_detail> 
     	</cfform>
		<cfsavecontent variable="right">
		    <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_list_ezgi_iflow_production_order','longpage');"><img src="/images/cizelge_emp.gif" title="<cf_get_lang dictionary_id='464.Üretim Emirleri Toplu Liste'>"></a>&nbsp;&nbsp;&nbsp;
           		<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_ezgi_production_analist','longpage');"><img src="/images/target_team.gif" title="<cf_get_lang dictionary_id='628.Üretim Sonuç Analizi'>"></a>&nbsp;&nbsp;&nbsp;
           		<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_display_ezgi_prod_menu_moduler&type=1&master_plan_id=1','longpage');"><img src="/images/table.gif" title="<cf_get_lang dictionary_id='38033.Üretim Takibi'>"></a>&nbsp;&nbsp;&nbsp;
		</cfsavecontent>   
      	<cfsavecontent variable="title"><cf_get_lang dictionary_id="40720.Üretim Programı"></cfsavecontent>
   		<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1" right_images="#right#">
      		<cf_grid_list>   
		    	<thead>
                    <tr valign="middle">
                        <th style="width:25px; text-align:center"><cf_get_lang dictionary_id='57487.No'></th>
                        <th style="width:75px; text-align:center"><cf_get_lang dictionary_id='57880.Belge No'></th>
                        <th style="width:70px; text-align:center"><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></th>
                        <th style="width:70px; text-align:center"><cf_get_lang dictionary_id='1064.Toplam Modül'></th>
                        <th style="width:70px; text-align:center"><cf_get_lang dictionary_id='1063.Biten Modül'></th>
                        <th style="width:70px; text-align:center"><cf_get_lang dictionary_id='1059.Toplam Paket'></th>
                        <th style="width:70px; text-align:center"><cf_get_lang dictionary_id='1062.Biten Paket'></th>
                        <th style="width:80px; text-align:center">Toplam İş Emri</th>
                        <th style="width:70px; text-align:center">Biten İş Emri</th>
                        
                        <th style="width:95px; text-align:center"><cf_get_lang dictionary_id='36604.Hedef Başlangıç'></th>
                        <th style="width:95px; text-align:center"><cf_get_lang dictionary_id='36606.Hedef Bitiş'></th>
                        <th style="width:125px; text-align:center"><cfoutput><cf_get_lang dictionary_id='1030.Planlama Türü'></cfoutput></th>
                        <th style="text-align:center"><cf_get_lang dictionary_id='57629.Açıklama'></th>
                        <th style="width:50px; text-align:center"><cf_get_lang dictionary_id='58859.Süreç'></th>
                        <!-- sil -->
                        <th style="width:25px; text-align:center" class="header_icn_none"></th>
                        <th style="width:20px; text-align:center; vertical-align:middle" class="header_icn_none" >
                            <input type="checkbox" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="gecim(-1);">
                        </th>
                        <th style="width:25px; text-align:center"  class="header_icn_none"><a href="<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.</cfoutput>list_ezgi_iflow_master_plan&event=add"><img src="/images/plus_list.gif" style="text-align:center" title="<cf_get_lang dictionary_id='57582.Ekle'>" border="0"></a></th>
                        <!-- sil -->
                    </tr>
		        </thead>
		        <tbody>
					<cfif get_ezgi_iflow_master_plan.recordcount>
                        <cfset TM_BAKIYE = 0>
                        <cfset BM_BAKIYE = 0>
                        <cfset TP_BAKIYE = 0>
                        <cfset BP_BAKIYE = 0>
                      	<cfset TE_BAKIYE = 0>
                        <cfset BE_BAKIYE = 0>
                        <cfoutput query="get_ezgi_iflow_master_plan">
                            <tr>
                                <td style="text-align:right">#RowNum#</td>
                                <td style="text-align:center">
                                    <a href="#request.self#?fuseaction=prod.list_ezgi_iflow_master_plan&event=upd&master_plan_id=#MASTER_PLAN_ID#"  class="tableyazi">
                                        #MASTER_PLAN_NUMBER#
                                    </a>
                                </td>
                                <td style="text-align:center">#dateformat(record_date,dateformat_style)#</td>
                                <td style="text-align:right">#Tlformat(TOPLAM_MODUL,2)#</td>
                                <td style="text-align:right">#Tlformat(BITEN_MODUL,2)#</td>
                                <td style="text-align:right">#Tlformat(TOPLAM_PAKET,2)#</td>
                                <td style="text-align:right">#Tlformat(BITEN_PAKET,2)#</td>
                                <td style="text-align:right">#Tlformat(TOPLAM_EMIR,2)#</td>
                                <td style="text-align:right">#Tlformat(BITEN_EMIR,2)#</td>
                                <td style="text-align:center">#dateformat(MASTER_PLAN_START_DATE,dateformat_style)#</td>
                                <td style="text-align:center">#dateformat(MASTER_PLAN_FINISH_DATE,dateformat_style)#</td>
                                <td>#MASTER_PLAN_NAME#</td>
                                <td>#MASTER_PLAN_DETAIL#</td>
                                <td style="text-align:center">#STAGE#</td>
                                <!-- sil -->
                                <td style="text-align:center;">
                                    <cfif BITEN_EMIR eq 0>
                                        <img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                    <cfelseif BITEN_EMIR lt TOPLAM_EMIR>
                                        <img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='398.Başladı'>">
                                    <cfelseif BITEN_EMIR gt TOPLAM_EMIR>
                                        <img src="/images/grey_glob.gif" title="<cf_get_lang dictionary_id='298.Arıza'>">
                                    <cfelse>
                                        <img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='305.Bitti'>">
                                    </cfif>
                                </td>
                                <td style="text-align:center;">
                                    <cfif isdefined('MASTER_PLAN_#MASTER_PLAN_ID#')>
                                        <input type="checkbox" name="select_sub_plan" value="#MASTER_PLAN_ID#">
                                    </cfif>
                                </td>
                                <td style="text-align:center">
                                    <a href="#request.self#?fuseaction=prod.list_ezgi_iflow_master_plan&event=upd&master_plan_id=#MASTER_PLAN_ID#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                                </td>
                                <cfset TE_BAKIYE = TE_BAKIYE+TOPLAM_EMIR>
                                <cfset BE_BAKIYE = BE_BAKIYE+BITEN_EMIR>
                                <cfset TM_BAKIYE = TM_BAKIYE+TOPLAM_MODUL>
                                <cfset BM_BAKIYE = BM_BAKIYE+BITEN_MODUL>
                                <cfif isnumeric(TOPLAM_PAKET)>
                                	<cfset TP_BAKIYE = TP_BAKIYE+TOPLAM_PAKET>
                                </cfif>
                                <cfset BP_BAKIYE = BP_BAKIYE+BITEN_PAKET>
                                <!-- sil -->
                                </tr>
                            </cfoutput>
                            <cfoutput>
                            <tfoot>
                                <tr  height="20">
                                <td colspan="3" align="right" class="txtbold" style="text-align:right;"><cf_get_lang dictionary_id='57492.Toplam'></td>
                                <td class="txtbold" style="text-align:right;">#TLFormat(TM_BAKIYE,2)#</td>
                                <td class="txtbold" style="text-align:right;">#TLFormat(BM_BAKIYE,2)#</td>
                                <td class="txtbold" style="text-align:right;">#TLFormat(TP_BAKIYE,2)#</td>
                                <td class="txtbold" style="text-align:right;">#TLFormat(BP_BAKIYE,2)#</td>
                                <td class="txtbold" style="text-align:right;">#TLFormat(TE_BAKIYE,2)#</td>
                                <td class="txtbold" style="text-align:right;">#TLFormat(BE_BAKIYE,2)#</td>
                                <!-- sil -->
                                <td colspan="8" style="text-align:right">
                                	<button type="button" name="print_button" id="print_button" onclick="gecim(-3);" style="width:100px; height:30px; text-align:center;font-size:10px; font-weight:bold">
                                        <img src="/images/print_plus.gif" alt="<cf_get_lang dictionary_id='57474.Yazdır'>" border="0"><cf_get_lang dictionary_id='57474.Yazdır'>
                                    </button>
                                    &nbsp;
                                    <button type="button" name="material_button" id="material_button" onclick="gecim(-2);" style="width:100px; height:30px; text-align:center;font-size:10px; font-weight:bold">
                                        <img src="/images/forklift.gif" alt="<cf_get_lang dictionary_id='444.Malzeme'>" border="0"><cf_get_lang dictionary_id='444.Malzeme'>
                                    </button>
                                </td>
                                <!-- sil -->
                            </tr>
                        </tfoot>
                    </cfoutput>
                    <cfelse>
                        <tr> 
                            <td colspan="15" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
                        </tr>
                    </cfif>
		  		</tbody>
		    </cf_grid_list>
		    <cfset adres="prod.list_ezgi_iflow_master_plan">
				<cfif isDefined('attributes.date1') and isdate(attributes.date1)>
		        <cfset adres = '#adres#&date1=#attributes.date1#'>
		    </cfif>
		    <cfif isDefined('attributes.date2') and isdate(attributes.date2)>
		        <cfset adres = '#adres#&date2=#attributes.date2#'>
		    </cfif>
		    <cfif isDefined('attributes.record_date1') and isdate(attributes.record_date1)>
		        <cfset adres = '#adres#&record_date1=#attributes.record_date1#'>
		    </cfif>
		    <cfif isDefined('attributes.record_date2') and isdate(attributes.record_date2)>
		        <cfset adres = '#adres#&record_date2=#attributes.record_date2#'>
		    </cfif>
		    <cfif isDefined("attributes.master_plan_status") and len(attributes.master_plan_status)>
		        <cfset adres = '#adres#&master_plan_status=#attributes.master_plan_status#'>
		    </cfif>
		    <cfif isDefined('attributes.keyword') and len(attributes.keyword)>
		        <cfset adres = '#adres#&keyword=#attributes.keyword#'>
		    </cfif>
		    <cfif isDefined('attributes.oby') and len(attributes.oby)>
		        <cfset adres = '#adres#&oby=#attributes.oby#'>
		    </cfif>
		    <cfif isdefined('attributes.process_stage') and len(attributes.process_stage)>
		        <cfset adres = '#adres#&process_stage=#attributes.process_stage#'>
		    </cfif>
		    <cfif isdefined('attributes.is_form_submitted') and len(attributes.is_form_submitted)>
		        <cfset adres = adres&"&is_submitted=1">
		    </cfif>
		    <cf_paging 
		        page="#attributes.page#"
		        maxrows="#attributes.maxrows#"
		        totalrecords="#attributes.totalrecords#"
		        startrow="#attributes.startrow#"
		        adres="#adres#&is_submitted=1">  
     	</cf_box>
		
   	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;	
	}
	function gecim(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
		master_plan_id_list = '';
		chck_leng = document.getElementsByName('select_sub_plan').length;
		for(ci=0;ci<chck_leng;ci++)
		{
			var my_objets = document.all.select_sub_plan[ci];
			if(chck_leng == 1)
				var my_objets =document.all.select_sub_plan;
			if(type == -1){//hepsini seç denilmişse	
				if(my_objets.checked == true)
					my_objets.checked = false;
				else
					my_objets.checked = true;
			}
			else
			{
				if(my_objets.checked == true)
					master_plan_id_list +=my_objets.value+',';
			}
		}
		master_plan_id_list = master_plan_id_list.substr(0,master_plan_id_list.length-1);//sondaki virgülden kurtarıyoruz.
		if(list_len(master_plan_id_list,','))
		{
			if(type == -2)
				windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_dsp_ezgi_iflow_product_metarial_need&master_plan_id_list='+master_plan_id_list,'longpage');
			if(type == -3)
				windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_print_files&print_type=289</cfoutput>&action_id='+master_plan_id_list,'page');
			else
				return false;
		}
	}
</script>