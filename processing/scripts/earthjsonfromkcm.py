from __future__ import print_function, unicode_literals

import os
import json

import numpy as np

from netCDF4 import Dataset
import argparse
from argparse import RawDescriptionHelpFormatter

parser = argparse.ArgumentParser(description = """earthjsonfromwrf.py

Creates a json in the format required by earth[1] from
Weather Research and Forecasting (WRF) outputs. The script
was made for and tested with Python3, but to be compatible
with Python2. See the example for a typical usage

[1]http://github.com/cambecc/earth
""", epilog = """
Example:
    Create input for earth from wrfinput_d01. This script was run
    from the root directory of the earth-master so that the outroot
    is in the standard weather location. The second line starts
    a node server with earth loaded. The third line (on a mac)
    starts the default webbrowser with the data loaded.
    
    $ python earthjsonfromwrf.py ../wrf/wrfinput_d01 public/data/weather/
    Latitude Error: 0.015507
    Latitude Sum Error: 0.00580698
    Longitude Error: 0.0334339
    Longitude Sum Error: 0.0344685
    Add "#2015/06/23/1800Z/wind/surface/level/orthographic" to url to see this time
    $ node dev-server.js 8089 &
    $ open http://localhost:8089/#2015/06/23/1800Z/wind/surface/level/orthographic
""", formatter_class = RawDescriptionHelpFormatter)
parser.add_argument('--lat', dest = 'latitude_name', help = 'Name for latitude variable')
parser.add_argument('--lon', dest = 'longitude_name', help = 'Name for longitude variable')
parser.add_argument('-var', dest = 'var_name', help = 'Name for variable of scalar field')
parser.add_argument('-v', dest = 'vcomponent', help = 'Name for v-component of wind')
parser.add_argument('-outvar', dest = 'outvar_name', help = 'Name for output variable of scalar field')
parser.add_argument('-sur', dest = 'sur_name', help = 'surface/isobaric')
parser.add_argument('-lev', dest = 'lev_name', help = 'level')
parser.add_argument('-vec', dest = 'vec_flag')
parser.add_argument('-seas', dest = 'seas')


parser.add_argument('wrffile', help = 'Path to wrfout or wrfinput file that contains latitude_name, longitude_name, var_name')
parser.add_argument('outroot', help = 'Path for output', default = '../data/echam/')
args = parser.parse_args()

outroot = args.outroot

# Copied a bunch of meta data. Some should (and has not)
# been updated. For example, should the earth radius be updated?
# If it is part of the display, maybe not. If it is part of the
# data meta-data, it should be set to 6,370,000.0
#tswhdr = {"header":{"discipline":0,"disciplineName":"Meteorological products","gribEdition":2,"gribLength":131858,"center":0,"centerName":"WRF OUTPUT","subcenter":0,"refTime":"2014-01-31T00:00:00.000Z","significanceOfRT":1,"significanceOfRTName":"Start of forecast","productStatus":0,"productStatusName":"Operational products","productType":1,"productTypeName":"Forecast products","productDefinitionTemplate":0,"productDefinitionTemplateName":"Analysis/forecast at horizontal level/layer at a point in time","parameterCategory":2,"parameterCategoryName":"Momentum","parameterNumber":2,"parameterNumberName":"U-component_of_wind","parameterUnit":"K","genProcessType":2,"genProcessTypeName":"Forecast","forecastTime":3,"surface1Type":103,"surface1TypeName":"Specified height level above ground","surface1Value":10,"surface2Type":255,"surface2TypeName":"Missing","surface2Value":0,"gridDefinitionTemplate":0,"gridDefinitionTemplateName":"Latitude_Longitude","numberPoints":65160,"shape":6,"shapeName":"Earth spherical with radius of 6,371,229.0 m","gridUnits":"degrees","resolution":48,"winds":"true","scanMode":0,"nx":360,"ny":181,"basicAngle":0,"subDivisions":0,"lo1":0,"la1":90,"lo2":359,"la2":-90,"dx":1,"dy":1}}
newf = Dataset(args.wrffile)
unit  = newf.variables[args.var_name].units

