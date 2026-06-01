<!---
    File: list_ezgi_vts_identity.cfm
    Folder: Add_Ons\ezgi\e-vts\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="VTS_IDENTITY" datasource="#DSN#">
	SELECT        
    	VTS.VTS_EMP_ID, 
        VTS.EMP_ID, 
        VTS.PAROLA, 
        VTS.DEFAULT_DEPARTMENT_ID, 
        (SELECT DEPARTMENT_HEAD FROM DEPARTMENT WHERE DEPARTMENT_ID = VTS.DEFAULT_DEPARTMENT_ID) as DEPARTMENT_HEAD,
        E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS ADI,
        E.EMPLOYEE_ID,
        E.EMPLOYEE_STATUS
	FROM            
    	#dsn3_alias#.EZGI_VTS_IDENTY AS VTS INNER JOIN
    	EMPLOYEES AS E ON VTS.EMP_ID = E.EMPLOYEE_ID
	ORDER BY        
    	E.EMPLOYEE_STATUS DESC,
        EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME
</cfquery>
<table cellpadding="0" cellspacing="0" border="0" style="width:400px;">
  	<tr style="height:20px;">  
    	<td class="txtbold" colspan="5">&nbsp;&nbsp;<cf_get_lang dictionary_id ='51138.Kullanıcı Erişim ve Yetkileri'></td>
  	</tr>
	<cfif VTS_IDENTITY.recordcount>
		<cfoutput query="VTS_IDENTITY">
			<tr>
				<td align="right" valign="baseline" style="text-align:right; width:20px;"><img src="/images/tree_1.gif" width="13"></td>
                <td <cfif EMPLOYEE_STATUS eq 0>style="color:red"</cfif>>#EMPLOYEE_ID#</td>
				<td <cfif EMPLOYEE_STATUS eq 0>style="color:red"</cfif>><a href="#request.self#?fuseaction=production.upd_ezgi_vts_identity&ID=#VTS_EMP_ID#" class="tableyazi">#ADI#</a></td>
                <td>#DEPARTMENT_HEAD#</td>
                <td>#PAROLA#</td>
			</tr>
  		</cfoutput>
	<cfelse>
		<tr>
			<td align="right" valign="baseline" style="text-align:right; width:20px;"><img src="/images/tree_1.gif" width="13"></td>
			<td class="tableyazi"><cf_get_lang dictionary_id='58486.Kayıt Bulunamadı'>!</td>
		</tr>
 	</cfif>
</table>
