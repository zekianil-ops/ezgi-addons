<cfset module_name="sales">
<cfinclude template="../query/get_ezgi_commethod_cats.cfm">
<cfinclude template="../query/get_ezgi_virtual_offer_plus.cfm">
<cfparam name="attributes.virtual_offer_id" default="">
<cfsavecontent variable="right_">
	<a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=sales.popup_add_ezgi_virtual_offer_plus&virtual_offer_id=#attributes.virtual_offer_id#</cfoutput>','page');"><img src="/images/plus1.gif" title="<cf_get_lang_main no='170.Ekle'>"></a>
</cfsavecontent>
<cf_popup_box title="#getLang('sales',114)#" right_images="#right_#"><!---takip--->
<table cellspacing="0" cellpadding="0" border="0" height="100%" width="100%">
<cfform name="upd_virtual_offer_meet" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_ezgi_virtual_offer_plus">
<input type="Hidden" ID="clicked" name="clicked" value="">
<input type="Hidden" name="virtual_offer_plus_id" id="virtual_offer_plus_id" value="<cfoutput>#virtual_offer_plus_id#</cfoutput>">
    <table>
        <tr>
            <td>
            	<cf_get_lang_main no='1361.Bilgi Verilecek'>
                <input type="hidden" name="employee_id" id="employee_id" value="<cfoutput>#get_virtual_offer_plus.employee_id#</cfoutput>">
                <cfif Len(get_virtual_offer_plus.employee_id)>
					<cfset attributes.employee_id = get_virtual_offer_plus.employee_id>
                    <cfinclude template="../../../../v16/SALES/query/get_employee_name.cfm">
                    <input type="text" name="employee" id="employee" style="width:170px;" value="<cfoutput>#get_employee_name.EMPLOYEE_EMAIL#</cfoutput>">
                <cfelse>
                    <input type="text" name="employee" id="employee" style="width:150px;" value="">
                </cfif>
                <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=upd_virtual_offer_meet.employee_id&field_emp_mail=upd_virtual_offer_meet.employee','list');"><img src="/images/plus_thin.gif"  align="absmiddle" border="0"></a>
                <cfinput type="text" name="plus_date" style="width:85px;" value="#dateformat(get_virtual_offer_plus.plus_date,dateformat_style)#" validate="#validate_style#" message="Tarih Giriniz !">
                <cf_wrk_date_image date_field="plus_date">
                <select name="commethod_id" id="commethod_id">
                    <option value="0"><cf_get_lang_main no='731.iletişim'></option>
                    <cfoutput query="get_commethod_cats">
                    <option value="#commethod_id#" <cfif get_virtual_offer_plus.commethod_id eq commethod_id>selected</cfif>>#commethod#</option>
                    </cfoutput>
                </select>
            </td>
        </tr>
    </table>
    <table>
        <tr>
            <td><cf_get_lang_main no='68.Başlık'></td>
            <td><input type="text" name="opp_head" id="opp_head" style="width:455px;"  value="<cfif isdefined("get_virtual_offer_plus.subject")><cfoutput>#get_virtual_offer_plus.subject#</cfoutput></cfif>">
            </td>
        </tr>
        <tr>
        <cfset tr_topic = get_virtual_offer_plus.plus_content>
        <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>
            <td colspan="2">
                <cfmodule
                template="/fckeditor/fckeditor.cfm"
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
                template="/fckeditor/fckeditor.cfm"
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
        <cfsavecontent variable="message"><cf_get_lang no='10.Güncelle ve Mail Gönder'></cfsavecontent>
        <cf_workcube_buttons 
            is_upd='0'
            insert_info='#message#'
            is_cancel='0'
            add_function="control()"
            insert_alert=''>                
        <cf_workcube_buttons 
            is_upd='1' 
            delete_page_url='#request.self#?fuseaction=sales.emptypopup_del_ezgi_virtual_offer_plus&VIRTUAL_OFFER_PLUS_ID=#virtual_offer_plus_id#'>
    </cf_popup_box_footer>
</cfform>
</cf_popup_box>
<script type="text/javascript">
	 
	 function control(){
		 
		 document.upd_virtual_offer_meet.clicked.value='&email=true';
		 document.upd_virtual_offer_meet.action = document.upd_virtual_offer_meet.action + document.upd_virtual_offer_meet.clicked.value;
		 
		 var aaa = document.upd_virtual_offer_meet.employee.value;		 
		 if (((aaa == '') || (aaa.indexOf('@') == -1) || (aaa.indexOf('.') == -1) || (aaa.length < 6)) && (document.upd_virtual_offer_meet.clicked.value == '&email=true'))
		 { 
				   alert('Lütfen mail alanına geçerli bir mail giriniz!!');
				   document.upd_virtual_offer_meet.action = "<cfoutput>#request.self#?fuseaction=sales.popup_upd_ezgi_virtual_offer_plus</cfoutput>";
				   return false;
		 }			  
		 return true;
	 }	 

</script>          
