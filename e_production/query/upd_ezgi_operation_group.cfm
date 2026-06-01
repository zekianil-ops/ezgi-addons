<!---
    File: upd_ezgi_operation_group.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---Plan Takip Kullanılacakmı--->
<cfset trace_method = 0>
<cfif isdefined('attributes.master_plan_id')>
    <cfquery name="get_trace_method" datasource="#dsn3#">
        SELECT 
            ISNULL(TRACE_METHOD,0) TRACE_METHOD
        FROM     
            EZGI_MASTER_PLAN_DEFAULTS
        WHERE  
            SHIFT_ID =
                    (
                        SELECT 
                            MASTER_PLAN_CAT_ID
                        FROM      
                            EZGI_MASTER_PLAN
                        WHERE   
                            MASTER_PLAN_ID = #attributes.master_plan_id#
                    )
    </cfquery>
    <cfif get_trace_method.recordcount and get_trace_method.TRACE_METHOD eq 1>
    	<cfset trace_method = get_trace_method.TRACE_METHOD>
        <cfset trace_amount = 1>
    </cfif>
</cfif>
<cfset default_optimum_time = 15>
<cfset yontem =2><!---Aynı Siparişten Emir Oluşsa Bile Farklı Lot İle Gurupla--->
<cfif yontem eq 1><!---Aynı Siparişten Gelenler Tek Lot_no ile Guruplanır--->
    <cfloop From = "1" To = "#ListLen(p_order_id_list)#" index = "Counter">
        <cfset _p_order_id=ListGetAt(p_order_id_list, Counter)>  
        <cfquery name="GET_ROW" datasource="#dsn3#">
            SELECT 	DISTINCT
                ORDER_NUMBER, 
                PRODUCTION_ORDERS_ROW.ORDER_ID
            FROM	PRODUCTION_ORDERS_ROW,
                ORDERS
            WHERE	PRODUCTION_ORDERS_ROW.PRODUCTION_ORDER_ID = #_p_order_id# AND
                PRODUCTION_ORDERS_ROW.ORDER_ID = ORDERS.ORDER_ID 
        </cfquery>
        <cfquery name="GET_ORDER" datasource="#dsn3#">
            SELECT 	
                ORW.ORDER_ROW_ID,
                CASE 
                    WHEN LEFT(PO.LOT_NO,1) = '-' THEN SUBSTRING(PO.LOT_NO,2,LEN(PO.LOT_NO)-1)
                    ELSE PO.LOT_NO
                END 
                    LOT_NO
            FROM    
                PRODUCTION_ORDERS_ROW POR,  
                ORDERS O,
                ORDER_ROW ORW,
                PRODUCTION_ORDERS PO
            WHERE  	
                (POR.PRODUCTION_ORDER_ID = #_p_order_id#)AND 
                (POR.ORDER_ID = O.ORDER_ID) AND 
                (O.ORDER_ID = ORW.ORDER_ID) AND 
                (PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID)AND
                (ORW.ORDER_ROW_CURRENCY = - 5)
        </cfquery>
        <cfset _order_row_list = ValueList(GET_ORDER.ORDER_ROW_ID)>
        <cfif GET_ORDER.recordcount> 
            <cfquery name="GET_ORDER_POR" datasource="#dsn3#">
                SELECT  
                    POR.PRODUCTION_ORDER_ID as P_ORDER_ID
                FROM	
                    ORDER_ROW ORW,
                    PRODUCTION_ORDERS_ROW POR
                WHERE   
                    (ORW.ORDER_ROW_ID IN (#_order_row_list#))
                    AND (ORW.ORDER_ROW_ID=POR.ORDER_ROW_ID) 
            </cfquery>
        <cfelse> <!---Siparis Kaynakli degil ise Üretim Emir Bilgilerinin Toplanmasi Toplanmasi--->
            <cfquery name="GET_ORDER" datasource="#dsn3#">
                SELECT	
                    CASE 
                        WHEN LEFT(PO.LOT_NO,1) = '-' THEN SUBSTRING(PO.LOT_NO,2,LEN(PO.LOT_NO)-1)
                        ELSE PO.LOT_NO
                    END 
                        LOT_NO,
                    S.PRODUCT_ID, 
                    S.PRODUCT_NAME, 
                    PO.QUANTITY, 
                    PO.STOCK_ID, 
                    'STOK ÜRETIM' AS ORDER_NUMBER,
                    '' AS ORDER_DATE,
                    '' AS DELIVERDATE,
                    PO.START_DATE,
                    PO.FINISH_DATE,
                    PU.MAIN_UNIT as UNIT
                FROM    	 
                    PRODUCT_UNIT AS PU INNER JOIN
                    STOCKS AS S ON PU.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
                    PRODUCTION_ORDERS AS PO ON S.STOCK_ID = PO.STOCK_ID
                WHERE   
                    (PO.P_ORDER_ID= #_p_order_id#)
            </cfquery>
            <cfquery name="GET_ORDER_POR" datasource="#dsn3#">
                SELECT     
                    P_ORDER_ID
                FROM         
                    PRODUCTION_ORDERS
                WHERE     
                    (LOT_NO LIKE '%#GET_ORDER.LOT_NO#')
            </cfquery>
        
        </cfif>
        <cfset p_order_list_1 = ValueList(GET_ORDER_POR.P_ORDER_ID)>
        <cfset bugun=now()>
    
        <cfquery name="GET_ISTASYON_DURUMU" datasource="#dsn3#">
            UPDATE 	
                PRODUCTION_ORDERS
            SET	
                IS_GROUP_LOT=1, 
                IS_STAGE=0, 
                LOT_NO= #GET_ORDER.LOT_NO#,
                P_ORDER_NO= ( SELECT CASE 
                                        WHEN LEFT(PO.P_ORDER_NO,1) = '-' THEN SUBSTRING(PO.P_ORDER_NO,2,LEN(PO.P_ORDER_NO)-1)
                                        ELSE PO.P_ORDER_NO
                                    END 
                                    P_NO
                                FROM  PRODUCTION_ORDERS PO
                                WHERE PO.P_ORDER_NO = PRODUCTION_ORDERS.P_ORDER_NO
                                )
                
            WHERE   
                (P_ORDER_ID IN (#p_order_list_1#))
        </cfquery>
    </cfloop>
<cfelse><!---Aynı Siparişten Emir Oluşsa Bile Farklı Lot_No İle Guruplanır--->
    <cfquery name="get_operation_default_station_control" datasource="#DSN3#"> <!---Default İstasyon Tanımı Yapılmamış Operasyon Sorguluyoruz--->
    	SELECT        
        	TBL2.OPERATION_TYPE_ID, 
            OPERATION_TYPES.OPERATION_TYPE
		FROM            
        	OPERATION_TYPES INNER JOIN
          	(
            	SELECT        
                	OPERATION_TYPE_ID
             	FROM            
                	PRODUCTION_OPERATION AS PO
             	WHERE        
                	P_ORDER_ID IN (#p_order_id_list#)
              	GROUP BY 
                	OPERATION_TYPE_ID
          	) AS TBL2 ON OPERATION_TYPES.OPERATION_TYPE_ID = TBL2.OPERATION_TYPE_ID LEFT OUTER JOIN
         	(
            	SELECT        
                	PO.OPERATION_TYPE_ID, ISNULL(WP.DEFAULT_STATUS, 0) AS DEFAULT_STATUS
              	FROM            
                	PRODUCTION_OPERATION AS PO INNER JOIN
            		WORKSTATIONS_PRODUCTS AS WP ON PO.OPERATION_TYPE_ID = WP.OPERATION_TYPE_ID
              	WHERE        
                	PO.P_ORDER_ID IN (#p_order_id_list#) AND 
                    ISNULL(WP.DEFAULT_STATUS, 0) = 1
             	GROUP BY 
                	PO.OPERATION_TYPE_ID, WP.DEFAULT_STATUS
          	) AS TBL1 ON TBL2.OPERATION_TYPE_ID = TBL1.OPERATION_TYPE_ID
		WHERE        
        	TBL1.OPERATION_TYPE_ID IS NULL
    </cfquery>
    <cfif get_operation_default_station_control.recordcount>
    	<script type="text/javascript">
			alert("<cf_get_lang dictionary_id='657.Defult İstasyon Tanımlanmamış Operasyonlar Mevcut'> : <cfoutput query="get_operation_default_station_control">#get_operation_default_station_control.OPERATION_TYPE#</cfoutput>");
			history.back();
        </script>
        <cfabort>
    <cfelse>
    	<cfloop From = "1" To = "#ListLen(p_order_id_list)#" index = "Counter"><!--- Her Üretim emrini tektek lot noya gurupluyoruz--->
			<cfset _p_order_id=ListGetAt(p_order_id_list, Counter)>  
         	<cfquery name="GET_ORDER" datasource="#dsn3#">
               	SELECT	
                	QUANTITY,
             		CASE 
                    	WHEN LEFT(LOT_NO,1) = '-' THEN SUBSTRING(LOT_NO,2,LEN(LOT_NO)-1)
                  		ELSE LOT_NO
                  	END 
                    	LOT_NO
            	FROM    	 
                 	PRODUCTION_ORDERS 
               	WHERE   
                 	P_ORDER_ID= #_p_order_id#
          	</cfquery>
            <!--- Eğer Takip No Yapılacaksa--->
            <cfif GET_ORDER.recordcount and Len(GET_ORDER.LOT_NO) and trace_method neq 0>
                <cfquery name="get_trace" datasource="#dsn3#">
                    SELECT 
                        SUM(AMOUNT) AS AMOUNT
                    FROM     
                        EZGI_PRODUCTION_ORDERS_TRACE
                    WHERE  
                        LOT_NO = '#GET_ORDER.LOT_NO#' AND 
                        NOT (TRACE_NO IS NULL)
                </cfquery>
                <cfif (get_trace.recordcount and get_trace.AMOUNT neq GET_ORDER.QUANTITY) or not get_trace.recordcount> <!---Takip No yapılmadıysa veya Takip No Eksikse--->
                	<cfquery name="del_trace" datasource="#dsn3#">
                    	DELETE FROM EZGI_PRODUCTION_ORDERS_TRACE WHERE LOT_NO = '#GET_ORDER.LOT_NO#'
                    </cfquery>
                    <cfset total_trace_amount = GET_ORDER.QUANTITY>
                    <cfloop from="1" to="#floor(GET_ORDER.QUANTITY)#" index="trace_number" step="#trace_amount#">
                    	<cfset trace_amount_value = trace_amount>
                    	<cfinclude template="upd_ezgi_operation_group_insert.cfm">
                        <cfset total_trace_amount = total_trace_amount - trace_amount>
                    </cfloop>
                    <cfif total_trace_amount gt 0>
                    	<cfset trace_amount_value = total_trace_amount>
                    	<cfinclude template="upd_ezgi_operation_group_insert.cfm">	
                    </cfif>
                </cfif>
            </cfif>
            <!--- Eğer Takip No Yapılacaksa--->
            
         	<cfquery name="GET_ORDER_POR" datasource="#dsn3#"> <!---Aynı Lotta Bulunan İlişkili Alt Emirlerin ID lerini topluyoruz--->
              	SELECT  P_ORDER_ID FROM PRODUCTION_ORDERS WHERE LOT_NO LIKE '%#GET_ORDER.LOT_NO#'
        	</cfquery>
            <cfset p_order_list_1 = ValueList(GET_ORDER_POR.P_ORDER_ID)>
            <cfquery name="GET_ISTASYON_DURUMU" datasource="#dsn3#"> <!---İlgili Alanları Update ediyoruz--->
                UPDATE 	
                    PRODUCTION_ORDERS
                SET	
                    IS_GROUP_LOT=1, 
                    IS_STAGE=0, 
                    LOT_NO= #GET_ORDER.LOT_NO#,
                    P_ORDER_NO= ( SELECT TOP (1) CASE 
                                            WHEN LEFT(PO.P_ORDER_NO,1) = '-' THEN SUBSTRING(PO.P_ORDER_NO,2,LEN(PO.P_ORDER_NO)-1)
                                            ELSE PO.P_ORDER_NO
                                        END 
                                        P_NO
                                    FROM  PRODUCTION_ORDERS PO
                                    WHERE PO.P_ORDER_NO = PRODUCTION_ORDERS.P_ORDER_NO
                                    )
                    
                WHERE   
                    P_ORDER_ID IN (#p_order_list_1#) AND
                    IS_STAGE NOT IN (1,2)
            </cfquery>
            <cfquery name="get_operation_info" datasource="#dsn3#"> <!---Emirlere Bağlı Operasyonların Default olanlarının ilgili sürelerini ve istasyonlarını buluyoruz--->
                SELECT    
                    WP.WS_ID,
                    PO.OPERATION_TYPE_ID, 
                    WP.DEFAULT_STATUS, 
                    WP.PRODUCTION_TIME, 
                    WP.SETUP_TIME, 
                    ISNULL(EO.OPTIMUM_TIME, #default_optimum_time#) AS OPTIMUM_TIME
                FROM 
                	PRODUCTION_OPERATION AS PO INNER JOIN
                	WORKSTATIONS_PRODUCTS AS WP ON PO.OPERATION_TYPE_ID = WP.OPERATION_TYPE_ID INNER JOIN
                  	PRODUCTION_ORDERS AS POR ON PO.P_ORDER_ID = POR.P_ORDER_ID LEFT OUTER JOIN
                	EZGI_OPERATION_OPTIMUM_TIME AS EO ON WP.OPERATION_TYPE_ID = EO.OPERATION_TYPE_ID AND POR.STOCK_ID = EO.STOCK_ID
           
                    <!---PRODUCTION_OPERATION AS PO INNER JOIN
                    WORKSTATIONS_PRODUCTS AS WP ON PO.OPERATION_TYPE_ID = WP.OPERATION_TYPE_ID INNER JOIN
                    PRODUCTION_ORDERS AS POR ON PO.P_ORDER_ID = POR.P_ORDER_ID LEFT OUTER JOIN
                    EZGI_OPERATION_OPTIMUM_TIME AS EO ON WP.WS_ID = EO.STATION_ID AND POR.STOCK_ID = EO.STOCK_ID--->
                WHERE        
                    PO.P_ORDER_ID IN (#p_order_list_1#) AND
                    WP.DEFAULT_STATUS = 1
                GROUP BY 
                    WP.WS_ID,
                    PO.OPERATION_TYPE_ID, 
                    WP.PRODUCTION_TIME, 
                    WP.SETUP_TIME, 
                    ISNULL(EO.OPTIMUM_TIME, #default_optimum_time#), 
                    WP.DEFAULT_STATUS
            </cfquery>
            <cfoutput query="get_operation_info"> <!---Bulunan operasyon bilgilerini döndürüyoruz--->
                <cfquery name="upd_o_info" datasource="#dsn3#"> <!---İlgili operasyonların bilgilerini update ediyoruz--->
                    UPDATE       
                        PRODUCTION_OPERATION
                    SET                
                        O_TOTAL_PROCESS_TIME = ROUND((#PRODUCTION_TIME#*PRODUCTION_OPERATION.AMOUNT*60) + (#SETUP_TIME#*60) + (#OPTIMUM_TIME#*PRODUCTION_OPERATION.AMOUNT),0), 
                        O_EXTRA_PROCESS_TIME = ROUND(#PRODUCTION_TIME#*PRODUCTION_OPERATION.AMOUNT*60,0), 
                        O_SETUP_TIME = ROUND(#SETUP_TIME#*60,0), 
                        O_START_DATE = (SELECT START_DATE FROM PRODUCTION_ORDERS AS POR WHERE P_ORDER_ID = PRODUCTION_OPERATION.P_ORDER_ID), 
                        O_STATION_IP = #WS_ID#
                    WHERE        
                        P_ORDER_ID IN (#p_order_list_1#) AND 
                        OPERATION_TYPE_ID = #get_operation_info.OPERATION_TYPE_ID#
                </cfquery>
            </cfoutput>
            <cfquery name="get_o_start_date" datasource="#dsn3#"> <!---Update edilen Emirlerin operasyonlarını plan tarihine göre gurupluyoruz--->
                SELECT format(O_START_DATE, 'yyyy-MM-dd') O_START_DATE, format(DATEADD(d, 1, O_START_DATE), 'yyyy-MM-dd') O_START_DATE1 FROM PRODUCTION_OPERATION WHERE P_ORDER_ID IN (#p_order_list_1#) GROUP BY format(O_START_DATE, 'yyyy-MM-dd'), format(DATEADD(d, 1, O_START_DATE), 'yyyy-MM-dd')
            </cfquery>
            <cfloop query="get_o_start_date"><!--- Guruplanan emirlerin tarihlerini döndürüyoruz--->
                <cfquery name="get_o_station_id" datasource="#dsn3#"> <!---İlgili tarihteki Tüm operasyonları atanmış istasyona göre listeliyoruz.--->
                    SELECT 
                        O_STATION_IP,
                        P_OPERATION_ID
                    FROM            
                        PRODUCTION_OPERATION
                    WHERE        
                        O_START_DATE >= CONVERT(DATETIME, '#get_o_start_date.O_START_DATE# 00:00:00', 102) AND
                        O_START_DATE < CONVERT(DATETIME, '#get_o_start_date.O_START_DATE1# 00:00:00', 102)
                </cfquery>
                <cfset station_list = ListDeleteDuplicates(Valuelist(get_o_station_id.O_STATION_IP),',')>
                <cfset p_operation_id_list = Valuelist(get_o_station_id.P_OPERATION_ID)>
                <cfloop list="#station_list#" index="k"> <!---İstasyona Göre Döndürüp İlgili İstasyondaki Tüm Operasyonları Buluyoruz.--->
                    <cfquery name="get_operation_id" datasource="#dsn3#">
                        SELECT 
                            P_OPERATION_ID
                        FROM
                            PRODUCTION_OPERATION
                        WHERE
                            O_STATION_IP = #k# AND
                            P_OPERATION_ID  IN (#p_operation_id_list#)
                        ORDER BY
                            ISNULL(O_CURRENT_NUMBER,P_OPERATION_ID)	
                    </cfquery>
                    <cfset station_operation_id_list = ValueList(get_operation_id.P_OPERATION_ID)>
                    <cfset sira = 0>
                    <cfloop list="#station_operation_id_list#" index="j">
                        <cfset sira = sira + 1>
                        <cfquery name="upd_operation_station" datasource="#dsn3#"> <!---İlgili Operasyonları Yeniden 1 den başlama Üzere Sıra No Veriyoruz.--->
                            UPDATE       
                                PRODUCTION_OPERATION
                            SET                
                                O_CURRENT_NUMBER = #sira#
                            WHERE        
                                P_OPERATION_ID = #j#
                        </cfquery>
                    </cfloop>
                </cfloop>
            </cfloop>
        </cfloop> 
    </cfif>
</cfif>  

<cfif isdefined('attributes.auto_print')>
	<cflocation url="#request.self#?fuseaction=objects.popup_print_files&print_type=281&iid=#attributes.p_order_id_list#&master_alt_plan_id=#attributes.master_alt_plan_id#" addtoken="No">
    <script language="javascript">
		wrk_opener_reload();
	</script>
<cfelse>
	<cflocation url="#request.self#?fuseaction=prod.upd_ezgi_master_sub_plan_manual&master_plan_id=#attributes.master_plan_id#&master_alt_plan_id=#attributes.master_alt_plan_id#&islem_id=#attributes.islem_id#" addtoken="No">
</cfif>
  
