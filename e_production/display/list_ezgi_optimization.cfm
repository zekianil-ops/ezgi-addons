<!---
    File: list_ezgi_optimization.cfm
    Folder: AddOns\ezgi\e_production\display
    Author: Ezgi Yazılım
    Date: #dateFormat(now(), "dd/mm/yyyy")#
    Description: Optimizasyon Liste Sayfası
--->

<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.record_emp_id" default="">
<cfparam name="attributes.record_emp_name" default="">
<cfparam name="attributes.record_date1" default="">
<cfparam name="attributes.record_date2" default="">
<cfparam name="attributes.oby" default="1">
<cfparam name="attributes.optimization_status" default="1">
<cfparam name="attributes.page" default="1">
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

<cfscript>
	get_ezgi_optimization.recordcount=0;
	get_ezgi_optimization.query_count=0;
	if (isdefined("attributes.is_submitted"))
	{
		get_ezgi_optimization_action = createObject("component", "addOns.ezgi.cfc.get_ezgi_optimization");
		get_ezgi_optimization_action.dsn = dsn;
		get_ezgi_optimization_action.dsn3 = dsn3;
		get_ezgi_optimization = get_ezgi_optimization_action.get_ezgi_optimization_
		(
		 	keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
			record_emp_id : '#IIf(IsDefined("attributes.record_emp_id"),"attributes.record_emp_id",DE(""))#',
			record_emp_name : '#iif(isdefined("attributes.record_emp_name"),"attributes.record_emp_name",DE(""))#',
			record_date1 : '#iif(isdefined("attributes.record_date1"),"attributes.record_date1",DE(""))#',
			record_date2 : '#iif(isdefined("attributes.record_date2"),"attributes.record_date2",DE(""))#',
			date1 : '#iif(isdefined("attributes.date1"),"attributes.date1",DE(""))#',
			date2 : '#iif(isdefined("attributes.date2"),"attributes.date2",DE(""))#',
		 	oby : '#iif(isdefined("attributes.oby"),"attributes.oby",DE(""))#',
			optimization_status : '#IIf(IsDefined("attributes.optimization_status"),"attributes.optimization_status",DE(""))#',
		 	startrow : '#iif(isdefined("attributes.startrow"),"attributes.startrow",DE(""))#',
			maxrows : '#iif(isdefined("attributes.maxrows"),"attributes.maxrows",DE(""))#'
		);
		arama_yapilmali=0;
		if (get_ezgi_optimization.recordcount)
		{
			get_ezgi_optimization.query_count = get_ezgi_optimization.QUERY_COUNT;
		}
		else
		{
			get_ezgi_optimization.query_count = 0;
		}
	}
	else
	{
		arama_yapilmali=1;
	}
</cfscript>

<cfparam name="attributes.totalrecords" default='#get_ezgi_optimization.query_count#'>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
			<input name="is_submitted" id="is_submitted" type="hidden" value="1">
            <cf_box_search>
                <div class="form-group" id="item-keyword">
                    <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                	<cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group medium" id="item-oby">
                	<select name="oby" style="width:120px; height:20px">
                     	<option value="1" <cfif attributes.oby eq 1>selected</cfif>><cf_get_lang dictionary_id='57926.Azalan Tarih'></option>
                      	<option value="2" <cfif attributes.oby eq 2>selected</cfif>><cf_get_lang dictionary_id='57925.Artan Tarih'></option>
                  	</select>
               	</div>
                <div class="form-group medium" id="item-optimization_status">
                	<select name="optimization_status" style="width:80px; height:20px">
                    	<option value=""><cf_get_lang dictionary_id='57708 .Tümü'></option>
                      	<option value="1"<cfif isDefined("attributes.optimization_status") and (attributes.optimization_status eq 1)> selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                      	<option value="0"<cfif isDefined("attributes.optimization_status") and (attributes.optimization_status eq 0)> selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
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
		
      	<cfsavecontent variable="title"><cf_get_lang dictionary_id='583.Optimizasyon'></cfsavecontent>
   		<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
      		<cf_grid_list>   
		    	<thead>
                    <tr valign="middle">
                        <th style="width:25px; text-align:center"><cf_get_lang dictionary_id='57487.No'></th>
                        <th style="width:75px; text-align:center"><cf_get_lang dictionary_id='57880.Belge No'></th>
                        <th style="width:70px; text-align:center"><cf_get_lang dictionary_id='57073.Belge Tarihi'></th>
                        <th style="width:120px; text-align:center"><cf_get_lang dictionary_id='57899.Kaydeden'></th>
                        <th style="text-align:center"><cf_get_lang dictionary_id='57629.Açıklama'></th>
                        <!-- sil -->
                        <th style="width:25px; text-align:center" class="header_icn_none"></th>
                        <th style="width:25px; text-align:center"  class="header_icn_none"><a href="<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.</cfoutput>list_ezgi_optimization&event=add"><img src="/images/plus_list.gif" style="text-align:center" title="<cf_get_lang dictionary_id='57582.Ekle'>" border="0"></a></th>
                        <!-- sil -->
                    </tr>
		        </thead>
		        <tbody>
					<cfif get_ezgi_optimization.recordcount>
                        <cfoutput query="get_ezgi_optimization">
                            <tr>
                                <td style="text-align:right">#RowNum#</td>
                                <td style="text-align:center">
                                    <a href="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_ezgi_optimization&event=upd&optimization_id=#OPTIMIZATION_ID#" class="tableyazi">
                                        #OPTIMIZATION_NUMBER#
                                    </a>
                                </td>
                                <td style="text-align:center"><cfif isDate(OPTIMIZATION_DATE)>#dateformat(OPTIMIZATION_DATE, dateformat_style)#</cfif></td>
                                <td style="text-align:left"><cfif len(OPTIMIZATION_EMP) and isNumeric(OPTIMIZATION_EMP)>#get_emp_info(OPTIMIZATION_EMP, 0, 0)#</cfif></td>
                                <td>#OPTIMIZATION_DETAIL#</td>
                                <td style="text-align:center"></td>
                                <td style="text-align:center">
                                    <a href="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_ezgi_optimization&event=upd&optimization_id=#OPTIMIZATION_ID#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                                </td>
                            </tr>
                        </cfoutput>
                    <cfelse>
                        <tr> 
                            <td colspan="7" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
                        </tr>
                    </cfif>
		  		</tbody>
		    </cf_grid_list>
		    <cfset adres="#listgetat(attributes.fuseaction,1,'.')#.list_ezgi_optimization">
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
		    <cfif isDefined("attributes.optimization_status") and len(attributes.optimization_status)>
		        <cfset adres = '#adres#&optimization_status=#attributes.optimization_status#'>
		    </cfif>
		    <cfif isDefined('attributes.keyword') and len(attributes.keyword)>
		        <cfset adres = '#adres#&keyword=#attributes.keyword#'>
		    </cfif>
		    <cfif isDefined('attributes.oby') and len(attributes.oby)>
		        <cfset adres = '#adres#&oby=#attributes.oby#'>
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
</script>

