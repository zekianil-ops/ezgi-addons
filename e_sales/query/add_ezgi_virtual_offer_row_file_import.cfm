<!---
    File: add_ezgi_virtual_offer_row_file_import.cfm
    Folder: Add_Ons\ezgi\e_sales\query
    Author: Ezgi Yazılım
    Date: 16/10/2023
    Description:
--->
<cffunction name="getXmlAttributeValue" access="private" returntype="string" output="false" hint="XML attribute degerini namespace bagimsiz bulur.">
	<cfargument name="attributes" type="struct" required="true">
	<cfargument name="attributeName" type="string" required="true">

	<cfset var attributeKey = "">

	<cfloop collection="#arguments.attributes#" item="attributeKey">
		<cfif compareNoCase(listLast(attributeKey, ":"), arguments.attributeName) eq 0>
			<cfreturn arguments.attributes[attributeKey]>
		</cfif>
	</cfloop>

	<cfreturn "">
</cffunction>

<cffunction name="getRelationshipTargetById" access="private" returntype="string" output="false" hint="Relationship ID ile target yolunu bulur.">
	<cfargument name="xmlDoc" type="any" required="true">
	<cfargument name="relationId" type="string" required="true">

	<cfset var relationNodes = []>
	<cfset var relationNode = "">

	<cfif !len(trim(arguments.relationId))>
		<cfreturn "">
	</cfif>

	<cfset relationNodes = xmlSearch(arguments.xmlDoc, "//*[local-name()='Relationship']")>

	<cfloop array="#relationNodes#" index="relationNode">
		<cfif compareNoCase(getXmlAttributeValue(relationNode.XmlAttributes, "Id"), arguments.relationId) eq 0>
			<cfreturn getXmlAttributeValue(relationNode.XmlAttributes, "Target")>
		</cfif>
	</cfloop>

	<cfreturn "">
</cffunction>

<cffunction name="resolveExcelTargetPath" access="private" returntype="string" output="false" hint="Excel icindeki relative target yolunu fiziksel yola cevirir.">
	<cfargument name="rootPath" type="string" required="true">
	<cfargument name="targetPath" type="string" required="true">

	<cfset var normalizedTarget = trim(arguments.targetPath)>
	<cfset var sep = createObject("java", "java.io.File").separator>

	<cfif !len(normalizedTarget)>
		<cfreturn "">
	</cfif>

	<cfset normalizedTarget = replace(normalizedTarget, "/", sep, "all")>
	<cfset normalizedTarget = reReplace(normalizedTarget, "^\.\.[\\/]", "", "all")>
	<cfset normalizedTarget = reReplace(normalizedTarget, "^[\\/]+", "", "all")>

	<cfreturn arguments.rootPath & normalizedTarget>
</cffunction>

<cffunction name="extractExcelImages" access="public" returntype="struct" output="false" hint=".xlsx icindeki gomulu resimleri ve satir bilgilerini cikarir.">
	<cfargument name="filePath" type="string" required="true">

	<cfset var result = {
		images = [],
		extract_dir = "",
		success = false,
		error_message = ""
	}>
	<cfset var tempRoot = getTempDirectory()>
	<cfset var sep = createObject("java", "java.io.File").separator>
	<cfset var extractDir = tempRoot & "excel_media_" & createUUID() & sep>
	<cfset var mediaDir = "">
	<cfset var files = []>
	<cfset var imageExtensions = "png,jpg,jpeg,gif,bmp,webp">
	<cfset var i = 0>
	<cfset var fileName = "">
	<cfset var excelRootPath = "">
	<cfset var workbookPath = "">
	<cfset var workbookRelsPath = "">
	<cfset var workbookXml = "">
	<cfset var workbookRelsXml = "">
	<cfset var sheetNodes = []>
	<cfset var sheetNode = "">
	<cfset var selectedSheetRelId = "">
	<cfset var selectedSheetTarget = "worksheets/sheet1.xml">
	<cfset var selectedSheetPath = "">
	<cfset var selectedSheetRelsPath = "">
	<cfset var selectedSheetXml = "">
	<cfset var selectedSheetRelsXml = "">
	<cfset var drawingNodes = []>
	<cfset var drawingRelId = "">
	<cfset var drawingTarget = "">
	<cfset var drawingPath = "">
	<cfset var drawingRelsPath = "">
	<cfset var drawingXml = "">
	<cfset var drawingRelsXml = "">
	<cfset var anchorNodes = []>
	<cfset var anchorNode = "">
	<cfset var rowNodes = []>
	<cfset var blipNodes = []>
	<cfset var imageRelId = "">
	<cfset var imageTarget = "">
	<cfset var imagePath = "">

	<cfif !fileExists(arguments.filePath)>
		<cfset result.error_message = "Dosya bulunamadi">
		<cfreturn result>
	</cfif>

	<cftry>
		<cfdirectory action="create" directory="#extractDir#">

		<cfzip
			action="unzip"
			file="#arguments.filePath#"
			destination="#extractDir#"
			overwrite="true">

		<cfset mediaDir = extractDir & "xl" & sep & "media">
		<cfset excelRootPath = extractDir & "xl" & sep>
		<cfset result.extract_dir = extractDir>

		<cfif !directoryExists(mediaDir)>
			<cfset result.success = true>
			<cfreturn result>
		</cfif>

		<cfset workbookPath = excelRootPath & "workbook.xml">
		<cfset workbookRelsPath = excelRootPath & "_rels" & sep & "workbook.xml.rels">

		<cfif fileExists(workbookPath) and fileExists(workbookRelsPath)>
			<cfset workbookXml = xmlParse(fileRead(workbookPath))>
			<cfset workbookRelsXml = xmlParse(fileRead(workbookRelsPath))>
			<cfset sheetNodes = xmlSearch(workbookXml, "//*[local-name()='sheet']")>

			<cfloop array="#sheetNodes#" index="sheetNode">
				<cfif compareNoCase(getXmlAttributeValue(sheetNode.XmlAttributes, "name"), "IMPORT") eq 0>
					<cfset selectedSheetRelId = getXmlAttributeValue(sheetNode.XmlAttributes, "id")>
					<cfbreak>
				</cfif>
			</cfloop>

			<cfif !len(selectedSheetRelId) and arrayLen(sheetNodes)>
				<cfset selectedSheetRelId = getXmlAttributeValue(sheetNodes[1].XmlAttributes, "id")>
			</cfif>

			<cfif len(selectedSheetRelId)>
				<cfset selectedSheetTarget = getRelationshipTargetById(workbookRelsXml, selectedSheetRelId)>
				<cfif !len(selectedSheetTarget)>
					<cfset selectedSheetTarget = "worksheets/sheet1.xml">
				</cfif>
			</cfif>

			<cfset selectedSheetPath = resolveExcelTargetPath(excelRootPath, selectedSheetTarget)>
			<cfset selectedSheetRelsPath = excelRootPath & getDirectoryFromPath(replace(selectedSheetTarget, "/", sep, "all")) & "_rels" & sep & listLast(replace(selectedSheetTarget, "/", sep, "all"), sep) & ".rels">

			<cfif fileExists(selectedSheetPath) and fileExists(selectedSheetRelsPath)>
				<cfset selectedSheetXml = xmlParse(fileRead(selectedSheetPath))>
				<cfset selectedSheetRelsXml = xmlParse(fileRead(selectedSheetRelsPath))>
				<cfset drawingNodes = xmlSearch(selectedSheetXml, "//*[local-name()='drawing']")>

				<cfif arrayLen(drawingNodes)>
					<cfset drawingRelId = getXmlAttributeValue(drawingNodes[1].XmlAttributes, "id")>
					<cfset drawingTarget = getRelationshipTargetById(selectedSheetRelsXml, drawingRelId)>

					<cfif len(drawingTarget)>
						<cfset drawingPath = resolveExcelTargetPath(excelRootPath, drawingTarget)>
						<cfset drawingRelsPath = excelRootPath & "drawings" & sep & "_rels" & sep & listLast(replace(drawingTarget, "/", sep, "all"), sep) & ".rels">

						<cfif fileExists(drawingPath) and fileExists(drawingRelsPath)>
							<cfset drawingXml = xmlParse(fileRead(drawingPath))>
							<cfset drawingRelsXml = xmlParse(fileRead(drawingRelsPath))>
							<cfset anchorNodes = xmlSearch(drawingXml, "//*[local-name()='twoCellAnchor' or local-name()='oneCellAnchor']")>

							<cfloop array="#anchorNodes#" index="anchorNode">
								<cfset rowNodes = xmlSearch(anchorNode, ".//*[local-name()='from']/*[local-name()='row']")>
								<cfset blipNodes = xmlSearch(anchorNode, ".//*[local-name()='blip']")>

								<cfif arrayLen(rowNodes) and arrayLen(blipNodes)>
									<cfset imageRelId = getXmlAttributeValue(blipNodes[1].XmlAttributes, "embed")>
									<cfset imageTarget = getRelationshipTargetById(drawingRelsXml, imageRelId)>
									<cfset imagePath = resolveExcelTargetPath(excelRootPath, imageTarget)>

									<cfif len(imagePath) and fileExists(imagePath)>
										<cfset arrayAppend(result.images, {
											index = arrayLen(result.images) + 1,
											row_no = val(rowNodes[1].XmlText) + 1,
											file_name = listLast(imagePath, "\/"),
											file_path = imagePath
										})>
									</cfif>
								</cfif>
							</cfloop>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfif>

		<cfif !arrayLen(result.images)>
			<cfset files = directoryList(mediaDir, false, "path")>
			<cfset arraySort(files, "textnocase")>

			<cfloop from="1" to="#arrayLen(files)#" index="i">
				<cfset fileName = listLast(files[i], "\/")>

				<cfif listFindNoCase(imageExtensions, listLast(fileName, "."))>
					<cfset arrayAppend(result.images, {
						index = arrayLen(result.images) + 1,
						file_name = fileName,
						file_path = files[i]
					})>
				</cfif>
			</cfloop>
		</cfif>

		<cfset result.success = true>

		<cfcatch>
			<cfset result.error_message = cfcatch.message>
		</cfcatch>
	</cftry>

	<cfreturn result>
