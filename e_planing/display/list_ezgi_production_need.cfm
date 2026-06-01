<!---
    File: list_ezgi_production_need.cfm
    Folder: Add_Ons\ezgi\e_planing\display
    Author: Ezgi Yazılım
    Date: 01/01/2020
    Description:
--->
<cf_xml_page_edit>
    <cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
    <cfparam name="attributes.page" default="1">
    <cfparam name="attributes.department_id" default="">
    <cfparam name="attributes.departments" default="">
    <cfparam name="attributes.branch_id" default="">
    <cfparam name="attributes.department_txt" default="">
    <cfparam name="attributes.stock_id" default="">
    <cfparam name="attributes.product_id" default="">
    <cfparam name="attributes.product_name" default="">
    <cfparam name="attributes.product_code" default="">
    <cfparam name="attributes.product_cat_id" default="">
    <cfparam name="attributes.product_cat" default="">
    <cfparam name="attributes.report_type" default="4">
    <cfparam name="attributes.unit_type" default="">
    <cfparam name="attributes.keyword" default="">
    <cfparam name="attributes.uretim_ay" default="0">
    <cfparam name="attributes.yontem" default="1">
    <cfparam name="attributes.is_excel" default="">
    <cfparam name="attributes.product_brand_name" default="">
    <cfif x_select_calc_yontem eq 1>
        <cfparam name="attributes.stock_calc_yontem" default="1">
    <cfelse>
        <cfparam name="attributes.stock_calc_yontem" default="0">
    </cfif>
    <cfset satirlar_stock_is_list = ''>
    <cfset stock_id_list = ''>
    <cfset t_real_stock = 0>
    <cfset s_t_real_stock = 0>
    <cfset son_row = 0>
    <cfif attributes.yontem eq 1 or attributes.yontem eq 2>
		<cfset this_year_max_month = Month(now())>
        <cfset this_year_min_month = 1>
        <cfset last_year_max_month = 12>
        <cfset last_year_min_month = this_year_max_month>
        <cfset this_year = Year(now())>
        <cfset last_year = this_year -1>
    <cfelseif attributes.yontem eq 3> <!---Son üç Ay--->
    	<cfset this_year_max_month = Month(now())>
        <cfset this_year = Year(now())>
        
        <cfset baslangic_ay = this_year_max_month>
        <cfloop from="1" to="3" index="i">
        	<cfif baslangic_ay - i lte 0>
            	<cfset this_year_min_month = 1>

            	<cfset last_year = this_year -1>
                <cfset last_year_max_month = 12>
                <cfset last_year_min_month = 12-i+baslangic_ay>
            <cfelse>
            	<cfset this_year_min_month = this_year_max_month-i>
                <cfset last_year = this_year>
            </cfif>
        </cfloop>
  	<cfelseif attributes.yontem eq 4> <!---Son Altı Ay--->
    	<cfset this_year_max_month = Month(now())>
        <cfset this_year = Year(now())>
        
        <cfset baslangic_ay = this_year_max_month>
        <cfloop from="1" to="6" index="i">
        	<cfif baslangic_ay - i lte 0>
            	<cfset this_year_min_month = 1>

            	<cfset last_year = this_year -1>
                <cfset last_year_max_month = 12>
                <cfset last_year_min_month = 12-i+baslangic_ay>
            <cfelse>
            	<cfset this_year_min_month = this_year_max_month-i>
                <cfset last_year = this_year>
            </cfif>
        </cfloop>
  	<cfelseif attributes.yontem eq 5> <!---Son Dokuz Ay--->
    	<cfset this_year_max_month = Month(now())>
        <cfset this_year = Year(now())>
        
        <cfset baslangic_ay = this_year_max_month>
        <cfloop from="1" to="9" index="i">
        	<cfif baslangic_ay - i lte 0>
            	<cfset this_year_min_month = 1>

            	<cfset last_year = this_year -1>
                <cfset last_year_max_month = 12>
                <cfset last_year_min_month = 12-i+baslangic_ay>
            <cfelse>
            	<cfset this_year_min_month = this_year_max_month-i>
                <cfset last_year = this_year>
            </cfif>
        </cfloop>
    </cfif>
    <cfquery name="GET_DEPARTMENT" datasource="#DSN#">
        SELECT
            DEPARTMENT_ID,
            DEPARTMENT_HEAD
        FROM
            BRANCH B,
            DEPARTMENT D 
        WHERE
            B.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
            B.BRANCH_ID = D.BRANCH_ID AND
            D.IS_STORE <> 2
            AND D.DEPARTMENT_STATUS = 1 
        ORDER BY
            DEPARTMENT_HEAD
    </cfquery>
    <cfset branch_dep_list=valuelist(get_department.department_id,',')>
    <cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
        SELECT * FROM STOCKS_LOCATION
    </cfquery>
    
    <cfset branch_dep_list=valuelist(get_department.department_id,',')>
    
    <cfquery name="get_last_period" datasource="#dsn#">
        SELECT PERIOD_ID FROM SETUP_PERIOD WHERE OUR_COMPANY_ID = #session.ep.company_id# AND PERIOD_YEAR = #last_year# AND PERIOD_YEAR <> #this_year#
    </cfquery>
    <cfquery name="get_branch" datasource="#dsn#">
        SELECT BRANCH_ID, BRANCH_NAME FROM BRANCH WHERE BRANCH_STATUS = 1 AND COMPANY_ID = #session.ep.company_id#
    </cfquery>
    <cfquery name="get_unit" datasource="#dsn#">
        SELECT UNIT_ID, UNIT FROM SETUP_UNIT
    </cfquery>
    <cfoutput query="get_unit">
        <cfset 'UNIT_#UNIT_ID#' = UNIT>
    </cfoutput>
    <cfset satirlar.recordcount=0>
    <cfif isdefined("attributes.is_submitted")>
        <cfif Len(attributes.product_code) and Len(attributes.product_cat)>
            <cfquery name="GET_CATEGORIES" datasource="#DSN1#">
                SELECT PRODUCT_ID FROM PRODUCT WHERE PRODUCT_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.product_code#.%">
            </cfquery>
        </cfif>
        <cfset attributes.list_with_store = 1>
    	<cfquery name="get_departments" datasource="#DSN#">
                SELECT        
                    CAST(DEPARTMENT_ID AS NVARCHAR)+'-'+CAST(LOCATION_ID AS NVARCHAR) AS DEPARTMENT_ID 
                FROM            
               		STOCKS_LOCATION
                WHERE        
                    DEPARTMENT_ID IN
                                     (
                                        SELECT        
                                            DEPARTMENT_ID
                                           FROM            
                                            DEPARTMENT
                                           WHERE   
                                           	 BRANCH_ID IN (SELECT BRANCH_ID FROM BRANCH WHERE BRANCH_STATUS = 1 AND COMPANY_ID = #session.ep.company_id#) AND
                                            <cfif len(attributes.branch_id)>      
                                                BRANCH_ID IN (#attributes.branch_id#) AND 
                                            </cfif>
                                            DEPARTMENT_STATUS = 1 
                                       )
                    AND ISNULL(IS_SCRAP,0) =0
                    <cfif len(attributes.departments)>   
                    	 AND 
                         	(
                                <cfloop from="1" to="#listlen(attributes.departments)#" index="k">
                                    DEPARTMENT_ID = #ListGetAt(ListGetAt(attributes.departments,k),1,'-')# AND 
                                    LOCATION_ID = #ListGetAt(ListGetAt(attributes.departments,k),2,'-')#
                                    <cfif k neq listlen(attributes.departments)>OR</cfif>
                                </cfloop>
                            )
                   	</cfif>
                ORDER BY 
                    DEPARTMENT_ID, 
                    LOCATION_ID
      	</cfquery>
     	<cfset attributes.department_id = ValueList(get_departments.DEPARTMENT_ID)>
        <cfinclude template="../query/get_ezgi_stock_last_location_karma_koli.cfm">
        <cfif len(attributes.unit_type)>
              <cfquery name="GET_EZGI_STOCK_LAST_LOCATION_KARMA_KOLI" dbtype="query">
                  SELECT * FROM GET_EZGI_STOCK_LAST_LOCATION_KARMA_KOLI WHERE UNIT_ID = #attributes.unit_type#
             </cfquery>
          </cfif>
        <cfif GET_EZGI_STOCK_LAST_LOCATION_KARMA_KOLI.recordcount>
            <cfset stock_id_list = Valuelist(GET_EZGI_STOCK_LAST_LOCATION_KARMA_KOLI.STOCK_ID)>
            <cfset product_id_list = Valuelist(GET_EZGI_STOCK_LAST_LOCATION_KARMA_KOLI.PRODUCT_ID)>
            <!---Üretim Miktarı Hesaplanıyor--->
            <cfquery name="get_production_amount" datasource="#dsn3#">
                SELECT        
                    SUM(PO.QUANTITY - ISNULL(TBL.AMOUNT, 0)) AS URETIM_PLANI, 
                    S.STOCK_ID
                FROM            
               		PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
                    #dsn1_alias#.KARMA_PRODUCTS AS KP WITH (NOLOCK)  ON PO.STOCK_ID = KP.STOCK_ID INNER JOIN
                    STOCKS AS S ON KP.KARMA_PRODUCT_ID = S.PRODUCT_ID LEFT OUTER JOIN
                     (
                        SELECT        
                            POR.P_ORDER_ID, 
                            SUM(PORR.AMOUNT) AS AMOUNT
                          FROM        
                            PRODUCTION_ORDER_RESULTS AS POR WITH (NOLOCK)  INNER JOIN
                            PRODUCTION_ORDER_RESULTS_ROW AS PORR WITH (NOLOCK)  ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
                        WHERE        
                            PORR.TYPE = 1 AND 
                            POR.IS_STOCK_FIS = 1
                        GROUP BY 
                            POR.P_ORDER_ID
                    ) AS TBL ON PO.P_ORDER_ID = TBL.P_ORDER_ID
                WHERE        
                    PO.IS_DEMONTAJ = 0 AND 
                    PO.STATUS = 1 AND 
                    PO.IS_STOCK_RESERVED = 1 AND
                    S.STOCK_ID IN (#stock_id_list#)
                GROUP BY 
                    S.STOCK_ID
            </cfquery>
            <cfoutput query="get_production_amount">
                <cfset 'URETIM_PLANI_#STOCK_ID#' = URETIM_PLANI>
            </cfoutput>
            <!---Üretim Miktarı Hesaplanıyor--->
            <cfquery name="get_karma" datasource="#dsn1#">
                SELECT PRODUCT_ID, ISNULL(IS_KARMA, 0) AS IS_KARMA FROM PRODUCT WITH (NOLOCK)  WHERE PRODUCT_ID IN (#product_id_list#)
            </cfquery>

            <cfoutput query="get_karma">
                <cfset 'IS_KARMA_#PRODUCT_ID#' = IS_KARMA> 
            </cfoutput>
            <cfif attributes.report_type neq 3>
                <!---Dönem İhtiyacı Hesaplanıyor--->
                <cfif x_select_control eq 1>
                    <!---SATIŞ FATURALARI--->
                    <cfquery name="get_all_sales" datasource="#dsn2#">
                        SELECT
                            YIL,
                            AY,
                            STOCK_ID,
                            SUM(SATIS) AS SATIS
                        FROM
                            (
                            SELECT     
                                CASE WHEN I.PURCHASE_SALES = 0 THEN IR.AMOUNT * - 1 ELSE IR.AMOUNT END AS SATIS, 
                                MONTH(I.INVOICE_DATE) AS AY, 
                                YEAR(I.INVOICE_DATE) AS YIL, 
                                IR.STOCK_ID
                            FROM         
                                INVOICE AS I WITH (NOLOCK)  INNER JOIN
                                INVOICE_ROW AS IR WITH (NOLOCK)  ON I.INVOICE_ID = IR.INVOICE_ID
                            WHERE
                                I.IS_IPTAL = 0 AND 
                                ISNULL(IR.IS_PROMOTION, 0) <> 1 AND 
                                <cfif isdefined('attributes.ihr_sat') and len(attributes.ihr_sat)>
                                    I.INVOICE_CAT IN (52,53,54,55,531) AND
                                <cfelse>
                                    I.INVOICE_CAT IN (52,53,54,55) AND
                                </cfif>
                                IR.STOCK_ID IN (#stock_id_list#) AND
                                MONTH(I.INVOICE_DATE) >= #this_year_min_month# AND 
                                MONTH(I.INVOICE_DATE) <= #this_year_max_month# AND
                                MONTH(I.INVOICE_DATE) <> #month(now())#
                            <cfif get_last_period.recordcount>
                                UNION ALL
                                SELECT     
                                    CASE WHEN I.PURCHASE_SALES = 0 THEN IR.AMOUNT * - 1 ELSE IR.AMOUNT END AS SATIS, 
                                    MONTH(I.INVOICE_DATE) AS AY, 
                                    YEAR(I.INVOICE_DATE) AS YIL, 
                                    IR.STOCK_ID
                                FROM         
                                    #dsn#_#last_year#_#session.ep.company_id#.INVOICE AS I WITH (NOLOCK)  INNER JOIN
                                    #dsn#_#last_year#_#session.ep.company_id#.INVOICE_ROW AS IR WITH (NOLOCK)  ON I.INVOICE_ID = IR.INVOICE_ID
                                WHERE
                                    I.IS_IPTAL = 0 AND 
                                    ISNULL(IR.IS_PROMOTION, 0) <> 1 AND 
                                    <cfif isdefined('attributes.ihr_sat') and len(attributes.ihr_sat)>
                                        I.INVOICE_CAT IN (52,53,54,55,531) AND
                                    <cfelse>
                                        I.INVOICE_CAT IN (52,53,54,55) AND
                                    </cfif>
                                    IR.STOCK_ID IN (#stock_id_list#) AND
                                    MONTH(I.INVOICE_DATE) >= #last_year_min_month#  AND 
                                    MONTH(I.INVOICE_DATE) <= #LAST_year_max_month# 
                            </cfif>
                            ) AS TBL
                        GROUP BY
                            YIL,
                            AY,
                            STOCK_ID
                        ORDER BY
                            STOCK_ID,
                            YIL,
                            AY
                    </cfquery>
                    <cfloop list="#stock_id_list#" index="i">
                        <cfquery name="get_info" dbtype="query">
                            SELECT * FROM get_all_sales WHERE STOCK_ID = #i# AND SATIS >0
                        </cfquery>
                        <cfquery name="get_info_total" dbtype="query">
                            SELECT sum(SATIS) AS SATIS FROM get_info
                        </cfquery>
                        <cfif get_info.recordcount>
                            <cfif attributes.yontem eq 1> 
                                <cfset 'ortalama_#i#' = get_info_total.SATIS/get_info.recordcount>
                            <cfelseif attributes.yontem eq 2>
                                <cfset 'ortalama_#i#' = get_info_total.SATIS/12>
                          	<cfelseif attributes.yontem eq 3>
                            	<cfset 'ortalama_#i#' = get_info_total.SATIS/3>
                           	<cfelseif attributes.yontem eq 4>
                            	<cfset 'ortalama_#i#' = get_info_total.SATIS/6>
                          	<cfelseif attributes.yontem eq 5>
                            	<cfset 'ortalama_#i#' = get_info_total.SATIS/9>
                            </cfif>
                            <cfif isdefined('attributes.calc_method') and len(attributes.calc_method)>
                                <cfset 'period_need_#i#' = 0>
                                <cfloop query="get_info">
                                    <cfset 'period_need_#i#' = Evaluate('period_need_#i#') + (get_info.satis-Evaluate('ortalama_#i#'))^2>
                                </cfloop>
                                <cfif Evaluate('period_need_#i#') gt 0 and get_info.recordcount-1 gt 0>
                                    <cfset 'period_need_#i#' = SQR(Evaluate('period_need_#i#')/(get_info.recordcount-1))>
                                    <cfset 'period_need_#i#' = Evaluate('period_need_#i#') + Evaluate('ortalama_#i#')>
                                <cfelse>
                                    <cfset 'period_need_#i#' = Evaluate('ortalama_#i#')>
                                </cfif>
                            <cfelse>
                                <cfloop query="get_info">
                                    <cfset 'period_need_#i#' = Evaluate('ortalama_#i#')>
                                </cfloop>
                            </cfif>
                        </cfif>
                    </cfloop>
                    <!---SATIŞ FATURALARI--->
                <cfelseif x_select_control eq 2>
                    <!---KOTALAR--->
                    <cfset yil_list = ''>
                    <cfloop from="1" to="#attributes.uretim_ay#" index="ay">
                        <cfset buyil = Year(Dateadd('m',ay,now()))>
                        <cfset buay = Month(Dateadd('m',ay,now()))>
                        <cfif isdefined('ay_list_#buyil#')>
                            <cfset 'ay_list_#buyil#' = ListAppend(Evaluate('ay_list_#buyil#'),buay)>
                           <cfelse>
                            <cfset 'ay_list_#buyil#' = buay>
                        </cfif>
                        <cfif not ListFind(yil_list,buyil)>
                            <cfset yil_list = ListAppend(yil_list,buyil)>
                        </cfif>
                    </cfloop>
                       <cfquery name="get_all_sales" datasource="#dsn3#">
                        SELECT
                            YIL,
                            AY,
                            STOCK_ID,
                            SUM(SATIS) AS SATIS
                           FROM
                            (
                            <cfloop list="#yil_list#" index="yil">
                                SELECT 
                                    ISNULL(SQR.QUANTITY,0) AS SATIS,
                                    SQR.STOCK_ID,
                                    MONTH(SQ.PLAN_DATE) AS AY,
                                    YEAR(SQ.PLAN_DATE) AS YIL
                                FROM
                                    SALES_QUOTAS SQ WITH (NOLOCK) ,
                                    SALES_QUOTAS_ROW SQR WITH (NOLOCK) 
                                WHERE
                                    SQ.SALES_QUOTA_ID = SQR.SALES_QUOTA_ID
                                    AND MONTH(SQ.PLAN_DATE) IN (#Evaluate('ay_list_#yil#')#)
                                    AND YEAR(SQ.PLAN_DATE) = #yil#
                                    AND IS_SALES_PURCHASE = 1
                                    AND SQR.STOCK_ID IN (#stock_id_list#)
                                <cfif ListFind(yil_list,((yil*1)+1))>
                                    UNION ALL
                                </cfif>
                             </cfloop>
                            ) AS TBL
                          GROUP BY
                            YIL,
                            AY,
                            STOCK_ID
                        ORDER BY
                            STOCK_ID,
                            YIL,
                            AY
                      </cfquery>
                    <cfloop list="#stock_id_list#" index="i">
                        <cfquery name="get_info" dbtype="query">
                            SELECT * FROM get_all_sales WHERE STOCK_ID = #i# AND SATIS >0
                        </cfquery>
                        <cfquery name="get_info_total" dbtype="query">
                            SELECT sum(SATIS) AS SATIS FROM get_info
                        </cfquery>
                        <cfif get_info.recordcount>
                            <cfif attributes.yontem eq 1> 
                                <cfset 'ortalama_#i#' = get_info_total.SATIS/get_info.recordcount>
                            <cfelseif attributes.yontem eq 2>
                                <cfset 'ortalama_#i#' = get_info_total.SATIS/12>
                          	<cfelseif attributes.yontem eq 3>
                            	<cfset 'ortalama_#i#' = get_info_total.SATIS/3>



                          	<cfelseif attributes.yontem eq 4>
                            	<cfset 'ortalama_#i#' = get_info_total.SATIS/6>
                          	<cfelseif attributes.yontem eq 5>
                            	<cfset 'ortalama_#i#' = get_info_total.SATIS/9>
                            </cfif>
                            <cfif isdefined('attributes.calc_method') and len(attributes.calc_method)>
                                <cfset 'period_need_#i#' = 0>
                                <cfloop query="get_info">
                                    <cfset 'period_need_#i#' = Evaluate('period_need_#i#') + (get_info.satis-Evaluate('ortalama_#i#'))^2>
                                </cfloop>
                                <cfif Evaluate('period_need_#i#') gt 0>
                                    <cfset 'period_need_#i#' = SQR(Evaluate('period_need_#i#')/(get_info.recordcount-1))>
                                    <cfset 'period_need_#i#' = Evaluate('period_need_#i#') + Evaluate('ortalama_#i#')>
                                <cfelse>
                                    <cfset 'period_need_#i#' = Evaluate('ortalama_#i#')>
                                </cfif>
                            <cfelse>
                                <cfloop query="get_info">
                                    <cfset 'period_need_#i#' = Evaluate('ortalama_#i#')>
                                </cfloop>
                            </cfif>
                        </cfif>
                    </cfloop>
                    <!---KOTALAR--->
                <cfelseif x_select_control eq 3>
                    <!---STOK STRATEJİLERİ MINIMUM STOK--->
                    <cfset buyil = Year(now())>
                       <cfset buay = Month(now())>
                    <cfquery name="get_all_sales" datasource="#dsn3#">
                        SELECT 
                            #buyil# AS YIL,
                            #buay# AS AY,
                            STOCK_ID, 
                            ISNULL(MINIMUM_STOCK,0) AS SATIS
                        FROM     
                            STOCK_STRATEGY WITH (NOLOCK) 
                        WHERE  
                            STOCK_ID IN (#stock_id_list#)
                        ORDER BY 
                            STOCK_ID
                       </cfquery>
                    <cfloop list="#stock_id_list#" index="i">
                        <cfquery name="get_info" dbtype="query">
                            SELECT * FROM get_all_sales WHERE STOCK_ID = #i# AND SATIS >0
                        </cfquery>
                        <cfquery name="get_info_total" dbtype="query">
                            SELECT sum(SATIS) AS SATIS FROM get_info
                        </cfquery>
                        <cfif get_info.recordcount>
                            <cfif attributes.yontem eq 1> 
                                <cfset 'ortalama_#i#' = get_info_total.SATIS/get_info.recordcount>
                            <cfelseif attributes.yontem eq 2>
                                <cfset 'ortalama_#i#' = get_info_total.SATIS/12>
                          	<cfelseif attributes.yontem eq 3>
                            	<cfset 'ortalama_#i#' = get_info_total.SATIS/3>
                           	<cfelseif attributes.yontem eq 4>
                            	<cfset 'ortalama_#i#' = get_info_total.SATIS/6>
                          	<cfelseif attributes.yontem eq 5>
                            	<cfset 'ortalama_#i#' = get_info_total.SATIS/9>
                            </cfif>
                            <cfif isdefined('attributes.calc_method') and len(attributes.calc_method)>
                                <cfset 'period_need_#i#' = 0>
                                <cfloop query="get_info">
                                    <cfset 'period_need_#i#' = Evaluate('period_need_#i#') + (get_info.satis-Evaluate('ortalama_#i#'))^2>
                                </cfloop>
                                <cfif Evaluate('period_need_#i#') gt 0>
                                    <cfset 'period_need_#i#' = SQR(Evaluate('period_need_#i#')/(get_info.recordcount-1))>
                                    <cfset 'period_need_#i#' = Evaluate('period_need_#i#') + Evaluate('ortalama_#i#')>
                                <cfelse>
                                    <cfset 'period_need_#i#' = Evaluate('ortalama_#i#')>
                                </cfif>
                            <cfelse>
                                <cfloop query="get_info">
                                    <cfset 'period_need_#i#' = Evaluate('ortalama_#i#')>
                                </cfloop>
                            </cfif>
                        </cfif>
                    </cfloop>
                    <!---STOK STRATEJİLERİ MINIMUM STOK--->
                </cfif>
                <!---Dönem İhtiyacı Hesaplanıyor--->
               </cfif>
        </cfif>
    <cfelse>
        <cfset GET_EZGI_STOCK_LAST_LOCATION_KARMA_KOLI.recordcount=0>
    </cfif>
    <cfif GET_EZGI_STOCK_LAST_LOCATION_KARMA_KOLI.recordcount>
     	<cfset satirlar = queryNew("stock_id, product_id,product_code,product_name,manufact_code,unit,RESERVED_PROD_STOCK,real_stock,RESERVE_PURCHASE_ORDER_STOCK, RESERVE_SALE_ORDER_STOCK,PURCHASE_PROD_STOCK,IS_KARMA,URETIM_PLANI,TALEP,SALEABLE_STOCK,RESERVED_STOCK,period_need,SHIP_INTERNAL_STOCK","integer,integer,VarChar,VarChar,VarChar,VarChar,Decimal,Decimal,Decimal,Decimal,Decimal,Bit,Decimal,Decimal,Decimal,Decimal,Decimal,Decimal") />
    	<cfoutput query="GET_EZGI_STOCK_LAST_LOCATION_KARMA_KOLI">
         	<cfset Temp = QueryAddRow(satirlar)>
        	<cfset Temp = QuerySetCell(satirlar, "stock_id", stock_id)> 
            <cfset Temp = QuerySetCell(satirlar, "product_id", product_id)>
            <cfset Temp = QuerySetCell(satirlar, "product_code", product_code)>
       		<cfset Temp = QuerySetCell(satirlar, "product_name", product_name)>
        	<cfset Temp = QuerySetCell(satirlar, "manufact_code", manufact_code)>
        	<cfset Temp = QuerySetCell(satirlar, "unit", Evaluate('UNIT_#UNIT_ID#'))> 
            <cfset Temp = QuerySetCell(satirlar, "RESERVED_PROD_STOCK", RESERVED_PROD_STOCK)>
         	<cfset Temp = QuerySetCell(satirlar, "real_stock", real_stock)> 
            <cfset Temp = QuerySetCell(satirlar, "RESERVE_PURCHASE_ORDER_STOCK", RESERVE_PURCHASE_ORDER_STOCK)> 
          	<cfset Temp = QuerySetCell(satirlar, "RESERVE_SALE_ORDER_STOCK", RESERVE_SALE_ORDER_STOCK)>
       		<cfset Temp = QuerySetCell(satirlar, "PURCHASE_PROD_STOCK", PURCHASE_PROD_STOCK)>
         	<cfset Temp = QuerySetCell(satirlar, "RESERVED_STOCK", RESERVED_STOCK)>
            <cfset Temp = QuerySetCell(satirlar, "SHIP_INTERNAL_STOCK", SHIP_INTERNAL_STOCK)>
        	<cfset Temp = QuerySetCell(satirlar, "IS_KARMA", Evaluate('IS_KARMA_#PRODUCT_ID#'))>
        	<cfif isdefined('URETIM_PLANI_#STOCK_ID#')>
            	<cfset Temp = QuerySetCell(satirlar, "URETIM_PLANI", Evaluate('URETIM_PLANI_#STOCK_ID#'))> 
          	<cfelse>
            	<cfset Temp = QuerySetCell(satirlar, "URETIM_PLANI", 0)> 
        	</cfif>
            <cfif TALEP lt 0>
                <cfset Temp = QuerySetCell(satirlar, "TALEP", 0)> 
            <cfelse>
                   <cfset Temp = QuerySetCell(satirlar, "TALEP", TALEP)> 
            </cfif>
            <cfif isdefined('attributes.is_production') and len(attributes.is_production)>
                  <cfset Temp = QuerySetCell(satirlar, "SALEABLE_STOCK", SALEABLE_STOCK-PURCHASE_PROD_STOCK)> 
            <cfelse>
                <cfset Temp = QuerySetCell(satirlar, "SALEABLE_STOCK", SALEABLE_STOCK)> 
            </cfif>
          	<cfif isdefined('period_need_#STOCK_ID#')>
                <cfif not len(attributes.uretim_ay) or not isnumeric(attributes.uretim_ay)>
                    <cfset attributes.uretim_ay =0>
                </cfif>
                  <cfset Temp = QuerySetCell(satirlar, "period_need", round(Evaluate('period_need_#STOCK_ID#'))*attributes.uretim_ay)> 
         	<cfelse>
                 <cfset Temp = QuerySetCell(satirlar, "period_need", 0)>
             </cfif>
         </cfoutput>
         <cfif satirlar.recordcount>
             <cfquery name="satirlar" dbtype="query">
                  SELECT
                      *
                  FROM
                    satirlar
                   WHERE
                     1=1
                     <cfif attributes.report_type eq 1>
                        <cfif isdefined('attributes.is_production') and len(attributes.is_production)>
                            AND REAL_STOCK+RESERVED_STOCK+TALEP-period_need+PURCHASE_PROD_STOCK < 0
                         <cfelse>
                            AND REAL_STOCK+RESERVED_STOCK+TALEP-period_need < 0
                        </cfif>
                       </cfif>
                     <cfif attributes.report_type eq 2>
                        <cfif isdefined('attributes.is_production') and len(attributes.is_production)>
                            AND REAL_STOCK+RESERVED_STOCK+TALEP-period_need+PURCHASE_PROD_STOCK > 0
                         <cfelse>
                            AND REAL_STOCK+RESERVED_STOCK+TALEP-period_need > 0
                        </cfif>
                     </cfif> 
            	ORDER BY
               		MANUFACT_CODE,
                 	PRODUCT_NAME
         	</cfquery>
            <cfif satirlar.recordcount>
                <cfquery name="satirlar_karma" dbtype="query">
                    SELECT STOCK_ID,PRODUCT_ID FROM satirlar WHERE IS_KARMA = 1
                </cfquery>
                <cfset karma_stock_id_list = ValueList(satirlar_karma.STOCK_ID)>
                <cfset karma_product_id_list = ValueList(satirlar_karma.PRODUCT_ID)>
                <cfif listlen(karma_product_id_list)>
                    <cfquery name="get_karma_paket" datasource="#DSN1#">
                    	WITH RealStock AS 
                        (
                            SELECT 
                                PRODUCT_ID, 
                                SUM(STOCK_IN - STOCK_OUT) AS REAL_STOCK
                            FROM 
                                #dsn2_alias#.STOCKS_ROW WITH (NOLOCK) 
                            GROUP BY 
                                PRODUCT_ID
                        ),
                        UretimStock AS (
                            SELECT 
                                STOCK_ID, 
                                SUM(PURCHASE_PROD_STOCK) AS PURCHASE_PROD_STOCK
                            FROM 
                                #dsn2_alias#.GET_STOCK_LAST_PROFILE WITH (NOLOCK) 
                            GROUP BY 
                                STOCK_ID
                        ),
                        SiparisStock AS (
                            SELECT 
                                STOCK_ID,
                                SUM(RESERVE_SALE_ORDER_STOCK) AS TOTAL_SIPARIS
                            FROM (
                                SELECT 
                                    STOCK_ID, 
                                    SUM(RESERVE_SALE_ORDER_STOCK) AS RESERVE_SALE_ORDER_STOCK
                                FROM 
                                    #dsn3_alias#.EZGI_SALE_ORDER_RESERVED_LOCATION_DEMONTE WITH (NOLOCK) 
                                GROUP BY 
                                    STOCK_ID
                                UNION ALL
                                SELECT 
                                    S.STOCK_ID, 
                                    SUM(ORR.RESERVE_STOCK_OUT - ORR.STOCK_OUT) AS RESERVE_SALE_ORDER_STOCK
                                FROM     
                                    #dsn3_alias#.GET_ORDER_ROW_RESERVED AS ORR WITH (NOLOCK) 
                                    INNER JOIN #dsn3_alias#.ORDERS AS ORDS WITH (NOLOCK)  ON ORR.ORDER_ID = ORDS.ORDER_ID 
                                    INNER JOIN #dsn3_alias#.STOCKS AS S WITH (NOLOCK)  ON ORR.STOCK_ID = S.STOCK_ID
                                WHERE  
                                    ORR.RESERVE_STOCK_OUT - ORR.STOCK_OUT > 0 
                                    AND S.IS_KARMA = 0 
                                    AND ORDS.RESERVED = 1 
                                    AND ORDS.ORDER_STATUS = 1
                                GROUP BY 
                                    S.STOCK_ID
                            ) AS SubQuery
                            GROUP BY 
                                STOCK_ID
                        )
                        SELECT  
                            K.KARMA_PRODUCT_ID,      
                            P.PRODUCT_NAME,
                            P.BARCOD,
                            K.PRODUCT_AMOUNT, 
                            K.PRODUCT_ID,
                            K.STOCK_ID,
                            DP.PACKAGE_IS_MASTER,
                            P.PRODUCT_CODE,
                            P.MANUFACT_CODE,
                            PU.MAIN_UNIT,
                            ISNULL(RS.REAL_STOCK, 0) AS REAL_STOCK,
                            ISNULL(US.PURCHASE_PROD_STOCK, 0) AS URETIM,
                            ISNULL(SS.TOTAL_SIPARIS, 0) AS SIPARIS
                        FROM            
                            KARMA_PRODUCTS K WITH (NOLOCK)  LEFT JOIN 
                            PRODUCT P WITH (NOLOCK)  ON K.PRODUCT_ID = P.PRODUCT_ID LEFT JOIN 
                            PRODUCT_UNIT PU WITH (NOLOCK)  ON PU.PRODUCT_ID = K.PRODUCT_ID AND PU.PRODUCT_UNIT_STATUS = 1 AND PU.IS_MAIN = 1 LEFT JOIN 
                            RealStock RS ON RS.PRODUCT_ID = K.PRODUCT_ID LEFT JOIN 
                            UretimStock US ON US.STOCK_ID = K.STOCK_ID LEFT JOIN 
                            SiparisStock SS ON SS.STOCK_ID = K.STOCK_ID LEFT JOIN 
                            #dsn3_alias#.EZGI_DESIGN_PACKAGE_ROW DP ON DP.PACKAGE_RELATED_ID = K.STOCK_ID AND DP.PACKAGE_IS_MASTER = 1
                    	WHERE        
                            KARMA_PRODUCT_ID IN (#karma_product_id_list#)
                        ORDER BY 
                            ENTRY_ID
                    </cfquery>
                </cfif>
            </cfif>
          </cfif>
    </cfif>
    <cfparam name="attributes.page" default=1>
    <cfparam name="attributes.totalrecords" default="#satirlar.recordcount#">
    <cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cf_box scroll="0">
    	<cfform name="list_order" method="post" action="#request.self#?fuseaction=prod.popup_list_ezgi_production_need">
        	<input type="hidden" name="is_submitted" id="is_submitted" value="1">
            <cf_box_search>
				<cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group medium">
                	<select name="unit_type" id="unit_type" style="50px; height:20px">
                    	<option value=""><cf_get_lang dictionary_id='57636.Birim'></option>
                    	<cfoutput query="get_unit">
                         	<option value="#UNIT_ID#" <cfif attributes.unit_type eq UNIT_ID>selected</cfif>>#UNIT#</option>
                      	</cfoutput>
                  	</select>
                </div>
                <div class="form-group medium">
                    <select name="yontem" id="yontem" style="width:120px; height:20px">
                        <option value="1" <cfif attributes.yontem eq 1>selected</cfif>><cf_get_lang dictionary_id='29436.Standart Hesap'></option>
                        
                        <option value="3" <cfif attributes.yontem eq 3>selected</cfif>>Son 3 Ay</option>
                        <option value="4" <cfif attributes.yontem eq 4>selected</cfif>>Son 6 Ay</option>
                        <option value="5" <cfif attributes.yontem eq 5>selected</cfif>>Son 9 Ay</option>
                        <option value="2" <cfif attributes.yontem eq 2>selected</cfif>>Son 12 Ay</option>
                    </select>
                </div>
                <div class="form-group">
                	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='282.Stoklama Zamanı'> (<cf_get_lang dictionary_id='58724.Ay'>)</label>
                 	<div class="col col-6 col-xs-12">
                      	<cfinput type="text" name="uretim_ay" id="uretim_ay" value="#attributes.uretim_ay#" style="width:20px; text-align:center">
                 	</div>
          		</div>
                <div class="form-group">
                	<input type="checkbox" name="is_excel" id="is_excel" value="1" <cfif attributes.is_excel eq 1>checked</cfif>>
                	<cf_get_lang_main no='446.Excel Getir'>
                </div>
           		<div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
           	</cf_box_search>
            <cf_box_search_detail>
            	<div id="detail_search_div" class="col col-12" style="display:table-row;">
                    <div class="col col-3">
                    	<div class="col col-12">
                    		<div class="col col-5">
                            	<label><cf_get_lang dictionary_id='481.Liste Tipi'></label>
                        	</div>
                            <div class="col col-7">
                                <div class="form-group medium">
                                 	<select name="report_type" id="report_type" style=" width:150px; height:20px" onChange="report_type_chng();">
                                      	<option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                                       	<option value="1" <cfif attributes.report_type eq 1>selected</cfif>><cf_get_lang dictionary_id='277.İhtiyacı Karşılamayanlar'></option>
                                     	<option value="2" <cfif attributes.report_type eq 2>selected</cfif>><cf_get_lang dictionary_id='278.İhtiyaç Fazlası Olanlar'></option>
                                      	<option value="3" <cfif attributes.report_type eq 3>selected</cfif>><cf_get_lang dictionary_id='279.Net Bakiye'></option>
                                     	<option value="4" <cfif attributes.report_type eq 4>selected</cfif>><cf_get_lang dictionary_id='280.Üretim Talebi Hesaplama'></option>
                                	</select>
                                </div>
                            </div>
                       	</div>
                        <div class="col col-12"> 
                            <div class="col col-5">
                                <label><label><cf_get_lang dictionary_id='58847.Marka'></label></label>
                            </div>
                            <div class="col col-7">
                                <div class="form-group medium">
                                    <div class="input-group">
                                        <cfoutput>
                                            <input type="hidden" name="product_brand_id" id="product_brand_id" value="<cfif len(attributes.product_brand_name)>#attributes.product_brand_id#</cfif>">
                                            <input type="text" name="product_brand_name" id="product_brand_name" value="<cfif len(attributes.product_brand_name)>#attributes.product_brand_name#</cfif>" onfocus="AutoComplete_Create('product_brand_name','BRAND_NAME','BRAND_NAME','get_brand','0','BRAND_ID,BRAND_NAME','product_brand_id,product_brand_name','','3','130','','');" autocomplete="off">
                                            <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_product_brands&brand_id=list_order.product_brand_id&brand_name=list_order.product_brand_name&keyword='+encodeURIComponent(document.list_order.product_brand_name.value));" title="<cf_get_lang dictionary_id='58847.Marka'>"></span>
                                        </cfoutput>
                                    </div>
                                </div>
                            </div>  
                        </div> 
                        <div class="col col-12">
                    		<div class="col col-5">
                            	<label><cf_get_lang_main no='74.Kategori'></label>
                        	</div>
                            <div class="col col-7">
                                <div class="form-group medium">
                                    <div class="input-group">
                                    	<cfoutput>
                                        <input type="hidden" name="product_code" id="product_code" value="<cfif len(attributes.product_cat) and len(attributes.product_code)>#attributes.product_code#</cfif>">
                                        <input type="hidden" name="product_cat_id" id="product_cat_id" value="<cfif len(attributes.product_cat) and len(attributes.product_cat_id)>#attributes.product_cat_id#</cfif>">
                                        <input type="text" name="product_cat" id="product_cat" style="width:160px;" onFocus="AutoComplete_Create('product_cat','PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','0','PRODUCT_CATID,HIERARCHY','product_cat_id,product_code','','3','175','','1');" value="<cfif len(attributes.product_cat) and len(attributes.product_code)>#attributes.product_cat#</cfif>" autocomplete="off">
                                        <span class="input-group-addon icon-ellipsis btnPoniter" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_cat_names&is_sub_category=1&field_id=list_order.product_cat_id&field_code=list_order.product_code&field_name=list_order.product_cat&field_min=add_design.MIN_MARGIN&field_max=add_design.MAX_MARGIN');" title="<cf_get_lang dictionary_id='37157.Ürün Kategorisi Ekle'>!"></span>
                                        </cfoutput>
                                    </div>
                                </div>
                            </div>
                       	</div>
            		</div>
                  	<div class="col col-3">
                    	<div class="col col-12">
                        	<div class="col col-4">
                            	<label>Şube</label>
                        	</div>
                        	<div class="col col-7">
                            	<div class="form-group">
                                    <select name="branch_id" id="branch_id" style="height:110px; width:95%" multiple>
                                        <cfoutput query="get_branch">
                                            <option value="#BRANCH_ID#" <cfif ListFind(attributes.branch_id,BRANCH_ID)>selected</cfif>>#BRANCH_NAME#</option>
                                        </cfoutput>
                                    </select>
                                </div>
                           	</div>
                       	</div>
                    </div>
                    <div class="col col-3">
                    	<div class="col col-12">
                        	<div class="col col-4">
                            	<label>Depo-Lokasyon</label>
                        	</div>
                        	<div class="col col-7">
                            	<div class="form-group">
                                    <select name="departments" style="height:110px; width:95%" multiple>
                                        <cfoutput query="get_department">
                                            <optgroup label="#department_head#">
                                                <cfquery name="GET_LOCATION" dbtype="query">
                                                    SELECT * FROM GET_ALL_LOCATION WHERE DEPARTMENT_ID = #get_department.department_id[currentrow]#
                                                </cfquery>
                                                <cfif get_location.recordcount>
                                                    <cfloop from="1" to="#get_location.recordcount#" index="s">
                                                        <option value="#department_id#-#get_location.location_id[s]#" <cfif listfind(attributes.departments,'#department_id#-#get_location.location_id[s]#',',')>selected</cfif>>&nbsp;&nbsp;#get_location.comment[s]#</option>
                                                    </cfloop>
                                                </cfif>
                                            </optgroup>					  
                                        </cfoutput>
                                    </select>
                                </div>
                           	</div>
                       	</div>
                    </div>
                    <div class="col col-3">
                    	<div class="col col-12">
                            <div class="col col-1">
                            	<div class="form-group">
                                	<div class="input-group">
                                		<input id="ihr_sat" name="ihr_sat" value="1" type="checkbox" <cfif isdefined('attributes.ihr_sat') and len(attributes.ihr_sat)>checked</cfif>>
                            		</div>
                                </div>
                            </div>
                            <div class="col col-11">
                                <label><cf_get_lang dictionary_id='281.İhracat Satışlarını Dahil Et'></label>
                            </div>
                       	</div> 
                      	<div class="col col-12">
                            <div class="col col-1">
                            	<div class="form-group">
                                	<div class="input-group">
                                		<input id="is_production" name="is_production" value="1" type="checkbox" <cfif isdefined('attributes.is_production') and len(attributes.is_production)>checked</cfif>>
                            		</div>
                                </div>
                            </div>
                            <div class="col col-11">
                                <label><cf_get_lang dictionary_id='1123.Üretim Hariç'></label>
                            </div>
                       	</div>
                        <div class="col col-12">
                            <div class="col col-1">
                            	<div class="form-group">
                                	<div class="input-group">
                                		<input id="calc_method" name="calc_method" value="1" type="checkbox" <cfif isdefined('attributes.calc_method') and len(attributes.calc_method)>checked</cfif>>
                            		</div>
                                </div>
                            </div>
                            <div class="col col-11">
                                <label><cf_get_lang dictionary_id='40054.Sapma'></label>
                            </div>
                       	</div>
            		</div>
               	</div>
            </cf_box_search_detail> 
      	</cfform>
    	</cf_box>
    
        <cfsavecontent variable="title"><cf_get_lang dictionary_id="272.Üretim Plan Hesaplama"></cfsavecontent>
        <cfsavecontent variable="right_menu">
            <cfif attributes.branch_id eq '' and attributes.departments eq ''>
                 <a href="javascript://" onclick="seviyelendir();">
                     <img src="images/rotate_bottom.gif" id="seviye" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='36590.Paket Bilgisi'>" />
                       <input type="hidden" name="seviye_" id="seviye_" value="0">
                   </a>&nbsp;&nbsp;
            </cfif>
        </cfsavecontent>
        <cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
            <cfset filename = "#createuuid()#">
            <cfheader name="Expires" value="#Now()#">
            <cfcontent type="application/vnd.msexcel;charset=utf-8">
            <cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
            <cfset attributes.startrow=1>
            <cfset attributes.maxrows = satirlar.recordcount>
        </cfif>
        <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1" right_images="#right_menu#">
             <cf_grid_list>
                <thead>
                    <tr>
                        <th width="30"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        <th width="100"><cf_get_lang dictionary_id='57537.Stok Kodu'></th>
                        <th width="70"><cf_get_lang dictionary_id='57634.Üretici Kodu'></th>
                        <th <cfif attributes.branch_id eq '' and attributes.departments eq ''>onclick="seviyelendir();"</cfif>><cf_get_lang dictionary_id='57657.Ürün'></th>
                        <th width="40"><cf_get_lang dictionary_id='57636.Birim'></th>
                        <th width="50"><cf_get_lang dictionary_id='58120.Gerçek Stok'></th>
                        <cfif attributes.report_type neq 3>
                            <th width="50"><cf_get_lang dictionary_id='45803.Verilen Sipariş'></th>
                            <th width="50"><cf_get_lang dictionary_id='283.Üretimden Gelecek'></th>
                             <th width="50"><cf_get_lang dictionary_id='36388.Üretim Talebi'></th>
                           </cfif>	
                          <th width="50"><cf_get_lang dictionary_id='284.Toplam Artan'></th>
                        <th width="50"><cf_get_lang dictionary_id='40224.Alınan Sipariş'></th>
                        <cfif attributes.branch_id neq '' or attributes.departments neq ''>
                            <th width="50"><cf_get_lang dictionary_id='45525.Sevk Talebi'></th>
                        </cfif>
                        <th width="50"><cf_get_lang dictionary_id='285.Üretime Gidecek'></th>
                        <th width="50"><cf_get_lang dictionary_id='286.Toplam Azalan'></th>
                        <cfif attributes.report_type eq 3>
                            <th width="50"><cf_get_lang dictionary_id='279.Net Bakiye'></th>
                           <cfelse>
                            <th width="50"><cf_get_lang dictionary_id='45241.Satılabilir Stok'></th>
                        </cfif>
                          
                        <cfif attributes.report_type neq 3>
                        	<th width="50"><cf_get_lang dictionary_id='1124.Dönem İhtiyacı'></th>
                        	<th width="50"><cf_get_lang dictionary_id='36437.İhtiyaç'></th>
                            <th style="text-align:center; width:15px">
                                <cfif not attributes.is_excel eq 1>
                                    <input type="checkbox" style="text-align:center;" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="grupla(-1);">
                                </cfif>
                            </th>
                        </cfif>
                    </tr>
                </thead>
                <tbody>
                    <cfif satirlar.recordcount>
                        <cfoutput query="satirlar">
                            <cfset s_t_real_stock = s_t_real_stock + REAL_STOCK>
                        </cfoutput>
                        <cfoutput query="satirlar"  startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                            <cfset satirlar_stock_is_list = ListAppend(satirlar_stock_is_list,stock_id)>
                            <tr id="satir_gizle_#satirlar.currentrow#">
                                <td style="text-align:right;cursor:pointer" onclick="satir_gizle(#satirlar.currentrow#,#STOCK_ID#);">
                                    <cfif not attributes.is_excel eq 1><button name="buton_" style="width:30px; height:20px">#currentrow#</button><cfelse>#currentrow#</cfif>
                                </td>
                                <td>
                                    <cfif not attributes.is_excel eq 1>	
                                       <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_detail_product&sid=#satirlar.stock_id#','list');" class="tableyazi">
                                       #satirlar.PRODUCT_CODE#
                                       </a>
                                      <cfelse>
                                        #satirlar.PRODUCT_CODE#
                                    </cfif> 
                                </td>
                                <td>#MANUFACT_CODE#</td>
                                <td>
                                    <cfif not attributes.is_excel eq 1>
                                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=product.list_product&event=det&pid=#satirlar.product_id#','longpage');" class="tableyazi">
                                        #satirlar.PRODUCT_NAME#
                                        </a>
                                    <cfelse>
                                        #satirlar.PRODUCT_NAME#
                                    </cfif>
                                </td>
                                <td>#satirlar.UNIT#</td>
                                <td style="text-align:right;">
                                    <cfif not attributes.is_excel eq 1>
                                        <cfif IS_KARMA eq 1>
                                            <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_dsp_karma_koli&pid=#satirlar.product_id#<cfif isdefined('attributes.branch_id') and len(attributes.branch_id)>&branch_id=#attributes.branch_id#</cfif><cfif isdefined('attributes.department_id') and len(attributes.department_id)>&department_id=#attributes.department_id#</cfif>','page');">
                                        <cfelse>
                                            <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=stock.detail_store_stock_popup&stock_id=#satirlar.stock_id#&product_id=#product_id#<cfif isdefined('attributes.branch_id') and len(attributes.branch_id)>&branch_id=#attributes.branch_id#</cfif>','page');">
                                        </cfif>
                                            #Amountformat(REAL_STOCK,0)#
                                        </a>
                                    <cfelse>
                                        #Amountformat(REAL_STOCK,0)#
                                    </cfif>
                                  </td>
                                <cfif attributes.report_type neq 3>
                                <td style="text-align:right;">
                                    <cfif not attributes.is_excel eq 1>
                                        <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_reserved_orders&taken=0&pid=#product_id#<cfif isdefined('attributes.branch_id') and len(attributes.branch_id)>&branch_id=#attributes.branch_id#</cfif>','medium');">
                                            #Amountformat(RESERVE_PURCHASE_ORDER_STOCK,0)#
                                            
                                        </a>
                                    <cfelse>
                                        #Amountformat(RESERVE_PURCHASE_ORDER_STOCK,0)#
                                    </cfif>
                                </td>
                                <td style="text-align:right;">
                                    <cfif not attributes.is_excel eq 1>
                                        <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_reserved_production_orders&type=1&pid=#product_id#','medium');">
                                            <cfif PURCHASE_PROD_STOCK gt 0>
                                                <cfif URETIM_PLANI neq PURCHASE_PROD_STOCK>
                                                    <span style="color:red; font-weight:bold">#AmountFormat(PURCHASE_PROD_STOCK,0)#</span>
                                                <cfelse>
                                                    #AmountFormat(PURCHASE_PROD_STOCK,0)#
                                                </cfif>
                                            <cfelse>
                                                <cfif URETIM_PLANI gt 0>
                                                    <span style="color:red; font-weight:bold">0</span>
                                                <cfelse>
                                                    0
                                                </cfif>
                                            </cfif>
                                        </a>
                                    <cfelse>
                                        <cfif PURCHASE_PROD_STOCK gt 0>
                                            <cfif URETIM_PLANI neq PURCHASE_PROD_STOCK>
                                                <span style="color:red; font-weight:bold">#AmountFormat(PURCHASE_PROD_STOCK,0)#</span>
                                              <cfelse>
                                                #AmountFormat(PURCHASE_PROD_STOCK,0)#
                                            </cfif>
                                           <cfelse>
                                            <cfif URETIM_PLANI gt 0>
                                                <span style="color:red; font-weight:bold">0</span>
                                            <cfelse>
                                                0
                                            </cfif>
                                         </cfif>
                                    </cfif>
                                </td>
                                 <td style="text-align:right;">
                                    <cfif not attributes.is_excel eq 1>
                                          <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=prod.popup_dsp_ezgi_production_demand&sid=#STOCK_id#','medium');">#AmountFormat(TALEP,0)#</a>
                                    <cfelse>
                                        #AmountFormat(TALEP,0)#
                                    </cfif>
                                  </td>
                                <td style="text-align:right;">
                                    <strong>
                                        <cfif isdefined('attributes.is_production') and len(attributes.is_production)>
                                            #Amountformat(REAL_STOCK+RESERVE_PURCHASE_ORDER_STOCK+PURCHASE_PROD_STOCK+TALEP-PURCHASE_PROD_STOCK,0)#
                                        <cfelse>
                                            #Amountformat(REAL_STOCK+RESERVE_PURCHASE_ORDER_STOCK+PURCHASE_PROD_STOCK+TALEP,0)#
                                        </cfif>
                                      </strong>
                                   </td>	
                                <cfelse>
                                    <td style="text-align:right;"><strong>#Amountformat(REAL_STOCK,0)#</strong></td>
                                </cfif>
                                <td style="text-align:right;">
                                    <cfif not attributes.is_excel eq 1>	
                                        <cfif IS_KARMA eq 1>
                                            <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_reserved_orders&taken=1&pid=#product_id#&sale_order=#RESERVE_SALE_ORDER_STOCK#&is_karma=1<cfif isdefined('attributes.branch_id') and len(attributes.branch_id)>&branch_id=#attributes.branch_id#</cfif>','medium');">#Amountformat(RESERVE_SALE_ORDER_STOCK,0)#</a>
                                        <cfelse>
                                            <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_reserved_orders&taken=1&pid=#product_id#<cfif isdefined('attributes.branch_id') and len(attributes.branch_id)>&branch_id=#attributes.branch_id#</cfif>','medium');">#Amountformat(RESERVE_SALE_ORDER_STOCK,0)#</a>
                                        </cfif>
                                    <cfelse>
                                        <cfif IS_KARMA eq 1>
                                            #Amountformat(RESERVE_SALE_ORDER_STOCK,0)#
                                        <cfelse>
                                            #Amountformat(RESERVE_SALE_ORDER_STOCK,0)#
                                        </cfif>
                                    </cfif>
                                </td>
                                <cfif attributes.branch_id neq '' or attributes.departments neq ''>
                                    <td style="text-align:right;">
                                   		<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=prod.popup_dsp_ezgi_production_internaldemand&sid=#STOCK_id#<cfif isdefined('attributes.branch_id') and len(attributes.branch_id)>&branch_id=#attributes.branch_id#</cfif><cfif isdefined('attributes.department_id') and len(attributes.department_id)>&department_id=#attributes.department_id#</cfif>','medium');">
                                    		#AmountFormat(SHIP_INTERNAL_STOCK,0)#
                                   		</a>     	
                                  	</td>
                                </cfif>
                                <td style="text-align:right;">
                                    <cfif not attributes.is_excel eq 1>
                                        <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_reserved_production_orders&type=2&pid=#product_id#','medium');">#AmountFormat(RESERVED_PROD_STOCK,0)#</a>
                                    <cfelse>
                                        #AmountFormat(RESERVED_PROD_STOCK,0)#
                                    </cfif>
                                </td>
                                <td style="text-align:right;">
                                	<strong>
                                    	<cfif attributes.branch_id neq '' or attributes.departments neq ''>
                                    		#Amountformat(RESERVED_PROD_STOCK+RESERVE_SALE_ORDER_STOCK+SHIP_INTERNAL_STOCK,0)#
                                        <cfelse>
                                        	#Amountformat(RESERVED_PROD_STOCK+RESERVE_SALE_ORDER_STOCK,0)#
                                        </cfif>
                                  	</strong>
                              	</td>
                                <cfif attributes.report_type eq 3>
                                    <td style="text-align:right;">
                                    	<strong>
                                        	<cfif attributes.branch_id neq '' or attributes.departments neq ''>
                                    			#Amountformat(REAL_STOCK - RESERVE_SALE_ORDER_STOCK - RESERVED_PROD_STOCK - SHIP_INTERNAL_STOCK,0)#
                                            <cfelse>
                                            	#Amountformat(REAL_STOCK - RESERVE_SALE_ORDER_STOCK - RESERVED_PROD_STOCK,0)#
                                            </cfif>
                                        </strong>
                                  	</td>
                                <cfelse>
                                    <td style="text-align:right;">
                                    	<strong>
                                        	<cfif attributes.branch_id neq '' or attributes.departments neq ''>
                                            	#Amountformat(SALEABLE_STOCK-SHIP_INTERNAL_STOCK,0)#
                                            <cfelse>
                                            	#Amountformat(SALEABLE_STOCK,0)#
                                            </cfif>
                                      	</strong>
                                  	</td>
                                    <td style="text-align:right;">
                                        <cfif x_select_control eq 3>
                                            #TlFormat(period_need,0)#
                                        <cfelse>
                                            <cfif not attributes.is_excel eq 1>	
                                                <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=prod.popup_dsp_ezgi_production_need&x_select_control=#x_select_control#&sid=#STOCK_id#<cfif isdefined('attributes.ihr_sat')>&ihr_sat=#attributes.ihr_sat#</cfif>&uretim_ay=#attributes.uretim_ay#','small');">
                                                    #TlFormat(period_need,0)#
                                                </a>  
                                            <cfelse>
                                                #TlFormat(period_need,0)#
                                            </cfif>
                                        </cfif>
                                    </td>
                                </cfif>
                                <cfset need_stock = 0>
                                <cfif attributes.report_type neq 3>
                                    <td style="text-align:right;">
                                    	<cfif attributes.branch_id neq '' or attributes.departments neq ''>
                                        	<cfset new_saleable_stock = SALEABLE_STOCK - SHIP_INTERNAL_STOCK>
                                        <cfelse>
                                        	<cfset new_saleable_stock = SALEABLE_STOCK>
                                        </cfif>
                                        <cfif new_saleable_stock - round(period_need) lt 0>
                                             <cfset need_stock = new_saleable_stock - round(period_need)>
                                              <cfif need_stock lt 0>
                                                <cfset need_stock = need_stock * -1>
                                             </cfif>
                                        <cfelse>
                                              <cfset need_stock = new_saleable_stock - round(period_need)>
                                             <cfif need_stock lt 0>
                                                <cfset need_stock = need_stock * -1>
                                              <cfelse>
                                                 <cfset need_stock = 0>
                                               </cfif>
                                        </cfif>
                                        <span style="color:white; font-size:7px">#need_stock#</span>
                                        <cfif not attributes.is_excel eq 1>
                                            <input type="text" name="need_stock_#STOCK_ID#"  id="need_stock_#STOCK_ID#" value="#need_stock#" style="text-align:right; width:50px" class="box" >
                                        </cfif>
                                    </td>
                                    <td style="text-align:center;">
                                        <cfif not attributes.is_excel eq 1>
                                            <input type="checkbox" name="select_production_#STOCK_ID#" id="select_production_#STOCK_ID#" value="1">
                                        </cfif>
                                    </td>
                                </cfif>
                                <cfset son_row = currentrow>
                            </tr>
                            <cfif not attributes.is_excel eq 1>
                                <cfif isdefined('get_karma_paket') and get_karma_paket.recordcount and satirlar.IS_KARMA eq 1 and attributes.report_type neq 3>
                                    <cfquery name="get_sub_satirlar" dbtype="query">
                                        SELECT * FROM get_karma_paket WHERE KARMA_PRODUCT_ID = #satirlar.PRODUCT_ID# ORDER BY PRODUCT_NAME
                                    </cfquery>
                                    <cfif get_sub_satirlar.recordcount>
                                        <cfloop query="get_sub_satirlar">
                                            <cfif isdefined('sub_satirlar_stock_id_list_#satirlar.STOCK_ID#')>
                                                <cfset 'sub_satirlar_stock_id_list_#satirlar.STOCK_ID#' = ListAppend(Evaluate('sub_satirlar_stock_id_list_#satirlar.STOCK_ID#'),get_sub_satirlar.stock_id)>
                                            <cfelse>
                                                <cfset 'sub_satirlar_stock_id_list_#satirlar.STOCK_ID#' = get_sub_satirlar.stock_id>
                                            </cfif>
                                            <tr id="demonte_1_#satirlar.currentrow#_#get_sub_satirlar.currentrow#" style="display:none" >
                                                <td style="background-color:Gainsboro"></td>
                                                <td style="background-color:Gainsboro">#get_sub_satirlar.PRODUCT_CODE#</td>
                                                <td style="background-color:Gainsboro">#BARCOD#</td>
                                                <td style="background-color:Gainsboro<cfif get_sub_satirlar.PACKAGE_IS_MASTER eq 1>;color:red; font-weight:bold</cfif>">#get_sub_satirlar.PRODUCT_NAME#</td>
                                                <td style="background-color:Gainsboro">#get_sub_satirlar.MAIN_UNIT#</td>
                                                <td style="text-align:right;background-color:Gainsboro">
                                                    <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=stock.detail_store_stock_popup&stock_id=#get_sub_satirlar.stock_id#&product_id=#get_sub_satirlar.product_id#<cfif isdefined('attributes.branch_id') and len(attributes.branch_id)>&branch_id=#attributes.branch_id#</cfif>','page');">
                                                        #AmountFormat(get_sub_satirlar.REAL_STOCK,0)#
                                                    </a>
                                                </td>
                                                <td style="text-align:right;background-color:Gainsboro"></td>
                                                
                                                <td style="text-align:right;background-color:Gainsboro">
                                                    <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=prod.popup_dsp_ezgi_reserved_production_orders&type=1&pid=#get_sub_satirlar.product_id#','medium');">
                                                        #AmountFormat(get_sub_satirlar.URETIM,0)#
                                                    </a>
                                                
                                                </td>
                                                <td style="text-align:right;background-color:Gainsboro"></td>
                                                <cfif isdefined('attributes.is_production') and len(attributes.is_production)>
                                                    <td style="text-align:right;background-color:Gainsboro"><b>#AmountFormat(get_sub_satirlar.REAL_STOCK,0)#</b></td>
                                                <cfelse>
                                                    <td style="text-align:right;background-color:Gainsboro"><b>#AmountFormat(get_sub_satirlar.REAL_STOCK+get_sub_satirlar.URETIM,0)#</b></td>
                                                </cfif>
                                                <td style="text-align:right;background-color:Gainsboro">
                                                    <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_reserved_orders&taken=1&pid=#get_sub_satirlar.product_id#<cfif isdefined('attributes.branch_id') and len(attributes.branch_id)>&branch_id=#attributes.branch_id#</cfif>','medium');">
                                                        #AmountFormat(get_sub_satirlar.SIPARIS,0)#
                                                    </a>   
                                                </td>
                                                <td style="text-align:right;background-color:Gainsboro"></td>
                                                <td style="text-align:right;background-color:Gainsboro"><b>#AmountFormat(get_sub_satirlar.SIPARIS,0)#</b></td>
                                                <cfif attributes.branch_id neq '' or attributes.departments neq ''>
                                                    <td style="text-align:right;background-color:Gainsboro"></td>
                                                </cfif>
                                                <cfif isdefined('attributes.is_production') and len(attributes.is_production)>
                                                    <td style="text-align:right;background-color:Gainsboro;<cfif get_sub_satirlar.REAL_STOCK-get_sub_satirlar.SIPARIS lt 0>color:red</cfif>"><b>#AmountFormat(get_sub_satirlar.REAL_STOCK-get_sub_satirlar.SIPARIS,0)#</b></td>
                                                 <cfelse>
                                                    <td style="text-align:right;background-color:Gainsboro;<cfif get_sub_satirlar.REAL_STOCK+get_sub_satirlar.URETIM-get_sub_satirlar.SIPARIS lt 0>color:red</cfif>"><b>#AmountFormat(get_sub_satirlar.REAL_STOCK+get_sub_satirlar.URETIM-get_sub_satirlar.SIPARIS,0)#</b></td>
                                                </cfif>
                                                <td style="background-color:Gainsboro"></td>
                                                <cfif isdefined('attributes.is_production') and len(attributes.is_production)>
                                                    <cfif get_sub_satirlar.REAL_STOCK-get_sub_satirlar.SIPARIS lt 0>
                                                        <cfset need_sub_stock = (get_sub_satirlar.REAL_STOCK-get_sub_satirlar.SIPARIS)*-1>
                                                    <cfelse>
                                                        <cfset need_sub_stock = 0>
                                                    </cfif>
                                                <cfelse>
                                                    <cfif get_sub_satirlar.REAL_STOCK+get_sub_satirlar.URETIM-get_sub_satirlar.SIPARIS lt 0>
        
                                                        <cfset need_sub_stock = (get_sub_satirlar.REAL_STOCK+get_sub_satirlar.URETIM-get_sub_satirlar.SIPARIS)*-1>
                                                    <cfelse>
                                                        <cfset need_sub_stock = 0>
                                                    </cfif>
                                                </cfif>
                                                <td style="background-color:Gainsboro; text-align:right">
                                                    <span style="color:Gainsboro; font-size:7px">#need_stock#</span>
                                                    <input type="text" name="need_sub_stock_#satirlar.STOCK_ID#_#STOCK_ID#"  id="need_sub_stock_#satirlar.STOCK_ID#_#get_sub_satirlar.STOCK_ID#" value="#TlFormat(need_sub_stock,0)#" style="text-align:right; width:50px" class="box">
                                                </td>
                                                <td style="background-color:Gainsboro;text-align:center">
                                                    <cfif not attributes.is_excel eq 1>
                                                    <input type="checkbox" name="select_sub_production_#satirlar.STOCK_ID#_#STOCK_ID#" id="select_sub_production_#satirlar.STOCK_ID#_#get_sub_satirlar.STOCK_ID#" value="#satirlar.STOCK_ID#_#get_sub_satirlar.STOCK_ID#" onchange="sub_select(this.value);">
                                                    </cfif>
                                                </td>
                                            </tr>
                                        </cfloop>
                                        <input name="sub_satirlar_stock_id_list_#satirlar.STOCK_ID#" id="sub_satirlar_stock_id_list_#satirlar.STOCK_ID#" type="hidden" value="#Evaluate('sub_satirlar_stock_id_list_#satirlar.STOCK_ID#')#">
                                    <cfelse>
                                        <cfset 'sub_satirlar_stock_id_list_#satirlar.STOCK_ID#' = 0>
                                        <input name="sub_satirlar_stock_id_list_#satirlar.STOCK_ID#" id="sub_satirlar_stock_id_list_#satirlar.STOCK_ID#" type="hidden" value="0">
                                    </cfif>
                                <cfelse>
                                    <cfset 'sub_satirlar_stock_id_list_#satirlar.STOCK_ID#' = 0>
                                    <input name="sub_satirlar_stock_id_list_#satirlar.STOCK_ID#" id="sub_satirlar_stock_id_list_#satirlar.STOCK_ID#" type="hidden" value="0">
                                </cfif>
                            </cfif>
                        </cfoutput>
                    <cfelse>
                        <tr>
                            <td colspan="21" class="color-row"><cfif isdefined("attributes.is_submitted")><cf_get_lang dictionary_id='57484.Kayıt Yok'><cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'></cfif>!</td>
                        </tr>
                    </cfif>
                    <cfif isdefined("attributes.is_submitted")>
                    <tfoot>
                           <tr>
                            <cfif attributes.report_type eq 3><cfset colspan_value = 6><cfelse><cfset colspan_value = 5></cfif>
                            <cfif isdefined("attributes.is_submitted") and attributes.totalrecords gt son_row>
                                <cfoutput>
                                    <td style="text-align:right;" colspan="5"><cf_get_lang dictionary_id='49182.Sayfa Toplam'></td>
                                    <td style="text-align:right;">#AmountFormat(t_real_stock,0)#</td>
                                    <td colspan="#colspan_value#"></td>
                                    <cfif attributes.report_type neq 3>
                                    <td style="text-align:center;" colspan="6">
                                        <cfif not attributes.is_excel eq 1>
                                        <button  value="" name="satin_alma_talebi" id="satin_alma_talebi" onClick="kota_kontrol(4);" style="width:140px; height:30px;"><img src="/images/money_plus.gif" alt="<cf_get_lang dictionary_id='49752.Satınalma Talebi'>" border="0">&nbsp;<cf_get_lang dictionary_id='49752.Satınalma Talebi'></button>&nbsp;
                                        <button  value="" id="product_demand" onClick="grupla(-2);" style="width:140px; height:30px;"><img src="/images/action_plus.gif" alt="<cf_get_lang dictionary_id='36388.Üretim Talebi'>" border="0">&nbsp;<cf_get_lang dictionary_id='36388.Üretim Talebi'></button>
                                        </cfif>
                                    </td>
                                    </cfif>
                                </cfoutput>
                               <cfelse>
                                <cfoutput>
                                    <td style="text-align:right;" colspan="5"><strong><cf_get_lang dictionary_id='57680.Genel Toplam'></strong></td>
                                    <td style="text-align:right;"><strong>#AmountFormat(s_t_real_stock,0)#</strong></td>
                                    <td colspan="#colspan_value#"></td>
                                    <cfif attributes.report_type neq 3>
                                    <td style="text-align:center;" colspan="6">
                                        <cfif not attributes.is_excel eq 1>
                                        <button  value="" name="satin_alma_talebi" id="satin_alma_talebi" onClick="kota_kontrol(4);" style="width:140px; height:30px;"><img src="/images/money_plus.gif" alt="<cf_get_lang dictionary_id='49752.Satınalma Talebi'>" border="0">&nbsp;<cf_get_lang dictionary_id='49752.Satınalma Talebi'></button>&nbsp;
                                        <button  value="" id="product_demand" onClick="grupla(-2);" style="width:140px; height:30px;"><img src="/images/action_plus.gif" alt="<cf_get_lang dictionary_id='36388.Üretim Talebi'>" border="0">&nbsp;<cf_get_lang dictionary_id='36388.Üretim Talebi'></button>
                                        </cfif>
                                    </td>
                                    </cfif>
                                </cfoutput>
                            </cfif>     
                        </tr>
                    </tfoot>
                    </cfif>
                </tbody>
              </cf_grid_list>
            <cfset adres="prod.popup_list_ezgi_production_need&is_submitted=1">
            <cfif len(attributes.keyword)>
                <cfset adres = "#adres#&keyword=#attributes.keyword#">
            </cfif>
            <cfif isdefined('attributes.report_type') and len(attributes.report_type)>
                <cfset adres = "#adres#&report_type=#attributes.report_type#">
            </cfif>
            <cfif Len(attributes.product_code)>
                <cfset adres = "#adres#&product_code=#attributes.product_code#">
            </cfif>
            <cfif Len(attributes.product_cat)>
                <cfset adres = "#adres#&product_cat=#attributes.product_cat#">
            </cfif>
            <cfif isdefined('attributes.upd_id') and len(attributes.upd_id)>
                <cfset adres = "#adres#&upd_id=#attributes.upd_id#">
            </cfif>
            <cfif isdefined('attributes.ihr_sat') and len(attributes.ihr_sat)>
                <cfset adres = "#adres#&ihr_sat=#attributes.ihr_sat#">
            </cfif>
            <cfif isdefined('attributes.calc_method') and len(attributes.calc_method)>
                <cfset adres = "#adres#&calc_method=#attributes.calc_method#">
            </cfif>
            <cfif isdefined('attributes.is_production') and len(attributes.is_production)>
                <cfset adres = "#adres#&is_production=#attributes.is_production#">
            </cfif>
            <cfif isdefined('attributes.yontem') and len(attributes.yontem)>
                <cfset adres = "#adres#&yontem=#attributes.yontem#">
            </cfif>

            <cfif isdefined('attributes.unit_type') and len(attributes.unit_type)>
                <cfset adres = "#adres#&unit_type=#attributes.unit_type#">
            </cfif>
            <cfif isdefined('attributes.branch_id') and len(attributes.branch_id)>
                <cfset adres = "#adres#&branch_id=#attributes.branch_id#">
            </cfif>
            <cfif isdefined('attributes.departments') and len(attributes.departments)>
                <cfset adres = "#adres#&departments=#attributes.departments#">
            </cfif>
            <cfif isdefined('attributes.product_brand_id')>
                <cfset adres = "#adres#&product_brand_id=#attributes.product_brand_id#">
            </cfif>
            <cfif isdefined('attributes.product_brand_name')>
                <cfset adres = "#adres#&product_brand_name=#attributes.product_brand_name#">
            </cfif>    
            <cf_paging page="#attributes.page#"
                maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                startrow="#attributes.startrow#"
                adres="#adres#">
        </cf_box>
    </div>
    <form name="aktar_form" method="post">
        <input type="hidden" name="list_price" id="list_price" value="0">
        <input type="hidden" name="price_cat" id="price_cat" value="">
        <input type="hidden" name="CATALOG_ID" id="CATALOG_ID" value="">
        <input type="hidden" name="NUMBER_OF_INSTALLMENT" id="NUMBER_OF_INSTALLMENT" value="">
        <input type="hidden" name="convert_stocks_id" id="convert_stocks_id" value="">
        <input type="hidden" name="convert_amount_stocks_id" id="convert_amount_stocks_id" value="">
        <input type="hidden" name="convert_price" id="convert_price" value="">
        <input type="hidden" name="convert_price_other" id="convert_price_other" value="">
        <input type="hidden" name="convert_money" id="convert_money" value="">
    </form>
    <script language="javascript">
        function grupla(type)
        {
            stock_id_list = '';
            <cfloop list="#satirlar_stock_is_list#" index="i">
                <cfoutput>
                    stockid = #i#;
                </cfoutput>
                row_sub_id_list = document.getElementById('sub_satirlar_stock_id_list_'+stockid).value;
                if(row_sub_id_list != 0)
                {
                    list_uzunluk = list_len(row_sub_id_list,',');
                    for(i=1;i<=list_uzunluk;i++)
                    {
                        aranan_sub_id = list_getat(row_sub_id_list,i,',');
                        if(eval('document.all.select_sub_production_'+stockid+'_'+aranan_sub_id).checked==true)
                        {
                            if(document.getElementById('need_sub_stock_'+stockid+'_'+aranan_sub_id).value > 0)
                                stock_id_list +=aranan_sub_id+'_'+document.getElementById('need_sub_stock_'+stockid+'_'+aranan_sub_id).value+',';
                            else
                            {
                                alert("<cfoutput><cf_get_lang dictionary_id='36359.Miktar Sıfırdan Büyük Olmalıdır'></cfoutput>");
                                document.getElementById('need_sub_stock_'+stockid+'_'+aranan_sub_id).focus();
                                return false;
                            }
                        }
                    }
                }
                if(eval('document.all.select_production_'+stockid).checked==true)
                {
                    stock_id_list +=stockid+'_'+document.getElementById('need_stock_'+stockid).value+',';
                    
                }
                if(type == -1)
                {//hepsini seç denilmişse	
                    if(eval('document.all.select_production_'+stockid).checked==true)
                        document.getElementById('select_production_'+stockid).checked = false;
                    else
                        document.getElementById('select_production_'+stockid).checked = true;
                }
            </cfloop>
            if(type == -2)
            {
                stock_id_list = stock_id_list.substr(0,stock_id_list.length-1);//sondaki virgülden kurtarıyoruz.
                if(stock_id_list!='')
                {
                    document.getElementById('product_demand').disabled = true;
                    <cfif isdefined('attributes.upd_id')>
                        window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_upd_ezgi_production_demand&upd_id=#attributes.upd_id#&stock_id_list=</cfoutput>"+stock_id_list;
                    <cfelse>
                        windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.list_ezgi_e_planning&event=add&stock_id_list='+stock_id_list,'longpage');
                    </cfif>
                }
            }
        }
        function input_control()
        {
            return true;
        }
        function seviyelendir()
        {
            <cfif isdefined("attributes.is_submitted") and satirlar.recordcount>
                if(document.getElementById('seviye_').value==0)
                {
                    document.getElementById('seviye_').value = 1;
                    document.getElementById("seviye").src = "images/rotate_up.gif";
                }
                else
                {
                    document.getElementById('seviye_').value = 0;
                    document.getElementById("seviye").src = "images/rotate_bottom.gif";
                }
                <cfoutput query="satirlar" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                    seviyelendir_demonte(#currentrow#);
                </cfoutput>
            </cfif>
        }
        function seviyelendir_demonte(row_count)
        {
    
            for(i=1;i<=1000;i++)
            {
                if(document.getElementById('demonte_1_'+row_count+'_'+i) != undefined)
                {	
                    if (document.getElementById('demonte_1_'+row_count+'_'+i).style.display == 'none')
                    {
                        document.getElementById('demonte_1_'+row_count+'_'+i).style.display = '';
                    }
                    else
                    {
                        document.getElementById('demonte_1_'+row_count+'_'+i).style.display = 'none';
                    }
                }
            }
        }
        function sub_select(satir)
        {
            satir_stock_id = list_getat(satir,1,'_');
            sub_satir_stock_id = list_getat(satir,2,'_');
            <cfif isdefined("attributes.is_submitted") and satirlar.recordcount>
                <cfoutput query="satirlar" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                    if(satir_stock_id != #satirlar.stock_id#)
                        sub_select_disble(#satirlar.stock_id#,sub_satir_stock_id);
                </cfoutput>
            </cfif>
        }
        function sub_select_disble(row_id,sub_id)
        {
            row_sub_id_list = document.getElementById('sub_satirlar_stock_id_list_'+row_id).value;
            buldunmu = list_find(row_sub_id_list,sub_id,',');
            if(buldunmu > 0)
                document.getElementById('select_sub_production_'+row_id+'_'+sub_id).disabled = true;
        }
        function satir_gizle(current_row_id,stock_id)
        {
            document.getElementById('satir_gizle_'+current_row_id).style.display='none';
            row_sub_id_list = document.getElementById('sub_satirlar_stock_id_list_'+stock_id).value;
            list_uzunluk = list_len(row_sub_id_list,',');
            for(i=1;i<=list_uzunluk;i++)
            {
                document.getElementById('demonte_1_'+current_row_id+'_'+i).style.display = 'none';
            }
        }
        function kota_kontrol(type)
        {
             var convert_list ="";
             var convert_list_amount ="";
             var convert_list_price ="";
             var convert_list_price_other="";
             var convert_list_money ="";
             //
             <cfif isdefined("attributes.is_submitted") and satirlar.recordcount>
                 <cfoutput query="satirlar">
                     if(document.all.select_production_#stock_id#.checked && filterNum(document.getElementById('need_stock_#stock_id#').value) > 0)
                     {
                        convert_list += "#stock_id#,";
                        convert_list_amount += filterNum(document.getElementById('need_stock_#stock_id#').value)+',';
                        convert_list_price_other += '0'+',';
                        convert_list_price += '0'+',';
                        convert_list_money += 'TL'+',';
                     }
                 </cfoutput>
            </cfif>
            document.getElementById('convert_stocks_id').value=convert_list;
            document.getElementById('convert_amount_stocks_id').value=convert_list_amount;
            document.getElementById('convert_price').value=convert_list_price;
            document.getElementById('convert_price_other').value=convert_list_price_other;
            document.getElementById('convert_money').value=convert_list_money;
            if(convert_list)//Ürün Seçili ise
            {
                 if(type==4)
                 {
                    sor=confirm('<cf_get_lang dictionary_id='461.Seçilen Ürünler İçin Talep Oluşturulacaktır'>');
                    if(sor==true)
    
                    {
                        aktar_form.action="<cfoutput>#request.self#</cfoutput>?fuseaction=purchase.list_purchasedemand&event=add&type=convert";
                        document.getElementById('satin_alma_talebi').disabled=true;
                        aktar_form.target='_blank';
                    }
                    else
                        return false;
                    
                 }
                 aktar_form.submit();
             }
             else
                 alert("<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='57657.Ürün'>.");
        }
    </script>