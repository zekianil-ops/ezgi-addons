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
                        SAYIM_FIS,
                        IS_FAST_SALES_REICIPT
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
                        #attributes.process_cat1#,
                        <cfif isdefined('attributes.is_fast_sales_reicipt')>1<cfelse>0</cfif>
                   	)
            </cfquery>
            <cfquery name="del_emp" datasource="#dsn3#">
            	DELETE FROM #dsn_alias#.EZGI_PDA_DEPARTMENT_DEFAULTS
          	</cfquery>
            <cfloop from="1" to="#attributes.RECORD_NUM_EMP#" index="i">
            	<cfif Evaluate('attributes.ROW_KONTROL_EMP#i#') eq 1>
					<cfset DEFAULT_MK_TO_RF_DEP = "#ListGetAt(Evaluate('attributes.kabul_#i#'),1,'-')#,#ListGetAt(Evaluate('attributes.ambar_#i#'),1,'-')#">
                    <cfset DEFAULT_RF_TO_SV_DEP = "#ListGetAt(Evaluate('attributes.ambar_#i#'),1,'-')#,#ListGetAt(Evaluate('attributes.sevkiyat_#i#'),1,'-')#">
                    <cfset DEFAULT_MK_TO_RF_LOC = "#ListGetAt(Evaluate('attributes.kabul_#i#'),2,'-')#,#ListGetAt(Evaluate('attributes.ambar_#i#'),2,'-')#">
                    <cfset DEFAULT_RF_TO_SV_LOC = "#ListGetAt(Evaluate('attributes.ambar_#i#'),2,'-')#,#ListGetAt(Evaluate('attributes.sevkiyat_#i#'),2,'-')#">
                    <cfquery name="add_emp" datasource="#dsn3#">
                        INSERT INTO 
                            #dsn_alias#.EZGI_PDA_DEPARTMENT_DEFAULTS
                            (
                                EPLOYEE_ID, 
                                DEFAULT_MK_TO_RF_DEP, 
                                DEFAULT_MK_TO_RF_LOC, 
                                DEFAULT_RF_TO_SV_DEP, 
                                DEFAULT_RF_TO_SV_LOC, 
                                POWER_USER,
                                PREPARATION
                            )
                        VALUES        
                            (
                                #Evaluate('attributes.employee_id_#i#')#,
                                '#DEFAULT_MK_TO_RF_DEP#',
                                '#DEFAULT_MK_TO_RF_LOC#',
                                '#DEFAULT_RF_TO_SV_DEP#',
                                '#DEFAULT_RF_TO_SV_LOC#',
                                <cfif isdefined('attributes.power_user_#i#')>
                                1
                                <cfelse>
                                0
                                </cfif>,
                                <cfif isdefined('attributes.Preparation_#i#') and  len(Evaluate('attributes.Preparation_#i#'))>#Evaluate('attributes.Preparation_#i#')#<cfelse>NULL</cfif>
                            )
                    </cfquery>
               	</cfif>
            </cfloop>
    	</cftransaction>
	</cflock>
</cfif>
<cflocation url="#request.self#?fuseaction=sales.setup_ezgi_shipping" addtoken="No">