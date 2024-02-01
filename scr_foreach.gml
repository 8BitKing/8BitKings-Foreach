// 8_BitKing's foreach
// Visit 8bitking.itch.io

// This is heavily inspired by the following Blogpost from katsaii, it's a blast so give it a read!
// https://www.katsaii.com/content/blog/post/gml+syntax+extensions.html


// this is used to keep track of nested loops
global.__foreach_iterator_stack = [];

// see test_undefined() below to learn about this macro
#macro FOREACH_EXIT pointer_null



// I disable feather for this as it seems to not really like the crimes I have committed here.
// feather ignore all


// This is where the magic happens, a proper iterator gets selected depending on the provided
// datastructure and the local variables __index and __elem are updated so you can use them in your code.
// the codeblock in which you write your code is actually the body of a for loop so you can use all your favourite
// loop keywords like break and continue.

// I suggest to look through the examples to find out what this can actually do.

#macro foreach var __iterator = iterator_select(				
			
#macro FOREACH_PREDO array_insert(global.__foreach_iterator_stack, 0, __iterator);				\
			var __elem  = array_first(global.__foreach_iterator_stack).next();					\
			var __index = array_first(global.__foreach_iterator_stack).index;					
			
#macro FOREACH_POSTDO for (;__elem != FOREACH_EXIT;												\
			{																					\
				__elem  = array_first(global.__foreach_iterator_stack).next();					\
				__index = array_first(global.__foreach_iterator_stack).index;					\
				if __elem == FOREACH_EXIT														\
				{																				\
					break;																		\
				}																				\
			})
			
#macro FOREACH_END	{array_shift(global.__foreach_iterator_stack);								\
			if (array_first(global.__foreach_iterator_stack) != undefined)						\
			{																					\
				__elem = array_first(global.__foreach_iterator_stack).peek();					\
				__index = array_first(global.__foreach_iterator_stack).index;					\
			}}																			

#macro FEreturn for(;;{FOREACH_END; return ____return}) var ____return =


// I could not do it without a macro after the parentheses so the syntax turned out to be
// foreach (list) do { something }
// do is already a keyword and I wanted something short so i chose "tu" 
// which is just the german version of do (in this context) (crtl + shift + f and you want to relace it with whatever, I was about to choose "doo" instead or "Do")
#macro tu ); FOREACH_PREDO for(;;{FOREACH_END; break}) FOREACH_POSTDO

// feather enable all




//Very basic "Iterator". This helps generalize different data structures
function Iterator() constructor
{	
	//take this as an abstract class, it should not be instanciated
	//the functions list_get_at() and list_length() get implemented by children of this
	//they are not found here so you get errors if you forget.
	
	list = undefined;

	index = -1;
	
	next = function()
	{		
		index++;
		if (index < list_length() and index >= 0)
		{
			return list_get_at(index);
		}
		else
		{
			return FOREACH_EXIT;
		}
	}

	peek = function()
	{	
		if (index < list_length() and index >= 0)
		{
			return list_get_at(index);
		}
		else
		{
			return FOREACH_EXIT;
		}
	}
}


//These contain the specifics to the Datastructures. Pretty easy to add your own or change the behaviour
function Iterator_Array(_list) : Iterator() constructor
{
	list = _list;
	
	list_length = function()
	{
		return array_length(list);
	}
	
	list_get_at = function(_index)
	{
		return list[@ _index];
	}
}

function Iterator_Struct(_struct) : Iterator() constructor
{
	//I am unsure if you want to Iterate through structs,
	//but either way take this as an example to see that you can play with the return values etc.
	
	list = struct_get_names(_struct);
	struct = _struct;
	
	list_length = function()
	{
		return array_length(list);
	}
	
	list_get_at = function(_index)
	{
		return {name : list[_index], value : struct[$ list[_index]]};
	}
}

