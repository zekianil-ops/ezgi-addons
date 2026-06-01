<cfset attributes.calc_today=1>
<cfquery name="GET_MONEY" datasource="#DSN#">
	SELECT
		MONEY
	FROM
		SETUP_MONEY
	WHERE
		PERIOD_ID = #SESSION.EP.PERIOD_ID# AND
		COMPANY_ID = #SESSION.EP.COMPANY_ID#
</cfquery>
<cfquery name="GET_WORKSTATION" datasource="#DSN3#">
	SELECT
		STATION_ID,
        STATION_NAME 
	FROM
		WORKSTATIONS
	WHERE
		STATION_ID IS NOT NULL AND
		UP_STATION IS NULL AND
		ACTIVE = 1
		<cfif isdefined("attributes.station_id") and len(attributes.station_id)>
			AND STATION_ID <> #attributes.station_id#
		</cfif>
	ORDER BY
		STATION_NAME
</cfquery>
<cfquery name="GET_DEPARTMENT" datasource="#DSN#">
	SELECT
		DEPARTMENT_ID,
        BRANCH_ID,
        IS_PRODUCTION,
        DEPARTMENT_HEAD
	FROM
		DEPARTMENT
	WHERE
		BRANCH_ID IS NOT NULL AND
		IS_PRODUCTION = 1
		<cfif isDefined("attributes.branch_id")>
			<cfif attributes.branch_id NEQ 0>
		AND
			BRANCH_ID = #attributes.branch_id#
			</cfif>
		</cfif>
	ORDER BY
		DEPARTMENT_HEAD
