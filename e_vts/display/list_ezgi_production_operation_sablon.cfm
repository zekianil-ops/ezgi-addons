<!---
    File: list_ezgi_production_operation_sablon.cfm
    Folder: Add_Ons\ezgi\e-vts\display
    Author: Ezgi Yazılım
    Date: 04/01/2025
    Description: Şablon Bazlı Üretim
--->
<cfparam name="attributes.is_submitted" default="">
<cfparam name="attributes.sheet_group_number" default="">
<cfparam name="attributes.color_id" default="">
<cfparam name="attributes.master_plan_id" default="">
<cfparam name="attributes.master_plan" default="">
<cfparam name="attributes.thickness_vale" default="">
<cfparam name="attributes.station_id" default="">
<cfparam name="attributes.employee_id" default="">

<!---İstasyon Bilgileri Alınıyor--->
<cfif len(attributes.station_id)>
	<cfquery name="get_workstation_name" datasource="#dsn3#">
		SELECT STATION_NAME,STATION_ID,EZGI_PACKAGE_CONTROL,ISNULL(EZGI_ORDER_CONTROL,0) AS EZGI_ORDER_CONTROL FROM WORKSTATIONS WHERE STATION_ID = #attributes.station_id#
	</cfquery>
<cfelse>
	<cfset get_workstation_name.recordcount = 0>
</cfif>

<!---Operasyon Bilgileri Alınıyor--->
<cfif len(attributes.station_id)>
	<cfquery name="get_workstation_operations" datasource="#dsn3#">
		SELECT 
			WP.OPERATION_TYPE_ID, 
			OT.OPERATION_TYPE
		FROM     
			WORKSTATIONS_PRODUCTS AS WP INNER JOIN
			OPERATION_TYPES AS OT ON WP.OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID
		WHERE  
			WP.WS_ID = #attributes.station_id# AND 
			NOT (WP.OPERATION_TYPE_ID IS NULL)
	</cfquery>
<cfelse>
	<cfset get_workstation_operations.recordcount = 0>
</cfif>

<!---İstasyonda Çalışanların Bilgileri Alınıyor--->
<cfif len(attributes.station_id) and len(attributes.employee_id)>
	<cfquery name="get_station_employee" datasource="#dsn3#">
		SELECT EMPLOYEE_ID FROM EZGI_STATION_EMPLOYEE WHERE STATION_ID = #attributes.station_id# AND FINISH_DATE IS NULL AND EMPLOYEE_ID <> #attributes.employee_id#
	</cfquery>
<cfelse>
	<cfset get_station_employee.recordcount = 0>
</cfif>

<!---Şu an Duraklama var mı? Bilgileri Alınıyor--->
<cfif len(attributes.station_id) and len(attributes.employee_id)>
	<cfquery name="get_prod_pause" datasource="#dsn3#">
		SELECT     
			PROD_PAUSE_TYPE_ID
		FROM         
			SETUP_PROD_PAUSE
		WHERE     
			STATION_ID = #attributes.station_id# AND 
			EMPLOYEE_ID = #attributes.employee_id# AND 
			PROD_DURATION IS NULL
	</cfquery>
	<!---Duraklama Bilgileri Alınıyor--->
	<cfif get_prod_pause.recordcount>
		<cfquery name="get_prod_pause_cat" datasource="#dsn3#">
			SELECT     
				PROD_PAUSE_CAT_ID
			FROM         
				SETUP_PROD_PAUSE_TYPE
			WHERE     
				PROD_PAUSE_TYPE_ID = #get_prod_pause.PROD_PAUSE_TYPE_ID#
		</cfquery>
		<cfif get_prod_pause_cat.recordcount>
			<cfset pause_cat = get_prod_pause_cat.PROD_PAUSE_CAT_ID>
		<cfelse>
			<cfset pause_cat = 0>
		</cfif>
	<cfelse>
		<cfset pause_cat = 0>
	</cfif>
<cfelse>
	<cfset pause_cat = 0>
</cfif>

