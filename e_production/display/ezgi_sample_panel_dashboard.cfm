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
<cfset attributes.department_id ='15-1,28-8'>
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
	SELECT * FROM SETUP_MONEY WHERE PERIOD_ID = #session.ep.period_id# ORDER BY MONEY_SYMBOL
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
<cfquery name="PUAN_KONTROL" datasource="#DSN3#">
	SELECT 
    	PTIP.STOCK_ID, 
        PTIP.PROPERTY2, 
        S.PRODUCT_NAME, 
        S.PRODUCT_CODE
	FROM     
    	PRODUCT_TREE_INFO_PLUS AS PTIP WITH (NOLOCK) INNER JOIN
        STOCKS AS S WITH (NOLOCK) ON PTIP.STOCK_ID = S.STOCK_ID
	WHERE  
    	NOT (PTIP.PROPERTY2 IS NULL) AND 
        S.PRODUCT_STATUS = 1
</cfquery>
<cfset hata = 0>
<cfoutput query="PUAN_KONTROL">
	<cfif not isnumeric(PUAN_KONTROL.PROPERTY2)>
    	<cfset hata = 1>
    	#PUAN_KONTROL.PRODUCT_CODE# - #PUAN_KONTROL.PRODUCT_NAME# - #PUAN_KONTROL.PROPERTY2#<br>
    </cfif>
