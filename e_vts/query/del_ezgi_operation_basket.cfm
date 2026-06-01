<!---
    File: del_ezgi_operation_basket.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/07/2022
    Description:
--->
<cftransaction>
	<cfif isdefined('attributes.operation_id_list') and Listlen(attributes.operation_id_list)><!---Dolu Sepet Silinmek isteniyorsa--->
        <cfloop list="#attributes.operation_id_list#" index="i">
            <cfif ListLen(i,'_') eq 2>
                <cfquery name="add_operation_basket_row" datasource="#dsn3#">
                    DELETE FROM 
                        EZGI_VTS_OPERATION_BASKET_ROW
                    WHERE  
                        OPERATION_ID = #ListGetAt(i,2,'_')# AND 
                        EZGI_VTS_OPERATION_BASKET_ID = #ListGetAt(i,1,'_')#
                </cfquery>
            </cfif>
        </cfloop>
        <cfquery name="get_basket_row" datasource="#dsn3#"> <!---Eğer Onaylanmamış sepet Varsa Bilgileri Alınıyor--->
            SELECT EZGI_VTS_OPERATION_BASKET_ID EZGI_VTS_OPERATION_BASKET_ID FROM EZGI_VTS_OPERATION_BASKET_ROW WHERE EZGI_VTS_OPERATION_BASKET_ID = #ListGetAt(i,1,'_')#
        </cfquery>
        <cfif not get_basket_row.recordcount>
            <cfquery name="add_operation_basket_row" datasource="#dsn3#">
                DELETE FROM 
                    EZGI_VTS_OPERATION_BASKET
                WHERE  
                    EZGI_VTS_OPERATION_BASKET_ID = #ListGetAt(i,1,'_')#
            </cfquery>
        </cfif>
   	<cfelse><!---Boşalmış Sepet Silinmek isteniyorsa--->
    	<cfquery name="add_operation_basket_row" datasource="#dsn3#">
         	DELETE FROM 
             	EZGI_VTS_OPERATION_BASKET
          	WHERE  
             	EZGI_VTS_OPERATION_BASKET_ID = #attributes.basket_id#
     	</cfquery>
    </cfif>
</cftransaction>    
<script type="text/javascript">
	alert("Seçtiğiniz Operasyonların Sepet Kaydı Silinmiştir!");
	window.location ="<cfoutput>#request.self#?fuseaction=production.dsp_ezgi_operation_basket&is_form_submitted=1&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#</cfoutput>";
</script>
