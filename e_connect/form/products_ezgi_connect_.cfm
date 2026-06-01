<!--- <cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default= 20>
<cfparam name="attributes.startrow" default= 1> --->

<style>
	.product_card{
		height:300px;
		margin-top:10px;
	}
	.product {
		position: relative;
		width: 100%;
		height: 170px;
	}
	.slider {
		position: relative;
		overflow: hidden;
		width: 100%;
		height: 100%;
	}
	.slider img {
		height: 150px;
		object-fit: contain;
		position: absolute;
		left: 50%;
		top: 0;
		transform: translateX(-50%);
		max-width: 100%;
		opacity: 0;
	}
	.slider img.active {
		opacity: 1;
	}
	.prevBtn,
	.nextBtn {
		position: absolute;
		top: 88%;
		transform: translateY(-50%);
		font-size: 20px;
		font-weight: bold;
		color: #fff;
		background-color: rgb(185 185 185 / 88%);
		border: none;
		outline: none;
		padding: 8px 15px;
		cursor: pointer;
		margin: -65px 3px;
		border-radius: 10px;
	}
	@media screen and (max-width:1200px){
		.prevBtn,
		.nextBtn {
			padding:4px 10px!important;
		}
		.tabNavNew{
            height: 75px!important;
            align-items: normal!important;
        }
        .tabNavNew li{
            display:flex!important;
            width:105px!important;
        }
        .tabNavNew li a{
            width: 150px!important;
            text-align: center!important;
            font-size: 17px!important;
            display: flex!important;
            align-content: center!important;
            justify-content: center!important;
            align-items: center!important;
        }
	}
	.prevBtn:hover,.nextBtn:hover {
		background-color: rgb(143 143 143 / 88%);
	}
	.prevBtn {
		left: 0;
	}
	.nextBtn {
		right: 0;
	}
	.addBasket button:hover{
		background: #36918b;
    	transition: .4s;
	}

	#tab-list .first-li{
        font-weight: bold;
        border-right: 1px solid #ddd;
        text-align: center;
        width:100px;
        background-color: #44b6ae;
        color: #fff;
        flex:none;
        display: flex;
        align-items: center;
        justify-content: center;
        position:sticky;
        left:0;
    }
    #tab-list .first-li a,a:hover{
        color: #fff;
    }
    #tab-list .other-li{
        padding:0px;
        font-size:14px;
    }
    #tab-list .other-li a{
        width:150px;
        text-align:center;
    }
    .parent_li{
        background-color:#7bd9d2;
    }
    .tabNavNew{
        display: flex!important;
        overflow-x: auto!important;
        overflow-y: hidden!important;
        height: auto!important;
        width: 100%!important;
        flex-wrap: nowrap!important;
        justify-content: flex-start!important;
        align-items: normal!important;
    }
