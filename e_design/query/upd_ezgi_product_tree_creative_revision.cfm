<cfparam name="attributes.type" default="0">
<cfquery name="get_product_name" datasource="#dsn3#">
	SELECT PRODUCT_NAME FROM STOCKS WHERE STOCK_ID = #attributes.new_stock_id#
</cfquery>
<cfset list_find_modul_id = ''>
<cfset list_find_package_id = ''>
<cfset list_find_piece_id = ''>
<cfif Listlen(attributes.convert_design_id)>
	<cftransaction>
        <cfloop list="#attributes.convert_design_id#" index="i">
            <cfquery name="get_piece_row_row" datasource="#dsn3#"> <!---Parça İçindeki Aksesuarlarda İlgili Ürünler Var mı--->
            	SELECT 
                	EPR.PIECE_ROW_ID, 
                    EPRR.STOCK_ID, 
                    EPRR.PIECE_ROW_ROW_ID,
                    EPR.PIECE_AMOUNT*EPRR.AMOUNT AS AMOUNT
				FROM     
             		EZGI_DESIGN_PIECE_ROWS AS EPR WITH (NOLOCK) INNER JOIN
                  	EZGI_DESIGN_PIECE_ROW AS EPRR WITH (NOLOCK) ON EPR.PIECE_ROW_ID = EPRR.PIECE_ROW_ID
				WHERE  
                	EPR.DESIGN_ID = #i# AND 
                    EPRR.PIECE_ROW_ROW_TYPE = 2	AND
                    EPRR.STOCK_ID IN (#attributes.new_stock_id#,#attributes.old_stock_id#)
           	</cfquery>
            <cfoutput query="get_piece_row_row">
            	<cfset 'PIECE_#PIECE_ROW_ID#' = AMOUNT>
            </cfoutput>
            <cfquery name="get_piece_row" datasource="#dsn3#"> <!---Paket İçindeki Aksesuarlarda İlgili Ürünler Var mı--->
            	SELECT 
                	DESIGN_PACKAGE_ROW_ID, 
                    PIECE_RELATED_ID AS STOCK_ID, 
                    PIECE_ROW_ID,
                    PIECE_AMOUNT AS AMOUNT
				FROM     
                	EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
				WHERE  
                	DESIGN_ID = #i# AND 
                    PIECE_TYPE = 4 AND
                    PIECE_RELATED_ID IN (#attributes.new_stock_id#,#attributes.old_stock_id#)
            </cfquery>
            <cfoutput query="get_piece_row">
            	<cfset 'PACKAGE_#DESIGN_PACKAGE_ROW_ID#' = AMOUNT>
            </cfoutput>
            <cfquery name="get_piece_row_row_group" dbtype="query"> <!---Parça İçindeki Aksesuarlarda Her İki Ürün de Var mı--->
            	SELECT 
                	PIECE_ROW_ID,
                    COUNT (*) AS SAYI
              	FROM
                	get_piece_row_row
               	GROUP BY
                	PIECE_ROW_ID
              	HAVING
                	COUNT (*) >1	
            </cfquery>
            <cfquery name="get_piece_row_group" dbtype="query"> <!---Paket İçindeki Aksesuarlarda Her İki Ürün de Var mı--->
            	SELECT 
                	DESIGN_PACKAGE_ROW_ID,
                    COUNT (*) AS SAYI
              	FROM
                	get_piece_row
               	GROUP BY
                	DESIGN_PACKAGE_ROW_ID
              	HAVING
                	COUNT (*) >1	
            </cfquery>
            <cfif get_piece_row_row_group.recordcount> <!---Eğer Parça İçindeki Aksesuarlarda Her İki Ürün de Var ise Durdur--->
            	<cfquery name="get_repeat_product" datasource="#dsn3#">
                	SELECT 
                    	ED.DESIGN_NAME, 
                        EPR.PIECE_NAME, 
                        EDM.DESIGN_MAIN_NAME, 
                        EPR.PIECE_CODE
					FROM     
                    	EZGI_DESIGN_MAIN_ROW AS EDM WITH (NOLOCK) INNER JOIN
                  		EZGI_DESIGN_PIECE_ROWS AS EPR WITH (NOLOCK) ON EDM.DESIGN_MAIN_ROW_ID = EPR.DESIGN_MAIN_ROW_ID INNER JOIN
                  		EZGI_DESIGN AS ED WITH (NOLOCK) ON EDM.DESIGN_ID = ED.DESIGN_ID
					WHERE  
                    	EPR.PIECE_ROW_ID = #get_piece_row_row_group.PIECE_ROW_ID#
                </cfquery>
            	<script type="text/javascript">
					alert("<cfoutput>Modül Adı : #get_repeat_product.DESIGN_MAIN_NAME# - Parça Adı : #get_repeat_product.PIECE_NAME# - Parça Kodu : #get_repeat_product.PIECE_CODE#</cfoutput> Değiştirmek İstediğin Ürün Zaten Bu Parçada Mevcut!");
					window.close();
				</script>
                <cfabort>
            </cfif>
            <cfif get_piece_row_group.recordcount> <!---Eğer Paket İçindeki Aksesuarlarda Her İki Ürün de Var ise Durdur--->
            	<cfquery name="get_repeat_product" datasource="#dsn3#">
                	SELECT 
                    	ED.DESIGN_NAME, 
                        EDM.DESIGN_MAIN_NAME, 
                        EDPR.PACKAGE_NUMBER, 
                        EDPR.PACKAGE_NAME
					FROM     
                    	EZGI_DESIGN_MAIN_ROW AS EDM WITH (NOLOCK) INNER JOIN
                  		EZGI_DESIGN AS ED WITH (NOLOCK) ON EDM.DESIGN_ID = ED.DESIGN_ID INNER JOIN
                  		EZGI_DESIGN_PACKAGE_ROW AS EDPR WITH (NOLOCK) ON EDM.DESIGN_MAIN_ROW_ID = EDPR.DESIGN_MAIN_ROW_ID
					WHERE  
                    	EDPR.PACKAGE_ROW_ID = #get_piece_row_group.DESIGN_PACKAGE_ROW_ID#
                </cfquery>
            	<script type="text/javascript">
					alert("<cfoutput>Modül Adı : #get_repeat_product.DESIGN_MAIN_NAME# - Paket Adı : #get_repeat_product.PACKAGE_NAME# - Paket No : #get_repeat_product.PACKAGE_NUMBER#</cfoutput> Değiştirmek İstediğin Ürün Zaten Bu Pakette Mevcut!");
					window.close();
				</script>
                <cfabort>
            </cfif>
       		<cfif get_piece_row_row.recordcount>
            	<cfquery name="get_piece_row_row_old_stock" dbtype="query"> <!---Parça İçindeki Aksesuarlarda Eski (Değişecek) Ürün de Var mı--->
                 	SELECT 
                    	PIECE_ROW_ID, 
                      	STOCK_ID, 
                      	PIECE_ROW_ROW_ID
                   	FROM     
                      	get_piece_row_row
                   	WHERE  
                    	STOCK_ID = #attributes.old_stock_id#
             	</cfquery>
              	<cfif get_piece_row_row_old_stock.recordcount> <!---Eğer Parça İçindeki Aksesuarlarda Değişcek Ürün Varsa--->
                 	<cfset PIECE_ROW_ROW_ID_list = ValueList(get_piece_row_row_old_stock.PIECE_ROW_ROW_ID)>
                  	<cfset pieces = ValueList(get_piece_row_row_old_stock.PIECE_ROW_ID)>
                  	<cfset pieces = ListDeleteDuplicates(pieces,',')>
                 	<cfif ListLen(pieces)>
                   		<cfset list_find_modul_id = ListAppend(list_find_modul_id,i)>
                     	<cfloop list="#pieces#" index="k">
                         	<cfset piece = '#i#_#k#'>
                        	<cfset list_find_piece_id = ListAppend(list_find_piece_id,piece)>
                      	</cfloop>
                        <cfif attributes.type eq 1> 
                            <cfquery name="upd_piece_row_row" datasource="#dsn3#"> <!---Parça İçindeki Eski Aksesuarı Yenisiyle Değiştir--->
                                UPDATE 
                                    EZGI_DESIGN_PIECE_ROW
                                SET          
                                    STOCK_ID = #attributes.new_stock_id#
                                WHERE  
                                    PIECE_ROW_ROW_ID IN (#PIECE_ROW_ROW_ID_list#) AND 
                                    STOCK_ID = #attributes.old_stock_id#
                            </cfquery>
                        </cfif>
               		</cfif>
               	</cfif>
         	</cfif>
         	<cfif get_piece_row.recordcount>
             	<cfquery name="get_piece_row_old_stock" dbtype="query"> <!---PAKET İçindeki Aksesuarlarda Eski (Değişecek) Ürün de Var mı--->
                 	SELECT 
                    	DESIGN_PACKAGE_ROW_ID, 
                      	STOCK_ID, 
                    	PIECE_ROW_ID
                 	FROM     
                    	get_piece_row
                	WHERE  
                   		STOCK_ID = #attributes.old_stock_id#
             	</cfquery>
            	<cfif get_piece_row_old_stock.recordcount> <!---Eğer PAKET İçindeki Aksesuarlarda Değişcek Ürün Varsa--->
                 	<cfset PIECE_ROW_ID_list = ValueList(get_piece_row_old_stock.PIECE_ROW_ID)>
                 	<cfif ListLen(PIECE_ROW_ID_list)>
                     	<cfset list_find_modul_id = ListAppend(list_find_modul_id,i)>
                      	<cfset packages = ValueList(get_piece_row_old_stock.DESIGN_PACKAGE_ROW_ID)>
                     	<cfset packages = ListDeleteDuplicates(packages,',')>
                     	<cfloop list="#packages#" index="k">
                         	<cfset package = '#i#_#k#'>
                        	<cfset list_find_package_id = ListAppend(list_find_package_id,package)>
                     	</cfloop>
                        <cfif attributes.type eq 1>
                            <cfquery name="upd_piece_row" datasource="#dsn3#"> <!---PaKET İçindeki Eski Aksesuarı Yenisiyle Değiştir--->
                                UPDATE 
                                	EZGI_DESIGN_PIECE_ROWS
    							SET          
                                	PIECE_RELATED_ID = #attributes.new_stock_id#,
                                    PIECE_NAME = '#get_product_name.product_name#'
    							WHERE  
                                	PIECE_ROW_ID IN (#PIECE_ROW_ID_list#) AND 
                                    PIECE_RELATED_ID = #attributes.old_stock_id# AND
                                    PIECE_TYPE = 4
                            </cfquery>
                       	</cfif>
                 	</cfif>
              	</cfif>
          	</cfif>
        </cfloop>
    </cftransaction>
</cfif>
<cfif Listlen(list_find_modul_id)>
	<cfset list_find_modul_id = ListDeleteDuplicates(list_find_modul_id,',')>
    <cfset list_find_package_id = ListDeleteDuplicates(list_find_package_id,',')>
    <cfset list_find_piece_id = ListDeleteDuplicates(list_find_piece_id,',')>
    <cfquery name="get_all_design" datasource="#dsn3#">
    	SELECT 
        	ED.DESIGN_ID, 
            ED.DESIGN_NAME, 
            EC.COLOR_NAME
		FROM     
        	EZGI_DESIGN AS ED WITH (NOLOCK) INNER JOIN
          	EZGI_COLORS AS EC WITH (NOLOCK) ON ED.COLOR_ID = EC.COLOR_ID
		WHERE  
        	ED.DESIGN_ID IN (#list_find_modul_id#)
    </cfquery>
    <cfif get_all_design.recordcount>
    	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    		<cfsavecontent variable="title"><cfoutput><cf_get_lang dictionary_id="33769.İlişkili İşlem Satırları"></cfoutput></cfsavecontent>
            <cf_box title="#title#">
                <cf_grid_list>
                	<thead>
                        <tr>
                            <th width="20"><cf_get_lang dictionary_id="58577.Sıra"></th>
                            <th><cf_get_lang dictionary_id="29792.Tasarım"></th>
                            <th width="100"><cf_get_lang dictionary_id="199.Renk"></th>
                            <th width="250"><cf_get_lang dictionary_id="141.Modül"></th>
                            <th width="250"><cf_get_lang dictionary_id="100.Paket"></th>
                            <th width="250"><cf_get_lang dictionary_id="45.Parça"></th>
                            <th width="70"><cf_get_lang dictionary_id="57635.Miktar"></th>
                            <cfif attributes.type eq 1><th width="25" class="header_icn_none"></th/></cfif>
                        </tr>
                    </thead>
                    <tbody>
						<cfif get_all_design.recordcount>
                            <cfoutput query="get_all_design">
                            	<cfset satir_list_package = ''>
                                <cfset satir_list_piece = ''>
                            	<cfloop list="#list_find_package_id#" index="ii">
                                	<cfif ListGetAt(ii,1,'_') eq DESIGN_ID>
                                    	<cfset satir_list_package = ListAppend(satir_list_package,ListGetAt(ii,2,'_'))>
                                    </cfif>
                                </cfloop>
                                <cfif ListLen(satir_list_package)>
                                	<cfquery name="get_packages" datasource="#dsn3#">
                                    	SELECT 
                                        	EDMR.DESIGN_MAIN_ROW_ID, 
                                            EDMR.DESIGN_MAIN_NAME, 
                                            EDPR.PACKAGE_ROW_ID, 
                                            EDPR.PACKAGE_NUMBER, 
                                            EDPR.PACKAGE_NAME, 
                                            EDPR.PACKAGE_IS_MASTER
										FROM     
                                        	EZGI_DESIGN_PACKAGE_ROW AS EDPR WITH (NOLOCK) INNER JOIN
                  							EZGI_DESIGN_MAIN_ROW AS EDMR WITH (NOLOCK) ON EDPR.DESIGN_MAIN_ROW_ID = EDMR.DESIGN_MAIN_ROW_ID
										WHERE  
                                        	EDPR.PACKAGE_ROW_ID IN (#satir_list_package#)
                                    </cfquery>
                                </cfif>
                            	<cfloop list="#list_find_piece_id#" index="kk">
                                	<cfif ListGetAt(kk,1,'_') eq DESIGN_ID>
                                    	<cfset satir_list_piece = ListAppend(satir_list_piece,ListGetAt(kk,2,'_'))>
                                    </cfif>
                                </cfloop>
                                <cfif ListLen(satir_list_piece)>
                                	<cfquery name="get_pieces" datasource="#dsn3#">
                                    	SELECT 
                                        	EDMR.DESIGN_MAIN_ROW_ID, 
                                            EDMR.DESIGN_MAIN_NAME, 
                                            EDPR.PIECE_ROW_ID, 
                                            EDPR.PIECE_NAME, 
                                            EDPR.PIECE_TYPE
										FROM     
                                        	EZGI_DESIGN_MAIN_ROW AS EDMR WITH (NOLOCK) INNER JOIN
                  							EZGI_DESIGN_PIECE_ROWS AS EDPR WITH (NOLOCK) ON EDMR.DESIGN_MAIN_ROW_ID = EDPR.DESIGN_MAIN_ROW_ID
										WHERE  
                                        	EDPR.PIECE_ROW_ID IN (#satir_list_piece#)
                                    </cfquery>
                                </cfif>
                                <cfquery name="get_detail" dbtype="query">
                                	<cfif ListLen(satir_list_package)>
                                    	SELECT 
                                        	1 AS TYPE,
                                        	DESIGN_MAIN_ROW_ID, 
                                          	DESIGN_MAIN_NAME, 
                                           	PACKAGE_ROW_ID AS DETAIL_ID, 
                                          	PACKAGE_NAME AS DETAIL_NAME
										FROM
                                        	get_packages
                                      	<cfif ListLen(satir_list_piece)>
                                        	UNION ALL
                                        </cfif>
                                    </cfif>
                                    <cfif ListLen(satir_list_piece)>
                                    	SELECT
                                        	2 AS TYPE, 
                                        	DESIGN_MAIN_ROW_ID, 
                                         	DESIGN_MAIN_NAME, 
                                         	PIECE_ROW_ID AS DETAIL_ID,
                                          	PIECE_NAME AS DETAIL_NAME
										FROM
                                        	get_pieces
                                    </cfif>
                                </cfquery>
                                <cfset satir_basi = 0>
                                <cfset satir_sayi = get_detail.RECORDCOUNT>
                                <tr> 
                                	<td rowspan="#satir_sayi#" style="text-align:right">#currentrow#</td>
                                    <td rowspan="#satir_sayi#" style="text-align:left">#DESIGN_NAME#</td>
                                    <td rowspan="#satir_sayi#" style="text-align:left">#COLOR_NAME#</td>
                                    <cfloop query="get_detail">
                                    	<cfif satir_basi eq 1> 
                                            <tr>
                                        <cfelse>
                                        	<cfset satir_basi = 1>
                                        </cfif>
                                    	<td  style="text-align:left">#DESIGN_MAIN_NAME#</td>
                                        <cfif TYPE eq 1>
                                        	<td style="text-align:left">#DETAIL_NAME#</td>
                                            <td></td>
                                            <td style="text-align:right"><cfif isdefined('PACKAGE_#DETAIL_ID#')>#AmountFormat(Evaluate('PACKAGE_#DETAIL_ID#'))#</cfif></td>
                                      	<cfelse>
                                        	<td></td>
                                        	<td style="text-align:left">#DETAIL_NAME#</td>
                                            <td style="text-align:right"><cfif isdefined('PIECE_#DETAIL_ID#')>#AmountFormat(Evaluate('PIECE_#DETAIL_ID#'))#</cfif></td>
                                        </cfif>
                                        <cfif attributes.type eq 1>    
                                            <td style="text-align:center">
                                             	<i class="fa fa-thumbs-up" title="<cf_get_lang dictionary_id='44519.İşlem Tamamlandı'>" alt="<cf_get_lang dictionary_id='44519.İşlem Tamamlandı'>"></i>
                                            </td>
                                       	</cfif>
                               			</tr>
                               		</cfloop>
                          	</cfoutput>
                      	</cfif>
                   	</tbody>
                </cf_grid_list>
          	</cf_box>
           	<div class="form-group">
            	<cf_box>
             		<button name="kapat" onClick="window.close();" style="width:100px; height:25px">Kapat</button>
                </cf_box>
        	</div> 
    	</div>
    </cfif>
<cfelse>
	<script type="text/javascript">
		alert("Değiştirmek İstediğiniz Ürün Seçtiğiniz Tasarımlarda Bulunamamıştır.!");
		window.close();
	</script>
 	<cfabort>
</cfif>
