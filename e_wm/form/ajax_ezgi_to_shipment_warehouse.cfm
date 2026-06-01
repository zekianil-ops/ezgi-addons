<!---
    File: ajax_ezgi_to_shipment_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2025
    Description: Sevkiyata Ürün Hazırlama Ajax
--->
<audio id="warning" src="AddOns/ezgi/sounds/warning.mp3" preload="auto"></audio>
<audio id="confirm" src="AddOns/ezgi/sounds/confirm.mp3" preload="auto"></audio>

<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
	<cfif attributes.is_type eq 1>
     	SELECT     
       		PAKET_SAYISI AS PAKETSAYISI, 
       		PAKET_ID AS STOCK_ID, 
       		BARCOD, 
       		STOCK_CODE, 
       		PRODUCT_NAME,
       		SPECT_MAIN_ID
   		FROM         
       		(
       		SELECT
       		    SUM(PAKET_SAYISI) AS PAKET_SAYISI,
       		    PAKET_ID, 
       		    BARCOD, 
       		    STOCK_CODE, 
       		    PRODUCT_NAME, 
       		    SHIP_RESULT_ID,
       		    SPECT_MAIN_ID
       		FROM
       		    (     
       		    SELECT 
       		        SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
       		        EPS.PAKET_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_ID,
       		        ISNULL(SP.SPECT_MAIN_ID,0) AS SPECT_MAIN_ID
       		    FROM          
       		        STOCKS AS S1 WITH (NOLOCK) INNER JOIN
       		        EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
       		        EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
       		        ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
       		        SPECTS AS SP ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
       		        STOCKS AS S WITH (NOLOCK) INNER JOIN
       		        EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID 
       		    WHERE      
       		        ESR.SHIP_RESULT_ID = #attributes.ship_id# AND
       		        ORR.ORDER_ROW_CURRENCY = -6 AND
       		        ISNULL(S1.IS_PROTOTYPE,0) = 1 
       		    GROUP BY 
       		        EPS.PAKET_ID,
       		        EPS.MODUL_SPECT_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_ID,
       		        ORR.SPECT_VAR_ID,
       		        SP.SPECT_MAIN_ID
       		    UNION ALL
       		    SELECT 
       		        SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
       		        EPS.PAKET_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_ID,
       		        0 AS SPECT_MAIN_ID
       		    FROM
       		        EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
       		        EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
       		        ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
       		        EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
       		        STOCKS AS S WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID INNER JOIN
       		        STOCKS AS S1 WITH (NOLOCK) ON S1.STOCK_ID = ORR.STOCK_ID
       		    WHERE      
       		        ESR.SHIP_RESULT_ID = #attributes.ship_id# AND
       		        ORR.ORDER_ROW_CURRENCY = -6 AND
       		        ISNULL(S1.IS_PROTOTYPE,0) = 0
       		    GROUP BY
       		        EPS.PAKET_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_ID,
       		        ORR.SPECT_VAR_ID
       		    ) AS TBL1
       		GROUP BY
       		    PAKET_ID, 
       		    BARCOD, 
       		    STOCK_CODE, 
       		    PRODUCT_NAME, 
       		    SHIP_RESULT_ID,
       		    SPECT_MAIN_ID
       		) AS TBL
       	ORDER BY
       		PRODUCT_NAME,
       		SPECT_MAIN_ID
 	<cfelse>
    	SELECT     
       		PAKET_SAYISI AS PAKETSAYISI, 
       		PAKET_ID AS STOCK_ID, 
       		BARCOD, 
       		STOCK_CODE, 
       		PRODUCT_NAME,
       		SPECT_MAIN_ID
   		FROM         
       		(
       		SELECT
       		    SUM(PAKET_SAYISI) AS PAKET_SAYISI,
       		    PAKET_ID, 
       		    BARCOD, 
       		    STOCK_CODE, 
       		    PRODUCT_NAME, 
       		    SHIP_RESULT_ID,
       		    SPECT_MAIN_ID
       		FROM
       		    (     
       		    SELECT 
       		        SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
       		        EPS.PAKET_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
       		        ISNULL(SP.SPECT_MAIN_ID,0) AS SPECT_MAIN_ID
       		    FROM          
       		        STOCKS AS S1 WITH (NOLOCK) INNER JOIN
       		        EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
       		        EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
       		        ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
       		        SPECTS AS SP ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
       		        STOCKS AS S WITH (NOLOCK) INNER JOIN
       		        EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID 
       		    WHERE      
       		        ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
       		        ORR.ORDER_ROW_CURRENCY = -6 AND
       		        ISNULL(S1.IS_PROTOTYPE,0) = 1 
       		    GROUP BY 
       		        EPS.PAKET_ID,
       		        EPS.MODUL_SPECT_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_INTERNALDEMAND_ID,
       		        ORR.SPECT_VAR_ID,
       		        SP.SPECT_MAIN_ID
       		    UNION ALL
       		    SELECT 
       		        SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
       		        EPS.PAKET_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_INTERNALDEMAND_ID,
       		        0 AS SPECT_MAIN_ID
       		    FROM
       		        EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
       		        EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
       		        ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
       		        EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
       		        STOCKS AS S WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID INNER JOIN
       		        STOCKS AS S1 WITH (NOLOCK) ON S1.STOCK_ID = ORR.STOCK_ID
       		    WHERE      
       		        ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
       		        ORR.ORDER_ROW_CURRENCY = -6 AND
       		        ISNULL(S1.IS_PROTOTYPE,0) = 0
       		    GROUP BY
       		        EPS.PAKET_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_INTERNALDEMAND_ID,
       		        ORR.SPECT_VAR_ID
       		    ) AS TBL1
       		GROUP BY
       		    PAKET_ID, 
       		    BARCOD, 
       		    STOCK_CODE, 
       		    PRODUCT_NAME, 
       		    SHIP_RESULT_ID,
       		    SPECT_MAIN_ID
       		) AS TBL
       	ORDER BY
       		PRODUCT_NAME,
       		SPECT_MAIN_ID
	</cfif>
