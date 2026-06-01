<!---
    File: upd_ezgi_virtual_offer_row_spect_aktar.cfm
    Folder: Add_Ons\ezgi\e_sales\query
    Author: Ezgi Yazılım
    Date: 01/01/2022
    Description:
--->

<cfparam name="attributes.price_transfer_type" default="2"><!---Ürün Kartı Bağlantısız Fiyat Dosyası Aktarımı İçin--->
<cfif isdefined('attributes.upd')> <!---Mutfak Aktarım Fiyat Aktarım Sonrası Satır Fiyat Güncelleme--->
 	<cfquery name="get_company" datasource="#dsn3#">
     	SELECT     
       		ISNULL(EVO.SALES_COMPANY_ID, 0) AS SALES_COMPANY_ID, 
           	EVOR.STOCK_ID, 
          	S.PRODUCT_ID, 
          	S.PRODUCT_CATID, 
          	S.BRAND_ID
		FROM        
        	EZGI_VIRTUAL_OFFER_ROW AS EVOR WITH (NOLOCK) INNER JOIN
         	EZGI_VIRTUAL_OFFER AS EVO WITH (NOLOCK) ON EVOR.VIRTUAL_OFFER_ID = EVO.VIRTUAL_OFFER_ID INNER JOIN
          	STOCKS AS S WITH (NOLOCK) ON EVOR.STOCK_ID = S.STOCK_ID
		WHERE     
        	EVOR.EZGI_ID = #attributes.ezgi_id#
  	</cfquery>
    
    <!---**********Yeni Uygulama*****************--->
    <cfquery name="get_diff_rate" datasource="#dsn3#">
     	SELECT 
        	ISNULL(S.MIN_MARGIN,0) AS DIFF_RATE_,
            EVOR.BOY,
            EVOR.EN,
            EVOR.DERINLIK,
            ISNULL(EVOR.YON,0) AS YON
		FROM     
        	STOCKS AS S WITH (NOLOCK) INNER JOIN
         	EZGI_VIRTUAL_OFFER_ROW AS EVOR WITH (NOLOCK) ON S.STOCK_ID = EVOR.STOCK_ID
		WHERE  
       		EVOR.EZGI_ID = #attributes.ezgi_id#
	</cfquery>
    <cftransaction>
        <!---Değişikliği History Tablosuna Kaydediyoruz--->
        <cfquery name="add_history" datasource="#dsn3#" >
            INSERT INTO 
                EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY
                (
                    EZGI_ID, 
                    BOY,
                    EN,
                    DERINLIK,
                    YON,
                    HISTORY_TYPE, 
                    UPDATE_EMP, 
                    UPDATE_IP, 
                    UPDATE_DATE
                    <cfif isdefined('attributes.revision')>
                        , IS_REVISION
                        , MAILLIST
                    </cfif>
                )
                VALUES (
                    #attributes.ezgi_id#, 
                    1, 
                    #get_diff_rate.BOY#,
                    #get_diff_rate.EN#,
                    #get_diff_rate.DERINLIK#,
                    #get_diff_rate.YON#,
                    #session.ep.userid#, 
                    '#cgi.remote_addr#', 
                    #now()#
                    <cfif isdefined('attributes.revision')>
                        , #attributes.revision#
                        , '#attributes.mail_list#'
                    </cfif>
                )
        </cfquery>
        <cfquery name="max_id" datasource="#dsn3#">
            SELECT MAX(VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID) AS MAX_ID FROM EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY
        </cfquery>
        <cfquery name="add_row_detail_history" datasource="#dsn3#">
            INSERT INTO 
                EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ROW
                (
                    VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID, 
                    EZGI_ID, 
                    AMOUNT, 
                    LAST_AMOUNT, 
                    SALES_PRICE, 
                    SALES_PRICE_MONEY, 
                    PURCHASE_PRICE, 
                    PURCHASE_PRICE_MONEY, 
                    COST_PRICE, 
                    COST_PRICE_MONEY, 
                    STOCK_ID, 
                    PRODUCT_CODE_2, 
                    PRODUCT_CODE, 
                    PRODUCT_NAME, 
                    MAIN_UNIT, 
                    PIECE_ROW_ID, 
                    PIECE_TYPE, 
                    QUESTION_ID, 
                    IS_AMOUNT_CHANGE, 
                    IS_PRICE_CHANGE, 
                    BOY_FORMUL, 
                    EN_FORMUL, 
                    AMOUNT_FORMUL, 
                    NOT_STANDART_RATE, 
                    DESIGN_EN, 
                    DESIGN_BOY, 
                    PRIVATE_PRICE_TYPE, 
                    PRIVATE_PRICE_MONEY, 
                    PRIVATE_PRICE, 
                    RECORD_EMP, 
                    RECORD_IP, 
                    RECORD_DATE, 
                    PRICE_FORMUL
                )
                SELECT 
                    #max_id.MAX_ID#,
                    EZGI_ID, 
                    AMOUNT, 
                    LAST_AMOUNT, 
                    SALES_PRICE, 
                    SALES_PRICE_MONEY, 
                    PURCHASE_PRICE, 
                    PURCHASE_PRICE_MONEY, 
                    COST_PRICE, 
                    COST_PRICE_MONEY, 
                    STOCK_ID, 
                    PRODUCT_CODE_2, 
                    PRODUCT_CODE, 
                    PRODUCT_NAME, 
                    MAIN_UNIT, 
                    PIECE_ROW_ID, 
                    PIECE_TYPE, 
                    QUESTION_ID, 
                    IS_AMOUNT_CHANGE, 
                    IS_PRICE_CHANGE, 
                    BOY_FORMUL, 
                    EN_FORMUL, 
                    AMOUNT_FORMUL, 
                    NOT_STANDART_RATE, 
                    DESIGN_EN, 
                    DESIGN_BOY, 
                    PRIVATE_PRICE_TYPE, 
                    PRIVATE_PRICE_MONEY, 
                    PRIVATE_PRICE, 
                    RECORD_EMP, 
                    RECORD_IP, 
                    RECORD_DATE, 
                    PRICE_FORMUL
                FROM 
                    EZGI_VIRTUAL_OFFER_ROW_DETAIL
                WHERE 
                    EZGI_ID = #attributes.ezgi_id#
                ORDER BY
                    VIRTUAL_OFFER_ROW_DETAIL_ID ASC
        </cfquery>
        <!---Değişikliği History Tablosuna Kaydediyoruz--->

        <!---Eski Kaydı Siliyoruz--->
        <cfquery name="del_row" datasource="#dsn3#">
            DELETE FROM EZGI_VIRTUAL_OFFER_ROW_DETAIL WHERE EZGI_ID = #attributes.ezgi_id#
        </cfquery>
        <!---Yeni Kaydı Ekliyoruz--->
        <cfloop from="1" to="#attributes.record_num#" index="i">
            <cfif Evaluate('attributes.row_kontrol#i#') eq 1>
             	<cfquery name="add_row" datasource="#dsn3#"> <!--- Mutfak adekodan gelen satırlar Detay Sayfası Kaydediliyor--->
                  	INSERT INTO 
                     	EZGI_VIRTUAL_OFFER_ROW_DETAIL
                  	    (
                  	        EZGI_ID, 
                  	        AMOUNT, 
                  	        SALES_PRICE, 
                  	        PURCHASE_PRICE, 
                  	        COST_PRICE, 
                  	        SALES_PRICE_MONEY, 
                  	        PURCHASE_PRICE_MONEY, 
                  	        COST_PRICE_MONEY, 
                  	        PRODUCT_CODE, 
                  	        PRODUCT_NAME,
                  	        RECORD_DATE, 
                  	        RECORD_EMP, 
                  	        RECORD_IP
                  	    )
                  	VALUES        
                  	    (
                  	        #attributes.ezgi_id#,
                  	        #Filternum(Evaluate('attributes.amount#i#'),2)#,
                  	        <cfif get_diff_rate.DIFF_RATE_ and isdefined('attributes.is_rate#i#') and Evaluate('attributes.is_rate#i#') eq 1>
                  	        	<cfif len(Evaluate('attributes.sales_price#i#'))>#(FilterNum(Evaluate('attributes.sales_price#i#'),2)*get_diff_rate.DIFF_RATE_/100)+FilterNum(Evaluate('attributes.sales_price#i#'),2)#<cfelse>0</cfif>,
                  	            <cfif len(Evaluate('attributes.purchase_price#i#'))>#(FilterNum(Evaluate('attributes.purchase_price#i#'),2)*get_diff_rate.DIFF_RATE_/100)+FilterNum(Evaluate('attributes.purchase_price#i#'),2)#<cfelse>0</cfif>,
                  	            <cfif len(Evaluate('attributes.cost_price#i#'))>#(FilterNum(Evaluate('attributes.cost_price#i#'),2)*get_diff_rate.DIFF_RATE_/100)+FilterNum(Evaluate('attributes.cost_price#i#'),2)#<cfelse>0</cfif>,
                  	        <cfelse>
								<cfif len(Evaluate('attributes.sales_price#i#'))>#FilterNum(Evaluate('attributes.sales_price#i#'),2)#<cfelse>0</cfif>,
                  	          	<cfif len(Evaluate('attributes.purchase_price#i#'))>#FilterNum(Evaluate('attributes.purchase_price#i#'),2)#<cfelse>0</cfif>,
                  	          	<cfif len(Evaluate('attributes.cost_price#i#'))>#FilterNum(Evaluate('attributes.cost_price#i#'),2)#<cfelse>0</cfif>,
                  	        </cfif>
                            <cfif len(Evaluate('attributes.sales_price_money#i#'))>'#Evaluate('attributes.sales_price_money#i#')#'<cfelse>NULL</cfif>,
                  	      	<cfif len(Evaluate('attributes.purchase_price_money#i#'))>'#Evaluate('attributes.purchase_price_money#i#')#'<cfelse>NULL</cfif>,
                  	     	<cfif len(Evaluate('attributes.cost_price_money#i#'))>'#Evaluate('attributes.cost_price_money#i#')#'<cfelse>NULL</cfif>,
                            
                            <cfif len(Evaluate('attributes.PRODUCT_CODE#i#'))>'#Evaluate('attributes.PRODUCT_CODE#i#')#'<cfelse>NULL</cfif>,
                            <cfif len(Evaluate('attributes.PRODUCT_NAME#i#'))>'#Evaluate('attributes.PRODUCT_NAME#i#')#'<cfelse>NULL</cfif>,
                  	        #now()#,
                  	        #session.ep.userid#,
                  	        '#cgi.remote_addr#'
                  	    )
            	</cfquery>   
            </cfif>
        </cfloop>
    </cftransaction>
     <!---**********Yeni Uygulama*****************--->
     
   	<cfif get_company.SALES_COMPANY_ID gt 0 > <!---Bayi Teklifi İse--->
     	<cfquery name="get_discount_row" datasource="#dsn3#"> <!---Bayi için İskonto Bilgileri Bulunuyor--->
        	SELECT   
            	ISNULL(PRODUCT_ID,0) PRODUCT_ID,
             	ISNULL(BRAND_ID,0) BRAND_ID,  
              	ISNULL(PRODUCT_CATID,0) PRODUCT_CATID, 
            	ISNULL(DISCOUNT_RATE,0) AS DISCOUNT_RATE_1, 
             	ISNULL(DISCOUNT_RATE_2,0) AS DISCOUNT_RATE_2,
             	ISNULL(DISCOUNT_RATE_3,0) AS DISCOUNT_RATE_3,
            	ISNULL(DISCOUNT_RATE_4,0) AS DISCOUNT_RATE_4,
             	ISNULL(DISCOUNT_RATE_5,0) AS DISCOUNT_RATE_5
          	FROM        
           		PRICE_CAT_EXCEPTIONS WITH (NOLOCK)
         	WHERE     
            	ACT_TYPE = 1 AND 
              	COMPANY_ID = #get_company.SALES_COMPANY_ID# AND 
             	PRICE_CATID =
                                (
                                    SELECT     
                                        TOP (1) PRICE_CAT
                                    FROM        
                                        #dsn_alias#.COMPANY_CREDIT WITH (NOLOCK)
                                    WHERE     
                                        COMPANY_ID = #get_company.SALES_COMPANY_ID# AND 
                                        OUR_COMPANY_ID = #session.ep.company_id#
                                )
   		</cfquery>
		<cfquery name="get_discount_row_select" dbtype="query"><!--- Bayi İskonto Bilgilerinde İlgili Ürün İskontosu Tanımlanmış mı--->
        	SELECT * FROM get_discount_row WHERE PRODUCT_ID = #get_company.PRODUCT_ID#
     	</cfquery>
      	<cfif not get_discount_row_select.recordcount>
        	<cfquery name="get_discount_row_select" dbtype="query"><!--- Bayi İskonto Bilgilerinde İlgili Ürün Kategorisiyle İlgili İskonto Tanımlanmış mı--->
             	SELECT * FROM get_discount_row WHERE PRODUCT_CATID = #get_company.PRODUCT_CATID#
         	</cfquery>
     	</cfif>
    	<cfif not get_discount_row_select.recordcount>
         	<cfquery name="get_discount_row_select" dbtype="query"><!--- Bayi İskonto Bilgilerinde Tüm Ürünlerle İlgili İskonto Tanımlanmış mı--->
             	SELECT * FROM get_discount_row WHERE PRODUCT_CATID = 0 AND PRODUCT_ID = 0
         	</cfquery>
     	</cfif>
    	<cfquery name="get_offer_row" datasource="#dsn3#"> <!---Sanal Teklif Satırında Kayıtlı İskontolar Varmı--->
                SELECT 
                    ISNULL(P_DISCOUNT_1,0) P_DISCOUNT_1, 
                    ISNULL(P_DISCOUNT_2,0) P_DISCOUNT_2, 
                    ISNULL(P_DISCOUNT_3,0) P_DISCOUNT_3, 
                    ISNULL(P_DISCOUNT_4,0) P_DISCOUNT_4, 
                    ISNULL(P_DISCOUNT_5,0) P_DISCOUNT_5 
                FROM 
                    EZGI_VIRTUAL_OFFER_ROW WITH (NOLOCK)
                WHERE        
                    EZGI_ID = #attributes.ezgi_id#
   		</cfquery>
    	<cfif len(attributes.purchase_total)>
                <cfset bayi_net_fiyat = attributes.purchase_total>
     	<cfelse>
                <cfset bayi_net_fiyat = 0>
     	</cfif>
    	<cfif get_offer_row.P_DISCOUNT_1 gt 0 or get_offer_row.P_DISCOUNT_2 gt 0 or get_offer_row.P_DISCOUNT_3 gt 0 or get_offer_row.P_DISCOUNT_4 gt 0 or get_offer_row.P_DISCOUNT_5 gt 0> 
				<!---Eğer Satırlarda İskonto Tanımlı İse Bu iskontoları Dikkate Alarak Hesapla--->
				<cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_offer_row.P_DISCOUNT_1/100)>
                <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_offer_row.P_DISCOUNT_2/100)>
                <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_offer_row.P_DISCOUNT_3/100)>
                <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_offer_row.P_DISCOUNT_4/100)>
                <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_offer_row.P_DISCOUNT_5/100)>
                <cfset disc_1 = get_offer_row.P_DISCOUNT_1>
                <cfset disc_2 = get_offer_row.P_DISCOUNT_2>
                <cfset disc_3 = get_offer_row.P_DISCOUNT_3>
                <cfset disc_4 = get_offer_row.P_DISCOUNT_4>
                <cfset disc_5 = get_offer_row.P_DISCOUNT_5>
     	<cfelse> <!---Eğer Satırlarda İskonto Tanımlı Değil İse Cari İskonto Tanımlarındaki iskontoları Dikkate Alarak Hesapla--->
        	<cfif get_discount_row_select.recordcount>
					<cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_discount_row_select.DISCOUNT_RATE_1/100)>
                    <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_discount_row_select.DISCOUNT_RATE_2/100)>
                    <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_discount_row_select.DISCOUNT_RATE_3/100)>
                    <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_discount_row_select.DISCOUNT_RATE_4/100)>
                    <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_discount_row_select.DISCOUNT_RATE_5/100)>
                    <cfset disc_1 = get_discount_row_select.DISCOUNT_RATE_1>
                    <cfset disc_2 = get_discount_row_select.DISCOUNT_RATE_2>
                    <cfset disc_3 = get_discount_row_select.DISCOUNT_RATE_3>
                    <cfset disc_4 = get_discount_row_select.DISCOUNT_RATE_4>
                    <cfset disc_5 = get_discount_row_select.DISCOUNT_RATE_5>
         	<cfelse>
           		<cfif len(attributes.purchase_total)>
					<cfset bayi_net_fiyat = attributes.purchase_total>
             	<cfelse>
                	<cfset bayi_net_fiyat = 0>
              	</cfif>
        	</cfif>
     	</cfif>
	<cfelse> <!---Bayi Teklifi Değilse--->
    	<cfif len(attributes.purchase_total)>
        	<cfset bayi_net_fiyat = attributes.purchase_total>
      	<cfelse>
         	<cfset bayi_net_fiyat = 0>
      	</cfif>
 	</cfif>
	<cfquery name="upd_row" datasource="#dsn3#">
            UPDATE       
                EZGI_VIRTUAL_OFFER_ROW
            SET                
                <cfif isdefined('is_price_change')><!---Fiyat Değişim Yoksa Sadece Maliyet Fiyatı Güncelleniyor --->
                	 <!---**********Yeni Uygulama*****************--->
                     PRICE = #FilterNum(attributes.total,2)#,
                   	<!---**********Yeni Uygulama*****************--->
                    <!---PRICE = #attributes.toplam#,---> 
                    OTHER_MONEY = '#attributes.money#',
                    PURCHASE_PRICE = #bayi_net_fiyat#,
                    PURCHASE_PRICE_MONEY = '#attributes.money#',
                    P_PURCHASE_PRICE = <cfif len(attributes.purchase_total)>#attributes.purchase_total#<cfelse>0</cfif>, 
                    P_PURCHASE_PRICE_MONEY = '#attributes.money#',
                    P_DISCOUNT_1 = <cfif isdefined('disc_1')>#disc_1#<cfelse>0</cfif>,
                    P_DISCOUNT_2 = <cfif isdefined('disc_2')>#disc_2#<cfelse>0</cfif>,
                    P_DISCOUNT_3 = <cfif isdefined('disc_3')>#disc_3#<cfelse>0</cfif>,
                    P_DISCOUNT_4 = <cfif isdefined('disc_4')>#disc_4#<cfelse>0</cfif>,
                    P_DISCOUNT_5 = <cfif isdefined('disc_5')>#disc_5#<cfelse>0</cfif>,
                </cfif>
             	COST_PRICE = #attributes.cost_total#,
             	COST_PRICE_MONEY = '#attributes.money#',
                UPDATE_DATE = #now()#,
                UPDATE_EMP = #session.ep.userid#,
                UPDATE_IP = '#cgi.remote_addr#'
            WHERE        
                EZGI_ID = #attributes.ezgi_id#
 	</cfquery>
    <script type="text/javascript">
		wrk_opener_reload();
		window.close();
	</script>
