<!---
    File: dsp_ezgi_period_based_count_report.cfm
    Folder: Add_Ons\ezgi\e-wm\display
    Author: Ezgi Yazılım
    Date: 01/02/2025
    Description:
--->
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.keyword_0" default="">
<cfparam name="attributes.keyword_1" default="">
<cfparam name="attributes.keyword_2" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.depo" default="">
<cfparam name="attributes.status" default="1">
<cfparam name="attributes.is_excel" default="">
<cfquery name="get_depo" datasource="#dsn3#">
	SELECT DISTINCT
        D.DEPO_NAME, 
        D.DEPO
	FROM     
    	EZGI_WM_COUNT_SERIAL_ROW AS E WITH (NOLOCK) INNER JOIN
        EZGI_WM_DEPARTMENTS AS D WITH (NOLOCK) ON E.DEPARTMENT_ID = D.DEPARTMENT_ID AND E.LOCATION_ID = D.LOCATION_ID LEFT OUTER JOIN
     	EZGI_PRODUCT_PLACE AS P WITH (NOLOCK) ON E.PRODUCT_PLACE_ID = P.PRODUCT_PLACE_ID
	WHERE  
    	E.WM_COUNT_ID = #attributes.count_id#
  	ORDER BY
    	D.DEPO_NAME
</cfquery>
<cfif isdefined('attributes.is_submitted')>
	<cfquery name="get_count_operations" datasource="#dsn3#">
    	SELECT 
        	EW.EZGI_WM_COUNT_ID, 
            EW.PROCESS_DATE, 
            EW.PROCESS_NUMBER, 
            P.BARCOD AS PRODUCT_BARCODE, 
            P.PRODUCT_NAME, 
            P.PRODUCT_ID, 
            P.PRODUCT_CODE, 
            EWR.SERIAL_NO, 
            EWR.DEPO,
            EWD.DEPO_NAME, 
            EWR.SPECT_ID, 
            EWR.PALET_BARCODE, 
            EWR.SHELF_CODE, 
            ISNULL(EWR.IS_CONTROL,0) AS IS_CONTROL, 
            EWR.IS_LOST_ITEM,
            EWR.CONTROL_EMP, 
            EWR.CONTROL_DATE
		FROM     
        	EZGI_WM_COUNT_SERIAL_ROW AS EWR WITH (NOLOCK) INNER JOIN
            EZGI_WM_COUNT AS EW WITH (NOLOCK) ON EWR.WM_COUNT_ID = EW.EZGI_WM_COUNT_ID INNER JOIN
            #dsn1_alias#.PRODUCT AS P WITH (NOLOCK) INNER JOIN
          	#dsn1_alias#.STOCKS AS S WITH (NOLOCK) ON P.PRODUCT_ID = S.PRODUCT_ID ON EWR.STOCK_ID = S.STOCK_ID INNER JOIN
          	EZGI_WM_DEPARTMENTS AS EWD ON EWR.DEPO = EWD.DEPO
		WHERE  
        	EW.EZGI_WM_COUNT_ID = #attributes.count_id#
            <cfif len(attributes.keyword)>
            	AND (P.PRODUCT_CODE LIKE '%#attributes.keyword#%' OR P.PRODUCT_NAME LIKE '%#attributes.keyword#%')
            </cfif>
            <cfif len(attributes.keyword_0)>
            	AND EWR.SERIAL_NO LIKE '%#attributes.keyword_0#%'
            </cfif>
            <cfif len(attributes.keyword_1)>
            	AND EWR.PALET_BARCODE LIKE '%#attributes.keyword_1#%'
            </cfif>
            <cfif len(attributes.keyword_2)>
            	AND EWR.SHELF_CODE LIKE '%#attributes.keyword_2#%'
            </cfif>
            <cfif len(attributes.depo)>
            	AND EWR.DEPO = '#attributes.depo#'
            </cfif>
            <cfif len(attributes.status)>
            	AND ISNULL(EWR.IS_CONTROL,0) = #attributes.status#
            </cfif>
     	ORDER BY
        	EWD.DEPO_NAME,
            EWR.SHELF_CODE,
            EWR.PALET_BARCODE,
            EWR.SERIAL_NO
    </cfquery>
    <cfset arama_yapilmali = 0>
<cfelse>
	<cfset get_count_operations.recordcount =0>
    <cfset arama_yapilmali = 1>
