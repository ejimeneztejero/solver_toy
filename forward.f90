subroutine forward()

use mod_parfile
use mod_data_arrays

	implicit none

	integer :: i,j,k,nt
	real :: dt
	real, allocatable :: Data_synth(:)
	real, allocatable :: Data_source(:)
	
!	character(len=1000) :: file_name

	!TAG=0
	
	!!!!!------ New time sampling
	
	dt=dmodel/maxval(Model_ini)/2.5
	nt=1+ceiling(time/dt)
			
        write(*,*)
	write(*,*)'nt, dt: ',nt,dt

	!!!!!------ Allocate Synthetic trace matrix

	allocate(Data_synth(nt))
	allocate(Data_source(nt))

	call Ricker(nt,dt,Data_source)

	!!!!!---------------------   	    
	!!!!!------ Forward solver
	!!!!!---------------------

        write(*,*)
	write(*,*)"Forward solver ..."

        call solver_acoustic(NumShots,NumRec,nxSou,nzSou,nxRec,nzRec,&	!!ojo cambiar la subrutina
       	Data_source,dmodel,dt,nxmodel,nzmodel,Model_ini,nt,Data_synth,&
	frames,solver_name,PML,accuracy)

        write(*,*)
	write(*,*)'... writting data in: ',trim(folder_output)

        open(unit=12,file=signal_name,status='unknown')
        do j=1,nt
	        write(12,*) (j-1)*dt, Data_synth(j)
	enddo
        close(12)

	!!escribir resultado
                        
	!!!!!-------------------------	    
	!!!!!------ End Forward solver
	!!!!!-------------------------

end subroutine forward
