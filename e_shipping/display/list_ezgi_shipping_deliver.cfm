<cfsetting showdebugoutput="yes">
<cf_get_lang_set module_name="sales">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.zone_id" default="">
<cfparam name="attributes.totalrecords" default="0">
<cfparam name="attributes.listing_type" default="2">
<cfparam name="attributes.order_stage" default="">
<cfparam name="attributes.member_cat_type" default="">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.currency_type" default="">
<cfparam name="attributes.company" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.sup_company" default="">
<cfparam name="attributes.sup_company_id" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.ship_method_id" default="">
<cfparam name="attributes.ship_method_name" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.product_cat" default="">
<cfparam name="attributes.search_product_catid" default="" >
<cfparam name="attributes.date1" default="#DateFormat(now(),dateformat_style)#">
<cfparam name="attributes.date2" default="#DateFormat(now(),dateformat_style)#">
<cfquery name="get_period" datasource="#dsn#">
	SELECT        
    	PERIOD_YEAR
	FROM      
    	SETUP_PERIOD
	WHERE        
    	OUR_COMPANY_ID = #session.ep.company_id# AND 
        PERIOD_YEAR < #session.ep.period_year#
</cfquery>
<cfquery name="SZ" datasource="#DSN#">
	SELECT * FROM SALES_ZONES WHERE IS_ACTIVE=1 ORDER BY SZ_NAME
</cfquery>
<cfquery name="get_branch" datasource="#dsn#">
	SELECT 
    	BRANCH_ID,
        BRANCH_NAME 
   	FROM 
    	BRANCH 
   	WHERE 
   		COMPANY_ID = #session.ep.company_id# 
        <cfif session.ep.ISBRANCHAUTHORIZATION eq 1>
            AND BRANCH_ID IN 	(
                                	SELECT  DISTINCT
                                    	BRANCH_ID
									FROM     
                                    	EMPLOYEE_POSITION_BRANCHES
									WHERE  
                                    	POSITION_CODE = #session.ep.POSITION_CODE# AND
                                        BRANCH_ID NOT NULL
                            )
     	</cfif>
   	ORDER BY 
    	BRANCH_NAME
</cfquery>
<cfset branch_id_list = ValueList(get_branch.BRANCH_ID)>
<cfquery name="get_locations" datasource="#dsn#">
	SELECT 
    	DEPARTMENT_ID
  	FROM 
    	EMPLOYEE_POSITION_BRANCHES 
  	WHERE  
    	POSITION_CODE = #session.ep.POSITION_CODE# AND 
        LOCATION_CODE IS NOT NULL 
        <cfif session.ep.ISBRANCHAUTHORIZATION eq 1>
            AND BRANCH_ID IN
                        (
                            SELECT        
                                BRANCH_ID
                            FROM            
                                BRANCH
                            WHERE        
                                BRANCH_STATUS = 1 AND 
                                COMPANY_ID = #session.ep.COMPANY_ID#
                        )
   		</cfif>
</cfquery>
<cfquery name="GET_COMPANY_CAT" datasource="#DSN#">
	SELECT DISTINCT	
		COMPANYCAT_ID,
		COMPANYCAT
	FROM
		GET_MY_COMPANYCAT
	WHERE
		EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"> AND
		OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
	ORDER BY
		COMPANYCAT
</cfquery>
<cfquery name="GET_CONSUMER_CAT" datasource="#DSN#">
	SELECT DISTINCT	
		CONSCAT_ID,
		CONSCAT,
		HIERARCHY
	FROM
		GET_MY_CONSUMERCAT
	WHERE
		EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"> AND
		OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
	ORDER BY
		HIERARCHY		
</cfquery>
<cfif not get_locations.recordcount>
	<script type="text/javascript">
     	alert("<cf_get_lang dictionary_id='712.Bu Şirket İçin Tanımlanmış Depo ve Lokasyon Bulunamamıştır!'>");
     	history.go(-1);
  	</script>
 	<cfabort>
<cfelse>
	<cfset condition_departments_list = ValueList(get_locations.DEPARTMENT_ID)>
    <cfset condition_departments_list = ListDeleteDuplicates(condition_departments_list,',')>
