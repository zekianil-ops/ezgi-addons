<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.list_type" default="2">
<cfif isdefined('seri_no')>
	<cfquery name="get_order_det" datasource="#DSN3#">
		SELECT 
        	11 TYPE,
        	(
                    SELECT 
                        TOP (1) EMP.MASTER_PLAN_NUMBER + ' - ' + EMP.MASTER_PLAN_DETAIL AS DETAIL
                    FROM     
                        EZGI_MASTER_PLAN_RELATIONS AS EPR INNER JOIN
                        EZGI_MASTER_ALT_PLAN AS EMAP ON EPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
                        EZGI_MASTER_PLAN AS EMP ON EMAP.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID
                    WHERE  
                        EPR.P_ORDER_ID = PO.P_ORDER_ID
           	) AS DETAIL,
        	PO.LOT_NO, 
            PO.FINISH_DATE, 
            PO.P_ORDER_ID,
            PO.P_ORDER_NO, 
            PO.START_DATE, 
           	PO.FINISH_DATE,
            1 AS QUANTITY,
            1 AS O_QUANTITY,
            0 AS IS_STAGE, 
            ORR.PRODUCT_NAME2, 
            EWM.PRODUCTION_ORDER_ROW_ID, 
            EWM.SERIAL_NO, 
            PO.STOCK_ID, 
            PO.SPEC_MAIN_ID,
            S.PRODUCT_ID
		FROM     
        	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
            ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID RIGHT OUTER JOIN
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
            PRODUCTION_ORDERS_ROW AS EWM ON PO.P_ORDER_ID = EWM.PRODUCTION_ORDER_ID ON ORR.ORDER_ROW_ID = EWM.ORDER_ROW_ID INNER JOIN
           	STOCKS AS S ON S.STOCK_ID  = PO.STOCK_ID
		WHERE 
        	ISNULL(S.IS_SERIAL_NO,0) = 1 AND
            PO.STOCK_ID = #attributes.stock_id# AND 
            PO.IS_STAGE <> 2 AND
            ISNULL(PO.IS_STOCK_RESERVED,0) = 1 AND
            EWM.SERIAL_NO IS NULL <!---Üretimi Tamamlanmamış--->
            <cfif isdefined('attributes.spect_var_id') and attributes.spect_var_id neq 0>
         		AND PO.SPEC_MAIN_ID =  (
                                        SELECT     
                                            SPECT_MAIN_ID
                                        FROM         
                                            SPECTS
                                        WHERE     
                                            SPECT_VAR_ID = #attributes.spect_var_id#
                                        )
        	</cfif> 
            <cfif len(attributes.list_type)>
                <cfif attributes.list_type eq 1>
                    AND NOT(ORR.ORDER_ROW_ID IS NULL)<!---Siparişe Bağlanmış--->
                <cfelseif attributes.list_type eq 2>
                    AND ORR.ORDER_ROW_ID IS NULL<!---Siparişe Bağlanmamış--->
                </cfif>
            </cfif>
            <cfif len(attributes.keyword)>
                AND (PO.P_ORDER_NO LIKE '%#attributes.keyword#%' OR PO.LOT_NO LIKE '%#attributes.keyword#%')
            </cfif>
	</cfquery>
   	
    <cfquery name="get_store_det" datasource="#DSN3#">
    	SELECT 
        	21 TYPE,
        	ES.SERIAL_NO, 
            ES.STOCK_ID, 
            ES.SPECT_ID, 
            ES.PALET_BARCODE, 
            ES.PRODUCT_NAME, 
            ES.SHELF_CODE, 
            ED.DEPO_NAME,
         	(
            	SELECT TOP (1) 
                	LOT_NO
             	FROM      
                	SERVICE_GUARANTY_NEW AS SG
             	WHERE   
                	STOCK_ID = ES.STOCK_ID AND 
                    ISNULL(SPECT_ID, 0) = ISNULL(ES.SPECT_ID, 0) AND 
                    SERIAL_NO = ES.SERIAL_NO
            	ORDER BY 
                	GUARANTY_ID DESC
         	) AS LOT_NO
		FROM     
       		ORDER_ROW AS ORR INNER JOIN
       		EZGI_WM_SERIAL_NO_ORDER_LAST_STATUS AS EO ON ORR.ORDER_ROW_ID = EO.RESERVE_ORDER_ROW_ID RIGHT OUTER JOIN
         	EZGI_WM_SERIAL_NO_LAST_STATUS AS ES INNER JOIN
       		EZGI_WM_DEPARTMENTS AS ED ON ES.DEPO = ED.DEPO ON EO.SERIAL_NO = ES.SERIAL_NO
		WHERE  
        	ES.STOCK_ID = #attributes.stock_id# AND 
            ISNULL(EO.RESERVE_ORDER_ROW_ID,0) = 0 <!---Siparişe Bağlanmamış--->
            <!---ISNULL(ES.SHIP_RESULT_ID,0) = 0---> <!---Sevk Planına Bağlanmamış--->
            <cfif isdefined('attributes.spect_var_id') and attributes.spect_var_id neq 0>
         		AND ES.SPECT_ID = (
                                        SELECT     
                                            SPECT_MAIN_ID
                                        FROM         
                                            SPECTS
                                        WHERE     
                                            SPECT_VAR_ID = #attributes.spect_var_id#
                              		)
        	</cfif> 
    </cfquery>
    
