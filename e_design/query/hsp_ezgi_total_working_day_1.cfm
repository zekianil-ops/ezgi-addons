<!---
    File: hsp_ezgi_total_working_day_1.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfquery name="get_general_offtime_table" datasource="#dsn3#"> <!---Ulusal Tatil Günlerini Çeker--->
 	SELECT        
   		OFFTIME_NAME, START_DATE, FINISH_DATE, IS_HALFOFFTIME
  	FROM            
      	#dsn_alias#.SETUP_GENERAL_OFFTIMES WITH (NOLOCK)
   	WHERE   
    	YEAR(START_DATE) = #session.ep.period_year# OR YEAR(START_DATE) = #session.ep.period_year#+1
</cfquery>
<cfquery name="get_shift_info" datasource="#dsn3#"> <!---Vardiya Bilgilerini Çeker--->
	SELECT        
    	START_HOUR, 
        END_HOUR, 
        START_MIN, 
        END_MIN, 
        STD_START_HOUR, 
        STD_START_MIN, 
        STD_END_HOUR, 
        STD_END_MIN, 
        FREE_TIME_NAME_1, 
        FREE_TIME_NAME_2, 
        FREE_TIME_NAME_3, 
       	FREE_TIME_NAME_4, 
        FREE_TIME_NAME_5, 
        IS_WEEKEND_1, 
        IS_WEEKEND_2, 
        IS_WEEKEND_3, 
        IS_WEEKEND_4, 
        IS_WEEKEND_5, 
        WEEK_OFFDAY, 
        CONTROL_HOUR_1, 
        FREE_TIME_START_HOUR_1, 
        FREE_TIME_START_MIN_1, 
        FREE_TIME_END_HOUR_1, 
        FREE_TIME_END_MIN_1, 
        FREE_TIME_START_HOUR_2, 
        FREE_TIME_START_MIN_2, 
      	FREE_TIME_END_HOUR_2, 
        FREE_TIME_END_MIN_2, 
        FREE_TIME_START_HOUR_3, 
        FREE_TIME_START_MIN_3, 
        FREE_TIME_END_HOUR_3, 
        FREE_TIME_END_MIN_3, 
        FREE_TIME_START_HOUR_4, 
     	FREE_TIME_START_MIN_4, 
        FREE_TIME_END_HOUR_4, 
        FREE_TIME_END_MIN_4, 
        FREE_TIME_START_HOUR_5, 
        FREE_TIME_START_MIN_5, 
        FREE_TIME_END_HOUR_5, 
        FREE_TIME_END_MIN_5,
        IS_FISRT_ADD_TIME_1, 
        IS_FISRT_ADD_TIME_2, 
        IS_FISRT_ADD_TIME_3, 
        IS_FISRT_ADD_TIME_4, 
        IS_FISRT_ADD_TIME_5
	FROM            
    	#dsn_alias#.SETUP_SHIFTS WITH (NOLOCK)
	WHERE        
    	SHIFT_ID = #attributes.shift_id#
