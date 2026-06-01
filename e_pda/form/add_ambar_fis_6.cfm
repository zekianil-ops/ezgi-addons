<!---
    File: add_ambar_fis_6.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/03/2025
    Description: Sipariş Bazlı Ambar Fişi 
--->
<cfparam name="attributes.anamenu" default="1">
<cfparam name="attributes.department_in_id" default="">
<cfparam name="attributes.department_out_id" default="">
<cfparam name="attributes.process_cat_id" default="">
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfset default_process_type = '113,111'>
<cfquery name="get_default_departments" datasource="#dsn#">
    SELECT        
        DEFAULT_RF_TO_SV_DEP, 
        DEFAULT_RF_TO_SV_LOC
    FROM            
        EZGI_PDA_DEPARTMENT_DEFAULTS
    WHERE        
        EPLOYEE_ID = #session.ep.userid#
</cfquery>
<cfset default_departments = '#get_default_departments.DEFAULT_RF_TO_SV_DEP#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
<cfset attributes.department_out_id = "#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_LOC,1)#">
<cfset attributes.department_in_id ="#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_LOC,2)#">
<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>

<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT 
		D.DEPARTMENT_HEAD,
		SL.DEPARTMENT_ID,
		SL.LOCATION_ID,
		SL.STATUS,
		SL.COMMENT
	FROM 
		STOCKS_LOCATION SL,
		DEPARTMENT D,
		BRANCH B
	WHERE
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
		SL.STATUS = 1 AND
		D.BRANCH_ID = B.BRANCH_ID AND
        B.COMPANY_ID=#session.ep.company_id# 
