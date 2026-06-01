<cfinclude template="basket_ezgi_connect_queries.cfm">
<cfset get_property_group_list = ValueList(get_property_group.PROPERTY_ID)>
<cfset url_str = "">
<cfif ListLen(get_property_group_list)>
	<cfset url_str = "#url_str#&property_group_list=#get_property_group_list#">
</cfif>
<cfset checked_id_list =''>
<cfloop list="#get_property_group_list#" index="ii">
	<cfif isdefined('attributes.categori_id_list_#ii#') and len(Evaluate('attributes.categori_id_list_#ii#'))>
		<cfset url_str = "#url_str#&categori_id_list_#ii#=#Evaluate('attributes.categori_id_list_#ii#')#">
        <cfset checked_id_list ="#checked_id_list##Evaluate('attributes.categori_id_list_#ii#')#,">
    </cfif>
</cfloop>
<cfset related_id_list = ''>
<cfset checked_id_list = ListDeleteDuplicates(checked_id_list,',')>
	<cfif ListLen(checked_id_list)>
    <cfquery name="get_related_id" datasource="#dsn#">
        SELECT PROPERTY_DETAIL_ID,VARIATION_ID FROM EZGI_CONNECT_PROPERTY WHERE PROPERTY_DETAIL_ID IN (#checked_id_list#)
    </cfquery>
    <cfset related_id_list = ValueList(get_related_id.VARIATION_ID)>
</cfif>
<cfif isdefined('attributes.is_form_submitted')>
    <cfquery name="get_products" datasource="#dsn3#">
    	WITH CTE1 AS(
			SELECT DISTINCT
				S.PRODUCT_ID, 
				S.STOCK_ID,
				PU.MAIN_UNIT, 
				S.BARCOD, 
				S.PRODUCT_NAME, 
				S.PRODUCT_CODE, 
				S.PRODUCT_CODE_2, 
				S.PROPERTY STOCK_NAME,
				S.TAX,
				S.PRODUCT_CATID, 
				ISNULL(S.BRAND_ID,0) AS BRAND_ID, 
				S.SHORT_CODE_ID,
				S.IS_KARMA,
                ISNULL((SELECT TOP (1) RELATED_ID FROM RELATED_PRODUCT WHERE PRODUCT_ID = S.PRODUCT_ID AND ISNULL(IS_TYPE,0) = 1),0) AS RELATED_PRODUCT_NECESSARY
			FROM     
				STOCKS AS S LEFT OUTER JOIN
				<cfloop query="get_property_group">
					(
						SELECT 
							PRODUCT_ID, 
							VARIATION_ID AS CATEGORI_ID
						FROM      
							#dsn1_alias#.PRODUCT_DT_PROPERTIES AS PRODUCT_DT_PROPERTIES_#get_property_group.PROPERTY_ID#
						WHERE   
							VARIATION_ID IN
										(
											SELECT 
												PROPERTY_DETAIL_ID
											FROM      
												#dsn1_alias#.PRODUCT_PROPERTY_DETAIL AS PRODUCT_PROPERTY_DETAIL_#get_property_group.PROPERTY_ID#
											WHERE   
												PRPT_ID = #get_property_group.PROPERTY_ID#
										)
					) AS CATEGORI_#get_property_group.PROPERTY_ID# ON S.PRODUCT_ID = CATEGORI_#get_property_group.PROPERTY_ID#.PRODUCT_ID LEFT OUTER JOIN
				</cfloop>
				#dsn1_alias#.PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
			WHERE  
				S.IS_EXTRANET = 1 AND
				S.STOCK_STATUS = 1 AND
				S.PRODUCT_STATUS = 1 
                <cfif session.ep.ISBRANCHAUTHORIZATION eq 1>
                	AND S.PRODUCT_ID IN (SELECT PRODUCT_ID FROM #dsn1_alias#.PRODUCT_BRANCH WHERE BRANCH_ID IN (SELECT BRANCH_ID FROM #dsn_alias#.EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE=#session.ep.position_code#))
                </cfif>
                <cfif attributes.sales_type eq 3 and Len(attributes.project_id)>
                	AND S.PRODUCT_ID IN (SELECT PRODUCT_ID FROM #dsn_alias#.EZGI_CONNECT_PROJECT_PRODUCT_ID WHERE PROJECT_ID = #attributes.project_id#)
                </cfif>
				<cfif isdefined('attributes.keyword') and len(attributes.keyword)>
					AND 
						(
							S.PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
							S.BARCOD = '#attributes.keyword#'
						)
				<cfelse> 
					<cfloop query="get_property_group">
						<cfif isdefined('attributes.categori_id_list_#get_property_group.PROPERTY_ID#') and ListLen(Evaluate('attributes.categori_id_list_#get_property_group.PROPERTY_ID#'))>
							AND CATEGORI_#get_property_group.PROPERTY_ID#.CATEGORI_ID IN (#Evaluate('attributes.categori_id_list_#get_property_group.PROPERTY_ID#')#)
						</cfif>
					</cfloop>
				</cfif>
		),
		CTE2 AS (
			SELECT
				CTE1.*,
				ROW_NUMBER() OVER (
					ORDER BY
						IS_KARMA DESC,						
						PRODUCT_NAME
				) AS RowNum,
				(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
			FROM
				CTE1
		)
		SELECT
			CTE2.*
		FROM
			CTE2
		WHERE
			RowNum BETWEEN #attributes.startrow# and #attributes.startrow# + (#attributes.maxrows# - 1)
    </cfquery>
    <cfset product_id_list = ValueList(get_products.PRODUCT_ID)>
    <cfset stock_id_list = ValueList(get_products.STOCK_ID)>
    <cfif attributes.sales_type eq 3 and Len(attributes.project_id)>
    	<cfquery name="get_project_disc" datasource="#dsn3#">
        	SELECT ISNULL(DISCOUNT_1,0) AS DISCOUNT_1, ISNULL(DISCOUNT_2,0) AS DISCOUNT_2, ISNULL(DISCOUNT_3,0) AS DISCOUNT_3 FROM PROJECT_DISCOUNTS WHERE PROJECT_ID = #attributes.project_id#
        </cfquery>
        <cfif get_project_disc.recordcount>
        	<cfif get_project_disc.DISCOUNT_1 gt 0>
            	<cfset proje_disc1 = get_project_disc.DISCOUNT_1>
            </cfif>
            <cfif get_project_disc.DISCOUNT_2 gt 0>
            	<cfset proje_disc2 = get_project_disc.DISCOUNT_2>
            </cfif>
            <cfif get_project_disc.DISCOUNT_3 gt 0>
            	<cfset proje_disc3 = get_project_disc.DISCOUNT_3>
            </cfif>
        </cfif>
    </cfif>
    <cfif ListLen(product_id_list)>
        <cfquery name="get_images" datasource="#dsn1#">
			SELECT 
				PI.PRODUCT_ID, 
				PI.PRODUCT_IMAGEID, 
				PI.PATH
			FROM     
				PRODUCT_IMAGES AS PI
				JOIN PRODUCT AS P ON P.PRODUCT_ID = PI.PRODUCT_ID
			WHERE   
				PI.PATH IS NOT NULL
				AND P.IS_EXTRANET = 1
                AND P.PRODUCT_ID IN (#product_id_list#)
        </cfquery>
		<cfset product_counter = 0>
		<cfset product_paths = structNew() />
        <cfoutput query="get_images">
			<cfif get_images.PRODUCT_ID eq get_images.PRODUCT_ID[currentRow - 1]>
				<cfset product_counter += 1>
			<cfelse>
				<cfset product_counter = 1>
				<cfset product_paths[PRODUCT_ID] = arrayNew(1) />
			</cfif>
			<cfset product_paths[PRODUCT_ID][product_counter] = PATH />
        </cfoutput>
        <cfif len(get_connect.PRICE_CAT_ID)>
            <cfquery name="GET_PRICE" datasource="#DSN3#">
                SELECT 
                	PRICE_ID,
                	PRODUCT_ID,
                    PRICE, 
                    PRICE_KDV, 
                    IS_KDV, 
                    MONEY
                FROM     
                    PRICE
                WHERE  
                    FINISHDATE IS NULL AND 
                    PRODUCT_ID IN (#product_id_list#) AND 
                    PRICE_CATID = #get_connect.PRICE_CAT_ID#
            </cfquery>
            <cfset price_cat_id=get_connect.PRICE_CAT_ID>
       	<cfelse>
        	<cfquery name="GET_PRICE" datasource="#DSN3#">
                SELECT 
                	PRICE_ID,
                	PRODUCT_ID,
                    PRICE, 
                    PRICE_KDV, 
                    IS_KDV, 
                    MONEY
                FROM     
                    PRICE
                WHERE  
                    FINISHDATE IS NULL AND 
                    PRODUCT_ID IN (#product_id_list#) AND 
                    PRICE_CATID = #attributes.default_pice_cat#
            </cfquery>
            <cfset price_cat_id=attributes.default_pice_cat>
        </cfif>
        <cfif GET_PRICE.recordcount>
        	<cfoutput query="GET_PRICE">
            	<cfset 'PRICE_ID_#PRODUCT_ID#' = PRICE_ID>
				<cfset 'PRICE_#PRODUCT_ID#' = PRICE>
                <cfset 'PRICE_KDV_#PRODUCT_ID#' = PRICE_KDV>
                <cfset 'MONEY_#PRODUCT_ID#' = MONEY>
            </cfoutput>
        </cfif>
        <cfif len(get_connect_defaults_row.IS_PRICE) and get_connect_defaults_row.IS_PRICE eq 1>
        	<cfset price_product_id_list = ValueList(GET_PRICE.product_id)>
            <cfif ListLen(price_product_id_list)>
            	<cfquery name="get_products" dbtype="query">
                	SELECT * FROM get_products WHERE PRODUCT_ID IN (#price_product_id_list#)
                </cfquery>
            <cfelse>
            	<script type="text/javascript">
					alert("Fiyat Listesine Bağlı Bu Seçeneklerde Hiç Ürün Yok!");
					window.close()
				</script>
                <cfabort>
            </cfif>
        </cfif>
        <!---İskonto Bulma--->
        <!---Müşteri İçin Tanımlanan İskonto Var mı--->
        <cfquery name="get_discount" datasource="#dsn3#">
        	SELECT 
            	PRICE_CAT_EXCEPTION_ID,
            	PRODUCT_CATID, 
                BRAND_ID, 
                PRODUCT_ID, 
                PRICE_CATID, 
                DISCOUNT_RATE DISCOUNT_RATE_1, 
                DISCOUNT_RATE_2, 
                DISCOUNT_RATE_3, 
                PAYMENT_TYPE_ID
			FROM     
            	PRICE_CAT_EXCEPTIONS
			WHERE 
            	<cfif len(get_connect.company_id)> 
            		COMPANY_ID = #get_connect.company_id# AND 
                <cfelseif len(get_connect.consumer_id)>
                	CONSUMER_ID = #get_connect.consumer_id# AND
                </cfif>
                ACT_TYPE = 1 AND
                PRICE_CATID = #get_connect.PRICE_CAT_ID#
        </cfquery>
        
        <cfif get_discount.recordcount>
        	<!---Tüm Kategoriler--->
            <cfquery name="get_all_p_cat" datasource="#dsn1#">
                SELECT PRODUCT_CATID, HIERARCHY FROM PRODUCT_CAT
            </cfquery>
            <cfloop list="#product_id_list#" index="i">
            	<cfset get_disc.recordcount = 0>
                <cfquery name="get_p_info" dbtype="query">
                	SELECT PRODUCT_ID, PRODUCT_CATID, BRAND_ID, SHORT_CODE_ID FROM get_products WHERE PRODUCT_ID = #i#
                </cfquery>
                <cfif len(get_p_info.PRODUCT_ID)>
                	<!---Ürün için--->
                    <cfquery name="get_disc" dbtype="query">
                        SELECT DISCOUNT_RATE_1, DISCOUNT_RATE_2, DISCOUNT_RATE_3 FROM get_discount WHERE PRODUCT_ID = #get_p_info.PRODUCT_ID#
                    </cfquery>
                </cfif>
                
                <cfif not get_disc.recordcount>
                	<!---Marka İçin--->
                	<cfif len(get_p_info.BRAND_ID)>
                        <cfquery name="get_disc" dbtype="query">
                            SELECT DISCOUNT_RATE_1, DISCOUNT_RATE_2, DISCOUNT_RATE_3 FROM get_discount WHERE BRAND_ID = #get_p_info.BRAND_ID#
                        </cfquery>
                    </cfif>
                    <cfif not get_disc.recordcount>
                    	<!---Kategori İçin--->
                    	<cfif len(get_p_info.PRODUCT_CATID)>
                            <cfquery name="get_pcat_id" dbtype="query">
                                SELECT HIERARCHY FROM get_all_p_cat WHERE PRODUCT_CATID = #get_p_info.PRODUCT_CATID#
                            </cfquery>
                            <cfquery name="get_pcat_ids" dbtype="query">
                                SELECT PRODUCT_CATID FROM get_all_p_cat WHERE HIERARCHY LIKE '%#get_pcat_id.HIERARCHY#%'
                            </cfquery>
							<cfif get_pcat_ids.recordcount>
                                <cfquery name="get_disc" dbtype="query">
                                    SELECT DISCOUNT_RATE_1, DISCOUNT_RATE_2, DISCOUNT_RATE_3 FROM get_discount WHERE PRODUCT_CATID IN (#ValueList(get_pcat_ids.PRODUCT_CATID)#)
                                </cfquery>
                            </cfif>
                    	</cfif>
                        <cfif not get_disc.recordcount>
                        	<cfquery name="get_disc" dbtype="query">
                                SELECT DISCOUNT_RATE_1, DISCOUNT_RATE_2, DISCOUNT_RATE_3 FROM get_discount ORDER BY PRICE_CAT_EXCEPTION_ID desc
                            </cfquery>
                        </cfif>
                    </cfif>
                </cfif>
                <cfif get_disc.recordcount>
                	<cfset 'disc1_#i#' = get_disc.DISCOUNT_RATE_1>
                    <cfset 'disc2_#i#' = get_disc.DISCOUNT_RATE_2>
                    <cfset 'disc3_#i#' = get_disc.DISCOUNT_RATE_3>
                </cfif>
            </cfloop>	
        </cfif>
        <!---İskonto Bulma--->
    </cfif>
<cfelse>
	<cfset get_products.recordcount = 0>
</cfif>

<cfif get_products.recordcount>
    <cfloop query="get_products">
        <cfif isdefined('PRICE_#PRODUCT_ID#')>
            <cfset price_id = Evaluate('PRICE_ID_#PRODUCT_ID#')>
            <cfset price = Evaluate('PRICE_#PRODUCT_ID#')>
            <cfset price_kdv = Evaluate('PRICE_KDV_#PRODUCT_ID#')>
            <cfset money = Evaluate('MONEY_#PRODUCT_ID#')>
        <cfelse>
            <cfset price_id = 0>
            <cfset price = 0>
            <cfset price_kdv = 0>
            <cfset money =''>
        </cfif>
        <cfif get_connect_defaults_row.IS_PRICE_KDV eq 1>
            <cfset row_net_other_ = PRICE_KDV> 
        <cfelse>
            <cfset row_net_other_ = price>
        </cfif>
        
        <cfif isdefined('get_disc') and get_disc.recordcount and price gt 0>
            <cfif isdefined('disc1_#product_id#') and Evaluate('disc1_#product_id#') gt 0>
                <cfset row_net_other_ = row_net_other_-(row_net_other_*Evaluate('disc1_#product_id#')/100)>
                <cfset disc1=Evaluate('disc1_#product_id#')>
            <cfelse>
                <cfset disc1=0>	
            </cfif>
            <cfif isdefined('disc2_#product_id#') and Evaluate('disc2_#product_id#') gt 0>
                <cfset row_net_other_ = row_net_other_-(row_net_other_*Evaluate('disc2_#product_id#')/100)>
                <cfset disc2=Evaluate('disc2_#product_id#')>
            <cfelse>
                <cfset disc2=0>	
            </cfif>
            <cfif isdefined('disc3_#product_id#') and Evaluate('disc3_#product_id#') gt 0>
                <cfset row_net_other_ = row_net_other_-(row_net_other_*Evaluate('disc3_#product_id#')/100)>
                <cfset disc3=Evaluate('disc3_#product_id#')>
            <cfelse>
                <cfset disc3=0>	
            </cfif>

        <cfelse>
            <cfset disc1=0>	
            <cfset disc2=0>
            <cfset disc3=0>	
        </cfif>
        <cfoutput>
            <div class="col col-3 col-md-4 col-sm-6 col-xs-12 product_card" type="column" index="1" sort="true">
                <div class="col col-12 col-xs-12" style="text-align:center">
                    <div class="product">
                        <div class="slider">
                            <a style="cursor:pointer;" onclick="windowopen('#request.self#?fuseaction=sales.popup_dsp_ezgi_connect_product_detail#url_str#&disc1=#disc1#&disc2=#disc2#&disc3=#disc3#&is_kdv=#get_connect_defaults_row.IS_PRICE_KDV#&price=<cfif get_connect_defaults_row.IS_PRICE_KDV eq 1>#PRICE_KDV#<cfelse>#price#</cfif><cfif RELATED_PRODUCT_NECESSARY gt 0>&related_product=1</cfif>&money=#money#&net_price=#row_net_other_#&product_id=#PRODUCT_ID#&stock_id=#STOCK_ID#&price_cat_id=#price_cat_id#&connect_id=#attributes.connect_id#&x_ssh=#attributes.x_ssh#<cfif isdefined("attributes.id_list") and len(attributes.id_list)>&id_list=#attributes.id_list#</cfif>','list');">
                                <cfif structCount(product_paths) and structKeyExists(product_paths,product_id)>
                                    <cfif arrayLen(product_paths[product_id])>
                                        <cfloop array="#product_paths[product_id]#" item="item" index="i">
                                            <img  alt="product" src="/documents/product/#item#"/> <!--- style="width:100%;height:#get_connect_defaults.IMAGE_SMALL_HEIGHT#px;" --->
                                        </cfloop>
                                    </cfif>
                                </cfif>
                            </a>
                        </div>
                        <cfif structCount(product_paths) and structKeyExists(product_paths,product_id)>
                            <cfif arrayLen(product_paths[product_id])>
                                <button class="prevBtn"><</button>
                                <button class="nextBtn">></button>
                            </cfif>
                        </cfif>
                    </div>
                    <div class="col col-12 col-xs-12" style="text-align:center;<cfif attributes.x_ssh eq 1>display:none</cfif>">
                        <div class="col col-8 col-xs-12 addBasket" style="height:50px;text-align:center; vertical-align:middle">
                        	<cfif RELATED_PRODUCT_NECESSARY gt 0>
                            	 <a style="cursor:pointer;" onclick="windowopen('#request.self#?fuseaction=sales.popup_dsp_ezgi_connect_product_detail#url_str#&disc1=#disc1#&disc2=#disc2#&disc3=#disc3#&is_kdv=#get_connect_defaults_row.IS_PRICE_KDV#&price=<cfif get_connect_defaults_row.IS_PRICE_KDV eq 1>#PRICE_KDV#<cfelse>#price#</cfif>&related_product=1&money=#money#&net_price=#row_net_other_#&product_id=#PRODUCT_ID#&stock_id=#STOCK_ID#&price_cat_id=#price_cat_id#&connect_id=#attributes.connect_id#&x_ssh=#attributes.x_ssh#<cfif isdefined("attributes.id_list") and len(attributes.id_list)>&id_list=#attributes.id_list#</cfif>','list');">
                            <cfelse>
                            	<a href="javascript://" onclick="add_product(this,'#stock_id#,#price#,#money#,#price_id#,#row_net_other_#,#disc1#,#disc2#,#disc3#');">
                           	</cfif> 
                                <button type="button" name="trasferring" style="width:100%; font-size:10px;border-radius:10px; font-weight:bold;height:35px;border:none;background-color: ##5f8ee1!important;color: white !important;">
                                    <i class="fa fa-shopping-basket" style="font-size:15px;"></i>&nbsp;&nbsp;
                                    <cfif isdefined('AMOUNT_#STOCK_ID#')>
                                        <span style="font-size:15px; color:white">(#Evaluate('AMOUNT_#STOCK_ID#')#)</span>
                                    </cfif>
                                </button>
                            </a>
                        </div>
                        <div class="col col-4 col-xs-12" style="height:50px;text-align:center; vertical-align:middle;<cfif RELATED_PRODUCT_NECESSARY gt 0>display:none</cfif>">
                            <a href="javascript://" onclick="select_product('#stock_id#,#price#,#money#,#price_id#,#row_net_other_#,#disc1#,#disc2#,#disc3#');">
                                <button type="button" name="selecting" style="width:100%;font-size:10px;font-weight:bold;height:35px;border:1px solid ##26262647!important;background: white;border-radius: 10px;">
                                    <select name="connect_amount_#STOCK_ID#" id="connect_amount_#STOCK_ID#" style="font-size:14px; font-weight:bold; height:100%; width:100%; background-color:	white; border:none;">
                                        <option value="0">0</option>
                                        <option value="1">1</option>
                                        <option value="2">2</option>
                                        <option value="3">3</option>
                                        <option value="4">4</option>
                                        <option value="5">5</option>
                                        <option value="6">6</option>
                                        <option value="7">7</option>
                                        <option value="8">8</option>
                                        <option value="9">9</option>
                                    </select>
                                </button>
                            </a>
                            <input type="hidden" id="is_active_id_#stock_id#" name="is_active_id_#stock_id#" value="0">
                            <input type="hidden" id="is_select_value_#stock_id#" name="is_select_value_#stock_id#" value="">
                        </div>
                    </div>
                    <div style="height:100px; width:100%;text-align:center; vertical-align:middle">
                        <div>
                            <span style="font-size:16px;">#left(PRODUCT_NAME,50)#</span><br />
                            <span style="font-size:12px;">#PRODUCT_CODE#</span>
                        </div>
                        <div>
							<span style="font-size:14px; font-family:Arial, Helvetica, sans-serif">
								<cfif get_connect_defaults_row.IS_PRICE_KDV eq 1>
                                 	<cfset first_price = PRICE_KDV>
                               		<cfif isdefined('proje_disc1') and proje_disc1 gt 0>
                                   		<cfset PRICE_KDV = (PRICE_KDV*(100-proje_disc1)/100)>
                                        <span style="font-style:italic; color:red"><del>#TlFormat(first_price,2)# #money#</del></span><br>
                                  	</cfif>
									#TlFormat(PRICE_KDV,2)# #money#
								<cfelse>
									#TlFormat(price,2)# #money#
								</cfif>
							</span>
						</div>
                        <cfif isdefined('get_disc') and get_disc.recordcount and price gt 0>
                            <div>
                                <span style="font-size:9px; height:10px; font-weight:bold">
                                    Özel Fiyat (#TlFormat(row_net_other_,2)# #money#)
                                </span>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div>
        </cfoutput>
    </cfloop>
</cfif>