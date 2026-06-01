<!---
    File: add_ezgi_virtual_offer.cfm
    Folder: Add_Ons\ezgi\e_sales\form
    Author: Ezgi Yazılım
    Date: 01/01/2022
    Description:
--->
<cfparam name="attributes.branch_id" default="#listgetat(session.ep.user_location,2,'-')#">
<cfparam name="attributes.country_id1" default="">
<cfparam name="attributes.sales_zone_id" default="">
<cfparam name="attributes.consumer_reference_code" default="">
<cfparam name="attributes.sales_reference_code" default="">
<cfparam name="attributes.partner_reference_code" default="">
<cfparam name="attributes.sales_partner_id" default="">
<cfparam name="attributes.ship_method" default="">
<cfparam name="attributes.PAYMETHOD_ID" default="">
<cfparam name="attributes.PROCESS_STAGE" default="">
<cfparam name="attributes.order_employee_id" default="#session.ep.userid#">
<cfset attributes.is_cost_discount = 1>
<cfset attributes.kilit_stage = 0>
<cfinclude template="../../../../v16/sales/query/get_priorities.cfm">
<cfset attributes.ref_company_id = "">
<cfset attributes.ref_member_type = "">
<cfset attributes.ref_member_id = "">
<cfset process_action = 'virtual_offer'>
<cfset process_fuse = 'add'>
<cfquery name="GET_DEFAULTS" datasource="#dsn3#">
	SELECT * FROM EZGI_VIRTUAL_OFFER_DEFAULTS
</cfquery>
<cfquery name="get_branch" datasource="#dsn#">
	SELECT        
    	BRANCH_ID, BRANCH_NAME
	FROM            
    	BRANCH
	WHERE   
    	1=1     
        <cfif session.ep.ISBRANCHAUTHORIZATION eq 1>
    		AND BRANCH_ID IN
                  	(
                    	SELECT        
                        	BRANCH_ID
                    	FROM            
                        	EMPLOYEE_POSITION_BRANCHES
                    	WHERE        
                        	POSITION_CODE = #session.ep.POSITION_CODE# AND 
                            DEPARTMENT_ID IS NULL
                   	)
       	</cfif>
      	AND COMPANY_ID = #session.ep.company_id# 
        AND BRANCH_STATUS = 1
</cfquery>
<cfquery name="get_money" datasource="#dsn#">
	SELECT MONEY_ID,MONEY, RATE2, RATE1 FROM SETUP_MONEY WHERE PERIOD_ID = #session.ep.period_id#
</cfquery>
<cfoutput query="get_money">
  	<cfset 'RATE1_#MONEY#' = RATE1>
  	<cfset 'RATE2_#MONEY#' = RATE2>
</cfoutput>
<cfquery name="get_virtual_offer_money_selected" dbtype="query">
	SELECT 
     	MONEY as MONEY_TYPE,
        RATE2
	FROM     
    	get_money
	WHERE
     	MONEY = '#session.ep.money#'
</cfquery>
<cfif not isdefined('attributes.cpy_virtual_offer_id')>
  	<cfset attributes.virtual_offer_date = DateFormat(now(),'dd/mm/yyyy')>
 	<cfset attributes.ship_date = DateFormat(now(),'dd/mm/yyyy')>
  	<cfset attributes.deliverdate = DateFormat(now(),'dd/mm/yyyy')>
	<cfset attributes.finishdate = ''>
    <cfset attributes.virtual_offer_head = "Teklifimiz">
    <cfparam name="attributes.deliver_dept_name" default="">
    <cfparam name="attributes.deliver_dept_id" default="">
    <cfparam name="attributes.deliver_loc_id" default="">
    <cfparam name="attributes.virtual_offer_status" default="1">
    <cfif not (isdefined("attributes.virtual_offer_employee_id") and Len(attributes.virtual_offer_employee_id))>
        <cfset attributes.virtual_offer_employee_id = session.ep.userid>
    </cfif>
    <cfparam name="attributes.basket_due_value_date_" default= "#DateFormat(now(),'dd/mm/yyyy')#">
