<!---
    File: upd_ezgi_product_tree_creative_piece_options_info.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfif isdefined('upd')>
	<cfif len(attributes.yuzey_code1)>
    	<cfquery name="GET_PRODUCT_CODE_2" datasource="#DSN3#">
            SELECT PRODUCT_CODE_2, PRODUCT_NAME FROM STOCKS WHERE STOCK_ID = #attributes.yuzey_code1#
        </cfquery>
        <cfif not len(GET_PRODUCT_CODE_2.PRODUCT_CODE_2)>
        	<script type="text/javascript">
				alert("Oda İç Yüzey İçin Tanımlanmış <cfoutput>#GET_PRODUCT_CODE_2.PRODUCT_NAME#</cfoutput> Üründe Özel Kod Alanı Boştur!");
				window.close()
			</script>
			<cfabort>
        </cfif>
        <cfset yuzey_code_1 = GET_PRODUCT_CODE_2.PRODUCT_CODE_2>
   	<cfelse>
    	<cfset yuzey_code_1 = ''>
    </cfif>
    <cfif len(attributes.yuzey_code2)>
    	<cfquery name="GET_PRODUCT_CODE_2" datasource="#DSN3#">
            SELECT PRODUCT_CODE_2, PRODUCT_NAME FROM STOCKS WHERE STOCK_ID = #attributes.yuzey_code2#
        </cfquery>
        <cfif not len(GET_PRODUCT_CODE_2.PRODUCT_CODE_2)>
        	<script type="text/javascript">
				alert("Oda İç Yüzey İçin Tanımlanmış <cfoutput>#GET_PRODUCT_CODE_2.PRODUCT_NAME#</cfoutput> Üründe Özel Kod Alanı Boştur!");
				window.close()
			</script>
			<cfabort>
        </cfif>
        <cfset yuzey_code_2 = GET_PRODUCT_CODE_2.PRODUCT_CODE_2>
   	<cfelse>
    	<cfset yuzey_code_2 = ''>
    </cfif>
    <cfif len(attributes.boya_code1)>
    	<cfquery name="GET_PRODUCT_CODE_2" datasource="#DSN3#">
            SELECT PRODUCT_CODE_2, PRODUCT_NAME FROM STOCKS WHERE STOCK_ID = #attributes.boya_code1#
        </cfquery>
        <cfif not len(GET_PRODUCT_CODE_2.PRODUCT_CODE_2)>
        	<script type="text/javascript">
				alert("Oda İç Yüzey İçin Tanımlanmış <cfoutput>#GET_PRODUCT_CODE_2.PRODUCT_NAME#</cfoutput> Üründe Özel Kod Alanı Boştur!");
				window.close()
			</script>
			<cfabort>
        </cfif>
        <cfset boya_code_1 = GET_PRODUCT_CODE_2.PRODUCT_CODE_2>
   	<cfelse>
    	<cfset boya_code_1 = ''>
    </cfif>
    <cfif len(attributes.boya_code2)>
    	<cfquery name="GET_PRODUCT_CODE_2" datasource="#DSN3#">
            SELECT PRODUCT_CODE_2, PRODUCT_NAME FROM STOCKS WHERE STOCK_ID = #attributes.boya_code2#
        </cfquery>
        <cfif not len(GET_PRODUCT_CODE_2.PRODUCT_CODE_2)>
        	<script type="text/javascript">
				alert("Oda İç Yüzey İçin Tanımlanmış <cfoutput>#GET_PRODUCT_CODE_2.PRODUCT_NAME#</cfoutput> Üründe Özel Kod Alanı Boştur!");
				window.close()
			</script>
			<cfabort>
        </cfif>
        <cfset boya_code_2 = GET_PRODUCT_CODE_2.PRODUCT_CODE_2>
   	<cfelse>
    	<cfset boya_code_2 = ''>
    </cfif>
	<cfset attributes.PIECE_PARAMS = "#attributes.modul_code#*#attributes.operation_code#*#yuzey_code_1#*#yuzey_code_2#*#boya_code_1#*#boya_code_2#****">
	<cfquery name="UPD_PIECE_PARAMS" datasource="#dsn3#">
    	UPDATE 
        	EZGI_DESIGN_PIECE_ROWS
       	SET
        	PIECE_PARAMS = '#attributes.PIECE_PARAMS#',
            IS_LABEL = #attributes.is_label#
      	WHERE
        	PIECE_ROW_ID = #attributes.piece_row_id#
    </cfquery>
    <script type="text/javascript">
		alert("Ek Bilgiler Başarıyla Güncellenmiştir.!");
		window.close()
	</script>
	<cfabort>
</cfif>
<cfquery name="get_hizmet" datasource="#dsn3#">
	SELECT 
    	E.STOCK_ID, 
        E.AMOUNT, 
        E.SIRA_NO, 
        S.PRODUCT_NAME
	FROM     
    	EZGI_DESIGN_PIECE_ROW AS E WITH (NOLOCK) INNER JOIN
        STOCKS AS S WITH (NOLOCK) ON E.STOCK_ID = S.STOCK_ID
	WHERE  
    	E.PIECE_ROW_ID = #attributes.piece_row_id# AND 
        E.PIECE_ROW_ROW_TYPE = 3
  	ORDER BY
    	E.SIRA_NO
