<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.montage_stock_ids" default="">
<cfparam name="attributes.sort_type" default="3">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.durum_uretim" default="">
<cfparam name="attributes.durum_montaj" default="">
<cfparam name="attributes.member_cat_type" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.member_name" default="">
<cfparam name="attributes.member_type" default="">
<cfparam name="attributes.record_emp_id" default="">
<cfparam name="attributes.record_emp_name" default="">
<cfparam name="attributes.category_name" default="">
<cfparam name="attributes.list_type" default="1">
<cfparam name="attributes.currency_id" default="">
<cfparam name="attributes.sales_type" default="">
<cfparam name="attributes.status" default="1">
<CFSET t_amount = 0>
<cfif isdefined('attributes.update_status')>
	<cfif ListLen(attributes.convert_list)>
        <cfloop list="#attributes.convert_list#" index="i">
        	<cfset ezgiid = ListGetAt(i,1,'_')>
            <cfset stockid = ListGetAt(i,2,'_')>
        	<cfquery name="update_row" datasource="#dsn3#">
            	UPDATE
                	EZGI_MONTAGE_ROW
               	SET
                	STATUS = #attributes.update_status#
             	WHERE
                	EZGI_ID = #ezgiid# AND
                    STOCK_ID = #stockid#   
           	</cfquery>    
        </cfloop>
    </cfif>
</cfif>
<cfif isdefined("attributes.date1") and isdate(attributes.date1)>
	<cf_date tarih="attributes.date1">
<cfelse>
	<cfparam name="attributes.date1" default="">
</cfif>
<cfif isdefined("attributes.date2") and isdate(attributes.date2)>
	<cf_date tarih="attributes.date2">
<cfelse>
	<cfparam name="attributes.date2" default="">
