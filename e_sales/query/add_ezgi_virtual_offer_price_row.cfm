<!---
    File: add_ezgi_virtual_offer_price_row.cfm
    Folder: Add_Ons\ezgi\e_sales\query
    Author: Ezgi Yazılım
    Date: 01/01/2022
    Description:
--->
<cfif len(attributes.parca) or len(attributes.urun)>
	<cfif attributes.price_type eq 2>	
     	<cfquery name="get_price" datasource="#dsn3#">
        	SELECT * FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PIECE_ROW_ID = #attributes.piece_id# AND PRICE_CAT_ID = #attributes.price_cat_id#
       	</cfquery>
 	<cfelseif attributes.price_type eq 1>
     	<cfquery name="get_price" datasource="#dsn3#">
          	SELECT * FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE STOCK_ID = #attributes.stock_id# AND PRICE_CAT_ID = #attributes.price_cat_id#
      	</cfquery>
  	</cfif>
  	<cfif get_price.recordcount>
    	<script language="javascript">
         	alert('Kaydetmek İstediğiniz Ürün Fiyat Listede Kayıtlıdır.');
        	window.history.back();
     	</script>
     	<cfabort>
    </cfif>
</cfif>
<cfif attributes.product_code neq 0>
	<cfquery name="get_product_code" datasource="#dsn3#">
    	SELECT * FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PRODUCT_CODE_2 = '#attributes.product_code#' AND PRICE_CAT_ID = #attributes.price_cat_id#
    </cfquery>
    <cfif get_product_code.recordcount>
		<script language="javascript">
            alert('Kaydetmek İstediğiniz Bağlantı Kodu Fiyat Listede Kayıtlıdır.');
            window.history.back();
        </script>
        <cfabort>
    </cfif>
</cfif>
<cftransaction>
	<cfquery name="add_price_row" datasource="#dsn3#">
    	INSERT INTO 
        	EZGI_VIRTUAL_OFFER_PRICE_ROW
         	(
            	PRICE_CAT_ID, 
                PRODUCT_CODE_2, 
                PRODUCT_NAME, 
                STOCK_ID, 
                PIECE_ROW_ID, 
                SALES_PRICE, 
                SALES_PRICE_MONEY, 
                PURCHASE_PRICE, 
                PURCHASE_PRICE_MONEY, 
                COST_PRICE, 
                COST_PRICE_MONEY,
                MONTAGE_TYPE,
                PRICE_TYPE,
                IS_RATE,
                UPDATE_DATE
         	)
		VALUES     
        	(
            	#attributes.price_cat_id#,
                '#attributes.product_code#',
                <cfif attributes.price_type eq 1>'#attributes.urun#'<cfelseif attributes.price_type eq 2>'#attributes.parca#'<cfelse>'#attributes.virtual_product#'</cfif>,
                <cfif len(attributes.stock_id)>#attributes.stock_id#<cfelse>NULL</cfif>,
                <cfif len(attributes.piece_id)>#attributes.piece_id#<cfelse>NULL</cfif>,
                #Filternum(sales_money_value)#,
                '#attributes.sales_money#',
                #Filternum(purchase_money_value)#,
                '#attributes.purchase_money#',
                #Filternum(cost_money_value)#,
                '#attributes.cost_money#',
                #attributes.montage_type#,
                #attributes.price_type#,
                #attributes.is_rate#,
                #now()#
        	)
    </cfquery>
</cftransaction>
<script language="javascript">
	window.opener.location.reload()
	window.close();
</script>