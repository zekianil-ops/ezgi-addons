<!---
    File: list_ezgi_workstation_oee_rate.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.is_active" default="1">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.list_type" default="1">
<cfparam name="attributes.list_check" default="">
<cfparam name="is_active" default="1">
<cfparam name="attributes.page" default=1>
<cfinclude template="../../../../v16/production_plan/query/get_branch.cfm">
<cfif isdefined("attributes.form_submitted")>
	<cfif attributes.list_type eq 1>
        <cfquery name="GET_WORKSTATION_ALL" datasource="#dsn3#">
            SELECT  
                ISNULL(E.EZGI_STATION_OOE_RATE_ID,0) AS EZGI_STATION_OOE_RATE_ID,      
                W.STATION_ID, 
                W.STATION_NAME, 
                D.DEPARTMENT_HEAD, 
                D.DEPARTMENT_ID, 
                D.BRANCH_ID, 
                B.BRANCH_NAME,
                ISNULL(E.OEE_STATUS,0) AS OEE_STATUS, 
                ISNULL(E.OEE_PERFORM_RATE,0) AS OEE_PERFORM_RATE, 
                ISNULL(E.OEE_AVAILBILITY_RATE,0) AS OEE_AVAILBILITY_RATE, 
                ISNULL(E.OEE_QUALITY_RATE,0) AS OEE_QUALITY_RATE
            FROM            
                WORKSTATIONS AS W WITH (NOLOCK) INNER JOIN
                #dsn_alias#.BRANCH AS B WITH (NOLOCK) ON W.BRANCH = B.BRANCH_ID INNER JOIN
                #dsn_alias#.DEPARTMENT AS D WITH (NOLOCK) ON W.DEPARTMENT = D.DEPARTMENT_ID LEFT OUTER JOIN
                EZGI_STATION_OOE_RATE AS E WITH (NOLOCK) ON W.STATION_ID = E.STATION_ID
            WHERE        
                NOT (W.UP_STATION IS NULL) 
                <cfif isdefined("attributes.list_check") and attributes.list_check eq 1> 
                    AND ISNULL(E.OEE_STATUS,0) = 1
                <cfelseif isdefined("attributes.list_check") and attributes.list_check eq 2>
                    AND ISNULL(E.OEE_STATUS,0) = 0
                </cfif>
                <cfif isdefined("attributes.branch_id") and len(attributes.branch_id)>AND B.BRANCH_ID = #attributes.branch_id#</cfif>
                <cfif isdefined("attributes.keyword") and len(attributes.keyword)>AND W.STATION_NAME LIKE '%#attributes.keyword#%'</cfif>	
                <cfif isdefined("attributes.is_active") and len(attributes.is_active)>AND W.ACTIVE = #attributes.is_active#</cfif>
            ORDER BY
                W.STATION_NAME
        </cfquery>
    <cfelse>
        <cfquery name="GET_WORKSTATION_ALL" datasource="#dsn3#">
            SELECT 
                ISNULL(E.EZGI_EMPLOYEE_OOE_RATE_ID,0) AS EZGI_STATION_OOE_RATE_ID,
                W.EMPLOYEE_ID AS STATION_ID, 
                W.EMPLOYEE_NAME+' '+W.EMPLOYEE_SURNAME AS STATION_NAME,
                D.DEPARTMENT_HEAD, 
                D.DEPARTMENT_ID, 
                D.BRANCH_ID, 
                B.BRANCH_NAME, 
                ISNULL(E.OEE_STATUS, 0) AS OEE_STATUS, 
                ISNULL(E.OEE_PERFORM_RATE, 0) AS OEE_PERFORM_RATE, 
                ISNULL(E.OEE_AVAILBILITY_RATE, 0) AS OEE_AVAILBILITY_RATE, 
                ISNULL(E.OEE_QUALITY_RATE, 0) AS OEE_QUALITY_RATE 
            FROM            
                #dsn_alias#.EMPLOYEE_POSITIONS AS W WITH (NOLOCK) INNER JOIN
                #dsn_alias#.DEPARTMENT AS D WITH (NOLOCK) ON W.DEPARTMENT_ID = D.DEPARTMENT_ID INNER JOIN
                #dsn_alias#.BRANCH AS B WITH (NOLOCK) ON D.BRANCH_ID = B.BRANCH_ID LEFT OUTER JOIN
                EZGI_EMPLOYEE_OOE_RATE AS E WITH (NOLOCK) ON W.EMPLOYEE_ID = E.EMPLOYEE_ID
            WHERE        
                D.IS_PRODUCTION = 1 AND 
                W.POSITION_STATUS = 1
                <cfif isdefined("attributes.list_check") and attributes.list_check eq 1> 
                    AND ISNULL(E.OEE_STATUS,0) = 1
                <cfelseif isdefined("attributes.list_check") and attributes.list_check eq 2>
                    AND ISNULL(E.OEE_STATUS,0) = 0
                </cfif>
                <cfif isdefined("attributes.branch_id") and len(attributes.branch_id)>AND B.BRANCH_ID = #attributes.branch_id#</cfif>
                <cfif isdefined("attributes.keyword") and len(attributes.keyword)>AND W.EMPLOYEE_NAME+' '+W.EMPLOYEE_SURNAME LIKE '%#attributes.keyword#%'</cfif>	
                <cfif isdefined("attributes.is_active") and len(attributes.is_active)>AND W.POSITION_STATUS = #attributes.is_active#</cfif>
            ORDER BY
                STATION_NAME
        </cfquery>
    </cfif>
