<!---
    File: upd_ezgi_shipping_divide.cfm
    Folder: Add_Ons\ezgi\e_shipping\form
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Sevkiyat Silme veya Bölme İşlemi
--->
<cfset module_name="sales">
<cfquery name="get_general_info" datasource="#dsn#">
	SELECT ISNULL(IS_SERIAL_CONTROL_LOCATION,0) AS IS_SERIAL_CONTROL_LOCATION FROM OUR_COMPANY_INFO WHERE COMP_ID = #session.ep.company_id#
</cfquery>
<cfquery name="get_ship_default" datasource="#dsn3#">
	SELECT ISNULL(SHIPPING_CONTROL_TYPE,0) SHIPPING_CONTROL_TYPE FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfif len(attributes.ship_id)>
	<cfif attributes.is_type eq 1>
        <cfquery name="get_order_rows" datasource="#dsn3#">
            SELECT        
                E.ORDER_ROW_ID, 
                ORR.PRODUCT_NAME, 
                ORR.QUANTITY, 
                ORR.ORDER_ROW_CURRENCY,
                E.SHIP_RESULT_ROW_ID as ROW_ID, 
                S.STOCK_ID, 
                S.PRODUCT_ID, 
                S.PRODUCT_CODE,
                ISNULL(S.IS_KARMA,0) IS_KARMA
            FROM            
                EZGI_SHIP_RESULT_ROW AS E WITH (NOLOCK) INNER JOIN
                ORDER_ROW AS ORR WITH (NOLOCK) ON E.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID
            WHERE        
                E.SHIP_RESULT_ID = #attributes.ship_id#
          	ORDER BY
            	S.STOCK_ID, 	
                ORR.QUANTITY
        </cfquery>
	<cfelse>
        <cfquery name="get_order_rows" datasource="#dsn3#">
        	SELECT        
                E.ORDER_ROW_ID, 
                ORR.PRODUCT_NAME, 
                ORR.QUANTITY, 
                ORR.ORDER_ROW_CURRENCY,
                E.SHIP_RESULT_INTERNALDEMAND_ROW_ID as ROW_ID, 
                S.STOCK_ID, 
                S.PRODUCT_ID, 
                S.PRODUCT_CODE,
                ISNULL(S.IS_KARMA,0) IS_KARMA
            FROM            
                EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS E WITH (NOLOCK) INNER JOIN
                ORDER_ROW AS ORR WITH (NOLOCK) ON E.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID
            WHERE        
                E.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
          	ORDER BY
            	S.STOCK_ID, 	
                ORR.QUANTITY
        </cfquery>
	</cfif>
<cfelse>
	<script type="text/javascript">
   		alert("Yanlış Bir Sayfadan Geldiniz Sistem Yöneticinize Bildirin!");
    	window.close()
	</script>
 	<cfabort>
