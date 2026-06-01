<cfif isdefined('attributes.connect_id')> <!---Eğer İlişkili Sepet Ekleden Gemişse--->
	<cfquery name="get_realted_connect" datasource="#dsn3#"><!--- İlişki Kurulacak Eski Sepet Bilgileri alınıyor--->
		SELECT * FROM EZGI_CONNECT WHERE  CONNECT_ID = #attributes.connect_id#
    </cfquery>
    <cfif attributes.connect_rel_id eq 0><!--- İlk İlişkili Sepet Olacaksa Yeni Bir ilişki ID açılıyor--->
    	<cfquery name="add_new_rel_connet_id" datasource="#dsn3#" result="max_id">
        	INSERT INTO 
            	EZGI_CONNECT_REL
             	(
                	RECORD_DATE, 
                    RECORD_EMP, 
                    RECORD_IP
              	)
			VALUES 
            	(
                	#now()#,
                   	#session.ep.userid#,
                   	'#cgi.remote_addr#'
              	)
        </cfquery>
        <cfset attributes.connect_rel_id = MAX_ID.IDENTITYCOL>
        <cfquery name="upd_rel_connect_id" datasource="#dsn3#"> <!---İlişki Kurulacak Eski Sepete Alınan İlişki ID işleniyor.--->
        	UPDATE 
            	EZGI_CONNECT
			SET          
            	CONNECT_REL_ID = #attributes.connect_rel_id#
			WHERE  
            	CONNECT_ID = #attributes.connect_id#
        </cfquery>
    </cfif>
    <cfquery name="get_order_connect_id" datasource="#dsn3#">
        SELECT  
            MEMBER_TYPE, 
            MEMBER_ID,
            ISNULL(CASH_DISCOUNT_RATE,0) CASH_DISCOUNT_RATE,
            ISNULL(FUTURE_DISCOUNT_RATE,0) FUTURE_DISCOUNT_RATE,
            ISNULL(CAMP_DISCOUNT_RATE,0) CAMP_DISCOUNT_RATE
        FROM 
            EZGI_CONNECT_SETUP_ROW 
        WHERE 
            EMPLOYEE_ID = #session.ep.userid#
    </cfquery>
    <cfset attributes.employee_cash_disc_rate = get_order_connect_id.CASH_DISCOUNT_RATE>
   	<cfset attributes.employee_future_disc_rate = get_order_connect_id.FUTURE_DISCOUNT_RATE>
 	<cfset attributes.employee_camp_disc_rate = get_order_connect_id.CAMP_DISCOUNT_RATE>
    <cfif get_realted_connect.recordcount>
    	<cfset attributes.company_id = get_realted_connect.company_id>
        <cfset attributes.consumer_id = get_realted_connect.consumer_id>
        <cfset attributes.partner_id = get_realted_connect.partner_id>
        <cfset attributes.process_stage = get_realted_connect.CONNECT_STAGE>
    	<cfset attributes.order_employee_id = session.ep.userid>
        <cfset attributes.order_employee = 'aa'>
        <cfset attributes.member_type = get_realted_connect.member_type>
    <cfelse>
    	<script type="text/javascript">
			alert("İlişkili Sepet Bulunamdı!");
			window.close()
		</script>
    	<cfabort>
    </cfif>
</cfif>
<cf_date tarih = "attributes.order_date">
<cfset adres = ''>
<cfinclude template="get_ezgi_sales_info.cfm">
<cfif isdefined('get_money_type.money_type')>
    <cfset ezgi_money_type= get_money_type.money_type>
<cfelse>
	<cfset ezgi_money_type= session.ep.money>
