<!---
    File: add_servis_basvuru.cfm
    Folder: AddOns/ezgi/e_partner/query
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Servis Başvuru Kayıt İşlemi
--->
<cfparam name="form.is_submitted" default="0">

<cfif form.is_submitted neq 1>
    <cflocation url="index.cfm?fuseaction=partner.add_servis_basvuru&error=#URLEncodedFormat('Form gönderilmedi.')#" addtoken="false">
</cfif>

<!--- Form validasyonu --->
<cfparam name="form.kategori_id" default="">
<cfparam name="form.iletisim_sekli_id" default="">
<cfparam name="form.oncelik_id" default="">
<cfparam name="form.konu" default="">
<cfparam name="form.aciklama" default="">
<cfparam name="form.basvuru_tarihi" default="">
<cfparam name="form.adi_soyadi" default="">
<cfparam name="form.cep_telefonu" default="">
<cfparam name="form.mail_adresi" default="">

<!--- Zorunlu alan kontrolü --->
<cfset errorMessages = []>
<cfif not len(trim(form.kategori_id))>
    <cfset arrayAppend(errorMessages, "Servis Başvuru Kategorisi seçilmelidir.")>
</cfif>
<cfif not len(trim(form.iletisim_sekli_id))>
    <cfset arrayAppend(errorMessages, "İletişim Şekli seçilmelidir.")>
</cfif>
<cfif not len(trim(form.oncelik_id))>
    <cfset arrayAppend(errorMessages, "Öncelik seçilmelidir.")>
</cfif>
<cfif not len(trim(form.konu))>
    <cfset arrayAppend(errorMessages, "Konu alanı zorunludur.")>
<cfelseif len(trim(form.konu)) gt 250>
    <cfset arrayAppend(errorMessages, "Konu alanı en fazla 250 karakter olabilir.")>
</cfif>
<cfif not len(trim(form.aciklama))>
    <cfset arrayAppend(errorMessages, "Açıklama alanı zorunludur.")>
<cfelseif len(trim(form.aciklama)) gt 1000>
    <cfset arrayAppend(errorMessages, "Açıklama alanı en fazla 1000 karakter olabilir.")>
</cfif>
<cfif not len(trim(form.basvuru_tarihi)) or not isDate(form.basvuru_tarihi)>
    <cfset arrayAppend(errorMessages, "Geçerli bir başvuru tarihi girilmelidir.")>
</cfif>
<cfif not len(trim(form.adi_soyadi))>
    <cfset arrayAppend(errorMessages, "Adı Soyadı alanı zorunludur.")>
</cfif>
<cfif not len(trim(form.cep_telefonu))>
    <cfset arrayAppend(errorMessages, "Cep Telefonu alanı zorunludur.")>
</cfif>
<cfif not len(trim(form.mail_adresi))>
    <cfset arrayAppend(errorMessages, "Mail Adresi alanı zorunludur.")>
</cfif>

<cfif arrayLen(errorMessages) gt 0>
    <cflocation url="index.cfm?fuseaction=partner.add_servis_basvuru&error=#URLEncodedFormat(arrayToList(errorMessages, ' | '))#" addtoken="false">
</cfif>

<!--- Partner bilgileri --->
<cfset partner_id = session.b2b.partnerId>
<cfset company_id = session.b2b.companyId>

<!--- Partner ID ve Company ID kontrolü --->
<cfif not isDefined("partner_id") or not isNumeric(partner_id) or partner_id eq 0>
    <cflocation url="index.cfm?fuseaction=partner.add_servis_basvuru&error=#URLEncodedFormat('Partner ID geçersiz.')#" addtoken="false">
</cfif>
<cfif not isDefined("company_id") or not isNumeric(company_id) or company_id eq 0>
    <cflocation url="index.cfm?fuseaction=partner.add_servis_basvuru&error=#URLEncodedFormat('Company ID geçersiz.')#" addtoken="false">
</cfif>

<!--- DSN değişkenlerini kontrol et ve varsayılan değerler ata --->
<cfif not isDefined("request.dsn") or not len(trim(request.dsn))>
    <cfset request.dsn = "demo_ezgiyazilim">
