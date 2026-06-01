  <!---
    File: add_ezgi_image.cfm
    Folder: Add_Ons\ezgi\e_connect\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->   
<cftry>
    <cfset file_name = createUUID()>
    <cffile action="UPLOAD" 
    destination="#upload_folder#sales#dir_seperator#" 
    filefield="image_file"  
    nameconflict="MAKEUNIQUE"> <!--- <!---accept="image/*"---> --->

    <cffile action="rename" source="#upload_folder#sales#dir_seperator##cffile.serverfile#" destination="#upload_folder#sales#dir_seperator##file_name#.#cffile.serverfileext#">
    <cfcatch type="any">
		<script type="text/javascript">
            alert("<cf_get_lang dictionary_id='259.Lütfen İmaj Dosyası Giriniz'>!");
            history.back();
        </script>
        <cfabort>
    </cfcatch>
</cftry>
<cfset assetTypeName = listlast(cffile.serverfile,'.')>
<cfset blackList = 'php,php2,php3,php4,php5,phtml,pwml,inc,asp,aspx,ascx,jsp,cfm,cfml,cfc,pl,bat,exe,com,dll,vbs,reg,cgi,htaccess,asis'>
<cfif listfind(blackList,assetTypeName,',')>
    <cffile action="delete" file="#upload_folder#sales#dir_seperator##file_name#.#cffile.serverfileext#">
    <script type="text/javascript">
		alert("<cf_get_lang dictionary_id='258.\''php\'',\''jsp\'',\''asp\'',\''cfm\'',\''cfml\'' Formatlarında Dosya Girmeyiniz!!'>");
		history.back();
    </script>
    <cfabort>
</cfif>
<cfset  session.imFile = #file_name#&"."&#cffile.serverfileext#>
    
<cfif (findnocase("gif","#CFFILE.SERVERFILE#",1) neq 0) and isDefined("rd")>
    <cfscript>
		CFFILE.SERVERFILE = listgetat(CFFILE.SERVERFILE,1,".")&"."&"jpg";
		cffile.serverfileext = "jpg";
    </cfscript>
</cfif>
<cfset size = cffile.fileSize / 1024>

<cfquery name="ADD_IMAGE" datasource="#dsn3#">
	INSERT INTO 
	    EZGI_CONNECT_ROW_IMAGES
	    (
	        IS_INTERNET,
	        CONNECT_ROW_ID,
	        PATH,
	        PATH_SERVER_ID,
	        PRD_IMG_NAME,
	        IMAGE_SIZE,
	        LANGUAGE_ID,
	        UPDATE_DATE,
	        UPDATE_EMP,
	        UPDATE_IP,
	        IS_EXTERNAL_LINK,
	        VIDEO_LINK,
	        DETAIL

	    )
	    VALUES
	    (
	        <cfif isdefined("attributes.is_internet")>1,<cfelse>0,</cfif>
	        #attributes.image_action_id#,
	        '#file_name#.#cffile.serverfileext#',
	        '#fusebox.server_machine#',
	        '#FORM.IMAGE_NAME#',
	        <cfif isdefined("attributes.size") and len(attributes.size)>#attributes.size#,<cfelse>NULL,</cfif>
	        '#attributes.language_id#',
	        #NOW()#,
	        <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>
	        #session.ep.userid#,
	        <cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>
	        #session.pp.userid# ,
	        </cfif>
	        '#cgi.REMOTE_ADDR#',
	        0,
	        0,
	        '#FORM.DETAIL#'
	    )
</cfquery>
<script type="text/javascript">
 	wrk_opener_reload();
 	 window.close();
</script>

