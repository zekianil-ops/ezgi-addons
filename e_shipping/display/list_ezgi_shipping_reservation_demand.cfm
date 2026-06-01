<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.prod_cat" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.order_employee" default="#get_emp_info(session.ep.userid,0,0)#">
<cfparam name="attributes.order_employee_id" default="#session.ep.userid#">
<cfparam name="attributes.listing_type" default="2">
<cfparam name="attributes.sort_type" default="2">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.totalrecords" default="0">
<cfquery name="get_default_department" datasource="#dsn#">
	SELECT DEPARTMENT_ID, LOCATION_ID FROM EMPLOYEE_POSITION_DEPARTMENTS WHERE POSITION_CODE = #session.ep.POSITION_CODE# AND OUR_COMPANY_ID = #session.ep.COMPANY_ID#
</cfquery>
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'> 
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1 >

<cfif isdefined("attributes.form_varmi")>
    <cfquery name="GET_SHIPPING_DEMAND" datasource="#dsn3#"><!---Sevk Planları ve Sevk Talepleri Listeleniyor--->
        SELECT 
        	ESD.SHIPPING_DEMAND_ID, 
            ESD.ORDER_ROW_ID, 
            ESD.DEMAND_ORDER_ROW_ID, 
            ESD.EMPLOYEE_ID, 
            ESD.DEMAND_EMPLOYEE_ID, 
            ESD.DEMAND_STATUS_ID, 
            ESD.SHIPPING_DEMAND_STAGE, 
            ESD.START_DATE, 
         	ESD.FINISH_DATE,
            ORR.PRODUCT_NAME, 
            O.ORDER_NUMBER,
            O.ORDER_ID, 
            O1.ORDER_ID DEMAND_ORDER_ID,
            O1.ORDER_NUMBER AS DEMAND_ORDER_NUMBER
		FROM     
        	EZGI_SHIPPING_DEMAND AS ESD INNER JOIN
            ORDER_ROW AS ORR ON ESD.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
            ORDER_ROW AS ORR1 ON ESD.DEMAND_ORDER_ROW_ID = ORR1.ORDER_ROW_ID INNER JOIN
            ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
            ORDERS AS O1 ON ORR1.ORDER_ID = O1.ORDER_ID
     	WHERE
        	1=1
            <cfif len(attributes.keyword)>
             	AND 
               	(
                   	O.ORDER_NUMBER LIKE '%#attributes.keyword#%' OR
                 	O1.ORDER_NUMBER LIKE '%#attributes.keyword#%'
            	)
     		</cfif>
            <cfif isdefined('attributes.product_id') and len(attributes.product_id)>
           		AND ORR.PRODUCT_ID = #attributes.product_id#
        	</cfif>
            <cfif isdefined('attributes.prod_cat') and len(attributes.prod_cat)>
              	AND ORR.PRODUCT_ID IN (SELECT PRODUCT_ID FROM STOCKS WHERE S.STOCK_CODE LIKE N'#attributes.prod_cat#%')                          
        	</cfif>
            <cfif isdefined('attributes.start_date') and len(attributes.start_date)>
             	AND ESD.START_DATE >= #attributes.start_date#
          	</cfif>
          	<cfif isdefined('attributes.finish_date') and len(attributes.finish_date)>
          		AND ESD.START_DATE < #DateAdd('d',1,attributes.finish_date)#
          	</cfif>
            <cfif len(attributes.order_employee_id) and len(attributes.order_employee)>
             	AND ESD.EMPLOYEE_ID = #attributes.order_employee_id#
          	</cfif>
            <cfif len(attributes.listing_type)>
            	AND ESD.DEMAND_STATUS_ID = #attributes.listing_type#
            </cfif>
      	ORDER BY
        	ESD.START_DATE
            <cfif attributes.sort_type eq 2>
            	desc
            </cfif>
    </cfquery>
    <cfset arama_yapilmali = 0>
    <cfset attributes.totalrecords = GET_SHIPPING_DEMAND.recordcount>