<cfelseif isdefined('attributes.price_upd')> <!---Maliyet ve Bayi Alış Güncelleme Yapılacaksa--->
	<cfquery name="upd_row" datasource="#dsn3#">
     	UPDATE       
        	EZGI_VIRTUAL_OFFER_ROW
      	SET                
       		PURCHASE_PRICE = #FilterNum(attributes.purchase_price_,2)#,
        	PURCHASE_PRICE_MONEY = '#attributes.p_purchase_price_money_#',
         	COST_PRICE = #FilterNum(attributes.cost_price_,2)#,
         	COST_PRICE_MONEY = '#attributes.cost_price_money_#',
            P_PURCHASE_PRICE = #FilterNum(attributes.p_purchase_price_,2)#, 
         	P_PURCHASE_PRICE_MONEY = '#attributes.p_purchase_price_money_#', 
          	P_DISCOUNT_1 = #FilterNum(attributes.p_discount_1_,2)#, 
           	P_DISCOUNT_2 = #FilterNum(attributes.p_discount_2_,2)#, 
           	P_DISCOUNT_3 = #FilterNum(attributes.p_discount_3_,2)#,
            UPDATE_DATE = #now()#,
            UPDATE_EMP = #session.ep.userid#,
            UPDATE_IP = '#cgi.remote_addr#'
     	WHERE        
       		EZGI_ID = #attributes.ezgi_id#
  	</cfquery>
    <script type="text/javascript">
		alert('<cf_get_lang_main no='1428.Güncelleme İşleminiz Başarıyla Tamamlanmıştır.'>!');
		wrk_opener_reload();
		window.close();
	</script>
    <cfabort>
