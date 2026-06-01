<!---
    File: cpy_ezgi_product_tree_creative.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cf_xml_page_edit>
<cfquery name="get_money" datasource="#dsn2#">
	SELECT MONEY, RATE1, RATE2 FROM SETUP_MONEY WITH (NOLOCK)
</cfquery>
<cfloop query="get_money">
	<cfset 't1_fiyat#MONEY#' = 0>
</cfloop>
<cfset toplam = 0>
<cfset toplam_price = 0>
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK) ORDER BY COLOR_NAME
</cfquery>
<cfoutput query="get_colors">
	<cfset 'COLOR_NAME_#COLOR_ID#' = COLOR_NAME>
</cfoutput>
<cfquery name="get_all_stocks" datasource="#dsn3#">
	SELECT        
    	S.PRODUCT_NAME, 
        S.PRODUCT_CODE, 
        S.STOCK_ID,
        S.PRODUCT_ID, 
        S.PRODUCT_CATID,
        ISNULL((
        		SELECT   TOP (1)     
                	PS.PRICE * SM.RATE2 AS PRICE
				FROM            
                	#dsn1_alias#.PRICE_STANDART AS PS WITH (NOLOCK) INNER JOIN
                    #dsn2_alias#.SETUP_MONEY AS SM WITH (NOLOCK) ON PS.MONEY = SM.MONEY
				WHERE        
                	PS.PRICESTANDART_STATUS = 1 AND 
                    PS.PURCHASESALES = 0 AND 
                    PS.PRODUCT_ID = S.PRODUCT_ID
        		),0) AS PRICE
  		
	FROM            
    	STOCKS AS S INNER JOIN
    	PRODUCT_CAT ON S.PRODUCT_CATID = PRODUCT_CAT.PRODUCT_CATID
  	WHERE
    	S.PRODUCT_STATUS = 1
</cfquery>
<cfoutput query="get_all_stocks">
	<cfset 'PRICE_#STOCK_ID#' = PRICE>
</cfoutput>
<!---Tasarım Bilgisi Çekme--->
<cfquery name="get_design" datasource="#dsn3#">
	SELECT  * FROM EZGI_DESIGN WHERE DESIGN_ID = #attributes.design_id#
</cfquery>
<cfif get_design.IS_PROTOTIP eq 1>
	<cfsavecontent variable="isprototip"><cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'></cfsavecontent>
<cfelse>
	<cfsavecontent variable="isprototip"><cf_get_lang dictionary_id='913.Standart Ürün'></cfsavecontent>
</cfif>
<!---Tasarım Bilgisi Çekme--->
<!---Renk Bilgisi Çekme--->
<cfquery name="GET_OTHER_COLORS" datasource="#dsn3#">
	SELECT        
    	TBL.COLOR_ID AS PIECE_COLOR_ID, EZGI_COLORS.COLOR_NAME AS PIECE_COLOR_NAME
	FROM            
    	(
        	SELECT        
            	PIECE_COLOR_ID AS COLOR_ID
       		FROM            
            	EZGI_DESIGN_PIECE WITH (NOLOCK)
            WHERE        
               	PIECE_COLOR_ID IS NOT NULL AND 
                DESIGN_ID = #attributes.design_id#
         	UNION ALL
         	SELECT        
            	PACKAGE_COLOR_ID AS COLOR_ID
         	FROM            
            	EZGI_DESIGN_PACKAGE WITH (NOLOCK)
         	WHERE        
            	DESIGN_ID = #attributes.design_id#
         	UNION ALL
          	SELECT        
            	DESIGN_MAIN_COLOR_ID AS COLOR_ID
         	FROM            
            	EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
          	WHERE        
            	DESIGN_ID = #attributes.design_id#
       	) AS TBL INNER JOIN
    	EZGI_COLORS ON TBL.COLOR_ID = EZGI_COLORS.COLOR_ID
	GROUP BY 
    	TBL.COLOR_ID, 
        EZGI_COLORS.COLOR_NAME
