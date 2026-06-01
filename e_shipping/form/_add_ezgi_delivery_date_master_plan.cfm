<CFSET avangarde_daily_point = 8><!---Avangard Koltuk Üretimi Günlük Puanı--->
<cfquery name="get_order_det" datasource="#DSN3#">
	SELECT     
    	ORR.STOCK_ID, 
        ORR.QUANTITY, 
        ORR.ORDER_ROW_ID, 
        ORD.ORDER_ID, 
        ORR.SPECT_VAR_ID, 
        ORR.SPECT_VAR_NAME, 
        S.PRODUCT_NAME, 
        S.STOCK_CODE, 
    	S.STOCK_CODE_2, 
        ORR.DELIVER_DATE, 
        ISNULL(PO.PRODUCTION_LEVEL, 0) AS PRODUCTION_LEVEL, 
        PO.LOT_NO, 
        EMAP.PLAN_TYPE, 
        PO.START_DATE, 
    	PO.P_ORDER_ID,
        ISNULL((SELECT PROPERTY2 FROM PRODUCT_TREE_INFO_PLUS WHERE STOCK_ID = ORR.STOCK_ID),0) AS PUAN<!---,
        ISNULL(S.SHORT_CODE_ID,0) AS AVANGARDE--->
	FROM         
    	PRODUCTION_ORDERS AS PO INNER JOIN
      	PRODUCTION_ORDERS_ROW AS PORR ON PO.P_ORDER_ID = PORR.PRODUCTION_ORDER_ID INNER JOIN
      	EZGI_MASTER_PLAN_RELATIONS AS EMPR ON PO.P_ORDER_ID = EMPR.P_ORDER_ID INNER JOIN
     	EZGI_MASTER_ALT_PLAN AS EMAP ON EMPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID RIGHT OUTER JOIN
      	ORDER_ROW AS ORR INNER JOIN
       	ORDERS AS ORD ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
       	STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID ON PORR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
	WHERE     
    	ORD.ORDER_ID = #attributes.order_id# AND 
        ISNULL(S.IS_PROTOTYPE,0) = 1 AND 
        ISNULL(PO.PRODUCTION_LEVEL, 0) = N'0'
	ORDER BY 
    	S.PRODUCT_NAME
