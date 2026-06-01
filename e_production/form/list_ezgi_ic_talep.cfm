<!---
    File: list_ezgi_ic_talep.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---E-Furniture İç Talep Window --->
<cfparam name="attributes.style" default="1">
<cfquery name="GET_IC_TALEP" datasource="#dsn3#">
	SELECT    	VPR.ACTION_ID, 
    			VPR.LOT_NO, 
                VPR.P_ORDER_ID, 
                VPR.MASTER_PLAN_ID, 
                I.INTERNAL_NUMBER, 
                I.IS_ACTIVE, 
                I.SUBJECT, 
                I.PRIORITY,
                I.TARGET_DATE
	FROM      	EZGI_MASTER_PLAN_RELATIONS AS VPR INNER JOIN
               	INTERNALDEMAND AS I ON VPR.ACTION_ID = I.INTERNAL_ID
	WHERE     	(VPR.PROCESS_ID = 2) AND 
    			(VPR.MASTER_PLAN_ID = #upd_id#)
</cfquery>
<table cellspacing="1" cellpadding="2" width="98%" border="0" class="color-border">
	<tr class="color-header" height="22">
	<cfoutput>
		<td class="form-title" style="cursor:hand;" width="100%" onClick="gizle_goster(related_internaldemand);"><cf_get_lang dictionary_id='32937.İlişkili İç Talepler'></td>
		<td nowrap>	<img src="/images/plus_square.gif" border="0" alt="<cf_get_lang dictionary_id='569.İç Talep Ekle'>"></td>
	</cfoutput>
	</tr>
	<tr id="related_internaldemand" <cfif not attributes.style> style="display=none;"</cfif> class="color-row">
		<td colspan="2">
			<table width="100%" >
				<cfoutput query="GET_IC_TALEP">
					<tr height="20" class="color-row">
						<td width="30%">
                    	<a href="#request.self#?fuseaction=purchase.upd_internaldemand&id=#ACTION_ID#" class="tableyazi">#Dateformat(TARGET_DATE,"DD/MM/YYYY")#</a></td>
                        <td width="25%"><a href="#request.self#?fuseaction=purchase.upd_internaldemand&id=#ACTION_ID#" class="tableyazi">#INTERNAL_NUMBER#</a></td>
                        <td width="35%"><a href="#request.self#?fuseaction=purchase.upd_internaldemand&id=#ACTION_ID#" class="tableyazi">#left(SUBJECT,30)#</a></td>
					</tr>
				</cfoutput>
				<cfif not GET_IC_TALEP.recordcount>
					<tr class="color-row">
						<td colspan="2" height="20"><cf_get_lang dictionary_id='479.İlişkili İç Talep Bulunamadı.'>!</td>
					</tr>		
				</cfif>
			</table>
		</td>
	</tr>
</table>
