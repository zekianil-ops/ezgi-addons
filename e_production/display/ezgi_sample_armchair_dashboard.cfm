<script src="JS/Chart.min.js"></script>
<script src="fckeditor/ckfinder/plugins/gallery/colorbox/jquery.min.js"></script>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.offer_stage" default="">
<cfparam name="attributes.sort_type" default="3">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.durum_siparis" default="">
<cfparam name="attributes.member_cat_type" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.member_name" default="">
<cfparam name="attributes.member_type" default="">
<cfparam name="attributes.record_emp_id" default="">
<cfparam name="attributes.record_emp_name" default="">
<cfparam name="attributes.category_name" default="">
<cfparam name="attributes.list_type" default="1">
<cfparam name="attributes.currency_id" default="">
<cfparam name="attributes.result_type" default="">
<cfparam name="attributes.sales_type" default="">
<cfparam name="attributes.start_date" default="#DateFormat(DateAdd('yyyy',-1,now()),dateformat_style)#">
<cfparam name="attributes.finish_date" default="#DateFormat(now(),dateformat_style)#">
<cfparam name="attributes.deliver_start_date" default="">
<cfparam name="attributes.deliver_finish_date" default="">
<cfparam name="attributes.is_form_submitted" default="1">
<cfset t_miktar = 0>
<cfset t_miktar1 = 0>
<cfset t_miktar2 = 0>
<cfset ct_id =0>
<cfif isdefined('attributes.start_date') and isdate(attributes.start_date)>
	<cf_date tarih='attributes.start_date'>
</cfif>	
<cfif isdefined('attributes.finish_date') and isdate(attributes.finish_date)>
	<cf_date tarih='attributes.finish_date'>
</cfif>
<cfif isdefined('attributes.deliver_start_date') and isdate(attributes.deliver_start_date)>
	<cf_date tarih='attributes.deliver_start_date'>
</cfif>	
<cfif isdefined('attributes.deliver_finish_date') and isdate(attributes.deliver_finish_date)>
	<cf_date tarih='attributes.deliver_finish_date'>
</cfif>
<cfquery name="get_money" datasource="#dsn#">
	SELECT * FROM SETUP_MONEY WITH (NOLOCK) WHERE PERIOD_ID = #session.ep.period_id# ORDER BY MONEY_SYMBOL
</cfquery>
<cfoutput query="get_money">
	<cfset 'RATE2_#MONEY#' = RATE2>
    <cfset 't_tutar_#MONEY#' = 0>
</cfoutput>
 <cfquery name="get_company_logo" datasource="#dsn#">
        SELECT 
            ASSET_FILE_NAME1,
            ASSET_FILE_NAME1_SERVER_ID,
            ADDRESS 
        FROM 
            OUR_COMPANY WITH (NOLOCK)
        WHERE 
            COMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
