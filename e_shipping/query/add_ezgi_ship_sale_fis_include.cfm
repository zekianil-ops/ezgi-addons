<!---
    File: add_ezgi_ship_sale_include.cfm
    Folder: Add_Ons\ezgi\e_shipping\query
    Author: Ezgi Yazılım
    Date: 01/10/2025
    Description: Hızlı Satış İrsaliyesi Oluşturmak_include_file
--->
<cf_get_lang_set module_name="stock"><!--- sayfanin en altinda kapanisi var --->
<cfif isDefined("attributes.employee_id") and len(attributes.employee_id)>
	<cfif Find("_",attributes.employee_id)>
		<cfset attributes.employee_id = listGetAt(attributes.employee_id,1,'_')>
	</cfif>
</cfif>
<cfinclude template="../../../../v16/stock/query/check_our_period.cfm">
<cfif isdefined('ship_number')>
	<cfset list1=",">
	<cfset list2="">
	<cfset ship_number = Replace(ship_number,list1,list2,"ALL")> 
</cfif>
<cfif (not len(attributes.company_id) and not len(attributes.comp_name)) and not len(attributes.consumer_id) and not len(attributes.employee_id)>
	<script type="text/javascript">
		alert("<cf_get_lang no='131.Üye Seçmediniz'>!");
		window.location.href='<cfoutput>#cgi.referer#</cfoutput>';
	</script>
	<cfabort>	
</cfif>
<cfif not isdefined("new_dsn2_group")><cfset new_dsn2_group = dsn2></cfif>
<cfif not isdefined("new_dsn3_group")><cfset new_dsn3_group = dsn3></cfif>
<cfinclude template="../../../../v16/stock/query/get_process_cat.cfm">
<cfif not len(attributes.location_id)>
	<cfset attributes.location_id = "NULL">
</cfif>
<cf_date tarih = 'attributes.deliver_date_frm'>
<cf_date tarih = 'attributes.ship_date'>
<cfset attributes.deliver_date_frm = createdatetime(year(attributes.deliver_date_frm),month(attributes.deliver_date_frm),day(attributes.deliver_date_frm),attributes.deliver_date_h,attributes.deliver_date_m,0)>
<cfset attributes.deliver_date_frm = createdatetime(year(attributes.deliver_date_frm),month(attributes.deliver_date_frm),day(attributes.deliver_date_frm),attributes.deliver_date_h,attributes.deliver_date_m,0)>
<cfif isdefined("attributes.basket_due_value") and len(attributes.basket_due_value)>
	<cfset ship_due_date = date_add("d",attributes.basket_due_value,attributes.ship_date)>
<cfelse>
	<cfset ship_due_date = "">
</cfif>
<cfif not isDefined("wrk_id")><!--- pda vs yerlerde set edilyor zaten --->
	<cfset wrk_id = dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*100)>
