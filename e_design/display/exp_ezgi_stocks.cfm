<!---
    File: exp_ezgi_stocks.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset FileName = "Stok_Tablosu_#DateFormat(now(),'YYYYMMDD')#_#TimeFormat(DateAdd('h',session.ep.time_zone,now()),'HHMMSS')#.csv">
<cfset myFile = "#upload_folder#production/#FileName#">
<cfset readFile = "#file_web_path#production/#FileName#">
<cfquery name="GetStuff" datasource="#dsn3#">
   	SELECT        
   		S.STOCK_ID, 
    	S.PRODUCT_NAME
	FROM            
    	STOCKS AS S INNER JOIN
   		PRODUCT_CAT AS P ON S.PRODUCT_CATID = P.PRODUCT_CATID
	WHERE        
    	P.LIST_ORDER_NO = 3
	ORDER BY 
    	S.STOCK_ID
</cfquery>
<cffile action="write" file="#myFile#" output="Stok ID;Stok ADI" addnewline="Yes">
<cfloop query="GetStuff">
   <cffile action="append" file="#myFile#" output="#STOCK_ID#;#PRODUCT_NAME#" addnewline="Yes">
</cfloop>
<script type="text/javascript">
  	alert('<cfoutput>#FileName#</cfoutput> <cf_get_lang dictionary_id="240.Adlı Dosya Oluşturulmuştur.">');
</script>
<table width="100%">
<tr>
	<td height="30px">
		<a href="javascript://" onclick="windowopen('<cfoutput>#readFile#</cfoutput>','medium')" class="tableyazi"><cfoutput>#FileName#</cfoutput></a> <cf_get_lang dictionary_id="244.Dosyasını Buradan Yükleyiniz.">
	</td>
</tr>
