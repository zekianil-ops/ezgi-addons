		<table cellspacing="0" cellpadding="0"  border="0" width="100%" style="text-align:center">
          	<tr class="color-border"> 
            	<td> 
            		<table cellspacing="1" cellpadding="2" width="100%" border="0">
                    	<cfoutput>
                    	<tr height="30" class="color-header">
							<td style="text-align:center" colspan="2" class="form-title">Açıklama</td>
                            <td style="text-align:center" colspan="#period_col#" class="form-title">Dönemler</td>
                       	</tr>
                    	<tr height="30" class="color-header">
                            <td style="text-align:center;" class="form-title">Rasyo Analiz Tablosu</td>
                            <td style="text-align:center; width:50px" class="form-title">İdeal<br />Oranı</td>
                            <td style="text-align:center" class="form-title">Kapanış/#last_donem#</td>
                            <td width="5">&nbsp;</td>
                            <cfswitch expression="#list_type#" >
                            	<cfcase value="1">
                					<cfloop from="#attributes.date1#" to="#attributes.date2#" index="i">
                                    	<td style="text-align:center" class="form-title">#evaluate('period_header_1_#i#')#</td>
                                        <td style="text-align:center; width:5px">&nbsp;</td>
                                    </cfloop>
                            	</cfcase>
                                <cfcase value="2">
                                    <cfloop from="#attributes.date1#" to="#attributes.date2#" index="i">
                                    	<td style="text-align:center" class="form-title" <cfif DayofYear(evaluate('period_flu_1_#i#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_1_#i#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_1_#i#')#</td>
                                        <td style="text-align:center" class="form-title" <cfif DayofYear(evaluate('period_flu_2_#i#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_2_#i#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_2_#i#')#</td>
                                        <td style="text-align:center" class="form-title" <cfif DayofYear(evaluate('period_flu_3_#i#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_3_#i#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_3_#i#')#</td>
                                        <td style="text-align:center" class="form-title" <cfif DayofYear(evaluate('period_flu_4_#i#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_4_#i#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_4_#i#')#</td>
                                        <td width="5">&nbsp;</td>
                                    </cfloop>
                              	</cfcase>
								<cfcase value="3">
                                	<td style="text-align:center" class="form-title"  <cfif DayofYear(evaluate('period_flu_1_#date1#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_1_#date1#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_1_#date1#')#</td>
                                    <td style="text-align:center" class="form-title"  <cfif DayofYear(evaluate('period_flu_2_#date1#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_2_#date1#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_2_#date1#')#</td>
                                    <td style="text-align:center" class="form-title"  <cfif DayofYear(evaluate('period_flu_3_#date1#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_3_#date1#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_3_#date1#')#</td>
                                    <td style="text-align:center" class="form-title"  <cfif DayofYear(evaluate('period_flu_4_#date1#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_4_#date1#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_4_#date1#')#</td>
                                    <td style="text-align:center" class="form-title"  <cfif DayofYear(evaluate('period_flu_5_#date1#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_5_#date1#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_5_#date1#')#</td>
                                    <td style="text-align:center" class="form-title"  <cfif DayofYear(evaluate('period_flu_6_#date1#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_6_#date1#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_6_#date1#')#</td>
                                    <td style="text-align:center" class="form-title"  <cfif DayofYear(evaluate('period_flu_7_#date1#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_7_#date1#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_7_#date1#')#</td>
                                    <td style="text-align:center" class="form-title"  <cfif DayofYear(evaluate('period_flu_8_#date1#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_8_#date1#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_8_#date1#')#</td>
                                    <td style="text-align:center" class="form-title"  <cfif DayofYear(evaluate('period_flu_9_#date1#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_9_#date1#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_9_#date1#')#</td>
                                    <td style="text-align:center" class="form-title"  <cfif DayofYear(evaluate('period_flu_10_#date1#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_10_#date1#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_10_#date1#')#</td>
                                    <td style="text-align:center" class="form-title"  <cfif DayofYear(evaluate('period_flu_11_#date1#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_11_#date1#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_11_#date1#')#</td>
                                    <td style="text-align:center" class="form-title"  <cfif DayofYear(evaluate('period_flu_12_#date1#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_12_#date1#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_12_#date1#')#</td>
                                    <td width="5">&nbsp;</td>
                                </cfcase>
                            </cfswitch>
                       	</tr>
                        </cfoutput>
                        <cfset t_islem_ = 0>
                        <cfset list_10 = '+100,+101,+102,+103,+108'>
                        <cfset list_11 = '+110,+111,+112,+113,+119'>
                        <cfset list_12 = '+120,+121,+122,+124,+126,+127,+128,+129'>
                        <cfset list_13 = '+131,+132,+133,+134,+136,+137,+138,+139'>
                        <cfset list_15 = '+150,+151,+152,+153,+157,+158,+159'>
                        <cfset list_17 = '+170,+178,+179'>
                        <cfset list_18 = '+180,+181'>
                        <cfset list_19 = '+190,+191,+192,+193,+196,+197,+198,+199'>
                        
						<cfset list_1 = '#list_10#,#list_11#,#list_12#,#list_13#,#list_15#,#list_17#,#list_18#,#list_19#'> <!---Dönen Varlıklar--->
                        <cfset list_st = '+150,+151,+152,+153,+157,+158'> <!---Tüm Stoklar--->
						<cfset list_sa = '+150,+152,+157'>	<!---mamüller--->
                        <cfset list_sb = '+153'> <!---Ticati Mallar--->
                        
                        <cfset list_22 = '+220,+221,+222,+224,+226,+229'>
                        <cfset list_23 = '+231,+232,+233,+235,+236,+237,+239'>
                        <cfset list_24 = '+240,+241,+242,+243,+244,+245,+246,+247,+249'>
                        <cfset list_25 = '+250,+251,+252,+253,+254,+255,+256,+257,+258,+259'>
                        <cfset list_26 = '+260,+261,+262,+263,+264,+267,+268,+269'>
                        <cfset list_27 = '+271,+272,+277,+278,+279'>
                        <cfset list_28 = '+281,+280'>
                        <cfset list_29 = '+291,+292,+293,+294,+295,+297,+298,+299'>
                        
                        <cfset list_2 = '#list_22#,#list_23#,#list_24#,#list_25#,#list_26#,#list_27#,#list_28#,#list_29#'> <!---Duran Varlıklar--->
                        
                        <cfset list_30 = '-300,-301,-302,-303,-304,-305,-306,-308,-309'>
                        <cfset list_32 = '-320,-321,-322,-326,-329'>
                        <cfset list_33 = '-331,-332,-333,-335,-336,-337'>
                        <cfset list_34 = '-340,-349'>
                        <cfset list_35 = '-350,-358'>
                        <cfset list_36 = '-360,-361,-368,-369'>
                        <cfset list_37 = '-370,-371,-372,-373,-379'>
                        <cfset list_38 = '-380,-381'>
						<cfset list_39 = '-391,-392,-393,-397,-399'>
                        
                        <cfset list_3 = '#list_30#,#list_32#,#list_33#,#list_34#,#list_35#,#list_36#,#list_37#,#list_38#,#list_39#'> <!---KV.Ticari Borçlar--->
                        
                        <cfset list_40 = '-400,-401,-402,-405,-407,-408,-409'>
                        <cfset list_42 = '-420,-421,-422,-426,-429'>
                        <cfset list_43 = '-431,-432,-433,-436,-437,-438'>
                        <cfset list_44 = '-440,-449'>
                        <cfset list_47 = '-472,-479'>
                        <cfset list_48 = '-480,-481'>
						<cfset list_49 = '-492,-493,-499'>
                        
                        <cfset list_4 = '#list_40#,#list_42#,#list_43#,#list_44#,#list_47#,#list_48#,#list_49#'><!---UV.Ticari Borçlar--->
                        
                        <cfset list_50 = '-500,-501,-502,-503'>
                        <cfset list_52 = '-520,-521,-522,-523,-524,-529'>
                        <cfset list_54 = '-540,-541,-542,-548,-549'>
                        <cfset list_57 = '-570'>
                        <cfset list_58 = '-580'>
                        <cfset list_59 = '-590,-591'>
                        
                        <cfset list_5 = '#list_50#,#list_52#,#list_54#,#list_57#,#list_58#,#list_59#'> <!---Sermaye--->
                        <cfset list_tb = '#list_32#,#list_33#,#list_34#,#list_42#,#list_43#,#list_44#'> <!---Tüm Ticari Borçlar--->
                        <cfset list_ta = '#list_12#,#list_22#'> <!---Tüm Ticari Alacaklar--->
						<cfset list_a = '#list_1#,#list_2#'> <!---Aktifler--->
                        <cfset list_p = '#list_3#,#list_4#,#list_5#'> <!---pasifler--->
                        
                        <cfset gelr_10 = '-600,-601,-602'>
                        <cfset gelr_11 = '+610,+611,+612'>
                        <cfset gelr_12 = '+620,+621,+622,+623'>
                        <cfset gelr_13 = '+630,+631,+632'>
                        <cfset gelr_14 = '-640,-641,-642,-643,-644,-645,-646,-647,-648,-649'>
                        <cfset gelr_15 = '+653,+654,+655,+656,+657,+658,+659'>
                        <cfset gelr_16 = '+660,+661,+662'>
                        <cfset gelr_17 = '-671,-679'>
                        <cfset gelr_18 = '+680,+681,+689'>
                        <cfset gelr_19 = '-691'>
                        <cfset gelr_20 = '-697,-698'>
                        
						<cfset gelr_1 = '#gelr_10#,#gelr_11#'><!---Net Satışlar--->
                        <cfset gelr_2 = '#gelr_10#,#gelr_11#,#gelr_12#'>
                        <cfset gelr_3 = '#gelr_10#,#gelr_11#,#gelr_12#,#gelr_13#'>
                        <cfset gelr_4 = '#gelr_10#,#gelr_11#,#gelr_12#,#gelr_13#,#gelr_14#,#gelr_15#,#gelr_16#'>
                        <cfset gelr_5 = '#gelr_10#,#gelr_11#,#gelr_12#,#gelr_13#,#gelr_14#,#gelr_15#,#gelr_16#,#gelr_17#,#gelr_18#'>
                        <cfset gelr_6 = '#gelr_10#,#gelr_11#,#gelr_12#,#gelr_13#,#gelr_14#,#gelr_15#,#gelr_16#,#gelr_17#,#gelr_18#,#gelr_19#'>
                        
                        <cfset gelr_sa = '+620'> <!---Satılan Mamüllerin maliyeti--->
                        <cfset gelr_sb = '+621'> <!---Satılan Ticari malların Maliyeti--->
                        
                        <cfset t_baslik = 'NET İŞLETME SERMAYESİ'>
                        <cfset t_baslik_1 = '( Dönen Varlıklar - Kısa Vadeli Borçlar )x1.000 TL'>
                        <cfset t_oran = '>0'>
                        <cfset t_row = 1>
                        <cfset calc = 'list1'>
                        <cfloop list="#list_1#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfset calc = 'list3'>
                        <cfloop list="#list_3#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                      	<cfinclude template="yeminli_rapor_rasyo_row.cfm">
						<tr height="20" class="color-list">
							<td style="text-align:center" colspan="2"><strong>ORAN ANALİZLERİ</strong></td>
                            <td style="text-align:center" colspan="<cfoutput>#period_col#</cfoutput>">&nbsp;</td>	
                     	</tr>   
    					<cfset t_baslik = 'CARİ ORAN'>
                        <cfset t_baslik_1 = '( Dönen Varlıklar / Kısa Vadeli Borçlar )'>
                        <cfset t_oran = '2,00'>
                        <cfset t_row = 2>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'CARİ ORAN SONUÇ DEĞERLENDİRME'>
                        <cfset t_baslik_1 = ''>
                        <cfset t_oran = ''>
                        <cfset t_islem = 2>
                        <cfset t_row = 3>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'LİKİDİTE ORANI'>
                        <cfset t_baslik_1 = '( Dönen Varlıklar -Stoklar / Kısa Vadeli Borçlar )'>
                        <cfset t_oran = '1,00'>
                        <cfset t_row = 4>
                        <cfset calc = 'list15'>
                        <cfloop list="#list_15#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                      	<cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                         <cfset t_baslik = 'LİKİDİTE ORAN SONUÇ DEĞERLENDİRME'>
                        <cfset t_baslik_1 = ''>
                        <cfset t_oran = ''>
                        <cfset t_islem = 1>
                        <cfset t_row = 5>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'NAKİT ORANI'>
                        <cfset t_baslik_1 = '( Hazır Değerler+ Menk.Kıymetler  / Kısa Vadeli Borçlar )'>
                        <cfset t_oran = '0,20'>
                        <cfset t_row = 6>
                        <cfset calc = 'list10'>
                        <cfloop list="#list_10#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfset calc = 'list11'>
                        <cfloop list="#list_11#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                      	<cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'NAKİT ORAN SONUÇ DEĞERLENDİRME'>
                        <cfset t_baslik_1 = ''>
                        <cfset t_oran = ''>
                        <cfset t_islem = 0.2>
                        <cfset t_row = 7>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'ASİT TEST ORAN'>
                        <cfset t_baslik_1 = '(Dönen Varlıklar-(Stoklar+Gelecek Ay Gidl) / Kısa Vadeli Borçlar )'>
                        <cfset t_oran = '1,25'>
                        <cfset t_row = 8>
                        <cfset calc = 'list18'>
                        <cfloop list="#list_18#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'ASİT TEST ORAN SONUÇ DEĞERLENDİRME'>
                        <cfset t_baslik_1 = ''>
                        <cfset t_oran = ''>
                        <cfset t_islem = 1.25>
                        <cfset t_row = 9>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
						<tr height="20" class="color-list">
							<td style="text-align:center" colspan="2"><strong>KARLILIK ANALİZLERİ</strong></td>
                            <td style="text-align:center" colspan="<cfoutput>#period_col#</cfoutput>">&nbsp;</td>	
                     	</tr>
                        
                        <cfset t_baslik = 'BRÜT KAR MARJI'>
                        <cfset t_baslik_1 = 'Brüt Satış Karı / Net Satışlar'>
                        <cfset t_oran = '=>% 10'>
                        <cfset t_row = 10>
                        <cfset t_islem = 10>
                        <cfset calc = 'gelr1'>
                        <cfloop list="#gelr_1#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfset calc = 'gelr2'>
                        <cfloop list="#gelr_2#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'NET KAR MARJI'>
                        <cfset t_baslik_1 = 'Net  Kar / Net Satışlar'>
                        <cfset t_oran = '=>% 4'>
                        <cfset t_row = 11>
                        <cfset t_islem = 4>
                        <cfset calc = 'gelr5'>
                        <cfloop list="#gelr_5#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'EKONOMİK RANTABİLİTE ORANI'>
                        <cfset t_baslik_1 = 'Yatırım Verim Oranı'>
                        <cfset t_oran = ''>
                        <cfset t_row = 12>
                        <cfset t_islem = 0>
                        <cfset calc = 'gelr5e'>
                        <cfloop list="#gelr_5#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calc_ters.cfm">
                      	</cfloop>
                        <cfset calc = 'gelr16'>
                        <cfloop list="#gelr_16#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfset calc = 'listp'>
                        <cfloop list="#list_p#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'FAİZLERİ KARŞILAMA ORANI'>
                        <cfset t_baslik_1 = ''>
                        <cfset t_oran = ''>
                        <cfset t_row = 13>
                        <cfset t_islem = 0>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <tr height="20" class="color-list">
							<td style="text-align:center" colspan="2"><strong>İŞLETME SERMAYESİ ANALİZLERİ</strong></td>
                            <td style="text-align:center" colspan="<cfoutput>#period_col#</cfoutput>">&nbsp;</td>	
                     	</tr>
                        
                        <cfset t_baslik = 'DÖNEN VARLIKLAR / AKTİF TOPLAMI'>
                        <cfset t_baslik_1 = ''>
                        <cfset t_oran = '=>0,66'>
                        <cfset t_row = 14>
                        <cfset t_islem = 0.66>
                        <cfset calc = 'lista'>
                        <cfloop list="#list_a#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'DURAN VARLIKLAR / AKTİF ORANI'>
                        <cfset t_baslik_1 = ''>
                        <cfset t_oran = '=>0,34'>
                        <cfset t_row = 15>
                        <cfset t_islem = 0.34>
                        <cfset calc = 'list2'>
                        <cfloop list="#list_2#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">

                        
                        <cfset t_baslik = 'KISA VADELİ YABANCI KAYNAKLAR / PASİF ORANI'>
                        <cfset t_baslik_1 = ''>
                        <cfset t_oran = '=>0,33'>
                        <cfset t_row = 16>
                        <cfset t_islem = 0.33>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'UZUN VADELİ YABANCI KAYNAKLAR / PASİF ORANI'>
                        <cfset t_baslik_1 = ''>
                        <cfset t_oran = '=>0,17'>
                        <cfset t_row = 17>
                        <cfset t_islem = 0.17>
                        <cfset calc = 'list4'>
                        <cfloop list="#list_4#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'ÖZKAYNAK ORANI'>
                        <cfset t_baslik_1 = 'Öz Sermaye  / Pasif  Oranı'>
                        <cfset t_oran = '=>0,50'>
                        <cfset t_row = 18>
                        <cfset t_islem = 0.5>
                        <cfset calc = 'list5'>
                        <cfloop list="#list_5#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'FİNANSMAN ORANI (FİNANSAL KALDIRAÇ ORANI)'>
                        <cfset t_baslik_1 = '( Uzun + Kısa Yabancı Kaynak / Özkaynak)'>
                        <cfset t_oran = '<=1,00'>
                        <cfset t_row = 19>
                        <cfset t_islem = 1>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <tr height="20" class="color-list">
							<td style="text-align:center" colspan="2"><strong>ETKİNLİK RASYOSU ANALİZLERİ</strong></td>
                            <td style="text-align:center" colspan="<cfoutput>#period_col#</cfoutput>">&nbsp;</td>	
                     	</tr>
                        
                        <cfset t_baslik = 'AKTİF (VARLIK) DEVİR HIZI'>
                        <cfset t_baslik_1 = '(Net Satışlar / Toplam Aktifler)'>
                        <cfset t_oran = '=>0,30'>
                        <cfset t_row = 20>
                        <cfset t_islem = 0.3>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'STOK DEVİR HIZI (GENEL)'>
                        <cfset t_baslik_1 = '(Satışların Maliyeti / Ortalama Stok )'>
                        <cfset t_oran = '=>'>
                        <cfset t_row = 21>
                        <cfset t_islem_ = 20>
                        <cfset calc = 'listst'>
                        <cfloop list="#list_st#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                         <cfset calc = 'gelr12'>
                        <cfloop list="#gelr_12#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        <cfset t_islem_ = 0>
                        
                        <cfset t_baslik = 'STOK DEVİR SÜRESİ (GENEL)'>
                        <cfset t_baslik_1 = '(Gün)'>
                        <cfset t_oran = '<=100'>
                        <cfset t_row = 22>
                        <cfset t_islem = 100>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'STOK DEVİR HIZI (MAMUL)'>
                        <cfset t_baslik_1 = '(Satılan Mamul Maliyeti / Ortalama Stok )'>
                        <cfset t_oran = '=>'>
                        <cfset t_row = 23>
                        <cfset t_islem_ = 20>
                        <cfset calc = 'gelrsa'>
                        <cfloop list="#gelr_sa#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfset calc = 'listsa'>
                        <cfloop list="#list_sa#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        <cfset t_islem_ = 0>
                        
                        <cfset t_baslik = 'STOK DEVİR SÜRESİ (MAMUL)'>
                        <cfset t_baslik_1 = '(Gün)'>
                        <cfset t_oran = '<=100'>
                        <cfset t_row = 24>
                        <cfset t_islem = 100>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'STOK DEVİR HIZI (TİCARİ MAL)'>
                        <cfset t_baslik_1 = '(Satılan T.Mallar Maliyeti / Ortalama Stok )'>
                        <cfset t_oran = '=>'>
                        <cfset t_row = 25>
                        <cfset t_islem_ = 20>
                        <cfset calc = 'gelrsb'>
                        <cfloop list="#gelr_sb#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfset calc = 'listsb'>
                        <cfloop list="#list_sb#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        <cfset t_islem_ = 0>
                        
                        <cfset t_baslik = 'STOK DEVİR SÜRESİ (TİCARİ MAL)'>
                        <cfset t_baslik_1 = '(Gün)'>
                        <cfset t_oran = '<=100'>
                        <cfset t_row = 26>
                        <cfset t_islem = 100>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <tr height="20" class="color-list">
							<td style="text-align:center" colspan="2"><strong>YATIRIM KARLILIK ANALİZLERİ</strong></td>
                            <td style="text-align:center" colspan="<cfoutput>#period_col#</cfoutput>">&nbsp;</td>	
                     	</tr>
                        
                        <cfset t_baslik = 'TİCARİ BORÇ DEVİR HIZI'>
                        <cfset t_baslik_1 = '(Kez)'>
                        <cfset t_oran = ''>
                        <cfset t_row = 27>
                        <cfset t_islem = 0>
                        <cfset calc = 'listtb'>
                        <cfloop list="#list_tb#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'TİCARİ BORÇLARIN ORTALAMA ÖDENME SÜRESİ'>
                        <cfset t_baslik_1 = ''>
                        <cfset t_oran = ''>
                        <cfset t_row = 28>
                        <cfset t_islem = 0>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">

                        <cfset t_baslik = 'ALACAK DEVİR HIZI'>
                        <cfset t_baslik_1 = '(Kez)'>
                        <cfset t_oran = ''>
                        <cfset t_row = 29>
                        <cfset t_islem = 0>
                        <cfset calc = 'listta'>
                        <cfloop list="#list_ta#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'ALACAKLARIN ORTALAMA TAHSİL SÜRESİ'>
                        <cfset t_baslik_1 = ''>
                        <cfset t_oran = ''>
                        <cfset t_row = 30>
                        <cfset t_islem = 0>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'DU PONT ANALİZİ'>
                        <cfset t_baslik_1 = '(Yatırım Karlılığı Yüzdesi)'>
                        <cfset t_oran = '=>2,00'>
                        <cfset t_row = 31>
                        <cfset t_islem = 2>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'AKTİF (VARLIK) KARLILIĞI'>
                        <cfset t_baslik_1 = ''>
                        <cfset t_oran = '=>2,00'>
                        <cfset t_row = 32>
                        <cfset t_islem = 2>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <cfset t_baslik = 'ÖZKAYNAK KARLILIĞI'>
                        <cfset t_baslik_1 = ''>
                        <cfset t_oran = '=>4,00'>
                        <cfset t_row = 33>
                        <cfset t_islem = 4>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                        <tr height="20" class="color-list">
							<td style="text-align:center" colspan="2"><strong>MALİ BAŞARI ANALİZLERİ</strong></td>
                            <td style="text-align:center" colspan="<cfoutput>#period_col#</cfoutput>">&nbsp;</td>	
                     	</tr>
                        
                        <cfset t_baslik = 'REEL BÜYÜME ORANI'>
                        <cfset t_baslik_1 = ''>
                        <cfset t_oran = ''>
                        <cfset t_row = 34>
                        <cfset t_islem = 0>
                        <cfinclude template="yeminli_rapor_rasyo_row.cfm">
                        
                    </table>
                </td>
            </tr>
        </table>
   <br />