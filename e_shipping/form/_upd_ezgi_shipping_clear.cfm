<cfif attributes.is_type eq 1>
        <cfquery name="get_order_rows" datasource="#dsn3#">
            SELECT        
                E.ORDER_ROW_ID, 
                ORR.PRODUCT_NAME, 
                ORR.QUANTITY, 
                E.SHIP_RESULT_ROW_ID as ROW_ID, 
                S.STOCK_ID, 
                S.PRODUCT_ID, 
                S.PRODUCT_CODE
            FROM            
                EZGI_SHIP_RESULT_ROW AS E INNER JOIN
                ORDER_ROW AS ORR ON E.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID
            WHERE        
                E.SHIP_RESULT_ID = #attributes.ship_id#
        </cfquery>
<cfelse>
        <cfquery name="get_order_rows" datasource="#dsn3#">
            SELECT        
                ORR.PRODUCT_NAME, 
                ORR.QUANTITY, 
                S.STOCK_ID, 
                S.PRODUCT_ID, 
                S.PRODUCT_CODE, 
                IR.SHIP_ROW_ID as ROW_ID, 
                ORR.ORDER_ROW_ID
            FROM            
                #dsn2_alias#.SHIP_INTERNAL_ROW AS IR INNER JOIN
                ORDER_ROW AS ORR ON IR.ROW_ORDER_ID = ORR.ORDER_ROW_ID INNER JOIN
                STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID
            WHERE        
                IR.DISPATCH_SHIP_ID = #attributes.ship_id#
        </cfquery>