</cfquery>
<cfquery name="get_detail_package_list" datasource="#DSN3#">
        SELECT 
        	2 AS VIRTUAL_ROW_ID,
            CASE
                WHEN 
                    ISNULL(EPS.IS_PROTOTYPE,0) = 0
                THEN 
                    0
                WHEN
                    ISNULL(EPS.IS_PROTOTYPE,0) = 1
                THEN
                    EPS.SPECT_ID
            END AS SPECT_MAIN_ID,
            EPS.STOCK_ID, 
            EPS.PRODUCT_NAME,
            EPS.PRODUCT_PLACE_ID, 
            EPS.DEPO, 
            EPS.IS_PROTOTYPE, 
            EPS.SHELF_CODE, 
            EPS.SHIP_RESULT_ID, 
            EPS.SHIP_RESULT_TYPE, 
            EPS.SERIAL_NO, 
            EPS.OUT_PRODUCT_PLACE_ID, 
            EPP.SHELF_CODE AS OUT_SHELF_CODE
        FROM     
            EZGI_WM_SERIAL_NO_LAST_STATUS AS EPS WITH (NOLOCK) LEFT OUTER JOIN
            EZGI_PRODUCT_PLACE AS EPP WITH (NOLOCK) ON EPS.OUT_PRODUCT_PLACE_ID = EPP.PRODUCT_PLACE_ID
        WHERE
            EPS.SHIP_RESULT_ID = #attributes.ship_id# AND 
            EPS.SHIP_RESULT_TYPE = #attributes.is_type#
</cfquery>
<cfquery name="get_total_control" dbtype="query">
  	SELECT COUNT(*) AS CONTROL_AMOUNT FROM get_detail_package_list
</cfquery>
<cfquery name="get_total_package" dbtype="query">
 	SELECT sum(PAKETSAYISI) PAKETSAYISI FROM GET_SHIP_PACKAGE_LIST
</cfquery>
<cfoutput>
    <input type="hidden" id="total_package" name="total_package" value="#get_total_package.PAKETSAYISI#">
    <input type="hidden" id="total_control" name="total_control" value="#get_total_control.CONTROL_AMOUNT#">
