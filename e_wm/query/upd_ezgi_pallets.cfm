<!---
    File: upd_ezgi_pallets.cfm
    Folder: Add_Ons\ezgi\e_wm\query
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Palet Oluştur
--->
<!---<cfdump var="#attributes#"><cfabort>--->
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfif isdefined('attributes.sil')>
	<cftransaction>
        <cfquery name="del_fis" datasource="#dsn2#">
            DELETE FROM #dsn3_alias#.EZGI_PACKING WHERE PACKING_ID = #attributes.packing_id#
        </cfquery>
        <cfquery name="del_row" datasource="#dsn2#">
            DELETE FROM #dsn3_alias#.EZGI_PACKING_ROW WHERE PACKING_ID = #attributes.packing_id#
        </cfquery>
    </cftransaction>
    <cflocation url="#request.self#?fuseaction=stock.list_ezgi_pallets" addtoken="no">
<cfelseif isdefined('attributes.process_action_type')>
	<cftransaction>
        <cfquery name="upd" datasource="#dsn2#"> <!---Palet Onaylanıyor--->
            UPDATE      
                #dsn3_alias#.EZGI_PACKING
            SET 
            	<cfif isdefined('attributes.is_status') and attributes.is_status eq 1>
                    STATUS = 1,
                <cfelse>
                    STATUS = 0,
                </cfif>
                PROCESS_STATUS = #attributes.process_action_type#,
                UPDATE_EMP = #session.ep.userid#,
             	UPDATE_IP = '#cgi.remote_addr#',
                UPDATE_DATE = #now()#
            WHERE        
                PACKING_ID = #attributes.packing_id#
        </cfquery>
    </cftransaction>
    <cflocation url="#request.self#?fuseaction=stock.list_ezgi_pallets&event=upd&packing_id=#attributes.packing_id#" addtoken="no">
