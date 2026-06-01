<!---
    File: list_ezgi_perioad_based_count_operations.cfm
    Folder: Add_Ons\ezgi\e-wm\display
    Author: Ezgi Yazılım
    Date: 01/02/2025
    Description:
--->
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.department_id" default="">
<cfparam name="attributes.position_code" default="">
<cfparam name="attributes.position_name" default="">
<cfparam name="attributes.status" default="2">
<cfif isdefined("is_branch")>
	<cfset branch_kontrol = "&is_branch=1">
<cfelse>
	<cfset branch_kontrol = "">
</cfif>
<cfif isdefined("attributes.date2") and isdate(attributes.date2)>
  	<cf_date tarih="attributes.date2">
  <cfelse>
  	<cfset attributes.date2 = wrk_get_today()>
</cfif>
<cfif isdefined("attributes.date1") and isdate(attributes.date1)>
  	<cf_date tarih="attributes.date1">
  <cfelse>
  	<cfset attributes.date1 = wrk_get_today()>
</cfif>


<cfquery name="get_branch_" datasource="#dsn#">
	SELECT 
		BRANCH_NAME,BRANCH_ID
	FROM
		BRANCH
	WHERE
		COMPANY_ID = #session.ep.company_id#
		AND BRANCH_STATUS = 1
        AND COMPANY_ID = #session.ep.company_id#
        AND BRANCH_ID IN
			(
                SELECT 
					BRANCH_ID 
				 FROM  
					EMPLOYEE_POSITION_BRANCHES 
				 WHERE 
					POSITION_CODE = #session.ep.position_code#
         	)
</cfquery>
<cfquery name="GET_DEPARTMENT" datasource="#DSN#">
	SELECT
		DEPARTMENT_ID,
		DEPARTMENT_HEAD
	FROM
		BRANCH B,
		DEPARTMENT D 
	WHERE
		B.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		B.BRANCH_ID = D.BRANCH_ID AND
		D.IS_STORE <> 2
		AND D.DEPARTMENT_STATUS = 1 
	ORDER BY
		DEPARTMENT_HEAD
