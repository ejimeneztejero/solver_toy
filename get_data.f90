!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!	This file contains subroutines for extracting input data features
!!	Author:	Clara Estela Jimenez Tejero. 
!!	License: GNU General Public License v3.0
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

subroutine get_data()

USE mod_parfile
USE mod_data_arrays

implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

call read_parfile()
call allocate_data_arrays()
call get_geometry_shot()
call get_geometry_rec()
call get_geometry()
call get_model()

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

end subroutine get_data

subroutine get_geometry_shot()	!!de aqui podriamos sacar nxmodel tb

USE mod_parfile
USE mod_data_arrays

implicit none

        integer :: i

!!	LECTURA DATOS SHOTGATHERS
        do i=1,NumShots !!number of lines nav_shot

                pos_shotx(i) = (shotx-1)*dmodel
                pos_shotx_grid(i)=shotx

		pos_shotz(i) = (shotz-1)*dmodel
		pos_shotz_grid(i) = shotz
        enddo

end subroutine get_geometry_shot

subroutine get_geometry_rec()

USE mod_parfile
USE mod_data_arrays

implicit none

        integer :: i

        do i=1,NumRec 

                pos_recx(i) = (recx-1)*dmodel
                pos_recx_grid(i)=recx

                pos_recz(i) = (recz-1)*dmodel
                pos_recz_grid(i)=recz

        enddo


end subroutine get_geometry_rec


subroutine get_geometry()

USE mod_parfile
USE mod_data_arrays

implicit none
integer :: i,j,k


do k=1,NumShots
	nxSou(k)=pos_shotx_grid(k)  
	nzSou(k)=pos_shotz_grid(k)  
enddo

!! RECEIVERS IN THE INVERSION ARE THE SHOTS (SON FIJOS)
do i=1,NumRec
	nxRec(i)=pos_recx_grid(i)
	nzRec(i)=pos_recz_grid(i)
enddo

end subroutine get_geometry

subroutine Ricker(nt,dt,data_source)

use mod_parfile

implicit none

	integer :: i,j,k,nt
	real :: data_source(nt)
        real :: pi,f0,wc,t0,tmp,S0(nt),t(nt)
        real :: n,dt
	character(len=100) :: file_name

        !!!!!------ Using a Ricker wavelet as impulse

        pi=3.14159265
        f0=freq
        wc=f0*2*pi
        t0=1.5/f0
        tmp=10./f0

        do i=1,nt
                t(i)=(i-1)*dt
        enddo

	S0=(1.-2.*(pi*f0*(t-t0))**2)*exp(-1.*(pi*f0*(t-t0))**2)

        do i=1,nt
                if(t(i).ge.tmp)then
                        S0(i)=0.
                endif
        enddo

        file_name=trim(adjustl(source_name))
	open(unit=12,file=file_name,status="unknown")
	do i=1,nt
	        data_source(i)=S0(i)
		write(12,*)(i-1)*dt,data_source(i)
	enddo
	close(12)

end subroutine Ricker

subroutine get_model()

USE mod_parfile
USE mod_data_arrays

implicit none

        integer :: i,j,i0,j0,r,equation
	real, allocatable :: mi(:,:)
	character(len=1000) :: file_name

!!!     Vp

	Model_ini=v1
	i0=nzmodel/2.
	j0=nxmodel/2.
	r=asize

!!!	Circle
	if(model.eq.1)	then
		do i=1,nxmodel
        	do j=1,nzmodel
			equation=(i-i0)**2+(j-j0)**2
			if(equation.le.r**2) Model_ini(j,i)=v2
		enddo
		enddo
	endif

!!!	Square
	if(model.eq.2)	then
		do i=1,nxmodel
        	do j=1,nzmodel
			if(i.le.(i0+r).and.j.le.(j0+r))	then
			if(i.ge.(i0-r).and.j.ge.(j0-r))	then
				Model_ini(j,i)=v2;
			endif
			endif
		enddo
		enddo
	endif

!	do i=1,nxmodel
!        	do j=1,nzmodel
!        	        Model_ini(j,i)=vpi+(j-jwater)*(vpf-vpi)/(nymodel-jwater)
!        	enddo
!        enddo

        file_name=trim(adjustl(model_name))

	open(unit=12,file=file_name,status="unknown")
        do i=1,nxmodel
        do j=1,nzmodel
	        write(12,*) (i-1)*dmodel, (j-1)*dmodel, Model_ini(j,i)
        enddo
        enddo

!        do j=1,nzmodel
!	        write(12,*) (Model_ini(j,i),i=1,nxmodel)
!        enddo

	close(12)

end subroutine get_model



