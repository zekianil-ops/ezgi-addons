<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.sort_type" default="2">
<cfparam name="attributes.list_type" default="1">
<cfparam name="attributes.is_confirm" default="0">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.member_name" default="">
<cfparam name="attributes.member_type" default="">
<CFSET t_amount = 0>
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
<cfif isdefined("attributes.update_date") and isdate(attributes.update_date)>
	<cf_date tarih="attributes.update_date">
<cfelse>
	<cfparam name="attributes.update_date" default="">
</cfif>
<cfif isdefined("attributes.is_form_submitted")>
	<cfquery name="get_revision_tracing_detail" datasource="#dsn3#">
        SELECT DISTINCT  
        	CASE
         		WHEN EOR.COMPANY_ID IS NOT NULL THEN
                   (
                    SELECT     
                      	NICKNAME
					FROM         
                    	#dsn_alias#.COMPANY
					WHERE     
                   		COMPANY_ID = EOR.COMPANY_ID
                  	)
          		WHEN EOR.CONSUMER_ID IS NOT NULL THEN      
                   	(	
                  	SELECT     
                     	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
					FROM         
                      	#dsn_alias#.CONSUMER
					WHERE     
                		CONSUMER_ID = EOR.CONSUMER_ID
               		)
          	END AS UNVAN ,
			EOR.VIRTUAL_OFFER_STAGE, 
            EOR.VIRTUAL_OFFER_NUMBER, 
            EOR.VIRTUAL_OFFER_DATE, 
            EOR.COMPANY_ID, 
            EOR.CONSUMER_ID, 
            EOR.NAME_PRODUCT, 
            EOR.QUANTITY, 
            EOR.PRODUCT_NAME, 
            EOR.SPECT_MAIN_ID, 
         	EOR.OFFER_NUMBER, 
            EOR.ORDER_NUMBER, 
            EOR.LOT_NO, 
            EOR.MASTER_PLAN_NAME, 
            EOR.MASTER_PLAN_NUMBER, 
            EOR.EZGI_ID, 
            EOR.VIRTUAL_OFFER_ID, 
            EOR.STOCK_ID, 
            EOR.PRODUCT_ID, 
            EOR.PRODUCT_NAME2, 
            EOR.P_ORDER_ID, 
            EOR.ORDER_ID, 
            EOR.OFFER_ID, 
            EOR.MASTER_PLAN_ID, 
            EOR.PROJECT_ID, 
            EOR.IS_STAGE, 
            EOR.UNIT,
            EOR.OR_QUANTITY,
            EOR.OF_QUANTITY,
            EOR.PO_QUANTITY,
            ISNULL(EOR.ORDER_ROW_ID,0) AS ORDER_ROW_ID,
            ISNULL(TBL.DESIGN_MAIN_ROW_ID,0) AS DESIGN_MAIN_ROW_ID, 
        	ISNULL(TBL.DESIGN_ID,0) AS DESIGN_ID,
            ISNULL(TBB.IS_TREE,0) AS IS_TREE
            <cfif attributes.list_type eq 1>
                ,EVORD.VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID,
                EVORD.IS_CONFIRM,
                EVORD.CONFIRM_EMP, 
                EVORD.CONFIRM_DATE,
                EVORD.UPDATE_DATE,
                ISNULL(EVORD.IS_REVISION,0) as IS_REVISION
            </cfif>
		FROM     
        	EZGI_ORGE_RELATIONS AS EOR LEFT OUTER JOIN
            <cfif attributes.list_type eq 1>
                EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY AS EVORD ON EOR.EZGI_ID = EVORD.EZGI_ID LEFT OUTER JOIN
            </cfif>
            (
            	SELECT 
                	EDMR.DESIGN_MAIN_ROW_ID, 
                    EDMR.DESIGN_ID, 
                    EVOR.EZGI_ID
				FROM     
                	EZGI_DESIGN_MAIN_ROW AS EDMR INNER JOIN
                  	OFFER_ROW AS OFR ON EDMR.WRK_ROW_RELATION_ID = OFR.WRK_ROW_ID INNER JOIN
                  	OFFER AS O ON OFR.OFFER_ID = O.OFFER_ID INNER JOIN
                  	EZGI_VIRTUAL_OFFER_ROW AS EVOR ON OFR.WRK_ROW_ID = EVOR.WRK_ROW_RELATION_ID
				WHERE  
                	NOT (EVOR.EZGI_ID IS NULL)
            ) AS TBL ON TBL.EZGI_ID = EOR.EZGI_ID LEFT OUTER JOIN
            (
            	SELECT 
                	IS_TREE, 
                    SPECT_MAIN_ID
				FROM     
                	SPECT_MAIN
				WHERE  
                IS_TREE = 1
            ) AS TBB ON TBB.SPECT_MAIN_ID = EOR.SPECT_MAIN_ID
		WHERE  
            EOR.VIRTUAL_OFFER_STATUS = 1
            <cfif len(attributes.keyword)>
            	AND 
                (
                    EOR.VIRTUAL_OFFER_NUMBER LIKE '%#attributes.keyword#%' OR
                    EOR.LOT_NO LIKE '%#attributes.keyword#%' 
              	)
            </cfif>
           
            <cfif isdefined('attributes.date1') and len(attributes.date1)>
              	AND EOR.VIRTUAL_OFFER_DATE  >= #attributes.date1#  
         	</cfif>
          	<cfif isdefined('attributes.date2') and len(attributes.date2)>
              	AND EOR.VIRTUAL_OFFER_DATE  <= #attributes.date2#
          	</cfif>
            <cfif attributes.list_type eq 1 and isdefined('attributes.update_date') and len(attributes.update_date)>
              	AND EVORD.UPDATE_DATE  >= #attributes.update_date#  
                AND EVORD.UPDATE_DATE  < #DateAdd('d',1,attributes.update_date)# 
         	</cfif>
            <cfif len(attributes.member_name)>
            	<cfif isdefined('attributes.company_id') and len(attributes.company_id)>
                    AND EOR.COMPANY_ID =#attributes.company_id#
                </cfif>
                <cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
                    AND EOR.CONSUMER_ID =#attributes.consumer_id# 
                </cfif>
           	</cfif>
            <cfif attributes.list_type eq 1>
                <cfif len(attributes.is_confirm)>
                    <cfif attributes.is_confirm eq 0>
                        AND EVORD.IS_CONFIRM IS NULL
                    <cfelse>
                        AND EVORD.IS_CONFIRM = #attributes.is_confirm#
                    </cfif>
                </cfif>
            	AND ISNULL(EVORD.IS_REVISION,0) = 1
                AND EVORD.VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID IN 
                                                                (
                                                                    SELECT 
                                                                        MAX(VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID) AS VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID
                                                                    FROM  
                                                                        EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY
                                                                    WHERE  
                                                                        ISNULL(IS_CONFIRM,0) = 0 AND 
                                                                        ISNULL(IS_REVISION,0) = 1
                                                                    GROUP BY 
                                                                        EZGI_ID
                                                                )
            </cfif>
      	ORDER BY
        	EOR.VIRTUAL_OFFER_DATE
            <cfif attributes.sort_type eq 2>DESC</cfif>
    </cfquery>
    <cfquery name="get_revision_tracing" dbtype="query">
        SELECT
            UNVAN ,
            VIRTUAL_OFFER_STAGE, 
            VIRTUAL_OFFER_NUMBER, 
            VIRTUAL_OFFER_DATE, 
            COMPANY_ID, 
            CONSUMER_ID, 
            NAME_PRODUCT, 
            QUANTITY, 
            PRODUCT_NAME, 
            OFFER_NUMBER, 
            EZGI_ID, 
            VIRTUAL_OFFER_ID, 
            STOCK_ID, 
            PRODUCT_ID, 
            PRODUCT_NAME2, 
            OFFER_ID, 
            PROJECT_ID, 
            UNIT,
            OF_QUANTITY,
            DESIGN_MAIN_ROW_ID, 
            DESIGN_ID,
            SPECT_MAIN_ID,
            IS_TREE  
            <cfif attributes.list_type eq 1>
                ,VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID,
                IS_CONFIRM,
                CONFIRM_EMP, 
                CONFIRM_DATE,
                UPDATE_DATE,
                IS_REVISION
            </cfif>
        FROM
            get_revision_tracing_detail
        GROUP BY
            UNVAN ,
            VIRTUAL_OFFER_STAGE, 
            VIRTUAL_OFFER_NUMBER, 
            VIRTUAL_OFFER_DATE, 
            COMPANY_ID, 
            CONSUMER_ID, 
            NAME_PRODUCT, 
            QUANTITY, 
            PRODUCT_NAME, 
            OFFER_NUMBER, 
            EZGI_ID, 
            VIRTUAL_OFFER_ID, 
            STOCK_ID, 
            PRODUCT_ID, 
            PRODUCT_NAME2, 
            OFFER_ID , 
            PROJECT_ID,
            UNIT,
            OF_QUANTITY,
            DESIGN_MAIN_ROW_ID, 
            DESIGN_ID,
            SPECT_MAIN_ID,
            IS_TREE
            <cfif attributes.list_type eq 1>
                ,VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID,
                IS_CONFIRM,
                CONFIRM_EMP, 
                CONFIRM_DATE,
                UPDATE_DATE,
                IS_REVISION
            </cfif>
    </cfquery>
	<cfset arama_yapilmali = 0>
