  <!---
    File: add_ezgi_default_measure.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->  

<cfquery name="get_name_control" datasource="#dsn3#">
	SELECT * FROM EZGI_VIRTUAL_OFFER_ROW_MEASURE WITH (NOLOCK) WHERE MEASURE_NAME = '#attributes.default_name#'
</cfquery>
<cfif get_name_control.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='57477.Hatalı Veri'> : <cf_get_lang dictionary_id='36572.Ölçü Adı Düzenle'>!");
		window.history.go(-1);
	</script>
	<cfabort>
</cfif>
<cftransaction>
    <cfquery name="add_measure_default" datasource="#dsn3#">
    	INSERT INTO 
        	EZGI_VIRTUAL_OFFER_ROW_MEASURE
          	(
            	MEASURE_CODE,
            	MEASURE_NAME,  
                IS_ACTIVE,
                RECORD_EMP, 
               	RECORD_IP,
              	RECORD_DATE
          	)
		VALUES        
        	(
                '#attributes.default_code#',
                '#attributes.default_name#',
                <cfif isdefined('attributes.status')>1<cfelse>0</cfif>,
                #session.ep.userid#,
                '#cgi.remote_addr#',
                #now()#
            )
    </cfquery>
</cftransaction>
<cfquery name="get_max" datasource="#dsn3#">
	SELECT MAX(MEASURE_ID) AS MAX_ID FROM EZGI_VIRTUAL_OFFER_ROW_MEASURE WITH (NOLOCK)
</cfquery>
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_default_measure&event=upd&measure_id=#get_max.MAX_ID#" addtoken="No">