</cfif>
<cfif get_order_rows.recordcount>
	<cfset row_id_list = ValueList(get_order_rows.ROW_ID)>
    <cfset satirlar = queryNew("order_row_id, ship_row_id, product_id, stock_id, product_code, product_name, quantity, rate, paket_amount,control_amount,barcod,is_sub,is_true","integer,integer,integer,integer, VarChar, VarChar, Decimal,Decimal,Decimal,Decimal,VarChar,Bit,Bit") />
 	<cfoutput query="get_order_rows">
    	<cfif attributes.is_type eq 1>
         	<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
            	SELECT
                	*,
                    #get_order_rows.QUANTITY#/PAKETSAYISI AS PAKET_ORAN
              	FROM
                	(
                                    SELECT
                                        PAKETSAYISI AS PAKETSAYISI,
                                        CONTROL_AMOUNT,
                                        STOCK_ID,
                                        BARCOD,
                                        STOCK_CODE,
                                        PRODUCT_NAME,
                                        SPECT_MAIN_ID
                                    FROM
                                        (
                                        SELECT
                                            SUM(PAKET_SAYISI) PAKETSAYISI,
                                            ISNULL(SUM(CONTROL_AMOUNT),0) CONTROL_AMOUNT,
                                            PAKET_ID STOCK_ID,
                                            BARCOD,
                                            STOCK_CODE,
                                            PRODUCT_NAME,
                                            PRODUCT_TREE_AMOUNT,
                                            SPECT_MAIN_ID
                                        FROM
                                            (      
                                            SELECT     
                                                SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                                                TBL_1.CONTROL_AMOUNT, 
                                                ESRR.SHIP_RESULT_ROW_ID, 
                                                ORR.STOCK_ID AS MODUL_STOCK_ID, 
                                                EPS.PAKET_ID, 
                                                S.BARCOD, 
                                                S.STOCK_CODE, 
                                                S.PRODUCT_NAME,
                                                S.PRODUCT_TREE_AMOUNT,
                                                ISNULL((SELECT SPECT_MAIN_ID FROM SPECTS WHERE SPECT_VAR_ID = ORR.SPECT_VAR_ID),0) AS SPECT_MAIN_ID
                                            FROM  
                                                EZGI_SHIP_RESULT AS ESR INNER JOIN
                                                EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                                                ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                                EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                                                STOCKS AS S ON EPS.PAKET_ID = S.STOCK_ID INNER JOIN
                                                SPECTS AS SP ON EPS.MODUL_SPECT_ID = SP.SPECT_MAIN_ID AND ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID LEFT OUTER JOIN
                                                (
                                                SELECT     
                                                    SHIPPING_ID, 
                                                    STOCK_ID, 
                                                    SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                                                FROM          
                                                    EZGI_SHIPPING_PACKAGE_LIST
                                                WHERE      
                                                    TYPE = 1 AND
                        							SHIPPING_ROW_ID = #get_order_rows.ROW_ID#
                                                GROUP BY 
                                                    SHIPPING_ID, 
                                                    STOCK_ID
                                                ) AS TBL_1 ON EPS.PAKET_ID = TBL_1.STOCK_ID AND ESR.SHIP_RESULT_ID = TBL_1.SHIPPING_ID INNER JOIN
                                                STOCKS AS S1 ON ORR.STOCK_ID = S1.STOCK_ID
                                            WHERE     
                                                ESR.SHIP_RESULT_ID = #attributes.ship_id# AND
                                                ESRR.SHIP_RESULT_ROW_ID = #get_order_rows.ROW_ID# AND
                                                ISNULL(S1.IS_PROTOTYPE,0) = 1
                                            GROUP BY 
                                                EPS.PAKET_ID, 
                                                TBL_1.CONTROL_AMOUNT, 
                                                ESRR.SHIP_RESULT_ROW_ID, 
                                                ORR.STOCK_ID, 
                                                S.BARCOD, 
                                                S.STOCK_CODE, 
                                                S.PRODUCT_NAME,
                                                S.PRODUCT_TREE_AMOUNT,
                                                ORR.SPECT_VAR_ID
                                          	UNION ALL
                                            SELECT     
                                                SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                                                TBL_1.CONTROL_AMOUNT, 
                                                ESRR.SHIP_RESULT_ROW_ID, 
                                                ORR.STOCK_ID AS MODUL_STOCK_ID, 
                                                EPS.PAKET_ID, 
                                                S.BARCOD, 
                                                S.STOCK_CODE, 
                                                S.PRODUCT_NAME,
                                                S.PRODUCT_TREE_AMOUNT,
                                                ISNULL((SELECT SPECT_MAIN_ID FROM SPECTS WHERE SPECT_VAR_ID = ORR.SPECT_VAR_ID),0) AS SPECT_MAIN_ID
                                            FROM  
                                                EZGI_SHIP_RESULT AS ESR INNER JOIN
                                                EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                                                ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                                EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                                                STOCKS AS S ON EPS.PAKET_ID = S.STOCK_ID LEFT OUTER JOIN
                                                (
                                                SELECT     
                                                    SHIPPING_ID, 
                                                    STOCK_ID, 
                                                    SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                                                FROM          
                                                    EZGI_SHIPPING_PACKAGE_LIST
                                                WHERE      
                                                    TYPE = 1 AND
                        							SHIPPING_ROW_ID = #get_order_rows.ROW_ID#
                                                GROUP BY 
                                                    SHIPPING_ID, 
                                                    STOCK_ID
                                                ) AS TBL_1 ON EPS.PAKET_ID = TBL_1.STOCK_ID AND ESR.SHIP_RESULT_ID = TBL_1.SHIPPING_ID INNER JOIN
                                                STOCKS AS S1 ON ORR.STOCK_ID = S1.STOCK_ID
                                            WHERE     
                                                ESR.SHIP_RESULT_ID = #attributes.ship_id# AND
                                                ESRR.SHIP_RESULT_ROW_ID = #get_order_rows.ROW_ID# AND
                                                ISNULL(S1.IS_PROTOTYPE,0) = 0
                                            GROUP BY 
                                                EPS.PAKET_ID, 
                                                TBL_1.CONTROL_AMOUNT, 
                                                ESRR.SHIP_RESULT_ROW_ID, 
                                                ORR.STOCK_ID, 
                                                S.BARCOD, 
                                                S.STOCK_CODE, 
                                                S.PRODUCT_NAME,
                                                S.PRODUCT_TREE_AMOUNT,
                                                ORR.SPECT_VAR_ID
                                            ) TBL_3
                                        GROUP BY
                                            PAKET_ID,
                                            BARCOD,
                                            STOCK_CODE,
                                            PRODUCT_NAME,
                                            PRODUCT_TREE_AMOUNT,
                                            SPECT_MAIN_ID
                                        ) AS TBL_4
               		) AS TBL_5
         	</cfquery>
     	<cfelse>
        	<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
            	SELECT
                	*,
                    #get_order_rows.QUANTITY#/PAKETSAYISI AS PAKET_ORAN
              	FROM
                	(
                                    SELECT
                                        CASE
                                            WHEN 
                                                PRODUCT_TREE_AMOUNT IS NOT NULL
                                            THEN 
                                                PRODUCT_TREE_AMOUNT
                                            ELSE
                                                PAKETSAYISI
                                        END 
                                            AS PAKETSAYISI,
                                        CONTROL_AMOUNT,
                                        STOCK_ID,
                                        BARCOD,
                                        STOCK_CODE,
                                        PRODUCT_NAME,
                                        SPECT_MAIN_ID
                                    FROM
                                        (
                                        SELECT
                                            SUM(PAKET_SAYISI) PAKETSAYISI,
                                            ISNULL(SUM(CONTROL_AMOUNT),0) CONTROL_AMOUNT,
                                            PAKET_ID STOCK_ID,
                                            BARCOD,
                                            STOCK_CODE,
                                            PRODUCT_NAME,
                                            PRODUCT_TREE_AMOUNT,
                                            SPECT_MAIN_ID
                                        FROM
                                            (      
                                            SELECT     
                                                TBL_1.CONTROL_AMOUNT, 
                                                EPS.PAKET_ID, 
                                                S.BARCOD, 
                                                SIR.SHIP_ROW_ID, 
                                                SIR.AMOUNT * EPS.PAKET_SAYISI AS PAKET_SAYISI, 
                                                S.STOCK_CODE, 
                                                S.PRODUCT_NAME,
                                                S.PRODUCT_TREE_AMOUNT,
                                                ISNULL((SELECT SPECT_MAIN_ID FROM SPECTS WHERE SPECT_VAR_ID = SIR.SPECT_VAR_ID),0) AS SPECT_MAIN_ID
                                            FROM         
                                                (
                                                SELECT     
                                                    SHIPPING_ID, 
                                                    STOCK_ID, 
                                                    SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                                                FROM          
                                                    EZGI_SHIPPING_PACKAGE_LIST
                                                WHERE      
                                                    TYPE = 2 AND
                        							SHIPPING_ROW_ID = #get_order_rows.ROW_ID#
                                                GROUP BY 
                                                    SHIPPING_ID, 
                                                    STOCK_ID
                                                ) TBL_1 RIGHT OUTER JOIN
                                                EZGI_PAKET_SAYISI AS EPS INNER JOIN
                                                STOCKS AS S ON EPS.PAKET_ID = S.STOCK_ID INNER JOIN
                                                #dsn2_alias#.SHIP_INTERNAL_ROW AS SIR INNER JOIN
                                                #dsn2_alias#.SHIP_INTERNAL AS SI ON SIR.DISPATCH_SHIP_ID = SI.DISPATCH_SHIP_ID ON EPS.MODUL_ID = SIR.STOCK_ID ON 
                                                TBL_1.SHIPPING_ID = SIR.DISPATCH_SHIP_ID AND TBL_1.STOCK_ID = EPS.PAKET_ID
                                            WHERE     
                                                SI.DISPATCH_SHIP_ID = #attributes.ship_id# AND
                                                SIR.SHIP_ROW_ID = #get_order_rows.ROW_ID#
                                            GROUP BY 
                                                EPS.PAKET_ID, 
                                                TBL_1.CONTROL_AMOUNT, 
                                                S.BARCOD, 
                                                SIR.SHIP_ROW_ID, 
                                                SIR.AMOUNT, 
                                                EPS.PAKET_SAYISI, 
                                                S.STOCK_CODE, 
                                                S.PRODUCT_NAME,
                                                S.PRODUCT_TREE_AMOUNT,
                                                SIR.SPECT_VAR_ID
                                            ) TBL_3
                                        GROUP BY
                                            PAKET_ID,
                                            BARCOD,
                                            STOCK_CODE,
                                            PRODUCT_NAME,
                                            PRODUCT_TREE_AMOUNT,
                                            SPECT_MAIN_ID
                                        ) AS TBL_4   
                   		) AS TBL_5    
         	</cfquery>
      	</cfif>
        <cfquery name="GET_SHIP" dbtype="query">
        	SELECT CONTROL_AMOUNT*PAKET_ORAN AS ORAN FROM GET_SHIP_PACKAGE_LIST
        </cfquery>
        <cfquery name="GET_SHIP_GROUP" dbtype="query">
        	SELECT ORAN FROM GET_SHIP GROUP BY ORAN
        </cfquery>
        <cfset Temp = QueryAddRow(satirlar)>
        <cfset Temp = QuerySetCell(satirlar, "order_row_id", get_order_rows.order_row_id)>
        <cfset Temp = QuerySetCell(satirlar, "ship_row_id", get_order_rows.row_id)>
        <cfset Temp = QuerySetCell(satirlar, "stock_id", get_order_rows.stock_id)>
        <cfset Temp = QuerySetCell(satirlar, "product_id", get_order_rows.product_id)>
        <cfset Temp = QuerySetCell(satirlar, "product_code", get_order_rows.product_code)>
        <cfset Temp = QuerySetCell(satirlar, "product_name", get_order_rows.product_name)>
        <cfset Temp = QuerySetCell(satirlar, "quantity", get_order_rows.quantity)>
        <cfset Temp = QuerySetCell(satirlar, "is_sub", 0)>
        <cfif GET_SHIP_GROUP.recordcount eq 1>
        	<cfset Temp = QuerySetCell(satirlar, "is_true", 1)>
            <cfset Temp = QuerySetCell(satirlar, "rate", GET_SHIP_GROUP.oran)>
        <cfelse>
        	<cfset Temp = QuerySetCell(satirlar, "is_true", 0)>
            <cfset Temp = QuerySetCell(satirlar, "rate", '')>
        </cfif>
        <cfloop query="GET_SHIP_PACKAGE_LIST">
        	<cfset Temp = QueryAddRow(satirlar)>
            <cfset Temp = QuerySetCell(satirlar, "stock_id", GET_SHIP_PACKAGE_LIST.stock_id)>
            <cfset Temp = QuerySetCell(satirlar, "product_code", GET_SHIP_PACKAGE_LIST.stock_code)>
            <cfset Temp = QuerySetCell(satirlar, "product_name", GET_SHIP_PACKAGE_LIST.product_name)>
            <cfset Temp = QuerySetCell(satirlar, "paket_amount", GET_SHIP_PACKAGE_LIST.PAKETSAYISI)>
            <cfset Temp = QuerySetCell(satirlar, "control_amount", GET_SHIP_PACKAGE_LIST.CONTROL_AMOUNT)>
            <cfset Temp = QuerySetCell(satirlar, "barcod", GET_SHIP_PACKAGE_LIST.BARCOD)>
            <cfset Temp = QuerySetCell(satirlar, "is_sub", 1)>
        </cfloop>
 	</cfoutput>
