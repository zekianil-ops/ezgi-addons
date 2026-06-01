<!---
    File: upd_ezgi_product_tree_creative_piece_rota.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cftransaction>
    <cfquery name="del_rota" datasource="#dsn3#">
        DELETE FROM 
        	EZGI_DESIGN_PIECE_ROTA 
       	WHERE 
        	<cfif isdefined('attributes.piece_id')>
                PIECE_ROW_ID = #attributes.piece_id# 
            <cfelseif isdefined('attributes.package_id')>
                PACKAGE_ROW_ID = #attributes.package_id#
            <cfelseif isdefined('attributes.main_id')>
                MAIN_ROW_ID = #attributes.main_id#
            </cfif>
    </cfquery>
    <cfloop from="1" to="#attributes.record_num#" index="i">
        <cfif Evaluate('attributes.row_kontrol#i#') eq 1>
            <cfquery name="add_default_rota" datasource="#dsn3#">
                INSERT INTO 
                    EZGI_DESIGN_PIECE_ROTA
                    (
                    <cfif isdefined('attributes.piece_id')>
                        PIECE_ROW_ID,
                    <cfelseif isdefined('attributes.package_id')>
                        PACKAGE_ROW_ID,
                    <cfelseif isdefined('attributes.main_id')>
                        MAIN_ROW_ID,
                    </cfif> 
                    OPERATION_TYPE_ID, 
                    SIRA, 
                    AMOUNT
                    )
                VALUES
                    (      
                    <cfif isdefined('attributes.piece_id')>
                        #attributes.piece_id#, 
                    <cfelseif isdefined('attributes.package_id')>
                        #attributes.package_id#,
                    <cfelseif isdefined('attributes.main_id')>
                       	#attributes.main_id#,
                    </cfif> 
                    #Evaluate('attributes.operation_type_id#i#')#, 
                    #Evaluate('attributes.current_id#i#')#, 
                    #FilterNum(Evaluate('attributes.quantity#i#'),2)#
                    )
            </cfquery>
        </cfif>
    </cfloop>
    <cfif isdefined('attributes.is_common_piece_list')> <!---Ortak Parça Varmı--->
    	<cfquery name="del_rota" datasource="#dsn3#">
            DELETE FROM EZGI_DESIGN_PIECE_ROTA WHERE PIECE_ROW_ID IN (#attributes.is_common_piece_list#)
        </cfquery>
        <cfloop list="#attributes.is_common_piece_list#" index="i">
          	<cfquery name="copy_rota" datasource="#dsn3#">
             	INSERT INTO 
                	EZGI_DESIGN_PIECE_ROTA
                  	(
                    	PIECE_ROW_ID, 
                        OPERATION_TYPE_ID, 
                        SIRA, 
                        AMOUNT
                	)
             	SELECT
                	#i#, 
                  	OPERATION_TYPE_ID, 
                  	SIRA, 
                 	AMOUNT
              	FROM
                	EZGI_DESIGN_PIECE_ROTA WITH (NOLOCK)
              	WHERE
                	PIECE_ROW_ID =  #attributes.piece_id#
        	</cfquery>
        </cfloop>
    </cfif>
</cftransaction>
<cf_get_lang dictionary_id='47470.İşlem Tamamlandı'>
<cfif isdefined('attributes.master_plan_id')>
	<cfinclude template="../../e_production/query/upd_ezgi_iflow_master_plan_operation.cfm">
	<script type="text/javascript">
        alert("<cf_get_lang dictionary_id='47470.İşlem Tamamlandı'>");
        wrk_opener_reload();
        window.close();
    </script>
<cfelse>
	<script type="text/javascript">
        alert("<cf_get_lang dictionary_id='47470.İşlem Tamamlandı'>");
        window.close();
    </script>
</cfif>