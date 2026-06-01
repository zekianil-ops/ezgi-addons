<!---
    File: hsp_ezgi_operation_time_cost.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/07/2022
    Description:
--->
<cfset time_cost_type = 1> <!---Zaman Harcaması Tipi 1-Operasyon Çalışma--->
<cfset overtime_type = 1> <!---Mesai Tipi = 1-Normal, 2-Fazla Mesai, 3-Hafta Sonu, 4-Resmi Tatil ---> 
<cfquery name="get_general_offtime_table" datasource="#dsn3#"> <!---Bu Sene olan Ulusal Tatil Günlerini Çeker--->
 	SELECT        
   		OFFTIME_NAME, 
        START_DATE, 
        FINISH_DATE, 
        IS_HALFOFFTIME
  	FROM            
      	#dsn_alias#.SETUP_GENERAL_OFFTIMES
   	WHERE   
    	YEAR(START_DATE) = #session.ep.period_year#
</cfquery>
<cfif not get_general_offtime_table.recordcount>
	<script type="text/javascript">
		alert("Genel Tatil Zamanları Girilmediğinden Zaman Harcaması Yapılamaz!");
	</script>
    <cfabort>
<cfelse>
    <cfquery name="get_shift_info" datasource="#dsn3#"> <!---Vardiya Bilgilerini Çeker--->
        SELECT * FROM #dsn_alias#.SETUP_SHIFTS WHERE SHIFT_ID = #attributes.shift_id#
    </cfquery>
</cfif>

<cfset breaking_blocks = queryNew("id, is_half_day, start_hour, start_minute, end_hour, end_minute","integer, integer, decimal, decimal, decimal, decimal") />
<cfset tatil_gun = 0>
<cfset test_gun_bitis = get_production_operations.TIME_COST_FINISH_DATE>
<cfset test_gun_basla = get_production_operations.TIME_COST_START_DATE>
<!---MESAI ARALIKLARI KONTROLÜ--->

<cfif len(get_shift_info.FREE_TIME_NAME_1) and len(test_gun_bitis)><!---1. Mesai Aralığı Adı Belirtilmişse--->
	<cfset braking_1 = DateDiff('n',DateAdd('n',get_shift_info.FREE_TIME_START_MIN_1,DateAdd('h',get_shift_info.FREE_TIME_START_HOUR_1, test_gun_bitis)),DateAdd('n',get_shift_info.FREE_TIME_END_MIN_1,DateAdd('h',get_shift_info.FREE_TIME_END_HOUR_1, test_gun_bitis)))> <!---1. Mesai Süreleri Arasında Anlamlı bir Fark Varsa--->
    <cfif braking_1 gt 0 and get_shift_info.IS_WEEKEND_1 eq 1>
        <cfset Temp = QueryAddRow(breaking_blocks)>
        <cfset Temp = QuerySetCell(breaking_blocks, "id", 1)>
        <cfset Temp = QuerySetCell(breaking_blocks, "start_hour", get_shift_info.FREE_TIME_START_HOUR_1)>
        <cfset Temp = QuerySetCell(breaking_blocks, "end_hour", get_shift_info.FREE_TIME_END_HOUR_1)>
        <cfset Temp = QuerySetCell(breaking_blocks, "start_minute", get_shift_info.FREE_TIME_START_MIN_1)>
        <cfset Temp = QuerySetCell(breaking_blocks, "end_minute", get_shift_info.FREE_TIME_END_MIN_1)>
        <cfif get_shift_info.IS_FISRT_ADD_TIME_1 eq 1>
        	<cfset Temp = QuerySetCell(breaking_blocks, "is_half_day", 1)>
      	<cfelse>
        	<cfset Temp = QuerySetCell(breaking_blocks, "is_half_day", 0)>
        </cfif>
    </cfif>
<cfelse>
	<cfset braking_1 = 0>
</cfif>

