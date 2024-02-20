!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!	This file contains the modules:
!!	(mod_parfile, mod_data_arrays)
!!	Author:	Clara Estela Jimenez Tejero. 
!!	License: GNU General Public License v3.0
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module mod_parfile

implicit none

  ! Control file variables
  integer :: homog
  integer :: nxmodel,nzmodel,frames,model,asize
  integer :: NumShots,NumRec,PML,accuracy	
  real :: dmodel,time,xmax,zmax
  real :: freq,v1,v2
  real :: shotx,shotz,recx,recz

  character(len=500) :: cpt_model,cpt_solver
  character(len=500) :: folder_output
  character(len=500) :: test_name,test,model_name
  character(len=500) :: signal_name,source_name,gif_name,solver_name
  character(len=500) :: par_file

  contains

  subroutine read_parfile()

  implicit none

  integer :: numtasks,rank,ierr,errcode!,status(MPI_STATUS_SIZE)

  ! Input related variables
  character(len=200) :: buffer,label
  integer :: ps,icount,i,ifile,interval,nlines
  integer, parameter :: fh = 10
  integer :: ios = 0
  integer :: line = 0

  character(len=500) :: command0,command
  character(len=50) :: Str,access,form,num_split
  character(len=500) :: file_name

  logical :: input_exist,output_exist,parfile_exist

  ierr=0;rank=0;numtasks=1;

  access = 'STREAM'
  form = 'UNFORMATTED'

  icount = iargc()  ! The number does not includes the executable name, so if user passed one argument, 1 is returned.
!!  if ( icount.eq.1 ) then
	call getarg(1, par_file)	! The file name of the executable.
	if(rank.eq.0)write(*,*)'name par_file: ',trim(adjustl(par_file))
	file_name = trim(adjustl(par_file))
	INQUIRE(file=file_name,EXIST=parfile_exist)
	if(.NOT. parfile_exist)     then
  		if(rank.eq.0)write(*,*)'WARNING: Par_file named: ', trim(adjustl(par_file)),' does not exist'
  		if(rank.eq.0)write(*,*)'THEREFORE: running the program for default parameters'
		
  	endif
!!  endif

  NumShots=1
  NumRec=1
  call getcwd(folder_output)
  homog=1

  nxmodel= 100
  nzmodel= 100
  shotx= nxmodel/2
  shotz= nzmodel/2
  recx= nxmodel/2
  recz= nzmodel/2
  dmodel= 0.025
  model= 1
  v1= 1.5
  v2= 1.5
  asize= 10
  time= 5
  freq= 20
  frames= 50
  PML= 50
  accuracy=3
  cpt_model="gray"
  cpt_solver="gray"
  test="default"


  if(parfile_exist)     then

  open(fh, file=par_file)

  ! ios is negative if an end of record condition is encountered or if
  ! an endfile condition was detected. It is positive if an error was
  ! detected.  ios is zero otherwise.


  do while (ios == 0)
     read(fh, '(A)', iostat=ios) buffer
     if (ios == 0) then
        line = line + 1

        ! Find the first instance of whitespace.  Split label and data.
        ps = scan(buffer,' ')
        label = buffer(1:ps)
        buffer = buffer(ps+1:)

        select case (label)

        case ('folder_output:')
           read(buffer, *, iostat=ios) folder_output
        case ('nxmodel:')
           read(buffer, *, iostat=ios) nxmodel
        case ('nzmodel:')
           read(buffer, *, iostat=ios) nzmodel
        case ('dmodel:')
           read(buffer, *, iostat=ios) dmodel
        case ('shotx:')
           read(buffer, *, iostat=ios) shotx
        case ('shotz:')
           read(buffer, *, iostat=ios) shotz
        case ('recx:')
           read(buffer, *, iostat=ios) recx
        case ('recz:')
           read(buffer, *, iostat=ios) recz
        case ('model:')
           read(buffer, *, iostat=ios) model
        case ('asize:')
           read(buffer, *, iostat=ios) asize
        case ('v1:')
           read(buffer, *, iostat=ios) v1
        case ('v2:')
           read(buffer, *, iostat=ios) v2
        case ('time:')
           read(buffer, *, iostat=ios) time
        case ('freq:')
           read(buffer, *, iostat=ios) freq
        case ('frames:')
           read(buffer, *, iostat=ios) frames
        case ('PML:')
           read(buffer, *, iostat=ios) PML
        case ('accuracy:')
           read(buffer, *, iostat=ios) accuracy
        case ('test_name:')
           read(buffer, *, iostat=ios) test
        case ('cpt_model:')
           read(buffer, *, iostat=ios) cpt_model
        case ('cpt_solver:')
           read(buffer, *, iostat=ios) cpt_solver
        case default
           if(rank.eq.0)print *, 'WARNING in file ',trim(adjustl(par_file)),': skipping invalid label at line', line

        end select
     end if
  end do

 close(fh)

