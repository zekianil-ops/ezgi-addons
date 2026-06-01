<!---
    File: add_ezgi_package_transfer.cfm
    Folder: Add_Ons\ezgi\e_wm\query
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Paket Transfer
---> 

<!---<cfdump var="#attributes#"><cfabort>--->
<cfset attributes.action_id = ''>
<cfset sira_no = 1>
<cfif len(attributes.dep_out)>
	<cfset out_dep = attributes.dep_out>
<cfelse>
	<cfset out_dep = 0>
</cfif>
<cfif len(attributes.packing_out)>
	<cfset out_pack = attributes.packing_out>
<cfelse>
	<cfset out_pack = 0>
</cfif>
<cfif len(attributes.shelf_out)>
	<cfset out_shelf = attributes.shelf_out>
<cfelse>
	<cfset out_shelf = 0>
</cfif>
<cflock name="#CreateUUID()#" timeout="60">
	<cftransaction>
    	<cfif ListLen(attributes.row_info_id)>
        	<cfset row_action_id = ''>
        	<cfloop list="#attributes.row_info_id#" index="kj">
            	<cfset attributes.ezg_row_id = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')# & #session.ep.company_id# & #ListGetAt(kj,2,'-')#>
            	<cfquery name="get_serial" datasource="#dsn2#">
                	SELECT 
                    	*,
                    	ISNULL(DEPO,'0') AS A_DEPO,
                        ISNULL(PACKING_ID,0) AS A_PACKING_ID,
                        ISNULL(PRODUCT_PLACE_ID,0) AS A_PRODUCT_PLACE_ID
                   	FROM 
                    	#dsn3_alias#.EZGI_WM_SERIAL_NO_LAST_STATUS 
                   	WHERE 
                    	SERIAL_NO = '#ListGetAt(kj,2,'-')#'                       
             	</cfquery>
                <cfif get_serial.A_DEPO neq out_dep>
                	<script type="text/javascript">
						alert("<cfoutput>#ListGetAt(kj,2,'-')#</cfoutput> Seri Nolu Ürünün Depo Bilgisi Değişmiş!");
						window.history.go(-1);
					</script>
					<cfabort>
                </cfif>
                <cfif get_serial.A_PACKING_ID neq out_pack>
                	<script type="text/javascript">
						alert("<cfoutput>#ListGetAt(kj,2,'-')#</cfoutput> Seri Nolu Ürünün Palet Bilgisi Değişmiş!");
						window.history.go(-1);
					</script>
					<cfabort>
                </cfif>
                <cfif get_serial.A_PRODUCT_PLACE_ID neq out_shelf>
                	<script type="text/javascript">
						alert("<cfoutput>#ListGetAt(kj,2,'-')#</cfoutput> Seri Nolu Ürünün Raf Bilgisi Değişmiş!");
						window.history.go(-1);
					</script>
					<cfabort>
                </cfif>
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
                            '#get_serial.SERIAL_NO#', 
                           	#get_serial.STOCK_ID#,
                            #ListGetAt(attributes.dep_in,1,'-')#,
                          	#ListGetAt(attributes.dep_in,2,'-')#, 
                            #get_serial.DEPARTMENT_ID#, 
                            #get_serial.LOCATION_ID#,
                          	<cfif len(attributes.shelf_in)>#attributes.shelf_in#<cfelse>NULL</cfif>,
                            <cfif len(get_serial.PRODUCT_PLACE_ID)>#get_serial.PRODUCT_PLACE_ID#<cfelse>NULL</cfif>,
                          	<cfif len(attributes.packing_in)>#attributes.packing_in#<cfelse>NULL</cfif>,
                            #session.ep.userid#,
                            '#cgi.remote_addr#'
	                	)      
             	</cfquery>
                <cfif attributes.packing_in neq get_serial.PACKING_ID> <!---pALET dEĞİŞMİŞSE--->
                	<cfif len(attributes.packing_in)>
                    	<cfquery name="add_row" datasource="#dsn2#"> <!---Giren palete Ekleniyor--->
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
                                    #attributes.packing_in#,
                                    1,
                                    #get_serial.STOCK_ID#,
                                    '#get_serial.SERIAL_NO#',
                                    '#get_serial.SPECT_ID#'
                                )
                        </cfquery>
                    </cfif>
                    <cfif len(get_serial.PACKING_ID)>
                    	<cfquery name="del_row" datasource="#dsn2#"> <!---Çıkan paletten Siliniyor--->
                        	DELETE FROM #dsn3_alias#.EZGI_PACKING_ROW WHERE SERIAL_NO = '#get_serial.SERIAL_NO#' AND PACKING_ID = #get_serial.PACKING_ID#
                        </cfquery>
                    </cfif>
                </cfif>
            	<cfif sira_no eq 1>
                  	<cfset row_action_id = '#sira_no#'>
             	<cfelse>
                 	<cfset row_action_id = '#row_action_id#,#sira_no#'>
              	</cfif>
                <cfif len(attributes.packing_in)>
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
            	<cfinclude template="add_ezgi_pallets_stock_fis.cfm"> <!---Stok Hareketi Yapılsın--->
            </cfif>
        </cfif>
    </cftransaction>
</cflock>
<cflocation url="#request.self#?fuseaction=stock.add_ezgi_package_transfer" addtoken="no">
