<cfscript>
function normalizeText(required string text) {
	var normalized = lCase(trim(text));

	if (!len(normalized)) {
		return "";
	}

	normalized = replaceList(normalized, "ç,ğ,ı,ö,ş,ü", "c,g,i,o,s,u");
	normalized = reReplace(normalized, "[-_.]", " ", "all");
	normalized = reReplace(normalized, "[^a-z0-9\s]", " ", "all");
	normalized = reReplace(normalized, "\s+", " ", "all");

	return trim(normalized);
}

function parseDimensions(string dimensionText = "", string descriptionText = "") {
	var dims = createEmptyDimensions();
	var sources = [];

	if (len(trim(dimensionText))) {
		arrayAppend(sources, trim(dimensionText));
	}

	if (len(trim(descriptionText))) {
		arrayAppend(sources, trim(descriptionText));
	}

	for (var source in sources) {
		dims = parseLabeledDimensions(source);
		if (hasDimensions(dims)) {
			return dims;
		}

		dims = parseDelimitedDimensions(source);
		if (hasDimensions(dims)) {
			return dims;
		}

		dims = parseNumberSequenceDimensions(source);
		if (hasDimensions(dims)) {
			return dims;
		}
	}

	return createEmptyDimensions();
}

function parseDescription(string descriptionText = "") {
	var materials = {};
	var normalizedDescription = lCase(trim(descriptionText));
	var parts = [];

	if (!len(normalizedDescription)) {
		return materials;
	}

	normalizedDescription = replaceList(normalizedDescription, "ç,ğ,ı,ö,ş,ü", "c,g,i,o,s,u");
	normalizedDescription = reReplace(normalizedDescription, "[^a-z0-9,\s]", " ", "all");
	normalizedDescription = reReplace(normalizedDescription, "\s+", " ", "all");
	parts = listToArray(normalizedDescription, ",");

	for (var part in parts) {
		var itemText = trim(part);
		var words = [];

		if (!len(itemText)) {
			continue;
		}

		words = listToArray(itemText, " ");

		if (arrayLen(words) gte 2) {
			if (findNoCase("kumas", itemText)) {
				materials["kumas"] = words[1];
			}

			if (findNoCase("ahsap", itemText)) {
				materials["ahsap"] = words[1];
			}

			if (findNoCase("metal", itemText)) {
				materials["metal"] = words[1];
			}
		}
	}

	return materials;
}

function normalizeImportRow(required struct rowStruct) {
	var dimensionSource = getFirstRowValue(rowStruct, ["dimension", "dimention", "dimensions", "dim", "size", "measure"]);
	var descriptionSource = getFirstRowValue(rowStruct, ["description", "aciklama", "product_name2"]);

	return {
		product_name = normalizeText(getFirstRowValue(rowStruct, ["product_name", "product", "urun_adi", "name"])),
		quantity = normalizeQuantity(getFirstRowValue(rowStruct, ["quantity", "qty", "adet", "miktar"])),
		dimensions = parseDimensions(dimensionSource, descriptionSource),
		materials = parseDescription(descriptionSource),
		area = trim(getFirstRowValue(rowStruct, ["area", "location_area", "mekan"]))
	};
}

