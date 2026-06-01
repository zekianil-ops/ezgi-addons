<!---
    File: upd_ezgi_virtual_offer.cfm
    Folder: Add_Ons\ezgi\e_sales\query
    Author: Ezgi Yazılım
    Date: 01/01/2022
    Description:
--->
<cf_date tarih="attributes.virtual_offer_date">
<cf_date tarih="attributes.deliverdate">
<cf_date tarih="attributes.finishdate">
<cfif len(attributes.BASKET_DUE_VALUE_DATE_)>
	<cf_date tarih="attributes.BASKET_DUE_VALUE_DATE_">
</cfif>
<cfif len(attributes.sales_member)>
    <cfquery name="get_company_id" datasource="#dsn#">
        SELECT COMPANY_ID FROM COMPANY_PARTNER WHERE PARTNER_ID = #attributes.sales_member_id#
    </cfquery>
</cfif>
<cfquery name="get_v_o" datasource="#dsn3#">
	SELECT VIRTUAL_OFFER_NUMBER FROM EZGI_VIRTUAL_OFFER WHERE VIRTUAL_OFFER_ID = #attributes.VIRTUAL_OFFER_id#
</cfquery>
<cflock name="#CREATEUUID()#" timeout="90">
    <cftransaction>
        <cfif attributes.record_num gt 0>
        	<cfinclude template="upd_ezgi_virtual_offer_include.cfm">
            <cfquery name="upd_virtual_offer" datasource="#dsn3#">
            	UPDATE
                    EZGI_VIRTUAL_OFFER
              	SET
                	IS_CANCEL = <cfif isdefined('attributes.is_cancel') and len(attributes.is_cancel)>1<cfelse>0</cfif>,
                    CANCEL_ID = <cfif isdefined('attributes.is_cancel') and len(attributes.cancel_id)>#attributes.cancel_id#<cfelse>NULL</cfif>,
                    VIRTUAL_OFFER_DETAIL= <cfif len(attributes.detail)>'#attributes.detail#'<cfelse>NULL</cfif>, 
                    VIRTUAL_OFFER_DATE= <cfif len(attributes.VIRTUAL_OFFER_date)>#attributes.VIRTUAL_OFFER_date#<cfelse>NULL</cfif>, 
                    VIRTUAL_OFFER_STAGE= <cfif len(attributes.process_stage)>#attributes.process_stage#<cfelse>NULL</cfif>,
                    VIRTUAL_OFFER_STATUS= <cfif isdefined('attributes.VIRTUAL_OFFER_status') and len(attributes.VIRTUAL_OFFER_status)>1<cfelse>0</cfif>,
                    VIRTUAL_OFFER_HEAD= <cfif len(attributes.VIRTUAL_OFFER_head)>'#attributes.VIRTUAL_OFFER_head#'<cfelse>NULL</cfif>, 
                    PURCHASE_SALES= 0, 
                    <cfif len(attributes.company_id)>
                    	COMPANY_ID= #attributes.company_id#,
                    	PARTNER_ID= #attributes.partner_id#,
                        CONSUMER_ID= NULL,
                 	<cfelseif len(attributes.consumer_id)>
                       	COMPANY_ID= NULL,
                    	PARTNER_ID= NULL,
                       	CONSUMER_ID= #attributes.consumer_id#,
                   	</cfif>
                    <cfif isdefined('attributes.priority_id')>PRIORITY_ID= #attributes.priority_id#,</cfif>
                    MEMBER_TYPE= '#attributes.member_type#', 
                    PROJECT_ID= <cfif len(attributes.project_head)>#attributes.project_id#<cfelse>NULL</cfif>, 
                    DELIVERDATE= <cfif len(attributes.deliverdate)>#attributes.deliverdate#<cfelse>NULL</cfif>, 
 		    		FINISHDATE = <cfif len(attributes.finishdate)>#attributes.finishdate#<cfelse>NULL</cfif>,	
                    DUE_DATE= <cfif len(attributes.BASKET_DUE_VALUE_DATE_)>#attributes.BASKET_DUE_VALUE_DATE_#<cfelse>NULL</cfif>,
                    DUE_VALUE= <cfif len(attributes.basket_due_value)>#attributes.basket_due_value#<cfelse>NULL</cfif>,
                    REF_NO= <cfif len(attributes.Ref_No)>'#attributes.Ref_No#'<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.sub_total_brut') and len(attributes.sub_total_brut)>
                    	GROSSTOTAL = #FilterNum(attributes.sub_total_brut,2)#,
                   	</cfif>
                  	<cfif isdefined('attributes.sub_total_end') and len(attributes.sub_total_end)>
                    	NETTOTAL = #FilterNum(attributes.sub_total_end,2)#,
                   	</cfif>
                 	<cfif isdefined('attributes.sub_total_discount') and len(attributes.sub_total_discount)>
                    	DISCOUNTTOTAL = #FilterNum(attributes.sub_total_discount,2)#,
                  	</cfif>
                 	<cfif isdefined('attributes.sub_total_tax') and len(attributes.sub_total_tax)>
                    	TAXTOTAL = #FilterNum(attributes.sub_total_tax,2)#,
                  	</cfif>
                    <cfif isdefined('attributes.sub_total_discount_ext') and len(attributes.sub_total_discount_ext)>
                    	SUB_DISCOUNTTOTAL = #FilterNum(attributes.sub_total_discount_ext,2)#,
                  	</cfif>
                    <cfif isdefined('attributes.branch_id')>
                    	BRANCH_ID = <cfif len(attributes.branch_id)>#ListGetAt(attributes.branch_id,1)#<cfelse>NULL</cfif>,
                    </cfif>
                  	PARTNER_COMPANY_ID = <cfif len(attributes.sales_member)>#attributes.sales_member_id#<cfelse>NULL</cfif>,
                    SALES_COMPANY_ID = <cfif len(attributes.sales_member)>#get_company_id.COMPANY_ID#<cfelse>NULL</cfif>,
                    PAYMETHOD = <cfif len(attributes.paymethod) and len(attributes.paymethod_id)>#attributes.paymethod_id#<cfelse>NULL</cfif>,
                    SHIP_METHOD = <cfif len(attributes.ship_method_name)>#attributes.ship_method_id#<cfelse>NULL</cfif>,
                    IS_COST_DISCOUNT = <cfif isdefined('attributes.is_cost_discount') and len(attributes.is_cost_discount)>1<cfelse>0</cfif>,
                  	IS_FOREIGN = <cfif isdefined('attributes.is_foreign') and len(attributes.is_foreign)>1<cfelse>0</cfif>,
                    VIRTUAL_OFFER_EMPLOYEE_ID = <cfif len(attributes.order_employee) and len(attributes.order_employee_id)>#attributes.order_employee_id#<cfelse>NULL</cfif>,
                    SHIP_ADDRESS_ID = <cfif len(attributes.ship_address) and len(attributes.ship_address_id)>#attributes.ship_address_id#<cfelse>NULL</cfif>,
                    SHIP_ADDRESS = <cfif len(attributes.ship_address)>'#attributes.ship_address#'<cfelse>NULL</cfif>,
                    DELIVER_DEPT_ID = <cfif len(attributes.deliver_dept_name) and len(attributes.deliver_dept_id)>#attributes.deliver_dept_id#<cfelse>NULL</cfif>,
                    LOCATION_ID = <cfif len(attributes.deliver_dept_name) and len(attributes.deliver_loc_id)>#attributes.deliver_loc_id#<cfelse>NULL</cfif>,
                    UPDATE_DATE= #now()#, 
                    UPDATE_EMP= #session.ep.userid#,
                    UPDATE_IP = '#cgi.remote_addr#'
				WHERE 
                	VIRTUAL_OFFER_ID = #attributes.VIRTUAL_OFFER_id#
       		</cfquery>
            <cfquery name="del_VIRTUAL_OFFER_row" datasource="#dsn3#">
            	DELETE FROM EZGI_VIRTUAL_OFFER_ROW WHERE VIRTUAL_OFFER_ID = #attributes.VIRTUAL_OFFER_id#
            </cfquery>
            <cfloop from="1" to="#attributes.record_num#" index="i">
            	<cfif isdefined('attributes.row_kontrol#i#') and Evaluate('attributes.row_kontrol#i#') gt 0>
                    <cfquery name="add_VIRTUAL_OFFER_row" datasource="#dsn3#">
                    	INSERT INTO 
                    		EZGI_VIRTUAL_OFFER_ROW
                         	(
                            	VIRTUAL_OFFER_ID, 
                                SORT_NO,
                                IS_STANDART, 
                                PRODUCT_ID,
                                STOCK_ID,
                                PRODUCT_NAME, 
                                STOCK_CODE,
                                QUANTITY, 
                                UNIT, 
                                VIRTUAL_OFFER_ROW_CURRENCY, 
                                PRODUCT_NAME2,
                                EZGI_ID,
                                PRICE,
                                OTHER_MONEY,
                                DISCOUNT_1,
                                DISCOUNT_2,
                                DISCOUNT_3,
                                DISCOUNT_COST,
                                COST,
                                BOY,
                                EN,
                                DERINLIK,
								YON,
                                PRODUCT_CODE_2,
                                TAX,
                                WRK_ROW_RELATION_ID,
                            	PURCHASE_PRICE, 
                                PURCHASE_PRICE_MONEY, 
                                COST_PRICE, 
                                COST_PRICE_MONEY,
                                P_PURCHASE_PRICE, 
                                P_PURCHASE_PRICE_MONEY, 
                                P_DISCOUNT_1, 
                                P_DISCOUNT_2, 
                                P_DISCOUNT_3, 
                                P_DISCOUNT_4, 
                                P_DISCOUNT_5,
                                PRICE_CAT_ID,
                                VIRTUAL_OFFER_IMPORT_ROW_ID
                         	)
						VALUES        
                        	(
                            	#attributes.VIRTUAL_OFFER_id#,
                                #i#,
                            	1,
                            	<cfif len(Evaluate('attributes.product_id#i#'))>#Evaluate('attributes.product_id#i#')#<cfelse>NULL</cfif>,
                                <cfif len(Evaluate('attributes.stock_id#i#'))>#Evaluate('attributes.stock_id#i#')#<cfelse>NULL</cfif>,
                                <cfif len(Evaluate('attributes.product_name#i#'))>'#Evaluate('attributes.product_name#i#')#'<cfelse>NULL</cfif>,
                                <cfif len(Evaluate('attributes.product_code#i#'))>'#Evaluate('attributes.product_code#i#')#'<cfelse>NULL</cfif>,
                                #FilterNum(Evaluate('attributes.quantity#i#'),2)#,
                                '#Evaluate('attributes.main_unit#i#')#',
                                #Evaluate('attributes.currency#i#')#,
                                '#Evaluate('attributes.detail#i#')#',
                                <cfif isdefined('attributes.ezgi_id#i#')>
                                	#Evaluate('attributes.ezgi_id#i#')#,
                              	<cfelse>
                                	NULL,
                                </cfif>
                                #FilterNum(Evaluate('attributes.sales_price#i#'),2)#,
                                '#Evaluate('attributes.money#i#')#',
                            	#FilterNum(Evaluate('attributes.discount1_#i#'),2)#,
                                #FilterNum(Evaluate('attributes.discount2_#i#'),2)#,
                                #FilterNum(Evaluate('attributes.discount3_#i#'),2)#,
                                #FilterNum(Evaluate('attributes.discount_tut#i#'),4)#,
                                #FilterNum(Evaluate('attributes.cost#i#'),2)#,
                                #Evaluate('attributes.boy#i#')#,
                                #Evaluate('attributes.en#i#')#,
                                #Evaluate('attributes.derinlik#i#')#,
								<cfif isdefined('attributes.yon#i#') and len(Evaluate('attributes.yon#i#'))>#Evaluate('attributes.yon#i#')#<cfelse>NULL</cfif>,
                                '#Evaluate('attributes.special_code#i#')#',
                                #Evaluate('attributes.tax#i#')#,
                                <cfif isdefined('attributes.WRK_ROW_RELATION_ID_#i#') and len(Evaluate('attributes.WRK_ROW_RELATION_ID_#i#'))>'#Evaluate('attributes.WRK_ROW_RELATION_ID_#i#')#'<cfelse>NULL</cfif>,
                                <cfif isdefined('attributes.purchase_price#i#')>#FilterNum(Evaluate('attributes.purchase_price#i#'),2)#<cfelse>0</cfif>,
                                <cfif isdefined('attributes.purchase_price_money#i#')>'#Evaluate('attributes.purchase_price_money#i#')#'<cfelse>'#session.ep.money#'</cfif>,
                                <cfif isdefined('attributes.cost_price#i#')>#FilterNum(Evaluate('attributes.cost_price#i#'),2)#<cfelse>0</cfif>,
                                <cfif isdefined('attributes.cost_price_money#i#')>'#Evaluate('attributes.cost_price_money#i#')#'<cfelse>'#session.ep.money#'</cfif>,
                                <cfif isdefined('attributes.p_purchase_price#i#') and len(Evaluate('attributes.p_purchase_price#i#'))>#FilterNum(Evaluate('attributes.p_purchase_price#i#'),2)#<cfelse>0</cfif>,
                                <cfif isdefined('attributes.p_purchase_price_money#i#') and len(Evaluate('attributes.p_purchase_price_money#i#'))>'#Evaluate('attributes.p_purchase_price_money#i#')#'<cfelse>'#session.ep.money#'</cfif>,
                                <cfif isdefined('attributes.p_discount_1_#i#') and len(Evaluate('attributes.p_discount_1_#i#'))>#FilterNum(Evaluate('attributes.p_discount_1_#i#'),2)#<cfelse>0</cfif>,
                                <cfif isdefined('attributes.p_discount_2_#i#') and len(Evaluate('attributes.p_discount_2_#i#'))>#FilterNum(Evaluate('attributes.p_discount_2_#i#'),2)#<cfelse>0</cfif>,
                                <cfif isdefined('attributes.p_discount_3_#i#') and len(Evaluate('attributes.p_discount_3_#i#'))>#FilterNum(Evaluate('attributes.p_discount_3_#i#'),2)#<cfelse>0</cfif>,
                                <cfif isdefined('attributes.p_discount_4_#i#') and len(Evaluate('attributes.p_discount_4_#i#'))>#FilterNum(Evaluate('attributes.p_discount_4_#i#'),2)#<cfelse>0</cfif>,
                                <cfif isdefined('attributes.p_discount_5_#i#') and len(Evaluate('attributes.p_discount_5_#i#'))>#FilterNum(Evaluate('attributes.p_discount_5_#i#'),2)#<cfelse>0</cfif>,
                                #Evaluate('attributes.price_cat_id#i#')#,
                                <cfif isdefined('attributes.virtual_offer_import_row_id#i#') and len(Evaluate('attributes.virtual_offer_import_row_id#i#'))>#Evaluate('attributes.virtual_offer_import_row_id#i#')#<cfelse>NULL</cfif>
                            )
                    </cfquery>
                    <cfquery name="upd_ezgi_id" datasource="#dsn3#">
                    	UPDATE EZGI_VIRTUAL_OFFER_ROW SET EZGI_ID = VIRTUAL_OFFER_ROW_ID WHERE VIRTUAL_OFFER_ID = #attributes.VIRTUAL_OFFER_id# AND EZGI_ID IS NULL
                    </cfquery>
                    <cfif isdefined('attributes.virtual_offer_import_row_id#i#') and len(Evaluate('attributes.virtual_offer_import_row_id#i#'))>
                        <cfquery name="get_import_row_image" datasource="#dsn3#">
                            SELECT TOP 1
                                EVOR.EZGI_ID,
                                PRI.IMAGE_NAME,
                                PRI.IMAGE_PATH
                            FROM
                                EZGI_VIRTUAL_OFFER_ROW EVOR INNER JOIN
                                EZGI_VIRTUAL_OFFER_ROW_PRE_IMPORT PRI ON PRI.VIRTUAL_OFFER_ROW_ID = EVOR.VIRTUAL_OFFER_IMPORT_ROW_ID
                            WHERE
                                EVOR.VIRTUAL_OFFER_ID = #attributes.VIRTUAL_OFFER_id#
                                AND EVOR.SORT_NO = #i#
                                AND EVOR.VIRTUAL_OFFER_IMPORT_ROW_ID = #Evaluate('attributes.virtual_offer_import_row_id#i#')#
                                AND ISNULL(LTRIM(RTRIM(PRI.IMAGE_PATH)),'') <> ''
                        </cfquery>
                        <cfif get_import_row_image.recordcount>
                            <cfset import_image_file_name = trim(get_import_row_image.IMAGE_NAME)>
                            <cfif !len(import_image_file_name) and len(trim(get_import_row_image.IMAGE_PATH))>
                                <cfset import_image_file_name = listLast(trim(get_import_row_image.IMAGE_PATH), "\/")>
                            </cfif>
                            <cfif len(import_image_file_name)>
                                <cfquery name="add_virtual_offer_import_image_file" datasource="#dsn3#">
                                    IF NOT EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE
                                        WHERE
                                            EZGI_ID = #get_import_row_image.EZGI_ID#
                                            AND FILE_TYPE_ID = 5
                                    )
                                    BEGIN
                                        INSERT INTO
                                            EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE
                                            (
                                                EZGI_ID,
                                                FILE_TYPE_ID,
                                                FILE_NAME,
                                                RECORD_EMP,
                                                RECORD_IP,
                                                RECORD_DATE
                                            )
                                        VALUES
                                            (
                                                #get_import_row_image.EZGI_ID#,
                                                5,
                                                '#import_image_file_name#',
                                                #session.ep.userid#,
                                                '#cgi.remote_addr#',
                                                #now()#
                                            )
                                    END
                                </cfquery>
                            </cfif>
                        </cfif>
                    </cfif>
                    <cfif isdefined('attributes.money_recordcount')>
                        <cfquery name="del_VIRTUAL_OFFER_row" datasource="#dsn3#">
                            DELETE FROM EZGI_VIRTUAL_OFFER_MONEY WHERE ACTION_ID = #attributes.VIRTUAL_OFFER_id#
                        </cfquery>
                        <cfloop from="1" to="#attributes.money_recordcount#" index="i">
                            <cfif isdefined('attributes.MONEY_TYPE_#i#')>
                                <cfquery name="add_money" datasource="#dsn3#">
                                    INSERT INTO 
                                        EZGI_VIRTUAL_OFFER_MONEY
                                        (
                                            MONEY_TYPE, 
                                            ACTION_ID, 
                                            RATE2, 
                                            RATE1, 
                                            IS_SELECTED
                                        )
                                    VALUES        
                                        (
                                            '#Evaluate("attributes.MONEY_TYPE_#i#")#',
                                            #attributes.VIRTUAL_OFFER_id#,
                                            #Filternum(Evaluate('attributes.MONEY_#i#'))#,
                                            1,
                                            <cfif attributes.basket eq Evaluate('attributes.MONEY_TYPE_#i#')>1<cfelse>0</cfif>
                                        )
                                </cfquery>	
                            </cfif>
                        </cfloop>
                  	</cfif>
            	</cfif>
            </cfloop>
       	<cfelse>
        	Kaydedilecek Satır Bulunamadı.
        	<cfabort>
        </cfif>
    </cftransaction>
</cflock>
<cf_workcube_process is_upd='1' 
		old_process_line='0'
		process_stage='#attributes.process_stage#' 
		record_member='#session.ep.userid#' 
		record_date='#now()#' 
		action_table='EZGI_VIRTUAL_OFFER'
		action_column='VIRTUAL_OFFER_ID'
		action_id='#attributes.virtual_offer_id#'
		action_page='#request.self#?fuseaction=prod.upd_ezgi_virtual_offer&virtual_offer_id=#attributes.virtual_offer_id#' 
        paper_no='#get_v_o.VIRTUAL_OFFER_NUMBER#'
		warning_description='#attributes.VIRTUAL_OFFER_head#'>
<cfif not isdefined('attributes.process_type')><!---Sanal Teklife Aktarımdan geliyorsa birşey yapma--->
    <script type="text/javascript">
        window.location.href = '<cfoutput>#request.self#?fuseaction=prod.list_ezgi_virtual_offer&event=upd&virtual_offer_id=#attributes.virtual_offer_id#</Cfoutput>';
    </script>
</cfif>