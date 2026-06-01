<!---
    File: list_ezgi_operation_time.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.is_active" default="1">
<cfparam name="attributes.is_save" default="">
<cfparam name="attributes.is_source" default="">
<cfparam name="attributes.report_sort"  default="">
<cfparam name="attributes.operation_type_id" default="">
<cfparam name="attributes.is_excel" default="">
<cfparam name="attributes.page" default=1>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfscript>
	get_operation_time.recordcount=0;
	get_operation_time.query_count=0;
	if (isdefined("attributes.is_submitted"))
	{
		get_operation_time_action = createObject("component", "addOns.ezgi.cfc.get_operation_time");
		get_operation_time_action.dsn3 = dsn3;
		get_operation_time = get_operation_time_action.get_operation_time_
		(
		 	keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
		 	report_sort : '#iif(isdefined("attributes.report_sort"),"attributes.report_sort",DE(""))#',
			is_active : '#IIf(IsDefined("attributes.is_active"),"attributes.is_active",DE(""))#',
			is_save : '#IIf(IsDefined("attributes.is_save"),"attributes.is_save",DE(""))#',
			operation_type_id : '#iif(isdefined("attributes.operation_type_id"),"attributes.operation_type_id",DE(""))#',
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
<cfif isdefined("attributes.is_submitted") and attributes.is_source neq 1>
	<cfset attributes.product_quantity = 1>
    <cfset get_default.DEFAULT_IS_STATION_OR_IS_OPERATION = 0>
	<cfif get_operation_time.recordcount>
    	<cfloop query="get_operation_time">
        	<cfquery name="GET_EDESIGN_ID" datasource="#DSN3#">
            	SELECT 
                	3 AS TYPE, 
                    PIECE_ROW_ID AS ID
				FROM     
                	EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
				WHERE  
                	PIECE_RELATED_ID = #get_operation_time.stock_id#
				UNION ALL
				SELECT 
                	2 AS TYPE, 
                    PACKAGE_ROW_ID AS ID
				FROM     
                	EZGI_DESIGN_PACKAGE_ROW WITH (NOLOCK)
				WHERE  
                	PACKAGE_RELATED_ID = #get_operation_time.stock_id#
				UNION ALL
				SELECT 
                	1 AS TYPE, 
                    DESIGN_MAIN_ROW_ID AS ID
				FROM     
                	EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
				WHERE  
                	DESIGN_MAIN_RELATED_ID = #get_operation_time.stock_id#
            </cfquery>
            <cfset attributes.design_main_row_id = ''>
         	<cfset attributes.design_package_row_id = ''>
          	<cfset attributes.design_piece_row_id = ''>
            <cfif GET_EDESIGN_ID.recordcount>
            	<cfif GET_EDESIGN_ID.TYPE eq 1>
                	<cfset attributes.design_main_row_id = GET_EDESIGN_ID.ID>
                <cfelseif GET_EDESIGN_ID.TYPE eq 2>
                	<cfset attributes.design_package_row_id = GET_EDESIGN_ID.ID>
                <cfelseif GET_EDESIGN_ID.TYPE eq 3>
                	<cfset attributes.design_piece_row_id = GET_EDESIGN_ID.ID>
                </cfif>
    			<cfinclude template="/addOns/ezgi/e_design/query/get_ezgi_product_tree_creative_station_time.cfm">
               	<cfif station_time_cal.recordcount>
                	<cfloop query="station_time_cal">
                    	<cfset 'OPERASYON_TIME_#get_operation_time.stock_id#_#STATION_ID#' = station_time_cal.process_time/station_time_cal.AMOUNT>
                    </cfloop>
                </cfif>
            </cfif>
        </cfloop>
    </cfif>
</cfif>
<cfquery name="get_operations" datasource="#dsn3#">
	SELECT OPERATION_TYPE_ID, OPERATION_TYPE FROM OPERATION_TYPES WITH (NOLOCK) WHERE ISNULL(IS_VIRTUAL,1) = 0 AND ISNULL(OPERATION_STATUS,0) = 1 ORDER BY OPERATION_TYPE
</cfquery>
<cfparam name="attributes.totalrecords" default='#get_operation_time.query_count#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="form" action="#request.self#?fuseaction=prod.list_ezgi_operation_time" method="post">
			<input type="hidden" name="is_submitted" id="is_submitted" value="1">
            <cf_box_search>
                 <div class="form-group"  id="item-keyword">
                    <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group medium" id="item-report_sort">
                	<select name="report_sort" id="report_sort" style="width:150px; height:20px">
                    	<option value=""><cf_get_lang dictionary_id='53661.Sıralama Şekli'></option>
                  		<option value="1" <cfif attributes.report_sort eq 1>selected</cfif>><cf_get_lang dictionary_id='58221.Ürün Adı'></option>
                       	<option value="2" <cfif attributes.report_sort eq 2>selected</cfif>><cf_get_lang dictionary_id='29419.Operasyon'></option>
                	</select>
               	</div>
                <div class="form-group medium" id="item-report_active">
                	<select name="is_active" id="is_active" style="width:60px; height:20px">
                     	<option value="2"><cf_get_lang dictionary_id='57708.Tümü'></option>
                     	<option value="1" <cfif attributes.is_active eq 1>selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                      	<option value="0" <cfif attributes.is_active eq 0>selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                	</select>
               	</div>
                <div class="form-group medium" id="item-report_dolu">
                	<select name="is_save" id="is_save" style="width:60px; height:20px">
                     	<option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                     	<option value="1" <cfif attributes.is_save eq 1>selected</cfif>><cf_get_lang dictionary_id='39965.Dolu Olanlar'></option>
                      	<option value="0" <cfif attributes.is_save eq 0>selected</cfif>><cf_get_lang dictionary_id='39966.Boş Olanlar'></option>
                	</select>
               	</div>
                <div class="form-group medium" id="item-report_source">
                	<select name="is_source" id="is_source" style="width:60px; height:20px">
                     	<option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                     	<option value="1" <cfif attributes.is_source eq 1>selected</cfif>><cf_get_lang dictionary_id='38092.Üretim Sonuçları'></option>
                      	<option value="2" <cfif attributes.is_source eq 2>selected</cfif>><cf_get_lang dictionary_id='4.E-Design'> <cf_get_lang dictionary_id='796.Operasyon Süreleri'></option>
                	</select>
               	</div>
                <div class="form-group medium" id="item-operation_type">
                	<select name="operation_type_id" style="width:125px; height:20px">
						<option value=""><cf_get_lang dictionary_id='1065.Tüm Operasyonlar'></option>
						<cfoutput query="get_operations">
							<option value="#OPERATION_TYPE_ID#"<cfif isdefined('attributes.operation_type_id') and attributes.operation_type_id eq OPERATION_TYPE_ID>selected</cfif>>#OPERATION_TYPE#</option>
						</cfoutput>
					</select>
               	</div>
				   <div class="form-group">
                	<input type="checkbox" name="is_excel" id="is_excel" value="1" <cfif attributes.is_excel eq 1>checked</cfif>>
                	<cf_get_lang_main no='446.Excel Getir'>
                </div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="1">
                </div>
			</cf_box_search>
     	</cfform>
 	</cf_box>
	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
		<cfset filename = "#createuuid()#">
		<cfheader name="Expires" value="#Now()#">
		<cfcontent type="application/vnd.msexcel;charset=utf-16">
		<cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
		<meta http-equiv="Content-Type" content="text/html; charset=utf-16">
		<cfset attributes.startrow=1>
		<cfset attributes.maxrows = GET_OPERATION_TIME.recordcount>
	</cfif>
  	<cfsavecontent variable="title"><cf_get_lang dictionary_id='796.Operasyon Süreleri'></cfsavecontent>
 	<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>   
        	<thead>
            	<tr>
                 	<th width="30" rowspan="2" style="text-align:center;"><cf_get_lang dictionary_id='58577.Sıra'></th>
                 	<th rowspan="2" style="text-align:center;"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                 	<th rowspan="2" style="text-align:center;"><cf_get_lang dictionary_id='58221.Ürün Adı' rowspan="2"></th>
                 	<th rowspan="2" style="text-align:center;"><cf_get_lang dictionary_id='36377.Operasyon Kodu'></th>
                 	<th rowspan="2" style="text-align:center;"><cf_get_lang dictionary_id='61806.İşlem Tipi'></th>
                 	<th rowspan="2" style="text-align:center;"><cf_get_lang dictionary_id ='57899.Kaydeden'></th>
                 	<cfif attributes.is_source neq 1>
                 		<th width="70" rowspan="2" style="text-align:center;"><cf_get_lang dictionary_id='4.E-Design'> <cf_get_lang dictionary_id='796.Operasyon Süreleri'></th>
                 	</cfif>
                    <cfif attributes.is_source neq 2>
                 		<th colspan="3" style="text-align:center;"><cf_get_lang dictionary_id='36512.Gerçekleşen Süre'></th>
                    </cfif>
                 	<th rowspan="2" style="text-align:center;">Optimal Süre <br />(<cf_get_lang dictionary_id='420.sn'>.)</th>
                 	<!-- sil --><th class="header_icn_none" rowspan="2"></th><!-- sil -->
            	</tr>
                <cfif attributes.is_source neq 2>
                    <tr>
                        <th width="40" style="text-align:center;">1.<cf_get_lang dictionary_id='29419.Operasyon'></th>
                        <th width="40" style="text-align:center;">2.<cf_get_lang dictionary_id='29419.Operasyon'></th>
                        <th width="40" style="text-align:center;">3.<cf_get_lang dictionary_id='29419.Operasyon'></th>
                    </tr>
                </cfif>
          	</thead>
        	<tbody>
            	<cfif GET_OPERATION_TIME.recordcount>
              		<cfoutput query="GET_OPERATION_TIME">
                        <cfquery name="GET_LAST_OPTIMUM_TIME" datasource="#DSN3#">
                            SELECT        
                                TOP (3) 
                                CASE
                                    WHEN 
                                        REAL_TIME >0 AND REAL_AMOUNT > 0
                                    THEN 
                                        ROUND(REAL_TIME / REAL_AMOUNT, 0) 
                                    ELSE
                                        0
                                END AS SURE,
                                P_ORDER_ID
                            FROM            
                                EZGI_OPERATION_M WITH (NOLOCK)
                            WHERE        
                                REAL_TIME IS NOT NULL AND 
                                STOCK_ID = #STOCK_ID# AND OPERATION_TYPE_ID = #OPERATION_TYPE_ID#
                            ORDER BY 
                                ACTION_START_DATE DESC
                        </cfquery>
                        
                        <cfif attributes.is_source neq 1>
                            <cfif isdefined('OPERASYON_TIME_#get_operation_time.stock_id#_#OPERATION_TYPE_ID#')>
                                <input name="operation_time_edesign_#currentrow#" id="operation_time_edesign_#currentrow#" type="hidden" value="#TlFormat(Evaluate('OPERASYON_TIME_#get_operation_time.stock_id#_#OPERATION_TYPE_ID#'),0)#">
                            <cfelse>
                                <input name="operation_time_edesign_#currentrow#" id="operation_time_edesign_#currentrow#" type="hidden" value="0">
                            </cfif>
                        </cfif>
                        <tr>
                            <td>#CURRENTROW#</td>
                            <td>#STOCK_CODE#</td>
                            <td>
								<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
									#product_name#
								<cfelse>
									<a href="#request.self#?fuseaction=prod.list_product_tree&event=upd&stock_id=#stock_id#" class="tableyazi" target="_blank">#product_name#</a>
								</cfif>	
							</td>
                            <td>#OPERATION_CODE#</td>
                            <td>#OPERATION_TYPE#</td>
                            <td>#get_emp_info(RECORD_EMP,0,0)#</td>
                            <cfif attributes.is_source neq 1>
                                <td style="text-align:center">
                                    <cfif isdefined('OPERASYON_TIME_#get_operation_time.stock_id#_#OPERATION_TYPE_ID#')>
                                        #TlFormat(Evaluate('OPERASYON_TIME_#get_operation_time.stock_id#_#OPERATION_TYPE_ID#'),0)#
                                    <cfelse>
                                        0
                                    </cfif>
                                </td>
                            </cfif>
                            <cfif attributes.is_source neq 2>
                                <td style="text-align:center">
                                    <cfif GET_LAST_OPTIMUM_TIME.recordcount>
										<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
											#GET_LAST_OPTIMUM_TIME.P_ORDER_ID[1]#
										<cfelse>
											<a href="#request.self#?fuseaction=prod.order&event=upd&upd=#GET_LAST_OPTIMUM_TIME.P_ORDER_ID[1]#" class="tableyazi" target="_blank">#GET_LAST_OPTIMUM_TIME.SURE[1]#</a>
											<input name="last_1_#currentrow#" id="last_1_#currentrow#" type="hidden" value="#GET_LAST_OPTIMUM_TIME.SURE[1]#">
										</cfif>
                                    <cfelse>
                                        0
                                        <input name="last_1_#currentrow#" id="last_1_#currentrow#" type="hidden" value="0">
                                    </cfif>
                                </td>
                                <td style="text-align:center">
                                    <cfif GET_LAST_OPTIMUM_TIME.recordcount gt 1>
										<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
											#GET_LAST_OPTIMUM_TIME.P_ORDER_ID[2]#
										<cfelse>
											<a href="#request.self#?fuseaction=prod.order&event=upd&upd=#GET_LAST_OPTIMUM_TIME.P_ORDER_ID[2]#" class="tableyazi" target="_blank">#GET_LAST_OPTIMUM_TIME.SURE[2]#</a>
											<input name="last_2_#currentrow#" id="last_2_#currentrow#" type="hidden" value="#GET_LAST_OPTIMUM_TIME.SURE[2]#">
										</cfif>
                                    <cfelse>
                                        0
                                        <input name="last_2_#currentrow#" id="last_2_#currentrow#" type="hidden" value="0">
                                    </cfif>
                                </td>
                                <td style="text-align:center">
                                    <cfif GET_LAST_OPTIMUM_TIME.recordcount gt 2>
										<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
											#GET_LAST_OPTIMUM_TIME.P_ORDER_ID[3]#
										<cfelse>
											<a href="#request.self#?fuseaction=prod.order&event=upd&upd=#GET_LAST_OPTIMUM_TIME.P_ORDER_ID[3]#" class="tableyazi" target="_blank">#GET_LAST_OPTIMUM_TIME.SURE[3]#</a>
											<input name="last_3_#currentrow#" id="last_3_#currentrow#" type="hidden" value="#GET_LAST_OPTIMUM_TIME.SURE[3]#">
										</cfif>
                                    <cfelse>
                                        0
                                        <input name="last_3_#currentrow#" id="last_3_#currentrow#" type="hidden" value="0">
                                    </cfif>
                                </td>
                            </cfif>
                            <td style="text-align:center">
								<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
									#OPTIMUM_TIME#
								<cfelse>
									<input name="input_time#CURRENTROW#" id="input_time#CURRENTROW#" value="#OPTIMUM_TIME#" class="box" style="width:30px; text-align:center" onChange="duzenle(#CURRENTROW#,#OPERATION_TYPE_ID#,#STOCK_ID#,#EZGI_OPERATION_OPTIMUM_TIME_ID#);">

									<input type="hidden" id="operation_optimum_time#currentrow#" name="operation_optimum_time#currentrow#" value="#OPTIMUM_TIME#" /> 
								</cfif>
                            </td>
                            
                            <!-- sil -->
                            <td align="center" width="15">
								<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
								<cfelse>
                            	<input type="hidden" name="is_change_top_#CURRENTROW#" id="is_change_top_#CURRENTROW#" value="0">
                                <span id="red_top#CURRENTROW#" style="display:none"><img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='58718.Düzenle'>" border="0"></span>
                                <span id="yellow_top#CURRENTROW#" style="display:none"><img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='58718.Düzenle'>" border="0"></span>
                                <span id="blue_top#CURRENTROW#" style="display:"><img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='36411.İşlem Görmeyenler'>" border="0"></span>
                                <span id="green_top#CURRENTROW#" style="display:none"><img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='58718.Düzenle'>" border="0"></span>
								</cfif>
                            </td>
                            <!-- sil -->
                        </tr>
               		</cfoutput>
            	<cfelse>
                 	<tr>
                 	    <td colspan="12"><cfif isdefined("attributes.is_submitted")><cf_get_lang dictionary_id='58486.Kayıt Bulunamadı'><cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'></cfif>!</td>
                 	</tr>
           		</cfif>
         	</tbody>
        	<tfoot>
            	<tr>
                 	<td colspan="12" style="text-align:right">
						<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
						<cfelse>
							<cfif attributes.is_source neq 1>
								<a style="cursor:pointer" onclick="is_edesign();">
									<button name="is_edesign" id="is_edesign" style="height:30px; width:200px; background-color:#F1142B; border:none; color:white; font-weight:bold">E-Design Süresi Optimal Yap</button>
								</a>
							</cfif>
							<cfif attributes.is_source neq 2>
								<a style="cursor:pointer" onclick="is_avarage();">
									<button name="is_avarage" id="is_avarage" style="height:30px; width:200px; background-color:#0645FF; border:none; color:white; font-weight:bold">En Kısa Sonucu Optimal Yap</button>
								</a>
							</cfif>
							<a style="cursor:pointer" onclick="guncelle();">
								<button name="guncelle" id="guncelle" style="height:30px; width:100px; background-color: #00B7B7; border:none; color:white; font-weight:bold"><cf_get_lang dictionary_id='57464.Güncelle'></button>
							</a>
						</cfif>
                 	</td>
              	</tr>
         	</tfoot>
        </cf_grid_list>
       	<cfset adres = url.fuseaction>
		<cfif isdefined("attributes.is_submitted")>
         	<cfset adres = "#adres#&is_submitted=#attributes.is_submitted#">
      	</cfif>
     	<cfif isdefined ("attributes.is_active") and len(attributes.is_active)>
          	<cfset adres = "#adres#&is_active=#attributes.is_active#">
     	</cfif>
    	<cfif isdefined ("attributes.is_save") and len(attributes.is_save)>
         	<cfset adres = "#adres#&is_save=#attributes.is_save#">
      	</cfif>
       	<cfif isdefined ("attributes.is_source") and len(attributes.is_source)>
        	<cfset adres = "#adres#&is_source=#attributes.is_source#">
      	</cfif>
      	<cfif isdefined('attributes.report_sort') and len(attributes.report_sort)>
           	<cfset adres = "#adres#&report_sort=#attributes.report_sort#">
      	</cfif>
   		<cfif isdefined('attributes.operation_type_id') and len(attributes.operation_type_id)>
        	<cfset adres = '#adres#&operation_type_id=#attributes.operation_type_id#'>
      	</cfif>
    	<cf_paging 
          	 	page="#attributes.page#"
          		maxrows="#attributes.maxrows#"
           		totalrecords="#attributes.totalrecords#"
            	startrow="#attributes.startrow#"
            	adres="#adres#&is_submitted=1">
   	</cf_box>
</div>
<form name="aktar_form" method="post" action="<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_upd_ezgi_operation_optimum_time">
	<input type="hidden" name="keyw" value="<cfoutput>#attributes.keyword#</cfoutput>">
    <input type="hidden" name="active" value="<cfoutput>#attributes.is_active#</cfoutput>">
    <input type="hidden" name="convert_stocks_id" id="convert_stocks_id" value="">
    <input type="hidden" name="convert_operation_type_id" id="convert_operation_type_id" value="">
    <input type="hidden" name="convert_optimum_time" id="convert_optimum_time" value="">
    <input type="hidden" name="convert_operation_optimum_time_id" id="convert_operation_optimum_time_id" value="">
</form>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function duzenle(currentrow,operation_type_id,stock_id)
	{
		if(document.getElementById("input_time"+currentrow).value != document.getElementById("operation_optimum_time"+currentrow).value)
		{
			document.getElementById("green_top"+currentrow).style.display = '';	
			document.getElementById("blue_top"+currentrow).style.display = 'none';
			document.getElementById("is_change_top_"+currentrow).value = 1;	
		}
		else
		{
			document.getElementById("green_top"+currentrow).style.display = 'none';	
			document.getElementById("blue_top"+currentrow).style.display = '';
			document.getElementById("is_change_top_"+currentrow).value = 0;
		}
	}
	function is_edesign()
	{
		sira = <cfoutput>#get_operation_time.query_count#</cfoutput>;
		if(sira >0)
		{
			for (var r=1;r<=sira;r++)
			{
				if(document.getElementById('operation_time_edesign_'+r).value>0)
				{
					document.getElementById('input_time'+r).value = document.getElementById('operation_time_edesign_'+r).value;	
					duzenle(r,0,0);
				}
			}
		}
		else
		{
			alert("Satırlarda Bilgi Yoktur.!");
			return false;
		}
	}
	function is_avarage()
	{
		sira = <cfoutput>#get_operation_time.query_count#</cfoutput>;
		if(sira >0)
		{
			for (var r=1;r<=sira;r++)
			{
				deger = 0;
				if(document.getElementById('last_1_'+r).value >0)
					deger = document.getElementById('last_1_'+r).value;
				if(document.getElementById('last_2_'+r).value >0 && document.getElementById('last_2_'+r).value < deger)	
					deger = document.getElementById('last_2_'+r).value;
				if(document.getElementById('last_3_'+r).value >0 && document.getElementById('last_3_'+r).value < deger)	
					deger = document.getElementById('last_3_'+r).value;
				
				if(deger >0)
					document.getElementById('input_time'+r).value = deger;	
				duzenle(r,0,0);
			}
		}
		else
		{
			alert("Satırlarda Bilgi Yoktur.!");
			return false;
		}
	}
	function guncelle()
	{
		document.getElementById('guncelle').disabled=true;
		var convert_list_stock_id ="";
		var convert_list_operation_type_id ="";
		var convert_list_optimum_time ="";
		var convert_list_operation_optimum_time_id ="";
		<cfif isdefined("attributes.is_submitted")>
			<cfoutput query="GET_OPERATION_TIME">
					var sira = #currentrow#;
					if(document.getElementById("is_change_top_"+sira).value == 1)
					{
						convert_list_stock_id += "#STOCK_ID#,";
						convert_list_operation_type_id += "#OPERATION_TYPE_ID#,";
						convert_list_optimum_time += document.getElementById("input_time"+sira).value+',';
						convert_list_operation_optimum_time_id += "#EZGI_OPERATION_OPTIMUM_TIME_ID#,";
					}
			</cfoutput>
		</cfif>
		document.getElementById('convert_stocks_id').value = convert_list_stock_id.substr(0,convert_list_stock_id.length-1);
		document.getElementById('convert_operation_type_id').value = convert_list_operation_type_id.substr(0,convert_list_operation_type_id.length-1);
		document.getElementById('convert_optimum_time').value = convert_list_optimum_time.substr(0,convert_list_optimum_time.length-1);
		document.getElementById('convert_operation_optimum_time_id').value = convert_list_operation_optimum_time_id.substr(0,convert_list_operation_optimum_time_id.length-1);
		aktar_form.submit();
	}
	function input_control()
	{
		if(document.getElementById('is_excel').checked==false)
			return true;
	}
</script>