<cfif len(get_shift_info.FREE_TIME_NAME_2)><!---2. Mesai Aralığı Adı Belirtilmişse--->
	<cfset braking_2 = DateDiff('n',DateAdd('n',get_shift_info.FREE_TIME_START_MIN_2,DateAdd('h',get_shift_info.FREE_TIME_START_HOUR_2, test_gun_bitis)),DateAdd('n',get_shift_info.FREE_TIME_END_MIN_2,DateAdd('h',get_shift_info.FREE_TIME_END_HOUR_2, test_gun_bitis)))> <!---2. Mesai Süreleri Arasında Anlamlı bir Fark Varsa--->
    <cfif braking_2 gt 0 and get_shift_info.IS_WEEKEND_2 eq 1>
        <cfset Temp = QueryAddRow(breaking_blocks)>
        <cfset Temp = QuerySetCell(breaking_blocks, "id", 2)>
        <cfset Temp = QuerySetCell(breaking_blocks, "start_hour", get_shift_info.FREE_TIME_START_HOUR_2)>
        <cfset Temp = QuerySetCell(breaking_blocks, "end_hour", get_shift_info.FREE_TIME_END_HOUR_2)>
        <cfset Temp = QuerySetCell(breaking_blocks, "start_minute", get_shift_info.FREE_TIME_START_MIN_2)>
        <cfset Temp = QuerySetCell(breaking_blocks, "end_minute", get_shift_info.FREE_TIME_END_MIN_2)>
        <cfif get_shift_info.IS_FISRT_ADD_TIME_2 eq 1>
        	<cfset Temp = QuerySetCell(breaking_blocks, "is_half_day", 1)>
      	<cfelse>
        	<cfset Temp = QuerySetCell(breaking_blocks, "is_half_day", 0)>
        </cfif>
    </cfif>
<cfelse>
	<cfset braking_2 = 0>
</cfif>

<cfif len(get_shift_info.FREE_TIME_NAME_3)><!---3. Mesai Aralığı Adı Belirtilmişse--->
	<cfset braking_3 = DateDiff('n',DateAdd('n',get_shift_info.FREE_TIME_START_MIN_3,DateAdd('h',get_shift_info.FREE_TIME_START_HOUR_3, test_gun_bitis)),DateAdd('n',get_shift_info.FREE_TIME_END_MIN_3,DateAdd('h',get_shift_info.FREE_TIME_END_HOUR_3, test_gun_bitis)))> <!---3. Mesai Süreleri Arasında Anlamlı bir Fark Varsa--->
    <cfif braking_3 gt 0 and get_shift_info.IS_WEEKEND_3 eq 1>
        <cfset Temp = QueryAddRow(breaking_blocks)>
        <cfset Temp = QuerySetCell(breaking_blocks, "id", 3)>
        <cfset Temp = QuerySetCell(breaking_blocks, "start_hour", get_shift_info.FREE_TIME_START_HOUR_3)>
        <cfset Temp = QuerySetCell(breaking_blocks, "end_hour", get_shift_info.FREE_TIME_END_HOUR_3)>
        <cfset Temp = QuerySetCell(breaking_blocks, "start_minute", get_shift_info.FREE_TIME_START_MIN_3)>
        <cfset Temp = QuerySetCell(breaking_blocks, "end_minute", get_shift_info.FREE_TIME_END_MIN_3)>
        <cfif get_shift_info.IS_FISRT_ADD_TIME_3 eq 1>
        	<cfset Temp = QuerySetCell(breaking_blocks, "is_half_day", 1)>
      	<cfelse>
        	<cfset Temp = QuerySetCell(breaking_blocks, "is_half_day", 0)>
        </cfif>
    </cfif>
<cfelse>
	<cfset braking_3 = 0>
</cfif>