</cfoutput>
<cfif attributes.type eq 1> <!---Ürünler--->
    <cfquery name="get_detail_package_group" dbtype="query">
        SELECT
            SPECT_MAIN_ID,
            STOCK_ID,
            COUNT(*) AS CONTROL_AMOUNT
        FROM
            get_detail_package_list
        GROUP BY
            SPECT_MAIN_ID,
            STOCK_ID	 	
    </cfquery>
    <cfoutput query="get_detail_package_group">
        <cfset 'control_amount#STOCK_ID#_#SPECT_MAIN_ID#' = CONTROL_AMOUNT>
    </cfoutput>
	<cfsavecontent variable="title"><cfif attributes.is_type eq 1><b><cf_get_lang dictionary_id='382.Sevk Plan No'> :</b><cfelse><b><cf_get_lang dictionary_id='375.Sevk Talep No'> :</b></cfif><cfoutput>#attributes.ship_number#</cfoutput></cfsavecontent>
	<cf_box title="#title#">
   		<cf_grid_list>
   		    <thead>
   		        <tr>
   		            <th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
   		            <th></th>
                    <th></th>
   		            <th style="width:100%"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
   		            <th style="width:25px"><cf_get_lang dictionary_id='57635.Miktar'></th>
   		            <th style="width:20px"><cf_get_lang dictionary_id='45358.Kontrol'></th>
   		            <th style="width:120px">&nbsp;&nbsp;&nbsp;</th>
   		        </tr>
   		    </thead>
   		    <tbody>
   		        <cfif GET_SHIP_PACKAGE_LIST.recordcount>
   		            <cfoutput query="GET_SHIP_PACKAGE_LIST">
   		                <tr height="20">
   		                    <td style="text-align:right">#currentrow#</td>
   		                    <!-- sil -->
   		                    <td class="iconL">
   		                        <a href="javascript:void(0)" onclick="gizle_goster(order_row#currentrow#);connectAjax('#currentrow#','#STOCK_ID#','#SPECT_MAIN_ID#');gizle_goster(order_row#currentrow#);gizle_goster(order_row#currentrow#);"><i class="fa fa-caret-right"></i></a>
   		                    </td>
                            <td class="iconL">
   		                        <a href="javascript:void(0)" onclick="FindAjax('#currentrow#','#STOCK_ID#','#SPECT_MAIN_ID#');"><i class="fa fa-question-circle"></i></a>
   		                    </td>
   		                    <!-- sil -->
   		                    <td>#product_name#<cfif SPECT_MAIN_ID gt 0><font color="red"> - #SPECT_MAIN_ID#</font></cfif></td> 
   		                    <td style="text-align:right">#PAKETSAYISI#</td>
   		                    <td style="text-align:right"><cfif isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')>#Evaluate('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')#<cfelse>0</cfif></td>
   		                    <td align="center" valign="middle">      
   		                        <cfif isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#') and len(Evaluate('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')) and Evaluate('control_amount#STOCK_ID#_#SPECT_MAIN_ID#') eq PAKETSAYISI>
   		                            <img id="is_durum#currentrow#" src="images\c_ok.gif">
   		                        <cfelseif isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#') and len(Evaluate('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')) and Evaluate('control_amount#STOCK_ID#_#SPECT_MAIN_ID#') neq PAKETSAYISI>
   		                            <img id="is_durum#currentrow#" src="images\warning.gif">
                              	<cfelseif not isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')>
   		                            <img id="is_durum#currentrow#" src="/images/caution_small.gif">
   		                        </cfif>
   		                    </td>
   		                </tr>
   		                <!-- sil -->
                        <cfquery name="row_detail" dbtype="query">
                        	SELECT SERIAL_NO FROM get_detail_package_list WHERE STOCK_ID = #STOCK_ID# AND SPECT_MAIN_ID = #SPECT_MAIN_ID# ORDER BY SERIAL_NO
                        </cfquery>
   		                <tr id="order_row#currentrow#" style="display:none">
   		                    <td colspan="7">
   		                       	<table cellpadding="0" cellspacing="0" border="1" style="width:100%">
                               		<tr style="height:10px; background-color:silver">
                                    	<td style="text-align:right; width:30px"><cf_get_lang dictionary_id='58577.Sıra'></td>
                                        <td style="text-align:center;"><cf_get_lang dictionary_id='57637.Seri No'></td>
                                    </tr>
                                    <cfif row_detail.recordcount>
                                    	<cfloop query="row_detail">
                                            <tr style="height:10px; background-color:white">
                                                <td style="text-align:right;">#row_detail.currentrow#</td>
                                                <td style="text-align:center;">#row_detail.SERIAL_NO#</td>
                                            </tr>
                                        </cfloop>
                                    <cfelse>
                                    </cfif>
                               	</table>
   		                    </td>
   		                </tr>
   		                <!-- sil -->
   		            </cfoutput>
   		        </cfif>
   		    </tbody>
   		</cf_grid_list>
	</cf_box>
