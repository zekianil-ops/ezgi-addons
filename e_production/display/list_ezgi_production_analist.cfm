<!---
    File: list_ezgi_production_analist.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfif not isdefined("attributes.is_excel")>
	<cfsetting showdebugoutput="yes">
</cfif>
<cfset total_amount = 0>
<cfset t_total_amount = 0>
<cfset total_loss = 0>
<cfset t_total_loss = 0>
<cfset total_time = 0>
<cfset t_total_time = 0>
<cfparam name="attributes.controller_emp_id" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.controller_emp" default="">
<cfparam name="attributes.station_id" default="">
<cfparam name="attributes.department_id" default="">
<cfparam name="attributes.operation_type_id" default="">
<cfparam name="attributes.report_type" default="2">
<cfparam name="attributes.lot_no" default="">
<cfparam name="attributes.is_virtual" default="">
<cfparam name="attributes.k_stock_id" default="1">
<cfparam name="attributes.k_lot_no" default="1">
<cfparam name="attributes.k_employee_id" default="1">
<cfparam name="attributes.k_station_id" default="1">
<cfparam name="attributes.k_opertaion_id" default="1">
<cfparam name="attributes.k_action_date" default="1">
<cfparam name="attributes.k_action_id" default="1">
<cfparam name="attributes.k_all" default="1">
<cfparam name="attributes.page" default=1>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<cfif isdefined("attributes.finish_date") and isdate(attributes.finish_date)>
  <cf_date tarih="attributes.finish_date">
  <cfelse>
  <cfset attributes.finish_date = wrk_get_today()>
</cfif>
<cfif isdefined("attributes.start_date") and isdate(attributes.start_date)>
  <cf_date tarih="attributes.start_date">
  <cfelse>
  <cfset attributes.start_date = wrk_get_today()>
</cfif>


<cfquery name="get_station" datasource="#dsn3#">
	SELECT     
    	E.STATION_ID, 
        W.STATION_NAME
	FROM         
    	EZGI_OPERATION_M AS E INNER JOIN
        WORKSTATIONS AS W ON E.STATION_ID = W.STATION_ID
	GROUP BY 
    	E.STATION_ID, 
        W.STATION_NAME
  	ORDER BY
    	W.STATION_NAME
</cfquery>
<cfquery name="get_department" datasource="#dsn#">
	SELECT     
    	DP.DEPARTMENT_ID, 
        DP.DEPARTMENT_HEAD
	FROM         
    	DEPARTMENT AS DP INNER JOIN
        #dsn3_alias#.WORKSTATIONS AS D ON DP.DEPARTMENT_ID = D.DEPARTMENT
	WHERE     
    	DP.DEPARTMENT_STATUS = 1 AND 
        DP.IS_PRODUCTION = 1
	GROUP BY 
    	DP.DEPARTMENT_ID, 
        DP.DEPARTMENT_HEAD
</cfquery>
<cfoutput query="get_station">
	<cfset 'STATION_NAME_#STATION_ID#' = STATION_NAME >
</cfoutput>
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

