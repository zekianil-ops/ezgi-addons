<!---
    File: upd_ezgi_production_order_from_iflow_master.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset rec_row = ListLen(attributes.CONVERT_STATION_OEE_RATE_ID)>
<cfif rec_row gt 0>
    <cftransaction>
        <cfloop from="1" to="#rec_row#" index="i">
    		<cfif ListGetAt(CONVERT_STATION_OEE_RATE_ID,i) eq 0>
            	<cfquery name="add_oee_rate" datasource="#dsn3#">
                	INSERT INTO 
                    	<cfif attributes.list_type eq 1>
                    		EZGI_STATION_OOE_RATE
                        <cfelse>
                        	EZGI_EMPLOYEE_OOE_RATE
                        </cfif>
                   		(
                        <cfif attributes.list_type eq 1>
                        	STATION_ID, 
                        <cfelse>
                        	EMPLOYEE_ID,
                        </cfif>
                        OEE_STATUS, 
                        OEE_PERFORM_RATE, 
                        OEE_AVAILBILITY_RATE, 
                        OEE_QUALITY_RATE, 
                        RECORD_DATE, 
                        RECORD_EMP, 
                        RECORD_IP
                        )
					VALUES        
                    	(
                        #ListGetAt(attributes.CONVERT_STATION_ID,i)#,
                        1,
                        #ListGetAt(attributes.CONVERT_PERFORM_TIME,i)#,
                        #ListGetAt(attributes.CONVERT_AVAILABILITY_TIME,i)#,
                        #ListGetAt(attributes.CONVERT_QUALITY_TIME,i)#,
                        #now()#,
                        #session.ep.userid#,
                        '#CGI.REMOTE_ADDR#'
                        )
                </cfquery>
            <cfelse>
            	<cfquery name="upd_oee_rate" datasource="#dsn3#">
                	UPDATE       
                    	<cfif attributes.list_type eq 1>
                    		EZGI_STATION_OOE_RATE
                        <cfelse>
                        	EZGI_EMPLOYEE_OOE_RATE
                        </cfif>
					SET    
                    	<cfif attributes.list_type eq 1>
                        	STATION_ID = #ListGetAt(attributes.CONVERT_STATION_ID,i)#,  
                        <cfelse>
                        	EMPLOYEE_ID = #ListGetAt(attributes.CONVERT_STATION_ID,i)#, 
                        </cfif>            
                        OEE_PERFORM_RATE = #ListGetAt(attributes.CONVERT_PERFORM_TIME,i)#, 
                        OEE_AVAILBILITY_RATE = #ListGetAt(attributes.CONVERT_AVAILABILITY_TIME,i)#,
                        OEE_QUALITY_RATE = #ListGetAt(attributes.CONVERT_QUALITY_TIME,i)#,
                        UPDATE_DATE = #now()#, 
                        UPDATE_EMP = #session.ep.userid#, 
                        UPDATE_IP = '#CGI.REMOTE_ADDR#',
                        <cfif ListGetAt(attributes.CONVERT_PERFORM_TIME,i) + ListGetAt(attributes.CONVERT_AVAILABILITY_TIME,i) + ListGetAt(attributes.CONVERT_QUALITY_TIME,i) gt 0>
                        	OEE_STATUS = 1
                        <cfelse>
                        	OEE_STATUS = 0
                      	</cfif>
					WHERE   
                    	<cfif attributes.list_type eq 1>     
                    		EZGI_STATION_OOE_RATE_ID = #ListGetAt(CONVERT_STATION_OEE_RATE_ID,i)#
                        <cfelse>
                        	EZGI_EMPLOYEE_OOE_RATE_ID = #ListGetAt(CONVERT_STATION_OEE_RATE_ID,i)#
                        </cfif>
                </cfquery>
            </cfif>
    	</cfloop>
    </cftransaction>
</cfif>
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_workstation_oee_rate&is_active=#attributes.active#&keyword=#attributes.keyw#&list_type=#attributes.list_type#&form_submitted=1" addtoken="No">