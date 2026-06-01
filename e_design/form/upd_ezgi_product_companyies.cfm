<cfparam name="attributes.cat" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.upd_type" default="4">
<cfparam name="attributes.our_company_id" default="">
<cfparam name="attributes.branches" default="">
<cfset old_branch_history_list = "">
<script>
function wrk_select_all_p(main_checkbox,row_checkbox,row_count)
{
	var check_len = row_count - 1;
	for(var cl_ind=0; cl_ind <= check_len; cl_ind++)
	{
		if(document.getElementById(main_checkbox).checked == true)
		{
			document.getElementById(row_checkbox + '_' + (cl_ind+ 1)).checked = true;	
		}
		else
		{
			document.getElementById(row_checkbox + '_' + (cl_ind+ 1)).checked = false;	
		}
	}
}
</script>

<cfparam name="attributes.brand_id" default="">
<cfquery name="GET_PRODUCT_CAT" datasource="#DSN1#">
	SELECT 
		PRODUCT_CAT.PRODUCT_CATID, 
        PRODUCT_CAT.HIERARCHY,
        CASE WHEN PRODUCT_CAT.HIERARCHY NOT LIKE '%.%' 
        	THEN PRODUCT_CAT.HIERARCHY + ' ' + PRODUCT_CAT.PRODUCT_CAT	
            WHEN PRODUCT_CAT.HIERARCHY LIKE '%.%.%'
            THEN '....' + PRODUCT_CAT.HIERARCHY + ' ' + PRODUCT_CAT.PRODUCT_CAT
            ELSE '..' + PRODUCT_CAT.HIERARCHY + ' ' + PRODUCT_CAT.PRODUCT_CAT
            END AS URUN_KAT            
	FROM 
		PRODUCT_CAT,
		PRODUCT_CAT_OUR_COMPANY PCO
	WHERE 
		PRODUCT_CAT.PRODUCT_CATID = PCO.PRODUCT_CATID AND
		PCO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
	ORDER BY 
		HIERARCHY
</cfquery>
<cfquery name="get_our_companies" datasource="#dsn#">
	SELECT 
    	* 
  	FROM 
    	OUR_COMPANY 
	<cfif len(attributes.our_company_id)>
    	WHERE 
        	COMP_ID = #attributes.our_company_id#
  	</cfif> 
    ORDER BY 
    	COMP_ID 
