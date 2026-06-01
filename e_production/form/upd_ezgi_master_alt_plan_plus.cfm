<!---
    File: upd_ezgi_master_alt_plan_plus.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfinclude template="../../../sales/query/get_commethod_cats.cfm">
<cfquery name="get_master_alt_plan_plus" datasource="#dsn3#">
	SELECT     
    	*
	FROM         
    	EZGI_MASTER_ALT_PLAN_PLUS
	WHERE     
    	MASTER_ALT_PLAN_PLUS_ID = #attributes.master_alt_plan_plus_ID#
</cfquery>

<cfparam name="attributes.master_alt_plan_id" default="">
<cfsavecontent variable="upd_takip"><cf_get_lang dictionary_id='34561.Takip Güncelle'></cfsavecontent>
<cf_popup_box title="#upd_takip#"><!---takip--->
<table cellspacing="0" cellpadding="0" border="0" height="100%" width="100%">
<cfform name="upd_master_alt_plan_meet" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_master_alt_plan_plus">
<input type="Hidden" ID="clicked" name="clicked" value="">
<input type="Hidden" name="master_alt_plan_plus_id" id="master_alt_plan_plus_id" value="<cfoutput>#master_alt_plan_plus_id#</cfoutput>">
    <table>
        <tr>
            <td>
            	<cf_get_lang dictionary_id='34561.Bilgi Verilecek'>
                <input type="hidden" name="employee_id" id="employee_id" value="<cfoutput>#get_master_alt_plan_plus.employee_id#</cfoutput>">
                <cfif Len(get_master_alt_plan_plus.employee_id)>
					<cfset attributes.employee_id = get_master_alt_plan_plus.employee_id>
                    <cfinclude template="../../../sales/query/get_employee_name.cfm">
                    <input type="text" name="employee" id="employee" style="width:170px;" value="<cfoutput>#get_employee_name.EMPLOYEE_EMAIL#</cfoutput>">
                <cfelse>
                    <input type="text" name="employee" id="employee" style="width:150px;" value="">
                </cfif>
                <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=upd_master_alt_plan_meet.employee_id&field_emp_mail=upd_master_alt_plan_meet.employee','list');"><img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a>
                <cfsavecontent variable="please_date"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'> !</cfsavecontent>
                <cfinput type="text" name="plus_date" style="width:85px;" value="#dateformat(get_master_alt_plan_plus.plus_date,dateformat_style)#" validate="eurodate" message="#please_date#">
                <cf_wrk_date_image date_field="plus_date">
                <select name="commethod_id" id="commethod_id">
                    <option value="0"><cf_get_lang dictionary_id='58143.İletişim'></option>
                    <cfoutput query="get_commethod_cats">
                    <option value="#commethod_id#" <cfif get_master_alt_plan_plus.commethod_id eq commethod_id>selected</cfif>>#commethod#</option>
                    </cfoutput>
                </select>
                	
            </td>
        </tr>
    </table>
    <table>
        <tr>
            <td><cf_get_lang dictionary_id='58820.Başlık'></td>
            <td>
            	<input type="text" name="opp_head" id="opp_head" style="width:455px;"  value="<cfif isdefined("get_master_alt_plan_plus.subject")><cfoutput>#get_master_alt_plan_plus.subject#</cfoutput></cfif>">
            	<select name="not_id" id="not_id" style="width:60px;">
                    <option value="0" <cfif get_master_alt_plan_plus.not_id eq 0>selected</cfif>><cf_get_lang dictionary_id='57467.Not'></option>
                    <option value="1" <cfif get_master_alt_plan_plus.not_id eq 1>selected</cfif>><cf_get_lang dictionary_id='57425.Uyarı'></option>
                </select>
            </td>
        </tr>
        <tr>
        <cfset tr_topic = get_master_alt_plan_plus.plus_content>
        <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>
            <td colspan="2">
                <cfmodule
                template="../../../fckeditor/fckeditor.cfm"
                toolbarSet="WRKContent"
                basePath="/fckeditor/"
                instanceName="plus_content"
                valign="top"
                value="#tr_topic#"
                width="575"
                height="300">
            </td>
        <cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>  
            <td colspan="2">
                <cfmodule
                template="../../../fckeditor/fckeditor.cfm"
                toolbarSet="WRKContent"
                basePath="/fckeditor/"
                instanceName="plus_content"
                valign="top"
                value="#tr_topic#"
                width="575"
                height="300">
            </td>
        </cfif>					
        </tr>
    </table>
    <cf_popup_box_footer>
        <cfsavecontent variable="message"><cf_get_lang dictionary_id='35884.Güncelle ve Mail Gönder'></cfsavecontent>
        <cf_workcube_buttons 
            is_upd='0'
            insert_info='#message#'
            is_cancel='0'
            add_function="control()"
            insert_alert=''>                
        <cf_workcube_buttons 
            is_upd='1' 
            delete_page_url='#request.self#?fuseaction=prod.emptypopup_del_ezgi_master_alt_plan_plus&master_alt_plan_PLUS_ID=#master_alt_plan_plus_id#'>
    </cf_popup_box_footer>
</cfform>
</cf_popup_box>
<script type="text/javascript">
	 function control(){
		 
		 document.upd_master_alt_plan_meet.clicked.value='&email=true';
		 document.upd_master_alt_plan_meet.action = document.upd_master_alt_plan_meet.action + document.upd_master_alt_plan_meet.clicked.value;
		 
		 var aaa = document.upd_master_alt_plan_meet.employee.value;		 
		 if (((aaa == '') || (aaa.indexOf('@') == -1) || (aaa.indexOf('.') == -1) || (aaa.length < 6)) && (document.upd_master_alt_plan_meet.clicked.value == '&email=true'))
		 { 
				   alert('<cf_get_lang dictionary_id='626.Lütfen mail alanına geçerli bir mail giriniz'>!!');
				   document.upd_master_alt_plan_meet.action = "<cfoutput>#request.self#?fuseaction=prod.emptypopup_upd_ezgi_master_alt_plan_plus</cfoutput>";
				   return false;
		 }			  
		 return true;
	 }	 
</script>          