<!---İstasyon ve Çalışan için Guruplama Varmı Bilgileri Alınıyor--->
<cfif len(attributes.station_id) and len(attributes.employee_id)>
	<cfquery name="get_employee_durum" datasource="#dsn3#">
		SELECT  
			ISNULL(REAL_AMOUNT, 0) AS REAL_AMOUNT,
			P_OPERATION_ID,
			ISNULL(OPERATION_GRUP_ID,0) AS OPERATION_GRUP_ID
		FROM        
			EZGI_OPERATION_M
		WHERE     
			ACTION_EMPLOYEE_ID = #attributes.employee_id# AND 
			STATION_ID = #attributes.station_id# AND
			STAGE = 1 AND
			LOSS_AMOUNT=0 AND
			REAL_AMOUNT=0 
	</cfquery>
	<cfquery name="get_employee_durum_gurup" dbtype="query">
		SELECT
			OPERATION_GRUP_ID
		FROM
			get_employee_durum
		GROUP BY
			OPERATION_GRUP_ID
	</cfquery>
	<cfif get_employee_durum_gurup.recordcount>
		<cfset ezgi_operation_gurup_id = get_employee_durum_gurup.OPERATION_GRUP_ID>
		<cfquery name="get_gurup_durum" datasource="#dsn3#">
			SELECT     
				IS_RESULT
			FROM         
				EZGI_OPERATION_GRUP_NO
			WHERE     
				OPERATION_GRUP_ID = #ezgi_operation_gurup_id#
		</cfquery>
		<cfset ezgi_operation_gurup_id_durum = get_gurup_durum.IS_RESULT>
	<cfelse>
		<cfset ezgi_operation_gurup_id_durum = 0>
	</cfif>
<cfelse>
	<cfset get_employee_durum.recordcount = 0>
	<cfset ezgi_operation_gurup_id_durum = 0>
</cfif>

<!--- Üretim Programında Oluşan Plan Bilgileri Alınıyor --->
<cfif len(attributes.station_id)>
	<cfquery name="GET_MASTER_PLAN_1" datasource="#dsn3#">
		SELECT 
			EIMAP.MASTER_PLAN_ID,
			EIMAP.MASTER_PLAN_NUMBER, 
			EIMAP.MASTER_PLAN_DETAIL, 
			EIMAP.RECORD_DATE
		FROM     
			EZGI_IFLOW_MASTER_PLAN AS EIMAP INNER JOIN
			#dsn_alias#.SETUP_SHIFTS AS SS ON EIMAP.MASTER_PLAN_CAT_ID = SS.SHIFT_ID INNER JOIN
			WORKSTATIONS AS WW ON SS.DEPARTMENT_ID = WW.DEPARTMENT
		WHERE  
			SS.IS_PRODUCTION = 1 AND 
			WW.STATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.station_id#"> AND 
			EIMAP.MASTER_PLAN_STATUS = 1
		ORDER BY 
			MASTER_PLAN_NUMBER
	</cfquery>
	<!--- Master Planda Oluşan Plan Bilgileri Alınıyor --->
	<cfquery name="GET_MASTER_PLAN_2" datasource="#dsn3#">
		SELECT 
			EMAP.MASTER_ALT_PLAN_ID MASTER_PLAN_ID,
			EMAP.MASTER_ALT_PLAN_NO MASTER_PLAN_NUMBER,  
			convert(varchar, EMAP.PLAN_START_DATE,103) MASTER_PLAN_DETAIL, 
			EMAP.RECORD_DATE
		FROM     
			EZGI_MASTER_ALT_PLAN AS EMAP INNER JOIN
			EZGI_MASTER_PLAN_SABLON AS EMAS ON EMAP.PROCESS_ID = EMAS.PROCESS_ID INNER JOIN
			WORKSTATIONS AS W ON EMAS.WORKSTATION_ID = W.STATION_ID INNER JOIN
			WORKSTATIONS AS W1 ON W.DEPARTMENT = W1.DEPARTMENT
		WHERE  
			W1.STATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.station_id#"> AND
			EMAS.WORKSTATION_ID IN
							(
								SELECT 
									UP_STATION
								FROM      
									WORKSTATIONS AS WW
								WHERE   
									STATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.station_id#">
							)
		ORDER BY 
			EMAP.PLAN_START_DATE
	</cfquery>
	<!--- Plan Bilgileri Birleştiriliyor --->
	<cfquery name="GET_MASTER_PLAN" dbtype="query">
		SELECT
			1 AS TYPE,
			MASTER_PLAN_ID,
			MASTER_PLAN_NUMBER, 
			MASTER_PLAN_DETAIL, 
			RECORD_DATE	
		FROM
			GET_MASTER_PLAN_1
		UNION ALL
		SELECT
			2 AS TYPE,
			MASTER_PLAN_ID,
			MASTER_PLAN_NUMBER, 
			MASTER_PLAN_DETAIL, 
			RECORD_DATE	
		FROM
			GET_MASTER_PLAN_2
	</cfquery>
