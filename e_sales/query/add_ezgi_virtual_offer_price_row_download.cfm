
<cfset upload_folder = "#upload_folder#temp#dir_seperator#">
<cftry>
        <cffile action = "upload" 
                fileField = "uploaded_file" 
                destination = "#upload_folder#"
                nameConflict = "MakeUnique"  
                mode="777">
      	<cfif cffile.serverfileext neq 'xlsx'>
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
   
<cftry>
  	<cfspreadsheet action="read" src="#upload_folder##file_name#" query="satirlar" sheetname ="FIYAT" headerrow ="1" rows="2-50000">	
 	<cfcatch>
    	<script type="text/javascript">
        	alert("<cfoutput>#getLang('ehesap',1112)#</cfoutput>.");
         	history.back();
      	</script>
     	<cfabort>
  	</cfcatch>
</cftry>
<!---<cfdump var="#attributes#"> 
<cfdump var="#satirlar#"><cfabort> ---> 
<cfif satirlar.recordcount>
	<cfquery name="get_money" datasource="#dsn#">
        SELECT MONEY FROM SETUP_MONEY WHERE PERIOD_ID = #session.ep.period_id# AND MONEY_STATUS = 1
    </cfquery>
	<cfset money_list = ValueList(get_money.MONEY)>
    <cfoutput query="satirlar">
		<cfif len(PRICE_TYPE)>
        	<cfif PRICE_TYPE eq 0>
            <cfelseif PRICE_TYPE eq 1>
            	<cfif len(STOCK_ID)>
                	<cfquery name="GET_STOCK_INFO" datasource="#DSN3#">
                    	SELECT STOCK_ID,PRODUCT_NAME FROM STOCKS WHERE STOCK_ID=#STOCK_ID#
                    </cfquery>
                    <cfif not GET_STOCK_INFO.recordcount>
                    	<script type="text/javascript">
							alert("#currentrow#. Satırdaki STOCK_ID alanındaki Bilgi Dosyadaki STOCK_ID lerle eşleşmiyor.");
							history.back();
						</script>
						<cfabort> 
                    </cfif>
                <cfelseif len(CODE)>
                	<cfquery name="GET_STOCK_INFO" datasource="#DSN3#">
                    	SELECT STOCK_ID,PRODUCT_CODE FROM STOCKS WHERE PRODUCT_CODE='#CODE#'
                    </cfquery>
                    <cfif not GET_STOCK_INFO.recordcount>
                    	<script type="text/javascript">
							alert("#currentrow#. Satırdaki CODE alanındaki Bilgi Dosyadaki PRODUCT_CODE lerle eşleşmiyor.");
							history.back();
						</script>
						<cfabort> 
                    </cfif>
                <cfelse>
                	<script type="text/javascript">
						alert("#currentrow#. Satırdaki STOCK_ID alanında Bilgi Yok.");
						history.back();
					</script>
					<cfabort>
                </cfif>
            <cfelseif PRICE_TYPE eq 2>
            	<cfif len(PIECE_ROW_ID)>
                	<cfquery name="GET_STOCK_INFO" datasource="#DSN3#">
                    	SELECT PIECE_ROW_ID,PIECE_NAME FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) WHERE PIECE_ROW_ID=#PIECE_ROW_ID#
                    </cfquery>
                    <cfif not GET_STOCK_INFO.recordcount>
                    	<script type="text/javascript">
							alert("#currentrow#. Satırdaki PIECE_ROW_ID alanındaki Bilgi Dosyadaki PRICE_ROW_ID lerle eşleşmiyor.");
							history.back();
						</script>
						<cfabort> 
                    </cfif>
                <cfelse>
                	<script type="text/javascript">
						alert("#currentrow#. Satırdaki PIECE_ROW_ID alanında Bilgi Yok.");
						history.back();
					</script>
					<cfabort>
                </cfif>
            <cfelse>
            	<script type="text/javascript">
					alert("#currentrow#. Satırdaki PRICE_TYPE alanındaKİ Bilgi (0,1,2) olmalıdır");
					history.back();
				</script>
				<cfabort>
            </cfif>
        <cfelse>
        	<script type="text/javascript">
				alert("#currentrow#. Satırdaki PRICE_TYPE alanında Bilgi Yok.");
				history.back();
			</script>
 			<cfabort>    
        </cfif>
        <cfif not len(CODE)>
        	<script type="text/javascript">
				alert("#currentrow#. Satırdaki CODE alanında Bilgi Yok.");
				history.back();
			</script>
 			<cfabort> 
        </cfif>
        <cfif not len(PRODUCT_NAME)>
        	<script type="text/javascript">
				alert("#currentrow#. Satırdaki PRODUCT_NAME alanında Bilgi Yok.");
				history.back();
			</script>
 			<cfabort> 
        </cfif>
        <cfif not isnumeric(PRICE1)>
        	<script type="text/javascript">
				alert("#currentrow#. Satırdaki PRICE1 alanında Bilgi Numerik Değil veya Boş.");
				history.back();
			</script>
 			<cfabort> 
        </cfif>
        <cfif not isnumeric(PRICE2)>
        	<script type="text/javascript">
				alert("#currentrow#. Satırdaki PRICE2 alanında Bilgi Numerik Değil veya Boş.");
				history.back();
			</script>
 			<cfabort> 
        </cfif>
        <cfif not isnumeric(PRICE3)>
        	<script type="text/javascript">
				alert("#currentrow#. Satırdaki PRICE3 alanında Bilgi Numerik Değil veya Boş.");
				history.back();
			</script>
 			<cfabort> 
        </cfif>
        <cfif not len(MONEY1) or not ListFind(money_list,MONEY1)>
        	<script type="text/javascript">
				alert("#currentrow#. Satırdaki MONEY1 alanında Bilgi Boş veya Döviz Bilgisi Değil.");
				history.back();
			</script>
 			<cfabort> 
        </cfif>
        <cfif not len(MONEY2) or not ListFind(money_list,MONEY2)>
        	<script type="text/javascript">
				alert("#currentrow#. Satırdaki MONEY2 alanında Bilgi Boş veya Döviz Bilgisi Değil.");
				history.back();
			</script>
 			<cfabort> 
        </cfif>
        <cfif not len(MONEY3) or not ListFind(money_list,MONEY3)>
        	<script type="text/javascript">
				alert("#currentrow#. Satırdaki MONEY3 alanında Bilgi Boş veya Döviz Bilgisi Değil.");
				history.back();
			</script>
 			<cfabort> 
        </cfif>
        <cfif not len(MONTAGE_TYPE) or not ListFind('0,1,2',MONTAGE_TYPE)>
        	<script type="text/javascript">
				alert("#currentrow#. Satırdaki MONTAGE_TYPE alanında Bilgi Boş veya (0,1,2,3) Değil.");
				history.back();
			</script>
 			<cfabort> 
        </cfif>
        <cfif not len(IS_RATE) or not ListFind('0,1,',IS_RATE)>
        	<script type="text/javascript">
				alert("#currentrow#. Satırdaki IS_RATE alanında Bilgi Boş veya (0,1) Değil.");
				history.back();
			</script>
 			<cfabort> 
        </cfif>
	</cfoutput>
