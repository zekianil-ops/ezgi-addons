<cf_date tarih="attributes.date">
<cf_date tarih="attributes.termin">
<cftransaction>
    <cfquery name="add_demand" datasource="#dsn3#">
        INSERT INTO 
            EZGI_PRODUCTION_DEMAND
            (
                DEMAND_HEAD, 
                PROCESS_STAGE, 
                DEMAND_DATE, 
                DEMAND_DELIVER_DATE,
                DEMAND_DETAIL, 
                DEMAND_EMP,
                DEMAND_TO_EMP,
                DEMAND_DEPARTMENT_ID,
                DEMAND_NUMBER,
                PROJECT_ID,
                RECORD_EMP, 
                RECORD_IP, 
                RECORD_DATE
                
            )
        VALUES
            (
                <cfif len(attributes.demand_head)>'#attributes.demand_head#'<cfelse>NULL</cfif>,
                #attributes.PROCESS_STAGE#,
                #attributes.date#,
                #attributes.termin#,
                <cfif len(attributes.detail)>'#attributes.detail#'<cfelse>NULL</cfif>,
                <cfif len(attributes.order_employee)>#attributes.order_employee_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.demand_employee)>#attributes.demand_employee_id#<cfelse>NULL</cfif>,
                <cfif len(attributes.department_id)>#attributes.department_id#<cfelse>NULL</cfif>,
                #demand_no#,
                <cfif len(attributes.project_id)>#attributes.project_id#<cfelse>NULL</cfif>,
                #session.ep.userid#,
                '#CGI.REMOTE_ADDR#',
                #now()#
            )
    </cfquery>
    <cfquery name="get_max_id" datasource="#dsn3#">
        SELECT     
            MAX(EZGI_DEMAND_ID) AS EZGI_DEMAND_ID
        FROM         
            EZGI_PRODUCTION_DEMAND
    </cfquery>
    <cfloop from="1" to="#attributes.RECORD_NUM#" index="i">
    	<cfif isdefined('attributes.row_kontrol#i#') and Evaluate('attributes.row_kontrol#i#') gt 0>
        	<cfquery name="add_demand_row" datasource="#dsn3#">
            	INSERT INTO 
                    EZGI_PRODUCTION_DEMAND_ROW
                    (
                        EZGI_DEMAND_ID, 
                        STOCK_ID, 
                        QUANTITY,
                        EZGI_ID,
                        PRODUCT_TYPE,
                        PRODUCTION_WASTAGE_ID
                    )
                VALUES
                    (
                        #get_max_id.EZGI_DEMAND_ID#,
                        #Evaluate('attributes.stock_id#i#')#,
                        #FilterNum(Evaluate('attributes.quantity#i#'),2)#,
                        <cfif len(Evaluate('attributes.ezgi_id#i#'))>
                        #Evaluate('attributes.ezgi_id#i#')#
                        <cfelse>
                        NULL
                        </cfif>,
                        <cfif len(Evaluate('attributes.type#i#'))>
                        	#Evaluate('attributes.type#i#')#
                        <cfelse>    
                            NULL
                        </cfif>,
                        <cfif isdefined('attributes.wastage_id#i#') and len(Evaluate('attributes.wastage_id#i#'))>
                        	#Evaluate('attributes.wastage_id#i#')#
                        <cfelse>    
                            NULL
                        </cfif>
                    )
        	</cfquery>
        </cfif>
    </cfloop>
    <cfquery name="upd_ezgi_id" datasource="#dsn3#">
    	UPDATE EZGI_PRODUCTION_DEMAND_ROW SET EZGI_ID = EZGI_DEMAND_ROW_ID WHERE EZGI_DEMAND_ID = #get_max_id.EZGI_DEMAND_ID#
  	</cfquery>
</cftransaction>
<cf_workcube_process 
	is_upd='1' 
	old_process_line='0'
	process_stage='#attributes.process_stage#' 
	record_member='#session.ep.userid#' 
	record_date='#now()#'
	action_table='EZGI_PRODUCTION_DEMAND'
	action_column='EZGI_DEMAND_ID'
	action_id='#get_max_id.EZGI_DEMAND_ID#'
	action_page='#request.self#?fuseaction=prod.list_ezgi_e_planning&event=upd&upd_id=#get_max_id.EZGI_DEMAND_ID#'
	warning_description = 'Üretim Plan Talep No : #demand_no#'>
<cfif not isdefined('attributes.LIST_TYPE')> <!---Fire Yönetiminden Gelmiyorsa--->
	<script type="text/javascript">
        window.location.href = '<cfoutput>#request.self#?fuseaction=prod.list_ezgi_e_planning&event=upd&upd_id=#get_max_id.EZGI_DEMAND_ID#</Cfoutput>';
    </script>
</cfif>