<!---
    File: upd_ezgi_production_order_from_iflow_master.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cflock name="#CreateUUID()#" timeout="60">
  	<cftransaction>
        <cfquery name="upd_p_order_row" datasource="#dsn3#"> <!---Satırda Bilgiler Değişmişse--->
            UPDATE   
                EZGI_IFLOW_PRODUCTION_ORDERS
            SET
                DETAIL = '#Evaluate('attributes.detail#i#')#', 
                QUANTITY = #FilterNum(Evaluate('attributes.quantity#i#'),2)#,
                UPDATE_IP = '#cgi.remote_addr#', 
                UPDATE_EMP = #session.ep.userid#, 
                UPDATE_DATE = #now()#
            WHERE 
                IFLOW_P_ORDER_ID = #ListGetAt(attributes.iflow_p_order_id_list,i)#   
        </cfquery>
        
        <cfset new_quantity_rate = (filternum(attributes.quantity,8)/filternum(attributes.old_quantity,8))>
        <cfquery name="add_production_order_related" datasource="#dsn3#">
            UPDATE
                PRODUCTION_ORDERS
            SET
                QUANTITY =  Round(QUANTITY*#new_quantity_rate#,8)
            WHERE 
                P_ORDER_ID IN (#related_production_list#)
        </cfquery>
        
        <cfquery name="add_production_order_related" datasource="#dsn3#">
            UPDATE 
                PRODUCTION_OPERATION
            SET
                AMOUNT =  Round(AMOUNT*#new_quantity_rate#,8)
            WHERE 
                P_ORDER_ID IN (#related_production_list#)
        </cfquery>
        <cfquery name="upd_related_production_amount_sarf" datasource="#dsn3#">
            UPDATE
                PRODUCTION_ORDERS_STOCKS
            SET
                AMOUNT =  Round(AMOUNT*#new_quantity_rate#,8)
            WHERE 
                P_ORDER_ID IN (#related_production_list#)
        </cfquery>
        <cfquery name="GET_PAPER" datasource="#dsn3#">
            SELECT P_ORDER_NO,P_ORDER_ID FROM PRODUCTION_ORDERS WHERE P_ORDER_ID = #ListGetAt(related_production_list,1,',')#
        </cfquery>
        
	</cftransaction>
</cflock>