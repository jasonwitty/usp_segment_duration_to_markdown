#!/bin/bash

# Usage: ./script.sh baseurl representation end_number output_folder

# Check if the correct number of arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 baseurl representation end_number output_folder"
    exit 1
fi

# Input parameters
baseurl="$1"
representation="$2"
end_number="$3"
output_folder="$4"

# Create output folder
mkdir -p "$output_folder"

# Download initialization segment
echo "Downloading initialization segment..."
init_url="$baseurl/index.ism/dash/index-$representation.dash"
curl -s "$init_url" -o "$output_folder/seg-init.m4s"

# Check if the initialization segment was downloaded successfully
if [ ! -f "$output_folder/seg-init.m4s" ]; then
    echo "Failed to download initialization segment from $init_url"
    exit 1
fi

# Initialize arrays to store durations
declare -a durations

# Iterate from 1 to end_number
for (( i=1; i<=end_number; i++ ))
do
    echo "Processing segment $i..."

    # Define segment URLs and file paths
    segment_url="$baseurl/index.ism/dash/index-$representation-$i.m4s"
    segment_file="$output_folder/seg$i.m4s"
    combined_file="$output_folder/seg$i-combined.m4s"

    # Download each segment
    curl -s "$segment_url" -o "$segment_file"

    # Check if the segment was downloaded successfully
    if [ ! -f "$segment_file" ]; then
        echo "Failed to download segment $i from $segment_url"
        durations[$i]="0"
        continue
    fi

    # Combine with initialization segment
    cat "$output_folder/seg-init.m4s" "$segment_file" > "$combined_file"

    # Run ffprobe to get duration
    duration=$(ffprobe -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$combined_file")

    # Check if ffprobe succeeded
    if [ -z "$duration" ]; then
        echo "Failed to get duration for segment $i."
        duration="0"
    fi

    # Store duration
    durations[$i]="$duration"
done

# Create summary.md
summary_file="$output_folder/summary.md"
{
    echo "# Segment Timing Summary"
    echo ""
    echo "**Base URL:** $baseurl"
    echo "**Representation:** $representation"
    echo "**End Number:** $end_number"
    echo ""
    echo "| Index | Duration (s) | Length (s) |"
    echo "|-------|--------------|------------|"
} > "$summary_file"

# Write table rows
prev_duration=0
for (( i=1; i<=end_number; i++ ))
do
    duration=${durations[$i]}
    if [ -z "$duration" ]; then
        duration="0"
    fi

    # Calculate length
    length=$(echo "$duration - $prev_duration" | bc)
    prev_duration="$duration"

    # Format the duration and length to 6 decimal places
    duration_formatted=$(printf "%.6f" "$duration")
    length_formatted=$(printf "%.6f" "$length")

    # Write to summary file
    echo "| $i     | $duration_formatted     | $length_formatted   |" >> "$summary_file"
done

echo "Summary written to $summary_file"
