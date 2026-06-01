<cfset shipping_id_list_1 =''>
<cfset shipping_id_list_2 =''>
<cfset errorOrderList =''>
<cf_date tarih='attributes.send_date'>
<cfloop list="#attributes.shipping_id_list#" index="ii">
	<cfif listgetat(ii,1,'-') eq 1>
		<cfset shipping_id_list_1 = ListAppend(shipping_id_list_1, listgetat(ii,2,'-'))>
   	<cfelseif listgetat(ii,1,'-') eq 2> 
    	<cfset shipping_id_list_2 = ListAppend(shipping_id_list_2, listgetat(ii,2,'-'))>
    </cfif>
</cfloop>
<cflock timeout="90">
  	<cftransaction>
    	<cfif not isdefined('attributes.type')>
			<cfif Listlen(shipping_id_list_1)>
                <cfquery name="UPD_SHIP_RESULT" datasource="#DSN3#">
                    UPDATE
                        EZGI_SHIP_RESULT
                    SET
                        OUT_DATE = #attributes.send_date#,
                        DELIVERY_DATE = #attributes.send_date#,
                        UPDATE_EMP = #session.ep.userid#,
                        UPDATE_IP = '#cgi.remote_addr#',
                        UPDATE_DATE = #now()#
                    WHERE
                        SHIP_RESULT_ID IN (#shipping_id_list_1#)
                </cfquery>
                <cfloop list="#shipping_id_list_1#" index="k">
                    <cfquery name="get_shipping_row" datasource="#dsn3#">
                        SELECT ORDER_ROW_ID FROM EZGI_SHIP_RESULT_ROW WHERE  SHIP_RESULT_ID = #k#
                    </cfquery>
                    <cfset order_row_id_list = ValueList(get_shipping_row.ORDER_ROW_ID)>
                    <cfif ListLen(order_row_id_list)>
                        <cfloop list="#order_row_id_list#" index="i">
                            <cfquery name="UPD_ORDER_ROW_DELIVER_DATE" datasource="#DSN3#">
                                UPDATE    
                                    ORDER_ROW
                                SET              
                                    DELIVER_DATE = #attributes.send_date#
                                WHERE     
                                    ORDER_ROW_ID = #i#
                            </cfquery>
                        </cfloop>
                    </cfif>
                </cfloop>
            </cfif>
            <cfif Listlen(shipping_id_list_2)>
                <cfquery name="UPD_SHIP_INTERNAL" datasource="#DSN3#">
                	 UPDATE
                        EZGI_SHIP_RESULT_INTERNALDEMAND
                    SET
                        OUT_DATE = #attributes.send_date#,
                        DELIVERY_DATE = #attributes.send_date#,
                        UPDATE_EMP = #session.ep.userid#,
                        UPDATE_IP = '#cgi.remote_addr#',
                        UPDATE_DATE = #now()#
                    WHERE
                        SHIP_RESULT_INTERNALDEMAND_ID IN (#shipping_id_list_2#)
                </cfquery>
            </cfif>
      	<cfelseif attributes.type eq 2> <!--- Faprika servisi tetiklenir --->
            <cfif Listlen(shipping_id_list_1)>
                <cfquery name="get_orders" datasource="#dsn3#">
                    SELECT 
                    	ORD.ORDER_ID, 
                        ORD.ORDER_HEAD 
                    FROM 
                    	EZGI_SHIP_RESULT_ROW AS ESRR JOIN 
                        ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID JOIN 
                        ORDERS AS ORD ON ORR.ORDER_ID = ORD.ORDER_ID
                    WHERE 
                    	SHIP_RESULT_ID IN(#shipping_id_list_1#)
                    GROUP 
                    	BY ORD.ORDER_ID, ORD.ORDER_HEAD
                </cfquery>
                <cfif get_orders.recordcount>
                    <cfset login_user = 
                        {
                            "apiKey": "xC4dxVZOKkOSwG2FzmBM5A",
                            "secretKey": "AjnA_nVfgE6ooubti3qFyQ",
                            "emailOrPhone": "api@bofigo.com",
                            "password": "HK524236"
                        }
                    />
                    <cfhttp url="https://www.bofigo.com/api/customer/login" result="response" charset="utf-8" method="post">
                        <cfhttpparam type="header" name="Content-Type" value="application/json" />
                        <cfhttpparam type="body" value="#replace(serializeJSON(login_user),"//","")#">
                    </cfhttp>
                    <cfset errorOrderList = "" />
                    <cfif response.Statuscode eq '200 OK'>
                        <cfset responseObj = deserializeJSON(response.Filecontent) />
                        <cfif responseObj.success>
                            <cfoutput query = "get_orders">
                                <!--- Siparişin durumu kontrol edilir --->
                                <cfhttp url="https://www.bofigo.com/adminapi/order/detail" result="order_response" charset="utf-8" method="get">
                                    <cfhttpparam type="header" name="Authorization" value="Bearer #responseObj.data.token#">
                                    <cfhttpparam type="header" name="User-Agent" value="faprika-eticaret">
                                    <cfhttpparam type="url" name="orderNumber" value="#ORDER_HEAD#">
                                </cfhttp>
                                <cfif order_response.Statuscode eq '200 OK'>
                                    <!--- Siparişin durumu değiştiriliyor --->
                                    <cfset order_responseObj = deserializeJSON(order_response.Filecontent) />
                                    <cfif order_responseObj.success and order_responseObj.data.orderStatus eq 'Onaylandı'>
                                        <cfhttp url="https://www.bofigo.com/adminapi/order/change-order-status" result="order_change_response" charset="utf-8" method="put">
                                            <cfhttpparam type="header" name="Authorization" value="Bearer #responseObj.data.token#">
                                            <cfhttpparam type="header" name="User-Agent" value="faprika-eticaret">
                                            <cfhttpparam type="url" name="orderNumber" value="#ORDER_HEAD#">
                                            <cfhttpparam type="url" name="orderStatusId" value="9">
                                        </cfhttp>
                                        <cfset order_change_responseObj = deserializeJSON(order_change_response.Filecontent) />
                                        <cfif order_change_responseObj.success>
                                            <cfquery name="update_order" datasource="#DSN3#">
                                                UPDATE 
                                                	ORDERS 
                                               	SET 
                                                	IS_SEND_WEBSERVICE = 1 
                                               	WHERE 
                                                	ORDER_ID = #ORDER_ID#
                                            </cfquery>
                                        <cfelse>
                                            <cfset errorOrderList = listAppend(errorOrderList, ORDER_HEAD) />
                                        </cfif>
                                    </cfif>
                                </cfif>
                            </cfoutput>
                        </cfif>
                    </cfif>
                </cfif>
            </cfif>
        </cfif>
  	</cftransaction>
</cflock>
<script language="javascript">
    <cfif listLen(errorOrderList)>
        alert("Sipariş Durumları Güncellenemedi: <cfoutput>#errorOrderList#</cfoutput>");
    </cfif>
	wrk_opener_reload();
   	window.close();
</script>
