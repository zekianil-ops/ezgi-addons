<!---
    File: _add_ezgi_operation_basket.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/07/2022
    Description:
--->
<cftransaction>
    <cfquery name="get_basket_status" datasource="#dsn3#"> <!---Eğer Onaylanmamış sepet Varsa Bilgileri Alınıyor--->
        SELECT BASKET_NO, EZGI_VTS_OPERATION_BASKET_ID FROM EZGI_VTS_OPERATION_BASKET WHERE IS_STAGE = 0 AND STATION_ID = #attributes.station_id#
    </cfquery>
    <cfif get_basket_status.recordcount gt 1>
        <script type="text/javascript">
            alert("Dikkat. Birden Açık Sepet Var.");
            window.location ="<cfoutput>#request.self#?fuseaction=production.list_ezgi_production_operation&is_form_submitted=1&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#</cfoutput>";
        </script>
        <cfabort>
    </cfif>
	<cfif get_basket_status.recordcount>
        <cfset paperno = get_basket_status.BASKET_NO>  
        <cfset get_max_id.MAX_ID = get_basket_status.EZGI_VTS_OPERATION_BASKET_ID> 
        <cfquery name="upd_operation_basket" datasource="#dsn3#">
            UPDATE
                EZGI_VTS_OPERATION_BASKET
            SET
                UPDATE_DATE = #now()#, 
                UPDATE_EMP = #session.ep.userid#, 
                UPDATE_IP = '#CGI.REMOTE_ADDR#'
            WHERE
                EZGI_VTS_OPERATION_BASKET_ID = #get_max_id.MAX_ID#
        </cfquery>
    <cfelse>
        <cfquery name="GET_PAPERNO" datasource="#dsn3#">
            SELECT MAX(BASKET_NO) AS PAPER_NO FROM EZGI_VTS_OPERATION_BASKET  
        </cfquery>
        <cfif GET_PAPERNO.recordcount and isnumeric(GET_PAPERNO.PAPER_NO)>
            <cfset paperno = GET_PAPERNO.PAPER_NO +1>
        <cfelse>
            <cfset paperno = 40000001>
        </cfif>
    
        <cfquery name="add_operation_basket" datasource="#dsn3#">
            INSERT INTO        
                EZGI_VTS_OPERATION_BASKET
                (
                    BASKET_NO,
                    STATION_ID, 
                    REAL_RATE,
                    IS_STAGE, 
                    RECORD_DATE, 
                    RECORD_EMP, 
                    RECORD_IP
                )
            VALUES 
                (
                    #paperno#,
                    #attributes.station_id#,
                    0,
                    0,
                    #now()#,
                    #session.ep.userid#,
                    '#CGI.REMOTE_ADDR#'
                )
        </cfquery>
        <cfquery name="get_max_id" datasource="#dsn3#">
            SELECT MAX(EZGI_VTS_OPERATION_BASKET_ID) AS MAX_ID FROM EZGI_VTS_OPERATION_BASKET  
        </cfquery> 
    </cfif>  
	<cfloop list="#attributes.operation_id_list#" index="i">
        <cfquery name="add_operation_basket_row" datasource="#dsn3#">
        	INSERT INTO 
            	EZGI_VTS_OPERATION_BASKET_ROW
             	(
                	EZGI_VTS_OPERATION_BASKET_ID,
                	OPERATION_ID
              	)
			VALUES 
            	(
                	#get_max_id.MAX_ID#,
                	#i#
               	)
        </cfquery>
	</cfloop>
</cftransaction>    
<script type="text/javascript">
	alert("Seçtiğiniz Operasyonların Sepet Kaydı Oluşturulmuştur!");
	window.location ="<cfoutput>#request.self#?fuseaction=production.list_ezgi_production_operation&is_form_submitted=1&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&lot_number=#paperno#</cfoutput>";
</script>