<cfelse>
    <cfset attributes.ezg_row_id = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')# & #session.ep.company_id# & #attributes.packing_id#>
    <cflock name="#CreateUUID()#" timeout="60">
	<cftransaction>
        <cfquery name="upd" datasource="#dsn2#"> <!---Palet Table Update Ediliyor--->
            UPDATE      
                #dsn3_alias#.EZGI_PACKING
            SET  
            	<cfif isdefined('attributes.is_status') and attributes.is_status eq 1>
                    STATUS = 1,
                <cfelse>
                    STATUS = 0,
                </cfif>
                PROCESS_STATUS = #attributes.packing_closed_type#,
                PACKING_SIZE_TYPE_ID = <cfif isdefined('attributes.collect_type_id') and len(attributes.collect_type_id)>#attributes.collect_type_id#<cfelseif isdefined('attributes.collect_type_id_2') and len(attributes.collect_type_id_2)>#attributes.collect_type_id_2#<cfelse>NULL</cfif>,
                STOCK_ID = <cfif isdefined('attributes.stock_id') and len(attributes.stock_id)>#attributes.stock_id#<cfelse>NULL</cfif>,
                PRODUCT_PLACE_ID = <cfif isdefined('attributes.depo_bolum_id') and len(attributes.depo_bolum_id)>#attributes.depo_bolum_id#<cfelse>NULL</cfif>,
                DEPARTMENT_ID = <cfif isdefined('attributes.dep_in') and len(attributes.dep_in)>#ListGetAt(attributes.dep_in,1,'-')#<cfelse>NULL</cfif>,
                LOCATION_ID = <cfif isdefined('attributes.dep_in') and len(attributes.dep_in)>#ListGetAt(attributes.dep_in,2,'-')#<cfelse>NULL</cfif>,
                IS_KARMA = #attributes.is_karma#,
                UPDATE_EMP = #session.ep.userid#,
             	UPDATE_IP = '#cgi.remote_addr#',
                UPDATE_DATE = #now()#
            WHERE        
                PACKING_ID = #attributes.packing_id#
        </cfquery>
        <cfif attributes.process_status eq 0> <!---İlk Defa Paket İlave edilmişse Paket Bu tarihte oluşur. Palet hareket Table Ekleme Yapılıyor--->
        	<cfquery name="add_packing_action" datasource="#dsn2#">
        		INSERT INTO        
                	#dsn3_alias#.EZGI_PACKING_ACTION
                    (
                    	PACKING_ID, 
                        EZGI_PACKING_ACTION_TYPE_ID,
                        STORE, 
                        STORE_LOCATION, 
                        OUT_STORE, 
                        OUT_STORE_LOCATION,
                        EZGI_ID, 
                        PROCESS_DATE, 
                        RECORD_IP, 
                        RECORD_EMP
               		)
				VALUES 
                	(
                    	#attributes.packing_id#,
                        #attributes.packing_action_type_id#,
                        #ListGetAt(attributes.dep_in,1,'-')#,
                       	#ListGetAt(attributes.dep_in,2,'-')#,
                        <cfif isdefined('attributes.dep_out') and Listlen(attributes.dep_out,'-')>#ListGetAt(attributes.dep_out,1,'-')#<cfelse>NULL</cfif>,
                       	<cfif isdefined('attributes.dep_out') and Listlen(attributes.dep_out,'-')>#ListGetAt(attributes.dep_out,2,'-')#<cfelse>NULL</cfif>,
                        '#attributes.ezg_row_id#',
                        #now()#,
                        '#cgi.remote_addr#',
                        #session.ep.userid#
                  	)
        	</cfquery>
        </cfif>
        <!---<cfif attributes.is_karma eq 0>--->
			<cfif isdefined('attributes.action_id') and Listlen(attributes.action_id)>
                <cfloop list="#attributes.action_id#" index="i">
                    <cfquery name="add_row" datasource="#dsn2#"> <!---Tüm Palet Satırları Yeniden İlave Ediliyor--->
                        INSERT INTO 
                            #dsn3_alias#.EZGI_PACKING_ROW
                            (
                                PACKING_ID, 
                                AMOUNT, 
                                STOCK_ID, 
                                SERIAL_NO,
                                SPECT_MAIN_ID
                            )
                        VALUES        
                            (
                                #attributes.packing_id#,
                                1,
                                #ListGetAt(i,3,'-')#,
                                <cfif len(ListGetAt(i,5,'-'))>'#ListGetAt(i,5,'-')#'<cfelse>NULL</cfif>,
                                <cfif Len(ListGetAt(i,4,'-')) and ListGetAt(i,4,'-') gt 0>#ListGetAt(i,4,'-')#<cfelse>NULL</cfif>
                            )
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
                                PACKING_ID, 
                                RECORD_EMP, 
                                RECORD_IP
                            )
                        VALUES 
                            (
                                #now()#,
                                <cfif len(ListGetAt(i,5,'-'))>'#ListGetAt(i,5,'-')#'<cfelse>NULL</cfif>,
                                #ListGetAt(i,3,'-')#,
                                #ListGetAt(attributes.dep_in,1,'-')#,
                                #ListGetAt(attributes.dep_in,2,'-')#,
                                #ListGetAt(attributes.dep_out,1,'-')#,
                                #ListGetAt(attributes.dep_out,2,'-')#,
                                #attributes.packing_id#,
                                #session.ep.userid#,
                                '#cgi.remote_addr#'
                            )
                    </cfquery>
                </cfloop>
                <cfif attributes.dep_out neq attributes.dep_in> <!---Eğer Depo farklılığı varsa--->
                    <cfinclude template="add_ezgi_pallets_stock_fis.cfm"> <!---Stok Hareketi Yapılsın--->
                </cfif>
        	</cfif>
        <!---</cfif>--->
    </cftransaction>
    </cflock>
 	<cflocation url="#request.self#?fuseaction=stock.list_ezgi_pallets&event=upd&packing_id=#attributes.packing_id#" addtoken="no">
 </cfif>