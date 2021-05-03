#!/usr/bin/env php
<?php
/*
 * Checks if a port can be listened on
 *
 * Copyright (C) 2021 Seiden Group
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

/*
 * CB 20210503:
 *
 * This is based on the PHP sockets example and just operates solely on TCP &
 * IPv4. We don't need other layer 4 protocols, but IPv6 would probably be
 * useful too.
 *
 * It's in PHP because we don't have netcat/nc for doing it from shell, doing
 * it in C is pointless until we need to i.e refer to ILE APIs, and we need
 * PHP installed regardless, so adding the socket extension to the mix is OK.
 *
 * TODO:
 *
 * - getopt to get i.e. layer 3 protocol, show messages (if interactive, etc.)
 * - actually check if it's because it's in use vs. other possible errors; we
 *   already distinguish if it's at socket/bind/listen, tho they seem unlikely
 * - convert to C, do what netstat does and tell us the job using the socket
 *   if the port is already used
 */

$address = "0.0.0.0";
$port = (int)($argv[1]);

// we don't care about PHP warnings, since we check for errors and exit
if (($sock = @socket_create(AF_INET, SOCK_STREAM, SOL_TCP)) === false) {
    //echo "socket_create() failed: reason: " . socket_strerror(socket_last_error()) . "\n";
    exit(1);
}

if (@socket_bind($sock, $address, $port) === false) {
    //echo "socket_bind() failed: reason: " . socket_strerror(socket_last_error($sock)) . "\n";
    exit(2);
}

if (@socket_listen($sock, 5) === false) {
    //echo "socket_listen() failed: reason: " . socket_strerror(socket_last_error($sock)) . "\n";
    exit(3);
}

exit(0);
