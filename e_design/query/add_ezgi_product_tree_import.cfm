<!---
    File: add_ezgi_product_tree_import.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 
<!---<cfdump var="#attributes#">--->
<cfset product_tree_id_list = ''>
<cfset spec_main_id_list =''>
<cfset deep_level = 1>
<cfquery name="GET_MAIN_STOCK_INFO" datasource="#dsn3#">
 	SELECT PRODUCT_UNIT_ID,STOCK_ID,PRODUCT_ID,PRODUCT_NAME,PROPERTY FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #GET_SID.STOCK_ID#
</cfquery>
<cfscript>
	if (GET_MAIN_STOCK_INFO.recordcount)
		{
			main_stock_id = GET_MAIN_STOCK_INFO.STOCK_ID;
			main_product_id =GET_MAIN_STOCK_INFO.PRODUCT_ID;
			spec_name='#GET_MAIN_STOCK_INFO.PRODUCT_NAME# #GET_MAIN_STOCK_INFO.PROPERTY#';
			row_count = 0;
			stock_id_list="";
			related_tree_id_list='';
			operation_type_id_list='';
			product_id_list="";
			product_name_list="";
			amount_list="";
			sevk_list="";
			configure_list="";
			is_property_list="";
			property_id_list = "";
			variation_id_list = "";
			total_min_list = "";
			total_max_list = "";
			tolerance_list = "";
			line_number_list ="";
			related_spect_main_id_list ="";
			question_id_list ="";
			detail_list ="";
		}