</cffunction>

<cffunction name="mapImagesToRows" access="public" returntype="array" output="false" hint="Excel satirlari ile extract edilen resimleri satir numarasina gore eslestirir.">
	<cfargument name="rowsArray" type="array" required="true">
	<cfargument name="imagesArray" type="array" required="true">

	<cfset var result = []>
	<cfset var i = 0>
	<cfset var j = 0>
	<cfset var imagePath = "">
	<cfset var imageName = "">
	<cfset var excelRowNo = 0>
	<cfset var hasAnchoredRows = false>

	<cfloop from="1" to="#arrayLen(arguments.imagesArray)#" index="j">
		<cfif structKeyExists(arguments.imagesArray[j], "row_no") and val(arguments.imagesArray[j].row_no) gt 0>
			<cfset hasAnchoredRows = true>
			<cfbreak>
		</cfif>
	</cfloop>

	<cfloop from="1" to="#arrayLen(arguments.rowsArray)#" index="i">
		<cfset imagePath = "">
		<cfset imageName = "">
		<cfset excelRowNo = i>

		<cfif structKeyExists(arguments.rowsArray[i], "excel_row_no")>
			<cfset excelRowNo = val(arguments.rowsArray[i].excel_row_no)>
		</cfif>

		<cfif hasAnchoredRows>
			<cfloop from="1" to="#arrayLen(arguments.imagesArray)#" index="j">
				<cfif
					structKeyExists(arguments.imagesArray[j], "row_no") and
					val(arguments.imagesArray[j].row_no) eq excelRowNo and
					structKeyExists(arguments.imagesArray[j], "file_path")
				>
					<cfset imagePath = arguments.imagesArray[j].file_path>
					<cfif structKeyExists(arguments.imagesArray[j], "file_name")>
						<cfset imageName = arguments.imagesArray[j].file_name>
					</cfif>
					<cfbreak>
				</cfif>
			</cfloop>
		<cfelseif arrayLen(arguments.imagesArray) gte i and structKeyExists(arguments.imagesArray[i], "file_path")>
			<cfset imagePath = arguments.imagesArray[i].file_path>
			<cfif structKeyExists(arguments.imagesArray[i], "file_name")>
				<cfset imageName = arguments.imagesArray[i].file_name>
			</cfif>
		</cfif>

		<cfset arrayAppend(result, {
			row_no = i,
			image_path = imagePath,
			image_name = imageName
		})>
	</cfloop>

	<cfreturn result>
</cffunction>

<cffunction name="saveImportImage" access="public" returntype="struct" output="false" hint="Extract edilen resmi kalici satis klasorune kopyalar.">
	<cfargument name="sourcePath" type="string" required="true">

	<cfset var result = {
		success = false,
		file_path = "",
		file_name = "",
		error_message = ""
	}>
	<cfset var targetDir = "C:\WORKCUBE_DOSYA\W3Catalyst_Ezgi_Test\documents\temp\">
	<cfset var extension = "">
	<cfset var generatedName = "">
	<cfset var targetFile = "">
	<cfset var currentTimestamp = 0>

	<cfif !len(trim(arguments.sourcePath)) or !fileExists(trim(arguments.sourcePath))>
		<cfset result.error_message = "Kaynak resim bulunamadi">
		<cfreturn result>
	</cfif>

	<cftry>
		<cfif !directoryExists(targetDir)>
			<cfdirectory action="create" directory="#targetDir#">
		</cfif>

		<cfset extension = lCase(listLast(arguments.sourcePath, "."))>
		<cfset generatedName = createUUID() & "." & extension>

		<cffile
			action="copy"
			source="#trim(arguments.sourcePath)#"
			destination="#targetDir##generatedName#">

		<cfset targetFile = createObject("java", "java.io.File").init(targetDir & generatedName)>
		<cfset currentTimestamp = createObject("java", "java.util.Date").init().getTime()>
		<cfset targetFile.setLastModified(currentTimestamp)>

		<cfset result.success = true>
		<cfset result.file_name = generatedName>
		<cfset result.file_path = targetDir & generatedName>

		<cfcatch>
			<cfset result.error_message = cfcatch.message>
		</cfcatch>
	</cftry>

	<cfreturn result>
</cffunction>

<cfinclude template="../include/virtual_offer_import_helpers.cfm">

<cfscript>
function findConfigPredictionOptionById(required array options, string optionId = "") {
	var optionItem = {};

	if (!len(trim(arguments.optionId))) {
		return {};
	}

	for (optionItem in arguments.options) {
		if (trim(optionItem.option_id & "") == trim(arguments.optionId)) {
			return duplicate(optionItem);
		}
	}

	return {};
}

