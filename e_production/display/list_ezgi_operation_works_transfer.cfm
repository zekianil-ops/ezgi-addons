<!---
    File: list_ezgi_iflow_operations.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/07/2022
    Description:
--->
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.master_plan_id" default="">
<cfparam name="attributes.record_emp_id" default="">
<cfparam name="attributes.record_emp_name" default="">
<cfparam name="attributes.oby" default="1">
<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.shift_id" default="">
<cfparam name="attributes.project_head" default="">
<cfparam name="attributes.master_plan_status" default="1">
<cfparam name="attributes.process_type" default="3">
<cfparam name="attributes.page" default=1>
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

<cfset kapasite_kullanim_orani = 0>
<cfset makine_sayisi = 0>
<cfquery name="get_master_plan" datasource="#dsn3#">
	SELECT        
    	MASTER_PLAN_ID, 
        MASTER_PLAN_NUMBER, 
        MASTER_PLAN_DETAIL
	FROM            
    	EZGI_IFLOW_MASTER_PLAN WITH (NOLOCK)
  	<cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
        WHERE 
            MASTER_PLAN_CAT_ID =    
            
                    (
                        SELECT        
                            MASTER_PLAN_CAT_ID
                        FROM       
                            EZGI_IFLOW_MASTER_PLAN AS M
                        WHERE        
                            MASTER_PLAN_ID = #attributes.master_plan_id#
                    )
    </cfif>
	ORDER BY 
    	MASTER_PLAN_NUMBER
