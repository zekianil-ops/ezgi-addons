<!---
    File: add_ship_fis_1.cfm
    Folder: Add_Ons\ezgi\e-pda\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cf_date tarih = 'attributes.fis_date'>

<cfif not len(attributes.location_in)>
	<cfset attributes.location_in = "NULL">
</cfif>
<cfif not len(attributes.location_out)>
	<cfset attributes.location_out = "NULL">
</cfif>
<cf_papers paper_type="STOCK_FIS">
<cfset system_paper_no = paper_code & '-' & paper_number>
<cfset system_paper_no_add = paper_number>
<cfset attributes.FIS_NO= system_paper_no>

<cfset multi="">
<cfquery name="GET_FIS_NO" datasource="#dsn2#">
	SELECT FIS_NUMBER FROM STOCK_FIS WHERE 	FIS_NUMBER = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.FIS_NO#">
</cfquery>

<cfif attributes.rows_ eq 0 >
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='40069.Lütfen Ürün Seçiniz !'> ");
		window.location.href='<cfoutput>#cgi.referer#</cfoutput>';
		//history.back();
	</script>
	<cfabort>	
</cfif>
<cfif GET_FIS_NO.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='45202.Fiş Numaranız Kullanılmaktadır !'>");
		window.location.href='<cfoutput>#cgi.referer#</cfoutput>';
		//history.back();
	</script>
	<cfabort>
</cfif>
