<cf_xml_page_edit fuseact="sales.list_ezgi_connect">
<cfquery name="get_connect_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_CONNECT_SETUP
</cfquery>
<cfquery name="get_connect_defaults_row" datasource="#dsn3#">
	SELECT  ISNULL(IS_PRICE,0) AS IS_PRICE, ISNULL(IS_PRICE_KDV,0) AS IS_PRICE_KDV, ISNULL(IS_EXPORT,0) AS IS_EXPORT FROM EZGI_CONNECT_SETUP_ROW WHERE EMPLOYEE_ID = #session.ep.userid#
</cfquery>
<cfif not get_connect_defaults.recordcount or not get_connect_defaults_row.recordcount>
	<script type="text/javascript">
		alert("Öncelikle Hızlı Sepet Tanımlarını Yapmalısınız!");
		window.close();
	</script>
    <cfabort>
</cfif>

<cfquery name="get_properties" datasource="#dsn1#">
	SELECT 
		PP.PROPERTY_ID, 
		PP.PROPERTY, 
		PP.PROPERTY_CODE,
		PPD.PROPERTY_DETAIL_ID, 
		PPD.PROPERTY_DETAIL,
		PROPERTY_DETAIL_CODE
 	FROM     
	   	PRODUCT_PROPERTY AS PP WITH (NOLOCK) INNER JOIN
		PRODUCT_PROPERTY_OUR_COMPANY AS PPOC WITH (NOLOCK) ON PP.PROPERTY_ID = PPOC.PROPERTY_ID INNER JOIN
		PRODUCT_PROPERTY_DETAIL AS PPD WITH (NOLOCK) ON PP.PROPERTY_ID = PPD.PRPT_ID
 	WHERE  
	   	PP.IS_ACTIVE = 1 AND 
		PP.IS_INTERNET = 1 AND 
		PPOC.OUR_COMPANY_ID = #session.ep.company_id# AND 
		PPD.IS_ACTIVE = 1 AND 
		PPD.PROPERTY_DETAIL_ID IN(
			SELECT 
				VARIATION_ID
			FROM      
				#dsn_alias#.EZGI_CONNECT_PROPERTY WITH (NOLOCK)
			GROUP BY 
				VARIATION_ID
		)
 ORDER BY 
	 PPD.PROPERTY_DETAIL_CODE,
	   PP.PROPERTY_CODE
</cfquery>
<cfquery name="get_property_group" dbtype="query">
	SELECT PROPERTY_ID,PROPERTY FROM get_properties GROUP BY PROPERTY_ID,PROPERTY ORDER BY PROPERTY_CODE
</cfquery>
<cfif not get_property_group.recordcount>
	Önce Ürün Özelliklerinden Başlık Tanımları Yapmalısınız!!
 <cfabort>
</cfif>

<cfquery name="get_connect" datasource="#DSN3#">
	SELECT 
    	*,
        ISNULL (DISCOUNTTOTAL,0) DISCOUNTTOTAL_, 
        ISNULL(SUB_DISCOUNTTOTAL,0) SUB_DISCOUNTTOTAL_, 
        ISNULL(GROSSTOTAL,0) GROSSTOTAL_, 
        ISNULL(TAX,0) TAX_, 
        ISNULL(NETTOTAL,0) NETTOTAL_, 
        ISNULL(OTV_TOTAL,0) OTV_TOTAL_, 
       	ISNULL(TAXTOTAL,0) TAXTOTAL_, 
        ISNULL(OTHER_MONEY,'#session.ep.money#') OTHER_MONEY_, 
        ISNULL(OTHER_MONEY_VALUE,0) OTHER_MONEY_VALUE_,
        ISNULL(EMPLOYEE_CASH_DISC_RATE,0) AS EMPLOYEE_CASH_DISC_RATE_,
        ISNULL(EMPLOYEE_FUTURE_DISC_RATE,0) AS EMPLOYEE_FUTURE_DISC_RATE_,
        ISNULL(EMPLOYEE_CAMP_DISC_RATE,0) AS EMPLOYEE_CAMP_DISC_RATE_,
        ISNULL(SALES_TYPE,1) AS SALES_TYPE_
   	FROM 
    	EZGI_CONNECT WITH (NOLOCK)
   	WHERE 
    	CONNECT_ID = #attributes.connect_id#
