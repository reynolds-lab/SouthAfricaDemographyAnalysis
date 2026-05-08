############################################################
# SPRUCE-RF / MAPS
# Environmental raster extraction pipeline (35° extent)
############################################################

module load gdal/2.4.4

############################################################
# STEP 1: Define directories
############################################################

GLOBAL=/share/hennlab/users/espless/EnvironmentalData/Global
ENV=/share/hennlab/projects/SPRUCE_sa/EnvironmentalData/thirtyfive_clips
WD=/share/hennlab/projects/SPRUCE_sa/EnvironmentalData/ExtractedValues_35

mkdir -p $ENV
mkdir -p $WD

############################################################
# STEP 2: Prepare global raster inputs
############################################################

cp $GLOBAL/*.tif.gz /share/hennlab/projects/SPRUCE_sa/EnvironmentalData/
gunzip -f /share/hennlab/projects/SPRUCE_sa/EnvironmentalData/*.tif.gz

############################################################
# STEP 3: Define bounding box (35° extent)
############################################################

WEST=16.0
NORTH=-24.0
EAST=35.0
SOUTH=-35.0

############################################################
# STEP 4: Clip rasters
############################################################

clip () {
  nice gdal_translate -projwin $WEST $NORTH $EAST $SOUTH \
    $1 $ENV/$2 \
    -co COMPRESS=DEFLATE -co ZLEVEL=9
}

# Geography
clip altitude_1KMmedian_MERIT.tif altitude.tif
clip slope_1KMmedian_MERIT.tif slope.tif

# Climate
clip AI_annual.tif aridity.tif
clip bio1_mean.tif bio1_mean.tif
clip bio5_mean.tif bio5_mean.tif
clip bio6_mean.tif bio6_mean.tif
clip bio12_mean.tif bio12_mean.tif
clip bio13_mean.tif bio13_mean.tif
clip bio14_mean.tif bio14_mean.tif

# Productivity
clip GPP_mean.tif GPP_mean.tif

# Hydrology
clip za_lakes.tif za_lakes.tif
clip za_rivers.tif za_rivers.tif

############################################################
# STEP 5: Extract MAPS coordinates
############################################################

MAPS=/share/hennlab/projects/SPRUCE_sa/MAPS/runs/with_namibia_300-2_6-output

cp $MAPS/demes.txt $WD/demes.txt

awk '{print $2,$1}' $WD/demes.txt > $WD/demes_xy.txt

############################################################
# STEP 6: Extract raster values at deme locations
############################################################

for VAR in altitude slope aridity bio1_mean bio5_mean bio6_mean bio12_mean bio13_mean bio14_mean GPP_mean za_lakes za_rivers
do
  cat $WD/demes_xy.txt | gdallocationinfo -valonly -wgs84 $ENV/${VAR}.tif \
  > $WD/${VAR}.txt
done

############################################################
# STEP 7: Clean missing values
############################################################

for FILE in $WD/*.txt
do
  sed 's/-999.*/NA/g' $FILE | sed 's/^[[:blank:]]*$/NA/' \
  > ${FILE%.txt}_clean.txt
done

############################################################
# STEP 8: OPTIONAL: transfer to local machine
############################################################

# (run locally, not in pipeline unless needed)

# scp user@server:$WD/*clean.txt ~/local_folder/
