<!---
    File: add_ezgi_product_tree_creative_piece_relation.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 
<cfif isdefined('attributes.piece_id') and len(attributes.piece_id)>
        <cfquery name="upd_piece_relation" datasource="#dsn3#">
            UPDATE       
                EZGI_DESIGN_PIECE_ROWS
            SET                
                PIECE_RELATED_ID = #attributes.sid#
            WHERE        
                PIECE_ROW_ID = #attributes.piece_id#
        </cfquery>
        <script type="text/javascript">
            alert("<cf_get_lang dictionary_id='984.Ürün İlişkilendirme Başarıyla Tamamlandı!'>");
            wrk_opener_reload();
            window.close();
        </script>
<cfelseif isdefined('attributes.main_id') and len(attributes.main_id)>
        <cfquery name="upd_main_relation" datasource="#dsn3#">
            UPDATE       
                EZGI_DESIGN_MAIN_ROW
            SET                
                DESIGN_MAIN_RELATED_ID = #attributes.sid#
            WHERE        
                DESIGN_MAIN_ROW_ID = #attributes.main_id#
        </cfquery>
        <script type="text/javascript">
            alert("<cf_get_lang dictionary_id='984.Ürün İlişkilendirme Başarıyla Tamamlandı!'>");
            wrk_opener_reload();
            window.close();
        </script>
<cfelseif isdefined('attributes.package_id') and len(attributes.package_id)>
        <cfquery name="upd_package_relation" datasource="#dsn3#">
            UPDATE       
                EZGI_DESIGN_PACKAGE_ROW
            SET                
                PACKAGE_RELATED_ID = #attributes.sid#
            WHERE        
                PACKAGE_ROW_ID = #attributes.package_id#
        </cfquery>
        <script type="text/javascript">
            alert("<cf_get_lang dictionary_id='984.Ürün İlişkilendirme Başarıyla Tamamlandı!'>");
            wrk_opener_reload();
            window.close();
        </script>
</cfif>