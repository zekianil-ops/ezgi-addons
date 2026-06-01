<cf_date tarih='attributes.start_date'>
<cf_date tarih='attributes.start_date_1'>
<!---<cf_date tarih='attributes.start_date_2'>--->
<cfset ezgi_id = 0>
<cflock name="#CREATEUUID()#" timeout="20">
	<cftransaction>
    	<cfquery name="get_number" datasource="#dsn3#">
        	SELECT MAX(MONTAGE_TRACING_NUMBER) MAX_NUMBER FROM EZGI_MONTAGE_TRACING
  		</cfquery>
    	<cfif get_number.recordcount and len(get_number.MAX_NUMBER)>
			<cfset maxnumber = get_number.MAX_NUMBER +1>
       	<cfelse>
   			<cfset maxnumber = 1000000>
  		</cfif>
     	<cfquery name="ADD_MONTAGE_TRACING" datasource="#DSN3#">
         	INSERT INTO 
           		EZGI_MONTAGE_TRACING
             	(
                 	MONTAGE_TRACING_NUMBER, 
              		MONTAGE_TRACING_DETAIL, 
                	MONTAGE_TRACING_STATUS, 
                 	RECORD_EMP, 
                 	RECORD_IP, 
                 	RECORD_DATE
             	)
			VALUES     
        		(
              		#maxnumber#,
                	'#attributes.montage_detail#',
                 	1,
               		#session.ep.userid#,
                  	'#cgi.remote_addr#',
                	#now()#
          		)
    	</cfquery>
     	<cfquery name="get_montage_max_id" datasource="#dsn3#">
         	SELECT MAX(MONTAGE_TRACING_ID) AS MAX_ID FROM EZGI_MONTAGE_TRACING
      	</cfquery>
    	<cfloop from="1" to="#attributes.toplam_kayit#" index="kayit">
        	<cfif ezgi_id neq Evaluate('ezgi_id_#kayit#')>
                <cf_papers paper_type="SERVICE_APP">
                <cfset system_paper_no=paper_code & '-' & paper_number>
                <cfset system_paper_no_add=paper_number>
                <cfquery name="UPD_GEN_PAP" datasource="#DSN3#">
                    UPDATE
                        GENERAL_PAPERS
                    SET
                        SERVICE_APP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#system_paper_no_add#">
                    WHERE
                        SERVICE_APP_NUMBER IS NOT NULL
                </cfquery>
                <cfquery name="get_eor" datasource="#dsn3#">
                    SELECT DISTINCT
                    	CASE
                            WHEN O.COMPANY_ID IS NOT NULL THEN
                               (
                                SELECT     
                                    NICKNAME
                                FROM         
                                    #dsn_alias#.COMPANY
                                WHERE     
                                    COMPANY_ID = O.COMPANY_ID
                                )
                            WHEN O.CONSUMER_ID IS NOT NULL THEN      
                                (	
                                SELECT     
                                    CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                                FROM         
                                    #dsn_alias#.CONSUMER
                                WHERE     
                                    CONSUMER_ID = O.CONSUMER_ID
                                )
                        END AS UNVAN,
                        COMPANY_ID,
                        CONSUMER_ID,
                        VIRTUAL_OFFER_NUMBER,
                        UNIT,
                        NAME_PRODUCT,
                        PRODUCT_NAME2,
                        STOCK_ID,
                        PRODUCT_ID,
                        BRANCH_ID,
                        PROJECT_ID,
                        SALES_COMPANY_ID,
                        SPECT_MAIN_ID
                   	FROM  
                    	EZGI_ORGE_RELATIONS O
                  	WHERE 
                    	EZGI_ID = #Evaluate('ezgi_id_#kayit#')#
                </cfquery>
                <cfif len(get_eor.COMPANY_ID)>
                    <cfquery name="get_musteri" datasource="#dsn3#">
                        SELECT     
                            FULLNAME AS UNVAN, 
                            (SELECT TOP (1) COMPANY_PARTNER_NAME+' '+COMPANY_PARTNER_SURNAME FROM #dsn_alias#.COMPANY_PARTNER WHERE COMPANY_ID = COMPANY.COMPANY_ID) as ADI,
                            TAXOFFICE AS TAX_OFFICE, 
                            TAXNO AS TAX_NO, 
                            COMPANY_EMAIL AS EMAIL, 
                            MOBIL_CODE AS CODE, 
                            MOBILTEL AS TEL, 
                            COMPANY_ADDRESS AS ADDRESS, 
                            COUNTY, 
                            CITY, 
                            COUNTRY,
                            SALES_COUNTY,
                            (SELECT TOP (1) TC_IDENTITY FROM #dsn_alias#.COMPANY_PARTNER WHERE COMPANY_ID = COMPANY.COMPANY_ID) as TC_IDENTITY_NO,
                            (SELECT TOP (1) PARTNER_ID FROM #dsn_alias#.COMPANY_PARTNER WHERE COMPANY_ID = COMPANY.COMPANY_ID) as PARTNER_ID
                        FROM        
                            #dsn_alias#.COMPANY
                        WHERE     
                            COMPANY_ID = #get_eor.COMPANY_ID#
                    </cfquery>
                <cfelseif len(get_eor.CONSUMER_ID)>
                    <cfquery name="get_musteri" datasource="#dsn3#">
                        SELECT
                            '' AS UNVAN,     
                            CONSUMER_NAME+' '+CONSUMER_SURNAME AS ADI,
                            TAX_OFFICE, 
                            TAX_NO, 
                            CONSUMER_EMAIL AS EMAIL, 
                            MOBIL_CODE AS CODE, 
                            MOBILTEL AS TEL, 
                            TAX_ADRESS AS ADDRESS, 
                            TAX_COUNTY_ID AS COUNTY, 
                            TAX_CITY_ID AS CITY, 
                            TAX_COUNTRY_ID AS COUNTRY, 
                            SALES_COUNTY, 
                            TC_IDENTY_NO
                        FROM        
                            #dsn_alias#.CONSUMER
                        WHERE
                            CONSUMER_ID = #get_eor.CONSUMER_ID#
                    </cfquery>
                <cfelse>
                    Cari Bağlantısı Yok.
                    <cfabort>
                </cfif>
                 
            	<cfset attributes.service_head = '#get_eor.VIRTUAL_OFFER_NUMBER# - (#Evaluate('miktar_#kayit#')# - #get_eor.UNIT#) - #get_eor.NAME_PRODUCT# - #get_eor.PRODUCT_NAME2#'> 
                <cfquery name="ADD_SERVICE" datasource="#DSN3#" result="my_result">
                    INSERT INTO
                        SERVICE
                        (
                            SERVICE_ACTIVE,
                            ISREAD,
                            SERVICECAT_ID,
                            SERVICE_STATUS_ID,
                            SERVICE_SUBSTATUS_ID,
                            STOCK_ID,	
                            PRIORITY_ID,
                            COMMETHOD_ID,
                            SERVICE_HEAD,
                            SERVICE_COUNTY_ID,
                            SERVICE_CITY_ID,
                            SERVICE_ADDRESS,
                            APPLY_DATE,
                            START_DATE,
                            <cfif len(get_eor.COMPANY_ID)>
                                SERVICE_PARTNER_ID,
                                SERVICE_COMPANY_ID,					
                            <cfelseif len(get_eor.CONSUMER_ID)>
                                SERVICE_CONSUMER_ID,
                            </cfif>
                            SERVICE_PRODUCT_ID,				
                            SERVICE_BRANCH_ID,
                            APPLICATOR_NAME,
                            APPLICATOR_COMP_NAME,
                            PRODUCT_NAME,
                            GUARANTY_START_DATE,
                            GUARANTY_INSIDE,
                            INSIDE_DETAIL,
                            SERVICE_NO,
                            BRING_NAME,
                            BRING_EMAIL,
                            DOC_NO,
                            BRING_TEL_NO,
                            BRING_MOBILE_NO,
                            BRING_DETAIL,
                            ACCESSORY,
                            ACCESSORY_DETAIL,
                            SUBSCRIPTION_ID,
                            SALE_ADD_OPTION_ID,
                            PROJECT_ID,
                            IS_SALARIED,
                            SHIP_METHOD,
                            BRING_SHIP_METHOD_ID,
                            CUS_HELP_ID,
                            OTHER_COMPANY_ID,
                            INSIDE_DETAIL_SELECT,
                            ACCESSORY_DETAIL_SELECT,
                            SERVICECAT_SUB_ID,
                            SERVICECAT_SUB_STATUS_ID,
                            WORKGROUP_ID,
                            CALL_SERVICE_ID,
                            SZ_ID,
                            RECORD_DATE,
                            RECORD_MEMBER,
                            <cfif len(attributes.TASK_EMP_ID)>
                                SERVICE_EMPLOYEE_ID,
                            <cfelseif len(attributes.TASK_COMPANY_ID)>
                                RELATED_COMPANY_ID,
                            </cfif>
                            INTERVENTION_DATE,
                            FINISH_DATE,
                            SPEC_MAIN_ID,
                            TIME_CLOCK_HOUR,
                            TIME_CLOCK_MINUTE
                        )
                    VALUES
                        (
                            1,
                            0,
                            #Evaluate('attributes.cat_#kayit#')#,
                            #attributes.process_stage#,
                            #Evaluate('substatus_#kayit#')#,
                            #get_eor.stock_id#,
                            #Evaluate('priority_#kayit#')#,
                            2,
                            '#Left(attributes.service_head,100)#',			
                            <cfif len(get_musteri.county)>#get_musteri.county#<cfelse>NULL</cfif>,
                            <cfif len(get_musteri.city)>#get_musteri.city#<cfelse>NULL</cfif>,
                            <cfif len(get_musteri.ADDRESS)>'#get_musteri.ADDRESS#'<cfelse>NULL</cfif>,
                            #attributes.start_date#,
                            #attributes.start_date_1#,
                            <cfif len(get_eor.COMPANY_ID)>
                                #get_musteri.partner_id#,
                                #get_eor.COMPANY_ID#,					
                            <cfelseif len(get_eor.CONSUMER_ID)>
                                #get_eor.CONSUMER_ID#,
                            </cfif>	
                            #get_eor.product_id#,
                            <cfif len(get_eor.branch_id)>#get_eor.branch_id#<cfelse>NULL</cfif>,
                            <cfif len(get_musteri.ADI)>'#left(get_musteri.ADI,200)#'<cfelse>NULL</cfif>,
                            <cfif len(get_musteri.UNVAN)>'#get_musteri.UNVAN#'<cfelse>NULL</cfif>,
                            <cfif len(get_eor.NAME_PRODUCT)>'#get_eor.NAME_PRODUCT#'<cfelse>NULL</cfif>,
                            <cfif isdefined('attributes.GUARANTY_START_DATE') and len(attributes.GUARANTY_START_DATE)>#attributes.GUARANTY_START_DATE#,<cfelse>NULL,</cfif>
                            <cfif isdefined("attributes.guaranty_inside")>1<cfelse>0</cfif>,
                            <cfif isdefined("attributes.inside_detail") and len(attributes.inside_detail)>'#attributes.inside_detail#',<cfelse>NULL,</cfif>
                            '#system_paper_no#',
                            <cfif isdefined("attributes.bring_name")>'#attributes.bring_name#'<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.bring_email")>'#attributes.bring_email#'<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.doc_no")>'#attributes.doc_no#'<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.bring_tel_no")>'#attributes.bring_tel_no#'<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.bring_mobile_no")>'#attributes.bring_mobile_no#'<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.bring_detail")>'#attributes.bring_detail#'<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.accessory") and attributes.accessory eq 1>1<cfelse>0</cfif>,
                            <cfif isdefined("attributes.accessory_detail")>'#attributes.accessory_detail#'<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.subscription_id") and len(attributes.subscription_id) and isdefined('attributes.subscription_no') and len(attributes.subscription_no)>#attributes.subscription_id#<cfelse>NULL</cfif>,
            
                            #Evaluate('attributes.add_options_#kayit#')#,
                            <cfif len(get_eor.project_id)>#get_eor.project_id#,<cfelse>NULL,</cfif>
                            <cfif isdefined("attributes.is_salaried")>1<cfelse>0</cfif>,
                            <cfif isdefined("attributes.ship_method") and len(attributes.ship_method) and len(attributes.ship_method_name)>#attributes.ship_method#<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.bring_ship_method_name") and len(attributes.bring_ship_method_name) and len(attributes.bring_ship_method_id)>#attributes.bring_ship_method_id#<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.cus_help_id") and len(attributes.cus_help_id)>#attributes.cus_help_id#<cfelse>NULL</cfif>,
                            <cfif len(get_eor.SALES_COMPANY_ID)>#get_eor.SALES_COMPANY_ID#<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.inside_detail_select") and len(attributes.inside_detail_select)>'#attributes.inside_detail_select#'<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.accessory_detail_select") and len(attributes.accessory_detail_select)>'#attributes.accessory_detail_select#'<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.appcat_sub_id") and len(attributes.appcat_sub_id)>#attributes.appcat_sub_id#<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.appcat_sub_status_id") and len(attributes.appcat_sub_status_id)>#attributes.appcat_sub_status_id#<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.service_work_groups") and len(attributes.service_work_groups)>#attributes.service_work_groups#<cfelse>NULL</cfif>,
                            <cfif isdefined("attributes.call_service_id") and len(attributes.call_service_id)>#attributes.call_service_id#<cfelse>NULL</cfif>,
                            <cfif len(get_musteri.SALES_COUNTY)>#get_musteri.SALES_COUNTY#<cfelse>NULL</cfif>,
                            #now()#,
                            #session.ep.userid#,
                            <cfif len(attributes.TASK_EMP_ID)>
                                #attributes.TASK_EMP_ID#,
                            <cfelseif len(attributes.TASK_COMPANY_ID)>
                                #attributes.TASK_COMPANY_ID#,
                            </cfif>
                            <cfif isdefined('attributes.intervention_date') and len(attributes.intervention_date)>#attributes.intervention_date#<cfelse>NULL</cfif>,
                            <cfif isdefined('attributes.finish_date1') and len(attributes.finish_date1)>#attributes.finish_date1#<cfelse>NULL</cfif>,
                            <cfif len(get_eor.SPECT_MAIN_ID)>#get_eor.SPECT_MAIN_ID#<cfelse>NULL</cfif>,
                            <cfif isDefined("attributes.time_clock_hour") and len(attributes.time_clock_hour)>#attributes.time_clock_hour#<cfelse>NULL</cfif>,
                            <cfif isDefined("attributes.time_clock_minute") and len(attributes.time_clock_minute)>#attributes.time_clock_minute#<cfelse>NULL</cfif>
                        )
                </cfquery>
                <cfset ezgi_id = Evaluate('ezgi_id_#kayit#')>
                <cfquery name="get_max" datasource="#dsn3#">
                	SELECT MAX(SERVICE_ID) MAX_ID FROM SERVICE
                </cfquery>
          	</cfif>
            <cfquery name="get_hizmet_info" datasource="#dsn3#">
            	SELECT     
                 	EMR.STOCK_ID, 
                   	EMR.PRODUCT_NAME, 
                  	EMR.AMOUNT, 
                  	EMR.MAIN_UNIT, 
                    EMR.PRODUCT_UNIT_ID,
                    S.PRODUCT_ID,
                 	ISNULL(TBL2.PRICE, 0) AS PRICE, 
                 	TBL2.MONEY
				FROM        
               		EZGI_MONTAGE_ROW AS EMR INNER JOIN
              		STOCKS AS S ON EMR.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
                  	(
                  		SELECT     
                         	PRODUCT_ID, 
                         	PRICE, 
                        	MONEY
                      	FROM        
                        	#dsn1_alias#.PRICE_STANDART
                      	WHERE    
                        	PRICESTANDART_STATUS = 1 AND 
                          	PURCHASESALES = 0
                	) AS TBL2 ON S.PRODUCT_ID = TBL2.PRODUCT_ID
				WHERE     
                 	EMR.EZGI_ID = #Evaluate('ezgi_id_#kayit#')# AND 
                  	EMR.STOCK_ID = #Evaluate('stock_id_#kayit#')#
           	</cfquery>
            <cfset attributes.wrk_row_id = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')# & #session.ep.company_id# & #kayit#>
            <cfquery name="ADD_SERVICE_OPERATION" datasource="#DSN3#">
				INSERT INTO
					SERVICE_OPERATION
				(
					SERVICE_ID,
					SPARE_PART_ID,
					STOCK_ID,
					PRODUCT_ID,
					PRODUCT_NAME,
                    PREDICTED_AMOUNT,
					AMOUNT,
					UNIT_ID,
					UNIT,
                    DETAIL,
					PRICE,
					TOTAL_PRICE,
					CURRENCY,
					IS_TOTAL,
                    WRK_ROW_ID,
                    SERIAL_NO,
					RECORD_MEMBER,
					RECORD_IP,
					RECORD_DATE			
				)
				VALUES
				(
					#get_max.MAX_ID#,
					4,
					#get_hizmet_info.stock_id#,
					#get_hizmet_info.product_id#,
					'#get_hizmet_info.product_name#',
					#Filternum(Evaluate('miktar_#kayit#'),2)#,
					#Filternum(Evaluate('amount_#kayit#'),2)#,
					#get_hizmet_info.PRODUCT_UNIT_ID#,
					'#get_hizmet_info.MAIN_UNIT#',
                    '#get_hizmet_info.product_name#',
					#Filternum(Evaluate('price_#kayit#'),2)#,
					#Filternum(Evaluate('total_#kayit#'),2)#,
					'#get_hizmet_info.money#',
					1,
                    '#attributes.wrk_row_id#',
                    NULL,
					#session.ep.userid#,
					'#cgi.remote_addr#',
					#now()#
			   )
			</cfquery>
            <cfquery name="add_tracing_row" datasource="#dsn3#">
            	INSERT INTO 
                	EZGI_MONTAGE_TRACING_ROW
                  	(
                    	MONTAGE_TRACING_ID, 
                        EZGI_ID, 
                        STOCK_ID, 
                        SERVICE_ID, 
                        WRK_ROW_RELATION_ID
                 	)
				VALUES     
                	(	
                    	#get_montage_max_id.MAX_ID#,
                        #Evaluate('ezgi_id_#kayit#')#,
                        #Evaluate('stock_id_#kayit#')#,
                       	#get_max.MAX_ID#,
                        '#attributes.wrk_row_id#'
                   	)
            </cfquery>
            <cfquery name="UPD_MONTAGE_ROW" datasource="#DSN3#">
            	UPDATE    
                	EZGI_MONTAGE_ROW
				SET           
                	WRK_ROW_RELATION_ID = '#attributes.wrk_row_id#'
				WHERE     
                	STOCK_ID = #Evaluate('stock_id_#kayit#')# AND 
                    EZGI_ID = #Evaluate('ezgi_id_#kayit#')#
            </cfquery>
     	</cfloop>
  	</cftransaction>
</cflock>
<script type="text/javascript">
	alert("Kayıt Tamamlanmıştır!");
	wrk_opener_reload();
  	window.close();	
</script>