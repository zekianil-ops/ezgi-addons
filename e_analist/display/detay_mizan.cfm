 		<table cellspacing="0" cellpadding="0"  border="0" width="100%" align="center">
          	<tr class="color-border"> 
            	<td> 
            		<table cellspacing="1" cellpadding="2" width="100%" border="0">
                    	<cfoutput>
                    	<tr height="30" class="color-header">
							<td style="text-align:center; width:40px" class="form-title">Hesap</td>
                            <td style="text-align:center; width:160px" class="form-title">Hesap Adları</td>
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
                                    <td width="5">&nbsp;</td>
                                </cfcase>
                            </cfswitch>
                       	</tr>
                        </cfoutput>
                        <cfif get_account_name.recordcount>
                        	<cfoutput query="get_account_name">
                            	<cfif SUB_ACCOUNT eq 1 or (SUB_ACCOUNT eq 0 and len(ACCOUNT_CODE) eq 3)>
                            		<cfinclude template="detay_mizan_row_b.cfm"> 
                                <cfelse>
                                	<cfinclude template="detay_mizan_row.cfm">
                                </cfif>
                            </cfoutput>
                        </cfif>
              		</table>
             	</td>
          	</tr>
    	</table>
	<br />