function matchImportProduct(required string normalizedProductName, required query productsQuery) {
	var searchRaw = trim(normalizedProductName);
	var searchNormalized = normalizeText(normalizedProductName);
	var bestMatch = {
		match_status = "none",
		match_score = 0,
		stock_id = "",
		product_id = "",
		product_name = "",
		product_code = "",
		note = "Eslesme bulunamadi",
		display_status = "none",
		display_text = "Öneri bulunamadı"
	};
	var searchWords = [];

	if (!len(searchRaw) || !productsQuery.recordCount) {
		return bestMatch;
	}

	searchWords = listToArray(searchNormalized, " ");

	for (var rowIndex = 1; rowIndex <= productsQuery.recordCount; rowIndex++) {
		var candidateName = trim(productsQuery.PRODUCT_NAME[rowIndex] & "");
		var candidateCode = trim(productsQuery.PRODUCT_CODE[rowIndex] & "");

		if (searchRaw == candidateName) {
			return {
				match_status = "exact",
				match_score = 100,
				stock_id = productsQuery.STOCK_ID[rowIndex],
				product_id = productsQuery.PRODUCT_ID[rowIndex],
				product_name = candidateName,
				product_code = candidateCode,
				note = "Ürün Adı Birebir Eşleşti",
				display_status = "exact",
				display_text = "Tam eşleşme bulundu"
			};
		}
	}

	for (var rowIndex = 1; rowIndex <= productsQuery.recordCount; rowIndex++) {
		var candidateName = trim(productsQuery.PRODUCT_NAME[rowIndex] & "");
		var candidateCode = trim(productsQuery.PRODUCT_CODE[rowIndex] & "");
		var candidateNormalized = normalizeText(candidateName);

		if (searchNormalized == candidateNormalized) {
			return {
				match_status = "normalized",
				match_score = 90,
				stock_id = productsQuery.STOCK_ID[rowIndex],
				product_id = productsQuery.PRODUCT_ID[rowIndex],
				product_name = candidateName,
				product_code = candidateCode,
				note = "Normalize Edilmiş Ürün Adları Eşleşti",
				display_status = "strong",
				display_text = "Güçlü Benzer Eşleşme"
			};
		}
	}

	for (var rowIndex = 1; rowIndex <= productsQuery.recordCount; rowIndex++) {
		var candidateName = trim(productsQuery.PRODUCT_NAME[rowIndex] & "");
		var candidateCode = trim(productsQuery.PRODUCT_CODE[rowIndex] & "");
		var candidateNormalized = normalizeText(candidateName);
		var candidateWords = listToArray(candidateNormalized, " ");
		var commonCount = 0;
		var rootMatchCount = 0;
		var score = 0;
		var extraWordPenalty = 0;
		var bestWordCount = 0;

		if (!len(candidateNormalized)) {
			continue;
		}

		for (var searchWord in searchWords) {
			if (len(searchWord) && listFindNoCase(candidateNormalized, searchWord, " ")) {
				commonCount++;
			}

			for (var candidateWord in candidateWords) {
				var prefixLength = 0;
				var minWordLength = min(len(searchWord), len(candidateWord));

				if (!len(searchWord) || !len(candidateWord) || searchWord == candidateWord) {
					continue;
				}

				while (
					prefixLength < minWordLength &&
					mid(searchWord, prefixLength + 1, 1) == mid(candidateWord, prefixLength + 1, 1)
				) {
					prefixLength++;
				}

				if (
					prefixLength >= 4 ||
					(
						prefixLength >= 3 &&
						(
							left(searchWord, len(candidateWord)) == candidateWord ||
							left(candidateWord, len(searchWord)) == searchWord
						)
					)
				) {
					rootMatchCount++;
					break;
				}
			}
		}

		if (arrayLen(searchWords)) {
			score += int((commonCount / arrayLen(searchWords)) * 45);
			score += int((rootMatchCount / arrayLen(searchWords)) * 20);
		}

		if (commonCount gte 1 && rootMatchCount gte 1 && arrayLen(candidateWords) == arrayLen(searchWords)) {
			score += 15;
		}

		if (findNoCase(searchNormalized, candidateNormalized) || findNoCase(candidateNormalized, searchNormalized)) {
			score += 15;
		}

		if (
			left(candidateNormalized, len(searchNormalized)) == searchNormalized ||
			left(searchNormalized, len(candidateNormalized)) == candidateNormalized
		) {
			score += 10;
		}

		if (commonCount gt 0 && rootMatchCount gt 0) {
			score += 20;
		}

		if (arrayLen(candidateWords) gt arrayLen(searchWords)) {
			extraWordPenalty = (arrayLen(candidateWords) - arrayLen(searchWords)) * 12;
			score -= extraWordPenalty;
		}

		if (score lt 0) {
			score = 0;
		}

		if (score > 89) {
			score = 89;
		}

		bestWordCount = len(bestMatch.product_name) ? listLen(normalizeText(bestMatch.product_name), " ") : 999;

		if (
			score >= 50 &&
			(
				score > bestMatch.match_score ||
				(
					score == bestMatch.match_score &&
					arrayLen(candidateWords) lt bestWordCount
				)
			)
		) {
			var displayStatus = "possible";
			var displayText = "Benzer eşleşme";

			if (score gte 70) {
				displayStatus = "strong";
				displayText = "Benzer eşleşme";
			}

			bestMatch = {
				match_status = "fuzzy",
				match_score = score,
				stock_id = productsQuery.STOCK_ID[rowIndex],
				product_id = productsQuery.PRODUCT_ID[rowIndex],
				product_name = candidateName,
				product_code = candidateCode,
				note = "Kelime ortakligi ve kok benzerligi ile onerildi",
				display_status = displayStatus,
				display_text = displayText
			};
		}
	}

	return bestMatch;
}

