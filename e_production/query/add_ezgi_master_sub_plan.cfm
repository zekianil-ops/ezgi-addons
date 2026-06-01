<!---
    File: add_ezgi_master_sub_plan.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---<cfdump var="#attributes#"><cfabort>--->
<cfif isdefined('attributes.master_alt_plan_start_date') and isdate(attributes.master_alt_plan_start_date)>
    <cf_date tarih = "attributes.master_alt_plan_start_date">
    <cfset attributes.master_alt_plan_start_date = dateadd("n",attributes.master_alt_plan_start_m,dateadd("h",attributes.master_alt_plan_start_h ,attributes.master_alt_plan_start_date))>
<cfelse>
    <cfset attributes.master_alt_plan_start_date =''>
</cfif>
<cfif isdefined('attributes.master_alt_plan_finish_date') and isdate(attributes.master_alt_plan_finish_date)>
    <cf_date tarih = "attributes.master_alt_plan_finish_date">
    <cfset attributes.master_alt_plan_finish_date = dateadd("n",attributes.master_alt_plan_finish_m,dateadd("h",attributes.master_alt_plan_finish_h ,attributes.master_alt_plan_finish_date))>
<cfelse>
    <cfset attributes.master_alt_plan_finish_date =''>
</cfif>
<cfset _control_row=0>
<cftransaction>
	<cflock name="#CREATEUUID()#" timeout="90">
		<cfif isdefined('attributes.master_alt_plan_id') and attributes.master_alt_plan_id gt 0>
        	<cfquery name="get_master_alt_plan" datasource="#dsn3#">
            	SELECT RELATED_MASTER_ALT_PLAN_ID FROM EZGI_MASTER_ALT_PLAN WHERE MASTER_ALT_PLAN_ID =#attributes.master_alt_plan_id#
            </cfquery>
			<cfquery name="upd_master_alt_plan" datasource="#dsn3#">
				UPDATE 
                	EZGI_MASTER_ALT_PLAN
				SET 
                	MASTER_ALT_PLAN_STAGE = #attributes.process_stage#, 
                    PLAN_START_DATE = #attributes.master_alt_plan_start_date#, 
                    PLAN_FINISH_DATE =  #attributes.master_alt_plan_finish_date#, 
                    MASTER_ALT_PLAN_NO = '#paper_serious#',
                    PLAN_DETAIL = '#detail#',
                    PLAN_TYPE = #attributes.plan_type#,
                    PLAN_POINT = <cfif len(work_point)>#Filternum(work_point,2)#<cfelse>0</cfif>
                    <cfif not len(get_master_alt_plan.RELATED_MASTER_ALT_PLAN_ID)> <!---Eğer 1.Satırdaki Alt Plan ise--->
                    	,IS_RESERVED = <cfif isdefined('attributes.is_stock_reserve') and len(attributes.is_stock_reserve)>1<cfelse>0</cfif>
                    </cfif>
				WHERE 
                	MASTER_ALT_PLAN_ID =#attributes.master_alt_plan_id# OR
                    RELATED_MASTER_ALT_PLAN_ID =#attributes.master_alt_plan_id#
			</cfquery>
            
             <cfif not len(get_master_alt_plan.RELATED_MASTER_ALT_PLAN_ID)> <!---Eğer 1.Satırdaki Alt Plan ise--->
             	<cfquery name="get_master_alt_plan_related" datasource="#dsn3#">
                	SELECT 
                    	MASTER_ALT_PLAN_ID
                   	FROM 
                    	EZGI_MASTER_ALT_PLAN 
                   	WHERE 
                    	MASTER_ALT_PLAN_ID =#attributes.master_alt_plan_id# OR
                    	RELATED_MASTER_ALT_PLAN_ID =#attributes.master_alt_plan_id#
             	</cfquery>
                <cfset master_alt_plan_id_list = ValueList(get_master_alt_plan_related.MASTER_ALT_PLAN_ID)>
                <cfif ListLen(master_alt_plan_id_list)>
                	<cfquery name="upd_related_po_reserved" datasource="#dsn3#">
                    	UPDATE 
                        	PRODUCTION_ORDERS
						SET          
                        	IS_STOCK_RESERVED = <cfif isdefined('attributes.is_stock_reserve') and len(attributes.is_stock_reserve)>1<cfelse>0</cfif>
						WHERE  
                        	LOT_NO IN
                      				(
                                    	SELECT 
                                        	DISTINCT LOT_NO
                       					FROM      
                                        	PRODUCTION_ORDERS AS PRODUCTION_ORDERS_1
                       					WHERE   
                                        	P_ORDER_ID IN
                                             			(
                                                        	SELECT 
                                                            	P_ORDER_ID
                                              				FROM      
                                                            	EZGI_MASTER_PLAN_RELATIONS
                                              				WHERE   
                                                            	MASTER_ALT_PLAN_ID IN (#master_alt_plan_id_list#)
                                                      	)
                                  	)
                    </cfquery>
                </cfif>
             </cfif>
		<cfelse>
        	<cfset _paper_number = paper_serious&paper_number>
			<cfquery name="add_master_alt_plan" datasource="#dsn3#">
				INSERT INTO EZGI_MASTER_ALT_PLAN
						(
						MASTER_PLAN_ID, 
						MASTER_ALT_PLAN_NO, 
						PROCESS_ID, 
                      	MASTER_ALT_PLAN_STAGE, 
						IS_STOCK_FIS, 
						RECORD_EMP, 
						RECORD_DATE, 
						RECORD_IP,
                        PLAN_START_DATE,
                        PLAN_FINISH_DATE,
                        PLAN_DETAIL,
                        PLAN_TYPE,
                        PLAN_POINT,
                        IS_RESERVED
						)
				VALUES	
						(
						#attributes.master_plan_id#,
						'#_paper_number#',
						#islem_id#,
						#process_stage#,
						0,
						#session.ep.userid#,
						#now()#,
						'#cgi.remote_addr#',
                        #attributes.master_alt_plan_start_date#,
                        #attributes.master_alt_plan_finish_date#,
                        <cfif len(reference_no)>'#reference_no#'<cfelse>NULL</cfif>,
                        #attributes.plan_type#,
                        #Filternum(work_point,2)#,
                        <cfif isdefined('attributes.is_stock_reserve') and len(attributes.is_stock_reserve)>1<cfelse>0</cfif>
						)
			</cfquery>
			<cfquery name="UPD_PAPER" datasource="#dsn3#">
				UPDATE	EZGI_MASTER_PLAN_SABLON
				SET 	PAPER_NO = PAPER_NO+1 
				WHERE   (PROCESS_ID = #islem_id# )
			</cfquery>
            <cfquery name="get_max_id" datasource="#dsn3#">
				SELECT 	MAX(MASTER_ALT_PLAN_ID) AS MASTER_ALT_PLAN_ID
				FROM   	EZGI_MASTER_ALT_PLAN
			</cfquery>
            <cfset max_master_alt_plan_id = get_max_id.MASTER_ALT_PLAN_ID>
        	<cfquery name="get_related_sablon" datasource="#dsn3#">
            	SELECT     
                	EMPS.PROCESS_ID, 
                    EMPS.PAPER_NO, 
                    RTRIM(EMPS.PAPER_SERIOUS) PAPER_SERIOUS, 
                    EMPS.SIRA, 
                    EMPS.UP_WORKSTATION_ID, 
                    EMPS.UP_WORKSTATION_TIME, 
                    EMPS.CURRENT_POINT
				FROM         
                	EZGI_MASTER_PLAN AS EMP INNER JOIN
                    EZGI_MASTER_PLAN_SABLON AS EMPS ON EMP.MASTER_PLAN_CAT_ID = EMPS.SHIFT_ID
				WHERE     
                	EMP.MASTER_PLAN_ID = #master_plan_id# AND 
                    EMPS.PROCESS_ID IN
                          			(
                                    SELECT     
                                    	PROCESS_ID
                            		FROM          
                                    	EZGI_MASTER_PLAN_SABLON AS EMPS_1
                            		WHERE      
                                    	SHIFT_ID = EMP.MASTER_PLAN_CAT_ID AND 
                                        SIRA >	(
                                        		SELECT     
                                                	SIRA
                                              	FROM          
                                                	EZGI_MASTER_PLAN_SABLON AS EMPS_2
                                               	WHERE      
                                                	PROCESS_ID = #islem_id#
                                               	) AND 
                             			STATUS_ID = 1
                                   	)
            
            </cfquery>
            <cfif get_related_sablon.recordcount>
                <cfloop query="get_related_sablon">
            		<cfset _paper_number = get_related_sablon.paper_serious&get_related_sablon.paper_no>	
            		<cfquery name="add_master_alt_plans" datasource="#dsn3#">
                        INSERT INTO EZGI_MASTER_ALT_PLAN
                                (
                                MASTER_PLAN_ID, 
                                MASTER_ALT_PLAN_NO, 
                                PROCESS_ID, 
                                MASTER_ALT_PLAN_STAGE, 
                                IS_STOCK_FIS, 
                                RECORD_EMP, 
                                RECORD_DATE, 
                                RECORD_IP,
                                PLAN_START_DATE,
                                PLAN_FINISH_DATE,
                                PLAN_DETAIL,
                                PLAN_POINT,
                                PLAN_TYPE,
                                RELATED_MASTER_ALT_PLAN_ID,
                                IS_RESERVED
                                )
                        VALUES	
                                (
                                #master_plan_id#,
                                '#_paper_number#',
                                #get_related_sablon.PROCESS_ID#,
                                #process_stage#,
                                0,
                                #session.ep.userid#,
                                #now()#,
                                '#cgi.remote_addr#',
                                #attributes.master_alt_plan_start_date#,
                                #attributes.master_alt_plan_finish_date#,
                                <cfif len(reference_no)>'#reference_no#'<cfelse>NULL</cfif>,
                                #get_related_sablon.CURRENT_POINT#,
                                #attributes.plan_type#,
                                #max_master_alt_plan_id#,
                                <cfif isdefined('attributes.is_stock_reserve') and len(attributes.is_stock_reserve)>1<cfelse>0</cfif>
                                )
                    </cfquery>
                    <cfquery name="UPD_PAPERS" datasource="#dsn3#">
                        UPDATE	
                        	EZGI_MASTER_PLAN_SABLON
                        SET 	
                        	PAPER_NO = PAPER_NO+1 
                        WHERE   
                        	PROCESS_ID = #get_related_sablon.PROCESS_ID#
                    </cfquery>
            	</cfloop>
            </cfif>
		</cfif>	
	</cflock>
</cftransaction>
<cfif isdefined('attributes.master_alt_plan_id') and attributes.master_alt_plan_id gt 0>
	<cflocation url="#request.self#?fuseaction=prod.upd_ezgi_master_sub_plan_manual&master_plan_id=#attributes.master_plan_id#&master_alt_plan_id=#attributes.master_alt_plan_id#&islem_id= #attributes.islem_id#" addtoken="no">
<cfelse>
	<cflocation url="#request.self#?fuseaction=prod.upd_ezgi_master_sub_plan_manual&master_plan_id=#master_plan_id#&master_alt_plan_id=#get_max_id.master_alt_plan_id#&islem_id= #islem_id#" addtoken="no">
</cfif>