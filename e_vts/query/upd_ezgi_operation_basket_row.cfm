<!---
    File: upd_ezgi_operation_basket_row.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/09/2022
    Description:
--->
<cfdump var = "#attributes#"><cfabort>
<cftransaction>
    <cfquery name="add_operation_basket_row" datasource="#dsn3#">
                UPDATE 
                	EZGI_VTS_OPERATION_BASKET
				SET          
                	IS_STAGE =<cfif isdefined('attributes.kaldir')>0<cfelse>1</cfif>,
                    UPDATE_DATE = #now()#, 
                    UPDATE_EMP = #session.ep.userid#, 
                    UPDATE_IP = '#CGI.REMOTE_ADDR#'
				WHERE  
                	EZGI_VTS_OPERATION_BASKET_ID = #attributes.basket_id#
            </cfquery>
</cftransaction>    
<script type="text/javascript">
	<cfif isdefined('attributes.islem') and attributes.islem eq 1>
		alert("Toplu Operasyon Başlatılmıştır.!");
	</cfif>
	window.location ="<cfoutput>#request.self#?fuseaction=production.dsp_ezgi_operation_basket&is_form_submitted=1&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#</cfoutput>";
</script>