</cfscript>
<cfloop query="get_product_tree">  
	<cfset row_stock_id = 0>
	<cfset row_product_id = 0>
    <cfset row_product_name = ''>
    <cfset unit_id = '' >
    <cfset operation_id = 0>
    <cfset related_tree_id = ''>  
	<cfif len(RELATED_ID) and RELATED_ID gt 0><!--- stock_id bilgisini almak için --->
        <cfquery name="GET_STOCK_INFO" datasource="#dsn3#">
            SELECT 
            	PROPERTY,
                PRODUCT_NAME,
                PRODUCT_UNIT_ID,
                STOCK_ID,
                PRODUCT_ID,
                ISNULL((
                	SELECT TOP 1 
                    	SPECT_MAIN_ID 
                  	FROM 
                    	SPECT_MAIN SM 
                  	WHERE 
                    	SM.STOCK_ID = STOCKS.STOCK_ID AND 
                        SM.IS_TREE = 1 
                  	ORDER BY 
                    	SM.RECORD_DATE DESC,
                        SM.UPDATE_DATE DESC
              	),0) AS SPECT_MAIN_ID,
                <cfif get_defaults.IS_HIZMET_PHANTOM eq 1>
                	ISNULL((SELECT PRODUCT_CATID FROM PRODUCT_CAT WITH (NOLOCK) WHERE LIST_ORDER_NO IN (1,5) AND PRODUCT_CATID = STOCKS.PRODUCT_CATID),0) AS IS_PHANTOM
                <cfelse>
                	0 AS IS_PHANTOM
                </cfif>
         	FROM 
            	STOCKS WITH (NOLOCK)
          	WHERE 
            	<cfif isdefined('RECETE_STOCK_ID_#RELATED_ID#')>
                	STOCK_ID = #Evaluate('RECETE_STOCK_ID_#RELATED_ID#')#
                <cfelse>
            		STOCK_ID = #RELATED_ID#
                </cfif>
        </cfquery>
        <cfif GET_STOCK_INFO.recordcount>
        	<cfif isdefined('get_design_info.IS_PROTOTIP') and get_design_info.IS_PROTOTIP eq 1> <!---Özelleştirilmiş Ürün İse--->
        		<cfquery name="get_question_different" datasource="#dsn3#">
                 	SELECT 
                    	PIECE_ROW_ID, 
                       	QUESTION_ID, 
                       	PT_QUESTION_ID,
                        EZGI_PIECE_ROW_ROW_ID
                  	FROM     
                     	(
                        	SELECT 
                            	ED.PIECE_ROW_ID, 
                              	EDP.QUESTION_ID, 
                              	ISNULL(PT.QUESTION_ID, 0) AS PT_QUESTION_ID,
                                ED.EZGI_PIECE_ROW_ROW_ID
                          	FROM      
                            	EZGI_DESIGN_PIECE_ROW AS ED WITH (NOLOCK) INNER JOIN
                              	EZGI_DESIGN_PIECE_PROTOTIP AS EDP WITH (NOLOCK) ON ED.EZGI_PIECE_ROW_ROW_ID = EDP.EZGI_PIECE_ROW_ROW_ID LEFT OUTER JOIN
                             	PRODUCT_TREE AS PT WITH (NOLOCK) ON EDP.EZGI_PIECE_ROW_ROW_ID = PT.PRODUCT_SAMPLE_ID
                           	WHERE   
                             	ED.PIECE_ROW_ID = #IID# AND
                              	ED.STOCK_ID = #get_product_tree.RELATED_ID#
                     	) AS TBL
                   	WHERE  
                    	QUESTION_ID <> PT_QUESTION_ID
            	</cfquery>
                
                <!---<cfdump var="#get_question_different#"><cfif get_question_different.recordcount><cfabort></cfif>--->
          		<cfif get_question_different.recordcount and len(get_question_different.QUESTION_ID)>
                  	<cfset attributes.EZGI_PIECE_ROW_ROW_ID = get_question_different.EZGI_PIECE_ROW_ROW_ID>
                    <cfset attributes.alternative_questions = get_question_different.QUESTION_ID>
               	<cfelse>
                  	<cfset attributes.alternative_questions = ''>
               	</cfif>
          	</cfif>
            <cfset row_stock_id = GET_STOCK_INFO.STOCK_ID>
            <cfset row_product_id = GET_STOCK_INFO.PRODUCT_ID>
            <cfset unit_id = GET_STOCK_INFO.PRODUCT_UNIT_ID>
            <cfset row_product_name =GET_STOCK_INFO.PRODUCT_NAME>
            <cfset spec_id = GET_STOCK_INFO.SPECT_MAIN_ID>
           	<cfset quantity = get_product_tree.AMOUNT>
            <cfif get_defaults.IS_HIZMET_PHANTOM eq 1>
            	<cfif GET_STOCK_INFO.IS_PHANTOM gt 0>
            		<cfset is_phantom = 1>
                <cfelse>
                	<cfset is_phantom = 0>
                </cfif>
            <cfelse>
            	<cfset is_phantom = 0>
            </cfif>
        </cfif>
   	<cfelseif len(OPERATION_TYPE_ID) and OPERATION_TYPE_ID gt 0><!--- operaion_id bilgisini almak için --->
    	<cfquery name="GET_OP_INFO" datasource="#dsn3#">
         	SELECT OPERATION_TYPE_ID,OPERATION_TYPE FROM OPERATION_TYPES WHERE OPERATION_TYPE_ID = #OPERATION_TYPE_ID#
       	</cfquery>
       	<cfif GET_OP_INFO.recordcount>
        	<cfset operation_id = GET_OP_INFO.OPERATION_TYPE_ID>
          	<cfset row_product_name =GET_OP_INFO.OPERATION_TYPE>
            <cfset quantity = get_product_tree.AMOUNT>
      	</cfif>
    </cfif>
  	<cfquery name="ADD_TREE" datasource="#dsn3#">
     	INSERT INTO
     		PRODUCT_TREE
           	(
                STOCK_ID,
                RELATED_ID,
                PRODUCT_ID,
                AMOUNT,
                FIRE_AMOUNT,
                FIRE_RATE,
                UNIT_ID,
                SPECT_MAIN_ID,
                IS_CONFIGURE,
                IS_SEVK,
                LINE_NUMBER,
                OPERATION_TYPE_ID,
                IS_PHANTOM,
                RELATED_PRODUCT_TREE_ID,
                QUESTION_ID,
                PROCESS_STAGE,
                DETAIL
       		)
      	VALUES
         	(
                #main_stock_id#,
                <cfif row_stock_id GT 0>#row_stock_id#<cfelse>NULL</cfif>,
                <cfif row_product_id GT 0>#row_product_id#<cfelse>NULL</cfif>,
                #quantity#,
                NULL,
                NULL,
                <cfif len(unit_id)>#unit_id#<cfelse>NULL</cfif>,
                <cfif len(spec_id)>#spec_id#<cfelse>NULL</cfif>,
                #is_configure#,
                #is_sevk#,
                <cfif len(get_product_tree.line_number) and get_product_tree.line_number gt 0>#get_product_tree.line_number#<cfelse>NULL</cfif>,
                <cfif get_product_tree.operation_type_id gt 0>#get_product_tree.operation_type_id#<cfelse>NULL</cfif>,
                #is_phantom#,
                NULL,
                <cfif isdefined('attributes.alternative_questions') and len(attributes.alternative_questions)>#attributes.alternative_questions#<cfelse>NULL</cfif>,
                #product_tree_process_stage#,
                NULL
       		)
  	</cfquery>
  	<cfquery name="GET_MAX_TREE" datasource="#dsn3#">
     	SELECT MAX(PRODUCT_TREE_ID) PRODUCT_TREE_ID FROM PRODUCT_TREE WITH (NOLOCK)
  	</cfquery>
	<cfif isdefined('get_design_info.IS_PROTOTIP') and get_design_info.IS_PROTOTIP eq 1> <!---Tasarım zelleştirilebilir İse--->
		<cfif isdefined('attributes.alternative_questions') and len(attributes.alternative_questions) and row_stock_id gt 0 and IID gt 0> <!---Alternatif Soru Girilmiş İse--->
            <cfset quetion_piece_row_id = IID>
            <cfset question_tree_stock_id = main_stock_id>
            <cfset quetion_product_id = row_product_id>
            <cfset quetion_product_tree_id = GET_MAX_TREE.PRODUCT_TREE_ID>
            <cfinclude template="add_ezgi_alternative_questions_import.cfm">
        </cfif>
	</cfif>
  	<cfset product_tree_id_list = ListAppend(product_tree_id_list,GET_MAX_TREE.PRODUCT_TREE_ID,',')>
    <cfset 'related_tree_id_1' = GET_MAX_TREE.PRODUCT_TREE_ID>
   	<cfscript>
    	row_count = row_count+1;
     	stock_id_list = listappend(stock_id_list,row_stock_id,',');
     	product_id_list = listappend(product_id_list,row_product_id,',');
		operation_type_id_list = listappend(operation_type_id_list,operation_id,',');
      	amount_list = listappend(amount_list,quantity,',');
    	product_name_list = listappend(product_name_list,row_product_name,'@');
    	if(row_stock_id gt 0)
		{
    		if((len(is_sevk) and is_sevk eq 1))
             	sevk_list = listappend(sevk_list,1,',');
         	else
           		sevk_list = listappend(sevk_list,0,',');
     	}
      	else
        	sevk_list = listappend(sevk_list,0,',');
                        
    	if(row_stock_id gt 0)
		{
       		if((len(is_configure) and is_configure eq 1))
             	configure_list = listappend(configure_list,1,',');
         	else
            	configure_list = listappend(configure_list,0,',');
    	}
      	else
     		configure_list = listappend(configure_list,1,',');
     	related_spect_main_id_list  = ListAppend(related_spect_main_id_list,spec_id,',');
      	if(deep_level eq 1)
		{
      		if(row_stock_id gt 0)
            	is_property_list=listappend(is_property_list,0,',');//sarf
          	else
            	is_property_list=listappend(is_property_list,3,',');//operasyon..
		}
    	else
		{
       		is_property_list=listappend(is_property_list,4,',');//operasyon altından gelen ürünler anlamına geliyor...
     	}
     	property_id_list = listappend(property_id_list,0,',');
     	variation_id_list = listappend(variation_id_list,0,',');
     	total_min_list = listappend(total_min_list,'-',',');
    	total_max_list = listappend(total_max_list,'-',',');
    	tolerance_list = listappend(tolerance_list,'-',',');
    	related_tree_id_list = listappend(related_tree_id_list,GET_MAX_TREE.PRODUCT_TREE_ID,',');
    	
      	if(len(line_number))
        	line_number_list = listappend(line_number_list,line_number,',');
        else
       		line_number_list = listappend(line_number_list,0,',');
		if(len(detail))
         	detail_list = listappend(detail_list,detail,',');
     	else
        	detail_list = listappend(detail_list,'-',',');
	</cfscript>