<cfelse>
    <cfquery name="get_order_det" datasource="#DSN3#">
        SELECT
            *
        FROM
            (
             SELECT 
                1 TYPE,
                (
                    SELECT 
                        TOP (1) EMP.MASTER_PLAN_NUMBER + ' - ' + EMP.MASTER_PLAN_DETAIL AS DETAIL
                    FROM     
                        EZGI_MASTER_PLAN_RELATIONS AS EPR INNER JOIN
                        EZGI_MASTER_ALT_PLAN AS EMAP ON EPR.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
                        EZGI_MASTER_PLAN AS EMP ON EMAP.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID
                    WHERE  
                        EPR.P_ORDER_ID = PO.P_ORDER_ID
                ) AS DETAIL,    
                PO.P_ORDER_ID, 
                PO.STOCK_ID, 
                PO.START_DATE, 
                PO.FINISH_DATE, 
                PO.QUANTITY, 
                PO.P_ORDER_NO, 
                PO.LOT_NO, 
                PO.IS_STAGE, 
                PO.SPEC_MAIN_ID,
                ISNULL((
                    SELECT 
                        SUM(QUANTITY) AS QUANTITY
                    FROM
                        (
                            SELECT 
                            	ISNULL(ORR.QUANTITY, 0) AS QUANTITY
                           	FROM      
                            	PRODUCTION_ORDERS AS POO INNER JOIN
                                PRODUCTION_ORDERS_ROW AS POR ON POO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID INNER JOIN
                                ORDER_ROW AS ORR ON POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID AND PO.STOCK_ID = ORR.STOCK_ID
                        	WHERE   
                            	POO.P_ORDER_ID = PO.P_ORDER_ID
                        )TBL_E
                ),0) AS O_QUANTITY,
            	S.PRODUCT_ID
			FROM            
            	PRODUCTION_ORDERS AS PO INNER JOIN
                STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID
			WHERE  
            	ISNULL(S.IS_SERIAL_NO,0) = 0 AND      
            	PO.STOCK_ID = #attributes.stock_id# 
                <cfif isdefined('attributes.spect_var_id') and attributes.spect_var_id neq 0>
                    AND PO.SPEC_MAIN_ID =  (
                                    SELECT     
                                        SPECT_MAIN_ID
                                    FROM         
                                        SPECTS
                                    WHERE     
                                        SPECT_VAR_ID = #attributes.spect_var_id#
                                    )
                </cfif>
            UNION ALL
            SELECT 
                2 TYPE, 
                CASE
                    WHEN ORDERS.COMPANY_ID IS NOT NULL THEN
                       (
                        SELECT     
                            NICKNAME
                        FROM         
                            #dsn_alias#.COMPANY
                        WHERE     
                            COMPANY_ID = ORDERS.COMPANY_ID
                        )
                    WHEN ORDERS.CONSUMER_ID IS NOT NULL THEN      
                        (	
                        SELECT     
                            CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                        FROM         
                            #dsn_alias#.CONSUMER
                        WHERE     
                            CONSUMER_ID = ORDERS.CONSUMER_ID
                        )
                END AS DETAIL,
                ORD_ROW.ORDER_ROW_ID P_ORDER_ID,    
                ORD_ROW.STOCK_ID, 
                ORDERS.ORDER_DATE START_DATE,
                ORD_ROW.DELIVER_DATE FINISH_DATE,
                ORD_ROW.QUANTITY,
                ORDERS.ORDER_NUMBER,
                '' AS LOT_NO,
                CASE 
                    WHEN 
                        ORD_ROW.ORDER_ROW_CURRENCY = -10 OR
                        ORD_ROW.ORDER_ROW_CURRENCY = -9 OR
                        ORD_ROW.ORDER_ROW_CURRENCY = -8 OR
                        ORD_ROW.ORDER_ROW_CURRENCY = -3
                    THEN
                        7
                    WHEN
                        ORD_ROW.ORDER_ROW_CURRENCY = -5 OR
                        ORD_ROW.ORDER_ROW_CURRENCY = -4 OR
                        ORD_ROW.ORDER_ROW_CURRENCY = -2 OR
                        ORD_ROW.ORDER_ROW_CURRENCY = -1
                    THEN
                        5
                    WHEN
                        ORD_ROW.ORDER_ROW_CURRENCY = -7 OR
                        ORD_ROW.ORDER_ROW_CURRENCY = -6
                    THEN
                        6
                    END
                        AS IS_STAGE,           	            
                S.SPECT_MAIN_ID,
                ORDER_ROW.QUANTITY O_QUANTITY,
                ORD_ROW.PRODUCT_ID
            FROM         
                ORDER_ROW AS ORD_ROW INNER JOIN
                ORDERS ON ORD_ROW.ORDER_ID = ORDERS.ORDER_ID INNER JOIN
                ORDER_ROW ON ORD_ROW.WRK_ROW_RELATION_ID = ORDER_ROW.WRK_ROW_ID LEFT OUTER JOIN
                SPECTS AS S ON ORD_ROW.SPECT_VAR_ID = S.SPECT_VAR_ID
            WHERE     
                ORDERS.PURCHASE_SALES = 0 AND 
                ORDERS.ORDER_ZONE = 0 AND
                ORD_ROW.STOCK_ID = #attributes.stock_id# 
                <cfif isdefined('attributes.spect_var_id') and attributes.spect_var_id neq 0>
                AND  S.SPECT_MAIN_ID =  
                                (
                                SELECT     
                                    SPECT_MAIN_ID
                                FROM         
                                    SPECTS
                                WHERE     
                                    SPECT_VAR_ID = #attributes.spect_var_id#
                                )
                </cfif>  
            UNION ALL
            SELECT 
                3 TYPE,
                CASE
                    WHEN ORDERS.COMPANY_ID IS NOT NULL THEN
                       (
                        SELECT     
                            NICKNAME
                        FROM         
                            #dsn_alias#.COMPANY
                        WHERE     
                            COMPANY_ID = ORDERS.COMPANY_ID
                        )
                    WHEN ORDERS.CONSUMER_ID IS NOT NULL THEN      
                        (	
                        SELECT     
                            CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                        FROM         
                            #dsn_alias#.CONSUMER
                        WHERE     
                            CONSUMER_ID = ORDERS.CONSUMER_ID
                        )
                END AS DETAIL,
                ORD_ROW.ORDER_ROW_ID P_ORDER_ID,    
                ORD_ROW.STOCK_ID, 
                ORDERS.ORDER_DATE START_DATE,
                ORD_ROW.DELIVER_DATE FINISH_DATE,
                ORD_ROW.QUANTITY,
                ORDERS.ORDER_NUMBER,
                '' AS LOT_NO,
                CASE 
                    WHEN 
                        ORD_ROW.ORDER_ROW_CURRENCY = -10 OR
                        ORD_ROW.ORDER_ROW_CURRENCY = -9 OR
                        ORD_ROW.ORDER_ROW_CURRENCY = -8 OR
                        ORD_ROW.ORDER_ROW_CURRENCY = -3
                    THEN
                        7
                    WHEN
                        ORD_ROW.ORDER_ROW_CURRENCY = -5 OR
                        ORD_ROW.ORDER_ROW_CURRENCY = -4 OR
                        ORD_ROW.ORDER_ROW_CURRENCY = -2 OR
                        ORD_ROW.ORDER_ROW_CURRENCY = -1
                    THEN
                        5
                    WHEN
                        ORD_ROW.ORDER_ROW_CURRENCY = -7 OR
                        ORD_ROW.ORDER_ROW_CURRENCY = -6
                    THEN
                        6
                    END
                        AS IS_STAGE,           	            
                S.SPECT_MAIN_ID,
                (
                SELECT     
                    ISNULL(SUM(ORR.QUANTITY),0) AS QUANTITY
                FROM         
                    EZGI_ORDERS_ORDERS_REL AS E INNER JOIN
                    ORDER_ROW AS ORR ON E.S_ORDER_ROW_ID = ORR.ORDER_ROW_ID AND E.S_ORDER_ID = ORR.ORDER_ID
                WHERE     
                    E.P_ORDER_ROW_ID = ORD_ROW.ORDER_ROW_ID 
                ) AS O_QUANTITY,
                ORD_ROW.PRODUCT_ID
            FROM
                ORDER_ROW AS ORD_ROW INNER JOIN
                ORDERS ON ORD_ROW.ORDER_ID = ORDERS.ORDER_ID LEFT OUTER JOIN
                ORDER_ROW ON ORD_ROW.WRK_ROW_RELATION_ID = ORDER_ROW.WRK_ROW_ID LEFT OUTER JOIN
                SPECTS AS S ON ORD_ROW.SPECT_VAR_ID = S.SPECT_VAR_ID
            WHERE     
                ORDERS.PURCHASE_SALES = 0 AND 
                ORDERS.ORDER_ZONE = 0 AND
                ORD_ROW.STOCK_ID = #attributes.stock_id# 
                <cfif isdefined('attributes.spect_var_id') and attributes.spect_var_id neq 0>
                AND  S.SPECT_MAIN_ID =  
                                (
                                SELECT     
                                    SPECT_MAIN_ID
                                FROM         
                                    SPECTS
                                WHERE     
                                    SPECT_VAR_ID = #attributes.spect_var_id#
                                )
                </cfif>  
                AND ORDER_ROW.WRK_ROW_ID IS NULL
            UNION ALL
            SELECT 
                6 TYPE,
                (
                    SELECT 
                        TOP (1) EMO.MASTER_PLAN_NUMBER + ' - ' + EMO.MASTER_PLAN_DETAIL AS DETAIL
                    FROM     
                        EZGI_IFLOW_MASTER_PLAN AS EMO
                    WHERE  
                        EMO.MASTER_PLAN_ID = EIP.MASTER_PLAN_ID
                ) AS DETAIL,
                EIP.IFLOW_P_ORDER_ID, 
                S.STOCK_ID, 
                EIP.START_DATE, 
                EIP.FINISH_DATE, 
                EIP.QUANTITY, 
                EIP.P_ORDER_NO, 
                EIP.LOT_NO,
                0 AS IS_STAGE,
                0 AS SPECT_MAIN_ID,
                ISNULL((
                        SELECT 
                            SUM(QUANTITY) AS QUANTITY
                        FROM     
                            (
                                SELECT DISTINCT 
                                    ORR.QUANTITY,
                                    EP.IFLOW_P_ORDER_ID, 
                                    ORR.ORDER_ROW_ID
                                FROM      
                                    EZGI_IFLOW_PRODUCTION_ORDERS AS EP WITH (NOLOCK) INNER JOIN
                                    PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EP.LOT_NO = PO.LOT_NO INNER JOIN
                                    PRODUCTION_ORDERS_ROW AS POR WITH (NOLOCK) ON PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID INNER JOIN
                                    ORDER_ROW AS ORR ON POR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                    ORDERS AS ORD WITH (NOLOCK) ON ORR.ORDER_ID = ORD.ORDER_ID INNER JOIN
                                    EZGI_IFLOW_MASTER_PLAN AS EMP ON EP.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID
                                WHERE   
                                    EP.IFLOW_P_ORDER_ID = EIP.IFLOW_P_ORDER_ID
                            ) AS TBL
                ),0) AS O_QUANTITY,
                S.PRODUCT_ID
            FROM     
                EZGI_IFLOW_PRODUCTION_ORDERS AS EIP INNER JOIN
                STOCKS AS S ON EIP.STOCK_ID = S.STOCK_ID
            WHERE  
                S.IS_KARMA = 1 AND
                EIP.STOCK_ID = #attributes.stock_id#
            ) AS TBL
        WHERE
            1=1
            <cfif len(attributes.list_type)>
                <cfif attributes.list_type eq 1>
                    AND O_QUANTITY >= QUANTITY
                <cfelseif attributes.list_type eq 2>
                    AND O_QUANTITY < QUANTITY
                </cfif>
            </cfif>
            <cfif len(attributes.keyword)>
                AND (P_ORDER_NO LIKE '%#attributes.keyword#%' OR LOT_NO LIKE '%#attributes.keyword#%')
            </cfif>
        ORDER BY
            FINISH_DATE desc
    </cfquery>
