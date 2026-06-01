<cfquery name="KONTROL" datasource="#DSN3#">
	SELECT 
		PRICE_CAT 
	FROM 
		PRICE_CAT
	WHERE 
		PRICE_CAT = '#form.price_cat#' AND
		PRICE_CAT_STATUS = 1
</cfquery>
<cfif kontrol.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang no ='878.Bu İsim Kullanılıyor Lütfen Kontrol Ediniz'> !");
		window.location.href="<cfoutput>#request.self#?fuseaction=product.list_price_cat</cfoutput>";
	</script>
	<cfabort>
</cfif>
<cf_date tarih = "form.startdate">
<cfif isdefined('target_due_date') and isdate(target_due_date)><cf_date tarih = "attributes.target_due_date"></cfif>
<cflock name="#CREATEUUID()#" timeout="20">
	<cftransaction>
		<cfquery name="ADD_PRICE_CAT" datasource="#DSN3#" result="MAX_ID">
        	INSERT INTO 
            	EZGI_VIRTUAL_OFFER_PRICE_LIST
           		(
                	PRICE_CAT, 
                    STATUS, 
                    VALIDATE, 
                    COMPANY_CATS,
                    CONSUMER_CATS
              	)
			VALUES     
            	(
                	<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.price_cat#">,
                    1,
                    #form.startdate#,
                    <cfif isDefined("form.company_cat")><cfqueryparam cfsqltype="cf_sql_varchar" value=",#form.company_cat#,"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value=","></cfif>,
                    <cfif isDefined("form.consumer_cat")><cfqueryparam cfsqltype="cf_sql_varchar" value=",#form.consumer_cat#,"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value=","></cfif>
               	)
		</cfquery>
	</cftransaction>
</cflock>
<cfset attributes.actionId = MAX_ID.IDENTITYCOL >
<script type="text/javascript">
	window.location.href="<cfoutput>#request.self#?fuseaction=prod.upd_ezgi_virtual_offer_price_cat&price_cat_id=#MAX_ID.IDENTITYCOL#</cfoutput>";
</script>
