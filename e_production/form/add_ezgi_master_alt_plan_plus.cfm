<!---
    File: add_ezgi_master_alt_plan_plus.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cf_get_lang_set module_name="prod">
<cfinclude template="../../../../V16/sales/query/get_commethod_cats.cfm">
<cf_popup_box title="Takip"><!---takip--->
<cfform name="add_master_alt_plan_meet" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_master_alt_plan_plus">
    <input type="Hidden" name="master_alt_plan_id" id="master_alt_plan_id" value="<cfoutput>#master_alt_plan_id#</cfoutput>">
    <input type="Hidden" ID="clicked" name="clicked" value="">
    <table>
        <tr>
            <td><cf_get_lang dictionary_id='34561.Bilgi Verilecek'>
                <input type="hidden" name="employee_id" id="employee_id" value="">
                <input type="hidden" name="employee_emails" id="employee_emails" value="">
                <input type="text" name="employee_names" id="employee_names" style="width:173px;" value="">
                <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_check_mail&mail_id=add_master_alt_plan_meet.employee_emails&names=add_master_alt_plan_meet.employee_names','list');"><img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a>
                <cfsavecontent variable="alert"><cf_get_lang dictionary_id ='1050.Tarih Değerinizi Kontrol Ediniz'></cfsavecontent>
                <cfinput type="text" name="plus_date" style="width:95px;" value="#dateformat(now(),dateformat_style)#" validate="eurodate" message="#alert#">
                <cf_wrk_date_image date_field="plus_date">
                <select name="commethod_id" id="commethod_id" style="width:140px;">
                    <option value="0"><cf_get_lang dictionary_id='58143.İletişim'></option>
                    <cfoutput query="get_commethod_cats">
                    <option value="#commethod_id#">#commethod#</option>
                    </cfoutput>
                </select>
        	</td>
        </tr>
    </table>
    <table>
        <tr>
            <td><cf_get_lang dictionary_id='58820.Başlık'></td>
            <td>
                <input type="text" name="opp_head" id="opp_head" style="width:325px;"  value="">
                <cfinclude template="../../../../V16/sales/query/get_pursuit_templates.cfm">
                <select name="pursuit_templates" id="pursuit_templates" onChange="document.add_master_alt_plan_meet.action = '';document.add_master_alt_plan_meet.submit();">
                    <option value="-1"><cf_get_lang dictionary_id='34185.Şablon Seçiniz'></option>
                    <cfoutput query="GET_PURSUIT_TEMPLATES">
                    <option value="#TEMPLATE_ID#"<cfif isDefined("attributes.pursuit_templates") and (attributes.pursuit_templates eq TEMPLATE_ID)> selected</cfif>>#TEMPLATE_HEAD#</option>
                    </cfoutput>
                </select>	
                <select name="not_id" id="not_id" style="width:60px;">
                    <option value="0"><cf_get_lang dictionary_id='57467.Not'></option>
                    <option value="1"><cf_get_lang dictionary_id='57425.Uyarı'></option>
                </select>				
            </td>
        </tr>
        <tr>
            <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>
                <td colspan="2">
                    <cfmodule
                    template="../../../../fckeditor/fckeditor.cfm"
                    toolbarSet="WRKContent"
                    basePath="/fckeditor/"
                    instanceName="plus_content"
                    valign="top"
                    value=""
                    width="550"
                    height="300">
                </td>
            <cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>  
                <td colspan="2">
                    <cfmodule
                    template="../../../../fckeditor/fckeditor.cfm"
                    toolbarSet="WRKContent"
                    basePath="/fckeditor/"
                    instanceName="plus_content"
                    valign="top"
                    value=""
                    width="550"
                    height="300">
                </td>
            </cfif>	
        </tr>
    </table>
<cf_popup_box_footer>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id='33689.Kaydet ve Mail Gönder'></cfsavecontent>
    <cf_workcube_buttons is_upd='0' insert_info='#message#' is_cancel='0' add_function="control()" insert_alert=''>
    <cf_workcube_buttons is_upd='0'>
</cf_popup_box_footer>
</cfform>
</cf_popup_box>                   
<cfif isdefined("header")>
  <script type="text/javascript">
     
     document.add_master_alt_plan_meet.opp_head.value = window.opener.<cfoutput>#attributes.header#</cfoutput>.value;
	 document.add_master_alt_plan_meet.employee_id.value = '<cfoutput>#Session.ep.userid#</cfoutput>';
	 
	 function control(){
	 
		 document.add_master_alt_plan_meet.clicked.value='&email=true';
		 document.add_master_alt_plan_meet.action = "<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_master_alt_plan_plus</cfoutput>" + document.add_master_alt_plan_meet.clicked.value;	 
		 
		 var aaa = document.add_master_alt_plan_meet.employee_names.value;
		 if (((aaa == '') || (aaa.indexOf('@') == -1) || (aaa.indexOf('.') == -1) || (aaa.length < 6)) && (document.add_master_alt_plan_meet.clicked.value == '&email=true'))
		 { 
				   alert("<cf_get_lang dictionary_id='58484.Lütfen geçerli bir e-posta adresi giriniz'>");
				   document.add_master_alt_plan_meet.action = "<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_master_alt_plan_plus</cfoutput>";  
				   return false;
		 }				  
		 
		 return true;
	 }	 
	 
	<cfset attributes.pursuit_template_id = -1>
	<cfif isDefined("attributes.pursuit_templates")>
		<cfset attributes.pursuit_template_id = attributes.pursuit_templates>
	</cfif>
	<cfinclude template="../../../../V16/sales/query/get_pursuit_templates.cfm">	
	document.all.plus_content.value = '<cfoutput>#GET_PURSUIT_TEMPLATES.TEMPLATE_CONTENT#</cfoutput>';	 
	</script>
</cfif>
