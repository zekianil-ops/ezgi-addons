<!---
    File: ajax_ezgi_purchase_receipt_seri_control_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Mal Alım İrsaliyesi Seri No Kontrol - ajax
--->
<cfquery name="GET_SHIP_INFO" datasource="#dsn2#">
	SELECT SHIP_ID, SHIP_NUMBER, COMPANY_ID, PARTNER_ID, CONSUMER_ID, EMPLOYEE_ID, SHIP_DATE, IS_DELIVERED, DEPARTMENT_IN, LOCATION_IN FROM SHIP WHERE SHIP_ID = #attributes.ship_id#
</cfquery>
<cfif not (len(GET_SHIP_INFO.DEPARTMENT_IN) or len(GET_SHIP_INFO.LOCATION_IN))>
	<script type="text/javascript">
    	alert("İrsaliyenin Depo Bilgisi Boş Bırakılamaz!");
      	window.history.go(-1);
	</script>
	<cfabort>
</cfif>
<cfsavecontent variable="title"><b><cf_get_lang dictionary_id='57880.Belge No'> :</b><cfoutput>#GET_SHIP_INFO.SHIP_NUMBER#</cfoutput></cfsavecontent>
<cfif attributes.type eq 0>
	
	<cfif isdefined('attributes.barcode') and len(attributes.barcode)><!---Eğer Barkod Kaydı Gelmişse--->
    	<cfquery name="get_new_ship_seri_no" datasource="#dsn3#">
            SELECT 
                SG.SERIAL_NO, 
                SG.STOCK_ID, 
                ISNULL(SG.SPECT_ID,0) AS SPECT_MAIN_ID,
                S.PRODUCT_NAME
            FROM 
                SERVICE_GUARANTY_NEW AS SG WITH (NOLOCK) INNER JOIN
                STOCKS AS S ON S.STOCK_ID = SG.STOCK_ID
            WHERE  
                SG.PROCESS_ID = #attributes.ship_id# AND 
                SG.PROCESS_CAT = 76 AND 
                SG.PERIOD_ID = #session.ep.period_id# AND 
                SG.IN_OUT = 1  
        </cfquery> 
    	<cfquery name="get_again_control_serial_no" dbtype="query">
        	SELECT * FROM get_new_ship_seri_no WHERE SERIAL_NO = '#attributes.barcode#'
        </cfquery>
        <cfif not get_again_control_serial_no.recordcount> <!---Daha Önce Okutulmuş mu--->
        	<cfquery name="get_old_ship_seri_no" datasource="#new_dsn3#">
                SELECT 
                    SG.SERIAL_NO, 
                    SG.STOCK_ID, 
                    ISNULL(SG.SPECT_ID,0) AS SPECT_MAIN_ID,
                    S.PRODUCT_NAME
                FROM 
                    SERVICE_GUARANTY_NEW AS SG WITH (NOLOCK) INNER JOIN
                    STOCKS AS S ON S.STOCK_ID = SG.STOCK_ID
                WHERE  
                    SG.PROCESS_ID = #attributes.old_ship_id# AND 
                    SG.PROCESS_CAT = 71 AND 
                    SG.PERIOD_ID = #attributes.period_id# AND 
                    SG.IN_OUT = 0 AND
                    SG.SERIAL_NO = '#attributes.barcode#'
            </cfquery>
            <cfif get_old_ship_seri_no.recordcount><!---Gelen Barkodlar İçinde Mevcut mu--->
            	<cfquery name="add_serial_no" datasource="#dsn3#">
            		INSERT INTO        
                            #dsn3_alias#.SERVICE_GUARANTY_NEW
                            (
                                STOCK_ID, 
                                SERIAL_NO, 
                                IN_OUT, 
                                IS_PURCHASE, 
                                IS_SALE, 
                                IS_RETURN, 
                                IS_RMA, 
                                IS_SERVICE, 
                                PROCESS_CAT, 
                                PROCESS_ID, 
                                PROCESS_NO, 
                                PERIOD_ID, 
                                DEPARTMENT_ID, 
                                LOCATION_ID, 
                                SALE_GUARANTY_CATID, 
                                SALE_START_DATE, 
                                SALE_COMPANY_ID, 
                                SALE_PARTNER_ID, 
                                SALE_CONSUMER_ID, 
                                SALE_EMPLOYEE_ID, 
                                IS_SARF, 
                                SPECT_ID, 
                                IS_SERI_SONU, 
                                RECORD_DATE, 
                                RECORD_EMP, 
                                RECORD_IP, 
                                UNIT_TYPE, 
                                UNIT_ROW_QUANTITY
                            )
                        VALUES 
                            (
                                #get_old_ship_seri_no.STOCK_ID#,
                                '#attributes.barcode#',
                                1,
                                1,
                                0,
                                0,
                                0,
                                0,
                               	76,
                                #GET_SHIP_INFO.SHIP_ID#,
                                '#GET_SHIP_INFO.SHIP_NUMBER#',
                                #session.ep.period_id#,
                                #GET_SHIP_INFO.DEPARTMENT_IN#,
                                #GET_SHIP_INFO.LOCATION_IN#,
                                NULL,
                                NULL,
                                <cfif len(GET_SHIP_INFO.COMPANY_ID)>
                                	#GET_SHIP_INFO.COMPANY_ID#,
                                    #GET_SHIP_INFO.PARTNER_ID#,
                                <cfelse>
                                	NULL,
                                	NULL,
                                </cfif>
                                <cfif len(GET_SHIP_INFO.CONSUMER_ID)>
                                	#GET_SHIP_INFO.CONSUMER_ID#,
                                <cfelse>
                                	NULL,
                                </cfif>
                                <cfif len(GET_SHIP_INFO.EMPLOYEE_ID)>
                                	#GET_SHIP_INFO.EMPLOYEE_ID#,
                                <cfelse>
                                	NULL,
                              	</cfif>
                                0,
                                <cfif len(get_old_ship_seri_no.SPECT_MAIN_ID) and get_old_ship_seri_no.SPECT_MAIN_ID gt 0>#get_old_ship_seri_no.SPECT_MAIN_ID#<cfelse>NULL</cfif>,
                                0,
                                #now()#,
                                #session.ep.userid#,
                                '#cgi.remote_addr#',
                                0,
                                1
                            )
            	</cfquery>
            <cfelse>
            	<script type="text/javascript">
					alert("Gönderilen Seri No Listesi İçinde Bulunamdı!");
				</script>
            </cfif>
        <cfelse>
        	<script type="text/javascript">
				alert("Seri No Daha Önce Okutulmuş!");
			</script>
        </cfif>
    </cfif>
   
    
    <cfquery name="get_new_ship_seri_no" datasource="#dsn3#">
        SELECT 
        	CASE
            	WHEN ISNULL(S.IS_PROTOTYPE,0) = 1
                THEN ISNULL(SG.SPECT_ID,0)
          		ELSE
                	0
           	END AS SPECT_MAIN_ID,
            SG.SERIAL_NO, 
            SG.STOCK_ID, 
            S.PRODUCT_NAME
        FROM 
            SERVICE_GUARANTY_NEW AS SG WITH (NOLOCK) INNER JOIN
            STOCKS AS S ON S.STOCK_ID = SG.STOCK_ID
        WHERE  
            SG.PROCESS_ID = #attributes.ship_id# AND 
          	SG.PROCESS_CAT = 76 AND 
         	SG.PERIOD_ID = #session.ep.period_id# AND 
        	SG.IN_OUT = 1   
    </cfquery> 
    <cfquery name="get_total_control" dbtype="query">
        SELECT COUNT(*) AS CONTROL_AMOUNT FROM get_new_ship_seri_no
    </cfquery>
    <cfif get_total_control.recordcount>
        <cfset total_control_amount = get_total_control.CONTROL_AMOUNT>
   	<cfelse>
    	<cfset total_control_amount = 0>	
    </cfif>
	
    <cfquery name="get_new_ship_seri_no_group" dbtype="query">
    	SELECT
        	COUNT (*) AS CONTROL_AMOUNT,
        	STOCK_ID, 
       		SPECT_MAIN_ID
     	FROM
        	get_new_ship_seri_no
     	GROUP BY
        	STOCK_ID, 
       		SPECT_MAIN_ID
    </cfquery>
    
    <cfoutput query="get_new_ship_seri_no_group">
    	<cfset 'CONTROL_AMOUNT_#STOCK_ID#_#SPECT_MAIN_ID#' = CONTROL_AMOUNT>
    </cfoutput>
    
    <cfquery name="get_old_ship_seri_no" datasource="#new_dsn3#">
     	SELECT 
         	SG.SERIAL_NO, 
         	SG.STOCK_ID, 
         	ISNULL(SG.SPECT_ID,0) AS SPECT_MAIN_ID,
         	S.PRODUCT_NAME
      	FROM 
        	SERVICE_GUARANTY_NEW AS SG WITH (NOLOCK) INNER JOIN
          	STOCKS AS S ON S.STOCK_ID = SG.STOCK_ID
      	WHERE  
        	SG.PROCESS_ID = #attributes.old_ship_id# AND 
         	SG.PROCESS_CAT = 71 AND 
         	SG.PERIOD_ID = #attributes.period_id# AND 
         	SG.IN_OUT = 0
	</cfquery>
    
    <cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn2#">
        SELECT
            SPECT_MAIN_ID,
            PAKET_ID AS STOCK_ID, 
            BARCOD, 
            PRODUCT_CODE, 
            PRODUCT_NAME, 
            SUM(PAKET_SAYISI) AS PAKETSAYISI
        FROM
            (
            SELECT 
                SHR.STOCK_ID, 
                0 AS SPECT_MAIN_ID,
                EPS.PAKET_ID, 
                S1.BARCOD, 
                S1.PRODUCT_CODE, 
                S1.PRODUCT_NAME, 
                SUM(EPS.PAKET_SAYISI * SHR.AMOUNT) AS PAKET_SAYISI
            FROM     
                SHIP_ROW AS SHR WITH (NOLOCK)INNER JOIN
                #dsn3_alias#.STOCKS AS S WITH (NOLOCK) ON SHR.STOCK_ID = S.STOCK_ID INNER JOIN
                #dsn3_alias#.EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.MODUL_ID INNER JOIN
                #dsn3_alias#.STOCKS AS S1 WITH (NOLOCK) ON EPS.PAKET_ID = S1.STOCK_ID
            WHERE  
                SHR.SHIP_ID = #attributes.ship_id# AND
                ISNULL(S.IS_PROTOTYPE,0) = 0
            GROUP BY 
                SHR.STOCK_ID, 
                EPS.PAKET_ID, 
                S1.BARCOD, 
                S1.PRODUCT_CODE, 
                S1.PRODUCT_NAME
            UNION ALL
            SELECT 
                SHR.STOCK_ID,
                SM.SPECT_MAIN_ID, 
                EPS.PAKET_ID, 
                S1.BARCOD, 
                S1.PRODUCT_CODE, 
                S1.PRODUCT_NAME, 
                SUM(EPS.PAKET_SAYISI * SHR.AMOUNT) AS PAKET_SAYISI
            FROM     
                #dsn3_alias#.SPECTS AS SM WITH (NOLOCK) INNER JOIN
                SHIP_ROW AS SHR WITH (NOLOCK) INNER JOIN
                #dsn3_alias#.STOCKS AS S WITH (NOLOCK) ON SHR.STOCK_ID = S.STOCK_ID ON SM.SPECT_VAR_ID = SHR.SPECT_VAR_ID INNER JOIN
                #dsn3_alias#.STOCKS AS S1 WITH (NOLOCK) INNER JOIN
                #dsn3_alias#.EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S1.STOCK_ID = EPS.PAKET_ID ON SM.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID
            WHERE  
                SHR.SHIP_ID = #attributes.ship_id# AND 
                ISNULL(S.IS_PROTOTYPE,0) = 1
            GROUP BY 
                SHR.STOCK_ID, 
                SM.SPECT_MAIN_ID,
                EPS.PAKET_ID, 
                S1.BARCOD, 
                S1.PRODUCT_CODE, 
                S1.PRODUCT_NAME
            ) AS TBL
        GROUP BY
            SPECT_MAIN_ID,
            PAKET_ID, 
            BARCOD, 
            PRODUCT_CODE, 
            PRODUCT_NAME       
    </cfquery>
    <cfquery name="get_total_package" dbtype="query">
        SELECT SUM(PAKETSAYISI) AS PAKETSAYISI FROM GET_SHIP_PACKAGE_LIST
    </cfquery>
	<cf_box title="#title#">
     	<cf_grid_list>
          	<thead>
              	<tr>
                  	<th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                  	<th style="width:100%"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                 	<th style="width:25px; text-align:center"><cf_get_lang dictionary_id='57635.Miktar'></th>
                    <th style="width:25px; text-align:center">Kontrol</th>
              	</tr>
           	</thead>
          	<tbody>
           		<cfif GET_SHIP_PACKAGE_LIST.recordcount>
                 	<cfoutput query="GET_SHIP_PACKAGE_LIST">
                    	<tr height="20">
                         	<td style="text-align:right">#currentrow#</td>
                        	<td>#product_name#<cfif SPECT_MAIN_ID gt 0><font color="red"> - #SPECT_MAIN_ID#</font></cfif></td> 
                        	<td style="text-align:right">#PAKETSAYISI#</td>
                            <td style="text-align:right">
                            	<cfif isdefined('CONTROL_AMOUNT_#STOCK_ID#_#SPECT_MAIN_ID#')>
                                	<cfset control_amount = Evaluate('CONTROL_AMOUNT_#STOCK_ID#_#SPECT_MAIN_ID#')>
                                <cfelse>
                                	<cfset control_amount = 0>
                                </cfif>
                                #control_amount#
                            </td>
                     	</tr>
              		</cfoutput>
              	</cfif>
          	</tbody>
            <tfoot>
            	<tr style="font-weight:bold">
                	<td colspan="2">Toplam</td>
                   	<td style="text-align:right"><cfoutput>#get_total_package.PAKETSAYISI#</cfoutput></td>
              		<td style="text-align:right"><cfoutput>#total_control_amount#</cfoutput></td> 
                </tr>
            </tfoot>
     	</cf_grid_list>
	</cf_box>