<cfelseif attributes.type eq 2><!---Seri No lar--->
    <cfquery name="get_detail_package_group" dbtype="query">
        SELECT
            SPECT_MAIN_ID,
            STOCK_ID,
            COUNT(*) AS CONTROL_AMOUNT
        FROM
            get_detail_package_list
        GROUP BY
            SPECT_MAIN_ID,
            STOCK_ID	 	
    </cfquery>
    <cfoutput query="get_detail_package_group">
        <cfset 'control_amount_#STOCK_ID#_#SPECT_MAIN_ID#' = CONTROL_AMOUNT>
    </cfoutput>
    <cfset hata = 0>
    <cfif isdefined('attributes.serial_no') and len(attributes.serial_no)><!---Seri No Gönderilmişse--->
    	<cfif isdefined('attributes.sil') and attributes.sil eq 1> <!---Görev Silmek mi--->
        	<cfquery name="get_serial_list" dbtype="query">
                SELECT * FROM get_detail_package_list WHERE SERIAL_NO = '#attributes.serial_no#'
            </cfquery>
            <cfif not get_serial_list.recordcount>
                <script type="text/javascript">
                    document.getElementById("warning").play();
                    alert("<cfoutput>#attributes.serial_no#</cfoutput> Seri No Daha Önce Bu Siparişten Çıkartılmış!");
                </script>
            <cfelse>
            	<cfset attributes.del_serial = 1>
            	<cfinclude template="../query/add_ezgi_pallets_to_shipment_warehouse.cfm">
             	<script type="text/javascript">
                 	document.getElementById("confirm").play();
					alert("<cfoutput>#attributes.serial_no#</cfoutput> Seri Nolu Ürün Sevkiyata Transfer İşleminden Çıkartılmıştır!");
              	</script>
            </cfif>
        <cfelse><!---Görev Eklemek mi--->
        	<cfif attributes.is_type eq 1> <!---Sevk Planına Bağlı Order_Row_Id listesini buluyorum--->
                <cfquery name="get_order_row_id" datasource="#dsn3#">
                    SELECT 
                        ESR.ORDER_ROW_ID
                    FROM     
                        EZGI_SHIP_RESULT_ROW AS ESR INNER JOIN
                        ORDER_ROW AS ORR ON ESR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                        ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID
                    WHERE  
                        ESR.SHIP_RESULT_ID = #attributes.ship_id# AND 
                        ORR.ORDER_ROW_CURRENCY IN (-6)
                </cfquery>
            <cfelse><!---Sevk Talebine Bağlı Order_Row_Id listesini buluyorum--->
            	<cfquery name="get_order_row_id" datasource="#dsn3#">
                    SELECT 
                        ESR.ORDER_ROW_ID
                    FROM     
                        EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESR INNER JOIN
                        ORDER_ROW AS ORR ON ESR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                        ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID
                    WHERE  
                        ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND 
                        ORR.ORDER_ROW_CURRENCY IN (-6)
                </cfquery>
            </cfif>
            <cfset order_row_id_list = ValueList(get_order_row_id.ORDER_ROW_ID)>
            <cfquery name="get_detail_package_list" dbtype="query">
                SELECT * FROM get_detail_package_list WHERE SERIAL_NO = '#attributes.serial_no#'
            </cfquery>
            <cfif get_detail_package_list.recordcount><!---Bu Sipariş İçin Tekrar Okutuluyor mu--->
                <script type="text/javascript">
                    document.getElementById("warning").play();
                    alert("<cfoutput>#attributes.serial_no#</cfoutput> Seri No Daha Önce Bu Sipariş İçin Okutulmuş!");
                </script>
                <cfset hata = 1>
            <cfelse>
                <cfquery name="get_serial" datasource="#dsn3#">
                    SELECT 
                        CASE
                            WHEN
                                (SELECT ISNULL(IS_PROTOTYPE,0) AS IS_PROTOTYPE FROM STOCKS WHERE STOCK_ID = EWM.STOCK_ID) = 1
                            THEN
                                EWM.SPECT_ID
                            ELSE
                                0
                        END AS SPECT_MAIN_ID,  	
                        EWM.STOCK_ID, 
                        EWM.PRODUCT_NAME, 
                   		EWM.PRODUCT_PLACE_ID, 
                        EWM.LOCATION_ID, 
                        EWM.DEPARTMENT_ID, 
                  		EWM.DEPO,
                        ISNULL(ES.PRODUCTION_ORDER_ROW_ID,0) AS PRODUCTION_ORDER_ROW_ID, 
                        EVL.SERIAL_NO,
                        ISNULL(ORR.ORDER_ROW_ID,0) AS ORDER_ROW_ID,
                        O.ORDER_ID, 
                        O.ORDER_NUMBER,
                        ISNULL(PP.SHELF_TYPE,0) AS SHELF_TYPE,
                        PP.SHELF_CODE
                    FROM     
                        ORDER_ROW AS ORR INNER JOIN
                        EZGI_WM_ORDER_LAST_STATUS AS ES ON ORR.ORDER_ROW_ID = ES.ORDER_ROW_ID INNER JOIN
                        ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID RIGHT OUTER JOIN
                        EZGI_WM_IS_SERIAL_NO_LIVE AS EVL INNER JOIN
                        EZGI_WM_SERIAL_NO_LAST_STATUS AS EWM ON EVL.SERIAL_NO = EWM.SERIAL_NO ON ES.SERIAL_NO = EWM.SERIAL_NO LEFT OUTER JOIN
         				PRODUCT_PLACE AS PP WITH (NOLOCK) ON EWM.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID
                    WHERE  
                        EVL.SERIAL_NO = '#attributes.serial_no#'
                </cfquery>
                <cfif not get_serial.recordcount><!---Bu SeRi No Yok mu?--->
                    <script type="text/javascript">
                        document.getElementById("warning").play();
                        alert("<cfoutput>#attributes.serial_no#</cfoutput> Seri No Bulunamdı!");
                    </script>
                    <cfset hata = 2>
                <cfelse> 
                	<cfif get_serial.DEPO neq attributes.to_department_loctaion_id> <!---Eğer Sevkiyata Çıkacak Ürün Aynı Depoda Değil İse--->
                    	<script type="text/javascript">
							document.getElementById("warning").play();
							alert("<cfoutput>#attributes.serial_no#</cfoutput> Seri No lu Ürün Sevkiyat Alanı ile Aynı Depoda Değil!");
						</script>
						<cfset hata = 9>
                    <cfelse><!---Eğer Sevkiyata Çıkacak Ürün Aynı Depoda İse--->
						<cfif get_serial.ORDER_ROW_ID gt 0><!---Okutulan Seri No Herhangi Bir Siparişe Bağlı mı--->
                            <cfif not ListFind(order_row_id_list,get_serial.ORDER_ROW_ID)><!---Sevkiyat Belgesine Bağlı Sipariş Satırlarına Bağlı Değil mi--->
                                <cfset hata = 3>
                                <script type="text/javascript">
                                    document.getElementById("warning").play();
                                    alert("<cfoutput>#attributes.serial_no# Seri Nolu Ürün #get_serial.ORDER_NUMBER#</cfoutput> Sipariş İçin Rezerve Edilmiş!");
                                </script>
                            <cfelse>
                            	<cfquery name="GET_SHIP_PACKAGE_LIST_GROUP" dbtype="query"> <!---Seri Noya Ait Ürünün Toplam Transfer Sayısını Buluyorum--->
                                	SELECT     
                                	    PAKETSAYISI,
                                	    PRODUCT_NAME, 
                                	    STOCK_ID, 
                                	    SPECT_MAIN_ID
                                	FROM
                                	    GET_SHIP_PACKAGE_LIST
                                	WHERE
                                	    SPECT_MAIN_ID = #get_serial.SPECT_MAIN_ID# AND
                                	    STOCK_ID = #get_serial.STOCK_ID#
                            	</cfquery> 
                             	<cfif not GET_SHIP_PACKAGE_LIST_GROUP.recordcount>
                                	<cfset hata = 5>
                                	<script type="text/javascript">
                                	    document.getElementById("warning").play();
                                	    alert("<cfoutput>#get_serial.PRODUCT_NAME#</cfoutput> Ürünü <cfoutput>#attributes.ship_number#</cfoutput> Belge Nolu Sevk Belgesinde Yoktur!");
                                	</script>
                              	<cfelse>
                                	<cfset buldum = 0>
                                	<cfloop query="GET_SHIP_PACKAGE_LIST_GROUP">
                                	    <cfif not isdefined('control_amount_#GET_SHIP_PACKAGE_LIST_GROUP.STOCK_ID#_#GET_SHIP_PACKAGE_LIST_GROUP.SPECT_MAIN_ID#') or Evaluate('control_amount_#GET_SHIP_PACKAGE_LIST_GROUP.STOCK_ID#_#GET_SHIP_PACKAGE_LIST_GROUP.SPECT_MAIN_ID#') lt GET_SHIP_PACKAGE_LIST_GROUP.PAKETSAYISI>
                                	        <cfset buldum = 1>
                                	        <cfbreak>
                                	    </cfif>
                                	</cfloop>
                                	<cfif buldum eq 0> <!---Ürün Bu Sevk Belgesinde olduğu halde Tamamı Sevkiyata Alanına Gönderilmiştir--->
                                	    <cfset hata = 6>
                                	    <script type="text/javascript">
                                	        document.getElementById("warning").play();
                                	        alert("<cfoutput>#get_serial.PRODUCT_NAME#</cfoutput> Ürünü İçin Fazla Sevkiyat Yapılamaz!");
                                	    </script>
                                	<cfelse>
                                		<cfset attributes.add_serial = 1>
                                		<cfinclude template="../query/add_ezgi_pallets_to_shipment_warehouse.cfm">
                                	</cfif>
                             	</cfif>
                            </cfif>
                        <cfelse>
                            <cfif get_serial.SHELF_TYPE eq 5><!---Seri Nolu Ürün Seviyat Belgesi İçin Sevkiyat Alanına Çıkartılmış mı--->
                                <cfset hata = 4>
                                <script type="text/javascript">
                                    document.getElementById("warning").play();
                                    alert("<cfoutput>#attributes.serial_no#</cfoutput> Seri No Başka Sevk Belgesi İçin Yükleme Alanına Alınmış!");
                                </script>
                            <cfelse>
                                <!---Seri No lu Ürünün STOCK ID ve SPECT ID leri üzerinden Bu Sevk Belgesinin Sipariş Satıralı İçin Rezerve Edilmiş Seri Numaralarını Listeliyorum (Sevkiyat Depoya Transfer Edilmişler Hariç)--->
                                <cfquery name="get_order_row_serial_no" datasource="#dsn3#">
                                    SELECT 
                                        ISNULL(ES.PRODUCTION_ORDER_ROW_ID, 0) AS PRODUCTION_ORDER_ROW_ID, 
                                        EVL.SERIAL_NO, 
                                        O.ORDER_ID, 
                                        ORR.ORDER_ROW_ID, 
                                        O.ORDER_NUMBER, 
                                        ISNULL(PP.SHELF_TYPE,0) AS SHELF_TYPE
                                    FROM     
                                        ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                                        EZGI_WM_ORDER_LAST_STATUS AS ES ON ORR.ORDER_ROW_ID = ES.ORDER_ROW_ID INNER JOIN
                                        ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
                                        EZGI_WM_IS_SERIAL_NO_LIVE AS EVL INNER JOIN
                                        EZGI_WM_SERIAL_NO_LAST_STATUS AS EWM ON EVL.SERIAL_NO = EWM.SERIAL_NO ON ES.SERIAL_NO = EWM.SERIAL_NO LEFT OUTER JOIN
                                        PRODUCT_PLACE AS PP WITH (NOLOCK) ON EWM.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID
                                    WHERE  
                                        EWM.STOCK_ID = #get_serial.STOCK_ID# AND 
                                        ORR.ORDER_ROW_ID IN (#order_row_id_list#) AND 
                                        ISNULL(PP.SHELF_TYPE, 0) <> 5 AND
                                        (
                                            CASE 
                                                WHEN
                                                    (SELECT ISNULL(IS_PROTOTYPE, 0) AS IS_PROTOTYPE FROM STOCKS WHERE STOCK_ID = EWM.STOCK_ID) = 1 
                                                THEN 
                                                    EWM.SPECT_ID 
                                                ELSE 
                                                    0 
                                            END = 0
                                        )
                                </cfquery>
                                <cfif get_order_row_serial_no.recordcount> <!---Sevkiyatın Bu ürünü için rezerve edilmiş seri nolar mevcut---> 
                                
                                    <!---okutulan Seri No Rezerve edilen Sevkiyata Trasfer Edilmemiş Seri Nolar İçinde Var mı? --->
                                    <cfquery name="get_order_row_serial_no_1" dbtype="query">
                                        SELECT * FROM get_order_row_serial_no WHERE SERIAL_NO = '#attributes.serial_no#'
                                    </cfquery>
                                    <cfif not get_order_row_serial_no_1.recordcount><!--- Seri No Listesi İçinde Yoksa--->
                                        <cfset hata = 7>
                                        <script type="text/javascript">
                                            document.getElementById("warning").play();
                                            alert("<cfoutput>#get_serial.PRODUCT_NAME#</cfoutput> Ürünü İçin Öncelikle Rezerve Edilmiş Seri Noları Okutun!");
                                        </script>
                                    <cfelse><!--- Seri No Listesi İçinde Varsa--->
                                        <cfquery name="get_order_row_serial_no_2" dbtype="query"><!--- Seri No WM Depo Dışında mı? değilse (SHELF_TYPE 1,2,3,4) dir. Yani Transfer edilmeye Hazır--->
                                            SELECT * FROM get_order_row_serial_no WHERE SHELF_TYPE = 0 AND SERIAL_NO = '#attributes.serial_no#'
                                        </cfquery>
                                        <cfif get_order_row_serial_no_2.recordcount><!--- Seri No Listesi WM Depo Dışında ise--->
                                            <cfset hata = 8>
                                            <script type="text/javascript">
                                                document.getElementById("warning").play();
                                                alert("<cfoutput>#attributes.serial_no#</cfoutput> Seri No lu Ürünü Sevkiyata Transfer Edebilmek İçin Öncelikle WM Depo İçersine Almalısınız!");
                                            </script>
                                        <cfelse>
                                            <cfquery name="GET_SHIP_PACKAGE_LIST_GROUP" dbtype="query"> <!---Seri Noya Ait Ürünün Toplam Transfer Sayısını Buluyorum--->
                                                SELECT     
                                                    PAKETSAYISI,
                                                    PRODUCT_NAME, 
                                                    STOCK_ID, 
                                                    SPECT_MAIN_ID
                                                FROM
                                                    GET_SHIP_PACKAGE_LIST
                                                WHERE
                                                    SPECT_MAIN_ID = #get_serial.SPECT_MAIN_ID# AND
                                                    STOCK_ID = #get_serial.STOCK_ID#
                                            </cfquery> 
                                            <cfif not GET_SHIP_PACKAGE_LIST_GROUP.recordcount>
                                                <cfset hata = 5>
                                                <script type="text/javascript">
                                                    document.getElementById("warning").play();
                                                    alert("<cfoutput>#get_serial.PRODUCT_NAME#</cfoutput> Ürünü <cfoutput>#attributes.ship_number#</cfoutput> Belge Nolu Sevk Belgesinde Yoktur!");
                                                </script>
                                            <cfelse>
                                                <cfset buldum = 0>
                                                <cfloop query="GET_SHIP_PACKAGE_LIST_GROUP">
                                                    <cfif Evaluate('control_amount_#GET_SHIP_PACKAGE_LIST_GROUP.STOCK_ID#_#GET_SHIP_PACKAGE_LIST_GROUP.SPECT_MAIN_ID#') lt GET_SHIP_PACKAGE_LIST_GROUP.PAKETSAYISI>
                                                        <cfset buldum = 1>
                                                        <cfbreak>
                                                    </cfif>
                                                </cfloop>
                                                <cfif buldum eq 0> <!---Ürün Bu Sevk Belgesinde olduğu halde Tamamı Sevkiyata Alanına Gönderilmiştir--->
                                                    <cfset hata = 6>
                                                    <script type="text/javascript">
                                                        document.getElementById("warning").play();
                                                        alert("<cfoutput>#get_serial.PRODUCT_NAME#</cfoutput> Ürünü İçin Fazla Sevkiyat Yapılamaz!");
                                                    </script>
                                                <cfelse>
                                                	<cfset attributes.add_serial = 1>
                                                	<cfinclude template="../query/add_ezgi_pallets_to_shipment_warehouse.cfm">
                                                </cfif>
                                            </cfif>
                                        </cfif>
                                    </cfif>
                                <cfelse><!---Sevkiyatın Bu ürünü için rezerve edilmiş seri nolar Yok veya Transfer edilecek Kalmamış---> 
                                    <cfquery name="GET_SHIP_PACKAGE_LIST_GROUP" dbtype="query"> <!---Seri Noya Ait Ürünün Toplam Transfer Sayısını Buluyorum--->
                                        SELECT     
                                            PAKETSAYISI,
                                            PRODUCT_NAME, 
                                            STOCK_ID, 
                                            SPECT_MAIN_ID
                                        FROM
                                            GET_SHIP_PACKAGE_LIST
                                        WHERE
                                            SPECT_MAIN_ID = #get_serial.SPECT_MAIN_ID# AND
                                            STOCK_ID = #get_serial.STOCK_ID#
                                    </cfquery> 
                                    <cfif not GET_SHIP_PACKAGE_LIST_GROUP.recordcount>
                                        <cfset hata = 5>
                                        <script type="text/javascript">
                                            document.getElementById("warning").play();
                                            alert("<cfoutput>#get_serial.PRODUCT_NAME#</cfoutput> Ürünü <cfoutput>#attributes.ship_number#</cfoutput> Belhge Nolu Sevk Belgesinde Yoktur!");
                                        </script>
                                    <cfelse>
                                        <cfset buldum = 0>
                                        <cfloop query="GET_SHIP_PACKAGE_LIST_GROUP">
                                            <cfif not isdefined('control_amount_#GET_SHIP_PACKAGE_LIST_GROUP.STOCK_ID#_#GET_SHIP_PACKAGE_LIST_GROUP.SPECT_MAIN_ID#') or Evaluate('control_amount_#GET_SHIP_PACKAGE_LIST_GROUP.STOCK_ID#_#GET_SHIP_PACKAGE_LIST_GROUP.SPECT_MAIN_ID#') lt GET_SHIP_PACKAGE_LIST_GROUP.PAKETSAYISI>
                                                <cfset buldum = 1>
                                                <cfbreak>
                                            </cfif>
                                        </cfloop>
                                        <cfif buldum eq 0> <!---Ürün Bu Sevk Belgesinde olduğu halde Tamamı Sevkiyata Alanına Gönderilmiştir--->
                                            <cfset hata = 6>
                                            <script type="text/javascript">
                                                document.getElementById("warning").play();
                                                alert("<cfoutput>#get_serial.PRODUCT_NAME#</cfoutput> Ürünü İçin Fazla Sevkiyat Yapılamaz!");
                                            </script>
                                        <cfelse>
                                           <cfset attributes.add_serial = 1>
                                           	<script type="text/javascript">
                                               document.getElementById('total_control').value = (document.getElementById('total_control').value*1) + 1;
                                            </script>
                                      		<cfinclude template="../query/add_ezgi_pallets_to_shipment_warehouse.cfm">
                                        </cfif>
                                    </cfif>
                                </cfif>
                            </cfif>
                        </cfif>
                    </cfif>
                </cfif>
            </cfif>
        </cfif>
    <cfelse>
    	<cfset attributes.list_serino = 1>
        <cfinclude template="../query/add_ezgi_pallets_to_shipment_warehouse.cfm">
    </cfif>
<cfelseif attributes.type eq 3><!---Raf Belirleme--->
	<cfset attributes.upd_shelf = 1>
    <cfinclude template="../query/add_ezgi_pallets_to_shipment_warehouse.cfm">
</cfif>
<script language="javascript" type="text/javascript">
	document.getElementById('total_control_amount').value = document.getElementById('total_control').value;
	document.getElementById('total_paket_sayisi').value = document.getElementById('total_package').value;
 	
	function FindAjax(crtrow,stockid,spectmainid)
	{
        openBoxDraggable('<cfoutput>#request.self#?fuseaction=stock.dsp_ezgi_serialno_warehouse&ship_id=#attributes.ship_id#&ship_type=#attributes.is_type#</cfoutput>&crtrow='+crtrow+'&stock_id='+stockid+'&spect_main_id='+spectmainid,'large');
	}
	function connectAjax(crtrow,stockid,spectmainid)
	{
        
	}
</script>