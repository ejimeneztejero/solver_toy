program Inversion_Main

use mod_parfile
use mod_data_arrays

implicit none
character(len=1000) :: command
character(len=50) :: str_d,str_x,str_z,str_f,str_h

	call get_data()
	call forward()
	call deallocate_data_arrays()

!!	Call MGT script which prints the model and the propagation together, and makes a gif video from jpg images	
	write(*,*)
	write(*,*)"RUNNING GMT SCRIPT"
	write(*,*)

        write(str_d,*) dmodel
        write(str_x,*) xmax
        write(str_z,*) zmax
        write(str_f,*) frames
        write(str_h,*) homog

	command = 'bash plot_solver.sh ' // trim(adjustl(str_d)) // &
              ' ' // trim(adjustl(str_x)) // &
              ' ' // trim(adjustl(str_z)) // &
              ' ' // trim(adjustl(str_f)) // &
              ' ' // trim(adjustl(str_h)) // &
              ' ' // trim(adjustl(folder_output)) // &
              ' ' // trim(adjustl(model_name)) // &
              ' ' // trim(adjustl(solver_name)) // &
              ' ' // trim(adjustl(gif_name)) // &
              ' ' // trim(adjustl(cpt_model)) // &
              ' ' // trim(adjustl(cpt_solver))

	write(*,*)trim(adjustl(command))
	write(*,*)

	call SYSTEM(command)

end program Inversion_Main