</cfquery>
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT DISTINCT  
    	SPC.PROCESS_CAT_ID,
        SPC.PROCESS_CAT
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE IN (#default_process_type#) AND 
        SPCF.FUSE_NAME = 'pda.form_add_ambar_fis' 
  	ORDER BY
    	SPC.PROCESS_CAT_ID DESC      
</cfquery>
<cfif not get_process_cat.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='333.İşlem Kategorisi Tanımlayınız!'>");
		history.back();	
	</script>
</cfif>

<cfif isdefined('attributes.order_id')>
	<cfquery name="get_period_id" datasource="#dsn#">
    	SELECT TOP(1)       
        	PERIOD_YEAR
		FROM            
        	SETUP_PERIOD
		WHERE        
        	OUR_COMPANY_ID = #session.ep.company_id# AND 
            PERIOD_YEAR < #session.ep.period_year#
        ORDER BY
        	PERIOD_YEAR desc
	</cfquery>
    <cfset last_year = session.ep.period_year -1> 
	<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
    	SELECT 
        	SUM(TBL.PAKET_SAYISI) AS PAKETSAYISI, 
            TBL.ORDER_NUMBER, 
            TBL.STOCK_ID, 
            TBL.PRODUCT_NAME, 
            TBL.SPECT_MAIN_ID, 
            TBL.BARCOD, 
            ISNULL(TBL2.CONTROL_AMOUNT,0) AS CONTROL_AMOUNT
		FROM     
        	(
            	SELECT 
                	SUM(ORR.QUANTITY * EPS_1.PAKET_SAYISI) AS PAKET_SAYISI, 
                    O.ORDER_NUMBER, 
                    EPS_1.PAKET_ID AS STOCK_ID, 
                    P1.PRODUCT_NAME, 
                    P1.BARCOD, 
                    EPS_1.RELATED_MAIN_SPECT_ID AS SPECT_MAIN_ID
               	FROM      
                	(
                    	SELECT 
                        	SM.SPECT_MAIN_ID AS MODUL_SPECT_ID, 
                            SM.STOCK_ID AS MODUL_ID, 
                            SMR.STOCK_ID AS PAKET_ID, 
                            S2.BARCOD, 
                            SMR.AMOUNT AS PAKET_SAYISI, 
                            SMR.RELATED_MAIN_SPECT_ID
                   		FROM      
                        	SPECT_MAIN AS SM INNER JOIN
                            SPECT_MAIN_ROW AS SMR ON SM.SPECT_MAIN_ID = SMR.SPECT_MAIN_ID INNER JOIN
                            STOCKS AS S ON SM.STOCK_ID = S.STOCK_ID INNER JOIN
                            STOCKS AS S2 ON SMR.STOCK_ID = S2.STOCK_ID
                   		WHERE   
                        	ISNULL(S.IS_PROTOTYPE, 0) = 1 AND 
                            ISNULL(S.IS_KARMA, 0) = 0 AND 
                            S2.STOCK_CODE LIKE N'01.151.01.01%' AND 
                            S.PACKAGE_CONTROL_TYPE = 2
              		) AS EPS_1 INNER JOIN
                    ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                    SPECTS AS SP WITH (NOLOCK) ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
           			ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
                    #dsn1_alias#.PRODUCT AS P WITH (NOLOCK) ON ORR.PRODUCT_ID = P.PRODUCT_ID ON EPS_1.MODUL_SPECT_ID = SP.SPECT_MAIN_ID INNER JOIN
                 	#dsn1_alias#.PRODUCT AS P1 WITH (NOLOCK) INNER JOIN
               		#dsn1_alias#.STOCKS AS S WITH (NOLOCK) ON P1.PRODUCT_ID = S.PRODUCT_ID ON EPS_1.PAKET_ID = S.STOCK_ID
             	WHERE   
                	ORR.ORDER_ID = #attributes.order_id# AND 
                    ISNULL(P.IS_PROTOTYPE, 0) = 1
               	GROUP BY 
                	O.ORDER_NUMBER, 
                    P1.PRODUCT_NAME, 
                    P1.BARCOD, 
                    EPS_1.RELATED_MAIN_SPECT_ID, 
                    EPS_1.PAKET_ID
            	UNION ALL
                SELECT 
                	SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                    O.ORDER_NUMBER, 
                    EPS.PAKET_ID, 
                    P1.PRODUCT_NAME, 
                    P1.BARCOD, 
                    0 AS SPECT_MAIN_ID
               	FROM     
                	#dsn1_alias#.STOCKS AS S WITH (NOLOCK) INNER JOIN
                  	EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID INNER JOIN
                    #dsn1_alias#.PRODUCT AS P1 WITH (NOLOCK) ON S.PRODUCT_ID = P1.PRODUCT_ID INNER JOIN
                 	ORDER_ROW AS ORR WITH (NOLOCK) INNER JOIN
                    ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
                    #dsn1_alias#.PRODUCT AS P WITH (NOLOCK) ON ORR.PRODUCT_ID = P.PRODUCT_ID ON EPS.MODUL_ID = ORR.STOCK_ID
          		WHERE  
                	ORR.ORDER_ID = #attributes.order_id# AND 
                    ISNULL(P.IS_PROTOTYPE, 0) = 0
          		GROUP BY 
                	O.ORDER_NUMBER, 
                    EPS.PAKET_ID, 
                    P1.PRODUCT_NAME, 
                    P1.BARCOD
         	) AS TBL LEFT OUTER JOIN
          	(
                SELECT 
                	SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT, 
                    REF_NO, 
                    STOCK_ID, 
                    SPECT_MAIN_ID
            	FROM      
                	(
                    	SELECT 
                        	SUM(SFR.AMOUNT) AS CONTROL_AMOUNT, 
                            SF.REF_NO, 
                            SFR.STOCK_ID, 
                            ISNULL(SP.SPECT_MAIN_ID, 0) AS SPECT_MAIN_ID
                       	FROM      
                        	#dsn2_alias#.STOCK_FIS AS SF INNER JOIN
                         	#dsn2_alias#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                       		SPECTS AS SP ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                            STOCKS AS S ON SFR.STOCK_ID = S.STOCK_ID
                      	WHERE   
                        	SF.FIS_TYPE = 113 AND 
                            ISNULL(S.IS_PROTOTYPE, 0) = 1
                       	GROUP BY 
                        	SF.REF_NO, 
                            SFR.STOCK_ID, 
                            SP.SPECT_MAIN_ID
                    	UNION ALL
                     	SELECT 
                        	SUM(SFR.AMOUNT) AS CONTROL_AMOUNT, 
                            SF.REF_NO, 
                            SFR.STOCK_ID, 
                            0 AS SPECT_MAIN_ID
                      	FROM     
                        	#dsn2_alias#.STOCK_FIS AS SF INNER JOIN
                        	#dsn2_alias#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                       		STOCKS AS S ON SFR.STOCK_ID = S.STOCK_ID
                       	WHERE  
                        	SF.FIS_TYPE = 113 AND 
                            ISNULL(S.IS_PROTOTYPE, 0) = 0
                   		GROUP BY 
                        	SF.REF_NO, 
                            SFR.STOCK_ID
         			) AS TBL_5
             	GROUP BY 
                	REF_NO, 
                    STOCK_ID, 
                    SPECT_MAIN_ID
     		) AS TBL2 ON TBL.STOCK_ID = TBL2.STOCK_ID AND TBL.SPECT_MAIN_ID = TBL2.SPECT_MAIN_ID AND TBL.ORDER_NUMBER = TBL2.REF_NO
		GROUP BY 
        	TBL.ORDER_NUMBER, 
            TBL.STOCK_ID, 
            TBL.PRODUCT_NAME, 
            TBL.SPECT_MAIN_ID, 
            TBL.BARCOD,
            TBL2.CONTROL_AMOUNT
		ORDER BY 
        	TBL.SPECT_MAIN_ID, 
            TBL.PRODUCT_NAME
    </cfquery>

    <cfquery name="get_total_control" dbtype="query">
        SELECT sum(CONTROL_AMOUNT) AS CONTROL_AMOUNT FROM GET_SHIP_PACKAGE_LIST
    </cfquery>
    <cfquery name="get_total_package" dbtype="query">
        SELECT sum(PAKETSAYISI) PAKETSAYISI FROM GET_SHIP_PACKAGE_LIST
    </cfquery>
    <cfquery name="get_detail_package_group" dbtype="query">
        SELECT
            SPECT_MAIN_ID,
            STOCK_ID,
            COUNT(*) AS CONTROL_AMOUNT
        FROM
            GET_SHIP_PACKAGE_LIST
        GROUP BY
            SPECT_MAIN_ID,
            STOCK_ID	 	
    </cfquery>	
	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    	<cf_box scroll="0">
            <cf_box_search>
            	<div class="col col-12" id="area_1">
                    <div class="col col-12">
                        <div class="col col-4">
                            <cf_get_lang dictionary_id='57635.Miktar'>
                        </div>
                        <div class="col col-4">
                            <cf_get_lang dictionary_id='57633.Barkod'>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="col col-6">
                            <div class="form-group">
                                <input id="add_other_amount" name="add_other_amount" type="text" onfocus="islemtipi=0;" style=" text-align:right" maxlength="6" value="1" readonly />
                                <input id="add_read_amount" name="add_read_amount" type="hidden" value="0" />
                            </div>
                        </div>
                        <div class="col col-6">
                            <div class="form-group">
                                <input id="add_other_barcod" name="add_other_barcod" type="text"  maxlength="30" value="" />
                            </div>
                        </div>
                    </div>
              	</div>
                <div class="col col-12" id="area_2">
                    <div class="col col-12">
                        <div class="col col-6">
                            <cf_get_lang dictionary_id='29428.Çıkış Depo'>
                        </div>
                        <div class="col col-6">
                            <cf_get_lang dictionary_id='33658.Giriş Depo'>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="col col-6">
                            <div class="form-group">
                                <select name="txt_department_out"  id="txt_department_out" style="width:120px; height:20px">
                                    <cfoutput query="get_all_location" group="department_id">
                                        <option disabled="disabled" value="#department_id#"<cfif attributes.department_out_id eq department_id>selected</cfif>>#department_head#</option>
                                    <cfoutput>
                                    <option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_out_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#<cfif not status>-<cf_get_lang dictionary_id='57494.Pasif'></cfif></option>
                                    </cfoutput> 
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="col col-6">
                            <div class="form-group">
                                <select name="txt_department_in"  id="txt_department_in" style="width:120px; height:20px">
                                    <cfoutput query="get_all_location" group="department_id">
                                       <option disabled="disabled"  value="#department_id#"<cfif attributes.department_in_id eq department_id>selected</cfif>>#department_head#</option>
                                    <cfoutput>
                                    <option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_in_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#<cfif not status>-<cf_get_lang dictionary_id='57494.Pasif'></cfif></option>
                                    </cfoutput> 
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </div>
             	</div>
                <div class="col col-12" id="area_3">
                    <div class="col col-12">
                        <div class="col col-12">
                            <cf_get_lang dictionary_id='45271.Fiş Tipi'>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="col col-12">
                            <div class="form-group">
                                <select name="process_cat_id" id="process_cat_id" style="height:20px">
                                	<cfoutput query="get_process_cat">
                                    	<option value="#PROCESS_CAT_ID#"<cfif attributes.process_cat_id eq PROCESS_CAT_ID>selected</cfif>>#PROCESS_CAT#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col col-12" id="fourth_area">
                	<div class="col col-12">
                	    <cfoutput>
                	  	<div class="col col-6">
                	        <div class="form-group" id="item-serial_control">
                	            <input type="text" name="total_control_amount" readonly="readonly" class="box" style="width:25px;text-align:right;font-weight:bold;color:FF0000;" id="total_control_amount" value="#get_total_control.CONTROL_AMOUNT#" />
                	        </div>
                	    </div>
                	    <div class="col col-6">
                	        <div class="form-group" id="item-serial_controled">
                	        	<input type="text" name="total_paket_sayisi" readonly="readonly" class="box" style="width:25px;text-align:right;font-weight:bold;color:FF0000;" id="total_paket_sayisi" value="#get_total_package.PAKETSAYISI#" />
                	   		</div>
                	    </div>
                	    </cfoutput>
                	</div>
           		</div>
           	</cf_box_search>
            <cf_box_footer>
          		<div class="col col-12">
                 	<div class="col col-4" style="text-align:right">
               		</div>
                    <div class="col col-4" style="text-align:right;display:none" id="goto_control">
                    	<input id="order_row" name="order_row" style="width:100%" value="<cf_get_lang dictionary_id="29630.Ambar Fişi">" type="button" onClick="window.location.reload();" />
                 	</div>
                    <div class="col col-4" style="text-align:right;" id="order_row_div">
                    	<input id="order_row" name="order_row" style="background-color:orange; color:white; width:100%" value="<cf_get_lang dictionary_id="57611.Sipariş">" type="button" onClick="order_row_kontrol();" />
                 	</div>
                	<div class="col col-4" style="text-align:right;display:none" id="onay_div">
                    	<input id="onay" name="Onay" style="width:100%" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" onClick="kontrol_kayit(1);" />
                 	</div>
                 	<div class="col col-4" style="text-align:right;" id="vazgec_div">
                     	<input id="vazgec" name="vazgec" style="background-color:red; color:white; width:100%" value="<cf_get_lang dictionary_id="57462.Vazgeç">" type="button" onClick="kontrol_kayit(2);" />
                 	</div>
          		</div>
        	</cf_box_footer>
        </cf_box>
        <cfsavecontent variable="sekme1"><cf_get_lang dictionary_id='45228.Siparişler'></cfsavecontent>
        <cfsavecontent variable="sekme2"><cf_get_lang dictionary_id='54447.Kontrol Edilenler'></cfsavecontent>
        <cfsavecontent variable="sekme3"><cf_get_lang dictionary_id='37244.Palet'></cfsavecontent>
        <cfsavecontent variable="sekme4"><cf_get_lang dictionary_id='1362.Palet İçi'></cfsavecontent>

        <cfform name="shipping_ambar_fis" >
		<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
        <div id="basket_main_div">
        	<div class="row">
                <div class="col col-12 uniqueRow">
                    <cf_basket_form id="upd_connect" class="row">
                        <div id="tab-container" class="tabStandart margin-top-5">
                            <div id="tab-head">
                                <ul class="tabNav">
                                  	<li class="<cfif attributes.anamenu eq 1>active</cfif>"><a id="href_urunler" href="#ship_list"><cfoutput>#sekme1#</cfoutput></a></li>
                                    <li class="<cfif attributes.anamenu eq 2>active</cfif>"><a id="href_minfo" href="#icerik"><cfoutput>#sekme2#</cfoutput></a></li>
                                    <li class="<cfif attributes.anamenu eq 3>active</cfif>"><a id="href_palet" href="#palet"><cfoutput>#sekme3#</cfoutput></a></li>
                                    <li class="<cfif attributes.anamenu eq 4>active</cfif>"><a id="href_palet_ici" href="#palet_ici"><cfoutput>#sekme4#</cfoutput></a></li>
                                </ul>
                            </div>
                      		<div id="tab-content" class="margin-top-10"> 
                                <div id="ship_list" class="content row">
                                	<cfsavecontent variable="title">
                                    	<cf_get_lang dictionary_id="1367.Sipariş  Bazlı Ambar Fişi"> : 
										<cfoutput>
                                        	<cfif GET_SHIP_PACKAGE_LIST.recordcount>#GET_SHIP_PACKAGE_LIST.ORDER_NUMBER#</cfif>
										</cfoutput>
                                   	</cfsavecontent>
                                    	<cf_box title="#title#">
                                    	
                                            <table cellspacing="0" cellpadding="2" border="1" style="width:100%">
                                                <tr>
                                                    <td ><cf_get_lang dictionary_id='58577.Sıra'></td>
                       								<td ><cf_get_lang dictionary_id='58221.Ürün Adı'></td>
                        							<td ><cf_get_lang dictionary_id='57635.Miktar'></td>
                        							<td ><cf_get_lang dictionary_id='45358.Kontrol'></td>
                                                </tr>

                                            	<cfif GET_SHIP_PACKAGE_LIST.recordcount>
                                                	
                                                	<cfoutput query="GET_SHIP_PACKAGE_LIST">
                                                    	<cfif isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')>
															<cfset 'control_amount#currentrow#' = Evaluate('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')>
                                                       	<cfelse>
                                                        	<cfset 'control_amount#currentrow#' = ''>
                                                        </cfif>
                                                    	<cfinput type="hidden" name="row_control_#currentrow#" id="row_control_#currentrow#" value="#STOCK_ID#_#SPECT_MAIN_ID#" >
                                                        <tr id="row#currentrow#" height="20" <cfif PAKETSAYISI eq CONTROL_AMOUNT>style="display:none"</cfif>>
                                                        	<td width="25" style="text-align:right">#CURRENTROW#</td>
                                                            <td>#product_name#<cfif SPECT_MAIN_ID gt 0><font color="red"> - #SPECT_MAIN_ID#</font></cfif></td>        
                                                                <input type="hidden" id="PRODUCT_NAME#currentrow#" name="PRODUCT_NAME#currentrow#" value="#PRODUCT_NAME#">
                                                            <td style="text-align:right; width:20px">
                                                                <input type="text" name="amount#currentrow#" id="amount#currentrow#" value="#PAKETSAYISI#" readonly="yes" style="width:25px;text-align:right;">
                                                            </td>
                                                            <td style="text-align:right; width:20px">
                                                                <input type="text" id="control_amount#currentrow#" name="control_amount#currentrow#" value="#CONTROL_AMOUNT#" class="box"  style="width:25px;text-align:right;color:FF0000;">
                                                            </td>
                                                       	
                                                        </tr>
                                                    </cfoutput>
                                                </cfif>
                           					</table>
                                      	</cf_box>
                                </div>
                             	<div id="icerik" class="content row">
									<cf_box title="#title#">
                                        <cf_grid_list>
                                            <thead>
                                                <tr>
                                                	<th style="width:20px"></th>
                                                	<th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                    <th><cf_get_lang dictionary_id='57633.Barkod'></th>
                                                    <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                                    <th style="width:35px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                                </tr>
                                            </thead>
                                            <cfinput type="hidden" id="row_count_content" name="row_count_content" value="0">
                                            <input type="hidden" id="action_id" name="action_id" value="" />
                                         	<tbody name="table2" id="table2">
                                                    	
                                       		</tbody>
                                        </cf_grid_list>
                                    </cf_box>
                                </div>
                                <div id="palet" class="content row">
									<cf_box title="#title#">
                                        <cf_grid_list>
                                            <thead>
                                                <tr>
                                                	<th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                    <th><cf_get_lang dictionary_id='1312.Palet Barkodu'></th>
                                                </tr>
                                            </thead>
                                            <cfinput type="hidden" id="row_count_palet" name="row_count_palet" value="0">
                                         	<tbody name="table3" id="table3">
                                                    	
                                       		</tbody>
                                        </cf_grid_list>
                                    </cf_box>
                                </div>
                                <div id="palet_ici" class="content row">
									<cf_box title="#title#">
                                        <cf_grid_list>
                                            <thead>
                                                <tr>
                                                	<th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                    <th><cf_get_lang dictionary_id='57633.Barkod'></th>
                                                    <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                                    <th style="width:35px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                                </tr>
                                            </thead>
                                            <cfinput type="hidden" id="row_count_palet_ici" name="row_count_palet_ici" value="0">
                                         	<tbody name="table4" id="table4">
                                                    	
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
    <script language="javascript" type="text/javascript">
		document.getElementById('add_other_barcod').focus();
		setTimeout("document.getElementById('add_other_barcod').select();",1000);
		document.onkeydown = checkKeycode
		function checkKeycode(e) /*Barkod Okuyup Enter Basıldığında*/
		{
			var keycode;
			if (window.event) keycode = window.event.keyCode;
			else if (e) keycode = e.which;
			if (keycode == 13)
			{
				if (document.getElementById('add_other_barcod').value.length == '') /*Barkod Boşsa*/
				{
					alert('<cf_get_lang dictionary_id='340.Önce Ürün Barkodu Okutunuz'>'); 
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus();	
				}
				else /*Barkod Doluysa*/
				{
					palet_ici_sil();
					get_stock(document.getElementById('add_other_barcod').value);
				}
			}
		}
		function get_stock(barcode) /*Ürün Kontrolü*/
		{
			row_count_sevk = <cfoutput>#GET_SHIP_PACKAGE_LIST.recordcount#</cfoutput>;
			row_count_content = document.getElementById('row_count_content').value;
			if(document.getElementById('add_other_amount').value.length == 0 || document.getElementById('add_other_amount').value==0)
			{
				alert('<cf_get_lang dictionary_id='29943.Lütfen miktar giriniz.'>');
				document.getElementById('add_other_amount').value = 1;
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcod').focus();
				return false;
			}
			if(barcode.substr(0,1)=='j')//Bazı barkod okuyucular okuduktan sonra başına j harfi koyuyor kontrol için yapıldı
				barcode = barcode.substring(1,length(barcode));
			uzunluk = barcode.length;
			spectmainid = 0;
			ean = <cfoutput>#get_defaults.EAN#</cfoutput>;
			if(uzunluk > ean)
			{
				spectmainid = barcode.substring(ean,uzunluk);
				barcode = barcode.substring(0,ean);
			}
			let[carpan, birim, stockid, productname,type]=urunbul(barcode,spectmainid);
			if(type==1)
			{
				let [buldum,seri_spect]=sevk_satirbul(row_count_sevk,stockid,spectmainid);
				if(buldum==0)
				{
					alert('Paket Bu Siparişin Ürünü Değildir. !');
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
					return false;
				}	
				else
				{
					if((document.getElementById('add_other_amount').value*1)+(document.getElementById('control_amount'+buldum).value*1) > (document.getElementById('amount'+buldum).value*1))
					{
						alert(document.getElementById('PRODUCT_NAME'+buldum).value+' <cf_get_lang dictionary_id='379.Fazla Çıkış'>');
						document.getElementById('add_other_amount').value=1;
						document.getElementById('add_other_amount').focus();
					}
					else
					{
						stokkontrol(barcode,stockid,spectmainid,productname);	
					}
				}
			}
			else
			{
				var listParam = barcode;
				var get_palet = wrk_safe_query('get_packing_content_barcode_ezgi','dsn3',0,listParam);
				palet_barcode = barcode;
				if(get_palet.recordcount)
				{
					for(j=0;j<get_palet.recordcount;j++)
					{
						barcode = get_palet.BARCOD[j];
						productname = get_palet.PRODUCT_NAME[j];
						stockid = get_palet.STOCK_ID[j];
						spectmainid = get_palet.SPECT_MAIN_ID[j];
						if(spectmainid=='')
							spectmainid=0;
						document.getElementById('add_other_amount').value = get_palet.AMOUNT[j]; 
						add_row_palet_ici(barcode,stockid,spectmainid,productname,document.getElementById('add_other_amount').value);
						
						let [buldum,seri_spect]=sevk_satirbul(row_count_sevk,stockid,spectmainid);
						if(buldum==0)
						{
							alert('Paket Bu Siparişin Ürünü Değildir. !');
							document.getElementById('add_other_barcod').value = '';
							document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
							return false;
						}	
						else
						{
							if((document.getElementById('add_other_amount').value*1)+(document.getElementById('control_amount'+buldum).value*1) > (document.getElementById('amount'+buldum).value*1))
							{
								alert(document.getElementById('PRODUCT_NAME'+buldum).value+' <cf_get_lang dictionary_id='379.Fazla Çıkış'>');
								palet_geri();
								document.getElementById('add_other_amount').value=1;
								document.getElementById('add_other_barcod').value = '';
								document.getElementById('add_other_barcod').focus();
								return false;
							}
							else
							{
								stokkontrol(barcode,stockid,spectmainid,productname);	
							}
						}
					}
					palet_add_row(palet_barcode);
				}
			}
		}
		function buton_kontrol()
		{
			document.getElementById('onay_div').style.display='';
			document.getElementById('order_row_div').style.display='none';
		}
		function add_row(barcode,stockid,spect,productname,shelfcode,amount)
		{
			row_count_content = document.getElementById('row_count_content').value;
			row_count_content++;
			document.getElementById('row_count_content').value = row_count_content;
			var newRow;
			var newCell;	
			newRow = document.getElementById("table2").insertRow(document.getElementById("table2").rows.length);
			newRow.setAttribute("name","frm_row" + row_count_content);
			newRow.setAttribute("id","frm_row" + row_count_content);		
			newRow.setAttribute("NAME","frm_row" + row_count_content);
			newRow.setAttribute("ID","frm_row" + row_count_content);		
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<a onclick="sil(' + row_count_content + ');"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>';
						
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="hidden" name="row_control_content_'+row_count_content+'" id="row_control_content_'+row_count_content+'" value="'+stockid+'_'+spect+'"><input name="STOCK_ID'+row_count_content+'" id="STOCK_ID'+row_count_content+'" type="hidden" value="'+stockid+'"><input name="SPECT_MAIN_ID'+row_count_content+'" id="SPECT_MAIN_ID'+row_count_content+'" type="hidden" value="'+spect+'"><input name="row_number'+row_count_content+'" type="text" value="'+row_count_content+'"text-align:right">';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="BARCODE'+row_count_content+'" id="BARCODE'+row_count_content+'" type="text" value="'+barcode+'">';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="PRODUCT_NAME'+row_count_content+'" id="PRODUCT_NAME'+row_count_content+'" type="text" value="'+productname+'">';
			
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="SEVK_AMOUNT'+row_count_content+'" id="SEVK_AMOUNT'+row_count_content+'" type="text" value="'+amount+'" >';
		}
		
		function sil(sy)
		{
			row_count_sevk = <cfoutput>#GET_SHIP_PACKAGE_LIST.recordcount#</cfoutput>;
			barcode = document.getElementById('BARCODE'+sy).value;
			spectmainid = document.getElementById('SPECT_MAIN_ID'+sy).value;
			stockid = document.getElementById('STOCK_ID'+sy).value;
			amount = document.getElementById('SEVK_AMOUNT'+sy).value;
			sor=confirm(barcode+' Borkodlu Ürünü Ambar Fişinden Çıkarıyorum.')
			if(sor==true)
			{
				buldum=0;
				document.getElementById('frm_row'+sy).style.display='none';
				document.getElementById('row_kontrol'+sy).value = 0;
				for(i=1;i<=row_count_sevk;i++)
				{
					satir_spect = document.getElementById('row_control_'+i).value;
					seri_spect = stockid+'_'+spectmainid;
					if(satir_spect==seri_spect)
						buldum=i;
				}
				if(buldum==0)
				{
					alert('Sorun Var. !');
				}
				else
				{
					document.getElementById('control_amount'+buldum).value = (document.getElementById('control_amount'+buldum).value*1)-(amount*1);
					document.getElementById('row'+buldum).style.display='';
					document.getElementById('total_control_amount').value = (document.getElementById('total_control_amount').value*1)-(amount*1);
				}
				if(document.getElementById('total_control_amount').value == 0)
				{
					document.getElementById('onay_div').style.display='none';	
					document.getElementById('order_row_div').style.display='';
				}
			}
		}
		function kontrol_kayit(type)
		{
			if(type==1)
			{
				sor = confirm('<cf_get_lang dictionary_id='57535.Kaydetmek İstediğinizden Emin Misiniz?'>');
				if(sor==true)
				{
					actionidolustur();
					window.location.href='<cfoutput>#request.self#?fuseaction=pda.add_ambar_fis&ambarfis=16&tersfis=1&ref_no=#GET_SHIP_PACKAGE_LIST.ORDER_NUMBER#&order_id=#attributes.order_id#</cfoutput>&action_id='+document.getElementById('action_id').value+'&fis_tipi='+document.shipping_ambar_fis.fis_tipi.value+'&process_cat='+document.getElementById('process_cat_id').value+'&dep_in='+document.getElementById('txt_department_in').value+'&dep_out='+document.getElementById('txt_department_out').value;
				}
				else
					return false;
			}
			else
			{
				sor = confirm('<cf_get_lang dictionary_id='383.Kaydetmeden Çıkıyorsunuz!'>');
				if(sor==true)
					window.location.href='<cfoutput>#request.self#?fuseaction=pda.list_shipping_ambar</cfoutput>';
				else
					return false;
			}
		}
		function actionidolustur()
		{
			row_count_content = document.getElementById('row_count_content').value;
			var j = 0;
			for(i=1;i<=row_count_content;i++)
			{
				if(document.getElementById('amount'+i).value > 0)
				{
					if (j > 0)
						document.getElementById('action_id').value = document.getElementById('action_id').value + ',';
					document.getElementById('action_id').value = document.getElementById('action_id').value + i + '-';
					document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('STOCK_ID'+i).value + '-';
					document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('SEVK_AMOUNT'+i).value + '-';
					document.getElementById('action_id').value = document.getElementById('action_id').value + '0'+ '-';
					document.getElementById('action_id').value = document.getElementById('action_id').value + '0'+ '-';
					document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('SPECT_MAIN_ID'+i).value;
					j++;
				}
				document.getElementById('row_count_content').value = j;
			}
		}
		function order_row_kontrol()
		{
			document.getElementById('area_1').style.display='none';
			document.getElementById('area_2').style.display='none';
			document.getElementById('area_3').style.display='none';
			document.getElementById('order_row_div').style.display='none';
			document.getElementById('goto_control').style.display='';
			var bb = '<cfoutput>#request.self#?fuseaction=pda.emptypopup_ajax_ambar_fis_6_control&order_id=#attributes.order_id#</cfoutput>';
			AjaxPageLoad(bb,'ship_list',1);
			document.getElementById('add_other_barcod').focus();
		}
		function urunbul(barcode,spectmainid)
		{
		/*var new_sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER,S.PRODUCT_NAME,S.IS_PROTOTYPE FROM STOCKS_BARCODES AS SB INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '"+barcode+"'";*/
				/*var get_product = wrk_query(new_sql,'dsn3');*/
				
			var listParam = barcode;
			var get_product = wrk_safe_query('get_product_ezgi','dsn3',0,listParam);
				
			if (get_product.STOCK_ID == undefined)
			{
				var listParam = barcode;
				var get_palet = wrk_safe_query('get_packing_barcode_ezgi','dsn3',0,listParam);
				if (get_palet.STOCK_ID == undefined)
				{
					alert('<cf_get_lang dictionary_id='341.Ürün Bulunamadı'>');
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus();
					return false;
				}
				else
				{
					carpan = 0;
					birim = 0;
					stockid = 0;
					productname = '';
					type = 2;
					return [carpan, birim, stockid, productname,type];
				}
			}
			else
			{	
				if(get_product.IS_PROTOTYPE==1 && spectmainid==0)
				{
					alert('<cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'> : <cf_get_lang dictionary_id='36006.Spekt ID'>');
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus();
					return false;
				}
				else
				{
					
					carpan = get_product.MULTIPLIER;
					birim = get_product.MAIN_UNIT;
					stockid = get_product.STOCK_ID;
					productname = get_product.PRODUCT_NAME;
					type = 1;
					palet_list = '';
					return [carpan, birim, stockid, productname,type];
				}
			}
		}
		function sevk_satirbul(row_count_sevk,stockid,spectmainid)
		{
			buldum=0;
			for(i=1;i<=row_count_sevk;i++)
			{
				satir_spect = document.getElementById('row_control_'+i).value;
				seri_spect = stockid+'_'+spectmainid;
				if(satir_spect==seri_spect)
					buldum=i;
			}
			return [buldum,seri_spect];
		}
		function content_satirbul(row_count_content,stockid,spectmainid)
		{
			buldum_content=0;
			for(m=1;m<=row_count_content;m++)
			{
				satir_spect_content = document.getElementById('row_control_content_'+m).value;
				seri_spect_content = stockid+'_'+spectmainid;
				if(satir_spect_content==seri_spect_content)
					buldum_content=m;
			}
			return [buldum_content,seri_spect_content];
		}
		function stokkontrol(barcode,stockid,spectmainid,productname)
		{
			if(spectmainid>0)
			{
				/*var stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_SPECT_LOCATION_TOTAL WHERE DEPO = '"+document.all.txt_department_out.value+"' AND STOCK_ID = "+stockid+" AND SPECT_MAIN_ID = "+spectmainid;*/
				var listParam = document.all.txt_department_out.value + "*" + spectmainid;
				var get_real_stock = wrk_safe_query('get_depo_stock_spectmainid_ezgi','dsn2',0,listParam);
			}
			else
			{
				/*var stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL WHERE DEPO = '"+document.all.txt_department_out.value+"' AND STOCK_ID = "+stockid;*/
				var listParam = document.all.txt_department_out.value + "*" + stockid;
				var get_real_stock = wrk_safe_query('get_depo_stock_stock_id_ezgi','dsn2',0,listParam);
			}
			/*var get_real_stock = wrk_query(stock_sql,'dsn2');*/	
			depo_stok = get_real_stock.PRODUCT_STOCK;
			<!---depo_stok = 20;--->
			document.getElementById('add_read_amount').value = 0;
			for(i=1;i<=row_count_content;i++)
			{
				content_spect = document.getElementById('SPECT_MAIN_ID'+i).value;
				content_stock = document.getElementById('STOCK_ID'+i).value;
				content_amount = document.getElementById('SEVK_AMOUNT'+i).value;
				content_seri = content_stock+'_'+content_spect;
				if(content_seri==seri_spect)
					document.getElementById('add_read_amount').value = (document.getElementById('add_read_amount').value*1) + (content_amount*1);
			}
								
			if(depo_stok==undefined)
				depo_stok = 0;
	
								
			if((depo_stok*1) < (document.getElementById('add_read_amount').value *1)+(document.getElementById('add_other_amount').value*1))
			{
				alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. Depo Stok Miktarı : "+get_real_stock. PRODUCT_STOCK);
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_amount').value = 1;
				document.getElementById('add_other_barcod').focus();
				return false;
			}
			else
			{
				document.getElementById('control_amount'+buldum).value = (document.getElementById('control_amount'+buldum).value*1)+(document.getElementById('add_other_amount').value*1);
				if(document.getElementById('control_amount'+buldum).value == document.getElementById('amount'+buldum).value)
					document.getElementById('row'+buldum).style.display='none';
				shelfcode = '';
				amount = document.getElementById('add_other_amount').value;
				buton_kontrol();
				add_row(barcode,stockid,spectmainid,productname,shelfcode,amount);
				document.getElementById('total_control_amount').value = (document.getElementById('total_control_amount').value*1) + (document.getElementById('add_other_amount').value*1);
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_amount').value = 1;
				document.getElementById('add_other_barcod').focus();
			}
		}
		function palet_add_row(palet_barcode)
		{
			row_count_palet = document.getElementById('row_count_palet').value;
			row_count_palet++;
			document.getElementById('row_count_palet').value = row_count_palet;
			var newRow;
			var newCell;	
			newRow = document.getElementById("table3").insertRow(document.getElementById("table3").rows.length);
			newRow.setAttribute("name","frm_row_palet" + row_count_palet);
			newRow.setAttribute("id","frm_row_palet" + row_count_palet);		
			newRow.setAttribute("NAME","frm_row_palet" + row_count_palet);
			newRow.setAttribute("ID","frm_row_palet" + row_count_palet);		
					
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="hidden" name="row_kontrol_palet'+row_count_palet+'" id="row_kontrol_palet'+row_count_palet+'" value="1"><input name="row_number_palet'+row_count_palet+'" type="text" value="'+row_count_palet+'"text-align:right">';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="palet_barcode'+row_count_palet+'" id="palet_barcode'+row_count_palet+'" type="text" value="'+palet_barcode+'">';
		}
		function add_row_palet_ici(barcode,stockid,spectmainid,productname,amount)
		{
			row_count_palet_ici = document.getElementById('row_count_palet_ici').value;
			row_count_palet_ici++;
			document.getElementById('row_count_palet_ici').value = row_count_palet_ici;
			var newRow;
			var newCell;	
			newRow = document.getElementById("table4").insertRow(document.getElementById("table4").rows.length);
			newRow.setAttribute("name","frm_row_palet_ici" + row_count_palet_ici);
			newRow.setAttribute("id","frm_row_palet_ici" + row_count_palet_ici);		
			newRow.setAttribute("NAME","frm_row_palet_ici" + row_count_palet_ici);
			newRow.setAttribute("ID","frm_row_palet_ici" + row_count_palet_ici);		
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="hidden" name="row_kontrol_palet_ici'+row_count_palet_ici+'" id="row_kontrol_palet_ici'+row_count_palet_ici+'" value="1"><input name="STOCK_ID_PALET_ICI'+row_count_palet_ici+'" id="STOCK_ID_PALET_ICI'+row_count_palet_ici+'" type="hidden" value="'+stockid+'"><input name="SPECT_MAIN_ID_PALET_ICI'+row_count_palet_ici+'" id="SPECT_MAIN_ID_PALET_ICI'+row_count_palet_ici+'" type="hidden" value="'+spectmainid+'"><input name="row_number_palet_ici'+row_count_palet_ici+'" type="text" value="'+row_count_palet_ici+'"text-align:right">';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="BARCODE_PALET_ICI'+row_count_palet_ici+'" id="BARCODE_PALET_ICI'+row_count_palet_ici+'" type="text" value="'+barcode+'">';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="PRODUCT_NAME_PALET_ICI'+row_count_palet_ici+'" id="PRODUCT_NAME_PALET_ICI'+row_count_palet_ici+'" type="text" value="'+productname+'">';
			
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="SEVK_AMOUNT_PALET_ICI'+row_count_palet_ici+'" id="SEVK_AMOUNT_PALET_ICI'+row_count_palet_ici+'" type="text" value="'+amount+'" >';
		}
		function palet_geri()
		{
			row_count_palet_ici = document.getElementById('row_count_palet_ici').value;
			row_count_sevk = <cfoutput>#GET_SHIP_PACKAGE_LIST.recordcount#</cfoutput>;
			row_count_content = document.getElementById('row_count_content').value;
			for(k=1;k<=row_count_palet_ici-1;k++)
			{
				stockid=document.getElementById('STOCK_ID_PALET_ICI'+k).value;
				spectmainid=document.getElementById('SPECT_MAIN_ID_PALET_ICI'+k).value;
				amount = document.getElementById('SEVK_AMOUNT_PALET_ICI'+k).value;
				
				let [buldum,seri_spect]=sevk_satirbul(row_count_sevk,stockid,spectmainid);
				document.getElementById('control_amount'+buldum).value = (document.getElementById('control_amount'+buldum).value*1)-(amount*1);
				if(document.getElementById('control_amount'+buldum).value < document.getElementById('amount'+buldum).value)
					document.getElementById('row'+buldum).style.display='';
					
				let [buldum_content,seri_spect_content]=content_satirbul(row_count_content,stockid,spectmainid);
				document.getElementById('SEVK_AMOUNT'+buldum_content).value = (document.getElementById('SEVK_AMOUNT'+buldum_content).value*1)-(amount*1);
				
				
				document.getElementById('total_control_amount').value = (document.getElementById('total_control_amount').value*1) - (amount*1);
				
				document.getElementById('frm_row_palet_ici'+k).style.display='none';
				document.getElementById('SEVK_AMOUNT_PALET_ICI'+k).value = '';
				document.getElementById('SPECT_MAIN_ID_PALET_ICI'+k).value = '';
				document.getElementById('STOCK_ID_PALET_ICI'+k).value = '';

			}
		}
		function palet_ici_sil()
		{
			row_count_palet_ici = document.getElementById('row_count_palet_ici').value;
			for(k=1;k<=row_count_palet_ici;k++)
			{
				row = document.getElementById('frm_row_palet_ici'+k)
				row.parentNode.removeChild(row);
			}
			document.getElementById('row_count_palet_ici').value = 0;
		}
	</script>
<cfelse>
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cf_box>
       		<cf_basket_form id="add_ezgi_ambarfis_6">
       		    <div class="row">
       		        <div class="col col-12 uniqueRow" id="first_area">
       		            <div class="row formContent">
       		       			<cf_box_elements>
       		              		<div class="col col-12 uniqueRow">
       		                         <div class="col col-6">
       		                            <label><cf_get_lang dictionary_id='1317.Paket Barkodu'></label>
       		                        </div>
       		                        <div class="col col-6">
       		                            <div class="form-group">
       		                       			<input id="add_other_barcod" name="add_other_barcod" type="text"  maxlength="30" value="" />
                                    	</div>
                                  	</div>
                             	</div>
                            	<div class="col col-12 uniqueRow">
                                	<div class="col col-6">
                                     	<label><cf_get_lang dictionary_id='58211.Sipariş No'></label>
                              		</div>
                                 	<div class="col col-4">
                                     	<div class="form-group">
                                        	<input id="ordernumber" name="ordernumber" type="text"  maxlength="30" value="" />
                                     	</div>
                                 	</div>
                                 	<div class="col col-2">
                                     	<div class="form-group">
                                         	<input id="order_no_confirm" name="order_no_confirm" style="color:white" value="<cf_get_lang dictionary_id="57565.Ara">" type="button" onClick="order_no_search();" />
                                   		</div>
                                 	</div>
                             	</div>
       		             	</cf_box_elements>
       		           	</div>
       		     	</div>
       		  	</div>
        	</cf_basket_form> 
          	<cfsavecontent variable="title"><cf_get_lang dictionary_id="1367.Sipariş  Bazlı Ambar Fişi"></cfsavecontent>
       		<cf_box title="#title#">
       		    <div class="col col-12"  id="display_info">
       		    
       		    </div>
       		</cf_box>
    	</cf_box>
  	</div>
    
    <script language="javascript" type="text/javascript">
		document.getElementById('add_other_barcod').focus();
		setTimeout("document.getElementById('add_other_barcod').select();",1000);
		document.onkeydown = checkKeycode
		function checkKeycode(e) 
		{
			var keycode;
			if (window.event) keycode = window.event.keyCode;
			else if (e) keycode = e.which;
			if (keycode == 13)
			{
				if (document.getElementById('ordernumber').value.length == 0)
				{
					if (document.getElementById('add_other_barcod').value.length == 0)
					{
						alert('<cf_get_lang dictionary_id='340.Önce Ürün Barkodu Okutunuz'>');
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_barcod').focus();	
					
					}
					else
					{
						get_stock(document.getElementById('add_other_barcod').value);
					}
				}
				else
				{
					order_no_search();
				}
			}
		}
		function get_stock(barcode)
		{
			uzunluk = barcode.length;
			carpan = ''; birim = ''; barcod = ''; stockid = ''; stockcode = ''; spectmainid = 0; //ilk önce sıfırlıyoruz
			k_= 0;
			ean = <cfoutput>#get_defaults.EAN#</cfoutput>;
			if(uzunluk > ean)
			{
				spectmainid = barcode.substring(ean,uzunluk);
				barcode = barcode.substring(0,ean);
			}
			/*Sorgulama Alanı*/
			var listParam = barcode;
			var get_product = wrk_safe_query('get_product_ezgi','dsn3',0,listParam);
			/*Sorgulama Alanı*/	
			if (get_product.STOCK_ID == undefined)
			{
				alert('<cf_get_lang dictionary_id='341.Ürün Bulunamadı'>');
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('ordernumber').value='';
				document.getElementById('add_other_barcod').focus();
			}
			else
			{	
				if(get_product.IS_PROTOTYPE==1 && spectmainid==0)
				{
					alert('<cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'> : <cf_get_lang dictionary_id='36006.Spekt ID'>');
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('ordernumber').value='';
					document.getElementById('add_other_barcod').focus();
				}
				else
				{
					carpan = get_product.MULTIPLIER;
					birim = get_product.MAIN_UNIT;
					stockid = get_product.STOCK_ID;
					product_name = get_product.PRODUCT_NAME;
					barcode = get_product.BARCODE;
					
					var bb = '<cfoutput>#request.self#</cfoutput>?fuseaction=pda.emptypopup_ajax_ambar_fis_6&barcode='+document.getElementById('add_other_barcod').value+'&spectmainid='+spectmainid+'&stockid='+stockid+'&productname='+product_name+'&birim='+birim;
					AjaxPageLoad(bb,'display_info',1);
					document.getElementById('add_other_barcod').value='';
					document.getElementById('ordernumber').value='';
					document.getElementById('add_other_barcod').focus();
				}
			}
		}
		function order_no_search()
		{
			var bb = '<cfoutput>#request.self#</cfoutput>?fuseaction=pda.emptypopup_ajax_ambar_fis_6&ordernumber='+document.getElementById('ordernumber').value;
			AjaxPageLoad(bb,'display_info',1);
			document.getElementById('add_other_barcod').value='';
			document.getElementById('ordernumber').value='';
			document.getElementById('add_other_barcod').focus();
		}
	</script>
</cfif>