</cfif>
<cfquery name="get_stock_info" datasource="#dsn3#">
	SELECT     
    	S.STOCK_CODE, 
        S.PRODUCT_NAME, 
        PU.MAIN_UNIT
	FROM         
    	STOCKS AS S LEFT OUTER JOIN
        PRODUCT_UNIT AS PU ON S.PRODUCT_ID = PU.PRODUCT_ID
	WHERE     
    	S.STOCK_ID = #attributes.stock_id# AND 
        PU.IS_MAIN = 1
</cfquery>

<cfsavecontent variable="right_menu">
	<cfif isdefined("attributes.planning")>
    	<a href="<cfoutput>#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id=#attributes.order_id#"><img src="/images/outsource.gif" title="<cf_get_lang_main no='3390.Master Plana Geri Dön'>" border="0"></cfoutput></a>
  	<cfelse>
    	<a href="<cfoutput>#request.self#?fuseaction=sales.popup_list_order_production_rate&order_id=#attributes.order_id#"><img src="/images/outsource.gif" title="<cf_get_lang_main no='3390.Master Plana Geri Dön'>" border="0"></cfoutput></a>
 	</cfif>
</cfsavecontent>
<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id='60171.Beklenen Üretim'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box scroll="0">
    	<cfform name="search_list" action="#request.self#?fuseaction=sales.popup_list_ezgi_production&planning=#attributes.planning#&stock_id=#attributes.stock_id#&order_id=#attributes.order_id#&order_row_id=#attributes.order_row_id#&spect_var_id=#attributes.spect_var_id#&ord_quantity=#attributes.ord_quantity#" method="post">
            <input type="hidden" name="is_submitted" id="is_submitted" value="1">
            <cf_box_search>
            	<cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
        		<div class="form-group medium">
                	<select name="list_type" id="list_type" style="width:100px;">
                    	<option value="" <cfif attributes.list_type eq ''>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                  		<option value="1" <cfif attributes.list_type eq 1>selected</cfif>><cf_get_lang dictionary_id='58048.Rezerve Edilen'></option>
                   		<option value="2" <cfif attributes.list_type eq 2>selected</cfif>><cf_get_lang dictionary_id='29824.Rezerve Edilecek'></option>
                	</select>
              	</div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
            </cf_box_search>
        </cfform>
   	</cf_box>
	<cf_box title="#ezgi_header#" right_images="#right_menu#">
    	<cf_basket id="upd_default_measure_bask">
        	<cfform name="orders" action="" method="post">
            	<cf_grid_list sort="0">
                	<thead>
                        <tr> 
                        	<th width="20" style="text-align:center;"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th width="70" style="text-align:center;"><cf_get_lang dictionary_id='36698.Lot No'></th>
                            <th width="70" style="text-align:center;"><cf_get_lang dictionary_id='29474.Emir No'></th>
                            <th style="text-align:center;"><cf_get_lang dictionary_id='57771.Detay'></th>
                            <th width="70" style="text-align:center;"><cf_get_lang dictionary_id='57655	.Başlama Tarihi'></th>
                            <th width="70" style="text-align:center;"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></th>
                            <th width="80" style="text-align:center;"><cf_get_lang dictionary_id='138.Üretim Miktarı'></th>
                            <th width="20" style="text-align:center;"><cf_get_lang dictionary_id='538.DRM'></th>
                            <cfif not isdefined('seri_no')><th width="80" style="text-align:center;"><cf_get_lang dictionary_id='757.Rezerve Miktar'></th></cfif>
                            <th width="15" style="text-align:center;"></th>
                        </tr>
                    </thead>
                    <tbody>
					<cfif get_order_det.recordcount>
                            <cfoutput query="get_order_det">
                                <tr>
                                	<td>#currentrow#</td>
                                	<td>#lot_no#</td>
                                    <td>#p_order_no#</td>
                                    <td>#DETAIL#</td>
                                    <td>#DateFormat(START_DATE,dateformat_style)#</td>
                                    <td>#DateFormat(FINISH_DATE,dateformat_style)#</td>
                                    <td style="text-align:right;">#TLFormat(QUANTITY,2)#</td>
                                    <td style="text-align:center;">
                                    	<cfif IS_STAGE eq 0>
                                        	<img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='57705.İşleniyor'>">
                                        <cfelseif IS_STAGE eq 1>
                                        	<img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='35708.Devam Ediyor'>>">
                                        <cfelseif IS_STAGE eq 2>
                                        	<img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='58786.Tamamlandı'>">
                                       	<cfelseif IS_STAGE eq 5>
                                        	<img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
										<cfelseif IS_STAGE eq 6>
                                        	<img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='1092.Sevk Başladı'>">
                                        <cfelseif IS_STAGE eq 7>
                                        	<img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='57705.Tümü Teslim Edildi'>">     
                                        <cfelse>
                                        	<img src="/images/grey_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                        </cfif>
                                    </td>
                                    <cfif isdefined('seri_no')>
                                    	<td style="text-align:right;">
                                            <cfif TYPE eq 11><!---Üretim--->
                                                <a href="javascript://" onClick="ekle_(#attributes.ORDER_ID#,#attributes.ORDER_ROW_ID#,#PRODUCTION_ORDER_ROW_ID#,11);"><img src="/images/action_plus.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='1090.Üretim İlişkilendir'>"></a>
                                          	<cfelseif TYPE eq 6>
                                                <a href="javascript://" onClick="ekle_(#attributes.ORDER_ID#,#attributes.ORDER_ROW_ID#,#P_ORDER_ID#,6);"><img src="/images/action_plus.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='1090.Üretim İlişkilendir'>"></a>
                                         	<cfelse>
                                             	<a href="javascript://" onClick="ekle_(#attributes.ORDER_ID#,#attributes.ORDER_ROW_ID#,#P_ORDER_ID#,2);"><img src="/images/action_plus.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='1091.Tedarik İlişkilendir'>"></a>
                                       		</cfif>
                                        </td>
                                    
                                    <cfelse>
                                        <td style="text-align:right;">#TLFormat(O_QUANTITY,2)#
                                            <!---<a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_reserved_orders&taken=1&pid=#PRODUCT_ID#&p_order_id=#P_ORDER_ID#&type=#TYPE#','list');" class="tableyazi"> 
                                                #TLFormat(O_QUANTITY,2)#
                                            </a>--->
                                        </td>
                                        <td style="text-align:center;">
                                            <cfif O_QUANTITY lt QUANTITY>
                                                <cfif TYPE eq 1>
                                                <a href="javascript://" onClick="ekle_(#attributes.ORDER_ID#,#attributes.ORDER_ROW_ID#,#P_ORDER_ID#,1);"><img src="/images/action_plus.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='1090.Üretim İlişkilendir'>"></a>
                                                <cfelseif TYPE eq 6>
                                                <a href="javascript://" onClick="ekle_(#attributes.ORDER_ID#,#attributes.ORDER_ROW_ID#,#P_ORDER_ID#,6);"><img src="/images/action_plus.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='1090.Üretim İlişkilendir'>"></a>
                                                
                                                <cfelse>
                                                    <a href="javascript://" onClick="ekle_(#attributes.ORDER_ID#,#attributes.ORDER_ROW_ID#,#P_ORDER_ID#,2);"><img src="/images/action_plus.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='1091.Tedarik İlişkilendir'>"></a>
                                                </cfif>
                                            <cfelse>
                                                <img src="/images/action_pasif.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='38105.Eksik Miktar'>">    
                                            </cfif>
                                        </td>
                                    </cfif>
                                </tr>
                            </cfoutput>
					</cfif>
				</tbody>
                <tfoot>
                	<tr class="color-list" height="35">
                      	<td align="right" valign="middle" colspan="9">&nbsp;<div id="groups_p"></div></td>
                   	</tr>
              	</tfoot>
            </cf_grid_list>
      	</cfform>    
	</cf_box>
    
    <cfif isdefined('seri_no')>
    <cfsavecontent variable="ezgi_header_1"><cf_get_lang dictionary_id='33476.Stokta Olanlar'></cfsavecontent>
    <cf_box title="#ezgi_header_1#" right_images="">
    	<cf_basket id="upd_default_store">
        	<cfform name="stores" action="" method="post">
            	<cf_grid_list sort="0">
                	<thead>
                        <tr> 
                        	<th width="20" style="text-align:center;"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th width="70" style="text-align:center;"><cf_get_lang dictionary_id='57637.Seri No'></th>
                            <th width="70" style="text-align:center;"><cf_get_lang dictionary_id='36698.Lot No'></th>
                            <th width="70" style="text-align:center;"><cf_get_lang dictionary_id='1312.Palet Barkodu'></th>
                            <th width="70" style="text-align:center;"><cf_get_lang dictionary_id='45667.Raf'></th>
                            <th style="text-align:center;"><cf_get_lang dictionary_id='41184.Depo - Lokasyon'></th>
                            <th width="15" style="text-align:center;"></th>
                        </tr>
                    </thead>
                    <tbody>
						<cfif get_store_det.recordcount>
                            <cfoutput query="get_store_det">
                                <tr>
                                	<td>#currentrow#</td>
                                    <td>#SERIAL_NO#</td>
                                	<td>#LOT_NO#</td>
                                    <td>#PALET_BARCODE#</td>
                                    <td>#SHELF_CODE#</td>
                                    <td>#DEPO_NAME#</td>
                                 	<td style="text-align:right;">
                                     	<cfif TYPE eq 21><!---Üretim - Depo--->
                                         	<a href="javascript://" onClick="ekle_(#attributes.ORDER_ID#,#attributes.ORDER_ROW_ID#,'#SERIAL_NO#',21);"><img src="/images/action_plus.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='57909.İlişkilendir'>"></a>
                                    	</cfif>
                               	 	</td>
                                </tr>
                            </cfoutput>
						</cfif>
					</tbody>
                	<tfoot>
                		<tr class="color-list" height="35">
                      		<td align="right" valign="middle" colspan="9">&nbsp;<div id="groups_p"></div></td>
                   		</tr>
              		</tfoot>
            	</cf_grid_list>
      		</cfform>    
		</cf_box>
    </cfif>
    
</div>                
<script language="javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;
	}
	function ekle_(order_id,order_row_id,p_order_id,type)
	{	
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_add_ezgi_order_rel<cfif isdefined("attributes.planning")>&planning=1</cfif>&order_id='+order_id+'&order_row_id='+order_row_id+'&p_order_id='+p_order_id+'&type='+type;
	}
</script>	