<!---
    File: upd_ezgi_private_product_tree_creative.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="upd_process" datasource="#dsn3#">
	UPDATE 
    	EZGI_DESIGN
   	SET
        STATUS = <cfif isdefined('attributes.is_active')>1<cfelse>0</cfif>, 
        DETAIL = <cfif len(attributes.detail)>'#attributes.detail#'<cfelse>NULL</cfif>,
        CONSUMER_ID = <cfif len(attributes.consumer_id)>#attributes.consumer_id#<cfelse>NULL</cfif>, 
        COMPANY_ID = <cfif len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>, 
        MEMBER_TYPE = <cfif len(attributes.member_type)>'#attributes.member_type#'<cfelse>NULL</cfif>,
        MEMBER_NAME = <cfif len(attributes.member_name)>'#attributes.member_name#'<cfelse>NULL</cfif>,
        PROCESS_STAGE = #attributes.process_stage#,
        UPDATE_EMP = #session.ep.userid#, 
        UPDATE_IP = '#cgi.remote_addr#',
        UPDATE_DATE = #now()#
   	WHERE
    	DESIGN_ID =	#attributes.design_id#
</cfquery>
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd&design_id=#attributes.design_id#" addtoken="no">