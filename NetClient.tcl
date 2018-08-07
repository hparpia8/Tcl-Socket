# NetClient 
# Author: Hussein Parpia, hparpia8@gmail.com;

package require TclOO;
package require oo::util;
package provide NetClient 1.0;

if {![info object isa object NetClient] ||
	![info object isa class NetClient]} {
		oo::class create NetClient;
}

oo::define NetClient {
	variable client;

	constructor {host port} {
		set client [socket $host $port]; 
		fconfigure $client -buffering line;
		fileevent $client readable [mymethod getMessage $client];
	}
	
	destructor {
		close $client;
	}

	method sendMessage {name msg} {
		puts $client [list $name $msg];
	}

	method getMessage {sock} {
		if {[catch {gets $sock line} ret] == 0} {
			puts $line;
		} else {
			puts stderr "Error occured: $ret";
		}
	}
}
