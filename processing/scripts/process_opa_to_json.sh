set -e
source ${HOME}/miniconda3/bin/activate py3_std # activate miniconda python environment

#happy W04 4300 4499 /sfs/fs1/work-geomar4/smomw014/prism/EXP2 ym


#exp_list="DS1 DS2 DS3 DS4 DS5 DS6 DC1 DC2 DC3 DC4 DC5 DC6"
#exp_list="WI1 WI2 WI3 WS1 WS2 WS3 WC1 WC2 WC3"
exp_list="W04"
var_list="ocevel votemper vosaline somxl010 sowaflep"
#var_list="votemper"
lev_list="1 20 22 24 26"
KCM_dir="/sfs/fs1/work-geomar4/smomw200/uvt_cret/KCM"
EARTH_dir="/sfs/fs1/work-geomar4/smomw200/PhD/earth_processing/SA_opening"
CDO=/sfs/fs6/home-geomar/smomw014/bin/cdo
#CDO=/sfs/fs6/home-geomar/smomw043/cdo/cdo-1.4.7/bin/cdo
years="4300-4499"


for exp in ${exp_list}; do
  echo "processing" ${exp}
  mkdir -p ${KCM_dir}/${exp}/clims
  mkdir -p ${EARTH_dir}/data/${exp}/ocean
  for var in ${var_list}; do
    var3d=0
    case "$var" in
      ("temp2" | "ta") outvar="temp" ;;
      ("wind" | "wind_sur") outvar="wind" ;;
      (*) outvar=${var} ;;
    esac

    if ( [ "${var}" = "votemper" ] || [ "${var}" = "vosaline" ] || [ "${var}" = "vovecrtz" ] ); then
#      if [ ! -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.filled.nc ]; then
        ${CDO} -r -ifnotthen -sellonlatbox,0,360,-90,90 ${KCM_dir}/${exp}/clims/${exp}.slm.1deg.nc -fillmiss -smooth9 -remapnn,r360x180 ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.masked.mean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.filled.nc