</cfquery>
<cfif get_connect.PROJECT_ID eq x_ssh> <!---SSH Sepeti mi?--->
	<cfset attributes.x_ssh = 1>
<cfelse>
	<cfset attributes.x_ssh = 0>
</cfif>
<cfquery name="get_connect_row" datasource="#DSN3#">
	SELECT 
    	E.*,
        P.PRODUCT_CATID,
        ISNULL(E.QUANTITY,0) AS AMOUNT, 
        ISNULL(E.PRICE_OTHER,0) AS SALES_PRICE, 
        ISNULL(E.OTHER_MONEY,'#session.ep.money#') AS MONEY,
        ISNULL(E.DISCOUNT_1,0) AS DISCOUNT1, 
        ISNULL(E.DISCOUNT_2,0) AS DISCOUNT2, 
        ISNULL(E.DISCOUNT_3,0) AS DISCOUNT3,
        ISNULL(E.DISCOUNT_COST,0) AS DISCOUNT_TUT,
        ISNULL(E.IS_CAMPAIGN_PRODUCT,0) AS IS_CAMPAIGN_PRODUCT_
  	FROM 
    	EZGI_CONNECT_ROW AS E WITH (NOLOCK),
        #dsn1_alias#.PRODUCT AS P WITH (NOLOCK)
   	WHERE 
    	E.PRODUCT_ID = P.PRODUCT_ID AND
    	E.CONNECT_ID = #attributes.connect_id#
 	ORDER BY
		E.SORT_NO,
    	E.CONNECT_ROW_ID
</cfquery>
<cfset attributes.is_campaign_product =0>
<cfoutput query="get_connect_row">
	<cfif isdefined('AMOUNT_#STOCK_ID#')>
		<cfset 'AMOUNT_#STOCK_ID#' = EVALUATE('AMOUNT_#STOCK_ID#')+AMOUNT>
    <cfelse>
    	<cfset 'AMOUNT_#STOCK_ID#' = AMOUNT>
    </cfif>
</cfoutput>
<cfquery name="get_money" datasource="#dsn#">
	SELECT MONEY_ID,MONEY, RATE2, RATE1 FROM SETUP_MONEY WITH (NOLOCK) WHERE PERIOD_ID = #session.ep.period_id#
</cfquery>
<cfoutput query="get_money">
  	<cfset 'RATE1_#MONEY#' = RATE1>
  	<cfset 'RATE2_#MONEY#' = RATE2>
</cfoutput>
<cfquery name="get_connect_money" datasource="#DSN3#">
	SELECT        
    	MONEY_TYPE, 
        RATE2, 
        RATE1, 
        IS_SELECTED
	FROM            
    	EZGI_CONNECT_MONEY
	WHERE        

    	ACTION_ID = #attributes.connect_id#
</cfquery>

<cfif isdefined('attributes.connect_id')>
	<cfoutput query="get_connect_money">
        <cfset 'RATE1_#MONEY_TYPE#' = RATE1>
        <cfset 'RATE2_#MONEY_TYPE#' = RATE2>
    </cfoutput>
</cfif>
<cfquery name="get_connect_money_selected" dbtype="query">
	SELECT 
    	<cfif isdefined('attributes.connect_id')>       
    		MONEY_TYPE,
        <cfelse>
        	MONEY as MONEY_TYPE,
        </cfif> 
        RATE2
	FROM     
		<cfif isdefined('attributes.connect_id')>
        	get_connect_money
        <cfelse>       
    		get_money
        </cfif>
	WHERE
    	<cfif isdefined('attributes.connect_id')>        
    		IS_SELECTED = 1
        <cfelse>
        	MONEY = '#session.ep.money#'
        </cfif>
</cfquery>
<cfquery name="get_branch" datasource="#dsn#">
	SELECT BRANCH_ID, BRANCH_NAME FROM BRANCH WHERE COMPANY_ID = #session.ep.company_id# AND BRANCH_STATUS = 1 ORDER BY BRANCH_NAME