</cfquery>
<cfquery name="GET_BRANCH" datasource="#DSN#">
	SELECT
		BRANCH_ID,
        BRANCH_NAME
	FROM
		BRANCH
	WHERE 
		IS_PRODUCTION=1
		AND COMPANY_ID = #session.ep.company_id#
		AND BRANCH_ID IN(SELECT BRANCH_ID FROM EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE = #session.ep.position_code#)
	ORDER BY 
		BRANCH_NAME
</cfquery>
<cfif isdefined("attributes.keyword")>
  <cfif attributes.keyword eq "branch">
    <script language="JavaScript">
		alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57453.Şube'> <cf_get_lang dictionary_id='57989.ve'> <cf_get_lang dictionary_id='57572.Departman'>");
	</script>
  </cfif>
  <cfif attributes.keyword eq "employee">
    <script language="JavaScript">
		alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57569.Görevli'>");
	</script>
  </cfif>
</cfif>


<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfform name="add_workstation" method="post" action="#request.self#?fuseaction=prod.add_workstation_process">
	<cf_catalystHeader> 
		<cf_box>
			<cf_box_elements>
				<div class="col col-4 col-sm-4 col-xs-12" type="column" index="1" sort="true">
	            	<div class="form-group" id="item-is_capacity">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='36379.Sonlu Kapasite'></label>
	                    <div class="col col-8 col-xs-12">
	                        <input type="checkbox" name="is_capacity" id="is_capacity">
	                    </div>
	                </div>
	                <div class="form-group" id="item-up_station">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36399.Üst Istasyon'></label>
	                    <div class="col col-8 col-xs-12">
	                    	<select name="up_station" id="up_station">
								<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
								<cfoutput query="get_workstation">
									<option value="#station_id#" <cfif isdefined("attributes.stat_id") and  attributes.stat_id eq station_id>selected</cfif>>#station_name#</option>
								</cfoutput>
							</select>
	                    </div>
	                </div>
	                <div class="form-group" id="item-STATION_NAME">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58834.İstasyon'> *</label>
	                    <div class="col col-8 col-xs-12">
							<cfinput type="text" name="station_name" maxlength="100" id="station_name">
						</div>
	                </div>
	                <div class="form-group" id="item-branch_id">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57453.Sube'> *</label>
	                    <div class="col col-8 col-xs-12">
	                        <select name="branch_id" id="branch_id" onchange="redirect(this.options.selectedIndex)">
								<option value="0"><cf_get_lang dictionary_id='57734.Seçiniz'></option>
								<cfoutput query="get_branch">
									<cfif isDefined("attributes.department_id") and attributes.branch_id eq branch_id><cfset cat_id = currentrow></cfif>
									<option value="#branch_id#">#branch_name#</option>
								</cfoutput>
							</select>
	                    </div>
	                </div>
	                <div class="form-group" id="item-department_id">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57572.Departman'> *</label>
	                    <div class="col col-8 col-xs-12">
	                       <select name="department_id" id="department_id">
								<option value="0"><cf_get_lang dictionary_id='36403.Önce Şube Seçiniz'></option>
							</select>
	                    </div>
	                </div>
	                <div class="form-group" id="item-cost">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36525.Adam Saat Maliyet'> *</label>
	                    <div class="col col-8 col-xs-12">
		                    <div class="input-group">
								<cfinput type="text" name="cost" id="cost" required="yes" maxlength="10" onkeyup="FormatCurrency(this,event,8)" class="moneybox">
		                        <span class="input-group-addon width">
		                        <input type="hidden" name="HID_COST_MONEY" id="HID_COST_MONEY" />
		                        <select name="COST_MONEY" id="COST_MONEY">
									<cfoutput query="get_money">
										<option value="#money#">#money#</option>
									</cfoutput>
								</select>
		                        </span>
	                        </div>
						</div>
	                </div>
                    <div class="form-group" id="item-comp_name">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36409.Dış Kaynak'></label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <input type="hidden" name="comp_id" id="comp_id">
								<input type="text" name="comp_name" id="comp_name" onClick="change_comp();" onFocus="AutoComplete_Create('comp_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2,3,4,5\',0,0,0','COMPANY_ID,PARTNER_ID,MEMBER_PARTNER_NAME','comp_id,partner_id,partner_name','','3','250');">
                                <span class="input-group-addon icon-ellipsis btnPointer" title="" onClick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_pars&field_name=add_workstation.partner_name&field_partner=add_workstation.partner_id&field_comp_name=add_workstation.comp_name&field_comp_id=add_workstation.comp_id</cfoutput>','list')"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-partner_name">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
	                    <div class="col col-8 col-xs-12">
							<input type="hidden" name="partner_id" id="partner_id">
							<input type="text" name="partner_name" id="partner_name" readonly>
						</div>
	                </div>
                    <div class="form-group" id="item-setting_period_hour">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36416.Ayarlama Süresi'></label>
	                    <div class="col col-8 col-xs-12">
		                    <div class="input-group">
		                        <input name="setting_period_hour" id="setting_period_hour" type="text" onkeyup="return(FormatCurrency(this,event,0,'int'));" maxlength="10" class="moneybox">
		                        <span class="input-group-addon"><cf_get_lang dictionary_id='57491.Saat'></span>
								<input name="setting_period_minute" id="setting_period_minute" type="text" onkeyup="return(FormatCurrency(this,event,0,'int'));" maxlength="5" class="moneybox">
		                        <span class="input-group-addon"><cf_get_lang dictionary_id='58827.Dk'></span>
							 </div>
	                    </div>
	                </div>
                    <div class="form-group" id="item-comment">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açiklama'></label>
						<div class="col col-8 col-xs-12">
							<cfsavecontent variable="message"><cf_get_lang dictionary_id='56293.200 Karakterden Fazla Yazmayınız'>!</cfsavecontent>
	                    	<textarea name="comment" id="comment" maxlength="200" onkeyup="return ismaxlength(this)" onblur="return ismaxlength(this);" message="<cfoutput>#message#</cfoutput>"></textarea>
	                    </div>
	                </div>
                </div>
	            <div class="col col-4 col-sm-4 col-xs-12" type="column" index="2" sort="true">
	                <div class="form-group" id="item-active">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
	                    <div class="col col-8 col-xs-12">
	                        <input type="checkbox" name="active" id="active" checked>
	                    </div>
	                </div>
	                <div class="form-group" id="item-enter_department">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36764.Sevkiyat Depo'></label>
	                    <div class="col col-8 col-xs-12">
		                    <cf_wrkdepartmentlocation
								returninputvalue="enter_location_id,enter_department,enter_department_id,enter_branch_id"
								returnqueryvalue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID,BRANCH_ID"
								fieldname="enter_department"
								branch_fldid="enter_branch_id"
								fieldid="enter_location_id"
								department_fldid="enter_department_id"
                                boxwidth="350"
								user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
                                user_location = 0
								line_info = 1
								width="175">
	                    </div>
	                </div>
	                <div class="form-group" id="item-production_location_id">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36763.Üretim Depo'> *</label>
	                    <div class="col col-8 col-xs-12">
		                    <cf_wrkdepartmentlocation
								returninputvalue="production_location_id,production_department,production_department_id,production_branch_id"
								returnqueryvalue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID,BRANCH_ID"
								fieldname="production_department"
								branch_fldid="production_branch_id"
								fieldid="production_location_id"
								department_fldid="production_department_id"
                                boxwidth="350"
								user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
								line_info = 2
								width="175">
						</div>
	                </div>
	                <div class="form-group" id="item-exit_location_id">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36761.Sarf Depo'>*</label>
	                    <div class="col col-8 col-xs-12">
							<cf_wrkdepartmentlocation
								returninputvalue="exit_location_id,exit_department,exit_department_id,exit_branch_id"
								returnqueryvalue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID,BRANCH_ID"
								fieldname="exit_department"
								branch_fldid="exit_branch_id"
								fieldid="exit_location_id"
								department_fldid="exit_department_id"
                                boxwidth="350"
								user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
								line_info = 3
								width="175">
						</div>
	                </div>
	                <div class="form-group" id="item-energy">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36407.Enerji Tüketimi'> *</label>
	                    <div class="col col-8 col-xs-12">
		                    <div class="col col-6 col-xs-12">
		                    	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='36407.Enerji Tüketimi'></cfsavecontent>
								<cfinput type="text" name="energy" maxlength="10" required="yes" message="#message#" onKeyup="return(formatcurrency(this,event,2));" class="moneybox">
								<cfinclude template="../query/get_basic_types.cfm">
		                    </div>  
							<div class="col col-6 col-xs-12"> 
								<select name="BASIC_TYPE" id="BASIC_TYPE">
									<cfoutput query="get_b_type">
										<option  value="#basic_input_id#">#basic_input#</option>
									</cfoutput>
								</select>	
							</div>
	                        
	                    </div>
	                </div>
                    <div class="form-group" id="item-employee_number">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36414.Adam Sayisi'></label>
	                    <div class="col col-8 col-xs-12">
							<input type="text" name="employee_number" id="employee_number" maxlength="10" onkeyup="return(FormatCurrency(this,event,0,'int'));" class="moneybox">
						</div>
	                </div>
                    <div class="form-group" id="item-avg_capacity">
	                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36400.Ortalama Yil Kapasite'></label>
	                    <div class="col col-8 col-xs-12">
		                    <div class="input-group">
		                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='36400.Ortalama Yıl Kapasite'></cfsavecontent>
								<cfinput name="avg_capacity_day" type="text" range="1,365" maxlength="10" message="#message#" onKeyup="return(formatcurrency(this,event,0));" class="moneybox">
		                        <span class="input-group-addon"><cf_get_lang dictionary_id='57490.Gün'></span>
								<cfinput name="avg_capacity_hour" type="text" range="1,24" maxlength="10" message="#message#" onKeyup="return(formatcurrency(this,event,0));" class="moneybox">
		                        <span class="input-group-addon">
		                        	<cf_get_lang dictionary_id='57491.Saat'>
		                        </span>
							 </div>
	                    </div>
	                </div>
                    <div class="form-group" id="item-width">
	                    <label class="col col-4 col-xs-12">A x B x H</label>
	                    <div class="col col-8 col-xs-12">
	                        <div class="col col-4 col-xs-12">
	                            <input type="text" maxlength="5" name="width" id="width" value="" />
							</div>
	                        <div class="col col-4 col-xs-12">
								<input type="text" maxlength="5" name="length" id="length" value="" /> 
							</div>
	                        <div class="col col-4 col-xs-12">
								<input type="text" maxlength="5" name="height" id="height" value="" />
							</div>
	                    </div>
	                </div>
	            </div>
	            <div class="col col-4 col-sm-4 col-xs-12" type="column" index="3" sort="true">
	                <div class="form-group" id="item-workstation">
						<cfsavecontent variable="info"><span class="bold"><cf_get_lang dictionary_id='57569.Görevli'> *</span></cfsavecontent>
						<cf_workcube_to_cc
						is_update="0"
						cc_dsp_name="#info#"
						form_name="add_workstation"
						str_list_param="1"
						data_type="2">
					</div>
				</div>
			</cf_box_elements>
			<cf_box_footer>
				<cf_workcube_buttons is_upd='0' add_function ='control()'>
			</cf_box_footer>
		</cf_box>
	 
	</cfform>
</div>
<script language="JavaScript">
	var groups=document.add_workstation.branch_id.options.length;
	var group=new Array(groups);
	for (i=0; i<groups; i++)
		group[i]=new Array();
	<cfset sayac = 1>
	<cfloop query="get_branch">
		<cfset attributes.branch_id = branch_id>
		<cfset attributes.names=1>
		<cfquery name="GET_DEPARTMENT_ROW" dbtype="query">
			SELECT
				*
			FROM
				GET_DEPARTMENT
			WHERE
				BRANCH_ID IS NOT NULL AND
				IS_PRODUCTION = 1
				<cfif isDefined("attributes.branch_id")>
					<cfif attributes.branch_id NEQ 0>
				AND
					BRANCH_ID = #attributes.branch_id#
					</cfif>
				</cfif>
			ORDER BY
				DEPARTMENT_HEAD
		</cfquery> 
	
		group[<cfoutput>#sayac#</cfoutput>][0]=new Option("Seçiniz","0");
	
			<cfoutput query="get_department_row">
				  <cfif isDefined("attributes.department_id")>
					<cfif attributes.department_id eq department_id>
						<cfset id = currentrow>
					</cfif>
				  </cfif>
				group[#sayac#][#currentrow#]=new Option("#department_head#","#department_id#");
			</cfoutput>
	
		<cfset sayac = sayac + 1>
	</cfloop>
	var temp=document.add_workstation.department_id;
	
	function redirect(x)
	{
		for (m=temp.options.length-1;m>0;m--)
			temp.options[m]=null;
		for (i=0;i<group[x].length;i++)
		{
			temp.options[i]=new Option(group[x][i].text,group[x][i].value);
		}
		temp.options[0].selected=true;
	}
	<cfif isDefined("attributes.department_id")>
		document.add_workstation.branch_id.selectedIndex = <cfoutput>#cat_id#</cfoutput>;
		redirect(<cfoutput>#cat_id#</cfoutput>);
		document.add_workstation.department_id.selectedIndex = <cfoutput>#id#</cfoutput>;
	</cfif>
	
	function change_comp()
	{
		document.getElementById('comp_id').value = '';
		document.getElementById('comp_name').value = '';
		document.getElementById('partner_id').value = '';	
		document.getElementById('partner_name').value = '';	
	}
	
	function unformat_fields()
	{
		document.add_workstation.energy.value = filterNum(document.add_workstation.energy.value);
		document.add_workstation.cost.value = filterNum(document.add_workstation.cost.value,4);
		document.add_workstation.employee_number.value = filterNum(document.add_workstation.employee_number.value,0);
		document.add_workstation.setting_period_hour.value = filterNum(document.add_workstation.setting_period_hour.value,0);
		document.add_workstation.setting_period_minute.value = filterNum(document.add_workstation.setting_period_minute.value,0);
		document.add_workstation.avg_capacity_day.value = filterNum(document.add_workstation.avg_capacity_day.value,0);
		document.add_workstation.avg_capacity_hour.value = filterNum(document.add_workstation.avg_capacity_hour.value,0);
	}
	function control()
	{
		if(!$("#cost").val().length)
		{
			alertObject({message: "<cfoutput><cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='36525.Adam Saat Maliyet'></cfoutput>"})    
			return false;
		}
		if(document.add_workstation.station_name.value=='')
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='58834.İstasyon'>");
			return false;
		}
		if(document.add_workstation.production_department.value=='')
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='36763.Üretim Depo'>");
			return false;
		}
		if(document.add_workstation.exit_department.value=='')
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='36761.Sarf Depo'>");
			return false;
		}
		if (document.add_workstation.branch_id.value== 0 || document.add_workstation.department_id.value==0)
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57453.Şube'> <cf_get_lang dictionary_id='57989.ve'> <cf_get_lang dictionary_id='57572.Departman'>");	
			return false;
		}
		if ((document.add_workstation.comment.value.length) > 250)
		{
			alert("<cf_get_lang dictionary_id='36644.En Fazla 250 Karakter Açıklama Girebilirsiniz'>.");	
			return false;
		}
		if(isNaN(document.add_workstation.length.value))
		{
			alert("<cf_get_lang dictionary_id='36645.Hatalı Veri Girişi : En / Boy / Yükseklik'> ");
			return false;
		}
		if(document.getElementById('cc_emp_ids') == undefined)
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57569.Görevli'>");
			return false;
		}
		return ( unformat_fields());
	}
</script>
