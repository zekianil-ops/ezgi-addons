<!---
    File: upd_ezgi_operation_optimum_time.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset rec_row = ListLen(attributes.CONVERT_OPERATION_OPTIMUM_TIME_ID)>
 
<cfif rec_row gt 0>
    <cftransaction>
        <cfloop from="1" to="#rec_row#" index="i">
    		<cfif ListGetAt(CONVERT_OPERATION_OPTIMUM_TIME_ID,i) eq 0>
            	<cfquery name="add_operation_optimum_time" datasource="#dsn3#">
                	INSERT 
                    	INTO EZGI_OPERATION_OPTIMUM_TIME
                   		(
                        STOCK_ID, 
                        OPERATION_TYPE_ID, 
                        OPTIMUM_TIME, 
                        RECORD_DATE, 
                        RECORD_EMP, 
                        RECORD_IP, 
                        STATUS
                        )
					VALUES        
                    	(
                        #ListGetAt(attributes.CONVERT_STOCKS_ID,i)#,
                        #ListGetAt(attributes.CONVERT_OPERATION_TYPE_ID,i)#,
                        #ListGetAt(attributes.CONVERT_OPTIMUM_TIME,i)#,
                        #now()#,
                        #session.ep.userid#,
                        '#CGI.REMOTE_ADDR#',
                        1
                        )
                </cfquery>
            <cfelse>
            	<cfquery name="upd_operation_optimum_time" datasource="#dsn3#">
                	UPDATE       
                    	EZGI_OPERATION_OPTIMUM_TIME
					SET                
                    	STOCK_ID = #ListGetAt(attributes.CONVERT_STOCKS_ID,i)#, 
                        OPERATION_TYPE_ID = #ListGetAt(attributes.CONVERT_OPERATION_TYPE_ID,i)#, 
                        OPTIMUM_TIME = #ListGetAt(attributes.CONVERT_OPTIMUM_TIME,i)#, 
                        UPDATE_DATE = #now()#, 
                        UPDATE_EMP = #session.ep.userid#, 
                        UPDATE_IP = '#CGI.REMOTE_ADDR#'
					WHERE        
                    	EZGI_OPERATION_OPTIMUM_TIME_ID = #ListGetAt(CONVERT_OPERATION_OPTIMUM_TIME_ID,i)#
                </cfquery>
            </cfif>
    	</cfloop>
    </cftransaction>
</cfif>
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_operation_time&is_active=#attributes.active#&keyword=#attributes.keyw#&form_submitted=1" addtoken="No">