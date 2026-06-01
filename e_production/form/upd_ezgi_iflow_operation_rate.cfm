<!---
    File: upd_ezgi_iflow_operation_rate.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_workstation" datasource="#dsn3#">
	SELECT 
    	WP.WS_P_ID,
    	WP.WS_ID, 
        WP.DEFAULT_STATUS, 
        WORKSTATIONS.STATION_ID,
        WORKSTATIONS.STATION_NAME, 
        WORKSTATIONS.EMPLOYEE_NUMBER, 
        WORKSTATIONS.EZGI_SETUP_TIME, 
        WORKSTATIONS.EZGI_KATSAYI,
        WORKSTATIONS.RECORD_EMP, 
        WORKSTATIONS.RECORD_DATE, 
        WORKSTATIONS.UPDATE_EMP, 
        WORKSTATIONS.UPDATE_DATE
	FROM            
    	WORKSTATIONS_PRODUCTS AS WP INNER JOIN
      	WORKSTATIONS ON WP.WS_ID = WORKSTATIONS.STATION_ID
	WHERE        
    	WP.OPERATION_TYPE_ID = #attributes.operation_type_id#
 	ORDER BY
    	WP.DEFAULT_STATUS DESC
</cfquery>
<cfset station_id_list = ValueList(get_workstation.STATION_ID)>
<cfquery name="get_operation" datasource="#dsn3#">
	SELECT        
    	OPERATION_TYPE, 
        O_MINUTE, 
        OPERATION_CODE, 
        OPERATION_STATUS, 
        EZGI_H_SURE, 
        EZGI_FORMUL
	FROM            
    	OPERATION_TYPES
	WHERE        
    	OPERATION_TYPE_ID = #attributes.operation_type_id#
