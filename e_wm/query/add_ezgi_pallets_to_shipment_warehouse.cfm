<!---
    File: add_ezgi_pallets_to_shipment_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\query
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Sevkiyata Ürün Hazırlama Query
--->
<cfif isdefined('attributes.upd_shelf')><!---Sevkiyat Alınında Kapı Belirleme Kaydı--->
    <cflock timeout="90">
        <cftransaction>
			<cfif attributes.is_type eq 1><!---Sevk Planı--->
                <cfquery name="get_control" datasource="#dsn3#">
                    SELECT ISNULL(SHIPMENT_PRODUCT_PLACE_ID, 0) AS SHIPMENT_PRODUCT_PLACE_ID FROM EZGI_SHIP_RESULT WITH (NOLOCK) WHERE SHIP_RESULT_ID = #attributes.ship_id#
                </cfquery>
                <cfif get_control.SHIPMENT_PRODUCT_PLACE_ID neq 0>
                    <script type="text/javascript">
                        alert("Kısa Zaman İçinde Raf Ataması Yapılmış!");
                        window.opener.location.reload()
                    </script>
                    <cfabort>
                <cfelse>
                    <cfquery name="upd_ship" datasource="#dsn3#">
                        UPDATE 
                            EZGI_SHIP_RESULT
                        SET          
                            SHIPMENT_PRODUCT_PLACE_ID = #attributes.out_shelf_id#,
                            SHIPMENT_PACKAGE_AMOUNT = #get_total_package.PAKETSAYISI#
                        WHERE  
                            SHIP_RESULT_ID = #attributes.ship_id#
                    </cfquery>
                </cfif>
            <cfelse><!---Sevk Talebi--->
            	<cfquery name="get_control" datasource="#dsn3#">
                    SELECT ISNULL(SHIPMENT_PRODUCT_PLACE_ID, 0) AS SHIPMENT_PRODUCT_PLACE_ID FROM EZGI_SHIP_RESULT_INTERNALDEMAND WITH (NOLOCK) WHERE SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
                </cfquery>
                <cfif get_control.SHIPMENT_PRODUCT_PLACE_ID neq 0>
                    <script type="text/javascript">
                        alert("Kısa Zaman İçinde Raf Ataması Yapılmış!");
                        window.opener.location.reload()
                    </script>
                    <cfabort>
                <cfelse>
                    <cfquery name="upd_ship" datasource="#dsn3#">
                        UPDATE 
                            EZGI_SHIP_RESULT_INTERNALDEMAND
                        SET          
                            SHIPMENT_PRODUCT_PLACE_ID = #attributes.out_shelf_id#,
                            SHIPMENT_PACKAGE_AMOUNT = #get_total_package.PAKETSAYISI#
                        WHERE  
                            SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
                    </cfquery>
                </cfif>
            </cfif>
        </cftransaction>
    </cflock>
    <script type="text/javascript">
		window.location.reload()
	</script>
