  <!---
    File: add_ezgi_design_all_material.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->   

<cfif attributes.record_num gt 0>
	<cftransaction>
		<cfif IsDefined("attributes.design_package_row_id")>
            <cfquery name="get_design_id" datasource="#dsn3#">
                SELECT DESIGN_ID, DESIGN_MAIN_ROW_ID FROM EZGI_DESIGN_PACKAGE WHERE PACKAGE_ROW_ID = #attributes.design_package_row_id#
            </cfquery>
            <cfset attributes.design_id = get_design_id.design_id>
            <cfset attributes.design_main_row_id = get_design_id.DESIGN_MAIN_ROW_ID>
            <cfquery name="del_all_material" datasource="#dsn3#">
            	DELETE FROM EZGI_DESIGN_ALL_MATERIAL WHERE DESIGN_PACKAGE_ROW_ID = #attributes.design_package_row_id# 
            </cfquery>
        <cfelseif IsDefined("attributes.design_main_row_id")>
            <cfquery name="get_design_id" datasource="#dsn3#">
                SELECT DESIGN_ID FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
            </cfquery>
            <cfset attributes.design_id = get_design_id.design_id>
            <cfquery name="del_all_material" datasource="#dsn3#">
            	DELETE FROM EZGI_DESIGN_ALL_MATERIAL WHERE DESIGN_MAIN_ROW_ID  = #attributes.design_main_row_id# AND DESIGN_PACKAGE_ROW_ID IS NULL
            </cfquery>
        </cfif>
        <cfloop from="1" to="#attributes.record_num#" index="i">
        	<cfif Evaluate('attributes.row_kontrol#i#') eq 1>
                <cfquery name="add_all_material" datasource="#dsn3#">
                    INSERT INTO 
                        EZGI_DESIGN_ALL_MATERIAL
                        (
                            DESIGN_ID, 
                            DESIGN_MAIN_ROW_ID, 
                            <cfif IsDefined("attributes.design_package_row_id")>
                                DESIGN_PACKAGE_ROW_ID, 
                            </cfif>
                            PRODUCT_ID, 
                            STOCK_ID, 
                            AMOUNT, 
                            UNIT_ID,
                            UNIT
                        )
                    VALUES        
                        (
                            #attributes.design_id#,
                            #attributes.design_main_row_id#,
                            <cfif IsDefined("attributes.design_package_row_id")>
                                #attributes.design_package_row_id#,
                            </cfif>
                            #Evaluate('product_id#i#')#,
                            #Evaluate('stock_id#i#')#,
                            #FilterNum(Evaluate('row_amount#i#'),3)#,
                            #Evaluate('unit_id#i#')#,
                            '#Evaluate('unit#i#')#'
                            )
                </cfquery>
            </cfif>
        </cfloop>
    </cftransaction>
</cfif>
<cfif IsDefined("attributes.design_package_row_id")>
	<cflocation url="#request.self#?fuseaction=prod.popup_add_ezgi_design_all_material&design_package_row_id=#attributes.design_package_row_id#" addtoken="No">
<cfelseif IsDefined("attributes.design_main_row_id")>
	<cflocation url="#request.self#?fuseaction=prod.popup_add_ezgi_design_all_material&design_main_row_id=#attributes.design_main_row_id#" addtoken="No">
</cfif>