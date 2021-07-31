var placeholderMapTypeHint:{name:String, size:Int, entries:Int, keys:Array<String>, vals:Array<Dynamic>} = null;

/**
 * Stores nearly everything needed to manage maps inside this anon struct.
 * Note, that placeholderMap is needed to hint to the limited Haxe compiler
 * what type the array is storing.
 */
var MAP = {
	maps:[placeholderMapTypeHint],

	DEBUG:{
		MSG:true,
	},

	ERROR:{
		NOTFOUND:1,
		NOMAP:2,
		MAPEXISTS:3,
	},
};

// We purge the type hint from the MAP as we no longer need it.
MAP.maps = [];

TESTS_ON = false;
TESTS_I = 0;
TESTS_PASS = 0;


function init() {
	TESTS_ON = true;
}

function regularUpdate(dt) {
	if(!TESTS_ON)
		return;

	switch(TESTS_I) {
		case 0:
			testStatus("Create Test", createTest());
		case 1:
			testStatus("Get Map Test", getMapTest());
		case 2:
			testStatus("Insert Test", insertTest());
		case 3:
			testStatus("Insert And Retrieve One Test", insertAndRetreiveOneTest());
		case 4:
			testStatus("Insert Three And Retrieve Three Test", insertThreeAndRetreiveThreeTest());

		default:TESTS_ON = false; debug("Testing complete. " + TESTS_PASS + " of " + TESTS_I + " passed.");
	}

	TESTS_I = TESTS_I + 1;
}

function beforeTest() {
	MAP.maps = [];
}

function createTest():Bool {
	beforeTest();

	debug("Running Create Test");
	var passed = true;
	var mapName = "map";
	_create(mapName);

	if(MAP.maps.length != 1) {
		passed = false;
		debug("Maps does not contain the map.");
	}

	var map = MAP.maps[0];

	if(map.name != mapName) {
		passed = false;
		debug("Maps does not contain our named map.");
	}

	if(map.size != 19) {
		passed = false;
		debug("Maps incorrectly set the map size.");
	}

	if(map.keys.length != map.size || map.keys.length != map.vals.length) {
		passed = false;
		debug("Maps did not set the size of the keys and vals array correctly.");
	}

	return passed;
}

function getMapTest():Bool {
	beforeTest();

	debug("Running Get Map Test");
	var passed = true;
	var mapName = "map";
	_create(mapName);

	var map = _getMap(mapName);

	if(map == null) {
		passed = false;
		debug("Did not find our map.");
		return passed;
	}

	if(map.name != mapName) {
		passed = false;
		debug("Did not find the correctly named map.");
	}

	return passed;
}

function insertTest():Bool {
	beforeTest();

	debug("Running Insert Test");
	var passed = true;
	var mapName = "map";
	var key = "key";
	var val = 123;

	_create(mapName);
	_insert(mapName, key, val);

	var map = _getMap(mapName);

	if(map.entries != 1) {
		passed = false;
		debug("Incorrect number of entries in map. Actual: " + map.entries);
	}

	var found = false;
	var index = 0;
	for(k in map.keys) {
		if(k == key)
			break;
		index++;
	}

	var valIndex = 0;
	for(v in map.vals) {
		if(v == val)
			break;
		valIndex++;
	}

	if(index != valIndex) {
		passed = false;
		debug("Value not found in same index where key was found. Index: " + index + " Actual Val Index: " + valIndex + " | Value Found at key index: " + map.vals[index]);
	}

	return passed;
}

function insertAndRetreiveOneTest():Bool {
	beforeTest();

	debug("Running Insert And Retrieve One Test");
	var passed = true;
	var mapName = "map";
	var key = "key";
	var val = 123;

	_create(mapName);
	_insert(mapName, key, val);
	return assertRetrieval(mapName, key, val);
}

function insertThreeAndRetreiveThreeTest():Bool {
	beforeTest();

	debug("Running Insert Three And Retrieve Three Test");
	var passed = true;
	var mapName = "map";

	_create(mapName);
	_insert(mapName, "k1", 1);
	_insert(mapName, "k2", 2);
	_insert(mapName, "k3", 3);
	passed = passed && assertRetrieval(mapName, "k1", 1) && assertRetrieval(mapName, "k2", 2) && assertRetrieval(mapName, "k3", 3);

	return passed;
}


function assertRetrieval(mapName:String, key:String, expected:Dynamic) {
	var passed = true;
	var retrievedValue = _retrieve(mapName, key);

	if(retrievedValue == null) {
		passed = false;
		debug("Retrieved value is null");
		return passed;
	}

	if(retrievedValue != expected) {
		passed = false;
		debug("Expected retrieved value to be: " + expected + " but found " + retrievedValue);
	}

	return passed;
}

