<!---
    File: list_ezgi_stocks.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.is_filter" default="0">
<cfparam name="attributes.product_cat" default=''>
<cfparam name="attributes.product_catid" default=''>
<cfparam name="attributes.search_company_id" default="">
<cfparam name="attributes.employee_id" default="">
<cfparam name="attributes.keyword" default=''>
<cfparam name="attributes.list_order_no" default="">
<cfparam name="attributes.unit" default="1">
<cfparam name="attributes.product_type" default="2">
<cfquery name="get_default_department" datasource="#dsn#">
	SELECT DEPARTMENT_ID, LOCATION_ID FROM EMPLOYEE_POSITION_DEPARTMENTS WHERE POSITION_CODE = #session.ep.POSITION_CODE# AND OUR_COMPANY_ID = #session.ep.COMPANY_ID#
</cfquery>
<cfquery name="get_unit" datasource="#dsn#">
	SELECT UNIT_ID, UNIT FROM SETUP_UNIT
</cfquery>
<cfif get_default_department.recordcount>
	<cfparam name="attributes.sales_departments" default="#get_default_department.DEPARTMENT_ID#-#get_default_department.LOCATION_ID#">
<cfelse>
	<cfparam name="attributes.sales_departments" default="">
</cfif>
<cfif isDefined('attributes.amount_multiplier')>
	<cfset attributes.amount_multiplier = filterNum(attributes.amount_multiplier)>
</cfif>
<cfif not (isDefined('attributes.amount_multiplier') and isnumeric(attributes.amount_multiplier) and attributes.amount_multiplier gt 0)>
	<cfset attributes.amount_multiplier = 1>
