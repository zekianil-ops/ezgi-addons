<!---
    File: upd_ezgi_p_order_send.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfif isdefined('chng_master_alt_plan') and len(chng_master_alt_plan)> <!---Gönderilmek İstenilen Alt Plan Seçilip Seçilmediğini Kontrol Ediyoruz--->
	<cfquery name="get_lot_no" datasource="#dsn3#"> <!---Seçilen Emirlere ait Lotları Topluyoruz--->
    	SELECT LOT_NO FROM PRODUCTION_ORDERS WHERE P_ORDER_ID IN (#p_order_list#)
    </cfquery>
    <cfset lot_no_list = ValueList(get_lot_no.LOT_NO)>
	<!---Gönderilmek İstenilen Alt planın İlişkili Alt Planlarını Buluyoruz--->
    <cfquery name="get_chng_related_sub_plans" datasource="#dsn3#">
        SELECT     
            MASTER_ALT_PLAN_ID, 
            PROCESS_ID
        FROM         
            EZGI_MASTER_ALT_PLAN
        WHERE     
            MASTER_ALT_PLAN_ID = #chng_master_alt_plan# OR
            RELATED_MASTER_ALT_PLAN_ID = #chng_master_alt_plan#
    </cfquery>
    <cfset process_id_list = ValueList(get_chng_related_sub_plans.PROCESS_ID)>
    <cfoutput query="get_chng_related_sub_plans">
        <cfset 'C_MASTER_ALT_PLAN_ID_#PROCESS_ID#'= MASTER_ALT_PLAN_ID>
    </cfoutput>
    <cftransaction>
        <cfloop list="#process_id_list#" index="i"><!---Her İlişkili alt Plan İçin Tek tek döndürüyoruz--->
        	<!---Gönderilecek alt plan veya ilişkilialt planın bilgileri bulunuyor--->
            <cfquery name="GET_NEW_INFO" datasource="#dsn3#">
                SELECT 
                    EMAP.PLAN_START_DATE, 
                    EMAP.PLAN_FINISH_DATE, 
                    EMPS.WORKSTATION_ID, 
                    EMAP.PROCESS_ID, 
                    EMAP.MASTER_ALT_PLAN_ID,
            		ISNULL(EMAP.IS_RESERVED,1) AS IS_RESERVED
                FROM         
                    EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
                    EZGI_MASTER_PLAN_SABLON AS EMPS ON EMAP.PROCESS_ID = EMPS.PROCESS_ID
                WHERE     
                    EMAP.MASTER_ALT_PLAN_ID = #Evaluate('C_MASTER_ALT_PLAN_ID_#i#')#
            </cfquery>
           <!--- İlgili Alt plana ait istasyondaki ve tesbit edilen lot numaralara sahip emirlerin id leri bulunuyor--->
            <cfquery name="get_p_orders" datasource="#dsn3#">
                SELECT     
                    P_ORDER_ID
                FROM         
                    PRODUCTION_ORDERS
                WHERE     
                    LOT_NO IN (#lot_no_list#) AND 
                    STATION_ID = #GET_NEW_INFO.WORKSTATION_ID# 
            </cfquery>
            <cfset _p_order_id_list = Valuelist(get_p_orders.P_ORDER_ID)>
            <!---İlgili Emirlerin eski Alt Planları bulunup history dosyasına kaydediliyor.--->
            <cfif len(_p_order_id_list)>
            	<cfquery name="add_master_alt_plan_history" datasource="#dsn3#">
                	INSERT INTO 
                    	EZGI_MASTER_ALT_PLAN_HISTORY
                  	(
                        MASTER_ALT_PLAN_ID, 
                        P_ORDER_ID,
                        REASON_ID,
                        RECORD_ID, 
                        RECORD_DATE, 
                        RECORD_IP
                  	)
                    SELECT 
                    	MASTER_ALT_PLAN_ID, 
                        P_ORDER_ID,
                        <cfif isdefined('attributes.reason_id') and len(attributes.reason_id)>#attributes.reason_id#<cfelse>NULL</cfif>,
                        #session.ep.userid# AS RECORD_ID,
                        #now()# AS RECORD_DATE, 
                        '#cgi.remote_addr#' AS RECORD_IP
					FROM     
                    	EZGI_MASTER_PLAN_RELATIONS
					WHERE  
                    	P_ORDER_ID IN (#_p_order_id_list#)
					ORDER BY 
                    	P_ORDER_ID DESC
                </cfquery>
                <!---İlgili Emirler İstenilen altplan veya ilişkili alt plana update ediliyor--->
                <cfquery name="upd_p_order_relations" datasource="#dsn3#">
                    UPDATE    
                        EZGI_MASTER_PLAN_RELATIONS
                    SET              
                        MASTER_ALT_PLAN_ID = #Evaluate('C_MASTER_ALT_PLAN_ID_#i#')#, 
                        PROCESS_ID = #GET_NEW_INFO.PROCESS_ID#, 
                        STATION_ID = #GET_NEW_INFO.WORKSTATION_ID#
                    WHERE     
                        P_ORDER_ID IN (#_p_order_id_list#)
                </cfquery>
                <!---İlgili Emirler Gönderilmesi istenilen Alt Planın tarihleriyle update ediliyor.--->
                <cfquery name="upd_p_orders" datasource="#dsn3#">
                    UPDATE    
                        PRODUCTION_ORDERS
                    SET              
                        START_DATE = '#GET_NEW_INFO.PLAN_START_DATE#', 
                        FINISH_DATE = '#GET_NEW_INFO.PLAN_FINISH_DATE#',
                     	IS_STOCK_RESERVED = #GET_NEW_INFO.IS_RESERVED#
                    WHERE     
                        P_ORDER_ID IN (#_p_order_id_list#)
                </cfquery>
                <cfquery name="UPD_STATION_IP" datasource="#DSN3#">
                	UPDATE PRODUCTION_OPERATION SET O_STATION_IP = NULL WHERE P_ORDER_ID IN (#_p_order_id_list#)
                </cfquery>
               	<!---Üretim Temp dosyası da Güncelleniyor--->
                <cfif isdefined('attributes.torba')>
                	<cfquery name="upd_p_orders_temp" datasource="#dsn3#">
                		DELETE
                        	EZGI_PRODUCTION_T_TEMP
                      	WHERE     
                            P_ORDER_ID IN (#_p_order_id_list#)
                	</cfquery>
                <cfelse>
                    <cfquery name="upd_p_orders_temp" datasource="#dsn3#">
                        UPDATE    
                            EZGI_PRODUCTION_TEMP_NOW
                        SET              
                            START_DATE = '#GET_NEW_INFO.PLAN_START_DATE#', 
                            FINISH_DATE = '#GET_NEW_INFO.PLAN_FINISH_DATE#'
                        WHERE     
                            P_ORDER_ID IN (#_p_order_id_list#) AND
                            TEMP_EMP_ID = #session.ep.userid#
                    </cfquery>  
               	</cfif>     
            </cfif>
        </cfloop>
    </cftransaction>
    <script language="javascript">
        window.location.reload( true );
    </script>
<cfelse>
	<script language="javascript">
        alert ('<cf_get_lang dictionary_id='662.Alt Plan Seçiniz'>');
		window.location.reload( true );
    </script>
</cfif>    