<cfelse>
	<cfset get_workstation_all.recordcount = 0>    
</cfif>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_workstation_all.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfset url_str = "prod.list_ezgi_workstation_oee_rate">
<cfif isdefined("attributes.form_submitted")><cfset url_str = "#url_str#&form_submitted=#attributes.form_submitted#"></cfif>
<cfif isdefined("attributes.field_id") and len(attributes.field_id)><cfset url_str = "#url_str#&field_id=#attributes.field_id#"></cfif>
<cfif isdefined("attributes.field_name") and len(attributes.field_name)><cfset url_str = "#url_str#&field_name=#attributes.field_name#"></cfif>
<cfif len(attributes.keyword)><cfset url_str = "#url_str#&keyword=#attributes.keyword#"></cfif>
<cfif len(attributes.is_active)><cfset url_str = "#url_str#&is_active=#attributes.is_active#"></cfif>
<cfif len(attributes.branch_id)><cfset url_str = "#url_str#&branch_id=#attributes.branch_id#"></cfif>
<cfif len(attributes.list_type)><cfset url_str = "#url_str#&list_type=#attributes.list_type#"></cfif>
<cfif len(attributes.list_check)><cfset url_str = "#url_str#&list_check=#attributes.list_check#"></cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform action="#request.self#?fuseaction=prod.list_ezgi_workstation_oee_rate" method="post" name="form">
			<input type="hidden" name="form_submitted" id="form_submitted" value="1">
            <cf_box_search>
              	<div class="form-group"  id="item-keyword">
                  	<cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                	<cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
            	</div>
                <div class="form-group medium" id="item-branch_id">
					<select name="branch_id" style="width:150px; height:20px">
						<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
						<cfoutput query="get_branch">
							<option value="#branch_id#"<cfif attributes.branch_id eq branch_id>selected</cfif>>#branch_name#</option>
						</cfoutput>
					</select>
              	</div>
                <div class="form-group medium" id="item-list_type">
					<select name="list_type" id="list_type" style="width:100px; height:20px">
                     	<option value="1" <cfif attributes.list_type eq 1>selected</cfif>><cf_get_lang dictionary_id='58834.İstasyon'></option>
                      	<option value="2" <cfif attributes.list_type eq 2>selected</cfif>><cf_get_lang dictionary_id='57576.Çalışan'></option>
                	</select>
              	</div>
                <div class="form-group medium" id="item-is_active">
					<select name="is_active" id="is_active" style="width:50px; height:20px">
                   		<option value="2"><cf_get_lang dictionary_id='57708.Tümü'></option>
                    	<option value="1" <cfif attributes.is_active eq 1>selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                  		<option value="0" <cfif attributes.is_active eq 0>selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                  	</select>
              	</div>
                <div class="form-group medium" id="item-list_check">
					<select name="list_check" id="list_check" style="width:100px; height:20px">
                     	<option value="" <cfif attributes.list_check eq "">selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                     	<option value="1" <cfif attributes.list_check eq 1>selected</cfif>><cf_get_lang dictionary_id='1040.OEE Aktifler'></option>
                      	<option value="2" <cfif attributes.list_check eq 2>selected</cfif>><cf_get_lang dictionary_id='1041.OEE Pasifler'></option>
                 	</select>
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

   		<cfsavecontent variable="title"><cf_get_lang dictionary_id='797.İstasyon OEE Oranları'></cfsavecontent>
      	<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
        	<cf_grid_list>   
              	<thead>
                  	<tr valign="middle">
                     	<th style="width:30px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        <th><cf_get_lang dictionary_id='36669.İstasyon Adı'></th>
                        <th style="width:130px"><cf_get_lang dictionary_id='57453.Şube'></th>
                        <th style="width:130px"><cf_get_lang dictionary_id='57572.Departman'></th>
                        <th style="width:30px; text-align:center"><cf_get_lang dictionary_id='683.OEE'></th>
                        <th style="width:150px"><cf_get_lang dictionary_id='1039.Performans Oranı'>(%)</th>
                        <th style="width:150px"><cf_get_lang dictionary_id='1049.Toplam Çalışma Oranı'>(%)</th>
                        <th style="width:150px"><cf_get_lang dictionary_id='1038.Kalite Oranı'>(%)</th>
                        <!-- sil --><th style="width:30px" class="header_icn_none" ></th><!-- sil -->
                    </tr>
                </thead>
                <tbody>
					<cfif get_workstation_all.recordcount>
                        <cfoutput query="get_workstation_all" STARTROW="#attributes.startrow#" MAXROWS="#attributes.maxrows#">
                            <tr>
                                <td>#currentrow#</td>
                                <td>
                                <cfif attributes.list_type eq 1>
                                    <a href="#request.self#?fuseaction=prod.upd_ezgi_workstation&station_id=#station_id#" class="tableyazi">#station_name#</a>
                                <cfelse>
                                    <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_emp_det&emp_id=#station_id#','list');" class="tableyazi">#station_name#</a>
                                </cfif>
                                </td>
                                <td>#branch_name#</td>
                                <td>#DEPARTMENT_HEAD#</td>
                                <td style="text-align:center">
                                    <input type="checkbox" name="input_check#CURRENTROW#" id="input_check#CURRENTROW#" value="1" readonly onChange="duzenle(#CURRENTROW#,#STATION_ID#,#EZGI_STATION_OOE_RATE_ID#);" <cfif OEE_STATUS eq 1>checked</cfif>>
                                    <input type="hidden" id="workstation_oee_check#currentrow#" name="workstation_oee_check#currentrow#" value="#OEE_STATUS#" /> 
                                </td>
                                <td style="text-align:center">
                                    <input name="input_perform_rate#CURRENTROW#" id="input_perform_rate#CURRENTROW#" value="#TlFormat(OEE_PERFORM_RATE,0)#" class="box" style="width:40px; text-align:center" onChange="duzenle(#CURRENTROW#,#STATION_ID#,#EZGI_STATION_OOE_RATE_ID#);">
                                    <input type="hidden" id="workstation_perform_rate#currentrow#" name="workstation_perform_rate#currentrow#" value="#TlFormat(OEE_PERFORM_RATE,0)#" /> 
                                </td>
                                <td style="text-align:center">
                                    <input name="input_availability_rate#CURRENTROW#" id="input_availability_rate#CURRENTROW#" value="#TlFormat(OEE_AVAILBILITY_RATE,0)#" class="box" style="width:40px; text-align:center" onChange="duzenle(#CURRENTROW#,#STATION_ID#,#EZGI_STATION_OOE_RATE_ID#);">
                                    <input type="hidden" id="workstation_availability_rate#currentrow#" name="workstation_availability_rate#currentrow#" value="#TlFormat(OEE_AVAILBILITY_RATE,0)#" /> 
                                </td>
                                <td style="text-align:center">
                                    <input name="input_quality_rate#CURRENTROW#" id="input_quality_rate#CURRENTROW#" value="#TlFormat(OEE_QUALITY_RATE,0)#"  class="box" style="width:40px; text-align:center" onChange="duzenle(#CURRENTROW#,#STATION_ID#,#EZGI_STATION_OOE_RATE_ID#);">
                                    <input type="hidden" id="workstation_quality_rate#currentrow#" name="workstation_quality_rate#currentrow#" value="#TlFormat(OEE_QUALITY_RATE,0)#" /> 
                                </td>
                                <!-- sil -->
                                <td align="center" width="15">
                                    <span id="red_top#CURRENTROW#" style="display:none"><img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='58718.Düzenle'>" border="0"></span>
                                    <span id="yellow_top#CURRENTROW#" style="display:none"><img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='58718.Düzenle'>" border="0"></span>
                                    <span id="blue_top#CURRENTROW#" style="display:"><img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='36411.İşlem Görmeyenler'>" border="0"></span>
                                    <span id="green_top#CURRENTROW#" style="display:none"><img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='58718.Düzenle'>" border="0"></span>
                                </td>
                                <!-- sil -->
                            </tr>
                        </cfoutput>
                         <tr>
                            <td colspan="11" style="text-align:right">
                            	<a style="cursor:pointer" onclick="guncelle();">
                                	<button style="height:25px; width:75px; background-color:silver" name="guncelle" id="guncelle"><cf_get_lang dictionary_id='57464.Güncelle'></button> 
                              	</a> 
                            </td>
                        </tr>
                    <cfelse>
                        <tr>
                            <td colspan="11"><cfif isdefined("attributes.form_submitted")><cf_get_lang dictionary_id='58486.Kayıt Bulunamadı'><cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'></cfif>!</td>
                        </tr>
                    </cfif>
                </tbody>
			</cf_grid_list>
            <cf_paging page="#attributes.page#"
                maxrows="#attributes.maxrows#"
                totalrecords="#get_workstation_all.recordcount#"
                startrow="#attributes.startrow#"
                adres="#url_str#">
            
      	</cf_box>
   	</cf_box>
