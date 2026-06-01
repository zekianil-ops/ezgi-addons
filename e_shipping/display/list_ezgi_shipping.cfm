<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.project_head" default="">
<cfparam name="attributes.short_code_id" default="">
<cfparam name="attributes.short_code_name" default="">
<cfparam name="attributes.prod_cat" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.order_employee" default="">
<cfparam name="attributes.order_employee_id" default="">
<cfparam name="attributes.listing_type" default="2">
<cfparam name="attributes.sort_type" default="3">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.city_name" default="">
<cfparam name="attributes.report_type_id" default="3">
<cfparam name="attributes.zone_id" default="">
<cfparam name="attributes.t_point" default="0">
<cfparam name="attributes.SHIP_METHOD_ID" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.dsp_puan" default="0">
<cfparam name="attributes.totalrecords" default="0">
<cfquery name="get_default_department" datasource="#dsn#">
	SELECT DEPARTMENT_ID, LOCATION_ID FROM EMPLOYEE_POSITION_DEPARTMENTS WHERE POSITION_CODE = #session.ep.POSITION_CODE# AND OUR_COMPANY_ID = #session.ep.COMPANY_ID#
</cfquery>
<cfif get_default_department.recordcount>
	<cfparam name="attributes.sales_departments" default="#get_default_department.DEPARTMENT_ID#-#get_default_department.LOCATION_ID#">
<cfelse>
	<cfparam name="attributes.sales_departments" default="">
</cfif>
<cfquery name="get_user_defaults" datasource="#dsn#">
	SELECT PREPARATION,PUAN FROM EZGI_PDA_DEPARTMENT_DEFAULTS WHERE EPLOYEE_ID = #session.ep.userid#
</cfquery>
<cfif get_user_defaults.recordcount and len(get_user_defaults.PREPARATION)>
	<cfset attributes.e_shipping_type = get_user_defaults.PREPARATION>
</cfif>
<cfif get_user_defaults.recordcount and len(get_user_defaults.PUAN)>
	<cfset attributes.dsp_puan = get_user_defaults.PUAN>
</cfif>
<cfquery name="get_user_defaults" datasource="#dsn#">
	SELECT PREPARATION FROM EZGI_PDA_DEPARTMENT_DEFAULTS WHERE EPLOYEE_ID = #session.ep.userid#
</cfquery>
<cfif get_user_defaults.recordcount and len(get_user_defaults.PREPARATION)>
	<cfset attributes.e_shipping_type = get_user_defaults.PREPARATION>
</cfif>
<cfquery name="get_shipping_default" datasource="#dsn3#">
	SELECT ISNULL(SHIPPING_CONTROL_TYPE,0) SHIPPING_CONTROL_TYPE, ISNULL(IS_FAST_SALES_REICIPT,0) IS_FAST_SALES_REICIPT FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfif get_shipping_default.recordcount>
	<cfparam name="attributes.e_shipping_type" default="#get_shipping_default.SHIPPING_CONTROL_TYPE#"> 
<cfelse>
	<cfparam name="attributes.e_shipping_type" default="0"> 
</cfif>

<cfquery name="get_locations" datasource="#dsn#">
	SELECT 
    	DEPARTMENT_ID
  	FROM 
    	EMPLOYEE_POSITION_BRANCHES WITH (NOLOCK)
  	WHERE  
    	POSITION_CODE = #session.ep.POSITION_CODE# AND 
        LOCATION_CODE IS NOT NULL AND
        BRANCH_ID IN
        			(
        				SELECT        
                        	BRANCH_ID
						FROM            
                        	BRANCH  WITH (NOLOCK)
						WHERE        
                        	BRANCH_STATUS = 1 AND 
                            COMPANY_ID = #session.ep.COMPANY_ID#
        			)
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
<cfset cat_criter1 = '01.152.'>
<cfset cat_criter2 = '01.153.'>
<cfset lnk_str = '#cat_criter1#,#cat_criter2#'>
<cfif len(attributes.SHIP_METHOD_ID)>
	<cfset lnk_str = lnk_str &',#attributes.SHIP_METHOD_ID#'>
<cfelse>
	<cfset lnk_str = lnk_str &','&' '>
</cfif> 
<cfif len(attributes.city_name)>
	<cfset lnk_str = lnk_str &',#attributes.city_name#'>
<cfelse>
	<cfset lnk_str = lnk_str &','&' '>
</cfif>
<cfif len(attributes.sales_departments)>
	<cfset lnk_str = lnk_str &',#attributes.sales_departments#'>
<cfelse>
	<cfset lnk_str = lnk_str &','&' '>
</cfif> 
<cfif len(attributes.prod_cat)>
	<cfset lnk_str = lnk_str &',#attributes.prod_cat#'>
<cfelse>
	<cfset lnk_str = lnk_str &','&' '>
</cfif> 
<cfif len(attributes.product_id)>
	<cfset lnk_str = lnk_str &',#attributes.product_id#'>
<cfelse>
	<cfset lnk_str = lnk_str &','&' '>
</cfif>
<cfif len(attributes.consumer_id)>
	<cfset lnk_str = lnk_str &',#attributes.consumer_id#'>
<cfelse>
	<cfset lnk_str = lnk_str &','&' '>
</cfif>
<cfif len(attributes.company_id)>
	<cfset lnk_str = lnk_str &',#attributes.company_id#'>
<cfelse>
	<cfset lnk_str = lnk_str &','&' '>
</cfif>
<cfif len(attributes.order_employee_id)>
	<cfset lnk_str = lnk_str &',#attributes.order_employee_id#'>
<cfelse>
	<cfset lnk_str = lnk_str &','&' '>
</cfif>
<cfif len(attributes.finish_date)>
	<cfset lnk_str = lnk_str &',#attributes.finish_date#'>
<cfelse>
	<cfset lnk_str = lnk_str &','&' '>
</cfif>
<cfif len(attributes.start_date)>
	<cfset lnk_str = lnk_str &',#attributes.start_date#'>
<cfelse>
	<cfset lnk_str = lnk_str &','&' '>
</cfif>
<cfif len(attributes.listing_type)>
	<cfset lnk_str = lnk_str &',#attributes.listing_type#'>
<cfelse>
	<cfset lnk_str = lnk_str &','&' '>
</cfif>
<cfif len(attributes.sort_type)>
	<cfset lnk_str = lnk_str &',#attributes.sort_type#'>
<cfelse>
	<cfset lnk_str = lnk_str &','&' '>
</cfif>
<cfif len(attributes.branch_id)>
	<cfset lnk_str = lnk_str &',#attributes.branch_id#'>
<cfelse>
	<cfset lnk_str = lnk_str &','&' '>
</cfif>
<cfif len(attributes.zone_id)>
	<cfset lnk_str = lnk_str &',#attributes.zone_id#'>
<cfelse>
	<cfset lnk_str = lnk_str &','&' '>
</cfif>
<cfif isdefined("attributes.project_id") and len(attributes.project_id) and isdefined("attributes.project_head") and len(attributes.project_head)>
	<cfset lnk_str = lnk_str & ",#attributes.project_id#">
<cfelse>
	<cfset lnk_str = lnk_str  &','&' '>
</cfif>
<cfif isdefined("attributes.form_varmi")>
	<cfset lnk_str = lnk_str & ",1">
<cfelse>
    <cfset lnk_str = lnk_str & ",0">
</cfif>
<cfset son_row = 0>
<cfif isdefined("attributes.start_date") and isdate(attributes.start_date)>
	<cf_date tarih="attributes.start_date">
<cfelse>
	<cfset attributes.start_date = wrk_get_today()>
</cfif>
<cfif isdefined("attributes.finish_date") and isdate(attributes.finish_date)>
	<cf_date tarih="attributes.finish_date">
<cfelse>
	<cfset attributes.finish_date = wrk_get_today()>
</cfif>
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'> 
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1 >
<cfquery name="SZ" datasource="#DSN#">
	SELECT * FROM SALES_ZONES WHERE IS_ACTIVE=1 ORDER BY SZ_NAME
