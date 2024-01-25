
/*
calico state v0.1
~ parchii
*/

// Feather ignore once GM1056
/// @ignore
function CalicoStateChild(_parent = undefined, _top) constructor {
	
	/// @ignore
	__parent = _parent;
	/// @ignore
	__top = _top;
	
	// stores every event
	/// @ignore
	__data = {};
	
	/// @func add()
	/// @desc creates a new CalicoStateChild and returns it, adding it to the inheritance tree
	/// @returns {Struct.CalicoStateChild}
	static add = function(){
		var _child = new CalicoStateChild(self, __top);
		return _child;
	}
	
	/// @func set(name, callback)
	/// @desc adds an event to the state with a given name
	/// @param {string} _name name of the event
	/// @param {function} _func callback for when the event is run
	static set = function(_name, _func){
		__data[$ _name] = _func;
		return self;
	}
	
	/// @func run(name)
	/// @desc runs this state's event without any inheritance
	/// @param {string} _name name of event to run
	static run = function(_name){
		if __data[$ _name] != undefined
			__data[$ _name]();
	}
	
	// sets up the inheritance stack.
	// when reaches the top of the tree,
	// the Stack controller begins running
	/// @ignore
	static __delegate = function(_name){
		__top.__push(self);
		if __parent != undefined {
			__parent.__delegate(_name);
		} else {
			__top.child(_name);
		}
		__top.__pop();
	}
	
}

/// @func CalicoState()
/// @desc creates a new "State" object, the main entry point of calico state
/// @returns {Struct.CalicoState}
function CalicoState() constructor {
	
	/// @ignore
	__stack = [];
	/// @ignore
	__depth = 0;
	
	/// @ignore
	__running = false;
	
	// current running event name
	/// @ignore
	__name = "";
	
	// the currently targeted state
	/// @ignore
	__current = undefined;
	
	// if currently running, stores the next targeted state
	// current is set to deferchange at end of run()
	/// @ignore
	__deferchange = undefined;
	
	/// @ignore
	__time_state = 0;
	/// @ignore
	__time_total = 0;
	
	/// @func add()
	/// @desc creates a new state and returns it. 
	/// this is the only intended way of creating a StateChild struct
	/// @returns {Struct.CalicoStateChild}
	static add = function(){
		var _child = new CalicoStateChild(undefined, self);
		return _child;
	}
	
	/// @func change(child)
	/// @desc changes the current state. will only take effect after the state has finished running.
	/// @param {Struct.CalicoStateChild} _child the state object to change to, obtained from .add()
	static change = function(_child){
		if !__running {
			__change(_child);
			return;
		}
		__deferchange = _child; // only change event at end of run()
	}
	/// @ignore
	static __change = function(_child){
		run("leave");
		
		__current = _child;
		__time_state = 0;
		
		run("enter");
	}
	
	/// @func child(name)
	/// @desc runs the current child's event. used when an event is running.
	/// @param {string} _name name of event to run. defaults to the name of the current running event.
	static child = function(_name = __name){
		if __depth <= 0 return;
		
		var _lastname = __name;
		__name = _name;
		
		__depth--;
		
		if __stack[__depth].__data[$ _name] != undefined
			__stack[__depth].run(_name);
		else
			child(); // move to next child until match found
		
		__depth++;
		
		__name = _lastname;
	}
	
	/// @func run(name)
	/// @desc runs the current state with the given event name.
	/// @param {string} _name event to run. defaults to "step"
	static run = function(_name = "step"){
		if __current == undefined return;
		__running = true;
		__depth = 0;
		__name = _name;
		__current.__delegate(_name);
		
		__time_state += 1;
		__time_total += 1;
		
		__running = false;
		if __deferchange != undefined {
			var _child = __deferchange;
			__deferchange = undefined;
			__change(_child)
		}
	}
	
	/// @func is(child)
	/// @desc check the current state against a child
	/// @param {Struct.CalicoStateChild} _child child to check against
	/// @returns {bool} whether the state is currently the child
	static is = function(_child){
		return __current == _child;
	}
	
	/// @ignore
	static __push = function(_child){
		array_push(__stack, _child);
		__depth++;
	}
	
	/// @ignore
	static __pop = function(){
		array_pop(__stack);
		__depth--;
	}
	
}