<cfelse>
	<cfset GET_MASTER_PLAN.recordcount = 0>
</cfif>

<!--- Renk listesi için sorgu --->
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT 
		COLOR_ID, 
		COLOR_NAME 
	FROM 
		EZGI_COLORS WITH (NOLOCK) 
	WHERE 
		IS_ACTIVE = 1 
	ORDER BY 
		COLOR_NAME
</cfquery>

<!--- Kalınlık listesi için sorgu --->
<cfquery name="get_thickness" datasource="#dsn3#">
	SELECT DISTINCT      
		THICKNESS_VALUE, 
		THICKNESS_NAME
	FROM            
		EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK)
	WHERE        
		LIST_ORDER_NO = 1
		AND THICKNESS_VALUE IS NOT NULL
		AND THICKNESS_VALUE <> ''
	ORDER BY 
		THICKNESS_NAME
</cfquery>

<cfif isdefined('attributes.is_submitted') and len(attributes.is_submitted)>
    <cfquery name="get_sablon" datasource="#dsn3#">
        SELECT 
            0 AS STAGE,
            E.STOCK_ID, 
            E.SHEET_GROUP_NUMBER, 
            ISNULL(
						(
						SELECT
							COUNT(DISTINCT OERR.OPTIMIZATION_RESULT_ROW_ID)
						FROM
							EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS OERR INNER JOIN
							EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER ON OERR.OPTIMIZATION_RESULT_ID = OER.OPTIMIZATION_RESULT_ID
						WHERE
							OER.SHEET_GROUP_NUMBER = E.SHEET_GROUP_NUMBER
						)
					,0) AS SAYI,
            (
                    SELECT 
                        COUNT(SHEET_NUMBER) AS SHEET_AMOUNT
                    FROM      
                        EZGI_IFLOW_OPTIMIZATION_RESULTS
                    WHERE   
                        SHEET_GROUP_NUMBER = E.SHEET_GROUP_NUMBER
            ) AS SHEET_AMOUNT, 
            S.PRODUCT_CODE, 
            S.PRODUCT_NAME,
            EOO.MASTER_PLAN_ID
        FROM     
            EZGI_IFLOW_OPTIMIZATION_RESULTS AS E INNER JOIN
            STOCKS AS S ON E.STOCK_ID = S.STOCK_ID INNER JOIN
            EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS ER ON E.OPTIMIZATION_RESULT_ID = ER.OPTIMIZATION_RESULT_ID INNER JOIN
            EZGI_IFLOW_OPTIMIZATION_ROW AS EO ON E.OPTIMIZATION_ID = EO.OPTIMIZATION_ID INNER JOIN
            EZGI_IFLOW_PRODUCTION_ORDERS AS EOO ON EO.IFLOW_P_ORDER_ID = EOO.IFLOW_P_ORDER_ID
        GROUP BY 
            E.STOCK_ID, 
            E.SHEET_GROUP_NUMBER, 
            S.STOCK_ID, 
            S.PRODUCT_CODE, 
            S.PRODUCT_NAME,
            EOO.MASTER_PLAN_ID
        HAVING 
            1=1
            <cfif len(attributes.sheet_group_number)>
                AND E.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_group_number#">
            </cfif>
            <cfif len(attributes.color_id) or len(attributes.thickness_vale)>
                AND 
                    S.STOCK_ID IN
                             (
                                SELECT 
                                    EB.STOCK_ID2
                                FROM      
                                    EZGI_PRODUCT_TREE_BOM1 AS EB INNER JOIN
                                    STOCKS AS S ON EB.STOCK_ID = S.STOCK_ID INNER JOIN
                                    EZGI_DESIGN_PRODUCT_PROPERTIES_UST AS U ON S.STOCK_ID = U.STOCK_ID
                                WHERE  
                                    1=1
                                    <cfif len(attributes.color_id)> 
                                        AND U.COLOR_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.color_id#">
                                    </cfif>
                                    <cfif len(attributes.thickness_vale)> 
                                        AND U.THICKNESS_VALUE = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.thickness_vale#">
                                    </cfif>
                            )
            </cfif>
            <cfif len(attributes.master_plan_id)>
                AND EOO.MASTER_PLAN_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.master_plan_id#">
            </cfif>
            <cfif len(attributes.master_plan) and ListLen(attributes.master_plan,'-')>
                <cfif ListGetat(attributes.master_plan,1,'-') eq 1>
                    AND EOO.MASTER_PLAN_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ListGetat(attributes.master_plan,2,'-')#">
                </cfif>
            </cfif>
    </cfquery>
