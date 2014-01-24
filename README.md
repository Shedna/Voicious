# Voicious

**Voicious** is an open source web application allowing everyone to enjoy video conferencing.
Aimed as well for private using than for enterprises, its ease of use and its ergonomy are its main strengths.

## Install

To install **Voicious**' dependencies, build the project and its documentation, run `npm install` from the root directory.  

## Configuration

All configuration variables are defined in `etc/config.json`.  
You can define in this file your database configuration (connector, host, username etc.) and listenning addresses and ports for both the **Voicious** server and its websocket server.

## Run

Run one of the following commands from the root directory to run the Voicious server :  
<pre><code>npm start
coffee ./app/startup.coffee</code></pre>

## Licensing

Copyright &copy; 2011-2013  **Voicious**  
  
This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.  
  
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.  
  
You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.  
