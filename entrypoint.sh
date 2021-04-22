#!/usr/bin/env bash

# Script which serves as the entry point to the github action
# Must receive at least one argument:
#   -$1       output path, where to place the files created
#   -$2..$n   files to compile the mermaid markup from
#
# Usage:
#   > entrypoint.sh <output path> [<file1> [<file2> ...]]

# For *.mermaid or *.mmd files, it is compiled and a *.mermaid.${output_file_type} is created at the location

# For *.md files:
#   1) finds all of the mermaid markup in the file
#   2) creates intermediate files in the output directory *.md.<n>.mermaid where n represents the nth block found
#   3) compile the mermaid to the directory *.md.<n>.mermaid.${output_file_type}
#   4) place a reference to the compiled image in the markdown

set -euo pipefail

# Normalize some environment variables (default values)
MMDC_EXTRA_ARGS="${MMDC_EXTRA_ARGS:-}"

function main {
  printf "Using MMDC version %s\n" "$(/node_modules/.bin/mmdc -V)"

  outpath="${1}"
  mkdir -p "${outpath}"
  printf "Got output path: %s\n" "${outpath}"
  output_file_type="${OUTPUT_FILE_TYPE:-png}"
  printf "Filetype: %s\n" "${output_file_type}"

  shift $(( OPTIND - 1 ))

  for in_file in $@; do
    if [[ -f "${in_file}" ]]; then
      printf "Attempting compile of: %s\n" "${in_file}"

      in_file_dirname=$(dirname "${in_file}")
      in_file_basename=$(basename "${in_file}")
      in_file_type="${in_file_basename##*.}"

      if [[ "${in_file_type}" == "mermaid" || "${in_file_type}" == "mmd" ]]; then

        output_path="${in_file_dirname}"
        output_file="$(dasherize_name ${in_file_basename}).${output_file_type}"
        c_mermaid "${in_file}" "${output_path}/${output_file}"

      elif is_path_markdown "${in_file_basename}" "${MD_SUFFIXES-.md}"; then

        output_path="${outpath}"
        c_md_mermaid "${in_file}" "${output_path}"

      else

        die "*.${in_file_type} is not a recognized type.  Check that your Github action is submitting a valid file to this entrypoint."

      fi
    fi
  done
}


function is_path_markdown {

  path="${1}"
  suffixes="${2}"

  for suffix in ${suffixes}; do
    if [[ "${path}" == *${suffix} ]]; then
      return 0
    fi
  done

  return 1
}

# $1 - the file to compile
# $2 - the output location
function c_mermaid {
  printf "Compiling: %s\n" "${1}"
  printf "Output to: %s\n" "${2}"
  printf "Extra args: %s\n" "${MMDC_EXTRA_ARGS}"
  /node_modules/.bin/mmdc -p /mmdc/puppeteer-config.json -i "${1}" -o "${2}" ${MMDC_EXTRA_ARGS}
  confirm_creation "${2}"
}

# $1 - the file to compile
# $2 - output path
function c_md_mermaid {
  printf "Parsing mermaid codeblocks from %s\n" "${1}"

  output_path="${2}"

  input_dir=$(dirname "${1}")
  dasherized=$(dasherize_name "${1}")

  # Make a temporary directory
  tmp_dir="${output_path}/tmp"
  mkdir -p "${tmp_dir}"

  all_file="${tmp_dir}/mermaid-blocks"
  block_file="${tmp_dir}/mermaid-block"

  # Get all mermaid blocks
  sed -n '/^```mermaid/,/^```/ p' < "${1}" > "${all_file}"

  # loop until all mermaid blocks are compiled
  block_count=0
  while [[ -s "${all_file}" ]]; do
    ((block_count=block_count+1))

    # Grab the first block
    sed '/^```$/q' < "${all_file}" > "${block_file}-${block_count}"

    line_count=$(wc -l < "${block_file}-${block_count}")

    # Drop the first and last line of the block file
    sed -i '1d;$d' "${block_file}-${block_count}"

    mv "${all_file}" "${all_file}x"
    sed "1,${line_count}d" < "${all_file}x" > "${all_file}"
    rm "${all_file}x"

    # Compile mermaid block"
    c_mermaid "${block_file}-${block_count}" "${output_path}/${dasherized}-${block_count}.${output_file_type}"

    # Compute relative path from the markdown to the tmp_dir
    image_relative_path=$(realpath --relative-to="${input_dir}" "${output_path}/${dasherized}-${block_count}.${output_file_type}")
    image_absolute_path="/${output_path}/${dasherized}-${block_count}.${output_file_type}"

    if [[ -z "${ABSOLUTE_IMAGE_LINKS}" ]]; then
      image_path="${image_relative_path}"
    else
      image_path="${image_absolute_path}"
    fi

    # Insert the link to the markdown
    awk -v n="${block_count}" \
        -v path="${image_path}" \
        -v hide_codeblocks="${HIDE_CODEBLOCKS}" \
        -f "${insert_markdown_awk}" \
        "${1}" > "${1}-temp"
    rm "${1}"
    mv "${1}-temp" "${1}"
  done

  # remove tmp dir
  rm -rf "${tmp_dir}"
}

# $1 name to be dasherized
function dasherize_name {
  local result=$(echo "${1}" | sed -e 's/\./-/g' | sed -e 's;/;_;g')
  echo "${result}"
}

function confirm_creation {
  if [[ ! -f "${1}" ]]; then
    die "Unable to create ${1}, exiting."
  fi
}

function installed {
  cmd=$(command -v "${1}")

  [[ -n "${cmd}" ]] && [[ -f "${cmd}" ]]
  return ${?}
}

function die {
  >&2 echo "Fatal: ${@}"
  exit 1
}

function validate_md_suffixes {

  for suffix in ${MD_SUFFIXES-}; do
    if [[ "${suffix}" =~ ^\. ]]; then
      continue
    fi

    die "Starting with . character is currently enforced for MD_SUFFIXES. Suffix ${suffix} is missing dot. Valid value is: .${suffix}."
  done
}

# Check for all required dependencies
deps=(node awk realpath basename dirname)
for dep in "${deps[@]}"; do
  installed "${dep}" || die "Missing '${dep}'"
done

# Check for required ENV
if [[ -z "${ENTRYPOINT_PATH}" ]]; then
  die "'ENTRYPOINT_PATH' is not set, set to location of entrypoint.sh"
fi

validate_md_suffixes

# Check for required files
insert_markdown_awk="${ENTRYPOINT_PATH}/insert-markdown.awk"
if [[ ! -f "${insert_markdown_awk}" ]]; then
  die "'${insert_markdown_awk}' not found in 'ENTRYPOINT_PATH'"
fi

main "$@"; exit
