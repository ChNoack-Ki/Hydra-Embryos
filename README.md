# Hydra-Embryos
Sofware for Analysis: R, Python, MatLab

1)Repositoy contains codes for analysing Hydra-embryo data, including first data processing and generation synchronization plots
"function.R" is needed to run "Final-GCaMP6S-analysis-pipeline_batch.R"
 - 

2) To run the code with the Leiden algorithm, Python is required. Install the leidenalg package as explained in 'How To Run Python From Matlab'.
Alternatively, the Louvain algorithm implemented in Matlab (taken from Lovas and Yuste, 2021, 10.1016/j.cub.2021.06.047) can be used. To switch to this algorithm, go to the folder 'codeForDataAnalysis, open 'analyseData.m', and change the variable 'commDetectionMethod' to 'Louvain'.

3) To evaluate the long-term analyses of the Hydra hatchlings, the folder 'dataForPaper' is loaded into the working directory of Matlab. The structure of this folder is as follows:
- dataForPaper
	- Hxx
		- Hxx-1.csv
		- Hxx-2.csv
		- ...
		- stages.txt
		- coordinates
			- Hxx-1_Position-X.csv
			- Hxx-1_Position-Y.csv
			- Hxx-2_Position-X.csv
			- Hxx-2_Position-Y.csv
			- ...

Here, xx is the number of the recording (e.g.,64). The text-file stages includes a list of the analyses per hatchling to be analyzed. Considering, for instance, xx=64, the file includes 'H64-1, H64-2, H64-3'

4) Setup of Anaconda for Executing Louvain Algorithm

-	Check for required python version for used Matlab version. See
https://de.mathworks.com/support/requirements/python-compatibility.html
-	Create new environment with required python version, e.g. conda create -n py38 python=3.8
-	Activate new environment with conda activate py38
-	Install leidenalg package: conda install --name py38 conda-forge::leidenalg
-	Install missing packages:
o	numpy (conda install --name py38 -c anaconda numpy)
o	pycairo (conda install --name py38 conda-forge::pycairo) OR
o	cairocffi (conda install --name py38 conda-forge::cairocffi)

5) Setup of Python for Matlab
-	Locate the path of your python installation. Typically C:\Users\USERNAME\anaconda3\python.exe
-	Add this path to your matlab path or execute  pyenv("Version","C:\Users\USERNAME\Anaconda3\python.exe") in your script
-	Done. You should now be able to run the Matlab runMe files

Note: Only tested for an installation of Python via Anaconda on Windows 10


