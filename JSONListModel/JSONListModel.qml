/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 */

import QtQuick 1.1
import "jsonpath.js" as JSONPath

Item {
    property string source: ""
    property string json: ""
    property string query: ""
    property string sortby: ""

    property ListModel model : ListModel { id: jsonModel }
    property alias count: jsonModel.count

    onSourceChanged: {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE)
                json = xhr.responseText;
        }
        xhr.send();
    }

    onJsonChanged: updateJSONModel()
    onQueryChanged: updateJSONModel()

    function updateJSONModel() {
        jsonModel.clear();

        if ( json === "" )
            return;

        var objectArray = parseJSONString(json, query);
        if (sortby !== "") objectArray = sortByKey(objectArray, sortby);
        for ( var key in objectArray ) {
            var jo = objectArray[key];
            jsonModel.append( jo );
        }
    }

    function parseJSONString(jsonString, jsonPathQuery) {
        var objectArray = JSON.parse(jsonString);
        if ( jsonPathQuery !== "" )
            objectArray = JSONPath.jsonPath(objectArray, jsonPathQuery);

        return objectArray;
    }

    function sortByKey(array, key) {
        return array.sort(function(a, b) {
            var x = a[key]; var y = b[key];
            return ((x < y) ? -1 : ((x > y) ? 1 : 0));
        });
    }
}
