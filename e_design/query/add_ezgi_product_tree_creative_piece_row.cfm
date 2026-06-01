<!---
    File: add_ezgi_product_tree_creative_piece_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfquery name="GET_DEFAULT_EBATLAMA" datasource="#dsn3#">
	SELECT        
    	OTT.OPERATION_TYPE_ID
	FROM           
    	OPERATION_TYPES AS OTT WITH (NOLOCK) INNER JOIN
     	EZGI_DESIGN_DEFAULTS AS EDD WITH (NOLOCK) ON OTT.OPERATION_TYPE_ID = EDD.DEFAULT_CUTTING_OPERATION_TYPE_ID
</cfquery>
<cfif not GET_DEFAULT_EBATLAMA.recordcount>
	<script type="text/javascript">
		alert(<cf_get_lang dictionary_id='950.Genel Default Tanımlarda Ebatlama Operasyonu Tanımlı Değil. Düzenleyip Tekrar Deneyin'>);
		
		window.close()
	</script>
    <cfabort>
</cfif>
<cftransaction>
    <cfinclude template="add_ezgi_product_tree_creative_piece_row_insert.cfm">
    <cfif attributes.PIECE_TYPE eq 4>
    	<cfquery name="get_spect_main_id" datasource="#dsn3#">
         	SELECT        
             	TOP (1) SPECT_MAIN_ID
         	FROM            
             	SPECT_MAIN WITH (NOLOCK)
           	WHERE        
           		STOCK_ID = #attributes.related_stock_id# AND 
          		IS_TREE = 1
        	ORDER BY 
         		SPECT_MAIN_ID DESC
 		</cfquery>
       	<cfif get_spect_main_id.recordcount>
          	<cfquery name="upd_piece" datasource="#dsn3#">
              	UPDATE     
                	EZGI_DESIGN_PIECE_ROWS
				SET                
              		PIECE_SPECT_RELATED_ID = #get_spect_main_id.SPECT_MAIN_ID#
				WHERE        
              		PIECE_ROW_ID = #get_max_id.MAX_ID#
          	</cfquery>
     	</cfif>
    </cfif>
</cftransaction>
<cfif not isdefined('attributes.import_files')> <!---İmport Dosyasından Gelmiyorsa--->
	<script type="text/javascript">
        wrk_opener_reload();
        window.close();
    </script>
</cfif>