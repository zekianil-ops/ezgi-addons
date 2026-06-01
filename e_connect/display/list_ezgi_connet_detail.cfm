<cfset module_name="sales">
<cfset CONNECT_ID = attributes.CONNECT_ID>
<cfquery name="get_connect" datasource="#DSN3#">
	SELECT CONSUMER_ID,PARTNER_ID,EMPLOYEE_ID,COMPANY_ID,'' AS OFFER_TO_PARTNER,CONNECT_HEAD, PROJECT_ID  FROM EZGI_CONNECT WHERE CONNECT_ID = #attributes.connect_id#
</cfquery>
<cfif len(get_connect.consumer_id)>
  <cfset contact_type = "c">
  <cfset contact_id = get_connect.consumer_id>
<cfelseif len(get_connect.partner_id)>
  <cfset contact_type = "p">
  <cfset contact_id = get_connect.partner_id>
<cfelseif len(get_connect.COMPANY_ID)>
  <cfset contact_type = "comp">
  <cfset contact_id = get_connect.COMPANY_ID>
<cfelseif len(get_connect.EMPLOYEE_ID)>
  <cfset contact_type = "e">
  <cfset contact_id = get_connect.EMPLOYEE_ID>
<cfelseif len(listsort(get_connect.OFFER_TO_PARTNER,"numeric"))>
  <cfset contact_type = "p">
  <cfset contact_id = listfirst(listsort(get_connect.OFFER_TO_PARTNER,"numeric"))>
</cfif>
<cfinclude template="../../../../v16/objects/query/get_account_simple.cfm">
<cf_popup_box title="#getLang('sales',62)#">
<form name="upd_virtual_offer_product">
    <input type="hidden" value="<cfoutput>#get_connect.CONNECT_HEAD#</cfoutput>" name="CONNECT_HEAD" id="CONNECT_HEAD">
</form>
<cf_box>
<div class="row">
    <div class="col col-12">
    	<cf_get_workcube_form_generator design="3" action_type='12' related_type='12' action_type_id='#CONNECT_ID#'>
  	</div>
</div>
</cf_box>
<cfset my_module_id = 13>
<cfset my_asset_cat_id = -12>
<cfset main_column_name = 'CONNECT_ID'>
<cfset attributes.action_id = CONNECT_ID>
<cf_box>
<div class="row">
    <div class="col col-12">
        <cf_get_workcube_asset asset_cat_id="-12" company_id="#session.ep.company_id#" module_id='13' action_section='OFFER_ID' action_id='#attributes.action_id#'>
    </div>
</div>
</cf_box>