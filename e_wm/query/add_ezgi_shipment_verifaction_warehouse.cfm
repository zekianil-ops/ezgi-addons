<!---
    File: add_ezgi_pallets_to_shipment_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\query
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Sevkiyat Doğrulama İşlemi ve Düzenleme 
--->
<cfif isdefined('attributes.add_serial')>
	<cfquery name="add_row" datasource="#dsn3#"> <!---Seri No Hareket Tablosuna Kayıt Atılıyor--->
       	UPDATE 
        	EZGI_WM_SERIAL_NO_ACTION
        SET
        	IS_SHIPMENT_VERIFACTION = 1
      	WHERE
        	SERIAL_NO = '#attributes.serial_no#' AND
            SHIP_RESULT_TYPE = #attributes.is_type# AND
            SHIP_RESULT_ID = #attributes.ship_id#	
 	</cfquery>
<cfelseif isdefined('attributes.del_serial')>
	<cfquery name="del_row" datasource="#dsn3#"> <!---Seri No Hareket Tablosundan Kayıt Siliniyor--->
    	UPDATE 
        	EZGI_WM_SERIAL_NO_ACTION
        SET
        	IS_SHIPMENT_VERIFACTION = 0
      	WHERE
        	SERIAL_NO = '#attributes.serial_no#' AND
            SHIP_RESULT_TYPE = #attributes.is_type# AND
            SHIP_RESULT_ID = #attributes.ship_id#	
    </cfquery>
    <script type="text/javascript">
		window.location.reload()
	</script>