</cfquery>
<!---Renk Bilgisi Çekme--->
<!---Hammadde Bilgisi Çekme--->
<cfquery name="get_raw_stock" datasource="#dsn3#">
	SELECT        
    	S.STOCK_ID, 
        S.PRODUCT_ID,
      	S.PRODUCT_NAME, 
      	S.PRODUCT_CODE,
        S.PRODUCT_CATID,
        ISNULL((
        		SELECT     
                	PRICE
               	FROM          
                	#dsn1_alias#.PRICE_STANDART WITH (NOLOCK)
             	WHERE      
                	PRODUCT_ID = S.PRODUCT_ID AND 
                    PRICESTANDART_STATUS = 1 AND 
                    PURCHASESALES = 0
        		),0) AS STANDART_ALIS,
      	(
        	SELECT     
        		MONEY
      		FROM          
            	#dsn1_alias#.PRICE_STANDART AS PRICE_STANDART_1 WITH (NOLOCK)
        	WHERE      
            	PRODUCT_ID = S.PRODUCT_ID AND 
                PRICESTANDART_STATUS = 1 AND 
                PURCHASESALES = 0
      	) AS STANDART_ALIS_MONEY,
        SUM(PIECE_AMOUNT) AS AMOUNT
	FROM            
    	(
        	SELECT        
            	PIECE_RELATED_ID, 
                PIECE_AMOUNT
         	FROM            
            	EZGI_DESIGN_PIECE WITH (NOLOCK)
          	WHERE        
            	DESIGN_ID = #attributes.design_id# AND 
                PIECE_TYPE = 4
        	UNION ALL
        	SELECT        
            	EDPR.STOCK_ID, 
                EDP.PIECE_AMOUNT * EDPR.AMOUNT AS AMOUNT
         	FROM            
            	EZGI_DESIGN_PIECE_ROW AS EDPR WITH (NOLOCK) INNER JOIN
             	EZGI_DESIGN_PIECE AS EDP WITH (NOLOCK) ON EDPR.PIECE_ROW_ID = EDP.PIECE_ROW_ID
         	WHERE        
            	EDPR.PIECE_ROW_ROW_TYPE IN (2,3) AND 
                EDP.DESIGN_ID = #attributes.design_id#
      	) AS TBL INNER JOIN
 		STOCKS AS S WITH (NOLOCK) ON TBL.PIECE_RELATED_ID = S.STOCK_ID
	GROUP BY 
    	S.PRODUCT_NAME, 
        S.PRODUCT_CODE, 
        S.STOCK_ID,
        S.PRODUCT_ID,
        S.PRODUCT_CATID
 	ORDER BY
    	S.PRODUCT_CODE
