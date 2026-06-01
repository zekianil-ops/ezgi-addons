		<cfquery name="store_control" datasource="#dsn3#">
          	SELECT 
             	COMPANY_ID, 
             	BRANCH_ID, 
              	DEPARTMENT_ID, 
            	LOCATION_ID, 
             	DEPARTMENT_HEAD, 
             	COMMENT, 
            	DEPO_NAME, 
             	DEPO
        	FROM     
            	EZGI_WM_DEPARTMENTS
          	WHERE  
            	DEPO = '#attributes.depo#'	       
   		</cfquery>
        <cfset fire_izinli_depolar = ValueList(store_control.DEPO)>
        <cfquery name="get_count_serial_row" datasource="#dsn3#">
            SELECT 
                E.SERIAL_NO, 
                E.STOCK_ID, 
                E.PRODUCT_PLACE_ID, 
                E.PACKING_ID, 
                E.SPECT_ID, 
                E.PALET_BARCODE, 
                E.PRODUCT_NAME, 
                E.IS_PROTOTYPE, 
                ISNULL(E.SHELF_CODE,0) SHELF_CODE, 
                ISNULL(E.IS_CONTROL,0) AS IS_CONTROL, 
                E.CONTROL_DATE, 
                E.CONTROL_EMP, 
                D.DEPO_NAME, 
                D.DEPO,
                P.SHELF_TYPE
            FROM     
                EZGI_WM_COUNT_SERIAL_ROW AS E WITH (NOLOCK) INNER JOIN
                EZGI_WM_DEPARTMENTS AS D WITH (NOLOCK) ON E.DEPARTMENT_ID = D.DEPARTMENT_ID AND E.LOCATION_ID = D.LOCATION_ID LEFT OUTER JOIN
                EZGI_PRODUCT_PLACE AS P WITH (NOLOCK) ON E.PRODUCT_PLACE_ID = P.PRODUCT_PLACE_ID
            WHERE  
                E.WM_COUNT_ID = #attributes.count_id# AND
                ISNULL(E.IS_CONTROL,0) = 0 AND
                D.DEPO = '#attributes.depo#'
        </cfquery>
		<cfif get_count_serial_row.recordcount>
        	<script language="javascript" type="text/javascript">
				document.getElementById('first_area').style.display='none';
				document.getElementById('third_area').style.display='';
				document.getElementById('second_area').style.display='';
				document.getElementById('add_other_barcod').value = '';
				<cfoutput>
					document.getElementById('txt_department_out_name').value= '#get_count_serial_row.DEPO_NAME#';
					document.getElementById('txt_department_out').value= '#get_count_serial_row.DEPO#';
				</cfoutput>
				<cfoutput query="get_count_serial_row">
					add_row('#get_count_serial_row.SERIAL_NO#','#get_count_serial_row.PRODUCT_NAME#',#get_count_serial_row.STOCK_ID#,#get_count_serial_row.SPECT_ID#);
				</cfoutput>
			</script>
        </cfif>