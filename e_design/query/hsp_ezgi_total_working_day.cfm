<!---
    File: hsp_ezgi_total_working_day.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfset toplam_gun = daysInYear(now())> <!---Bu Yıl Kaç Gün (365/366)--->
<cfset gun = createDate("#session.ep.period_year#", "01", "01")> <!---Yıl Başı Günü--->
<cfset test_gun = createDate("#session.ep.period_year#", "01", "01")> <!---Döngü Başlama Günü--->
<cfinclude template="hsp_ezgi_total_working_day_1.cfm"> <!---'İlgili Gün Aralığını Hesapla--->