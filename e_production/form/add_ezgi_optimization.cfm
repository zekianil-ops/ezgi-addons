<!---
    File: add_ezgi_optimization.cfm
    Folder: AddOns\ezgi\e_production\form
    Author: Ezgi Yazılım
    Date: #dateFormat(now(), "dd/mm/yyyy")#
    Description: Optimizasyon Ekleme Sayfası
--->

<cf_xml_page_edit>
<cf_catalystHeader>

<!--- Belge numarası otomatik oluşturma --->
<cfquery name="get_paper_number" datasource="#dsn3#">
	SELECT 
        TOP (1) CAST(OPTIMIZATION_NUMBER AS INT) AS OPTIMIZATION_NUMBER
	FROM 
        EZGI_IFLOW_OPTIMIZATION
	ORDER BY 
        OPTIMIZATION_NUMBER DESC
</cfquery>

<cfif get_paper_number.recordcount>
	<cfset default_optimization_number = get_paper_number.OPTIMIZATION_NUMBER + 1>
<cfelse>
	<cfset default_optimization_number = 10000>
</cfif>

<!--- Master Plan listesi --->
<cfquery name="get_master_plans" datasource="#dsn3#">
	SELECT 
		MASTER_PLAN_ID, 
		MASTER_PLAN_NUMBER, 
		MASTER_PLAN_DETAIL
	FROM 
		EZGI_IFLOW_MASTER_PLAN
	WHERE 
		(MASTER_PLAN_CAT_ID = 1) 
		AND (MASTER_PLAN_STATUS = 1) 
		AND (MASTER_PLAN_PROCESS = 1)
	ORDER BY 
		MASTER_PLAN_ID DESC
</cfquery>

<div class="col col-12 col-xs-12">
	<cf_box>
    	<cfform name="form_basket" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_optimization">
        	<cf_box_elements>
            	<cfoutput>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-optimization_number">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57880.Belge No'></label>
                     	<div class="col col-8 col-xs-12">
                        	<input name="optimization_number" type="text" readonly="readonly" value="#default_optimization_number#" maxlength="20" style="width:150px;" />
                      	</div>
                 	</div>
                    <div class="form-group" id="item-optimization_date">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></label>
                     	<div class="col col-8 col-xs-12">
                        	<div class="input-group">
                            	<cfinput type="text" name="optimization_date" value="#dateformat(now(), dateformat_style)#" style="width:100px;" validate="#validate_style#" maxlength="10">
                            	<span class="input-group-addon"><cf_wrk_date_image date_field="optimization_date"></span>
                        	</div>
                      	</div>
                 	</div>
                    <div class="form-group" id="item-master_plan_id">
                     	<label class="col col-4 col-xs-12">Master Plan *</label>
                     	<div class="col col-8 col-xs-12">
                        	<select name="master_plan_id" id="master_plan_id" style="width:200px;" required>
                            	<option value="">-- Seçiniz --</option>
                            	<cfif isDefined("get_master_plans") and get_master_plans.recordcount>
                            		<cfloop query="get_master_plans">
                            			<option value="#MASTER_PLAN_ID#">#MASTER_PLAN_NUMBER# <cfif len(MASTER_PLAN_DETAIL)>- #MASTER_PLAN_DETAIL#</cfif></option>
                            		</cfloop>
                            	</cfif>
                        	</select>
                      	</div>
                 	</div>
                    <div class="form-group" id="item-optimization_emp">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57899.Kaydeden'></label>
                     	<div class="col col-8 col-xs-12">
                        	<div class="input-group">
                            	<input type="hidden" name="optimization_emp_id" id="optimization_emp_id" value="#session.ep.userid#">
                            	<input name="optimization_emp_name" type="text" id="optimization_emp_name" style="width:120px;" placeholder="<cf_get_lang dictionary_id='57899.Kaydeden'>" onFocus="AutoComplete_Create('optimization_emp_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','optimization_emp_id','form_basket','3','125');" value="" autocomplete="off">
                            	<span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_name=form_basket.optimization_emp_name&field_emp_id=form_basket.optimization_emp_id&select_list=1,9','list');return false"></span>
                        	</div>
                      	</div>
                 	</div>
                    
                    <div class="form-group" id="item-optimization_detail">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                     	<div class="col col-8 col-xs-12">
                        	<textarea name="optimization_detail" rows="3" style="width:200px;" maxlength="500"></textarea>
                      	</div>
                 	</div>
                </div>
                </cfoutput>
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-12">
                <cf_workcube_buttons type_format="1" is_upd='0' add_function='kontrol()'>
                </div>
            </cf_box_footer>
        </cfform>
    </cf_box>
</div>
<script type="text/javascript">
	function kontrol()
	{
		if (form_basket.optimization_date.value.length == 0)
		{
			alert("<cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'> !");
			return false;
		}
		if (form_basket.optimization_emp_id.value.length == 0 || form_basket.optimization_emp_id.value == 0)
		{
			alert("<cf_get_lang dictionary_id='57899.Kaydeden'> seçmelisiniz !");
			return false;
		}
		if (form_basket.master_plan_id.value.length == 0 || form_basket.master_plan_id.value == 0)
		{
			alert("Master Plan seçmelisiniz !");
			return false;
		}
		return true;
	}
</script>










