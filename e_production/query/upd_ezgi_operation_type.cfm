<cfquery name="get_asset" datasource="#DSN3#">
	SELECT * FROM OPERATION_TYPES WHERE OPERATION_TYPE_ID=#attributes.operation_type_id#
</cfquery>
<cfquery name="GET_OPERATION_TYPE_ID" datasource="#DSN3#">
	SELECT OPERATION_TYPE FROM OPERATION_TYPES WHERE OPERATION_TYPE LIKE '#attributes.OP_NAME#' AND OPERATION_TYPE_ID <> #attributes.OPERATION_TYPE_ID#
</cfquery>
<cfif get_operation_type_id.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang no ='621.İşlem Tipi Mevcut'> !");
		history.back();
	</script>
	<cfabort>
<cfelse>
	<cfif isdefined("attributes.upd_asset")>
		<cfif attributes.upd_asset eq 1>
			<cfset upload_folder = "#upload_folder#operationtype#dir_seperator#">
			<cfif len(get_asset.file_name)>
				<cf_del_server_file output_file="operationtype/#get_asset.file_name#" output_server="#get_asset.file_server_id#">
			</cfif>
			<cftry>
				<cfset file_name = createUUID()>
				<cffile action = "upload" fileField = "asset" destination = "#upload_folder#" nameConflict = "MakeUnique" mode="777">
				<cffile action="rename" source="#upload_folder##cffile.serverfile#" destination="#upload_folder##file_name#.#cffile.serverfileext#">
				<cfset assetTypeName = listlast(cffile.serverfile,'.')>
				<cfset blackList = 'php,php2,php3,php4,php5,phtml,pwml,inc,asp,aspx,ascx,jsp,cfm,cfml,cfc,pl,bat,exe,com,dll,vbs,reg,cgi,htaccess,asis'>
				<cfif listfind(blackList,assetTypeName,',')>
					<cffile action="delete" file="#upload_folder##file_name#.#cffile.serverfileext#">
					<script type="text/javascript">
						alert("\'php\',\'jsp\',\'asp\',\'cfm\',\'cfml\' Formatlarında Dosya Girmeyiniz!!");
						history.back();
					</script>
					<cfabort>
				</cfif>	
				<cfcatch type="Any">
					<script type="text/javascript">
						alert("<cf_get_lang_main no ='43.Dosyanýz upload edilemedi ! Dosyanýzý kontrol ediniz'>!");
						history.back();
					</script>
				</cfcatch>  
			</cftry>
		</cfif>
	<cfelse>
		<cfif len(attributes.asset)>
			<cfset upload_folder = "#upload_folder#operationtype#dir_seperator#">
			<cftry>
				<cfset file_name = createUUID()>
				<cffile action = "upload" fileField = "asset" destination = "#upload_folder#" nameConflict = "MakeUnique" mode="777">
				<cffile action="rename" source="#upload_folder##cffile.serverfile#" destination="#upload_folder##file_name#.#cffile.serverfileext#">
				<cfset assetTypeName = listlast(cffile.serverfile,'.')>
				<cfset blackList = 'php,php2,php3,php4,php5,phtml,pwml,inc,asp,aspx,ascx,jsp,cfm,cfml,cfc,pl,bat,exe,com,dll,vbs,reg,cgi,htaccess,asis'>
				<cfif listfind(blackList,assetTypeName,',')>
					<cffile action="delete" file="#upload_folder##file_name#.#cffile.serverfileext#">
					<script type="text/javascript">
						alert("\'php\',\'jsp\',\'asp\',\'cfm\',\'cfml\' Formatlarında Dosya Girmeyiniz!!");
						history.back();
					</script>
					<cfabort>
				</cfif>	
				<cfcatch type="Any">
					<script type="text/javascript">
						alert("<cf_get_lang_main no ='43.Dosyanız upload edilemedi ! Dosyanızı kontrol ediniz'>!");
						history.back();
					</script>
				</cfcatch>  
			</cftry>	
		</cfif>
	</cfif>
	<cfquery name="UPD_OP_TYPE" datasource="#DSN3#">
		UPDATE 
			OPERATION_TYPES
		SET
			<cfif isdefined("GET_MAX_STCK.MAX_STCK")>RELATION_STOCK_ID = #GET_MAX_STCK.MAX_STCK#,</cfif>
			OPERATION_TYPE = '#attributes.OP_NAME#',
			O_MINUTE = <cfif len(attributes.MINUTES)>#attributes.MINUTES#<cfelse>NULL</cfif>,
			COMMENT = '#left(attributes.COMMENT,100)#',
			COMMENT2 =<cfif len(attributes.COMMENT_2)>'#left(attributes.COMMENT_2,100)#'<cfelse>NULL</cfif> ,
			<cfif (isdefined("attributes.asset") and len(attributes.asset)) or (isdefined("attributes.upd_asset") and attributes.upd_asset eq 1)>
				FILE_NAME = '#file_name#.#cffile.serverfileext#',
				FILE_SERVER_ID = #fusebox.server_machine#,
			</cfif>
			MONEY = '#attributes.MONEY#',
			RECORD_DATE = #NOW()#,	
			RECORD_EMP = #SESSION.EP.USERID#,
			OPERATION_COST = '#OPERATION_COST#',
            OPERATION_CODE = <cfif len(attributes.operation_code)>'#attributes.operation_code#'<cfelse>NULL</cfif>,
			OPERATION_STATUS = <cfif isdefined("attributes.status")>1<cfelse>0</cfif>,
            EZGI_H_SURE = <cfif len(attributes.ezgi_h_sure)>#attributes.ezgi_h_sure#<cfelse>NULL</cfif>,
            EZGI_FORMUL = <cfif len(attributes.ezgi_formul)>'#attributes.ezgi_formul#'<cfelse>NULL</cfif>,
            IS_VIRTUAL = <cfif isdefined("attributes.is_virtual")>1<cfelse>0</cfif>
		WHERE 
			OPERATION_TYPE_ID = #attributes.OPERATION_TYPE_ID#
	</cfquery>
	<script type="text/javascript">
		window.location.href = '<cfoutput>#request.self#</cfoutput>?fuseaction=prod.list_operationtype&event=upd&operation_type_id=<cfoutput>#attributes.operation_type_id#</cfoutput>';
	</script>
</cfif> 
