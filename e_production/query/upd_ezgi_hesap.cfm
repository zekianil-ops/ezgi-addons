<!---
    File: upd_ezgi_hesap.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset wrk_id = dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*100)>
<cfquery name="get_shift" datasource="#dsn3#">
	SELECT     
    	MASTER_PLAN_CAT_ID
	FROM         
    	EZGI_MASTER_PLAN
	WHERE     
    	MASTER_PLAN_ID = #attributes.master_plan_id#
</cfquery>
<cfset ezgi_shift_id = get_shift.MASTER_PLAN_CAT_ID>
<cfquery name="GET_SHIFT_INFO" datasource="#DSN#"> <!---Kullanılan Vardiyanın Çalışma saatleri toplanıyor--->
	SELECT     
    	START_HOUR, 
        END_HOUR, 
        START_MIN, 
        END_MIN, 
        STD_START_HOUR, 
        STD_START_MIN, 
        STD_END_HOUR, 
        STD_END_MIN, 
        WEEK_OFFDAY
	FROM         
    	SETUP_SHIFTS
	WHERE     
    	SHIFT_ID = #ezgi_shift_id#
</cfquery>

<cfif not GET_SHIFT_INFO.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='1080.Çalışma Dönemi Tanımlayınız'>");
		history.back();	
	</script>
<cfelseif not len(GET_SHIFT_INFO.START_HOUR) or not len(GET_SHIFT_INFO.END_HOUR) or not len(GET_SHIFT_INFO.START_MIN) or not len(GET_SHIFT_INFO.END_MIN) or not len(GET_SHIFT_INFO.STD_START_HOUR) or not len(GET_SHIFT_INFO.STD_END_HOUR) or not len(GET_SHIFT_INFO.STD_START_MIN) or not len(GET_SHIFT_INFO.STD_END_MIN)>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='1081.Çalışma Programındaki Başlama ve Bitiş Saatlerini Tanımlayınız !!!'>");
		history.back();	
	</script>
</cfif>
<cfquery name="get_timing_type" datasource="#dsn3#">
	SELECT     
    	ISNULL(TIMING_TYPE,0) as TIMING_TYPE
	FROM         
    	EZGI_MASTER_PLAN_SABLON
	WHERE     
    	SHIFT_ID = #ezgi_shift_id# AND 
        SIRA = 0
</cfquery>

<cfif get_timing_type.timing_type eq 0 or not get_timing_type.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='1082.Master Plan Şablonundaki Planlama Zaman Türünü Giriniz !!!'>");
		history.back();	
	</script>
</cfif>
<cfquery name="get_general_offtimes" datasource="#dsn#"><!---Genel Tatil Zamanları Bulunuyor--->
	SELECT     
    	START_DATE, 
        DATEADD(d, 1, FINISH_DATE) AS FINISH_DATE, 
        IS_HALFOFFTIME
	FROM         
    	SETUP_GENERAL_OFFTIMES
