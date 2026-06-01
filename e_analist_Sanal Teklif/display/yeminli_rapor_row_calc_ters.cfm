<cfoutput>
<!---Açılış Fişi Hesaplama--->
<cfif isdefined('BAKIYE_#ACCOUNT_CODE#')>
	<cfif islem_  eq '-'>
		<cfset 'BAKIYE_#ACCOUNT_CODE#'= evaluate('BAKIYE_#ACCOUNT_CODE#') * -1>
  	<cfelse>
        <cfset 'BAKIYE_#ACCOUNT_CODE#' = evaluate('BAKIYE_#ACCOUNT_CODE#') * +1>
    </cfif>
	<cfif isdefined('t_#calc#')>
		<cfset 't_#calc#' = evaluate('t_#calc#') + evaluate('BAKIYE_#ACCOUNT_CODE#')>
	<cfelse>
    	<cfset 't_#calc#' = evaluate('BAKIYE_#ACCOUNT_CODE#')>
    </cfif>
</cfif>
<cfswitch expression="#list_type#" >
   	<cfcase value="1"> <!---Yıllar Bazında Hesaplama--->
        <cfloop from="#sene1#" to="#sene2#" index="ii">
           	<cfif isdefined('BAKIYE_1_#ii#_#ACCOUNT_CODE#')>
            	<cfif islem_  eq '-'>
					<cfset 'BAKIYE_1_#ii#_#ACCOUNT_CODE#'= evaluate('BAKIYE_1_#ii#_#ACCOUNT_CODE#') * -1>
                <cfelse>
                    <cfset 'BAKIYE_1_#ii#_#ACCOUNT_CODE#' = evaluate('BAKIYE_1_#ii#_#ACCOUNT_CODE#') * +1>
                </cfif>
            	<cfif isdefined('t_#calc#_1_#ii#')>
           			<cfset 't_#calc#_1_#ii#' = evaluate('t_#calc#_1_#ii#') + evaluate('BAKIYE_1_#ii#_#ACCOUNT_CODE#')>
               	<cfelse>
                	<cfset 't_#calc#_1_#ii#' = evaluate('BAKIYE_1_#ii#_#ACCOUNT_CODE#')>
                </cfif>
           	</cfif>
            
        </cfloop>
   	</cfcase>
   	<cfcase value="2"> <!---Üç Aylık Bazda Hesaplama--->
      	<cfloop from="#sene1#" to="#sene2#" index="ii">
           	<cfloop from="1" to="#period_say#" index="i">
				<cfif isdefined('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#')>
                	
                	<cfif islem_  eq '-'>
						<cfset 'BAKIYE_#i#_#ii#_#ACCOUNT_CODE#'= evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#') * -1>
                    <cfelse>
                        <cfset 'BAKIYE_#i#_#ii#_#ACCOUNT_CODE#' = evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#') * +1>
                    </cfif>
                    
					<cfif isdefined('t_#calc#_#i#_#ii#')>
                        <cfset 't_#calc#_#i#_#ii#' = evaluate('t_#calc#_#i#_#ii#') + evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#')>
                    <cfelse>
                        <cfset 't_#calc#_#i#_#ii#' = evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#')>
                    </cfif>
                    
           		</cfif>
          	</cfloop>
       	</cfloop>
   	</cfcase>
	<cfcase value="3"><!---Aylık Bazda Hesaplama--->
       	<cfloop from="#sene1#" to="#sene2#" index="ii"> 
            <cfloop from="1" to="#period_say#" index="i">
				<cfif isdefined('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#')>
                	<cfif islem_  eq '-'>
						<cfset 'BAKIYE_#i#_#ii#_#ACCOUNT_CODE#'= evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#') * -1>
                    <cfelse>
                        <cfset 'BAKIYE_#i#_#ii#_#ACCOUNT_CODE#' = evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#') * +1>
                    </cfif>
                    
					<cfif isdefined('t_#calc#_#i#_#ii#')>
                        <cfset 't_#calc#_#i#_#ii#' = evaluate('t_#calc#_#i#_#ii#') + evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#')>
                    <cfelse>
                        <cfset 't_#calc#_#i#_#ii#' = evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#')>
                    </cfif>
           		</cfif>
           	</cfloop>
       	</cfloop>
    </cfcase>
</cfswitch>
</cfoutput>