</cfquery>
<cfset branch_dep_list=valuelist(get_department.department_id,',')>
<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT * FROM STOCKS_LOCATION WHERE STATUS = 1
</cfquery>
<cfset branch_dep_list=valuelist(get_department.department_id,',')>
<cfif isdefined('attributes.is_submitted')>
	<cfquery name="get_count_operations" datasource="#dsn3#">
    	SELECT 
        	EZGI_WM_COUNT_ID, 
            PROCESS_DATE, 
            PROCESS_NUMBER,
            DEPARTMENT_ID, 
            LOCATION_ID, 
            RECORD_EMP,
            RECORD_DATE,
            ISNULL((SELECT COUNT (*) AS PAKET_AMOUNT FROM EZGI_WM_COUNT_SERIAL_ROW WHERE WM_COUNT_ID = EZGI_WM_COUNT.EZGI_WM_COUNT_ID),0) AS PAKET_AMOUNT,
            ISNULL((SELECT COUNT (*) AS PALET_AMOUNT FROM EZGI_WM_COUNT_PACKING_ROW WHERE WM_COUNT_ID = EZGI_WM_COUNT.EZGI_WM_COUNT_ID),0) AS PALET_AMOUNT
		FROM     
        	EZGI_WM_COUNT
      	WHERE
        	1=1
            <cfif isdefined("attributes.date1") and len(attributes.date1)>
        		AND PROCESS_DATE > #attributes.date1#	
            </cfif>
            <cfif isdefined("attributes.date2") and len(attributes.date2)>
            	AND PROCESS_DATE < #DateAdd('d',1,attributes.date2)#
            </cfif>
            <cfif len(attributes.keyword)>
            	AND PROCESS_NUMBER LIKE '%attributes.keywor%'
            </cfif>
            <cfif isDefined("attributes.position_code") and len(attributes.position_code) and isDefined("attributes.position_name") and len(attributes.position_name)>
                AND RECORD_EMP = #attributes.position_code#
            </cfif>
            <cfif attributes.status eq 2>
            	AND STATUS = 1
            <cfelseif attributes.status eq 3>
            	AND STATUS = 0
            </cfif>
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
            <cf_box_search>
				<cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group">
                 	<div class="input-group">
                     	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                      	<cfinput type="text" maxlength="10" name="date1" value="#dateformat(attributes.date1,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                      	<span class="input-group-addon"><cf_wrk_date_image date_field="date1"></span>
                  	</div>
                  	<div class="input-group">
                     	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                     	<cfinput type="text" maxlength="10" name="date2" value="#dateformat(attributes.date2,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                    	<span class="input-group-addon"><cf_wrk_date_image date_field="date2"></span>
               		</div>
               	</div>
                <div class="form-group">
					<div class="input-group">
						<input type="hidden" name="position_code" id="position_code" maxlength="50" value="<cfif isdefined("attributes.position_code") and len(attributes.position_code) and isDefined("attributes.position_name") and len(attributes.position_name)><cfoutput>#attributes.position_code#</cfoutput></cfif>">
						<input type="text" name="position_name" id="position_name"  placeholder="<cfoutput>#getLang('main',487)#</cfoutput>" value="<cfif isdefined("attributes.position_code") and len(attributes.position_code) and isDefined("attributes.position_name") and len(attributes.position_name)><cfoutput>#attributes.position_name#</cfoutput></cfif>" style="width:100px;">
						<span class="input-group-addon btnPointer icon-ellipsis" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=stock.popup_list_positions&field_emp_id=list_stock_count.position_code&field_name=list_stock_count.position_name&select_list=1&branch_related','list','popup_list_positions')"></span> 
					</div>
				</div>
                <div class="form-group medium">
                	<select name="status" id="status" style="width:100px;">
                  		<option value="1" <cfif attributes.status eq 1>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                   		<option value="2" <cfif attributes.status eq 2>selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                   		<option value="3" <cfif attributes.status eq 3>selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                	</select>
              	</div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
          	</cf_box_search>
      	</cfform>
    </cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='1357.WM - Dönem Bazlı Sayım İşlemleri'></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>
        	<thead>
            	<tr>
                	<th width="20"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th><cf_get_lang dictionary_id='57880.Belge No'></th>
                    <th><cf_get_lang dictionary_id='34435.Dönemi'></th>
                    
                    <th><cf_get_lang dictionary_id='1306.Palet Miktarı'></th>
                    <th><cf_get_lang dictionary_id='48888.Paket Miktarı'></th>
                    
                    <th><cf_get_lang dictionary_id='49250.Kayıt Yapan'></th>
                    <th><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></th>
                    
                    <!-- sil -->
                   <th width="20" class="header_icn_none">
                   	<a href="javascript://" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=stock.popup_add_ezgi_period_based_count_operations</cfoutput>');">
                    	<i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i>
                   	</a>
                    </th>
                   	<!-- sil -->
              	</tr>
         	</thead>
          	<tbody>
            	<cfif get_count_operations.recordcount>
                    <cfoutput query="get_count_operations">
                        <tr height="25px">
                            <td style="text-align:right">#currentrow#</td>
                            <td style="text-align:center">
                            	<a href="#request.self#?fuseaction=stock.list_ezgi_perioad_based_count_operations&event=upd&count_id=#EZGI_WM_COUNT_ID#" class="tableyazi">
                            		#PROCESS_NUMBER#
                            	</a>
                            </td>
                            <td style="text-align:center">#DateFormat(PROCESS_DATE,dateformat_style)#</td>
                            
                            <td style="text-align:center">#AmountFormat(PALET_AMOUNT)#</td>
                            <td style="text-align:center">#AmountFormat(PAKET_AMOUNT)#</td>
                            
                            <td style="text-align:left">#get_emp_info(RECORD_EMP,0,0)#</td>
                            <td style="text-align:center">#DateFormat(RECORD_DATE,dateformat_style)# #TimeFormat(RECORD_DATE,'hh:mm')#</td>
                            <!-- sil -->
                            <td style="text-align:center; width:25px">
                                <a href="javascript://" onClick="window.location ='#request.self#?fuseaction=stock.list_ezgi_perioad_based_count_operations&event=upd&count_id=#EZGI_WM_COUNT_ID#';">
                                	<i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i>
                              	</a>
                          	</td>
                            <!-- sil -->
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
        <cfif len(attributes.keyword)>
        	<cfset adres = "#adres#&keyword=#attributes.keyword#">
        </cfif>
        <cfif len(attributes.status)>
        	<cfset adres = "#adres#&status=#attributes.status#">
        </cfif>
        <cfif len(attributes.date1)>
        	<cfset adres = "#adres#&date1=#attributes.date1#">
        </cfif>
        <cfif len(attributes.date2)>
        	<cfset adres = "#adres#&date2=#attributes.date2#">
        </cfif>
        <cfif len(attributes.position_code)>
        	<cfset adres = "#adres#&position_code=#attributes.position_code#">
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
		return true;
	}
</script>