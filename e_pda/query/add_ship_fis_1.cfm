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

<cfif not isDefined("get_stock_amount")>
	<cfset get_stock_amount = 1>
	<cffunction name="get_stock_amount">
		<cfargument name="stock_id">
		<cfquery name="get_pro_stock" datasource="#DSN2#">
			SELECT
				SUM(SR.STOCK_IN - SR.STOCK_OUT) AS PRODUCT_STOCK
			FROM
				#dsn_alias#.DEPARTMENT D,
				#dsn3_alias#.PRODUCT P,
				#dsn3_alias#.STOCKS S,
				STOCKS_ROW SR
			WHERE
				P.PRODUCT_ID = S.PRODUCT_ID AND
				S.STOCK_ID = SR.STOCK_ID AND
				D.DEPARTMENT_ID = SR.STORE AND
				D.DEPARTMENT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.department_in#"> AND
				S.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#stock_id#">
			GROUP BY
				P.PRODUCT_ID, 
				S.STOCK_ID, 
				S.STOCK_CODE, 
				S.PROPERTY, 
				S.BARCOD, 
				D.DEPARTMENT_ID, 
				D.DEPARTMENT_HEAD
		</cfquery>
		<cfreturn get_pro_stock.product_stock>
	</cffunction>
</cfif>

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
