		<table cellspacing="0" cellpadding="0"  border="0" width="100%" align="center">
          	<tr class="color-border"> 
            	<td> 
            		<table cellspacing="1" cellpadding="2" width="100%" border="0">
                    	<cfoutput>
                    	<tr height="30" class="color-header">
							<td align="center" colspan="2" class="form-title">Açıklama</td>
                            <td align="center" colspan="#period_col#" class="form-title">Dönemler</td>
                       	</tr>
                    	<tr height="30" class="color-header">
							<td align="center" width="40" class="form-title">Hesap</td>
                            <td align="center" width="160" class="form-title">Gelir Tablosu Hesapları</td>
                            <td align="center" class="form-title">Açılış/#attributes.date1#</td>
                            <td width="5">&nbsp;</td>
                            <cfswitch expression="#list_type#" >
                            	<cfcase value="1">
                					<cfloop from="#attributes.date1#" to="#attributes.date2#" index="i">
                                    	<td align="center" class="form-title">#evaluate('period_header_1_#i#')#</td>
                                        <td align="center" width="5">&nbsp;</td>
                                    </cfloop>
                            	</cfcase>
                                <cfcase value="2">
                                    <cfloop from="#attributes.date1#" to="#attributes.date2#" index="i">
                                    	<td align="center" class="form-title" <cfif DayofYear(evaluate('period_flu_1_#i#')) gt DayofYear(now()) and Year(evaluate('period_flu_1_#i#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_1_#i#')#</td>
                                        <td align="center" class="form-title" <cfif DayofYear(evaluate('period_flu_2_#i#')) gt DayofYear(now()) and Year(evaluate('period_flu_2_#i#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_2_#i#')#</td>
                                        <td align="center" class="form-title" <cfif DayofYear(evaluate('period_flu_3_#i#')) gt DayofYear(now()) and Year(evaluate('period_flu_3_#i#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_3_#i#')#</td>
                                        <td align="center" class="form-title" <cfif DayofYear(evaluate('period_flu_4_#i#')) gt DayofYear(now()) and Year(evaluate('period_flu_4_#i#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_4_#i#')#</td>
                                        <td width="5">&nbsp;</td>
                                    </cfloop>
                              	</cfcase>
								<cfcase value="3">
                                	<td align="center" class="form-title"  <cfif DayofYear(evaluate('period_flu_1_#date1#')) gt DayofYear(now()) and Year(evaluate('period_flu_1_#date1#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_1_#date1#')#</td>
                                    <td align="center" class="form-title"  <cfif DayofYear(evaluate('period_flu_2_#date1#')) gt DayofYear(now()) and Year(evaluate('period_flu_2_#date1#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_2_#date1#')#</td>
                                    <td align="center" class="form-title"  <cfif DayofYear(evaluate('period_flu_3_#date1#')) gt DayofYear(now()) and Year(evaluate('period_flu_3_#date1#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_3_#date1#')#</td>
                                    <td align="center" class="form-title"  <cfif DayofYear(evaluate('period_flu_4_#date1#')) gt DayofYear(now()) and Year(evaluate('period_flu_4_#date1#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_4_#date1#')#</td>
                                    <td align="center" class="form-title"  <cfif DayofYear(evaluate('period_flu_5_#date1#')) gt DayofYear(now()) and Year(evaluate('period_flu_5_#date1#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_5_#date1#')#</td>
                                    <td align="center" class="form-title"  <cfif DayofYear(evaluate('period_flu_6_#date1#')) gt DayofYear(now()) and Year(evaluate('period_flu_6_#date1#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_6_#date1#')#</td>
                                    <td align="center" class="form-title"  <cfif DayofYear(evaluate('period_flu_7_#date1#')) gt DayofYear(now()) and Year(evaluate('period_flu_7_#date1#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_7_#date1#')#</td>
                                    <td align="center" class="form-title"  <cfif DayofYear(evaluate('period_flu_8_#date1#')) gt DayofYear(now()) and Year(evaluate('period_flu_8_#date1#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_8_#date1#')#</td>
                                    <td align="center" class="form-title"  <cfif DayofYear(evaluate('period_flu_9_#date1#')) gt DayofYear(now()) and Year(evaluate('period_flu_9_#date1#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_9_#date1#')#</td>
                                    <td align="center" class="form-title"  <cfif DayofYear(evaluate('period_flu_10_#date1#')) gt DayofYear(now()) and Year(evaluate('period_flu_10_#date1#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_10_#date1#')#</td>
                                    <td align="center" class="form-title"  <cfif DayofYear(evaluate('period_flu_11_#date1#')) gt DayofYear(now()) and Year(evaluate('period_flu_11_#date1#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_11_#date1#')#</td>
                                    <td align="center" class="form-title"  <cfif DayofYear(evaluate('period_flu_12_#date1#')) gt DayofYear(now()) and Year(evaluate('period_flu_12_#date1#')) eq Year(now())>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>#evaluate('period_header_12_#date1#')#</td>
                                    <td width="5">&nbsp;</td>
                                </cfcase>
                            </cfswitch>
                       	</tr>
                        </cfoutput>
                        <cfset g_690 = '-600,-601,-602,-610,-611,-612,-620,-621,-622,-623,-630,-631,-632,-640,-641,-642,-643,-644,-645,-646,-647,-648,-649,-653,-654,-655,-656,-657,-658,-659,-660,-661,-671,-679,-680,-681,-689'>
						<cfset calc='g690'>
                        <cfset t_baslik = 'Dönem Karı (V.Ö.Kar)Toplam'>
                        <cfset t_code = ''>
                        <cfloop list="#g_690#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfloop list="#g_690#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row.cfm">
                      	</cfloop>
                        <cfif attributes.report_type eq 3>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 6> 
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_dikey_row_tb.cfm">
                       	<cfelseif attributes.report_type eq 7> 
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_trend_row_tb.cfm">     
                        </cfif>    
                        
                        <cfset gt_690 = '-690'>
						<cfset calc='gt690'>
                        <cfset t_baslik = 'Dönem Karı (V.Ö.Kar) Hesap'>
                        <cfset t_code = '690'>
                        <cfloop list="#gt_690#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_tb.cfm">
                        
                        <cfset gt_691 = '-691'>
						<cfset calc='gt691'>
                        <cfset t_baslik = 'Dönem Karı Vergi Karşılığı'>
                        <cfset t_code = '691'>
                        <cfloop list="#gt_691#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row.cfm">
                        
                        <cfset gt_692 = '#g_690#,#gt_690#'>
						<cfset calc='gt692'>
                        <cfset t_baslik = 'Dönem Karı (V.S.Kar) Toplam'>
                        <cfset t_code = ''>
                        <cfloop list="#gt_692#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_tb.cfm">
                        
                        <cfset g_692 = '-692'>
						<cfset calc='g692'>
                        <cfset t_baslik = 'Dönem Karı (V.S.Kar) Hesap'>
                        <cfset t_code = '692'>
                        <cfloop list="#g_692#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_tb.cfm">
                        
                        <cfset gt_70 = '-720,-730,-740,-750,-760,-770,-780'>
						<cfset calc='gt70'>
                        <cfset t_baslik = ''>
                        <cfset t_code = ''>
                        <cfloop list="#gt_70#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfloop list="#gt_70#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row.cfm">
                      	</cfloop>
                        
                        <cfset calc='gt70'>
                        <cfset t_baslik = 'Gider Toplamları'>
                        <cfset t_code = ''>
                        <cfloop list="#gt_70#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_tb.cfm">
                        
                        <cfset g_730 = '0'>
						<cfset calc='g730'>
                        <cfset t_baslik = 'AMORTİSMAN GİDERLERİ'>
                        <cfset t_code = '730'>
                        <cfset islem=1>
                        <cfloop list="#g_730#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_tbb.cfm">
                        
                        <cfset g_740 = '0'>
						<cfset calc='g740'>
                        <cfset t_baslik = 'AMORTİSMAN GİDERLERİ'>
                        <cfset t_code = '740'>
                        <cfset islem=1>
                        <cfloop list="#g_740#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_tbb.cfm">
                        
                        <cfset g_750 = '0'>
						<cfset calc='g750'>
                        <cfset t_baslik = 'AMORTİSMAN GİDERLERİ'>
                        <cfset t_code = '750'>
                        <cfset islem=1>
                        <cfloop list="#g_750#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_tbb.cfm">
                       
                       	<cfset g_760 = '0'>
						<cfset calc='g760'>
                        <cfset t_baslik = 'AMORTİSMAN GİDERLERİ'>
                        <cfset t_code = '760'>
                        <cfset islem=1>
                        <cfloop list="#g_760#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_tbb.cfm">
                        
                        <cfset g_770 = '0'>
						<cfset calc='g770'>
                        <cfset t_baslik = 'AMORTİSMAN GİDERLERİ'>
                        <cfset t_code = '770'>
                        <cfset islem=1>
                        <cfloop list="#g_770#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_tbb.cfm">
                        
                        <cfset g_top = '0,0,0,0,0'>
						<cfset calc='gtop'>
                        <cfset t_baslik = 'TOPLAM'>
                        <cfset t_code = ''>
                        <cfset islem=1>
                        <cfloop list="#g_top#" index="account_code_">
                        	<cfset account_code = Right(account_code_,3)>
                            <cfset islem_ = Left(account_code_,1)>
                        	<cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_calculate.cfm">
                      	</cfloop>
                        <cfinclude template="/add_options/e_analiz/display/yeminli_rapor_row_tbb.cfm">
                        
                    </table>
             	</td>
          	</tr>
    	</table>
        <br />