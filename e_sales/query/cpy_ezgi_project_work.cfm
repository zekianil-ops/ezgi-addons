<cfif attributes.import_type eq 1>
    <cfquery name="GET_COMPANY" datasource="#DSN#">
        SELECT
            COMPANY_ID,
            PARTNER_ID
        FROM
            PRO_PROJECTS
        WHERE
            PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.main_project_id#">
    </cfquery>
    <!---<cfdump var="#attributes#"><cfabort>--->
    <cfset with_related_work = ''>
    <cflock timeout="60">
        <cftransaction>
            <cfquery name="GET_TEMP_TABLE" datasource="#DSN#">
                IF object_id('tempdb..#chr(35)#WORK_ID_HISTORY') IS NOT NULL
                   BEGIN
                    DROP TABLE #chr(35)#WORK_ID_HISTORY 
                   END
            </cfquery>
            <cfquery name="CRT_TEMP_TABLE" datasource="#DSN#">
                CREATE TABLE #chr(35)#WORK_ID_HISTORY 
                ( 
                    PREVIOUS_WORK_ID	int,
                    AFTER_WORK_ID	int
                )
            </cfquery>
            <cfloop from="1" to="#attributes.record_num#" index="i">
                <cfif IsDefined("attributes.work_select#i#")>
                    <cfif isdefined("attributes.copy_cc#i#")>
                        <cfset form_copy_cc = evaluate("attributes.copy_cc#i#")>
                    <cfelse>
                        <cfset form_copy_cc = 0>
                    </cfif>
                    <cfscript>
                        form_pro_work_cat = evaluate("attributes.pro_work_cat#i#");
                        form_special_defination_id = evaluate("attributes.special_defination_id#i#");
                        form_project_emp_id = evaluate("attributes.project_emp_id#i#");
                        form_task_company_id = evaluate("attributes.task_company_id#i#");
                        form_task_partner_id = evaluate("attributes.task_partner_id#i#");
                        form_work_head = evaluate("attributes.work_head#i#");
                        form_work_id = evaluate("attributes.work_id#i#");
                        form_related_work_id = evaluate("attributes.related_work_id#i#");
                        form_work_currency_id=evaluate("attributes.work_currency_id#i#");
                        form_work_h_start = evaluate("attributes.work_h_start#i#");
                        form_work_h_finish = evaluate("attributes.work_h_finish#i#");
                        form_priority_cat = evaluate("attributes.priority_cat#i#");	
                        form_our_company_id = evaluate("attributes.our_company_id#i#");
                        form_purchase_contract_amount = evaluate("attributes.purchase_contract_amount#i#");
                        form_sale_contract_amount = evaluate("attributes.fiyat_#i#");
                        form_sale_miktar = evaluate("attributes.miktar_#i#");
                        form_workgroup_id = evaluate("attributes.workgroup_id_#i#");
                    </cfscript>
    
                    <cf_date tarih="form_work_h_start">
                    <cf_date tarih="form_work_h_finish"> 
                    <cfquery name="GET_LAST_HISTORY" datasource="#DSN#" maxrows="1">
                        SELECT
                            WORK_DETAIL
                        FROM
                            PRO_WORKS_HISTORY
                        WHERE
                            WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form_work_id#">
                        ORDER BY 
                            HISTORY_ID		
                    </cfquery>		
                    <cfquery name="ADD_WORK" datasource="#DSN#">
                        INSERT INTO
                            PRO_WORKS
                            (
                                WORK_CAT_ID,
                                SPECIAL_DEFINITION_ID,
                                PROJECT_ID,
                                RELATED_WORK_ID,					
                                <cfif len(form_project_emp_id)>
                                    PROJECT_EMP_ID,
                                    OUTSRC_CMP_ID,
                                    OUTSRC_PARTNER_ID,
                                <cfelseif len(form_task_company_id)>
                                    PROJECT_EMP_ID,
                                    OUTSRC_CMP_ID,
                                    OUTSRC_PARTNER_ID,
                                </cfif>
                                COMPANY_ID,
                                COMPANY_PARTNER_ID,
                                WORK_HEAD,
                                WORK_DETAIL,
                                TARGET_START,
                                TARGET_FINISH,
                                RECORD_AUTHOR,
                                WORK_CURRENCY_ID,
                                WORK_PRIORITY_ID,
                                RECORD_DATE,
                                RECORD_IP,
                                WORK_STATUS,
                                OUR_COMPANY_ID,
                                PURCHASE_CONTRACT_AMOUNT,
                                IS_MILESTONE,
                                SALE_CONTRACT_AMOUNT,
    
                                WORKGROUP_ID,
                                AVERAGE_AMOUNT_UNIT,
                                AVERAGE_AMOUNT,
                                EXPECTED_BUDGET,
                                EXPECTED_BUDGET_MONEY
                            )
                            VALUES
                            (
                                #form_pro_work_cat#,
                                #form_special_defination_id#,
                                #attributes.main_project_id#,
                                NULL,
                                <cfif len(form_project_emp_id)>
                                    #form_project_emp_id#,
                                    NULL,
                                    NULL,
                                <cfelseif len(form_task_company_id)>
                                    NULL,
                                    #form_task_company_id#,
                                    <cfif len(form_task_partner_id)>#form_task_partner_id#<cfelse>NULL</cfif>,
                                </cfif>
                                <cfif len(get_company.company_id)>#get_company.company_id#<cfelse>NULL</cfif>,
                                <cfif len(get_company.partner_id)>#get_company.partner_id#<cfelse>NULL</cfif>,
                                '#form_work_head#',
                                '#get_last_history.work_detail#',
                                #form_work_h_start#,
                                #form_work_h_finish#,
                                #session.ep.userid#,
                                <cfif len(form_work_currency_id)>#form_work_currency_id#<cfelse>NULL</cfif>,<!--- #get_process_type.process_row_id#, --->
                                #form_priority_cat#,
                                #now()#,
                                '#cgi.remote_addr#',
                                1,
                                <cfif len(form_our_company_id)>#form_our_company_id#<cfelse>NULL</cfif>,
                                <cfif len(form_purchase_contract_amount)>#form_purchase_contract_amount#<cfelse>NULL</cfif>,
                                0,
                                <cfif len(form_sale_contract_amount)>#FilterNum(form_sale_contract_amount,2)#<cfelse>NULL</cfif>,
                                <cfif len(form_workgroup_id)>#form_workgroup_id#<cfelse>NULL</cfif>,
                                1,
                                <cfif len(form_sale_miktar)>#FilterNum(form_sale_miktar,2)#<cfelse>NULL</cfif>,
                                <cfif len(form_sale_miktar) and len(form_sale_contract_amount)>#FilterNum(form_sale_miktar,2)*FilterNum(form_sale_contract_amount,2)#<cfelse>NULL</cfif>,
                                <cfif len(form_sale_miktar) and len(form_sale_contract_amount)>'#session.ep.money#'<cfelse>NULL</cfif>
                                
                            )
                            SELECT SCOPE_IDENTITY() AS MAX_WORK_ID
                    </cfquery>
                    <cfquery name="CRT_TEMP_TABLE" datasource="#DSN#">
                        INSERT INTO #chr(35)#WORK_ID_HISTORY (PREVIOUS_WORK_ID,AFTER_WORK_ID) VALUES (#form_work_id#,#add_work.max_work_id#)
                    </cfquery>
                    <cfset new_work_id = add_work.max_work_id>		
                    <cfset task_user_email=''>
                    
                    <cfif len(form_project_emp_id)>
                        <cfset attributes.project_emp_id = form_project_emp_id>
                        <cfinclude template="/V16/PROJECT/query/get_work_pos.cfm">
                        <cfset task_user_email=get_pos.employee_email>				
                    <cfelseif len(form_task_partner_id)>
                        <cfset form.task_partner_id = form_task_partner_id>
                        <cfinclude template="/V16/PROJECT/query/get_work_partner.cfm">
                        <cfset task_user_email=get_work_partner.company_partner_email>
                    </cfif>
                    <cfquery name="ADD_WORK_HISTORY" datasource="#DSN#">
                        INSERT INTO
                            PRO_WORKS_HISTORY
                            (
                                WORK_CAT_ID,
                                WORK_ID,
                                WORK_HEAD,
                                WORK_DETAIL,
                                <cfif len(form_project_emp_id)>
                                    PROJECT_EMP_ID,
                                    OUTSRC_CMP_ID,
                                    OUTSRC_PARTNER_ID,
                                <cfelseif len(form_task_company_id)>
                                    PROJECT_EMP_ID,
                                    OUTSRC_CMP_ID,
                                    OUTSRC_PARTNER_ID,
                                </cfif>				
                                PROJECT_ID,
                                COMPANY_ID,
                                COMPANY_PARTNER_ID,
                                TARGET_START,
                                TARGET_FINISH,
                                WORK_CURRENCY_ID,
                                WORK_PRIORITY_ID,
                                UPDATE_DATE,
                                UPDATE_AUTHOR
                            )
                            VALUES
                            (
                                #form_pro_work_cat#,
                                #add_work.max_work_id#,
                                '#form_work_head#',
                                '#get_last_history.work_detail#',
                                <cfif len(form_project_emp_id)>
                                    #form_project_emp_id#,
                                    NULL,
                                    NULL,
                                <cfelseif len(form_task_company_id)>
                                    NULL,
                                    #form_task_company_id#,
                                    <cfif len(form_task_partner_id)>#form_task_partner_id#<cfelse>NULL</cfif>,
                                </cfif>
                                    #attributes.main_project_id#,
                                <cfif len(get_company.company_id)>#get_company.company_id#<cfelse>NULL</cfif>,
                                <cfif len(get_company.partner_id)>#get_company.partner_id#<cfelse>NULL</cfif>,					
                                #form_work_h_start#,
                                #form_work_h_finish#,
                                <cfif len(form_work_currency_id)>#form_work_currency_id#<cfelse>NULL</cfif>,
                                #form_priority_cat#,
                                #now()#,
                                #session.ep.userid#
                            )
                    </cfquery>
                    
                    <cfif form_copy_cc neq 0>
                        <cfquery name="GET_WORK_CC" datasource="#DSN#">
                            SELECT * FROM PRO_WORKS_CC WHERE WORK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form_work_id#">
                        </cfquery>
                        <cfif get_work_cc.recordcount>
                            <cfquery name="INS_WORK_CC" datasource="#DSN#">
                                <cfloop query="get_work_cc">
                                    INSERT INTO 
                                        PRO_WORKS_CC
                                    (
                                        WORK_ID,
                                        CC_EMP_ID,
                                        CC_PAR_ID
                                    )
                                    VALUES
                                    (
                                        #add_work.max_work_id#,
                                        <cfif len(get_work_cc.cc_emp_id)>#get_work_cc.cc_emp_id#<cfelse>NULL</cfif>,
                                        <cfif len(get_work_cc.cc_par_id)>#get_work_cc.cc_par_id#<cfelse>NULL</cfif>
                                    )
                                </cfloop>
                            </cfquery>
                        </cfif>
                    </cfif>
                    <cfquery name="get_pro_work_material" datasource="#dsn#">
                        SELECT PRO_MATERIAL_ID FROM PRO_MATERIAL WHERE WORK_ID = #Evaluate('attributes.WORK_ID#i#')#
                    </cfquery>
                    <cfif get_pro_work_material.recordcount>
                        <cfloop query="get_pro_work_material">
                            <cfset attributes.wrk_row_id = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')# & #session.ep.company_id# & #currentrow#>
                            <cfquery name="cpy_pro_work_material" datasource="#dsn#" result="max_id">
                                INSERT INTO 
                                    PRO_MATERIAL
                                    (
                                        PRO_MATERIAL_NO, 
                                        ACTION_DATE, 
                                        PROJECT_ID, 
                                        COMPANY_ID, 
                                        PARTNER_ID, 
                                        WORK_ID, 
                                        DETAIL, 
                                        PLANNER_EMP_ID, 
                                        DISCOUNTTOTAL, 
                                        GROSSTOTAL, 
                                        NETTOTAL, 
                                        TAXTOTAL, 
                                        OTHER_MONEY, 
                                        OTHER_MONEY_VALUE, 
                                        RECORD_EMP,
                                        RECORD_DATE, 
                                        RECORD_IP,
                                        MATERIAL_STAGE
                                    )
                                SELECT     
                                    PRO_MATERIAL_NO, 
                                    #now()#, 
                                    #attributes.main_project_id#, 
                                    <cfif len(get_company.company_id)>#get_company.company_id#<cfelse>NULL</cfif>,
                                    <cfif len(get_company.partner_id)>#get_company.partner_id#<cfelse>NULL</cfif>,
                                    #add_work.max_work_id#,
                                    DETAIL, 
                                    #session.ep.userid#, 
                                    DISCOUNTTOTAL, 
                                    GROSSTOTAL, 
                                    NETTOTAL, 
                                    TAXTOTAL, 
                                    OTHER_MONEY, 
                                    OTHER_MONEY_VALUE, 
                                    #session.ep.userid#,
                                    #now()#,
                                    '#cgi.remote_addr#',
                                    MATERIAL_STAGE
                                FROM      
                                    PRO_MATERIAL
                                WHERE     
                                    PRO_MATERIAL_ID = #get_pro_work_material.PRO_MATERIAL_ID#
                            </cfquery>
                            <cfquery name="get_promax_id" datasource="#dsn#">
                                SELECT MAX(PRO_MATERIAL_ID) MAX_ID FROM PRO_MATERIAL
                            </cfquery>
                            <cfquery name="cpy_pro_work_material_money" datasource="#dsn#">
                                INSERT INTO 
                                    PRO_MATERIAL_MONEY
                                    (
                                        MONEY_TYPE, 
                                        ACTION_ID, 
                                        RATE2, 
                                        RATE1, 
                                        IS_SELECTED
                                    )
                                SELECT     
                                    MONEY_TYPE, 
                                    #get_promax_id.max_id#, 
                                    RATE2, 
                                    RATE1, 
                                    IS_SELECTED
                                FROM      
                                    PRO_MATERIAL_MONEY
                                WHERE     
                                    ACTION_ID = #get_pro_work_material.PRO_MATERIAL_ID#
                            </cfquery>
                            
                            <cfquery name="cpy_pro_work_material_row" datasource="#dsn#">
                                INSERT INTO 
                                    PRO_MATERIAL_ROW
                                    (
                                        PRO_MATERIAL_ID, 
                                        PRODUCT_ID, 
                                        STOCK_ID, 
                                        PRICE, 
                                        PRICE_OTHER, 
                                        AMOUNT, 
                                        UNIT, 
                                        UNIT_ID, 
                                        TAX, 
                                        PRODUCT_NAME, 
                                        SPECT_VAR_ID, 
                                        SPECT_VAR_NAME, 
                                        COST_PRICE, 
                                        MARGIN, 
                                        EXTRA_COST, 
                                        DISCOUNT1, 
                                        DISCOUNT2, 
                                        DISCOUNT3, 
                                        DISCOUNT4, 
                                        DISCOUNT5, 
                                        DISCOUNTTOTAL, 
                                        GROSSTOTAL, 
                                        NETTOTAL, 
                                        TAXTOTAL, 
                                        OTHER_MONEY, 
                                        OTHER_MONEY_VALUE, 
                                        PROM_COST, 
                                        DISCOUNT_COST, 
                                        IS_PROMOTION, 
                                        EXTRA_PRICE, 
                                        EXTRA_PRICE_TOTAL, 
                                        OTV_ORAN, 
                                        OTVTOTAL, 
                                        AMOUNT2, 
                                        EK_TUTAR_PRICE, 
                                        LIST_PRICE, 
                                        WRK_ROW_ID
                                    )
                                SELECT     
                                        #get_promax_id.max_id#,  
                                        PRODUCT_ID, 
                                        STOCK_ID, 
                                        PRICE, 
                                        PRICE_OTHER, 
                                        <cfif form_sale_miktar gt 0>
                                            AMOUNT*#FilterNum(form_sale_miktar,2)#
                                        <cfelse>
                                            AMOUNT
                                        </cfif>,
                                        UNIT, 
                                        UNIT_ID, 
                                        TAX, 
                                        PRODUCT_NAME, 
                                        SPECT_VAR_ID, 
                                        SPECT_VAR_NAME, 
                                        COST_PRICE, 
                                        MARGIN, 
                                        EXTRA_COST, 
                                        DISCOUNT1, 
                                        DISCOUNT2, 
                                        DISCOUNT3, 
                                        DISCOUNT4, 
                                        DISCOUNT5, 
                                        DISCOUNTTOTAL, 
                                        GROSSTOTAL, 
                                        NETTOTAL, 
                                        TAXTOTAL, 
                                        OTHER_MONEY, 
                                        OTHER_MONEY_VALUE, 
                                        PROM_COST, 
                                        DISCOUNT_COST, 
                                        IS_PROMOTION, 
                                        EXTRA_PRICE, 
                                        EXTRA_PRICE_TOTAL, 
                                        OTV_ORAN, 
                                        OTVTOTAL, 
                                        AMOUNT2, 
                                        EK_TUTAR_PRICE, 
                                        LIST_PRICE, 
                                        '#attributes.wrk_row_id#'
                                FROM        
                                    PRO_MATERIAL_ROW
                                WHERE     
                                    PRO_MATERIAL_ID = #get_pro_work_material.PRO_MATERIAL_ID#
                            </cfquery>
                        </cfloop>
                    </cfif>
                    <cfset attributes.work_head = form_work_head>
                    <cfif len(task_user_email) and isdefined("attributes.mail#i#")>
                        <cfset mail_type_id = 1> 
                        <cfset form.work_id = form_work_id>
                        <cfset attributes.work_head = form_work_head>
                        <cfset attributes.work_h_start = form_work_h_start>
                        <cfset attributes.work_h_finish = form_work_h_finish>
                        <cfset mail_emp_id = form_project_emp_id>
                        <cfset attributes.mail_content_from = '#session.ep.company#<#session.ep.company_email#>'>
                        <cfsavecontent variable="message">
                            <cfoutput><cf_get_lang no='362.iş kaydı'></cfoutput>
                        </cfsavecontent>
                        <cfsavecontent variable="additor">
                            <cfoutput>
                                <cfif isdefined('mail_emp_id') and len(mail_emp_id)>
                                    #get_emp_info(mail_emp_id,0,0)#
                                </cfif>
                            </cfoutput>
                        </cfsavecontent>
                        <cfsavecontent variable="subject_info"><cf_get_lang_main no="1728.Görevlendirme"></cfsavecontent>
                        <cfset attributes.mail_content_to = task_user_email>
                        <cfset attributes.mail_content_subject = subject_info & '! - ' & attributes.work_head>
                        <cfset attributes.mail_content_additor = additor>
                        <cfset attributes.mail_record_emp='#session.ep.name# #session.ep.surname#'>
                        <cfset attributes.mail_record_date=dateformat(dateadd('h',session.ep.time_zone,now()),dateformat_style) & " " & timeformat(dateadd('h',session.ep.time_zone,now()),timeformat_style)>
                        <cfset attributes.start_date= dateformat(date_add("h",session.ep.time_zone,attributes.work_h_start),dateformat_style) & " " & timeformat(date_add("h",session.ep.time_zone,attributes.work_h_start),timeformat_style) >
                        <cfset attributes.finish_date=dateformat(date_add("h",session.ep.time_zone,attributes.work_h_finish),dateformat_style) & " " & timeformat(date_add("h",session.ep.time_zone,attributes.work_h_finish),timeformat_style)>
                        <cfset attributes.mail_content_info2=get_last_history.work_detail>
                        <cfif len(attributes.project_id)>
                            <cfquery name="Get_Project_Head" datasource="#dsn#">
                                SELECT PROJECT_NUMBER, PROJECT_HEAD FROM #dsn_alias#.PRO_PROJECTS WHERE PROJECT_ID = #attributes.project_id#
                            </cfquery>
                            <cfset attributes.project_head='#Get_Project_Head.Project_Head#'>
                            <cfset attributes.project_id = attributes.project_id>
                        </cfif>
                        <cfsavecontent variable="attributes.mail_content_info"><cf_get_lang no='362.iş kaydı'></cfsavecontent>
                        <cfif len(mail_emp_id)>
                            <cfif cgi.server_port eq 443>
                                <cfset user_domain = "https://#cgi.server_name#">
                            <cfelse>
                                <cfset user_domain = "http://#cgi.server_name#">
                            </cfif>
                            <cfset attributes.mail_content_link = '#user_domain#/#request.self#?fuseaction=project.works&event=det&id=#form_work_id#'>
                        <cfelse>
                            <cfset attributes.mail_content_link = '#partner_domain##request.self#?fuseaction=project.works&event=det&id=#form_work_id#'>
                        </cfif>
                        <cfset attributes.mail_content_link_info = '#attributes.work_head#'>
                        <cfsavecontent variable="attributes.process_stage_info">
                            <cfoutput>
                                <cfif isdefined("attributes.work_process_stage")>#attributes.work_process_stage#<cfelseif isdefined("form_work_currency_id")>#form_work_currency_id#<cfelse>#attributes.process_stage#</cfif>
                            </cfoutput>
                        </cfsavecontent>
                        <cfinclude template="/design/template/info_mail/mail_content.cfm">
                    </cfif>
                    <cf_workcube_process
                    is_upd='1' 
                    old_process_line='0'
                    process_stage='#form_work_currency_id#' 
                    record_member='#session.ep.userid#' 
                    record_date='#now()#' 
                    action_table='PRO_WORKS'
                    action_column='WORK_ID'
                    action_id='#add_work.max_work_id#'
                    action_page='#request.self#?fuseaction=project.works&event=det&id=#add_work.max_work_id#' 
                    warning_description = 'İlgili İş : #attributes.work_head#'>
                </cfif>
            </cfloop>
        </cftransaction>
    </cflock>
<cfelse>
	<cfif attributes.record_num gt 0 and Listlen(attributes.pro_work_id_list) eq attributes.record_num>
        <cfloop from="1" to="#attributes.record_num#" index="i">
            <cfif IsDefined("attributes.work_select#i#")>
           		<cfset form_work_id = ListGetAt(attributes.pro_work_id_list,i)>
                <cfset form_sale_miktar = Evaluate("attributes.miktar_#i#")>
                <cfset form_sale_oran = Evaluate("attributes.oran_#i#")>
                <cftransaction>
                	<cfquery name="upd_pro_work" datasource="#dsn#">
                    	UPDATE    
                        	PRO_WORKS
						SET           
                        	COMPLETED_AMOUNT = #Filternum(form_sale_miktar,2)#, 
                            TO_COMPLETE = #Filternum(form_sale_oran,2)#
						WHERE     
                        	PROJECT_ID = #attributes.main_project_id# AND 
                            WORK_ID = #form_work_id#
                    </cfquery>
                </cftransaction>
            </cfif>
        </cfloop>
   	</cfif>
</cfif>
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
