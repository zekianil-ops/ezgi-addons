<!---
    File: login_process.cfm
    Folder: AddOns/ezgi/e_partner/query
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Login İşlemi
--->
<!--- DEBUG: Form ve Request bilgileri --->
<cfif structKeyExists(url, "debug")>
    <!DOCTYPE html>
    <html lang="tr">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Debug Bilgileri - B2B Partner Portal</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                padding: 20px;
                background: #f3f4f6;
            }
            .debug-container {
                max-width: 800px;
                margin: 0 auto;
                background: white;
                padding: 30px;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            h1 {
                color: #1e3a8a;
                border-bottom: 2px solid #667eea;
                padding-bottom: 10px;
            }
            .debug-item {
                margin: 15px 0;
                padding: 10px;
                background: #f9fafb;
                border-left: 4px solid #667eea;
            }
            .debug-item strong {
                color: #374151;
                display: inline-block;
                min-width: 150px;
            }
            .debug-item span {
                color: #059669;
            }
            .debug-item .error {
                color: #dc2626;
            }
            .btn-back {
                display: inline-block;
                margin-top: 20px;
                padding: 10px 20px;
                background: #667eea;
                color: white;
                text-decoration: none;
                border-radius: 6px;
            }
            .btn-back:hover {
                background: #5568d3;
            }
        </style>
    </head>
    <body>
        <cfoutput>
        <div class="debug-container">
            <h1>🔍 Debug Bilgileri</h1>
            
            <div class="debug-item">
                <strong>Form Username:</strong> 
                <span class="#isDefined("form.username") and len(form.username) ? '' : 'error'#">
                    <cfif isDefined("form.username") and len(form.username)>
                        #HTMLEditFormat(form.username)#
                    <cfelse>
                        TANIMSIZ
                    </cfif>
                </span>
            </div>
            
            <div class="debug-item">
                <strong>Form Password:</strong> 
                <span class="#isDefined("form.password") and len(form.password) ? '' : 'error'#">
                    <cfif isDefined("form.password") and len(form.password)>
                        *** (Gizli)
                    <cfelse>
                        TANIMSIZ
                    </cfif>
                </span>
            </div>
            <div class="debug-item">
                <strong>Request DSN:</strong> 
                <span class="#isDefined("request.dsn") and len(request.dsn) ? '' : 'error'#">
                    <cfif isDefined("request.dsn") and len(request.dsn)>
                        #HTMLEditFormat(request.dsn)#
                    <cfelse>
                        TANIMSIZ
                    </cfif>
                </span>
            </div>
            
            <div class="debug-item">
                <strong>Request DSN1:</strong> 
                <span class="#isDefined("request.dsn1") and len(request.dsn1) ? '' : 'error'#">
                    <cfif isDefined("request.dsn1") and len(request.dsn1)>
                        #HTMLEditFormat(request.dsn1)#
                    <cfelse>
                        TANIMSIZ
                    </cfif>
                </span>
            </div>
            
            <div class="debug-item">
                <strong>Request DSN2:</strong> 
                <span class="#isDefined("request.dsn2") and len(request.dsn2) ? '' : 'error'#">
                    <cfif isDefined("request.dsn2") and len(request.dsn2)>
                        #HTMLEditFormat(request.dsn2)#
                    <cfelse>
                        TANIMSIZ
                    </cfif>
                </span>
            </div>
            
            <div class="debug-item">
                <strong>Request DSN3:</strong> 
                <span class="#isDefined("request.dsn3") and len(request.dsn3) ? '' : 'error'#">
                    <cfif isDefined("request.dsn3") and len(request.dsn3)>
                        #HTMLEditFormat(request.dsn3)#
                    <cfelse>
                        TANIMSIZ
                    </cfif>
                </span>
            </div>
            
            <div class="debug-item">
                <strong>Variables DSN:</strong> 
                <span class="#isDefined("variables.dsn") and len(variables.dsn) ? '' : 'error'#">
                    <cfif isDefined("variables.dsn") and len(variables.dsn)>
                        #HTMLEditFormat(variables.dsn)#
                    <cfelse>
                        TANIMSIZ
                    </cfif>
                </span>
            </div>
            
            <div class="debug-item">
                <strong>Session B2B:</strong> 
                <span class="#isDefined("session.b2b") ? '' : 'error'#">
                    <cfif isDefined("session.b2b")>
                        TANIMLI
                    <cfelse>
                        TANIMSIZ
                    </cfif>
                </span>
            </div>
            
            <div class="debug-item">
                <strong>Session LoggedIn:</strong> 
                <span class="#isDefined("session.b2b") and isDefined("session.b2b.loggedIn") and session.b2b.loggedIn ? '' : 'error'#">
                    <cfif isDefined("session.b2b") and isDefined("session.b2b.loggedIn")>
                        #session.b2b.loggedIn ? "EVET" : "HAYIR"#
                    <cfelse>
                        TANIMSIZ
                    </cfif>
                </span>
            </div>
            
            <a href="index.cfm?fuseaction=partner.login" class="btn-back">← Login Sayfasına Dön</a>
        </div>
        </cfoutput>
    </body>
    </html>
    <cfabort>
</cfif>

<cftry>
    <cfparam name="form.username" default="">
    <cfparam name="form.password" default="">

    <!--- Form kontrolü --->
    <cfif not len(trim(form.username)) or not len(trim(form.password))>
        <cflocation url="index.cfm?fuseaction=partner.login&error=#URLEncodedFormat('Kullanıcı adı ve şifre gereklidir')#" addtoken="false">
        <cfabort>
    </cfif>

    <!--- Kullanıcı bilgilerini al --->
    <cftry>
        <cfquery name="checkUser" datasource="#request.dsn#">
            SELECT        
                C.COMPANY_ID, 
                C.MEMBER_CODE, 
                C.FULLNAME, 
                CP.PARTNER_ID, 
                CP.COMPANY_PARTNER_USERNAME, 
                CP.COMPANY_PARTNER_PASSWORD, 
                CP.COMPANY_PARTNER_NAME, 
                CP.COMPANY_PARTNER_SURNAME, 
                CP.COMPANY_PARTNER_EMAIL, 
                CP.MOBIL_CODE, 
                CP.MOBILTEL, 
                CP.PHOTO, 
                CP.TITLE
            FROM            
                COMPANY AS C INNER JOIN
                COMPANY_PARTNER AS CP ON C.COMPANY_ID = CP.COMPANY_ID
            WHERE        
                (C.COMPANY_STATUS = 1) 
                AND (CP.COMPANY_PARTNER_STATUS = 1)
                AND (CP.COMPANY_PARTNER_USERNAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(form.username)#">)
        </cfquery>
        
        <cfcatch type="database">
            <cflocation url="index.cfm?fuseaction=partner.login&error=#URLEncodedFormat('Veritabanı hatası: ' & cfcatch.message)#" addtoken="false">
            <cfabort>
        </cfcatch>
        <cfcatch type="any">
            <cflocation url="index.cfm?fuseaction=partner.login&error=#URLEncodedFormat('Sistem hatası: ' & cfcatch.message)#" addtoken="false">
            <cfabort>
        </cfcatch>
    </cftry>

    <!--- Kullanıcı kontrolü --->
    <cfif checkUser.recordcount eq 0>
        <cflocation url="index.cfm?fuseaction=partner.login&error=#URLEncodedFormat('Kullanıcı adı veya şifre hatalı')#" addtoken="false">
        <cfabort>
    </cfif>

    <!--- Şifre kontrolü (SHA-256 hash) --->
    <cfset hashedPassword = Hash(trim(form.password), "SHA-256")>
    <cfif checkUser.COMPANY_PARTNER_PASSWORD neq hashedPassword>
        <cflocation url="index.cfm?fuseaction=partner.login&error=#URLEncodedFormat('Kullanıcı adı veya şifre hatalı')#" addtoken="false">
        <cfabort>
    </cfif>

    <!--- COMPANY_ID kullanıcının sahip olduğu şirket ID'si (COMPANY_PARTNER tablosundan) --->
    <cfset companyId = checkUser.COMPANY_ID>

    <!--- Session oluştur --->
    <cfscript>
        session.b2b.loggedIn = true;
        session.b2b.userId = checkUser.PARTNER_ID;
        session.b2b.username = checkUser.COMPANY_PARTNER_USERNAME;
        session.b2b.companyId = companyId; // Kullanıcının sahip olduğu şirket ID'si (COMPANY_PARTNER tablosundan)
        session.b2b.partnerId = checkUser.PARTNER_ID;
        session.b2b.memberCode = checkUser.MEMBER_CODE;
        session.b2b.fullName = checkUser.FULLNAME;
        session.b2b.partnerName = checkUser.COMPANY_PARTNER_NAME;
        session.b2b.partnerSurname = checkUser.COMPANY_PARTNER_SURNAME;
        session.b2b.partnerEmail = checkUser.COMPANY_PARTNER_EMAIL;
        session.b2b.partnerMobile = checkUser.MOBIL_CODE & checkUser.MOBILTEL;
        session.b2b.partnerPhoto = checkUser.PHOTO;
        session.b2b.partnerTitle = checkUser.TITLE;
        // compId ve periodYear setup sayfasından belirlenir
        session.b2b.loginTime = now();
    </cfscript>

    <!--- Dashboard'a yönlendir --->
    <cflocation url="index.cfm?fuseaction=partner.dashboard" addtoken="false">
    
    <cfcatch type="any">
        <!--- Hata durumunda login sayfasına yönlendir --->
        <cflocation url="index.cfm?fuseaction=partner.login&error=#URLEncodedFormat('Beklenmeyen bir hata oluştu: ' & cfcatch.message)#" addtoken="false">
        <cfabort>
    </cfcatch>
</cftry>

