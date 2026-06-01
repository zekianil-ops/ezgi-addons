<!---
    File: upd_ezgi_iflow_production_parti_operations.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description:
--->
<cfset attributes.master_plan_id = attributes.iflow_master_plan_id>

<!---Şablonu Listesini Alıyoruz--->
<cfquery name="get_station_sablon" datasource="#dsn3#">
	SELECT 
    	EMPS.WORKSTATION_ID, 
        EMPS.SIRA, 
        EMPS.UP_WORKSTATION_ID, 
        ISNULL(EMPS.UP_WORKSTATION_TIME,0) AS UP_WORKSTATION_TIME, 
        W.STATION_NAME,
        ISNULL(EMPS.CURRENT_POINT,0) AS CURRENT_POINT, 
        EMD.FABRIC_CAT, 
        EMD.POINT_METHOD
	FROM     
   		EZGI_MASTER_PLAN_SABLON AS EMPS WITH (NOLOCK) INNER JOIN
     	WORKSTATIONS AS W WITH (NOLOCK) ON EMPS.WORKSTATION_ID = W.STATION_ID INNER JOIN
      	EZGI_MASTER_PLAN_DEFAULTS AS EMD WITH (NOLOCK) ON EMPS.SHIFT_ID = EMD.SHIFT_ID
	WHERE  
    	EMPS.SHIFT_ID = #GET_MASTER_PLAN_INFO.MASTER_PLAN_CAT_ID# AND 
        EMPS.STATUS_ID = 1 AND
        NOT(EMPS.WORKSTATION_ID IS NULL) 
	ORDER BY 
    	EMPS.SIRA
</cfquery>

<!---Hesaplama Şeklini Öğrenmek İçim Master Plan Şablon Dosyasının 1. Satırına Bakıyorum--->
<cfquery name="get_station_sablon_main" dbtype="query">
	SELECT 
     	SIRA, 
       	CURRENT_POINT, 
     	FABRIC_CAT, 
   		POINT_METHOD
	FROM     
   		get_station_sablon
	WHERE  
        SIRA = 1 
</cfquery>

<cfif not get_station_sablon_main.recordcount>
 	Master Plan Tanımı Yapınız. Veya 1. sıra Tanımı Bulunamamıştır
 	<cfdump var="#get_station_sablon_main#">
 	<cfabort>
</cfif>

