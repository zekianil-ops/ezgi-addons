<!---
    File: dsp_ezgi_design_operation_row.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfsetting showdebugoutput="yes">
<cfinclude template="../query/get_ezgi_product_tree_creative_station_time.cfm">
<cfsavecontent  variable="operasyonlar">
    <cf_get_lang dictionary_id='36376.Operasyonlar'>
</cfsavecontent>
<cfsavecontent  variable="istasyonlar">
    <cf_get_lang dictionary_id='29473.İstasyonlar'>
</cfsavecontent>
<cfif get_default.DEFAULT_IS_STATION_OR_IS_OPERATION eq 1>
	<cfset time_head = '#istasyonlar#'>
<cfelse>
	<cfset time_head = "#operasyonlar#">
</cfif>
<cf_box title="#time_head#" id="operation_">
    <div id="operation_">
        <cf_grid_list id="operation_">
            <thead>
                <tr style="height:30px">
                    <th style="text-align:right;width:25px"><cf_get_lang dictionary_id="58577.Sıra"></th>
                    <th style="text-align:left;width:100%">&nbsp;<cfif get_default.DEFAULT_IS_STATION_OR_IS_OPERATION eq 1><cf_get_lang dictionary_id="58834.İstasyon"><cfelse><cf_get_lang dictionary_id="29419.Operasyon"></cfif></th>
                    <th style="text-align:center;width:40px"><cf_get_lang dictionary_id="36414.Adam Sayısı"></th>
                    <th style="text-align:center;width:70px"><cf_get_lang dictionary_id="29513.Süre"></th>
                </tr>
            </thead>
            <tbody>
            <cfif isdefined('station_time_cal_group') and station_time_cal_group.recordcount>
                <cfset total_time = 0>
                <cfoutput query="station_time_cal_group">
                    <cfset total_time = total_time+TOTAL_EMPLOYEE_TIME>
                    <tr>
                        <td style="text-align:right">#currentrow#&nbsp;</td>
                        <td nowrap <cfif Len(STATION_NAME) gt 30>title="#STATION_NAME#"</cfif>>
                            <cfif get_default.DEFAULT_IS_STATION_OR_IS_OPERATION eq 1>
                                <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.list_workstation&event=upd&station_id=#station_id#','wide');">
                            <cfelse>
                                <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_upd_ezgi_iflow_operation_rate&operation_type_id=#station_id#&e_design=1','list');">
                            </cfif>
                                &nbsp;#Left(STATION_NAME,30)#<cfif len(STATION_NAME) gte 30>...</cfif>
                            </a>
                        </td>
                        <td style="text-align:center;">#AmountFormat(EMPLOYEE_NUMBER,0)#</td>
                        <td style="text-align:right;"><cfif len(Int(TOTAL_STATION_TIME/3600)) eq 1>0</cfif>#Int(TOTAL_STATION_TIME/3600)#:<cfif len(Int((TOTAL_STATION_TIME/60) Mod 60)) eq 1>0</cfif>#Int((TOTAL_STATION_TIME/60) Mod 60)#:<cfif len(Int(TOTAL_STATION_TIME Mod 60)) eq 1>0</cfif>#Int(TOTAL_STATION_TIME Mod 60)#&nbsp;</td>
                    </tr>
                </cfoutput>
                <tr>
                    <td colspan="3" style="font-weight:bolder"><cf_get_lang dictionary_id="837.Toplam Adam Sayısı">  <cf_get_lang dictionary_id="29513.Süre"></td>
                    <td style="text-align:right;font-weight:bolder"><cfoutput><cfif len(Int(TOTAL_TIME/3600)) eq 1>0</cfif>#Int(TOTAL_TIME/3600)#:<cfif len(Int((TOTAL_TIME/60) Mod 60)) eq 1>0</cfif>#Int((TOTAL_TIME/60) Mod 60)#:<cfif len(Int(TOTAL_TIME Mod 60)) eq 1>0</cfif>#Int(TOTAL_TIME Mod 60)#&nbsp;</cfoutput></td>
                </tr>
            <cfelse>
                <tr><td colspan="4"><cf_get_lang dictionary_id="57484.Kayıt Yok	"></td></tr>
            </cfif>
           </tbody>
        </cf_grid_list>
    </div>
</cf_box>