<cfif len(get_shift_info.FREE_TIME_NAME_4)><!---4. Mesai Aralığı Adı Belirtilmişse--->
	<cfset braking_4 = DateDiff('n',DateAdd('n',get_shift_info.FREE_TIME_START_MIN_4,DateAdd('h',get_shift_info.FREE_TIME_START_HOUR_4, test_gun_bitis)),DateAdd('n',get_shift_info.FREE_TIME_END_MIN_4,DateAdd('h',get_shift_info.FREE_TIME_END_HOUR_4, test_gun_bitis)))> <!---4. Mesai Süreleri Arasında Anlamlı bir Fark Varsa--->
    <cfif braking_4 gt 0 and get_shift_info.IS_WEEKEND_4 eq 1>
        <cfset Temp = QueryAddRow(breaking_blocks)>
        <cfset Temp = QuerySetCell(breaking_blocks, "id", 4)>
        <cfset Temp = QuerySetCell(breaking_blocks, "start_hour", get_shift_info.FREE_TIME_START_HOUR_4)>
        <cfset Temp = QuerySetCell(breaking_blocks, "end_hour", get_shift_info.FREE_TIME_END_HOUR_4)>
        <cfset Temp = QuerySetCell(breaking_blocks, "start_minute", get_shift_info.FREE_TIME_START_MIN_4)>
        <cfset Temp = QuerySetCell(breaking_blocks, "end_minute", get_shift_info.FREE_TIME_END_MIN_4)>
        <cfif get_shift_info.IS_FISRT_ADD_TIME_4 eq 1>
        	<cfset Temp = QuerySetCell(breaking_blocks, "is_half_day", 1)>
      	<cfelse>
        	<cfset Temp = QuerySetCell(breaking_blocks, "is_half_day", 0)>
        </cfif>
    </cfif>
<cfelse>
	<cfset braking_4 = 0>
</cfif>

<cfif len(get_shift_info.FREE_TIME_NAME_5)><!---5. Mesai Aralığı Adı Belirtilmişse--->
	<cfset braking_5 = DateDiff('n',DateAdd('n',get_shift_info.FREE_TIME_START_MIN_5,DateAdd('h',get_shift_info.FREE_TIME_START_HOUR_5, test_gun_bitis)),DateAdd('n',get_shift_info.FREE_TIME_END_MIN_5,DateAdd('h',get_shift_info.FREE_TIME_END_HOUR_5, test_gun_bitis)))> <!---5. Mesai Süreleri Arasında Anlamlı bir Fark Varsa--->
    <cfif braking_5 gt 0 and get_shift_info.IS_WEEKEND_5 eq 1>
        <cfset Temp = QueryAddRow(breaking_blocks)>
        <cfset Temp = QuerySetCell(breaking_blocks, "id", 5)>
        <cfset Temp = QuerySetCell(breaking_blocks, "start_hour", get_shift_info.FREE_TIME_START_HOUR_5)>
        <cfset Temp = QuerySetCell(breaking_blocks, "end_hour", get_shift_info.FREE_TIME_END_HOUR_5)>
        <cfset Temp = QuerySetCell(breaking_blocks, "start_minute", get_shift_info.FREE_TIME_START_MIN_5)>
        <cfset Temp = QuerySetCell(breaking_blocks, "end_minute", get_shift_info.FREE_TIME_END_MIN_5)>
        <cfif get_shift_info.IS_FISRT_ADD_TIME_5 eq 1>
        	<cfset Temp = QuerySetCell(breaking_blocks, "is_half_day", 1)>
      	<cfelse>
        	<cfset Temp = QuerySetCell(breaking_blocks, "is_half_day", 0)>
        </cfif>
    </cfif>
<cfelse>
	<cfset braking_5 = 0>
</cfif>