</cfquery>
<!---<cfdump expand="yes" var="#get_order_det#">--->
<cfquery name="get_delivered_days" datasource="#dsn3#">
	SELECT   
    	CONVERT(VARCHAR(10),PLAN_START_DATE,110) AS PLAN_START_DATE,
        SUM(W_POINT) AS W_POINT, 
        SUM(TOTAL_POINT) AS TOTAL_POINT<!---,
        SUM(AVANGARDE) AS AVANGARDE--->
	FROM         
    	(
        SELECT     
            EZGI_MASTER_ALT_PLAN.PLAN_START_DATE, 
            ISNULL(EZGI_MASTER_ALT_PLAN.PLAN_POINT, 0) AS W_POINT, 
            ISNULL(
                (
                    SELECT     
                        SUM(PO.QUANTITY * ISNULL(PTIP.PROPERTY2, 0)) AS P_POINT
                    FROM         
                        EZGI_MASTER_PLAN_RELATIONS AS EMPR INNER JOIN
                        PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID LEFT OUTER JOIN
                        PRODUCT_TREE_INFO_PLUS AS PTIP ON PO.STOCK_ID = PTIP.STOCK_ID
                    WHERE     
                        EMPR.MASTER_ALT_PLAN_ID = EZGI_MASTER_ALT_PLAN.MASTER_ALT_PLAN_ID AND
                        PO.STOCK_ID IN (SELECT STOCK_ID FROM STOCKS WHERE SHORT_CODE_ID IS NULL)
                )
            , 0) AS TOTAL_POINT<!---,
            ISNULL(
                (
                    SELECT     
                        SUM(PO.QUANTITY * ISNULL(PTIP.PROPERTY2, 0)) AS P_POINT
                    FROM         
                        EZGI_MASTER_PLAN_RELATIONS AS EMPR INNER JOIN
                        PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID LEFT OUTER JOIN
                        PRODUCT_TREE_INFO_PLUS AS PTIP ON PO.STOCK_ID = PTIP.STOCK_ID
                    WHERE     
                        EMPR.MASTER_ALT_PLAN_ID = EZGI_MASTER_ALT_PLAN.MASTER_ALT_PLAN_ID AND
                        PO.STOCK_ID IN (SELECT STOCK_ID FROM STOCKS WHERE SHORT_CODE_ID = 1)
                )
            , 0) AS AVANGARDE--->
        FROM         
            EZGI_MASTER_ALT_PLAN INNER JOIN
            EZGI_MASTER_PLAN ON EZGI_MASTER_ALT_PLAN.MASTER_PLAN_ID = EZGI_MASTER_PLAN.MASTER_PLAN_ID INNER JOIN
            EZGI_MASTER_PLAN_SABLON ON EZGI_MASTER_ALT_PLAN.PROCESS_ID = EZGI_MASTER_PLAN_SABLON.PROCESS_ID
        WHERE     
            <!---EZGI_MASTER_PLAN.MASTER_PLAN_CAT_ID = 3 AND --->
            EZGI_MASTER_PLAN_SABLON.SIRA = 1 AND 
            EZGI_MASTER_ALT_PLAN.PLAN_START_DATE >= #now()# AND 
            EZGI_MASTER_ALT_PLAN.PLAN_TYPE = 0
        UNION ALL
        SELECT     
        	CASE 
            	WHEN 
                	ORR.DELIVER_DATE IS NULL THEN EMAP.PLAN_START_DATE 
                ELSE 
                	ORR.DELIVER_DATE 


          	END AS START_DATE, 
            0 AS W_POINT, 
            ISNULL(
            	(
                	SELECT     
                    	SUM(PO.QUANTITY * ISNULL(PTIP.PROPERTY2, 0)) AS P_POINT
                  	FROM         
                    	EZGI_MASTER_PLAN_RELATIONS AS EMPR INNER JOIN
                        PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID LEFT OUTER JOIN
                        PRODUCT_TREE_INFO_PLUS AS PTIP ON PO.STOCK_ID = PTIP.STOCK_ID
                 	WHERE     
                    	EMPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID AND
                        PO.STOCK_ID IN (SELECT STOCK_ID FROM STOCKS WHERE SHORT_CODE_ID IS NULL)
              	)
     		, 0) AS TOTAL_POINT<!---,
            ISNULL(
            	(
                	SELECT     
                    	SUM(PO.QUANTITY * ISNULL(PTIP.PROPERTY2, 0)) AS P_POINT
                  	FROM         
                    	EZGI_MASTER_PLAN_RELATIONS AS EMPR INNER JOIN
                        PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID LEFT OUTER JOIN
                        PRODUCT_TREE_INFO_PLUS AS PTIP ON PO.STOCK_ID = PTIP.STOCK_ID
                 	WHERE     
                    	EMPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID AND
                        PO.STOCK_ID IN (SELECT STOCK_ID FROM STOCKS WHERE SHORT_CODE_ID = 1)
              	)
     		, 0) AS AVANGARDE--->
		FROM         
        	EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
            EZGI_MASTER_PLAN AS EMP ON EMAP.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID INNER JOIN
            EZGI_MASTER_PLAN_SABLON AS EMPS ON EMAP.PROCESS_ID = EMPS.PROCESS_ID INNER JOIN
            EZGI_MASTER_PLAN_RELATIONS AS EMPR ON EMAP.MASTER_ALT_PLAN_ID = EMPR.MASTER_ALT_PLAN_ID INNER JOIN
            PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
            PRODUCTION_ORDERS_ROW AS PORR ON PO.P_ORDER_ID = PORR.PRODUCTION_ORDER_ID INNER JOIN
            ORDER_ROW AS ORR ON PORR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
		WHERE     
        	<!---EMP.MASTER_PLAN_CAT_ID = 3 AND --->
            EMPS.SIRA = 1 AND 
            EMAP.PLAN_START_DATE >= #now()# AND 
          	EMAP.PLAN_TYPE = 1 
        UNION ALL
        SELECT     
        	O.DELIVERDATE AS START_DATE, 
            0 AS W_POINT, 
            PT.PROPERTY2 AS TOTAL_POINT<!---,
            0 AS AVANGARDE--->
    	FROM         
        	ORDER_ROW AS ORR INNER JOIN
        	ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
         	STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
          	PRODUCT_TREE_INFO_PLUS AS PT ON S.STOCK_ID = PT.STOCK_ID LEFT OUTER JOIN
         	PRODUCTION_ORDERS_ROW AS PORR ON ORR.ORDER_ROW_ID = PORR.ORDER_ROW_ID LEFT OUTER JOIN
         	PRODUCTION_ORDERS AS PO ON PORR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
   		 WHERE     
         	PO.P_ORDER_ID IS NULL AND 
            O.ORDER_STATUS = 1 AND 
            O.PURCHASE_SALES = 1 AND 
            S.STOCK_CODE LIKE N'01.152.02.%' AND 
         	O.ORDER_DATE > CONVERT(DATETIME, '2015-01-01 00:00:00', 102) AND 
            ORR.DELIVER_DATE > CONVERT(DATETIME, '2015-01-01 00:00:00', 102) AND 
          	ORR.ORDER_ROW_CURRENCY = - 5 <!---AND
          	ORR.STOCK_ID IN (SELECT STOCK_ID FROM STOCKS WHERE SHORT_CODE_ID IS NULL)--->
        <!---UNION ALL
        SELECT     
        	O.DELIVERDATE AS START_DATE, 
            0 AS W_POINT, 
            0 AS TOTAL_POINT,
            PT.PROPERTY2 AS AVANGARDE
    	FROM         
        	ORDER_ROW AS ORR INNER JOIN
        	ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
         	STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
          	PRODUCT_TREE_INFO_PLUS AS PT ON S.STOCK_ID = PT.STOCK_ID LEFT OUTER JOIN
         	PRODUCTION_ORDERS_ROW AS PORR ON ORR.ORDER_ROW_ID = PORR.ORDER_ROW_ID LEFT OUTER JOIN
         	PRODUCTION_ORDERS AS PO ON PORR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
   		 WHERE     
         	PO.P_ORDER_ID IS NULL AND 
            O.ORDER_STATUS = 1 AND 
            O.PURCHASE_SALES = 1 AND 
            S.STOCK_CODE LIKE N'01.152.02.%' AND 
         	O.ORDER_DATE > CONVERT(DATETIME, '2015-01-01 00:00:00', 102) AND 
            ORR.DELIVER_DATE > CONVERT(DATETIME, '2015-01-01 00:00:00', 102) AND 
          	ORR.ORDER_ROW_CURRENCY = - 5 AND
          	ORR.STOCK_ID IN (SELECT STOCK_ID FROM STOCKS WHERE SHORT_CODE_ID = 1)--->
     	) AS TBL
	GROUP BY 
    	CONVERT(VARCHAR(10),PLAN_START_DATE,110) 
   	ORDER BY
    	PLAN_START_DATE DESC
