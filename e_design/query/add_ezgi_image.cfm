  <!---
    File: add_ezgi_image.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->   
    
    <cfif attributes.image_type eq "brand"><!--- Parça İse --->
        <cfset table = "EZGI_DESIGN_PIECE_IMAGES">
        <cfset identity_column = "DESIGN_PIECE_ROW_ID">
        <cfquery name="get_ortak_parca" datasource="#dsn3#">
        	SELECT DISTINCT
            	PIECE_ROW_ID
			FROM     
            	EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
			WHERE  
            	PIECE_RELATED_ID =
                      			(
                                	SELECT 
                                    	DISTINCT ED.PIECE_RELATED_ID
                       				FROM      
                                    	EZGI_DESIGN_PIECE_ROWS AS ED INNER JOIN
                                        STOCKS S ON S.STOCK_ID = ED.PIECE_RELATED_ID 
                       				WHERE   
                                    	ISNULL(S.IS_PROTOTYPE,0) = 0 AND
                                    	NOT (ED.PIECE_RELATED_ID IS NULL) AND 
                                        ED.PIECE_ROW_ID = #attributes.image_action_id#
                              	) AND 
                	PIECE_TYPE <> 4
        </cfquery>
        <cfif get_ortak_parca.recordcount gt 1>
        	<cfset image_id_list = ValueList(get_ortak_parca.PIECE_ROW_ID)>
        </cfif>
        <cfset ezgidsn = #dsn3#>
    <cfelseif attributes.image_type eq "product"><!--- Modül İse--->
        <cfset table = "EZGI_DESIGN_MAIN_IMAGES">
        <cfset identity_column = "DESIGN_MAIN_ROW_ID">
        <cfset ezgidsn = #dsn3#>
  	<cfelseif attributes.image_type eq "package"><!--- Paket İse --->
        <cfset table = "EZGI_DESIGN_PACKAGE_IMAGES">
        <cfset identity_column = "DESIGN_PACKAGE_ROW_ID">
        <cfset ezgidsn = #dsn3#>
   	<cfelseif attributes.image_type eq "lift_sub"><!--- Amortisör İse --->
        <cfset table = "EZGI_LIFT_IMAGES">
        <cfset identity_column = "DESIGN_LIFT_TYPE_ID">
        <cfset ezgidsn = #dsn#>
  	<cfelseif attributes.image_type eq "lift_offer"><!--- Amortisör Teklif İse --->
        <cfset table = "EZGI_LIFT_IMAGES">
        <cfset identity_column = "ORDER_ROW_ID">
        <cfset ezgidsn = #dsn#>
  	<cfelseif attributes.type eq "connect_row"><!--- Sanal Teklif Satırı SSH İse --->
		<cfset table = "EZGI_CONNECT_ROW_IMAGES">
        <cfset identity_column = "CONNECT_ROW_ID">
        <cfset ezgidsn = #dsn3#>
    </cfif>
    <cfif isDefined("attributes.image_file")  and len(attributes.image_file) and isDefined("attributes.image_url_link")  and len(attributes.image_url_link)>
        <cftry>
            <cfset file_name = createUUID()>
            <cffile action="UPLOAD" 
                    destination="#upload_folder#product#dir_seperator#" 
                    filefield="image_file"  
                    nameconflict="MAKEUNIQUE"> <!---accept="image/*"---> 
            <cffile action="rename" source="#upload_folder#product#dir_seperator##cffile.serverfile#" destination="#upload_folder#product#dir_seperator##file_name#.#cffile.serverfileext#">
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
            <cffile action="delete" file="#upload_folder#product#dir_seperator##file_name#.#cffile.serverfileext#">
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
        
        <cfquery name="ADD_IMAGE" datasource="#ezgidsn#">
            INSERT INTO 
                #table#
                (
                    IS_INTERNET,
                    #identity_column#,
                    PATH,
                    PATH_SERVER_ID,
                    PRD_IMG_NAME,
                    IMAGE_SIZE,
                    <cfif attributes.image_type eq "product">
                        STOCK_ID,
                    </cfif>
                    LANGUAGE_ID,
                    UPDATE_DATE,
                    UPDATE_EMP,
                    UPDATE_IP,
                    IS_EXTERNAL_LINK,
                    VIDEO_LINK,
                    VIDEO_PATH,
                    DETAIL
                    <cfif attributes.image_type eq "lift_offer">
                     	, EZGI_LIFT_IMAGE_DEFAULT_ID
                    </cfif>
                )
                VALUES
                (
                    <cfif isdefined("attributes.is_internet")>1,<cfelse>0,</cfif>
                    #attributes.image_action_id#,
                    '#file_name#.#cffile.serverfileext#',
                    '#fusebox.server_machine#',
                    '#FORM.IMAGE_NAME#',
                    <cfif isdefined("attributes.size") and len(attributes.size)>#attributes.size#,<cfelse>NULL,</cfif>
                    <cfif attributes.image_type eq "product">
                        <cfif isdefined("attributes.stock_id") and len(attributes.stock_id)>',#attributes.stock_id#,'<cfelse>NULL</cfif>,
                    </cfif>
                    '#attributes.language_id#',
                    #NOW()#,
                    <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>
                    #session.ep.userid#,
                    <cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>
                    #session.pp.userid# ,
                    </cfif>
                    '#cgi.REMOTE_ADDR#',
                    1,
                    0,
                    '#attributes.image_url_link#',
                    '#FORM.DETAIL#'
                    <cfif attributes.image_type eq "lift_offer">
                       ,#attributes.lift_default_id#
                    </cfif>
                )
        </cfquery>
        
        <cfset session.resim = 4>
        <cfif not isDefined("rd")>
            <script type="text/javascript">
                wrk_opener_reload();
                window.close();
            </script>
            <cfabort>
        </cfif>
    <cfelseif isDefined("attributes.image_url_link")  and len(attributes.image_url_link)>
        <cfquery name="ADD_IMAGE" datasource="#ezgidsn#">
            INSERT INTO 
                #table#
                (
                    IS_INTERNET,
                    #identity_column#,
                    VIDEO_PATH,
                    PRD_IMG_NAME,
                    IMAGE_SIZE,
                    STOCK_ID,
                    UPDATE_DATE,
                    UPDATE_EMP,
                    UPDATE_IP,
                    PATH_SERVER_ID,
                    IS_EXTERNAL_LINK,
                    VIDEO_LINK,
                    DETAIL
                    <cfif attributes.image_type eq "lift_offer">
                     	, EZGI_LIFT_IMAGE_DEFAULT_ID
                    </cfif>
                )
                VALUES
                (
                    <cfif isdefined("attributes.is_internet")>1,<cfelse>0,</cfif>
                    #attributes.image_action_id#,
                    '#attributes.image_url_link#',
                    '#form.IMAGE_NAME#',
                    <cfif isdefined("attributes.size") and len(attributes.size)>#attributes.size#,<cfelse>NULL,</cfif>
                    <cfif isdefined("attributes.stock_id") and len(attributes.stock_id)>',#attributes.stock_id#,'<cfelse>NULL</cfif>,
                    #now()#,
                    <cfif listfindnocase(employee_url,'#cgi.http_host#',';')>
                        #session.ep.userid#,
                    <cfelseif listfindnocase(partner_url,'#cgi.http_host#',';')>
                        #session.pp.userid# ,
                    </cfif>
                    '#cgi.remote_addr#',
                    NULL,
                    1,
                    <cfif isdefined('attributes.video_link') and len(attributes.video_link)>1<cfelse>0</cfif>,
                    '#FORM.DETAIL#'
                    <cfif attributes.image_type eq "lift_offer">
                       ,#attributes.lift_default_id#
                    </cfif>
                )
        </cfquery>
        <script type="text/javascript">
            wrk_opener_reload();
            window.close();
        </script>
        <cfabort>
    <cfelse>
        <cftry>
            <cfset file_name = createUUID()>
            <cffile action="UPLOAD" 
                    destination="#upload_folder#product#dir_seperator#" 
                    filefield="image_file"  
                    nameconflict="MAKEUNIQUE"> <!--- <!---accept="image/*"---> --->
                
            <cffile action="rename" source="#upload_folder#product#dir_seperator##cffile.serverfile#" destination="#upload_folder#product#dir_seperator##file_name#.#cffile.serverfileext#">
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
            <cffile action="delete" file="#upload_folder#product#dir_seperator##file_name#.#cffile.serverfileext#">
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
        
        <cfif isdefined('image_id_list') and Listlen(image_id_list)>
        	<cfquery name="DEL_UNIT" datasource="#ezgidsn#">
                DELETE FROM
                    #table# 
                WHERE 
              		#identity_column# IN (#image_id_list#) 
            </cfquery>
            <cfloop list="#image_id_list#" index="i">
            	<cfquery name="ADD_IMAGE" datasource="#ezgidsn#">
                    INSERT INTO 
                        #table#
                        (
                            IS_INTERNET,
                            #identity_column#,
                            PATH,
                            PATH_SERVER_ID,
                            PRD_IMG_NAME,
                            IMAGE_SIZE,
                            <cfif attributes.image_type eq "product">
                                STOCK_ID,
                            </cfif>
                            LANGUAGE_ID,
                            UPDATE_DATE,
                            UPDATE_EMP,
                            UPDATE_IP,
                            IS_EXTERNAL_LINK,
                            VIDEO_LINK,
                            DETAIL
                            <cfif attributes.image_type eq "lift_offer">
                                , EZGI_LIFT_IMAGE_DEFAULT_ID
                            </cfif>
                        )
                        VALUES
                        (
                            <cfif isdefined("attributes.is_internet")>1,<cfelse>0,</cfif>
                            #i#,
                            '#file_name#.#cffile.serverfileext#',
                            '#fusebox.server_machine#',
                            '#FORM.IMAGE_NAME#',
                            <cfif isdefined("attributes.size") and len(attributes.size)>#attributes.size#,<cfelse>NULL,</cfif>
                            <cfif attributes.image_type eq "product">
                                <cfif isdefined("attributes.stock_id") and len(attributes.stock_id)>',#attributes.stock_id#,'<cfelse>NULL</cfif>,
                            </cfif>
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
                            <cfif attributes.image_type eq "lift_offer">
                               ,#attributes.lift_default_id#
                            </cfif>
                        )
                </cfquery>
            </cfloop>
        <cfelse>
        	<cfquery name="ADD_IMAGE" datasource="#ezgidsn#">
                INSERT INTO 
                    #table#
                    (
                        IS_INTERNET,
                        #identity_column#,
                        PATH,
                        PATH_SERVER_ID,
                        PRD_IMG_NAME,
                        IMAGE_SIZE,
                        <cfif attributes.image_type eq "product">
                            STOCK_ID,
                        </cfif>
                        LANGUAGE_ID,
                        UPDATE_DATE,
                        UPDATE_EMP,
                        UPDATE_IP,
                        IS_EXTERNAL_LINK,
                        VIDEO_LINK,
                        DETAIL
                        <cfif attributes.image_type eq "lift_offer">
                            , EZGI_LIFT_IMAGE_DEFAULT_ID
                        </cfif>
                    )
                    VALUES
                    (
                        <cfif isdefined("attributes.is_internet")>1,<cfelse>0,</cfif>
                        #attributes.image_action_id#,
                        '#file_name#.#cffile.serverfileext#',
                        '#fusebox.server_machine#',
                        '#FORM.IMAGE_NAME#',
                        <cfif isdefined("attributes.size") and len(attributes.size)>#attributes.size#,<cfelse>NULL,</cfif>
                        <cfif attributes.image_type eq "product">
                            <cfif isdefined("attributes.stock_id") and len(attributes.stock_id)>',#attributes.stock_id#,'<cfelse>NULL</cfif>,
                        </cfif>
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
                        <cfif attributes.image_type eq "lift_offer">
                           ,#attributes.lift_default_id#
                        </cfif>
                    )
            </cfquery>
        </cfif>
        <cfif attributes.image_type eq "lift_offer">
        	
            <cfquery name="GET_STOCK_INFO" datasource="#ezgidsn#">
                SELECT PRODUCT_ID FROM EZGI_LIFT_ORDER_ROW WITH (NOLOCK) WHERE EZGI_ID = #attributes.image_action_id#
            </cfquery>
            <cfif LEN(attributes.lift_default_id)>
                <cfquery name="GET_LIFT_DETAIL" datasource="#ezgidsn#">
                    SELECT EZGI_LIFT_IMAGE_DETAIL FROM EZGI_LIFT_IMAGE_DEFAULT WITH (NOLOCK) WHERE EZGI_LIFT_IMAGE_DEFAULT_ID = #attributes.lift_default_id#
                </cfquery>
            <cfelse>
            	<cfset GET_LIFT_DETAIL.recordcount = 0>
            </cfif>
            <cfif GET_STOCK_INFO.recordcount and len(GET_STOCK_INFO.PRODUCT_ID)>
            	<cfquery name="ADD_IMAGE" datasource="#ezgidsn#">
                    INSERT INTO 
                        #dsn1_alias#.PRODUCT_IMAGES
                        (
                            IS_INTERNET,
                            PRODUCT_ID,
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
                            VIDEO_PATH,
                            DETAIL
                        )
                        VALUES
                        (
                            <cfif isdefined("attributes.is_internet")>1,<cfelse>0,</cfif>
                            #GET_STOCK_INFO.PRODUCT_ID#,
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
                            1,
                            0,
                            '#attributes.image_url_link#',
                            <cfif GET_LIFT_DETAIL.recordcount and len(GET_LIFT_DETAIL.EZGI_LIFT_IMAGE_DETAIL)>'#GET_LIFT_DETAIL.EZGI_LIFT_IMAGE_DETAIL#'<cfelse>NULL</cfif>
                        )
                </cfquery>
            </cfif>
        </cfif>
        <cfset session.resim = 4>
        <cfif not isDefined("rd")>
            <script type="text/javascript">
                wrk_opener_reload();
                window.close();
            </script>
            <cfabort>
        </cfif>
    </cfif>
    <cfif isDefined("rd")>

        <cfinclude template="../display/rd.cfm">
    </cfif>
