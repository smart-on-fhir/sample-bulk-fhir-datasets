# Sample FHIR Bulk Export Datasets

This repo hosts [Synthea](https://github.com/synthetichealth/synthea)-generated
sample [FHIR](https://www.hl7.org/fhir/) bulk export results,
useful for testing downstream workflows. It also hosts a script for generating samples of
custom sizes. See the [regenerating a dataset section below](#regenerating-a-dataset) for
instructions on generating custom sized datasets.

## Downloads

We've created several pre-zipped bundles of sample patients if you only

- [Small](https://github.com/smart-on-fhir/sample-bulk-fhir-datasets/archive/refs/heads/10-patients.zip)
  (10 patients, 1.9MB zipped, 19MB unzipped)
- [Medium](https://github.com/smart-on-fhir/sample-bulk-fhir-datasets/archive/refs/heads/100-patients.zip)
  (100 patients, 17MB zipped, 129MB unzipped)
- [Large](https://github.com/smart-on-fhir/sample-bulk-fhir-datasets/archive/refs/heads/1000-patients.zip)
  (1,000 patients, 183MB zipped, 1.3B unzipped)

### Which FHIR Resources Are Included?

- Condition
- DocumentReference
- Encounter
- Medication
- MedicationRequest
- Observation
- Patient
- Procedure

### What Do the Contents of a Dataset Look Like?

The 100-patient dataset looks like this, for example:

```text
sample-bulk-fhir-datasets-100-patients/
  Condition.000.ndjson
  DocumentReference.000.ndjson
  Encounter.000.ndjson
  Medication.000.ndjson
  MedicationRequest.000.ndjson
  Observation.000.ndjson
  Observation.001.ndjson
  Patient.000.ndjson
  Procedure.000.ndjson
```

Each file holds a list of FHIR json records (one per line) like:

```json
{"resourceType":"Condition","id":"000023ef-c498-02cc-c9b7-20aab279b262",...}
```

Each file is also less than 50MB for convenience when working with them.
As you can see above, two files were needed to hold all the Observations.

## License

The script that generates these datasets is Apache 2,
but the datasets themselves can be treated as
[CC0](https://creativecommons.org/publicdomain/zero/1.0/) licensed
(i.e. as close to public domain as possible).

## Goals of This Dataset Collection

- No end-user generation of data should be necessary. All examples are pre-generated.
- Offer several different sized datasets as one-click downloads.
  - The exact definitions of those sizes are flexible.
  - Limits imposed by GitHub may affect our options.
- Each dataset should look like the plausible result of a FHIR bulk export.
- A reasonable effort will be made to keep data consistent over time.
  - That is, patient 1234 will not suddenly change addresses in a month.
  - This is not a guarantee, but a best-effort feature.

### Non-Goals

- This dataset does not need to serve everyone's needs.
  - It's primary purpose is to be useful to other SMART on FHIR projects,
    like [Cumulus](https://docs.smarthealthit.org/cumulus/).
  - If you need something different (like, a new resource), it's easy to generate your own with Synthea.

## Prior Art

There are several other similar sample FHIR datasets or generators,
with slightly different purposes:

- [custom-sample-data](https://github.com/smart-on-fhir/custom-sample-data) (2017): focused on
  providing a few small validated JSON transaction bundles

- [sample-patients](https://github.com/smart-on-fhir/sample-patients) (2018): focused on
  generating individual JSON files based off a custom text file format

- [generated-sample-data](https://github.com/smart-on-fhir/generated-sample-data) (2021): focused
  on generating a JSON transaction bundle for insertion into a FHIR server

- [ctakes-examples](https://github.com/Machine-Learning-for-Medical-Language/ctakes-examples)
  (2022): focused on realistic plaintext physician notes

- [synthea](https://github.com/synthetichealth/synthea/) (ongoing): and of course Synthea, the
  general purpose FHIR generator, used to generate this dataset

## Regenerating a Dataset

The following must be installed for the generation script to succeed:

- Java
- GNU `sed`
  - Note: For mac users, this script requires the installation of `gnu-sed` and
    proper aliasing `gsed` to `sed`. We hav had success completing this installation
    and setup using this [homebrew package](https://formulae.brew.sh/formula/gnu-sed#default)
- GNU `split`
  - Note: For mac users, we have had success with the 
    [coreutils brew package](https://formulae.brew.sh/formula/coreutils), which includes `split`

Then you should be able to clone and run the script:

```commandline
git clone --single-branch git@github.com:smart-on-fhir/sample-bulk-fhir-datasets.git
cd sample-bulk-fhir-datasets
./generate.sh 10 # generates a ten patient dataset
```
