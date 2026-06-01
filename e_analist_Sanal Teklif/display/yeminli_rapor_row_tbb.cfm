<tr style="height:20px" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-list';" class="color-list">
<cfoutput>
	<td style="text-align:right; width:50px"><strong><font color="brown">#t_code#&nbsp;</font></strong></td>
    <td><strong><font color="brown">#t_baslik#</font></strong></td>
    <td style="text-align:right; width:80px">
    <strong>
    <font color="brown">
    	<cfif isdefined('t_#calc#')>
        	<cfif islem_ eq '+'>
            	#Tlformat(evaluate('t_#calc#')/islem*1,2)#
           	<cfelse>
            	#Tlformat(evaluate('t_#calc#')/islem*-1,2)#
          	</cfif>     
     	<cfelse>
        	0,00&nbsp;
       	</cfif>
  	</font>
    </strong>
    </td>
    <td style="text-align:right; width:5px">&nbsp;</td>
    
    <cfswitch expression="#list_type#" >
       	<cfcase value="1">
            <cfloop from="#sene1#" to="#sene2#" index="ii">
                <td style="text-align:right;width:80px" >
                <strong>
                <font color="brown">
                	<cfif isdefined('t_#calc#_1_#ii#')>
                    	<cfif islem_ eq '+'>
                			#Tlformat(evaluate('t_#calc#_1_#ii#')/islem*1,2)#
                       	<cfelse>
                        	#Tlformat(evaluate('t_#calc#_1_#ii#')/islem*-1,2)#
                        </cfif>     
                  	<cfelse>
                    	0,00&nbsp;
                  	</cfif>
                </font>
                </strong>
                </td>
                <td style="text-align:right; width:5px">&nbsp;</td>
            </cfloop>
       	</cfcase>
      	<cfcase value="2">
         	<cfloop from="#sene1#" to="#sene2#" index="ii">
            	<cfloop from="1" to="#period_say#" index="i">
                	<td style="text-align:right; width:80px;<cfif DayofYear(evaluate('period_flu_#i#_#ii#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_#i#_#ii#')) eq Year(period_date_lock)>filter:alpha(Opacity=50,FinishOpacity=40);</cfif>">
                    <strong>
                    <font color="brown">
						<cfif isdefined('t_#calc#_#i#_#ii#')>
                        	<cfif islem_ eq '+'>
                        	 	#Tlformat(evaluate('t_#calc#_#i#_#ii#')/islem*1,2)#
                           	<cfelse>
                            	#Tlformat(evaluate('t_#calc#_#i#_#ii#')/islem*-1,2)#
                            </cfif>     
                       	<cfelse>
                    		0,00&nbsp;
                  		</cfif>
                   	</font>     
                   	</strong>
                   	</td>
               	</cfloop>
                <td width="5" >&nbsp;</td>
         	</cfloop>
      	</cfcase>
		<cfcase value="3">
        	<cfloop from="#sene1#" to="#sene2#" index="ii">
                 <cfloop from="1" to="#period_say#" index="i">
                	<td style="text-align:right; width:80px;<cfif DayofYear(evaluate('period_flu_#i#_#ii#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_#i#_#ii#')) eq Year(period_date_lock)>filter:alpha(Opacity=50,FinishOpacity=40);</cfif>" >
                    <strong>
                    <font color="brown">

						<cfif isdefined('t_#calc#_#i#_#ii#')>
                        	<cfif islem_ eq '+'>
                        		#Tlformat(evaluate('t_#calc#_#i#_#ii#')/islem*1,2)#
                          	<cfelse>
                            	#Tlformat(evaluate('t_#calc#_#i#_#ii#')/islem*-1,2)#
                            </cfif>      
                       	<cfelse>
                    		0,00&nbsp;
                  		</cfif>
                    </font>
                   	</strong>
                   	</td>
               	</cfloop>
                <td style="text-align:right; width:5px">&nbsp;</td>
           	</cfloop>
      	</cfcase>
 	</cfswitch>
</cfoutput>
</tr>