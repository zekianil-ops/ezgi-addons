<cfset module_name="sales">
<cfset VIRTUAL_OFFER_ID = attributes.VIRTUAL_OFFER_ID>
<cfquery name="get_virtual_offer" datasource="#DSN3#">
	SELECT CONSUMER_ID,PARTNER_ID,EMPLOYEE_ID,COMPANY_ID,'' AS OFFER_TO_PARTNER,VIRTUAL_OFFER_HEAD, PROJECT_ID  FROM EZGI_VIRTUAL_OFFER WHERE VIRTUAL_OFFER_ID = #VIRTUAL_OFFER_ID#
</cfquery>
<cfif len(get_virtual_offer.consumer_id)>
  <cfset contact_type = "c">
  <cfset contact_id = get_virtual_offer.consumer_id>
<cfelseif len(get_virtual_offer.partner_id)>
  <cfset contact_type = "p">
  <cfset contact_id = get_virtual_offer.partner_id>
<cfelseif len(get_virtual_offer.COMPANY_ID)>
  <cfset contact_type = "comp">
  <cfset contact_id = get_virtual_offer.COMPANY_ID>
<cfelseif len(get_virtual_offer.EMPLOYEE_ID)>
  <cfset contact_type = "e">
  <cfset contact_id = get_virtual_offer.EMPLOYEE_ID>
<cfelseif len(listsort(get_virtual_offer.OFFER_TO_PARTNER,"numeric"))>
  <cfset contact_type = "p">
  <cfset contact_id = listfirst(listsort(get_virtual_offer.OFFER_TO_PARTNER,"numeric"))>
</cfif>
<cfinclude template="../../../../v16/objects/query/get_account_simple.cfm">
<cf_popup_box title="#getLang('sales',62)#">
<form name="upd_virtual_offer_product">
    <input type="hidden" value="<cfoutput>#get_virtual_offer.virtual_offer_head#</cfoutput>" name="virtual_offer_head" id="virtual_offer_head">
</form>
<cf_medium_list>
	<cfinclude template="../query/get_virtual_offer_pluses.cfm">
	<thead>
    	<tr>
        	<th><cf_get_lang no="62.takip"></th>
            <th style="text-align:center" width="15"><a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=sales.popup_add_ezgi_virtual_offer_plus&virtual_offer_id=#virtual_offer_id#&header=upd_virtual_offer_product.virtual_offer_head&contact_mail=#get_account_simple.email#&contact_person=#get_account_simple.name# #get_account_simple.surname#</cfoutput>','medium');"><img src="/images/plus_list.gif"></a></th>
        </tr>
    </thead>
	<cfif get_virtual_offer_pluses.recordcount> 
        <tbody>
			<cfoutput query="get_virtual_offer_pluses">
            <tr>
                <td><cfif len(subject)>#subject#<cfelse><cf_get_lang_main no='68.Başlık'></cfif></td>
                <td style="text-align:center" width="15"><a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_virtual_offer_plus&virtual_offer_plus_ID=#virtual_offer_plus_ID#','medium');"><img src="/images/update_list.gif"></a></td>
            </tr>
            <tr class="nohover"> 
                <td colspan="2">
                    <b><cf_get_lang_main no='330.tarih'>:</b> #dateformat(plus_date,dateformat_style)#
                    <cfif len(employee_id)>
                    <b>&nbsp;&nbsp;<cf_get_lang_main no='157.görevli'>:</b> 
                    #get_emp_info(employee_id,0,0)#</cfif>
                    <cfif len(commethod_id)>
                      &nbsp;&nbsp; <b><cf_get_lang_main no='731.iletişim'>:</b> 
                    <cfset attributes.commethod_id = commethod_id>
                    <cfinclude template="../query/get_ezgi_commethod.cfm">
                    #get_commethod.commethod#<br/>
                    </cfif>
                    <br/><br/>
                    #plus_content#
                </td>
            </tr>
        </tbody>
		</cfoutput>
    <cfelse>
    	<tbody>
            <tr> 
                <td colspan="2"><cf_get_lang_main no='72.Kayıt Bulunamadı'>!</td>
            </tr>
        </tbody>
	</cfif>
	<table width="100%" align="center">
		<tr>
			<td><cf_get_workcube_form_generator design="3" action_type='12' related_type='12' action_type_id='#virtual_offer_id#'></td>
		</tr>
	</table>
	</cf_medium_list>
</cf_popup_box>
<cfset my_module_id = 13>
<cfset my_asset_cat_id = -12>
<cfset main_column_name = 'VIRTUAL_OFFER_ID'>
<cfset attributes.action_id = virtual_offer_id>
<div class="row">
    <div class="col col-12">
        <cf_get_workcube_asset asset_cat_id="-12" company_id="#session.ep.company_id#" module_id='13' action_section='OFFER_ID' action_id='#attributes.action_id#'>
    </div>
</div>