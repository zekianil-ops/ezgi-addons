<!---
    File: upd_ezgi_iflow_production_order.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cf_xml_page_edit fuseact="prod.add_prod_order"><!--- Workcube Ürtim Emri XML AYARLARI --->
<cfset attributes.iflow_master_plan_id = attributes.master_plan_id>
<!---Süreç Yetkisi Kontrolü--->
<cfquery name="get_process_type" datasource="#dsn#">
	SELECT        
    	TOP (1) PR.PROCESS_ROW_ID
	FROM          
    	PROCESS_TYPE AS P INNER JOIN
     	PROCESS_TYPE_ROWS AS PR ON P.PROCESS_ID = PR.PROCESS_ID INNER JOIN
      	PROCESS_TYPE_OUR_COMPANY AS PC ON PR.PROCESS_ID = PC.PROCESS_ID
	WHERE        
    	P.FACTION LIKE N'%prod.add_prod_order,%' AND 
        PC.OUR_COMPANY_ID = #session.ep.company_id#
</cfquery>
<cfif not get_process_type.recordcount>
	<script type="text/javascript">
		alert('<cf_get_lang dictionary_id='645.Üretim Emri Kaydetmek İçin Süreçte Yetkili Olmalısınız'>!');
        window.history.go(-1);
	</script>
	<cfabort>
