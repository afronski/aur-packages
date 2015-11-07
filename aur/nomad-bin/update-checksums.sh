#!/bin/sh

set -e

source ./PKGBUILD

curl -OL "https://dl.bintray.com/mitchellh/nomad/nomad_${pkgver}_SHA256SUMS"

newsums="sha256sums_i686=('$(env grep nomad_${pkgver}_linux_386.zip nomad_${pkgver}_SHA256SUMS | cut -d' ' -f1)')
sha256sums_x86_64=('$(env grep nomad_${pkgver}_linux_amd64.zip nomad_${pkgver}_SHA256SUMS | cut -d' ' -f1)')
sha256sums_arm=('$(env grep nomad_${pkgver}_linux_arm.zip nomad_${pkgver}_SHA256SUMS | cut -d' ' -f1)')"

buildfile=${1:-PKGBUILD}
newbuildfile=$(mktemp --tmpdir updpkgsums.XXXXXX)
awk -v newsums="$newsums" '
	/^[[:blank:]]*(md|sha)[[:digit:]]+sums(_[^=]+)?=/,/\)[[:blank:]]*(#.*)?$/ {
		if (!w) {
			print newsums
			w++
		}
		next
	}

	1
	END { if (!w) print newsums }
' "$buildfile" > "$newbuildfile" || die 'Failed to write new PKGBUILD'
cat -- "$newbuildfile" >"$buildfile"
