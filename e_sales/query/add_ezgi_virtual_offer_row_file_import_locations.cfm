<!---
    File: add_ezgi_virtual_offer_row_file_import_locations.cfm
    Folder: Add_Ons\ezgi\e_sales\query
    Author: Ezgi Yazılım
    Date: 13/06/2024
    Description:
--->

<cfset upload_folder = "#upload_folder#temp#dir_seperator#">
<cftry>
 	<cffile action = "upload" 
   		fileField = "uploaded_file" 
      	destination = "#upload_folder#"
     	nameConflict = "MakeUnique"  
    	mode="777">
 	<cfset file_name = "#createUUID()#.#cffile.serverfileext#">	
	<cffile action="rename" source="#upload_folder##cffile.serverfile#" destination="#upload_folder##file_name#">	
 	<cfset file_size = cffile.filesize>
   	<cfcatch type="Any">
     	<cfoutput>#cfcatch.detail#</cfoutput>
     	<cfabort>
	</cfcatch>  
</cftry>

<cftry>
 	<cfspreadsheet action="read" src="#upload_folder##file_name#" query="excel_file_ham" sheetname ="IMPORT" headerrow ="1" rows="2-10000">
 	<cfcatch>
    	<script type="text/javascript">
       		alert("<cfoutput>#getLang('ehesap',1112)#</cfoutput>.");
          	history.back();
     	</script>
     	<cfabort>
  	</cfcatch>
</cftry>
<cfquery name="get_virtula_offer" datasource="#dsn3#">
	SELECT 
        QUANTITY
  	FROM 
    	EZGI_VIRTUAL_OFFER_ROW
   	WHERE 
    	EZGI_ID = #attributes.ezgi_id#
</cfquery>
<cfif excel_file_ham.recordcount NEQ get_virtula_offer.QUANTITY>
    <script type="text/javascript">
        alert("Excel dosyasındaki satır sayısı veritabanındaki miktarla eşleşmiyor!");
        window.history.go(-1);
    </script>
    <cfabort>
</cfif>
<cfquery name="delete_virtual_offer_row_floor" datasource="#dsn3#">
    DELETE FROM EZGI_VIRTUAL_OFFER_ROW_FLOOR
    WHERE EZGI_ID = #attributes.EZGI_ID#
</cfquery>
<cfif excel_file_ham.recordcount>
	<cfloop query="excel_file_ham">
		<!---Poz Zorunlu--->
    	<cfif not len(excel_file_ham.Tip)>
        	<script type="text/javascript">
				alert("#currentrow#. Satırda Poz Bilgisi Belirtilmemiş!");
				window.history.go(-1);
			</script>
            <cfabort>
        </cfif>
        <cfquery name="add_virtual_offer_row_floor" datasource="#dsn3#">
        	INSERT INTO 
            	EZGI_VIRTUAL_OFFER_ROW_FLOOR
                (
                	EZGI_ID, 
                    TIP, 
                    KONUM, 
                    DAIRE, 
                    MEKAN
              	)
			VALUES 
            	(
                	#attributes.EZGI_ID#,
                    '#excel_file_ham.Tip#',
                    <cfif len(excel_file_ham.Konum)>'#excel_file_ham.Konum#'<cfelse>NULL</cfif>,
                    <cfif len(excel_file_ham.Daire)>'#excel_file_ham.Daire#'<cfelse>NULL</cfif>,
                    <cfif len(excel_file_ham.Mekan)>'#excel_file_ham.Mekan#'<cfelse>NULL</cfif>
               	)
        </cfquery>
	</cfloop>
</cfif>
<script type="text/javascript">
	alert("Aktarım Başarıyla Tamamlanmıştır.!");
</script>    
<cflocation url="#request.self#?fuseaction=prod.popup_upd_ezgi_virtual_offer_row_floor_info&ezgi_id=#attributes.ezgi_id#" addtoken="No">   