module inifile;

import std.stdio;
import std.conv;
import std.range;
import std.format;
import std.traits;

string genINIparser(T)() {
	return "";
}

struct INI {
	string msg;

	static INI opCall(string s) {
		INI ret;
		ret.msg = s;

		return ret;
	}
}

bool isINI(T)() @trusted {
	foreach(it; __traits(getAttributes, T)) {
		if(is(typeof(it) == INI)) {
			return true;
		}
	}
	return false;
}

bool isINI(T, string mem)() @trusted {
	foreach(it; __traits(getAttributes, __traits(getMember, T, mem))) {
		if(is(typeof(it) == INI)) {
			return true;
		}
	}
	return false;
}

string getINI(T)() @trusted {
	foreach(it; __traits(getAttributes, T)) {
		if(isINI!(T)) {
			return it.msg;
		}
	}
	assert(false);
}

string getINI(T, string mem)() @trusted {
	foreach(it; __traits(getAttributes, __traits(getMember, T, mem))) {
		if(isINI!(T, mem)) {
			return it.msg;
		}
	}
	assert(false, mem);
}

string getTypeName(T)() @trusted {
	return fullyQualifiedName!T;
}

void readINIFile(T)(ref T t, string filename) {

}

void writeComment(ORange,IRange)(ORange orange, IRange irange) @trusted 
	if(isOutputRange!(ORange, ElementType!IRange) && isInputRange!IRange)
{
	size_t idx = 0;
	foreach(it; irange) {
		if(idx % 80 == 0) {
			orange.put("; ");
		}
		orange.put(it);

		if(idx+1 % 80 == 0) {
			orange.put('\n');
		}

		++idx;
	}
	orange.put('\n');
}

void writeValue(ORange,T)(ORange orange, string name, T value) @trusted 
{
	orange.formattedWrite("%s=\"%s\"\n", name, to!string(value));
}

void writeINIFile(T)(ref T t, string filename) @trusted {
	auto oFile = File(filename, "w");
	auto oRange = oFile.lockingTextWriter();
	
	if(isINI!T) {
		writeComment(oRange, getINI!T());
	}

	oRange.formattedWrite("[%s]\n", getTypeName!T);

	foreach(it; __traits(allMembers, T)) {
		if(isINI!(T,it)) {
			//writefln("%d %s", __LINE__, getINI!(T,it));
			writeComment(oRange, getINI!(T,it));
			writeValue(oRange, it, __traits(getMember, t, it));
		}
	}
}