</style>
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
				S.IS_KARMA
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
            	<cfif attributes.x_ssh eq 0>  
					S.IS_EXTRANET = 1 AND
                </cfif>
				S.STOCK_STATUS = 1 AND
				S.PRODUCT_STATUS = 1 
                <cfif session.ep.ISBRANCHAUTHORIZATION eq 1 and attributes.x_ssh eq 0>
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
                  	AND S.PRODUCT_ID IN 
                    					(
                        					SELECT DISTINCT 
                                            	PRODUCT_ID
											FROM     
                                            	#dsn1_alias#.PRODUCT_DT_PROPERTIES
											WHERE  
                                            	VARIATION_ID IN
                      											(
                                                                	SELECT 
                                                                    	PROPERTY_DETAIL_ID
                       												FROM      
                                                                    	#dsn1_alias#.PRODUCT_PROPERTY_DETAIL
                       												WHERE   
                                                                    	PRPT_ID IN (#get_property_group_list#)
                                                              	)
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
						PRODUCT_CODE_2,
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
					alert("Fiyat Listesine Bağlı Olmayan Ürünl Mevcut!");
					window.location ="<cfoutput>#request.self#?fuseaction=sales.list_ezgi_connect&event=upd&connect_id=#attributes.connect_id#</cfoutput>";
				</script>
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

<cfparam name="attributes.totalrecords" default='#get_products.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

	<cfif x_left_menu neq 1>
		<cf_box>
			<cf_box_elements>
				<div class="col col-12">
					<div class="col col-8 col-xs-12">
						<div class="form-group" id="form_ul_keyword">
							<cfinput type="text" name="keyword" id="keyword" style="width:150px; height:35px" placeholder="Barcod Okutunuz" maxlength="50" value="#attributes.keyword#" onKeyPress="return noenter()">
						</div>
					</div>
					<div id="qr-reader" style="width:300px"></div>
					<div class="col col-4 col-xs-12">
						<input type="button" id="buton" name="buton" style="width:100%; height:35px; font-size:16px; font-weight:bold; border-color:gainsboro; color:white;margin:0px;" value="Ara" onclick="filtrele();">
					</div>
				</div>
			</cf_box_elements>
		</cf_box>
	</cfif>

	<div id="tab-list" <cfif x_top_menu neq 1> style="display:none;"</cfif>>
		<cfloop query="get_property_group">
			<cfquery name="get_categori" dbtype="query">
				SELECT 
					PROPERTY_DETAIL, 
					PROPERTY_DETAIL_ID,
					PROPERTY_DETAIL_CODE
				FROM
					get_properties
				WHERE
					PROPERTY_ID = #get_property_group.PROPERTY_ID#	
				GROUP BY
					PROPERTY_DETAIL, 
					PROPERTY_DETAIL_ID,
					PROPERTY_DETAIL_CODE
				ORDER BY
					PROPERTY_DETAIL_CODE
			</cfquery>
			<cfset category_counter = currentRow />
			<cfoutput>
				<div>
					<ul class="tabNav tabNavNew scrollContent" style="">
						<li class="first-li"><a href="javascript://" style="color:white!important;">#get_property_group.PROPERTY#</a></li>
						<cfloop query="get_categori">
							<li class="other-li <cfif Listlen(attributes.id_list) and ListFind(attributes.id_list,get_categori.PROPERTY_DETAIL_ID)>parent_li</cfif>" id="prop_detail_li_#get_categori.PROPERTY_DETAIL_ID#" <cfif Listlen(related_id_list) and not ListFind(related_id_list,get_categori.PROPERTY_DETAIL_ID)>style="display:none"</cfif>>
								<a href="javascript://" class="<cfif Listlen(attributes.id_list) and ListFind(attributes.id_list,get_categori.PROPERTY_DETAIL_ID)>active</cfif>" id="prop_detail_li_a_#get_categori.PROPERTY_DETAIL_ID#" onclick="category_change_header(this, #get_categori.PROPERTY_DETAIL_ID#, #category_counter#)">#get_categori.PROPERTY_DETAIL#</a>
							</li>
						</cfloop>
					</ul>
				</div>
			</cfoutput>
		</cfloop>
	</div>
	<div class="col col-3 col-xs-12" <cfif x_left_menu neq 1>style="display:none;"</cfif>>
		<cf_box>
			<cf_box_elements>
				<cfif x_left_menu eq 1>
					<div class="col col-12 col-xs-12">
						<div class="form-group" id="form_ul_keyword">
							<cfinput type="text" name="keyword" id="keyword" style="width:150px; height:20px" placeholder="Barcod Okutunuz" maxlength="50" value="#attributes.keyword#" onKeyPress="return noenter()">
						</div>
					</div>
					<div id="qr-reader" style="width:300px"></div>
					<div class="col col-12 col-xs-12">
						<input type="button" id="buton" name="buton" style="width:100%; height:35px; font-size:16px; font-weight:bold; border-color:gainsboro; color:white;margin:0px;" value="Ara" onclick="filtrele();">
					</div>
				</cfif>
				<cfloop query="get_property_group">
					<cfquery name="get_categori" dbtype="query">
						SELECT 
							PROPERTY_DETAIL, 
							PROPERTY_DETAIL_ID,
							PROPERTY_DETAIL_CODE
						FROM
							get_properties
						WHERE
							PROPERTY_ID = #get_property_group.PROPERTY_ID#	
						GROUP BY
							PROPERTY_DETAIL, 
							PROPERTY_DETAIL_ID,
							PROPERTY_DETAIL_CODE
						ORDER BY
							PROPERTY_DETAIL_CODE
					</cfquery>
					<div class="col col-12 col-xs-12" <cfif x_left_menu neq 1>style="display:none;"</cfif>>
						<cf_seperator title="#get_property_group.PROPERTY#" id="categori_#get_property_group.PROPERTY_ID#" closeForGrid="1">
						<div id="categori_<cfoutput>#get_property_group.PROPERTY_ID#</cfoutput>" class="col col-12 col-xs-12" style="display:none;">
							<cfoutput query="get_categori">
								<div id="prop_detail_#get_categori.PROPERTY_DETAIL_ID#" <cfif Listlen(related_id_list) and not ListFind(related_id_list,get_categori.PROPERTY_DETAIL_ID)>style="display:none"</cfif>>
									<label class="col col-10 col-xs-12" style="height:20px">#get_categori.PROPERTY_DETAIL#</label>
									<div class="col col-2 col-xs-12">
											<div class="checkbox checbox-switch">
												<label>
													<input type="checkbox" name="catagori_#get_categori.PROPERTY_DETAIL_ID#" id="catagori_#get_categori.PROPERTY_DETAIL_ID#" class="category_checkbox" onchange="catagori_change()" <cfif Listlen(attributes.id_list) and ListFind(attributes.id_list,get_categori.PROPERTY_DETAIL_ID)>checked</cfif> value="1" />
													<span></span>
												</label>
											</div>
									</div>
								</div>
							</cfoutput>
						</div>
					</div>
				</cfloop>
				
			</cf_box_elements>
		</cf_box>
	</div>
<div class="<cfif x_left_menu neq 1>col col-12 col-xs-12<cfelse>col col-9 col-xs-12"</cfif>>
	<cf_box id="product_ezgi_connect">
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
									<a style="cursor:pointer;" onclick="windowopen('#request.self#?fuseaction=sales.popup_dsp_ezgi_connect_product_detail#url_str#&disc1=#disc1#&disc2=#disc2#&disc3=#disc3#&price=#price#&money=#money#&net_price=#row_net_other_#&product_id=#PRODUCT_ID#&stock_id=#STOCK_ID#&price_cat_id=#price_cat_id#&connect_id=#attributes.connect_id#&id_list=#attributes.id_list#','list');">
										<cfif structCount(product_paths) and structKeyExists(product_paths,product_id)>
											<cfif arrayLen(product_paths[product_id])>
												<cfloop array="#product_paths[product_id]#" item="item" index="i">
													<img alt="product" src="/documents/product/#item#"/> <!--- style="width:100%;height:#get_connect_defaults.IMAGE_SMALL_HEIGHT#px;" --->
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
							<div class="col col-12 col-xs-12" style="text-align:center">
								<div class="col col-8 col-xs-12 addBasket" style="height:50px;text-align:center; vertical-align:middle;">
									<a href="javascript://" onclick="add_product(this,'#stock_id#,#price#,#money#,#price_id#,#row_net_other_#,#disc1#,#disc2#,#disc3#');">
										<button type="button" name="trasferring" style="width:100%; font-size:10px;border-radius:10px; font-weight:bold;height:35px;border:none;background-color: ##5f8ee1!important;color: white !important;">
											<i class="fa fa-shopping-basket" style="font-size:15px;"></i>&nbsp;&nbsp;
											<cfif isdefined('AMOUNT_#STOCK_ID#')>
												<span style="font-size:15px; color:white">(#Evaluate('AMOUNT_#STOCK_ID#')#)</span>
											</cfif>
										</button>
									</a>
								</div>
								<div class="col col-4 col-xs-12" style="height:50px;text-align:center; vertical-align:middle">
									<a href="javascript://" onclick="select_product('#stock_id#,#price#,#money#,#price_id#,#row_net_other_#,#disc1#,#disc2#,#disc3#');">
										<button type="button" name="selecting" style="width:100%;font-size:10px;font-weight:bold;height:35px;border:1px solid ##26262647!important;background: white;border-radius: 10px;">
											<!---<img style="display:none" id="is_active_#STOCK_ID#" src="/images/aktif.png" border="0">--->
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
									<span style="font-size:16px;">#left(PRODUCT_NAME,60)#</span><br />
									<span style="font-size:12px;">#PRODUCT_CODE#</span>
								</div>
								<div>
									<span style="font-size:14px; font-family:Arial, Helvetica, sans-serif">
										<cfif get_connect_defaults_row.IS_PRICE_KDV eq 1>
                                        	<cfset first_price = PRICE_KDV>
                                        	<cfif isdefined('proje_disc1') and proje_disc1 gt 0>
                                            	<cfset PRICE_KDV = PRICE_KDV - (Round(PRICE_KDV*100/proje_disc1)/100)>
                                          	</cfif>
                                            <cfif isdefined('proje_disc2') and proje_disc2 gt 0>
                                            	<cfset PRICE_KDV = PRICE_KDV - (Round(PRICE_KDV*100/proje_disc2)/100)>
                                          	</cfif>
                                            <cfif isdefined('proje_disc3') and proje_disc3 gt 0>
                                            	<cfset PRICE_KDV = PRICE_KDV - (Round(PRICE_KDV*100/proje_disc3)/100)>
                                          	</cfif>
                                            <span style="font-style:italic; color:red"><del>#TlFormat(first_price,2)# #money#</del></span>
											#TlFormat(first_price,2)# #money#
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
	</cf_box>
</div>
    
<!---<script src="AddOns\ezgi\e_connect\form\html5-qrcode-master\minified\html5-qrcode.min.js"></script>--->
<script type="text/javascript">
    var id_list = "";
	function filtrele(){
		<cfif Listlen(get_property_group_list)>
			<cfloop list="#get_property_group_list#" index="ii">
				categori_id_list_<cfoutput>#ii#</cfoutput> = '';
				<cfquery name="get_categori" dbtype="query">
                   SELECT PROPERTY_DETAIL_ID FROM get_properties WHERE PROPERTY_ID = #ii# GROUP BY PROPERTY_DETAIL_ID
              	</cfquery>
				<cfif get_categori.recordcount>
					<cfoutput query="get_categori">
						i = #PROPERTY_DETAIL_ID#;
						if(eval('document.all.catagori_'+i).checked==true)
						{
							categori_id_list_#ii# += i+',';
							id_list += i+',';
						}
					</cfoutput>
				</cfif>
				categori_id_list_<cfoutput>#ii#</cfoutput> = categori_id_list_<cfoutput>#ii#</cfoutput>.substr(0,categori_id_list_<cfoutput>#ii#</cfoutput>.length-1);
			</cfloop>
		</cfif>
		id_list = id_list.substr(0,id_list.length-1);
		if(list_len(id_list))
		{
            history.pushState("", "title", "<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_ezgi_connect&event=upd&connect_id=<cfoutput>#url.connect_id#</cfoutput>&is_form_submitted=1&keyword="+document.getElementById('keyword').value+"&id_list="+id_list+"<cfloop list="#get_property_group_list#" index="ii">&categori_id_list_<cfoutput>#ii#</cfoutput>="+categori_id_list_<cfoutput>#ii#</cfoutput>+"</cfloop>");
		}
		else
		{
			if(document.getElementById('keyword').value!=''){
                history.pushState("","title","<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_ezgi_connect&event=upd&connect_id=<cfoutput>#url.connect_id#</cfoutput>&is_form_submitted=1&keyword="+document.getElementById('keyword').value)+"&id_list=";
            }
			else
			{
				history.pushState("","title","<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_ezgi_connect&event=upd&connect_id=<cfoutput>#url.connect_id#</cfoutput>");
			}
		}
        dataTemplate();
	}
    function add_product(el, product_info)
    {
        addProductUrl='';
        select_list='';
        amount_list='';
		product_info_list = '';
		amount_info_list = '';

        <cfif get_products.recordcount>
            <cfoutput query="get_products">
                stockid = #get_products.STOCK_ID#;
                if(document.getElementById('is_active_id_'+stockid).value==1)
                {
                    amount = document.getElementById('connect_amount_'+stockid).value;
                    select_list += stockid+',';	
                    amount_list += amount+',';
                }
            </cfoutput>
        </cfif>
        if(list_len(select_list))
        {
            select_list = select_list.substr(0,select_list.length-1);
            amount_list = amount_list.substr(0,amount_list.length-1);
            select_list_len = list_len(select_list);
            
            for(var xx=1;xx<=select_list_len;xx++)
            {
                stockid=list_getat(select_list,xx);
                product_info_list +=document.getElementById('is_select_value_'+stockid).value+'-';
                amount_info_list +=document.getElementById('connect_amount_'+stockid).value+'-';
            }
            product_info_list = product_info_list.substr(0,product_info_list.length-1);
            amount_info_list = amount_info_list.substr(0,amount_info_list.length-1);
            if(list_len(product_info_list))
            {
                var addProductUrl ="<cfoutput>#request.self#?fuseaction=sales.emptypopup_add_ezgi_connect_row&#url_str#&connect_id=#attributes.connect_id#&price_cat_id=#get_connect.PRICE_CAT_ID#&id_list=#attributes.id_list#</cfoutput>&product_info_list="+product_info_list+"&amount_info_list="+amount_info_list+"&keyword="+document.getElementById('keyword').value;
            }
        }
        else
        {
            stock_id=list_getat(product_info,1);
            price=list_getat(product_info,2);
            money=list_getat(product_info,3);
            price_id=list_getat(product_info,4);
            net_price=list_getat(product_info,5);
            disc1=list_getat(product_info,6);
            disc2=list_getat(product_info,7);
            disc3=list_getat(product_info,8);
            if(price_id.length == 0)
            {
                alert('Fiyatı Olmayan Ürün Sepete Dahil Edilemez');
                return false;
            }
            else
                var addProductUrl ="<cfoutput>#request.self#?fuseaction=sales.emptypopup_add_ezgi_connect_row&#url_str#&connect_id=#attributes.connect_id#&price_cat_id=#get_connect.PRICE_CAT_ID#&id_list=#attributes.id_list#</cfoutput>&product_info_list="+product_info+"&amount_info_list=1&keyword="+document.getElementById('keyword').value;
        }
		var basketCounter = 0;
        if(addProductUrl != ''){
            $.ajax({
                url: addProductUrl,
                type: "GET",
                data: {},
                cache: false,
                processData: false,
                contentType: false,
                success: function ( response ) {
                    alert("<cf_get_lang dictionary_id='35458.Ürün Sepete Atıldı'>");
					if($(el).find("button > span").length > 0){
						basketCounter = parseInt($(el).find("button > span").text().replace('(','').replace(')',''));
					}else{
						$("<span>").css({"font-size": "15px", "color": "white"}).appendTo($(el).find('button'));
					}
					$(el).find("button > span").text( '(' + (basketCounter + parseInt((amount_info_list != '') ? amount_info_list : 1)) + ')');
                },
                beforeSend : function(){
                    $(el).find("button > i").removeClass("fa-shopping-basket").addClass("fa-cog fa-spin");
                },
                complete : function () {
                    $(el).find("button > i").removeClass("fa-cog fa-spin").addClass("fa-shopping-basket");
                }
            });
        }
		document.getElementById('keyword').focus();
    }
    
    function select_product(product_info)
    {
        stock_id=list_getat(product_info,1);
        price=list_getat(product_info,2);
        money=list_getat(product_info,3);
        price_id=list_getat(product_info,4);
        net_price=list_getat(product_info,5);
        disc1=list_getat(product_info,6);
        disc2=list_getat(product_info,7);
        disc3=list_getat(product_info,8);
        if(price_id.length == 0)
        {
            alert('Fiyatı Olmayan Ürün Sepete Dahil Etmek İçin Seçilemez');
            return false;
        }
        else
        {
            if(document.getElementById('is_active_id_'+stock_id).value==0)
            {
                document.getElementById('connect_amount_'+stock_id).style.display = '';
                document.getElementById('connect_amount_'+stock_id).value = 1;
                document.getElementById('is_active_id_'+stock_id).value = 1;
                document.getElementById('is_select_value_'+stock_id).value = product_info;
            }
            else
            {
                
                if(document.getElementById('connect_amount_'+stock_id).value == 0)
                {
                    document.getElementById('connect_amount_'+stock_id).style.display = 'none';
                    document.getElementById('is_active_id_'+stock_id).value = 0;
                    document.getElementById('is_select_value_'+stock_id).value = '';
                }
            }
        }
    }

    function sliderTool(products) {
        products.forEach((product) => {
            const slider = product.querySelector(".slider");
            const images = slider.querySelectorAll("img");
            const prevBtn = product.querySelector(".prevBtn");
            const nextBtn = product.querySelector(".nextBtn");
            let counter = 0;

            if( images.length ){

                images[counter].classList.add("active");

                prevBtn.addEventListener("click", function(event) {
                    event.preventDefault();
                    prevSlide();
                });
                nextBtn.addEventListener("click", function(event) {
                    event.preventDefault();
                    nextSlide();
                });

                function prevSlide() {
                    images[counter].classList.remove("active");
                    if (counter === 0) {
                    counter = images.length - 1;
                    } else {
                    counter--;
                    }
                    images[counter].classList.add("active");
                }

                function nextSlide() {
                    images[counter].classList.remove("active");
                    if (counter === images.length - 1) {
                    counter = 0;
                    } else {
                    counter++;
                    }
                    images[counter].classList.add("active");
                }

            }

        });
    }

    /* var products = document.querySelectorAll(".product"),
        showProductCount = products.length,
        showProductCountMax = <cfoutput>#get_products.recordCount ? get_products.QUERY_COUNT : 0#</cfoutput>;

    sliderTool(products); */

    var page = 1,
        startrow = 1,
        maxrows = <cfoutput>#attributes.maxrows#</cfoutput>,
        oldHeight = 0,
        pageEnd = false;

    window.onscroll = function(){
        
        var winScroll = Math.round(document.body.scrollTop || document.documentElement.scrollTop);
        var height = Math.round(document.documentElement.scrollHeight - document.documentElement.clientHeight);
        if((winScroll == height) && (oldHeight != height)){
            if(showProductCountMax > showProductCount) dataTemplate(true);
        }
        
    }

    function dataTemplate(scrool = false) {
        startrow = (scrool) ? (((page - 1) * maxrows) + 1) : startrow;

        $.ajax({
            url: "/index.cfm"+ document.location.search.replace("event=upd","event=get") +"&isAjax=1&startrow="+startrow+"&maxrows="+maxrows,
            type: "GET",
            data: {},
            cache: false,
            processData: false,
            contentType: false,
            success: function ( response ) {
                $("#product_ezgi_connect").find("#divPageLoad").remove();
                if(scrool) $("#product_ezgi_connect").append(response);
                else $("#product_ezgi_connect").html(response);
                var products = document.querySelectorAll(".product");
                showProductCount = products.length;
                sliderTool(products);
            },
            beforeSend : function(){
                $("#product_ezgi_connect").append(
                    '<div id="divPageLoad"><div class="col col-12" style="text-align:center;"><?xml version="1.0" encoding="utf-8"?><svg width="32px" height="32px" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid" class="uil-ring-alt"><rect x="0" y="0" width="100" height="100" fill="none" class="bk"></rect><circle cx="50" cy="50" r="40" stroke="rgba(255,255,255,0)" fill="none" stroke-width="10" stroke-linecap="round"></circle><circle cx="50" cy="50" r="40" stroke="#ff8a00" fill="none" stroke-width="6" stroke-linecap="round"><animate attributeName="stroke-dashoffset" dur="2s" repeatCount="indefinite" from="0" to="502"></animate><animate attributeName="stroke-dasharray" dur="2s" repeatCount="indefinite" values="150.6 100.4;1 250;150.6 100.4"></animate></circle></svg></td></tr>'
                );
                oldHeight = Math.round(document.documentElement.scrollHeight - document.documentElement.clientHeight);
            },
            complete : function () {
                page++;
            }
        });
    }

    dataTemplate();

	function catagori_change()
	{
		<cfif get_properties.recordcount>
			checked_id_list='';
			prop_det_id_list='';
			<cfoutput query="get_properties">
				prop_det_id = #PROPERTY_DETAIL_ID#;
				prop_det_id_list += prop_det_id+',';
				if(document.getElementById('catagori_'+prop_det_id).checked==true)
				{
					checked_id_list += prop_det_id+',';
					document.getElementById('prop_detail_li_a_'+prop_det_id).classList.add('active');
					document.getElementById('prop_detail_li_'+prop_det_id).classList.add('parent_li');
				}else{
					document.getElementById('prop_detail_li_a_'+prop_det_id).classList.remove('active');
					document.getElementById('prop_detail_li_'+prop_det_id).classList.remove('parent_li');
				}
			</cfoutput>
			prop_det_id_list = prop_det_id_list.substr(0,prop_det_id_list.length-1);
			checked_id_list = checked_id_list.substr(0,checked_id_list.length-1);//sondaki virgülden kurtariyoruz.
		</cfif>
		related_id_list='0,';
		if(list_len(checked_id_list))
		{
			/*var property_detail_sql = "SELECT PROPERTY_DETAIL_ID,VARIATION_ID FROM EZGI_CONNECT_PROPERTY WHERE PROPERTY_DETAIL_ID IN ("+checked_id_list+")";*/
			/*var get_property_detail = wrk_query(property_detail_sql,'dsn');*/
			
			var listParam = checked_id_list;
			var get_property_detail = wrk_safe_query('get_property_checked_id_list_ezgi','dsn',0,listParam)
			
			if(get_property_detail.recordcount != 0)
			{
				for(var xx=0;xx<get_property_detail.recordcount;xx++)
				{
					related_id_list += get_property_detail.VARIATION_ID[xx]+',';
				}
				related_id_list = related_id_list.substr(0,related_id_list.length-1);
			}
			if(list_len(prop_det_id_list))
			{
				for(var x=1;x<list_len(prop_det_id_list);x++)
				{
					cont_prop_det_id = list_getat(prop_det_id_list,x);
					if(list_find(related_id_list,cont_prop_det_id))
					{
						document.getElementById('prop_detail_'+cont_prop_det_id).style.display = '';	
						document.getElementById('prop_detail_li_'+cont_prop_det_id).style.display = '';	

					}
					else
					{
						document.getElementById('prop_detail_'+cont_prop_det_id).style.display = 'none';
						document.getElementById('prop_detail_li_'+cont_prop_det_id).style.display = 'none';
					}
				}
			}
		}
		else
		{
			if(list_len(prop_det_id_list))
			{
				for(var x=1;x<list_len(prop_det_id_list);x++)
				{
					cont_prop_det_id = list_getat(prop_det_id_list,x);
					document.getElementById('prop_detail_'+cont_prop_det_id).style.display = '';	
					document.getElementById('prop_detail_li_'+cont_prop_det_id).style.display = '';
					
				}
			}
		}
	}
	function category_change_header(element, prop_det_id, group_index) {
        if($("#catagori_"+prop_det_id+"").is(":checked")) $("#catagori_"+prop_det_id+"").prop("checked",false);
        else $("#catagori_"+prop_det_id+"").prop("checked",true);
        
        $(element).toggleClass('active');
        var parentLi = $(element).closest('li');
        $(parentLi).toggleClass('parent_li');

		catagori_change();
		var checkedCount = $(".category_checkbox:checked").length;
        if( group_index == 2 || group_index == 3 || checkedCount == 0 ){
            var button = document.getElementById('buton');
            if (button) {
                button.click();
            }
        }

    }
	function noenter() 
	{
		if(window.event && window.event.keyCode == 13)
		{
			filtrele();	
			document.getElementById('keyword').value='';
		}
	}
</script>