</cfquery>
<cfif len(get_connect.PAYMETHOD)>
    <cfquery name="get_paymethod" datasource="#dsn#">
        SELECT PAYMETHOD_ID, PAYMETHOD FROM SETUP_PAYMETHOD WHERE PAYMETHOD_ID = #get_connect.PAYMETHOD#
    </cfquery>
    <cfset attributes.paymethod_id=get_paymethod.PAYMETHOD_ID>
	<cfset attributes.paymethod=get_paymethod.PAYMETHOD>
</cfif>
<cfquery name="get_offer_relations" datasource="#dsn3#">
	SELECT 
    	ECR.CONNECT_ROW_ID
	FROM     
    	EZGI_CONNECT_ROW AS ECR WITH (NOLOCK) INNER JOIN
        OFFER_ROW AS OFR WITH (NOLOCK) ON ECR.WRK_ROW_RELATION_ID = OFR.WRK_ROW_ID
	WHERE  
    	ECR.CONNECT_ID = #attributes.connect_id#
</cfquery>
<cfif len(get_connect.CONNECT_REL_ID)>
	<cfquery name="get_related_connect" datasource="#dsn3#">
    	SELECT CONNECT_ID,CONNECT_NUMBER FROM EZGI_CONNECT WHERE CONNECT_REL_ID = #get_connect.CONNECT_REL_ID# ORDER BY CONNECT_ID
    </cfquery>
<cfelse>
	<cfset get_related_connect.recordcount =0>
</cfif>
<cfinclude template="../../../../v16/sales/query/get_moneys.cfm">
<cfinclude template="../../../../v16/sales/query/get_priorities.cfm">

<cfset process_action = 'connect'>
<cfset process_fuse = 'upd'>
<cfparam name="attributes.consumer_reference_code" default="">
<cfparam name="attributes.partner_reference_code" default="">
<cfparam name="attributes.ship_method" default="#get_connect.SHIP_METHOD#">
<cfset attributes.branch_id = get_connect.branch_id>
<cfset attributes.sales_type = get_connect.SALES_TYPE_>
<cfset attributes.project_id = get_connect.PROJECT_ID>
<cfset attributes.connect_date = DateFormat(get_connect.connect_DATE,dateformat_style)>
<cfset attributes.deliverdate = DateFormat(get_connect.DELIVERDATE,dateformat_style)>
<cfset attributes.connect_head = get_connect.connect_HEAD>
<cfset attributes.connect_detail = get_connect.connect_DETAIL>
<cfset attributes.deliver_dept_name="">
<cfset attributes.deliver_dept_id= get_connect.DELIVER_DEPT_ID>
<cfset attributes.deliver_loc_id= get_connect.LOCATION_ID>
<cfSET attributes.basket_due_value_date_= DateFormat(get_connect.DUE_DATE,dateformat_style)>
<cfSET attributes.basket_due_value= get_connect.DUE_VALUE>
<cfset attributes.process_stage = get_connect.connect_STAGE>
<cfset attributes.connect_status = get_connect.connect_status>
<cfset attributes.price_catid = get_connect.PRICE_CAT_ID>
<cfset attributes.connect_tel = get_connect.connect_tel>
<cfset attributes.resource_id = get_connect.resource_id>
<cfset attributes.order_employee_id = get_connect.connect_employee_id>
<cfset attributes.ref_company_id = "">
<cfset attributes.ref_member_type = "">
<cfset attributes.ref_member_id = "">
<cfif len(get_connect.company_id)>
	<cfset attributes.company_id = get_connect.company_id>
    <cfset attributes.partner_id = get_connect.partner_id>
    <cfset attributes.member_type = get_connect.member_type>
    <cfset attributes.musteri_id = get_connect.company_id>
<cfelseif len(get_connect.consumer_id)>
	<cfset attributes.member_type = get_connect.member_type>
	<cfset attributes.consumer_id = get_connect.consumer_id>
    <cfset attributes.musteri_id = get_connect.consumer_id>
</cfif>
<cfif attributes.sales_type eq 1>
	<cfset max_rate = get_connect.EMPLOYEE_CASH_DISC_RATE_>
<cfelseif attributes.sales_type eq 2>
	<cfset max_rate = get_connect.EMPLOYEE_FUTURE_DISC_RATE_>