function testStatus(name:String, status:Bool) {
	debug("[" + name + "] " + (status ? "PASSED" : "FAILED"));
	if(status) TESTS_PASS++;
}

function _create(name:String) {
	var existed = _getMap(name);
	if(existed != null) {
		if(MAP.DEBUG.MSG)
			debug("ERROR [MAP]: Map already exists, '" + name + "'");
		return MAP.ERROR.MAPEXISTS;
	}

	var keys:Array<String> = [null];
	var vals:Array<Dynamic> = [null];

	keys.resize(19);
	vals.resize(19);
	MAP.maps.push({name:name, size:19, entries:0, keys:keys, vals:vals});
}

/**
 * Inserts a key into a given named map with the given value. If the key
 * already exists, its value is replaced.
 *
 * @return Bool - true if the key was cleanly inserted, false if it replaced a record.
 * @error MAP.ERROR.NOMAP - if there is no map with that name.
 */
function _insert(name:String, key:String, val:Dynamic):Dynamic {
	var map = _getMap(name);
	if(map == null) {
		if(MAP.DEBUG.MSG)
			debug("ERROR [MAP]: Map does not exist, '" + name + "'");
		return MAP.ERROR.NOMAP;
	}

	if(map.entries >= (map.size * 0.75)) {
		_resize(map);
	}

	var hash = _hash(key);

	var index = hash % map.size;

	// If a key already exists, and it isn't our own key, then
	// we must probe for an empty index. I have chosen a simple
	// incrementor strategy until this proves poor.
	while(map.keys[index] != null && map.keys[index] != key) {
		index = (index++) % map.size;
	}

	map.keys[index] = key;
	map.vals[index] = val;
	map.entries++;

	return map.keys[index] == key;
}

/**
 * Given a map's name, will return the associated value with the given key
 * in the map.
 *
 * @return Dynamic - The value associated with the key.
 * @error MAP.ERROR.NOMAP - if there is no map with that name.
 * @error MAP.ERROR.NOTFOUND - If the key does not exist in the map.
 */
function _retrieve(name:String, key:String):Dynamic {
	var map = _getMap(name);
	if(map == null) {
		if(MAP.DEBUG.MSG)
			debug("ERROR [MAP]: Map does not exist, '" + name + "'");
		return MAP.ERROR.NOMAP;
	}

	var hash = _hash(key);
	var index = hash % map.size;

	if(map.keys[index] == null) {
		if(MAP.DEBUG.MSG)
			debug("Key does not exist, '" + key + "'");
		return MAP.ERROR.NOTFOUND;
	}

	// To handle collisions, we must check if the key at the given index
	// is ours, and if not, then keep probing until we have found our key.
	// Once found, that is where the value is also stored.
	var indexCount = 0;
	while(map.keys[index] != null && map.keys[index] != key && indexCount <= map.size) {
		index = (index++) % map.size;
		indexCount++;
	}

	if(indexCount > map.size) {
		return MAP.ERROR.NOTFOUND;
	}

	return map.vals[index];
}

/**
 * Will remove an entry from a given Map. It is safe to call this
 * repeatedly for the same key and for maps that do not exist.
 *
 * @return Bool - True if the entry was present and removed. Otherwise false.
 * @error MAP.ERROR.NOMAP - if there is no map with that name.
 */
function _delete(name:String, key:String):Dynamic {
	var map = _getMap(name);
	if(map == null) {
		if(MAP.DEBUG.MSG)
			debug("ERROR [MAP]: Map does not exist, '" + name + "'");
		return MAP.ERROR.NOMAP;
	}

	var hash = _hash(key);
	var index = hash % map.size;

	// We still need to handle collisions, however we have the special case
	// where we are asked to delete a key that does not exist that must be
	// handled.

}

/**
 * Increase the size of our map to ensure we have space for all incoming objects.
 */
function _resize(map:{name:String, size:Int, entries:Int, keys:Array<String>, vals:Array<Dynamic>}) {

}

/**
 * Source: https://www.cs.hmc.edu/~geoff/classes/hmc.cs070.200101/homework10/hashfuncs.html
 *
 * We use the CRC variant algorithm under the section "Hashing sequences of characters". This was
 * chosen because it was easy to implement, directly deals with characters for key values which
 * is what we require, and because the CRC variant was said to be slightly better over the PJW hash.
 */
function _hash(key:String) {
	var h = 0;
	for(i in 0...key.length) {
		var char = key.charCodeAt(i);
		var highorder = h & 0xf8000000;
		h = h << 5;
		h = h ^ (highorder >> 27);
		h = h ^ char;
	}

	return h;
}

function _getMap(name:String):{name:String, size:Int, entries:Int, keys:Array<String>, vals:Array<Dynamic>} {
	for(m in MAP.maps) {
		if(m.name == name)
			return m;
	}

	return null;
}