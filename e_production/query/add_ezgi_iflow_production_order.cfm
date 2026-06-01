<!---
    File: add_ezgi_iflow_production_order.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

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
<cfquery name="GET_MASTER_PLAN_INFO" datasource="#DSN3#">
	SELECT MASTER_PLAN_PROCESS, MASTER_PLAN_CAT_ID FROM EZGI_IFLOW_MASTER_PLAN WHERE MASTER_PLAN_ID = #attributes.master_plan_id#
</cfquery>
<cfif not get_process_type.recordcount>
	<script type="text/javascript">
		alert('<cf_get_lang dictionary_id='645.Üretim Emri Kaydetmek İçin Süreçte Yetkili Olmalısınız'>!');
        window.history.go(-1);
	</script>
	<cfabort>
</cfif>
<!---Süreç Yetkisi Kontrolü--->
<cf_date tarih="attributes.p_order_date">
<cfif isdefined('attributes.p_start_date') and len(attributes.p_start_date)><cf_date tarih="attributes.p_start_date"></cfif>,
<cfif isdefined('attributes.p_finish_date') and len(attributes.p_finish_date)><cf_date tarih="attributes.p_finish_date"></cfif>,
<cflock name="#CREATEUUID()#" timeout="90">
    <cftransaction>
        <cfif attributes.record_num gt 0><!---Kaydedilecek İş Emri Satırı Varsa--->
        	<cfquery name="add_p_order_parti" datasource="#dsn3#" result="max_id"> <!---Parti Kaydı Yapılıyor--->
        		INSERT INTO 
                	EZGI_IFLOW_PRODUCTION_ORDERS_PARTI
                  	(
                    	P_ORDER_PARTI_DATE, 
                        P_ORDER_PARTI_NUMBER, 
                        P_ORDER_PARTI_TYPE,
                        P_ORDER_START_DATE,
                        P_ORDER_FINISH_DATE,
                        RECORD_EMP, 
                        RECORD_DATE, 
                        RECORD_IP
                  	)
				VALUES        
                	(
                    #attributes.p_order_date#,
                    #attributes.parti_no#,
                    #attributes.p_order_type#,
                    <cfif isdefined('attributes.p_start_date') and len(attributes.p_start_date)>#attributes.p_start_date#<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.p_finish_date') and len(attributes.p_finish_date)>#attributes.p_finish_date#<cfelse>NULL</cfif>,
                    #session.ep.userid#,
                    #now()#,
                   	'#cgi.remote_addr#'
                    )
        	</cfquery>
            <!---Yeni Kaydedilen Partinin Parti ID si alınıyor--->
        	<cfquery name="get_max_sira_no" datasource="#dsn3#">
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
            <!---Yeni Bir Lot No Alınıyor--->
            <cfquery name="get_gen_paper" datasource="#dsn3#">
                SELECT PRODUCTION_LOT_NUMBER FROM GENERAL_PAPERS WHERE GENERAL_PAPERS_ID = 1
            </cfquery>
            <cfset paper_number = get_gen_paper.PRODUCTION_LOT_NUMBER>
            <cfloop from="1" to="#attributes.record_num#" index="i"><!---Yeni Açılacak Üretim Emirleri Döndürülüyor --->
                <cfif isdefined('row_kontrol#i#') and Evaluate('row_kontrol#i#') gt 0>
                	<cfset paper_number = paper_number +1>
					<cfset paper_full = '#paper_number#'>
                    <cfif isdefined('attributes.ACTION_TYPE#i#') and Evaluate('attributes.ACTION_TYPE#i#') eq 3><!---Eğer Transfer İşlemi İse--->
                    	<cfquery name="add_p_order_row" datasource="#dsn3#">
                        	UPDATE       
                            	EZGI_IFLOW_PRODUCTION_ORDERS
							SET                
                            	REL_P_ORDER_ID = #MAX_ID.IDENTITYCOL#, 
                                MASTER_PLAN_ID = #attributes.master_plan_id#
							WHERE        
                            	 IFLOW_P_ORDER_ID = #Evaluate('ACTION_ID#i#')#
                        </cfquery>
                        <cfset emir_transfer = 1>
                    <cfelse><!---Eğer Yeni Kayıt İse--->
                        <cfquery name="add_p_order_row" datasource="#dsn3#"><!---Parti İş Emri Kaydediliyor--->
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
                                    #MAX_ID.IDENTITYCOL#,
                                    #Evaluate('attributes.type#i#')#,
                                    #Evaluate('attributes.stock_id#i#')#,
                                    #FilterNum(Evaluate('attributes.quantity#i#'),2)#,
                                    '#Evaluate('attributes.detail#i#')#',
                                    #attributes.process_stage#,
                                    #paper_full#,
                                    #attributes.p_order_date#,
                                    #sirano+i#,
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
                    </cfif>
                </cfif>
            </cfloop>
            <cfquery name="SET_MAX_PAPER" datasource="#dsn3#"> <!---Lot No Updete Ediliyor--->
                UPDATE       
                    GENERAL_PAPERS
                SET                
                    PRODUCTION_LOT_NUMBER = #paper_number#
                WHERE        
                    GENERAL_PAPERS_ID = 1
            </cfquery>
            <cfquery name="get_iid" datasource="#dsn3#"><!---En Son Parti İş Emri IS si alınıyor--->
                SELECT IFLOW_P_ORDER_ID FROM EZGI_IFLOW_PRODUCTION_ORDERS WHERE REL_P_ORDER_ID = #MAX_ID.IDENTITYCOL#
            </cfquery>
            <cfset attributes.iid = ValueList(get_iid.IFLOW_P_ORDER_ID)>
            <cfset attributes.iflow_master_plan_id = attributes.master_plan_id>
         	<cfquery name="upd_p_order" datasource="#dsn3#">
                    UPDATE 
                        EZGI_IFLOW_PRODUCTION_ORDERS
                    SET          
                        CUTTING_FINISH_DATE = #attributes.p_start_date#, 
                        START_DATE = #attributes.p_start_date#, 
                        FINISH_DATE = #attributes.p_finish_date#
                    FROM     
                        EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPO INNER JOIN
                        EZGI_IFLOW_PRODUCTION_ORDERS ON EIPO.P_ORDER_PARTI_ID = EZGI_IFLOW_PRODUCTION_ORDERS.REL_P_ORDER_ID
                    WHERE  
                        EIPO.P_ORDER_PARTI_ID = #MAX_ID.IDENTITYCOL#
         	</cfquery>
            <cfif not isdefined('emir_transfer')> <!---Transfer Değilse--->
            	<cfinclude template="add_ezgi_production_order_from_iflow_master.cfm"> <!---İş Emirleri Oluşturuluyor--->
              	<cfinclude template="upd_ezgi_iflow_production_parti_operations.cfm"> <!---Üretim Zamanı Hesaplama İşlemine Gidiyor--->
            <cfelse>
                <cfinclude template="upd_ezgi_iflow_production_parti_operations.cfm"> <!---Üretim Zamanı Hesaplama İşlemine Gidiyor--->
            	<script type="text/javascript">
					alert("<cf_get_lang dictionary_id='253.Transfer Başarıyla Tamamlandı'>!");
					wrk_opener_reload();
					window.close()
				</script>
            </cfif>
        <cfelse>
        	<cf_get_lang dictionary_id='646.Kaydedilecek Satır Bulunamadı'>.
        	<cfabort>
        </cfif>
    </cftransaction>
</cflock>