</cfquery>
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
<cfif isdefined("attributes.is_submitted")>
	<cfquery name="get_production_operations" datasource="#DSN3#">
		SELECT    
        	CASE 
                                WHEN 
                                    ISNULL(S.IS_PROTOTYPE,0) = 0
                                THEN 
                                    S.PRODUCT_NAME
                                ELSE
                                    (
                                        SELECT        
                                            TOP (1) DESIGN_MAIN_NAME
                                        FROM            
                                            EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
                                        WHERE        
                                            MAIN_SPECT_RELATED_ID = EOM.SPEC_MAIN_ID
                                        ORDER BY 
                                            DESIGN_MAIN_ROW_ID DESC
                                        UNION ALL
                                        SELECT        
                                            TOP (1) PACKAGE_NAME
                                        FROM        
                                            EZGI_DESIGN_PACKAGE_ROW WITH (NOLOCK)
                                        WHERE        
                                            PACKAGE_SPECT_RELATED_ID = EOM.SPEC_MAIN_ID
                                        ORDER BY 
                                            PACKAGE_ROW_ID DESC
                                        UNION ALL
                                        SELECT        
                                            TOP (1) PIECE_NAME
                                        FROM            
                                            EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
                                        WHERE        
                                            PIECE_SPECT_RELATED_ID = EOM.SPEC_MAIN_ID
                                        ORDER BY 
                                            PIECE_ROW_ID DESC
                                    )
            END	AS PRODUCT_NAME,
           	S.PRODUCT_NAME AS NAME_PRODUCT,     
        	EOM.P_ORDER_ID, 
            EOM.PROJECT_ID, 
            EOM.LOT_NO, 
            EOM.P_ORDER_NO, 
            EOM.IS_STAGE, 
            EOM.STOCK_CODE, 
            EOM.SPEC_MAIN_ID, 
            EOM.STOCK_ID, 
            EOM.PRODUCT_ID, 
            EOM.SPECT_VAR_NAME, 
            EOM.QUANTITY, 
            EOM.P_OPERATION_ID, 
            EOM.OPERATION_TYPE_ID, 
            EOM.OPERATION_CODE, 
            EOM.OPERATION_TYPE, 
            EOM.AMOUNT, 
            EOM.STAGE, 
            EOM.STATION_ID, 
            EOM.REAL_TIME, 
            ISNULL(EOM.WAIT_TIME,0) AS WAIT_TIME, 
            EOTC.EMPLOYEE_ID, 
            EOTC.TIME_COST_START_DATE, 
            EOTC.TIME_COST_FINISH_DATE,
            EOM.REAL_AMOUNT, 
            EOM.STATION_NAME, 
            EOM.OPERATION_RESULT_ID, 
            EOM.COMMENT2, 
            EOM.UPDATE_DATE, 
            EOM.RECORD_DATE,
            PP.PROJECT_NUMBER, 
            PP.PROJECT_HEAD, 
            LEFT(LTRIM(PW.WORK_HEAD), 5) AS WORK_CONNECT_CODE, 
            PW.WORK_HEAD,
            PW.WORK_ID,
            S.IS_PROTOTYPE,
            EOTC.OVERTIME_TYPE,
            EOTC.TIME_COST_TYPE,
            EOTC.EZGI_OPERATION_TIME_COST_ID,
            EOTC.TIME_COST_MINUTE,
            ISNULL((SELECT TIME_COST_ID FROM #dsn_alias#.TIME_COST WHERE P_OPERATION_RESULT_ID = EOTC.EZGI_OPERATION_TIME_COST_ID),0) AS TIME_COST_ID
		FROM            
        	#dsn_alias#.PRO_WORKS AS PW WITH (NOLOCK) INNER JOIN
            #dsn_alias#.PRO_PROJECTS AS PP WITH (NOLOCK) ON PW.PROJECT_ID = PP.PROJECT_ID RIGHT OUTER JOIN
           	EZGI_OPERATION_M AS EOM WITH (NOLOCK) ON LEFT(LTRIM(PW.WORK_HEAD), 5) = EOM.COMMENT2 AND PP.PROJECT_ID = EOM.PROJECT_ID INNER JOIN
            STOCKS AS S WITH (NOLOCK) ON EOM.STOCK_ID = S.STOCK_ID  INNER JOIN
           	EZGI_OPERATION_TIME_COST AS EOTC WITH (NOLOCK) ON EOM.OPERATION_RESULT_ID = EOTC.OPERATION_RESULT_ID
		WHERE        
            EOM.REAL_AMOUNT > 0 AND
            EOM.LOT_NO IN 
                				(
                                	SELECT        
                                    	EIFP.LOT_NO
									FROM            
                                    	EZGI_IFLOW_PRODUCTION_ORDERS AS EIFP WITH (NOLOCK) INNER JOIN
                                        EZGI_IFLOW_MASTER_PLAN AS EIMP WITH (NOLOCK) ON EIFP.MASTER_PLAN_ID = EIMP.MASTER_PLAN_ID
									WHERE        
                                    	EIMP.MASTER_PLAN_CAT_ID = #attributes.shift_id#
                               	)
            <cfif len(attributes.project_id) and len(attributes.project_head)>
            	AND EOM.PROJECT_ID = #attributes.project_id#
            </cfif>
            <cfif attributes.process_type eq 1>
            	AND ISNULL((SELECT TIME_COST_ID FROM #dsn_alias#.TIME_COST WHERE P_OPERATION_RESULT_ID = EOTC.EZGI_OPERATION_TIME_COST_ID),0) >0
                AND EOTC.STATUS = 1
            <cfelseif attributes.process_type eq 2>
            	AND ISNULL((SELECT TIME_COST_ID FROM #dsn_alias#.TIME_COST WHERE P_OPERATION_RESULT_ID = EOTC.EZGI_OPERATION_TIME_COST_ID),0) =0
                AND EOTC.STATUS = 1
            <cfelseif attributes.process_type eq 3>
            	AND EOTC.STATUS = 0
            </cfif>
            <cfif len(attributes.master_plan_id)> 
				AND EOM.LOT_NO IN 
                				(
                                	SELECT        
                                    	LOT_NO
									FROM            
                                    	EZGI_IFLOW_PRODUCTION_ORDERS WITH (NOLOCK)
									WHERE        
                                    	MASTER_PLAN_ID = #attributes.master_plan_id#
                               	)
			</cfif>
            <cfif len(attributes.date1)>
            	AND EOTC.TIME_COST_FINISH_DATE >= #attributes.date1#
           	</cfif>
            <cfif len(attributes.date2)>
            	AND EOTC.TIME_COST_FINISH_DATE < #DateAdd('d',1,attributes.date2)#
        	</cfif>
            <cfif isDefined('attributes.keyword') and len(attributes.keyword)>
            	AND 
                	(
                    	PP.PROJECT_HEAD LIKE '#attributes.keyword#%' OR
                        PP.PROJECT_NUMBER LIKE '#attributes.keyword#%' OR
                       	PW.WORK_HEAD LIKE '#attributes.keyword#%'
                    )
            </cfif>
      	ORDER BY
        	EOTC.TIME_COST_FINISH_DATE 
            <cfif attributes.oby eq 1>
            	desc
            </cfif>
	</cfquery>
    <cfif attributes.process_type eq 3>
    	<cfif get_production_operations.recordcount and len(get_production_operations.TIME_COST_FINISH_DATE)>
        	<cfinclude template="../query/hsp_ezgi_operation_time_cost.cfm">
            <cfquery name="get_production_operations" dbtype="query">
            	SELECT
            		*
              	FROM
                	Get_production_operations
              	ORDER BY
                	TIME_COST_FINISH_DATE 
					<cfif attributes.oby eq 1>
                        desc
                    </cfif>
            </cfquery>
        </cfif>
    </cfif>
	<cfset arama_yapilmali = 0>
<cfelse>
	<cfset get_production_operations.recordcount = 0>
    <cfset arama_yapilmali = 1>
</cfif>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_production_operations.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="list_time_cost" method="post" action="#request.self#?fuseaction=prod.list_ezgi_operation_works_transfer">
			<input name="is_submitted" id="is_submitted" type="hidden" value="1">
            <cf_box_search>
                <div class="form-group"  id="item-keyword">
                    <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group medium" id="item-oby">
                	<select name="oby" style="width:120px; height:20px">
                     	<option value="1" <cfif attributes.oby eq 1>selected</cfif>><cf_get_lang dictionary_id='57926.Azalan Tarih'></option>
                      	<option value="2" <cfif attributes.oby eq 2>selected</cfif>><cf_get_lang dictionary_id='57925.Artan Tarih'></option>
                  	</select>
               	</div>
                <div class="form-group medium" id="item-process_type">
                	<select name="process_type" style="width:120px; height:20px">
                     	<option value="1" <cfif attributes.process_type eq 1>selected</cfif>><cf_get_lang dictionary_id='59864.İşlenen'></option>
                      	<option value="2" <cfif attributes.process_type eq 2>selected</cfif>><cf_get_lang dictionary_id='51085.İşlenmeyenler'></option>
                        <option value="3" <cfif attributes.process_type eq 3>selected</cfif>><cf_get_lang dictionary_id='59337.Onay Bekleyenler'></option>
                  	</select>
               	</div>
                <div class="form-group medium" id="item-shift_id">
                	<select name="shift_id" id="shift_id" style="width:150px; height:20px">
						<cfoutput query="get_shift">
							<option value="#SHIFT_ID#"<cfif isdefined('attributes.shift_id') and attributes.shift_id eq SHIFT_ID>selected</cfif>>#SHIFT_NAME#</option>
						</cfoutput>
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
                <div class="form-group medium" id="item-master_plan_id">
                	<div class="input-group">
                   		<input type="hidden" name="project_id" id="project_id" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id) and len(attributes.project_head)><cfoutput>#attributes.project_id#</cfoutput></cfif>"> 
                		<input type="text" name="project_head" id="project_head" placeholder="Proje" value="<cfif isdefined('attributes.project_id') and len(attributes.project_id) and len(attributes.project_head)><cfoutput>#get_project_name(attributes.project_id)#</cfoutput></cfif>" style="width:200px; height:20px" onFocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','list_time_cost','3','200')" autocomplete="off">
                     	<span class="input-group-addon icon-ellipsis btnPointer" onClick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=list_time_cost.project_head&project_id=list_time_cost.project_id</cfoutput>');" title="<cf_get_lang no='45.Proje Seçiniz'>"></span>
                 	</div>
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
           	<!---<cf_box_search_detail>
                <div id="detail_search_div" class="col col-12" style="display:table-row;">
                	<div class="col col-3">
                    	<div class="col col-10">
                       		<div class="form-group medium">
                        		<div class="input-group">
                                        <input type="hidden" name="record_emp_id" id="record_emp_id" value="<cfif len(attributes.record_emp_id)><cfoutput>#attributes.record_emp_id#</cfoutput></cfif>">
                                        <input name="record_emp_name" type="text" id="record_emp_name" style="width:120px;" placeholder="<cf_get_lang dictionary_id='57899.Kaydeden'>" onFocus="AutoComplete_Create('record_emp_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','record_emp_id','list_time_cost','3','125');" value="<cfif len(attributes.record_emp_name)><cfoutput>#attributes.record_emp_name#</cfoutput> </cfif>" autocomplete="off">
                                        <span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_name=list_time_cost.record_emp_name&field_emp_id=list_time_cost.record_emp_id<cfif fusebox.circuit is "store">&is_store_module=1</cfif>&select_list=1,9','list');return false"></span>
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
        	</cf_box_search_detail>     --->           
            <cfsavecontent variable="right"></cfsavecontent>
         	<cfsavecontent variable="title">Operasyon - Zaman Harcaması Transfer</cfsavecontent>
    		<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1" right_images="#right#">
      			<cf_grid_list>   
                	<thead>
                        <tr valign="middle">
                            <th style="width:25px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th style="width:50px; text-align:center; vertical-align:middle" >Mesai</th>
                            <th style="width:50px; text-align:center; vertical-align:middle" >Başlama Tarih</th>
                            <th style="width:50px; text-align:center; vertical-align:middle" >Bitiş Tarih</th>
                            <th style="width:90px; text-align:center; vertical-align:middle" >Proje No</th>
                            <th style="text-align:center; vertical-align:middle" >İş Adı</th>
                            <th style="width:50px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='695.Plan No'></th>
                            <th style="width:50px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='41701.Lot No'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57657.Ürün'></th>
                            <th style="width:30px; text-align:center; vertical-align:middle" >Toplam</th>
                            <th style="width:30px; text-align:center; vertical-align:middle" >Üretim</th>
                            <th style="width:30px; text-align:center; vertical-align:middle" >Oran %</th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='36376.Operasyonlar'></th>
                            <th style="text-align:center; vertical-align:middle" >Operatör</th>
                            <th style="width:50px; text-align:center; vertical-align:middle" >Süre(<cf_get_lang dictionary_id='58827.Dk'>)</th>
                            <!-- sil -->
                            <th style="width:20px; text-align:center; vertical-align:middle" class="header_icn_none" >
                            	<input type="checkbox" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="secim(-1);">
                            </th>
                            <!-- sil -->
                        </tr>
                    </thead>
              
                    <tbody>
                        <cfif get_production_operations.recordcount>
                            <cfoutput query="get_production_operations" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                            	<cfif TIME_COST_MINUTE gt 0>
                            		<cfset DAKIKA = TIME_COST_MINUTE/60>
                                <cfelse>
                                	<cfset DAKIKA = 0>
                                </cfif>
                               	<cfinput type="hidden" name="project_id#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#" value="#project_id#">
                                <cfinput type="hidden" name="work_id#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#" value="#work_id#">
                                <cfinput type="hidden" name="product_name#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#" value="#product_name#"> 
                                <cfinput type="hidden" name="p_order_no#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#" value="#p_order_no#"> 
                                <cfinput type="hidden" name="amount#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#" value="#amount#"> 
                                <cfinput type="hidden" name="real_amount#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#" value="#real_amount#">
                                <cfinput type="hidden" name="real_time#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#" value="#ceiling(dakika)#"> 
                                <cfinput type="hidden" name="time_cost_minute#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#" value="#time_cost_minute#"> 
                                <cfinput type="hidden" name="operasyon_type#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#" value="#OPERATION_TYPE#">
                                <cfinput type="hidden" name="emp_id#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#" value="#EMPLOYEE_ID#"> 
                                <cfinput type="hidden" name="start_date#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#" value="#TIME_COST_START_DATE#">
                      			<cfinput type="hidden" name="finish_date#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#" value="#TIME_COST_FINISH_DATE#">
                                <cfinput type="hidden" name="overtime_type#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#" value="#OVERTIME_TYPE#">
                                <cfinput type="hidden" name="station_id#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#" value="#STATION_ID#">
                                <tr>
                                    <td style="text-align:right">#currentrow#</td>
                                    <td nowrap style="text-align:left">
                                    	<cfif OVERTIME_TYPE eq 1>
                                        	Normal
                                      	<cfelseif OVERTIME_TYPE eq 2>
                                        	Fazla Mesai
                                      	<cfelseif OVERTIME_TYPE eq 3>
                                        	Hafta Sonu
                                      	<cfelseif OVERTIME_TYPE eq 4>
                                        	Resmi Tatil
                                     	</cfif>
                                    </td>
                                    <td style="text-align:center" nowrap>#DateFormat(TIME_COST_START_DATE,dateformat_style)#:#TimeFormat(TIME_COST_START_DATE,timeformat_style)#</td>
                                    <td style="text-align:center" nowrap>#DateFormat(TIME_COST_FINISH_DATE,dateformat_style)#:#TimeFormat(TIME_COST_FINISH_DATE,timeformat_style)#</td>
                                    <td style="text-align:center" title="#PROJECT_HEAD#">#PROJECT_NUMBER#</td>
                                    <td style="text-align:left">#WORK_HEAD#</td>
                                    <td style="text-align:center;">#P_ORDER_NO#</td>
                                    <td style="text-align:center;">#LOT_NO#</td>
                                    <td style="text-align:left">#PRODUCT_NAME#</td>
                                    <td style="text-align:right">#AMOUNT#</td>
                                    <td style="text-align:right">#REAL_AMOUNT#</td>
                                    <td style="text-align:center">#ceiling((REAL_AMOUNT-WAIT_TIME)/amount*100)#</td>
                                    <td style="text-align:left">#OPERATION_TYPE#</td>
                                    <td style="text-align:left">#get_emp_info(EMPLOYEE_ID,0,0)#</td>
                                    <td style="text-align:right" title="(Çalışma - Duraklama)">#ceiling(DAKIKA)#</td>
                                    <cfif attributes.process_type neq 1>
                                        <td style="text-align:center;">
                                            <cfif time_cost_id eq 0>
                                                <input type="checkbox" name="select_operation_id" value="#OPERATION_RESULT_ID#_#EZGI_OPERATION_TIME_COST_ID#_#CURRENTROW#">
                                            <cfelse>
                                                <img src="images/c_ok.gif" title="<cf_get_lang dictionary_id='59864.İşlenen'>">
                                            </cfif>
                                        </td>
                                    </cfif>
                                </tr>
                            </cfoutput>
                            <cfoutput>
                            <tfoot>
                                <tr  height="20">
                                    <td colspan="12" align="right" class="txtbold" style="text-align:right;"><cf_get_lang dictionary_id='57492.Toplam'></td>
                                    <!-- sil -->
                                    <td colspan="<cfif attributes.process_type neq 1>4<cfelse>3</cfif>" style="text-align:right">
                                    	<cfif attributes.process_type eq 3>
                                        	<button type="button" name="material_button" id="material_button" onclick="secim(-3);" style="width:200px; height:30px; text-align:center;font-size:10px; font-weight:bold">
                                                <img src="/images/valid.gif" alt="Onayla" border="0">  Onayla
                                            </button>

                                        <cfelseif attributes.process_type eq 2>
                                            <button type="button" name="material_button" id="material_button" onclick="secim(-2);" style="width:200px; height:30px; text-align:center;font-size:10px; font-weight:bold">
                                                <img src="/images/oriantation.gif" alt="Zaman Harcamasına Dönüştür" border="0">  Zaman Harcamasına Dönüştür
                                            </button>
                                      	</cfif>
                                    </td>
                                    <!-- sil -->
                                </tr>
                            </tfoot>
                        </cfoutput>
                        <cfelse>
                            <tr> 
                                <td colspan="12" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
                            </tr>
                        </cfif>
                    </tbody>
                </cf_grid_list>
         	</cf_box>
		</cfform>
    	<cfset adres="prod.list_ezgi_operation_works_transfer">
				<cfif isDefined('attributes.date1') and isdate(attributes.date1)>
                    <cfset adres = '#adres#&date1=#attributes.date1#'>
                </cfif>
                <cfif isDefined('attributes.date2') and isdate(attributes.date2)>
                    <cfset adres = '#adres#&date2=#attributes.date2#'>
                </cfif>
                <cfif isDefined('attributes.keyword') and len(attributes.keyword)>
                    <cfset adres = '#adres#&keyword=#attributes.keyword#'>
                </cfif>
                <cfif isDefined('attributes.oby') and len(attributes.oby)>
                    <cfset adres = '#adres#&oby=#attributes.oby#'>
                </cfif>
                <cfif len(attributes.PROCESS_TYPE)>
                    <cfset adres = '#adres#&PROCESS_TYPE=#attributes.PROCESS_TYPE#'>
                </cfif>
                <cfif len(attributes.master_plan_id)>
                    <cfset adres = '#adres#&master_plan_id=#attributes.master_plan_id#'>
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
		if(document.getElementById('shift_id').value=='')
		{
			alert('Çalışma Programı Seçmelisiniz');
			return false;
		}
		else
			return true;	
	}
	function secim(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
		operation_result_id_list = '';
		chck_leng = document.getElementsByName('select_operation_id').length;
		for(ci=0;ci<chck_leng;ci++)
		{
			var my_objets = document.all.select_operation_id[ci];
			if(chck_leng == 1)
				var my_objets =document.all.select_operation_id;
			if(type == -1){//hepsini seç denilmişse	
				if(my_objets.checked == true)
					my_objets.checked = false;
				else
					my_objets.checked = true;
			}
			else
			{
				if(my_objets.checked == true)
					operation_result_id_list +=my_objets.value+',';
			}
		}
		operation_result_id_list = operation_result_id_list.substr(0,operation_result_id_list.length-1);//sondaki virgülden kurtarıyoruz.
		if(list_len(operation_result_id_list,','))
		{
			if(type == -2)
			{
				document.getElementById("list_time_cost").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_add_ezgi_operation_works_transfer";
				document.getElementById("list_time_cost").submit();
			}
			if(type == -3)
			{
				document.getElementById("list_time_cost").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_add_ezgi_operation_works_transfer&onay=1";
				document.getElementById("list_time_cost").submit();
			}
			else
				return false;
		}
	}
</script>