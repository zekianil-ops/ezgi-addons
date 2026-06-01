<cfif get_connect.sales_type eq 3 and get_connect.CAMPAIGN_TYPE eq 1> <!---Satış Tipi Kampanya ve Kampanya Anında İndirim İse--->
	<cfquery name="get_connect_row_camp" datasource="#DSN3#">
        SELECT 
            ISNULL(QUANTITY,0) AS QUANTITY, 
            ISNULL(PRICE_OTHER,0) AS SALES_PRICE, 
            ISNULL(OTHER_MONEY,'#session.ep.money#') AS MONEY,
            TAX
        FROM 
            EZGI_CONNECT_ROW
        WHERE 
            CONNECT_ID = #attributes.connect_id#
        ORDER BY
            SORT_NO,
            CONNECT_ROW_ID
    </cfquery>
   
	<cfset camp_total_brut_ = 0>
    <cfset camp_sub_total_brut = 0>
    <cfset camp_total_tax_ = 0>
    <cfset camp_isk = 0>
    <cfloop query="get_connect_row_camp"> <!---Toplam Satış Rakamını Buluyoruz--->
		<cfset camp_total_brut_ = get_connect_row_camp.SALES_PRICE*get_connect_row_camp.QUANTITY>
      	<cfset camp_total_tax_ = camp_total_brut_*get_connect_row_camp.TAX/100>
        <cfset camp_sub_total_brut = camp_sub_total_brut+(camp_total_brut_+camp_total_tax_)>
    </cfloop>
    <cfif camp_sub_total_brut gt 0> <!---Sepette hesaplanacak Ürün Varsa--->
        <cfquery name="Get_Discount_Table" datasource="#dsn3#">
            SELECT * FROM EZGI_CONNECT_CAMPAIGN_DISCOUNT WHERE PROJECT_ID = #get_connect.project_id# ORDER BY EZGI_CONNECT_CAMPAIGN_DISCOUNT_ID
        </cfquery>
        <cfif Get_Discount_Table.recordcount>
            <cfloop query="Get_Discount_Table">
                <cfif camp_sub_total_brut gt Get_Discount_Table.START_TOTAL and camp_sub_total_brut lte Get_Discount_Table.FINISH_TOTAL>
                    <cfset camp_isk = Get_Discount_Table.DISCOUNT>
                </cfif>
            </cfloop>
            
            <cfif len(camp_isk)> <!---Eğer Düzenlenecek İskonto Bulunduysa--->
                <cfquery name="upd_connect_row" datasource="#dsn3#"> <!---Kampanya İskontosu Sepetin Tüm Satırlarına İşleniyor--->
                    UPDATE 
                        EZGI_CONNECT_ROW 
                    SET
                        DISCOUNT_1 = #camp_isk#,
                        DISCOUNT_2 = 0,
                        DISCOUNT_3 = 0,
                        DISCOUNT_COST = 0
                    WHERE 
                        CONNECT_ID = #attributes.connect_id#
                </cfquery>
            </cfif>
        </cfif>
  	</cfif>
<cfelseif get_connect.sales_type eq 4> <!---Satış Kategori Bazlı İndirim İse--->
	<cfinclude template="upd_ezgi_connect_product_cat.cfm">
</cfif>
<cfquery name="get_connect_row" datasource="#DSN3#">
	SELECT 
      	*,
        <cfif get_connect_defaults_row.IS_EXPORT>0 AS TAX<cfelse>ISNULL(TAX,0) AS TAX</cfif>,
   		ISNULL(QUANTITY,0) AS AMOUNT, 
     	ISNULL(PRICE_OTHER,0) AS SALES_PRICE, 
    	ISNULL(OTHER_MONEY,'#session.ep.money#') AS MONEY,
      	ISNULL(DISCOUNT_1,0) AS DISCOUNT1, 
      	ISNULL(DISCOUNT_2,0) AS DISCOUNT2, 
      	ISNULL(DISCOUNT_3,0) AS DISCOUNT3,
      	ISNULL(DISCOUNT_COST,0) AS DISCOUNT_TUT
   	FROM 
     	EZGI_CONNECT_ROW
  	WHERE 
    	CONNECT_ID = #attributes.connect_id#
   	ORDER BY
     	SORT_NO,
     	CONNECT_ROW_ID
</cfquery>
<cfset sub_total_brut =0>
<cfset sub_total_net =0>
<cfset sub_total_tax =0>
<cfset sub_total_brut =0>
<cfset sub_total_brut_other =0>
<cfset sub_total_net_other =0>
<cfset sub_total_tax_other =0>
<cfset sub_total_discount = 0>
<cfset sub_total_end = 0>
<cfset sub_total_end_other = 0>

<cfloop query="get_connect_row">
	<cfset total_brut_other_ = sales_price*quantity>
	<cfset total_brut_ = Evaluate('RATE2_#MONEY#')*total_brut_other_>
	<cfset sub_total_brut = sub_total_brut+total_brut_>
	<cfset total_net_other_ = total_brut_other_-(discount_tut*quantity)>
	<cfset total_net_other_ = total_net_other_-(total_net_other_*discount1/100)>
	<cfset total_net_other_ = total_net_other_-(total_net_other_*discount2/100)>
	<cfset total_net_other_ = total_net_other_-(total_net_other_*discount3/100)>
	<cfset total_net_ = Evaluate('RATE2_#MONEY#')*total_net_other_>
	<cfset sub_total_net = sub_total_net+total_net_>
	<cfset total_tax_other_ = total_net_other_*tax/100>
	<cfset total_tax_ = Evaluate('RATE2_#MONEY#')*total_tax_other_ >
	<cfset sub_total_tax = sub_total_tax+total_tax_>
	<cfset sub_total_end = sub_total_net+sub_total_tax>
	<cfset sub_total_brut_other =sub_total_brut/connect_rate2>
	<cfset sub_total_net_other = sub_total_net/connect_rate2>
	<cfset sub_total_tax_other = sub_total_tax/connect_rate2>
	<cfset sub_total_discount = sub_total_brut - sub_total_net>
	<cfset sub_total_end_other = sub_total_end/connect_rate2>
</cfloop>
<cfquery name="upd_connect" datasource="#dsn3#">
	UPDATE
	    EZGI_CONNECT
	SET
	    DISCOUNTTOTAL = <cfif len(sub_total_discount)>#Round(sub_total_discount*100)/100#<cfelse>0</cfif>,
	    GROSSTOTAL = <cfif len(sub_total_brut)>#Round(sub_total_brut*100)/100#<cfelse>0</cfif>,
	    NETTOTAL = <cfif len(sub_total_end)>#Round(sub_total_end*100)/100#<cfelse>0</cfif>,
	    TAXTOTAL = <cfif len(sub_total_tax)>#Round(sub_total_tax*100)/100#<cfelse>0</cfif>,
	    OTHER_MONEY = '#connect_money#', 
	    OTHER_MONEY_VALUE = <cfif len(sub_total_end_other)>#Round(sub_total_end_other*100)/100#<cfelse>0</cfif>,
	    UPDATE_DATE = #now()#,
	    UPDATE_EMP = #session.ep.userid#,
	    UPDATE_IP = '#cgi.remote_addr#'
	WHERE
	    CONNECT_ID = #attributes.connect_id#       
</cfquery>