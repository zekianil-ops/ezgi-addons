<!---
    File: add_ezgi_product_tree_creative_package_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 
<cfquery name="GET_DEFAULT_PACKING" datasource="#dsn3#">
	SELECT        
    	OTT.OPERATION_TYPE_ID
	FROM           
    	OPERATION_TYPES AS OTT WITH (NOLOCK) INNER JOIN
     	EZGI_DESIGN_DEFAULTS AS EDD WITH (NOLOCK) ON OTT.OPERATION_TYPE_ID = EDD.DEFAULT_PACKAGE_OPERATION_TYPE_ID
</cfquery>
<cfif not GET_DEFAULT_PACKING.recordcount>
	<script type="text/javascript">
		alert(<cf_get_lang dictionary_id='1171.Genel Default Tanımlarda Paketleme Operasyonu Tanımlı Değil. Düzenleyip Tekrar Deneyin'>);
		
		window.close()
	</script>
    <cfabort>
</cfif>
<cfquery name="get_defaults" datasource="#dsn3#">
 	SELECT * FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfquery name="get_design_package_row" datasource="#dsn3#">
  	SELECT TOP(1) * FROM EZGI_DESIGN_PACKAGE WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id# ORDER BY PACKAGE_NUMBER desc
</cfquery>
<cfquery name="get_design_main_row" datasource="#dsn3#">
  	SELECT 	*  FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
</cfquery>
<cfif get_design_package_row.recordcount>
 	<cfset package_number = get_design_package_row.PACKAGE_NUMBER + 1>
<cfelse>
 	<cfset package_number = 1>
</cfif>
<cftransaction>
    <cfif isdefined('is_private') and package_number gt 0> <!---Özel Tasarıma Yeni Paket Eklendiğinde Default Paket Örnek Alınıyor--->
    	<cfif len(get_defaults.PROTOTIP_PACKAGE_ID)>
        	<cfquery name="package_defaults" datasource="#dsn3#">
                SELECT        
                    EDPP.PACKAGE_ROW_ID, 
                    S.STOCK_ID, 
                    EDPP.PACKAGE_NUMBER, 
                    EDPP.PACKAGE_NAME
                FROM            
                    EZGI_DESIGN_PACKAGE_ROW AS EDPP WITH (NOLOCK) LEFT OUTER JOIN
                    STOCKS AS S WITH (NOLOCK) ON EDPP.PACKAGE_RELATED_ID = S.STOCK_ID
                WHERE        
                    EDPP.DESIGN_MAIN_ROW_ID = #get_defaults.PROTOTIP_PACKAGE_ID#
            </cfquery>
       		<cfif package_defaults.recordcount>
            	<cfquery name="get_related_id" dbtype="query">
                	SELECT * FROM package_defaults WHERE PACKAGE_NUMBER = #package_number#
                </cfquery>
                <cfif not len(get_related_id.STOCK_ID)>
                	<script type="text/javascript">
						alert("<cfoutput>#package_number#</cfoutput> <cf_get_lang dictionary_id='49280.Nolu'> <cf_get_lang dictionary_id='57.İlişkili Master Paket'> - <cf_get_lang dictionary_id='58486.Kayıt Bulunamadı'>!");
						window.close()
					</script>
					<cfabort>
                </cfif>
            <cfelse>
            	<script type="text/javascript">
					alert("<cfoutput>#package_number#</cfoutput> <cf_get_lang dictionary_id='49280.Nolu'> <cf_get_lang dictionary_id='57.İlişkili Master Paket'> - <cf_get_lang dictionary_id='172.Ürün Transferi Eksik'>!");
					window.close()
				</script>
				<cfabort>
        	</cfif>
        <cfelse>
			<script type="text/javascript">
                alert("<cf_get_lang dictionary_id='782.Zorunlu Alan'> : <cf_get_lang dictionary_id='114.Tasarım Genel Default Tanımları'>!");
                window.close()
            </script>
            <cfabort>
        </cfif>
    </cfif>
    <cfinclude template="add_ezgi_product_tree_creative_package_row_insert.cfm">
</cftransaction>
<script type="text/javascript">
 	wrk_opener_reload();
        window.close();
</script>