</cfif>
<!---<cfdump var="#get_order_rows#">--->
<cfset row_id_list = ValueList(get_order_rows.ROW_ID)>
<cfset order_row_id_list = ValueList(get_order_rows.ORDER_ROW_ID)>
<cfquery name="get_order_det1" datasource="#DSN3#">
	<cfif get_general_info.IS_SERIAL_CONTROL_LOCATION>
    <!---Sipariş - Seri No--->
    SELECT 
    	PRODUCTION_ORDER_ROW_ID,  
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
        ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO, 
     	ISNULL(EWL.SHIP_RESULT_ID, 0) AS SHIP_RESULT_ID,
        ISNULL(EWL.SHIP_RESULT_TYPE, 0) AS SHIP_RESULT_TYPE
	FROM     	
    	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
        STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
        ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
        EZGI_WM_ORDER_LAST_STATUS AS EWM ON ORR.ORDER_ROW_ID = EWM.ORDER_ROW_ID LEFT OUTER JOIN
        PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EWM.P_ORDER_ID = PO.P_ORDER_ID LEFT OUTER JOIN
        EZGI_WM_SERIAL_NO_LAST_STATUS AS EWL ON EWM.SERIAL_NO = EWL.SERIAL_NO
	WHERE  
    	ORR.ORDER_ROW_ID IN (#order_row_id_list#) AND 
        ISNULL(PO.PRODUCTION_LEVEL, 0) = '0' AND 
        S.IS_PRODUCTION = 1 AND 
        ISNULL(S.IS_SERIAL_NO, 0) = 1 AND
        (
        	(ISNULL(EWL.SHIP_RESULT_ID, 0) = #attributes.ship_id# AND ISNULL(EWL.SHIP_RESULT_TYPE, 0) = #attributes.is_type#) OR
            ISNULL(EWL.SHIP_RESULT_ID,0)=0
        )
	UNION ALL
    </cfif>
    <!---Sipariş - Üretim Planı Lot No--->
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
        ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO,
        0 AS SHIP_RESULT_ID,
        0 AS SHIP_RESULT_TYPE
	FROM         
    	ORDERS AS ORD WITH (NOLOCK) RIGHT OUTER JOIN
      	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
       	STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
       	PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
       	PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) ON PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID ON ORR.ORDER_ROW_ID = POR.ORDER_ROW_ID ON ORD.ORDER_ID = ORR.ORDER_ID
	WHERE     
    	ORR.ORDER_ROW_ID IN(#order_row_id_list#) AND 
        ISNULL(PO.PRODUCTION_LEVEL, 0) = N'0' AND
        S.IS_PRODUCTION = 1 AND
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
        PO.LOT_NO, 
        PO.FINISH_DATE, 
        PO.P_ORDER_ID, 
        POR.TYPE,
        S.IS_PROTOTYPE,
        S.IS_SERIAL_NO
	UNION ALL
    <!---Sipariş - Satınalma Siparişi--->
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
        O1.ORDER_NUMBER AS LOT_NO, 
        O1.ORDER_DATE AS FINISH_DATE, 
        O1.ORDER_ID AS P_ORDER_ID, 
        3 AS TYPE,
        SUM(ORR1.QUANTITY) AMOUNT,
        S.IS_PROTOTYPE,
        ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO,
        0 AS SHIP_RESULT_ID,
        0 AS SHIP_RESULT_TYPE
	FROM         
    	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
        ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
        STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
        ORDER_ROW AS ORR1 WITH (NOLOCK) ON ORR.WRK_ROW_ID = ORR1.WRK_ROW_RELATION_ID INNER JOIN
        ORDERS AS O1 WITH (NOLOCK) ON ORR1.ORDER_ID = O1.ORDER_ID
	WHERE     
    	ORR.ORDER_ROW_ID IN(#order_row_id_list#) AND 
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
        S.IS_PROTOTYPE,
        S.IS_SERIAL_NO
	UNION ALL
   
  	<!---Sipariş - Üretim Planı - Üretim Programı--->
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
        IS_SERIAL_NO,
        0 AS SHIP_RESULT_ID,
        0 AS SHIP_RESULT_TYPE
	FROM     
    	(
        	<!---Üst Paketler Karma Koli - Alt Paketlerde Seri No Yoksa--->
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
                S.IS_PROTOTYPE, 
                PO.LOT_NO, 
                EMP.MASTER_PLAN_FINISH_DATE AS FINISH_DATE, 
                EP.IFLOW_P_ORDER_ID AS P_ORDER_ID, 
                6 AS TYPE, 
                EP.QUANTITY AS AMOUNT, 
               	ORR.PRODUCT_NAME2,
                ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO
     		FROM      
            	EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) INNER JOIN
                PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EP.LOT_NO = PO.LOT_NO INNER JOIN
                PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) ON PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID INNER JOIN
                ORDER_ROW AS ORR ON POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
                STOCKS AS S ON EP.STOCK_ID = S.STOCK_ID INNER JOIN
                EZGI_IFLOW_MASTER_PLAN AS EMP ON EP.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID
         	WHERE   
            	ORR.ORDER_ROW_ID IN(#order_row_id_list#) AND 
        		S.IS_KARMA = 1 AND
                ISNULL(S.IS_SERIAL_NO,0) =0
            <cfif get_general_info.IS_SERIAL_CONTROL_LOCATION>
        	UNION ALL
            <!---Üst Paketler Karma Koli - Alt Paketlerde Seri No Varsa--->
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
                S.IS_PROTOTYPE, 
                PO.LOT_NO, 
                EMP.MASTER_PLAN_FINISH_DATE AS FINISH_DATE, 
                EP.IFLOW_P_ORDER_ID AS P_ORDER_ID, 
                6 AS TYPE, 
                EP.QUANTITY AS AMOUNT, 
               	ORR.PRODUCT_NAME2,
                ISNULL(S.IS_SERIAL_NO, 0) AS IS_SERIAL_NO
     		FROM      
            	EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) INNER JOIN
                PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EP.LOT_NO = PO.LOT_NO INNER JOIN
                PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) ON PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID INNER JOIN
                ORDER_ROW AS ORR ON POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
                STOCKS AS S ON EP.STOCK_ID = S.STOCK_ID INNER JOIN
                EZGI_IFLOW_MASTER_PLAN AS EMP ON EP.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID
         	WHERE   
            	ORR.ORDER_ROW_ID IN(#order_row_id_list#) AND 
        		S.IS_KARMA = 1 AND
                ISNULL(S.IS_SERIAL_NO,0) =0
        </cfif>        
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
        IS_SERIAL_NO
</cfquery>

<cfset order_row_id_list_1 = Valuelist(get_order_det1.ORDER_ROW_ID)>
<cfquery name="get_order_det2" datasource="#DSN3#">
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
        0 AS SHIP_RESULT_ID,
        0 AS SHIP_RESULT_TYPE
	FROM         
    	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
        STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
        ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID
	WHERE     
   		ORR.ORDER_ROW_ID IN(#order_row_id_list#) AND  
        <cfif len(get_order_det1.ORDER_ROW_ID)>
       		ORR.ORDER_ROW_ID NOT IN (#order_row_id_list_1#) AND
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
        SHIP_RESULT_ID,
    	SHIP_RESULT_TYPE
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
        SHIP_RESULT_ID,
        SHIP_RESULT_TYPE
	FROM
    	get_order_det2
  	ORDER BY
    	ORDER_ROW_ID      
</cfquery>
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
        TYPE,
        SUM(AMOUNT) AS AMOUNT
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
        TYPE
  	ORDER BY
    	ORDER_ROW_ID 
</cfquery>
<cfoutput query="get_order_det">
	<cfset 'AMOUNT_#ORDER_ROW_ID#' = AMOUNT>
</cfoutput>
<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id='1115.Sevkiyat Düzenleme'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#ezgi_header#" right_images="">
    	<cf_basket id="upd_default_measure_bask">
			 <cfform name="add_packet_ship" id="add_packet_ship" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_ezgi_shipping_clear&ship_id=#attributes.ship_id#&is_type=#attributes.is_type#">
                <cf_grid_list sort="0">
                    <thead>
                        <tr height="20px">
                        	<th width="45px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th width="70px"><cf_get_lang dictionary_id='58585.Kod'></th>
                            <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                            <th width="40px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            <th width="70px"><cf_get_lang dictionary_id='36698.Lot No'></th>
                            <th width="70px"><cf_get_lang dictionary_id='57637.Seri No'></th>
                            <th width="40px"><cf_get_lang dictionary_id="49884.Üretim Emri"></th>
                            <th width="40px"><cf_get_lang dictionary_id="33105.Sevk Edilecek"></th>
                            <th width="20px"><cf_get_lang dictionary_id='52513.Ok'></th>
                        </tr>
                    </thead>
                    <cfinput type="hidden" name="row_id_list" value="#row_id_list#">
                    <tbody>
                    	<cfset sira = 0>
                        <cfoutput query="get_order_rows">
                        	<cfif get_order_rows.IS_KARMA eq 1>
                            	<!---Karma Koli Kuralı
                                1- Hiç Okutulmamış ise Tamamını Çıkar veya Böl ReadOnly yok
                                2- Okutulmuşsa Okutulduğu Kadar Çıkar ReadOnly Var--->
                                
                            	<cfif attributes.is_type eq 1><!---Sevk Planı İse--->
                                    <cfquery name="get_karma_row" datasource="#dsn3#">
                                        SELECT 
                                            ORR.ORDER_ROW_ID, 
                                            EPS.PAKET_ID AS STOCK_ID, 
                                            EPS.PAKET_SAYISI * ORR.QUANTITY AS PAKET_AMOUNT, 
                                            FLOOR(ISNULL(TBL_1.AMOUNT,0)/EPS.PAKET_SAYISI) AS AMOUNT
                                        FROM     
                                            ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                                            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                                            STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
                                            EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ORR.ORDER_ROW_ID = ESRR.ORDER_ROW_ID LEFT OUTER JOIN
                                            (
                                                <cfif get_general_info.IS_SERIAL_CONTROL_LOCATION>
                                                	SELECT 
                                                    	COUNT(*) AS AMOUNT,  
                                                        ELS.SPECT_ID, 
                                                        ELS.STOCK_ID, 
                                                        ORR.ORDER_ROW_ID
													FROM     
                                                    	EZGI_SHIP_RESULT AS ESR INNER JOIN
                  										EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                  										ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                  										EZGI_PAKET_SAYISI AS EPP ON ORR.STOCK_ID = EPP.MODUL_ID INNER JOIN
                  										EZGI_WM_SERIAL_NO_LAST_STATUS AS ELS ON EPP.PAKET_ID = ELS.STOCK_ID AND ESRR.SHIP_RESULT_ID = ELS.SHIP_RESULT_ID
                                                  	WHERE  
                                                    	ISNULL(ELS.SHIP_RESULT_ID, 0) > 0 AND 
                                                        ELS.SHIP_RESULT_TYPE = 1
													GROUP BY 
                                                    	ORR.ORDER_ROW_ID, 
                                                        ELS.SPECT_ID, 
                                                        ELS.STOCK_ID, 
                                                        ESR.SHIP_RESULT_ID
                                                    UNION ALL
                                                </cfif>
                                                SELECT
                                                    SUM(ESP.CONTROL_AMOUNT) AS AMOUNT,
                                                    ESP.SPECT_MAIN_ID,
                                                    ESP.STOCK_ID, 
                                                    ORR.ORDER_ROW_ID
                                                FROM     
                                                    EZGI_SHIP_RESULT AS ESR INNER JOIN
                                                    EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                                                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                                    EZGI_SHIPPING_PACKAGE_LIST AS ESP ON ESRR.SHIP_RESULT_ROW_ID = ESP.SHIPPING_ROW_ID
                                                WHERE  
                                                    ESP.TYPE = 1
                                                GROUP BY 
                                                    ORR.ORDER_ROW_ID, 
                                                    ESP.STOCK_ID, 
                                                    ESP.SPECT_MAIN_ID
                                            ) AS TBL_1 ON EPS.PAKET_ID = TBL_1.STOCK_ID AND ORR.ORDER_ROW_ID = TBL_1.ORDER_ROW_ID
                                        WHERE  
                                            S.IS_PROTOTYPE = 0 AND 
                                            S.IS_KARMA = 1 AND 
                                            ORR.ORDER_ROW_ID = #ORDER_ROW_ID#
                                    </cfquery> 
                                <cfelse><!---Sevk Talebi İse--->
                                	<cfquery name="get_karma_row" datasource="#dsn3#">
                                        SELECT 
                                            ORR.ORDER_ROW_ID, 
                                            EPS.PAKET_ID AS STOCK_ID, 
                                            EPS.PAKET_SAYISI * ORR.QUANTITY AS PAKET_AMOUNT, 
                                            FLOOR(ISNULL(TBL_1.AMOUNT,0)/EPS.PAKET_SAYISI) AS AMOUNT
                                        FROM     
                                            ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                                            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                                            STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
                                            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ORR.ORDER_ROW_ID = ESRR.ORDER_ROW_ID LEFT OUTER JOIN
                                            (
                                                <cfif get_general_info.IS_SERIAL_CONTROL_LOCATION>
                                                	SELECT 
                                                    	COUNT(*) AS AMOUNT, 
                                                        ELS.SPECT_ID, 
                                                        ELS.STOCK_ID,
                                                        ORR.ORDER_ROW_ID
													FROM     
                                                    	EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                  										EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                  										ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                  										EZGI_PAKET_SAYISI AS EPP ON ORR.STOCK_ID = EPP.MODUL_ID INNER JOIN
                  										EZGI_WM_SERIAL_NO_LAST_STATUS AS ELS ON EPP.PAKET_ID = ELS.STOCK_ID AND ESRR.SHIP_RESULT_INTERNALDEMAND_ID = ELS.SHIP_RESULT_ID
													WHERE  
                                                    	ISNULL(ELS.SHIP_RESULT_ID, 0) > 0 AND 
                                                        ELS.SHIP_RESULT_TYPE = 2
													GROUP BY 
                                                    	ORR.ORDER_ROW_ID, 
                                                        ELS.SPECT_ID, 
                                                        ELS.STOCK_ID, 
                                                        ESR.SHIP_RESULT_INTERNALDEMAND_ID
                                                    UNION ALL
                                                </cfif>
                                                SELECT
                                                    SUM(ESP.CONTROL_AMOUNT) AS AMOUNT,
                                                    ESP.SPECT_MAIN_ID,
                                                    ESP.STOCK_ID, 
                                                    ORR.ORDER_ROW_ID
                                                FROM     
                                                    EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                                                    EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                                                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                                    EZGI_SHIPPING_PACKAGE_LIST AS ESP ON ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID = ESP.SHIPPING_ROW_ID
                                                WHERE  
                                                    ESP.TYPE = 2
                                                GROUP BY 
                                                    ORR.ORDER_ROW_ID, 
                                                    ESP.STOCK_ID, 
                                                    ESP.SPECT_MAIN_ID
                                            ) AS TBL_1 ON EPS.PAKET_ID = TBL_1.STOCK_ID AND ORR.ORDER_ROW_ID = TBL_1.ORDER_ROW_ID
                                        WHERE  
                                            S.IS_PROTOTYPE = 0 AND 
                                            S.IS_KARMA = 1 AND 
                                            ORR.ORDER_ROW_ID = #ORDER_ROW_ID#
                                    </cfquery> 
                                </cfif>
                                <!---<cfdump var="#get_karma_row#">--->
                                <cfquery name="get_karma_max_row" dbtype="query">
                                	SELECT 
                                    	MAX(AMOUNT) AS MAX_AMOUNT
                                    FROM	
                                		get_karma_row
                                </cfquery>  
                                <!---<cfdump var="#get_karma_max_row#">--->
                                <cfif get_karma_max_row.MAX_AMOUNT gt 0>
                                    <cfquery name="get_karma_min_row" dbtype="query">
                                        SELECT 
                                            AMOUNT
                                        FROM	
                                            get_karma_row
                                        GROUP BY
                                            AMOUNT
                                    </cfquery>
                                    <!---<cfdump var="#get_karma_min_row#">--->
                                    <cfif get_karma_min_row.recordcount eq 1><!---Eğer Satır 1 ise Paketler eşit Okutulmuş durumdadır--->
                                        
                                        <cfif isdefined('MIKTAR_#get_order_rows.STOCK_ID#')><!---Aynı Üründen Birden Fazla Satırda Varsa Ürünler Küçük Miktardan Büyük Miktara Sırlanarak Düşülerek Gidilir. --->
                                        	<cfif Evaluate('MIKTAR_#get_order_rows.STOCK_ID#') gt 0> <!---Bir Önceki Satırdan Dağıtılacak Kaldı mı--->
                                            	<cfset miktar = Evaluate('MIKTAR_#get_order_rows.STOCK_ID#')><!---Kalan kadar çıkartılmasına izin verilir.--->
												<cfset 'MIKTAR_#get_order_rows.STOCK_ID#' = Evaluate('MIKTAR_#get_order_rows.STOCK_ID#') - get_order_rows.quantity>
                                          	<cfelse>
                                            	<cfset miktar = get_order_rows.quantity>
                                            </cfif>
                                            <cfif Evaluate('MIKTAR_#get_order_rows.STOCK_ID#') gt 0><!---Bu Satır Toplam Okutulandan Düşüldü ancak Hala Okutulmuş varmı--->
                                            	<cfset izin =0>
                                            <cfelse>
                                        		<cfset izin =2>
                                          	</cfif>
                                        <cfelse>
                                        	<cfset 'MIKTAR_#get_order_rows.STOCK_ID#' = get_karma_min_row.AMOUNT - get_order_rows.quantity>
                                            <cfif get_order_rows.quantity gt get_karma_min_row.AMOUNT>
                                            	<cfset miktar = get_order_rows.quantity-get_karma_min_row.AMOUNT><!---Okutulduğu kadar çıkartılmasına izin verilir.--->
                                          	<cfelse>
                                            	<cfset miktar = get_order_rows.quantity><!---Okutulduğu kadar çıkartılmasına izin verilir.--->
                                            </cfif>
                                            <cfif Evaluate('MIKTAR_#get_order_rows.STOCK_ID#') gt 0><!---Bu Satır Toplam Okutulandan Düşüldü ancak Hala Okutulmuş varmı--->
                                            	<cfset izin =0>
                                            <cfelse>
                                        		<cfset izin =2>
                                          	</cfif>
                                      	</cfif>
                                  	<cfelse><!---Eğer Birden Fazla Satır Varsa Paketler eşit Okutulmamış Bu durumda eksitlme işlemi yapılamaz--->
                                    	<cfset miktar = get_order_rows.quantity>
                                        <cfset izin =0>
                                    </cfif> 
                             	<cfelse>
                                	<cfset miktar = get_order_rows.quantity>
                                    <cfset izin =1>
                                </cfif> 
                           	</cfif>
                       		<cfquery name="get_order_det_4" dbtype="query">
                          		SELECT DISTINCT
                                	PRODUCTION_ORDER_ROW_ID, 
                                	SHIP_RESULT_ID,
                                    SHIP_RESULT_TYPE,
                                 	SERIAL_NO,    
                                	LOT_NO, 
                                	P_ORDER_ID,
                                	AMOUNT
                            	FROM
                                 	get_order_det_3
                             	WHERE
                               		ORDER_ROW_ID = #ORDER_ROW_ID# AND
                                    NOT(SERIAL_NO IS NULL)
                              	GROUP BY
                                	PRODUCTION_ORDER_ROW_ID,
                                	SHIP_RESULT_ID,
                                    SHIP_RESULT_TYPE,
                                 	SERIAL_NO,    
                                	LOT_NO, 
                                	P_ORDER_ID,
                                	AMOUNT
                              	ORDER BY
                                 	AMOUNT
                       		</cfquery>
                          	<cfquery name="get_order_det_4_group" dbtype="query">
                             	SELECT SUM(AMOUNT) AMOUNT FROM get_order_det_4
                          	</cfquery>
                           	<cfif  get_order_det_4.amount eq 0>
                             	<cfset row_span = 1>
                          	<cfelse>
                            	<cfif get_order_det_4_group.AMOUNT lt get_order_rows.quantity>
                                	<cfset row_span = get_order_det_4.recordcount+1>
                               	<cfelse>
                                 	<cfset row_span = get_order_det_4.recordcount>
                              	</cfif>
                         	</cfif>
                                
                        	<cfset sira = sira+1>
                         	<tr height="30">
                             	<td rowspan="#row_span#">#currentrow#</td>
                                <td rowspan="#row_span#"><b>#PRODUCT_CODE#</b></td>
                                <td rowspan="#row_span#"><b>#PRODUCT_NAME#</b></td>
                                <td rowspan="#row_span#" style="text-align:right"><b>#Tlformat(QUANTITY,3)#</b></td>
                                <input type="hidden" name="quantity_#get_order_rows.row_id#" value="#TlFormat(QUANTITY,3)#"/>
                                <input type="hidden" name="order_row_id_#get_order_rows.row_id#" value="#order_row_id#"/>
                                <input type="hidden" name="order_row_row_#get_order_rows.row_id#" value="#row_span#"/>
                                <cfset t = 1>
                                <cfset row_quantity = get_order_rows.quantity>
                                <!---<cfdump var="#get_order_det_4#">--->
                              	<cfloop query="get_order_det_4">
                                 	<cfset row_quantity = row_quantity - AMOUNT>
                                    <cfif get_order_det_4.AMOUNT and len(SERIAL_NO)> <!---Üretim Planı Varsa--->
                                    	<cfif row_quantity lt 0>
                                        	<cfset rate = get_order_det_4.AMOUNT+row_quantity>
                                       	<cfelse>
                                        	<cfset rate = get_order_det_4.AMOUNT>
                                       	</cfif>
                                  	<cfelse> <!---Üretim Yoksa--->
                                      	<cfset rate = get_order_rows.quantity>
                                  	</cfif>
                                    <cfif t eq 0>
                                      	<tr>
                                  	</cfif>
                                    <td style="text-align:center;">#get_order_det_4.lot_no#</td>
                                    <td style="text-align:center;">#get_order_det_4.SERIAL_NO#</td>
                                    <td style="text-align:right">
                                    	#Tlformat(get_order_det_4.AMOUNT,3)#
                                   	</td>
                                    <td style="text-align:right">
                                    	<cfif get_order_rows.IS_KARMA eq 1>
                                        	<input 
                                            	type="text" 
                                                name="rate_#get_order_rows.row_id#_#get_order_det_4.currentrow#" 
                                                id="rate_#sira#" 
                                                style="font-weight:bold; width:70px; text-align:right"  
                                                <cfif izin eq 1>
                                                	value="#Tlformat(miktar,3)#"
                                                <cfelseif izin eq 2>
                                                	readonly 
                                                	value="#Tlformat(miktar,3)#"
                                              	<cfelseif izin eq 0>
                                                	readonly  
                                                	value="#Tlformat(miktar,3)#"
                                                </cfif>
                                          	/>
                                        <cfelse>
                                    		<input type="text" name="rate_#get_order_rows.row_id#_#get_order_det_4.currentrow#" id="rate_#sira#" style="font-weight:bold; width:70px; text-align:right"  <cfif rate lte 1>value="#Tlformat(rate,3)#" readonly <cfelse>value="#Tlformat(rate,3)#"</cfif>/>
                                        </cfif>
                                        <input type="hidden" name="quantity_#sira#" value="#rate#" <cfif get_order_rows.quantity eq 1>readonly</cfif>/>
                                        <input type="hidden" name="p_order_id_#get_order_rows.row_id#_#get_order_det_4.currentrow#" value="#get_order_det_4.p_order_id#"/>
                                        <input type="hidden" name="p_order_amount_#get_order_rows.row_id#_#get_order_det_4.currentrow#" value="#get_order_det_4.AMOUNT#"/>
                                 	</td>
                                    <cfset izinli_list = '-1,-2,-5,-6'><!---Açık,Tedarik,Üretim,Sevk--->
                                    <td style="text-align:center;">
                                    	<cfif len(get_order_det_4.SERIAL_NO)><!---Seri No İse--->
                                        	<cfinput type="hidden" name="serino_#get_order_rows.row_id#_#get_order_det_4.currentrow#" id="serino_#get_order_rows.row_id#_#get_order_det_4.currentrow#" value="#get_order_det_4.SERIAL_NO#">
                                         	<cfinput type="hidden" name="is_serial_no_#get_order_rows.row_id#" id="is_serial_no_#get_order_rows.row_id#" value="1">
                                        	<cfif get_order_det_4.SHIP_RESULT_ID eq 0><!--- WM de Sevkiyata Transfer Yapılmadıysa--->
                                            	<input type="checkbox" name="input_#get_order_rows.row_id#_#get_order_det_4.currentrow#" id="input_#sira#" value="1" >
                                                <cfinput type="hidden" name="kontrol_#sira#" id="kontrol_#sira#" value="1">
                                          	<cfelse>
                                            	<img src="images\c_ok.gif" title="Sevk Alanına Transfer Başladı">
                                            </cfif>
                                        <cfelse><!---Lot No İse--->
											<cfif ListFind(izinli_list,get_order_rows.ORDER_ROW_CURRENCY)> <!---Sipariş Satır Aşaması müsait mi?--->
                                            	<cfif get_order_rows.IS_KARMA eq 1>
                                                	<cfif izin eq 1 or izin eq 2>
                                                      	<input type="checkbox" name="input_#get_order_rows.row_id#_#get_order_det_4.currentrow#" id="input_#sira#" value="1" >
                                                    	<cfinput type="hidden" name="kontrol_#sira#" id="kontrol_#sira#" value="1">
                                                    <cfelseif izin eq 0>
                                                        <img src="images\d_ok.gif" title="Sevkten Çıkartılamaz">
                                                    </cfif>
                                                <cfelse>
                                                    <input type="checkbox" name="input_#get_order_rows.row_id#_#get_order_det_4.currentrow#" id="input_#sira#" value="1" >
                                                    <cfinput type="hidden" name="kontrol_#sira#" id="kontrol_#sira#" value="1">
                                          		</cfif>     
                                            <cfelse>
                                                <img src="images\b_ok.gif" title="<cf_get_lang dictionary_id='334.Sevk Edildi'>">
                                            </cfif>
                                      	</cfif>
                                 	</td>
                            	</tr>
                             	<cfif t eq 1>
                                	<cfset t = 0>
                            	</cfif>
                         	</cfloop>
                       		<cfif row_quantity gt 0 and get_order_det_4.amount neq 0><!---Seri No İse ve Henüz Seri No Bağlanmamışsa--->
                            	<cfset sira = sira+1>
                              	<tr>
                                  	<td></td>
                                    <td></td>
                                  	<td></td>
                                  	<td style="text-align:right">
                                        	<input type="text" name="rate_#get_order_rows.row_id#_#get_order_det_4.recordcount+1#" id="rate_#sira#" style="font-weight:bold; width:70px; text-align:right" value="#Tlformat(row_quantity,3)#"/>
                                          	<input type="hidden" name="quantity_#sira#" value="#row_quantity#"/>
                                        	<input type="hidden" name="p_order_id_#get_order_rows.row_id#_#get_order_det_4.recordcount+1#" value="0"/>
                                          	<input type="hidden" name="p_order_amount_#get_order_rows.row_id#_#get_order_det_4.currentrow+1#" value="0"/>
                                  	</td>
                                  	<td style="text-align:center;">
                                     	<input type="checkbox" name="input_#get_order_rows.row_id#_#get_order_det_4.recordcount+1#" id="input_#sira#" value="1">
                                    	<cfinput type="hidden" name="kontrol_#sira#" id="kontrol_#sira#" value="1">
                                 	</td>
                             	</tr>
                          	</cfif>
                        </cfoutput>
                    </tbody>
             	</cf_grid_list>
                <cf_box_footer>
					<div class="col col-12 col-xs-12">
                    	<div class="col col-8"></div>
                        <div class="col col-3">
                    		Hepsini Seç <input type="checkbox" name="all_conv_product" id="all_conv_product" onClick="javascript: wrk_select_all2('all_conv_product','input_',<cfoutput>#sira#</cfoutput>);">					</div>	
                      	<div class="col col-1">	
                     		<cf_workcube_buttons 
                            	insert_info = 'Sevkten Çıkar'
                               	is_upd='0' 
                              	add_function='control()'
                             	is_delete = '0'>
                     	</div>
                	</div>
         		</cf_box_footer>
         	</cfform>
     	</cf_basket>
  	</cf_box>
</div>
<script language="javascript">
	function control()
	{
		hata=0;
		<cfoutput>row_count=#sira#;</cfoutput>
		for(i=1;i<=row_count;i++)
		{
			if(document.getElementById('input_'+i).checked==true)
			{
				if(document.getElementById('rate_'+i).value == 0)
				{
					document.getElementById('rate_'+i).focus();
					hata=1;
				}
			}
		}
		if(hata==1)
		{
			alert('<cf_get_lang dictionary_id="1072.Sevk Miktarı"> : <cf_get_lang dictionary_id="54686.Hatalı">');
			return false;
		}
		else
			return true;
	}
	function wrk_select_all2(all_conv_product,input_,number)
	{
		for(var cl_ind=1; cl_ind <= number; cl_ind++)
		{
			if(document.getElementById('kontrol_'+cl_ind).value === undefined)
			{
				alert('aa');
			}
			else
			{
				if(document.getElementById('kontrol_'+cl_ind).value == 1)
				{
					if(document.getElementById(all_conv_product).checked == true)
					{
						if(document.getElementById('input_'+cl_ind).checked == false)
							document.getElementById('input_'+cl_ind).checked = true;
					}
					else
					{
						if(document.getElementById('input_'+cl_ind).checked == true)
							document.getElementById('input_'+cl_ind).checked = false;
					}
				}
			}
		}
	}
</script>
