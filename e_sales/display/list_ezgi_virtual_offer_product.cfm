<cfset module_name="sales">
<cf_xml_page_edit>
<cfparam name="attributes.is_filter" default="0">
<cfparam name="attributes.product_cat" default=''>
<cfparam name="attributes.product_catid" default=''>
<cfparam name="attributes.category_name" default=''>
<cfparam name="attributes.search_company_id" default="">
<cfparam name="attributes.employee_id" default="">
<cfparam name="attributes.keyword" default=''>
<cfparam name="attributes.list_order_no" default="">
<cfparam name="attributes.unit" default="1">
<cfparam name="attributes.product_type" default="2">
<cfparam name="attributes.list_type" default="#x_list_type#">
<cfif attributes.is_filter>
	<cfinclude template="../query/get_ezgi_stocks.cfm">
    <cfset stock_id_list = ValueList(products.stock_id)>
<cfelse>
	<cfset PRODUCTS.recordcount = 0>
</cfif>
<cfif not isdefined('attributes.price_catid') or not len(attributes.price_catid)>
	<cfif (isdefined('attributes.company_id') and len(attributes.company_id)) or (isdefined('attributes.consumer_id') and len(attributes.consumer_id))>
        <cfif (isdefined('attributes.company_id') and len(attributes.company_id))>
            <cfquery name="get_c_cat_id" datasource="#dsn#">
                SELECT COMPANYCAT_ID FROM COMPANY WHERE COMPANY_ID = #attributes.company_id#
            </cfquery>
            <cfquery name="GET_PRICE_CAT" datasource="#DSN3#">
                SELECT 
                    PRICE_CAT_ID, 
                    PRICE_CAT
                FROM     
                    EZGI_VIRTUAL_OFFER_PRICE_LIST
                WHERE        
                    STATUS = 1 AND
                    COMPANY_CATS LIKE '%,#get_c_cat_id.COMPANYCAT_ID#,%'
                ORDER BY
        			PRICE_CAT_CODE
            </cfquery>
        </cfif>
        <cfif (isdefined('attributes.consumer_id') and len(attributes.consumer_id))>
            <cfquery name="get_c_cat_id" datasource="#dsn#">
                SELECT CONSUMER_CAT_ID FROM CONSUMER WHERE CONSUMER_ID = #attributes.consumer_id#
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
    <!---<cfparam name="attributes.price_catid"  default="#GET_PRICE_CAT.PRICE_CAT_ID#">--->
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
<cfquery name="get_cat" datasource="#dsn3#">
 	SELECT      
   		PRODUCT_CATID, 
    	HIERARCHY, 
    	PRODUCT_CAT
 	FROM            
   		PRODUCT_CAT
 	WHERE
     	PRODUCT_CATID IN 
     	(
          	SELECT        
             	PRODUCT_CATID
           	FROM            
            	PRODUCT
          	GROUP BY 
            	PRODUCT_CATID
     	)
     	<cfif isdefined('attributes.list_order_no') and len(attributes.list_order_no)>
        	AND  LIST_ORDER_NO IN (#attributes.list_order_no#)
     	</cfif>
  	ORDER BY
     	PRODUCT_CAT
</cfquery>
<cfquery name="get_discount_row" datasource="#dsn3#"> <!---Cari için İskonto Bilgileri Bulunuyor--->
	<cfif isdefined('attributes.company_id') and len(attributes.company_id)>
        SELECT   
            TOP (1)
            ISNULL(PRODUCT_ID,0) PRODUCT_ID,
            ISNULL(BRAND_ID,0) BRAND_ID,  
            ISNULL(PRODUCT_CATID,0) PRODUCT_CATID, 
            ISNULL(DISCOUNT_RATE,0) AS DISCOUNT_RATE_1, 
            ISNULL(DISCOUNT_RATE_2,0) AS DISCOUNT_RATE_2,
            ISNULL(DISCOUNT_RATE_3,0) AS DISCOUNT_RATE_3,
            ISNULL(DISCOUNT_RATE_4,0) AS DISCOUNT_RATE_4,
            ISNULL(DISCOUNT_RATE_5,0) AS DISCOUNT_RATE_5
        FROM        
            PRICE_CAT_EXCEPTIONS WITH (NOLOCK)
        WHERE     
            ACT_TYPE = 1 AND 
            COMPANY_ID = #attributes.company_id# 
 	<cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
    	SELECT   
            TOP (1)
            ISNULL(PRODUCT_ID,0) PRODUCT_ID,
            ISNULL(BRAND_ID,0) BRAND_ID,  
            ISNULL(PRODUCT_CATID,0) PRODUCT_CATID, 
            ISNULL(DISCOUNT_RATE,0) AS DISCOUNT_RATE_1, 
            ISNULL(DISCOUNT_RATE_2,0) AS DISCOUNT_RATE_2,
            ISNULL(DISCOUNT_RATE_3,0) AS DISCOUNT_RATE_3,
            ISNULL(DISCOUNT_RATE_4,0) AS DISCOUNT_RATE_4,
            ISNULL(DISCOUNT_RATE_5,0) AS DISCOUNT_RATE_5
        FROM        
            PRICE_CAT_EXCEPTIONS WITH (NOLOCK)
        WHERE     
            ACT_TYPE = 1 AND 
            CONSUMER_ID = #attributes.consumer_id#
    </cfif>
</cfquery>
<cfif get_discount_row.recordcount>
	<cfset disc1 = get_discount_row.DISCOUNT_RATE_1>
    <cfset disc2 = get_discount_row.DISCOUNT_RATE_2>
    <cfset disc3 = get_discount_row.DISCOUNT_RATE_3>
<cfelse>
	<cfset disc1 = 0>
    <cfset disc2 = 0>
    <cfset disc3 = 0>
</cfif>
<cfparam name="attributes.maxrows" default="#SESSION.EP.MAXROWS#">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.totalrecords" default=#products.recordcount#>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfset url_str = "">
<cfif isdefined("attributes.list_order_no") and len(attributes.list_order_no)>
	<cfset url_str = "#url_str#&list_order_no=#attributes.list_order_no#">
</cfif>
<cfif isdefined("attributes.company_id") and len(attributes.company_id)>
	<cfset url_str = "#url_str#&company_id=#attributes.company_id#">
</cfif>
<cfif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
	<cfset url_str = "#url_str#&consumer_id=#attributes.consumer_id#">
</cfif>
<cfif isdefined('attributes.product_catid') and len(attributes.product_catid)>
	<cfset url_str2 = "&product_catid=#attributes.product_catid#&product_cat=#PRODUCT_CAT#">
<cfelse>
	<cfset url_str2 =''>
</cfif>
<br />
<cfsavecontent variable="message"><cf_get_lang dictionary_id='57564.Ürünler'></cfsavecontent>
<cfsavecontent variable="kategori"><cf_get_lang dictionary_id='57486.Kategori'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#message#" collapsable="0" resize="0" scroll="1">
    	<cfform name="price_cat" action="#request.self#?fuseaction=prod.popup_list_ezgi_virtual_offer_product#url_str##url_str2#" method="post">
        	<input type="hidden" name="is_filter" id="is_filter" value="1">
            <cfif isdefined("attributes.company_id") and len(attributes.company_id)>
             	<cfinput type="hidden" name="company_id" value="#attributes.company_id#">
         	</cfif>
         	<!---<cfinput type="hidden" name="product_catid" id="product_catid" value="#attributes.product_catid#">
           	<cfinput type="hidden" name="product_cat" id="product_catid" value="#attributes.product_cat#">--->
            <cf_box_search>
            	<div class="form-group" id="item-keyword">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
					<cfinput type="text" name="keyword" placeholder="#message#" id="keyword"  value="#attributes.keyword#" maxlength="200">
				</div>
                <div class="form-group" id="item-cat">
                    <select name="price_catid" id="price_catid" style="width:220px; height:20px">
                        <cfoutput query="GET_PRICE_CAT">
                            <option value="#GET_PRICE_CAT.PRICE_CAT_ID#" <cfif GET_PRICE_CAT.PRICE_CAT_ID eq attributes.price_catid> selected</cfif>>#GET_PRICE_CAT.PRICE_CAT#</option>
                        </cfoutput>
                    </select>
             	</div>
                <div class="form-group" id="item-list_type">
                    <select name="list_type" id="list_type" style="width:220px; height:20px">
						<option value="1" <cfif attributes.list_type eq 1>selected</cfif>><cf_get_lang dictionary_id='39740.Sadece Satıştaki Ürünler'></option>
                        <option value="2" <cfif attributes.list_type eq 2>selected</cfif>><cf_get_lang dictionary_id='66254.Tümünü Getir'></option>
                    </select>
             	</div>
         		<div class="form-group medium"  id="item-cat">
                 	<div class="input-group">
                     	<input type="hidden" name="product_catid" id="product_catid" value="<cfif len(attributes.product_catid) and len(attributes.category_name)><cfoutput>#attributes.product_catid#</cfoutput></cfif>">
                        <input type="hidden" name="product_cat" id="product_cat" value="<cfif len(attributes.product_cat) and len(attributes.category_name)><cfoutput>#attributes.product_cat#</cfoutput></cfif>">
                        <input name="category_name" type="text" id="category_name" placeholder="Kategori" style="width:100px;" onfocus="AutoComplete_Create('category_name','PRODUCT_CATID,PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','','PRODUCT_CATID,HIERARCHY','product_catid,product_cat','','3','200','','1');" value="<cfif len(attributes.category_name)><cfoutput>#attributes.category_name#</cfoutput></cfif>" autocomplete="off">
                        <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_cat_names&is_sub_category=1&field_id=price_cat.product_catid&field_code=price_cat.cat&field_name=price_cat.category_name&field_min=add_design.MIN_MARGIN&field_max=add_design.MAX_MARGIN');"></span>
						
                  	</div>
             	</div>
                <div class="form-group small">
					<cfinput type="text" name="maxrows" id="maxrows" value="#attributes.maxrows#" validate="integer" range="1," required="yes" message="Sayi_Hatasi_Mesaj" onkeyup="return(formatcurrency(this,event,0));">
				</div>
				<div class="form-group">   
					<cf_wrk_search_button search_function='input_control()' button_type="4">
				</div>
         	</cf_box_search>
      	</cfform>
  	</cf_box>
    <cf_box>
    	<div class="col col-4">
    		<cf_flat_list>
            	<thead>
					<tr>
                    	<th><cf_get_lang dictionary_id="58577.Sıra"></th>
                        <th><cf_get_lang dictionary_id="57486.Kategori"></th>
                    </tr>
                </thead>

            	<cfif get_cat.recordcount>
					<cfoutput query="get_cat">
                    	<tbody>
                        	<tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row" style="text-align:right;cursor: pointer;<cfif isdefined('attributes.product_catid') and attributes.product_catid eq PRODUCT_CATID>background-color:LightGray</cfif>" >
                                <td style="width:30px; text-align:right">#currentrow#&nbsp;</td>
                                <td width="80%">
                                    <a href="#request.self#?fuseaction=prod.popup_list_ezgi_virtual_offer_product&is_filter=1&list_order_no=#attributes.list_order_no#&list_type=#attributes.list_type#<cfif not (isdefined('attributes.product_catid') and attributes.product_catid eq PRODUCT_CATID)>&product_catid=#PRODUCT_CATID#</cfif>&product_cat=#HIERARCHY#&keyword=#attributes.keyword#&price_catid=#attributes.price_catid#<cfif isdefined('attributes.company_id') and len(attributes.company_id)>&company_id=#attributes.company_id#<cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>&consumer_id=#attributes.consumer_id#</cfif>">
                                        &nbsp;#PRODUCT_CAT#
                                    </a>
                                </td>
                            </tr>
                        </tbody>
                    </cfoutput>
                </cfif>
           	</cf_flat_list>
    	</div>
        <div class="col col-8">
    		<cf_flat_list>
            	<thead>
                    <tr>
                        <th width="100px"><cf_get_lang_main no='106.Stok Kodu'></th>
                        <th><cf_get_lang_main no='245.Ürün'></th>
                        <th width="75px"><cf_get_lang_main no='672.Fiyat'></th>
                        <th width="40px"><cf_get_lang_main no='265.Döviz'></th>
                        <th width="25"><cf_get_lang_main no='224.Birim'></th>
                    </tr>
                </thead>
                <tbody>
                	<cfif products.recordcount>
						<cfoutput query="products" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#"> 
                            <cfif isdefined('SALES_PRICE_#STOCK_ID#')>
                                <cfset sales_price = Evaluate('SALES_PRICE_#STOCK_ID#')>
                                <cfset money = Evaluate('MONEY_#STOCK_ID#')>
                            <cfelse>
                                <cfset discount = 0>
                                <cfset sales_price = 0>
                                <cfset money = session.ep.money>
                            </cfif>
                            <form name="product#currentrow#" method="post" action="#request.self#?fuseaction=objects.emptypopup_add_session2module#url_str#">
                                <input type="Hidden" name="product_id" id="product_id" value="#product_id#">
                                <input type="Hidden" name="product_name" id="product_name" value="#product_name#">
                            <tr height="20" title="#PRODUCT_DETAIL2#"  onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">           
                                <td>#STOCK_CODE#</td>
                                <cfscript>
                                    temp_prod_property=replace(PROPERTY,'"','','all');
                                    temp_prod_property=replace(temp_prod_property,"'","","all");
                                    temp_prod_property=replace(temp_prod_property,";","","all");
                                    temp_prod_name=replace(product_name,'"','','all');
                                    temp_prod_name=replace(temp_prod_name,"'","","all");
                                    temp_prod_name=replace(temp_prod_name,";","","all");
                                </cfscript>
                
                                <td style="cursor:pointer" class="tableyazi" onClick="javascript:opener.add_row(#STOCK_ID#,'#temp_prod_name#','#PRODUCT_CODE#','#PRODUCT_CODE_2#','#main_unit#','#product_id#','#price#','#money#','0','0','0','#purchase_price#','#purchase_price_money#','#cost_price#','#cost_price_money#',#tax#,#attributes.price_catid#,#disc1#,#disc2#,#disc3#,1,0);">#product_name# #property#</td> 
                                <td style="text-align:right">#Tlformat(price,2)#</td>
                                <td>#money#</td>
                                <td width="15">#main_unit#</td>
                            </tr>
            
                          </form>
                        </cfoutput> 
                    <cfelse>
                        <tr> 
                            <td colspan="8">
                                <cfif attributes.is_filter>
            
                                    <cf_get_lang_main no='72.Kayıt Bulunamadı'>!
                                <cfelse>
                                    <cf_get_lang_main no='289.Filtre Ediniz'>!
                                </cfif>
                            </td>
                        </tr>
                    </cfif>
                </tbody>
        	</cf_flat_list>
    	</div>
    </cf_box>

	<cfif attributes.totalrecords gt attributes.maxrows>
        <table width="99%">
          <tr> 
            <td>
                <cfset adres = "prod.popup_list_ezgi_virtual_offer_product&is_filter=1">
                <cfif len(attributes.keyword)>
                    <cfset adres = "#adres#&keyword=#attributes.keyword#">
                </cfif>
                <cfif isDefined('attributes.product_catid') and len(attributes.product_catid)>
                    <cfset adres = "#adres#&product_catid=#attributes.product_catid#">
                </cfif>
                <cfif isDefined('attributes.product_cat') and len(attributes.product_cat)>
                    <cfset adres = "#adres#&product_cat=#attributes.product_cat#">
                </cfif>
    
                <cfif isdefined("attributes.compid")>
                    <cfset adres = "#adres#&compid=#attributes.compid#">
                </cfif>
                <cfif isdefined("attributes.price_catid")>
                    <cfset adres = "#adres#&price_catid=#attributes.price_catid#">
                </cfif>
                <cfif isdefined("attributes.list_order_no") and len(attributes.list_order_no)>
                    <cfset adres = "#adres#&list_order_no=#attributes.list_order_no#">
                </cfif>
    			<cfif isdefined("attributes.attributes.list_type") and len(attributes.attributes.list_type)>
                    <cfset adres = "#adres#&attributes.list_type=#attributes.attributes.list_type#">
                </cfif>
                <cfif isdefined("attributes.company_id") and len(attributes.company_id)>
                    <cfset adres = "#adres#&company_id=#attributes.company_id#">
                </cfif>
                <cfif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
                    <cfset adres = "#adres#&consumer_id=#attributes.consumer_id#">
                </cfif>
                <cf_pages page="#attributes.page#"
                    maxrows="#attributes.maxrows#"
                    totalrecords="#attributes.totalrecords#"
                    startrow="#attributes.startrow#"
                    adres="#adres#">
              </td>
              <!-- sil --><td style="text-align:right;"> <cfoutput> <cf_get_lang_main no='128.Toplam Kayıt'>:#attributes.totalrecords#&nbsp;-&nbsp;<cf_get_lang_main no='169.Sayfa'>:#attributes.page#/#lastpage#</cfoutput> 
              </td><!-- sil -->
          </tr>
        </table>
    </cfif>
</div> 
<script type="text/javascript">
	price_cat.keyword.focus();
	function input_control()
	{
	<cfif not session.ep.our_company_info.unconditional_list>
		if (price_cat.keyword.value.length == 0 && price_cat.product_cat.value.length == 0 && (price_cat.employee_id.value.length == 0 || price_cat.employee.value.length == 0) && (price_cat.search_company_id.value.length == 0 || price_cat.search_company.value.length == 0) )
			{
				alert("<cf_get_lang_main no='1538.En Az Bir Alanda Filtre Etmelisiniz'> !");
				return false;
			}
		else return true;
	<cfelse>
		return true;
	</cfif>
	}
	function gonder(stock_id,product_name)
	{
		window.opener.add_ezgi_row(stock_id,product_name);
		self.close();
	}
</script>
               
               	