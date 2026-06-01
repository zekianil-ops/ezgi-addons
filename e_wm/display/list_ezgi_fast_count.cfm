<!---
    File: list_ezgi_fast_count.cfm
    Folder: Add_Ons\ezgi\e_wm\display
    Author: Ezgi Yazılım
    Date: 01/12/2025
    Description: Adres Sorgulama
---> 
<cfset fuseaction_ = ListGetAt(attributes.fuseaction,2,'.')>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.list_type" default="2">
<cfparam name="attributes.shelf_type" default="">
<cfparam name="attributes.department_id" default="">
<cfquery name="get_shelf_type" datasource="#dsn#">
	SELECT SHELF_ID, SHELF_NAME FROM SHELF
</cfquery>

<cfquery name="GET_DEPARTMENT" datasource="#DSN3#">
	SELECT        
    	DEPARTMENT_ID, 
        LOCATION_ID, 
        DEPARTMENT_HEAD, 
        COMMENT, 
        DEPO_NAME, 
        DEPO
	FROM            
    	EZGI_WM_DEPARTMENTS
	WHERE        
    	COMPANY_ID = 1 AND 
        DEPO IN
             	(
                	SELECT        
                    	CAST(STORE_ID AS VARCHAR) + '-' + CAST(LOCATION_ID AS VARCHAR) AS DEPO
                	FROM            
                    	PRODUCT_PLACE
                  	WHERE        
                    	PLACE_STATUS = 1
                	GROUP BY 
                    	CAST(STORE_ID AS VARCHAR) + '-' + CAST(LOCATION_ID AS VARCHAR)
             	)
   	ORDER BY
    	DEPO
</cfquery>

<cfparam name="attributes.page" default=1>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
	  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<cfscript>
	get_fast_count.recordcount=0;
	get_fast_count.query_count=0;
	if (isdefined("attributes.is_submitted"))
	{
		get_fast_count_list_action = createObject("component", "addOns.ezgi.cfc.get_ezgi_fast_count");
		get_fast_count_list_action.dsn3 = dsn3;
		get_fast_count_list_action.dsn_alias = dsn_alias;
		get_fast_count = get_fast_count_list_action.get_fast_count_
		(
		 	dsn_alias : '#dsn_alias#',
			list_type : '#iif(isdefined("attributes.list_type"),"attributes.list_type",DE(""))#',
			shelf_type : '#iif(isdefined("attributes.shelf_type"),"attributes.shelf_type",DE(""))#',
			keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
		 	startrow : '#iif(isdefined("attributes.startrow"),"attributes.startrow",DE(""))#',
			maxrows : '#iif(isdefined("attributes.maxrows"),"attributes.maxrows",DE(""))#',
			department_id : '#iif(isdefined("attributes.department_id"),"attributes.department_id",DE(""))#'
		);
		arama_yapilmali=0;
		}
	else
	{
		arama_yapilmali=1;
	}
</cfscript>
<cfparam name="attributes.totalrecords" default='#get_fast_count.query_count#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search_list" action="#request.self#?fuseaction=stock.list_ezgi_fast_count" method="post">
        	<input type="hidden" name="is_submitted" id="is_submitted" value="1">
            <cf_box_search>
				<cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group medium">
                	<select name="list_type" id="list_type" style="width:100px;">
                  		<option value="1" <cfif attributes.list_type eq 1>selected</cfif>>Raf Doğrulama Emirleri</option>
                   		<option value="2" <cfif attributes.list_type eq 2>selected</cfif>>Doğrulama İşlemleri</option>
                	</select>
              	</div>

                <div class="form-group medium">
                	<select name="shelf_type" id="shelf_type" style="width:100px;">
                  		<option value="" <cfif attributes.shelf_type eq ''>selected</cfif>>Raf Tipi</option>
						<cfoutput query="get_shelf_type">
                         	<option value="#SHELF_ID#" <cfif attributes.shelf_type eq SHELF_ID>selected</cfif>>#SHELF_NAME#</option>
                      	</cfoutput>
                	</select>
              	</div>
                <div class="form-group">
                	<select name="department_id" style="width:145px;">
                    	<option value=""<cfif attributes.department_id eq ''> selected</cfif>><cf_get_lang dictionary_id="57734.Seçiniz"></option>
						<cfoutput query="get_department">
							<option value="#depo#" <cfif attributes.department_id eq depo>selected</cfif>>#DEPO_NAME#</option>
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
    </cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='1386.raf Doğrulama'></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>
        	<thead>
            	<tr>
                	<th width="20"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th style="width:70px;"><cfif attributes.list_type eq 2><cf_get_lang dictionary_id='57742.Tarih'><cfelse>Son Kontrol</cfif></th>
                    <th style="width:180px;"><cf_get_lang dictionary_id='58763.Depo'></th>
                    <th style="width:70px;"><cf_get_lang dictionary_id='45254.Raf No'></th>
                    <th><cf_get_lang dictionary_id='57880.Belge No'></th>
                     <!-- sil -->
                    <th style="width:20px" class="header_icn_none">
                      	<a href="<cfoutput>#request.self#?fuseaction=stock.list_ezgi_fast_count&event=add</cfoutput>"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
            		</th>
                   	<!-- sil -->
              	</tr>
         	</thead>
          	<tbody>
            	<cfif get_fast_count.recordcount>
                    <cfoutput query="get_fast_count">
                        <tr height="25px">
                            <td style="text-align:right">#currentrow#</td>
                            <td style="text-align:center">
                            	<cfif attributes.list_type eq 2>
                                	#DateFormat(PROCESS_DATE,dateformat_style)#
                               	<cfelse>
                                	<cfif len(GUN_FARKI)>
                                		#DateFormat(DateAdd('d',GUN_FARKI,now()),dateformat_style)#
                                    <cfelse>
                                    	----
                                    </cfif>
                                </cfif>
                            </td>
                            <td style="text-align:left">#DEPO_NAME#</td>
                            <td style="text-align:center">
                            	<cfif attributes.list_type eq 2>
                            		<a href="#request.self#?fuseaction=stock.list_ezgi_fast_count&event=upd&fast_count_id=#EZGI_WM_FAST_COUNT_ID#" class="tableyazi">#SHELF_CODE#</a>
                              	<cfelse>
                                	<a href="#request.self#?fuseaction=stock.list_ezgi_fast_count&event=add&is_submitted=1&add_other_shelf=#SHELF_CODE#" class="tableyazi">#SHELF_CODE#</a>
                                </cfif>
                            </td>
							<td style="text-align:center"><cfif attributes.list_type eq 2>#PROCESS_NUMBER#</cfif></td>
                            <td style="text-align:center">
                            	<cfif attributes.list_type eq 2>
                                	<a href="#request.self#?fuseaction=stock.list_ezgi_fast_count&event=upd&fast_count_id=#EZGI_WM_FAST_COUNT_ID#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                        	 
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
        <cfif len(attributes.keyword)>
        	<cfset adres = "#adres#&keyword=#attributes.keyword#">
        </cfif>
        <cfif len(attributes.list_type)>
        	<cfset adres = "#adres#&list_type=#attributes.list_type#">
        </cfif>
        <cfif len(attributes.shelf_type)>
        	<cfset adres = "#adres#&shelf_type=#attributes.shelf_type#">
        </cfif>
        <cfif len(attributes.department_id)>
        	<cfset adres = "#adres#&department_id=#attributes.department_id#">
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