<cfelse>        
	<script type="text/javascript">
     	alert("Dosyanın Satırlarında Bilgi Yok.");
      	history.back();
  	</script>
 	<cfabort>        
</cfif>
<cfquery name="get_name_group" dbtype="query">
	SELECT
    	PRODUCT_NAME
  	FROM
    	satirlar
  	GROUP BY
    	PRODUCT_NAME
  	HAVING
    	COUNT(*) > 1
</cfquery>
<cfif get_name_group.recordcount>
	<script type="text/javascript">
		alert('Tablodaki Ürün Adları Transfer Dosyasında Birden Fazla Kullanılmış Kontrol edip Yeniden Deneyin.');
	</script> 
    <cfdump var="#get_name_group#">
	<cfabort>
</cfif>
<cfquery name="get_code_group" dbtype="query">
	SELECT
    	CODE
  	FROM
    	satirlar
  	GROUP BY
    	CODE
  	HAVING
    	COUNT(*) > 1
</cfquery>
<cfif get_code_group.recordcount>
	<script type="text/javascript">
		alert('Tablodaki Kodlar Transfer Dosyasında Birden Fazla Kullanılmış Kontrol edip Yeniden Deneyin.');
	</script>
    <cfdump var="#get_code_group#">
	<cfabort>
</cfif>

