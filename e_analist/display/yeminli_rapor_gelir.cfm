		<table cellspacing="0" cellpadding="0"  border="0" width="100%" align="center">
          	<tr class="color-border"> 
            	<td> 
            		<table cellspacing="1" cellpadding="2" width="100%" border="0">
                    	<cfoutput>
                    	<tr style=" height:30px" class="color-header">
							<td style="text-align:center" colspan="2" class="form-title">Açıklama</td>
                            <td style="text-align:center" colspan="#period_col#" class="form-title">Dönemler</td>
                       	</tr>
                    	<tr height="30" class="color-header">
							<td style="text-align:center; width:40px" class="form-title">Hesap</td>
                            <td style="text-align:center; width:160px" class="form-title">Gelir Tablosu Hesapları</td>
                            <td style="text-align:center" class="form-title">#last_donem# Dönem Sonu</td>
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
                        
                        <cfset gelr_10 = '-600,-601,-602'>
                        <cfset gelr_11 = '-610,-611,-612'>
                        <cfset gelr_12 = '-620,-621,-622,-623'>
                        <cfset gelr_13 = '-630,-631,-632'>
                        <cfset gelr_14 = '-640,-641,-642,-643,-644,-645,-646,-647,-648,-649'>
                        <cfset gelr_15 = '-653,-654,-655,-656,-657,-658,-659'>
                        <cfset gelr_16 = '-660,-661,-662'>
                        <cfset gelr_17 = '-671,-679'>
                        <cfset gelr_18 = '-680,-681,-689'>
                        <cfset gelr_19 = '-691'>
                        <cfset gelr_20 = '-697,-698'>
                        
						<cfset gelr_1 = '#gelr_10#,#gelr_11#'>
                        <cfset gelr_2 = '#gelr_10#,#gelr_11#,#gelr_12#'>
                        <cfset gelr_3 = '#gelr_10#,#gelr_11#,#gelr_12#,#gelr_13#'>
                        <cfset gelr_4 = '#gelr_10#,#gelr_11#,#gelr_12#,#gelr_13#,#gelr_14#,#gelr_15#,#gelr_16#'>
                        <cfset gelr_5 = '#gelr_10#,#gelr_11#,#gelr_12#,#gelr_13#,#gelr_14#,#gelr_15#,#gelr_16#,#gelr_17#,#gelr_18#'>
                        <cfset gelr_6 = '#gelr_10#,#gelr_11#,#gelr_12#,#gelr_13#,#gelr_14#,#gelr_15#,#gelr_16#,#gelr_17#,#gelr_18#,#gelr_19#'>
                        
						<cfset calc='gelr10'>
                        <cfset t_baslik = 'Brüt Satışlar'>
                        <cfset t_code = 60>
                        <cfloop list="#gelr_10#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                        </cfif>    
                        <cfloop list="#gelr_10#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 3>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif> 
                      	</cfloop>
                        
						<cfset calc='gelr11'>
                        <cfset t_baslik = 'Satış İndirimleri'>
                        <cfset t_code = 61>
                        <cfloop list="#gelr_11#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                        </cfif>    
                        <cfloop list="#gelr_11#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 3>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif> 
                      	</cfloop>
                        
                        <cfset calc='gelr1'>
                        <cfloop list="#gelr_1#"  index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        
                        <cfset t_code = ''>
                        <cfset t_baslik = 'NET SATIŞLAR'>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 6> 
                        	<cfinclude template="yeminli_rapor_dikey_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="yeminli_rapor_trend_row_tb.cfm">     
                        </cfif>
                        
						<cfset calc='gelr12'>
                        <cfset t_baslik = 'Satışların Maliyeti'>
                        <cfset t_code = 62>
                        <cfloop list="#gelr_12#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                       	<cfelseif attributes.report_type eq 6> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                        </cfif>    
                        <cfloop list="#gelr_12#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 3>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif> 
                      	</cfloop>
                        
                        <cfset calc='gelr2'>
                        <cfset t_code = ''>
                        <cfset t_baslik = 'BRÜT SATIŞ KARI VEYA ZARARI'>
                        <cfloop list="#gelr_2#"  index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 6> 
                        	<cfinclude template="yeminli_rapor_dikey_row_tbdikey.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="yeminli_rapor_trend_row_tb.cfm">     
                        </cfif>
                        
                        <cfset calc='gelr13'>
                        <cfset t_baslik = 'Faaliyet Giderleri'>
                        <cfset t_code = 63>
                        <cfloop list="#gelr_13#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                       	<cfelseif attributes.report_type eq 6> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                        </cfif>    
                        <cfloop list="#gelr_13#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 3>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif> 
                      	</cfloop>
                        
                        <cfset calc='gelr3'>
                        <cfset t_code = ''>
                        <cfset t_baslik = 'FAALİYET KARI VEYA ZARARI'>
                        <cfloop list="#gelr_3#"  index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 6> 
                        	<cfinclude template="yeminli_rapor_dikey_row_tbdikey.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="yeminli_rapor_trend_row_tb.cfm">     
                        </cfif>
                        
                        <cfset calc='gelr14'>
                        <cfset t_baslik = 'Diğer Faal.Ol.Gelir ve Karlar'>
                        <cfset t_code = 64>
                        <cfloop list="#gelr_14#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                       	<cfelseif attributes.report_type eq 6> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                        </cfif>    
                        <cfloop list="#gelr_14#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 3>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif> 
                      	</cfloop>
                        
                        <cfset calc='gelr15'>
                        <cfset t_baslik = 'Diğer Faal.Ol.Gider ve Zararlar (-)'>
                        <cfset t_code = 65>
                        <cfloop list="#gelr_15#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                       	<cfelseif attributes.report_type eq 6> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                        </cfif>    
                        <cfloop list="#gelr_15#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 3>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif> 
                      	</cfloop>
                        
                        <cfset calc='gelr16'>
                        <cfset t_baslik = 'Finansman Giderleri (-)'>
                        <cfset t_code = 66>
                        <cfloop list="#gelr_16#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                       	<cfelseif attributes.report_type eq 6> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                        </cfif>    
                        <cfloop list="#gelr_16#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 3>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif> 
                      	</cfloop>
                        
                        <cfset calc='gelr4'>
                        <cfset t_code = ''>
                        <cfset t_baslik = 'OLAĞAN KAR VEYA ZARAR'>
                        <cfloop list="#gelr_4#"  index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 6> 
                        	<cfinclude template="yeminli_rapor_dikey_row_tbdikey.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="yeminli_rapor_trend_row_tb.cfm">     
                        </cfif>
                        
                        <cfset calc='gelr17'>
                        <cfset t_baslik = 'Olağandışı Gelir ve Karlar'>
                        <cfset t_code = 67>
                        <cfloop list="#gelr_17#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                       	<cfelseif attributes.report_type eq 6> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                        </cfif>    
                        <cfloop list="#gelr_17#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 3>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif> 
                      	</cfloop>
                        
                        <cfset calc='gelr18'>
                        <cfset t_baslik = 'Olağandışı Gider ve Zararlar (-)'>
                        <cfset t_code = 68>
                        <cfloop list="#gelr_18#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                       	<cfelseif attributes.report_type eq 6> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                        </cfif>    
                        <cfloop list="#gelr_18#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 3>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif> 
                      	</cfloop>
                        <cfset calc='gelr5'>
                        <cfset t_code = ''>
                        <cfset t_baslik = 'DÖNEM NET KARI VEYA ZARARI'>
                        <cfloop list="#gelr_5#"  index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 6> 
                        	<cfinclude template="yeminli_rapor_dikey_row_tbdikey.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="yeminli_rapor_trend_row_tb.cfm">     
                        </cfif>
                        
                        <cfset calc='gelr5'>
                        <cfset t_baslik = 'Dönem Karı Veya Zararı'>
                        <cfset t_code = 690>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                        </cfif> 
                        
                        <cfset calc='gelr19'>
                        <cfset t_baslik = 'Dönem Karı Vergi Diğ.Yasal Yüküm.Karş.'>
                        <cfset t_code = 691>
                        <cfloop list="#gelr_19#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                        </cfif>
                        
                         <cfset calc='gelr6'>
                        <cfset t_baslik = 'Dönem Net Karı Veya Zararı'>
                        <cfset t_code = 692>
                        <cfloop list="#gelr_6#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                        </cfif>
                        
                        <cfset calc='gelr20'>
                        <cfloop list="#gelr_20#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfloop list="#gelr_20#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 3>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                            </cfif> 
                      	</cfloop>
                    </table>
             	</td>
          	</tr>
    	</table>
        <br />