<!---
    File: upd_ezgi_product_tree_creative_piece_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_piece" datasource="#dsn3#">
  	SELECT MASTER_PRODUCT_ID FROM EZGI_DESIGN_PIECE WHERE PIECE_ROW_ID = #attributes.design_piece_row_id#
</cfquery>
<cfif not get_piece.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='982.Parça Silindiğinden Güncelleme Yapılamaz!'>");
		window.close()
	</script>
    <cfabort>
</cfif>
<cftransaction>
	<cfinclude template="upd_ezgi_product_tree_creative_piece_row_insert.cfm">
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
              		PIECE_ROW_ID = #attributes.design_piece_row_id#
          	</cfquery>
     	</cfif>
    </cfif>
</cftransaction>
<cflocation url="#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_piece_row&design_piece_row_id=#attributes.design_piece_row_id#" addtoken="no">