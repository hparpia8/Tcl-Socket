# NetServer
# Author: Hussein Parpia, hparpia8@gmail.com;

package require TclOO;
package require oo::util;
package provide NetServer 1.0;

if {![info object isa object NetServer] ||
	![info object isa class NetServer]} {
		oo::class create NetServer;
}

oo::define NetServer {
	variable server;
	variable clients;
	variable count;
	variable cnames;

	constructor {port} {
		set count 0;
		array set cnames {};
		array set clients {};
		set server [socket -server [mymethod accept] $port];
		vwait forever;
	}
	
	destructor {
		# TODO: Find a proper way to destroy server;
		if {[array exists cnames]} {
			foreach n [array names cnmaes] {
				set sock $cnames($n);
				close $sock;
				unset $clients(addr,$sock);
			}
			array unset cnames;
		}
	}

	method getClients {name} {
		if {[info exists clients($name)]} {
			set sock $cnames($name);
			lassign $clients(addr,$sock) addr port;
			puts "Client: $sock, Address: $addr, Port: $port";
		}
	}

	method accept {sock addr port} {
		puts "Accepted $sock from $addr port $port";
		set clients(addr,$sock) [list $addr $port];
		
		# TODO: Add better way of storing client name;
		set cnames([incr count]) $sock;
		puts "name $count"; 

		fconfigure $sock -buffering line;
		fileevent $sock readable [mymethod processData $sock];

	}

	method processData {sock} {
		if {[eof $sock] || [catch {gets $sock line}]} {
			close $sock;
			puts "Closed $clients(addr,$sock)";
			unset clients(addr,$sock);
		} else {
			lassign $line name msg;
			set myname [my getName $sock];
			puts stderr $myname;
			puts "Sending message from $sock to $cnames($name)";
			puts $cnames($name) "$myname $msg";
		}
	}

	method getName {sock} {
		foreach s [array names cnames] {
			if {$sock eq $cnames($s)} return $s;
		}
	}
}