</cfquery>
<br />
<cfsavecontent variable="upd_operation"><cf_get_lang dictionary_id='623.Operasyon Bilgisi Güncelle'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#upd_operation#">
    	<cfform name="upd_operation" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_iflow_operation_rate">
        	<cfinput type="hidden" name="operation_type_id" value="#attributes.operation_type_id#">
            <cfif isdefined('attributes.e_design')>
             	<cfinput type="hidden" name="e_design" value="#attributes.e_design#">
        	<cfelse>
             	<cfinput type="hidden" name="master_plan_id" value="#attributes.master_plan_id#">
         	</cfif>
        	<cfinput type="hidden" name="station_id_list" value="#station_id_list#">
			<cf_basket_form id="upd_default_piece">
                <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
                                	<div class="col col-12" type="column" index="1" sort="true">
                                        <div class="form-group" id="item-operation_code">
                                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='36377.Operasyon Kodu'></label>
                                            <div class="col col-6 col-xs-12">
                                                <cfinput name="operation_code" readonly="yes" type="text" id="operation_code" style="width:50px;" value="#get_operation.operation_code#">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-operation_type">
                                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='437.Operasyon Adı'></label>
                                            <div class="col col-6 col-xs-12">
                                                <cfinput name="operation_type" readonly="yes" type="text" id="operation_type" style="width:300px" value="#get_operation.operation_type#">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-ezgi_i_sure">
                                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57692.İşlem'>/<cf_get_lang dictionary_id='552.Hazırlık Süresi'></label>
                                            <div class="col col-3 col-xs-12">
                                               	<cfinput name="ezgi_i_sure" type="text" id="ezgi_i_sure" style="width:50px; text-align:right" value="#get_operation.O_MINUTE#">
                                            </div>
                                            <div class="col col-3 col-xs-12">
                                                <cfinput name="ezgi_h_sure" type="text" id="ezgi_h_sure" style="width:50px; text-align:right" value="#get_operation.EZGI_H_SURE#">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-status">
                                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='58028.Formül'></label>
                                            <div class="col col-6 col-xs-12">
                                                <cfinput name="formul" type="text" id="formul" style="width:300px" value="#get_operation.EZGI_FORMUL#">
                                            </div>
                                        </div>
                                   	</div>
                              	</cf_box_elements>
                    			<cf_box_footer>
                                	<cf_record_info 
                                        query_name="get_workstation"
                                        record_emp="RECORD_EMP" 
                                        record_date="record_date"
                                        update_emp="UPDATE_EMP"
                                        update_date="update_date">
                                  	<cf_workcube_buttons 
                                     	is_upd='1' 
                                        is_cancel='1' 
                                     	is_delete = '0' 
                                     	add_function='kontrol()'>
                				</cf_box_footer>
                			</div>
            			</div>
        		</div>
    		</cf_basket_form>
            <cf_basket id="upd_default_piece_bask">
            	<cf_grid_list sort="0">
                	 <thead style="width:100%">
                     	<tr height="20px">
                        	<th style="text-align:center; width:25px" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                          	<th style="text-align:center;"><cf_get_lang dictionary_id='36669.İstasyon Adı'></th>
                          	<th style="text-align:center; width:50px" ><cf_get_lang dictionary_id='57576.Çalışan'></th>
                         	<th style="text-align:center; width:70px"><cf_get_lang dictionary_id="36416.Ayarlama Süresi"></th>
                          	<th style="text-align:center; width:70px"><cf_get_lang dictionary_id='558.Katsayı'> </th>
                         	<th style="text-align:center; width:40px"><cf_get_lang dictionary_id="43116.Default"></th>
                      	</tr>
                 	</thead>
                 	<tbody>
                            <cfif get_workstation.recordcount>
                                <cfoutput query="get_workstation">
                                    <tr>
                                        <td style="width:30px; height:30px; text-align:right; vertical-align:middle">#currentrow#</td>
                                        <td style="text-align:left; vertical-align:middle">#STATION_NAME#</td>
                                        <td style="text-align:center; vertical-align:middle">
                                        	<cfinput name="employee_number#station_id#" type="text" id="employee_number#station_id#" style="width:45px" value="#EMPLOYEE_NUMBER#" class="box">
                                        </td>
                                        <td style="text-align:center; vertical-align:middle">
                                        	<cfinput name="ezgi_setup_time#station_id#" type="text" id="ezgi_setup_time#station_id#" style="width:65px" value="#EZGI_SETUP_TIME#" class="box">
                                        </td>
                                        <td style="text-align:center; vertical-align:middle">
                                        	<cfinput name="ezgi_katsayi#station_id#" type="text" id="ezgi_katsayi#station_id#" style="width:65px" value="#TlFormat(EZGI_KATSAYI,1)#" class="box">
                                       	</td>
                                        <td style="text-align:center; vertical-align:middle">
                                        	<input name="default_status#station_id#" type="checkbox" id="default_status#station_id#" value="#WS_P_ID#" <cfif DEFAULT_STATUS eq 1>checked</cfif>>
                                        </td>
                                    </tr>
                                </cfoutput>
                            </cfif>
                        </tbody>
                </cf_grid_list>
            </cf_basket>
 		</cfform>
   	</cf_box>
</div>
<script type="text/javascript">
	function kontrol()
	{
		if(document.getElementById("ezgi_i_sure").value <= 0)
		{
			alert("<cf_get_lang dictionary_id='624.İşlem Süresi 0 dan büyük olmalıdır.'> !");
			document.getElementById('ezgi_i_sure').focus();
			return false;
		}
		if(document.getElementById("ezgi_h_sure").value <= 0)
		{
			alert("<cf_get_lang dictionary_id='625.Hazırlık Süresi 0 dan büyük olmalıdır.'> !");
			document.getElementById('ezgi_h_sure').focus();
			return false;
		}
		sor=confirm('<cf_get_lang dictionary_id='57536.Güncellemek İstediğinizden Emin misiniz?'>')
		if(sor==false)
			return false;
	}
</script>