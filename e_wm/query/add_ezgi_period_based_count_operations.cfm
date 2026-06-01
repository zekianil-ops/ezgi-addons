<!---
    File: add_ezgi_perioad_based_count_operations.cfm
    Folder: Add_Ons\ezgi\e-wm\query
    Author: Ezgi Yazılım
    Date: 01/02/2025
    Description:
--->
<cflock timeout="90">
	<cftransaction>
        <cfquery name="get_count" datasource="#dsn3#">
            SELECT 
                TOP (1) PROCESS_NUMBER
            FROM     
                EZGI_WM_COUNT
            ORDER BY
                PROCESS_NUMBER DESC	
        </cfquery>
        <cfif get_count.recordcount and len(get_count.PROCESS_NUMBER)>
            <cfset paper_number = get_count.PROCESS_NUMBER + 1>
        <cfelse>
            <cfset paper_number = 10000>
        </cfif>
        <cfquery name="add_count" datasource="#dsn3#" result="max_id">
            INSERT INTO 
                EZGI_WM_COUNT
                (
                    PROCESS_NUMBER,
                    PROCESS_DATE,
                    STATUS, 
		    IS_PALETTE_CONTENT_SAVE,
                    RECORD_EMP, 
                    RECORD_IP, 
                    RECORD_DATE
                )
            VALUES 
                (
                    #paper_number#,
                    #now()#,
                    1,
		    0,
                    #session.ep.userid#,
                    '#cgi.remote_addr#',
                    #now()#
                )
        </cfquery>
        <cfquery name="get_max" datasource="#dsn3#">
        	SELECT MAX(EZGI_WM_COUNT_ID) AS MAX_ID FROM EZGI_WM_COUNT
        </cfquery>
        <cfquery name="add_palets" datasource="#dsn3#">
            INSERT INTO 
                EZGI_WM_COUNT_PACKING_ROW
                (
                    WM_COUNT_ID, 
                    PACKING_ID, 
                    STORE, 
                    STORE_LOCATION, 
                    SHELF_NUMBER, 
                    BARCODE, 
                    PACKING_SIZE_TYPE_ID, 
                    PACKING_SIZE_TYPE_CODE, 
                    PACKING_SIZE_TYPE_NAME, 
                    STOCK_ID, 
                    AMOUNT, 
                    IS_KARMA
                )
            SELECT
                #get_max.max_id#, 
                PACKING_ID, 
                STORE, 
                STORE_LOCATION, 
                SHELF_NUMBER, 
                BARCODE, 
                PACKING_SIZE_TYPE_ID, 
                PACKING_SIZE_TYPE_CODE, 
                PACKING_SIZE_TYPE_NAME, 
                STOCK_ID, 
                AMOUNT, 
                IS_KARMA
            FROM     
                EZGI_WM_PACKING_LAST_STATUS
            WHERE  
                STATUS = 1 AND 
                AMOUNT > 0
            ORDER BY
                PACKING_ID 	
        </cfquery>
        <cfquery name="add_serial" datasource="#dsn3#">
            INSERT INTO
                EZGI_WM_COUNT_SERIAL_ROW
                (
                    WM_COUNT_ID, 
                    SERIAL_NO, 
                    STOCK_ID, 
                    DEPARTMENT_ID, 
                    LOCATION_ID, 
                    PRODUCT_PLACE_ID, 
                    PACKING_ID, 
                    DEPO, 
                    SPECT_ID, 
                    PALET_BARCODE, 
                    PRODUCT_NAME, 
                    IS_PROTOTYPE, 
                    SHELF_CODE
                )
            SELECT 
                #get_max.max_id#, 
                E.SERIAL_NO, 
                E.STOCK_ID, 
                E.DEPARTMENT_ID, 
                E.LOCATION_ID, 
                E.PRODUCT_PLACE_ID, 
                E.PACKING_ID, 
                E.DEPO, 
                E.SPECT_ID, 
                E.PALET_BARCODE, 
                E.PRODUCT_NAME, 
                E.IS_PROTOTYPE, 
                E.SHELF_CODE
            FROM     
                EZGI_WM_SERIAL_NO_LAST_STATUS AS E INNER JOIN
                EZGI_WM_IS_SERIAL_NO_LIVE AS S ON E.SERIAL_NO = S.SERIAL_NO
            ORDER BY 
                E.SERIAL_NO
        </cfquery>
	</cftransaction>
</cflock> 
<cflocation url="#request.self#?fuseaction=stock.list_ezgi_perioad_based_count_operations&event=upd&count_id=#get_max.max_id#" addtoken="No">      