</cfif>
<cfquery name="get_department_name" datasource="#DSN#">
	SELECT 
		SL.LOCATION_ID,
		SL.COMMENT,
		D.DEPARTMENT_ID,
		D.DEPARTMENT_HEAD,
		D.BRANCH_ID
	FROM
		STOCKS_LOCATION SL,
		DEPARTMENT D
	WHERE 
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID
		AND D.BRANCH_ID IN (SELECT BRANCH_ID FROM BRANCH WHERE COMPANY_ID = #session.ep.company_id#)
        AND D.DEPARTMENT_ID IN (
        						SELECT 
                                    DEPARTMENT_ID
                                FROM 
                                    EMPLOYEE_POSITION_BRANCHES 
                                WHERE  
                                    POSITION_CODE = #session.ep.POSITION_CODE# AND 
                                    LOCATION_CODE IS NOT NULL
        						)
	ORDER BY
		D.DEPARTMENT_HEAD,
		SL.COMMENT
</cfquery>
<cfif attributes.is_filter>
	<cfinclude template="../query/get_ezgi_stocks.cfm">
    <cfset stock_id_list = ValueList(products.stock_id)>
    <cfset product_id_list = ValueList(products.product_id)>
    <cfif products.recordcount>
        <cfquery name="GET_PRODUCT_UNITS" datasource="#DSN3#">
            SELECT ADD_UNIT,MAIN_UNIT,MULTIPLIER,PRODUCT_UNIT_ID,PRODUCT_ID FROM PRODUCT_UNIT WHERE PRODUCT_ID IN (#product_id_list#) AND PRODUCT_UNIT_STATUS = 1
        </cfquery>
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
<cfif isdefined('attributes.ezgi_secim_type')>
	<cfset url_str = "&ezgi_secim_type=#attributes.ezgi_secim_type#">
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
<cfsavecontent variable="message"><cf_get_lang dictionary_id='57564.Ürünler'></cfsavecontent>
<cfsavecontent variable="kategori"><cf_get_lang dictionary_id='57486.Kategori'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<div class="col col-4">
    	<cf_box title="kategori" collapsable="0" resize="0" scroll="1">
        	<cf_flat_list>
            	<cfif get_cat.recordcount>
					<cfoutput query="get_cat">
                    	<tbody>
                        <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row" style="text-align:right;cursor: pointer;<cfif isdefined('attributes.product_catid') and attributes.product_catid eq PRODUCT_CATID>background-color:LightGray</cfif>" >
                            <td style="width:20px; text-align:right">#currentrow#&nbsp;</td>
                            <td style="text-align:left">
                                <a href="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str1#&var_=#attributes.var_#&is_filter=1&keyword=#attributes.keyword#<cfif isdefined('attributes.product_catid') and attributes.product_catid neq PRODUCT_CATID>&product_catid=#PRODUCT_CATID#&product_cat=#PRODUCT_CAT#</cfif><cfif isdefined("attributes.company_id") and len(attributes.company_id)>&company_id=#attributes.company_id#</cfif>">
                                    &nbsp;#PRODUCT_CAT#
                                </a>
                            </td>
                        </tr>
                        </tbody>
                    </cfoutput>
                </cfif>
            </cf_flat_list>
        </cf_box>
   </div> 
   <div class="col col-8">
	<cf_box title="#message#" collapsable="0" resize="0" scroll="1">
    	<cfform name="price_cat" action="#request.self#?fuseaction=prod.popup_ezgi_stocks#url_str##url_str2#&var_=#attributes.var_#" method="post">
			<input type="hidden" name="is_filter" id="is_filter" value="1">
            <cfif isdefined("attributes.company_id") and len(attributes.company_id)>
          		<cfinput type="hidden" name="company_id" value="#attributes.company_id#">
      		</cfif>
            <cfif isdefined('attributes.ezgi_secim_type')>
            	<cfinput type="hidden" name="ezgi_secim_type" id="ezgi_secim_type" value="#attributes.ezgi_secim_type#">
            </cfif>
        	<cfinput type="hidden" name="product_catid" id="product_catid" value="#attributes.product_catid#">
          	<cfinput type="hidden" name="product_cat" id="product_catid" value="#attributes.product_cat#">
            <cf_box_search>
            	<div class="form-group" id="item-keyword">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
					<cfinput type="text" name="keyword" placeholder="#message#" id="keyword"  value="#attributes.keyword#" maxlength="200">
				</div>
                <cfif isdefined('attributes.ezgi_design') or isdefined('attributes.ezgi_production') or isdefined('attributes.ezgi_prototip')>
               		<div class="form-group" id="item-product_type">
                  		<select name="product_type" id="product_type">
                        	<cfif not isdefined('attributes.ezgi_prototip')>
                            	<option value="2" <cfif attributes.product_type eq 2>selected</cfif>><cf_get_lang dictionary_id="36742.Modül"></option>
                           		<option value="3" <cfif attributes.product_type eq 3>selected</cfif>><cf_get_lang dictionary_id="45548.Paket"></option>
                          	</cfif>
                          	<option value="4" <cfif attributes.product_type eq 4>selected</cfif>><cf_get_lang dictionary_id="45.Parça"></option>
							<cfif isdefined('attributes.ezgi_design') and not isdefined('attributes.ezgi_prototip')>
                           		<option value="5" <cfif attributes.product_type eq 5>selected</cfif>><cf_get_lang dictionary_id="404.Hammadde"></option>
                         	</cfif>
                    	</select>
             		</div>
             	</cfif>
                <div class="form-group medium" id="item-amount_multiplier">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57635.Miktar'></cfsavecontent>
					<input type="text" name="amount_multiplier" id="amount_multiplier" placeholder="<cfoutput>#message#</cfoutput>" value="<cfoutput>#amountformat(attributes.amount_multiplier,4)#</cfoutput>" onkeyup="return FormatCurrency(this,event,4);" class="moneybox">
				</div>
                <!---<div class="form-group" id="item-unit">
					<select name="unit" id="unit" style="width:75px;height:20px">
                  		<cfoutput query="get_unit">
                       		<option value="#UNIT_ID#" <cfif attributes.unit eq UNIT_ID>selected</cfif>>#UNIT#</option>
                      	</cfoutput>
                 	</select>
				</div>--->
                <div class="form-group small">
					<cfinput type="text" name="maxrows" id="maxrows" value="#attributes.maxrows#" validate="integer" range="1," required="yes" message="Sayi_Hatasi_Mesaj" onkeyup="return(formatcurrency(this,event,0));">
				</div>
				<div class="form-group">   
					<cf_wrk_search_button search_function='input_control()' button_type="4">
				</div>
          	</cf_box_search>
            <cf_box_search_detail>
                <div id="detail_search_div" style="display:table-row;"></div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="item-cat_id">
                        <label class="col col-12"><cf_get_lang dictionary_id='58831.Boyutlar'> (<cf_get_lang dictionary_id='42549.mm'>)</label>
                        <div class="col col-4">
                            <div class="input-group">
								<input type="text" name="en" id="en" value="1000">  
                            </div>
                        </div>
                        <div class="col col-4">
                            <div class="input-group">
								<input type="text" name="boy" id="boy" value="1000">  
                            </div>
                        </div>
                        <div class="col col-4">
                            <div class="input-group">
								<input type="text" name="genislik" id="genislik" value="1000">  
                            </div>
                        </div>
                    </div>
              	</div>
            </cf_box_search_detail>
			<cf_flat_list>
            	<thead>
					<tr>
                        <th width="100px"><cf_get_lang dictionary_id="57518.Stok Kodu"></th>
                        <th width="80px"><cf_get_lang dictionary_id="57633.Barkod"></th>
                        <th><cf_get_lang dictionary_id="44019.Ürün"></th>
                        <cfif isdefined("attributes.company_id") and len(attributes.company_id)>
                            <th width="75px"><cf_get_lang dictionary_id="58084.Fiyat"></th>
                            <th width="40px"><cf_get_lang dictionary_id="57677.Döviz"></th>
                        </cfif>
                    <th width="25"><cf_get_lang dictionary_id="57636.Birim"></th>
                    </tr>
                </thead>
                <tbody>
                    <cfif products.recordcount>
						<cfoutput query="products" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#"> 
                        	<cfif type eq 1>
                                <cfsavecontent variable="type_detail"><cf_get_lang dictionary_id='58511.Takım'></cfsavecontent>
                            <cfelseif type eq 2>
                                <cfsavecontent variable="type_detail"><cf_get_lang dictionary_id="36742.Modül"></cfsavecontent>
                            <cfelseif type eq 3>
                                <cfsavecontent variable="type_detail"><cf_get_lang dictionary_id="45548.Paket"></cfsavecontent>
                            <cfelseif type eq 4>
                                <cfsavecontent variable="type_detail"><cf_get_lang dictionary_id="45.Parça"></cfsavecontent>
                            <cfelseif type eq 5>
                                <cfsavecontent variable="type_detail"><cf_get_lang dictionary_id="404.Hammadde"></cfsavecontent>
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
                            <tr height="20" title="#PRODUCT_DETAIL2#"  onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">           
                                <td>#STOCK_CODE#</td>
                                <td>#BARCOD#</td>
                                <cfscript>
                                    temp_prod_property=replace(PROPERTY,'"','','all');
                                    temp_prod_property=replace(temp_prod_property,"'","","all");
                                    temp_prod_property=replace(temp_prod_property,";","","all");
                                    temp_prod_name=replace(product_name,'"','','all');
                                    temp_prod_name=replace(temp_prod_name,"'","","all");
                                    temp_prod_name=replace(temp_prod_name,";","","all");
                                </cfscript>
                                <cfif (isdefined('attributes.ezgi_design') and attributes.ezgi_design eq 2)> <!---Tek Seçim İsteniyorsa--->
                                    <td style="cursor:pointer" onClick="gonder(#STOCK_ID#,'#product_name#');">#product_name# #property#</td>
                                <cfelse><!--- Çoklu Seçim İsteniyorsa--->
                                <td style="cursor:pointer" onClick="sepete_ekle(#STOCK_ID#,'#temp_prod_property#','#currentrow#','#product_id#','#temp_prod_name#','#STOCK_CODE#','#type#','#type_detail#','#main_unit#','#sales_price#','#money#','#discount#','0','1','0','<cf_get_lang dictionary_id="621.Serbest Giriş">','#spect_main_id#','1','#BARCOD#');">#product_name# #property#</td> 
                                </cfif>
                                <cfif isdefined("attributes.company_id") and len(attributes.company_id)>
                                    <td style="text-align:right" onClick="sepete_ekle(#STOCK_ID#,'#temp_prod_property#','#currentrow#','#product_id#','#temp_prod_name#','#STOCK_CODE#','#type#','#type_detail#','#main_unit#','#sales_price#','#money#','#discount#','0','1','0','<cf_get_lang dictionary_id="621.Serbest Giriş">','#spect_main_id#','1','#BARCOD#');">#Tlformat(sales_price,2)#</td>
                                    <td>#money#</td>
                                </cfif>
                                <cfquery name="GET_UNITS" dbtype="query">
                                    SELECT DISTINCT ADD_UNIT,PRODUCT_UNIT_ID,MULTIPLIER,MAIN_UNIT FROM get_product_units WHERE PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#PRODUCT_ID#">
                                </cfquery>
                                <td style="cursor:pointer">
                                	<cfloop from="1" to="#get_units.recordcount#" index="unt_ind">
                                    	<cfif get_units.add_unit[unt_ind] eq products.main_unit>
                                        	<a onclick="sepete_ekle(#STOCK_ID#,'#temp_prod_property#','#currentrow#','#product_id#','#temp_prod_name#','#STOCK_CODE#','#type#','#type_detail#','#main_unit#','#sales_price#','#money#','#discount#','0','1','0','<cf_get_lang dictionary_id="621.Serbest Giriş">','#spect_main_id#','1','#BARCOD#');" class="tableyazi">
												#get_units.add_unit[unt_ind]#&nbsp;
					  						</a>
                                        <cfelse>
                                        	<a onclick="sepete_ekle(#STOCK_ID#,'#temp_prod_property#','#currentrow#','#product_id#','#temp_prod_name#','#STOCK_CODE#','#type#','#type_detail#','#main_unit#','#sales_price#','#money#','#discount#','0','1','0','<cf_get_lang dictionary_id="621.Serbest Giriş">','#spect_main_id#','#get_units.MULTIPLIER[unt_ind]#','#BARCOD#');" class="tableyazi">
												#get_units.add_unit[unt_ind]#&nbsp;
					  						</a>
                                        </cfif>
                                    </cfloop>
                                </td>
                            </tr>
                          </form>
                        </cfoutput> 
                    <cfelse>
                        <tr> 
                            <td colspan="7">
                                <cfif attributes.is_filter>
                                    <cf_get_lang dictionary_id="58486.Kayıt Bulunamadı">!
                                <cfelse>
                                    <cf_get_lang dictionary_id="57701.Filtre Ediniz">!
                                </cfif>
                            </td>
                        </tr>
                    </cfif>
                </tbody>
           	</cf_flat_list>
       	</cfform> 
	</cf_box>
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
                <cfif isdefined("attributes.amount_multiplier")>
					<cfset adres = "#adres#&amount_multiplier=#attributes.amount_multiplier#">
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

<script type="text/javascript">
	$( "#keyword" ).focus();
	function input_control()
	{
	<cfif not session.ep.our_company_info.unconditional_list>
		if (price_cat.keyword.value.length == 0 && price_cat.product_cat.value.length == 0 && (price_cat.employee_id.value.length == 0 || price_cat.employee.value.length == 0) && (price_cat.search_company_id.value.length == 0 || price_cat.search_company.value.length == 0) )
			{
				alert("<cf_get_lang dictionary_id='58950.En Az Bir Alanda Filtre Etmelisiniz'> !");
				return false;
			}
		else return true;
	<cfelse>
		return true;
	</cfif>
	}
	function sepete_ekle(stockid,stockprop,sirano,product_id,product_name,stock_code,type,type_detail,add_unit,sales_price,money,discount,type_1,type_2,type_3,detail,spect_main_id,amount_multiplier,barcod)
	{
		
		if(isNaN(amount_multiplier))
		{
			amount = filterNum(price_cat.amount_multiplier.value,4);
		}
		else
		{
			amount = filterNum(price_cat.amount_multiplier.value,4)*amount_multiplier
		}
		if(add_unit == 'M3')
		{
			hacim_oran = document.getElementById('en').value*document.getElementById('boy').value*document.getElementById('genislik').value/1000000000;
			amount = amount*hacim_oran;
		}
		<cfif isdefined('attributes.ezgi_secim_type') and attributes.ezgi_secim_type eq 2>
			window.opener.add_ezgi_row(stockid,stockprop,sirano,product_id,product_name,stock_code,type,type_detail,add_unit,sales_price,money,discount,type_1,type_2,type_3,detail,spect_main_id,amount,barcod);
			self.close();
		<cfelse>
			window.opener.add_row(stockid,stockprop,sirano,product_id,product_name,stock_code,type,type_detail,add_unit,sales_price,money,discount,type_1,type_2,type_3,detail,spect_main_id,amount,barcod);
			document.price_cat.submit();
		</cfif>
	}
	function gonder(stock_id,product_name)
	{
		window.opener.add_ezgi_row(stock_id,product_name);
		self.close();
	}
</script>