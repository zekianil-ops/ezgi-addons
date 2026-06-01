<cfquery name="get_general_info" datasource="#dsn#">
	SELECT ISNULL(IS_SERIAL_CONTROL_LOCATION,0) AS IS_SERIAL_CONTROL_LOCATION FROM OUR_COMPANY_INFO WHERE COMP_ID = #session.ep.company_id#
</cfquery>
<cfquery name="get_order_det1" datasource="#DSN3#">
	<cfif get_general_info.IS_SERIAL_CONTROL_LOCATION>
    	<!---1- Seri No Ürünler Sadece Depodaki Ürünü ve Üretim Planlarını Rezerve ederler
        2- Seri No Karma Ürünler e ait Paketler Sadece El Terminali İle Depodaki Hazır Ürünü Rezerve eder.
        3- Standart Karma Ürün Satınalma Siparişini Rezerve Eder.
        4- Standart Ürün Üretim Plan(lar)ını Rezerve eder.
        5- Standart Ürün Satınalam Siparişini Satış Miktarı Kadar rezerve eder.--->
        
		<!---Seri no Sipariş - Üretim Planı veya Depodan Bağlantılı--->
        SELECT 
            ISNULL(EWM.PRODUCTION_ORDER_ROW_ID,0) AS PRODUCTION_ORDER_ROW_ID,
            EWM.SERIAL_NO,
            ORR.STOCK_ID, 
            ORR.QUANTITY, 
            ORR.ORDER_ROW_ID, 
            ORD.ORDER_ID, 
            ORD.ORDER_HEAD, 
            ORD.ORDER_NUMBER, 
            ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
            ORR.SPECT_VAR_NAME, 
            ORR.ORDER_ROW_CURRENCY, 
            S.PRODUCT_NAME, 
            S.STOCK_CODE, 
            S.STOCK_CODE_2,
            PO.LOT_NO, 
            PO.FINISH_DATE, 
            PO.P_ORDER_ID,
            11 AS TYPE,
            1 AS AMOUNT, 
            S.IS_PROTOTYPE,
            ISNULL(S.IS_KARMA,0) AS IS_KARMA,
            ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO, 
            ORR.PRODUCT_NAME2
        FROM     
            ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
            STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
            ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
            EZGI_WM_ORDER_LAST_STATUS AS EWM ON ORR.ORDER_ROW_ID = EWM.ORDER_ROW_ID LEFT OUTER JOIN
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EWM.P_ORDER_ID = PO.P_ORDER_ID
        WHERE  
            ORD.ORDER_ID = #attributes.order_id# AND 
            ISNULL(PO.PRODUCTION_LEVEL, 0) = '0' AND 
            S.IS_PRODUCTION = 1 AND 
            ISNULL(S.IS_SERIAL_NO, 0) = 1
        UNION ALL
    </cfif>
    <!---Lot No - Karma Olmayan Sipariş - Üretim Planı--->
	SELECT
    	0 AS PRODUCTION_ORDER_ROW_ID,    
        '' AS SERIAL_NO, 
    	ORR.STOCK_ID, 
        ORR.QUANTITY, 
        ORR.ORDER_ROW_ID, 
        ORD.ORDER_ID, 
        ORD.ORDER_HEAD, 
        ORD.ORDER_NUMBER, 
        ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
        ORR.SPECT_VAR_NAME, 
        ORR.ORDER_ROW_CURRENCY,
        S.PRODUCT_NAME, 
        S.STOCK_CODE, 
        S.STOCK_CODE_2, 
        PO.LOT_NO, 
        PO.FINISH_DATE, 
        PO.P_ORDER_ID, 
        POR.TYPE,
        SUM(PO.QUANTITY) AMOUNT,
        S.IS_PROTOTYPE,
        ISNULL(S.IS_KARMA,0) AS IS_KARMA,
        ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO,
        ORR.PRODUCT_NAME2
	FROM         
    	ORDERS AS ORD WITH (NOLOCK) RIGHT OUTER JOIN
      	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
       	STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
       	PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
       	PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) ON PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID ON ORR.ORDER_ROW_ID = POR.ORDER_ROW_ID ON ORD.ORDER_ID = ORR.ORDER_ID
	WHERE     
    	ORD.ORDER_ID = #attributes.order_id# AND 
        ISNULL(PO.PRODUCTION_LEVEL, 0) = N'0' AND
        ISNULL(S.IS_PRODUCTION,0) = 1 AND
      	ISNULL(S.IS_SERIAL_NO,0) =0 AND
        ISNULL(S.IS_KARMA,0) = 0
  	GROUP BY
    	ORR.STOCK_ID, 
        ORR.QUANTITY, 
        ORR.ORDER_ROW_ID, 
        ORD.ORDER_ID, 
        ORD.ORDER_HEAD, 
        ORD.ORDER_NUMBER, 
        ORR.SPECT_VAR_ID,
        ORR.SPECT_VAR_NAME, 
        ORR.ORDER_ROW_CURRENCY,
        S.PRODUCT_NAME, 
        S.STOCK_CODE, 
        S.STOCK_CODE_2, 
        PO.LOT_NO, 
        PO.FINISH_DATE, 
        PO.P_ORDER_ID, 
        POR.TYPE,
        S.IS_PROTOTYPE,
      	S.IS_KARMA,
        S.IS_SERIAL_NO,
        ORR.PRODUCT_NAME2
	UNION ALL
    <!---Lot No Sipariş - Satınalma Siparişi Otomatik Bağlama--->
	SELECT  
    	0 AS PRODUCTION_ORDER_ROW_ID,   
        '' AS SERIAL_NO,  
    	ORR.STOCK_ID, 
        ORR.QUANTITY, 
        ORR.ORDER_ROW_ID, 
        ORD.ORDER_ID, 
        ORD.ORDER_HEAD, 
        ORD.ORDER_NUMBER, 
        ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
        ORR.SPECT_VAR_NAME,
        ORR.ORDER_ROW_CURRENCY, 
        S.PRODUCT_NAME, 
        S.STOCK_CODE, 
        S.STOCK_CODE_2, 
        CAST(O1.ORDER_ID AS VARCHAR) AS LOT_NO, 
        ISNULL(ORR1.DELIVER_DATE,O1.DELIVERDATE) AS FINISH_DATE, 
        O1.ORDER_ID AS P_ORDER_ID, 
        3 AS TYPE,
        ORR.QUANTITY AS AMOUNT,
        S.IS_PROTOTYPE,
        ISNULL(S.IS_KARMA,0) AS IS_KARMA,
        ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO,
        ORR.PRODUCT_NAME2
	FROM         
    	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
        ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
        STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
        ORDER_ROW AS ORR1 WITH (NOLOCK) ON ORR.WRK_ROW_ID = ORR1.WRK_ROW_RELATION_ID INNER JOIN
        ORDERS AS O1 WITH (NOLOCK) ON ORR1.ORDER_ID = O1.ORDER_ID
	WHERE     
    	ORD.ORDER_ID = #attributes.order_id# AND 
        S.IS_PURCHASE = 1 AND
     	ISNULL(S.IS_SERIAL_NO,0) =0
  	GROUP BY
    	ORR.STOCK_ID, 
        ORR.QUANTITY, 
        ORR.ORDER_ROW_ID, 
        ORD.ORDER_ID, 
        ORD.ORDER_HEAD, 
        ORD.ORDER_NUMBER, 
        ORR.SPECT_VAR_ID,
        ORR.SPECT_VAR_NAME,
        ORR.ORDER_ROW_CURRENCY, 
        S.PRODUCT_NAME, 
        S.STOCK_CODE, 
        S.STOCK_CODE_2, 
        O1.ORDER_NUMBER, 
        O1.ORDER_DATE,
        O1.ORDER_ID,
        O1.DELIVERDATE,
        ORR1.DELIVER_DATE,
        S.IS_PROTOTYPE,
    	S.IS_KARMA,
        S.IS_SERIAL_NO,
        ORR.PRODUCT_NAME2
  	UNION ALL
    <!---Lot No Sipariş - Satınalma Siparişi Manuel Bağlama--->
 	SELECT  
        0 AS PRODUCTION_ORDER_ROW_ID,   
        '' AS SERIAL_NO,    
    	ORR.STOCK_ID, 
        ORR.QUANTITY, 
        ORR.ORDER_ROW_ID, 
        ORD.ORDER_ID, 
        ORD.ORDER_HEAD, 
        ORD.ORDER_NUMBER, 
        ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
        ORR.SPECT_VAR_NAME, 
        ORR.ORDER_ROW_CURRENCY,
        S.PRODUCT_NAME, 
        S.STOCK_CODE, 
        S.STOCK_CODE_2, 
        CAST(ORD1.ORDER_ID AS VARCHAR) AS LOT_NO, 
        ORD1.ORDER_DATE AS FINISH_DATE, 
        ORD1.ORDER_ID AS P_ORDER_ID, 
        4 AS TYPE,
        ORR.QUANTITY AS AMOUNT,
        S.IS_PROTOTYPE,
        ISNULL(S.IS_KARMA,0) AS IS_KARMA,
        ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO,
        ORR.PRODUCT_NAME2
	FROM         
    	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
        ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
        STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
        EZGI_ORDERS_ORDERS_REL WITH (NOLOCK) ON ORR.ORDER_ROW_ID = EZGI_ORDERS_ORDERS_REL.S_ORDER_ROW_ID AND 
        ORR.ORDER_ID = EZGI_ORDERS_ORDERS_REL.S_ORDER_ID INNER JOIN
        ORDER_ROW AS ORR1 WITH (NOLOCK) ON EZGI_ORDERS_ORDERS_REL.P_ORDER_ID = ORR1.ORDER_ID AND 
        EZGI_ORDERS_ORDERS_REL.P_ORDER_ROW_ID = ORR1.ORDER_ROW_ID INNER JOIN
        ORDERS AS ORD1 WITH (NOLOCK) ON ORR1.ORDER_ID = ORD1.ORDER_ID
	WHERE     
    	ORD.ORDER_ID = #attributes.order_id# AND 
        (S.IS_PRODUCTION = 1 OR S.IS_PURCHASE = 1) AND
     	ISNULL(S.IS_SERIAL_NO,0) =0
  	GROUP BY
    	ORR.STOCK_ID, 
        ORR.QUANTITY, 
        ORR.ORDER_ROW_ID, 
        ORD.ORDER_ID, 
        ORD.ORDER_HEAD, 
        ORD.ORDER_NUMBER, 
        ORR.SPECT_VAR_ID,
        ORR.SPECT_VAR_NAME, 
        ORR.ORDER_ROW_CURRENCY,
        S.PRODUCT_NAME, 
        S.STOCK_CODE, 
        S.STOCK_CODE_2, 
        ORD1.ORDER_NUMBER, 
        ORD1.ORDER_DATE, 
        ORD1.ORDER_ID,
        S.IS_PROTOTYPE,
        S.IS_KARMA,
        S.IS_SERIAL_NO,
        ORR.PRODUCT_NAME2
   	UNION ALL
    <!---Lot No - Karma Sipariş - Üretim Demonte Ürün Bağlama--->
    SELECT 
        0 AS PRODUCTION_ORDER_ROW_ID,   
        '' AS SERIAL_NO,  
    	STOCK_ID, 
        QUANTITY, 
        ORDER_ROW_ID, 
        ORDER_ID, 
        ORDER_HEAD, 
        ORDER_NUMBER, 
        SPECT_VAR_ID, 
        SPECT_VAR_NAME, 
        ORDER_ROW_CURRENCY, 
        PRODUCT_NAME, 
        STOCK_CODE, 
        STOCK_CODE_2, 
        LOT_NO, 
        FINISH_DATE, 
        P_ORDER_ID, 
        TYPE, 
        SUM(AMOUNT) AS AMOUNT,
        IS_PROTOTYPE, 
       	IS_KARMA,
     	IS_SERIAL_NO,
        PRODUCT_NAME2
	FROM     
    	(
        	SELECT DISTINCT 
           		ORR.STOCK_ID, 
                ORR.QUANTITY, 
                ORR.ORDER_ROW_ID, 
                ORD.ORDER_ID, 
                ORD.ORDER_HEAD, 
                ORD.ORDER_NUMBER, 
                ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
                ORR.SPECT_VAR_NAME, 
                ORR.ORDER_ROW_CURRENCY, 
                S.PRODUCT_NAME, 
                S.STOCK_CODE, 
                S.STOCK_CODE_2,
                ISNULL(S.IS_KARMA,0) AS IS_KARMA,
        		ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO,
                S.IS_PROTOTYPE, 
                PO.LOT_NO, 
                EMP.MASTER_PLAN_FINISH_DATE AS FINISH_DATE, 
                EP.IFLOW_P_ORDER_ID AS P_ORDER_ID, 
                6 AS TYPE, 
                EP.QUANTITY AS AMOUNT, 
               	ORR.PRODUCT_NAME2
     		FROM      
            	EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) INNER JOIN
                PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EP.LOT_NO = PO.LOT_NO INNER JOIN
                PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) ON PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID INNER JOIN
                ORDER_ROW AS ORR ON POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
                STOCKS AS S ON EP.STOCK_ID = S.STOCK_ID INNER JOIN
                EZGI_IFLOW_MASTER_PLAN AS EMP ON EP.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID
         	WHERE   
            	ORD.ORDER_ID = #attributes.order_id# AND 
        		ISNULL(S.IS_KARMA,0) = 1 
    	) AS TBL
	GROUP BY 
    	STOCK_ID, 
     	QUANTITY, 
    	ORDER_ROW_ID, 
     	ORDER_ID, 
      	ORDER_HEAD, 
      	ORDER_NUMBER, 
     	SPECT_VAR_ID, 
      	SPECT_VAR_NAME, 
     	ORDER_ROW_CURRENCY, 
        PRODUCT_NAME,
      	STOCK_CODE, 
      	STOCK_CODE_2, 
   		LOT_NO, 
     	FINISH_DATE, 
      	P_ORDER_ID, 
      	TYPE, 
        IS_PROTOTYPE,
        IS_KARMA,
     	IS_SERIAL_NO,
     	PRODUCT_NAME2
