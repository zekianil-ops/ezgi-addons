
<cf_date tarih = "attributes.order_date">
<cf_date tarih = "attributes.deliverdate">
<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_CONNECT WHERE CONNECT_ID = #attributes.connect_id# 
</cfquery>
<cfset member_change = 0>
<cfif len(attributes.company_id) and get_upd.COMPANY_ID neq attributes.company_id>
	<cfquery name="get_adress" datasource="#dsn#">
    	SELECT COMPANY_ADDRESS ADDRESS,COUNTY,CITY,COUNTRY FROM COMPANY WHERE COMPANY_ID = #attributes.company_id#
    </cfquery>
    <cfset member_change = 1>
<cfelseif len(attributes.consumer_id) and get_upd.CONSUMER_ID neq attributes.consumer_id>
	<cfquery name="get_adress" datasource="#dsn#">
    	SELECT HOMEADDRESS ADDRESS,HOME_COUNTY_ID COUNTY,HOME_CITY_ID CITY,HOME_COUNTRY_ID COUNTRY FROM CONSUMER WHERE CONSUMER_ID = #attributes.consumer_id#
    </cfquery>
    <cfset member_change = 1>
</cfif>
<cfif member_change eq 1>
	<cfif len(get_adress.COUNTRY)>
        <cfquery name="get_country" datasource="#dsn#">
            SELECT COUNTRY_NAME FROM SETUP_COUNTRY WHERE COUNTRY_ID = #get_adress.COUNTRY#
        </cfquery>
    <cfelse>
    	<cfset get_country.COUNTRY_NAME =''>
    </cfif>
    <cfif len(get_adress.CITY)>
        <cfquery name="get_city" datasource="#dsn#">
            SELECT CITY_NAME FROM SETUP_CITY WHERE CITY_ID = #get_adress.CITY#
        </cfquery>
    <cfelse>
    	<cfset get_city.CITY_NAME =''>
    </cfif>
    <cfif len(get_adress.COUNTY)>
        <cfquery name="get_county" datasource="#dsn#">
            SELECT COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = #get_adress.COUNTY#
        </cfquery>
    <cfelse>
    	<cfset get_county.COUNTY_NAME =''>
    </cfif>
    <cfset adres = '#get_adress.ADDRESS# #get_county.COUNTY_NAME#/#get_city.CITY_NAME# - #get_country.COUNTRY_NAME#'>
