# solver_toy
An acoustic solver code to understand propagation with finite differences in toy models

# README

## Author
Clara Estela Jimenez Tejero - ICM-CSIC (Barcelona) - Barcelona-CSI

## Description
This example demonstrates the propagation from one source to one receiver through a benchmark velocity model. Parameters for the simulation are contained in the "parfile". The benchmark model consists of a homogeneous velocity model with an anomaly in the middle.

## Outputs
- In the "output" folder, data generated after running the program will be stored. Outputs include:
  - "model.dat"
  - "signal.dat"
  - "solver_frame_i.dat" (where i=1,n, depending on the number of frames selected in "parfile")
  - "solver.gif", resulting from running the plot.sh script based on GMT (automatically executed from Fortran)

## Execution
- To execute, type in the terminal:

	solver parfile

- An example "parfile" named "parfile_example" is included in this folder.

## Defaults: if no "parfile" is provided, default parameters will be used. These are the default parameters or the default "parfile" used by the code:
- test_name: "default"
- nxmodel: 100
- nzmodel: 100
- shotx: 50
- shotz: 50
- recx: 50
- recz: 50
- dmode: 0.025
- model: 1
- v1: 1.5
- v2: 1.5
- time: 5
- freq: 20
- frames: 50
- PML: 50
- accuracy: 3
- cpt_model: "gray"
- cpt_solver: "gray"

## Meaning of the different parameters that can be included by the user in the parfile:
- "test_name": name added to the output files
- "output_folder": name of the folder to store results (path must be included if folder is located outside the location of "parfile")
- "nxmodel": number of points in X (length)
- "nzmodel": number of points in Z (depth)
- "shotx": position of source in X (point, adimensional)
- "shotz": position of source in Z ("")
- "recx": position of receiver in X ("")
- "recz": position of receiver in Z ("")
- "dmodel": distance between points in the grid (km)
- "model": type of anomaly used (1 for solid circle, 2 for solid square)
- "v1": velocity value for the background
- "v2": velocity value for the anomaly
- "asize": size of the anomaly (points, adimensional). For anomaly 1, it is the radius of the circle; for anomaly 2, it is the half length of the square.
- "time": total propagation time for the simulation
- "freq": central frequency for the Ricker function used as a source
- "frames": number of frames to print the output data of the propagation
- "PML": number of layers at the PMLs at each border of the model
- "accuracy": number referring to the accuracy for the finite difference (options: 3 or 4)
- "cpt_model": name for the palette in GMT used for the velocity model
- "cpt_solver": name for the palette in GMT used for solver propagation
