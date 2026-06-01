<!---
    File: upd_ezgi_optimization_materials.cfm
    Folder: AddOns\ezgi\e_production\query
    Author: Ezgi Yazılım
    Date: 12/12/2025
    Description: Optimizasyon Malzeme Güncelleme
--->

<cfparam name="attributes.optimization_id" default="">
<cfif len(attributes.optimization_id)>
	<cfif isdefined('attributes.is_material_cancel') and attributes.is_material_cancel eq 1>
    	<cfquery name="upd_opt" datasource="#dsn3#">
          	UPDATE 
           		EZGI_IFLOW_OPTIMIZATION
          	SET          
             	IS_MATERIAL_UPDATE = 0
         	WHERE  
           		OPTIMIZATION_ID = #attributes.optimization_id#
  		</cfquery>
        <cfquery name="upd_history" datasource="#dsn3#">
        	UPDATE 
            	PRODUCTION_ORDERS_STOCKS
			SET          
            	AMOUNT = EIH.AMOUNT,  
                PRODUCT_ID = EIH.PRODUCT_ID, 
                STOCK_ID = EIH.STOCK_ID, 
                PRODUCT_UNIT_ID = EIH.PRODUCT_UNIT_ID
			FROM     
            	EZGI_IFLOW_OPTIMIZATION_POR_STOCKS_HISTORY AS EIH INNER JOIN
                PRODUCTION_ORDERS_STOCKS ON EIH.POR_STOCK_ID = PRODUCTION_ORDERS_STOCKS.POR_STOCK_ID
         	WHERE  
            	EIH.OPTIMIZATION_ID = #attributes.optimization_id#
       	</cfquery>
        <cfquery name="del_history" datasource="#dsn3#">
        	DELETE FROM EZGI_IFLOW_OPTIMIZATION_POR_STOCKS_HISTORY WHERE OPTIMIZATION_ID = #attributes.optimization_id#
     	</cfquery>
        <script type="text/javascript">
            alert('Malzeme Geri Al İşlemi Tamamlandı')
            wrk_opener_reload();
            window.close();
        </script>
    <cfelse>
        <cfquery name="get_info" datasource="#dsn3#">
            SELECT 
                EI.STOCK_ID, 
                EI.MRP_AMOUNT, 
                EIR.STOCK_ID AS STOCK_ID2
            FROM     
                EZGI_IFLOW_OPTIMIZATION_MATERIAL AS EI INNER JOIN
                EZGI_IFLOW_OPTIMIZATION_MATERIAL_ROW AS EIR ON EI.OPTIMIZATION_MATERIAL_ID = EIR.OPTIMIZATION_MATERIAL_ID
            WHERE  
                EI.OPTIMIZATION_ID = #attributes.optimization_id# AND
                ISNULL(EI.MRP_AMOUNT,0) > 0 AND 
                (NOT (EIR.STOCK_ID IS NULL)) AND 
                (NOT (EI.STOCK_ID IS NULL))
        </cfquery>
        <cfif get_info.recordcount>
            <cfquery name="get_p_order_info" datasource="#dsn3#">
                SELECT DISTINCT 
                    EIOR.IFLOW_P_ORDER_ID
                FROM     
                    EZGI_IFLOW_OPTIMIZATION AS EIO INNER JOIN
                    EZGI_IFLOW_OPTIMIZATION_ROW AS EIOR ON EIO.OPTIMIZATION_ID = EIOR.OPTIMIZATION_ID
                WHERE  
                    EIO.OPTIMIZATION_ID = #attributes.optimization_id# AND 
                    NOT (EIOR.IFLOW_P_ORDER_ID IS NULL)
            </cfquery>
            <cfif get_p_order_info.recordcount>
            <cftransaction>
                <cfloop query="get_info">
                    <cfquery name="get_new_amount" datasource="#dsn3#">
                        SELECT 
                            COUNT(*) AS NEW_AMOUNT
                        FROM     
                            EZGI_IFLOW_OPTIMIZATION_RESULTS
                        WHERE  
                            OPTIMIZATION_ID = #attributes.optimization_id# AND 
                            IS_VIRTUAL_MATERIAL = 0 AND 
                            STOCK_ID = #get_info.STOCK_ID2#
                    </cfquery>
                    <cfif get_new_amount.recordcount>
                        <cfset attributes.optimization = 1>
                        <cfset attributes.record_num = 1>
                        <cfset  attributes.row_kontrol1 = 1>
                        <cfset attributes.sid = get_info.STOCK_ID>
                        <cfset attributes.plan_demand = TlFormat(get_info.MRP_AMOUNT,4)>
                        <cfset attributes.stock_id1 = get_info.STOCK_ID2>
                        <cfset attributes.plan_demand_1 = TlFormat(get_new_amount.NEW_AMOUNT,4)>
                        <cfset attributes.iid = ValueList(get_p_order_info.IFLOW_P_ORDER_ID)>
                        <cfinclude template="upd_ezgi_production_material.cfm">
                   </cfif> 
                </cfloop>
                <cfquery name="upd_opt" datasource="#dsn3#">
                    UPDATE 
                        EZGI_IFLOW_OPTIMIZATION
                    SET          
                        IS_MATERIAL_UPDATE =1
                    WHERE  
                        OPTIMIZATION_ID = #attributes.optimization_id#
                </cfquery>
            </cftransaction>
            <cfelse>
                <script type="text/javascript">
                    alert('Optimizasyona Bağlı Üretim Emirleri Başka Bir Ortamda Silinmiştir!!!')
                    window.close();
                </script>
            </cfif>
        </cfif>
        <script type="text/javascript">
            alert('Malzeme Güncelleme İşlemi Tamamlandı')
            wrk_opener_reload();
            window.close();
        </script>
    </cfif>
<cfelse>
	<script type="text/javascript">
        alert('Optimizayon İşleminde Hata Var. Kontrol Ediniz!!')
        window.close();
    </script>
</cfif>