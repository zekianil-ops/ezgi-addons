<!---
    File: dsp_ezgi_iflow_operational_gantt_chart.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description:
--->
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.operation_type" default="">
<cfparam name="attributes.station_id" default="">
<cfparam name="attributes.master_plan_id" default="">
<cfparam name="attributes.master_plan_cat_id" default="">

<link rel="stylesheet" type="text/css" href="/AddOns/ezgi/css/ezgi.css">
<link rel="stylesheet" type="text/css" href="/AddOns/ezgi/css/corporate-core.css">
<link rel="stylesheet" type="text/css" href="/AddOns/ezgi/css/corporate-table.css">
<link rel="stylesheet" type="text/css" href="/AddOns/ezgi/css/corporate-gantt.css">
<cfquery name="get_master_plan" datasource="#dsn3#">
	SELECT        
    	MASTER_PLAN_ID, 
        MASTER_PLAN_NUMBER, 
        MASTER_PLAN_DETAIL,
        MASTER_PLAN_CAT_ID
	FROM            
    	EZGI_IFLOW_MASTER_PLAN WITH (NOLOCK)
  	<cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
        WHERE 
            MASTER_PLAN_CAT_ID IN    
            
                    (
                        SELECT        
                            MASTER_PLAN_CAT_ID
                        FROM       
                            EZGI_IFLOW_MASTER_PLAN AS M
                        WHERE        
                            MASTER_PLAN_ID IN (#attributes.master_plan_id#)
                    )
    </cfif>
	ORDER BY 
    	MASTER_PLAN_NUMBER
</cfquery>

<!---Şablonu Listesini Alıyoruz--->
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
    	EMPS.SHIFT_ID = #get_master_plan.MASTER_PLAN_CAT_ID# AND 
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
        S.PRODUCT_ID,
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
       	), 0) AS OPTIMUM_TIME, 
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
        STOCK_ID,
        PRODUCT_ID,
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
        STOCK_ID,
        PRODUCT_ID,
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

<cfquery name="get_general_offtime" datasource="#dsn#">
	SELECT
    	OFFTIME_NAME, 
        START_DATE, 
        FINISH_DATE, 
        IS_HALFOFFTIME
	FROM     
    	SETUP_GENERAL_OFFTIMES
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
								STOCK_ID,
								PRODUCT_ID,
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
            window.close()
        </script>
        <cfabort>
  	</cfif>
  	<cfif qPlanSorted.AMOUNT eq 0>
		<script type="text/javascript">
            alert(<cfoutput>"#qPlanSorted.PRODUCT_NAME# Ürün Miktarı 0 değerinden büyük olmalıdır.!"</cfoutput>);
            window.close()
        </script>
        <cfabort>
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
    <cfset temp = QuerySetCell(operasyonlar, "STOCK_ID", STOCK_ID)> 
    <cfset temp = QuerySetCell(operasyonlar, "PRODUCT_ID", PRODUCT_ID)> 
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
<cfquery name="operasyonlar_p_order" dbtype="query">
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
        STOCK_ID,
        PRODUCT_ID,
    	P_ORDER_ID, 
    	PRODUCTION_LEVEL,
    	PO_RELATED_ID ,
        AMOUNT
   	FROM
    	operasyonlar
  	WHERE
    	1=1
        <cfif len(attributes.station_id)>
            AND STATION_ID = #attributes.station_id#
        </cfif>
        <cfif len(attributes.keyword)>
            AND 
            	(
                	P_ORDER_PARTI_NUMBER LIKE  '%#attributes.keyword#%' OR
                    LOT_NO LIKE  '%#attributes.keyword#%' OR
                    P_ORDER_NO LIKE  '%#attributes.keyword#%'
              	)
        </cfif>
     	<cfif len(attributes.operation_type)>
            AND OPERATION_TYPE LIKE  '%#attributes.operation_type#%'
        </cfif>
  	group by
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
        STOCK_ID,
        PRODUCT_ID,
    	P_ORDER_ID, 
    	PRODUCTION_LEVEL,
    	PO_RELATED_ID,
        AMOUNT
  	ORDER BY
    	<cfif len(attributes.station_id)>
        	BASLA
        <cfelse>
            P_ORDER_PARTI_SORT_NO,
            P_ORDER_SORT_NO,
            PO_RELATED_ID desc
        </cfif>
</cfquery>

<cfquery name="get_station_list_group" dbtype="query">
	SELECT
    	*
   	FROM
		get_station_list
  	WHERE
    	1=1
       	<cfif len(attributes.station_id)>
            AND STATION_ID = #attributes.station_id#
        </cfif> 
  	ORDER BY
    	SIRA
