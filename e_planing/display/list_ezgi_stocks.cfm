<cfparam name="attributes.is_filter" default="0">
<cfparam name="attributes.product_cat" default=''>
<cfparam name="attributes.product_catid" default=''>
<cfparam name="attributes.search_company_id" default="">
<cfparam name="attributes.employee_id" default="">
<cfparam name="attributes.keyword" default=''>
<cfparam name="attributes.list_order_no" default="">
<cfparam name="attributes.product_type" default="2">
<cfif attributes.is_filter>
	<cfinclude template="../query/get_ezgi_stocks.cfm">
    <cfif isdefined("attributes.company_id") and len(attributes.company_id)>
    	<cfquery name="get_discount" datasource="#dsn3#">
        	SELECT TOP (1) DISCOUNT_RATE AS DISCOUNT FROM PRICE_CAT_EXCEPTIONS WHERE COMPANY_ID = #attributes.company_id# AND (PRODUCT_CATID IS NULL) AND (ACT_TYPE = 1)
        </cfquery>
        <cfif get_discount.recordcount>
        	<cfset discount = get_discount.discount>
       	<cfelse>
        	<cfset discount =  0>
        </cfif>
    	<cfset stock_id_list = ValueList(products.stock_id)>
    	<cfif attributes.product_type eq 2 and Len(stock_id_list)>
        	<cfquery name="get_price" datasource="#dsn3#">
            	SELECT        
                	SALES_PRICE, 
                    MONEY, 
                    DESIGN_MAIN_ROW_ID
				FROM            
                	EZGI_DESIGN_MAIN_ROW
				WHERE        
                	DESIGN_MAIN_ROW_ID IN (#stock_id_list#)
            </cfquery>
            <cfoutput query="get_price">
            	<cfset 'SALES_PRICE_#DESIGN_MAIN_ROW_ID#' = SALES_PRICE>
                <cfset 'MONEY_#DESIGN_MAIN_ROW_ID#' = MONEY>
            </cfoutput>
        </cfif>
    </cfif>
<cfelse>
	<cfset PRODUCTS.recordcount = 0>
</cfif>
<cfquery name="get_cat" datasource="#dsn3#">
	<cfif (isdefined('attributes.ezgi_design') and (attributes.product_type eq 2 or attributes.product_type eq 3 or attributes.product_type eq 4)) or isdefined('attributes.ezgi_production')> <!---I Flow Sipariş Sayfasından Geliyorsa--->

		SELECT        
        	ED.PRODUCT_CATID, 
            PC.PRODUCT_CAT, 
            PC.HIERARCHY
		FROM            
        	EZGI_DESIGN AS ED INNER JOIN
           	PRODUCT_CAT AS PC ON ED.PRODUCT_CATID = PC.PRODUCT_CATID
		WHERE        
        	ED.STATUS = 1
		GROUP BY 
        	ED.PRODUCT_CATID, 
            PC.PRODUCT_CAT, 
            PC.HIERARCHY
		HAVING        
        	ED.PRODUCT_CATID IS NOT NULL AND 
            PC.PRODUCT_CAT IS NOT NULL
    <cfelse>
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
                AND       
                    LIST_ORDER_NO IN (#attributes.list_order_no#)
            </cfif>
        ORDER BY
            PRODUCT_CAT
 	</cfif>
</cfquery>
<!---<cfinclude template="../../../product/query/get_price_cats_basket.cfm">--->
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
<cfif isdefined('attributes.ezgi_design')>
	<cfset url_str = "&ezgi_design=#attributes.ezgi_design#">
</cfif>
<cfif isdefined('attributes.ezgi_production')>
	<cfset url_str = "&ezgi_production=#attributes.ezgi_production#">
</cfif>
<cfif isdefined('attributes.product_type')>
	<cfset url_str1 = "&product_type=#attributes.product_type#">


<cfelse>
	<cfset url_str1 =''>
</cfif>
<cfif isdefined('attributes.product_catid') and len(attributes.product_catid)>
	<cfset url_str2 = "&product_catid=#attributes.product_catid#&product_cat=#PRODUCT_CAT#">
<cfelse>
	<cfset url_str2 =''>
</cfif>
<!--- Harfler --->
<cfoutput>                
	<table class="harfler">
		<tr>
			<td>
				<td>&nbsp;</td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=A">A</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=B">B</a></td> 
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=C">C</a></td> 
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=D">D</a></td> 
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=E">E</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=F">F</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=G">G</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=H">H</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=I">I</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=İ">İ</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=J">J</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=K">K</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=L">L</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=M">M</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=N">N</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=O">O</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=P">P</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=Q">Q</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=R">R</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=S">S</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=Ş">Ş</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=T">T</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=U">U</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=Ü">Ü</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=V">V</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=W">W</a></td> 
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=X">X</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=Y">Y</a></td>
				<td><a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1##url_str2#&var_=#attributes.var_#&is_filter=1&keyword=Z">Z</a></td>
				<td>&nbsp;</td>
			</td>
		</tr>
	</table>     
</cfoutput> 

<cfform name="price_cat" action="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str2#&var_=#attributes.var_#" method="post">
	<input type="hidden" name="is_filter" id="is_filter" value="1">
	<cf_medium_list_search title='#lang_array_main.item [1552]#'>
		<cf_medium_list_search_area>
			<table>
				<tr> 
					<td><cf_get_lang dictionary_id='57460.Filtre'></td>
					<td><cfinput type="text" name="keyword" maxlength="50" value="#attributes.keyword#" style="width:100px;"></td>
					<cfif isdefined("attributes.company_id") and len(attributes.company_id)>
                    	<cfinput type="hidden" name="company_id" value="#attributes.company_id#">
                    </cfif>
                    <cfinput type="hidden" name="product_catid" id="product_catid" value="#attributes.product_catid#">
                    <cfinput type="hidden" name="product_cat" id="product_catid" value="#attributes.product_cat#">
                    <cfif isdefined('attributes.ezgi_design') or isdefined('attributes.ezgi_production')>
                        <td>
                            <select name="product_type" id="product_type" style="width:75px">
                                <option value="2" <cfif attributes.product_type eq 2>selected</cfif>><cf_get_lang dictionary_id='141.Modül'></option>
                                <option value="3" <cfif attributes.product_type eq 3>selected</cfif>><cf_get_lang dictionary_id='100.Paket'></option>
                                <option value="4" <cfif attributes.product_type eq 4>selected</cfif>><cf_get_lang dictionary_id='45.Parça'></option>
				<cfif isdefined('attributes.ezgi_design')>
                                	<option value="5" <cfif attributes.product_type eq 5>selected</cfif>><cf_get_lang dictionary_id='4004.Hammadde'></option>
				</cfif>
                            </select>
                        </td>
                    </cfif>
                    <td>
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='34135.Sayi_Hatasi_Mesaj'></cfsavecontent>
						<cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" onKeyUp="isNumber(this)" validate="integer" range="1,999" message="#message#" maxlength="3" style="width:25px;">
					</td>
					<td style="text-align:right;">
                    	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=prod.form_add_product</cfoutput>','longpage');">
							<img src="images/plus1.gif" title="<cf_get_lang dictionary_id='37562.Yeni Ürün'>" />
                      	</a>
                    	<cf_wrk_search_button search_function='input_control()'>
                   	</td>
				</tr>       
			</table>
		</cf_medium_list_search_area>
	</cf_medium_list_search>
</cfform>
<cf_area width="200px">
	<table width="100%">
		<cfif get_cat.recordcount>
			<cfoutput query="get_cat">
            	<tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row" style="text-align:right;cursor: pointer;<cfif isdefined('attributes.product_catid') and attributes.product_catid eq PRODUCT_CATID>background-color:LightGray</cfif>" >
                	<td width="20%">#currentrow#</td>
                    <td width="80%">
                    	<a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1#&var_=#attributes.var_#&is_filter=1&keyword=#attributes.keyword#&product_catid=#PRODUCT_CATID#&product_cat=#PRODUCT_CAT#<cfif isdefined("attributes.company_id") and len(attributes.company_id)>&company_id=#attributes.company_id#</cfif>">
                    		#PRODUCT_CAT#
                    	</a>
                    </td>
                </tr>
            </cfoutput>
		</cfif>
  	</table>
</cf_area>
<cf_area width="500px">
<cf_medium_list>
	<thead>
		<tr>
			<th width="100px"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
			<th><cf_get_lang dictionary_id='57657.Ürün'></th>
            <cfif isdefined("attributes.company_id") and len(attributes.company_id)>
            	<th width="75px"><cf_get_lang dictionary_id='58084.Fiyat'></th>
                <th width="40px"><cf_get_lang dictionary_id='57677.Döviz'></th>
            </cfif>
		<th width="25"><cf_get_lang dictionary_id='57636.Birim'></th>
		</tr>
	</thead>
	<tbody>
		<cfif products.recordcount>
		<cfoutput query="products" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#"> 
        	<cfif type eq 1>
            	<cfset type_detail = <cf_get_lang dictionary_id='58511.Takım'>>
            <cfelseif type eq 2>
            	<cfset type_detail = <cf_get_lang dictionary_id='141.Modül'>>
            <cfelseif type eq 3>
            	<cfset type_detail = <cf_get_lang dictionary_id='100.Paket'>>
            <cfelseif type eq 4>
            	<cfset type_detail = <cf_get_lang dictionary_id='45.Parça'>>
            <cfelseif type eq 5>
            	<cfset type_detail = <cf_get_lang dictionary_id='404.Hammadde'>>
            </cfif>
            <cfif isdefined('SALES_PRICE_#STOCK_ID#')>
            	<cfset sales_price = Evaluate('SALES_PRICE_#STOCK_ID#')>
                <cfset money = Evaluate('MONEY_#STOCK_ID#')>
            <cfelse>
            	<cfset discount = 0>
            	<cfset sales_price = 0>
                <cfset money = session.ep.money>
            </cfif>
			<form name="product#currentrow#" method="post" action="#request.self#?fuseaction=objects.emptypopup_add_session2module#url_str#&var_=#attributes.var_#">
				<input type="Hidden" name="product_id" id="product_id" value="#product_id#">
                <input type="Hidden" name="type" id="type" value="#type#">
				<input type="Hidden" name="product_name" id="product_name" value="#product_name#"><!--- #&nbsp;#property# --->
				<cfif isdefined("attributes.is_action")>
                    <input type="hidden" name="is_action" id="is_action" value="1">
                </cfif>
			<tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">           
				<td>#STOCK_CODE#</td>
				<cfscript>
					temp_prod_property=replace(PROPERTY,'"','','all');
					temp_prod_property=replace(temp_prod_property,"'","","all");
					temp_prod_property=replace(temp_prod_property,";","","all");
					temp_prod_name=replace(product_name,'"','','all');
					temp_prod_name=replace(temp_prod_name,"'","","all");
					temp_prod_name=replace(temp_prod_name,";","","all");
				</cfscript>
                <cfif (isdefined('attributes.ezgi_design') and attributes.ezgi_design eq 2)> <!---Tek Seçim İsteniyorsa--->
                	<td style="cursor:pointer" class="tableyazi" onClick="gonder(#STOCK_ID#,'#product_name#');">#product_name# #property#</td>
                <cfelse><!--- Çoklu Seçim İsteniyorsa--->
				<td style="cursor:pointer" class="tableyazi" onClick="javascript:opener.add_row(#STOCK_ID#,'#temp_prod_property#','#currentrow#','#product_id#','#temp_prod_name#','#STOCK_CODE#','#type#','#type_detail#','#main_unit#','#sales_price#','#money#','#discount#');">#product_name# #property#</td> 
                </cfif>
                <cfif isdefined("attributes.company_id") and len(attributes.company_id)>
                	<td style="text-align:right" onClick="javascript:opener.add_row(#STOCK_ID#,'#temp_prod_property#','#currentrow#','#product_id#','#temp_prod_name#','#STOCK_CODE#','#type#','#type_detail#','#main_unit#','#sales_price#','#money#','#discount#');">#Tlformat(sales_price,2)#</td>
                    <td>#money#</td>
                </cfif>
				<td width="15">#main_unit#</td>
			</tr>
		  </form>
		</cfoutput> 
		<cfelse>
			<tr> 
				<td colspan="8">
					<cfif attributes.is_filter>
						<cf_get_lang dictionary_id='58486.Kayıt Bulunamadı'>!
					<cfelse>
						<cf_get_lang dictionary_id='57701.Filtre Ediniz'>!
					</cfif>
				</td>
			</tr>
		</cfif>
	</tbody>
</cf_medium_list>
</cf_area>
<cfif attributes.totalrecords gt attributes.maxrows>
	<table width="99%">
	  <tr> 
		<td>
			<cfset adres = "prod.popup_ezgi_stocks&is_filter=1">
			<cfif len(attributes.keyword)>
				<cfset adres = "#adres#&keyword=#attributes.keyword#">
			</cfif>
			<cfif len(attributes.var_)>
				<cfset adres = "#adres#&var_=#attributes.var_#">
			</cfif>
			<cfif isDefined('attributes.product_catid') and len(attributes.product_catid)>
				<cfset adres = "#adres#&product_catid=#attributes.product_catid#">
			</cfif>
			<cfif isDefined('attributes.product_cat') and len(attributes.product_cat)>
				<cfset adres = "#adres#&product_cat=#attributes.product_cat#">
			</cfif>
			<cfif isDefined('attributes.module_name') and len(attributes.module_name)>
				<cfset adres = "#adres#&module_name=#attributes.module_name#">
			</cfif>
			<cfif isdefined("attributes.startdate")>
				<cfset adres = "#adres#&startdate=#attributes.startdate#">
			</cfif>
			<cfif isdefined("attributes.price_lists")>
				<cfset adres = "#adres#&price_lists=#attributes.price_lists#">
			</cfif>
			<cfif isdefined("attributes.compid")>
				<cfset adres = "#adres#&compid=#attributes.compid#">
			</cfif>
			<cfif isdefined("attributes.price_catid")>
				<cfset adres = "#adres#&price_catid=#attributes.price_catid#">
			</cfif>
			<cfif isdefined("attributes.add_product_cost")>
				<cfset adres = "#adres#&add_product_cost=#attributes.add_product_cost#">
			</cfif>
            <cfif isdefined("attributes.list_order_no") and len(attributes.list_order_no)>
				<cfset adres = "#adres#&list_order_no=#attributes.list_order_no#">
            </cfif>
            <cfif isdefined('attributes.ezgi_design') and len(attributes.ezgi_design)>
            	<cfset adres = "#adres#&ezgi_design=#attributes.ezgi_design#">
            </cfif>
	    <cfif isdefined('attributes.ezgi_production') and len(attributes.ezgi_production)>
            	<cfset adres = "#adres#&ezgi_production=#attributes.ezgi_production#">
            </cfif>
            <cfif isdefined('attributes.product_type') and len(attributes.product_type)>
                <cfset adres = "#adres#&product_type=#attributes.product_type#">
            </cfif>
            <cfif isdefined("attributes.company_id") and len(attributes.company_id)>
				<cfset adres = "#adres#&company_id=#attributes.company_id#">
            </cfif>
			<cf_pages page="#attributes.page#"
				maxrows="#attributes.maxrows#"
				totalrecords="#attributes.totalrecords#"
				startrow="#attributes.startrow#"
				adres="#adres#">
		  </td>
		  <!-- sil --><td style="text-align:right;"> <cfoutput> <cf_get_lang dictionary_id='57540.Toplam Kayıt'>:#attributes.totalrecords#&nbsp;-&nbsp;<cf_get_lang dictionary_id='57581.Sayfa'>:#attributes.page#/#lastpage#</cfoutput> 
		  </td><!-- sil -->
	  </tr>
	</table>
</cfif>
<script type="text/javascript">
	price_cat.keyword.focus();
	function input_control()
	{
	<cfif not session.ep.our_company_info.unconditional_list>
		if (price_cat.keyword.value.length == 0 && price_cat.product_cat.value.length == 0 && (price_cat.employee_id.value.length == 0 || price_cat.employee.value.length == 0) && (price_cat.search_company_id.value.length == 0 || price_cat.search_company.value.length == 0) )
			{
				alert('<cf_get_lang dictionary_id='58950.En az bir alanda filtre etmelisiniz'> !');
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