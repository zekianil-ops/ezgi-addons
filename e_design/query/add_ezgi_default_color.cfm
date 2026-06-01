  <!---
    File: add_ezgi_default_color.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->  

<cfquery name="get_name_control" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WHERE COLOR_NAME = '#attributes.default_name#'
</cfquery>
<cfif get_name_control.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='255.Aynı İsimde Renk Mevcut. Lütfen Düzeltiniz'>!");
		window.history.go(-1);
	</script>
	<cfabort>
</cfif>
<cfquery name="get_name_control" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WHERE PROP_CODE = '#attributes.special_code#'
</cfquery>
<cfif get_name_control.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='47369.Seçilen Kod Mevcut'> <cf_get_lang dictionary_id='407.Lütfen Düzeltiniz'>!");
		window.history.go(-1);
	</script>
	<cfabort>
</cfif>
<cfquery name="get_default" datasource="#dsn3#">
    SELECT DEFAULT_COLOR_PROPERTY_ID FROM EZGI_DESIGN_DEFAULTS
</cfquery>
<cftransaction>
    <cfquery name="add_color_default" datasource="#dsn1#">
    	INSERT INTO 
        	PRODUCT_PROPERTY_DETAIL
          	(
            	PRPT_ID, 
                PROPERTY_DETAIL, 
                IS_ACTIVE, 
                PROPERTY_DETAIL_CODE, 
                RELATED_STOCK_ID,
                PROP_CODE,
                IS_FLAG,
                RECORD_EMP, 
               	RECORD_IP,
              	RECORD_DATE
          	)
		VALUES        
        	(
                #get_default.DEFAULT_COLOR_PROPERTY_ID#,
                '#attributes.default_name#',
                <cfif isdefined('attributes.status')>1<cfelse>0</cfif>,
                '#attributes.default_code#',
                #attributes.stock_id#,
                '#attributes.special_code#',
                <cfif isdefined('attributes.is_pattern')>1<cfelse>0</cfif>,
                #session.ep.userid#,
                '#cgi.remote_addr#',
                #now()#
            )
    </cfquery>
</cftransaction>
<cfquery name="get_max" datasource="#dsn1#">
	SELECT MAX(PROPERTY_DETAIL_ID) AS MAX_ID FROM PRODUCT_PROPERTY_DETAIL WITH (NOLOCK)
</cfquery>
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_default_color&event=upd&color_id=#get_max.MAX_ID#" addtoken="No">