<cfelseif attributes.type eq 1>
	<cfquery name="get_new_ship_seri_no" datasource="#dsn3#">
        SELECT 
            SG.SERIAL_NO, 
            SG.STOCK_ID, 
            ISNULL(SG.SPECT_ID,0) AS SPECT_MAIN_ID,
            S.PRODUCT_NAME
        FROM 
            SERVICE_GUARANTY_NEW AS SG WITH (NOLOCK) INNER JOIN
            STOCKS AS S ON S.STOCK_ID = SG.STOCK_ID
        WHERE  
            SG.PROCESS_ID = #attributes.ship_id# AND 
         	SG.PROCESS_CAT = 76 AND 
          	SG.PERIOD_ID = #session.ep.period_id# AND 
          	SG.IN_OUT = 1  
      	ORDER BY
        	SG.GUARANTY_ID desc
    </cfquery> 
	<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>
         	<thead>
             	<tr>
                 	<th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                	<th><cf_get_lang dictionary_id='57637.Seri No'></th>
                	<th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
            	</tr>
     		</thead>
     		<tbody>
     		    <cfif get_new_ship_seri_no.recordcount>
     		        <cfoutput query="get_new_ship_seri_no">
     		            <tr height="20">
     		                <td style="text-align:right">#currentrow#</td>
     		                <td style="text-align:left">#SERIAL_NO#</td>
     		                <td style="text-align:left">#PRODUCT_NAME#</td>     		            
                      	</tr>
     		        </cfoutput>
     		    </cfif>
     		</tbody>
    	</cf_grid_list>
 	</cf_box>