</cfquery>
<cfquery name="get_params" datasource="#dsn3#">
	SELECT PIECE_PARAMS,ISNULL(IS_LABEL,0) AS IS_LABEL FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) WHERE PIECE_ROW_ID = #attributes.piece_row_id#
</cfquery>
<cfif get_params.recordcount and len(get_params.PIECE_PARAMS)>
	<cfset modul_no = ListGetAt(get_params.PIECE_PARAMS,1,'*',true)>
   	<cfset operasyon_code = ListGetAt(get_params.PIECE_PARAMS,2,'*',true)>
  	<cfset yuzey_code1 = ListGetAt(get_params.PIECE_PARAMS,3,'*',true)>
   	<cfset yuzey_code2= ListGetAt(get_params.PIECE_PARAMS,4,'*',true)>
  	<cfset boya_code1 = ListGetAt(get_params.PIECE_PARAMS,5,'*',true)>
  	<cfset boya_code2= ListGetAt(get_params.PIECE_PARAMS,6,'*',true)>
<cfelse>
	<cfset modul_no = ''>
   	<cfset operasyon_code = ''>
    <cfset yuzey_code1 = ''>
    <cfset yuzey_code2= ''>
    <cfset boya_code1 = ''>
    <cfset boya_code2= ''>
</cfif>
<cfif len(yuzey_code1)>
	<cfquery name="GET_STOCK_ID" datasource="#DSN3#">
		SELECT STOCK_ID FROM STOCKS WITH (NOLOCK) WHERE PRODUCT_CODE_2 = '#yuzey_code1#'
	</cfquery>
    <cfif GET_STOCK_ID.recordcount gt 1>
    	<script type="text/javascript">
			alert("Oda İç Yüzey İçin Tanımlanmış <cfoutput>#yuzey_code1#</cfoutput> Özel Kodu Birden Fazla Üründe Bulunmuştur!");
			window.close()
		</script>
        <cfabort>
    </cfif>
    <cfif not GET_STOCK_ID.recordcount>
    	<script type="text/javascript">
			alert("Oda İç Yüzey İçin Tanımlanmış <cfoutput>#yuzey_code1#</cfoutput> Özel Kodu Hiç Bir Üründe Bulunamamıştır!");
			window.close()
		</script>
        <cfabort>
    </cfif>
    <cfset yuzey_code1_stockid = GET_STOCK_ID.STOCK_ID>
<cfelse>
	<cfset yuzey_code1_stockid = ''>
</cfif>
<cfif len(yuzey_code2)>
	<cfquery name="GET_STOCK_ID" datasource="#DSN3#">
		SELECT STOCK_ID FROM STOCKS WITH (NOLOCK) WHERE PRODUCT_CODE_2 = '#yuzey_code2#'
	</cfquery>
    <cfif GET_STOCK_ID.recordcount gt 1>
    	<script type="text/javascript">
			alert("Oda Dış Yüzey İçin Tanımlanmış <cfoutput>#yuzey_code2#</cfoutput> Özel Kodu Birden Fazla Üründe Bulunmuştur!");
			window.close()
		</script>
        <cfabort>
    </cfif>
    <cfif not GET_STOCK_ID.recordcount>
    	<script type="text/javascript">
			alert("Oda Dış Yüzey İçin Tanımlanmış <cfoutput>#yuzey_code2#</cfoutput> Özel Kodu Hiç Bir Üründe Bulunamamıştır!");
			window.close()
		</script>
        <cfabort>
    </cfif>
    <cfset yuzey_code2_stockid = GET_STOCK_ID.STOCK_ID>
<cfelse>
	<cfset yuzey_code2_stockid = ''>
</cfif>
<cfif len(boya_code1)>
	<cfquery name="GET_STOCK_ID" datasource="#DSN3#">
		SELECT STOCK_ID FROM STOCKS WITH (NOLOCK) WHERE PRODUCT_CODE_2 = '#boya_code1#'
	</cfquery>
    <cfif GET_STOCK_ID.recordcount gt 1>
    	<script type="text/javascript">
			alert("Oda İç Boya İçin Tanımlanmış <cfoutput>#boya_code1#</cfoutput> Özel Kodu Birden Fazla Üründe Bulunmuştur!");
			window.close()
		</script>
        <cfabort>
    </cfif>
    <cfif not GET_STOCK_ID.recordcount>
    	<script type="text/javascript">
			alert("Oda İç Boya İçin Tanımlanmış <cfoutput>#boya_code1#</cfoutput> Özel Kodu Hiç Bir Üründe Bulunamamıştır!");
			window.close()
		</script>
        <cfabort>
    </cfif>
    <cfset boya_code1_stockid = GET_STOCK_ID.STOCK_ID>
<cfelse>
	<cfset boya_code1_stockid = ''>
