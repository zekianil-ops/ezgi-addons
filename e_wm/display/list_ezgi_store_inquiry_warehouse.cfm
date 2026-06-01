<cf_get_lang_set module_name="product">
<cfparam name="attributes.cat_id" default="">
<cfparam name="attributes.category_name" default="">
<cfparam name="attributes.cat" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.sort_type" default="0">
<cfparam name="attributes.list_type" default="1">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.department_id" default="">
<cfparam name="attributes.is_excel" default="">
<cfquery name="get_branch_" datasource="#dsn#">
	SELECT 
		BRANCH_NAME,BRANCH_ID
	FROM
		BRANCH
	WHERE
		COMPANY_ID = #session.ep.company_id#
		AND BRANCH_STATUS = 1
        AND COMPANY_ID = #session.ep.company_id#
        AND BRANCH_ID IN
			(
                SELECT 
					BRANCH_ID 
				 FROM  
					EMPLOYEE_POSITION_BRANCHES 
				 WHERE 
					POSITION_CODE = #session.ep.position_code#
         	)
</cfquery>
<cfquery name="GET_DEPARTMENT" datasource="#DSN#">
	SELECT
		DEPARTMENT_ID,
		DEPARTMENT_HEAD
	FROM
		BRANCH B,
		DEPARTMENT D 
	WHERE
		B.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		B.BRANCH_ID = D.BRANCH_ID AND
		D.IS_STORE <> 2
		AND D.DEPARTMENT_STATUS = 1 
	ORDER BY
		DEPARTMENT_HEAD
</cfquery>
<cfset branch_dep_list=valuelist(get_department.department_id,',')>
<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT * FROM STOCKS_LOCATION WHERE STATUS = 1
</cfquery>

<cfset branch_dep_list=valuelist(get_department.department_id,',')>