<cfelse>
	<cfset get_sablon.recordcount = 0>
</cfif>

<cf_box>
	<cfform name="search_list" id="search_list" action="#request.self#?fuseaction=production.list_ezgi_production_operation_sablon" method="post">
		<cfinput type="hidden" name="is_submitted" value="1">
        <cfinput type="hidden" name="station_id" value="#attributes.station_id#">
        <cfinput type="hidden" name="employee_id" value="#attributes.employee_id#">
		<cf_box_search>
			<div class="form-group">
				<cfif get_workstation_name.recordcount and isdefined('get_employee_durum') and get_employee_durum.recordcount and get_employee_durum.REAL_AMOUNT eq 0>
					<a href="javascript://" onclick="delete_control(0,'');">
						<button type="button" name="worked" class="ui-ripple-btn act" style="margin:5px 5px;background-color:#f35d5d;width:120px;height:50px;"><cf_get_lang dictionary_id='40137.Çalışıyor'></button>
					</a>
				<cfelse>
					<cfif pause_cat eq 0>
						<a href=<cfoutput>"#request.self#?fuseaction=production.upd_ezgi_station_employee&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&upd_employee=1"</cfoutput>>
							<button type="button" name="degistir" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"><cf_get_lang dictionary_id='57431.Çıkış'></button>
						</a>
					<cfelse>
						<button type="button" name="degistir" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"></button>
					</cfif>
					<cfif pause_cat eq 3 or pause_cat eq 0>
						<a href="javascript://" onclick="prod_pause(3);">
							<button type="button" name="ariza" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"><cf_get_lang dictionary_id='298.Arıza'></button>
						</a>
					<cfelse>
						<button type="button" name="ariza" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"></button>
					</cfif>
					<cfif pause_cat eq 2 or pause_cat eq 0>
						<a href="javascript://" onclick="prod_pause(2);">
							<button type="button" name="duraklama" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"><cf_get_lang dictionary_id='300.Duraklama'></button>
						</a>
					<cfelse>
						<button type="button" name="duraklama" class="ui-ripple-btn" style="margin:5px 5px;width:120px;height:50px;"></button>
					</cfif>
				</cfif>
				<a href="javascript://" onclick="geri();">
					<button type="button" name="geri" class="ui-ripple-btn" style="margin:5px 5px;background-color: #ff9b05;width:120px;height:50px;">Partner Ekle</button>
				</a>
			</div>
			<div class="form-group">
				<label style="font-size:16px; font-weight:bold; margin-right:10px;">Şablon No:</label>
				<input name="sheet_group_number" id="sheet_group_number" type="text" value="<cfif len(attributes.sheet_group_number)><cfoutput>#attributes.sheet_group_number#</cfoutput><cfelse></cfif>" placeholder="Şablon No" style="width:140px; height:50px!important; font-size:17px; font-weight:bold; vertical-align:top">
			</div>
			<div class="form-group">
				<label style="font-size:16px; font-weight:bold; margin-right:10px;">Renk:</label>
				<select name="color_id" id="color_id" style="font-size:16px; font-weight:bold; height:50px; width:200px">
					<option value="" <cfif not len(attributes.color_id)>selected</cfif>>Tümü</option>
					<cfoutput query="get_colors">
						<option value="#COLOR_ID#" <cfif attributes.color_id eq COLOR_ID>selected</cfif>>#COLOR_NAME#</option>
					</cfoutput>
				</select>
			</div>
			<div class="form-group">
				<label style="font-size:16px; font-weight:bold; margin-right:10px;">Kalınlık:</label>
				<select name="thickness_vale" id="thickness_vale" style="font-size:16px; font-weight:bold; height:50px; width:200px">
					<option value="" <cfif not len(attributes.thickness_vale)>selected</cfif>>Tümü</option>
					<cfoutput query="get_thickness">
						<option value="#THICKNESS_VALUE#" <cfif attributes.thickness_vale eq THICKNESS_VALUE>selected</cfif>>#THICKNESS_NAME#</option>
					</cfoutput>
				</select>
			</div>
			<div class="form-group">
				<select name="master_plan" id="master_plan" style="font-size:16px; font-weight:bold; height:50px; width:200px">
					<option value="" <cfif attributes.master_plan eq ''>selected</cfif>>Üretim Seçiniz</option>
					<cfif GET_MASTER_PLAN.recordcount>
						<cfoutput query="GET_MASTER_PLAN">
							<option value="#TYPE#-#MASTER_PLAN_ID#" <cfif week(GET_MASTER_PLAN.RECORD_DATE)-week(now()) eq 0>style="background-color:palegreen"</cfif> <cfif Listlen(attributes.master_plan,'-') and ListGetat(attributes.master_plan,2,'-') eq #MASTER_PLAN_ID# and ListGetat(attributes.master_plan,1,'-') eq #TYPE#>selected</cfif>>#MASTER_PLAN_NUMBER# - #MASTER_PLAN_DETAIL#</option>
						</cfoutput>
					</cfif>
				</select>
			</div>
			<div class="form-group">
				<cfif pause_cat eq 3 or pause_cat eq 0>
					<a class="ui-btn ui-btn-green" href="javascript://" onclick="document.getElementById('search_list').submit();">
						<button type="button" name="ara" style="cursor:pointer; vertical-align:bottom; background-color:transparent; border:none"><i class="fa fa-search"></i></button>
					</a>
				<cfelse>
					<button type="button" name="ara" style="cursor:pointer; vertical-align:bottom; background-color:transparent; border:none"><i class="fa fa-search"></i></button>
				</cfif>
			</div>
			<div class="form-group" id="form_ul_data_explorer">
				<a class="ui-btn ui-btn-gray2" onclick="yazdir()"><i class="fa fa-print"></i></a>						
			</div>
		</cf_box_search>
	</cfform>