<cfelse>
	<cfquery name="get_virtual_offer" datasource="#dsn3#">
        SELECT * FROM EZGI_VIRTUAL_OFFER WHERE VIRTUAL_OFFER_ID = #attributes.cpy_order_id#
    </cfquery>
    <cfquery name="get_virtual_offer_row" datasource="#dsn3#">
        SELECT 
        	*, 
            ISNULL(QUANTITY,0) AS AMOUNT ,
            ISNULL(PRICE,0) AS SALES_PRICE, 
            ISNULL(OTHER_MONEY,'#session.ep.money#') AS MONEY, 
            ISNULL(DISCOUNT_1,0) AS DISCOUNT,
            0 AS VIRTUAL_OFFER_ID
     	FROM 
        	EZGI_VIRTUAL_OFFER_ROW E
      	WHERE 
        	VIRTUAL_OFFER_ID = #attributes.cpy_order_id#
    </cfquery>
    <cfset virtual_offer_row_id_list =''>
    <cfset attributes.virtual_offer_head = "Teklifimiz">
    <cfset attributes.priority_id = get_virtual_offer.priority_id>
    <cfset attributes.project_id = get_virtual_offer.PROJECT_ID>
    <cfset attributes.virtual_offer_date = DateFormat(now(),'dd/mm/yyyy')>
 	<cfset attributes.ship_date = DateFormat(now(),'dd/mm/yyyy')>
  	<cfset attributes.deliverdate = DateFormat(now(),'dd/mm/yyyy')>
    <cfset attributes.finishdate = DateFormat(now(),'dd/mm/yyyy')>
    <cfset attributes.deliver_dept_name="">
    <cfset attributes.deliver_dept_id= get_virtual_offer.DELIVER_DEPT_ID>
    <cfset attributes.deliver_loc_id= get_virtual_offer.LOCATION_ID>
    <cfset attributes.virtual_offer_status = ''>
    <cfif len(get_virtual_offer.company_id)>
        <cfset attributes.company_id = get_virtual_offer.company_id>
        <cfset attributes.partner_id = get_virtual_offer.partner_id>
        <cfset attributes.member_type = get_virtual_offer.member_type>
    </cfif>
    <cfparam name="attributes.basket_due_value_date_" default= "#DateFormat(now(),'dd/mm/yyyy')#">
</cfif>
<cfset get_virtual_offer_row.recordcount =0>
<table class="dph">
  	<tr>
        <td class="dpht">
            <a href="javascript:gizle_goster_basket(detail_inv_menu);">&raquo;</a><cf_get_lang dictionary_id="801.Sanal Teklif"> <cf_get_lang dictionary_id="44630.Ekle">
        </td>
        <td class="dphb">
            <table align="right">
                <tr><td></td></tr>
            </table>
        </td>
        <td width="15" style="text-align:right;"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=objects.add_virtual_offer_from_file&from_where=4"><img src="images/barcode_phl.gif" border="0"></a></td>
        <td id="member_page" style="display:none;" width="15">
            <a href="javascript://" onClick="open_member_page();"><img src="/images/cubexport.gif" align="absmiddle" title="<cf_get_lang no='256.Ek Bilgi'>" border="0"></a>
        </td>
        <td id="member_page_1" style="display:none;" width="15">
            <a href="javascript://" onClick="open_contract_page();"><img src="/images/contract.gif" align="absmiddle" title="<cf_get_lang no='607.Alış-Satış Koşulları'>" border="0"></a>
        </td>
  	</tr>
</table>
<cfform name="form_basket" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_virtual_offer">
	<cfinput type="hidden" name="virtual_offer_money" id="virtual_offer_money" value="#get_virtual_offer_money_selected.MONEY_TYPE#">
    <cfinput type="hidden" name="virtual_offer_rate2" id="virtual_offer_rate2" value="#TlFormat(get_virtual_offer_money_selected.RATE2,4)#">
	<cf_basket_form id="detail_inv_menu">
		<cfinclude template="header_ezgi_virtual_offer.cfm">
    </cf_basket_form>
	<cfinclude template="basket_ezgi_virtual_offer.cfm">
	<cfinclude template="footer_ezgi_virtual_offer.cfm">
</cfform>