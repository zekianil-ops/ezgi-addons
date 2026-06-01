  <!---
    File: add_ezgi_default_piece.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->  

<cfquery name="get_name_control" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_PIECE_DEFAULTS WITH (NOLOCK) WHERE PIECE_DEFAULT_NAME = '#attributes.default_type#'
</cfquery>
<cfif get_name_control.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='257.Aynı İsimde Operasyon Mevcut. Lütfen Düzeltiniz'>!");
		window.history.go(-1);
	</script>
	<cfabort>
</cfif>
<cftransaction>
    <cfquery name="get_piece_default" datasource="#dsn3#">
        INSERT INTO              
            EZGI_DESIGN_PIECE_DEFAULTS
            (
                PIECE_DEFAULT_NAME,
                PIECE_DEFAULT_CODE,
                STATUS,
                RECORD_EMP, 
                RECORD_IP, 
                RECORD_DATE
            )
        VALUES        
            (
                '#attributes.default_type#',
                '#attributes.default_code#',
                <cfif isdefined('attributes.status')>1<cfelse>0</cfif>,
                #session.ep.userid#,
                '#cgi.remote_addr#',
                #now()#
            )
    </cfquery>
    <cfquery name="get_max" datasource="#dsn3#">
        SELECT MAX(PIECE_DEFAULT_ID) AS MAX_ID FROM EZGI_DESIGN_PIECE_DEFAULTS WITH (NOLOCK)
    </cfquery>
    <cfif attributes.record_num gt 0>
        <cfloop from="1" to="#attributes.record_num#" index="i">
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
                    #get_max.MAX_ID#,
                    #Evaluate('attributes.operation_type_id#i#')#,
                    #Filternum(Evaluate('attributes.quantity#i#'),2)#,
                    #i#
                    )
            </cfquery>
        </cfloop>
    </cfif>
	<cfquery name="getmax" datasource="#dsn3#">
    	SELECT MAX(PIECE_DEFAULT_ID) MAXID FROM EZGI_DESIGN_PIECE_DEFAULTS WITH (NOLOCK)
    </cfquery>
</cftransaction>
<cfif isdefined('attributes.is_piece')>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='58838.Kayıt İşleminiz Başarıyla Tamamlanmıştır.'>!");
		wrk_opener_reload();
		window.close()
	</script>
<cfelse>
	<cflocation url="#request.self#?fuseaction=prod.list_ezgi_default_piece&event=upd&piece_id=#getmax.maxid#" addtoken="No">
</cfif>