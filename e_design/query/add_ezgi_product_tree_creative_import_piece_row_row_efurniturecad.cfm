<!---
    File:add_ezgi_product_tree_creative_import_piece_row_row_efurniturecad.cfm
    Folder: V16\add_options\ezgi\e_furniture
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: 
---> 
<cfoutput query="malzeme_listesi">
 	<cfif len(malzeme_listesi.WORKCUBE_CODE)><!---Stok Kodu Doluysa--->
    	<cfquery name="GET_STOCK_ID" datasource="#DSN3#">
        	SELECT STOCK_ID,PRODUCT_NAME FROM STOCKS WHERE PRODUCT_CODE = '#malzeme_listesi.WORKCUBE_CODE#' <!---Önce Stok Kodunu Ara--->
      	</cfquery>
      	<cfif not GET_STOCK_ID.recordcount>
       		<cfquery name="GET_STOCK_ID" datasource="#DSN3#">
            	SELECT STOCK_ID,PRODUCT_NAME FROM STOCKS WHERE PRODUCT_CODE_2 = '#malzeme_listesi.WORKCUBE_CODE#' <!---Sonra Özel Kodu Ara--->
         	</cfquery>
          	<cfif not GET_STOCK_ID.recordcount>
            	<cfif aksesuar  eq 1>
					<script type="text/javascript">
                        alert("Aksesuar #malzeme_listesi.WORKCUBE_CODE# Ürün Kodu Stok Dosyasında Bulunamamıştır.");
                        window.history.go(-1);
                    </script>
                <cfelse>
                	<script type="text/javascript">
                        alert("Hizmet #malzeme_listesi.WORKCUBE_CODE# Ürün Kodu Stok Dosyasında Bulunamamıştır.");
                        window.history.go(-1);
                    </script>
                </cfif>
				<cfabort>
         	</cfif>
     	</cfif>
 	<cfelse>
    	<cfdump var="#malzeme_listesi#"><cfabort>
        <cfif aksesuar  eq 1><!---Aksesuar--->
			<script type="text/javascript">
                alert("Aksesuar #malzeme_listesi.currentrow+1# Nolu Satırda Ürün Kodu Dolu olmalıdır");
                window.history.go(-1);
            </script>
        <cfelse><!---Hizmet--->
        	<script type="text/javascript">
                alert("Hizmet #malzeme_listesi.currentrow+1# Nolu Satırda Ürün Kodu Dolu olmalıdır");
                window.history.go(-1);
            </script>
        </cfif>
		<cfabort>
	</cfif>
        
	<cfif GET_STOCK_ID.recordcount>
     	<cfif GET_STOCK_ID.recordcount gt 1> <!---Stok veya Özel Kod Birden Fazla Tekrarlanmış mı--->
        	<cfif aksesuar  eq 1><!---Aksesuar--->
				<script type="text/javascript">
                    alert("Aksesuar #malzeme_listesi.currentrow+1# Nolu Satırdaki #malzeme_listesi.WORKCUBE_CODE# Ürün Kodu Stok Dosyasında Birden Fazla Bulunmuştur.");
                    window.history.go(-1);
                </script>
            <cfelse><!---Hizmet--->
            	<script type="text/javascript">
                    alert("Hizmet #malzeme_listesi.currentrow+1# Nolu Satırdaki #malzeme_listesi.WORKCUBE_CODE# Ürün Kodu Stok Dosyasında Birden Fazla Bulunmuştur.");
                    window.history.go(-1);
                </script>
            </cfif>
			<cfabort>
    	<cfelse>
        	<cfset temp = QueryAddRow(materials)>
            <cfif montaj eq 1><!---Aksesuar--->
            	<cfset Temp = QuerySetCell(materials, "Last_Row", malzeme_listesi.PIECE_NUMBER)> 
                <cfset Temp = QuerySetCell(materials, "Piece_Id", malzeme_listesi.PIECE_NUMBER)> 
            <cfelse><!---Hizmet--->
				<cfset Temp = QuerySetCell(materials, "Last_Row", Last_Row)> 
                <cfset Temp = QuerySetCell(materials, "Piece_Id",Last_Row)> 
            </cfif>
          	<cfset Temp = QuerySetCell(materials, "Stock_Id",GET_STOCK_ID.STOCK_ID)>
            <cfif aksesuar  eq 1>
         		<cfset Temp = QuerySetCell(materials, "Type",2)> <!---Aksesuar--->
            <cfelse>
            	<cfset Temp = QuerySetCell(materials, "Type",3)> <!---Hizmet--->
            </cfif>
        	<cfif len(malzeme_listesi.PIECE_AMOUNT) or isnumeric(malzeme_listesi.PIECE_AMOUNT)>
             	<cfset Temp = QuerySetCell(materials, "Amount",malzeme_listesi.PIECE_AMOUNT)>
        	<cfelse>
            	<cfif aksesuar  eq 1><!---Aksesuar--->
					<script type="text/javascript">
                        alert("Aksesuar #malzeme_listesi.WORKCUBE_CODE# Ürün Kodlu ürünün Miktarı Boştur veya Numerik Değildir.");
                        window.history.go(-1);
                    </script>
                <cfelse><!---Hizmet--->
                	<script type="text/javascript">
                        alert("Hizmet #malzeme_listesi.WORKCUBE_CODE# Ürün Kodlu ürünün Miktarı Boştur veya Numerik Değildir.");
                        window.history.go(-1);
                    </script>
                </cfif>
            	<cfabort>
       		</cfif>
     	</cfif>
   	</cfif>
</cfoutput>