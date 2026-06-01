<!---
    File: add_ezgi_product_tree_creative_piece_row_insert.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 
    
<cfquery name="add_piece" datasource="#dsn3#">
        INSERT INTO 
            EZGI_DESIGN_PIECE_ROWS
            (
            <cfif attributes.PIECE_TYPE eq 4>
            	PIECE_RELATED_ID,
                PIECE_NAME,
          	<cfelse>
                PIECE_NAME, 
                PIECE_COLOR_ID, 
                MASTER_PRODUCT_ID, 
                MATERIAL_ID, 
                TRIM_TYPE,
                TRIM_SIZE, 
                IS_FLOW_DIRECTION, 
                BOYU, 
                ENI, 
                KALINLIK,
                TRIM_1,
                TRIM_2,
                TRIM_3,
                TRIM_4,
                PIECE_STYLE,
                BOY_FARK,
                EN_FARK,
                CANALIZING_TYPE,
         	</cfif>
            PIECE_DETAIL, 
            PIECE_CODE,
            PIECE_TYPE,
            DESIGN_MAIN_ROW_ID, 
          	DESIGN_PACKAGE_ROW_ID, 
          	DESIGN_ID,
            PIECE_STATUS,
            PIECE_AMOUNT,
            PIECE_PRICE,
            PIECE_PRICE_MONEY,
            PIECE_FLOOR,
            PIECE_PACKAGE_ROTA,
            RECORD_EMP, 
            RECORD_IP, 
            RECORD_DATE
            )
        VALUES        
            (
            <cfif attributes.PIECE_TYPE eq 4>
            	#attributes.related_stock_id#,
                '#attributes.RELATED_PRODUCT_NAME#',
            <cfelse>
                '#attributes.DESIGN_NAME_PIECE_ROW#',
                <cfif attributes.PIECE_TYPE eq 1 or attributes.PIECE_TYPE eq 2 or attributes.PIECE_TYPE eq 3>#attributes.COLOR_TYPE#<cfelse>0</cfif>,
                #attributes.DEFAULT_TYPE#,
                <cfif attributes.PIECE_TYPE eq 1>#attributes.PIECE_YONGA_LEVHA#<cfelse>NULL</cfif>,
                #attributes.trim_type#,
           		<cfif attributes.trim_type eq 1>#Filternum(attributes.trim_rate,1)#<cfelse>0</cfif>,
                <cfif isdefined('attributes.PIECE_SU_YONU') and attributes.PIECE_SU_YONU eq 1>1<cfelse>0</cfif>,
                #FilterNum(attributes.PIECE_BOY,1)#,
                #FilterNum(attributes.PIECE_EN,1)#,
                <cfif isdefined('attributes.PIECE_KALINLIK') and len(attributes.PIECE_KALINLIK)>#attributes.PIECE_KALINLIK#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.pvc_select_1') and len(attributes.pvc_select_1)>1<cfelse>0</cfif>,
                <cfif isdefined('attributes.pvc_select_2') and len(attributes.pvc_select_2)>1<cfelse>0</cfif>,
                <cfif isdefined('attributes.pvc_select_3') and len(attributes.pvc_select_3)>1<cfelse>0</cfif>,
                <cfif isdefined('attributes.pvc_select_4') and len(attributes.pvc_select_4)>1<cfelse>0</cfif>,
                <cfif isdefined('attributes.piece_style') and len(attributes.piece_style)>#attributes.piece_style#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.boy_fark') and len(attributes.boy_fark)>#filternum(attributes.boy_fark,1)#<cfelse>0</cfif>,
                <cfif isdefined('attributes.en_fark') and len(attributes.en_fark)>#filternum(attributes.en_fark,1)#<cfelse>0</cfif>,
                <cfif isdefined('attributes.canalize_type') and len(attributes.canalize_type)>#attributes.canalize_type#<cfelse>0</cfif>,
            </cfif>
            '#attributes.piece_detail#',
            '#attributes.DESIGN_CODE_PIECE_ROW#',
            #attributes.PIECE_TYPE#,
            #attributes.design_main_row_id#,
         	<cfif len(attributes.piece_package_no)>#attributes.piece_package_no#<cfelse>NULL</cfif>,
         	#attributes.design_id#,
            1,
            #FilterNum(attributes.PIECE_AMOUNT,4)#,
            <cfif isdefined('attributes.PRODUCT_PRICE') and len(attributes.PRODUCT_PRICE) and attributes.PIECE_TYPE eq 4>#FilterNum(attributes.PRODUCT_PRICE,4)#<cfelse>0</cfif>,
            <cfif isdefined('attributes.PRODUCT_PRICE_MONEY') and len(attributes.PRODUCT_PRICE_MONEY) and attributes.PIECE_TYPE eq 4>'#attributes.PRODUCT_PRICE_MONEY#'<cfelse>NULL</cfif>,
            <cfif isdefined('attributes.piece_package_floor_no') and len(attributes.piece_package_floor_no)>
            	#attributes.piece_package_floor_no#,
           	<cfelse>
            	NULL,
            </cfif>
            <cfif isdefined('attributes.piece_package_rota') and len(attributes.piece_package_rota)>
            	'#attributes.piece_package_rota#',
           	<cfelse>
            	NULL,
            </cfif>
            #session.ep.userid#,
            '#cgi.remote_addr#',
            #now()#
            )
</cfquery>
<cfquery name="get_max_id" datasource="#dsn3#">
        SELECT MAX(PIECE_ROW_ID) AS MAX_ID FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
</cfquery>
<cfinclude template="hsp_ezgi_product_tree_creative_piece_row.cfm">
    <cfif attributes.PIECE_TYPE eq 1 or attributes.PIECE_TYPE eq 2 or attributes.PIECE_TYPE eq 3> <!---Hammadde Değilse--->
    	<cfif attributes.PIECE_TYPE eq 1> <!---Yonga Levha İse--->
			<cfquery name="add_default_ebatlama_rota" datasource="#dsn3#">
				INSERT INTO 
					EZGI_DESIGN_PIECE_ROTA
					(
					PIECE_ROW_ID, 
					OPERATION_TYPE_ID, 
					SIRA, 
					AMOUNT
					)
				VALUES
                	(        
					#get_max_id.MAX_ID#, 
					#GET_DEFAULT_EBATLAMA.OPERATION_TYPE_ID#, 
					0, 
					1
					)
			</cfquery>
        </cfif>
        <cfquery name="add_default_rota" datasource="#dsn3#">
            INSERT INTO 
                EZGI_DESIGN_PIECE_ROTA
                (
                PIECE_ROW_ID, 
                OPERATION_TYPE_ID, 
                SIRA, 
                AMOUNT
                )
            SELECT        
                #get_max_id.MAX_ID#, 
                OPERATION_TYPE_ID, 
                SIRA, 
                QUANTITY
            FROM            
                EZGI_DESIGN_PIECE_DEFAULTS_ROTA
            WHERE        
                PIECE_DEFAULT_ID = #attributes.DEFAULT_TYPE#
        </cfquery>
    </cfif>