</cfquery>
<!---<cfdump var="#get_order_det1#">--->
<cfif get_order_det1.recordcount>
	<cfoutput query="get_order_det1">
        <cfset 'FINISH_DATE_#TYPE#_#LOT_NO#_#ORDER_ROW_ID#'= FINISH_DATE>
    </cfoutput>
    <cfif isdefined('attributes.planning')>
        <cfquery name="get_order_det" dbtype="query">
            SELECT FINISH_DATE FROM get_order_det1 ORDER BY FINISH_DATE DESC
        </cfquery>
        <cfif get_order_det.recordcount>
            <cfset attributes.deliver_date=get_order_det.FINISH_DATE>
        <cfelse>
            <cfset attributes.deliver_date=''>
        </cfif>
  	</cfif>
<cfelse>
	<cfset attributes.deliver_date=''>
</cfif>
<cfset order_row_id_list = Valuelist(get_order_det1.ORDER_ROW_ID)>
<cfquery name="orders_info" datasource="#dsn3#">
  	SELECT DELIVERDATE,ORDER_DETAIL FROM ORDERS WITH (NOLOCK) WHERE ORDER_ID = #attributes.order_id#
</cfquery>
<cfquery name="get_order_det2" datasource="#DSN3#">
	<cfif get_general_info.IS_SERIAL_CONTROL_LOCATION>
		<!---Seri No Üretim veya Depodan Hiç Bir Bağlantısı Yoksa--->
        SELECT 
            0 AS PRODUCTION_ORDER_ROW_ID, 
            EVLS.SERIAL_NO, 
            ORR.STOCK_ID, 
            ORR.QUANTITY, 
            ORR.ORDER_ROW_ID, 
            ORD.ORDER_ID, 
            ORD.ORDER_HEAD, 
            ORD.ORDER_NUMBER, 
            ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
            ORR.SPECT_VAR_NAME, 
            ORR.ORDER_ROW_CURRENCY, 
            S.PRODUCT_NAME, 
            S.STOCK_CODE, 
            S.STOCK_CODE_2, 
            '' AS LOT_NO, 
            '' AS FINISH_DATE, 
            0 AS P_ORDER_ID, 
            21 AS TYPE, 
            0 AS AMOUNT, 
            S.IS_PROTOTYPE, 
            ISNULL(S.IS_KARMA,0) AS IS_KARMA,
            ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO, 
            ORR.PRODUCT_NAME2
        FROM     
            PRODUCTION_ORDERS AS PO INNER JOIN
           	PRODUCTION_ORDERS_ROW AS ERPP ON PO.P_ORDER_ID = ERPP.P_ORDER_ID RIGHT OUTER JOIN
            ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
            STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
            ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID ON ERPP.ORDER_ROW_ID = ORR.ORDER_ROW_ID LEFT OUTER JOIN
            EZGI_WM_ORDER_LAST_STATUS AS EVLS ON ORR.ORDER_ROW_ID = EVLS.ORDER_ROW_ID
        WHERE  
            ORD.ORDER_ID = #attributes.order_id# AND 
            ISNULL(S.IS_SERIAL_NO, 0) = 1 AND 
            EVLS.ORDER_ROW_ID IS NULL AND
            ERPP.PRODUCTION_ORDER_ROW_ID IS NULL
   	UNION ALL
    </cfif>
	SELECT  
    	0 AS PRODUCTION_ORDER_ROW_ID,  
        '' AS SERIAL_NO,   
    	ORR.STOCK_ID, 
        ORR.QUANTITY, 
        ORR.ORDER_ROW_ID, 
        ORD.ORDER_ID, 
        ORD.ORDER_HEAD, 
        ORD.ORDER_NUMBER, 
        ISNULL(ORR.SPECT_VAR_ID, 0) AS SPECT_VAR_ID, 
        ORR.SPECT_VAR_NAME, 
        ORR.ORDER_ROW_CURRENCY,
        S.PRODUCT_NAME, 
        S.STOCK_CODE, 
        S.STOCK_CODE_2, 
        '' AS LOT_NO, 
        '' AS FINISH_DATE, 
        0 AS P_ORDER_ID, 
        5 AS TYPE,
        0 AS AMOUNT,
        S.IS_PROTOTYPE,
        ISNULL(S.IS_KARMA,0) AS IS_KARMA,
        ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO,
        ORR.PRODUCT_NAME2
	FROM         
    	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
        STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
        ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID
	WHERE     
   		ORD.ORDER_ID = #attributes.order_id# AND 
        ISNULL(S.IS_SERIAL_NO,0) =0 AND
        <cfif len(get_order_det1.ORDER_ROW_ID)>
       		ORR.ORDER_ROW_ID NOT IN (#order_row_id_list#) AND
        </cfif>
       	(S.IS_PRODUCTION = 1 OR S.IS_PURCHASE = 1)
</cfquery>
<!---<cfdump var="#get_order_det2#">--->
<cfquery name="get_order_det_3" dbtype="query">
	SELECT 
    	PRODUCTION_ORDER_ROW_ID,   
        SERIAL_NO,   
    	STOCK_ID, 
        QUANTITY, 
        ORDER_ROW_ID, 
        ORDER_ID, 
        ORDER_HEAD, 
        ORDER_NUMBER, 
        SPECT_VAR_ID, 
        SPECT_VAR_NAME,
        ORDER_ROW_CURRENCY, 
        PRODUCT_NAME, 
        STOCK_CODE, 
        STOCK_CODE_2, 
        LOT_NO, 
        P_ORDER_ID, 
        TYPE,
        AMOUNT,
       	IS_PROTOTYPE,
        IS_KARMA,
        IS_SERIAL_NO,
        PRODUCT_NAME2
	FROM
    	get_order_det1	   
	UNION ALL
    SELECT 
    	PRODUCTION_ORDER_ROW_ID,    
        SERIAL_NO, 
    	STOCK_ID, 
        QUANTITY, 
        ORDER_ROW_ID, 
        ORDER_ID, 
        ORDER_HEAD, 
        ORDER_NUMBER, 
        SPECT_VAR_ID, 
        SPECT_VAR_NAME,
        ORDER_ROW_CURRENCY, 
        PRODUCT_NAME, 
        STOCK_CODE, 
        STOCK_CODE_2, 
        LOT_NO, 
        P_ORDER_ID, 
        TYPE,
        AMOUNT,
        IS_PROTOTYPE,
        IS_KARMA,
        IS_SERIAL_NO,
        PRODUCT_NAME2
	FROM
    	get_order_det2
  	ORDER BY
    	ORDER_ROW_ID      
</cfquery>
<!---<cfdump var="#get_order_det_3#">--->
<cfquery name="get_order_det" dbtype="query">
	SELECT 
    	STOCK_ID, 
        QUANTITY, 
        ORDER_ROW_ID, 
        ORDER_ID, 
        ORDER_HEAD, 
        ORDER_NUMBER, 
        SPECT_VAR_ID, 
        SPECT_VAR_NAME,
        ORDER_ROW_CURRENCY, 
        PRODUCT_NAME, 
        STOCK_CODE, 
        STOCK_CODE_2, 
        SUM(AMOUNT) AS AMOUNT,
        IS_PROTOTYPE,
        IS_KARMA,
        IS_SERIAL_NO,
        PRODUCT_NAME2
	FROM
    	get_order_det_3
   	GROUP BY
    	STOCK_ID, 
        QUANTITY, 
        ORDER_ROW_ID, 
        ORDER_ID, 
        ORDER_HEAD, 
        ORDER_NUMBER, 
        SPECT_VAR_ID, 
        SPECT_VAR_NAME,
        ORDER_ROW_CURRENCY, 
        PRODUCT_NAME, 
        STOCK_CODE, 
        STOCK_CODE_2, 
        IS_PROTOTYPE,
        IS_KARMA,
        IS_SERIAL_NO,
        PRODUCT_NAME2
  	ORDER BY
    	ORDER_ROW_ID 
</cfquery>
<!---<cfdump var="#get_order_det#">--->
<cfset amount_round = 2>	
<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id='57611.Sipariş'> <cf_get_lang dictionary_id='57456.Üretim'> <cf_get_lang dictionary_id='57989.ve'> <cf_get_lang dictionary_id='29745.Tedarik'> <cf_get_lang dictionary_id='29750.Rezerve'> - <cf_get_lang_main no='233.Teslim Tarihi'> : <cfoutput>#DateFormat(orders_info.DELIVERDATE,'dd/mm/yyyy')#</cfoutput></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#ezgi_header#">
    	<cfform name="orders" action="" method="post">
        	<cf_basket id="upd_default_measure_bask">
            	<cf_grid_list sort="0">
        			<thead>
                        <tr>
                            <th width="15"><cf_get_lang dictionary_id='58577.Sıra'></th> 
                            <th width="20"></th>
                            <th><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                            <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                            <th><cf_get_lang dictionary_id='33925.Spec Main'></th>
                            <th><cf_get_lang dictionary_id='47408.Satır Açıklama'></th>
                            <th width="50" style="text-align:right;"><cf_get_lang dictionary_id='57611.Sipariş'></th>
                            <th width="50"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></th>
                            <th width="50"><cf_get_lang dictionary_id='36698.Lot No'></th>
                            <th width="70"><cf_get_lang dictionary_id='57637.Seri No'></th>
                            <cfif isdefined('attributes.planning')>
                            	<th width="15"><cf_get_lang dictionary_id='49564.İlişkili'></th>
                                <th width="15"></th>
                                <th width="40"></th>
                            </cfif>
                        </tr>
                    </thead>
                    <tbody>
                        <cfif get_order_det.recordcount>
                            <cfform name="orders" action="" method="post">
                                <cfoutput query="get_order_det">
                                    <cfquery name="get_order_det_4" dbtype="query">
                                        SELECT DISTINCT
                                        	IS_KARMA,
                                        	PRODUCTION_ORDER_ROW_ID, 
                                        	SERIAL_NO, 
                                            LOT_NO, 
                                            P_ORDER_ID,
                                            AMOUNT,
                                            TYPE
                                        FROM
                                            get_order_det_3
                                        WHERE
                                            ORDER_ROW_ID = #ORDER_ROW_ID#
                                    </cfquery>
                                    <cfif get_order_det_4.recordcount>
                                    	<cfset rows = get_order_det_4.recordcount>
                                  	<cfelse>
                                    	<cfset rows = 1>
                                    </cfif>
										
                                    <!---<cfdump var="#get_order_det_4#">--->
                                    <tr>
                                        <td rowspan="#rows#" style="height:30px; text-align:right">#currentrow#</td>
                                        <td rowspan="#rows#" style="font-size:20px; font-weight:bold; text-align:center">
                                        	<cfif IS_KARMA eq 1>
                                            	<span title="Demonte Ürün">D</span>
                                            <cfelse>
                                            	<cfif IS_SERIAL_NO eq 1>
                                            		<span title="Seri No Ürün">S</span>
                                                <cfelse>
                                                  	<span title="Standart Ürün">P</span>  
                                                </cfif>
                                            </cfif>
                                        </td>
                                        <td rowspan="#rows#">#get_order_det.STOCK_CODE#</td>
                                        <td rowspan="#rows#">#get_order_det.PRODUCT_NAME#</td>
                                        <td rowspan="#rows#">#get_order_det.SPECT_VAR_NAME#</td>
                                        <td rowspan="#rows#">#get_order_det.PRODUCT_NAME2#</td>
                                        <td rowspan="#rows#" style="text-align:right;">#TLFormat(get_order_det.QUANTITY,amount_round)#</td>
                                        <cfset t = 1>
                                        <cfloop query="get_order_det_4">
                                            <cfif t eq 0>
                                                <tr>
                                            </cfif>
                                            <td style="text-align:center;">
												<cfif isdefined('FINISH_DATE_#get_order_det_4.TYPE#_#get_order_det_4.LOT_NO#_#get_order_det.ORDER_ROW_ID#')>
                                                    #DateFormat(Evaluate('FINISH_DATE_#get_order_det_4.TYPE#_#get_order_det_4.LOT_NO#_#get_order_det.ORDER_ROW_ID#'),dateformat_style)#
                                                </cfif>
                                            </td>
                                            <td style="text-align:center;">#get_order_det_4.lot_no#</td>
                                            <td style="text-align:center;">#get_order_det_4.SERIAL_NO#</td>
                                            <cfif isdefined('attributes.planning')>
                                            	<td style="text-align:right;">
                                                	#TLFormat(get_order_det_4.AMOUNT,amount_round)#
                                                </td>
                                                <td style="text-align:center;">
                                                	<cfif get_order_det.IS_PROTOTYPE eq 1>
                                                    	<cfquery name="get_spect" datasource="#dsn3#">
                                                        	SELECT
                                                            	SPECT_MAIN_ID,
                                                                SPECT_VAR_NAME
                                                          	FROM
                                                            	SPECTS
                                                          	WHERE
                                                            	SPECT_VAR_ID = #get_order_det.SPECT_VAR_ID#
                                                        </cfquery>	
                                                    	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=stock.add_ezgi_product_inquiry_warehouse&is_submitted=1&product_name=#get_order_det.PRODUCT_NAME#&spect_name=#get_spect.SPECT_VAR_NAME#&stock_id=#get_order_det.STOCK_ID#&spect_main_id=#get_spect.SPECT_MAIN_ID#','wide');">
                                                        	<img src="/images/package.gif" title="<cf_get_lang dictionary_id='37244.Palet'>" border="0">
                                                    	</a>
                                                    <cfelse>
                                                   	 	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=stock.add_ezgi_product_inquiry_warehouse&is_submitted=1&product_name=#get_order_det.PRODUCT_NAME#&stock_id=#get_order_det.STOCK_ID#','wide');">
                                                        	<img src="/images/package.gif" title="<cf_get_lang dictionary_id='37244.Palet'>" border="0">
                                                    	</a>
                                                    </cfif>
                                                </td>
                                                <td style="text-align:center;" nowrap>
                                                	<cfif IS_KARMA eq 0>
														<cfif get_order_det_4.TYPE eq 2 or get_order_det_4.TYPE eq 4 or get_order_det_4.TYPE eq 6> <!---Üretim Lot No--->
                                                            <cfif get_order_det.QUANTITY gt get_order_det.AMOUNT>
                                                                <a href="javascript://" onClick="ekle(#get_order_det.ORDER_ID#,#get_order_det.ORDER_ROW_ID#,#get_order_det.STOCK_ID#,#get_order_det.SPECT_VAR_ID#,#get_order_det.QUANTITY#);"><img src="/images/plus_list.gif" align="absmiddle" border="0"></a>
                                                                <cfif len(get_order_det_4.LOT_NO)>
                                                                    &nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript://" onClick="sil(#get_order_det.ORDER_ID#,#get_order_det.ORDER_ROW_ID#,#get_order_det_4.P_ORDER_ID#,#get_order_det_4.TYPE#);"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>
                                                                </cfif>
                                                            <cfelse>
                                                                <a href="javascript://" onClick="sil(#get_order_det.ORDER_ID#,#get_order_det.ORDER_ROW_ID#,#get_order_det_4.P_ORDER_ID#,#get_order_det_4.TYPE#);"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>
                                                            </cfif>
                                                        <cfelseif get_order_det_4.TYPE eq 1 or get_order_det_4.TYPE eq 3>
                                                            <cfif get_order_det.QUANTITY gt get_order_det.AMOUNT>
                                                                <cfif session.ep.admin eq 1>
                                                                    <a href="javascript://" onClick="ekle(#get_order_det.ORDER_ID#,#get_order_det.ORDER_ROW_ID#,#get_order_det.STOCK_ID#,#get_order_det.SPECT_VAR_ID#,#get_order_det.QUANTITY#);"><img src="/images/plus_list.gif" align="absmiddle" border="0"></a>
                                                                    <cfif len(get_order_det_4.LOT_NO)>
                                                                    &nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript://" onClick="sil(#get_order_det.ORDER_ID#,#get_order_det.ORDER_ROW_ID#,#get_order_det_4.P_ORDER_ID#,#get_order_det_4.TYPE#);"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>
                                                                </cfif>
                                                                </cfif>
                                                            <cfelse>
                                                                <cfif session.ep.admin eq 1>
                                                                    <a href="javascript://" onClick="sil(#get_order_det.ORDER_ID#,#get_order_det.ORDER_ROW_ID#,#get_order_det_4.P_ORDER_ID#,#get_order_det_4.TYPE#);"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>
                                                                </cfif>
                                                            </cfif>
                                                        <cfelseif get_order_det_4.TYPE eq 11 or get_order_det_4.TYPE eq 21> <!---Üretim Seri No--->
                                                            <cfif get_order_det.QUANTITY gt get_order_det.AMOUNT>
                                                                <a href="javascript://" onClick="ekle_seri(#get_order_det.ORDER_ID#,#get_order_det.ORDER_ROW_ID#,#get_order_det.STOCK_ID#,#get_order_det.SPECT_VAR_ID#,#get_order_det.QUANTITY#);"><img src="/images/plus_list.gif" align="absmiddle" border="0"></a>												
                                                                <cfif get_order_det_4.AMOUNT gt 0>
                                                                    &nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript://" onClick="sil_seri(#get_order_det.ORDER_ID#,#get_order_det.ORDER_ROW_ID#,#get_order_det_4.PRODUCTION_ORDER_ROW_ID#,#get_order_det_4.TYPE#,'#get_order_det_4.SERIAL_NO#');"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>		
                                                                </cfif>
                                                            <cfelse>
                                                                <cfif get_order_det_4.AMOUNT gt 0>
                                                                    <a href="javascript://" onClick="sil_seri(#get_order_det.ORDER_ID#,#get_order_det.ORDER_ROW_ID#,#get_order_det_4.PRODUCTION_ORDER_ROW_ID#,#get_order_det_4.TYPE#,'#get_order_det_4.SERIAL_NO#');"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>		
                                                                </cfif>
                                                            </cfif>
                                                        <cfelse>
                                                            <cfif get_order_det_4.TYPE eq 5>
                                                                <a href="javascript://" onClick="ekle(#get_order_det.ORDER_ID#,#get_order_det.ORDER_ROW_ID#,#get_order_det.STOCK_ID#,#get_order_det.SPECT_VAR_ID#,#get_order_det.QUANTITY#);"><img src="/images/plus_list.gif" align="absmiddle" border="0"></a>
                                                            </cfif>
                                                        </cfif>
                                                   	</cfif>
                                                </td>
                                                
                                            </cfif>
                                 		</tr>
                                   		<cfif t eq 1>
                                         	<cfset t = 0>
                                       	</cfif>
                                        </cfloop>
                                </cfoutput>
                            </cfform>
                        </cfif>
                    </tbody>
          		</cf_grid_list>
          	</cf_basket>
        </cfform>
 	
		<cfif isdefined('attributes.planning')>
            <cfform name="deliver_date_form" action="" method="post">
            <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
                <cf_box>
                    <div class="col col-7">
                    
                   		<div class="col col-12">
                       		<div class="col col-4"><label style="font-weight:bold"><cf_get_lang dictionary_id='36708.Sipariş Açıklaması'></label></div>
                         	<div class="col col-8">	
                              	<cfoutput>#orders_info.ORDER_DETAIL#</cfoutput> 
                          	</div>
                      	</div>
                    
                    </div>
                    <div class="col col-3">
                        <div class="form-group" id="item-deliver_date">
                            <div class="col col-12">
                                <div class="col col-5"><label style="font-weight:bold"><cf_get_lang_main no='233.Teslim Tarihi'></label></div>
                                <div class="col col-5">	
                                    <div class="form-group medium">
                                        <div class="input-group x-14">		
                                            <cfinput type="text" name="deliver_date" id="deliver_date" placeholder="" value="#dateformat(attributes.deliver_date,dateformat_style)#" validate="#validate_style#" maxlength="10">	
                                            <span class="input-group-addon"><cf_wrk_date_image date_field="deliver_date"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col col-2">
                        <div class="col col-12">
                            <div class="form-group medium" style="text-align:right"> 
                            	<input type="button" name="buton" onClick="update_deliver_date(<cfoutput>#attributes.order_id#</cfoutput>)" style="height:30px; width:90px" value="Güncelle">
                            </div>
                        </div>
                    </div>
                </cf_box>
            </div>
            </cfform>
        </cfif>
  	</cf_box>
</div>
<cfif not isdefined('attributes.planning')>
    <cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id="401.İlişkili Operasyonlar"></cfsavecontent>
    <cf_seperator id="operasyonlar" is_closed="1" header="#ezgi_header#" >
    <table id="operasyonlar" width="100%">
        <tr>
            <td>
                <cf_medium_list>
                    <cfinclude template="/v16/add_options/ezgi/e_furniture/list_ezgi_order_production_rate.cfm">
                </cf_medium_list>
            </td>
        </tr>
    </table>
</cfif>
<script language="javascript">
	function ekle(order_id,order_row_id,stock_id,spect_var_id,quantity)
	{	
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.popup_list_ezgi_production<cfif isdefined('attributes.planning')>&planning=1</cfif>&stock_id='+stock_id+'&order_id='+order_id+'&order_row_id='+order_row_id+'&spect_var_id='+spect_var_id+'&ord_quantity='+quantity;	
	}
	function ekle_seri(order_id,order_row_id,stock_id,spect_var_id,quantity)
	{	
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.popup_list_ezgi_production&seri_no=1<cfif isdefined('attributes.planning')>&planning=1</cfif>&stock_id='+stock_id+'&order_id='+order_id+'&order_row_id='+order_row_id+'&spect_var_id='+spect_var_id+'&ord_quantity='+quantity;	
	}
	function sil(order_id,order_row_id,p_order_id,type)
	{	
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_del_ezgi_order_rel<cfif isdefined('attributes.planning')>&planning=1</cfif>&order_id='+order_id+'&order_row_id='+order_row_id+'&p_order_id='+p_order_id+'&type='+type;
	}
	function sil_seri(order_id,order_row_id,p_order_id,type,serino)
	{	
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_del_ezgi_order_rel<cfif isdefined('attributes.planning')>&planning=1</cfif>&order_id='+order_id+'&order_row_id='+order_row_id+'&p_order_id='+p_order_id+'&type='+type+'&serino='+serino;
	}
	function update_deliver_date(order_id)
	{
		if(document.getElementById('deliver_date').value=='')
		{
			alert('Tarih Giriniz');
			return false;
		}
		sor=confirm('<cf_get_lang dictionary_id="57536.Güncellemek İstediğinizden Emin misiniz?">')	
		if(sor==true)
		{
			upd_deliver_date=document.getElementById('deliver_date').value;
			window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_del_ezgi_order_rel&planning=1&upd_deliver_date='+upd_deliver_date+'&order_id='+order_id+'&type=1';
		}
		else
			return false;
	}
</script>	