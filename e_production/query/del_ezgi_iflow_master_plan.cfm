<!---
    File: del_ezgi_iflow_master_plan.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cflock name="#CREATEUUID()#" timeout="90">
	<cftransaction>
		<cfif Len(attributes.master_plan_id)>
            <cfquery name="GET_CONTROL" datasource="#DSN3#">
                SELECT        
                    PO.P_ORDER_ID
                FROM            
                    EZGI_IFLOW_PRODUCTION_ORDERS AS E INNER JOIN
                    PRODUCTION_ORDERS AS PO ON E.LOT_NO = PO.LOT_NO
                WHERE        
                    E.MASTER_PLAN_ID = #attributes.master_plan_id#
            </cfquery>
			<cfset p_order_id_list = ValueList(GET_CONTROL.P_ORDER_ID)>
            <cfif ListLen(p_order_id_list)>
                <cfquery name="GET_RELATED_PRODUCTION_RESULT" datasource="#dsn3#">
                    SELECT P_ORDER_ID FROM PRODUCTION_ORDER_RESULTS WHERE P_ORDER_ID IN (#p_order_id_list#)
                </cfquery>
                <cfif GET_RELATED_PRODUCTION_RESULT.recordcount>
                    <script type="text/javascript">
                        alert("<cf_get_lang dictionary_id ='1078.Bu Üretim Emrinin İlişkili Olduğu Üretimlerden Sonuç Girilenler Var,Öncelikle İlişkili Üretim Emirlerinin Sonuçlarını Siliniz'>!");
                        history.go(-1);
                    </script>
                    <cfabort>
                </cfif>
                <cfquery name="DEL_ROW" datasource="#dsn3#">
                    DELETE FROM PRODUCTION_ORDERS_ROW WHERE PRODUCTION_ORDER_ID IN(#p_order_id_list#)
                </cfquery>        
                <cfquery name="DEL_PROD_ORDER" datasource="#dsn3#">
                    DELETE FROM PRODUCTION_OPERATION WHERE P_ORDER_ID IN(#p_order_id_list#)
                </cfquery>
                <cfquery name="DEL_PROD_ORDER" datasource="#dsn3#">
                    DELETE FROM PRODUCTION_ORDERS WHERE P_ORDER_ID IN(#p_order_id_list#)
                </cfquery>
                <cfquery name="DEL_PROD_ORDER_STOCKS" datasource="#dsn3#">
                    DELETE FROM PRODUCTION_ORDERS_STOCKS WHERE P_ORDER_ID IN(#p_order_id_list#)
                </cfquery>
            </cfif>
        	<cfquery name="del_operations" datasource="#dsn3#">
                DELETE 
                    EZGI_IFLOW_PRODUCTION_OPERATION
                WHERE        
                    IFLOW_P_ORDER_ID IN
                                (
                                    SELECT        
                                        IFLOW_P_ORDER_ID
                                    FROM            
                                        EZGI_IFLOW_PRODUCTION_ORDERS
                                    WHERE        
                                        MASTER_PLAN_ID = #attributes.master_plan_id#
                                )
            </cfquery>
            <cfquery name="del_p_order_row" datasource="#dsn3#">
                DELETE 
                    EZGI_IFLOW_PRODUCTION_ORDERS 
                WHERE 
                    MASTER_PLAN_ID = #attributes.master_plan_id#
            </cfquery>
            <cfquery name="del_p_order_row" datasource="#dsn3#">
                DELETE 
                    EZGI_IFLOW_MASTER_PLAN
                WHERE        
                    MASTER_PLAN_ID = #attributes.master_plan_id#
            </cfquery>
            <!---******************Seri No İçin Üretilen Kayıtlar Kalmışsa Toptan sil*********--->
            <cfquery name="DEL_PROD_ORDER_WM" datasource="#dsn3#">
                DELETE FROM 
                    PRODUCTION_ORDERS_ROW
                WHERE  
                    PRODUCTION_ORDER_ROW_ID IN
                                          (
                                            SELECT 
                                                E.PRODUCTION_ORDER_ROW_ID
                                            FROM      
                                                PRODUCTION_ORDERS_ROW AS E LEFT OUTER JOIN
                                                PRODUCTION_ORDERS AS PO ON E.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
                                            WHERE   
                                                (PO.P_ORDER_ID IS NULL)
                                            )
                            
            </cfquery>
            <!---******************Seri No İçin Üretilen Kayıtlar Kalmışsa Toptan sil*********--->
        </cfif>
    </cftransaction>
</cflock>
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_iflow_master_plan" addtoken="No">