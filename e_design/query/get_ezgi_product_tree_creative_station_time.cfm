<!---
    File: get_ezgi_product_tree_creative_station_time.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfquery name="get_default" datasource="#dsn3#">
	SELECT ISNULL(DEFAULT_PRODUCTION_AMOUNT,1) AS DEFAULT_PRODUCTION_AMOUNT, DEFAULT_IS_STATION_OR_IS_OPERATION FROM EZGI_DESIGN_DEFAULTS
</cfquery>
<cfquery name="get_money" datasource="#dsn3#">
	SELECT MONEY, RATE2 FROM #dsn_alias#.SETUP_MONEY
</cfquery>
<cfoutput query="get_money">
	<cfset 'RATE2_#MONEY#' = RATE2>
</cfoutput>
<cfquery name="get_station_time_calculate" datasource="#dsn3#">
	SELECT DISTINCT
    	EDOT.SIRA,     
    	EDOT.PIECE_TYPE, 
        EDOT.EMKTR, 
        EDOT.OMKTR, 
        EDOT.BOY, 
        EDOT.EN, 
        EDOT.ALAN, 
        EDOT.CEVRE, 
        EDOT.MMKTR, 
        EDOT.AMKTR, 
        EDOT.HSURE, 
      	EDOT.ISURE, 
        EDOT.KENAR1, 
        EDOT.KENAR2, 
        EDOT.KENAR3, 
        EDOT.KENAR4,
        EDOT.FORMUL, 
        ISNULL(W.EZGI_SETUP_TIME, 0) AS SSURE, 
        ISNULL(W.EZGI_KATSAYI,1) AS KATSAYI, 
        ISNULL(W.COST, 0) AS COST, 
        ISNULL(W.COST_MONEY,'#session.ep.money#') AS MONEY, 
        ISNULL(W.EMPLOYEE_NUMBER,1) AS EMPLOYEE_NUMBER,
        (SELECT TOP (1) PIECE_NAME FROM EZGI_DESIGN_PIECE WHERE PIECE_ROW_ID = EDOT.PIECE_ROW_ID) AS PIECE_NAME,
        <cfif get_default.DEFAULT_IS_STATION_OR_IS_OPERATION eq 1>
            W.STATION_ID, 
            W.STATION_NAME,
            '' AS STATION_CODE
        <cfelse>
            EDOT.OPERATION_TYPE AS STATION_NAME, 
            EDOT.OPERATION_TYPE_ID AS STATION_ID,
            (
            	SELECT        
                	OPERATION_CODE
				FROM            
                	OPERATION_TYPES
				WHERE        
                	OPERATION_TYPE_ID = EDOT.OPERATION_TYPE_ID
         	) AS STATION_CODE
        </cfif>
	FROM            
    	WORKSTATIONS AS W WITH (NOLOCK) INNER JOIN
    	(
        	SELECT        
            	OPERATION_TYPE_ID, 
                MIN(WS_ID) AS WS_ID
        	FROM            
            	WORKSTATIONS_PRODUCTS WITH (NOLOCK)
          	WHERE        
            	DEFAULT_STATUS = 1
        	GROUP BY 
            	OPERATION_TYPE_ID
         	HAVING         
            	OPERATION_TYPE_ID IS NOT NULL
    	) AS TBL ON W.STATION_ID = TBL.WS_ID RIGHT OUTER JOIN
   		EZGI_DESIGN_OPERATION_TIME AS EDOT ON TBL.OPERATION_TYPE_ID = EDOT.OPERATION_TYPE_ID
 	WHERE
    	1=1 
        <cfif isdefined('attributes.design_piece_row_id') and len(attributes.design_piece_row_id)>    
    		AND EDOT.PIECE_ROW_ID = #attributes.design_piece_row_id#
        <cfelseif isdefined('attributes.design_package_row_id') and len(attributes.design_package_row_id)>
        	AND EDOT.DESIGN_PACKAGE_ROW_ID = #attributes.design_package_row_id#
        <cfelseif isdefined('attributes.design_main_row_id') and len(attributes.design_main_row_id)>
        	AND EDOT.DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id# 
    	<cfelseif isdefined('attributes.design_id') and len(attributes.design_id)>
    		AND EDOT.DESIGN_ID = #attributes.design_id# 
		</cfif>
	ORDER BY 
    	EDOT.SIRA