</cfif>
<cflock name="#CreateUUID()#" timeout="20">
	<cftransaction>
		<cfquery name="ADD_SALE" datasource="#new_dsn2_group#" result="MAX_ID">
			INSERT INTO
				SHIP
				(
                    WRK_ID,
                    PURCHASE_SALES,
                    SHIP_NUMBER,
                    SHIP_TYPE,
                    PROCESS_CAT,
                    SHIP_METHOD,
                    SHIP_DATE,
                    SHIP_DETAIL,
                    <cfif len(attributes.company_id) and len(attributes.comp_name)>
                        COMPANY_ID,
                        PARTNER_ID,
                    <cfelseif len(attributes.consumer_id)>
                        CONSUMER_ID,
                    <cfelse>
                        EMPLOYEE_ID,
                    </cfif>
                        <cfif isDefined("session.ep") and session.ep.our_company_info.project_followup eq 1>
                            PROJECT_ID,
                            PROJECT_ID_IN,
                        </cfif>
                    <cfif isdate(attributes.deliver_date_frm)>DELIVER_DATE,</cfif>
                    DELIVER_EMP,
                    DISCOUNTTOTAL,
                    NETTOTAL,
                    GROSSTOTAL,
                    TAXTOTAL,
                    OTV_TOTAL,
                    OTHER_MONEY,
                    OTHER_MONEY_VALUE,
                    DELIVER_STORE_ID,
                    LOCATION,
                    RECORD_DATE,
                    ADDRESS,
                    SHIP_ADDRESS_ID,
                    CITY_ID,
                    COUNTY_ID,
                    COUNTRY_ID,
                    RECORD_EMP,
                    IS_WITH_SHIP,
                    COMMETHOD_ID,
                    REF_NO,
                    DUE_DATE,
                    PAYMETHOD_ID,
                    GENERAL_PROM_ID,
                    GENERAL_PROM_LIMIT,
                    GENERAL_PROM_AMOUNT,
                    GENERAL_PROM_DISCOUNT,
                    FREE_PROM_ID,
                    FREE_PROM_LIMIT,
                    FREE_PROM_AMOUNT,
                    FREE_PROM_STOCK_ID,
                    FREE_STOCK_PRICE,
                    FREE_STOCK_MONEY,
                    CARD_PAYMETHOD_ID,
                    CARD_PAYMETHOD_RATE,
                    DELIVER_COMP_ID,
                    DELIVER_CONS_ID,
                    SUBSCRIPTION_ID,
                    SERVICE_ID,
                    SA_DISCOUNT,
                    IS_RECEIVED_WEBSERVICE,
                    PROCESS_STAGE
                    <cfif isdefined('attributes.sale_emp') and len(attributes.sale_emp) and isdefined('attributes.sale_emp_name') and len(attributes.sale_emp_name)>,SALE_EMP</cfif>                
				)
			VALUES
				(
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_id#">,
                    1,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#SHIP_NUMBER#">,
                    #get_process_type.process_type#,
                    #form.process_cat#,					
                    <cfif isDefined('attributes.SHIP_METHOD') and len(attributes.SHIP_METHOD)>
                        #attributes.SHIP_METHOD#,
                    <cfelse>
                        NULL,
                    </cfif>
                    #attributes.ship_date#,
                    <cfif isdefined('attributes.detail') and len(attributes.detail)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.detail#"><cfelse>NULL</cfif>,
                    <cfif len(attributes.company_id) and len(attributes.comp_name)>
                        #attributes.company_id#,
                        <cfif len(attributes.partner_id)>#attributes.partner_id#,<cfelse>NULL,</cfif>
                    <cfelseif len(attributes.consumer_id)>
                        #attributes.consumer_id#,
                    <cfelse>
                        #attributes.employee_id#,
                    </cfif>
                    <cfif isDefined("session.ep") and session.ep.our_company_info.project_followup eq 1>
                        <cfif len(attributes.project_id) and len(attributes.project_head)>#attributes.project_id#,<cfelse>NULL,</cfif>
                        <cfif isdefined("attributes.project_id_in") and len(attributes.project_id_in) and len(attributes.project_head_in)>#attributes.project_id_in#,<cfelse>NULL,</cfif>
                    </cfif>
                    <cfif isdate(attributes.deliver_date_frm)>
                        #attributes.deliver_date_frm#,
                    </cfif>
                    <cfif isdefined("attributes.DELIVER_GET") and len(attributes.DELIVER_GET)><cfqueryparam cfsqltype="cf_sql_varchar" value="#LEFT(TRIM(attributes.DELIVER_GET),50)#"><cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.BASKET_DISCOUNT_TOTAL")>#attributes.BASKET_DISCOUNT_TOTAL#,<cfelse>0,</cfif>
                    <cfif isdefined("attributes.basket_net_total")>#attributes.basket_net_total#,<cfelse>0,</cfif>
                    <cfif isdefined("attributes.basket_gross_total")>#attributes.basket_gross_total#,<cfelse>0,</cfif>
                    <cfif isdefined("attributes.basket_tax_total")>#attributes.basket_tax_total#,<cfelse>0,</cfif>
                    <cfif isdefined("attributes.basket_otv_total") and len(attributes.basket_otv_total)>#attributes.basket_otv_total#<cfelse>NULL</cfif>,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.basket_money#">,
                    #((form.BASKET_NET_TOTAL*form.BASKET_RATE1)/form.BASKET_RATE2)#,
                    #attributes.department_id#,
                    #attributes.location_id#,
                    #now()#,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#adres#">,
                    <cfif isDefined("attributes.ship_address_id") and len(attributes.ship_address_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.ship_address_id#"><cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.city_id") and len(attributes.city_id)>#attributes.city_id#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.county_id") and len(attributes.county_id)>#attributes.county_id#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.country_id") and len(attributes.country_id)>#attributes.country_id#<cfelse>NULL</cfif>,
                    #session.ep.userid#,
                    0,
                    <cfif isdefined("attributes.commethod_id") and len(attributes.commethod_id)>#attributes.commethod_id#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.ref_no") and len(attributes.ref_no)><cfqueryparam cfsqltype="cf_sql_varchar" value="#listdeleteduplicates(attributes.ref_no)#"><cfelse>NULL</cfif>,
                    <cfif isdefined("ship_due_date") and len(ship_due_date)>#ship_due_date#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.paymethod_id") and len(attributes.paymethod_id)>#attributes.paymethod_id#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.general_prom_id") and len(attributes.general_prom_id)>#attributes.general_prom_id#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.general_prom_limit") and len(attributes.general_prom_limit)>#attributes.general_prom_limit#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.general_prom_amount") and len(attributes.general_prom_amount)>#attributes.general_prom_amount#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.general_prom_discount") and len(attributes.general_prom_discount)>#attributes.general_prom_discount#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.free_prom_id") and len(attributes.free_prom_id)>#attributes.free_prom_id#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.free_prom_limit") and len(attributes.free_prom_limit)>#attributes.free_prom_limit#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.free_prom_amount") and len(attributes.free_prom_amount)>#attributes.free_prom_amount#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.free_prom_stock_id") and len(attributes.free_prom_stock_id)>#attributes.free_prom_stock_id#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.free_stock_price") and len(attributes.free_stock_price)>#attributes.free_stock_price#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.free_stock_money") and len(attributes.free_stock_money)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.free_stock_money#"><cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.card_paymethod_id") and len(attributes.card_paymethod_id)>
                        #attributes.card_paymethod_id#,
                        <cfif isdefined("attributes.commission_rate") and len(attributes.commission_rate)>
                            #attributes.commission_rate#,
                        <cfelse>
                            NULL,
                        </cfif>
                    <cfelse>
                        NULL,
                        NULL,
                    </cfif>
                    <cfif isdefined("attributes.deliver_comp_id") and len(attributes.deliver_comp_id)>#attributes.deliver_comp_id#<cfelse>NULL</cfif>,
                    <cfif isdefined("attributes.deliver_cons_id") and len(attributes.deliver_cons_id)>#attributes.deliver_cons_id#<cfelse>NULL</cfif>,
                    <cfif isDefined("attributes.subscription_id") and len(attributes.subscription_id) and isDefined("attributes.subscription_no") and len(attributes.subscription_no)>#attributes.subscription_id#<cfelse>NULL</cfif>,
                    <cfif isDefined("attributes.service_app_id") and len(attributes.service_app_id) and isDefined("attributes.service_app_no") and len(attributes.service_app_no)>#attributes.service_app_id#<cfelse>NULL</cfif>,
                    <cfif isdefined('form.genel_indirim') and len(form.genel_indirim)>#form.genel_indirim#<cfelse>0</cfif>,
                    <cfif isdefined('attributes.webService')>1<cfelse>0</cfif>,
                    <cfif isdefined('attributes.process_stage') and len(attributes.process_stage)>#attributes.process_stage#<cfelse>NULL</cfif>
                    <cfif isdefined('attributes.sale_emp') and len(attributes.sale_emp) and isdefined('attributes.sale_emp_name') and len(attributes.sale_emp_name)>,#attributes.sale_emp#</cfif>
				)
		</cfquery>
        <!---IRSALİYE MONEY TABLOSUNA KAYIT ATIYORUM (sİPARİŞ BELGESİNDEN ALIYORUM)--->
		<!---<cfquery name="add_ship_money" datasource="#dsn2#">
        	INSERT INTO 
             	SHIP_MONEY 
            	(
                 	ACTION_ID,
                 	MONEY_TYPE,
                  	RATE2,
                  	RATE1,
               		IS_SELECTED
              	)
        	SELECT 
             	#MAX_ID.IDENTITYCOL#,
             	MONEY_TYPE, 
             	RATE2, 
            	RATE1, 
            	IS_SELECTED
			FROM     
            	#dsn3_alias#.ORDER_MONEY
			WHERE  
           		ACTION_ID = #ListGetAt(attributes.order_id_listesi,1)#		
      	</cfquery>--->
		<cfloop from="1" to="#attributes.rows_#" index="i">
			<cfif isDefined("session.ep")>
				<cfif session.ep.our_company_info.spect_type and isdefined('attributes.is_production#i#') and evaluate('attributes.is_production#i#') eq 1 and not (isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#')))>
					<cfset dsn_type=new_dsn2_group>
					<cfinclude template="../../../../v16/objects/query/add_basket_spec.cfm">
				</cfif>
			</cfif>
			<cf_date tarih = 'attributes.deliver_date#i#'> <!--- satırdaki teslim tarihi burada formatlanıyor, fakat stocks_row'a kayıt atılırken de aynı degerler kullanılıyor --->
			<cfinclude template="../../../../v16/stock/query/get_dis_amount.cfm">
			<cfif isDefined("attributes.related_action_id_main") and Len(attributes.related_action_id_main)><cfset 'attributes.related_action_id#i#' = attributes.related_action_id_main></cfif>
			<cfif isDefined("attributes.related_action_table_main") and Len(attributes.related_action_table_main)><cfset 'attributes.related_action_table#i#' = attributes.related_action_table_main></cfif>
			<cfif isdefined('attributes.reason_code#i#') and len(evaluate('attributes.reason_code#i#'))>
				<cfset reasonCode = Replace(evaluate('attributes.reason_code#i#'),'--','*')>
			<cfelse>
				<cfset reasonCode = ''>
			</cfif>
            <cfif not len(evaluate('attributes.wrk_row_relation_id#i#'))>
            	WRK_ROW_ID Boş
                <cfabort>
            </cfif>
            <!---SİPARİŞ SATIR VE FİŞ BİLGİLERİ ALIYORUM--->
            <cfquery name="get_order_amounts" datasource="#dsn2#">
				SELECT 
                	ORR.QUANTITY,
					ORR.STOCK_ID,
					ORR.ORDER_ROW_ID,
					ORR.RESERVE_TYPE,
					ORR.ORDER_ROW_CURRENCY AS ROW_CURRENCY,
					O.RESERVED,
                    O.ORDER_ID
				FROM 
					#dsn3_alias#.ORDERS O,
					#dsn3_alias#.ORDER_ROW ORR
				WHERE 
					O.ORDER_ID = ORR.ORDER_ID AND 
                    O.ORDER_ID IN (#attributes.order_id_listesi#) AND 
                 	WRK_ROW_ID = '#evaluate('attributes.wrk_row_relation_id#i#')#'
			</cfquery>
			<cfquery name="ADD_SHIP_ROW" datasource="#new_dsn2_group#">
				INSERT INTO
					SHIP_ROW
					(
					NAME_PRODUCT,
					PAYMETHOD_ID,
					SHIP_ID,
					STOCK_ID,
					PRODUCT_ID,
					AMOUNT,
					UNIT,
					UNIT_ID,					
					TAX,
				<cfif len(evaluate("attributes.price#i#"))>
					PRICE,
				</cfif>
					DISCOUNT,
					PURCHASE_SALES,
					DISCOUNT2,
					DISCOUNT3,
					DISCOUNT4,
					DISCOUNT5,
					DISCOUNT6,
					DISCOUNT7,
					DISCOUNT8,
					DISCOUNT9,
					DISCOUNT10,
					DISCOUNTTOTAL,
					GROSSTOTAL,
					NETTOTAL,
					TAXTOTAL,
					DELIVER_DATE,						
					DELIVER_DEPT,
					DELIVER_LOC,
					<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>					
                        SPECT_VAR_ID,
                        SPECT_VAR_NAME,
                    </cfif>
					LOT_NO,
					OTHER_MONEY,
					OTHER_MONEY_VALUE,				
					PRICE_OTHER,
					OTHER_MONEY_GROSS_TOTAL,
					COST_PRICE,
					EXTRA_COST,
					DISCOUNT_COST,
					MARGIN,
					ROW_ORDER_ID,
					<cfif listfind('72,78,79',get_process_type.PROCESS_TYPE) and isdefined("attributes.irsaliye_id_listesi") and len(attributes.irsaliye_id_listesi)>
                        RELATED_SHIP_ID,
                        RELATED_SHIP_PERIOD,
                    </cfif>
					PROM_COMISSION,
					PROM_COST,
					PROM_ID,
					IS_PROMOTION,
					PROM_STOCK_ID,
					IS_COMMISSION,
					DARA,
					DARALI,
					UNIQUE_RELATION_ID,
					PROM_RELATION_ID,
					PRODUCT_NAME2,
					AMOUNT2,
					UNIT2,
					EXTRA_PRICE,
					EK_TUTAR_PRICE,<!--- iscilik birim ücreti --->
					EXTRA_PRICE_TOTAL,
					EXTRA_PRICE_OTHER_TOTAL,
					SHELF_NUMBER,
					TO_SHELF_NUMBER,
					PRODUCT_MANUFACT_CODE,
					BASKET_EXTRA_INFO_ID,
					SELECT_INFO_EXTRA,
					DETAIL_INFO_EXTRA,
					BASKET_EMPLOYEE_ID,
					LIST_PRICE,
					PRICE_CAT,
					CATALOG_ID,
					NUMBER_OF_INSTALLMENT,
					DUE_DATE,
					KARMA_PRODUCT_ID,
					OTV_ORAN,
					OTVTOTAL,
					SERVICE_ID,
					WRK_ROW_ID,
					WRK_ROW_RELATION_ID,
					RELATED_ACTION_ID,
					RELATED_ACTION_TABLE,
					WIDTH_VALUE,
					DEPTH_VALUE,
					HEIGHT_VALUE,
					ROW_PROJECT_ID,
					ROW_PAYMETHOD_ID,
					ROW_WORK_ID,
					REASON_CODE,
					REASON_NAME,
					ACTIVITY_TYPE_ID,
					GTIP_NUMBER
					<cfif isdefined('attributes.row_weight#i#') and len(evaluate("attributes.row_weight#i#"))>,WEIGHT</cfif>
					<cfif isdefined('attributes.row_specific_weight#i#') and len(evaluate("attributes.row_specific_weight#i#"))>,SPECIFIC_WEIGHT</cfif>
					<cfif isdefined('attributes.row_volume#i#') and len(evaluate("attributes.row_volume#i#"))>,VOLUME</cfif>
				)
				VALUES
				(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#left(evaluate('attributes.product_name#i#'),250)#">,
					<cfif isdefined("attributes.paymethod_id#i#") and len(evaluate("attributes.paymethod_id#i#"))>#evaluate("attributes.paymethod_id#i#")#,<cfelse>NULL,</cfif>
					#MAX_ID.IDENTITYCOL#,
					#evaluate("attributes.stock_id#i#")#,
					#evaluate("attributes.product_id#i#")#,
					#evaluate("attributes.amount#i#")#,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit#i#')#">,
					#evaluate("attributes.unit_id#i#")#,
					#evaluate("attributes.tax#i#")#,
					<cfif len(evaluate("attributes.price#i#"))>
						#evaluate("attributes.price#i#")#,
					</cfif>
					#indirim1#,
					1,
					#indirim2#,
					#indirim3#,
					#indirim4#,
					#indirim5#,
					#indirim6#,
					#indirim7#,
					#indirim8#,
					#indirim9#,
					#indirim10#,
					#DISCOUNT_AMOUNT#,
					#evaluate("attributes.row_lasttotal#i#")#,
					#evaluate("attributes.row_nettotal#i#")#,
					#evaluate("attributes.row_taxtotal#i#")#,	
					<cfif isdefined("attributes.deliver_date#i#") and len(evaluate('attributes.deliver_date#i#'))>#evaluate('attributes.deliver_date#i#')#<cfelse>NULL</cfif>,				
					<cfif isdefined("attributes.deliver_dept#i#") and len(trim(evaluate("attributes.deliver_dept#i#"))) and len(listfirst(evaluate("attributes.deliver_dept#i#"),"-"))>
						#listfirst(evaluate("attributes.deliver_dept#i#"),"-")#,
					<cfelseif isdefined('attributes.department_id') and len(attributes.department_id)>
						#attributes.department_id#,
					<cfelse>
						NULL,
					</cfif>
					<cfif isdefined("attributes.deliver_dept#i#") and listlen(trim(evaluate("attributes.deliver_dept#i#")),"-") eq 2 and len(listlast(evaluate("attributes.deliver_dept#i#"),"-"))>
						#listlast(evaluate("attributes.deliver_dept#i#"),"-")#,
					<cfelseif isdefined('attributes.location_id') and len(attributes.location_id)>
						#attributes.location_id#,
					<cfelse>
						NULL,
					</cfif>
					<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
						#evaluate('attributes.spect_id#i#')#,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.spect_name#i#')#">,
					</cfif>
					<cfif isdefined('attributes.lot_no#i#') and len(evaluate('attributes.lot_no#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.lot_no#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined('attributes.other_money_#i#')><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.other_money_#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined("attributes.other_money_value_#i#") and len(evaluate("attributes.other_money_value_#i#"))>#evaluate("attributes.other_money_value_#i#")#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.price_other#i#') and len(evaluate('attributes.price_other#i#'))>#evaluate("attributes.price_other#i#")#<cfelse>NULL</cfif>,
					<cfif isdefined("attributes.other_money_gross_total#i#") and len(evaluate("attributes.other_money_gross_total#i#"))>#evaluate("attributes.other_money_gross_total#i#")#,<cfelse>0,</cfif>
					<cfif isdefined('attributes.net_maliyet#i#') and len(evaluate('attributes.net_maliyet#i#'))>#evaluate('attributes.net_maliyet#i#')#<cfelse>0</cfif>,
					<cfif isdefined('attributes.extra_cost#i#') and len(evaluate('attributes.extra_cost#i#'))>#evaluate('attributes.extra_cost#i#')#<cfelse>0</cfif>,
					<cfif isdefined('attributes.iskonto_tutar#i#') and len(evaluate('attributes.iskonto_tutar#i#'))>#evaluate('attributes.iskonto_tutar#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.marj#i#') and len(evaluate('attributes.marj#i#'))>#evaluate('attributes.marj#i#')#<cfelse>NULL</cfif>,
					<cfif len(get_order_amounts.ORDER_ID)>#get_order_amounts.ORDER_ID#<cfelse>NULL</cfif>,
					<cfif listfind('72,78,79',get_process_type.PROCESS_TYPE) and isdefined("attributes.irsaliye_id_listesi") and len(attributes.irsaliye_id_listesi)>
                        <cfif listlen(evaluate("attributes.row_ship_id#i#"),';') eq 2>#listfirst(evaluate("attributes.row_ship_id#i#"),';')#,<cfelse>NULL,</cfif>
                        <cfif listlen(evaluate("attributes.row_ship_id#i#"),';') eq 2>#listlast(evaluate("attributes.row_ship_id#i#"),';')#,<cfelse>NULL,</cfif>
                    </cfif>
					<cfif isdefined('attributes.promosyon_yuzde#i#') and len(evaluate('attributes.promosyon_yuzde#i#'))>#evaluate('attributes.promosyon_yuzde#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.promosyon_maliyet#i#') and len(evaluate('attributes.promosyon_maliyet#i#'))>#evaluate('attributes.promosyon_maliyet#i#')#<cfelse>0</cfif>,
					<cfif isdefined('attributes.row_promotion_id#i#') and len(evaluate('attributes.row_promotion_id#i#'))>#evaluate('attributes.row_promotion_id#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.is_promotion#i#') and len(evaluate('attributes.is_promotion#i#'))>#evaluate('attributes.is_promotion#i#')#<cfelse>0</cfif>,
					<cfif isdefined('attributes.prom_stock_id#i#') and len(evaluate('attributes.prom_stock_id#i#'))>#evaluate('attributes.prom_stock_id#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.is_commission#i#') and len(evaluate('attributes.is_commission#i#'))>#evaluate('attributes.is_commission#i#')#<cfelse>0</cfif>,
					<cfif isdefined('attributes.dara#i#') and len(evaluate('attributes.dara#i#'))>#evaluate('attributes.dara#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.darali#i#') and len(evaluate('attributes.darali#i#'))>#evaluate('attributes.darali#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.row_unique_relation_id#i#') and len(evaluate('attributes.row_unique_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.row_unique_relation_id#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined('attributes.prom_relation_id#i#') and len(evaluate('attributes.prom_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.prom_relation_id#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined('attributes.product_name_other#i#') and len(evaluate('attributes.product_name_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_name_other#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined('attributes.amount_other#i#') and len(evaluate('attributes.amount_other#i#'))>#evaluate('attributes.amount_other#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.unit_other#i#') and len(evaluate('attributes.unit_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit_other#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined('attributes.ek_tutar#i#') and len(evaluate('attributes.ek_tutar#i#'))>#evaluate('attributes.ek_tutar#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.ek_tutar_price#i#') and len(evaluate('attributes.ek_tutar_price#i#'))>#evaluate('attributes.ek_tutar_price#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.ek_tutar_total#i#') and len(evaluate('attributes.ek_tutar_total#i#'))>#evaluate('attributes.ek_tutar_total#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.ek_tutar_other_total#i#') and len(evaluate('attributes.ek_tutar_other_total#i#'))>#evaluate('attributes.ek_tutar_other_total#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.shelf_number#i#') and len(evaluate('attributes.shelf_number#i#'))>#evaluate('attributes.shelf_number#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.to_shelf_number#i#') and len(evaluate('attributes.to_shelf_number#i#'))>#evaluate('attributes.to_shelf_number#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.manufact_code#i#') and len(evaluate('attributes.manufact_code#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.manufact_code#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined('attributes.basket_extra_info#i#') and len(evaluate('attributes.basket_extra_info#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.basket_extra_info#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined('attributes.select_info_extra#i#') and len(evaluate('attributes.select_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.select_info_extra#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined('attributes.detail_info_extra#i#') and len(evaluate('attributes.detail_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.detail_info_extra#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined('attributes.basket_employee_id#i#') and len(evaluate('attributes.basket_employee_id#i#')) and isdefined('attributes.basket_employee#i#') and len(evaluate('attributes.basket_employee#i#'))>#evaluate('attributes.basket_employee_id#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.list_price#i#') and len(evaluate('attributes.list_price#i#'))>#evaluate('attributes.list_price#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.price_cat#i#') and len(evaluate('attributes.price_cat#i#'))>#evaluate('attributes.price_cat#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.row_catalog_id#i#') and len(evaluate('attributes.row_catalog_id#i#'))>#evaluate('attributes.row_catalog_id#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.number_of_installment#i#') and len(evaluate('attributes.number_of_installment#i#'))>#evaluate('attributes.number_of_installment#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined("attributes.duedate#i#") and len(evaluate("attributes.duedate#i#"))>#evaluate("attributes.duedate#i#")#<cfelse>0</cfif>,
					<cfif isdefined('attributes.karma_product_id#i#') and len(evaluate('attributes.karma_product_id#i#'))>#evaluate('attributes.karma_product_id#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.otv_oran#i#') and len(evaluate('attributes.otv_oran#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.otv_oran#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined('attributes.row_otvtotal#i#') and len(evaluate('attributes.row_otvtotal#i#'))>#evaluate('attributes.row_otvtotal#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.row_service_id#i#') and len(evaluate('attributes.row_service_id#i#'))>#evaluate("attributes.row_service_id#i#")#<cfelseif isdefined("attributes.service_id") and listlen(attributes.service_id) eq 1>#attributes.service_id#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.wrk_row_id#i#') and len(evaluate('attributes.wrk_row_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.wrk_row_id#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined('attributes.wrk_row_relation_id#i#') and len(evaluate('attributes.wrk_row_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.wrk_row_relation_id#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined('attributes.related_action_id#i#') and len(evaluate('attributes.related_action_id#i#'))>#evaluate('attributes.related_action_id#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.related_action_table#i#') and len(evaluate('attributes.related_action_table#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.related_action_table#i#')#"><cfelse>NULL</cfif>,
					<cfif isdefined('attributes.row_width#i#') and len(evaluate('attributes.row_width#i#'))>#evaluate('attributes.row_width#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.row_depth#i#') and len(evaluate('attributes.row_depth#i#'))>#evaluate('attributes.row_depth#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.row_height#i#') and len(evaluate('attributes.row_height#i#'))>#evaluate('attributes.row_height#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.row_project_id#i#') and len(evaluate('attributes.row_project_id#i#')) and isdefined('attributes.row_project_name#i#') and len(evaluate('attributes.row_project_name#i#'))>#evaluate('attributes.row_project_id#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.row_paymethod_id#i#') and len(evaluate('attributes.row_paymethod_id#i#'))>#evaluate('attributes.row_paymethod_id#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.row_work_id#i#') and len(evaluate('attributes.row_work_id#i#'))>#evaluate('attributes.row_work_id#i#')#<cfelse>NULL</cfif>,
					<cfif len(reasonCode) and reasonCode contains '*'>
						<cfqueryparam cfsqltype="cf_sql_integer" value="#listfirst(reasonCode,'*')#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#listLast(reasonCode,'*')#">,
					<cfelse>
						NULL,
						NULL,
					</cfif>
					<cfif isdefined('attributes.row_activity_id#i#') and len(evaluate('attributes.row_activity_id#i#'))>#evaluate('attributes.row_activity_id#i#')#<cfelse>NULL</cfif>,
					<cfif isdefined('attributes.gtip_number#i#') and len(evaluate('attributes.gtip_number#i#'))>'#evaluate('attributes.gtip_number#i#')#'<cfelse>NULL</cfif>
					<cfif isdefined('attributes.row_weight#i#') and len(evaluate("attributes.row_weight#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_weight#i#')#"></cfif>
					<cfif isdefined('attributes.row_specific_weight#i#') and len(evaluate("attributes.row_specific_weight#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_specific_weight#i#')#"></cfif>
					<cfif isdefined('attributes.row_volume#i#') and len(evaluate("attributes.row_volume#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_volume#i#')#"></cfif>
				)
			</cfquery>
            <cfif get_process_type.is_stock_action eq 1><!--- Stok hareketi yapılsın --->
            	<cfinclude template="../../../../v16/stock/query/get_unit_add_fis.cfm">
				<cfif get_unit.recordcount and len(get_unit.multiplier)>
					<cfset multi=get_unit.multiplier*evaluate("attributes.amount#i#")>
				<cfelse>
					<cfset multi=evaluate("attributes.amount#i#")>
				</cfif>
				<cfset form_spect_main_id="">
				<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
					<cfset form_spect_id="#evaluate('attributes.spect_id#i#')#">
					<cfif len(form_spect_id) and len(form_spect_id)>
						<cfquery name="GET_MAIN_SPECT" datasource="#new_dsn2#">
							SELECT SPECT_MAIN_ID FROM #dsn3_alias#.SPECTS WHERE SPECT_VAR_ID=#form_spect_id#
						</cfquery>
						<cfif GET_MAIN_SPECT.RECORDCOUNT>
							<cfset form_spect_main_id=GET_MAIN_SPECT.SPECT_MAIN_ID>
						</cfif>
					</cfif>
				</cfif>
             	<cfquery name="GET_KARMA_PRODUCTS" datasource="#dsn2#"><!--- karma koli olan ürünler --->
					SELECT PRODUCT_ID FROM #dsn3_alias#.PRODUCT WHERE PRODUCT_ID IN (#evaluate("attributes.product_id#i#")#) AND IS_KARMA = 1
				</cfquery>
                <cfif GET_KARMA_PRODUCTS.recordcount>
                	<cfquery name="GET_KARMA_PRODUCT" datasource="#dsn2#">
                    	SELECT PRODUCT_ID,STOCK_ID,SPEC_MAIN_ID,PRODUCT_AMOUNT FROM #dsn1_alias#.KARMA_PRODUCTS WHERE KARMA_PRODUCT_ID =#evaluate("attributes.product_id#i#")#
                 	</cfquery>

            		<cfif GET_KARMA_PRODUCT.recordcount>
            			<cfloop query="GET_KARMA_PRODUCT">
                       		<cfif len(GET_KARMA_PRODUCT.SPEC_MAIN_ID)><!--- karma koli satırındaki urun için spec seçilmisse, hem o ürün hem de sevkte birleştirilen urunleri için stok hareketi yazılır --->
                           		<cfquery name="GET_SPEC_PRODUCT" datasource="#dsn2#">
                                  	SELECT 
                                   		PRODUCT_ID,
                                     	STOCK_ID,
                                     	AMOUNT,
                                   		RELATED_MAIN_SPECT_ID
                                 	FROM
                                     	#dsn3_alias#.SPECT_MAIN_ROW
                                 	WHERE
                                      	IS_SEVK = 1 AND
                                     	STOCK_ID IS NOT NULL AND
                                    	PRODUCT_ID IS NOT NULL AND
                                   		SPECT_MAIN_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_KARMA_PRODUCT.SPEC_MAIN_ID#">
                           		</cfquery>

                                <cfif GET_SPEC_PRODUCT.recordcount>
                                	<cfloop query="GET_SPEC_PRODUCT">
                                	 	<cfquery name="ADD_STOCK_ROW" datasource="#dsn2#">
                                	     	INSERT INTO 
                                	       		#dsn2_alias#.STOCKS_ROW
                                	            (
                                	                UPD_ID,
                                	                PRODUCT_ID,
                                	                STOCK_ID,
                                	                PROCESS_TYPE,
                                	                STOCK_OUT,
                                	                STORE,
                                	                STORE_LOCATION,
                                	                PROCESS_DATE,
													PROCESS_TIME,
                                	                <cfif isdefined('form_spect_id') and len(form_spect_id)>
                                	                    SPECT_VAR_ID,
                                	                </cfif>
                                	                AMOUNT2,
                                	                UNIT2,
                                	                DELIVER_DATE,
                                	                SHELF_NUMBER,
                                	                DEPTH_VALUE,
                                	                WIDTH_VALUE,
                                	                HEIGHT_VALUE
                                	            )
                                	  		VALUES
                                	            (
                                	                #MAX_ID.IDENTITYCOL#,
                                	                #GET_SPEC_PRODUCT.product_id#,
                                	                #GET_SPEC_PRODUCT.stock_id#,
                                	                #get_process_type.process_type#,
                                	                #multi*GET_SPEC_PRODUCT.product_amount#,
                                	                #attributes.department_id#,
                                	                #attributes.location_id#,
                                	                #attributes.ship_date#,
													#attributes.deliver_date_frm#,
                                	                <cfif isdefined('form_spect_id') and len(form_spect_id)>
                                	                    <cfif len(GET_SPEC_PRODUCT.RELATED_MAIN_SPECT_ID)>#GET_KARMA_PRODUCT.RELATED_MAIN_SPECT_ID#<cfelse>NULL</cfif>,
                                	                </cfif>
                                	                <cfif isdefined('attributes.amount_other#i#') and len(evaluate('attributes.amount_other#i#'))>#evaluate('attributes.amount_other#i#')#<cfelse>NULL</cfif>,
                                	                <cfif isdefined('attributes.unit_other#i#') and len(evaluate('attributes.unit_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit_other#i#')#"><cfelse>NULL</cfif>,
                                	                <cfif isdefined('attributes.deliver_date#i#') and isdate(evaluate('attributes.deliver_date#i#'))>#evaluate('attributes.deliver_date#i#')#<cfelse>NULL</cfif>,
                                	                <cfif isdefined('attributes.shelf_number#i#') and len(evaluate('attributes.shelf_number#i#'))>#evaluate('attributes.shelf_number#i#')#<cfelse>NULL</cfif>,
                                	                <cfif isdefined('attributes.row_depth#i#') and len(evaluate('attributes.row_depth#i#'))>#evaluate('attributes.row_depth#i#')#<cfelse>NULL</cfif>,
                                	                <cfif isdefined('attributes.row_width#i#') and len(evaluate('attributes.row_width#i#'))>#evaluate('attributes.row_width#i#')#<cfelse>NULL</cfif>,
                                	                <cfif isdefined('attributes.row_height#i#') and len(evaluate('attributes.row_height#i#'))>#evaluate('attributes.row_height#i#')#<cfelse>NULL</cfif>
                                	            )
                                	    </cfquery>
                                	</cfloop>
                      			</cfif>
                            </cfif>
                            <cfquery name="ADD_STOCK_ROW" datasource="#dsn2#">
                        		INSERT INTO 
                               		#dsn2_alias#.STOCKS_ROW
                               		(
                                   		UPD_ID,
                                   		PRODUCT_ID,
                                   		STOCK_ID,
                                   		PROCESS_TYPE,
                                   		STOCK_OUT,
                                   		STORE,
                                   		STORE_LOCATION,
                                   		PROCESS_DATE,
										PROCESS_TIME,
                                  		SPECT_VAR_ID,
                                   		AMOUNT2,
                                   		UNIT2,
                                   		DELIVER_DATE,
                                   		SHELF_NUMBER,
                                   		DEPTH_VALUE,
                                   		WIDTH_VALUE,
                                   		HEIGHT_VALUE
                                  	)
                            	VALUES
                               		(
                                   		#MAX_ID.IDENTITYCOL#,
                                   		#GET_KARMA_PRODUCT.product_id#,
                                    	#GET_KARMA_PRODUCT.stock_id#,
                                   		#get_process_type.process_type#,
                                   		#multi*GET_KARMA_PRODUCT.product_amount#,
                                   		#attributes.department_id#,
                                   		#attributes.location_id#,
                                   		#attributes.ship_date#,
										#attributes.deliver_date_frm#,
                                 		<cfif len(GET_KARMA_PRODUCT.SPEC_MAIN_ID)>#GET_KARMA_PRODUCT.SPEC_MAIN_ID#<cfelse>NULL</cfif>,
                                   		<cfif isdefined('attributes.amount_other#i#') and len(evaluate('attributes.amount_other#i#'))>#evaluate('attributes.amount_other#i#')#<cfelse>NULL</cfif>,
                                   		<cfif isdefined('attributes.unit_other#i#') and len(evaluate('attributes.unit_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit_other#i#')#"><cfelse>NULL</cfif>,
                                   		<cfif isdefined('attributes.deliver_date#i#') and isdate(evaluate('attributes.deliver_date#i#'))>#evaluate('attributes.deliver_date#i#')#<cfelse>NULL</cfif>,
                                   		<cfif isdefined('attributes.shelf_number#i#') and len(evaluate('attributes.shelf_number#i#'))>#evaluate('attributes.shelf_number#i#')#<cfelse>NULL</cfif>,
                                   		<cfif isdefined('attributes.row_depth#i#') and len(evaluate('attributes.row_depth#i#'))>#evaluate('attributes.row_depth#i#')#<cfelse>NULL</cfif>,
                                   		<cfif isdefined('attributes.row_width#i#') and len(evaluate('attributes.row_width#i#'))>#evaluate('attributes.row_width#i#')#<cfelse>NULL</cfif>,
                                   		<cfif isdefined('attributes.row_height#i#') and len(evaluate('attributes.row_height#i#'))>#evaluate('attributes.row_height#i#')#<cfelse>NULL</cfif>
                                  	)
							</cfquery>
                       	</cfloop>
           			</cfif>
            	<cfelse>       
                 	<cfquery name="ADD_STOCK_ROW" datasource="#dsn2#">
                    	INSERT INTO 
                         	#dsn2_alias#.STOCKS_ROW
                       		(
                           	 	UPD_ID,
                           	 	PRODUCT_ID,
                           	 	STOCK_ID,
                           	 	PROCESS_TYPE,
                           	 	STOCK_OUT,
                           	 	STORE,
                           	 	STORE_LOCATION,
                           	 	PROCESS_DATE,
                           	 	PROCESS_TIME,
                           	 	<cfif isdefined('form_spect_main_id') and len(form_spect_main_id)>
                           	 	    SPECT_VAR_ID,
                           	 	</cfif>
                           	 	LOT_NO,
                           	 	PRODUCT_MANUFACT_CODE,				
                           	 	AMOUNT2,
                           	 	UNIT2,
                           	 	DELIVER_DATE,
                           	 	SHELF_NUMBER,
                           	 	DEPTH_VALUE,
                           	 	WIDTH_VALUE,
                           	 	HEIGHT_VALUE
                        	)
                   		VALUES
                      		(
                           	 	#MAX_ID.IDENTITYCOL#,
                           	 	#evaluate("attributes.product_id#i#")#,
                           	 	#evaluate("attributes.stock_id#i#")#,
                           	 	#get_process_type.process_type#,
                           	 	#multi#,
                           	 	#attributes.department_id#,
                           	 	#attributes.location_id#,
                           	 	#attributes.ship_date#,
                           	 	#attributes.deliver_date_frm#,
                           	 	<cfif isdefined('form_spect_main_id') and len(form_spect_main_id)>
                           	 	    #form_spect_main_id#,
                           	 	</cfif>
                           	 	<cfif isdefined('attributes.lot_no#i#') and len(evaluate('attributes.lot_no#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.lot_no#i#')#"><cfelse>NULL</cfif>,
                           	 	<cfif isdefined('attributes.manufact_code#i#') and len(evaluate('attributes.manufact_code#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.manufact_code#i#')#"><cfelse>NULL</cfif>,
                           	 	<cfif isdefined('attributes.amount_other#i#') and len(evaluate('attributes.amount_other#i#'))>#evaluate('attributes.amount_other#i#')#<cfelse>NULL</cfif>,
                           	 	<cfif isdefined('attributes.unit_other#i#') and len(evaluate('attributes.unit_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit_other#i#')#"><cfelse>NULL</cfif>,
                           	 	<cfif isdefined('attributes.deliver_date#i#') and isdate(evaluate('attributes.deliver_date#i#'))>#evaluate('attributes.deliver_date#i#')#<cfelse>NULL</cfif>,
                           	 	<cfif isdefined('attributes.shelf_number#i#') and len(evaluate('attributes.shelf_number#i#'))>#evaluate('attributes.shelf_number#i#')#<cfelse>NULL</cfif>,
                           	 	<cfif isdefined('attributes.row_depth#i#') and len(evaluate('attributes.row_depth#i#'))>#evaluate('attributes.row_depth#i#')#<cfelse>NULL</cfif>,
                           	 	<cfif isdefined('attributes.row_width#i#') and len(evaluate('attributes.row_width#i#'))>#evaluate('attributes.row_width#i#')#<cfelse>NULL</cfif>,
                           	 	<cfif isdefined('attributes.row_height#i#') and len(evaluate('attributes.row_height#i#'))>#evaluate('attributes.row_height#i#')#<cfelse>NULL</cfif>
                         	)
                    </cfquery>
             	</cfif>			
            </cfif>
            
            <!---SİPARİŞ SATIR bilgilerini güncelliyorum--->
            <cfquery name="UPD_ORD_ROW" datasource="#dsn2#">
				UPDATE 
					#dsn3_alias#.ORDER_ROW 
				SET 
					ORDER_ROW_CURRENCY = -3,
					DELIVER_AMOUNT = #get_order_amounts.QUANTITY#,
                    RESERVE_TYPE = -4
				WHERE
					ORDER_ID = #get_order_amounts.ORDER_ID# AND
					ORDER_ROW_ID = #get_order_amounts.ORDER_ROW_ID#
			</cfquery>
            <!---SİPARİŞ SATIR rezerve dosyasına kayıt ekliyorum--->
            <cfquery name="add_order_row_reserved" datasource="#dsn2#">
            	INSERT INTO
					#dsn3_alias#.ORDER_ROW_RESERVED
					(
						STOCK_ID,
						PRODUCT_ID,
						DEPARTMENT_ID,
						LOCATION_ID,
						ORDER_ID,
						ORDER_WRK_ROW_ID,
						SHIP_ID,
						PERIOD_ID,
						STOCK_OUT, 
						SHELF_NUMBER		
					)
				VALUES
					(
						#evaluate("attributes.stock_id#i#")#,
						#evaluate("attributes.product_id#i#")#,
						#attributes.department_id#,
                    	#attributes.location_id#,
						#get_order_amounts.ORDER_ID#,
						'#evaluate('attributes.wrk_row_relation_id#i#')#', 
						#MAX_ID.IDENTITYCOL#,
						#session.ep.period_id#,
						#get_order_amounts.QUANTITY#,
						NULL
					)
         	</cfquery>
		</cfloop>
        <cfloop list="#attributes.order_id_listesi#" index="order_ind_">
        	<!---ORDERS_SHIP tablosuna kayıt ekliyorum--->
        	<cfquery name="add_orders_ship" datasource="#dsn2#">
				INSERT INTO
					#dsn3_alias#.ORDERS_SHIP
					(
						ORDER_ID,
						SHIP_ID,
						PERIOD_ID
					)
				VALUES
					(
						#order_ind_#,
						#MAX_ID.IDENTITYCOL#,
						#session.ep.period_id#
					)
			</cfquery>
            <!---SİPARİŞ DURUM BİLGİSİNİ ÇEKİYORUM--->
            <cfquery name="get_relation_document_control" datasource="#dsn2#" maxrows="1">
				SELECT ORDER_ID FROM #dsn3_alias#.ORDERS_SHIP WHERE ORDER_ID = #order_ind_#
				UNION ALL
				SELECT ORDER_ID FROM #dsn3_alias#.ORDERS_INVOICE WHERE ORDER_ID = #order_ind_#
			</cfquery>
			<cfif get_relation_document_control.recordcount>
				<cfset order_process_flag = 1>
			<cfelse>
				<cfset order_process_flag = 0>
			</cfif>
            <!---SİPARİŞİN SATIRLARINDA REZERVE SATIR KALDI MI--->
            <cfquery name="GET_ORD_ROW_RESERVE_CONTROL" datasource="#dsn2#">
            	SELECT
                	ORDER_ROW_ID
              	FROM
                	#dsn3_alias#.ORDER_ROW
              	WHERE
                	ORDER_ID = #order_ind_# AND
                    NOT (RESERVE_TYPE = -4 OR RESERVE_TYPE = -3) <!---Rezerve Kapatıldı ve Rezerve değil ise--->
            </cfquery>
            <cfif GET_ORD_ROW_RESERVE_CONTROL.recordcount>
            	<cfset paper_general_reserve_type = 1>
            <cfelse>
            	<cfset paper_general_reserve_type = 0>
            </cfif>
            <!---SİPARİŞİN BİLGİLERİ GÜNCELLENİYOR--->
            <cfquery name="UPD_ORD" datasource="#dsn2#">
             	UPDATE 
                 	#dsn3_alias#.ORDERS 
          		SET 
                	IS_PROCESSED = #order_process_flag#,
                	RESERVED = #paper_general_reserve_type#
            	WHERE 
                	ORDER_ID = #order_ind_#
            </cfquery>
		</cfloop>
		<!---demirbaş ekleme islemleri --->
		<cfset row_ship_id = MAX_ID.IDENTITYCOL>
		<cfif get_process_type.is_add_inventory eq 1>
			<cfinclude template="../../../../v16/stock/query/add_inventory.cfm">
		</cfif>
		<cfif listgetat(attributes.fuseaction,1,'.') is 'service'>
			<cfset new_fuse_ = "service.popup_upd_sale_ship">
		<cfelse>
			<cfset new_fuse_ = "#listgetat(attributes.fuseaction,1,'.')#.form_add_sale&event=upd">
		</cfif>
		<!---Ek Bilgiler--->
		<cfset attributes.info_id = max_id.IDENTITYCOL>
		<cfset attributes.is_upd = 0>
		<cfset attributes.info_type_id = -31>
		<cfinclude template="../../../../v16/objects/query/add_info_plus2.cfm">
		<!---Ek Bilgiler--->
		<cf_workcube_process_cat 
			process_cat="#form.process_cat#"
			action_id = "#MAX_ID.IDENTITYCOL#"
			action_table="SHIP"
			action_column="SHIP_ID"
			is_action_file = 1
			action_file_name='#get_process_type.action_file_name#'
			action_page='#request.self#?fuseaction=#new_fuse_#&ship_id=#MAX_ID.IDENTITYCOL#'
			action_db_type = '#new_dsn2_group#'
			is_template_action_file = '#get_process_type.action_file_from_template#'>
		<cfset last_ship_id_sale = MAX_ID.IDENTITYCOL>
		<cfif not isdefined("first_ship_id")>
			<cfset first_ship_id = MAX_ID.IDENTITYCOL>
		</cfif>
		<cf_add_log employee_id="#session.ep.userid#" log_type="1" action_id="#MAX_ID.IDENTITYCOL#" action_name="#attributes.SHIP_NUMBER# Eklendi" paper_no="#attributes.SHIP_NUMBER#" period_id="#session.ep.period_id#" process_type="#get_process_type.PROCESS_TYPE#" data_source="#new_dsn2_group#">
	</cftransaction>
</cflock>
<cfif isdefined("attributes.process_stage") and len(attributes.process_stage)>
	<cf_workcube_process 
			is_upd='1' 
			data_source='#new_dsn2_group#' 
			old_process_line='0'
			process_stage='#attributes.process_stage#' 
			record_member='#session.ep.userid#' 
			record_date='#now()#'
			action_table='SHIP'
			action_column='SHIP_ID'
			action_id='#MAX_ID.IDENTITYCOL#'
			action_page='#request.self#?fuseaction=stock.form_add_sale&event=upd&SHIP_ID=#MAX_ID.IDENTITYCOL#'
			warning_description='Satış İrsaliyesi : #attributes.SHIP_NUMBER#'>
</cfif>	
<cfif len(attributes.paper_number)>
	<cfquery name="UPD_PAPERS" datasource="#new_dsn2_group#">
		UPDATE 
			#new_dsn3_group#.PAPERS_NO 
		SET 
			SHIP_NUMBER = #attributes.paper_number# 
		WHERE 
		<cfif isdefined('attributes.paper_printer_id') and len(attributes.paper_printer_id)>
			PRINTER_ID = #attributes.paper_printer_id#
		<cfelse>
			EMPLOYEE_ID = #SESSION.EP.USERID#
		</cfif>
	</cfquery>
</cfif>

<cf_get_lang_set module_name="stock"> <!--- sayfanin en ustunde acilisi var --->

