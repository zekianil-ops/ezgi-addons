<cf_date tarih="attributes.date">
<cf_date tarih="attributes.termin">
<cfif isdefined('attributes.stock_id_list') and listlen(attributes.stock_id_list)>
	<cfloop list="#attributes.stock_id_list#" index="i">
		<cfset stock_id = ListGetAt(i,1,'_')>
        <cfset amount = ListGetAt(i,2,'_')>
        <cfquery name="get_product_type" datasource="#dsn3#">
					SELECT   TOP(1)     
                    	PIECE_TYPE 
					FROM            
                    	(
                        	SELECT        
                            	2 AS PIECE_TYPE, 
                                DESIGN_MAIN_RELATED_ID AS STOCK_ID
                          	FROM      
                            	EZGI_DESIGN_MAIN_ROW
                          	WHERE        
                            	DESIGN_MAIN_STATUS = 1 AND 
                                DESIGN_MAIN_RELATED_ID IS NOT NULL
                          	UNION ALL
                          	SELECT        
                          		3 AS PIECE_TYPE, 
                            	PACKAGE_RELATED_ID AS STOCK_ID
                          	FROM            
                            	EZGI_DESIGN_PACKAGE_ROW
                          	WHERE        
                            	PACKAGE_RELATED_ID IS NOT NULL
                          	UNION ALL
                          	SELECT        
                            	4 AS PIECE_TYPE, 
                                PIECE_RELATED_ID AS STOCK_ID
                          	FROM    
                            	EZGI_DESIGN_PIECE_ROWS
                          	WHERE        
                            	PIECE_RELATED_ID IS NOT NULL
              			) AS TBL
                  	WHERE 
                    	TBL.STOCK_ID = #stock_id#
     	</cfquery>
     	<cfquery name="add_demand_row" datasource="#dsn3#">
                INSERT INTO 
                    EZGI_PRODUCTION_DEMAND_ROW
                    (
                        EZGI_DEMAND_ID, 
                        STOCK_ID, 
                        QUANTITY,
                        EZGI_ID,
                        PRODUCT_TYPE
                    )
                VALUES
                    (
                        #attributes.upd_id#,
                        #stock_id#,
                        #FilterNum(amount,2)#,
                        NULL,
                        <cfif len(get_product_type.PIECE_TYPE)>
                    		#get_product_type.PIECE_TYPE#
                        <cfelse>
                        	NULL
                      	</cfif>
                    )
     	</cfquery>
  	</cfloop>
    <script type="text/javascript">
        wrk_opener_reload();
        window.close();
	</script>
    <cfabort>
</cfif>
<cftransaction>
    <cfquery name="add_demand" datasource="#dsn3#">
        UPDATE
            EZGI_PRODUCTION_DEMAND
      	SET
       		DEMAND_HEAD = '#attributes.demand_head#',
         	PROCESS_STAGE = #attributes.PROCESS_STAGE#,
          	DEMAND_DATE = #attributes.date#,
          	DEMAND_DELIVER_DATE = #attributes.termin#, 
          	DEMAND_DETAIL = <cfif len(attributes.detail)>'#attributes.detail#'<cfelse>NULL</cfif>, 
            DEMAND_EMP = <cfif len(attributes.order_employee)>#attributes.order_employee_id#<cfelse>NULL</cfif>,
            DEMAND_TO_EMP = <cfif len(attributes.demand_employee)>#attributes.demand_employee_id#<cfelse>NULL</cfif>,
            DEMAND_DEPARTMENT_ID = <cfif len(attributes.department_id)>#attributes.department_id#<cfelse>NULL</cfif>,
            PROJECT_ID = <cfif len(attributes.project_head) and len(attributes.project_id)>#attributes.project_id#<cfelse>NULL</cfif>,
         	UPDATE_EMP = #session.ep.userid#,
        	UPDATE_IP = '#CGI.REMOTE_ADDR#',
         	UPDATE_DATE = #now()#
      	WHERE
        	EZGI_DEMAND_ID = #attributes.upd_id#
    </cfquery>
    <cfif not isdefined('attributes.demand_row_list')>
    	<cfset attributes.demand_row_list = ''>
    </cfif>
    <cfloop from="1" to="#attributes.RECORD_NUM#" index="i">
    	<cfif isdefined('attributes.row_kontrol#i#') and Evaluate('attributes.row_kontrol#i#') gt 0>
        	<cfif ListLen(attributes.demand_row_list) lt i> <!---Eklenen Satırsa--->
                <cfquery name="add_demand_row" datasource="#dsn3#">
                    INSERT INTO 
                        EZGI_PRODUCTION_DEMAND_ROW
                        (
                            EZGI_DEMAND_ID, 
                            STOCK_ID, 
                            QUANTITY,
                            PRODUCT_TYPE
                        )
                    VALUES
                        (
                            #attributes.upd_id#,
                            #Evaluate('attributes.stock_id#i#')#,
                            #FilterNum(Evaluate('attributes.quantity#i#'),2)#,
                            <cfif len(Evaluate('attributes.type#i#'))>
                                #Evaluate('attributes.type#i#')#
                            <cfelse>    
                                NULL
                            </cfif>
                        )
                </cfquery>
         	<cfelse> <!---Satır Değişmişse--->
            	<cfquery name="upd_demand_row" datasource="#dsn3#">
                	UPDATE      
                    	EZGI_PRODUCTION_DEMAND_ROW
					SET                
                    	STOCK_ID = #Evaluate('attributes.stock_id#i#')#, 
                        QUANTITY = #FilterNum(Evaluate('attributes.quantity#i#'),2)#,
                        PRODUCT_TYPE = <cfif len(Evaluate('attributes.type#i#'))>#Evaluate('attributes.type#i#')#<cfelse>NULL</cfif>
					WHERE        
                    	EZGI_DEMAND_ROW_ID = #ListGetAt(attributes.demand_row_list,i)# 
                </cfquery>
            </cfif>
       	<cfelse><!--- Satır Silinmişse--->
        	<cfquery name="del_demand_row" datasource="#dsn3#">
              	DELETE FROM EZGI_PRODUCTION_DEMAND_ROW WHERE EZGI_DEMAND_ROW_ID = #ListGetAt(attributes.demand_row_list,i)#
          	</cfquery>
        </cfif>
    </cfloop>
</cftransaction>
<cf_workcube_process 
		is_upd='1' 
		old_process_line='0'
        data_source='#dsn3#'
		process_stage='#attributes.process_stage#' 
		record_member='#session.ep.userid#' 
		record_date='#now()#' 
		action_table='EZGI_PRODUCTION_DEMAND'
		action_column='EZGI_DEMAND_ID'
		action_id='#attributes.upd_id#'
		action_page='#request.self#?fuseaction=prod.list_ezgi_e_planning&event=upd&upd_id=#attributes.upd_id#' 
		warning_description='Üretim Plan Talep No'>
<script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#?fuseaction=prod.list_ezgi_e_planning&event=upd&upd_id=#attributes.upd_id#</Cfoutput>';
</script>