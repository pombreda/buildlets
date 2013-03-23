## Buildlets

An eclectic collection of single file, minimal dependency, PowerShell-based
build recipes for creating libraries and executables on mingw/minw-w64
Windows systems.

In contrast with other well known port-style systems, buildlets enable one to
quickly build binary artifacts with minimal ceremony and minimal persistent
configuration. Typically one downloads a buildlet, runs it, and gets a binary
archive. What you do next is up to you.

Buildlets are very mercenary in their focus and actions. No interdependency
management. No complex configuration nor massive directory trees of persistent
local data. As such, the buildlet system will always be a tradeoff between
minimalism and modular reusability.

## Dependencies

* PowerShell 2.0+
* Live internet connection
* MinGW or mingw-w64 based toolchain with MSYS, Autotools, and Perl superpowersl

## Basic Usage

Assuming you have a capable mingw or mingw-w64 toolchain already installed, typical
usage can be as simple as the following:

1. Open PowerShell
2. Download and execute `bootstrap.ps1` to fetch build tools and, optionally, an
   initial buildlet

        PS foo> .\bootstrap.ps1 build_lua
        ---> creating C:\Users\Jon\Downloads\temp\foo\tools
        ---> downloading tool: 7za.exe
        ---> downloading build_lua.ps1

3. Execute the buildlet

        PS foo> .\build_lua.ps1 5.2.1
        ---> fetching buildlet library
        ---> downloading http://www.lua.org/ftp/lua-5.2.1.tar.gz
        ---> validating lua-5.2.1.tar.gz
        ---> extracting lua-5.2.1.tar.gz
        ---> activating toolchain
        ---> configuring lua-5.2.1
        ---> building lua-5.2.1
        ---> creating binary archive for lua-5.2.1
        ---> cleaning up

## License

3-clause BSD