#      fi
 #     if [ ! -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.nc ]; then
        ${CDO} -r -ifnotthen -sellonlatbox,0,360,-90,90 ${KCM_dir}/${exp}/clims/${exp}.slm.1deg.nc -smooth9 -remapnn,r360x180 ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.masked.mean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.nc
 #     fi
      for lev in ${lev_list}; do
        if [ "${lev}" = "1" ]; then
          ${CDO} -r -sellevidx,${lev} ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.filled.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.${lev}.nc
          python earthjsonfromkcm.py --lat lat --lon lon -var ${var} -outvar ${outvar} -sur depthz -lev 0m -vec 0 -seas ANN ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.${lev}.nc ${EARTH_dir}/data/${exp}/ocean
        else
          case ${lev} in
            20)
              meter=500
              ;;
            22)
              meter=1000
              ;;
            24)
              meter=2000
              ;;
            26)
              meter=3000
              ;;
          esac
          ${CDO} -r -setctomiss,0 -sellevidx,${lev} ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.${lev}.nc
          python earthjsonfromkcm.py --lat lat --lon lon -var ${var} -outvar ${outvar} -sur depthz -lev ${meter}m -vec 0 -seas ANN ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.${lev}.nc ${EARTH_dir}/data/${exp}/ocean
        fi
       # rm ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.${lev}.nc
      done

    elif ( [ "${var}" = "ocevel" ] ); then
  #    if [ ! -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vozocrtx.r360x180.yearmean.filled.nc ]; then
        ${CDO} -r -ifnotthen -sellonlatbox,0,360,-90,90 ${KCM_dir}/${exp}/clims/${exp}.slm.1deg.nc -fillmiss -smooth9 -remapnn,r360x180 ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vozocrtx.masked.mean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vozocrtx.r360x180.yearmean.filled.nc
   #   fi
  #    if [ ! -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vomecrty.r360x180.yearmean.filled.nc ]; then
        ${CDO} -r -ifnotthen -sellonlatbox,0,360,-90,90 ${KCM_dir}/${exp}/clims/${exp}.slm.1deg.nc -fillmiss -smooth9 -remapnn,r360x180 ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vomecrty.masked.mean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vomecrty.r360x180.yearmean.filled.nc
  #    fi
  #    if [ ! -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vozocrtx.r360x180.yearmean.nc ]; then
        ${CDO} -r -ifnotthen -sellonlatbox,0,360,-90,90 ${KCM_dir}/${exp}/clims/${exp}.slm.1deg.nc -smooth9 -remapnn,r360x180 ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vozocrtx.masked.mean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vozocrtx.r360x180.yearmean.nc
  #    fi
  #    if [ ! -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vomecrty.r360x180.yearmean.nc ]; then
        ${CDO} -r -ifnotthen -sellonlatbox,0,360,-90,90 ${KCM_dir}/${exp}/clims/${exp}.slm.1deg.nc -smooth9 -remapnn,r360x180 ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vomecrty.masked.mean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vomecrty.r360x180.yearmean.nc
  #    fi
      for lev in ${lev_list}; do
        if [ "${lev}" = "1" ]; then
          ${CDO} -r -sellevidx,${lev} ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vozocrtx.r360x180.yearmean.filled.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vozocrtx.r360x180.yearmean.${lev}.nc
          ${CDO} -r -sellevidx,${lev} ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vomecrty.r360x180.yearmean.filled.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vomecrty.r360x180.yearmean.${lev}.nc
          ${CDO} -r -merge ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vozocrtx.r360x180.yearmean.${lev}.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vomecrty.r360x180.yearmean.${lev}.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.ocevel.r360x180.yearmean.${lev}.nc
          python earthjsonfromkcm.py --lat lat --lon lon -var vozocrtx -v vomecrty -outvar ${outvar} -sur depthz -lev 0m -vec 1 -seas ANN ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.ocevel.r360x180.yearmean.${lev}.nc ${EARTH_dir}/data/${exp}/ocean
        else
          case ${lev} in
            20)
              meter=500
              ;;
            22)
              meter=1000
              ;;
            24)
              meter=2000
              ;;
            26)
              meter=3000
              ;;
          esac
          ${CDO} -r -sellevidx,${lev} ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vozocrtx.r360x180.yearmean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vozocrtx.r360x180.yearmean.${lev}.nc
          ${CDO} -r -sellevidx,${lev} ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vomecrty.r360x180.yearmean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vomecrty.r360x180.yearmean.${lev}.nc
          ${CDO} -r -merge  -setctomiss,0 ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vozocrtx.r360x180.yearmean.${lev}.nc  -setctomiss,0 ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vomecrty.r360x180.yearmean.${lev}.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.ocevel.r360x180.yearmean.${lev}.nc
          python earthjsonfromkcm.py --lat lat --lon lon -var vozocrtx -v vomecrty -outvar ${outvar} -sur depthz -lev ${meter}m -vec 1 -seas ANN ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.ocevel.r360x180.yearmean.${lev}.nc ${EARTH_dir}/data/${exp}/ocean
        fi
        rm -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vozocrtx.r360x180.yearmean.${lev}.nc
        rm -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vomecrty.r360x180.yearmean.${lev}.nc
        rm -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.ocevel.r360x180.yearmean.${lev}.nc
      done

    elif ( [ "${var}" = "somxl010" ] ); then
 #     if [ ! -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.filled.nc ]; then
        ${CDO} -r -ifnotthen -sellonlatbox,0,360,-90,90 ${KCM_dir}/${exp}/clims/${exp}.slm.1deg.nc -fillmiss -smooth9 -remapnn,r360x180  ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.masked.mean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.filled.nc
 #     fi
      python earthjsonfromkcm.py --lat lat --lon lon -var ${var} -outvar ${outvar} -sur depthz -lev 0m -vec 0 -seas ANN ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.filled.nc ${EARTH_dir}/data/${exp}/ocean
    elif ( [ "${var}" = "sowaflep" ] ); then
