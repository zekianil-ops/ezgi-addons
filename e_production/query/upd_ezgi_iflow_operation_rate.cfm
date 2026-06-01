<!---
    File: upd_ezgi_iflow_operation_rate.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cftransaction>
	<cflock timeout="90">
    	<cfquery name="upd_operation" datasource="#dsn3#">
        	UPDATE       
            	OPERATION_TYPES
			SET                
                O_MINUTE = <cfif len(attributes.ezgi_i_sure)>#FilterNum(attributes.ezgi_i_sure,0)#<cfelse>0</cfif>, 
                EZGI_H_SURE = <cfif len(attributes.ezgi_h_sure)>#FilterNum(attributes.ezgi_h_sure,0)#<cfelse>0</cfif>, 
                EZGI_FORMUL = '#attributes.formul#'
			WHERE        
            	OPERATION_TYPE_ID = #attributes.operation_type_id#
        </cfquery>
        <cfloop list="#station_id_list#" index="i">
        	<cfquery name="upd_station" datasource="#dsn3#">
            	UPDATE       
                	WORKSTATIONS
				SET                
                	EMPLOYEE_NUMBER = <cfif len(Evaluate('attributes.employee_number#i#'))>#FilterNum(Evaluate('attributes.employee_number#i#'),0)#<cfelse>0</cfif>, 
                    EZGI_SETUP_TIME = <cfif len(Evaluate('attributes.ezgi_setup_time#i#'))>#FilterNum(Evaluate('attributes.ezgi_setup_time#i#'),0)#<cfelse>0</cfif>, 
                    EZGI_KATSAYI = <cfif len(Evaluate('attributes.ezgi_katsayi#i#'))>#FilterNum(Evaluate('attributes.ezgi_katsayi#i#'),1)#<cfelse>0</cfif>
				WHERE        
                	STATION_ID = #i#
            </cfquery>
            <cfif isdefined('attributes.default_status#i#')>
            	<cfquery name="upd_1" datasource="#dsn3#">
                	UPDATE       
                    	WORKSTATIONS_PRODUCTS
					SET                
                    	DEFAULT_STATUS = 0
					WHERE        
                    	OPERATION_TYPE_ID = #attributes.operation_type_id#
                </cfquery>
                <cfquery name="upd_2" datasource="#dsn3#">
                	UPDATE       
                    	WORKSTATIONS_PRODUCTS
					SET                
                    	DEFAULT_STATUS = 1
					WHERE        
                    	WS_P_ID = #Evaluate('attributes.default_status#i#')#
                </cfquery>
            </cfif>
        </cfloop>
    </cflock>
</cftransaction>
<cfif not isdefined('attributes.e_design')>
	<cfinclude template="upd_ezgi_iflow_master_plan_operation.cfm">
</cfif>
<script type="text/javascript">
	wrk_opener_reload();
 	window.close();
</script>