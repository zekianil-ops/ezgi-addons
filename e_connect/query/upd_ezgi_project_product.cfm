<cfif ListLen(attributes.product_id)>
	<cfquery name="del_product" datasource="#dsn#">
    	DELETE FROM EZGI_CONNECT_PROJECT_PRODUCT_ID WHERE PROJECT_ID = #attributes.project_id# 
 	</cfquery>
	<cfloop list="#attributes.product_id#" index="iid">
    	<cfquery name="add_product" datasource="#dsn#">
         	INSERT INTO
            	EZGI_CONNECT_PROJECT_PRODUCT_ID
            	(
                	PRODUCT_ID,
                  	PROJECT_ID
          		)
          	VALUES
             	(
                	#iid#,
					#attributes.project_id#
            	)
     	</cfquery>
	</cfloop>
</cfif>
<script type="text/javascript">
	alert('<cf_get_lang dictionary_id="47470.İşlem Tamamlandı">');
	window.close()
</script>
<cflocation url="#request.self#?fuseaction=prod.upd_ezgi_project_product&project_id=#attributes.project_id#" addtoken="No">