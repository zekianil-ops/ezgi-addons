<!---
    File: upd_ezgi_image.cfm
    Folder: Add_Ons\ezgi\e_connect\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->    

<cfset file_name = createUUID()>
<cfif isDefined("form.image_file") and len(form.image_file)>
	<cffile action="UPLOAD" 
	destination="#upload_folder#sales#dir_seperator#" 
	filefield="image_file"  
	nameconflict="MAKEUNIQUE" accept="image/*">
				
	<cffile action="rename" source="#upload_folder#sales#dir_seperator##cffile.serverfile#" destination="#upload_folder#sales#dir_seperator##file_name#.#cffile.serverfileext#">
	<cfset assetTypeName = listlast(cffile.serverfile,'.')>
	<cfset blackList = 'php,php2,php3,php4,php5,phtml,pwml,inc,asp,aspx,ascx,jsp,cfm,cfml,cfc,pl,bat,exe,com,dll,vbs,reg,cgi,htaccess,asis'>
	<cfif listfind(blackList,assetTypeName,',')>
		<script type="text/javascript">
			alert("\'php\',\'jsp\',\'asp\',\'cfm\',\'cfml\' Formatlarında Dosya Girmeyiniz!!");
			history.back();
		</script>
		<cfabort>
	</cfif>
</cfif>
<cfquery name="UPD_UNIT" datasource="#dsn3#">
 	UPDATE 
 	    EZGI_CONNECT_ROW_IMAGES
 	SET 
 	    PRD_IMG_NAME = '#FORM.IMAGE_NAME#',
 	    <cfif isDefined("form.image_file") and len(form.image_file)>
 	        PATH_SERVER_ID = '#fusebox.server_machine#',
 	        PATH = '#file_name#.#cffile.serverfileext#',
 	    </cfif>
 	    <cfif len(attributes.image_url_link)>
 	        <cfif not isDefined("form.image_file") and not len(form.image_file)> PATH_SERVER_ID = NULL,</cfif>
 	        VIDEO_PATH = '#attributes.image_url_link#',
 	    <cfelse>
 	        VIDEO_PATH = NULL,
 	    </cfif>
 	    IS_INTERNET = <cfif isdefined("attributes.is_internet")>1<cfelse>0</cfif>,
 	    DETAIL = '#form.detail#',
 	    IMAGE_SIZE = <cfif isdefined("attributes.size") and len(attributes.size)>#attributes.size#<cfelse>NULL</cfif>,
 	    LANGUAGE_ID = '#attributes.language_id#',
 	    UPDATE_DATE = #NOW()#,
 	    UPDATE_EMP = #SESSION.EP.USERID#,
 	    UPDATE_IP = '#CGI.REMOTE_ADDR#',
 	    IS_EXTERNAL_LINK = 0,
 	    VIDEO_LINK =   <cfif isdefined('attributes.video_link') and len(attributes.video_link)>1<cfelse>0</cfif>
 	WHERE 
 	    CONNECT_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.image_action_id#">
</cfquery>
        
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>
