Usage: $0 -m molecule [ options ] " 
   ($0 -h for help) "  

This script runs parameterization for a specified molecule" 
The results of this script should be taken WITH EXTREME CAUTION" 

Note: This program is dependent on: 
     1) GAMESS, Quantum mechanics software
     2) RED-vIII perl scripts available at http://upjv.q4md-forcefieldtools.org/RED/" 
     3) antechamber, a part of AmberTools15 available at http://ambermd.org/#AmberTools" 
     4) acpype, a python script to run antechamber "
            available at https://code.google.com/archive/p/acpype/ " 

Usage $0 -m molecule name [-f initial pdb (mol.pdb) ] [-e param.err ] [-l param.log ] " 
   -m mol      Specify molecule name (ie, bfa). No spaces or special characters" 
   -f *.pdb    Specify the starting pdb file, if not mol.pdb " 
   -l logFile      Specify name of the logFile file. Default: param.logFile " 
   -e err.txt  Specify name of the error file. Default: param.err " 

Example: $0 -m BFA -f bfa.pdb " 
      ## Parameterizes using basename BFA for files, starting from 'bfa.pdb' " 

HowTo : 
  Installation: 
    Download and install GAMESS. (http://www.msg.ameslab.gov/gamess/download.html) 
    In the gamess folder, edit three variables in rungms. 
        1) SCR => This should be set to an empty scratch directory on the local disk. 
                  (ie, SCR=/Users/jeremyfirst/tmp) 
        2) USERSCR => Unless you are running on a cluster, this can be the same folder as SCR. 
                  (ie, USERSCR=/Users/jeremyfirst/tmp) 
        3) GMSPATH => This should be set to the gamess install location (ie, /Users/jeremyfirst/gamess) 
                  (ie, GMSPATH=/Users/jeremyfirst/gamess) 
    Make sure that the scratch folders exist, and are empty. 
        $ cd $HOME      ##Go to home directory. 
        $ mkdir tmp     ##Create directory
        $ rm tmp/*      ##Remove anything in the tmp directory. 
    Download and install RED-vIII (http://upjv.q4md-forcefieldtools.org/RED/) 
        In the RED-vIII.5..pl script, edit the variable NP (line 7341) 
            to reflect the correct number of CPUs on your machine. 
            (ie, $NP    = "2"   for a 2 CPU machine) 
    Edit run_parameter.sh 
        1) redDir => This needs to be set to the RED-III tools folder. 
           This is line #2. 
                 (ie, redDir=/Users/jeremyfirst/RED-II.52-Tools-Files) 
    Download and install AmberTools15 (http://ambermd.org/AmberTools15-get.html). This will take some time.  
        Be sure to add these executables to your path. 
    Download and install acpype (https://code.google.com/archive/p/acpype/). 

 Running the script: 
    Create a PDB structure of the ligand of interest. (Avagadro works nice) 
    Uniquely name each of the atoms in the file. 
        For each ATOM record, change field 3 to a unique name. 
    Create a new directory with just the pdb structure file and the run_parameter.sh script. 
        $ mkdir Parameterization
        $ cp ligand.pdb Parameterization/
        $ cp run_parameter.sh Parameterization/
        $ cd Parameterization/ 
        $ ./run_parameter.sh -m BFA -f ligand.pdb 
    This should run the necessary scripts to parameterize your ligand! It will take several hours to run. 

Workflow: 
    PDB Structure  =>    p2n structure and GAMESS inputs   =>   Partial Charges    =>      Gromacs topology 
                 Ante_RED                                GAMESS                 Antechamber
                                                    (run by RED-vIII)           (run by acpype.py)  