</cfquery>
<cfif get_station_time_calculate.recordcount>
	<cfset station_time_cal = QueryNew("sira, amount, station_code, station_id, station_name, station_time, process_time, setup_time, employee_number, employee_time, station_cost, station_cost_money, katsayi", "Integer, VarChar, VarChar, Integer, VarChar, Decimal, Decimal, Decimal, Decimal, Integer, Decimal, VarChar, Decimal")>
    <cfloop query="get_station_time_calculate">
    	
    	<cfoutput>
        	<cftry>
            	<cfif len(FORMUL)>
            		<cfset calc_process_time = Evaluate('#FORMUL#')>
                <cfelse>
                	<cfset calc_process_time = 0>
                </cfif>
             	<cfcatch type="any">
                	<script type="text/javascript">
						alert('<cf_get_lang dictionary_id='45.Parça'> : #PIECE_NAME# <cf_get_lang dictionary_id='36669.İstasyon Adı'> : #station_name# <cf_get_lang dictionary_id='1015.Bu Parçadaki İstasyonunun Formülünde Hata Var'> ');
						
					</script>
                    <cfset calc_setup_time = 0>
              	</cfcatch>
         	</cftry>
            <cfif isnumeric(SSURE) and len(SSURE)>
        		<cfset calc_setup_time = SSURE>
          	<cfelse>
            	<cfset calc_setup_time = 0>
            </cfif>
            <cfif (calc_process_time*EMKTR*attributes.product_quantity)>
            	<cfset calc_only_process_time = calc_process_time*EMKTR>
            <cfelse>
            	<cfset calc_only_process_time = 0>
            </cfif>
            <cfif (calc_process_time*EMKTR*attributes.product_quantity) + calc_setup_time gt 0>
            	<cfset calc_one_process_time = ((calc_process_time*attributes.product_quantity) + calc_setup_time) / attributes.product_quantity>
            <cfelse>
            	<cfset calc_one_process_time = 0>
            </cfif>
            
            <cfset calc_employee_time = calc_one_process_time * employee_number>
            <cfset calc_station_cost = cost*Evaluate('RATE2_#MONEY#')/810000*calc_one_process_time>
            <cfset Temp = QueryAddRow(station_time_cal)>
            <cfset Temp = QuerySetCell(station_time_cal, "sira", sira)> 
            <cfset Temp = QuerySetCell(station_time_cal, "amount", EMKTR)>
            <cfset Temp = QuerySetCell(station_time_cal, "station_code", station_code)>
            <cfset Temp = QuerySetCell(station_time_cal, "station_id", station_id)> 
            <cfset Temp = QuerySetCell(station_time_cal, "station_name", station_name)> 
            <cfset Temp = QuerySetCell(station_time_cal, "station_time", calc_one_process_time)>
            <cfset Temp = QuerySetCell(station_time_cal, "process_time", calc_only_process_time)>
            <cfset Temp = QuerySetCell(station_time_cal, "setup_time", calc_setup_time)>
            <cfset Temp = QuerySetCell(station_time_cal, "employee_number", employee_number)> 
            <cfset Temp = QuerySetCell(station_time_cal, "employee_time", employee_number*calc_one_process_time)>
            <cfset Temp = QuerySetCell(station_time_cal, "station_cost", cost)> 
            <cfset Temp = QuerySetCell(station_time_cal, "station_cost_money", session.ep.money)> 
            <cfset Temp = QuerySetCell(station_time_cal, "katsayi", katsayi)>
        </cfoutput>
    </cfloop>
    <cfquery name="station_time_cal_group" dbtype="query">
    	SELECT DISTINCT
        	STATION_ID,
            STATION_NAME,
            STATION_CODE,
            EMPLOYEE_NUMBER,
            STATION_COST_MONEY,
            KATSAYI,
            SUM(STATION_COST) AS TOTAL_STATION_COST,
    		SUM(STATION_TIME) AS TOTAL_STATION_TIME,
       		SUM(EMPLOYEE_TIME) AS TOTAL_EMPLOYEE_TIME
     	FROM
        	station_time_cal
       	GROUP BY
        	STATION_ID,
           	STATION_NAME,
          	STATION_CODE,
          	EMPLOYEE_NUMBER,
         	STATION_COST_MONEY,
          	KATSAYI
		ORDER BY
	   		STATION_CODE
    </cfquery>
</cfif>
