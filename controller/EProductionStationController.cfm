<cfscript>
	if(attributes.tabMenuController eq 0)
	{
		// Switch //
		WOStruct = StructNew();
		
		WOStruct['#attributes.fuseaction#'] = structNew();	
		
		WOStruct['#attributes.fuseaction#']['default'] = 'list';
		if(not isdefined('attributes.event'))
			attributes.event = WOStruct['#attributes.fuseaction#']['default'];
		
		WOStruct['#attributes.fuseaction#']['list'] = structNew();
		WOStruct['#attributes.fuseaction#']['list']['window'] = 'normal';
		WOStruct['#attributes.fuseaction#']['list']['fuseaction'] = 'prod.list_ezgi_workstation';
		WOStruct['#attributes.fuseaction#']['list']['filePath'] = '/AddOns/ezgi/e_production/display/list_ezgi_workstation.cfm';
		
		if(isdefined("attributes.station_id"))
		{
			WOStruct['#attributes.fuseaction#']['upd'] = structNew();
			WOStruct['#attributes.fuseaction#']['upd']['window'] = 'normal';
			WOStruct['#attributes.fuseaction#']['upd']['fuseaction'] = 'prod.upd_ezgi_workstation';
			WOStruct['#attributes.fuseaction#']['upd']['filePath'] = '/AddOns/ezgi/e_production/form/upd_ezgi_workstation.cfm';
			WOStruct['#attributes.fuseaction#']['upd']['queryPath'] = '/AddOns/ezgi/e_production/query/upd_ezgi_workstation.cfm';
			WOStruct['#attributes.fuseaction#']['upd']['Identity'] = '#attributes.station_id#';
			WOStruct['#attributes.fuseaction#']['upd']['nextEvent'] = 'prod.list_ezgi_workstation&event=upd&station_id=';
			
		}
		
		WOStruct['#attributes.fuseaction#']['add'] = structNew();
		WOStruct['#attributes.fuseaction#']['add']['window'] = 'normal';
		WOStruct['#attributes.fuseaction#']['add']['fuseaction'] = 'prod.popup_add_ezgi_workstation';
		WOStruct['#attributes.fuseaction#']['add']['filePath'] = '/AddOns/ezgi/e_production/form/add_ezgi_workstation.cfm';
		WOStruct['#attributes.fuseaction#']['add']['queryPath'] = '/AddOns/ezgi/e_production/query/add_ezgi_workstation.cfm';
		WOStruct['#attributes.fuseaction#']['add']['nextEvent'] = 'prod.list_ezgi_workstation&event=upd&station_id=';
		
	}
	
	else
	{
		fuseactController = caller.attributes.fuseaction;
		getLang = caller.getLang;
		
		tabMenuStruct = StructNew();
		tabMenuStruct['#fuseactController#'] = structNew();
		tabMenuStruct['#fuseactController#']['tabMenus'] = structNew();
		
		if(caller.attributes.event is 'add')
		{			
			tabMenuStruct['#fuseactController#']['tabMenus']['popup_add']['icons'] = structNew();
			tabMenuStruct['#fuseactController#']['tabMenus']['popup_add']['icons']['list-ul']['target'] = "_blank";
			tabMenuStruct['#fuseactController#']['tabMenus']['popup_add']['icons']['list-ul']['text'] = '#getLang('main',97)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['popup_add']['icons']['list-ul']['href'] = "#request.self#?fuseaction=prod.list_ezgi_workstation";
			tabMenuStruct['#fuseactController#']['tabMenus']['popup_add']['icons']['check']['text'] = '#getLang('main',49)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['popup_add']['icons']['check']['onClick'] = "buttonClickFunction()";
			
		}
		else if(caller.attributes.event is 'upd')
		{
			
			denied_pages = caller.denied_pages;
			GET_WORKSTATION_DETAIL.STATION_NAME =caller.GET_WORKSTATION_DETAIL.STATION_NAME;
			
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons'] = structNew();
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['add']['text'] = '#getLang('main',170)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['add']['href'] = "#request.self#?fuseaction=prod.list_ezgi_workstation&event=add";
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['add']['target'] = "_blank";
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['list-ul']['target'] = "_blank";
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['list-ul']['text'] = '#getLang('main',97)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['list-ul']['href'] = "#request.self#?fuseaction=prod.list_ezgi_workstation";
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['check']['text'] = '#getLang('main',49)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['check']['onClick'] = "buttonClickFunction()";
			
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['menus'] = structNew();
			i=0;
			
			
			if (not listfindnocase(denied_pages,'product.popup_list_product_workstations'))
			{
				tabMenuStruct['#fuseactController#']['tabMenus']['upd']['menus'][i]['text'] = '#getLang('prod',1)#';
				tabMenuStruct['#fuseactController#']['tabMenus']['upd']['menus'][i]['onClick'] = "windowopen('#request.self#?fuseaction=prod.popup_list_product_workstations&station_id=#attributes.station_id#&station_name=#GET_WORKSTATION_DETAIL.STATION_NAME#','page');";
				i++;
			}
			
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['menus'][i]['text'] = '#getLang('prod',339)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['menus'][i]['onClick'] = "windowopen('#request.self#?fuseaction=prod.popup_list_workstation_orders&station_id=#attributes.station_id#','list');";
			i++;
			
		}
		tabMenuData = SerializeJSON(tabMenuStruct['#attributes.fuseaction#']['tabMenus']);
	}
	
	WOStruct['#attributes.fuseaction#']['systemObject']['extendedForm'] = true;
	WOStruct['#attributes.fuseaction#']['systemObject']['pageExtendedEventList'] = 'add,upd';
	WOStruct['#attributes.fuseaction#']['systemObject']['pageTableName'] = 'WORKSTATIONS';
	WOStruct['#attributes.fuseaction#']['systemObject']['pageIdentityColumn'] = 'STATION_ID';
	WOStruct['#attributes.fuseaction#']['systemObject']['pageSettings'] = "['item-STATION_NAME','item-branch_id','item-department_id','item-exit_location_id','item-energy','item-production_location_id','item-workstation',]";
	
</cfscript>

<!---<cf_np tablename="WORKSTATIONS" primary_key = "STATION_ID" pointer="STATION_ID=#attributes.station_id#" dsn_var="DSN3">--->