#      if [ ! -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.filled.nc ]; then
        ${CDO} -r -chunit,kg/m^2s,mm/day -mulc,86400 -ifnotthen -sellonlatbox,0,360,-90,90 ${KCM_dir}/${exp}/clims/${exp}.slm.1deg.nc -fillmiss -smooth9 -remapnn,r360x180 ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.masked.mean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.filled.nc
#      fi
      python earthjsonfromkcm.py --lat lat --lon lon -var ${var} -outvar ${outvar} -sur depthz -lev 0m -vec 0 -seas ANN ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.filled.nc ${EARTH_dir}/data/${exp}/ocean

    elif ( [ "${var}" = "vodens" ] ); then
#      if [ ! -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.votemper.r360x180.yearmean.filled.nc ]; then
        ${CDO} -r -ifnotthen -sellonlatbox,0,360,-90,90 ${KCM_dir}/${exp}/clims/${exp}.slm.1deg.nc -fillmiss -smooth9 -remapnn,r360x180 ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.votemper.masked.mean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.votemper.r360x180.yearmean.filled.nc
 #     fi
#      if [ ! -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.votemper.r360x180.yearmean.nc ]; then
        ${CDO} -r -ifnotthen -sellonlatbox,0,360,-90,90 ${KCM_dir}/${exp}/clims/${exp}.slm.1deg.nc -smooth9 -remapnn,r360x180 ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.votemper.masked.mean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.votemper.r360x180.yearmean.nc
 #     fi
 #     if [ ! -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vosaline.r360x180.yearmean.filled.nc ]; then
        ${CDO} -r -ifnotthen -sellonlatbox,0,360,-90,90 ${KCM_dir}/${exp}/clims/${exp}.slm.1deg.nc -fillmiss -smooth9 -remapnn,r360x180 ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vosaline.masked.mean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vosaline.r360x180.yearmean.filled.nc
 #     fi
 #     if [ ! -f ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.votemper.r360x180.yearmean.nc ]; then
        ${CDO} -r -ifnotthen -sellonlatbox,0,360,-90,90 ${KCM_dir}/${exp}/clims/${exp}.slm.1deg.nc -smooth9 -remapnn,r360x180 ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vosaline.masked.mean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vosaline.r360x180.yearmean.nc
 #     fi

      for lev in ${lev_list}; do
        if [ "${lev}" = "1" ]; then
          ${CDO} -r -merge -chname,votemper,to ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.votemper.r360x180.yearmean.filled.nc -chname,vosaline,sao ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vosaline.r360x180.yearmean.filled.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.TS.r360x180.yearmean.filled.nc
          ${CDO} -r -chname,rhopoto,vodens -rhopot ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.TS.r360x180.yearmean.filled.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.filled.nc
          ${CDO} -r -sellevidx,${lev} ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.filled.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.${lev}.nc
          python earthjsonfromkcm.py --lat lat --lon lon -var ${var} -outvar ${outvar} -sur depthz -lev 0m -vec 0 -seas ANN ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.${lev}.nc ${EARTH_dir}/data/${exp}/ocean
        else
          case ${lev} in
            20)
              meter=500
              ;;
            22)
              meter=1000
              ;;
            24)
              meter=2000
              ;;
            26)
              meter=3000
              ;;
          esac
          ${CDO} -r -merge -chname,votemper,to ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.votemper.r360x180.yearmean.nc -chname,vosaline,sao ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.vosaline.r360x180.yearmean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.TS.r360x180.yearmean.nc
          ${CDO} -r -chname,rhopoto,vodens -rhopot ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.TS.r360x180.yearmean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.nc
          ${CDO} -r -setctomiss,0 -sellevidx,${lev} ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.${lev}.nc
          python earthjsonfromkcm.py --lat lat --lon lon -var ${var} -outvar ${outvar} -sur depthz -lev 0m -vec 0 -seas ANN ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.${lev}.nc ${EARTH_dir}/data/${exp}/ocean
        fi
        rm ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.TS.r360x180.yearmean.filled.nc
        rm ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.filled.nc
        rm ${KCM_dir}/${exp}/masked/${exp}_ym_${years}.${var}.r360x180.yearmean.${lev}.nc
      done
    fi
  done
done

