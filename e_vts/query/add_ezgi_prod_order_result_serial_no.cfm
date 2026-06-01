<cfquery name="get_sale_order_info" datasource="#DSN3#">
	SELECT 
    	EWM.PRODUCTION_ORDER_ROW_ID, 
        ORR.QUANTITY,
        ORR.ORDER_ROW_ID, 
        O.COMPANY_ID
	FROM     
    	ORDERS AS O INNER JOIN
        ORDER_ROW AS ORR ON O.ORDER_ID = ORR.ORDER_ID RIGHT OUTER JOIN
        PRODUCTION_ORDERS_ROW AS EWM ON ORR.ORDER_ROW_ID = EWM.ORDER_ROW_ID
	WHERE  
    	EWM.PRODUCTION_ORDER_ID = #attributes.upd_id# AND 
        EWM.SERIAL_NO IS NULL
	ORDER BY 
    	O.COMPANY_ID DESC, 
        O.CONSUMER_ID DESC, 
        ORR.ORDER_ROW_ID
</cfquery>
<cfif get_sale_order_info.recordcount lt amount>
	<script type="text/javascript">
		alert("PRODUCTION_ORDERS_ROW tablosundaki ayrılan kayıtlar üretilen sonucu karşılamıyor. Sistem Yöneticinize Başvurun!");
	</script>
	<!---<cfabort>--->
</cfif>
<cfif (isdefined('attributes.company_id') and len(attributes.company_id) and not GET_SERIAL.recordcount) or not (isdefined('attributes.company_id') and len(attributes.company_id))>
	
</cfif>
<cfquery name="GET_SERIAL" datasource="#DSN3#">
  	SELECT 
    	EZGI_SERIAL_ID, 
    	COMPANY_ID, 
     	ONTAKI, 
      	NUMARATOR, 
     	SONTAKI, 
     	SAYAC
  	FROM     
    	EZGI_SERIAL_NO
  	WHERE  
     	COMPANY_ID = 0
</cfquery>
<cfquery name="get_order_info" dbtype="query">
	SELECT * FROM get_sale_order_info
