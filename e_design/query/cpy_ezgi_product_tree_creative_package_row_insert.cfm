<!---
    File: cpy_ezgi_product_tree_creative_package_row_insert.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

    <cfquery name="get_old_design_id" datasource="#dsn3#">
    	SELECT 
        	DESIGN_ID,
            DESIGN_MAIN_NAME,
            (SELECT MAIN_ROW_SETUP_NAME FROM EZGI_DESIGN_MAIN_ROW_SETUP WITH (NOLOCK) WHERE MAIN_ROW_SETUP_ID = D.MAIN_ROW_SETUP_ID) as MAIN_ROW_SETUP_NAME,
            (SELECT COLOR_NAME FROM EZGI_COLORS WITH (NOLOCK) WHERE COLOR_ID = D.DESIGN_MAIN_COLOR_ID) AS COLOR_NAME
      	FROM 
        	EZGI_DESIGN_MAIN_ROW D WITH (NOLOCK)
       	WHERE 
        	DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID#
    </cfquery>

    <cfquery name="get_new_design_id" datasource="#dsn3#">
    	SELECT 
        	DESIGN_ID,
            DESIGN_MAIN_NAME,
            (SELECT MAIN_ROW_SETUP_NAME FROM EZGI_DESIGN_MAIN_ROW_SETUP WITH (NOLOCK) WHERE MAIN_ROW_SETUP_ID = D.MAIN_ROW_SETUP_ID) as MAIN_ROW_SETUP_NAME,
            (SELECT COLOR_NAME FROM EZGI_COLORS WITH (NOLOCK) WHERE COLOR_ID = D.DESIGN_MAIN_COLOR_ID) AS COLOR_NAME
      	FROM 
        	EZGI_DESIGN_MAIN_ROW D WITH (NOLOCK)
       	WHERE 
        	DESIGN_MAIN_ROW_ID = #attributes.sid#
    </cfquery>

    <cfif isdefined('attributes.main')>
    	<cfif isdefined('attributes.package_piece_select')><!--- Modüle Ait Tüm Paket Parçaları Uyumlu Kopyala İse--->
        	<cfset sub_list = ''>
        	<cfloop list="#attributes.PIECE_ROW_ID_LIST#" index="w"> <!---Öncelikle Montaj Ürününe Bağlanan Alt Parçaları Buluyoruz--->
            	<cfif isdefined('PIECE_SUB_ID_#w#') and Evaluate('PIECE_SUB_ID_#w#')gt 0>
                	<cfset sub_list = ListAppend(sub_list,Evaluate('PIECE_SUB_ID_#w#'))>
                </cfif>
            </cfloop>
            <cfset sub_list = ListDeleteDuplicates(sub_list,',')> 
            <cfloop list="#sub_list#" index="i">
                    <cfSET cpy_piece_id = i>
                    <cfset get_max_id.max_id = 'NULL'>
                    <cfif isdefined('PIECE_ORTAK_#i#') and Evaluate('PIECE_ORTAK_#i#') eq ''> <!---Ortak veya Master Parça Değilse--->
                    	<cfinclude template="cpy_ezgi_product_tree_creative_package_piece_row.cfm">
                    </cfif>
            </cfloop>
        	<cfquery name="get_package" datasource="#dsn3#">
                SELECT * FROM EZGI_DESIGN_PACKAGE WHERE DESIGN_MAIN_ROW_ID = #attributes.sid# ORDER BY PACKAGE_NUMBER
            </cfquery>
            <cfloop query="get_package"><!---Seçilen Modülün Paket Bilgilerini Çekiyoruz--->
				<cfset new_package_name = Replace(get_package.PACKAGE_NAME,'#get_new_design_id.MAIN_ROW_SETUP_NAME#','#get_old_design_id.MAIN_ROW_SETUP_NAME#','All')>
                <!---Paketin İsmini Değiştiriyoruz--->
                <cfquery name="add_package" datasource="#dsn3#"><!--- Paketin Kaydını Yapıyoruz.--->
                    INSERT INTO 
                        EZGI_DESIGN_PACKAGE_ROW
                        (
                            DESIGN_ID, 
                            <cfif isdefined('attributes.collect_add')>
                                PACKAGE_RELATED_ID,
                            </cfif>
                            DESIGN_MAIN_ROW_ID, 
                            PACKAGE_NUMBER, 
                            PACKAGE_AMOUNT,
                            PACKAGE_COLOR_ID,
                            PACKAGE_NAME,
                            PACKAGE_PARTNER_ID,
                            PACKAGE_IS_MASTER
                        )
                    VALUES
                        (
							<cfif isdefined('attributes.collect_add')>
                                #attributes.DESIGN_ID#,
                                #get_package.PACKAGE_RELATED_ID#,
                            <cfelse>
                                #get_old_design_id.DESIGN_ID#,
                            </cfif>
                            #attributes.DESIGN_MAIN_ROW_ID#,
                            #get_package.PACKAGE_NUMBER#,
                            #get_package.PACKAGE_AMOUNT#,
                            <cfif get_package.PACKAGE_IS_MASTER eq 0>
                                #get_package.PACKAGE_COLOR_ID#,
                                '#get_package.PACKAGE_NAME#',
                                #get_package.PACKAGE_PARTNER_ID#,
                                0
                            <cfelseif get_package.PACKAGE_IS_MASTER eq 1>
                                #get_package.PACKAGE_COLOR_ID#,
                                '#get_package.PACKAGE_NAME#',
                                #get_package.PACKAGE_ROW_ID#,
                                0
                            <cfelse>
                                #get_package.PACKAGE_COLOR_ID#,
                                '#new_package_name#',
                                NULL,
                                NULL
                            </cfif>
                        )
                </cfquery>
                <cfif not get_package.PACKAGE_IS_MASTER eq 0 and not get_package.PACKAGE_IS_MASTER eq 1> <!---Eğer Ortak Paket Değilse--->
                    <cfquery name="get_max_id" datasource="#dsn3#">
                        SELECT MAX(PACKAGE_ROW_ID) AS MAX_ID FROM EZGI_DESIGN_PACKAGE_ROW
                    </cfquery>
                    <cfquery name="add_main_rota" datasource="#dsn3#"> 
                    	INSERT INTO 
                        	EZGI_DESIGN_PIECE_ROTA
                  			(
                            	OPERATION_TYPE_ID, 
                                SIRA, 
                                AMOUNT, 
                                PACKAGE_ROW_ID
                          	)
						SELECT     
                        	OPERATION_TYPE_ID, 
                            SIRA, 
                            AMOUNT, 
                            #get_max_id.MAX_ID#
						FROM        
                        	EZGI_DESIGN_PIECE_ROTA WITH (NOLOCK)
						WHERE     
                        	PACKAGE_ROW_ID = #get_package.PACKAGE_ROW_ID#
                    </cfquery>
                    <cfquery name="get_piece_id" datasource="#dsn3#">
                    	SELECT 
                        	PIECE_ROW_ID,
                            PIECE_TYPE 
                       	FROM 
                        	EZGI_DESIGN_PIECE  WITH (NOLOCK)
                       	WHERE 
                        	DESIGN_PACKAGE_ROW_ID = #get_package.PACKAGE_ROW_ID# 
                            <cfif ListLen(sub_list)>
                            	AND PIECE_ROW_ID NOT IN (#sub_list#)
                          	</cfif>
                    </cfquery>
                    <cfif get_piece_id.recordcount>
                    	<cfloop query="get_piece_id">
                    		<cfSET cpy_piece_id = get_piece_id.PIECE_ROW_ID>
                            <cfinclude template="cpy_ezgi_product_tree_creative_package_piece_row.cfm">
                    	</cfloop>
                 	</cfif>
                </cfif>
          	</cfloop>
        <cfelse>
        	<cfset sub_list = ''>
            <cfset ust_list = ''>
            <cfset orta_list = ''>
        	<cfloop list="#attributes.PIECE_ROW_ID_LIST#" index="w"> <!---Öncelikle Montaj Ürününe Bağlanan Alt Parçaları Buluyoruz--->
            	<cfif isdefined('PIECE_SUB_ID_#w#') and Evaluate('PIECE_SUB_ID_#w#')gt 0 and isdefined('attributes.a_#w#')> <!---Montaja Bağlı Alt parçalar mı--->
                	<cfset sub_list = ListAppend(sub_list,Evaluate('PIECE_SUB_ID_#w#'))> <!---Montaja Bağlı Alt parçalar--->
                	<cfset ust_list = ListAppend(ust_list,w)><!---Montaja Bağlı Üst parçalar--->
                <cfelse>
                	<cfif isdefined('attributes.a_#w#')>
                    	<cfset orta_list = ListAppend(orta_list,w)> <!---Montaja Bağlı alt ve üst parça olmayanlar--->
                    </cfif>
                </cfif>
            </cfloop>
            <cfset sub_list = ListDeleteDuplicates(sub_list,',')> 
            <cfset ust_list = ListDeleteDuplicates(ust_list,',')> 
            <cfset orta_list = ListDeleteDuplicates(orta_list,',')> 
            <cfloop list="#sub_list#" index="i">
            	<cfset sub_piece = 1>
             	<cfSET cpy_piece_id = i>
              	<cfset get_max_id.max_id = 'NULL'>
              	<cfinclude template="cpy_ezgi_product_tree_creative_package_piece_row.cfm">
            </cfloop>
        	<cfloop list="#ust_list#" index="i">
            	<cfset sub_piece = 0>
             	<cfSET cpy_piece_id = i>
              	<cfset get_max_id.max_id = 'NULL'>
              	<cfinclude template="cpy_ezgi_product_tree_creative_package_piece_row.cfm">
            </cfloop>
            <cfloop list="#orta_list#" index="i">
            	<cfif not Listfind(sub_list,i)>
					<cfset sub_piece = 0>
                    <cfSET cpy_piece_id = i>
                    <cfset get_max_id.max_id = 'NULL'>
                    <cfinclude template="cpy_ezgi_product_tree_creative_package_piece_row.cfm">
               	</cfif>
            </cfloop>
        </cfif>
        <cfif not isdefined('attributes.collect_add')>
			<script type="text/javascript">
                alert('<cf_get_lang dictionary_id='251.Parça Kopyalama İşlemi Başarıyla Tamamlandı!'>')
                wrk_opener_reload();
                window.close();
            </script>
        </cfif>
    <cfelse>
		<cfif get_old_design_id.recordcount eq 1 and len(get_old_design_id.DESIGN_ID)>
            <cfquery name="cpy_package" datasource="#dsn3#">
                INSERT INTO 
                    EZGI_DESIGN_PACKAGE_ROW
                    (
                        DESIGN_ID,
                        DESIGN_MAIN_ROW_ID, 
                        MASTER_PRODUCT_ID, 
                        PACKAGE_NUMBER, 
                        PACKAGE_NAME, 
                        PACKAGE_COLOR_ID, 
                        PACKAGE_AMOUNT, 
                        PACKAGE_PARTNER_ID,
                        PACKAGE_IS_MASTER
                        <cfif isdefined('attributes.private')> <!---Özel Tasarımdan Geliyorsa--->
                        	,PACKAGE_SPECT_RELATED_ID
                        </cfif>
                    )
                SELECT        
                    #get_old_design_id.DESIGN_ID#, 
                    #attributes.DESIGN_MAIN_ROW_ID#, 
                    MASTER_PRODUCT_ID, 
                    PACKAGE_NUMBER, 
                    PACKAGE_NAME, 
                    PACKAGE_COLOR_ID, 
                    PACKAGE_AMOUNT, 
                    PACKAGE_ROW_ID,
                    0 AS IS_MASTER
                    <cfif isdefined('attributes.private')> <!---Özel Tasarımdan Geliyorsa--->
                    	,(SELECT TOP (1) SPECT_MAIN_ID FROM SPECT_MAIN WHERE STOCK_ID = EZGI_DESIGN_PACKAGE.PACKAGE_RELATED_ID AND IS_TREE = 1 AND SPECT_STATUS = 1
ORDER BY SPECT_MAIN_ID DESC) AS SPECT_MAIN_ID
                    </cfif>
                FROM            
                    EZGI_DESIGN_PACKAGE WITH (NOLOCK)
                WHERE        
                    PACKAGE_ROW_ID = #attributes.sid#
            </cfquery>
            <script type="text/javascript">
                alert('<cf_get_lang dictionary_id='251.Parça Kopyalama İşlemi Başarıyla Tamamlandı!'>')
                wrk_opener_reload();
                window.close();
            </script>
     	<cfelse>
            <cf_get_lang dictionary_id='252.Çalıştığınız Modül Birden Fazla Tasarıma Bağlı Ya Da Herhangi Bir Tasarıma Bağlanmamış !'>
            <cfabort>
        </cfif>
 	</cfif>