<!---
    File: del_ezgi_product_tree_creative.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cftransaction>
	<!---Rotalar Siliniyor--->
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
                                    DESIGN_ID = #attributes.design_id#
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
                                    DESIGN_ID = #attributes.design_id#
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
                                            DESIGN_ID = #attributes.design_id#
                                    ) OR
            DESIGN_MAIN_ROW_ID IN  (
                                        SELECT        
                                            DESIGN_MAIN_ROW_ID
                                        FROM            
                                            EZGI_DESIGN_MAIN_ROW
                                        WHERE        
                                            DESIGN_ID = #attributes.design_id#
                                    )
    </cfquery>
    <!---Parçalar Siliniyor--->
    <cfquery name="del_package" datasource="#dsn3#">
        DELETE FROM EZGI_DESIGN_PIECE_ROWS WHERE DESIGN_ID = #attributes.design_id#
    </cfquery>
    <!---Paketler Siliniyor--->
    <cfquery name="del_package" datasource="#dsn3#">
        DELETE FROM EZGI_DESIGN_PACKAGE_ROW WHERE DESIGN_ID = #attributes.design_id#
    </cfquery>
    <!---Modüller Siliniyor--->
    <cfquery name="del_main" datasource="#dsn3#">
        DELETE FROM EZGI_DESIGN_MAIN_ROW WHERE DESIGN_ID = #attributes.design_id#
    </cfquery>
    <!---Tasarım Siliniyor--->
    <cfquery name="del_design" datasource="#dsn3#">
        DELETE FROM EZGI_DESIGN	WHERE DESIGN_ID = #attributes.design_id#
    </cfquery>
</cftransaction>
<cfif isdefined('attributes.is_private')>
	<cflocation url="#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative" addtoken="no">
<cfelse>
	<cflocation url="#request.self#?fuseaction=prod.list_ezgi_product_tree_creative" addtoken="no">
</cfif>