if  float(args.vec_flag) == 1:
  varhdr  = {"header":{"discipline":0,"disciplineName":"Meteorological products","gribEdition":2,"gribLength":131858,"center":0,"centerName":"Kiel Climate Model","subcenter":0,"refTime":"2014-01-31T00:00:00.000Z","significanceOfRT":1,"significanceOfRTName":"Start of forecast","productStatus":0,"productStatusName":"Operational products","productType":1,"productTypeName":"Forecast products","productDefinitionTemplate":0,"productDefinitionTemplateName":"Analysis/forecast at horizontal level/layer at a point in time","parameterCategory":2,"parameterCategoryName":"Momentum","parameterNumber":2,"parameterNumberName":"U-component_of_wind","parameterUnit":unit,"genProcessType":2,"genProcessTypeName":"Forecast","forecastTime":3,"surface1Type":103,"surface1TypeName":"Specified height level above ground","surface1Value":10,"surface2Type":255,"surface2TypeName":"Missing","surface2Value":0,"gridDefinitionTemplate":0,"gridDefinitionTemplateName":"Latitude_Longitude","numberPoints":65160,"shape":6,"shapeName":"Earth spherical with radius of 6,371,229.0 m","gridUnits":"degrees","resolution":48,"winds":"true","scanMode":0,"nx":128,"ny":64,"basicAngle":0,"subDivisions":0,"lo1":0,"la1":87.9,"lo2":357.1,"la2":-87.9,"dx":2.8,"dy":2.8}}
  varhdr2 = {"header":{"discipline":0,"disciplineName":"Meteorological products","gribEdition":2,"gribLength":131858,"center":0,"centerName":"Kiel Climate Model","subcenter":0,"refTime":"2014-01-31T00:00:00.000Z","significanceOfRT":1,"significanceOfRTName":"Start of forecast","productStatus":0,"productStatusName":"Operational products","productType":1,"productTypeName":"Forecast products","productDefinitionTemplate":0,"productDefinitionTemplateName":"Analysis/forecast at horizontal level/layer at a point in time","parameterCategory":2,"parameterCategoryName":"Momentum","parameterNumber":2,"parameterNumberName":"V-component_of_wind","parameterUnit":unit,"genProcessType":2,"genProcessTypeName":"Forecast","forecastTime":3,"surface1Type":103,"surface1TypeName":"Specified height level above ground","surface1Value":10,"surface2Type":255,"surface2TypeName":"Missing","surface2Value":0,"gridDefinitionTemplate":0,"gridDefinitionTemplateName":"Latitude_Longitude","numberPoints":65160,"shape":6,"shapeName":"Earth spherical with radius of 6,371,229.0 m","gridUnits":"degrees","resolution":48,"winds":"true","scanMode":0,"nx":128,"ny":64,"basicAngle":0,"subDivisions":0,"lo1":0,"la1":87.9,"lo2":357.1,"la2":-87.9,"dx":2.8,"dy":2.8}}
  data = [varhdr,varhdr2]
else:
  varhdr = {"header":{"discipline":0,"disciplineName":"Meteorological products","gribEdition":2,"gribLength":131858,"center":0,"centerName":"Kiel Climate Model","subcenter":0,"refTime":"2014-01-31T00:00:00.000Z","significanceOfRT":1,"significanceOfRTName":"Start of forecast","productStatus":0,"productStatusName":"Operational products","productType":1,"productTypeName":"Forecast products","productDefinitionTemplate":0,"productDefinitionTemplateName":"Analysis/forecast at horizontal level/layer at a point in time","parameterCategory":2,"parameterCategoryName":"Momentum","parameterNumber":2,"parameterNumberName":"U-component_of_wind","parameterUnit":unit,"genProcessType":2,"genProcessTypeName":"Forecast","forecastTime":3,"surface1Type":103,"surface1TypeName":"Specified height level above ground","surface1Value":10,"surface2Type":255,"surface2TypeName":"Missing","surface2Value":0,"gridDefinitionTemplate":0,"gridDefinitionTemplateName":"Latitude_Longitude","numberPoints":65160,"shape":6,"shapeName":"Earth spherical with radius of 6,371,229.0 m","gridUnits":"degrees","resolution":48,"winds":"true","scanMode":0,"nx":128,"ny":64,"basicAngle":0,"subDivisions":0,"lo1":0,"la1":87.9,"lo2":357.1,"la2":-87.9,"dx":2.8,"dy":2.8}}
