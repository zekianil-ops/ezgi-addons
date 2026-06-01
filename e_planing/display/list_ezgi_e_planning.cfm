<cfparam name="attributes.planer_employee" default="">
<cfparam name="attributes.planer_employee_id" default="">
<cfparam name="attributes.department_id" default="">
<cfparam name="attributes.listing_type" default="3">
<cfparam name="attributes.sort_type" default="2">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.page" default=1>
<cfquery name="get_department" datasource="#dsn#">
	SELECT        
    	DEPARTMENT_HEAD, 
        DEPARTMENT_ID
	FROM            
    	DEPARTMENT
	WHERE        
    	IS_PRODUCTION = 1 AND 
        BRANCH_ID IN (SELECT BRANCH_ID FROM BRANCH WHERE COMPANY_ID = #session.ep.company_id#)  AND 
        DEPARTMENT_STATUS = 1
</cfquery>
<cfoutput query="get_department">
	<cfset 'department_#department_id#' = DEPARTMENT_HEAD>
</cfoutput>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfscript>
	get_planing.recordcount=0;
	get_planing.query_count=0;
	if (isdefined("attributes.form_varmi"))
	{
		get_design_list_action = createObject("component", "addOns.ezgi.cfc.get_planing");
		get_design_list_action.dsn3 = dsn3;
		get_planing = get_design_list_action.get_planing_
		(
		 	planer_employee : '#iif(isdefined("attributes.planer_employee"),"attributes.planer_employee",DE(""))#',
			planer_employee_id : '#iif(isdefined("attributes.planer_employee_id"),"attributes.planer_employee_id",DE(""))#',
			department_id : '#iif(isdefined("attributes.department_id"),"attributes.department_id",DE(""))#',
			sort_type : '#iif(isdefined("attributes.sort_type"),"attributes.sort_type",DE(""))#',
			keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
			listing_type : '#IIf(IsDefined("attributes.listing_type"),"attributes.listing_type",DE(""))#',
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
<cfparam name="attributes.totalrecords" default='#get_planing.query_count#'>
<cfsavecontent variable="right_menu">
	 <a href="javascript://" onclick="window.open('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_production_need</cfoutput>','_blank');">
     	<img src="../../../images/carier.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='272.Üretim Plan Hesaplama'>" />
   	</a>&nbsp;&nbsp;
  	<a href="javascript://" onclick="window.open('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_production_demonte_need</cfoutput>','_blank');">
    	<img src="../../../images/package.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='273.Demonte Ürün Hesaplama'>" />
	</a>&nbsp;&nbsp;
</cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="planning_form" method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
			 <input name="form_varmi" id="form_varmi" value="1" type="hidden">
             <cf_box_search>
                <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group">
                	<select name="listing_type" id="listing_type" style="width:160px;height:20px">
                     	<option value="1" <cfif attributes.listing_type eq 1>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                     	<option value="2" <cfif attributes.listing_type eq 2>selected</cfif>><cf_get_lang dictionary_id='268.Planlananlar'></option>
                     	<option value="3" <cfif attributes.listing_type eq 3>selected</cfif>><cf_get_lang dictionary_id='269.Bekleyenler'></option>
              		</select> 
                </div>
                <div class="form-group">
                	<select name="sort_type" id="sort_type" style="width:180px;height:20px">
                    	<option value="1" <cfif attributes.sort_type eq 1>selected</cfif>><cf_get_lang dictionary_id="60613.Belge Numarasına Göre Artan"></option>
                     	<option value="2" <cfif attributes.sort_type eq 2>selected</cfif>><cf_get_lang dictionary_id="60612.Belge Numarasına Göre Azalan"></option>
                 	</select> 
                </div>
                <div class="form-group">
                 	<select name="department_id"  id="department_id"style="width:160px; height:20px">
                     	<option value=""><cf_get_lang dictionary_id='57572.Departman'></option>
                       	<cfoutput query="get_department">
                        	<option  value="#department_id#" <cfif attributes.department_id eq department_id>selected</cfif>>#DEPARTMENT_HEAD#</option>
                      	</cfoutput>
                   	</select>
                </div>
                <cfsavecontent variable="planner_"><cf_get_lang dictionary_id='33360.Talep Eden'></cfsavecontent>
                <div class="form-group">
                	<div class="input-group">
                    	<input type="hidden" name="planer_employee_id" id="planer_employee_id" value="<cfif isdefined('attributes.planer_employee_id') and len(attributes.planer_employee_id) and isdefined('attributes.planer_employee') and len(attributes.planer_employee)><cfoutput>#attributes.planer_employee_id#</cfoutput></cfif>">
                        <input name="planer_employee" type="text" id="planer_employee" placeholder="<cfoutput>#planner_#</cfoutput>" style="width:160px;vertical-align:top" onfocus="AutoComplete_Create('planer_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','planer_employee_id','','3','125');" value="<cfif isdefined('attributes.planer_employee_id') and len(attributes.planer_employee_id) and isdefined('attributes.planer_employee') and len(attributes.planer_employee)><cfoutput>#attributes.planer_employee#</cfoutput></cfif>" autocomplete="off" >	
                      	<span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=planning_form.planer_employee_id&field_name=planning_form.planer_employee&is_form_submitted=1&select_list=1','list');"></span>
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
      	</cfform>
    </cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id="39.E-Planing"></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1" right_images="#right_menu#">
     	<cf_grid_list>
        	<thead>
            	<tr>
                    <th style="width:30px;text-align:center" class="header_icn_txt"><cf_get_lang dictionary_id='58577.Sira'></th>
                    <th style="width:55px;text-align:center"><cf_get_lang dictionary_id='56879.Talep No'></th>
                    <th style="width:200px;text-align:center"><cf_get_lang dictionary_id='58820.Başlık'></th>
                    <th style="width:100px;text-align:center"><cf_get_lang dictionary_id='57742.tarih'></th>
                    <th style="width:100px;text-align:center"><cf_get_lang dictionary_id='36798.Termin'></th>
                    <th style="width:120px;text-align:center"><cf_get_lang dictionary_id='58859.Süreç'></th>
                    <th style="width:100px;text-align:center"><cf_get_lang dictionary_id='38281.Planlayan'></th>
                    <th style="width:150px;text-align:center"><cf_get_lang dictionary_id='57572.Departman'></th>
                    <th style="width:55px;text-align:center"><cf_get_lang dictionary_id='57756.Durum'></th>
                    <th style="text-align:center"><cf_get_lang dictionary_id='57629.Açıklama'></th>
                    <!-- sil -->
                    <th style="width:20px;text-align:center">
                        <a href="<cfoutput>#request.self#</cfoutput>?fuseaction=prod.list_ezgi_e_planning&event=add"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
                    </th>
                    <!-- sil -->
				</tr>
            </thead>
            <tbody>
                <cfif get_planing.recordcount>
                    <cfset stage_list=''>
                    <cfoutput query="get_planing">
                        <cfif len(PROCESS_STAGE) and not listfind(stage_list,PROCESS_STAGE)>
                            <cfset stage_list=listappend(stage_list,PROCESS_STAGE)>
                        </cfif>
                    </cfoutput>
                    <cfif len(stage_list)>
                        <cfset stage_list=listsort(stage_list,"numeric","ASC",",")>
                        <cfquery name="PROCESS_TYPE_ALL" datasource="#DSN#">
                            SELECT STAGE, PROCESS_ROW_ID FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID IN (#stage_list#) ORDER BY PROCESS_ROW_ID
                        </cfquery>
                        <cfset stage_list = listsort(listdeleteduplicates(valuelist(process_type_all.process_row_id,',')),"numeric","ASC",",")>
                    </cfif>
                    <cfoutput query="get_planing">
                        <tr>
                            <td style="text-align:right">#rownum#</td>
                            <td style="text-align:center">
                                <a href="#request.self#?fuseaction=prod.list_ezgi_e_planning&event=upd&upd_id=#EZGI_DEMAND_ID#" class="tableyazi" title="<cf_get_lang dictionary_id='274.Talep Fişine Git'>">
                                        #DEMAND_NUMBER#
                                </a>
                            </td>
                            <td>#DEMAND_HEAD#</td>
                            <td style="text-align:center">#DateFormat(DEMAND_DATE,dateformat_style)#</td>
                            <td style="text-align:center">#DateFormat(DEMAND_DELIVER_DATE,dateformat_style)#</td>
                            <td style="text-align:center"><cfif len(PROCESS_STAGE)>#process_type_all.stage[listfind(stage_list,PROCESS_STAGE,',')]#</cfif></td>
                            <td>#get_emp_info(DEMAND_EMP,0,0)#</td>
                            <td style="text-align:left"><cfif isdefined('department_#DEMAND_DEPARTMENT_ID#')>#Evaluate('department_#DEMAND_DEPARTMENT_ID#')#</cfif></td>
                            <td style="text-align:center"></td>
                            <td style="text-align:left">#DEMAND_DETAIL#</td>
                            <!-- sil -->
                          	<td style="text-align:center">
                             	<a href="#request.self#?fuseaction=prod.list_ezgi_e_planning&event=upd&upd_id=#EZGI_DEMAND_ID#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                        	</td>
                         	<!-- sil -->
                        </tr>
                    </cfoutput>
                <cfelse>
                    <tr>
                        <td colspan="16"><cfif arama_yapilmali neq 1><cf_get_lang dictionary_id='57484.Kayit Yok'>!<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz '>!</cfif></td>
                    </tr>
                </cfif>	
            </tbody>
      	</cf_grid_list>
        <cfset url_str = url.fuseaction>
        <cfif isdefined("attributes.keyword") and len(attributes.keyword)>
            <cfset url_str = url_str & "&keyword=#attributes.keyword#">
        </cfif>
        <cfif isdefined("attributes.planer_employee_id") and len(attributes.planer_employee_id)> 
            <cfset url_str = url_str & "&planer_employee_id=#attributes.planer_employee_id#&planer_employee=#attributes.planer_employee#">
        </cfif>
        <cfif isdefined("attributes.listing_type") and len(attributes.listing_type)>
            <cfset url_str = "#url_str#&listing_type=#attributes.listing_type#">
        </cfif>
        <cfif isdefined("attributes.department_id") and len(attributes.department_id)>
            <cfset url_str = "#url_str#&department_id=#attributes.department_id#">
        </cfif>
        <cfset url_str = url_str & "&sort_type=#attributes.sort_type#">
        <cf_paging 
            page="#attributes.page#"
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#url_str#&form_varmi=1">
    </cf_box>
</div>
<script language="javascript">
	function input_control()
	{
		return true;
	}
</script>
