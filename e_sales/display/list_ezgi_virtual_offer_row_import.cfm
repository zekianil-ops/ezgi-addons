<!---
    File: list_ezgi_virtual_offer_row_import.cfm
    Folder: Add_Ons\ezgi\e_sales\display
    Author: Ezgi Yazılım
    Date: 16/10/2023
    Description:
--->
<cfparam name="attributes.keyword" default=''>
<cfparam name="attributes.is_related" default=''>
<cfparam name="attributes.is_excel" default="">
<cfparam name="attributes.price_catid" default=''>
<cfif isdefined("attributes.show_image") and attributes.show_image eq 1 and isdefined("attributes.image_row_id") and len(trim(attributes.image_row_id))>
	<cfquery name="get_row_image_file" datasource="#DSN3#">
		SELECT
			IMAGE_PATH
		FROM
			EZGI_VIRTUAL_OFFER_ROW_PRE_IMPORT
		WHERE
			VIRTUAL_OFFER_ROW_ID = <cfqueryparam value="#attributes.image_row_id#" cfsqltype="cf_sql_numeric">
	</cfquery>
	<cfif get_row_image_file.recordcount and len(trim(get_row_image_file.IMAGE_PATH)) and fileExists(trim(get_row_image_file.IMAGE_PATH))>
		<cfset imageMimeType = "image/jpeg">
		<cfset imageFilePath = trim(get_row_image_file.IMAGE_PATH)>
		<cfif listFindNoCase("png", listLast(imageFilePath, "."))>
			<cfset imageMimeType = "image/png">
		<cfelseif listFindNoCase("gif", listLast(imageFilePath, "."))>
			<cfset imageMimeType = "image/gif">
		<cfelseif listFindNoCase("bmp", listLast(imageFilePath, "."))>
			<cfset imageMimeType = "image/bmp">
		<cfelseif listFindNoCase("webp", listLast(imageFilePath, "."))>
			<cfset imageMimeType = "image/webp">
		</cfif>
		<cfsetting showdebugoutput="false">
		<cfcontent type="#imageMimeType#" file="#imageFilePath#" deletefile="no" reset="true">
		<cfabort>
	</cfif>
	<cfheader statuscode="404" statustext="Not Found">
	<cfabort>
</cfif>
<cfinclude template="../include/virtual_offer_import_helpers.cfm">
<cfquery name="get_money" datasource="#dsn#">
	SELECT MONEY_ID,MONEY, RATE2, RATE1 FROM SETUP_MONEY WHERE PERIOD_ID = <cfqueryparam value="#session.ep.period_id#" cfsqltype="cf_sql_numeric">
</cfquery>
<cfquery name="get_virtual_offer_money" datasource="#DSN3#">
	SELECT        
    	MONEY_TYPE, 
        RATE2, 
        RATE1, 
        IS_SELECTED
	FROM            
    	EZGI_VIRTUAL_OFFER_MONEY
	WHERE        

    	ACTION_ID = <cfqueryparam value="#attributes.virtual_offer_id#" cfsqltype="cf_sql_numeric">
</cfquery>
<cfif isdefined('attributes.virtual_offer_id')>
	<cfoutput query="get_virtual_offer_money">	
        <cfset 'RATE1_#MONEY_TYPE#' = RATE1>
        <cfset 'RATE2_#MONEY_TYPE#' = RATE2>
    </cfoutput>
<cfelse>
	<cfoutput query="get_money">
        <cfset 'RATE1_#MONEY#' = RATE1>
        <cfset 'RATE2_#MONEY#' = RATE2>
    </cfoutput>
</cfif>
<cfquery name="get_old_virtual_offer_row" datasource="#DSN3#">
	SELECT 
		TOP (1) PRICE_CAT_ID
	FROM     
		EZGI_VIRTUAL_OFFER_ROW
	WHERE  
		VIRTUAL_OFFER_ID = #attributes.virtual_offer_id# AND PRICE_CAT_ID IS NOT NULL
	ORDER BY 
		VIRTUAL_OFFER_ROW_ID DESC
</cfquery>
<cfset attributes.price_catid = get_old_virtual_offer_row.PRICE_CAT_ID>
<cfif not get_old_virtual_offer_row.recordcount>
	<cfquery name="get_old_virtual_offer" datasource="#DSN3#">
		SELECT 
			VIRTUAL_OFFER_ID,
			COMPANY_ID, 
			PARTNER_ID, 
			CONSUMER_ID
		FROM     
			EZGI_VIRTUAL_OFFER
		WHERE  
			VIRTUAL_OFFER_ID = #attributes.virtual_offer_id#
	</cfquery>
    <cfif len(get_old_virtual_offer.COMPANY_ID)>
      	<cfquery name="get_c_cat_id" datasource="#dsn#">
            SELECT COMPANYCAT_ID FROM COMPANY WHERE COMPANY_ID = #get_old_virtual_offer.COMPANY_ID#
        </cfquery>
        <cfquery name="GET_PRICE_CAT" datasource="#DSN3#">
          	SELECT 
              	PRICE_CAT_ID, 
             	PRICE_CAT,
            	COMPANY_CATS,
                CONSUMER_CATS
            FROM     
                EZGI_VIRTUAL_OFFER_PRICE_LIST
            WHERE
                COMPANY_CATS LIKE '%,#get_c_cat_id.COMPANYCAT_ID#,%'
            ORDER BY
                PRICE_CAT_CODE
        </cfquery>
        <cfif not GET_PRICE_CAT.RECORDCOUNT>
            <script type="text/javascript">
                alert("Kurumsal Üyeyi Bir Fiyat Listesine Dahil Ediniz!");
                window.close();
            </script>
            <cfabort>
        </cfif>
	<cfelseif len(get_old_virtual_offer.CONSUMER_ID)>
        <cfquery name="get_c_cat_id" datasource="#dsn#">
            SELECT CONSUMER_CAT_ID FROM CONSUMER WHERE CONSUMER_ID = #get_old_virtual_offer.CONSUMER_ID#
        </cfquery>
        <cfquery name="GET_PRICE_CAT" datasource="#DSN3#">
            SELECT 
                PRICE_CAT_ID, 
                PRICE_CAT
            FROM     
                EZGI_VIRTUAL_OFFER_PRICE_LIST
            WHERE        
                STATUS = 1 AND
                CONSUMER_CATS LIKE '%,#get_c_cat_id.CONSUMER_CAT_ID#,%'
            ORDER BY
       			PRICE_CAT_CODE
        </cfquery> 
		<cfif not GET_PRICE_CAT.RECORDCOUNT>
            <script type="text/javascript">
                alert("Bireysel Üyeyi Bir Fiyat Listesine Dahil Ediniz!");
                window.close();
            </script>
            <cfabort>
        </cfif>        
    <cfelse>
        <cfquery name="GET_PRICE_CAT" datasource="#DSN3#">
            SELECT TOP (1)  
                PRICE_CAT_ID, 
                PRICE_CAT
            FROM     
                EZGI_VIRTUAL_OFFER_PRICE_LIST
            WHERE        
                STATUS = 1
           	ORDER BY
        		PRICE_CAT_CODE
        </cfquery>
    </cfif>
    <cfif not GET_PRICE_CAT.RECORDCOUNT>
        <script type="text/javascript">
            alert("Kurumsal Üyeyi Bir Fiyat Listesine Dahil Ediniz!");
            window.close();
        </script>
        <cfabort>
    </cfif>
<cfelse>
	<cfquery name="GET_PRICE_CAT" datasource="#DSN3#">
      	SELECT TOP (1)  
         	PRICE_CAT_ID, 
         	PRICE_CAT
       	FROM     
         	EZGI_VIRTUAL_OFFER_PRICE_LIST
       	WHERE        
			PRICE_CAT_ID = #attributes.price_catid#
      	ORDER BY
        	PRICE_CAT_CODE
	</cfquery>