#  varhdr = {"header":{"discipline":0,"disciplineName":"Meteorological products","gribEdition":2,"gribLength":131858,"center":0,"centerName":"Kiel Climate Model","subcenter":0,"refTime":"2014-01-31T00:00:00.000Z","significanceOfRT":1,"significanceOfRTName":"Start of forecast","productStatus":0,"productStatusName":"Operational products","productType":1,"productTypeName":"Forecast products","productDefinitionTemplate":0,"productDefinitionTemplateName":"Analysis/forecast at horizontal level/layer at a point in time","parameterCategory":2,"parameterCategoryName":"Momentum","parameterNumber":2,"parameterNumberName":"U-component_of_wind","parameterUnit":unit,"genProcessType":2,"genProcessTypeName":"Forecast","forecastTime":3,"surface1Type":103,"surface1TypeName":"Specified height level above ground","surface1Value":10,"surface2Type":255,"surface2TypeName":"Missing","surface2Value":0,"gridDefinitionTemplate":0,"gridDefinitionTemplateName":"Latitude_Longitude","numberPoints":65160,"shape":6,"shapeName":"Earth spherical with radius of 6,371,229.0 m","gridUnits":"degrees","resolution":48,"winds":"true","scanMode":0,"nx":129,"ny":65,"basicAngle":0,"subDivisions":0,"lo1":0,"la1":90.,"lo2":360.,"la2":-90.,"dx":2.8,"dy":2.8}}
#  varhdr = {"header":{"discipline":0,"disciplineName":"Meteorological products","gribEdition":2,"gribLength":131858,"center":0,"centerName":"Kiel Climate Model","subcenter":0,"refTime":"2014-01-31T00:00:00.000Z","significanceOfRT":1,"significanceOfRTName":"Start of forecast","productStatus":0,"productStatusName":"Operational products","productType":1,"productTypeName":"Forecast products","productDefinitionTemplate":0,"productDefinitionTemplateName":"Analysis/forecast at horizontal level/layer at a point in time","parameterCategory":2,"parameterCategoryName":"Momentum","parameterNumber":2,"parameterNumberName":"U-component_of_wind","parameterUnit":unit,"genProcessType":2,"genProcessTypeName":"Forecast","forecastTime":3,"surface1Type":103,"surface1TypeName":"Specified height level above ground","surface1Value":10,"surface2Type":255,"surface2TypeName":"Missing","surface2Value":0,"gridDefinitionTemplate":0,"gridDefinitionTemplateName":"Latitude_Longitude","numberPoints":65160,"shape":6,"shapeName":"Earth spherical with radius of 6,371,229.0 m","gridUnits":"degrees","resolution":48,"winds":"true","scanMode":0,"nx":360,"ny":180,"basicAngle":0,"subDivisions":0,"lo1":0,"la1":89.5,"lo2":359.5,"la2":-89.5,"dx":1.0,"dy":1.0}}
  data = [varhdr]

#lat = newf.variables[args.latitude_name][0]
#lon = newf.variables[args.longitude_name][0]
lat = newf.variables[args.latitude_name]
lat = lat[::-1] #reverse echam latitude array
lon = newf.variables[args.longitude_name]
#dys = np.diff(lat, axis = 0).mean(1)
dys = np.diff(lat, axis = 0).mean(0)
dy = float(dys.mean())

#print('Latitude Error:', np.abs((dy / dys) - 1).max())
#print('Latitude Sum Error:', (dy / dys - 1).sum())
#dxs = np.diff(lon, axis = 1).mean(0)
dxs = np.diff(lon, axis = 0).mean(0)
dx = float(dxs.mean())
#print('Longitude Error:', np.abs(dx / dxs - 1).max())
#print('Longitude Sum Error:', (dx / dxs - 1).sum())
#nx = float(lon.shape[1])
nx = float(lon.shape[0])
ny = float(lat.shape[0])
#la1 = float(lat[-1, -1])
#la2 = float(lat[0, 0])
#lo1 = float(lon[0, 0])
#lo2 = float(lon[-1, -1])
la1 = float(lat[-1])
la2 = float(lat[0])
lo1 = float(lon[0])
lo2 = float(lon[-1])
times = newf.variables['time']

for ti, time in enumerate(times):
    #2012/02/07/0100Z/wind/surface/level/orthographic=-74.01,4.38,29184
    datestr = '1'
    timestr = '1'
    #print('Add "#' + datestr + '/' + timestr + 'Z/wind/surface/level/orthographic" to url to see this time')
#    dirpath = os.path.join(args.outroot, *datestr.split('/'))
    os.makedirs(args.outroot, exist_ok = True)
#    outpath = os.path.join(dirpath, '%s-temp-surface-level-gfs-1.0.json' % (timestr,))
    outpath = os.path.join(args.outroot, '%s-%s-%s-%s-gfs-1.0.json' % (args.seas,args.outvar_name,args.sur_name,args.lev_name))
    # Update header data for some properties
    # that are now to affect.
    h = data[0]['header']
    h['la1'] = la1
    h['la2'] = la2
    h['lo1'] = lo1
    h['lo2'] = lo2
    h['nx'] = nx
    h['ny'] = ny
    h['dx'] = dx
    h['dy'] = dy
    h['forecastTime'] = 0
    h['refTime'] = '1'     
    h['gribLength'] = 1538 + nx * ny * 2
    data[0]['data'] = newf.variables[args.var_name][ti].ravel().tolist()
    if float(args.vec_flag) == 1:
        data[1]['data'] = newf.variables[args.vcomponent][ti].ravel().tolist()
        h = data[1]['header']
        h['la1'] = la1
        h['la2'] = la2
        h['lo1'] = lo1
        h['lo2'] = lo2
        h['nx'] = nx
        h['ny'] = ny
        h['dx'] = dx
        h['dy'] = dy
        h['forecastTime'] = 0
        h['refTime'] = '1'     
        h['gribLength'] = 1538 + nx * ny * 2
    if ti == 0:
        outf = open(outpath, 'w')
        json.dump(data, outf)
        outf.close()
        
    outf = open(outpath, 'w')
    json.dump(data, outf)
    outf.close()
