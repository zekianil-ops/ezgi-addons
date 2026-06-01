<cfset total_sales = 0>
<cfset total_cost = 0>
<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_ANALYST_BRANCH WHERE ANALYST_BRANCH_ID = #attributes.upd_id#
</cfquery>
<cfquery name="get_sales_row" datasource="#dsn#">	
	SELECT
    	*,
        CASE
       		WHEN O.COMPANY_ID IS NOT NULL THEN
                   (
                    SELECT     
                      	NICKNAME
					FROM         
                    	#dsn_alias#.COMPANY
					WHERE     
                   		COMPANY_ID = O.COMPANY_ID
                  	)
          	WHEN O.CONSUMER_ID IS NOT NULL THEN      
                   	(	
                  	SELECT     
                     	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
					FROM         
                      	#dsn_alias#.CONSUMER
					WHERE     
                		CONSUMER_ID = O.CONSUMER_ID
               		)
          	WHEN O.EMPLOYEE_ID IS NOT NULL THEN
                  	(
                   	SELECT     
                    	EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
					FROM         
                  		#dsn_alias#.EMPLOYEES
					WHERE     
                     	EMPLOYEE_ID = O.EMPLOYEE_ID
                 	)
   		END AS UNVAN
  	FROM
    	(
        SELECT 
        	INVOICE_NUMBER,
            INVOICE_DATE,
            COMPANY_ID,
            NETTOTAL,	
            GROSSTOTAL,
            COST_PRICE,
            INVOICE_ID,
            INVOICE_ROW_ID,
            STOCK_ID,
            PRODUCT_ID,
            AMOUNT,
            SALE_EMP,
            LIST_PRICE, 
            CONSUMER_ID, 
            EMPLOYEE_ID, 
            NAME_PRODUCT, 
            UNIT,
            (INV_M.RATE2/INV_M.RATE1) AS OTHER_MONEY_RATE,
            ISNULL((SELECT
                    TOP 1 (PURCHASE_NET_SYSTEM + PURCHASE_EXTRA_COST_SYSTEM)  
                FROM 
                    #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.GET_PRODUCT_COST_PERIOD
                WHERE
                    GET_PRODUCT_COST_PERIOD.START_DATE <= INV_TOTAL.INVOICE_DATE
                    AND GET_PRODUCT_COST_PERIOD.PRODUCT_ID = INV_TOTAL.PRODUCT_ID
                    AND ISNUMERIC(GET_PRODUCT_COST_PERIOD.SPECT_MAIN_ID)=0
                ORDER BY
                    GET_PRODUCT_COST_PERIOD.START_DATE DESC,
                    GET_PRODUCT_COST_PERIOD.RECORD_DATE DESC
                    ),0) AS PROD_COST,
            (
                SELECT        
                    PC.PRODUCT_CAT
                FROM            
                    #dsn1_alias#.PRODUCT AS P INNER JOIN
                    #dsn1_alias#.PRODUCT_CAT AS PC ON P.PRODUCT_CATID = PC.PRODUCT_CATID
                WHERE        
                    P.PRODUCT_ID = INV_TOTAL.PRODUCT_ID
            ) AS PRODUCT_CAT,
            (
                SELECT        
                    PRODUCT_CATID
                FROM            
                    #dsn1_alias#.PRODUCT AS P
                WHERE        
                    PRODUCT_ID = INV_TOTAL.PRODUCT_ID
            ) AS PRODUCT_CATID,
            1 AS TYPE
        FROM
            (
            SELECT	
                I.INVOICE_NUMBER, 
                I.INVOICE_DATE,
                I.COMPANY_ID,
                CASE WHEN (I.NETTOTAL-I.TAXTOTAL+I.SA_DISCOUNT)= 0 THEN IR.NETTOTAL ELSE ((1- I.SA_DISCOUNT/(I.NETTOTAL-I.TAXTOTAL+I.SA_DISCOUNT)) *IR.NETTOTAL) END AS NETTOTAL,	
                CASE WHEN (I.NETTOTAL-I.TAXTOTAL+I.SA_DISCOUNT)= 0 THEN (IR.NETTOTAL + (IR.TAXTOTAL*ISNULL(I.TEVKIFAT_ORAN/100,1) )-(IR.NETTOTAL * ISNULL(I.STOPAJ_ORAN/100,0) )) ELSE (  ( (1- (I.SA_DISCOUNT)/(I.NETTOTAL-I.TAXTOTAL+I.SA_DISCOUNT) ) * IR.NETTOTAL) + (IR.TAXTOTAL*ISNULL(I.TEVKIFAT_ORAN/100,1)) - (IR.NETTOTAL * ISNULL(I.STOPAJ_ORAN/100,0) ) ) END AS GROSSTOTAL,
                IR.COST_PRICE,
                I.INVOICE_ID,
                IR.INVOICE_ROW_ID,
                IR.STOCK_ID,
                IR.PRODUCT_ID,
                IR.AMOUNT,
                I.SALE_EMP,
                IR.LIST_PRICE, 
                I.CONSUMER_ID, 
                I.EMPLOYEE_ID, 
                IR.NAME_PRODUCT, 
                IR.UNIT
            FROM
                #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.INVOICE I,
                #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.INVOICE_ROW IR
            WHERE
                I.INVOICE_ID=IR.INVOICE_ID
                AND I.INVOICE_CAT IN (48,50,52,53,531,56,58,62,561)
                AND I.IS_IPTAL=0
                AND YEAR(I.INVOICE_DATE) = #get_upd.YEAR_VALUE# 
                AND MONTH(I.INVOICE_DATE) = #get_upd.MONTH_VALUE#
                AND I.DEPARTMENT_ID IN
                                    (
                                        SELECT        
                                            DEPARTMENT_ID
                                        FROM            
                                            #dsn_alias#.DEPARTMENT
                                        WHERE        
                                            BRANCH_ID = #get_upd.BRANCH_ID#
                                    )
            UNION ALL		
        	SELECT	
                I.INVOICE_NUMBER,
                I.INVOICE_DATE,
                I.COMPANY_ID,
                CASE WHEN (I.NETTOTAL-I.TAXTOTAL+I.SA_DISCOUNT)= 0 THEN (-1)*IR.NETTOTAL ELSE ((1- I.SA_DISCOUNT/(I.NETTOTAL-I.TAXTOTAL+I.SA_DISCOUNT)) *IR.NETTOTAL*(-1)) END AS NETTOTAL,
                CASE WHEN (I.NETTOTAL-I.TAXTOTAL+I.SA_DISCOUNT)= 0 THEN  (-1)*(IR.NETTOTAL + (IR.TAXTOTAL*ISNULL(I.TEVKIFAT_ORAN/100,1) )-(IR.NETTOTAL * ISNULL(I.STOPAJ_ORAN/100,0) )) ELSE (-1)*(  ( (1- (I.SA_DISCOUNT)/(I.NETTOTAL-I.TAXTOTAL+I.SA_DISCOUNT) ) * IR.NETTOTAL) + (IR.TAXTOTAL*ISNULL(I.TEVKIFAT_ORAN/100,1)) - (IR.NETTOTAL * ISNULL(I.STOPAJ_ORAN/100,0) ) ) END AS GROSSTOTAL,	
                IR.COST_PRICE,
                I.INVOICE_ID,
                IR.INVOICE_ROW_ID,
                IR.STOCK_ID,
                IR.PRODUCT_ID,
                IR.AMOUNT,
                I.SALE_EMP,
                IR.LIST_PRICE, 
                I.CONSUMER_ID, 
                I.EMPLOYEE_ID, 
                IR.NAME_PRODUCT, 
                IR.UNIT
            FROM
                #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.INVOICE I,
                #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.INVOICE_ROW IR
            WHERE
                I.INVOICE_ID=IR.INVOICE_ID
                AND I.INVOICE_CAT IN (51,54,55,63)
                AND I.IS_IPTAL=0
                AND YEAR(I.INVOICE_DATE) = #get_upd.YEAR_VALUE# 
                AND MONTH(I.INVOICE_DATE) = #get_upd.MONTH_VALUE#
                AND I.DEPARTMENT_ID IN
                                    (
                                        SELECT        
                                            DEPARTMENT_ID
                                        FROM            
                                            #dsn_alias#.DEPARTMENT
                                        WHERE        
                                            BRANCH_ID = #get_upd.BRANCH_ID#
                                    )
            ) AS INV_TOTAL,
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.INVOICE_MONEY INV_M,
            #dsn_alias#.SETUP_PERIOD STP
        WHERE
            INV_M.ACTION_ID=INV_TOTAL.INVOICE_ID
            AND STP.PERIOD_ID = #session.ep.period_id# 
            AND INV_M.MONEY_TYPE = ISNULL(STP.OTHER_MONEY,'TL')
        UNION ALL
        SELECT    
        	PAPER_NO AS INVOICE_NUMBER,    
            EIE.EXPENSE_DATE AS INVOICE_DATE, 
            EIP.CH_COMPANY_ID AS COMPANY_ID, 
            EIE.AMOUNT AS NETTOTAL, 
            EIE.AMOUNT AS GROSSTOTAL,
            0 AS COST_PRICE, 
            EIE.EXPENSE_ID AS INVOICE_ID, 
            EIE.EXP_ITEM_ROWS_ID AS INVOICE_ROW_ID, 
            EIE.EXPENSE_ITEM_ID AS STOCK_ID, 
            EIE.EXPENSE_ITEM_ID AS PRODUCT_ID, 
            1 AS AMOUNT, 
            EIP.EMP_ID AS SALE_EMP,
            0 AS LIST_PRICE, 
            EIP.CH_CONSUMER_ID AS CONSUMER_ID, 
            EIP.CH_EMPLOYEE_ID AS EMPLOYEE_ID, 
            EIE.DETAIL AS NAME_PRODUCT, '' AS UNIT, 
            0 AS OTHER_MONEY_RATE, 0 AS PROD_COST, 
            EIC.EXPENSE_CAT_NAME AS PRODUCT_CAT, 
            EIC.EXPENSE_CAT_ID AS PRODUCT_CATID, 
            2 AS TYPE
        FROM            
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEMS_ROWS AS EIE INNER JOIN
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEMS AS EI ON EIE.EXPENSE_ITEM_ID = EI.EXPENSE_ITEM_ID INNER JOIN
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_CATEGORY AS EIC ON EI.EXPENSE_CATEGORY_ID = EIC.EXPENSE_CAT_ID INNER JOIN
            #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEM_PLANS AS EIP ON EIE.EXPENSE_ID = EIP.EXPENSE_ID
        WHERE        
            EIE.EXPENSE_ID IN
                            (
                                SELECT        
                                    EXPENSE_ID
                                FROM            
                                    #dsn#_#get_upd.YEAR_VALUE#_#session.ep.company_id#.EXPENSE_ITEM_PLANS AS EXPENSE_ITEM_PLANS_1
                                WHERE        
                                    BRANCH_ID = #get_upd.BRANCH_ID# AND 
                                    MONTH(EXPENSE_DATE) = #get_upd.MONTH_VALUE# AND 
                                    YEAR(EXPENSE_DATE) = #get_upd.YEAR_VALUE#
                            ) AND 
            EI.IS_EXPENSE = 0
     	) AS O
   	ORDER BY
    	TYPE,
        INVOICE_DATE,
        INVOICE_NUMBER