<cfparam name="attributes.page" default=1>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfif isdefined('is_form_submitted')>
	<cfquery name="get_product" datasource="#dsn3#">
    	SELECT 
        	TBL3.STOCK_ID, 
            TBL3.PRODUCT_ID, 
            TBL3.PRODUCT_NAME, 
            TBL3.PRODUCT_CODE, 
            TBL3.PRODUCT_CODE_2, 
            TBL3.SPECT_VAR_ID, 
            TBL3.PRODUCT_UNIT_ID, 
            SUM(TBL3.REAL_STOCK) AS REAL_STOCK, 
            SUM(TBL3.TOTAL_STOCK) AS TOTAL_STOCK, 
            PU.MAIN_UNIT
		FROM     
        	(
            	SELECT 
                	S.STOCK_ID, 
                    S.PRODUCT_ID, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_CODE, 
                    S.PRODUCT_CODE_2, 
                    TBL2.SPECT_VAR_ID, 
                    S.PRODUCT_UNIT_ID, 
                    SUM(TBL2.REAL_STOCK) AS REAL_STOCK, 
                    0 AS TOTAL_STOCK
              	FROM      
                	STOCKS AS S INNER JOIN
                    (
                    	SELECT 
                        	REAL_STOCK, 
                            PRODUCT_ID, 
                            SPECT_VAR_ID, 
                            STOCK_ID
                       	FROM      
                        	(
                            	SELECT 
                                	SR.STOCK_IN - SR.STOCK_OUT AS REAL_STOCK, 
                                    SR.PRODUCT_ID, 
                                    SR.SPECT_VAR_ID, 
                                    SR.STOCK_ID
                              	FROM      
                                	#dsn2_alias#.STOCKS_ROW AS SR WITH (NOLOCK)
                             	WHERE 
                                	1=1
                                    <cfif listLen(attributes.department_id)>
                                        AND   
                                            (
                                                <cfloop from="1" to="#listlen(attributes.department_id)#" index="k">
                                                    SR.STORE = #ListGetAt(ListGetAt(attributes.department_id,k),1,'-')# AND 
                                                    SR.STORE_LOCATION = #ListGetAt(ListGetAt(attributes.department_id,k),2,'-')#
                                                    <cfif k neq listlen(attributes.department_id)>OR</cfif>
                                                </cfloop>
                                            )
                                    </cfif>  
                      		) AS TBL1
                  	) AS TBL2 ON S.STOCK_ID = TBL2.STOCK_ID
         		WHERE   
                	S.PRODUCT_STATUS = 1
                    <cfif isdefined('attributes.cat') and len(attributes.cat) and len(attributes.category_name)>
                        AND S.PRODUCT_CODE LIKE '#attributes.cat#%' 
                    </cfif>
           		GROUP BY 
                	S.STOCK_ID, 
                    S.PRODUCT_ID, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_CODE, 
                    S.PRODUCT_CODE_2, 
                    TBL2.SPECT_VAR_ID, 
                    S.PRODUCT_UNIT_ID
           		UNION ALL
              	SELECT 
                	S.STOCK_ID, 
                    S.PRODUCT_ID, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_CODE, 
                    S.PRODUCT_CODE_2, 
                    TBL.SPECT_ID, 
                    S.PRODUCT_UNIT_ID, 
                    0 AS REAL_STOCK, 
                    ISNULL(TBL.TOTAL_AMOUNT, 0) AS TOTAL_AMOUNT
          		FROM     
                	STOCKS AS S LEFT OUTER JOIN
                    (
                    	SELECT 
                        	EVLS.STOCK_ID, 
                            EVLS.SPECT_ID, 
                            COUNT(*) AS TOTAL_AMOUNT
                    	FROM      
                        	EZGI_WM_SERIAL_NO_LAST_STATUS AS EVLS INNER JOIN
                            EZGI_WM_IS_SERIAL_NO_LIVE AS EVL ON EVLS.SERIAL_NO = EVL.SERIAL_NO
                     	WHERE   
                        	1=1
                           	<cfif listLen(attributes.department_id)>
                            	AND   
                                	(
                                   		<cfloop from="1" to="#listlen(attributes.department_id)#" index="k">
                                        	EVLS.DEPARTMENT_ID = #ListGetAt(ListGetAt(attributes.department_id,k),1,'-')# AND 
                                      		EVLS.LOCATION_ID = #ListGetAt(ListGetAt(attributes.department_id,k),2,'-')#
                                         	<cfif k neq listlen(attributes.department_id)>OR</cfif>
                                     	</cfloop>
                                  	)
                           	</cfif> 
                      	GROUP BY 
                        	EVLS.STOCK_ID, 
                            EVLS.SPECT_ID
                	) AS TBL ON S.STOCK_ID = TBL.STOCK_ID
          		WHERE  
                	S.PRODUCT_STATUS = 1
                    <cfif isdefined('attributes.cat') and len(attributes.cat) and len(attributes.category_name)>
                        AND S.PRODUCT_CODE LIKE '#attributes.cat#%' 
                    </cfif>
       		) AS TBL3 INNER JOIN
            #dsn1_alias#.PRODUCT_UNIT AS PU ON TBL3.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
		WHERE
        	1=1
            <cfif isdefined('attributes.keyword') and len(attributes.keyword)>
            	AND 
                	(
                   		TBL3.PRODUCT_CODE LIKE '%#attributes.keyword#%' OR
                      	TBL3.PRODUCT_NAME LIKE '%#attributes.keyword#%'
                	)
       		</cfif>
        GROUP BY 
        	TBL3.STOCK_ID, 
            TBL3.PRODUCT_ID, 
            TBL3.PRODUCT_NAME, 
            TBL3.PRODUCT_CODE, 
            TBL3.PRODUCT_CODE_2, 
            TBL3.SPECT_VAR_ID, 
            TBL3.PRODUCT_UNIT_ID, 
            PU.MAIN_UNIT
     	<cfif len(attributes.list_type)>
        	HAVING
            <cfif attributes.list_type eq 1>
            	SUM(TBL3.REAL_STOCK) > SUM(TBL3.TOTAL_STOCK)
           	<cfelseif attributes.list_type eq 2>
            	SUM(TBL3.REAL_STOCK) < SUM(TBL3.TOTAL_STOCK)
          	<cfelseif attributes.list_type eq 3>
            	SUM(TBL3.REAL_STOCK) = SUM(TBL3.TOTAL_STOCK)
            </cfif>	
        </cfif>	
    	<cfif len(attributes.sort_type)>
            ORDER BY
            <cfif attributes.sort_type eq 0>	
                PRODUCT_NAME
            <cfelseif attributes.sort_type eq 1>
                PRODUCT_NAME desc
            <cfelseif attributes.sort_type eq 2>
               PRODUCT_CODE
            <cfelseif attributes.sort_type eq 3>
                PRODUCT_CODE desc
            </cfif>
        </cfif>
    </cfquery>
    <cfset product_id_list = ValueList(get_product.PRODUCT_ID)>
    <cfset stock_id_list = ValueList(get_product.stock_id)>
    <cfset arama_yapilmali = 0>
