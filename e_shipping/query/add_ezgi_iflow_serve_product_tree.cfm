<!---
    File: add_ezgi_iflow_serve_product_tree.cfm
    Folder: Add_Ons\ezgi\e-shipping\query
    Author: Ezgi Yazılım
    Date: 19/01/2024
    Description:
--->
<cfquery name="get_order_info" datasource="#dsn3#">
	SELECT 
     	DELIVERDATE, 
     	DELIVER_DEPT_ID, 
     	LOCATION_ID
	FROM     
     	ORDERS
	WHERE  
   	ORDER_ID = #attributes.order_id#
</cfquery>
<cftransaction>
	<cfquery name="del_order_row" datasource="#dsn3#">
    	DELETE FROM ORDER_ROW WHERE ORDER_ID = #attributes.order_id#
    </cfquery>
    <cfquery name="del_order_row" datasource="#dsn3#">
    	DELETE FROM ORDER_ROW_RESERVED WHERE ORDER_ID = #attributes.order_id#
    </cfquery>
    <cfquery name="upd_order_info" datasource="#dsn3#">
    	UPDATE 
        	ORDERS
		SET          
        	GROSSTOTAL =0, 
            NETTOTAL =0, 
            OTV_TOTAL =0, 
            TAXTOTAL =0, 
            OTHER_MONEY = '#session.ep.money#',  
            OTHER_MONEY_VALUE =0, 
            SA_DISCOUNT =0, 
            DISCOUNTTOTAL =0
		WHERE  
        	ORDER_ID = #attributes.order_id#
    </cfquery>
    <cfloop from="1" to="#ListLen(attributes.stock_id_list)#" index="i">
        <cfquery name="get_product_info" datasource="#dsn3#">
            SELECT 
                S.STOCK_ID, 
                P.PRODUCT_ID, 
                P.PRODUCT_NAME, 
                S.PRODUCT_UNIT_ID, 
                PU.MAIN_UNIT, 
                PU.UNIT_ID,
                P.TAX
            FROM     
                #dsn1_alias#.STOCKS AS S WITH (NOLOCK) INNER JOIN
                #dsn1_alias#.PRODUCT AS P WITH (NOLOCK) ON S.PRODUCT_ID = P.PRODUCT_ID INNER JOIN
                #dsn1_alias#.PRODUCT_UNIT AS PU WITH (NOLOCK) ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
            WHERE  
                S.STOCK_ID = #ListGetAt(attributes.stock_id_list,i)#
        </cfquery>
        <cfif get_product_info.recordcount>
        	<cfset attributes.ezg_row_id = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')# & #session.ep.company_id# & #session.ep.userid# & #i#>
            <cfquery name="add_order_row" datasource="#dsn3#" result="max_id">
                INSERT INTO 
                    ORDER_ROW
                    (
                        ORDER_ID, 
                        STOCK_ID, 
                        PRODUCT_ID, 
                        PRODUCT_NAME, 
                        QUANTITY, 
                        PRICE, 
                        PRICE_OTHER, 
                        UNIT, 
                        UNIT_ID, 
                        TAX, 
                        NETTOTAL, 
                        ORDER_ROW_CURRENCY, 
                        DELIVER_DATE, 
                        DELIVER_DEPT, 
                        DELIVER_LOCATION, 
                        DISCOUNT_1, 
                        DISCOUNT_2, 
                        DISCOUNT_3, 
                        DISCOUNT_4, 
                        DISCOUNT_5, 
                        DISCOUNT_6, 
                        DISCOUNT_7, 
                        DISCOUNT_8, 
                        DISCOUNT_9, 
                        DISCOUNT_10, 
                        OTHER_MONEY, 
                        OTHER_MONEY_VALUE, 
                        COST_PRICE, 
                        EXTRA_COST, 
                        MARJ, 
                        PROM_COST, 
                        DISCOUNT_COST, 
                        IS_PROMOTION, 
                        IS_COMMISSION, 
                        EXTRA_PRICE_OTHER_TOTAL, 
                        EXTRA_PRICE, 
                        EXTRA_PRICE_TOTAL, 
                        OTV_ORAN, 
                        OTVTOTAL, 
                        RESERVE_TYPE, 
                        LIST_PRICE, 
                        NUMBER_OF_INSTALLMENT, 
                        AMOUNT2, 
                        EK_TUTAR_PRICE, 
                        WRK_ROW_ID, 
                        CANCEL_AMOUNT, 
                        BSMV_RATE, 
                        BSMV_AMOUNT, 
                        BSMV_CURRENCY, 
                        OIV_RATE, 
                        OIV_AMOUNT, 
                        OTV_DISCOUNT
                    )
                VALUES 
                    (
                        #attributes.order_id#, 
                        #get_product_info.STOCK_ID#, 
                        #get_product_info.PRODUCT_ID#, 
                        '#get_product_info.PRODUCT_NAME#', 
                        #ListGetAt(attributes.amount_list,i)#, 
                        0, 
                        0, 
                        '#get_product_info.MAIN_UNIT#', 
                        #get_product_info.PRODUCT_UNIT_ID#, 
                        #get_product_info.TAX#, 
                        0, 
                        -1, 
                        '#get_order_info.DELIVERDATE#', 
                        #get_order_info.DELIVER_DEPT_ID#, 
                        #get_order_info.LOCATION_ID#, 
                        0, 
                        0, 
                        0, 
                        0, 
                        0, 
                        0, 
                        0, 
                        0, 
                        0, 
                        0, 
                        '#session.ep.money#', 
                        0, 
                        0, 
                        0, 
                        0, 
                        0, 
                       	0, 
                        0, 
                        0, 
                        0, 
                        0, 
                        0, 
                        0, 
                        0, 
                        -1, 
                        0, 
                        0, 
                        #ListGetAt(attributes.amount_list,i)#, 
                        0, 
                        '#attributes.ezg_row_id#', 
                        0, 
                        0, 
                        0, 
                        0, 
                        0, 
                        0, 
                        0
                    )
            </cfquery>
            <cfquery name="add_order_row_reserved" datasource="#dsn3#">
            	INSERT INTO 
                	ORDER_ROW_RESERVED
                  	(
                    	STOCK_ID, 
                        PRODUCT_ID, 
                        ORDER_ID, 
                        RESERVE_STOCK_IN, 
                        RESERVE_STOCK_OUT, 
                        RESERVE_CANCEL_AMOUNT, 
                        STOCK_IN, 
                        STOCK_OUT, 
                        DEPARTMENT_ID, 
                        LOCATION_ID, 
                        ORDER_WRK_ROW_ID
                  	)
				VALUES 
                	(
                    	#get_product_info.STOCK_ID#, 
                        #get_product_info.PRODUCT_ID#, 
                        #attributes.order_id#, 
                        0, 
                        #ListGetAt(attributes.amount_list,i)#, 
                        0, 
                        0, 
                        0, 
                     	#get_order_info.DELIVER_DEPT_ID#, 
                        #get_order_info.LOCATION_ID#,  
                        '#attributes.ezg_row_id#'
                    )
            </cfquery>
        </cfif>
 	</cfloop>
</cftransaction>
<script type="text/javascript">
 	alert("Kayıt İşlemi Başarıyla Tamamlanmıştır.");
	wrk_opener_reload();
    window.close()
</script>