function normalizeQuantity(quantityValue) {
	var rawValue = trim(toStringValue(quantityValue));
	var matches = [];

	if (!len(rawValue)) {
		return 1;
	}

	if (isNumeric(rawValue)) {
		return val(replace(rawValue, ",", ".", "all"));
	}

	matches = reMatch("[0-9]+(?:[.,][0-9]+)?", rawValue);

	if (arrayLen(matches)) {
		return val(replace(matches[1], ",", ".", "all"));
	}

	return 1;
}

function getFirstRowValue(required struct rowStruct, required array keys) {
	for (var keyName in keys) {
		if (structKeyExists(rowStruct, keyName)) {
			return toStringValue(rowStruct[keyName]);
		}
	}

	return "";
}

function toStringValue(any value = "") {
	if (isNull(arguments.value)) {
		return "";
	}

	if (isSimpleValue(arguments.value)) {
		return trim(arguments.value & "");
	}

	return "";
}

function createEmptyDimensions() {
	return {
		width = 0,
		height = 0,
		depth = 0
	};
}

function hasDimensions(required struct dims) {
	return (dims.width gt 0) || (dims.height gt 0) || (dims.depth gt 0);
}

function parseLabeledDimensions(required string sourceText) {
	var dims = createEmptyDimensions();
	var parts = listToArray(sourceText, ";");

	for (var part in parts) {
		var entry = trim(part);

		if (!find(":", entry)) {
			continue;
		}

		var keyValue = listToArray(entry, ":");

		if (arrayLen(keyValue) lt 2) {
			continue;
		}

		var axisKey = uCase(trim(keyValue[1]));
		var axisValue = extractFirstNumber(keyValue[2]);

		switch (axisKey) {
			case "G":
				dims.width = axisValue;
				break;
			case "Y":
				dims.height = axisValue;
				break;
			case "D":
				dims.depth = axisValue;
				break;
		}
	}

	return dims;
}

function parseDelimitedDimensions(required string sourceText) {
	var dims = createEmptyDimensions();
	var normalized = reReplaceNoCase(sourceText, "\s*[x]\s*", "x", "all");
	var parts = listToArray(normalized, "x");

	if (arrayLen(parts) gte 3) {
		dims.width = extractFirstNumber(parts[1]);
		dims.height = extractFirstNumber(parts[2]);
		dims.depth = extractFirstNumber(parts[3]);
	}

	return dims;
}

function parseNumberSequenceDimensions(required string sourceText) {
	var dims = createEmptyDimensions();
	var matches = reMatch("[0-9]+(?:[.,][0-9]+)?", sourceText);

	if (arrayLen(matches) gte 3) {
		dims.width = extractFirstNumber(matches[1]);
		dims.height = extractFirstNumber(matches[2]);
		dims.depth = extractFirstNumber(matches[3]);
	}

	return dims;
}

function extractFirstNumber(any rawValue = "") {
	var textValue = trim(toStringValue(rawValue));
	var matches = [];

	if (!len(textValue)) {
		return 0;
	}

	if (isNumeric(textValue)) {
		return val(replace(textValue, ",", ".", "all"));
	}

	matches = reMatch("[0-9]+(?:[.,][0-9]+)?", textValue);

	if (arrayLen(matches)) {
		return val(replace(matches[1], ",", ".", "all"));
	}

	return 0;
}