<cfif isdefined("attributes.is_submitted")>
	<cfquery name="quality_row" datasource="#dsn3#">
    	WITH CTE1 AS 
        (
			SELECT
            	<cfif attributes.k_stock_id eq 1>     
                	EOM.STOCK_ID, 
                    EOM.PRODUCT_NAME,
              	</cfif> 
               	<cfif attributes.k_lot_no eq 1> 
                	EOM.P_ORDER_ID,     
                    EOM.LOT_NO, 
              	</cfif>
                <cfif attributes.k_employee_id eq 1>      
                    <cfif attributes.report_type eq 1> 
                    	ETCOS.EMPLOYEE_ID ACTION_EMPLOYEE_ID,
                    <cfelse>
                    	EOM.ACTION_EMPLOYEE_ID,
                    </cfif>
               	</cfif>
                <cfif attributes.k_station_id eq 1>     
                    EOM.STATION_ID, 
               	</cfif>
                <cfif attributes.k_opertaion_id eq 1>     
                    EOM.OPERATION_TYPE_ID,
                    EOM.OPERATION_CODE,
               	</cfif>
                <cfif attributes.k_action_date eq 1>     
                    EOM.ACTION_START_DATE,
               	</cfif>  
                <cfif attributes.k_action_id eq 1>     
                    <cfif attributes.report_type eq 1> 
                    	ETCOS.OPERATION_RESULT_ID,
                    <cfelse>
                    	EOM.OPERATION_RESULT_ID,
                    </cfif>
               	</cfif> 
                ISNULL(EOM.IS_VIRTUAL,0) AS IS_VIRTUAL,
                SUM(EOM.REAL_AMOUNT) AS REAL_AMOUNT,
                SUM(EOM.LOSS_AMOUNT) AS LOSS_AMOUNT,  
               	SUM(EOM.REAL_TIME) AS REAL_TIME
			FROM 
            	<cfif attributes.report_type eq 1>  
               		EZGI_OPERATION_TIME_COST AS ETCOS WITH (NOLOCK),
                </cfif>
           		EZGI_OPERATION_M AS EOM WITH (NOLOCK)
			WHERE  
            	<cfif attributes.report_type eq 1>
            		ETCOS.OPERATION_RESULT_ID = EOM.OPERATION_RESULT_ID AND
               	</cfif>
            	(EOM.REAL_AMOUNT >0 OR EOM.LOSS_AMOUNT >0)
                <cfif len(attributes.keyword)>
                    AND 
                    	(
                    		EOM.PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
                            EOM.P_ORDER_NO LIKE '%#attributes.keyword#%'
                       	)
                </cfif> 
                <cfif attributes.report_type eq 1>
					<cfif len(attributes.controller_emp_id) and len(attributes.controller_emp)>
                        AND ETCOS.EMPLOYEE_ID = #attributes.controller_emp_id#
                    </cfif> 
                <cfelse>
                	<cfif len(attributes.controller_emp_id) and len(attributes.controller_emp)>
                        AND EOM.ACTION_EMPLOYEE_ID = #attributes.controller_emp_id#
                    </cfif>
                </cfif>
                <cfif len(attributes.start_date)>
                    AND EOM.ACTION_START_DATE >= #attributes.start_date#
                </cfif>
                <cfif len(attributes.finish_date)>
                    AND EOM.ACTION_START_DATE < #dateadd('d',1,attributes.finish_date)#
                </cfif>
                <cfif len(attributes.lot_no)>
                    AND EOM.LOT_NO LIKE '%#attributes.lot_no#%'
                </cfif> 
                <cfif len(attributes.product_id) and len(attributes.product_name)>
                    AND EOM.STOCK_ID IN (SELECT STOCK_ID FROM STOCKS WHERE PRODUCT_ID = #attributes.product_id#)
                </cfif>
                <cfif len(attributes.operation_type_id)>
                    AND EOM.OPERATION_TYPE_ID = #attributes.operation_type_id#
                </cfif>
                <cfif len(attributes.station_id)>
                    AND EOM.STATION_ID=#attributes.station_id#			
                </cfif>
                <cfif len(attributes.department_id)>
                	AND EOM.STATION_ID IN
                    				(
                                    SELECT     
                                    	STATION_ID
									FROM  
                                    	WORKSTATIONS AS D
									WHERE     
                                    	DEPARTMENT = #attributes.department_id#
                                    )
                </cfif>
                <cfif len(attributes.is_virtual)>
                    AND ISNULL(EOM.IS_VIRTUAL,0) = #attributes.is_virtual#			
                </cfif>
			GROUP BY 
               	<cfif attributes.k_stock_id eq 1>     
               		EOM.STOCK_ID, 
                    EOM.PRODUCT_NAME,
              	</cfif> 
               	<cfif attributes.k_lot_no eq 1>   
                	EOM.P_ORDER_ID,   
                    EOM.LOT_NO, 
              	</cfif>
                <cfif attributes.k_employee_id eq 1>      
                    <cfif attributes.report_type eq 1> 
                    	ETCOS.EMPLOYEE_ID,
                    <cfelse>
                    	EOM.ACTION_EMPLOYEE_ID,
                    </cfif>
               	</cfif>
                <cfif attributes.k_station_id eq 1>     
                    EOM.STATION_ID, 
               	</cfif>
                <cfif attributes.k_opertaion_id eq 1>     
                    EOM.OPERATION_TYPE_ID,
                    EOM.OPERATION_CODE,
               	</cfif> 
                <cfif attributes.k_action_date eq 1>     
                    EOM.ACTION_START_DATE,
               	</cfif>
                <cfif attributes.k_action_id eq 1>    
                	<cfif attributes.report_type eq 1> 
                    	ETCOS.OPERATION_RESULT_ID,
                    <cfelse>
                    	EOM.OPERATION_RESULT_ID,
                    </cfif>
               	</cfif> 
                EOM.IS_VIRTUAL
       		),
           CTE2 AS (
				SELECT
					CTE1.*,
					ROW_NUMBER() OVER (	
                    					ORDER BY 
											<cfif attributes.k_lot_no eq 1> 
                                                LOT_NO, 
                                            </cfif>
                                            <cfif attributes.k_opertaion_id eq 1>     
                                                OPERATION_CODE,
                                            </cfif>
                                            <cfif attributes.k_employee_id eq 1>      
                                                ACTION_EMPLOYEE_ID, 
                                            </cfif>
                                            <cfif attributes.k_station_id eq 1>     
                                                STATION_ID, 
                                            </cfif>
                                            <cfif attributes.k_action_date eq 1>     
                                                ACTION_START_DATE,
                                            </cfif>
                                            <cfif attributes.k_action_id eq 1>     
                                                OPERATION_RESULT_ID,
                                            </cfif> 
                                            REAL_AMOUNT desc 
									) AS RowNum,(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
				FROM
					CTE1
			)
            
      	SELECT
				CTE2.*
			FROM
				CTE2
			WHERE
				RowNum BETWEEN #attributes.startrow# and #attributes.startrow#+(#maxrows#-1)
	</cfquery>
    <cfoutput query="quality_row">
		<cfset t_total_amount = t_total_amount+ REAL_AMOUNT>
        <cfset t_total_loss = t_total_loss+ LOSS_AMOUNT>
        <cfset t_total_time = t_total_time+ REAL_TIME>
    </cfoutput>
<cfelse>
	<cfset quality_row.query_count=0>
</cfif>
<cfparam name="attributes.totalrecords" default='#quality_row.query_count#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="quality_control" id="quality_control" method="post" action="#request.self#?fuseaction=prod.popup_ezgi_production_analist">
        	<input name="is_submitted" id="is_submitted" value="1" type="hidden">
            <cf_box_search>
                <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                    <cfsavecontent variable="lot_no"><cf_get_lang dictionary_id='57460.Lot No'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" style="width:150px;" placeholder="Filtre" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group">
                	 <cfinput type="text" style="width:150px;" placeholder="Lot No" maxlength="50" name="lot_no" value="#attributes.lot_no#">
               	</div>
                <div class="form-group">
                	 <select name="department_id" id="department_id" style="width:110px;">
                      	<option value=""><cf_get_lang dictionary_id='57572.Departman'></option>
                     	<cfoutput query="get_department">
                        	<option value="#department_id#" <cfif attributes.department_id eq department_id>selected</cfif>>#department_head#</option>
                      	</cfoutput>
                  	</select>
               	</div>
                <div class="form-group">
                	 <select name="report_type" id="report_type" style="width:110px;">
                     	<option value="1" <cfif attributes.report_type eq 1>selected</cfif>>İstasyondaki Tüm Çalışanlar Bazında</option>
                        <option value="2" <cfif attributes.report_type eq 2>selected</cfif>>Başla-Bitir Yapan Bazında</option>
                  	</select>
               	</div>
                <div class="form-group" id="piece_type_">
                	<div class="col col-12">
                        <div class="col col-6">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                                <cfinput type="text" maxlength="10" name="start_date" value="#dateformat(attributes.start_date,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                            </div>
                        </div>
                        <div class="col col-6">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                                <cfinput type="text" maxlength="10" name="finish_date" value="#dateformat(attributes.finish_date,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
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
            	<div id="detail_search_div" style="display:table-row;" class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                	<cf_box_elements>
                        <div class="col col-12">
                            <div class="form-group medium" id="piece_type_">
                                <label class="col col-2"><cf_get_lang dictionary_id='57657.Ürün'></label>
                              	<div class="col col-10">
                                	<div class="input-group">
                                		<input type="hidden" name="product_id" id="product_id" value="<cfoutput>#attributes.product_id#</cfoutput>">
                        				<input type="text" name="product_name" id="product_name" style="width:100px;" value="<cfoutput>#attributes.product_name#</cfoutput>">
                                    	<span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=quality_control.product_id&field_name=quality_control.product_name','list');"></span>
                                    </div>
                                </div>
                			</div>
                     	</div>
                        <div class="col col-12">
                        	<div class="form-group medium" id="piece_type_">
                                <label class="col col-2"><cf_get_lang dictionary_id='58081.Hepsi'></label>
                                <div class="col col-4">
                                	<select name="k_all" onchange="hepsi();" style="width:70px; height:20px">
                                        <option value="1" <cfif attributes.k_all eq '1'>selected</cfif>><cf_get_lang dictionary_id='58596.Göster'></option>
                                        <option value="0" <cfif attributes.k_all eq '0'>selected</cfif>><cf_get_lang dictionary_id='58628.Gizle'></option>
                                    </select>
                                </div>
                                <label class="col col-2"><cf_get_lang dictionary_id='57657.Ürün'></label>
                                <div class="col col-4">
                                	<select name="k_stock_id" style="width:70px; height:20px">
                                        <option value="1" <cfif attributes.k_stock_id eq '1'>selected</cfif>><cf_get_lang dictionary_id='58596.Göster'></option>
                                        <option value="0" <cfif attributes.k_stock_id eq '0'>selected</cfif>><cf_get_lang dictionary_id='58628.Gizle'></option>
                                    </select>
                                </div>
                           	</div>
                        </div>
                   	</cf_box_elements>
           		</div>
                <div id="detail_search_div2" style="display:table-row;" class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                	<cf_box_elements>
                        <div class="col col-12">
                            <div class="form-group medium" id="piece_type_">
                                <label class="col col-2"><cf_get_lang dictionary_id='57576.Çalışan'></label>
                              	<div class="col col-10">
                                	<div class="input-group">
                                		<input type="hidden" name="controller_emp_id" id="controller_emp_id" value="<cfif len(attributes.controller_emp_id)><cfoutput>#attributes.controller_emp_id#</cfoutput></cfif>">			
                        				<input type="text" name="controller_emp" id="controller_emp" value="<cfif len(attributes.controller_emp_id) and len(attributes.controller_emp)><cfoutput>#attributes.controller_emp#</cfoutput></cfif>" onfocus="AutoComplete_Create('controller_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','controller_emp_id','','3','130');" autocomplete="off" style="width:100px;">
                                    	<span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_emps&field_id=quality_control.controller_emp_id&field_name=quality_control.controller_emp&select_list=1</cfoutput>','list');"></span>
                                    </div>
                                </div>
                			</div>
                     	</div>
                        <div class="col col-12">
                        	<div class="form-group medium" id="piece_type_">
                                <label class="col col-2"><cf_get_lang dictionary_id='32916.Lot No'></label>
                                <div class="col col-4">
                                	<select name="k_lot_no" style="width:70px; height:20px">
                                        <option value="1" <cfif attributes.k_lot_no eq '1'>selected</cfif>><cf_get_lang dictionary_id='58596.Göster'></option>
                                        <option value="0" <cfif attributes.k_lot_no eq '0'>selected</cfif>><cf_get_lang dictionary_id='58628.Gizle'></option>
                                    </select>
                                </div>
                                <label class="col col-2"><cf_get_lang dictionary_id='57576.Çalışan'></label>
                                <div class="col col-4">
                                	<select name="k_employee_id" style="width:70px; height:20px">
                                        <option value="1" <cfif attributes.k_employee_id eq '1'>selected</cfif>><cf_get_lang dictionary_id='58596.Göster'></option>
                                        <option value="0" <cfif attributes.k_employee_id eq '0'>selected</cfif>><cf_get_lang dictionary_id='58628.Gizle'></option>
                                    </select>
                                </div>
                           	</div>
                        </div>
                   	</cf_box_elements>
           		</div>
                
                <div id="detail_search_div3" style="display:table-row;" class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                	<cf_box_elements>
                        <div class="col col-12">
                            <div class="form-group medium" id="piece_type_">
                                <label class="col col-2"><cf_get_lang dictionary_id='58834.İstasyon'></label>
                              	<div class="col col-10">
                                	<select name="station_id" id="station_id" style="width:110px; height:20px">
                                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                        <cfoutput query="get_station">
                                            <option value="#station_id#" <cfif attributes.station_id eq station_id>selected</cfif>>#station_name#</option>
                                        </cfoutput>
                                    </select>
                                </div>
                			</div>
                     	</div>
                        <div class="col col-12">
                        	<div class="form-group medium" id="piece_type_">
                                <label class="col col-2"><cf_get_lang dictionary_id='58834.İstasyon'></label>
                                <div class="col col-4">
                                	<select name="k_station_id" style="width:70px; height:20px">
                                        <option value="1" <cfif attributes.k_station_id eq '1'>selected</cfif>><cf_get_lang dictionary_id='58596.Göster'></option>
                                        <option value="0" <cfif attributes.k_station_id eq '0'>selected</cfif>><cf_get_lang dictionary_id='58628.Gizle'></option>
                                    </select>
                                </div>
                                <label class="col col-2"><cf_get_lang dictionary_id='29419.Operasyon'></label>
                                <div class="col col-4">
                                	<select name="k_opertaion_id" style="width:70px; height:20px">
                                        <option value="1" <cfif attributes.k_opertaion_id eq '1'>selected</cfif>><cf_get_lang dictionary_id='58596.Göster'></option>
                                        <option value="0" <cfif attributes.k_opertaion_id eq '0'>selected</cfif>><cf_get_lang dictionary_id='58628.Gizle'></option>
                                    </select>
                                </div>
                           	</div>
                        </div>
                   	</cf_box_elements>
           		</div>
                <div id="detail_search_div4" style="display:table-row;" class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                	<cf_box_elements>
                        <div class="col col-12">
                            <div class="form-group medium" id="piece_type_">
                                <label class="col col-2"><cf_get_lang dictionary_id='29419.Operasyon'></label>
                              	<div class="col col-10">
                                	<select name="operation_type_id" id="operation_type_id" style="width:150px; height:20px">
                                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                        <cfoutput query="get_operation">
                                            <option value="#operation_type_id#" <cfif attributes.operation_type_id eq operation_type_id>selected</cfif>>#OPERATION_TYPE#</option>
                                        </cfoutput>
                                    </select>
                                </div>
                			</div>
                     	</div>
                        <div class="col col-12">
                            <div class="col col-6">
                                <div class="form-group" id="piece_type_">
                                    <label class="col col-4"><cf_get_lang dictionary_id='44095.Üretim Sonuç'></label>
                                    <div class="col col-8">
                                        <select name="k_action_id" style="width:70px; height:20px">
                                            <option value="1" <cfif attributes.k_action_id eq '1'>selected</cfif>><cf_get_lang dictionary_id='58596.Göster'></option>
                                            <option value="0" <cfif attributes.k_action_id eq '0'>selected</cfif>><cf_get_lang dictionary_id='58628.Gizle'></option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="col col-6">
                                <div class="form-group" id="piece_type_">
                                    <label class="col col-4"><cf_get_lang dictionary_id='493.Üretim Tarihi'></label>
                                    <div class="col col-8">
                                        <select name="k_action_date" style="width:70px; height:20px">
                                            <option value="1" <cfif attributes.k_action_date eq '1'>selected</cfif>><cf_get_lang dictionary_id='58596.Göster'></option>
                                            <option value="0" <cfif attributes.k_action_date eq '0'>selected</cfif>><cf_get_lang dictionary_id='58628.Gizle'></option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                   	</cf_box_elements>
           		</div>
       		</cf_box_search_detail>
      	</cfform>
    </cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='39594.Üretim Sonuç Analizi'></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>
        	<thead>
                <tr>
                    <cfset row_ = 1>
                    <th style="width:25px; text-align:center"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <cfif attributes.k_stock_id eq 1> 
                        <th style="text-align:center"><cf_get_lang dictionary_id='57657.Ürün'></th>
                        <cfset row_ = row_ +1>
                    </cfif>
                    <cfif attributes.k_lot_no eq 1>
                        <th style="text-align:center">Lot No</th>
                        <cfset row_ = row_ +1>
                    </cfif>
                    <cfif attributes.k_employee_id eq 1> 
                        <th style="text-align:center"><cf_get_lang dictionary_id='57576.Çalışan'></th>
                        <cfset row_ = row_ +1>
                    </cfif>
                    <cfif attributes.k_station_id eq 1>
                        <th style="text-align:center"><cf_get_lang dictionary_id='58834.İstasyon'></th>
                        <cfset row_ = row_ +1>
                    </cfif>
                    <cfif attributes.k_opertaion_id eq 1>
                        <th style="text-align:center"><cf_get_lang dictionary_id='29419.Operasyon'></th>
                        <cfset row_ = row_ +1>
                    </cfif>
                    <cfif attributes.k_action_id eq 1> 
                    	<th style="text-align:center"><cf_get_lang dictionary_id='44095.Üretim Sonuç'></th>
                        <cfset row_ = row_ +1>
                    </cfif>
                    <cfif attributes.k_action_date eq 1>
                        <th style="text-align:center"><cf_get_lang dictionary_id='493.Üretim Tarihi'></th>
                        <cfset row_ = row_ +1>
                    </cfif>
                    <th style="text-align:center"><cf_get_lang dictionary_id='58927.Sanal'></th>
                    <th style="text-align:center"><cf_get_lang dictionary_id='57456.Üretim'></th>
                    <th style="text-align:center"><cf_get_lang dictionary_id='29471.Fire'></th>
                    <th style="text-align:center"><cf_get_lang dictionary_id='29513.Süre'></th>
                    <th width="0"></th>
               </tr>
            </thead>
            <tbody>
				<cfif isdefined("attributes.is_submitted") and quality_row.query_count gt 0>
                    <cfoutput query="quality_row">
                    	<cfif attributes.k_action_id eq 1> 
                            <cfif isdefined('krow') and krow eq OPERATION_RESULT_ID>
                            
                            <cfelse>
                                <tr class="color-row">
                                    <td style="height:1mm" colspan="<cfoutput>#row_#+3</cfoutput>"></td>
                                </tr>
                                <cfset krow = OPERATION_RESULT_ID>
                            </cfif>
                        </cfif>
                        <tr class="color-row">
                            <td style="text-align:right">#RowNum#</td>
                            <cfif attributes.k_stock_id eq 1>     
                                <td style="text-align:left">#product_name#</td>
                            </cfif>
                            <cfif attributes.k_lot_no eq 1>      
                                <td style="text-align:center">
                                    <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.order&event=upd&upd=#P_ORDER_ID#','longpage');" class="tableyazi">
                                        #LOT_NO#
                                    </a>
                                </td> 
                            </cfif>
                            <cfif attributes.k_employee_id eq 1>      
                                <td style="text-align:center">#get_emp_info(ACTION_EMPLOYEE_ID,0,0)#</td> 
                            </cfif>
                            <cfif attributes.k_station_id eq 1>     
                                <td style="text-align:center">#Evaluate('STATION_NAME_#STATION_ID#')#</td>
                            </cfif>
                            <cfif attributes.k_opertaion_id eq 1>     
                                <td style="text-align:center">#Evaluate('OPERATION_TYPE_#OPERATION_TYPE_ID#')#</td>
                            </cfif>
                            <cfif attributes.k_action_id eq 1>   
                                <td style="text-align:center">#OPERATION_RESULT_ID#</td>  
                            </cfif>
                            <cfif attributes.k_action_date eq 1>   
                                <td style="text-align:center">#dateformat(ACTION_START_DATE,'dd/mm/yyyy')#</td>  
                            </cfif> 
                            <td style="text-align:right"><cfif IS_VIRTUAL eq 1>Sanal<cfelse>Gerçek</cfif></td>
                            <cfset totaltime = "#REAL_TIME\60#:#numberformat(REAL_TIME % 60, "00")#">
                            <td style="text-align:right">#Tlformat(REAL_AMOUNT)#</td>
                            <td style="text-align:right">#Tlformat(LOSS_AMOUNT)#</td>
                            <td style="text-align:right">#TlFormat(totaltime,0)#</td> 
                            <td></td>
                            <cfset total_amount = total_amount+ REAL_AMOUNT>
                            <cfset total_loss = total_loss+ LOSS_AMOUNT>
                            <cfset total_time = total_time+ REAL_TIME>  
                        </tr>
                        <cfset son_row = currentrow>
                    </cfoutput>
                    <tfoot>
                        <tr>
                            <td colspan="<cfoutput>#row_#</cfoutput>"><cf_get_lang dictionary_id='57492.Toplam'> : </td>
                            <td></td>
                            <td style="text-align:right" class="txtbold">
                                <cfoutput>
                                    <cfif attributes.totalrecords gt son_row>
                                        #TLFormat(total_amount)#
                                    <cfelse>
                                        #TLFormat(t_total_amount)#
                                    </cfif>		
                                </cfoutput>
                            </td>
                            <td style="text-align:right" class="txtbold">
                                <cfoutput>
                                    <cfif attributes.totalrecords gt son_row>
                                        #TLFormat(total_loss)#
                                    <cfelse>
                                        #TLFormat(t_total_loss)#
                                    </cfif>		
                                </cfoutput>
                            </td>
                            <td style="text-align:right" class="txtbold">
                                <cfoutput>
                                    <cfif attributes.totalrecords gt son_row>
                                        <cfset a_totaltime = "#total_time\60#:#numberformat(total_time % 60, "00")#">
                                        #TLFormat(a_totaltime,0)#
                                    <cfelse>
                                        <cfset t_totaltime = "#t_total_time\60#:#numberformat(t_total_time % 60, "00")#">
                                        #TLFormat(t_totaltime,0)#
                                    </cfif>		
                                </cfoutput>
                            </td>
                            <!---<td></td>--->
                            <td></td>
                        </tr>
                    </tfoot>  
                    <!-- sil -->
                <cfelse>
                    <tr><td class="color-row" colspan="20"><cfif not isdefined("attributes.is_submitted")><cf_get_lang dictionary_id='57701.Filtre ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'> !</cfif></td></tr>
                </cfif>
            </tbody>
       	</cf_grid_list>
		<cfset adres = "prod.popup_ezgi_production_analist">
        <cfif len(attributes.product_id) and len(attributes.product_name)>
            <cfset adres = "#adres#&product_id=#attributes.product_id#&product_name=#attributes.product_name#">
        </cfif>
        <cfif len(attributes.keyword)>
            <cfset adres = "#adres#&keyword=#attributes.keyword#">
        </cfif>
        <cfif len(attributes.start_date)>
            <cfset adres = "#adres#&start_date=#dateformat(attributes.start_date,dateformat_style)#">
        </cfif>
        <cfif len(attributes.finish_date)>
            <cfset adres = "#adres#&finish_date=#dateformat(attributes.finish_date,dateformat_style)#">
        </cfif>
        <cfif len(attributes.lot_no)>
            <cfset adres = "#adres#&lot_no=#attributes.lot_no#">
        </cfif>
        <cfif len(attributes.station_id)>
            <cfset adres = "#adres#&station_id=#attributes.station_id#">
        </cfif>
        <cfif len(attributes.department_id)>
            <cfset adres = "#adres#&department_id=#attributes.department_id#">
        </cfif>
        <cfif len(attributes.operation_type_id)>
            <cfset adres = "#adres#&operation_type_id=#attributes.operation_type_id#">
        </cfif>
        <cfif len(attributes.controller_emp)>
            <cfset adres = "#adres#&controller_emp=#attributes.controller_emp#">
        </cfif>
        <cfif len(attributes.controller_emp_id)>
            <cfset adres = "#adres#&controller_emp_id=#attributes.controller_emp_id#">
        </cfif>
        <cfif len(attributes.k_stock_id)>
            <cfset adres = "#adres#&k_stock_id=#attributes.k_stock_id#">
        </cfif>
        <cfif len(attributes.k_lot_no)>
            <cfset adres = "#adres#&k_lot_no=#attributes.k_lot_no#">
        </cfif>
        <cfif len(attributes.k_employee_id)>
            <cfset adres = "#adres#&k_employee_id=#attributes.k_employee_id#">
        </cfif>
        <cfif len(attributes.k_station_id)>
            <cfset adres = "#adres#&k_station_id=#attributes.k_station_id#">
        </cfif>
        <cfif len(attributes.k_opertaion_id)>
            <cfset adres = "#adres#&k_opertaion_id=#attributes.k_opertaion_id#">
        </cfif>
        <cfif len(attributes.k_action_date)>
            <cfset adres = "#adres#&k_action_date=#attributes.k_action_date#">
        </cfif>
        <cfif len(attributes.k_all)>
            <cfset adres = "#adres#&k_all=#attributes.k_all#">
        </cfif>
        <cfif len(attributes.report_type)>
            <cfset adres = "#adres#&report_type=#attributes.report_type#">
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
	function hepsi()
	{
		var hepsi=document.quality_control.k_all.value;
		document.quality_control.k_stock_id.value=hepsi;
		document.quality_control.k_lot_no.value=hepsi;
		document.quality_control.k_employee_id.value=hepsi;
		document.quality_control.k_station_id.value=hepsi;
		document.quality_control.k_opertaion_id.value=hepsi;
		document.quality_control.k_action_date.value=hepsi;
		document.quality_control.k_action_id.value=hepsi;
	}
</script>