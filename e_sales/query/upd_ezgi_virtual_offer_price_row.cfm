<!---
    File: upd_ezgi_virtual_offer_price_row.cfm
    Folder: Add_Ons\ezgi\e_sales\query
    Author: Ezgi Yazılım
    Date: 01/01/2022
    Description:
--->
<cfquery name="get_cat" datasource="#dsn3#">
	SELECT PRICE_CAT_ID FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PRICE_CAT_ROW_ID = #attributes.PRICE_CAT_ROW_ID#
</cfquery>
<cfif len(attributes.parca) or len(attributes.urun)>
		<cfif len(attributes.parca)>	
            <cfquery name="get_price" datasource="#dsn3#">
                SELECT * FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PIECE_ROW_ID = #attributes.piece_id# AND PRICE_CAT_ID = #get_cat.price_cat_id# AND PRICE_CAT_ROW_ID <> #attributes.PRICE_CAT_ROW_ID#
            </cfquery>
        <cfelseif len(attributes.urun)>
            <cfquery name="get_price" datasource="#dsn3#">
                SELECT * FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE STOCK_ID = #attributes.stock_id# AND PRICE_CAT_ID = #get_cat.price_cat_id# AND PRICE_CAT_ROW_ID <> #attributes.PRICE_CAT_ROW_ID#
            </cfquery>
        </cfif>
        <cfif get_price.recordcount>
            <script language="javascript">
                alert('Kaydetmek İstediğiniz Ürün, Listede Kayıtlıdır.');
                window.history.back();
            </script>
            <cfabort>
    </cfif>
</cfif>
<cfif attributes.product_code neq 0>
	<cfquery name="get_product_code" datasource="#dsn3#">
    	SELECT * FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PRODUCT_CODE_2 = '#attributes.product_code#' AND PRICE_CAT_ROW_ID <> #attributes.PRICE_CAT_ROW_ID# AND PRICE_CAT_ID = #get_cat.price_cat_id#
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
	<cfquery name="upd_price_row" datasource="#dsn3#">
    	UPDATE 
        	EZGI_VIRTUAL_OFFER_PRICE_ROW
      	SET
      		PRODUCT_CODE_2 ='#attributes.product_code#', 
        	PRODUCT_NAME =<cfif attributes.price_type eq 1>'#attributes.urun#'<cfelseif attributes.price_type eq 2>'#attributes.parca#'<cfelse>'#attributes.virtual_product#'</cfif>,
        	STOCK_ID =<cfif len(attributes.stock_id)>#attributes.stock_id#<cfelse>NULL</cfif>, 
          	PIECE_ROW_ID =<cfif len(attributes.piece_id)>#attributes.piece_id#<cfelse>NULL</cfif>,
         	SALES_PRICE =#Filternum(sales_money_value)#, 
         	SALES_PRICE_MONEY ='#attributes.sales_money#', 
        	PURCHASE_PRICE = #Filternum(purchase_money_value)#,
         	PURCHASE_PRICE_MONEY = '#attributes.purchase_money#',
         	COST_PRICE = #Filternum(cost_money_value)#, 
          	COST_PRICE_MONEY = '#attributes.cost_money#',
            MONTAGE_TYPE = #attributes.montage_type#,
            PRICE_TYPE = #attributes.price_type#,
            IS_RATE = #attributes.is_rate#,
            UPDATE_DATE = #now()#
       	WHERE 
        	PRICE_CAT_ROW_ID = #attributes.PRICE_CAT_ROW_ID#
    </cfquery>
</cftransaction>
<script language="javascript">
	window.opener.location.reload()
	window.close();
</script>