<cfelseif isdefined('attributes.last_process')> <!---Fiş Kaydediliyor--->
	<cfquery name="get_row" datasource="#dsn3#">
    	SELECT * FROM EZGI_WM_SERIAL_NO_LAST_STATUS WHERE  IS_SHIPMENT_VERIFACTION = 1 AND SHIP_RESULT_TYPE = #attributes.is_type# AND SHIP_RESULT_ID = #attributes.ship_id#
    </cfquery>
	<cfif get_row.recordcount>
    	<cfif attributes.is_type eq 1>
        	<cfquery name="get_ship" datasource="#dsn2#">
            	SELECT DELIVER_PAPER_NO FROM #dsn3_alias#.EZGI_SHIP_RESULT WHERE SHIP_RESULT_ID = #attributes.ship_id#
        	</cfquery>
       	<cfelse>
         	<cfquery name="get_ship" datasource="#dsn2#">
                SELECT CAST(SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) AS DELIVER_PAPER_NO FROM #dsn3_alias#.EZGI_SHIP_RESULT_INTERNALDEMAND WHERE SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
       		</cfquery>
       	</cfif>
    	<cfset attributes.ezg_row_id = get_ship.DELIVER_PAPER_NO>
    	<cftransaction>
        	<cfset attributes.action_id =''>
            <cfloop query="get_row">
                <cfquery name="add_row" datasource="#dsn2#"> <!---Seri No Hareket Tablosuna Kayıt Atılıyor--->
                    INSERT INTO 
                        #dsn3_alias#.EZGI_WM_SERIAL_NO_ACTION
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
                            <cfif len(get_row.SERIAL_NO)>'#get_row.SERIAL_NO#'<cfelse>NULL</cfif>,
                            <cfif len(get_row.STOCK_ID)>#get_row.STOCK_ID#<cfelse>NULL</cfif>,
                            #ListGetAt(attributes.dep_in,1,'-')#,
                            #ListGetAt(attributes.dep_in,2,'-')#,
                            #ListGetAt(attributes.dep_out,1,'-')#,
                            #ListGetAt(attributes.dep_out,2,'-')#,
                            <cfif isdefined('attributes.to_shelf_id') and len(attributes.to_shelf_id)>#attributes.to_shelf_id#<cfelse>NULL</cfif>,
                            <cfif len(get_row.PRODUCT_PLACE_ID)>#get_row.PRODUCT_PLACE_ID#<cfelse>NULL</cfif>,
                            NULL,
                            #attributes.ship_id#,
                            #attributes.is_type#,
                            #session.ep.userid#,
                            '#cgi.remote_addr#'
                        )
                </cfquery>
                <cfif not len(get_row.SPECT_ID)>
                	<cfset get_row.SPECT_ID = 0>
                </cfif>
                <cfif not isdefined('attributes.action_id')>
                	<cfset attributes.action_id ='#get_row.currentrow#--#get_row.STOCK_ID#-#get_row.STOCK_ID#-#get_row.SPECT_ID#-#get_row.SERIAL_NO#--#get_row.PRODUCT_PLACE_ID#-0'>
               	<cfelse>
                	<cfset attributes.action_id ='#attributes.action_id##get_row.currentrow#--#get_row.STOCK_ID#-#get_row.STOCK_ID#-#get_row.SPECT_ID#-#get_row.SERIAL_NO#--#get_row.PRODUCT_PLACE_ID#-0'>
                </cfif>
                <cfif get_row.currentrow lt get_row.recordcount>
                	<cfset attributes.action_id ='#attributes.action_id#,'>
                </cfif>
            </cfloop>
            <cfquery name="Get_Control_List" datasource="#dsn2#">
            	SELECT 
                	STOCK_ID, 
                    SPECT_ID, 
                    IS_PROTOTYPE, 
                    COUNT(*) AS AMOUNT
				FROM     
                	#dsn3_alias#.EZGI_WM_SERIAL_NO_LAST_STATUS
				WHERE  
                	SHIP_RESULT_TYPE = #attributes.is_type# AND 
                    SHIP_RESULT_ID = #attributes.ship_id#
				GROUP BY 
                	STOCK_ID, 
                    SPECT_ID, 
                    IS_PROTOTYPE
            </cfquery>
            <cfif Get_Control_List.recordcount>
            	<cfloop query="Get_Control_List">
                    <cfquery name="add_e_shipping_control" datasource="#dsn2#">
                        INSERT INTO 
                            #dsn3_alias#.EZGI_SHIPPING_PACKAGE_LIST
                            (
                                SHIPPING_ID, 
                                STOCK_ID, 
                                SPECT_MAIN_ID, 
                                CONTROL_AMOUNT, 
                                AMOUNT,
                                CONTROL_STATUS, 
                                TYPE, 
                                RECORD_EMP, 
                                RECORD_DATE
                            )
                        VALUES 
                            (
                                #attributes.ship_id#,
                                #Get_Control_List.STOCK_ID#,
                                <cfif len(Get_Control_List.SPECT_ID)>#Get_Control_List.SPECT_ID#<cfelse>NULL</cfif>,
                                #Get_Control_List.AMOUNT#,
                                #Get_Control_List.AMOUNT#,
                                2,
                                #attributes.is_type#,
                                #session.ep.userid#,
                                #now()#
                            )
                    </cfquery>
            	</cfloop>
            </cfif>
            <cfif attributes.is_type eq 1>
                <cfquery name="upd_ship" datasource="#dsn2#">
                    UPDATE 
                        #dsn3_alias#.EZGI_SHIP_RESULT
                    SET          
                        SHIPMENT_PROCESS = 1
                    WHERE  
                        SHIP_RESULT_ID = #attributes.ship_id# AND
                        ISNULL(SHIPMENT_PROCESS,0) = 0 
                </cfquery>
            <cfelse>
                <cfquery name="upd_ship" datasource="#dsn2#">
                    UPDATE 
                        #dsn3_alias#.EZGI_SHIP_RESULT_INTERNALDEMAND
                    SET          
                        SHIPMENT_PROCESS = 1
                    WHERE  
                        SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
                        ISNULL(SHIPMENT_PROCESS,0) = 0 
                </cfquery>
            </cfif>
            <cfif attributes.dep_out neq attributes.dep_in> <!---Eğer Depo farklılığı varsa--->
            	<cfinclude template="add_ezgi_pallets_stock_fis.cfm"> <!---Stok Hareketi Yapılsın--->
            </cfif>
        </cftransaction>
	<cfelse>
    	<script type="text/javascript">
        	alert("Başkası Tarafından Transfer Kaydı Yapılmış!");
			window.history.go(-1);
         	window.location.reload();
     	</script>
     	<cfabort>
    </cfif>
    <cflocation url="#request.self#?fuseaction=stock.list_ezgi_shipment_verifaction_warehouse" addtoken="No">
</cfif>