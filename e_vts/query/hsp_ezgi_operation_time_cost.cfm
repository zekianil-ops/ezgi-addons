<!---
    File: hsp_ezgi_operation_time_cost.cfm
    Folder: Add_Ons\ezgi\e_vts\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 
<cfquery name="get_shift" datasource="#dsn3#">
	SELECT 
    	TOP (1) SS.SHIFT_ID
	FROM     
    	EZGI_IFLOW_PRODUCTION_ORDERS AS EO INNER JOIN
        PRODUCTION_ORDERS AS PO ON EO.LOT_NO = PO.LOT_NO INNER JOIN
        EZGI_IFLOW_MASTER_PLAN AS EOP ON EO.MASTER_PLAN_ID = EOP.MASTER_PLAN_ID INNER JOIN
        #dsn_alias#.SETUP_SHIFTS AS SS ON EOP.MASTER_PLAN_CAT_ID = SS.SHIFT_ID
	WHERE  
    	PO.P_ORDER_ID = #attributes.upd_id#
	UNION ALL
	SELECT 
    	TOP (1) SS.SHIFT_ID
	FROM  
    	EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
     	EZGI_MASTER_PLAN_RELATIONS AS EMP ON EMAP.MASTER_ALT_PLAN_ID = EMP.MASTER_ALT_PLAN_ID INNER JOIN
   		#dsn_alias#.SETUP_SHIFTS AS SS INNER JOIN
      	EZGI_MASTER_PLAN AS EM ON SS.SHIFT_ID = EM.MASTER_PLAN_CAT_ID ON EMAP.MASTER_PLAN_ID = EM.MASTER_PLAN_ID
	WHERE  
    	EMP.P_ORDER_ID = #attributes.upd_id#
</cfquery>
<cfif not get_shift.recordcount or not len(get_shift.SHIFT_ID)>
	<script type="text/javascript">
		alert("Üretim e ait Çalışma Programı Bulunamdı.!");
		window.history.go(-1);
	</script>
    <cfabort>
<cfelse>
	<cfset attributes.shift_id = get_shift.SHIFT_ID>
</cfif>
<cfquery name="get_general_offtime_table" datasource="#dsn3#"> <!---Ulusal Tatil Günlerini Çeker--->
 	SELECT        
   		OFFTIME_NAME, 
        START_DATE, 
        FINISH_DATE, 
        IS_HALFOFFTIME
  	FROM            
      	#dsn_alias#.SETUP_GENERAL_OFFTIMES
   	WHERE   
    	YEAR(START_DATE) = #session.ep.period_year# OR YEAR(START_DATE) = #session.ep.period_year#+1
</cfquery>

<cfquery name="get_shift_info" datasource="#dsn3#"> <!---Vardiya Bilgilerini Çeker--->
	SELECT * FROM #dsn_alias#.SETUP_SHIFTS WHERE SHIFT_ID = #attributes.shift_id#
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
