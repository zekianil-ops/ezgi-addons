<cfsetting showdebugoutput="yes">
<cfparam name="attributes.finishdate" default="#dateformat(now(),'dd/mm/yyyy')#">
<cfparam name="attributes.branch_id" default="">
<cf_date tarih='attributes.finishdate'>
<cfif isdefined('attributes.is_form_submitted') and attributes.is_form_submitted eq 1>
	<cfquery name="get_all_account" datasource="#dsn2#">
    	SELECT     	ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.BORC - ACCOUNT_ACCOUNT_REMAINDER.ALACAK), 2) AS BAKIYE, 
                   	ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.BORC), 2) AS BORC, 
                    ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.ALACAK), 2) AS ALACAK, 
                    
                    ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.OTHER_AMOUNT_BORC - ACCOUNT_ACCOUNT_REMAINDER.OTHER_AMOUNT_ALACAK), 2) AS OTHER_BAKIYE, 
                    ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.OTHER_AMOUNT_BORC), 2) AS OTHER_BORC, 
                    ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.OTHER_AMOUNT_ALACAK), 2) AS OTHER_ALACAK, 
                    ACCOUNT_ACCOUNT_REMAINDER.OTHER_CURRENCY, 
                    ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.AMOUNT2_BORC - ACCOUNT_ACCOUNT_REMAINDER.AMOUNT2_ALACAK), 2) AS BAKIYE_2, 
                    ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.AMOUNT2_BORC), 2) AS BORC_2, 
                    ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.AMOUNT2_ALACAK), 2)AS ALACAK_2, 
                     
                  	ACCOUNT_PLAN.ACCOUNT_CODE, 
                    ACCOUNT_PLAN.ACCOUNT_NAME, 
                    ACCOUNT_PLAN.ACCOUNT_ID
		FROM     	(
        			SELECT   	0 AS ALACAK, 
                        		SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT, 2)) AS BORC,
                                0 AS OTHER_AMOUNT_ALACAK, 
                      			SUM(ISNULL(ACCOUNT_CARD_ROWS.OTHER_AMOUNT, 0)) AS OTHER_AMOUNT_BORC, 
                                ISNULL(ACCOUNT_CARD_ROWS.OTHER_CURRENCY, 'TL') AS OTHER_CURRENCY,
                                0 AS AMOUNT2_ALACAK, 
                                SUM(ISNULL(ACCOUNT_CARD_ROWS.AMOUNT_2, 0)) AS AMOUNT2_BORC, 
                        		ACCOUNT_CARD_ROWS.ACCOUNT_ID
                   	FROM       	ACCOUNT_CARD_ROWS INNER JOIN
                               	ACCOUNT_CARD ON ACCOUNT_CARD_ROWS.CARD_ID = ACCOUNT_CARD.CARD_ID
                   	WHERE      	(ACCOUNT_CARD_ROWS.BA = 0) AND 
                    			(ACCOUNT_CARD_ROWS.ACCOUNT_ID >= '740') AND 
                                (ACCOUNT_CARD.ACTION_DATE BETWEEN CONVERT(DATETIME, '2008-01-01 00:00:00', 102) AND <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#">) AND 
                              	(ACCOUNT_CARD_ROWS.ACC_BRANCH_ID IN (#attributes.branch_id#))
                 	GROUP BY 	ACCOUNT_CARD_ROWS.ACCOUNT_ID, ACCOUNT_CARD_ROWS.OTHER_CURRENCY
                   	HAVING    	(SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT, 2)) <> 0)
                  	UNION ALL
                  	SELECT     	SUM(ROUND(ACCOUNT_CARD_ROWS_1.AMOUNT, 2)) AS ALACAK, 
                       			0 AS BORC,
                                SUM(ISNULL(ACCOUNT_CARD_ROWS_1.OTHER_AMOUNT, 0))AS OTHER_AMOUNT_ALACAK, 
                                0 AS OTHER_AMOUNT_BORC,
                                ISNULL(ACCOUNT_CARD_ROWS_1.OTHER_CURRENCY, 'TL') AS OTHER_CURRENCY,
                                SUM(ISNULL(ACCOUNT_CARD_ROWS_1.AMOUNT_2, 0)) AS AMOUNT2_ALACAK, 
                                0 AS AMOUNT2_BORC, 
                                ACCOUNT_CARD_ROWS_1.ACCOUNT_ID
                  	FROM       	ACCOUNT_CARD_ROWS AS ACCOUNT_CARD_ROWS_1 INNER JOIN
                                ACCOUNT_CARD AS ACCOUNT_CARD_1 ON ACCOUNT_CARD_ROWS_1.CARD_ID = ACCOUNT_CARD_1.CARD_ID
                 	WHERE     	(ACCOUNT_CARD_ROWS_1.BA = 1) AND 
                    			(ACCOUNT_CARD_ROWS_1.ACCOUNT_ID >= '740') AND 
                                (ACCOUNT_CARD_1.ACTION_DATE BETWEEN CONVERT(DATETIME, '2008-01-01 00:00:00', 102) AND <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#">) AND 
                              	(ACCOUNT_CARD_ROWS_1.ACC_BRANCH_ID IN (#attributes.branch_id#)) 
                  	GROUP BY 	ACCOUNT_CARD_ROWS_1.ACCOUNT_ID, ACCOUNT_CARD_ROWS_1.OTHER_CURRENCY
                   	HAVING    	(SUM(ROUND(ACCOUNT_CARD_ROWS_1.AMOUNT, 2)) <> 0)
                    ) AS ACCOUNT_ACCOUNT_REMAINDER INNER JOIN
                   	ACCOUNT_PLAN ON LEFT(ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID, 3) = ACCOUNT_PLAN.ACCOUNT_CODE
		WHERE   	(1 = 1) AND 
        			(ACCOUNT_PLAN.ACCOUNT_CODE >= '740')
		GROUP BY 	ACCOUNT_PLAN.ACCOUNT_CODE, 
        			ACCOUNT_PLAN.ACCOUNT_NAME, 
                    ACCOUNT_PLAN.ACCOUNT_ID,
                    ACCOUNT_ACCOUNT_REMAINDER.OTHER_CURRENCY
		ORDER BY 	ACCOUNT_PLAN.ACCOUNT_CODE
    </cfquery>
    <cfquery name="get_account" dbtype="query">
        SELECT		'751' AS A_ACCOUNT_CODE,
        			'630' AS B_ACCOUNT_CODE,	 
                    BAKIYE,
                    OTHER_BAKIYE,
                    BAKIYE_2,
                    OTHER_CURRENCY AS OTHER_MONEY
      	FROM		get_all_account
        WHERE		ACCOUNT_CODE = '750'
        UNION ALL
        SELECT		'761' AS A_ACCOUNT_CODE,
        			'631' AS B_ACCOUNT_CODE,	 
                    BAKIYE,
                    OTHER_BAKIYE,
                    BAKIYE_2,
                    OTHER_CURRENCY AS OTHER_MONEY
      	FROM		get_all_account
        WHERE		ACCOUNT_CODE = '760'
        UNION ALL
        SELECT		'771' AS A_ACCOUNT_CODE,
        			'632' AS B_ACCOUNT_CODE,	 
                    BAKIYE,
                    OTHER_BAKIYE,
                    BAKIYE_2,
                    OTHER_CURRENCY AS OTHER_MONEY
      	FROM		get_all_account
        WHERE		ACCOUNT_CODE = '770'
        UNION ALL
        SELECT		'781' AS A_ACCOUNT_CODE,
        			'660' AS B_ACCOUNT_CODE,	 
                    BAKIYE,
                    OTHER_BAKIYE,
                    BAKIYE_2,
                    OTHER_CURRENCY AS OTHER_MONEY
      	FROM		get_all_account
        WHERE		ACCOUNT_CODE = '780'
    </cfquery>
  	<cfif get_account.recordcount>
		<cfset muhasebe_uyari = ''>
		<cflock name="#CreateUUID()#" timeout="60">
			<cftransaction>
            	<cfquery name="Get_Account_Control" datasource="#dsn3#">
					SELECT 
                    	DISTINCT    
                    	AC.CARD_ID
					FROM         
                    	#dsn2_alias#.ACCOUNT_CARD AS AC INNER JOIN
                      	#dsn2_alias#.ACCOUNT_CARD_ROWS AS ACR ON AC.CARD_ID = ACR.CARD_ID
                  	WHERE     
                    	AC.ACTION_ID = 0 AND 
                        AC.ACTION_TYPE = 173 AND
                        <cfif isDefined("attributes.branch_id") and len(attributes.branch_id)>
                        	ACR.ACC_BRANCH_ID = #attributes.branch_id# AND
                        </cfif> 
						AC.ACTION_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#">
                        
				</cfquery>
				<cfif Get_Account_Control.RecordCount>
					<cfquery name="Del_Account_Card_Rows" datasource="#dsn3#">
						DELETE FROM #dsn2_alias#.ACCOUNT_CARD_ROWS WHERE CARD_ID IN (#ValueList(Get_Account_Control.Card_Id)#)
					</cfquery>
					<cfquery name="Del_Account_Cards" datasource="#dsn3#">
						DELETE FROM #dsn2_alias#.ACCOUNT_CARD WHERE CARD_ID IN (#ValueList(Get_Account_Control.Card_Id)#)
					</cfquery>
				</cfif>			
				<cfscript>
					Date_Detail = "#DateFormat(attributes.finishdate,'dd/mm/yyyy')#";
					str_borclu_hesaplar = '' ;
					str_alacakli_hesaplar = '' ;
					str_borc_tutar = '' ;
					str_alacak_tutar = '' ;
					str_alacak_dovizli = '' ;
					str_borc_dovizli = '' ;
					str_other_currency_borc = '' ;
					str_other_currency_alacak = '';
					temp_cost_price_system_exit = 0;
					temp_cost_price_exit = 0;
					for(i=1;i lte get_account.recordcount; i=i+1) 
					{	
						str_borclu_hesaplar = ListAppend(str_borclu_hesaplar, get_account.B_ACCOUNT_CODE[i], ",");	
						str_borc_tutar = ListAppend(str_borc_tutar, wrk_round(get_account.BAKIYE[i]),",");
						str_borc_dovizli = ListAppend(str_borc_dovizli, wrk_round(get_account.OTHER_BAKIYE[i]),",");
						str_other_currency_borc = ListAppend(str_other_currency_borc,get_account.OTHER_MONEY[i],",");//get_all_invoice_amount.OTHER_MONEY[i]
																		
						str_alacakli_hesaplar = ListAppend(str_alacakli_hesaplar, get_account.A_ACCOUNT_CODE[i], ",");	
						str_alacak_tutar = ListAppend(str_alacak_tutar, wrk_round(get_account.BAKIYE[i]),",");
						str_alacak_dovizli = ListAppend(str_alacak_dovizli, wrk_round(get_account.OTHER_BAKIYE[i]),",");
						str_other_currency_alacak = ListAppend(str_other_currency_alacak,get_account.OTHER_MONEY[i],",");
					}
					temp_total_alacak = evaluate(ListChangeDelims(str_alacak_tutar,'+',','));
					temp_total_borc = evaluate(ListChangeDelims(str_borc_tutar,'+',','));
					muhasebeci
					(
						action_id : 0,
						workcube_process_type : 173,
						workcube_process_cat : 0,
						muhasebe_db : '#dsn3#',
						account_card_type : 13,
						islem_tarihi : attributes.finishdate,
						borc_hesaplar : str_borclu_hesaplar,
						borc_tutarlar : str_borc_tutar,
						other_amount_borc : str_borc_dovizli,
						other_currency_borc : str_other_currency_borc,
						alacak_hesaplar : str_alacakli_hesaplar,
						alacak_tutarlar : str_alacak_tutar,
						other_amount_alacak : str_alacak_dovizli,
						other_currency_alacak :str_other_currency_alacak,
						fis_detay : '#Date_Detail# GİDER HESAPLARI YANSITMA',
						fis_satir_detay : '#Date_Detail# GİDER HESAPLARI YANSITMA',
						is_account_group : 1,
						from_branch_id : iif((isdefined("branch_id") and len(branch_id)), 'branch_id', de('')),
						to_branch_id : iif((isdefined("branch_id") and len(branch_id)), 'branch_id', de(''))
					);
				</cfscript>
			</cftransaction>
		</cflock>
		<cfquery name="get_cards" datasource="#dsn2#">
        	SELECT 
            	DISTINCT    
            	AC.CARD_ID, 
                ACR.ACC_BRANCH_ID, 
                AC.ACTION_DATE, AC.BILL_NO
			FROM         
            	ACCOUNT_CARD AS AC INNER JOIN
                ACCOUNT_CARD_ROWS AS ACR ON AC.CARD_ID = ACR.CARD_ID
			WHERE     
            	AC.ACTION_ID = 0 AND 
                AC.ACTION_TYPE = 173 AND 
                ACR.ACC_BRANCH_ID = #attributes.branch_id# AND 
                AC.RECORD_EMP = #session.ep.userid# AND 
                AC.ACTION_DATE = #attributes.finishdate#
		</cfquery>
		<cfset warning_txt = ''>
		<cfoutput query="get_cards">
			<cfif len(warning_txt)>
				<cfset warning_txt = '#warning_txt#,#get_cards.bill_no#'>
			<cfelse>
				<cfset warning_txt = '#get_cards.bill_no#'>
			</cfif>
		</cfoutput>
		<cfoutput>
			<script>
				alert("Seçilen Tarih Aralığındaki Faturaların Muhasebe Fişleri Oluşturuldu !\n Fiş Numaraları : \n #warning_txt#");
				windowopen('<cfoutput>#request.self#?fuseaction=account.popup_list_card_rows&card_id=#get_cards.card_id#</cfoutput>','page');
			</script>	
		</cfoutput>
	<cfelse>
		<script>
			alert("Seçilen Tarih Aralığındaki İşlem Bulunamadı !");
		</script>	
	</cfif>
</cfif>    
<span style="font-size:16px; color:mediumturquoise; font-weight:bold">GİDER HESAPLARI YANSITMA</span><br />
<cfform name="report_special" action="" method="post">
	<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
	<div class="row"> 
		<div class="col col-12 uniqueRow">
			<div class="row formContent">
				<div class="row" type="row">
					<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
						<div class="form-group" id="item-process">
							<label class="col col-3 col-xs-12"><cf_get_lang_main no="388.İşlem Tipi"></label>
							<div class="col col-9 col-xs-12"> 
								<select name="process_type" id="process_type" multiple style="width:160px;">
									<cfoutput query="get_process_cat">
										<option value="#process_cat_id#" <cfif listfind(attributes.process_type,process_cat_id)>selected</cfif>>#process_cat#</option>
									</cfoutput>
								</select>
							</div>
						</div>					
					</div>
					<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
						<div class="form-group" id="item-dates">
							<label class="col col-3 col-xs-12"><cf_get_lang_main no="330.Tarih">*</label>
							<div class="col col-9 col-xs-12"> 
								<div class="input-group">
									<cfsavecontent variable="message1"><cf_get_lang_main no='370.Tarih Değerlerini Kontrol Ediniz'> !</cfsavecontent>
									<cfinput type="text" name="startdate" validate="#validate_style#" message="#message1#" value="#dateformat(attributes.startdate,dateformat_style)#" required="yes" style="width:65px;">												
									<span class="input-group-addon"><cf_wrk_date_image date_field="startdate"> </span>
									<span class="input-group-addon no-bg"></span>
									<cfinput type="text" name="finishdate" validate="#validate_style#" message="#message1#" value="#dateformat(attributes.finishdate,dateformat_style)#" required="yes" style="width:65px;">
									<span class="input-group-addon"><cf_wrk_date_image date_field="finishdate"></span>
								</div>
							</div>
						</div>					
					</div>
				</div>	
				<div class="row formContentFooter">	
					<div class="col col-12">
						<cfsavecontent variable="message"><cf_get_lang_main no ='499.Çalıştır'></cfsavecontent>
						<cf_wrk_search_button is_upd='0' is_cancel='0' insert_info='#message#' insert_alert=''>
					</div> 
				</div>
			</div>
		</div>
	</div>
</cfform>


