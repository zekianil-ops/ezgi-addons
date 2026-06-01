<!---
    File: list_ezgi_oee_analist.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfparam name="attributes.controller_emp_id" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.controller_emp" default="">
<cfparam name="attributes.station_id" default="">
<cfparam name="attributes.shift_id" default="">
<cfparam name="attributes.operation_type_id" default="">
<cfparam name="attributes.report_type" default="1">
<cfparam name="attributes.report_format" default="1">
<cfparam name="attributes.list_type" default="1">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfif isdefined("attributes.start_date") and isdate(attributes.start_date)>
	<cf_date tarih="attributes.start_date">
<cfelse>
	<cfset attributes.start_date = ''>
</cfif>

<cfif isdefined("attributes.finish_date") and isdate(attributes.finish_date)>
	<cf_date tarih="attributes.finish_date">
<cfelse>
	<cfset attributes.finish_date = ''>
</cfif>

<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_DEFAULTS
</cfquery>
<cfset toplam_operator_sayisi = get_defaults.DEFAULT_ACTIVE_OPERATOR_AMOUNT>
<cfquery name="get_station" datasource="#dsn3#">
	SELECT     
    	E.STATION_ID, 
        W.STATION_NAME,
        ISNULL((SELECT OEE_PERFORM_RATE FROM EZGI_STATION_OOE_RATE WHERE STATION_ID = E.STATION_ID AND OEE_STATUS = 1),0) AS OEE_PERFORM_RATE,
        ISNULL((SELECT OEE_AVAILBILITY_RATE FROM EZGI_STATION_OOE_RATE WHERE STATION_ID = E.STATION_ID AND OEE_STATUS = 1),0) AS OEE_AVAILBILITY_RATE,
        ISNULL((SELECT OEE_QUALITY_RATE FROM EZGI_STATION_OOE_RATE WHERE STATION_ID = E.STATION_ID AND OEE_STATUS = 1),0) AS OEE_QUALITY_RATE
	FROM         
    	EZGI_OPERATION_M AS E INNER JOIN
        WORKSTATIONS AS W ON E.STATION_ID = W.STATION_ID
	GROUP BY 
    	E.STATION_ID, 
        W.STATION_NAME
  	ORDER BY
    	W.STATION_NAME
</cfquery>
<cfquery name="get_employee" datasource="#dsn3#">
	SELECT        
    	EMPLOYEE_ID,
        ISNULL((SELECT OEE_PERFORM_RATE FROM EZGI_EMPLOYEE_OOE_RATE WHERE EMPLOYEE_ID = E.EMPLOYEE_ID AND OEE_STATUS = 1),0) AS OEE_PERFORM_RATE,
        ISNULL((SELECT OEE_AVAILBILITY_RATE FROM EZGI_EMPLOYEE_OOE_RATE WHERE EMPLOYEE_ID = E.EMPLOYEE_ID AND OEE_STATUS = 1),0) AS OEE_AVAILBILITY_RATE,
        ISNULL((SELECT OEE_QUALITY_RATE FROM EZGI_EMPLOYEE_OOE_RATE WHERE EMPLOYEE_ID = E.EMPLOYEE_ID AND OEE_STATUS = 1),0) AS OEE_QUALITY_RATE
	FROM            
    	#dsn_alias#.EMPLOYEES E
	WHERE        
    	EMPLOYEE_STATUS = 1
</cfquery>
<cfif attributes.report_type eq 1>
	<cfoutput query="get_station">
        <cfset 'STATION_NAME_#STATION_ID#' = STATION_NAME>
        <cfset 'OEE_PERFORM_RATE_#STATION_ID#' = OEE_PERFORM_RATE>
        <cfset 'OEE_AVAILBILITY_RATE_#STATION_ID#' = OEE_AVAILBILITY_RATE>
        <cfset 'OEE_QUALITY_RATE_#STATION_ID#' = OEE_QUALITY_RATE>
    </cfoutput>
<cfelse>
	<cfoutput query="get_employee">
        <cfset 'OEE_PERFORM_RATE_#EMPLOYEE_ID#' = OEE_PERFORM_RATE>
        <cfset 'OEE_AVAILBILITY_RATE_#EMPLOYEE_ID#' = OEE_AVAILBILITY_RATE>
        <cfset 'OEE_QUALITY_RATE_#EMPLOYEE_ID#' = OEE_QUALITY_RATE>
    </cfoutput>
</cfif>


<cfquery name="get_shift" datasource="#dsn#">
	SELECT SHIFT_ID, SHIFT_NAME FROM SETUP_SHIFTS