function getConfigPrediction(required numeric stockId, string descriptionText = "", required string datasourceName, string setupDatasourceName = "") {
	var result = {
		summary_text = "",
		summary_html = "",
		match_status = "none",
		needs_manual_selection = false,
		total_questions = 0,
		matched_questions = 0,
		details = []
	};
	var optionGroups = getConfigOptionGroups(arguments.stockId, arguments.datasourceName, arguments.setupDatasourceName);
	var summaryLines = [];

	if (!arrayLen(optionGroups)) {
		return result;
	}

	for (var group in optionGroups) {
		var predictionDetail = matchConfigOptionGroup(group, arguments.descriptionText);
		arrayAppend(result.details, predictionDetail);
		arrayAppend(summaryLines, predictionDetail.display_text);
		result.total_questions++;

		if (predictionDetail.match_status != "none") {
			result.matched_questions++;
		} else {
			result.needs_manual_selection = true;
		}
	}

	result.summary_text = arrayToList(summaryLines, chr(10));
	result.summary_html = arrayToList(summaryLines, "<br>");

	if (result.matched_questions eq 0) {
		result.match_status = "none";
	} else if (!result.needs_manual_selection) {
		result.match_status = "exact";
	} else {
		result.match_status = "mixed";
	}

	return result;
}

