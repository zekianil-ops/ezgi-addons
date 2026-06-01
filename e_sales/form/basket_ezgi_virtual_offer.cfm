<!---
    File: basket_ezgi_virtual_offer.cfm
    Folder: Add_Ons\ezgi\e_sales\form
    Author: Ezgi Yazılım
    Date: 01/01/2022
    Description:
--->
<cfif get_virtual_offer_row.recordcount and len(get_virtual_offer_row.price_cat_id)>
	<cfparam name="attributes.price_cat_id"  default="#get_virtual_offer_row.price_cat_id#">
<cfelse>
	<cfparam name="attributes.price_cat_id"  default="">
</cfif>
<cf_box>
 	<cf_grid_list sort="1">
    	<thead>
        	<tr height="25">
        	    <cfoutput>
        	        <th nowrap width="55px" id="basket_header_add" style="text-align:center">
        	        	<cfif ListFind(session.ep.power_user_level_id,2188) and not attributes.kilit_stage>
        	      			<a href="javascript://" onClick="openProducts();"><img src="/images/plus_list.gif" border="0" id="basket_header_add" title="Ürün Ekle"></a>
        	            </cfif>
        	        </th>
        	        <th width="60px" style="display:none" id="bol_baslik"></th>
                    <th width="80px"><cf_get_lang dictionary_id="1276.Resimler"></th>
        	        <th width="85px"><cf_get_lang dictionary_id="57756.Durum"></th>
        	        <th width="35px"><cf_get_lang dictionary_id="99.Boy"></th>
        	        <th width="35px"><cf_get_lang dictionary_id="98.En"></th>
        	        <th width="35px"><cf_get_lang dictionary_id="45200.Derinlik"></th>
        	        <th width="35px"><cf_get_lang dictionary_id="50847.Taraf"></th>
        	        <th width="250px"><cf_get_lang dictionary_id="57564.Ürünler"></th>
        	        <th width="55px"><cf_get_lang dictionary_id="57635.Miktar"></th>
        	        <th width="55px" ><cf_get_lang dictionary_id="57636.Birim"></th>
        	        <cfif ListFind(session.ep.power_user_level_id,2188)>
                        <th width="25px" ></th>
        	        </cfif>
        	        <th width="25px" ></th>
        	        <cfif ListFind(session.ep.power_user_level_id,2188)>
                        <th width="60px" ><cf_get_lang dictionary_id="57638.Birim Fiyat"></th>
                        <th width="65px" ><cf_get_lang dictionary_id="51716.Hizmetler"></th>
                        <th width="55px" ><cf_get_lang dictionary_id="57677.Döviz"></th>
                        <th width="50px" ><cf_get_lang dictionary_id="57641.İskonto"></th>
                        <th width="25px" >
                            <input type="text" name="disc_1" id="disc_1" value="<cfoutput>#TlFormat(0,2)#</cfoutput>" class="boxtext" style="width:25px; text-align:center" onChange="top_disc(1)" <cfif (get_virtual_offer_row.recordcount and get_virtual_offer.max_rev_no gt 0) or attributes.kilit_stage>readonly="readonly"</cfif>>
                        </th>
                        <th width="25px" >
                            <input type="text" name="disc_2" id="disc_2" value="<cfoutput>#TlFormat(0,2)#</cfoutput>" class="boxtext" style="width:25px; text-align:center" onChange="top_disc(2)" <cfif (get_virtual_offer_row.recordcount and get_virtual_offer.max_rev_no gt 0) or attributes.kilit_stage>readonly="readonly"</cfif>>
                        </th>
                        <th width="25px" >
                            <input type="text" name="disc_3" id="disc_3" value="<cfoutput>#TlFormat(0,2)#</cfoutput>" class="boxtext" style="width:25px; text-align:center" onChange="top_disc(3)" <cfif (get_virtual_offer_row.recordcount and get_virtual_offer.max_rev_no gt 0) or attributes.kilit_stage>readonly="readonly"</cfif>>
                        </th>
                        <th width="25px" ><cf_get_lang dictionary_id="57639.KDV"></th>
        	        </cfif>
        	        <th width="25px"></th>
        	        <th><cf_get_lang dictionary_id="57629.Açıklama"></th>
        	        <cfif ListFind(session.ep.power_user_level_id,2188)>
        	        	<th width="60px" ><cf_get_lang dictionary_id="57397.Net Fiyat"></th>
        	            <th width="75px" ><cf_get_lang dictionary_id="29534.Toplam Tutar"></th>
        	            <th width="75px" >(#session.ep.money#) <cf_get_lang dictionary_id="57673.Tutar"></th>
        	        </cfif>
        	    </cfoutput>
        	</tr>
         </thead>
  		<tbody name="new_row" id="new_row">
         	<input type="hidden" name="gizle_goster" id="gizle_goster" value="0">
        	<input type="hidden" name="record_num" id="record_num" value="<cfoutput>#get_virtual_offer_row.recordcount#</cfoutput>">
        	<cfif get_virtual_offer_row.recordcount>
				<cfoutput query="get_virtual_offer_row">
        	    	<cfif OFFER_ID gt 0> <!---Gerçek Teklife Aktarıldıysa Satır Bazında Kilit Yapılıyor--->
						<cfset kilit = 1>
        	        <cfelseif OFFER_ID eq 0 and (VIRTUAL_OFFER_ROW_CURRENCY eq 4 or VIRTUAL_OFFER_ROW_CURRENCY eq 2)> <!---Teklife Aktarılmadı ve Teknik Onayda veya Onaylandı ise--->
        	            <cfset kilit = 2>
        	        <cfelse>
        	            <cfset kilit = 0>
        	        </cfif>
        	        <cfif (process_fuse eq 'upd' and get_virtual_offer_row.DELIVER_AMOUNT gt 0) or process_fuse eq 'add'>
        	            <cfset virtual_offer_lock = 1>
        	        <cfelse>
        	            <cfset virtual_offer_lock = 0>
        	        </cfif>
        	     	<input type="hidden" name="special_code#currentrow#" id="special_code#currentrow#" value="#PRODUCT_CODE_2#">
        	        <input type="hidden" value="1" name="row_kontrol#currentrow#">
        	        <input type="hidden" value="#ezgi_id#" name="ezgi_id#currentrow#">
        	        <input type="hidden" value="#wrk_row_relation_id#" name="WRK_ROW_RELATION_ID_#currentrow#">
        	        <tr height="80" id="frm_row#currentrow#">
        	            <td nowrap style="text-align:right;">
        	            	<cfif ListFind(session.ep.power_user_level_id,2188) and OFFER_ID lte 0 and not attributes.kilit_stage>
								<cfif get_virtual_offer.max_rev_no lte 0>
        	        				<a style="cursor:pointer" onclick="sil(#currentrow#);" >
                                    	<img src="/images/delete_list.gif" alt="<cf_get_lang_main no='1559.Satır Sil'>" title="<cf_get_lang_main no='1559.Satır Sil'>" border="0">
                                 	</a>
                              	</cfif>
                        	<cfelseif attributes.kilit_stage>
                             	<a style="cursor:pointer" onclick="satir_bol(#currentrow#);" >
                                  	<img src="/images/workflow_list.gif" alt="<cf_get_lang dictionary_id='62455.Satır Çoğalt'>" title="<cf_get_lang dictionary_id='62455.Satır Çoğalt'>" border="0">
                               	</a>
                        	</cfif>
        	                <cfif isdefined("attributes.virtual_offer_id")>
        	                    <cfif is_revision_small eq 0 and not attributes.kilit_stage>
        	                        <cfif VIRTUAL_OFFER_ROW_CURRENCY neq 3>
                                     	<a style="cursor:pointer" onclick="kopyala(#VIRTUAL_OFFER_ROW_ID#);" >
                                        	<img src="/images/copy_list.gif" alt="<cf_get_lang_main no='1560.Satır Kopyala'>" title="<cf_get_lang_main no='1560.Satır Kopyala'>" border="0">
                                     	</a> 
                                   	<cfelse>
                                      	<img src="/images/add_gray_mini.gif">
                                	</cfif>
                               	</cfif>
                           	</cfif>
                           	#currentrow#&nbsp;
        	            </td>
        	            <td style="display:none" id="bol_satir_#currentrow#">
        	            	<input type="text" name="bol_amount#currentrow#" id="bol_amount#currentrow#" value="#TlFormat(0,4)#" style="width:35px; text-align:right;" >
        	                <cfif AMOUNT gt 1 and FLOOR_ID eq 0 and VIRTUAL_OFFER_ROW_CURRENCY neq 3 and is_revision_small eq 0>
        	                    <a style="cursor:pointer" onclick="bol(#currentrow#,#VIRTUAL_OFFER_ROW_ID#);" >
        	                        <img src="/images/plus_thin_p.gif" alt="<cf_get_lang dictionary_id='60476.Böl'>" title="<cf_get_lang dictionary_id='60476.Böl'>" border="0">
                            	</a>
                          	</cfif>
        	            </td>
                        <td  nowrap style="text-align:center; cursor:pointer" onClick="windowopen('#request.self#?fuseaction=sales.popup_dsp_ezgi_virtual_offer_product_detail&pid=#product_id#&ezgi_id=#ezgi_id#','wide');">
							<cfif len(get_virtual_offer_row.PRODUCT_IMAGE)>
								<img src="/documents/product/#get_virtual_offer_row.PRODUCT_IMAGE#" alt="#product_name#" style="max-width:60px; max-height:60px;">
							<cfelse>
								<img src="/images/production/no-image.png" alt="#product_name#" style="max-width:60px; max-height:60px;">
							</cfif>
                        </td>
        	        	<td>
        	           		<select name="currency#currentrow#" id="currency#currentrow#" style="width:75px; height:20px">
        	                	<cfif OFFER_ID gt 0> <!---Gerçek Teklife Aktarıldıysa--->
        	                    	<option value="3" <cfif VIRTUAL_OFFER_ROW_CURRENCY eq 3>selected</cfif>><cf_get_lang dictionary_id='40941.İşlendi'></option>
        	                    <cfelse>
        	                        <option value="1" <cfif VIRTUAL_OFFER_ROW_CURRENCY eq 1>selected</cfif>><cf_get_lang dictionary_id='58717.Açık'></option>
        	                        <option value="4" <cfif VIRTUAL_OFFER_ROW_CURRENCY eq 4>selected</cfif>><cf_get_lang dictionary_id='41522.Son Onay'></option>
        	                       	<option value="2" <cfif VIRTUAL_OFFER_ROW_CURRENCY eq 2>selected</cfif>><cf_get_lang dictionary_id='30975.Onaylandı'></option>
        	                        <option value="9" <cfif VIRTUAL_OFFER_ROW_CURRENCY eq 9>selected</cfif>><cf_get_lang dictionary_id='58506.İptal'></option>
        	                   	</cfif>
        	              	</select>
        	         	</td>
        	            <td nowrap style="text-align:left;">
        	            	<input type="text" id="boy#currentrow#" name="boy#currentrow#" style="width:45px; text-align:right" value="#boy#" readonly=yes>
        	            </td>
        	            <td nowrap style="text-align:left;">
        	            	<input type="text" id="en#currentrow#" name="en#currentrow#" style="width:45px; text-align:right"  value="#en#" readonly=yes>
        	            </td>
        	            <td nowrap style="text-align:left;">
        	            	<input type="text" id="derinlik#currentrow#" name="derinlik#currentrow#" style="width:45px; text-align:right" value="#derinlik#" readonly=yes>
        	            </td>
        	            <td nowrap style="text-align:left;">
        	            	<cfif yon eq 1>
                            	<cfsavecontent variable="yon_"><cf_get_lang dictionary_id="82.Sağ"></cfsavecontent>
        	                <cfelseif yon eq 2>
        	                	<cfsavecontent variable="yon_"><cf_get_lang dictionary_id="85.Sol"></cfsavecontent>
        	              	<cfelseif yon eq 3>
        	                	<cfsavecontent variable="yon_"><cf_get_lang dictionary_id="1297.Dışa Sağ"></cfsavecontent>
        	               	<cfelseif yon eq 4>
        	                	<cfsavecontent variable="yon_"><cf_get_lang dictionary_id="1298.Dışa Sol"></cfsavecontent>
        	               	<cfelse>
        	                	<cfset yon_= ''>
        	                </cfif>
        	            	<input type="hidden" id="yon#currentrow#" name="yon#currentrow#" value="#yon#" >
        	                <input type="text" id="yon_#currentrow#" name="yon_#currentrow#" style="width:45px; text-align:center" value="#yon_#" readonly=yes>
        	            </td>
        	            <td nowrap style="text-align:left;">
        	                <input type="Hidden" name="stock_id#currentrow#" id="stock_id#currentrow#" value="#stock_id#">
        	                <input type="hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#product_id#">
        	                <input type="text" name="product_name#currentrow#" id="product_name#currentrow#" style=" width:96%" class="boxtext" value="#product_name#" <cfif kilit neq 1>readonly="readonly"</cfif>>
        	            	<input type="hidden" id="product_code#currentrow#" name="product_code#currentrow#" value="#stock_code#">
        	            </td>
        	            <td nowrap style="text-align:right;">
        	                <input type="text" name="quantity#currentrow#" id="quantity#currentrow#" value="#TlFormat(AMOUNT,4)#" style="width:55px; text-align:right;" onchange="hesapla(#currentrow#);" <cfif attributes.kilit_stage or virtual_offer_lock eq 1 or (virtual_offer_lock eq 0 and not ListFind(session.ep.power_user_level_id,2188))>readonly</cfif>>
        	            </td>
        	            <td nowrap style="text-align:left;">
        	                <input type="text" name="main_unit#currentrow#" id="main_unit#currentrow#" style="width:55px;" class="boxtext" value="#unit#">
        	            </td>
        	            <cfif ListFind(session.ep.power_user_level_id,2188)>
                            <td nowrap style="text-align:center;" title="">
                                <cfif isdefined('attributes.virtual_offer_id')>
                                    <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.popup_dsp_ezgi_virtual_cost&virtual_offer_row_id=#VIRTUAL_OFFER_ROW_ID#&stock_id=#STOCK_ID#','longpage');">
                                        <img src="images/money.gif" title="Maliyet" border="0" />
                                    </a>
                                </cfif>
                            </td>
        	            </cfif>
        	            <td nowrap style="text-align:center;">
        	          		<a href="javascript://" onClick="add_spect(#ezgi_id#,#kilit#,#SORT_NO#);">
        	                	<cfif isdefined('LAST_UPD_#get_virtual_offer_row.EZGI_ID#')>
        	                    	<cfif isdefined('LASTEST_UPD_#get_virtual_offer_row.EZGI_ID#')>
        	                        	<img id="sort_#SORT_NO#" src="images/start.gif" title="Spekt Oluştur" border="0" />
        	                        <cfelse>
        	                    		<img id="sort_#SORT_NO#" src="images/elements.gif" title="Spekt Oluştur" border="0" />
        	                        </cfif>
        	                    <cfelse>
        	                 		<img id="sort_#SORT_NO#" src="images/shema_list.gif" title="Spekt Oluştur" border="0" />
        	                  	</cfif>
        	             	</a>
        	            </td>
        	            <cfif ListFind(session.ep.power_user_level_id,2188)>
                            <td nowrap style="text-align:left;">
                                <input type="text" name="sales_price#currentrow#" id="sales_price#currentrow#" style="width:60px;text-align:right" class="boxtext" value="#TlFormat(sales_price,4)#" onchange="hesapla(#currentrow#);" <cfif get_virtual_offer.max_rev_no gt 0 or IS_TERAZI eq 1 or attributes.kilit_stage>readonly="readonly"</cfif>>
                            </td>
        	            <cfelse>
        	            	<input type="hidden" name="sales_price#currentrow#" id="sales_price#currentrow#" value="#TlFormat(sales_price,4)#">
        	            </cfif>
        	            <cfif ListFind(session.ep.power_user_level_id,2188)>
                            <td nowrap style="text-align:left;">
                                <input type="text" name="cost#currentrow#" id="cost#currentrow#" style="width:55px;text-align:right;<cfif hizmet eq 0>color:red</cfif>" class="boxtext" value="#TlFormat(hizmet,4)#" readonly onchange="hesapla(#currentrow#);">
                                <input type="hidden" name="old_cost#currentrow#" id="old_cost#currentrow#" value="#TlFormat(hizmet,4)#">
                                <cfif kilit neq 1> <!---Teklife Çevrilmemiş ise--->
                                    <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_virtual_cost&ezgi_id=#EZGI_ID#&row_money=#get_virtual_offer_row.money#&kilit_stage=#attributes.kilit_stage#','list');">
                                        <img src="images/plus_thin.gif" id="cost_pin">
                                    </a>
                                <cfelse>
                                    <img src="images/plus_thin.gif" id="cost_pin">
                                </cfif>
                            </td>
        	            <cfelse>
        	            	<input type="hidden" name="cost#currentrow#" id="cost#currentrow#" value="#TlFormat(cost,4)#">
        	            </cfif>
        	            <cfif ListFind(session.ep.power_user_level_id,2188)>
                            <td nowrap style="text-align:left;">
                                <select name="money#currentrow#" id="money#currentrow#" style="width:55px;" onchange="satir_doviz_hesapla(#currentrow#);">
                                    <cfloop query="get_money"><option value="#money#" <cfif get_virtual_offer_row.money eq get_money.money>selected</cfif>>#money#</option></cfloop>
                                </select>
                                <input type="hidden" value="#TlFormat(Evaluate('RATE2_#get_virtual_offer_row.money#'),4)#" id="row_rate2_#currentrow#" name="row_rate2_#currentrow#">
                                <input type="hidden" value="#get_virtual_offer_row.money#" name="old_money_#currentrow#" id="old_money_#currentrow#">
                                <input type="hidden" value="#TlFormat(Evaluate('RATE2_#get_virtual_offer_row.money#'),4)#" id="old_row_rate2_#currentrow#" name="old_row_rate2_#currentrow#">
                            </td>
        	            <cfelse>
        	                <input type="hidden" value="#get_virtual_offer_row.money#" id="money#currentrow#" name="money#currentrow#">
        	                <input type="hidden" value="#TlFormat(Evaluate('RATE2_#get_virtual_offer_row.money#'),4)#" id="row_rate2_#currentrow#" name="row_rate2_#currentrow#">
        	            </cfif>
        	            <cfif ListFind(session.ep.power_user_level_id,2188)>
        	            	<td nowrap style="text-align:right;">
        	                	<input type="text" name="discount_tut#currentrow#" id="discount_tut#currentrow#" style="width:50px; text-align:right" class="boxtext" value="#TlFormat(discount_tut,4)#" onchange="hesapla(#currentrow#);" <cfif get_virtual_offer.max_rev_no gt 0 or attributes.kilit_stage>readonly="readonly"</cfif>>
        	            	</td>
        	            <cfelse>
        	            	<input type="hidden" name="discount_tut#currentrow#" id="discount_tut#currentrow#" style="width:50px" value="#TlFormat(discount_tut,4)#">
        	            </cfif>
        	            <cfif ListFind(session.ep.power_user_level_id,2188)>
        	            	<td nowrap style="text-align:center;">
        	                	<input type="text" name="discount1_#currentrow#" id="discount1_#currentrow#" style="width:25px; text-align:center" class="boxtext" value="#TlFormat(discount1,2)#" onchange="hesapla(#currentrow#);" <cfif get_virtual_offer.max_rev_no gt 0 or attributes.kilit_stage>readonly="readonly"</cfif>>
        	            	</td>
        	            <cfelse>
        	            	<input type="hidden" name="discount1_#currentrow#" id="discount1_#currentrow#" value="#TlFormat(discount1,2)#">
        	            </cfif>
        	            <cfif ListFind(session.ep.power_user_level_id,2188)>
        	            	<td nowrap style="text-align:center;">
        	                	<input type="text" name="discount2_#currentrow#" id="discount2_#currentrow#" style="width:25px; text-align:center" class="boxtext" value="#TlFormat(discount2,2)#" onchange="hesapla(#currentrow#);" <cfif get_virtual_offer.max_rev_no gt 0 or attributes.kilit_stage>readonly="readonly"</cfif>>
        	            	</td>
        	            <cfelse>
        	            	<input type="hidden" name="discount2_#currentrow#" id="discount2_#currentrow#" value="#TlFormat(discount2,2)#">
        	            </cfif>
        	            <cfif ListFind(session.ep.power_user_level_id,2188)>
        	            	<td nowrap style="text-align:center;">
        	                	<input type="text" name="discount3_#currentrow#" id="discount3_#currentrow#" style="width:25px; text-align:center" class="boxtext" value="#TlFormat(discount3,2)#" onchange="hesapla(#currentrow#);" <cfif get_virtual_offer.max_rev_no gt 0 or attributes.kilit_stage>readonly="readonly"</cfif>>
        	            	</td>
        	            <cfelse>
        	            	<input type="hidden" name="discount3_#currentrow#" id="discount3_#currentrow#" value="#TlFormat(discount3,2)#">
        	            </cfif>
        	            <cfif ListFind(session.ep.power_user_level_id,2188)>
							<td nowrap style="text-align:center;">
        	               		<input type="text" name="tax#currentrow#" id="tax#currentrow#" style="width:25px; text-align:center" class="boxtext" value="#TlFormat(tax,0)#" onchange="hesapla(#currentrow#);" <cfif get_virtual_offer.max_rev_no gt 0 or attributes.kilit_stage>readonly="readonly"</cfif>>
        	            	</td>
        	            <cfelse>
        	            	<input type="hidden" name="tax#currentrow#" id="tax#currentrow#" value="#TlFormat(tax,0)#">
        	            </cfif>
        	            <td style="text-align:center">
        	            	<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_upd_ezgi_virtual_offer_row_floor_info&ezgi_id=#ezgi_id#&kilit=#kilit#','list');" style="text-align:center">
        	                 	<img src="images/plus_thin.gif" title="Detaylı Satır Açıklaması" border="0" />
        	             	</a>
        	           	</td>
        	            <td nowrap style="text-align:left;" title="#PRODUCT_NAME2#">
        	                <input type="text" name="detail#currentrow#" style="width:96%;" value="#PRODUCT_NAME2#">
        	            </td>
                        <cfif attributes.is_cost_discount eq 1>
							<cfset row_net_other_ = sales_price-discount_tut>
                            <cfset row_net_other_ = row_net_other_-(row_net_other_*discount1/100)>
                            <cfset row_net_other_ = row_net_other_-(row_net_other_*discount2/100)>
                            <cfset row_net_other_ = row_net_other_-(row_net_other_*discount3/100)>
                            <cfset row_net_other_ = row_net_other_+cost>
        	            <cfelse>
                        	<cfset row_net_other_ = sales_price+cost-discount_tut>
                           	<cfset row_net_other_ = row_net_other_-(row_net_other_*discount1/100)>
                         	<cfset row_net_other_ = row_net_other_-(row_net_other_*discount2/100)>
                          	<cfset row_net_other_ = row_net_other_-(row_net_other_*discount3/100)>
                        </cfif>
        	            <cfif ListFind(session.ep.power_user_level_id,2188)>
                            <td nowrap style="text-align:left;">
                                    <input type="text" name="row_net_other#currentrow#" id="row_net_other#currentrow#" style="width:60px;text-align:right" class="boxtext" value="#TlFormat(row_net_other_,4)#" readonly>
                            </td>
        	            <cfelse>
        	            	<input type="hidden" name="row_net_other#currentrow#" id="row_net_other#currentrow#" value="#TlFormat(row_net_other_,4)#">
        	            </cfif>
                        <cfif attributes.is_cost_discount eq 1>
							<cfset total_brut_other_ = (sales_price+cost)*quantity>
                            
                            <cfset total_net_other_ = sales_price*quantity>
                            <cfset total_net_other_ = total_net_other_-(discount_tut*quantity)>
                            <cfset total_net_other_ = total_net_other_-(total_net_other_*discount1/100)>
                            <cfset total_net_other_ = total_net_other_-(total_net_other_*discount2/100)>
                            <cfset total_net_other_ = total_net_other_-(total_net_other_*discount3/100)>
                            <cfset total_net_other_ = total_net_other_+(cost*quantity)>
        	            <cfelse>
                        	<cfset total_brut_other_ = (sales_price+hizmet)*quantity>
                            
                          	<cfset total_net_other_ = total_brut_other_-(discount_tut*quantity)>
                         	<cfset total_net_other_ = total_net_other_-(total_net_other_*discount1/100)>
                       		<cfset total_net_other_ = total_net_other_-(total_net_other_*discount2/100)>
                         	<cfset total_net_other_ = total_net_other_-(total_net_other_*discount3/100)>
                        </cfif>
        	        	<cfset total_tax_other_ = total_net_other_*tax/100>
        	            <cfif ListFind(session.ep.power_user_level_id,2188)>
        	                <td nowrap style="text-align:left;">
        	                    <input type="text" name="total_brut_other#currentrow#" id="total_brut_other#currentrow#" style="width:75px;text-align:right" class="boxtext" value="#TlFormat(total_brut_other_,4)#" readonly>
        	                </td>
        	            <cfelse>
        	            	<input type="hidden" name="total_brut_other#currentrow#" id="total_brut_other#currentrow#" value="#TlFormat(total_brut_other_,4)#">
        	            </cfif>
        	            <input type="hidden" name="total_tax_other#currentrow#" id="total_tax_other#currentrow#" value="#TlFormat(total_tax_other_,4)#">
        	         	<input type="hidden" name="total_net_other#currentrow#" id="total_net_other#currentrow#" value="#TlFormat(total_net_other_,4)#">
        	            <cfset total_brut_ = Evaluate('RATE2_#MONEY#')*total_brut_other_>
        	        	<cfset total_net_ = Evaluate('RATE2_#MONEY#')*total_net_other_>
        	         	<cfset total_tax_ = Evaluate('RATE2_#MONEY#')*total_tax_other_ >
        	            <cfif ListFind(session.ep.power_user_level_id,2188)>
        	                <td nowrap style="text-align:left;">
        	                    <input type="text" name="total_brut#currentrow#" id="total_brut#currentrow#" style="width:75px;text-align:right" class="boxtext" value="#TlFormat(total_brut_,4)#" readonly>
        	                </td>
        	            <cfelse>
        	            	<input type="hidden" name="total_brut#currentrow#" id="total_brut#currentrow#" value="#TlFormat(total_brut_,4)#">
        	            </cfif>
        	            <input type="hidden" name="total_tax#currentrow#" id="total_tax#currentrow#" value="#TlFormat(total_tax_,4)#">
        	         	<input type="hidden" name="total_net#currentrow#" id="total_net#currentrow#" value="#TlFormat(total_net_,4)#">
        	            <input type="hidden" name="purchase_price#currentrow#" id="purchase_price#currentrow#" value="#TlFormat(purchase_price_,4)#">
        	            <input type="hidden" name="cost_price#currentrow#" id="cost_price#currentrow#" value="#TlFormat(cost_price_,4)#">
        	            <input type="hidden" name="purchase_price_money#currentrow#" id="purchase_price_money#currentrow#" value="#purchase_price_money_#">
        	            <input type="hidden" name="cost_price_money#currentrow#" id="cost_price_money#currentrow#" value="#cost_price_money_#">
        	            <input type="hidden" name="p_purchase_price#currentrow#" id="p_purchase_price#currentrow#" value="#TlFormat(p_purchase_price,4)#">
        	            <input type="hidden" name="p_purchase_price_money#currentrow#" id="p_purchase_price_money#currentrow#" value="#p_purchase_price_money#">
        	            <input type="hidden" name="p_discount_1_#currentrow#"  id="p_discount_1_#currentrow#" value="#TlFormat(P_DISCOUNT_1,2)#">
        	            <input type="hidden" name="p_discount_2_#currentrow#"  id="p_discount_2_#currentrow#" value="#TlFormat(P_DISCOUNT_2,2)#">
        	            <input type="hidden" name="p_discount_3_#currentrow#"  id="p_discount_3_#currentrow#" value="#TlFormat(P_DISCOUNT_3,2)#">
        	            <input type="hidden" name="p_discount_4_#currentrow#"  id="p_discount_4_#currentrow#" value="#TlFormat(P_DISCOUNT_4,2)#">
        	            <input type="hidden" name="p_discount_5_#currentrow#"  id="p_discount_5_#currentrow#" value="#TlFormat(P_DISCOUNT_5,2)#">
                        <input type="hidden" name="price_cat_id#currentrow#"  id="price_cat_id#currentrow#" value="#PRICE_CAT_ID_#">
        	        </tr>
        	    </cfoutput>
        	</cfif>
       	</tbody>
   	</cf_grid_list>
</cf_box>

<script type="text/javascript">
	var row_count = document.form_basket.record_num.value;
	function add_spect(ezgi_id,kilit,sira_no)
	{
		<cfif isdefined("attributes.virtual_offer_id")>
			if(kilit > 0)
			  	windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_upd_ezgi_virtual_offer_row_spect&kilit_stage=#attributes.kilit_stage#</cfoutput>&ezgi_kilit='+kilit+'&<cfif get_virtual_offer.max_rev_no gt 0>revision=1&</cfif>ezgi_id='+ezgi_id,'longpage');
			else
				windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_upd_ezgi_virtual_offer_row_spect&kilit_stage=#attributes.kilit_stage#</cfoutput>&<cfif get_virtual_offer.max_rev_no gt 0>revision=1&</cfif>ezgi_id='+ezgi_id,'longpage');
		</cfif>
	}
	function openProducts()
	{
		if(document.getElementById('company_id').value <=0 && document.getElementById('consumer_id').value <=0)
		{
			alert('Önce Üye Seçimi Yapınız!');
			return false;
		}
		else
		windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_virtual_offer_product&price_catid=#attributes.price_cat_id#</cfoutput>&list_order_no=6,9&company_id='+document.getElementById('company_id').value+'&consumer_id='+document.getElementById('consumer_id').value,'wide');
	}
	function change_row(stock_id,product_name,product_code,product_code_2,main_unit,product_id,sales_price,money,boy,en,derinlik,satir_no)
	{
		document.getElementById('stock_id'+satir_no).value = stock_id;
		document.getElementById('product_name'+satir_no).value = product_name;
		document.getElementById('product_code'+satir_no).value = product_code;
		document.getElementById('special_code'+satir_no).value = special_code;
		document.getElementById('main_unit'+satir_no).value = main_unit;
		document.getElementById('product_id'+satir_no).value = product_id;
		document.getElementById('boy'+satir_no).value = boy;
		document.getElementById('en'+satir_no).value = en;
		document.getElementById('derinlik'+satir_no).value = derinlik;
		document.getElementById('link_param'+satir_no).value = link_param;
	}
	function add_row(stock_id,product_name,product_code,special_code,main_unit,product_id,sales_price,money,boy,en,derinlik,purchase_price,purchase_price_money,cost_price,cost_price_money,tax,price_cat_id,disc1,disc2,disc3,quantity,virtual_offer_import_row_id)
	{
		if(document.getElementById('is_foreign').checked==true)
			tax = 0;
		if(money =='')
			money = <cfoutput>'#session.ep.money#'</cfoutput>;
		row_count++;
		var newRow;
		var newCell;
		newRow = document.getElementById("new_row").insertRow(document.getElementById("new_row").rows.length);
		newRow.className = 'color-row';
		newRow.style.height = '80px';
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);
		newRow.setAttribute("NAME","frm_row" + row_count);
		newRow.setAttribute("ID","frm_row" + row_count);
		document.form_basket.record_num.value = row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang_main no='51.Sil'>" border="0"></a>'+row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute("nowrap","nowrap");
		newCell.innerHTML = '';
			
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute("nowrap","nowrap");
		newCell.innerHTML = '<select name="currency' + row_count +'" id="currency' + row_count +'" style="width:75px;"><option value="1">Açık</option></select>';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="boy' + row_count + '" style="width:45px;text-align:right" value="'+boy+'">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="en' + row_count + '" style="width:45px;text-align:right" value="'+en+'">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="derinlik' + row_count + '" style="width:45px;text-align:right" value="'+derinlik+'">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="yon' + row_count + '" style="width:55px;text-align:right" value="">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="Hidden" name="virtual_offer_import_row_id'+row_count+'" id="virtual_offer_import_row_id'+row_count+'" value="' + virtual_offer_import_row_id + '">';
		newCell.innerHTML = newCell.innerHTML + '<input type="Hidden" name="stock_id'+row_count+'" id="stock_id'+row_count+'" value="' + stock_id + '">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="product_id'+row_count+'" id="product_id'+row_count+'" value="'+product_id+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="text" name="product_name' + row_count + '" style="width:96%;" readonly="readonly" value="'+product_name+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="product_code' + row_count + '" value="'+product_code+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="special_code' + row_count + '" value="'+special_code+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="purchase_price' + row_count + '" value="'+commaSplit(purchase_price,4)+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="purchase_price_money' + row_count + '" value="'+purchase_price_money+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="cost_price' + row_count + '" value="'+commaSplit(cost_price,4)+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="cost_price_money' + row_count + '" value="'+cost_price_money+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="price_cat_id' + row_count + '" value="'+price_cat_id+'">';

		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="quantity' + row_count +'" name="quantity' + row_count +'" value="'+quantity+'" style="width:55px; text-align:right;" onchange="hesapla('+row_count+');">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="main_unit' + row_count + '" style="width:55px;" class="boxtext" value="'+main_unit+'">';
		
		<cfif ListFind(session.ep.power_user_level_id,2188)>
			newCell = newRow.insertCell(newRow.cells.length);

			newCell.setAttribute('nowrap','nowrap');
			newCell.innerHTML = '';
		</cfif>
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="sales_price' + row_count + '" id="sales_price' + row_count + '" style="width:60px;text-align:right" class="boxtext" value="'+ commaSplit(sales_price,4) +'" onchange="hesapla('+row_count+');"><input type="hidden" value="1" id="row_rate2_'+ row_count +'" name="row_rate2_'+ row_count +'"><input type="hidden" value="<cfoutput>#session.ep.money#</cfoutput>" name="old_money_'+ row_count +'" id="old_money_'+ row_count +'"><input type="hidden" value="<cfoutput>#TlFormat(0,4)#</cfoutput>" id="old_row_rate2_'+ row_count +'" name="old_row_rate2_'+ row_count +'">';
		
		<cfif ListFind(session.ep.power_user_level_id,2188)>
			newCell = newRow.insertCell(newRow.cells.length);
			newCell.setAttribute('nowrap','nowrap');
			newCell.innerHTML = '<input type="text" name="cost' + row_count + '" id="cost' + row_count + '" style="width:55px;text-align:right" class="boxtext" value="<cfoutput>#TlFormat(0,4)#</cfoutput>" onchange="hesapla('+row_count+');"><input type="hidden" name="old_cost' + row_count + '" id="old_cost' + row_count + '" value="<cfoutput>#TlFormat(0,4)#</cfoutput>">';
		</cfif>
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="money' + row_count + '" id="money' + row_count + '" style="width:50px;text-align:left" value="'+money+'" >';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="discount_tut' + row_count + '" id="discount_tut' + row_count + '" style="width:50px;text-align:right" class="boxtext" value="0,00" onchange="hesapla('+row_count+');">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="discount1_' + row_count + '" id="discount1_' + row_count + '" style="width:25px;text-align:center" class="boxtext" value="'+disc1+'" onchange="hesapla('+row_count+');">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="discount2_' + row_count + '" id="discount2_' + row_count + '" style="width:25px;text-align:center" class="boxtext" value="'+disc2+'" onchange="hesapla('+row_count+');">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="discount3_' + row_count + '" id="discount3_' + row_count + '" style="width:25px;text-align:center" class="boxtext" value="'+disc3+'" onchange="hesapla('+row_count+');">';
		

		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="tax' + row_count + '" id="tax' + row_count + '" style="width:25px;text-align:center" class="boxtext" value="'+tax+'" onchange="hesapla('+row_count+');">';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="detail' + row_count + '" style="width:96%;" maxlength="150" value="">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="row_net_other' + row_count + '" id="row_net_other' + row_count + '" value="0" style="width:65px;text-align:right" class="boxtext" readonly>';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="total_brut_other' + row_count + '" id="total_brut_other' + row_count + '" value="0" style="width:75px;text-align:right" class="boxtext" readonly><input type="hidden" name="total_net_other' + row_count + '" id="total_net_other' + row_count + '" value="0"><input type="hidden" name="total_tax_other' + row_count + '" id="total_tax_other' + row_count + '" value="0">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="total_brut' + row_count + '" id="total_brut' + row_count + '" value="0" style="width:75px;text-align:right" class="boxtext" readonly><input type="hidden" name="total_net' + row_count + '" id="total_net' + row_count + '" value="0"><input type="hidden" name="total_tax' + row_count + '" id="total_tax' + row_count + '" value="0">';
	hesapla(row_count);
	sub_total();
		
	}
	function sil(sy)
	{
		sil_sor = confirm('Teklif Satırını Siliyorsunuz Emin misiniz?');
		if(sil_sor == 1)
		{
			var element=eval("form_basket.row_kontrol"+sy);
			element.value=0;
			var element=eval("frm_row"+sy); 
			element.style.display="none";	
			document.getElementById('total_net'+sy).value = 0;
			document.getElementById('total_brut'+sy).value = 0;
			document.getElementById('total_tax'+sy).value = 0;
			sub_total();
		}
		else
		{
			return false;

		}
	}
	function satir_bol(sy)
	{
		if(document.getElementById('bol_baslik').style.display==='none')
		{
			for (var r=1;r<=document.form_basket.record_num.value;r++)
			{
				document.getElementById('bol_satir_'+r).style.display='';
			}
			document.getElementById('bol_baslik').style.display='';
		}
		else
		{
			for (var r=1;r<=document.form_basket.record_num.value;r++)
			{
				document.getElementById('bol_satir_'+r).style.display='none';
			}
			document.getElementById('bol_baslik').style.display='none';
		}
	}
	function bol(sy,virtualofferid)
	{
		<cfif isdefined("attributes.virtual_offer_id")>
			if(parseFloat(filterNum(document.getElementById('bol_amount'+sy).value,4))==0.00)
			{
				alert('Bölünecek Miktar Sıfırdan Büyük Olmalıdır');
				return false;
			}
			else if(parseFloat(filterNum(document.getElementById('bol_amount'+sy).value,4))<parseFloat(filterNum(document.getElementById('quantity'+sy).value,4)))
			{
				bol_sor = confirm('Teklifin Satırını Bölüyorsunuz !');
				if(bol_sor==true)
					window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_cpy_ezgi_virtual_offer_row&virtual_offer_id=#attributes.virtual_offer_id#</cfoutput>&virtual_offer_row_id="+virtualofferid+"&satir_bol="+document.getElementById('bol_amount'+sy).value;
				else
					return false;
			}
			else
			{
				alert('Bölünecek Miktar Satır Miktarından Küçük Olmalıdır');
				return false;
			}
		</cfif>
	}
	function kopyala(sy)
	{
		<cfif isdefined("attributes.virtual_offer_id")>
			kopyala_sor = confirm('Teklifin Satırını Kopyalıyorsunuz !');
			if(kopyala_sor==true)
				window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_cpy_ezgi_virtual_offer_row&virtual_offer_id=#attributes.virtual_offer_id#</cfoutput>&virtual_offer_row_id="+sy;
			else
				return false;
		</cfif>
	}
	function hesapla(row)
	{
		if(document.getElementById('is_cost_discount').checked==true)
		{
			document.getElementById('row_net_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('sales_price'+row).value,4)) - parseFloat(filterNum(document.getElementById('discount_tut'+row).value,2)),4);
	
			document.getElementById('row_net_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('row_net_other'+row).value,4)) - (parseFloat(filterNum(document.getElementById('row_net_other'+row).value,4))*parseFloat(filterNum(document.getElementById('discount1_'+row).value,2))/100),4);
			
			document.getElementById('row_net_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('row_net_other'+row).value,4)) - (parseFloat(filterNum(document.getElementById('row_net_other'+row).value,4))*parseFloat(filterNum(document.getElementById('discount2_'+row).value,2))/100),4);
			
			document.getElementById('row_net_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('row_net_other'+row).value,4)) - (parseFloat(filterNum(document.getElementById('row_net_other'+row).value,4))*parseFloat(filterNum(document.getElementById('discount3_'+row).value,2))/100),4);
			
			document.getElementById('row_net_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('row_net_other'+row).value,4)) + parseFloat(filterNum(document.getElementById('cost'+row).value,4)),4);
		}
		else
		{
			document.getElementById('row_net_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('sales_price'+row).value,4)) + parseFloat(filterNum(document.getElementById('cost'+row).value,4)) - parseFloat(filterNum(document.getElementById('discount_tut'+row).value,4)),4);

			document.getElementById('row_net_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('row_net_other'+row).value,4)) - (parseFloat(filterNum(document.getElementById('row_net_other'+row).value,4))*parseFloat(filterNum(document.getElementById('discount1_'+row).value,2))/100),4);
		
			document.getElementById('row_net_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('row_net_other'+row).value,4)) - (parseFloat(filterNum(document.getElementById('row_net_other'+row).value,4))*parseFloat(filterNum(document.getElementById('discount2_'+row).value,2))/100),4);
		
			document.getElementById('row_net_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('row_net_other'+row).value,4)) - (parseFloat(filterNum(document.getElementById('row_net_other'+row).value,4))*parseFloat(filterNum(document.getElementById('discount3_'+row).value,2))/100),4);
		}
		
		if(document.getElementById('is_cost_discount').checked==true)
		{
			document.getElementById('total_net'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('sales_price'+row).value,4)) * parseFloat(filterNum(document.getElementById('quantity'+row).value,4)) * parseFloat(filterNum(document.getElementById('row_rate2_'+row).value,4)),4);
	
			document.getElementById('total_net'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,4)) - (parseFloat(filterNum(document.getElementById('discount_tut'+row).value,4)) * parseFloat(filterNum(document.getElementById('quantity'+row).value,4)) * parseFloat(filterNum(document.getElementById('row_rate2_'+row).value,4))),4);
	
			document.getElementById('total_net'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,4)) - (parseFloat(filterNum(document.getElementById('total_net'+row).value,4))*parseFloat(filterNum(document.getElementById('discount1_'+row).value,2))/100),4);
			
			document.getElementById('total_net'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,4)) - (parseFloat(filterNum(document.getElementById('total_net'+row).value,4))*parseFloat(filterNum(document.getElementById('discount2_'+row).value,2))/100),4);
			
			document.getElementById('total_net'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,4)) - (parseFloat(filterNum(document.getElementById('total_net'+row).value,4))*parseFloat(filterNum(document.getElementById('discount3_'+row).value,2))/100),4);
			
			document.getElementById('total_net'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,4)) + (parseFloat(filterNum(document.getElementById('cost'+row).value,4)) * parseFloat(filterNum(document.getElementById('quantity'+row).value,4)) * parseFloat(filterNum(document.getElementById('row_rate2_'+row).value,4))),4);
		}
		else
		{
			document.getElementById('total_net'+row).value = commaSplit((parseFloat(filterNum(document.getElementById('sales_price'+row).value,4)) + parseFloat(filterNum(document.getElementById('cost'+row).value,4))) * parseFloat(filterNum(document.getElementById('quantity'+row).value,4)) * parseFloat(filterNum(document.getElementById('row_rate2_'+row).value,4)),4);

			document.getElementById('total_net'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,4)) - (parseFloat(filterNum(document.getElementById('discount_tut'+row).value,4)) * parseFloat(filterNum(document.getElementById('quantity'+row).value,4)) * parseFloat(filterNum(document.getElementById('row_rate2_'+row).value,4))),4);
		
			document.getElementById('total_net'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,4)) - (parseFloat(filterNum(document.getElementById('total_net'+row).value,4))*parseFloat(filterNum(document.getElementById('discount1_'+row).value,2))/100),4);
				
			document.getElementById('total_net'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,4)) - (parseFloat(filterNum(document.getElementById('total_net'+row).value,4))*parseFloat(filterNum(document.getElementById('discount2_'+row).value,2))/100),4);
				
			document.getElementById('total_net'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,4)) - (parseFloat(filterNum(document.getElementById('total_net'+row).value,4))*parseFloat(filterNum(document.getElementById('discount3_'+row).value,2))/100),4);
		}
		
		document.getElementById('total_tax'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,4)*document.getElementById('tax'+row).value/100),4);
		document.getElementById('total_brut'+row).value = commaSplit((parseFloat(filterNum(document.getElementById('sales_price'+row).value,4))+parseFloat(filterNum(document.getElementById('cost'+row).value,4)))*parseFloat(filterNum(document.getElementById('quantity'+row).value,4))*parseFloat(filterNum(document.getElementById('row_rate2_'+row).value,4)),4);
		
		document.getElementById('total_brut_other'+row).value = commaSplit((parseFloat(filterNum(document.getElementById('sales_price'+row).value,4))+parseFloat(filterNum(document.getElementById('cost'+row).value,4)))*parseFloat(filterNum(document.getElementById('quantity'+row).value,4)),4);
		sub_total();
	}
	function sub_total()
	{
		document.getElementById('sub_total_brut').value = 0;
		document.getElementById('sub_total_net').value = 0;
		document.getElementById('sub_total_tax').value = 0;
		document.getElementById('sub_total_brut_other').value = 0;
		document.getElementById('sub_total_net_other').value = 0;
		document.getElementById('sub_total_tax_other').value = 0;
		for (var r=1;r<=document.form_basket.record_num.value;r++)
		{
			document.getElementById('sub_total_brut').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_brut').value,4))+parseFloat(filterNum(document.getElementById('total_brut'+r).value,4)),4);
			document.getElementById('sub_total_net').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_net').value,4))+parseFloat(filterNum(document.getElementById('total_net'+r).value,4)),4);
			document.getElementById('sub_total_discount').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_brut').value,4))-parseFloat(filterNum(document.getElementById('sub_total_net').value,4)),4);
			document.getElementById('sub_total_tax').value =  commaSplit(parseFloat(filterNum(document.getElementById('sub_total_tax').value,4))+parseFloat(filterNum(document.getElementById('total_tax'+r).value,4)),4);
			document.getElementById('sub_total_end').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_net').value,4))-parseFloat(filterNum(document.getElementById('sub_total_discount_ext').value,4))+ parseFloat(filterNum(document.getElementById('sub_total_tax').value,4)),4);
			
			document.getElementById('sub_total_brut_other').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_brut').value,4))/parseFloat(filterNum(document.getElementById('virtual_offer_rate2').value,4)),4);
			document.getElementById('sub_total_net_other').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_net').value,4))/parseFloat(filterNum(document.getElementById('virtual_offer_rate2').value,4)),4);
			document.getElementById('sub_total_discount_other').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_discount').value,4))/parseFloat(filterNum(document.getElementById('virtual_offer_rate2').value,4)),4);
			document.getElementById('sub_total_tax_other').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_tax').value,4))/parseFloat(filterNum(document.getElementById('virtual_offer_rate2').value,4)),4);
			document.getElementById('sub_total_end_other').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_end').value,4))/parseFloat(filterNum(document.getElementById('virtual_offer_rate2').value,4)),4);
		}
		if(parseFloat(filterNum(document.getElementById('sub_total_discount').value,2)) >0 && parseFloat(filterNum(document.getElementById('sub_total_brut').value,2))>0)
			document.getElementById('son_oran').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_discount').value,2))/parseFloat(filterNum(document.getElementById('sub_total_brut').value,2))*100,2);

	}
	function satir_doviz_hesapla(currentrow)
	{
		row_money = document.getElementById('money'+currentrow).value;
		<cfif isdefined('attributes.virtual_offer_id')>
			<cfoutput query="get_virtual_offer_money">
				money_type = '#get_virtual_offer_money.money_type#';
				money_currentrow = #get_virtual_offer_money.currentrow#
				money_rate2 = #get_virtual_offer_money.rate2#
				if(row_money==money_type)
				{
					document.getElementById('sales_price'+currentrow).value=commaSplit(parseFloat(filterNum(document.getElementById('sales_price'+currentrow).value,4))/money_rate2*parseFloat(filterNum(document.getElementById('row_rate2_'+currentrow).value,4)),4);
					document.getElementById('cost'+currentrow).value=commaSplit(parseFloat(filterNum(document.getElementById('cost'+currentrow).value,4))/money_rate2*parseFloat(filterNum(document.getElementById('row_rate2_'+currentrow).value,4)),4);
					document.getElementById('old_row_rate2_'+currentrow).value=document.getElementById('row_rate2_'+currentrow).value;
					document.getElementById('old_cost'+currentrow).value=document.getElementById('cost'+currentrow).value;
					document.getElementById('old_money_'+currentrow).value=document.getElementById('money'+currentrow).value;
					document.getElementById('row_rate2_'+currentrow).value=document.getElementById('money_'+money_currentrow).value;
				}
			</cfoutput>
		<cfelse>
			<cfoutput query="get_money">
				money_type = '#get_money.money#';
				money_currentrow = #get_money.currentrow#
				if(row_money==money_type)
				{
					document.getElementById('row_rate2_'+currentrow).value=document.getElementById('money_'+money_currentrow).value;
				}
			</cfoutput>
		</cfif>
		hesapla(currentrow);
	}
	function gizle_goster()
	{
		if(document.getElementById('gizle_goster').value == 0)
		{
			document.getElementById('siparis_gizle').style.display='';
			document.getElementById('siparis_goster').style.display='none';
			document.getElementById('gizle_goster').value = 1;
			document.getElementById('b_depo').style.display='';
			document.getElementById('u_emir').style.display='';
			document.getElementById('a_sipa').style.display='';
			document.getElementById('s_stok').style.display='';
			for (var k=1;k<=paketsayisi;k++)
			{
				document.getElementById('p'+k).style.display='';
			}
			for (var r=1;r<=document.form_basket.record_num.value;r++)
			{
				document.getElementById('b_depo'+r).style.display='';
				document.getElementById('u_emir'+r).style.display='';
				document.getElementById('a_sipa'+r).style.display='';
				document.getElementById('s_stok'+r).style.display='';
				for (var k=1;k<=paketsayisi;k++)
				{
					document.getElementById('p'+k+'_'+r).style.display='';
				}
			}
		}
		else
		{
			document.getElementById('siparis_gizle').style.display='none';
			document.getElementById('siparis_goster').style.display='';
			document.getElementById('gizle_goster').value = 0;
			document.getElementById('b_depo').style.display='none';
			document.getElementById('u_emir').style.display='none';
			document.getElementById('a_sipa').style.display='none';
			document.getElementById('s_stok').style.display='none';
			for (var k=1;k<=paketsayisi;k++)
			{
				document.getElementById('p'+k).style.display='none';
			}
			for (var r=1;r<=document.form_basket.record_num.value;r++)
			{
				document.getElementById('b_depo'+r).style.display='none';

				document.getElementById('u_emir'+r).style.display='none';
				document.getElementById('a_sipa'+r).style.display='none';
				document.getElementById('s_stok'+r).style.display='none';
				for (var k=1;k<=paketsayisi;k++)
				{
					document.getElementById('p'+k+'_'+r).style.display='none';
				}
			}
		}
	}
	function top_disc(iskonto)
	{
		iskonto_oran = document.getElementById('disc_'+iskonto).value;
		for (var r=1;r<=document.form_basket.record_num.value;r++)
		{
			document.getElementById('discount'+iskonto+'_'+r).value = iskonto_oran;	
			hesapla(r);
		}
	}
	function yeniden_hesapla()
	{
		for (var r=1;r<=document.form_basket.record_num.value;r++)
		{
			hesapla(r);
		}
	}
</script>