</cfquery>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#operasyonlar_p_order.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
      	<cfform name="search" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
           	<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <cf_box_search>
             		<div class="form-group"  id="item-keyword">
                        <cfsavecontent variable="filter">Parti, Lot, Emir</cfsavecontent>
                         <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
                    </div>
                    <div class="form-group"  id="item-operation_type">
                        <cfsavecontent variable="filter">Operasyon</cfsavecontent>
                         <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="operation_type" value="#attributes.operation_type#">
                    </div>
                    <div class="form-group medium" id="item-master_plan_id">
                        <select name="master_plan_id">
                            <option value="" <cfif attributes.master_plan_id eq ''>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            <cfoutput query="get_master_plan">
                                <option value="#MASTER_PLAN_ID#" <cfif attributes.master_plan_id eq MASTER_PLAN_ID>selected</cfif>>#MASTER_PLAN_NUMBER# - #MASTER_PLAN_DETAIL#</option>
                            </cfoutput>
                        </select>
                    </div>
                    <div class="form-group" id="form_ul_stations">
                    	<select name="station_id" onChange="process_change(this.value)">
                         	<option value="" <cfif attributes.station_id eq ''>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                         	<cfoutput query="get_station_list">
                            	<option value="#STATION_ID#" <cfif attributes.station_id eq STATION_ID>selected</cfif>>#STATION_NAME#</option>
                         	</cfoutput>
                    	</select>
                   	</div>
                     <div class="form-group small">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                        <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                    </div>
                    <div class="form-group">
                        <cf_wrk_search_button search_function='input_control()' button_type="4">
                    </div>
         	</cf_box_search>
		</cfform>
        <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        	<cfsavecontent variable="title"><cf_get_lang dictionary_id='36368.Fabrika Üretim Emirleri'></cfsavecontent>
        	<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
           		<cf_grid_list id="operation_panel" sort="0">   
              		<thead>
                		<tr valign="middle">
                        	<th style="width:25px; height:30px; text-align:center; vertical-align:middle" rowspan="2"><cf_get_lang dictionary_id='58577.Sıra'></th>
                         	<th style="width:60px; text-align:center; vertical-align:middle" rowspan="2"><cf_get_lang dictionary_id='36528.Parti No'></th>
                         	<th style="width:60px; text-align:center; vertical-align:middle" rowspan="2"><cf_get_lang dictionary_id='41701.Lot No'></th>
                       		<th style="width:60px; text-align:center; vertical-align:middle" rowspan="2">Emir No</th> 
                        	<th style="text-align:center; vertical-align:middle" rowspan="2"><cf_get_lang dictionary_id='57657.Ürün'></th>
        					<th style="width:50px; text-align:center; vertical-align:middle" rowspan="2"><cf_get_lang dictionary_id='57635.Miktar'></th>
                         	<th style="text-align:center" colspan="<cfoutput>#get_station_list_group.recordcount#</cfoutput>">İstasyonlar</th>
                     	</tr>
                  		<tr> 
                       		<cfoutput query="get_station_list_group">
                          		<th>#STATION_NAME#</th>
                          	</cfoutput>
                       	</tr>
                 	</thead>
                 	<tbody>
                     	<cfif operasyonlar_p_order.recordcount>
                        	<cfoutput query="operasyonlar_p_order" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                              	<tr name="frm_row#currentrow#" id="frm_row#currentrow#" >
                                 	<td style="text-align:right;">#currentrow#</td>
                                	<td style="text-align:center;">#P_ORDER_PARTI_NUMBER#</td>
                                 	<td style="text-align:center;">
                                    	<a href="javascript://" onclick="window.open('#request.self#?fuseaction=prod.popup_list_ezgi_iflow_production_operations&is_form_submitted=1&keyword=#LOT_NO#','_blank');">
                                            #LOT_NO#
                                        </a>
                                    </td>
                                  	<td style="text-align:center;">
                                    	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.order&event=upd&upd=#p_order_id#','longpage');" class="tableyazi">
                                            #P_ORDER_NO#
                                        </a>
                                    </td>
                                 	<td style="text-align:left;">
                                    	<a href="javascript://" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_detail_product&pid=#product_id#&sid=#stock_id#','large');">
                            				#PRODUCT_NAME#
                        				</a>
                                    </td>
                                  	<td style="text-align:right;">#amount#</td>
                                 	<cfloop query="get_station_list_group">
                                    	<cfquery name="get_operation_for_station" dbtype="query">
                                         	SELECT
                                             	P_ORDER_ID, 
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
                                        	FROM
                                             	operasyonlar
                                         	WHERE
                                            	P_ORDER_ID = #operasyonlar_p_order.P_ORDER_ID# AND
                                             	STATION_ID = #get_station_list_group.STATION_ID#
                                              	<cfif len(attributes.operation_type)>
                                                 	AND OPERATION_TYPE LIKE '%#attributes.operation_type#%'
                                             	</cfif>	
                                     	</cfquery>

                                  		<td class="td-center">
											<cfif get_operation_for_station.recordcount>
                                                <!-- HÜCRE KART GÖRÜNÜMÜ -->
                                                <a style="cursor:pointer"  onClick="windowopen('#request.self#?fuseaction=prod.popup_list_ezgi_iflow_production_operation_result&operation_id=#get_operation_for_station.P_OPERATION_ID#','wide');">
                                                <div class="operation-cell 
                                                    <cfif get_operation_for_station.STAGE EQ 1>green</cfif>
                                                    <cfif get_operation_for_station.STAGE EQ 3>red</cfif>
                                                ">
                                                    <strong>#get_operation_for_station.OPERATION_TYPE#</strong><br>
                                                    Süre: #AmountFormat(get_operation_for_station.OPTIMUM_TOTAL,0)# sn<br>
        
                                                    <span class="ezgi-text-muted" style="font-size:10px;">
                                                        Başla: #DateFormat(get_operation_for_station.BASLA,"dd/mm")#  
                                                        #TimeFormat(get_operation_for_station.BASLA,"HH:MM")#<br>
        
                                                        Bitir: #DateFormat(get_operation_for_station.BITIR,"dd/mm")#
                                                        #TimeFormat(get_operation_for_station.BITIR,"HH:MM")#
                                                    </span>
                                                </div>
                                                </a>
                                            </cfif>
                                        </td>
                                 	</cfloop>
                            	</tr>
                          	</cfoutput>
                     	</cfif>
                	</tbody>
        		</cf_grid_list>
            	<cfset adres = url.fuseaction>
              	<cfif len(attributes.keyword)>
                 	<cfset adres = '#adres#&keyword=#URLEncodedFormat(attributes.keyword)#'>
            	</cfif>
            	<cfif len(attributes.keyword)>
                 	<cfset adres = '#adres#&operation_type=#attributes.operation_type#'>
             	</cfif>
           		<cfif len(attributes.station_id)>
                 	<cfset adres = '#adres#&station_id=#attributes.station_id#'>
              	</cfif>
            	<cfif len(attributes.master_plan_id)>
                	<cfset adres = '#adres#&master_plan_id=#attributes.master_plan_id#'>
            	</cfif>
            	<cf_paging 
                        page="#attributes.page#"
                        maxrows="#attributes.maxrows#"
                        totalrecords="#attributes.totalrecords#"
                        startrow="#attributes.startrow#"
                        adres="#adres#&is_form_submitted=1">
			</cf_box>
      	</div>
   	</cf_box>
</div>


<!-- DHTMLX Gantt Libraries -->
<script src="JS/gantt_chart/dhtmlxgantt.js" type="text/javascript" charset="utf-8"></script>
<link rel="stylesheet" href="JS/gantt_chart/skins/dhtmlxgantt_terrace.css" type="text/css" media="screen" title="no title" charset="utf-8">
<cfif session.ep.language neq 'eng'><script src="JS/gantt_chart/locale/locale_<cfoutput>#session.ep.language#</cfoutput>.js" type="text/javascript" charset="utf-8"></script></cfif>
<script src="https://www.gstatic.com/charts/loader.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>