<cfelseif isdefined('attributes.add_serial') and attributes.add_serial gt 0><!--- Sevkiyat Alanına Transfer İçin Kayıt Yapılıyor--->
	<!---Aşağıda Listeye İlk Sırada Göstermek ve Yeniden Sorgu çalıştırmamak için query table a ekleme yapıyorum.--->
	<cfset temp = QueryAddRow(get_detail_package_list)>
	<cfset Temp = QuerySetCell(get_detail_package_list, "VIRTUAL_ROW_ID", '1')> 
 	<cfset Temp = QuerySetCell(get_detail_package_list, "SERIAL_NO", attributes.serial_no)>
 	<cfset Temp = QuerySetCell(get_detail_package_list, "STOCK_ID", get_serial.STOCK_ID)>
 	<cfset Temp = QuerySetCell(get_detail_package_list, "PRODUCT_NAME", get_serial.PRODUCT_NAME)>
 	<cfset Temp = QuerySetCell(get_detail_package_list, "SPECT_MAIN_ID", get_serial.SPECT_MAIN_ID)>
 	<cfset Temp = QuerySetCell(get_detail_package_list, "OUT_SHELF_CODE", get_serial.SHELF_CODE)>
 	<!---Listeye İlk Sırada Göstermek ve Yeniden Sıralama Yapıyorum--->
 	<cfquery name="get_detail_package_list" dbtype="query">
 	    SELECT * FROM get_detail_package_list ORDER BY VIRTUAL_ROW_ID,SERIAL_NO
 	</cfquery>
 	<cfquery name="add_row" datasource="#dsn3#"> <!---Seri No Hareket Tablosuna Kayıt Atılıyor--->
 	    INSERT INTO 
 	        EZGI_WM_SERIAL_NO_ACTION
 	        (
 	            PROCESS_DATE, 
 	            SERIAL_NO,
 	            STOCK_ID, 
 	            DEPARTMENT_ID, 
 	            LOCATION_ID, 
 	            OUT_DEPARTMENT_ID, 
 	            OUT_LOCATION_ID, 
 	            PRODUCT_PLACE_ID,
 	            OUT_PRODUCT_PLACE_ID,
 	            PACKING_ID, 
 	            SHIP_RESULT_ID,
 	            SHIP_RESULT_TYPE,
 	            RECORD_EMP, 
 	            RECORD_IP
 	        )
 	    VALUES 
 	        (
 	            #now()#,
 	            '#get_serial.SERIAL_NO#',
 	            #get_serial.STOCK_ID#,
 	            #ListGetAt(attributes.to_department_loctaion_id,1,'-')#,
 	            #ListGetAt(attributes.to_department_loctaion_id,2,'-')#,
 	            #ListGetAt(attributes.to_department_loctaion_id,1,'-')#,
 	            #ListGetAt(attributes.to_department_loctaion_id,2,'-')#,
 	            <cfif isdefined('attributes.to_shelf_id') and len(attributes.to_shelf_id)>#attributes.to_shelf_id#<cfelse>NULL</cfif>,
 	            #get_serial.PRODUCT_PLACE_ID#,
 	            NULL,
 	            #attributes.ship_id#,
 	            #attributes.is_type#,
 	            #session.ep.userid#,
 	            '#cgi.remote_addr#'
 	        )
 	</cfquery>
 	<cfquery name="del_packing_row" datasource="#dsn3#"><!---Eğer Bir Palette İse Palet Kaydı Silinsin--->
 	    DELETE FROM 
 	        EZGI_PACKING_ROW
 	    WHERE  
 	        SERIAL_NO = '#attributes.SERIAL_NO#'
 	</cfquery>
 	<script type="text/javascript">
 	    document.getElementById("confirm").play();
 	</script>
<cfelseif isdefined('attributes.del_serial') and attributes.del_serial gt 0><!--- Sevkiyat Alanına Transfer Yapılan Ürün Geri Alınıyor--->
	<cfquery name="del_row" datasource="#dsn3#"> <!---Seri No Hareket Tablosundan Kayıt Siliniyor--->
    	DELETE FROM
    		EZGI_WM_SERIAL_NO_ACTION
      	WHERE
        	SHIP_RESULT_ID = #attributes.ship_id# AND
          	SHIP_RESULT_TYPE = #attributes.is_type# AND
          	SERIAL_NO = '#attributes.SERIAL_NO#'
    </cfquery>
    <cfquery name="get_detail_package_list" dbtype="query">
    	SELECT * FROM get_detail_package_list WHERE SERIAL_NO <> '#attributes.serial_no#'
	</cfquery>
</cfif>
<cfif (isdefined('attributes.del_serial') and attributes.del_serial gt 0) or (isdefined('attributes.add_serial') and attributes.add_serial gt 0) or (isdefined('attributes.list_serino') and attributes.list_serino eq 1)>
	<cfsavecontent variable="title"><cfif attributes.is_type eq 1><b><cf_get_lang dictionary_id='382.Sevk Plan No'> :</b><cfelse><b><cf_get_lang dictionary_id='375.Sevk Talep No'> :</b></cfif><cfoutput>#attributes.ship_number#</cfoutput></cfsavecontent>
	<cf_box title="#title#">
   		<cf_grid_list>
			<thead>
			    <tr>
			        <th style="width:20px"></th>
			        <th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
			        <th><cf_get_lang dictionary_id='57637.Seri No'></th>
			        <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
			        <th><cf_get_lang dictionary_id='37540.Raf Kodu'></th>
			    </tr>
			</thead>
			<tbody name="table2" id="table2">
			    <cfif get_detail_package_list.recordcount>
			        <cfoutput query="get_detail_package_list">
			            <tr id="row#currentrow#" height="20">
			                <td style="text-align:center">
			                    <a onclick="sil('#SERIAL_NO#');"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
			                </td>
			                <td style="text-align:right">#currentrow#</td>
			                <td style="text-align:center">#SERIAL_NO#</td>
			                <td style="text-align:left">#PRODUCT_NAME#</td>
			                <td style="text-align:center">#OUT_SHELF_CODE#</td>
			            </tr>
			        </cfoutput>
			    </cfif>
			</tbody>
    	</cf_grid_list>
	</cf_box> 
</cfif>
