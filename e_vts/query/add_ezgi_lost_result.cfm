<!---
    File: add_ezgi_lost_result.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/04/2023
    Description:
--->
<cfquery name="get_production_info" datasource="#dsn3#">
	SELECT 
    	PROJECT_ID, 
        P_ORDER_NO, 
        LOT_NO
	FROM     
    	PRODUCTION_ORDERS
	WHERE  
    	P_ORDER_ID = #attributes.upd_id#
</cfquery>
<cfquery name="get_department" datasource="#dsn3#">
	SELECT DEPARTMENT FROM WORKSTATIONS WHERE  STATION_ID = #attributes.station_id_#
</cfquery>
<cfquery name="get_work_team" datasource="#DSN3#">
	SELECT 
    	EMPLOYEE_ID
	FROM     
    	EZGI_STATION_EMPLOYEE
	WHERE  
    	STATION_ID = #attributes.station_id_# AND 
        FINISH_DATE IS NULL
</cfquery>
<cfset employee_id_list = ValueList(get_work_team.EMPLOYEE_ID)>
<cfquery name="GET_PAPER" datasource="#DSN3#">
	SELECT 
        EZGI_VTS_WASTAGE_SERI, 
     	EZGI_VTS_WASTAGE_NO
	FROM     
    	EZGI_VTS_SETUP
	WHERE  
     	EZGI_VTS_DEPARTMENT_ID = #get_department.DEPARTMENT#
</cfquery>
<cfif GET_PAPER.recordcount and len(GET_PAPER.EZGI_VTS_WASTAGE_SERI) and len(GET_PAPER.EZGI_VTS_WASTAGE_NO)>
    <cfset paper_no = '#GET_PAPER.EZGI_VTS_WASTAGE_SERI#-#GET_PAPER.EZGI_VTS_WASTAGE_NO#'>
<cfelse>
    <script type="text/javascript">
		alert("VTS Setup Tanımlarındaki Fire Belge No Tanımlarını Yapınız.!");
		window.close()
	</script>
 	<cfabort>
</cfif> 
<cfquery name="add_production_wastage" datasource="#dsn3#">
	INSERT INTO 
    	EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE
      	(
        	P_ORDER_ID, 
         	P_OPERATION_ID, 
         	STATION_ID, 
         	EMPLOYEE_IDS, 
         	WASTAGE_DATE, 
         	DETAIL, 
         	REASON_ID, 
         	IS_DEMAND, 
         	STATUS, 
         	WASTAGE_NO, 
         	WASTAGE_STAGE, 
         	WASTAGE_AMOUNT,
         	PROJECT_ID,
         	RECORD_DATE, 
         	RECORD_EMP, 
         	RECORD_IP
       	)
		VALUES 
    	(
        	#attributes.upd_id#,
         	#attributes.operation_id_#,
         	#attributes.station_id_#,
         	<cfif ListLen(employee_id_list)>'#employee_id_list#'<cfelse>NULL</cfif>,
         	#now()#,
         	NULL,
         	#attributes.reason_id#,
         	#attributes.product_demand#,
         	1,
         	'#paper_no#',
         	#attributes.process_stage#,
         	#filternum(attributes.loss_amount_,8)#,
         	<cfif len(get_production_info.PROJECT_ID)>#get_production_info.PROJECT_ID#<cfelse>NULL</cfif>,
         	#now()#,
			#session.ep.userid#,
	    	'#CGI.REMOTE_ADDR#'
       	)
</cfquery>
<cfquery name="get_max" datasource="#dsn3#">
  	SELECT MAX(PRODUCTION_WASTAGE_ID) MAX_ID FROM EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE
</cfquery>
<cfif ListLen(attributes.convert_list_)>
   	<cfloop list="#attributes.convert_list_#" index="i">
    	<cfset attributes.ezg_row_id = 'EZG'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')# & #session.ep.company_id# & #ListGetat(i,1,'_')#>
       	<cfif ListLen(i,'_') eq 2>
            <cfquery name="get_por_stock" datasource="#dsn3#">
         	    SELECT 
         	    	POS.POR_STOCK_ID,
         	        POS.PRODUCT_ID, 
         	        POS.STOCK_ID, 
         	        POS.SPECT_MAIN_ID, 
         	        POS.AMOUNT, 
         	        POS.PRODUCT_UNIT_ID
         	    FROM     
         	        PRODUCTION_ORDERS_STOCKS AS POS INNER JOIN
         	        STOCKS AS S ON POS.STOCK_ID = S.STOCK_ID INNER JOIN
         	        PRODUCT_UNIT AS PU ON POS.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
         	    WHERE  
         	        POS.P_ORDER_ID = #attributes.upd_id# AND 
         	        <!---ISNULL(S.IS_ADD_XML,0) = 0 AND --->
         	        POS.TYPE = 2 AND 
         	        POS.POR_STOCK_ID = #ListGetat(i,1,'_')#
         	</cfquery>
            <cfif get_por_stock.recordcount>
                <cfquery name="add_production_wastage_row" datasource="#dsn3#">
                    INSERT INTO 
                        EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE_ROW
                        (
                            PRODUCTION_WASTAGE_ID, 
                            STOCK_ID, 
                            PRODUCT_ID, 
                            MAIN_SPECT_ID, 
                            AMOUNT, 
                            WRK_ROW_ID, 
                            PRODUCT_UNIT_ID, 
                            POR_STOCK_ID
                        )
                    VALUES 
                        (
                            #get_max.MAX_ID#,
                            #get_por_stock.STOCK_ID#,
                            #get_por_stock.PRODUCT_ID#,
                            <cfif len(get_por_stock.SPECT_MAIN_ID)>#get_por_stock.SPECT_MAIN_ID#<cfelse>NULL</cfif>,
                            #ListGetat(i,2,'_')#,
                            '#attributes.ezg_row_id#',
                            #get_por_stock.PRODUCT_UNIT_ID#,
                            #get_por_stock.POR_STOCK_ID#
                        )
                </cfquery>
            <cfelse>
            	<script type="text/javascript">
					alert("Fire Yapılacak Ürün Bulunamadı.!");
					window.close()
				</script>
				<cfabort>
            </cfif>
    	<cfelse>
          	<script type="text/javascript">
				alert("Miktarda Değer Yoktur.!");
				window.close()
			</script>
			<cfabort>
      	</cfif>
  	</cfloop>
    <cfif attributes.product_demand eq 1>
		<cfinclude template="add_ezgi_operation_result.cfm">
	</cfif>
    <cfquery name="GET_PAPER" datasource="#DSN3#">
        UPDATE 
			EZGI_VTS_SETUP
      	SET
            EZGI_VTS_WASTAGE_NO = #GET_PAPER.EZGI_VTS_WASTAGE_NO+1#
        WHERE  
            EZGI_VTS_DEPARTMENT_ID = #get_department.DEPARTMENT#
	</cfquery>
</cfif>
<cf_workcube_process is_upd='1' 
					data_source='#dsn3#'
                    old_process_line='0'
                    process_stage='#attributes.process_stage#' 
                    record_member='#session.ep.userid#' 
                    record_date='#now()#' 
                    action_table='EZGI_IFLOW_PRODUCTION_ORDERS_WASTAGE'
                    action_column='PRODUCTION_WASTAGE_ID'
                    action_id='#get_max.MAX_ID#'
                    action_page='#request.self#?fuseaction=sales.list_ezgi_lost_result&event=upd&wastage_id=#get_max.MAX_ID#' 
                    warning_description='Fire İşlemi'>