</cfquery>
<cfset breaking_blocks = queryNew("id, is_half_day, start_hour, start_minute, end_hour, end_minute","integer, integer, decimal, decimal, decimal, decimal") />
<cfset tatil_gun = 0>
<cfif len(get_shift_info.FREE_TIME_NAME_1)><!---1. Mesai Aralığı Adı Belirtilmişse--->
	<cfset braking_1 = DateDiff('n',DateAdd('n',get_shift_info.FREE_TIME_START_MIN_1,DateAdd('h',get_shift_info.FREE_TIME_START_HOUR_1, test_gun)),DateAdd('n',get_shift_info.FREE_TIME_END_MIN_1,DateAdd('h',get_shift_info.FREE_TIME_END_HOUR_1, test_gun)))> <!---1. Mesai Süreleri Arasında Anlamlı bir Fark Varsa--->
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
	<cfset braking_2 = DateDiff('n',DateAdd('n',get_shift_info.FREE_TIME_START_MIN_2,DateAdd('h',get_shift_info.FREE_TIME_START_HOUR_2, test_gun)),DateAdd('n',get_shift_info.FREE_TIME_END_MIN_2,DateAdd('h',get_shift_info.FREE_TIME_END_HOUR_2, test_gun)))> <!---2. Mesai Süreleri Arasında Anlamlı bir Fark Varsa--->
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
	<cfset braking_3 = DateDiff('n',DateAdd('n',get_shift_info.FREE_TIME_START_MIN_3,DateAdd('h',get_shift_info.FREE_TIME_START_HOUR_3, test_gun)),DateAdd('n',get_shift_info.FREE_TIME_END_MIN_3,DateAdd('h',get_shift_info.FREE_TIME_END_HOUR_3, test_gun)))> <!---3. Mesai Süreleri Arasında Anlamlı bir Fark Varsa--->
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
	<cfset braking_4 = DateDiff('n',DateAdd('n',get_shift_info.FREE_TIME_START_MIN_4,DateAdd('h',get_shift_info.FREE_TIME_START_HOUR_4, test_gun)),DateAdd('n',get_shift_info.FREE_TIME_END_MIN_4,DateAdd('h',get_shift_info.FREE_TIME_END_HOUR_4, test_gun)))> <!---4. Mesai Süreleri Arasında Anlamlı bir Fark Varsa--->
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
	<cfset braking_5 = DateDiff('n',DateAdd('n',get_shift_info.FREE_TIME_START_MIN_5,DateAdd('h',get_shift_info.FREE_TIME_START_HOUR_5, test_gun)),DateAdd('n',get_shift_info.FREE_TIME_END_MIN_5,DateAdd('h',get_shift_info.FREE_TIME_END_HOUR_5, test_gun)))> <!---5. Mesai Süreleri Arasında Anlamlı bir Fark Varsa--->
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
        <!---<cfif isdefined('old_time')>
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
        </cfif>--->
    </cfoutput>
</cfif>

