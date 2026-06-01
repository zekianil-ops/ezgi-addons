<cfset total_sales = 0>
<cfset total_cost = 0>
<cfset total_purchase = 0>
<cfset attributes.modul=10>
<cfquery name="get_stage_default" datasource="#dsn3#">
	SELECT  VIRTUAL_OFFER_STAGES_2 FROM EZGI_VIRTUAL_OFFER_DEFAULTS
</cfquery>
<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_ANALYST_BRANCH WHERE ANALYST_BRANCH_ID = #attributes.upd_id#
</cfquery>
<cfquery name="GET_HEDEF_sales" datasource="#DSN3#"> <!---Satış Hedefleri - Kotlardan--->
 	SELECT     
   		SQR.CATEGORY_ID, 
     	(SELECT HIERARCHY FROM #dsn1_alias#.PRODUCT_CAT WHERE PRODUCT_CATID = SQR.CATEGORY_ID) AS HIERARCHY
	FROM        
    	SALES_QUOTAS AS SQ INNER JOIN
      	SALES_QUOTAS_ROW AS SQR ON SQ.SALES_QUOTA_ID = SQR.SALES_QUOTA_ID
	WHERE     
    	SQ.IS_ACTIVE = 1 AND
     	SQ.BRANCH_ID = #get_upd.BRANCH_ID# AND 
     	MONTH(SQ.PLAN_DATE) = #get_upd.MONTH_VALUE# AND
      	YEAR(SQ.PLAN_DATE) = #get_upd.YEAR_VALUE#
        <cfif isdefined('attributes.cat_id')>
        	AND SQR.CATEGORY_ID = #attributes.cat_id#
        </cfif>
	GROUP BY 
    	SQR.CATEGORY_ID
</cfquery>
<cfset hierarchy_list = ValueList(GET_HEDEF_sales.HIERARCHY)>
<cfset all_cat_list = ''>
<cfloop list="#hierarchy_list#" index="i">
	<cfoutput>
        <cfquery name="get_cat" datasource="#dsn1#">
            SELECT     
                PRODUCT_CAT,
                PRODUCT_CATID
            FROM        
                PRODUCT_CAT
            WHERE     
                HIERARCHY LIKE '#i#%'
        </cfquery>
        <cfif get_cat.recordcount>
            <cfloop query="get_cat">
                <cfif ListFind(all_cat_list,get_cat.PRODUCT_CATID)>
                    <script type="text/javascript">
                        alert("#i# #get_cat.PRODUCT_CAT# Kategorisine Mükerrer Hedef Kota Uygulanmış");
                    </script>
                <cfelse>
                    <cfset all_cat_list = ListAppend(all_cat_list,get_cat.PRODUCT_CATID)>
                </cfif>
            </cfloop>
        </cfif>
    </cfoutput>
</cfloop>
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
			<cfif (isdefined('attributes.type') and (attributes.type eq 1 or attributes.type eq 3)) or not isdefined('attributes.type')>
            SELECT
                EVO.VIRTUAL_OFFER_NUMBER INVOICE_NUMBER,
                EVO.VIRTUAL_OFFER_DATE INVOICE_DATE,
                EVO.COMPANY_ID,
                0 AS NETTOTAL,
                0 AS GROSSTOTAL,
                EVOR.COST_PRICE,
                EVOR.COST_PRICE_MONEY, 
                EVO.VIRTUAL_OFFER_ID AS INVOICE_ID,
                EVOR.VIRTUAL_OFFER_ROW_ID AS INVOICE_ROW_ID, 
                EVOR.STOCK_ID,
                EVOR.PRODUCT_ID, 
                EVOR.QUANTITY AS AMOUNT,
                EVO.VIRTUAL_OFFER_EMPLOYEE_ID AS SALE_EMP,
                EVOR.PRICE LIST_PRICE,
                EVOR.OTHER_MONEY, 
                EVO.CONSUMER_ID, 
                EVO.EMPLOYEE_ID,
                EVOR.PRODUCT_NAME NAME_PRODUCT,
                EVOR.UNIT,
                ISNULL((
                        SELECT     
                            TOP (1) RATE2
                        FROM        
                            #dsn3_alias#.EZGI_VIRTUAL_OFFER_MONEY
                        WHERE     
                            ACTION_ID = EVO.VIRTUAL_OFFER_ID AND 
                            MONEY_TYPE = EVOR.OTHER_MONEY
                     ),1) AS OTHER_MONEY_RATE,
                     ISNULL((
                    SELECT     
                        TOP (1) RATE2
                    FROM        
                        #dsn3_alias#.EZGI_VIRTUAL_OFFER_MONEY
                    WHERE     
                        ACTION_ID = EVO.VIRTUAL_OFFER_ID AND 
                        MONEY_TYPE = ISNULL(EVOR.COST_PRICE_MONEY,'#session.ep.money#')
                 ),1) AS COST_RATE2,
                 ISNULL((
                    SELECT     
                        TOP (1) RATE2
                    FROM        
                        #dsn3_alias#.EZGI_VIRTUAL_OFFER_MONEY
                    WHERE     
                        ACTION_ID = EVO.VIRTUAL_OFFER_ID AND 
                        MONEY_TYPE = ISNULL(EVOR.PURCHASE_PRICE_MONEY,'#session.ep.money#')
                 ),1) AS PURCHASE_RATE2,
                EVOR.COST PROD_COST,
                PC.PRODUCT_CAT,
                PC.PRODUCT_CATID, 
                EVOR.PURCHASE_PRICE, 
                EVOR.PURCHASE_PRICE_MONEY,
                EVOR.DISCOUNT_1, 
                EVOR.DISCOUNT_2, 
                EVOR.DISCOUNT_3, 
                EVOR.DISCOUNT_COST, 
                1 AS TYPE   
            FROM        
                #dsn3_alias#.EZGI_VIRTUAL_OFFER_ROW AS EVOR INNER JOIN
                #dsn3_alias#.STOCKS AS S ON EVOR.STOCK_ID = S.STOCK_ID INNER JOIN
                #dsn1_alias#.PRODUCT_CAT AS PC ON S.PRODUCT_CATID = PC.PRODUCT_CATID INNER JOIN
                #dsn3_alias#.EZGI_VIRTUAL_OFFER AS EVO ON EVOR.VIRTUAL_OFFER_ID = EVO.VIRTUAL_OFFER_ID
            WHERE     
                EVO.VIRTUAL_OFFER_STATUS = 1 AND 
                ISNULL(EVO.IS_CANCEL,0) = 0 AND 
                EVO.REVISION_ID IS NULL AND
                MONTH(EVO.FINISHDATE) = #get_upd.MONTH_VALUE# AND 
                YEAR(EVO.FINISHDATE) = #get_upd.YEAR_VALUE# AND
                EVO.BRANCH_ID = #get_upd.BRANCH_ID# 
                <cfif len(get_stage_default.VIRTUAL_OFFER_STAGES_2)>
                    AND EVO.VIRTUAL_OFFER_STAGE NOT IN (#get_stage_default.VIRTUAL_OFFER_STAGES_2#)
                </cfif>
                <cfif isdefined('attributes.cat_id')>
                	<cfif attributes.type eq 3>
						AND PC.PRODUCT_CATID IN (#attributes.cat_id#)
					<cfelse>
                		AND PC.PRODUCT_CATID IN (#all_cat_list#)
                    </cfif>
                </cfif>
           	</cfif>
            <cfif not isdefined('attributes.type')>UNION ALL</cfif>
        	<cfif (isdefined('attributes.type') and attributes.type eq 2) or not isdefined('attributes.type')>
            SELECT    
                PAPER_NO AS INVOICE_NUMBER,    
                EIE.EXPENSE_DATE AS INVOICE_DATE, 
                EIP.CH_COMPANY_ID AS COMPANY_ID, 
                EIE.AMOUNT AS NETTOTAL, 
                EIE.AMOUNT AS GROSSTOTAL,
                0 AS COST_PRICE, 
                '' AS COST_PRICE_MONEY, 
                EIE.EXPENSE_ID AS INVOICE_ID, 
                EIE.EXP_ITEM_ROWS_ID AS INVOICE_ROW_ID, 
                EIE.EXPENSE_ITEM_ID AS STOCK_ID, 
                EIE.EXPENSE_ITEM_ID AS PRODUCT_ID, 
                1 AS AMOUNT, 
                EIP.EMP_ID AS SALE_EMP,
                EIE.AMOUNT AS LIST_PRICE, 
                'TL' AS OTHER_MONEY,
                EIP.CH_CONSUMER_ID AS CONSUMER_ID, 
                EIP.CH_EMPLOYEE_ID AS EMPLOYEE_ID, 
                EIE.DETAIL AS NAME_PRODUCT, 
                '' AS UNIT, 
                1 AS OTHER_MONEY_RATE,
                1 AS COST_RATE2,
                1 AS PURCHASE_RATE2, 
                0 AS PROD_COST, 
                EIC.EXPENSE_CAT_NAME AS PRODUCT_CAT, 
                EIC.EXPENSE_CAT_ID AS PRODUCT_CATID, 
                0 AS PURCHASE_PRICE, 
                '' AS PURCHASE_PRICE_MONEY,
                0 AS DISCOUNT_1, 
                0 AS DISCOUNT_2, 
                0 AS DISCOUNT_3, 
                0 AS DISCOUNT_COST,
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
             	ISNULL(EI.IS_EXPENSE,0) = 0
      	</cfif>
        ) AS O
   	ORDER BY
    	TYPE,
        INVOICE_DATE,
        INVOICE_NUMBER
</cfquery>
<cfform action="" method="post" name="gelir_detay">
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cf_box title="Gelir Detayları" right_images="">
            <cf_basket id="upd_bask">
                <cf_report_list sort="0">
                    <thead>
                        <tr height="20px">
                            <th width="25px"><cf_get_lang_main no='1165.Sıra'></th>
                            <th width="70px"><cf_get_lang_main no='56.Belge'></th>
                            <th width="65px"><cf_get_lang_main no='330.Tarih'></th>
                            <th width="65px"><cf_get_lang_main no='468.Belge No'></th>
                            <th><cf_get_lang_main no='45.Müşteri'></th>
                            <th width="150px" nowrap><cf_get_lang_main no='74.Kategori'></th>
                            <th><cf_get_lang_main no='245.Ürün'></th>
                            <th width="50px"><cf_get_lang_main no='223.Miktar'></th>
                            <th width="40px"><cf_get_lang_main no='224.Birim'></th>
                            <th width="80px"><cf_get_lang_main no='226.Birim Fiyat'></th>
                            <th width="80px"><cf_get_lang_main no='80.Toplam'></th>
                            <th width="80px"><cfoutput>#getLang('product',806)#</cfoutput></th>
                            <th width="90px"><cfoutput>#getLang('invoice',174)#</cfoutput></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfif get_sales_row.RECORDCOUNT>
                            <cfoutput query="get_sales_row">
                                <input name="list_type#currentrow#" id="list_type#currentrow#" type="hidden" value="#type#">
                                <input name="invoice_row_#type#" type="hidden" value="#INVOICE_ROW_ID#">
                                <tr height="20">
                                    <td style="text-align:right" nowrap>#currentrow#</td>
                                    <td nowrap <cfif type eq 1 and not ListFind(all_cat_list,PRODUCT_CATID)> title="Hedef Uygulanmayan Satış" style="background-color:red; color:white; font-weight:bold"</cfif> >
                                        <cfif type eq 1>
                                            Sanal Teklif
                                        <cfelse>
                                            Gelir Fişi
                                        </cfif>
                                    </td>
                                    <td style="text-align:center">#DateFormat(INVOICE_DATE,'DD/MM/YYYY')#</td>
                                    <td style="text-align:center">
                                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.upd_ezgi_virtual_offer&virtual_offer_id=#INVOICE_ID#','longpage');">#INVOICE_NUMBER#</a>
                                    </td>
                                    <td>#UNVAN#</td>
                                    <td nowrap>#PRODUCT_CAT#</td>
                                    <td>#NAME_PRODUCT#</td>
                                    <td style="text-align:right">#AmountFormat(Amount,2)#</td>
                                    <td>#UNIT#</td>
                                  	<cfset row_cost = ((COST_PRICE*cost_rate2))+(PROD_COST*OTHER_MONEY_RATE)>
                                  	<cfset row_purchase = ((PURCHASE_PRICE*purchase_rate2))+(PROD_COST*OTHER_MONEY_RATE)>
                                   	<cfset row_net_other_ = LIST_PRICE+PROD_COST-discount_cost>
                                  	<cfset row_net_other_ = row_net_other_*OTHER_MONEY_RATE>
                                   	<cfset row_net_other_ = row_net_other_-(row_net_other_*discount_1/100)>
                                  	<cfset row_net_other_ = row_net_other_-(row_net_other_*discount_2/100)>
                                   	<cfset row_net_other_ = row_net_other_-(row_net_other_*discount_3/100)>
                                  	<td style="text-align:right">#AmountFormat(row_net_other_,2)#</td>
                                  	<td style="text-align:right">#AmountFormat(row_net_other_*amount,2)#</td>
                                   	<td style="text-align:right" title="#AmountFormat(row_cost,2)#">#AmountFormat(row_cost*Amount,2)#</td>
                                  	<td style="text-align:right" title="#AmountFormat(row_purchase,2)#">#AmountFormat(row_purchase*Amount,2)#</td>
                                  	<cfset total_sales = total_sales + (row_net_other_*Amount)>
                                   	<cfset total_cost = total_cost + (Amount*row_cost)>
                                   	<cfset total_purchase = total_purchase + (Amount*row_purchase)>
                                </tr>
                            </cfoutput>
                            <tr>
                                <td colspan="10"><strong>Genel Toplam</strong></td>
                                <td style="text-align:right"><cfoutput><strong>#TlFormat(total_sales,2)#</strong></cfoutput></td>
                                <td style="text-align:right"><cfoutput><strong>#TlFormat(total_cost,2)#</strong></cfoutput></td>
                                <td style="text-align:right"><cfoutput><strong>#TlFormat(total_purchase,2)#</strong></cfoutput></td>
                            </tr>
                        </cfif>
                    </tbody>
                </cf_report_list>
            </cf_basket>
        </cf_box>
    </div>
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