<!---
    File: del_ezgi_product_tree_creative_main_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cftransaction>
	<!---Parça Rotalar Siliniyor--->
    <cfquery name="DEL_ROTA" datasource="#DSN3#">
        DELETE FROM 
            EZGI_DESIGN_PIECE_ROTA
        WHERE        
            PIECE_ROW_ID IN
                            (
                                SELECT        
                                	PIECE_ROW_ID
								FROM            
                                	EZGI_DESIGN_PIECE_ROWS
								WHERE        
                                	DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
                            )
    </cfquery>
    <!---Aksesuar - Bant - Hizmetler Siliniyor--->
    <cfquery name="DEL_PIECE_ROW" datasource="#DSN3#">
        DELETE FROM 
            EZGI_DESIGN_PIECE_ROW
        WHERE        
            PIECE_ROW_ID IN
                            (
                                SELECT        
                                	PIECE_ROW_ID
								FROM            
                                	EZGI_DESIGN_PIECE_ROWS
								WHERE        
                                	DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
                            )
    </cfquery>
    <!---Sepet Ürünleri Siliniyor--->
    <cfquery name="DEL_ALL_MATERIAL" datasource="#DSN3#">
        DELETE FROM            
            EZGI_DESIGN_ALL_MATERIAL
        WHERE        
            DESIGN_PACKAGE_ROW_ID IN
                                    (
                                        SELECT        
                                        	PACKAGE_ROW_ID
										FROM            
                                        	EZGI_DESIGN_PACKAGE_ROW
										WHERE        
                                        	DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
                                    ) OR
            DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
    </cfquery>
    <!---Parçalar Siliniyor--->
    <cfquery name="del_piece" datasource="#dsn3#">
        DELETE FROM EZGI_DESIGN_PIECE_ROWS WHERE DESIGN_MAIN_ROW_ID =#attributes.design_main_row_id#
    </cfquery>
    <!---Paket Rotalar Siliniyor--->
    <cfquery name="DEL_ROTA" datasource="#DSN3#">
        DELETE FROM 
            EZGI_DESIGN_PIECE_ROTA
        WHERE        
            PACKAGE_ROW_ID IN
                            (
                                SELECT        
                                	PACKAGE_ROW_ID
								FROM            
                                	EZGI_DESIGN_PACKAGE
								WHERE        
                                	DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
                            )
    </cfquery>
    <!---Paketler Siliniyor--->
    <cfquery name="del_package" datasource="#dsn3#">
        DELETE FROM EZGI_DESIGN_PACKAGE_ROW WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
    </cfquery>
    <!---Modül Siliniyor--->
    <cfquery name="del_main" datasource="#dsn3#">
        DELETE FROM EZGI_DESIGN_MAIN_ROW WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
    </cfquery>
</cftransaction>
<script type="text/javascript">
        wrk_opener_reload();
        window.close();
</script>