function saveConfigPredictionRow(
	required numeric virtualOfferId,
	required numeric offerRowId,
	required numeric rowNo,
	required struct submittedAttributes,
	required string salesDatasourceName,
	required string setupDatasourceName
) {
	var result = {
		success = false,
		message = "",
		offer_row_id = arguments.offerRowId,
		predict_id = 0
	};
	var tableCheck = queryNew("");
	var getPreImportRow = queryNew("");
	var predictionData = {};
	var getExistingPredict = queryNew("");
	var savePredict = queryNew("");
	var detailItem = {};
	var selectedOptionId = "";
	var selectedOption = {};
	var fieldName = "";
	var detailRows = [];
	var summaryLines = [];
	var detailIndex = 0;
	var selectedCount = 0;
	var totalScore = 0;
	var needsManualSelection = false;
	var hasManualSelection = false;
	var overallStatus = "none";
	var overallScore = 0;
	var predictId = 0;
	var finalOptionName = "";
	var finalStatus = "";
	var finalScore = 0;
	var finalDisplayLine = "";

	tableCheck = queryExecute(
		"
		SELECT
			OBJECT_ID('demo_ezgiyazilim_1.EZGI_VIRTUAL_OFFER_ROW_CONFIG_PREDICT', 'U') AS SUMMARY_TABLE_ID,
			OBJECT_ID('demo_ezgiyazilim_1.EZGI_VIRTUAL_OFFER_ROW_CONFIG_PREDICT_DETAIL', 'U') AS DETAIL_TABLE_ID
		",
		{},
		{ datasource = arguments.salesDatasourceName }
	);

	if (
		!tableCheck.recordCount ||
		!val(tableCheck.SUMMARY_TABLE_ID[1]) ||
		!val(tableCheck.DETAIL_TABLE_ID[1])
	) {
		result.message = "Konfigürasyon tahmin tabloları bulunamadı.";
		return result;
	}

	getPreImportRow = queryExecute(
		"
		SELECT TOP (1)
			PRI.VIRTUAL_OFFER_ID,
			PRI.VIRTUAL_OFFER_ROW_ID,
			PRI.STOCK_ID,
			PRI.PRODUCT_ID,
			ISNULL(PRI.PRODUCT_NAME2, '') AS PRODUCT_NAME2,
			EIR.EZGI_ID,
			EIR.VIRTUAL_OFFER_ROW_ID AS TRANSFER_ROW_ID
		FROM
			EZGI_VIRTUAL_OFFER_ROW_PRE_IMPORT PRI
			LEFT OUTER JOIN EZGI_VIRTUAL_OFFER_ROW EIR ON EIR.VIRTUAL_OFFER_IMPORT_ROW_ID = PRI.VIRTUAL_OFFER_ROW_ID
		WHERE
			PRI.VIRTUAL_OFFER_ID = :virtualOfferId
			AND PRI.VIRTUAL_OFFER_ROW_ID = :offerRowId
		",
		{
			virtualOfferId = { value = arguments.virtualOfferId, cfsqltype = "cf_sql_numeric" },
			offerRowId = { value = arguments.offerRowId, cfsqltype = "cf_sql_numeric" }
		},
		{ datasource = arguments.salesDatasourceName }
	);

	if (!getPreImportRow.recordCount) {
		result.message = "Tahmin kaydı için satır bulunamadı.";
		return result;
	}

	if (!len(trim(getPreImportRow.STOCK_ID[1] & ""))) {
		queryExecute(
			"
			DELETE FROM
				demo_ezgiyazilim_1.EZGI_VIRTUAL_OFFER_ROW_CONFIG_PREDICT_DETAIL
			WHERE
				PREDICT_ID IN (
					SELECT
						PREDICT_ID
					FROM
						demo_ezgiyazilim_1.EZGI_VIRTUAL_OFFER_ROW_CONFIG_PREDICT
					WHERE
						VIRTUAL_OFFER_IMPORT_ROW_ID = :offerRowId
				)
			",
			{
				offerRowId = { value = arguments.offerRowId, cfsqltype = "cf_sql_numeric" }
			},
			{ datasource = arguments.salesDatasourceName }
		);

		queryExecute(
			"
			DELETE FROM
				demo_ezgiyazilim_1.EZGI_VIRTUAL_OFFER_ROW_CONFIG_PREDICT
			WHERE
				VIRTUAL_OFFER_IMPORT_ROW_ID = :offerRowId
			",
			{
				offerRowId = { value = arguments.offerRowId, cfsqltype = "cf_sql_numeric" }
			},
			{ datasource = arguments.salesDatasourceName }
		);

		result.success = true;
		result.message = "Ürün bağlantısı olmayan satır için eski tahmin kayıtları temizlendi.";
		return result;
	}

	predictionData = getConfigPrediction(
		val(getPreImportRow.STOCK_ID[1]),
		getPreImportRow.PRODUCT_NAME2[1],
		arguments.salesDatasourceName,
		arguments.setupDatasourceName
	);

	for (detailIndex = 1; detailIndex <= arrayLen(predictionData.details); detailIndex++) {
		detailItem = duplicate(predictionData.details[detailIndex]);
		fieldName = "config_predict_" & arguments.rowNo & "_" & detailItem.question_id;
		selectedOptionId = "";
		selectedOption = {};
		finalOptionName = "";
		finalStatus = "none";
		finalScore = 0;
		finalDisplayLine = detailItem.question_name & " - Seçim gerekli";

		if (
			structKeyExists(arguments.submittedAttributes, fieldName) &&
			len(trim(arguments.submittedAttributes[fieldName] & ""))
		) {
			selectedOptionId = trim(arguments.submittedAttributes[fieldName] & "");
		} else if (len(trim(detailItem.option_id & ""))) {
			selectedOptionId = trim(detailItem.option_id & "");
		}

		if (len(selectedOptionId)) {
			selectedOption = findConfigPredictionOptionById(detailItem.options, selectedOptionId);

			if (structCount(selectedOption)) {
				finalOptionName = trim(selectedOption.option_name & "");
				finalStatus = detailItem.match_status;
				finalScore = val(detailItem.match_score);
				finalDisplayLine = detailItem.question_name & " - " & finalOptionName;

				if (
					!len(trim(detailItem.option_id & "")) ||
					selectedOptionId != trim(detailItem.option_id & "")
				) {
					finalStatus = "manual";
					finalScore = 100;
					hasManualSelection = true;
				} else if (finalStatus == "similar") {
					finalDisplayLine &= " (Benzer)";
				}

				selectedCount++;
				totalScore += finalScore;
			} else {
				needsManualSelection = true;
			}
		} else {
			needsManualSelection = true;
		}

		if (!len(finalOptionName)) {
			finalStatus = "none";
			finalScore = 0;
		}

		arrayAppend(summaryLines, finalDisplayLine);
		arrayAppend(detailRows, {
			question_id = detailItem.question_id,
			question_name = detailItem.question_name,
			option_id = selectedOptionId,
			option_name = finalOptionName,
			match_status = finalStatus,
			match_score = finalScore,
			is_selected = len(finalOptionName) ? 1 : 0,
			sort_no = detailIndex
		});
	}

	if (!arrayLen(detailRows)) {
		arrayAppend(summaryLines, "Konfigürasyon sorusu bulunamadı");
	}

	if (arrayLen(detailRows)) {
		overallScore = totalScore / arrayLen(detailRows);
	}

	if (selectedCount eq 0) {
		overallStatus = "none";
	} else if (needsManualSelection or hasManualSelection) {
		overallStatus = "mixed";
	} else {
		overallStatus = "exact";
	}

	getExistingPredict = queryExecute(
		"
		SELECT TOP (1)
			PREDICT_ID
		FROM
			demo_ezgiyazilim_1.EZGI_VIRTUAL_OFFER_ROW_CONFIG_PREDICT
		WHERE
			VIRTUAL_OFFER_IMPORT_ROW_ID = :offerRowId
		",
		{
			offerRowId = { value = arguments.offerRowId, cfsqltype = "cf_sql_numeric" }
		},
		{ datasource = arguments.salesDatasourceName }
	);

	if (getExistingPredict.recordCount) {
		predictId = val(getExistingPredict.PREDICT_ID[1]);

		queryExecute(
			"
			UPDATE
				demo_ezgiyazilim_1.EZGI_VIRTUAL_OFFER_ROW_CONFIG_PREDICT
			SET
				VIRTUAL_OFFER_ID = :virtualOfferId,
				VIRTUAL_OFFER_ROW_ID = :transferRowId,
				VIRTUAL_OFFER_IMPORT_ROW_ID = :offerRowId,
				EZGI_ID = :ezgiId,
				PRODUCT_ID = :productId,
				STOCK_ID = :stockId,
				SOURCE_DESCRIPTION = :sourceDescription,
				PREDICT_SUMMARY = :predictSummary,
				MATCH_SCORE = :matchScore,
				MATCH_STATUS = :matchStatus,
				NEEDS_MANUAL_SELECTION = :needsManualSelection,
				IS_TRANSFERRED = :isTransferred,
				UPDATE_DATE = GETDATE(),
				UPDATE_EMP = :updateEmp,
				UPDATE_IP = :updateIp
			WHERE
				PREDICT_ID = :predictId
			",
			{
				virtualOfferId = { value = arguments.virtualOfferId, cfsqltype = "cf_sql_numeric" },
				transferRowId = { value = val(getPreImportRow.TRANSFER_ROW_ID[1]), cfsqltype = "cf_sql_numeric", null = !val(getPreImportRow.TRANSFER_ROW_ID[1]) },
				offerRowId = { value = arguments.offerRowId, cfsqltype = "cf_sql_numeric" },
				ezgiId = { value = val(getPreImportRow.EZGI_ID[1]), cfsqltype = "cf_sql_numeric", null = !val(getPreImportRow.EZGI_ID[1]) },
				productId = { value = val(getPreImportRow.PRODUCT_ID[1]), cfsqltype = "cf_sql_numeric", null = !val(getPreImportRow.PRODUCT_ID[1]) },
				stockId = { value = val(getPreImportRow.STOCK_ID[1]), cfsqltype = "cf_sql_numeric", null = !val(getPreImportRow.STOCK_ID[1]) },
				sourceDescription = { value = getPreImportRow.PRODUCT_NAME2[1], cfsqltype = "cf_sql_varchar" },
				predictSummary = { value = arrayToList(summaryLines, chr(10)), cfsqltype = "cf_sql_longvarchar" },
				matchScore = { value = overallScore, cfsqltype = "cf_sql_decimal", scale = 2 },
				matchStatus = { value = overallStatus, cfsqltype = "cf_sql_varchar" },
				needsManualSelection = { value = needsManualSelection ? 1 : 0, cfsqltype = "cf_sql_bit" },
				isTransferred = { value = val(getPreImportRow.TRANSFER_ROW_ID[1]) ? 1 : 0, cfsqltype = "cf_sql_bit" },
				updateEmp = { value = session.ep.userid, cfsqltype = "cf_sql_numeric" },
				updateIp = { value = cgi.remote_addr, cfsqltype = "cf_sql_varchar" },
				predictId = { value = predictId, cfsqltype = "cf_sql_numeric" }
			},
			{ datasource = arguments.salesDatasourceName }
		);
	} else {
		savePredict = queryExecute(
			"
			INSERT INTO demo_ezgiyazilim_1.EZGI_VIRTUAL_OFFER_ROW_CONFIG_PREDICT
			(
				VIRTUAL_OFFER_ID,
				VIRTUAL_OFFER_ROW_ID,
				VIRTUAL_OFFER_IMPORT_ROW_ID,
				EZGI_ID,
				PRODUCT_ID,
				STOCK_ID,
				SOURCE_DESCRIPTION,
				PREDICT_SUMMARY,
				MATCH_SCORE,
				MATCH_STATUS,
				NEEDS_MANUAL_SELECTION,
				IS_TRANSFERRED,
				RECORD_DATE,
				RECORD_EMP,
				RECORD_IP
			)
			VALUES
			(
				:virtualOfferId,
				:transferRowId,
				:offerRowId,
				:ezgiId,
				:productId,
				:stockId,
				:sourceDescription,
				:predictSummary,
				:matchScore,
				:matchStatus,
				:needsManualSelection,
				:isTransferred,
				GETDATE(),
				:recordEmp,
				:recordIp
			);

			SELECT CAST(SCOPE_IDENTITY() AS INT) AS PREDICT_ID;
			",
			{
				virtualOfferId = { value = arguments.virtualOfferId, cfsqltype = "cf_sql_numeric" },
				transferRowId = { value = val(getPreImportRow.TRANSFER_ROW_ID[1]), cfsqltype = "cf_sql_numeric", null = !val(getPreImportRow.TRANSFER_ROW_ID[1]) },
				offerRowId = { value = arguments.offerRowId, cfsqltype = "cf_sql_numeric" },
				ezgiId = { value = val(getPreImportRow.EZGI_ID[1]), cfsqltype = "cf_sql_numeric", null = !val(getPreImportRow.EZGI_ID[1]) },
				productId = { value = val(getPreImportRow.PRODUCT_ID[1]), cfsqltype = "cf_sql_numeric", null = !val(getPreImportRow.PRODUCT_ID[1]) },
				stockId = { value = val(getPreImportRow.STOCK_ID[1]), cfsqltype = "cf_sql_numeric", null = !val(getPreImportRow.STOCK_ID[1]) },
				sourceDescription = { value = getPreImportRow.PRODUCT_NAME2[1], cfsqltype = "cf_sql_varchar" },
				predictSummary = { value = arrayToList(summaryLines, chr(10)), cfsqltype = "cf_sql_longvarchar" },
				matchScore = { value = overallScore, cfsqltype = "cf_sql_decimal", scale = 2 },
				matchStatus = { value = overallStatus, cfsqltype = "cf_sql_varchar" },
				needsManualSelection = { value = needsManualSelection ? 1 : 0, cfsqltype = "cf_sql_bit" },
				isTransferred = { value = val(getPreImportRow.TRANSFER_ROW_ID[1]) ? 1 : 0, cfsqltype = "cf_sql_bit" },
				recordEmp = { value = session.ep.userid, cfsqltype = "cf_sql_numeric" },
				recordIp = { value = cgi.remote_addr, cfsqltype = "cf_sql_varchar" }
			},
			{ datasource = arguments.salesDatasourceName }
		);

		predictId = val(savePredict.PREDICT_ID[1]);
	}

	queryExecute(
		"
		DELETE FROM
			demo_ezgiyazilim_1.EZGI_VIRTUAL_OFFER_ROW_CONFIG_PREDICT_DETAIL
		WHERE
			PREDICT_ID = :predictId
		",
		{
			predictId = { value = predictId, cfsqltype = "cf_sql_numeric" }
		},
		{ datasource = arguments.salesDatasourceName }
	);

	for (detailItem in detailRows) {
		queryExecute(
			"
			INSERT INTO demo_ezgiyazilim_1.EZGI_VIRTUAL_OFFER_ROW_CONFIG_PREDICT_DETAIL
			(
				PREDICT_ID,
				QUESTION_ID,
				QUESTION_NAME,
				PIECE_ROW_ID,
				PIECE_TYPE,
				ALTERNATIVE_STOCK_ID,
				ALTERNATIVE_VALUE,
				MATCH_TEXT,
				MATCH_SCORE,
				MATCH_STATUS,
				IS_SELECTED,
				SORT_NO,
				RECORD_DATE,
				RECORD_EMP,
				RECORD_IP
			)
			VALUES
			(
				:predictId,
				:questionId,
				:questionName,
				:pieceRowId,
				:pieceType,
				:optionId,
				:optionName,
				:matchText,
				:matchScore,
				:matchStatus,
				:isSelected,
				:sortNo,
				GETDATE(),
				:recordEmp,
				:recordIp
			)
			",
			{
				predictId = { value = predictId, cfsqltype = "cf_sql_numeric" },
				questionId = { value = val(detailItem.question_id), cfsqltype = "cf_sql_numeric", null = !val(detailItem.question_id) },
				questionName = { value = detailItem.question_name, cfsqltype = "cf_sql_varchar" },
				pieceRowId = { value = 0, cfsqltype = "cf_sql_numeric", null = true },
				pieceType = { value = 0, cfsqltype = "cf_sql_numeric", null = true },
				optionId = { value = val(detailItem.option_id), cfsqltype = "cf_sql_numeric", null = !len(trim(detailItem.option_id & "")) },
				optionName = { value = detailItem.option_name, cfsqltype = "cf_sql_varchar", null = !len(trim(detailItem.option_name & "")) },
				matchText = { value = getPreImportRow.PRODUCT_NAME2[1], cfsqltype = "cf_sql_varchar", null = !len(trim(getPreImportRow.PRODUCT_NAME2[1] & "")) },
				matchScore = { value = detailItem.match_score, cfsqltype = "cf_sql_decimal", scale = 2 },
				matchStatus = { value = detailItem.match_status, cfsqltype = "cf_sql_varchar" },
				isSelected = { value = detailItem.is_selected ? 1 : 0, cfsqltype = "cf_sql_bit" },
				sortNo = { value = detailItem.sort_no, cfsqltype = "cf_sql_numeric" },
				recordEmp = { value = session.ep.userid, cfsqltype = "cf_sql_numeric" },
				recordIp = { value = cgi.remote_addr, cfsqltype = "cf_sql_varchar" }
			},
			{ datasource = arguments.salesDatasourceName }
		);
	}

	result.success = true;
	result.message = "Konfigürasyon tahmini kaydedildi.";
	result.predict_id = predictId;
	return result;
}