</cfquery>
<cfquery name="get_operation" datasource="#dsn3#">
	SELECT     
    	E.OPERATION_TYPE_ID, 
        O.OPERATION_TYPE
	FROM         
    	EZGI_OPERATION_M AS E INNER JOIN
        OPERATION_TYPES AS O ON E.OPERATION_TYPE_ID = O.OPERATION_TYPE_ID

	GROUP BY 
    	E.OPERATION_TYPE_ID, 
        O.OPERATION_TYPE
   	ORDER BY
    	O.OPERATION_TYPE
</cfquery>
<cfoutput query="get_operation">
	<cfset 'OPERATION_TYPE_#OPERATION_TYPE_ID#' = OPERATION_TYPE >
</cfoutput>
<cfif isdefined("attributes.form_varmi")>
	<cfquery name="get_perform" datasource="#dsn3#">
        SELECT        
            OPERATION_CODE, 
            OPERATION_TYPE, 
            OPERATION_TYPE_ID, 
            SUM(REAL_AMOUNT) AS REAL_AMOUNT, 
            SUM(REAL_TIME) AS REAL_TIME, 
            SUM(OPTIMUM_TIME) AS OPTIMUM_TIME, 
            CASE 
                WHEN 
                    SUM(OPTIMUM_TIME) > 0 AND SUM(REAL_TIME) > 0 
                THEN 
                    ROUND(SUM(OPTIMUM_TIME) / SUM(REAL_TIME), 2) 
                ELSE 
                    0
            END AS PERFORMANS_ORAN,
            <cfif isdefined('attributes.report_type') and attributes.report_type eq 2>
                ACTION_EMPLOYEE_ID AS STATION_ID,
            <cfelse>
                STATION_ID,
            </cfif>
            <cfif attributes.report_format eq 1>
            	DAY_TIME,
            </cfif>
            <cfif attributes.report_format eq 2>
            	WEEK_TIME,
            </cfif>
            <cfif attributes.report_format eq 1 or attributes.report_format eq 3>
            	MONTH_TIME,
            </cfif>
            YEAR_TIME
        FROM            
            (
                SELECT        
                    OES.OPERATION_CODE, 
                    OES.OPERATION_TYPE, 
                    OES.OPERATION_TYPE_ID, 
                    OES.STOCK_ID, 
                    <cfif attributes.report_type eq 1>
                    	OES.STATION_ID, 
                    <cfelse>
                    	OES.ACTION_EMPLOYEE_ID,
                    </cfif>
                    ISNULL(SUM(OES.REAL_AMOUNT), 0) AS REAL_AMOUNT, 
                    ISNULL(SUM(OES.REAL_TIME), 0) AS REAL_TIME, 
                    SUM(ISNULL(OES.REAL_AMOUNT,0) * ISNULL(EOOT.OPTIMUM_TIME,0)) AS OPTIMUM_TIME, 
                    YEAR(OES.ACTION_START_DATE) AS YEAR_TIME, 
                    MONTH(OES.ACTION_START_DATE) AS MONTH_TIME, 
                    DAY(OES.ACTION_START_DATE) AS DAY_TIME, 
                    { fn WEEK(OES.ACTION_START_DATE) } AS WEEK_TIME
                FROM            
                    EZGI_OPERATION_M AS OES LEFT OUTER JOIN
                    EZGI_OPERATION_OPTIMUM_TIME AS EOOT ON OES.OPERATION_TYPE_ID = EOOT.OPERATION_TYPE_ID AND OES.STOCK_ID = EOOT.STOCK_ID
                WHERE        
                    OES.REAL_TIME > 0 AND
                    <cfif attributes.report_type eq 1>
                    	OES.STATION_ID IN (SELECT STATION_ID FROM EZGI_STATION_OOE_RATE WHERE OEE_STATUS = 1)
                    <cfelse>
                    	OES.ACTION_EMPLOYEE_ID IN (SELECT EMPLOYEE_ID FROM EZGI_EMPLOYEE_OOE_RATE WHERE OEE_STATUS = 1)
                    </cfif>
                    <cfif len(attributes.operation_type_id)>
                        AND OES.OPERATION_TYPE_ID = #attributes.operation_type_id#
                    </cfif>
                    <cfif len(attributes.controller_emp)>
                        AND OES.ACTION_EMPLOYEE_ID = #attributes.controller_emp_id#
                    </cfif>
                    <cfif len(attributes.station_id)>
                        AND OES.STATION_ID = #attributes.station_id#
                    </cfif>
                    <cfif len(attributes.start_date)>
                        AND OES.ACTION_START_DATE >=#attributes.start_date# 
                    </cfif>
                    <cfif len(attributes.finish_date)>
                        AND OES.ACTION_START_DATE < #DateAdd('d',1,attributes.finish_date)# 
                    </cfif>
                GROUP BY 
                    OES.OPERATION_CODE, 
                    OES.OPERATION_TYPE, 
                    OES.OPERATION_TYPE_ID, 
                    OES.STOCK_ID, 
                    <cfif attributes.report_type eq 1>
                    	OES.STATION_ID, 
                    <cfelse>
                    	OES.ACTION_EMPLOYEE_ID,
                    </cfif>
                    EOOT.OPTIMUM_TIME, 
                    YEAR(OES.ACTION_START_DATE), 
                    MONTH(OES.ACTION_START_DATE), 
                    DAY(OES.ACTION_START_DATE), 
                    { fn WEEK(OES.ACTION_START_DATE) }
            ) AS TBL_1
        WHERE 
            1=1
            <cfif isdefined('attributes.day_time') and len(attributes.day_time)>
                AND DAY_TIME = #attributes.day_time#
            <cfelseif isdefined('attributes.week_time') and len(attributes.week_time)>
                AND WEEK_TIME = #attributes.week_time#
            <cfelseif isdefined('attributes.month_time') and len(attributes.month_time)>
                AND MONTH_TIME = #attributes.month_time#
            <cfelseif isdefined('attributes.year_time') and len(attributes.year_time)>
                AND YEAR_TIME = #attributes.year_time#
            </cfif>
        GROUP BY 
            OPERATION_CODE, 


            OPERATION_TYPE, 
            OPERATION_TYPE_ID, 
            <cfif isdefined('attributes.report_type') and attributes.report_type eq 2>
                ACTION_EMPLOYEE_ID,
            <cfelse>
                STATION_ID,
            </cfif>
            <cfif attributes.report_format eq 1>
            	DAY_TIME,
            </cfif>
            <cfif attributes.report_format eq 2>
            	WEEK_TIME,
            </cfif>
            <cfif attributes.report_format eq 1 or attributes.report_format eq 3>
            	MONTH_TIME,
            </cfif>
            YEAR_TIME
      	ORDER BY
        	YEAR_TIME
            <cfif attributes.report_format eq 1 or attributes.report_format eq 3>
            	,MONTH_TIME
            </cfif>
            <cfif attributes.report_format eq 2>
            	,WEEK_TIME
            </cfif>
        	<cfif attributes.report_format eq 1>
            	,DAY_TIME
            </cfif>
    </cfquery>
    <cfquery name="get_plan_info" datasource="#dsn3#">
        SELECT 
        	ISNULL(D.WORK_TIME,0) AS WORK_TIME,
            SS.DEPARTMENT_ID
		FROM     
        	EZGI_MASTER_PLAN_DEFAULTS AS D INNER JOIN
            #dsn_alias#.SETUP_SHIFTS AS SS ON D.SHIFT_ID = SS.SHIFT_ID
		WHERE  
        	D.SHIFT_ID = #attributes.shift_id#
    </cfquery>
    <cfset attributes.department_id = get_plan_info.DEPARTMENT_ID>
    <cfif get_plan_info.WORK_TIME gt 0 and get_plan_info.recordcount>
		<cfset gunluk_caliasma_saat = get_plan_info.WORK_TIME/3600>
        <cfset working_minute = get_plan_info.WORK_TIME/60>
        <cfset total_working_minute = 0>
    <cfelse>
    	<script type="text/javascript">
            alert("Çalışma Programlarında İlgili Çalışma Programının Çalışma Saat Tanımlarını Yapınız!");
            window.close()
        </script>
    	<cfabort>
    </cfif>
