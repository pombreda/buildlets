#requires -version 2.0

# Author: Jon Maken
# License: 3-clause BSD
# Revision: 2013-03-26 21:17:58 -0600
#
# TODO:
#   - extract generics into a downloadable utils helper module
#   - add x86/x64 dynamic package naming

param(
  [parameter(Mandatory=$true,
             Position=0,
             HelpMessage='liblzma version to build (eg - 5.0.4).')]
  [validateset('5.0.4')]
  [alias('v')]
  [string] $version,

  [parameter(HelpMessage='Path to DevKit root directory')]
  [string] $devkit = $nil
)

$libname = 'xz'
$source = "${libname}-${version}.tar.bz2"
$source_dir = "${libname}-${version}"
$repo_root = 'http://tukaani.org/xz/'
$archive = "${repo_root}${source}"
$hash_uri = "https://raw.github.com/jonforums/buildlets/master/hashery/${libname}.sha1"

# download and source the buildlet library
if (-not (Test-Path "$PWD\buildlet_utils.ps1")) {
  Write-Host '---> fetching buildlet library' -foregroundcolor yellow
  try {
    $fetcher = New-Object System.Net.WebClient
    $fetcher.DownloadFile('https://raw.github.com/jonforums/buildlets/master/buildlet_utils.ps1',
                          "$PWD\buildlet_utils.ps1")
  }
  catch {
    throw '[ERROR] unable to fetch required buildlet library'
  }
}
. "$PWD\buildlet_utils.ps1"

# download source archive
Fetch-Archive

# download hash data and validate source archive
Validate-Archive

# extract
Extract-Archive

# patch, configure, build, archive
Push-Location "${source_dir}"

  # activate toolchain
  Activate-Toolchain

  # configure tools
  Configure-Build {
    New-Item "$install_dir/bin","$install_dir/include","$install_dir/include/lzma", `
             "$install_dir/lib","$install_dir/doc" -itemtype directory | Out-Null
    $cfg_args = @('--disable-nls'
                  '--disable-scripts'
                  '--disable-threads'
                  '--disable-shared'
                  '--enable-small'
                  "CFLAGS='-Os'")
    sh -c "./configure $($cfg_args -join ' ')" | Out-Null
  }

  # build tools
  New-Build {
    sh -c "make" | Out-Null
  }

  # install tools and clean
  cp src/xzdec/xzdec.exe, src/xzdec/lzmadec.exe "$install_dir/bin" | Out-Null
  cp src/lzmainfo/lzmainfo.exe "$install_dir/bin" | Out-Null
  sh -c "make distclean" | Out-Null

  # configure primary xz.exe tool and developer libraries
  Configure-Build {
    $cfg_args = @('--disable-nls'
                  '--disable-scripts'
                  '--disable-threads'
                  "CFLAGS='-O2'")
    sh -c "./configure $($cfg_args -join ' ')" | Out-Null
  }

  # build
  New-Build {
    Push-Location 'src/liblzma'
      sh -c "make" | Out-Null
    Pop-Location
    Push-Location 'src/xz'
      sh -c "make LDFLAGS=-static" | Out-Null
    Pop-Location
  }

  # install
  cp src/xz/xz.exe "$install_dir/bin" | Out-Null
  cp src/liblzma/.libs/liblzma-*.dll "$install_dir/bin/liblzma.dll" | Out-Null
  cp src/liblzma/api/lzma.h "$install_dir/include" | Out-Null
  cp src/liblzma/api/lzma/*.h "$install_dir/include/lzma" | Out-Null
  cp src/liblzma/.libs/liblzma.a "$install_dir/lib" | Out-Null
  cp src/liblzma/liblzma.def "$install_dir/lib" | Out-Null
  cp doc/man/txt/xz.txt, doc/man/txt/xzdec.txt, doc/man/txt/lzmainfo.txt `
     "$install_dir/doc" | Out-Null
  cp doc/xz-file-format.txt, doc/lzma-file-format.txt "$install_dir/doc" | Out-Null
  cp doc/examples, doc/examples_old "$install_dir/doc" -recurse | Out-Null

  # archive
  Archive-Build

  # hoist binary archive to top level
  Move-ArchiveToRoot

Pop-Location

# cleanup
Clean-Build