function saveConfigPredictionRows(
	required numeric virtualOfferId,
	required struct submittedAttributes,
	required string salesDatasourceName,
	required string setupDatasourceName
) {
	var resultList = [];
	var rowIndex = 0;
	var currentOfferRowId = 0;
	var selectedOfferRowList = "";

	if (
		!structKeyExists(arguments.submittedAttributes, "suggestion_offer_id_list") ||
		!len(trim(arguments.submittedAttributes.suggestion_offer_id_list & ""))
	) {
		return resultList;
	}

	if (
		!structKeyExists(arguments.submittedAttributes, "offer_row_id_list") ||
		!len(trim(arguments.submittedAttributes.offer_row_id_list & ""))
	) {
		return resultList;
	}

	selectedOfferRowList = trim(arguments.submittedAttributes.offer_row_id_list & "");

	for (rowIndex = 1; rowIndex <= listLen(arguments.submittedAttributes.suggestion_offer_id_list); rowIndex++) {
		currentOfferRowId = val(listGetAt(arguments.submittedAttributes.suggestion_offer_id_list, rowIndex));

		if (currentOfferRowId && listFind(selectedOfferRowList, currentOfferRowId)) {
			arrayAppend(
				resultList,
				saveConfigPredictionRow(
					arguments.virtualOfferId,
					currentOfferRowId,
					rowIndex,
					arguments.submittedAttributes,
					arguments.salesDatasourceName,
					arguments.setupDatasourceName
				)
			);
		}
	}

	return resultList;
}
</cfscript>