</cfquery>
<table class="dph">
	<tr> 
		<td class="dpht">Gelir Detayları</td>
        <td style="text-align:right"></td>
	</tr>
</table>   
 
<cfform action="" method="post" name="gelir_detay">
<table id="kontrol_listesi" width="100%">
	<tr>
		<td>
        	<cf_medium_list>
                <thead>
                    <tr height="20px">
                    	<th width="25px"><cf_get_lang_main no='1165.Sıra'></th>
                        <th width="60px"><cf_get_lang_main no='56.Belge'></th>
                        <th width="65px"><cf_get_lang_main no='330.Tarih'></th>
                        <th width="65px"><cf_get_lang_main no='468.Belge No'></th>
                        <th width="250px"><cf_get_lang_main no='45.Müşteri'></th>
                        <th width="90px"><cf_get_lang_main no='74.Kategori'></th>
                        <th><cf_get_lang_main no='245.Ürün'></th>
                        <th width="40px"><cf_get_lang_main no='223.Miktar'></th>
                        <th width="40px"><cf_get_lang_main no='224.Birim'></th>
                        <th width="70px"><cf_get_lang_main no='226.Birim Fiyat'></th>
                        <th width="70px"><cf_get_lang_main no='80.Toplam'></th>
                        <th width="70px"><cfoutput>#getLang('product',806)#</cfoutput></th>
                        <th width="70px"><cfoutput>#getLang('invoice',174)#</cfoutput></th>
                    </tr>
    			</thead>
                <tbody>
                	<cfif get_sales_row.RECORDCOUNT>
						<cfoutput query="get_sales_row">
                        	<input name="list_type#currentrow#" id="list_type#currentrow#" type="hidden" value="#type#">
                            <input name="invoice_row_#type#" type="hidden" value="#INVOICE_ROW_ID#">
                            <tr height="20">
                                <td style="text-align:right">#currentrow#</td>
                                <td>
                                	<cfif type eq 1>
                                    	Fatura
                                    <cfelse>
                                    	Gelir Fişi
                                    </cfif>
                                </td>
                                <td style="text-align:center">#DateFormat(INVOICE_DATE,'DD/MM/YYYY')#</td>
                                <td style="text-align:center">#INVOICE_NUMBER#</td>
                                <td>#UNVAN#</td>
                                <td>#PRODUCT_CAT#</td>
                                <td>#NAME_PRODUCT#</td>
                                <td style="text-align:right">#AmountFormat(Amount,2)#</td>
                                <td>#UNIT#</td>
                                <td style="text-align:right">#AmountFormat(Nettotal/Amount,2)#</td>
                                <td style="text-align:right">#AmountFormat(Nettotal,2)#</td>
                                <td style="text-align:right">#AmountFormat(Amount*COST_PRICE,2)#</td>
                                <td style="text-align:right">
                                	<input name="list_price#INVOICE_ROW_ID#" id="list_price#currentrow#" type="text" class="box" value="#AmountFormat(List_price,2)#" <cfif TYPE eq 2>readonly="readonly"</cfif>>
                                </td>
                          	</tr>
                            <cfset total_sales = total_sales + Nettotal>
							<cfset total_cost = total_cost + (Amount*COST_PRICE)>
                     	</cfoutput>
                        <tr>
                        	<td colspan="10"><strong>Genel Toplam</strong></td>
                        	<td style="text-align:right"><cfoutput><strong>#TlFormat(total_sales,2)#</strong></cfoutput></td>
                            <td style="text-align:right"><cfoutput><strong>#TlFormat(total_cost,2)#</strong></cfoutput></td>
                            <td style="text-align:right"><cf_workcube_buttons is_upd='1' is_delete='0' add_function='control()' insert_alert = ''></td>
                        </tr>
                  	</cfif>
               	</tbody>
                <!---<tfoot>
                    <tr>
                    	
                        
                    </tr>
             	</tfoot>--->
         	</cf_medium_list>
      	</td>
  	</tr>
</table>
</cfform>
<script type="text/javascript">
	function control()
	{
		
			<cfif get_sales_row.RECORDCOUNT>
				uzunluk = <cfoutput>#get_sales_row.RECORDCOUNT#</cfoutput>;
				for(ci=1;ci<=uzunluk;ci++)
				{
					if(filterNum(document.getElementById('list_price'+ci).value,2)*1 <= 0 && document.getElementById('list_type'+ci).value==1)
					{
						sor=confirm('Değer 0 dan büyük Olmalıdır. Devam Etmek İstermisin?');
						if(sor==false)
						{
							document.getElementById('list_price'+ci).focus();
							return false;
						}
					}
				}
				document.getElementById("gelir_detay").action = "<cfoutput>#request.self#?fuseaction=report.emptypopup_upd_ezgi_analyst_gelirler_row&upd_id=#attributes.upd_id#</cfoutput>";
				document.getElementById("gelir_detay").submit();
				return true;
			</cfif>
		
	}
</script>