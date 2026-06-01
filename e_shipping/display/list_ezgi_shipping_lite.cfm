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
<cfparam name="attributes.sort_type" default="4">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.city_name" default="">
<cfparam name="attributes.report_type_id" default="3">
<cfparam name="attributes.zone_id" default="">
<cfparam name="attributes.t_point" default="0">
<cfparam name="attributes.t_weight" default="0">
<cfparam name="attributes.SHIP_METHOD_ID" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.totalrecords" default="0">
<cfquery name="get_default_department" datasource="#dsn#">
	SELECT DEPARTMENT_ID, LOCATION_ID FROM EMPLOYEE_POSITION_DEPARTMENTS WHERE POSITION_CODE = #session.ep.POSITION_CODE# AND OUR_COMPANY_ID = #session.ep.COMPANY_ID#
</cfquery>
<cfif get_default_department.recordcount>
	<cfparam name="attributes.sales_departments" default="#get_default_department.DEPARTMENT_ID#-#get_default_department.LOCATION_ID#">
<cfelse>
	<cfparam name="attributes.sales_departments" default="">
</cfif>
<cfquery name="get_shipping_default" datasource="#dsn3#">
	SELECT ISNULL(SHIPPING_CONTROL_TYPE,0) SHIPPING_CONTROL_TYPE FROM EZGI_SHIPPING_DEFAULTS
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
    	EMPLOYEE_POSITION_BRANCHES 
  	WHERE  
    	POSITION_CODE = #session.ep.POSITION_CODE# AND 
        LOCATION_CODE IS NOT NULL AND
        BRANCH_ID IN
        			(
        				SELECT        
                        	BRANCH_ID
						FROM            
                        	BRANCH
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
	<!---Birleştirdikten sonra adres veya sevk yöntemi değiştirilmiş mi kontrol ediliyor--->
    <cfquery name="get_period_id" datasource="#dsn#">
    	SELECT        
        	PERIOD_YEAR
		FROM            
        	SETUP_PERIOD
		WHERE        
        	OUR_COMPANY_ID = #session.ep.company_id# AND 
            PERIOD_YEAR < #session.ep.period_year#
    </cfquery>
    <cfquery name="GET_SHIPPING" datasource="#dsn3#"><!---Sevk Planları ve Sevk Talepleri Listeleniyor--->
        SELECT 
            *
   		FROM
            (
                    SELECT     
                        ESR.SHIP_RESULT_ID, 
                        ESR.NOTE, 
                        ESR.SEVK_EMIR_DATE,
                        ISNULL(ESR.IS_SEVK_EMIR,0) AS IS_SEVK_EMIR,
                        ISNULL(ESR.SEVK_EMP,0) SEVK_EMP,
                        ESR.SHIP_FIS_NO, 
                        ESR.DELIVER_PAPER_NO, 
                        ESR.DELIVER_EMP,
                        ESR.REFERENCE_NO, 
                        ESR.DELIVERY_DATE, 
                        ESR.DEPARTMENT_ID, 
                        ESR.COMPANY_ID, 
                        ESR.CONSUMER_ID, 
                        ESR.OUT_DATE, 
                        ESR.IS_TYPE, 
                        ESR.LOCATION_ID, 
                        ESR.SHIP_METHOD_TYPE,
                        ISNULL(ESR.IS_INVOICED,0) AS IS_INVOICED,
                        SM.SHIP_METHOD, 
                        OP.ORDER_ID,
                        OP.RECORD_DATE,
                        ISNULL(OP.IS_SEND_WEBSERVICE,0) AS IS_SEND_WEBSERVICE,
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
                                        WHEN OP.RESERVED = 0 THEN 0 
                                    END AS DURUM
                                FROM          
                                    ORDER_ROW AS ORR WITH (NOLOCK)
                                WHERE      
                                    ORR.ORDER_ID = OP.ORDER_ID
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
                                    ORDER_ROW AS ORR WITH (NOLOCK)
                                WHERE      
                                    ORR.ORDER_ID = OP.ORDER_ID
                                ) AS TBL2
                            GROUP BY SEVK_DURUM
                            ) AS TBL3
                        ) AS SEVK_DURUM                        
                    FROM      
                    	EZGI_SHIP_RESULT AS ESR INNER JOIN
                    	#dsn_alias#.SHIP_METHOD AS SM ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID INNER JOIN
                    	EZGI_SHIP_RESULT_ROW AS ESRRP ON ESR.SHIP_RESULT_ID = ESRRP.SHIP_RESULT_ID INNER JOIN
                      	ORDER_ROW AS ORRP ON ESRRP.ORDER_ROW_ID = ORRP.ORDER_ROW_ID INNER JOIN
                     	ORDERS AS OP ON ORRP.ORDER_ID = OP.ORDER_ID
                    WHERE 
                        IS_TYPE = 1 AND
                        OP.ORDER_STATUS = 1
                        <cfif isdefined('attributes.SHIP_METHOD_ID') and len(attributes.SHIP_METHOD_ID)>
                            AND OP.SHIP_METHOD IN (#attributes.SHIP_METHOD_ID#) 
                        </cfif>
                        <cfif isdefined('attributes.member_name') and len(attributes.member_name)>
                            <cfif isdefined('attributes.company_id') and len(attributes.company_id)>
                                AND ESR.COMPANY_ID =#attributes.company_id#
                            </cfif>
                            <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
                                AND ESR.CONSUMER_ID =#attributes.consumer_id# 
                            </cfif>
                        </cfif>
                        <cfif len(attributes.keyword)>
                            AND 
                                (
                                    DELIVER_PAPER_NO LIKE '%#attributes.keyword#%' OR
                                    REFERENCE_NO LIKE '%#attributes.keyword#%'
                                )
                        </cfif>
                        <cfif isdefined('attributes.product_id') and len(attributes.product_id)>
                            AND ESR.SHIP_RESULT_ID IN
                                                (
                                                SELECT DISTINCT 
                                                    ESRR.SHIP_RESULT_ID
                                                FROM          
                                                    EZGI_SHIP_RESULT_ROW AS ESRR INNER JOIN
                                                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
                                                WHERE      
                                                    ORR.PRODUCT_ID = #attributes.product_id#
                                                )
                        </cfif>
                        <cfif isdefined('attributes.prod_cat') and len(attributes.prod_cat)>
                            AND ESR.SHIP_RESULT_ID IN
                                                    (
                                                    SELECT DISTINCT 
                                                        ESRR.SHIP_RESULT_ID
                                                    FROM          
                                                        EZGI_SHIP_RESULT_ROW AS ESRR INNER JOIN
                                                        ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                                        STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID
                                                    WHERE      
                                                        S.STOCK_CODE LIKE N'#attributes.prod_cat#%'
                                                    )                          
                        </cfif>
                        <cfif isdefined('attributes.SALES_DEPARTMENTS') and Listlen(attributes.SALES_DEPARTMENTS,'-') eq 2>
                            AND ESR.DEPARTMENT_ID = #listgetat(attributes.SALES_DEPARTMENTS,1,'-')# 
                            AND ESR.LOCATION_ID = #listgetat(attributes.SALES_DEPARTMENTS,2,'-')#
                        </cfif>
                        <cfif isdefined('attributes.start_date') and len(attributes.start_date)>
                            AND ESR.OUT_DATE >= #attributes.start_date#
                        </cfif>
                        <cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>
                            AND ESR.OUT_DATE < #DateAdd('d',1,attributes.finish_date)#
                        </cfif>
                        <cfif isdefined("attributes.project_id") and len(attributes.project_id) and isdefined("attributes.project_head") and len(attributes.project_head)>
                         	<cfif attributes.project_id eq -1>
                             	AND OP.PROJECT_ID IS NULL
                         	<cfelse>
                               	AND OP.PROJECT_ID = #attributes.project_id#
                         	</cfif>
                       	</cfif>
                        <cfif len(attributes.zone_id)>  
                            AND (
                                ESR.COMPANY_ID IN 	
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
                                ESR.CONSUMER_ID IN 	
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
                        ESR.COMPANY_ID, 
                        ESR.CONSUMER_ID, 
                        ESR.OUT_DATE, 
                        ESR.IS_TYPE, 
                        ESR.LOCATION_ID, 
                        ESR.SHIP_METHOD_TYPE,
                   		ESR.IS_INVOICED,
                        SM.SHIP_METHOD, 
                        OP.ORDER_ID,
                        OP.RESERVED,
                        OP.RECORD_DATE,
                        OP.IS_SEND_WEBSERVICE
            ) AS TBL
        WHERE
            DURUM IN (1,2,3,4,5,6,7)
            <cfif attributes.report_type_id eq 1>
                AND DURUM = 1
            <cfelseif attributes.report_type_id eq 2>
                AND DURUM = 2
            <cfelseif attributes.report_type_id eq 3>
                AND SEVK_DURUM = 4
          	<cfelseif attributes.report_type_id eq 4>
                AND SEVK_DURUM = 6
          	<cfelseif attributes.report_type_id eq 5>
            	AND SEVK_DURUM <> 4 AND SEVK_DURUM <> 6 AND DURUM = 1
          	<cfelseif attributes.report_type_id eq 6>
            	AND SEVK_DURUM = 4 AND IS_SEND_WEBSERVICE = 1
          	<cfelseif attributes.report_type_id eq 7>
            	AND SEVK_DURUM = 4 AND IS_SEND_WEBSERVICE = 0
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
                DEPARTMENT_ID,COMPANY_ID, CONSUMER_ID, SHIP_FIS_NO
            </cfif>
    </cfquery>
    <cfset arama_yapilmali = 0>
    <cfset attributes.totalrecords = GET_SHIPPING.recordcount>
    <cfif isdefined('attributes.is_control')>
    	<cfif GET_SHIPPING.recordcount>
        	<cfset ship_result_id_list = ''>
        	<cfoutput query="GET_SHIPPING" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
				<cfset ship_result_id_list = ListAppend(ship_result_id_list,GET_SHIPPING.SHIP_RESULT_ID)>
         	</cfoutput>
     		<cfquery name="PACKEGE_CONTROL" datasource="#DSN3#"> <!---Paket Kontrolü kontrol ediliyor--->
              	SELECT     
               		ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
                  	ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT,
                  	SHIP_RESULT_ID
            	FROM         
                	(
                    	SELECT  
                        	SHIP_RESULT_ID,   
                         	PAKET_SAYISI AS PAKETSAYISI, 
                          	PAKET_ID AS STOCK_ID, 
                         	BARCOD, 
                         	STOCK_CODE, 
                        	PRODUCT_NAME,
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
                                         	EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
                                         	EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                                        	ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                         	EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                                         	STOCKS AS S WITH (NOLOCK) ON EPS.PAKET_ID = S.STOCK_ID INNER JOIN
                                          	STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID
                                     	WHERE      
                                         	ESR.SHIP_RESULT_ID IN (#ship_result_id_list#) AND
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
            <cfif PACKEGE_CONTROL.recordcount>
            	<cfoutput query="PACKEGE_CONTROL">
					<cfset 'PAKET_SAYISI_#SHIP_RESULT_ID#' = PAKET_SAYISI>
                    <cfset 'CONTROL_AMOUNT_#SHIP_RESULT_ID#' = CONTROL_AMOUNT>
                </cfoutput>
            </cfif>
        </cfif>  
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
                      	<option value="3" <cfif attributes.report_type_id eq '3'>selected</cfif>>Hazır Olan Sevkler</option>
                        <option value="6" <cfif attributes.report_type_id eq '6'>selected</cfif>>Hazır Bildirilen Sevkler</option>
                        <option value="7" <cfif attributes.report_type_id eq '7'>selected</cfif>>Hazır Bildirilmeyen Sevkler</option>
                        <option value="5" <cfif attributes.report_type_id eq '5'>selected</cfif>>Hazır Olmayan Sevkler</option>
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
                <div class="form-group" id="form_ul_control">
                	<input type="checkbox" name="is_control" id="is_control" <cfif isdefined('attributes.is_control')>checked</cfif>> Eşleme Göster
                </div>
                <div class="form-group small">
                 	<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Kayıt Sayısı Hatalı!'></cfsavecontent>
                 	<cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,1000" required="yes" message="#message#">
            	</div>
               	<div class="form-group">
                	<cf_wrk_search_button search_function='input_control()' button_type="4">
             	</div>
          	</cf_box_search>
          	<cf_box_search_detail>
            	<div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="1" sort="true">
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
                    
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="3" sort="true">
                    <div class="form-group" id="form_ul_branch">
                    	<select name="branch_id" id="branch_id" style="width:70px;height:20px">
                        	<option value=""><cf_get_lang dictionary_id='57453.Sube'></option>
                         	<cfoutput query="get_branch">
                           		<option value="#branch_id#" <cfif isdefined("attributes.branch_id") and branch_id eq attributes.branch_id>selected</cfif>>#branch_name#</option>
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
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="4" sort="true">
                	<div class="form-group" id="form_ul_shipmethod">
                    	<select name="SHIP_METHOD_ID" id="SHIP_METHOD_ID" style="width:100px;height:70px" multiple="multiple">
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
   	</cfsavecontent> 
    <cfsavecontent variable="message"><cf_get_lang dictionary_id="1351.E-Shipping Lite"></cfsavecontent>
    <cf_box title="#message#" uidrop="1" hide_table_column="1" woc_setting = "#{ checkbox_name : 'print_invoice_id', print_type : 10 }#" right_images="#right#">
    	<cf_grid_list sort="1">
        	<thead>
             	<tr>
                    <th style="width:30px; height:7;text-align:center" class="header_icn_txt"><cf_get_lang dictionary_id='58577.Sira'></th>
                    <!---<th style="width:20px;"></th>--->
                    <th style="width:65px;text-align:center"><cf_get_lang dictionary_id='382.Sevk Plan No'></th>
                    <th style="width:65px;text-align:center"><cf_get_lang dictionary_id='1089.Sevk Plan Tarihi'></th>
                    <th style="width:65px;text-align:center"><cf_get_lang dictionary_id='60609.Termin Tarihi'></th>
                    <th style="width:65px;text-align:center">Kayıt Tarihi</th>
                    <th style="width:100px;text-align:center">Sipariş No</th>
                    <th style="text-align:center"><cf_get_lang dictionary_id='57457.Müşteri'></th>
                                       
                    <th style="width:100px;text-align:center"><cf_get_lang dictionary_id='29500.Sevk Yöntemi'></th>
                    <th style="width:100px;text-align:center"><cf_get_lang dictionary_id='30114.Hacim'>(dm3)</th>
                    <th style="width:25px;text-align:center">SVK</th>
                    <cfif isdefined('attributes.is_control')><th style="width:25px;text-align:center">KNT</th></cfif>
                    <th style="width:25px;text-align:center">FTR</th>
                    <th style="width:20px" class="header_icn_none" nowrap="nowrap">
                        <!---<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_ezgi_print_files&print_type=79&action_id=#lnk_str#</cfoutput>','wide');"><img src="/images/print_plus.gif" alt="<cf_get_lang dictionary_id='57474.Yazdır'>" border="0" title="<cf_get_lang dictionary_id='57474.Yazdır'>">
                        </a>--->
                    </th>
                    <th style="width:20px;text-align:center"><input type="checkbox" alt="<cf_get_lang dictionary_id='57971.Şehir'>" onClick="grupla(-1);"></th>
                    <!-- sil -->
                </tr>
            </thead>
            <tbody>
				<cfset t_point =#attributes.t_point#>
                <cfset t_weight =#attributes.t_weight#>
                <cfif isdefined("attributes.form_varmi") and GET_SHIPPING.recordcount>
                	<cfoutput query="GET_SHIPPING" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                         	<cfquery name="GET_VOLUME" datasource="#DSN3#"> <!---Hacimler Toplanıyor--->
                                    SELECT
                                    	PU.WEIGHT,
                                        PU.VOLUME,
                                        ORR.ORDER_ID,
                                        ORR.STOCK_ID, 
                                        ORR.PRODUCT_ID, 
                                        ORR.QUANTITY,
                                        ORR.ORDER_ID FIS_ID,
                                        ORR.ORDER_ROW_ID FIS_ROW_ID                                       
                                    FROM         
                                        EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) INNER JOIN
                                        ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID LEFT OUTER JOIN
                                        #dsn1_alias#.PRODUCT_UNIT AS PU WITH (NOLOCK) ON ORR.PRODUCT_ID = PU.PRODUCT_ID
                                    WHERE     
                                        ESRR.SHIP_RESULT_ID = #SHIP_RESULT_ID#
                         	</cfquery>
                            <cfset row_point = 0>
                            <cfset row_weight = 0>
                            <cfquery name="get_order_id_list" dbtype="query">
                                SELECT
                                    FIS_ID
                                FROM
                                    GET_VOLUME
                                GROUP BY
                                    FIS_ID
                            </cfquery>
                            <cfset order_id_list = Valuelist(get_order_id_list.FIS_ID)>
                            <cfset order_row_id_list = Valuelist(GET_VOLUME.FIS_ROW_ID)>
                            <cfloop query="GET_VOLUME">
                                <cfif len(GET_VOLUME.VOLUME) and isnumeric(GET_VOLUME.VOLUME)>
                                    <cfset row_point = row_point + GET_VOLUME.VOLUME*GET_VOLUME.QUANTITY>
                                    <cfset t_point =t_point+GET_VOLUME.VOLUME*GET_VOLUME.QUANTITY>
                                </cfif>
                                <cfif len(GET_VOLUME.WEIGHT) and isnumeric(GET_VOLUME.WEIGHT)>
                                    <cfset row_weight = row_weight + GET_VOLUME.WEIGHT*GET_VOLUME.QUANTITY>
                                    <cfset t_weight =t_weight+GET_VOLUME.WEIGHT*GET_VOLUME.QUANTITY>
                                </cfif>
                            </cfloop>
                         	<tr>
                                    <td style="text-align:right">#currentrow#</td>
                                    <!---<td class="iconL">
                                        <a href="javascript:void(0)" id="ship_result_row#currentrow#"  onclick="gizle_goster(ship_result_row#currentrow#);connectAjax('#currentrow#');gizle_goster(siparis_goster#currentrow#);gizle_goster(siparis_gizle#currentrow#);"><i class="fa fa-caret-right"></i></a>
                                    </td>--->                                                                        
                                    <td style="text-align:center">
                                            <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping&iid=#SHIP_RESULT_ID#','wide');" class="tableyazi" title="<cf_get_lang dictionary_id='724.Sevk Fişine Git'>">
                                            #DELIVER_PAPER_NO#
                                            </a>
                                    </td>
                                    <td style="text-align:center">#DateFormat(OUT_DATE,dateformat_style)#</td>
                                	<td style="text-align:center">#DateFormat(DELIVERY_DATE,dateformat_style)#</td>
                                    <td style="text-align:center" nowrap>#DateFormat(RECORD_DATE,dateformat_style)# #TimeFormat(RECORD_DATE,'HH:MM')#</td>
                                    <td style="text-align:center">#REFERENCE_NO#</td>
                                    <td>
                                    	<cfif len(COMPANY_ID)>
                                        	#get_par_info(COMPANY_ID,1,1,0)#
                                        <cfelseif len(CONSUMER_ID)>
                                        	#get_cons_info(CONSUMER_ID,0,0)#
                                        </cfif>
                                    </td>
                                    <td>#SHIP_METHOD#</td>
                                    <td style="text-align:center">
                                        <cfif len(GET_VOLUME.VOLUME)>
                                            #TLFormat(GET_VOLUME.VOLUME/1000000,1)# 
                                        </cfif>    
                                    </td>                                    
                                    <!-- sil -->
                                    <td style="text-align:center"> <!---Sevk Indicator--->
                                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_sevk&iid=#SHIP_RESULT_ID#&is_type=#is_type#','page');" class="tableyazi" title="<cf_get_lang_main no='3533.Sevk Emri Ver'>">
                                            <cfif GET_SHIPPING.IS_SEND_WEBSERVICE eq 1>
                                                <img src="../../../images/green_glob.gif" border="0" title="Data Gönderildi" />
                                            <cfelseif GET_SHIPPING.sevk_durum eq 2>
                                                <img src="../../../images/red_glob.gif" border="0"/>
                                          	<cfelseif  GET_SHIPPING.sevk_durum eq 4>
                                                <img src="../../../images/blue_glob.gif" border="0" title="<cf_get_lang dictionary_id='731.Tüm Ürünler Hazır'>" />
                                          	<cfelseif  GET_SHIPPING.sevk_durum eq 5>
                                                <img src="../../../images/black_glob.gif" border="0" title="<cf_get_lang dictionary_id='732.Düzeltilmesi Gereken Sevk Talebi'>" />
                                          	<cfelseif  GET_SHIPPING.sevk_durum eq 6>
                                                <img src="../../../images/yellow_glob.gif" border="0" title="<cf_get_lang dictionary_id='730.Kısmi Sevk'>" />
                                            </cfif>
                                        </a>
                                    </td>
    								<!-- sil -->
                                    <cfif isdefined('attributes.is_control')>
                                        <!-- sil -->
                                        <td style="text-align:center"> <!---El Terminali 1 Kontrol Indicator--->
                                            <cfif isdefined('PAKET_SAYISI_#SHIP_RESULT_ID#') and isdefined('CONTROL_AMOUNT_#SHIP_RESULT_ID#')>
												<cfif Evaluate('PAKET_SAYISI_#SHIP_RESULT_ID#') - Evaluate('CONTROL_AMOUNT_#SHIP_RESULT_ID#') eq 0>
                                                	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_term_control&ship_id=#SHIP_RESULT_ID#&is_type=#is_type#','page');" class="tableyazi" title="<cf_get_lang dictionary_id='733.Detay Göster'>">
                                                    	<img src="/images/green_glob.gif" border="0" title="<cf_get_lang dictionary_id='330.Kontrol Edildi'>.">
                                               	 	</a>
                                             	<cfelse>
                                                	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_term_control&ship_id=#SHIP_RESULT_ID#&is_type=#is_type#','page');" class="tableyazi" title="<cf_get_lang dictionary_id='733.Detay Göster'>">
                                                    	<img src="/images/red_glob.gif" border="0" title="<cf_get_lang dictionary_id='331.Kontrol Edilmedi'>.">
                                                	</a>
                                             	</cfif>
                                         	</cfif>
                                        </td>
                                    </cfif>
                                    <!-- sil -->
                                    <td style="text-align:center"> <!---Fatura Indicator--->
                                        <cfif DURUM eq 1>
											<img src="../../../images/red_glob.gif" border="0" title="<cf_get_lang dictionary_id='737.Kontrol Tamamlanmamış Sevkiyat'>" />
                                     	<cfelseif DURUM eq 2>
                                         	<img src="../../../images/green_glob.gif" border="0" title="<cf_get_lang dictionary_id='1103.Tamamı Sevk Edildi'>" />
                                     	<cfelseif DURUM eq 3>
                                          	<img src="../../../images/yellow_glob.gif" border="0"title="<cf_get_lang dictionary_id='3542.Kısmi Kapandı'>" />
                                    	</cfif>
                                    </td> 
                                    <!-- sil -->
                                    <td style="text-align:center;<cfif DURUM neq 1>background-color:red</cfif>"><a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_ezgi_print_files&print_type=32&action_id=#is_type#-#SHIP_RESULT_ID#','page');"><img src="/images/print2.gif" alt="<cf_get_lang_main no='62.Yazdır'>" border="0" title="<cf_get_lang_main no='62.Yazdır'>"></a>
                                    </td>
                                    <td style="text-align:right">
                                        <input type="checkbox" name="select_production" value="1-#SHIP_RESULT_ID#-0">
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
                                 	<td style="text-align:right;" colspan="20">
                                    	<cfif attributes.report_type_id neq '2'>
                                   			<input type="text" name="send_date" id="send_date" value="#dateformat(now(),dateformat_style)#" validate="eurodate" maxlength="10" style="width:65px;" >
                                      		<cf_wrk_date_image date_field="send_date">
                                      		&nbsp;&nbsp;&nbsp;&nbsp;
                                        
                                      		<button  value="" name="gonder" id="gonder" onClick="grupla(-4);" style="width:100px; height:25px;">&nbsp;Tarih Düzenle</button>
                                        </cfif>
                                        <cfif attributes.report_type_id eq '7'>
                                     		<button  value="" name="data_send" id="data_send" onClick="grupla(-2);" style="width:100px; height:25px;">&nbsp;Data Gönder</button>
                                        </cfif>
                                            
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
            <cfif len(t_weight)>
                <cfset url_str = url_str & "&t_weight=#t_weight#">
            </cfif>
            <cfset url_str = url_str & "&order_employee_id=#attributes.order_employee_id#&order_employee=#attributes.order_employee#">
            <cfset url_str = url_str & "&sort_type=#attributes.sort_type#">
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
				
				if(type == -4)
				{
					if (!date_check(order_form.today_value,document.all.send_date,"Sevk tarihi Bugünden Önceye Yapılamaz.!"))
						return false;
					var soru = confirm("<cf_get_lang dictionary_id='750.Sevkiyatları ilgili Tarihe Gönderiyorum.'> <cf_get_lang dictionary_id='58588.Emin misiniz ?'>");
					if(soru==true)
					{
						send_date = document.getElementById('send_date').value;
						if(send_date.length>0)
						window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_upd_ezgi_shipping_date&type=1&shipping_id_list='+shipping_id_list+'&send_date='+send_date);
						else
						{
							alert("<cf_get_lang dictionary_id='751.Gönderilecek Tarih Boş Olamaz !'>");
							return false;
						}
					}
				}
				else if(type == -2)
				{
					var soru = confirm("Sevk Aşamasına Gelen Siparişleri Entegratöre Gönderiyorum Emin misin?");
					if(soru==true)
					{
						window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_upd_ezgi_shipping_date&type=2&shipping_id_list='+shipping_id_list);
						return true;
					}
					else
						return false;
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

</script>