<!---
    File: trf_ezgi_iflow_production_order_parti.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/11/2024
    Description:
--->
<cfif ListLen(attributes.iflow_parti_list)>
	<cfset attributes.iflow_master_plan_id = attributes.master_plan_id>
	<cfquery name="get_max_parti" datasource="#dsn3#"><!---Hedef Master Plandaki En Büyük Parti Sırasını Buluyorum--->
      	SELECT        
        	TOP (1) ISNULL(P_ORDER_PARTI_SORT_NO,0) AS PARTI_SORT_NO
       	FROM            
         	EZGI_IFLOW_PRODUCTION_ORDERS AS EIPO INNER JOIN
         	EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPOP ON EIPO.REL_P_ORDER_ID = EIPOP.P_ORDER_PARTI_ID
       	WHERE        
        	EIPO.MASTER_PLAN_ID = #attributes.master_plan_id#
       	ORDER BY
         	P_ORDER_PARTI_SORT_NO desc
  	</cfquery>
    <cftransaction>
        <cfquery name="get_parti" datasource="#dsn3#"><!---Kaynak Parti İçinde Üretim Planı Varmı--->
            SELECT        
                EIPO.IFLOW_P_ORDER_ID, 
                EIPO.MASTER_PLAN_ID
            FROM            
                EZGI_IFLOW_PRODUCTION_ORDERS AS EIPO INNER JOIN
                EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPOP ON EIPO.REL_P_ORDER_ID = EIPOP.P_ORDER_PARTI_ID
            WHERE        
                EIPOP.P_ORDER_PARTI_ID IN (#attributes.iflow_parti_list#)
        </cfquery>
        <cfif get_parti.recordcount><!---Kaynak Parti İçinde Üretim Planı Var ise--->
        	<cfset iflow_p_order_id_list = ValueList(get_parti.IFLOW_P_ORDER_ID)> 
            <cfset source_master_plan_id = get_parti.MASTER_PLAN_ID> <!---Kaynak Master_Plan_Id alınıyor Kural Gereği Sadece 1 Tane Geliyor. --->
        	<cfquery name="get_master_plan_info" datasource="#dsn3#"> <!---Hedef Master Plan Bilgileri Alınıyor--->
                SELECT  
                	MASTER_PLAN_ID, 
                    MASTER_PLAN_START_DATE, 
                    MASTER_PLAN_FINISH_DATE, 
                    MASTER_PLAN_CAT_ID, 
                    MASTER_PLAN_NAME, 
                    MASTER_PLAN_NUMBER, 
                    MASTER_PLAN_DETAIL
				FROM            
                	EZGI_IFLOW_MASTER_PLAN
				WHERE        
                	MASTER_PLAN_ID = #attributes.master_plan_id#
            </cfquery>
            <cfif get_max_parti.recordcount>
        		<cfset max_parti_sort_no = get_max_parti.PARTI_SORT_NO>
            <cfelse>
            	<cfset max_parti_sort_no = 1>
            </cfif>
        	<cfloop list="#attributes.iflow_parti_list#" index="i"> <!---Seçilen Partiler Hedef Master Plan İçinde Son Sıraya Alınıyor ve Master Plan Tarihleri veriliyor--->
        		<cfset max_parti_sort_no = max_parti_sort_no + 1>
                <cfquery name="upd_parti_new_sort_no" datasource="#dsn3#">
                	UPDATE
                    	EZGI_IFLOW_PRODUCTION_ORDERS_PARTI
					SET          
                    	P_ORDER_PARTI_SORT_NO = #max_parti_sort_no#,
                        P_ORDER_START_DATE = '#get_master_plan_info.MASTER_PLAN_START_DATE#', 
                        P_ORDER_FINISH_DATE = '#get_master_plan_info.MASTER_PLAN_FINISH_DATE#'
					WHERE  
                    	P_ORDER_PARTI_NUMBER = #i#
                </cfquery> 
        	</cfloop>
            <cfquery name="upd_parti" datasource="#dsn3#"> <!--- Taşınan Partilerin Emirlerini Yeni Master Palana Güncelliyorum--->
                UPDATE       
                    EZGI_IFLOW_PRODUCTION_ORDERS
                SET                
                    MASTER_PLAN_ID = #attributes.master_plan_id#
                WHERE        
                    IFLOW_P_ORDER_ID IN (#iflow_p_order_id_list#)
            </cfquery>
            
            <cfinclude template="upd_ezgi_iflow_production_parti_operations.cfm"> <!---Hedef Master Plan İçin Üretim Zamanı Hesaplama İşlemine Gidiyor--->
            
			<!---Kaynak Master Plan Tanımlamaları Yapılıyor--->
            <cfset attributes.master_plan_id = source_master_plan_id>
			<cfset attributes.iflow_master_plan_id = attributes.master_plan_id>
            <cfinclude template="upd_ezgi_iflow_production_parti_operations.cfm"> <!---Kaynak Master Plan İçin Üretim Zamanı Hesaplama İşlemine Gidiyor--->
        </cfif>
    </cftransaction>
    <script type="text/javascript">
		alert('Seçilen Partilerin Taşıma İşlemi Başarıyla Tamamlanmıştır');
		wrk_opener_reload();
		window.close();
	</script>
</cfif>