<!---
    File: add_ezgi_package_between_store_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\query
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Depolararası Ambar Fişi - Fire Fişi
---> 
<!---<cfdump var="#attributes#"><cfabort>--->
<cfset attributes.action_id = ''>
<cfset sira_no = 1>
<cflock name="#CreateUUID()#" timeout="60">
	<cftransaction>
    	<cfif ListLen(attributes.row_info_id)>
        	<cfset row_action_id = ''>
        	<cfloop list="#attributes.row_info_id#" index="kj">
            	<cfset attributes.ezg_row_id = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')# & #session.ep.company_id# & #ListGetAt(kj,2,'-')#>
            	<cfquery name="get_serial" datasource="#dsn2#">
                	SELECT * FROM #dsn3_alias#.EZGI_WM_SERIAL_NO_LAST_STATUS WHERE SERIAL_NO = '#ListGetAt(kj,2,'-')#'                       
             	</cfquery>
                <cfif attributes.default_process_type eq 113> <!---Ambar Fişi İse--->
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
                                RECORD_EMP, 
                                RECORD_IP
                            )
                        VALUES
                            (
                                #now()#,       
                                '#get_serial.SERIAL_NO#', 
                                #get_serial.STOCK_ID#,
                                #ListGetAt(attributes.dep_in,1,'-')#,
                                #ListGetAt(attributes.dep_in,2,'-')#, 
                                #get_serial.DEPARTMENT_ID#, 
                                #get_serial.LOCATION_ID#,
                                #session.ep.userid#,
                                '#cgi.remote_addr#'
                            )      
                    </cfquery>
				<cfelseif attributes.default_process_type eq 112><!---Fire Fişi İse--->

                </cfif>
            	<cfif sira_no eq 1>
                  	<cfset row_action_id = '#sira_no#'>
             	<cfelse>
                 	<cfset row_action_id = '#row_action_id#,#sira_no#'>
              	</cfif>
                <cfif isdefined('attributes.packing_in') and  len(attributes.packing_in)>
                	<cfset row_action_id = '#row_action_id#-#attributes.packing_in#'>
                <cfelse>
                	<cfset row_action_id = '#row_action_id#-0'>
                </cfif>
               	<cfset row_action_id = '#row_action_id#-#get_serial.STOCK_ID#'>
              	<cfif len(get_serial.SPECT_ID)>
                 	<cfset row_action_id = '#row_action_id#-#get_serial.SPECT_ID#'>
              	<cfelse>
                	<cfset row_action_id = '#row_action_id#-0'>
              	</cfif>
               	<cfset row_action_id = '#row_action_id#-#get_serial.SERIAL_NO#'>
               	<cfif isdefined('attributes.shelf_in') and len(attributes.shelf_in)>
                 	<cfset row_action_id = '#row_action_id#-#attributes.shelf_in#'>
              	<cfelse>
                  	<cfset row_action_id = '#row_action_id#-'>
              	</cfif>
              	<cfif len(get_serial.PRODUCT_PLACE_ID)>
                	<cfset row_action_id = '#row_action_id#-#get_serial.PRODUCT_PLACE_ID#'>
               	<cfelse>
                 	<cfset row_action_id = '#row_action_id#-'>
               	</cfif>
               	<cfset row_action_id = '#row_action_id#-0'>
                        
             	<cfset sira_no = sira_no+1>
         	</cfloop>
         	<cfset attributes.action_id = '#attributes.action_id##row_action_id#'>
      		<cfif (attributes.default_process_type eq 113 and attributes.dep_out neq attributes.dep_in) or attributes.default_process_type eq 112> <!---Eğer Ambar Fişi ve Depo farklılığı varsa veya Fire Fişi ise--->
            	<cfinclude template="add_ezgi_pallets_stock_fis.cfm"> <!---Stok Hareketi Yapılsın--->
            </cfif>
            <cfif attributes.default_process_type eq 112><!---Fire Fişi İse--->
            	<cfquery name="get_ship" datasource="#dsn2#">
                	SELECT FIS_ID, FIS_TYPE, FIS_NUMBER, LOCATION_OUT, DEPARTMENT_OUT FROM STOCK_FIS WHERE FIS_ID = #GET_ID.MAX_ID#
                </cfquery>
                <cfquery name="get_serial_no" datasource="#dsn2#">
                	SELECT 
                    	SFR.STOCK_ID, 
                        SFR.AMOUNT, 
                        SFR.UNIT, 
                        SFR.UNIT_ID, 
                        SFR.WRK_ROW_ID, 
                        SP.SPECT_MAIN_ID AS SPECT_ID, 
                        SFR.PRODUCT_NAME2 AS SERIAL_NO
					FROM     
                    	STOCK_FIS_ROW AS SFR LEFT OUTER JOIN
                  		#dsn3_alias#.SPECTS AS SP ON SFR.SPECT_VAR_ID = SP.SPECT_VAR_ID
					WHERE  
                    	SFR.FIS_ID = #GET_ID.MAX_ID#
                   	ORDER BY 
                    	SFR.STOCK_FIS_ROW_ID
                </cfquery>
                <cfloop query="get_serial_no">
                	<cfquery name="add_serial_no" datasource="#dsn2#">
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
                                #get_serial_no.STOCK_ID#,
                                '#get_serial_no.SERIAL_NO#',
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                                #get_ship.FIS_TYPE#,
                                #get_ship.FIS_ID#,
                                '#get_ship.FIS_NUMBER#',
                                #session.ep.period_id#,
                                #get_ship.DEPARTMENT_OUT#,
                                #get_ship.LOCATION_OUT#,
                                1,
                                #now()#,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                0,
                                <cfif len(get_serial_no.SPECT_ID)>#get_serial_no.SPECT_ID#<cfelse>NULL</cfif>,
                                0,
                                #now()#,
                                #session.ep.userid#,
                                '#cgi.remote_addr#',
                                1,
                                1
                            )
                    </cfquery>
                    <cfquery name="upda_palette" datasource="#dsn2#"> <!---Eğer Seri No Palet İçindeyse Oradanda kaldırılıyor--->
                    	DELETE FROM 
                        	#dsn3_alias#.EZGI_PACKING_ROW
						WHERE  
                        	SERIAL_NO = '#get_serial_no.SERIAL_NO#'
                    </cfquery>
                    <cfif isdefined('attributes.convert') and attributes.convert eq 1><!--- Sayım İşlemlerinden Fire Fişi oluşturuyorsa--->
                    	<cfquery name="upd_count_result" datasource="#dsn2#">
                        	UPDATE 
                            	#dsn3_alias#.EZGI_WM_COUNT_SERIAL_ROW
							SET          
                            	IS_LOST_ITEM =1
							WHERE  
                            	SERIAL_NO = '#get_serial_no.SERIAL_NO#' AND 
                                WM_COUNT_ID = #attributes.count_id# AND 
                                ISNULL(IS_CONTROL, 0) = 0
                        </cfquery>
                    </cfif>
                </cfloop>
            </cfif>
        </cfif>
    </cftransaction>
</cflock>
<cfif isdefined('attributes.convert') and attributes.convert eq 1><!--- Sayım İşlemlerinden Fire Fişi oluşturuyorsa--->
	<script type="text/javascript">
		alert('Fire Fişi Başarıyla Kaydedilmiştir.')
        window.close();
	</script>
    <cfabort>
<cfelseif isdefined('attributes.fast_count') and attributes.fast_count eq 1><!--- Hızlı Sayım İşleminden  Fire Fişi oluşturuyorsa Eylem Yok--->

<cfelse>
	<cflocation url="#request.self#?fuseaction=stock.add_ezgi_create_loss_receipt_warehouse" addtoken="no">
</cfif>