</cfloop>
<cfscript>
	new_spec_cre=specer(
                    	dsn_type: dsn3,
                     	spec_type: 1,
                      	spec_is_tree: 1,
                    	only_main_spec: 0,
                    	main_stock_id: main_stock_id,
                     	main_product_id: main_product_id,
                    	spec_name: spec_name,
                      	spec_row_count: row_count,
                     	stock_id_list: stock_id_list,
                      	product_id_list: product_id_list,
                    	product_name_list: product_name_list,
                     	amount_list: amount_list,
                     	is_sevk_list: sevk_list,	
                     	is_configure_list: configure_list,
                      	is_property_list: is_property_list,
                      	property_id_list: property_id_list,
                      	variation_id_list: variation_id_list,
                      	total_min_list: total_min_list,
                     	total_max_list : total_max_list,
                      	tolerance_list : tolerance_list,
                     	related_spect_id_list : related_spect_main_id_list,
                      	line_number_list : line_number_list,
                    	upd_spec_main_row:1,
                      	related_tree_id_list : related_tree_id_list,
                    	operation_type_id_list:operation_type_id_list,
						is_product_tree_import:1,
						detail_list : detail_list
                  		);
 	spec_main_id_list = ListAppend(spec_main_id_list,ListGetAt(new_spec_cre,1,','));