</cfif>
<cflock name="#CREATEUUID()#" timeout="60">
 	<cftransaction>
        <cfquery name="get_gen_paper" datasource="#dsn3#">
            SELECT 
                ORDER_NO, 
                ORDER_NUMBER
            FROM     
                GENERAL_PAPERS
            WHERE  
                GENERAL_PAPERS_ID = 4
        </cfquery>
        <cfset paper_code = evaluate('get_gen_paper.ORDER_NO')>
        <cfset paper_number = evaluate('get_gen_paper.ORDER_NUMBER') +1>
        <cfset paper_full = '#paper_code#-#paper_number#'>
        <cfquery name="SET_MAX_PAPER" datasource="#dsn3#">
            UPDATE
                GENERAL_PAPERS
            SET
                ORDER_NUMBER = ORDER_NUMBER+1
            WHERE
                GENERAL_PAPERS_ID = 4
        </cfquery>
		<cfif isdefined('attributes.x_ssh') and len(attributes.x_ssh)>
			<cfif isdefined('attributes.x_ssh_price_cat') and len(attributes.x_ssh_price_cat)>
				<cfquery name="get_price_cat" datasource="#dsn3#">
					SELECT TOP (1)
						PRICE_CATID,
						PRICE_CAT
					FROM     
						PRICE_CAT
					WHERE  
						IS_SALES = 1 AND 
						PRICE_CAT_STATUS = 1 AND 
						PRICE_CATID = #attributes.x_ssh_price_cat#
					ORDER BY 
						STARTDATE DESC
				</cfquery>	
			</cfif>
		</cfif>
		
        <cfquery name="add_connect" datasource="#dsn3#">
          	INSERT INTO 
             	EZGI_CONNECT
              	(
                 	CONNECT_DETAIL, 
                   	CONNECT_NUMBER, 
                  	CONNECT_DATE, 
                  	CONNECT_STAGE, 
                 	CONNECT_STATUS,
                  	CONNECT_HEAD, 
                  	PURCHASE_SALES,
                    CONNECT_EMPLOYEE_ID,
                    <cfif len(attributes.company_id)> 
                   		COMPANY_ID, 
                     	PARTNER_ID, 
                  	<cfelseif len(attributes.consumer_id)>
                      	CONSUMER_ID,
                  	<cfelseif len(attributes.employee_id)>
                    	EMPLOYEE_ID,
                   	</cfif>
                    <cfif len(adres)>
                        SHIP_ADDRESS_ID,
                        SHIP_ADDRESS,
                    </cfif>
                 	MEMBER_TYPE, 
             		BRANCH_ID,
                    PRICE_CAT_ID,
                    EMPLOYEE_CASH_DISC_RATE,
                    EMPLOYEE_FUTURE_DISC_RATE,
                    EMPLOYEE_CAMP_DISC_RATE,
                    SALES_TYPE,
                	PROJECT_ID,
                 	CONNECT_REL_ID,
                    RESOURCE_ID,
                 	RECORD_DATE, 
                 	RECORD_EMP, 
                	RECORD_IP
            	)
           	VALUES        
           		(
                 	<cfif isdefined('attributes.detail') and len(attributes.detail)>'#attributes.detail#'<cfelse>NULL</cfif>,
                  	'#paper_full#',
                   	<cfif isdefined('attributes.order_date') and len(attributes.order_date)>#attributes.order_date#<cfelse>#now()#</cfif>,
                  	<cfif len(attributes.process_stage)>#attributes.process_stage#<cfelse>NULL</cfif>,
                   	1,
                 	'Teklifimiz',
                  	0,
                    <cfif len(attributes.order_employee)>#attributes.order_employee_id#<cfelse>NULL</cfif>,
                 	<cfif len(attributes.company_id)>
                    	#attributes.company_id#,
                      	#attributes.partner_id#,
                  	<cfelseif len(attributes.consumer_id)>
                     	#attributes.consumer_id#,
                   	<cfelseif len(attributes.employee_id)>
                     	#attributes.employee_id#,
                   	</cfif>
                    <cfif len(adres)>
                        1,
                        '#adres#',
                    </cfif>
                   	<cfif len(attributes.member_type)>'#attributes.member_type#'<cfelse>NULL</cfif>,
                  	#ListGetAt(session.ep.user_location,2,'-')#,
                    <cfif get_price_cat.recordcount and len(get_price_cat.PRICE_CATID)>#get_price_cat.PRICE_CATID#<cfelse>-2</cfif>,
                    #attributes.employee_cash_disc_rate#,
                    #attributes.employee_future_disc_rate#,
                    #attributes.employee_camp_disc_rate#,
                    <cfif isdefined('attributes.is_project') and len(attributes.is_project) and not isdefined('attributes.x_ssh')>
                    	3
                   	<cfelse>
                    	<cfif len(attributes.x_default_sales_type) and isnumeric(attributes.x_default_sales_type)>
                        	#attributes.x_default_sales_type#
                        <cfelse>
                    		1
                      	</cfif>
                   	</cfif>,
                    <cfif isdefined('attributes.is_project') and len(attributes.is_project)>#attributes.is_project#<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.connect_rel_id') and len(attributes.connect_rel_id)>#attributes.connect_rel_id#<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.resource_id') and attributes.resource_id gt 0>#attributes.resource_id#<cfelse>NULL</cfif>,
                   	#now()#,
                   	#session.ep.userid#,
                   	'#cgi.remote_addr#'
             	)
      	</cfquery>
        <cfquery name="get_max_id" datasource="#dsn3#">
        	SELECT MAX(connect_ID) AS MAX_ID FROM EZGI_connect
      	</cfquery>
        <cfquery name="add_connect_money" datasource="#dsn3#">
        	INSERT INTO 
            	EZGI_CONNECT_MONEY
              	(
                	MONEY_TYPE, 
                    RATE2, 
                    RATE1, 
                    IS_SELECTED, 
                    ACTION_ID
              	)
			SELECT 
            	MONEY,
                RATE2, 
                RATE1,
                0 , 
                #get_max_id.MAX_ID#
			FROM     
            	#dsn_alias#.SETUP_MONEY
			WHERE  
            	PERIOD_ID = #session.ep.period_id#
		</cfquery>
        <cfif len(ezgi_money_type)>
            <cfquery name="upd_connect_money" datasource="#dsn3#">
                UPDATE
                    EZGI_CONNECT_MONEY
                SET
                    IS_SELECTED = 1
                WHERE
                    ACTION_ID = #get_max_id.MAX_ID# AND
                    MONEY_TYPE = '#ezgi_money_type#'
            </cfquery>
        <cfelse>
        	<cfquery name="upd_connect_money" datasource="#dsn3#">
                UPDATE
                    EZGI_CONNECT_MONEY
                SET
                    IS_SELECTED = 1
                WHERE
                    ACTION_ID = #get_max_id.MAX_ID# AND
                    MONEY_TYPE = '#session.ep.money#'
            </cfquery>
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
		action_id='#get_max_id.max_id#'
		action_page='#request.self#?fuseaction=sales.list_ezgi_connect&event=upd&connect_id=#get_max_id.max_id#' 
		warning_description='Sıcak Satış'>
<script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_ezgi_connect&event=upd&connect_id=#get_max_id.MAX_ID#</Cfoutput>';
</script>