<cfsetting showdebugoutput="no">
<cf_flat_list>
	<thead>
        <tr>
            <th width="35"><cf_get_lang dictionary_id='58577.Sıra'></th>
            <th><cf_get_lang dictionary_id='58834.İstasyon'></th>
            <th width="20"></th>
        </tr>	
    </thead>
    <tbody>
        <cfset attributes.UP_SEARCH = attributes.station_id>
        <cfparam name="attributes.keyword" default="">
        <cfparam name="attributes.branch_id" default="">
        <cfinclude template="../query/get_ezgi_workstation_all.cfm">
        <cfif get_workstation_all.recordcount>
            <cfoutput query="get_workstation_all">
                <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                    <td>#currentrow#</td>
                    <td>#station_name#</td>
                    <td><a href="#request.self#?fuseaction=prod.list_ezgi_workstation&event=upd&station_id=#station_id#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='36417.Alt İstasyon Ekle'>"></i></a></td>
                </tr>
            </cfoutput>
        <cfelse>
            <tr>
                <td colspan="4"><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!</td>
            </tr>
        </cfif>
    </tbody>
</cf_flat_list> 
