<!---
    File: upd_ezgi_iflow_production_order_time.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
				
				<!---Gün Hesaplaması Yapılıyor--->
            	<cfset product_id_list = ValueList(get_production_orders.iflow_p_order_id)>
                <cfquery name="get_working_operations" datasource="#dsn3#">
                    SELECT * FROM EZGI_IFLOW_PRODUCTION_OPERATION WHERE IFLOW_P_ORDER_ID IN (#product_id_list#)
                </cfquery>
                <cfoutput query="get_working_operations">
                    <cfset 'SURE_#OPERATION_TYPE_ID#_#IFLOW_P_ORDER_ID#' = O_TOTAL_PROCESS_TIME> <!---(Üretim Plan Miktarı * Operasyon Süresi) dir--->
                </cfoutput>
                
                <cfoutput query="get_operations">
					<cfset 'total_operation_time_#OPERATION_TYPE_ID#' = 0>
              	</cfoutput>
                <cfoutput query="get_production_orders">
                    <cfset 'biggest_time_operation_#get_production_orders.IFLOW_P_ORDER_ID#' = 0>
                    <cfset 'total_product_order_time_#get_production_orders.IFLOW_P_ORDER_ID#' = 0>
                    <cfloop query="get_operations">
                        <cfif isdefined('SURE_#get_operations.OPERATION_TYPE_ID#_#get_production_orders.iflow_p_order_id#') and Evaluate('KATSAYI_#OPERATION_TYPE_ID#') gt 0>
                            <!---Operasyon Sütunun Kümüle Operasyon Süresinin Hesaplanması--->
                            <cfset 'total_operation_time_#OPERATION_TYPE_ID#' = Evaluate('total_operation_time_#OPERATION_TYPE_ID#') + (Evaluate('SURE_#get_operations.OPERATION_TYPE_ID#_#get_production_orders.iflow_p_order_id#')/Evaluate('KATSAYI_#OPERATION_TYPE_ID#')/Evaluate('SAYI_#OPERATION_TYPE_ID#'))>
                            <!---Üretim Planının Toplam Operasyon Süresinin Hesaplaması--->
                            <cfset 'total_product_order_time_#get_production_orders.IFLOW_P_ORDER_ID#' = Evaluate('total_product_order_time_#get_production_orders.IFLOW_P_ORDER_ID#') + (Evaluate('SURE_#get_operations.OPERATION_TYPE_ID#_#get_production_orders.IFLOW_P_ORDER_ID#')/Evaluate('KATSAYI_#OPERATION_TYPE_ID#')/Evaluate('SAYI_#OPERATION_TYPE_ID#'))>
                            <cfif get_operations.OPERATION_TYPE_ID eq get_defaults.DEFAULT_CUTTING_OPERATION_TYPE_ID>
                                <!---Satırın Kesim Zamanı Hesaplaması--->
                                <cfset 'cutting_time_#get_production_orders.IFLOW_P_ORDER_ID#' = Evaluate('SURE_#get_operations.OPERATION_TYPE_ID#_#get_production_orders.IFLOW_P_ORDER_ID#')/Evaluate('KATSAYI_#OPERATION_TYPE_ID#')/Evaluate('SAYI_#OPERATION_TYPE_ID#')>
                            </cfif>
                            <!---Her Operasyonun Son Değeri Bulunuyor--->
                        </cfif>
                        <cfif Evaluate('total_operation_time_#OPERATION_TYPE_ID#') gt Evaluate('biggest_time_operation_#get_production_orders.IFLOW_P_ORDER_ID#')>
                            <!---En Büyük Kümülatif Operasyon Türü Bulunuyor--->
                            <cfset 'biggest_time_operation_type_id_#get_production_orders.IFLOW_P_ORDER_ID#' = OPERATION_TYPE_ID> 
                            <!---En Büyük Kümülatif Operasyon Süresi Bulunuyor --->
                            <cfset 'biggest_time_operation_#get_production_orders.IFLOW_P_ORDER_ID#' =  Evaluate('total_operation_time_#OPERATION_TYPE_ID#')>   
                            <cfset biggest_time_operation = Evaluate('total_operation_time_#OPERATION_TYPE_ID#')>   
                        </cfif>
                    </cfloop>
                    <cfif isdefined('biggest_time_operation_#get_production_orders.IFLOW_P_ORDER_ID#') and Evaluate('biggest_time_operation_#get_production_orders.IFLOW_P_ORDER_ID#') gt 0>
                        <!---Satırdaki En Büyük Kümüle Operasyon Süresi üzerinden  Toplam Çalışma Zamanı (Gün) Hesaplanıyor--->
                        <cfset 'working_days_#get_production_orders.IFLOW_P_ORDER_ID#' = Evaluate('biggest_time_operation_#get_production_orders.IFLOW_P_ORDER_ID#')/60/60/gunluk_caliasma_saat>
                    </cfif>
                </cfoutput>
                <cfloop query="get_operations">
                    <cfif Evaluate('total_operation_time_#OPERATION_TYPE_ID#') gt biggest_time_day> 
                        <cfset biggest_time_day_operation_type_id = OPERATION_TYPE_ID>
                        <cfset biggest_time_day = Evaluate('total_operation_time_#OPERATION_TYPE_ID#')>
                    </cfif>
                </cfloop>
                <cfset total_row = get_production_orders.recordcount>
              	<cfset total_cutting_time = 0>
             	<cfset plan_start_date = get_plan_info.MASTER_PLAN_start_DATE><!---Master Planın Başlama Tarihi--->
             	<cfoutput query="get_operations">
					<cfset 'total_operation_time_#OPERATION_TYPE_ID#' = 0>
             	</cfoutput>
           		<cfoutput query="get_production_orders">
                	<!---Üretim Planı Bitiş Tarihinin Bulunması--->
                 	<cfif isdefined('biggest_time_operation_#get_production_orders.IFLOW_P_ORDER_ID#')>
                     	<cfset total_product_time = (Evaluate('biggest_time_operation_#get_production_orders.IFLOW_P_ORDER_ID#')/60) + (ara_stok*60*gunluk_caliasma_saat)>
                    	<cfset loop_mode = 1><!--- Arama Modu--->
                     	<cfset loop_size = working_blocks.recordcount>
                     	<cfif working_blocks.recordcount>
                        	<cfloop query="working_blocks">
                            	<cfif loop_mode eq 1>
                                  	<cfif plan_start_date gte working_blocks.start_date and plan_start_date lt working_blocks.end_date>
                                      	<cfset loop_mode = 2> <!---Hesaplama Modu--->
                                  	<cfelse>
                                    	<cfif plan_start_date lt working_blocks.start_date>
                                         	<cfset plan_start_date = working_blocks.start_date>
                                          	<cfset loop_mode = 2> <!---Hesaplama Modu--->
                                     	</cfif>
                                 	</cfif>
                              	</cfif>
                             	<cfif loop_mode eq 2>
                                 	<cfif total_product_time lte working_blocks.amount> <!---Mesai Blok Zamanı Toplam Yalışma Zamanından Büyükse--->
                                     	<cfset loop_mode = 3> <!---Pass Modu--->
                                      	<cfset total_product_end_date = DateAdd('n',total_product_time, working_blocks.start_date)>
                                 	<cfelse>
                                    	<cfset total_product_time = total_product_time - working_blocks.amount><!---Toplam Mesai Süresi Güncelleniyor --->
                                 	</cfif>
                              		<cfif loop_size eq currentrow>
                                    	<cf_get_lang dictionary_id='655.Dikkat Plan Süresi Bu Yılı Aşıyor.'>
                                   		<cfabort>
                                	</cfif>
                             	</cfif>
                        	</cfloop>
                       	<cfelse>
                         	<cf_get_lang dictionary_id='656.Dikkat : working_blocks Tarih Hesaplama Dosyasında Kayıt Yok'>. <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'> !
                         	<cfabort>
                     	</cfif>
                	<cfelse>
                    	Dikkat : #LOT_NO# Lot No #PRODUCT_NAME# Süre Hesaplaması Yapılamıyor. Sistem Yöneticinizle Görüşün !
                   		<cfabort>
					</cfif>
                 	<!---Üretim Planı Bitiş Tarihinin Bulunması--->
                    
                 	<!---Paketleme Bitiş Tarihinin Bulunması--->
                	<cfif isdefined('cutting_time_#get_production_orders.IFLOW_P_ORDER_ID#')>
                    	<cfset total_cutting_time = total_cutting_time + (Evaluate('cutting_time_#get_production_orders.IFLOW_P_ORDER_ID#')/60)>
                     	<cfset total_product_time = total_cutting_time >
                    	<cfset loop_mode = 1><!--- Arama Modu--->
                      	<cfset loop_size = working_blocks.recordcount>
                     	<cfset cutting_start_date = get_plan_info.MASTER_PLAN_start_DATE>
                    	<cfif working_blocks.recordcount>
                         	<cfloop query="working_blocks">
                             	<cfif loop_mode eq 1>
                                	<cfif cutting_start_date  gte working_blocks.start_date and cutting_start_date lt working_blocks.end_date>
                                     	<cfset loop_mode = 2> <!---Hesaplama Modu--->
                                  	<cfelse>
                                     	<cfif cutting_start_date lt working_blocks.start_date>
                                        	<cfset cutting_start_date  = working_blocks.start_date>
                                        	<cfset loop_mode = 2> <!---Hesaplama Modu--->
                                     	</cfif>
                                	</cfif>
                            	</cfif>
                              	<cfif loop_mode eq 2>
                                	<cfif total_product_time lte working_blocks.amount> <!---Mesai Blok Zamanı Toplam Yalışma Zamanından Büyükse--->
                                    	<cfset loop_mode = 3> <!---Pass Modu--->
                                      	<cfset total_cutting_end_date = DateAdd('n',total_product_time, working_blocks.start_date)>
                                  	<cfelse>
                                     	<cfset total_product_time = total_product_time - working_blocks.amount><!---Toplam Mesai Süresi Güncelleniyor --->
                                  	</cfif>
                                 	<cfif loop_size eq currentrow>
                                      	<cf_get_lang dictionary_id='655.Dikkat Plan Süresi Bu Yılı Aşıyor.'>
                                     	<cfabort>
                                 	</cfif>
                             	</cfif>
                         	</cfloop>
                     	<cfelse>
                        	<cf_get_lang dictionary_id='656.Dikkat : working_blocks Tarih Hesaplama Dosyasında Kayıt Yok'>. <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'> !
                         	<cfabort>
                     	</cfif>
                    <cfelse>
                        <cfset 'cutting_time_#get_production_orders.IFLOW_P_ORDER_ID#' = 0>
                        <cfquery name="get_last_time" datasource="#dsn3#">
                        	SELECT        
                            	TOP (1) START_DATE, FINISH_DATE,CUTTING_FINISH_DATE
							FROM            
                            	EZGI_IFLOW_PRODUCTION_ORDERS
							WHERE        
                            	IFLOW_P_ORDER_ID < #get_production_orders.IFLOW_P_ORDER_ID# AND
                                MASTER_PLAN_ID = #attributes.master_plan_id#
							ORDER BY 
                            	IFLOW_P_ORDER_ID DESC
                        </cfquery>
                        <cfif get_last_time.recordcount>
                            <cfscript>
								total_cutting_end_date = CreateODBCDateTime(get_last_time.CUTTING_FINISH_DATE);
							</cfscript>
                        <cfelse>
                            <cfscript>
								total_cutting_end_date = CreateODBCDateTime(get_plan_info.MASTER_PLAN_start_DATE);
							</cfscript>
                        </cfif>
                     	<!---<cfabort> --->   
                    </cfif>
                    <cfquery name="upd_p_order" datasource="#dsn3#">
                    	UPDATE       
                        	EZGI_IFLOW_PRODUCTION_ORDERS
						SET                
                        	START_DATE = #DateAdd('n',-Evaluate('cutting_time_#get_production_orders.IFLOW_P_ORDER_ID#'), total_cutting_end_date)#, 
                            FINISH_DATE = <cfif isdefined('total_product_end_date')>#total_product_end_date#<cfelse>NULL</cfif>, 
                            CUTTING_FINISH_DATE = <cfif isdefined('total_cutting_end_date')>#total_cutting_end_date#<cfelse>NULL</cfif>, 
                            TOTAL_PRODUCTION_TIME = <cfif isdefined('working_days_#get_production_orders.IFLOW_P_ORDER_ID#') and Evaluate('working_days_#get_production_orders.IFLOW_P_ORDER_ID#') gt 0>#Evaluate('working_days_#get_production_orders.IFLOW_P_ORDER_ID#')#<cfelse>0</cfif>
						WHERE        
                        	IFLOW_P_ORDER_ID = #get_production_orders.IFLOW_P_ORDER_ID#
                    </cfquery>
                    <cfquery name="upd_p_order" datasource="#dsn3#">
                    	UPDATE 
                        	PRODUCTION_ORDERS
						SET          
                        	START_DATE = EM.MASTER_PLAN_START_DATE, 
                            FINISH_DATE = EM.MASTER_PLAN_FINISH_DATE
						FROM     
                        	EZGI_IFLOW_PRODUCTION_ORDERS AS EO INNER JOIN
              				EZGI_IFLOW_MASTER_PLAN AS EM ON EO.MASTER_PLAN_ID = EM.MASTER_PLAN_ID INNER JOIN
                  			PRODUCTION_ORDERS ON EO.LOT_NO = PRODUCTION_ORDERS.LOT_NO
						WHERE  
                        	EM.MASTER_PLAN_ID = #attributes.master_plan_id#
                   	</cfquery>
              	</cfoutput>
           