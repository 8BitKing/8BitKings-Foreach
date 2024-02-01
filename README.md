# 8BitKings-Foreach
Foreach macros in gamemaker.

This script provides macros that archive a foreach behaviour in GML
It supports ```break``` and ```continue``` and its variable scope is just like in any other loop, unlike many foreach implementations based on functions.
The code you write in the foreach block is actually inside a forloop so it behaves as you would expect, except with return but more on that later.

I was inspired to do this after I read this fabulous [Blogpost](https://www.katsaii.com/content/blog/post/gml+syntax+extensions.html) by katsaii. Give it a read especially if you want to understand how this works in detail.

I will provide some example to show what this can do, they are also inside the script so you can run and test them yourself.


First lets just iterate over an array.
```
		var _array = [1,2,3,4,9,9,9]
		foreach (_array) tu
		{
			//Works just like other loops!
			if (__elem mod 2 == 0) continuee;		
		
			show_message($"__elem: {__elem}, __index : {__index}");
			if (__elem == 9) break;
		}
```
```foreach``` is a macro as well as ```tu``` (german version of ```do``` in this context but ```do``` is already taken) and they are defined in the script to set up the local vars ```__elem``` and ```__index```.
```__elem``` assumes the value of the element in the array or list and ```__index``` is the index.
Note that the parentheses around ```_array``` are necassary and also because of macros syntax hightlighting likes to suggest ```__elem``` and ```__index``` are not local vars, idk whats happening there.

This is how it could look when iterating over a String:
```
		var _string = "ABCD"
		foreach (_string) tu
		{
			show_message($"__elem: {__elem}, __index : {__index}");
		}

```
Ofcourse ``` foreach ("ABCD") tu ``` would also work, but be aware unlike usual gml behaviour this loops starts the indexing of the characters at 0, though you could also change that if you need.

Then there is lists and structs:
```
		var _list = ds_list_create()
		ds_list_add(_list, 1, 2, 3, 4,)
		foreach (_list) tu
		{
			show_message($"__elem: {__elem}, __index : {__index}");
		}
	
		ds_list_destroy(_list)


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

```
As you can see I implemented ```__elem``` to look like this ``` {name, value} ```. I think its debateable how to implement this but it really is a super simple change in the code if you want something else.
Also you have no control about the order in which this gets iterated, its dependend on the order of whatever ```struct_get_names()``` returns. 

Ofcourse it also support nested loops:

```
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
```
just be aware __elem and __index have the value of whichever loop their are written in.


Now we get to the biggest weakness of the system, returning from within a foreach loop.
```
		test = function(_array)
		{
			foreach (_array) tu
			{
				FEreturn __elem;
			}
		}
```
As you can see this is done with yet another macro "FEreturn".
You can use this macro just as you would return except you cannot FEreturn nothing, you have to be explicit: ``` return; ``` => ``` FEreturn undefined; ```.
If you just use return the stack used to keep track of nested loops does not get updated and your game can crash or memory leak. This is the biggest weakness of the system and maybe someone clever can figure out how to avoid it.

There is another detail, that if missed could cause some headaches:
```
		foreach ([1, undefined, 2, pointer_null, 3]) tu
		{
			show_message($"__elem: {__elem}, __index : {__index}");
		}
```
This will run without errors but per default the exit condition of the forloop that runs in the backround is  ``` __elem == pointer_null ```.
So even though this runs it may not behave like you expect as it will stop looping at index 2. The exit Value can be modified by you, just change the value of ``` #macro FOREACH_EXIT pointer_null ```
to something else, maybe you prefer a string.


As final words I want to let you know that this is not made with performance in mind and I have never tested this in regards of speed. This is for your code writing pleasure and oh boy let me tell you its so fun to have foreach loops! I have used this in a complete game I worked over a year on ([check it out](https://8bitking.itch.io/eoa-cold-blood)) and thats what I can tell you about its reliability, allthough I have updated it since then and while I am sure I have not made any changes to functionality I have not tested the new version on a big project yet.


I have documented the code so you should find your way through that, except the macros themselves... they are a mess and if you really want to know what happens there, alot of syntax/gml specifics but I am sure if you really want to you can get behind it, it just uses a few tricks. Supporting new datastructures should also not be a problem, if you really want to iterate through ds_maps its just a few lines of code, once you have a look at the code you will see how its done.


Have fun :D
