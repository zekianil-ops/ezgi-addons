<cftry>
	<!---<cfset file_name = createUUID()>--->
	<cffile 
    	action = "copy"
		source = "/teknik_resim/#get_pieces.PICTURE#"
  		destination="#upload_folder#product#dir_seperator#">
    	<!---anameconflict="MAKEUNIQUE"> ccept="image/*"---> 
  	<cfcatch type="any">
    	<script type="text/javascript">
        	alert("<cf_get_lang dictionary_id='259.Lütfen İmaj Dosyası Giriniz'>!");
       		history.back();
     	</script>
 		<cfabort>
	</cfcatch>
</cftry>
<cfset assetTypeName = listlast(get_pieces.PICTURE,'.')>
<cfset blackList = 'php,php2,php3,php4,php5,phtml,pwml,inc,asp,aspx,ascx,jsp,cfm,cfml,cfc,pl,bat,exe,com,dll,vbs,reg,cgi,htaccess,asis'>
<cfif listfind(blackList,assetTypeName,',')>
	<cffile action="delete" file="#upload_folder#product#dir_seperator##get_pieces.PICTURE#">
	<script type="text/javascript">
   		alert("<cf_get_lang dictionary_id='258.\''php\'',\''jsp\'',\''asp\'',\''cfm\'',\''cfml\'' Formatlarında Dosya Girmeyiniz!!'>");
   		history.back();
 	</script>
	<cfabort>
<cfelse>
	<cfquery name="ADD_IMAGE" datasource="#dsn3#">
            INSERT INTO 
                EZGI_DESIGN_PIECE_IMAGES
                (
                    DESIGN_PIECE_ROW_ID,
                    PATH,
                    PATH_SERVER_ID,
                    PRD_IMG_NAME,
                    IMAGE_SIZE,
                    LANGUAGE_ID,
                    UPDATE_DATE,
                    UPDATE_EMP,
                    UPDATE_IP,
                    VIDEO_LINK
                )
                VALUES
                (
                    #get_max_id.MAX_ID#, 
                    '#get_pieces.PICTURE#',
                    '1',
                    '#attributes.DESIGN_NAME_PIECE_ROW#',
                    0,
                    'tr',
                    #now()#,
                    #session.ep.userid#,
                    '#cgi.REMOTE_ADDR#',
                    0
                )
	</cfquery>
</cfif>
