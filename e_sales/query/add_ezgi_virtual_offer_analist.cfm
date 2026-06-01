<!---
    File: add_ezgi_virtual_offer_analist.cfm
    Folder: Add_Ons\ezgi\e_sales\query
    Author: Ezgi Yazılım
    Date: 01/12/2024
    Description:
--->
<cfif Listlen(attributes.virtual_offer_row_id)>
	<cftransaction>
        <cfloop from="1" to="#ListLen(attributes.virtual_offer_row_id)#" index="i">
        	<cfset v_offer_row_id = ListGetAt(attributes.virtual_offer_row_id,i)>
            <cfquery name="upd_virtual_offer_row" datasource="#dsn3#">
            	UPDATE
                	EZGI_VIRTUAL_OFFER_ROW
              	SET
                	SORT_NO = #i#
                WHERE
                	VIRTUAL_OFFER_ROW_ID = #v_offer_row_id#
            </cfquery>
        </cfloop>
    </cftransaction>
	<script type="text/javascript">
     	alert("Satır Sıralama İşlemi Tamamlanmıştır!");
		window.opener.location.reload();
       	window.close();
  	</script>
</cfif>
