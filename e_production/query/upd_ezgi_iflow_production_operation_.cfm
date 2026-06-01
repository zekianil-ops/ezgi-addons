<!---
    File: upd_ezgi_iflow_production_operation.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/11/2024
    Description:
--->

<cfif get_station_sablon.recordcount>
	<cfset up_workstation_list = ValueList(get_station_sablon.WORKSTATION_ID)>
	<cfif not Listlen(get_station_sablon.WORKSTATION_ID)>
        <!---Partiye Bağlı İşlerin Listesini Alıyoruz--->
        <cfquery name="get_works" datasource="#dsn3#">
            SELECT DISTINCT 
                EIPO.P_ORDER_PARTI_ID, 
                PORR.OPERATION_TYPE_ID, 
                W1.STATION_ID, 
                W1.STATION_NAME,
                PORR.P_OPERATION_ID, 
                PORR.AMOUNT
            FROM     
                EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPO WITH (NOLOCK) INNER JOIN
                EZGI_IFLOW_PRODUCTION_ORDERS AS EPO WITH (NOLOCK) ON EIPO.P_ORDER_PARTI_ID = EPO.REL_P_ORDER_ID INNER JOIN
                PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EPO.LOT_NO = PO.LOT_NO INNER JOIN
                PRODUCTION_OPERATION AS PORR WITH (NOLOCK) ON PO.P_ORDER_ID = PORR.P_ORDER_ID INNER JOIN
                WORKSTATIONS_PRODUCTS AS WP WITH (NOLOCK) ON PORR.OPERATION_TYPE_ID = WP.OPERATION_TYPE_ID INNER JOIN
                WORKSTATIONS AS W WITH (NOLOCK) ON WP.WS_ID = W.STATION_ID INNER JOIN
                WORKSTATIONS AS W1 WITH (NOLOCK) ON W.UP_STATION = W1.STATION_ID
            WHERE  
                EIPO.P_ORDER_PARTI_ID = #get_production_operations_group.P_ORDER_PARTI_ID#
            ORDER BY 
                W1.STATION_ID
        </cfquery>
        
        <!---İşleri İstasyona Göre Gurupluyorum--->
        <cfquery name="get_works_group" dbtype="query">
            SELECT STATION_ID,STATION_NAME FROM get_works GROUP BY STATION_ID,STATION_NAME
        </cfquery>
        <!---İstasyona Göre Guruplu Lsiteyi Döndürüyorum --->
        <cfloop query="get_works_group">
            <!---Şablonda tanımlanan İstasyon Bilgilerini Buluyorum--->
            <cfquery name="get_station_info" dbtype="query">
                SELECT UP_WORKSTATION_ID, UP_WORKSTATION_TIME, SIRA FROM get_station_sablon WHERE WORKSTATION_ID = #get_works_group.STATION_ID#
            </cfquery>
            <!---İstasyona Bağlı İşleri Buluyorum--->
            <cfquery name="get_station_works" dbtype="query">
                SELECT
                    P_OPERATION_ID
                FROM
                    get_works
                WHERE
                    STATION_ID = #get_works_group.STATION_ID#	
            </cfquery>
            <cfset p_operation_list = ValueList(get_station_works.P_OPERATION_ID)>
            
            <cfif get_station_info.SIRA eq 1><!---Eğer Şablonun İlk Sırasında ise Parti Başlangıç Tarihini Yazdırıyorum--->
                <cfif ListLen(p_operation_list)>
                    <cfquery name="upd_p_operation_time" datasource="#dsn3#">
                         UPDATE 
                            PRODUCTION_OPERATION
                        SET          
                            O_START_DATE = #x_start_date#, 
                            O_FINISH_DATE = #x_start_date#
                        WHERE
                            P_OPERATION_ID IN (#p_operation_list#)
                    </cfquery>
                </cfif>
            <cfelse><!---Eğer Şablonun İlk Sırasından sonra ise Şablondaki Farkı Parti Başlangıç Tarihine Ekleyerek Yazdırıyorum--->
                <cfif get_station_info.UP_WORKSTATION_TIME gt 0>
                    <cfset new_date = DateAdd('d',get_station_info.UP_WORKSTATION_TIME,x_start_date)>
                <cfelse>
                    <cfset new_date = x_start_date>
                </cfif>
                <cfquery name="upd_p_operation_time" datasource="#dsn3#">
                    UPDATE 
                        PRODUCTION_OPERATION
                    SET          
                        O_START_DATE = #new_date#, 
                        O_FINISH_DATE = #new_date#
                    WHERE
                        P_OPERATION_ID IN (#p_operation_list#)
                </cfquery>
            </cfif>
        </cfloop>
    </cfif>
</cfif>