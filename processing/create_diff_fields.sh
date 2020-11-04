source ${HOME}/miniconda3/bin/activate py3_std # activate miniconda python environment

exp_list="C63mC53"
exp1="C63"
exp2="C53"
#var_list_echam="rh temp2 tsw precip slp ta ua va evap uwnd vwnd"
var_list_echam="uwnd vwnd"
#var_list_opa="vozocrtx vomecrty vosaline votemper somxl010 sowaflep"
var_list_opa="somxl010"

CDO=/sfs/fs6/home-geomar/smomw014/bin/cdo
KCM_dir="/sfs/fs1/work-geomar4/smomw200/uvt_cret/KCM"

for exp in ${exp_list}; do
  echo "processing" ${exp}
  mkdir -p ${KCM_dir}/${exp}/masked
  for var in ${var_list_echam}; do
    cdo -r -sub ${KCM_dir}/${exp1}/${exp1}_mm_1500-1999.${var}.nc ${KCM_dir}/${exp2}/${exp2}_mm_1500-1999.${var}.nc ${KCM_dir}/${exp}/${exp}_mm_1500-1999.${var}.nc
  done
  cp ${KCM_dir}/${exp2}/${exp2}.slm.nc ${KCM_dir}/${exp}/${exp}.slm.nc
  for var in ${var_list_opa}; do
    ${CDO} -r -sub ${KCM_dir}/${exp1}/masked/${exp1}_ym_1500-1999.${var}.masked.mean.nc ${KCM_dir}/${exp2}/masked/${exp2}_ym_1500-1999.${var}.masked.mean.nc ${KCM_dir}/${exp}/masked/${exp}_ym_1500-1999.${var}.masked.mean.nc
  done

done