</cfif>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_count_operations.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="list_stock_count" action="#request.self#?fuseaction=#attributes.fuseaction#" method="post">
        	<input type="hidden" name="is_submitted" id="is_submitted" value="1">
           	<cfinput type="hidden" name="count_id" value="#attributes.count_id#"> 
            <cf_box_search>
				<cfsavecontent variable="filter"><cf_get_lang dictionary_id='58800.Ürün Kodu'>, <cf_get_lang dictionary_id='58221.Ürün Adı'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group medium">
                	<select name="depo" id="depo">
               			<option value=""><cf_get_lang dictionary_id="57734.Seçiniz"></option>
                       	<cfoutput query="GET_DEPO">
                          	<option value="#DEPO#" <cfif GET_DEPO.DEPO eq attributes.depo>selected</cfif>>#DEPO_NAME#</option>
                      	</cfoutput>
                 	</select> 
              	</div>
                <cfsavecontent variable="filter"><cf_get_lang dictionary_id='1361.Raf Barkodu'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" placeholder="#filter#" maxlength="50" name="keyword_2" value="#attributes.keyword_2#">
               	</div>
                <cfsavecontent variable="filter"><cf_get_lang dictionary_id='1312.Palet Barkodu'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" placeholder="#filter#" maxlength="50" name="keyword_1" value="#attributes.keyword_1#">
               	</div>
                <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57637.Seri No'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" placeholder="#filter#" maxlength="50" name="keyword_0" value="#attributes.keyword_0#">
               	</div>
                <div class="form-group medium">
                	<select name="status" id="status" style="width:100px;">
                  		<option value="" <cfif attributes.status eq ''>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                   		<option value="1" <cfif attributes.status eq 1>selected</cfif>><cf_get_lang dictionary_id='54680.Sayılan'></option>
                   		<option value="0" <cfif attributes.status eq 0>selected</cfif>><cf_get_lang dictionary_id='54681.Sayılmayan'></option>
                	</select>
              	</div>
                <div class="form-group">
                    <input type="checkbox" name="is_excel" id="is_excel" value="1" <cfif attributes.is_excel eq 1>checked</cfif>><cf_get_lang dictionary_id='57858.Excel Getir'> 
                </div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,250" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="4" style="width:35px;">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="1">
                </div>
          	</cf_box_search>
      	</cfform>
    </cf_box>
    <cfif isdefined("attributes.is_excel") and attributes.is_excel eq 1>
		<cfset filename= "#dateformat(now(),'ddmmyyyy')##timeformat(now(),'hhmm')#">
        <cfheader name="Expires" value="#Now()#">
      <cfcontent type="application/vnd.msexcel;charset=utf-16">
        <cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
        <meta http-equiv="Content-Type" content="text/html; charset=utf-16">
        <cfset attributes.startrow=1>
        <cfset attributes.maxrows =attributes.totalrecords>
	</cfif>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='1365.WM - Dönem Bazlı Sayım Raporu'></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>
        	<thead>
            	<tr>
                	<th width="20"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th><cf_get_lang dictionary_id='58763.Depo'></th>
                    <th><cf_get_lang dictionary_id='1361.Raf Barkodu'></th>
                    <th><cf_get_lang dictionary_id='1312.Palet Barkodu'></th>
                    <th><cf_get_lang dictionary_id='57637.Seri No'></th>
                    <th><cf_get_lang dictionary_id='58800.Ürün Kodu'></th>
                    <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                    <th><cf_get_lang dictionary_id='57576.Çalışan'></th>
                    <th><cf_get_lang dictionary_id='57742.Tarih'> - <cf_get_lang dictionary_id='57491.Saat'></th>
                   <th width="20" class="header_icn_none"><cf_get_lang dictionary_id='63875.Sayım'></th>
              	</tr>
         	</thead>
          	<tbody>
            	<cfif get_count_operations.recordcount>
                    <cfoutput query="get_count_operations" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                        <tr height="25px">
                            <td style="text-align:right">#currentrow#</td>
                            <td style="text-align:left">#DEPO_NAME#</td>
                            <td style="text-align:center">#SHELF_CODE#</td>
                            <td style="text-align:center">#PALET_BARCODE#</td>
                            <td style="text-align:center">#SERIAL_NO#</td>
                            <td style="text-align:center" nowrap>#PRODUCT_CODE#</td>
                            <td style="text-align:left">#PRODUCT_NAME#</td>
                            <td style="text-align:left">#get_emp_info(CONTROL_EMP,0,0)#</td>
                            <td style="text-align:center" nowrap><cfif len(CONTROL_DATE)>#DateFormat(DateAdd('h',session.ep.time_zone,CONTROL_DATE),dateformat_style)# #TimeFormat(DateAdd('h',session.ep.time_zone,CONTROL_DATE),'HH:MM')#</cfif></td>
                            <td style="text-align:center; width:25px">
								<cfif IS_CONTROL eq 1>
                                	<img src="images/c_ok.gif" title="<cf_get_lang dictionary_id='54680.Sayılan'>" alt="<cf_get_lang dictionary_id='54680.Sayılan'>">
                                <cfelse>
                                	<img src="images/b_ok.gif" title="<cf_get_lang dictionary_id='54681.Sayılmayan'>" alt="<cf_get_lang dictionary_id='54681.Sayılmayan'>">
                                </cfif>
                          	</td>
                        </tr>
                    </cfoutput>
            	<cfelse>
               		<tr> 
                    	<td colspan="10" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
                 	</tr>
             	</cfif>
         	</tbody>
      	</cf_grid_list>
        <cfset adres = url.fuseaction>
        <cfset adres = "#adres#&count_id=#attributes.count_id#">
        <cfif len(attributes.keyword)>
        	<cfset adres = "#adres#&keyword=#attributes.keyword#">
        </cfif>
        <cfif len(attributes.keyword_0)>
        	<cfset adres = "#adres#&keyword_0=#attributes.keyword_0#">
        </cfif>
        <cfif len(attributes.keyword_1)>
        	<cfset adres = "#adres#&keyword_1=#attributes.keyword_1#">
        </cfif>
        <cfif len(attributes.keyword_2)>
        	<cfset adres = "#adres#&keyword_2=#attributes.keyword_2#">
        </cfif>
        <cfif len(attributes.status)>
        	<cfset adres = "#adres#&status=#attributes.status#">
        </cfif>
        <cfif len(attributes.depo)>
        	<cfset adres = "#adres#&depo=#attributes.depo#">
        </cfif>
        <cf_paging 
            page="#attributes.page#"
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#adres#&is_submitted=1">
    </cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		if(document.quality_control.is_excel.checked==false)
			return true;
	}
</script>