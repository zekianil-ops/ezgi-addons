<cfif isdefined('attributes.company_id') and len(attributes.company_id)> 
	<!---<cfset get_money_type.MONEY_TYPE = session.ep.money>--->
	<cfquery name="get_company_cat" datasource="#dsn#">
    	SELECT COMPANYCAT_ID FROM COMPANY WHERE COMPANY_ID = #attributes.company_id#
    </cfquery>
    <cfquery name="get_price_cat" datasource="#dsn3#">
    	SELECT        
        	PRICE_CATID,
            (SELECT PRICE_CAT FROM #dsn3_alias#.PRICE_CAT WHERE PRICE_CATID = PRICE_CAT_EXCEPTIONS.PRICE_CATID) AS PRICE_CAT
		FROM            
        	PRICE_CAT_EXCEPTIONS
		WHERE        
        	COMPANY_ID = #attributes.company_id# AND 
            PURCHASE_SALES = 1
		ORDER BY 
        	IS_DEFAULT DESC
    </cfquery>
    <cfif not get_price_cat.recordcount or not len(get_price_cat.PRICE_CATID)>
        <cfquery name="get_price_cat" datasource="#dsn3#">
            SELECT
                PRICE_CATID,
                0 AS COMPANY_CREDIT_ID,
                PRICE_CAT
            FROM     
                PRICE_CAT
            WHERE  
                COMPANY_CAT LIKE '%,#get_company_cat.COMPANYCAT_ID#,%' AND 
                IS_SALES = 1 AND 
                PRICE_CAT_STATUS = 1
            ORDER BY 
                STARTDATE DESC
        </cfquery>
    </cfif>	
    <!---<cfquery name="get_price_cat" datasource="#dsn#">
        SELECT COMPANY_CREDIT_ID, PRICE_CAT as PRICE_CATID FROM COMPANY_CREDIT WHERE COMPANY_ID = #attributes.company_id# AND OUR_COMPANY_ID = #session.ep.company_id#
    </cfquery>--->
    <cfif get_price_cat.recordcount>
        <cfquery name="get_money_type" datasource="#dsn#">
            SELECT 
            	MONEY_TYPE 
           	FROM 
            	COMPANY_CREDIT_MONEY 
          	WHERE 
            	ACTION_ID = (SELECT	COMPANY_CREDIT_ID FROM COMPANY_CREDIT WHERE COMPANY_ID = #attributes.company_id# AND OUR_COMPANY_ID = #session.ep.company_id#) AND 
                IS_SELECTED = 1
        </cfquery>
    </cfif>
    <cfquery name="get_adress" datasource="#dsn#">
    	SELECT COMPANY_ADDRESS ADDRESS,COUNTY,CITY,COUNTRY FROM COMPANY WHERE COMPANY_ID = #attributes.company_id#
    </cfquery>
<cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
	<cfquery name="get_consumer_cat" datasource="#dsn#">
    	SELECT CONSUMER_CAT_ID FROM CONSUMER WHERE CONSUMER_ID = #attributes.consumer_id#
    </cfquery>
    <cfquery name="get_price_cat" datasource="#dsn3#">
    	SELECT        
        	PRICE_CATID,
            (SELECT PRICE_CAT FROM #dsn3_alias#.PRICE_CAT WHERE PRICE_CATID = PRICE_CAT_EXCEPTIONS.PRICE_CATID) AS PRICE_CAT
		FROM            
        	PRICE_CAT_EXCEPTIONS
		WHERE        
        	CONSUMER_ID = #attributes.consumer_id# AND 
            PURCHASE_SALES = 1
		ORDER BY 
        	IS_DEFAULT DESC
    </cfquery>
    <cfif not get_price_cat.recordcount or not len(get_price_cat.PRICE_CATID)>
        <cfquery name="get_price_cat" datasource="#dsn3#">
            SELECT
                PRICE_CATID,
                PRICE_CAT
            FROM     
                PRICE_CAT
            WHERE  
                CONSUMER_CAT LIKE '%,#get_consumer_cat.CONSUMER_CAT_ID#,%' AND 
                IS_SALES = 1 AND 
                PRICE_CAT_STATUS = 1
            ORDER BY 
                STARTDATE DESC
        </cfquery>	
    </cfif>
    <cfquery name="get_adress" datasource="#dsn#">
    	SELECT HOMEADDRESS ADDRESS,HOME_COUNTY_ID COUNTY,HOME_CITY_ID CITY,HOME_COUNTRY_ID COUNTRY FROM CONSUMER WHERE CONSUMER_ID = #attributes.consumer_id#
    </cfquery>
</cfif>
<cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)> 
	<cfif len(get_adress.COUNTRY)>
        <cfquery name="get_country" datasource="#dsn#">
            SELECT COUNTRY_NAME FROM SETUP_COUNTRY WHERE COUNTRY_ID = #get_adress.COUNTRY#
        </cfquery>
    <cfelse>
    	<cfset get_country.COUNTRY_NAME = ''>
    </cfif>
    <cfif len(get_adress.CITY)>
        <cfquery name="get_city" datasource="#dsn#">
            SELECT CITY_NAME FROM SETUP_CITY WHERE CITY_ID = #get_adress.CITY#
        </cfquery>
    <cfelse>
    	<cfset get_city.CITY_NAME = ''>
    </cfif>
    <cfif len(get_adress.COUNTY)>
        <cfquery name="get_county" datasource="#dsn#">
            SELECT COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = #get_adress.COUNTY#
        </cfquery>
    <cfelse>
    	<cfset get_county.COUNTY_NAME = ''>
    </cfif>
    <cfset adres = '#get_adress.ADDRESS# #get_county.COUNTY_NAME#/#get_city.CITY_NAME# - #get_country.COUNTRY_NAME#'>
<cfelse>
	<cfset adres = ''>
</cfif>
<cfif isdefined('x_ssh') and len(x_ssh)>
    <cfif isdefined('x_ssh_price_cat') and len(x_ssh_price_cat)>
        <cfquery name="get_price_cat" datasource="#dsn3#">
            SELECT TOP (1)
                PRICE_CATID,
                PRICE_CAT
            FROM     
                PRICE_CAT
            WHERE  
                IS_SALES = 1 AND 
                PRICE_CAT_STATUS = 1 AND 
                PRICE_CATID IN (#x_ssh_price_cat#)
            ORDER BY 
                STARTDATE DESC
        </cfquery>	
    </cfif>
</cfif>

<cfif not get_price_cat.recordcount or not len(get_price_cat.PRICE_CATID)>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='34305.Üyeyi Bir Fiyat Listesine Dahil Ediniz!'>");
		window.history.go(-1);
	</script>
</cfif>