</cfquery>
<cfif isdefined("attributes.is_form_submitted")>
	<cfif not isdefined("attributes.to_day") or not len(attributes.to_day)>
        <cfset attributes.to_day= now()>
        <cfset attributes.to_day1=dateadd("D",-7,attributes.to_day)>
    </cfif>
    <cfquery name="GET_ORDER_LIST" datasource="#DSN3#">
        SELECT 
            O.ORDER_ID,
            O.COMPANY_ID,
            O.PARTNER_ID,
            O.CONSUMER_ID,
            O.IS_INSTALMENT,
            O.ORDER_HEAD,
            O.ORDER_DATE,
            O.ORDER_NUMBER,
            ISNULL(O.TAXTOTAL,0) as TAXTOTAL,
            ISNULL(O.GROSSTOTAL,0) as GROSSTOTAL,
            ISNULL(O.NETTOTAL,0) as NETTOTAL,
            ISNULL(O.OTHER_MONEY_VALUE,0) AS OTHER_MONEY_VALUE,
            ISNULL(O.OTHER_MONEY,'#session.ep.money#') AS OTHER_MONEY,
            CMP.NICKNAME,
            CP.COMPANY_PARTNER_NAME,
            CP.COMPANY_PARTNER_SURNAME,
            CNS.CONSUMER_NAME,
            CNS.CONSUMER_SURNAME
        FROM 
            ORDERS O
            LEFT JOIN #dsn_alias#.COMPANY CMP WITH (NOLOCK) ON CMP.COMPANY_ID = O.COMPANY_ID
            LEFT JOIN #dsn_alias#.COMPANY_PARTNER CP WITH (NOLOCK) ON CP.PARTNER_ID = O.PARTNER_ID
            LEFT JOIN #dsn_alias#.CONSUMER CNS WITH (NOLOCK) ON CNS.CONSUMER_ID = O.CONSUMER_ID
        WHERE 
            O.ORDER_STATUS = 1 AND
            (( O.PURCHASE_SALES = 1 AND O.ORDER_ZONE = 0 ) OR ( O.PURCHASE_SALES = 0 AND O.ORDER_ZONE = 1 )) AND
           	O.ORDER_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('d',1,attributes.to_day)#"> AND
          	O.ORDER_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('d',-1,attributes.to_day)#"> AND
            ISNULL(O.IS_INSTALMENT,0) = 0 
        ORDER BY
            O.ORDER_DATE DESC
    </cfquery>

	<cfquery name="get_orders" datasource="#dsn3#">
		SELECT 
                	ISNULL((
                    		SELECT 
                            	SUM(PO.QUANTITY) AS QUANTITY
                           	FROM     
                            	PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) INNER JOIN
                             	PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
                          	WHERE   
                            	POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID AND 
                                ORR.STOCK_ID = PO.STOCK_ID
                 	), 0) AS URETIM,
                    ISNULL((
                    	SELECT 
                        	TOP (1) PROPERTY2
						FROM     
                        	PRODUCT_TREE_INFO_PLUS WITH (NOLOCK)
						WHERE  
                        	NOT (PROPERTY2 IS NULL) AND 
                            STOCK_ID = ORR.STOCK_ID
                    ),0) AS PUAN,
                    ORR.QUANTITY, 
                    ORR.DELIVER_DATE, 
                    ORR.UNIT, 
                    O.ORDER_DATE AS ACTION_DATE
               	FROM      
                	ORDERS AS O WITH (NOLOCK) INNER JOIN
                    PRODUCT_UNIT AS PU WITH (NOLOCK) INNER JOIN
                    STOCKS AS S WITH (NOLOCK) ON PU.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
                    ORDER_ROW AS ORR WITH (NOLOCK) ON S.STOCK_ID = ORR.STOCK_ID AND S.PRODUCT_ID = ORR.PRODUCT_ID ON O.ORDER_ID = ORR.ORDER_ID
            	WHERE   
                	((O.PURCHASE_SALES = 1 AND O.ORDER_ZONE = 0) OR (O.PURCHASE_SALES = 0 AND O.ORDER_ZONE = 1)) AND 
                    O.ORDER_STATUS = 1 AND 
                    ORR.ORDER_ROW_CURRENCY = - 5 AND 
                    S.PRODUCT_CODE LIKE N'01.152.02.02%' 
	</cfquery>   
    <cfset get_orders_group.KALAN  = 0>
    <cfset get_orders_group.KALAN_ADET  = 0>
    <cfset get_orders_group.HATA  = 0>
	<cfif get_orders.recordcount>
    	<cfoutput query="get_orders">
        	<cfif QUANTITY - URETIM gt 0>
            	<cfif isnumeric(puan)>
        			<cfset get_orders_group.KALAN  = get_orders_group.KALAN + ((QUANTITY - URETIM)*puan)>
                    <cfset get_orders_group.KALAN_ADET  = get_orders_group.KALAN_ADET + (QUANTITY - URETIM)>
                </cfif>
        	<CFELSE>
            	<cfset get_orders_group.HATA  = 1>
            </cfif>
        </cfoutput>
   	</cfif>
        <cfquery name="get_torba" datasource="#dsn3#">
    	SELECT 
        	CASE
        		WHEN
                	(
                    	SELECT TOP (1)
                        	POR.ORDER_ROW_ID
						FROM     
                        	PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) INNER JOIN
                  			ORDER_ROW AS ORR WITH (NOLOCK) ON POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
						WHERE  
                        	POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
                    ) > 0 AND ISNULL(S.IS_SERIAL_NO,0) = 0
           		THEN
                	1
            	WHEN
                	(
                    	SELECT TOP (1)
                        	POR.ORDER_ROW_ID
						FROM     
                        	PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) INNER JOIN
                  			ORDER_ROW AS ORR WITH (NOLOCK) ON POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
						WHERE  
                        	POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
                    ) > 0 AND ISNULL(S.IS_SERIAL_NO,0) = 1
           		THEN
                	1
            	ELSE
                	0
           	END AS PLAN_,
        	PO.P_ORDER_ID,
        	EMA.MASTER_ALT_PLAN_ID, 
            S.PRODUCT_NAME, 
            S.PRODUCT_CODE, 
            EMA.MASTER_PLAN_ID, 
            EMA.MASTER_ALT_PLAN_NO, 
            PO.QUANTITY,
            ISNULL((
            	SELECT 
                	SUM(PORR.AMOUNT) AS URETIM_SONUC
            	FROM      
                	PRODUCTION_ORDER_RESULTS AS POR WITH (NOLOCK) INNER JOIN
                    PRODUCTION_ORDER_RESULTS_ROW AS PORR WITH (NOLOCK) ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
            	WHERE   
                	POR.P_ORDER_ID = PO.P_ORDER_ID AND 
                    POR.IS_STOCK_FIS = 1 AND 
                    PORR.TYPE = 1
       		),0) AS URETILEN, 
            ISNULL((
               	SELECT 
                	TOP (1) PROPERTY2 
				FROM     
                 	PRODUCT_TREE_INFO_PLUS WITH (NOLOCK)
				WHERE  
                	NOT (PROPERTY2 IS NULL) AND 
                 	STOCK_ID = PO.STOCK_ID
          	),0) AS PUAN,
            PO.P_ORDER_NO

		FROM     
        	EZGI_MASTER_ALT_PLAN AS EMA WITH (NOLOCK) INNER JOIN
            EZGI_MASTER_PLAN_RELATIONS AS EMR WITH (NOLOCK) ON EMA.MASTER_ALT_PLAN_ID = EMR.MASTER_ALT_PLAN_ID INNER JOIN
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
            STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID
		WHERE  
        	EMA.MASTER_PLAN_ID IN
                      			(
                                	SELECT 
                                    	MASTER_PLAN_ID
                       				FROM      
                                    	EZGI_MASTER_PLAN WITH (NOLOCK)
                       				WHERE   
                                    	MASTER_PLAN_PROCESS = 1
                             	) AND 
           	ISNULL(EMA.PLAN_TYPE,0) = 1 AND 
            S.PRODUCT_CODE LIKE N'01.152.02.02%'
	</cfquery>
    <cfquery name="get_uretim" datasource="#dsn3#">
    	SELECT
        	CASE
        		WHEN
                	(
                    	SELECT TOP (1)
                        	POR.ORDER_ROW_ID
						FROM     
                        	PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) INNER JOIN
                  			ORDER_ROW AS ORR WITH (NOLOCK) ON POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
						WHERE  
                        	POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
                    ) > 0 AND ISNULL(S.IS_SERIAL_NO,0) = 0
           		THEN
                	1
            	WHEN
                	(
                    	SELECT TOP (1)
                        	POR.ORDER_ROW_ID
						FROM     
                        	PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) INNER JOIN
                  			ORDER_ROW AS ORR WITH (NOLOCK) ON POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
						WHERE  
                        	POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
                    ) > 0 AND ISNULL(S.IS_SERIAL_NO,0) = 1
           		THEN
                	1
            	ELSE
                	0
           	END AS PLAN_,
        	PO.P_ORDER_ID, 
        	EMA.MASTER_ALT_PLAN_ID, 
            S.PRODUCT_NAME, 
            S.PRODUCT_CODE, 
            EMA.MASTER_PLAN_ID, 
            EMA.MASTER_ALT_PLAN_NO, 
            PO.QUANTITY,
            ISNULL((
            	SELECT 
                	SUM(PORR.AMOUNT) AS URETIM_SONUC
            	FROM      
                	PRODUCTION_ORDER_RESULTS AS POR WITH (NOLOCK) INNER JOIN
                    PRODUCTION_ORDER_RESULTS_ROW AS PORR WITH (NOLOCK) ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
            	WHERE   
                	POR.P_ORDER_ID = PO.P_ORDER_ID AND 
                    POR.IS_STOCK_FIS = 1 AND 
                    PORR.TYPE = 1
       		),0) AS URETILEN, 
            ISNULL((
               	SELECT 
                	TOP (1) PROPERTY2
				FROM     
                 	PRODUCT_TREE_INFO_PLUS WITH (NOLOCK)
				WHERE  
                	NOT (PROPERTY2 IS NULL) AND 
                 	STOCK_ID = PO.STOCK_ID
          	),0) AS PUAN,
            PO.P_ORDER_NO
		FROM     
        	EZGI_MASTER_ALT_PLAN AS EMA WITH (NOLOCK) INNER JOIN
            EZGI_MASTER_PLAN_RELATIONS AS EMR WITH (NOLOCK) ON EMA.MASTER_ALT_PLAN_ID = EMR.MASTER_ALT_PLAN_ID INNER JOIN
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
            STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID
		WHERE  
        	EMA.MASTER_PLAN_ID IN
                      			(
                                	SELECT 
                                    	MASTER_PLAN_ID
                       				FROM      
                                    	EZGI_MASTER_PLAN WITH (NOLOCK)
                       				WHERE   
                                    	MASTER_PLAN_PROCESS = 1
                             	) AND 
           	ISNULL(EMA.PLAN_TYPE,0) = 0 AND 
            S.PRODUCT_CODE LIKE N'01.152.02.02%'
	</cfquery>
    <cfquery name="get_torba_stoklar" dbtype="query">
      	SELECT 
        	PUAN,
            QUANTITY-URETILEN as KALAN
       	FROM
        	get_torba
      	WHERE
        	PLAN_ = 0 AND
            QUANTITY - URETILEN >0
    </cfquery>
    <cfquery name="get_uretim_stoklar" dbtype="query">
    	SELECT 
        	PUAN,
            QUANTITY-URETILEN as KALAN
       	FROM
        	get_uretim
      	WHERE
        	PLAN_ = 0 AND
            QUANTITY - URETILEN >0
    </cfquery>
    <cfquery name="get_torba_siparisler" dbtype="query">
      	SELECT 
        	PUAN,
            QUANTITY-URETILEN as KALAN
       	FROM
        	get_torba
      	WHERE
        	PLAN_ > 0 AND
            QUANTITY - URETILEN >0
    </cfquery>
    <cfquery name="get_uretim_siparisler" dbtype="query">
    	SELECT 
        	PUAN,
            QUANTITY-URETILEN as KALAN
       	FROM
        	get_uretim
      	WHERE
        	PLAN_ > 0 AND
            QUANTITY - URETILEN >0
    </cfquery>
    <cfset adet_torba_stok = 0>
    <cfset adet_torba_siparis = 0>
    <cfset adet_uretim_stok = 0>
    <cfset adet_uretim_siparis = 0>
    <cfset puan_torba_stok = 0>
    <cfset puan_torba_siparis = 0>
    <cfset puan_uretim_stok = 0>
    <cfset puan_uretim_siparis = 0>
	<cfif get_torba_stoklar.recordcount>
    	<cfoutput query="get_torba_stoklar">
        	<cfif KALAN gt 0>
            	<cfif isnumeric(puan)>
        			<cfset puan_torba_stok  = puan_torba_stok + (KALAN*puan)>
                    <cfset adet_torba_stok  = adet_torba_stok + KALAN>
                </cfif>
        	<cfelse>
            	<cfset adet_torba_stok_hata  = 1>
            </cfif>
        </cfoutput>
    </cfif>
    <cfif get_uretim_stoklar.recordcount>
    	<cfoutput query="get_uretim_stoklar">
        	<cfif KALAN gt 0>
            	<cfif isnumeric(puan)>
        			<cfset puan_uretim_stok  = puan_uretim_stok + (KALAN*puan)>
                    <cfset adet_uretim_stok  = adet_uretim_stok + KALAN>
                </cfif>
        	<cfelse>
            	<cfset adet_uretim_stok_hata  = 1>
            </cfif>
        </cfoutput>
    </cfif>
    <cfif get_torba_siparisler.recordcount>
    	<cfoutput query="get_torba_siparisler">
        	<cfif KALAN gt 0>
            	<cfif isnumeric(puan)>
        			<cfset puan_torba_siparis  = puan_torba_siparis + (KALAN*puan)>
                    <cfset adet_torba_siparis  = adet_torba_siparis + KALAN>
                </cfif>
        	<cfelse>
            	<cfset adet_torba_siparis_hata  = 1>
            </cfif>
        </cfoutput>
    </cfif>
    <cfif get_uretim_siparisler.recordcount>
    	<cfoutput query="get_uretim_siparisler">
        	<cfif KALAN gt 0>
            	<cfif isnumeric(puan)>
        			<cfset puan_uretim_siparis  = puan_uretim_siparis + (KALAN*puan)>
                    <cfset adet_uretim_siparis  = adet_uretim_siparis + KALAN>
                </cfif>
        	<cfelse>
            	<cfset adet_uretim_siparis_hata  = 1>
            </cfif>
        </cfoutput>
    </cfif>
    <cfquery name="get_depo" datasource="#dsn3#">
    	SELECT
        	TYPE,
        	ISNULL(AMOUNT,0) AS AMOUNT,
            ISNULL((
               	SELECT 
                	TOP (1) PROPERTY2
				FROM     
                 	PRODUCT_TREE_INFO_PLUS WITH (NOLOCK)
				WHERE  
                	NOT (PROPERTY2 IS NULL) AND 
                 	STOCK_ID = TBL.STOCK_ID
          	),0) AS PUAN
       	FROM
        	(
            SELECT 
            	E.STOCK_ID, 
                1 AS AMOUNT,
                1 AS TYPE
			FROM     
            	EZGI_WM_SERIAL_NO_LAST_STATUS AS E INNER JOIN
                EZGI_WM_IS_SERIAL_NO_LIVE AS EW ON E.SERIAL_NO = EW.SERIAL_NO INNER JOIN
                STOCKS AS S ON E.STOCK_ID = S.STOCK_ID INNER JOIN
                EZGI_WM_SERIAL_NO_ORDER_LAST_STATUS AS EL ON E.SERIAL_NO = EL.SERIAL_NO
			WHERE  
            	E.DEPARTMENT_ID = 28 AND 
                E.LOCATION_ID = 8 AND 
                S.STOCK_CODE LIKE N'01.152.02.02%'
            	AND EL.RESERVE_ORDER_ROW_ID = 0
          	UNION ALL
            SELECT 
            	E.STOCK_ID, 
                1 AS AMOUNT,
                2 AS TYPE
			FROM     
            	EZGI_WM_SERIAL_NO_LAST_STATUS AS E INNER JOIN
                EZGI_WM_IS_SERIAL_NO_LIVE AS EW ON E.SERIAL_NO = EW.SERIAL_NO INNER JOIN
                STOCKS AS S ON E.STOCK_ID = S.STOCK_ID INNER JOIN
                EZGI_WM_SERIAL_NO_ORDER_LAST_STATUS AS EL ON E.SERIAL_NO = EL.SERIAL_NO
			WHERE  
            	E.DEPARTMENT_ID = 28 AND 
                E.LOCATION_ID = 8 AND 
                S.STOCK_CODE LIKE N'01.152.02.02%'
            	AND EL.RESERVE_ORDER_ROW_ID > 0
          	) AS TBL
    </cfquery>
    <cfset adet_depo_stok = 0>
    <cfset adet_depo_siparis = 0>
    <cfset puan_depo_stok = 0>
    <cfset puan_depo_siparis = 0>
	<cfoutput query="get_depo">
    	<cfif type eq 1>
        	<cfset adet_depo_stok = adet_depo_stok + AMOUNT>
            <cfset puan_depo_stok = puan_depo_stok + (AMOUNT*PUAN)>
        <cfelse>
        	<cfset adet_depo_siparis = adet_depo_siparis + AMOUNT>
        	<cfset puan_depo_siparis = puan_depo_siparis + (AMOUNT*PUAN)>
        </cfif>
    </cfoutput>