</cfif>
<cfquery name="get_department_name" datasource="#DSN#">
	SELECT 
		SL.LOCATION_ID,
		SL.COMMENT,
		D.DEPARTMENT_ID,
		D.DEPARTMENT_HEAD,
		D.BRANCH_ID
	FROM
		STOCKS_LOCATION SL,
		DEPARTMENT D
	WHERE 
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID
		AND D.BRANCH_ID IN (SELECT BRANCH_ID FROM BRANCH WHERE COMPANY_ID = #session.ep.company_id#)
        AND D.DEPARTMENT_ID IN (#condition_departments_list#)
	ORDER BY
		D.DEPARTMENT_HEAD,
		SL.COMMENT
</cfquery>
<cfquery name="GET_PROCESS_TYPE" datasource="#DSN#">
	SELECT
		PTR.STAGE,
		PTR.PROCESS_ROW_ID
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%sales.list_order%">
	ORDER BY
		PTR.LINE_NUMBER
</cfquery>
<cfoutput query="GET_PROCESS_TYPE">
	<cfset 'STAGE_#PROCESS_ROW_ID#' = STAGE>
</cfoutput>
<cfif isdate(attributes.date1)><cfset attributes.date1 = dateformat(attributes.date1, dateformat_style)></cfif>
<cfif isdate(attributes.date2)><cfset attributes.date2 = dateformat(attributes.date2, dateformat_style)></cfif>
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'> 
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1 >
<cfif isdefined("attributes.form_varmi")>
	<cfset krmsl_uye = ''>
	<cfset brysl_uye = ''>
	<cfif listlen(attributes.member_cat_type)>
		<cfset uzunluk=listlen(attributes.member_cat_type)>
		<cfloop from="1" to="#uzunluk#" index="katyp">
			<cfset kat_list = listgetat(attributes.member_cat_type,katyp,',')>
			<cfif listlen(kat_list) and listfirst(kat_list,'-') eq 1>
				<cfset krmsl_uye = listappend(krmsl_uye,kat_list)>
			<cfelseif listlen(kat_list) and listfirst(kat_list,'-') eq 2>
				<cfset brysl_uye = listappend(brysl_uye,kat_list)>
			</cfif>
		</cfloop>
	</cfif>

	<cfset arama_yapilmali = 0>
     <cfquery name="GET_SHIPPING" datasource="#dsn3#">
    	SELECT      
        	*
		FROM         
        	(
                SELECT   
                    1 AS IS_TYPE,  
                    CASE
                        WHEN O.COMPANY_ID IS NOT NULL THEN
                           (
                            SELECT     
                                NICKNAME
                            FROM         
                                #dsn_alias#.COMPANY WITH (NOLOCK)
                            WHERE     
                                COMPANY_ID = O.COMPANY_ID
                            )
                        WHEN O.CONSUMER_ID IS NOT NULL THEN      
                            (	
                            SELECT     
                                CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                            FROM         
                                #dsn_alias#.CONSUMER WITH (NOLOCK)
                            WHERE     
                                CONSUMER_ID = O.CONSUMER_ID
                            )
                        WHEN O.EMPLOYEE_ID IS NOT NULL THEN
                            (
                            SELECT     
                                EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
                            FROM         
                                #dsn_alias#.EMPLOYEES WITH (NOLOCK)
                            WHERE     
                                EMPLOYEE_ID = O.EMPLOYEE_ID
                            )
                    END
                        AS UNVAN, 
                   	(
                        SELECT     
                            PRODUCT_NAME
                        FROM         
                            #dsn1_alias#.PRODUCT WITH (NOLOCK)
                        WHERE     
                            PRODUCT_ID = ORR.PRODUCT_ID
                    ) AS PRODUCT_NAME,
                    O.ORDER_ID, 
                    ORR.ORDER_ROW_ID, 
                    O.DELIVERDATE, 
                    O.IS_INSTALMENT,
                    O.ORDER_NUMBER, 
                    O.ORDER_DATE, 
                    O.COMPANY_ID, 
                    O.EMPLOYEE_ID, 
                    O.CONSUMER_ID, 
                    O.ORDER_STAGE,
                    O.REF_NO,
                    O.CITY_ID,
                    (SELECT CITY_NAME FROM #dsn_alias#.SETUP_CITY WITH (NOLOCK) WHERE CITY_ID = O.CITY_ID) AS CITY_NAME,
                    ORR.STOCK_ID, 
                    ORR.PRODUCT_ID, 
                    ORR.QUANTITY, 
                    ORR.NETTOTAL, 
                    ORR.RESERVE_TYPE,
                    ORR.ORDER_ROW_CURRENCY, 
                    ORR.DELIVER_AMOUNT
                FROM          
                    EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) RIGHT OUTER JOIN
                    ORDERS AS O WITH (NOLOCK) INNER JOIN
                    ORDER_ROW AS ORR WITH (NOLOCK) ON O.ORDER_ID = ORR.ORDER_ID ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
                WHERE      
                    O.ORDER_STATUS = 1 AND 
                    O.IS_INSTALMENT IS NULL AND 
                    O.RESERVED = 1 AND 
                    (
                        ORR.ORDER_ROW_CURRENCY = - 1 OR
                        ORR.ORDER_ROW_CURRENCY = - 2 OR
                        ORR.ORDER_ROW_CURRENCY = - 4 OR
                        ORR.ORDER_ROW_CURRENCY = - 5 OR
                        ORR.ORDER_ROW_CURRENCY = - 6 OR
                        ORR.ORDER_ROW_CURRENCY = - 7
                    ) AND 
                    ESRR.SHIP_RESULT_ROW_ID IS NULL AND 
                    ((O.PURCHASE_SALES = 1 AND O.ORDER_ZONE = 0) OR (O.PURCHASE_SALES = 0 AND O.ORDER_ZONE = 1))
                    <cfif isdefined('attributes.SALES_DEPARTMENTS') and len(attributes.SALES_DEPARTMENTS)>
                      	AND O.DELIVER_DEPT_ID = #listgetat(attributes.SALES_DEPARTMENTS,1,'-')# 
                    	AND O.LOCATION_ID = #listgetat(attributes.SALES_DEPARTMENTS,2,'-')#
               		</cfif>
                     <cfif session.ep.ISBRANCHAUTHORIZATION eq 1>
                    	<cfif len(branch_id_list)>
                        	AND O.DELIVER_DEPT_ID IN (SELECT DEPARTMENT_ID FROM #dsn_alias#.DEPARTMENT WHERE BRANCH_ID IN (#branch_id_list#))
                     	<cfelse>
                        	AND 1=2
                        </cfif>
                    </cfif>
                    <cfif len(attributes.branch_id)>
                    	AND O.DELIVER_DEPT_ID IN (SELECT DEPARTMENT_ID FROM #dsn_alias#.DEPARTMENT WHERE BRANCH_ID IN (#attributes.branch_id#))
                    </cfif>
                   	<cfif len(attributes.order_stage)>
                    	AND O.ORDER_STAGE = #attributes.order_stage#
                    </cfif> 
                    
                    <cfif isdefined('attributes.date1') and len(attributes.date1)>
                       	AND O.ORDER_DATE > #DateAdd('d',-1,attributes.date1)#
                    </cfif>
                    <cfif isdefined('attributes.date2') and len(attributes.date2)>
                       	AND O.ORDER_DATE < #DateAdd('d',1,attributes.date2)#
                    </cfif>
                    
                    <cfif len(attributes.SHIP_METHOD_NAME)>
                    	AND O.SHIP_METHOD IN (#attributes.SHIP_METHOD_ID#) 
                    </cfif>
                    <cfif len(attributes.product_name)>
                    	AND ORR.PRODUCT_ID = #attributes.product_id#
                   	</cfif>
                    <cfif len(attributes.PRODUCT_CAT)>
                    	AND ORR.PRODUCT_ID IN
                        					(
                                            	SELECT 
                                            		PRODUCT_ID
                                               	FROM
                                                	#dsn1_alias#.PRODUCT WITH (NOLOCK)
                                               	WHERE
                                                	PRODUCT_CODE LIKE '#attributes.search_product_catid#%'
                                            )
                    </cfif>
                    <cfif len(attributes.COMPANY)>
                    	<cfif len(attributes.COMPANY_ID)>
                    		AND O.COMPANY_ID = #attributes.COMPANY_ID#
                      	</cfif>
                        <cfif len(attributes.CONSUMER_ID)>
                    		AND O.CONSUMER_ID = #attributes.CONSUMER_ID#
                      	</cfif>
                  	</cfif>
                   	<cfif len(attributes.currency_type)>
                    	AND ORR.ORDER_ROW_CURRENCY IN (#attributes.currency_type#)
					</cfif>
                    <cfif isdefined("krmsl_uye") and listlen(krmsl_uye)>
                        AND O.COMPANY_ID IN 
                                      	(
                                         	SELECT     
                                            	COMPANY_ID
                                          	FROM         
                                             	#dsn_alias#.COMPANY WITH (NOLOCK)
                                           	WHERE     
                                             	(
                                                 	<cfloop list="#krmsl_uye#" delimiters="," index="comp_i">
                                                    	(COMPANYCAT_ID = #listlast(comp_i,'-')#)
                                                       	<cfif comp_i neq listlast(krmsl_uye,',') and listlen(krmsl_uye,',') gte 1> OR</cfif>
                                               		</cfloop> 
                                            	)
                                 		)
                    <cfelseif isdefined("brysl_uye") and listlen(brysl_uye)>
                        AND O.CONSUMER_ID IN 
                                  		(
                                       		SELECT     
                                            	CONSUMER_ID
                                          	FROM         
                                               	#dsn_alias#.CONSUMER WITH (NOLOCK)
                                         	WHERE     
                                            	(
                                               		<cfloop list="#brysl_uye#" delimiters="," index="cons_j">
                                                  		(CONSUMER_CAT_ID = #listlast(cons_j,'-')#)
                                                    	<cfif cons_j neq listlast(brysl_uye,',') and listlen(brysl_uye,',') gte 1> OR</cfif>
                                                  	</cfloop> 
                                              	)
                               			)
                    </cfif>
               	UNION ALL
                SELECT   
                    2 AS IS_TYPE,  
                    CASE
                        WHEN O.COMPANY_ID IS NOT NULL THEN
                           (
                            SELECT     
                                NICKNAME
                            FROM         
                                #dsn_alias#.COMPANY WITH (NOLOCK)
                            WHERE     
                                COMPANY_ID = O.COMPANY_ID
                            )
                        WHEN O.CONSUMER_ID IS NOT NULL THEN      
                            (	
                            SELECT     
                                CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                            FROM         
                                #dsn_alias#.CONSUMER WITH (NOLOCK)
                            WHERE     
                                CONSUMER_ID = O.CONSUMER_ID
                            )
                        WHEN O.EMPLOYEE_ID IS NOT NULL THEN
                            (
                            SELECT     
                                EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
                            FROM         
                                #dsn_alias#.EMPLOYEES WITH (NOLOCK)
                            WHERE     
                                EMPLOYEE_ID = O.EMPLOYEE_ID
                            )
                    END
                        AS UNVAN, 
                   	(
                        SELECT     
                            PRODUCT_NAME 
                        FROM         
                            #dsn1_alias#.PRODUCT WITH (NOLOCK)
                        WHERE     
                            PRODUCT_ID = ORR.PRODUCT_ID
                    ) AS PRODUCT_NAME,
                    O.ORDER_ID, 
                    ORR.ORDER_ROW_ID, 
                    O.DELIVERDATE, 
                    O.IS_INSTALMENT,
                    O.ORDER_NUMBER, 
                    O.ORDER_DATE, 
                    O.COMPANY_ID, 
                    O.EMPLOYEE_ID, 
                    O.CONSUMER_ID, 
                    O.ORDER_STAGE,
                    O.REF_NO,
                    O.CITY_ID,
                    (SELECT CITY_NAME FROM #dsn_alias#.SETUP_CITY WITH (NOLOCK) WHERE CITY_ID = O.CITY_ID) AS CITY_NAME,
                    ORR.STOCK_ID, 
                    ORR.PRODUCT_ID, 
                    ORR.QUANTITY, 
                    ORR.NETTOTAL, 
                    ORR.RESERVE_TYPE,
                    ORR.ORDER_ROW_CURRENCY, 
                    ORR.DELIVER_AMOUNT
                FROM          
                    EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) RIGHT OUTER JOIN
                    ORDERS AS O WITH (NOLOCK) INNER JOIN
                    ORDER_ROW AS ORR WITH (NOLOCK) ON O.ORDER_ID = ORR.ORDER_ID ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
                WHERE      
                    O.ORDER_STATUS = 1 AND 
                    O.IS_INSTALMENT IS NULL AND 
                    O.RESERVED = 1 AND
                    ORR.ORDER_ROW_ID NOT IN (SELECT ORDER_ROW_ID FROM EZGI_ORDER_TESHIR) AND
                    (
                        ORR.ORDER_ROW_CURRENCY = - 1 OR
                        ORR.ORDER_ROW_CURRENCY = - 2 OR
                        ORR.ORDER_ROW_CURRENCY = - 4 OR
                        ORR.ORDER_ROW_CURRENCY = - 5 OR
                        ORR.ORDER_ROW_CURRENCY = - 6 OR
                        ORR.ORDER_ROW_CURRENCY = - 7
                    ) AND 
                    ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID IS NULL AND 
                    ((O.PURCHASE_SALES = 1 AND O.ORDER_ZONE = 0) OR (O.PURCHASE_SALES = 0 AND O.ORDER_ZONE = 1))
                    <cfif session.ep.ISBRANCHAUTHORIZATION eq 1>
                    	<cfif len(branch_id_list)>
                        	AND O.DELIVER_DEPT_ID IN (SELECT DEPARTMENT_ID FROM #dsn_alias#.DEPARTMENT WHERE BRANCH_ID IN (#branch_id_list#))
                     	<cfelse>
                        	AND 1=2
                        </cfif>
                    </cfif>
                    <cfif len(attributes.branch_id)>
                    	AND O.DELIVER_DEPT_ID IN (SELECT DEPARTMENT_ID FROM #dsn_alias#.DEPARTMENT WHERE BRANCH_ID IN (#attributes.branch_id#))
                    </cfif>
                    <cfif isdefined('attributes.SALES_DEPARTMENTS') and len(attributes.SALES_DEPARTMENTS)>
                      	AND O.DELIVER_DEPT_ID = #listgetat(attributes.SALES_DEPARTMENTS,1,'-')# 
                    	AND O.LOCATION_ID = #listgetat(attributes.SALES_DEPARTMENTS,2,'-')#
               		</cfif>
                   	<cfif len(attributes.order_stage)>
                    	AND O.ORDER_STAGE = #attributes.order_stage#
                    </cfif> 
                    
                    <cfif isdefined('attributes.date1') and len(attributes.date1)>
                       	AND O.ORDER_DATE > #DateAdd('d',-1,attributes.date1)#
                    </cfif>
                    <cfif isdefined('attributes.date2') and len(attributes.date2)>
                       	AND O.ORDER_DATE < #DateAdd('d',1,attributes.date2)#
                    </cfif>
                    
                    <cfif len(attributes.SHIP_METHOD_NAME)>
                    	AND O.SHIP_METHOD IN (#attributes.SHIP_METHOD_ID#) 
                    </cfif>
                    <cfif len(attributes.product_name)>
                    	AND ORR.PRODUCT_ID = #attributes.product_id#
                   	</cfif>
                    <cfif len(attributes.PRODUCT_CAT)>
                    	AND ORR.PRODUCT_ID IN
                        					(
                                            	SELECT 
                                            		PRODUCT_ID
                                               	FROM
                                                	#dsn1_alias#.PRODUCT WITH (NOLOCK)
                                               	WHERE
                                                	PRODUCT_CODE LIKE '#attributes.search_product_catid#%'
                                            )
                    </cfif>
                    <cfif len(attributes.COMPANY)>
                    	<cfif len(attributes.COMPANY_ID)>
                    		AND O.COMPANY_ID = #attributes.COMPANY_ID#
                      	</cfif>
                        <cfif len(attributes.CONSUMER_ID)>
                    		AND O.CONSUMER_ID = #attributes.CONSUMER_ID#
                      	</cfif>
                  	</cfif>
                   	<cfif len(attributes.currency_type)>
                    	AND ORR.ORDER_ROW_CURRENCY IN (#attributes.currency_type#)
					</cfif>
                    <cfif isdefined("krmsl_uye") and listlen(krmsl_uye)>
                        AND O.COMPANY_ID IN 
                                      	(
                                         	SELECT     
                                            	COMPANY_ID
                                          	FROM         
                                             	#dsn_alias#.COMPANY WITH (NOLOCK)
                                           	WHERE     
                                             	(
                                                 	<cfloop list="#krmsl_uye#" delimiters="," index="comp_i">
                                                    	(COMPANYCAT_ID = #listlast(comp_i,'-')#)
                                                       	<cfif comp_i neq listlast(krmsl_uye,',') and listlen(krmsl_uye,',') gte 1> OR</cfif>
                                               		</cfloop> 
                                            	)
                                 		)
                    <cfelseif isdefined("brysl_uye") and listlen(brysl_uye)>
                        AND O.CONSUMER_ID IN 
                                  		(
                                       		SELECT     
                                            	CONSUMER_ID
                                          	FROM         
                                               	#dsn_alias#.CONSUMER WITH (NOLOCK)
                                         	WHERE     
                                            	(
                                               		<cfloop list="#brysl_uye#" delimiters="," index="cons_j">
                                                  		(CONSUMER_CAT_ID = #listlast(cons_j,'-')#)
                                                    	<cfif cons_j neq listlast(brysl_uye,',') and listlen(brysl_uye,',') gte 1> OR</cfif>
                                                  	</cfloop> 
                                              	)
                               			)
                    </cfif>
          	) AS TBL
		WHERE
        	1=1
            <cfif attributes.LISTING_TYPE eq 2>
            	AND IS_TYPE = 1
            <cfelseif attributes.LISTING_TYPE eq 3>
            	AND IS_TYPE = 2
            </cfif>
            <cfif isdefined("attributes.keyword") and len(attributes.keyword)>
            	AND 
                	(
                    	ORDER_NUMBER LIKE '%#attributes.keyword#%' OR
                        UNVAN LIKE '%#attributes.keyword#%' OR
                        PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
                        REF_NO LIKE '%#attributes.keyword#%'
                  	)
            </cfif>
            <cfif len(attributes.zone_id)>  
                	AND (
                    	COMPANY_ID IN 	
                    				(
                                        SELECT     
                                        	COMPANY_ID
										FROM         
                                        	#dsn_alias#.COMPANY
										WHERE     
                                        	SALES_COUNTY IN
                          									(
                                                            	SELECT     
                                                                	SZ_ID
                            									FROM          
                                                                	#dsn_alias#.SALES_ZONES WITH (NOLOCK)
                            									WHERE      
                                                                	SZ_HIERARCHY LIKE '#attributes.zone_id#%'
                                                           	) 
                                   	)
                       	OR
                   		CONSUMER_ID IN 	
                    				(
                                        SELECT     
                                        	CONSUMER_ID
										FROM         
                                        	#dsn_alias#.CONSUMER
										WHERE     
                                        	SALES_COUNTY IN
                          									(
                                                            	SELECT     
                                                                	SZ_ID
                            									FROM          
                                                                	#dsn_alias#.SALES_ZONES WITH (NOLOCK)
                            									WHERE      
                                                                	SZ_HIERARCHY LIKE '#attributes.zone_id#%'
                                                           	) 
                                   	)
                                    
                        OR
                        ORDER_ID IN
                            		(
                                  		SELECT DISTINCT 
                                         	OO.ORDER_ID
                                     	FROM            
                                         	#dsn_alias#.COMPANY_BRANCH AS CB WITH (NOLOCK) INNER JOIN
                                        	ORDERS AS OO WITH (NOLOCK) ON CB.COMPBRANCH_ID = OO.SHIP_ADDRESS_ID
                                      	WHERE        
                                        	CB.SZ_ID IN
                                                			(
                                                              	SELECT     
                                                                 	SZ_ID
                                                             	FROM          
                                                                 	#dsn_alias#.SALES_ZONES WITH (NOLOCK)
                                                              	WHERE      
                                                                  	SZ_HIERARCHY LIKE '#attributes.zone_id#%'
                                                        	)
                        			) 
                  		)
              	</cfif>
     	ORDER BY
        	ORDER_NUMBER
    </cfquery>
    <cfset attributes.totalrecords = GET_SHIPPING.recordcount>
<cfelse>
	<cfset arama_yapilmali = 1>
</cfif>
<cfset t_tutar = 0>
<cfset s_tutar = 0>
<cfform name="order_form" method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cf_box scroll="0">
    	
        	<input name="form_varmi" id="form_varmi" value="1" type="hidden">
            <cf_box_search>
                <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group">
                	 <select name="zone_id" id="zone_id" style="width:160px; height:20px">
						<option value=""><cf_get_lang dictionary_id='57659.Satis Bölgesi'></option>
						<cfoutput query="sz">
							<option value="#SZ_HIERARCHY#" <cfif attributes.zone_id eq SZ_HIERARCHY>selected</cfif>>#sz_name#</option>
						</cfoutput>
					</select>
                </div>
                <div class="form-group">
                	<select name="listing_type" id="listing_type" style="width:90px;height:20px">
                      	<option value="1" <cfif attributes.listing_type eq 1>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                       	<option value="2" <cfif attributes.listing_type eq 2>selected</cfif>><cf_get_lang dictionary_id='717.Sevk Planları'></option>
                      	<option value="3" <cfif attributes.listing_type eq 3>selected</cfif>><cf_get_lang dictionary_id='32034.Sevk Talepleri'></option>
                  	</select>
                </div>
                <div class="form-group">
                	<select name="sales_departments" id="sales_departments" style="width:130px;height:20px">
                    	<option value=""><cf_get_lang dictionary_id='30031.Lokasyon'></option>
                      	<cfoutput query="get_department_name">
                       		<option value="#department_id#-#location_id#" <cfif isdefined("attributes.sales_departments") and attributes.sales_departments is '#department_id#-#location_id#'>selected</cfif>>#department_head#-#comment#</option>
                     	</cfoutput>
                	</select>
                </div>
                <div class="form-group" id="form_ul_branch">
               		<select name="branch_id" id="branch_id" style="width:70px;height:20px" title="Şube Seçilirse Sadece Sevk Talepleri Listelenecektir.">
                      	<option value=""><cf_get_lang dictionary_id='57453.Sube'></option>
                     	<cfoutput query="get_branch">
                      		<option value="#branch_id#" <cfif isdefined("attributes.branch_id") and branch_id eq attributes.branch_id>selected</cfif>>#branch_name#</option>
                     	</cfoutput>
              		</select> 
             	</div>
                <div class="form-group medium" id="form_ul_stage">
                	<select name="order_stage" id="order_stage">
						<option value=""><cf_get_lang_main no='1447.Süreç'></option>
						<cfoutput query="get_process_type">
							<option value="#process_row_id#"<cfif Listfind(attributes.order_stage, process_row_id)>selected</cfif>>#stage#</option>
						</cfoutput>
					</select>
              	</div>
                <div class="form-group" id="form_ul_date">
                	<div class="col col-12">
                     	<div class="col col-6 pl-0">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='30122.Başlangıç Tarihini Kontrol Ediniz'></cfsavecontent>
                                <cfinput type="text" name="date1" value="#dateformat(attributes.date1, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="date1"></span>
                            </div>
                       	</div>
                        <div class="col col-6 pl-0">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='30123.Bitiş Tarihini Kontrol Ediniz'></cfsavecontent>
                                <cfinput type="text" name="date2" value="#dateformat(attributes.date2, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="date2"></span>
                            </div>
                       	</div>
                   	</div>
                </div>
                <div class="form-group small">
                 	<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Kayıt Sayısı Hatalı!'></cfsavecontent>
                 	<cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,1250" required="yes" message="#message#">
            	</div>
                <div class="form-group">
                	<cf_wrk_search_button search_function='input_control()' button_type="4">
             	</div>
           	</cf_box_search>
   		
            <cf_box_search_detail>
            	<div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="1" sort="true">
                    	<div class="col col-12">
                    		<div class="col col-2">
                            	<label><cf_get_lang_main no='74.Kategori'></label>
                        	</div>
                            <div class="col col-10">
                                <div class="form-group medium">
                                    <div class="input-group">
                                    	<cf_wrk_product_cat form_name='order_form' hierarchy_code='search_product_catid' product_cat_name='product_cat'>
										<input type="hidden" name="search_product_catid" id="search_product_catid" value="<cfif len(attributes.product_cat)><cfoutput>#attributes.search_product_catid#</cfoutput></cfif>">
										<input type="text" name="product_cat" id="product_cat" value="<cfif len(attributes.product_cat)><cfoutput>#attributes.product_cat#</cfoutput></cfif>" onkeyup="get_product_cat();">
                                        <span class="input-group-addon icon-ellipsis btnPoniter" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_cat_names&is_sub_category=1&field_code=order_form.search_product_catid&field_name=order_form.product_cat&field_min=add_design.MIN_MARGIN&field_max=add_design.MAX_MARGIN');" title="<cf_get_lang dictionary_id='37157.Ürün Kategorisi Ekle'>!"></span>
                                    </div>
                                </div>
                            </div>
                       	</div>
                        <div class="col col-12">
                    		<div class="col col-2">
                            	<label><cf_get_lang_main no='245.Ürün'></label>
                        	</div>
                            <div class="col col-10">
                                <div class="form-group medium">
                                    <div class="input-group">
                                    	<cf_wrk_products form_name = 'order_form' product_name='product_name' product_id='product_id'>
										<input type="hidden" name="product_id" id="product_id" value="<cfif len(attributes.product_name)><cfoutput>#attributes.product_id#</cfoutput></cfif>">
										<input type="text" name="product_name" id="product_name" value="<cfoutput>#attributes.product_name#</cfoutput>" passthrough="readonly=yes" onkeyup="get_product();">
										<span class="input-group-addon icon-ellipsis btnPoniter" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=order_form.product_id&field_name=order_form.product_name<cfif fusebox.circuit is 'store'>&is_store_module=1</cfif>','list');"></span>
                                    </div>
                                </div>
                            </div>
                       	</div>
                
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="2" sort="true">
                	<div class="col col-12">
                    		<div class="col col-3">
                            	<label><cf_get_lang_main no='1703.Sevk Yöntemi'></label>
                        	</div>
                            <div class="col col-9">
                                <div class="form-group medium">
                                	<div class="input-group">
                                    	<input type="hidden" name="ship_method_id" id="ship_method_id" value="<cfif isdefined('attributes.ship_method_id') and len(attributes.ship_method_name)><cfoutput>#attributes.ship_method_id#</cfoutput></cfif>">
										<input type="text" name="ship_method_name" id="ship_method_name" style="width:150px;" value="<cfif isdefined("attributes.ship_method_name") and len(attributes.ship_method_name)><cfoutput>#attributes.ship_method_name#</cfoutput></cfif>" onfocus="AutoComplete_Create('ship_method_name','SHIP_METHOD','SHIP_METHOD','get_ship_method','','SHIP_METHOD_ID','ship_method_id','','3','125');" autocomplete="off">
                                        <span class="input-group-addon icon-ellipsis btnPoniter" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_ship_methods&field_name=order_form.ship_method_name&field_id=order_form.ship_method_id','list');"></span>
                                	</div>
                                </div>
                            </div>
                       	</div>
                        <div class="col col-12">
                    		<div class="col col-3">
                            	<label><cf_get_lang_main no='45.Müsteri'></label>
                        	</div>
                            <div class="col col-9">
                                <div class="form-group medium">
                                	<div class="input-group">
                                    <input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined('attributes.consumer_id') and len(attributes.company)><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
									<input type="hidden" name="company_id" id="company_id" value="<cfif len(attributes.company)><cfoutput>#attributes.company_id#</cfoutput></cfif>">
									<input type="text" name="company" id="company" style="width:150px;" value="<cfif len(attributes.company)><cfoutput>#attributes.company#</cfoutput></cfif>">
									<span class="input-group-addon icon-ellipsis btnPoniter" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_comp_name=order_form.company&field_comp_id=order_form.company_id&field_consumer=order_form.consumer_id&field_member_name=order_form.company&select_list=2,3','list');"></span>
                                    </div>
                                </div>
                            </div>
                       	</div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="3" sort="true">
                    <div class="col col-12">
                        <div class="col col-2">
                            <label>Üye Kategorisi</label>
                        </div>
                        <div class="col col-10">
                            <div class="form-group" id="form_ul_employee">
                                <select name="member_cat_type" style="width:170px;height:80px;" multiple="multiple">
                                    <optgroup label="<cf_get_lang no='498.Kurumsal Üye Kategorileri'>">
                                    <cfoutput query="get_company_cat">
                                        <option value="1-#COMPANYCAT_ID#" <cfif listfind(attributes.member_cat_type,'1-#COMPANYCAT_ID#',',')>selected</cfif>>&nbsp;&nbsp;#COMPANYCAT#</option>
                                    </cfoutput>						
                                    </optgroup>
                                    <optgroup label="Bireysel Üye Kategorileri">
                                    <cfoutput query="get_consumer_cat">
                                        <option value="2-#CONSCAT_ID#" <cfif listfind(attributes.member_cat_type,'2-#CONSCAT_ID#',',')>selected</cfif>>&nbsp;&nbsp;#CONSCAT#</option>
                                    </cfoutput>						
                                    </optgroup>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="4" sort="true">
                	<div class="col col-12">
                        <div class="col col-2">
                            <label>Aşama</label>
                        </div>
                        <div class="col col-10">
                            <div class="form-group" id="form_ul_status">
                                <select name="currency_type" id="currency_type" style="width:170px;height:80px;" multiple="multiple">
                                    <option value="-1" <cfif listfind(attributes.currency_type,-1)>selected</cfif>><cf_get_lang_main no='1305.Açık'></option>
                                    <option value="-2" <cfif listfind(attributes.currency_type,-2)>selected</cfif>><cf_get_lang_main no ='1948.Tedarik'></option>
                                    <option value="-3" <cfif listfind(attributes.currency_type,-3)>selected</cfif>><cf_get_lang_main no ='1949.Kapatildi'></option>
                                    <option value="-4" <cfif listfind(attributes.currency_type,-4)>selected</cfif>><cf_get_lang_main no ='1950.Kismi Üretim'></option>
                                    <option value="-5" <cfif listfind(attributes.currency_type,-5)>selected</cfif>><cf_get_lang_main no ='44.Üretim'></option>
                                    <option value="-6" <cfif listfind(attributes.currency_type,-6)>selected</cfif>><cf_get_lang_main no='1349.Sevk'></option>
                                    <option value="-7" <cfif listfind(attributes.currency_type,-7)>selected</cfif>><cf_get_lang_main no ='1951.Eksik Teslimat'></option>
                                    <option value="-8" <cfif listfind(attributes.currency_type,-8)>selected</cfif>><cf_get_lang_main no ='1952.Fazla Teslimat'></option>
                                    <option value="-9" <cfif listfind(attributes.currency_type,-9)>selected</cfif>><cf_get_lang_main no ='1094.İptal'></option>
                                    <option value="-10" <cfif listfind(attributes.currency_type,-10)>selected</cfif>>Kapatıldı(Manuel)</option>

                                </select>
                          	</div>
                      	</div>
                	</div>
                </div>
            </cf_box_search_detail>
      	</cf_box>
   	</cfform>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id='58857.Sevkiyat İşlemleri'></cfsavecontent>
    <cf_box title="#message#" uidrop="1" hide_table_column="1">
    	<cf_grid_list sort="1">
        	<thead>
                <tr>
                    <th class="header_icn_txt" style="text-align:center"; width="30px"><cf_get_lang dictionary_id='58577.Sira'></th>
                    <th style="text-align:center"; width="90px"><cf_get_lang dictionary_id='38047.Sipariş No'></th>
                    <th style="text-align:center"; width="80px"><cf_get_lang dictionary_id='58859.Süreç'></th>
                    <th style="text-align:center"; width="80px"><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></th>
                    <th style="text-align:center"; width="80px"><cf_get_lang dictionary_id='290.Termin Tarihi'></th>
                    <th style="text-align:center"; width="180px"><cf_get_lang dictionary_id='57457.Müşteri'></th>
                    <th style="text-align:center"; width="180px"><cf_get_lang dictionary_id='58784.Referans'></th>
                    <th style="text-align:center"; width="80px"><cf_get_lang dictionary_id='57971.Şehir'></th>
                    <th style="text-align:center";><cf_get_lang dictionary_id='57657.Ürün'></th>
                    <th style="text-align:center"; width="80px"><cf_get_lang dictionary_id='57635.Miktar'></th>   
                    <th style="text-align:center"; width="100px"><cf_get_lang dictionary_id='57673.tutar'></th>
                    <th style="text-align:center"; width="70px"><cf_get_lang dictionary_id='57482.Asama'></th>
                    <th style="text-align:center"; width="80px"><cf_get_lang dictionary_id='29750.Rezerve'></th> 
                    <th style="text-align:center"; width="25px"></th>
                </tr>
            </thead>
            <tbody>
				<cfif isdefined("attributes.form_varmi")>
                    <cfif GET_SHIPPING.recordcount>
                        <cfoutput query="GET_SHIPPING">
                            <cfset t_tutar = t_tutar + NETTOTAL>
                        </cfoutput>
                        <cfoutput query="GET_SHIPPING" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                            <tr>
                                <td style="text-align:center">#currentrow#</td>
                                <td style="text-align:center">
                                    <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.list_order&event=upd&order_id=#order_id#','longpage');" class="tableyazi">
                                        #ORDER_NUMBER#
                                    </a>
                                </td>
                              	<td><cfif isdefined('STAGE_#ORDER_STAGE#')>#Evaluate('STAGE_#ORDER_STAGE#')#</cfif></td>
                                <td style="text-align:center">#DateFormat(ORDER_DATE,'dd/mm/yyyy')#</td>
                                <td style="text-align:center">#DateFormat(DELIVERDATE,'dd/mm/yyyy')#</td>
                                <td style="text-align:left">
                                    <cfif len(COMPANY_ID)>
                                        <a href="javascript://"  class="tableyazi" onclick"window.open('#request.self#?fuseaction=objects.popup_com_det&company_id=#COMPANY_ID#')">
                                            #UNVAN#
                                        </a>
                                    <cfelseif len(CONSUMER_ID)>
                                        <a href="javascript://"  class="tableyazi" onclick="window.open('#request.self#?fuseaction=objects.popup_con_det&con_id=#CONSUMER_ID#')">
                                            #UNVAN#
                                        </a>
                                    </cfif>
                                </td>
                                <td style="text-align:left">#REF_NO#</td>
                                <td style="text-align:left">#CITY_NAME#</td>
                                <td style="text-align:left">
                                    <a href="javascript://" class="tableyazi" onclick="window.open('#request.self#?fuseaction=objects.popup_detail_product&pid=#PRODUCT_ID#');">
                                        #PRODUCT_NAME#
                                    </a>
                                </td>
                                
                                <td style="text-align:right">#AmountFormat(QUANTITY)#</td>
                                <td style="text-align:right">#TlFormat(NETTOTAL)#</td>
                                <td style="text-align:center">
                                    <cfif order_row_currency eq -8><cf_get_lang dictionary_id ='29749.Fazla Teslimat'>
                                    <cfelseif order_row_currency eq -7><cf_get_lang dictionary_id ='29748.Eksik Teslimat'>
                                    <cfelseif order_row_currency eq -6><cf_get_lang dictionary_id='58761.Sevk'>
                                    <cfelseif order_row_currency eq -5><cf_get_lang dictionary_id ='57456.Üretim'>
                                    <cfelseif order_row_currency eq -4><cf_get_lang dictionary_id ='29747.Kismi Üretim'>
                                    <cfelseif order_row_currency eq -3><cf_get_lang dictionary_id ='29746.Kapatildi'>
                                    <cfelseif order_row_currency eq -2><cf_get_lang dictionary_id ='29745.Tedarik'>
                                    <cfelseif order_row_currency eq -1><cf_get_lang dictionary_id='58717.Açık'>
                                    <cfelseif order_row_currency eq -9><cf_get_lang dictionary_id ='58506.İptal'>
                                    <cfelseif order_row_currency eq -10><cf_get_lang dictionary_id='58623.Kapatıldı(Manuel)'>
                                    </cfif>	
                                </td>
                                <td style="text-align:center">
                                    <cfif RESERVE_TYPE eq -1><cf_get_lang dictionary_id='29750.Rezerve'>
                                    <cfelseif RESERVE_TYPE eq -2><cf_get_lang dictionary_id='29751.Kısmi Rezerve'>
                                    <cfelseif RESERVE_TYPE eq -3><font color="red"><strong><cf_get_lang dictionary_id='29752.Rezerve Değil'></strong></font>
                                    <cfelseif RESERVE_TYPE eq -4><font color="red"><strong><cf_get_lang dictionary_id='29753.Rezerve Kapatıldı'></strong></font>
                                    </cfif>
                                </td>
                                
                             	<td style="text-align:center">
                                    <cfif attributes.listing_type eq 2>
                                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_add_ezgi_shipping&order_id=#order_id#','wide');">
                                            <img src="../../../images/target_customer.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='58871.Sevk Planı Oluştur'>" />
                                        </a>
                                 	<cfelse>
                                    	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_add_ezgi_shipping_internaldemand&order_id=#order_id#','wide');">
                                            <img src="../../../images/target_branch.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='58871.Sevk Planı Oluştur'>" />
                                        </a>
                                    </cfif>
                             	</td>
                                
                            </tr>
                            <cfset son = currentrow>
                            <cfset s_tutar = s_tutar + NETTOTAL>
                        </cfoutput>
                        <cfif son lt attributes.totalrecords>
                            <cfoutput>
                            <tfoot>
                                <tr>
                                    <td style="text-align:left" colspan="10"><strong><cf_get_lang dictionary_id ='53907.Sayfa Toplamı'></strong></td>
                                    <td style="text-align:right"><strong>#Tlformat(s_tutar)#</strong></td>
                                    <td style="text-align:left" colspan="3"></td>
                                </tr>
                            </tfoot>
                            </cfoutput>
                        <cfelse>
                            <cfoutput>
                            <tfoot>
                                <tr>
                                    <td style="text-align:left" colspan="10"><strong><cf_get_lang dictionary_id='57680.Genel Toplam'></strong></td>
                                    <td style="text-align:right"><strong>#Tlformat(t_tutar)#</strong></td>
                                    <td style="text-align:left" colspan="2"></td>
                                </tr>
                            </tfoot>
                            </cfoutput>
                        </cfif>
                    <cfelse>
                        <tr>
                            <td colspan="18"><cfif arama_yapilmali neq 1><cf_get_lang dictionary_id='57484.Kayit Yok'>!<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'>!</cfif></td>
                        </tr>
                    </cfif>
                </cfif>
            </tbody>
        </cf_grid_list>
        <cfset url_str = 'sales.popup_list_ezgi_shipping_deliver'>
        <cfif isdefined("attributes.form_varmi") and attributes.totalrecords gt attributes.maxrows>
			<cfif isdefined("attributes.totalrecords") and len(attributes.totalrecords)>
                <cfset url_str = url_str & "&totalrecords=#attributes.totalrecords#">
            </cfif>
            <cfif isdefined("attributes.keyword") and len(attributes.keyword)>
                <cfset url_str = url_str & "&keyword=#attributes.keyword#">
            </cfif>
            <cfif isdefined("attributes.zone_id") and len(attributes.zone_id)>
                <cfset url_str = url_str & "&zone_id=#attributes.zone_id#">
            </cfif>
            <cfif isdefined("attributes.listing_type") and len(attributes.listing_type)>
                <cfset url_str = url_str & "&listing_type=#attributes.listing_type#">
            </cfif>
            <cfif isdefined("attributes.sales_departments") and len(attributes.sales_departments)>
                <cfset url_str = url_str & "&sales_departments=#attributes.sales_departments#">
            </cfif>
            
            <cfif isDefined("attributes.currency_type") and len(attributes.currency_type)>
                <cfset url_str = url_str & "&currency_type=#attributes.currency_type#">
            </cfif>
            <cfif isDefined("attributes.member_cat_type") and len(attributes.member_cat_type)>
                <cfset url_str = url_str & "&member_cat_type=#attributes.member_cat_type#">
            </cfif>
            <cfif len(attributes.sup_company_id)>
                <cfset url_str = url_str & "&sup_company_id=#attributes.sup_company_id#&sup_company=#attributes.sup_company#">
            </cfif>
            <cfif len(attributes.company_id)>
                <cfset url_str = url_str & "&company_id=#attributes.company_id#&company=#attributes.company#">
            </cfif>
            <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
                <cfset url_str = url_str & "&consumer_id=#attributes.consumer_id#&company=#attributes.company#">
            </cfif>
            <cfif len(attributes.search_product_catid)>
                <cfset url_str = url_str & "&search_product_catid=#attributes.search_product_catid#&product_cat=#attributes.product_cat#">
            </cfif>
            <cfif len(attributes.date1)>
                <cfset url_str = url_str & "&date1=#attributes.date1#">
            </cfif>
            <cfif len(attributes.date2)>
                <cfset url_str = url_str & "&date2=#attributes.date2#">
            </cfif>
            <cfif len(attributes.product_id)>
                <cfset url_str = url_str & "&product_id=#attributes.product_id#&product_name=#attributes.product_name#">
            </cfif>
            <cfif len(attributes.sup_company_id)>
                <cfset url_str = url_str & "&sup_company_id=#attributes.sup_company_id#&sup_company=#attributes.sup_company#">
            </cfif>
            <cf_paging 

                    page="#attributes.page#"
                    maxrows="#attributes.maxrows#"
                    totalrecords="#attributes.totalrecords#"
                    startrow="#attributes.startrow#"
                    adres="#attributes.fuseaction#&#url_str#&form_varmi=1">
        </cfif>
 	</cf_box>
</div>
<script language="javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true
	}
</script>