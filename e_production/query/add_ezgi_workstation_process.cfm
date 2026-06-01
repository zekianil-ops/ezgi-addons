<cfif not isdefined("attributes.cc_emp_ids") or not len(attributes.cc_emp_ids)>
	<script>
    	alert("<cf_get_lang_main no='782.Zorunlu Alan'> <cf_get_lang_main no='157.Görevli'>");
		window.location.href="<cfoutput>#request.self#</cfoutput>?fuseaction=prod.list_workstation&event=add";
    </script>
<cfelse>
	<cfset employee_list=",#listdeleteduplicates(attributes.cc_emp_ids,'numeric','ASC',',')#,">
	<cfquery name="ADD_WORKSTATION" datasource="#DSN3#">
		INSERT INTO
			WORKSTATIONS
		(
			IS_CAPACITY,
			UP_STATION,
			STATION_NAME,
			BRANCH,
			DEPARTMENT,
			ENERGY,
			EMP_ID,
			OUTSOURCE_PARTNER,
			COMMENT,
			ACTIVE,
			COST,
			COST_MONEY,
			EMPLOYEE_NUMBER,
			SET_PERIOD_HOUR,
			SET_PERIOD_MINUTE,
			AVG_CAPACITY_DAY,
			AVG_CAPACITY_HOUR,
			BASIC_INPUT_ID,
			EXIT_DEP_ID,
			EXIT_LOC_ID,
			ENTER_DEP_ID,
			ENTER_LOC_ID,
			PRODUCTION_DEP_ID,
			PRODUCTION_LOC_ID,
			WIDTH,
			LENGTH,
			HEIGHT,
            EZGI_SETUP_TIME,
            EZGI_KATSAYI,
            EZGI_PACKAGE_CONTROL,
          	EZGI_ORDER_CONTROL,
            PREVIOUS_OPERATION_END_CONTROL,
        	OUTER_EDGE_TRIMMING_ALLOWANCE,
    		CIRCLE_TESTRE_THICKNESS,
       		MAXIMUM_NUMBER_OF_CUTS,
       		CUTTING_METHOD,
      		MAXIMUM_DIFFERENT_CUTS,
        	CUTTING_STARTING_DIRECTION,
			RECORD_EMP,
			RECORD_DATE,
			RECORD_IP
		)
		VALUES
		(
			<cfif isdefined("attributes.is_capacity")><cfqueryparam value = "1" CFSQLType = "cf_sql_bit"><cfelse><cfqueryparam value = "0" CFSQLType = "cf_sql_bit"></cfif>,
			<cfif isdefined("attributes.up_station") and len(attributes.up_station)><cfqueryparam value = "#attributes.up_station#" CFSQLType = "cf_sql_varchar"><cfelse>NULL</cfif>,
			<cfqueryparam value = "#attributes.station_name#" CFSQLType = "cf_sql_varchar">,
			<cfqueryparam value = "#attributes.branch_id#" CFSQLType = "cf_sql_integer">,
			<cfqueryparam value = "#attributes.department_id#" CFSQLType = "cf_sql_integer">,
			<cfif isdefined('attributes.energy') and len(attributes.energy)>#attributes.energy#<cfelse>1</cfif>,
			<cfqueryparam value = "#employee_list#" CFSQLType = "cf_sql_varchar">,
			<cfif len(attributes.partner_id)><cfqueryparam value = "#attributes.partner_id#" CFSQLType = "cf_sql_integer"><cfelse>NULL</cfif>,
			<cfif len(attributes.comment)><cfqueryparam value = "#attributes.comment#" CFSQLType = "cf_sql_varchar"><cfelse>NULL</cfif>,
			<cfif isdefined("attributes.active")><cfqueryparam value = "1" CFSQLType = "cf_sql_bit"><cfelse><cfqueryparam value = "0" CFSQLType = "cf_sql_bit"></cfif>,
			<cfif len(attributes.cost)>#filternum(attributes.cost,4)#<cfelse>1</cfif>,
			<cfif len(attributes.cost_money)><cfqueryparam value = "#attributes.cost_money#" CFSQLType = "cf_sql_varchar"><cfelse><cfqueryparam value = "#session.ep.money#" CFSQLType = "cf_sql_varchar"></cfif>,
			<cfif len(attributes.employee_number)><cfqueryparam value = "#attributes.employee_number#" CFSQLType = "cf_sql_integer"><cfelse>NULL</cfif>,
			<cfif len(attributes.setting_period_hour)><cfqueryparam value = "#attributes.setting_period_hour#" CFSQLType = "cf_sql_integer"><cfelse>NULL</cfif>,
			<cfif len(attributes.setting_period_minute)><cfqueryparam value = "#attributes.setting_period_minute#" CFSQLType = "cf_sql_integer"><cfelse>NULL</cfif>,
			<cfif isdefined('attributes.avg_capacity_day') and len(attributes.avg_capacity_day)>#attributes.avg_capacity_day#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.avg_capacity_hour') and len(attributes.avg_capacity_hour)>#attributes.avg_capacity_hour#<cfelse>NULL</cfif>,
			<cfif isdefined("attributes.basic_type") and len(attributes.basic_type)><cfqueryparam value = "#attributes.basic_type#" CFSQLType = "cf_sql_integer"><cfelse>NULL</cfif>,
			<cfif len(attributes.exit_department) and len(attributes.exit_department_id)><cfqueryparam value = "#attributes.exit_department_id#" CFSQLType = "cf_sql_integer"><cfelse>NULL</cfif>,
			<cfif len(attributes.exit_department) and len(attributes.exit_location_id)><cfqueryparam value = "#attributes.exit_location_id#" CFSQLType = "cf_sql_integer"><cfelse>NULL</cfif>,
			<cfif len(attributes.enter_department) and len(attributes.enter_department_id)><cfqueryparam value = "#attributes.enter_department_id#" CFSQLType = "cf_sql_integer"><cfelse>NULL</cfif>,
			<cfif len(attributes.enter_department) and len(attributes.enter_location_id)><cfqueryparam value = "#attributes.enter_location_id#" CFSQLType = "cf_sql_integer"><cfelse>NULL</cfif>,
			<cfif len(attributes.production_department) and len(attributes.production_department_id)><cfqueryparam value = "#attributes.production_department_id#" CFSQLType = "cf_sql_integer"><cfelse>NULL</cfif>,
			<cfif len(attributes.production_department) and len(attributes.production_location_id)><cfqueryparam value = "#attributes.production_location_id#" CFSQLType = "cf_sql_integer"><cfelse>NULL</cfif>,
			<cfif len(attributes.width)><cfqueryparam value = "#attributes.width#" CFSQLType = "cf_sql_float"><cfelse>NULL</cfif>,
			<cfif len(attributes.length)><cfqueryparam value = "#attributes.length#" CFSQLType = "cf_sql_float"><cfelse>NULL</cfif>,
			<cfif len(attributes.height)><cfqueryparam value = "#attributes.height#" CFSQLType = "cf_sql_float"><cfelse>NULL</cfif>,
          	<cfif isdefined("attributes.ezgi_setup_time") and len(attributes.ezgi_setup_time)>#filternum(attributes.ezgi_setup_time,0)#<cfelse>0</cfif>,
          	<cfif isdefined("attributes.ezgi_katsayi") and len(attributes.ezgi_katsayi)>#filternum(attributes.ezgi_katsayi,2)#<cfelse>0</cfif>,
        	<cfif isdefined("attributes.ezgi_package_control") and len(attributes.ezgi_package_control)>#attributes.ezgi_package_control#<cfelse>0</cfif>,
          	<cfif isdefined("attributes.ezgi_order_control") and len(attributes.ezgi_order_control)>#attributes.ezgi_order_control#<cfelse>0</cfif>,
           	<cfif isdefined("attributes.previous_operation_end_control") and len(attributes.previous_operation_end_control)>#attributes.previous_operation_end_control#<cfelse>0</cfif>,
        	<cfif isdefined("attributes.trimming") and len(attributes.trimming)>#Filternum(attributes.trimming,1)#<cfelse>0</cfif>,
    		<cfif isdefined("attributes.thickness") and len(attributes.thickness)>#Filternum(attributes.thickness,1)#<cfelse>0</cfif>,
       		<cfif isdefined("attributes.max_number") and len(attributes.max_number)>#attributes.max_number#<cfelse>1</cfif>,
       		<cfif isdefined("attributes.cutting_method") and len(attributes.cutting_method)>#attributes.cutting_method#<cfelse>1</cfif>,
      		<cfif isdefined("attributes.max_different_cuts") and len(attributes.max_different_cuts)>#attributes.max_different_cuts#<cfelse>999</cfif>,
        	<cfif isdefined("attributes.cutting_direction") and len(attributes.cutting_direction)>#attributes.cutting_direction#<cfelse>1</cfif>,
			<cfqueryparam value = "#session.ep.userid#" CFSQLType = "cf_sql_integer">,
			<cfqueryparam value = "#now()#" CFSQLType = "cf_sql_timestamp">,
			<cfqueryparam value = "#cgi.remote_addr#" CFSQLType = "cf_sql_varchar">		
		)
	</cfquery> 
    <cfquery name="get_max_workstation"  datasource="#DSN3#">
    	SELECT MAX(STATION_ID) AS MAX_ID FROM WORKSTATIONS
    </cfquery>
	<script type="text/javascript">
	  	window.location.href="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_workstation&event=upd&station_id=#get_max_workstation.MAX_ID#</cfoutput>";
    </script>
</cfif>
 