<cfelse>
	<cfset get_perform.recordcount =0>
</cfif>
<cfsavecontent variable="ooe_analyse"><cf_get_lang dictionary_id='798.OEE Analiz'></cfsavecontent>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_perform.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="quality_control" id="quality_control" method="post" action="#request.self#?fuseaction=prod.list_ezgi_oee_analist">
			<input name="form_varmi" id="form_varmi" value="1" type="hidden">
            <cf_box_search>
              	<div class="form-group"  id="item-keyword">
                  	<cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                	<cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
            	</div>
             	<div class="form-group medium" id="item-shift_id">
					<select name="shift_id" id="shift_id" style="width:110px; height:20px">
                     	<cfoutput query="get_shift">
                        	<option value="#shift_id#" <cfif attributes.shift_id eq shift_id>selected</cfif>>#SHIFT_NAME#</option>
                    	</cfoutput>
               		</select>
              	</div>
				<div class="form-group medium" id="item-station_id">
					<select name="station_id" id="station_id" style="width:100px; height:20px">
                     	<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                     	<cfoutput query="get_station">
                         	<option value="#station_id#" <cfif attributes.station_id eq station_id>selected</cfif>>#station_name#</option>
                     	</cfoutput>
                	</select>
              	</div>
                <div class="form-group medium" id="item-operation_type_id">
					<select name="operation_type_id" id="operation_type_id" style="width:100px; height:20px">
                    	<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                     	<cfoutput query="get_operation">
                        	<option value="#operation_type_id#" <cfif attributes.operation_type_id eq operation_type_id>selected</cfif>>#OPERATION_TYPE#</option>
                    	</cfoutput>
               		</select>
              	</div>
                <div class="form-group medium" id="item-report_type">
					<select name="report_type" id="report_type" style="width:70px; height:20px">
                    	<option value="1" <cfif attributes.report_type eq 1>selected</cfif>><cf_get_lang dictionary_id='58834.İstasyon'></option>
                     	<option value="2" <cfif attributes.report_type eq 2>selected</cfif>><cf_get_lang dictionary_id='57576.Çalışan'></option>
                	</select>
              	</div>
                <div class="form-group medium" id="item-report_format">
					<select name="report_format" id="report_format" style="width:70px; height:20px">
                   		<option value="1" <cfif attributes.report_format eq 1>selected</cfif>><cf_get_lang dictionary_id='58457.Günlük'></option>
                    	<!---<option value="2" <cfif attributes.report_format eq 2>selected</cfif>><cf_get_lang dictionary_id='58458.Haftalık'></option>
                    	<option value="3" <cfif attributes.report_format eq 3>selected</cfif>><cf_get_lang dictionary_id='58932.Aylık'></option>
                     	<option value="4" <cfif attributes.report_format eq 4>selected</cfif>><cf_get_lang dictionary_id='29400.Yıllık'></option>--->
                  	</select>
              	</div>
                <div class="form-group" id="item-report_date">
                        <div class="col col-12">
                            <div class="col col-6 pl-0">
                                <div class="input-group">
                                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='30122.Başlangıç Tarihini Kontrol Ediniz'></cfsavecontent>
                                    <cfinput type="text" name="start_date" value="#dateformat(attributes.start_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                                </div>
                            </div>
                            <div class="col col-6 pl-0">
                                <div class="input-group">
                                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='30123.Bitiş Tarihini Kontrol Ediniz'></cfsavecontent>
                                    <cfinput type="text" name="finish_date" value="#dateformat(attributes.finish_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                                </div>
                            </div>
                        </div>
              	</div>
                <div class="form-group small">
                  	<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                	<cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
           		</div>
             	<div class="form-group">
                 	<cf_wrk_search_button search_function='input_control()' button_type="4">
             	</div>
         	</cf_box_search>
            <cf_box_search_detail>
                <div id="detail_search_div" class="col col-12" style="display:table-row;">
                	<div class="col col-3">
                    	<div class="col col-12">
                       		<div class="form-group medium">
                            	<div class="col col-3">
                                	<label><cf_get_lang dictionary_id='57576.Çalışan'></label>
                                </div>
                                <div class="col col-9">
                                    <div class="input-group">
                                        <input type="hidden" name="controller_emp_id" id="controller_emp_id" value="<cfif len(attributes.controller_emp_id)><cfoutput>#attributes.controller_emp_id#</cfoutput></cfif>">			
                                        <input type="text" name="controller_emp" id="controller_emp" value="<cfif len(attributes.controller_emp_id) and len(attributes.controller_emp)><cfoutput>#attributes.controller_emp#</cfoutput></cfif>" onfocus="AutoComplete_Create('controller_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','controller_emp_id','','3','130');" autocomplete="off" style="width:100px;">
                                 	<span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_emps&field_id=quality_control.controller_emp_id&field_name=quality_control.controller_emp&select_list=1','list');return false"></span>
                                    </div>
                                </div>
                            </div>
                       	</div>
                   	</div>
             	</div>
        	</cf_box_search_detail> 
            <cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
					<cfset filename = "#createuuid()#">
                    <cfheader name="Expires" value="#Now()#">
                    <cfcontent type="application/vnd.msexcel;charset=utf-16">
                    <cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
                    <meta http-equiv="Content-Type" content="text/html; charset=utf-16">
                    <cfset attributes.startrow=1>
                    <cfset attributes.maxrows = get_perform.recordcount>
         	</cfif>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='798.OEE Analiz'></cfsavecontent>
       		<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
             	<cf_grid_list>   
                 	<thead>
                    	<tr valign="middle">
                          	<th rowspan="2" style="width:20px; text-align:center"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th rowspan="2" style="width:150px; text-align:center"><cf_get_lang dictionary_id='58472.Dönem'></th>
                            <cfif attributes.report_type eq 2> 
                                <th rowspan="2" style="text-align:center"><cf_get_lang dictionary_id='57576.Çalışan'></th>
                            <cfelse>
                                <th rowspan="2" style="text-align:center"><cf_get_lang dictionary_id='58834.İstasyon'></th>
                            </cfif>
                            <th rowspan="2" style="text-align:center"><cf_get_lang dictionary_id='29419.Operasyon'></th>
                            <th rowspan="2" style="width:50px; text-align:center"><cf_get_lang dictionary_id='138.Üretim Miktarı'></th>
                            <th rowspan="2" style="width:60px; text-align:center"><cf_get_lang dictionary_id='57951.Hedef'><br><cf_get_lang dictionary_id='29513.Süre'> (<cf_get_lang dictionary_id='420.Sn'>)</th>
                            <th rowspan="2" style="width:60px; text-align:center"><cf_get_lang dictionary_id='57684.Sonuç'><br><cf_get_lang dictionary_id='29513.Süre'>(<cf_get_lang dictionary_id='420.Sn'>)</th>
                            <th rowspan="2" style="width:60px; text-align:center"><cf_get_lang dictionary_id='58472.Dönem'><br><cf_get_lang dictionary_id='29513.Süre'> (<cf_get_lang dictionary_id='420.Sn'>)</th>
                            <th colspan="2" style="width:100px; text-align:center"><cf_get_lang dictionary_id='58003.Performans'></th>
                            <th colspan="2" style="width:100px; text-align:center"><cf_get_lang dictionary_id='53815.Toplam Çalışma'></th>
                            <th colspan="2" style="width:100px; text-align:center"><cf_get_lang dictionary_id='59157.Kalite'></th>
                            <th colspan="2" style="width:100px; text-align:center"><cf_get_lang dictionary_id='683.OEE'></th>
                        </tr>
                        <tr>
                            <th style="width:50px; text-align:center"><cf_get_lang dictionary_id='57951.Hedef'></th>
                            <th style="width:50px; text-align:center"><cf_get_lang dictionary_id='57684.Sonuç'></th>
                            <th style="width:50px; text-align:center"><cf_get_lang dictionary_id='57951.Hedef'></th>
                            <th style="width:50px; text-align:center"><cf_get_lang dictionary_id='57684.Sonuç'></th>
                            <th style="width:50px; text-align:center"><cf_get_lang dictionary_id='57951.Hedef'></th>
                            <th style="width:50px; text-align:center"><cf_get_lang dictionary_id='57684.Sonuç'></th>
                            <th style="width:50px; text-align:center"><cf_get_lang dictionary_id='57951.Hedef'></th>
                            <th style="width:50px; text-align:center"><cf_get_lang dictionary_id='57684.Sonuç'></th>
                        </tr>
                    </thead>
                    <tbody>
						<cfif isdefined("attributes.form_varmi") and get_perform.recordcount>
                            <cfoutput query="get_perform" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                                <cfif attributes.report_format eq 1>
                                    <cfset toplam_gun = 1> <!---Hesaplanacak Dönem Aralığı--->
                                    <cfset gun = createDate("#YEAR_TIME#", "#MONTH_TIME#", "#DAY_TIME#")> <!---Başlama Günü--->
                                    <cfset test_gun = gun> <!---Döngü Başlama Günü--->
                                <cfelseif attributes.report_format eq 2>
                                    <cfset toplam_gun = 7> <!---Hesaplanacak Dönem Aralığı--->
                                    <cfset gun = createDate("#YEAR_TIME#", "01", "01")> <!---Yıl Başı Günü--->
                                    <cfset gun = DateAdd("ww",week_time,gun)>
                                    <cfset test_gun = gun> <!---Döngü Başlama Günü--->          
                                <cfelseif attributes.report_format eq 3>
                                    
                                    <cfset gun = createDate("#YEAR_TIME#", "#MONTH_TIME#", "01")> <!---Başlama Günü--->
                                    <cfset test_gun = gun> <!---Döngü Başlama Günü--->
                                    <cfset toplam_gun = DaysInMonth(gun)> <!---Hesaplanacak Dönem Aralığı--->
                                <cfelseif attributes.report_format eq 4>
                                    <cfset gun = createDate("#YEAR_TIME#", "01", "01")> <!---Başlama Günü--->
                                    <cfset test_gun = gun> <!---Döngü Başlama Günü--->
                                    <cfset toplam_gun = daysInYear(now())> <!---Bu Yıl Kaç Gün (365/366)--->
                                </cfif>
                                <cfinclude template="../../e_design/query/hsp_ezgi_total_working_day_1.cfm"> <!---'İlgili Gün Aralığını Hesapla--->
                                <tr class="color-row">
                                    <td style="text-align:right">#currentrow#</td>
                                    <td style="text-align:CENTER; height:25px">
                                        <cfif attributes.report_format eq 1>
                                        	<cfset tarih = '#DAY_TIME#/#MONTH_TIME#/#YEAR_TIME#'> 
                                        	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.popup_ezgi_production_analist&is_submitted=1&maxrows=#attributes.maxrows#&start_date=#tarih#&finish_date=#tarih#&operation_type_id=#OPERATION_TYPE_ID#&<cfif attributes.report_type eq 2>controller_emp=#STATION_ID#<cfelse>station_id=#STATION_ID#</cfif>','longpage');">
                                            #DAY_TIME#
                                            <cfif MONTH_TIME eq 1>
                                                <cf_get_lang dictionary_id='57592.Ocak'>
                                            <cfelseif MONTH_TIME eq 2>
                                                <cf_get_lang dictionary_id='57593.Şubat'>
                                            <cfelseif MONTH_TIME eq 3>
                                                <cf_get_lang dictionary_id='57594.Mart'>
                                            <cfelseif MONTH_TIME eq 4>
                                                <cf_get_lang dictionary_id='57595.Nisan'>
                                            <cfelseif MONTH_TIME eq 5>
                                                <cf_get_lang dictionary_id='57596.Mayıs'>
                                            <cfelseif MONTH_TIME eq 6>
                                                <cf_get_lang dictionary_id='57597.Haziran'>
                                            <cfelseif MONTH_TIME eq 7>
                                                <cf_get_lang dictionary_id='57598.Temmuz'>
                                            <cfelseif MONTH_TIME eq 8>
                                                <cf_get_lang dictionary_id='57599.Ağustos'>
                                            <cfelseif MONTH_TIME eq 9>
                                                <cf_get_lang dictionary_id='57600.Eylül'>
                                            <cfelseif MONTH_TIME eq 10>
                                                <cf_get_lang dictionary_id='57601.Ekim'>
                                            <cfelseif MONTH_TIME eq 11>
                                                <cf_get_lang dictionary_id='57602.Kasım'>
                                            <cfelseif MONTH_TIME eq 12>
                                                <cf_get_lang dictionary_id='57603.Aralık'>
                                            </cfif>
                                            #YEAR_TIME#
                                            </a>
                                        <cfelseif attributes.report_format eq 2>
                                            #WEEK_TIME#-#YEAR_TIME#
                                        <cfelseif attributes.report_format eq 3>
                                            <cfif MONTH_TIME eq 1>
                                                <cf_get_lang dictionary_id='57592.Ocak'>
                                            <cfelseif MONTH_TIME eq 2>
                                                <cf_get_lang dictionary_id='57593.Şubat'>
                                            <cfelseif MONTH_TIME eq 3>
                                                <cf_get_lang dictionary_id='57594.Mart'>
                                            <cfelseif MONTH_TIME eq 4>
                                                <cf_get_lang dictionary_id='57595.Nisan'>
                                            <cfelseif MONTH_TIME eq 5>
                                                <cf_get_lang dictionary_id='57596.Mayıs'>
                                            <cfelseif MONTH_TIME eq 6>
                                                <cf_get_lang dictionary_id='57597.Haziran'>
                                            <cfelseif MONTH_TIME eq 7>
                                                <cf_get_lang dictionary_id='57598.Temmuz'>
                                            <cfelseif MONTH_TIME eq 8>
                                                <cf_get_lang dictionary_id='57599.Ağustos'>
                                            <cfelseif MONTH_TIME eq 9>
                                                <cf_get_lang dictionary_id='57600.Eylül'>
                                            <cfelseif MONTH_TIME eq 10>
                                                <cf_get_lang dictionary_id='57601.Ekim'>
                                            <cfelseif MONTH_TIME eq 11>
                                                <cf_get_lang dictionary_id='57602.Kasım'>
                                            <cfelseif MONTH_TIME eq 12>
                                                <cf_get_lang dictionary_id='57603.Aralık'>
                                            </cfif>
                                            -#YEAR_TIME#
                                        <cfelseif attributes.report_format eq 4>
                                            #YEAR_TIME#
                                        </cfif>
                                    </td>
                                    <td>
                                        <cfif attributes.report_type eq 2> 
                                            #get_emp_info(STATION_ID,0,0)# 
                                        <cfelse>
                                            <cfif isdefined('STATION_NAME_#STATION_ID#')>
                                                #Evaluate('STATION_NAME_#STATION_ID#')#
                                            </cfif>
                                        </cfif>
                                    </td>
                                    <td>#OPERATION_TYPE#</td>
                                    <td style="text-align:CENTER">#TlFormat(REAL_AMOUNT,0)#</td>
                                    <td style="text-align:CENTER">#TlFormat(OPTIMUM_TIME,0)#</td>
                                    <td style="text-align:CENTER">#TlFormat(REAL_TIME,0)#</td>
                					<cfset total_working_minute = total_working_minute + working_minute>
                                    <td style="text-align:CENTER">#TlFormat(total_working_minute*60,0)#</td>
                                    <!---PERFORMANS--->
                                    <td style="text-align:CENTER">
                                        <cfif isdefined('OEE_PERFORM_RATE_#STATION_ID#')>
                                            #TlFormat(Evaluate('OEE_PERFORM_RATE_#STATION_ID#'),1)#
                                            <cfset perform_rate = Evaluate('OEE_PERFORM_RATE_#STATION_ID#')>
                                        <cfelse>
                                            #TlFormat(0,1)#
                                            <cfset perform_rate = 0>
                                        </cfif>
                                    </td>
                                    <td style="text-align:CENTER;<cfif PERFORMANS_ORAN*100 gte perform_rate>background-color:LightCyan<cfelse>background-color:Seashell</cfif>"><b>#TlFormat(PERFORMANS_ORAN*100,1)#</b></td>
                                    <!---TOPLAM ÇALIŞMA--->
                                    <td style="text-align:CENTER">
                                        <cfif isdefined('OEE_AVAILBILITY_RATE_#STATION_ID#')>
                                            #TlFormat(Evaluate('OEE_AVAILBILITY_RATE_#STATION_ID#'),1)#
                                            <cfset availbility_rate = Evaluate('OEE_AVAILBILITY_RATE_#STATION_ID#')>
                                        <cfelse>
                                            #TlFormat(0,1)#
                                            <cfset availbility_rate = 0>
                                        </cfif>
                                        <cfif total_working_minute*60 gt 0 and REAL_TIME gt 0>
                                            <cfset real_availbility =  REAL_TIME/(total_working_minute*60)>
                                        <cfelse>
                                            <cfset real_availbility = 0>
                                        </cfif>
                                    </td>
                                    <td style="text-align:CENTER;<cfif real_availbility*100 gte availbility_rate>background-color:LightCyan<cfelse>background-color:Seashell</cfif>"><b>#TlFormat(real_availbility*100,1)#</b></td>
                                    <!---KALİTE--->
                                    <td style="text-align:CENTER">
                                        <cfif isdefined('OEE_QUALITY_RATE_#STATION_ID#')>
                                            #TlFormat(Evaluate('OEE_QUALITY_RATE_#STATION_ID#'),1)#
                                            <cfset quality_rate = Evaluate('OEE_QUALITY_RATE_#STATION_ID#')>
                                        <cfelse>
                                            #TlFormat(0,1)#
                                            <cfset quality_rate = 0>
                                        </cfif>
                                    </td>
                                    <td style="text-align:CENTER;background-color:LightCyan"><b>#TlFormat(100,0)#</b></td>
                                    <!---TOPLAM--->
                                    <td style="text-align:CENTER">#perform_rate*availbility_rate*quality_rate/10000#</td>
                                    <td style="text-align:CENTER;<cfif PERFORMANS_ORAN*real_availbility*100 gte perform_rate*availbility_rate*quality_rate/10000>background-color:LightCyan<cfelse>background-color:Seashell</cfif>">#TlFormat(PERFORMANS_ORAN*real_availbility*100,1)#</td>
                                </tr>
                                <cfset son_row = currentrow>
                            </cfoutput>
                            <tfoot>
                                <tr>
                                    <td colspan="16"><!---<cf_get_lang_main no='80.Toplam'>---> </td>
                                </tr>
                            </tfoot>  
                                <table style="width:100%">
                                    <tr>
                                        <td style="width:100%; height:620px; text-align:center; vertical-align:middle">
                                            <cfif len(attributes.station_id)>
                                                <cfchart
                                                    format="png"
                                                    scalefrom="0"
                                                    scaleto="120"
                                                    chartHeight="600" 
                                                    chartWidth="1300" 
                                                    showLegend="yes" 
                                                    >
                                                    <cfsavecontent variable="performans"><cf_get_lang dictionary_id='58003.Performans'></cfsavecontent>
                                                    <cfchartseries
                                                        type="line"
                                                        serieslabel="#performans#"
                                                        seriescolor="red">
                                                        <cfloop query="get_perform">
                                                                <cfif attributes.report_format eq 1>
                                                                    <cfset line_time = '#DAY_TIME#/#MONTH_TIME#/#YEAR_TIME#'>
                                                                <cfelseif attributes.report_format eq 2>
                                                                    <cfset line_time = '#WEEK_TIME#-#YEAR_TIME#'>
                                                                <cfelseif attributes.report_format eq 3>
                                                                    <cfset line_time = '#MONTH_TIME#-#YEAR_TIME#'>
                                                                <cfelseif attributes.report_format eq 4>
                                                                    <cfset line_time = '#YEAR_TIME#'>
                                                                </cfif>
                                                                <cfchartdata item="#line_time#" value="#PERFORMANS_ORAN*100#">
                                                        </cfloop>
                                                    </cfchartseries>
                                                    <cfsavecontent variable="sum_work"><cf_get_lang dictionary_id='53815.Toplam Çalışma'></cfsavecontent>
                                                    <cfchartseries
                                                        type="line"
                                                        serieslabel="#sum_work#"
                                                        seriescolor="orange">
                                                        <cfloop query="get_perform">
                                                                <cfif attributes.report_format eq 1>
                                                                    <cfset line_time = '#DAY_TIME#/#MONTH_TIME#/#YEAR_TIME#'>
                                                                <cfelseif attributes.report_format eq 2>
                                                                    <cfset line_time = '#WEEK_TIME#-#YEAR_TIME#'>
                                                                <cfelseif attributes.report_format eq 3>
                                                                    <cfset line_time = '#MONTH_TIME#-#YEAR_TIME#'>
                                                                <cfelseif attributes.report_format eq 4>
                                                                    <cfset line_time = '#YEAR_TIME#'>
                                                                </cfif>
                                                                <cfif total_working_minute*60 gt 0 and REAL_TIME gt 0>
                                                                    <cfset real_availbility =  REAL_TIME/(total_working_minute*60)*100>
                                                                    <cfchartdata item="#line_time#" value="#real_availbility#">
                                                                <cfelse>
                                                                    <cfchartdata item="#line_time#" value="0">
                                                                </cfif>
                                                        </cfloop>
                                                    </cfchartseries>
                                                </cfchart>
                                            </cfif>
                                        </td>
                                    </tr>
                                </table>
                            <!-- sil -->
                        <cfelse>
                            <tr><td class="color-row" colspan="20"><cfif not isdefined("attributes.form_varmi")><cf_get_lang dictionary_id='57701.Filtre ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'> !</cfif></td></tr>
                        </cfif>
                    </tbody>
              	</cf_grid_list>
    			<cfset url_str = url.fuseaction>
				<cfif len(attributes.keyword)>
					<cfset url_str = "#url_str#&keyword=#attributes.keyword#">
                </cfif>
                <cfif len(attributes.station_id)>
                    <cfset url_str = "#url_str#&station_id=#attributes.station_id#">
                </cfif>
                <cfif len(attributes.shift_id)>
                    <cfset url_str = "#url_str#&shift_id=#attributes.shift_id#">
                </cfif>
                <cfif len(attributes.operation_type_id)>
                    <cfset url_str = "#url_str#&operation_type_id=#attributes.operation_type_id#">
                </cfif>
                <cfif len(attributes.controller_emp)>
                    <cfset url_str = "#url_str#&controller_emp=#attributes.controller_emp#">
                </cfif>
                <cfif len(attributes.controller_emp_id)>
                    <cfset url_str = "#url_str#&controller_emp_id=#attributes.controller_emp_id#">
                </cfif>
                <cfif len(attributes.start_date)>
                	<cfset url_str = '#url_str#&start_date=#attributes.start_date#'>
              	</cfif>
              	<cfif len(attributes.finish_date)>
                	<cfset url_str = '#url_str#&finish_date=#attributes.finish_date#'>
             	</cfif>
             	<cf_paging 
                        page="#attributes.page#"
                        maxrows="#attributes.maxrows#"
                        totalrecords="#attributes.totalrecords#"
                        startrow="#attributes.startrow#"
                        adres="#url_str#&form_varmi=1">
        
			</cf_box>
		</cfform>
   	</cf_box>
</div>