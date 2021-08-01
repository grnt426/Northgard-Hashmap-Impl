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
		UNDERSIZED:4,
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
		case 5:
			testStatus("Contains Key Test", containsKeyTest());
		case 6:
			testStatus("Contains Three Keys Test", containsThreeKeysTest());
		case 7:
			testStatus("Resize Test", resizeTest());

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

	var fake = _retrieve(mapName, "k4");
	if(fake != MAP.ERROR.NOTFOUND) {
		passed = false;
		debug("Expected to not find key 'k4'");
	}

	return passed;
}

function containsKeyTest():Bool {
	beforeTest();

	debug("Running Contains Key Test");
	var passed = true;
	var mapName = "map";

	_create(mapName);
	_insert(mapName, "key", 123);
	var found = _containsKey(mapName, "key");

	if(!found) {
		passed = false;
		debug("Key was not found");
	}

	return passed;
}

function containsThreeKeysTest():Bool {
	beforeTest();

	debug("Running Contains Three Keys Test");
	var passed = true;
	var mapName = "map";

	_create(mapName);
	_insert(mapName, "k1", 123);
	_insert(mapName, "k2", 456);
	_insert(mapName, "k3", 789);
	var found = _containsKey(mapName, "k1");

	if(!found) {
		passed = false;
		debug("k1 was not found");
	}

	var found = _containsKey(mapName, "k2");

	if(!found) {
		passed = false;
		debug("k2 was not found");
	}

	var found = _containsKey(mapName, "k3");

	if(!found) {
		passed = false;
		debug("k3 was not found");
	}

	var found = _containsKey(mapName, "k4");

	if(found) {
		passed = false;
		debug("k4 was found when it should not have been");
	}

	return passed;
}

