<cfset module_name="sales">
<cfinclude template="../query/get_ezgi_commethod_cats.cfm">
<cf_popup_box title="#getLang('sales',114)#"><!---takip--->
<cfform name="add_virtual_offer_meet" method="post" action="#request.self#?fuseaction=sales.emptypopup_add_ezgi_virtual_offer_plus">
    <input type="Hidden" name="virtual_offer_id" id="virtual_offer_id" value="<cfoutput>#virtual_offer_id#</cfoutput>">
    <input type="Hidden" ID="clicked" name="clicked" value="">
<div class="row form-inline">
     <div class="col col-12 form-inline">
        <div class="form-group" id="item-employee_names">
            <div class="input-group x-18">
                <input type="hidden" name="employee_id" id="employee_id" value="">
                <input type="hidden" name="employee_emails" id="employee_emails" value="">
                <input type="text" name="employee_names" id="employee_names" style="width:173px;" value="" placeholder="<cfoutput>#getLang('main',1361)#</cfoutput>">
                <span class="input-group-addon btnPointer icon-ellipsis" href="javascript://" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_check_mail&mail_id=add_virtual_offer_meet.employee_emails&names=add_virtual_offer_meet.employee_names','list');"></span>
            </div>
        </div>     
        <div class="form-group" id="item-employee_names">        
            <div class="input-group x-12">    
                <cfsavecontent variable="alert"><cf_get_lang_main no ='370.Tarih Değerinizi Kontrol Ediniz'></cfsavecontent>
                <cfinput type="text" name="plus_date" style="width:95px;" value="#dateformat(now(),dateformat_style)#" validate="#validate_style#" message="#alert#">
                <span class="input-group-addon"><cf_wrk_date_image date_field="plus_date"></span>
            </div>
        </div>        
        <div class="form-group" id="item-commethod_id">
            <div class="input-group x-18">        
                <select name="commethod_id" id="commethod_id" style="width:160px;">
                    <option value="0"><cf_get_lang_main no='63.İletişim'></option>
                    <cfoutput query="get_commethod_cats">
                    <option value="#commethod_id#">#commethod#</option>
                    </cfoutput>
                </select>
        	</div>
        </div>
    </div>
</div>    
<div class="row form-inline">
    <div class="col col-12 form-inline">
        <div class="form-group" id="item-opp_head">
            <div class="input-group x-18">
                <input type="text" name="opp_head" id="opp_head" style="width:325px;"  value="" placeholder="<cfoutput>#getLang('main',68)#</cfoutput>">
            </div>
        </div>
        <div class="form-group" id="item-pursuit_templates">
            <div class="input-group x-18">    
                <cfinclude template="../query/get_ezgi_pursuit_templates.cfm">
                <select name="pursuit_templates" id="pursuit_templates" onChange="document.add_virtual_offer_meet.action = '';document.add_virtual_offer_meet.submit();">
                    <option value="-1"><cf_get_lang no='210.Şablon Seçiniz'></option>
                    <cfoutput query="GET_PURSUIT_TEMPLATES">
                    <option value="#TEMPLATE_ID#"<cfif isDefined("attributes.pursuit_templates") and (attributes.pursuit_templates eq TEMPLATE_ID)> selected</cfif>>#TEMPLATE_HEAD#</option>
                    </cfoutput>
                </select>					
            </div>
        </div>
       <div class="form-group" id="item-plus_content">
            <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>
                    <cfmodule
                    template="/fckeditor/fckeditor.cfm"
                    toolbarSet="WRKContent"
                    basePath="/fckeditor/"
                    instanceName="plus_content"
                    valign="top"
                    value=""
                    width="550"
                    height="300">
                </div>
        <div class="form-group" id="item-plus_content">        
            <cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>  

                    <cfmodule
                    template="/fckeditor/fckeditor.cfm"
                    toolbarSet="WRKContent"
                    basePath="/fckeditor/"
                    instanceName="plus_content"
                    valign="top"
                    value=""
                    width="550"
                    height="300">
                </div>
            </cfif>	
        </div>
    </div>
<cf_popup_box_footer>
    <cfsavecontent variable="message"><cf_get_lang no='9.Kaydet ve Mail Gönder'></cfsavecontent>
    <cf_workcube_buttons is_upd='0' insert_info='#message#' is_cancel='0' add_function="control()" insert_alert=''>
    <cf_workcube_buttons is_upd='0'>
</cf_popup_box_footer>
</cfform>
</cf_popup_box>                   
<cfif isdefined("header")>
  <script type="text/javascript">
     
     document.add_virtual_offer_meet.opp_head.value = window.opener.<cfoutput>#attributes.header#</cfoutput>.value;
	 document.add_virtual_offer_meet.employee_id.value = '<cfoutput>#Session.ep.userid#</cfoutput>';
	 
	 function control(){
	 
		 document.add_virtual_offer_meet.clicked.value='&email=true';
		 document.add_virtual_offer_meet.action = "<cfoutput>#request.self#?fuseaction=sales.popup_add_ezgi_virtual_offer_plus</cfoutput>" + document.add_virtual_offer_meet.clicked.value;	 
		 
		 var aaa = document.add_virtual_offer_meet.employee_names.value;
		 if (((aaa == '') || (aaa.indexOf('@') == -1) || (aaa.indexOf('.') == -1) || (aaa.length < 6)) && (document.add_virtual_offer_meet.clicked.value == '&email=true'))
		 { 
				   alert("<cf_get_lang_main no='1072.Lütfen geçerli bir e-mail adresi giriniz'>");
				   document.add_virtual_offer_meet.action = "<cfoutput>#request.self#?fuseaction=sales.popup_add_ezgi_virtual_offer_plus</cfoutput>";  
				   return false;
		 }				  
		 
		 return true;
	 }	 
	 
	<cfset attributes.pursuit_template_id = -1>
	<cfif isDefined("attributes.pursuit_templates")>
		<cfset attributes.pursuit_template_id = attributes.pursuit_templates>
	</cfif>
	<cfinclude template="../query/get_ezgi_pursuit_templates.cfm">	
	document.all.plus_content.value = '<cfoutput>#GET_PURSUIT_TEMPLATES.TEMPLATE_CONTENT#</cfoutput>';	 
	</script>
</cfif>

