<!---
    File: dsp_ezgi_connect_product_detail.cfm
    Folder: Add_Ons\ezgi\e_connect\display
    Author: Ezgi Yazılım
    Date: 01/01/2023
    Description:
--->
<cf_xml_page_edit>
<cfset b_stock_id_list =''>
<cfif isdefined('x_our_company_id') and len(x_our_company_id)>
	<cfset new_dsn3 = '#dsn#_#x_our_company_id#'>
    <cfset new_dsn2 ='#dsn#_#session.ep.period_year#_#x_our_company_id#'>
<cfelse>
	<cfset new_dsn3 = '#dsn#_1'>
    <cfset new_dsn2 = '#dsn#_#session.ep.period_year#_1'>
</cfif>

<cfif isdefined('attributes.related_product')>
	<cfset x_relation_type = 1>
</cfif>

<cfquery name="get_images" datasource="#dsn1#">
 	SELECT * FROM PRODUCT_IMAGES WHERE PRODUCT_ID IN (#attributes.product_id#)
</cfquery>
<cfquery name="GET_PRICE" datasource="#DSN3#">
 	SELECT * FROM PRICE WHERE FINISHDATE IS NULL AND PRODUCT_ID IN (#attributes.product_id#) AND PRICE_CATID = #attributes.PRICE_CAT_ID#
</cfquery>
<cfquery name="GET_CONNECT" datasource="#DSN3#">
 	SELECT * FROM EZGI_CONNECT WHERE CONNECT_ID = #attributes.CONNECT_ID#
</cfquery>
<cfif x_detail_type eq 1>
    <cfquery name="get_product_content" datasource="#dsn#">
        SELECT        
            CONT_HEAD, 
            CONT_SUMMARY, 
            CONT_BODY
        FROM            
            CONTENT
        WHERE        
            CONTENT_ID IN
                        (
                            SELECT        
                                CR.CONTENT_ID
                            FROM            
                                CONTENT_RELATION AS CR INNER JOIN
                                #dsn3_alias#.STOCKS AS S ON CR.ACTION_TYPE_ID = S.PRODUCT_ID
                            WHERE        
                                CR.ACTION_TYPE = N'PRODUCT_ID' AND 
                                S.STOCK_ID = #attributes.stock_id#
                        ) AND 
            CONTENT_STATUS = 1 AND 
            LANGUAGE_ID = 'tr'
    </cfquery>
</cfif>
<cfquery name="get_product_info" datasource="#dsn1#">
	SELECT 
    	P.*,
        (
        	SELECT        
            	TOP (1) ITEM
			FROM            
            	#dsn_alias#.SETUP_LANGUAGE_INFO
			WHERE        
            	UNIQUE_COLUMN_ID = P.PRODUCT_ID AND 
                TABLE_NAME = 'PRODUCT' AND 
                COLUMN_NAME = 'PRODUCT_DETAIL' AND 
                LANGUAGE = 'tr'
        ) AS ITEM
   	FROM 
    	STOCKS S,
        PRODUCT P
  	WHERE 
    	S.PRODUCT_ID = P.PRODUCT_ID AND
    	STOCK_ID = #attributes.stock_id#
</cfquery>
<cfset attributes.product_name = get_product_info.PRODUCT_NAME>
<cfquery name="get_connect_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_CONNECT_SETUP
</cfquery>
<cfquery name="GET_P_UNIT" datasource="#dsn1#">
	SELECT        
    	DIMENTION, 
        WEIGHT, 
        DESI_VALUE, 
        VOLUME
	FROM            
    	PRODUCT_UNIT
	WHERE        
    	PRODUCT_ID = #attributes.product_id# AND 
        IS_MAIN = 1
</cfquery>
<cfif len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1 and len(get_product_info.IS_KARMA_SEVK) and get_product_info.IS_KARMA_SEVK eq 1>
	<cfquery name="get_karma" datasource="#dsn1#">
    	SELECT  
        	KP.UNIT, 
            KP.PRODUCT_AMOUNT, 
            KP.STOCK_ID, 
            S.BARCOD, 
            S.PRODUCT_ID, 
            S.PRODUCT_NAME, 
            S.PRODUCT_CODE,
            (
                SELECT        
                    TOP (1) ITEM
                FROM            
                    #dsn_alias#.SETUP_LANGUAGE_INFO
                WHERE        
                    UNIQUE_COLUMN_ID = S.PRODUCT_ID AND 
                    TABLE_NAME = 'PRODUCT' AND 
                    COLUMN_NAME = 'PRODUCT_DETAIL' AND 
                    LANGUAGE = 'tr'
            ) AS ITEM,
            (
            	SELECT        
                	TOP (1) PATH
				FROM            
                	PRODUCT_IMAGES
				WHERE        
                	PRODUCT_ID = S.PRODUCT_ID AND 
                    IMAGE_SIZE = 0
				ORDER BY 
                	PRODUCT_IMAGEID DESC
            ) AS PATH
		FROM            
        	KARMA_PRODUCTS AS KP INNER JOIN

            #dsn3_alias#.STOCKS AS S ON KP.STOCK_ID = S.STOCK_ID
		WHERE        
        	KP.KARMA_PRODUCT_ID = #get_product_info.PRODUCT_ID#
    </cfquery>
</cfif>
<cfset olcu_A = ''>
<cfset olcu_B = ''>
<cfset olcu_C = ''>
<cfif GET_P_UNIT.recordcount>
	<cfif ListLen(GET_P_UNIT.DIMENTION,'*') eq 3>
		<cfset olcu_A = ListGetAt(GET_P_UNIT.DIMENTION,1,'*')>
        <cfset olcu_B = ListGetAt(GET_P_UNIT.DIMENTION,2,'*')>
        <cfset olcu_C = ListGetAt(GET_P_UNIT.DIMENTION,3,'*')>
	</cfif>
</cfif>
<cfif len(x_alternative_code)> <!---Eğer alternatif Ürün Kategorisi tanımlanmışsa--->
    <cfquery name="get_product_tree" datasource="#dsn3#">
            SELECT        
                E.TIP, 
                ST.PRODUCT_ID,
                ST.STOCK_ID, 
                ST.PRODUCT_NAME, 
                ST.PRODUCT_CODE,
                ST.PRODUCT_CODE_2, 
                E.AMOUNT * E.AMOUNT2 * E.AMOUNT3 * E.AMOUNT4 * E.AMOUNT5 AS AMOUNT, 
                E.IS_PRODUCTION,
                E.IS_TREE, 
                E.STOCK_ID2, 
                E.STOCK_CODE, 
                E.PRODUCT_NAME TREE_NAME, 
                E.QUESTION_ID, 
                S.QUESTION_NAME
            FROM            
                EZGI_PRODUCT_TREE_BOM1 AS E INNER JOIN
                #dsn_alias#.SETUP_ALTERNATIVE_QUESTIONS AS S ON E.QUESTION_ID = S.QUESTION_ID INNER JOIN
                STOCKS AS ST ON E.STOCK_ID = ST.STOCK_ID
            WHERE
                E.STOCK_CODE LIKE '01.150.03%' AND
                ST.PRODUCT_ID = #attributes.product_id#
    </cfquery>
</cfif>
<cfif isdefined('x_department_id_list') and len(x_department_id_list)>
	<cfset attributes.department_id = x_department_id_list>
</cfif>
<cfset attributes.new_dsn3 = new_dsn3>
<cfset attributes.new_dsn2_alias = new_dsn2>
<cfparam name="attributes.keyword" default="">
<cfset x_select_order_yontem=1>
<cfinclude template="/AddOns/ezgi/e_planing/query/get_ezgi_stock_last_location_karma_koli.cfm">
<cfset stock_true = 1>
<cfif GET_EZGI_STOCK_LAST_LOCATION_KARMA_KOLI.recordcount>
	<cfset real_stock = GET_EZGI_STOCK_LAST_LOCATION_KARMA_KOLI.SALEABLE_STOCK-GET_EZGI_STOCK_LAST_LOCATION_KARMA_KOLI.SHIP_INTERNAL_STOCK>
<cfelse>
	<cfset real_stock = 0>
</cfif> 
<cfif real_stock lte 2> <!---Eğer Stok 3 ten küçükse Üretim Planına Bak--->
	<cfset stock_true = 0>
	<cfquery name="get_production_plan" datasource="#dsn3#">
    	SELECT 
        	TOP (1) EIP.MASTER_PLAN_FINISH_DATE
		FROM     
        	#new_dsn3#.EZGI_IFLOW_PRODUCTION_ORDERS AS EI INNER JOIN
            #new_dsn3#.EZGI_IFLOW_MASTER_PLAN AS EIP ON EI.MASTER_PLAN_ID = EIP.MASTER_PLAN_ID
		WHERE  	
        	EI.STOCK_ID = #attributes.stock_id# AND
            ISNULL(EIP.MASTER_PLAN_STATUS,1) = 1
		ORDER BY 
        	EIP.MASTER_PLAN_FINISH_DATE DESC
    </cfquery>
</cfif>

<style>
	/* Modern Ürün Detay Popup Stilleri */
	.product {
		position: relative;
		width: 100%;
		height: 100%;
		border-radius: 16px;
		overflow: hidden;
		background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
		box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
		transition: all 0.3s ease;
	}
	.product:hover {
		box-shadow: 0 6px 30px rgba(0, 0, 0, 0.15);
	}
	.slider {
		position: relative;
		overflow: hidden;
		width: 100%;
		height: 100%;
		background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
		border-radius: 16px;
		display: flex;
		align-items: center;
		justify-content: center;
	}
	.slider img {
		max-height: calc(100% - 40px);
		max-width: calc(100% - 40px);
		width: auto;
		height: auto;
		object-fit: contain;
		position: absolute;
		left: 50%;
		top: 50%;
		transform: translate(-50%, -50%);
		opacity: 0;
		transition: opacity 0.5s ease-in-out, transform 0.5s ease-in-out;
		filter: drop-shadow(0 4px 12px rgba(0, 0, 0, 0.15));
	}
	/* Tüm Sekmeler İçin Sabit Yükseklik */
	.tab-content-fixed-height {
		overflow-y: auto;
		overflow-x: hidden;
		padding: 20px;
		box-sizing: border-box;
		position: relative;
	}
	.tab-content-fixed-height .product {
		height: 100%;
		min-height: 100%;
		max-height: 100%;
	}
	.tab-content-fixed-height .slider {
		height: 100%;
		min-height: 100%;
		max-height: 100%;
	}
	.slider img.active {
		opacity: 1;
		transform: translate(-50%, -50%) scale(1);
	}
	.prevBtn,
	.nextBtn {
		position: absolute;
		top: 50%;
		transform: translateY(-50%);
		width: 48px;
		height: 48px;
		font-size: 18px;
		font-weight: 600;
		color: #fff;
		background: linear-gradient(135deg, #5f8ee1 0%, #44b6ae 100%);
		border: 2px solid rgba(255, 255, 255, 0.3);
		outline: none;
		padding: 0;
		cursor: pointer;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow: 0 4px 15px rgba(68, 182, 174, 0.4);
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		z-index: 10;
		opacity: 0;
		backdrop-filter: blur(10px);
	}
	.product:hover .prevBtn,
	.product:hover .nextBtn {
		opacity: 1;
	}
	.prevBtn:hover,
	.nextBtn:hover {
		background: linear-gradient(135deg, #4a7bc8 0%, #3a9d96 100%);
		box-shadow: 0 6px 20px rgba(68, 182, 174, 0.5);
		transform: translateY(-50%) scale(1.15);
		border-color: rgba(255, 255, 255, 0.5);
	}
	.prevBtn:active,
	.nextBtn:active {
		transform: translateY(-50%) scale(0.95);
	}
	.prevBtn {
		left: 12px;
	}
	.nextBtn {
		right: 12px;
	}
	.prevBtn i,
	.nextBtn i {
		font-size: 18px;
		line-height: 1;
	}
	/* Tab Navigation Modernizasyonu */
	.tabNav {
		background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
		border-radius: 12px 12px 0 0;
		padding: 8px 8px 0 8px;
		margin-bottom: 0;
		border-bottom: 2px solid #e9ecef;
	}
	.tabNav li {
		transition: all 0.3s ease;
		margin-right: 4px;
		border-radius: 8px 8px 0 0;
	}
	.tabNav li a {
		padding: 12px 20px;
		font-weight: 600;
		color: #495057;
		transition: all 0.3s ease;
		border-radius: 8px 8px 0 0;
		display: block;
	}
	.tabNav li:hover a {
		background-color: rgba(95, 142, 225, 0.1);
		color: #5f8ee1;
	}
	.tabNav li.active {
		background: linear-gradient(135deg, #5f8ee1 0%, #44b6ae 100%);
		box-shadow: 0 -2px 8px rgba(68, 182, 174, 0.3);
	}
	.tabNav li.active a {
		color: #fff;
		background: transparent;
	}
	.tabNav li.active:hover a {
		color: #fff;
		background: transparent;
	}
	/* Tab Content Modernizasyonu */
	.input-group {
		background: #fff;
		border-radius: 0 0 12px 12px;
		padding: 20px;
		box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
	}
	.addBasket button:hover{
		background: linear-gradient(135deg, #4a7bc8 0%, #3a9d96 100%) !important;
    	transition: all 0.3s ease !important;
		transform: translateY(-2px);
		box-shadow: 0 4px 12px rgba(68, 182, 174, 0.4);
	}
	/* Ürün Bilgileri Modernizasyonu */
	.product-info-modern {
		padding: 16px;
		background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
		border-radius: 12px;
		box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
		text-align: center;
		margin-top: 16px;
	}
	.product-title-section {
		margin-bottom: 12px;
		padding-bottom: 12px;
		border-bottom: 2px solid #e9ecef;
	}
	.product-title {
		font-size: 18px;
		font-weight: 700;
		color: #212529;
		margin: 0 0 6px 0;
		line-height: 1.3;
		text-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
	}
	.product-code {
		font-size: 12px;
		color: #6c757d;
		font-weight: 500;
		letter-spacing: 0.5px;
	}
	.product-price-section {
		margin-bottom: 10px;
	}
	.product-price {
		font-size: 20px;
		font-weight: 700;
		color: #5f8ee1;
		text-shadow: 0 2px 4px rgba(95, 142, 225, 0.2);
		display: inline-block;
		padding: 6px 12px;
		background: linear-gradient(135deg, rgba(95, 142, 225, 0.1) 0%, rgba(68, 182, 174, 0.1) 100%);
		border-radius: 8px;
	}
	.product-special-price-section {
		margin-top: 6px;
	}
	.product-special-price {
		font-size: 12px;
		color: #6c757d;
		font-style: italic;
	}
	/* Sepete Ekle Butonu Modernizasyonu */
	.modern-add-basket-link {
		display: inline-block;
		text-decoration: none;
		width: 100%;
		max-width: 300px;
	}
	.modern-add-basket-btn {
		width: 100%;
		padding: 10px 20px;
		font-size: 14px;
		font-weight: 600;
		border-radius: 12px;
		border: none;
		background: linear-gradient(135deg, #5f8ee1 0%, #44b6ae 100%);
		color: #fff;
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 8px;
		box-shadow: 0 4px 15px rgba(68, 182, 174, 0.4);
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		margin: 0 auto;
	}
	.modern-add-basket-btn i {
		font-size: 16px;
		transition: transform 0.3s ease;
	}
	.modern-add-basket-btn:hover {
		background: linear-gradient(135deg, #4a7bc8 0%, #3a9d96 100%);
		box-shadow: 0 6px 20px rgba(68, 182, 174, 0.5);
		transform: translateY(-2px);
	}
	.modern-add-basket-btn:hover i {
		transform: scale(1.2) rotate(-5deg);
	}
	.modern-add-basket-btn:active {
		transform: translateY(0);
		box-shadow: 0 3px 12px rgba(68, 182, 174, 0.4);
	}
	.modern-add-basket-btn.ssh-btn {
		background: linear-gradient(135deg, #ff9800 0%, #f57c00 100%);
		box-shadow: 0 4px 15px rgba(255, 152, 0, 0.4);
	}
	.modern-add-basket-btn.ssh-btn:hover {
		background: linear-gradient(135deg, #f57c00 0%, #e65100 100%);
		box-shadow: 0 6px 20px rgba(255, 152, 0, 0.5);
	}
	/* Responsive */
	@media screen and (max-width: 768px) {
		.prevBtn,
		.nextBtn {
			width: 40px;
			height: 40px;
			font-size: 16px;
		}
		.prevBtn {
			left: 8px;
		}
		.nextBtn {
			right: 8px;
		}
		.tab-content-fixed-height {
			padding: 15px;
		}
		.slider img {
			max-height: calc(100% - 30px);
			max-width: calc(100% - 30px);
		}
		.tabNav li a {
			padding: 10px 12px;
			font-size: 13px;
		}
		.product-title {
			font-size: 16px;
		}
		.product-code {
			font-size: 11px;
		}
		.product-price {
			font-size: 18px;
			padding: 5px 10px;
		}
		.product-special-price {
			font-size: 11px;
		}
		.modern-add-basket-btn {
			padding: 8px 16px;
			font-size: 13px;
		}
		.modern-add-basket-btn i {
			font-size: 14px;
		}
	}
</style>
<cfif attributes.is_kdv eq 1 and get_product_info.TAX gt 0>
	<cfset net_fiyat = round(attributes.net_price/(100+get_product_info.TAX)*10000)/100>
<cfelse>
	<cfset net_fiyat = attributes.net_price>
</cfif>

<div id="basket_main_div">
    <div class="row">
        <div class="col col-12 uniqueRow">
            <cf_box title="Ürün Detayı" scroll="0" collapsable="0" resize="0" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
             	<div id="tab-container" class="tabStandart margin-top-5">
                 	<div id="tab-head">
                     	<ul class="tabNav">
							<cfif x_relation_type eq 1>
                            	<li class="active" id="iliskili_"><a style="cursor:pointer" onclick="kapat(8);"><cfoutput>İlişkili Ürünler</cfoutput></a></li>
                                <li class="" id="foto_"><a style="cursor:pointer" onclick="kapat(1);"><cfoutput>Görünüm</cfoutput></a></li>
                            <cfelse>
                            	<li class="active" id="foto_"><a style="cursor:pointer" onclick="kapat(1);"><cfoutput>Görünüm</cfoutput></a></li>
                            </cfif>
                        	
                        	<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
                            	<li class="" id="karma_"><a style="cursor:pointer" onclick="kapat(5);"><cfoutput>Takım İçeriği</cfoutput></a></li>
                            </cfif>
                         	<li class="" id="genel_"><a style="cursor:pointer" onclick="kapat(2);"><cfoutput>Açıklamalar</cfoutput></a></li>
                         	<li class="" id="teknik_"><a style="cursor:pointer" onclick="kapat(3);"><cfoutput>Teknik Bilgi</cfoutput></a></li>
                            <li class="" id="stoklar_"><a style="cursor:pointer" onclick="kapat(6);"><cfoutput>Bildirim</cfoutput></a></li>
                            <li class="" id="belge_"><a style="cursor:pointer" onclick="kapat(4);"><cfoutput>Belgeler</cfoutput></a></li>
                            <cfif x_service_type eq 1 and attributes.x_ssh eq 1>
                            	<li class="" id="ssh_"><a style="cursor:pointer" onclick="kapat(7);"><cfoutput>SSH</cfoutput></a></li>
                            </cfif>
                            
                     	</ul>
                 	</div>
                    
                    <cfif x_relation_type eq 1>
                    	<cfquery name="get_main_relation_info" datasource="#dsn3#">
                        	SELECT 
                            	S.STOCK_ID, 
                                S.PRODUCT_NAME, 
                                S.PRODUCT_CODE,
                                S.PRODUCT_ID,
                                TBL.PATH,
                                <cfif attributes.is_kdv eq 1>
                                	ISNULL(TBL2.PRICE_KDV,0) AS PRICE,
                                <cfelse>
                                	ISNULL(TBL2.PRICE,0) AS PRICE,
                                </cfif>
                                ISNULL(TBL2.MONEY,'#session.ep.money#') AS MONEY
							FROM     
                            	STOCKS AS S LEFT OUTER JOIN
                                (
                                    SELECT 
                                        PRODUCT_ID, 
                                        PATH
                                    FROM      
                                        #dsn1_alias#.PRODUCT_IMAGES
                                    WHERE   
                                        PRODUCT_IMAGEID IN
                                                            (
                                                                SELECT 
                                                                    MIN(PRODUCT_IMAGEID) AS PRODUCT_IMAGEID
                                                                FROM      
                                                                    #dsn1_alias#.PRODUCT_IMAGES AS PRODUCT_IMAGES_1
                                                                WHERE   
                                                                    IMAGE_SIZE = 2
                                                                GROUP BY 
                                                                    PRODUCT_ID
                                                            )
                                ) AS TBL ON S.PRODUCT_ID = TBL.PRODUCT_ID LEFT OUTER JOIN
                                (
                                	SELECT 
                                    	PR.PRODUCT_ID, 
                                        PR.PRICE, 
                                        PR.PRICE_KDV, 
                                        PR.MONEY
									FROM     
                                    	PRICE_CAT AS PC INNER JOIN
                  						PRICE AS PR ON PC.PRICE_CATID = PR.PRICE_CATID INNER JOIN 
                                        (
                                            SELECT 
                                                PRODUCT_ID,
                                                MAX(STARTDATE) AS MAX_STARTDATE
                                            FROM 
                                            	PRICE
                                            WHERE 
                                            	FINISHDATE IS NULL
                                            GROUP BY 
                                            	PRODUCT_ID
                                        ) AS MAXP ON PR.PRODUCT_ID = MAXP.PRODUCT_ID AND PR.STARTDATE = MAXP.MAX_STARTDATE
									WHERE  
                                    	PC.PRICE_CATID = #attributes.price_cat_id# AND
                                        PR.FINISHDATE IS NULL
                                
                                ) AS TBL2 ON TBL2.PRODUCT_ID = S.PRODUCT_ID
							WHERE   
                            	S.STOCK_ID = #attributes.stock_id# 
                      	</cfquery>
                    	<cfquery name="get_relation_info" datasource="#dsn3#">
                        	SELECT DISTINCT
                            	S.STOCK_ID, 
                                S.PRODUCT_NAME, 
                                S.PRODUCT_CODE,
                                S.PRODUCT_ID,
                                TBL.PATH,
                                RP.PRODUCT_VAR,
                                <cfif attributes.is_kdv eq 1>
                                	ISNULL(TBL2.PRICE_KDV,0) AS PRICE,
                                <cfelse>
                                	ISNULL(TBL2.PRICE,0) AS PRICE,
                                </cfif>
                                ISNULL(TBL2.MONEY,'#session.ep.money#') AS MONEY
							FROM     
                            	RELATED_PRODUCT AS RP INNER JOIN
                  				STOCKS AS S ON RP.RELATED_PRODUCT_ID = S.PRODUCT_ID LEFT OUTER JOIN
                                (
                                    SELECT 
                                        PRODUCT_ID, 
                                        PATH
                                    FROM      
                                        #dsn1_alias#.PRODUCT_IMAGES
                                    WHERE   
                                        PRODUCT_IMAGEID IN
                                                            (
                                                                SELECT 
                                                                    MIN(PRODUCT_IMAGEID) AS PRODUCT_IMAGEID
                                                                FROM      
                                                                    #dsn1_alias#.PRODUCT_IMAGES AS PRODUCT_IMAGES_1
                                                                WHERE   
                                                                    IMAGE_SIZE = 0
                                                                GROUP BY 
                                                                    PRODUCT_ID
                                                            )
                                ) AS TBL ON S.PRODUCT_ID = TBL.PRODUCT_ID LEFT OUTER JOIN
                                (
                                	SELECT 
                                    	PR.PRODUCT_ID, 
                                        PR.PRICE, 
                                        PR.PRICE_KDV, 
                                        PR.MONEY
									FROM     
                                    	PRICE_CAT AS PC INNER JOIN
                  						PRICE AS PR ON PC.PRICE_CATID = PR.PRICE_CATID INNER JOIN 
                                        (
                                            SELECT 
                                                PRODUCT_ID,
                                                MAX(STARTDATE) AS MAX_STARTDATE
                                            FROM 
                                            	PRICE
                                            WHERE 
                                            	FINISHDATE IS NULL
                                            GROUP BY 
                                            	PRODUCT_ID
                                        ) AS MAXP ON PR.PRODUCT_ID = MAXP.PRODUCT_ID AND PR.STARTDATE = MAXP.MAX_STARTDATE
									WHERE  
                                    	PC.PRICE_CATID = #attributes.price_cat_id# AND
                                        PR.FINISHDATE IS NULL
                                
                                ) AS TBL2 ON TBL2.PRODUCT_ID = S.PRODUCT_ID
							WHERE  
                            	RP.PRODUCT_ID = #attributes.product_id# AND 
                                ISNULL(RP.IS_TYPE,0) = 1 AND 
                                ISNULL(S.IS_PROTOTYPE,0) = 0 AND 
                                ISNULL(S.PRODUCT_STATUS,0) = 1 
                       		ORDER BY
                                PRODUCT_NAME
                        </cfquery>
                        <cfquery name="get_relation_info_group" dbtype="query">
                        	SELECT
                            	PRODUCT_VAR
                            FROM
                            	get_relation_info
                           	GROUP BY
                            	PRODUCT_VAR
                        </cfquery>
                        <cfquery name="get_relation_info_1" datasource="#dsn3#">
                        	SELECT DISTINCT
                            	S.STOCK_ID, 
                                S.PRODUCT_NAME, 
                                S.PRODUCT_CODE,
                                S.PRODUCT_ID,
                                TBL.PATH,
                                <cfif attributes.is_kdv eq 1>
                                	ISNULL(TBL2.PRICE_KDV,0) AS PRICE,
                                <cfelse>
                                	ISNULL(TBL2.PRICE,0) AS PRICE,
                                </cfif>
                                ISNULL(TBL2.MONEY,'#session.ep.money#') AS MONEY
							FROM     
                            	RELATED_PRODUCT AS RP INNER JOIN
                  				STOCKS AS S ON RP.RELATED_PRODUCT_ID = S.PRODUCT_ID LEFT OUTER JOIN
                                (
                                    SELECT 
                                        PRODUCT_ID, 
                                        PATH
                                    FROM      
                                        #dsn1_alias#.PRODUCT_IMAGES
                                    WHERE   
                                        PRODUCT_IMAGEID IN
                                                            (
                                                                SELECT 
                                                                    MIN(PRODUCT_IMAGEID) AS PRODUCT_IMAGEID
                                                                FROM      
                                                                    #dsn1_alias#.PRODUCT_IMAGES AS PRODUCT_IMAGES_1
                                                                WHERE   
                                                                    IMAGE_SIZE = 0
                                                                GROUP BY 
                                                                    PRODUCT_ID
                                                            )
                                ) AS TBL ON S.PRODUCT_ID = TBL.PRODUCT_ID LEFT OUTER JOIN
                                (
                                	SELECT 
                                    	PR.PRODUCT_ID, 
                                        PR.PRICE, 
                                        PR.PRICE_KDV, 
                                        PR.MONEY
									FROM     
                                    	PRICE_CAT AS PC INNER JOIN
                  						PRICE AS PR ON PC.PRICE_CATID = PR.PRICE_CATID INNER JOIN 
                                        (
                                            SELECT 
                                                PRODUCT_ID,
                                                MAX(STARTDATE) AS MAX_STARTDATE
                                            FROM 
                                            	PRICE
                                            WHERE 
                                            	FINISHDATE IS NULL
                                            GROUP BY 
                                            	PRODUCT_ID
                                        ) AS MAXP ON PR.PRODUCT_ID = MAXP.PRODUCT_ID AND PR.STARTDATE = MAXP.MAX_STARTDATE
									WHERE  
                                    	PC.PRICE_CATID = #attributes.price_cat_id# AND
                                        PR.FINISHDATE IS NULL
                                ) AS TBL2 ON TBL2.PRODUCT_ID = S.PRODUCT_ID
							WHERE  
                            	RP.PRODUCT_ID = #attributes.product_id# AND 
                                ISNULL(RP.IS_TYPE,0) = 0 AND 
                                ISNULL(S.IS_PROTOTYPE,0) = 0 AND 
                                ISNULL(S.PRODUCT_STATUS,0) = 1
                       		ORDER BY
                                PRODUCT_NAME
                        </cfquery>
                   		<div id="iliskili" class="input-group tab-content-fixed-height" style="width:100%; height:<cfoutput>#get_connect_defaults.IMAGE_MEDIUM_HEIGHT#</cfoutput>px; text-align:center; vertical-align:middle">
                       		<cf_box>
                            	<cf_grid_list sort="1">
                               		<thead>
                                            <tr>
                                                <th width="80"></th>
                                                <th><cf_get_lang dictionary_id='57564.Ürünler'></th>
                                                <th width="70"><cf_get_lang dictionary_id='57638.Birim Fiyat'></th>
                                                <th width="70"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                                <th width="40"></th>
                                            </tr>
                                	</thead>
                               		<tbody>
                                    	<cfif get_main_relation_info.recordcount>
                                     		<cfset b_stock_id_list_main = ValueList(get_main_relation_info.STOCK_ID)>
                                     		<cfoutput query="get_main_relation_info">
                                                	<tr height="40" id="a_frm_row#currentrow#" title="#PRODUCT_NAME#" style="background-color:snow">
                                                        <td nowrap style="text-align:center; cursor:pointer" onClick="windowopen('#request.self#?fuseaction=sales.popup_dsp_ezgi_product_image&pid=#get_main_relation_info.product_id#','wide');">
                                                            <cfif len(get_main_relation_info.path)>
                                                                <img  alt="product" src="/documents/product/#get_main_relation_info.path#" style="height:60px;"/>
                                                            <cfelse>
                                                                <img  alt="product" src="/images/production/no-image.png" style="height:40px;"/>
                                                            </cfif>
                                                        </td>
                                                        <td style="text-align:left;">#PRODUCT_NAME#</td>
                                                        <td style="text-align:right;">#TlFormat(PRICE)# #MONEY#</td>
                                                        <td style="text-align:right;">
                                                        	 <select name="b_connect_amount_a_#STOCK_ID#" id="b_connect_amount_a_#STOCK_ID#" style="font-size:14px; font-weight:bold; height:100%; width:100%; background-color:mintcream; border:none" onChange="b_connnect_change_amount(this.value)">
                                                                <option value="1" >1</option>
                                                                <option value="2" >2</option>
                                                                <option value="3" >3</option>
                                                                <option value="4" >4</option>
                                                                <option value="5" >5</option>
                                                                <option value="6" >6</option>
                                                                <option value="7" >7</option>
                                                                <option value="8" >8</option>
                                                                <option value="9" >9</option>
                                                            </select>
                                                        </td>
                                                        <td style="text-align:center;">
                                                            <input type="checkbox" name="b_select_production_a" value="#STOCK_ID#" onclick="this.checked=!this.checked;" checked>
                                                        </td>
                                                    </tr>
                                       		</cfoutput>
                                     	</cfif>
                                     	<cfif get_relation_info_group.recordcount>
                                        	<cfset renk = 'white'>
                                        	<cfoutput query="get_relation_info_group">
                                            	<cfquery name="get_relation_info_detail" dbtype="query">
                                                	SELECT * FROM get_relation_info WHERE PRODUCT_VAR = #get_relation_info_group.PRODUCT_VAR#
                                                </cfquery>
                                                <cfset 'b_stock_id_list_zorunlu_#get_relation_info_group.PRODUCT_VAR#' = ValueList(get_relation_info_detail.STOCK_ID)>
                                                <cfif renk eq 'white'>
                                                	<cfset renk = 'whitesmoke'>
                                                <cfelse>
                                                	<cfset renk = 'white'>
                                                </cfif>
                                                <cfloop query="get_relation_info_detail">
                                                    <tr height="40" id="b_frm_row#currentrow+1#" title="#PRODUCT_NAME#" style="background-color:#renk#">
                                                        <td nowrap style="text-align:center; cursor:pointer" onClick="windowopen('#request.self#?fuseaction=sales.popup_dsp_ezgi_product_image&pid=#get_relation_info_detail.product_id#','wide');">
                                                            <cfif len(get_relation_info_detail.path)>
                                                                <img  alt="product" src="/documents/product/#get_relation_info_detail.path#" style="height:60px;"/>
                                                            <cfelse>
                                                                <img  alt="product" src="/images/production/no-image.png" style="height:40px;"/>
                                                            </cfif>
                                                        </td>
                                                        <td style="text-align:left;">#PRODUCT_NAME#</td>
                                                        <td style="text-align:right;">#TlFormat(PRICE)# #MONEY#</td>
                                                        <td style="text-align:right;">
                                                            <input type="text" name="b_connect_amount_#get_relation_info_group.PRODUCT_VAR#_#get_relation_info_detail.STOCK_ID#" id="b_connect_amount_#get_relation_info_group.PRODUCT_VAR#_#get_relation_info_detail.STOCK_ID#" style="font-size:14px; font-weight:bold; height:100%; width:100%; background-color:mintcream; border:none" value="1" readonly="readonly">
                                                        </td>
                                                        <td style="text-align:center;">
                                                            <input type="radio" name="b_select_production_#get_relation_info_group.PRODUCT_VAR#" value="#get_relation_info_detail.STOCK_ID#" <cfif currentrow eq 1>checked</cfif>>
                                                        </td>
                                                    </tr>
                                          		</cfloop>
                                         	</cfoutput>
                                  		</cfif>
                                    	<cfif get_relation_info_1.recordcount>
                                            	<cfoutput query="get_relation_info_1">
                                            		<cfset b_stock_id_list = ListAppend(b_stock_id_list, get_relation_info_1.STOCK_ID)> 
                                                </cfoutput> 
                                                <cfif get_relation_info.recordcount>
                                                	<cfset row_ = 1+get_relation_info.recordcount>
                                                <cfelse>
                                                	<cfset row_ = 1>
                                                </cfif> 
												<cfoutput query="get_relation_info_1">
                                                    <tr height="40" id="b_frm_row#currentrow+row_#" title="#PRODUCT_NAME#" style="background-color:azure">
                                                        <td nowrap style="text-align:center; cursor:pointer" onClick="windowopen('#request.self#?fuseaction=sales.popup_dsp_ezgi_product_image&pid=#get_relation_info_1.product_id#','wide');">
                                                            <cfif len(get_relation_info_1.path)>
                                                                <img  alt="product" src="/documents/product/#get_relation_info_1.path#" style="height:60px;"/>
                                                            <cfelse>
                                                                <img  alt="product" src="/images/production/no-image.png" style="height:40px;"/>
                                                            </cfif>
                                                        </td>
                                                        <td style="text-align:left;">#PRODUCT_NAME#</td>
                                                        <td style="text-align:right;">#TlFormat(PRICE)# #MONEY#</td>
                                                        <td style="text-align:right;">
                                                            <input type="text" name="b_connect_amount_b_#STOCK_ID#" id="b_connect_amount_b_#STOCK_ID#" style="font-size:14px; font-weight:bold; height:100%; width:100%; background-color:mintcream; border:none" value="1">
                                                        </td>
                                                        <td style="text-align:center;">
                                                            <input type="checkbox" name="b_select_production_b" value="#STOCK_ID#">
                                                        </td>
                                                    </tr>
                                                </cfoutput>
                                    	</cfif>
                                  	</tbody>
                             	</cf_grid_list>  
                         	</cf_box>
                     	</div>
                    </cfif>
                	<div id="foto" class="input-group tab-content-fixed-height" style="display: flex;justify-content: center;width: 100%; height:<cfoutput>#get_connect_defaults.IMAGE_MEDIUM_HEIGHT#</cfoutput>px; text-align: center; vertical-align: middle;; <cfif x_relation_type eq 1>display:none</cfif>">
							<div class="product">
								<div class="slider">
									<cfoutput>
										<cfif get_images.recordcount and len(get_images.path)>
											<cfloop query="get_images">
												<img  alt="product" src="/documents/product/#get_images.path#"/>
											</cfloop>
										<cfelse>
											<img  alt="product" src="/images/production/no-image.png" style="width:60%;height:#get_connect_defaults.IMAGE_MEDIUM_HEIGHT#px;"/>
										</cfif>	
									</cfoutput>
								</div>
								<button class="prevBtn" aria-label="Önceki resim">
									<i class="fa fa-chevron-left"></i>
								</button>
								<button class="nextBtn" aria-label="Sonraki resim">
									<i class="fa fa-chevron-right"></i>
								</button>
							</div>
               		</div>
                  	<div id="genel" class="input-group tab-content-fixed-height" style="width:100%;height:<cfoutput>#get_connect_defaults.IMAGE_MEDIUM_HEIGHT#</cfoutput>px; text-align:center; vertical-align:middle; display:none">
                    	<cf_box>
                       		<div style="text-align:left; font-size:14px;width:100%; height:100%">
                            	<cfif x_detail_type eq 1>
									<cfif get_product_content.recordcount>
                                        <cfoutput query="get_product_content">
                                            <div style="text-align:left;width:100%;">
                                                #get_product_content.CONT_HEAD#
                                            </div>
                                            <br>
                                            <div style="text-align:left;width:100%;">
                                                #get_product_content.CONT_BODY#
                                            </div>
                                            <br>
                                        </cfoutput>
                                  	</cfif>
                                <cfelse>
                                	<cfoutput>
                                        <div style="text-align:left;width:100%;">
                                            #get_product_info.PRODUCT_NAME#
                                        </div>
                                        <br>
                                        <div style="text-align:left;width:100%;">
                                            #get_product_info.PRODUCT_DETAIL_WATALOGY#
                                        </div>
                                        <br>
                                    </cfoutput>
                                </cfif>
                          	</div>
                    	</cf_box>
                 	</div>
                	<div id="teknik" class="input-group tab-content-fixed-height" style="width:100%; height:<cfoutput>#get_connect_defaults.IMAGE_MEDIUM_HEIGHT#</cfoutput>px; text-align:center; vertical-align:middle; display:none">
                    	<cf_box>
							<cf_box_search>
                            	<div class="col col-3"></div>
                            	<div class="col col-6">
                                	<div class="col col-12">
                                        <div class="col col-3" style="text-align:left">
                                            <label><b>Ölçüler (cm)</b></label>
                                        </div>
                                        <div class="col col-3">
                                            <div class="form-group">
                                                <input type="text" style="text-align:center" value="<cfoutput>#olcu_A#</cfoutput>" name="olcu1">
                                            </div>
                                        </div>
                                        <div class="col col-3">
                                            <div class="form-group">
                                                <input type="text" style="text-align:center" value="<cfoutput>#olcu_B#</cfoutput>" name="olcu2">
                                            </div>
                                        </div>
                                        <div class="col col-3">
                                            <div class="form-group">
                                                <input type="text" style="text-align:center" value="<cfoutput>#olcu_C#</cfoutput>" name="olcu3">
                                            </div>
                                        </div>
                                  	</div>
                                    <div class="col col-12">
                                        <div class="col col-3" style="text-align:left">
                                            <label><b>Hacim (m3)</b></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group">
                                            	<cfif GET_P_UNIT.recordcount AND GET_P_UNIT.VOLUME gt 0>
                                               		<input type="text" style="text-align:center" value="<cfoutput>#TlFormat(GET_P_UNIT.VOLUME/1000000,2)#</cfoutput>" name="hacim"> 
                                                <cfelse>
                                                	<input type="text" style="text-align:center" value="<cfoutput>#TlFormat(0,2)#</cfoutput>" name="hacim">
                                                </cfif>
                                                
                                            </div>
                                        </div>
                                  	</div>
                                    <div class="col col-12">
                                        <div class="col col-3" style="text-align:left">
                                            <label><b>Ağırlık (KG)</b></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group">
                                            	<cfif GET_P_UNIT.recordcount>
                                               		<input type="text" style="text-align:center" value="<cfoutput>#TlFormat(GET_P_UNIT.WEIGHT,2)#</cfoutput>" name="hacim"> 
                                                <cfelse>
                                                	<input type="text" style="text-align:center" value="<cfoutput>#TlFormat(0,2)#</cfoutput>" name="hacim">
                                                </cfif>
                                                
                                            </div>
                                        </div>
                                  	</div>
                                </div>
                                <div class="col col-3"></div>
                          	</cf_box_search>
                    	</cf_box>
                    	<cfif len(x_alternative_code)>	
                        <cf_box>
                        	<div class="col col-3"></div>
                         	<div class="col col-6">
                           		<div class="col col-12">
                                 	<cf_grid_list>
                                            <thead>
                                                <tr> 
                                                    <th style="width:40px">Toplam</th>
                                                    <th>Alternatif Soru</th>
                                                    <th style="width:40px">Miktar</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            	<cfoutput>
                                                        <cfquery name="GET_PRODUCT_DETAIL" dbtype="query">
                                    
                                                            SELECT
                                                                AMOUNT, 
                                                                TREE_NAME, 
                                                                QUESTION_ID, 
                                                                QUESTION_NAME	
                                                            FROM
                                                                get_product_tree
                                                        </cfquery>
                                                        <cfquery name="get_toplam" dbtype="query">
                                                            SELECT
                                                                SUM(AMOUNT) AMOUNT
                                                            FROM
                                                                GET_PRODUCT_DETAIL
                                                        </cfquery>
                                                        <cfset row_num = GET_PRODUCT_DETAIL.RECORDCOUNT+1>
                                                        <tr> 
                                                            <td rowspan="#row_num#" style="text-align:right">#TlFormat(get_toplam.AMOUNT,4)#</td>
                                                        </tr>
                                             			<cfif GET_PRODUCT_DETAIL.recordcount>
                                                            <cfloop query="GET_PRODUCT_DETAIL">
                                                                <tr>
                                                                    <td>#QUESTION_NAME#</td>
                                                                    <td style="text-align:right">#TlFormat(AMOUNT,4)#</td>
                                                                </tr>
                                                            </cfloop>
                                                        </cfif>
                                          		</cfoutput>
												
                                            </tbody>
                               		</cf_grid_list>
                             	</div>
                          	</div>
                            <div class="col col-3"></div>
                   		</cf_box>
                        </cfif>
                    </div>
                    <div id="stoklar" class="input-group tab-content-fixed-height" style="width:100%; height:<cfoutput>#get_connect_defaults.IMAGE_MEDIUM_HEIGHT#</cfoutput>px; text-align:center; vertical-align:middle; display:none">
                    	<cfif x_price_cat_id gt 0>
                        	<cfquery name="GET_PRICE" datasource="#DSN3#">
                                SELECT 
                                    PRICE_ID,
                                    PRODUCT_ID,
                                    PRICE, 
                                    PRICE_KDV, 
                                    IS_KDV, 
                                    MONEY
                                FROM     
                                    PRICE
                                WHERE  
                                    FINISHDATE IS NULL AND 
                                    PRODUCT_ID = #attributes.product_id# AND 
                                    PRICE_CATID = #x_price_cat_id#
                            </cfquery>
                            <cfif len(get_connect.project_id)>
                                <cfquery name="get_project" datasource="#dsn#">
                                	SELECT 
                                    	PP.PROJECT_HEAD, 
                                        PD.DISCOUNT_4, 
                                        PD.DISCOUNT_5
									FROM     
                                    	PRO_PROJECTS AS PP LEFT OUTER JOIN
                  						#dsn3_alias#.PROJECT_DISCOUNTS AS PD ON PP.PROJECT_ID = PD.PROJECT_ID
									WHERE  
                                    	PP.PROJECT_ID = #get_connect.project_id#
                                </cfquery>
                            </cfif>
                            <cf_box>
                                <div style="text-align:left; font-size:14px; width:100%; height:100%">
                                    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
                                        <cf_box title="Bayi Fiyatı">
                                            <cf_grid_list>
                                                <thead>
                                                    <tr> 
                                                        <th>Liste Fiyatı</th>
                                                        <th>Uygulanan Kampanya</th>
                                                        <th>İskonto</th>
                                                        <th>Net Fiyat</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <cfoutput>
                                                        <tr>
                                                            <td style="text-align:right">#TlFormat(GET_PRICE.PRICE)# #GET_PRICE.MONEY#</td>
                                                            <td><cfif len(get_connect.project_id)>#get_project.PROJECT_HEAD#</cfif></td>
                                                            <td style="text-align:center">
                                                            	<cfif len(get_connect.project_id)>
																	<cfif len(get_project.DISCOUNT_4)>
                                                                    	#TlFormat(get_project.DISCOUNT_4)#
                                                                    </cfif>
                                                              	</cfif>
                                                          	</td>
                                                            <td style="text-align:right">
                                                            	<cfif len(get_connect.project_id)>
																	<cfif len(get_project.DISCOUNT_4)>
                                                                        #TlFormat(GET_PRICE.PRICE*(100-get_project.DISCOUNT_4)/100)# #GET_PRICE.MONEY#
                                                                    <cfelse>
                                                                    	#TlFormat(GET_PRICE.PRICE)# #GET_PRICE.MONEY#
                                                                    </cfif>
                                                                <cfelse>
                                                                	#TlFormat(GET_PRICE.PRICE)# #GET_PRICE.MONEY#
                                                                </cfif>
                                                            </td>
                                                        </tr>
                                                    </cfoutput>
                                                </tbody>
                                            </cf_grid_list>
                                        </cf_box>
                                    </div>
                                </div>
                            </cf_box>
                        </cfif>
                        <cfif stock_true eq 0>
                            <cf_box>
                                <div style="text-align:left; font-size:14px; width:100%; height:100%">
                                    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
                                        <cf_box title="Stok Durumu">
                                            <cf_grid_list>
                                                <thead>
                                                    <tr> 
                                                        <th>Üretim Plan Haftası</th>
                                                        <th>Termin Tarihi</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                	<cfif real_stock lte 2>
														<cfoutput query="get_production_plan">
                                                            <tr>
                                                                <td style="text-align:center">#week(DateAdd('d',5,get_production_plan.MASTER_PLAN_FINISH_DATE))# . Hafta</td>
                                                                <td style="text-align:center">#DateFormat(DateAdd('d',5,get_production_plan.MASTER_PLAN_FINISH_DATE),dateformat_style)#</td>
                                                            </tr>
                                                        </cfoutput>
                                                    </cfif>
                                                </tbody>
                                            </cf_grid_list>
                                        </cf_box>
                                    </div>
                                </div>
                            </cf_box>
                      	</cfif>
                	</div>
                    <div id="belge" class="input-group tab-content-fixed-height" style="width:100%; height:<cfoutput>#get_connect_defaults.IMAGE_MEDIUM_HEIGHT#</cfoutput>px; text-align:center; vertical-align:middle; display:none">
                    	<cf_box>
							<div style="text-align:left; font-size:14px; width:100%; height:100%">
								<!---Belgeler--->
								<cf_get_workcube_asset asset_cat_id="-3" module_id='5' action_section='PRODUCT_ID' action_id='#attributes.PRODUCT_ID#' is_add='0'>
                          	</div>
                    	</cf_box>
                	</div>
                    <div id="karma" class="input-group tab-content-fixed-height" style="width:100%; height:<cfoutput>#get_connect_defaults.IMAGE_MEDIUM_HEIGHT#</cfoutput>px; text-align:center; vertical-align:middle; display:none">
                    	<cf_box>
							 <cf_grid_list sort="1">
        						<thead>
             						<tr>
                                    	<th width="80"></th>
                                        <th><cf_get_lang dictionary_id='57564.Ürünler'></th>
                                        <th width="70"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                        <th width="70"><cf_get_lang dictionary_id='57636.Birim'></th>
                                        <th width="40">
                                        	<input type="checkbox" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="grupla(-1);">
                                        </th>
                                  	</tr>
                             	</thead>
                               	<tbody>
                                	<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
                                    	<cfoutput query="get_karma">
                                        	<tr height="40" id="frm_row#currentrow#" title="#PRODUCT_NAME#">
                                            	
                                               	<td style="text-align:center;">
                                                	<cfif len(get_karma.path)>
                                                		<img  alt="product" src="/documents/product/#get_karma.path#" style="height:60px;"/>
                                                    <cfelse>
                                                    	<img  alt="product" src="/images/production/no-image.png" style="height:40px;"/>
                                                    </cfif>
                                                </td>
                                                <td style="text-align:left;">#PRODUCT_NAME#</td>
                                                <td style="text-align:right;"><!---#TlFormat(PRODUCT_AMOUNT,2)#--->
                                                	<select name="connect_amount_#STOCK_ID#" id="connect_amount_#STOCK_ID#" style="font-size:14px; font-weight:bold; height:100%; width:100%; background-color:mintcream; border:none">
                                                        <option value="1" <cfif PRODUCT_AMOUNT eq 1>selected</cfif>>1</option>
                                                        <option value="2" <cfif PRODUCT_AMOUNT eq 2>selected</cfif>>2</option>
                                                        <option value="3" <cfif PRODUCT_AMOUNT eq 3>selected</cfif>>3</option>
                                                        <option value="4" <cfif PRODUCT_AMOUNT eq 4>selected</cfif>>4</option>
                                                        <option value="5" <cfif PRODUCT_AMOUNT eq 5>selected</cfif>>5</option>
                                                        <option value="6" <cfif PRODUCT_AMOUNT eq 6>selected</cfif>>6</option>
                                                        <option value="7" <cfif PRODUCT_AMOUNT eq 7>selected</cfif>>7</option>
                                                        <option value="8" <cfif PRODUCT_AMOUNT eq 8>selected</cfif>>8</option>
                                                        <option value="9" <cfif PRODUCT_AMOUNT eq 9>selected</cfif>>9</option>
                                                    </select>
                                                </td>
                                                <td style="text-align:left;">#UNIT#</td>
                                                <td style="text-align:center;">
                                                	<input type="checkbox" name="select_production" value="#STOCK_ID#" checked>
                                                </td>
                                       		</tr>
                                        </cfoutput>
                                    </cfif>
                                </tbody>
                         	</cf_grid_list>         
                    	</cf_box>
                 	</div>
					<cfif x_service_type eq 1>
                    	<cfquery name="get_main_info" datasource="#dsn3#">
                            SELECT 
                                EDM.DESIGN_MAIN_ROW_ID, 
                                TBL.PATH, 
                                S.STOCK_ID, 
                                S.PRODUCT_CODE, 
                                S.PRODUCT_ID, 
                                S.PRODUCT_NAME
                            FROM     
                                EZGI_DESIGN_MAIN_ROW AS EDM INNER JOIN
                                STOCKS AS S ON EDM.DESIGN_MAIN_RELATED_ID = S.STOCK_ID LEFT OUTER JOIN
                                (
                                    SELECT 
                                        PRODUCT_ID, 
                                        PATH
                                    FROM      
                                        #dsn1_alias#.PRODUCT_IMAGES
                                    WHERE   
                                        PRODUCT_IMAGEID IN
                                                            (
                                                                SELECT 
                                                                    MIN(PRODUCT_IMAGEID) AS PRODUCT_IMAGEID
                                                                FROM      
                                                                    #dsn1_alias#.PRODUCT_IMAGES AS PRODUCT_IMAGES_1
                                                                WHERE   
                                                                    IMAGE_SIZE = 2
                                                                GROUP BY 
                                                                    PRODUCT_ID
                                                            )
                                ) AS TBL ON S.PRODUCT_ID = TBL.PRODUCT_ID
                            WHERE  
                                S.STOCK_ID= #attributes.stock_id# AND 
                                S.IS_PROTOTYPE = 0
                        </cfquery>
                        <cfif get_main_info.recordcount>
                            <cfquery name="get_package_info" datasource="#dsn3#">
                                SELECT DISTINCT
                                    EDP.PACKAGE_ROW_ID,
                                    TBL.PATH, 
                                    S.STOCK_ID, 
                                    P.PRODUCT_CODE,
                                    P.PRODUCT_ID, 
                                    P.PRODUCT_NAME,
                                    EDP.PACKAGE_AMOUNT AS AMOUNT,
                               		<cfif attributes.is_kdv eq 1>
                                        ISNULL(TBL2.PRICE_KDV,0) AS PRICE,
                                    <cfelse>
                                        ISNULL(TBL2.PRICE,0) AS PRICE,
                                    </cfif>
                                    ISNULL(TBL2.MONEY,'#session.ep.money#') AS MONEY,
                                    'PK' AS NUMBER
                                FROM     
                                    #dsn1_alias#.STOCKS AS S INNER JOIN
                                    #dsn1_alias#.PRODUCT AS P ON P.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
                                    EZGI_DESIGN_PACKAGE AS EDP ON S.STOCK_ID = EDP.PACKAGE_RELATED_ID LEFT OUTER JOIN
                                    (
                                        SELECT 
                                            PRODUCT_ID, 
                                            PATH
                                        FROM      
                                            #dsn1_alias#.PRODUCT_IMAGES
                                        WHERE   
                                            PRODUCT_IMAGEID IN
                                                              (
                                                                SELECT 
                                                                    MIN(PRODUCT_IMAGEID) AS PRODUCT_IMAGEID
                                                                FROM      
                                                                    #dsn1_alias#.PRODUCT_IMAGES AS PRODUCT_IMAGES_1
                                                                WHERE   
                                                                    IMAGE_SIZE = 2
                                                                GROUP BY 
                                                                    PRODUCT_ID
                                                                )
                                    ) AS TBL ON P.PRODUCT_ID = TBL.PRODUCT_ID LEFT OUTER JOIN
                                    (
                                    	SELECT DISTINCT
                                        	PRODUCT_ID, 
                                            PRICE, 
                                            PRICE_KDV, 
                                            MONEY
										FROM     
                                        	#dsn1_alias#.PRICE_STANDART
										WHERE  
                                        	PRICESTANDART_STATUS = 1 AND 
                                            PURCHASESALES = 1
                                    ) AS TBL2 ON TBL2.PRODUCT_ID = P.PRODUCT_ID
                                WHERE  
                                    EDP.DESIGN_MAIN_ROW_ID = #get_main_info.DESIGN_MAIN_ROW_ID# AND
                                    ISNULL(P.IS_EXTRANET,0) = 1
                             </cfquery>
                            
                            <cfquery name="get_piece_all_info" datasource="#dsn3#">
                                SELECT DISTINCT
                                    EDP.PIECE_ROW_ID,
                                    TBL.PATH, 
                                    S.STOCK_ID, 
                                    P.PRODUCT_CODE, 
                                    P.PRODUCT_ID, 
                                    P.PRODUCT_NAME, 
                                    EDP.PIECE_CODE AS NUMBER, 
                                    <cfif attributes.is_kdv eq 1>
                                        ISNULL(TBL2.PRICE_KDV,0) AS PRICE,
                                    <cfelse>
                                        ISNULL(TBL2.PRICE,0) AS PRICE,
                                    </cfif>
                                    ISNULL(TBL2.MONEY,'#session.ep.money#') AS MONEY,
                                    EDP.PIECE_TYPE,
                                    EDP.PIECE_AMOUNT AS AMOUNT
                                FROM     
                                    #dsn1_alias#.STOCKS AS S INNER JOIN
                                    #dsn1_alias#.PRODUCT AS P ON P.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
                                    EZGI_DESIGN_PIECE AS EDP ON S.STOCK_ID = EDP.PIECE_RELATED_ID LEFT OUTER JOIN
                                    (
                                        SELECT 
                                            PRODUCT_ID, 
                                            PATH
                                        FROM      
                                            #dsn1_alias#.PRODUCT_IMAGES
                                        WHERE   
                                            PRODUCT_IMAGEID IN
                                                              (
                                                                SELECT 
                                                                    MIN(PRODUCT_IMAGEID) AS PRODUCT_IMAGEID
                                                                FROM      
                                                                    #dsn1_alias#.PRODUCT_IMAGES AS PRODUCT_IMAGES_1
                                                                WHERE   
                                                                    IMAGE_SIZE = 2
                                                                GROUP BY 
                                                                    PRODUCT_ID
                                                                )
                                    ) AS TBL ON P.PRODUCT_ID = TBL.PRODUCT_ID LEFT OUTER JOIN
                                    (
                                    	SELECT DISTINCT
                                        	PRODUCT_ID, 
                                            PRICE, 
                                            PRICE_KDV, 
                                            MONEY
										FROM     
                                        	#dsn1_alias#.PRICE_STANDART
										WHERE  
                                        	PRICESTANDART_STATUS = 1 AND 
                                            PURCHASESALES = 1
                                    ) AS TBL2 ON TBL2.PRODUCT_ID = P.PRODUCT_ID
                                WHERE  
                                    ISNULL(P.IS_EXTRANET,0) = 1 AND
                                    EDP.PIECE_ROW_ID IN 
                                    					(
                                                        	SELECT 
                                                            	MIN(EDP1.PIECE_ROW_ID) AS PIECE_ROW_ID
															FROM     
                                                            	 #dsn1_alias#.STOCKS AS S1 INNER JOIN
                  												EZGI_DESIGN_PIECE AS EDP1 ON S1.STOCK_ID = EDP1.PIECE_RELATED_ID
															WHERE  
                                                            	EDP1.DESIGN_MAIN_ROW_ID = #get_main_info.DESIGN_MAIN_ROW_ID#
															GROUP BY 
                                                            	EDP1.PIECE_RELATED_ID
                                                   		)
                                ORDER BY 
                                    EDP.PIECE_CODE
                            </cfquery>
                            <cfquery name="get_piece_info" dbtype="query">
                                SELECT * FROM get_piece_all_info WHERE PIECE_TYPE <> 4
                            </cfquery>
                            <cfquery name="get_piece_raw_info" dbtype="query">
                                SELECT * FROM get_piece_all_info WHERE PIECE_TYPE = 4
                            </cfquery>
                            <cfif get_piece_info.recordcount>
                                <cfset PIECE_ROW_ID_list = ValueList(get_piece_info.PIECE_ROW_ID)>
                                <cfquery name="get_material_info" datasource="#dsn3#">
                                    SELECT DISTINCT
                                    	'MLZ' AS NUMBER,
                                        EDP.PIECE_ROW_ID,
                                        TBL.PATH, 
                                        S.STOCK_ID, 
                                        P.PRODUCT_CODE,
                                        P.PRODUCT_ID, 
                                        P.PRODUCT_NAME,
                                        <cfif attributes.is_kdv eq 1>
                                            ISNULL(TBL2.PRICE_KDV,0) AS PRICE,
                                        <cfelse>
                                            ISNULL(TBL2.PRICE,0) AS PRICE,
                                        </cfif> 
                                        ISNULL(TBL2.MONEY,'#session.ep.money#') AS MONEY,
                                        EDP.AMOUNT
                                    FROM     
                                        #dsn1_alias#.STOCKS AS S INNER JOIN
                                    	#dsn1_alias#.PRODUCT AS P ON P.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
                                        EZGI_DESIGN_PIECE_ROW AS EDP ON S.STOCK_ID = EDP.STOCK_ID LEFT OUTER JOIN
                                        (
                                            SELECT 
                                                PRODUCT_ID, PATH
                                            FROM      
                                                #dsn1_alias#.PRODUCT_IMAGES
                                            WHERE   
                                                PRODUCT_IMAGEID IN
                                                                (
                                                                    SELECT 
                                                                        MIN(PRODUCT_IMAGEID) AS PRODUCT_IMAGEID
                                                                    FROM      
                                                                        #dsn1_alias#.PRODUCT_IMAGES AS PRODUCT_IMAGES_1
                                                                    WHERE   
                                                                        IMAGE_SIZE = 2
                                                                    GROUP BY 
                                                                        PRODUCT_ID
                                                                )
                                        ) AS TBL ON P.PRODUCT_ID = TBL.PRODUCT_ID  LEFT OUTER JOIN
                                        (
                                            SELECT DISTINCT
                                                PRODUCT_ID, 
                                                PRICE, 
                                                PRICE_KDV, 
                                                MONEY
                                            FROM     
                                                #dsn1_alias#.PRICE_STANDART
                                            WHERE  
                                                PRICESTANDART_STATUS = 1 AND 
                                                PURCHASESALES = 1
                                        ) AS TBL2 ON TBL2.PRODUCT_ID = P.PRODUCT_ID
                                    WHERE  
                                        EDP.PIECE_ROW_ID IN (#PIECE_ROW_ID_list#) AND
                                        EDP.PIECE_ROW_ROW_TYPE = 2  AND
                                        ISNULL(P.IS_EXTRANET,0) = 1
                                </cfquery>
                                <cfquery name="get_all_material_info_group" dbtype="query">
                                        SELECT
                                        	PRICE,
                                            MONEY,
                                        	NUMBER,
                                            PATH, 
                                            STOCK_ID, 
                                            PRODUCT_ID,
                                            PRODUCT_CODE, 
                                            PRODUCT_NAME, 
                                            AMOUNT
                                        FROM
                                            get_material_info
                                        UNION ALL
                                        SELECT 
                                        	PRICE,
                                            MONEY,
                                        	NUMBER,
                                            PATH, 
                                            STOCK_ID, 
                                            PRODUCT_ID,
                                            PRODUCT_CODE, 
                                            PRODUCT_NAME, 
                                            AMOUNT
                                        FROM
                                            get_piece_raw_info
                                </cfquery>
                                <cfif get_all_material_info_group.recordcount>
                                    <cfquery name="get_all_material_info" dbtype="query">
                                        SELECT
                                        	PRICE,
                                            MONEY,
                                        	NUMBER,
                                            PATH, 
                                            STOCK_ID, 
                                            PRODUCT_ID,
                                            PRODUCT_CODE, 
                                            PRODUCT_NAME,
                                            SUM(AMOUNT) AS AMOUNT
                                        FROM
                                            get_all_material_info_group
                                        GROUP BY
                                        	PRICE,
                                            MONEY,
                                        	NUMBER,
                                            PATH, 
                                            STOCK_ID, 
                                            PRODUCT_ID,
                                            PRODUCT_CODE, 
                                            PRODUCT_NAME	
                                    </cfquery>
                                <cfelse>
                                    <cfset get_all_material_info.recordcount=0>
                                </cfif>
                            </cfif>
                        	<cfquery name="get_all" dbtype="query">
                            	SELECT
                                	2 AS TYPE,
                                    PRICE,
                                 	MONEY,
                                 	PATH, 
                                  	STOCK_ID, 
                                    PRODUCT_ID,
                                   	PRODUCT_CODE, 
                                  	PRODUCT_NAME,
                                 	AMOUNT,
                                    NUMBER
                              	FROM
                            		get_package_info
                              	UNION ALL
                                SELECT
                                	3 AS TYPE,
                                    PRICE,
                                   	MONEY,
                                 	PATH, 
                                  	STOCK_ID, 
                                    PRODUCT_ID,
                                   	PRODUCT_CODE, 
                                  	PRODUCT_NAME,
                                 	AMOUNT,
                                    NUMBER
                              	FROM
                            		get_piece_info
                              	<cfif isdefined('get_all_material_info') and get_all_material_info.recordcount>
                                UNION ALL
                             	SELECT
                                	4 AS TYPE,
                                    PRICE,
                              		MONEY,
                                 	PATH, 
                                  	STOCK_ID, 
                                    PRODUCT_ID,
                                   	PRODUCT_CODE, 
                                  	PRODUCT_NAME,
                                 	AMOUNT,
                                    NUMBER
                              	FROM
                            		get_all_material_info	
                             	</cfif>
                            </cfquery>
                            <div id="ssh" class="input-group" style="width:100%; height:<cfoutput>#get_connect_defaults.IMAGE_MEDIUM_HEIGHT#</cfoutput>px; text-align:center; vertical-align:middle; display:none">
                                <cf_box>
                                	<cfif LEN(get_main_info.PATH)>
                                		<div style="width:100%;text-align:center; vertical-align:middle">
                                        	<cfoutput>
                                        	<img src="/documents/product/#get_main_info.PATH#" style="width:100%;"/>
                                            </cfoutput>
                                        </div>
                                	</cfif>
                                     <cf_grid_list sort="1">
                                        <thead>
                                            <tr>
                                                <th width="80"></th>
                                                <th width="40"><cf_get_lang dictionary_id='844.Parça No'></th>
                                                <th><cf_get_lang dictionary_id='57564.Ürünler'></th>
                                                <th width="70"><cf_get_lang dictionary_id='57638.Birim Fiyat'></th>
                                                <th width="70"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                                <th width="40"></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <cfif get_all.recordcount>
                                                <cfoutput query="get_all">
                                                    <tr height="40" id="a_frm_row#currentrow#" title="#PRODUCT_NAME#" style="background-color:<cfif get_all.type eq 2>snow<cfelseif get_all.type eq 4>lightcyan<cfelse>white</cfif>">
                                                        <td nowrap style="text-align:center; cursor:pointer" onClick="windowopen('#request.self#?fuseaction=sales.popup_dsp_ezgi_product_image&pid=#get_all.product_id#','wide');">
                                                            <cfif len(get_all.path)>
                                                                <img  alt="product" src="/documents/product/#get_all.path#" style="height:60px;"/>
                                                            <cfelse>
                                                                <img  alt="product" src="/images/production/no-image.png" style="height:40px;"/>
                                                            </cfif>
                                                        </td>
                                                        <td style="text-align:center;"><cfif get_all.type neq 4>#NUMBER#<cfelse>AKS</cfif></td>
                                                        <td nowrap style="text-align:left;">
                                                        	#PRODUCT_NAME#
                                                       	</td>
                                                        <td style="text-align:right;">#TlFormat(PRICE)# #MONEY#</td>
                                                        <td style="text-align:right;">
                                                            <select name="a_connect_amount_#STOCK_ID#" id="a_connect_amount_#STOCK_ID#" style="font-size:14px; font-weight:bold; height:100%; width:100%; background-color:mintcream; border:none">
                                                                <option value="1" >1</option>
                                                                <option value="2" >2</option>
                                                                <option value="3" >3</option>
                                                                <option value="4" >4</option>
                                                                <option value="5" >5</option>
                                                                <option value="6" >6</option>
                                                                <option value="7" >7</option>
                                                                <option value="8" >8</option>
                                                                <option value="9" >9</option>
                                                            </select>
                                                        </td>
                                                        
                                                        <td style="text-align:center;">
                                                            <input type="checkbox" name="a_select_production" value="#STOCK_ID#" >
                                                        </td>
                                                    </tr>
                                                </cfoutput>
                                            </cfif>
                                        </tbody>
                                    </cf_grid_list>         
                                </cf_box>
                            </div>
                     	</cfif>             	
                    </cfif>
                </div>
                <hr size="4" width="45%" color="<cfif stock_true eq 0>red<cfelse>green</cfif>" align="center">
            	<div id="standart_buton" style="height:40px; width:100%;text-align:center; vertical-align:middle;<cfif attributes.x_ssh eq 1>display:none</cfif>">
                	<cfoutput>
                    <cfif len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1 and len(get_product_info.IS_KARMA_SEVK) and get_product_info.IS_KARMA_SEVK eq 1>
                    	<a href="javascript://" onClick="grupla();">
                            <button type="button" name="trasferring" style="width:45%; font-size:10px;border-radius:10px; font-weight:bold;height:35px;border:none;background-color: ##5f8ee1!important;color: white !important;">
                                <i class="fa fa-shopping-basket" style="font-size:15px;"></i>
                            </button>
                        </a>
                    <cfelse>
                    	<cfif x_relation_type eq 1>
							<a href="javascript://" onclick="add_iliski_grupla(2);" class="modern-add-basket-link">
                                <button type="button" name="trasferring" class="modern-add-basket-btn">
                                	<i class="fa fa-shopping-basket"></i>
                                    <span>Sepete Ekle</span>
                            	</button>
                            </a>                        
                        <cfelse>
                            <a href="javascript://" onclick="add_product(0,1);" class="modern-add-basket-link">
                                <button type="button" name="trasferring" class="modern-add-basket-btn">
                                    <i class="fa fa-shopping-basket"></i>
                                    <span>Sepete Ekle</span>
                                </button>
                            </a>
                        </cfif>
                    </cfif>
                    </cfoutput>
             	</div>
                <div id="ssh_buton" style="height:40px; width:100%;text-align:center; vertical-align:middle; display:none">
                	<cfoutput>
                    	<a href="javascript://" onclick="add_ssh_grupla();" class="modern-add-basket-link">
                            <button type="button" name="trasferring" class="modern-add-basket-btn ssh-btn">
                                <i class="fa fa-shopping-basket"></i>
                                <span>Sepete Ekle</span>
                            </button>
                        </a>
                    </cfoutput>
             	</div>
                <hr size="2" width="100%">
            	<div class="product-info-modern">
                	<cfoutput>
                	<div class="product-title-section">
                    	<h2 class="product-title">#left(get_product_info.PRODUCT_NAME,80)#</h2>
                     	<span class="product-code">#get_product_info.PRODUCT_CODE#</span>
                   	</div>
                 	<div class="product-price-section">
                   		<cfif LEN(attributes.PRICE)>
                         	<span class="product-price">#TlFormat(attributes.PRICE,2)# #attributes.MONEY#</span>
                     	</cfif>
                 	</div>
                    <div class="product-special-price-section">
                   		<cfif LEN(attributes.NET_PRICE) and attributes.NET_PRICE neq attributes.PRICE>
                         	<span class="product-special-price">Özel Fiyat (#TlFormat(attributes.NET_PRICE,2)# #attributes.MONEY#)</span>
                     	</cfif>
                 	</div>
                    </cfoutput>
             	</div>
            </cf_box>
        </div>
    </div>
</div>
<cfset url_str = "">
<cfif isdefined('attributes.property_group_list') and ListLen(attributes.property_group_list)>
    <cfloop list="#attributes.property_group_list#" index="ii">
        <cfif isdefined('attributes.categori_id_list_#ii#') and len(Evaluate('attributes.categori_id_list_#ii#'))>
            <cfset url_str = "#url_str#&categori_id_list_#ii#=#Evaluate('attributes.categori_id_list_#ii#')#">
        </cfif>
    </cfloop>
</cfif>
<cfset product_info_list = '#attributes.STOCK_ID#,#net_fiyat#,#attributes.money#,0,#attributes.net_price#,#attributes.disc1#,#attributes.disc2#,#attributes.disc3#'>
<script type="text/javascript">
	const products = document.querySelectorAll(".product");

	products.forEach((product) => {
	const slider = product.querySelector(".slider");
	const images = slider.querySelectorAll("img");
	const prevBtn = product.querySelector(".prevBtn");
	const nextBtn = product.querySelector(".nextBtn");
	let counter = 0;


	images[counter].classList.add("active");

	prevBtn.addEventListener("click", function(event) {
		event.preventDefault();
		prevSlide();
	});
	nextBtn.addEventListener("click", function(event) {
		event.preventDefault();
		nextSlide();
	});

	function prevSlide() {
		images[counter].classList.remove("active");
		if (counter === 0) {
		counter = images.length - 1;
		} else {
		counter--;
		}
		images[counter].classList.add("active");
	}

	function nextSlide() {
		images[counter].classList.remove("active");
		if (counter === images.length - 1) {
		counter = 0;
		} else {
		counter++;
		}
		images[counter].classList.add("active");
	}
	});


	function kapat(type)
	{
		if(type==1)
		{
			document.getElementById('foto').style.display='';
			document.getElementById('genel').style.display='none';
			document.getElementById('teknik').style.display='none';
			document.getElementById('stoklar').style.display='none';
			document.getElementById('belge').style.display='none';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma').style.display='none';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh').style.display='none';
				document.getElementById('standart_buton').style.display='';
				document.getElementById('ssh_buton').style.display='none';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili').style.display='none';
			</cfif>
			document.getElementById('foto_').className='active';
			document.getElementById('genel_').className='';
			document.getElementById('teknik_').className='';
			document.getElementById('stoklar_').className='';
			document.getElementById('belge_').className='';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma_').className='';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh_').className='';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili_').className='';
			</cfif>
		}
		else if(type==2)
		{
			document.getElementById('foto').style.display='none';
			document.getElementById('genel').style.display='';
			document.getElementById('teknik').style.display='none';
			document.getElementById('stoklar').style.display='none';
			document.getElementById('belge').style.display='none';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma').style.display='none';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh').style.display='none';
				document.getElementById('standart_buton').style.display='';
				document.getElementById('ssh_buton').style.display='none';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili').style.display='none';
			</cfif>
			document.getElementById('foto_').className='';
			document.getElementById('genel_').className='active';
			document.getElementById('teknik_').className='';
			document.getElementById('stoklar_').className='';
			document.getElementById('belge_').className='';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma_').className='';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh_').className='';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili_').className='';
			</cfif>
		}
		else if(type==3)
		{
			document.getElementById('foto').style.display='none';
			document.getElementById('genel').style.display='none';
			document.getElementById('teknik').style.display='';
			document.getElementById('stoklar').style.display='none';
			document.getElementById('belge').style.display='none';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma').style.display='none';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh').style.display='none';
				document.getElementById('standart_buton').style.display='';
				document.getElementById('ssh_buton').style.display='none';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili').style.display='none';
			</cfif>
			document.getElementById('foto_').className='';
			document.getElementById('genel_').className='';
			document.getElementById('teknik_').className='active';
			document.getElementById('stoklar_').className='';
			document.getElementById('belge_').className='';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma_').className='';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh_').className='';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili_').className='';
			</cfif>
		}
		else if(type==4)
		{
			document.getElementById('foto').style.display='none';
			document.getElementById('genel').style.display='none';
			document.getElementById('teknik').style.display='none';
			document.getElementById('stoklar').style.display='none';
			document.getElementById('belge').style.display='';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma').style.display='none';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh').style.display='none';
				document.getElementById('standart_buton').style.display='';
				document.getElementById('ssh_buton').style.display='none';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili').style.display='none';
			</cfif>
			document.getElementById('foto_').className='';
			document.getElementById('genel_').className='';
			document.getElementById('teknik_').className='';
			document.getElementById('stoklar_').className='';
			document.getElementById('belge_').className='active';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma_').className='';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh_').className='';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili_').className='';
			</cfif>
		}
		else if(type==5)
		{
			document.getElementById('foto').style.display='none';
			document.getElementById('genel').style.display='none';
			document.getElementById('teknik').style.display='none';
			document.getElementById('stoklar').style.display='none';
			document.getElementById('belge').style.display='none';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma').style.display='';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh').style.display='none';
				document.getElementById('standart_buton').style.display='';
				document.getElementById('ssh_buton').style.display='none';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili').style.display='none';
			</cfif>
			document.getElementById('foto_').className='';
			document.getElementById('genel_').className='';
			document.getElementById('teknik_').className='';
			document.getElementById('stoklar_').className='';
			document.getElementById('belge_').className='';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma_').className='active';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh_').className='';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili_').className='';
			</cfif>
		}
		else if(type==6)
		{
			document.getElementById('foto').style.display='none';
			document.getElementById('genel').style.display='none';
			document.getElementById('teknik').style.display='none';
			document.getElementById('stoklar').style.display='';
			document.getElementById('belge').style.display='none';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma').style.display='none';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh').style.display='none';
				document.getElementById('standart_buton').style.display='';
				document.getElementById('ssh_buton').style.display='none';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili').style.display='none';
			</cfif>
			document.getElementById('foto_').className='';
			document.getElementById('genel_').className='';
			document.getElementById('teknik_').className='';
			document.getElementById('stoklar_').className='active';
			document.getElementById('belge_').className='';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma_').className='';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh_').className='';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili_').className='';
			</cfif>
		}
		else if(type==7)
		{
			document.getElementById('foto').style.display='none';
			document.getElementById('genel').style.display='none';
			document.getElementById('teknik').style.display='none';
			document.getElementById('stoklar').style.display='none';
			document.getElementById('belge').style.display='none';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma').style.display='none';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh').style.display='';
				document.getElementById('standart_buton').style.display='none';
				document.getElementById('ssh_buton').style.display='';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili').style.display='none';
			</cfif>
			document.getElementById('foto_').className='';
			document.getElementById('genel_').className='';
			document.getElementById('teknik_').className='';
			document.getElementById('stoklar_').className='';
			document.getElementById('belge_').className='';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma_').className='';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh_').className='active';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili_').className='';
			</cfif>
		}
		else if(type==8)
		{
			document.getElementById('foto').style.display='none';
			document.getElementById('genel').style.display='none';
			document.getElementById('teknik').style.display='none';
			document.getElementById('stoklar').style.display='none';
			document.getElementById('belge').style.display='none';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma').style.display='none';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh').style.display='none';
				document.getElementById('standart_buton').style.display='';
				document.getElementById('ssh_buton').style.display='none';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili').style.display='';
			</cfif>
			document.getElementById('foto_').className='';
			document.getElementById('genel_').className='';
			document.getElementById('teknik_').className='';
			document.getElementById('stoklar_').className='';
			document.getElementById('belge_').className='';
			<cfif isdefined('get_karma') and len(get_product_info.IS_KARMA) and get_product_info.IS_KARMA eq 1>
				document.getElementById('karma_').className='';
			</cfif>
			<cfif x_service_type eq 1>
				document.getElementById('ssh_').className='';
			</cfif>
			<cfif x_relation_type eq 1>
				document.getElementById('iliskili_').className='active';
			</cfif>
		}
	}
	function add_product(stock_id_list,amount_list,type)
	{
		price=<cfoutput>#attributes.price#</cfoutput>;

		if(price.length == 0)
		{
			alert('Fiyatı Olmayan Ürün Sepete Dahil Edilemez');
			return false;
		}
		else
		{
			window.location ="<cfoutput>#request.self#?fuseaction=sales.emptypopup_add_ezgi_connect_row&type="+type+"&karma_stock_id_list="+stock_id_list+"&karma_amount_list="+amount_list+"#url_str#&popup=1&connect_id=#attributes.connect_id#&price_cat_id=#attributes.PRICE_CAT_ID#&id_list=0&product_id=#attributes.PRODUCT_ID#&amount_info_list=1&product_info_list=#product_info_list#</cfoutput>"
		}
	}
	function grupla(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
		karma_stock_id_list = '';
		karma_amount_list = '';
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
				{
					stockid = my_objets.value;
					amount = document.getElementById('connect_amount_'+stockid).value;
					karma_stock_id_list +=my_objets.value+',';
					karma_amount_list +=amount+',';
				}
			}
		}

		karma_stock_id_list = karma_stock_id_list.substr(0,karma_stock_id_list.length-1);//sondaki virgülden kurtarıyoruz.
		if(karma_stock_id_list!='')
			add_product(karma_stock_id_list,karma_amount_list,1);
	}
	function add_ssh_grupla(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
		ssh_stock_id_list = '';
		ssh_amount_list = '';
		chck_leng = document.getElementsByName('a_select_production').length;
		for(ci=0;ci<chck_leng;ci++)
		{
			var my_objets = document.all.a_select_production[ci];
			if(chck_leng == 1)
				var my_objets =document.all.a_select_production;
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
				{
					stockid = my_objets.value;
					amount = document.getElementById('a_connect_amount_'+stockid).value;
					ssh_stock_id_list +=my_objets.value+',';
					ssh_amount_list +=amount+',';
				}
			}
		}
		ssh_stock_id_list = ssh_stock_id_list.substr(0,ssh_stock_id_list.length-1);//sondaki virgülden kurtarıyoruz.
		if(ssh_stock_id_list!='')
			add_product(ssh_stock_id_list,ssh_amount_list,2);
	}
	<cfif x_relation_type eq 1>
	function b_connnect_change_amount(b_amount)
	{
		<cfloop list="#b_stock_id_list_main#" index="b_i">
			document.getElementById('b_connect_amount_a_'+<cfoutput>#b_i#</cfoutput>).value = b_amount;
		</cfloop>
		<cfif get_relation_info_group.recordcount>
			<cfoutput query="get_relation_info_group">
				<cfset stock_id_list_zorunlu = Evaluate('b_stock_id_list_zorunlu_#get_relation_info_group.PRODUCT_VAR#')>
				prod_var = #get_relation_info_group.PRODUCT_VAR#;
				<cfloop list="#stock_id_list_zorunlu#" index="b_i">
					document.getElementById('b_connect_amount_'+prod_var+'_'+#b_i#).value = b_amount;
				</cfloop>
			</cfoutput>
		</cfif>
	}
	function add_iliski_grupla(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
		iliski_stock_id_list = '';
		iliski_amount_list = '';
		
		//kök ürün
		chck_leng = document.getElementsByName('b_select_production_a').length;
		for(ci=0;ci<chck_leng;ci++)
		{
			var my_objets = document.all.b_select_production_a[ci];
			if(chck_leng == 1)
				var my_objets =document.all.b_select_production_a;
	
			if(my_objets.checked == true)
			{
				stockid = my_objets.value;
				amount = document.getElementById('b_connect_amount_a_'+stockid).value;
				iliski_stock_id_list +=my_objets.value+',';
				iliski_amount_list +=amount+',';
			}
		}
		//zorunlu seçmeli ürün
		<cfif get_relation_info_group.recordcount>
			<cfoutput query="get_relation_info_group">
				prod_var = #get_relation_info_group.PRODUCT_VAR#;
				chck_leng = document.getElementsByName('b_select_production_'+prod_var).length;
				for(ci=0;ci<chck_leng;ci++)
				{
					var my_objets = document.all.b_select_production_#get_relation_info_group.PRODUCT_VAR#[ci];
					if(chck_leng == 1)
						var my_objets =document.all.b_select_production_#get_relation_info_group.PRODUCT_VAR#;
		
					if(my_objets.checked == true)
					{
						stockid = my_objets.value;
						amount = document.getElementById('b_connect_amount_'+prod_var+'_'+stockid).value;
						iliski_stock_id_list +=my_objets.value+',';
						iliski_amount_list +=amount+',';
					}
				}
			</cfoutput>
		</cfif>
		//seçmeli ürün
		chck_leng = document.getElementsByName('b_select_production_b').length;
		for(ci=0;ci<chck_leng;ci++)
		{
			var my_objets = document.all.b_select_production_b[ci];
			if(chck_leng == 1)
				var my_objets =document.all.b_select_production_b;
	
			if(my_objets.checked == true)
			{
				stockid = my_objets.value;
				amount = document.getElementById('b_connect_amount_b_'+stockid).value;
				iliski_stock_id_list +=my_objets.value+',';
				iliski_amount_list +=amount+',';
			}
		}
		iliski_stock_id_list = iliski_stock_id_list.substr(0,iliski_stock_id_list.length-1);//sondaki virgülden kurtarıyoruz.
		if(iliski_stock_id_list!='')
			add_product(iliski_stock_id_list,iliski_amount_list,2);
	}
	</cfif>
</script>
