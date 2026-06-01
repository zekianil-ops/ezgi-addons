<!---
    File: Application.cfc
    Folder: AddOns/ezgi/e_partner
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Application Configuration
--->
<cfcomponent displayname="B2B Partner Application" output="true" hint="B2B Partner Portal uygulama yönetimi">
    <cfscript>
        this.name = hash(getCurrentTemplatePath()) & 'B2BPARTNER';
        this.sessionManagement = true;
        this.sessionTimeout = CreateTimeSpan(0, 8, 0, 0); // 8 saat
        this.clientManagement = true;
        this.setClientCookies = true;
        this.secureJSON = "True";
        this.secureJSONPrefix = "//";
        
        // Custom tag paths
        this.customtagpaths = '';
        basePath = getDirectoryFromPath(getCurrentTemplatePath());
        rootPath = replace(basePath, "AddOns\ezgi\e_partner\", "", "all");
        this.customtagpaths = ListAppend(this.customtagpaths, rootPath & "CustomTags");
        this.customtagpaths = ListAppend(this.customtagpaths, rootPath & "Utility/CustomTag");
        this.customtagpaths = ListAppend(this.customtagpaths, rootPath & "AddOns/CustomTags");
    </cfscript>
    
    <!--- Sayfa request özellikleri --->
    <cfsetting requesttimeout="300" showdebugoutput="false" enablecfoutputonly="false" />
    
    <!--- On Application Start --->
    <cffunction name="OnApplicationStart" access="public" returntype="boolean" output="false">
        <cfscript>
            // Application scope değişkenleri
            application.b2b = structNew();
            application.b2b.initialized = true;
            application.b2b.version = "1.0.0";
            application.b2b.startTime = now();
        </cfscript>
        
        <cfreturn true />
    </cffunction>
    
    <!--- On Session Start --->
    <cffunction name="OnSessionStart" access="public" returntype="void" output="false">
        <cfscript>
            // Session başlangıç değerleri
            session.b2b = structNew();
            session.b2b.loggedIn = false;
            session.b2b.userId = 0;
            session.b2b.companyId = 0;
            session.b2b.periodYear = '2026'; // Varsayılan dönem yılı
            session.b2b.language = 'tr';
        </cfscript>
    </cffunction>
    
    <!--- On Request Start --->
    <cffunction name="OnRequestStart" access="public" returntype="boolean" output="true">
        <cfargument name="targetPage" type="string" required="true" />
        
        <!--- Application başlatılmamışsa başlat --->
        <cfif not structKeyExists(application, "b2b") or not application.b2b.initialized>
            <cfset OnApplicationStart()>
        </cfif>
        
        <!--- Session başlatılmamışsa başlat --->
        <cfif not structKeyExists(session, "b2b")>
            <cfset OnSessionStart()>
        </cfif>
        
        <!--- Config dosyasını yükle (varsa) --->
        <cfset var configPath = expandPath("./config.cfm")>
        <cfif fileExists(configPath)>
            <cfset var config = structNew()>
            <cfinclude template="./config.cfm">
            
            <!--- Config'de COMP_ID tanımlıysa, session'a uygula --->
            <cfif structKeyExists(config, "COMP_ID") and len(trim(config.COMP_ID)) and isNumeric(trim(config.COMP_ID))>
                <cfif not structKeyExists(session, "b2b")>
                    <cfset OnSessionStart()>
                </cfif>
                <cfset session.b2b.compId = trim(config.COMP_ID)>
                
                <!--- Config'de PERIOD_YEAR tanımlıysa kullan, yoksa sorgu ile al --->
                <cfif structKeyExists(config, "PERIOD_YEAR") and len(trim(config.PERIOD_YEAR))>
                    <cfset session.b2b.periodYear = trim(config.PERIOD_YEAR)>
                <cfelse>
                    <!--- PERIOD_YEAR'ı sorgu ile al --->
                    <cftry>
                        <cfquery name="getPeriod" datasource="#dsn#">
                            SELECT        
                                TOP (1) PERIOD_YEAR
                            FROM            
                                SETUP_PERIOD
                            WHERE        
                                (OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.b2b.compId#">)
                            ORDER BY 
                                PERIOD_YEAR DESC
                        </cfquery>
                        <cfif getPeriod.recordcount gt 0>
                            <cfset session.b2b.periodYear = getPeriod.PERIOD_YEAR>
                        </cfif>
                        <cfcatch>
                            <!--- Hata durumunda varsayılan yıl --->
                            <cfset session.b2b.periodYear = year(now())>
                        </cfcatch>
                    </cftry>
                </cfif>
            </cfif>
        </cfif>
        
        <!--- Veritabanı bağlantı bilgileri --->
        <!--- Ana datasource --->
        <cfset dsn = "demo_ezgiyazilim">
        
        <!--- Product datasource (ortak, tüm şirketler kullanır) --->
        <cfset dsn1 = "demo_ezgiyazilim_product">
        
        <!--- Dönem datasource (yıl bazlı) - COMP_ID'ye göre belirlenir --->
        <cfif isDefined("session.b2b") and isDefined("session.b2b.compId") and isDefined("session.b2b.periodYear") and session.b2b.compId gt 0 and len(session.b2b.periodYear)>
            <cfset dsn2 = "#dsn#_#session.b2b.periodYear#_#session.b2b.compId#">
        <cfelse>
            <!--- Varsayılan dönem datasource (2026 yılı, comp 1) --->
            <cfset dsn2 = "#dsn#_2026_1">
        </cfif>
        
        <!--- Company-specific datasource - COMP_ID'ye göre belirlenir --->
        <cfif isDefined("session.b2b") and isDefined("session.b2b.compId") and session.b2b.compId gt 0>
            <cfset dsn3 = "#dsn#_#session.b2b.compId#">
        <cfelse>
            <!--- Varsayılan company datasource (test için) --->
            <cfset dsn3 = "#dsn#_1">
        </cfif>
        
        <!--- DSN alias'ları --->
        <cfset dsn_alias = dsn>
        <cfset dsn1_alias = dsn1>
        <cfset dsn2_alias = dsn2>
        <cfset dsn3_alias = dsn3>
        
        <!--- DSN değişkenlerini request scope'a ekle (tüm sayfalarda kullanılabilir) --->
        <cfset request.dsn = dsn>
        <cfset request.dsn1 = dsn1>
        <cfset request.dsn2 = dsn2>
        <cfset request.dsn3 = dsn3>
        <cfset request.dsn_alias = dsn_alias>
        <cfset request.dsn1_alias = dsn1_alias>
        <cfset request.dsn2_alias = dsn2_alias>
        <cfset request.dsn3_alias = dsn3_alias>
        
        <!--- Variables scope'a da ekle (include edilen sayfalarda kullanılabilir) --->
        <cfset variables.dsn = dsn>
        <cfset variables.dsn1 = dsn1>
        <cfset variables.dsn2 = dsn2>
        <cfset variables.dsn3 = dsn3>
        <cfset variables.dsn_alias = dsn_alias>
        <cfset variables.dsn1_alias = dsn1_alias>
        <cfset variables.dsn2_alias = dsn2_alias>
        <cfset variables.dsn3_alias = dsn3_alias>
        
        <!--- Login kontrolü (login sayfası hariç) --->
        <cfset var loginRequired = true>
        <cfset var currentPage = listLast(arguments.targetPage, "/\")>
        
        <!--- Public sayfalar (login gerektirmez) --->
        <cfif currentPage eq "index.cfm">
            <cfif not structKeyExists(url, "fuseaction")>
                <!--- Fuseaction yoksa login sayfasına yönlendir --->
                <cfset loginRequired = false>
            <cfelseif url.fuseaction eq "partner.login" or url.fuseaction eq "partner.logout" or url.fuseaction eq "partner.login_process">
                <!--- Login, logout ve login_process sayfaları public --->
                <cfset loginRequired = false>
            <cfelse>
                <!--- Diğer tüm partner sayfaları login gerektirir --->
                <cfset loginRequired = true>
            </cfif>
        </cfif>
        
        <!--- Login kontrolü --->
        <cfif loginRequired>
            <cfif not structKeyExists(session, "b2b") or not structKeyExists(session.b2b, "loggedIn") or not session.b2b.loggedIn>
                <cflocation url="index.cfm?fuseaction=partner.login" addtoken="false">
                <cfreturn false>
            </cfif>
        </cfif>
        
        <cfreturn true />
    </cffunction>
    
    <!--- On Error --->
    <cffunction name="onError" access="public" returntype="void" output="true">
        <cfargument name="exception" type="any" required="true" />
        <cfargument name="eventName" type="string" required="true" />
        
        <!--- Hata loglama --->
        <cflog file="b2b_errors" text="Error: #arguments.exception.message# | Detail: #arguments.exception.detail# | StackTrace: #arguments.exception.stackTrace#">
        
        <!--- Kullanıcıya hata mesajı göster --->
        <cfoutput>
            <div style="padding: 20px; font-family: Arial; color: ##d32f2f;">
                <h2>Bir Hata Oluştu</h2>
                <p>Lütfen sistem yöneticinize başvurun.</p>
                <cfif structKeyExists(arguments.exception, "message")>
                    <p style="font-size: 12px; color: ##666;">Hata: #arguments.exception.message#</p>
                </cfif>
            </div>
        </cfoutput>
    </cffunction>
</cfcomponent>

