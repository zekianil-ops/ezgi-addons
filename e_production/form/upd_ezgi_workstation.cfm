<cfinclude template="../query/get_ezgi_branch.cfm">
<cfinclude template="../query/get_ezgi_money.cfm">
<cfinclude template="../query/get_ezgi_workstation.cfm">
<cfif isdefined('attributes.keyword')>
	<cfif attributes.keyword is "branch">
		<script type="text/javascript">
			alert("<cf_get_lang dictionary_id ='58579.Sube Seçmediniz'>");
		</script>
	</cfif>
	<cfif attributes.keyword is "employee">
		<script type="text/javascript">
			alert("<cf_get_lang dictionary_id ='36398.Görevli Seçmediniz'>");
		</script>
	</cfif>
</cfif>
<cfquery name="GET_WORKSTATION_DETAIL" datasource="#DSN3#">
	SELECT 
        #dsn#.Get_Dynamic_Language(STATION_ID,'#session.ep.language#','WORKSTATIONS','STATION_NAME',NULL,NULL,STATION_NAME) AS STATION_NAME_ITEM,
        STATION_ID, 
        IS_CAPACITY, 
        PROJECT_ID, 
        UP_STATION, 
        STATION_NAME, 
        BRANCH, 
        DEPARTMENT, 
        PRODUCT, 
        CAPACITY, 
        VALUE_STATION, 
        ENERGY, 
        EMP_ID, 
        OUTSOURCE_PARTNER, 
        COMMENT, 
        DOWN_STATIONS, 
        ACTIVE, 
        COST, 
        COST_MONEY, 
        EMPLOYEE_NUMBER, 
        SET_PERIOD_HOUR, 
        SET_PERIOD_MINUTE, 
        AVG_CAPACITY_DAY, 
        AVG_CAPACITY_HOUR, 
        ASSET_ID, 
        BASIC_INPUT_ID, 
        AVG_COST, 
        EXIT_DEP_ID, 
        EXIT_LOC_ID, 
        ENTER_DEP_ID, 
        ENTER_LOC_ID, 
        PRODUCTION_DEP_ID, 
        PRODUCTION_LOC_ID, 
        WIDTH, 
        LENGTH, 
        HEIGHT, 
        ELECTRIC_TYPE, 
        DESIGN_INFO, 
        MARINA_PART_TYPE_ID, 
        RECORD_IP, 
        RECORD_EMP, 
        RECORD_DATE, 
        UPDATE_IP, 
        UPDATE_EMP, 
        UPDATE_DATE, 
        REFLECTION_TYPE, 
        UNIT2, 
        EZGI_SETUP_TIME, 
        EZGI_KATSAYI, 
        EZGI_PACKAGE_CONTROL, 
        EZGI_ORDER_CONTROL,
        ISNULL(PREVIOUS_OPERATION_END_CONTROL,0) AS PREVIOUS_OPERATION_END_CONTROL,
        ISNULL(OUTER_EDGE_TRIMMING_ALLOWANCE,0) AS OUTER_EDGE_TRIMMING_ALLOWANCE,
        ISNULL(CIRCLE_TESTRE_THICKNESS,0) AS CIRCLE_TESTRE_THICKNESS,
        ISNULL(MAXIMUM_NUMBER_OF_CUTS,1) AS MAXIMUM_NUMBER_OF_CUTS,
        ISNULL(CUTTING_METHOD,1) AS CUTTING_METHOD,
        ISNULL(MAXIMUM_DIFFERENT_CUTS,999) AS MAXIMUM_DIFFERENT_CUTS,
        ISNULL(CUTTING_STARTING_DIRECTION,1) AS CUTTING_STARTING_DIRECTION
    FROM 
    	WORKSTATIONS 
   	WHERE 
    	STATION_ID = #attributes.station_id#
</cfquery>

<cfset dep_id_list =''>
<cfset loc_id_list =''>
<cfif len(GET_WORKSTATION_DETAIL.exit_dep_id)>
	<cfset dep_id_list = ListAppend(dep_id_list,GET_WORKSTATION_DETAIL.exit_dep_id,',')>
    <cfset loc_id_list = ListAppend(loc_id_list,GET_WORKSTATION_DETAIL.exit_loc_id,',')>