</cfquery>
<cftransaction>
	<cfif get_timing_type.timing_type eq 2> <!---Ardışık Süre Planlama--->
		<cfif islem eq 2> <!---Planlama zamanlaması tam değil ise zamanlanmış operasyonlar sıfırlanıyor--->
            <cfquery name="upd_operation_time" datasource="#dsn3#">
                UPDATE    
                    PRODUCTION_OPERATION
                SET              
                    O_START_DATE = NULL, 
                    O_STATION_IP = NULL, 
                    O_TOTAL_PROCESS_TIME = NULL, 
                    O_FINISH_DATE = NULL
                FROM         
                    PRODUCTION_OPERATION INNER JOIN
                    EZGI_OPERATION_S AS EOS ON PRODUCTION_OPERATION.P_OPERATION_ID = EOS.P_OPERATION_ID
                WHERE     
                    EOS.MASTER_ALT_PLAN_ID IN
                                            (
                                            SELECT     
                                                MASTER_ALT_PLAN_ID
                                            FROM          
                                                EZGI_MASTER_ALT_PLAN
                                            WHERE      
                                                MASTER_ALT_PLAN_ID = #master_alt_plan_id# OR
                                                RELATED_MASTER_ALT_PLAN_ID = #master_alt_plan_id#
                                            )
            </cfquery>
        </cfif>
        <cfquery name="get_calculate_operation" datasource="#dsn3#"> <!---ilgili alt plana ait tüm operasyonlar bulunuyor--->
            SELECT     
                EOS.P_ORDER_ID, 
                EOS.STOCK_ID, 
                EOS.SPEC_MAIN_ID,
                EOS.PRODUCT_NAME, 
                EOS.OPERATION_TYPE_ID, 
                EOS.P_OPERATION_ID, 
                EOS.O_START_DATE,
                EOS.O_FINISH_DATE, 
                EOS.O_STATION_IP,
                EOS.QUANTITY,
                EMAP.PLAN_START_DATE, 
                EMPSG.TYPE AS SIRA, 
                EOS.PO_RELATED_ID AS UST_P_ORDER_ID,
                CAST(EOS.PRODUCTION_LEVEL AS float) AS PRODUCTION_LEVEL
            FROM         
                EZGI_OPERATION_S AS EOS INNER JOIN
                EZGI_MASTER_ALT_PLAN AS EMAP ON EOS.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
                EZGI_MASTER_PLAN AS EMP ON EMAP.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID INNER JOIN
                EZGI_MASTER_PLAN_SABLON_GRP AS EMPSG ON EMAP.PROCESS_ID = EMPSG.P
            WHERE     
                EOS.O_START_DATE IS NULL AND 
                EMAP.MASTER_ALT_PLAN_ID IN
                                            (
                                            SELECT     
                                                MASTER_ALT_PLAN_ID
                                            FROM          
                                                EZGI_MASTER_ALT_PLAN
                                            WHERE      
                                                MASTER_ALT_PLAN_ID = #master_alt_plan_id# OR
                                                RELATED_MASTER_ALT_PLAN_ID = #master_alt_plan_id#
                                            )
            ORDER BY 
                SIRA DESC, 
                PRODUCTION_LEVEL DESC
        </cfquery>
        <cfset operation_id_list = Valuelist(get_calculate_operation.P_OPERATION_ID)> <!---Planlaması yapılacak operasyonların listesi--->
        <cfset sira2 = 0>
        <cfdump var="#get_calculate_operation#">
        <cfloop query="get_calculate_operation">
            <!---<cfoutput>#currentrow#</cfoutput>--->
            <cfquery name="get_station_optimum_time" datasource="#dsn3#"><!---Operasyon İçin İstasyon ve İşlem ile Hazırlık Süreleri Alınıyor - İşlem ve Hazırlık Süresi Tanımlanmamışsa 1 birim Tanımlanıyor--->
                SELECT     
                    WP.WS_ID, 
                    ISNULL(W.SET_PERIOD_HOUR, 0) AS SET_PERIOD_HOUR, 
                    ISNULL(W.SET_PERIOD_MINUTE, 1) AS SET_PERIOD_MINUTE, 
                    ISNULL(
                            (
                            SELECT     
                                OPTIMUM_TIME
                            FROM         
                                EZGI_OPERATION_OPTIMUM_TIME
                            WHERE     
                                STATUS = 1 AND 
                                STOCK_ID = #STOCK_ID# AND 
                                OPERATION_TYPE_ID = WP.OPERATION_TYPE_ID AND 
                                STATION_ID = WP.WS_ID
                            )
                    , 1) AS OPTIMUM_TIME 
                FROM         
                    WORKSTATIONS_PRODUCTS AS WP INNER JOIN
                    WORKSTATIONS AS W ON WP.WS_ID = W.STATION_ID
                WHERE     
                    WP.OPERATION_TYPE_ID = #OPERATION_TYPE_ID#
            </cfquery>
            <!---<cfdump expand="yes" var="#get_station_optimum_time#">--->
            <cfloop query="get_station_optimum_time">
                <cfset 'SET_PERIOD_HOUR_#WS_ID#' = SET_PERIOD_HOUR>
                <cfset 'SET_PERIOD_MINUTE_#WS_ID#' = SET_PERIOD_MINUTE>
                <cfset 'OPTIMUM_TIME_#WS_ID#' = OPTIMUM_TIME>
            </cfloop>
            <cfset station_id_list = Valuelist(get_station_optimum_time.WS_ID)>
            <cfquery name="get_recetede_uretilen_varmi" datasource="#dsn3#"><!--- Reçetede Üretilen Ürün Var mı--->
                SELECT     
                    SMR.STOCK_ID,
                    SMR.RELATED_MAIN_SPECT_ID
                FROM         
                    SPECT_MAIN AS SM INNER JOIN
                    SPECT_MAIN_ROW AS SMR ON SM.SPECT_MAIN_ID = SMR.SPECT_MAIN_ID INNER JOIN
                    STOCKS ON SMR.STOCK_ID = STOCKS.STOCK_ID
                WHERE     
                    SM.SPECT_MAIN_ID = #SPEC_MAIN_ID# AND 
                    STOCKS.IS_PRODUCTION = 1
            </cfquery>
            <cfdump expand="yes" var="#get_recetede_uretilen_varmi#">
            <cfquery name="en_uygun_istasyon" datasource="#dsn3#"> <!---Listedeki istasyonlar İçinde En Erken Başlayabilecek Olanı Seçiliyor--->
                SELECT     
                    TOP (1) O_FINISH_DATE, 
                    STATION_ID
                FROM         
                    (
                    SELECT     
                        MAX(POR.O_FINISH_DATE) AS O_FINISH_DATE, 
                        W.STATION_ID
                    FROM          
                        PRODUCTION_OPERATION AS POR RIGHT OUTER JOIN
                        WORKSTATIONS AS W ON POR.O_STATION_IP = W.STATION_ID
                    GROUP BY 
                        W.STATION_ID
                        HAVING      
                            W.STATION_ID IN (#station_id_list#)
                    ) AS TBL
                ORDER BY 
                    O_FINISH_DATE
            </cfquery>
            <!---Bura--->
            <cfdump expand="yes" var="#en_uygun_istasyon#">
            <cfif get_recetede_uretilen_varmi.recordcount> <!---Eğer Reçetede Üretilen Ürün varsa üretim planı varmı bakılıyor--->
                <cfset recetede_uretilen_stock_id_list = Valuelist(get_recetede_uretilen_varmi.STOCK_ID)>
                <cfset recetede_uretilen_stock_id_list = ListDeleteDuplicates(recetede_uretilen_stock_id_list,',')>
                <cfset recetede_uretilen_spect_id_list = Valuelist(get_recetede_uretilen_varmi.RELATED_MAIN_SPECT_ID)>
                <cfset recetede_uretilen_spect_id_list = ListDeleteDuplicates(recetede_uretilen_spect_id_list,',')>
                <cfquery name="get_alt_uretim" datasource="#dsn3#">
                    SELECT
                        O_FINISH_DATE
                    FROM
                        EZGI_OPERATION_S
                    WHERE     
                        STOCK_ID IN (#recetede_uretilen_stock_id_list#) AND
                        SPEC_MAIN_ID IN (#recetede_uretilen_spect_id_list#) AND
                        P_OPERATION_ID IN (#operation_id_list#)
                    ORDER BY
                        O_FINISH_DATE DESC	
                </cfquery>
            <cfelse>
                <cfset get_alt_uretim.recordcount =0>
            </cfif>
            <cfif len(en_uygun_istasyon.O_FINISH_DATE) or get_alt_uretim.recordcount> <!---İstasyona ait iş bulunduysa Son İşin Bitiş Zamanı Baz Alınıyor--->
                <cfif get_alt_uretim.recordcount>
                    <cfif len(en_uygun_istasyon.O_FINISH_DATE)>
                        <cfif get_alt_uretim.O_FINISH_DATE gt en_uygun_istasyon.O_FINISH_DATE>  
                            <cfset yeni_is_basi = get_alt_uretim.O_FINISH_DATE>
                        <cfelse>
                            <cfset yeni_is_basi = en_uygun_istasyon.O_FINISH_DATE>
                        </cfif>
                    <cfelse>
                        <cfset yeni_is_basi = get_alt_uretim.O_FINISH_DATE>
                    </cfif>
                <cfelse>
                    <cfset yeni_is_basi = en_uygun_istasyon.O_FINISH_DATE>
                </cfif>
                
                <!---<cfdump expand="yes" var="#get_alt_uretim#">
                <cfdump expand="yes" var="#get_calculate_operation#">
                <cfoutput>#yeni_is_basi# </cfoutput><cfabort>--->
                <cfset yeni_tarih = Dateformat(yeni_is_basi,dateformat_style)>
                <cfset yeni_saat = DatePart("h", yeni_is_basi)>
                <cfset yeni_dakika = DatePart("n", yeni_is_basi)>
                <cfset yeni_saniye = DatePart("s", yeni_is_basi)>
                <cfset yeni_tarih= DateAdd('h',yeni_saat,yeni_tarih)>
                <cfset yeni_tarih= DateAdd('n',yeni_dakika,yeni_tarih)>
                <cfset yeni_tarih= DateAdd('s',yeni_saniye,yeni_tarih)>
                <cfset yeni_is_basi = yeni_tarih>
            <cfelse> <!---İstasyona ait iş bulunmadıysa Master Alt Planın Başlama tarihi Baz alınıyor---> 
                <cfset yeni_is_basi = Dateformat(PLAN_START_DATE,dateformat_style)>
                <cfset yeni_is_basi = DateAdd('h',GET_SHIFT_INFO.START_HOUR,yeni_is_basi)>
            </cfif>
            <cfset ezgi_work_time = (Evaluate('SET_PERIOD_HOUR_#en_uygun_istasyon.STATION_ID#')*3600)+(Evaluate('SET_PERIOD_MINUTE_#en_uygun_istasyon.STATION_ID#')*60)+(Evaluate('OPTIMUM_TIME_#en_uygun_istasyon.STATION_ID#')*QUANTITY)> <!---İş İçin Toplam çalışma Zamanı Hesaplanıyor Hazırlık+(İşlem süresi * İş Adedi)--->
            <cfset toplam_is_suresi = ezgi_work_time>
            <cfset is_basi = yeni_is_basi>
            <!---#P_OPERATION_ID# - #yeni_is_basi# - #ezgi_work_time#<br>--->
            <cfinclude template="upd_ezgi_hesap_calc.cfm">
            <cfquery name="upd_operation_optimum_info" datasource="#dsn3#">
                UPDATE    
                    PRODUCTION_OPERATION
                SET              
                    O_START_DATE = #yeni_is_basi#,
                    O_FINISH_DATE =#is_sonu#,
                    O_STATION_IP = #en_uygun_istasyon.STATION_ID#, 
                    O_TOTAL_PROCESS_TIME = #ezgi_work_time#
                WHERE     
                    P_OPERATION_ID = #P_OPERATION_ID#
            </cfquery>
            <!---Burası3--->
        </cfloop>
        <cfquery name="get_p_order_list_grup" dbtype="query">
            SELECT
                P_ORDER_ID
            FROM
                get_calculate_operation
            GROUP BY
                P_ORDER_ID
        </cfquery>
        <cfset p_order_id_list = valuelist(get_p_order_list_grup.P_ORDER_ID)>

        <cfloop list="#p_order_id_list#" index="i">
            <cfquery name="get_min_start_date" datasource="#dsn3#"> <!---Üretim Planı Tarih Güncelleme--->
                SELECT     
                    MIN(O_START_DATE) AS O_START_DATE
                FROM         
                    PRODUCTION_OPERATION
                WHERE
                    P_ORDER_ID = #i#      
                GROUP BY 
                    P_ORDER_ID
            </cfquery>
            <cfquery name="get_max_finish_date" datasource="#dsn3#">
                SELECT     
                    MAX(O_FINISH_DATE) AS O_FINISH_DATE
                FROM         
                    PRODUCTION_OPERATION
                WHERE
                    P_ORDER_ID = #i#      
                GROUP BY 
                    P_ORDER_ID
            </cfquery>
            <cfif get_min_start_date.recordcount and get_max_finish_date.recordcount>
                <cfquery name="upd_p_order_date" datasource="#dsn3#">
                    UPDATE
                        PRODUCTION_ORDERS
                    SET
                        START_DATE = #CreateODBCDateTime(get_min_start_date.O_START_DATE)#,
                        FINISH_DATE = #CreateODBCDateTime(get_max_finish_date.O_FINISH_DATE)#
                    WHERE
                        P_ORDER_ID = #i# 
                </cfquery>
            </cfif>
        </cfloop>
        <cfquery name="get_min_start_date_alt_plan" datasource="#dsn3#">
            SELECT     
                MIN(PO.O_START_DATE) AS O_START_DATE
            FROM         
                PRODUCTION_OPERATION AS PO INNER JOIN
                EZGI_OPERATION_S AS EOS ON PO.P_OPERATION_ID = EOS.P_OPERATION_ID
            WHERE     
                EOS.MASTER_ALT_PLAN_ID IN
                                        (
                                        SELECT     
                                            MASTER_ALT_PLAN_ID
                                        FROM          
                                            EZGI_MASTER_ALT_PLAN
                                        WHERE      
                                            MASTER_ALT_PLAN_ID = #master_alt_plan_id# OR
                                            RELATED_MASTER_ALT_PLAN_ID = #master_alt_plan_id#
                                        )
        </cfquery>
        <cfquery name="get_max_finish_date_alt_plan" datasource="#dsn3#">
            SELECT     
                MAX(PO.O_FINISH_DATE) AS O_FINISH_DATE
            FROM         
                PRODUCTION_OPERATION AS PO INNER JOIN
                EZGI_OPERATION_S AS EOS ON PO.P_OPERATION_ID = EOS.P_OPERATION_ID
            WHERE     
                EOS.MASTER_ALT_PLAN_ID IN
                                        (
                                        SELECT     
                                            MASTER_ALT_PLAN_ID
                                        FROM          
                                            EZGI_MASTER_ALT_PLAN
                                        WHERE      
                                            MASTER_ALT_PLAN_ID = #master_alt_plan_id# OR
                                            RELATED_MASTER_ALT_PLAN_ID = #master_alt_plan_id#
                                        )
        </cfquery>
        <cfif get_min_start_date_alt_plan.recordcount and get_max_finish_date_alt_plan.recordcount>
            <cfquery name="upd_alt_plan_date" datasource="#dsn3#">
                UPDATE    
                    EZGI_MASTER_ALT_PLAN
                SET              
                    PLAN_START_DATE = #CreateODBCDateTime(get_min_start_date_alt_plan.O_START_DATE)#, 
                    PLAN_FINISH_DATE =#CreateODBCDateTime(get_max_finish_date_alt_plan.O_FINISH_DATE)#
                WHERE     
                    MASTER_ALT_PLAN_ID = #master_alt_plan_id#
            </cfquery>
        </cfif>
        <cfquery name="get_all_sub_plan" datasource="#dsn3#">
            SELECT MASTER_ALT_PLAN_ID FROM EZGI_MASTER_ALT_PLAN WHERE RELATED_MASTER_ALT_PLAN_ID = #master_alt_plan_id#
        </cfquery>
        <cfset all_sub_plan_list = ValueList(get_all_sub_plan.MASTER_ALT_PLAN_ID)>
        <cfloop list="#all_sub_plan_list#" index="i">
            <cfquery name="get_min_start_date_alt_plan_1" datasource="#dsn3#">
                SELECT     
                    MIN(PO.O_START_DATE) AS O_START_DATE
                FROM         
                    PRODUCTION_OPERATION AS PO INNER JOIN
                    EZGI_OPERATION_S AS EOS ON PO.P_OPERATION_ID = EOS.P_OPERATION_ID
                WHERE     
                    EOS.MASTER_ALT_PLAN_ID IN
                                            (
                                            SELECT     
                                                MASTER_ALT_PLAN_ID
                                            FROM          
                                                EZGI_MASTER_ALT_PLAN
                                            WHERE      
                                                MASTER_ALT_PLAN_ID = #i#
                                            )
            </cfquery>
            
             <cfquery name="get_max_finish_date_alt_plan_1" datasource="#dsn3#">
                SELECT     
                    MAX(PO.O_FINISH_DATE) AS O_FINISH_DATE
                FROM         
                    PRODUCTION_OPERATION AS PO INNER JOIN
                    EZGI_OPERATION_S AS EOS ON PO.P_OPERATION_ID = EOS.P_OPERATION_ID
                WHERE     
                    EOS.MASTER_ALT_PLAN_ID IN
                                            (
                                            SELECT     
                                                MASTER_ALT_PLAN_ID
                                            FROM          
                                                EZGI_MASTER_ALT_PLAN
                                            WHERE      
                                                MASTER_ALT_PLAN_ID = #i#
                                            )
            </cfquery>
            <cfif len(get_min_start_date_alt_plan_1.O_START_DATE) and len(get_max_finish_date_alt_plan_1.O_FINISH_DATE)>
                <cfquery name="upd_alt_plan_date_1" datasource="#dsn3#">
                    UPDATE    
                        EZGI_MASTER_ALT_PLAN
                    SET              
                        PLAN_START_DATE = #CreateODBCDateTime(get_min_start_date_alt_plan_1.O_START_DATE)#, 
                        PLAN_FINISH_DATE = #CreateODBCDateTime(get_max_finish_date_alt_plan_1.O_FINISH_DATE)#
                    WHERE     
                        MASTER_ALT_PLAN_ID = #i#
                </cfquery>
            </cfif>
        </cfloop>
 	<cfelseif get_timing_type.timing_type eq 1 or get_timing_type.timing_type eq 3> <!---Alt Plan Başlama Başlama Tarihine Bağlı Kalarak İlişkili Alt Emirleri Sürelerini Planlama--->
		<cfquery name="get_all_sub_plan" datasource="#dsn3#">
        	SELECT     
            	EMAP.MASTER_ALT_PLAN_ID,
                EMPS.SIRA
			FROM         
            	EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
              	EZGI_MASTER_PLAN_SABLON AS EMPS ON EMAP.PROCESS_ID = EMPS.PROCESS_ID
			WHERE     
            	(EMAP.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id# OR EMAP.RELATED_MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#)
			ORDER BY 
            	EMPS.SIRA
        </cfquery> 
        <cfset master_alt_plan_id_list = ValueList(get_all_sub_plan.MASTER_ALT_PLAN_ID)>
        <!---<cfdump var="#get_all_sub_plan#">--->
        <cfloop query="get_all_sub_plan">
        	<cfif SIRA neq 1>
				<cfquery name="get_up_datetime" datasource="#dsn3#">
					SELECT     
						EMPS.UP_WORKSTATION_TIME, 
						EMPS.UP_WORKSTATION_ID, 
						TBL1.PLAN_START_DATE,
                        ISNULL((SELECT STD_START_HOUR FROM #dsn_alias#.SETUP_SHIFTS WHERE SHIFT_ID = EMPS.SHIFT_ID),0) AS STD_START
					FROM         
						EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
						EZGI_MASTER_PLAN_SABLON AS EMPS ON EMAP.PROCESS_ID = EMPS.PROCESS_ID INNER JOIN
						(
							SELECT     
								EMPS1.WORKSTATION_ID, 
								EMAP1.PLAN_START_DATE
							FROM          
								EZGI_MASTER_ALT_PLAN AS EMAP1 INNER JOIN
								EZGI_MASTER_PLAN_SABLON AS EMPS1 ON EMAP1.PROCESS_ID = EMPS1.PROCESS_ID
							WHERE      
								EMAP1.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id# OR EMAP1.RELATED_MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
						) AS TBL1 ON EMPS.UP_WORKSTATION_ID = TBL1.WORKSTATION_ID
					WHERE     
						EMAP.MASTER_ALT_PLAN_ID = #get_all_sub_plan.MASTER_ALT_PLAN_ID#
				</cfquery>
                <!---<cfdump var="#get_up_datetime#">--->
				<cfif get_up_datetime.UP_WORKSTATION_TIME eq '' or not get_up_datetime.recordcount>
					<script type="text/javascript">
						alert("<cf_get_lang dictionary_id='1083.Üst İstasyon İlişki ve Zamanları Girilmemiş'>");
						history.back();	
					</script>
				</cfif>
            <cfelse> 
            	<cfquery name="get_up_datetime" datasource="#dsn3#">   
                	SELECT     
                    	MASTER_ALT_PLAN_ID, 
                        PLAN_START_DATE, 
                        0 AS UP_WORKSTATION_TIME
					FROM         
                    	EZGI_MASTER_ALT_PLAN AS EMAP
					WHERE     
                    	MASTER_ALT_PLAN_ID = #get_all_sub_plan.MASTER_ALT_PLAN_ID#
				</cfquery>
           	</cfif>
            <cfset d_date1 = '#Dateformat(get_up_datetime.PLAN_START_DATE,'yyyy-mm-dd')# 00:00:00.0'>
            <cfset startdate_ = dateadd('n','00',d_date1)>
            <cfset startdate_ = dateadd('h','08',startdate_)>
            <cfset finishdate_ = dateadd('n','00',d_date1)>
            <cfset finishdate_ = dateadd('h','18',finishdate_)>
            <cfif get_up_datetime.UP_WORKSTATION_TIME gt 0>
                <cfloop from="1" to="#get_up_datetime.UP_WORKSTATION_TIME#" index="a">
                    <cfset startdate_ = dateadd('d','-1',startdate_)>
                    <cfset finishdate_ = dateadd('d','-1',finishdate_)>
                    <!---Pazar Günü Kontrolü--->
                    <cfif #DayOfWeek(startdate_)# eq 1>
                        <cfset startdate_ = dateadd('d','-1',startdate_)>
                        <cfset finishdate_  = dateadd('d','-1',finishdate_ )>
                    </cfif>
                    <!---Cumartesi Günü Kontrolü--->
					<cfif #DayOfWeek(startdate_)# eq 7>
                    	<cfif get_up_datetime.STD_START eq 0><!---Cumartesi Çalışılmıyorsa--->
							<cfset startdate_ = dateadd('d','-1',startdate_)>
                            <cfset finishdate_  = dateadd('d','-1',finishdate_ )>
                        </cfif>
                 	</cfif>
                </cfloop> 
         	</cfif>
            <cfquery name="upd_alt_plan_date" datasource="#dsn3#">
                UPDATE    
                    EZGI_MASTER_ALT_PLAN
                SET              
                    PLAN_START_DATE = #startdate_#, 
                    PLAN_FINISH_DATE = #finishdate_#
                WHERE     
                    MASTER_ALT_PLAN_ID = #get_all_sub_plan.MASTER_ALT_PLAN_ID#
            </cfquery>
           	<cfquery name="upd_p_order_date" datasource="#dsn3#">
            	UPDATE    
                	PRODUCTION_ORDERS
				SET              
                	START_DATE = EMAP1.PLAN_START_DATE, 
                    FINISH_DATE = EMAP1.PLAN_FINISH_DATE
				FROM         
                	EZGI_MASTER_ALT_PLAN AS EMAP1 INNER JOIN
                	EZGI_MASTER_PLAN_RELATIONS AS EMPR ON EMAP1.MASTER_ALT_PLAN_ID = EMPR.MASTER_ALT_PLAN_ID INNER JOIN
                	PRODUCTION_ORDERS ON EMPR.P_ORDER_ID = PRODUCTION_ORDERS.P_ORDER_ID
				WHERE     
                	EMAP1.MASTER_ALT_PLAN_ID = #get_all_sub_plan.MASTER_ALT_PLAN_ID# OR EMAP1.RELATED_MASTER_ALT_PLAN_ID = #get_all_sub_plan.MASTER_ALT_PLAN_ID#
            </cfquery> 
            <cfquery name="upd_operation_date" datasource="#dsn3#">
            	UPDATE    
                	PRODUCTION_OPERATION
				SET              
                	O_START_DATE = EMAP1.PLAN_START_DATE, 
                    O_STATION_IP = PO.STATION_ID, 
                    O_TOTAL_PROCESS_TIME = 500
				FROM         
                	EZGI_MASTER_ALT_PLAN AS EMAP1 INNER JOIN
                	EZGI_MASTER_PLAN_RELATIONS AS EMPR ON EMAP1.MASTER_ALT_PLAN_ID = EMPR.MASTER_ALT_PLAN_ID INNER JOIN
                	PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                	PRODUCTION_OPERATION ON PO.P_ORDER_ID = PRODUCTION_OPERATION.P_ORDER_ID
				WHERE     
                	EMAP1.MASTER_ALT_PLAN_ID = #get_all_sub_plan.MASTER_ALT_PLAN_ID# OR EMAP1.RELATED_MASTER_ALT_PLAN_ID = #get_all_sub_plan.MASTER_ALT_PLAN_ID#
            </cfquery>   
        </cfloop>
        <cfif get_timing_type.timing_type eq 3>
        	<cfif Listlen(master_alt_plan_id_list)>
            	<cfquery name="get_colect_po" datasource="#dsn3#">
            		SELECT        
                    	POR.ORDER_ID, 
                        PO.LOT_NO, 
                        PO.P_ORDER_ID
					FROM            
                  		EZGI_MASTER_ALT_PLAN AS EMAP1 INNER JOIN
                     	EZGI_MASTER_PLAN_RELATIONS AS EMPR ON EMAP1.MASTER_ALT_PLAN_ID = EMPR.MASTER_ALT_PLAN_ID INNER JOIN
                    	PRODUCTION_ORDERS AS PO ON EMPR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                     	PRODUCTION_ORDERS_ROW AS POR ON PO.P_ORDER_ID = POR.PRODUCTION_ORDER_ID INNER JOIN
                     	ORDERS AS O ON POR.ORDER_ID = O.ORDER_ID
					WHERE        
                    	EMAP1.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id# OR
                       	EMAP1.RELATED_MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
					ORDER BY 
                    	POR.ORDER_ID
            	</cfquery>
                <cfif get_colect_po.recordcount>
					<cfquery name="get_colect_po_group" dbtype="query">
                    	SELECT ORDER_ID FROM get_colect_po GROUP BY ORDER_ID
                    </cfquery>
                    <cfloop query="get_colect_po_group">
                    	<cfquery name="get_po_id_list" dbtype="query">
                        	SELECT P_ORDER_ID FROM get_colect_po WHERE ORDER_ID=#get_colect_po_group.ORDER_ID#
                        </cfquery>
                        <cfset group_p_order_list = ValueList(get_po_id_list.P_ORDER_ID)>
                        <cfquery name="get_min_lot_no" dbtype="query">
                            SELECT
                                MIN(LOT_NO) AS LOT_NO
                           	FROM
                            	get_colect_po
                            WHERE
                              ORDER_ID=#get_colect_po_group.ORDER_ID#  
                        </cfquery>
                        <cfquery name="upd_collect_po_group" datasource="#dsn3#">
                        	UPDATE     
                            	PRODUCTION_ORDERS
							SET                
                            	LOT_NO = '#get_min_lot_no.LOT_NO#'
							WHERE        
                            	P_ORDER_ID IN (#group_p_order_list#)
                        </cfquery>
                    </cfloop>
                </cfif>
            </cfif>
        </cfif>
    </cfif>
</cftransaction>  
<cflocation url="#request.self#?fuseaction=prod.upd_ezgi_master_sub_plan_manual&master_plan_id=#master_plan_id#&master_alt_plan_id=#master_alt_plan_id#&islem_id=#islem_id#" addtoken="No">