</cfscript>
<cfoutput>
    <cfquery name="upd_workstations_products_table" datasource="#dsn3#">
        INSERT INTO 
            WORKSTATIONS_PRODUCTS
            (
            WS_ID, STOCK_ID, CAPACITY, PRODUCTION_TIME, PRODUCTION_TIME_TYPE, SETUP_TIME, MIN_PRODUCT_AMOUNT, PRODUCTION_TYPE, PROCESS, MAIN_STOCK_ID, OPERATION_TYPE_ID, 
            ASSET_ID, RECORD_EMP, RECORD_IP, RECORD_DATE
            )
     	VALUES
            (#product_tree_workstation_id#, #main_stock_id#,60, 1, 1, 10, 1, 0, NULL, #main_stock_id#, NULL,  NULL, #session.ep.userid#, '#CGI.REMOTE_ADDR#', #now()#)

    </cfquery>
</cfoutput>
<cfif len(product_tree_id_list)>
    <cfquery name="upd_product_tree" datasource="#dsn3#">
        UPDATE 
        	PRODUCT_TREE 
		SET 
        	SPECT_MAIN_ID = (SELECT TOP 1 SPECT_MAIN_ID FROM SPECT_MAIN SM WHERE SM.STOCK_ID =PRODUCT_TREE.RELATED_ID AND SM.IS_TREE = 1 ORDER BY SM.RECORD_DATE DESC,SM.UPDATE_DATE DESC) 
		WHERE 
        	PRODUCT_TREE_ID IN (#product_tree_id_list#)
    </cfquery>
    <cfquery name="upd_spect_main_row_is_phantom" datasource="#dsn3#">
    	UPDATE       
        	SPECT_MAIN_ROW
		SET                
        	IS_PHANTOM = PT.IS_PHANTOM
		FROM            
        	PRODUCT_TREE AS PT INNER JOIN
        	SPECT_MAIN_ROW ON PT.PRODUCT_TREE_ID = SPECT_MAIN_ROW.RELATED_TREE_ID
		WHERE        
        	PT.PRODUCT_TREE_ID IN (#product_tree_id_list#)
    </cfquery>
</cfif>
<cfif len(spec_main_id_list)>
    <cfquery name="get_spec_main" datasource="#dsn3#">
    	UPDATE 
        	SPECT_MAIN_ROW
		SET
        	RELATED_MAIN_SPECT_ID = (SELECT TOP 1 SPECT_MAIN_ID FROM SPECT_MAIN SM WHERE SM.STOCK_ID =SPECT_MAIN_ROW.STOCK_ID AND SM.IS_TREE = 1  ORDER BY SM.RECORD_DATE DESC,SM.UPDATE_DATE DESC) 
		WHERE
        	SPECT_MAIN_ID IN (#spec_main_id_list#)
    </cfquery>
</cfif>