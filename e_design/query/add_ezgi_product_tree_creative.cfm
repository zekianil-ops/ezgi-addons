<!---
    File: add_ezgi_product_tree_creative.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 
<cfquery name="get_cat_id" datasource="#dsn1#">
	SELECT 
    	HIERARCHY
	FROM     
    	PRODUCT_CAT
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
<cfquery name="add_process" datasource="#dsn3#">
	INSERT INTO 
    	EZGI_DESIGN
    	(
        DESIGN_NAME, 
        COLOR_ID, 
        PROCESS_ID, 
        STATUS, 
        DETAIL, 
        PROCESS_STAGE,
        PRODUCT_CAT,
        PRODUCT_CAT_CODE,
        PRODUCT_CATID,
        PRODUCT_QUANTITY,
        RECORD_EMP, 
        RECORD_IP, 
        RECORD_DATE
        )
	VALUES        
    	(
        '#attributes.design_name#',
        #attributes.color_type#,
        #attributes.design_type#,
        <cfif isdefined('attributes.is_active')>1<cfelse>0</cfif>,
        <cfif len(attributes.detail)>'#attributes.detail#'<cfelse>NULL</cfif>,
        #attributes.process_stage#,
        <cfif len(attributes.product_cat)>'#attributes.product_cat#'<cfelse>NULL</cfif>,
        <cfif len(get_cat_id.HIERARCHY)>'#get_cat_id.HIERARCHY#'<cfelse>NULL</cfif>,
        <cfif len(attributes.product_catid)>#attributes.product_catid#<cfelse>NULL</cfif>,
        <cfif len(attributes.product_quantity)>#attributes.product_quantity#<cfelse>NULL</cfif>,
        #session.ep.userid#,
        '#cgi.remote_addr#',
        #now()#
        )
</cfquery>
<cfquery name="GET_MAXID" datasource="#dsn3#">
	SELECT MAX(DESIGN_ID) AS MAX_ID FROM EZGI_DESIGN WITH (NOLOCK)
</cfquery>
<cf_workcube_process 
	is_upd='1' 
	data_source='#dsn3#' 
	old_process_line='0'
	process_stage='#attributes.process_stage#' 
	record_member='#session.ep.userid#' 
	record_date='#now()#' 
	action_table='EZGI_DESIGN'
	action_column='DESIGN_ID'
	action_id='#GET_MAXID.MAX_ID#'
	action_page='#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&design_id=#GET_MAXID.MAX_ID#' 
	warning_description='E-Design: #GET_MAXID.MAX_ID# - #attributes.design_name#'>
<script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&design_id=#get_maxid.max_id#</Cfoutput>';
</script>