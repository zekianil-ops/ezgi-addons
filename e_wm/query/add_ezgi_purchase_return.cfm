<!---
    File: add_ezgi_purchase_return.cfm
    Folder: Add_Ons\ezgi\e_wm\query
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description: Alım İade İşlemi
--->
<cfif isdefined('attributes.row_count_content') and attributes.row_count_content gt 0>
	<cfquery name="get_ship" datasource="#dsn2#">
    	SELECT
        	COMPANY_ID,
            PARTNER_ID, 
            CONSUMER_ID, 
            EMPLOYEE_ID    
		FROM            
         	SHIP
		WHERE        
        	SHIP_ID = #attributes.SHIP_ID# 
    </cfquery>
	<cftransaction>
    	<cfquery name="del_serial_no" datasource="#dsn3#">
        	DELETE FROM
            	SERVICE_GUARANTY_NEW
        	WHERE
       			PROCESS_ID = #attributes.SHIP_ID# AND	
              	PROCESS_CAT = #attributes.SHIP_TYPE#
        </cfquery>
        <cfloop from="1" to="#attributes.row_count_content#" index="i">
            <cfif isdefined('attributes.row_kontrol#i#') and Evaluate('attributes.row_kontrol#i#') eq 1>
                <cfquery name="add_serial_no" datasource="#dsn3#">
                    INSERT INTO        
                        SERVICE_GUARANTY_NEW
                        (
                            STOCK_ID, 
                            SERIAL_NO, 
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
                            SALE_GUARANTY_CATID, 
                            SALE_START_DATE, 
                            SALE_COMPANY_ID, 
                            SALE_PARTNER_ID, 
                            SALE_CONSUMER_ID, 
                            SALE_EMPLOYEE_ID, 
                            IS_SARF, 
                            SPECT_ID, 
                            IS_SERI_SONU, 
                            RECORD_DATE, 
                            RECORD_EMP, 
                            RECORD_IP, 
                            UNIT_TYPE, 
                            UNIT_ROW_QUANTITY
                        )
                    VALUES 
                        (
                            #Evaluate('attributes.stock_id#i#')#,
                            '#Evaluate('attributes.serial#i#')#',
                            0,
                            0,
                            1,
                            0,
                            0,
                            0,
                            #attributes.SHIP_TYPE#,
                            #attributes.SHIP_ID#,
                            '#attributes.SHIP_NUMBER#',
                            #session.ep.period_id#,
                            #ListGetAt(attributes.txt_department_out,1,'-')#,
                            #ListGetAt(attributes.txt_department_out,2,'-')#,
                            1,
                            #now()#,
                            <cfif len(get_ship.company_id)>#get_ship.company_id#<cfelse>NULL</cfif>,
                            <cfif len(get_ship.PARTNER_ID)>#get_ship.PARTNER_ID#<cfelse>NULL</cfif>,
                            <cfif len(get_ship.CONSUMER_ID)>#get_ship.CONSUMER_ID#<cfelse>NULL</cfif>,
                            <cfif len(get_ship.EMPLOYEE_ID)>#get_ship.EMPLOYEE_ID#<cfelse>NULL</cfif>,
                            0,
                            <cfif len(Evaluate('attributes.SPECT_MAIN_ID#i#'))>#Evaluate('attributes.SPECT_MAIN_ID#i#')#<cfelse>NULL</cfif>,
                            0,
                            #now()#,
                            #session.ep.userid#,
                            '#cgi.remote_addr#',
                            1,
                            1
                        )
                </cfquery>
            </cfif>
        </cfloop>
    </cftransaction>
</cfif>
<script type="text/javascript">
 	alert("Kayıt İşlemi Başarıyla Tamamlanmıştır.");
	window.location ="<cfoutput>#request.self#</cfoutput>?fuseaction=stock.add_ezgi_purchase_return";
</script>