</cfif>
<cfif isdefined("attributes.is_form_submitted")>
	<cfquery name="get_montages" datasource="#dsn3#">
    	SELECT   
        	CASE
         		WHEN EVO.COMPANY_ID IS NOT NULL THEN
                   (
                    SELECT     
                      	NICKNAME
					FROM         
                    	#dsn_alias#.COMPANY WITH (NOLOCK)
					WHERE     
                   		COMPANY_ID = EVO.COMPANY_ID
                  	)
          		WHEN EVO.CONSUMER_ID IS NOT NULL THEN      
                   	(	
                  	SELECT     
                     	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
					FROM         
                      	#dsn_alias#.CONSUMER WITH (NOLOCK)
					WHERE     
                		CONSUMER_ID = EVO.CONSUMER_ID
               		)
          	END AS UNVAN,
            (SELECT MASTER_PLAN_DETAIL FROM EZGI_IFLOW_MASTER_PLAN WHERE MASTER_PLAN_ID = ofr.MASTER_PLAN_ID) MASTER_PLAN_DETAIL,
			EVOR.PRODUCT_NAME2, 
            EVO.VIRTUAL_OFFER_HEAD, 
            EVO.FINISHDATE, 
            EVO.BRANCH_ID, 
            OFR.IS_STAGE, 
            EMR.MONTAGE_ROW_ID, 
            EMR.MONTAGE_ID, 
            EMR.STOCK_ID, 
         	EMR.PRODUCT_NAME, 
            EMR.AMOUNT, 
            EMR.MAIN_UNIT, 
            EMR.PRODUCT_UNIT_ID, 
            EMR.IS_HZM, 
            EVO.REVISION_NO, 
            EVOR.PRODUCT_NAME AS NAME_PRODUCT, 
            EVO.VIRTUAL_OFFER_DATE, 
            EVO.VIRTUAL_OFFER_STAGE, 
            EVO.VIRTUAL_OFFER_ID, 
         	EVO.RECORD_DATE, 
            EVO.RECORD_EMP, 
            EVO.SALES_COMPANY_ID, 
            EVO.VIRTUAL_OFFER_NUMBER, 
            EVO.COMPANY_ID, 
            EVO.CONSUMER_ID, 
            EVOR.QUANTITY, 
            EVOR.EZGI_ID, 
            ISNULL((
            	SELECT     
                	SUM(PREDICTED_AMOUNT) AS AMOUNT
          		FROM        
                	SERVICE_OPERATION WITH (NOLOCK)
             	WHERE     
                	WRK_ROW_ID = EMR.WRK_ROW_RELATION_ID
          	), 0) AS MONTAGE_AMOUNT, 
            ORR.ORDER_ROW_ID AS SA_ORDER_ROW_ID, 
            O.ORDER_NUMBER AS SA_ORDER_NUMBER, 
            ORR.QUANTITY AS SA_QUANTITY, 
            OFR.P_ORDER_ID, 
            OFR.MASTER_PLAN_NAME, 
          	OFR.MASTER_PLAN_NUMBER, 
            OFR.LOT_NO, 
            OFR.PO_QUANTITY, 
            OFR.PO_FINISH_DATE, 
            ORR1.ORDER_ROW_ID AS SV_ORDER_ROW_ID, 
            O1.ORDER_NUMBER AS SV_ORDER_NUMER, 
            ORR1.QUANTITY AS SV_QUANTITY,
            (
            	SELECT     
                	TOP (1) ESR.DELIVER_PAPER_NO
              	FROM       
                	EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) INNER JOIN
                 	EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) ON ESRR.SHIP_RESULT_ID = ESR.SHIP_RESULT_ID
             	WHERE     
                	ESRR.ORDER_ROW_ID = OFR.ORDER_ROW_ID
         	) AS DELIVER_PAPER_NO,
        	(
            	SELECT     
            		TOP (1) ESR.OUT_DATE
           		FROM      
                	EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) INNER JOIN
                  	EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) ON ESRR.SHIP_RESULT_ID = ESR.SHIP_RESULT_ID
             	WHERE     
                	ESRR.ORDER_ROW_ID = OFR.ORDER_ROW_ID
          	) AS OUT_DATE,
        	(
            	SELECT     
            		TOP (1) KONUM + ' - ' + DAIRE + ' - ' + MEKAN AS LOKASYON
             	FROM      
                	EZGI_VIRTUAL_OFFER_ROW_FLOOR WITH (NOLOCK)
              	WHERE     
                	EZGI_ID = EVOR.EZGI_ID
          	) AS LOKASYON
		FROM        
        	EZGI_SHIP_RESULT_ROW AS ESRR INNER JOIN
        	EZGI_SHIP_RESULT AS ESR ON ESRR.SHIP_RESULT_ID = ESR.SHIP_RESULT_ID INNER JOIN
        	EZGI_ORGE_RELATIONS AS OFR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = OFR.ORDER_ROW_ID RIGHT OUTER JOIN
         	ORDER_ROW AS ORR1 WITH (NOLOCK) INNER JOIN
        	ORDERS AS O1 WITH (NOLOCK) ON ORR1.ORDER_ID = O1.ORDER_ID RIGHT OUTER JOIN
          	EZGI_MONTAGE_ROW AS EMR WITH (NOLOCK) INNER JOIN
       		EZGI_VIRTUAL_OFFER_ROW AS EVOR WITH (NOLOCK) ON EMR.EZGI_ID = EVOR.EZGI_ID INNER JOIN
          	EZGI_VIRTUAL_OFFER AS EVO WITH (NOLOCK) ON EVOR.VIRTUAL_OFFER_ID = EVO.VIRTUAL_OFFER_ID INNER JOIN
         	ORDER_ROW AS ORR WITH (NOLOCK) ON EVOR.WRK_ROW_RELATION_ID = ORR.WRK_ROW_RELATION_ID INNER JOIN
    		ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID ON ORR1.WRK_ROW_RELATION_ID = ORR.WRK_ROW_ID ON OFR.EZGI_ID = EMR.EZGI_ID
		WHERE     
        	EMR.IS_HZM = 1
         	<cfif len(attributes.member_name)>
            	<cfif isdefined('attributes.company_id') and len(attributes.company_id)>
                    AND EVO.COMPANY_ID =#attributes.company_id#
                </cfif>
                <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
                    AND EVO.CONSUMER_ID =#attributes.consumer_id# 
                </cfif>
           	</cfif>
            <cfif len(attributes.keyword)>
            	AND 
                (
                	EVO.VIRTUAL_OFFER_NUMBER LIKE '%#attributes.keyword#%' OR
                    EVO.VIRTUAL_OFFER_DETAIL LIKE '%#attributes.keyword#%' OR
                    EVO.VIRTUAL_OFFER_HEAD LIKE '%#attributes.keyword#%' 
              	)
            </cfif>
            <cfif len(attributes.record_emp_name) and len(attributes.record_emp_id)>
            	AND EVO.RECORD_EMP = #attributes.record_emp_id#
            </cfif>

            <cfif session.ep.ISBRANCHAUTHORIZATION eq 1>
            	AND EVO.BRANCH_ID IN 
                				(
                                SELECT        
                                	BRANCH_ID
								FROM   
                                	#dsn_alias#.EMPLOYEE_POSITION_BRANCHES
								WHERE        
                                	POSITION_CODE = #session.ep.POSITION_CODE# AND 
                                    DEPARTMENT_ID IS NULL
                                
                                )
            </cfif>
            <cfif len(attributes.branch_id)>
            	AND EVO.BRANCH_ID = #attributes.branch_id#
            </cfif>
			<cfif len(attributes.montage_stock_ids)>
            	AND EMR.STOCK_ID IN (#attributes.montage_stock_ids#)
            </cfif>
            <cfif attributes.sales_type eq 1>
            	AND EVO.SALES_COMPANY_ID IS NOT NULL
           	<cfelseif attributes.sales_type eq 2>
            	AND EVO.BRANCH_ID IS NOT NULL
            </cfif>
            <cfif len(attributes.durum_uretim)>
				<cfif attributes.durum_uretim eq 1>
                    AND OFR.IS_STAGE = 1
                <cfelseif attributes.durum_uretim eq 2>
                    AND OFR.IS_STAGE = 2
                <cfelse>
                    AND OFR.IS_STAGE NOT IN (1,2)
                </cfif>
            </cfif>
            <cfif len(attributes.status)>
            	AND EMR.STATUS = #attributes.status#
            </cfif>
        	
      	ORDER BY
        	<cfif attributes.sort_type eq 2>
            	EVO.VIRTUAL_OFFER_NUMBER
            <cfelseif attributes.sort_type eq 3>
            	EVO.RECORD_DATE DESC
            <cfelseif attributes.sort_type eq 4>
            	EVO.FINISHDATE
            <cfelseif attributes.sort_type eq 5>
            	EVO.FINISHDATE desc
            </cfif>
    </cfquery>

    <cfquery name="get_montage" dbtype="query">
    	SELECT
        	UNVAN, 
         	MASTER_PLAN_DETAIL, 
         	PRODUCT_NAME2, 
        	VIRTUAL_OFFER_HEAD, 
          	FINISHDATE, 
          	BRANCH_ID, 
         	IS_STAGE, 
          	MONTAGE_ROW_ID, 
          	MONTAGE_ID, 
         	STOCK_ID, 
           	PRODUCT_NAME, 
         	AMOUNT, 
          	MAIN_UNIT, 
         	PRODUCT_UNIT_ID, 
          	IS_HZM, 
            REVISION_NO, 
        	NAME_PRODUCT, 
            VIRTUAL_OFFER_DATE, 
            VIRTUAL_OFFER_STAGE, 
            VIRTUAL_OFFER_ID, 
            RECORD_DATE, 
            RECORD_EMP, 
            SALES_COMPANY_ID, 
            VIRTUAL_OFFER_NUMBER, 
            COMPANY_ID, 
            CONSUMER_ID, 
            QUANTITY, 
            MONTAGE_AMOUNT,
            EZGI_ID,
            LOKASYON
       	FROM
        	get_montages
        WHERE
        	1=1
            <cfif attributes.durum_montaj eq 1>
            	AND MONTAGE_AMOUNT = QUANTITY
            <cfelseif attributes.durum_montaj eq 2>
            	AND MONTAGE_AMOUNT < QUANTITY
            </cfif>
      	GROUP BY
        	UNVAN, 
         	MASTER_PLAN_DETAIL, 
         	PRODUCT_NAME2, 
        	VIRTUAL_OFFER_HEAD, 
          	FINISHDATE, 
          	BRANCH_ID, 
         	IS_STAGE, 
          	MONTAGE_ROW_ID, 
          	MONTAGE_ID, 
         	STOCK_ID, 
           	PRODUCT_NAME, 
         	AMOUNT, 
          	MAIN_UNIT, 
         	PRODUCT_UNIT_ID, 
          	IS_HZM, 
            REVISION_NO, 
        	NAME_PRODUCT, 
            VIRTUAL_OFFER_DATE, 
            VIRTUAL_OFFER_STAGE, 
            VIRTUAL_OFFER_ID, 
            RECORD_DATE, 
            RECORD_EMP, 
            SALES_COMPANY_ID, 
            VIRTUAL_OFFER_NUMBER, 
            COMPANY_ID, 
            CONSUMER_ID, 
            QUANTITY, 
            MONTAGE_AMOUNT,
            EZGI_ID,
            LOKASYON
      	ORDER BY
        	VIRTUAL_OFFER_ID
    </cfquery>
	<cfset arama_yapilmali = 0>
<cfelse>
	<cfset get_montage.recordcount = 0>
    <cfset arama_yapilmali = 1>
</cfif>

<cfquery name="GET_COMPANY_CAT" datasource="#DSN#">
	SELECT COMPANYCAT_ID,COMPANYCAT FROM COMPANY_CAT ORDER BY COMPANYCAT
</cfquery>
<cfquery name="GET_CONSUMER_CAT" datasource="#DSN#">
	SELECT CONSCAT_ID,CONSCAT FROM CONSUMER_CAT ORDER BY HIERARCHY
</cfquery>
<cfquery name="get_branch" datasource="#dsn#">
	SELECT        
    	BRANCH_ID, BRANCH_NAME
	FROM            
    	BRANCH WITH (NOLOCK)
	WHERE        
    	BRANCH_ID IN
                  	(

                    	SELECT        
                        	BRANCH_ID
                    	FROM            
                        	EMPLOYEE_POSITION_BRANCHES WITH (NOLOCK)
                    	WHERE        
                        	POSITION_CODE = #session.ep.POSITION_CODE# AND 
                            DEPARTMENT_ID IS NULL
                   	)
      	AND COMPANY_ID = #session.ep.company_id# 
        AND BRANCH_STATUS = 1
</cfquery>
<cfoutput query="get_branch">
	<cfset 'BRANCH_NAME_#BRANCH_ID#' = BRANCH_NAME>
</cfoutput>

<cfquery name="MONTAGE_DEFAULTS" datasource="#DSN3#">
	SELECT     
    	E.STOCK_ID MONTAGE_STOCK_ID, 
        E.SORT_NO, 
        S.PRODUCT_NAME MONTAGE_PRODUCT_NAME,
        E.IS_ACTIVE
	FROM        
    	EZGI_VIRTUAL_OFFER_COST_DEFAULT AS E WITH (NOLOCK) INNER JOIN
      	STOCKS AS S WITH (NOLOCK) ON E.STOCK_ID = S.STOCK_ID
	ORDER BY 
    	E.SORT_NO
</cfquery>
<!---<cfif isdate(attributes.date1)><cfset attributes.date1 = dateformat(attributes.date1, "dd/mm/yyyy")></cfif>
<cfif isdate(attributes.date2)><cfset attributes.date2 = dateformat(attributes.date2, "dd/mm/yyyy")></cfif>--->
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_montage.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search_form" method="post" action="#request.self#?fuseaction=prod.list_ezgi_montage">
			<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <cf_box_search>
                <div class="form-group" id="form_ul_keyword">
                	<cfinput type="text" style="width:150px;" placeholder="#getLang(48,'Filtre',57460)#" maxlength="50" name="keyword" value="#attributes.keyword#">
              	</div>

                <div class="form-group medium" id="form_ul_branch_id">
                	<select name="branch_id" id="branch_id" style="width:180px; height:20px">
                     	<option value=""><cf_get_lang_main no='41.Şube'></option>
                        <cfoutput query="get_branch">
                        	<option value="#get_branch.branch_id#" <cfif attributes.branch_id eq get_branch.branch_id>selected</cfif>>#get_branch.branch_name#</option>
                        </cfoutput>
                  	</select>
                </div>
                <div class="form-group medium" id="form_ul_durum_montaj">
               		<select name="durum_montaj" id="durum_montaj" style="width:180px; height:20px">
                     	<option value="" <cfif attributes.durum_montaj eq "">selected</cfif>>Montaj Emri</option>
                        <option value="1" <cfif attributes.durum_montaj eq 1>selected</cfif>>Tamamlananlar</option>
                        <option value="2" <cfif attributes.durum_montaj eq 2>selected</cfif>>Eksik Olanlar</option>
                    </select>
                </div>
                <div class="form-group medium" id="form_ul_status">
               		<select name="status" id="status" style="width:180px; height:20px">
                       	<option value="" <cfif attributes.STATUS eq "">selected</cfif>>Durum</option>
                       	<option value="1" <cfif attributes.STATUS eq 1>selected</cfif>>Aktif</option>
                       	<option value="0" <cfif attributes.STATUS eq 0>selected</cfif>>Pasif</option>
                  	</select>
                </div>
                <div class="form-group" id="form_ul_date">
                	<div class="col col-12">
                    	<div class="col col-4 pl-0">
                    		<label class="col col-12">Sevk Plan Tarihi</label>
                        </div>
                     	<div class="col col-4 pl-0">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='30122.Başlangıç Tarihini Kontrol Ediniz'></cfsavecontent>
                                <cfinput type="text" name="date1" value="#dateformat(attributes.date1, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#" placeholder="Başlangıç Tarihi">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="date1"></span>
                            </div>
                       	</div>
                        <div class="col col-4 pl-0">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='30123.Bitiş Tarihini Kontrol Ediniz'></cfsavecontent>
                                <cfinput type="text" name="date2" value="#dateformat(attributes.date2, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#" placeholder="Bitiş Tarihi">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="date2"></span>
                            </div>
                       	</div>
                   	</div>
                </div>
                <div class="form-group small">
                 	<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Kayıt Sayısı Hatalı!'></cfsavecontent>
                 	<cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,1250" required="yes" message="#message#">
            	</div>
               	<div class="form-group">
                	<cf_wrk_search_button search_function='input_control()' button_type="4">
             	</div>
         	</cf_box_search>
          	<cf_box_search_detail> 
             	<div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="form_ul_record_emp_id">
                     	<label class="col col-12"><cf_get_lang_main no='487.Kaydeden'></label>
                      	<div class="col col-12">
                         	<div class="input-group">
                            	<input type="hidden" name="record_emp_id" id="record_emp_id" value="<cfif isdefined("attributes.record_emp_id")><cfoutput>#attributes.record_emp_id#</cfoutput></cfif>">
								<input name="record_emp_name" type="text" id="record_emp_name" style="width:175px;" onfocus="AutoComplete_Create('record_emp_name','FULLNAME','FULLNAME','get_emp_pos','','EMPLOYEE_ID','record_emp_id','','3','130');" value="<cfif isdefined("attributes.record_emp_id") and len(attributes.record_emp_id)><cfoutput>#attributes.record_emp_name#</cfoutput></cfif>" maxlength="255" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=search_form.record_emp_id&field_name=search_form.record_emp_name<cfif fusebox.circuit is "store">&is_store_module=1</cfif>&select_list=1&is_form_submitted=1&keyword='+encodeURIComponent(document.search_form.record_emp_name.value),'list','popup_list_positions');"></span>
                            </div>
                      	</div>
              		</div>
                    <div class="form-group" id="form_ul_member_name">
                     	<label class="col col-12"><cf_get_lang_main no='107.Cari Hesap'></label>
                      	<div class="col col-12">
                         	<div class="input-group">
                            	<input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#attributes.consumer_id#</cfoutput>">
                   				<input type="hidden" name="company_id"  id="company_id" value="<cfoutput>#attributes.company_id#</cfoutput>">
                       			<input type="hidden" name="member_type" id="member_type" value="<cfoutput>#attributes.member_type#</cfoutput>">
                      			<input type="text"   name="member_name" id="member_name" style="width:175px;"  value="<cfoutput>#attributes.member_name#</cfoutput>" onFocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2\'','COMPANY_ID,CONSUMER_ID,MEMBER_TYPE','company_id,consumer_id,member_type','','3','250');" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&field_consumer=search_form.consumer_id&field_comp_id=search_form.company_id&field_member_name=search_form.member_name&field_type=search_form.member_type&select_list=7,8&keyword='+encodeURIComponent(document.search_form.member_name.value),'list');"></span>
                            </div>
                      	</div>
              		</div>
               	</div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="2" sort="true">
                	<div class="form-group" id="form_ul_record_emp_id">
                     	<label class="col col-12">Montaj Tipleri</label>
                      	<div class="col col-12">
                         	<div class="input-group">
                            	<select name="montage_stock_ids" id="montage_stock_ids" style="height:90px;width:200px" multiple="multiple">
									<cfoutput query="MONTAGE_DEFAULTS">
                                        <option value="#montage_stock_id#"<cfif Listfind(attributes.montage_stock_ids, montage_stock_id)>selected</cfif>>#MONTAGE_PRODUCT_NAME#</option>
                                    </cfoutput>
                                </select>
                            </div>
                      	</div>
              		</div>
               	</div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="3" sort="true">
                	<div class="form-group" id="form_ul_record_emp_id">
                     	<label class="col col-12">Sıralama</label>
                      	<div class="col col-12">
                         	<div class="input-group">
                            	<select name="sort_type" id="sort_type" style="width:175px; height:20px">
                                    <option value="2" <cfif attributes.sort_type eq 2>selected</cfif>>Teklif Nosuna Göre Artan</option>
                                    <option value="3" <cfif attributes.sort_type eq 3>selected</cfif>>Kayıt Tarihine Göre Azalan</option>
                                    <option value="4" <cfif attributes.sort_type eq 4>selected</cfif>>Sözleşme Tarihine Göre Artan</option>
                                    <option value="5" <cfif attributes.sort_type eq 5>selected</cfif>>Sözleşme Tarihine Göre Azalan</option>
                                </select>
                            </div>
                      	</div>
              		</div>
                    <div class="form-group" id="form_ul_member_name">
                     	<label class="col col-12">Üretim Durumu</label>
                      	<div class="col col-12">
                         	<div class="input-group">
                            	<select name="durum_uretim" id="durum_uretim" style="width:180px; height:20px">
                                    <option value="" <cfif attributes.durum_uretim eq "">selected</cfif>>Tümü</option>
                                    <option value="0" <cfif attributes.durum_uretim eq 0>selected</cfif>>Başlamayanlar</option>
                                    <option value="1" <cfif attributes.durum_uretim eq 1>selected</cfif>>Başlayanlar</option>
                                    <option value="2" <cfif attributes.durum_uretim eq 2>selected</cfif>>Bitenler</option>
                                </select>
                            </div>
                      	</div>
              		</div>
               	</div>
         	</cf_box_search_detail> 
        </cfform>
    </cf_box>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id="817.Montaj Emirleri"></cfsavecontent>
    <cf_box title="#message#" uidrop="1" hide_table_column="1" woc_setting = "#{ checkbox_name : 'print_invoice_id', print_type : 10 }#">
    	<cf_grid_list sort="1">
        	<thead>
                <tr>
                    <th style="width:25px"><cf_get_lang_main no='1165.Sıra'></th>
                    <th style="width:80px">Teklif No</th>
                    <th style="width:60px">Sözleşme Tarihi</th>
                    <th style="width:150px">Müşteri</th>
                    <th style="width:90px">Bayi / Şube</th>
                    <th>Ürün Cinsi</th>
                    <th style="width:25px"></th>
                    <th style="width:50px">Miktar</th>
                    <th style="width:120px">Hizmet Cinsi</th>
                    <th style="width:90px">Açıklama</th>
                    <th style="width:60px">Sipariş No</th>
                    <th style="width:50px">Sipariş<br>Miktarı</th>
                    <th style="width:100px">Üretim Programı</th>
                    <th style="width:60px">Üretim Çıkış<br>Tarihi</th>
                    <th style="width:60px">Lot No</th>
                    <th style="width:50px">Üretim<br>Miktarı</th>
                    <th style="width:60px">Sevk Plan No</th>
                    <th style="width:60px">Sevk Plan<br>Tarihi</th>
                    <th style="width:40px">Montaj<br>Miktarı</th>
                    <th style="width:30px">Birim</th>
                    <th style="width:40px">Verilen<br>Miktar</th>
                    <th style="width:40px">Kalan<br>Miktar</th>
                    <!-- sil -->
                    <th class="header_icn_none" style="text-align:center">
                        <input type="checkbox" name="all_conv_product" id="all_conv_product" onClick="javascript: wrk_select_all2('all_conv_product','_select_product_',<cfoutput>#get_montage.recordcount#</cfoutput>);">
                    </th>
                    <!-- sil -->
                </tr>
            </thead>
            <tbody>
                <cfif get_montage.recordcount>
                    <cfoutput query="get_montage" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                        <cfquery name="get_orders" dbtype="query">
                            SELECT     
                                SA_ORDER_ROW_ID, 
                                SA_ORDER_NUMBER, 
                                SA_QUANTITY
                            FROM
                                get_montages
                            WHERE
                                EZGI_ID = #get_montage.EZGI_ID#
                            GROUP BY
                                SA_ORDER_ROW_ID, 
                                SA_ORDER_NUMBER, 
                                SA_QUANTITY
                            ORDER BY
                                SA_ORDER_ROW_ID	     	
                        </cfquery>
                        <cfquery name="get_p_orders" dbtype="query">
                            SELECT     
                                PO_QUANTITY, 
                                PO_FINISH_DATE, 
                                LOT_NO, 
                                MASTER_PLAN_DETAIL,
                                IS_STAGE,
                                P_ORDER_ID
                            FROM
                                get_montages
                            WHERE
                                EZGI_ID = #get_montage.EZGI_ID#
                            GROUP BY
                                PO_QUANTITY, 
                                PO_FINISH_DATE, 
                                LOT_NO, 
                                MASTER_PLAN_DETAIL,
                                IS_STAGE,
                                P_ORDER_ID 
                            HAVING
                                NOT (P_ORDER_ID IS NULL)
                            UNION ALL
                            SELECT
                                SV_QUANTITY AS PO_QUANTITY,
                                #now()# AS PO_FINISH_DATE,
                                SV_ORDER_NUMER AS LOT_NO, 
                                '' AS MASTER_PLAN_NAME,
                                0 AS IS_STAGE,
                                SV_ORDER_ROW_ID AS P_ORDER_ID
                            FROM
                                get_montages
                            WHERE
                                EZGI_ID = #get_montage.EZGI_ID#
                            GROUP BY
                                SV_QUANTITY,
                                SV_ORDER_NUMER,
                                SV_ORDER_ROW_ID
                            HAVING
                                NOT (SV_ORDER_ROW_ID IS NULL)       
                            ORDER BY
                                LOT_NO
                        </cfquery>
                        <cfquery name="get_sevk_plan" dbtype="query">
                            SELECT     
                                DELIVER_PAPER_NO, 
                                OUT_DATE, 
                                SA_ORDER_ROW_ID
                            FROM
                                get_montages
                            WHERE
                                EZGI_ID = #get_montage.EZGI_ID#
                            GROUP BY
                                DELIVER_PAPER_NO, 
                                OUT_DATE, 
                                SA_ORDER_ROW_ID
                        </cfquery>
                        <cfloop query="get_sevk_plan">
                            <cfset 'DELIVER_PAPER_NO_#SA_ORDER_ROW_ID#' = DELIVER_PAPER_NO>
                            <cfset 'OUT_DATE_#SA_ORDER_ROW_ID#' = OUT_DATE>
                        </cfloop> 
                        <tr> 
                            <td style=" vertical-align:middle; text-align:right;">#CURRENTROW#</td>
                            <td style=" vertical-align:middle ;text-align:left;"><a href="#request.self#?fuseaction=prod.upd_ezgi_virtual_offer&virtual_offer_id=#get_montage.virtual_offer_id#" class="tableyazi">#VIRTUAL_OFFER_NUMBER#<cfif len(REVISION_NO)> <span style="font-weight:bold; color:red">Rev:#REVISION_NO#</span></cfif></a></td>
                            
                            <td style=" vertical-align:middle; text-align:center;">#DateFormat(FINISHDATE,'DD/MM/YYYY')#</td>
                            <td style=" vertical-align:middle; text-align:LEFT;">#UNVAN#</td>
                            <td style=" vertical-align:middle" nowrap="nowrap">
                                <cfif len(get_montage.SALES_COMPANY_ID)>
                                    #get_par_info(get_montage.SALES_COMPANY_ID,1,1,0)#
                                <cfelse>
                                    <cfif isdefined('BRANCH_NAME_#BRANCH_ID#')>
                                        #Evaluate('BRANCH_NAME_#BRANCH_ID#')#
                                    </cfif>
                                </cfif>
                            </td>
                            
                            <td style=" vertical-align:middle" nowrap="nowrap">#Left(NAME_PRODUCT,80)#<cfif len(NAME_PRODUCT) gt 80>...</cfif></td>
                            <td style="text-align:center">
                                <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_upd_ezgi_virtual_offer_row_floor_info&ezgi_id=#ezgi_id#&kilit=1','list');" style="text-align:center">
                                    <img src="images/plus_thin.gif" title="Detaylı Satır Açıklaması" border="0" />
                                </a>
                            </td>
                            <td style=" vertical-align:middle; text-align:right;">#AmountFormat(QUANTITY)#</td>
                            <td style=" vertical-align:middle" nowrap="nowrap">#Left(PRODUCT_NAME,50)#<cfif len(PRODUCT_NAME) gt 50>...</cfif></td>
                            <td style=" vertical-align:middle" nowrap="nowrap">#LOKASYON#</td>
                            <td style=" vertical-align:middle">
                                <cfif get_orders.recordcount>
                                    <table cellpadding="0" cellspacing="0" border="0" style="width:100%">
                                        <cfloop query="get_orders">
                                            <tr>
                                                <td nowrap style="text-align:center; height:15px">#get_orders.SA_ORDER_NUMBER#</td>
                                            </tr>
                                        </cfloop>
                                    </table>
                                </cfif>
                            </td>
                            <td style=" vertical-align:middle">
                                <cfif get_orders.recordcount>
                                    <table cellpadding="0" cellspacing="0" border="0" style="width:100%">
                                        <cfloop query="get_orders">
                                            <tr>
                                                <td style="text-align:right; height:15px">#AmountFormat(get_orders.SA_QUANTITY)#</td>
                                            </tr>
                                        </cfloop>
                                    </table>
                                </cfif>
                            </td>
                            <td style=" vertical-align:middle">
                                <cfif get_p_orders.recordcount>
                                    <table cellpadding="0" cellspacing="0" border="0" style="width:100%">
                                        <cfloop query="get_p_orders">
                                            <tr>
                                                <td style="text-align:left; height:15px" nowrap="nowrap">#Left(get_p_orders.MASTER_PLAN_DETAIL,40)#<cfif len(get_p_orders.MASTER_PLAN_DETAIL) gt 40>...</cfif></td>
                                            </tr>
                                        </cfloop>
                                    </table>
                                </cfif>
                            </td>
                            <td style=" vertical-align:middle">
                                <cfif get_p_orders.recordcount>
                                    <table cellpadding="0" cellspacing="0" border="0" style="width:100%">
                                        <cfloop query="get_p_orders">
                                            <tr>
                                                <td style="text-align:center;height:15px">#DateFormat(get_p_orders.PO_FINISH_DATE,'DD/MM/YYYY')#</td>
                                            </tr>
                                        </cfloop>
                                    </table>
                                </cfif>
                            </td>
                            <td style=" vertical-align:middle">
                                <cfif get_p_orders.recordcount>
                                    <table cellpadding="0" cellspacing="0" border="0" style="width:100%">
                                        <cfloop query="get_p_orders">
                                            <tr>
                                                <td style="text-align:center; height:15px; font-weight:bold; color:<cfif get_p_orders.IS_STAGE eq 2>red<cfelseif get_p_orders.IS_STAGE eq 1>green<cfelse>orange</cfif>">
                                                    #get_p_orders.LOT_NO#
                                                </td>
                                            </tr>
                                        </cfloop>
                                    </table>
                                </cfif>
                            </td>
                            <td style=" vertical-align:middle">
                                <cfif get_p_orders.recordcount>
                                    <table cellpadding="0" cellspacing="0" border="0" style="width:100%">
                                        <cfloop query="get_p_orders">
                                            <tr>
                                                <td style="text-align:right; height:15px;">#AmountFormat(get_p_orders.PO_QUANTITY)#</td>
                                            </tr>
                                        </cfloop>
                                    </table>
                                </cfif>
                            </td>
                            <td style=" vertical-align:middle">
                                <cfif get_orders.recordcount>
                                    <table cellpadding="0" cellspacing="0" border="0" style="width:100%">
                                        <cfloop query="get_orders">
                                            <tr>
                                                <td style="text-align:center; height:15px">
                                                    <cfif isdefined('DELIVER_PAPER_NO_#get_orders.SA_ORDER_ROW_ID#')>
                                                        #Evaluate('DELIVER_PAPER_NO_#get_orders.SA_ORDER_ROW_ID#')#
                                                    </cfif>
                                                </td>
                                            </tr>
                                        </cfloop>
                                    </table>
                                </cfif>
                            </td>
                            <td style=" vertical-align:middle">
                                <cfif get_orders.recordcount>
                                    <table cellpadding="0" cellspacing="0" border="0" style="width:100%">
                                        <cfloop query="get_orders">
                                            <tr>
                                                <td style="text-align:center; height:15px">
                                                    <cfif isdefined('OUT_DATE_#get_orders.SA_ORDER_ROW_ID#')>
                                                        #DateFormat(Evaluate('OUT_DATE_#get_orders.SA_ORDER_ROW_ID#'),'DD/MM/YYYY')#
                                                    </cfif>
                                                </td>
                                            </tr>
                                        </cfloop>
                                    </table>
                                </cfif>
                            </td>
                            <td style=" vertical-align:middle;text-align:right;">#AmountFormat(QUANTITY*AMOUNT,2)#</td>
                            <td style=" vertical-align:middle;text-align:left;">#MAIN_UNIT#</td>
                            <cfset kalan = QUANTITY-MONTAGE_AMOUNT>
                            <td style=" vertical-align:middle;text-align:right;">#AmountFormat(MONTAGE_AMOUNT,2)#</td>
                            <td style=" vertical-align:middle;text-align:right;">
                                <input name="montage_amount_#EZGI_ID#_#STOCK_ID#" id="montage_amount_#EZGI_ID#_#STOCK_ID#" value="#AmountFormat(kalan,2)#" class="box" style="width:50px">
                            </td>
    
                            <CFSET t_amount = t_amount + (QUANTITY*AMOUNT)>
                            <!-- sil -->
                            <td style=" vertical-align:middle;text-align:center;">
                                <input type="checkbox" name="select_product_#EZGI_ID#_#STOCK_ID#" value="#stock_id#" id="_select_product_#currentrow#">
                            </td>
                            <!-- sil -->
                        </tr>
                    </cfoutput>
                    <tr>
                        <td></td>
                        <td colspan="15" style="vertical-align:top">
                            <cfif attributes.durum_montaj eq 2>
                                <cfif attributes.status eq 1>
                                    <input type="button" value="Seçileni Pasif Yap" name="pasif" id="pasif" onClick="basvuru_kontrol(2);" style="width:150px;">
                                <cfelseif attributes.status eq 0>
                                    <input type="button" value="Seçileni Aktif Yap" name="aktif" id="aktif" onClick="basvuru_kontrol(3);" style="width:150px;">
                                </cfif>
                            </cfif>	
                        </td>
                        <td colspan="2"><strong>Toplam</strong></td>
                        <td style="text-align:right;"><strong><cfoutput>#AmountFormat(t_amount,2)#</cfoutput></strong></td>
                        <td></td>
                        <TD colspan="3" style="text-align:right; padding-right:2px">
                            <button name="basvuru" id="basvuru" style="width:100%; height:30px; background-color:darkturquoise" onClick="basvuru_kontrol(1);" ><cfoutput>#getLang('call',96)#</cfoutput></button>
                        </TD>
                        
                    </tr>
                <cfelse>
                    <tr> 
                        <td colspan="21" height="20"><cfif arama_yapilmali eq 1><cf_get_lang_main no='289.Filtre Ediniz'> !<cfelse><cf_get_lang_main no='72.Kayıt Yok'>!</cfif></td>
                    </tr>
                </cfif>
            </tbody>
      	</cf_grid_list>
        <cfset adres = url.fuseaction>
		<cfif isdefined("attributes.is_form_submitted") and attributes.totalrecords gt attributes.maxrows>
			<cfif len(attributes.member_name)>
              <cfset adres = '#adres#&company_id=#attributes.company_id#'>
              <cfset adres = '#adres#&member_name=#attributes.member_name#'>
            </cfif>		
            <cfif len(attributes.keyword)>
              <cfset adres = '#adres#&keyword=#URLEncodedFormat(attributes.keyword)#'>
            </cfif>
            <cfif len(attributes.sales_type)>
                <cfset adres = '#adres#&sales_type=#attributes.sales_type#'>
            </cfif>
            <cfif len(attributes.sort_type)>
                <cfset adres = '#adres#&sort_type=#attributes.sort_type#'>
            </cfif>
            <cfif len(attributes.list_type)>
                <cfset adres = '#adres#&list_type=#attributes.list_type#'>
            </cfif>
                <cfif len(attributes.durum_montaj)>
                <cfset adres = '#adres#&durum_montaj=#attributes.durum_montaj#'>
            </cfif>
            <cfif len(attributes.durum_uretim)>
                <cfset adres = '#adres#&durum_uretim=#attributes.durum_uretim#'>
            </cfif>
            <cfif len(attributes.montage_stock_ids)>
                <cfset adres = '#adres#&montage_stock_ids=#attributes.montage_stock_ids#'>
            </cfif>
            <cfif len(attributes.record_emp_name)>
                <cfset adres = '#adres#&record_emp_name=#attributes.record_emp_name#'>
                <cfset adres = '#adres#&record_emp_id=#attributes.record_emp_id#'>
            </cfif>
            <cfif len(attributes.currency_id)>
                <cfset adres = '#adres#&currency_id=#attributes.currency_id#'>
            </cfif>
            <cfif isdefined('attributes.currency_type')>
                <cfset adres = '#adres#&currency_type=#attributes.currency_type#'>
            </cfif>
     		<cf_paging 
                page="#attributes.page#"
                maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                startrow="#attributes.startrow#"
                adres="#adres#&is_form_submitted=1">
        </cfif>
  	</cf_box>
