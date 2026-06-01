<cfquery name="DEL_ROW" datasource="#DSN3#">
 	DELETE FROM
   		EZGI_ORDER_TESHIR
  	WHERE
    	ORDER_ROW_ID = #attributes.order_row_id#
</cfquery>
<cflocation url="#request.self#?fuseaction=sales.popup_add_ezgi_shipping_internaldemand&order_id=#attributes.order_id#" addtoken="no">