</cfquery>
<!---Hammadde Bilgisi Çekme--->
<cfsavecontent variable="message"><cf_get_lang dictionary_id='861.Tasarım Kopyala'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#message#">
    	<cfform name="add_same_design" method="post" action="#request.self#?fuseaction=prod.emptypopup_cpy_ezgi_product_tree_creative">
        	<cfinput type="hidden" name="old_design_id" value="#attributes.design_id#">
            <cfif isdefined('x_pvc_kalinlik_erkisi_arama')>
            	<cfinput type="hidden" name="x_pvc_kalinlik_erkisi_arama" value="#x_pvc_kalinlik_erkisi_arama#">
            </cfif>
        	<cf_basket_form id="upd_default_color">
                <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
                                    <div class="col col-6 col-md-12 col-sm-12 col-xs-12" type="column" index="1" sort="true">
                                    	<div class="col col-12">
                                            <div class="form-group" id="item-design_name">
                                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='43440.Tasarım Adı'> *</label>
                                                <div class="col col-4 col-xs-12">
                                                    <cfinput type="text" name="old_design_name" id="old_design_name" value="#get_design.design_name#" maxlength="50" readonly="yes">
                                                </div>
                                                <div class="col col-4 col-xs-12">
                                                    <cfinput type="text" name="new_design_name" id="new_design_name" value="#get_design.design_name#" maxlength="50">
                                                </div>
                                            </div>
                                      	</div>
										<div class="col col-12">
                                            <div class="form-group" id="item-color_name">
                                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='178.Tasarım Rengi'> *</label>
                                                <div class="col col-4 col-xs-12">
                                                    <cfinput type="text" name="old_design_color_name" id="old_design_color_name" value="#Evaluate('COLOR_NAME_#get_design.color_id#')#" maxlength="50" readonly="yes">
                                                    <cfinput type="hidden" name="old_design_color" id="old_design_color" value="#get_design.color_id#">
                                                </div>
                                                <div class="col col-4 col-xs-12">
                                                    <select name="new_design_color" id="new_design_color">
                                                        <option value="0"><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                        <cfoutput query="get_colors">
                                                            <option value="#COLOR_ID#" <cfif get_design.color_id eq COLOR_ID>style="font-weight:bold" selected</cfif>>#COLOR_NAME#</option>
                                                        </cfoutput>
                                                    </select>
                                                </div>
                                            </div>
                                     	</div>
                                        <div class="col col-12">
                                            <div class="form-group" id="item-design_type">
                                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='55288.Tasarım Tipi'> *</label>
                                                <div class="col col-4 col-xs-12">
                                                    <cfinput type="text" name="old_design_is_proto" id="old_design_is_proto" value="#isprototip#" maxlength="50" readonly="yes">
                                                    <cfinput type="hidden" name="old_design_is_prototype" id="old_design_is_prototype" value="#get_design.IS_PROTOTIP#">
                                                </div>
                                                <div class="col col-4 col-xs-12">
                                                    <select name="new_design_is_prototype" id="new_design_is_prototype">
                                                        <option value="0" <cfif get_design.IS_PROTOTIP neq 1>selected</cfif>><cf_get_lang dictionary_id='913.Standart Ürün'></option>
                                                        <option value="1" <cfif get_design.IS_PROTOTIP eq 1>selected</cfif>><cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'></option>
                                                    </select>
                                                </div>
                                            </div>
                                     	</div>
                                        <div class="col col-4 col-xs-12">
                                            <div class="form-group" id="item-check">
                                                <input type="checkbox" name="is_pvc_not_same" id="is_pvc_not_same" value="1" style="height:25px" checked /> <cf_get_lang dictionary_id='942.PVC Bulunamdı ise Aynı PVC Olsun'> 
                                            </div>
                                        </div>
                                        <div class="col col-4 col-xs-12">
                                            <div class="form-group" id="item-ortak">
                                            	<cfif get_design.PROCESS_ID eq 1>
                                                	<input type="checkbox" name="is_otak_parca" id="is_otak_parca" value="1" style="height:25px" checked /> <cf_get_lang dictionary_id='69.Workcube Bağlantılı Ortak Parça Olarak Kopyala'>
                                             	</cfif>
                                            </div>
                                        </div>
                                        <div class="col col-4 col-xs-12">
                                            <div class="form-group" id="item-bila">
                                         
                                            </div>
                                        </div>
                                  	</div>
                                	<div class="col col-6 col-md-12 col-sm-12 col-xs-12" type="column" index="1" sort="true">
                                    	<cfoutput query="GET_OTHER_COLORS">
                                            <div class="col col-12">
                                                <div class="form-group" >
                                                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36554.Renk'> - #currentrow# *</label>
                                                    <div class="col col-4 col-xs-12">
                                                        <cfinput type="text" name="old_design_color_name_#currentrow#" id="old_design_color_name_#currentrow#" value="#PIECE_COLOR_NAME#" maxlength="50" readonly="yes">
                                            			<cfinput type="hidden" name="old_design_color_#currentrow#" id="old_design_color_#currentrow#" value="#PIECE_COLOR_ID#" maxlength="50">
                                                    </div>
                                                    <div class="col col-4 col-xs-12">
                                                        <select name="new_design_color_#PIECE_COLOR_ID#" id="new_design_color_#PIECE_COLOR_ID#" style="width:190px; height:20px">
                                                            <option value="0"><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                            <cfloop query="get_colors">
                                                                <option value="#COLOR_ID#" <cfif GET_OTHER_COLORS.PIECE_COLOR_ID eq COLOR_ID>style="font-weight:bold" selected</cfif>>#COLOR_NAME#</option>
                                                            </cfloop>
                                                        </select>
                                                    </div>
                                                </div>
                                            </div>
                                        </cfoutput>
                                  	</div>
                                </cf_box_elements>
                                <cf_box_footer>
									<div class="col col-6 col-xs-12">
                                        <cf_workcube_buttons 
                                        	is_upd='0' 
                                            add_function='kontrol()'
                                            is_delete = '0'>
                                    </div>
                				</cf_box_footer>
                          	</div>
                  		</div>
              	</div>
         	</cf_basket_form>
            <cf_basket id="upd_default_color_bask">
            	<cf_flat_list sort="0">
                    <thead>
                        <tr>
                            <th style="text-align:center; width:30px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th style="text-align:center; width:40px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            <th style="text-align:center"><cf_get_lang dictionary_id='904.Kaynak Hammadde'></th>
                            <th style="text-align:center; width:100px"><cf_get_lang dictionary_id='58722.Standart Alış'></th>
                            <th style="text-align:center; width:50px"><cf_get_lang dictionary_id='57677.Döviz'></th>
                            <th style="text-align:center; width:50px"><cf_get_lang dictionary_id='57673.Tutar'></th>
                            <th style="text-align:center; width:400px"><cf_get_lang dictionary_id='905.Hedef Hammadde'></th>
                            <th style="text-align:center; width:100px"><cf_get_lang dictionary_id='58722.Standart Alış'></th>
                            <th style="text-align:center; width:50px"><cf_get_lang dictionary_id='57677.Döviz'></th>
                            <th style="text-align:center; width:50px"><cf_get_lang dictionary_id='57673.Tutar'></th>
						</tr>
                   	</thead>
                     <tbody>
                    	<cfif get_raw_stock.recordcount>
                    		<cfoutput query="get_raw_stock">
                            	<cfquery name="get_these_stocks" dbtype="query">
                                   	SELECT * FROM get_all_stocks WHERE PRODUCT_CATID = #PRODUCT_CATID# ORDER BY PRODUCT_NAME
                            	</cfquery>
                          		<tr height="25px"  id="raw_stocks_">
                                	<td style=" text-align:right">#currentrow#</td>
                                  	<td style=" text-align:right">#TlFormat(Amount,4)#</td>
                                  	<td>
                                     	<input type="text" name="old_design_product_name_#currentrow#" id="old_design_product_name_#currentrow#" value="#PRODUCT_NAME#" maxlength="50" style="width:100%;border:none" >
                                     	<cfinput type="hidden" name="old_design_stock_id_#currentrow#" id="old_design_stock_id_#currentrow#" value="#STOCK_ID#">
                                  	</td>
                                 	<td style=" text-align:right">#TlFormat(STANDART_ALIS,8)#</td>
                                   	<td style=" text-align:left">#STANDART_ALIS_MONEY#</td>
                                	<td style=" text-align:right">#TlFormat(STANDART_ALIS*Amount,2)#</td>
									<cfif isdefined('t1_fiyat#STANDART_ALIS_MONEY#') and get_raw_stock.STANDART_ALIS gt 0>
                                    	<cfset 't1_fiyat#STANDART_ALIS_MONEY#' = evaluate('t1_fiyat#STANDART_ALIS_MONEY#') + (get_raw_stock.STANDART_ALIS*get_raw_stock.Amount)>
                                   	</cfif> 
                                 	<td>
                                    	<select name="new_design_stock_id_#STOCK_ID#" id="new_design_stock_id_#currentrow#" style="width:100%; height:20px; border-style:none" onchange="change_raw(#currentrow#,#amount#);">
                                        	<option value="0"><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                         	<cfloop query="get_these_stocks">
                                           		<option value="#STOCK_ID#,#PRODUCT_NAME#,#get_these_stocks.PRICE#" <cfif get_raw_stock.STOCK_ID eq STOCK_ID>style="font-weight:bold" selected</cfif>>#PRODUCT_NAME#</option>
                                         	</cfloop>
                                     	</select>
                                	</td>
                                	<td style=" text-align:right">
                                    	<cfif isdefined('PRICE_#STOCK_ID#')>
                                        	<input type="text" id="price_#currentrow#" name="price_#currentrow#" style="width:95px; height:20px; border-color:silver; text-align:right" value="#TlFormat(Evaluate('PRICE_#STOCK_ID#'),8)#" onchange="hesapla_row(#currentrow#,#amount#);" />
                                     	<cfelse>
                                        	<input type="text" id="price_#currentrow#" name="price_#currentrow#" style="width:95px; height:20px; border-color:silver; text-align:right" value="#TlFormat(0,8)#" onchange="hesapla_row(#currentrow#,#amount#);" />
                                     	</cfif>
                                  	</td>
                               		<td style=" text-align:left">&nbsp;#session.ep.money#</td>
                                 	<td style=" text-align:right">
                                   		<cfif isdefined('PRICE_#STOCK_ID#')>
                                        	<input type="text" id="row_price_#currentrow#" name="row_price_#currentrow#" style="width:45px; height:20px; border-style:none; text-align:right" value="#TlFormat(Evaluate('PRICE_#STOCK_ID#')*Amount,2)#" readonly="readonly" />
                                       		<cfset toplam_price = toplam_price + (Evaluate('PRICE_#STOCK_ID#')*Amount)>
                                     	<cfelse>
                                        	<input type="text" id="row_price_#currentrow#" name="row_price_#currentrow#" style="width:45px; height:20px; border-style:none; text-align:right" value="#TlFormat(0,2)#" readonly="readonly" />
                                    	</cfif>
                                	</td>
                           		</tr>
                        	</cfoutput>
                       	</cfif>
                   	</tbody>
                    <tfoot>
                    	<tr>
                         	<td colspan="3" style=" text-align:right; height:20px;font-weight:bold"><cf_get_lang dictionary_id='57492.Toplam'>&nbsp;</td>
                           	<td style=" text-align:right;font-weight:bold">
                              	<cfoutput query="get_money">
									<cfif isdefined('t1_fiyat#MONEY#') and Evaluate('t1_fiyat#MONEY#') gt 0>
                                     	#TlFormat(Evaluate('t1_fiyat#MONEY#'),2)#
                                  		<cfset toplam = toplam + (Evaluate('t1_fiyat#MONEY#')*RATE2)>
                               		</cfif>      	            
                             	</cfoutput>
                       		</td>
                         	<td style=" text-align:left;font-weight:bold">
                             	<cfoutput query="get_money">
									<cfif isdefined('t1_fiyat#MONEY#') and Evaluate('t1_fiyat#MONEY#') gt 0>
                                     	&nbsp;#MONEY#<br />
                                 	</cfif>      	            
                             	</cfoutput>
                         	</td>
                          	<cfoutput>
                            	<td style=" text-align:right; font-weight:bold">#TlFormat(toplam,2)#&nbsp;</td>
                            	<td style=" text-align:left;font-weight:bold" colspan="3">&nbsp;</td>
                             	<td style=" text-align:right;font-weight:bold">
                                 	<input type="text" id="total_price" name="total_price" style="width:45px; height:20px; border-style:none; text-align:right; font-weight:bold" value="#TlFormat(toplam_price,2)#" readonly="readonly" />
                              	</td>
                        	</cfoutput>
                    	</tr>
                   </tfoot> 
              	</cf_flat_list>
            </cf_basket>
     	</cfform>
 	</cf_box>
