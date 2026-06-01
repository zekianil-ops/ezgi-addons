<!---
    File: list_ezgi_piece_row_calc.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset var_="upd_purchase_basket">
<cfparam name="attributes.urun" default="">
<cfparam name="attributes.stock_id" default="">
<cfparam name="attributes.pid" default="">
<cfparam name="attributes.rate" default="1">
<cfif len(attributes.stock_id)>
	<cfquery name="get_calc_content" datasource="#dsn3#">
    	SELECT 
        	SUM(AMOUNT) AS AMOUNT,
            STOCK_ID,
            PRODUCT_ID, 
            STOCK_CODE, 
            PRODUCT_NAME,
            (
            SELECT 
            	TOP (1)       
            	MAIN_UNIT
			FROM            
            	PRODUCT_UNIT
			WHERE        
            	PRODUCT_ID = TBL.PRODUCT_ID AND 
                IS_MAIN = 1
			) AS MAIN_UNIT
      	FROM
        	(
            SELECT        
                STOCK_ID2 AS STOCK_ID, 
                PRODUCT_ID,
                STOCK_CODE, 
                PRODUCT_NAME, 
                AMOUNT * AMOUNT2 * AMOUNT3 * AMOUNT4 * AMOUNT5 AS AMOUNT
            FROM           
                EZGI_PRODUCT_TREE_BOM1
            WHERE        
                STOCK_ID = #attributes.stock_id#
            ) AS TBL
     	GROUP BY
        	STOCK_ID,
            PRODUCT_ID, 
            STOCK_CODE, 
            PRODUCT_NAME
    </cfquery>
<cfelse>
	<cfset get_calc_content.recordcount =0>
