;-------------------------------------------------------------------------->

function sw_get_data, trange, omni=omni, sta=sta, stb=stb, ace=ace, wind=wind, $
	constants=constants_arr

orbitp=sw_paths(/insitu)
;constants_arr=[alpha_b,alpha_rho,alpha_t,au_km,vernal_equinox,nan,r_sun,omegasun]
alpha_b=constants_arr[0]
alpha_rho=constants_arr[1]
alpha_t=constants_arr[2]
au_km=constants_arr[3]
vernal_equinox=constants_arr[4]
nan=constants_arr[5]
r_sun=constants_arr[6]
omegasun=constants_arr[7]

if keyword_set(omni) then begin
	readcol,orbitp+'omni_'+strmid(time2file(trange[0],/date),0,4)+'.txt',omn_dd,omn_tt,omn_hglat,omn_hglon,omn_br,omn_bt,omn_bn,omn_bmag,omn_vel,omn_elev,omn_azim,omn_rho,omn_temp,form='A,A,F,F,F,F,F,F,F,F,F,F,F',delim=' '
	omn_tim=anytim(strmid(omn_dd,6,4)+'-'+strmid(omn_dd,3,2)+'-'+strmid(omn_dd,0,2)+'T'+omn_tt)
	omn_hglon=sw_theta_shift(omn_hglon)
	sc_vel_arr=omn_vel
	sc_tim_arr=omn_tim
	sc_r_arr=fltarr(n_elements(sc_tim_arr))+au_km
	sc_hgtheta_arr=omn_hglon ;need to convert to HAE or w/e.
	sc_bmag=omn_bmag;omn_br;(omn_br^2.+omn_bt^2.+omn_bn^2.)^.5
;todo: radial field
	sc_rho=omn_rho
	sc_temp=omn_temp
endif

if keyword_set(sta) then begin
	readcol,orbitp+'sta_'+strmid(time2file(trange[0],/date),0,4)+'.txt',sta_dd,sta_tt,sta_r,sta_hglat,sta_hglon,sta_br,sta_bt,sta_bn,sta_b,sta_v,sta_sw_lat,sta_sw_lon,sta_rho,sta_t,form='A,A,F,F,F,F,F,F,F,F,F,F,F,F',delim=' '
	sc_tim_arr=anytim(strmid(sta_dd,6,4)+'-'+strmid(sta_dd,3,2)+'-'+strmid(sta_dd,0,2)+'T'+sta_tt)
	sc_hgtheta_arr=sw_theta_shift(sta_hglon)
	sc_vel_arr=sta_v
	sc_r_arr=sta_r*au_km
	sc_bmag=sta_b;sta_br
	sc_rho=sta_rho
	sc_temp=sta_t
endif

if keyword_set(stb) then begin
	readcol,orbitp+'stb_'+strmid(time2file(trange[0],/date),0,4)+'.txt',stb_dd,stb_tt,stb_r,stb_hglat,stb_hglon,stb_br,stb_bt,stb_bn,stb_b,stb_v,stb_sw_lat,stb_sw_lon,stb_rho,stb_t,form='A,A,F,F,F,F,F,F,F,F,F,F,F,F',delim=' '
	sc_tim_arr=anytim(strmid(stb_dd,6,4)+'-'+strmid(stb_dd,3,2)+'-'+strmid(stb_dd,0,2)+'T'+stb_tt)
	sc_hgtheta_arr=sw_theta_shift(stb_hglon)
	sc_vel_arr=stb_v
	sc_r_arr=stb_r*au_km
	sc_bmag=stb_b;stb_br
	sc_rho=stb_rho
	sc_temp=stb_t
endif

;make an array of S=([r,theta,v,rho,temp,bmag,t],nblob)
sc_arr=fltarr(7,n_elements(sc_vel_arr))
sc_arr[0,*]=sc_r_arr
sc_arr[1,*]=sc_hgtheta_arr
sc_arr[2,*]=sc_vel_arr
sc_arr[3,*]=sc_rho
sc_arr[4,*]=sc_temp
sc_arr[5,*]=sc_bmag
sc_arr[6,*]=sc_tim_arr

;Check for bad data points
if (where(sc_arr[3,*] eq -1.*10^31.))[0] ne -1 then sc_arr[*,where(sc_arr[3,*] eq -1.*10^31.)]=nan
sc_arr=sc_arr[*,where(finite(sc_arr[3,*]) eq 1)]

return,sc_arr

end