<cfelse>
	<cfset get_revision_tracing.recordcount = 0>
    <cfset arama_yapilmali = 1>
</cfif>

<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_revision_tracing.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search_form" method="post" action="#request.self#?fuseaction=prod.list_ezgi_revision_tracing">
			<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <cf_box_search>
                <div class="form-group">
                	<cfinput type="text" style="width:150px;" placeholder="#getLang(48,'Filtre',57460)#" maxlength="50" name="keyword" value="#attributes.keyword#">
              	</div>
                <div class="form-group large">
               		<select name="sort_type" id="sort_type" style="width:175px; height:20px">
                     	<option value="1" <cfif attributes.sort_type eq 1>selected</cfif>>Teklif Tarihine Göre Artan</option>
                      	<option value="2" <cfif attributes.sort_type eq 2>selected</cfif>>Teklif Tarihine Göre Azalan</option>
                	</select>
                </div>

                <div class="form-group medium" >
               		<select name="is_confirm" id="is_confirm" style="width:180px; height:20px">
                       	<option value="" <cfif attributes.is_confirm eq "">selected</cfif>>Tümü</option>
                       	<option value="0" <cfif attributes.is_confirm eq 0>selected</cfif>>Cevaplanmayan</option>
                       	<option value="1" <cfif attributes.is_confirm eq 1>selected</cfif>>Onaylanan</option>
                        <option value="2" <cfif attributes.is_confirm eq 2>selected</cfif>>Reddedilen</option>
                  	</select>
                </div>
                <div class="form-group medium" >
               		<select name="list_type" id="list_type" style="width:180px; height:20px">
                       	<option value="1" <cfif attributes.list_type eq 1>selected</cfif>>Revizyon Takibi Olanlar</option>
                        <option value="0" <cfif attributes.list_type eq 0>selected</cfif>>Revizyon Takibi Olmayanlar</option>
                  	</select>
                </div>
                <div class="form-group medium" >
                	<div class="input-group">
                    	<cfsavecontent variable="message">Tarihi Kontrol Ediniz</cfsavecontent>
                     	<cfinput type="text" name="update_date" value="#dateformat(attributes.update_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#" placeholder="Onay İstem Tarihi">
                      	<span class="input-group-addon"><cf_wrk_date_image date_field="update_date"></span>
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
					<div class="form-group" id="form_ul_kabul_date">
                		<label class="col col-12">Sanal Teklif Tarihi</label>
                        <div class="col col-12">
                            <div class="col col-6 pl-0">
                                <div class="input-group">
                                	<cfsavecontent variable="message"><cf_get_lang dictionary_id='30122.Başlangıç Tarihini Kontrol Ediniz'></cfsavecontent>
                                    <cfinput type="text" name="date1" value="#dateformat(attributes.date1, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#" placeholder="Başlangıç Tarihi">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="date1"></span>
                                </div>
                            </div>
                            <div class="col col-6 pr-0">  
                                <div class="input-group">
                                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='30123.Bitiş Tarihini Kontrol Ediniz'></cfsavecontent>
                                <cfinput type="text" name="date2" value="#dateformat(attributes.date2, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#" placeholder="Bitiş Tarihi">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="date2"></span>
                                </div>
                            </div>
                        </div>
                	</div>
               	</div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="3" sort="true">
                	
               	</div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="4" sort="true">
                	
               	</div>
         	</cf_box_search_detail> 
        </cfform>
    </cf_box>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id="1390.Revizyon Takip"></cfsavecontent>
    <cf_box title="#message#" uidrop="1" hide_table_column="1" woc_setting = "#{ checkbox_name : 'print_invoice_id', print_type : 10 }#">
    	<cf_grid_list sort="1">
        	<thead>
                <tr>
                    <th style="width:25px"><cf_get_lang_main no='1165.Sıra'></th>
                    <cfif attributes.list_type eq 1>
                        <th style="width:90px">Rev.İstem Tarihi</th>
                        <th style="width:90px">Revizyon Onay</th>
                        <th style="width:150px">Takip Eden</th>
                        <th style="width:65px">Takip Tarihi</th>
                    </cfif>
                    <th style="width:80px">Sanal Teklif No</th>
                    <th style="width:100px">Sanal Teklif Tarihi</th>
                    <th>Müşteri</th>
                    <th>Ürün Cinsi</th>
                    <th style="width:90px">Miktar</th>
                    <th style="width:30px">Birim</th>
                    <th style="width:70px">Teklif No</th>
                    <th style="width:70px">Miktar</th>
                    <th style="width:70px">Tasarım No</th>
                    <th style="width:70px">Spect</th>
                    <th style="width:70px">Sipariş No</th>
                    <th style="width:70px">Miktar</th>
                    <th style="width:70px">Plan No</th> 
                    <th style="width:70px">Miktar</th>
                    <th style="width:60px">Lot No</th>
                </tr>
            </thead>
            <tbody>
                <cfif get_revision_tracing.recordcount>
                    <cfoutput query="get_revision_tracing" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                        <cfquery name="get_orders_info" dbtype="query">
                            SELECT 
                                ORDER_NUMBER, 
                                ORDER_ID, 
                                OR_QUANTITY,
                                ORDER_ROW_ID
                            FROM    
                                get_revision_tracing_detail
                            WHERE 
                                EZGI_ID = <cfqueryparam value="#get_revision_tracing.EZGI_ID#" cfsqltype="cf_sql_integer">
                         </cfquery>
                         <cfquery name="get_orders_group" dbtype="query">
                            SELECT 
                                ORDER_NUMBER, 
                                ORDER_ID, 
                                OR_QUANTITY,
                                ORDER_ROW_ID
                            FROM    
                                get_orders_info
                            GROUP BY
                                ORDER_NUMBER, 
                                ORDER_ID, 
                                OR_QUANTITY,
                                ORDER_ROW_ID
                         </cfquery>
                        <tr> 
                            <td rowspan="#get_orders_info.recordcount#" style="text-align:right;">#CURRENTROW#</td>
                            <cfif attributes.list_type eq 1>
                                <td rowspan="#get_orders_info.recordcount#" style="text-align:center;" nowrap="nowrap">#Dateformat(UPDATE_DATE,dateformat_style)#</td>
                                <td rowspan="#get_orders_info.recordcount#" style="text-align:center;" nowrap="nowrap">
                                	<cfif IS_REVISION eq 1>
										<cfif not len(IS_CONFIRM)>
                                        	<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_revision_tracing&history_id=#VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID#','wide');">
                                            	İşlem Yap
                                            </a>
                                        <cfelseif IS_CONFIRM eq 2>
                                            <span style="color:red; font-weight:bold">Red</span>
                                        <cfelseif IS_CONFIRM eq 1>
                                            <span style="color:green; font-weight:bold">Onay</span>
                                        </cfif> 
                                    </cfif>
                                </td>
                                <td rowspan="#get_orders_info.recordcount#" style="text-align:center;" nowrap="nowrap">#get_emp_info(CONFIRM_EMP,0,0)# </td>
                                <td rowspan="#get_orders_info.recordcount#" style="text-align:center;" nowrap="nowrap">#Dateformat(CONFIRM_DATE,dateformat_style)#</td>
                            </cfif>
                            <td rowspan="#get_orders_info.recordcount#" style="text-align:center;" nowrap="nowrap">
                            	<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.upd_ezgi_virtual_offer&virtual_offer_id=#VIRTUAL_OFFER_ID#','longpage');">
                            		#VIRTUAL_OFFER_NUMBER#
                              	</a>
                           	</td>
                            <td rowspan="#get_orders_info.recordcount#" style="text-align:center;" nowrap="nowrap">#DateFormat(VIRTUAL_OFFER_DATE,dateformat_style)#</td>
                            <td rowspan="#get_orders_info.recordcount#" style="text-align:LEFT;">#UNVAN#</td>
                            <td rowspan="#get_orders_info.recordcount#" style="text-align:LEFT;" >#Left(NAME_PRODUCT,150)#<cfif len(NAME_PRODUCT) gt 150>...</cfif></td>
                            <td rowspan="#get_orders_info.recordcount#" style="text-align:right;">#AmountFormat(QUANTITY,2)#</td>
                            <td rowspan="#get_orders_info.recordcount#" >#UNIT#</td>
                            <td rowspan="#get_orders_info.recordcount#" style="text-align:center;" nowrap="nowrap">
                            	<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=sales.list_offer&event=upd&offer_id=#OFFER_ID#','longpage');" style="text-align:center">
                            		#OFFER_NUMBER#
                              	</a>
                            </td>
                            <td rowspan="#get_orders_info.recordcount#" style="text-align:right;">#AmountFormat(OF_QUANTITY,2)#</td>
                            <td rowspan="#get_orders_info.recordcount#" style="text-align:center;" nowrap="nowrap">
                            	<cfif DESIGN_ID gt 0>
                                    <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd&piece_type_select=&sort_id=5&design_id=#DESIGN_ID#&design_main_row_id=#DESIGN_MAIN_ROW_ID#','longpage');" style="text-align:center">
                                        #DESIGN_ID#
                                    </a>
                                </cfif>
                            </td>
                            <td rowspan="#get_orders_info.recordcount#" style="text-align:center;" nowrap="nowrap">
                            	<cfif IS_TREE eq 0>
                                	#SPECT_MAIN_ID#
                                </cfif>
                            </td>
                            <cfloop query="get_orders_group">
                                <cfif get_orders_group.currentrow gt 1><tr></cfif>  
                                    <cfquery name="get_p_orders_info" dbtype="query">
                                        SELECT 
                                            MASTER_PLAN_NAME, 
                                            MASTER_PLAN_NUMBER, 
                                            P_ORDER_ID, 
                                            MASTER_PLAN_ID, 
                                            IS_STAGE, 
                                            PO_QUANTITY,
                                            LOT_NO
                                        FROM    
                                            get_revision_tracing_detail
                                        WHERE 
                                            ORDER_ROW_ID = <cfqueryparam value="#get_orders_group.ORDER_ROW_ID#" cfsqltype="cf_sql_integer"> AND
                                            EZGI_ID = <cfqueryparam value="#get_revision_tracing.EZGI_ID#" cfsqltype="cf_sql_integer">
                                    </cfquery> 
                                    <td rowspan="#get_p_orders_info.recordcount#" style="text-align:center;" nowrap="nowrap">
                                        <cfif len(get_orders_group.ORDER_NUMBER)>
                                            <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=sales.list_order&event=upd&order_id=#get_orders_group.ORDER_ID#','longpage');" style="text-align:center">
                                                #get_orders_group.ORDER_NUMBER#
                                            </a>
                                        </cfif>
                                    </td>
                                    <td rowspan="#get_p_orders_info.recordcount#" style="text-align:right;">#AmountFormat(get_orders_info.OR_QUANTITY,2)#</td>
                                    <cfloop query="get_p_orders_info">
                                        <cfif get_p_orders_info.currentrow gt 1><tr></cfif>
                                        <td style="text-align:center;" nowrap="nowrap" title="#get_p_orders_info.MASTER_PLAN_NAME#">
                                            <cfif len(get_p_orders_info.MASTER_PLAN_NUMBER)>
                                                <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.list_ezgi_iflow_master_plan&event=upd&master_plan_id=#get_p_orders_info.MASTER_PLAN_ID#','longpage');">
                                                    #get_p_orders_info.MASTER_PLAN_NUMBER#
                                                </a>
                                            </cfif>
                                        </td>
                                        <td style="text-align:right;">#AmountFormat(get_p_orders_info.PO_QUANTITY,2)#</td>
                                        <td style="text-align:center; font-weight:bold; color:<cfif get_p_orders_info.IS_STAGE eq 0 or get_p_orders_info.IS_STAGE eq 4>orange<cfelseif get_p_orders_info.IS_STAGE eq 1>green<cfelse>red</cfif>">
                                            <cfif len(get_p_orders_info.LOT_NO)>
                                                <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_list_ezgi_iflow_production_operations&is_form_submitted=1&keyword=#get_p_orders_info.LOT_NO#','longpage');" >
                                                    #get_p_orders_info.LOT_NO#
                                                </a>
                                            </cfif>
                                        </td>
                                    </tr>
                                </cfloop>
                            </cfloop>
                    </cfoutput>
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
            <cfif len(attributes.sort_type)>
                <cfset adres = '#adres#&sort_type=#attributes.sort_type#'>
            </cfif>
            <cfif len(attributes.list_type)>
                <cfset adres = '#adres#&list_type=#attributes.list_type#'>
            </cfif>
            <cfif isdefined('attributes.is_confirm')>
                <cfset adres = '#adres#&is_confirm=#attributes.is_confirm#'>
            </cfif>
            <cfif isdefined('attributes.update_date')>
                <cfset adres = '#adres#&update_date=#attributes.update_date#'>
            </cfif>
            <cfif isdefined('attributes.date1')>
                <cfset adres = '#adres#&date1=#attributes.date1#'>
            </cfif>
            <cfif isdefined('attributes.date2')>
                <cfset adres = '#adres#&date2=#attributes.date2#'>
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

<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;
	}
</script>
