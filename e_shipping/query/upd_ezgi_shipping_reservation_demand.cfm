<cftransaction>
    <cfquery name="upd_demand" datasource="#dsn3#">
        UPDATE 
            EZGI_SHIPPING_DEMAND
        SET          
             
            <cfif not isdefined('attributes.status_type')>
                SHIPPING_DEMAND_STAGE = #attributes.process_stage#,
                DETAIL = #attributes.detail#
            <cfelse>
                SHIPPING_DEMAND_STAGE = #attributes.process_stage#,
                FINISH_DATE = #now()#, 
                DEMAND_STATUS_ID = #attributes.status_type#,
                DETAIL = <cfif len(attributes.detail)>'#attributes.detail#'<cfelse>NULL</cfif>
            </cfif>
            
        WHERE  
            SHIPPING_DEMAND_ID = #attributes.SHIPPING_DEMAND_ID#
    </cfquery>
    
    <cfif isdefined('attributes.status_type') and attributes.status_type eq 2> <!---Eğer Kabul İse--->
    	<!---İzin Verilen Kaydı Sevk İse Açık Hale Getiriyorum--->
        <cfquery name="upd_order" datasource="#dsn3#">
            UPDATE 
                ORDER_ROW
            SET          
                ORDER_ROW_CURRENCY = -1
            WHERE  
                ORDER_ROW_ID = #attributes.demand_order_row_id# AND 
                ORDER_ROW_CURRENCY = -6
        </cfquery>
        
        <!---Talep Edilen Miktar ile Kabul Edilmişler Alınıyor.--->
        <cfquery name="get_demands" datasource="#dsn3#">
        	SELECT 
            	ORR.QUANTITY, 
                ORR.ORDER_ROW_ID, 
                SUM(ORR1.QUANTITY) AS DEMAND_QUANTITY
			FROM     
            	ORDER_ROW AS ORR INNER JOIN
                EZGI_SHIPPING_DEMAND AS E ON ORR.ORDER_ROW_ID = E.ORDER_ROW_ID INNER JOIN
                ORDER_ROW AS ORR1 ON E.DEMAND_ORDER_ROW_ID = ORR1.ORDER_ROW_ID
			WHERE  
            	ORR.ORDER_ROW_ID = #attributes.demand_order_row_id#
                AND ORR1.ORDER_ROW_CURRENCY = - 1
			GROUP BY 
            	ORR.QUANTITY, 
                ORR.ORDER_ROW_ID
        </cfquery>
		<cfif get_demands.recordcount and get_demands.QUANTITY lte get_demands.DEMAND_QUANTITY>
        	<!---Eğer Talep Edilen Miktar Kadar Talepler Onaylanmışsa veya (İlgili sipariş satırı Açık ise) Talep edilen sipariş satırı Sevk Aşamasına getirilir.--->
            <cfquery name="upd_demand_order" datasource="#dsn3#">
                UPDATE 
                    ORDER_ROW
                SET          
                    ORDER_ROW_CURRENCY = -6
                WHERE  
                    ORDER_ROW_ID = #attributes.order_row_id# AND 
                    ORDER_ROW_CURRENCY = -1
            </cfquery>
        </cfif>
    </cfif>
</cftransaction>
<script type="text/javascript">
	alert("İşlem Tamamlanmıştır");
	wrk_opener_reload();
  	window.close();
</script>