function resizeTest():Bool {
	beforeTest();

	debug("Running Resize Test");
	var passed = true;
	var mapName = "map";

	var map = _createWithSize(mapName, 3);

	_insert(mapName, "k1", 123);
	debug("Insert first key");
	if(map.size != 3) {
		passed = false;
		debug("Should not have resized after one element.");
	}
	_insert(mapName, "k2", 456);
	debug("Insert second key");
	if(map.size != 3) {
		passed = false;
		debug("Should not have resized after two elements.");
	}
	_insert(mapName, "k3", 789);
	debug("Insert third key");
	if(map.size != 3) {
		passed = false;
		debug("Should not have resized after three elements.");
	}

	_insert(mapName, "k4", 2468);
	debug("Insert fourth key");
	if(map.size != 6) {
		passed = false;
		debug("Should have resized after four elements.");
	}

	return passed && assertRetrieval(mapName, "k1", 123) && assertRetrieval(mapName, "k2", 456)
		&& assertRetrieval(mapName, "k3", 789) && assertRetrieval(mapName, "k4", 2468);
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


/**
 * ==========================================================================
 * 								Map Functions
 *
 * @source: https://github.com/grnt426/Northgard-Hashmap-Impl
 *
 * The below functions are used to manage map datastructures.
 *
 * Why? Because the limited scripting features we get do not
 * include this basic data structure, and I kept making mods where
 * I very much wanted, if not needed, this datastructure.
 *
 * You, the user, don't need to know how the below code works! I tried
 * to make it as friendly as possible and provide many useful APIs.
 *
 * You can create as many maps as needed, and they can be as large as
 * Northgard or your computer memory allows.
 *
 * The performance is designed for an average case of O(1). Worst-case
 * performance of O(n) can happen when the map is nearly full. However,
 * the map will automatically resize itself through the _insert function
 * by doubling the array size each time. This should help keep collisions
 * down and performance higher.
 *
 * Example Usage:
 * 	_create("myMap");
 *
 * 	_insert("myMap", "key", 123);
 * 	_insert("myMap", "anotherKey", "mixed types allowed");
 *
 * 	_retrieve("myMap", "key"); // returns the number 123
 *
 * 	_create("any number of maps supported");
 *
 * 	_containsKey("myMap", "never inserted"); // returns false
 *
 * ==========================================================================
 */

/**
 * Creates a map with the given name and an initial size.
 *
 * @return - The newly created map.
 * @error MAP.ERROR.MAPEXISTS - if a map with that name already exists.
 */
function _create(name:String):Dynamic {

	// 19 was somewhat arbitrarily chosen, but it is prime and is larger
	// than all the other maps I needed, so should be good enough for
	// most other modders.
	return _createWithSize(name, 19);
}

/**
 * Creates a map with the given name and an initial size.
 *
 * @return - The newly created map with specified size.
 * @error MAP.ERROR.MAPEXISTS - if a map with that name already exists.
 */
function _createWithSize(name:String, size:Int):Dynamic {
	var existed = _getMap(name);
	if(existed != null) {
		if(MAP.DEBUG.MSG)
			debug("ERROR [MAP]: Map already exists, '" + name + "'");
		return MAP.ERROR.MAPEXISTS;
	}

	var keys:Array<String> = [null];
	var vals:Array<Dynamic> = [null];

	keys.resize(size);
	vals.resize(size);
	var map = {name:name, size:size, entries:0, keys:keys, vals:vals};
	MAP.maps.push(map);

	return map;
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

	if(MAP.DEBUG.MSG) {
		debug("Entries: " + map.entries + " Size: " + map.size + " Resize Threshold: " + (map.size * 0.75));
		debug("New Entry key: " + key + " value: " + val);
	}


	if(map.entries >= (map.size * 0.75)) {
		if(MAP.DEBUG.MSG)
			debug("Resizing...");
		_resize(map);
	}

	var hash = _hash(key);
	var index = hash % map.size;




	// If a key already exists, and it isn't our own key, then
	// we must probe for an empty index. I have chosen a simple
	// incrementor strategy until this proves poor.
	var indexCount = 0;
	while(map.keys[index] != null && map.keys[index] != key && indexCount <= map.size) {
		index = (index++) % map.size;
		indexCount++;
	}

	if(indexCount > map.size) {
		debug("Error: Map is undersized. Should not happen.");
		return MAP.ERROR.UNDERSIZED;
	}

	var replacedItself = map.keys[index] == key;
	map.keys[index] = key;
	map.vals[index] = val;
	map.entries++;
	// debug("wrote key to index: " + index);

	return replacedItself;
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
 * If the key exists in the map, will return true. Will not throw
 * MAP.ERROR.NOTFOUND errors.
 *
 * @return Bool - True if the key was found, otherwise false.
 * @MAP.ERROR.NOMAP - if the map was not found by the given name.
 */
function _containsKey(name:String, key:String):Dynamic {
	var map = _getMap(name);
	if(map == null) {
		if(MAP.DEBUG.MSG)
			debug("ERROR [MAP]: Map does not exist, '" + name + "'");
		return MAP.ERROR.NOMAP;
	}

	var hash = _hash(key);
	var index = hash % map.size;

	if(map.keys[index] == null) {
		return false;
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
		return false;
	}

	return map.keys[index] == key;
}

/**
 * Will remove an entry from a given Map. It is safe to call this
 * repeatedly for the same key.
 *
 * Attempting to delete a key that does not exist in a
 * full map will cause the entire map to be searched.
 *
 * Unlike other functions, this one will maintain idempotency
 * and will never return a MAP.ERROR.NOTFOUND error. This is
 * useful in loops where you want to quickly look for objects
 * which were positively deleted.
 *
 * Runtime Complexity: O(n)
 * Average: O(1)
 *
 * @return Bool - True if the entry was present and removed. Otherwise false.
 * 					Will return false if not found.
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
	var indexCount = 0;
	while(map.keys[index] != null && map.keys[index] != key && indexCount <= map.size) {
		index = (index++) % map.size;
		indexCount++;
	}

	// In these cases the key was not found
	if(indexCount > map.size || map.keys[index] == null) {
		return false;
	}

	map.keys[index] = null;
	map.vals[index] = null;
	map.entries--;
	return true;
}

/**
 * Increase the size of our map to ensure we have space for all incoming objects.
 */
function _resize(map:{name:String, size:Int, entries:Int, keys:Array<String>, vals:Array<Dynamic>}) {

	var oldKeys = [];
	var oldVals = [];
	var oldSize = map.size;

	var index = 0;
	while(index < oldSize) {
		oldKeys.push(map.keys[index]);
		oldVals.push(map.vals[index]);
		// debug("K: " + map.keys[index] + " V: " + map.vals[index]);
		index++;
	}

	map.entries = 0;
	map.size = map.size * 2;
	map.keys = [null];
	map.vals = [null];
	map.keys.resize(map.size);
	map.vals.resize(map.size);
	debug("reinserting old values");

	index = 0;
	@sync while(index < oldSize) {
		if(oldKeys[index] != null) {
			var key = oldKeys[index];
			var val = oldVals[index];
			var hash = _hash(key);
			var index = hash % map.size;

			// If a key already exists, and it isn't our own key, then
			// we must probe for an empty index. I have chosen a simple
			// incrementor strategy until this proves poor.
			var indexCount = 0;
			while(map.keys[index] != null && map.keys[index] != key && indexCount <= map.size) {
				index = (index++) % map.size;
				indexCount++;
			}

			map.keys[index] = key;
			map.vals[index] = val;
			map.entries++;
		}
		index++;
	}
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