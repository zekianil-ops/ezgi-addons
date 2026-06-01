<cfset total_brut_ = 0>
<cfset total_net_ = 0>
<cfset total_tax_ = 0>
<cf_box>
    <cf_box_elements>
        <cfinput type="hidden" name="old_price_catid" value="#attributes.price_catid#">
        <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true" style="margin-right: 15px !important;">
            <div class="form-group" id="item-order_date">
                <select name="price_catid" id="price_catid" style="width:200px;" onChange="price_change(0)">
                    <option value="-2"<cfif attributes.price_catid eq -2> selected</cfif>><cf_get_lang dictionary_id='58721.Standart Satış'></option>
                    <cfoutput query="get_price_cat"> 
                        <option value="#price_catid#"<cfif (price_catid is attributes.price_catid)> selected</cfif>>#price_cat#</option>
                    </cfoutput>
                </select>
            </div>
        </div>
        <cfif x_consumer_info neq 1>
            <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true" style="margin-right: 15px !important;">
                <div class="form-group" id="item-connect_head_2">
                    <input type="text" name="connect_head_2" id="connect_head_2" value="<cfoutput>#attributes.connect_head#</cfoutput>" maxlength="150" onChange="change_header_info();">
                </div>
            </div>
            <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true" style="margin-right: 0 !important;">
                <div class="form-group" id="item-detail_2">
                    <textarea name="detail_2" id="detail_2" style="width:height:30px;"  placeholder="Açıklama" onChange="change_header_info();"><cfoutput>#attributes.connect_detail#</cfoutput></textarea>  
                </div>
            </div>
        <cfelse>
            <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true"></div>
            <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true"></div>
        </cfif>
        <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
            <cfif get_offer_relations.recordcount>
                <div class="col col-12">
                    <span style="color:red; height:20px; text-align:center; vertical-align:middle"><cf_get_lang dictionary_id='51074.Teklife Dönüştürülenler'></span>	
                </div>
            </cfif>
        </div>    
    </cf_box_elements>
    <cf_box_footer>
        <div class="col col-12 col-xs-12" style="text-align:center">
            <div class="col col-2" style="height:100%; vertical-align:middle; display: flex; align-items: center;">
                <a href="javascript://" onClick="grupla();" style="text-decoration: none;">
                    <button type="button" name="basket_sil_" class="modern-delete-product-btn">
                        <i class="fa fa-trash"></i>
                        <cf_get_lang dictionary_id='50765.Ürün Sil'>
                    </button>
                </a>
            </div>
            <div class="col col-10">
                <cfif not get_offer_relations.recordcount>
                    <cf_workcube_buttons 
                        is_upd='1' 
                        add_function='kontrol()' 
                        is_delete='1'
                        del_function='sil_kontrol()'>
                </cfif>
            </div>
        </div>
    </cf_box_footer>
</cf_box>
<cf_box id="basket_bar"></cf_box>