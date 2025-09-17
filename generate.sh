#!/bin/sh
# -*- Mode: sh; indent-tabs-mode: nil; tab-width: 2 -*-

set -e

NUM=$1
if [ -z "$NUM" ]; then
  echo "You must provide a number of patients"
  exit 2
fi

OUTDIR="$NUM-patients" # note: this is a relative dir
WORKDIR=$(mktemp -d)

if ! [ -f synthea-with-dependencies.jar ]; then
  echo "Downloading Synthea..."
  wget -q https://github.com/synthetichealth/synthea/releases/download/master-branch-latest/synthea-with-dependencies.jar
fi

echo "Generating FHIR..."

# To guarantee reproducibility across runs:
# 1. Set seeds (-s seed & -cs clinicianSeed)
# 2. Set dates (-r referenceDate & -e endDate)
# 3. Sort results (Synthea is multi-threaded and records are generated in an arbitrary order)

# Property docs:
# https://github.com/synthetichealth/synthea/blob/master/src/main/resources/synthea.properties
java -jar synthea-with-dependencies.jar \
  --exporter.baseDirectory "$WORKDIR" \
  --exporter.fhir.bulk_data true \
  --exporter.fhir.included_resources \
  AllergyIntolerance,Condition,Device,DiagnosticReport,DocumentReference,Encounter,Immunization,Location,MedicationRequest,Observation,Organization,Patient,Practitioner,PractitionerRole,Procedure \
  -cs 54321 \
  -s 54321 \
  -r 20230403 \
  -e 20230403 \
  -p "$NUM" \
  Kansas >/dev/null 2>/dev/null

# Move output files into place
rm -rf $OUTDIR
mv "$WORKDIR/fhir" $OUTDIR
rm -r "$WORKDIR"

### Manipulation of results ###

# Sort each file
echo "Sorting files..."
for file in $OUTDIR/*; do
  sort $file > $file.sorted
  mv -f $file.sorted $file
done

# Synthea only likes to generate patient history notes, and tags them as such.
# But we are interested in a bit more of a mix than that, so fake some emergency department visits.
HIST_NOTE_TYPE='"system":"http://loinc.org","code":"34117-2","display":"History and physical note"'
EMER_NOTE_TYPE='"system":"http://loinc.org","code":"34111-5","display":"Emergency department note"'
# Ensures that OSX users are using gsed if they have it installed 
SED=sed
which gsed >/dev/null && SED=gsed 
# This sed line will modify every 4th line
$SED -i "0~4s|$HIST_NOTE_TYPE|$EMER_NOTE_TYPE|" $OUTDIR/DocumentReference.ndjson

# Split each file to meet GitHub file limits (100MB per file is hard limit, but they complain at 50MB)
echo "Splitting files into smaller ones..."
# Ensures that OSX users are using gsplit if they have it installed 
SPLIT=split
which gsplit >/dev/null && SPLIT=gsplit
for file in $OUTDIR/*; do
  resource=$(basename $file | cut -d. -f1)
  $SPLIT -d --additional-suffix .ndjson --suffix-length 3 --line-bytes 49m $file $OUTDIR/$resource.
  rm $file
done

# Add a fake bulk export log file,
# both for semi-realism and so that Cumulus ETL can parse it.
# https://github.com/smart-on-fhir/bulk-data-client/wiki/Bulk-Data-Export-Log-Items
$SED "s/%NUM%/$NUM/g" log.ndjson > $OUTDIR/log.ndjson

DIR_SIZE=$(du -sh $OUTDIR | cut -f1)
echo "Done! FHIR is in ./$OUTDIR ($DIR_SIZE)"
