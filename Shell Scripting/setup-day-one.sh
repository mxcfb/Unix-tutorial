#!/bin/bash
set -e

myARCHIVE="shell-scripting-sci-day1.tar.gz"

if [ ! -r "${myARCHIVE}" ] ; then
	echo "Cannot read ${myARCHIVE} - aborting." >&2
	exit 1
fi

if [ -z "${1}" ] ; then
	myINPUT=""
	read -p "Enter directory to unpack archive: " myINPUT
else
	myINPUT="${1}"
fi

if [ -z "${myINPUT}" ] ; then
	echo "The empty string is not a valid directory!" >&2
	exit 1
fi

if type -p perl &>/dev/null ; then
	myPERLGLOB="print glob(\"${myINPUT}\");"
	myINPUT="$(perl -e "${myPERLGLOB}")"
fi	

if [ -e "${myINPUT}" ] &&
   [ ! -d "${myINPUT}" ] ; then
	echo "${myINPUT} already exists, but is not a directory!" >&2
	exit 1
else
	if [ ! -d "${myINPUT}" ] ; then
		mkdir --parents "${myINPUT}"
	fi
fi

myDIR="$( set -e ; cd "${myINPUT}" ; pwd -P )"
# Escape "/" characters in directory path for sed.
mySED_DIR="$( echo "${myDIR}" | awk 'gsub ("/", "\\/")')"

echo "Extracting ${myARCHIVE} to ${myDIR}..."
tar -C "${myDIR}" -xvzf "${myARCHIVE}"

echo "Setting up shell scripts..."
for zzSCRIPT in "${myDIR}"/${myARCHIVE%.tar.gz}/setup/*.sh ; do
	sed -i -e "s/relative to the HOME directory/relative to ${mySED_DIR}\/${myARCHIVE%.tar.gz}/" "${zzSCRIPT}"
	sed -i -e "s/^cd$/cd \"${mySED_DIR}\/${myARCHIVE%.tar.gz}\"/" "${zzSCRIPT}"
done
sed -i -e "s/Change to my home directory/Change to ${mySED_DIR}\/${myARCHIVE%.tar.gz}/" "${myDIR}"/${myARCHIVE%.tar.gz}/setup/cleanup-prog-dir.sh
sed -i -e "s/as directories are relative to home/as directories are relative to ${mySED_DIR}\/${myARCHIVE%.tar.gz}/" "${myDIR}"/${myARCHIVE%.tar.gz}/setup/cleanup-prog-dir.sh
sed -i -e "s/^cd$/cd \"${mySED_DIR}\/${myARCHIVE%.tar.gz}\"/" "${myDIR}"/${myARCHIVE%.tar.gz}/setup/cleanup-prog-dir.sh
sed -i -e "s/^[[:space:]]*myPROGS=.*/myPROGS=\"${mySED_DIR}\/${myARCHIVE%.tar.gz}\/source\"/" "${myDIR}"/${myARCHIVE%.tar.gz}/answers/cleanup-prog-dir.sh
sed -i -e "s/^[[:space:]]*myBACKUPS=.*/myBACKUPS=\"${mySED_DIR}\/${myARCHIVE%.tar.gz}\/backup\"/" "${myDIR}"/${myARCHIVE%.tar.gz}/answers/cleanup-prog-dir.sh
sed -i -e "s/Changing to home directory/Changing to ${mySED_DIR}\/${myARCHIVE%.tar.gz}/" "${myDIR}"/${myARCHIVE%.tar.gz}/answers/setup-play.sh
sed -i -e "s/cd$/cd \"${mySED_DIR}\/${myARCHIVE%.tar.gz}\"/" "${myDIR}"/${myARCHIVE%.tar.gz}/answers/setup-play.sh
sed -i -e "s/\"\${HOME}\/scripts\/run-once.sh\"/\"${mySED_DIR}\/${myARCHIVE%.tar.gz}\/scripts\/run-once.sh\"/" "${myDIR}"/${myARCHIVE%.tar.gz}/scripts/multi-run.sh
sed -i -e "s/cd$/cd \"${mySED_DIR}\/${myARCHIVE%.tar.gz}\"/" "${myDIR}"/${myARCHIVE%.tar.gz}/source/cleanup-prog-dir.sh

echo "Ready to go!"
echo -e "\nChange to the ${myDIR}/${myARCHIVE%.tar.gz} directory:"
echo "        cd ${myDIR}/${myARCHIVE%.tar.gz}"
echo "and read the README file there:"
echo "        more README"
echo -e "\nThere is an exercise for you to try in the"
echo "  ${myDIR}/${myARCHIVE%.tar.gz}/gnuplot directory."
echo -e "Read the README.exercise file in that directory for details.\n"
exit 0