function getConfigOptionGroups(required numeric stockId, required string datasourceName, string setupDatasourceName = "") {
	var cache = {};
	var cacheKey = trim(arguments.stockId & "");
	var pieceRows = queryNew("");
	var questionQuery = queryNew("");
	var groupsByKey = {};
	var orderedGroups = [];
	var pieceRowIdList4 = [];
	var pieceRowIdListOther = [];
	var pieceGroupMap = {};
	var questionIdList = [];
	var questionNameMap = {};
	var stockAlternatives = queryNew("");
	var pieceAlternatives = queryNew("");

	if (!structKeyExists(request, "virtualOfferConfigOptionCache")) {
		request.virtualOfferConfigOptionCache = {};
	}

	cache = request.virtualOfferConfigOptionCache;

	if (structKeyExists(cache, cacheKey)) {
		return duplicate(cache[cacheKey]);
	}

	pieceRows = queryExecute(
		"
		SELECT
			TBL.PIECE_ROW_ID,
			TBL.PIECE_TYPE,
			TBL.QUESTION_ID
		FROM
			(
				SELECT
					EDPP.PIECE_ROW_ID,
					EDPP.PIECE_TYPE,
					EDPT.QUESTION_ID
				FROM
					EZGI_DESIGN_PACKAGE EDP
					INNER JOIN EZGI_DESIGN_PIECE EDPP ON EDP.PACKAGE_ROW_ID = EDPP.DESIGN_PACKAGE_ROW_ID
					LEFT OUTER JOIN EZGI_DESIGN_PIECE_PROTOTIP EDPT ON EDPP.PIECE_ROW_ID = EDPT.PIECE_ROW_ID
				WHERE
					EDP.DESIGN_MAIN_ROW_ID = (
						SELECT TOP (1)
							DESIGN_MAIN_ROW_ID
						FROM
							EZGI_DESIGN_MAIN_ROW
						WHERE
							DESIGN_MAIN_RELATED_ID = :stockId
							AND DESIGN_MAIN_STATUS = 1
							AND MAIN_PROTOTIP_TYPE = 1
						ORDER BY
							DESIGN_MAIN_ROW_ID
					)
					AND EDPP.PIECE_TYPE <> 3
				UNION ALL
				SELECT
					EDPRR.PIECE_ROW_ID,
					EDPRR.PIECE_TYPE,
					EDPT.QUESTION_ID
				FROM
					EZGI_DESIGN_PACKAGE EDP
					INNER JOIN EZGI_DESIGN_PIECE EDPP ON EDP.PACKAGE_ROW_ID = EDPP.DESIGN_PACKAGE_ROW_ID
					INNER JOIN EZGI_DESIGN_PIECE_ROW EDPR ON EDPP.PIECE_ROW_ID = EDPR.PIECE_ROW_ID
					INNER JOIN EZGI_DESIGN_PIECE_ROWS EDPRR ON EDPR.RELATED_PIECE_ROW_ID = EDPRR.PIECE_ROW_ID
					LEFT OUTER JOIN EZGI_DESIGN_PIECE_PROTOTIP EDPT ON EDPRR.PIECE_ROW_ID = EDPT.PIECE_ROW_ID
				WHERE
					EDP.DESIGN_MAIN_ROW_ID = (
						SELECT TOP (1)
							DESIGN_MAIN_ROW_ID
						FROM
							EZGI_DESIGN_MAIN_ROW
						WHERE
							DESIGN_MAIN_RELATED_ID = :stockId
							AND DESIGN_MAIN_STATUS = 1
							AND MAIN_PROTOTIP_TYPE = 1
						ORDER BY
							DESIGN_MAIN_ROW_ID
					)
					AND EDPP.PIECE_TYPE = 3
			) AS TBL
		WHERE
			TBL.QUESTION_ID IS NOT NULL
		ORDER BY
			TBL.QUESTION_ID,
			TBL.PIECE_ROW_ID
		",
		{
			stockId = { value = arguments.stockId, cfsqltype = "cf_sql_numeric" }
		},
		{ datasource = arguments.datasourceName }
	);

	for (var questionIndex = 1; questionIndex <= pieceRows.recordCount; questionIndex++) {
		var questionIdValue = trim(pieceRows.QUESTION_ID[questionIndex] & "");

		if (len(questionIdValue) && !arrayFind(questionIdList, questionIdValue)) {
			arrayAppend(questionIdList, questionIdValue);
		}
	}

	if (arrayLen(questionIdList) && len(arguments.setupDatasourceName)) {
		questionQuery = queryExecute(
			"
			SELECT
				QUESTION_ID,
				QUESTION_NAME
			FROM
				SETUP_ALTERNATIVE_QUESTIONS
			WHERE
				QUESTION_ID IN (:questionIds)
			",
			{
				questionIds = { value = arrayToList(questionIdList), cfsqltype = "cf_sql_numeric", list = true }
			},
			{ datasource = arguments.setupDatasourceName }
		);

		for (var questionRowIndex = 1; questionRowIndex <= questionQuery.recordCount; questionRowIndex++) {
			questionNameMap[trim(questionQuery.QUESTION_ID[questionRowIndex] & "")] = toStringValue(questionQuery.QUESTION_NAME[questionRowIndex]);
		}
	}

	for (var rowIndex = 1; rowIndex <= pieceRows.recordCount; rowIndex++) {
		var questionKey = trim(pieceRows.QUESTION_ID[rowIndex] & "");
		var pieceRowId = val(pieceRows.PIECE_ROW_ID[rowIndex]);
		var pieceType = val(pieceRows.PIECE_TYPE[rowIndex]);

		if (!len(questionKey)) {
			continue;
		}

		if (!structKeyExists(groupsByKey, questionKey)) {
			groupsByKey[questionKey] = {
				question_id = val(pieceRows.QUESTION_ID[rowIndex]),
				question_name = structKeyExists(questionNameMap, questionKey) ? questionNameMap[questionKey] : ("Soru " & questionKey),
				options = [],
				option_map = {}
			};
			arrayAppend(orderedGroups, groupsByKey[questionKey]);
		}

		pieceGroupMap[pieceRowId] = questionKey;

		if (pieceType eq 4) {
			arrayAppend(pieceRowIdList4, pieceRowId);
		} else {
			arrayAppend(pieceRowIdListOther, pieceRowId);
		}
	}

	if (arrayLen(pieceRowIdList4)) {
		stockAlternatives = queryExecute(
			"
			SELECT
				PIECE_ROW_ID,
				ALTERNATIVE_STOCK_ID AS OPTION_ID,
				PRODUCT_NAME AS OPTION_NAME
			FROM
				EZGI_DESIGN_ALTERNATIVE_STOCKS
			WHERE
				PIECE_ROW_ID IN (:pieceRowIds)
				AND ISNULL(IS_SPECIAL_MEASURE, 0) = 0
			ORDER BY
				PIECE_ROW_ID,
				PRODUCT_NAME
			",
			{
				pieceRowIds = { value = arrayToList(pieceRowIdList4), cfsqltype = "cf_sql_numeric", list = true }
			},
			{ datasource = arguments.datasourceName }
		);

		appendConfigOptionsToGroups(stockAlternatives, pieceGroupMap, groupsByKey);
	}

	if (arrayLen(pieceRowIdListOther)) {
		pieceAlternatives = queryExecute(
			"
			SELECT
				PIECE_ROW_ID,
				ALTERNATIVE_PIECE_ROW_ID AS OPTION_ID,
				PIECE_NAME AS OPTION_NAME
			FROM
				EZGI_DESGIN_ALTERNATIVE_PIECE
			WHERE
				PIECE_ROW_ID IN (:pieceRowIds)
				AND ISNULL(IS_SPECIAL_MEASURE, 0) = 0
			ORDER BY
				PIECE_ROW_ID,
				PIECE_NAME
			",
			{
				pieceRowIds = { value = arrayToList(pieceRowIdListOther), cfsqltype = "cf_sql_numeric", list = true }
			},
			{ datasource = arguments.datasourceName }
		);

		appendConfigOptionsToGroups(pieceAlternatives, pieceGroupMap, groupsByKey);
	}

	for (var groupItem in orderedGroups) {
		structDelete(groupItem, "option_map", false);
	}

	cache[cacheKey] = duplicate(orderedGroups);
	request.virtualOfferConfigOptionCache = cache;

	return duplicate(orderedGroups);
}

