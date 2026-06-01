<!---
    File: _add_ezgi_operation_sablon.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/07/2022
    Description:
--->
<cfset attributes.station_id_ = attributes.station_id>
<cftransaction>
    <cfquery name="get_basket_status" datasource="#dsn3#"> <!---Eğer Onaylanmamış sepet Varsa Bilgileri Alınıyor--->
        SELECT BASKET_NO, EZGI_VTS_OPERATION_BASKET_ID FROM EZGI_VTS_OPERATION_BASKET WHERE IS_STAGE = 0 AND STATION_ID = #attributes.station_id#
    </cfquery>
    <cfif get_basket_status.recordcount>
        <script type="text/javascript">
            alert("Dikkat. Bu İstasyona Atanmış" +<cfoutput>#get_basket_status.BASKET_NO#</cfoutput>+ " Nolu Açık Sepet Var.");
            window.location ="<cfoutput>#request.self#?fuseaction=production.list_ezgi_production_operation_sablon&is_form_submitted=1&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#</cfoutput>";
        </script>
        <cfabort>
    <cfelse>
        <cfquery name="GET_PAPERNO" datasource="#dsn3#">
            SELECT MAX(BASKET_NO) AS PAPER_NO FROM EZGI_VTS_OPERATION_BASKET  
        </cfquery>
        <cfif GET_PAPERNO.recordcount and isnumeric(GET_PAPERNO.PAPER_NO)>
            <cfset paperno = GET_PAPERNO.PAPER_NO +1>
        <cfelse>
            <cfset paperno = 40000001>
        </cfif>
        <cfquery name="get_operations" datasource="#dsn3#">
            SELECT 
                POO.P_OPERATION_ID, 
                POO.P_ORDER_ID,
                POO.STAGE,
                COUNT(*) AS AMOUNT
            FROM     
                EZGI_IFLOW_OPTIMIZATION_RESULTS AS O INNER JOIN
                EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS ORR ON O.OPTIMIZATION_RESULT_ID = ORR.OPTIMIZATION_RESULT_ID INNER JOIN
                PRODUCTION_ORDERS AS PO ON ORR.P_ORDER_NO = PO.P_ORDER_NO INNER JOIN
                PRODUCTION_OPERATION AS POO ON PO.P_ORDER_ID = POO.P_ORDER_ID INNER JOIN
                WORKSTATIONS_PRODUCTS AS WP ON POO.OPERATION_TYPE_ID = WP.OPERATION_TYPE_ID
            WHERE  
                O.SHEET_GROUP_NUMBER = #attributes.SHEET_GROUP_NUMBER# AND 
                WP.WS_ID = #attributes.station_id# AND
                POO.STAGE <> 2
            GROUP BY 
                POO.P_OPERATION_ID,
                POO.P_ORDER_ID,
                POO.STAGE
        </cfquery>
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
                    2,
                    #now()#,
                    #session.ep.userid#,
                    '#CGI.REMOTE_ADDR#'
                )
        </cfquery>
        <cfquery name="get_max_id" datasource="#dsn3#">
            SELECT MAX(EZGI_VTS_OPERATION_BASKET_ID) AS MAX_ID FROM EZGI_VTS_OPERATION_BASKET  
        </cfquery> 
    </cfif>  
    <cfif get_operations.recordcount>
        <cfset attributes.realized_amount_ = 0>
        <cfset attributes.loss_amount_ = 0>
        <cfset product_time_ = 0>
        <cfset attributes.duration_time_ = 0>
        <cfset attributes.lot_number = paperno>
        <cfloop query="get_operations">
            <cfquery name="add_operation_basket_row" datasource="#dsn3#">
                INSERT INTO 
                    EZGI_VTS_OPERATION_BASKET_ROW
                    (
                        EZGI_VTS_OPERATION_BASKET_ID,
                        OPERATION_ID,
                        OPTIMIZITION_SABLON
                    )
                VALUES 
                    (

                        #get_max_id.MAX_ID#,
                        #get_operations.P_OPERATION_ID#,
                        #attributes.SHEET_GROUP_NUMBER#
                    )
            </cfquery>
            <cfset attributes.upd_id = get_operations.P_ORDER_ID>
            <cfset attributes.operation_id_ = get_operations.P_OPERATION_ID>
            <cfinclude template="add_ezgi_operation_result.cfm"><!---Operasyon Sonuç Başlama Kaydı Açılıyor--->
            <cfif get_ezgi_result_control_group.recordcount and get_ezgi_result_stocks_group.recordcount> <!---Eğer Malzemede ve sorun varsa --->
                <script type="text/javascript">
                    window.history.go(-1);
                </script>
                <cfabort>
            </cfif>
            <cfquery name="UPD_OPERATION" datasource="#dsn3#"> <!---Operasyonlara Başladı STAGE yapılıyor--->
                UPDATE  
                    PRODUCTION_OPERATION
                SET     
                    STAGE = 1
                WHERE 	
                    P_OPERATION_ID = #attributes.operation_id_#
            </cfquery>
        </cfloop>
    </cfif>
</cftransaction>    
<script type="text/javascript">
	alert("Seçtiğiniz Şablonun Üretimleri Başlatılmıştır.!");
	window.location ="<cfoutput>#request.self#?fuseaction=production.dsp_ezgi_operation_sablon&sheet_group_number=#attributes.sheet_group_number#&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#</cfoutput>";
</script>