</cfquery>
<!---<cfdump expand="yes" var="#get_delivered_days#">--->
<cfset order_row_id_list = Valuelist(get_order_det.ORDER_ROW_ID)>
<cfset amount_round = 2>	
<table class="dph">
	<tr> 
		<td class="dpht"><cf_get_lang dictionary_id='1118.Sipariş Termin Hesaplama'></td>
	</tr>
</table>
<cf_seperator id="iliskili_fatura" header="Koltuk Siparişleri">
<table id="iliskili_fatura" width="100%">
	<tr>
		<td>
			<cf_medium_list>
				<thead>
					<tr> 
                    	<th width="110"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
						<th><cf_get_lang dictionary_id='57657.Ürün'></th>
						<th width="40" style="text-align:right;"><cf_get_lang dictionary_id='57611.Sipariş'></th>
                        <th width="40"><cf_get_lang dictionary_id='36046.Lot No'></th>
                        <th width="70"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></th>
                        <th width="80"><cf_get_lang dictionary_id='290.Termin Tarihi'></th>
                        <th width="25"></th>
					</tr>
				</thead>
				<tbody>
					<cfif get_order_det.recordcount>
                        <cfform name="delivery_date" action="" method="post">
                            <cfoutput query="get_order_det">
                                <tr>
                                	<td>#STOCK_CODE#</td>
                                    <td>#PRODUCT_NAME#</td>
                                    <td style="text-align:right;">#TLFormat(QUANTITY,amount_round)#</td>
                                    <td style="text-align:center;">#LOT_NO#</td>
                                    <td style="text-align:center;">#DateFormat(START_DATE,'DD/MM/YYYY')#</td>
                                    <td style="text-align:center;">
                                    	<!---<cfif AVANGARDE eq 0>
											<cfif not len(P_ORDER_ID)>
                                                <cfif len(DELIVER_DATE)> 
                                                    #DateFormat(DELIVER_DATE,'DD/MM/YYYY')#
                                                <cfelse>
                                                    <select name="delivery_date_#ORDER_ROW_ID#" onChange="upd_delivery_date(#ORDER_ROW_ID#);">
                                                        <option value="">Seçiniz</option>
                                                        
                                                        <cfloop query="get_delivered_days">
                                                        	<cfif get_delivered_days.w_point gt 0>
                                                            	<cfset puan_durum = get_delivered_days.w_point-get_delivered_days.total_point-get_delivered_days.avangarde-get_order_det.puan>
																<cfif dayofweek(get_delivered_days.PLAN_START_DATE) eq 1 or dayofweek(get_delivered_days.PLAN_START_DATE) eq 7>
                                                                    <cfset gun_durum = 0>
                                                                <cfelse>
                                                                    <cfif puan_durum gte 0>
                                                                        <cfset gun_durum = 1>
                                                                    <cfelse>
                                                                        <cfset gun_durum = 2>
                                                                    </cfif>
                                                                </cfif>
                                                            <cfelse>
                                                            	<cfset gun_durum = 2>
                                                            </cfif>
                                                            <option value="#gun_durum#_#get_delivered_days.PLAN_START_DATE#" <cfif gun_durum eq 0>style="background-color:blue"<cfelseif gun_durum eq 2>style="background-color:red"<cfelse>style="background-color:green"</cfif>>
                                                                #DateFormat(get_delivered_days.PLAN_START_DATE,'DD/MM')#
                                                            </option>
                                                        </cfloop>
                                                    </select>
                                                </cfif>
                                            <cfelse>
                                                #DateFormat(DELIVER_DATE,'DD/MM/YYYY')#
                                            </cfif>
                                        <cfelse>--->
                                        	<cfif not len(P_ORDER_ID)>
                                                <cfif len(DELIVER_DATE)> 
                                                    #DateFormat(DELIVER_DATE,'DD/MM/YYYY')#
                                                <cfelse>
                                                    <select name="delivery_date_#ORDER_ROW_ID#" onChange="upd_delivery_date(#ORDER_ROW_ID#);">
                                                        <option value="">Seçiniz</option>
                                                        <cfloop query="get_delivered_days">
                                                        	<cfif get_delivered_days.w_point gt 0>
																<cfset puan_durum = get_order_det.puan>
                                                                <cfif dayofweek(get_delivered_days.PLAN_START_DATE) eq 1 or dayofweek(get_delivered_days.PLAN_START_DATE) eq 7>
                                                                    <cfset gun_durum = 0>
                                                                <cfelse>
                                                                    <cfif puan_durum gt 0>
                                                                        <cfset gun_durum = 1>
                                                                    <cfelse>
                                                                        <cfset gun_durum = 2>
                                                                    </cfif>
                                                                </cfif>
                                                            <cfelse>
                                                            	<cfset gun_durum = 2>
                                                            </cfif>
                                                            <option value="#gun_durum#_#get_delivered_days.PLAN_START_DATE#" <cfif gun_durum eq 0>style="background-color:blue"<cfelseif gun_durum eq 2>style="background-color:red"<cfelse>style="background-color:green"</cfif>>
                                                                #DateFormat(get_delivered_days.PLAN_START_DATE,'DD/MM')#
                                                            </option>
                                                        </cfloop>
                                                    </select>
                                                </cfif>
                                            <cfelse>
                                                #DateFormat(DELIVER_DATE,'DD/MM/YYYY')#
                                            </cfif>
                                        <!---</cfif>--->
                                    </td>
                                    <td style="text-align:center;">
                                    	<cfif not len(P_ORDER_ID)>
                                        	<cfif len(DELIVER_DATE)>                                        
                                    			<a style="cursor:pointer;" onclick="sil_delivery_date('#ORDER_ROW_ID#');"><img src="images/delete_list.gif" border="0" align="absmiddle" title="Termin Tarihi Sil"></a>
                                            </cfif>    
                                       	<cfelse>
                                        	<cfif PLAN_TYPE eq 1>
                                            	<img src="images/d_ok.gif" border="0" align="absmiddle" title="<cf_get_lang dictionary_id='1106.Üretim Planına Alınıyor'>">
                                            <cfelse>
                                            	<img src="images/c_ok.gif" border="0" align="absmiddle" title="<cf_get_lang dictionary_id='1107.Üretim Planlandı'>">
                                            </cfif>
                                        </cfif>
                                    </td>
                                </tr>
                            </cfoutput>
                        </cfform>
                    </cfif>
				</tbody>
                <tfoot>
                	<tr class="color-list" height="35">
                      	<td align="right" valign="middle" colspan="13">&nbsp;</td>
                   	</tr>
              	</tfoot>
			</cf_medium_list>
      	</td>      
	</tr>
</table>
<script type="text/javascript">
	function sil_delivery_date(upd_id)
	{
		window.location ='<cfoutput>#request.self#?fuseaction=sales.emptypopup_del_ezgi_delivery_date_master_plan&order_id=#attributes.order_id#</cfoutput>&upd='+upd_id;
	}
	function upd_delivery_date(upd_id)
	{
		window.location ='<cfoutput>#request.self#?fuseaction=sales.emptypopup_upd_ezgi_delivery_date_master_plan&order_id=#attributes.order_id#</cfoutput>&upd='+upd_id+'&delivery_date='+eval('document.delivery_date.delivery_date_'+upd_id).value;
	}
</script>