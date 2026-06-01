<!---
    File: add_ezgi_operation_works_transfer.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/07/2022
    Description:
--->
<cfif ListLen(attributes.select_operation_id)>
	<cfif isdefined('attributes.onay')>
    	<cfloop list="#attributes.select_operation_id#" index="i">
        	<cfif ListGetAt(i,2,'_') eq 0>
            	<cfquery name="add_time_cost" datasource="#dsn3#">
            		INSERT  INTO        
                    	EZGI_OPERATION_TIME_COST
                        (
                        	TIME_COST_TYPE, 
                            TIME_COST_START_DATE, 
                            TIME_COST_FINISH_DATE, 
                            TIME_COST_MINUTE, 
                            OPERATION_RESULT_ID, 
                            EMPLOYEE_ID, 
                            STATION_ID, 
                            STATUS, 
                            OVERTIME_TYPE, 
                  			RECORD_EMP, 
                            RECORD_DATE, 
                            RECORD_IP
                     	)
					VALUES 
                    	(
                        	0,
                            '#Evaluate('attributes.start_date#i#')#',
                            '#Evaluate('attributes.finish_date#i#')#',
                            #Evaluate('attributes.time_cost_minute#i#')#,
                            #ListGetAt(i,1,'_')#,
                            #Evaluate('attributes.emp_id#i#')#,
                            #Evaluate('attributes.station_id#i#')#,
                            1,
                            #Evaluate('attributes.overtime_type#i#')#,
                            #session.ep.userid#,
                            #now()#,
                            '#cgi.remote_addr#'
                     	)
           		</cfquery>
            <cfelse>
            	<cfquery name="upd_time_cost" datasource="#dsn3#">
            		UPDATE 
                    	EZGI_OPERATION_TIME_COST
                  	SET
                      	TIME_COST_FINISH_DATE = '#Evaluate('attributes.finish_date#i#')#', 
                       	TIME_COST_MINUTE = #Evaluate('attributes.time_cost_minute#i#')#,
                        OVERTIME_TYPE = #Evaluate('attributes.overtime_type#i#')#,
                    	STATUS = 1, 
                  		UPDATE_EMP = #session.ep.userid#,
                       	UPDATE_DATE = #now()#,
                     	UPDATE_IP = '#cgi.remote_addr#'
                 	WHERE
                    	EZGI_OPERATION_TIME_COST_ID = #ListGetAt(i,2,'_')#
            	</cfquery>
            </cfif>
        </cfloop>
    <cfelse>
        <cftransaction>
            <cfloop list="#attributes.select_operation_id#" index="i">
                <cfquery name="get_project_info" datasource="#dsn#">
                    SELECT 
                        COMPANY_ID, 
                        PARTNER_ID
                    FROM     
                        PRO_PROJECTS
                    WHERE  
                        PROJECT_ID = #Evaluate('project_id#i#')#
                </cfquery>
                <cfquery name="add_time_cost" datasource="#dsn#">
                    INSERT INTO TIME_COST
                        (
                            OUR_COMPANY_ID,
                            TOTAL_TIME,
                            EXPENSED_MONEY,
                            EXPENSED_MINUTE,
                            EMPLOYEE_ID,
                            EMPLOYEE_NAME, 
                            WORK_ID,
                            PROJECT_ID,
                            PARTNER_ID,
                            COMPANY_ID,
                            CONSUMER_ID,
                            EXPENSE_ID,
                            COMMENT,
                            EVENT_DATE,
                            PRODUCT_ID,	
                            OVERTIME_TYPE,
                            RECORD_DATE,
                            RECORD_EMP,
                            RECORD_IP,
                            ACTIVITY_ID,
                            STATE,
                            TIME_COST_CAT_ID,
                            TIME_COST_STAGE,
                            IS_RD_SSK,
                            P_OPERATION_RESULT_ID
                        )
                    VALUES
                        (
                            #session.ep.company_id#,
                            #ceiling(Evaluate('real_time#i#')*100/60)/100# ,
                            0 ,
                            #Evaluate('real_time#i#')#,
                            #Evaluate('emp_id#i#')#,
                            '#get_emp_info(Evaluate("emp_id#i#"),0,0)#',
                            #Evaluate('work_id#i#')#, 
                            #Evaluate('project_id#i#')#, 
                            <cfif get_project_info.recordcount and len(get_project_info.company_id)>#get_project_info.company_id#<cfelse>NULL</cfif>,
                            <cfif get_project_info.recordcount and len(get_project_info.PARTNER_ID)>#get_project_info.PARTNER_ID#<cfelse>NULL</cfif>,
                            NULL, 
                            NULL,  
                            '#Evaluate("p_order_no#i#")# Nolu İş Emrinin - #Evaluate("amount#i#")# Adet - #Evaluate("product_name#i#")# Ürüne Ait #Evaluate("operasyon_type#i#")# İşlemi' ,  
                            '#Evaluate("finish_date#i#")#',
                            NULL,  
                            #Evaluate('attributes.overtime_type#i#')#,
                            #now()# ,
                            #session.ep.userid# ,
                            '#cgi.remote_addr#',
                            NULL,  
                            1,
                            2 ,
                            344 ,
                            NULL,
                            #ListGetAt(i,2,'_')#
                        )
                </cfquery>
            </cfloop>
        </cftransaction>
    </cfif>
</cfif>  
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_operation_works_transfer" addtoken="No">