function appendConfigOptionsToGroups(required query optionsQuery, required struct pieceGroupMap, required struct groupsByKey) {
	for (var rowIndex = 1; rowIndex <= arguments.optionsQuery.recordCount; rowIndex++) {
		var pieceRowId = val(arguments.optionsQuery.PIECE_ROW_ID[rowIndex]);
		var optionId = trim(arguments.optionsQuery.OPTION_ID[rowIndex] & "");
		var optionName = toStringValue(arguments.optionsQuery.OPTION_NAME[rowIndex]);
		var questionKey = "";

		if (!structKeyExists(arguments.pieceGroupMap, pieceRowId)) {
			continue;
		}

		questionKey = arguments.pieceGroupMap[pieceRowId];

		if (
			!structKeyExists(arguments.groupsByKey, questionKey) ||
			!len(optionId) ||
			!len(optionName)
		) {
			continue;
		}

		if (!structKeyExists(arguments.groupsByKey[questionKey].option_map, optionId)) {
			arguments.groupsByKey[questionKey].option_map[optionId] = true;
			arrayAppend(arguments.groupsByKey[questionKey].options, {
				option_id = optionId,
				option_name = optionName
			});
		}
	}
}

function matchConfigOptionGroup(required struct optionGroup, string descriptionText = "") {
	var bestMatch = {
		question_id = arguments.optionGroup.question_id,
		question_name = arguments.optionGroup.question_name,
		option_id = "",
		option_name = "",
		match_status = "none",
		match_score = 0,
		options = duplicate(arguments.optionGroup.options),
		display_text = encodeForHTML(arguments.optionGroup.question_name) & " - Seçim gerekli"
	};

	for (var optionItem in arguments.optionGroup.options) {
		var scoreInfo = scoreConfigOptionMatch(arguments.descriptionText, optionItem.option_name, arguments.optionGroup.question_name);

		if (scoreInfo.score > bestMatch.match_score) {
			bestMatch.option_id = optionItem.option_id;
			bestMatch.option_name = optionItem.option_name;
			bestMatch.match_score = scoreInfo.score;
			bestMatch.match_status = scoreInfo.match_status;
		}
	}

	if (bestMatch.match_status == "exact") {
		bestMatch.display_text = encodeForHTML(bestMatch.question_name) & " - " & encodeForHTML(bestMatch.option_name);
	} else if (bestMatch.match_status == "similar") {
		bestMatch.display_text = encodeForHTML(bestMatch.question_name) & " - " & encodeForHTML(bestMatch.option_name) & " (Benzer)";
	} else {
		bestMatch.option_id = "";
		bestMatch.option_name = "";
	}

	return bestMatch;
}