<!---<cfif isdefined('breaking_blocks') and breaking_blocks.recordcount> <!---Mesai Aralığı Girilmişse Mesai Aralığı Doğruluk Kontrolü--->
	<cfquery name="breaking_blocks_sort" dbtype="query">
    	SELECT * FROM breaking_blocks ORDER BY start_hour, start_minute
    </cfquery>
    <cfset breaking_blocks_sort_count = breaking_blocks_sort.recordcount>
    <cfoutput query="breaking_blocks_sort">
    	<cfset start_time = '#breaking_blocks_sort.start_hour##breaking_blocks_sort.start_minute#'>
    	<cfset end_time = '#breaking_blocks_sort.end_hour##breaking_blocks_sort.end_minute#'> 
        <cfif isdefined('old_time')>
        	<cfif old_time gte start_time> <!---Bir Önceki Satırdaki Mesai Bitişi ile Bu Satırın Mesai Başlangıcı Arasında Kontrol Yapılıyor--->
                #id#. Satırda Girilen Mesai Duraklama Başlangıç Saati ile Bir Önceki Satır daki Bitiş Saati Arasında Uyumsuzluk Var. Öncelikle Düzeltiniz.
				<cfabort>
            </cfif>
        </cfif>
        <cfif end_time lte start_time> <!---Aynı Satırdaki Mesai Başlangıç ve Bitiş Arası Kontrol--->
            #id#. Satırda Girilen Mesai Duraklama Başlangıç Saati ile Bitiş Saati Arasında Uyumsuzluk Var. Öncelikle Düzeltiniz.
			<cfabort>
        <cfelse>
        	<cfif breaking_blocks_sort_count gt 1>
            	<cfset old_time = start_time>
            </cfif>
        </cfif>
    </cfoutput>
</cfif>--->

<cfif breaking_blocks.recordcount> <!---Mesai Aralığı Girilmişse Mesai Aralığı Doğruluk Kontrolü--->
	<cfquery name="breaking_blocks_sort" dbtype="query">
    	SELECT * FROM breaking_blocks ORDER BY start_hour, start_minute
    </cfquery>

    <cfset breaking_blocks_sort_count = breaking_blocks_sort.recordcount>
    <cfoutput query="breaking_blocks_sort">
    	<cfif len(breaking_blocks_sort.start_hour) eq 1>
        	<cfset start_hour_ = '0#breaking_blocks_sort.start_hour#'>
       	<cfelse>
        	<cfset start_hour_ = '#breaking_blocks_sort.start_hour#'>
        </cfif>
        <cfif len(breaking_blocks_sort.start_minute) eq 1>
        	<cfset start_minute_ = '0#breaking_blocks_sort.start_minute#'>
       	<cfelse>
        	<cfset start_minute_ = '#breaking_blocks_sort.start_minute#'>
        </cfif>
        <cfif len(breaking_blocks_sort.end_hour) eq 1>
        	<cfset end_hour_ = '0#breaking_blocks_sort.end_hour#'>
       	<cfelse>
        	<cfset end_hour_ = '#breaking_blocks_sort.end_hour#'>
        </cfif>
        <cfif len(breaking_blocks_sort.end_minute) eq 1>
        	<cfset end_minute_ = '0#breaking_blocks_sort.end_minute#'>
       	<cfelse>
        	<cfset end_minute_ = '#breaking_blocks_sort.end_minute#'>
        </cfif>
    	<cfset start_time = '#start_hour_##start_minute_#'>
    	<cfset end_time = '#end_hour_##end_minute_#'> 
        <cfif isdefined('old_time')>
        	<cfif old_time gte start_time> <!---Farklı Satırdaki Mesai Bitiş ve Başlangıç Arası Kontrol--->
                #id#. Satırda Girilen Mesai Duraklama Başlangıç Saati ile Önceki Satır daki Bitiş Saati Arasında Uyumsuzluk Var. Öncelikle Düzeltiniz.
				<cfabort>
            </cfif>
        </cfif>
        
        <cfif end_time lte start_time> <!---Aynı Satırdaki Mesai Başlangıç ve Bitiş Arası Kontrol--->
            #id#. Satırda Girilen Mesai Duraklama Başlangıç Saati ile Bitiş Saati Arasında Uyumsuzluk Var. Öncelikle Düzeltiniz.
			<cfabort>
        <cfelse>
        	<cfif breaking_blocks_sort_count gt 1>
            	<cfset old_time = end_time>
            </cfif>
        </cfif>
    </cfoutput>