<cfelseif isdefined('attributes.upd_standart')><!---Kapı Tanımlama Sayfasından Geliyorsa--->
	<cfif isdefined('attributes.import_file_type') and attributes.import_file_type eq 5> <!---Kapı Sayfasından Resim Gönderilmişse--->
    	<cfset ajaxImageUpload = isdefined('attributes.ajax_upload') and attributes.ajax_upload eq 1>
    	<cfset upload_folder = "#upload_folder#temp#dir_seperator#">
        <cfset imageUploadResponse = {
            success = false,
            message = "",
            file_name = "",
            file_path = ""
        }>
        <cftry>
            <cffile action = "upload" 
                    fileField = "uploaded_file" 
                    destination = "#upload_folder#"
                    nameConflict = "MakeUnique"  
                    mode="777">
            <cfif not listFindNoCase("jpg,jpeg,png,bmp,gif,webp", cffile.serverfileext)>
                <cfif ajaxImageUpload>
                    <cfset imageUploadResponse.message = "Resim Dosyası Uzantıları JPG, JPEG, PNG, BMP, GIF veya WEBP olmalıdır.">
                    <cfoutput>__SPECT_IMAGE_UPLOAD_JSON_START__#serializeJSON(imageUploadResponse)#__SPECT_IMAGE_UPLOAD_JSON_END__</cfoutput>
                    <cfabort>
                <cfelse>
                    <script type="text/javascript">
                        alert("Resim Dosyası Uzantıları JPG, JPEG, PNG, BMP, GIF veya WEBP olmalıdır.");
                        history.back();
                    </script>
                    <cfabort>
                </cfif>
            </cfif>
            <cfset file_name = "#createUUID()#.#cffile.serverfileext#">	
            <cffile action="rename" source="#upload_folder##cffile.serverfile#" destination="#upload_folder##file_name#">	
            <cfset file_size = cffile.filesize>
            <cfcatch type="Any">
                <cfif ajaxImageUpload>
                    <cfset imageUploadResponse.message = cfcatch.message>
                    <cfoutput>__SPECT_IMAGE_UPLOAD_JSON_START__#serializeJSON(imageUploadResponse)#__SPECT_IMAGE_UPLOAD_JSON_END__</cfoutput>
                    <cfabort>
                </cfif>
                    <cfoutput>#cfcatch.detail#</cfoutput>
                <cfabort>
            </cfcatch>  
        </cftry>
        <cfquery name="del_file" datasource="#dsn3#"> <!---Satırla İlgili Varsa Kayıt Siliniyor--->
            DELETE FROM EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE WHERE EZGI_ID = #attributes.ezgi_id# AND FILE_TYPE_ID = #attributes.import_file_type#
        </cfquery>
        <cfquery name="add_fie" datasource="#dsn3#"><!--- Yeni İçeriye Alınan Dosyanın Database Kaydı Yapılıyor--->
            INSERT INTO 
                EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE
                (
                    EZGI_ID, 
                    FILE_TYPE_ID, 
                    FILE_NAME,
                    FILE_NAME_OLD,
                    RECORD_DATE, 
                    RECORD_EMP, 
                    RECORD_IP
                )
            VALUES        
                (
                    #attributes.ezgi_id#,
                    #attributes.import_file_type#,
                    '#file_name#',
                    '#Left(cffile.serverFile,100)#',
                    #now()#,
                    #session.ep.userid#,
                    '#cgi.remote_addr#'
                )
        </cfquery>
        <cfif ajaxImageUpload>
            <cfset imageUploadResponse.success = true>
            <cfset imageUploadResponse.message = "Resim yükleme işlemi başarıyla tamamlandı.">
            <cfset imageUploadResponse.file_name = file_name>
            <cfset imageUploadResponse.file_path = "/documents/temp/#file_name#">
            <cfoutput>__SPECT_IMAGE_UPLOAD_JSON_START__#serializeJSON(imageUploadResponse)#__SPECT_IMAGE_UPLOAD_JSON_END__</cfoutput>
            <cfabort>
        </cfif>
    <cfelse>
        <cftransaction>
            <cfquery name="get_company" datasource="#dsn3#">
                SELECT     
                     ISNULL(EVO.SALES_COMPANY_ID, 0) AS SALES_COMPANY_ID, 
                     EVOR.STOCK_ID, 
                     S.PRODUCT_ID, 
                     S.PRODUCT_CATID, 
                     S.BRAND_ID
                FROM        
                    EZGI_VIRTUAL_OFFER_ROW AS EVOR WITH (NOLOCK) INNER JOIN
                    EZGI_VIRTUAL_OFFER AS EVO WITH (NOLOCK) ON EVOR.VIRTUAL_OFFER_ID = EVO.VIRTUAL_OFFER_ID INNER JOIN
                    STOCKS AS S ON EVOR.STOCK_ID = S.STOCK_ID
                WHERE     
                    EVOR.EZGI_ID = #attributes.ezgi_id#
            </cfquery>
            <cfif get_company.SALES_COMPANY_ID gt 0 > <!---Bayi Teklifi İse--->
                <cfquery name="get_discount_row" datasource="#dsn3#"> <!---Bayi için İskonto Bilgileri Bulunuyor--->
                    SELECT   
                        ISNULL(PRODUCT_ID,0) PRODUCT_ID,
                        ISNULL(BRAND_ID,0) BRAND_ID,  
                        ISNULL(PRODUCT_CATID,0) PRODUCT_CATID, 
                        ISNULL(DISCOUNT_RATE,0) AS DISCOUNT_RATE_1, 
                        ISNULL(DISCOUNT_RATE_2,0) AS DISCOUNT_RATE_2,
                        ISNULL(DISCOUNT_RATE_3,0) AS DISCOUNT_RATE_3,
                        ISNULL(DISCOUNT_RATE_4,0) AS DISCOUNT_RATE_4,
                        ISNULL(DISCOUNT_RATE_5,0) AS DISCOUNT_RATE_5
                    FROM        
                        PRICE_CAT_EXCEPTIONS WITH (NOLOCK)
                    WHERE     
                        ACT_TYPE = 1 AND 
                        COMPANY_ID = #get_company.SALES_COMPANY_ID# AND 
                        PRICE_CATID =
                                    (
                                        SELECT     
                                            TOP (1) PRICE_CAT
                                        FROM        
                                            #dsn_alias#.COMPANY_CREDIT WITH (NOLOCK)
                                        WHERE     
                                            COMPANY_ID = #get_company.SALES_COMPANY_ID# AND 
                                            OUR_COMPANY_ID = #session.ep.company_id#
                                    )
                </cfquery>
                <cfquery name="get_discount_row_select" dbtype="query"><!--- Bayi İskonto Bilgilerinde İlgili Ürün İskontosu Tanımlanmış mı--->
                    SELECT * FROM get_discount_row WHERE PRODUCT_ID = #get_company.PRODUCT_ID#
                </cfquery>
                <cfif not get_discount_row_select.recordcount>
                    <cfquery name="get_discount_row_select" dbtype="query"><!--- Bayi İskonto Bilgilerinde İlgili Ürün Kategorisiyle İlgili İskonto Tanımlanmış mı--->
                        SELECT * FROM get_discount_row WHERE PRODUCT_CATID = #get_company.PRODUCT_CATID#
                    </cfquery>
                </cfif>
                <cfif not get_discount_row_select.recordcount>
                    <cfquery name="get_discount_row_select" dbtype="query"><!--- Bayi İskonto Bilgilerinde Tüm Ürünlerle İlgili İskonto Tanımlanmış mı--->
                        SELECT * FROM get_discount_row WHERE PRODUCT_CATID = 0 AND PRODUCT_ID = 0
                    </cfquery>
                </cfif>
                <cfquery name="get_offer_row" datasource="#dsn3#"> <!---Sanal Teklif Satırında Kayıtlı İskontolar Varmı--->
                    SELECT 
                        ISNULL(P_DISCOUNT_1,0) P_DISCOUNT_1, 
                        ISNULL(P_DISCOUNT_2,0) P_DISCOUNT_2, 
                        ISNULL(P_DISCOUNT_3,0) P_DISCOUNT_3, 
                        ISNULL(P_DISCOUNT_4,0) P_DISCOUNT_4, 
                        ISNULL(P_DISCOUNT_5,0) P_DISCOUNT_5 
                    FROM 
                        EZGI_VIRTUAL_OFFER_ROW WITH (NOLOCK)
                    WHERE        
                        EZGI_ID = #attributes.ezgi_id#
                </cfquery>
                <cfif len(attributes.purchase_total)>
                    <cfset bayi_net_fiyat = attributes.purchase_total>
                <cfelse>
                    <cfset bayi_net_fiyat = 0>
                </cfif>
                <cfif get_offer_row.P_DISCOUNT_1 gt 0 or get_offer_row.P_DISCOUNT_2 gt 0 or get_offer_row.P_DISCOUNT_3 gt 0 or get_offer_row.P_DISCOUNT_4 gt 0 or get_offer_row.P_DISCOUNT_5 gt 0> 
                    <!---Eğer Satırlarda İskonto Tanımlı İse Bu iskontoları Dikkate Alarak Hesapla--->
                    <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_offer_row.P_DISCOUNT_1/100)>
                    <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_offer_row.P_DISCOUNT_2/100)>
                    <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_offer_row.P_DISCOUNT_3/100)>
                    <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_offer_row.P_DISCOUNT_4/100)>
                    <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_offer_row.P_DISCOUNT_5/100)>
                    <cfset disc_1 = get_offer_row.P_DISCOUNT_1>
                    <cfset disc_2 = get_offer_row.P_DISCOUNT_2>
                    <cfset disc_3 = get_offer_row.P_DISCOUNT_3>
                    <cfset disc_4 = get_offer_row.P_DISCOUNT_4>
                    <cfset disc_5 = get_offer_row.P_DISCOUNT_5>
                <cfelse> <!---Eğer Satırlarda İskonto Tanımlı Değil İse Cari İskonto Tanımlarındaki iskontoları Dikkate Alarak Hesapla--->
                    <cfif get_discount_row_select.recordcount>
                        <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_discount_row_select.DISCOUNT_RATE_1/100)>
                        <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_discount_row_select.DISCOUNT_RATE_2/100)>
                        <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_discount_row_select.DISCOUNT_RATE_3/100)>
                        <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_discount_row_select.DISCOUNT_RATE_4/100)>
                        <cfset bayi_net_fiyat = bayi_net_fiyat - (bayi_net_fiyat*get_discount_row_select.DISCOUNT_RATE_5/100)>
                        <cfset disc_1 = get_discount_row_select.DISCOUNT_RATE_1>
                        <cfset disc_2 = get_discount_row_select.DISCOUNT_RATE_2>
                        <cfset disc_3 = get_discount_row_select.DISCOUNT_RATE_3>
                        <cfset disc_4 = get_discount_row_select.DISCOUNT_RATE_4>
                        <cfset disc_5 = get_discount_row_select.DISCOUNT_RATE_5>
                    <cfelse>
                        <cfif len(attributes.purchase_total)>
                            <cfset bayi_net_fiyat = attributes.purchase_total>
                        <cfelse>
                            <cfset bayi_net_fiyat = 0>
                        </cfif>
                    </cfif>	
                </cfif>
            <cfelse> <!---Bayi Teklifi Değilse--->
                <cfif len(attributes.purchase_total)>
                    <cfset bayi_net_fiyat = attributes.purchase_total>
                <cfelse>
                    <cfset bayi_net_fiyat = 0>
                </cfif>
            </cfif>
            <cfquery name="get_row_info" datasource="#dsn3#">
                SELECT
                    BOY,
                    EN,
                    DERINLIK,
                    ISNULL(YON,0) AS YON
                FROM
                    EZGI_VIRTUAL_OFFER_ROW
                WHERE EZGI_ID = #attributes.ezgi_id#
            </cfquery>
            <cfquery name="upd_row" datasource="#dsn3#">
                UPDATE       
                    EZGI_VIRTUAL_OFFER_ROW
                SET    
                    <cfif isdefined('is_price_change')> <!---Fiyat Değişim Yoksa Sadece Maliyet Fiyatı Güncelleniyor --->    
                        PRICE = #attributes.toplam#, 
                        OTHER_MONEY = '#attributes.money#',
                        PURCHASE_PRICE = #bayi_net_fiyat#,
                        PURCHASE_PRICE_MONEY = '#attributes.money#',
                        P_PURCHASE_PRICE = <cfif len(attributes.purchase_total)>#attributes.purchase_total#<cfelse>0</cfif>, 
                        P_PURCHASE_PRICE_MONEY = '#attributes.money#',
                        P_DISCOUNT_1 = <cfif isdefined('disc_1')>#disc_1#<cfelse>0</cfif>,
                        P_DISCOUNT_2 = <cfif isdefined('disc_2')>#disc_2#<cfelse>0</cfif>,
                        P_DISCOUNT_3 = <cfif isdefined('disc_3')>#disc_3#<cfelse>0</cfif>,
                        P_DISCOUNT_4 = <cfif isdefined('disc_4')>#disc_4#<cfelse>0</cfif>,
                        P_DISCOUNT_5 = <cfif isdefined('disc_5')>#disc_5#<cfelse>0</cfif>,
                    </cfif>
                    COST_PRICE = <cfif len(attributes.cost_total)>#attributes.cost_total#<cfelse>0</cfif>,
                    COST_PRICE_MONEY = '#attributes.money#',
                    BOY = #attributes.height#,
                    EN = #attributes.width#,
                    DERINLIK = #attributes.depth#,
                    YON = #attributes.side#,
                    UPDATE_DATE = #now()#,
                    UPDATE_EMP = #session.ep.userid#,
                    UPDATE_IP = '#cgi.remote_addr#'
                WHERE        
                    EZGI_ID = #attributes.ezgi_id#
            </cfquery>
            <!---Değişikliği History Tablosuna Kaydediyoruz--->
            <cfquery name="add_history" datasource="#dsn3#" >
                INSERT INTO 
                    EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY
                    (
                        EZGI_ID, 
                        BOY,
                        EN,
                        DERINLIK,
                        YON,
                        HISTORY_TYPE, 
                        UPDATE_EMP, 
                        UPDATE_IP, 
                        UPDATE_DATE
                    <cfif isdefined('attributes.revision')>
                        , IS_REVISION
                        , MAILLIST
                    </cfif>
                    )
                    VALUES (
                        #attributes.ezgi_id#, 
                        #get_row_info.BOY#,
                        #get_row_info.EN#,
                        #get_row_info.DERINLIK#,
                        #get_row_info.YON#,
                        2, 
                        #session.ep.userid#, 
                        '#cgi.remote_addr#', 
                        #now()#
                        <cfif isdefined('attributes.revision')>
                            , #attributes.revision#
                            , '#attributes.mail_list#'
                        </cfif>
                    )
            </cfquery>
            <cfquery name="max_id" datasource="#dsn3#">
                SELECT MAX(VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID) AS MAX_ID FROM EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY
            </cfquery>
            <cfquery name="add_row_detail_history" datasource="#dsn3#">
                INSERT INTO 
                    EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ROW
                    (
                        VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID, 
                        EZGI_ID, 
                        AMOUNT, 
                        LAST_AMOUNT, 
                        SALES_PRICE, 
                        SALES_PRICE_MONEY, 
                        PURCHASE_PRICE, 
                        PURCHASE_PRICE_MONEY, 
                        COST_PRICE, 
                        COST_PRICE_MONEY, 
                        STOCK_ID, 
                        PRODUCT_CODE_2, 
                        PRODUCT_CODE, 
                        PRODUCT_NAME, 
                        MAIN_UNIT, 
                        PIECE_ROW_ID, 
                        PIECE_TYPE, 
                        QUESTION_ID, 
                        IS_AMOUNT_CHANGE, 
                        IS_PRICE_CHANGE, 
                        BOY_FORMUL, 
                        EN_FORMUL, 
                        AMOUNT_FORMUL, 
                        NOT_STANDART_RATE, 
                        DESIGN_EN, 
                        DESIGN_BOY, 
                        PRIVATE_PRICE_TYPE, 
                        PRIVATE_PRICE_MONEY, 
                        PRIVATE_PRICE, 
                        RECORD_EMP, 
                        RECORD_IP, 
                        RECORD_DATE, 
                        PRICE_FORMUL
                    )
                    SELECT 
                        #max_id.MAX_ID#,
                        EZGI_ID, 
                        AMOUNT, 
                        LAST_AMOUNT, 
                        SALES_PRICE, 
                        SALES_PRICE_MONEY, 
                        PURCHASE_PRICE, 
                        PURCHASE_PRICE_MONEY, 
                        COST_PRICE, 
                        COST_PRICE_MONEY, 
                        STOCK_ID, 
                        PRODUCT_CODE_2, 
                        PRODUCT_CODE, 
                        PRODUCT_NAME, 
                        MAIN_UNIT, 
                        PIECE_ROW_ID, 
                        PIECE_TYPE, 
                        QUESTION_ID, 
                        IS_AMOUNT_CHANGE, 
                        IS_PRICE_CHANGE, 
                        BOY_FORMUL, 
                        EN_FORMUL, 
                        AMOUNT_FORMUL, 
                        NOT_STANDART_RATE, 
                        DESIGN_EN, 
                        DESIGN_BOY, 
                        PRIVATE_PRICE_TYPE, 
                        PRIVATE_PRICE_MONEY, 
                        PRIVATE_PRICE, 
                        RECORD_EMP, 
                        RECORD_IP, 
                        RECORD_DATE, 
                        PRICE_FORMUL
                    FROM 
                        EZGI_VIRTUAL_OFFER_ROW_DETAIL
                    WHERE 
                        EZGI_ID = #attributes.ezgi_id#
                    ORDER BY
                        VIRTUAL_OFFER_ROW_DETAIL_ID ASC
            </cfquery>
            <!---Değişikliği History Tablosuna Kaydediyoruz--->

            <!---Eski Kaydı Siliyoruz--->
            <cfquery name="del_row" datasource="#dsn3#">
                DELETE FROM EZGI_VIRTUAL_OFFER_ROW_DETAIL WHERE EZGI_ID = #attributes.ezgi_id#
            </cfquery>
            <cfif ListLen(attributes.piece_row_id)><!--- Kapı İçin Soru sorulan veya hesap yapılan satır varmı--->
                <cfloop list="#attributes.piece_row_id#" index="i">
                    <cfif isdefined('attributes.piece_type_#i#') and Evaluate('attributes.piece_type_#i#') eq 4><!---Satır Hammadde ise--->
                        <cfif isdefined('attributes.alternative_stock_id_4_#i#')><!---Alternatif Sorulmuşmu--->
                            <cfquery name="get_stock_id" datasource="#dsn3#">
                                SELECT 
                                    STOCK_ID,
                                    PRODUCT_CODE, 
                                    PRODUCT_NAME, 
                                    (SELECT MAIN_UNIT FROM PRODUCT_UNIT WHERE PRODUCT_UNIT_ID = STOCKS.PRODUCT_UNIT_ID AND IS_MAIN = 1) AS MAIN_UNIT
                                FROM 
                                    STOCKS  WITH (NOLOCK)
                                WHERE 
                                    STOCK_ID=#Evaluate('attributes.alternative_stock_id_4_#i#')#
                            </cfquery>
                        <cfelse><!---Alternatif Soulmadıysa Kendisi--->
                            <cfquery name="get_stock_id" datasource="#dsn3#">
                                SELECT        
                                    PIECE_RELATED_ID STOCK_ID, 
                                    PIECE_NAME PRODUCT_NAME, 
                                    PIECE_CODE PRODUCT_CODE,
                                    (SELECT DEFAULT_PIECE_UNIT FROM EZGI_DESIGN_DEFAULTS) AS MAIN_UNIT
                                FROM            
                                    EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
                                WHERE        
                                    PIECE_ROW_ID = #i#
                            </cfquery>
                        </cfif>
                    <cfelseif isdefined('attributes.piece_type_#i#') and Evaluate('attributes.piece_type_#i#') eq 1> <!---Satır Yonga Levha İse (1)--->
                        <cfif isdefined('attributes.alternative_stock_id_1_#i#')><!---Alternatif Sorulmuşmu--->
                            <cfquery name="get_stock_id" datasource="#dsn3#">
                                SELECT        
                                    PIECE_ROW_ID STOCK_ID, 
                                    PIECE_NAME PRODUCT_NAME, 
                                    PIECE_CODE PRODUCT_CODE,
                                    (SELECT DEFAULT_PIECE_UNIT FROM EZGI_DESIGN_DEFAULTS) AS MAIN_UNIT
                                FROM            
                                    EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
                                WHERE        
                                    PIECE_ROW_ID = #Evaluate('attributes.alternative_stock_id_1_#i#')#
                            </cfquery>
                        <cfelse><!---Alternatif Soulmadıysa Kendisi--->
                            <cfquery name="get_stock_id" datasource="#dsn3#">
                                SELECT        
                                    PIECE_ROW_ID STOCK_ID, 
                                    PIECE_NAME PRODUCT_NAME, 
                                    PIECE_CODE PRODUCT_CODE,
                                    (SELECT DEFAULT_PIECE_UNIT FROM EZGI_DESIGN_DEFAULTS) AS MAIN_UNIT
                                FROM            
                                    EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
                                WHERE        
                                    PIECE_ROW_ID = #i#
                            </cfquery>
                        </cfif>
                    <cfelseif isdefined('attributes.piece_type_#i#') and Evaluate('attributes.piece_type_#i#') eq 2> <!---Satır Genel Reçete İse (2)--->
                        <cfif isdefined('attributes.alternative_stock_id_2_#i#')><!---Alternatif Sorulmuşmu--->
                            <cfquery name="get_stock_id" datasource="#dsn3#">
                                SELECT        
                                    PIECE_ROW_ID STOCK_ID, 
                                    PIECE_NAME PRODUCT_NAME, 
                                    PIECE_CODE PRODUCT_CODE,
                                    (SELECT DEFAULT_PIECE_UNIT FROM EZGI_DESIGN_DEFAULTS) AS MAIN_UNIT
                                FROM            
                                    EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
                                WHERE        
                                    PIECE_ROW_ID = #Evaluate('attributes.alternative_stock_id_2_#i#')#
                            </cfquery>
                        <cfelse><!---Alternatif Soulmadıysa Kendisi--->
                            <cfquery name="get_stock_id" datasource="#dsn3#">
                                SELECT        
                                    PIECE_ROW_ID STOCK_ID, 
                                    PIECE_NAME PRODUCT_NAME, 
                                    PIECE_CODE PRODUCT_CODE,
                                    (SELECT DEFAULT_PIECE_UNIT FROM EZGI_DESIGN_DEFAULTS) AS MAIN_UNIT
                                FROM            
                                    EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
                                WHERE        
                                    PIECE_ROW_ID = #i#
                            </cfquery>
                        </cfif>
                    <cfelseif isdefined('attributes.piece_type_#i#') and Evaluate('attributes.piece_type_#i#') eq 3> <!---Satır Montaj Ürünü İse (3)--->
                        <cfif isdefined('attributes.alternative_stock_id_3_#i#')><!---Alternatif Sorulmuşmu--->
                            <cfquery name="get_stock_id" datasource="#dsn3#">
                                SELECT        
                                    PIECE_ROW_ID STOCK_ID, 
                                    PIECE_NAME PRODUCT_NAME, 
                                    PIECE_CODE PRODUCT_CODE,
                                    (SELECT DEFAULT_PIECE_UNIT FROM EZGI_DESIGN_DEFAULTS) AS MAIN_UNIT
                                FROM            
                                    EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
                                WHERE        
                                    PIECE_ROW_ID = #Evaluate('attributes.alternative_stock_id_3_#i#')#
                            </cfquery>
                        <cfelse><!---Alternatif Soulmadıysa Kendisi--->
                            <cfquery name="get_stock_id" datasource="#dsn3#">
                                SELECT        
                                    PIECE_ROW_ID STOCK_ID, 
                                    PIECE_NAME PRODUCT_NAME, 
                                    PIECE_CODE PRODUCT_CODE,
                                    (SELECT DEFAULT_PIECE_UNIT FROM EZGI_DESIGN_DEFAULTS) AS MAIN_UNIT
                                FROM            
                                    EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
                                WHERE        
                                    PIECE_ROW_ID = #i#
                            </cfquery>
                        </cfif>
                    <cfelseif isdefined('attributes.piece_type_#i#') and Evaluate('attributes.piece_type_#i#') eq 0> <!---Satır Ana Ürün mü--->
                        <cfquery name="get_stock_id" datasource="#dsn3#">
                            SELECT 
                                STOCK_ID,
                                PRODUCT_CODE, 
                                PRODUCT_NAME, 
                                (SELECT MAIN_UNIT FROM PRODUCT_UNIT WHERE PRODUCT_UNIT_ID = STOCKS.PRODUCT_UNIT_ID AND IS_MAIN = 1) AS MAIN_UNIT
                            FROM 
                                STOCKS WITH (NOLOCK)
                            WHERE 
                                STOCK_ID= #attributes.stock_id_0#
                        </cfquery>
                    </cfif>
                    <cfquery name="add_row" datasource="#dsn3#"> <!---Kapının Satır Detayları Kaydediliyor--->
                        INSERT INTO 
                            EZGI_VIRTUAL_OFFER_ROW_DETAIL
                                (
                                    EZGI_ID, 
                                    AMOUNT, 
                                    LAST_AMOUNT, 
                                    SALES_PRICE, 
                                    SALES_PRICE_MONEY, 
                                    PURCHASE_PRICE, 
                                    PURCHASE_PRICE_MONEY, 
                                    COST_PRICE, 
                                    COST_PRICE_MONEY, 
                                    STOCK_ID, 
                                    PRODUCT_CODE, 
                                    PRODUCT_NAME, 
                                    MAIN_UNIT,
                                    PIECE_ROW_ID,
                                    PIECE_TYPE,
                                    QUESTION_ID,
                                    IS_AMOUNT_CHANGE,
                                    IS_PRICE_CHANGE,
                                    BOY_FORMUL,
                                    EN_FORMUL,
                                    AMOUNT_FORMUL,
                                    PRICE_FORMUL,
                                    NOT_STANDART_RATE,
                                    DESIGN_BOY,
                                    DESIGN_EN,
                                    PRIVATE_PRICE_TYPE, 
                                    PRIVATE_PRICE_MONEY, 
                                    PRIVATE_PRICE,
                                    RECORD_DATE, 
                                    RECORD_EMP, 
                                    RECORD_IP
                                )
                        VALUES        
                                (
                                    #attributes.ezgi_id#,
                                    #FilterNum(Evaluate('piece_amount_#i#'),4)#,
                                    <cfif isdefined('amount2_#i#')>#FilterNum(Evaluate('amount2_#i#'),4)#<cfelse>#FilterNum(Evaluate('piece_amount_#i#'),4)#</cfif>,
                                    <cfif len(Evaluate('attributes.SALES_PRICE_#i#'))>#Evaluate('attributes.SALES_PRICE_#i#')#<cfelse>0</cfif>,
                                    '#Evaluate('attributes.SALES_PRICE_MONEY_#i#')#',
                                    <cfif len(Evaluate('attributes.PURCHASE_PRICE_#i#'))>#Evaluate('attributes.PURCHASE_PRICE_#i#')#<cfelse>0</cfif>,
                                    '#Evaluate('attributes.PURCHASE_PRICE_MONEY_#i#')#',
                                    <cfif len(Evaluate('attributes.COST_PRICE_#i#'))>#Evaluate('attributes.COST_PRICE_#i#')#<cfelse>0</cfif>,
                                    '#Evaluate('attributes.COST_PRICE_MONEY_#i#')#',
                                    #get_stock_id.STOCK_ID#,
                                    '#get_stock_id.PRODUCT_CODE#',
                                    '#get_stock_id.PRODUCT_NAME#',
                                    '#get_stock_id.MAIN_UNIT#',
                                    #i#,
                                    #Evaluate('attributes.PIECE_TYPE_#i#')#,
                                    <cfif isdefined('attributes.QUESTION_ID_#i#') and LEN(Evaluate('attributes.QUESTION_ID_#i#'))>#Evaluate('attributes.QUESTION_ID_#i#')#<cfelse>NULL</cfif>,
                                    #Evaluate('attributes.IS_AMOUNT_CHANGE_#i#')#,
                                    #Evaluate('attributes.IS_PRICE_CHANGE_#i#')#,
                                    <cfif isdefined('attributes.BOY_FORMUL_#i#') and LEN(Evaluate('attributes.BOY_FORMUL_#i#'))>'#Evaluate('attributes.BOY_FORMUL_#i#')#'<cfelse>NULL</cfif>,
                                    <cfif isdefined('attributes.EN_FORMUL_#i#') and LEN(Evaluate('attributes.EN_FORMUL_#i#'))>'#Evaluate('attributes.EN_FORMUL_#i#')#'<cfelse>NULL</cfif>,
                                    <cfif isdefined('attributes.AMOUNT_FORMUL_#i#') and LEN(Evaluate('attributes.AMOUNT_FORMUL_#i#'))>'#Evaluate('attributes.AMOUNT_FORMUL_#i#')#'<cfelse>NULL</cfif>,
                                    <cfif isdefined('attributes.PRICE_FORMUL_#i#') and LEN(Evaluate('attributes.PRICE_FORMUL_#i#'))>'#Evaluate('attributes.PRICE_FORMUL_#i#')#'<cfelse>NULL</cfif>,
                                    <cfif isdefined('attributes.not_standart_rate') and len(attributes.not_standart_rate)>#attributes.not_standart_rate#<cfelse>0</cfif>,
                                    <cfif isdefined('attributes.BOY_#i#') and len(Evaluate('attributes.BOY_#i#'))>#Evaluate('attributes.BOY_#i#')#<cfelse>0</cfif>,
                                    <cfif isdefined('attributes.EN_#i#') and len(Evaluate('attributes.EN_#i#'))>#Evaluate('attributes.EN_#i#')#<cfelse>0</cfif>,
                                    <cfif isdefined('attributes.PRIVATE_PRICE_TYPE_#i#') and len(Evaluate('attributes.PRIVATE_PRICE_TYPE_#i#'))>#Evaluate('attributes.PRIVATE_PRICE_TYPE_#i#')#<cfelse>0</cfif>,
                                    <cfif isdefined('attributes.PRIVATE_PRICE_MONEY_#i#') and len(Evaluate('attributes.PRIVATE_PRICE_MONEY_#i#'))>'#Evaluate('attributes.PRIVATE_PRICE_MONEY_#i#')#'<cfelse>NULL</cfif>,
                                    <cfif isdefined('attributes.PRIVATE_PRICE_#i#') and len(Evaluate('attributes.PRIVATE_PRICE_#i#'))>#	FilterNum(Evaluate('attributes.PRIVATE_PRICE_#i#'),2)#<cfelse>0</cfif>,
                                    #now()#,
                                    #session.ep.userid#,
                                    '#cgi.remote_addr#'
                                )
                    </cfquery>
                </cfloop>
            </cfif>
        </cftransaction>
    </cfif>
    <script type="text/javascript">
		wrk_opener_reload();
		window.close();
	</script>          
