<!---
    File: list_ezgi_iflow_wastage_tracking.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.record_emp_id" default="">
<cfparam name="attributes.record_emp_name" default="">
<cfparam name="attributes.record_date1" default="">
<cfparam name="attributes.record_date2" default="">
<cfparam name="attributes.oby" default="1">
<cfparam name="attributes.process_stage" default="">
<cfparam name="attributes.wastage_tracking_status" default="1">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.shift_id" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.price_cat" default="-1">
<cfparam name="attributes.list_type" default="1">

<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfif isdefined("attributes.date1") and isdate(attributes.date1)>
	<cf_date tarih = "attributes.date1">
<cfelse>	
	<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
		<cfset attributes.date1 = ''>
	<cfelse>
		<cfset attributes.date1 = session.ep.period_start_date>
	</cfif>
</cfif>

<cfif isdefined("attributes.date2") and isdate(attributes.date2)>
	<cf_date tarih = "attributes.date2">
<cfelse>	
	<cfif session.ep.our_company_info.UNCONDITIONAL_LIST>
		<cfset attributes.date2 = ''>
	<cfelse>
		<cfset attributes.date2 = session.ep.period_finish_date>
	</cfif>
</cfif>
<cfset type = "">
<cfset genel_bakiye = 0>
<cfscript>
	get_ezgi_iflow_wastage_tracking.recordcount=0;
	get_ezgi_iflow_wastage_tracking.query_count=0;
	if (isdefined("attributes.is_submitted"))
	{
		get_ezgi_iflow_wastage_tracking_action = createObject("component", "addOns.ezgi.cfc.get_ezgi_iflow_wastage_tracking");
		get_ezgi_iflow_wastage_tracking_action.dsn3 = dsn3;
		get_ezgi_iflow_wastage_tracking = get_ezgi_iflow_wastage_tracking_action.get_ezgi_iflow_wastage_tracking_
		(
		 	keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
			record_emp_id : '#IIf(IsDefined("attributes.record_emp_id"),"attributes.record_emp_id",DE(""))#',
			record_emp_name : '#iif(isdefined("attributes.record_emp_name"),"attributes.record_emp_name",DE(""))#',
			record_date1 : '#iif(isdefined("attributes.record_date1"),"attributes.record_date1",DE(""))#',
			record_date2 : '#iif(isdefined("attributes.record_date2"),"attributes.record_date2",DE(""))#',
			date1 : '#iif(isdefined("attributes.date1"),"attributes.date1",DE(""))#',
			date2 : '#iif(isdefined("attributes.date2"),"attributes.date2",DE(""))#',
		 	oby : '#iif(isdefined("attributes.oby"),"attributes.oby",DE(""))#',
			list_type : '#iif(isdefined("attributes.list_type"),"attributes.list_type",DE(""))#',
			wastage_tracking_status : '#IIf(IsDefined("attributes.wastage_tracking_status"),"attributes.wastage_tracking_status",DE(""))#',
			process_stage : '#iif(isdefined("attributes.process_stage"),"attributes.process_stage",DE(""))#',
			shift_id : '#IIf(IsDefined("attributes.shift_id"),"attributes.shift_id",DE(""))#',
		 	startrow : '#iif(isdefined("attributes.startrow"),"attributes.startrow",DE(""))#',
			maxrows : '#iif(isdefined("attributes.maxrows"),"attributes.maxrows",DE(""))#'
		);
		arama_yapilmali=0;
		}
	else
	{
		arama_yapilmali=1;
	}
