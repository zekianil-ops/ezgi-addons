<!---
    File: ajax_ezgi_pallets_order_shelf_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2025
    Description: Siparişe Ürün Bağlama Ajax
--->
<audio id="warning" src="AddOns/ezgi/sounds/warning.mp3" preload="auto"></audio>
<audio id="confirm" src="AddOns/ezgi/sounds/confirm.mp3" preload="auto"></audio>


<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
	<cfif attributes.type eq 3>
		SELECT
    		SUM(PAKET_SAYISI) AS PAKETSAYISI,
    		STOCK_ID, 
    		BARCOD, 
    		STOCK_CODE, 
    		PRODUCT_NAME, 
    		SPECT_MAIN_ID,
        	ORDER_ROW_ID
      	FROM
    		(     
    		SELECT 
    		    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
    		    S1.STOCK_ID, 
    		    S1.BARCOD, 
    		    S1.STOCK_CODE, 
    		    S1.PRODUCT_NAME, 
    		    ORR.ORDER_ROW_ID,
    		    ISNULL(SP.SPECT_MAIN_ID,0) AS SPECT_MAIN_ID
    		FROM          
    		  	STOCKS AS S1 WITH (NOLOCK) INNER JOIN
        	 	ORDER_ROW AS ORR WITH (NOLOCK) ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
        		SPECTS AS SP WITH (NOLOCK) ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
        		EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID INNER JOIN
        		STOCKS AS S WITH (NOLOCK) ON EPS.PAKET_ID = S.STOCK_ID 
    		WHERE      
    		    ORR.ORDER_ID = #attributes.order_id# AND
    		    ISNULL(S1.IS_PROTOTYPE,0) = 1 AND
    		    ISNULL(S.IS_SERIAL_NO,0) = 1 
    		GROUP BY 
    		    EPS.MODUL_SPECT_ID, 
    		    S1.STOCK_ID, 
    		    S1.BARCOD, 
    		    S1.STOCK_CODE, 
    		    S1.PRODUCT_NAME, 
    		    ORR.ORDER_ROW_ID,
    		    SP.SPECT_MAIN_ID
    		UNION ALL
    		SELECT 
    		    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
    		    S1.STOCK_ID, 
    		    S1.BARCOD, 
    		    S1.STOCK_CODE, 
    		    S1.PRODUCT_NAME, 
    		    ORR.ORDER_ROW_ID,
    		    0 AS SPECT_MAIN_ID
    		FROM
    		    ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
    		    EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
    		    STOCKS AS S WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID INNER JOIN
    		    STOCKS AS S1 WITH (NOLOCK) ON S1.STOCK_ID = ORR.STOCK_ID
    		WHERE      
    		    ORR.ORDER_ID = #attributes.order_id# AND
    		    ISNULL(S1.IS_PROTOTYPE,0) = 0 AND
    		    ISNULL(S.IS_SERIAL_NO,0) = 1 
    		GROUP BY
    		    S1.STOCK_ID, 
    		    S1.BARCOD, 
    		    S1.STOCK_CODE, 
    		    S1.PRODUCT_NAME, 
				ORR.ORDER_ROW_ID,
    		    ORR.SPECT_VAR_ID
     		) AS TBL
     	GROUP BY
    		STOCK_ID, 
    		BARCOD, 
    		STOCK_CODE, 
    		PRODUCT_NAME, 
    		SPECT_MAIN_ID,
        	ORDER_ROW_ID
  		ORDER BY
     		ORDER_ROW_ID
	<cfelse>         
 		SELECT     
        	PAKET_SAYISI AS PAKETSAYISI, 
        	PAKET_ID AS STOCK_ID, 
        	BARCOD, 
        	STOCK_CODE, 
        	PRODUCT_NAME,
        	SPECT_MAIN_ID,
        	ORDER_ROW_ID
     	FROM         
        	(
        	SELECT
        	    SUM(PAKET_SAYISI) AS PAKET_SAYISI,
        	    ORDER_ROW_ID,
        	    PAKET_ID, 
        	    BARCOD, 
        	    STOCK_CODE, 
        	    PRODUCT_NAME, 
        	    SPECT_MAIN_ID
        	FROM
        	    (     
        	    SELECT 
        	        SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
        	        EPS.PAKET_ID, 
        	        S.BARCOD, 
        	        S.STOCK_CODE, 
        	        S.PRODUCT_NAME, 
        	        ORR.ORDER_ROW_ID,
        	        ISNULL(SP.SPECT_MAIN_ID,0) AS SPECT_MAIN_ID
        	    FROM          
        	        STOCKS AS S1 WITH (NOLOCK) INNER JOIN
        	        ORDER_ROW AS ORR WITH (NOLOCK) ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
        	        SPECTS AS SP WITH (NOLOCK) ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
        	        EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID INNER JOIN
        	        STOCKS AS S WITH (NOLOCK) ON EPS.PAKET_ID = S.STOCK_ID 
        	    WHERE      
        	        ORR.ORDER_ID = #attributes.order_id# AND
        	        ISNULL(S1.IS_PROTOTYPE,0) = 1 AND
               		ISNULL(S.IS_SERIAL_NO,0) = 1 
        	    GROUP BY 
        	        EPS.PAKET_ID,
        	        EPS.MODUL_SPECT_ID, 
        	        S.BARCOD, 
        	        S.STOCK_CODE, 
        	        S.PRODUCT_NAME, 
        	        ORR.ORDER_ROW_ID,
        	        SP.SPECT_MAIN_ID
        	    UNION ALL
        	    SELECT 
        	        SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
        	        EPS.PAKET_ID, 
        	        S.BARCOD, 
        	        S.STOCK_CODE, 
        	        S.PRODUCT_NAME, 
        	        ORR.ORDER_ROW_ID,
        	        0 AS SPECT_MAIN_ID
        	    FROM
        	        ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
        	        EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
        	        STOCKS AS S WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID INNER JOIN
        	        STOCKS AS S1 WITH (NOLOCK) ON S1.STOCK_ID = ORR.STOCK_ID
        	    WHERE      
        	        ORR.ORDER_ID = #attributes.order_id# AND
        	        ISNULL(S1.IS_PROTOTYPE,0) = 0 AND
                	ISNULL(S.IS_SERIAL_NO,0) = 1 
        	    GROUP BY
        	        EPS.PAKET_ID, 
        	        S.BARCOD, 
        	        S.STOCK_CODE, 
        	        S.PRODUCT_NAME, 
        	        ORR.ORDER_ROW_ID,
        	        ORR.SPECT_VAR_ID
        	    ) AS TBL1
        	GROUP BY
        	    ORDER_ROW_ID,
        	    PAKET_ID, 
        	    BARCOD, 
        	    STOCK_CODE, 
        	    PRODUCT_NAME, 
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
            '' AS LOT_NO,
            ES.SERIAL_NO, 
            O.ORDER_ID,
            O.ORDER_NUMBER,
            ORR.ORDER_ROW_ID, 
            EWM.STOCK_ID, 
            EWM.PRODUCT_NAME, 
            ISNULL(PP.SHELF_TYPE,0) AS SHELF_TYPE,
            ISNULL(ES.PRODUCTION_ORDER_ROW_ID,0) AS PRODUCTION_ORDER_ROW_ID,
            CASE
            	WHEN
           			(SELECT ISNULL(IS_PROTOTYPE,0) AS IS_PROTOTYPE FROM STOCKS WHERE STOCK_ID = EWM.STOCK_ID) = 1
              	THEN
                 	EWM.SPECT_ID
             	ELSE
                	0
         	END AS SPECT_MAIN_ID
        FROM     
            EZGI_WM_ORDER_LAST_STATUS AS ES INNER JOIN
            EZGI_WM_IS_SERIAL_NO_LIVE AS EVL ON ES.SERIAL_NO = EVL.SERIAL_NO INNER JOIN
            ORDER_ROW AS ORR ON ES.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
            ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
            EZGI_WM_SERIAL_NO_LAST_STATUS AS EWM ON ES.SERIAL_NO = EWM.SERIAL_NO LEFT OUTER JOIN
        	PRODUCT_PLACE AS PP WITH (NOLOCK) ON EWM.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID
        WHERE  
        	O.ORDER_ID = #attributes.order_id#
   		UNION ALL
        SELECT
        	3 AS VIRTUAL_ROW_ID, 
            PO.LOT_NO,
            E.SERIAL_NO,
        	O.ORDER_ID, 
            O.ORDER_NUMBER, 
            ORR.ORDER_ROW_ID, 
            S.STOCK_ID, 
            S.PRODUCT_NAME, 
            0 AS SHELF_TYPE, 
            E.PRODUCTION_ORDER_ROW_ID, 
            CASE 
            	WHEN ISNULL(S.IS_PROTOTYPE, 0) = 1 
                THEN PO.SPEC_MAIN_ID 
                ELSE 0 
          	END AS SPECT_MAIN_ID
		FROM     
        	PRODUCTION_ORDERS_ROW AS E INNER JOIN
            PRODUCTION_ORDERS AS PO ON E.PRODUCTION_ORDER_ID = PO.P_ORDER_ID INNER JOIN
            STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID INNER JOIN
            ORDER_ROW AS ORR ON E.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
            ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID
		WHERE  
            PO.STATUS = 1 AND 
            PO.IS_STAGE <> 2 AND 
            E.SERIAL_NO IS NULL AND 
            O.ORDER_ID = #attributes.order_id#
  		ORDER BY
        	VIRTUAL_ROW_ID,
            SERIAL_NO
</cfquery>
<cfquery name="get_total_control" dbtype="query">
  	SELECT COUNT(*) AS CONTROL_AMOUNT FROM get_detail_package_list
</cfquery>
<cfquery name="get_total_package" dbtype="query">
 	SELECT sum(PAKETSAYISI) PAKETSAYISI FROM GET_SHIP_PACKAGE_LIST
</cfquery>
<cfif not len(get_total_control.CONTROL_AMOUNT)>
	<cfset get_total_control.CONTROL_AMOUNT = 0 >
</cfif>

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

	<cf_box>
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
                	<cfquery name="GET_SHIP_PACKAGE_LIST" dbtype="query">
                    	SELECT
                        	PRODUCT_NAME,
                            SPECT_MAIN_ID,
                            STOCK_ID,
                            SUM(PAKETSAYISI) AS PAKETSAYISI
                        FROM
                            GET_SHIP_PACKAGE_LIST
                        GROUP BY
                        	PRODUCT_NAME,
                            SPECT_MAIN_ID,
                            STOCK_ID
                    </cfquery>
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
                        	SELECT PRODUCT_NAME,SERIAL_NO FROM get_detail_package_list WHERE STOCK_ID = #STOCK_ID# AND SPECT_MAIN_ID = #SPECT_MAIN_ID# ORDER BY SERIAL_NO DESC, PRODUCT_NAME
                        </cfquery>
   		                <tr id="order_row#currentrow#" style="display:none">
   		                    <td colspan="7">
   		                       	<table cellpadding="0" cellspacing="0" border="1" style="width:100%">
                               		<tr style="height:10px; background-color:silver">
                                    	<td style="text-align:right; width:30px"><cf_get_lang dictionary_id='58577.Sıra'></td>
                                        <td style="text-align:center; width:20px"></td>
                                        <td style="text-align:center;"><cf_get_lang dictionary_id='58221.Ürün Adı'></td>
                                        <td style="text-align:center;"><cf_get_lang dictionary_id='57637.Seri No'></td>
                                    </tr>
                                    <cfif row_detail.recordcount>
                                    	<cfloop query="row_detail">
                                            <tr style="height:10px; background-color:white">
                                                <td style="text-align:right;">#row_detail.currentrow#</td>
                                                <td style="text-align:center; width:20px">
                                                    <a onclick="sil('#SERIAL_NO#');"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
                                                </td>
                                                <td style="text-align:center;">#row_detail.PRODUCT_NAME#</td>
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
        	ORDER_ROW_ID,
            SPECT_MAIN_ID,
            STOCK_ID,
            COUNT(*) AS CONTROL_AMOUNT
        FROM
            get_detail_package_list
        GROUP BY
        	ORDER_ROW_ID,
            SPECT_MAIN_ID,
            STOCK_ID	 	
    </cfquery>
    <cfoutput query="get_detail_package_group">
        <cfset 'control_amount_#ORDER_ROW_ID#_#STOCK_ID#_#SPECT_MAIN_ID#' = CONTROL_AMOUNT>
    </cfoutput>
    <cfset hata = 0>
    <cfif isdefined('attributes.serial_no') and len(attributes.serial_no)>
    	<cfif isdefined('attributes.sil') and attributes.sil eq 1>
        	<cfquery name="get_serial_list" dbtype="query">
                SELECT * FROM get_detail_package_list WHERE SERIAL_NO = '#attributes.serial_no#'
            </cfquery>
            <cfif not get_serial_list.recordcount>
                <script type="text/javascript">
                    document.getElementById("warning").play();
                    alert("<cfoutput>#attributes.serial_no#</cfoutput> Seri No Daha Önce Bu Siparişten Çıkartılmış!");
                </script>
            <cfelse>
            	<!---Seri Noyu ORDER_ROW_ID ye Rezerveden Çıkarıyorum--->
            	<cfquery name="ADD_ROW" datasource="#DSN3#">
                  	INSERT INTO 
                   		EZGI_WM_SERIAL_NO_ORDER_ACTION
                      	(
                         	SERIAL_NO, 
                          	ORDER_ROW_ID,
                          	RECORD_DATE, 
                          	RECORD_IP,
                          	RECORD_EMP
                    	)
                  	VALUES 
                     	(
                        	'#attributes.serial_no#',
                           	0,
                         	#now()#,
                        	'#CGI.REMOTE_ADDR#',
                          	#session.ep.userid#
                     	)
      			</cfquery>
				<cfquery name="get_detail_package_list" dbtype="query">
                    SELECT * FROM get_detail_package_list WHERE SERIAL_NO <> '#attributes.serial_no#'
                </cfquery>
             	<script type="text/javascript">
                 	document.getElementById("confirm").play();
					alert("<cfoutput>#attributes.serial_no#</cfoutput> Seri Nolu Ürün Rezervasyondan Çıkartılmıştır!");
              	</script>
            </cfif>
        <cfelse>
            <cfquery name="get_order_info" datasource="#DSN3#">
                SELECT ORDER_NUMBER FROM ORDERS WHERE ORDER_ID = #attributes.order_id#
            </cfquery>
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
                        ISNULL(ES.PRODUCTION_ORDER_ROW_ID,0) AS PRODUCTION_ORDER_ROW_ID, 
                        EVL.SERIAL_NO,
                        O.ORDER_ID, 
                        O.ORDER_NUMBER,
                        ISNULL(PP.SHELF_TYPE,0) AS SHELF_TYPE
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
                <cfif not get_serial.recordcount><!---Bu Sei No Yaşıyor mu?--->
                    <script type="text/javascript">
                        document.getElementById("warning").play();
                        alert("<cfoutput>#attributes.serial_no#</cfoutput> Seri No Bulunamdı!");
                    </script>
                    <cfset hata = 2>
                <cfelse> 
                    <cfif get_serial.ORDER_ID gt 0><!---Başka Sipariş İçin Önceden Okutulmuş mu--->
                        <cfset hata = 3>
                        <script type="text/javascript">
                            document.getElementById("warning").play();
                            alert("<cfoutput>#attributes.serial_no#</cfoutput> Seri No Başka Sipariş İçin Rezerve Edilmiş!");
                        </script>
                    <cfelse>
                    	<cfif get_serial.SHELF_TYPE eq 5><!---BBaşka Bir Seviyat Belgesi İçin Sevkiyat Alanına Çıkartılmış mı--->
                        	<cfset hata = 4>
							<script type="text/javascript">
                                document.getElementById("warning").play();
                                alert("<cfoutput>#attributes.serial_no#</cfoutput> Seri No Başka Sevk Belgesi İçin Yükleme Alanına Alınmış!");
                            </script>
                        <cfelse>
                            <cfquery name="GET_SHIP_PACKAGE_LIST_GROUP" dbtype="query"> <!---Rezerve Edilecek Ürün Sipariş Satırlarına göre Sıralanıyor--->
                                SELECT     
                                    PAKETSAYISI,
                                    PRODUCT_NAME, 
                                    STOCK_ID, 
                                    SPECT_MAIN_ID,
                                    ORDER_ROW_ID
                                FROM
                                    GET_SHIP_PACKAGE_LIST
                                WHERE
                                    SPECT_MAIN_ID = #get_serial.SPECT_MAIN_ID# AND
                                    STOCK_ID = #get_serial.STOCK_ID#
                                ORDER BY
                                    ORDER_ROW_ID
                            </cfquery>
                            <cfif not GET_SHIP_PACKAGE_LIST_GROUP.recordcount>
                                <cfset hata = 5>
                                <script type="text/javascript">
                                    document.getElementById("warning").play();
                                    alert("<cfoutput>#get_serial.PRODUCT_NAME#</cfoutput> Ürünü <cfoutput>#get_order_info.ORDER_NUMBER#</cfoutput> Siparişinde Yoktur!");
                                </script>
                            <cfelse>
                                <cfset select_order_row_id = 0>
                                <cfloop query="GET_SHIP_PACKAGE_LIST_GROUP">
                                    <cfif not isdefined('control_amount_#GET_SHIP_PACKAGE_LIST_GROUP.ORDER_ROW_ID#_#GET_SHIP_PACKAGE_LIST_GROUP.STOCK_ID#_#GET_SHIP_PACKAGE_LIST_GROUP.SPECT_MAIN_ID#') OR (isdefined('control_amount_#GET_SHIP_PACKAGE_LIST_GROUP.ORDER_ROW_ID#_#GET_SHIP_PACKAGE_LIST_GROUP.STOCK_ID#_#GET_SHIP_PACKAGE_LIST_GROUP.SPECT_MAIN_ID#') and Evaluate('control_amount_#ORDER_ROW_ID#_#STOCK_ID#_#SPECT_MAIN_ID#') lt GET_SHIP_PACKAGE_LIST_GROUP.PAKETSAYISI)>
                                        <cfset select_order_row_id = GET_SHIP_PACKAGE_LIST_GROUP.ORDER_ROW_ID>
                                        <cfbreak>
                                    </cfif>
                                </cfloop>
                                <cfif select_order_row_id eq 0> <!---Ürün Bu siparişte olduğu halde Tüm satırlardaki rezerve ayırma olayı dolmuştur--->
                                    <cfset hata = 6>
                                    <script type="text/javascript">
                                        document.getElementById("warning").play();
                                        alert("<cfoutput>#get_serial.PRODUCT_NAME#</cfoutput> Ürünü <cfoutput>#get_order_info.ORDER_NUMBER#</cfoutput> Siparişinde İçin Fazla Rezerve Yapılamaz!");
                                    </script>
                                <cfelse>
                                    <!---Aşağıda Listeye İlk Sırada Göstermek ve Yeniden Sorgu çalıştırmamak için query table a ekleme yapıyorum.--->
                                    <cfset temp = QueryAddRow(get_detail_package_list)>
                                    <cfset Temp = QuerySetCell(get_detail_package_list, "VIRTUAL_ROW_ID", '1')> 
                                    <cfset Temp = QuerySetCell(get_detail_package_list, "ORDER_ID", attributes.order_id)>
                                    <cfset Temp = QuerySetCell(get_detail_package_list, "ORDER_NUMBER", get_order_info.ORDER_NUMBER)>
                                    <cfset Temp = QuerySetCell(get_detail_package_list, "ORDER_ROW_ID", select_order_row_id)>
                                    <cfset Temp = QuerySetCell(get_detail_package_list, "SERIAL_NO", attributes.serial_no)>
                                    <cfset Temp = QuerySetCell(get_detail_package_list, "STOCK_ID", get_serial.STOCK_ID)>
                                    <cfset Temp = QuerySetCell(get_detail_package_list, "PRODUCT_NAME", get_serial.PRODUCT_NAME)>
                                    <cfset Temp = QuerySetCell(get_detail_package_list, "SPECT_MAIN_ID", get_serial.SPECT_MAIN_ID)>
                                    <!---Listeye İlk Sırada Göstermek ve Yeniden Sıralama Yapıyorum--->
                                    <cfquery name="get_detail_package_list" dbtype="query">
                                        SELECT * FROM get_detail_package_list ORDER BY VIRTUAL_ROW_ID,SERIAL_NO
                                    </cfquery>
                                    <!---Seri Noyu ORDER_ROW_ID ye Rezerve ediyorum--->
                                    <cfquery name="ADD_ROW" datasource="#DSN3#">
                                        INSERT INTO 
                                            EZGI_WM_SERIAL_NO_ORDER_ACTION
                                            (
                                                SERIAL_NO, 
                                                ORDER_ROW_ID,
                                                RECORD_DATE, 
                                                RECORD_IP,
                                                RECORD_EMP
                                            )
                                        VALUES 
                                            (
                                                '#attributes.serial_no#',
                                                #select_order_row_id#,
                                                #now()#,
                                                '#CGI.REMOTE_ADDR#',
                                                #session.ep.userid#
                                            )
                                    </cfquery>
                                    <script type="text/javascript">
                                        document.getElementById("confirm").play();
                                    </script>
                                </cfif>
                            </cfif>
                        </cfif>
                    </cfif>
                </cfif>
            </cfif>
        </cfif>
    </cfif>
 	<cf_box>
   		<cf_grid_list>
   		    <thead>
   		        <tr>
   		            <th style="width:20px; text-align:right"><cf_get_lang dictionary_id='58577.Sıra'></th>
   		            <th style="width:20px"></th>
   		            <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
   		            <th style="text-align:center"><cf_get_lang dictionary_id='57637.Seri No'></th>
   		        </tr>
   		    </thead>
   		    <tbody>
   		        <cfif get_detail_package_list.recordcount>
   		            <cfoutput query="get_detail_package_list" startrow="1" maxrows="#session.ep.maxrows#">
   		                <tr id="serirow#currentrow#" height="20">
   		                    <td style="text-align:right">#currentrow#</td>
   		                    <!-- sil -->
   		                    <td>
                            	<cfif VIRTUAL_ROW_ID eq 2>
                            		<a onclick="sil('#SERIAL_NO#');"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
                                </cfif>
                            </td>
   		                    <!-- sil -->
   		                    <td>#product_name#<cfif SPECT_MAIN_ID gt 0><font color="red"> - #SPECT_MAIN_ID#</font></cfif></td> 
   		                    <td style="text-align:right" title="<cfif VIRTUAL_ROW_ID eq 3>Lot No<cfelse>Serial No</cfif>"><cfif VIRTUAL_ROW_ID eq 3><font color="red">#LOT_NO#</font><cfelse>#SERIAL_NO#</cfif></td>
   		                </tr>
   		            </cfoutput>
   		        <cfelse>
                	<tr height="20"><td colspan="4">Kayıt Yok</td></tr>
                </cfif>
   		    </tbody>
   		</cf_grid_list>
	</cf_box> 
<cfelseif attributes.type eq 3><!---Sipariş--->
    <cfquery name="get_detail_package_group" dbtype="query">
        SELECT
        	ORDER_ROW_ID,
            COUNT(*) AS CONTROL_AMOUNT
        FROM
            get_detail_package_list
        GROUP BY
        	ORDER_ROW_ID	 	
    </cfquery>
    <cfoutput query="get_detail_package_group">
        <cfset 'control_amount#ORDER_ROW_ID#' = CONTROL_AMOUNT>
    </cfoutput>
    <cf_box>
   		<cf_grid_list>
   		    <thead>
   		        <tr>
   		            <th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
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
   		                    <!-- sil -->
   		                    <td>#product_name#<cfif SPECT_MAIN_ID gt 0><font color="red"> - #SPECT_MAIN_ID#</font></cfif></td> 
   		                    <td style="text-align:right">#PAKETSAYISI#</td>
   		                    <td style="text-align:right"><cfif isdefined('control_amount#ORDER_ROW_ID#')>#Evaluate('control_amount#ORDER_ROW_ID#')#<cfelse>0</cfif></td>
   		                    <td align="center" valign="middle">      
   		                        <cfif isdefined('control_amount#ORDER_ROW_ID#') and len(Evaluate('control_amount#ORDER_ROW_ID#')) and Evaluate('control_amount#ORDER_ROW_ID#') eq PAKETSAYISI>
   		                            <img id="is_durum#currentrow#" src="images\c_ok.gif">
   		                        <cfelseif isdefined('control_amount#ORDER_ROW_ID#') and len(Evaluate('control_amount#ORDER_ROW_ID#')) and Evaluate('control_amount#ORDER_ROW_ID#') neq PAKETSAYISI>
   		                            <img id="is_durum#currentrow#" src="images\warning.gif">
                              	<cfelseif not isdefined('control_amount#ORDER_ROW_ID#')>
   		                            <img id="is_durum#currentrow#" src="/images/caution_small.gif">
   		                        </cfif>
   		                    </td>
   		                </tr>
   		                <!-- sil -->
                        <cfquery name="row_detail" dbtype="query">
                        	SELECT PRODUCT_NAME,SERIAL_NO FROM get_detail_package_list WHERE ORDER_ROW_ID = #ORDER_ROW_ID# ORDER BY SERIAL_NO DESC,PRODUCT_NAME
                        </cfquery>
   		                <tr id="order_row#currentrow#" style="display:none">
   		                    <td colspan="6">
   		                       	<table cellpadding="0" cellspacing="0" border="1" style="width:100%">
                               		<tr style="height:10px; background-color:silver">
                                    	<td style="text-align:right; width:30px"><cf_get_lang dictionary_id='58577.Sıra'></td>
                                        <td style="text-align:center;"><cf_get_lang dictionary_id='58221.Ürün Adı'></td>
                                        <td style="text-align:center;"><cf_get_lang dictionary_id='57637.Seri No'></td>
                                    </tr>
                                    <cfif row_detail.recordcount>
                                    	<cfloop query="row_detail">
                                            <tr style="height:10px; background-color:white">
                                                <td style="text-align:right;">#row_detail.currentrow#</td>
                                                <td style="text-align:center;">#row_detail.PRODUCT_NAME#</td>
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
    
</cfif>
<script language="javascript" type="text/javascript">
	<cfoutput>
		document.getElementById('total_control_amount').value = #get_total_control.CONTROL_AMOUNT#;
		document.getElementById('total_paket_sayisi').value = #get_total_package.PAKETSAYISI#;
	</cfoutput>
 	function connectAjax(crtrow,stockid,spectmainid)
	{
        
	}
	function FindAjax(crtrow,stockid,spectmainid)
	{
        openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=stock.dsp_ezgi_serialno_warehouse&crtrow='+crtrow+'&stock_id='+stockid+'&spect_main_id='+spectmainid,'large');
	}
</script>