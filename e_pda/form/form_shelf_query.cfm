<!---
    File: form_shelf_query.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<style type="text/css">
.boxtext {
	text-decoration: none;
	background-color: #e6e6fe;
	margin: 0px;
	padding: 0px;
	border-top-width: 0px;
	border-right-width: 0px;
	border-bottom-width: 0px;
	border-left-width: 0px;
}
.tablo {
	text-decoration: none;
	margin: 0px;
	padding: 0px;
	border-top-width: 1px;
	border-right-width: 0px;
	border-bottom-width: 1px;
	border-left-width: 0px;
	border-top-color: aec7f0;
	border-right-color: aec7f0;
	border-bottom-color: aec7f0;
	border-left-color: aec7f0;
}
</style>
<cfset get_barcode.recordcount = 0>
<cfparam name="attributes.add_other_barcod" default="">
<cfif isdefined('attributes.is_form_submitted') and len(attributes.is_form_submitted)>
	<cfquery name="get_barcode" datasource="#dsn3#">
    	SELECT        
        	TOP (1) SB.STOCK_ID, 
            S.PRODUCT_ID, 
            S.STOCK_CODE, 
            S.STOCK_CODE_2, 
            S.PRODUCT_NAME
		FROM 
        	STOCKS_BARCODES AS SB INNER JOIN
        	STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID
		WHERE        
        	SB.BARCODE = '#attributes.add_other_barcod#'
    </cfquery>
    <cfif get_barcode.recordcount>
        <cfquery name="get_shelf_query" datasource="#dsn2#">
            SELECT        
                PP.SHELF_CODE, 
                PPR.AMOUNT, 
                PP.PRODUCT_PLACE_ID, 
                ISNULL((
                        SELECT        
                            REAL_STOCK
                        FROM            
                            GET_STOCK_LAST_SHELF
                        WHERE        
                            SHELF_NUMBER = PP.PRODUCT_PLACE_ID AND 
                            STOCK_ID = PPR.STOCK_ID
                ), 0) AS REAL_STOCK
            FROM            
                #dsn3_alias#.PRODUCT_PLACE AS PP LEFT OUTER JOIN
                #dsn3_alias#.PRODUCT_PLACE_ROWS AS PPR ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID
            WHERE        
                PPR.STOCK_ID = 
                            (
                                SELECT        
                                    TOP (1) STOCK_ID
                                FROM            
                                    #dsn1_alias#.STOCKS_BARCODES
                                WHERE        
                                    BARCODE = '#attributes.add_other_barcod#'
                            )
            ORDER BY
                REAL_STOCK DESC
        </cfquery>
        <cfif isdefined('attributes.new_shelf_code') and len(attributes.new_shelf_code)>
        	<cfquery name="get_shelf" datasource="#dsn3#">
            	SELECT PRODUCT_PLACE_ID,SHELF_CODE FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE = '#attributes.new_shelf_code#'
            </cfquery>
            <cfif not get_shelf.recordcount>
				<script type="text/javascript">
                    alert("<cf_get_lang dictionary_id='338.Raf Barkodu Tanımlı Değil.'> <cf_get_lang dictionary_id='29938.Lütfen Kontrol Ediniz!'>");
                    history.back();	
                </script>
            <cfelse>
            	<cfquery name="get_product_shelf" dbtype="query">
                	SELECT * FROM get_shelf_query WHERE SHELF_CODE = '#attributes.new_shelf_code#'
             	</cfquery>
          		<cfif not get_product_shelf.recordcount>
               		<cfquery name="add_product_shelf" datasource="#dsn3#">
                    	INSERT INTO 
                      		PRODUCT_PLACE_ROWS
                         	(
                                PRODUCT_PLACE_ID, 
                                PRODUCT_ID, 
                                STOCK_ID, 
                                AMOUNT
                       		)
						VALUES        
                         	(
                                #get_shelf.PRODUCT_PLACE_ID#,
                                #get_barcode.PRODUCT_ID#,
                                #get_barcode.STOCK_ID#,
                                1
                       		)
               		</cfquery>
               		<script type="text/javascript">
						alert("<cf_get_lang dictionary_id='58890.Kaydedildi'>!");
						window.location.href='<cfoutput>#request.self#?fuseaction=pda.form_shelf_query'</cfoutput>;
					</script>
            	</cfif>
            </cfif>
        </cfif>
    </cfif>
