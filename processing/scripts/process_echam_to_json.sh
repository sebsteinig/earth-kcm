set -e
source ${HOME}/miniconda3/bin/activate py3_std # activate miniconda python environment

exp_list="W04"
var_list="rh temp2 tsw precip slp ta wind evap"
lev_list="1000 850 700 500 250 100 10"

KCM_dir="/sfs/fs1/work-geomar4/smomw200/uvt_cret/KCM"
EARTH_dir="/sfs/fs1/work-geomar4/smomw200/PhD/earth_processing/SA_opening"
years="4300-4499"

for exp in ${exp_list}; do
  echo "processing" ${exp}
  mkdir -p ${KCM_dir}/${exp}/clims
  mkdir -p ${EARTH_dir}/data/${exp}/atmosphere
  for var in ${var_list}; do
    var3d=0
    invar=${var}
    case "$var" in
      ("temp2") outvar="temp" ;;
      ("ta") invar="t"; outvar="temp" ;;
      ("wind" | "wind_sur") outvar="wind" ;;
      ("rh") invar="rhumidity"; outvar=${var} ;;
      (*) outvar=${var} ;;
    esac

    if ( [ "${var}" = "temp2" ] || [ "${var}" = "tsw" ] || [ "${var}" = "precip" ] || [ "${var}" = "slp" ] ); then
      if ( [ "${var}" = "precip" ] || [ "${var}" = "evap" ] ); then
        cdo -r -chunit,kg/m^2s,mm/day -mulc,86400 -ymonmean ${KCM_dir}/${exp}/${exp}_mm_${years}.${var}.nc ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.ymonmean.nc
      elif [ "${var}" = "tsw" ]; then
        cdo -r -smooth9 -remapnn,r360x180 -ymonmean ${KCM_dir}/${exp}/${exp}_mm_${years}.${var}.nc ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.ymonmean.nc
      else
        cdo -r -ymonmean ${KCM_dir}/${exp}/${exp}_mm_${years}.${var}.nc ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.ymonmean.nc
      fi
      cdo -r timmean ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.ymonmean.nc ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.yearmean.nc
      if [ "${var}" = "tsw" ]; then
        cdo -r -sellonlatbox,-180,180,-90,90 -setmisstoc,1 -setrtoc,-999,999,0 ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.tsw.yearmean.nc ${KCM_dir}/${exp}/clims/${exp}.slm.1deg.nc
      fi
      python earthjsonfromkcm.py --lat lat --lon lon -var ${invar} -outvar ${outvar} -sur surface -lev level -vec 0 -seas ANN ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.yearmean.nc ${EARTH_dir}/data/${exp}/atmosphere
    elif ( [ "${var}" = "ta" ] || [ "${var}" = "rh" ] ); then
      if [ ! -f ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.yearmean.nc ]; then
        if [ "${var}" = "rh" ]; then
          cdo -r chunit,,"%" -ymonmean ${KCM_dir}/${exp}/${exp}_mm_${years}.${var}.nc ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.ymonmean.nc
        else
          cdo -r ymonmean ${KCM_dir}/${exp}/${exp}_mm_${years}.${var}.nc ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.ymonmean.nc
        fi
        cdo -r timmean ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.ymonmean.nc ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.yearmean.nc
      fi
      for lev in ${lev_list}; do
        echo "processing level: "${lev}
        let lev_Pa=${lev}*100
        cdo -r sellevel,${lev_Pa} ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.yearmean.nc ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.yearmean.tmp.nc
        python earthjsonfromkcm.py --lat lat --lon lon -var ${invar} -outvar ${outvar} -sur isobaric -lev ${lev}hPa  -vec 0 -seas ANN ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.yearmean.tmp.nc ${EARTH_dir}/data/${exp}/atmosphere
        rm ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.yearmean.tmp.nc
      done
      if [ "${var}" = "rh" ]; then
        cp ${EARTH_dir}/data/${exp}/atmosphere/ANN-rh-isobaric-1000hPa-gfs-1.0.json ${EARTH_dir}/data/${exp}/atmosphere/ANN-rh-surface-level-gfs-1.0.json
      fi
    elif [ "${var}" = "wind" ]; then
      if [ ! -f ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.ymonmean.nc ]; then
        cdo -r -merge -ymonmean ${KCM_dir}/${exp}/${exp}_mm_${years}.ua.nc -ymonmean ${KCM_dir}/${exp}/${exp}_mm_${years}.va.nc ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.ymonmean.nc
        cdo -r timmean ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.ymonmean.nc ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.yearmean.nc
      fi
      for lev in ${lev_list}; do
        echo "processing level: "${lev}
        let lev_Pa=${lev}*100
        cdo -r sellevel,${lev_Pa} ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.yearmean.nc ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.yearmean.tmp.nc
        python earthjsonfromkcm.py --lat lat --lon lon -var u -v v -outvar ${outvar} -sur isobaric -lev ${lev}hPa -vec 1 -seas ANN ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.yearmean.tmp.nc ${EARTH_dir}/data/${exp}/atmosphere
        rm ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}.yearmean.tmp.nc
      done
        if [ ! -f ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}_surface.yearmean.nc ]; then
          cdo -r -merge -ymonmean ${KCM_dir}/${exp}/${exp}_mm_${years}.uwnd.nc -ymonmean ${KCM_dir}/${exp}/${exp}_mm_${years}.vwnd.nc ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}_surface.ymonmean.nc   
          cdo -r timmean ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}_surface.ymonmean.nc ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}_surface.yearmean.nc
        fi
        python earthjsonfromkcm.py --lat lat --lon lon -var u10 -v v10 -outvar ${outvar} -sur surface -lev level -vec 1 -seas ANN ${KCM_dir}/${exp}/clims/${exp}_mm_${years}.${var}_surface.yearmean.nc ${EARTH_dir}/data/${exp}/atmosphere
    fi
  done
done
