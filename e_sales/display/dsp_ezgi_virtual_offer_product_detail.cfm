<!---
    File: dsp_ezgi_virtual_offer_product_detail.cfm
    Folder: Add_Ons\ezgi\e_sales\display
    Author: Ezgi Yazılım
    Date: 01/01/2024
    Description:
--->
<cfif isdefined('attributes.asset_company_id')>
	 <cfquery name="get_images" datasource="#dsn#">
     	SELECT DISTINCT
        	A.ASSETCAT_ID, 
          	A.ASSET_FILE_NAME, 
          	A.ASSET_DESCRIPTION, 
         	A.ASSET_ID, 
       		A.ASSET_FILE_FORMAT
		FROM     
        	#dsn#_#attributes.asset_company_id#.ORDER_ROW AS ORR INNER JOIN
        	#dsn#_#attributes.asset_company_id#.EZGI_CONNECT_ROW AS ECR ON ORR.WRK_ROW_RELATION_ID = ECR.WRK_ROW_RELATION_ID INNER JOIN
       		ASSET AS A ON ECR.CONNECT_ID = A.ACTION_ID
		WHERE  
       		ORR.ORDER_ID = #attributes.ORDER_ID# AND 
         	A.MODULE_ID = 13 AND 
          	A.ACTION_SECTION = 'OFFER_ID'
     </cfquery>
<cfelse>
    <cfquery name="get_images" datasource="#dsn1#">
        SELECT  
            1 AS TYPE,
            PATH 
        FROM 
            PRODUCT_IMAGES 
        WHERE 
            PRODUCT_ID = #attributes.pid#
        UNION ALL
        SELECT
            2 AS TYPE, 
            FILE_NAME AS PATH
        FROM     
            #dsn3_alias#.EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE
        WHERE  
            EZGI_ID = #attributes.EZGI_ID# AND 
            FILE_TYPE_ID = 5
    </cfquery>
</cfif>
<style>
	.product {
		position: relative;
		width: 100%;
		height: 100%;
	}
	.slider {
		position: relative;
		overflow: hidden;
		width: 100%;
		height: 100%;
	}
	.slider img {
		height: 300px;
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
		top: 50%;
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
</style>
<div id="basket_main_div">
    <div class="row">
        <div class="col col-12 uniqueRow">
            <cf_box title="Ürün Detayı" scroll="0" collapsable="0" resize="0" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
             	<div id="tab-container" class="tabStandart margin-top-5">
                	<div id="foto" class="input-group" style="display: flex;justify-content: center; height:600px; text-align: center; vertical-align: middle;">
							<div class="product">
								<div class="slider">
									<cfoutput>
                                    	<cfif isdefined('attributes.asset_company_id')>
                                        	<cfif get_images.recordcount>
                                            	<cfloop query="get_images">
                                                	<cfif len(get_images.ASSET_FILE_NAME)>
                                        				<img  alt="product" src="/documents/thumbnails/middle/#get_images.ASSET_FILE_NAME#"  style="height:100%;"/>
                                                    </cfif>
                                                </cfloop>
                                            </cfif>
                                        <cfelse>
											<cfif get_images.recordcount and len(get_images.path)>
                                                <cfloop query="get_images">
                                                    <cfif TYPE eq 1>
                                                        <img  alt="product" src="/documents/product/#get_images.path#"  style="height:100%;"/>
                                                    <cfelse>
                                                        <img src="/documents/temp/#get_images.path#"  style="height:100%;">
                                                    </cfif>
                                                </cfloop>
                                            <cfelse>
                                                <img  alt="product" src="/images/production/no-image.png" style="height:100%;"/>
                                            </cfif>	
                                        </cfif>
									</cfoutput>
								</div>
                                <cfif get_images.recordcount gt 1>
								<button class="prevBtn"><</button>
								<button class="nextBtn">></button>
                                </cfif>
							</div>
               		</div>
                </div>
            </cf_box>
        </div>
    </div>
</div>
<cfset url_str = "">

<script type="text/javascript">
	const products = document.querySelectorAll(".product");

	products.forEach((product) => {
	const slider = product.querySelector(".slider");
	const images = slider.querySelectorAll("img");
	const prevBtn = product.querySelector(".prevBtn");
	const nextBtn = product.querySelector(".nextBtn");
	let counter = 0;

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
	});
</script>
