<!---
    File: upd_ezgi_shipping_clear.cfm
    Folder: Add_Ons\ezgi\e_shipping\query
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Sevkiyat Silme veya Bölme İşlemi
--->
<!---<cfdump var="#attributes#"><cfabort>--->
<cfif isdefined('attributes.change')> <!---Sevkiyat Köntrolü Satır Bazına Çevir--->
	<cftransaction>
        <cfquery name="del_shipping_row" datasource="#dsn3#"><!---Kontrol satırı siliniyor--->
            DELETE FROM EZGI_SHIPPING_PACKAGE_LIST WHERE SHIPPING_ID = #attributes.ship_id#                          
        </cfquery>
        <cfquery name="add_shipping_row_control" datasource="#dsn3#">
            INSERT INTO 
                EZGI_SHIPPING_PACKAGE_LIST
                (
                    SHIPPING_ID, 
                    SHIPPING_ROW_ID, 
                    STOCK_ID, 
                    AMOUNT, 
                    CONTROL_AMOUNT, 
                    REF_STOCK_ID, 
                    CONTROL_STATUS, 
                    TYPE, 
                    RECORD_EMP, 
                    RECORD_DATE
                )
          	<cfif attributes.is_type eq 1>
                SELECT        
                    ESR.SHIP_RESULT_ID, 
                    ESR.SHIP_RESULT_ROW_ID, 
                    EPS.PAKET_ID, 
                    ORR.QUANTITY * EPS.PAKET_SAYISI AS Expr1, 
                    ORR.QUANTITY * EPS.PAKET_SAYISI AS Expr2, 
                    ORR.STOCK_ID, 
                    1 AS CONTROL_STATUS, 
                    1 AS TYPE,
                    #session.ep.userid#,
                    #now()#
                FROM            
                    EZGI_SHIP_RESULT_ROW AS ESR INNER JOIN
                    ORDER_ROW AS ORR ON ESR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                    EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID
                WHERE        
                    ESR.SHIP_RESULT_ID = #attributes.ship_id#
            <cfelse>
            	SELECT        
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID, 
                    ESR.SHIP_RESULT_INTERNALDEMAND_ROW_ID, 
                    EPS.PAKET_ID, 
                    ORR.QUANTITY * EPS.PAKET_SAYISI AS Expr1, 
                    ORR.QUANTITY * EPS.PAKET_SAYISI AS Expr2, 
                    ORR.STOCK_ID, 
                    1 AS CONTROL_STATUS, 
                    2 AS TYPE,
                    #session.ep.userid#,
                    #now()#
                FROM            
                    EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESR INNER JOIN
                    ORDER_ROW AS ORR ON ESR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                    EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID
                WHERE        
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
            </cfif>	
        </cfquery>
    </cftransaction>
    <cflocation url="#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_term_control&ship_id=#attributes.ship_id#&is_type=1" addtoken="No">