</cfif>
<cfquery name="get_detail" datasource="#DSN3#">
	SELECT 
    	PRI.*,
        S.STOCK_ID AS MATCHED_STOCK_ID, 
        S.PRODUCT_ID, 
        S.PRODUCT_NAME AS MATCHED_PRODUCT_NAME, 
        S.PRODUCT_CODE AS MATCHED_PRODUCT_CODE,
		ISNULL(EIR.VIRTUAL_OFFER_ROW_ID,0) AS TRANSFER_ROW_ID
	FROM     
    	EZGI_VIRTUAL_OFFER_ROW_PRE_IMPORT PRI LEFT JOIN 
		STOCKS S ON S.STOCK_ID = PRI.STOCK_ID LEFT JOIN
		EZGI_VIRTUAL_OFFER_ROW EIR ON EIR.VIRTUAL_OFFER_IMPORT_ROW_ID = PRI.VIRTUAL_OFFER_ROW_ID
	WHERE  
    	PRI.VIRTUAL_OFFER_ID = <cfqueryparam value="#attributes.virtual_offer_id#" cfsqltype="cf_sql_numeric">
		<cfif len(attributes.keyword) gt 0>
			AND (
				PRI.PRODUCT_NAME LIKE <cfqueryparam value="%#attributes.keyword#%" cfsqltype="cf_sql_varchar">
				OR PRI.PRODUCT_NAME2 LIKE <cfqueryparam value="%#attributes.keyword#%" cfsqltype="cf_sql_varchar">
			)
		</cfif>
		<cfif attributes.is_related neq ''>
			<cfif attributes.is_related eq 1>
				AND PRI.STOCK_ID IS NOT NULL
			<cfelseif attributes.is_related eq 2>
				AND PRI.STOCK_ID IS NULL
			</cfif>
		</cfif>
</cfquery>
<cfquery name="productsQuery" datasource="#DSN3#">
	SELECT
		STOCK_ID,
		PRODUCT_ID,
		PRODUCT_NAME,
		PRODUCT_CODE
	FROM
		STOCKS
	WHERE
		PRODUCT_NAME IS NOT NULL AND 
		IS_SALES = 1 AND
		PRODUCT_STATUS = 1
</cfquery>
<cfset savedConfigSelectionMap = {}>
<cfif get_detail.recordcount>
	<cfquery name="get_saved_config_predict_detail" datasource="#DSN3#">
		SELECT
			P.VIRTUAL_OFFER_IMPORT_ROW_ID,
			D.QUESTION_ID,
			D.ALTERNATIVE_STOCK_ID,
			D.ALTERNATIVE_VALUE,
			D.MATCH_STATUS,
			D.MATCH_SCORE
		FROM
			demo_ezgiyazilim_1.EZGI_VIRTUAL_OFFER_ROW_CONFIG_PREDICT P
			INNER JOIN demo_ezgiyazilim_1.EZGI_VIRTUAL_OFFER_ROW_CONFIG_PREDICT_DETAIL D ON P.PREDICT_ID = D.PREDICT_ID
		WHERE
			P.VIRTUAL_OFFER_IMPORT_ROW_ID IN (
				<cfqueryparam value="#ValueList(get_detail.VIRTUAL_OFFER_ROW_ID)#" cfsqltype="cf_sql_numeric" list="true">
			)
			AND D.IS_SELECTED = 1
	</cfquery>
	<cfloop query="get_saved_config_predict_detail">
		<cfset savedImportRowId = trim(get_saved_config_predict_detail.VIRTUAL_OFFER_IMPORT_ROW_ID & "")>
		<cfset savedQuestionId = trim(get_saved_config_predict_detail.QUESTION_ID & "")>
		<cfif !structKeyExists(savedConfigSelectionMap, savedImportRowId)>
			<cfset savedConfigSelectionMap[savedImportRowId] = {}>
		</cfif>
		<cfset savedConfigSelectionMap[savedImportRowId][savedQuestionId] = {
			option_id = trim(get_saved_config_predict_detail.ALTERNATIVE_STOCK_ID & ""),
			option_name = trim(get_saved_config_predict_detail.ALTERNATIVE_VALUE & ""),
			match_status = trim(get_saved_config_predict_detail.MATCH_STATUS & ""),
			match_score = val(get_saved_config_predict_detail.MATCH_SCORE)
		}>
	</cfloop>
</cfif>
<cfparam name="attributes.maxrows" default="#SESSION.EP.MAXROWS#">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.totalrecords" default="#get_detail.recordcount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<br/>
<cfsavecontent variable="message"><cf_get_lang dictionary_id='45836.Aktarım'></cfsavecontent>
<cfsavecontent variable="right_images_">
	<a href="<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_virtual_offer_row_file_import&virtual_offer_id=#attributes.virtual_offer_id#</cfoutput>">
    	<img src="images/save.gif" border="0" />
 	</a>
</cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
   <div class="col col-12">
	<cf_box title="#message#" right_images="#right_images_#">
    	<cfform name="import_list" id="import_list" action="#request.self#?fuseaction=prod.popup_list_ezgi_virtual_offer_row_import" method="post">
        	<cfinput type="hidden" name="virtual_offer_id" id="virtual_offer_id" value="#attributes.virtual_offer_id#">
                <cfinput type="hidden" name="page" id="page" value="#attributes.page#">
                <cfinput type="hidden" name="is_filter" id="is_filter" value="1">
                <cfinput type="hidden" name="delete_offer_row_id_list" id="delete_offer_row_id_list" value="">
            <cfinput type="hidden" name="suggestion_offer_id_list" id="suggestion_offer_id_list" value="#ValueList(get_detail.VIRTUAL_OFFER_ROW_ID)#">
            <cf_box_search>
            	<div class="form-group" id="item-keyword">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
					<cfinput type="text" name="keyword" placeholder="#message#" id="keyword"  value="#attributes.keyword#" maxlength="200">
				</div>
                <div class="form-group" id="item-is_related">
					<select name="is_related" id="is_related">
                    	<option value="" <cfif attributes.is_related eq ''>selected</cfif>>Tümü</option>
                    	<option value="1" <cfif attributes.is_related eq 1>selected</cfif>>Ürün Bağlantısı Yapılmışlar</option>
                        <option value="2" <cfif attributes.is_related eq 2>selected</cfif>>Ürün Bağlantısı Yapılmamışlar</option>
                    </select>
				</div>
				<div class="form-group" id="item-cat">
                    <select name="price_catid" id="price_catid" style="width:220px; height:20px">
                        <cfoutput query="GET_PRICE_CAT">
                            <option value="#GET_PRICE_CAT.PRICE_CAT_ID#" <cfif GET_PRICE_CAT.PRICE_CAT_ID eq attributes.price_catid> selected</cfif>>#GET_PRICE_CAT.PRICE_CAT#</option>
                        </cfoutput>
                    </select>
             	</div>
                <div class="form-group">
                	<input type="checkbox" name="is_excel" id="is_excel" value="1" <cfif attributes.is_excel eq 1>checked</cfif>>
                	<cf_get_lang_main no='446.Excel Getir'>
                </div>
                <div class="form-group small">
					<cfinput type="text" name="maxrows" id="maxrows" value="#attributes.maxrows#" validate="integer" range="1," required="yes" message="Sayi_Hatasi_Mesaj" onkeyup="return(formatcurrency(this,event,0));">
				</div>
				<div class="form-group">   
					<cf_wrk_search_button search_function='input_control()' button_type="1">
				</div>
          	</cf_box_search>
            <cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
				<cfset filename = "#createuuid()#">
                <cfheader name="Expires" value="#Now()#">
                <cfcontent type="application/vnd.msexcel;charset=utf-8">
                <cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
                <cfset attributes.startrow=1>
                <cfset attributes.maxrows = get_detail.recordcount>
            </cfif>
			<cf_grid_list>
            	<thead>
					<tr>
                    	<th width="30">S.No</th>
                        <th width="80">Resim</th>
                        <th width="150">Müşteri Ürün Adı</th>
                        <th>Sistem Ürün Adı Bağlantısı</th>
                        <th width="180">Sistem Ürün Önerisi</th>
                        <th width="45">Onay</th>
                        <th width="40">Miktar</th>
                        <th width="25"><cf_get_lang dictionary_id="57636.Birim"></th>
                        <th width="60">Fiyat</th>
						<th width="40">Döviz</th>
                        <th width="100">Açıklama</th>
						<th width="200">Konfigüsayon Tahmini</th>
                        <th width="100">DIM</th>
                        <th width="50">Area</th>
                        <th width="25">
                        	<input type="checkbox" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="grupla(-1);">
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <cfif get_detail.recordcount>
						<cfoutput query="get_detail" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#"> 
                        	<cfset suggestionMatch = {
								match_status = "none",
								match_score = 0,
								stock_id = "",
								product_id = "",
								product_name = "",
								product_code = "",
								note = "",
								display_status = "none",
								display_text = "Öneri bulunamadı"
							}>
							<cfset configPrediction = {
								summary_html = "",
								match_status = "none",
								needs_manual_selection = false,
								total_questions = 0,
								matched_questions = 0,
								details = []
							}>
                            <cfset imagePath_ = "">
                            <cfset imageUrl_ = "">
                        	<cfif len(get_detail.stock_id)>
                                <cfset stock_id_ = get_detail.STOCK_ID>
                                <cfset product_id_ = get_detail.PRODUCT_ID>
                                <cfset product_name_ = get_detail.MATCHED_PRODUCT_NAME>
								<cfset configPrediction = getConfigPrediction(val(stock_id_), get_detail.PRODUCT_NAME2, DSN3, DSN)>
								<cfif structKeyExists(savedConfigSelectionMap, trim(get_detail.VIRTUAL_OFFER_ROW_ID & ""))>
									<cfset savedRowPredictionMap = savedConfigSelectionMap[trim(get_detail.VIRTUAL_OFFER_ROW_ID & "")]>
									<cfset predictionSummaryLines = []>
									<cfset configPrediction.matched_questions = 0>
									<cfset configPrediction.needs_manual_selection = false>
									<cfloop from="1" to="#arrayLen(configPrediction.details)#" index="predictionIndex">
										<cfset predictionDetail = configPrediction.details[predictionIndex]>
										<cfset predictionQuestionId = trim(predictionDetail.question_id & "")>
										<cfif structKeyExists(savedRowPredictionMap, predictionQuestionId)>
											<cfset savedPredictionDetail = savedRowPredictionMap[predictionQuestionId]>
											<cfset predictionDetail.option_id = savedPredictionDetail.option_id>
											<cfset predictionDetail.option_name = savedPredictionDetail.option_name>
											<cfset predictionDetail.match_status = len(savedPredictionDetail.match_status) ? savedPredictionDetail.match_status : "manual">
											<cfset predictionDetail.match_score = savedPredictionDetail.match_score>
											<cfif predictionDetail.match_status eq "similar">
												<cfset predictionDetail.display_text = HTMLEditFormat(predictionDetail.question_name) & " - " & HTMLEditFormat(savedPredictionDetail.option_name) & " (Benzer)">
											<cfelseif predictionDetail.match_status eq "exact">
												<cfset predictionDetail.display_text = HTMLEditFormat(predictionDetail.question_name) & " - " & HTMLEditFormat(savedPredictionDetail.option_name)>
											<cfelse>
												<cfset predictionDetail.display_text = HTMLEditFormat(predictionDetail.question_name) & " - " & HTMLEditFormat(savedPredictionDetail.option_name) & " (Kaydedilen)">
											</cfif>
										</cfif>
										<cfset arrayAppend(predictionSummaryLines, predictionDetail.display_text)>
										<cfif predictionDetail.match_status neq "none">
											<cfset configPrediction.matched_questions++>
										<cfelse>
											<cfset configPrediction.needs_manual_selection = true>
										</cfif>
										<cfset configPrediction.details[predictionIndex] = predictionDetail>
									</cfloop>
									<cfset configPrediction.summary_html = arrayToList(predictionSummaryLines, "<br>")>
									<cfif configPrediction.matched_questions eq 0>
										<cfset configPrediction.match_status = "none">
									<cfelseif configPrediction.needs_manual_selection>
										<cfset configPrediction.match_status = "mixed">
									<cfelse>
										<cfset configPrediction.match_status = "exact">
									</cfif>
								</cfif>
                            <cfelse>
                            	<cfset stock_id_ = ''>
                                <cfset product_id_ = ''>
                                <cfset product_name_ = ''>
                                <cfset suggestionMatch = matchImportProduct(get_detail.PRODUCT_NAME, productsQuery)>
                            </cfif>
                            <cfif len(trim(get_detail.IMAGE_PATH)) and fileExists(trim(get_detail.IMAGE_PATH))>
                                <cfset imagePath_ = trim(get_detail.IMAGE_PATH)>
                                <cfset imageUrl_ = "#request.self#?fuseaction=prod.popup_list_ezgi_virtual_offer_row_import&virtual_offer_id=#attributes.virtual_offer_id#&show_image=1&image_row_id=#get_detail.VIRTUAL_OFFER_ROW_ID#">
                            </cfif>
                            <tr height="80" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                            	<td style="text-align:right">#currentrow#</td>           
                                <td style="text-align:center">
                                	<div id="image_cell#currentrow#" data-product-name="#HTMLEditFormat(get_detail.PRODUCT_NAME)#" style="width:86px; min-height:86px; margin:0 auto; display:flex; align-items:center; justify-content:center;">
                                        <cfif len(imageUrl_)>
                                            <img src="#imageUrl_#" alt="#xmlFormat(get_detail.PRODUCT_NAME)#" style="max-width:60px; max-height:60px; border:1px solid ##ddd; padding:2px; cursor:pointer;" onclick="openImagePreview('#JSStringFormat(imageUrl_)#','#JSStringFormat(get_detail.PRODUCT_NAME)#');">
                                        <cfelseif len(trim(get_detail.IMAGE_NAME))>
                                            <span style="font-size:10px; color:##666;">#get_detail.IMAGE_NAME#</span>
                                        <cfelse>
                                        	<div id="image_drop_zone#currentrow#" class="row-image-drop-zone" data-row-no="#currentrow#" data-offer-row-id="#get_detail.VIRTUAL_OFFER_ROW_ID#" onclick="chooseRowImage(#currentrow#);" style="width:78px; min-height:78px; border:2px dashed ##bbb; padding:6px; cursor:pointer; font-size:10px; color:##666; line-height:1.4; display:flex; align-items:center; justify-content:center; box-sizing:border-box; border-radius:6px; text-align:center; transition:all 0.15s ease;">
                                            	Resmi buraya birak
                                            </div>
                                            <input type="file" id="row_image_input#currentrow#" accept="image/*" style="display:none;" onchange="handleImageSelect(this,#currentrow#,#get_detail.VIRTUAL_OFFER_ROW_ID#);">
                                        </cfif>
                                    </div>
                                </td>
                                <td>#product_name#</td>
                                <td style="text-align:right">
                                	<input type="hidden" name="pid#currentrow#" id="pid#currentrow#" value="#product_id_#">
                                  	<input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#" value="#stock_id_#">
                                    <input type="hidden" name="product_name#currentrow#" id="product_name#currentrow#" value="#HTMLEditFormat(get_detail.PRODUCT_NAME)#">
                                    <input type="hidden" name="stock_code#currentrow#" id="stock_code#currentrow#" value="#HTMLEditFormat(get_detail.STOCK_CODE)#">
                                    <input type="hidden" name="product_code_2#currentrow#" id="product_code_2#currentrow#" value="#HTMLEditFormat(get_detail.PRODUCT_CODE_2)#">
                                    <input type="hidden" name="unit_value#currentrow#" id="unit_value#currentrow#" value="#HTMLEditFormat(get_detail.UNIT)#">
                                    <input type="hidden" name="price_value#currentrow#" id="price_value#currentrow#" value="#get_detail.PRICE#">
                                    <input type="hidden" name="other_money_value#currentrow#" id="other_money_value#currentrow#" value="#HTMLEditFormat(get_detail.OTHER_MONEY)#">
                                    <input type="hidden" name="purchase_price#currentrow#" id="purchase_price#currentrow#" value="#get_detail.PURCHASE_PRICE#">
                                    <input type="hidden" name="purchase_price_money#currentrow#" id="purchase_price_money#currentrow#" value="#HTMLEditFormat(get_detail.PURCHASE_PRICE_MONEY)#">
                                    <input type="hidden" name="cost_price#currentrow#" id="cost_price#currentrow#" value="#get_detail.COST_PRICE#">
                                    <input type="hidden" name="cost_price_money#currentrow#" id="cost_price_money#currentrow#" value="#HTMLEditFormat(get_detail.COST_PRICE_MONEY)#">
                                    <input type="hidden" name="tax_value#currentrow#" id="tax_value#currentrow#" value="#get_detail.TAX#">
                                    <input type="hidden" name="price_cat_value#currentrow#" id="price_cat_value#currentrow#" value="#get_detail.PRICE_CAT_ID#">
                                    <input type="hidden" name="discount_1_value#currentrow#" id="discount_1_value#currentrow#" value="#get_detail.DISCOUNT_1#">
                                    <input type="hidden" name="discount_2_value#currentrow#" id="discount_2_value#currentrow#" value="#get_detail.DISCOUNT_2#">
                                    <input type="hidden" name="discount_3_value#currentrow#" id="discount_3_value#currentrow#" value="#get_detail.DISCOUNT_3#">
                                    <input type="hidden" name="quantity_value#currentrow#" id="quantity_value#currentrow#" value="#get_detail.QUANTITY#">
                                    <input type="hidden" name="existing_match#currentrow#" id="existing_match#currentrow#" value="<cfif len(get_detail.stock_id) gt 0>1<cfelse>0</cfif>">
                                    <input type="hidden" name="transfer_row_id#currentrow#" id="transfer_row_id#currentrow#" value="#get_detail.TRANSFER_ROW_ID#">
                                    <input type="hidden" name="suggestion_status#currentrow#" id="suggestion_status#currentrow#" value="#suggestionMatch.match_status#">
                                    <input type="hidden" name="suggestion_pid#currentrow#" id="suggestion_pid#currentrow#" value="#suggestionMatch.product_id#">
                                    <input type="hidden" name="suggestion_stock_id#currentrow#" id="suggestion_stock_id#currentrow#" value="#suggestionMatch.stock_id#">
                                    <input type="hidden" name="suggestion_product_name#currentrow#" id="suggestion_product_name#currentrow#" value="#suggestionMatch.product_name#">
                                  	<input type="text" name="urun#currentrow#" id="urun#currentrow#" value="#product_name_#" style="width:95%; height:25px; border-style:none">
                                 	<cfif !(isdefined("get_detail.TRANSFER_ROW_ID") and val(get_detail.TRANSFER_ROW_ID) gt 0)>
                                 		<a href="javascript://" onclick="pencere_ac(#currentrow#);"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>
                                        </cfif>
                                </td>
                                <td style="text-align:left">
                                	<div id="suggestion_text#currentrow#" style="font-size:11px; color:##666; line-height:1.5;">
                                    	<cfif len(get_detail.stock_id) gt 0>
                                        	<span style="font-weight:bold;">#get_detail.MATCHED_PRODUCT_NAME#</span><br>
                                            <span style="color:green;">Ürün Bağlantısı Yapılmıştır.</span>
                                        <cfelseif suggestionMatch.match_status neq "none">
                                        	<span style="font-weight:bold;">#suggestionMatch.product_name#</span><br>
                                            #suggestionMatch.display_text# (%#suggestionMatch.match_score#)
                                        <cfelse>
                                        	Öneri bulunamadı
                                        </cfif>
                                        <cfif isdefined("get_detail.TRANSFER_ROW_ID") and val(get_detail.TRANSFER_ROW_ID) gt 0>
                                            <br><span style="color:green;">Sanal Teklife Transfer Edilmiştir.</span>
                                        </cfif>
                                    </div>
                                </td>
                                <td style="text-align:center; font-size:16px;">
                                    <span id="approval_icon#currentrow#">
                                        <cfif len(stock_id_) gt 0>
                                            <span style="color:##2e7d32; font-weight:bold;">&##10003;</span>
                                        <cfelseif suggestionMatch.match_status neq "none">
                                            <a href="javascript://" onclick="applySuggestion(#currentrow#);" style="color:##888; font-weight:bold; text-decoration:none;" title="Önerilen ürünü bağla">!</a>
                                        </cfif>
                                    </span>
                                </td>
                                <td style="text-align:right">#TlFormat(QUANTITY,2)#</td>
                                <td style="text-align:left">#UNIT#</td>
								<td style="text-align:right">#TlFormat(PRICE,2)#</td>	
                                <td style="text-align:left">#OTHER_MONEY#</td>
                                <td style="text-align:left">#PRODUCT_NAME2#</td>
                                <td style="text-align:left; font-size:11px; line-height:1.5;">
									<cfif !len(stock_id_)>
										<span style="color:##888;">Önce ürün tanımlayın</span>
									<cfelseif configPrediction.total_questions eq 0>
										<span style="color:##888;">Konfigürasyon sorusu bulunamadı</span>
									<cfelse>
										<cfloop array="#configPrediction.details#" index="predictionDetail">
											<cfset predictionTextColor = "##2e7d32">
											<cfset predictionBorderColor = "##81c784">
											<cfset predictionBackgroundColor = "##e8f5e9">
											<cfset showPredictionSelect = false>
											<cfset predictionStatusText = predictionDetail.display_text>
											<cfset predictionStatusMargin = "0">
											<cfif predictionDetail.match_status eq "similar">
												<cfset predictionTextColor = "##b26a00">
												<cfset predictionBorderColor = "##ffcc80">
												<cfset predictionBackgroundColor = "##fff3e0">
												<cfset showPredictionSelect = true>
												<cfset predictionStatusMargin = "4">
											<cfelseif predictionDetail.match_status neq "exact">
												<cfset predictionTextColor = "##c62828">
												<cfset predictionBorderColor = "##ef9a9a">
												<cfset predictionBackgroundColor = "##ffebee">
												<cfset showPredictionSelect = true>
												<cfset predictionStatusMargin = "4">
											</cfif>
											<div style="margin-bottom:6px; padding:6px; border:1px solid #predictionBorderColor#; background-color:#predictionBackgroundColor#; border-radius:4px;">
												<div style="color:#predictionTextColor#; font-weight:bold; margin-bottom:#predictionStatusMargin#px;">
													#predictionStatusText#
												</div>
												<cfif showPredictionSelect and arrayLen(predictionDetail.options)>
													<select name="config_predict_#currentrow#_#predictionDetail.question_id#" id="config_predict_#currentrow#_#predictionDetail.question_id#" onchange="submitSingleRowConfigPrediction(#currentrow#, false);" style="width:100%; height:24px; font-size:11px; border:1px solid ##d6a85d; background-color:##fffaf2;">
														<option value="">Seçiniz</option>
														<cfloop array="#predictionDetail.options#" index="predictionOption">
															<option value="#predictionOption.option_id#" <cfif len(predictionDetail.option_id) and predictionDetail.option_id eq predictionOption.option_id>selected</cfif>>#HTMLEditFormat(predictionOption.option_name)#</option>
														</cfloop>
													</select>
												</cfif>
											</div>
										</cfloop>
										<cfif configPrediction.total_questions gt 0>
											<cfset predictionSummaryColor = "##2e7d32">
											<cfif configPrediction.needs_manual_selection>
												<cfset predictionSummaryColor = "##b26a00">
											</cfif>
											<div style="color:#predictionSummaryColor#; font-size:10px; font-weight:bold;">
												#configPrediction.matched_questions#/#configPrediction.total_questions# bulundu
											</div>
										</cfif>
									</cfif>
								</td>
                                <td style="text-align:left">#DIM#</td>
                                <td style="text-align:left">#LOCATION_AREA#</td>
                                <td style="text-align:center">
                                	<input type="checkbox" name="select_production" id="select_production#currentrow#" value="#get_detail.VIRTUAL_OFFER_ROW_ID#" <cfif (len(stock_id_) eq 0 and suggestionMatch.match_status neq "exact") or (isdefined("get_detail.TRANSFER_ROW_ID") and val(get_detail.TRANSFER_ROW_ID) gt 0)>disabled="disabled"</cfif>>
                                </td>
                         	</tr>
                        </cfoutput> 
                        <tfoot>
                        	<td colspan="11"></td>
                            <td colspan="4" style="text-align:right">
                                <button type="button" value="" name="delete_non_transferred" onClick="deleteNonTransferredRows();" style="width:49%; height:35px; margin-bottom:6px; background-color:red; color:white; border-color:red; font-weight:bold	">Satır Sil&nbsp;</button>
                                <cfif attributes.is_related eq 1>
                                    <button type="button" value="" name="teklife_gonder" onClick="grupla(-3);" style="width:49%; height:35px; background-color:green; color:white; border-color:green; font-weight:bold">Teklife Gönder&nbsp;</button>
                                <cfelse>
                                    <button type="button" value="" name="gonder" onClick="grupla(-2);" style="width:49%; height:35px; background-color:blue; color:white; border-color:blue; font-weight:bold">Ürün Tanımla&nbsp;</button>
                                </cfif>
                            </td>	
                        </tfoot>
                    <cfelse>
                        <tr> 
                            <td colspan="15">
                                <cfif isdefined('attributes.is_filter')>
                                    <cf_get_lang dictionary_id="58486.Kayıt Bulunamadı">!
                                <cfelse>
                                    <cf_get_lang dictionary_id="57701.Filtre Ediniz">!
                                </cfif>
                            </td>
                        </tr>
                    </cfif>
                </tbody>
           	</cf_grid_list>
       	</cfform> 
	</cf_box>
    <cfif attributes.totalrecords gt attributes.maxrows>
        <table width="99%">
            <tr> 
                <td>
                <cfset adres = "prod.popup_list_virtual_offer_analist&is_filter=1">
                <cfif len(attributes.keyword)>
                    <cfset adres = "#adres#&keyword=#attributes.keyword#">
                </cfif>
                <cfif isdefined('attributes.is_related') and len(attributes.is_related)>
                    <cfset adres = "#adres#&is_related=#attributes.is_related#">
                </cfif>
                <cf_paging
                    page="#attributes.page#"
                    maxrows="#attributes.maxrows#"
                    totalrecords="#attributes.totalrecords#"
                    startrow="#attributes.startrow#"
                    adres="#adres#">
                </td>
            </tr>
        </table>
    </cfif>
    </div>
