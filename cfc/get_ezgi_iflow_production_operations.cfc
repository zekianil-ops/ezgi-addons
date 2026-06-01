<cfcomponent>
	<cfset dsn = application.systemParam.systemParam().dsn />
    <cfset dsn1 = "#dsn#_product" />
    <cfset dsn3 = "#dsn#_#session.ep.company_id#" />
    <cffunction name="new_ranking" returnformat="JSON" returntype="any" access="remote">
        <cfset incomingData = DeserializeJSON(arguments.form_data)>
        <!--- bu kısımda partiler dönüyor --->
        <cfset parti_sira_no =1>
        <cfset emir_sira_no =1>
        <cfloop array="#incomingData#" index="parti">
            <cftry>
                <cfquery name="set_parti" datasource="#dsn3#">
                	UPDATE 
                    	EZGI_IFLOW_PRODUCTION_ORDERS_PARTI
					SET          
                    	P_ORDER_PARTI_SORT_NO = <cfqueryparam cfsqltype="cf_sql_integer" value="#parti_sira_no#">
					WHERE  
                    	P_ORDER_PARTI_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#parti.parti_id#">
                </cfquery>
                <cfloop array="#parti.urunler#" index="urun">
                    <cfquery name="set_emir" datasource="#dsn3#">
                    	UPDATE 
                        	EZGI_IFLOW_PRODUCTION_ORDERS
						SET          
                        	P_ORDER_SORT_NO = <cfqueryparam cfsqltype="cf_sql_integer" value="#emir_sira_no#">,
                            REL_P_ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#parti.parti_id#">
						WHERE  
                        	IFLOW_P_ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#urun.iflow_p_order_id#">
                    </cfquery>
                    <cfset emir_sira_no = emir_sira_no+1>
                    <cfset ornek_iflow_p_order_id = urun.iflow_p_order_id>
                </cfloop>
                
                <cfset response.status = true />
                <cfcatch type="any">
                    <cfset response.status = false />
                </cfcatch>
            </cftry>
            <cfset parti_sira_no = parti_sira_no+1>
        </cfloop>

        <!---<cfinclude template="../e_production/query/sort_ezgi_iflow_master_plan.cfm">--->
    </cffunction>
</cfcomponent>