endif

if(v1.ne.v2) homog=0

if(frames.ge.100)	then
	write(*,*)"NUM OF FRAMES MUST BE LESS THAN 100"
	stop
endif

folder_output = trim(adjustl(folder_output)) // '/'
test_name = trim(adjustl(folder_output)) // trim(adjustl(test))
model_name = trim(adjustl(test_name)) // '_model.dat'
signal_name = trim(adjustl(test_name)) // '_signal.dat'
source_name = trim(adjustl(test_name)) // '_source.dat'
solver_name = trim(adjustl(test_name)) // '_solver_frame_'
gif_name = trim(adjustl(test_name)) // '_solver.gif'

if(rank.eq.0)	then

	write(*,*)
	write(*,*)'*******************************************'
	write(*,*)'RUNNING PROGRAM FOR THESE PARAMETERS'
	write(*,*)'*******************************************'

  	write(*,*)"folder_output: ",trim(adjustl(folder_output))
  	write(*,*)"model_name: ",trim(adjustl(model_name))
  	write(*,*)"signal_name: ",trim(adjustl(signal_name))
  	write(*,*)"source_name: ",trim(adjustl(source_name))
  	write(*,*)"solver_name: ",trim(adjustl(solver_name))
  	write(*,*)"gif_name: ",trim(adjustl(gif_name))
  	write(*,*)"dmodel: ",dmodel
	write(*,*)"nxmodel: ",nxmodel
	write(*,*)"nzmodel: ",nzmodel
	write(*,*)"model: ",model
	write(*,*)"v1: ",v1
	write(*,*)"v2: ",v2
	write(*,*)"asize: ",asize
	write(*,*)"freq:", freq
	write(*,*)"time: ",time
	write(*,*)"shotx: ",shotx
	write(*,*)"shotz: ",shotz
	write(*,*)"recx: ",recx
	write(*,*)"recz: ",recz
	write(*,*)"frames: ",frames
	write(*,*)"PML:", PML

endif

xmax=(nxmodel-1)*dmodel
zmax=(nzmodel-1)*dmodel

end subroutine read_parfile

end module mod_parfile

module mod_data_arrays

implicit none

        integer, allocatable :: pos_shotx_grid(:) !!position shot, no dimensions (points)
        integer, allocatable :: pos_shotz_grid(:) !!position shot, no dimensions (points)
        integer, allocatable :: pos_recx_grid(:) !!position obs x
        integer, allocatable :: pos_recz_grid(:) !!position obs z
 	integer, allocatable :: nxSou(:),nzSou(:),nxRec(:),nzRec(:)
        real, allocatable :: pos_shotx(:) !!position shot
        real, allocatable :: pos_shotz(:) !!position shot
        real, allocatable :: pos_recx(:) !!position obs x
        real, allocatable :: pos_recz(:) !!position obs z
	real, allocatable :: Model_ini(:,:)

contains

subroutine allocate_data_arrays()

use mod_parfile

	implicit none
	integer :: i,j

        	allocate(pos_shotx(NumShots),pos_shotx_grid(NumShots))
        	allocate(pos_shotz(NumShots),pos_shotz_grid(NumShots))
		allocate(pos_recx(NumRec),pos_recz(NumRec))
		allocate(pos_recx_grid(NumRec),pos_recz_grid(NumRec))
		allocate(nxSou(NumShots),nzSou(NumShots),nxRec(NumRec),nzRec(NumRec))!en SS
		allocate(Model_ini(nzmodel,nxmodel))

        	pos_shotx=0;pos_shotx_grid=0;
        	pos_shotz=0;pos_shotz_grid=0;
        	pos_recx=0;pos_recx_grid=0;
        	pos_recz=0;pos_recz_grid=0;
		nxSou=0;nzSou=0;nxRec=0;nzRec=0;
		Model_ini=0.

end subroutine allocate_data_arrays

subroutine deallocate_data_arrays()

        deallocate(pos_shotx,pos_shotx_grid)
        deallocate(pos_shotz,pos_shotz_grid)
        deallocate(pos_recx,pos_recx_grid)
        deallocate(pos_recz,pos_recz_grid)
	deallocate(nxSou,nzSou,nxRec,nzRec) 
	deallocate(Model_ini)

end subroutine deallocate_data_arrays

end module mod_data_arrays
