<cfif attributes.type eq 21> <!---Depodan Seri Nolu--->
	<cfset production_control = 1> <!---Üretim Kontrol--->
	<cfquery name="get_CONTROL" datasource="#dsn3#">
    	SELECT 
        	EWM.ORDER_ROW_ID, 
            O.ORDER_NUMBER
		FROM     
        	PRODUCTION_ORDERS AS PO INNER JOIN
            PRODUCTION_ORDERS_ROW AS EWM ON PO.P_ORDER_ID = EWM.PRODUCTION_ORDER_ID LEFT OUTER JOIN
            ORDERS AS O INNER JOIN
            ORDER_ROW AS ORR ON O.ORDER_ID = ORR.ORDER_ID ON EWM.ORDER_ROW_ID = ORR.ORDER_ROW_ID
		WHERE  
        	EWM.SERIAL_NO = '#attributes.p_order_id#'
	</cfquery>
    <cfif not get_CONTROL.recordcount>
    	<!---<script type="text/javascript">
			alert("PRODUCTION_ORDERS_ROW tablosunda Kayıt Bulunamadı Lütfen Sistem Yöneticinize Başvurun!");
			window.location ="<cfoutput>#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id?#attributes.order_id#</cfoutput>";
		</script>
     	<cfabort>--->
        <cfset production_control = 0>
    <cfelseif get_CONTROL.recordcount and len(get_CONTROL.ORDER_NUMBER)>
     	<script type="text/javascript">
			alert("<cfoutput>#get_CONTROL.ORDER_NUMBER#</cfoutput> Nolu Siparişe Rezerve edilmiştir.!");
			window.location ="<cfoutput>#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id?#attributes.order_id#</cfoutput>";
		</script>
     	<cfabort>
    </cfif>   
	<cfquery name="ADD_ROW" datasource="#DSN3#">
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
            	'#attributes.p_order_id#',
                #attributes.order_row_id#,
                #now()#,
                '#CGI.REMOTE_ADDR#',
                #session.ep.userid#
          	)
 	</cfquery>   
    <cfif production_control eq 1>
        <cfquery name="UPD_ROW" datasource="#DSN3#">
            UPDATE PRODUCTION_ORDERS_ROW SET ORDER_ROW_ID = #attributes.order_row_id# WHERE SERIAL_NO = '#attributes.p_order_id#'
        </cfquery>
    </cfif>
    <cfquery name="get_order_row_info" datasource="#dsn3#">
    	SELECT QUANTITY, ORDER_ROW_CURRENCY FROM ORDER_ROW WHERE ORDER_ROW_ID = #attributes.order_row_id#
    </cfquery>
    <cfif get_order_row_info.recordcount and (get_order_row_info.ORDER_ROW_CURRENCY eq -1 or get_order_row_info.ORDER_ROW_CURRENCY eq -5)> <!---Sipariş Satırı Açık veya Üretim ise--->
        <cfquery name="get_serial_order_row" datasource="#dsn3#">
            SELECT COUNT(*) AS SAYI FROM EZGI_WM_SERIAL_NO_ORDER_ACTION WHERE ORDER_ROW_ID = #attributes.order_row_id#
        </cfquery>
        <cfif get_serial_order_row.recordcount and get_serial_order_row.SAYI gte get_order_row_info.QUANTITY> <!---Seri No Sipariş Miktarı Kadar Ayrılmışsa Satırı sevk Yap--->
            <cfquery name="upd_order_row_currency" datasource="#dsn3#">
                UPDATE 
                	ORDER_ROW
              	SET
                	ORDER_ROW_CURRENCY = -6
             	WHERE
                    ORDER_ROW_ID = #attributes.order_row_id#
            </cfquery>
        </cfif>
    </cfif>
<cfelseif attributes.type eq 11> <!---Üretimden Seri Nolu--->
	<cfquery name="get_CONTROL" datasource="#dsn3#">
		SELECT 
        	E.PRODUCTION_ORDER_ROW_ID, 
            O.ORDER_NUMBER, 
            E.SERIAL_NO
		FROM     
        	ORDERS AS O INNER JOIN
            ORDER_ROW AS ORR ON O.ORDER_ID = ORR.ORDER_ID RIGHT OUTER JOIN
            PRODUCTION_ORDERS_ROW AS E ON ORR.ORDER_ROW_ID = E.ORDER_ROW_ID
		WHERE  
        	E.PRODUCTION_ORDER_ROW_ID = #attributes.p_order_id#
	</cfquery>
    <cfif get_CONTROL.recordcount>
    	<cfif len(get_CONTROL.ORDER_NUMBER)>
        	<script type="text/javascript">
				alert("<cfoutput>#get_CONTROL.ORDER_NUMBER#</cfoutput> Nolu Siparişe Rezerve edilmiştir.!");
				window.location ="<cfoutput>#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id?#attributes.order_id#</cfoutput>";
			</script>
            <cfabort>
        <cfelseif len(get_CONTROL.SERIAL_NO)>
        	<script type="text/javascript">
				alert("<cfoutput>#get_CONTROL.SERIAL_NO#</cfoutput> Nolu Seri No ile Üretim Tamamlanmıştır. Lütfen Ser No ile Rezerve Ediniz.!");
				window.location ="<cfoutput>#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id?#attributes.order_id#</cfoutput>";
			</script>
            <cfabort>
        <cfelse>
        	<cfquery name="upd_rel" datasource="#dsn3#">
        		UPDATE 
                	PRODUCTION_ORDERS_ROW
				SET          
                    ORDER_ROW_ID = #attributes.order_row_id#
				WHERE  
                	PRODUCTION_ORDER_ROW_ID = #attributes.p_order_id# 
       		</cfquery>             
            <script type="text/javascript">
				alert("İşlem Tamamlanmıştır");
				window.location ="<cfoutput>#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id?#attributes.order_id#</cfoutput>";
			</script>	
        </cfif>
    <cfelse>
    	<script type="text/javascript">
			alert("İşlem Yapılamadı");
			window.location ="<cfoutput>#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id?#attributes.order_id#</cfoutput>";
		</script>
     	<cfabort>
    </cfif>  
