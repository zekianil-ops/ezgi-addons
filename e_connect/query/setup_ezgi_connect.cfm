<cfif attributes.RECORD_NUM_EMP gt 0>
	<cflock timeout="90">
    	<cftransaction>	
        	<cfquery name="del_setup" datasource="#dsn3#">
            	DELETE FROM EZGI_CONNECT_SETUP
            </cfquery>
        	<cfquery name="add_setup" datasource="#dsn3#">
            	INSERT INTO 
                	EZGI_CONNECT_SETUP
                	(
                    	IMAGE_SMALL_HEIGHT, 
                        IMAGE_SMALL_WIDTH, 
                        IMAGE_SMALL_PIXEL, 
                        IMAGE_MEDIUM_HEIGHT, 
                        IMAGE_MEDIUM_WIDTH, 
                        IMAGE_MEDIUM_PIXEL,
                        VALIDATE_DATE,
                        DELIVERY_DATE
                  	)
				VALUES        
                	(
                    	<cfif len(attributes.IMAGE_SMALL_HEIGHT)>#attributes.IMAGE_SMALL_HEIGHT#<cfelse>NULL</cfif>, 
                        <cfif len(attributes.IMAGE_SMALL_WIDTH)>#attributes.IMAGE_SMALL_WIDTH#<cfelse>NULL</cfif>, 
                        <cfif len(attributes.IMAGE_SMALL_PIXEL)>#attributes.IMAGE_SMALL_PIXEL#<cfelse>NULL</cfif>, 
                        <cfif len(attributes.IMAGE_MEDIUM_HEIGHT)>#attributes.IMAGE_MEDIUM_HEIGHT#<cfelse>NULL</cfif>, 
                        <cfif len(attributes.IMAGE_MEDIUM_WIDTH)>#attributes.IMAGE_MEDIUM_WIDTH#<cfelse>NULL</cfif>, 
                        <cfif len(attributes.IMAGE_MEDIUM_PIXEL)>#attributes.IMAGE_MEDIUM_PIXEL#<cfelse>NULL</cfif>,
                        <cfif len(attributes.VALIDATE_DATE)>#attributes.VALIDATE_DATE#<cfelse>NULL</cfif>,
                        <cfif len(attributes.DELIVERY_DATE)>#attributes.DELIVERY_DATE#<cfelse>NULL</cfif>
                        
                   	)
            </cfquery>
            <cfquery name="del_emp" datasource="#dsn3#">
            	DELETE FROM EZGI_CONNECT_SETUP_ROW
          	</cfquery>
            <cfloop from="1" to="#attributes.RECORD_NUM_EMP#" index="i">
            	<cfif Evaluate('attributes.ROW_KONTROL_EMP#i#') eq 1 and len(Evaluate('attributes.employee_#i#'))>
                	<cfif len(Evaluate('attributes.consumer_id_#i#')) and len(Evaluate('attributes.company_#i#'))>
                    	<cfset member_type = 'consumer'>
                        <cfset member_id = Evaluate('attributes.consumer_id_#i#')>
                    <cfelseif len(Evaluate('attributes.company_id_#i#')) and len(Evaluate('attributes.company_#i#'))>
                    	<cfset member_type = 'company'>
                        <cfset member_id = Evaluate('attributes.company_id_#i#')>
                    <cfelse>
                    	<cfset member_type = ''>
                    </cfif>
                    <cfquery name="add_emp" datasource="#dsn3#">
                        INSERT INTO 
                            EZGI_CONNECT_SETUP_ROW
                            (
                                EMPLOYEE_ID, 
                                MEMBER_TYPE, 
                                MEMBER_ID, 
                                CASH_DISCOUNT_RATE,
                                FUTURE_DISCOUNT_RATE,
                                CAMP_DISCOUNT_RATE,
                                IS_PRICE, 
                                IS_PRICE_KDV, 
                                IS_EXPORT,
                                IS_CUSTOMER_SELECT
                            )
                        VALUES        
                            (
                                #Evaluate('attributes.employee_id_#i#')#,
                                <cfif len(member_type)>
                                	'#member_type#',
                                    #member_id#,
                                <cfelse>
                                	NULL,
                                    NULL,
                                </cfif>
                                #Filternum(Evaluate('attributes.disc_rate_1_#i#'),2)#,
                                #Filternum(Evaluate('attributes.disc_rate_2_#i#'),2)#,
                                #Filternum(Evaluate('attributes.disc_rate_3_#i#'),2)#,
                                <cfif isdefined('attributes.IS_PRICE_#i#')>1<cfelse>0</cfif>,
                                <cfif isdefined('attributes.IS_PRICE_KDV_#i#')>1<cfelse>0</cfif>,
                                <cfif isdefined('attributes.IS_EXPORT_#i#')>1<cfelse>0</cfif>,
                                <cfif isdefined('attributes.IS_CUSTOMER_SELECT_#i#')>1<cfelse>0</cfif>
                            )
                    </cfquery>
               	</cfif>
            </cfloop>
    	</cftransaction>
	</cflock>
</cfif>
<cflocation url="#request.self#?fuseaction=sales.setup_ezgi_connect" addtoken="No">