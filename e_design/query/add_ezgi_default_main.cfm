  <!---
    File: add_ezgi_default_main.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->  

<cfquery name="get_name_control" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_MAIN_ROW_SETUP WITH (NOLOCK) WHERE MAIN_ROW_SETUP_NAME = '#attributes.default_type#'
</cfquery>
<cfif get_name_control.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='256.Aynı İsimde Modül Mevcut. Lütfen Düzeltiniz'>!");
		window.history.go(-1);
	</script>
	<cfabort>
</cfif>
<cftransaction>
    <cfquery name="get_piece_default" datasource="#dsn3#">
        INSERT INTO              
            EZGI_DESIGN_MAIN_ROW_SETUP
            (
                 MAIN_ROW_SETUP_NAME, 
                 MAIN_ROW_SETUP_CODE, 
                 STATUS, 
                 RECORD_EMP, 
                 RECORD_IP,
                 RECORD_DATE
            )
        VALUES        
            (
                '#attributes.default_type#',
                '#attributes.default_code#',
                <cfif isdefined('attributes.status')>1<cfelse>0</cfif>,
                #session.ep.userid#,
                '#cgi.remote_addr#',
                #now()#
            )
    </cfquery>
    <cfquery name="getmax" datasource="#dsn3#">
    	SELECT MAX(MAIN_ROW_SETUP_ID) MAXID FROM EZGI_DESIGN_MAIN_ROW_SETUP WITH (NOLOCK)
    </cfquery>
</cftransaction>
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_default_main&event=upd&main_id=#getmax.maxid#" addtoken="No">