</cfif>
<cfif len(GET_WORKSTATION_DETAIL.production_dep_id)>
	<cfset dep_id_list = ListAppend(dep_id_list,GET_WORKSTATION_DETAIL.production_dep_id,',')>
    <cfset loc_id_list = ListAppend(loc_id_list,GET_WORKSTATION_DETAIL.production_loc_id,',')>
</cfif>
<cfif len(GET_WORKSTATION_DETAIL.enter_dep_id)>
	<cfset dep_id_list = ListAppend(dep_id_list,GET_WORKSTATION_DETAIL.enter_dep_id,',')>
    <cfset loc_id_list = ListAppend(loc_id_list,GET_WORKSTATION_DETAIL.enter_loc_id,',')>
</cfif>
<cfif len(dep_id_list)>
    <cfquery name="GET_DEP" datasource="#DSN#">
        SELECT DEPARTMENT_HEAD, DEPARTMENT_ID FROM DEPARTMENT WHERE DEPARTMENT_ID IN (#dep_id_list#)
    </cfquery>
	<cfif len(loc_id_list)> 
        <cfquery name="GET_LOC" datasource="#DSN#">
            SELECT
                COMMENT,
                LOCATION_ID,
                DEPARTMENT_ID
            FROM
                STOCKS_LOCATION
            WHERE
                LOCATION_ID IN (#loc_id_list#) AND
                DEPARTMENT_ID IN (#dep_id_list#)
        </cfquery>
</cfif>
<cfloop query="GET_DEP">
	<cfif GET_WORKSTATION_DETAIL.exit_dep_id eq DEPARTMENT_ID>
        <cfset exit_dep_name = DEPARTMENT_HEAD>
    </cfif>
    <cfif GET_WORKSTATION_DETAIL.production_dep_id eq DEPARTMENT_ID>
        <cfset production_dep_name = DEPARTMENT_HEAD>
    </cfif>
    <cfif GET_WORKSTATION_DETAIL.enter_dep_id eq DEPARTMENT_ID>
        <cfset enter_dep_name = DEPARTMENT_HEAD>
    </cfif>
</cfloop>
<cfset exit_loc_comment = ''>
<cfset production_loc_comment = ''>
<cfset enter_loc_comment = ''>
<cfloop query="GET_LOC">
	<cfif GET_WORKSTATION_DETAIL.exit_loc_id eq LOCATION_ID and GET_WORKSTATION_DETAIL.exit_dep_id eq DEPARTMENT_ID>
		<cfset exit_loc_comment = COMMENT>
	</cfif>
    <cfif GET_WORKSTATION_DETAIL.production_loc_id eq LOCATION_ID and GET_WORKSTATION_DETAIL.production_dep_id eq DEPARTMENT_ID>
		<cfset production_loc_comment =  COMMENT>
	</cfif>
    <cfif GET_WORKSTATION_DETAIL.enter_loc_id eq LOCATION_ID and GET_WORKSTATION_DETAIL.enter_dep_id eq DEPARTMENT_ID>
		<cfset enter_loc_comment = COMMENT>
	</cfif>
</cfloop>
</cfif>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">  
    <cfform name="upd_workstation" method="post" action="#request.self#?fuseaction=prod.upd_ezgi_workstation_process">
    <input type="hidden" name="STATION_ID" id="STATION_ID" value="<cfoutput>#attributes.station_id#</cfoutput>" />
        <div class="col col-9 col-md-9 col-sm-9 col-xs-12" type="row" index="1" sort="true">
            <cf_box>
                <cf_box_elements>
                    <div class="col col-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group" id="item-is_capacity">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='36379.Sonlu Kapasite'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="checkbox" name="is_capacity" id="is_capacity" <cfif get_workstation_detail.is_capacity eq 1>checked</cfif> />
                            </div>
                        </div>
                        <div class="form-group" id="item-up_station">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36399.Üst Istasyon'></label>
                            <div class="col col-8 col-xs-12">
                                <select name="up_station" id="up_station">
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="get_workstation">
                                        <cfif not len(up_station)>
                                            <option value="#station_id#" <cfif get_workstation_detail.up_station eq station_id>selected</cfif>>#station_name#</option>
                                        </cfif>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-STATION_NAME">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58834.Istasyon'> *</label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <cfinput type="text"  name="STATION_NAME" id="STATION_NAME" value="#GET_WORKSTATION_DETAIL.STATION_NAME_ITEM#" required="yes">
                                        <span class="input-group-addon">   
                                            <cf_language_info 
                                                table_name="WORKSTATIONS"
                                                column_name="STATION_NAME" 
                                                column_id_value="#attributes.station_id#" 
                                                maxlength="50" 
                                                datasource="#dsn3#" 
                                                column_id="STATION_ID"
                                                control_type="0">
                                        </span>   
                                </div>                             
                            </div>
                        </div>
                        <div class="form-group" id="item-branch_id">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57453.Sube'> *</label>
                            <div class="col col-8 col-xs-12">
                                <select name="branch_id_sta" id="branch_id_sta" onchange="get_departments(this.value);">
                                    <option value=""><cf_get_lang dictionary_id='57453.Sube'></option>
                                    <cfoutput query="get_branch">
                                        <option value="#branch_id#" <cfif get_branch.branch_id eq get_workstation_detail.branch>selected</cfif>>#branch_name#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-department_id">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57572.Departman'> *</label>
                            <div class="col col-8 col-xs-12">
                            <select name="department_id" id="department_id">
                                    <option value=""><cf_get_lang dictionary_id='57572.Departman'></option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group" id="item-exit_location_id">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36761.Sarf Depo'> *</label>
                            <div class="col col-8 col-xs-12">
                                <cfif len(get_workstation_detail.exit_dep_id) and len(get_workstation_detail.exit_loc_id)>
                                    <cf_wrkdepartmentlocation
                                        returnInputValue="exit_location_id,exit_department,exit_department_id"
                                        returnQueryValue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID"
                                        fieldName="exit_department"
                                        fieldId="exit_location_id"
                                        department_fldId="exit_department_id"
                                        department_id="#get_workstation_detail.exit_dep_id#"
                                        location_id="#get_workstation_detail.exit_loc_id#"
                                        location_name="#exit_dep_name# - #exit_loc_comment#"
                                        user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
                                        branch_fldId="branch_fldId"
                                        line_info = 1
                                        width="170">
                                <cfelse>
                                    <cf_wrkdepartmentlocation
                                        returnInputValue="exit_location_id,exit_department,exit_department_id"
                                        returnQueryValue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID"
                                        fieldName="exit_department"
                                        fieldId="exit_location_id"
                                        department_fldId="exit_department_id"
                                        user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
                                        branch_fldId="branch_fldId"
                                        line_info = 1
                                        width="170">
                                </cfif>
                            </div>
                        </div>
                        <div class="form-group" id="item-production_location_id">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36763.Üretim Depo'> *</label>
                            <div class="col col-8 col-xs-12">
                                <cfif len(get_workstation_detail.production_dep_id) and len(get_workstation_detail.production_loc_id)>
                                    <cf_wrkdepartmentlocation
                                        returnInputValue="production_location_id,production_department,production_department_id"
                                        returnQueryValue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID"
                                        fieldId="production_location_id"
                                        fieldName="production_department"
                                        department_fldId="production_department_id"
                                        department_id="#get_workstation_detail.production_dep_id#"
                                        location_id="#get_workstation_detail.production_loc_id#"
                                        user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
                                        line_info = 2
                                        width="170">
                                <cfelse>
                                    <cf_wrkdepartmentlocation
                                        returnInputValue="production_location_id,production_department,production_department_id"
                                        returnQueryValue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID"
                                        fieldId="production_location_id"
                                        fieldName="production_department"
                                        department_fldId="production_department_id"
                                        user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
                                        line_info = 2
                                        width="170">
                                </cfif>
                            </div>
                        </div>
                        <div class="form-group" id="item-enter_location_id">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36764.Sevkiyat Depo'></label>
                            <div class="col col-8 col-xs-12">
                                <cfif len(get_workstation_detail.enter_dep_id) and len(get_workstation_detail.enter_loc_id)>
                                    <cf_wrkdepartmentlocation
                                        returnInputValue="enter_location_id,enter_department,enter_department_id"
                                        returnQueryValue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID"
                                        fieldId="enter_location_id"
                                        fieldName="enter_department"
                                        department_fldId="enter_department_id"
                                        department_id="#get_workstation_detail.enter_dep_id#"
                                        location_id="#get_workstation_detail.enter_loc_id#"
                                        user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
                                        line_info = 3
                                        user_location = 0
                                        width="170">
                                <cfelse>
                                    <cf_wrkdepartmentlocation
                                        returnInputValue="enter_location_id,enter_department,enter_department_id"
                                        returnQueryValue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID"
                                        fieldId="enter_location_id"
                                        fieldName="enter_department"
                                        department_fldId="enter_department_id"
                                        user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
                                        line_info = 3
                                        user_location = 0
                                        width="170">
                                </cfif>
                            </div>
                        </div>
                        <div class="form-group" id="item-cost">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36525.Adam Saat Maliyet'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <cfinput type="text" name="cost" id="cost" value="#TlFormat(get_workstation_detail.cost,4)#" required="yes" onkeyup="FormatCurrency(this,event,8)" class="moneybox">
                                    <span class="input-group-addon width">
                                    <input type="hidden" name="HID_COST_MONEY" id="HID_COST_MONEY" />
                                    <select name="COST_MONEY" id="COST_MONEY">
                                        <cfoutput query="get_money">
                                        <option value="#money#" <cfif get_workstation_detail.cost_money eq money>selected</cfif>>#money#</option>
                                        </cfoutput>
                                    </select>
                                    </span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-employee_number">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36414.Adam Sayisi'></label>
                            <div class="col col-8 col-xs-12">
                                <input name="employee_number" id="employee_number" type="text" value="<cfif len(get_workstation_detail.employee_number)><cfoutput>#TlFormat(get_workstation_detail.employee_number,0)#</cfoutput></cfif>" onKeyup="return(FormatCurrency(this,event,0));" class="moneybox"/>
                            </div>
                        </div>
                        <div class="form-group" id="item-comp_name">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36409.Dis Kaynak'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">
                                    <cfif len(get_workstation_detail.outsource_partner)>
                                        <cfquery name="GET_PARTNER" datasource="#DSN#">
                                            SELECT 
                                                C.FULLNAME AS FULLNAME2, 
                                                CP.COMPANY_PARTNER_NAME,
                                                CP.COMPANY_PARTNER_SURNAME 
                                            FROM 
                                                COMPANY C,
                                                COMPANY_PARTNER CP 
                                            WHERE 
                                                CP.PARTNER_ID = #get_workstation_detail.outsource_partner# AND 
                                                CP.COMPANY_ID = C.COMPANY_ID
                                        </cfquery>
                                        <input type="hidden" name="comp_id" id="comp_id" />
                                        <input type="text" name="comp_name" id="comp_name" value="<cfoutput>#get_partner.fullname2#</cfoutput>" onFocus="AutoComplete_Create('comp_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1\',0,0,0','COMPANY_ID,PARTNER_ID,MEMBER_PARTNER_NAME','comp_id,partner_id,partner_name','','3','250');">
                                    <cfelse>
                                        <input type="hidden" name="comp_id" id="comp_id" />
                                        <input type="text" name="comp_name" id="comp_name" value="" onFocus="AutoComplete_Create('comp_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2,3,4,5\',0,0,0','COMPANY_ID,PARTNER_ID,MEMBER_PARTNER_NAME','comp_id,partner_id,partner_name','','3','250');"/>
                                    </cfif>
                                    <span class="input-group-addon icon-ellipsis btnPointer" title="" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_pars&select_list=1,2,3,4,5,6&field_name=upd_workstation.partner_name&field_partner=upd_workstation.partner_id&field_comp_name=upd_workstation.comp_name&field_comp_id=upd_workstation.comp_id</cfoutput>','list')"></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-partner_name">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
                            <div class="col col-8 col-xs-12">
                                <cfif len(get_workstation_detail.outsource_partner)>
                                    <input type="hidden" name="partner_id" id="partner_id" value="<cfoutput>#get_workstation_detail.outsource_partner#</cfoutput>" />
                                    <input type="text" name="partner_name" id="partner_name" readonly VALUE="<cfoutput>#get_partner.company_partner_name#&nbsp;#get_partner.company_partner_surname#</cfoutput>" />
                                <cfelse>
                                    <input type="hidden" name="partner_id" id="partner_id" value="" />
                                    <input type="text" name="partner_name" id="partner_name" value="" readonly />
                                </cfif>
                            </div>
                        </div>
                        <div class="form-group" id="item-ebatlama">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='48479.A x B x H'></label>
                            <div class="col col-8 col-xs-12">
                                <div class="col col-4 col-xs-12">
                                    <input type="text" name="width" id="width" value="<cfoutput>#get_workstation_detail.WIDTH#</cfoutput>" />
                                </div>
                                <div class="col col-4 col-xs-12">
                                    <input type="text" name="length" id="length" value="<cfoutput>#get_workstation_detail.LENGTH#</cfoutput>" />
                                </div>
                                <div class="col col-4 col-xs-12">
                                    <input type="text" name="height" id="height" value="<cfoutput>#get_workstation_detail.HEIGHT#</cfoutput>" />
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-group" id="item-comment">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açiklama'></label>
                            <div class="col col-8 col-xs-12">
                                <textarea name="comment" id="comment" style="width:503px; height:65px;"><cfoutput>#get_workstation_detail.comment#</cfoutput></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="col col-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                        <div class="form-group" id="item-active">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                            <div class="col col-8 col-xs-12">
                                <input type="checkbox" name="active" id="active"<cfif get_workstation_detail.active eq 1>checked</cfif> />
                            </div>
                        </div>
                        <!---Ezgi Yazılım Özelleştirme--->
                        <div class="form-group" id="item-katsayi">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='558.Katsayı'></label>
                            <div class="col col-8 col-xs-12">
							    <input name="ezgi_katsayi" id="ezgi_katsayi" type="text" value="<cfif len(get_workstation_detail.ezgi_katsayi)><cfoutput>#TlFormat(get_workstation_detail.ezgi_katsayi,2)#</cfoutput></cfif>" onKeyup="return(FormatCurrency(this,event,2));" class="moneybox"/>
                            </div>
                        </div>
                        <div class="form-group" id="item-oreder_control">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='630.Emir Arama'></label>
                            <div class="col col-8 col-xs-12">
                                <select name="ezgi_order_control" id="ezgi_order_control">
                               		<option value="0" <cfif get_workstation_detail.ezgi_order_control eq 0>selected</cfif>><cf_get_lang dictionary_id='1066.Tüm Emirler'></option>
                                 	<option value="1" <cfif get_workstation_detail.ezgi_order_control eq 1>selected</cfif>><cf_get_lang dictionary_id='1358.Planlı Emirler'></option>
                           		</select>
                            </div>
                        </div>
                        <div class="form-group" id="item-package_control">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='38468.Ürün Kontrol'></label>
                            <div class="col col-8 col-xs-12">
								<select name="ezgi_package_control" id="ezgi_package_control">
                               		<option value="0" <cfif get_workstation_detail.ezgi_package_control eq 0>selected</cfif>><cf_get_lang dictionary_id='58546.Yok'></option>
                                 	<option value="1" <cfif get_workstation_detail.ezgi_package_control eq 1>selected</cfif>><cf_get_lang dictionary_id='39093.Ürün Barkod'></option>
                                 	<option value="2" <cfif get_workstation_detail.ezgi_package_control eq 2>selected</cfif>><cf_get_lang dictionary_id='39093.Ürün Barkod'> + <cf_get_lang dictionary_id='833.Paket Ekle'></option>
                                    <option value="3" <cfif get_workstation_detail.ezgi_package_control eq 3>selected</cfif>><cf_get_lang dictionary_id='36815.Grupla'> <cf_get_lang dictionary_id='61695.Üret'></option>
                                    <option value="4" <cfif get_workstation_detail.ezgi_package_control eq 4>selected</cfif>>Takip No Kontrol</option>
                                    <option value="5" <cfif get_workstation_detail.ezgi_package_control eq 5>selected</cfif>>Hızlı Üret</option>
                                    <option value="6" <cfif get_workstation_detail.ezgi_package_control eq 6>selected</cfif>>Şablon Bazlı Üretim</option>
                                    <option value="7" <cfif get_workstation_detail.ezgi_package_control eq 7>selected</cfif>>Şartlı Liste</option>
                           		</select>
                            </div>
                        </div>
                        <div class="form-group" id="item-previous_operation_end_control">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='1376.Önceki Operasyon Bitiş Kontrolü'></label>
                            <div class="col col-8 col-xs-12">
								<select name="previous_operation_end_control" id="previous_operation_end_control">
                               		<option value="0" <cfif get_workstation_detail.PREVIOUS_OPERATION_END_CONTROL eq 0>selected</cfif>><cf_get_lang dictionary_id='38000.Takibi Yapılmasın'></option>
                                 	<option value="1" <cfif get_workstation_detail.PREVIOUS_OPERATION_END_CONTROL eq 1>selected</cfif>><cf_get_lang dictionary_id='58467.Başlama'> <cf_get_lang dictionary_id='37999.Takibi Yapılsın'></option>
                                    <option value="3" <cfif get_workstation_detail.PREVIOUS_OPERATION_END_CONTROL eq 3>selected</cfif>><cf_get_lang dictionary_id='57502.Bitiş'> <cf_get_lang dictionary_id='37999.Takibi Yapılsın'></option>
                           		</select>
                            </div>
                        </div>
                        <div class="form-group" id="item-setting_period_hour">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36416.Ayarlama Süresi'> (<cf_get_lang dictionary_id='42828.Saniye'>)</label>
                            <div class="col col-8 col-xs-12">
								<input name="ezgi_setup_time" id="ezgi_setup_time" type="text" value="<cfif len(get_workstation_detail.ezgi_setup_time)><cfoutput>#TlFormat(get_workstation_detail.ezgi_setup_time,0)#</cfoutput></cfif>" onKeyup="return(FormatCurrency(this,event,0));" class="moneybox"/>
                            </div>
                        </div>
                        <input name="setting_period_hour" id="setting_period_hour" type="hidden" value="<cfif len(get_workstation_detail.set_period_hour)><cfoutput>#TlFormat(get_workstation_detail.set_period_hour,0)#</cfoutput></cfif>" onKeyup="return(FormatCurrency(this,event,0));" class="moneybox"/>
                        <input name="setting_period_minute" id="setting_period_minute" type="hidden" value="<cfif len(get_workstation_detail.set_period_minute)><cfoutput>#TlFormat(get_workstation_detail.set_period_minute,0)#</cfoutput></cfif>" onKeyup="return(FormatCurrency(this,event,0));" class="moneybox"/>
                        <div class="form-group" id="item-thickness">
                            <label class="col col-4 col-xs-12"><strong>Ebatlama Blgileri</strong></label>
                            <div class="col col-8 col-xs-12">
                                <div class="col col-12 col-xs-12">
                                     <hr style="width:100%; border:0; border-top:2px solid #ccc; margin:1px 0;" />
                                </div>
                            </div>
                        </div>
                       
                        <div class="form-group" id="item-trimming">
                            <label class="col col-4 col-xs-12">Dış Kenar Traşlama (mm)</label>
                            <div class="col col-8 col-xs-12">
                                <div class="col col-12 col-xs-12">
                                    <input type="text" name="trimming" id="trimming" value="<cfoutput>#TlFormat(get_workstation_detail.OUTER_EDGE_TRIMMING_ALLOWANCE,1)#</cfoutput>" onKeyup="return(FormatCurrency(this,event,1));" class="moneybox"/>
                                </div>
                            </div>
                        </div>
                   		<div class="form-group" id="item-thickness">
                            <label class="col col-4 col-xs-12">Testere Kalınlığı (mm)</label>
                            <div class="col col-8 col-xs-12">
                                <div class="col col-12 col-xs-12">
                                    <input type="text" name="thickness" id="thickness" value="<cfoutput>#TlFormat(get_workstation_detail.CIRCLE_TESTRE_THICKNESS,1)#</cfoutput>" onKeyup="return(FormatCurrency(this,event,1));" class="moneybox"/>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-cutting_method">
                            <label class="col col-4 col-xs-12">Optimizasyon Yöntemi</label>
                            <div class="col col-8 col-xs-12">
                            	<select name="cutting_method" id="cutting_method">
                                 	<option value="1" <cfif get_workstation_detail.CUTTING_METHOD eq 1>selected</cfif>>Saf Guillotine</option>
                                    <option value="2" <cfif get_workstation_detail.CUTTING_METHOD eq 2>selected</cfif>>Hibrit (Best-Fit)</option>
                           		</select>
                            </div>
                        </div>
                        <div class="form-group" id="item-max_number">
                            <label class="col col-4 col-xs-12">Max.Plaka Kat</label>
                            <div class="col col-8 col-xs-12">
                                <div class="col col-12 col-xs-12">
                                    <input type="text" name="max_number" id="max_number" value="<cfoutput>#TlFormat(get_workstation_detail.MAXIMUM_NUMBER_OF_CUTS,0)#</cfoutput>" onKeyup="return(FormatCurrency(this,event,0));" class="moneybox"/>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-group" id="item-rotate">
                            <label class="col col-4 col-xs-12">Max.Farklı Kesim</label>
                            <div class="col col-8 col-xs-12">
                                <div class="col col-12 col-xs-12">
                                    <input type="text" name="max_different_cuts" id="max_different_cuts" value="<cfoutput>#TlFormat(get_workstation_detail.MAXIMUM_DIFFERENT_CUTS,0)#</cfoutput>" onKeyup="return(FormatCurrency(this,event,0));" class="moneybox"/>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-cutting_direction">
                            <label class="col col-4 col-xs-12">Kesim Başlama Yönü</label>
                            <div class="col col-8 col-xs-12">
                            	<select name="cutting_direction" id="cutting_direction">
                                 	<option value="1" <cfif get_workstation_detail.CUTTING_STARTING_DIRECTION eq 1>selected</cfif>>Plaka Dikey Kesim</option>
                                    <option value="2" <cfif get_workstation_detail.CUTTING_STARTING_DIRECTION eq 2>selected</cfif>>Plaka Yatay Kesim</option>
                           		</select>
                            </div>
                        </div>
                        <!---Ezgi Yazılım Özelleştirme--->
                    </div>
                    <div class="col col-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                        <div class="form-group" id="item-workstation">
                            <cfsavecontent variable="info"><span class="bold"><cf_get_lang dictionary_id='57569.Görevli'> *</span></cfsavecontent>
                                <cf_workcube_to_cc 
                                is_update="1" 
                                cc_dsp_name="#info#" 
                                form_name="upd_workstation" 
                                str_list_param="1" 
                                action_dsn="#dsn3#"
                                str_action_names="EMP_ID as CC_EMP"
                                action_table="WORKSTATIONS"
                                action_id_name="STATION_ID"
                                action_id="#attributes.station_id#"
                                data_type="1"
                                str_alias_names="">
                        </div>
                    </div>
                </cf_box_elements>
                <cf_box_footer>
                    <cf_record_info query_name='get_workstation_detail'><cf_workcube_buttons is_upd='1' is_delete='0' add_function ='control()' type_format='1'>
                </cf_box_footer>
            </cf_box>
            <cfsavecontent variable="message"><cf_get_lang dictionary_id='36522.Alt Istasyonlar'></cfsavecontent>
                <cf_box 
                    id="dsp_sub_stat"
                    box_page="#request.self#?fuseaction=prod.emptypopup_ajax_dsp_ezgi_sub_station&station_id=#attributes.station_id#"
                    title="#message#"
                    add_href="#request.self#?fuseaction=prod.list_ezgi_workstation&event=add&stat_id=#station_id#"
                    closable="0"></cf_box>
        </div>
        <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                <cfsavecontent variable="message"><cf_get_lang dictionary_id ='36632.Istasyon-Kapasite/Saat'></cfsavecontent>
                <cf_get_workcube_asset company_id="#session.ep.company_id#" asset_cat_id="-3" module_id='35' action_section='STATION_ID' action_id='#attributes.station_id#'>
                <cf_box 
                    id="list_product_ws"
                    box_page="#request.self#?fuseaction=prod.emptypopup_list_product_ws_ajaxproduct&upd=#attributes.station_id#"
                    add_href="#request.self#?fuseaction=prod.popup_add_ws_product&is_upd_workstation=1&ws_id=#attributes.station_id#"
                    title="#message#" add_href_size="wwide1"
                    closable="0">
                </cf_box>
                <cfsavecontent variable="message"><cf_get_lang dictionary_id ='36950.Iliskili Fiziki Varliklar'></cfsavecontent>
                <cf_box 
                    id="rel_phy_asset"
                    info_href="#request.self#?fuseaction=assetcare.popup_list_relation_assetp&station_id=#attributes.station_id#"
                    title="#message#"
                    box_page="#request.self#?fuseaction=prod.emptypopup_ajax_dsp_physical_assets&station_id=#attributes.station_id#"
                    closable="0">
                </cf_box>
        </div>
    </cfform>  
</div>
<cfset attributes.department_id= GET_WORKSTATION_DETAIL.DEPARTMENT>
<script type="text/javascript">
	function get_departments(branch_id){
		var get_dep=workdata('get_branch_dep',branch_id);
		document.upd_workstation.department_id.options.length=0;
		document.upd_workstation.department_id.options[0] = new Option('Departman','');
		if (get_dep.recordcount)
		{
			for(var jj=0;jj<get_dep.recordcount;jj++)
			document.upd_workstation.department_id.options[jj+1] = new Option(get_dep.DEPARTMENT_HEAD[jj],get_dep.DEPARTMENT_ID[jj]);
		}
	}
	<cfoutput>
	get_departments('#GET_WORKSTATION_DETAIL.BRANCH#');
	<cfif len(GET_WORKSTATION_DETAIL.DEPARTMENT)>
		document.upd_workstation.department_id.value='#GET_WORKSTATION_DETAIL.DEPARTMENT#';	
	</cfif>
	</cfoutput>
	var my_moneys=document.upd_workstation.COST_MONEY.options.length;
	var money=new Array(my_moneys);
	<cfset count=0>
	<cfloop query="get_money">
		<cfset count=count+1>
		money[<cfoutput>#count#</cfoutput>]=<cfoutput>#Evaluate(rate2/rate1)#</cfoutput>;
	</cfloop>
	
	function change_comp()
	{
		document.getElementById('comp_id').value = '';
		document.getElementById('comp_name').value = '';
		document.getElementById('partner_id').value = '';	
		document.getElementById('partner_name').value = '';	
	}
	
	function unformat_fields()
	{
		document.upd_workstation.energy.value = filterNum(document.upd_workstation.energy.value);
		document.upd_workstation.cost.value = filterNum(document.upd_workstation.cost.value,4);
		document.upd_workstation.employee_number.value = filterNum(document.upd_workstation.employee_number.value,0);
		document.upd_workstation.setting_period_hour.value = filterNum(document.upd_workstation.setting_period_hour.value,0);
		document.upd_workstation.setting_period_minute.value = filterNum(document.upd_workstation.setting_period_minute.value,0);
		document.upd_workstation.avg_capacity_day.value = filterNum(document.upd_workstation.avg_capacity_day.value,0);
		document.upd_workstation.avg_capacity_hour.value = filterNum(document.upd_workstation.avg_capacity_hour.value,0);
		document.upd_workstation.ws_avg_cost.value = filterNum(document.upd_workstation.ws_avg_cost.value);
	}
	function control(){
		if(!$("#STATION_NAME").val().length)
		{
			alertObject({message: "<cfoutput><cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='58834.Istasyon'></cfoutput>"})    
			return false;
		}
		if(document.upd_workstation.production_department.value=='')
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='36763.Üretim Depo'>");
			return false;
		}
		if(document.upd_workstation.exit_department.value=='')
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='36761.Sarf Depo'>");
			return false;
		}
		if(document.getElementById('cc_emp_ids') == undefined)
		{
			alert("<cf_get_lang dictionary_id='36913.Görevli Seçiniz'>!");
			return false;
		}
		if (document.upd_workstation.branch_id_sta.value== 0 || document.upd_workstation.department_id.value==0){
			alert("<cf_get_lang dictionary_id ='36914.Sube ve Departmani Eksiksiz Seçiniz'>");	
			return false;
		}
		return (unformat_fields());
	}
</script>
