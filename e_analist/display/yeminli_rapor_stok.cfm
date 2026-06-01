 		<table cellspacing="0" cellpadding="0"  border="0" width="100%" align="center">
          	<tr class="color-border"> 
            	<td> 
            		<table cellspacing="1" cellpadding="2" width="100%" border="0">
                    	<cfoutput>
                    	<tr style="height:30px" class="color-header">
							<td style="text-align:center" colspan="2" class="form-title">Açıklama</td>
                            <td style="text-align:center" colspan="#period_col#" class="form-title">Dönemler</td>
                       	</tr>
                    	<tr style="height:30px" class="color-header">
							<td style="text-align:center; width:40px" class="form-title">Hesap</td>
                            <td style="text-align:center; width:160px" class="form-title">Malzeme Girişleri</td>
                            <td style="text-align:center" class="form-title">Açılış/#attributes.date1#</td>
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
                                    <td style="width:5px">&nbsp;</td>
                                </cfcase>
                            </cfswitch>
                       	</tr>
                        </cfoutput>
                        <cfset s_15 = '+150,+151,+152,+153,+157'>
						<cfset calc='s15'>
                        <cfset t_baslik = 'Toplam Stoklar'>
                        <cfset t_code = ''>
                        <cfloop list="#s_15#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfloop list="#s_15#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tb.cfm">
                        
                        <cfset s_1 = '-600,-601,-602'>
						<cfset calc='s1'>
                        <cfset t_baslik = 'BRÜT SATIŞLAR'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_1#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_2 = '-610,-611,-612'>
						<cfset calc='s2'>
                        <cfset t_baslik = 'SATIŞ İNDİRİMLERİ'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_2#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_3 = '-600,-601,-602,-610,-611,-612'>
						<cfset calc='s3'>
                        <cfset t_baslik = 'NET SATIŞLAR'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_3#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_4 = '-620,-621,-622,-623'>
						<cfset calc='s4'>
                        <cfset t_baslik = 'SATIŞLARIN MALİYETİ'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_4#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_5 = '-620'>
						<cfset calc='s5'>
                        <cfset t_baslik = 'SATIŞLARIN MALİYETİ-MAMUL'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_5#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_t.cfm">
                        
                        <cfset s_6 = '-621'>
						<cfset calc='s6'>
                        <cfset t_baslik = 'SATIŞLARIN MALİYETİ-T.MAL'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_6#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_t.cfm">
                        
                        <cfset s_7 = '-622'>
						<cfset calc='s7'>
                        <cfset t_baslik = 'SATIŞLARIN MALİYETİ-HİZMET'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_7#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_t.cfm">
                        
                        <cfset s_8 = '-600,-601,-602,-610,-611,-612,-620,-621,-622,-623'>
						<cfset calc='s8'>
                        <cfset t_baslik = 'BRÜT  SATIŞ KARI VEYA ZARARI'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_8#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_9 = '-630,-631,-632'>
						<cfset calc='s9'>
                        <cfset t_baslik = 'FAALİYET GİDERLERİ'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_9#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_20 = '#s_8#,#s_9#'>
						<cfset calc='s20'>
                        <cfset t_baslik = 'FAALİYET KARI VEYA ZARARI'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_20#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_10 = '-640,-641,-642,-643,-644,-645,-646,-647,-648,-649'>
						<cfset calc='s10'>
                        <cfset t_baslik = 'D.FAAL.OLAĞAN KARLAR'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_10#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_21 = '-653,-654,-655,-656,-657,-658,-659'>
						<cfset calc='s21'>
                        <cfset t_baslik = 'D.FAAL.OLAĞAN ZARARLAR'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_21#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_11 = '-660,-661'>
						<cfset calc='s11'>
                        <cfset t_baslik = 'FİNANSMAN GİDERLERİ'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_11#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_12 = '#s_20#,#s_10#,#s_21#,#s_11#'>
						<cfset calc='s12'>
                        <cfset t_baslik = 'OLAĞAN KAR VEYA ZARAR'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_12#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_13 = '-671,-679'>
						<cfset calc='s13'>
                        <cfset t_baslik = 'OLAĞAN DIŞI GELİR VE KARLAR'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_13#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_14 = '-680,-681,-689'>
						<cfset calc='s14'>
                        <cfset t_baslik = 'OLAĞAN DIŞI GELİR VE ZARARLAR'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_14#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_17 = '#s_12#,#s_13#,#s_14#'>
						<cfset calc='s17'>
                        <cfset t_baslik = 'DÖNEM KARI VEYA ZARARI'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_17#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_18 = '-691'>
						<cfset calc='s18'>
                        <cfset t_baslik = 'DÖNEM KARINDAN VERGİ KARŞILIĞI'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_18#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                        <cfset s_19 = '#s_12#,#s_13#,#s_14#,691'>
						<cfset calc='s19'>
                        <cfset t_baslik = 'DÖNEM NET KARI VEYA ZARARI'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#s_19#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="yeminli_rapor_row_tbb.cfm">
                        
                    </table>
             	</td>
          	</tr>
    	</table>
        <br />