<cfelse>
	<cfset arama_yapilmali = 1>
	<cfset GET_SHIPPING_DEMAND.recordcount = 0>
</cfif>
<cfquery name="GET_PRODUCT_CATS" datasource="#dsn1#">
	SELECT     
    	PC.HIERARCHY, 
        PC.PRODUCT_CAT
	FROM         
    	PRODUCT_CAT AS PC INNER JOIN
        PRODUCT_CAT_OUR_COMPANY AS PCOC ON PC.PRODUCT_CATID = PCOC.PRODUCT_CATID
	WHERE     
    	PCOC.OUR_COMPANY_ID = #session.ep.company_id# 
 	ORDER BY
    	PRODUCT_CAT
</cfquery>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="order_form" method="post" action="#request.self#?fuseaction=sales.list_ezgi_shipping_reservation_demand">
        	<input name="form_varmi" id="form_varmi" value="1" type="hidden">
            <cfinput type="hidden" name="today_value" id="today_value" value="#DateFormat(now(),dateformat_style)#">
            <cf_box_search>
                <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group" id="form_ul_keyword">
                	<select name="listing_type" id="listing_type" style="width:120px;height:20px">
						<option value="" <cfif attributes.listing_type eq ''>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                      	<option value="1" <cfif attributes.listing_type eq '1'>selected</cfif>>Cevaplanmayanlar</option>
                        <option value="2" <cfif attributes.listing_type eq '2'>selected</cfif>>Olumsuz Cevaplananlar</option>
                        <option value="3" <cfif attributes.listing_type eq '3'>selected</cfif>>Olumlu Cevaplananlar</option>
					</select>
                </div>
                <div class="form-group" id="form_ul_sort">
                	<select name="sort_type" id="sort_type" style="width:160px;height:20px">
                      	<option value="1" <cfif attributes.sort_type eq 1>selected</cfif>><cf_get_lang dictionary_id='36818.Teslim Tarihine Göre Artan'></option>
                     	<option value="2" <cfif attributes.sort_type eq 2>selected</cfif>><cf_get_lang dictionary_id='36819.Teslim Tarihine Göre Azalan'></option>
                 	</select>
                </div>
                <div class="form-group" id="form_ul_employee">
                 	<div class="input-group">
                      	<input type="hidden" name="order_employee_id" id="order_employee_id" value="<cfif isdefined('attributes.order_employee_id') and len(attributes.order_employee_id) and isdefined('attributes.order_employee') and len(attributes.order_employee)><cfoutput>#attributes.order_employee_id#</cfoutput></cfif>">
                     	<input name="order_employee" type="text" id="order_employee" style="width:115px;" onfocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','order_employee_id','','3','125');" value="<cfif isdefined('attributes.order_employee_id') and len(attributes.order_employee_id)><cfoutput>#attributes.order_employee#</cfoutput></cfif>" autocomplete="off" placeholder="Talep Eden">	
                    	<span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=order_form.order_employee_id&field_name=order_form.order_employee&is_form_submitted=1&select_list=1','list');"></span>
                	</div>      
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
                <div class="form-group small">
                 	<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Kayıt Sayısı Hatalı!'></cfsavecontent>
                 	<cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,1000" required="yes" message="#message#">
            	</div>
               	<div class="form-group">
                	<cf_wrk_search_button search_function='input_control()' button_type="4">
             	</div>
          	</cf_box_search>
          	<cf_box_search_detail>
            	<div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="1" sort="true">
					<div class="form-group" id="form_ul_urun">
                        <div class="input-group">
                        	<input type="hidden" name="product_id" id="product_id" <cfif len(attributes.product_id) and len(attributes.product_name)>value="<cfoutput>#attributes.product_id#</cfoutput>"</cfif>>
                        	<input name="product_name" type="text" id="product_name" style="width:120px;" onfocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME','get_product','0','PRODUCT_ID','product_id','','3','100');" value="<cfif len(attributes.product_id) and len(attributes.product_name)><cfoutput>#attributes.product_name#</cfoutput></cfif>" autocomplete="off"  placeholder="<cf_get_lang dictionary_id='57657.Ürün'>">
                            <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=order_form.product_id&field_name=order_form.product_name&keyword='+encodeURIComponent(document.order_form.product_name.value),'list');"></span>
                        </div>      
                    </div>
                    
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="2" sort="true">
                  	<div class="form-group" id="form_ul_kategori">
                    	<select name="prod_cat" id="prod_cat" style="width:140px;height:20px">
                            <option value=""><cf_get_lang dictionary_id='57567.Ürün Kategorileri'></option>
                            <cfoutput query="GET_PRODUCT_CATS">
                            	<cfif listlen(hierarchy,".") gte 4>
                                <option value="#hierarchy#"<cfif (attributes.prod_cat eq hierarchy) and len(attributes.prod_cat) eq len(hierarchy)> selected</cfif>>#product_cat#</option>
                                </cfif>
                            </cfoutput>
                        </select>
                    </div> 
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="3" sort="true">

              	</div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="4" sort="true">
                	
                </div>
         	</cf_box_search_detail>
      	</cfform>
   	</cf_box>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id="1353.Rezervasyon Talebi"></cfsavecontent>
    <cf_box title="#message#" uidrop="1" hide_table_column="1" woc_setting = "#{ checkbox_name : 'print_invoice_id', print_type : 10 }#">
    	<cf_grid_list sort="1">
        	<thead>
             	<tr>
                    <th style="width:30px;text-align:center" class="header_icn_txt" rowspan="2"><cf_get_lang dictionary_id='58577.Sira'></th>
                    <th style="text-align:center" rowspan="2">Süreç</th>
                    <th style="text-align:center" colspan="4" >Talep Eden</th>
                    <th style="text-align:center" colspan="3">Talep Edilen</th>
                    
                    <!-- sil -->
                    <th style="width:25px;text-align:center" rowspan="2"></th>
                    <th style="width:25px;text-align:center" rowspan="2"></th>
                    <!-- sil -->
               	</tr>
                <tr>     
                    <th style="text-align:center">Tarihi</th>
                    <th style="text-align:center">Sipariş No</th>
                    <th style="text-align:center">Ürün</th>
                    <th style="text-align:center">Çalışan</th>
                    
                    <th style="text-align:center">Sipariş No</th>
                    <th style="text-align:center">Çalışan</th>
                    <th style="text-align:center">Cevap Tarihi</th>
                </tr>
            </thead>
            <tbody>
                <cfif GET_SHIPPING_DEMAND.recordcount>
                	<cfquery  name="GET_PROCESS" datasource="#DSN#">
                   		SELECT STAGE, PROCESS_ROW_ID FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID IN (#ListDeleteDuplicates(ValueList(GET_SHIPPING_DEMAND.SHIPPING_DEMAND_STAGE))#)
                	</cfquery>
                	<cfoutput query="GET_SHIPPING_DEMAND" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                     	<tr>
                      		<td style="text-align:right">#currentrow#</td>
                         	<td style="text-align:center">
                                <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.list_ezgi_shipping_reservation_demand&event=upd&SHIPPING_DEMAND_ID=#SHIPPING_DEMAND_ID#','list');" class="tableyazi" title="<cf_get_lang dictionary_id='57464.Güncelle'>">
                            		#GET_PROCESS.STAGE#
                              	</a>
                            </td>
                            <td style="text-align:center">#DateFormat(START_DATE,dateformat_style)#</td>
                          	<td style="text-align:center">
                              	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.list_order&event=upd&order_id=#ORDER_ID#','longpage');" class="tableyazi" title="Satış Siparişine Git">
                                  	#ORDER_NUMBER#
                              	</a>
                         	</td>
                          	<td style="text-align:left">#PRODUCT_NAME#</td>
                            <td style="text-align:left">#get_emp_info(EMPLOYEE_ID,0,0)#</td>
                            
                            <td style="text-align:center">
                              	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.list_order&event=upd&order_id=#DEMAND_ORDER_ID#','longpage');" class="tableyazi" title="Satış Siparişine Git">
                                  	#DEMAND_ORDER_NUMBER#
                              	</a>
                         	</td>
                            <td style="text-align:left">#get_emp_info(DEMAND_EMPLOYEE_ID,0,0)#</td>
                            <td style="text-align:center">#DateFormat(FINISH_DATE,dateformat_style)#</td>
                            <!-- sil -->
                          	<td style="text-align:center"> <!---Cevap Durumu--->
                              	<cfif GET_SHIPPING_DEMAND.DEMAND_STATUS_ID eq 1>
                                   	<img src="../../../images/yellow_glob.gif" border="0" title="Cevaplanmadı" />
                              	<cfelseif GET_SHIPPING_DEMAND.DEMAND_STATUS_ID eq 2>
                                 	<img src="../../../images/green_glob.gif" border="0" title="Olumlu"/>
                             	<cfelseif GET_SHIPPING_DEMAND.DEMAND_STATUS_ID eq 3>
                                 	<img src="../../../images/red_glob.gif" border="0" title="Olumsuz"/>
                               	</cfif>
                      		 </td>
                             <td style="text-align:center">
                            	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.list_ezgi_shipping_reservation_demand&event=upd&SHIPPING_DEMAND_ID=#SHIPPING_DEMAND_ID#','list');" class="tableyazi" title="<cf_get_lang dictionary_id='57464.Güncelle'>">
                               		<i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i>
                             	</a>
                     		</td>
    						<!-- sil -->
                     	</tr>
                    	<cfset son_row = currentrow>
                 	</cfoutput>      
                <cfelse>
                    <tr>
                        <td colspan="20"><cfif arama_yapilmali neq 1><cf_get_lang dictionary_id='57484.Kayit Yok'>!<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'>!</cfif></td>
                    </tr>
                </cfif>	
           	</tbody>
       	</cf_grid_list>
		<cfset url_str = 'sales.list_ezgi_shipping_reservation_demand'>
        <cfif isdefined("attributes.form_varmi") and attributes.totalrecords gt attributes.maxrows>
            <cfif isdefined("attributes.product_id") and len(attributes.product_id) and isdefined("attributes.product_name") and len(attributes.product_name)>
                <cfset url_str = url_str & "&product_id=#attributes.product_id#&product_name=#attributes.product_name#">
            </cfif>
            <cfif isdefined("attributes.employee_id") and len(attributes.employee_id) and isdefined("attributes.employee") and len(attributes.employee)>
                <cfset url_str = url_str & "&employee_id=#attributes.employee_id#&employee=#attributes.employee#">
            </cfif>
            
            <cfif isdefined("attributes.prod_cat") and len(attributes.prod_cat)>
                <cfset url_str = url_str & "&prod_cat=#attributes.prod_cat#">
            </cfif>
            <cfif isdefined("attributes.listing_type") and len(attributes.listing_type)>
                <cfset url_str = "#url_str#&listing_type=#attributes.listing_type#">
            </cfif>
            <cfif isdate(attributes.start_date)>
                <cfset url_str = url_str & "&start_date=#dateformat(attributes.start_date,dateformat_style)#">
            </cfif>
            <cfif isdate(attributes.finish_date)>
                <cfset url_str = url_str & "&finish_date=#dateformat(attributes.finish_date,dateformat_style)#">
            </cfif>
            <cfif isdefined('attributes.sort_type')>
                <cfset url_str = url_str & "&sort_type=#attributes.sort_type#">
            </cfif>
            <cf_paging 
                page="#attributes.page#"
                maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                startrow="#attributes.startrow#"
                adres="#attributes.fuseaction#&#url_str#&form_varmi=1">
        </cfif>
 	</cf_box>
</div>
<script language="javascript">
	function input_control()
	{
			return true
	}
</script>