<cfif isdefined('attributes.process_type') and attributes.process_type eq -4><!---Pre-import Satir Resim Yükleme--->
	<cfsetting showdebugoutput="false">
	<cfheader statuscode="200" statustext="OK">
	<cfcontent type="application/json; charset=utf-8" reset="true">
	<cfset responseData = {
		success = false,
		message = "",
		file_name = "",
		file_path = ""
	}>
	<cfset tempSeparator = createObject("java", "java.io.File").separator>
	<cfset uploadTempDir = getTempDirectory() & "virtual_offer_row_image_upload" & tempSeparator>
	<cfset uploadedTempPath = "">
	<cfset uploadedExtension = "">
	<cfset saveResult = {success = false, file_path = "", file_name = "", error_message = ""}>

	<cftry>
		<cfif !isDefined("attributes.offer_row_id") or !len(trim(attributes.offer_row_id))>
			<cfthrow message="Satir bilgisi bulunamadi.">
		</cfif>

		<cfif !directoryExists(uploadTempDir)>
			<cfdirectory action="create" directory="#uploadTempDir#">
		</cfif>

		<cffile
			action="upload"
			fileField="row_image_file"
			destination="#uploadTempDir#"
			nameConflict="makeunique"
			mode="777">

		<cfset uploadedTempPath = cffile.serverDirectory & tempSeparator & cffile.serverFile>
		<cfset uploadedExtension = lCase(cffile.serverFileExt)>

		<cfif !listFindNoCase("jpg,jpeg,png,gif,bmp,webp", uploadedExtension)>
			<cfif len(uploadedTempPath) and fileExists(uploadedTempPath)>
				<cffile action="delete" file="#uploadedTempPath#">
			</cfif>
			<cfthrow message="Sadece resim dosyasi yukleyebilirsiniz.">
		</cfif>

		<cfset saveResult = saveImportImage(uploadedTempPath)>

		<cfif !saveResult.success>
			<cfthrow message="#saveResult.error_message#">
		</cfif>

		<cfquery name="upd_pre_import_image" datasource="#dsn3#">
			UPDATE
				EZGI_VIRTUAL_OFFER_ROW_PRE_IMPORT
			SET
				IMAGE_PATH = <cfqueryparam value="#saveResult.file_path#" cfsqltype="cf_sql_varchar">,
				IMAGE_NAME = <cfqueryparam value="#saveResult.file_name#" cfsqltype="cf_sql_varchar">
			WHERE
				VIRTUAL_OFFER_ROW_ID = <cfqueryparam value="#attributes.offer_row_id#" cfsqltype="cf_sql_numeric">
				AND VIRTUAL_OFFER_ID = <cfqueryparam value="#attributes.virtual_offer_id#" cfsqltype="cf_sql_numeric">
		</cfquery>

		<cfset responseData.success = true>
		<cfset responseData.message = "Resim basariyla yuklendi.">
		<cfset responseData.file_name = saveResult.file_name>
		<cfset responseData.file_path = saveResult.file_path>

		<cfcatch>
			<cfset responseData.success = false>
			<cfset responseData.message = cfcatch.message>
		</cfcatch>
	</cftry>

	<cfif len(uploadedTempPath) and fileExists(uploadedTempPath)>
		<cftry>
			<cffile action="delete" file="#uploadedTempPath#">
			<cfcatch>
				<!--- Temp cleanup hatasi, yukleme cevabini bozmasin. --->
			</cfcatch>
		</cftry>
	</cfif>

	<cfoutput>__ROW_IMAGE_UPLOAD_JSON_START__#serializeJSON(responseData)#__ROW_IMAGE_UPLOAD_JSON_END__</cfoutput>
	<cfabort>