<cfelseif attributes.type eq 2>
	<cfquery name="get_new_ship_seri_no" datasource="#dsn3#">
        SELECT 
            SG.SERIAL_NO, 
            SG.STOCK_ID, 
            ISNULL(SG.SPECT_ID,0) AS SPECT_MAIN_ID,
            S.PRODUCT_NAME
        FROM 
            SERVICE_GUARANTY_NEW AS SG WITH (NOLOCK) INNER JOIN
            STOCKS AS S ON S.STOCK_ID = SG.STOCK_ID
        WHERE  
            SG.PROCESS_ID = #attributes.ship_id# AND 
          	SG.PROCESS_CAT = 76 AND 
          	SG.PERIOD_ID = #session.ep.period_id# AND 
         	SG.IN_OUT = 1   
    </cfquery> 
    <cfset serial_no_list = ValueList(get_new_ship_seri_no.SERIAL_NO)>
    
    <cfquery name="get_total_control" dbtype="query">
        SELECT COUNT(*) AS CONTROL_AMOUNT FROM get_new_ship_seri_no
    </cfquery>
    <cfif not len(get_total_control.CONTROL_AMOUNT) or not get_total_control.recordcount>
        <cfset get_total_control.CONTROL_AMOUNT = 0>
    </cfif>
    
	<cfquery name="get_old_ship_seri_no" datasource="#new_dsn3#">
        SELECT 
            SG.SERIAL_NO, 
            SG.STOCK_ID, 
            ISNULL(SG.SPECT_ID,0) AS SPECT_MAIN_ID,
            S.PRODUCT_NAME
        FROM 
            SERVICE_GUARANTY_NEW AS SG WITH (NOLOCK) INNER JOIN
            STOCKS AS S ON S.STOCK_ID = SG.STOCK_ID
        WHERE  
            SG.PROCESS_ID = #attributes.old_ship_id# AND 
            SG.PROCESS_CAT = 71 AND 
            SG.PERIOD_ID = #attributes.period_id# AND 
            SG.IN_OUT = 0
      	ORDER BY
        	S.PRODUCT_NAME,
            SG.SERIAL_NO
    </cfquery>
	<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>
         	<thead>
             	<tr>
                 	<th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                	<th><cf_get_lang dictionary_id='57637.Seri No'></th>
                	<th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
            	</tr>
     		</thead>
     		<tbody>
     		    <cfif get_old_ship_seri_no.recordcount>
     		        <cfoutput query="get_old_ship_seri_no">
                    	<cfif not ListFind(serial_no_list,SERIAL_NO)>
                            <tr height="20">
                                <td style="text-align:right">#currentrow#</td>
                                <td style="text-align:left">#SERIAL_NO#</td>
                                <td style="text-align:left">#PRODUCT_NAME#</td>     		            
                            </tr>
                        </cfif>
     		        </cfoutput>
     		    </cfif>
     		</tbody>
    	</cf_grid_list>
 	</cf_box>
</cfif>