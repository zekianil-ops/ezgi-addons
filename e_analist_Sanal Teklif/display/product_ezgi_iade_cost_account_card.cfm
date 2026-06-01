<cfsetting showdebugoutput="no">
<cfparam name="attributes.process_type" default="">
<cfparam name="attributes.startdate" default="#dateformat(now(),dateformat_style)#">
<cfparam name="attributes.finishdate" default="#dateformat(now(),dateformat_style)#">
<cf_date tarih='attributes.finishdate'>
<cf_date tarih='attributes.startdate'>
<cfquery name="get_process_cat" datasource="#dsn3#">
	SELECT PROCESS_CAT,PROCESS_CAT_ID FROM SETUP_PROCESS_CAT WHERE PROCESS_TYPE IN(55) AND IS_PROD_COST_ACC_ACTION = 0 ORDER BY PROCESS_CAT
</cfquery>
<cfif isdefined('attributes.is_form_submitted') and attributes.is_form_submitted eq 1>
	<cfquery name="get_all_invoice_amount" datasource="#dsn3#">
		SELECT
			'#session.ep.money#' OTHER_MONEY,
			IR.PRODUCT_ID,
			ISNULL(SUM((IR.COST_PRICE+IR.EXTRA_COST)*AMOUNT),0) COST_PRICE,
			S.PRODUCT_NAME
		FROM
			#dsn2_alias#.INVOICE_ROW IR,
			#dsn3_alias#.STOCKS S,
			#dsn2_alias#.INVOICE I
			left JOIN #dsn2_alias#.INVOICE_SHIPS ISS ON ISS.INVOICE_ID = I.INVOICE_ID 
			JOIN #dsn2_alias#.SHIP SR ON SR.SHIP_ID = ISS.SHIP_ID
		WHERE
			I.IS_IPTAL = 0 AND
            I.PURCHASE_SALES = 0 AND
			I.INVOICE_CAT IN(55) AND
			I.INVOICE_ID = IR.INVOICE_ID AND
			IR.STOCK_ID = S.STOCK_ID AND
		<!---	I.INVOICE_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#"> AND
			I.INVOICE_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#">--->
			ISNULL(ISNULL(SR.DELIVER_DATE,SR.SHIP_DATE),INVOICE_DATE) >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#"> AND
			ISNULL(ISNULL(SR.DELIVER_DATE,SR.SHIP_DATE),INVOICE_DATE) <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#">
			<cfif len(attributes.process_type)>
				AND I.PROCESS_CAT IN(#attributes.process_type#)
			</cfif>
		GROUP BY
			IR.PRODUCT_ID,
			S.PRODUCT_NAME
	</cfquery>
	<cfif get_all_invoice_amount.recordcount>
		<cfset muhasebe_uyari = ''>
		<cfset muhasebe_uyari_2 = "">
		<cflock name="#CreateUUID()#" timeout="60">
			<cftransaction>				
				<!--- Satılan malın maliyeti ile ilgili, olup (176), gonderilen tarihte daha onceki kayitlar yeniden olusacagi icin temizleniyor --->
				<cfquery name="Get_Account_Control" datasource="#dsn3#">
					SELECT
						CARD_ID
					FROM
						#dsn2_alias#.ACCOUNT_CARD
					WHERE
						ACTION_ID = 0 AND
						ACTION_TYPE = 176 AND
						ACTION_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finishdate#">
				</cfquery>
				<cfif Get_Account_Control.RecordCount>
					<cfquery name="Del_Account_Card_Rows" datasource="#dsn3#">
						DELETE FROM #dsn2_alias#.ACCOUNT_CARD_ROWS WHERE CARD_ID IN (#ValueList(Get_Account_Control.Card_Id)#)
					</cfquery>
					<cfquery name="Del_Account_Cards" datasource="#dsn3#">
						DELETE FROM #dsn2_alias#.ACCOUNT_CARD WHERE CARD_ID IN (#ValueList(Get_Account_Control.Card_Id)#)
					</cfquery>
				</cfif>
				<!--- Satılan malın maliyeti muhasebe kaydı oluşturulacak. Ürünlerin alış hesabına alacak, satılan malın maliyet hesabına borç yazacak --->
				<cfscript>
					Date_Detail = "#DateFormat(attributes.startdate,dateformat_style)# - #DateFormat(attributes.finishdate,dateformat_style)#";
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
					//üretilen ürün
					for(i=1;i lte get_all_invoice_amount.recordcount; i=i+1) 
					{	
						account_codes =  cfquery(datasource:'#dsn3#',sqlstring:'SELECT ACCOUNT_CODE_PUR,SALE_PRODUCT_COST,PRODUCTION_COST FROM PRODUCT_PERIOD WHERE PRODUCT_ID = #get_all_invoice_amount.PRODUCT_ID[i]# AND PERIOD_ID = #session.ep.period_id#');
						str_borclu_hesaplar = ListAppend(str_borclu_hesaplar, account_codes.SALE_PRODUCT_COST, ",");	
						str_borc_tutar = ListAppend(str_borc_tutar, wrk_round(get_all_invoice_amount.COST_PRICE[i]),",");
						str_borc_dovizli = ListAppend(str_borc_dovizli, wrk_round(get_all_invoice_amount.COST_PRICE[i]),",");
						str_other_currency_borc = ListAppend(str_other_currency_borc,get_all_invoice_amount.OTHER_MONEY[i],",");//get_all_invoice_amount.OTHER_MONEY[i]
																		
						str_alacakli_hesaplar = ListAppend(str_alacakli_hesaplar, account_codes.ACCOUNT_CODE_PUR, ",");	
						str_alacak_tutar = ListAppend(str_alacak_tutar, wrk_round(get_all_invoice_amount.COST_PRICE[i]),",");
						str_alacak_dovizli = ListAppend(str_alacak_dovizli, wrk_round(get_all_invoice_amount.COST_PRICE[i]),",");
						str_other_currency_alacak = ListAppend(str_other_currency_alacak,get_all_invoice_amount.OTHER_MONEY[i],",");
						
						if(not len(account_codes.SALE_PRODUCT_COST))
							muhasebe_uyari = "#muhasebe_uyari#;#get_all_invoice_amount.PRODUCT_NAME[i]# Ürünü İçin Satılan Malın Maliyeti Hesabı Eksik.";
						if(not len(account_codes.ACCOUNT_CODE_PUR))
							muhasebe_uyari = "#muhasebe_uyari#;#get_all_invoice_amount.PRODUCT_NAME[i]# Ürünü İçin Alış Hesabı Eksik.";
					}
					//1-9 kurus icin yuvarlama islemi yapılıyor
					temp_total_alacak = evaluate(ListChangeDelims(str_alacak_tutar,'+',','));
					temp_total_borc = evaluate(ListChangeDelims(str_borc_tutar,'+',','));
					temp_fark = round((temp_total_alacak-temp_total_borc)*100);
					if( temp_fark gte -9 and temp_fark lt 0 )
					{
						fark_account = cfquery(datasource:"#dsn3#",sqlstring:"SELECT FARK_GELIR FROM SETUP_INVOICE");
						str_alacakli_hesaplar = ListAppend(str_alacakli_hesaplar, fark_account.FARK_GELIR, ",");
						str_alacak_tutar = ListAppend(str_alacak_tutar, abs(temp_fark/100), ",");
						str_alacak_dovizli = ListAppend(str_alacak_dovizli, abs(temp_fark/100),",");
						str_other_currency_alacak = ListAppend(str_other_currency_alacak,session.ep.money,",");
					}
					else if( temp_fark lte 9 and temp_fark gt 0 )
					{
						fark_account = cfquery(datasource:"#dsn3#",sqlstring:"SELECT FARK_GIDER FROM SETUP_INVOICE");
						str_borclu_hesaplar = ListAppend(str_borclu_hesaplar, fark_account.FARK_GIDER, ",");
						str_borc_tutar = ListAppend(str_borc_tutar, abs(temp_fark/100), ",");
						str_borc_dovizli = ListAppend(str_borc_dovizli, abs(temp_fark/100),",");
						str_other_currency_borc = ListAppend(str_other_currency_borc,session.ep.money,",");
					}	 
				 	if(len(muhasebe_uyari))
					{
						for(kk=1;kk<=listlen(muhasebe_uyari,';');kk=kk+1)
						{
							muhasebe_uyari_2 =  "#muhasebe_uyari_2# #listgetat(muhasebe_uyari,kk,';')#\n";
							
						}
					} 
					if(not len(muhasebe_uyari))
					{
						muhasebeci
						(
							action_id : 0,
							workcube_process_type : 176,
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
							fis_detay : '#Date_Detail# İADE ALINAN MALIN MALİYETİ',
							fis_satir_detay : '#Date_Detail# İADE ALINAN MALIN MALİYETİ',
							is_account_group : 1
						); 
					}  
				</cfscript>			
				<cfif len(muhasebe_uyari_2)>
					<cfoutput>	
						<script>						
							alert('#muhasebe_uyari_2# \n Yukarıdaki Ürünler İçin Düzenleme Yapmalısınız !');
							history.back();
						</script>	
					</cfoutput>
					<cfabort>
				</cfif>
			</cftransaction>
		</cflock>
		<cfquery name="get_cards" datasource="#dsn2#">
			SELECT BILL_NO,ACTION_DATE FROM ACCOUNT_CARD WHERE ACTION_ID = 0 AND ACTION_TYPE = 53 AND RECORD_EMP = #session.ep.userid# AND ACTION_DATE = #attributes.finishdate#
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
				alert('Seçilen Tarih Aralığındaki Faturaların Muhasebe Fişleri Oluşturuldu !\n Fiş Numaraları : \n #warning_txt#');
			</script>	
		</cfoutput>
	<cfelse>
		<script>
			alert("Seçilen Tarih Aralığındaki Fatura Bulunamadı !");
		</script>	
	</cfif>
</cfif>
<!---<cfset pageHead ="#getLang('account',285)#">
<cf_catalystHeader>--->
<span style="font-size:16px; color:mediumturquoise; font-weight:bold">İADE ADINAN MALIN MALİYETİ MUHASEBELEŞTİRME</span><br />
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
