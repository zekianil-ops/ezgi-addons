<!---
    File: list_ezgi_iflow_production_operations.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<!---<cfset x_daily_point = 300>--->
<cfset renk ='silver'>
<cfset renk_1 ='orange'>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.sort_type" default="2">
<cfparam name="attributes.master_plan_id" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.is_excel" default="">

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

<cfset kapasite_kullanim_orani = 0>
<cfset makine_sayisi = 0>

<style>
    /* Sürüklenen parti (tbody) için efekt */
    .parti-group.dragging {
        background-color: #f8f9fa; /* Hafif gri arkaplan */
        border: 2px dashed #007bff; /* Çizgili sınır */
        opacity: 0.8; /* Yarı saydam görünüm */
    }

    /* Ürün satırlarını taşırken görsel efekt */
    .urun-row.dragging {
        background-color: #d1ecf1; /* Hafif mavi arkaplan */
        opacity: 0.7;
    }
</style>
<cfquery name="get_master_plan" datasource="#dsn3#">
	SELECT        
    	MASTER_PLAN_ID, 
        MASTER_PLAN_NUMBER, 
        MASTER_PLAN_DETAIL,
        MASTER_PLAN_CAT_ID
	FROM            
    	EZGI_IFLOW_MASTER_PLAN WITH (NOLOCK)
  	<cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
        WHERE 
            MASTER_PLAN_CAT_ID IN    
            
                    (
                        SELECT        
                            MASTER_PLAN_CAT_ID
                        FROM       
                            EZGI_IFLOW_MASTER_PLAN AS M
                        WHERE        
                            MASTER_PLAN_ID IN (#attributes.master_plan_id#)
                    )
    </cfif>
	ORDER BY 
    	MASTER_PLAN_NUMBER
</cfquery>
<!---Şablonu Listesini Alıyoruz--->
<cfquery name="get_station_sablon" datasource="#dsn3#">
	SELECT 
    	EMPS.WORKSTATION_ID, 
        EMPS.SIRA, 
        EMPS.UP_WORKSTATION_ID, 
        ISNULL(EMPS.UP_WORKSTATION_TIME,0) AS UP_WORKSTATION_TIME, 
        W.STATION_NAME,
        ISNULL(EMPS.CURRENT_POINT,0) AS CURRENT_POINT, 
        EMD.FABRIC_CAT, 
        EMD.POINT_METHOD,
        EMD.WORK_TIME
	FROM     
   		EZGI_MASTER_PLAN_SABLON AS EMPS WITH (NOLOCK) INNER JOIN
     	WORKSTATIONS AS W WITH (NOLOCK) ON EMPS.WORKSTATION_ID = W.STATION_ID INNER JOIN
      	EZGI_MASTER_PLAN_DEFAULTS AS EMD WITH (NOLOCK) ON EMPS.SHIFT_ID = EMD.SHIFT_ID
	WHERE  
    	EMPS.SHIFT_ID = #get_master_plan.MASTER_PLAN_CAT_ID# AND 
        EMPS.STATUS_ID = 1 AND
        NOT(EMPS.WORKSTATION_ID IS NULL) 
	ORDER BY 
    	EMPS.SIRA
</cfquery>

<!---Hesaplama Şeklini Öğrenmek İçim Master Plan Şablon Dosyasının 1. Satırına Bakıyorum--->
<cfquery name="get_station_sablon_main" dbtype="query">
	SELECT 
     	SIRA, 
       	CURRENT_POINT, 
     	FABRIC_CAT, 
   		POINT_METHOD,
        WORK_TIME
	FROM     
   		get_station_sablon
	WHERE  
        SIRA = 1 
</cfquery>
<cfif not get_station_sablon_main.recordcount>
 	<script type="text/javascript">
      	alert("Ilk Olarak Çalışma Programlarındaki İstasyon Tanımlarını Yapınız!");
      	window.close()
 	</script>
 	<cfabort>
</cfif>
<cfif isdefined("attributes.is_form_submitted")>
	<cfinclude template="../query/get_ezgi_iflow_production_operations.cfm">
	<cfset arama_yapilmali = 0>
<cfelse>
	<cfset get_production_operations.recordcount = 0>
    <cfset arama_yapilmali = 1>
</cfif>

<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_production_operations_group.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfif attributes.x_is_parti eq 0>
            <cfform name="search" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
                <input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
                <cfinput name="x_is_parti" type="hidden" value="#attributes.x_is_parti#">
                <cf_box_search>
                    <div class="form-group"  id="item-keyword">
                        <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                         <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
                    </div>
                    <div class="form-group medium" id="item-sort_type">
                        <select name="sort_type" id="sort_type">
                            <option value="0" <cfif attributes.sort_type eq 0>selected</cfif>><cf_get_lang dictionary_id='37959.Ürün Adına Göre Artan'></option>
                            <option value="1" <cfif attributes.sort_type eq 1>selected</cfif>><cf_get_lang dictionary_id='37960.Ürün Adına Göre Azalan'></option>
                            <option value="2" <cfif attributes.sort_type eq 2>selected</cfif>><cf_get_lang dictionary_id='465.Emir Nosuna Göre Artan'></option>
                            <option value="3" <cfif attributes.sort_type eq 3>selected</cfif>><cf_get_lang dictionary_id='466.Emir Nosuna Göre Azalan'></option>
                            <option value="4" <cfif attributes.sort_type eq 4>selected</cfif>><cf_get_lang dictionary_id='467.Emir Tarihine Göre Azalan'></option>
                            <option value="5" <cfif attributes.sort_type eq 5>selected</cfif>><cf_get_lang dictionary_id='468.Emir Tarihine Göre Azalan'></option>
                        </select>
                    </div>
                    <div class="form-group medium" id="item-master_plan_id">
                        <select name="master_plan_id">
                            <option value="" <cfif attributes.master_plan_id eq ''>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            <cfoutput query="get_master_plan">
                                <option value="#MASTER_PLAN_ID#" <cfif attributes.master_plan_id eq MASTER_PLAN_ID>selected</cfif>>#MASTER_PLAN_NUMBER# - #MASTER_PLAN_DETAIL#</option>
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
        	<cfsavecontent variable="title"><cf_get_lang dictionary_id='36368.Fabrika Üretim Emirleri'></cfsavecontent>
        	<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
        	    <cf_grid_list>   
        	        <thead>
        	            <tr valign="middle">
        	                <th style="width:25px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58577.Sıra'></th>
        	                <th style="width:50px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='695.Plan No'></th>
        	                <th style="width:50px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='36528.Parti No'></th>
        	                <th style="width:50px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='41701.Lot No'></th>
        	                <th style="width:250px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57657.Ürün'></th>
        	                <th style="width:30px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57635.Miktar'></th>
        	                <th style="width:50px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='141.Modül'></th>
        	                <th style="width:50px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='100.Paket'></th>
        	                <th style="width:50px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='45.Parça'></th>
        	                <th style="width:350px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
        	                <th style="width:30px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57635.Miktar'></th>
        	                <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='36376.Operasyonlar'></th>
        	                <!-- sil -->
        	                <th style="width:20px; text-align:center; vertical-align:middle" class="header_icn_none" ></th>
        	                <!-- sil -->
        	            </tr>
        	        </thead>




        	        
        	        <tbody>
        	            <cfif get_production_operations_group.recordcount>
        	                <cfoutput query="get_production_operations_group" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                      		    <cfquery name="get_production_order_group" dbtype="query">
                      		        SELECT
                      		            P_ORDER_NO, 
                      		            P_ORDER_ID,
                      		            PRODUCTION_LEVEL, 
                      		            IS_STAGE, 
                      		            STOCK_CODE, 
                      		            STOCK_ID,
                      		            PRODUCT_ID, 
                      		            PRODUCT_NAME,
                      		            NAME_PRODUCT, 
                      		            QUANTITY,
                      		            LOT_NO,
                      		            SIRA_ID,
                      		            TYPE
                      		        FROM
                      		            get_production_operations
                      		        WHERE
                      		            LOT_NO = #get_production_operations_group.LOT_NO#
                      		        GROUP BY
                      		            P_ORDER_NO, 
                      		            P_ORDER_ID,
                      		            PRODUCTION_LEVEL, 
                      		            IS_STAGE, 
                      		            STOCK_CODE, 
                      		            STOCK_ID,
                      		            PRODUCT_ID, 
                      		            PRODUCT_NAME, 
                      		            NAME_PRODUCT,
                      		            QUANTITY,
                      		            LOT_NO,
                      		            SIRA_ID,
                      		            TYPE
                      		        ORDER BY
                      		            SIRA_ID
                      		    </cfquery>
                      		    <!---<cfdump var="#get_production_order_group#">--->
                      		    <cfset row_span = get_production_order_group.recordcount + 1>
                      		    <tr>
                      		        <td style="text-align:right; font-weight:bold" rowspan="#row_span#" nowrap="nowrap">#CURRENTROW#</td>
                      		        <td style="text-align:center; font-weight:bold" rowspan="#row_span#" nowrap="nowrap">#MASTER_PLAN_NUMBER#</td>
                      		        <td style="text-align:center; font-weight:bold" rowspan="#row_span#" nowrap="nowrap">#P_ORDER_PARTI_NUMBER#</td>
                      		        <td style="text-align:center; font-weight:bold" rowspan="#row_span#">#LOT_NO#</td>
                      		        <td style="text-align:left; font-weight:bold" rowspan="#row_span#" nowrap="nowrap">#Left(IFLOW_PRODUCT_NAME,80)#<cfif len(IFLOW_PRODUCT_NAME) gt 80>...</cfif></td>
                      		        <td style="text-align:right; font-weight:bold" rowspan="#row_span#">#AmountFormat(IFLOW_QUANTITY,2)#</td>
                      		        <cfloop query="get_production_order_group">
                      		            <cfquery name="get_operations" dbtype="query">
                      		                SELECT        
                      		                    P_OPERATION_ID, 
                      		                    OPERATION_TYPE_ID, 
                      		                    OPERATION_CODE, 
                      		                    OPERATION_TYPE, 
                      		                    AMOUNT, 
                      		                    STAGE,
                      		                    SUM(REAL_AMOUNT) AS REAL_AMOUNT,
                      		                    ASIRA
                      		                FROM  
                      		                    get_production_operations         
                      		                WHERE        
                      		                    P_ORDER_ID = #get_production_order_group.P_ORDER_ID#
                      		                GROUP BY 
                      		                    P_OPERATION_ID, 
                      		                    OPERATION_TYPE_ID, 
                      		                    OPERATION_CODE, 
                      		                    OPERATION_TYPE, 
                      		                    AMOUNT, 
                      		                    STAGE,
                      		                    ASIRA
                      		                ORDER BY
                      		                    ASIRA
                      		            </cfquery>
                      		            <tr>
                      		                <td style="text-align:center; font-weight:bolder; height:30px">
                      		                    <cfif TYPE eq 3>
                      		                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.order&event=upd&upd=#p_order_id#','longpage');" class="tableyazi">
                      		                            #P_ORDER_NO#
                      		                        </a>
                      		                    </cfif>
                      		                </td>
                      		                <td style="text-align:center; font-weight:bold">
                      		                    <cfif TYPE eq 2 or not len(TYPE)>
                      		                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.order&event=upd&upd=#p_order_id#','longpage');" class="tableyazi">
                      		                            #P_ORDER_NO#
                      		                        </a>
                      		                    </cfif>
                      		                </td>
                      		                <td style="text-align:center;">
                      		                    <cfif TYPE eq 1>
                                                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.order&event=upd&upd=#p_order_id#','longpage');" class="tableyazi">
                      		                            #P_ORDER_NO#
                      		                        </a>
                                              	</cfif>
                      		                </td>
                      		                <td style="text-align:left;" nowrap="nowrap">
                      		                    <cfif len(PRODUCT_NAME)>
                      		                        <cfset p_name = PRODUCT_NAME>
                      		                    <cfelse>
                      		                        <cfset p_name = NAME_PRODUCT>
                      		                    </cfif>
                      		                    #Left(p_name,80)#<cfif len(p_name) gt 80>...</cfif>
                      		                </td>
                      		                <td style="text-align:right;">#AmountFormat(QUANTITY,2)#</td>
                      		                <td style="text-align:left; width:50%" title="" nowrap>
                      		                    <cfif len(get_operations.P_OPERATION_ID)>
                      		                        <cfloop query="get_operations">
                      		                            <cfquery name="get_this_operations" dbtype="query">
                      		                                SELECT        
                      		                                    ACTION_EMPLOYEE_ID,
                      		                                    ACTION_START_DATE
                      		                                FROM  
                      		                                    get_production_operations         
                      		                                WHERE        
                      		                                    P_OPERATION_ID = #get_operations.P_OPERATION_ID# AND
                      		                                    REAL_AMOUNT = 0 and
                      		                                    LOSS_AMOUNT = 0 and
                      		                                    ACTION_EMPLOYEE_ID > 0
                      		                            </cfquery>
                      		                            <button name="operation_#P_OPERATION_ID#" title="<cfif get_this_operations.recordcount><cfloop query='get_this_operations'>Biten : #get_operations.REAL_AMOUNT# - #get_emp_info(ACTION_EMPLOYEE_ID,0,0)# - </cfloop><cfelse>Biten : #get_operations.REAL_AMOUNT#</cfif>" id="operation_#P_OPERATION_ID#" onclick="operation(#P_OPERATION_ID#);" style=" border:none; color:white; width:100px; font-size:10px; height:30px; background-color:<cfif get_this_operations.recordcount>blue<cfelse><cfif STAGE eq 0>orange<cfelseif STAGE eq 1>green<cfelse>red</cfif></cfif>">#OPERATION_TYPE#</button>
                      		                        </cfloop>
                      		                    <cfelse> 
                      		                        <input type="button" name="operation#currentrow#" value="Tanımsız" id="operation#currentrow#" onclick="operation_tanimsiz(#currentrow#);" style="width:100px; height:30px; background-color:gray">
                      		                    </cfif>
                      		                </td>
                      		                <!-- sil -->
                      		                    <td style="text-align:center;">
                      		                        <cfif IS_STAGE eq 0 or IS_STAGE eq 4>
                      		                            <img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='36583.Başlamadı'>">
                      		                        <cfelseif IS_STAGE eq 2>
                      		                            <img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='36584.Bitti'>">
                      		                        <cfelseif IS_STAGE eq 1>
                      		                            <img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='36890.Başladı'>">
                      		                        </cfif>
                      		                    </td>
                      		                <!-- sil -->
                      		            </tr>
                      		        </cfloop> 
                      		    </tr>
                      		</cfoutput>
                     	<cfelse>
                         	<tr> 
                          		<td colspan="20" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
        	        		</tr>
        	            </cfif>
        	        </tbody>
        	    </cf_grid_list>
        	    <cfset adres = url.fuseaction>
        	    <cfif len(attributes.keyword)>
        	      <cfset adres = '#adres#&keyword=#URLEncodedFormat(attributes.keyword)#'>
        	    </cfif>
        	    <cfif len(attributes.sort_type)>
        	        <cfset adres = '#adres#&sort_type=#attributes.sort_type#'>
        	    </cfif>
        	    <cfif len(attributes.master_plan_id)>
        	        <cfset adres = '#adres#&master_plan_id=#attributes.master_plan_id#'>
        	    </cfif>
        	    <cf_paging 
        	        page="#attributes.page#"
        	        maxrows="#attributes.maxrows#"
        	        totalrecords="#attributes.totalrecords#"
        	        startrow="#attributes.startrow#"
        	        adres="#adres#&is_form_submitted=1">
        	</cf_box>
       	<cfelse>
        	<cfform name="search" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
            	<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            	<cfinput name="x_station_level" id="x_station_level" value="#attributes.x_station_level#" type="hidden">
                <cfinput name="x_is_parti" type="hidden" value="#attributes.x_is_parti#">
                <cf_box_search>
                    <div class="form-group"  id="item-keyword">
                        <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                         <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
                    </div>
                    <div class="form-group" id="form_ul_date">
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
                    <div class="form-group medium">
                        <input type="checkbox" name="is_excel" id="is_excel" value="1" <cfif attributes.is_excel eq 1>checked</cfif>>
                        <cf_get_lang_main no='446.Excel Getir'>
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
                	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
						<div class="form-group" id="form_ul_master" style="display:none">
                            <select name="master_plan_id" style="width:150px;height:80px" multiple>
                                <option value="" <cfif attributes.master_plan_id eq ''>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_master_plan">
                                    <option value="#MASTER_PLAN_ID#" <cfif ListFind(attributes.master_plan_id,MASTER_PLAN_ID)>selected</cfif>>#MASTER_PLAN_NUMBER# - #MASTER_PLAN_DETAIL#</option>
                                </cfoutput>
                            </select>
                        </div>
                   	</div>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                    	
                   	</div>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                     	
                  	</div>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                        
                        
                	</div>
          		</cf_box_search_detail>
            </cfform>

            <cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
				<cfset filename = "#createuuid()#">
             	<cfheader name="Expires" value="#Now()#">
             	<cfcontent type="application/vnd.msexcel;charset=utf-16">
             	<cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
              	<meta http-equiv="Content-Type" content="text/html; charset=utf-16">
              	<cfset attributes.startrow=1>
             	<cfset attributes.maxrows = get_production_operations_group.recordcount>
            </cfif>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='36368.Fabrika Üretim Emirleri'></cfsavecontent>
          	<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
             	<cf_grid_list id="partiContainer">   
             	    <thead>
             	        <tr valign="middle">
             	            <th style="display:none">iflow p order id</th>
             	            <th style="width:25px; text-align:center; vertical-align:middle" rowspan="2"><cf_get_lang dictionary_id='58577.Sıra'></th>
             	            <th style="width:50px; text-align:center; vertical-align:middle" rowspan="2"><cf_get_lang dictionary_id='695.Plan No'></th>
             	            <th style="width:50px; text-align:center; vertical-align:middle" rowspan="2"><cf_get_lang dictionary_id='36528.Parti No'></th>
             	            <th style="width:50px; text-align:center; vertical-align:middle" rowspan="2"><cf_get_lang dictionary_id='41701.Lot No'></th>
             	            <th style="text-align:center; vertical-align:middle" rowspan="2"><cf_get_lang dictionary_id='57657.Ürün'></th>
                            <cfif get_station_sablon_main.POINT_METHOD eq 2> <!---Puanlı ise--->
                                <th style="width:30px; text-align:center; vertical-align:middle" rowspan="2">Puan</th>
                                <th style="width:30px; text-align:center; vertical-align:middle" rowspan="2">Toplam<br>Puan</th>
                            </cfif>
             	            <th style="width:30px; text-align:center; vertical-align:middle" rowspan="2"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            <th style="width:30px; text-align:center; vertical-align:middle" rowspan="2"><cf_get_lang dictionary_id='302.Biten'> (%)</th>
                            <th style="width:60px; text-align:center; vertical-align:middle" rowspan="2"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></th>
             	            <th style="text-align:center; vertical-align:middle" colspan="<cfoutput>#get_operations_group.recordcount#</cfoutput>">
             	            	<cfif attributes.x_station_level eq 1>
                                    <cf_get_lang dictionary_id='29473.istasyonlar'>
             	                <cfelse>
             	            		<cf_get_lang dictionary_id='36376.Operasyonlar'>
             	                </cfif>
             	          	</th>
             	        </tr>
             	        <tr valign="middle">
             	        	<cfoutput query="get_operations_group">
             	            	<th style="text-align:center; vertical-align:middle">
             	                	<cfif attributes.x_station_level eq 1>
             	             			#get_operations_group.STATION_NAME#
             	                    <cfelse>
             	                		#get_operations_group.OPERATION_TYPE#
             	                  	</cfif>
             	                </th>
             	            </cfoutput>
             	        </tr>
             	    </thead>
             	    <cfif get_production_operations_group.recordcount>
             	        <cfset total_point = 0>
             	        <cfset parti_point = 0>
                        <cfset new_real_day = 0>
             	        <cfoutput query="get_production_operations_group" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
             	            <cfquery name="get_production_operations_list" dbtype="query">
             	                <cfif attributes.x_station_level eq 1>
                                    SELECT 
                                        STATION_ID, 
                                        O_START_DATE, 
                                        STATION_NAME, 
                                        LOT_NO
                                    FROM 
                                        get_production_operations
                                    WHERE
                                        LOT_NO = #get_production_operations_group.LOT_NO#	    
                                    GROUP BY 
                                        STATION_ID, 
                                        O_START_DATE, 
                                        STATION_NAME, 
                                        LOT_NO
                      		    <cfelse>
                                    SELECT 
                                        OPERATION_TYPE_ID, 
                                        O_START_DATE, 
                                        OPERATION_TYPE, 
                                        LOT_NO
                                    FROM 
                                        get_production_operations
                                    WHERE
                                        LOT_NO = #get_production_operations_group.LOT_NO#	    
                                    GROUP BY 
                                        OPERATION_TYPE_ID, 
                                        O_START_DATE, 
                                        OPERATION_TYPE, 
                                        LOT_NO
                      		    </cfif>
                      		</cfquery>
                      		<cfset parti_id = get_production_operations_group.P_ORDER_PARTI_ID>
                      		<cfset col_span = get_operations_group.recordcount+3>

                      		<cfif currentrow eq 1 or parti_id neq get_production_operations_group.P_ORDER_PARTI_ID[currentrow - 1]>
                      		    <tbody class="parti-group" data-parti-id="#parti_id#">
                      		</cfif>

                      		    <tr class="urun-row" data-parti-id="#parti_id#">
                      		        <td style=" display:none">#IFLOW_P_ORDER_ID#</td>
                      		        <td style="text-align:right;" nowrap="nowrap">#CURRENTROW#</td>
                      		        <td style="text-align:center;" nowrap="nowrap">#MASTER_PLAN_NUMBER#</td>
                      		        <td style="text-align:center;" nowrap="nowrap">#P_ORDER_PARTI_NUMBER#</td>
                      		        <td style="text-align:center;" >
                      		        	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.popup_list_ezgi_iflow_production_operations&is_form_submitted=1&keyword=#LOT_NO#','longpage');">
                      		                #LOT_NO#
                      		            </a>
                      		        </td>
                      		        <td style="text-align:left;" nowrap="nowrap">#Left(PRODUCT_NAME,80)#<cfif len(PRODUCT_NAME) gt 80>...</cfif></td>
                                    <cfif get_station_sablon_main.POINT_METHOD eq 2> <!---Puanlı ise--->
                                        <td style="text-align:right;">
                                            <cfif isdefined('PUAN_#IFLOW_P_ORDER_ID#')>
                                                #AmountFormat(Evaluate('PUAN_#IFLOW_P_ORDER_ID#'))#
                                            <cfelse>
                                                0
                                            </cfif>
                                        </td>
                                        
                                        <td style="text-align:right; font-weight:bold">
                                            <cfif isdefined('PUAN_#IFLOW_P_ORDER_ID#')>
                                                #AmountFormat(Evaluate('PUAN_#IFLOW_P_ORDER_ID#')*QUANTITY,2)#
                                                <cfset total_point = total_point + (Evaluate('PUAN_#IFLOW_P_ORDER_ID#')*QUANTITY)>
                                                <cfset parti_point = parti_point + (Evaluate('PUAN_#IFLOW_P_ORDER_ID#')*QUANTITY)>
                                            <cfelse>
                                                0
                                            </cfif>
                                        </td>
                      		        </cfif>
                      		        <td style="text-align:right;">#AmountFormat(QUANTITY,2)#</td>
                                    <td style="text-align:center;">#AmountFormat(URETILEN,2)#</td>
									<td style="text-align:center;">
                                    	<cfif get_station_sablon_main.POINT_METHOD eq 1> <!---Süreli ise--->
                                        	#DateFormat(START_DATE,dateformat_style)#
                                        <cfelseif get_station_sablon_main.POINT_METHOD eq 2> <!---Puanlı ise--->
											<cfif isdefined('REAL_DAY_#IFLOW_P_ORDER_ID#') and Evaluate('REAL_DAY_#IFLOW_P_ORDER_ID#') gt 0>
                                                <cfset real_day = Evaluate('REAL_DAY_#IFLOW_P_ORDER_ID#')>
                                                #DateFormat(DateAdd('d',real_day,MASTER_PLAN_START_DATE),dateformat_style)#
                                            <cfelse>
                                                #DateFormat(MASTER_PLAN_START_DATE,dateformat_style)#
                                            </cfif>
                                        </cfif>
                      		        </td>
                      		        <cfloop query="get_operations_group">
                                    	<cfif get_station_sablon_main.POINT_METHOD eq 1> <!---Süreli ise--->
                                        	<cfquery name="get_op_date" dbtype="query">
                                              	SELECT
                                                  	O_START_DATE
                                              	FROM
                                                	get_production_operations
                                              	WHERE
                                                 	IFLOW_P_ORDER_ID = #get_production_operations_group.IFLOW_P_ORDER_ID# AND 
                                                    OPERATION_TYPE_ID = #get_operations_group.OPERATION_TYPE_ID#
                                              	ORDER BY
                                                	O_START_DATE	
                                            </cfquery>
                                        <cfelseif get_station_sablon_main.POINT_METHOD eq 2> <!---Puanlı ise--->
                                            <cfquery name="get_op_date" dbtype="query">
                                                <cfif attributes.x_station_level eq 1>
                                                    SELECT
                                                        O_START_DATE
                                                    FROM
                                                        get_production_operations_list
                                                    WHERE
                                                        STATION_ID = #get_operations_group.STATION_ID#
                                                <cfelse>
                                                    SELECT
                                                        O_START_DATE
                                                    FROM
                                                        get_production_operations_list
                                                    WHERE
                                                        OPERATION_TYPE_ID = #get_operations_group.OPERATION_TYPE_ID#	
                                                </cfif>
                                            </cfquery>
                                        </cfif>
                      		            <cfif attributes.x_station_level eq 1>
                      		                <cfif isdefined('STAGE_#get_production_operations_group.IFLOW_P_ORDER_ID#_#get_operations_group.STATION_ID#')>
                      		                    <cfif Evaluate('STAGE_#get_production_operations_group.IFLOW_P_ORDER_ID#_#get_operations_group.STATION_ID#') eq 1>
                      		                        <cfset renk = 'white'>
                      		                        <cfset renk_1 = 'black'>
                      		                    <cfelseif Evaluate('STAGE_#get_production_operations_group.IFLOW_P_ORDER_ID#_#get_operations_group.STATION_ID#') eq 1.5 or Evaluate('STAGE_#get_production_operations_group.IFLOW_P_ORDER_ID#_#get_operations_group.STATION_ID#') eq 3.5>
                      		                        <cfset renk = 'blue'>
                      		                        <cfset renk_1 = 'white'>
                      		                    <cfelseif Evaluate('STAGE_#get_production_operations_group.IFLOW_P_ORDER_ID#_#get_operations_group.STATION_ID#') eq 4>
                      		                        <cfset renk = 'green'>
                      		                        <cfset renk_1 = 'white'>
                      		                    <cfelseif Evaluate('STAGE_#get_production_operations_group.IFLOW_P_ORDER_ID#_#get_operations_group.STATION_ID#') eq 3>
                      		                        <cfset renk = 'red'>
                      		                        <cfset renk_1 = 'white'>
                      		                    </cfif>
                      		                <cfelse>
                      		                    <cfset renk = 'white'>
                      		                    <cfset renk_1 = 'black'>
                      		                </cfif>
                      		            <cfelse>
                      		                <cfif isdefined('STAGE_#get_production_operations_group.IFLOW_P_ORDER_ID#_#get_operations_group.OPERATION_TYPE_ID#')>
                      		                    <cfif Evaluate('STAGE_#get_production_operations_group.IFLOW_P_ORDER_ID#_#get_operations_group.OPERATION_TYPE_ID#') eq 1>
                      		                        <cfset renk = 'white'>
                      		                        <cfset renk_1 = 'black'>
                      		                    <cfelseif Evaluate('STAGE_#get_production_operations_group.IFLOW_P_ORDER_ID#_#get_operations_group.OPERATION_TYPE_ID#') eq 1.5 or Evaluate('STAGE_#get_production_operations_group.IFLOW_P_ORDER_ID#_#get_operations_group.OPERATION_TYPE_ID#') eq 3.5>
                      		                        <cfset renk = 'blue'>
                      		                        <cfset renk_1 = 'white'>
                      		                    <cfelseif Evaluate('STAGE_#get_production_operations_group.IFLOW_P_ORDER_ID#_#get_operations_group.OPERATION_TYPE_ID#') eq 4>
                      		                        <cfset renk = 'green'>
                      		                        <cfset renk_1 = 'white'>
                      		                    <cfelseif Evaluate('STAGE_#get_production_operations_group.IFLOW_P_ORDER_ID#_#get_operations_group.OPERATION_TYPE_ID#') eq 3>
                      		                        <cfset renk = 'red'>
                      		                        <cfset renk_1 = 'white'>
                      		                    </cfif>
                      		                <cfelse>
                      		                    <cfset renk = 'white'>
                      		                    <cfset renk_1 = 'black'>
                      		                </cfif>
                      		            </cfif>
                                        <cfif get_station_sablon_main.POINT_METHOD eq 1> <!---Süreli ise--->
											<td style="text-align:center; vertical-align:middle; width:90px; <cfif isdefined('biggest_time_operation_type_id_#get_production_operations_group.IFLOW_P_ORDER_ID#') and Evaluate('biggest_time_operation_type_id_#get_production_operations_group.IFLOW_P_ORDER_ID#') eq get_operations_group.OPERATION_TYPE_ID>background-color:mistyrose;<cfelse>background-color:#renk#;</cfif> color:#renk_1#">
												<cfif get_op_date.recordcount>
                                                    #DateFormat(get_op_date.O_START_DATE,dateformat_style)#
                                                </cfif>
                                            </td>
                                        <cfelseif get_station_sablon_main.POINT_METHOD eq 2> <!---Puanlı ise--->
                                            <td style="text-align:center; vertical-align:middle; width:90px; background-color:#renk#; color:#renk_1#">
												<cfif get_op_date.recordcount>
                                                    #DateFormat(get_op_date.O_START_DATE,dateformat_style)#
                                                </cfif>
                                            </td>    
                                        </cfif>
                      		        </cfloop>
                      		    </tr>
                                <cfif get_station_sablon_main.POINT_METHOD eq 2 and len(TOTAL_PRODUCTION_TIME)> <!---Puanlı ise--->
									<cfset total_point = total_point + (TOTAL_PRODUCTION_TIME/3600)>
                             		<cfset parti_point = parti_point + (TOTAL_PRODUCTION_TIME/3600)>
                             	</cfif>
								
                      		    <cfif parti_id neq get_production_operations_group.P_ORDER_PARTI_ID[#get_production_operations_group.currentrow#+1]>
                      		        <tr class="dip-toplam" data-parti-id="#parti_id#">
                      		            <td style="text-align:right;" colspan="5">
                      		                <hr>
                      		            </td>
                                        <cfif get_station_sablon_main.POINT_METHOD eq 2> <!---Puanlı ise--->
                                            <td style="text-align:right;">
                                                #AmountFormat(total_point,2)#	
                                            </td>
                                            <td style="text-align:right; font-weight:bold">
                                                #AmountFormat(parti_point,2)#
                                            </td>
                                        </cfif>
                      		            <td style="text-align:right;" colspan="#col_span#">
                      		                <hr>
                      		            </td>
                      		        </tr>
                      		        <cfset parti_point = 0>
                      		        </tbody>
                      		    </cfif>
                            
							</cfoutput>
                        </cfif>

                 	</cf_grid_list>
    				<cfset adres = url.fuseaction>
                    <cfif len(attributes.keyword)>
                      <cfset adres = '#adres#&keyword=#URLEncodedFormat(attributes.keyword)#'>
                    </cfif>
                    <cfif len(attributes.sort_type)>
                        <cfset adres = '#adres#&sort_type=#attributes.sort_type#'>
                    </cfif>
                    <cfif len(attributes.master_plan_id)>
                        <cfset adres = '#adres#&master_plan_id=#attributes.master_plan_id#'>
                    </cfif>
                    <cf_paging 
                        page="#attributes.page#"
                        maxrows="#attributes.maxrows#"
                        totalrecords="#attributes.totalrecords#"
                        startrow="#attributes.startrow#"
                        adres="#adres#&is_form_submitted=1">
                        <cf_box_footer>
                         
                        </cf_box_footer>
                </cf_box>           
      	</cfif>
		
        <cfif attributes.x_is_parti eq 1>
            <button id="saveButton" style="padding: 8px 16px; background-color: #28a745; color: #fff; border: none; border-radius: 4px; cursor: pointer; float:right;">
                Sıralamayı Kaydet
            </button>
            <button style="padding: 8px 2px; background-color: #fff; color: #fff; border: none; border-radius: 4px; cursor: pointer; float:right;">
                
            </button>
            <button id="sortButton" onClick="hesapla()" style="padding: 8px 16px; background-color: #F00; color: #fff; border: none; border-radius: 4px; cursor: pointer; float:right;">
                Yeniden Hesapla
            </button>
        </cfif>
   	</cf_box>
</div>
<script src="https://cdn.jsdelivr.net/npm/sortablejs@latest/Sortable.min.js"></script>

<script type="text/javascript">

    document.addEventListener("DOMContentLoaded", function () {
        // Parti Taşıma
        new Sortable(document.querySelector('table'), {
            animation: 150,
            handle: ".dip-toplam", // Dip toplam üzerinden taşıma
            draggable: ".parti-group", // <tbody> taşınabilir
            onStart: function (evt) {
                evt.item.classList.add("dragging"); // Parti grubuna sınıf ekle
                console.log("Taşıma başladı: Parti ID", evt.item.dataset.partiId);
            },
            onEnd: function (evt) {
                evt.item.classList.remove("dragging"); // Taşıma bittiğinde sınıfı kaldır
                console.log("Parti sırası değişti");
            }
        });

        // Ürünlerin Taşınması
        document.querySelectorAll('.parti-group').forEach(function (partiGroup) {
            const partiId = partiGroup.dataset.partiId;

            new Sortable(partiGroup, {
                animation: 150,
                group: "urunler", // Her parti için ayrı grup
                draggable: ".urun-row", // Ürün satırları taşınabilir
                onStart: function (evt) {
                    evt.item.classList.add("dragging"); // Ürün satırına sınıf ekle
                },
                onEnd: function (evt) {
                    evt.item.classList.remove("dragging"); // Taşıma bittiğinde sınıfı kaldır
                    console.log("Ürün sırası değişti: Parti ID", partiId);
                }
            });
        });
    });
    
    document.getElementById("saveButton").addEventListener("click", function () {
        const headers = []; // Tablonun başlıklarını tutar
        const resultArray = []; // JSON yapısını tutar

        // Başlıkları oku ve "İstasyonlar" ya da boş olanları filtrele
        document.querySelectorAll("thead th").forEach(function (th) {
            const headerText = th.innerText.trim();

            // "İstasyonlar" başlığı ve boş başlıkları atla
            if (headerText !== "" && headerText.toLowerCase() !== "istasyonlar") {
                headers.push(headerText.replace(/\s+/g, "_").toLowerCase());
            } else {
                headers.push(null);
            }
        });

        // Tüm partileri oku
        document.querySelectorAll("tbody.parti-group").forEach(function (parti) {
            const partiId = parti.dataset.partiId; // Parti ID'sini al
            const partiObj = { parti_id: partiId, urunler: [] };

            // Partiye ait ürün satırlarını döner
            parti.querySelectorAll(".urun-row").forEach(function (row) {
                const rowData = {}; // Her ürün için key-value objesi

                // Hücreleri dönerken null başlıkları filtrele
                row.querySelectorAll("td").forEach(function (cell, index) {
                    if (headers[index] !== null) { // Sadece geçerli başlıklar
                        // Tüm hücre değerlerini al, görünmez olanlar dahil
                        rowData[headers[index]] = cell.textContent.trim();
                    }
                });

                partiObj.urunler.push(rowData);
            });

            resultArray.push(partiObj);
        });
		sor = confirm('Sıralamayı Bu Şekilde Kaydediyorum ?')
		if(sor==true)
		{
			var data = new FormData();
			data.append("form_data", JSON.stringify(resultArray));
			AjaxControlPostDataJson( "AddOns/ezgi/cfc/get_ezgi_iflow_production_operations.cfc?method=new_ranking", data, function (response) {});
			window.location.reload();
		}
		else
			return false;

    });


	document.getElementById('keyword').focus();
	function input_control(){
		if(document.getElementById('is_excel').checked==false)
			return true;		
	}
	function operation(operation_id){
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_list_ezgi_iflow_production_operation_result&operation_id='+operation_id,'list');	
	}
		function hesapla()
	{
		sor = confirm('Sıralamayı Bu Şekilde Hesaplıyorum ?')
		if(sor==true)
		{
			windowopen('<cfoutput>#request.self#?fuseaction=prod.emptypopup_hsp_ezgi_iflow_production_order_master&master_plan_id=#attributes.master_plan_id#</cfoutput>','list');	
			window.location.reload();
		}
	}

</script>