<cfelse>
	<cfset adet_depo_stok = 0>
    <cfset adet_depo_siparis = 0>
    <cfset puan_depo_stok = 0>
    <cfset puan_depo_siparis = 0>
	<cfset adet_torba_stok = 0>
    <cfset adet_torba_siparis = 0>
    <cfset adet_uretim_stok = 0>
    <cfset adet_uretim_siparis = 0>
    <cfset puan_torba_stok = 0>
    <cfset puan_torba_siparis = 0>
    <cfset puan_uretim_stok = 0>
    <cfset puan_uretim_siparis = 0>
    <cfset adet_torba_stok_hata = 0>
    <cfset adet_torba_siparis_hata = 0>
    <cfset adet_uretim_stok_hata = 0>
    <cfset adet_uretim_siparis_hata = 0>
    <cfset arama_yapilmali = 1>
</cfif>
<div class="row">
    <div class="col col-12 col-xs-12 form-inline">
        <div class="col col-12 col-xs-12" style="text-align:right;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
        	<div class="col col-3 col-xs-12" style="text-align:left">
            	<cfif len(get_company_logo.ASSET_FILE_NAME1)>
                	<a style="cursor:pointer" onclick="refresh_page();">
                		<cfoutput><img src="#user_domain##file_web_path#settings/#get_company_logo.ASSET_FILE_NAME1#" border="0"></cfoutput>
                    </a>
                </cfif>
            </div>
			<div class="col col-6 col-xs-12" style="text-align:center; font-size:55px; font-weight:bold">
				Gabba Sandalye Üretim
			</div>
            <div class="col col-3 col-xs-12"></div>
		</div>
        <div class="col col-12 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
        	<div class="col col-12 col-xs-12" >
				<div class="col col-4 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
					<div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                    	SİPARİŞ
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:80px; font-weight:bold">
                      	<span class="counter" data-count="<cfoutput>#floor(get_orders_group.KALAN*10)/10#</cfoutput>"><b><cfoutput>#floor(get_orders_group.KALAN*10)/10#</cfoutput></b></span>
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:65px; font-weight:bold; color:red">
                      	<span class="counter" data-count="<cfoutput>#floor(get_orders_group.KALAN_ADET*10)/10#</cfoutput>"><b><cfoutput>#floor(get_orders_group.KALAN_ADET*10)/10#</cfoutput></b></span>
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                            <cfparam name="attributes.page" default=1>
                            <cfparam name="attributes.maxrows" default="20">
                            <cfparam name="attributes.totalrecords" default="#get_order_list.recordcount#">
                            <cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
                            <cf_flat_list>
                                <cfif get_order_list.recordcount>
                                    <thead>
                                        <tr>
                                            <th style="width:70px;"><cf_get_lang_main no="75.no"></th>
                                            <th><cf_get_lang_main no="107.cari hesap"></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfset total_nettotal_ = 0>
                                        <cfset total_grosstotal_ = 0>
                                        <cfset kur_ = 0>
                                        <cfquery name="GET_MONEY_TYPE" datasource="#DSN#">
                                            SELECT DISTINCT MONEY FROM SETUP_MONEY
                                        </cfquery>
                                        <cfloop query="get_money_type">
                                            <cfset 'total_other_money_value_#money#' = 0>
                                            <cfset 'total_other_money_value_kdvsiz_#money#' = 0>
                                        </cfloop>
                                        <cfoutput query="get_order_list" startrow="#attributes.startrow#" maxrows="#session.ep.maxrows#">
                                            <tr>
                                                <td style="text-align:center">#order_number#</td>
                                                <!--- Sirketi al --->
                                                <cfif len(partner_id)>
                                                    <td style="text-align:left">#nickname# - #company_partner_name# #company_partner_surname#</td>
                                                <cfelseif len(consumer_id)>
                                                    <td style="text-align:left">#consumer_name# #consumer_surname#</td>
                                                <cfelse>
                                                    <td></td>
                                                </cfif>
                                            </tr>
                                        </cfoutput>
                                    </tbody>
                                <cfelse>
                                    <tbody>
                                        <tr>
                                            <td><cf_get_lang_main no='72.Kayıt Bulunamadı'> !</td>
                                        </tr>
                                    </tbody>
                                </cfif>
                            </cf_flat_list>
                    </div>
				</div>
                <div class="col col-2 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
					<div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                    	BEKLEYEN
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:80px; font-weight:bold">
                    	<span class="counter" data-count="<cfoutput>#floor((puan_torba_stok+puan_torba_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:65px; font-weight:bold; color:red">
                    	<span class="counter" data-count="<cfoutput>#floor((adet_torba_stok+adet_torba_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    </div>
                 	<div class="col col-12 col-xs-12" >
                     	<div class="col col-6 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:30px;font-weight:bold; background-color:blue">
                            	STOK
                            </div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:50px; font-weight:bold">
                    			<span class="counter" data-count="<cfoutput>#floor((puan_torba_stok)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px; font-weight:bold; color:red">
                    			<span class="counter" data-count="<cfoutput>#floor((adet_torba_stok)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                        </div>
                        <div class="col col-6 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:30px;font-weight:bold; background-color:blue">
                            	SİPARİŞ
                            </div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:50px; font-weight:bold">
                    			<span class="counter" data-count="<cfoutput>#floor((puan_torba_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px; font-weight:bold; color:red">
                    			<span class="counter" data-count="<cfoutput>#floor((adet_torba_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                        </div>
                    </div>
                    <div class="col col-12 col-xs-12" id="summary1" style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
                        <canvas id="myChart1" style="height:100%;"></canvas>
                        <cfset 'item_1' = "Stok">
						<cfset 'value_1' = "#Round(adet_torba_stok)#">
                        <cfset 'item_2' = "Sipariş">
                        <cfset 'value_2' = "#Round(adet_torba_siparis)#">
                        <script>
                            var ctx = document.getElementById('myChart1');
                            var myChart1 = new Chart(ctx, {
                                type: 'doughnut',
                                data: {
                                        labels: [<cfloop from="1" to="2" index="jj">
                                                <cfoutput>"#evaluate("item_#jj#")#"</cfoutput>,</cfloop>],
                                        datasets: [{
                                        label: "<cfoutput>Bekleyen</cfoutput>",
                                        backgroundColor: [<cfloop from="1" to="2" index="jj">'rgba('+Math.floor((Math.random()*255) + 1) + ',' +Math.floor((Math.random()*255) + 1) + ','+ Math.floor((Math.random()*255) + 1)+',0.60)',</cfloop>],
                                        data: [<cfloop from="1" to="2" index="jj"><cfoutput>"#evaluate("value_#jj#")#"</cfoutput>,</cfloop>],
                                            }]
                                        },
                                options: {}
                            });
                        </script>
                    </div>
				</div>
                <div class="col col-2 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
					<div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                    	ÜRETİM
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:80px; font-weight:bold">
                     	<span class="counter" data-count="<cfoutput>#floor((puan_uretim_stok+puan_uretim_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:65px; font-weight:bold; color:red">
                     	<span class="counter" data-count="<cfoutput>#floor((adet_uretim_stok+adet_uretim_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    </div>
                    <div class="col col-12 col-xs-12" >
                     	<div class="col col-6 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:30px;font-weight:bold; background-color:blue">
                            	STOK
                            </div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:50px; font-weight:bold">
                    			<span class="counter" data-count="<cfoutput>#floor((puan_uretim_stok)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px; font-weight:bold; color:red">
                    			<span class="counter" data-count="<cfoutput>#floor((adet_uretim_stok)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                        </div>
                        <div class="col col-6 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:30px;font-weight:bold; background-color:blue">
                            	SİPARİŞ
                            </div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:50px; font-weight:bold">
                    			<span class="counter" data-count="<cfoutput>#floor((puan_uretim_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px; font-weight:bold; color:red">
                    			<span class="counter" data-count="<cfoutput>#floor((adet_uretim_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                        </div>
                    </div>
                    <div class="col col-12 col-xs-12" id="summary2" style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
                        <canvas id="myChart2" style="height:100%;"></canvas>
                        <cfset 'item_1' = "Stok">
						<cfset 'value_1' = "#Round(adet_uretim_stok)#">
                        <cfset 'item_2' = "Sipariş">
                        <cfset 'value_2' = "#Round(adet_uretim_siparis)#">
                        <script>
                            var ctx = document.getElementById('myChart2');
                            var myChart2 = new Chart(ctx, {
                                type: 'doughnut',
                                data: {
                                        labels: [<cfloop from="1" to="2" index="jj">
                                                <cfoutput>"#evaluate("item_#jj#")#"</cfoutput>,</cfloop>],
                                        datasets: [{
                                        label: "<cfoutput>Üretim</cfoutput>",
                                        backgroundColor: [<cfloop from="1" to="2" index="jj">'rgba('+Math.floor((Math.random()*255) + 1) + ',' +Math.floor((Math.random()*255) + 1) + ','+ Math.floor((Math.random()*255) + 1)+',0.60)',</cfloop>],
                                        data: [<cfloop from="1" to="2" index="jj"><cfoutput>"#evaluate("value_#jj#")#"</cfoutput>,</cfloop>],
                                            }]
                                        },
                                options: {}
                            });
                        </script>
                    </div>
				</div>
               	<div class="col col-2 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
					<div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                    	TOPLAM
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:80px; font-weight:bold">
                       	<span class="counter" data-count="<cfoutput>#floor((puan_torba_stok+puan_torba_siparis+puan_uretim_stok+puan_uretim_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:65px; font-weight:bold; color:red">
                       	<span class="counter" data-count="<cfoutput>#floor((adet_torba_stok+adet_torba_siparis+adet_uretim_stok+adet_uretim_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    </div>
                    <div class="col col-12 col-xs-12" >
                     	<div class="col col-6 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:30px;font-weight:bold; background-color:blue">
                            	STOK
                            </div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:50px; font-weight:bold">
                    			<span class="counter" data-count="<cfoutput>#floor((puan_torba_stok+puan_uretim_stok)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px; font-weight:bold; color:red">
                    			<span class="counter" data-count="<cfoutput>#floor((adet_torba_stok+adet_uretim_stok)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                        </div>
                        <div class="col col-6 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:30px;font-weight:bold; background-color:blue">
                            	SİPARİŞ
                            </div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:50px; font-weight:bold">
                    			<span class="counter" data-count="<cfoutput>#floor((puan_torba_siparis+puan_uretim_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px; font-weight:bold; color:red">
                    			<span class="counter" data-count="<cfoutput>#floor((adet_torba_siparis+adet_uretim_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                        </div>
                    </div>
                    <div class="col col-12 col-xs-12" id="summary3" style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
                        <canvas id="myChart3" style="height:100%;"></canvas>
                        <cfset 'item_1' = "Stok">
						<cfset 'value_1' = "#Round(adet_uretim_stok+adet_torba_stok)#">
                        <cfset 'item_2' = "Sipariş">
                        <cfset 'value_2' = "#Round(adet_uretim_siparis+adet_torba_siparis)#">
                        <script>
                            var ctx = document.getElementById('myChart3');
                            var myChart3 = new Chart(ctx, {
                                type: 'doughnut',
                                data: {
                                        labels: [<cfloop from="1" to="2" index="jj">
                                                <cfoutput>"#evaluate("item_#jj#")#"</cfoutput>,</cfloop>],
                                        datasets: [{
                                        label: "<cfoutput>Toplam</cfoutput>",
                                        backgroundColor: [<cfloop from="1" to="2" index="jj">'rgba('+Math.floor((Math.random()*255) + 1) + ',' +Math.floor((Math.random()*255) + 1) + ','+ Math.floor((Math.random()*255) + 1)+',0.60)',</cfloop>],
                                        data: [<cfloop from="1" to="2" index="jj"><cfoutput>"#evaluate("value_#jj#")#"</cfoutput>,</cfloop>],
                                            }]
                                        },
                                options: {}
                            });
                        </script>
                    </div>
				</div>
                
                <div class="col col-2 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
					<div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                    	DEPO
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:80px; font-weight:bold">
                       	<span class="counter" data-count="<cfoutput>#floor((puan_depo_stok+puan_depo_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:65px; font-weight:bold; color:red">
                       	<span class="counter" data-count="<cfoutput>#floor((adet_depo_stok+adet_depo_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    </div>
                    <div class="col col-12 col-xs-12" >
                     	<div class="col col-6 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:30px;font-weight:bold; background-color:blue">
                            	STOK
                            </div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:50px; font-weight:bold">
                    			<span class="counter" data-count="<cfoutput>#floor((puan_depo_stok)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px; font-weight:bold; color:red">
                    			<span class="counter" data-count="<cfoutput>#floor((adet_depo_stok)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                        </div>
                        <div class="col col-6 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:30px;font-weight:bold; background-color:blue">
                            	SİPARİŞ
                            </div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:50px; font-weight:bold">
                    			<span class="counter" data-count="<cfoutput>#floor((puan_depo_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                            <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px; font-weight:bold; color:red">
                    			<span class="counter" data-count="<cfoutput>#floor((adet_depo_siparis)*10)/10#</cfoutput>"><b><cfoutput></cfoutput></b></span>
                    		</div>
                        </div>
                    </div>
                    <div class="col col-12 col-xs-12" id="summary3" style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
                        <canvas id="myChart6" style="height:100%;"></canvas>
                        <cfset 'item_1' = "Stok">
						<cfset 'value_1' = "#Round(adet_depo_stok)#">
                        <cfset 'item_2' = "Sipariş">
                        <cfset 'value_2' = "#Round(adet_depo_siparis)#">
                        <script>
                            var ctx = document.getElementById('myChart6');
                            var myChart6 = new Chart(ctx, {
                                type: 'doughnut',
                                data: {
                                        labels: [<cfloop from="1" to="2" index="jj">
                                                <cfoutput>"#evaluate("item_#jj#")#"</cfoutput>,</cfloop>],
                                        datasets: [{
                                        label: "<cfoutput>Toplam</cfoutput>",
                                        backgroundColor: [<cfloop from="1" to="2" index="jj">'rgba('+Math.floor((Math.random()*255) + 1) + ',' +Math.floor((Math.random()*255) + 1) + ','+ Math.floor((Math.random()*255) + 1)+',0.60)',</cfloop>],
                                        data: [<cfloop from="1" to="2" index="jj"><cfoutput>"#evaluate("value_#jj#")#"</cfoutput>,</cfloop>],
                                            }]
                                        },
                                options: {}
                            });
                        </script>
                    </div>
				</div>
          	</div>
       	</div>
	</div>
</div>
<script language="javascript">
	$(document).ready(function()
	{
		$('.counter').each(function() {
		var $this = $(this),
			countTo = $this.attr('data-count');
		$({ countNum: $this.text()}).animate({
		  countNum: countTo
		},
		{
		  duration: 1500,
		  easing:'linear',
		  step:function() {
			$this.text(Math.floor(this.countNum));
		  },
		  complete:function() {
			$this.text(this.countNum);
		  }
		});
	  });
	});
	setTimeout(function(){window.location.reload(1);}, 100000);
	function go_func(type)
	{
		alert(type)

	}
	function refresh_page()
	{
		window.location.reload();
	}
</script>