</cfoutput>
<cfif hata eq 1>Puanlar Nümerik Olmalıdır.<cfabort></cfif>
<cfif isdefined("attributes.is_form_submitted")>
	<cfif not isdefined("attributes.to_day") or not len(attributes.to_day)>
        <cfset attributes.to_day= now()>
        <cfset attributes.to_day1=dateadd("D",-7,attributes.to_day)>
    </cfif>
    <cfquery name="GET_ORDER_LIST" datasource="#DSN3#">
        SELECT top (15)
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
        	CASE
              	WHEN 
               		ISNULL(S.IS_PROTOTYPE,0) = 1
             	THEN
               		ISNULL((
                            	SELECT        
                               		SUM(EPS.PAKET_SAYISI) AS PAKET_SAYISI
                            	FROM           
                              		EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) INNER JOIN
                                  	SPECTS AS SP WITH (NOLOCK) ON EPS.MODUL_SPECT_ID = SP.SPECT_MAIN_ID
                          		WHERE        
                              		SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID
                    		),0)	
              	ELSE 
                 	ISNULL((
                            	SELECT     
                                 	SUM(PAKET_SAYISI) AS PAKET_SAYISI
                              	FROM         
                                	EZGI_PAKET_SAYISI WITH (NOLOCK)
                            	WHERE     
                                	MODUL_ID = ORR.STOCK_ID	
                        	),0)
           	END AS PAKETSAYISI,
            CASE
              	WHEN 
               		ISNULL(S.IS_PROTOTYPE,0) = 1
             	THEN
               		ISNULL((
                            	SELECT        
                               		SUM(ISNULL(PTIP.PROPERTY2, 0) * EPS.PAKET_SAYISI) AS PAKET_PUAN
                            	FROM           
                              		EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) INNER JOIN
                                  	SPECTS AS SP WITH (NOLOCK) ON EPS.MODUL_SPECT_ID = SP.SPECT_MAIN_ID INNER JOIN 
                                    PRODUCT_TREE_INFO_PLUS AS PTIP WITH (NOLOCK) ON EPS.PAKET_ID = PTIP.STOCK_ID
                          		WHERE        
                              		SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID
                    		),0)	
              	ELSE 
                 	ISNULL((
                            	SELECT 
                                	SUM(ISNULL(PTIP.PROPERTY2, 0) * EPS.PAKET_SAYISI) AS PAKET_PUAN
                        		FROM      
                                	EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) INNER JOIN
                                    PRODUCT_TREE_INFO_PLUS AS PTIP WITH (NOLOCK) ON EPS.PAKET_ID = PTIP.STOCK_ID
                        		WHERE   
                                	EPS.MODUL_ID = ORR.STOCK_ID	
                        	),0)
           	END AS PAKETPUAN,
       		ORR.QUANTITY,
            ORR.SPECT_VAR_ID,
            S.STOCK_ID
       	FROM      
         	ORDERS AS O WITH (NOLOCK) INNER JOIN
            ORDER_ROW AS ORR WITH (NOLOCK) ON O.ORDER_ID = ORR.ORDER_ID INNER JOIN
          	STOCKS AS S WITH (NOLOCK) ON S.STOCK_ID = ORR.STOCK_ID
     	WHERE   
         	((O.PURCHASE_SALES = 1 AND O.ORDER_ZONE = 0) OR (O.PURCHASE_SALES = 0 AND O.ORDER_ZONE = 1)) AND 
          	O.ORDER_STATUS = 1 AND 
         	ORR.ORDER_ROW_CURRENCY NOT IN (-3,-8,-9,-10) AND 
       		S.PRODUCT_CODE LIKE N'01.152.01%'
	</cfquery>   
   	<cfset get_orders_group.SIPARIS  = 0>
    <cfset get_orders_group.SIPARIS_ADET  = 0>
    <cfset get_orders_group.SIPARIS_PAKET  = 0>
	<cfif get_orders.recordcount>
    	<cfoutput query="get_orders">
        	<cfset get_orders_group.SIPARIS  = get_orders_group.SIPARIS + (get_orders.QUANTITY*get_orders.PAKETSAYISI*get_orders.PAKETPUAN)>
          	<cfset get_orders_group.SIPARIS_ADET  = get_orders_group.SIPARIS_ADET + get_orders.QUANTITY>
            <cfset get_orders_group.SIPARIS_PAKET  = get_orders_group.SIPARIS_PAKET + (get_orders.QUANTITY*get_orders.PAKETSAYISI)>
        </cfoutput>
   	</cfif>
    
    <cfquery name="get_uretim" datasource="#dsn3#">
    	SELECT 
        	MASTER_PLAN_ID, 
            MASTER_PLAN_START_DATE, 
            MASTER_PLAN_NUMBER, 
            MASTER_PLAN_DETAIL,
            ISNULL((
            	SELECT 
                	SUM(PO.QUANTITY) AS QUANTITY
               	FROM      
                	PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
                    EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) ON PO.LOT_NO = EP.LOT_NO INNER JOIN
                    STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID
          		WHERE   
                	S.PRODUCT_CATID =
                                     	(
                                        	SELECT 
                                            	DEFAULT_PACKAGE_CAT_ID
                                           	FROM      
                                            	EZGI_DESIGN_DEFAULTS
                                   		) AND 
               		EP.MASTER_PLAN_ID = E.MASTER_PLAN_ID
     		),0) AS TOPLAM_PAKET, 
           	ISNULL((
                   	SELECT 
                      	SUM(ISNULL(PTIP.PROPERTY2, 0) * PO.QUANTITY) AS EMIR_PUAN
                   	FROM      
                   		PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
                      	EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) ON PO.LOT_NO = EP.LOT_NO INNER JOIN
                     	STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
                  		PRODUCT_TREE_INFO_PLUS AS PTIP WITH (NOLOCK) ON S.STOCK_ID = PTIP.STOCK_ID
                 	WHERE   
                   		S.PRODUCT_CATID =
                                		(
                                        	SELECT 
                                             	DEFAULT_PACKAGE_CAT_ID
                                          	FROM      
                                             	EZGI_DESIGN_DEFAULTS AS EZGI_DESIGN_DEFAULTS_3 WITH (NOLOCK)
                                    	) AND 
                     	EP.MASTER_PLAN_ID = E.MASTER_PLAN_ID
        	), 0) AS EMIR_PUAN, 
         	ISNULL((
            		SELECT 
                    	SUM(ISNULL(TBL.AMOUNT, 0) * ISNULL(PTIP.PROPERTY2, 0)) AS AMOUNT
                  	FROM      

                    	PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
                        EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) ON PO.LOT_NO = EP.LOT_NO INNER JOIN
                        STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
                        PRODUCT_TREE_INFO_PLUS AS PTIP WITH (NOLOCK) ON S.STOCK_ID = PTIP.STOCK_ID LEFT OUTER JOIN
                        (
                        	SELECT 
                            	POR.P_ORDER_ID, SUM(PORR.AMOUNT) AS AMOUNT
                        	FROM      
                            	PRODUCTION_ORDER_RESULTS AS POR WITH (NOLOCK) INNER JOIN
                                PRODUCTION_ORDER_RESULTS_ROW AS PORR WITH (NOLOCK) ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
                       		WHERE   
                            	POR.IS_STOCK_FIS = 1 AND 
                                PORR.TYPE = 1
                    		GROUP BY 
                            	POR.P_ORDER_ID
                    	) AS TBL ON PO.P_ORDER_ID = TBL.P_ORDER_ID
             		WHERE   
                    	S.PRODUCT_CATID =
  										(
                                        	SELECT 
                                            	DEFAULT_PACKAGE_CAT_ID
                                          	FROM      
                                            	EZGI_DESIGN_DEFAULTS AS EZGI_DESIGN_DEFAULTS_2 WITH (NOLOCK)
                                      	) AND 
                     	EP.MASTER_PLAN_ID = E.MASTER_PLAN_ID
         	), 0) AS BITEN_EMIR_PUAN,
            ISNULL((
            	SELECT 
                	ISNULL(SUM(TBL_2.AMOUNT), 0) AS AMOUNT
              	FROM      
                	PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
                    EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) ON PO.LOT_NO = EP.LOT_NO INNER JOIN
                    STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
                    (
                    	SELECT 
                        	POR.P_ORDER_ID, SUM(PORR.AMOUNT) AS AMOUNT
                     	FROM      
                        	PRODUCTION_ORDER_RESULTS AS POR WITH (NOLOCK) INNER JOIN
                            PRODUCTION_ORDER_RESULTS_ROW AS PORR WITH (NOLOCK) ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
                       	WHERE   
                        	POR.IS_STOCK_FIS = 1 AND 
                            PORR.TYPE = 1
                     	GROUP BY 
                        	POR.P_ORDER_ID
                 	) AS TBL_2 ON PO.P_ORDER_ID = TBL_2.P_ORDER_ID
              	WHERE   
                	S.PRODUCT_CATID =
                              		(
                                    	SELECT 
                                        	DEFAULT_PACKAGE_CAT_ID
                                  		FROM      
                                        	EZGI_DESIGN_DEFAULTS AS EZGI_DESIGN_DEFAULTS_2
                                 	) AND 
               		EP.MASTER_PLAN_ID = E.MASTER_PLAN_ID
       		),0) AS BITEN_PAKET, 
            ISNULL((
            		SELECT 
                    	SUM(QUANTITY) AS TOPLAM_MODUL
                	FROM      
                    	EZGI_IFLOW_PRODUCTION_ORDERS WITH (NOLOCK)
                  	WHERE   
                    	MASTER_PLAN_ID = E.MASTER_PLAN_ID AND 
                        PRODUCT_TYPE = 2
        	), 0) AS TOPLAM_MODUL, 
            ISNULL((
            		SELECT 
                    	SUM(AMOUNT) AS MODUL_AMOUNT
                   	FROM      
                    	(
                        	SELECT 
                            	MIN(ISNULL(TBL_1.AMOUNT, 0)) AS AMOUNT
                         	FROM      
                            	PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
                                EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) ON PO.LOT_NO = EP.LOT_NO INNER JOIN
                                STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
                                (
                                	SELECT 
                                    	POR.P_ORDER_ID, 
                                        SUM(PORR.AMOUNT) AS AMOUNT
                                 	FROM      
                                    	PRODUCTION_ORDER_RESULTS AS POR WITH (NOLOCK) INNER JOIN
                                        PRODUCTION_ORDER_RESULTS_ROW AS PORR WITH (NOLOCK) ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
                                  	WHERE   
                                    	POR.IS_STOCK_FIS = 1 AND 
                                        PORR.TYPE = 1
                                 	GROUP BY 
                                    	POR.P_ORDER_ID
                             	) AS TBL_1 ON PO.P_ORDER_ID = TBL_1.P_ORDER_ID
                          	WHERE   
                            	S.PRODUCT_CATID =
                                       			(
                                                	SELECT 
                                                    	DEFAULT_PACKAGE_CAT_ID
                                              		FROM      
                                                    	EZGI_DESIGN_DEFAULTS AS EZGI_DESIGN_DEFAULTS_1 WITH (NOLOCK)
                                            	) AND 
                           		EP.MASTER_PLAN_ID = E.MASTER_PLAN_ID AND 
                                EP.PRODUCT_TYPE = 2
                      		GROUP BY 
                        		EP.LOT_NO
                        ) AS TBL2
       		), 0) AS BITEN_MODUL
		FROM     
        	EZGI_IFLOW_MASTER_PLAN AS E WITH (NOLOCK)
		WHERE
			MASTER_PLAN_STATUS = 1
    	ORDER BY
        	MASTER_PLAN_START_DATE DESC
    </cfquery>
    <cfset get_production_group.URETIM  = 0>
    <cfset get_production_group.URETIM_ADET  = 0>
    <cfset get_production_group.URETIM_PAKET  = 0>
	<cfif get_orders.recordcount>
    	<cfoutput query="get_uretim">
        	<cfset get_production_group.URETIM  = get_production_group.URETIM + (EMIR_PUAN-BITEN_EMIR_PUAN)>
          	<cfset get_production_group.URETIM_ADET  = get_production_group.URETIM_ADET + (TOPLAM_MODUL-BITEN_MODUL)>
            <cfset get_production_group.URETIM_PAKET  = get_production_group.URETIM_PAKET + (TOPLAM_PAKET-BITEN_PAKET)>
        </cfoutput>
   	</cfif>
    <cfquery name="get_store" datasource="#dsn3#">
         	SELECT        
            	TBL2.KARMA_PRODUCT_ID, 
                ISNULL(MIN(TOPLAM),0) AS REAL_STOCK
        	FROM            
            	(
    				SELECT        
                    	TBL.PRODUCT_ID, 
                        KP.KARMA_PRODUCT_ID, 
                        ISNULL(SUM(TBL.REAL_STOCK/PRODUCT_AMOUNT),0) AS TOPLAM
                  	FROM            
                    	(
                        	SELECT        
                                STOCK_IN - STOCK_OUT AS REAL_STOCK, 
                                PRODUCT_ID
                         	FROM            
                            	#dsn2_alias#.STOCKS_ROW WITH (NOLOCK)
                        	WHERE        
                            	STORE IS NOT NULL AND 
                                STORE_LOCATION IS NOT NULL
								<cfif listLen(attributes.department_id)>
                                  AND   
                                  (
                                    <cfloop from="1" to="#listlen(attributes.department_id)#" index="k">
                                        STORE = #ListGetAt(ListGetAt(attributes.department_id,k),1,'-')# AND 
                                        STORE_LOCATION = #ListGetAt(ListGetAt(attributes.department_id,k),2,'-')#
                                        <cfif k neq listlen(attributes.department_id)>OR</cfif>
                                    </cfloop>
                                    )
                                </cfif>
                         	UNION ALL
                          	SELECT        
                                STOCK_IN - STOCK_OUT AS REAL_STOCK, 
                                PRODUCT_ID
                         	FROM            
                            	#dsn2_alias#.STOCKS_ROW AS SR WITH (NOLOCK)
                          	WHERE        
                            	UPD_ID IS NULL AND 
                                STOCK_IN - STOCK_OUT > 0
								<cfif listLen(attributes.department_id)>
                                  AND   
                                  (
                                    <cfloop from="1" to="#listlen(attributes.department_id)#" index="k">
                                        STORE = #ListGetAt(ListGetAt(attributes.department_id,k),1,'-')# AND 
                                        STORE_LOCATION = #ListGetAt(ListGetAt(attributes.department_id,k),2,'-')#
                                        <cfif k neq listlen(attributes.department_id)>OR</cfif>
                                    </cfloop>
                                    )
                                </cfif>
                		) AS TBL RIGHT OUTER JOIN
                     	#dsn1_alias#.KARMA_PRODUCTS AS KP WITH (NOLOCK) ON TBL.PRODUCT_ID = KP.PRODUCT_ID
              		GROUP BY 
                    	TBL.PRODUCT_ID, 
                        KP.KARMA_PRODUCT_ID

            	) TBL2 INNER JOIN
                STOCKS AS S WITH (NOLOCK) ON S.PRODUCT_ID = TBL2.KARMA_PRODUCT_ID
           	WHERE 
            	S.PRODUCT_CODE LIKE '01.152.01%'
        	GROUP BY
            	TBL2.KARMA_PRODUCT_ID    	
          	HAVING
            	ISNULL(MIN(TOPLAM),0)>0
 	</cfquery>
    <cfquery name="get_store_puan" datasource="#dsn3#">
    	SELECT        
            SUM(TBL.REAL_STOCK) AS REAL_STOCK,
            ISNULL(PTIP.PROPERTY2,0) AS PUAN,
            TBL.STOCK_ID
      	FROM            
        	(
              	SELECT        
                	STOCK_IN - STOCK_OUT AS REAL_STOCK, 
                  	STOCK_ID
          		FROM            
              		#dsn2_alias#.STOCKS_ROW WITH (NOLOCK)
              	WHERE        
                 	STORE IS NOT NULL AND 
                 	STORE_LOCATION IS NOT NULL
					<cfif listLen(attributes.department_id)>
                    	AND   
                      	(
                      	<cfloop from="1" to="#listlen(attributes.department_id)#" index="k">
                        	STORE = #ListGetAt(ListGetAt(attributes.department_id,k),1,'-')# AND 
                         	STORE_LOCATION = #ListGetAt(ListGetAt(attributes.department_id,k),2,'-')#
                         	<cfif k neq listlen(attributes.department_id)>OR</cfif>
                       	</cfloop>
                      	)
                        </cfif>
             	UNION ALL
             	SELECT        
            		STOCK_IN - STOCK_OUT AS REAL_STOCK, 
              		STOCK_ID
               	FROM            
              		#dsn2_alias#.STOCKS_ROW AS SR WITH (NOLOCK)
            	WHERE        
                	UPD_ID IS NULL AND 
                  	STOCK_IN - STOCK_OUT > 0
					<cfif listLen(attributes.department_id)>
                   		AND   
                     	(
                      	<cfloop from="1" to="#listlen(attributes.department_id)#" index="k">
                       		STORE = #ListGetAt(ListGetAt(attributes.department_id,k),1,'-')# AND 
                         	STORE_LOCATION = #ListGetAt(ListGetAt(attributes.department_id,k),2,'-')#
                         	<cfif k neq listlen(attributes.department_id)>OR</cfif>
                    	</cfloop>
                    	)
                 	</cfif>
       		) AS TBL INNER JOIN
            STOCKS AS S WITH (NOLOCK) ON TBL.STOCK_ID = S.STOCK_ID INNER JOIN
         	PRODUCT_TREE_INFO_PLUS AS PTIP WITH (NOLOCK) ON S.STOCK_ID = PTIP.STOCK_ID
     	WHERE
        	S.PRODUCT_CODE LIKE '01.151.01.01%' 
       	GROUP BY
        	PTIP.PROPERTY2,
            TBL.STOCK_ID
 	</cfquery>
    <cfquery name="get_store" dbtype="query">
    	SELECT
        	SUM(REAL_STOCK) AS TOPLAM
       	FROM
        	get_store
    </cfquery>
    <cfset get_store_group.DEPO  = 0>
    <cfset get_store_group.DEPO_ADET  = 0>
    <cfset get_store_group.DEPO_PAKET = 0>
	<cfif get_orders.recordcount>
    	<cfoutput query="get_store">
          	<cfset get_store_group.DEPO_ADET  = get_store_group.DEPO_ADET + TOPLAM>
        </cfoutput>
        <cfoutput query="get_store_puan">
        	<cfset get_store_group.DEPO_PAKET  = get_store_group.DEPO_PAKET + get_store_puan.real_stock>
        	<cfif isnumeric(get_store_puan.PUAN)>
        		<cfset get_store_group.DEPO  = get_store_group.DEPO + (get_store_puan.PUAN*get_store_puan.real_stock)>
            </cfif>
        </cfoutput>
   	</cfif>
	<cfset arama_yapilmali = 0>