<cftransaction>
	<cfif attributes.upload_type eq 1>
        <cfloop query="satirlar">
            <cfquery name="get_price_row" datasource="#dsn3#">
                SELECT PRICE_CAT_ROW_ID FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PRODUCT_CODE_2 = '#satirlar.CODE#' AND PRICE_CAT_ID = #attributes.price_cat_id#
            </cfquery>
            <cfif get_price_row.recordcount eq 1>
                <cfquery name="upd_price_row" datasource="#dsn3#">
                    UPDATE 
                        EZGI_VIRTUAL_OFFER_PRICE_ROW 
                    SET
                        PRODUCT_CODE_2 ='#satirlar.CODE#', 
                        PRODUCT_NAME ='#satirlar.PRODUCT_NAME#',
                        STOCK_ID =<cfif len(satirlar.STOCK_ID)>#satirlar.STOCK_ID#<cfelse>NULL</cfif>, 
                        PIECE_ROW_ID =<cfif len(satirlar.PIECE_ROW_ID)>#satirlar.PIECE_ROW_ID#<cfelse>NULL</cfif>,
                        SALES_PRICE =#satirlar.PRICE1#, 
                        SALES_PRICE_MONEY ='#satirlar.MONEY1#', 
                        PURCHASE_PRICE =#satirlar.PRICE2#,
                        PURCHASE_PRICE_MONEY = '#satirlar.MONEY2#',
                        COST_PRICE = #satirlar.PRICE3#, 
                        COST_PRICE_MONEY = '#satirlar.MONEY3#',
                        MONTAGE_TYPE = #satirlar.MONTAGE_TYPE#,
                        PRICE_TYPE = #satirlar.PRICE_TYPE#,
                        IS_RATE = #satirlar.IS_RATE#,
                        UPDATE_DATE = #now()#
                    WHERE 
                        PRICE_CAT_ROW_ID = #get_price_row.PRICE_CAT_ROW_ID#
                </cfquery>
          	<cfelseif get_price_row.recordcount gt 1>
            	<script type="text/javascript">
					alert('Tablodaki Kodlar Fiyat Listesinde Birden Fazla Kullanılmış Düzenleyip Yeniden Deneyin.');
				</script>
				<cfdump var="#get_price_row#">
				<cfabort>
            <cfelse>
            	<cfif PRICE_TYPE eq 1>
					<cfif len(STOCK_ID) and not len(CODE)>
                        <cfquery name="GET_STOCK_INFO" datasource="#DSN3#">
                            SELECT STOCK_ID,PRODUCT_CODE FROM STOCKS WHERE STOCK_ID=#STOCK_ID#
                        </cfquery>
                        <cfset satir_code = GET_STOCK_INFO.PRODUCT_CODE>
                        <cfset satir_stock_id = satirlar.STOCK_ID>
                    <cfelseif len(CODE) and not len(STOCK_ID)>
                        <cfquery name="GET_STOCK_INFO" datasource="#DSN3#">
                            SELECT STOCK_ID,PRODUCT_CODE FROM STOCKS WHERE PRODUCT_CODE='#CODE#'
                        </cfquery>
                        <cfset satir_stock_id = GET_STOCK_INFO.STOCK_ID>
                        <cfset satir_code = satirlar.CODE >
                    </cfif>
                <cfelseif PRICE_TYPE eq 2>
                	<cfif len(PIECE_ROW_ID)>
                        <cfquery name="GET_STOCK_INFO" datasource="#DSN3#">
                        	SELECT 
                            	EPR.PIECE_ROW_ID, 
                                S.PRODUCT_CODE 
							FROM     
                            	EZGI_DESIGN_PIECE_ROWS AS EPR INNER JOIN
                  				STOCKS AS S ON EPR.PIECE_RELATED_ID = S.STOCK_ID
							WHERE  
                            	EPR.PIECE_ROW_ID = #PIECE_ROW_ID#
                        </cfquery>
                        <cfif GET_STOCK_INFO.recordcount>
                        	<cfset satir_code = GET_STOCK_INFO.PRODUCT_CODE>
                            <cfset satir_stock_id = ''>
                      	<cfelse>
                            <script type="text/javascript">
								alert('Mobilya Tasarımdaki Parça Henüz Ürün Kodu Oluşturulmamış.');
							</script>
							<cfdump var="#GET_STOCK_INFO#">
							<cfabort>
                        </cfif>
                    </cfif>
                	<cfset satir_code = satirlar.CODE >
                    <cfset satir_stock_id = ''>
                <cfelse>
                	Sanal Fiyat İmportu Henüz Kodlanmadı
                	<cfabort>
                </cfif>
            	<cfquery name="add_price_row" datasource="#dsn3#">
                    INSERT INTO 
                        EZGI_VIRTUAL_OFFER_PRICE_ROW
                        (
                            PRICE_CAT_ID, 
                            PRODUCT_CODE_2, 
                            PRODUCT_NAME, 
                            STOCK_ID, 
                            PIECE_ROW_ID, 
                            SALES_PRICE, 
                            SALES_PRICE_MONEY, 
                            PURCHASE_PRICE, 
                            PURCHASE_PRICE_MONEY, 
                            COST_PRICE, 
                            COST_PRICE_MONEY,
                            MONTAGE_TYPE,
                            PRICE_TYPE,
                            IS_RATE,
                            UPDATE_DATE
                        )
                    VALUES     
                        (
                            #attributes.price_cat_id#,
                            '#satir_code#',
                            '#satirlar.PRODUCT_NAME#',
                            <cfif len(satir_stock_id)>#satir_stock_id#<cfelse>NULL</cfif>, 
                            <cfif len(satirlar.PIECE_ROW_ID)>#satirlar.PIECE_ROW_ID#<cfelse>NULL</cfif>,
                          	#satirlar.PRICE1#, 
                        	'#satirlar.MONEY1#', 
                        	#satirlar.PRICE2#,
                        	'#satirlar.MONEY2#',
                       		#satirlar.PRICE3#, 
                        	'#satirlar.MONEY3#',
                        	#satirlar.MONTAGE_TYPE#,
                        	#satirlar.PRICE_TYPE#,
                       		#satirlar.IS_RATE#,
                            #now()#
                        )
                </cfquery>
            </cfif>
        </cfloop>	
    <cfelse>
    	<cfif satirlar.recordcount>
            <cfquery name="del_price_row" datasource="#dsn3#">
                DELETE EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PRICE_CAT_ID = #attributes.price_cat_id#
            </cfquery>
        	<cfloop query="satirlar">
            	<cfif PRICE_TYPE eq 1>
					<cfif len(STOCK_ID) and not len(CODE)>
                        <cfquery name="GET_STOCK_INFO" datasource="#DSN3#">
                            SELECT STOCK_ID,PRODUCT_CODE FROM STOCKS WHERE STOCK_ID=#STOCK_ID#
                        </cfquery>
                        <cfset satir_code = GET_STOCK_INFO.PRODUCT_CODE>
                        <cfset satir_stock_id = satirlar.STOCK_ID>
                    <cfelseif len(CODE) and not len(STOCK_ID)>
                        <cfquery name="GET_STOCK_INFO" datasource="#DSN3#">
                            SELECT STOCK_ID,PRODUCT_CODE FROM STOCKS WHERE PRODUCT_CODE='#CODE#'
                        </cfquery>
                        <cfset satir_stock_id = GET_STOCK_INFO.STOCK_ID>
                        <cfset satir_code = satirlar.CODE >
                    </cfif>
                <cfelseif PRICE_TYPE eq 2>
                	<cfif len(PIECE_ROW_ID)>
                        <cfquery name="GET_STOCK_INFO" datasource="#DSN3#">
                        	SELECT 
                            	EPR.PIECE_ROW_ID, 
                                S.PRODUCT_CODE 
							FROM     
                            	EZGI_DESIGN_PIECE_ROWS AS EPR INNER JOIN
                  				STOCKS AS S ON EPR.PIECE_RELATED_ID = S.STOCK_ID
							WHERE  
                            	EPR.PIECE_ROW_ID = #PIECE_ROW_ID#
                        </cfquery>
                        <cfif GET_STOCK_INFO.recordcount>
                        	<cfset satir_code = GET_STOCK_INFO.PRODUCT_CODE>
                            <cfset satir_stock_id = ''>
                      	<cfelse>
                            <script type="text/javascript">
								alert('Mobilya Tasarımdaki Parça Henüz Ürün Kodu Oluşturulmamış.');
							</script>
							<cfdump var="#GET_STOCK_INFO#">
							<cfabort>
                        </cfif>
                    </cfif>
                	<cfset satir_code = satirlar.CODE >
                    <cfset satir_stock_id = ''>
                <cfelse>
                	Sanal Fiyat İmportu Henüz Kodlanmadı
                	<cfabort>
                </cfif>
        		<cfquery name="add_price_row" datasource="#dsn3#">
                    INSERT INTO 
                        EZGI_VIRTUAL_OFFER_PRICE_ROW
                        (
                            PRICE_CAT_ID, 
                            PRODUCT_CODE_2, 
                            PRODUCT_NAME, 
                            STOCK_ID, 
                            PIECE_ROW_ID, 
                            SALES_PRICE, 
                            SALES_PRICE_MONEY, 
                            PURCHASE_PRICE, 
                            PURCHASE_PRICE_MONEY, 
                            COST_PRICE, 
                            COST_PRICE_MONEY,
                            MONTAGE_TYPE,
                            PRICE_TYPE,
                            IS_RATE,
                            UPDATE_DATE
                        )
                    VALUES     
                        (
                            #attributes.price_cat_id#,
                            '#satir_code#',
                            '#satirlar.PRODUCT_NAME#',
                            <cfif len(satir_stock_id)>#satir_stock_id#<cfelse>NULL</cfif>,
                            <cfif len(satirlar.PIECE_ROW_ID)>#satirlar.PIECE_ROW_ID#<cfelse>NULL</cfif>,
                          	#satirlar.PRICE1#, 
                        	'#satirlar.MONEY1#', 
                        	#satirlar.PRICE2#,
                        	'#satirlar.MONEY2#',
                       		#satirlar.PRICE3#, 
                        	'#satirlar.MONEY3#',
                        	#satirlar.MONTAGE_TYPE#,
                        	#satirlar.PRICE_TYPE#,
                       		#satirlar.IS_RATE#,
                            #now()#
                        )
   				</cfquery>
          	</cfloop>
      	<cfelse>
        	<script type="text/javascript">
				alert('Transfer Dosyasının İçi Boş.');
				history.back();
			</script>
			<cfabort>
        </cfif>
    </cfif>
</cftransaction>
<script type="text/javascript">
	alert('Fiyat Listeniz Başarıyla Transfer Edilmiştir.');
  	wrk_opener_reload();
 	window.close();
</script>