</cfif>
<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id='1114.Müşteri Bazında Sevkiyat'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#ezgi_header#" right_images="">
    	<cf_basket id="upd_default_measure_bask">
        	<cfform name="add_packet_ship" id="add_packet_ship" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_ezgi_shipping_clear&ship_id=#attributes.ship_id#&is_type=#attributes.is_type#">
            	<cfinput type="hidden" name="row_id_list" value="#row_id_list#">
                <cf_grid_list sort="0">
                    <thead>
                        <tr height="20px">
                            <th width="140px"><cf_get_lang dictionary_id='57633.Barkod'></th>
                            <th width="120px"><cf_get_lang dictionary_id='58585.Kod'></th>
                            <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                            <th width="90px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            <th width="90px"><cf_get_lang dictionary_id='47396.Kontrol'></th>
                            <th width="20px"><cf_get_lang dictionary_id='52513.Ok'></th>
                        </tr>
                    </thead>
					<tbody>
                        <cfoutput query="satirlar">
                            <cfif is_sub eq 0>
                                <tr height="30">
                                    <td></td>
                                    <td><b>#PRODUCT_CODE#</b></td>
                                    <td><b>#PRODUCT_NAME#</b></td>
                                    <td style="text-align:right"><b>#Tlformat(QUANTITY,3)#</b></td>
                                    <td style="text-align:right">
                                    	<input type="text" name="rate_#satirlar.ship_row_id#" id="rate_#satirlar.ship_row_id#" readonly="readonly" style="font-weight:bold; width:70px; text-align:right" value="#Tlformat(rate,3)#"/>
                                        <input type="hidden" name="quantity_#satirlar.ship_row_id#" value="#TlFormat(QUANTITY,3)#"/>
                                        <input type="hidden" name="order_row_id_#satirlar.ship_row_id#" value="#order_row_id#"/>
                                  	</td>
                                    <td style="text-align:center">
                                    	<cfif rate gte 0>
                                        	<cfif quantity neq rate or rate eq 0>
                                        		<input type="checkbox" name="input_#satirlar.ship_row_id#" id="input_#satirlar.ship_row_id#" value="1" checked="checked" />
                                            <cfelse>
                                            	<img src="images\c_ok.gif" title="<cf_get_lang dictionary_id='773.Hepsi Okundu'>">
                                            </cfif>
                                        <cfelse>
                                       		<img src="images\warning.gif" title="<cf_get_lang dictionary_id='774.Orantısız Okuma'>">
                                        </cfif>
                                    </td>
                                </tr>
                            <cfelse>
                                <tr height="30">
                                    <td>#BARCOD#</td>
                                    <td>#PRODUCT_CODE#</td>
                                    <td>#product_name#</td>
                                    <td style="text-align:right">#Tlformat(paket_amount,3)#</td>
                                    <td style="text-align:right">#Tlformat(CONTROL_AMOUNT,3)#</td>
                                    <td style="text-align:center"></td>
                                </tr>
                            </cfif>
                        </cfoutput>
                    </tbody>
                    
              	</cf_grid_list>
                <cf_box_footer>
						<div class="col col-12 col-xs-12">
                        	<cf_workcube_buttons 
                               	is_upd='0' 
                              	add_function='control()'
                             	is_delete = '0'>
                     	</div>
                	</cf_box_footer>
         	</cfform>
     	</cf_basket>
  	</cf_box>
</div>
<script language="javascript">
	function control()
	{
		return true;
	}
</script>