<cfelseif attributes.type eq 1>
	<cfquery name="get_info" datasource="#dsn3#">
    	SELECT     
        	FINISH_DATE,
            IS_STAGE
		FROM         
        	PRODUCTION_ORDERS
		WHERE     
        	P_ORDER_ID = #attributes.p_order_id#
    </cfquery>
    <cfquery name="get_p_order_id" datasource="#dsn3#">
    	SELECT     
        	P_ORDER_ID
		FROM         
        	PRODUCTION_ORDERS
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
    <cfloop list="#p_order_id_list#" index="i">
        <cfquery name="ADD_ROW" datasource="#DSN3#">
            INSERT INTO
                PRODUCTION_ORDERS_ROW
                (
                PRODUCTION_ORDER_ID,
                ORDER_ID,
                ORDER_ROW_ID,
                TYPE 
                )
            VALUES
                (
                #i#,
                #attributes.order_id#,
                #attributes.order_row_id#,
                1
                )
        </cfquery>
   	</cfloop>
    <cfif get_info.IS_STAGE eq 2>
    	<cfquery name="upd_order_currency" datasource="#dsn3#">
        	UPDATE 
            	ORDER_ROW
			SET          
            	ORDER_ROW_CURRENCY = -6
			WHERE  
            	ORDER_ROW_ID = #attributes.order_row_id#
                AND ORDER_ROW_CURRENCY NOT IN (-8,-9,-10,-3)
        </cfquery>
    </cfif>
<cfelseif attributes.type eq 6>
    <cfquery name="get_p_order_id" datasource="#dsn3#">
    	SELECT  DISTINCT   
        	P_ORDER_ID
		FROM         
        	PRODUCTION_ORDERS
		WHERE     
        	LOT_NO = (
            			SELECT 
                        	LOT_NO
						FROM     
                        	EZGI_IFLOW_PRODUCTION_ORDERS
						WHERE  
                        	IFLOW_P_ORDER_ID = #attributes.p_order_id#
                  	)
    </cfquery>
    <cfset p_order_id_list = Valuelist(get_p_order_id.P_ORDER_ID)>
    <cfloop list="#p_order_id_list#" index="i">
        <cfquery name="ADD_ROW" datasource="#DSN3#">
            INSERT INTO
                PRODUCTION_ORDERS_ROW
                (
                PRODUCTION_ORDER_ID,
                ORDER_ID,
                ORDER_ROW_ID,
                TYPE 
                )
            VALUES
                (
                #i#,
                #attributes.order_id#,
                #attributes.order_row_id#,
                1
                )
        </cfquery>
   	</cfloop>
<cfelse>
	<cfquery name="get_info" datasource="#dsn3#">
    	SELECT     
        	ORDER_ID,
            QUANTITY,
           	DELIVER_DATE FINISH_DATE
		FROM         
        	ORDER_ROW
		WHERE     
        	ORDER_ROW_ID = #attributes.P_ORDER_ID#
    </cfquery>
    <cfquery name="GET_S_ROW_INFO" datasource="#DSN3#">
    	SELECT     
        	QUANTITY, 
            WRK_ROW_ID
		FROM         
        	ORDER_ROW
		WHERE     
        	ORDER_ROW_ID = #attributes.order_row_id#
    </cfquery>
    <cfif get_info.QUANTITY eq GET_S_ROW_INFO.QUANTITY>
    	<cfquery name="upd_p_order_row" datasource="#dsn3#">
        	UPDATE    
            	ORDER_ROW
			SET              
            	WRK_ROW_RELATION_ID = '#GET_S_ROW_INFO.WRK_ROW_ID#'
			WHERE     
            	ORDER_ROW_ID = #attributes.p_order_id# AND 
                QUANTITY = #GET_S_ROW_INFO.QUANTITY#
        </cfquery>
    <cfelse>
        <cfquery name="ADD_ROW" datasource="#DSN3#">
            INSERT INTO 
                EZGI_ORDERS_ORDERS_REL
                (
                P_ORDER_ID, 
                P_ORDER_ROW_ID, 
                S_ORDER_ROW_ID, 
                S_ORDER_ID, 
                RECORD_DATE, 
                RECORD_IP, 
                RECORD_EMP
                )
            VALUES
                (
                #get_info.ORDER_ID#,
                #attributes.p_order_id#,
                #attributes.order_row_id#,
                #attributes.order_id#,
                #now()#,
                '#CGI.REMOTE_ADDR#',
                #session.ep.userid#
                )
        </cfquery>
   	</cfif>
</cfif>
<cfif isdefined('attributes.planning')>
	<cflocation url="#request.self#?fuseaction=sales.popup_list_order_production_rate&planning=1&order_id=#attributes.order_id#" addtoken="no">
<cfelse>
	<cflocation url="#request.self#?fuseaction=sales.popup_list_order_production_rate&order_id=#attributes.order_id#" addtoken="no">
</cfif>