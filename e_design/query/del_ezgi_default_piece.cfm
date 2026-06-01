<!---
    File: del_ezgi_default_piece.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfquery name="get_name_control" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_PIECE WITH (NOLOCK) WHERE MASTER_PRODUCT_ID = #attributes.piece_id#
</cfquery>
<cfif get_name_control.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='971.Default Parça Tasarımda Kullanılmaktadır. Bu Yüzden Silme İşlemi Gerçekleşmedi.!'>");
		window.history.go(-1);
	</script>
	<cfabort>
</cfif>
<cftransaction>
    <cfquery name="del_piece_default" datasource="#dsn3#">
    	DELETE FROM EZGI_DESIGN_PIECE_DEFAULTS WHERE PIECE_DEFAULT_ID = #attributes.piece_id#
    </cfquery>
    <cfquery name="del_rota" datasource="#dsn3#">
    	DELETE FROM EZGI_DESIGN_PIECE_DEFAULTS_ROTA WHERE PIECE_DEFAULT_ID = #attributes.piece_id#
    </cfquery>
</cftransaction>
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_default_piece" addtoken="No">