<!---
    File: upd_ezgi_production_material.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset new_stock_id_list = ''>
<cfset new_amount_list = ''>
<cfloop from="1" to="#attributes.record_num#" index="i"> <!---Satırlar Döndürülüyor--->
   	<cfif Evaluate('attributes.row_kontrol#i#') eq 1>
    	<cfset new_stock_id = Evaluate('attributes.stock_id#i#')>
    	<cfset new_stock_id_list = ListAppend(new_stock_id_list,new_stock_id)>	
        <cfset new_amount = FilterNum(Evaluate('attributes.plan_demand_#i#'),4)>
        <cfset new_amount_list = ListAppend(new_amount_list,new_amount)>
    </cfif>
</cfloop>
<cfquery name="get_p_orders" datasource="#dsn3#">
	SELECT 
    	PO.P_ORDER_ID
	FROM     
    	EZGI_IFLOW_PRODUCTION_ORDERS AS E INNER JOIN
        PRODUCTION_ORDERS AS PO ON E.LOT_NO = PO.LOT_NO INNER JOIN
        PRODUCTION_ORDERS_STOCKS POS ON PO.P_ORDER_ID = POS.P_ORDER_ID
	WHERE  
    	E.IFLOW_P_ORDER_ID IN (#attributes.iid#) AND 
        POS.STOCK_ID = #attributes.sid#
</cfquery>
<cfif not get_p_orders.recordcount>
		Kayıt yapılana Kadar Üretim Emri Silinmiştir.
	<cfabort>
</cfif>
<cfset p_order_id_list = ValueList(get_p_orders.P_ORDER_ID)>
<cfset p_order_id_list = ListDeleteDuplicates(p_order_id_list,',')>
<cfset new_stock_id_list = ListDeleteDuplicates(new_stock_id_list,',')>
<cfset new_amount_list = ListDeleteDuplicates(new_amount_list,',')>
<!---Yeni Soklar, Eklediğimiz Planlarda mevcut mu?--->
<cfloop list="#p_order_id_list#" index="p">
	<cfquery name="get_p_order_new_stock" datasource="#dsn3#">
    	SELECT 
        	PO.P_ORDER_NO, 
            S.PRODUCT_NAME
		FROM     
        	PRODUCTION_ORDERS AS PO INNER JOIN
            PRODUCTION_ORDERS_STOCKS AS POS ON PO.P_ORDER_ID = POS.P_ORDER_ID INNER JOIN
            STOCKS AS S ON POS.STOCK_ID = S.STOCK_ID
		WHERE  
        	POS.STOCK_ID IN(#new_stock_id_list#) AND 
            PO.P_ORDER_ID = #p# AND 
            NOT (POS.STOCK_ID IN (#attributes.sid#))
    </cfquery>
    <cfif get_p_order_new_stock.recordcount and attributes.record_num gt 1>
    	<script type="text/javascript">
			alert(<cfoutput>"#get_p_order_new_stock.P_ORDER_NO# Nolu Üretim Emrinde Zaten #get_p_order_new_stock.PRODUCT_NAME# Ürün Var.!"</cfoutput>);
			window.history.go(-1);
		</script>
        <cfabort>
    </cfif>
</cfloop>
<!---<cfoutput>#p_order_id_list# - #new_stock_id_list# - #new_amount_list#</cfoutput>--->
<cftransaction>
	<cfif Listlen(new_stock_id_list) gt 1> <!---Yeni Stok Satırları 1 den çoksa--->
		<cfif ListLen(p_order_id_list)>
        	<cfquery name="get_old_amount" datasource="#dsn3#">
            	SELECT P_ORDER_ID, AMOUNT FROM PRODUCTION_ORDERS_STOCKS WHERE P_ORDER_ID IN (#p_order_id_list#) AND STOCK_ID = #attributes.sid# AND TYPE = 2
            </cfquery>
            <cfoutput query="get_old_amount">
            	<cfset 'AMOUNT_#P_ORDER_ID#' = AMOUNT>
            </cfoutput>
        	<cfquery name="del_production_order_material" datasource="#DSN3#"><!--- Emirlerdeki İlgili Stok Satırları Siliniyor--->
                DELETE FROM PRODUCTION_ORDERS_STOCKS WHERE P_ORDER_ID IN (#p_order_id_list#) AND STOCK_ID = #attributes.sid# AND TYPE = 2
            </cfquery>
            <cfloop from="1" to="#attributes.record_num#" index="i"> <!---Her Alta Eklenen Stok Satırı için Döndürülüyor--->
                <cfloop list="#p_order_id_list#" index="pp"> <!---Üretim Emirleri Döndürülüyor--->
                    <cfif Evaluate('attributes.row_kontrol#i#') eq 1> <!---Eğer satır silinmemişse--->
                    
                        <cfset katsayi = FilterNum(Evaluate('attributes.plan_demand_#i#'),4)/FilterNum(attributes.plan_demand,4)> <!---Eski Satırla Yeni Satır Arasındaki Oran Hesaplanıyor--->
                   		<cfquery name="GET_STOCK_INFO" datasource="#DSN3#"><!--- Yeni Stok Bilgileri Alınıyor--->
                        	SELECT STOCK_ID,PRODUCT_ID,PRODUCT_UNIT_ID FROM STOCKS WHERE STOCK_ID = #evaluate('attributes.stock_id#i#')#
                   		</cfquery>
                      	<cfset wrk_id_new_sarf = 'WRK#round(rand()*65)##dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmssL')##session.ep.userid##round(rand()*100)#U#PP#S#GET_STOCK_INFO.STOCK_ID#'>
                        <cfif isdefined('AMOUNT_#pp#') and Evaluate('AMOUNT_#pp#') gt 0 and katsayi gt 0>
                            <cfquery name="add_production_order_material" datasource="#DSN3#">
                                INSERT INTO 
                                    PRODUCTION_ORDERS_STOCKS
                                    (
                                        P_ORDER_ID, 
                                        PRODUCT_ID, 
                                        STOCK_ID, 
                                        SPECT_MAIN_ID, 
                                        AMOUNT, 
                                        TYPE, 
                                        PRODUCT_UNIT_ID, 
                                        RECORD_DATE, 
                                        RECORD_EMP, 
                                        RECORD_IP, 
                                        IS_PHANTOM, 
                                        IS_SEVK, 
                                        IS_PROPERTY, 
                                        IS_FREE_AMOUNT, 
                                        FIRE_AMOUNT, 
                                        FIRE_RATE, 
                                        SPECT_MAIN_ROW_ID, 
                                        IS_FLAG, 
                                        WRK_ROW_ID, 
                                        LINE_NUMBER
                                    )
                                VALUES 
                                    (
                                        #pp#,
                                        #GET_STOCK_INFO.PRODUCT_ID#,
                                        #GET_STOCK_INFO.STOCK_ID#,
                                        NULL,
                                        <cfif Evaluate('AMOUNT_#pp#') gt 0>#Evaluate('AMOUNT_#pp#')*katsayi#<cfelse>0</cfif>,
                                        2,
                                        #GET_STOCK_INFO.PRODUCT_UNIT_ID#,
                                        #now()#,
                                        #session.ep.userid#,
                                        '#cgi.remote_addr#',
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        NULL,
                                        0,
                                        '#wrk_id_new_sarf#',
                                        0
                                    )
                            </cfquery> 
                    	</cfif>
                    </cfif>
                </cfloop>
            </cfloop>
        	<cfquery name="del_zero_amount" datasource="#dsn3#">
            	DELETE FROM PRODUCTION_ORDERS_STOCKS WHERE AMOUNT = 0
            </cfquery>
        </cfif> 
 	<cfelse> <!---Tek Satır Varsa--->
    	<cfset katsayi = new_amount_list/FilterNum(attributes.plan_demand,4)> <!---Eski Satırla Yeni Satır Arasındaki Oran Hesaplanıyor--->
        <cfquery name="GET_STOCK_INFO" datasource="#DSN3#"><!--- Yeni Stok Bilgileri Alınıyor--->
        	SELECT STOCK_ID,PRODUCT_ID,PRODUCT_UNIT_ID FROM STOCKS WHERE STOCK_ID = #new_stock_id_list#
      	</cfquery>
        <cfif isdefined('attributes.optimization') and len(attributes.optimization_id)>
            <cfquery name="add_history" datasource="#dsn3#">
            	INSERT INTO
                	EZGI_IFLOW_OPTIMIZATION_POR_STOCKS_HISTORY
                    (
                        OPTIMIZATION_ID,
                        POR_STOCK_ID, 
                        PRODUCT_ID, 
                        STOCK_ID, 
                        AMOUNT, 
                        PRODUCT_UNIT_ID 
                    )
            	SELECT
                	#attributes.optimization_id# AS OPTIMIZATION_ID,
                	POR_STOCK_ID,
                    PRODUCT_ID,
                    STOCK_ID,
                    AMOUNT,
                    PRODUCT_UNIT_ID	
              	FROM
            		PRODUCTION_ORDERS_STOCKS
              	 WHERE        
                    P_ORDER_ID IN (#p_order_id_list#) AND 
                    STOCK_ID = #attributes.sid# AND 
                    TYPE = 2
            </cfquery>
        </cfif>
    	<cfquery name="upd_production_order_material" datasource="#DSN3#">
            UPDATE       
                PRODUCTION_ORDERS_STOCKS
            SET                
                AMOUNT = AMOUNT * #katsayi#,
                PRODUCT_ID = #GET_STOCK_INFO.PRODUCT_ID#,
                STOCK_ID = #GET_STOCK_INFO.STOCK_ID#,
                PRODUCT_UNIT_ID = #GET_STOCK_INFO.PRODUCT_UNIT_ID#
            WHERE        
                P_ORDER_ID IN (#p_order_id_list#) AND 
                STOCK_ID = #attributes.sid# AND 
                TYPE = 2
        </cfquery>
        <cfquery name="del_zero_amount" datasource="#dsn3#">
       		DELETE FROM PRODUCTION_ORDERS_STOCKS WHERE AMOUNT = 0
  		</cfquery>
    </cfif>
</cftransaction>
<cfif not isdefined('attributes.optimization')>
	<script type="text/javascript">
        alert('<cf_get_lang dictionary_id='663.Optimizasyon Girişi Tamamlandı'>.')
        wrk_opener_reload();
        window.close();
    </script>
</cfif>