</cfquery>
<cfif GET_SERIAL.recordcount and isnumeric(GET_SERIAL.SAYAC)>
	<cfloop query="get_sale_order_info" startrow="1" endrow="#AMOUNT#">
		<cfif len(get_sale_order_info.COMPANY_ID)>
            <cfquery name="GET_SERIAL" datasource="#DSN3#">
                SELECT 
                    EZGI_SERIAL_ID, 
                    COMPANY_ID, 
                    ONTAKI, 
                    NUMARATOR, 
                    SONTAKI, 
                    SAYAC
                FROM     
                    EZGI_SERIAL_NO
                WHERE  
                    COMPANY_ID = #get_sale_order_info.COMPANY_ID#
            </cfquery>
        <cfelse>
        	<cfquery name="get_order_info" datasource="#dsn3#">
        		SELECT COMPANY_ID FROM STOCKS WHERE STOCK_ID = #get_stock_serial_info.STOCK_ID#
            </cfquery>
            <cfif get_order_info.recordcount and len(get_order_info.COMPANY_ID)>
            	<cfquery name="GET_SERIAL" datasource="#DSN3#">
                    SELECT 
                        EZGI_SERIAL_ID, 
                        COMPANY_ID, 
                        ONTAKI, 
                        NUMARATOR, 
                        SONTAKI, 
                        SAYAC
                    FROM     
                        EZGI_SERIAL_NO
                    WHERE  
                        COMPANY_ID = #get_order_info.COMPANY_ID#
                </cfquery>
            </cfif>
        </cfif>
		<cfif not len(get_order_info.COMPANY_ID) or (len(get_order_info.COMPANY_ID) and not GET_SERIAL.recordcount)>
        	<cfquery name="GET_SERIAL" datasource="#DSN3#">
                SELECT 
                    EZGI_SERIAL_ID, 
                    COMPANY_ID, 
                    ONTAKI, 
                    NUMARATOR, 
                    SONTAKI, 
                    SAYAC
                FROM     
                    EZGI_SERIAL_NO
                WHERE  
                    COMPANY_ID = 0
            </cfquery>
        </cfif>
		<cfset sayac = GET_SERIAL.SAYAC>
        <cfset numarator = GET_SERIAL.NUMARATOR>
        
		<cfset sayac = sayac + 1>
        <cfif len(GET_SERIAL.NUMARATOR) gt len(sayac)>
            <cfset fark = len(GET_SERIAL.NUMARATOR)-len(sayac)>
            <cfset serino = '#left(GET_SERIAL.NUMARATOR,fark)##sayac#'>
        <cfelse>
            <cfset serino = '#sayac#'>
        </cfif>
        
        <cfif len(GET_SERIAL.ONTAKI)>
            <cfset serino = '#GET_SERIAL.ONTAKI##serino#'>
        </cfif>
        <cfif len(GET_SERIAL.SONTAKI)>
            <cfset serino = '#serino##GET_SERIAL.SONTAKI#'>
        </cfif>
        
        <cfset attributes.wrk_row_id = '#serino#'&#DateFormat(Now(),'YYYYMMDD')# & #TimeFormat(Now(),'HHmmssL')# & '_' &#session.ep.userid# & '_' & #get_sale_order_info.currentrow#>
        
        <cfquery name="add_serial_no" datasource="#dsn3#">
         	INSERT INTO        
            	SERVICE_GUARANTY_NEW
             	(
             	    STOCK_ID, 
             	    SERIAL_NO, 
             	    LOT_NO, 
             	    IN_OUT, 
             	    IS_PURCHASE, 
             	    IS_SALE, 
             	    IS_RETURN, 
             	    IS_RMA, 
             	    IS_SERVICE, 
             	    PROCESS_CAT, 
             	    PROCESS_ID, 
             	    PROCESS_NO, 
             	    PERIOD_ID, 
             	    DEPARTMENT_ID, 
             	    LOCATION_ID, 
             	    PURCHASE_START_DATE, 
             	    IS_SARF, 
             	    SPECT_ID, 
             	    IS_SERI_SONU, 
             	    WRK_ID, 
             	    RMA_NO, 
             	    REFERENCE_NO, 
             	    RECORD_DATE, 
             	    RECORD_EMP, 
             	    RECORD_IP, 
             	    UNIT_TYPE,
                    RESERVE_ORDER_ROW_ID
             	)
        	VALUES 
             	(
             	    #get_stock_serial_info.STOCK_ID#,
             	    '#serino#',
             	    '#get_stock_serial_info.LOT_NO#',
             	    1,
             	    0,
             	    0,
             	    0,
             	    0,
             	    0,
             	    171,
             	    #attributes.pr_order_id#,
             	    '#get_stock_serial_info.RESULT_NO#',
             	    #session.ep.period_id#,
             	    #get_stock_serial_info.PRODUCTION_DEP_ID#, 
             	    #get_stock_serial_info.PRODUCTION_LOC_ID#,
             	    '#get_stock_serial_info.RECORD_DATE#',
             	    0,
             	    #get_stock_serial_info.SPEC_MAIN_ID#,	
             	    0,
             	    '#attributes.wrk_row_id#',
             	    '',
                    <cfif isdefined('attributes.trace_no') and len(attributes.trace_no)>
                    	'#attributes.trace_no#',
                   	<cfelse>
                    	'',
                 	</cfif>
             	     #now()#,
             	    #session.ep.userid#,
             	    '#cgi.remote_addr#',
             	    0,
                    <cfif isdefined('get_sale_order_info.ORDER_ROW_ID') and len(get_sale_order_info.ORDER_ROW_ID)>#get_sale_order_info.ORDER_ROW_ID#<cfelse>NULL</cfif>
             	)
        </cfquery>
    	<cfquery name="upd_SERIAL" datasource="#DSN3#">
         	UPDATE EZGI_SERIAL_NO SET SAYAC = #sayac# WHERE COMPANY_ID = #GET_SERIAL.COMPANY_ID#
      	</cfquery>
        <cfif isdefined('get_sale_order_info.PRODUCTION_ORDER_ROW_ID') and len(get_sale_order_info.PRODUCTION_ORDER_ROW_ID)>
            <cfquery name="upd_pre" datasource="#dsn3#">
                UPDATE PRODUCTION_ORDERS_ROW SET SERIAL_NO = '#serino#' WHERE PRODUCTION_ORDER_ROW_ID = #get_sale_order_info.PRODUCTION_ORDER_ROW_ID#
            </cfquery>
            <cfif isdefined('get_sale_order_info.ORDER_ROW_ID') and len(get_sale_order_info.ORDER_ROW_ID)>
                <cfquery name="upd_order_row_currency" datasource="#dsn3#">
                    UPDATE
                        ORDER_ROW
                    SET
                        ORDER_ROW_CURRENCY = -6
                    WHERE 
                        ORDER_ROW_ID NOT IN
                                        (
                                            SELECT 
                                                ORDER_ROW_ID
                                            FROM
                                                PRODUCTION_ORDERS_ROW
                                            WHERE  
                                                SERIAL_NO IS NULL
                                            GROUP BY 
                                                ORDER_ROW_ID, 
                                                PRODUCTION_ORDER_ID
                                            HAVING 
                                                NOT (PRODUCTION_ORDER_ID IS NULL) AND 
                                                ORDER_ROW_ID = #get_sale_order_info.ORDER_ROW_ID#
                                        ) AND
                        ORDER_ROW_ID = #get_sale_order_info.ORDER_ROW_ID#                   
                </cfquery>
            </cfif>
        <cfelse>
        	PRODUCTION_ORDERS_ROW Table SERIAL_NO Güncellemesi Yapılamıyor. Lütfen Yönetiinize Başvurun
        	<cfdump var="#get_sale_order_info#">
        	<cfabort>
        </cfif>
        
        
        
 	</cfloop>
<cfelse>
	<script type="text/javascript">
		alert("Ilk Olarak Seri No Tanımlarını Yapınız!");
		window.close()
	</script>
	<cfabort>
</cfif>