</div>
<form name="aktar_form" method="post">
    <input type="hidden" name="convert_ezgi_stocks_id" id="convert_ezgi_stocks_id" value="">
	<input type="hidden" name="convert_amount_ezgi_stocks_id" id="convert_amount_ezgi_stocks_id" value="">
</form>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function basvuru_kontrol(type)
	{
		var convert_list ="";
		var convert_list_amount ="";

		<cfif isdefined("attributes.is_form_submitted")>
			 <cfoutput query="get_montage" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
			 	 if(document.all.select_product_#EZGI_ID#_#STOCK_ID#.checked && filterNum(document.getElementById('montage_amount_#EZGI_ID#_#STOCK_ID#').value) > 0)
				 {
					 convert_list += "#EZGI_ID#_#STOCK_ID#,";
					 convert_list_amount += filterNum(document.getElementById('montage_amount_#EZGI_ID#_#STOCK_ID#').value,2)+',';
				 }
			 </cfoutput>
		</cfif>
		document.getElementById('convert_ezgi_stocks_id').value=convert_list;
		document.getElementById('convert_amount_ezgi_stocks_id').value=convert_list_amount;
		if(convert_list)//Ürün Seçili ise
		{
			 
			 if(type==1)
			 {
				windowopen('','longpage','cc_paym');
				aktar_form.action="<cfoutput>#request.self#?fuseaction=service.popup_add_ezgi_montage_service</cfoutput>";
				document.getElementById('basvuru').disabled=true;
				aktar_form.target='cc_paym';
				aktar_form.submit();
			 }
			  if(type==2)
			 {
				sor_pasif=confirm('Seçilen Kayıtlar Pasif Edilecektir.');
				if(sor_pasif==true)
				{
					search_form.action="<cfoutput>#request.self#</cfoutput>?fuseaction=prod.list_ezgi_montage&update_status=0&convert_list="+convert_list; 
					search_form.submit();
				}
				else
					return false;
			 }
			  if(type==3)
			 {
				sor_aktif=confirm('Seçilen Kayıtlar Aktif Edilecektir.');
				if(sor_aktif==true)
				{
					search_form.action="<cfoutput>#request.self#</cfoutput>?fuseaction=prod.list_ezgi_montage&update_status=1&convert_list="+convert_list; 
					search_form.submit();
				}
				else
					return false;
			 }
			 
		}
		else
		 	alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no ='245.Ürün'>.");
	}
	function wrk_select_all2(all_conv_product,_select_product_,number)
	{
		for(var cl_ind=1; cl_ind <= number; cl_ind++)
		{
			if(document.getElementById(all_conv_product).checked == true)
			{
				if(document.getElementById('_select_product_'+cl_ind).checked == false)
					document.getElementById('_select_product_'+cl_ind).checked = true;
			}
			else
			{
				if(document.getElementById('_select_product_'+cl_ind).checked == true)
					document.getElementById('_select_product_'+cl_ind).checked = false;
			}
		}
	}
	function input_control()
	{
		return true;
	}
</script>   
                        