</div>

<div id="image_preview_overlay" onclick="closeImagePreview();" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.75); z-index:9999; text-align:center;">
	<div style="position:absolute; top:20px; right:30px; color:##fff; font-size:28px; font-weight:bold; cursor:pointer;">x</div>
	<img id="image_preview_large" src="" alt="" onclick="event.stopPropagation();" style="max-width:90vw; max-height:90vh; margin-top:5vh; border:3px solid ##fff; background:##fff;">
	<div id="image_preview_title" onclick="event.stopPropagation();" style="color:##fff; margin-top:10px; font-weight:bold;"></div>
</div>

<script type="text/javascript">
	$( "#keyword" ).focus();
	function openImagePreview(imageSrc, imageTitle)
	{
		document.getElementById('image_preview_large').src = imageSrc;
		document.getElementById('image_preview_large').alt = imageTitle;
		document.getElementById('image_preview_title').innerHTML = imageTitle;
		document.getElementById('image_preview_overlay').style.display = 'block';
	}

	function closeImagePreview()
	{
		document.getElementById('image_preview_overlay').style.display = 'none';
		document.getElementById('image_preview_large').src = '';
		document.getElementById('image_preview_title').innerHTML = '';
	}

	function getRowImageCell(rowNo)
	{
		return document.getElementById('image_cell' + rowNo);
	}

	function getRowProductName(rowNo)
	{
		var imageCell = getRowImageCell(rowNo);

		if(!imageCell)
			return '';

		return imageCell.getAttribute('data-product-name') || '';
	}

	function setRowImageDropState(rowNo, isActive)
	{
		var imageCell = getRowImageCell(rowNo);
		var imageCellContainer = null;
		var rowElement = null;

		if(!imageCell || !imageCell.parentNode)
			return;

		imageCellContainer = imageCell.parentNode;
		rowElement = imageCellContainer.parentNode;

		if(isActive)
		{
			imageCellContainer.style.backgroundColor = '#e3f2fd';
			imageCellContainer.style.boxShadow = 'inset 0 0 0 2px #64b5f6';
			imageCellContainer.style.borderRadius = '8px';
			if(rowElement)
			{
				rowElement.style.backgroundColor = '#f1f8ff';
				rowElement.style.boxShadow = 'inset 0 0 0 2px #bbdefb';
			}
		}
		else
		{
			imageCellContainer.style.backgroundColor = '';
			imageCellContainer.style.boxShadow = '';
			imageCellContainer.style.borderRadius = '';
			if(rowElement)
			{
				rowElement.style.backgroundColor = '';
				rowElement.style.boxShadow = '';
			}
		}
	}

	function preventBrowserFileDrop(event)
	{
		event.preventDefault();
	}

	function getClosestRowImageDropZone(target)
	{
		while(target)
		{
			if(target.className && (' ' + target.className + ' ').indexOf(' row-image-drop-zone ') > -1)
				return target;

			target = target.parentNode;
		}

		return null;
	}

	function normalizeRowImageUploadResponse(responseData)
	{
		if(!responseData)
			return { success: false, message: '' };

		return {
			success: !!(responseData.success || responseData.SUCCESS),
			message: responseData.message || responseData.MESSAGE || '',
			file_name: responseData.file_name || responseData.FILE_NAME || '',
			file_path: responseData.file_path || responseData.FILE_PATH || ''
		};
	}

	function buildImageDropZoneHtml(rowNo, offerRowId)
	{
		return '<div id="image_drop_zone' + rowNo + '" class="row-image-drop-zone" data-row-no="' + rowNo + '" data-offer-row-id="' + offerRowId + '" onclick="chooseRowImage(' + rowNo + ');" style="width:78px; min-height:78px; border:2px dashed #bbb; padding:6px; cursor:pointer; font-size:10px; color:#666; line-height:1.4; display:flex; align-items:center; justify-content:center; box-sizing:border-box; border-radius:6px; text-align:center; transition:all 0.15s ease;">Resmi buraya birak</div><input type="file" id="row_image_input' + rowNo + '" accept="image/*" style="display:none;" onchange="handleImageSelect(this,' + rowNo + ',' + offerRowId + ');">';
	}

	function renderRowImagePreview(rowNo, imageSrc)
	{
		var imageCell = getRowImageCell(rowNo);
		var previewImage = null;
		var productName = getRowProductName(rowNo);

		if(!imageCell)
			return;

		imageCell.innerHTML = '';
		previewImage = document.createElement('img');
		previewImage.src = imageSrc;
		previewImage.alt = productName;
		previewImage.style.maxWidth = '60px';
		previewImage.style.maxHeight = '60px';
		previewImage.style.border = '1px solid #ddd';
		previewImage.style.padding = '2px';
		previewImage.style.cursor = 'pointer';
		previewImage.onclick = function() {
			openImagePreview(imageSrc, productName);
		};
		imageCell.appendChild(previewImage);
	}

	function renderSelectedRowImage(file, rowNo)
	{
		var fileReader = null;

		if(!file)
			return;

		fileReader = new FileReader();
		fileReader.onload = function(loadEvent) {
			renderRowImagePreview(rowNo, loadEvent.target.result);
		};
		fileReader.readAsDataURL(file);
	}

	function chooseRowImage(rowNo)
	{
		var fileInput = document.getElementById('row_image_input' + rowNo);

		if(fileInput)
			fileInput.click();
	}

	function handleImageDragOver(event, element)
	{
		event.preventDefault();
		event.stopPropagation();
		setRowImageDropState(element.getAttribute('data-row-no'), true);
		element.style.backgroundColor = '#d9efff';
		element.style.borderColor = '#1e88e5';
		element.style.boxShadow = '0 0 0 4px rgba(30,136,229,0.25)';
		element.style.transform = 'scale(1.05)';
		element.style.color = '#0d47a1';
		return false;
	}

	function handleImageDragLeave(event, element)
	{
		event.preventDefault();
		event.stopPropagation();
		setRowImageDropState(element.getAttribute('data-row-no'), false);
		element.style.backgroundColor = '';
		element.style.borderColor = '#bbb';
		element.style.boxShadow = '';
		element.style.transform = '';
		element.style.color = '#666';
		return false;
	}

	function handleImageDrop(event, rowNo, offerRowId)
	{
		var droppedFile = null;

		event.preventDefault();
		event.stopPropagation();
		handleImageDragLeave(event, document.getElementById('image_drop_zone' + rowNo));

		if(!event.dataTransfer || !event.dataTransfer.files || !event.dataTransfer.files.length)
			return false;

		droppedFile = event.dataTransfer.files[0];
		uploadRowImage(droppedFile, rowNo, offerRowId);
		return false;
	}

	function handleImageSelect(input, rowNo, offerRowId)
	{
		if(input.files && input.files.length)
			uploadRowImage(input.files[0], rowNo, offerRowId);

		input.value = '';
	}

	function uploadRowImage(file, rowNo, offerRowId)
	{
		var imageCell = getRowImageCell(rowNo);
		var formData = null;
		var request = null;

		if(!file || !imageCell)
			return;

		if(file.type && file.type.indexOf('image/') !== 0)
		{
			alert('Sadece resim dosyasi yukleyebilirsiniz.');
			return;
		}

		renderSelectedRowImage(file, rowNo);

		formData = new FormData();
		formData.append('process_type', '-4');
		formData.append('virtual_offer_id', document.getElementById('virtual_offer_id').value);
		formData.append('offer_row_id', offerRowId);
		formData.append('row_image_file', file);

		request = new XMLHttpRequest();
		request.open('POST', '<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_add_ezgi_virtual_offer_row_file_import', true);
		request.onreadystatechange = function() {
			var responseData = null;
			var hasHttpError = false;

			if(request.readyState !== 4)
				return;

			hasHttpError = (request.status < 200 || request.status >= 300);

			try
			{
				responseData = normalizeRowImageUploadResponse(parseRowImageUploadResponse(request.responseText));
			}
			catch(error)
			{
				if(hasHttpError)
				{
					imageCell.innerHTML = buildImageDropZoneHtml(rowNo, offerRowId);
					alert('Resim yukleme sirasinda hata olustu.');
				}
				return;
			}

			if(hasHttpError && (!responseData || !responseData.success))
			{
				imageCell.innerHTML = buildImageDropZoneHtml(rowNo, offerRowId);
				alert((responseData && responseData.message) ? responseData.message : 'Resim yukleme sirasinda hata olustu.');
				return;
			}

			if(!responseData.success)
			{
				imageCell.innerHTML = buildImageDropZoneHtml(rowNo, offerRowId);
				alert(responseData.message || 'Resim yukleme sirasinda hata olustu.');
				return;
			}
		};
		request.send(formData);
	}

	function parseRowImageUploadResponse(responseText)
	{
		var startMarker = '__ROW_IMAGE_UPLOAD_JSON_START__';
		var endMarker = '__ROW_IMAGE_UPLOAD_JSON_END__';
		var startIndex = responseText.indexOf(startMarker);
		var endIndex = responseText.indexOf(endMarker);
		var jsonText = '';
		var firstBrace = -1;
		var lastBrace = -1;

		if(startIndex > -1 && endIndex > startIndex)
		{
			jsonText = responseText.substring(startIndex + startMarker.length, endIndex);
			return JSON.parse(jsonText);
		}

		firstBrace = responseText.indexOf('{');
		lastBrace = responseText.lastIndexOf('}');

		if(firstBrace > -1 && lastBrace > firstBrace)
		{
			jsonText = responseText.substring(firstBrace, lastBrace + 1);
			return JSON.parse(jsonText);
		}

		return JSON.parse(responseText);
	}

	function applySuggestion(rowNo)
	{
		var suggestionStatusInput = document.getElementById('suggestion_status' + rowNo);
		var suggestionPidInput = document.getElementById('suggestion_pid' + rowNo);
		var suggestionStockInput = document.getElementById('suggestion_stock_id' + rowNo);
		var suggestionNameInput = document.getElementById('suggestion_product_name' + rowNo);
		var pidInput = document.getElementById('pid' + rowNo);
		var stockInput = document.getElementById('stock_id' + rowNo);
		var nameInput = document.getElementById('urun' + rowNo);

		if(
			!suggestionStatusInput ||
			!suggestionPidInput ||
			!suggestionStockInput ||
			!suggestionNameInput ||
			!pidInput ||
			!stockInput ||
			!nameInput
		)
			return;

		if(suggestionStatusInput.value.length == 0 || suggestionStatusInput.value == 'none')
			return;

		pidInput.value = suggestionPidInput.value;
		stockInput.value = suggestionStockInput.value;
		nameInput.value = suggestionNameInput.value;

		refreshApprovalIcon(rowNo);
		submitSingleRowProductDefinition(rowNo);
	}

	function submitSingleRowProductDefinition(rowNo)
	{
		var formElement = document.getElementById('import_list');
		var rowCheckbox = document.getElementById('select_production' + rowNo);
		var existingMatchInput = document.getElementById('existing_match' + rowNo);
		var suggestionStatusInput = document.getElementById('suggestion_status' + rowNo);
		var suggestionText = document.getElementById('suggestion_text' + rowNo);
		var stockCodeInput = document.getElementById('stock_code' + rowNo);
		var unitValueInput = document.getElementById('unit_value' + rowNo);
		var priceValueInput = document.getElementById('price_value' + rowNo);
		var otherMoneyValueInput = document.getElementById('other_money_value' + rowNo);
		var purchasePriceInput = document.getElementById('purchase_price' + rowNo);
		var purchasePriceMoneyInput = document.getElementById('purchase_price_money' + rowNo);
		var costPriceInput = document.getElementById('cost_price' + rowNo);
		var costPriceMoneyInput = document.getElementById('cost_price_money' + rowNo);
		var taxValueInput = document.getElementById('tax_value' + rowNo);
		var priceCatValueInput = document.getElementById('price_cat_value' + rowNo);
		var discount1Input = document.getElementById('discount_1_value' + rowNo);
		var discount2Input = document.getElementById('discount_2_value' + rowNo);
		var discount3Input = document.getElementById('discount_3_value' + rowNo);
		var request = null;
		var formData = null;
		var responseData = null;
		var offerRowId = '';

		if(!formElement || !rowCheckbox)
			return false;

		offerRowId = rowCheckbox.value ? rowCheckbox.value.replace(/^\s+|\s+$/g, '') : '';

		if(!offerRowId.length)
			return false;

		formData = new FormData(formElement);
		formData.append('ajax_mode', '1');

		request = new XMLHttpRequest();
		request.open('POST', "<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_add_ezgi_virtual_offer_row_file_import&process_type=-2&offer_row_id_list=" + encodeURIComponent(offerRowId), true);
		request.onreadystatechange = function() {
			if(request.readyState !== 4)
				return;

			try
			{
				responseData = normalizeRowProductDefineResponse(parseRowProductDefineResponse(request.responseText));
			}
			catch(error)
			{
				alert('Ürün tanımlama yanıtı okunamadı.');
				return;
			}

			if(request.status < 200 || request.status >= 300 || !responseData.success)
			{
				alert(responseData.message || 'Ürün tanımlama işlemi sırasında hata oluştu.');
				return;
			}

			if(existingMatchInput)
				existingMatchInput.value = '1';
			if(suggestionStatusInput)
				suggestionStatusInput.value = 'none';
			if(suggestionText)
				suggestionText.innerHTML = '<span style="font-weight:bold;">' + escapeHtml(responseData.product_name || '') + '</span><br><span style="color:green;">Ürün Bağlantısı Yapılmıştır.</span>';
			if(stockCodeInput)
				stockCodeInput.value = responseData.stock_code || '';
			if(unitValueInput)
				unitValueInput.value = responseData.unit || '';
			if(priceValueInput)
				priceValueInput.value = responseData.price || '';
			if(otherMoneyValueInput)
				otherMoneyValueInput.value = responseData.other_money || '';
			if(purchasePriceInput)
				purchasePriceInput.value = responseData.purchase_price || '';
			if(purchasePriceMoneyInput)
				purchasePriceMoneyInput.value = responseData.purchase_price_money || '';
			if(costPriceInput)
				costPriceInput.value = responseData.cost_price || '';
			if(costPriceMoneyInput)
				costPriceMoneyInput.value = responseData.cost_price_money || '';
			if(taxValueInput)
				taxValueInput.value = responseData.tax || '';
			if(priceCatValueInput)
				priceCatValueInput.value = responseData.price_cat_id || '';
			if(discount1Input)
				discount1Input.value = responseData.discount_1 || '';
			if(discount2Input)
				discount2Input.value = responseData.discount_2 || '';
			if(discount3Input)
				discount3Input.value = responseData.discount_3 || '';

			refreshApprovalIcon(rowNo);
			submitSingleRowConfigPrediction(rowNo, true);
		};
		request.send(formData);
		return true;
	}

	function parseRowProductDefineResponse(responseText)
	{
		var startMarker = '__ROW_PRODUCT_DEFINE_JSON_START__';
		var endMarker = '__ROW_PRODUCT_DEFINE_JSON_END__';
		var startIndex = responseText.indexOf(startMarker);
		var endIndex = responseText.indexOf(endMarker);
		var jsonText = '';

		if(startIndex > -1 && endIndex > startIndex)
		{
			jsonText = responseText.substring(startIndex + startMarker.length, endIndex);
			return JSON.parse(jsonText);
		}

		return JSON.parse(responseText);
	}

	function normalizeRowProductDefineResponse(responseData)
	{
		if(!responseData)
			return { success: false, message: '', product_name: '' };

		return {
			success: !!(responseData.success || responseData.SUCCESS),
			message: responseData.message || responseData.MESSAGE || '',
			product_name: responseData.product_name || responseData.PRODUCT_NAME || '',
			stock_code: responseData.stock_code || responseData.STOCK_CODE || '',
			unit: responseData.unit || responseData.UNIT || '',
			price: responseData.price || responseData.PRICE || '',
			other_money: responseData.other_money || responseData.OTHER_MONEY || '',
			purchase_price: responseData.purchase_price || responseData.PURCHASE_PRICE || '',
			purchase_price_money: responseData.purchase_price_money || responseData.PURCHASE_PRICE_MONEY || '',
			cost_price: responseData.cost_price || responseData.COST_PRICE || '',
			cost_price_money: responseData.cost_price_money || responseData.COST_PRICE_MONEY || '',
			tax: responseData.tax || responseData.TAX || '',
			price_cat_id: responseData.price_cat_id || responseData.PRICE_CAT_ID || '',
			discount_1: responseData.discount_1 || responseData.DISCOUNT_1 || '',
			discount_2: responseData.discount_2 || responseData.DISCOUNT_2 || '',
			discount_3: responseData.discount_3 || responseData.DISCOUNT_3 || ''
		};
	}

	function escapeHtml(text)
	{
		var value = text || '';

		return value
			.replace(/&/g, '&amp;')
			.replace(/</g, '&lt;')
			.replace(/>/g, '&gt;')
			.replace(/"/g, '&quot;')
			.replace(/'/g, '&#39;');
	}

	function submitConfigPredictionSave(offerRowIdList, isSilent)
	{
		var formElement = document.getElementById('import_list');
		var formData = null;
		var request = null;
		var responseData = null;

		if(!formElement || !offerRowIdList || !offerRowIdList.length)
			return false;

		formData = new FormData(formElement);
		formData.append('ajax_mode', '1');

		request = new XMLHttpRequest();
		request.open('POST', "<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_add_ezgi_virtual_offer_row_file_import&process_type=-7&offer_row_id_list=" + encodeURIComponent(offerRowIdList), true);
		request.onreadystatechange = function() {
			if(request.readyState !== 4)
				return;

			try
			{
				responseData = normalizeConfigPredictionResponse(parseConfigPredictionResponse(request.responseText));
			}
			catch(error)
			{
				if(!isSilent)
				{
					alert(
						'Konfigürasyon tahmini yanıtı okunamadı.\n\n' +
						'HTTP: ' + request.status + '\n\n' +
						(request.responseText ? request.responseText.substring(0, 1200) : 'Boş yanıt')
					);
				}
				return;
			}

			if((request.status < 200 || request.status >= 300 || !responseData.success) && !isSilent)
			{
				alert(
					(responseData.message && responseData.message.length ? responseData.message : 'Konfigürasyon tahmini kaydedilemedi.') +
					'\n\nHTTP: ' + request.status +
					'\n\nJSON: ' + JSON.stringify(responseData) +
					'\n\nRAW: ' + (request.responseText ? request.responseText.substring(0, 1500) : 'Boş yanıt')
				);
			}
		};
		request.send(formData);
		return true;
	}

	function normalizeConfigPredictionResponse(responseData)
	{
		if(!responseData)
			return { success: false, message: '', results: [] };

		return {
			success: !!(responseData.success || responseData.SUCCESS),
			message: responseData.message || responseData.MESSAGE || '',
			results: responseData.results || responseData.RESULTS || []
		};
	}

	function parseConfigPredictionResponse(responseText)
	{
		var startMarker = '__CONFIG_PREDICT_JSON_START__';
		var endMarker = '__CONFIG_PREDICT_JSON_END__';
		var startIndex = responseText.indexOf(startMarker);
		var endIndex = responseText.indexOf(endMarker);
		var jsonText = '';

		if(startIndex > -1 && endIndex > startIndex)
		{
			jsonText = responseText.substring(startIndex + startMarker.length, endIndex);
			return JSON.parse(jsonText);
		}

		return JSON.parse(responseText);
	}

	function submitSingleRowConfigPrediction(rowNo, isSilent)
	{
		var rowCheckbox = document.getElementById('select_production' + rowNo);
		var stockInput = document.getElementById('stock_id' + rowNo);
		var offerRowId = '';

		if(!rowCheckbox || !stockInput)
			return false;

		offerRowId = rowCheckbox.value ? rowCheckbox.value.replace(/^\s+|\s+$/g, '') : '';

		if(!offerRowId.length)
			return false;

		if(!stockInput.value || !stockInput.value.replace(/^\s+|\s+$/g, '').length)
			return false;

		return submitConfigPredictionSave(offerRowId, isSilent === true);
	}

	function saveVisibleConfigPredictions()
	{
		var rowCheckboxes = document.querySelectorAll('input[name="select_production"]');
		var offerRowIdList = [];
		var i = 0;
		var rowCheckbox = null;
		var rowNo = '';
		var stockInput = null;

		for(i = 0; i < rowCheckboxes.length; i++)
		{
			rowCheckbox = rowCheckboxes[i];
			rowNo = rowCheckbox.id ? rowCheckbox.id.replace('select_production', '') : '';
			stockInput = document.getElementById('stock_id' + rowNo);

			if(
				rowCheckbox &&
				rowCheckbox.value &&
				stockInput &&
				stockInput.value &&
				stockInput.value.replace(/^\s+|\s+$/g, '').length
			)
				offerRowIdList.push(rowCheckbox.value);
		}

		if(offerRowIdList.length)
			submitConfigPredictionSave(offerRowIdList.join(','), true);
	}

	var productSelectionWatchers = {};

	function startProductSelectionWatcher(rowNo)
	{
		var stockInput = document.getElementById('stock_id' + rowNo);
		var pidInput = document.getElementById('pid' + rowNo);
		var initialStockValue = '';
		var initialPidValue = '';
		var tickCount = 0;

		if(!stockInput || !pidInput)
			return;

		if(productSelectionWatchers[rowNo])
			window.clearInterval(productSelectionWatchers[rowNo]);

		initialStockValue = stockInput.value ? stockInput.value.replace(/^\s+|\s+$/g, '') : '';
		initialPidValue = pidInput.value ? pidInput.value.replace(/^\s+|\s+$/g, '') : '';

		productSelectionWatchers[rowNo] = window.setInterval(function() {
			var currentStockValue = stockInput.value ? stockInput.value.replace(/^\s+|\s+$/g, '') : '';
			var currentPidValue = pidInput.value ? pidInput.value.replace(/^\s+|\s+$/g, '') : '';

			tickCount++;

			if(
				currentStockValue.length &&
				currentPidValue.length &&
				(currentStockValue != initialStockValue || currentPidValue != initialPidValue)
			)
			{
				window.clearInterval(productSelectionWatchers[rowNo]);
				delete productSelectionWatchers[rowNo];
				submitSingleRowProductDefinition(rowNo);
				return;
			}

			if(tickCount > 300)
			{
				window.clearInterval(productSelectionWatchers[rowNo]);
				delete productSelectionWatchers[rowNo];
			}
		}, 500);
	}

	function refreshApprovalIcon(rowNo)
	{
		var stockInput = document.getElementById('stock_id' + rowNo);
		var existingMatchInput = document.getElementById('existing_match' + rowNo);
		var transferRowInput = document.getElementById('transfer_row_id' + rowNo);
		var suggestionStatusInput = document.getElementById('suggestion_status' + rowNo);
		var iconWrapper = document.getElementById('approval_icon' + rowNo);
		var rowCheckbox = document.getElementById('select_production' + rowNo);
		var stockValue = '';
		var existingMatchValue = '';
		var transferRowValue = '';
		var suggestionStatus = '';

		if(!stockInput || !suggestionStatusInput || !iconWrapper)
			return;

		stockValue = stockInput.value ? stockInput.value.replace(/^\s+|\s+$/g, '') : '';
		existingMatchValue = existingMatchInput && existingMatchInput.value ? existingMatchInput.value.replace(/^\s+|\s+$/g, '') : '';
		transferRowValue = transferRowInput && transferRowInput.value ? transferRowInput.value.replace(/^\s+|\s+$/g, '') : '';
		suggestionStatus = suggestionStatusInput.value ? suggestionStatusInput.value.replace(/^\s+|\s+$/g, '') : '';

		if(stockValue.length)
		{
			iconWrapper.innerHTML = '<span style="color:#2e7d32; font-weight:bold;">&#10003;</span>';
			if(rowCheckbox)
			{
				if(transferRowValue.length && parseInt(transferRowValue,10) > 0)
				{
					rowCheckbox.checked = false;
					rowCheckbox.disabled = true;
				}
				else
					rowCheckbox.disabled = false;
			}
		}
		else if(suggestionStatus.length && suggestionStatus != 'none')
		{
			iconWrapper.innerHTML = '<a href="javascript://" onclick="applySuggestion(' + rowNo + ');" style="color:#888; font-weight:bold; text-decoration:none;" title="Önerilen ürünü bağla">!</a>';
			if(rowCheckbox)
			{
				rowCheckbox.disabled = (suggestionStatus == 'exact') ? false : true;
			}
		}
		else
		{
			iconWrapper.innerHTML = '';
			if(rowCheckbox)
			{
				rowCheckbox.checked = false;
				rowCheckbox.disabled = true;
			}
		}
	}

	function refreshApprovalIcons()
	{
		var rowNo = 1;

		while(document.getElementById('approval_icon' + rowNo))
		{
			refreshApprovalIcon(rowNo);
			rowNo++;
		}
	}

	refreshApprovalIcons();
	window.setInterval(refreshApprovalIcons, 1000);
	window.setTimeout(saveVisibleConfigPredictions, 400);
	document.addEventListener('dragenter', function(event) {
		var dropZone = getClosestRowImageDropZone(event.target);

		if(dropZone)
			return handleImageDragOver(event, dropZone);

		return preventBrowserFileDrop(event);
	}, false);
	document.addEventListener('dragover', function(event) {
		var dropZone = getClosestRowImageDropZone(event.target);

		if(dropZone)
			return handleImageDragOver(event, dropZone);

		return preventBrowserFileDrop(event);
	}, false);
	document.addEventListener('dragleave', function(event) {
		var dropZone = getClosestRowImageDropZone(event.target);

		if(dropZone)
			return handleImageDragLeave(event, dropZone);
	}, false);
	document.addEventListener('drop', function(event) {
		var dropZone = getClosestRowImageDropZone(event.target);
		var rowNo = 0;
		var offerRowId = 0;

		if(dropZone)
		{
			rowNo = parseInt(dropZone.getAttribute('data-row-no'), 10);
			offerRowId = parseInt(dropZone.getAttribute('data-offer-row-id'), 10);
			return handleImageDrop(event, rowNo, offerRowId);
		}

		return preventBrowserFileDrop(event);
	}, false);

	function prepareExactSuggestionSelections()
	{
		var rowNo = 1;
		var rowCheckbox = null;
		var suggestionStatusInput = null;
		var stockInput = null;
		var pidInput = null;
		var suggestionStockInput = null;
		var suggestionPidInput = null;

		while(document.getElementById('select_production' + rowNo))
		{
			rowCheckbox = document.getElementById('select_production' + rowNo);
			suggestionStatusInput = document.getElementById('suggestion_status' + rowNo);
			stockInput = document.getElementById('stock_id' + rowNo);
			pidInput = document.getElementById('pid' + rowNo);
			suggestionStockInput = document.getElementById('suggestion_stock_id' + rowNo);
			suggestionPidInput = document.getElementById('suggestion_pid' + rowNo);

			if(
				rowCheckbox &&
				rowCheckbox.checked &&
				suggestionStatusInput &&
				suggestionStatusInput.value == 'exact' &&
				stockInput &&
				pidInput &&
				suggestionStockInput &&
				suggestionPidInput &&
				(!stockInput.value || !stockInput.value.replace(/^\s+|\s+$/g, '').length)
			)
			{
				stockInput.value = suggestionStockInput.value;
				pidInput.value = suggestionPidInput.value;
			}

			rowNo++;
		}
	}

	function transferSelectedRowToOffer(rowNo)
	{
		var transferRowInput = document.getElementById('transfer_row_id' + rowNo);
		var rowCheckbox = document.getElementById('select_production' + rowNo);
		var stockInput = document.getElementById('stock_id' + rowNo);
		var productNameInput = document.getElementById('product_name' + rowNo);
		var stockCodeInput = document.getElementById('stock_code' + rowNo);
		var productCode2Input = document.getElementById('product_code_2' + rowNo);
		var unitValueInput = document.getElementById('unit_value' + rowNo);
		var pidInput = document.getElementById('pid' + rowNo);
		var priceValueInput = document.getElementById('price_value' + rowNo);
		var otherMoneyValueInput = document.getElementById('other_money_value' + rowNo);
		var purchasePriceInput = document.getElementById('purchase_price' + rowNo);
		var purchasePriceMoneyInput = document.getElementById('purchase_price_money' + rowNo);
		var costPriceInput = document.getElementById('cost_price' + rowNo);
		var costPriceMoneyInput = document.getElementById('cost_price_money' + rowNo);
		var taxValueInput = document.getElementById('tax_value' + rowNo);
		var priceCatValueInput = document.getElementById('price_cat_value' + rowNo);
		var discount1Input = document.getElementById('discount_1_value' + rowNo);
		var discount2Input = document.getElementById('discount_2_value' + rowNo);
		var discount3Input = document.getElementById('discount_3_value' + rowNo);
		var quantityValueInput = document.getElementById('quantity_value' + rowNo);

		if(!rowCheckbox || !stockInput || !stockInput.value || !stockInput.value.replace(/^\s+|\s+$/g, '').length)
			return false;

		if(transferRowInput)
			transferRowInput.value = rowCheckbox.value;

		rowCheckbox.checked = false;
		rowCheckbox.disabled = true;
		refreshApprovalIcon(rowNo);

		opener.add_row(
			stockInput.value || '',
			productNameInput ? productNameInput.value : '',
			stockCodeInput ? stockCodeInput.value : '',
			productCode2Input ? productCode2Input.value : '',
			unitValueInput ? unitValueInput.value : '',
			pidInput ? pidInput.value : '',
			priceValueInput ? priceValueInput.value : '',
			otherMoneyValueInput ? otherMoneyValueInput.value : '',
			'0',
			'0',
			'0',
			purchasePriceInput ? purchasePriceInput.value : '',
			purchasePriceMoneyInput ? purchasePriceMoneyInput.value : '',
			costPriceInput ? costPriceInput.value : '',
			costPriceMoneyInput ? costPriceMoneyInput.value : '',
			taxValueInput ? taxValueInput.value : '',
			priceCatValueInput ? priceCatValueInput.value : '',
			discount1Input ? discount1Input.value : '',
			discount2Input ? discount2Input.value : '',
			discount3Input ? discount3Input.value : '',
			quantityValueInput ? quantityValueInput.value : '',
			rowCheckbox.value || ''
		);

		return true;
	}

	function transferRowsSequentially(rowNumbers, currentIndex)
	{
		if(!rowNumbers || currentIndex >= rowNumbers.length)
			return;

		transferSelectedRowToOffer(rowNumbers[currentIndex]);

		if(currentIndex + 1 < rowNumbers.length)
		{
			window.setTimeout(function() {
				transferRowsSequentially(rowNumbers, currentIndex + 1);
			}, 500);
		}
	}

	function grupla(type)
	{
		var offer_row_id_list = '';
		var chck_leng = document.getElementsByName('select_production').length;
		var ci = 0;
		var selectedRowNumbers = [];

		for(ci=0; ci<chck_leng; ci++)
		{
			var my_objets = document.all.select_production[ci];
			if(chck_leng == 1)
				my_objets = document.all.select_production;

			if(type == -1)
			{
				if(!my_objets.disabled)
				{
					if(my_objets.checked == true)
						my_objets.checked = false;
					else
						my_objets.checked = true;
				}
			}
			else if(type == -2 || type == -3)
			{
				if(my_objets.checked == true && my_objets.disabled == false)
					offer_row_id_list += my_objets.value + ',';
			}
		}

		if(type == -2)
		{
			if(offer_row_id_list.length)
			{
				prepareExactSuggestionSelections();
				offer_row_id_list = offer_row_id_list.substr(0, offer_row_id_list.length - 1);
				document.getElementById("import_list").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_add_ezgi_virtual_offer_row_file_import&process_type=-2&offer_row_id_list=" + offer_row_id_list;
				document.getElementById("import_list").submit();
				return true;
			}
			else
			{
				alert('Lütfen en az bir onaylı satır seçiniz.');
				return false;
			}
		}
		else if(type == -3)
		{
			if(offer_row_id_list.length)
			{
				prepareExactSuggestionSelections();
				for(ci=0; ci<chck_leng; ci++)
				{
					my_objets = document.all.select_production[ci];
					if(chck_leng == 1)
						my_objets = document.all.select_production;

					if(my_objets.checked == true && my_objets.disabled == false)
						selectedRowNumbers.push(ci + 1);
				}
				transferRowsSequentially(selectedRowNumbers, 0);
				return true;
			}
			else
			{
				alert('Lütfen en az bir onaylı satır seçiniz.');
				return false;
			}
		}
	}

	function deleteNonTransferredRows()
	{
		var formElement = document.getElementById('import_list');
		var rowCheckboxes = document.querySelectorAll('input[name="select_production"]');
		var deleteList = [];
		var i = 0;
		var rowNo = '';
		var transferRowInput = null;

		if(!formElement || !rowCheckboxes.length)
		{
			alert('Silinecek satır bulunamadı.');
			return false;
		}

		for(i = 0; i < rowCheckboxes.length; i++)
		{
			if(rowCheckboxes[i].checked !== true)
				continue;

			rowNo = rowCheckboxes[i].id.replace('select_production', '');
			transferRowInput = document.getElementById('transfer_row_id' + rowNo);

			if(!transferRowInput || !transferRowInput.value || parseInt(transferRowInput.value, 10) <= 0)
				deleteList.push(rowCheckboxes[i].value);
		}

		if(!deleteList.length)
		{
			alert('Lütfen silmek için transfer edilmemiş en az bir satır seçiniz.');
			return false;
		}

		if(!confirm('İşaretlenen transfer edilmemiş ' + deleteList.length + ' satır silinecek. Devam edilsin mi?'))
			return false;

		document.getElementById('delete_offer_row_id_list').value = deleteList.join(',');
		formElement.action = "<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_add_ezgi_virtual_offer_row_file_import&process_type=-6";
		formElement.submit();
		return true;
	}

	function input_control()
	{
		if(document.getElementById('is_excel').checked==false)
			return true;
	}
	function pencere_ac(no)
	{
		startProductSelectionWatcher(no);
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=6,9&product_id=import_list.pid" + no +"&field_id=import_list.stock_id" + no +"&field_name=import_list.urun" + no,'list');
	}
</script>