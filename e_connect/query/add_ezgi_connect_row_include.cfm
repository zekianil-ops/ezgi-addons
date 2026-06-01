        <cfquery name="get_product_info" datasource="#dsn3#">
        	SELECT 
             	P.PRODUCT_ID ,
                P.PRODUCT_NAME,
                P.TAX,
                S.PRODUCT_UNIT_ID,
                (SELECT MAIN_UNIT FROM #dsn1_alias#.PRODUCT_UNIT WHERE PRODUCT_UNIT_ID = S.PRODUCT_UNIT_ID) AS UNIT
          	FROM 
            	#dsn1_alias#.STOCKS AS S INNER JOIN
                #dsn1_alias#.PRODUCT AS P ON P.PRODUCT_ID = S.PRODUCT_ID
          	WHERE 
            	S.STOCK_ID = #attributes.stock_id#
        </cfquery>
        <cfquery name="add_connect_row" datasource="#dsn3#" result="max_id">
            INSERT INTO 
                EZGI_CONNECT_ROW
                (
                    CONNECT_ID, 
                    PRODUCT_ID, 
                    STOCK_ID, 
                    PRODUCT_NAME, 
                    QUANTITY, 
                    PRICE, 
                    PRICE_OTHER, 
                    UNIT, 
                    UNIT_ID, 
                    TAX, 
                    NETTOTAL, 
                    CONNECT_ROW_CURRENCY, 
                    DISCOUNT_1, 
                    DISCOUNT_2, 
                    DISCOUNT_3, 
                    OTHER_MONEY, 
                    OTHER_MONEY_VALUE, 
                    LIST_PRICE, 
                    KARMA_PRODUCT_ID, 
                    EZGI_ID, 
                    SORT_NO,
                    ROW_PRICE_CAT_ID,
                    IS_CAMPAIGN_PRODUCT,
                    PRODUCT_NAME2
                )
            VALUES 
                (
                    #attributes.connect_id#,
                    #get_product_info.product_id#,
                    #attributes.stock_id#,
                    '#get_product_info.product_name#',
                    <cfif isnumeric(attributes.amount) and isnumeric(miktar)>#attributes.amount*miktar#<cfelse>0</cfif>,
                    <cfif attributes.price gt 0>#attributes.price/Evaluate('RATE1_#attributes.money#')#<cfelse>0</cfif>,
                    <cfif attributes.price gt 0>#attributes.price#<cfelse>0</cfif>,
                    '#get_product_info.UNIT#',
                    #get_product_info.PRODUCT_UNIT_ID#,
                    <cfif get_connect_defaults_row.IS_EXPORT>0<cfelse>#get_product_info.tax#</cfif>,<!---Eğer Yurtdışı İşlem Yapan İse KDV 0 Gelsin--->
                    <cfif attributes.net_price gt 0>#attributes.net_price/Evaluate('RATE1_#attributes.money#')*attributes.amount*miktar#<cfelse>0</cfif>,
                    1,
                    #attributes.disc1#,
                    #attributes.disc2#,
                    #attributes.disc3#,
                    <cfif len(attributes.money)>'#attributes.money#'<cfelse>'#session.ep.money#'</cfif>,
                    <cfif isnumeric(attributes.price) and isnumeric(miktar) and isnumeric(attributes.amount)>#attributes.price*miktar*attributes.amount#<cfelse>0</cfif>,
                    <cfif isnumeric(attributes.price)>#attributes.price#<cfelse>0</cfif>,
                    NULL,
                    0,
                    0,
                    <cfif isdefined('attributes.price_cat_id') and len(attributes.price_cat_id)>#attributes.price_cat_id#<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.is_campaign_product') and len(attributes.is_campaign_product)>#attributes.is_campaign_product#<cfelse>0</cfif>,
                    <cfif isdefined('attributes.row_detail') and len(attributes.row_detail)>'#attributes.row_detail#'<cfelse>0</cfif>
                )
        </cfquery>
        <cfquery name="upd_connect_row" datasource="#dsn3#">
            UPDATE 
                EZGI_CONNECT_ROW
            SET 
                EZGI_ID = CONNECT_ROW_ID
            WHERE
                CONNECT_ROW_ID = #MAX_ID.IDENTITYCOL#
        </cfquery>
        