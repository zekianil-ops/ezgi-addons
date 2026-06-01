<cfset attributes.action_id = ''>
<cfset sira_no = 1>
<cflock name="#CreateUUID()#" timeout="60">
	<cftransaction>
    	<cfif ListLen(attributes.row_info_id)>
        	<cfloop list="#attributes.row_info_id#" index="kj">
             	<cfset attributes.ezg_row_id = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')# & #session.ep.company_id# & #ListGetAt(kj,2,'-')#>
                <cfquery name="upd" datasource="#dsn2#"> <!---Palet Table Update Ediliyor--->
                    UPDATE      
                        #dsn3_alias#.EZGI_PACKING
                    SET  
                        STATUS = 1,
                        PRODUCT_PLACE_ID = <cfif isdefined('attributes.shelf_in') and len(attributes.shelf_in)>#attributes.shelf_in#<cfelse>NULL</cfif>,
                        DEPARTMENT_ID = <cfif isdefined('attributes.dep_in') and len(attributes.dep_in)>#ListGetAt(attributes.dep_in,1,'-')#<cfelse>NULL</cfif>,
                        LOCATION_ID = <cfif isdefined('attributes.dep_in') and len(attributes.dep_in)>#ListGetAt(attributes.dep_in,2,'-')#<cfelse>NULL</cfif>,
                        UPDATE_EMP = #session.ep.userid#,
                        UPDATE_IP = '#cgi.remote_addr#',
                        UPDATE_DATE = #now()#
                    WHERE        
                        PACKING_ID = #ListGetAt(kj,2,'-')#
                </cfquery>
       
                <cfquery name="add_packing_action" datasource="#dsn2#">
                    INSERT INTO        
                        #dsn3_alias#.EZGI_PACKING_ACTION
                        (
                            PACKING_ID, 
                            EZGI_PACKING_ACTION_TYPE_ID,
                            STORE, 
                            STORE_LOCATION, 
                            SHELF_NUMBER,
                            OUT_STORE, 
                            OUT_STORE_LOCATION,
                            OUT_SHELF_NUMBER,
                            EZGI_ID, 
                            PROCESS_DATE, 
                            RECORD_IP, 
                            RECORD_EMP
                        )
                    VALUES 
                        (
                            #ListGetAt(kj,2,'-')#,
                            #attributes.packing_action_type_id#,
                            #ListGetAt(attributes.dep_in,1,'-')#,
                            #ListGetAt(attributes.dep_in,2,'-')#,
                            <cfif isdefined('attributes.shelf_in') and len(attributes.shelf_in)>#attributes.shelf_in#<cfelse>NULL</cfif>,
                            #ListGetAt(attributes.dep_out,1,'-')#,
                            #ListGetAt(attributes.dep_out,2,'-')#,
                            <cfif isdefined('attributes.shelf_out') and len(attributes.shelf_out)>#attributes.shelf_out#<cfelse>NULL</cfif>,
                            '#attributes.ezg_row_id#',
                            #now()#,
                            '#cgi.remote_addr#',
                            #session.ep.userid#
                        )
                </cfquery>

                <cfquery name="get_packing_row" datasource="#dsn2#"> <!---Tüm Palet Satırları Yeniden İlave Ediliyor--->
               		SELECT 
                    	PACKING_ID, 
               		  	AMOUNT, 
               		  	STOCK_ID, 
               		  	SERIAL_NO,
               		  	SPECT_MAIN_ID
                  	FROM
               		    #dsn3_alias#.EZGI_PACKING_ROW
                  	WHERE
                    	PACKING_ID = #ListGetAt(kj,2,'-')#
                </cfquery>
                <cfset row_action_id = ''>
                <cfif get_packing_row.recordcount>
                	<cfloop query="get_packing_row">
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
                                    RECORD_EMP, 
                                    RECORD_IP
                                )
                            VALUES 
                                (
                                    #now()#,
                                    <cfif len(get_packing_row.SERIAL_NO)>'#get_packing_row.SERIAL_NO#'<cfelse>NULL</cfif>,
                                    <cfif len(get_packing_row.STOCK_ID)>'#get_packing_row.STOCK_ID#'<cfelse>NULL</cfif>,
                                    #ListGetAt(attributes.dep_in,1,'-')#,
                                    #ListGetAt(attributes.dep_in,2,'-')#,
                                    #ListGetAt(attributes.dep_out,1,'-')#,
                                    #ListGetAt(attributes.dep_out,2,'-')#,
                                    <cfif isdefined('attributes.shelf_in') and len(attributes.shelf_in)>#attributes.shelf_in#<cfelse>NULL</cfif>,
                                    <cfif isdefined('attributes.shelf_out') and len(attributes.shelf_out)>#attributes.shelf_out#<cfelse>NULL</cfif>,
                                    #ListGetAt(kj,2,'-')#,
                                    #session.ep.userid#,
                                    '#cgi.remote_addr#'
                                )
                        </cfquery>

                        <cfif sira_no eq 1>
                        	<cfset row_action_id = '#sira_no#'>
                        <cfelse>
                        	<cfset row_action_id = '#row_action_id#,#sira_no#'>
                        </cfif>
                        <cfset row_action_id = '#row_action_id#-#ListGetAt(kj,2,'-')#'>
                        <cfset row_action_id = '#row_action_id#-#get_packing_row.STOCK_ID#'>
                        <cfif len(get_packing_row.SPECT_MAIN_ID)>
                        	<cfset row_action_id = '#row_action_id#-#get_packing_row.SPECT_MAIN_ID#'>
                        <cfelse>
                        	<cfset row_action_id = '#row_action_id#-0'>
                        </cfif>
                        <cfset row_action_id = '#row_action_id#-#get_packing_row.SERIAL_NO#'>
                        <cfif isdefined('attributes.shelf_in') and len(attributes.shelf_in)>
                        	<cfset row_action_id = '#row_action_id#-#attributes.shelf_in#'>
                        <cfelse>
                        	<cfset row_action_id = '#row_action_id#-'>
                        </cfif>
                        <cfif isdefined('attributes.shelf_out') and len(attributes.shelf_out)>
                        	<cfset row_action_id = '#row_action_id#-#attributes.shelf_out#'>
                        <cfelse>
                        	<cfset row_action_id = '#row_action_id#-'>
                        </cfif>
                        <cfset row_action_id = '#row_action_id#-0'>
                        
                        <cfset sira_no = sira_no+1>
                  	</cfloop>
                    <cfset attributes.action_id = '#attributes.action_id##row_action_id#'>
              	</cfif>
            </cfloop>
      		<cfif attributes.dep_out neq attributes.dep_in> <!---Eğer Depo farklılığı varsa--->
            	<cfinclude template="add_ezgi_pallets_stock_fis.cfm"> <!---Stok Hareketi Yapılsın--->
            </cfif>
        </cfif>
    </cftransaction>
</cflock>
<cflocation url="#request.self#?fuseaction=stock.list_ezgi_pallets_to_storage_shelf_warehouse&is_submitted=1" addtoken="no">