<cfelse> <!---Mutfak Aktarım Sayfasından Geliyorsa--->
	<cfset upload_folder = "#upload_folder#temp#dir_seperator#">
    <cftry>
        <cffile action = "upload" 
                fileField = "uploaded_file" 
                destination = "#upload_folder#"
                nameConflict = "MakeUnique"  
                mode="777">
      	<cfif attributes.import_file_type eq 4 and cffile.serverfileext neq 'PDF'>
        	<script type="text/javascript">
             	alert("<cfoutput>#getLang('main',2947)# #getLang('main',1936)#</cfoutput>.");
             	history.back();
         	</script>
         	<cfabort>
        </cfif>
        <cfset file_name = "#createUUID()#.#cffile.serverfileext#">	
        <cffile action="rename" source="#upload_folder##cffile.serverfile#" destination="#upload_folder##file_name#">	
        <cfset file_size = cffile.filesize>
        <cfcatch type="Any">
                <cfoutput>#cfcatch.detail#</cfoutput>
            <cfabort>
        </cfcatch>  
    </cftry>
    <cfquery name="del_file" datasource="#dsn3#"> <!---Satırla İlgili Varsa Kayıt Siliniyor--->
     	DELETE FROM EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE WHERE EZGI_ID = #attributes.ezgi_id# AND FILE_TYPE_ID = #attributes.import_file_type#
  	</cfquery>
	<cfquery name="add_fie" datasource="#dsn3#"><!--- Yeni İçeriye Alınan Dosyanın Database Kaydı Yapılıyor--->
   		INSERT INTO 
     		EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE
          	(
         		EZGI_ID, 
             	FILE_TYPE_ID, 
          		FILE_NAME,
                FILE_NAME_OLD,
                RECORD_DATE, 
              	RECORD_EMP, 
        		RECORD_IP
          	)
      	VALUES        
         	(
           		#attributes.ezgi_id#,
             	#attributes.import_file_type#,
              	'#file_name#',
                '#Left(cffile.serverFile,100)#',
                #now()#,
               	#session.ep.userid#,
             	'#cgi.remote_addr#'
      		)
 	</cfquery>
    <cfif isdefined('attributes.import_file_type') and attributes.import_file_type eq 1> <!---Mutfak Fiyat Aktarımından Geliyorsa--->
        <cftry>
            <cfspreadsheet action="read" src="#upload_folder##file_name#" query="satirlar" sheetname ="FIYAT" headerrow ="1" rows="2-10000">	
            <cfspreadsheet action="read" src="#upload_folder##file_name#" query="details" sheetname ="ACIKLAMA" headerrow ="1" rows="2-20">
            <cfspreadsheet action="read" src="#upload_folder##file_name#" query="montage" sheetname ="MONTAJ" headerrow ="1" rows="2-20">
            <cfcatch>
                <script type="text/javascript">
                     alert("<cfoutput>#getLang('ehesap',1112)#</cfoutput>.");
                    history.back();
                </script>
                <cfabort>
            </cfcatch>
        </cftry>
        <cfif satirlar.recordcount>
        	<cfquery name="get_diff_rate" datasource="#dsn3#">
            	SELECT 
                	ISNULL(S.MIN_MARGIN,0) AS DIFF_RATE_,
                    EVOR.BOY,
                    EVOR.EN,
                    EVOR.DERINLIK,
                    ISNULL(EVOR.YON,0) AS YON
				FROM     
                	STOCKS AS S INNER JOIN
                  	EZGI_VIRTUAL_OFFER_ROW AS EVOR ON S.STOCK_ID = EVOR.STOCK_ID
				WHERE  
                	EVOR.EZGI_ID = #attributes.ezgi_id#
            </cfquery>
            <cftransaction>
                <!---Değişikliği History Tablosuna Kaydediyoruz--->
                <cfquery name="add_history" datasource="#dsn3#" >
                    INSERT INTO 
                        EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY
                        (
                            EZGI_ID, 
                            BOY,
                            EN,
                            DERINLIK,
                            YON,
                            HISTORY_TYPE, 
                            UPDATE_EMP, 
                            UPDATE_IP, 
                            UPDATE_DATE
                            <cfif isdefined('attributes.revision')>
                                , IS_REVISION
                                , MAILLIST
                            </cfif>
                        )
                        VALUES (
                            #attributes.ezgi_id#, 
                            #get_diff_rate.BOY#,
                            #get_diff_rate.EN#,
                            #get_diff_rate.DERINLIK#,
                            #get_diff_rate.YON#,
                            3, 
                            #session.ep.userid#, 
                            '#cgi.remote_addr#', 
                            #now()#
                            <cfif isdefined('attributes.revision')>
                                , #attributes.revision#
                                , '#attributes.mail_list#'
                            </cfif>
                        )
                </cfquery>
                <cfquery name="max_id" datasource="#dsn3#">
                    SELECT MAX(VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID) AS MAX_ID FROM EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY
                </cfquery>
                <cfquery name="add_row_detail_history" datasource="#dsn3#">
                    INSERT INTO 
                        EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ROW
                        (
                            VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID, 
                            EZGI_ID, 
                            AMOUNT, 
                            LAST_AMOUNT, 
                            SALES_PRICE, 
                            SALES_PRICE_MONEY, 
                            PURCHASE_PRICE, 
                            PURCHASE_PRICE_MONEY, 
                            COST_PRICE, 
                            COST_PRICE_MONEY, 
                            STOCK_ID, 
                            PRODUCT_CODE_2, 
                            PRODUCT_CODE, 
                            PRODUCT_NAME, 
                            MAIN_UNIT, 
                            PIECE_ROW_ID, 
                            PIECE_TYPE, 
                            QUESTION_ID, 
                            IS_AMOUNT_CHANGE, 
                            IS_PRICE_CHANGE, 
                            BOY_FORMUL, 
                            EN_FORMUL, 
                            AMOUNT_FORMUL, 
                            NOT_STANDART_RATE, 
                            DESIGN_EN, 
                            DESIGN_BOY, 
                            PRIVATE_PRICE_TYPE, 
                            PRIVATE_PRICE_MONEY, 
                            PRIVATE_PRICE, 
                            RECORD_EMP, 
                            RECORD_IP, 
                            RECORD_DATE, 
                            PRICE_FORMUL
                        )
                        SELECT  
                            #max_id.MAX_ID#,
                            EZGI_ID, 
                            AMOUNT, 
                            LAST_AMOUNT, 
                            SALES_PRICE, 
                            SALES_PRICE_MONEY, 
                            PURCHASE_PRICE, 
                            PURCHASE_PRICE_MONEY, 
                            COST_PRICE, 
                            COST_PRICE_MONEY, 
                            STOCK_ID, 
                            PRODUCT_CODE_2, 
                            PRODUCT_CODE, 
                            PRODUCT_NAME, 
                            MAIN_UNIT, 
                            PIECE_ROW_ID, 
                            PIECE_TYPE, 
                            QUESTION_ID, 
                            IS_AMOUNT_CHANGE, 
                            IS_PRICE_CHANGE, 
                            BOY_FORMUL, 
                            EN_FORMUL, 
                            AMOUNT_FORMUL, 
                            NOT_STANDART_RATE, 
                            DESIGN_EN, 
                            DESIGN_BOY, 
                            PRIVATE_PRICE_TYPE, 
                            PRIVATE_PRICE_MONEY, 
                            PRIVATE_PRICE, 
                            RECORD_EMP, 
                            RECORD_IP, 
                            RECORD_DATE, 
                            PRICE_FORMUL
                        FROM 
                            EZGI_VIRTUAL_OFFER_ROW_DETAIL
                        WHERE 
                            EZGI_ID = #attributes.ezgi_id#
                        ORDER BY
                            VIRTUAL_OFFER_ROW_DETAIL_ID ASC
                </cfquery>
                <!---Değişikliği History Tablosuna Kaydediyoruz--->

                <!---Eski Kaydı Siliyoruz--->
                <cfquery name="del_row" datasource="#dsn3#"><!---Varsa Detay Satırları Siliniyor--->
                    DELETE FROM EZGI_VIRTUAL_OFFER_ROW_DETAIL WHERE EZGI_ID = #attributes.ezgi_id#
                </cfquery>
                <cfquery name="del_row" datasource="#dsn3#"><!---Varsa Montaj Satırları Siliniyor--->
                    DELETE FROM EZGI_VIRTUAL_OFFER_ROW_MONTAGE WHERE EZGI_ID = #attributes.ezgi_id#
                </cfquery>
                <cfquery name="del_row" datasource="#dsn3#"><!---Varsa Açıklama Satırları Siliniyor--->
                    DELETE FROM EZGI_VIRTUAL_OFFER_ROW_DESCRIPTION WHERE EZGI_ID = #attributes.ezgi_id#
                </cfquery>
                <cfif attributes.price_transfer_type eq 1> <!---Aktarım İçin Ürün Kartı Bağlantısı Aranacaksa--->
                    <cfloop query="satirlar">
                        <cfif len(satirlar.code)>
                            <cfquery name="get_stock_id" datasource="#dsn3#">
                                SELECT 
                                    STOCK_ID,
                                    PRODUCT_CODE, 
                                    PRODUCT_NAME, 
                                    (SELECT MAIN_UNIT FROM PRODUCT_UNIT WHERE PRODUCT_UNIT_ID = STOCKS.PRODUCT_UNIT_ID AND IS_MAIN = 1) AS MAIN_UNIT
                                FROM 
                                    STOCKS 
                                WHERE 
                                    PRODUCT_CODE_2 = '#satirlar.code#'
                            </cfquery>
                            <cfif get_stock_id.recordcount>
                                <cfif get_stock_id.recordcount gt 1>
                                    <script type="text/javascript">
                                        alert("<cfoutput>#satirlar.code#</cfoutput> Kodu Ürün Kodlarında Birden Fazla Tanımlanmıştır!");
                                        window.close()
                                    </script>
                                    <cfdump var="#get_stock_id#">
                                    <cfabort>
                                <cfelse>
                                    <cfquery name="get_price" datasource="#dsn3#">
                                        SELECT        
                                            OFR.SALES_PRICE, 
                                            OFR.SALES_PRICE_MONEY,
                                            OFR.PURCHASE_PRICE,
                                            OFR.PURCHASE_PRICE_MONEY,
                                            OFR.COST_PRICE,
                                            OFR.COST_PRICE_MONEY,
                                            ISNULL(OFR.IS_RATE,0) AS IS_RATE
                                        FROM
                                            EZGI_VIRTUAL_OFFER_PRICE_ROW AS OFR WITH (NOLOCK) INNER JOIN
                                            EZGI_VIRTUAL_OFFER_PRICE_LIST AS OFL WITH (NOLOCK) ON OFR.PRICE_CAT_ID = OFL.PRICE_CAT_ID
                                        WHERE        
                                            OFR.PRICE_CAT_ID = 1 AND 
                                            OFL.STATUS = 1 AND 
                                            OFR.STOCK_ID = #get_stock_id.STOCK_ID#
                                    </cfquery>
                                    <cfif get_price.recordcount>
                                        <cfquery name="add_row" datasource="#dsn3#">
                                            INSERT INTO 
                                                EZGI_VIRTUAL_OFFER_ROW_DETAIL
                                                (
                                                    EZGI_ID, 
                                                    AMOUNT, 
                                                    SALES_PRICE, 
                                                    SALES_PRICE_MONEY, 
                                                    PURCHASE_PRICE, 
                                                    PURCHASE_PRICE_MONEY, 
                                                    COST_PRICE, 
                                                    COST_PRICE_MONEY, 
                                                    STOCK_ID, 
                                                    PRODUCT_CODE, 
                                                    PRODUCT_NAME, 
                                                    MAIN_UNIT,
                                                    RECORD_DATE, 
                                                	RECORD_EMP, 
                                                	RECORD_IP
                                                )
                                            VALUES        
                                                (
                                                    #attributes.ezgi_id#,
                                                    #satirlar.miktar#,
                                                    #get_price.SALES_PRICE#,
                                                    '#get_price.SALES_PRICE_MONEY#',
                                                     #get_price.PURCHASE_PRICE#,
                                                    '#get_price.PURCHASE_PRICE_MONEY#',
                                                     #get_price.COST_PRICE#,
                                                    '#get_price.COST_PRICE_MONEY#',
                                                    #get_stock_id.STOCK_ID#,
                                                    '#get_stock_id.PRODUCT_CODE#',
                                                    '#get_stock_id.PRODUCT_NAME#',
                                                    '#get_stock_id.MAIN_UNIT#',
                                                    #now()#,
                                                    #session.ep.userid#,
                                                    '#cgi.remote_addr#'
                                                )
                                        </cfquery>
                                    <cfelse>
                                        <script type="text/javascript">
                                            alert("<cfoutput>#satirlar.code#</cfoutput> Kodul Ürün Fiyat Listesinde Kayıtlı Değildir!");
                                            window.close()
                                        </script>
                                        <cfabort>
                                    </cfif>
                                </cfif>
                            <cfelse>
                                <script type="text/javascript">
                                    alert("<cfoutput>#satirlar.code#</cfoutput> Kodu Ürün Kodlarında Kayıtlı Değildir!");
                                    window.close()
                                </script>
                                <cfabort>
                            </cfif>
                        </cfif>
                    </cfloop>
              	<cfelse> <!---Şu an Bursaı Çalışıyor Ürün Kartı Bağlantısız Direk EZGI_VIRTUAL_OFFER_PRICE_ROW tablosundaki Özel Kodla Alınıyor--->
                	<cfloop query="satirlar">
                        <cfif len(satirlar.code)>
                            <cfquery name="get_price" datasource="#dsn3#">
                                SELECT    
                                     WR.*,
                                     ISNULL(WR.IS_RATE,0) AS IS_RATE_
                                FROM            
                                    EZGI_VIRTUAL_OFFER_PRICE_ROW AS WR WITH (NOLOCK) INNER JOIN
                                    EZGI_VIRTUAL_OFFER_PRICE_LIST AS WL WITH (NOLOCK) ON WR.PRICE_CAT_ID = WL.PRICE_CAT_ID
                                WHERE        
                                    WR.PRODUCT_CODE_2 = '#satirlar.code#' AND 
                                    WL.STATUS = 1
                            </cfquery>
                            <cfif get_price.recordcount>
                                <cfif get_price.recordcount gt 1>
                                    <script type="text/javascript">
                                        alert("<cfoutput>#satirlar.code#</cfoutput> Kodu Ürün Kodlarında Birden Fazla Tanımlanmıştır!");
                                        window.close()
                                    </script>
                                    <cfdump var="#get_price#">
                                    <cfabort>
                                <cfelse>
                                    <cfquery name="add_row" datasource="#dsn3#"> <!--- Mutfak adekodan gelen satırlar Detay Sayfası Kaydediliyor--->
                                        INSERT INTO 
                                            EZGI_VIRTUAL_OFFER_ROW_DETAIL
                                            (
                                                EZGI_ID, 
                                                AMOUNT, 
                                                SALES_PRICE, 
                                                PURCHASE_PRICE, 
                                                COST_PRICE, 
                                                SALES_PRICE_MONEY, 
                                                PURCHASE_PRICE_MONEY, 
                                                COST_PRICE_MONEY, 
                                                PRODUCT_CODE, 
                                                PRODUCT_NAME,
                                                RECORD_DATE, 
                                                RECORD_EMP, 
                                                RECORD_IP
                                            )
                                        VALUES        
                                            (
                                                #attributes.ezgi_id#,
                                                #satirlar.miktar#,
                                                <cfif get_diff_rate.DIFF_RATE_ and get_price.IS_RATE_>
                                                	<cfif len(get_price.SALES_PRICE)>#(get_price.SALES_PRICE*get_diff_rate.DIFF_RATE_/100)+get_price.SALES_PRICE#<cfelse>0</cfif>,
                                                    <cfif len(get_price.PURCHASE_PRICE)>#(get_price.PURCHASE_PRICE*get_diff_rate.DIFF_RATE_/100)+get_price.PURCHASE_PRICE#<cfelse>0</cfif>,
                                                    <cfif len(get_price.COST_PRICE)>#(get_price.COST_PRICE*get_diff_rate.DIFF_RATE_/100)+get_price.COST_PRICE#<cfelse>0</cfif>,
                                                <cfelse>
													<cfif len(get_price.SALES_PRICE)>#get_price.SALES_PRICE#<cfelse>0</cfif>,
                                                    <cfif len(get_price.PURCHASE_PRICE)>#get_price.PURCHASE_PRICE#<cfelse>0</cfif>,
                                                    <cfif len(get_price.COST_PRICE)>#get_price.COST_PRICE#<cfelse>0</cfif>,
                                                </cfif>
                                                <cfif len(get_price.SALES_PRICE_MONEY)>'#get_price.SALES_PRICE_MONEY#'<cfelse>NULL</cfif>,
                                                <cfif len(get_price.PURCHASE_PRICE_MONEY)>'#get_price.PURCHASE_PRICE_MONEY#'<cfelse>NULL</cfif>,
                                                <cfif len(get_price.COST_PRICE_MONEY)>'#get_price.COST_PRICE_MONEY#'<cfelse>NULL</cfif>,
                                                '#get_price.PRODUCT_CODE_2#',
                                                '#get_price.PRODUCT_NAME#',
                                                #now()#,
                                                #session.ep.userid#,
                                                '#cgi.remote_addr#'
                                            )
                                    </cfquery>
                                </cfif>
                            <cfelse>
                                <script type="text/javascript">
                                    alert("<cfoutput>#satirlar.code#</cfoutput> Kodu Ürün Kodlarında Tanımlanmamıştır!");
                                    window.close()
                                </script>
                                <cfdump var="#get_price#">
                                <cfabort>
                            </cfif>
                    	</cfif>
                    </cfloop>
                </cfif>
                <cfif details.recordcount>
                	<cfloop query="details">
                		<cfif len(details.kod)>
                        	<cfquery name="add_description" datasource="#dsn3#"><!--- Adekodan Gelen Açıklamalar Açıklama Dosyasına Kaydediliyor--->
                                INSERT INTO 
                                    EZGI_VIRTUAL_OFFER_ROW_DESCRIPTION
                                    (
                                        EZGI_ID, 
                                        DESCRIPTION
                                    )
                                VALUES        
                                    (
                                        #attributes.ezgi_id#,
                                        '#details.aciklama#'  
                                    )
                        	</cfquery>
                        </cfif>
                	</cfloop>
                </cfif>
                <cfif MONTAGE.recordcount>
                	<cfloop query="MONTAGE">
                		<cfif len(MONTAGE.CODE) and len(MONTAGE.miktar) and isnumeric(MONTAGE.miktar)> <!---Adekodan Gelen Montaj Ölçüsü Kontrol ediliyor--->
                        	<cfquery name="get_des_stock_id" datasource="#dsn3#">
                                SELECT 
                                    STOCK_ID
                                FROM 
                                    STOCKS WITH (NOLOCK)
                                WHERE 
                                    PRODUCT_CODE_2 = '#MONTAGE.code#'
                            </cfquery>
                            <cfif get_des_stock_id.recordcount gt 1>
                                <script type="text/javascript">
                                    alert("<cfoutput>#montage.code#</cfoutput> Montaj Kodu Ürün Kodlarında Birden Fazla Tanımlanmıştır!");
                                    window.close()
                                </script>
                                <cfdump var="#get_des_stock_id#">
                                <cfabort>
                          	<cfelseif not get_des_stock_id.recordcount>
                            	<script type="text/javascript">
                                    alert("<cfoutput>#montage.code#</cfoutput> Montaj Kodu Ürün Kodlarında Bulunamamıştır!");
                                    window.close()
                                </script>
                                <cfdump var="#get_des_stock_id#">
                                <cfabort>
                         	<cfelse>    
                                <cfquery name="add_montage" datasource="#dsn3#"> <!---Adekodan Gelen Montaj Ölçüsü Montaj Dosyasına Kaydediliyor.--->
                                    INSERT INTO 
                                        EZGI_VIRTUAL_OFFER_ROW_MONTAGE
                                        (
                                            EZGI_ID, 
                                            STOCK_ID,
                                            AMOUNT
                                        )
                                    VALUES        
                                        (
                                            #attributes.ezgi_id#,
                                            #get_des_stock_id.STOCK_ID#,
                                            #MONTAGE.miktar# 
                                        )
                                </cfquery>
                            </cfif>
                        </cfif>
                	</cfloop>
                </cfif>
            </cftransaction>
        <cfelse>
            Hatalı Dosya
        </cfif>
  	<cfelseif isdefined('attributes.import_file_type') and attributes.import_file_type eq 3> <!---Mutfak İmalat Dosyası Aktarımı İse--->
    	<cfinclude template="/v16/add_options/ezgi/e_furniture/imp_ezgi_virtual_offer_row_spect_aktar.cfm">
    </cfif>
</cfif>
<cfif isdefined('attributes.upd') or isdefined('attributes.UPD_STANDART')>
	<script type="text/javascript">
        alert("Güncelleme Tamamlanmıştır!");
        wrk_opener_reload();
        window.close()
    </script>
<cfelse>
	<cflocation url="#request.self#?fuseaction=prod.popup_upd_ezgi_virtual_offer_row_spect&kilit_stage=#attributes.kilit_stage#&ezgi_id=#attributes.ezgi_id#" addtoken="No">
</cfif>