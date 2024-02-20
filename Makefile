#!/bin/bash
FC	= gfortran
FFLAGS  = -O3 #-Wargument-mismatch
LFLAGS  = $(FFLAGS)
EXE     = solver
SRC	= modules.f90 \
	00-main.f90  get_data.f90 forward.f90 solver.f90

# No need to edit below this line
.SUFFIXES: .f90 .o

OBJ = $(SRC:.f90=.o)

.f90.o:
	$(FC) $(FFLAGS) -c $<

all: $(EXE)

$(EXE): $(OBJ)
	$(FC) $(LFLAGS) -o $@ $(OBJ)

$(OBJ): $(MF)

tar:
	tar cvf $(EXE).tar $(MF) $(SRC)

clean:
	rm -f $(OBJ) $(EXE) core

