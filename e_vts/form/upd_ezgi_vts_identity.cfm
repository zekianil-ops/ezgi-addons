<!---
    File: upd_ezgi_vts_identity.cfm
    Folder: Add_Ons\ezgi\e-vts\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_upd" datasource="#dsn3#">
	SELECT        
    	PAROLA, EMP_ID, DEFAULT_DEPARTMENT_ID, VTS_EMP_ID
	FROM            
   		EZGI_VTS_IDENTY
	WHERE        
    	VTS_EMP_ID = #attributes.id#
</cfquery>
<cfquery name="GET_DEPARTMENT" datasource="#DSN#">
	SELECT DEPARTMENT_ID, DEPARTMENT_HEAD FROM DEPARTMENT WHERE IS_PRODUCTION = 1 AND DEPARTMENT_STATUS = 1
</cfquery>
<cfquery name="GET_EMPLOYEES" datasource="#DSN#">
	SELECT        EMPLOYEE_ID, EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ADI FROM EMPLOYEES WHERE 	EMPLOYEE_STATUS = 1 ORDER BY ADI
</cfquery>
<table border="0" cellspacing="0" cellpadding="0" align="center" style="width:98%; height:35px;">
	<tr>
		<td class="headbold"><cf_get_lang dictionary_id='1138.Kullanıcı Erişim ve Yetkileri Güncelle'></td>
        <td align="right" class="headbold" style="text-align:right;"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=production.add_ezgi_vts_identity"><img src="/images/plus1.gif" border="0" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></a></td>
	</tr>
</table>
<table border="0" cellspacing="1" cellpadding="2" align="center" class="color-border" style="width:98%;">
	<tr>
		<td class="color-row" style="width:200px; vertical-align:top;">
			<cfinclude template="../display/list_ezgi_vts_identity.cfm">
		</td>
		<td class="color-row" style="vertical-align:top;">
			<cfform action="#request.self#?fuseaction=production.emptypopup_upd_ezgi_vts_identity" method="post" name="vts_identity">
            <cfinput type="hidden" name="id" value="#attributes.id#">
			<table>
                <tr>
					<td style="width:100px;"><cf_get_lang dictionary_id='57576.Çalışan'> *</td>
					<td>
                    	<select name="employee_id" id="employee_id" style="width:150px; height:20px">
                        	<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
							<cfoutput query="get_EMPLOYEES">
                               	<option  value="#EMPLOYEE_ID#" <cfif get_upd.EMP_ID eq EMPLOYEE_ID>selected</cfif>>#ADI#</option>
                            </cfoutput>
                      	</select>
					</td>
				</tr>
				<tr>
					<td style="width:100px;"><cf_get_lang dictionary_id='57572.Departman'> *</td>
					<td>
                    	<select name="department_id" id="department_id" style="width:150px; height:20px">
                        	<option value=""><cf_get_lang dictionary_id='58836.Lütfen Departman Seçiniz'></option>
							<cfoutput query="GET_DEPARTMENT">
                               	<option value="#DEPARTMENT_ID#" <cfif get_upd.DEFAULT_DEPARTMENT_ID eq DEPARTMENT_ID>selected</cfif>>#DEPARTMENT_HEAD#</option>
                            </cfoutput>
                      	</select>
					</td>
				</tr>
				<tr style="height:16px;">
					<td align="left"><cf_get_lang dictionary_id='57552.Şifre'> *</td>
					<td >
						<cfinput type="text" name="pass" id="pass" value="#get_upd.PAROLA#" style="width:150px; height:20px">
					</td>
				</tr>
				<tr>
					<td></td>
					<td><cf_workcube_buttons is_upd='1' delete_page_url='#request.self#?fuseaction=production.emptypopup_del_ezgi_vts_identity&id=#attributes.id#' add_function="kontrol()"></td>
				</tr>
			</table>
			<table>
				<tr>
					<td><div id="control_joining_id"></div></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</cfform>
<br/>
<script type="text/javascript">
	function kontrol()
	{
		if(document.getElementById('employee_id').value=='')
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57576.Çalışan'>")	;
			return false;
		}
		if(document.getElementById('department_id').value=='')
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57572.Departman'>")	;
			return false;
		}	
		if(document.getElementById('pass').value=='')
		{
			alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id='57552.Şifre'>")	;
			return false;
		}
	}
</script>