function scoreConfigOptionMatch(string descriptionText = "", string optionName = "", string questionName = "") {
	var normalizedDescription = normalizeText(arguments.descriptionText);
	var normalizedOption = normalizeText(arguments.optionName);
	var normalizedQuestion = normalizeText(arguments.questionName);
	var descriptionWords = [];
	var optionWords = [];
	var questionWords = [];
	var matchedDescriptionWords = 0;
	var matchedOptionWords = 0;
	var matchedQuestionWords = 0;
	var prefixMatchCount = 0;
	var score = 0;

	if (!len(normalizedDescription) || !len(normalizedOption)) {
		return { score = 0, match_status = "none" };
	}

	if (normalizedOption == normalizedDescription) {
		return { score = 100, match_status = "exact" };
	}

	if (findNoCase(normalizedOption, normalizedDescription)) {
		return { score = 100, match_status = "exact" };
	}

	if (
		findNoCase(normalizedDescription, normalizedOption) ||
		left(normalizedOption, len(normalizedDescription)) == normalizedDescription ||
		left(normalizedDescription, len(normalizedOption)) == normalizedOption
	) {
		return { score = 85, match_status = "similar" };
	}

	descriptionWords = listToArray(normalizedDescription, " ");
	optionWords = listToArray(normalizedOption, " ");
	questionWords = listToArray(normalizedQuestion, " ");

	for (var descriptionWord in descriptionWords) {
		if (!len(descriptionWord)) {
			continue;
		}

		for (var optionWord in optionWords) {
			if (!len(optionWord)) {
				continue;
			}

			if (descriptionWord == optionWord) {
				matchedDescriptionWords++;
				prefixMatchCount++;
				break;
			}

			if (
				(len(descriptionWord) gte 3 && left(optionWord, len(descriptionWord)) == descriptionWord) ||
				(len(optionWord) gte 3 && left(descriptionWord, len(optionWord)) == optionWord)
			) {
				matchedDescriptionWords++;
				prefixMatchCount++;
				break;
			}
		}
	}

	for (var optionWord in optionWords) {
		if (len(optionWord) gt 1 and listFindNoCase(normalizedDescription, optionWord, " ")) {
			matchedOptionWords++;
		}
	}

	for (var questionWord in questionWords) {
		if (len(questionWord) gt 2 and listFindNoCase(normalizedDescription, questionWord, " ")) {
			matchedQuestionWords++;
		}
	}

	if (arrayLen(optionWords)) {
		score += int((matchedOptionWords / arrayLen(optionWords)) * 70);
	}

	if (arrayLen(descriptionWords)) {
		score += int((matchedDescriptionWords / arrayLen(descriptionWords)) * 55);
	}

	if (arrayLen(questionWords)) {
		score += int((matchedQuestionWords / arrayLen(questionWords)) * 20);
	}

	if (matchedOptionWords gt 0 and matchedQuestionWords gt 0) {
		score += 10;
	}

	if (matchedOptionWords gt 0 && arrayLen(optionWords) gte 2) {
		score += 15;
	}

	if (prefixMatchCount gt 0) {
		score += 20;
	}

	if (
		arrayLen(descriptionWords) eq 1 &&
		matchedDescriptionWords eq 1 &&
		arrayLen(optionWords) gte 2
	) {
		score += 25;
	}

	if (score gte 60) {
		return { score = score, match_status = "similar" };
	}

	return { score = score, match_status = "none" };
}
</cfscript>