<cfelseif isdefined('attributes.process_type') and attributes.process_type eq -2><!---Ürün Tanımlama İşlemi--->
	<cfset isAjaxProductDefine = isdefined('attributes.ajax_mode') and attributes.ajax_mode eq 1>
	<cfset configPredictionSaveResults = []>
	<cfif isAjaxProductDefine>
		<cfsetting showdebugoutput="false">
		<cfheader statuscode="200" statustext="OK">
		<cfcontent type="application/json; charset=utf-8" reset="true">
		<cfset responseData = {
			success = false,
			message = "",
			offer_row_id = "",
			stock_id = "",
			product_id = "",
			product_name = "",
			stock_code = "",
			unit = "",
			price = "",
			other_money = "",
			purchase_price = "",
			purchase_price_money = "",
			cost_price = "",
			cost_price_money = "",
			tax = "",
			price_cat_id = "",
			discount_1 = "",
			discount_2 = "",
			discount_3 = ""
		}>
	</cfif>
	<cftry>
	<cfquery name="get_sales_info" datasource="#dsn3#">
		SELECT 
			COMPANY_ID, 
			CONSUMER_ID
		FROM
			EZGI_VIRTUAL_OFFER
		WHERE
			VIRTUAL_OFFER_ID = #attributes.virtual_offer_id#
	</cfquery>
	<cfif get_sales_info.recordcount>
		<cfset attributes.company_id = get_sales_info.COMPANY_ID>
		<cfset attributes.consumer_id = get_sales_info.CONSUMER_ID>
	</cfif>
	<cfquery name="get_discount_row" datasource="#dsn3#"> <!---Cari için İskonto Bilgileri Bulunuyor--->
		<cfif isdefined('attributes.company_id') and len(attributes.company_id)>
			SELECT   
				TOP (1)
				ISNULL(PRODUCT_ID,0) PRODUCT_ID,
				ISNULL(BRAND_ID,0) BRAND_ID,  
				ISNULL(PRODUCT_CATID,0) PRODUCT_CATID, 
				ISNULL(DISCOUNT_RATE,0) AS DISCOUNT_RATE_1, 
				ISNULL(DISCOUNT_RATE_2,0) AS DISCOUNT_RATE_2,
				ISNULL(DISCOUNT_RATE_3,0) AS DISCOUNT_RATE_3,
				ISNULL(DISCOUNT_RATE_4,0) AS DISCOUNT_RATE_4,
				ISNULL(DISCOUNT_RATE_5,0) AS DISCOUNT_RATE_5
			FROM        
				PRICE_CAT_EXCEPTIONS WITH (NOLOCK)
			WHERE     
				ACT_TYPE = 1 AND 
				COMPANY_ID = #attributes.company_id# 
		 <cfelseif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
			SELECT   
				TOP (1)
				ISNULL(PRODUCT_ID,0) PRODUCT_ID,
				ISNULL(BRAND_ID,0) BRAND_ID,  
				ISNULL(PRODUCT_CATID,0) PRODUCT_CATID, 
				ISNULL(DISCOUNT_RATE,0) AS DISCOUNT_RATE_1, 
				ISNULL(DISCOUNT_RATE_2,0) AS DISCOUNT_RATE_2,
				ISNULL(DISCOUNT_RATE_3,0) AS DISCOUNT_RATE_3,
				ISNULL(DISCOUNT_RATE_4,0) AS DISCOUNT_RATE_4,
				ISNULL(DISCOUNT_RATE_5,0) AS DISCOUNT_RATE_5
			FROM        
				PRICE_CAT_EXCEPTIONS WITH (NOLOCK)
			WHERE     
				ACT_TYPE = 1 AND 
				CONSUMER_ID = #attributes.consumer_id#
		</cfif>
	</cfquery>
	<cfif get_discount_row.recordcount>
		<cfset disc1 = get_discount_row.DISCOUNT_RATE_1>
		<cfset disc2 = get_discount_row.DISCOUNT_RATE_2>
		<cfset disc3 = get_discount_row.DISCOUNT_RATE_3>
	<cfelse>
		<cfset disc1 = 0>
		<cfset disc2 = 0>
		<cfset disc3 = 0>
	</cfif>
	<cfloop from="1" to="#ListLen(attributes.suggestion_offer_id_list)#" index="offer_row_id">
		<cfif ListFind(attributes.offer_row_id_list, ListGetAt(attributes.suggestion_offer_id_list, offer_row_id))>
			<cfquery name="get_stock_info" datasource="#dsn3#">
				SELECT 
					S.STOCK_ID, 
					S.PRODUCT_NAME,
					S.STOCK_CODE, 
					PU.MAIN_UNIT,
					ISNULL(S.TAX,0) AS TAX,
					ISNULL(TBL.SALES_PRICE,0) AS SALES_PRICE, 
					ISNULL(TBL.SALES_PRICE_MONEY,'#session.ep.money#') AS SALES_PRICE_MONEY, 
					ISNULL(TBL.PURCHASE_PRICE,0) AS PURCHASE_PRICE, 
					ISNULL(TBL.PURCHASE_PRICE_MONEY,'#session.ep.money#') AS PURCHASE_PRICE_MONEY, 
					ISNULL(TBL.COST_PRICE,0) AS COST_PRICE, 
					ISNULL(TBL.COST_PRICE_MONEY,'#session.ep.money#') AS COST_PRICE_MONEY
				FROM     
					STOCKS AS S LEFT OUTER JOIN
					(
						SELECT 
							STOCK_ID, 
							SALES_PRICE, 
							SALES_PRICE_MONEY, 
							PURCHASE_PRICE, 
							PURCHASE_PRICE_MONEY, 
							COST_PRICE, 
							COST_PRICE_MONEY
						FROM      
							EZGI_VIRTUAL_OFFER_PRICE_ROW
						WHERE   
							PRICE_CAT_ID = #attributes.price_catid#
					) AS TBL ON S.STOCK_ID = TBL.STOCK_ID INNER JOIN
					PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
				WHERE  
					S.STOCK_ID = #Evaluate('attributes.STOCK_ID#offer_row_id#')#
			</cfquery>
			<cfquery name="upd_virtual_offer_row" datasource="#dsn3#">
				UPDATE
					EZGI_VIRTUAL_OFFER_ROW_PRE_IMPORT
				SET
					STOCK_ID = #Evaluate('attributes.STOCK_ID#offer_row_id#')#,
					PRODUCT_ID = #Evaluate('attributes.PID#offer_row_id#')#,
					PRICE_CAT_ID = #attributes.price_catid#,
					STOCK_CODE = '#get_stock_info.STOCK_CODE#',
					PRICE = #get_stock_info.SALES_PRICE#,
					OTHER_MONEY = '#get_stock_info.SALES_PRICE_MONEY#',
					PURCHASE_PRICE = #get_stock_info.PURCHASE_PRICE#,
					PURCHASE_PRICE_MONEY = '#get_stock_info.PURCHASE_PRICE_MONEY#',
					COST_PRICE = #get_stock_info.COST_PRICE#,
					COST_PRICE_MONEY = '#get_stock_info.COST_PRICE_MONEY#',
					TAX = #get_stock_info.TAX#,
					UNIT = '#get_stock_info.MAIN_UNIT#',
					DISCOUNT_1=#disc1#,
					DISCOUNT_2=#disc2#,
					DISCOUNT_3=#disc3#
				WHERE
					VIRTUAL_OFFER_ROW_ID = #ListGetAt(attributes.suggestion_offer_id_list, offer_row_id)#
			</cfquery>
			<cfset arrayAppend(
				configPredictionSaveResults,
				saveConfigPredictionRow(
					attributes.virtual_offer_id,
					ListGetAt(attributes.suggestion_offer_id_list, offer_row_id),
					offer_row_id,
					attributes,
					DSN3,
					DSN
				)
			)>
			<cfif isAjaxProductDefine>
				<cfset responseData.success = true>
				<cfset responseData.message = "Ürün Tanımlama İşlemi Başarıyla Tamamlanmıştır.!">
				<cfset responseData.offer_row_id = ListGetAt(attributes.suggestion_offer_id_list, offer_row_id)>
				<cfset responseData.stock_id = Evaluate('attributes.STOCK_ID#offer_row_id#')>
				<cfset responseData.product_id = Evaluate('attributes.PID#offer_row_id#')>
				<cfset responseData.product_name = get_stock_info.PRODUCT_NAME>
				<cfset responseData.stock_code = get_stock_info.STOCK_CODE>
				<cfset responseData.unit = get_stock_info.MAIN_UNIT>
				<cfset responseData.price = get_stock_info.SALES_PRICE>
				<cfset responseData.other_money = get_stock_info.SALES_PRICE_MONEY>
				<cfset responseData.purchase_price = get_stock_info.PURCHASE_PRICE>
				<cfset responseData.purchase_price_money = get_stock_info.PURCHASE_PRICE_MONEY>
				<cfset responseData.cost_price = get_stock_info.COST_PRICE>
				<cfset responseData.cost_price_money = get_stock_info.COST_PRICE_MONEY>
				<cfset responseData.tax = get_stock_info.TAX>
				<cfset responseData.price_cat_id = attributes.price_catid>
				<cfset responseData.discount_1 = disc1>
				<cfset responseData.discount_2 = disc2>
				<cfset responseData.discount_3 = disc3>
				<cfif arrayLen(configPredictionSaveResults)>
					<cfset responseData.config_predict_saved = configPredictionSaveResults[arrayLen(configPredictionSaveResults)].success>
					<cfset responseData.config_predict_message = configPredictionSaveResults[arrayLen(configPredictionSaveResults)].message>
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	<cfif isAjaxProductDefine>
		<cfoutput>__ROW_PRODUCT_DEFINE_JSON_START__#serializeJSON(responseData)#__ROW_PRODUCT_DEFINE_JSON_END__</cfoutput>
		<cfabort>
	<cfelse>
		<script type="text/javascript">
			alert("Ürün Tanımlama İşlemi Başarıyla Tamamlanmıştır.!");
		</script>
	</cfif>
	<cfcatch>
		<cfif isAjaxProductDefine>
			<cfset responseData.success = false>
			<cfset responseData.message = cfcatch.message>
			<cfoutput>__ROW_PRODUCT_DEFINE_JSON_START__#serializeJSON(responseData)#__ROW_PRODUCT_DEFINE_JSON_END__</cfoutput>
			<cfabort>
		<cfelse>
			<cfrethrow>
		</cfif>
	</cfcatch>
	</cftry>
