<!---
    File: list_shipping_ambar.cfm
    Folder: Add_Ons\ezgi\e-pda\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
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
<cfset default_process_type = 113>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.kontrol_status" default="1">
<cfparam name="attributes.DELIVER_PAPER_NO" default="">
<cfparam name="attributes.IS_TYPE" default="">
<cfquery name="get_default_departments" datasource="#dsn#">
	SELECT        
    	DEFAULT_RF_TO_SV_DEP, 
        DEFAULT_RF_TO_SV_LOC
	FROM            
    	EZGI_PDA_DEPARTMENT_DEFAULTS
	WHERE        
    	EPLOYEE_ID = #session.ep.userid#
</cfquery>

<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>. <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>!");
		window.location ="<cfoutput>#request.self#?fuseaction=myhome.welcome</cfoutput>";
	</script>
    <cfabort>
</cfif>
<cfset default_departments = '#get_default_departments.DEFAULT_RF_TO_SV_DEP#'> 
<cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_LOC,2)#">
<cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_LOC,1)#">
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
		D.DEPARTMENT_ID IN (#default_departments#) AND
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
		SL.STATUS = 1 AND
		D.BRANCH_ID = B.BRANCH_ID
</cfquery>
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT TOP (1)    
    	SPC.PROCESS_CAT_ID
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE = #default_process_type# AND 
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

<cfif isdefined("attributes.date2") and isdate(attributes.date2)>
  <cf_date tarih="attributes.date2">
  <cfelse>
  <cfset attributes.date2 = wrk_get_today()>
</cfif>
<cfif isdefined("attributes.date1") and isdate(attributes.date1)>
  <cf_date tarih="attributes.date1">
  <cfelse>
  <cfset attributes.date1 = wrk_get_today()>
</cfif>

<cfif isdefined("attributes.is_form_submitted")>
  <cfinclude template="../query/get_shipping_list.cfm">
  <cfelse>
  <cfset get_sevk_fis.recordcount = 0>
</cfif>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default=20>
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows)+1>
<cfparam name="attributes.totalrecords" default='#get_sevk_fis.recordcount#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="frm_search" method="post" action="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_shipping_ambar">
  			<input type="hidden" name="is_form_submitted" value="1">
            <cf_box_search>
                <div class="form-group">
                	<cfsavecontent variable="message"><cf_get_lang dictionary_id="54667.Lütfen Barkod No Giriniz"></cfsavecontent>
                   	<cfinput type="text" name="keyword" value="#attributes.keyword#" maxlength="20" placeholder="#message#">
                </div>
				<div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
           	 </cf_box_search>
            <cf_box_search_detail>
                <div id="detail_search_div" style="display:table-row;">
                	<cf_box_elements>
                        <div class="col col-12">
                            <div class="form-group" id="tarih_">
                                <label class="col col-2">Tarih</label>
                              	<div class="col col-5">
                                	<div class="input-group">
                                	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                                    <cfinput type="text" maxlength="10" name="date1" value="#dateformat(attributes.date1,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="date1"></span>
                                    </div>
                                </div>
                                <div class="col col-5">
                                	<div class="input-group">
                                	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                                    <cfinput type="text" maxlength="10" name="date2" value="#dateformat(attributes.date2,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="date2"></span>
                               		</div>
                     			</div>
                			</div>
                     	</div>
                        <div class="col col-12">
                            <div class="form-group" id="depo1_">
                            	<label class="col col-2"><cf_get_lang dictionary_id='29428.Çıkış Depo'></label>
                             	<div class="col col-10">
                                	<select name="department_out_id" id="department_out_id" style="width:110px; height:20px">
										<cfoutput query="get_all_location" group="department_id">
                                            <option disabled="disabled" value="#department_id#">#department_head#</option>
                                            <cfoutput>
                                            <option value="#department_id#-#location_id#" <cfif department_id is #ListFirst(attributes.department_out_id,'-')# and location_id is #ListLast(attributes.department_out_id,'-')#>selected="selected"</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#</option>
                                            </cfoutput> 
                                        </cfoutput>
                                    </select>
                                </div>
                			</div>
                            <div class="form-group" id="depo2_">
                            	<label class="col col-2"><cf_get_lang dictionary_id='33658.Giriş Depo'></label>
                             	<div class="col col-10">
                                	<select name="department_in_id" id="department_in_id" style="width:110px; height:20px">
										<cfoutput query="get_all_location" group="department_id">
                                            <option disabled="disabled" value="#department_id#">#department_head#</option>
                                            <cfoutput>
                                            <option value="#department_id#-#location_id#" <cfif department_id is #ListFirst(attributes.department_in_id,'-')# and location_id is #ListLast(attributes.department_in_id,'-')#>selected="selected"</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#</option>
                                            </cfoutput> 
                                        </cfoutput>
                                    </select>
                                </div>
                			</div>
                     	</div>
                	</cf_box_elements>
               	</div>
          	</cf_box_search_detail>
    	</cfform>
  	</cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id="8.Ambardan Sevkiyata"></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
      	<cf_form_list>
        	<thead>
              	<tr>
                 	<th style="width:25%"><cf_get_lang dictionary_id='57880.Belge No'></th>
                    <th style="width:100%"><cf_get_lang dictionary_id='58061.Cari'></th>
                    <th style="width:25%"><cf_get_lang dictionary_id='29775.Hazırlayan'></th>
                    <!-- sil -->
    				<th style="width:10%">&nbsp;&nbsp;&nbsp;</th>
                    <!-- sil -->
               	</tr>
          	</thead>
            <tbody>
            	<cfif get_sevk_fis.recordcount>
					<cfoutput query="get_sevk_fis">
						<tr>
                        	<cfquery name="get_url" datasource="#dsn#">
                                SELECT     
                                    E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS ADI,
                                    E.EMPLOYEE_ID
                                FROM         
                                    WRK_SESSION AS W INNER JOIN
                                    EMPLOYEES AS E ON W.USERID = E.EMPLOYEE_ID
                                WHERE   
                                    W.PERIOD_ID = #session.ep.period_id# AND
                                    W.ACTION_PAGE LIKE '#fuseaction#%' AND 
                                    W.ACTION_PAGE LIKE N'%ship_id=#SHIP_RESULT_ID#%'
                            </cfquery>
                            <cfif get_url.recordcount>
                                <td>#DELIVER_PAPER_NO#</td>
                                <td>
                                    <cfif IS_TYPE eq 1> 
                                        #left(unvan,25)#<cfif len(unvan) gt 25>...</cfif>
                                    <cfelse>
                                    	#left(DEPARTMENT_HEAD,25)#<cfif len(DEPARTMENT_HEAD) gt 25>...</cfif>
                                    </cfif>     
                                </td>
                                <td> <font color="red">#left(get_url.ADI,15)#<cfif len(get_url.ADI) gt 15>...</cfif></font></td>
                            <cfelse>
                                <td>
                                    <cfset url_param = "">
                                    <a href="javascript://" class="tableyazi" onclick="add_ambar('#SHIP_RESULT_ID#','#IS_TYPE#','#DELIVER_PAPER_NO#');">
                                        #DELIVER_PAPER_NO#
                                    </a>
                                </td>
                                <td>
                                    <cfif IS_TYPE eq 1> 
                                        #left(unvan,25)#<cfif len(unvan) gt 25>...</cfif>
                                    <cfelse>
                                    	#left(DEPARTMENT_HEAD,25)#<cfif len(DEPARTMENT_HEAD) gt 25>...</cfif>
                                    </cfif>      
                                </td>
                                <td></td>
                            </cfif>
                            <cfset last_year = session.ep.period_year -1> 
                            <cfif IS_TYPE eq 1>   
                                <cfquery name="PACKEGE_CONTROL" datasource="#DSN3#">
                               		SELECT     
                          			    ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
                          			    ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT
                          			FROM         
                          			    (
                          			    SELECT     
                          			        PAKET_SAYISI AS PAKETSAYISI, 
                          			        PAKET_ID AS STOCK_ID, 
                          			        BARCOD, 
                          			        STOCK_CODE, 
                          			        PRODUCT_NAME,
                          			        (
                          			        SELECT 
                          			            SUM(CONTROL_AMOUNT) CONTROL_AMOUNT
                          			        FROM
                          			            ( 
                          			                SELECT        
                          			                    SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                          			                FROM   
                          			                           
                          			                    #dsn2_alias#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                          			                    #dsn2_alias#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                          			                    SPECTS AS SP WITH (NOLOCK) ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                          			                    STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                          			                WHERE        
                          			                    SF.FIS_TYPE = 113 AND 
                          			                    SF.REF_NO = '#DELIVER_PAPER_NO#' AND 
                          			                    SFR.STOCK_ID = TBL.PAKET_ID AND
                          			                    ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                          			                    ISNULL(S.IS_PROTOTYPE,0) = 1
                          			                    <cfif get_period_id.recordcount>
                          			                    	UNION ALL
                          			                    	SELECT        
                          			                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                          			                        FROM   
                          			                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                          			                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                          			                            SPECTS AS SP WITH (NOLOCK) ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                          			                            STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                          			                        WHERE        
                          			                            SF.FIS_TYPE = 113 AND 
                          			                            SF.REF_NO = '#DELIVER_PAPER_NO#' AND 
                          			                            SFR.STOCK_ID = TBL.PAKET_ID AND
                          			                            ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                          			                            ISNULL(S.IS_PROTOTYPE,0) = 1
                          			                    </cfif>
                          			                UNION ALL
                          			                SELECT        
                          			                    SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                          			                FROM   
                          			                    #dsn2_alias#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                          			                    #dsn2_alias#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                          			                    STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                          			                WHERE        
                          			                    SF.FIS_TYPE = 113 AND 
                          			                    SF.REF_NO = '#DELIVER_PAPER_NO#' AND 
                          			                    SFR.STOCK_ID = TBL.PAKET_ID AND
                          			                    ISNULL(S.IS_PROTOTYPE,0) = 0
                          			                    <cfif get_period_id.recordcount>
                          			                    	UNION ALL
                          			                        SELECT        
                          			                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                          			                        FROM   
                          			                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                          			                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                          			                            STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                          			                        WHERE        
                          			                            SF.FIS_TYPE = 113 AND 
                          			                            SF.REF_NO = '#DELIVER_PAPER_NO#' AND 
                          			                            SFR.STOCK_ID = TBL.PAKET_ID AND
                          			                            ISNULL(S.IS_PROTOTYPE,0) = 0
                          			                    </cfif>
                          			            ) AS TBL_5
                          			        ) AS CONTROL_AMOUNT
                          			    FROM         
                          			        (
                          			        SELECT
                          			            SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                          			            PAKET_ID, 
                          			            BARCOD, 
                          			            STOCK_CODE, 
                          			            PRODUCT_NAME, 
                          			            SHIP_RESULT_ID,
                          			            SPECT_MAIN_ID
                          			        FROM
                          			            (     
                          			            SELECT     
                          			                SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                          			                EPS.PAKET_ID, 
                          			                S.BARCOD, 
                          			                S.STOCK_CODE, 
                          			                S.PRODUCT_NAME, 
                          			                ESR.SHIP_RESULT_ID,
                          			                ESRR.ORDER_ROW_ID,
                          			                0 AS SPECT_MAIN_ID
                          			            FROM          
                          			                STOCKS AS S1 WITH (NOLOCK) INNER JOIN
                          			                EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
                          			                EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                          			                ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
                          			                STOCKS AS S WITH (NOLOCK) INNER JOIN
                          			                EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON S1.STOCK_ID = EPS.MODUL_ID
                          			            WHERE      
                          			                ESR.SHIP_RESULT_ID = #SHIP_RESULT_ID# AND
                          			                ISNULL(S1.IS_PROTOTYPE,0) = 0
                          			            GROUP BY 
                          			                EPS.PAKET_ID, 
                          			                S.BARCOD, 
                          			                S.STOCK_CODE, 
                          			                S.PRODUCT_NAME, 
                          			                ESR.SHIP_RESULT_ID,
                          			                ESRR.ORDER_ROW_ID
                          			          	UNION ALL
                          			        	SELECT
                          			                SUM(ORR.QUANTITY) AS PAKET_SAYISI, 
                          			                S1.STOCK_ID AS PAKET_ID,
                          			                S1.BARCOD,
                          			                S1.STOCK_CODE,
                          			                S1.PRODUCT_NAME,
                          			                ESR.SHIP_RESULT_ID, 
                          			                ESRR.ORDER_ROW_ID, 
                          			                SP.SPECT_MAIN_ID
                          			            FROM            
                          			                SPECTS AS SP WITH (NOLOCK) INNER JOIN
                          			                EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
                          			                EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                          			                ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                          			                STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID
                          			            WHERE        
                          			                ESR.SHIP_RESULT_ID = #SHIP_RESULT_ID# AND 
                          			                ISNULL(S1.IS_PROTOTYPE, 0) = 1
                          			            GROUP BY 
                          			                S1.STOCK_ID,
                          			                SP.SPECT_MAIN_ID, 
                          			                ESR.SHIP_RESULT_ID, 
                          			                ESRR.ORDER_ROW_ID, 
                          			                S1.STOCK_CODE, 
                          			                S1.PRODUCT_NAME, 
                          			                S1.BARCOD
                          			            ) AS TBL1
                          			        GROUP BY
                          			            PAKET_ID, 
                          			            BARCOD, 
                          			            STOCK_CODE, 
                          			            PRODUCT_NAME, 
                          			            SHIP_RESULT_ID,
                          			            SPECT_MAIN_ID
                          			        ) AS TBL
                          			    ) AS TBL2
                                </cfquery>
                            <cfelse>
                                <cfquery name="PACKEGE_CONTROL" datasource="#DSN3#">
                            		SELECT     
                          			    ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
                          			    ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT
                          			FROM         
                          			    (		
                          			    SELECT     
                          			        PAKET_SAYISI AS PAKETSAYISI, 
                          			        PAKET_ID AS STOCK_ID, 
                          			        BARCOD, 
                          			        STOCK_CODE, 
                          			        PRODUCT_NAME,
                          			        (
                          			          SELECT 
                          			            SUM(CONTROL_AMOUNT) CONTROL_AMOUNT
                          			        FROM
                          			            ( 
                          			            	SELECT        
                          			                    SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                          			                FROM   
                          			                           
                          			                    #dsn2_alias#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                          			                    #dsn2_alias#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                          			                    SPECTS AS SP WITH (NOLOCK) ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                          			                    STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                          			                WHERE        
                          			                    SF.FIS_TYPE = 113 AND 
                          			                    SF.REF_NO = '#DELIVER_PAPER_NO#' AND 
                          			                    SFR.STOCK_ID = TBL.PAKET_ID AND
                          			                    ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                          			                    ISNULL(S.IS_PROTOTYPE,0) = 1
                          			                    <cfif get_period_id.recordcount>
                          			                    	UNION ALL
                          			                     	SELECT        
                          			                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                          			                        FROM   
                          			                                   
                          			                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                          			                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                          			                            SPECTS AS SP WITH (NOLOCK) ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                          			                            STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                          			                        WHERE        
                          			                            SF.FIS_TYPE = 113 AND 
                          			                            SF.REF_NO = '#DELIVER_PAPER_NO#' AND 
                          			                            SFR.STOCK_ID = TBL.PAKET_ID AND
                          			                            ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                          			                            ISNULL(S.IS_PROTOTYPE,0) = 1
                          			                    </cfif>
                          			                UNION ALL
                          			                SELECT        
                          			                    SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                          			                FROM   
                          			                    #dsn2_alias#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                          			                    #dsn2_alias#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                          			                    STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                          			                WHERE        
                          			                    SF.FIS_TYPE = 113 AND 
                          			                    SF.REF_NO = '#DELIVER_PAPER_NO#' AND 
                          			                    SFR.STOCK_ID = TBL.PAKET_ID AND
                          			                    ISNULL(S.IS_PROTOTYPE,0) = 0
                          			             		 <cfif get_period_id.recordcount>
                          			                     	UNION ALL
                          			                        SELECT        
                          			                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                          			                        FROM   
                          			                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                          			                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                          			                            STOCKS S WITH (NOLOCK) ON SFR.STOCK_ID=S.STOCK_ID
                          			                        WHERE        
                          			                            SF.FIS_TYPE = 113 AND 
                          			                            SF.REF_NO = '#DELIVER_PAPER_NO#' AND 
                          			                            SFR.STOCK_ID = TBL.PAKET_ID AND
                          			                            ISNULL(S.IS_PROTOTYPE,0) = 0
                          			                     </cfif>
                          			            ) AS TBL_5
                          			        ) AS CONTROL_AMOUNT, 
                          			        SHIP_RESULT_ID
                          			    FROM         
                          			        (
                          			        SELECT     
                          			            SUM(PAKET_SAYISI) AS PAKET_SAYISI, 
                          			            PAKET_ID, 
                          			            BARCOD, 
                          			            STOCK_CODE, 
                          			            PRODUCT_NAME, 
                          			            SHIP_RESULT_ID,
                          			            SPECT_MAIN_ID
                          			        FROM          
                          			            (
                          			            	SELECT     
                          			                SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                          			                EPS.PAKET_ID, 
                          			                S.BARCOD, 
                          			                S.STOCK_CODE, 
                          			                S.PRODUCT_NAME, 
                          			                ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
                          			                ESRR.ORDER_ROW_ID,
                          			                0 AS SPECT_MAIN_ID
                          			            FROM          
                          			                STOCKS AS S1 WITH (NOLOCK) INNER JOIN
                          			                EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
                          			                EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                          			                ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
                          			                STOCKS AS S WITH (NOLOCK) INNER JOIN
                          			                EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON S1.STOCK_ID = EPS.MODUL_ID
                          			            WHERE      
                          			                ESR.SHIP_RESULT_INTERNALDEMAND_ID = #SHIP_RESULT_ID# AND
                          			                ISNULL(S1.IS_PROTOTYPE,0) = 0
                          			            GROUP BY 
                          			                EPS.PAKET_ID, 
                          			                S.BARCOD, 
                          			                S.STOCK_CODE, 
                          			                S.PRODUCT_NAME, 
                          			                ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                          			                ESRR.ORDER_ROW_ID
                          			          	UNION ALL
                          			        	SELECT
                          			                SUM(ORR.QUANTITY) AS PAKET_SAYISI, 
                          			                S1.STOCK_ID AS PAKET_ID,
                          			                S1.BARCOD,
                          			                S1.STOCK_CODE,
                          			                S1.PRODUCT_NAME,
                          			                ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID, 
                          			                ESRR.ORDER_ROW_ID, 
                          			                SP.SPECT_MAIN_ID
                          			            FROM            
                          			                SPECTS AS SP WITH (NOLOCK) INNER JOIN
                          			                EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
                          			                EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                          			                ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                          			                STOCKS AS S1 WITH (NOLOCK) ON ORR.STOCK_ID = S1.STOCK_ID
                          			            WHERE        
                          			                ESR.SHIP_RESULT_INTERNALDEMAND_ID = #SHIP_RESULT_ID# AND 
                          			                ISNULL(S1.IS_PROTOTYPE, 0) = 1
                          			            GROUP BY 
                          			                S1.STOCK_ID,
                          			                SP.SPECT_MAIN_ID, 
                          			                ESR.SHIP_RESULT_INTERNALDEMAND_ID, 
                          			                ESRR.ORDER_ROW_ID, 
                          			                S1.STOCK_CODE, 
                          			                S1.PRODUCT_NAME, 
                          			                S1.BARCOD
                          			            ) AS TBL1
                          			        GROUP BY 
                          			            PAKET_ID, 
                          			            BARCOD, 
                          			            STOCK_CODE, 
                          			            PRODUCT_NAME, 
                          			            SHIP_RESULT_ID,
                          			            SPECT_MAIN_ID
                          			        ) AS TBL
                          			    ) AS TBL2
                                </cfquery>
                            </cfif>
                            <!-- sil -->
                          	<td align="center">
								 <cfif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI eq 0 and PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                    <img src="/images/plus_ques.gif" border="0" title="<cf_get_lang dictionary_id='29975.Barkod Yok'>">
                                 <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI - PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                    <img src="/images/c_ok.gif" border="0" title="<cf_get_lang dictionary_id='334.Sevk Edildi'>.">
                                 <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                    <img src="/images/caution_small.gif" border="0" title="<cf_get_lang dictionary_id='335.Sevk Edilmedi'>.">
                                 <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI gt PACKEGE_CONTROL.CONTROL_AMOUNT>
                                    <img src="/images/warning.gif" border="0" title="<cf_get_lang dictionary_id='336.Eksik Sevkiyat'>.">
                                 <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI lt PACKEGE_CONTROL.CONTROL_AMOUNT>
                                    <img src="/images/control.gif" border="0" title="<cf_get_lang dictionary_id='337.Fazla Sevkiyat'>">  
                                 </cfif>
                        	</td>
                            <!-- sil -->
                    	</tr>
                   	</cfoutput>
            	<cfelse>
                	<tfoot>
                        <tr>
                            <td colspan="3" height="20">
                                <cfif not isdefined("attributes.is_form_submitted")>
                                    <cf_get_lang dictionary_id='57701.Filtre Ediniz'>
                                <cfelse>
                                    <cf_get_lang dictionary_id='57484.Kayıt Yok'>
                                </cfif>
                                !
                            </td>
                        </tr>
                    </tfoot>
                </cfif>
            </tbody>
        </cf_form_list>
    	<cfset adres = url.fuseaction>
    	<cfif isDefined('attributes.department_in_id') and len(attributes.department_in_id)>
        	<cfset adres = adres & '&department_in_id=' & attributes.department_in_id>
      	</cfif>
        <cfif isDefined('attributes.department_out_id') and len(attributes.department_out_id)>
        	<cfset adres = adres & '&department_out_id=' & attributes.department_out_id>
      	</cfif>
   		<cfif isdate(attributes.date1)>
        	<cfset adres = "#adres#&date1=#dateformat(attributes.date1,dateformat_style)#">
      	</cfif>
    	<cfif isdate(attributes.date2)>
        	<cfset adres = "#adres#&date2=#dateformat(attributes.date2,dateformat_style)#">
     	</cfif>
       	<cfif isDefined('attributes.keyword') and len(attributes.keyword) >
        	<cfset adres = "#adres#&keyword=#attributes.keyword#" >
      	</cfif>
        
        <cf_paging 
            page="#attributes.page#"
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#adres#&is_submitted=1">
  	</cf_box>    
</div>

<script type="text/javascript">
	$('#keyword').focus();
	function input_control()
	{	
		return true;
	}
	function add_ambar(ship_id,is_type,deliver_paper_no)
	{
		window.location ="<cfoutput>#request.self#?fuseaction=pda.form_shipping_ambar_fis&keyword=#attributes.keyword#&date1=#dateformat(attributes.date1,dateformat_style)#&date2=#dateformat(attributes.date2,dateformat_style)#</cfoutput>&DELIVER_PAPER_NO="+deliver_paper_no+"&is_type="+is_type+"&ship_id="+ship_id+"&department_in_id="+document.getElementById('department_in_id').value+"&department_out_id="+document.getElementById('department_out_id').value;
	}
</script>            
                