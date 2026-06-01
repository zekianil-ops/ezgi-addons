<!---
    File: setup_ezgi_master_plan_general_default_defination.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfset attributes.start_date = DateFormat(now(),dateformat_style)>
<cf_date tarih = "attributes.start_date">
<cfset attributes.start_date = dateadd("n",attributes.start_m,dateadd("h",attributes.start_h ,attributes.start_date))>

<cfset attributes.finish_date = DateFormat(now(),dateformat_style)>
<cf_date tarih = "attributes.finish_date">
<cfset attributes.finish_date = dateadd("n",attributes.finish_m,dateadd("h",attributes.finish_h ,attributes.finish_date))>

<cfset worktime = DateDiff('s',attributes.start_date,attributes.finish_date)>

<cflock timeout="90">
	<cftransaction>
    	<cfquery name="get_shift" datasource="#dsn3#">
        	SELECT SHIFT_NAME FROM #dsn_alias#.SETUP_SHIFTS WHERE SHIFT_ID = #attributes.shift_id#
        </cfquery>
        <cfquery name="get_defaults" datasource="#dsn3#">
            SELECT * FROM EZGI_MASTER_PLAN_DEFAULTS WHERE SHIFT_ID = #attributes.shift_id#
        </cfquery>
        <cfif get_defaults.recordcount>
        	<cfquery name="upd_defaults" datasource="#dsn3#">
            	UPDATE   
                	EZGI_MASTER_PLAN_DEFAULTS
				SET                
                	DEFAULT_RAW_STORE_ID = #attributes.raw_department_id#, 
                    DEFAULT_RAW_LOC_ID = #attributes.raw_location_id#, 
                    DEFAULT_PRODUCTION_STORE_ID = #attributes.pro_department_id#, 
                    DEFAULT_PRODUCTION_LOC_ID = #attributes.pro_location_id#,  
                    POINT_METHOD = #attributes.point_method#, 
                    CONTROL_METHOD = #attributes.control_method#,  
                    TRACE_METHOD = #attributes.trace_method#,
                    FABRIC_CAT = '#attributes.cat#',
                    START_DATE = #attributes.start_date#, 
                    FINISH_DATE = #attributes.finish_date#, 
                    WORK_TIME = <cfif len(worktime) and worktime gt 0>#worktime#<cfelse>0</cfif> 
				WHERE        
                	SHIFT_ID = #attributes.shift_id#
            </cfquery>
            <cfquery name="upd_main_row" datasource="#dsn3#">
            	UPDATE
                	EZGI_MASTER_PLAN_SABLON
               	SET       
                    PAPER_SERIOUS = '#attributes.paper_serious#',
                    PAPER_NO = #attributes.paper_no#,
                    PAPER_NO_LENGTH = #Len(attributes.paper_no)#,
                    MENU_HEAD = '#get_shift.SHIFT_NAME#'
				WHERE        
                	STATUS_ID = 0 AND 
                    SHIFT_ID = #attributes.shift_id#
            </cfquery>
        <cfelse>
        	<cfquery name="add_defaults" datasource="#dsn3#">
            	INSERT INTO 
                	EZGI_MASTER_PLAN_DEFAULTS
                    (
                    	SHIFT_ID,
                    	DEFAULT_RAW_STORE_ID, 
                        DEFAULT_RAW_LOC_ID, 
                        DEFAULT_PRODUCTION_STORE_ID, 
                        DEFAULT_PRODUCTION_LOC_ID, 
                        POINT_METHOD, 
                        CONTROL_METHOD, 
                        FABRIC_CAT,
                        START_DATE, 
                    	FINISH_DATE, 
                    	WORK_TIME 
                 	)
				VALUES        
                	(
                    	#attributes.shift_id#,
                    	#attributes.raw_department_id#,
                        #attributes.raw_location_id#, 
                        #attributes.pro_department_id#,
                        #attributes.pro_location_id#,
                        #attributes.point_method#,
                        #attributes.control_method#, 
                        '#attributes.cat#',
                        #attributes.start_date#,
                        #attributes.finish_date#,
                        <cfif len(worktime) and worktime gt 0>#worktime#<cfelse>0</cfif>
                   	)
            </cfquery>
            <cfquery name="add_main_row" datasource="#dsn3#">
            	INSERT INTO 
                	EZGI_MASTER_PLAN_SABLON
                	(
                    	PROCESS_NAME, 
                        PAPER_SERIOUS, 
                        PAPER_NO, 
                        PAPER_NO_LENGTH, 
                        SHIFT_ID, 
                        WORKSTATION_ID, 
                        STATUS_ID, 
                        MENU_HEAD, 
                      	TOPLU_P_ORDERS, 
                        SIRA, 
                        CURRENT_POINT, 
                        UP_WORKSTATION_ID, 
                        UP_WORKSTATION_TIME, 
                        P_ORDER_FREE, 
                        P_ORDER_FROM_ORDER, 
                        IS_GROUP, 
                        IS_COLLECT, 
                        IS_CONTROL, 
                        IS_MOVIE, 
                        TIMING_TYPE, 
                      	IS_DELETE,
                        FROM_UP_P_ORDER,
                      	FROM_DEMAND
                  	)
				VALUES        
                	(
                    	'Master',
                        '#attributes.paper_serious#',
                        #attributes.paper_no#,
                        #Len(attributes.paper_no)#,
                        #attributes.shift_id#,
                        0,
                        0,
                        '#get_shift.SHIFT_NAME#',
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0
                	)
			</cfquery>
        </cfif>
        <cfloop from="1" to="#attributes.record_num#" index="rn">
        	<cfif Evaluate('attributes.row_kontrol#rn#') eq 1><!--- Satır Silinmediyse--->
        		<cfif Evaluate('attributes.process_id#rn#') eq 0><!--- Yeni Satır İlave Edilmişse--->
                	<cfquery name="add_row" datasource="#dsn3#">
                    	INSERT INTO 
                            EZGI_MASTER_PLAN_SABLON
                            (
                                PROCESS_NAME, 
                                PAPER_SERIOUS, 
                                PAPER_NO, 
                                PAPER_NO_LENGTH, 
                                SHIFT_ID, 
                                WORKSTATION_ID, 
                                STATUS_ID, 
                                MENU_HEAD, 
                                TOPLU_P_ORDERS, 
                                SIRA, 
                                CURRENT_POINT, 
                                UP_WORKSTATION_ID, 
                                UP_WORKSTATION_TIME, 
                                P_ORDER_FREE, 
                                P_ORDER_FROM_ORDER, 
                                IS_GROUP, 
                                IS_COLLECT, 
                                IS_CONTROL, 
                                IS_MOVIE, 
                                TIMING_TYPE, 
                                IS_DELETE,
                                FROM_UP_P_ORDER,
                                FROM_DEMAND
                            )
                        VALUES        
                            (
                              	'#Evaluate("attributes.PROCESS_NAME#rn#")#',
                               	'#Evaluate("attributes.paper_serious#rn#")#',
                                #Evaluate('attributes.paper_no#rn#')#,
                                #Len(Evaluate('attributes.paper_no#rn#'))#,
                                #attributes.shift_id#,
                                #Evaluate('attributes.WORKSTATION_ID#rn#')#,
                                1,
                                '#Evaluate('attributes.SUB_PLAN_HEAD#rn#')#',
                                <cfif isdefined('attributes.TOPLU_P_ORDERS#rn#')>1<cfelse>0</cfif>,
                                #Evaluate('attributes.sira#rn#')#,
                                #Evaluate('attributes.CURRENT_POINT#rn#')#,
                                <cfif Len(Evaluate('attributes.UP_WORKSTATION_ID#rn#'))>#Evaluate('attributes.UP_WORKSTATION_ID#rn#')#<cfelse>NULL</cfif>,
                                <cfif Len(Evaluate('attributes.UP_WORKSTATION_TIME#rn#'))>#Evaluate('attributes.UP_WORKSTATION_TIME#rn#')#<cfelse>NULL</cfif>,
                                <cfif isdefined('attributes.P_ORDER_FREE#rn#')>1<cfelse>0</cfif>,
                                <cfif isdefined('attributes.P_ORDER_FROM_ORDER#rn#')>1<cfelse>0</cfif>,
                                <cfif isdefined('attributes.IS_GROUP#rn#')>1<cfelse>0</cfif>,
                                <cfif isdefined('attributes.IS_COLLECT#rn#')>1<cfelse>0</cfif>,
                                <cfif isdefined('attributes.IS_CONTROL#rn#')>1<cfelse>0</cfif>,
                                <cfif isdefined('attributes.IS_MOVIE#rn#')>1<cfelse>0</cfif>,
                                #Evaluate('attributes.TIMING_TYPE#rn#')#,
                                <cfif isdefined('attributes.IS_DELETE#rn#')>1<cfelse>0</cfif>,
                                <cfif isdefined('attributes.FROM_UP_P_ORDER#rn#')>1<cfelse>0</cfif>,
                                <cfif isdefined('attributes.FROM_DEMAND#rn#')>1<cfelse>0</cfif>
                            )
                   </cfquery> 
              	<cfelse> <!--- Eski Satır İse--->
                	<cfquery name="upd_row" datasource="#dsn3#">
                    	UPDATE
                        	EZGI_MASTER_PLAN_SABLON
                      	SET
                        	PROCESS_NAME = '#Evaluate("attributes.PROCESS_NAME#rn#")#',
                         	PAPER_SERIOUS = '#Evaluate("attributes.paper_serious#rn#")#',
                           	PAPER_NO = #Evaluate('attributes.paper_no#rn#')#,
                            PAPER_NO_LENGTH = #Len(Evaluate('attributes.paper_no#rn#'))#,
                          	WORKSTATION_ID = #Evaluate('attributes.WORKSTATION_ID#rn#')#,
                            MENU_HEAD = '#Evaluate('attributes.SUB_PLAN_HEAD#rn#')#',
                          	TOPLU_P_ORDERS = <cfif isdefined('attributes.TOPLU_P_ORDERS#rn#')>1<cfelse>0</cfif>,
                           	SIRA = #Evaluate('attributes.sira#rn#')#,
                        	CURRENT_POINT = #Evaluate('attributes.CURRENT_POINT#rn#')#,
                          	UP_WORKSTATION_ID = <cfif Len(Evaluate('attributes.UP_WORKSTATION_ID#rn#'))>#Evaluate('attributes.UP_WORKSTATION_ID#rn#')#<cfelse>NULL</cfif>,
                          	UP_WORKSTATION_TIME = <cfif Len(Evaluate('attributes.UP_WORKSTATION_TIME#rn#'))>#Evaluate('attributes.UP_WORKSTATION_TIME#rn#')#<cfelse>NULL</cfif>,
                           	P_ORDER_FREE = <cfif isdefined('attributes.P_ORDER_FREE#rn#')>1<cfelse>0</cfif>,
                          	P_ORDER_FROM_ORDER = <cfif isdefined('attributes.P_ORDER_FROM_ORDER#rn#')>1<cfelse>0</cfif>,
                         	IS_GROUP = <cfif isdefined('attributes.IS_GROUP#rn#')>1<cfelse>0</cfif>,
                          	IS_COLLECT = <cfif isdefined('attributes.IS_COLLECT#rn#')>1<cfelse>0</cfif>,
                          	IS_CONTROL = <cfif isdefined('attributes.IS_CONTROL#rn#')>1<cfelse>0</cfif>,
                          	IS_MOVIE = <cfif isdefined('attributes.IS_MOVIE#rn#')>1<cfelse>0</cfif>,
                           	TIMING_TYPE = #Evaluate('attributes.TIMING_TYPE#rn#')#,
                         	IS_DELETE = <cfif isdefined('attributes.IS_DELETE#rn#')>1<cfelse>0</cfif>,
                            FROM_UP_P_ORDER = <cfif isdefined('attributes.FROM_UP_P_ORDER#rn#')>1<cfelse>0</cfif>,
                          	FROM_DEMAND = <cfif isdefined('attributes.FROM_DEMAND#rn#')>1<cfelse>0</cfif>
                       	WHERE        
                        	SHIFT_ID = #attributes.shift_id# AND 
                            PROCESS_ID = #Evaluate('attributes.process_id#rn#')#
                   </cfquery> 
                </cfif>
          	<cfelse> <!--- Satır Silindiyse--->
              	<cfquery name="del_row" datasource="#dsn3#">
                    DELETE FROM EZGI_MASTER_PLAN_SABLON WHERE SHIFT_ID = #attributes.shift_id# AND PROCESS_ID = #Evaluate('attributes.process_id#rn#')#
             	</cfquery> 
        	</cfif>
        </cfloop>
	</cftransaction>
</cflock>
<cflocation url="#request.self#?fuseaction=prod.setup_ezgi_master_plan_general_default_defination&shift_id=#attributes.shift_id#" addtoken="No">