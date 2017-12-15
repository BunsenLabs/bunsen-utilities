# genman.sh
# script to generate man files from executables' --help options,
# using help2man.

# Put this script in the package source debian/ directory,
# add a file genman-list or <packagename>.genman-list
# with a list of the executables whose manpages are to be built.
# Shell globs may be used, but spaces in filenames or paths may not.
#
# Built manpages will be put in debian/genman-pages, and
# their paths will be appended to an existing debian/*manpages file,
# or put in a new one (following the naming rule of genman-list).
#
# genman.sh --clean will return everything to its previous state.
#
# Run the script manually before building the package,
# or to auto-run, add this to debian/rules:
#
#override_dh_installman:
#	sh debian/genman.sh
#	dh_installman
#
#override_dh_clean:
#	dh_clean
#	sh debian/genman.sh --clean
#

set -e

src_name=$(dpkg-parsechangelog -S Source)
pkg_ver=$(dpkg-parsechangelog -S Version)

workdir=debian # Should match the path set in debian/rules.

includes="[authors]
Written by the BunsenLabs team.

[reporting bugs]
Please report bugs at
https://github.com/BunsenLabs/${src_name}/issues

[see also]
The BunsenLabs forums may be able to answer your questions

https://forums.bunsenlabs.org
"
### it may not be necessary to edit below this line ###

pkg_name="$src_name"
manpg_dir="${workdir}"/genman-pages
mkdir -p "$manpg_dir"

include_file="${workdir}"/genman.include

### functions ###

# pass file with list of executables to make manpages for,
# with file or shell glob on each line
build_mans() {
    local line file
    while read -r line
    do
        [ -f "$line" ] && {
            mk_man "$line"
            continue
        }
        for file in $line # shell glob
        do
            [ -f "$file" ] || continue
            mk_man "$file"
        done
    done < "$1"
}

# pass executable file
mk_man() {
    local exec="$1"
    local cmd=${1##*/}
    chmod +x "$exec"
    default_desc="a script provided by ${pkg_name}"
    desc="$( "$exec" --help | sed -rn "/^ *$cmd/ {s/^ *$cmd( -|:| is)? *//p;q}")"
    [ -z "$desc" ] && desc="$default_desc"
    help2man "$exec" --no-info --no-discard-stderr --version-string="$cmd $pkg_ver" --name="$desc" --include="$include_file" | sed "s|$HOME|~|g" > "${manpg_dir}/${cmd}.1"
    chmod -x "$exec"
    echo "${manpg_dir}/${cmd}.1" >> "${manpages_file}"
}

### script starts here ###

case $1 in
--clean)
    rm -rf "$manpg_dir"
    # avoid cleaning existing files
    [ -f "$include_file" ] && rm -f debian/*manpages
    rm -rf "$include_file"
    for i in debian/*.genman.bak # restore backups
    do
        [ -f "$i" ] || continue
        mv "$i" "${i%.genman.bak}"
    done
    exit 0
    ;;
esac

# avoid multiple runs
[ -f "$include_file" ] && {
    echo "$0: manpages already built" >&2
    exit 1
}

# backup any existing manpages files
for file in debian/*manpages
do
    [ -f "$file" ] || continue
    cp "$file" "$file".genman.bak
done

cat <<EOF > "$include_file"
$includes
EOF

for list in debian/*.genman-list
do
    [ -f "$list" ] || continue
    found_list=true
    pkg_name="${list##*/}"
    pkg_name="${pkg_name%.genman-list}"
    manpages_file=debian/${pkg_name}.manpages
    build_mans "$list"
done

if [ "$found_list" != true ] && [ -f debian/genman-list ]
then
    manpages_file=debian/manpages
    build_mans debian/genman-list
fi
