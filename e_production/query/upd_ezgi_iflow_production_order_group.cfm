<!---
    File: upd_ezgi_iflow_production_order_group.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfif attributes.gurupla eq 0><!---Gurup Çöz Denmişse--->
 	<cfquery name="upd_group_lot" datasource="#dsn3#">
     	UPDATE PRODUCTION_ORDERS SET IS_GROUP_LOT = 0, GROUP_LOT_NO = NULL WHERE P_ORDER_ID IN (#attributes.p_order_id_list#)
   	</cfquery>
<cfelseif attributes.gurupla eq 1><!---Gurupla Denmişse--->
    <cfinclude template="../query/get_ezgi_iflow_production_order.cfm">
    <cfif get_production_orders.recordcount>
        <cfquery name="get_group" dbtype="query">
            SELECT
                COUNT(*) AS SAY,
                STOCK_ID
            FROM
                get_production_orders
            GROUP BY
                <cfif attributes.list_type eq 3>
                    LOT_NO,STOCK_ID
                <cfelseif attributes.list_type eq 4>  
                    P_ORDER_PARTI_NUMBER,STOCK_ID
                <cfelseif attributes.list_type eq 5>
                    STOCK_ID
                </cfif>
            HAVING
                COUNT(*) > 1
        </cfquery>
        <cfif get_group.recordcount>
            <cflock timeout="60">
                <cfquery name="get_gen_paper" datasource="#dsn3#">
                    SELECT PRODUCTION_LOT_NUMBER FROM GENERAL_PAPERS WHERE GENERAL_PAPERS_ID = 1
                </cfquery>
                <cfset paper_number = get_gen_paper.PRODUCTION_LOT_NUMBER>
                <cftransaction>
                    <cfloop query="get_group">
                        <cfset paper_number = paper_number +1>
                        <cfquery name="upd_group_lot" datasource="#dsn3#">
                            UPDATE 
                                PRODUCTION_ORDERS 
                            SET 
                                IS_GROUP_LOT = 1, 
                                GROUP_LOT_NO = '#paper_number#' 
                            WHERE 
                                P_ORDER_ID IN (#attributes.p_order_id_list#) AND 
                                STOCK_ID = #get_group.STOCK_ID#
                        </cfquery>
                    </cfloop>
                    <cfquery name="SET_MAX_PAPER" datasource="#dsn3#">
                        UPDATE       
                            GENERAL_PAPERS
                        SET                
                            PRODUCTION_LOT_NUMBER = #paper_number#
                        WHERE        
                            GENERAL_PAPERS_ID = 1
                    </cfquery>
                </cftransaction>
            </cflock>
        </cfif>
    </cfif>
<cfelseif attributes.gurupla eq 2><!---Birleştir Denmişse--->
	<cfquery name="get_group_p_order_id" datasource="#dsn3#">
    	SELECT P_ORDER_ID, GROUP_LOT_NO, LOT_NO, QUANTITY FROM PRODUCTION_ORDERS WHERE P_ORDER_ID IN (#attributes.p_order_id_list#) AND NOT (GROUP_LOT_NO IS NULL)
    </cfquery>
    <!---Alt Emir Kontrolü Yapılıyor--->
    <cfset group_list = ValueList(get_group_p_order_id.P_ORDER_ID)>
	<cfquery name="get_sub_p_order_control" datasource="#dsn3#">
        SELECT P_ORDER_ID FROM PRODUCTION_ORDERS WHERE PO_RELATED_ID IN (#group_list#)	
    </cfquery>
    <cfif get_sub_p_order_control.recordcount>
        <script language="javascript">
            alert ('<cf_get_lang dictionary_id='659.Birleştirmek İstediğiniz Emirlerin İlişkili Alt Emirleri Mevcut. Lütfen Önce Alt Emirleri Birleştiriniz .'>!');
            history.back();
        </script>
        <cfabort>
    <cfelse>
    	<!---Birleşecek Lot Grupları Bulunuyor---> 
    	<cfquery name="get_group_lot_no" dbtype="query">
        	SELECT
            	GROUP_LOT_NO
          	FROM
            	get_group_p_order_id
         	GROUP BY
            	GROUP_LOT_NO		
        </cfquery>
        <cfif get_group_lot_no.recordcount>  
			<cfset group_lot_no_list = ValueList(get_group_lot_no.GROUP_LOT_NO)>
            <!---Guruplu Lotlar Döndürülerek En Küçük Emir ID de Birleştirilip Büyük Emir ID ler siliniyor. --->
            <cfloop list="#group_lot_no_list#" index="glist">
            	<cftransaction>
                    <cfquery name="get_sub_group" dbtype="query">
                        SELECT P_ORDER_ID, QUANTITY FROM get_group_p_order_id WHERE GROUP_LOT_NO = '#glist#'
                    </cfquery>
                    <!--- Guruplanmış Emirler İçindeki En Büyük Emri Buluyorum--->
                    <cfquery name="get_max_p_order_id" dbtype="query">
                        SELECT MAX(P_ORDER_ID) AS MAX_P_ORDER_ID FROM get_group_p_order_id WHERE GROUP_LOT_NO = '#glist#'
                    </cfquery>
                    <cfif get_sub_group.recordcount>
                        <!--- Guruplanmış Emirler İçindeki Emir Listesi Bulunuyor--->
                        <cfset sub_group_p_order_id_list = Valuelist(get_sub_group.P_ORDER_ID)>
                        <!---EMİR DÜZENLEME BAŞLADI--->
                        <cfset emir_miktar =0>
                        <!---Guruplanmış Emirlerin Toplam Miktarı Bulunuyor--->
                        <cfloop query="get_sub_group">
                            <cfset emir_miktar =emir_miktar+QUANTITY>
                        </cfloop>
                        <!---En Büyük Kaydın Emir Miktarı Toplam Emir Miktarı ile Güncelleniyor--->
                        <cfquery name="upd_p_order" datasource="#dsn3#">
                        	UPDATE 
                            	PRODUCTION_ORDERS
							SET          
                            	QUANTITY = #emir_miktar#
							WHERE  
                            	P_ORDER_ID = #get_max_p_order_id.MAX_P_ORDER_ID#
                        </cfquery>
                         <!---En Büyük Kayıt Hariç Aynı Guruplanmış Emirler Siliniyor--->
                    	<cfquery name="del_p_order" datasource="#dsn3#">
                        	DELETE FROM 
                            	PRODUCTION_ORDERS
							WHERE  
                            	P_ORDER_ID IN (#sub_group_p_order_id_list#) AND 
                                P_ORDER_ID <> #get_max_p_order_id.MAX_P_ORDER_ID#
                        </cfquery>
                        <!---EMİR DÜZENLEME BİTTİ--->
                        
                        <!---OPERASYON DÜZENLEME BAŞLADI--->
                   		<cfquery name="del_p_operation" datasource="#dsn3#">
                        	DELETE FROM 
                            	PRODUCTION_OPERATION
							WHERE  
                            	P_ORDER_ID IN (#sub_group_p_order_id_list#) AND 
                                P_ORDER_ID <> #get_max_p_order_id.MAX_P_ORDER_ID#
                        </cfquery>
                        <cfquery name="upd_p_operation" datasource="#dsn3#">
                        	UPDATE
                            	PRODUCTION_OPERATION
                          	SET
                            	AMOUNT = #emir_miktar#
                           	WHERE
                            	P_ORDER_ID = #get_max_p_order_id.MAX_P_ORDER_ID#	
                        </cfquery>
                        <!---OPERASYON DÜZENLEME BİTTİ--->
                        
                        <!---MALZEME DÜZENLEME BAŞLADI--->
                        <!---Guruplanmış Üretim Emirlerine ait Malzeme Listesini Stok ve Spect bazında çekiyoruz--->
						<cfquery name="get_p_order_stocks" datasource="#dsn3#">
                        	SELECT
                              	PRODUCT_ID, 
                             	STOCK_ID, 
                             	SPECT_MAIN_ID, 
                              	SUM(AMOUNT) AS AMOUNT 
                          	FROM
                             	PRODUCTION_ORDERS_STOCKS 
                          	WHERE
                           		P_ORDER_ID IN (#sub_group_p_order_id_list#) AND
                                TYPE = 2
                         	GROUP BY
                            	PRODUCT_ID, 
                             	STOCK_ID, 
                             	SPECT_MAIN_ID
                       	</cfquery>
                        <!---Guruplanmış Üretimlerine ait Malzemeler sadece 1 tanesi kalacak şekilde Siliniyor--->
                        <cfquery name="del_p_order_stocks" datasource="#dsn3#">
                        	DELETE FROM
                            	PRODUCTION_ORDERS_STOCKS
                           	WHERE
                           		P_ORDER_ID IN (#sub_group_p_order_id_list#) AND 
                                P_ORDER_ID <> #get_max_p_order_id.MAX_P_ORDER_ID#
                        </cfquery>
                        <!---Kalan 1 tanesine Malzemele Stok ve spect bazında yükleniyor.--->
                        <cfloop query="get_p_order_stocks">
                        	<cfquery name="upd_p_order_stocks" datasource="#dsn3#">
                            	UPDATE
                                	PRODUCTION_ORDERS_STOCKS
                              	SET
                                	AMOUNT = #get_p_order_stocks.AMOUNT#
                                WHERE
                                	P_ORDER_ID = #get_max_p_order_id.MAX_P_ORDER_ID# AND
                                    STOCK_ID = #get_p_order_stocks.STOCK_ID#
                                    <cfif len(get_p_order_stocks.SPECT_MAIN_ID)>
                             			AND SPECT_MAIN_ID = #get_p_order_stocks.SPECT_MAIN_ID#
                                    </cfif>
                            </cfquery>
                        </cfloop>
                        <!---MALZEME DÜZENLEME BİTTİ--->
                    </cfif>
              	</cftransaction>
            </cfloop>
      	<cfelse>
        	<script language="javascript">
				alert ('Guruplanmış Liste Bulunamadı.!');
				history.back();
			</script>
            <cfabort>
        </cfif>
    </cfif>
</cfif>
<script type="text/javascript">
	wrk_opener_reload();
 	window.close();
</script>