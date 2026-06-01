<!---
    File: add_servis_basvuru_file.cfm
    Folder: AddOns/ezgi/e_partner/query
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Servis Başvuru Dosya Ekleme İşlemi
--->
<cfparam name="form.is_submitted" default="0">
<cfparam name="form.basvuru_id" default="0">

<cfif form.is_submitted neq 1>
    <cflocation url="index.cfm?fuseaction=partner.upd_servis_basvuru&basvuru_id=#form.basvuru_id#&error=#URLEncodedFormat('Form gönderilmedi.')#" addtoken="false">
</cfif>

<cfif not isNumeric(form.basvuru_id) or form.basvuru_id eq 0>
    <cflocation url="index.cfm?fuseaction=partner.servis_islemleri&error=#URLEncodedFormat('Geçersiz başvuru ID.')#" addtoken="false">
</cfif>

<!--- Partner bilgileri --->
<cfset partner_id = session.b2b.partnerId>
<cfset company_id = session.b2b.companyId>
<cfset basvuru_id = form.basvuru_id>

<!--- Partner ID ve Company ID kontrolü --->
<cfif not isDefined("partner_id") or not isNumeric(partner_id) or partner_id eq 0>
    <cflocation url="index.cfm?fuseaction=partner.upd_servis_basvuru&basvuru_id=#basvuru_id#&error=#URLEncodedFormat('Partner ID geçersiz.')#" addtoken="false">
</cfif>

<!--- Başvurunun bu kullanıcıya ait olduğunu kontrol et --->
<cftry>
    <cfquery name="CHECK_SERVICE" datasource="#request.dsn3#">
        SELECT SERVICE_ID
        FROM SERVICE
        WHERE SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#basvuru_id#">
            AND SERVICE_ACTIVE = 1
            AND SERVICE_PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_id#">
            AND SERVICE_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#company_id#">
    </cfquery>
    
    <cfif CHECK_SERVICE.recordcount eq 0>
        <cflocation url="index.cfm?fuseaction=partner.servis_islemleri&error=#URLEncodedFormat('Başvuru bulunamadı veya erişim yetkiniz yok.')#" addtoken="false">
    </cfif>
    
    <!--- Dosya yükleme işlemi --->
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
    <cftry>
        <cfif not directoryExists(uploadDir)>
            <cfdirectory action="create" directory="#uploadDir#" mode="777">
        </cfif>
    <cfcatch>
        <cflocation url="index.cfm?fuseaction=partner.upd_servis_basvuru&basvuru_id=#basvuru_id#&error=#URLEncodedFormat('Klasör oluşturulamadı: ' & uploadDir & ' - ' & cfcatch.message)#" addtoken="false">
    </cfcatch>
    </cftry>
    
    <cftry>
        <!--- Dosya yükleme --->
        <cffile action="upload" 
                filefield="dosya" 
                destination="#uploadDir#" 
                nameconflict="makeunique"
                accept="image/*,video/*"
                mode="777"
                result="uploadResult">
        
        <!--- Yükleme sonucunu kontrol et --->
        <cfif not uploadResult.fileWasSaved>
            <cflocation url="index.cfm?fuseaction=partner.upd_servis_basvuru&basvuru_id=#basvuru_id#&error=#URLEncodedFormat('Dosya yüklenemedi: ' & uploadResult.errorMessage)#" addtoken="false">
        </cfif>
            
        <!--- Dosya boyutu kontrolü (10 MB) --->
        <cfif cffile.fileSize gt 10485760>
            <cftry>
                <cffile action="delete" file="#uploadDir##cffile.serverFile#">
            <cfcatch>
            </cfcatch>
            </cftry>
            <cflocation url="index.cfm?fuseaction=partner.upd_servis_basvuru&basvuru_id=#basvuru_id#&error=#URLEncodedFormat('Dosya boyutu çok büyük (Maksimum 10 MB)')#" addtoken="false">
        </cfif>
        
        <!--- Dosya tipi kontrolü --->
        <cfset fileType = cffile.contentType>
        <cfset isImage = left(fileType, 6) eq "image/">
        <cfset isVideo = left(fileType, 6) eq "video/">
        
        <cfif not isImage and not isVideo>
            <cftry>
                <cffile action="delete" file="#uploadDir##cffile.serverFile#">
            <cfcatch>
            </cfcatch>
            </cftry>
            <cflocation url="index.cfm?fuseaction=partner.upd_servis_basvuru&basvuru_id=#basvuru_id#&error=#URLEncodedFormat('Desteklenmeyen dosya formatı (Sadece resim ve video dosyaları kabul edilir)')#" addtoken="false">
        </cfif>
        
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
        <cftry>
            <cffile action="rename" 
                    source="#uploadDir##cffile.serverFile#" 
                    destination="#uploadDir##newFileName#">
        <cfcatch>
            <!--- Rename başarısız olursa orijinal dosya adını kullan --->
            <cfset newFileName = cffile.serverFile>
        </cfcatch>
        </cftry>
            
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
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#basvuru_id#">,
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
                    <cfquery name="INSERT_ASSET" datasource="#request.dsn#" result="assetResult">
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
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#basvuru_id#">,
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
                    <!--- ASSET tablosuna kayıt hatası - hata mesajını URL'ye ekle --->
                    <cfset assetError = "ASSET kaydı: " & cfcatch.message>
                    <!--- Hata varsa bile SERVICE_FILES kaydı başarılı olduğu için işleme devam et --->
                </cfcatch>
                </cftry>
                
                <!--- Başarı mesajı --->
                <cfset successMsg = "Dosya başarıyla yüklendi.">
                <cfif isDefined("assetError")>
                    <cfset successMsg = successMsg & " (ASSET kaydı hatası: " & assetError & ")">
                </cfif>
                
                <cflocation url="index.cfm?fuseaction=partner.upd_servis_basvuru&basvuru_id=#basvuru_id#&success=#URLEncodedFormat(successMsg)#" addtoken="false">
            <cfcatch>
                <!--- Veritabanı hatası - dosyayı sil --->
                <cftry>
                    <cfif isDefined("newFileName")>
                        <cffile action="delete" file="#uploadDir##newFileName#">
                    <cfelse>
                        <cffile action="delete" file="#uploadDir##cffile.serverFile#">
                    </cfif>
                <cfcatch>
                </cfcatch>
                </cftry>
                <cflocation url="index.cfm?fuseaction=partner.upd_servis_basvuru&basvuru_id=#basvuru_id#&error=#URLEncodedFormat('Dosya kaydedilirken bir hata oluştu.')#" addtoken="false">
            </cfcatch>
            </cftry>
        <cfcatch>
            <!--- Dosya yüklenmemişse --->
            <cfset errorMsg = "Dosya yüklenirken bir hata oluştu: " & cfcatch.message>
            <cfif findNoCase("No file was uploaded", cfcatch.message) or findNoCase("did not contain a file", cfcatch.message) or findNoCase("filefield", cfcatch.message)>
                <cfset errorMsg = "Lütfen bir dosya seçin.">
            </cfif>
            <cflocation url="index.cfm?fuseaction=partner.upd_servis_basvuru&basvuru_id=#basvuru_id#&error=#URLEncodedFormat(errorMsg)#" addtoken="false">
        </cfcatch>
    </cftry>
    
<cfcatch>
    <cflocation url="index.cfm?fuseaction=partner.upd_servis_basvuru&basvuru_id=#basvuru_id#&error=#URLEncodedFormat('Bir hata oluştu: ' & cfcatch.message)#" addtoken="false">
</cfcatch>
</cftry>