<cfelseif attributes.sales_type eq 3>
	<cfset max_rate = get_connect.EMPLOYEE_CAMP_DISC_RATE_>
<cfelseif attributes.sales_type eq 4>
	<cfset max_rate = 100>
</cfif>
<cfset attributes.campaign_type = 0>
<cfset attributes.campaign_min_limit = 0>
<cfset attributes.iskonto_izin= 1>
<cfif len(attributes.project_id)>
	<cfquery name="get_pro_camp_info" datasource="#dsn3#">
    	SELECT ISNULL(MIN_LIMIT,0) AS MIN_LIMIT, CAMPAIGN_TYPE FROM PROJECT_DISCOUNTS WHERE PROJECT_ID = #attributes.project_id#
    </cfquery>
    <cfif get_pro_camp_info.recordcount>
    	<cfif not len(get_pro_camp_info.CAMPAIGN_TYPE)>
        	<script type="text/javascript">
				alert("Proje Ürün Bağlantılarındaki Kampanya Tipi Tanımsızdır.!");
			</script>
            <cfabort>
        <cfelse>
        	<cfif (get_pro_camp_info.CAMPAIGN_TYPE eq 2 or get_pro_camp_info.CAMPAIGN_TYPE eq 3 or get_pro_camp_info.CAMPAIGN_TYPE eq 4) and get_pro_camp_info.MIN_LIMIT lte 0> <!---Hediye Ürün Kampanyaları ise ve Limit Tanımlanmamışsa--->
            	<script type="text/javascript">
					alert("Proje Ürün Bağlantılarındaki Hediye Ürün Minimum Limiti Tanımsızdır.!");
				</script>
				<cfabort>
         	<cfelseif get_pro_camp_info.CAMPAIGN_TYPE eq 1> <!---Anında İndirim Kampanyası ve İskonto Tablosu Kontrol--->
            	<cfquery name="Get_Discount_Table" datasource="#DSN3#">
                    SELECT 
                        EZGI_CONNECT_CAMPAIGN_DISCOUNT_ID, 
                        START_TOTAL, 
                        FINISH_TOTAL, 
                        DISCOUNT
                    FROM     
                        EZGI_CONNECT_CAMPAIGN_DISCOUNT
                    WHERE  
                        PROJECT_ID = #attributes.project_id#
                  	ORDER BY
                    	EZGI_CONNECT_CAMPAIGN_DISCOUNT_ID
                </cfquery>
                <cfif not Get_Discount_Table.recordcount>
					<script type="text/javascript">
                        alert("Proje Ürün Bağlantılarındaki Anında İndirim İskonto Tablosu Tanımsızdır.!");
                    </script>
                    <cfabort>
                <cfelse>
                	<cfloop query="Get_Discount_Table">
                    	<cfif not len(Get_Discount_Table.DISCOUNT) or Get_Discount_Table.DISCOUNT eq 0>
                        	<script type="text/javascript">
								alert("Proje Ürün Bağlantılarındaki Anında İndirim İskonto Tablosunda İskonto Alanı Sıfırdan Büyük Olmalıdır.!");
							</script>
							<cfabort>
                        </cfif>
                    	<cfif Get_Discount_Table.FINISH_TOTAL lte Get_Discount_Table.START_TOTAL>
                        	<script type="text/javascript">
								alert("Proje Ürün Bağlantılarındaki Anında İndirim İskonto Tablosunda Bitiş Değeri Başlangıç Değerinden Büyük Değildir.!");
							</script>
							<cfabort>
                        </cfif>
                        <cfif Get_Discount_Table.currentrow gt 1>
                        	<cfif Get_Discount_Table.START_TOTAL neq Get_Discount_Table.FINISH_TOTAL[#Get_Discount_Table.currentrow#-1]>
                            	<script type="text/javascript">
									alert("Proje Ürün Bağlantılarındaki Anında İndirim İskonto Tablosunda Başlangıç Değeri ile Bir Önceki Satırın Bitiş Değeri Eşit Olmalıdır.!");
								</script>
								<cfabort>
                            </cfif>
                        </cfif>
                        <cfif Get_Discount_Table.currentrow eq 1><!---Kampanya Tipi Anında İndirim ve Sorun Yoksa--->
                        	<cfset attributes.campaign_min_limit = Get_Discount_Table.FINISH_TOTAL>	
                        </cfif>
                    </cfloop>
                </cfif>
            <cfelse> <!---Kampanya Tipi Hediye Ürün ve Sorun Yoksa--->
            
            	<cfif get_pro_camp_info.CAMPAIGN_TYPE eq 4><!--- Ürün Bazında Hediye Ürün mü--->
                	<!---Kampanya Tipi Ürün Bazlı Hediye Ürün  ise Ürün Listesi Alınıyor--->
                    <cfquery name="get_ezgi_project_discount_product" datasource="#dsn3#">
                        SELECT CON_PRODUCT_ID, PRODUCT_ID, QUANTITY FROM EZGI_CONNECT_PROJECT_DISCOUNT_SUB_CONDITIONS WHERE PROJECT_ID = #attributes.project_id#
                    </cfquery>
                    <cfset urun_bazli_hediye_list = ListDeleteDuplicates(ValueList(get_ezgi_project_discount_product.CON_PRODUCT_ID))>
                    <cfif not Listlen(urun_bazli_hediye_list)><!---Ürün Bazlı Liste Tanımlanmışsa--->
                     	<script type="text/javascript">
                         	alert("Ürün Bazlı Hediye Ürün Kampanyası İçinde Ürün Tanımı yapılmamıştır.!");
                     	</script>
                      	<cfabort>	
                 	</cfif>
                    
                    <cfquery name="get_campaign_product" dbtype="query"> <!---Satırlar arasında Hediye Verilmesi gereken ürün varmı Listesi Alınıyor--->
                    	SELECT PRODUCT_ID, SUM(AMOUNT) AS AMOUNT FROM get_connect_row WHERE PRODUCT_ID IN (#urun_bazli_hediye_list#) GROUP BY PRODUCT_ID
                    </cfquery>
                    
                    <cfif get_campaign_product.recordcount><!--- Sepette Kampanyayı İlgilendiren ürün varsa--->	
                    	<cfoutput query="get_connect_row"> <!---Satırlar Döndürülüyor--->
							<cfif IS_CAMPAIGN_PRODUCT_ eq 1> <!---Ürün Hediye Ürün Mü--->
                                <cfset attributes.is_campaign_product = 1>
                            </cfif>
                        </cfoutput>
					<cfelse><!--- Sepette Kampanyayı İlgilendiren ürün Yoksa--->	
                    	<cfset attributes.is_campaign_product = 1>
                    </cfif>
                <cfelseif get_pro_camp_info.CAMPAIGN_TYPE eq 2 or get_pro_camp_info.CAMPAIGN_TYPE eq 3><!---Kampanya Tipi Hediye Ürün ve Kediye Ürün+İskonto ise--->
					<cfoutput query="get_connect_row"> <!---Satırlar Döndürülüyor--->
                        <cfif IS_CAMPAIGN_PRODUCT_ eq 1> <!---Ürün Hediye Ürün Mü--->
                        	<cfset attributes.is_campaign_product = 1>
                        </cfif>
                    </cfoutput>
               	</cfif>
            	<cfset attributes.campaign_min_limit = get_pro_camp_info.MIN_LIMIT>	
            </cfif>
            <cfif get_pro_camp_info.CAMPAIGN_TYPE eq 1><!--- Anında İndirim--->
            	<cfset attributes.iskonto_izin= 0>
            <cfelseif get_pro_camp_info.CAMPAIGN_TYPE eq 2><!--- Hediye Ürün--->
            	<cfset attributes.iskonto_izin= 0>
        	<cfelseif get_pro_camp_info.CAMPAIGN_TYPE eq 3><!--- Hediye Ürün + İskonto--->
            	<cfset attributes.iskonto_izin= 1>
          	<cfelseif get_pro_camp_info.CAMPAIGN_TYPE eq 4><!--- Ürün Bazlı Hediye Ürün--->
            	<cfset attributes.iskonto_izin= 1>
            </cfif>
        </cfif>
        <cfset attributes.campaign_type = get_pro_camp_info.CAMPAIGN_TYPE>
    </cfif>
</cfif>
<cfinclude template="../query/get_ezgi_sales_info.cfm">