<cfelseif isdefined('attributes.process_type') and attributes.process_type eq -7><!---Konfigürasyon Tahmini Kaydetme--->
	<cfsetting showdebugoutput="false">
	<cfheader statuscode="200" statustext="OK">
	<cfcontent type="application/json; charset=utf-8" reset="true">
	<cfset configPredictionSaveResults = []>
	<cfset configPredictionSaveSuccess = true>
	<cfset configPredictionSaveMessage = "Konfigürasyon tahmini kaydedildi.">
	<cfset configPredictionResponse = {success = false, message = "", results = []}>
	<cftry>
		<cfset configPredictionSaveResults = saveConfigPredictionRows(attributes.virtual_offer_id, attributes, DSN3, DSN)>
		<cfif !arrayLen(configPredictionSaveResults)>
			<cfset configPredictionSaveSuccess = false>
			<cfset configPredictionSaveMessage = "Kaydedilecek tahmin satırı bulunamadı.">
		<cfelse>
			<cfloop array="#configPredictionSaveResults#" index="configPredictionSaveItem">
				<cfif !configPredictionSaveItem.success>
					<cfset configPredictionSaveSuccess = false>
					<cfif structKeyExists(configPredictionSaveItem, "message") and len(trim(configPredictionSaveItem.message & ""))>
						<cfset configPredictionSaveMessage = trim(configPredictionSaveItem.message & "")>
					<cfelse>
						<cfset configPredictionSaveMessage = "Konfigürasyon tahmin kaydı başarısız döndü.">
					</cfif>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>
		<cfset configPredictionResponse.success = configPredictionSaveSuccess>
		<cfset configPredictionResponse.message = configPredictionSaveMessage>
		<cfset configPredictionResponse.results = configPredictionSaveResults>
		<cfoutput>__CONFIG_PREDICT_JSON_START__#serializeJSON(configPredictionResponse)#__CONFIG_PREDICT_JSON_END__</cfoutput>
		<cfabort>
	<cfcatch>
		<cfset configPredictionResponse.success = false>
		<cfset configPredictionResponse.message = trim((cfcatch.message & " " & cfcatch.detail))>
		<cfif !len(configPredictionResponse.message)>
			<cfset configPredictionResponse.message = "Konfigürasyon tahmini kaydı sırasında sunucu hatası oluştu.">
		</cfif>
		<cfset configPredictionResponse.results = []>
		<cfoutput>__CONFIG_PREDICT_JSON_START__#serializeJSON(configPredictionResponse)#__CONFIG_PREDICT_JSON_END__</cfoutput>
		<cfabort>
	</cfcatch>
	</cftry>
<cfelseif isdefined('attributes.process_type') and attributes.process_type eq -6><!---Transfer Edilmemis Pre-import Satirlari Silme--->
	<cfset deletedRowCount = 0>
	<cfset returnUrl = "#request.self#?fuseaction=prod.popup_list_ezgi_virtual_offer_row_import&virtual_offer_id=#attributes.virtual_offer_id#&is_filter=1">
	<cfif isdefined("attributes.keyword") and len(trim(attributes.keyword))>
		<cfset returnUrl &= "&keyword=#urlEncodedFormat(trim(attributes.keyword))#">
	</cfif>
	<cfif isdefined("attributes.is_related") and len(trim(attributes.is_related))>
		<cfset returnUrl &= "&is_related=#urlEncodedFormat(trim(attributes.is_related))#">
	</cfif>
	<cfif isdefined("attributes.price_catid") and len(trim(attributes.price_catid))>
		<cfset returnUrl &= "&price_catid=#urlEncodedFormat(trim(attributes.price_catid))#">
	</cfif>
	<cfif isdefined("attributes.maxrows") and len(trim(attributes.maxrows))>
		<cfset returnUrl &= "&maxrows=#urlEncodedFormat(trim(attributes.maxrows))#">
	</cfif>
	<cfif isdefined("attributes.page") and len(trim(attributes.page))>
		<cfset returnUrl &= "&page=#urlEncodedFormat(trim(attributes.page))#">
	</cfif>

	<cftry>
		<cfif !isdefined("attributes.delete_offer_row_id_list") or !len(trim(attributes.delete_offer_row_id_list))>
			<cfthrow message="Silinecek satır bulunamadı.">
		</cfif>

		<cfquery name="get_delete_rows" datasource="#dsn3#">
			SELECT
				PRI.VIRTUAL_OFFER_ROW_ID,
				PRI.IMAGE_PATH
			FROM
				EZGI_VIRTUAL_OFFER_ROW_PRE_IMPORT PRI
			WHERE
				PRI.VIRTUAL_OFFER_ID = <cfqueryparam value="#attributes.virtual_offer_id#" cfsqltype="cf_sql_numeric">
				AND PRI.VIRTUAL_OFFER_ROW_ID IN (
					<cfqueryparam value="#attributes.delete_offer_row_id_list#" cfsqltype="cf_sql_numeric" list="true">
				)
				AND NOT EXISTS (
					SELECT
						1
					FROM
						EZGI_VIRTUAL_OFFER_ROW EIR
					WHERE
						EIR.VIRTUAL_OFFER_IMPORT_ROW_ID = PRI.VIRTUAL_OFFER_ROW_ID
				)
		</cfquery>

		<cfif get_delete_rows.recordcount>
			<cfquery name="del_pre_import_rows" datasource="#dsn3#">
				DELETE FROM
					EZGI_VIRTUAL_OFFER_ROW_PRE_IMPORT
				WHERE
					VIRTUAL_OFFER_ID = <cfqueryparam value="#attributes.virtual_offer_id#" cfsqltype="cf_sql_numeric">
					AND VIRTUAL_OFFER_ROW_ID IN (
						<cfqueryparam value="#ValueList(get_delete_rows.VIRTUAL_OFFER_ROW_ID)#" cfsqltype="cf_sql_numeric" list="true">
					)
			</cfquery>

			<cfloop query="get_delete_rows">
				<cfif len(trim(get_delete_rows.IMAGE_PATH)) and fileExists(trim(get_delete_rows.IMAGE_PATH))>
					<cftry>
						<cffile action="delete" file="#trim(get_delete_rows.IMAGE_PATH)#">
						<cfcatch>
							<!--- Resim silinemezse satır silme işlemini bozmasın. --->
						</cfcatch>
					</cftry>
				</cfif>
			</cfloop>

			<cfset deletedRowCount = get_delete_rows.recordcount>
		</cfif>

		<script type="text/javascript">
			alert("<cfoutput>#deletedRowCount#</cfoutput> Satır Silindi.");
			window.location = "<cfoutput>#JSStringFormat(returnUrl)#</cfoutput>";
		</script>
		<cfabort>
	<cfcatch>
		<script type="text/javascript">
			alert("<cfoutput>#JSStringFormat(cfcatch.message)#</cfoutput>");
			window.location = "<cfoutput>#JSStringFormat(returnUrl)#</cfoutput>";
		</script>
		<cfabort>
	</cfcatch>
	</cftry>