<cfelse>
	<cfset get_product.recordcount = 0>
    <cfset arama_yapilmali = 1>
</cfif>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.totalrecords" default='#get_product.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="rapor" method="post" action="#request.self#?fuseaction=stock.list_ezgi_store_inquiry_warehouse">
            <input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <cf_box_search>
                <div class="form-group">
                    <cfinput type="text" style="width:150px;" placeholder="Filtre" maxlength="50" name="keyword" value="#attributes.keyword#">
                </div>
                <div class="form-group">
                    <select name="sort_type" id="sort_type" style="width:150px;">
                        <option value="0" <cfif attributes.sort_type eq 0>selected</cfif>><cf_get_lang no='945.Ürün Adına Göre Artan'></option>
                        <option value="1" <cfif attributes.sort_type eq 1>selected</cfif>><cf_get_lang no='946.Ürün Adına Göre Azalan'></option>
                        <option value="2" <cfif attributes.sort_type eq 2>selected</cfif>><cf_get_lang no='947.Stok Koduna Göre Artan'></option>
                        <option value="3" <cfif attributes.sort_type eq 3>selected</cfif>><cf_get_lang no='948.Stok Koduna Göre Azalan'></option>
                    </select>
                </div>
                <div class="form-group">
                    <select name="list_type" id="list_type" style="width:150px;">
                        <option value="" <cfif attributes.list_type eq ''>selected</cfif>>Tümü</option>
                        <option value="1" <cfif attributes.list_type eq 1>selected</cfif>>Depoda Fazla Olanlar</option>
                        <option value="2" <cfif attributes.list_type eq 2>selected</cfif>>Seri No Fazla Olanlar</option>
                        <option value="3" <cfif attributes.list_type eq 3>selected</cfif>>Eşit Olanlar</option>
                    </select>
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <input type="hidden" name="cat_id" id="cat_id" value="<cfif len(attributes.cat_id) and len(attributes.category_name)><cfoutput>#attributes.cat_id#</cfoutput></cfif>">
                        <input type="hidden" name="cat" id="cat" value="<cfif len(attributes.cat) and len(attributes.category_name)><cfoutput>#attributes.cat#</cfoutput></cfif>">
                        <input name="category_name" type="text" id="category_name" placeholder="Kategori" style="width:100px;" onfocus="AutoComplete_Create('category_name','PRODUCT_CATID,PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','','PRODUCT_CATID,HIERARCHY','cat_id,cat','','3','200','','1');" value="<cfif len(attributes.category_name)><cfoutput>#attributes.category_name#</cfoutput></cfif>" autocomplete="off">
                        <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_cat_names&is_sub_category=1&field_id=rapor.cat_id&field_code=rapor.cat&field_name=rapor.category_name&field_min=add_design.MIN_MARGIN&field_max=add_design.MAX_MARGIN');"></span>
                    </div>
                </div>
                <div class="form-group">
                	<select name="department_id" style="width:145px; height:20px">
                    	<option value=""<cfif attributes.department_id eq ''> selected</cfif>><cf_get_lang dictionary_id="57734.Seçiniz"></option>
						<cfoutput query="get_department">
							<optgroup label="#department_head#">
								<cfquery name="GET_LOCATION" dbtype="query">
									SELECT * FROM GET_ALL_LOCATION WHERE DEPARTMENT_ID = #get_department.department_id[currentrow]#
								</cfquery>
								<cfif get_location.recordcount>
									<cfloop from="1" to="#get_location.recordcount#" index="s">
										<option value="#department_id#-#get_location.location_id[s]#" <cfif listfind(attributes.department_id,'#department_id#-#get_location.location_id[s]#',',')>selected</cfif>>&nbsp;&nbsp;#get_location.comment[s]#</option>
									</cfloop>
								</cfif>
							</optgroup>					  
						</cfoutput>
					</select>
                </div>
                <div class="form-group">
                	<input type="checkbox" name="is_excel" id="is_excel" value="1" <cfif attributes.is_excel eq 1>checked</cfif>>
                	<cf_get_lang_main no='446.Excel Getir'>
                </div>
                <div class="form-group small">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                        <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,2000" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="4" style="width:35px;">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="1">
                </div>
          	</cf_box_search>
      	</cfform>
    </cf_box>
    <cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
		<cfset filename = "#createuuid()#">
		<cfheader name="Expires" value="#Now()#">
		<cfcontent type="application/vnd.msexcel;charset=utf-8">
		<cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<cfset attributes.startrow=1>
		<cfset attributes.maxrows = get_product.recordcount>
	</cfif>
	<cf_report_list>
        <thead style="width:100%">
            <tr>
                <th style=" width:35px; text-align:right;" rowspan="2"><cf_get_lang_main no='1165.Sıra'></th>
                <th style="width:150px" rowspan="2"><cf_get_lang_main no='106.Stok Kodu'></th>
                <th rowspan="2"><cf_get_lang_main no='245.Ürün'></th>
                <th style="width:70px" rowspan="2">SPECT</th>
                <th style=" text-align:center;" colspan="2">Depo Miktar</th>
                <th style=" text-align:center;" colspan="2">Seri No Miktar</th>
            </tr>
            <tr>
                <th style=" text-align:center; width:90px">Miktar</th>
                <th style=" text-align:center; width:60px">Birim</th>
                <th style=" text-align:center; width:90px">Miktar</th>
                <th style=" text-align:center; width:60px">Birim</th>
          	</tr>
        </thead>
        <tbody>
            <cfif get_product.recordcount>
                <cfoutput query="get_product" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                	<tr oncontextmenu="javascript:wrk_right_menu('PRODUCT_ID',#PRODUCT_ID#);return false;">
                    	<td style="height:20px; text-align:right">#CURRENTROW#</td>
                    	<td style="mso-number-format:\@ ; text-align:left">
                        	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
                            	#get_product.PRODUCT_CODE#
                            <cfelse>
                            	<a href="#request.self#?fuseaction=stock.list_stock&event=det&pid=#get_product.product_id#" class="tableyazi">
                                    #get_product.PRODUCT_CODE#
                                </a>
                            </cfif>
                       	</td>
                   		<td style="text-align:left">#get_product.product_name#</td>
                        <td style="text-align:center">#get_product.SPECT_VAR_ID#</td>
                      	<td style="text-align:right; ">#TlFormat(get_product.REAL_STOCK,2)#</td>
                      	<td>#get_product.MAIN_UNIT#</td>
                    	<td style="text-align:right;<cfif get_product.REAL_STOCK neq get_product.TOTAL_STOCK>color:red</cfif>">#TlFormat(get_product.TOTAL_STOCK,2)#</td>
                      	<td style="text-align:left;<cfif get_product.REAL_STOCK neq get_product.TOTAL_STOCK>color:red</cfif>">#get_product.MAIN_UNIT#</td>
                    </tr>
                </cfoutput>
             	<cfoutput>
                	<tr>
                    	<td style="text-align:left; font-weight:bold" colspan="6">Toplam</td>
                        <td style="text-align:right; font-weight:bold" colspan="4"></td>
                  	</tr>
           		</cfoutput>	
            <cfelse>
                <tr> 
                    <td colspan="10" height="20" style="text-align:left"><cfif arama_yapilmali eq 1><cf_get_lang_main no='289.Filtre Ediniz'> !<cfelse><cf_get_lang_main no='72.Kayıt Yok'>!</cfif></td>
                </tr>
            </cfif>
        </tbody>
	</cf_report_list>
	<cfset adres="prod.popup_list_ezgi_production_need&is_submitted=1">
    <cfif len(attributes.cat) and len(attributes.category_name)>
    	<cfset adres = '#adres#&cat=#attributes.cat#&cat_id=#attributes.cat_id#&category_name=#attributes.category_name#'>
   	</cfif>
    <cfif isDefined('attributes.keyword') and len(attributes.keyword)>
      <cfset adres = "#adres#&keyword=#attributes.keyword#">
    </cfif>
    <cfif len(attributes.sort_type)>
        <cfset adres = '#adres#&sort_type=#attributes.sort_type#'>
    </cfif>
    <cfif len(attributes.list_type)>
        <cfset adres = '#adres#&list_type=#attributes.list_type#'>
    </cfif>
    <cfif len(attributes.department_id)>
      	<cfset adres = "#adres#&department_id=#attributes.department_id#">
   	</cfif>
    <cf_paging page="#attributes.page#"
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#adres#">
</div>
<script language="javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		if(document.getElementById('is_excel').checked==false)
			return true;
	}
</script>