<cfelse> <!---Temizleme İşlemi--->
	<cfset attributes.row_id_list = ListDeleteDuplicates(attributes.row_id_list,',')>
	<cfif len(attributes.row_id_list)>
        <cftransaction>
            <cfloop list="#attributes.row_id_list#" index="i">
            	<cfset new_amount =0>
            	<!---Seri No Varsa ve Üretim Planına Bağlı veya Değilse--->
      			<cfif isdefined('attributes.IS_SERIAL_NO_#i#') and Len(Evaluate('attributes.IS_SERIAL_NO_#i#'))> <!---Seri No Varsa--->
                	<cfif Evaluate('attributes.order_row_row_#i#') gt 1> <!---Bir satırdan Fazlaysa--->
                    	<cfset t_p_order_amount = 0> <!---Üretim Palnına Bağlı olan satırların toplamı için sayaç oluşturuyoruz--->
                        <cfset t_rate_amount = 0> <!---Düşülmesi istenilen satırların toplamı için sayaç oluşturuyoruz--->
                    	<cfloop from="1" to="#Evaluate('attributes.order_row_row_#i#')#" index="z">
                        	<cfif isdefined('input_#i#_#z#')> <!---İşaretlenmemişse ---> 
                            
                        	 	<cfset t_rate_amount = t_rate_amount + FilterNum(Evaluate('rate_#i#_#z#'),3)>
                        	</cfif>
                        </cfloop>
                        <cfset old_rate = (FilterNum(Evaluate('quantity_#i#'),3)-t_rate_amount)/FilterNum(Evaluate('quantity_#i#'),3)>	    
                        <cfset new_rate = 1-old_rate> 
                        <cfset new_amount = FilterNum(Evaluate('quantity_#i#'),3) - (FilterNum(Evaluate('quantity_#i#'),3)-t_rate_amount)>
                        <cfset old_amount = FilterNum(Evaluate('quantity_#i#'),3) - t_rate_amount>
                  	<cfelse><!---Bir satır ise--->
                    	<cfset new_amount = 1>
                    </cfif>
              		<cfif new_amount gt 0> <!---Eğer Satırda Bir Değişiklik İstenmişse--->
                        <cfinclude template="upd_ezgi_shipping_clear_order_row_seri_no.cfm"><!---Sipariş Satırları Güncelleniyor--->
                    </cfif>
                <cfelse> <!---Seri No Yoksa--->
					<cfif Evaluate('attributes.order_row_row_#i#') gt 1> <!---Bir satırdan Fazlaysa--->
                        <cfset t_p_order_amount = 0> <!---Üretim Palnına Bağlı olan satırların toplamı için sayaç oluşturuyoruz--->
                        <cfset t_rate_amount = 0> <!---Düşülmesi istenilen satırların toplamı için sayaç oluşturuyoruz--->
                        <cfloop from="1" to="#Evaluate('attributes.order_row_row_#i#')#" index="z">
                            <cfif Evaluate('p_order_id_#i#_#z#') gt 0> <!---Üretim Planı Olan Satırlarda İse --->
                            
                                <cfset t_p_order_amount = t_p_order_amount + Filternum(Evaluate('p_order_amount_#i#_#z#'),3)> <!---Üretim Planına Bağlı Olan satırları Topluyoruz--->
                                
                                <cfif not isdefined('input_#i#_#z#')> <!---İşaretlenmemişse ---> 
                                
                                    <cfset t_rate_amount = t_rate_amount + Filternum(Evaluate('p_order_amount_#i#_#z#'),3)> <!---Düşülecek Miktar Üretim Planı kadar ilave ediliyor--->
                                    
                                <cfelseif  isdefined('input_#i#_#z#')> <!---İşaretlenmişse--->
                                
                                    <cfset t_rate_amount = t_rate_amount + (Filternum(Evaluate('p_order_amount_#i#_#z#'),3)-Filternum(Evaluate('rate_#i#_#z#'),3))> <!---Düşülecek Miktar Üretim Planı - Sevk Miktarı arasındaki fark kadar ilave ediliyor--->
                                
                                </cfif>
                            <cfelse> <!---Üretim Planı Olmayan Satıra Yani Son Satıra İnmişse--->
                                <cfset t_fark = FilterNum(Evaluate('quantity_#i#'),3) - t_p_order_amount> <!---Sipariş Satır miktarından Üretim Planına bağlı olanların miktarını çıkararak, Üretim Emri Olmayan Miktarı Buluyoruz--->
                                <cfif not isdefined('input_#i#_#z#')> <!---İşaretlenmemişse ---> 
                                    <cfset t_rate_amount = t_rate_amount + t_fark> <!---Üretim Emri Olmayan Miktardan tamamını ekliyoruz--->
                                <cfelseif  isdefined('input_#i#_#z#')> <!---İşaretlenmişse--->
                                    <cfset t_rate_amount = t_rate_amount + (t_fark-Filternum(Evaluate('rate_#i#_#z#'),3))> <!---Üretim Emri Olmayan Miktardan Çıkarılmak istenen farkı buluyoruz--->
                                </cfif>     
                            </cfif>
                            <!---<cfoutput>#i#_#z# : t_p_order_amount #t_p_order_amount# - t_rate_amount #t_rate_amount#</cfoutput><br>--->
                        </cfloop>
                        <cfset old_rate = (FilterNum(Evaluate('quantity_#i#'),3)-t_rate_amount)/FilterNum(Evaluate('quantity_#i#'),3)>	    
                        <cfset new_rate = 1-old_rate> 
                        <cfset new_amount = FilterNum(Evaluate('quantity_#i#'),3) - (FilterNum(Evaluate('quantity_#i#'),3)-t_rate_amount)>
                        <cfset old_amount = FilterNum(Evaluate('quantity_#i#'),3) - t_rate_amount> 
                    <cfelse><!---Bir satır ise--->
                        <cfif isdefined('input_#i#_1')> <!---Checkbox işaretli ise--->
                        	<cfif FilterNum(Evaluate('rate_#i#_1'),3) eq FilterNum(Evaluate('quantity_#i#'),3)> <!---Eğer Satır Miktarı ile Bölünme Miktarı Eşitse Direk Sevkiyattan Çıkar--->
								<cfif attributes.is_type eq 1> <!---Sevk Planıysa--->
                                	<cfquery name="get_paket_sayisi" datasource="#dsn3#">
                                        SELECT     
                                            SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI
                                        FROM          
                                            STOCKS AS S1 WITH (NOLOCK) INNER JOIN
                                            EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) INNER JOIN
                                            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
                                            STOCKS AS S WITH (NOLOCK) INNER JOIN
                                            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON S1.STOCK_ID = EPS.MODUL_ID
                                        WHERE      
                                            ESRR.SHIP_RESULT_ROW_ID = #i# AND
                                            ISNULL(S1.IS_PROTOTYPE,0) = 0
                                        UNION ALL
                                        SELECT
                                            SUM(ORR.QUANTITY) AS PAKET_SAYISI
                                        FROM            
                                            SPECTS AS SP WITH (NOLOCK) INNER JOIN
                                            EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) INNER JOIN
                                            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                                            STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID
                                        WHERE        
                                            ESRR.SHIP_RESULT_ROW_ID = #i# AND
                                            ISNULL(S1.IS_PROTOTYPE, 0) = 1
                                    </cfquery>
                                    <cfif get_paket_sayisi.recordcount and get_paket_sayisi.PAKET_SAYISI gt 0>
                                    	<cfquery name="upd_ship_result" datasource="#dsn3#">
                                            UPDATE 
                                                EZGI_SHIP_RESULT
                                            SET          
                                                SHIPMENT_PACKAGE_AMOUNT = SHIPMENT_PACKAGE_AMOUNT-#get_paket_sayisi.PAKET_SAYISI#
                                            WHERE  
                                                SHIP_RESULT_ID = #attributes.ship_id#
                                        </cfquery>
                                    </cfif>
                                    <cfquery name="del_shipping_row" datasource="#dsn3#"><!---Sevk Planı satırı siliniyor--->
                                        DELETE FROM EZGI_SHIP_RESULT_ROW WHERE SHIP_RESULT_ROW_ID = #i#
                                    </cfquery>
                                <cfelse> <!---Sevk Talebiyse--->
                                	<cfquery name="get_paket_sayisi" datasource="#dsn3#">
                                    	SELECT     
                                            SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI
                                        FROM          
                                            STOCKS AS S1 WITH (NOLOCK) INNER JOIN
                                            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) INNER JOIN
                                            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
                                            STOCKS AS S WITH (NOLOCK) INNER JOIN
                                            EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON S1.STOCK_ID = EPS.MODUL_ID
                                        WHERE      
                                            ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID = #i# AND
                                            ISNULL(S1.IS_PROTOTYPE,0) = 0
                                        UNION ALL
                                        SELECT
                                            SUM(ORR.QUANTITY) AS PAKET_SAYISI
                                        FROM            
                                            SPECTS AS SP WITH (NOLOCK) INNER JOIN
                                            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) INNER JOIN
                                            ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                                            STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID
                                        WHERE        
                                            ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID = #i# AND
                                            ISNULL(S1.IS_PROTOTYPE, 0) = 1
                                    </cfquery>
                                    <cfif get_paket_sayisi.recordcount and get_paket_sayisi.PAKET_SAYISI gt 0>
                                    	<cfquery name="upd_ship_internal" datasource="#dsn3#">
                                        	 UPDATE 
                                                EZGI_SHIP_RESULT_INTERNALDEMAND
                                            SET          
                                                SHIPMENT_PACKAGE_AMOUNT = SHIPMENT_PACKAGE_AMOUNT-#get_paket_sayisi.PAKET_SAYISI#
                                            WHERE  
                                                SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
                                        </cfquery>
                                    </cfif>
                                    <cfquery name="del_shipping_row" datasource="#dsn3#"><!---Sevk Talebi satırı siliniyor--->
                                    	DELETE FROM EZGI_SHIP_RESULT_INTERNALDEMAND_ROW WHERE SHIP_RESULT_INTERNALDEMAND_ROW_ID = #i#
                                    </cfquery>
                                </cfif>
                                
                                <cfset new_amount = 0> <!---Sipariş Bölmeye (upd_ezgi_shipping_clear_order_row.cfm) Gitmesin--->
                            <cfelse> <!---Eğer Satır Miktarı ile Bölünme Miktarı Eşit Değilse Bölme işlemi yap--->
                                <cfset old_rate = FilterNum(Evaluate('rate_#i#_1'),3)/FilterNum(Evaluate('quantity_#i#'),3)>
                                <cfset new_rate = 1-old_rate> 
                                <cfset new_amount = FilterNum(Evaluate('quantity_#i#'),3) - FilterNum(Evaluate('rate_#i#_1'),3)>
                                <cfset old_amount = FilterNum(Evaluate('rate_#i#_1'),3)>
                            </cfif>
                    	<cfelse><!---Checkbox işaretli Değil ise Hiç Birşey yapma---> 
                        	<cfset new_amount = 0><!---Sipariş Bölmeye (upd_ezgi_shipping_clear_order_row.cfm) Gitmesin--->
                        </cfif>
                    </cfif>
                    <!---<cfoutput>#old_rate# - #new_rate# - #old_amount# - #new_amount# -- #FilterNum(Evaluate('quantity_#i#'),3)#- #FilterNum(Evaluate('quantity_#i#'),3)# </cfoutput><br />
                    <cfdump var="#attributes#"><cfabort>--->
                    <cfif new_amount gt 0> <!---Eğer Satırda Bir Değişiklik İstenmişse--->
                        <cfinclude template="upd_ezgi_shipping_clear_order_row.cfm"><!---Sipariş Satırları Güncelleniyor--->
                    </cfif>
                </cfif>
            </cfloop>
        </cftransaction>
        <!---<cfabort>--->
        <script type="text/javascript">
            alert("<cf_get_lang dictionary_id='786.Sevk Edilemeyen Satırlar Plandan Çıkarılmıştır'>!");
            wrk_opener_reload();
            window.close()
        </script>
        <cfabort>
    </cfif>
</cfif>