<!-- Modern Gantt Chart Styles -->
<style>
	.gantt-chart-container {
		position: relative;
		background: #fff;
		border-radius: 8px;
		padding: 20px;
		box-shadow: 0 2px 8px rgba(0,0,0,0.1);
	}
	
	#gantt_here {
		width: 100%;
		height: 600px;
	}
	
	.gantt_task_pending {
		background-color: #ff9800 !important;
		border-color: #ff9800 !important;
	}
	
	.gantt_task_completed {
		background-color: #f44336 !important;
		border-color: #f44336 !important;
	}
	
	.gantt_task_completed .gantt_task_progress {
		background-color: #f44336 !important;
		background: #f44336 !important;
	}
	
	.gantt_task_inprogress {
		background-color: #2196F3 !important;
		border-color: #2196F3 !important;
	}
	
	.gantt_task_inprogress .gantt_task_progress {
		background-color: #2196F3 !important;
		background: #2196F3 !important;
	}
	
	.gantt_task_pending .gantt_task_progress {
		background-color: #ff9800 !important;
		background: #ff9800 !important;
	}
	
	.gantt-controls {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 15px;
		padding: 10px;
		background: #f8f9fa;
		border-radius: 6px;
		flex-wrap: wrap;
		gap: 10px;
	}
	
	.gantt-controls-left {
		display: flex;
		gap: 10px;
		align-items: center;
		flex-wrap: wrap;
	}
	
	.gantt-controls-right {
		display: flex;
		gap: 10px;
		align-items: center;
		flex-wrap: wrap;
	}
	
	.gantt-btn {
		padding: 8px 16px;
		border: none;
		border-radius: 4px;
		cursor: pointer;
		font-size: 14px;
		font-weight: 500;
		transition: all 0.3s ease;
		display: inline-flex;
		align-items: center;
		gap: 6px;
	}
	
	.gantt-btn-primary {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: white;
	}
	
	.gantt-btn-primary:hover {
		transform: translateY(-2px);
		box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
	}
	
	.gantt-btn-secondary {
		background: #6c757d;
		color: white;
	}
	
	.gantt-btn-secondary:hover {
		background: #5a6268;
	}
	
	.gantt-btn-success {
		background: #28a745;
		color: white;
	}
	
	.gantt-btn-success:hover {
		background: #218838;
	}
	
	.gantt-btn-danger {
		background: #dc3545;
		color: white;
	}
	
	.gantt-btn-danger:hover {
		background: #c82333;
	}
	
	.gantt-zoom-controls {
		display: flex;
		gap: 5px;
		align-items: center;
	}
	
	.gantt-zoom-btn {
		padding: 6px 12px;
		border: 1px solid #dee2e6;
		background: white;
		border-radius: 4px;
		cursor: pointer;
		font-size: 12px;
	}
	
	.gantt-zoom-btn:hover {
		background: #e9ecef;
	}
	
	.gantt-zoom-btn.active {
		background: #667eea;
		color: white;
		border-color: #667eea;
	}
	
	.gantt-legend {
		display: flex;
		gap: 20px;
		align-items: center;
		margin-bottom: 15px;
		padding: 10px;
		background: #f8f9fa;
		border-radius: 6px;
		flex-wrap: wrap;
	}
	
	.gantt-legend-item {
		display: flex;
		align-items: center;
		gap: 8px;
		font-size: 13px;
	}
	
	.gantt-legend-color {
		width: 20px;
		height: 20px;
		border-radius: 4px;
		border: 1px solid #dee2e6;
	}
	
	.gantt-chart-wrapper {
		position: relative;
		overflow-x: auto;
		overflow-y: hidden;
		border: 1px solid #dee2e6;
		border-radius: 6px;
		background: white;
	}
	
	.gantt-loading {
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		z-index: 1000;
		text-align: center;
	}
	
	.gantt-loading-spinner {
		border: 4px solid #f3f3f3;
		border-top: 4px solid #667eea;
		border-radius: 50%;
		width: 40px;
		height: 40px;
		animation: spin 1s linear infinite;
		margin: 0 auto 10px;
	}
	
	@keyframes spin {
		0% { transform: rotate(0deg); }
		100% { transform: rotate(360deg); }
	}
	
	.gantt-date-filter {
		display: flex;
		gap: 10px;
		align-items: center;
	}
	
	.gantt-date-input {
		padding: 6px 10px;
		border: 1px solid #dee2e6;
		border-radius: 4px;
		font-size: 13px;
	}
	
	.gantt-stats {
		display: flex;
		gap: 20px;
		margin-top: 15px;
		padding: 15px;
		background: #f8f9fa;
		border-radius: 6px;
		flex-wrap: wrap;
	}
	
	.gantt-stat-item {
		display: flex;
		flex-direction: column;
		gap: 5px;
	}
	
	.gantt-stat-label {
		font-size: 12px;
		color: #6c757d;
		font-weight: 500;
	}
	
	.gantt-stat-value {
		font-size: 18px;
		font-weight: 700;
		color: #495057;
	}
	
	@media (max-width: 768px) {
		.gantt-controls {
			flex-direction: column;
			align-items: stretch;
		}
		
		.gantt-controls-left,
		.gantt-controls-right {
			width: 100%;
			justify-content: center;
		}
	}
	
	/* Grafik Container Stilleri */
	#stats-pie-chart,
	#stats-bar-chart {
		transition: all 0.3s ease;
		box-shadow: 0 2px 8px rgba(0,0,0,0.1);
	}
	
	#stats-pie-chart:hover,
	#stats-bar-chart:hover {
		box-shadow: 0 4px 16px rgba(0,0,0,0.15);
		transform: translateY(-2px);
	}
	
	/* Google Charts Tooltip Stilleri */
	.google-visualization-tooltip {
		border-radius: 8px !important;
		box-shadow: 0 4px 12px rgba(0,0,0,0.2) !important;
		padding: 12px !important;
		font-family: 'Arial', sans-serif !important;
	}
	
	/* Chart Area Stilleri */
	.google-visualization-chart {
		font-family: 'Arial', sans-serif;
	}
</style>