</div>  
<form name="aktar_form" method="post" action="<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_upd_ezgi_workstation_oee_rate">
	<input type="hidden" name="list_type" value="<cfoutput>#attributes.list_type#</cfoutput>">
    <input type="hidden" name="keyw" value="<cfoutput></cfoutput>">
    <input type="hidden" name="active" value="<cfoutput>#attributes.is_active#</cfoutput>">
    <input type="hidden" name="convert_station_id" id="convert_station_id" value="">
    <input type="hidden" name="convert_perform_time" id="convert_perform_time" value="">
    <input type="hidden" name="convert_availability_time" id="convert_availability_time" value="">
    <input type="hidden" name="convert_quality_time" id="convert_quality_time" value="">
    <input type="hidden" name="convert_station_oee_rate_id" id="convert_station_oee_rate_id" value="">
</form>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function duzenle(currentrow,station,station_oee_rate_id)
	{
		if((document.getElementById("input_perform_rate"+currentrow).value != document.getElementById("workstation_perform_rate"+currentrow).value) || (document.getElementById("input_availability_rate"+currentrow).value != document.getElementById("workstation_availability_rate"+currentrow).value) || (document.getElementById("input_quality_rate"+currentrow).value != document.getElementById("workstation_quality_rate"+currentrow).value))
		{
			document.getElementById("green_top"+currentrow).style.display = '';	
			document.getElementById("blue_top"+currentrow).style.display = 'none';
		}
		else
		{
			document.getElementById("green_top"+currentrow).style.display = 'none';	
			document.getElementById("blue_top"+currentrow).style.display = '';
		}
	}
	function guncelle()
	{
		document.getElementById('guncelle').disabled=true;
		var convert_list_station_id ="";
		var convert_list_perform_time ="";
		var convert_list_availability_time ="";
		var convert_list_quality_time ="";
		var convert_list_station_oee_rate_id ="";
		<cfif isdefined("attributes.form_submitted")>
			<cfoutput query="get_workstation_all" STARTROW="#attributes.startrow#" MAXROWS="#attributes.maxrows#">
				var sira = #currentrow#;
				if((document.getElementById("input_perform_rate"+sira).value != document.getElementById("workstation_perform_rate"+sira).value) || (document.getElementById("input_availability_rate"+sira).value != document.getElementById("workstation_availability_rate"+sira).value) || (document.getElementById("input_quality_rate"+sira).value != document.getElementById("workstation_quality_rate"+sira).value))
				{
					convert_list_station_id += "#STATION_ID#,";
					convert_list_perform_time += document.getElementById("input_perform_rate"+sira).value+',';
					convert_list_availability_time += document.getElementById("input_availability_rate"+sira).value+',';
					convert_list_quality_time += document.getElementById("input_quality_rate"+sira).value+',';
					convert_list_station_oee_rate_id += "#EZGI_STATION_OOE_RATE_ID#,";
				}
			</cfoutput>
		</cfif>
		document.getElementById('convert_station_id').value = convert_list_station_id.substr(0,convert_list_station_id.length-1);
		document.getElementById('convert_perform_time').value = convert_list_perform_time.substr(0,convert_list_perform_time.length-1);
		document.getElementById('convert_availability_time').value = convert_list_availability_time.substr(0,convert_list_availability_time.length-1);
		document.getElementById('convert_quality_time').value = convert_list_quality_time.substr(0,convert_list_quality_time.length-1);
		document.getElementById('convert_station_oee_rate_id').value = convert_list_station_oee_rate_id.substr(0,convert_list_station_oee_rate_id.length-1);
		aktar_form.submit();
	}
	function input_control()
	{
		return true	
	}
</script> 