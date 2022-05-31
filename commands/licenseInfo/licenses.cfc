/***
 * Recursively traverses the modules folder in a Coldbox app and retrieves the names of the modules and their licenses
 **/

component {

	/***
	 * The entry function for the module
	 *
	 * @folder           The folder to traverse. Defaults to the current working directory.
	 * @exportTo.hint    Where do you want the results displayed or written
	 * @exportTo.options screen,csv
	 * @filename         used with exportTo=csv to determine the name of the file to write the data. Defaults to licenseData.csv. File Extension not needed
	 **/
	void function run(
		string folder   = getCwd(),
		string exportTo = "screen",
		filename        = "licenseData"
	){
		var allboxJson = directoryList(
			path     = arguments.folder,
			recurse  = true,
			listInfo = "path",
			filter   = "*.json"
		);
		var onlyBoxes = filterBox( allboxJson );
		var rootLen   = folder.listLen( "\" );

		var allVersionInfo = onlyBoxes.map( function( item ){
			return showBoxes( item, rootLen );
		} );

		if ( arguments.exportTo == "screen" ) {
			outPutToScreen( allVersionInfo )
		} else if ( arguments.exportTo == "csv" ) {
			outputToCSV( allVersionInfo, arguments.filename );
		}
	}

	/***
	 * Filters out all files except those titles "box.json"
	 *
	 * @paths An array of absolute filenames from directoryList
	 **/
	array function filterBox( required array paths ){
		return paths.filter( function( item ){
			return item.findNoCase( "box.json" );
		} );
	}

	/***
	 * Outputs the results of the audit on the screen in Commandbox
	 *
	 * @item The
	 **/
	struct function showBoxes( required string item, required numeric baseLen = 0 ){
		var numIndents  = item.listlen( "\" ) - baseLen;
		var indents     = makeIndent( numIndents );
		var boxData     = readJson( item );
		var licenseData = extractLicenseData( boxData );
		return {
			"indents"     : numIndents,
			"name"        : boxData.name,
			"version"     : boxData.version,
			"licenseData" : licenseData
		}
	}

	void function outPutToScreen( displayData ){
		print.line( "License Information generated on #dateFormat( now(), "dd mmmm yyyy" )# at #timeFormat( now(), "HH:nn:ss" )#" );
		displayData.each( ( item ) => {
			print.line(
				makeIndent( item.indents ) & "|-" & item.name & " (" & item.version & ") : " & item.licenseData.toList( "," )
			);
		} );
	}

	function outputToCSV( displayData, filename ){
		createHierarchy( arguments.displayData, arguments.fileName );
		createUnique( arguments.displayData, arguments.filename );
	}

	function createHierarchy( displayData, filename ){
		var output = "name,version,license,indent#chr( 10 )#";
		displayData.each( ( item ) => {
			output = output & "#item.name#,#item.version#,#item.licenseData.toList( "|" )##item.indents##chr( 10 )#";
		} );

		fileWrite( getcwd() & "/#arguments.filename#.csv", output );
	}

	function createUnique( displayData, filename ){
		var filtered     = {};
		var filteredData = displayData.each( ( item ) => {
			filtered[ item.name ]                 = filtered.keyExists( item.name ) ? filtered[ item.name ] : {};
			filtered[ item.name ][ item.version ] = filtered[ item.name ].keyExists( item.version ) ? filtered[
				item.name
			][ item.version ] : [];
			if ( filtered[ item.name ][ item.version ].findNoCase( item.licenseData.toList( "|" ) ) == 0 ) {
				filtered[ item.name ][ item.version ].append( item.licenseData.toList( "|" ) );
			}
		} );

		var output = "name,version,license,indent#chr( 10 )#";
		filtered
			.keyArray()
			.sort( "textNoCase" )
			.each( ( packageName ) => {
				var data = filtered[ packageName ];
				data.keyArray()
					.sort( "textNoCase" )
					.each( ( versionName ) => {
						var licenseData = filtered[ packageName ][ versionName ];
						licenseData.each( ( license ) => {
							output = output & "#packageName#,#versionName#,#license##chr( 10 )#";
						} )
					} );
			} )

		fileWrite( getcwd() & "/#arguments.filename#-filtered.csv", output );
	}


	/***
	 * Reads the box.json at the submitted path and deserializes is
	 *
	 * @path The absolute path to the box.json file
	 **/
	struct function readJson( required string path ){
		var boxInfo   = fileRead( arguments.path );
		var boxParsed = deserializeJSON( boxInfo );
		return boxParsed;
	}

	/***
	 * Calculates the number of indents needed to create the tree view
	 *
	 * @numKeys the length of the name with "\" as the delimiter
	 **/
	string function makeIndent( required numeric numKeys ){
		var retme = "";
		for ( var x = 1; x < numKeys; x = x + 1 ) {
			retme = retme & " ";
		}
		return retme;
	}

	/***
	 * Extracts the license data from the parsed box.json
	 *
	 * @boxData The parsed box.json structure
	 **/
	array function extractLicensedata( required struct boxData ){
		var licArr = boxData.keyExists( "license" ) ? boxData.license : [];
		return licArr.map( function( item ){
			return item.keyExists( "type" ) ? item.type : "";
		} );
	}

}
