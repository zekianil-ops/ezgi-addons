<!---
    File: hsp_ezgi_iflow_production_operations.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset x_total_point = 0>
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
        EMD.POINT_METHOD,
        EMD.WORK_TIME
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
   		POINT_METHOD,
        WORK_TIME
	FROM     
   		get_station_sablon
	WHERE  
        SIRA = 1 
</cfquery>

<cfif not get_station_sablon_main.recordcount>
 	<script type="text/javascript">
      	alert("Ilk Olarak Çalışma Programlarındaki İstasyon Tanımlarını Yapınız!");
      	window.close()
 	</script>
 	<cfabort>
</cfif>

<cfif get_station_sablon_main.POINT_METHOD eq 2> <!---Puanlı ise--->

 	<cfif get_station_sablon_main.CURRENT_POINT eq 0> <!---1. Sıraya Gün Puanı Tanımlanmış mı--->
     	Master Plan 1. Sıra için Puan Tanımı Yapmalısınız
      	<cfdump var="#get_station_sablon_main#">
     	<cfabort>
  	<cfelse>
     	<cfset x_daily_point = get_station_sablon_main.CURRENT_POINT> <!---Bir Günü Belirleyen Üretim Puanı--->
 	</cfif>
    
	<cfif not len(get_station_sablon_main.FABRIC_CAT)> <!---Optimizasyon Kategorisi Tanımlanmış mı--->
    	Master Plan Şablonunda Optimizasyon Kategorisi Tanımlayın
      	<cfdump var="#get_station_sablon_main#">
    	<cfabort>
 	<cfelse>
    	<cfset attributes.point_code = get_station_sablon_main.FABRIC_CAT><!---Optimizasyon Kategorisi--->
 	</cfif>
    
    <!---Puanlı Dağıtm Anahtarı Hesaplama--->
    <cfquery name="get_production_point" datasource="#dsn3#"><!---Optimizasyon Kategorinde belirtilen Ürünlerin Ürün Ağacındaki Ek Bilgilerin 2. Satırından Alınıyor--->
                SELECT 
                    TBL.PROPERTY2,
                    EPO.IFLOW_P_ORDER_ID, 
                    S.PRODUCT_CODE, 
                    PO.P_ORDER_ID, 
                    CAST(ISNULL(TBL.PROPERTY2,0) AS float) AS PUAN
                FROM     
                    EZGI_IFLOW_PRODUCTION_ORDERS AS EPO WITH (NOLOCK) INNER JOIN
                    PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EPO.LOT_NO = PO.LOT_NO INNER JOIN
                    STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
                    (
                        SELECT 
                            STOCK_ID, 
                            PROPERTY2
                        FROM      
                            PRODUCT_TREE_INFO_PLUS
                        WHERE   
                            INFO_ID IN
                                    (
                                        SELECT 
                                            MAX(INFO_ID) AS INFO_ID
                                        FROM      
                                            PRODUCT_TREE_INFO_PLUS AS PIPO
                                        GROUP BY 
                                            STOCK_ID
                                    )
                    ) AS TBL ON S.STOCK_ID = TBL.STOCK_ID
                WHERE  
                    EPO.IFLOW_P_ORDER_ID IN (#iflow_p_order_id_list#) AND 
                    S.PRODUCT_CODE LIKE '#attributes.point_code#%' 
    </cfquery>
    <cfquery name="get_production_point_group" dbtype="query"> <!---Parti Üretim Emrindeki Ürünün 1 adedinin paketlerinin Toplam Puanı hesaplanıyor--->
        SELECT
            IFLOW_P_ORDER_ID,
            SUM(PUAN) AS PUAN
        FROM
            get_production_point
        GROUP BY
            IFLOW_P_ORDER_ID	
    </cfquery>
    
    <!---Her Parti Üretim Satırın Ayrı Ayrı Toplam Puanı tanımlanıyor--->
    <cfif get_production_point_group.recordcount>
        <cfoutput query="get_production_point_group">
            <cfset 'PUAN_#IFLOW_P_ORDER_ID#' = PUAN>
        </cfoutput>
    </cfif>
    
    <cfoutput query="get_production_operations_group">
        <cfif isdefined('PUAN_#IFLOW_P_ORDER_ID#')>
            <cfset x_total_point = x_total_point + (Evaluate('PUAN_#IFLOW_P_ORDER_ID#')*QUANTITY)> <!---Her Parti Üretim Emri Satırının Toplam Puanı Hesaplanıyor.--->
        </cfif>
        <cfif x_daily_point gt 0 and x_total_point gt 0>
            <cfset 'REAL_DAY_#IFLOW_P_ORDER_ID#' = floor(x_total_point/x_daily_point)> <!---Her Parti Üretim Emri Satırının Toplam Puanı Günlük Puana Bölünerek Gün Hesaplanıyor.--->
        <cfelse>
            <cfset 'REAL_DAY_#IFLOW_P_ORDER_ID#' = 0>
        </cfif>
     	<cfif isdefined('REAL_DAY_#IFLOW_P_ORDER_ID#') and Evaluate('REAL_DAY_#IFLOW_P_ORDER_ID#') gt 0>
           	<cfset real_day = Evaluate('REAL_DAY_#IFLOW_P_ORDER_ID#')>
			<cfset plus_day = 0>
            <cfset kontrol_edilecek_gun_sayisi = real_day>
            <cfloop condition="true">
                <cfset plus_day = 0>
            
                <!--- İlk real_day + varsa önceki plus_day kadar günü kontrol et --->
                <cfloop index="i" from="1" to="#kontrol_edilecek_gun_sayisi#">
                    <cfset kontrolTarihi = dateAdd("d", i, get_production_operations_group.MASTER_PLAN_START_DATE)>
                    <cfif dayOfWeek(kontrolTarihi) EQ 1 OR dayOfWeek(kontrolTarihi) EQ 7>
                        <cfset plus_day = plus_day + 1>
                    </cfif>
                </cfloop>
            
                <!--- Eğer yeni plus_day varsa, tekrar kontrol et --->
                <cfif kontrol_edilecek_gun_sayisi LT real_day + plus_day>
                    <cfset kontrol_edilecek_gun_sayisi = real_day + plus_day>
                <cfelse>
                    <!--- artık hafta sonu olmayan 10 iş günü kadar ilerlenmiş demektir --->
                    <cfbreak>
                </cfif>
            </cfloop>
           	<cfset 'REAL_DAY_#IFLOW_P_ORDER_ID#' = kontrol_edilecek_gun_sayisi>
     	</cfif> 
    </cfoutput>
    
<cfelseif  get_station_sablon_main.POINT_METHOD eq 1> <!---Süre Hesaplamalı ise--->

    <cfquery name="get_station_sablon" datasource="#dsn3#">
        SELECT 
            EMPS.SIRA, 
            EMPS.UP_WORKSTATION_ID, 
            ISNULL(EMPS.UP_WORKSTATION_TIME, 0) AS UP_WORKSTATION_TIME, 
            W.STATION_NAME, 
            ISNULL(EMPS.CURRENT_POINT, 0) AS CURRENT_POINT, 
            EMD.FABRIC_CAT, 
            EMD.POINT_METHOD, 
            EMD.WORK_TIME, 
            W.STATION_ID
        FROM     
            EZGI_MASTER_PLAN_SABLON AS EMPS WITH (NOLOCK) INNER JOIN
            EZGI_MASTER_PLAN_DEFAULTS AS EMD WITH (NOLOCK) ON EMPS.SHIFT_ID = EMD.SHIFT_ID INNER JOIN
            WORKSTATIONS AS W WITH (NOLOCK) ON EMPS.WORKSTATION_ID = W.UP_STATION
        WHERE 
            ISNULL(W.ACTIVE,0) = 1 AND 
            EMPS.SHIFT_ID = 1 AND 
            EMPS.STATUS_ID = 1 AND 
            NOT (EMPS.WORKSTATION_ID IS NULL)
        ORDER BY 
            EMPS.SIRA, 
            W.STATION_NAME
    </cfquery>
    <cfif not get_station_sablon.recordcount>
		<script type="text/javascript">
            alert("Çalışma Programı Tanımları Eksik. Sistem Yöneticinize Bildirin.!");
            window.close()
        </script>
        <cfabort>
    </cfif>
    <cfif not len(get_station_sablon.WORK_TIME) or not get_station_sablon.WORK_TIME gt 0>
        <script type="text/javascript">
            alert("Çalışma Programı Tanımlarında Başlama ve Bitiş Tarihleri Eksik. Sistem Yöneticinize Bildirin.!");
            window.close()
        </script>
        <cfabort>
    <cfelse>
        <cfset gunlukSure = get_station_sablon.WORK_TIME>
    </cfif>
    
    <cfquery name="get_station_list" dbtype="query">
        SELECT
            SIRA,
            STATION_ID,
            STATION_NAME
        FROM
            get_station_sablon
        GROUP BY
            SIRA,
            STATION_ID,
            STATION_NAME
    </cfquery>

    <cfquery name="get_production_operations" datasource="#dsn3#">
        SELECT DISTINCT 
            EPO.IFLOW_P_ORDER_ID, 
            EPO.P_ORDER_SORT_NO,
            PO.P_ORDER_ID, 
            PO.QUANTITY, 
            PO.P_ORDER_NO, 
            PO.STOCK_ID, 
            PO.SPEC_MAIN_ID,
            PO.PRODUCTION_LEVEL,
            ISNULL(PO.PO_RELATED_ID,1) AS PO_RELATED_ID, 
            EIM.MASTER_PLAN_NUMBER, 
            EIM.MASTER_PLAN_DETAIL,
            EIM.MASTER_PLAN_ID, 
            EIM.MASTER_PLAN_START_DATE,
            PORR.O_START_DATE, 
            PORR.O_CURRENT_NUMBER, 
            EIPO.P_ORDER_PARTI_NUMBER, 
            EIPO.P_ORDER_PARTI_SORT_NO,
            PO.LOT_NO, 
            ISNULL(PORR.AMOUNT, 0) AS AMOUNT, 
            PORR.STAGE, 
            PORR.OPERATION_TYPE_ID, 
            PORR.O_STATION_IP, 
            PORR.O_STATION_START_DATE, 
            PORR.P_OPERATION_ID, 
            PORR.STAGE,
            OT.OPERATION_TYPE, 
            ISNULL((
                    SELECT TOP (1) 
                        CASE 
                            WHEN 
                                ISNULL(OPTIMUM_TIME,0) = 0
                            THEN 
                                1
                            ELSE 
                                OPTIMUM_TIME 
                        END AS OPTIMUM_TIME
                    FROM 
                        EZGI_OPERATION_OPTIMUM_TIME
                    WHERE   
                        STOCK_ID = PO.STOCK_ID AND 
                        OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID AND 
                        STATUS = 1
            ), 1) AS OPTIMUM_TIME, 
            WP.WS_ID, 
            W.STATION_NAME, 
            W.STATION_ID, 
            W.EZGI_SETUP_TIME,
            W.EZGI_KATSAYI,
            S.PRODUCT_NAME, 
            S.PRODUCT_CODE
        FROM     
            EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPO WITH (NOLOCK) INNER JOIN
            EZGI_IFLOW_PRODUCTION_ORDERS AS EPO WITH (NOLOCK) ON EIPO.P_ORDER_PARTI_ID = EPO.REL_P_ORDER_ID INNER JOIN
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EPO.LOT_NO = PO.LOT_NO INNER JOIN
            PRODUCTION_OPERATION AS PORR WITH (NOLOCK) ON PO.P_ORDER_ID = PORR.P_ORDER_ID INNER JOIN
            EZGI_IFLOW_MASTER_PLAN AS EIM WITH (NOLOCK) ON EPO.MASTER_PLAN_ID = EIM.MASTER_PLAN_ID INNER JOIN
            OPERATION_TYPES AS OT ON OT.OPERATION_TYPE_ID = PORR.OPERATION_TYPE_ID INNER JOIN
            WORKSTATIONS_PRODUCTS AS WP ON OT.OPERATION_TYPE_ID = WP.OPERATION_TYPE_ID INNER JOIN
            WORKSTATIONS AS W ON WP.WS_ID = W.STATION_ID INNER JOIN
            STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID
        WHERE  
            ISNULL(W.ACTIVE,0) = 1 AND 
            EIM.MASTER_PLAN_ID = #attributes.master_plan_id#
        ORDER BY 
            PO.P_ORDER_NO,
            PORR.P_OPERATION_ID, 
            W.STATION_ID
    </cfquery>
    
    <cfquery name="get_production_operations_group" dbtype="query">
        SELECT
            MASTER_PLAN_ID,
            MASTER_PLAN_NUMBER,
            MASTER_PLAN_START_DATE,
            P_ORDER_PARTI_SORT_NO,
            P_ORDER_SORT_NO,
            P_ORDER_PARTI_NUMBER,
            LOT_NO,
            IFLOW_P_ORDER_ID,
            P_ORDER_NO,
            PRODUCT_NAME, 
            PRODUCT_CODE,
            P_ORDER_ID, 
            PRODUCTION_LEVEL,
            PO_RELATED_ID, 
            AMOUNT, 
            OPERATION_TYPE_ID, 
            OPERATION_TYPE,
            P_OPERATION_ID, 
            OPTIMUM_TIME,
            STAGE
        FROM
            get_production_operations
        GROUP BY
            MASTER_PLAN_ID,
            MASTER_PLAN_NUMBER,
            MASTER_PLAN_START_DATE,
            P_ORDER_PARTI_SORT_NO,
            P_ORDER_SORT_NO,
            P_ORDER_PARTI_NUMBER,
            LOT_NO,
            IFLOW_P_ORDER_ID,
            P_ORDER_NO,
            PRODUCT_NAME, 
            PRODUCT_CODE,
            P_ORDER_ID, 
            PRODUCTION_LEVEL,
            PO_RELATED_ID, 
            AMOUNT, 
            OPERATION_TYPE_ID, 
            OPERATION_TYPE,
            P_OPERATION_ID, 
            OPTIMUM_TIME,
            STAGE
    </cfquery>
    
    <cfquery name="get_operations_group" dbtype="query">
        SELECT
            OPERATION_TYPE_ID, 
            OPERATION_TYPE, 
            STATION_NAME, 
            STATION_ID,
            EZGI_KATSAYI,
            EZGI_SETUP_TIME
        FROM
            get_production_operations
        GROUP BY
            OPERATION_TYPE_ID, 
            OPERATION_TYPE, 
            STATION_NAME, 
            STATION_ID,
            EZGI_KATSAYI,
            EZGI_SETUP_TIME	
    </cfquery>
    
    <cfquery name="get_stations_group" dbtype="query">
        SELECT
            STATION_NAME, 
            STATION_ID,
            EZGI_KATSAYI,
            EZGI_SETUP_TIME
        FROM
            get_production_operations
        GROUP BY
            STATION_NAME, 
            STATION_ID,
            EZGI_KATSAYI,
            EZGI_SETUP_TIME	
    </cfquery>
    
    <cfset stationLoads = {}> <!-- STATION_ID -> toplam yük -->
    <cfset stationTimers = {}> <!-- STATION_ID -> son bitiş datetime -->
    <cfset orderTimers = {}> <!-- Her üretim emri için son bitiş zamanı -->
    <cfset UporderTimers = {}> <!-- Üst üretim emri için son bitiş zamanı -->
    <cfset assignments = []>
    
    <cfscript>
        startDate = CreateODBCDateTime(get_production_operations_group.MASTER_PLAN_START_DATE);
    </cfscript>
    
    <cfquery name="get_general_offtime" datasource="#dsn3#">
        SELECT
            OFFTIME_NAME, 
            START_DATE, 
            FINISH_DATE, 
            IS_HALFOFFTIME
        FROM     
            #dsn_alias#.SETUP_GENERAL_OFFTIMES
        WHERE  
            START_DATE >= #startDate#
    </cfquery>
    
    
    
    <cfquery dbtype="query" name="qPlanSorted">
        SELECT 
            * 
        FROM 
            get_production_operations_group
        ORDER BY 
            P_ORDER_PARTI_SORT_NO ASC,
            P_ORDER_SORT_NO ASC,
            PO_RELATED_ID DESC,
            P_ORDER_ID ASC, 
            P_OPERATION_ID ASC
    </cfquery>
    
    <cfset operasyonlar = queryNew("
                                    MASTER_PLAN_ID,
                                    MASTER_PLAN_NUMBER,
                                    MASTER_PLAN_START_DATE,
                                    P_ORDER_PARTI_SORT_NO,
                                    P_ORDER_SORT_NO,
                                    P_ORDER_PARTI_NUMBER,
                                    LOT_NO,
                                    IFLOW_P_ORDER_ID,
                                    P_ORDER_NO,
                                    PRODUCT_NAME, 
                                    PRODUCT_CODE,
                                    P_ORDER_ID, 
                                    PRODUCTION_LEVEL,
                                    PO_RELATED_ID, 
                                    AMOUNT, 
                                    OPERATION_TYPE_ID, 
                                    OPERATION_TYPE,
                                    P_OPERATION_ID, 
                                    OPTIMUM_TIME,
                                    OPTIMUM_TOTAL,
                                    STATION_ID,
                                    STATION_NAME,
                                    BASLA,
                                    BITIR,
                                    STAGE
                                    ","
                                    integer,
                                    VarChar,
                                    Timestamp,
                                    integer,
                                    integer,
                                    VarChar,
                                    VarChar,
                                    integer,
                                    VarChar,
                                    VarChar,
                                    VarChar,
                                    integer,
                                    integer,
                                    integer,
                                    Decimal,
                                    integer,
                                    VarChar,
                                    integer,
                                    Decimal,
                                    Decimal,
                                    integer,
                                    VarChar,
                                    Timestamp,
                                    Timestamp,
                                    integer
                                    ") />
    <cfloop query="qPlanSorted">
        <cfif qPlanSorted.OPTIMUM_TIME eq 0>
            <script type="text/javascript">
                alert(<cfoutput>"#qPlanSorted.PRODUCT_NAME# Ürününe Ait #qPlanSorted.OPERATION_TYPE# Operasyon Süresi 0 değerinden büyük olmalıdır.!"</cfoutput>);
            </script>
        </cfif>
        <cfif qPlanSorted.AMOUNT eq 0>
            <script type="text/javascript">
                alert(<cfoutput>"#qPlanSorted.PRODUCT_NAME# Ürün Miktarı 0 değerinden büyük olmalıdır.!"</cfoutput>);
            </script>
        </cfif>
        <cfset opTypeId = qPlanSorted.OPERATION_TYPE_ID>
        <cfset opName = qPlanSorted.OPERATION_TYPE>
        <cfset amount = qPlanSorted.AMOUNT>
        <cfset orderId = qPlanSorted.P_ORDER_ID>
        <cfset UporderId = qPlanSorted.PO_RELATED_ID>
        <cfset timePerUnit = qPlanSorted.OPTIMUM_TIME>
        <cfset totalTime = amount * timePerUnit>
    
        <cfquery dbtype="query" name="qStations"> <!---Operasyonda Çalışabilecek İstasyonlar Bulunuyor--->
            SELECT 
                * 
            FROM 
                get_operations_group
            WHERE 
                OPERATION_TYPE_ID = <cfqueryparam value="#opTypeId#" cfsqltype="cf_sql_integer">
            ORDER BY
                STATION_NAME	
        </cfquery>
        
        <cfset minLoad = 999999999>
        <cfset chosenStation = {}>
    
        <cfloop query="qStations"><!--- Bulunan İstasyonlar Döndürülüyor--->
            <cfset stationid = qStations.STATION_ID>
            <cfset currentLoad = structKeyExists(stationLoads, stationid) ? stationLoads[stationid] : 0> <!---Eğer İstasyon StationLoads da tanımlı ise CurrentLoad a İstasyonun Yük değerini Tanımlı değilse 0 ata--->
            <cfif currentLoad LTE minLoad> <!---En Az Yüklü İstasyona Atama Yapılıyor.--->
                <cfset minLoad = currentLoad>
                <cfset chosenStation = {
                                        id = stationid,
                                        name = qStations.STATION_NAME,
                                        setup = qStations.EZGI_SETUP_TIME,
                                        katsayi = qStations.EZGI_KATSAYI
                                        }> <!---En Az Yüklü İstasyon Bulunup, chosenStation nesnesine istasyon bilgileri yükleniyor--->
            </cfif>
        </cfloop>
        <cfset stationReady = structKeyExists(stationTimers, chosenStation.id) ? stationTimers[chosenStation.id] : startDate> <!---stationReady için stationTimers nesnesinde Yeni Seçilen istasyon varsa Bu anahtarındeğerini Yoksa Startdate Başlangıç Değerini ata--->
        <cfset orderReady = structKeyExists(orderTimers, orderId) ? orderTimers[orderId] : startDate> <!---orderReady için orderTimers nesnesinde P_ORDER_ID varsa Bu anahtarın değerini Yoksa Startdate Başlangıç Değerini ata--->
        <cfif structKeyExists(UporderTimers, orderId)> <!---Eğer Üst Üretimse İlerleme Zamanı Alt Üretimin En yüksek zamanını alır.--->
            <cfif UporderTimers[orderId] gt orderReady>
                <cfif UporderTimers[orderId] gt stationReady>
                    <cfset currentTime = UporderTimers[orderId]>
                <cfelse>
                    <cfset currentTime = stationReady>  
                </cfif>
            <cfelse>
                <cfset currentTime = dateCompare(stationReady, orderReady) GT 0 ? stationReady : orderReady>
            </cfif>
        <cfelse>
            <cfset currentTime = dateCompare(stationReady, orderReady) GT 0 ? stationReady : orderReady> <!---currentTime için Eğer stationReady değeri orderReady değerinden büyükse stationReady değilse orderReady değerini ata--->
        </cfif>
        <cfset uzamali =0>	
        <cfset sure = totalTime> <!---sure OPTIMUM_TIME*AMOUNT eşittir.--->
        <cfloop condition="sure GT 0"> <!---Süre 0 dan büyük se dön--->
            <cfset gun = dayOfWeek(currentTime)> <!---gun Haftadaki gun no atanıyor. 1Pazar, 2 Pztsi,3 Salı, 4 Çrşmb, 5 Prşmb, 6 Cuma, 7 Cmrtsi,--->
            <cfif gun EQ 7 OR gun EQ 1><!---Eğer Haftanın Günü Cumartesi veya Pazar İse CurrentTime a 1 gün ekle ve süreden düşme--->
                <cfset currentTime = dateAdd("d", 1, createDateTime(year(currentTime), month(currentTime), day(currentTime), 8, 0, 0))>
                <cfcontinue> <!---Direk CfLoop satırına git--->
            <cfelse>
                <cfif get_general_offtime.recordcount> <!---Tatil Zamanları tanımlanmışsa--->
                    <cfset anahtar =0>
                    <cfloop query="get_general_offtime">
                        <cfif dayOfYear(currentTime) gte dayOfYear(get_general_offtime.START_DATE) and dayOfYear(currentTime) lte dayOfYear(get_general_offtime.FINISH_DATE)> <!---Eğer Gün Bayramsa--->
                            <cfset currentTime = dateAdd("d", 1, createDateTime(year(currentTime), month(currentTime), day(currentTime), 8, 0, 0))>
                            <cfset anahtar =1>
                        </cfif>
                    </cfloop>
                    <cfif anahtar eq 1>
                        <cfcontinue> <!---Direk CfLoop satırına git--->
                    </cfif>
                </cfif>
            </cfif>
            
            <cfset gunlukKalan = gunlukSure - (dateDiff("s", createDateTime(year(currentTime), month(currentTime), day(currentTime), 8, 0, 0), currentTime))> <!---Günlük Kalanı = 32400 - Saat 8 ile İlerleme Değeri arasındaki saniye Cinsinden fark Bulunup düşülüyor.--->
            <cfif sure LTE gunlukKalan> <!---Eğer sure (İşin toplam zamanı) gün içinde kalan süreden küçükse --->
                <!---GÜN ATLAMIŞSA--->
                <cfif uzamali eq 1> 
                    <cfif structKeyExists(UporderTimers, orderId)> <!---Bu Üretimin Bir Üst Üreti Varsa O Üretimin Bitiş Tarihidir.--->
                        <cfif UporderTimers[orderId] gt stationReady>
                            <cfset baslangicZaman = UporderTimers[orderId]>
                        <cfelse>	
                            <cfif stationReady gt orderReady>
                                <cfset baslangicZaman = stationReady>
                            <cfelse>
                                <cfset baslangicZaman = orderReady>
                            </cfif>
                        </cfif>
                        <!---<cfset baslangicZaman = UporderTimers[orderId]>---> 
                    <cfelse>
                        <cfif stationReady gt orderReady>
                            <cfset baslangicZaman = stationReady> <!---Başlangıç zamanı Bir Önceki Operasyonunun Bitişidir--->
                        <cfelse>
                            <cfset baslangicZaman = sonbaslangic> <!---Başlangıç zamanı Bir Önceki Operasyonunun Bitişidir--->
                        </cfif>
                    </cfif>
                <cfelse>
                    <cfif structKeyExists(UporderTimers, orderId)> <!---Bu Üretimin Bir Üst Üreti Varsa O Üretimin Bitiş Tarihidir.--->
                        <cfif UporderTimers[orderId] gt currentTime>
                            <cfset baslangicZaman = UporderTimers[orderId]>
                        <cfelse>
                            <cfset baslangicZaman = currentTime>
                        </cfif>
                    <cfelse>
                        <cfset baslangicZaman = currentTime> <!---Başlangıç zamanı ilerleme süresidir.--->
                    </cfif>
                </cfif>
                <!---GÜN ATLAMIŞSA--->
            
                <cfset bitisZaman = dateAdd("s", sure, currentTime)> <!---Bitiş zamanı ilerleme süresi + işin toplam süresidir.--->
                <cfset sure = 0> <!---İş Süresi tekrar dönmesin diye sıfırlanır--->
            
            <cfelse> <!---Eğer sure (İşin toplam zamanı) gün içinde kalan süreden büyükse (Yani gün yetmiyorsa) --->
                <cfset sure = sure - gunlukKalan> <!---sure üzerinden Günlük Kalan süre düşülerek yeniden hesaplanıyor.--->
                <cfset uzamali =1>
                <cfset sonbaslangic = dateAdd("s", sure, currentTime)>
                <cfset currentTime = dateAdd("d", 1, createDateTime(year(currentTime), month(currentTime), day(currentTime), 8, 0, 0))> <!---Ve İlerleme Zamanına 1 tam Gün ilave ediliyor.--->
            </cfif>
        </cfloop>
    
        <cfset stationLoads[chosenStation.id] = structKeyExists(stationLoads, chosenStation.id) ? stationLoads[chosenStation.id] + totalTime : totalTime> <!---Eğer stationLoads nesnesinde İstasyon Tanımlı ise yeni değer = eski değeri + Toplam İş zamanı yeni tanımlanıyorsa Toplam İş zamanı tanımlanıyor.--->
        <cfset stationTimers[chosenStation.id] = bitisZaman> <!---stationTimers nesnesine istasyonun bitiş zamanı ekleniyor veya değiştiriliyor.--->
        <cfset orderTimers[orderId] = bitisZaman> <!---orderTimers nesnesine P_ORDER_ID nin bitiş zamanı ekleniyor veya değiştiriliyor.--->
        <cfif structKeyExists(UporderTimers, UporderId)>
            <cfif UporderTimers[UporderId] lt bitisZaman>
                <cfset UporderTimers[UporderId] = bitisZaman> <!---UporderTimers nesnesine PO_RELATED_ID nin bitiş zamanı ekleniyor veya değiştiriliyor.--->
            </cfif>
        <cfelse>
            <cfset UporderTimers[UporderId] = bitisZaman> <!---UporderTimers nesnesine PO_RELATED_ID nin bitiş zamanı ekleniyor veya değiştiriliyor.--->
        </cfif>  
    
        <cfset temp = QueryAddRow(operasyonlar)>
        <cfset temp = QuerySetCell(operasyonlar, "MASTER_PLAN_ID", MASTER_PLAN_ID)> 
        <cfset temp = QuerySetCell(operasyonlar, "MASTER_PLAN_NUMBER", MASTER_PLAN_NUMBER)> 
        <cfset temp = QuerySetCell(operasyonlar, "MASTER_PLAN_START_DATE", MASTER_PLAN_START_DATE)> 
        <cfset temp = QuerySetCell(operasyonlar, "P_ORDER_PARTI_SORT_NO", P_ORDER_PARTI_SORT_NO)> 
        <cfset temp = QuerySetCell(operasyonlar, "P_ORDER_SORT_NO", P_ORDER_SORT_NO)> 
        <cfset temp = QuerySetCell(operasyonlar, "P_ORDER_PARTI_NUMBER", P_ORDER_PARTI_NUMBER)> 
        <cfset temp = QuerySetCell(operasyonlar, "LOT_NO", LOT_NO)> 
        <cfset temp = QuerySetCell(operasyonlar, "IFLOW_P_ORDER_ID", IFLOW_P_ORDER_ID)> 
        <cfset temp = QuerySetCell(operasyonlar, "P_ORDER_NO", P_ORDER_NO)> 
        <cfset temp = QuerySetCell(operasyonlar, "PRODUCT_NAME", PRODUCT_NAME)> 
        <cfset temp = QuerySetCell(operasyonlar, "PRODUCT_CODE", PRODUCT_CODE)> 
        <cfset temp = QuerySetCell(operasyonlar, "P_ORDER_ID", P_ORDER_ID)> 
        <cfset temp = QuerySetCell(operasyonlar, "PRODUCTION_LEVEL", PRODUCTION_LEVEL)> 
        <cfset temp = QuerySetCell(operasyonlar, "PO_RELATED_ID", PO_RELATED_ID)> 
        <cfset temp = QuerySetCell(operasyonlar, "AMOUNT", AMOUNT)> 
        <cfset temp = QuerySetCell(operasyonlar, "OPERATION_TYPE_ID", opTypeId)> 
        <cfset temp = QuerySetCell(operasyonlar, "OPERATION_TYPE", opName)> 
        <cfset temp = QuerySetCell(operasyonlar, "P_OPERATION_ID", P_OPERATION_ID)> 
        <cfset temp = QuerySetCell(operasyonlar, "OPTIMUM_TIME", OPTIMUM_TIME)> 
        <cfset temp = QuerySetCell(operasyonlar, "OPTIMUM_TOTAL", totalTime)> 
        <cfset temp = QuerySetCell(operasyonlar, "STATION_ID", chosenStation.id)> 
        <cfset temp = QuerySetCell(operasyonlar, "STATION_NAME", chosenStation.name)> 
        <cfset temp = QuerySetCell(operasyonlar, "MASTER_PLAN_ID", MASTER_PLAN_ID)>
        <cfset temp = QuerySetCell(operasyonlar, "BASLA", baslangicZaman)>
        <cfset temp = QuerySetCell(operasyonlar, "BITIR", bitisZaman)> 
        <cfset temp = QuerySetCell(operasyonlar, "STAGE", STAGE)>
    </cfloop>
</cfif>