function Iterator_String(_string) : Iterator() constructor
{
	//I am lazy and cheat so I just convert it to an array, feel free to change this.
	//be aware this changes String indexing to start at 0, which I like for myself.
	
	list = [];
	for (var _i = 1; _i <= string_length(_string); _i++)
	{
		array_push(list, string_char_at(_string, _i))
	}
	
	
	list_length = function()
	{
		return array_length(list);
	}
	
	list_get_at = function(_index)
	{
		return list[@ _index];
	}
}

function Iterator_List(_list) : Iterator() constructor
{
	list = _list;
	
	list_length = function()
	{
		return ds_list_size(list);
	}
	
	list_get_at = function(_index)
	{
		return list[| _index];
	}
}


//This function gets called by the foreach macros and it just decides which kind of iterator to return.
function iterator_select(_list)
{
	if (is_struct(_list)) return new Iterator_Struct(_list);
	
	if (is_array(_list)) return new Iterator_Array(_list);
	
	if (is_string(_list)) return new Iterator_String(_list);

	if (not is_string(_list) and ds_exists(_list, ds_type_list)) return new Iterator_List(_list);
}


#region EXAMPLES

	test_array = function()
	{
		var _array = [1,2,3,4,9,9,9]
		foreach (_array) tu
		{
			//Works just like other loops!
			if (__elem mod 2 == 0) continue;		
		
			show_message($"__elem: {__elem}, __index : {__index}");
			if (__elem == 9) break;
		}
	}

	test_string = function()
	{
		var _string = "ABCD"
		foreach (_string) tu
		{
			show_message($"__elem: {__elem}, __index : {__index}");
		}
	}

	test_list = function()
	{
		var _list = ds_list_create()
		ds_list_add(_list, 1, 2, 3, 4,)
		foreach (_list) tu
		{
			show_message($"__elem: {__elem}, __index : {__index}");
		}
	
		ds_list_destroy(_list)
	}

	test_struct = function()
	{
		//decide for yourself if you should even consider iterating through a struct :D
	
		var _struct = {
			test0 : 5,
			test1 : "Hi",
			test2 : (5-1),
			test3 : "Hello :D",
		}
	
		//This will iterate through all elements in the struct but the order is random.
		foreach (_struct) tu
		{
			show_message($"__elem: {__elem}, __index : {__index}, __elem.name : {__elem.name}, __elem.value : {__elem.value}");
		}
	
	}

	test_nested = function()
	{
		var _array = [2,1];
		var _string = "EF"

		foreach (_string) tu
		{
			//__elem does not carry over into the nested loop, for that you have to save it yourself
			var _char = __elem;
	
			foreach (_array) tu
			{
				show_message($"Nested: _char: {_char}, __elem: {__elem}");
			}
	
			//__elem gets reset after the nested loop so it behaves as you would expect: its the same value as char again
	
			show_message($"_char: {_char}, __elem: {__elem}");
		}
	}

	test_fereturn = function()
	{
		test = function(_array)
		{
			foreach (_array) tu
			{
				//if you exit a foreach you NEED to use FEreturn, this insures the stack gets updated correctly
				//not doing this is will result in an ever growing stack and even if this seems to not affect the functionality
				//It will mess with results in nested Foreachloops and even crash.
				//there is no counterpart to the keyword exit as I dont see why you would use that. It is also not supported just
				//like regular return.
				FEreturn __elem;
			}
		}

		var _array = [[1,2],[2,3]]
		foreach (_array) tu
		{
			show_message(test(__elem));
		}

	}

	test_undefined = function()
	{
		// as demonstradet in this test, if an element assumes the value pointer_null the loop stops
		// the condition for the loop to stop is __elem == pointer_null
		// or more specifically __elem == FOREACH_EXIT
		// FOREACH_EXIT is a macro defined at the top and you can change it to whatever you see fit maybe 
		// a string "FOREACH_EXIT" fits your purposes better.
	
		foreach ([1, undefined, 2, pointer_null, 3]) tu
		{
			show_message($"__elem: {__elem}, __index : {__index}");
		}
	}

	test_array();
	test_string();
	test_list();
	test_struct();
	test_nested();
	test_fereturn();
	test_undefined();

#endregion


