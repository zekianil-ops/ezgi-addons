<!---
    File: upd_ezgi_perioad_based_count_operations.cfm
    Folder: Add_Ons\ezgi\e-wm\query
    Author: Ezgi Yazılım
    Date: 01/03/2025
    Description:
--->
<cflock timeout="90">
	<cftransaction>
        <cfquery name="upd_count" datasource="#dsn3#">
            UPDATE 
            	EZGI_WM_COUNT
			SET          
            	STATUS = <cfif isdefined('attributes.status')>1<cfelse>0</cfif>, 
                IS_PALETTE_CONTENT_SAVE = <cfif isdefined('attributes.is_palette_content_save')>1<cfelse>0</cfif>,  
                UPDATE_EMP = #session.ep.userid#,
                UPDATE_IP = '#cgi.remote_addr#',
                UPDATE_DATE = #now()#
			WHERE  
            	EZGI_WM_COUNT_ID = #attributes.count_id#
        </cfquery>
	</cftransaction>
</cflock> 
<script type="text/javascript">
	alert('Güncelleme İşlemi Tamamlanmıştır.');
	window.location ="<cfoutput>#request.self#?fuseaction=stock.list_ezgi_perioad_based_count_operations&event=upd&count_id=#attributes.count_id#</cfoutput>";
</script>  