</cf_box>

<style>
	.box_yazi {font-size:16px;border-color:#666666;font:bold} 
	.box_yazi_td {font-size:18px!important;border-color:#666666;padding:12px 5px!important;} 
	.box_yazi_small {font-size:11px;border-color:#666666;} 
	.a_box_yazi {font-size:16px;border-color:#BDCAC5;font:bold} 
	.a_box_yazi_td {font-size:14px;border-color:#BDCAC5;} 
	.tablesorter-header-inner{font-size:20px!important;}
	.ui-btn{padding: 9px 20px!important;}
	.portBox .portHeadLightTitle span a{
		font-size:30px!important;
	}
</style>

<cfif isdefined('attributes.is_submitted') and len(attributes.is_submitted) and get_sablon.recordcount>
	<cf_box title="Şablon Listesi" uidrop="1" hide_table_column="1">
		<cf_grid_list>
			<thead>
				<tr>
					<th class="box_yazi" style="text-align:center" width="5%">Sıra</th>
					<th class="box_yazi" style="text-align:center" width="15%">Şablon No</th>
					<th class="box_yazi" style="text-align:center" width="15%"></th>
					<th class="box_yazi" style="text-align:center" width="15%">Malzeme Kodu</th>
					<th class="box_yazi" style="text-align:center">Malzeme Adı</th>
					<th class="box_yazi" style="text-align:center" width="10%">Toplam Plaka</th>
					<th class="box_yazi" style="text-align:center" width="10%">Toplam İş Emri</th>
				</tr>
			</thead>
			<tbody>
				<cfoutput query="get_sablon">
					<tr height="50" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
						<td class="box_yazi_td" style="text-align:center">#currentrow#</td>
						<td class="box_yazi_td" style="text-align:center">#SHEET_GROUP_NUMBER#</td>
						<td class="box_yazi_td" style="text-align:center;">
							<cfif STAGE neq 3>
								<a href="#request.self#?fuseaction=production.dsp_ezgi_operation_sablon&sheet_group_number=#SHEET_GROUP_NUMBER#&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#" style="font-size:14px" class="tableyazi">
									<button type="button" name="gurupla" style="width:120px; font-size:14px; font-weight:bold;height:40px" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id ='57734.Seçiniz'></button>
								</a>
							</cfif>
						</td>
						<td class="box_yazi_td" style="text-align:center">#PRODUCT_CODE#</td>
						<td class="box_yazi_td">#PRODUCT_NAME#</td>
						<td class="box_yazi_td" style="text-align:center">#SHEET_AMOUNT#</td>
						<td class="box_yazi_td" style="text-align:center">#SAYI#</td>
					</tr>
				</cfoutput>
				<cfif get_workstation_name.recordcount and len(attributes.employee_id)>
					<tr>
						<td style="font-size:17px; font-weight:bold; ">Operatör</td>
						<td style="font-size:17px; font-weight:bold; " colspan="2"><cfoutput>#get_emp_info(attributes.employee_id,0,0)#</cfoutput></td>
						<td style="font-size:17px; font-weight:bold; text-align:center; height:50px">
							<cfif get_station_employee.recordcount>
								<cfoutput query="get_station_employee">
									#get_emp_info(get_station_employee.employee_id,0,0)#,&nbsp;
								</cfoutput>
							</cfif>
						</td>
						<td style="font-size:17px; font-weight:bold; ">
							<cfoutput>#get_workstation_name.station_name#</cfoutput>
						</td>
						<td style="font-size:18px; font-weight:bold; text-align:center" colspan="2" nowrap>
						</td>
					</tr>
				</cfif>
			</tbody>
		</cf_grid_list>
	</cf_box>
<cfelseif isdefined('attributes.is_submitted') and len(attributes.is_submitted)>
	<cf_box title="Şablon Listesi">
		<div class="col col-12">
			<p style="text-align:center; padding:20px; font-size:16px; color:#999;">Kayıt bulunamadı.</p>
		</div>
	</cf_box>
</cfif>

<script language="javascript">
	function yazdir()
	{
		if(document.getElementById('master_plan').value == '')
		{
			alert('Önce Master Plan Seçiniz..!');
			return false;
		}
		else
			windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_print_files&print_type=284</cfoutput>&iid='+document.getElementById('master_plan').value,'page');
	}
	function delete_control(p_operation_id,trace_no)
	{
		sor = confirm(trace_no+" <cf_get_lang dictionary_id='417.Üretim İçin Sonuç Girmeden Çıkmak İstediğinizden Emin misiniz'>?");
		if(sor==true)
		{
			if(p_operation_id==0)
				window.location.href='<cfoutput>#request.self#?fuseaction=production.upd_ezgi_station_employee_exit&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&p_operation_id=#get_employee_durum.p_operation_id#</cfoutput>';
			else
				window.location.href='<cfoutput>#request.self#?fuseaction=production.upd_ezgi_station_employee_exit&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#</cfoutput>&p_operation_id='+p_operation_id+'&trace_no='+trace_no;
		}
	}
	function prod_pause(tkey)
	{
		<cfoutput>
			var station_id = #attributes.station_id#;
			var employee_id = #attributes.employee_id#;
			var pause_cat = #pause_cat#
		</cfoutput>
		if(pause_cat==0)
		{
			if(tkey==1||tkey==2||tkey==3)
			{
				windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_form_add_ezgi_prod_pause&station_id_='+station_id+'&employee_id_='+employee_id+'&type_id='+tkey,'small');
			}
		}
		else
		{
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.emptypopup_add_ezgi_prod_pause&station_id='+station_id+'&employee_id='+employee_id+'&pause_cat='+pause_cat,'small');	
		}
	}
	function geri()
	{
		window.location.href='<cfoutput>#request.self#?fuseaction=production.employee_ezgi_identification_1</cfoutput>';
	}
</script>