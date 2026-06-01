<!---
    File: del_ezgi_iflow_production_order.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---><cfset attributes.iflow_master_plan_id = attributes.master_plan_id>
<cfquery name="get_general_info" datasource="#dsn#">
	SELECT ISNULL(IS_SERIAL_CONTROL_LOCATION,0) AS IS_SERIAL_CONTROL_LOCATION FROM OUR_COMPANY_INFO WHERE COMP_ID = #session.ep.company_id#
</cfquery>
<cflock name="#CREATEUUID()#" timeout="90">
    <cftransaction>
    	<cfquery name="GET_CONTROL" datasource="#DSN3#"><!---Pariye Bağlı Workcube Üretim Planları Sorguluyorum--->
        	SELECT        
          		PO.P_ORDER_ID
          	FROM            
            	EZGI_IFLOW_PRODUCTION_ORDERS AS E INNER JOIN
             	PRODUCTION_ORDERS AS PO ON E.LOT_NO = PO.LOT_NO
          	WHERE        
             	E.REL_P_ORDER_ID= #attributes.rel_p_order_id#
      	</cfquery>
		<cfset p_order_id_list = ValueList(GET_CONTROL.P_ORDER_ID)>
        <cfif ListLen(p_order_id_list)><!---Pariye Bağlı Workcube Üretim Planları Varsa--->
            <cfquery name="GET_RELATED_PRODUCTION_RESULT" datasource="#dsn3#"><!---Sonuç Girilmiş Planlar Var mı--->
                SELECT P_ORDER_ID FROM PRODUCTION_ORDER_RESULTS WHERE P_ORDER_ID IN (#p_order_id_list#)
            </cfquery>
            <cfif GET_RELATED_PRODUCTION_RESULT.recordcount>
                <script type="text/javascript">
                    alert("<cf_get_lang dictionary_id ='1078.Bu Üretim Emrinin İlişkili Olduğu Üretimlerden Sonuç Girilenler Var,Öncelikle İlişkili Üretim Emirlerinin Sonuçlarını Siliniz'>!");
                    history.go(-1);
                </script>
                <cfabort>
            <cfelse><!---Sonuç Girilmiş Planlar Yoksa--->
                <cfquery name="DEL_ROW" datasource="#dsn3#"> <!---Workcube Üretim Planı ile Sipariş İlişkilerini Sil--->
                    DELETE FROM PRODUCTION_ORDERS_ROW WHERE PRODUCTION_ORDER_ID IN(#p_order_id_list#)
                </cfquery>        
                <cfquery name="DEL_PROD_ORDER" datasource="#dsn3#"> <!---Workcube Üretim Planına Bağlı Operasyonları Sil--->
                    DELETE FROM PRODUCTION_OPERATION WHERE P_ORDER_ID IN(#p_order_id_list#)
                </cfquery>
                <cfquery name="DEL_PROD_ORDER" datasource="#dsn3#"><!---Workcube Üretim Planlarını Sil--->
                    DELETE FROM PRODUCTION_ORDERS WHERE P_ORDER_ID IN(#p_order_id_list#)
                </cfquery>
                <cfquery name="DEL_PROD_ORDER_STOCKS" datasource="#dsn3#"><!---Workcube Üretim Planı Sarflarını Sil--->
                    DELETE FROM PRODUCTION_ORDERS_STOCKS WHERE P_ORDER_ID IN(#p_order_id_list#)
                </cfquery>
            </cfif>
       	</cfif>
    	
     	<cfquery name="del_p_order_row" datasource="#dsn3#"><!---Parti Üretim Planlarını Sil--->
          	DELETE 
            	EZGI_IFLOW_PRODUCTION_ORDERS 
           	WHERE 
            	REL_P_ORDER_ID = #attributes.rel_p_order_id#
    	</cfquery>
        <cfquery name="del_p_order_row" datasource="#dsn3#"><!---Partiyi Sil--->
          	DELETE 
            	EZGI_IFLOW_PRODUCTION_ORDERS_PARTI
           	WHERE 
            	P_ORDER_PARTI_ID = #attributes.rel_p_order_id#
    	</cfquery>
        <cfif get_general_info.IS_SERIAL_CONTROL_LOCATION>
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
         <cfquery name="GET_MASTER_PLAN_INFO" datasource="#DSN3#">
            SELECT MASTER_PLAN_PROCESS, MASTER_PLAN_CAT_ID FROM EZGI_IFLOW_MASTER_PLAN WHERE MASTER_PLAN_ID = #attributes.master_plan_id#
        </cfquery>
        <cfinclude template="upd_ezgi_iflow_production_parti_operations.cfm"> <!---Düzenlenen Master Plan İçin Yeniden Üretim Zamanı Hesaplama İşlemine Gidiyor--->
    </cftransaction>
</cflock>
<cfinclude template="upd_ezgi_iflow_master_plan_operation.cfm">
<script type="text/javascript">
 	alert('<cf_get_lang dictionary_id='654.Parti Tamamen Silinmiştir'>!');
   	wrk_opener_reload();
  	window.close();
</script>
