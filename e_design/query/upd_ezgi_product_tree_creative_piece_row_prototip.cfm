<!---
    File: upd_ezgi_product_tree_creative_piece_row_prototip.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cftransaction>
    <cfquery name="del_piece_prototip" datasource="#dsn3#">
        DELETE FROM EZGI_DESIGN_PIECE_PROTOTIP WHERE <cfif isdefined('attributes.ezgi_piece_row_row_id')>EZGI_PIECE_ROW_ROW_ID=#attributes.ezgi_piece_row_row_id#<cfelse>PIECE_ROW_ID = #attributes.design_piece_row_id#</cfif>
    </cfquery>
    <cfquery name="del_piece_prototip_alternative" datasource="#dsn3#">
        DELETE FROM EZGI_DESIGN_PIECE_PROTOTIP_ALTERNATIVE WHERE <cfif isdefined('attributes.ezgi_piece_row_row_id')>EZGI_PIECE_ROW_ROW_ID=#attributes.ezgi_piece_row_row_id#<cfelse>PIECE_ROW_ID = #attributes.design_piece_row_id#</cfif>
    </cfquery>
    <cfif not isdefined('attributes.is_delete')>
        <cfquery name="add_piece_prototip" datasource="#dsn3#">
            INSERT INTO 
                EZGI_DESIGN_PIECE_PROTOTIP
                (
                	QUESTION_ID, 
                    <cfif isdefined('attributes.ezgi_piece_row_row_id')>
                    	EZGI_PIECE_ROW_ROW_ID
                    <cfelse>
                        PIECE_ROW_ID, 
                        BOY_FORMUL, 
                        EN_FORMUL, 
                        IS_AMOUNT_CHANGE, 
                        IS_PRICE_CHANGE,
                        IS_SIMILAR_STOCK,
                        AMOUNT_FORMUL,
                        PRIVATE_PRICE_TYPE,
                        PRIVATE_PRICE,
                        PRIVATE_PRICE_MONEY,
                        PRICE_FORMUL
                    </cfif>
                )
            VALUES        
                (
                    
                    <cfif isdefined('attributes.alternative_question_id') and len(attributes.alternative_question_id)>#attributes.alternative_question_id#<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.ezgi_piece_row_row_id')>
                    	#attributes.ezgi_piece_row_row_id#
                    <cfelse>
                        #attributes.design_piece_row_id#,
                        <cfif (isdefined('attributes.is_similar_stock') and attributes.piece_type eq 4) or piece_type neq 4>
                            <cfif isdefined('attributes.boy_formul') and len(attributes.boy_formul)>'#attributes.boy_formul#'<cfelse>NULL</cfif>,
                            <cfif isdefined('attributes.en_formul') and len(attributes.en_formul)>'#attributes.en_formul#'<cfelse>NULL</cfif>,
                        <cfelse>
                            NULL,
                            NULL,
                        </cfif>
                        <cfif isdefined('attributes.is_amount') and len(attributes.is_amount)>1<cfelse>0</cfif>,
                        <cfif isdefined('attributes.is_price') and len(attributes.is_price)>1<cfelse>0</cfif>,
                        <cfif isdefined('attributes.is_similar_stock') and len(attributes.is_similar_stock)>1<cfelse>0</cfif>,
                        <cfif isdefined('attributes.amount_formul') and len(attributes.amount_formul)>'#attributes.amount_formul#'<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.private_price_type') and len(attributes.private_price_type)>'#attributes.private_price_type#'<cfelse>0</cfif>,
                        <cfif isdefined('attributes.private_price_type') and attributes.private_price_type neq 0>#FilterNum(attributes.private_price,2)#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.private_price_type') and attributes.private_price_type eq 1>'#attributes.private_price_money#'<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.price_formul') and len(attributes.price_formul)>'#attributes.price_formul#'<cfelse>NULL</cfif>
                    </cfif>
                    )
        </cfquery>
        <cfif attributes.record_num gt 0>
            <cfloop from="1" to="#attributes.record_num#" index="i">
                <cfif isdefined('attributes.row_kontrol#i#') and Evaluate('attributes.row_kontrol#i#') eq 1>
                    <cfquery name="add_piece_prototip_alternative" datasource="#dsn3#">
                        INSERT INTO 
                            EZGI_DESIGN_PIECE_PROTOTIP_ALTERNATIVE
                            (
                            	<cfif isdefined('attributes.ezgi_piece_row_row_id')>
                                	EZGI_PIECE_ROW_ROW_ID,
                                    ALTERNATIVE_PIECE_ROW_ROW_ID,
                                    ALTERNATIVE_STOCK_ID,
                                <cfelse>
                                    IS_SPECIAL_MEASURE,
                                	PIECE_ROW_ID,
                                    <cfif attributes.piece_type eq 4>
                                        ALTERNATIVE_STOCK_ID,
                                    <cfelse>
                                        ALTERNATIVE_PIECE_ROW_ID,
                                    </cfif>
                                </cfif>
                                ALTERNATIVE_AMOUNT
                            )
                        VALUES        
                            (
                            	<cfif isdefined('attributes.ezgi_piece_row_row_id')>
                    				#attributes.ezgi_piece_row_row_id#,
                                    #attributes.alternative_piece_row_row_id#,
                                    #Evaluate('attributes.stock_id#i#')#,
                               	<cfelse>
                                    <cfif isdefined('attributes.is_special_measure_#i#')>1<cfelse>0</cfif>,
                                	#attributes.design_piece_row_id#,
                                    #Evaluate('attributes.stock_id#i#')#,
                               	</cfif>
                                #FilterNum(Evaluate('attributes.quantity#i#'),4)#
                            )
                    </cfquery>
                </cfif>
            </cfloop>
        </cfif>
 	</cfif>
</cftransaction>
<cfif isdefined('attributes.ezgi_piece_row_row_id')>
	<cflocation url="#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_piece_row_prototip&design_piece_row_id=#attributes.design_piece_row_id#&ezgi_piece_row_row_id=#attributes.ezgi_piece_row_row_id#" addtoken="No">
<cfelse>
	<cflocation url="#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_piece_row_prototip&design_piece_row_id=#attributes.design_piece_row_id#" addtoken="No">
</cfif>