</cfif>
<br />
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="title_"><cf_get_lang dictionary_id="182.Hizmet Hesaplayarak Ekle"></cfsavecontent>
	<cf_box title=#title_#>
    	<cfform name="add_piece_relation" id="add_piece_relation" method="post" action="#request.self#?fuseaction=prod.popup_list_ezgi_piece_row_calc">
            <cf_basket_form id="upd_default_piece">
                <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
                                	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                                        <div class="form-group" id="item-status">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="29410.Ürün Ekle"> *</label>
                                            <div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                    <cfsavecontent variable="message"><cf_get_lang dictionary_id="63587.Girilmesi Zorunlu Alan">!</cfsavecontent>
                                                    <input type="text" name="urun" id="urun" value="<cfoutput>#attributes.urun#</cfoutput>" style="width:280px; vertical-align:middle">
                                                    <input type="hidden" name="stock_id" id="stock_id" value="<cfoutput>#attributes.stock_id#</cfoutput>">
                                                    <input type="hidden" name="pid" id="pid" value="<cfoutput>#attributes.pid#</cfoutput>">
                                                    <cfinput type="hidden" name="design_piece_row_id" value="#attributes.design_piece_row_id#">
                                                    <span class="input-group-addon icon-ellipsis btnPoniter" onclick="relation_product_row();"></span>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-default_code">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58456.Oran'> *</label>
                                            <div class="col col-8 col-xs-12">
                                                <input type="text" name="rate" id="rate" value="<cfoutput>#attributes.rate#</cfoutput>" style="text-align:right">
                                            </div>
                                        </div>
                                   	</div>
                              	</cf_box_elements>
                                <br />
                    			<cf_box_footer>
                                	
									<cfsavecontent  variable="vazgeç"><cf_get_lang dictionary_id='57462.Vazgeç'></cfsavecontent>
                                    <cfinput type="button" value="#vazgeç#" name="cnc_buton" style="background-color:red" onClick="window.close();">&nbsp;
                                    <cfsavecontent  variable="hesapla"><cf_get_lang dictionary_id='58998.Hesapla'></cfsavecontent>
                                    <cfinput type="submit" value="#hesapla#" name="upd_buton">&nbsp;
                                    <cfif len(attributes.stock_id)>
                                        <input type="button" value="<cf_get_lang dictionary_id='44630.Ekle'>" onClick="grupla();">
                                    </cfif>
                				</cf_box_footer>
                			</div>
            			</div>
        		</div>
    		</cf_basket_form>
            <cf_box id="ezgi_list">
            	<cf_flat_list>
            		<thead>
                    	<tr>
                          	<th style="text-align:center;width:25px;cursor:pointer"><cf_get_lang dictionary_id="58577.Sıra"></th>
                          	<th style="text-align:center;width:90px;"><cf_get_lang dictionary_id="58800.Ürün Kodu"></th>
                         	<th style="text-align:center;width:350px;"><cf_get_lang dictionary_id="58221.Ürün Adı"></th>
                          	<th style="text-align:center;width:60px;"><cf_get_lang dictionary_id="57635.Miktar"></th>
                            <th style="text-align:center;width:40px;"><cf_get_lang dictionary_id="57636.Birim"></th>
                          	<th style="text-align:center;width:20px;">
                         		<input type="checkbox" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="grupla(-1);">
                    		</th>
                     	</tr>
                  	</thead>
                  	<tbody>
                     	<cfif get_calc_content.recordcount>
        					<cfoutput query="get_calc_content">
                            	<input type="hidden" id="product_name_#stock_id#" name="product_name_#stock_id#" value="#product_name#">
                              	<input type="hidden" id="product_id_#stock_id#" name="product_id_#stock_id#" value="#product_id#">
                              	<input type="hidden" id="MAIN_UNIT_#stock_id#" name="MAIN_UNIT_#stock_id#" value="#MAIN_UNIT#">
                              	<tr id="frm_row_exit#currentrow#">
                					<td style="text-align:right;vertical-align:middle;">#currentrow#</td>
                					<td nowrap>#STOCK_CODE#</td>
                					<td>#PRODUCT_NAME#</td>
                					<td style="text-align:right;">
                                    	<input type="text" name="amount_#stock_id#" id="amount_#stock_id#" value="#TlFormat(AMOUNT*Filternum(attributes.rate,2),8)#" style="width:75px; text-align:right">
                                   	</td>
                                    <td nowrap>#MAIN_UNIT#</td>
                					<td style="text-align:center;" nowrap>
                                   		<input type="checkbox" name="select_production" checked="checked" value="#stock_id#">
                                   	</td>
                				</tr>
                           	</cfoutput>
                    	</cfif>
                   	</tbody>
            	</cf_flat_list>
            </cf_box>
       	</cfform>
  	</cf_box>
</div>         
<script type="text/javascript">
	function relation_product_row(product_type, creative_id, satir_no)
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=5&product_id=add_piece_relation.pid&field_id=add_piece_relation.stock_id&field_name=add_piece_relation.urun",'list');
	}
	function add_ezgi_row(stock_id,product_name)
	{
		document.getElementById('urun').value = product_name;
		document.getElementById('stock_id').value = stock_id;
		document.getElementById("add_piece_relation").action = "<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_piece_row_calc</cfoutput>";
		document.getElementById("add_piece_relation").submit();
	}
	function grupla(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
			stock_id_list = '';
			chck_leng = document.getElementsByName('select_production').length;
			for(ci=0;ci<chck_leng;ci++)
			{
				var my_objets = document.all.select_production[ci];
				if(chck_leng == 1)
					var my_objets =document.all.select_production;
				if(type == -1)
				{//hepsini seç denilmişse	
					if(my_objets.checked == true)
						my_objets.checked = false;
					else
						my_objets.checked = true;
				}
				else
				{
					if(my_objets.checked == true)

						stock_id_list +=my_objets.value+',';
				}
			}
			stock_id_list = stock_id_list.substr(0,stock_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(stock_id_list!='')
			{
				document.getElementById("add_piece_relation").action = "<cfoutput>#request.self#?fuseaction=prod.emptypopup_add_ezgi_piece_row_calc</cfoutput>";
				document.getElementById("add_piece_relation").submit();
			}
	}
</script>