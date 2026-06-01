<!---
    File: del_ezgi_private_product_tree_creative_rows.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cftransaction>
    <cfquery name="del_process" datasource="#dsn3#">
        DELETE FROM EZGI_DESIGN_PIECE_ROWS WHERE PIECE_ROW_ID IN (#attributes.pic_row_list#)
    </cfquery>
    <cfquery name="del_process_row" datasource="#dsn3#">
        DELETE FROM EZGI_DESIGN_PIECE_ROW WHERE PIECE_ROW_ID IN (#attributes.pic_row_list#)
    </cfquery>
    <cfquery name="del_rota" datasource="#dsn3#">
        DELETE FROM EZGI_DESIGN_PIECE_ROTA WHERE PIECE_ROW_ID IN (#attributes.pic_row_list#)
    </cfquery>
</cftransaction>
<cfif ListLen(attributes.iid)>
	<cfset adres = "piece_type_select=&sort_id=#attributes.sort_id#">
	<cfloop list="#attributes.iid#" index="i">
    	<cfif ListGetat(i,1,'-') eq 1>
        	<cfset attributes.design_id = ListGetat(i,2,'-')>
            <cfif len(attributes.design_id)>
				<cfset adres = "#adres#&design_id=#attributes.design_id#">
            </cfif>
        <cfelseif ListGetat(i,1,'-') eq 2>
        	<cfset attributes.design_main_row_id = ListGetat(i,2,'-')>
            <cfif len(attributes.design_main_row_id)>
				<cfset adres = "#adres#&design_main_row_id=#attributes.design_main_row_id#">
            </cfif>
       	<cfelseif ListGetat(i,1,'-') eq 3>
        	<cfset attributes.design_package_row_id = ListGetat(i,2,'-')>
            <cfif len(attributes.design_package_row_id)>
				<cfset adres = "#adres#&design_package_row_id=#attributes.design_package_row_id#">
            </cfif>
        </cfif>
    </cfloop>
</cfif>
<cfif isdefined('attributes.standart')>
	<script type="text/javascript">
        window.location.href = '<cfoutput>#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&#adres#</Cfoutput>';
    </script>
<cfelse>
	<script type="text/javascript">
        window.location.href = '<cfoutput>#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd&#adres#</Cfoutput>';
    </script>
	
</cfif>