</cfscript>
<cfif isdefined("attributes.is_submitted")>
	<cfif get_ezgi_iflow_wastage_tracking.recordcount>
    	<cfset wastage_tracking_list = ValueList(get_ezgi_iflow_wastage_tracking.PRODUCTION_WASTAGE_ID)>
        <cfif isDefined("attributes.list_type") and attributes.list_type eq 2>
        	<cfset raw_stock_list = ValueList(get_ezgi_iflow_wastage_tracking.RAW_STOCK_ID)>
        	<cfset raw_stock_list = ListDeleteDuplicates(raw_stock_list,',')>
			<!--- ÜRÜN FİYATLAR --->
            <cfquery name="GET_PRICE" datasource="#DSN3#">
                SELECT
                    P.MONEY,
                    P.PRICE,
                    S.STOCK_ID
                FROM
                    <cfif attributes.price_cat eq -1>
                        PRICE_STANDART P WITH (NOLOCK),
                    <cfelse>
                        PRICE P WITH (NOLOCK),
                    </cfif>
                    STOCKS S WITH (NOLOCK)  
                WHERE
                    S.PRODUCT_ID = P.PRODUCT_ID AND
                    S.STOCK_ID IN (#raw_stock_list#) AND
                    <cfif attributes.price_cat eq -1>
                        P.PRICESTANDART_STATUS = 1 AND
                        P.PURCHASESALES = 0
                    <cfelse>
                        ISNULL(P.STOCK_ID,0)=0 AND
                        ISNULL(P.SPECT_VAR_ID,0)=0 AND
                        P.STARTDATE <= #now()# AND
                        (P.FINISHDATE >= #now()# OR P.FINISHDATE IS NULL) AND
                        P.PRICE_CATID = #attributes.price_cat#
                    </cfif>
            </cfquery>
            <cfoutput query="GET_PRICE">
                <cfset 'PRICE_#STOCK_ID#'=PRICE>
                <cfset 'MONEY_#STOCK_ID#'=MONEY> 
            </cfoutput> 
        </cfif>
  	</cfif>
</cfif>
<cfquery name="get_shift" datasource="#dsn#">
	SELECT        
    	SHIFT_ID, 
        SHIFT_NAME, 
        BRANCH_ID
	FROM            
    	SETUP_SHIFTS WITH (NOLOCK)
	WHERE        
    	IS_PRODUCTION = 1 AND 
        BRANCH_ID IN
        			(
                    	SELECT 
    						BRANCH_ID
                        FROM 
                            BRANCH 
                        WHERE
                            COMPANY_ID = #session.ep.COMPANY_ID# AND	
                            BRANCH_ID IN (SELECT BRANCH_ID FROM EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">)
                    )
  	ORDER BY
    	SHIFT_NAME
    
</cfquery>
<cfquery name="GET_PROCESS_TYPE" datasource="#DSN#">
	SELECT
		PTR.STAGE,
		PTR.PROCESS_ROW_ID 
	FROM
		PROCESS_TYPE_ROWS PTR WITH (NOLOCK),
		PROCESS_TYPE_OUR_COMPANY PTO WITH (NOLOCK),
		PROCESS_TYPE PT WITH (NOLOCK)
	WHERE
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%wastage_tracking%">
</cfquery>
<cfparam name="attributes.totalrecords" default='#get_ezgi_iflow_wastage_tracking.query_count#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search_form" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
			<input name="is_submitted" id="is_submitted" type="hidden" value="1">
            <cf_box_search>
                <div class="form-group"  id="item-keyword">
                    <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group medium" id="item-list_type">
                	<select name="list_type" style="width:120px; height:20px">
                     	<option value="1" <cfif attributes.list_type eq 1>selected</cfif>><cf_get_lang dictionary_id='51072.Üretim Talebi Oluştur'></option>
                      	<option value="2" <cfif attributes.list_type eq 2>selected</cfif>><cf_get_lang dictionary_id='51120.İç Talep Oluştur'></option>
                  	</select>
               	</div>
                <div class="form-group medium" id="item-oby">
                	<select name="oby" style="width:120px; height:20px">
                     	<option value="1" <cfif attributes.oby eq 1>selected</cfif>><cf_get_lang dictionary_id='57926.Azalan Tarih'></option>
                      	<option value="2" <cfif attributes.oby eq 2>selected</cfif>><cf_get_lang dictionary_id='57925.Artan Tarih'></option>
                  	</select>
               	</div>
                <div class="form-group medium" id="item-shift_id">
                	<select name="shift_id" style="width:150px; height:20px">
						<cfoutput query="get_shift">
							<option value="#SHIFT_ID#"<cfif isdefined('attributes.shift_id') and attributes.shift_id eq SHIFT_ID>selected</cfif>>#SHIFT_NAME#</option>
						</cfoutput>
					</select>
               	</div>
                <div class="form-group medium" id="item-wastage_tracking_status">
                	<select name="wastage_tracking_status" style="width:80px; height:20px">
                    	<option value=""><cf_get_lang dictionary_id='57708 .Tümü'></option>
                      	<option value="1"<cfif isDefined("attributes.wastage_tracking_status") and (attributes.wastage_tracking_status eq 1)> selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                      	<option value="0"<cfif isDefined("attributes.wastage_tracking_status") and (attributes.wastage_tracking_status eq 0)> selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                  	</select>
               	</div>
                <div class="form-group" id="item-start_date">
					<div class="input-group x-14">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></cfsavecontent>
						<cfinput type="text" name="date1" placeholder="#message#" value="#dateformat(attributes.date1, dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10">
						<span class="input-group-addon"><cf_wrk_date_image date_field="date1"></span>
					</div>
				</div>		
				<div class="form-group" id="item-finish_date">
					<div class="input-group x-14">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></cfsavecontent>
						<cfinput type="text" name="date2" placeholder="#message#" value="#dateformat(attributes.date2, dateformat_style)#" style="width:65px;" validate="#validate_style#" maxlength="10">
						<span class="input-group-addon"><cf_wrk_date_image date_field="date2"></span>
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
                    	<div class="col col-10">
                       		<div class="form-group medium">
                        		<div class="input-group">
                                        <input type="hidden" name="record_emp_id" id="record_emp_id" value="<cfif len(attributes.record_emp_id)><cfoutput>#attributes.record_emp_id#</cfoutput></cfif>">
                                        <input name="record_emp_name" type="text" id="record_emp_name" style="width:120px;" placeholder="<cf_get_lang dictionary_id='57899.Kaydeden'>" onFocus="AutoComplete_Create('record_emp_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','record_emp_id','search_form','3','125');" value="<cfif len(attributes.record_emp_name)><cfoutput>#attributes.record_emp_name#</cfoutput> </cfif>" autocomplete="off">
                                        <span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_name=search_form.record_emp_name&field_emp_id=search_form.record_emp_id<cfif fusebox.circuit is "store">&is_store_module=1</cfif>&select_list=1,9','list');return false"></span>
                                </div>
                            </div>
                       	</div>
                   	</div>
                  	<div class="col col-3">
                    	<div class="col col-12">	
                        	<div class="form-group medium">
                            	<div class="col col-2">
                                	<label><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></label>
                                </div>
                                <div class="col col-4">
                                    <div class="input-group">
                                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                                        <cfinput type="text" maxlength="10" name="record_date1" value="#dateformat(attributes.record_date1,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="record_date1"></span>
                                    </div>
                               </div>
                               <div class="col col-4"> 
                                    <div class="input-group">
                                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                                        <cfinput type="text" maxlength="10" name="record_date2" value="#dateformat(attributes.record_date2,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="record_date2"></span>
                                    </div>
                             	</div>  
                          	</div>
                       	</div>
                  	</div>
             	</div>
        	</cf_box_search_detail> 
     	</cfform>

      	<cfsavecontent variable="title"><cf_get_lang dictionary_id="1301.Fire Takip"></cfsavecontent>
   		<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1" right_images="">
      		<cf_grid_list>   
		    	<thead>
                    <tr valign="middle">
                    	<th style="width:25px; text-align:center"><cf_get_lang dictionary_id='57487.No'></th>
                   		<th style="text-align:center"><cf_get_lang dictionary_id='57880.Belge No'></th>
                      	<th style="text-align:center"><cf_get_lang dictionary_id='41701.Lot No'></th>
                      	<th style="text-align:center"><cf_get_lang dictionary_id='29474.Emir No'></th>
                       	<th style="text-align:center"><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></th>
                       	<th style="text-align:center"><cf_get_lang dictionary_id='38050.Üretilen Ürün Adı'></th>
                      	<th style="text-align:center"><cf_get_lang dictionary_id='1135.Operasyon Türü'></th>
                       	<th style="text-align:center"><cf_get_lang dictionary_id='58834.İstasyon'></th>
                      	<th style="text-align:center"><cf_get_lang dictionary_id='57576.Çalışan'></th>
                    	<cfif attributes.list_type eq 1>
                            <th style="text-align:center"><cf_get_lang dictionary_id='320.Fire Sebebi'></th>
                            <th style="text-align:center"><cf_get_lang dictionary_id='137.Fire Miktarı'></th>
                            <th style="text-align:center"><cf_get_lang dictionary_id='57629.Açıklama'></th>
                            <th style="text-align:center"><cf_get_lang dictionary_id='36388.Üretim Talebi'></th>
                        <cfelse>
                        	<th style="text-align:center"><cf_get_lang dictionary_id='137.Fire Miktarı'></th>
                            <th style="text-align:center"><cf_get_lang dictionary_id='57636.Birim'></th>
                            <th style="text-align:center"><cf_get_lang dictionary_id='58800.Ürün Kodu'></th>
                            <th style="text-align:center"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                            <th style="text-align:center"><cf_get_lang dictionary_id='58798.İç Talep'></th>
                        </cfif>
                        
                        <!-- sil -->
                        <th style="text-align:center"><cf_get_lang dictionary_id='36437.İhtiyaç'></th>
                        <th style="width:20px; text-align:center; vertical-align:middle" class="header_icn_none" >
                            <input type="checkbox" name="all_conv_product" id="all_conv_product" onClick="javascript: all_select_control('all_conv_product','_conversion_product_',<cfoutput>#get_ezgi_iflow_wastage_tracking.recordcount#</cfoutput>);">
                        </th>
                        <th style="width:25px; text-align:center"  class="header_icn_none"><a href="<cfoutput>#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.</cfoutput>list_ezgi_iflow_wastage_tracking&event=add"><img src="/images/plus_list.gif" style="text-align:center" title="<cf_get_lang dictionary_id='57582.Ekle'>" border="0"></a></th>
                        <!-- sil -->
                    </tr>
		        </thead>
		        <tbody>
					<cfif get_ezgi_iflow_wastage_tracking.recordcount>
                    	<cfform name="aktar_form" method="post">
                        <cfoutput query="get_ezgi_iflow_wastage_tracking">
                            <cfquery  name="GET_PROCESS" datasource="#dsn#">
                                SELECT STAGE,PROCESS_ROW_ID FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#WASTAGE_STAGE#">
                            </cfquery>
                            <tr>
                                <td style="text-align:right">#RowNum#</td>
                                <td style="text-align:center">
                                    <a href="#request.self#?fuseaction=prod.list_ezgi_iflow_wastage_tracking&event=upd&wastage_tracking_id=#PRODUCTION_WASTAGE_ID#"  class="tableyazi">
                                        #WASTAGE_NO#
                                    </a>
                                </td>
                                <td style="text-align:center">#LOT_NO#</td>
                                <td style="text-align:center">#P_ORDER_NO#</td>
                                <td style="text-align:center">#dateformat(WASTAGE_DATE,dateformat_style)#</td>
                                <td style="text-align:left">#PRODUCT_NAME#</td>
                                <td style="text-align:left">#OPERATION_TYPE#</td>
                                <td style="text-align:left">#STATION_NAME#</td>
                                <td style="text-align:left">
                                	<cfif Listlen(EMPLOYEE_IDS)>
                                    	<cfloop list="#EMPLOYEE_IDS#" index="mm">
                                        	#get_emp_info(mm,0,0)#, 
                                        </cfloop>
                                    </cfif>
                                </td>
                                <cfif attributes.list_type eq 1>
                                    <td style="text-align:left">#LOST_REASON_NAME#</td>
                                    <td style="text-align:right">#Tlformat(WASTAGE_AMOUNT,2)#</td>
                                    <td style="text-align:left">#DETAIL#</td>
                                    <td style="text-align:right">#AmountFormat(PRODUCTION_DEMAND_QUANTITY,4)#</td>
                                    <!-- sil -->
                                    <td style="text-align:right">
                                    	<cfset row_total_need = (round(WASTAGE_AMOUNT*10000)/10000)-(round(PRODUCTION_DEMAND_QUANTITY*10000)/10000)>
                                        <cfif row_total_need lte 0><cfset row_total_need = 0></cfif>
                                        <input type="text" name="row_total_need_#PRODUCTION_WASTAGE_ID#" id="row_total_need_#PRODUCTION_WASTAGE_ID#" value="#tlformat(row_total_need,4)#" class="box" style="width:60px;" onKeyup="return(FormatCurrency(this,event));">
                                    </td>
                                    <td style="text-align:center; background-color:<cfif IS_DEMAND neq 1>gainsboro</cfif>" title="<cfif IS_DEMAND eq 1>Yapılacak<cfelse>Yapılmayacak</cfif>">
                                        <cfif IS_DEMAND eq 1 and row_total_need gt 0>
                                        	<input type="checkbox" name="conversion_product_#PRODUCTION_WASTAGE_ID#" value="#PRODUCTION_WASTAGE_ID#" id="_conversion_product_#currentrow#">
                                        </cfif>
                                    </td>
                                    <td style="text-align:center">
                                        <a href="#request.self#?fuseaction=prod.list_ezgi_iflow_wastage_tracking&event=upd&wastage_tracking_id=#PRODUCTION_WASTAGE_ID#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                                    </td>
                                	<!-- sil -->
                                    <input type="hidden" name="PRODUCTION_WASTAGE_ID_list" id="PRODUCTION_WASTAGE_ID_list" value="#PRODUCTION_WASTAGE_ID#">
                                <cfelse>
                                	<cfif isdefined('PRICE_#RAW_STOCK_ID#')>
                                    	<cfset row_price = Evaluate('PRICE_#RAW_STOCK_ID#')>
                                      	<input type="hidden" name="row_price_unit_#PRODUCTION_WASTAGE_ROW_ID#" id="row_price_unit_#PRODUCTION_WASTAGE_ROW_ID#" value="#tlformat(row_price,2)#">
                                  	<cfelse>
                                   		<cfset row_price = 0>
                                      	<input type="hidden" name="row_price_unit_#PRODUCTION_WASTAGE_ROW_ID#" id="row_price_unit_#PRODUCTION_WASTAGE_ROW_ID#" value="#tlformat(0)#">
                                	</cfif>
                                    <cfif isdefined('MONEY_#RAW_STOCK_ID#')>
                                    	<input type="hidden" name="row_stock_money_#PRODUCTION_WASTAGE_ROW_ID#" id="row_stock_money_#PRODUCTION_WASTAGE_ROW_ID#" value="#Evaluate('MONEY_#RAW_STOCK_ID#')#" />
                                  	<cfelse>
                                     	<input type="hidden" name="row_stock_money_#PRODUCTION_WASTAGE_ROW_ID#" id="row_stock_money_#PRODUCTION_WASTAGE_ROW_ID#" value="#session.ep.money#" />
                                   	</cfif>
                                    <td style="text-align:right">#AmountFormat(RAW_AMOUNT,4)#</td>
                                    <td style="text-align:left">#RAW_MAIN_UNIT#</td>
                                    <td style="text-align:left">#RAW_PRODUCT_CODE#</td>
                                    <td style="text-align:left">#RAW_PRODUCT_NAME#</td>
                                    <td style="text-align:right">#AmountFormat(DEMAND_QUANTITY,4)#</td>
                                    <!-- sil -->
                                    <td style="text-align:right">
                                    	<cfset row_total_need = (round(RAW_AMOUNT*10000)/10000)-(round(DEMAND_QUANTITY*10000)/10000)>
                                        <cfif row_total_need lte 0><cfset row_total_need = 0></cfif>
                                        <input type="text" name="row_total_need_#PRODUCTION_WASTAGE_ROW_ID#" id="row_total_need_#PRODUCTION_WASTAGE_ROW_ID#" value="#tlformat(row_total_need,4)#" class="box" style="width:60px;" onKeyup="return(FormatCurrency(this,event));" onChange="hesapla('#PRODUCTION_WASTAGE_ROW_ID#');">
                                        <input type="hidden" name="row_price_#PRODUCTION_WASTAGE_ROW_ID#" id="row_price_#PRODUCTION_WASTAGE_ROW_ID#" value="#tlformat(row_total_need*row_price,4)#" class="box">
                                    </td>
                                    <td style="text-align:center;" title="<cfif IS_DEMAND eq 1>Yapılacak<cfelse>Yapılmayacak</cfif>">
                                    	<cfif row_total_need gt 0>
                                    		<input type="checkbox" name="conversion_product_#PRODUCTION_WASTAGE_ROW_ID#" value="#PRODUCTION_WASTAGE_ROW_ID#" id="_conversion_product_#currentrow#">
                                        </cfif>
                                    </td>
                                    <td style="text-align:center">
                                        <a href="#request.self#?fuseaction=prod.list_ezgi_iflow_wastage_tracking&event=upd&wastage_tracking_id=#PRODUCTION_WASTAGE_ID#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                                    </td>
                                    <input type="hidden" name="PRODUCTION_WASTAGE_ROW_ID_list" id="PRODUCTION_WASTAGE_ROW_ID_list" value="#PRODUCTION_WASTAGE_ROW_ID#">
                                </cfif>
                          	</tr>
                       	</cfoutput>
                        
                      	<cfoutput>
                      		<tfoot>
                                <tr  height="20">
                                	<td colspan="20">
                                    	<input type="hidden" name="list_type" value="#attributes.list_type#">
                                    	<table style="width:100%" bordercolor="gainsboro" border="1" cellpadding="2" cellspacing="0">
                                        	<tr>
                                                <!-- sil -->
                                                <cfif attributes.list_type eq 1>
                                                	<td style=" width:100px"><cf_get_lang dictionary_id='58859.Süreç'></td>
                                                    <td style=" width:150px"><cf_workcube_process is_upd='0' process_cat_width='125' is_detail='0' fusepath='prod.list_ezgi_e_planning'></td>
                                                    <td colspan="20" style="text-align:right">
                                                    
                                                    
                                                        <button type="button" name="production_button" id="production_button" onclick="secim(-2);" style="width:200px; height:30px; text-align:center;font-size:10px; font-weight:bold">
                                                            <img src="/images/forklift.gif" alt="<cf_get_lang dictionary_id='51072.Üretim Talebi Oluştur'>" border="0"><cf_get_lang dictionary_id='51072.Üretim Talebi Oluştur'>
                                                        </button>
                                                    </td>
                                                <cfelse>
                                                    <td style=" width:100px"><cf_get_lang dictionary_id='58859.Süreç'></td>
                                                    <td style=" width:150px"><cf_workcube_process is_upd='0' process_cat_width='125' is_detail='0' fusepath='purchase.list_internaldemand'></td>
                                                    <td style="text-align:right">	  	
                                                        <button type="button" name="material_button" id="material_button" onclick="secim(-3);" style="width:200px; height:30px; text-align:center;font-size:10px; font-weight:bold">
                                                            <img src="/images/forklift.gif" alt="<cf_get_lang dictionary_id='51120.İç Talep Oluştur'>" border="0"><cf_get_lang dictionary_id='51120.İç Talep Oluştur'>
                                                        </button>
                                                    </td>
                                                </cfif>
                                                <!-- sil -->
                                         	</tr>
                                      	</table>
                                  	</td>
                            	</tr>
                   			</tfoot>
                    	</cfoutput>
                        </cfform>
              		<cfelse>
                		<tr> 
                   			<td colspan="15" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
                 		</tr>
             		</cfif>
				</tbody>
			</cf_grid_list>
		    <cfset adres="prod.list_ezgi_iflow_wastage_tracking">
			<cfif isDefined('attributes.date1') and isdate(attributes.date1)>
		        <cfset adres = '#adres#&date1=#attributes.date1#'>
		    </cfif>
		    <cfif isDefined('attributes.date2') and isdate(attributes.date2)>
		        <cfset adres = '#adres#&date2=#attributes.date2#'>
		    </cfif>
		    <cfif isDefined('attributes.record_date1') and isdate(attributes.record_date1)>
		        <cfset adres = '#adres#&record_date1=#attributes.record_date1#'>
		    </cfif>
		    <cfif isDefined('attributes.record_date2') and isdate(attributes.record_date2)>
		        <cfset adres = '#adres#&record_date2=#attributes.record_date2#'>
		    </cfif>
		    <cfif isDefined("attributes.wastage_tracking_status") and len(attributes.wastage_tracking_status)>
		        <cfset adres = '#adres#&wastage_tracking_status=#attributes.wastage_tracking_status#'>
		    </cfif>
		    <cfif isDefined('attributes.keyword') and len(attributes.keyword)>
		        <cfset adres = '#adres#&keyword=#attributes.keyword#'>
		    </cfif>
		    <cfif isDefined('attributes.oby') and len(attributes.oby)>
		        <cfset adres = '#adres#&oby=#attributes.oby#'>
		    </cfif>
		    <cfif isdefined('attributes.process_stage') and len(attributes.process_stage)>
		        <cfset adres = '#adres#&process_stage=#attributes.process_stage#'>
		    </cfif>
            <cfif isdefined('attributes.list_type') and len(attributes.list_type)>
		        <cfset adres = '#adres#&list_type=#attributes.list_type#'>
		    </cfif>
		    <cfif isdefined('attributes.is_form_submitted') and len(attributes.is_form_submitted)>
		        <cfset adres = adres&"&is_submitted=1">
		    </cfif>
		    <cf_paging 
		        page="#attributes.page#"
		        maxrows="#attributes.maxrows#"
		        totalrecords="#attributes.totalrecords#"
		        startrow="#attributes.startrow#"
		        adres="#adres#&is_submitted=1">  
     	</cf_box>
		
   	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;	
	}
	function secim(type)
	{
		<cfif attributes.list_type eq 1>
			var convert_list ="";
			var convert_list_amount ="";
			<cfif isdefined("attributes.is_submitted")>
				 <cfoutput query="get_ezgi_iflow_wastage_tracking">
					<cfif get_ezgi_iflow_wastage_tracking.IS_DEMAND eq 1>
						<cfset row_total_need_ = (round(get_ezgi_iflow_wastage_tracking.WASTAGE_AMOUNT*10000)/10000)-(round(get_ezgi_iflow_wastage_tracking.PRODUCTION_DEMAND_QUANTITY*10000)/10000)>
						<cfif row_total_need_ gt 0>
							 if(document.all.conversion_product_#PRODUCTION_WASTAGE_ID#.checked && filterNum(document.getElementById('row_total_need_#PRODUCTION_WASTAGE_ID#').value) > 0)
							 {
								convert_list += "#PRODUCTION_WASTAGE_ID#,";
								convert_list_amount += filterNum(document.getElementById('row_total_need_#PRODUCTION_WASTAGE_ID#').value)+',';
							 }
						 </cfif>
					 </cfif>
				 </cfoutput>
			</cfif>
			if(convert_list)//Ürün Seçili ise
			{
				if(type==-2)
				{
					sor=confirm('<cf_get_lang dictionary_id='461.Seçilen Ürünler İçin Talep Oluşturulacaktır'>');
					if(sor==true)
					{
						if(process_cat_control())
						{
							document.getElementById('production_button').disabled=true;
							aktar_form.action="<cfoutput>#request.self#?fuseaction=prod.emptypopup_add_ezgi_internaldemand_from_wastage_tracking</cfoutput>";
							aktar_form.submit();
						}
						else
							return false;
					}
					else
						return false;
				}
			}
		<cfelse>
			var convert_list ="";
			var convert_list_amount ="";
			var convert_list_price ="";
			var convert_list_price_other="";
			var convert_list_money ="";	
			<cfif isdefined("attributes.is_submitted")>
				 <cfoutput query="get_ezgi_iflow_wastage_tracking">
					<cfset row_total_need_ = (round(get_ezgi_iflow_wastage_tracking.RAW_AMOUNT*10000)/10000)-(round(get_ezgi_iflow_wastage_tracking.DEMAND_QUANTITY*10000)/10000)>
					<cfif row_total_need_ gt 0>
						 if(document.all.conversion_product_#PRODUCTION_WASTAGE_ROW_ID#.checked && filterNum(document.getElementById('row_total_need_#PRODUCTION_WASTAGE_ROW_ID#').value) > 0)
						 {
							convert_list += "#PRODUCTION_WASTAGE_ROW_ID#,";
							convert_list_amount += filterNum(document.getElementById('row_total_need_#PRODUCTION_WASTAGE_ROW_ID#').value)+',';
							convert_list_price_other += filterNum(document.getElementById('row_price_unit_#PRODUCTION_WASTAGE_ROW_ID#').value,4)+',';
							convert_list_price += list_getat(document.getElementById('row_stock_money_#PRODUCTION_WASTAGE_ROW_ID#').value,2,',')*filterNum(document.getElementById('row_price_unit_#PRODUCTION_WASTAGE_ROW_ID#').value,4)+',';
							convert_list_money += list_getat(document.getElementById('row_stock_money_#PRODUCTION_WASTAGE_ROW_ID#').value,1,',')+',';
						 }
					 </cfif>
				 </cfoutput>
			</cfif>
			if(convert_list)//Ürün Seçili ise
			{
				if(type==-3)
				{
					sor=confirm('<cf_get_lang dictionary_id='461.Seçilen Ürünler İçin Talep Oluşturulacaktır'>');
					if(sor==true)
					{
						if(process_cat_control())
						{
							document.getElementById('material_button').disabled=true;
							aktar_form.action="<cfoutput>#request.self#?fuseaction=prod.emptypopup_add_ezgi_internaldemand_from_wastage_tracking</cfoutput>";
							aktar_form.submit();
							return true;
						}
						else
							return false;
					}
					else
						return false;
				}
			}
		</cfif>
	}
	function all_select_control(all_conv_product,_conversion_product_,number)
	{
		for(var cl_ind=1; cl_ind <= number; cl_ind++)
		{
			if(document.getElementById(all_conv_product).checked == true)
			{
				if(document.getElementById('_conversion_product_'+cl_ind) != undefined && document.getElementById('_conversion_product_'+cl_ind).checked == false)
					document.getElementById('_conversion_product_'+cl_ind).checked = true;
			}
			else
			{
				if(document.getElementById('_conversion_product_'+cl_ind) != undefined && document.getElementById('_conversion_product_'+cl_ind).checked == true)
					document.getElementById('_conversion_product_'+cl_ind).checked = false;
			}
		}
	}
	function hesapla(wrk_row_id)
	{
		document.getElementById('row_price_'+wrk_row_id).value = 
			commaSplit(
					   	parseFloat(document.getElementById('row_price_unit_'+wrk_row_id).value)*
						parseFloat(document.getElementById('row_total_need_'+wrk_row_id).value)
						,2);
	}
</script>