</cfif>
<!---TEST BAŞLIYOR--->

<cfset cmrt_gun_basla_minute = (get_shift_info.STD_START_HOUR*60)+get_shift_info.STD_START_MIN>
<cfset cmrt_gun_bitis_minute = (get_shift_info.STD_END_HOUR*60)+get_shift_info.STD_END_MIN>
<cfset stnd_gun_basla_minute = (get_shift_info.START_HOUR*60)+get_shift_info.START_MIN>
<cfset stnd_gun_bitis_minute = (get_shift_info.END_HOUR*60)+get_shift_info.END_MIN>

<cfloop query="get_production_operations">
	<cfset sira_no = currentrow>
	<cfset test_gun_bitis = get_production_operations.TIME_COST_FINISH_DATE>
    <cfset test_gun_basla = get_production_operations.TIME_COST_START_DATE>
    <cfset test_gun_bitis_overtime_type = 1>
    <cfquery name="get_general_offtime" dbtype="query">
        SELECT        
            OFFTIME_NAME, 
            START_DATE, 
            FINISH_DATE, 
            IS_HALFOFFTIME
        FROM            
            get_general_offtime_table
        WHERE   
            START_DATE >= '#DateFormat(test_gun_bitis,dateformat_style)#' AND
            FINISH_DATE <= '#DateFormat(test_gun_bitis,dateformat_style)#'
    </cfquery>
    <cfif get_general_offtime.recordcount><!---Resmi Tatil Günü Testi--->
        <cfif get_general_offtime.IS_HALFOFFTIME eq 1>
            <cfset tatil = 1> <!---Yarım Gün Tatil--->
        <cfelse>
            <cfset tatil = 2> <!---Tam Gün Tatil--->
        </cfif>
     <cfelse>
        <cfset tatil = 0> <!--- Tatil Değil --->   
    </cfif>
    
    <cfif tatil gt 0>
        <cfset test_gun_bitis_overtime_type = 4> <!---Genel Tatil--->
    <cfelse>
        <!---Hafta Tatili Testi--->
        <cfset test_gun_basla_minute = (hour(test_gun_basla)*60)+minute(test_gun_basla)>
        <cfset test_gun_bitis_minute = (hour(test_gun_bitis)*60)+minute(test_gun_bitis)>
        <cfif dayOfWeek(test_gun_bitis) eq get_shift_info.WEEK_OFFDAY> <!---Pazar Günü ise Zaten Tatil--->
            <cfset test_gun_bitis_overtime_type = 3>
        <cfelseif dayOfWeek(test_gun_bitis) eq 7 and get_shift_info.STD_START_HOUR eq 0> <!---Cumartesi de Hafta Tatili ise--->
            <cfset test_gun_bitis_overtime_type = 3>
        <cfelse> <!---Normal Gün ise--->
            <!---Fazla Mesai Var mı--->
            <cfif dayOfWeek(test_gun_bitis) eq 7><!--- Cumartesi Günü Fazla Mesai Kontrolü---> <!---Bu Bloğa Girdi İse Cumartesi de Mesai Günüdür--->
                <cfif dayOfYear(test_gun_basla) eq dayOfYear(test_gun_bitis)> <!---Başlangıç ve Bitiş Aynı Gün Olmalı--->
                    <cfif test_gun_basla_minute lt cmrt_gun_bitis_minute> <!---Çalışma Başlangıcı Mesai Bitiş Saatinden Önce ise--->
                        <cfif test_gun_bitis_minute gt cmrt_gun_bitis_minute> <!---Çalışma Bitişi Mesai Bitiş Saatinden Önce ise---> <!---Fazla Mesai Vardır ve Çalışma Bölünmelidir--->
                            <cfset fark_hesapla = cmrt_gun_bitis_minute-test_gun_bitis_minute> <!---Mesai Bitişinden Sonraki Zaman Hesaplanıyor--->
                            <cfset test_gun_bitis_overtime_type = 1> <!---Normal--->
                        </cfif>
                    <cfelse> <!---Çalışma Başlangıcı Mesai Bitiş Saatinden Sonra ise Tüm Çalışma Fazla Mesaidir---> 
                        <cfset test_gun_bitis_overtime_type = 2> <!---Fazla Mesai--->
                    </cfif>
                </cfif>
            <cfelse> <!---Hafta İçi Fazla Mesai Kontrolü--->
            	<cfif dayOfYear(test_gun_basla) eq dayOfYear(test_gun_bitis)> <!---Başlangıç ve Bitiş Aynı Gün Olmalı--->
                    <cfif test_gun_basla_minute lt stnd_gun_bitis_minute> <!---Çalışma Başlangıcı Mesai Bitiş Saatinden Önce ise--->
                        <cfif test_gun_bitis_minute gt stnd_gun_bitis_minute> <!---Çalışma Bitişi Mesai Bitiş Saatinden Önce ise---> <!---Fazla Mesai Vardır ve Çalışma Bölünmelidir--->
                            
							<cfset fark_hesapla = stnd_gun_bitis_minute-test_gun_bitis_minute> <!---Mesai Bitişinden Sonraki Zaman Hesaplanıyor--->
                            <cfset test_gun_bitis_overtime_type = 1> <!---Normal--->
                            
                            <cfset hesapli_fark = TIME_COST_MINUTE+(fark_hesapla*60)>
                            <cfset bitis_tarih = TIME_COST_FINISH_DATE>
                            <!---Sub Query kayıtları Düzenleniyor--->
                            <cfset Temp = QuerySetCell(get_production_operations, "TIME_COST_FINISH_DATE", DateAdd('n',fark_hesapla,TIME_COST_FINISH_DATE), sira_no)>
                            <cfset Temp = QuerySetCell(get_production_operations, "TIME_COST_MINUTE", hesapli_fark, sira_no)>
                            <cfset Temp = QuerySetCell(get_production_operations, "REAL_AMOUNT", REAL_AMOUNT/2, sira_no)> <!---Miktar Fazla Mesa için 2 ye Bölünüyor--->
                            <!---Sub Query kayıtları Düzenleniyor--->
                            
                            <!---Sub Query kayıtlarına Mesai Kaydı Ekleniyor--->
                            <cfset Temp = QueryAddRow(get_production_operations)>
                            <cfset Temp = QuerySetCell(get_production_operations, "OVERTIME_TYPE", 2)>
                            <cfset Temp = QuerySetCell(get_production_operations, "AMOUNT", AMOUNT)>
                            <cfset Temp = QuerySetCell(get_production_operations, "COMMENT2", COMMENT2)>
                            <cfset Temp = QuerySetCell(get_production_operations, "EMPLOYEE_ID", EMPLOYEE_ID)>
                            <cfset Temp = QuerySetCell(get_production_operations, "IS_PROTOTYPE", IS_PROTOTYPE)>
                            <cfset Temp = QuerySetCell(get_production_operations, "IS_STAGE", IS_STAGE)>
                            <cfset Temp = QuerySetCell(get_production_operations, "LOT_NO", LOT_NO)>
                            <cfset Temp = QuerySetCell(get_production_operations, "NAME_PRODUCT", NAME_PRODUCT)>
                            <cfset Temp = QuerySetCell(get_production_operations, "OPERATION_CODE", OPERATION_CODE)>
                            <cfset Temp = QuerySetCell(get_production_operations, "OPERATION_RESULT_ID", OPERATION_RESULT_ID)>
                            <cfset Temp = QuerySetCell(get_production_operations, "OPERATION_TYPE", OPERATION_TYPE)>
                            <cfset Temp = QuerySetCell(get_production_operations, "OPERATION_TYPE_ID", OPERATION_TYPE_ID)>
                            <cfset Temp = QuerySetCell(get_production_operations, "PRODUCT_ID", PRODUCT_ID)>
                            <cfset Temp = QuerySetCell(get_production_operations, "PRODUCT_NAME", PRODUCT_NAME)>
                            <cfset Temp = QuerySetCell(get_production_operations, "PROJECT_HEAD", PROJECT_HEAD)>
                            <cfset Temp = QuerySetCell(get_production_operations, "PROJECT_ID", PROJECT_ID)>
                            <cfset Temp = QuerySetCell(get_production_operations, "PROJECT_NUMBER", PROJECT_NUMBER)>
                            <cfset Temp = QuerySetCell(get_production_operations, "P_OPERATION_ID", P_OPERATION_ID)>
                            <cfset Temp = QuerySetCell(get_production_operations, "P_ORDER_ID", P_ORDER_ID)>
                            <cfset Temp = QuerySetCell(get_production_operations, "P_ORDER_NO", P_ORDER_NO)>
                            <cfset Temp = QuerySetCell(get_production_operations, "QUANTITY", QUANTITY)>
                            <cfset Temp = QuerySetCell(get_production_operations, "REAL_AMOUNT", REAL_AMOUNT)>
                            <cfset Temp = QuerySetCell(get_production_operations, "TIME_COST_MINUTE", -1*fark_hesapla*60)>
                            <cfset Temp = QuerySetCell(get_production_operations, "RECORD_DATE", RECORD_DATE)>
                            <cfset Temp = QuerySetCell(get_production_operations, "SPECT_VAR_NAME", SPECT_VAR_NAME)>
                            <cfset Temp = QuerySetCell(get_production_operations, "SPEC_MAIN_ID", SPEC_MAIN_ID)>
                            <cfset Temp = QuerySetCell(get_production_operations, "STAGE", STAGE)>
                            <cfset Temp = QuerySetCell(get_production_operations, "STATION_ID", STATION_ID)>
                            <cfset Temp = QuerySetCell(get_production_operations, "STATION_NAME", STATION_NAME)>
                            <cfset Temp = QuerySetCell(get_production_operations, "STOCK_CODE", STOCK_CODE)>
                            <cfset Temp = QuerySetCell(get_production_operations, "STOCK_ID", STOCK_ID)>
                            <cfset Temp = QuerySetCell(get_production_operations, "TIME_COST_FINISH_DATE", bitis_tarih)>
                            <cfset Temp = QuerySetCell(get_production_operations, "TIME_COST_ID", TIME_COST_ID)>
                            <cfset Temp = QuerySetCell(get_production_operations, "TIME_COST_START_DATE", TIME_COST_FINISH_DATE)>
                            <cfset Temp = QuerySetCell(get_production_operations, "TIME_COST_TYPE", 0)>
                            <cfset Temp = QuerySetCell(get_production_operations, "UPDATE_DATE", UPDATE_DATE)>
                            <cfset Temp = QuerySetCell(get_production_operations, "WAIT_TIME", WAIT_TIME)>
                            <cfset Temp = QuerySetCell(get_production_operations, "WORK_CONNECT_CODE", WORK_CONNECT_CODE)>
                            <cfset Temp = QuerySetCell(get_production_operations, "WORK_HEAD", WORK_HEAD)>
                            <cfset Temp = QuerySetCell(get_production_operations, "EZGI_OPERATION_TIME_COST_ID", 0)>
                            <!---Sub Query kayıtlarına Mesai Kaydı Ekleniyor--->
                            
                        </cfif>
                    <cfelse> <!---Çalışma Başlangıcı Mesai Bitiş Saatinden Sonra ise Tüm Çalışma Fazla Mesaidir---> 
                        <cfset test_gun_bitis_overtime_type = 2> <!---Fazla Mesai--->
                    </cfif>
                </cfif>
            </cfif>
        </cfif>
    </cfif>
    <cfset Temp = QuerySetCell(get_production_operations, "OVERTIME_TYPE", test_gun_bitis_overtime_type, sira_no)>
</cfloop>
