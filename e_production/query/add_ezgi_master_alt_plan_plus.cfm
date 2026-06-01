<!---
    File: add_ezgi_master_alt_plan_plus.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfif len(PLUS_DATE)>
	<CF_DATE TARIH="PLUS_DATE">
</cfif>
<cfquery name="ADD_OFFER_PLUS" datasource="#dsn3#">
	INSERT INTO
		EZGI_MASTER_ALT_PLAN_PLUS
		(
			SUBJECT,
			MASTER_ALT_PLAN_ID,
			<cfif COMMETHOD_ID neq 0>COMMETHOD_ID,</cfif>
			PLUS_CONTENT,
			<cfif len(PLUS_DATE)>PLUS_DATE,</cfif>
			<cfif len(EMPLOYEE_ID)>EMPLOYEE_ID,</cfif>
			RECORD_DATE,
			RECORD_EMP,
			RECORD_IP ,
			MAIL_SENDER,
            NOT_ID
		)
	VALUES
		(
			'#attributes.OPP_HEAD#',
			#MASTER_ALT_PLAN_ID#,
			<cfif COMMETHOD_ID neq 0>#COMMETHOD_ID#,</cfif>
			'#PLUS_CONTENT#',
			<cfif len(PLUS_DATE)>#PLUS_DATE#,</cfif>
			<cfif len(EMPLOYEE_ID)>#EMPLOYEE_ID#,</cfif>
			#now()#,
			#SESSION.EP.USERID#,
			'#CGI.REMOTE_ADDR#',
			<cfif isDefined("attributes.email") and (attributes.email eq "true")>'#attributes.employee_names#'<cfelse>''</cfif>,
            <cfif isDefined("attributes.not_id")>'#attributes.not_id#'<cfelse>0</cfif>
		)
</cfquery>

<cfif isDefined("attributes.email") and (attributes.email eq "true")>
	<cfquery name="GET_MAILFROM" datasource="#dsn#">
		SELECT
			<cfif listfindnocase(employee_url,'#cgi.http_host#',';')>EMPLOYEE_ID,EMPLOYEE_NAME NAME_,EMPLOYEE_SURNAME SURNAME_,EMPLOYEE_EMAIL EMAIL_<cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>PARTNER_ID,COMPANY_PARTNER_NAME NAME_,COMPANY_PARTNER_SURNAME SURNAME_,COMPANY_PARTNER_EMAIL EMAIL_</cfif>
		FROM		
			<cfif listfindnocase(employee_url,'#cgi.http_host#',';')>EMPLOYEE_POSITIONS<cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>COMPANY_PARTNER</cfif>		
		WHERE
			<cfif listfindnocase(employee_url,'#cgi.http_host#',';')>EMPLOYEE_ID=#session.ep.USERID#
			<cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>PARTNER_ID=#session.pp.USERID#</cfif>
			 
	</cfquery>
	<cfif GET_MAILFROM.RECORDCOUNT>
		<cfset sender = "#GET_MAILFROM.NAME_# #GET_MAILFROM.SURNAME_#<#GET_MAILFROM.EMAIL_#>">
	</cfif>

	<cftry>	
	  <cfmail  
		  from = "#sender#"
		  to = "#attributes.employee_names#"
		  subject = "#attributes.opp_head#" type="HTML">
			  
			<style type="text/css">
				.color-header{background-color: ##a7caed;}
				.color-border	{background-color:##6699cc;}
				.color-row{	background-color: ##f1f0ff;}
				.label {font-size:11px;font-family:Geneva, tahoma, arial,  Helvetica, sans-serif;color : ##333333;padding-left: 4px;}
			</style>		  
			  
			#attributes.plus_content#
		 
	  </cfmail>
	  <cfsavecontent variable="css">
		<style type="text/css">
			.color-header{background-color: ##a7caed;}
			.color-border	{background-color:##6699cc;}
			.color-row{	background-color: ##f1f0ff;}
			.label {font-size:11px;font-family:Geneva, tahoma, arial,  Helvetica, sans-serif;color : ##333333;padding-left: 4px;}
		</style>
	  </cfsavecontent>	 
      <cfset attributes.from = sender> 
	  <cfset attributes.body="#css##attributes.plus_content#">
	  <cfset attributes.to_list="#attributes.employee_names#">
	  <cfset attributes.type=0>
	  <cfset attributes.module="prod">
	  <cfset attributes.subject="#attributes.opp_head#">
	  <cfinclude template="../../../objects/query/add_mail.cfm">
		<style type="text/css">
			.color-header{background-color: ##a7caed;}
			.color-border	{background-color:##6699cc;}
			.color-row{	background-color: ##f1f0ff;}
			.headbold {  font-family:  Geneva, Verdana, Arial, sans-serif; font-size: 14px; font-weight: bold; padding-right: 2px; padding-left: 2px}
		</style>	  	  	   
		<table height="100%" width="100%" cellspacing="0" cellpadding="0">
			<tr class="color-border">
				<td valign="top"> 
					<table height="100%" width="100%" cellspacing="1" cellpadding="2">
						<tr class="color-list">
							<td height="35" class="headbold">&nbsp;&nbsp;<cf_get_lang dictionary_id='57512.Workcube E-Mail'></td>
						</tr>
						<tr class="color-row">
							<td align="center" class="headbold"><cf_get_lang dictionary_id='51080.Mail Başarıyla Gönderildi'></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	<cfcatch type="any">
	<style type="text/css">
		.color-header{background-color: ##a7caed;}
		.color-border	{background-color:##6699cc;}
		.color-row{	background-color: ##f1f0ff;}
		.headbold {  font-family:  Geneva, Verdana, Arial, sans-serif; font-size: 14px; font-weight: bold; padding-right: 2px; padding-left: 2px}
	</style>	
	<table height="100%" width="100%" cellspacing="0" cellpadding="0">
		<tr class="color-border">
			<td valign="top"> 
				<table height="100%" width="100%" cellspacing="1" cellpadding="2">
					<tr class="color-list">
						<td height="35" class="headbold">&nbsp;&nbsp;<cf_get_lang dictionary_id='57512.Workcube E-Mail'></td>
					</tr>
					<tr class="color-row">
						<td align="center" class="headbold">
						<cf_get_lang dictionary_id='40826.Teklif Kaydedildi Fakat Mail Göndermede Bir Hata Oldu Lütfen Verileri Kontrol Edip Sonra Tekrar Deneyiniz'></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	</cfcatch>
	</cftry>
	<script type="text/javascript">
		wrk_opener_reload();
		function waitfor(){
		  window.close();
		}
		setTimeout("waitfor()",5000); 		
	</script>
<cfelse>
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
</cfif>

