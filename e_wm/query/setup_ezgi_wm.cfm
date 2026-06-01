<cfdump var="#attributes#">
<cfif attributes.RECORD_NUM_EMP gt 0>
	<cflock timeout="90">
    	<cftransaction>	
        	<cfquery name="del_setup" datasource="#dsn3#">
            	DELETE FROM EZGI_SHIPPING_DEFAULTS
            </cfquery>
        	<cfquery name="add_setup" datasource="#dsn3#">
            	INSERT INTO 
                	EZGI_SHIPPING_DEFAULTS
                	(
                    	SHIPPING_CONTROL_TYPE, 
                        PDA_CONTROL_TYPE, 
                        EAN, 
                        IS_AMOUNT_INPUT_FREE,
                        PALET_BARCODE,
                        PALET_BARCODE_LOT,
                        FIRE_FIS, 
                        SAYIM_FIS
                  	)
				VALUES        
                	(
                    	<cfif isdefined('attributes.ambar_control')>
                        	1,
                        <cfelse>
                        	0,
                        </cfif>
                        #attributes.pda_control_type#,
                        #attributes.ean#,
                        <cfif isdefined('attributes.e_shipping_control')>1<cfelse>0</cfif>,
                        '#attributes.barcode#',
                        #attributes.lot_zorunlu#,
                        #attributes.process_cat2#,
                        #attributes.process_cat1#
                   	)
            </cfquery>
            <cfquery name="del_emp" datasource="#dsn3#">
            	DELETE FROM EZGI_WM_SETUP_ROW
          	</cfquery>
            <cfloop from="1" to="#attributes.RECORD_NUM_EMP#" index="i">
            	<cfif Evaluate('attributes.ROW_KONTROL_EMP#i#') eq 1>
                	<cfset check_list = ''>
                	<cfloop from="1" to="4" index="k">
						<cfif isdefined('attributes.select_#k#_#i#')>
                        	<cfif Listlen(check_list)>
                            	<cfset check_list = '#check_list#,#k#'>
                            <cfelse>
                            	<cfset check_list = '#k#'>
                            </cfif>
                        </cfif>
                    </cfloop>
                    <cfquery name="add_emp" datasource="#dsn3#">
                        INSERT INTO 
                            EZGI_WM_SETUP_ROW
                            (
                                EMPLOYEE_POSITION_ID, 
                                PRODUCTION_WAREHOUSE, 
                                INTERMEDIATE_WAREHOUSE, 
                                SHELF_WAREHOUSE, 
                                SHIPMENT_WAREHOUSE,
                                ORDER_PAGE_AUTHORITY
                            )
                        VALUES        
                            (
                                #Evaluate('attributes.employee_id_#i#')#,
                                '#Evaluate('attributes.product_#i#')#',
                                '#Evaluate('attributes.paletting_#i#')#',
                                '#Evaluate('attributes.wm_#i#')#',
                                '#Evaluate('attributes.shipping_#i#')#',
                                <cfif ListLen(check_list)>'#check_list#'<cfelse>NULL</cfif>
                            )
                    </cfquery>
               	</cfif>
            </cfloop>
    	</cftransaction>
	</cflock>
</cfif>
<cflocation url="#request.self#?fuseaction=stock.setup_ezgi_wm" addtoken="No">