<!---
    File: list_ezgi_default_main.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.status" default="2">
<cfparam name="attributes.oby" default="0">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.page" default=1>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfscript>
	get_main.recordcount=0;
	get_main.query_count=0;
	if (isdefined("attributes.is_submitted"))
	{
		get_main_list_action = createObject("component", "addOns.ezgi.cfc.get_main");
		get_main_list_action.dsn3 = dsn3;
		get_main = get_main_list_action.get_main_
		(
		 	status : '#iif(isdefined("attributes.status"),"attributes.status",DE(""))#',
			oby : '#iif(isdefined("attributes.oby"),"attributes.oby",DE(""))#',
			keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
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
<cfparam name="attributes.totalrecords" default='#get_main.query_count#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search_list" action="#request.self#?fuseaction=prod.list_ezgi_default_main" method="post">
        	<input type="hidden" name="is_submitted" id="is_submitted" value="1">
            <cf_box_search>
				<cfsavecontent  variable="filtre">
					<cf_get_lang dictionary_id='57460.Filtre'>
				</cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" style="width:150px;" placeholder="#filtre#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
           		<div class="form-group medium">
                	<select name="oby" id="oby" style="width:100px;">
						<option value="0" <cfif attributes.oby eq 0>selected</cfif>><cf_get_lang dictionary_id="58924.Sıralama"></option>
						<option value="1" <cfif attributes.oby eq 1>selected</cfif>><cf_get_lang dictionary_id="58585.Kod"></option>
						<option value="2" <cfif attributes.oby eq 2>selected</cfif>><cf_get_lang dictionary_id="57897.Adı"></option>
             		</select>
              	</div>
                <div class="form-group medium">
                	<select name="status" id="status" style="width:65px;">
						<option value="1" <cfif attributes.status eq 1>selected</cfif>><cf_get_lang dictionary_id="57708.Tümü"></option>
						<option value="2" <cfif attributes.status eq 2>selected</cfif>><cf_get_lang dictionary_id="57493.Aktif"></option>
						<option value="3" <cfif attributes.status eq 3>selected</cfif>><cf_get_lang dictionary_id="57494.Pasif"></option>
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
    </cf_box>
    <cfsavecontent variable="title"><cfoutput><cf_get_lang dictionary_id="847.Default Modül Listesi"></cfoutput></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>
          	<thead>
            	<tr>
                	<th width="20"><cf_get_lang dictionary_id="58577.Sıra"></th>
            		<th><cfoutput><cf_get_lang dictionary_id="850.Modül ID"></cfoutput></th>
            		<th><cfoutput><cf_get_lang dictionary_id="849.Modül Kodu"></cfoutput></th>
           			<th><cfoutput><cf_get_lang dictionary_id="848.Default Modül Adı"></cfoutput></th>
      				<th><cf_get_lang dictionary_id='57899.Kaydeden'></th>
           			<th><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></th>
            		<!-- sil -->
            			<th width="20" class="header_icn_none">
                        	<a href="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_default_main&event=add</cfoutput>"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
            			</th>
                   	<!-- sil -->
             	</tr>
         	</thead>
          	<tbody>
            	<cfif get_main.recordcount>
                	<cfoutput query="get_main">
						<tr oncontextmenu="javascript:wrk_right_menu('MAIN_ROW_SETUP_ID',#MAIN_ROW_SETUP_ID#);return false;"> 
                        	<td>#rownum#</td>
                         	<td style="text-align:center">#MAIN_ROW_SETUP_ID#</td>
                       		<td style="text-align:center">
                             	<a href="#request.self#?fuseaction=prod.list_ezgi_default_main&event=upd&MAIN_ID=#MAIN_ROW_SETUP_ID#" class="tableyazi">#MAIN_ROW_SETUP_CODE#</a>
                         	</td>
                          	<td>#MAIN_ROW_SETUP_NAME#</td>
                         	<td>#get_emp_info(RECORD_EMP,0,0)# </td>
                          	<td style="text-align:center">#DateFormat(RECORD_DATE,dateformat_style)#</td>
                          	<!-- sil -->
                                <td>
                                    <a href="#request.self#?fuseaction=prod.list_ezgi_default_main&event=upd&MAIN_ID=#MAIN_ROW_SETUP_ID#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                                </td>
                         	<!-- sil -->
                     	</tr>
               		</cfoutput>
            	<cfelse>
               		<tr> 
                    	<td colspan="7" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
                 	</tr>
             	</cfif>
         	</tbody>
      	</cf_grid_list>
       	<cfset adres = url.fuseaction>
        <cfif len(attributes.keyword)>
        	<cfset adres = "#adres#&keyword=#attributes.keyword#">
        </cfif>
        <cfif len(attributes.oby)>
        	<cfset adres = "#adres#&oby=#attributes.oby#">
        </cfif>
        <cfif len(attributes.status)>
        	<cfset adres = "#adres#&status=#attributes.status#">
        </cfif>
        <cf_paging 
            page="#attributes.page#"
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#adres#&is_submitted=1">
    </cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;
	}
</script>