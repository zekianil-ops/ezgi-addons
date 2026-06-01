<cfset iid = ''>
<cfif isdefined('attributes.design_id') and len(attributes.design_id)>
 	<cfset iid = '#iid#1-#attributes.design_id#,'>
</cfif>
<cfif isdefined('attributes.design_main_row_id') and len(attributes.design_main_row_id)>
 	<cfset iid = '#iid#2-#attributes.design_main_row_id#,'>
</cfif>
<cfif isdefined('attributes.design_package_row_id') and len(attributes.design_package_row_id)>
 	<cfset iid = '#iid#3-#attributes.design_package_row_id#,'>
</cfif>
<cfif isdefined('attributes.design_piece_row_id') and len(attributes.design_piece_row_id)>
 	<cfset iid = '#iid#4-#attributes.design_piece_row_id#,'>
</cfif>
<cfif right(iid,1) eq ','>
	<cfset iid = left(iid,len(iid)-1)>
</cfif>
<cfscript>

    if (attributes.tabMenuController eq 0)
    {

        WOStruct = structNew();

        WOStruct['#attributes.fuseaction#'] = structNew();

        WOStruct['#attributes.fuseaction#']['default'] = 'list';
        if (not isDefined('attributes.event'))
            attributes.event = WOStruct['#attributes.fuseaction#']['default'];

        WOStruct['#attributes.fuseaction#']['list'] = structNew();
        WOStruct['#attributes.fuseaction#']['list']['window'] = 'normal';
        WOStruct['#attributes.fuseaction#']['list']['fuseaction'] = 'prod.list_ezgi_product_tree_creative';
        WOStruct['#attributes.fuseaction#']['list']['filePath'] = '/AddOns/ezgi/e_design/display/list_ezgi_product_tree_creative.cfm';

        WOStruct['#attributes.fuseaction#']['add'] = structNew();
        WOStruct['#attributes.fuseaction#']['add']['window'] = 'normal';
        WOStruct['#attributes.fuseaction#']['add']['fuseaction'] = 'prod.list_ezgi_product_tree_creative&event=add';
        WOStruct['#attributes.fuseaction#']['add']['filePath'] = '/AddOns/ezgi/e_design/form/add_ezgi_product_tree_creative.cfm';
        WOStruct['#attributes.fuseaction#']['add']['queryPath'] = '/AddOns/ezgi/e_design/query/add_ezgi_product_tree_creative.cfm';
        WOStruct['#attributes.fuseaction#']['add']['nextEvent'] = WOStruct['#attributes.fuseaction#']['list']['fuseaction'];
	
		WOStruct['#attributes.fuseaction#']['upd'] = structNew();
        WOStruct['#attributes.fuseaction#']['upd']['window'] = 'normal';
        WOStruct['#attributes.fuseaction#']['upd']['fuseaction'] = 'prod.list_ezgi_product_tree_creative&event=upd';
        WOStruct['#attributes.fuseaction#']['upd']['filePath'] = '/AddOns/ezgi/e_design/form/upd_ezgi_product_tree_creative.cfm';
        WOStruct['#attributes.fuseaction#']['upd']['queryPath'] = '/AddOns/ezgi/e_design/query/upd_ezgi_product_tree_creative.cfm';
        WOStruct['#attributes.fuseaction#']['upd']['nextEvent'] = WOStruct['#attributes.fuseaction#']['list']['fuseaction'];

    }
	else
	{
		fuseactController = caller.attributes.fuseaction;
		// Tab Menus //
		tabMenuStruct = StructNew();
		getLang = caller.getLang;
		
		tabMenuStruct['#fuseactController#'] = structNew();
		tabMenuStruct['#fuseactController#']['tabMenus'] = structNew();
		// Upd //
		if(isdefined("caller.attributes.event") and caller.attributes.event is 'upd')
		{
						
			tabMenuStruct['#fuseactController#']['tabMenus']['upd'] = structNew();
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['menus'] = structNew();
			
			i = 0;

			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['menus'][i]['text'] = '#getLang('main',2851)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['menus'][i]['onclick'] = "windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_product_tree_import&design_id=#attributes.design_id#','list');";
			i=i+1;
			
			if(isdefined('attributes.design_main_row_id') && len(attributes.design_main_row_id))
			{
				tabMenuStruct['#fuseactController#']['tabMenus']['upd']['menus'][i]['text'] = '#getLang('main',2852)#';
				tabMenuStruct['#fuseactController#']['tabMenus']['upd']['menus'][i]['onclick'] = "windowopen('#request.self#?fuseaction=prod.popup_cnt_ezgi_product_tree_import&design_id=#attributes.design_id#&design_main_row_id=#attributes.design_main_row_id#','wide');";
				i=i+1;
			}
			else
			{
				tabMenuStruct['#fuseactController#']['tabMenus']['upd']['menus'][i]['text'] = '#getLang('main',2852)#';
				tabMenuStruct['#fuseactController#']['tabMenus']['upd']['menus'][i]['onclick'] = "windowopen('#request.self#?fuseaction=prod.popup_cnt_ezgi_product_tree_import&design_id=#attributes.design_id#','wide');";
				i=i+1;
			}
			
						
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['add']['text'] = '#getLang('main',170)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['add']['href'] = "#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=add";
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['add']['target'] = "_blank";

			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['copy']['text'] = '#getLang('main',64)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['copy']['href'] = "#request.self#?fuseaction=prod.cpy_ezgi_product_tree_creative&design_id=#attributes.design_id#";

			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['print']['text'] = '#getLang('main',62)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['print']['onclick'] = "windowopen('#request.self#?fuseaction=objects.popup_ezgi_print_files&iid=#iid#&print_type=288','wwide')";

			//Uyarılar
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['bell']['text'] = '#getlang('main',345)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['bell']['href'] = "";
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['bell']['target'] ="_blank";
			//Tarihçe
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['fa fa-history']['text'] = '#getlang('main',61)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['fa fa-history']['onClick'] = "";

			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['list-ul']['target'] = "_blank";
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['list-ul']['text'] = '#getLang('main',97)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['list-ul']['href'] = "#request.self#?fuseaction=prod.list_ezgi_product_tree_creative";

			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['check']['text'] = '#getLang('main',49)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['upd']['icons']['check']['onClick'] = "buttonClickFunction()";
			tabMenuData = SerializeJSON(tabMenuStruct['#fuseactController#']['tabMenus']);
		}
		else if(caller.attributes.event is 'add')
		{	
			tabMenuStruct['#fuseactController#']['tabMenus']['add'] = structNew();
			tabMenuStruct['#fuseactController#']['tabMenus']['add']['icons'] = structNew();
			tabMenuStruct['#fuseactController#']['tabMenus']['add']['icons']['list-ul']['target'] = "_blank";
			tabMenuStruct['#fuseactController#']['tabMenus']['add']['icons']['list-ul']['text'] = '#getLang('main',97)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['add']['icons']['list-ul']['href'] = "#request.self#?fuseaction=prod.list_ezgi_product_tree_creative";
			tabMenuStruct['#fuseactController#']['tabMenus']['add']['icons']['check']['text'] = '#getLang('main',49)#';
			tabMenuStruct['#fuseactController#']['tabMenus']['add']['icons']['check']['onClick'] = "buttonClickFunction()";
			tabMenuData = SerializeJSON(tabMenuStruct['#fuseactController#']['tabMenus']);
		}
	}
</cfscript>