<script type="text/javascript">
	var ganttOperations = [];
	var currentZoomLevel = 'day'; // 'hour', 'day', 'week', 'month'
	var ganttTasks = [];
	var ganttLinks = [];
	
	// Operasyon verilerini topla
	<cfif get_station_list_group.recordcount>
		ganttOperations = [
			<cfoutput query="get_station_list_group">
				<cfquery name="get_operation_for_station" dbtype="query">
					SELECT 
						P_ORDER_NO, 
						PRODUCT_NAME, 
						OPERATION_TYPE, 
						OPTIMUM_TIME, 
						OPTIMUM_TOTAL,
						BASLA, 
						BITIR, 
						STAGE,
						P_ORDER_ID,
						P_OPERATION_ID,
						LOT_NO,
						P_ORDER_PARTI_NUMBER
					FROM operasyonlar 
					WHERE STATION_ID = #get_station_list_group.STATION_ID# 
					<cfif len(attributes.operation_type)>AND OPERATION_TYPE LIKE '%#attributes.operation_type#%'</cfif> 
					ORDER BY BASLA
				</cfquery>
				<cfif get_operation_for_station.recordcount>
					<cfloop query="get_operation_for_station">
						<cfset station_name_escaped = Replace(Replace(Replace(get_station_list_group.STATION_NAME, "'", "\'", "all"), Chr(10), " ", "all"), Chr(13), " ", "all")>
						<cfset order_no_escaped = Replace(Replace(Replace(get_operation_for_station.P_ORDER_NO, "'", "\'", "all"), Chr(10), " ", "all"), Chr(13), " ", "all")>
						<cfset product_name_escaped = Replace(Replace(Replace(get_operation_for_station.PRODUCT_NAME, "'", "\'", "all"), Chr(10), " ", "all"), Chr(13), " ", "all")>
						<cfset operation_type_escaped = Replace(Replace(Replace(get_operation_for_station.OPERATION_TYPE, "'", "\'", "all"), Chr(10), " ", "all"), Chr(13), " ", "all")>
						<cfset lot_no_escaped = Replace(Replace(Replace(get_operation_for_station.LOT_NO, "'", "\'", "all"), Chr(10), " ", "all"), Chr(13), " ", "all")>
						<cfset parti_no_escaped = Replace(Replace(Replace(get_operation_for_station.P_ORDER_PARTI_NUMBER, "'", "\'", "all"), Chr(10), " ", "all"), Chr(13), " ", "all")>
						{
							stationName: '#station_name_escaped#',
							stationId: #get_station_list_group.STATION_ID#,
							orderNo: '#order_no_escaped#',
							productName: '#product_name_escaped#',
							operationType: '#operation_type_escaped#',
							optimumTime: #get_operation_for_station.OPTIMUM_TIME#,
							optimumTotal: #get_operation_for_station.OPTIMUM_TOTAL#,
							startDate: new Date(#Year(get_operation_for_station.BASLA)#, #Month(get_operation_for_station.BASLA)-1#, #Day(get_operation_for_station.BASLA)#, #Hour(get_operation_for_station.BASLA)#, #Minute(get_operation_for_station.BASLA)#, #Second(get_operation_for_station.BASLA)#),
							endDate: new Date(#Year(get_operation_for_station.BITIR)#, #Month(get_operation_for_station.BITIR)-1#, #Day(get_operation_for_station.BITIR)#, #Hour(get_operation_for_station.BITIR)#, #Minute(get_operation_for_station.BITIR)#, #Second(get_operation_for_station.BITIR)#),
							stage: #get_operation_for_station.STAGE#,
							pOrderId: #get_operation_for_station.P_ORDER_ID#,
							pOperationId: #get_operation_for_station.P_OPERATION_ID#,
							lotNo: '#lot_no_escaped#',
							partiNo: '#parti_no_escaped#'
						}<cfif get_station_list_group.recordcount gt get_station_list_group.currentrow or get_operation_for_station.recordcount gt get_operation_for_station.currentrow>,</cfif>
					</cfloop>
				</cfif>
			</cfoutput>
		];
	</cfif>
	
	// DHTMLX Gantt başlatma
	function initGantt() {
		// DHTMLX Gantt konfigürasyonu
		gantt.config.columns = [
			{name: "text", label: "İstasyon", tree: true, width: 200, resize: true},
			{name: "operation", label: "Operasyon", width: 150, resize: true},
			{name: "order", label: "Emir No", width: 100, resize: true},
			{name: "product", label: "Ürün", width: 200, resize: true},
			{name: "start_date", label: "Başlangıç", align: "center", width: 120, resize: true},
			{name: "duration", label: "Süre", align: "center", width: 80, resize: true}
		];
		
		gantt.config.scale_unit = "day";
		gantt.config.date_scale = "%d %M";
		gantt.config.scale_height = 50;
		gantt.config.row_height = 40;
		gantt.config.bar_height = 30;
		gantt.config.fit_tasks = true;
		gantt.config.drag_move = true;
		gantt.config.drag_resize = true;
		gantt.config.drag_progress = false;
		gantt.config.drag_links = false;
		
		// Zoom seviyesine göre scale ayarla
		updateGanttScale();
		
		// Task renkleri
		// 0: Başlamadı (Beklemede) - Turuncu
		// 1: Başladı, Devam ediyor - Mavi
		// 3: Tamamlandı (Bitti) - Kırmızı
		gantt.templates.task_class = function(start, end, task) {
			if (task.stage == 3) return "gantt_task_completed"; // Tamamlandı - Kırmızı
			if (task.stage == 1) return "gantt_task_inprogress"; // Devam ediyor - Mavi
			return "gantt_task_pending"; // Beklemede - Turuncu
		};
		
		// Task tooltip
		gantt.templates.tooltip_text = function(start, end, task) {
			return "<b>" + task.operationType + "</b><br/>" +
				"<b>Emir No:</b> " + task.orderNo + "<br/>" +
				"<b>Ürün:</b> " + task.productName + "<br/>" +
				"<b>İstasyon:</b> " + task.stationName + "<br/>" +
				"<b>Parti No:</b> " + task.partiNo + "<br/>" +
				"<b>Lot No:</b> " + task.lotNo + "<br/>" +
				"<b>Başlangıç:</b> " + formatDateTime(task.start_date) + "<br/>" +
				"<b>Bitiş:</b> " + formatDateTime(task.end_date) + "<br/>" +
				"<b>Süre:</b> " + formatDuration(task.optimumTotal) + "<br/>" +
				"<b>Durum:</b> " + getStageText(task.stage);
		};
		
		// Task text - Sadece Emir No
		gantt.templates.task_text = function(start, end, task) {
			return task.orderNo || "";
		};
		
		// Verileri DHTMLX Gantt formatına dönüştür
		convertToGanttData();
		
		// Gantt'ı başlat
		gantt.init("gantt_here");
		gantt.parse({
			data: ganttTasks,
			links: ganttLinks
		});
		
		// Event listener'lar
		
		// 1. Bitmiş operasyonlar sürükle-bırak yapılamasın
		gantt.attachEvent("onBeforeTaskDrag", function(id, mode, e) {
			var task = gantt.getTask(id);
			if (task && task.stage == 3) {
				// Tamamlanan operasyon sürüklenemez
				return false;
			}
			return true;
		});
		
		// 2. Başlamış ve bekleyen operasyonları sürüklediğimde, kendisinden sonra gelen operasyonlar da sürüklensin
		gantt.attachEvent("onAfterTaskDrag", function(id, mode, e, task, target) {
			// Sürüklenen operasyonu kaydet
			saveTaskChanges(id, task);
			
			// Aynı emir no'ya sahip ve sonraki operasyonları bul ve güncelle
			if (task && task.orderNo && (task.stage == 0 || task.stage == 1)) {
				var draggedTask = gantt.getTask(id);
				var newEndDate = draggedTask.end_date;
				var oldStartDate = task.start_date; // Sürüklemeden önceki başlangıç tarihi
				var oldEndDate = new Date(oldStartDate.getTime() + (task.duration * 24 * 60 * 60 * 1000)); // Eski bitiş tarihi
				
				// Aynı emir no'ya sahip tüm operasyonları bul
				var allTasks = gantt.getTaskBy(function(t) {
					return t.orderNo == task.orderNo && t.id != id && (t.stage == 0 || t.stage == 1);
				});
				
				// Sürüklenen operasyonun eski bitiş tarihinden sonra başlayan operasyonları bul
				allTasks.forEach(function(nextTask) {
					if (nextTask.start_date && nextTask.start_date >= oldEndDate) {
						// Sonraki operasyonun eski başlangıç tarihi ile eski bitiş tarihi arasındaki farkı hesapla
						var timeDiff = nextTask.start_date.getTime() - oldEndDate.getTime();
						
						// Yeni başlangıç tarihi = yeni bitiş tarihi + zaman farkı
						var newStartDate = new Date(newEndDate.getTime() + timeDiff);
						
						// Operasyonu güncelle
						gantt.updateTask(nextTask.id, {
							start_date: newStartDate
						});
						
						// Backend'e kaydet
						saveTaskChanges(nextTask.id, gantt.getTask(nextTask.id));
					}
				});
			}
			
			return true;
		});
		
		// 3. Tek tıklama ile detay bilgi
		gantt.attachEvent("onTaskClick", function(id, e) {
			var task = gantt.getTask(id);
			if (task && task.pOperationId) {
				openOperationDetail(task.pOperationId);
			}
			return true;
		});
		
		gantt.attachEvent("onTaskDblClick", function(id, e) {
			// Çift tıklama ile de detay aç (opsiyonel)
			var task = gantt.getTask(id);
			if (task && task.pOperationId) {
				openOperationDetail(task.pOperationId);
			}
			return false;
		});
		
		// İstatistikleri hesapla
		calculateStats();
	}
	
	function convertToGanttData() {
		ganttTasks = [];
		var taskId = 1;
		
		ganttOperations.forEach(function(op) {
			var duration = Math.max(1, Math.ceil((op.endDate.getTime() - op.startDate.getTime()) / (1000 * 60 * 60 * 24)));
			
			ganttTasks.push({
				id: taskId++,
				text: op.stationName,
				start_date: op.startDate,
				duration: duration,
				progress: op.stage == 3 ? 1 : (op.stage == 1 ? 0.5 : 0), // 3: Tamamlandı (100%), 1: Devam ediyor (50%), 0: Beklemede (0%)
				stationName: op.stationName,
				stationId: op.stationId,
				orderNo: op.orderNo,
				productName: op.productName,
				operationType: op.operationType,
				optimumTime: op.optimumTime,
				optimumTotal: op.optimumTotal,
				stage: op.stage,
				pOrderId: op.pOrderId,
				pOperationId: op.pOperationId,
				lotNo: op.lotNo,
				partiNo: op.partiNo,
				operation: op.operationType,
				order: op.orderNo,
				product: op.productName
			});
		});
	}
	
	function saveTaskChanges(taskId, task) {
		// Backend'e AJAX ile kaydet
		var startDateStr = gantt.templates.format_date({
			date: task.start_date,
			task: task
		});
		var endDateStr = gantt.templates.format_date({
			date: task.end_date,
			task: task
		});
		
		$.ajax({
			type: 'POST',
			url: '<cfoutput>#request.self#</cfoutput>?fuseaction=prod.ajax_update_operation_time',
			data: {
				operation_id: task.pOperationId,
				start_date: startDateStr,
				end_date: endDateStr,
				duration: task.duration
			},
			success: function(response) {
				console.log('Operasyon zamanlaması güncellendi');
			},
			error: function() {
				alert('Zamanlama güncellenirken bir hata oluştu.');
			}
		});
	}
	
	function formatDateTime(date) {
		if (!date) return '';
		var day = String(date.getDate()).padStart(2, '0');
		var month = String(date.getMonth() + 1).padStart(2, '0');
		var year = date.getFullYear();
		var hours = String(date.getHours()).padStart(2, '0');
		var minutes = String(date.getMinutes()).padStart(2, '0');
		return day + '/' + month + '/' + year + ' ' + hours + ':' + minutes;
	}
	
	function formatDuration(seconds) {
		if (!seconds) return '0 sn';
		var hours = Math.floor(seconds / 3600);
		var minutes = Math.floor((seconds % 3600) / 60);
		var secs = Math.floor(seconds % 60);
		var result = '';
		if (hours > 0) result += hours + ' sa ';
		if (minutes > 0) result += minutes + ' dk ';
		if (secs > 0 || result === '') result += secs + ' sn';
		return result.trim();
	}
	
	function getStageText(stage) {
		switch(stage) {
			case 0: return 'Başlamadı';
			case 1: return 'Başladı, Devam ediyor';
			case 3: return 'Tamamlandı';
			default: return 'Bilinmiyor';
		}
	}
	
	function updateZoomLevel(level) {
		currentZoomLevel = level;
		var zoomButtons = document.querySelectorAll('.gantt-zoom-btn');
		zoomButtons.forEach(function(btn) {
			btn.classList.remove('active');
			if (btn.dataset.zoom === level) {
				btn.classList.add('active');
			}
		});
		
		updateGanttScale();
		if (gantt) {
			gantt.render();
		}
	}
	
	function updateGanttScale() {
		switch(currentZoomLevel) {
			case 'hour':
				gantt.config.scale_unit = "hour";
				gantt.config.step = 1;
				gantt.config.date_scale = "%H:%i";
				gantt.config.scales = [
					{unit: "day", step: 1, format: "%d %M"},
					{unit: "hour", step: 1, format: "%H:%i"}
				];
				break;
			case 'day':
				gantt.config.scale_unit = "day";
				gantt.config.step = 1;
				gantt.config.date_scale = "%d %M";
				gantt.config.scales = [
					{unit: "month", step: 1, format: "%F, %Y"},
					{unit: "day", step: 1, format: "%d %M"}
				];
				break;
			case 'week':
				gantt.config.scale_unit = "week";
				gantt.config.step = 1;
				gantt.config.date_scale = "%d %M";
				gantt.config.scales = [
					{unit: "month", step: 1, format: "%F, %Y"},
					{unit: "week", step: 1, format: "Hafta %W"}
				];
				break;
			case 'month':
				gantt.config.scale_unit = "month";
				gantt.config.step = 1;
				gantt.config.date_scale = "%F, %Y";
				gantt.config.scales = [
					{unit: "year", step: 1, format: "%Y"},
					{unit: "month", step: 1, format: "%F"}
				];
				break;
		}
	}
	
	function exportToPDF() {
		if (!gantt) {
			alert('Gantt Chart henüz yüklenmedi. Lütfen bekleyin.');
			return;
		}
		
		var container = document.getElementById('gantt_here');
		html2canvas(container, {
			scale: 2,
			useCORS: true,
			backgroundColor: '#ffffff'
		}).then(function(canvas) {
			var imgData = canvas.toDataURL('image/png');
			var { jsPDF } = window.jspdf;
			var pdf = new jsPDF('landscape', 'mm', 'a4');
			var imgWidth = 297;
			var imgHeight = (canvas.height * imgWidth) / canvas.width;
			pdf.addImage(imgData, 'PNG', 0, 0, imgWidth, imgHeight);
			pdf.save('Gantt_Chart_' + new Date().getTime() + '.pdf');
		});
	}
	
	function exportToPNG() {
		if (!gantt) {
			alert('Gantt Chart henüz yüklenmedi. Lütfen bekleyin.');
			return;
		}
		
		var container = document.getElementById('gantt_here');
		html2canvas(container, {
			scale: 2,
			useCORS: true,
			backgroundColor: '#ffffff'
		}).then(function(canvas) {
			var link = document.createElement('a');
			link.download = 'Gantt_Chart_' + new Date().getTime() + '.png';
			link.href = canvas.toDataURL('image/png');
			link.click();
		});
	}
	
	function exportToExcel() {
		if (ganttOperations.length === 0) {
			alert('Dışa aktarılacak veri bulunamadı.');
			return;
		}
		
		var csv = 'İstasyon,Emir No,Ürün,Operasyon Tipi,Parti No,Lot No,Başlangıç,Bitiş,Süre (sn),Durum\n';
		ganttOperations.forEach(function(op) {
			csv += '"' + op.stationName + '",';
			csv += '"' + op.orderNo + '",';
			csv += '"' + op.productName + '",';
			csv += '"' + op.operationType + '",';
			csv += '"' + op.partiNo + '",';
			csv += '"' + op.lotNo + '",';
			csv += '"' + formatDateTime(op.startDate) + '",';
			csv += '"' + formatDateTime(op.endDate) + '",';
			csv += op.optimumTotal + ',';
			csv += '"' + getStageText(op.stage) + '"\n';
		});
		
		var blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
		var link = document.createElement('a');
		link.href = URL.createObjectURL(blob);
		link.download = 'Gantt_Chart_' + new Date().getTime() + '.csv';
		link.click();
	}
	
	function refreshChart() {
		if (gantt) {
			initGantt();
		} else {
			location.reload();
		}
	}
	
	function calculateStats() {
		var total = ganttOperations.length;
		var completed = ganttOperations.filter(function(op) { return op.stage == 3; }).length; // Tamamlandı
		var pending = ganttOperations.filter(function(op) { return op.stage == 0; }).length; // Başlamadı
		var inProgress = ganttOperations.filter(function(op) { return op.stage == 1; }).length; // Devam ediyor
		var totalDuration = ganttOperations.reduce(function(sum, op) { return sum + (op.optimumTotal || 0); }, 0);
		
		if (document.getElementById('stat-total')) {
			document.getElementById('stat-total').textContent = total;
			document.getElementById('stat-completed').textContent = completed;
			document.getElementById('stat-pending').textContent = pending;
			document.getElementById('stat-delayed').textContent = inProgress; // Devam ediyor sayısı
			document.getElementById('stat-duration').textContent = formatDuration(totalDuration);
		}
		
		// Grafikleri çiz
		drawStatsCharts(completed, pending, inProgress);
	}
	
	function drawStatsCharts(completed, pending, inProgress) {
		// Google Charts yüklendikten sonra grafikleri çiz
		google.charts.load("current", {packages:["corechart"]});
		google.charts.setOnLoadCallback(function() {
			// Pie Chart - Durum Dağılımı
			var pieData = google.visualization.arrayToDataTable([
				['Durum', 'Sayı'],
				['Tamamlanan', completed],
				['Başlamadı', pending],
				['Devam ediyor', inProgress]
			]);
			
			var pieOptions = {
				title: 'Operasyon Durum Dağılımı',
				titleTextStyle: {
					fontSize: 18,
					bold: true,
					color: '#2c3e50',
					fontName: 'Arial, sans-serif'
				},
				colors: ['#f44336', '#ff9800', '#2196F3'], // Tamamlanan: Kırmızı, Başlamadı: Turuncu, Devam ediyor: Mavi
				pieHole: 0.5,
				pieSliceText: 'percentage',
				pieSliceTextStyle: {
					color: 'white',
					fontSize: 14,
					bold: true,
					fontName: 'Arial, sans-serif'
				},
				legend: {
					position: 'bottom',
					alignment: 'center',
					textStyle: {
						fontSize: 13,
						color: '#555',
						fontName: 'Arial, sans-serif'
					},
					pageIndex: 0
				},
				chartArea: {
					left: 10,
					top: 60,
					width: '95%',
					height: '75%'
				},
				tooltip: {
					textStyle: {
						fontSize: 13,
						fontName: 'Arial, sans-serif'
					},
					trigger: 'selection',
					showColorCode: true
				},
				backgroundColor: {
					fill: 'transparent'
				},
				animation: {
					startup: true,
					duration: 1000,
					easing: 'out'
				},
				enableInteractivity: true,
				is3D: false
			};
			
			var pieChart = new google.visualization.PieChart(document.getElementById('stats-pie-chart'));
			pieChart.draw(pieData, pieOptions);
			
			// Bar Chart - İstasyon Bazında Toplam Operasyon Süreleri (Stacked)
			var stationStats = {};
			ganttOperations.forEach(function(op) {
				if (!stationStats[op.stationName]) {
					stationStats[op.stationName] = {
						pending: 0,    // Başlamamış (stage == 0) - Turuncu
						inProgress: 0, // Başlamış (stage == 1) - Mavi
						completed: 0   // Bitmiş (stage == 3) - Kırmızı
					};
				}
				
				// Süreyi saniyeden saate çevir (veya dakikaya)
				var durationHours = (op.optimumTotal || 0) / 3600; // Saniyeyi saate çevir
				
				if (op.stage == 0) {
					stationStats[op.stationName].pending += durationHours;
				} else if (op.stage == 1) {
					stationStats[op.stationName].inProgress += durationHours;
				} else if (op.stage == 3) {
					stationStats[op.stationName].completed += durationHours;
				}
			});
			
			// Stacked bar chart için veri hazırla
			var barDataArray = [['İstasyon', 'Başlamamış (saat)', 'Başlamış (saat)', 'Bitmiş (saat)']];
			var stationArray = [];
			
			for (var station in stationStats) {
				var total = stationStats[station].pending + stationStats[station].inProgress + stationStats[station].completed;
				stationArray.push({
					name: station,
					pending: stationStats[station].pending,
					inProgress: stationStats[station].inProgress,
					completed: stationStats[station].completed,
					total: total
				});
			}
			
			// Toplam süreye göre sırala (en yüksekten en düşüğe)
			stationArray.sort(function(a, b) {
				return b.total - a.total;
			});
			
			// İlk 10 istasyonu göster
			var stationsToShow = stationArray.slice(0, 10);
			
			stationsToShow.forEach(function(station) {
				barDataArray.push([
					station.name,
					Math.round(station.pending * 100) / 100,      // 2 ondalık basamak
					Math.round(station.inProgress * 100) / 100,
					Math.round(station.completed * 100) / 100
				]);
			});
			
			var barData = google.visualization.arrayToDataTable(barDataArray);
			
			var barOptions = {
				title: 'İstasyon Bazında Toplam Operasyon Süreleri',
				titleTextStyle: {
					fontSize: 18,
					bold: true,
					color: '#2c3e50',
					fontName: 'Arial, sans-serif'
				},
				isStacked: true,
				hAxis: {
					title: 'Toplam Süre (Saat)',
					titleTextStyle: {
						fontSize: 13,
						bold: true,
						color: '#555',
						fontName: 'Arial, sans-serif'
					},
					textStyle: {
						fontSize: 11,
						color: '#666',
						fontName: 'Arial, sans-serif'
					},
					gridlines: {
						color: '#e0e0e0',
						count: 5
					},
					baselineColor: '#bdbdbd',
					minValue: 0,
					format: '#,##0.0'
				},
				vAxis: {
					title: 'İstasyon',
					titleTextStyle: {
						fontSize: 13,
						bold: true,
						color: '#555',
						fontName: 'Arial, sans-serif'
					},
					textStyle: {
						fontSize: 11,
						color: '#666',
						fontName: 'Arial, sans-serif'
					},
					gridlines: {
						color: '#f5f5f5'
					}
				},
				colors: ['#ff9800', '#2196F3', '#f44336'], // Başlamamış: Turuncu, Başlamış: Mavi, Bitmiş: Kırmızı
				legend: {
					position: 'bottom',
					alignment: 'center',
					textStyle: {
						fontSize: 12,
						color: '#555',
						fontName: 'Arial, sans-serif'
					}
				},
				chartArea: {
					left: 160,
					top: 60,
					width: '72%',
					height: '70%'
				},
				tooltip: {
					textStyle: {
						fontSize: 13,
						fontName: 'Arial, sans-serif',
						color: '#333'
					},
					trigger: 'focus',
					showColorCode: true
				},
				backgroundColor: {
					fill: 'transparent'
				},
				animation: {
					startup: true,
					duration: 1000,
					easing: 'out'
				},
				enableInteractivity: true,
				focusTarget: 'category',
				bar: {
					groupWidth: '75%'
				}
			};
			
			var barChart = new google.visualization.BarChart(document.getElementById('stats-bar-chart'));
			barChart.draw(barData, barOptions);
		});
	}
	
	// Sayfa yüklendiğinde istatistikleri hesapla (Gantt yüklendikten sonra)
	// calculateStats() fonksiyonu initGantt() içinde çağrılıyor
	
	// Operasyon detayını aç
	function openOperationDetail(operationId) {
		if (!operationId) return;
		var url = '<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_list_ezgi_iflow_production_operation_result&operation_id=' + operationId;
		if (typeof windowopen === 'function') {
			windowopen(url, 'wide');
		} else if (typeof window.open === 'function') {
			window.open(url, '_blank', 'width=1200,height=800,scrollbars=yes');
		} else {
			alert('Operasyon ID: ' + operationId);
		}
	}
	
	// Sayfa yüklendiğinde Gantt'ı başlat
	window.addEventListener('load', function() {
		setTimeout(function() {
			initGantt();
		}, 500);
	});
	
	if (document.getElementById('keyword')) {
		document.getElementById('keyword').focus();
	}
	function input_control() {
		return true;
	}
</script>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="Gantt Chart - Üretim Operasyon Zaman Çizelgesi" scroll="1">
		<div class="gantt-chart-container">
			<!-- Kontroller -->
			<div class="gantt-controls">
				<div class="gantt-controls-left">
					<div class="gantt-zoom-controls">
						<span style="margin-right: 10px; font-weight: 500;">Zoom:</span>
						<button class="gantt-zoom-btn" data-zoom="hour" onclick="updateZoomLevel('hour')">Saat</button>
						<button class="gantt-zoom-btn active" data-zoom="day" onclick="updateZoomLevel('day')">Gün</button>
						<button class="gantt-zoom-btn" data-zoom="week" onclick="updateZoomLevel('week')">Hafta</button>
						<button class="gantt-zoom-btn" data-zoom="month" onclick="updateZoomLevel('month')">Ay</button>
					</div>
				</div>
				<div class="gantt-controls-right">
					<button class="gantt-btn gantt-btn-primary" onclick="refreshChart()">
						<i class="fa fa-refresh"></i> Yenile
					</button>
					<button class="gantt-btn gantt-btn-success" onclick="exportToPDF()">
						<i class="fa fa-file-pdf-o"></i> PDF
					</button>
					<button class="gantt-btn gantt-btn-success" onclick="exportToPNG()">
						<i class="fa fa-file-image-o"></i> PNG
					</button>
					<button class="gantt-btn gantt-btn-secondary" onclick="exportToExcel()">
						<i class="fa fa-file-excel-o"></i> Excel
					</button>
				</div>
			</div>
			
			<!-- Legend -->
			<div class="gantt-legend">
				<div class="gantt-legend-item">
					<div class="gantt-legend-color" style="background: orange;"></div>
					<span>Başlamadı</span>
				</div>
				<div class="gantt-legend-item">
					<div class="gantt-legend-color" style="background: #2196F3;"></div>
					<span>Devam ediyor</span>
				</div>
				<div class="gantt-legend-item">
					<div class="gantt-legend-color" style="background: red;"></div>
					<span>Tamamlandı</span>
				</div>
			</div>
			
			<!-- Chart Container -->
			<div class="gantt-chart-wrapper">
				<div id="gantt_here" style="height: <cfoutput>#get_station_list_group.recordcount*60+100#</cfoutput>px; width: 100%;"></div>
			</div>
			
			<!-- İstatistikler -->
			<div class="gantt-stats">
				<div class="gantt-stat-item">
					<div class="gantt-stat-label">Toplam Operasyon</div>
					<div class="gantt-stat-value" id="stat-total">0</div>
				</div>
				<div class="gantt-stat-item">
					<div class="gantt-stat-label">Tamamlanan</div>
					<div class="gantt-stat-value" style="color: #f44336;" id="stat-completed">0</div>
				</div>
				<div class="gantt-stat-item">
					<div class="gantt-stat-label">Başlamadı</div>
					<div class="gantt-stat-value" style="color: #ff9800;" id="stat-pending">0</div>
				</div>
				<div class="gantt-stat-item">
					<div class="gantt-stat-label">Devam ediyor</div>
					<div class="gantt-stat-value" style="color: #2196F3;" id="stat-delayed">0</div>
				</div>
				<div class="gantt-stat-item">
					<div class="gantt-stat-label">Toplam Süre</div>
					<div class="gantt-stat-value" id="stat-duration">0 sn</div>
				</div>
			</div>
			
			<!-- İstatistik Grafikleri -->
			<div class="col col-12 col-md-12 col-sm-12 col-xs-12" style="margin-top: 30px;">
				<div class="row">
					<div class="col col-12 col-md-6 col-sm-12 col-xs-12" style="margin-bottom: 20px;">
						<cf_box title="Operasyon Durum Dağılımı" scroll="0">
							<div id="stats-pie-chart" style="height: 350px; width: 100%; padding: 15px; background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); border-radius: 8px;"></div>
						</cf_box>
					</div>
					<div class="col col-12 col-md-6 col-sm-12 col-xs-12" style="margin-bottom: 20px;">
						<cf_box title="İstasyon Bazında Toplam Operasyon Süreleri" scroll="0">
							<div id="stats-bar-chart" style="height: 350px; width: 100%; padding: 15px; background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); border-radius: 8px;"></div>
						</cf_box>
					</div>
				</div>
			</div>
		</div>
	</cf_box>
</div>

<!---<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script type="text/javascript">
	<cfif operasyonlar_p_order.recordcount>
      	google.charts.load('current', {'packages':['gantt']});
      	google.charts.setOnLoadCallback(drawChart);


		function drawChart() 
		{
			var data = new google.visualization.DataTable();
			data.addColumn('string', 'Task ID');
			data.addColumn('string', 'Task Name');
			data.addColumn('string', 'Resource');
			data.addColumn('date', 'Start Date');
			data.addColumn('date', 'End Date');
			data.addColumn('number', 'Duration');
			data.addColumn('number', 'Percent Complete');
			data.addColumn('string', 'Dependencies');
			<cfif operasyonlar_p_order.recordcount>
				data.addRows([
				<cfoutput query="operasyonlar_p_order">	
					<cfloop query="get_station_list_group">
						<cfquery name="get_operation_for_station" dbtype="query">
							SELECT OPERATION_TYPE, OPTIMUM_TIME, BASLA, BITIR FROM operasyonlar WHERE P_ORDER_ID = #operasyonlar_p_order.P_ORDER_ID# AND STATION_ID = #get_station_list_group.STATION_ID# <cfif len(attributes.operation_type)>AND OPERATION_TYPE LIKE '%#attributes.operation_type#%'</cfif>			
						</cfquery>
						<cfif get_operation_for_station.recordcount>
							['#operasyonlar_p_order.currentrow#', '#operasyonlar_p_order.P_ORDER_NO#-#operasyonlar_p_order.PRODUCT_NAME#', '#get_station_list_group.STATION_NAME#',
							new Date(#Year(get_operation_for_station.BASLA)#, #Month(get_operation_for_station.BASLA)-1#, #Day(get_operation_for_station.BASLA)#, #Hour(get_operation_for_station.BASLA)#, #Minute(get_operation_for_station.BASLA)#, #Second(get_operation_for_station.BASLA)#),
							new Date(#Year(get_operation_for_station.BITIR)#, #Month(get_operation_for_station.BITIR)-1#, #Day(get_operation_for_station.BITIR)#, #Hour(get_operation_for_station.BITIR)#, #Minute(get_operation_for_station.BITIR)#, #Second(get_operation_for_station.BITIR)#),
							null, 0, null]<cfif operasyonlar_p_order.recordcount gt operasyonlar_p_order.currentrow>,</cfif>
						</cfif>
					</cfloop>
					
				</cfoutput>
				]);
			</cfif>
			
			var options = {
			  height: <cfoutput>(#operasyonlar_p_order.recordcount#</cfoutput>*30)+50,
			  gantt: {
				trackHeight: 30
			  }
			};
	
			var chart = new google.visualization.Gantt(document.getElementById('chart_div'));
			chart.draw(data, options);
		}

	</cfif>
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;		
	}
</script>--->
