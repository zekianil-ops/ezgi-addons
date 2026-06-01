<!---
    File: employee_ezgi_identification_1.cfm
    Folder: Add_Ons\ezgi\e-vts\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<style>
	.portBox .portHeadLightTitle span a{
		font-size:30px!important;
	}
</style>

<cfparam name="attributes.deliver_code" default="">
<cfquery name="get_deliver_code" datasource="#dsn3#">
    SELECT * FROM EZGI_VTS_IDENTY
</cfquery>
<cfset deliver_code_list = Valuelist(get_deliver_code.PAROLA)>
<cfsavecontent variable="title"><cf_get_lang dictionary_id='293.Personel Tanıma'></cfsavecontent>
<cf_box title="#title#" style="height:100%!important;" resize="0" collapsable="0"> 
	<cfform name="form_password" id="form_password" method="post" action="#request.self#?fuseaction=production.popup_dsp_employee_ezgi_identification" >
		<cf_box_elements>
			<input type="hidden" name="is_form" value="1">
			<div class="col col-4 col-md-4 col-sm-6 col-xs-12">
				<div class="form-group" id="item-process_cat">
					<label class="col col-4 col-xs-12"style="font-size: 20px;"><cf_get_lang dictionary_id='294.Kartınızı Okutun'> *</label>
					<div class="col col-8 col-xs-12">
						<input type="password" name="deliver_code" value="" required="yes" id="deliver_code" maxlength="10" title="<cf_get_lang dictionary_id='295.Sadece Personel Kartları Geçerlidir'>" style="height:50px!important;">
					</div>
				</div>
			</div>
		</cf_box_elements>
		<cf_box_footer>
			<div class="col col-12 text-right">
				<input type="button" name="buton" id="buton"style="height: 50px;width: 150px;font-size: 18px;" value="<cf_get_lang dictionary_id='35456.Giriş Yapın'>" onclick="input_control()"/>
			</div>
		</cf_box_footer>
	</cfform>
</cf_box>
<script language="javascript">
document.form_password.deliver_code.focus();
function input_control()
{
	deliver_code = document.getElementById('deliver_code').value;
	if(list_find('<cfoutput>#deliver_code_list#</cfoutput>',deliver_code,','))
		document.getElementById("form_password").submit();
	else
	{
		alert('<cf_get_lang dictionary_id='296.Kartınız Yetkili Değil'> - <cf_get_lang dictionary_id='297.İnsan Kaynaklarına Başvurunuz'>!');
		document.form_password.deliver_code.value = '';
		document.form_password.deliver_code.focus();
		return false;
	}
}
</script>