<cfquery name="get_production_operations_detail" datasource="#dsn3#"><!--- Master Plana Bağlı Tüm Parti ve Emirleri Alt Emirleri Çekiyoruz--->
   	SELECT 
     	PO.P_ORDER_ID,
        EIPO.P_ORDER_PARTI_ID, 
        EIPO.P_ORDER_PARTI_SORT_NO,
       	EPO.P_ORDER_SORT_NO,
        EPO.QUANTITY, 
        EPO.LOT_NO, 
        EPO.IFLOW_P_ORDER_ID,
        EIM.MASTER_PLAN_ID, 
        EIM.MASTER_PLAN_START_DATE
    FROM     
        EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPO WITH (NOLOCK) INNER JOIN
        EZGI_IFLOW_PRODUCTION_ORDERS AS EPO WITH (NOLOCK) ON EIPO.P_ORDER_PARTI_ID = EPO.REL_P_ORDER_ID INNER JOIN
        PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EPO.LOT_NO = PO.LOT_NO INNER JOIN
        EZGI_IFLOW_MASTER_PLAN AS EIM WITH (NOLOCK) ON EPO.MASTER_PLAN_ID = EIM.MASTER_PLAN_ID
    WHERE
  		EPO.MASTER_PLAN_ID IN (#attributes.master_plan_id#)
</cfquery>
<cfquery name="get_production_operations_group" dbtype="query"> <!--- Master Plana Bağlı Tüm Parti ve Üst Emirler Bazında Gurupluyoruz--->
   	SELECT 
      	P_ORDER_PARTI_SORT_NO,
       	P_ORDER_SORT_NO,
       	P_ORDER_PARTI_ID,
       	QUANTITY, 
        LOT_NO, 
        IFLOW_P_ORDER_ID, 
        MASTER_PLAN_ID, 
        MASTER_PLAN_START_DATE
   	FROM
       	get_production_operations_detail
   	GROUP BY
       	P_ORDER_PARTI_SORT_NO,
       	P_ORDER_SORT_NO,
       	P_ORDER_PARTI_ID,
       	QUANTITY, 
        LOT_NO, 
        IFLOW_P_ORDER_ID, 
        MASTER_PLAN_ID,
        MASTER_PLAN_START_DATE	
   	ORDER BY
       	P_ORDER_PARTI_SORT_NO,
       	P_ORDER_SORT_NO,
        P_ORDER_PARTI_ID,
        IFLOW_P_ORDER_ID
</cfquery>

<cfset parti_id = 0>
<cfset iflow_p_order_id_list = ValueList(get_production_operations_group.IFLOW_P_ORDER_ID)>
<cfif Listlen(iflow_p_order_id_list)>
	<cfinclude template="hsp_ezgi_iflow_production_operations.cfm"> <!--- Gün Hesaplamaya Gönderiyoruz--->
</cfif>

<cfif get_station_sablon_main.POINT_METHOD eq 2> <!---Puanlı ise--->

    <cfloop query="get_production_operations_group"> <!---Guruplanmış Üst Emir ve Partileri Döndürüyorum--->
        
        <!---Parti Üretim Emirleri İle Workcube Üretim Emirleri Tarihlerini Güncelleme İşlemi--->
        
        <cfif isdefined('REAL_DAY_#IFLOW_P_ORDER_ID#') and Evaluate('REAL_DAY_#IFLOW_P_ORDER_ID#') gt 0> <!---Gün Hesaplama İşleminde Gün Alınmış ise--->
               
            <cfset real_day = Evaluate('REAL_DAY_#IFLOW_P_ORDER_ID#')>
            
            <cfquery name="upd_p_order" datasource="#dsn3#"> <!---Üst Emirlerin Başlangıç Tarihlerini Güncelliyorum--->
                UPDATE 
                    EZGI_IFLOW_PRODUCTION_ORDERS
                SET  
                    CUTTING_FINISH_DATE = #DateAdd('d',real_day,get_production_operations_group.MASTER_PLAN_START_DATE)#, 
                    START_DATE = #DateAdd('d',real_day,get_production_operations_group.MASTER_PLAN_START_DATE)#, 
                    FINISH_DATE = #DateAdd('d',real_day,get_production_operations_group.MASTER_PLAN_START_DATE)#
                WHERE  
                    IFLOW_P_ORDER_ID =  #get_production_operations_group.IFLOW_P_ORDER_ID#     
            </cfquery>  
            <cfquery name="upd_p_order" datasource="#dsn3#"> <!---Alt Emirlerin Başlangıç Tarihlerini Güncelliyorum--->
                UPDATE 
                    PRODUCTION_ORDERS
                SET  
                    START_DATE = #DateAdd('d',real_day,get_production_operations_group.MASTER_PLAN_START_DATE)#, 
                    FINISH_DATE = #DateAdd('d',real_day,get_production_operations_group.MASTER_PLAN_START_DATE)#
                WHERE  
                    LOT_NO =  '#get_production_operations_group.LOT_NO#'    
            </cfquery> 
            <!---Operasyon Üretim Tarihleri Güncelleme İşlemi--->
            <cfset x_start_date = DateAdd('d',real_day,get_production_operations_group.MASTER_PLAN_START_DATE)>
      		<cfinclude template="upd_ezgi_iflow_production_operation.cfm"> <!---Operasyonlara Tarih Hesaplanarak Yazdırılıyor--->
        <cfelse>
            <cfquery name="upd_p_order" datasource="#dsn3#"> <!---Üst Emirlerin Başlangıç Tarihlerini Güncelliyorum--->
                UPDATE 
                    EZGI_IFLOW_PRODUCTION_ORDERS
                SET  
                    CUTTING_FINISH_DATE = '#get_production_operations_group.MASTER_PLAN_START_DATE#', 
                    START_DATE = '#get_production_operations_group.MASTER_PLAN_START_DATE#',
                    FINISH_DATE = '#get_production_operations_group.MASTER_PLAN_START_DATE#'
                WHERE  
                    IFLOW_P_ORDER_ID =  #get_production_operations_group.IFLOW_P_ORDER_ID#     
            </cfquery>  
            <cfquery name="upd_p_order" datasource="#dsn3#"> <!---Alt Emirlerin Başlangıç Tarihlerini Güncelliyorum--->
                UPDATE 
                    PRODUCTION_ORDERS
                SET  
                    START_DATE = '#get_production_operations_group.MASTER_PLAN_START_DATE#',
                    FINISH_DATE = '#get_production_operations_group.MASTER_PLAN_START_DATE#'
                WHERE  
                    LOT_NO =  '#get_production_operations_group.LOT_NO#'    
            </cfquery>
		   <!--- Parti Üretim Tarihleri Güncelleme İşlemi--->
                                    
            <cfif parti_id neq get_production_operations_group.P_ORDER_PARTI_ID>
                <cfset parti_id = get_production_operations_group.P_ORDER_PARTI_ID>
                <cfif isdefined('REAL_DAY_#IFLOW_P_ORDER_ID#') and Evaluate('REAL_DAY_#IFLOW_P_ORDER_ID#') gt 0>
                    <cfset real_day = Evaluate('REAL_DAY_#IFLOW_P_ORDER_ID#')>
                    <cfset x_start_date = DateAdd('d',real_day,get_production_operations_group.MASTER_PLAN_START_DATE)>
                <cfelse>
                    <cfset x_start_date = DateAdd('d',0,get_production_operations_group.MASTER_PLAN_START_DATE)>
                </cfif>
                <cfquery name="upd_p_order" datasource="#dsn3#"> <!---Partilerin Başlangıç Tarihlerini Güncelliyorum--->
                    UPDATE 
                        EZGI_IFLOW_PRODUCTION_ORDERS_PARTI
                    SET  
                        P_ORDER_START_DATE = #x_start_date#,
                        P_ORDER_FINISH_DATE = #x_start_date#
                    WHERE  
                        P_ORDER_PARTI_ID =  #get_production_operations_group.P_ORDER_PARTI_ID#     
                </cfquery>
                
                <!---Operasyon Üretim Tarihleri Güncelleme İşlemi--->
                
                <cfinclude template="upd_ezgi_iflow_production_operation.cfm"> <!---Operasyonlara Tarih Hesaplanarak Yazdırılıyor--->
    		</cfif>
        </cfif>
    </cfloop>
<cfelseif  get_station_sablon_main.POINT_METHOD eq 1> <!---Süre Hesaplamalı ise--->
	<cfif isdefined('operasyonlar') and operasyonlar.recordcount>
    	<cfloop query="operasyonlar">
    		<cfquery name="upd_p_operation_time" datasource="#dsn3#">
             	UPDATE 
                	PRODUCTION_OPERATION
               	SET          
                 	O_START_DATE = '#operasyonlar.basla#', 
                 	O_FINISH_DATE = '#operasyonlar.bitir#',
                    STATION_ID = #operasyonlar.station_id#,
                    O_TOTAL_PROCESS_TIME = #operasyonlar.optimum_total#
            	WHERE
                 	P_OPERATION_ID = #operasyonlar.P_OPERATION_ID#
         	</cfquery>
    	</cfloop>
        <cfquery name="get_upd_parti_operations" dbtype="query">
        	SELECT
            	P_ORDER_PARTI_NUMBER,
            	MAX(BITIR) AS BITIR,
                MIN(BASLA) AS BASLA
        	FROM
            	operasyonlar
          	WHERE
            	NOT (BASLA IS NULL) AND NOT (BITIR IS NULL) 
          	GROUP BY	
        		P_ORDER_PARTI_NUMBER
        </cfquery>
        <cfif get_upd_parti_operations.recordcount>
            <cfloop query="get_upd_parti_operations">
            	<cfquery name="upd_p_operation_time" datasource="#dsn3#">
                    UPDATE 
                        EZGI_IFLOW_PRODUCTION_ORDERS_PARTI
                    SET  
                    	P_ORDER_START_DATE = '#get_upd_parti_operations.BASLA#', 
                        P_ORDER_FINISH_DATE = '#get_upd_parti_operations.BITIR#'
                    WHERE
                        P_ORDER_PARTI_NUMBER = '#get_upd_parti_operations.P_ORDER_PARTI_NUMBER#'
                </cfquery>
            </cfloop>
        </cfif>
        <cfquery name="get_upd_iflow_p_order_operations" dbtype="query">
        	SELECT
            	IFLOW_P_ORDER_ID,
            	MAX(BITIR) AS BITIR,
                MIN(BASLA) AS BASLA
        	FROM
            	operasyonlar
          	WHERE
            	NOT (BASLA IS NULL) AND NOT (BITIR IS NULL) 
          	GROUP BY	
        		IFLOW_P_ORDER_ID
        </cfquery>
        <cfif get_upd_iflow_p_order_operations.recordcount>
            <cfloop query="get_upd_iflow_p_order_operations">
            	<cfquery name="upd_p_operation_time" datasource="#dsn3#">
                    UPDATE 
                        EZGI_IFLOW_PRODUCTION_ORDERS
                    SET  
                    	START_DATE = '#get_upd_iflow_p_order_operations.BASLA#', 
                        FINISH_DATE = '#get_upd_iflow_p_order_operations.BITIR#'
                    WHERE
                        IFLOW_P_ORDER_ID = #get_upd_iflow_p_order_operations.IFLOW_P_ORDER_ID#
                </cfquery>
            </cfloop>
        </cfif>
        <cfquery name="get_upd_p_order_operations" dbtype="query">
        	SELECT
            	P_ORDER_ID,
            	MAX(BITIR) AS BITIR,
                MIN(BASLA) AS BASLA
        	FROM
            	operasyonlar
          	WHERE
            	NOT (BASLA IS NULL) AND NOT (BITIR IS NULL) 
          	GROUP BY	
        		P_ORDER_ID
        </cfquery>
        <cfif get_upd_p_order_operations.recordcount>
            <cfloop query="get_upd_p_order_operations">
            	<cfquery name="upd_p_operation_time" datasource="#dsn3#">
                    UPDATE 
                        PRODUCTION_ORDERS
                    SET  
                    	START_DATE = '#get_upd_p_order_operations.BASLA#', 
                        FINISH_DATE = '#get_upd_p_order_operations.BITIR#'
                    WHERE
                        P_ORDER_ID = #get_upd_p_order_operations.P_ORDER_ID#
                </cfquery>
            </cfloop>
        </cfif>
    </cfif>
</cfif>