</cfif>
<cfif not isDefined("request.dsn3") or not len(trim(request.dsn3))>
    <cfif isDefined("session.b2b.compId") and isNumeric(session.b2b.compId) and session.b2b.compId gt 0>
        <cfset request.dsn3 = "#request.dsn#_#session.b2b.compId#">
    <cfelse>
        <cfset request.dsn3 = "#request.dsn#_1">
    </cfif>
</cfif>

<!--- DSN3 değişkenini caller scope'a ekle (cf_papers custom tag için) --->
<cfset caller.DSN3 = request.dsn3>
<cfset caller.DSN = request.dsn>
<cfset caller.dsn3 = request.dsn3>
<cfset caller.dsn = request.dsn>

    
            <!--- Servis numarası oluştur --->
                <cf_papers paper_type="SERVICE_APP">
                <cfset system_paper_no = paper_code & '-' & paper_number>
                <cfset system_paper_no_add = paper_number>
                
                <!--- cf_papers başarısız olursa, manuel olarak oluştur --->
                <cfquery name="GET_GEN_PAPER" datasource="#request.dsn3#">
                    SELECT 
                        ISNULL(SERVICE_APP_NO, 'SRV') AS SERVICE_APP_NO,
                        ISNULL(SERVICE_APP_NUMBER, 0) AS SERVICE_APP_NUMBER
                    FROM 
                        GENERAL_PAPERS 
                    WHERE 
                    GENERAL_PAPERS_ID=1
                </cfquery>
                <cfif isDefined("GET_GEN_PAPER") and GET_GEN_PAPER.recordcount>
                    <cfset paper_code = GET_GEN_PAPER.SERVICE_APP_NO>
                    <cfset paper_number = GET_GEN_PAPER.SERVICE_APP_NUMBER + 1>
                <cfelse>
                    <cfset paper_code = "SRV">
                    <cfset paper_number = 1>
                </cfif>
                
                <cfset system_paper_no = paper_code & '-' & paper_number>
                <cfset system_paper_no_add = paper_number>

            
            <!--- Paper number kontrolü --->
            <cfif not isDefined("paper_code") or not len(trim(paper_code))>
                <cfset paper_code = "SRV">
            </cfif>
            <cfif not isDefined("paper_number") or not isNumeric(paper_number) or paper_number eq 0>
                <cfset paper_number = 1>
            </cfif>
            
            <cfset system_paper_no = paper_code & '-' & paper_number>
            <cfset system_paper_no_add = paper_number>
            
            <!--- GENERAL_PAPERS tablosunu güncelle --->
            <cfquery name="UPD_GEN_PAP" datasource="#request.dsn3#">
                UPDATE
                    GENERAL_PAPERS
                SET
                    SERVICE_APP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#system_paper_no_add#">
                WHERE
                    SERVICE_APP_NUMBER IS NOT NULL
            </cfquery>
            
            <!--- Başvuru tarihini formatla --->
            <cfif len(form.basvuru_tarihi)>
                <cfset apply_date = createDate(year(form.basvuru_tarihi), month(form.basvuru_tarihi), day(form.basvuru_tarihi))>
            <cfelse>
                <cfset apply_date = now()>
            </cfif>
            
            <!--- İlk durum (Beklemede) için PROCESS_TYPE_ROWS'dan STAGE=0 olan kaydı bul --->
            <cfset comp_id_for_query = 1>
            <cfif isDefined("session.b2b.compId") and isNumeric(session.b2b.compId) and session.b2b.compId gt 0>
                <cfset comp_id_for_query = session.b2b.compId>
            <cfelseif isDefined("session.b2b.companyId") and isNumeric(session.b2b.companyId) and session.b2b.companyId gt 0>
                <cfset comp_id_for_query = session.b2b.companyId>
            </cfif>
            
    <cflock name="#CREATEUUID()#" timeout="20">
        <cftransaction>
            <!--- Başvuru kaydı ekle (ServiceAction.cfc'deki add_service fonksiyonundan uyarlandı) --->
            <cfquery name="ADD_SERVICE" datasource="#request.dsn3#" result="my_result">
                INSERT INTO
                    SERVICE
                    (
                        SERVICE_ACTIVE,
                        ISREAD,
                        SERVICECAT_ID,
                        SERVICE_STATUS_ID,
                        PRIORITY_ID,
                        COMMETHOD_ID,
                        SERVICE_HEAD,
                        SERVICE_DETAIL,
                        APPLY_DATE,
                        SERVICE_PARTNER_ID,
                        SERVICE_COMPANY_ID,
                        APPLICATOR_NAME,
                        BRING_NAME,
                        BRING_EMAIL,
                        BRING_MOBILE_NO,
                        SERVICE_NO,
                        RECORD_DATE,
                        RECORD_MEMBER
                    )
                    VALUES
                    (
                        1,
                        0,
                        <cfif len(trim(form.kategori_id)) and isNumeric(trim(form.kategori_id)) and trim(form.kategori_id) gt 0><cfqueryparam cfsqltype="cf_sql_integer" value="#trim(form.kategori_id)#"><cfelse>NULL</cfif>,
                        <cfif isDefined("process_stage") and isNumeric(process_stage) and process_stage gt 0><cfqueryparam cfsqltype="cf_sql_integer" value="#process_stage#"><cfelse>NULL</cfif>,
                        <cfif len(trim(form.oncelik_id)) and isNumeric(trim(form.oncelik_id)) and trim(form.oncelik_id) gt 0><cfqueryparam cfsqltype="cf_sql_integer" value="#trim(form.oncelik_id)#"><cfelse>NULL</cfif>,
                        <cfif len(trim(form.iletisim_sekli_id)) and isNumeric(trim(form.iletisim_sekli_id)) and trim(form.iletisim_sekli_id) gt 0><cfqueryparam cfsqltype="cf_sql_integer" value="#trim(form.iletisim_sekli_id)#"><cfelse>NULL</cfif>,
                        <cfif len(trim(form.konu))><cfqueryparam cfsqltype="cf_sql_varchar" value="#left(trim(form.konu), 250)#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="#system_paper_no#"></cfif>,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#left(trim(form.aciklama), 1000)#">,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#apply_date#">,
                        <cfif isDefined("partner_id") and isNumeric(partner_id) and partner_id gt 0><cfqueryparam cfsqltype="cf_sql_integer" value="#partner_id#"><cfelse>NULL</cfif>,
                        <cfif isDefined("company_id") and isNumeric(company_id) and company_id gt 0><cfqueryparam cfsqltype="cf_sql_integer" value="#company_id#"><cfelse>NULL</cfif>,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#left(trim(form.adi_soyadi), 200)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#left(trim(form.adi_soyadi), 200)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(form.mail_adresi)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(form.cep_telefonu)#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#system_paper_no#">,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                        <cfif isDefined("partner_id") and isNumeric(partner_id) and partner_id gt 0><cfqueryparam cfsqltype="cf_sql_integer" value="#partner_id#"><cfelse>NULL</cfif>
                    )
            </cfquery>
            
            <!--- Oluşturulan servis kaydını al --->
            <cfquery name="GET_SERVICE1" datasource="#request.dsn3#" maxrows="1">
                SELECT  
                    SERVICE_ID,
                    SERVICE_NO
                FROM 
                    SERVICE 
                WHERE 
                    <cfif isDefined("partner_id") and isNumeric(partner_id) and partner_id gt 0>SERVICE_PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_id#"> AND </cfif>
                    SERVICE_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#system_paper_no#"> 
                ORDER BY 
                    SERVICE_ID DESC
            </cfquery>
            
            <!--- Dosya yükleme işlemi --->
            <cfset service_id = GET_SERVICE1.SERVICE_ID>
            <cfset uploaded_files = []>
            
            <!--- Upload klasörü yolu --->
            <!--- Virtual Directory için expandPath kullan --->
            <cftry>
                <!--- Virtual Directory "documents" için fiziksel yolu bul --->
                <cfset documentsPath = expandPath("/documents/")>
                <cfset uploadDir = documentsPath & "service\">
            <cfcatch>
                <!--- expandPath çalışmazsa alternatif yöntem --->
                <cftry>
                    <!--- Web root'u bul --->
                    <cfset webRoot = expandPath("/")>
                    <cfset uploadDir = webRoot & "documents\service\">
                <cfcatch>
                    <!--- Son çare: Application.cfc ile aynı mantığı kullan --->
                    <cfset basePath = getDirectoryFromPath(getCurrentTemplatePath())>
                    <cfset rootPath = replace(basePath, "AddOns\ezgi\e_partner\query\", "", "all")>
                    <cfset uploadDir = rootPath & "documents\service\">
                </cfcatch>
                </cftry>
            </cfcatch>
            </cftry>
            
            <!--- Klasör yoksa oluştur --->
            <cfif not directoryExists(uploadDir)>
                <cfdirectory action="create" directory="#uploadDir#" mode="777">
            </cfif>
            
            <!--- Dosyaları yükle --->
            <!--- ColdFusion'da multiple file upload için form.dosyalar bir struct olabilir --->
            <cfif isDefined("form.dosyalar")>
                <cftry>
                    <!--- Dosya yükleme --->
                    <cffile action="upload" 
                            filefield="dosyalar" 
                            destination="#uploadDir#" 
                            nameconflict="makeunique"
                            accept="image/*,video/*"
                            mode="777">
                    
                    <!--- Dosya boyutu kontrolü (10 MB) --->
                    <cfif cffile.fileSize gt 10485760>
                        <cffile action="delete" file="#uploadDir##cffile.serverFile#">
                    <cfelse>
                        <!--- Dosya tipi kontrolü --->
                        <cfset fileType = cffile.contentType>
                        <cfset isImage = left(fileType, 6) eq "image/">
                        <cfset isVideo = left(fileType, 6) eq "video/">
                        
                    <cfif isImage or isVideo>
                        <!--- Orijinal dosya adını sakla --->
                        <cfset originalFileName = cffile.clientFile>
                        <cfset originalFileExtension = listLast(originalFileName, ".")>
                        
                        <!--- Hash/UUID ile yeni dosya adı oluştur --->
                        <cfset fileHash = createUUID()>
                        <!--- Tireleri kaldır ve büyük harfe çevir --->
                        <cfset fileHash = ucase(replace(fileHash, "-", "", "ALL"))>
                        <!--- İstenen formata çevir: 19E8D2E7-E2D0-79F7-AD0C944532CDD577 --->
                        <cfset fileHash = left(fileHash, 8) & "-" & mid(fileHash, 9, 4) & "-" & mid(fileHash, 13, 4) & "-" & mid(fileHash, 17, len(fileHash) - 16)>
                        <cfset newFileName = fileHash & "." & originalFileExtension>
                        
                        <!--- Dosyayı yeniden adlandır --->
                        <cffile action="rename" 
                                source="#uploadDir##cffile.serverFile#" 
                                destination="#uploadDir##newFileName#">
                        
                        <!--- Dosya bilgilerini array'e ekle --->
                        <cfset fileInfo = {
                            "service_id" = service_id,
                            "file_name" = originalFileName,
                            "server_file_name" = newFileName,
                            "file_path" = "documents/service/" & newFileName,
                            "file_size" = cffile.fileSize,
                            "file_type" = fileType,
                            "is_image" = isImage,
                            "is_video" = isVideo
                        }>
                        <cfset arrayAppend(uploaded_files, fileInfo)>
                        
                        <!--- Dosya bilgilerini veritabanına kaydet --->
                        <cftry>
                            <!--- SERVICE_FILES tablosuna kaydet --->
                            <cfquery name="INSERT_FILE" datasource="#request.dsn3#">
                                INSERT INTO SERVICE_FILES
                                (
                                    SERVICE_ID,
                                    FILE_NAME,
                                    SERVER_FILE_NAME,
                                    FILE_PATH,
                                    FILE_SIZE,
                                    FILE_TYPE,
                                    IS_IMAGE,
                                    IS_VIDEO,
                                    RECORD_DATE
                                )
                                VALUES
                                (
                                    <cfqueryparam cfsqltype="cf_sql_integer" value="#service_id#">,
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#originalFileName#">,
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#newFileName#">,
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="documents/service/#newFileName#">,
                                    <cfqueryparam cfsqltype="cf_sql_bigint" value="#cffile.fileSize#">,
                                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#fileType#">,
                                    <cfqueryparam cfsqltype="cf_sql_bit" value="#isImage#">,
                                    <cfqueryparam cfsqltype="cf_sql_bit" value="#isVideo#">,
                                    <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                                )
                            </cfquery>
                            
                            <!--- ASSET tablosuna kaydet --->
                            <cfset fileSizeKB = int(cffile.fileSize / 1024)>
                            <cfif fileSizeKB eq 0>
                                <cfset fileSizeKB = 1>
                            </cfif>
                            
                            <cftry>
                                <cfquery name="INSERT_ASSET" datasource="#request.dsn#">
                                    INSERT INTO ASSET
                                    (
                                        MODULE_NAME,
                                        MODULE_ID,
                                        ACTION_SECTION,
                                        ACTION_ID,
                                        ASSETCAT_ID,
                                        ASSET_FILE_NAME,
                                        ASSET_FILE_SIZE,
                                        ASSET_FILE_SERVER_ID,
                                        ASSET_FILE_FORMAT,
                                        ASSET_NAME,
                                        PROPERTY_ID,
                                        COMPANY_ID,
                                        ASSET_FILE_REAL_NAME,
                                        RECORD_DATE,
                                        RECORD_PUB,
                                        RECORD_EMP,
                                        RECORD_IP
                                    )
                                    VALUES
                                    (
                                        <cfqueryparam cfsqltype="cf_sql_varchar" value="service">,
                                        <cfqueryparam cfsqltype="cf_sql_integer" value="14">,
                                        <cfqueryparam cfsqltype="cf_sql_varchar" value="SERVICE_ID">,
                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#service_id#">,
                                        <cfqueryparam cfsqltype="cf_sql_integer" value="-5">,
                                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#newFileName#">,
                                        <cfqueryparam cfsqltype="cf_sql_integer" value="#fileSizeKB#">,
                                        <cfqueryparam cfsqltype="cf_sql_integer" value="1">,
                                        <cfqueryparam cfsqltype="cf_sql_integer" value="0">,
                                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#left(originalFileName, 200)#">,
                                        <cfqueryparam cfsqltype="cf_sql_integer" value="2">,
                                        <cfif isDefined("company_id") and isNumeric(company_id) and company_id gt 0>
                                            <cfqueryparam cfsqltype="cf_sql_integer" value="#company_id#">
                                        <cfelse>
                                            NULL
                                        </cfif>,
                                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#originalFileName#">,
                                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                                        <cfif isDefined("partner_id") and isNumeric(partner_id) and partner_id gt 0>
                                            <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_id#">
                                        <cfelse>
                                            NULL
                                        </cfif>,
                                        <cfif isDefined("partner_id") and isNumeric(partner_id) and partner_id gt 0>
                                            <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_id#">
                                        <cfelse>
                                            NULL
                                        </cfif>,
                                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">
                                    )
                                </cfquery>
                            <cfcatch>
                                <!--- ASSET tablosuna kayıt hatası - devam et --->
                            </cfcatch>
                            </cftry>
                            
                            <cfcatch>
                                <!--- Tablo yoksa veya hata varsa - dosyalar yine de yüklenmiş durumda --->
                            </cfcatch>
                        </cftry>
                        <cfelse>
                            <!--- Desteklenmeyen dosya tipi - sil --->
                            <cffile action="delete" file="#uploadDir##cffile.serverFile#">
                        </cfif>
                    </cfif>
                <cfcatch>
                    <!--- Dosya yükleme hatası - devam et --->
                </cfcatch>
                </cftry>
            </cfif>
            
            <!--- Multiple file upload için döngü (eğer birden fazla dosya varsa) --->
            <!--- Not: ColdFusion'da multiple file upload için özel bir yaklaşım gerekebilir --->
            <!--- Şimdilik tek dosya yükleme destekleniyor, ileride geliştirilebilir --->
            
        </cftransaction>
    </cflock>
    
    <!--- Mail bildirimi (placeholder - mail gönderme kodu eklenecek) --->
    <!--- 
    <cfmail to="servis@ezgiyazilim.com" 
            from="#form.mail_adresi#" 
            subject="Yeni Servis Başvurusu: #system_paper_no#"
            type="html">
        Yeni bir servis başvurusu oluşturuldu.
        Başvuru No: #system_paper_no#
        Konu: #form.konu#
        Başvuru Yapan: #form.adi_soyadi#
        ...
    </cfmail>
    --->
    
    <cflocation url="index.cfm?fuseaction=partner.servis_islemleri&success=#URLEncodedFormat('Servis başvurunuz başarıyla oluşturuldu. Başvuru No: ' & system_paper_no)#" addtoken="false">
    



