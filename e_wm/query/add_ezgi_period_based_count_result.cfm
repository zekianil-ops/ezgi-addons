<!---
    File: add_ezgi_period_based_count_result.cfm
    Folder: Add_Ons\ezgi\e_wm\query
    Author: Ezgi Yazılım
    Date: 01/03/2025
    Description: Sayım Belgesi Oluştur
---> 
<cfset attributes.TXT_DEPARTMENT_IN = attributes.depo>

<cfquery name="get_sayim" datasource="#dsn3#">
	SELECT 
    	E.STOCK_ID, 
        E.SPECT_ID, 
        S.IS_PROTOTYPE,
        S.PRODUCT_NAME,
        S.BARCOD,
        COUNT(*) AS SAYI
	FROM     
    	EZGI_WM_COUNT_SERIAL_ROW AS E WITH (NOLOCK) INNER JOIN
        STOCKS AS S WITH (NOLOCK) ON E.STOCK_ID = S.STOCK_ID
	WHERE  
    	E.WM_COUNT_ID = #attributes.count_id# AND 
        ISNULL(E.IS_CONTROL, 0) = 1 AND 
        ISNULL(E.IS_LOST_ITEM, 0) = 0 AND
        E.DEPO = '#attributes.depo#'
	GROUP BY 
    	E.STOCK_ID, 
        E.SPECT_ID, 
        S.IS_PROTOTYPE,
        S.PRODUCT_NAME,
        S.BARCOD
</cfquery>
<cfif get_sayim.recordcount>
	<cfset attributes.ROW_COUNT = get_sayim.recordcount>
	<cfoutput query="get_sayim">
		<cfset 'attributes.STOCKID#get_sayim.currentrow#' = get_sayim.STOCK_ID>
        <cfset 'attributes.AMOUNT#get_sayim.currentrow#' = get_sayim.SAYI>
        <cfset 'attributes.BARCOD#get_sayim.currentrow#' = get_sayim.BARCOD>
        <cfset 'attributes.STOCKCODE#get_sayim.currentrow#' = get_sayim.PRODUCT_NAME>
        <cfset 'attributes.ROW_KONTROL#get_sayim.currentrow#' = 1>
        <cfif get_sayim.IS_PROTOTYPE eq 1>
			<cfset 'attributes.SPECTMAINID#get_sayim.currentrow#' = get_sayim.SPECT_ID>
        <cfelse>
        	<cfset 'attributes.SPECTMAINID#get_sayim.currentrow#' =''>
        </cfif>
	</cfoutput>
    
    <cfset attributes.seperator_type = 59><!--- Noktali Virgul Chr --->
	<cfset upload_folder = "#upload_folder#store#dir_seperator#">
    <cfscript>
        CRLF=chr(13)&chr(10);
        barcode_list = ArrayNew(1);
        for(row_i=1;row_i lte attributes.row_count;row_i=row_i+1)
        {
            if(evaluate('attributes.row_kontrol#row_i#') eq 1)
                ArrayAppend(barcode_list,"#evaluate('attributes.barcod#row_i#')#;#evaluate('attributes.amount#row_i#')#;#evaluate('attributes.spectmainid#row_i#')#");
        }
    </cfscript>
    <cfset file_name = "#createUUID()#.txt">
    <cffile action="write" output="#ArrayToList(barcode_list,CRLF)#" file="#upload_folder##file_name#" addnewline="yes" charset="iso-8859-9">
    <cfdirectory directory="#upload_folder#" name="folder_info" sort="datelastmodified" filter="#file_name#">
    <cfset file_name = folder_info.name>
    <cfset file_size = folder_info.size>
    <cfset form.store = attributes.txt_department_in>
    <cfset attributes.department_id = ListGetAt(attributes.txt_department_in,1,'-')>
    <cfset attributes.location_id = ListGetAt(attributes.txt_department_in,2,'-')>
    <cfset attributes.process_date = Dateformat(now(),dateformat_style)>
    <cfset attributes.stock_identity_type = 1><!--- Tip Barkod --->
    <cfset attributes.ADD_FILE_FORMAT_1 = 'SPECT_MAIN_ID'>
    <cfset attributes.ADD_FILE_FORMAT_2 = ''>
    <cfset attributes.ADD_FILE_FORMAT_3 = ''>
    <cfinclude template="import_stock_count_display.cfm">
    <cfquery name="update_count_operation" datasource="#dsn2#">
    	UPDATE 
        	FILE_IMPORTS
		SET          
        	SOURCE_SYSTEM = #attributes.count_id#
		WHERE  
        	I_ID =
               		(
                    	SELECT TOP (1) 
                        	I_ID
                       	FROM      
                        	FILE_IMPORTS AS FILE_IMPORTS_1
                       	ORDER BY 
                        	I_ID DESC
                 	)
    </cfquery>
    <script type="text/javascript">
        <cfif not isdefined('error_flag')>
            alert('<cf_get_lang dictionary_id='387.Sayım dosyanız başarıyla oluşturulmuştur!'>');
        </cfif>
        window.location.href = '<cfoutput>#request.self#?fuseaction=stock.list_ezgi_perioad_based_count_operations&event=upd&count_id=#attributes.count_id#</cfoutput>';
    </script>
<cfelse>
	<script type="text/javascript">
     	alert('Sayım Belgesi Oluşturacak Kayıt Bulunamadı!!!');
        window.location.href = '<cfoutput>#request.self#?fuseaction=stock.list_ezgi_perioad_based_count_operations&event=upd&count_id=#attributes.count_id#</cfoutput>';
    </script>
</cfif>