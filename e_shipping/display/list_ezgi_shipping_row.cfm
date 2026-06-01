<cfquery name="get_orders_ship" datasource="#dsn3#">
	SELECT 
    	*
  	FROM
    	(
        SELECT     
            1 AS TYPE, 
            ORR.STOCK_ID, 
            ORR.SPECT_VAR_ID, 
            ORR.QUANTITY - ISNULL(ORR.DELIVER_AMOUNT, 0) AS BEKLEYEN, 
            ESR.OUT_DATE AS DELIVER_DATE, 
            CASE 
                WHEN O.COMPANY_ID IS NOT NULL THEN
                              (SELECT     NICKNAME
                                FROM          #dsn_alias#.COMPANY WITH (NOLOCK)
                                WHERE      COMPANY_ID = O.COMPANY_ID) 
                WHEN O.CONSUMER_ID IS NOT NULL THEN
                              (SELECT     CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                                FROM          #dsn_alias#.CONSUMER WITH (NOLOCK
                                WHERE      CONSUMER_ID = O.CONSUMER_ID) 
                WHEN O.EMPLOYEE_ID IS NOT NULL THEN
                              (SELECT     EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
                                FROM          #dsn_alias#.EMPLOYEES WITH (NOLOCK
                                WHERE      EMPLOYEE_ID = O.EMPLOYEE_ID) 
            END AS UNVAN, 
            ESR.SHIP_RESULT_ID, 
            ESR.DELIVER_PAPER_NO,
            O.ORDER_DATE
        FROM         
            EZGI_SHIP_RESULT AS ESR WITH (NOLOCK INNER JOIN
            EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
            ORDER_ROW AS ORR WITH (NOLOCK ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
            ORDERS AS O WITH (NOLOCK ON ORR.ORDER_ID = O.ORDER_ID
        WHERE     
            O.ORDER_STATUS = 1 AND 
            O.RESERVED = 1 AND 
            ((O.PURCHASE_SALES = 1 AND O.ORDER_ZONE = 0) OR (O.PURCHASE_SALES = 0 AND O.ORDER_ZONE = 1)) AND
            NOT (ORR.ORDER_ROW_CURRENCY IN (- 10, - 8, - 3, - 9)) AND 
            ORR.STOCK_ID IN (#attributes.stock_id#) 
        UNION ALL
        SELECT     
            2 AS TYPE, 
            ORR.STOCK_ID, 
            ORR.SPECT_VAR_ID, 
            ORR.QUANTITY - ISNULL(ORR.DELIVER_AMOUNT, 0) AS BEKLEYEN, 
            ESR.OUT_DATE AS DELIVER_DATE, 
            D.DEPARTMENT_HEAD AS UNVAN, 
            ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID, 
            CAST(ESR.SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) AS DELIVER_PAPER_NO,
            O.ORDER_DATE
        FROM         
            EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK INNER JOIN
            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
            ORDER_ROW AS ORR WITH (NOLOCK ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
            ORDERS AS O WITH (NOLOCK ON ORR.ORDER_ID = O.ORDER_ID LEFT JOIN
            #dsn_alias#.DEPARTMENT AS D ON D.DEPARTMENT_ID = ESR.DEPARTMENT_IN_ID
        WHERE     
            O.ORDER_STATUS = 1 AND 
            O.RESERVED = 1 AND 
            ((O.PURCHASE_SALES = 1 AND O.ORDER_ZONE = 0) OR (O.PURCHASE_SALES = 0 AND O.ORDER_ZONE = 1)) AND
            NOT (ORR.ORDER_ROW_CURRENCY IN (- 10, - 8, - 3, - 9)) AND 
            ORR.STOCK_ID IN (#attributes.stock_id#)
    	) AS TBL
   	<cfif isdefined('attributes.start_date')>
  	WHERE
    	DELIVER_DATE >= '#DateFormat(attributes.start_date,dateformat_style)#' 
        <cfif isdefined('attributes.finish_date')>
        	AND DELIVER_DATE < '#DateFormat(attributes.finish_date,dateformat_style)#'
       	</cfif>
   	</cfif>
	ORDER BY
    	DELIVER_DATE
</cfquery>
<table class="dph">
	<tr> 
		<td class="dpht"><cf_get_lang dictionary_id='758.Sevkiyat Rezerve Kontrol'></td>
	</tr>
</table>
<cfsavecontent variable="sevk_belge"><cf_get_lang dictionary_id='759.Sevk Belgeleri'></cfsavecontent>
<cf_seperator id="iliskili_fatura" header="#sevk_belge#">
<table id="iliskili_fatura" width="100%">
	<tr>
		<td>
			<cf_medium_list>
				<thead>
					<tr> 
                   		<th><cf_get_lang dictionary_id='58577.Sıra'></th>
						<th><cf_get_lang dictionary_id='382.Sevk Plan No'></th>
                  		<th><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></th>
						<th><cf_get_lang dictionary_id='1089.Sevk Plan Tarihi'></th>
						<th><cf_get_lang dictionary_id='57457.Müşteri'></th>
						<th width="50" style="text-align:right;"><cf_get_lang dictionary_id='57635.Miktar'></th>
					</tr>
				</thead>
				<tbody>
        			<cfset toplam_bekleyen = 0>
					<cfif get_orders_ship.recordcount>
                       	<cfoutput query="get_orders_ship">
                         	<tr>
                           		<td>#currentrow#</td>
                              	<td style="text-align:center;">
                                  	<cfif TYPE eq 1>
                                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping&iid=#SHIP_RESULT_ID#','page');" class="tableyazi" title="<cf_get_lang_main no='3528.Sevk Fişine Git'>">
                                        	#DELIVER_PAPER_NO#
                                        </a>
                                    <cfelse>
                                    	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=stock.upd_dispatch_internaldemand&ship_id=#DELIVER_PAPER_NO#','longpage');" class="tableyazi" title="<cf_get_lang_main no='3531.Sevk Talebine Git'>">
                                       		#DELIVER_PAPER_NO#
                                    	</a>
                                    </cfif>    	
                              	</td>
                             	<td style="text-align:center;">#DateFormat(ORDER_DATE,'dd/mm/yyyy')#</td>
                                <td style="text-align:center;">#DateFormat(DELIVER_DATE,'dd/mm/yyyy')#</td>
                              	<td>#UNVAN#</td>
                             	<td style="text-align:right;">#TLFormat(bekleyen)#</td>
                           	</tr>
                          	<cfset toplam_bekleyen = toplam_bekleyen + bekleyen>
                      	</cfoutput>
                    	<tr>
                        	<cfoutput>
                            	<td colspan="5"><strong><cf_get_lang dictionary_id='57492.Toplam'></strong></td>
                                <td style="text-align:right;"><strong>#TLFormat(toplam_bekleyen)#</strong></td>
                          	</cfoutput>
                     	</tr>
					</cfif>
				</tbody>
			</cf_medium_list>
  		</td>
	</tr>
</table>
