<!---
    File: del_ezgi_shipping_internaldemand.cfm
    Folder: Add_Ons\ezgi\e_shipping\query
    Author: Ezgi Yazılım
    Date: 01/01/2017
    Description:
--->
<cfquery name="DEL_ROW" datasource="#DSN3#">
        DELETE FROM 
        	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW
		WHERE  
        	<cfif attributes.type eq 1>   
        		SHIP_RESULT_INTERNALDEMAND_ROW_ID = #attributes.ship_result_internaldemand_row_id#
            <cfelse>
            	SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_result_internaldemand_id#
            </cfif>
</cfquery>
<cfif attributes.type eq 1>   
	<cfquery name="GET_PACKAGE" datasource="#dsn3#">
    	SELECT 
        	ISNULL(SUM(EPS.PAKET_SAYISI * ORR.QUANTITY), 0) AS TOPLAM_PAKET_SAYI
		FROM     
        	STOCKS AS S INNER JOIN
            EZGI_PAKET_SAYISI AS EPS ON S.STOCK_ID = EPS.MODUL_ID INNER JOIN
            ORDER_ROW AS ORR INNER JOIN
            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ORR.ORDER_ROW_ID = ESRR.ORDER_ROW_ID ON S.STOCK_ID = ORR.STOCK_ID
		WHERE  
        	S.IS_KARMA = 1 AND 
        	ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID = #attributes.ship_result_row_id#
    </cfquery>
    <cfquery name="upd_result_pack_amount" datasource="#dsn#">
    	UPDATE 
        	EZGI_SHIP_RESULT_INTERNALDEMAND
		SET          
        	SHIPMENT_PACKAGE_AMOUNT = SHIPMENT_PACKAGE_AMOUNT -#GET_PACKAGE.TOPLAM_PAKET_SAYI#
		WHERE  
        	SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_result_internaldemand_id#
    </cfquery>
</cfif>
<cfif attributes.type eq 1> 
	<cflocation url="#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_internaldemand&iid=#attributes.ship_result_internaldemand_id#" addtoken="no">
<cfelse>
	<script type="text/javascript">
		wrk_opener_reload();
		window.close();
	</script>
</cfif>    