</cfif>
<!---Süreç Yetkisi Kontrolü--->
<cfset attributes.iid = ''>
<cfset attributes.piid = ''>
<cf_date tarih="attributes.p_order_date">
<cfif isdefined('attributes.p_start_date') and len(attributes.p_start_date)><cf_date tarih="attributes.p_start_date"></cfif>,
<cfif isdefined('attributes.p_finish_date') and len(attributes.p_finish_date)><cf_date tarih="attributes.p_finish_date"></cfif>,
<cflock name="#CREATEUUID()#" timeout="90">
    <cftransaction>
    	<cfquery name="upd_parti" datasource="#dsn3#"><!---Değişen Parti Bilgileri Güncelleniyor--->
        	UPDATE 
            	EZGI_IFLOW_PRODUCTION_ORDERS_PARTI 
           	SET 
            	P_ORDER_START_DATE = <cfif isdefined('attributes.p_start_date') and len(attributes.p_start_date)>#attributes.p_start_date#<cfelse>NULL</cfif>,
            	P_ORDER_FINISH_DATE = <cfif isdefined('attributes.p_finish_date') and len(attributes.p_finish_date)>#attributes.p_finish_date#<cfelse>NULL</cfif>,
            	P_ORDER_PARTI_DETAIL ='#attributes.detail#',
                P_ORDER_PARTI_TYPE =#attributes.p_order_type#
           	WHERE 
            	P_ORDER_PARTI_ID = #attributes.rel_p_order_id#
        </cfquery>
        
        <cfset MAX_ID.IDENTITYCOL = attributes.rel_p_order_id><!---Yeni Açılması gereken Workcube İş Emirlerine Parti ID si MAX_ID.IDENTITYCOL değişkenine yükleniyor--->
        
        <cfif attributes.record_num gt 0> <!---Parti Listesinde İş Emri Varsa--->
        	
        	<cfquery name="get_upd_info" datasource="#dsn3#"> <!---Kayıtlı İş Emir Bilgileri Alınıyor--->
            	SELECT IFLOW_P_ORDER_ID, MASTER_PLAN_ID, QUANTITY FROM EZGI_IFLOW_PRODUCTION_ORDERS WHERE IFLOW_P_ORDER_ID IN (#attributes.iflow_p_order_id_list#)
            </cfquery>
            <cfoutput query="get_upd_info"> <!---Değişkenelre Yükleniyor--->
            	<cfset 'QUANTITY_#IFLOW_P_ORDER_ID#' = QUANTITY>
                <cfset 'MASTER_PLAN_ID_#IFLOW_P_ORDER_ID#' = MASTER_PLAN_ID>
            </cfoutput>
            <cfquery name="get_max_sira_no" datasource="#dsn3#"> <!---Parti No İçin Bilgi Alınıyor--->
            	SELECT 
                	TOP (1) ISNULL(DP_ORDER_ID,0) AS DP_ORDER_ID 
               	FROM 
                	EZGI_IFLOW_PRODUCTION_ORDERS 
              	<cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
                  	WHERE              	
                    	MASTER_PLAN_ID = #attributes.master_plan_id#
              	</cfif>
               	ORDER BY 
                	DP_ORDER_ID DESC
            </cfquery>
            <cfif get_max_sira_no.recordcount>
            	<cfset sirano = get_max_sira_no.DP_ORDER_ID>
            <cfelse>
            	<cfset sirano = 0>
            </cfif>
            <cfloop from="1" to="#attributes.record_num#" index="i"><!---Parti Listesinde İş Emrileri Döndürülüyor--->
            
            	<cfquery name="get_gen_paper" datasource="#dsn3#"><!---Yeni Bir emir eklenmişse LOT No alınıyor--->
                    SELECT PRODUCTION_LOT_NUMBER FROM GENERAL_PAPERS WHERE GENERAL_PAPERS_ID = 1
                </cfquery>
                <cfset paper_number = get_gen_paper.PRODUCTION_LOT_NUMBER>
                <cfif isdefined('row_kontrol#i#') and Evaluate('row_kontrol#i#') gt 0> <!---Gelen Satırlardan Silinmemişse--->
                	
                	<cfif ListLen(attributes.iflow_p_order_id_list) lt i><!---Satır Yeni Eklnmişse--->
                        <cfset sirano = sirano + 1>
                        <cfset paper_number = paper_number +1>
						<cfset paper_full = '#paper_number#'>
                    	<cfquery name="add_p_order_row" datasource="#dsn3#"><!--- Parti İş Emei Ekleniyor--->
                        	INSERT INTO   
                                EZGI_IFLOW_PRODUCTION_ORDERS
                                (
                                    <cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
                                        MASTER_PLAN_ID,
                                    </cfif>
                                    REL_P_ORDER_ID,
                                    PRODUCT_TYPE, 
                                    STOCK_ID, 
                                    QUANTITY, 
                                    DETAIL, 
                                    PROD_ORDER_STAGE, 
                                    LOT_NO, 
                                    PLANNING_DATE,
                                    DP_ORDER_ID,
                                    ACTION_TYPE,
									<cfif Evaluate('attributes.action_type#i#') lte 1>
                                        ACTION_ID,
                                    <cfelseif Evaluate('attributes.action_type#i#') eq 2>
                                        ORDER_ROW_ID,
                                    </cfif>
                                    SPECT_MAIN_ID,
                                    RECORD_IP, 
                                    RECORD_EMP, 
                                    RECORD_DATE
                               )
                            VALUES        
                                (
                                    <cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
                                        #attributes.master_plan_id#,
                                    </cfif>
                                    #attributes.rel_p_order_id#,
                                    #Evaluate('attributes.type#i#')#,
                                    #Evaluate('attributes.stock_id#i#')#,
                                    #FilterNum(Evaluate('attributes.quantity#i#'),2)#,
                                    '#Evaluate('attributes.detail#i#')#',
                                    #attributes.process_stage#,
                                    #paper_full#,
                                    #attributes.p_order_date#,
                                    #sirano#,
                                    #Evaluate('attributes.action_type#i#')#,
                                    #Evaluate('attributes.action_id#i#')#,
                                    <cfif len(Evaluate('attributes.spect_main_id#i#')) and Evaluate('attributes.spect_main_id#i#') gt 0>
                                        #Evaluate('attributes.spect_main_id#i#')#,
                                    <cfelse>
                                        NULL,
                                    </cfif>
                                    '#cgi.remote_addr#',
                                    #session.ep.userid#,
                                    #now()#
                             	)
                        </cfquery>
                        <cfquery name="SET_MAX_PAPER" datasource="#dsn3#"> <!---Lot No Update Ediliyor--->
                            UPDATE       
                                GENERAL_PAPERS
                            SET                
                                PRODUCTION_LOT_NUMBER = #paper_number#
                            WHERE        
                                GENERAL_PAPERS_ID = 1
                        </cfquery>
                        <cfquery name="get_iflow_max_id" datasource="#dsn3#"><!--- Son Eklenen Parti İşe Emri ID si alınıyor--->
                            SELECT MAX(IFLOW_P_ORDER_ID) AS IFLOW_P_ORDER_ID FROM EZGI_IFLOW_PRODUCTION_ORDERS
                        </cfquery>
                        <cfset attributes.iid = ListAppend(attributes.iid,get_iflow_max_id.IFLOW_P_ORDER_ID)>
                    <cfelse> <!---İş emri Zaten Varsa (Yeni Eklenmemişse)--->
                    	
                    	<cfset iflow_p_order_id = ListAppend(attributes.iid,ListGetAt(attributes.iflow_p_order_id_list,i))>
                        <cfquery name="upd_parti_row_detail" datasource="#dsn3#"> <!---Açıklama Güncelleniyor--->
                            UPDATE EZGI_IFLOW_PRODUCTION_ORDERS SET DETAIL = '#Evaluate('attributes.detail#i#')#' WHERE IFLOW_P_ORDER_ID = #iflow_p_order_id#
                        </cfquery>
                        <cfif FilterNum(Evaluate('attributes.quantity#i#'),2) neq FilterNum(Evaluate('attributes.old_quantity#i#'),2)> <!---Eğer Miktarda Değişiklik Varsa--->
                        	
                        	<cfset attributes.piid = ListAppend(attributes.iid,ListGetAt(attributes.iflow_p_order_id_list,i))>
                            <cfset attributes.iflow_master_plan_id = attributes.master_plan_id>
                            <cfif len(attributes.piid)>
                            	<cfquery name="get_virtual_p_order" datasource="#dsn3#"> <!---Partdeki İşemrinin Lot Nosu Alınıyor--->
                                    SELECT DISTINCT      
                                        PO.LOT_NO
                                    FROM            
                                        EZGI_IFLOW_PRODUCTION_ORDERS AS EPO INNER JOIN
                                        PRODUCTION_ORDERS AS PO ON EPO.LOT_NO = PO.LOT_NO
                                    WHERE        
                                        EPO.MASTER_PLAN_ID = #attributes.master_plan_id# AND 
                                        EPO.REL_P_ORDER_ID = #attributes.rel_p_order_id# AND 
                                        EPO.IFLOW_P_ORDER_ID IN (#attributes.piid#)
                                </cfquery>
                                <cfif get_virtual_p_order.recordcount> <!---Eğer LOT NO bulunmuşsa --->
                                	<cfset attributes.lot_no_ = get_virtual_p_order.LOT_NO>
									<cfif len("attributes.lot_no_")>
										<cfquery name="get_all_porder" datasource="#dsn3#"><!--- Lot No ile Workcube İş Emir Listesi Alınıyor.--->
                                            SELECT P_ORDER_ID FROM PRODUCTION_ORDERS WHERE LOT_NO = '#attributes.lot_no_#'
                                        </cfquery>
                                        <cfset related_production_list = ValueList(get_all_porder.P_ORDER_ID)>
                                        <cfquery name="GET_RELATED_PRODUCTION_RESULT" datasource="#dsn3#"><!---Güncellenmek İstene İş Emirleri Arasında Üretim Sonucu Girilmiş mi? Kontrol--->
                                            SELECT PRODUCTION_ORDER_NO FROM PRODUCTION_ORDER_RESULTS WHERE P_ORDER_ID IN (#related_production_list#)
                                        </cfquery>
                                        <cfset related_production_no_list = ValueList(GET_RELATED_PRODUCTION_RESULT.PRODUCTION_ORDER_NO,',')>
                                        <cfif GET_RELATED_PRODUCTION_RESULT.recordcount and is_result_control eq 1><!--- xmle bağlandı --->
                                            <script type="text/javascript">
                                                alert("<cf_get_lang dictionary_id="36948.Bu Üretim Emrinin İlişkili Olduğu Üretimlerden Sonuç Girilenler Var,Güncelleme Yapılamaz Sonuç Girilenler"> :<cfoutput>#related_production_no_list#</cfoutput>");
                                                history.go(-1);
                                            </script>
                                            <cfabort>
                                        </cfif>
										<cfset attributes.quantity = Evaluate('attributes.quantity#i#')>
                                        <cfset attributes.old_quantity = Evaluate('attributes.old_quantity#i#')>
                                        <cfinclude template="upd_ezgi_production_order_from_iflow_master.cfm"> <!---İş Emirleri Güncelleniyor--->
                                 	</cfif>
                                </cfif>
                         	</cfif>
                        </cfif>
                   	</cfif>
                <cfelse> <!---Satır Silinmişse--->
                	<cfquery name="GET_CONTROL" datasource="#DSN3#">
                        SELECT        
                            PO.P_ORDER_ID
                        FROM            
                            EZGI_IFLOW_PRODUCTION_ORDERS AS E INNER JOIN
                            PRODUCTION_ORDERS AS PO ON E.LOT_NO = PO.LOT_NO
                        WHERE        
                            E.MASTER_PLAN_ID = #attributes.master_plan_id# AND
                           	E.IFLOW_P_ORDER_ID = #ListGetAt(attributes.iflow_p_order_id_list,i)#
                    </cfquery>
                    <cfset p_order_id_list = ValueList(GET_CONTROL.P_ORDER_ID)>
                    <cfif ListLen(p_order_id_list)>
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
                    <cfquery name="del_p_operation_row" datasource="#dsn3#">
                    	DELETE FROM EZGI_IFLOW_PRODUCTION_OPERATION WHERE IFLOW_P_ORDER_ID = #ListGetAt(attributes.iflow_p_order_id_list,i)#
                    </cfquery>
                	<cfquery name="del_p_order_row" datasource="#dsn3#">
                    	DELETE FROM EZGI_IFLOW_PRODUCTION_ORDERS WHERE IFLOW_P_ORDER_ID = #ListGetAt(attributes.iflow_p_order_id_list,i)#
                    </cfquery>
                </cfif>
            </cfloop>
        </cfif>
        <cfset attributes.iflow_master_plan_id = attributes.master_plan_id>
        <cfquery name="GET_MASTER_PLAN_INFO" datasource="#DSN3#">
            SELECT MASTER_PLAN_PROCESS, MASTER_PLAN_CAT_ID FROM EZGI_IFLOW_MASTER_PLAN WHERE MASTER_PLAN_ID = #attributes.master_plan_id#
        </cfquery>
        <cfif len(attributes.iid)>
         	<cfinclude template="add_ezgi_production_order_from_iflow_master.cfm"> <!---İş Emirleri Oluşturuluyor--->
        </cfif>
		<cfinclude template="upd_ezgi_iflow_production_parti_operations.cfm"> <!---Üretim Zamanı Hesaplama İşlemine Gidiyor--->
              
    </cftransaction>
</cflock>

<cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
	<script type="text/javascript">
        wrk_opener_reload();
        window.close();
	</script>
<cfelse>
	<cfif isdefined('iflow_p_order_id_')>
        <cflocation url="#request.self#?fuseaction=prod.upd_ezgi_iflow_production_order&iflow_p_order_id=#iflow_p_order_id_#" addtoken="No">
    <cfelse>
        <cflocation url="#request.self#?fuseaction=prod.list_ezgi_iflow_production_order" addtoken="No">
    </cfif>
</cfif>