<cfelse>
	<cfset get_orders_group.KALAN = 0>
	<cfset get_torba_group.KALAN = 0>
    <cfset get_uretim_group.KALAN = 0>
    <cfset get_orders_group.KALAN_ADET = 0>
	<cfset get_torba_group.KALAN_ADET = 0>
    <cfset get_uretim_group.KALAN_ADET = 0>
    <cfset get_orders_group.HATA = 0>
	<cfset get_torba_group.HATA = 0>
    <cfset get_uretim_group.HATA = 0>
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
				Gabba Panel Üretim
			</div>
            <div class="col col-4 col-xs-12"></div>
		</div>
        <!---<cfset 'item_1' = "Sipariş">
      	<cfset 'value_1' = "#Round(get_orders_group.SIPARIS)#">
        <cfset 'item_2' = "Bekleyen">
      	<cfset 'value_2' = "#Round(get_torba_group.KALAN)#">
        <cfset 'item_3' = "Üretim">
      	<cfset 'value_3' = "#Round(get_uretim_group.KALAN)#">--->
        <cfset 'item_1' = "Sipariş">
      	<cfset 'value_1' = "#Round(get_orders_group.SIPARIS_ADET)#">
        <cfset 'item_2' = "Üretim">
      	<cfset 'value_2' = "#Round(get_production_group.URETIM_ADET)#">
        <cfset 'item_3' = "Depo">
      	<cfset 'value_3' = "#Round(get_store_group.DEPO_ADET)#">
		<div class="col col-12 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
        	<div class="col col-12 col-xs-12" >
				<div class="col col-4 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
					<div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                    	SİPARİŞ (Takım)
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:90px; font-weight:bold">
                      	<span class="counter" data-count="<cfoutput>#floor(get_orders_group.SIPARIS)#</cfoutput>"><b><cfoutput>#floor(get_orders_group.SIPARIS)#</cfoutput></b></span>
                    </div>
				</div>
                <div class="col col-4 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
					<div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                    	ÜRETİM (Takım) 
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:90px; font-weight:bold">
                    	<span class="counter" data-count="<cfoutput>#floor(get_production_group.URETIM)#</cfoutput>"><b><cfoutput>#floor(get_production_group.URETIM)#</cfoutput></b></span>
                    </div>
				</div>
                <div class="col col-4 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
					<div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                    	DEPO (Takım)
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:90px; font-weight:bold">
                     	<span class="counter" data-count="<cfoutput>#floor(get_store_group.DEPO)#</cfoutput>"><b><cfoutput>#floor(get_store_group.DEPO)#</cfoutput></b></span>
                    </div>
				</div>
          	</div>
        	<div class="col col-12 col-xs-12" >
				<div class="col col-4 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
					<div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                    	SİPARİŞ (Modül)
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:90px; font-weight:bold">
                      	<span class="counter" data-count="<cfoutput>#floor(get_orders_group.SIPARIS_ADET)#</cfoutput>"><b><cfoutput>#floor(get_orders_group.SIPARIS_ADET)#</cfoutput></b></span>
                    </div>
				</div>
                <div class="col col-4 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
					<div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                    	ÜRETİM (Modül) 
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:90px; font-weight:bold">
                    	<span class="counter" data-count="<cfoutput>#floor(get_production_group.URETIM_ADET)#</cfoutput>"><b><cfoutput>#floor(get_production_group.URETIM_ADET)#</cfoutput></b></span>
                    </div>
				</div>
                <div class="col col-4 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
					<div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                    	DEPO (Modül)
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:90px; font-weight:bold">
                     	<span class="counter" data-count="<cfoutput>#floor(get_store_group.DEPO_ADET)#</cfoutput>"><b><cfoutput>#floor(get_store_group.DEPO_ADET)#</cfoutput></b></span>
                    </div>
				</div>
          	</div>
            <div class="col col-12 col-xs-12" >
				<div class="col col-4 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
					<div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                    	SİPARİŞ (Paket)
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:90px; font-weight:bold">
                      	<span class="counter" data-count="<cfoutput>#floor(get_orders_group.SIPARIS_PAKET)#</cfoutput>"><b><cfoutput>#floor(get_orders_group.SIPARIS_PAKET)#</cfoutput></b></span>
                    </div>
				</div>
                <div class="col col-4 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
					<div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                    	ÜRETİM (Paket) 
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:90px; font-weight:bold">
                    	<span class="counter" data-count="<cfoutput>#floor(get_production_group.URETIM_PAKET)#</cfoutput>"><b><cfoutput>#floor(get_production_group.URETIM_PAKET)#</cfoutput></b></span>
                    </div>
				</div>
                <div class="col col-4 col-xs-12" style="margin-top:1%;border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%;">
					<div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:40px;font-weight:bold">
                    	DEPO (Paket)
                    </div>
                    <div style="border:solid 1px #c3c3c3;padding:0.5%;margin-bottom:0.5%; text-align:center; font-size:90px; font-weight:bold">
                     	<span class="counter" data-count="<cfoutput>#floor(get_store_group.DEPO_PAKET)#</cfoutput>"><b><cfoutput>#floor(get_store_group.DEPO_PAKET)#</cfoutput></b></span>
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
	setTimeout(function(){window.location.reload(1);}, 50000);
	function go_func(type)
	{
		alert(type)
	}
	function refresh_page()
	{
		window.location.reload();
	}
</script>