</cfquery>
<cfif isdefined("attributes.form_varmi")>
	<cfquery name="get_period_id" datasource="#dsn#">
    	SELECT TOP(1)       
        	PERIOD_YEAR
		FROM            
        	SETUP_PERIOD
		WHERE        
        	OUR_COMPANY_ID = #session.ep.company_id# AND 
            PERIOD_YEAR < #session.ep.period_year#
        ORDER BY
        	PERIOD_YEAR desc
    </cfquery>
    <cfif ListLen(attributes.branch_id)>
        <cfquery name="get_department" datasource="#dsn#">
            SELECT DEPARTMENT_ID FROM DEPARTMENT WHERE BRANCH_ID IN (#attributes.branch_id#)
        </cfquery>
        <cfset department_id_list = ValueList(get_department.DEPARTMENT_ID)>
    </cfif>
	<cfquery name="GET_SHIPPING" datasource="#dsn3#"><!---Sevk Planları ve Sevk Talepleri Listeleniyor--->
            SELECT 
                *,
                CASE
                    WHEN TBL.COMPANY_ID IS NOT NULL THEN
                        (
                        SELECT     
                            NICKNAME
                            FROM         
                                #dsn_alias#.COMPANY WITH (NOLOCK)
                            WHERE     
                                COMPANY_ID = TBL.COMPANY_ID
                        )
                    WHEN TBL.CONSUMER_ID IS NOT NULL THEN      
                        (	
                            SELECT     
                                CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                            FROM         
                                #dsn_alias#.CONSUMER WITH (NOLOCK)
                            WHERE     
                                CONSUMER_ID = TBL.CONSUMER_ID
                        )
                END
                    AS UNVAN
            FROM
                (
                <cfif listing_type neq 3>
                    <cfif not len(attributes.branch_id)>
                    	SELECT 
                        	'' AS DEPO,    
                            ESR.SHIP_RESULT_ID, 
                            ESR.NOTE, 
                            ESR.SEVK_EMIR_DATE,
                            ISNULL(ESR.IS_SEVK_EMIR,0) AS IS_SEVK_EMIR,
                            ISNULL(ESR.SEVK_EMP,0) AS SEVK_EMP,
                            ESR.SHIP_FIS_NO, 
                            ESR.DELIVER_PAPER_NO, 
                            ESR.DELIVER_EMP,
                            ESR.REFERENCE_NO, 
                            ESR.DELIVERY_DATE, 
                            ESR.DEPARTMENT_ID, 
                            0 AS DEPARTMENT_IN_ID,
                            O.COMPANY_ID, 
                            O.CONSUMER_ID, 
                            ESR.OUT_DATE, 
                            ESR.IS_TYPE, 
                            ESR.LOCATION_ID, 
                            0 AS LOCATION_IN_ID,
                            ESR.SHIP_METHOD_TYPE, 
                            SM.SHIP_METHOD, 
                            E.EMPLOYEE_NAME, 
                            E.EMPLOYEE_SURNAME, 
                            D.DEPARTMENT_HEAD,
                            MIN(O.ORDER_ID) AS ORDER_ID,
                            MIN(O.ORDER_NUMBER) AS ORDER_NUMBER,
                            MIN(O.ORDER_DATE) AS ORDER_DATE,
                            MIN(B.BRANCH_NAME) AS BRANCH_NAME,
                            MIN(SC.CITY_NAME) AS SEHIR,
                            MIN(SCO.COUNTY_NAME) AS ILCE,
                            SUM(ORR.QUANTITY) AS AMOUNT,
                            (
                            SELECT     
                                SUM(DURUM) AS DURUM
                            FROM         
                                (
                                SELECT     
                                    DURUM
                                FROM          
                                    (
                                    SELECT     
                                        CASE 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 1 THEN 1 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 2 THEN 1 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 3 THEN 2 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 4 THEN 1 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 5 THEN 1 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 6 THEN 1 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 7 THEN 1 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 8 THEN 2 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 9 THEN 2 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 10 THEN 2 
                                            WHEN O.RESERVED = 0 THEN 0 
                                        END AS DURUM
                                    FROM          
                                        EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) INNER JOIN
                                        ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                        ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID
                                    WHERE      
                                        ESRR.SHIP_RESULT_ID = ESR.SHIP_RESULT_ID
                                    ) AS TBL2
                                GROUP BY DURUM
                                ) AS TBL3
                            ) AS DURUM,
                            (
                            SELECT     
                                SUM(SEVK_DURUM) AS SEVK_DURUM
                            FROM         
                                (
                                SELECT     
                                    SEVK_DURUM
                                FROM          
                                    (
                                    SELECT     
                                        CASE 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 3 THEN 1 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 6 THEN 4
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 8 THEN 1 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 9 THEN 1
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 10 THEN 1
                                            ELSE 2
                                        END AS SEVK_DURUM
                                    FROM          
                                        EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) INNER JOIN
                                        ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                        ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID
                                    WHERE      
                                        ESRR.SHIP_RESULT_ID = ESR.SHIP_RESULT_ID
                                    ) AS TBL2
                                GROUP BY SEVK_DURUM
                                ) AS TBL3
                            ) AS SEVK_DURUM
                        FROM 
                        	EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) JOIN 
                        	#dsn_alias#.SHIP_METHOD AS SM WITH (NOLOCK) ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID JOIN 
                        	#dsn_alias#.EMPLOYEES AS E WITH (NOLOCK) ON ESR.DELIVER_EMP = E.EMPLOYEE_ID JOIN 
                            #dsn_alias#.DEPARTMENT AS D WITH (NOLOCK) ON ESR.DEPARTMENT_ID = D.DEPARTMENT_ID LEFT JOIN 
                            EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID LEFT JOIN 
                            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID LEFT JOIN 
                            ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID LEFT JOIN 
                            #dsn_alias#.BRANCH AS B WITH (NOLOCK) ON O.FRM_BRANCH_ID = B.BRANCH_ID LEFT JOIN 
                            #dsn_alias#.SETUP_CITY AS SC WITH (NOLOCK) ON O.CITY_ID = SC.CITY_ID LEFT JOIN 
                            #dsn_alias#.SETUP_COUNTY AS SCO WITH (NOLOCK) ON O.COUNTY_ID = SCO.COUNTY_ID INNER JOIN
                      		STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID
                        WHERE 
                        	ESR.IS_TYPE = 1
                        	<cfif isdefined('attributes.product_id') and len(attributes.product_id)>
                                AND ORR.PRODUCT_ID = #attributes.product_id#
                            </cfif>
                            <cfif isdefined('attributes.prod_cat') and len(attributes.prod_cat)>
                                AND S.STOCK_CODE LIKE N'#attributes.prod_cat#%'                          
                            </cfif>
                            <cfif isdefined('attributes.SALES_DEPARTMENTS') and Listlen(attributes.SALES_DEPARTMENTS,'-') eq 2>
                                AND ESR.DEPARTMENT_ID = #listgetat(attributes.SALES_DEPARTMENTS,1,'-')# 
                                AND ESR.LOCATION_ID = #listgetat(attributes.SALES_DEPARTMENTS,2,'-')#
                            </cfif>
                            <cfif isdefined('attributes.start_date') and len(attributes.start_date)>
                                AND ESR.OUT_DATE >= #attributes.start_date#
                            </cfif>
                            <cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>
                                AND ESR.OUT_DATE <= #attributes.finish_date#
                            </cfif>
                            <cfif isdefined("attributes.project_id") and len(attributes.project_id) and isdefined("attributes.project_head") and len(attributes.project_head)>
                            	<cfif attributes.project_id eq -1>
                                	AND O.PROJECT_ID IS NULL
                                <cfelse>
                                    AND O.PROJECT_ID = #attributes.project_id#
                              	</cfif>
                            </cfif>
                            <cfif len(attributes.zone_id)>  
                                AND (
                                    O.COMPANY_ID IN 	
                                                (
                                                    SELECT     
                                                        COMPANY_ID
                                                    FROM         
                                                        #dsn_alias#.COMPANY WITH (NOLOCK)
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
                                    O.CONSUMER_ID IN 	
                                                (
                                                    SELECT     
                                                        CONSUMER_ID
                                                    FROM         
                                                        #dsn_alias#.CONSUMER WITH (NOLOCK)
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
                                    ESR.SHIP_RESULT_ID IN
                                    			(
                                                	SELECT DISTINCT 
                                                    	ESRR.SHIP_RESULT_ID
													FROM            
                                                    	#dsn_alias#.COMPANY_BRANCH AS CB WITH (NOLOCK) INNER JOIN
                         								ORDERS AS OO WITH (NOLOCK) ON CB.COMPBRANCH_ID = OO.SHIP_ADDRESS_ID INNER JOIN
                         								EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON OO.ORDER_ID = ESRR.ORDER_ID
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
                        
                        GROUP BY
                            ESR.SHIP_RESULT_ID, 
                            ESR.NOTE, 
                            ESR.SEVK_EMIR_DATE,
                            ESR.IS_SEVK_EMIR,
                            ESR.SEVK_EMP,
                            ESR.SHIP_FIS_NO, 
                            ESR.DELIVER_PAPER_NO, 
                            ESR.DELIVER_EMP,
                            ESR.REFERENCE_NO, 
                            ESR.DELIVERY_DATE, 
                            ESR.DEPARTMENT_ID, 
                            O.COMPANY_ID, 
                            O.CONSUMER_ID, 
                            ESR.OUT_DATE, 
                            ESR.IS_TYPE, 
                            ESR.LOCATION_ID, 
                            ESR.SHIP_METHOD_TYPE, 
                            SM.SHIP_METHOD, 
                            E.EMPLOYEE_NAME, 
                            E.EMPLOYEE_SURNAME, 
                            D.DEPARTMENT_HEAD
                        <cfif listing_type eq 1>      
                            UNION ALL
                        </cfif>
                    </cfif>
                </cfif>
                <cfif listing_type neq 2>
                	SELECT  
                    	ESR.DEPARTMENT_IN_ID+'-'+ESR.LOCATION_IN_ID AS DEPO,   
                  		ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID, 
                  		ESR.NOTE, 
                  		ESR.SEVK_EMIR_DATE,
                  		ISNULL(ESR.IS_SEVK_EMIR,0) AS IS_SEVK_EMIR,
                  		ISNULL(ESR.SEVK_EMP,0) AS SEVK_EMP,
                  		ESR.SHIP_FIS_NO, 
                  		CAST(ESR.SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) AS DELIVER_PAPER_NO,  
                  		ESR.DELIVER_EMP,
                  		ESR.REFERENCE_NO, 
                  		ESR.DELIVERY_DATE, 
                  		ESR.DEPARTMENT_ID, 
                        ESR.DEPARTMENT_IN_ID,
                  		MIN(O.COMPANY_ID) AS COMPANY_ID, 
                  		MIN(O.CONSUMER_ID) AS CONSUMER_ID, 
                  		ESR.OUT_DATE, 
                  		ESR.IS_TYPE, 
                  		ESR.LOCATION_ID, 
                        ESR.LOCATION_IN_ID,
                  		ESR.SHIP_METHOD_TYPE, 
                  		SM.SHIP_METHOD, 
                  		E.EMPLOYEE_NAME, 
                  		E.EMPLOYEE_SURNAME, 
                  		D.DEPARTMENT_HEAD,
                        MIN(O.ORDER_ID) AS ORDER_ID,
                    	MIN(O.ORDER_NUMBER) AS ORDER_NUMBER,
                        MIN(O.ORDER_DATE) AS ORDER_DATE,
                  		MIN(B.BRANCH_NAME) AS BRANCH_NAME,
                  		MIN(SC.CITY_NAME) AS SEHIR,
                  		MIN(SCO.COUNTY_NAME) AS ILCE,
                  		SUM(ORR.QUANTITY) AS AMOUNT,
                        CASE
                            WHEN (SH.SHIP_ID IS NOT NULL AND SH.IS_SHIP_IPTAL = 0) THEN 2
                            WHEN (SH.SHIP_ID IS NULL OR SH.IS_SHIP_IPTAL = 1) THEN 1
                            END
                        AS DURUM,
                  		(
                        	SELECT     
                                SUM(SEVK_DURUM) AS SEVK_DURUM
                            FROM         
                                (
                                SELECT     
                                    SEVK_DURUM
                                FROM          
                                    (
                                    SELECT     
                                        CASE 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 3 THEN 1 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 6 THEN 4
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 8 THEN 1 
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 9 THEN 1
                                            WHEN ORR.ORDER_ROW_CURRENCY = - 10 THEN 1
                                            ELSE 2
                                        END AS SEVK_DURUM
                                    FROM          
                                        EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) INNER JOIN
                                        ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                        ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID
                                    WHERE      
                                        ESRR.SHIP_RESULT_INTERNALDEMAND_ID = ESR.SHIP_RESULT_INTERNALDEMAND_ID
                                    ) AS TBL2
                                GROUP BY SEVK_DURUM
                                ) AS TBL3

                    	) AS SEVK_DURUM
                	FROM 
                 		EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) JOIN 
                    	#dsn_alias#.SHIP_METHOD AS SM WITH (NOLOCK) ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID JOIN 
                    	#dsn_alias#.EMPLOYEES AS E WITH (NOLOCK) ON ESR.DELIVER_EMP = E.EMPLOYEE_ID JOIN 
                  		#dsn_alias#.DEPARTMENT AS D WITH (NOLOCK) ON ESR.DEPARTMENT_IN_ID = D.DEPARTMENT_ID LEFT JOIN 
                  		EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID LEFT JOIN 
                  		ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID LEFT JOIN 
                  		ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID LEFT JOIN 
                  		#dsn_alias#.BRANCH AS B WITH (NOLOCK) ON O.FRM_BRANCH_ID = B.BRANCH_ID LEFT JOIN 
                  		#dsn_alias#.SETUP_CITY AS SC WITH (NOLOCK) ON O.CITY_ID = SC.CITY_ID LEFT JOIN 
                  		#dsn_alias#.SETUP_COUNTY AS SCO WITH (NOLOCK) ON O.COUNTY_ID = SCO.COUNTY_ID INNER JOIN
            			STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID LEFT JOIN
                        #dsn2_alias#.SHIP AS SH WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = SH.DISPATCH_SHIP_ID
                 	WHERE 
                   		ESR.IS_TYPE = 2
                     	<cfif ListLen(attributes.branch_id) and ListLen(department_id_list)>
                        	AND ESR.DEPARTMENT_IN_ID IN (#department_id_list#)
                  		</cfif>
                        <cfif isdefined('attributes.product_id') and len(attributes.product_id)>
                         	AND O.PRODUCT_ID = #attributes.product_id#
                  		</cfif>
                  		<cfif isdefined('attributes.prod_cat') and len(attributes.prod_cat)>
                  		    AND S.STOCK_CODE LIKE N'#attributes.prod_cat#%'                          
                  		</cfif>
                  		<cfif isdefined('attributes.SALES_DEPARTMENTS') and Listlen(attributes.SALES_DEPARTMENTS,'-') eq 2>
                  		    AND ESR.DEPARTMENT_ID = #listgetat(attributes.SALES_DEPARTMENTS,1,'-')# 
                  		    AND ESR.LOCATION_ID = #listgetat(attributes.SALES_DEPARTMENTS,2,'-')#
                  		</cfif>
                  		<cfif isdefined('attributes.start_date') and len(attributes.start_date)>
                  		    AND ESR.OUT_DATE >= #attributes.start_date#
                  		</cfif>
                  		<cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>
                  		    AND ESR.OUT_DATE <= #attributes.finish_date#
                  		</cfif>
                  		<cfif isdefined("attributes.project_id") and len(attributes.project_id) and isdefined("attributes.project_head") and len(attributes.project_head)>
                  			<cfif attributes.project_id eq -1>
                  		    	AND O.PROJECT_ID IS NULL
                  		    <cfelse>
                  		        AND O.PROJECT_ID = #attributes.project_id#
                  		  	</cfif>
                  		</cfif>
                  		<cfif len(attributes.zone_id)>  
                  		    AND (
                  		        O.COMPANY_ID IN 	
                  		                    (
                  		                        SELECT     
                  		                  			COMPANY_ID
                  		                        FROM         
                  		                  			#dsn_alias#.COMPANY WITH (NOLOCK)
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
                  		        O.CONSUMER_ID IN 	
                  		                    (
                  		                        SELECT     
                  		                            CONSUMER_ID
                  		                        FROM         
                                              		#dsn_alias#.CONSUMER WITH (NOLOCK)
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
                  		        ESR.SHIP_RESULT_ID IN
                  		        			(
                  		                    	SELECT DISTINCT 
                  		                        	ESRR.SHIP_RESULT_ID
												FROM            
                  		                        	#dsn_alias#.COMPANY_BRANCH AS CB WITH (NOLOCK) INNER JOIN
                         							ORDERS AS OO WITH (NOLOCK) ON CB.COMPBRANCH_ID = OO.SHIP_ADDRESS_ID INNER JOIN
                         							EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON OO.ORDER_ID = ESRR.ORDER_ID
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
                  	GROUP BY
                  		ESR.SHIP_RESULT_INTERNALDEMAND_ID, 
                  		ESR.NOTE, 
                  		ESR.SEVK_EMIR_DATE,
                  		ESR.IS_SEVK_EMIR,
                  		ESR.SEVK_EMP,
                  		ESR.SHIP_FIS_NO, 
                  		ESR.DELIVER_EMP,
                  		ESR.REFERENCE_NO, 
                  		ESR.DELIVERY_DATE, 
                  		ESR.DEPARTMENT_ID,
                        ESR.DEPARTMENT_IN_ID, 
                  		ESR.OUT_DATE, 
                  		ESR.IS_TYPE, 
                  		ESR.LOCATION_ID, 
                        ESR.LOCATION_IN_ID, 
                  		ESR.SHIP_METHOD_TYPE, 
                  		SM.SHIP_METHOD, 
                  		E.EMPLOYEE_NAME, 
                  		E.EMPLOYEE_SURNAME, 
                  		D.DEPARTMENT_HEAD,
                        SH.SHIP_ID,
                        SH.IS_SHIP_IPTAL
               	</cfif> 
                ) AS TBL
            WHERE
                AMOUNT > 0
                <cfif isdefined('attributes.city_name') and len(attributes.city_name)>
                    AND SEHIR ='#attributes.city_name#' 
                </cfif>
                <cfif isdefined('attributes.SHIP_METHOD_ID') and len(attributes.SHIP_METHOD_ID)>
                    AND SHIP_METHOD_TYPE IN (#attributes.SHIP_METHOD_ID#) 
                </cfif>
                <cfif isdefined('attributes.member_name') and len(attributes.member_name)>
					<cfif isdefined('attributes.company_id') and len(attributes.company_id)>
                        AND COMPANY_ID =#attributes.company_id#
                    </cfif>
                    <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
                        AND CONSUMER_ID =#attributes.consumer_id# 
                    </cfif>
                </cfif>
                <cfif len(attributes.keyword)>
                    AND 
                    	(
                        REFERENCE_NO LIKE '%#attributes.keyword#%' OR
                        DELIVER_PAPER_NO LIKE '%#attributes.keyword#%'
                        )
                </cfif>
                <cfif len(attributes.order_employee_id) and len(attributes.order_employee)>
                	AND DELIVER_EMP = #attributes.order_employee_id#
                </cfif>
              	
    			<cfif attributes.report_type_id eq 1>
                	AND DURUM = 1
                <cfelseif attributes.report_type_id eq 2>
                	AND DURUM = 2
                <cfelseif attributes.report_type_id eq 3>
                	AND SEVK_DURUM = 4
               	 <cfelseif attributes.report_type_id eq 4>
                	AND SEVK_DURUM = 6
                </cfif>
            ORDER BY
                <cfif sort_type eq 1>
                    OUT_DATE
                <cfelseif sort_type eq 2>
                    OUT_DATE desc
                <cfelseif sort_type eq 3>
                    DELIVER_PAPER_NO
                <cfelseif sort_type eq 4>
                    DELIVER_PAPER_NO desc
                <cfelseif sort_type eq 5>
                    IS_TYPE,DEPARTMENT_ID,UNVAN, SHIP_FIS_NO
              	<cfelseif sort_type eq 6>
                    SHIP_FIS_NO
              	<cfelseif sort_type eq 7>
                    SHIP_FIS_NO DESC
                </cfif>
  	</cfquery>
	<cfif GET_SHIPPING.recordcount>
        	<cfquery name="get_plan_id" dbtype="query">
            	SELECT SHIP_RESULT_ID FROM GET_SHIPPING WHERE IS_TYPE =1
            </cfquery>
            <cfset sevk_plan_id_list = ValueList(get_plan_id.SHIP_RESULT_ID)>
        	<cfquery name="get_plan_id" dbtype="query">
            	SELECT SHIP_RESULT_ID FROM GET_SHIPPING WHERE IS_TYPE =2
            </cfquery>
            <cfset sevk_talep_id_list = ValueList(get_plan_id.SHIP_RESULT_ID)>

            <!---*****PUAN GÖSTERİMİ SORGU*******--->
            <cfset last_year = session.ep.period_year -1>
            <cfif ListLen(sevk_plan_id_list)>
            	<cfif attributes.e_shipping_type eq 1> <!---Hazırlık Göster--->
          			<cfquery name="GET_PLAN_AMBAR" datasource="#DSN3#">
                   		SELECT     
                   		    ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
                   		    ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT,
                   		    SHIP_RESULT_ID
                   		FROM         
                   		    (
                   		    SELECT     
                   		        PAKET_SAYISI AS PAKETSAYISI, 
                   		        PAKET_ID AS STOCK_ID, 
                   		        BARCOD, 
                   		        STOCK_CODE, 
                   		        PRODUCT_NAME,
                   		        SHIP_RESULT_ID,
                   		        (
                   		        SELECT 
                   		            SUM(CONTROL_AMOUNT) CONTROL_AMOUNT
                   		        FROM
                   		            ( 
                   		                SELECT        
                   		                    SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                   		                FROM   
                   		                           
                   		                    #dsn2_alias#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                   		                    #dsn2_alias#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                   		                    SPECTS AS SP WITH (NOLOCK) ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                   		                    STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                   		                WHERE        
                   		                    SF.FIS_TYPE = 113 AND 
                   		                    SF.REF_NO = TBL.DELIVER_PAPER_NO AND 
                   		                    SFR.STOCK_ID = TBL.PAKET_ID AND
                   		                    ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                   		                    ISNULL(S.IS_PROTOTYPE,0) = 1
                   		                UNION ALL
                   		                SELECT        
                   		                    SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                   		                FROM   
                   		                    #dsn2_alias#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                   		                    #dsn2_alias#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN

                   		                    STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                   		                WHERE        
                   		                    SF.FIS_TYPE = 113 AND 
                   		                    SF.REF_NO = TBL.DELIVER_PAPER_NO AND 
                   		                    SFR.STOCK_ID = TBL.PAKET_ID AND
                   		                    ISNULL(S.IS_PROTOTYPE,0) = 0
                   		                    <cfif get_period_id.recordcount>
                   		                    	UNION ALL
                   		                        SELECT        
                   		                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                   		                        FROM   
                   		                                   
                   		                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                   		                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                   		                            SPECTS AS SP WITH (NOLOCK) ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                   		                            STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                   		                        WHERE        
                   		                            SF.FIS_TYPE = 113 AND 
                   		                            SF.REF_NO = TBL.DELIVER_PAPER_NO AND 
                   		                            SFR.STOCK_ID = TBL.PAKET_ID AND
                   		                            ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                   		                            ISNULL(S.IS_PROTOTYPE,0) = 1
                   		                        UNION ALL
                   		                        SELECT        
                   		                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                   		                        FROM   
                   		                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                   		                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                   		                            STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                   		                        WHERE        
                   		                            SF.FIS_TYPE = 113 AND 
                   		                            SF.REF_NO = TBL.DELIVER_PAPER_NO AND 
                   		                            SFR.STOCK_ID = TBL.PAKET_ID AND
                   		                            ISNULL(S.IS_PROTOTYPE,0) = 0
                   		                    </cfif>
                   		            ) AS TBL_5
                   		        ) AS CONTROL_AMOUNT
                   		    FROM         
                   		        (
                   		        SELECT
                   		            SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                   		            PAKET_ID, 
                   		            BARCOD, 
                   		            STOCK_CODE, 
                   		            PRODUCT_NAME, 
                   		            SHIP_RESULT_ID,
                   		            DELIVER_PAPER_NO,
                   		            SPECT_MAIN_ID
                   		        FROM
                   		            (     
                   		            SELECT     
                   		                SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                   		                EPS.PAKET_ID, 
                   		                S.BARCOD, 
                   		                S.STOCK_CODE, 
                   		                S.PRODUCT_NAME, 
                   		                ESR.SHIP_RESULT_ID,
                   		                ESR.DELIVER_PAPER_NO,
                   		                ESRR.ORDER_ROW_ID,
                   		                0 AS SPECT_MAIN_ID
                   		            FROM          
                   		                STOCKS AS S1 WITH (NOLOCK) INNER JOIN
                   		                EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
                   		                EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                   		                ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
                   		                STOCKS AS S WITH (NOLOCK) INNER JOIN
                   		                EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON S1.STOCK_ID = EPS.MODUL_ID
                   		            WHERE      
                   		                ESR.SHIP_RESULT_ID IN (#sevk_plan_id_list#) AND
                   		                ISNULL(S1.IS_PROTOTYPE,0) = 0
                   		            GROUP BY 
                   		                EPS.PAKET_ID, 
                   		                S.BARCOD, 
                   		                S.STOCK_CODE, 
                   		                S.PRODUCT_NAME, 
                   		                ESR.SHIP_RESULT_ID,
                   		                ESR.DELIVER_PAPER_NO,
                   		                ESRR.ORDER_ROW_ID
                   		          	UNION ALL
                   		        	SELECT
                   		                SUM(ORR.QUANTITY) AS PAKET_SAYISI, 
                   		                S1.STOCK_ID AS PAKET_ID,
                   		                S1.BARCOD,
                   		                S1.STOCK_CODE,
                   		                S1.PRODUCT_NAME,
                   		                ESR.SHIP_RESULT_ID,
                   		                ESR.DELIVER_PAPER_NO, 
                   		                ESRR.ORDER_ROW_ID, 
                   		                SP.SPECT_MAIN_ID
                   		            FROM            
                   		                SPECTS AS SP WITH (NOLOCK) INNER JOIN
                   		                EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
                   		                EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                   		                ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                   		                STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID
                   		            WHERE        
                   		                ESR.SHIP_RESULT_ID IN (#sevk_plan_id_list#) AND 
                   		                ISNULL(S1.IS_PROTOTYPE, 0) = 1
                   		            GROUP BY 
                   		                S1.STOCK_ID,
                   		                SP.SPECT_MAIN_ID, 
                   		                ESR.DELIVER_PAPER_NO,
                   		                ESR.SHIP_RESULT_ID, 
                   		                ESRR.ORDER_ROW_ID, 
                   		                S1.STOCK_CODE, 
                   		                S1.PRODUCT_NAME, 
                   		                S1.BARCOD
                   		                
                   		            ) AS TBL1
                   		        GROUP BY
                   		            PAKET_ID, 
                   		            BARCOD, 
                   		            STOCK_CODE, 
                   		            PRODUCT_NAME, 
                   		            SHIP_RESULT_ID,
                   		            DELIVER_PAPER_NO,
                   		            SPECT_MAIN_ID
                   		        ) AS TBL
                   		    ) AS TBL2
                      	GROUP BY
                   			SHIP_RESULT_ID       
					</cfquery>
                </cfif>
				<cfquery name="GET_PLAN_SEVK" datasource="#DSN3#">
             		SELECT     
                   		ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
                   		ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT,
                   		SHIP_RESULT_ID
                                            FROM         
                   		(
                   		SELECT     
                   		    PAKET_SAYISI AS PAKETSAYISI, 
                   		    PAKET_ID AS STOCK_ID, 
                   		    BARCOD, 
                   		    STOCK_CODE, 
                   		    PRODUCT_NAME,
                   		    SHIP_RESULT_ID,
                   		    (
                   		    SELECT     
                   		        SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                   		    FROM          
                   		        EZGI_SHIPPING_PACKAGE_LIST WITH (NOLOCK)
                   		    WHERE      
                   		        TYPE = 1 AND 
                   		        STOCK_ID = TBL.PAKET_ID AND 
                   		        SHIPPING_ID = TBL.SHIP_RESULT_ID
                   		    ) AS CONTROL_AMOUNT
                   		FROM         
                   		    (
                   		    SELECT
                   		        SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                   		        PAKET_ID, 
                   		        BARCOD, 
                   		        STOCK_CODE, 
                   		        PRODUCT_NAME, 
                   		        PRODUCT_TREE_AMOUNT, 
                   		        SHIP_RESULT_ID
                   		    FROM
                   		        (     
                   		        SELECT     
                   		            round(SUM(ORR.QUANTITY * EPS.PAKET_SAYISI),2) AS PAKET_SAYISI, 
                   		            EPS.PAKET_ID, 
                   		            S.BARCOD, 
                   		            S.STOCK_CODE, 
                   		            S.PRODUCT_NAME, 
                   		            S.PRODUCT_TREE_AMOUNT, 
                   		            ESR.SHIP_RESULT_ID,
                   		            ESRR.ORDER_ROW_ID
                   		        FROM 
                   		            SPECTS AS SP WITH (NOLOCK) INNER JOIN
                   		            EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
                   		            EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                   		            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                   		            STOCKS AS S WITH (NOLOCK) INNER JOIN
                   		            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID INNER JOIN
                   		            STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID   
                   		        WHERE      
                   		            ESR.SHIP_RESULT_ID IN (#sevk_plan_id_list#) AND
                   		            ISNULL(S1.IS_PROTOTYPE,0) = 1
                   		        GROUP BY 
                   		            EPS.PAKET_ID, 
                   		            S.BARCOD, 
                   		            S.STOCK_CODE, 
                   		            S.PRODUCT_NAME, 
                   		            S.PRODUCT_TREE_AMOUNT, 
                   		            ESR.SHIP_RESULT_ID,
                   		            ESRR.ORDER_ROW_ID
                   		        UNION ALL
                   		        SELECT     
                   		            round(SUM(ORR.QUANTITY * EPS.PAKET_SAYISI),2) AS PAKET_SAYISI, 
                   		            EPS.PAKET_ID, 
                   		            S.BARCOD, 
                   		            S.STOCK_CODE, 
                   		            S.PRODUCT_NAME, 
                   		            S.PRODUCT_TREE_AMOUNT, 
                   		            ESR.SHIP_RESULT_ID,
                   		            ESRR.ORDER_ROW_ID
                   		        FROM          
                   		            EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
                   		            EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                   		            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                   		            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                   		            STOCKS AS S WITH (NOLOCK) ON EPS.PAKET_ID = S.STOCK_ID INNER JOIN
                   		            STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID
                   		        WHERE      
                   		            ESR.SHIP_RESULT_ID IN (#sevk_plan_id_list#) AND
                   		            ISNULL(S1.IS_PROTOTYPE,0) = 0
                   		        GROUP BY 
                   		            EPS.PAKET_ID, 
                   		            S.BARCOD, 
                   		            S.STOCK_CODE, 
                   		            S.PRODUCT_NAME, 
                   		            S.PRODUCT_TREE_AMOUNT, 
                   		            ESR.SHIP_RESULT_ID,
                   		            ESRR.ORDER_ROW_ID
                   		        ) AS TBL1
                   		    GROUP BY
                   		        PAKET_ID, 
                   		        BARCOD, 
                   		        STOCK_CODE, 
                   		        PRODUCT_NAME,
                   		        PRODUCT_TREE_AMOUNT, 
                   		        SHIP_RESULT_ID
                   		    ) AS TBL
                   		) AS TBL2
                   	GROUP BY
                    	SHIP_RESULT_ID
                </cfquery>
                <cfquery name="GET_PUAN_PLAN" datasource="#DSN3#"> <!---Satış Puanları Toplanıyor--->
                  	SELECT
                     	<cfif attributes.dsp_puan><!---Kişi Puan Gösterecekse--->
                        	ISNULL(PIP.PROPERTY1, 0) AS PUAN,
                      	<cfelse>
                        	0 AS PUAN,	
                        </cfif>
                        ISNULL(TBLB.AMOUNT,0) AS AMOUNT,
                        ESRR.SHIP_RESULT_ID,
                     	ORR.ORDER_ID,
                     	ORR.STOCK_ID, 
                       	ORR.PRODUCT_ID, 
                       	ORR.QUANTITY,
                       	ORR.ORDER_ID FIS_ID,
                       	ORR.ORDER_ROW_ID FIS_ROW_ID
                  	FROM  
                    	EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN       
                    	EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESRR.SHIP_RESULT_ID = ESR.SHIP_RESULT_ID INNER JOIN
                      	ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID LEFT OUTER JOIN
                    	(
                         	SELECT        
                            	WRK_ROW_RELATION_ID, 
                            	SUM(AMOUNT) AS AMOUNT
                           	FROM            
                             	(
                                	SELECT        
                                    	AMOUNT, 
                                      	WRK_ROW_RELATION_ID
                                   	FROM            
                                     	#dsn#_#session.ep.period_year#_#session.ep.company_id#.INVOICE_ROW WITH (NOLOCK)
                                  	UNION ALL
                                   	SELECT        
                                     	IR.AMOUNT, 
                                     	IR.WRK_ROW_RELATION_ID
                                   	FROM            
                                    	#dsn#_#session.ep.period_year#_#session.ep.company_id#.SHIP_ROW AS SR WITH (NOLOCK) INNER JOIN
                                     	#dsn#_#session.ep.period_year#_#session.ep.company_id#.INVOICE_ROW AS IR WITH (NOLOCK) ON SR.WRK_ROW_ID = IR.WRK_ROW_RELATION_ID
                                   	<cfif get_period_id.recordcount>
                                     	UNION ALL
                                     	SELECT        
                                        	AMOUNT, 
                                          	WRK_ROW_RELATION_ID
                                      	FROM            
                                         	#dsn#_#last_year#_#session.ep.company_id#.INVOICE_ROW WITH (NOLOCK)
                                       	UNION ALL
                                      	SELECT        
                                        	IR.AMOUNT, 
                                           	IR.WRK_ROW_RELATION_ID
                                      	FROM            
                                          	#dsn#_#last_year#_#session.ep.company_id#.SHIP_ROW AS SR WITH (NOLOCK) INNER JOIN
                                       		#dsn#_#last_year#_#session.ep.company_id#.INVOICE_ROW AS IR WITH (NOLOCK) ON SR.WRK_ROW_ID = IR.WRK_ROW_RELATION_ID
                                   	</cfif>
                              	) AS TBLA
                        	GROUP BY 

                             	 WRK_ROW_RELATION_ID
                  		) AS TBLB ON ORR.WRK_ROW_ID = TBLB.WRK_ROW_RELATION_ID INNER JOIN
                        STOCKS AS ST WITH (NOLOCK) ON ST.STOCK_ID = ORR.STOCK_ID
                      	<cfif attributes.dsp_puan>
                        	LEFT OUTER JOIN PRODUCT_INFO_PLUS AS PIP WITH (NOLOCK) ON ORR.PRODUCT_ID = PIP.PRODUCT_ID
                      	</cfif>
                  	WHERE     
                    	ESRR.SHIP_RESULT_ID IN (#sevk_plan_id_list#)
        		</cfquery>
          	<cfelse>
            	<cfset GET_PLAN_SEVK.recordcount =0>
                <cfset GET_PLAN_AMBAR.recordcount =0>
                <cfset GET_PUAN_PLAN.recordcount =0>
          	</cfif>
            <cfif ListLen(sevk_talep_id_list)>
            	<cfif attributes.e_shipping_type eq 1> <!---Hazırlık Göster--->
         			<cfquery name="GET_TALEP_AMBAR" datasource="#DSN3#">
                    	SELECT     
                   		    ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
                   		    ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT,
                   		    SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID
                   		FROM         
                   		    (
                   		    SELECT     
                   		        PAKET_SAYISI AS PAKETSAYISI, 
                   		        PAKET_ID AS STOCK_ID, 
                   		        BARCOD, 
                   		        STOCK_CODE, 
                   		        PRODUCT_NAME,
                   		        SHIP_RESULT_INTERNALDEMAND_ID,
                   		        (
                   		        SELECT 
                   		            SUM(CONTROL_AMOUNT) CONTROL_AMOUNT
                   		        FROM
                   		            ( 
                   		                SELECT        
                   		                    SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                   		                FROM   
                   		                           
                   		                    #dsn2_alias#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                   		                    #dsn2_alias#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                   		                    SPECTS AS SP WITH (NOLOCK) ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                   		                    STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                   		                WHERE        
                   		                    SF.FIS_TYPE = 113 AND 
                   		                    SF.REF_NO = TBL.DELIVER_PAPER_NO AND 
                   		                    SFR.STOCK_ID = TBL.PAKET_ID AND
                   		                    ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                   		                    ISNULL(S.IS_PROTOTYPE,0) = 1
                   		                UNION ALL
                   		                SELECT        
                   		                    SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                   		                FROM   
                   		                    #dsn2_alias#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN


                   		                    #dsn2_alias#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                   		                    STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                   		                WHERE        
                   		                    SF.FIS_TYPE = 113 AND 
                   		                    SF.REF_NO = TBL.DELIVER_PAPER_NO AND 
                   		                    SFR.STOCK_ID = TBL.PAKET_ID AND
                   		                    ISNULL(S.IS_PROTOTYPE,0) = 0


                   		                    <cfif get_period_id.recordcount>
                   		                    	UNION ALL
                   		                        SELECT        
                   		                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                   		                        FROM   
                   		                                   
                   		                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                   		                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                   		                            SPECTS AS SP WITH (NOLOCK) ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                   		                            STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                   		                        WHERE        
                   		                            SF.FIS_TYPE = 113 AND 
                   		                            SF.REF_NO = TBL.DELIVER_PAPER_NO AND 
                   		                            SFR.STOCK_ID = TBL.PAKET_ID AND
                   		                            ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                   		                            ISNULL(S.IS_PROTOTYPE,0) = 1
                   		                        UNION ALL
                   		                        SELECT        
                   		                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                   		                        FROM   
                   		                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                   		                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                   		                            STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                   		                        WHERE        
                   		                            SF.FIS_TYPE = 113 AND 
                   		                            SF.REF_NO = TBL.DELIVER_PAPER_NO AND 
                   		                            SFR.STOCK_ID = TBL.PAKET_ID AND
                   		                            ISNULL(S.IS_PROTOTYPE,0) = 0
                   		                    </cfif>
                   		            ) AS TBL_5
                   		        ) AS CONTROL_AMOUNT
                   		    FROM         
                   		        (
                   		        SELECT
                   		            SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                   		            PAKET_ID, 
                   		            BARCOD, 
                   		            STOCK_CODE, 
                   		            PRODUCT_NAME, 
                   		            SHIP_RESULT_INTERNALDEMAND_ID,
                   		            CAST(SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) AS DELIVER_PAPER_NO,
                   		            SPECT_MAIN_ID
                   		        FROM
                   		            (     
                   		            SELECT     
                   		                SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                   		                EPS.PAKET_ID, 
                   		                S.BARCOD, 
                   		                S.STOCK_CODE, 
                   		                S.PRODUCT_NAME, 
                   		                ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                   		                ESRR.ORDER_ROW_ID,
                   		                0 AS SPECT_MAIN_ID
                   		            FROM          
                   		                STOCKS AS S1 WITH (NOLOCK) INNER JOIN
                   		                EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
                   		                EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                   		                ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
                   		                STOCKS AS S WITH (NOLOCK) INNER JOIN
                   		                EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON S1.STOCK_ID = EPS.MODUL_ID
                   		            WHERE      
                   		                ESR.SHIP_RESULT_INTERNALDEMAND_ID IN (#sevk_talep_id_list#) AND
                   		                ISNULL(S1.IS_PROTOTYPE,0) = 0
                   		            GROUP BY 
                   		                EPS.PAKET_ID, 
                   		                S.BARCOD, 
                   		                S.STOCK_CODE, 
                   		                S.PRODUCT_NAME, 
                   		                ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                   		                ESRR.ORDER_ROW_ID
                   		          	UNION ALL
                   		        	SELECT
                   		                SUM(ORR.QUANTITY) AS PAKET_SAYISI, 
                   		                S1.STOCK_ID AS PAKET_ID,
                   		                S1.BARCOD,
                   		                S1.STOCK_CODE,
                   		                S1.PRODUCT_NAME,
                   		                ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                   		                ESRR.ORDER_ROW_ID, 
                   		                SP.SPECT_MAIN_ID
                   		            FROM            
                   		                SPECTS AS SP WITH (NOLOCK) INNER JOIN
                   		                EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
                   		                EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                   		                ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                   		                STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID
                   		            WHERE        
                   		                ESR.SHIP_RESULT_INTERNALDEMAND_ID IN (#sevk_talep_id_list#) AND 
                   		                ISNULL(S1.IS_PROTOTYPE, 0) = 1
                   		            GROUP BY 
                   		                S1.STOCK_ID,
                   		                SP.SPECT_MAIN_ID, 
                   		                ESR.SHIP_RESULT_INTERNALDEMAND_ID, 
                   		                ESRR.ORDER_ROW_ID, 
                   		                S1.STOCK_CODE, 
                   		                S1.PRODUCT_NAME, 
                   		                S1.BARCOD
                   		                
                   		            ) AS TBL1
                   		        GROUP BY
                   		            PAKET_ID, 
                   		            BARCOD, 
                   		            STOCK_CODE, 
                   		            PRODUCT_NAME, 
                   		            SHIP_RESULT_INTERNALDEMAND_ID,
                   		            SPECT_MAIN_ID
                   		        ) AS TBL
                   		    ) AS TBL2
                      	GROUP BY
                   			SHIP_RESULT_INTERNALDEMAND_ID 
                	</cfquery>
                </cfif>
                <cfquery name="GET_TALEP_SEVK" datasource="#DSN3#">
                	SELECT     
                   		ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
                   		ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT,
                   		SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID
               		FROM         
                   		(
                   		SELECT     
                   		    PAKET_SAYISI AS PAKETSAYISI, 
                   		    PAKET_ID AS STOCK_ID, 
                   		    BARCOD, 
                   		    STOCK_CODE, 
                   		    PRODUCT_NAME,
                   		    SHIP_RESULT_INTERNALDEMAND_ID,
                   		    (
                   		    SELECT     
                   		        SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                   		    FROM          
                   		        EZGI_SHIPPING_PACKAGE_LIST WITH (NOLOCK)
                   		    WHERE      
                   		        TYPE = 2 AND 
                   		        STOCK_ID = TBL.PAKET_ID AND 
                   		        SHIPPING_ID = TBL.SHIP_RESULT_INTERNALDEMAND_ID
                   		    ) AS CONTROL_AMOUNT
                   		FROM         
                   		    (
                   		    SELECT
                   		        SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                   		        PAKET_ID, 
                   		        BARCOD, 
                   		        STOCK_CODE, 
                   		        PRODUCT_NAME, 
                   		        PRODUCT_TREE_AMOUNT, 
                   		        SHIP_RESULT_INTERNALDEMAND_ID
                   		    FROM
                   		        (     
                   		        SELECT     
                   		            round(SUM(ORR.QUANTITY * EPS.PAKET_SAYISI),2) AS PAKET_SAYISI, 
                   		            EPS.PAKET_ID, 
                   		            S.BARCOD, 
                   		            S.STOCK_CODE, 
                   		            S.PRODUCT_NAME, 
                   		            S.PRODUCT_TREE_AMOUNT, 
                   		            ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                   		            ESRR.ORDER_ROW_ID
                   		        FROM 
                   		            SPECTS AS SP WITH (NOLOCK) INNER JOIN
                   		            EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
                   		            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                   		            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                   		            STOCKS AS S WITH (NOLOCK) INNER JOIN
                   		            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID INNER JOIN
                   		            STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID   
                   		        WHERE      
                   		            ESR.SHIP_RESULT_INTERNALDEMAND_ID IN (#sevk_talep_id_list#) AND
                   		            ISNULL(S1.IS_PROTOTYPE,0) = 1
                   		        GROUP BY 
                   		            EPS.PAKET_ID, 
                   		            S.BARCOD, 
                   		            S.STOCK_CODE, 
                   		            S.PRODUCT_NAME, 
                   		            S.PRODUCT_TREE_AMOUNT, 
                   		            ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                   		            ESRR.ORDER_ROW_ID
                   		        UNION ALL
                   		        SELECT     
                   		            round(SUM(ORR.QUANTITY * EPS.PAKET_SAYISI),2) AS PAKET_SAYISI, 
                   		            EPS.PAKET_ID, 
                   		            S.BARCOD, 
                   		            S.STOCK_CODE, 
                   		            S.PRODUCT_NAME, 
                   		            S.PRODUCT_TREE_AMOUNT, 
                   		            ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                   		            ESRR.ORDER_ROW_ID
                   		        FROM          
                   		            EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
                   		            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                   		            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                   		            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                   		            STOCKS AS S WITH (NOLOCK) ON EPS.PAKET_ID = S.STOCK_ID INNER JOIN
                   		            STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID
                   		        WHERE      
                   		            ESR.SHIP_RESULT_INTERNALDEMAND_ID IN (#sevk_talep_id_list#) AND
                   		            ISNULL(S1.IS_PROTOTYPE,0) = 0
                   		        GROUP BY 
                   		            EPS.PAKET_ID, 
                   		            S.BARCOD, 
                   		            S.STOCK_CODE, 
                   		            S.PRODUCT_NAME, 
                   		            S.PRODUCT_TREE_AMOUNT, 
                   		            ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                   		            ESRR.ORDER_ROW_ID
                   		        ) AS TBL1
                   		    GROUP BY
                   		        PAKET_ID, 
                   		        BARCOD, 
                   		        STOCK_CODE, 
                   		        PRODUCT_NAME,
                   		        PRODUCT_TREE_AMOUNT, 
                   		        SHIP_RESULT_INTERNALDEMAND_ID
                   		    ) AS TBL
                   		) AS TBL2
                   	GROUP BY
                    	SHIP_RESULT_INTERNALDEMAND_ID
        		</cfquery>
                <cfquery name="GET_PUAN_TALEP" datasource="#DSN3#">
                	SELECT
                     	<cfif attributes.dsp_puan><!---Kişi Puan Gösterecekse--->
                        	ISNULL(PIP.PROPERTY1, 0) AS PUAN,
                      	<cfelse>
                        	0 AS PUAN,	
                        </cfif>
                        ISNULL(TBLB.AMOUNT,0) AS AMOUNT,
                        ESRR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
                     	ORR.ORDER_ID,
                     	ORR.STOCK_ID, 
                       	ORR.PRODUCT_ID, 
                       	ORR.QUANTITY,
                       	ORR.ORDER_ID FIS_ID,
                       	ORR.ORDER_ROW_ID FIS_ROW_ID
                  	FROM  
                    	EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN       
                    	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESRR.SHIP_RESULT_INTERNALDEMAND_ID = ESR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                      	ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID LEFT OUTER JOIN
                    	(
                         	SELECT        
                            	WRK_ROW_RELATION_ID, 
                            	SUM(AMOUNT) AS AMOUNT
                           	FROM            
                             	(
                                	SELECT        
                                    	AMOUNT, 
                                      	WRK_ROW_RELATION_ID
                                   	FROM            
                                     	#dsn#_#session.ep.period_year#_#session.ep.company_id#.INVOICE_ROW WITH (NOLOCK)
                                  	UNION ALL
                                   	SELECT        
                                     	IR.AMOUNT, 
                                     	IR.WRK_ROW_RELATION_ID
                                   	FROM            
                                    	#dsn#_#session.ep.period_year#_#session.ep.company_id#.SHIP_ROW AS SR WITH (NOLOCK) INNER JOIN
                                     	#dsn#_#session.ep.period_year#_#session.ep.company_id#.INVOICE_ROW AS IR WITH (NOLOCK) ON SR.WRK_ROW_ID = IR.WRK_ROW_RELATION_ID
                                   	<cfif get_period_id.recordcount>
                                     	UNION ALL
                                     	SELECT        
                                        	AMOUNT, 
                                          	WRK_ROW_RELATION_ID
                                      	FROM            

                                         	#dsn#_#last_year#_#session.ep.company_id#.INVOICE_ROW WITH (NOLOCK)
                                       	UNION ALL
                                      	SELECT        
                                        	IR.AMOUNT, 
                                           	IR.WRK_ROW_RELATION_ID
                                      	FROM            
                                          	#dsn#_#last_year#_#session.ep.company_id#.SHIP_ROW AS SR WITH (NOLOCK) INNER JOIN
                                       		#dsn#_#last_year#_#session.ep.company_id#.INVOICE_ROW AS IR WITH (NOLOCK) ON SR.WRK_ROW_ID = IR.WRK_ROW_RELATION_ID
                                   	</cfif>
                              	) AS TBLA
                        	GROUP BY 
                             	 WRK_ROW_RELATION_ID
                  		) AS TBLB ON ORR.WRK_ROW_ID = TBLB.WRK_ROW_RELATION_ID INNER JOIN
                        STOCKS AS ST WITH (NOLOCK) ON ST.STOCK_ID = ORR.STOCK_ID
                      	<cfif attributes.dsp_puan>
                        	LEFT OUTER JOIN PRODUCT_INFO_PLUS AS PIP WITH (NOLOCK) ON ORR.PRODUCT_ID = PIP.PRODUCT_ID
                      	</cfif>
                  	WHERE     
                    	ESRR.SHIP_RESULT_INTERNALDEMAND_ID IN (#sevk_talep_id_list#)
        		</cfquery>
           	<cfelse>
            	<cfset GET_TALEP_AMBAR.recordcount =0>
                <cfset GET_TALEP_SEVK.recordcount =0>
                <cfset GET_PUAN_TALEP.recordcount =0>
            </cfif>
            <!---*****PUAN GÖSTERİMİ SORGU*******--->

        <cfset arama_yapilmali = 0>
        <cfset attributes.totalrecords = GET_SHIPPING.recordcount>
	<cfelse>
    	<cfset arama_yapilmali = 1>
		<cfset get_order_list.recordcount = 0>
    </cfif>
<cfelse>
	<cfset arama_yapilmali = 1>
	<cfset get_order_list.recordcount = 0>
</cfif>
<cfquery name="get_department_name" datasource="#DSN#">
	SELECT 
		SL.LOCATION_ID,
		SL.COMMENT,
		D.DEPARTMENT_ID,
		D.DEPARTMENT_HEAD,
		D.BRANCH_ID
	FROM
		STOCKS_LOCATION SL WITH (NOLOCK),
		DEPARTMENT D WITH (NOLOCK)
	WHERE 
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID
		AND D.BRANCH_ID IN (SELECT BRANCH_ID FROM BRANCH WHERE COMPANY_ID = #session.ep.company_id#)
        AND D.DEPARTMENT_ID IN (#condition_departments_list#)
	ORDER BY
		D.DEPARTMENT_HEAD,
		SL.COMMENT
</cfquery>
<cfquery name="get_branch" datasource="#dsn#">
	SELECT BRANCH_ID,BRANCH_NAME FROM BRANCH WHERE COMPANY_ID = #session.ep.company_id# ORDER BY BRANCH_NAME
</cfquery>
<cfquery name="get_kur" datasource="#dsn#">
	SELECT (RATE2/RATE1) RATE,MONEY,RECORD_DATE FROM MONEY_HISTORY ORDER BY MONEY_HISTORY_ID DESC
</cfquery>
<cfquery name="get_city" datasource="#dsn#">
	SELECT CITY_NAME FROM SETUP_CITY ORDER BY CITY_NAME
</cfquery>
<cfquery name="GET_SHIP_METHOD" datasource="#DSN#">

	SELECT SHIP_METHOD_ID, SHIP_METHOD FROM SHIP_METHOD ORDER BY SHIP_METHOD
</cfquery>
<cfquery name="GET_PRODUCT_CATS" datasource="#dsn1#">
	SELECT     
    	PC.HIERARCHY, 
        PC.PRODUCT_CAT
	FROM         
    	PRODUCT_CAT AS PC INNER JOIN
        PRODUCT_CAT_OUR_COMPANY AS PCOC ON PC.PRODUCT_CATID = PCOC.PRODUCT_CATID
	WHERE     
    	PCOC.OUR_COMPANY_ID = #session.ep.company_id# 
 	ORDER BY
    	PRODUCT_CAT
</cfquery>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="order_form" method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
        	<input name="form_varmi" id="form_varmi" value="1" type="hidden">
            <cfinput type="hidden" name="today_value" id="today_value" value="#DateFormat(now(),dateformat_style)#">
            <cf_box_search>
                <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group" id="form_ul_keyword">
                	<select name="report_type_id" id="report_type_id" style="width:120px;height:20px">
						<option value="" <cfif attributes.report_type_id eq ''>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
						<option value="1" <cfif attributes.report_type_id eq '1'>selected</cfif>><cf_get_lang dictionary_id='1099.Açık Sevkler'></option>
                      	<option value="2" <cfif attributes.report_type_id eq '2'>selected</cfif>><cf_get_lang dictionary_id='1100.Kapalı Sevkler'></option>
                      	<option value="3" <cfif attributes.report_type_id eq '3'>selected</cfif>><cf_get_lang dictionary_id='714.Hazır Sevkler'></option>
                     	<option value="4" <cfif attributes.report_type_id eq '4'>selected</cfif>><cf_get_lang dictionary_id='715.Kısmi Hazır Sevkler'></option>
					</select>
                </div>
                <div class="form-group" id="form_ul_zone">
                	<select name="zone_id" id="zone_id" style="width:100px;height:20px">
						<option value=""><cf_get_lang dictionary_id='57659.Satis Bölgesi'></option>
						<cfoutput query="sz">
							<option value="#SZ_HIERARCHY#" <cfif attributes.zone_id eq SZ_HIERARCHY>selected</cfif>>#sz_name#</option>
						</cfoutput>
					</select>
                </div>
                <div class="form-group" id="form_ul_sort">
                	<select name="sort_type" id="sort_type" style="width:160px;height:20px">
                      	<option value="1" <cfif attributes.sort_type eq 1>selected</cfif>><cf_get_lang dictionary_id='36818.Teslim Tarihine Göre Artan'></option>
                     	<option value="2" <cfif attributes.sort_type eq 2>selected</cfif>><cf_get_lang dictionary_id='36819.Teslim Tarihine Göre Azalan'></option>
                     	<option value="3" <cfif attributes.sort_type eq 3>selected</cfif>><cf_get_lang dictionary_id="29459.Artan No"></option>
                      	<option value="4" <cfif attributes.sort_type eq 4>selected</cfif>><cf_get_lang dictionary_id="29458.Azalan No"></option>
                      	<option value="5" <cfif attributes.sort_type eq 5>selected</cfif>><cf_get_lang dictionary_id='716.Şirket Adına Göre Artan'></option>
                        <option value="6" <cfif attributes.sort_type eq 6>selected</cfif>><cf_get_lang dictionary_id="40971.Sipariş Noya Göre Artan"></option>
                      	<option value="7" <cfif attributes.sort_type eq 7>selected</cfif>><cf_get_lang dictionary_id="40975.Sipariş Noya Göre Azalan"></option>
                 	</select>
                </div>
                <div class="form-group" id="form_ul_list_type">
                	<select name="listing_type" id="listing_type" style="width:90px;height:20px">
                    	<option value="1" <cfif attributes.listing_type eq 1>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                      	<option value="2" <cfif attributes.listing_type eq 2>selected</cfif>><cf_get_lang dictionary_id='717.Sevk Planları'></option>
                     	<option value="3" <cfif attributes.listing_type eq 3>selected</cfif>><cf_get_lang dictionary_id='45959.Sevk Talebi'></option>
                  	</select> 
                </div>
                <div class="form-group" id="form_ul_date">
                	<div class="col col-12">
                     	<div class="col col-6 pl-0">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='30122.Başlangıç Tarihini Kontrol Ediniz'></cfsavecontent>
                                <cfinput type="text" name="start_date" value="#dateformat(attributes.start_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                            </div>
                       	</div>
                        <div class="col col-6 pl-0">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='30123.Bitiş Tarihini Kontrol Ediniz'></cfsavecontent>
                                <cfinput type="text" name="finish_date" value="#dateformat(attributes.finish_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
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
                    <div class="form-group" id="form_ul_employee">
                        <div class="input-group">
                            <input type="hidden" name="order_employee_id" id="order_employee_id" value="<cfif isdefined('attributes.order_employee_id') and len(attributes.order_employee_id) and isdefined('attributes.order_employee') and len(attributes.order_employee)><cfoutput>#attributes.order_employee_id#</cfoutput></cfif>">
                            <input name="order_employee" type="text" id="order_employee" style="width:115px;" onfocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','order_employee_id','','3','125');" value="<cfif isdefined('attributes.order_employee_id') and len(attributes.order_employee_id)><cfoutput>#attributes.order_employee#</cfoutput></cfif>" autocomplete="off" placeholder="<cf_get_lang dictionary_id='40101.Gönderen'>">	
                            <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=order_form.order_employee_id&field_name=order_form.order_employee&is_form_submitted=1&select_list=1','list');"></span>
                        </div>      
                    </div>
                    <div class="form-group" id="form_ul_cari">
                        <div class="input-group">
                        	<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
                        	<input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
                        	<input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
                        	<input name="member_name" type="text" id="member_name" style="width:115px;" onfocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','get_member_autocomplete','\'1,2\'','CONSUMER_ID,COMPANY_ID,MEMBER_TYPE','consumer_id,company_id,member_type','','3','250');" value="<cfif isdefined("attributes.member_name") and len(attributes.member_name)><cfoutput>#attributes.member_name#</cfoutput></cfif>" autocomplete="off" placeholder="<cf_get_lang dictionary_id='57519.Cari Hesap'>">
                        	<cfset str_linke_ait="&field_consumer=order_form.consumer_id&field_comp_id=order_form.company_id&field_member_name=order_form.member_name&field_type=order_form.member_type">
                            <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars<cfoutput>#str_linke_ait#<cfif fusebox.circuit eq "store">&is_store_module=1</cfif></cfoutput>&select_list=7,8&keyword='+encodeURIComponent(document.order_form.member_name.value),'list');"></span>
                        </div>      
                    </div>
                    <div class="form-group" id="form_ul_project_id">	
						<div class="input-group">
							<input type="hidden" name="project_id" id="project_id" value="<cfif isdefined("attributes.project_id") and len (attributes.project_head)><cfoutput>#attributes.project_id#</cfoutput></cfif>">
							<input type="text" name="project_head"  id="project_head" placeholder="<cfoutput><cf_get_lang dictionary_id='57416.Proje'></cfoutput>" value="<cfif Len(attributes.project_head)><cfoutput>#get_project_name(attributes.project_id)#</cfoutput></cfif>" onfocus="AutoComplete_Create('project_head','PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','','3','200');" autocomplete="off">
							<span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_projects&project_id=order_form.project_id&project_head=order_form.project_head');"></span>
						</div>
					</div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="2" sort="true">
                	<div class="form-group" id="form_ul_urun">
                        <div class="input-group">
                        	<input type="hidden" name="product_id" id="product_id" <cfif len(attributes.product_id) and len(attributes.product_name)>value="<cfoutput>#attributes.product_id#</cfoutput>"</cfif>>
                        	<input name="product_name" type="text" id="product_name" style="width:120px;" onfocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME','get_product','0','PRODUCT_ID','product_id','','3','100');" value="<cfif len(attributes.product_id) and len(attributes.product_name)><cfoutput>#attributes.product_name#</cfoutput></cfif>" autocomplete="off"  placeholder="<cf_get_lang dictionary_id='57657.Ürün'>">
                            <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=order_form.product_id&field_name=order_form.product_name&keyword='+encodeURIComponent(document.order_form.product_name.value),'list');"></span>
                        </div>      
                    </div>
                    <div class="form-group" id="form_ul_kategori">
                    	<select name="prod_cat" id="prod_cat" style="width:140px;height:20px">
                            <option value=""><cf_get_lang dictionary_id='57567.Ürün Kategorileri'></option>
                            <cfoutput query="GET_PRODUCT_CATS">
                            	<cfif listlen(hierarchy,".") gte 4>
                                <option value="#hierarchy#"<cfif (attributes.prod_cat eq hierarchy) and len(attributes.prod_cat) eq len(hierarchy)> selected</cfif>>#product_cat#</option>
                                </cfif>
                            </cfoutput>
                        </select>
                    </div>
                    <div class="form-group" id="form_ul_depo">
                    	<select name="sales_departments" id="sales_departments" style="width:130px;height:20px">
                            <option value=""><cf_get_lang dictionary_id='30031.Lokasyon'></option>
                            <cfoutput query="get_department_name">
                                <option value="#department_id#-#location_id#" <cfif isdefined("attributes.sales_departments") and attributes.sales_departments is '#department_id#-#location_id#'>selected</cfif>>#department_head#-#comment#</option>
                            </cfoutput>
                        </select>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="3" sort="true">
                	<div class="form-group" id="form_ul_city">
                    	<select name="city_name" id="city_name" style="width:100px;height:20px">
                            <option value=""><cf_get_lang dictionary_id='57971.Şehir'></option>
                            <cfoutput query="get_city">
                                <option value="#city_name#" <cfif isdefined("attributes.city_name") and attributes.city_name is '#city_name#'>selected</cfif>>#city_name#</option>
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
                    
              	</div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="4" sort="true">
                	<div class="form-group" id="form_ul_shipmethod">
                    	<select name="SHIP_METHOD_ID" id="SHIP_METHOD_ID" style="width:100px;height:90px" multiple="multiple">
                            <option value=""><cf_get_lang dictionary_id='29500.Sevk Yöntemi'></option>
                            <cfoutput query="GET_SHIP_METHOD">
                                <option value="#SHIP_METHOD_ID#" <cfif isdefined("attributes.SHIP_METHOD_ID") and ListFind(attributes.SHIP_METHOD_ID,SHIP_METHOD_ID)>selected</cfif>>#SHIP_METHOD#</option>
                            </cfoutput>
                        </select> 
                    </div>
                </div>
         	</cf_box_search_detail>
      	</cfform>
   	</cf_box>
    <cfsavecontent variable="right">
     	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=sales.popup_list_ezgi_shipping_graph</cfoutput>','longpage');" class="tableyazi">
         	<img src="../../../images/graph.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='718.Sevkiyat Perspektif'>" />
      	</a>&nbsp;&nbsp;
      	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=sales.popup_list_ezgi_shipping_deliver</cfoutput>','longpage');" class="tableyazi">
         	<img src="../../../images/target_customer.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='719.Sevk Planı Açılacak Siparişler'>" />
      	</a>&nbsp;&nbsp;
       	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=sales.popup_list_ezgi_shipping_control</cfoutput>','wide');" class="tableyazi">
         	<img src="../../../images/pos_credit.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='1101.Sevk Talebi Kontrol'>" />
      	</a>&nbsp;&nbsp;
   	</cfsavecontent> 
    <cfsavecontent variable="message"><cf_get_lang dictionary_id="5.Eshipping"></cfsavecontent>
    <cf_box title="#message#" uidrop="1" hide_table_column="1" woc_setting = "#{ checkbox_name : 'print_invoice_id', print_type : 10 }#" right_images="#right#">
    	<cf_grid_list sort="1">
        	<thead>
             	<tr>
                    <th rowspan="2" style="width:30px; height:35px;text-align:center" class="header_icn_txt"><cf_get_lang dictionary_id='58577.Sira'></th>
                    <th rowspan="2" style="width:65px;text-align:center"><cf_get_lang dictionary_id='382.Sevk Plan No'></th>
                    <th rowspan="2" style="width:65px;text-align:center"><cf_get_lang dictionary_id='57073.Belge Tarihi'></th>
					<th rowspan="2" style="width:65px;text-align:center"><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></th>
                    <th rowspan="2" style="text-align:center"><cf_get_lang dictionary_id='57574.sirket'>/Şube</th>
                    <cfif ListFind(session.ep.user_level,25)><!---Operatörün Cari İşlemlere Yetkisi Varsa--->
                        <th rowspan="2" style="width:100px;text-align:center"><cf_get_lang dictionary_id='58615.üye bakiyesi'></th>
                    </cfif>
                    <th rowspan="2" style="width:170px;text-align:center"><cf_get_lang dictionary_id='57899.Kaydeden'></th>
                    <th rowspan="2" style="width:100px;text-align:center"><cf_get_lang dictionary_id='29500.Sevk Yöntemi'></th>
                    <!-- sil -->
                    <th colspan="<cfif attributes.e_shipping_type eq 1>5<cfelse>4</cfif>" style="width:100px;text-align:center"><cf_get_lang dictionary_id="1102.Süreç Kontrolü"></th>
                    <!-- sil -->
                    <th rowspan="2" style="width:100px;text-align:center"><cf_get_lang dictionary_id='36566.Kontrol Eden'></th>
                    <cfif attributes.dsp_puan><!---Kişi Puan Gösterecekse--->
                    	<th rowspan="2" style="width:40px;text-align:center"><cf_get_lang dictionary_id="58984.Puan"></th>
                    </cfif>
                    <th rowspan="2" style="width:100px;text-align:center"><cf_get_lang dictionary_id='57971.Şehir'></th> 
                    <th rowspan="2" style="width:180px;text-align:center"><cf_get_lang dictionary_id='57629.Açıklama'></th>
                    <!-- sil -->
                    <th rowspan="2" style="width:20px" class="header_icn_none" nowrap="nowrap">
                        
                        <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_ezgi_print_files&print_type=79&action_id=#lnk_str#</cfoutput>','wide');"><img src="/images/print_plus.gif" alt="<cf_get_lang dictionary_id='57474.Yazdır'>" border="0" title="<cf_get_lang dictionary_id='57474.Yazdır'>">
                        </a>
                    </th>
                    <th rowspan="2" style="width:20px;text-align:center"><input type="checkbox" alt="<cf_get_lang dictionary_id='57971.Şehir'>" onClick="grupla(-1);"></th>
                    <th rowspan="2" style="width:20px;text-align:center"></th>
                    <!-- sil -->
    
    
                </tr>
                <tr>
                	<!-- sil -->
                    <th style="width:20px;text-align:center"><cf_get_lang dictionary_id='720.SVK.'></th>
                    <cfif attributes.e_shipping_type eq 1>
                    <th style="width:20px;text-align:center"><cf_get_lang dictionary_id='721.HZR.'></th>
                    </cfif>
                    <th style="width:20px;text-align:center"><cf_get_lang dictionary_id='377.KNT.'></th>
                    <th style="width:20px;text-align:center"><cf_get_lang dictionary_id='722.İRS.'></th>
                    <th style="width:20px;text-align:center"><cf_get_lang dictionary_id='723.FTR.'></th>
    				<!-- sil -->
                </tr>
            </thead>
            <tbody>
				<cfset t_point =#attributes.t_point#>
                <cfif isdefined("attributes.form_varmi") and GET_SHIPPING.recordcount>



                        <cfoutput query="GET_SHIPPING" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                        	
                            <cfif IS_TYPE eq 1>	
                            	<cfif attributes.e_shipping_type eq 1> <!---Hazırlık Göster--->
                                    <cfquery name="AMBAR_CONTROL" dbtype="query"><!---Ambar Kontrol Indicator için Kalan Bul---> 
                                		SELECT
                                            PAKET_SAYISI,
                                            CONTROL_AMOUNT
                                        FROM
                                            GET_PLAN_AMBAR
                                        WHERE     
                                            SHIP_RESULT_ID = #SHIP_RESULT_ID#
                                    </cfquery>
                                </cfif>
                                <cfquery name="PACKEGE_CONTROL" dbtype="query"><!---Sevk Kontrol Indicator için Kalan Bul---> 
                                	SELECT
                                        PAKET_SAYISI,
                                        CONTROL_AMOUNT
                                    FROM
                                        GET_PLAN_SEVK
                                    WHERE     
                                    	SHIP_RESULT_ID = #SHIP_RESULT_ID#
                                </cfquery>
                                <cfif GET_PUAN_PLAN.recordcount>
                                    <cfquery name="GET_PUAN" dbtype="query"> <!---Satış Puanları Toplanıyor--->
                                        SELECT
                                            ORDER_ID,
                                            STOCK_ID, 
                                            PRODUCT_ID, 
                                            QUANTITY,
                                            AMOUNT,
                                            FIS_ID,
                                            FIS_ROW_ID,
                                            PUAN,
                                            SHIP_RESULT_ID AS SEVK_ID
                                        FROM         
                                            GET_PUAN_PLAN
                                        WHERE     
                                            SHIP_RESULT_ID = #SHIP_RESULT_ID#
                                    </cfquery>
                                </cfif>
                            <cfelse>
                            	<cfif attributes.e_shipping_type eq 1> <!---Hazırlık Göster--->
                                    <cfquery name="AMBAR_CONTROL" dbtype="query"><!---Ambar Kontrol Indicator için Kalan Bul---> 
                                		SELECT
                                            PAKET_SAYISI,
                                            CONTROL_AMOUNT
                                        FROM
                                            GET_TALEP_AMBAR
                                        WHERE     
                                            SHIP_RESULT_ID = #SHIP_RESULT_ID#
                                    </cfquery>
                                </cfif>
                                <cfquery name="PACKEGE_CONTROL" dbtype="query"><!---Sevk Kontrol Indicator için Kalan Bul---> 
                                	SELECT
                                        PAKET_SAYISI,
                                        CONTROL_AMOUNT
                                    FROM
                                        GET_TALEP_SEVK
                                    WHERE     
                                    	SHIP_RESULT_ID = #SHIP_RESULT_ID#
                                </cfquery>
                                <cfif GET_PUAN_TALEP.recordcount>
                                    <cfquery name="GET_PUAN" dbtype="query"> <!---Satış Puanları Toplanıyor--->
                                        SELECT     
                                            PUAN, 
                                            QUANTITY, 
                                            AMOUNT,
                                            PRODUCT_ID, 
                                            STOCK_ID, 
                                            SHIP_RESULT_ID AS SEVK_ID, 
                                            FIS_ID, 
                                            ORDER_ID,
                                            FIS_ROW_ID
                                        FROM
                                            GET_PUAN_TALEP
                                        WHERE     
                                            SHIP_RESULT_ID = #SHIP_RESULT_ID#
                                    </cfquery>
                                </cfif>
                            </cfif>
                            <cfset row_point = 0>
                            <cfquery name="get_order_id_list" dbtype="query">
                                SELECT
                                    FIS_ID
                                FROM
                                    GET_PUAN
                                GROUP BY
                                    FIS_ID
                            </cfquery>
                            <cfquery name="get_invoice_durum" dbtype="query"><!---Fatura Indicator için Kalan Bul---> 
                            	SELECT
                                    SEVK_ID,
                                    SUM(QUANTITY) AS QUANTITY,
                                    SUM(AMOUNT) AS AMOUNT
                                FROM
                                    GET_PUAN
                                GROUP BY
                                    SEVK_ID
                            </cfquery>
                            <cfset order_id_list = Valuelist(get_order_id_list.FIS_ID)>
                            <cfset order_row_id_list = Valuelist(GET_PUAN.FIS_ROW_ID)>
                            <cfloop query="GET_PUAN">
                                <cfif len(GET_PUAN.puan) and isnumeric(GET_PUAN.puan)>
                                    <cfset row_point = row_point + GET_PUAN.puan*GET_PUAN.QUANTITY>
                                    <cfset t_point =t_point+GET_PUAN.puan*GET_PUAN.QUANTITY>
                                </cfif>
                            </cfloop>
                                <tr>
                                    <td style="text-align:right">#currentrow#</td>
                                    <td style="text-align:center">
                                        <cfif IS_TYPE eq 1>
                                        	<strong>
                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping&iid=#SHIP_RESULT_ID#','wide');" class="tableyazi" title="<cf_get_lang dictionary_id='724.Sevk Fişine Git'>">
                                            #DELIVER_PAPER_NO#
                                            </a>
                                            </strong>
                                        <cfelse>
                                            <strong>
                                            	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_internaldemand&iid=#SHIP_RESULT_ID#','wide');" class="tableyazi" title="<cf_get_lang dictionary_id='727.Sevk Talebine Git'>">
                                                    #DELIVER_PAPER_NO#
                                                </a>
                                            </strong>
                                        </cfif> 
                                        <br />
                                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.list_order&event=upd&order_id=#ORDER_ID#','longpage');" class="tableyazi" title="<cf_get_lang dictionary_id='728.Satış Siparişine Git'>">
                                        	#ORDER_NUMBER#
                                    	</a>      
                                    </td>
                                    <td style="text-align:center">#DateFormat(OUT_DATE,dateformat_style)#</td>
                                    <td style="text-align:center">#DateFormat(ORDER_DATE,dateformat_style)#</td>
                                    <td>
                                        <cfif IS_TYPE eq 1>
                                        	<strong> 
                                            	#UNVAN#<br>
                                            </strong>
                                            (#BRANCH_NAME#)
                                        <cfelse>
                                            <strong>        
                                            #DEPARTMENT_HEAD#<br>
                                            </strong>
                                            (#UNVAN#)
                                        </cfif>
                                    </td>
                                    <cfif ListFind(session.ep.user_level,25)>
                                        <td style="text-align:right;cursor:pointer" onclick="detail_member('#company_id#','#consumer_id#');">
                                            <cfif IS_TYPE eq 1>
                                                <!---<cfset get_bakiye.recordcount =0>--->
                                                <cfif len(company_id)>
                                                    <cfquery name="get_bakiye" datasource="#dsn2#">
                                                        SELECT        
                                                            BAKIYE3, 
                                                            OTHER_MONEY
                                                        FROM      
                                                            COMPANY_REMAINDER_MONEY
                                                        WHERE        
                                                            COMPANY_ID = #company_id#
                                                    </cfquery>
                                                <cfelseif len(consumer_id)>
                                                    <cfquery name="get_bakiye" datasource="#dsn2#">
                                                        SELECT        
                                                            BAKIYE3, 
                                                            OTHER_MONEY
                                                        FROM      
                                                            CONSUMER_REMAINDER_MONEY
                                                        WHERE        
                                                            CONSUMER_ID = #consumer_id#
                                                    </cfquery>
                                                </cfif>
                                                <cfif get_bakiye.recordcount>
                                                    <cfloop query="get_bakiye">
                                                    <font style="color:<cfif bakiye3 lte 0>blue<cfelse>red</cfif>">
                                                        #TlFormat(BAKIYE3,2)# #OTHER_MONEY# 
                                                    </font><cfif get_bakiye.recordcount gt get_bakiye.currentrow><br/></cfif>
                                                    </cfloop>
                                                </cfif>
                                            </cfif>
                                        </td>
                                    </cfif>
                                    <td>
                                    	#get_emp_info(DELIVER_EMP,0,0)#
                                    </td>
                                    <td>#SHIP_METHOD#</td>
                                    <!-- sil -->
                                    <td style="text-align:center"> <!---Sevk Indicator--->
                                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_sevk&iid=#SHIP_RESULT_ID#&is_type=#is_type#','page');" class="tableyazi" title="<cf_get_lang_main no='3533.Sevk Emri Ver'>">
                                            <cfif  SEVK_DURUM eq 2>
                                                <img src="../../../images/yellow_glob.gif" border="0" title="<cf_get_lang dictionary_id='1093.Hepsi Açık'>" />
                                            <cfelseif  SEVK_DURUM eq 1>
                                                <img src="../../../images/red_glob.gif" border="0" title="<cf_get_lang dictionary_id='1094.Hepsi Kapalı'>" />
                                            <cfelseif  SEVK_DURUM eq 6>
                                                <img src="../../../images/green_glob.gif" border="0"title="<cf_get_lang dictionary_id='730.Kısmi Sevk'>" />
                                            <cfelseif  SEVK_DURUM eq 4>
                                                <img src="../../../images/blue_glob.gif" border="0"title="<cf_get_lang dictionary_id='731.Tüm Ürünler Hazır'>" />
                                            <cfelseif  SEVK_DURUM eq 5>
                                                <img src="../../../images/black_glob.gif" border="0"title="<cf_get_lang dictionary_id='732.Düzeltilmesi Gereken Sevk Talebi'>" />
                                          	 <cfelseif  SEVK_DURUM eq 7>
                                                <img src="../../../images/grey_glob.gif" border="0"title="Sevk Talebi Gönderi Öncesi Şubenin Müşteriye Teslimatı" />
                                            </cfif>
                                        </a>
                                    </td>
    								<!-- sil -->
                                    <cfif attributes.e_shipping_type eq 1>
                                        <!-- sil -->
                                        <td style="text-align:center"> <!---Hazırlama Indicator--->
                                            <cfif AMBAR_CONTROL.recordcount AND AMBAR_CONTROL.PAKET_SAYISI eq 0 and AMBAR_CONTROL.CONTROL_AMOUNT eq 0>
                                                <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_ambar_control&ref_no=#DELIVER_PAPER_NO#&ship_id=#SHIP_RESULT_ID#&is_type=#is_type#','wide');" class="tableyazi" title="<cf_get_lang dictionary_id='733.Detay Göster'>"><img src="/images/plus_ques.gif" border="0" title="<cf_get_lang dictionary_id='29975.Barkod Yok'>">
                                                </a>
                                             <cfelseif AMBAR_CONTROL.recordcount AND ceiling(AMBAR_CONTROL.PAKET_SAYISI) - ceiling(AMBAR_CONTROL.CONTROL_AMOUNT) eq 0>
                                                <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_ambar_control&ref_no=#DELIVER_PAPER_NO#&ship_id=#SHIP_RESULT_ID#&is_type=#is_type#','wide');" class="tableyazi" title="<cf_get_lang dictionary_id='733.Detay Göster'>"><img src="/images/red_glob.gif" border="0" title="<cf_get_lang dictionary_id='334.Sevk Edildi'>.">
                                                </a>
                                             <cfelseif AMBAR_CONTROL.recordcount AND AMBAR_CONTROL.CONTROL_AMOUNT eq 0>
                                                <cfif IS_SEVK_EMIR eq 1>
                                                    <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_ambar_control&ref_no=#DELIVER_PAPER_NO#&ship_id=#SHIP_RESULT_ID#&is_type=#is_type#','wide');" class="tableyazi" title="<cf_get_lang dictionary_id='733.Detay Göster'>"><img src="/images/blue_glob.gif" border="0" title="<cf_get_lang dictionary_id='734.Sevk Emri Verildi.'>">
                                                    </a>
                                                <cfelse>
                                                    <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_ambar_control&ref_no=#DELIVER_PAPER_NO#&ship_id=#SHIP_RESULT_ID#&is_type=#is_type#','wide');" class="tableyazi" title="<cf_get_lang dictionary_id='733.Detay Göster'>"><img src="/images/yellow_glob.gif" border="0" title="<cf_get_lang dictionary_id='335.Sevk Edilmedi'>.">
                                                    </a>
                                                </cfif>
                                             <cfelseif AMBAR_CONTROL.recordcount AND AMBAR_CONTROL.PAKET_SAYISI gt AMBAR_CONTROL.CONTROL_AMOUNT>
                                                <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_ambar_control&ref_no=#DELIVER_PAPER_NO#&ship_id=#SHIP_RESULT_ID#&is_type=#is_type#','wide');" class="tableyazi" title="<cf_get_lang dictionary_id='733.Detay Göster'>"><img src="/images/green_glob.gif" border="0" title="<cf_get_lang dictionary_id='336.Eksik Sevkiyat'>.">
                                                </a>
                                             <cfelseif AMBAR_CONTROL.recordcount AND ceiling(AMBAR_CONTROL.PAKET_SAYISI) lt ceiling(AMBAR_CONTROL.CONTROL_AMOUNT)>
                                                <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_ambar_control&ref_no=#DELIVER_PAPER_NO#&ship_id=#SHIP_RESULT_ID#&is_type=#is_type#','wide');" class="tableyazi" title="<cf_get_lang dictionary_id='733.Detay Göster'>"><img src="/images/black_glob.gif" border="0" title="<cf_get_lang dictionary_id='337.Fazla Sevkiyat'>">  
                                                </a>
                                             </cfif>
                                        </td>
                                        <!-- sil -->
                                    <cfelse>
                                        <cfset AMBAR_CONTROL.recordcount = 0>
                                        <cfset AMBAR_CONTROL.PAKET_SAYISI =0>
                                        <cfset AMBAR_CONTROL.CONTROL_AMOUNT = 0>
                                    </cfif>
                                    <!-- sil -->
                                    <td style="text-align:center"> <!---El Terminali 1 Kontrol Indicator--->
                                        <cfif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI eq 0 and PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_term_control&ship_id=#SHIP_RESULT_ID#&is_type=#is_type#','page');" class="tableyazi" title="<cf_get_lang dictionary_id='733.Detay Göster'>">
                                                <img src="/images/plus_ques.gif" border="0" title="<cf_get_lang dictionary_id='29975.Barkod Yok'>." />
                                            </a>
                                        <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI - PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_term_control&ship_id=#SHIP_RESULT_ID#&is_type=#is_type#','page');" class="tableyazi" title="<cf_get_lang dictionary_id='733.Detay Göster'>">
                                                <img src="/images/red_glob.gif" border="0" title="<cf_get_lang dictionary_id='330.Kontrol Edildi'>.">
                                            </a>
                                         <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_term_control&ship_id=#SHIP_RESULT_ID#&is_type=#is_type#','page');" class="tableyazi" title="<cf_get_lang dictionary_id='733.Detay Göster'>">
                                                <img src="/images/yellow_glob.gif" border="0" title="<cf_get_lang dictionary_id='331.Kontrol Edilmedi'>.">
                                            </a>
                                         <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI gt PACKEGE_CONTROL.CONTROL_AMOUNT>
                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_term_control&ship_id=#SHIP_RESULT_ID#&is_type=#is_type#','page');" class="tableyazi" title="<cf_get_lang dictionary_id='733.Detay Göster'>">	
                                                <img src="/images/green_glob.gif" border="0" title="<cf_get_lang dictionary_id='332.Kontrol Eksik'>."> 
                                            </a>  
                                         <cfelse>
                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_term_control&ship_id=#SHIP_RESULT_ID#&is_type=#is_type#','page');" class="tableyazi" title="<cf_get_lang dictionary_id='733.Detay Göster'>">	
                                                <img src="/images/black_glob.gif" border="0" title="<cf_get_lang dictionary_id='735.Teslimat Miktarı Düşürülmüş.'>"> 
                                            </a> 
                                         </cfif>
                                    </td>
                                    <td style="text-align:center"> <!---İrsaliye Indicator--->
                                        <cfif IS_TYPE eq 1>
                                            <cfif DURUM eq 1>
                                                <cfif (attributes.e_shipping_type eq 1 and AMBAR_CONTROL.recordcount and ceiling(AMBAR_CONTROL.PAKET_SAYISI) - ceiling(AMBAR_CONTROL.CONTROL_AMOUNT) eq 0 and PACKEGE_CONTROL.recordcount and ceiling(PACKEGE_CONTROL.PAKET_SAYISI) - ceiling(PACKEGE_CONTROL.CONTROL_AMOUNT) eq 0) or (attributes.e_shipping_type neq 1 and PACKEGE_CONTROL.recordcount and ceiling(PACKEGE_CONTROL.PAKET_SAYISI) - ceiling(PACKEGE_CONTROL.CONTROL_AMOUNT) eq 0)>
                                                	<cfif get_shipping_default.IS_FAST_SALES_REICIPT eq 1><!---Hızlı İrsaliye Oluştur İse--->
                                                    	<a href="javascript://" onclick="add_ship_sale(#SHIP_RESULT_ID#);" class="tableyazi" title="<cf_get_lang_main no='3543.Depolararası Sevk İrsaliyesi Oluştur'>">
                                                        	<img src="../../../images/yellow_glob.gif" border="0" title="<cf_get_lang dictionary_id='736.Satış İrsaliyesi Oluştur'>" />
                                                    	</a>
                                                    <cfelse><!---Hızlı İrsaliye Oluştur Değil İse--->
														<cfif Listlen(order_id_list) eq 1><!---Birden Fazla Siparişe Bağlı İrsaliye Olacaksa--->
                                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=stock.form_add_sale&order_id=#order_id_list#&order_row_id=#order_row_id_list#','longpage');" class="tableyazi" title="<cf_get_lang_main no='3540.Satış İrsaliyesi Oluştur'>">
                                                        <cfelse><!---Tek Siparişe Bağlı İrsaliye Olacaksa--->
                                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=stock.form_add_sale&shipping_id=#SHIP_RESULT_ID#&order_id=#ListGetAt(order_id_list,1)#&ezgi_order_row_id=#order_row_id_list#&order_row_id=0','longpage');" class="tableyazi" title="<cf_get_lang_main no='3540.Satış İrsaliyesi Oluştur'>">
                                                        </cfif>
                                                            <img src="../../../images/yellow_glob.gif" border="0" title="<cf_get_lang dictionary_id='1093.Hepsi Açık'>" />
                                                        </a>
                                                    </cfif>
                                                <cfelse>
                                                    <img src="../../../images/yellow_glob.gif" border="0" title="<cf_get_lang dictionary_id='737.Kontrol Tamamlanmamış Sevkiyat'>" />
                                                </cfif>
                                            <cfelseif DURUM eq 2>
                                                <img src="../../../images/red_glob.gif" border="0" title="<cf_get_lang dictionary_id='1103.Tamamı Sevk Edildi'>" />
                                            <cfelseif DURUM eq 3>
                                                 <cfif ceiling(PACKEGE_CONTROL.PAKET_SAYISI) - ceiling(PACKEGE_CONTROL.CONTROL_AMOUNT) eq 0>
                                                    <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=stock.form_add_sale&<cfif Listlen(order_id_list) eq 1>order_id=#order_id_list#&order_row_id=#order_row_id_list#<cfelse></cfif>','longpage');" class="tableyazi" title="Satış İrsaliyesi Oluştur">
                                                        <img src="../../../images/green_glob.gif" border="0"title="<cf_get_lang dictionary_id='3542.Kısmi Kapandı'>" />
                                                    </a>
                                                <cfelse>
                                                    <img src="../../../images/green_glob.gif" border="0"title="<cf_get_lang dictionary_id='3542.Kısmi Kapandı'>" />
                                                </cfif>
                                            </cfif>
                                        <cfelse>
                                            <cfif DURUM eq 1>
                                                <cfif (attributes.e_shipping_type eq 1 and ceiling(AMBAR_CONTROL.recordcount) AND ceiling(AMBAR_CONTROL.PAKET_SAYISI) - ceiling(AMBAR_CONTROL.CONTROL_AMOUNT) eq 0 and ceiling(PACKEGE_CONTROL.recordcount) AND ceiling(PACKEGE_CONTROL.PAKET_SAYISI) - ceiling(PACKEGE_CONTROL.CONTROL_AMOUNT) eq 0) or attributes.e_shipping_type neq 1>
                                                    <a href="javascript://" onclick="add_ship_dispatch(#SHIP_RESULT_ID#);" class="tableyazi" title="<cf_get_lang_main no='3543.Depolararası Sevk İrsaliyesi Oluştur'>">
                                                        <img src="../../../images/yellow_glob.gif" border="0" title="<cf_get_lang dictionary_id='1093.Hepsi Açık'>" />
                                                    </a>
                                                <cfelse>
                                                    <img src="../../../images/yellow_glob.gif" border="0" title="<cf_get_lang dictionary_id='737.Kontrol Tamamlanmamış Sevkiyat'>" />
                                                </cfif>
                                            <cfelseif DURUM eq 2>
    
                                                <img src="../../../images/red_glob.gif" border="0" title="<cf_get_lang dictionary_id='1103.Tamamı Sevk Edildi'>" />
                                            </cfif>
                                        </cfif>
                                    </td>
                                    <td style="text-align:center"> <!---Fatura Indicator--->
                                    	<cfif get_invoice_durum.AMOUNT neq 0 and get_invoice_durum.QUANTITY gt get_invoice_durum.AMOUNT>
                                         	<img src="../../../images/green_glob.gif" border="0" title="<cf_get_lang dictionary_id='1104.Kısmi Faturalandı'>" />
                                      	<cfelseif get_invoice_durum.AMOUNT neq 0 and get_invoice_durum.QUANTITY eq get_invoice_durum.AMOUNT>
                                        	<img src="../../../images/red_glob.gif" border="0" title="<cf_get_lang dictionary_id='39125.Faturalandı'>" />
                                      	<cfelseif get_invoice_durum.AMOUNT neq 0 and get_invoice_durum.QUANTITY lt get_invoice_durum.AMOUNT>
                                        	<img src="../../../images/black_glob.gif" border="0" title="Fazla <cf_get_lang dictionary_id='39125.Faturalandı'>" />
                                        <cfelse>
                                            <cfif DURUM eq 1>
                                                <cfif (attributes.e_shipping_type eq 1 and AMBAR_CONTROL.recordcount and ceiling(AMBAR_CONTROL.PAKET_SAYISI) - ceiling(AMBAR_CONTROL.CONTROL_AMOUNT) eq 0 and PACKEGE_CONTROL.recordcount and ceiling(PACKEGE_CONTROL.PAKET_SAYISI) - ceiling(PACKEGE_CONTROL.CONTROL_AMOUNT) eq 0) or (attributes.e_shipping_type neq 1 and PACKEGE_CONTROL.recordcount and ceiling(PACKEGE_CONTROL.PAKET_SAYISI) - ceiling(PACKEGE_CONTROL.CONTROL_AMOUNT) eq 0)>
                                                    <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=invoice.form_add_bill&<cfif Listlen(order_id_list) eq 1>order_id=#order_id_list#&order_row_id=#order_row_id_list#<cfelse>order_id=#ListGetAt(order_id_list,1)#</cfif>','longpage');" class="tableyazi" title="<cf_get_lang_main no='3545.Toptan Satış Faturası Oluştur'>">
                                                        <img src="../../../images/yellow_glob.gif" border="0" title="<cf_get_lang dictionary_id='1105.Tümü Faturalanacak'>" />
                                                    </a>
                                                <cfelse>
                                                    <img src="../../../images/yellow_glob.gif" border="0" title="<cf_get_lang dictionary_id='742.Önce Ambar Fişi Oluşturun'>" />
                                                </cfif>
                                            <cfelse>
                                                <img src="../../../images/yellow_glob.gif" border="0" title="<cf_get_lang dictionary_id='743.Fatura Emirlerden Kesilebilir'> " />
                                            </cfif>
                                        </cfif>
                                    </td> 
                                    <!-- sil -->
                                    <cfquery name="get_control_emp" datasource="#dsn3#">
                                        SELECT DISTINCT RECORD_EMP FROM EZGI_SHIPPING_PACKAGE_LIST WHERE SHIPPING_ID = #SHIP_RESULT_ID# AND TYPE = #IS_TYPE#
                                    </cfquery>
                                    <td>#get_emp_info(get_control_emp.RECORD_EMP,0,0)#</td>
                                    <cfif attributes.dsp_puan><!---Kişi Puan Gösterecekse--->
                                    	<td style="text-align:right">
											<cfif isnumeric(GET_PUAN.puan)>
												<cfif GET_PUAN.puan eq 0>
                                                	<font color="red">
                                                    	#Tlformat(row_point,2)#
                                                  	</font>
                                             	<cfelse>
                                                	#Tlformat(row_point,2)#
                                             	</cfif>
                                         	<cfelse>
                                            	<font color="red">
                                                	-
                                               	</font>
                                          	</cfif>
                                     	</td>
                                    </cfif>
                                    <td style="text-align:center">#SEHIR#<br />#ILCE#</td>
                                    <td title="#NOTE#">#left(NOTE,70)#<cfif len(NOTE) gt 70>...</cfif></td>
                                    <!-- sil -->
                                    <td style="text-align:center;<cfif DURUM neq 1>background-color:red</cfif>"><a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_ezgi_print_files&print_type=32&action_id=#is_type#-#SHIP_RESULT_ID#','page');"><img src="/images/print2.gif" alt="<cf_get_lang_main no='62.Yazdır'>" border="0" title="<cf_get_lang_main no='62.Yazdır'>"></a>
                                    </td>
                                    <td style="text-align:right">
                                        <cfset birlesme_izni = 0>
                                        <cfif IS_TYPE eq 1>
                                     		<cfquery name="get_shipping_group" dbtype="query">
                                     		    SELECT
                                     		        <cfif len(COMPANY_ID)>
                                     		            COMPANY_ID,
                                     		        <cfelseif len(CONSUMER_ID)>
                                     		            CONSUMER_ID,
                                     		        </cfif>
                                     		        SEHIR,
                                     		        ILCE,
                                     		        SHIP_METHOD_TYPE,
                                     		        COUNT(*) AS SAYI
                                     		    FROM
                                     		        GET_SHIPPING
                                     		    WHERE
                                     		        IS_TYPE = 1 AND
                                     		        SHIP_METHOD_TYPE = #SHIP_METHOD_TYPE#  AND
                                     		        <cfif len(COMPANY_ID)>
                                     		            COMPANY_ID = #COMPANY_ID#
                                     		        <cfelseif len(CONSUMER_ID)>
                                     		            CONSUMER_ID = #CONSUMER_ID#
                                     		        </cfif>
                                                    <cfif len(SEHIR)>
                                                    	AND SEHIR = '#SEHIR#'
                                                    </cfif>
                                                    <cfif len(ILCE)>
                                     		        	AND ILCE = '#ILCE#'
                                                  	</cfif>
                                     		    GROUP BY
                                     		        <cfif len(COMPANY_ID)>
                                     		            COMPANY_ID,
                                     		        <cfelseif len(CONSUMER_ID)>
                                     		            CONSUMER_ID,
                                     		        </cfif>
                                     		        SEHIR,
                                     		        ILCE,
                                     		        SHIP_METHOD_TYPE
                                     		</cfquery>
                                     		<cfif get_shipping_group.SAYI gt 1>
                                     		    <cfset birlesme_izni = 1>
                                     		</cfif>
                                        <cfelse>
                                        	<cfquery name="get_shipping_group" dbtype="query">
                                     		    SELECT
													DEPO,
                                     		        SHIP_METHOD_TYPE,
                                     		        COUNT(*) AS SAYI
                                     		    FROM
                                     		        GET_SHIPPING
                                     		    WHERE
                                     		        IS_TYPE = 2 AND
                                     		        SHIP_METHOD_TYPE = #SHIP_METHOD_TYPE# AND
                                     		        DEPO = '#DEPO#' 
                                     		    GROUP BY
                                     		        DEPO,
                                     		        SHIP_METHOD_TYPE
                                     		</cfquery>
                                     		<cfif get_shipping_group.SAYI gt 1>
                                     		    <cfset birlesme_izni = 1>
                                     		</cfif>
                                        </cfif>
                                        <cfif DURUM eq 1>
                                            <input type="checkbox" name="select_production" value="#IS_TYPE#-#SHIP_RESULT_ID#-#birlesme_izni#">
                                        </cfif>

                                  	</td>
                                    <td style="text-align:center">
                                        <cfif birlesme_izni eq 1>
                                            <img src="/images/starton.gif" border="0" title="<cf_get_lang dictionary_id='744.Birleşebilir'>" />
                                        <cfelse>
                                            <img src="/images/stop.gif" border="0" title="<cf_get_lang dictionary_id='745.Birleşemez'>" />
                                        </cfif>
                                    </td>
                                    <!-- sil -->
                                </tr>
                                <cfset son_row = currentrow>
                        </cfoutput>
   
                <cfelse>
                <tr>
                    <td colspan="20"><cfif arama_yapilmali neq 1><cf_get_lang dictionary_id='57484.Kayit Yok'>!<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'>!</cfif></td>
                </tr>
                </cfif>	
            	
           	</tbody>
            <tfoot>
            	<!-- sil -->
				<cfif isdefined("attributes.form_varmi") and GET_SHIPPING.recordcount>
                	
                        <tr>
                            <cfif isdefined('tip')>
                                <td colspan="20">
                                    <font color="red">
                                        <cf_get_lang dictionary_id='746.Önce Hataları Düzeltmelisiniz!!!'>
                                    </font>
                                </td>      
                            <cfelse>
                            	<cfoutput>
                                	<!---<td style="text-align:left;" colspan="<cfif attributes.e_shipping_type eq 1>14<cfelse>13</cfif>"><cfif attributes.totalrecords gt son_row><cfoutput>#getLang('report',462)#</cfoutput><cfelse><cf_get_lang_main no='268.Genel Toplam'></cfif></td>--->
                                 	<td style="text-align:right;" colspan="20">
                                   		<input type="text" name="send_date" id="send_date" value="#dateformat(DateAdd('d',1,now()),dateformat_style)#" validate="eurodate" maxlength="10" style="width:65px;" >
                                      	<cf_wrk_date_image date_field="send_date">
                                      	&nbsp;&nbsp;&nbsp;&nbsp;
                                      	<button  value="" name="gonder" onClick="grupla(-4);" style="width:100px; height:25px;">&nbsp;<cf_get_lang dictionary_id='58743.Gönder'></button>
                                      	<button  value="" name="birles" onClick="grupla(-3);" style="width:100px; height:25px;">&nbsp;<cf_get_lang dictionary_id='747.Birleştir'></button>
                                     	<button  value="" name="yazdir" onClick="grupla(-2);" style="width:100px; height:25px;">&nbsp;<cf_get_lang dictionary_id='50111.Toplu Yazdır'></button>
                                            
                                 	</td>
                             	</cfoutput>
                            </cfif>
                        </tr>
                	
                </cfif>
                <!-- sil -->
            </tfoot>
       	</cf_grid_list>
		<cfset url_str = 'sales.list_ezgi_shipping'>
        <cfif isdefined("attributes.form_varmi") and attributes.totalrecords gt attributes.maxrows>
            <cfif isdefined("attributes.member_type") and len(attributes.member_type)>
                <cfset url_str = url_str & "&member_type=#attributes.member_type#&member_name=#attributes.member_name#">
            </cfif>
            <cfif isdefined("attributes.company_id") and len(attributes.company_id)>
                <cfset url_str = url_str & "&company_id=#attributes.company_id#&member_name=#attributes.member_name#">
            </cfif>
            <cfif isdefined("attributes.product_id") and len(attributes.product_id) and isdefined("attributes.product_name") and len(attributes.product_name)>
                <cfset url_str = url_str & "&product_id=#attributes.product_id#&product_name=#attributes.product_name#">
            </cfif>
            <cfif isdefined("attributes.short_code_id") and len(attributes.short_code_id) and isdefined("attributes.short_code_name") and len(attributes.short_code_name)>
                <cfset url_str = url_str & "&short_code_id=#attributes.short_code_id#&short_code_name=#attributes.short_code_name#">
            </cfif>
            <cfif isdefined("attributes.employee_id") and len(attributes.employee_id) and isdefined("attributes.employee") and len(attributes.employee)>
                <cfset url_str = url_str & "&employee_id=#attributes.employee_id#&employee=#attributes.employee#">
            </cfif>
            
            <cfif isdefined("attributes.prod_cat") and len(attributes.prod_cat)>
                <cfset url_str = url_str & "&prod_cat=#attributes.prod_cat#">
            </cfif>
            <cfif isdefined("attributes.project_id") and len(attributes.project_id) and isdefined("attributes.project_head") and len(attributes.project_head)>
                <cfset url_str = url_str & "&project_id=#attributes.project_id#&project_head=#URLEncodedFormat(attributes.project_head)#">
            </cfif>
            <cfif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
                <cfset url_str = url_str & "&consumer_id=#attributes.consumer_id#">
            </cfif>
            <cfif isdefined("attributes.sales_member_id") and len(attributes.sales_member_id)>
                <cfset url_str = url_str & "&sales_member_id=#attributes.sales_member_id#&sales_member_name=#attributes.sales_member_name#">
            </cfif>
            <cfif isdefined("attributes.sales_departments") and len(attributes.sales_departments)>
                <cfset url_str = "#url_str#&sales_departments=#attributes.sales_departments#">
            </cfif>
            <cfif isdefined("attributes.listing_type") and len(attributes.listing_type)>
            
                <cfset url_str = "#url_str#&listing_type=#attributes.listing_type#">
            </cfif>
            
            <cfif isdefined("attributes.branch_id") and len(attributes.branch_id)>
                <cfset url_str = "#url_str#&branch_id=#attributes.branch_id#">
            </cfif>
            <cfif isdefined("attributes.zone_id") and len(attributes.zone_id)>

                <cfset url_str = "#url_str#&zone_id=#attributes.zone_id#">
            </cfif>
            <cfif isdefined("attributes.city_name") and len(attributes.city_name)>
            
                <cfset url_str = "#url_str#&city_name=#attributes.city_name#">
            </cfif>
            <cfif isdefined("attributes.ship_method_id") and len(attributes.ship_method_id)>
                <cfset url_str = "#url_str#&ship_method_id=#attributes.ship_method_id#">
            </cfif>
            
            <cfif isdate(attributes.start_date)>
                <cfset url_str = url_str & "&start_date=#dateformat(attributes.start_date,dateformat_style)#">
            </cfif>
            <cfif isdate(attributes.finish_date)>
                <cfset url_str = url_str & "&finish_date=#dateformat(attributes.finish_date,dateformat_style)#">
            </cfif>
            <cfif isdefined('attributes.report_type_id')>
                <cfset url_str = url_str & "&report_type_id=#attributes.report_type_id#">
            </cfif>
            <cfif len(t_point)>
                <cfset url_str = url_str & "&t_point=#t_point#">
            </cfif>
            <cfset url_str = url_str & "&order_employee_id=#attributes.order_employee_id#&order_employee=#attributes.order_employee#">
            <cfset url_str = url_str & "&sort_type=#attributes.sort_type#">
            <cfif isdefined("attributes.project_id") and len(attributes.project_id) and isdefined("attributes.project_head") and len(attributes.project_head)>
				<cfset url_str = url_str & "&project_id=#attributes.project_id#&project_head=#URLEncodedFormat(attributes.project_head)#">
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
	function input_control()
	{
			if(document.all.branch_id.value !='' && document.all.listing_type.value ==2)
			{
				alert("<cf_get_lang dictionary_id='3552.Liste Tipi Olarak Sevk Planları İle Şubeyi Birlikte Seçemezsiniz'>!!!.");
				return false
			}
			else
			{
				return true
			}
	}
	function grupla(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
			shipping_id_list = '';
			chck_leng = document.getElementsByName('select_production').length;
			for(ci=0;ci<chck_leng;ci++)
			{
				var my_objets = document.all.select_production[ci];
				if(chck_leng == 1)
					var my_objets =document.all.select_production;
				if(type == -1)
				{//hepsini seç denilmişse	
					if(my_objets.checked == true)
						my_objets.checked = false;
					else
						my_objets.checked = true;
				}
				else
				{
					if(my_objets.checked == true)
						shipping_id_list +=my_objets.value+',';
				}
			}
			shipping_id_list = shipping_id_list.substr(0,shipping_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(shipping_id_list!='')
			{
				if(type == -3)
				{
					var soru = confirm("<cf_get_lang dictionary_id='749.Birleştirilen Sevk Planını Tekrar Geri Alamazsınız'>. <cf_get_lang dictionary_id='58588.Emin misiniz ?'>");
					if(soru==true)
					{
						window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_upd_ezgi_shipping_row&shipping_id_list='+shipping_id_list);
					}
				}
				else if(type == -4)
				{
					if (!date_check(order_form.today_value,document.all.send_date,"Sevk tarihi Bugünden Önceye Yapılamaz.!"))
						return false;
					var soru = confirm("<cf_get_lang dictionary_id='750.Sevkiyatları ilgili Tarihe Gönderiyorum.'> <cf_get_lang dictionary_id='58588.Emin misiniz ?'>");
					if(soru==true)
					{
						send_date = document.getElementById('send_date').value;
						if(send_date.length>0)
							window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_upd_ezgi_shipping_date&shipping_id_list='+shipping_id_list+'&send_date='+send_date);
						else
						{
							alert("<cf_get_lang dictionary_id='751.Gönderilecek Tarih Boş Olamaz !'>");
							return false;
						}
					}
				}
				else if(type == -2)
				{
					window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_print_files&print_type=32&action_id='+shipping_id_list);		
				}
			}
	}
	function detail_member(company_id,consumer_id)
	{
		if(company_id.length>0)
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_com_det&company_id='+company_id,'list');
		else if(consumer_id.length>0)
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_con_det&con_id='+consumer_id,'list');
	}
	function add_ship_dispatch(ship_result_id)
	{
		var sor=confirm("<cf_get_lang dictionary_id='1383.Depolararası Sevk İrsaliyesi Oluşturuyorum'>. <cf_get_lang dictionary_id='58588.Emin misiniz ?'>");
		if(sor==true)
		{
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=stock.emptypopup_add_ezgi_ship_dispatch&ship_result_id='+ship_result_id,'longpage');
		}
		else
			return false;
	}
	function add_ship_sale(ship_result_id)
	{
		var sor=confirm("<cf_get_lang dictionary_id='1382.Satış İrsaliyesi Oluşturuyorum'>. <cf_get_lang dictionary_id='58588.Emin misiniz ?'>");
		if(sor==true)
		{
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=stock.emptypopup_add_ezgi_ship_sale&ship_result_id='+ship_result_id,'longpage');
		}
		else
			return false;
	}
</script>