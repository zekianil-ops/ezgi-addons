<cfset durum = ListgetAt(attributes.delivery_date,1,'_')>
<cfset tarih = ListgetAt(attributes.delivery_date,2,'_')>
<cfif durum eq 1>
    <cfquery name="del_delivery_date" datasource="#dsn3#">
        UPDATE    
            ORDER_ROW
        SET              
            DELIVER_DATE = CONVERT(DATETIME, '#Dateformat(tarih,'YYYY-MM-DD')# 00:00:00', 102)
        WHERE     
            ORDER_ROW_ID = #attributes.upd#
    </cfquery>
    <cflocation url="#request.self#?fuseaction=sales.popup_add_ezgi_delivery_date_master_plan&order_id=#attributes.order_id#" addtoken="no">
<cfelseif durum eq 0>
	<script language="javascript">
		alert('Tatil Gününü Rezerv Edemezsiniz');
	   	history.back();
	</script>
<cfelse>
	<script language="javascript">
		alert('Dolu Günü Rezerv Edemezsiniz');
	   	history.back();
	</script>
</cfif>