<cfset working_blocks = queryNew("id, start_date, end_date, amount","integer, date, date, decimal") /> <!---Çalışma Aralıkları Tablosu Açılışı--->
<cfloop from="1" to="#toplam_gun#" index="i"> <!---Yıl İçindeki Tüm Günler için döner--->
    <cfif dayOfWeek(test_gun) eq get_shift_info.WEEK_OFFDAY> <!---Hafta Tatili Pazar Günü ise--->
    	<cfset tatil_gun = tatil_gun + 1>
 	<cfelseif dayOfWeek(test_gun) eq 7 and get_shift_info.WEEK_OFFDAY neq 7> <!---Hafta Sonu Cumartesi İse ve Hafta Tatili Cumartesi Değil ise--->
    	<cfset main_working_start = DateAdd('n',get_shift_info.STD_START_MIN,DateAdd('h',get_shift_info.STD_START_HOUR, test_gun))> <!---Cumartesi Mesai Başlama Tarih ve Saati--->
     	<cfset main_working_end = DateAdd('n',get_shift_info.STD_END_MIN,DateAdd('h',get_shift_info.STD_END_HOUR, test_gun))> <!---Cumartesi Mesai Bitiş Tarih ve Saati--->
    	<cfif DateDiff('n',DateAdd('n',get_shift_info.STD_START_MIN,DateAdd('h',get_shift_info.STD_START_HOUR, test_gun)),DateAdd('n',get_shift_info.STD_END_MIN,DateAdd('h',get_shift_info.STD_END_HOUR, test_gun))) gt 0> <!---Eğer Hafta Sonu Çalışma Varsa--->
        	<cfinclude template="hsp_ezgi_total_working_day_sub.cfm"> <!---Ulusal Tatil mi--->
        	<cfif tatil  eq 1> <!---Yarım Gün Ulusal Tatil--->
             	<cfset tatil_gun = tatil_gun + 0.5>
              	<!---Dikkat Yarım Gün Tatil Günlerinde, Mesai Çalışma Başlangıç ile Öğle Yemeği Arası Tasarlanmıştır--->
           		<cfif isdefined('breaking_blocks_sort') and breaking_blocks_sort.recordcount>
            		<cfloop query="breaking_blocks_sort">
                    	<cfif currentrow eq 1> <!---ilk turda ise--->
                        	<cfset working_start = main_working_start> <!---İlk Döngü Satırı İse ; Blok Çalışma Başlama Saati Gün Genel Mesai Başlama Saati Olsun--->
                        </cfif>
                        <cfset working_end = DateAdd('n',breaking_blocks_sort.start_minute,DateAdd('h',breaking_blocks_sort.start_hour, test_gun))>
                        <cfset working_id = 1>
                        <cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                        <cfif is_half_day eq 1> <!---Yarım Gün İşaretli İse Döngüden Çık--->
                        	<cfbreak>
                        </cfif>
                        <cfset working_start = DateAdd('n',breaking_blocks_sort.end_minute,DateAdd('h',breaking_blocks_sort.end_hour, test_gun))>
                        <cfif currentrow eq breaking_blocks_sort_count> <!---son turda ise--->
                        	<cfset working_end = main_working_end> <!---Son Döngü Satırı İse ; Blok Çalışma Biitiş Saati Gün Genel Mesai Bitiş Saati Olsun--->
                            <cfset working_id = 1>
                            <cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                        </cfif>
                 	</cfloop>
             	</cfif>
           	<cfelseif tatil eq 2> <!---Tam Gün Ulusal Tatil--->
              	<cfset tatil_gun = tatil_gun + 1>
           	<cfelseif tatil eq 0> <!---Ulusal Tatil Değilse--->
                 <cfif isdefined('breaking_blocks_sort') and breaking_blocks_sort.recordcount>
            		<cfloop query="breaking_blocks_sort">
                    	<cfif currentrow eq 1> <!---ilk turda ise--->
                        	<cfset working_start = main_working_start> <!---İlk Döngü Satırı İse ; Blok Çalışma Başlama Saati Gün Genel Mesai Başlama Saati Olsun--->
                        </cfif>
                        <cfset working_end = DateAdd('n',breaking_blocks_sort.start_minute,DateAdd('h',breaking_blocks_sort.start_hour, test_gun))>
                        <cfset working_id = 1>
                        <cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                        <cfset working_start = DateAdd('n',breaking_blocks_sort.end_minute,DateAdd('h',breaking_blocks_sort.end_hour, test_gun))>
                        <cfif currentrow eq breaking_blocks_sort_count> <!---son turda ise--->
                        	<cfset working_end = main_working_end> <!---Son Döngü Satırı İse ; Blok Çalışma Biitiş Saati Gün Genel Mesai Bitiş Saati Olsun--->
                            <cfset working_id = 1>
                            <cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                        </cfif>
                 	</cfloop>
             	</cfif>  
         	</cfif>
        <cfelse><!---Eğer Hatfa Sonu Çalışma Yoksa--->
        	<cfset tatil_gun = tatil_gun + 1>
        </cfif>
    <cfelse> <!---Hafta İçi İse--->
    	<cfset main_working_start = DateAdd('n',get_shift_info.START_MIN,DateAdd('h',get_shift_info.START_HOUR, test_gun))> <!---Cumartesi Mesai Başlama Tarih ve Saati--->
     	<cfset main_working_end = DateAdd('n',get_shift_info.END_MIN,DateAdd('h',get_shift_info.END_HOUR, test_gun))> <!---Cumartesi Mesai Bitiş Tarih ve Saati--->
    	<cfinclude template="hsp_ezgi_total_working_day_sub.cfm"> <!---Ulusal Tatil mi--->
     	<cfif tatil  eq 1> <!---Yarım Gün Ulusal Tatil--->
         	<cfset tatil_gun = tatil_gun + 0.5>
         	<!---Dikkat Yarım Gün Tatil Günlerinde, Mesai Çalışma Başlangıç ile Öğle Yemeği Arası Tasarlanmıştır--->
          	<cfif isdefined('breaking_blocks_sort') and breaking_blocks_sort.recordcount>
            	<cfloop query="breaking_blocks_sort">
                	<cfif currentrow eq 1> <!---ilk turda ise--->
                    	<cfset working_start = main_working_start> <!---İlk Döngü Satırı İse ; Blok Çalışma Başlama Saati Gün Genel Mesai Başlama Saati Olsun--->
                  	</cfif>
                 	<cfset working_end = DateAdd('n',breaking_blocks_sort.start_minute,DateAdd('h',breaking_blocks_sort.start_hour, test_gun))>
                    <cfset working_id = 1>
                	<cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                  	<cfif is_half_day eq 1> <!---Yarım Gün İşaretli İse Döngüden Çık--->
                     	<cfbreak>
                 	</cfif>
                 	<cfset working_start = DateAdd('n',breaking_blocks_sort.end_minute,DateAdd('h',breaking_blocks_sort.end_hour, test_gun))>
                  	<cfif currentrow eq breaking_blocks_sort_count> <!---son turda ise--->
                     	<cfset working_end = main_working_end> <!---Son Döngü Satırı İse ; Blok Çalışma Biitiş Saati Gün Genel Mesai Bitiş Saati Olsun--->
                        <cfset working_id = 1>
                    	<cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                 	</cfif>
            	</cfloop>
      		</cfif>
      	<cfelseif tatil eq 2> <!---Tam Gün Ulusal Tatil--->
        	<cfset tatil_gun = tatil_gun + 1>
     	<cfelseif tatil eq 0> <!---Ulusal Tatil Değilse--->
        	<cfif isdefined('breaking_blocks_sort') and breaking_blocks_sort.recordcount>
           		<cfloop query="breaking_blocks_sort">
               		<cfif currentrow eq 1> <!---ilk turda ise--->
                    	<cfset working_start = main_working_start> <!---İlk Döngü Satırı İse ; Blok Çalışma Başlama Saati Gün Genel Mesai Başlama Saati Olsun--->
                	</cfif>
                 	<cfset working_end = DateAdd('n',breaking_blocks_sort.start_minute,DateAdd('h',breaking_blocks_sort.start_hour, test_gun))>
                    <cfset working_id = 1>
                 	<cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                  	<cfset working_start = DateAdd('n',breaking_blocks_sort.end_minute,DateAdd('h',breaking_blocks_sort.end_hour, test_gun))>
                 	<cfif currentrow eq breaking_blocks_sort_count> <!---son turda ise--->
                     	<cfset working_end = main_working_end> <!---Son Döngü Satırı İse ; Blok Çalışma Biitiş Saati Gün Genel Mesai Bitiş Saati Olsun--->
                        <cfset working_id = 1>
                     	<cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                  	</cfif>
              	</cfloop>
        	</cfif>  
    	</cfif>
    </cfif>
    <cfset test_gun = DateAdd('d',i,gun)> <!---Döngüden Dolayı Yılbaşı Gününe i değeri Gün İlave Ederek Test Günü Değer Atar --->
