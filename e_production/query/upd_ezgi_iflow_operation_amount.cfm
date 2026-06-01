<!---
    File: upd_ezgi_iflow_operation_amount.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfif ListLen(attributes.p_operation_id_list)>
	<cftransaction>
        <cfloop list="#attributes.p_operation_id_list#" index="i">
        	<cfif ListLen(i,'_')>
        		<cfset islem = i>
                <cfset piece_row_id = ListGetAt(islem,1,'_')>
                <cfset operation_type_id = ListGetAt(islem,2,'_')>
                <cfset amount = ListGetAt(islem,3,'_')>
                <cfoutput>#piece_row_id# - #operation_type_id# - #AMOUNT#</cfoutput><BR />
                <cfquery name="get_operation_same" datasource="#dsn3#">
                	SELECT        
                    	PIECE_ROTA_ID
					FROM            
                    	EZGI_DESIGN_PIECE_ROTA
					WHERE        
                    	PIECE_ROW_ID = #piece_row_id# AND 
                        OPERATION_TYPE_ID = #operation_type_id#
                </cfquery>
                <cfif get_operation_same.recordcount>
                	<cfif amount gt 0>
                		<cfquery name="upd_operation_same" datasource="#dsn3#">
                        	UPDATE EZGI_DESIGN_PIECE_ROTA SET AMOUNT = #amount# WHERE PIECE_ROTA_ID = #get_operation_same.PIECE_ROTA_ID#
                        </cfquery>
                	<cfelse>
                    	<cfquery name="del_operation_same" datasource="#dsn3#">
                        	DELETE FROM EZGI_DESIGN_PIECE_ROTA WHERE PIECE_ROTA_ID = #get_operation_same.PIECE_ROTA_ID#
                        </cfquery>
                    </cfif>
                <cfelse>
                	<cfquery name="add_operation_same" datasource="#dsn3#">
                    	INSERT INTO 
                        	EZGI_DESIGN_PIECE_ROTA
                         	(
                            	PIECE_ROW_ID, 
                                OPERATION_TYPE_ID, 
                                SIRA, 
                                AMOUNT
                          	)
						VALUES        
                        	(
                                #piece_row_id#,
                                #operation_type_id#,
                                0,
                                #amount#
                            )
                    </cfquery>
                </cfif>
          	</cfif>
        </cfloop>
   	</cftransaction>
</cfif>
<cfinclude template="/add_options/e_iflow/query/upd_ezgi_iflow_master_plan_operation.cfm">
<cflocation url="#request.self#?fuseaction=prod.upd_ezgi_iflow_master_plan&master_plan_id=#attributes.master_plan_id#" addtoken="No">