</cfif>
<cfform name="form_shelf_query" action="#request.self#?fuseaction=pda.form_shelf_query" method="post">
	<cfinput type="hidden" name="is_form_submitted" value="1">
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    	<cf_box scroll="0">
        	<cf_box_search>
            	<div class="col col-12">
                	<div class="col col-4">
                    	<cf_get_lang dictionary_id='57633.Barkod'>
                    </div>
                	<div class="col col-4">
                    	<div class="form-group">
                            <cfinput value="#attributes.add_other_barcod#" id="add_other_barcod"  name="add_other_barcod" type="text">
                    	</div>
                    </div>
                    <cfif get_barcode.recordcount>
                        <div class="col col-4">
                            <div class="form-group">
                                <cfinput value="" id="new_shelf_code"  name="new_shelf_code" type="text" >
                            </div>
                        </div>
                    </cfif>
              	</div>
                <cfif get_barcode.recordcount gt 0>
                	<div class="col col-12">
                    	<div class="form-group">
                        	<span style="font-weight:bold">
                    			<cfoutput>#get_barcode.product_name#</cfoutput>
                          	</span>
                        </div>
                    </div>
                </cfif>
            </cf_box_search>
        </cf_box>
        <cfsavecontent variable="title"><cf_get_lang dictionary_id="12.Ürün Raf Tanımla"></cfsavecontent>
        <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
            <cf_form_list>
                <thead>
                    <tr>
                        <th style="width:100%"><cf_get_lang dictionary_id='45539.Raf Kodu'></th>
                        <th style="width:20%"><cf_get_lang dictionary_id='36420.Kapasite'></th>
                        <th style="width:20%"><cf_get_lang dictionary_id='58571.Mevcut'></th>
                   	</tr>
               	</thead>  
                <tbody>
                	<cfif isdefined('attributes.is_form_submitted') and len(attributes.is_form_submitted)>
						<cfif get_barcode.recordcount>
                            <cfif get_shelf_query.recordcount>
                                <cfoutput query="get_shelf_query">
                                	<tr>
                                  		<td align="center">#SHELF_CODE#</td>
                                  		<td align="right">#AMOUNT#</td>
                                  		<td align="right">#REAL_STOCK#</td> 
                                	</tr>
                                </cfoutput>
                            <cfelse>
                                <tr class="color-list">
                                  <td colspan="3" align="left"><cf_get_lang dictionary_id='365.Raf Bulunamadı'></td> 
                                </tr>
                            </cfif>
                        <cfelse>
                            <tr class="color-list">
                                <td colspan="3" align="left"><cf_get_lang dictionary_id='366.Ürün Barkodu Kayıtlı Değil'></td> 
                            </tr>
                        </cfif>
                    <cfelse>
                        <tr class="color-list">
                          <td colspan="3" align="left"><cf_get_lang dictionary_id='367.Ürün Barkodu Okutunuz'></td> 
                        </tr>
                    </cfif>
                </tbody>  
                <tfoot>
                	<tr>
                        <td colspan="3" align="right">
                            <input type="button" value="<cf_get_lang dictionary_id='58674.Yeni'>" name="yeni" onClick="yeniden_ara();">
                            <cfif not isdefined('attributes.is_form_submitted') or get_barcode.recordcount>
                                <input type="submit" value="<cf_get_lang dictionary_id='57565.Ara'>" name="ara">
                            </cfif>
                        </td> 
                    </tr>
                </tfoot>
          	</cf_form_list>
        </cf_box>
    </div>
</cfform>
<script language="javascript" type="text/javascript">
	<cfif isdefined('attributes.is_form_submitted') and get_barcode.recordcount gt 0>
		document.getElementById('new_shelf_code').focus();
		setTimeout("document.getElementById('new_shelf_code').select();",1000);
	<cfelse>
		document.getElementById('add_other_barcod').focus();
		setTimeout("document.getElementById('add_other_barcod').select();",1000);
	</cfif>
	function yeniden_ara()
	{
		window.location.href='<cfoutput>#request.self#?fuseaction=pda.form_shelf_query'</cfoutput>;
	}
</script>