</cfloop>

<cfset calisma_gun = toplam_gun - tatil_gun>
<cfset calisma_saniye = toplam_operator_sayisi*calisma_gun*3600*gunluk_caliasma_saat >

<cfset next_toplam_gun = daysInYear(DateAdd('yyyy',1,now()))> <!---Gelecek Yıl Kaç Gün (365/366)--->
<cfset next_gun = DateAdd('yyyy',1,createDate("#session.ep.period_year#", "01", "01"))> <!---Gelecek Yıl Başı Günü--->
<cfset test_gun = DateAdd('yyyy',1,createDate("#session.ep.period_year#", "01", "01"))> <!---Gelecek Döngü Başlama Günü--->
<cfset next_tatil_gun = 0>

<cfloop from="1" to="#next_toplam_gun#" index="i"> <!---Yıl İçindeki Tüm Günler için döner--->
    <cfif dayOfWeek(test_gun) eq get_shift_info.WEEK_OFFDAY> <!---Hafta Tatili Pazar Günü ise--->
    	<cfset next_tatil_gun = next_tatil_gun + 1>
 	<cfelseif dayOfWeek(test_gun) eq 7 and get_shift_info.WEEK_OFFDAY neq 7> <!---Hafta Sonu Cumartesi İse ve Hafta Tatili Cumartesi Değil ise--->
    	<cfset main_working_start = DateAdd('n',get_shift_info.STD_START_MIN,DateAdd('h',get_shift_info.STD_START_HOUR, test_gun))> <!---Cumartesi Mesai Başlama Tarih ve Saati--->
     	<cfset main_working_end = DateAdd('n',get_shift_info.STD_END_MIN,DateAdd('h',get_shift_info.STD_END_HOUR, test_gun))> <!---Cumartesi Mesai Bitiş Tarih ve Saati--->
    	<cfif DateDiff('n',DateAdd('n',get_shift_info.STD_START_MIN,DateAdd('h',get_shift_info.STD_START_HOUR, test_gun)),DateAdd('n',get_shift_info.STD_END_MIN,DateAdd('h',get_shift_info.STD_END_HOUR, test_gun))) gt 0> <!---Eğer Hafta Sonu Çalışma Varsa--->
        	<cfinclude template="hsp_ezgi_total_working_day_sub.cfm"> <!---Ulusal Tatil mi--->
        	<cfif tatil  eq 1> <!---Yarım Gün Ulusal Tatil--->
             	<cfset next_tatil_gun = next_tatil_gun + 0.5>
              	<!---Dikkat Yarım Gün Tatil Günlerinde, Mesai Çalışma Başlangıç ile Öğle Yemeği Arası Tasarlanmıştır--->
           		<cfif isdefined('breaking_blocks_sort') and breaking_blocks_sort.recordcount>
            		<cfloop query="breaking_blocks_sort">
                    	<cfif currentrow eq 1> <!---ilk turda ise--->
                        	<cfset working_start = main_working_start> <!---İlk Döngü Satırı İse ; Blok Çalışma Başlama Saati Gün Genel Mesai Başlama Saati Olsun--->
                        </cfif>
                        <cfset working_end = DateAdd('n',breaking_blocks_sort.start_minute,DateAdd('h',breaking_blocks_sort.start_hour, test_gun))>
                        <cfset working_id = 1>
                        <cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                        <cfif is_half_day eq 1> <!---Yarım Gün İşaretli İse Döngüden Çık--->
                        	<cfbreak>
                        </cfif>
                        <cfset working_start = DateAdd('n',breaking_blocks_sort.end_minute,DateAdd('h',breaking_blocks_sort.end_hour, test_gun))>
                        <cfif currentrow eq breaking_blocks_sort_count> <!---son turda ise--->
                        	<cfset working_end = main_working_end> <!---Son Döngü Satırı İse ; Blok Çalışma Biitiş Saati Gün Genel Mesai Bitiş Saati Olsun--->
                            <cfset working_id = 1>
                            <cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                        </cfif>
                 	</cfloop>
             	</cfif>
           	<cfelseif tatil eq 2> <!---Tam Gün Ulusal Tatil--->
              	<cfset next_tatil_gun = next_tatil_gun + 1>
           	<cfelseif tatil eq 0> <!---Ulusal Tatil Değilse--->
                 <cfif isdefined('breaking_blocks_sort') and breaking_blocks_sort.recordcount>
            		<cfloop query="breaking_blocks_sort">
                    	<cfif currentrow eq 1> <!---ilk turda ise--->
                        	<cfset working_start = main_working_start> <!---İlk Döngü Satırı İse ; Blok Çalışma Başlama Saati Gün Genel Mesai Başlama Saati Olsun--->
                        </cfif>
                        <cfset working_end = DateAdd('n',breaking_blocks_sort.start_minute,DateAdd('h',breaking_blocks_sort.start_hour, test_gun))>
                        <cfset working_id = 1>
                        <cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                        <cfset working_start = DateAdd('n',breaking_blocks_sort.end_minute,DateAdd('h',breaking_blocks_sort.end_hour, test_gun))>
                        <cfif currentrow eq breaking_blocks_sort_count> <!---son turda ise--->
                        	<cfset working_end = main_working_end> <!---Son Döngü Satırı İse ; Blok Çalışma Biitiş Saati Gün Genel Mesai Bitiş Saati Olsun--->
                            <cfset working_id = 1>
                            <cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                        </cfif>
                 	</cfloop>
             	</cfif>  
         	</cfif>
        <cfelse><!---Eğer Hatfa Sonu Çalışma Yoksa--->
        	<cfset next_tatil_gun = next_tatil_gun + 1>
        </cfif>
    <cfelse> <!---Hafta İçi İse--->
    	<cfset main_working_start = DateAdd('n',get_shift_info.START_MIN,DateAdd('h',get_shift_info.START_HOUR, test_gun))> <!---Cumartesi Mesai Başlama Tarih ve Saati--->
     	<cfset main_working_end = DateAdd('n',get_shift_info.END_MIN,DateAdd('h',get_shift_info.END_HOUR, test_gun))> <!---Cumartesi Mesai Bitiş Tarih ve Saati--->
    	<cfinclude template="hsp_ezgi_total_working_day_sub.cfm"> <!---Ulusal Tatil mi--->
     	<cfif tatil  eq 1> <!---Yarım Gün Ulusal Tatil--->
         	<cfset next_tatil_gun = next_tatil_gun + 0.5>
         	<!---Dikkat Yarım Gün Tatil Günlerinde, Mesai Çalışma Başlangıç ile Öğle Yemeği Arası Tasarlanmıştır--->
          	<cfif isdefined('breaking_blocks_sort') and breaking_blocks_sort.recordcount>
            	<cfloop query="breaking_blocks_sort">
                	<cfif currentrow eq 1> <!---ilk turda ise--->
                    	<cfset working_start = main_working_start> <!---İlk Döngü Satırı İse ; Blok Çalışma Başlama Saati Gün Genel Mesai Başlama Saati Olsun--->
                  	</cfif>
                 	<cfset working_end = DateAdd('n',breaking_blocks_sort.start_minute,DateAdd('h',breaking_blocks_sort.start_hour, test_gun))>
                    <cfset working_id = 1>
                	<cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                  	<cfif is_half_day eq 1> <!---Yarım Gün İşaretli İse Döngüden Çık--->
                     	<cfbreak>
                 	</cfif>
                 	<cfset working_start = DateAdd('n',breaking_blocks_sort.end_minute,DateAdd('h',breaking_blocks_sort.end_hour, test_gun))>
                  	<cfif currentrow eq breaking_blocks_sort_count> <!---son turda ise--->
                     	<cfset working_end = main_working_end> <!---Son Döngü Satırı İse ; Blok Çalışma Biitiş Saati Gün Genel Mesai Bitiş Saati Olsun--->
                        <cfset working_id = 1>
                    	<cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                 	</cfif>
            	</cfloop>
      		</cfif>
      	<cfelseif tatil eq 2> <!---Tam Gün Ulusal Tatil--->
        	<cfset next_tatil_gun = next_tatil_gun + 1>
     	<cfelseif tatil eq 0> <!---Ulusal Tatil Değilse--->
        	<cfif isdefined('breaking_blocks_sort') and breaking_blocks_sort.recordcount>
           		<cfloop query="breaking_blocks_sort">
               		<cfif currentrow eq 1> <!---ilk turda ise--->
                    	<cfset working_start = main_working_start> <!---İlk Döngü Satırı İse ; Blok Çalışma Başlama Saati Gün Genel Mesai Başlama Saati Olsun--->
                	</cfif>
                 	<cfset working_end = DateAdd('n',breaking_blocks_sort.start_minute,DateAdd('h',breaking_blocks_sort.start_hour, test_gun))>
                    <cfset working_id = 1>
                 	<cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                  	<cfset working_start = DateAdd('n',breaking_blocks_sort.end_minute,DateAdd('h',breaking_blocks_sort.end_hour, test_gun))>
                 	<cfif currentrow eq breaking_blocks_sort_count> <!---son turda ise--->
                     	<cfset working_end = main_working_end> <!---Son Döngü Satırı İse ; Blok Çalışma Biitiş Saati Gün Genel Mesai Bitiş Saati Olsun--->
                        <cfset working_id = 1>
                     	<cfinclude template="hsp_ezgi_total_working_day_sub_1.cfm">
                  	</cfif>
              	</cfloop>
        	</cfif>  
    	</cfif>
    </cfif>
    <cfset test_gun = DateAdd('d',i, next_gun)> <!---Döngüden Dolayı Yılbaşı Gününe i değeri Gün İlave Ederek Test Günü Değer Atar --->
</cfloop>