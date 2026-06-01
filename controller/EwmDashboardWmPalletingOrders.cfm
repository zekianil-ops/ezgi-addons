<cfscript>
	if(attributes.tabMenuController eq 0)
	{
		WOStruct = StructNew();
		
		WOStruct['#attributes.fuseaction#'] = structNew();	
		
		WOStruct['#attributes.fuseaction#']['default'] = 'list';
		if(not isdefined('attributes.event'))
			attributes.event = WOStruct['#attributes.fuseaction#']['default'];
	
            WOStruct['#attributes.fuseaction#']['list'] = structNew();
            WOStruct['#attributes.fuseaction#']['list']['window'] = 'normal';
            WOStruct['#attributes.fuseaction#']['list']['fuseaction'] = 'stock.dashboard_ezgi_wm_palleting_orders';
            WOStruct['#attributes.fuseaction#']['list']['filePath'] = 'addOns/ezgi/e_wm/display/dashboard_ezgi_wm_palleting_orders.cfm';
            WOStruct['#attributes.fuseaction#']['list']['queryPath'] = 'addOns/ezgi/e_wm/display/dashboard_ezgi_wm_palleting_orders.cfm';
            WOStruct['#attributes.fuseaction#']['list']['nextEvent'] = 'addOns/ezgi/e_wm/display/dashboard_ezgi_wm_palleting_orders.cfm';
		
	}
</cfscript>