<!---
    File: upd_ezgi_hesap_calc.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset hafta_tatili = GET_SHIFT_INFO.WEEK_OFFDAY>
<cfset hafta_sonu = hafta_tatili - 1>
<cfif hafta_sonu eq 0>
	<cfset hafta_sonu = 7>
</cfif>
<cfloop from="1" to="3650" index="h"> <!---10 senelik Döngü--->
	<cfif GET_GENERAL_OFFTIMES.recordcount>
        <cfquery name="genel_tatil" dbtype="query"> <!---İş Başlama Genel Tatil İçinde mi?--->
            SELECT
                *
            FROM
                GET_GENERAL_OFFTIMES
            WHERE
                START_DATE <= '#Dateformat(is_basi,dateformat_style)#' AND
                FINISH_DATE > '#Dateformat(is_basi,dateformat_style)#'
        </cfquery>
    <cfelse>
    	<cfset genel_tatil.recordcount=''>
    </cfif>
    <cfif DayOfWeek(is_basi) neq hafta_tatili or not genel_tatil.recordcount> <!---İş Başlama saati Hafta Tatili veya Genel tatil Değilse--->
    	
		<cfset gun_sonu = Dateformat(is_basi,'MM/DD/YYYY')> <!---Günsonu iş başlama gününe saat 00 ayarlanıyor--->
        
        <cfif DayOfWeek(is_basi) eq hafta_sonu> <!---Günsonu na Bitiş saatleri ilave ediliyor--->
        	<cfif GET_SHIFT_INFO.STD_END_HOUR neq 0>
        		<cfset gun_sonu = DateAdd('h',GET_SHIFT_INFO.STD_END_HOUR,gun_sonu)>
           	</cfif> 
            <cfif GET_SHIFT_INFO.STD_END_MIN neq 0>    
            	<cfset gun_sonu = DateAdd('n',GET_SHIFT_INFO.STD_END_MIN,gun_sonu)>
            </cfif>
        <cfelse> <!---İş Günü Hafta içi ise--->
			<cfif GET_SHIFT_INFO.END_HOUR neq 0>
				<cfset gun_sonu = DateAdd('h',GET_SHIFT_INFO.END_HOUR,gun_sonu)>
            </cfif>
            <cfif GET_SHIFT_INFO.END_MIN neq 0>
				<cfset gun_sonu = DateAdd('n',GET_SHIFT_INFO.END_MIN,gun_sonu)>
   			</cfif>
        </cfif>
        
		<cfset gun_fark = Datediff('s',is_basi,gun_sonu)> <!---Gün içindeki çalışma zamanı hesaplanıyor (saniye cinsinden)--->
        
		<cfset toplam_is_suresi = toplam_is_suresi - gun_fark> <!---Toplam iş zamanından Gün içindeki toplam çalışma zamanı düşülüyor--->
        
        <!---<cfoutput>#P_OPERATION_ID# - #toplam_is_suresi# - #is_basi# - #gun_sonu# - #gun_fark# <br></cfoutput>--->
		
		<cfif toplam_is_suresi eq 0> <!---Eğer Toplam İş zamanı Tam Bitmiş ise--->
        	<cfset is_sonu = DateAdd('s',-1,gun_sonu)> <!---Mesai Bitiminden 1 saniye geri çekiyoruz.--->
            <cfbreak>
       	<cfelseif toplam_is_suresi lt 0> <!---Mesai Bitiminden fark süresi kadar saniye geri çekiyoruz.--->
        	<cfset is_sonu = DateAdd('s',toplam_is_suresi,gun_sonu)>
            <cfbreak>
        </cfif>
    </cfif>
    
    <cfset is_basi = Dateformat(DateAdd('d',1,is_basi),'MM/DD/YYYY')> <!---iş başlama zamanına 1 gün ilave edililerek saat 00 alınıyor ve döngüye devam ediliyor --->
    <cfif DayOfWeek(is_basi) eq hafta_sonu>
    	<cfset is_basi = DateAdd('h',GET_SHIFT_INFO.STD_START_HOUR,is_basi)>
        <cfset is_basi = DateAdd('n',GET_SHIFT_INFO.STD_START_MIN,is_basi)>
   	<cfelse> <!---İş Günü Hafta içi ise--->
		<cfset is_basi = DateAdd('h',GET_SHIFT_INFO.START_HOUR,is_basi)>
        <cfset is_basi = DateAdd('n',GET_SHIFT_INFO.START_MIN,is_basi)>
    </cfif>
</cfloop>