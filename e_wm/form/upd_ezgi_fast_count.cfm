<!---
    File: upd_ezgi_fast_count.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/12/2025
    Description: Raf Doğrulama
---> 
<cfparam name="attributes.anamenu" default="2">
<cfquery name="get_fis" datasource="#dsn3#">
    SELECT * FROM EZGI_WM_FAST_COUNT WHERE EZGI_WM_FAST_COUNT_ID = #attributes.fast_count_id#
</cfquery>
<cfif not get_fis.recordcount or not len(get_fis.PRODUCT_PLACE_ID)>
	<script type="text/javascript">
   		alert("Raf Bilgisi Bulunamamıştır!");
    	window.history.go(-1);
 	</script>
 	<cfabort>
</cfif>
<cfquery name="get_shelf_info" datasource="#dsn3#">
	SELECT SHELF_CODE FROM PRODUCT_PLACE WHERE PRODUCT_PLACE_ID = #get_fis.PRODUCT_PLACE_ID#
</cfquery>
<cfquery name="get_serial" datasource="#dsn3#">
    SELECT        
        E.SERIAL_NO, 
        E.PACKING_ID, 
        E.SPECT_ID, 
        E.IS_LOST_ITEM, 
        S.PRODUCT_NAME
	FROM        
     	EZGI_WM_FAST_COUNT_SERIAL_ROW AS E INNER JOIN
        STOCKS AS S ON E.STOCK_ID = S.STOCK_ID
	WHERE        
    	E.EZGI_WM_FAST_COUNT_ID = #attributes.fast_count_id#
	ORDER BY 
        E.SERIAL_NO
</cfquery>
<cfquery name="get_controlled" dbtype="query">
	SELECT * FROM get_serial  WHERE IS_LOST_ITEM = 0
</cfquery>
<cfquery name="get_not_controlled" dbtype="query">
	SELECT * FROM get_serial  WHERE IS_LOST_ITEM = 1
</cfquery>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
 	<cfform name="add_ezgi_fast_count" id="add_ezgi_fast_count" action="" method="post">
     	<cf_basket_form id="add_ezgi_package_transfer">
        	<div class="row">
          		<div class="col col-12 uniqueRow">
               		<div class="row formContent">
                  		<cf_box_footer>
                     		<div class="col col-12">
                            	<div class="col col-6" style="text-align:right">
                                	<cf_record_info 
                                        query_name="get_fis"
                                        record_emp="RECORD_EMP" 
                                        record_date="record_date"><br>
                                  	
									<cfoutput>
                                    	<cfif get_fis.PERIOD_ID eq session.ep.period_id>
                                        	<span style="color:green; font-weight:bold">
                                                <cf_get_lang dictionary_id="29629.Fire Fişi"> : #get_fis.STOCK_FIS_NUMBER#
                                            </span>
                                        <cfelse>
                                            <span style="color:red; font-weight:bold">
                                                <cf_get_lang dictionary_id="29629.Fire Fişi"> : #get_fis.STOCK_FIS_NUMBER#
                                            </span>
                                        </cfif>
                                    </cfoutput> 	     
                             	</div>
                             	<div class="col col-6" style="text-align:right;" id="onay_div">
                                  	<input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57432.Geri">" type="button" onClick="window.history.go(-1);" />
                            	</div>
                        	</div>
              			</cf_box_footer>
               		</div>
             	</div>
       		</div>
   		</cf_basket_form>
            
      	
        <cfsavecontent variable="sekme1"><cf_get_lang dictionary_id="57314.Kontrol Edilmiş"></cfsavecontent>
        <cfsavecontent variable="sekme2"><cf_get_lang dictionary_id="57315.Kontrol Edilmemiş"></cfsavecontent>
        <div id="basket_main_div">
        	<div class="row">
                <div class="col col-12 uniqueRow">
                    <cf_basket_form id="upd_connect" class="row">
                        <div id="tab-container" class="tabStandart margin-top-5">
                            <div id="tab-head">
                                <ul class="tabNav">
                                	<li class="<cfif attributes.anamenu eq 2>active</cfif>"><a id="href_minfo" href="#icerik"><cfoutput>#sekme2#</cfoutput></a></li>
                                    <li class="<cfif attributes.anamenu eq 1>active</cfif>"><a id="href_urunler" href="#ship_list"><cfoutput>#sekme1#</cfoutput></a></li>
                                    
                                </ul>
                            </div>
                            <div id="tab-content" class="margin-top-10"> 
                                <cfsavecontent variable="title"><cf_get_lang dictionary_id="45667.Raf"> : <cfoutput>#get_shelf_info.SHELF_CODE#</cfoutput></cfsavecontent>
                                
                                <div id="icerik" class="content row">
									<cf_box title="#title#">
                                        <cf_grid_list>
                                        	<thead>
                                                <tr>
                                                	<th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                    <th style="width:75px"><cf_get_lang dictionary_id='57637.Seri No'></th>
                                                    <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <cfif get_controlled.recordcount>
                                                    <cfoutput query="get_controlled">
                                                        <tr id="row#currentrow#" height="20">
                                                        	<td style="text-align:center">#currentrow#</td>
                                                            <td style="text-align:center">#SERIAL_NO#</td>        
                                                            <td style="text-align:left">#PRODUCT_NAME#</td>
                                                         </tr>
                                                    </cfoutput>
                                                </cfif>
                                            </tbody>
                                        
                                        </cf_grid_list>
                                    </cf_box>
                                </div>
                                
                                <div id="ship_list" class="content row">
                                    <cf_box title="#title#">
                                        <cf_grid_list>
                                            <thead>
                                                <tr>
                                                	<th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                    <th style="width:75px"><cf_get_lang dictionary_id='57637.Seri No'></th>
                                                    <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <cfif get_not_controlled.recordcount>
                                                    <cfoutput query="get_not_controlled">
                                                        <tr id="row#currentrow#" height="20">
                                                        	<td style="text-align:center">#currentrow#</td>
                                                            <td style="text-align:center">#SERIAL_NO#</td>        
                                                            <td style="text-align:left">#PRODUCT_NAME#</td>
                                                         </tr>
                                                    </cfoutput>
                                                </cfif>
                                            </tbody>
                                        </cf_grid_list>
                                    </cf_box>
                             	</div>
                                
                            </div>
                        </div>
                    </cf_basket_form>
                </div>
           	</div>                     
       	</div>                         
	</cfform>
</div>