</cfquery>
<cfset listcompanies = ValueList(get_our_companies.COMP_ID)>
<cfquery name="get_branch_all" datasource="#dsn#">
	SELECT 
		B.BRANCH_ID,
		B.BRANCH_NAME,
		B.COMPANY_ID
	FROM
		BRANCH B
  	<cfif len(attributes.branches)>
    	WHERE 
        	B.BRANCH_ID IN (#attributes.branches#)
  	</cfif> 
    ORDER BY
    	B.BRANCH_NAME
</cfquery>
<cfset listbranches = ValueList(get_branch_all.branch_id,',')>
<cfsavecontent variable="message"><cf_get_lang dictionary_id='58874.Ürün Bilgisi Düzenle'></cfsavecontent>
    <cf_box title="#message#">
	<cfform name="set_" method="post" action="">
        <input type="hidden" value="1" name="is_search_submit"/>
            <cf_box_search >
                <div class="form-group">
                    <div class="col col-12 col-xs-12">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                        <cfinput type="text" name="keyword" id="keyword" placeholder="#message#" value="#attributes.keyword#">
                    </div>
                </div>
                <div class="form-group">
                    <div class="col col-12 col-xs-12">
                        <select name="product_status" id="product_status">
                            <option value="1"<cfif isDefined("attributes.product_status") and (attributes.product_status eq 1)> selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                            <option value="0"<cfif isDefined("attributes.product_status") and (attributes.product_status eq 0)> selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                            <option value="2"<cfif isDefined("attributes.product_status") and (attributes.product_status eq 2)> selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                        </select>
                    </div>                    
                </div>
                <div class="form-group">
                    <label><input type="checkbox" value="1" name="is_company_off" <cfif isdefined("attributes.is_company_off")>checked</cfif>/><cf_get_lang dictionary_id='37536.Webde Görünmesin'></label>
                </div>
                <div class="form-group">
                    <cf_wrk_search_button search_function="kontrol()" button_type="4">
                </div>
            </cf_box_search>
            <cf_box_search_detail>
                <div class="col col-3 col-md-3 col-sm-3 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group">
                        <label><input type="radio" name="upd_type" id="upd_type" value="0" <cfif attributes.upd_type eq 0>checked</cfif> onclick="control_tr();"> <cf_get_lang dictionary_id='37970.Ürün Kategorisine Göre'></label>
                    </div>
                    <div class="form-group">
                        <label><input type="radio" name="upd_type" id="upd_type" value="1" <cfif attributes.upd_type eq 1>checked</cfif> onclick="control_tr();"> <cf_get_lang dictionary_id='37971.Tedarikçiye Göre'></label>
                    </div>
                    <div class="form-group">
                        <label><input type="radio" name="upd_type" id="upd_type" value="2" <cfif attributes.upd_type eq 2>checked</cfif> onclick="control_tr();"> <cf_get_lang dictionary_id='37972.Markaya Göre'></label>
                    </div>
                    <div class="form-group">
                        <label><input type="radio" name="upd_type" id="upd_type" value="3" <cfif attributes.upd_type eq 3>checked</cfif> onclick="control_tr();"> <cf_get_lang dictionary_id='37973.Marka ve Tedarikçiye Göre'></label>
                    </div>
                    <div class="form-group">
                        <label><input type="radio" name="upd_type" id="upd_type" value="4" <cfif attributes.upd_type eq 4>checked</cfif> onclick="control_tr();"> <cf_get_lang dictionary_id='37927.Ürün Adına Göre'></label>
                    </div>
                </div> 
                <div class="col col-4 col-md-4 col-sm-4 col-xs-12" type="column" index="2" sort="true">
                    <cf_box_elements vertical="1">  
                        <div class="form-group">
                            <div id="kategori_1" style="display:none;">
                                <label class="col col-8 col-xs-12"><cf_get_lang dictionary_id='29401.Ürün Kategorisi'></label>
                            </div>
                            <div id="kategori_2" style="display:none;">
                                <div class="col col-8 col-xs-12">
                                    <div id="prod_cats">
                                        <cf_multiselect_check 
                                            query_name="get_product_cat"  
                                            name="cat"
                                            option_text="Ürün Kategorileri" 
                                            width="300"
                                            option_name="URUN_KAT" 
                                            option_value="HIERARCHY"
                                            filter="1"
                                            value="#attributes.cat#">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <div id="company_1" style="display:none;">
                                <label class="col col-8 col-xs-12"><cf_get_lang dictionary_id='57574.Şirket'></label>
                            </div>
                            <div id="company_2" style="display:none;">
                                <div class="col col-8 col-xs-12">
                                    <cfquery name="COMPANIES" datasource="#DSN#">
                                        SELECT COMP_ID, COMPANY_NAME FROM OUR_COMPANY
                                    </cfquery>
                                    <select name="our_company_id" id="our_company_id" onchange="showBranch(this.value);">
                                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                        <cfoutput query="companies">
                                            <option value="#comp_id#"<cfif isdefined('attributes.our_company_id') and listfind(attributes.our_company_id,COMP_ID)>selected</cfif>>#company_name#</option>
                                        </cfoutput>
                                    </select>	            
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <div id="branch_1" style="display:none;">
                                <label class="col col-8 col-xs-12"><cf_get_lang dictionary_id='57453.Şube'></label>
                            </div>
                            <div class="col col-8 col-xs-12" id="comp_branches" style="display:none;">
                                <cfif isdefined('attributes.our_company_id') and len(attributes.our_company_id)>
                                    <cfquery name="GET_BRANCHES" datasource="#DSN#">
                                        SELECT BRANCH_ID, BRANCH_FULLNAME FROM BRANCH <cfif isdefined("our_company_id")>WHERE COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.our_company_id#"></cfif>
                                    </cfquery>
                                    <select name="branches" id="branches" multiple="multiple">
                                        <cfoutput query="GET_BRANCHES">
                                            <option value="#branch_id#" <cfif isdefined("attributes.branches") and listfind(attributes.branches,GET_BRANCHES.BRANCH_ID)>selected</cfif>>#BRANCH_FULLNAME#</option>
                                        </cfoutput>
                                    </select>
                                </cfif>
                            </div>
                        </div>
                        <div class="form-group">
                            <div id="tedarikci_1" style="display:none;">
                                <label class="col col-8 col-xs-12"><cf_get_lang dictionary_id='29533.Tedarikçi'></label>
                            </div>
                            <div id="tedarikci_2" style="display:none;">
                                <div class="col col-8 col-xs-12">
                                    <div class="input-group">
                                        <input name="comp" type="text"  id="comp" style="width:250px;" onfocus="AutoComplete_Create('comp','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1\',0,0','COMPANY_ID','company_id','','3','140');" value="" autocomplete="off">
                                        <span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_list_pars&field_comp_id=set_.company_id&field_comp_name=set_.comp&select_list=2&keyword=</cfoutput>'+set_.comp.value,'list','popup_list_pars');" border="0" align="absmiddle" title="<cf_get_lang dictionary_id='57582.Ekle'>"></span>
                                        <input type="hidden" name="company_id" id="company_id" value="">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <div id="marka_1" style="display:none;">
                                <label class="col col-8 col-xs-12"><cf_get_lang dictionary_id='58847.Marka'></label>
                            </div>
                            <div id="marka_2" style="display:none;">
                                <div class="col col-8 col-xs-12">
                                    <cf_wrkproductbrand
                                    width="150"
                                    compenent_name="getProductBrand"               
                                    boxwidth="240"
                                    boxheight="150"
                                    brand_id="#attributes.brand_id#">
                                </div>		
                            </div>
                        </div> 
                    </cf_box_elements>
                </div>
            </cf_box_search_detail> 
    </cfform>
</cf_box>

    <cfif isdefined("attributes.is_search_submit")>
        <cfform name="set2_" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_product_companyies">
            <cfif attributes.upd_type eq 0>
                <cfquery name="get_cats" datasource="#dsn1#">
                    SELECT 
                        PRODUCT_CAT.PRODUCT_CATID, 
                        PRODUCT_CAT.HIERARCHY, 
                        PRODUCT_CAT.PRODUCT_CAT
                    FROM
                        <!---<cfif isdefined("attributes.branches") and len(attributes.branches)>
                            PRODUCT_BRANCH,
                        </cfif>--->
                        PRODUCT_CAT,
                        PRODUCT_CAT_OUR_COMPANY PCO
                    WHERE 
                        PRODUCT_CAT.PRODUCT_CATID = PCO.PRODUCT_CATID AND
                        <!---<cfif isdefined("attributes.branches") and len(attributes.branches)>
                            PRODUCT_BRANCH_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.branches#" list>) AND
                        </cfif>
                        <cfif isdefined("attributes.our_company_id") and len(attributes.our_company_id)>
                            PCO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.our_company_id#"> AND
                        <cfelse>
                            PCO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
                        </cfif>--->
                        <cfif listlen(attributes.cat)>
                        (
                        <cfloop from="1" to="#listlen(attributes.cat)#" index="ccc">
                            <cfset cat_ = listgetat(attributes.cat,ccc)>
                            (PRODUCT_CAT.HIERARCHY = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cat_#"> OR PRODUCT_CAT.HIERARCHY LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#cat_#.%">)
                            <cfif ccc neq listlen(attributes.cat)>
                                OR
                            </cfif>
                        </cfloop>
                        )
                        <cfelse>
                        PRODUCT_CAT.PRODUCT_CATID = 0
                        </cfif>
                        GROUP BY
                            PRODUCT_CAT.PRODUCT_CATID,
                            PRODUCT_CAT.HIERARCHY
                            ,PRODUCT_CAT.PRODUCT_CAT
                </cfquery>
                <cfif get_cats.recordcount>
                    <cfquery name="GET_PRODUCTS" datasource="#dsn1#">
                        SELECT
                            *,
                            (SELECT PB.BRAND_NAME FROM PRODUCT_BRANDS PB WHERE PB.BRAND_ID = PRODUCT.BRAND_ID) AS MARKA,
                            (SELECT PC.HIERARCHY + ' ' + PC.PRODUCT_CAT FROM PRODUCT_CAT PC WHERE PC.PRODUCT_CATID = PRODUCT.PRODUCT_CATID) AS KATEGORI,
                            (SELECT C.FULLNAME FROM #dsn_alias#.COMPANY C WHERE C.COMPANY_ID = PRODUCT.COMPANY_ID) AS COMP_FULLNAME,
                            (SELECT C.NICKNAME FROM #dsn_alias#.COMPANY C WHERE C.COMPANY_ID = PRODUCT.COMPANY_ID) AS COMP_NAME
                        FROM
                            PRODUCT
                        WHERE
                            <cfif isDefined("attributes.product_status") and (attributes.product_status eq 1)>
                                PRODUCT_STATUS = 1 AND
                            </cfif>
                            <cfif isDefined("attributes.product_status") and (attributes.product_status eq 0)>
                                PRODUCT_STATUS = 0 AND
                            </cfif>
                            <cfif isdefined("attributes.is_company_off")>
                                (COMPANY_ID IS NULL OR COMPANY_ID = '') AND
                            </cfif>
                            <cfif len(attributes.keyword)>
                                PRODUCT_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> AND
                            </cfif>
                            PRODUCT_CATID IN (#valuelist(get_cats.PRODUCT_CATID)#) 
                    ORDER BY 
                        PRODUCT_NAME
                    </cfquery>
                <cfelse>
                    <cfset GET_PRODUCTS.recordcount = 0> 
                </cfif>
                <cfif ListLen(attributes.cat) AND ListLen(attributes.branches)>
                    <cfquery name="get_product_branch" datasource="#dsn1#">
                        SELECT
                        	*
                       	FROM
                            PRODUCT_BRANCH
                        WHERE  
                            BRANCH_ID IN (#attributes.branches#) AND 
                            PRODUCT_ID IN
                                        (
                                            SELECT 
                                                PRODUCT_ID
                                            FROM      
                                                PRODUCT
                                            WHERE  
                                                ( 
                                                <cfloop from="1" to="#ListLen(attributes.cat)#" index="i">
                                                    PRODUCT_CODE LIKE '#ListGetAt(attributes.cat,i)#%' <cfif ListLen(attributes.cat) neq i>OR</cfif>
                                                </cfloop>
                                                )
                                        )
                    </cfquery>
                    <cfif get_product_branch.recordcount>
                  		<cfset product_branch_id_list = ValueList(get_product_branch.PRODUCT_ID)>
                    </cfif>
                </cfif>
         	<cfelseif attributes.upd_type eq 4>
                <cfquery name="GET_PRODUCTS" datasource="#dsn1#">
                        SELECT
                            *,
                            (SELECT PC.HIERARCHY + ' ' + PC.PRODUCT_CAT FROM PRODUCT_CAT PC WHERE PC.PRODUCT_CATID = PRODUCT.PRODUCT_CATID) AS KATEGORI,
                            (SELECT PB.BRAND_NAME FROM PRODUCT_BRANDS PB WHERE PB.BRAND_ID = PRODUCT.BRAND_ID) AS MARKA,
                            (SELECT C.FULLNAME FROM #dsn_alias#.COMPANY C WHERE C.COMPANY_ID = PRODUCT.COMPANY_ID) AS COMP_FULLNAME,
                            (SELECT C.NICKNAME FROM #dsn_alias#.COMPANY C WHERE C.COMPANY_ID = PRODUCT.COMPANY_ID) AS COMP_NAME
                        FROM
                            PRODUCT
                        WHERE
                            <cfif isDefined("attributes.product_status") and (attributes.product_status eq 1)>
                                PRODUCT_STATUS = 1 AND
                            </cfif>
                            <cfif isDefined("attributes.product_status") and (attributes.product_status eq 0)>
                                PRODUCT_STATUS = 0 AND
                            </cfif>
                            <cfif isdefined("attributes.is_company_off")>
                                (COMPANY_ID IS NULL OR COMPANY_ID = '') AND
                            </cfif>
                            <cfif len(attributes.keyword)>
                                PRODUCT_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> AND
                            </cfif>
                            PRODUCT_ID IS NOT NULL
                        ORDER BY 
                        PRODUCT_NAME
                    </cfquery>
                <cfelseif attributes.upd_type eq 1>
                    <cfquery name="GET_PRODUCTS" datasource="#dsn1#">
                        SELECT
                            *,
                            (SELECT PC.HIERARCHY + ' ' + PC.PRODUCT_CAT FROM PRODUCT_CAT PC WHERE PC.PRODUCT_CATID = PRODUCT.PRODUCT_CATID) AS KATEGORI,
                            (SELECT PB.BRAND_NAME FROM PRODUCT_BRANDS PB WHERE PB.BRAND_ID = PRODUCT.BRAND_ID) AS MARKA,
                            (SELECT C.FULLNAME FROM #dsn_alias#.COMPANY C WHERE C.COMPANY_ID = PRODUCT.COMPANY_ID) AS COMP_FULLNAME,
                            (SELECT C.NICKNAME FROM #dsn_alias#.COMPANY C WHERE C.COMPANY_ID = PRODUCT.COMPANY_ID) AS COMP_NAME
                        FROM
                            PRODUCT
                        WHERE
                            <cfif isDefined("attributes.product_status") and (attributes.product_status eq 1)>
                                PRODUCT_STATUS = 1 AND
                            </cfif>
                            <cfif isDefined("attributes.product_status") and (attributes.product_status eq 0)>
                                PRODUCT_STATUS = 0 AND
                            </cfif>
                            <cfif isdefined("attributes.is_company_off")>
                                (COMPANY_ID IS NULL OR COMPANY_ID = '') AND
                            </cfif>
                            <cfif len(attributes.keyword)>
                                PRODUCT_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> AND
                            </cfif>
                            COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id# ">
                        ORDER BY 
                        PRODUCT_NAME
                    </cfquery>
                <cfelseif attributes.upd_type eq 2>
                    <cfquery name="GET_PRODUCTS" datasource="#dsn1#">
                        SELECT
                            *,
                            (SELECT PB.BRAND_NAME FROM PRODUCT_BRANDS PB WHERE PB.BRAND_ID = PRODUCT.BRAND_ID) AS MARKA,
                            (SELECT PC.HIERARCHY + ' ' + PC.PRODUCT_CAT FROM PRODUCT_CAT PC WHERE PC.PRODUCT_CATID = PRODUCT.PRODUCT_CATID) AS KATEGORI,
                            (SELECT C.FULLNAME FROM #dsn_alias#.COMPANY C WHERE C.COMPANY_ID = PRODUCT.COMPANY_ID) AS COMP_FULLNAME,
                            (SELECT C.NICKNAME FROM #dsn_alias#.COMPANY C WHERE C.COMPANY_ID = PRODUCT.COMPANY_ID) AS COMP_NAME
                        FROM
                            PRODUCT
                        WHERE
                            <cfif isDefined("attributes.product_status") and (attributes.product_status eq 1)>
                                PRODUCT_STATUS = 1 AND
                            </cfif>
                            <cfif isDefined("attributes.product_status") and (attributes.product_status eq 0)>
                                PRODUCT_STATUS = 0 AND
                            </cfif>
                            <cfif isdefined("attributes.is_company_off")>
                                (COMPANY_ID IS NULL OR COMPANY_ID = '') AND
                            </cfif>
                            <cfif len(attributes.keyword)>
                                PRODUCT_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> AND
                            </cfif>
                            BRAND_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.brand_id#">
                        ORDER BY 
                        PRODUCT_NAME
                    </cfquery>
                <cfelseif attributes.upd_type eq 3>
                    <cfquery name="GET_PRODUCTS" datasource="#dsn1#">
                    SELECT
                            *,
                            (SELECT PB.BRAND_NAME FROM PRODUCT_BRANDS PB WHERE PB.BRAND_ID = PRODUCT.BRAND_ID) AS MARKA,
                            (SELECT PC.HIERARCHY + ' ' + PC.PRODUCT_CAT FROM PRODUCT_CAT PC WHERE PC.PRODUCT_CATID = PRODUCT.PRODUCT_CATID) AS KATEGORI,
                            (SELECT C.FULLNAME FROM #dsn_alias#.COMPANY C WHERE C.COMPANY_ID = PRODUCT.COMPANY_ID) AS COMP_FULLNAME,
                            (SELECT C.NICKNAME FROM #dsn_alias#.COMPANY C WHERE C.COMPANY_ID = PRODUCT.COMPANY_ID) AS COMP_NAME
                        FROM
                            PRODUCT
                        WHERE
                            <cfif isDefined("attributes.product_status") and (attributes.product_status eq 1)>
                                PRODUCT_STATUS = 1 AND
                            </cfif>
                            <cfif isDefined("attributes.product_status") and (attributes.product_status eq 0)>
                                PRODUCT_STATUS = 0 AND
                            </cfif>
                            <cfif isdefined("attributes.is_company_off")>
                                (COMPANY_ID IS NULL OR COMPANY_ID = '') AND
                            </cfif>
                            <cfif len(attributes.keyword)>
                                PRODUCT_NAME LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> AND
                            </cfif>
                            BRAND_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.brand_id#"> AND
                            COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
                        ORDER BY 
                        PRODUCT_NAME
                    </cfquery>
            </cfif> 
            <cfsavecontent variable="message"><cf_get_lang dictionary_id='57564.Ürünler'></cfsavecontent>
            <cf_box title="#message#" uidrop="1" hide_table_column="1">   
                <cf_grid_list>
                    <thead>
                        <tr>
                            <th width="35"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th><cf_get_lang dictionary_id='57756.Durum'></th>
                            <th><cf_get_lang dictionary_id='58800.Ürün Kodu'></th>
                            <th><cf_get_lang dictionary_id='57486.Kategori'></th>
                            <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                            <th><cf_get_lang dictionary_id='58847.Marka'></th>
                            <th><cf_get_lang dictionary_id='29533.Tedarikçi'></th>						
                            <th><cf_get_lang dictionary_id='29533.Tedarikçi'> <cf_get_lang dictionary_id='32646.Kodu'></th>
                            <th style="text-align:center" ><input type="checkbox" name="all_product_id" id="all_product_id" value="1" checked="checked" onclick="wrk_select_all_p('all_product_id','product_id','<cfoutput>#GET_PRODUCTS.recordcount#</cfoutput>');"/></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfif GET_PRODUCTS.recordcount>
                            <cfoutput query="GET_PRODUCTS">
                                <tr>
                                    <td width="35">#currentrow#</td>
                                    <td><cfif product_status eq 1><cf_get_lang dictionary_id='57493.Aktif'><cfelse><cf_get_lang dictionary_id='57494.Pasif'></cfif></td>
                                    <td><a href="#request.self#?fuseaction=product.list_product&event=det&pid=#product_id#" class="tableyazi">#product_code#</a></td>
                                    <td>#KATEGORI#</td>
                                    <td>#product_name#</td>
                                    <td>#marka#</td>
                                    <td>#comp_FULLname#</td>
                                    <td>#COMP_NAME#</td>
                                    <cfif isdefined('product_branch_id_list') and len(product_branch_id_list)>
                                    	<td style="text-align:center; <cfif ListFind(product_branch_id_list,product_id)>background-color:paleturquoise</cfif>">
                                        	<input type="checkbox" name="product_id" id="product_id_#currentrow#" value="#product_id#" <cfif ListFind(product_branch_id_list,product_id)>checked="checked"</cfif>/>
                                      	</td>
                                    <cfelse>
                                    	<td style="text-align:center"><input type="checkbox" name="product_id" id="product_id_#currentrow#" value="#product_id#" checked="checked"/></td>
                                    </cfif>
                                </tr>
                            </cfoutput>
                        <cfelse>
                        <tr>
                            <td colspan="10"><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>                          
                        </tr>
                        </cfif>
                    </tbody>
                </cf_grid_list>
            </cf_box>
            <cfsavecontent variable="message"><cf_get_lang dictionary_id='58718.düzenle'></cfsavecontent>
            <cf_box title="#getLang('','Ürün Şirketleri ve Şubeleri',37538)#" scroll="1" collapsable="1" resize="1">
            	<table width="100%">
                 	 <tr>
                      	<input type="hidden" name="branch_recordcount" id="branch_recordcount" value="<cfoutput>#get_branch_all.recordcount#</cfoutput>">
                      	<cfparam name="attributes.mode" default="4">
                       	<cfparam name="attributes.page" default="1">
                    	<cfset attributes.startrow=1>
                      	<cfset attributes.maxrows = get_our_companies.recordcount>
                       	<cfset branch_currentrow = 1>
                    	<cfloop query="get_our_companies">
                          	<td valign="bottom"  class="color-list">
                             	<input type="checkbox" name="our_company_id" id="our_company_id" value="<cfoutput>#comp_id#</cfoutput>" checked>
                              	<cfoutput><b>#nick_name#</b></cfoutput>
                          	</td>
                       		<cfquery name="get_branch" dbtype="query">
                              	SELECT * FROM GET_BRANCH_ALL WHERE COMPANY_ID = #comp_id# ORDER BY BRANCH_NAME
                           	</cfquery>
                        	<cfif get_branch.recordcount>
                            	<tr>
                                 	<td colspan="2">
                                    	<table>
                                        	<tr>
                                           		<td colspan="2" >
                                                	<input type="checkbox" name="all_branch_id_<cfoutput>#comp_id#</cfoutput>" id="all_branch_id_<cfoutput>#comp_id#</cfoutput>" value="1" onClick="hepsini_sec_branch(<cfoutput>#comp_id#</cfoutput>);">
                                                    <i><cf_get_lang dictionary_id='37565.Tüm Şubeleri Seç'></i>
                                              	</td>
                                        	</tr>
                                            <cfquery name="get_branch" dbtype="query">
                                                SELECT * FROM GET_BRANCH_ALL WHERE COMPANY_ID = #comp_id# ORDER BY BRANCH_NAME
                                            </cfquery>
                                         	<cfoutput query="get_branch">
                                             	<cfif ListFind(listbranches,branch_id)>
                                                	<cfset old_branch_history_list = listappend(old_branch_history_list,branch_id,',')>
                                             	</cfif>
                                           		<cfif ((currentrow mod attributes.mode is 1)) or (currentrow eq 1)>
                                          			</tr>
                                             	</cfif>
                                             	<td>
                                                	<input type="checkbox" name="branch_id_#branch_currentrow#" id="branch_id_#branch_currentrow#" value="#branch_id#" <cfif ListFind(listbranches,branch_id)>checked</cfif>>
                                                  	<input type="hidden" name="comp_id_#branch_currentrow#" id="comp_id_#branch_currentrow#" value="#company_id#">
                                            	</td>
                                             	<td width="130" align="left">#branch_name#</td>
                                              	<cfset branch_currentrow = branch_currentrow + 1>
                                            	<cfif ((currentrow mod attributes.mode is 0)) or (currentrow eq recordcount)>
                                                 	</tr>
                                             	</cfif>
                                       		</cfoutput>
                                        </table>
                                	</td>
                             	</tr>
                          	<cfelse>
                           		<tr>
                                 	<td colspan="2"></td>
                              	</tr>
                      		</cfif>
                     	</cfloop>
                        <input type="hidden" name="old_branch_history_list" id="old_branch_history_list" value="<cfoutput>#old_branch_history_list#</cfoutput>">
                        <input type="hidden" name="old_cat_list" value="<cfoutput>#attributes.cat#</cfoutput>"
                </table>
                <cf_box_footer>	
                    <cf_workcube_buttons is_upd='0' is_delete='0'>
                </cf_box_footer>
            </cf_box>
        </cfform>
    </cfif>
<script type="text/javascript">
	function control_tr()
	{
		if(document.set_.upd_type[0].checked==true)
		{
			gizle(tedarikci_1);
			gizle(tedarikci_2);
			gizle(marka_1);
			gizle(marka_2);
			goster(kategori_1);
			goster(kategori_2);
            goster(company_1);
            goster(comp_branches);
            goster(company_2);
            goster(branch_1);
            
		}
		else if(document.set_.upd_type[4].checked==true)
		{
			gizle(tedarikci_1);
			gizle(tedarikci_2);
			gizle(marka_1);
			gizle(marka_2);
			gizle(kategori_1);
			gizle(kategori_2);
            gizle(company_1);
            gizle(comp_branches);
            gizle(company_2);
            gizle(branch_1);
		}
		else if(document.set_.upd_type[1].checked==true)
		{
			goster(tedarikci_1);
			goster(tedarikci_2);
			gizle(kategori_1);
			gizle(kategori_2);
            gizle(company_1);
            gizle(company_2);
            gizle(comp_branches);
            gizle(branch_1);
			gizle(marka_1);
			gizle(marka_2);
		}
		else if(document.set_.upd_type[2].checked==true)
		{
			gizle(tedarikci_1);
			gizle(tedarikci_2);
			gizle(kategori_1);
			gizle(kategori_2);
            gizle(company_1);
            gizle(company_2);
            gizle(comp_branches);
            gizle(branch_1);
			goster(marka_1);
			goster(marka_2);
		}
		else if(document.set_.upd_type[3].checked==true)
		{
			goster(tedarikci_1);
			goster(tedarikci_2);
			gizle(kategori_1);
			gizle(kategori_2);
            gizle(company_1);
            gizle(company_2);
            gizle(comp_branches);
            gizle(branch_1);
			goster(marka_1);
			goster(marka_2);
		}
	}
	control_tr();
	function kontrol()
	{
		return true;
	}	
	
	function filter_char(strng)
	{
		AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=product.ajax_product_categories&keyword=' + strng + '','prod_cats',1);
	}
	
	function showBranch(comp_id)	
	{
        var send_address = "<cfoutput>#request.self#</cfoutput>?fuseaction=product.ajax_company_branches&company_id="+comp_id;
        AjaxPageLoad(send_address,'comp_branches',1,'İlişkili Şubeler');
	}
	function hepsini_sec_branch(deger)
	{
		if(eval("document.set2_.all_branch_id_"+deger).checked == true)
		{
			for (say=1; say<=<cfoutput>#get_branch_all.recordcount#</cfoutput>;say++)
				if(eval("document.set2_.comp_id_"+say).value == deger)
					if(eval("document.set2_.branch_id_"+say).disabled==false)
						eval("document.set2_.branch_id_"+say).checked = true;		
		}
		else
		{
			for (say=1; say<=<cfoutput>#get_branch_all.recordcount#</cfoutput>;say++)
				if(eval("document.set2_.comp_id_"+say).value == deger)
					if(eval("document.set2_.branch_id_"+say).disabled==false)
						eval("document.set2_.branch_id_"+say).checked = false;		
		}
		return false;
	}
</script>