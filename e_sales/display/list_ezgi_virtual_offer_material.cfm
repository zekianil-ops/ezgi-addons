<!---
    File: list_ezgi_virtual_offer_material.cfm
    Folder: Add_Ons\ezgi\e-sales\display
    Author: Ezgi Yazılım
    Date: 01/06/2022
    Description:
--->

<cfparam name="attributes.keyword" default=''>
<cfparam name="attributes.price_cat" default=''>
<cfquery name="get_price_cat" datasource="#DSN3#">
	SELECT 
    	PRICE_CAT_ID, 
        PRICE_CAT, 
        STATUS, 
        VALIDATE, 
        COMPANY_CATS
	FROM     
    	EZGI_VIRTUAL_OFFER_PRICE_LIST
  	WHERE
    	STATUS = 1
</cfquery>
<cfquery name="get_price" datasource="#dsn3#">
    SELECT 
    	EPR.PRICE_CAT_ROW_ID,
    	EP.PRICE_CAT_ID, 
        EPR.PRODUCT_NAME, 
        EPR.PRODUCT_CODE_2 STOCK_CODE, 
        ISNULL(EPR.IS_RATE,0) AS IS_RATE,
        ISNULL(EPR.SALES_PRICE,0) AS SALES_PRICE, 
        ISNULL(EPR.SALES_PRICE_MONEY,'#session.ep.money#') SALES_PRICE_MONEY, 
        ISNULL(EPR.PURCHASE_PRICE,0) AS PURCHASE_PRICE, 
        ISNULL(EPR.PURCHASE_PRICE_MONEY,'#session.ep.money#') PURCHASE_PRICE_MONEY,
        ISNULL(EPR.COST_PRICE,0) AS COST_PRICE, 
        ISNULL(EPR.COST_PRICE_MONEY,'#session.ep.money#') COST_PRICE_MONEY, 
        EPR.UPDATE_DATE
	FROM     
    	EZGI_VIRTUAL_OFFER_PRICE_LIST AS EP INNER JOIN
        EZGI_VIRTUAL_OFFER_PRICE_ROW AS EPR ON EP.PRICE_CAT_ID = EPR.PRICE_CAT_ID
	WHERE 
    	<cfif isdefined('attributes.is_filter') and len (attributes.is_filter)>
			1=1
        <cfelse>
        	1=2
        </cfif> 
        <cfif isdefined('attributes.keyword') and len (attributes.keyword)>
        	AND
            	(
                	EPR.PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
                    EPR.PRODUCT_CODE_2 LIKE '%#attributes.keyword#%'
                )
        </cfif>
        <cfif isdefined('attributes.price_cat') and len (attributes.price_cat)>
    		AND EP.PRICE_CAT_ID = #attributes.price_cat#
        </cfif>
</cfquery>
<cfparam name="attributes.maxrows" default="#SESSION.EP.MAXROWS#">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.totalrecords" default="#get_price.recordcount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<cfsavecontent variable="message"><cf_get_lang dictionary_id='57564.Ürünler'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
   <div class="col col-12">
	<cf_box title="#message#" collapsable="0" resize="0" scroll="1">
    	<cfform name="price_cat" action="#request.self#?fuseaction=prod.popup_list_ezgi_virtual_offer_material" method="post">
			<input type="hidden" name="is_filter" id="is_filter" value="1">
            <cf_box_search>
            	<div class="form-group" id="item-keyword">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
					<cfinput type="text" name="keyword" placeholder="#message#" id="keyword"  value="#attributes.keyword#" maxlength="200">
				</div>
                <div class="form-group" id="item-price_cat">
					<select name="price_cat" id="price_cat">
                		<option value="">Seçiniz</option>
                   		<cfoutput query="get_price_cat">
                         	<option value="#PRICE_CAT_ID#" <cfif isdefined("attributes.price_cat") and attributes.price_cat eq #PRICE_CAT_ID#>selected</cfif>>#PRICE_CAT#</option>
                     	</cfoutput>
               		</select>
				</div>
                <div class="form-group small">
					<cfinput type="text" name="maxrows" id="maxrows" value="#attributes.maxrows#" validate="integer" range="1," required="yes" message="Sayi_Hatasi_Mesaj" onkeyup="return(formatcurrency(this,event,0));">
				</div>
				<div class="form-group">   
					<cf_wrk_search_button search_function='input_control()' button_type="1">
				</div>
          	</cf_box_search>
			<cf_flat_list>
            	<thead>
					<tr>
                        <th width="100"><cf_get_lang dictionary_id="57518.Stok Kodu"></th>
                        <th><cf_get_lang dictionary_id="44019.Ürün"></th>
                      	<th width="75"><cf_get_lang dictionary_id="58084.Fiyat"></th>
                      	<th width="40"><cf_get_lang dictionary_id="57677.Döviz"></th>
                        <th width="25"><cf_get_lang dictionary_id="57636.Birim"></th>
                        <th width="70">Son Güncelleme</th>
                    </tr>
                </thead>
                <tbody>
                    <cfif get_price.recordcount>
						<cfoutput query="get_price" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#"> 
                            <form name="product#currentrow#" method="post" action="">
                                <input type="Hidden" name="PRICE_CAT_ROW_ID" id="PRICE_CAT_ROW_ID" value="#PRICE_CAT_ROW_ID#">
                                <input type="Hidden" name="product_name" id="product_name" value="#product_name#"><!--- #&nbsp;#property# --->
                                <cfif isdefined("attributes.is_action")>
                                    <input type="hidden" name="is_action" id="is_action" value="1">
                                </cfif>
                            <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">           
                                <td>#STOCK_CODE#</td>
                                <cfscript>
                                    temp_prod_name=replace(product_name,'"','','all');
                                    temp_prod_name=replace(temp_prod_name,"'","","all");
                                    temp_prod_name=replace(temp_prod_name,";","","all");
                                </cfscript>
                          		<td style="cursor:pointer" onClick="javascript:opener.add_row('#PRICE_CAT_ROW_ID#','#temp_prod_name#','#STOCK_CODE#','#SALES_PRICE#','#SALES_PRICE_MONEY#','#PURCHASE_PRICE#','#PURCHASE_PRICE_MONEY#','#COST_PRICE#','#COST_PRICE_MONEY#','#IS_RATE#');">#product_name#</td> 
                                <td style="text-align:right">#TlFormat(SALES_PRICE)#</td>
                                <td style="text-align:left">#SALES_PRICE_MONEY#</td>
                                <td style="text-align:left"></td>
                                <td style="text-align:left">#DateFormat(UPDATE_DATE,dateformat_style)#</td>
                            </tr>
                          </form>
                        </cfoutput> 
                    <cfelse>
                        <tr> 
                            <td colspan="8">
                                <cfif isdefined('attributes.is_filter')>
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
                <cfset adres = "prod.popup_list_ezgi_virtual_offer_material&is_filter=1">
                <cfif len(attributes.keyword)>
                    <cfset adres = "#adres#&keyword=#attributes.keyword#">
                </cfif>
                <cfif isdefined('attributes.price_cat') and len(attributes.price_cat)>
                    <cfset adres = "#adres#&price_cat=#attributes.price_cat#">
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
		if(document.getElementById('price_cat').value)
		{
			alert("<cf_get_lang dictionary_id='45954.Fiyat Listesi Seçmelisiniz'> !");
			return false;
		}
		else
			return true;
	}
</script>