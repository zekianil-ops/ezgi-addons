<cfcomponent extends = "WMO.functions">
    <cfset dsn = application.systemParam.systemParam().dsn />
    <cfset dsn1 = "#dsn#_product" />
    <cfset dsn3 = "#dsn#_#session.ep.company_id#" />
    <cfset queryJSONConverter = createObject("component","cfc.queryJSONConverter") />

    <cffunction name="set_package" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="design_main_row_id" type="numeric">
        
        <cfset response = structNew() />
        <cfset response.status = true />

        <!--- <cftry> --->
            
            <cftransaction>
                <cfquery name="GET_DEFAULT_PACKING" datasource="#dsn3#">
                    SELECT        
                        OTT.OPERATION_TYPE_ID
                    FROM           
                        OPERATION_TYPES AS OTT WITH (NOLOCK) INNER JOIN
                        EZGI_DESIGN_DEFAULTS AS EDD WITH (NOLOCK) ON OTT.OPERATION_TYPE_ID = EDD.DEFAULT_PACKAGE_OPERATION_TYPE_ID
                </cfquery>

                <cfif not GET_DEFAULT_PACKING.recordcount>
                    <cfset response.status = false />
                    <cfset response.message = this.getLang('','Genel Default Tanımlarda Paketleme Operasyonu Tanımlı Değil. Düzenleyip Tekrar Deneyin',1171) />
                <cfelse>
                    <cfquery name="get_defaults" datasource="#dsn3#">
                        SELECT * FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
                    </cfquery>
                    <cfquery name="get_design_package_row" datasource="#dsn3#">
                        SELECT TOP(1) * FROM EZGI_DESIGN_PACKAGE WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #arguments.design_main_row_id# ORDER BY PACKAGE_NUMBER desc
                    </cfquery>
                    <cfquery name="get_design_main_row" datasource="#dsn3#">
                        SELECT * FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #arguments.design_main_row_id#
                    </cfquery>
                    
                    <cfset package_number = get_design_package_row.recordcount ? get_design_package_row.PACKAGE_NUMBER + 1 : 1>

                    <cfif isdefined('arguments.is_private') and package_number gt 0> <!---Özel Tasarıma Yeni Paket Eklendiğinde Default Paket Örnek Alınıyor--->
                        <cfif len(get_defaults.PROTOTIP_PACKAGE_ID)>
                            <cfquery name="package_defaults" datasource="#dsn3#">
                                SELECT        
                                    EDPP.PACKAGE_ROW_ID, 
                                    S.STOCK_ID, 
                                    EDPP.PACKAGE_NUMBER, 
                                    EDPP.PACKAGE_NAME
                                FROM            
                                    EZGI_DESIGN_PACKAGE_ROW AS EDPP LEFT OUTER JOIN
                                    STOCKS AS S ON EDPP.PACKAGE_RELATED_ID = S.STOCK_ID
                                WHERE        
                                    EDPP.DESIGN_MAIN_ROW_ID = #get_defaults.PROTOTIP_PACKAGE_ID#
                            </cfquery>
                            <cfif package_defaults.recordcount>
                                <cfquery name="get_related_id" dbtype="query">
                                    SELECT * FROM package_defaults WHERE PACKAGE_NUMBER = #package_number#
                                </cfquery>
                                <cfif not len(get_related_id.STOCK_ID)>
                                    <cfset response.status = false />
                                    <cfset response.message = package_number & " " & this.getLang('','Nolu',49280) & " " & this.getLang('','İlişkili Master Paket',57) & " - " & this.getLang('','Kayıt Bulunamadı',58486) />
                                </cfif>
                            <cfelse>
                                <cfset response.status = false />
                                <cfset response.message = package_number & " " & this.getLang('','Nolu',49280) & " " & this.getLang('','İlişkili Master Paket',57) & " - " & this.getLang('','Ürün Transferi Eksik',172) />
                            </cfif>
                        <cfelse>
                            <cfset response.status = false />
                            <cfset response.message = this.getLang('','Zorunlu Alan',782) & ": " & this.getLang('','Tasarım Genel Default Tanımları',114) />
                        </cfif>
                    </cfif>
                    <cfif response.status>
                        <cfset package_name = "#get_design_main_row.DESIGN_MAIN_NAME# - #package_number# .#this.getLang('main',2903)#">
                        <cfquery name="add_package" datasource="#dsn3#">
                            INSERT INTO EZGI_DESIGN_PACKAGE_ROW(
                                DESIGN_ID, 
                                DESIGN_MAIN_ROW_ID, 
                                PACKAGE_NUMBER, 
                                PACKAGE_NAME, 
                                PACKAGE_COLOR_ID, 
                                PACKAGE_AMOUNT
                                <cfif isdefined('arguments.is_private') and package_number gt 0>
                                    ,PACKAGE_RELATED_ID
                                </cfif>
                            )
                            VALUES(
                                #get_design_main_row.DESIGN_ID#,
                                #get_design_main_row.DESIGN_MAIN_ROW_ID#,
                                #package_number#,
                                '#package_name#',
                                #get_design_main_row.DESIGN_MAIN_COLOR_ID#,
                                1
                                <cfif isdefined('arguments.is_private') and package_number gt 0>
                                    ,#get_related_id.STOCK_ID#
                                </cfif>
                            )
                        </cfquery>
                        <cfquery name="get_max_id" datasource="#dsn3#">
                            SELECT MAX(PACKAGE_ROW_ID) AS MAX_ID FROM EZGI_DESIGN_PACKAGE_ROW
                        </cfquery>
                        <cfquery name="add_rota" datasource="#dsn3#">
                            INSERT INTO EZGI_DESIGN_PIECE_ROTA(
                                PACKAGE_ROW_ID, 
                                OPERATION_TYPE_ID, 
                                SIRA, 
                                AMOUNT
                            )
                            VALUES(   
                                #get_max_id.MAX_ID#,     
                                #GET_DEFAULT_PACKING.OPERATION_TYPE_ID#,
                                0, 
                                1
                            )
                        </cfquery>
                        <cfset response.data = queryJSONConverter.returnData( replace(serializeJSON( this.get_package(arguments.design_main_row_id) ),"//","") ) />
                    </cfif>

                </cfif>
            </cftransaction>
            
            <!--- <cfcatch type="any">
                <cfset response.status = false />
                <cfset response.message = this.getLang('','Bir hata oluştu',52126) />
            </cfcatch>
        </cftry> --->

        <cfreturn replace(serializeJSON(response),"//","") />
    </cffunction>

    <cffunction name="get_package" access="remote" returntype="query">
        <cfargument name="design_main_row_id" type="numeric">

        <cfquery name="q_get_package" datasource="#dsn3#">
            SELECT 
                TOP 1
                *,
                (SELECT DESIGN_MAIN_NAME FROM EZGI_DESIGN_MAIN_ROW WHERE DESIGN_MAIN_ROW_ID = EZGI_DESIGN_PACKAGE.DESIGN_MAIN_ROW_ID) as DESIGN_MAIN_NAME,
                (
                    SELECT        
                        EDS.MAIN_ROW_SETUP_CODE
                    FROM           
                        EZGI_DESIGN_MAIN_ROW_SETUP AS EDS WITH (NOLOCK) INNER JOIN
                        EZGI_DESIGN_MAIN_ROW AS EDM WITH (NOLOCK) ON EDS.MAIN_ROW_SETUP_ID = EDM.MAIN_ROW_SETUP_ID
                    WHERE        
                        EDM.DESIGN_MAIN_ROW_ID = EZGI_DESIGN_PACKAGE.DESIGN_MAIN_ROW_ID
                ) AS CODE
            FROM EZGI_DESIGN_PACKAGE WITH (NOLOCK)
            WHERE DESIGN_MAIN_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.design_main_row_id#">
            ORDER BY 
                PACKAGE_ROW_ID DESC,
                CODE ASC, 
                PACKAGE_NUMBER ASC
        </cfquery>

        <cfreturn q_get_package />

    </cffunction>

    

</cfcomponent>