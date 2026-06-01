 		<table cellspacing="0" cellpadding="0"  border="0" width="100%" style="text-align:center">
          	<tr class="color-border"> 
            	<td> 
            		<table cellspacing="1" cellpadding="2" width="100%" border="0">
                    	<cfoutput>
                        <cfif attributes.report_type neq 9> <!---Mizan Tablosu Değilse--->
                            <tr height="30" class="color-header">
                                <td style="text-align:center" colspan="2" class="form-title">Aktifler</td>
                                <td style="text-align:center" colspan="#period_col#" class="form-title">Dönemler</td>
                            </tr>
                        </cfif>
                    	<tr style="height:30px" class="color-header">
							<td style="text-align:center; width:50px" class="form-title">Hesap</td>
                            <td style="text-align:center; width:160px" class="form-title"><cfif attributes.report_type neq 9>Bilanço Hesapları<cfelse>Hesap Adları</cfif></td>
                            <td style="text-align:center" class="form-title">Açılış/#attributes.date1#</td>
                            <td style="5px">&nbsp;</td>
                            <cfswitch expression="#list_type#" >
                            	<cfcase value="1">
                					<cfloop from="#attributes.date1#" to="#attributes.date2#" index="i">
                                    	<td style="text-align:center" class="form-title">#evaluate('period_header_1_#i#')#</td>
                                        <td style="text-align:center" style="5px">&nbsp;</td>
                                    </cfloop>
                            	</cfcase>
                                <cfcase value="2">
                                    <cfloop from="#attributes.date1#" to="#attributes.date2#" index="i">
                                    	<td style="text-align:center" class="form-title" <cfif DayofYear(evaluate('period_flu_1_#i#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_1_#i#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_1_#i#')#</td>
                                        <td style="text-align:center" class="form-title" <cfif DayofYear(evaluate('period_flu_2_#i#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_2_#i#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_2_#i#')#</td>
                                        <td style="text-align:center" class="form-title" <cfif DayofYear(evaluate('period_flu_3_#i#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_3_#i#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_3_#i#')#</td>
                                        <td style="text-align:center" class="form-title" <cfif DayofYear(evaluate('period_flu_4_#i#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_4_#i#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_4_#i#')#</td>
                                        <td style="5px">&nbsp;</td>
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
                                    <td style="width:5px">&nbsp;</td>
                                </cfcase>
                            </cfswitch>
                       	</tr>
                        </cfoutput>
                        
                        <cfset list_10 = '+100,+101,+102,+103,+108'>
                        <cfset list_11 = '+110,+111,+112,+113,+119'>
                        <cfset list_12 = '+120,+121,+122,+124,+126,+127,+128,+129'>
                        <cfset list_13 = '+131,+132,+133,+134,+136,+137,+138,+139'>
                        <cfset list_15 = '+150,+151,+152,+153,+157,+158,+159'>
                        <cfset list_17 = '+170,+178,+179'>
                        <cfset list_18 = '+180,+181'>
                        <cfset list_19 = '+190,+191,+192,+193,+196,+197,+198,+199'>
                        <cfset list_1 = '#list_10#,#list_11#,#list_12#,#list_13#,#list_15#,#list_17#,#list_18#,#list_19#'>
                        <cfset calc='list1'>
                        <cfset t_code = 1>
                        <cfset t_baslik = 'DÖNEN VARLIKLAR'>
                        <cfloop list="#list_1#"  index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_tb.cfm">     
                        </cfif>    
                        
                        <cfset calc='list10'>
                        <cfset t_baslik = 'Hazır Değerler'>
                        <cfset t_code = 10>
                        <cfloop list="#list_10#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_10#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list11'>
                        <cfset t_baslik = 'Menkul Kıymetler'>
                        <cfset t_code = 11>
                        <cfloop list="#list_11#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_11#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list12'>
                        <cfset t_baslik = 'Ticari Alacaklar'>
                        <cfset t_code = 12>
                        <cfloop list="#list_12#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_12#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>

                        <cfset calc='list13'>
                        <cfset t_baslik = 'Diğer Alacaklar'>
                        <cfset t_code = 13>
                        <cfloop list="#list_13#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_13#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        
                        <cfset calc='list15'>
                        <cfset t_baslik = 'Stoklar'>
                        <cfset t_code = 15>
                        <cfloop list="#list_15#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_15#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        
                        <cfset calc='list17'>
                        <cfset t_baslik = 'Yıllara Yaygın İnş. Ve On. Mal.'>
                        <cfset t_code = 17>
                        <cfloop list="#list_17#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_17#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        
                        <cfset calc='list18'>
                        <cfset t_baslik = 'Gel. Ayl. Ait Gid. Ve Gelir Tah.'>
                        <cfset t_code = 18>
                        <cfloop list="#list_18#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_18#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list19'>
                        <cfset t_baslik = 'Diğer Dönen Varlıklar'>
                        <cfset t_code = 19>
                        <cfloop list="#list_19#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_19#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
						<cfset list_22 = '+220,+221,+222,+224,+226,+229'>
                        <cfset list_23 = '+231,+232,+233,+235,+236,+237,+239'>
                        <cfset list_24 = '+240,+241,+242,+243,+244,+245,+246,+247,+249'>
                        <cfset list_25 = '+250,+251,+252,+253,+254,+255,+256,+257,+258,+259'>
                        <cfset list_26 = '+260,+261,+262,+263,+264,+267,+268,+269'>
                        <cfset list_27 = '+271,+272,+277,+278,+279'>
                        <cfset list_28 = '+281,+280'>
                        <cfset list_29 = '+291,+292,+293,+294,+295,+297,+298,+299'>
                        <cfset list_2 = '#list_22#,#list_23#,#list_24#,#list_25#,#list_26#,#list_27#,#list_28#,#list_29#'>
                        <cfset calc='list2'>
                        <cfset t_baslik = 'DURAN VARLIKLAR'>
                        <cfset t_code = 2>
                        <cfloop list="#list_2#"  index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_tb.cfm">     
                        </cfif> 
                        
                        <cfset calc='list22'>
                        <cfset t_baslik = 'Ticari Alacaklar'>
                        <cfset t_code = 22>
                        <cfloop list="#list_22#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_22#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list23'>
                        <cfset t_baslik = 'Diğer Alacaklar'>
                        <cfset t_code = 23>
                        <cfloop list="#list_23#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_23#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list24'>
                        <cfset t_baslik = 'Mali Duran Varlıklar'>
                        <cfset t_code = 24>
                        <cfloop list="#list_24#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_24#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list25'>
                        <cfset t_baslik = 'Maddi Duran Varlıklar'>
                        <cfset t_code = 25>
                        <cfloop list="#list_25#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_25#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list26'>
                        <cfset t_baslik = 'Maddi Olmayan Duran Varlıklar'>
                        <cfset t_code = 26>
                        <cfloop list="#list_26#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_26#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list27'>
                        <cfset t_baslik = 'Özel Tükenmeye Tabi Varlıklar'>
                        <cfset t_code = 27>
                        <cfloop list="#list_27#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_27#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list28'>
                        <cfset t_baslik = 'Gel. Yıl. Ait Gid. Ve Gel. Tah. '>
                        <cfset t_code = 28>
                        <cfloop list="#list_28#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_28#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                                                
                        <cfset calc='list29'>
                        <cfset t_baslik = 'Diğer Duran Varlıklar'>
                        <cfset t_code = 29>
                        <cfloop list="#list_29#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_29#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfif attributes.report_type eq 1>
							<cfset calc='list1'>
                            <cfset t_baslik = 'DÖNEN VARLIKLAR'>
                            <cfset t_code = ''>
                            <cfset islem=1>
                            <cfinclude template="yeminli_rapor_row_tbb.cfm">

							<cfset calc='list2'>
                            <cfset t_baslik = 'DURAN VARLIKLAR'>
                            <cfset t_code = ''>
                            <cfset islem=1>
                            <cfinclude template="yeminli_rapor_row_tbb.cfm">
                            
                            
                            <cfset list_a1 = '#list_1#,#list_2#'>
                            <cfset calc='lista1'>
                            <cfset t_baslik = 'AKTİF TOPLAMI'>
                            <cfset t_code = ''>
                            <cfloop list="#list_a1#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfset islem=1>
                            <cfinclude template="yeminli_rapor_row_tbb.cfm">
                      	</cfif>      
                        
                        <cfif attributes.report_type neq 9> <!---Mizan Tablosu Değilse--->
							<cfoutput>
                            <tr height="30" class="color-header">
                                <td style="text-align:center" colspan="2" class="form-title">Pasifler</td>
                                <td style="text-align:center" colspan="#period_col#+2" class="form-title">Dönemler</td>
                            </tr>
                            <tr style="height:30px" class="color-header">
                                <td style="text-align:center; width:40px" class="form-title">Hesap</td>
                                <td style="text-align:center; width:160px" class="form-title">Bilanço Hesapları</td>
                                <td style="text-align:center" class="form-title">Açılış/#attributes.date1#</td>
                                <td style="5px">&nbsp;</td>
                                <cfswitch expression="#list_type#" >
                                    <cfcase value="1">
                                        <cfloop from="#attributes.date1#" to="#attributes.date2#" index="i">
                                            <td style="text-align:center" class="form-title">#evaluate('period_header_1_#i#')#</td>
                                            <td style="text-align:center" style="5px">&nbsp;</td>
                                        </cfloop>
                                    </cfcase>
                                    <cfcase value="2">
                                        <cfloop from="#attributes.date1#" to="#attributes.date2#" index="i">
                                            <td style="text-align:center" class="form-title" <cfif DayofYear(evaluate('period_flu_1_#i#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_1_#i#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_1_#i#')#</td>
                                            <td style="text-align:center" class="form-title" <cfif DayofYear(evaluate('period_flu_2_#i#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_2_#i#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_2_#i#')#</td>
                                            <td style="text-align:center" class="form-title" <cfif DayofYear(evaluate('period_flu_3_#i#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_3_#i#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_3_#i#')#</td>
                                            <td style="text-align:center" class="form-title" <cfif DayofYear(evaluate('period_flu_4_#i#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_4_#i#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_3_#i#')#</td>
                                            <td style="5px">&nbsp;</td>
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
                                        <td style="width:5px">&nbsp;</td>
                                    </cfcase>
                                </cfswitch>
                            </tr>
                            </cfoutput>
                        </cfif>
                        <cfset list_30 = '-300,-301,-302,-303,-304,-305,-306,-308,-309'>
                        <cfset list_32 = '-320,-321,-322,-326,-329'>
                        <cfset list_33 = '-331,-332,-333,-335,-336,-337'>
                        <cfset list_34 = '-340,-349'>
                        <cfset list_35 = '-350,-358'>
                        <cfset list_36 = '-360,-361,-368,-369'>
                        <cfset list_37 = '-370,-371,-372,-373,-379'>
                        <cfset list_38 = '-380,-381'>
						<cfset list_39 = '-391,-392,-393,-397,-399'>
                        
                        <cfset list_3 = '#list_30#,#list_32#,#list_33#,#list_34#,#list_35#,#list_36#,#list_37#,#list_38#,#list_39#'>
                        <cfset calc='list3'>
                        <cfset t_baslik = 'KISA VADELİ YAB.KAYNAKLAR'>
                        <cfset t_code = 3>
                        <cfloop list="#list_3#"  index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_tb.cfm">     
                        </cfif> 
                        
                        <cfset calc='list30'>
                        <cfset t_baslik = 'Mali Borçlar'>
                        <cfset t_code = 30>
                        <cfloop list="#list_30#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_30#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list32'>
                        <cfset t_baslik = 'Ticari Borçlar'>
                        <cfset t_code = 32>
                        <cfloop list="#list_32#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_32#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list33'>
                        <cfset t_baslik = 'Diğer Borçlar'>
                        <cfset t_code = 33>
                        <cfloop list="#list_33#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_33#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list34'>
                        <cfset t_baslik = 'Alınan Avanslar'>
                        <cfset t_code = 34>
                        <cfloop list="#list_34#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_34#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list35'>
                        <cfset t_baslik = 'Yıllara Yaygın İnş. Ve On. Hak.'>
                        <cfset t_code = 35>
                        <cfloop list="#list_35#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_35#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list36'>
                        <cfset t_baslik = 'Ödenecek Vergi ve Diğer Yüküm.'>
                        <cfset t_code = 36>
                        <cfloop list="#list_36#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_36#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list37'>
                        <cfset t_baslik = 'Borç ve Gider Karşılıkları'>
                        <cfset t_code = 37>
                        <cfloop list="#list_37#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_37#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list38'>
                        <cfset t_baslik = 'Gelecek Ayl. Ait Gelirler ve Gid. Tah.'>
                        <cfset t_code = 38>
                        <cfloop list="#list_38#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_38#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list39'>
                        <cfset t_baslik = 'Diğer Kısa Vadeli Yabancı Kaynaklar'>
                        <cfset t_code = 39>
                        <cfloop list="#list_39#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_39#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset list_40 = '-400,-401,-402,-405,-407,-408,-409'>
                        <cfset list_42 = '-420,-421,-422,-426,-429'>
                        <cfset list_43 = '-431,-432,-433,-436,-437,-438'>
                        <cfset list_44 = '-440,-449'>
                        <cfset list_47 = '-472,-479'>
                        <cfset list_48 = '-480,-481'>
						<cfset list_49 = '-492,-493,-499'>
                        
                        <cfset list_4 = '#list_40#,#list_42#,#list_43#,#list_44#,#list_47#,#list_48#,#list_49#'>
                        <cfset calc='list4'>
                        <cfset t_baslik = 'UZUN VADELİ YAB.KAYNAKLAR'>
                        <cfset t_code = 4>
                        <cfloop list="#list_4#"  index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_tb.cfm">     
                        </cfif> 
                        
                        <cfset calc='list40'>
                        <cfset t_baslik = 'Mali Borçlar'>
                        <cfset t_code = 40>
                        <cfloop list="#list_40#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_40#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list42'>
                        <cfset t_baslik = 'Ticari Borçlar'>
                        <cfset t_code = 42>
                        <cfloop list="#list_42#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_42#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list43'>
                        <cfset t_baslik = 'Diğer Borçlar'>
                        <cfset t_code = 43>
                        <cfloop list="#list_43#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_43#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list44'>
                        <cfset t_baslik = 'Alınan Avanslar'>
                        <cfset t_code = 44>
                        <cfloop list="#list_44#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_44#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list47'>
                        <cfset t_baslik = 'Borç ve Gider Karşılıkları'>
                        <cfset t_code = 47>
                        <cfloop list="#list_47#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_47#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list48'>
                        <cfset t_baslik = 'Gelecek Ayl. Ait Gelirler ve Gid. Tah.'>
                        <cfset t_code = 48>
                        <cfloop list="#list_48#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          

                            
                        <cfloop list="#list_48#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list49'>
                        <cfset t_baslik = 'Diğer Kısa Vadeli Yabancı Kaynaklar'>
                        <cfset t_code = 49>
                        <cfloop list="#list_49#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_49#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>


						<cfset list_50 = '-500,-501,-502,-503'>
                        <cfset list_52 = '-520,-521,-522,-523,-524,-529'>
                        <cfset list_54 = '-540,-541,-542,-548,-549'>
                        <cfset list_57 = '-570'>
                        <cfset list_58 = '-580'>
                        <cfset list_59 = '-590,-591'>
                        
                        <cfset list_5 = '#list_50#,#list_52#,#list_54#,#list_57#,#list_58#,#list_59#'>
                        <cfset calc='list5'>
                        <cfset t_baslik = 'ÖZKAYNAKLAR'>
                        <cfset t_code = 5>
                        <cfloop list="#list_5#"  index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_tb.cfm">     
                        </cfif> 

                        <cfset calc='list50'>
                        <cfset t_baslik = 'Ödenmiş Sermaye'>
                        <cfset t_code = 50>
                        <cfloop list="#list_50#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_50#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list52'>
                        <cfset t_baslik = 'Sermaye Yedekleri'>
                        <cfset t_code = 52>
                        <cfloop list="#list_52#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_52#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list54'>
                        <cfset t_baslik = 'Kar Yedekleri'>
                        <cfset t_code = 54>
                        <cfloop list="#list_54#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_54#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list57'>
                        <cfset t_baslik = 'Geçmiş Yıllar Karları'>
                        <cfset t_code = 57>
                        <cfloop list="#list_57#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_57#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list58'>
                        <cfset t_baslik = 'Geçmiş Yıllar Zararları'>
                        <cfset t_code = 58>
                        <cfloop list="#list_58#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_58#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfset calc='list59'>
                        <cfset t_baslik = 'Dönem Net Karı (Zararı)'>
                        <cfset t_code = 59>
                        <cfloop list="#list_59#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        	<cfinclude template="yeminli_rapor_row_t.cfm">
                      	<cfelseif attributes.report_type eq 4> 
                        	<cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                      	<cfelseif attributes.report_type eq 5> 
                        	<cfinclude template="yeminli_rapor_trend_row_t.cfm">      
                        </cfif>          
                            
                        <cfloop list="#list_59#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                            <cfif attributes.report_type eq 1 or attributes.report_type eq 9>
                        		<cfinclude template="yeminli_rapor_row.cfm">
                          	<cfelseif attributes.report_type eq 4> 
                                <cfinclude template="yeminli_rapor_dikey_row.cfm">
                            <cfelseif attributes.report_type eq 5> 
                                <cfinclude template="yeminli_rapor_trend_row.cfm">
                            </cfif>      
                      	</cfloop>
                        
                        <cfif attributes.report_type eq 1>
							<cfset calc='list3'>
                            <cfset t_baslik = 'KISA VADELİ BORÇLAR TOPLAMI'>
                            <cfset t_code = ''>
                            <cfset islem=1>
                            <cfinclude template="yeminli_rapor_row_tbb.cfm">
                            
                            <cfset calc='list4'>
                            <cfset t_baslik = 'UZUN VADELİ BORÇLAR TOPLAMI'>
                            <cfset t_code = ''>
                            <cfset islem=1>
                            <cfinclude template="yeminli_rapor_row_tbb.cfm">
                            
                            <cfset list_p3 = '#list_3#,#list_4#'>
                            <cfset calc='listp3'>
                            <cfset t_baslik = 'TOPLAM BORÇLAR'>
                            <cfset t_code = ''>
                            <cfloop list="#list_p3#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfset islem=1>
                            <cfinclude template="yeminli_rapor_row_tbb.cfm">
                            
                            <cfset calc='list5'>
                            <cfset t_baslik = 'ÖZKAYNAKLAR TOPLAMI'>
                            <cfset t_code = ''>
                            <cfset islem=1>
                            <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
							<cfset list_p1 = '#list_3#,#list_4#,#list_5#'>
                            <cfset calc='listp1'>
                            <cfset t_baslik = 'PASİF TOPLAMI'>
                            <cfset t_code = ''>
                            <cfloop list="#list_p1#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfset islem=1>
                            <cfinclude template="yeminli_rapor_row_tbb.cfm">
                            <cfset list_ap1 = '#list_a1#,#list_p1#'>
                            <cfset calc='listap1'>
                            <cfset t_baslik = 'AKTİF PASİF FARKI'>
                            <cfset t_code = ''>
                            <cfloop list="#list_ap1#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_1 = Left(account_code_,1)>
                                <cfif islem_1 eq '-'>
                                    <cfset islem_ = '+'>
                                <cfelse>
                                    <cfset islem_ = '-'>
                                </cfif>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfset islem=1>
                            <cfinclude template="yeminli_rapor_row_tbb.cfm">
                       	</cfif>   
                      	<cfif attributes.report_type eq 9>
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
                            
                            <cfset gelr_1 = '#gelr_10#,#gelr_11#,#gelr_12#,#gelr_13#,#gelr_14#,#gelr_15#,#gelr_16#,#gelr_17#,#gelr_18#,#gelr_19#,#gelr_20#'>
                            
                            <cfset calc='gelr1'>
                            <cfloop list="#gelr_1#"  index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            
                            <cfset t_code = 6>
                            <cfset t_baslik = 'GELİRLER'>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_tb.cfm">
                            <cfelseif attributes.report_type eq 6> 
                                <cfinclude template="yeminli_rapor_dikey_row_tb.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_tb.cfm">     
                            </cfif>
                            
                            <cfset calc='gelr10'>
                            <cfset t_baslik = 'Brüt Satışlar'>
                            <cfset t_code = 60>
                            <cfloop list="#gelr_10#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gelr_10#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
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
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gelr_11#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 
                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                            
                            <cfset calc='gelr12'>
                            <cfset t_baslik = 'Satışların Maliyeti'>
                            <cfset t_code = 62>
                            <cfloop list="#gelr_12#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 6> 
                                <cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gelr_12#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 
                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                           
                            <cfset calc='gelr13'>
                            <cfset t_baslik = 'Faaliyet Giderleri'>
                            <cfset t_code = 63>
                            <cfloop list="#gelr_13#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 6> 
                                <cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gelr_13#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 
                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                            
                            <cfset calc='gelr14'>
                            <cfset t_baslik = 'Diğer Faal.Ol.Gelir ve Karlar'>
                            <cfset t_code = 64>
                            <cfloop list="#gelr_14#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 6> 
                                <cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gelr_14#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
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
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 6> 
                                <cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gelr_15#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
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
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 6> 
                                <cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gelr_16#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 
                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                            
                            <cfset calc='gelr17'>
                            <cfset t_baslik = 'Olağandışı Gelir ve Karlar'>
                            <cfset t_code = 67>
                            <cfloop list="#gelr_17#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 6> 
                                <cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gelr_17#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
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
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 6> 
                                <cfinclude template="yeminli_rapor_dikey_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gelr_18#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 
                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                            
                            <cfset calc='gelr19'>
                            <cfset t_baslik = 'Dönem Karı Vergi Diğ.Yasal Yüküm.Karş.'>
                            <cfset t_code = 691>
                            <cfloop list="#gelr_19#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
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
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                </cfif> 
                            </cfloop>
                            
                            <cfset gidr_10 = '+701'>
                            <cfset gidr_11 = '+711,+712,+713'>
                            <cfset gidr_12 = '+721,+722,+723'>
                            <cfset gidr_13 = '+731,+732,+733'>
                            <cfset gidr_14 = '+741,+742,+743'>
                            <cfset gidr_15 = '+751,+752,+753'>
                            <cfset gidr_16 = '+761,+762,+763'>
                            <cfset gidr_17 = '+771,+772,+773'>
                            <cfset gidr_18 = '+781,+782,+783'>
                            <cfset gidr_19 = '+791,+792,+793,+794,+795,+796,+797,+798,+799'>
                            
                            <cfset gidr_1 = '#gidr_10#,#gidr_11#,#gidr_12#,#gidr_13#,#gidr_14#,#gidr_15#,#gidr_16#,#gidr_17#,#gidr_18#,#gidr_19#'>
                            
                            <cfset calc='gidr1'>
                            <cfloop list="#gidr_1#"  index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            
                            <cfset t_code = 7>
                            <cfset t_baslik = 'MALİYET HESAPLARI'>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_tb.cfm">
                            <cfelseif attributes.report_type eq 6> 
                                <cfinclude template="yeminli_rapor_dikey_row_tb.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_tb.cfm">     
                            </cfif>
                            
                            <cfset calc='gidr10'>
                            <cfset t_baslik = 'Maliyet Muh. Bağlantı Hes.'>
                            <cfset t_code = 70>
                            <cfloop list="#gidr_10#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gidr_10#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 
                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                            
                            <cfset calc='gidr11'>
                            <cfset t_baslik = 'Direkt İlk Madde ve Malzeme'>
                            <cfset t_code = 71>
                            <cfloop list="#gidr_11#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gidr_11#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 
                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                            
                            <cfset calc='gidr12'>
                            <cfset t_baslik = 'Direkt İşçilik Giderleri'>
                            <cfset t_code = 72>
                            <cfloop list="#gidr_12#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gidr_12#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 
                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                             
                           	<cfset calc='gidr13'>
                            <cfset t_baslik = 'Genel Üretim Giderleri'>
                            <cfset t_code = 73>
                            <cfloop list="#gidr_13#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gidr_13#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 

                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                            
                            <cfset calc='gidr14'>
                            <cfset t_baslik = 'Hizmet Üretim Giderleri'>
                            <cfset t_code = 74>
                            <cfloop list="#gidr_14#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gidr_14#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 
                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                            
                            <cfset calc='gidr15'>
                            <cfset t_baslik = 'Araştırma ve Geliştirme Giderleri'>
                            <cfset t_code = 75>
                            <cfloop list="#gidr_15#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gidr_15#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 
                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                            
                            <cfset calc='gidr16'>
                            <cfset t_baslik = 'Pazarlama Satış ve Dağıtım Giderleri'>
                            <cfset t_code = 76>
                            <cfloop list="#gidr_16#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gidr_16#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 
                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                            
                            <cfset calc='gidr17'>
                            <cfset t_baslik = 'Genel Yönetim Giderleri'>
                            <cfset t_code = 77>
                            <cfloop list="#gidr_17#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gidr_17#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 
                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                            
                            <cfset calc='gidr18'>
                            <cfset t_baslik = 'Finansman Giderleri'>
                            <cfset t_code = 78>
                            <cfloop list="#gidr_18#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gidr_18#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 
                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                            
                            <cfset calc='gidr19'>
                            <cfset t_baslik = 'Gider Çeşitleri'>
                            <cfset t_code = 79>
                            <cfloop list="#gidr_19#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfinclude template="yeminli_rapor_row_calculate.cfm">
                            </cfloop>
                            <cfif attributes.report_type eq 9>
                                <cfinclude template="yeminli_rapor_row_t.cfm">
                            <cfelseif attributes.report_type eq 7> 
                                <cfinclude template="yeminli_rapor_trend_row_t.cfm">     
                            </cfif>    
                            <cfloop list="#gidr_19#" index="account_code_">
                                <cfset account_code = Right(account_code_,3)>
                                <cfset islem_ = Left(account_code_,1)>
                                <cfif attributes.report_type eq 9>
                                    <cfinclude template="yeminli_rapor_row.cfm">
                                <cfelseif attributes.report_type eq 7> 
                                    <cfinclude template="yeminli_rapor_trend_row.cfm">
                                </cfif> 
                            </cfloop>
                            <cfinclude template="yeminli_rapor_row_dip_t.cfm">
                       	</cfif> 	
              		</table>
             	</td>
          	</tr>
    	</table>
	<br />