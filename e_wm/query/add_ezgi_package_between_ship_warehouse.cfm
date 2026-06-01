<!---
    File: stock.add_ezgi_package_between_ship_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\query
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Depolararası Sevk İrsaliyesi
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
      		<cfif attributes.dep_out neq attributes.dep_in> <!---Eğer Depo farklılığı varsa--->
            	<cfinclude template="add_ezgi_pallets_ship_dispatch_fis.cfm"> <!---Stok Hareketi Yapılsın--->
            </cfif>
        </cfif>
    </cftransaction>
</cflock>
<cflocation url="#request.self#?fuseaction=stock.add_ezgi_package_between_ship_warehouse" addtoken="no">