</div>
<script type="text/javascript">
	function kontrol()
	{
		if(document.getElementById('old_design_name').value == document.getElementById('new_design_name').value)
		{
			if(document.getElementById('old_design_color').value == document.getElementById('new_design_color').value)	
			{
				alert('<cf_get_lang dictionary_id='181.Tasarım Kopyalamak İçin Tasarım Adı Veya Tasarım Rengi Farklı Olması Gerekir'> !');	
				return false;
			}
		}
		else
			return true;
	}
	function change_raw(sira,amount)
	{
		price=list_getat(document.getElementById('new_design_stock_id_'+sira).value,3);
		document.getElementById('price_'+sira).value = commaSplit(price,8);
		document.getElementById('row_price_'+sira).value = commaSplit(price*amount,2);
		hesapla();
	}
	function hesapla_row(sira,amount)
	{
		document.getElementById('row_price_'+sira).value = commaSplit(filterNum(document.getElementById('price_'+sira).value)*amount,2);	
		hesapla();
	}
	function hesapla()
	{
		toplam = 0;
		<cfloop query="get_raw_stock">
			<cfoutput>
				sira = #currentrow#;
			</cfoutput>
			toplam = toplam + filterNum(document.getElementById('row_price_'+sira).value,2)*1;
		</cfloop>
		document.getElementById('total_price').value = commaSplit(toplam,2);
	}
</script>