</cfif>
<cfif len(boya_code2)>
	<cfquery name="GET_STOCK_ID" datasource="#DSN3#">
		SELECT STOCK_ID FROM STOCKS WITH (NOLOCK) WHERE PRODUCT_CODE_2 = '#boya_code2#'
	</cfquery>
    <cfif GET_STOCK_ID.recordcount gt 1>
    	<script type="text/javascript">
			alert("Oda Dış Boya İçin Tanımlanmış <cfoutput>#boya_code2#</cfoutput> Özel Kodu Birden Fazla Üründe Bulunmuştur!");
			window.close()
		</script>
        <cfabort>
    </cfif>
    <cfif not GET_STOCK_ID.recordcount>
    	<script type="text/javascript">
			alert("Oda Dış Boya İçin Tanımlanmış <cfoutput>#boya_code2#</cfoutput> Özel Kodu Hiç Bir Üründe Bulunamamıştır!");
			window.close()
		</script>
        <cfabort>
    </cfif>
    <cfset boya_code2_stockid = GET_STOCK_ID.STOCK_ID>
<cfelse>
	<cfset boya_code2_stockid = ''>
</cfif>
<br>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="ekle">
		<cf_get_lang dictionary_id='55129.Ek Bilgiler'>
	</cfsavecontent>
	<cf_box title="#ekle#">
    <cf_box>
    	<cfform name="piece_options_info" method="post" action="#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_piece_options_info&upd=1">
    		<cfinput type="hidden" name="piece_row_id" value="#attributes.piece_row_id#">
           	<cf_box_elements>
            	<div class="col col-6 col-md-6 col-sm-9 col-xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="is_label_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="36610.Etiket Bilgisi"></label>
                    	<div class="col col-8 col-xs-12">
                         	<select name="is_label">
                            	<option value="1" <cfif get_params.IS_LABEL eq 1>selected</cfif>><cf_get_lang dictionary_id="29813.Gösterme"></option>
                                <option value="0" <cfif get_params.IS_LABEL eq 0>selected</cfif>><cf_get_lang dictionary_id="58596.Göster"></option>
                            </select>
                      	</div>
                 	</div>
                    <div class="form-group" id="modul_code_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="849.Modül Kodu"></label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="modul_code" id="modul_code" value="#modul_no#" maxlength="10">
                      	</div>
                 	</div>
                    <div class="form-group" id="operation_code_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="36377.Operasyon Kodu"></label>
                    	<div class="col col-8 col-xs-12">
                         	<cfinput type="text" name="operation_code" id="operation_code" value="#operasyon_code#" maxlength="10">
                      	</div>
                 	</div>
                    <div class="form-group" id="yuzey_code1_">
                     	<label class="col col-4 col-xs-12">Oda İç Yüzey</label>
                    	<div class="col col-8 col-xs-12">
                         	<select name="yuzey_code1" id="yuzey_code1" style="height:20px">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_hizmet">
                                    <option value="#STOCK_ID#" <cfif len(yuzey_code1_stockid) and yuzey_code1_stockid eq get_hizmet.stock_id>selected style="font-weight:bold"</cfif>>#PRODUCT_NAME#</option>
                                </cfoutput>
                            </select>
                      	</div>
                 	</div>
					<div class="form-group" id="yuzey_code2_">
                     	<label class="col col-4 col-xs-12">Oda Dış Yüzey</label>
                    	<div class="col col-8 col-xs-12">
                         	<select name="yuzey_code2" id="yuzey_code2" style="height:20px">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_hizmet">
                                     <option value="#STOCK_ID#" <cfif len(yuzey_code2_stockid) and yuzey_code2_stockid eq get_hizmet.stock_id>selected style="font-weight:bold"</cfif>>#PRODUCT_NAME#</option>
                                </cfoutput>
                            </select>
                      	</div>
                 	</div>
                    <div class="form-group" id="boya_code1_">
                     	<label class="col col-4 col-xs-12">Oda İç Boya</label>
                    	<div class="col col-8 col-xs-12">
                         	<select name="boya_code1" id="boya_code1" style="height:20px">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_hizmet">
                                     <option value="#STOCK_ID#" <cfif len(boya_code1_stockid) and boya_code1_stockid eq get_hizmet.stock_id>selected style="font-weight:bold"</cfif>>#PRODUCT_NAME#</option>
                                </cfoutput>
                            </select>
                      	</div>
                 	</div>
					<div class="form-group" id="boya_code2_">
                     	<label class="col col-4 col-xs-12">Oda Dış Boya</label>
                    	<div class="col col-8 col-xs-12">
                         	<select name="boya_code2" id="boya_code2" style="height:20px">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_hizmet">
                                    <option value="#STOCK_ID#" <cfif len(boya_code2_stockid) and boya_code2_stockid eq get_hizmet.stock_id>selected style="font-weight:bold"</cfif>>#PRODUCT_NAME#</option>
                                </cfoutput>
                            </select>
                      	</div>
                 	</div>
              	</div>      
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-12">
                    <cf_workcube_buttons is_upd='1' is_delete='0' add_function='kontrol()'> 
                </div>
            </cf_box_footer>
        </cfform> 
    </cf_box>
</div>
<script type="text/javascript">
	function kontrol()
	{
		return true;
	}
</script>