</cfif>
<cflock name="#CREATEUUID()#" timeout="60">
 	<cftransaction>
        <cfquery name="upd_connect" datasource="#dsn3#">
          	UPDATE
             	EZGI_CONNECT
         	SET
            	CONNECT_DETAIL = <cfif len(attributes.detail)>'#attributes.detail#'<cfelse>NULL</cfif>, 
              	CONNECT_DATE = <cfif len(attributes.order_date)>#attributes.order_date#<cfelse>NULL</cfif>,
              	CONNECT_STAGE = <cfif len(attributes.process_stage)>#attributes.process_stage#<cfelse>NULL</cfif>,
             	CONNECT_STATUS = 1,
            	<cfif len(attributes.company_id)> 
                 	COMPANY_ID = #attributes.company_id#,
                 	PARTNER_ID = #attributes.partner_id#,
                    CONSUMER_ID = NULL,
                    EMPLOYEE_ID = NULL,
              	<cfelseif len(attributes.consumer_id)>
                	COMPANY_ID = NULL,
                 	PARTNER_ID = NULL,
                 	CONSUMER_ID = #attributes.consumer_id#,
                    EMPLOYEE_ID = NULL,
               	<cfelseif len(attributes.employee_id)>
                	COMPANY_ID = NULL,
                 	PARTNER_ID = NULL,
                 	CONSUMER_ID = NULL,
                    EMPLOYEE_ID = #attributes.employee_id#,
               	</cfif>
                <cfif member_change eq 1>
                	SHIP_ADDRESS_ID =1,
                    SHIP_ADDRESS = '#adres#',
                </cfif>
                SALES_TYPE = #attributes.sales_type#,
                CONNECT_EMPLOYEE_ID = <cfif len(attributes.order_employee_id) and len(attributes.order_employee)>#attributes.order_employee_id#<cfelse>NULL</cfif>,
                CONNECT_TEL = <cfif len(attributes.connect_tel)>'#attributes.connect_tel#'<cfelse>NULL</cfif>,
                CONNECT_HEAD = <cfif len(attributes.connect_head)>'#attributes.connect_head#'<cfelse>NULL</cfif>,
                DELIVERDATE = <cfif len(attributes.deliverdate)>#attributes.deliverdate#<cfelse>NULL</cfif>,
              	MEMBER_TYPE = '#attributes.member_type#',
             	PRICE_CAT_ID = <cfif len(attributes.price_catid)>#attributes.price_catid#<cfelse>NULL</cfif>,
                PAYMETHOD = <cfif len(attributes.paymethod_id)>#attributes.paymethod_id#<cfelse>NULL</cfif>,
                PROJECT_ID = <cfif len(attributes.project_head) and len(attributes.project_id)>#attributes.project_id#<cfelse>NULL</cfif>,
                SHIP_METHOD = <cfif len(attributes.ship_method_id)>#attributes.ship_method_id#<cfelse>NULL</cfif>,
                DISCOUNTTOTAL = <cfif len(attributes.sub_total_discount)>#FilterNum(attributes.sub_total_discount,2)#<cfelse>0</cfif>, 
                GROSSTOTAL = <cfif len(attributes.sub_total_end)>#FilterNum(attributes.sub_total_end,2)#<cfelse>0</cfif>, 
                NETTOTAL = <cfif len(attributes.sub_total_end)>#FilterNum(attributes.sub_total_end,2)#<cfelse>0</cfif>, 
            	TAXTOTAL = <cfif len(attributes.sub_total_tax)>#FilterNum(attributes.sub_total_tax,2)#<cfelse>0</cfif>, 
                OTHER_MONEY = <cfif len(attributes.basket)>'#attributes.basket#'<cfelse>'#session.ep.money#'</cfif>, 
                OTHER_MONEY_VALUE = <cfif len(attributes.sub_total_end_other)>#FilterNum(attributes.sub_total_end_other,2)#<cfelse>0</cfif>,
                RESOURCE_ID = <cfif len(attributes.resource)>#attributes.resource#<cfelse>NULL</cfif>,
              	UPDATE_DATE = #now()#,
               	UPDATE_EMP = #session.ep.userid#,
              	UPDATE_IP = '#cgi.remote_addr#'
           	WHERE
            	CONNECT_ID = #attributes.connect_id#       
      	</cfquery>
        <cfquery name="upd_connect_row" datasource="#dsn3#">
        	DELETE FROM EZGI_CONNECT_ROW WHERE CONNECT_ID = #attributes.connect_id#
        </cfquery>
        <cfif attributes.record_num gt 0>
        	<cfloop from="1" to="#attributes.record_num#" index="i">
            	<cfif isdefined('attributes.row_kontrol#i#') and Evaluate('attributes.row_kontrol#i#') eq 1>
                	<cfquery name="get_product_info" datasource="#dsn3#">
                    	SELECT 
                        	S.PRODUCT_UNIT_ID, 
                            S.PRODUCT_CODE, 
                            PU.MAIN_UNIT, 
                            S.PRODUCT_CODE_2
						FROM 
                        	STOCKS AS S INNER JOIN
                 			PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
						WHERE  
                        	S.STOCK_ID = #Evaluate('attributes.stock_id#i#')#
                    </cfquery>
                    <cfquery name="add_connect_row" datasource="#dsn3#">
                        INSERT INTO 
                            EZGI_CONNECT_ROW
                            (
                                CONNECT_ID, 
                                PRODUCT_ID, 
                                STOCK_ID, 
                                PRODUCT_NAME, 
                                QUANTITY, 
                                PRICE, 
                                PRICE_OTHER, 
                                UNIT, 
                                UNIT_ID, 
                                TAX, 
                                NETTOTAL, 
                                CONNECT_ROW_CURRENCY, 
                                DISCOUNT_1, 
                                DISCOUNT_2, 
                                DISCOUNT_3, 
                                DISCOUNT_COST, 
                                OTHER_MONEY, 
                                OTHER_MONEY_VALUE, 
                                PRODUCT_NAME2, 
                                LIST_PRICE, 
                                KARMA_PRODUCT_ID, 
                                EZGI_ID, 
                                SORT_NO,
                    			ROW_PRICE_CAT_ID,
                                IS_CAMPAIGN_PRODUCT
                                
                            )
                        VALUES 
                            (
                                #attributes.connect_id#,
                                <cfif len(Evaluate('attributes.product_id#i#'))>#Evaluate('attributes.product_id#i#')#<cfelse>NULL</cfif>,
                                <cfif len(Evaluate('attributes.stock_id#i#'))>#Evaluate('attributes.stock_id#i#')#<cfelse>NULL</cfif>,
                                <cfif len(Evaluate('attributes.product_name#i#'))>'#Evaluate('attributes.product_name#i#')#'<cfelse>NULL</cfif>,
                                <cfif len(Evaluate('attributes.quantity#i#'))>#filternum(Evaluate('attributes.quantity#i#'),2)#<cfelse>0</cfif>,
                                <cfif Evaluate('attributes.total_brut#i#') gt 0>#filternum(Evaluate('attributes.total_brut#i#'),2)/filternum(Evaluate('attributes.quantity#i#'),2)#<cfelse>0</cfif>,
                                <cfif len(Evaluate('attributes.sales_price#i#'))>#filternum(Evaluate('attributes.sales_price#i#'),2)#<cfelse>0</cfif>,
                                <cfif len(get_product_info.MAIN_UNIT)>'#get_product_info.MAIN_UNIT#'<cfelse>NULL</cfif>,
                                <cfif len(get_product_info.PRODUCT_UNIT_ID)>#get_product_info.PRODUCT_UNIT_ID#<cfelse>NULL</cfif>,
                                <cfif len(Evaluate('attributes.tax#i#'))>#Evaluate('attributes.tax#i#')#<cfelse>0</cfif>,
                                <cfif len(Evaluate('attributes.total_net#i#'))>#filternum(Evaluate('attributes.total_net#i#'),2)#<cfelse>0</cfif>,
                                1,
                                <cfif len(Evaluate('attributes.discount1_#i#'))>#filternum(Evaluate('attributes.discount1_#i#'),2)#<cfelse>0</cfif>,
                                <cfif len(Evaluate('attributes.discount2_#i#'))>#filternum(Evaluate('attributes.discount2_#i#'),2)#<cfelse>0</cfif>,
                                <cfif len(Evaluate('attributes.discount3_#i#'))>#filternum(Evaluate('attributes.discount3_#i#'),2)#<cfelse>0</cfif>,
                                <cfif len(Evaluate('attributes.discount_tut#i#'))>#filternum(Evaluate('attributes.discount_tut#i#'),2)#<cfelse>0</cfif>,
                                <cfif len(Evaluate('attributes.money#i#'))>'#Evaluate('attributes.money#i#')#'<cfelse>'#session.ep.money#'</cfif>,
                                <cfif len(Evaluate('attributes.sales_price#i#'))>#filternum(Evaluate('attributes.sales_price#i#'),2)#<cfelse>0</cfif>,
                                <cfif len(Evaluate('attributes.detail#i#'))>'#Evaluate('attributes.detail#i#')#'<cfelse>NULL</cfif>,
                                <cfif len(Evaluate('attributes.sales_price#i#'))>#filternum(Evaluate('attributes.sales_price#i#'),2)#<cfelse>NULL</cfif>,
                                NULL,
                                <cfif len(Evaluate('attributes.ezgi_id#i#'))>#Evaluate('attributes.ezgi_id#i#')#<cfelse>NULL</cfif>,
                                #i#,
                                <cfif isdefined('attributes.row_price_cat_id#i#') and len(Evaluate('attributes.row_price_cat_id#i#'))>#Evaluate('attributes.row_price_cat_id#i#')#<cfelse>NULL</cfif>,
                                <cfif isdefined('attributes.is_campaign_product#i#') and len(Evaluate('attributes.is_campaign_product#i#'))>#Evaluate('attributes.is_campaign_product#i#')#<cfelse>0</cfif>
                            )
                    </cfquery>
              	</cfif>
           	</cfloop>
     	</cfif>
        <cfquery name="upd_ezgi_id" datasource="#dsn3#">
        	UPDATE EZGI_CONNECT_ROW SET EZGI_ID = CONNECT_ROW_ID WHERE CONNECT_ID = #attributes.connect_id# AND EZGI_ID IS NULL
      	</cfquery>
        <cfif isdefined('attributes.money_recordcount')>
         	<cfquery name="del_VIRTUAL_OFFER_row" datasource="#dsn3#">
             	DELETE FROM EZGI_CONNECT_MONEY WHERE ACTION_ID = #attributes.connect_id#
      		</cfquery>
           	<cfloop from="1" to="#attributes.money_recordcount#" index="i">
             	<cfif isdefined('attributes.MONEY_TYPE_#i#')>
                 	<cfquery name="add_money" datasource="#dsn3#">
                     	INSERT INTO 
                        	EZGI_CONNECT_MONEY
                         	(
                              	MONEY_TYPE, 
                             	ACTION_ID, 
                            	RATE2, 
                           		RATE1, 
                              	IS_SELECTED
                           	)
                        VALUES        
                        	(
                            	'#Evaluate("attributes.MONEY_TYPE_#i#")#',
                               	#attributes.CONNECT_id#,
                              	#Filternum(Evaluate('attributes.MONEY_#i#'))#,
                              	1,
                             	<cfif attributes.basket eq Evaluate('attributes.MONEY_TYPE_#i#')>1<cfelse>0</cfif>
                         	)
            		</cfquery>	
               	</cfif>
           	</cfloop>
    	</cfif>
        <cfif attributes.sales_type eq 4>
        	<cfinclude template="upd_ezgi_connect_product_cat.cfm">
        </cfif>
   	</cftransaction>
</cflock>
<cf_workcube_process is_upd='1' 
		old_process_line='0'
		process_stage='#attributes.process_stage#' 
		record_member='#session.ep.userid#' 
		record_date='#now()#' 
		action_table='EZGI_CONNECT'
		action_column='CONNECT_ID'
		action_id='#attributes.connect_id#'
		action_page='#request.self#?fuseaction=sales.list_ezgi_connect&event=upd&connect_id=#attributes.connect_id#' 
		warning_description='Sıcak Satış'>
<script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_ezgi_connect&event=upd&connect_id=#attributes.connect_id#</Cfoutput>';
</script>