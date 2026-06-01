<!---
    File: upd_ezgi_product_tree_creative.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfquery name="get_cat_id" datasource="#dsn1#">
	SELECT 
    	HIERARCHY
	FROM     
    	PRODUCT_CAT WITH (NOLOCK)
	WHERE  
    	PRODUCT_CATID = #attributes.product_catid#
</cfquery>
<cfif not get_cat_id.recordcount>
	<script type="text/javascript">
		alert("Seçtiğiniz Kategori Bulunamadı!");
		window.history.go(-1);
	</script>
    <cfabort>
</cfif>
<cfquery name="upd_process" datasource="#dsn3#">
	UPDATE 
    	EZGI_DESIGN
   	SET
        DESIGN_NAME = '#attributes.design_name#',
        COLOR_ID = #attributes.color_type#,
        PROCESS_ID = #attributes.design_type#, 
        STATUS = <cfif isdefined('attributes.is_active')>1<cfelse>0</cfif>, 
		IS_PROTOTIP = <cfif isdefined('attributes.is_prototip')>1<cfelse>0</cfif>,
        DETAIL = <cfif len(attributes.detail)>'#attributes.detail#'<cfelse>NULL</cfif>,
        PROCESS_STAGE = #attributes.process_stage#,
        PRODUCT_CAT = <cfif len(attributes.product_cat)>'#attributes.product_cat#'<cfelse>NULL</cfif>,
        PRODUCT_CAT_CODE = <cfif len(get_cat_id.HIERARCHY)>'#get_cat_id.HIERARCHY#'<cfelse>NULL</cfif>,
        PRODUCT_CATID = <cfif len(attributes.product_catid)>#attributes.product_catid#<cfelse>NULL</cfif>,
        PRODUCT_QUANTITY = <cfif len(attributes.product_quantity)>#attributes.product_quantity#<cfelse>NULL</cfif>,
        UPDATE_EMP = #session.ep.userid#, 
        UPDATE_IP = '#cgi.remote_addr#',
        UPDATE_DATE = #now()#
   	WHERE
    	DESIGN_ID =	#attributes.design_id#
</cfquery>
<cf_workcube_process 
		is_upd='1' 
		old_process_line='0'
        data_source='#dsn3#'
		process_stage='#attributes.process_stage#' 
		record_member='#session.ep.userid#' 
		record_date='#now()#' 
		action_table='EZGI_DESIGN'
		action_column='DESIGN_ID'
		action_id='#attributes.design_id#'
		action_page='#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&design_id=#attributes.design_id#' 
		warning_description='Mobilya Tasarım'>
<script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&design_id=#attributes.design_id#</Cfoutput>';
</script>