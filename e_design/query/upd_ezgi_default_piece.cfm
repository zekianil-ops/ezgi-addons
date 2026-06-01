<!---
    File: upd_ezgi_default_piece.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfquery name="get_name_control" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_PIECE_DEFAULTS WITH (NOLOCK) WHERE PIECE_DEFAULT_NAME = '#attributes.default_type#' AND PIECE_DEFAULT_ID <> #attributes.piece_id#
</cfquery>
<cfif get_name_control.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='980.Aynı İsimde Default Parça Mevcut Lütfen Düzeltiniz!'>");
		window.history.go(-1);
	</script>
	<cfabort>
</cfif>
<cftransaction>
	
    <cfquery name="upd_piece_default" datasource="#dsn3#">
    	UPDATE     
        	EZGI_DESIGN_PIECE_DEFAULTS
		SET                
        	PIECE_DEFAULT_CODE = '#attributes.default_code#', 
            PIECE_DEFAULT_NAME = '#attributes.default_type#', 
            STATUS = <cfif isdefined('attributes.status')>1<cfelse>0</cfif>, 
            UPDATE_EMP = #session.ep.userid#, 
            UPDATE_DATE = #now()#, 
            UPDATE_IP = '#cgi.remote_addr#'
		WHERE        
        	PIECE_DEFAULT_ID = #attributes.piece_id#
    </cfquery>
    <cfquery name="del_rota" datasource="#dsn3#">
    	DELETE FROM EZGI_DESIGN_PIECE_DEFAULTS_ROTA WHERE PIECE_DEFAULT_ID = #attributes.piece_id#
    </cfquery>
    <cfif attributes.record_num gt 0>
        <cfloop from="1" to="#attributes.record_num#" index="i">
        	<cfif Evaluate('attributes.row_kontrol#i#') eq 1>
                <cfquery name="add_rota" datasource="#dsn3#">
                    INSERT INTO 
                        EZGI_DESIGN_PIECE_DEFAULTS_ROTA
                        (
                        PIECE_DEFAULT_ID, 
                        OPERATION_TYPE_ID, 
                        QUANTITY,
                        SIRA
                        )
                    VALUES        
                        (
                        #attributes.piece_id#,
                        #Evaluate('attributes.operation_type_id#i#')#,
                        #Filternum(Evaluate('attributes.quantity#i#'),2)#,
                        #i#
                        )
                </cfquery>
            </cfif>
        </cfloop>
    </cfif>
</cftransaction>
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_default_piece&event=upd&piece_id=#attributes.piece_id#" addtoken="No">