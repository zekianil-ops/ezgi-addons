<table width="98%" border="0" cellspacing="0" cellpadding="0" height="35" align="center">
    <tr>
        <td class="headbold">Muhasebe Dönem Sonu işlemleri</td>
    </tr>
</table>
<table width="98%" border="0" align="center" cellpadding="2" cellspacing="1" class="color-border">
     <tr class="color-row">
        <td>
        	<table>
            	<tr class="txtbold" height="20"> 
                  <td colspan="2">&nbsp;&nbsp;Finansal İşlemler</td>
                </tr>
                <cfif not listfindnocase(denied_pages,'cash.form_add_cash_rate_valuation')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right; width:20"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=cash.form_add_cash_rate_valuation</cfoutput>','longpage');">Kasa Kur Değerleme</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'bank.form_add_bank_rate_valuation')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=bank.form_add_bank_rate_valuation</cfoutput>','longpage');">Banka Kur Değerleme</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'ch.form_add_cari_rate_valuation')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=ch.form_add_cari_rate_valuation</cfoutput>','longpage');">Cari Kur Değerleme</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'account.account_card_rate_valuation')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=account.account_card_rate_valuation</cfoutput>','longpage');">Muhasebe Kur Değerleme</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'report.company_account_code')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=report.company_account_code</cfoutput>','longpage');">Cari - Muhasebe Bakiye Kontrolü </a></td>
					</tr>
                </cfif>
                
                <tr class="txtbold" height="20"> 
                  <td colspan="2">&nbsp;&nbsp;Stok İşlemleri</td>
                </tr>
                <cfif not listfindnocase(denied_pages,'settings.add_new_cost')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=settings.add_new_cost</cfoutput>','longpage');">Yeniden Maliyetlendirme (Belgelerden)</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'account.list_ezgi_cost_of_manufactured_product')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=account.list_ezgi_cost_of_manufactured_product</cfoutput>','longpage');">Üretilen Malın Maliyeti</a></td>
					</tr>
                </cfif>
                
                <cfif not listfindnocase(denied_pages,'account.list_ezgi_cost_of_product_sold')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=account.list_ezgi_cost_of_product_sold</cfoutput>','longpage');">Satılan Malın Maliyeti</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'report.stock_analyse')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=report.stock_analyse</cfoutput>','longpage');">Stok Analiz</a></td>
					</tr>
                </cfif>
                
                <tr class="txtbold" height="20"> 
                  <td colspan="2">&nbsp;&nbsp;Muhasebe Yansıtma İşlemleri</td>
                </tr>
                <cfif not listfindnocase(denied_pages,'account.product_cost_rate_paper')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=account.product_cost_rate_paper</cfoutput>','longpage');">Üretim ve İşçilik Maliyetleri Yansitma</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'account.production_result_account_card')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=account.production_result_account_card</cfoutput>','longpage');">Üretim Sonuçları Muhasebeleştirme</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'account.product_cost_account_card')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=account.product_cost_account_card</cfoutput>','longpage');">Satılan Malın Maliyeti Muhasebeleştirme</a></td>
					</tr>
                </cfif>
            	<cfif not listfindnocase(denied_pages,'account.product_ezgi_iade_cost_account_card')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=account.product_ezgi_iade_cost_account_card</cfoutput>','longpage');">İade Alınan Malın Maliyeti Muhasebeleştirme</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'fintab.list_scale')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=account.list_scale</cfoutput>','longpage');">Genel Mizan</a></td>
					</tr>
                </cfif>
                <tr class="txtbold" height="20"> 
                  <td colspan="2">&nbsp;&nbsp;Sonuç Yansıtma İşlemleri</td>
                </tr>
                <cfif not listfindnocase(denied_pages,'account.account_ezgi_gider_hesaplari_yansitma')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=account.account_ezgi_gider_hesaplari_yansitma</cfoutput>','longpage');">Gider Hesapları Yansıtma</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'account.yansitma_hesaplari_kapama')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=account.yansitma_hesaplari_kapama</cfoutput>','longpage');">Yansıtma Hesapları Kapatma</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'fintab.list_income_table&requesttimeout=500')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=account.list_income_table&requesttimeout=500</cfoutput>','longpage');">Gelir Tablosu Dökümü</a></td>
					</tr>
                </cfif>
				<cfif not listfindnocase(denied_pages,'account.kar_zarar_yansitmasi')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=account.kar_zarar_yansitmasi</cfoutput>','longpage');">Kar Zarar Yansıtması</a></td>
					</tr>
                </cfif>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td>Vergi Karşılıklarının Ayrılması</td>
					</tr>
                    <tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td>Ödenen Peşin Vergi Mahsubu</td>
					</tr>
              		<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td>Net Kar Zarar Mahsubu</td>
					</tr>
                    <tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td>Net Kar Zarar Devri</td>
					</tr>
               	<cfif not listfindnocase(denied_pages,'fintab.list_balance_sheet&requesttimeout=500')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=account.list_balance_sheet&requesttimeout=500</cfoutput>','longpage');">Bilanço Dökümü</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'account.stock_doviz_duzenle')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=account.stock_doviz_duzenle</cfoutput>','longpage');">Stok Döviz Düzenleme İşlemi</a></td>
					</tr>
                </cfif>
                
              	<cfif not listfindnocase(denied_pages,'settings.form_add_acc_close_card')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=settings.form_add_acc_close_card</cfoutput>','longpage');">Muhasebe Dönem Kapanış Fişi</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'settings.form_muhasebe_devir')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=settings.form_muhasebe_devir</cfoutput>','longpage');">Muhasebe Dönem Açılış Fişi</a></td>
					</tr>
                </cfif>
               	<tr class="txtbold" height="20"> 
                  <td colspan="2">&nbsp;&nbsp;E-Defter İşlemleri</td>
                </tr>
                <cfif not listfindnocase(denied_pages,'account.form_concentrate_bill_no')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a target="_blank" href="<cfoutput>#request.self#</cfoutput>?fuseaction=account.form_concentrate_bill_no" class="tableyazi">Fiş No Düzenleme</a></td>
					</tr>
                </cfif>
                <cfif not listfindnocase(denied_pages,'account.list_ezgi_e_defter')>
					<tr>
                    	<td width="20" align="right" valign="baseline" style="text-align:right;"><img src="/images/tree_1.gif"></td>
						<td><a target="_blank" href="<cfoutput>#request.self#</cfoutput>?fuseaction=account.list_ezgi_e_defter" class="tableyazi">E-Defter</a></td>
					</tr>
                </cfif>
            </table>
        </td>
    </tr>
</table>