<cfelseif isdefined('attributes.process_type') and attributes.process_type eq -3><!---Sanal Teklife Aktarım--->
	<cfloop from="1" to="#ListLen(attributes.suggestion_offer_id_list)#" index="offer_row_id">
		<cfif ListFind(attributes.offer_row_id_list, ListGetAt(attributes.suggestion_offer_id_list, offer_row_id))>
			<cfquery name="get_virtual_offer_row_import_file" datasource="#dsn3#">
				SELECT 
					*
				FROM
					EZGI_VIRTUAL_OFFER_ROW_PRE_IMPORT
				WHERE
					VIRTUAL_OFFER_ROW_ID = #ListGetAt(attributes.suggestion_offer_id_list, offer_row_id)#
			</cfquery>
			<script type="text/javascript">
				<cfoutput>
					opener.add_row(#get_virtual_offer_row_import_file.STOCK_ID#,'#get_virtual_offer_row_import_file.PRODUCT_NAME#','#get_virtual_offer_row_import_file.STOCK_CODE#','#get_virtual_offer_row_import_file.PRODUCT_CODE_2#','#get_virtual_offer_row_import_file.UNIT#','#get_virtual_offer_row_import_file.PRODUCT_ID#','#get_virtual_offer_row_import_file.PRICE#','#get_virtual_offer_row_import_file.OTHER_MONEY#','0','0','0','#get_virtual_offer_row_import_file.PURCHASE_PRICE#','#get_virtual_offer_row_import_file.PURCHASE_PRICE_MONEY#','#get_virtual_offer_row_import_file.COST_PRICE#','#get_virtual_offer_row_import_file.COST_PRICE_MONEY#',#get_virtual_offer_row_import_file.TAX#,#attributes.price_catid#,#get_virtual_offer_row_import_file.DISCOUNT_1#,#get_virtual_offer_row_import_file.DISCOUNT_2#,#get_virtual_offer_row_import_file.DISCOUNT_3#,);
				</cfoutput>
			</script>
		</cfif>
	</cfloop>
	<script type="text/javascript">
		alert("Aktarım Başarıyla Tamamlanmıştır.!");
	</script> 
<cfelse><!---Excelden Dosya Aktarım--->
	<cfset upload_folder = "#upload_folder#temp#dir_seperator#">
	<cfset uploadedFilePath = "">
	<cfset imageExtractResult = {images = [], extract_dir = "", success = false, error_message = ""}>
	<cfset rowsArray = []>
	<cfset imageRowMap = []>
	<cftry>
		<cffile action = "upload" 
			fileField = "uploaded_file" 
			destination = "#upload_folder#"
			nameConflict = "MakeUnique"  
			mode="777">
		<cfset file_name = "#createUUID()#.#cffile.serverfileext#">	
		<cffile action="rename" source="#upload_folder##cffile.serverfile#" destination="#upload_folder##file_name#">	
		<cfset uploadedFilePath = "#upload_folder##file_name#">
		<cfset file_size = cffile.filesize>
		<cfcatch type="Any">
			<cfoutput>#cfcatch.detail#</cfoutput>
			<cfabort>
		</cfcatch>  
	</cftry>

	<cftry>
		<cfspreadsheet action="read" src="#uploadedFilePath#" query="excel_file_ham" sheetname ="IMPORT" headerrow ="1" rows="2-10000">
		<cfcatch>
			<script type="text/javascript">
				alert("<cfoutput>#getLang('ehesap',1112)#</cfoutput>.");
				history.back();
			</script>
			<cfabort>
		</cfcatch>
	</cftry>

	<cfset imageExtractResult = extractExcelImages(uploadedFilePath)>

	<cfif structKeyExists(imageExtractResult, "images") and arrayLen(imageExtractResult.images)>
		<cfloop from="1" to="#arrayLen(imageExtractResult.images)#" index="imageIndex">
			<cfif
				structKeyExists(imageExtractResult.images[imageIndex], "file_path") and
				len(trim(imageExtractResult.images[imageIndex].file_path))
			>
				<cfset savedImageResult = saveImportImage(imageExtractResult.images[imageIndex].file_path)>
				<cfif savedImageResult.success>
					<cfset imageExtractResult.images[imageIndex].file_path = savedImageResult.file_path>
					<cfset imageExtractResult.images[imageIndex].file_name = savedImageResult.file_name>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>

	<cfif excel_file_ham.recordcount>
		<cfloop query="excel_file_ham">
			<cfset arrayAppend(rowsArray, {row_no = currentrow, excel_row_no = currentrow + 1})>
		</cfloop>
	</cfif>

	<cfset imageRowMap = mapImagesToRows(rowsArray, imageExtractResult.images)>

	<cfif excel_file_ham.recordcount>
		<cfloop query="excel_file_ham">
			<cfset currentImagePath = "">
			<cfset currentImageName = "">
			<cfif arrayLen(imageRowMap) gte currentrow>
				<cfset currentImagePath = imageRowMap[currentrow].image_path>
				<cfif structKeyExists(imageRowMap[currentrow], "image_name")>
					<cfset currentImageName = imageRowMap[currentrow].image_name>
				</cfif>
			</cfif>
			<!---Product_Name Zorunlu--->
			<cfif not len(excel_file_ham.Product_Name)>
				<script type="text/javascript">
					alert("#currentrow#. Satırda Product_Name Belirtilmemiş!");
					window.history.go(-1);
				</script>
				<cfabort>
			</cfif>
			<!---Quantity Zorunlu--->
			<cfif not len(excel_file_ham.Quantity)>
				<script type="text/javascript">
					alert("#currentrow#. Satırda Quantity Belirtilmemiş!");
					window.history.go(-1);
				</script>
				<cfabort>
			<cfelse>
				<cfif not isnumeric(excel_file_ham.Quantity)>
					<script type="text/javascript">
						alert("#currentrow#. Satırda Quantity Alanı Sayısal Olmalıdır.!");
						window.history.go(-1);
					</script>
					<cfabort>
				</cfif>
			</cfif>
			<cfquery name="add_virtual_offer_row" datasource="#dsn3#">
				INSERT INTO 
					EZGI_VIRTUAL_OFFER_ROW_PRE_IMPORT
					(
						VIRTUAL_OFFER_ID, 
						PRODUCT_NAME, 
						QUANTITY, 
						PRODUCT_NAME2, 
						DIM, 
						LOCATION_AREA, 
						URL,
						IMAGE_PATH,
						IMAGE_NAME
					)
				VALUES 
					(
						<cfqueryparam value="#attributes.virtual_offer_id#" cfsqltype="cf_sql_numeric">,
						<cfqueryparam value="#excel_file_ham.PRODUCT_NAME#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#excel_file_ham.QUANTITY#" cfsqltype="cf_sql_numeric">,
						<cfqueryparam value="#trim(excel_file_ham.Description)#" cfsqltype="cf_sql_varchar" null="#not len(trim(excel_file_ham.Description))#">,
						<cfqueryparam value="#trim(excel_file_ham.Dimention)#" cfsqltype="cf_sql_varchar" null="#not len(trim(excel_file_ham.Dimention))#">,
						<cfqueryparam value="#trim(excel_file_ham.Area)#" cfsqltype="cf_sql_varchar" null="#not len(trim(excel_file_ham.Area))#">,
						<cfqueryparam value="#trim(excel_file_ham.URL)#" cfsqltype="cf_sql_varchar" null="#not len(trim(excel_file_ham.URL))#">,
						<cfqueryparam value="#currentImagePath#" cfsqltype="cf_sql_varchar" null="#not len(currentImagePath)#">,
						<cfqueryparam value="#currentImageName#" cfsqltype="cf_sql_varchar" null="#not len(currentImageName)#">
					)
			</cfquery>
		</cfloop>
	</cfif>
	<script type="text/javascript">
		alert("Aktarım Başarıyla Tamamlanmıştır.!");
	</script> 
</cfif>
<cflocation url="#request.self#?fuseaction=prod.popup_list_ezgi_virtual_offer_row_import&virtual_offer_id=#attributes.virtual_offer_id#" addtoken="No">   