<cfif isdefined('attributes.upd_deliver_date')>
	<cf_date tarih='attributes.upd_deliver_date'>
	<cfquery name="upd_order" datasource="#dsn3#">
    	UPDATE
        	ORDERS
      	SET
        	DELIVERDATE = #attributes.upd_deliver_date#
      	WHERE
        	ORDER_ID = #attributes.order_id#
    </cfquery>
<cfelse>
	<cfif attributes.type eq 2 or attributes.type eq 1>
    	<cfquery name="upd_order_row" datasource="#dsn3#"> <!---Sipariş Satır Açıklamalarını Üretim Emir Açıklamasına Geçiriyoruz--->
        	UPDATE 
            	PRODUCTION_ORDERS
			SET          
            	DETAIL =  O.ORDER_NUMBER+' - '+ORR.PRODUCT_NAME2
			FROM     
            	PRODUCTION_ORDERS INNER JOIN
                PRODUCTION_ORDERS_ROW AS PORR ON PRODUCTION_ORDERS.P_ORDER_ID = PORR.PRODUCTION_ORDER_ID INNER JOIN
                ORDER_ROW AS ORR ON PORR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID
			WHERE  
            	PORR.ORDER_ID = #attributes.order_id# AND 
                PORR.ORDER_ROW_ID = #attributes.order_row_id# AND 
                LEN(ORR.PRODUCT_NAME2) > 0
        </cfquery>
        <cfquery name="get_p_order_id" datasource="#dsn3#">
            SELECT     
                P_ORDER_ID
            FROM         
                PRODUCTION_ORDERS WITH (NOLOCK)
            WHERE     
                LOT_NO = (
                            SELECT     
                                LOT_NO
                            FROM          
                                PRODUCTION_ORDERS AS PRODUCTION_ORDERS_1
                            WHERE      
                                P_ORDER_ID = #attributes.p_order_id#
                        )
        </cfquery>
        <cfset p_order_id_list = Valuelist(get_p_order_id.P_ORDER_ID)>
        <cfquery name="DEL_ROW" datasource="#DSN3#">
            DELETE
                PRODUCTION_ORDERS_ROW
            WHERE
                PRODUCTION_ORDER_ID IN (#p_order_id_list#) AND
                ORDER_ID = #attributes.order_id# AND
                ORDER_ROW_ID = #attributes.order_row_id# 
        </cfquery>
    <cfelseif attributes.type eq 4>
    	<cfquery name="upd_order_row" datasource="#dsn3#"> <!---Sipariş Satır Açıklamalarını Üretim Emir Açıklamasına Geçiriyoruz--->
        	UPDATE 
            	PRODUCTION_ORDERS
			SET          
            	DETAIL = ORR.PRODUCT_NAME2 + ' - ' + O.ORDER_NUMBER + ' - ' + PRODUCTION_ORDERS.DETAIL
			FROM     
            	PRODUCTION_ORDERS INNER JOIN
                PRODUCTION_ORDERS_ROW AS PORR ON PRODUCTION_ORDERS.P_ORDER_ID = PORR.PRODUCTION_ORDER_ID INNER JOIN
                ORDER_ROW AS ORR ON PORR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID
			WHERE  
            	PORR.ORDER_ID = #attributes.order_id# AND 
                PORR.ORDER_ROW_ID = #attributes.order_row_id# AND 
                LEN(ORR.PRODUCT_NAME2) > 0
        </cfquery>
        <cfquery name="DEL_ROW" datasource="#DSN3#">
            DELETE 
                EZGI_ORDERS_ORDERS_REL
            WHERE     
                S_ORDER_ID = #attributes.order_id# AND
                S_ORDER_ROW_ID = #attributes.order_row_id#
        </cfquery>
    <cfelseif attributes.type eq 6>
    	<cfquery name="get_p_order_id" datasource="#dsn3#">
            SELECT  DISTINCT   
                P_ORDER_ID
            FROM         
                PRODUCTION_ORDERS WITH (NOLOCK)
            WHERE     
                LOT_NO = (
                            SELECT 
                                LOT_NO
                            FROM     
                                EZGI_IFLOW_PRODUCTION_ORDERS WITH (NOLOCK)
                            WHERE  
                                IFLOW_P_ORDER_ID = #attributes.p_order_id#
                        )
        </cfquery>
    	<cfset p_order_id_list = Valuelist(get_p_order_id.P_ORDER_ID)>
        <cfquery name="DEL_ROW" datasource="#DSN3#">
            DELETE
                PRODUCTION_ORDERS_ROW
            WHERE
                PRODUCTION_ORDER_ID IN (#p_order_id_list#) AND
                ORDER_ID = #attributes.order_id# AND
                ORDER_ROW_ID = #attributes.order_row_id# 
        </cfquery>
    <cfelseif attributes.type eq 3>
        <cfquery name="DEL_ROW" datasource="#DSN3#">
            UPDATE    
                ORDER_ROW
            SET              
                WRK_ROW_RELATION_ID = NULL
            WHERE     
                ORDER_ROW_ID =
                            (
                            SELECT     
                                ORDER_ROW_1.ORDER_ROW_ID
                            FROM          
                                ORDER_ROW AS ORDER_ROW_2 INNER JOIN
                                ORDER_ROW AS ORDER_ROW_1 ON ORDER_ROW_2.WRK_ROW_ID = ORDER_ROW_1.WRK_ROW_RELATION_ID
                            WHERE      
                                ORDER_ROW_2.ORDER_ROW_ID = #attributes.order_row_id#
                            )
        </cfquery>  
 	<cfelseif attributes.type eq 11> <!---Üretim Seri No ---> 
    	<!---<cfquery name="GET_ORDER_CONTROL" datasource="#DSN3#"><!---Üretim-Sipariş Bağı Kontrolü Yapılıyor--->
        	SELECT 
            	PO.P_ORDER_ID, 
                O.ORDER_NUMBER
			FROM     
            	PRODUCTION_ORDERS_ROW AS E WITH (NOLOCK) INNER JOIN
                PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON E.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
                PRODUCTION_ORDERS_ROW AS PORR WITH (NOLOCK) ON PO.P_ORDER_ID = PORR.PRODUCTION_ORDER_ID INNER JOIN
                ORDER_ROW AS ORR WITH (NOLOCK) ON PORR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID
			WHERE  
            	PRODUCTION_ORDER_ROW_ID = #attributes.p_order_id#
        </cfquery>
        <cfif GET_ORDER_CONTROL.recordcount>
        	<script type="text/javascript">
             	alert("<cfoutput>#GET_ORDER_CONTROL.ORDER_NUMBER#</cfoutput> Nolu Sipariş ile Üretim Bağı Vardır. Rezerve İptal Edilemez!");
				window.close();
           	</script>
         	<cfabort>
        </cfif>--->
    	<cfquery name="GET_SERIAL" datasource="#dsn3#"><!---Seri No Oluşmuş mu--->
            SELECT SERIAL_NO FROM PRODUCTION_ORDERS_ROW WHERE PRODUCTION_ORDER_ROW_ID = #attributes.p_order_id#
        </cfquery>
        <cfif GET_SERIAL.recordcount or attributes.p_order_id eq 0> <!---Seri No Oluşmuşsa Sevkiyata Ayrılmış mı?--->
            <cfif (attributes.p_order_id gt 0 and len(GET_SERIAL.SERIAL_NO)) or (attributes.p_order_id eq 0 and len(attributes.serino))>
            	<cfif session.ep.userid eq 4><!--- Özel Yapıldı 01.10.2024 e kadar açık kalacak--->
                	<cfquery name="GET_SHIPPING_CONTROL" datasource="#dsn3#">
                        SELECT 
                            SERIAL_NO 
                        FROM 
                            EZGI_WM_SERIAL_NO_LAST_STATUS 
                        WHERE 
                            SERIAL_NO = <cfif attributes.p_order_id gt 0 and len(GET_SERIAL.SERIAL_NO)>'#GET_SERIAL.SERIAL_NO#'<cfelse>'#attributes.serino#'</cfif>
                    </cfquery>
                <cfelse>
                    <cfquery name="GET_SHIPPING_CONTROL" datasource="#dsn3#"><!--- Doğru Satır--->
                        SELECT 
                            SERIAL_NO 
                        FROM 
                            EZGI_WM_SERIAL_NO_LAST_STATUS 
                        WHERE 
                            SERIAL_NO = <cfif attributes.p_order_id gt 0 and len(GET_SERIAL.SERIAL_NO)>'#GET_SERIAL.SERIAL_NO#'<cfelse>'#attributes.serino#'</cfif> AND ISNULL(SHIP_RESULT_ID, 0) = 0
                    </cfquery>
                </cfif>
                <cfif not GET_SHIPPING_CONTROL.recordcount>
                	<script type="text/javascript">
						alert("<cfoutput>#GET_SHIPPING_CONTROL.SERIAL_NO#</cfoutput>AAAA Seri Nolu Ürün Sevkiyat İçin Transfer Alanına Alınmıştır. İlişki Silinemez!");
						window.location ="<cfoutput>#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id=#attributes.order_id#</cfoutput>";
					</script>
                    <cfabort>
              	<cfelse>
                	<cfif attributes.p_order_id gt 0>
                        <cfquery name="upd_rel" datasource="#dsn3#"><!---Üretimdeki Bağı Boşalt--->
                            UPDATE 
                                PRODUCTION_ORDERS_ROW
                            SET          
                                ORDER_ROW_ID = NULL
                            WHERE  
                                PRODUCTION_ORDER_ROW_ID = #attributes.p_order_id# 
                        </cfquery>
                    </cfif>
                	<cfquery name="ADD_ROW" datasource="#DSN3#"><!---Sipariş Seri No Bağını Boşalt--->
                        INSERT INTO 
                            EZGI_WM_SERIAL_NO_ORDER_ACTION
                            (
                                SERIAL_NO, 
                                ORDER_ROW_ID,
                                RECORD_DATE, 
                                RECORD_IP,
                                RECORD_EMP
                            )
                        VALUES 
                            (
                                '#GET_SHIPPING_CONTROL.SERIAL_NO#',
                                NULL,
                                #now()#,
                                '#CGI.REMOTE_ADDR#',
                                #session.ep.userid#
                            )
                    </cfquery>
                    <script type="text/javascript">
						alert("İşlem Tamamlanmıştır");
						window.location ="<cfoutput>#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id=#attributes.order_id#</cfoutput>";
					</script>
                </cfif>
            <cfelseif attributes.p_order_id gt 0 and not len(GET_SERIAL.SERIAL_NO)><!---Üretimden Gelecek Seri No Oluşmamışsa--->
         		<cfquery name="upd_rel" datasource="#dsn3#"> <!---Üretimdeki Bağı Boşalt--->
                 	UPDATE 
                    	PRODUCTION_ORDERS_ROW
                 	SET          
                     	ORDER_ROW_ID = NULL
                  	WHERE  
                     	PRODUCTION_ORDER_ROW_ID = #attributes.p_order_id# 
              	</cfquery>
				   
                <script type="text/javascript">
                    alert("İşlem Tamamlanmıştır");
                    window.location ="<cfoutput>#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id=#attributes.order_id#</cfoutput>";
                </script>	
            </cfif>
        <cfelse>
            <script type="text/javascript">
                alert("İşlem Yapılamadı");
                window.location ="<cfoutput>#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id=#attributes.order_id#</cfoutput>";
            </script>
            <cfabort>
        </cfif> 
    <cfelseif attributes.type eq 21> <!---Depodan Üretim Bağlantısız ---> 
    	<cfquery name="ADD_ROW" datasource="#DSN3#"><!---Sipariş Seri No Bağını Boşalt--->
        	INSERT INTO 
           		EZGI_WM_SERIAL_NO_ORDER_ACTION
             	(
                 	SERIAL_NO, 
                  	ORDER_ROW_ID,
                  	RECORD_DATE, 
                	RECORD_IP,
                 	RECORD_EMP
            	)
         	VALUES 
             	(
                	'#attributes.serino#',
                  	NULL,
                 	#now()#,
                  	'#CGI.REMOTE_ADDR#',
                  	#session.ep.userid#
            	)
   		</cfquery>
     	<script type="text/javascript">
			alert("İşlem Tamamlanmıştır");
			window.location ="<cfoutput>#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id=#attributes.order_id#</cfoutput>";
		</script>
    </cfif>
</cfif>
<cfif isdefined('attributes.planning')>
	<cflocation url="#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id=#attributes.order_id#" addtoken="no">
<cfelse>
	<cflocation url="#request.self#?fuseaction=sales.popup_list_order_production_rate&order_id=#attributes.order_id#" addtoken="no">
</cfif>