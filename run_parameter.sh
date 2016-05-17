#!/bin/bash
redDir=/Users/jeremyfirst/RED-II.52-Tools-Files

Usage(){
    echo "Usage: $0 -m molecule [ options ] " 
    echo "   ($0 -h for help) "  
    exit 
}

HELP(){
    echo 
    echo "This script runs parameterization for a specified molecule" 
    echo "The results of this script should be taken WITH EXTREME CAUTION" 
    echo 
    echo "Note: This program is dependent on: " 
    echo "     1) GAMESS, Quantum mechanics software. " 
    echo "     2) RED-vIII perl scripts available at http://upjv.q4md-forcefieldtools.org/RED/" 
    echo "     3) antechamber, a part of AmberTools15 available at http://ambermd.org/#AmberTools" 
    echo "     4) acpype, a python script to run antechamber "
    echo "            available at https://code.google.com/archive/p/acpype/ " 
    echo 
    echo "Usage $0 -m molecule name [-f initial pdb (mol.pdb) ] [-e param.err ] [-l param.log ] " 
    echo "   -m mol      Specify molecule name (ie, bfa). No spaces or special characters" 
    echo "   -f *.pdb    Specify the starting pdb file.               Default: {molecule}.pdb " 
    echo "   -l logFile  Specify name of the logFile file.            Default: param.logFile " 
    echo "   -e err.txt  Specify name of the error file.              Default: param.err " 
    echo 
    echo "Example: $0 -m BFA -f bfa.pdb " 
    echo "      ## Parameterizes using basename BFA for files, starting from 'bfa.pdb' " 
    echo 
    echo "Be sure to read the README.txt for more information on installation and use. "
    echo 
    exit
}

## Option parsing. This is more or less adopted from the getopts tutorial 
##    at http://tuxtweaks.com/2014/05/bash-getopts/  
logFile=param.log 
errFile=param.err 
while getopts ":f:m:l:h" opt; do 
    case $opt in 
       f) 
         pdbFile=$OPTARG
         ;;
       m) 
         mol=$OPTARG
         ;;
       l) 
         logFile=$OPTARG
         ;;
       e) 
         errFile=$OPTARG
         ;; 
       h) 
         HELP 
         ;;
       \?) 
         echo "ERROR: Invalid option -$OPTARG" 
         Usage
         ;; 
       :) 
         echo "ERROR: option $OPTARG requires an argument! " 
         Usage
         ;; 
       esac 
       done 


## Check to make sure -m is used 
if [[ -z $mol ]] ; then 
    echo "ERROR: -m option must be used." 
    Usage
    exit
    fi 
## If -f is not used, construct default from molecule name -> mol.pdb 
if [[ -z $pdbFile ]] ; then 
    pdbFile=$mol.pdb 
    fi 

if [ ! -f $pdbFile ] ; then 
    echo "ERROR: Starting pdb file ($pdbFile) does not exist." 
    exit 
    fi 

## This function simply check to see if a file was created, and if not then 
##     it searches for errors in the log file and quits the program. 
check(){
    for arg in $@ ; do 
        if [ ! -f $arg ] ; then 
            echo "Failed" 
            printf "\t Printing Errors from .logFile and .err files\n\n\n\n"
            cat $logFile | grep -i Error
            cat $errFile | grep -i Error 
            printf "\n\t Check .log files for more info! \n\n\n" 
            exit 
            fi 
        done 
}

## Prepare *.p2n file for RED-vIII program input using Ante_RED
Ante(){
    printf "Running Ante-RED................................" 
    if [ ! -f Ante-Files/$mol-out.p2n ] ; then 
        perl $redDir/Ante_RED-1.5.pl $pdbFile >> $logFile 2>> $errFile 
        fi 
    if [ ! -d Ante-Files ] ; then mkdir Ante-Files ; fi 
    mv -v $mol-* Ante-Files/ >> $logFile 2>> $errFile
    mv -v Ante_out.txt Ante-Files/ >> $logFile 2>> $errFile 
    check Ante-Files/$mol-out.p2n 
    printf "Completed\n" 
} 

## Rename the p2n file for file-name conventions of RED-vIII. (ie, it automatically reads from filename Mol_red1.p2n) 
rename(){
    printf "Renaming mol.p2n file to Mol_red1.p2n..........."
    if [ ! -f Mol_red1.p2n ] ; then 
        cp -v Ante-Files/$mol-out.p2n Mol_red1.p2n >> $logFile 2>> $errFile 
        fi 
    check Mol_red1.p2n
    printf "Completed\n" 
} 

## Using RED-vIII perl script, we perform two tasks using GAMESS Quantum Mechanics software
##   1) Geometry optimization to the low energy configuration
##   2) Self-consistent field (SCF) calculation using the 6-31* basis state to obtain partial charges
##         for all atoms. 
RED(){
    printf "Running RED-vIII.5.pl..........................." 
    if [ ! -f Data-RED/Mol_m1-o1.mol2 ] ; then 
        perl $redDir/RED-vIII.5.pl >> $logFile 2>> $errFile 
        fi 
    check Data-RED/Mol_m1-o1.mol2
    printf "Completed\n" 
}

## Rename the output of RED-vIII to something more useful. 
rename_rd(){
    printf "Renaming output mol2 file of RED-vIII..........." 
    if [ ! -f $mol.mol2 ] ; then 
        cp -v Data-RED/Mol_m1-o1.mol2 $mol.mol2 >> $logFile 2>> $errFile 
        fi 
    check $mol.mol2  
    printf "Completed\n" 
}

## ACPYPE is a python script that runs antechamber, from AmberTools14
##   This program searches for necessary parameters from the molecular geometry, 
##     and pieces together from what it has in the Amber force field. 
##   The flag '-c user' allows the program to use the GAMESS generated partial charges and geometry. 
run_acpype(){
    printf "Running ACPYPE.................................."
    if [ ! -f $mol.acpype/$mol.itp ] ; then 
        acpype -i $mol.mol2 -c user -a amber --gmx45 -o gmx >> $logFile 2>> $errFile  
        fi 
    check $mol.acpype/$mol\_GMX.gro $mol.acpype/$mol\_GMX.itp $mol.acpype/$mol\_GMX.top 
    printf "Completed\n" 
}


##################################
########  Begin main program. ####
##################################
printf "\n\t**Program Beginning**\n\n" 
Ante
rename
RED
rename_rd
run_acpype
printf "\n\t**Program Complete**\n\n" 














