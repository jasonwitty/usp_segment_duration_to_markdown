# usp_segment_duration_to_markdown
This script automates the process of downloading unified streaming DASH segments when the MPD is in number mode, combining them with the initialization segment, extracting their durations using ffprobe, and summarizing the results in a Markdown file. 

This is useful because when the dash timeline is presented in number mode there is no metadata in the MPD which provides the length of each segment. Since the output is standardized to a markdown file, it is easy to view the resolts in a tabulated format and compare with results from other assets.

## Requirments 

- ffmpeg (ffprobe)
- curl
- glow (recomended for viewing markdown in terminal emulator)

## Usage

Run using command line argmuments below:

```
bash ./segment_timing.sh <baseurl> <representation> <end_number> <output_folder>
```

- baseurl: url to use as base for downloading segments, segment and url pattern assumed based on unified streaming dash output for number timeline mode.
- representation: the bitrate of the track to test, taken from mpd file.
- end_number: can be taken or calculate from the MPD or shortened to short circuit. (if you only want to test the first 10 segments, you can pass in 10 and processing will stop after 10 are downloaded and analyzed)
- output folder

## example output

```
$ glow ./output_folder/summary.md

   Segment Timing Summary

  Base URL: https://someurl/somapath/ID/
  Representation: video=1202000
  End Number: 10

  Index                 │Duration (s)                 │Length (s)
  ──────────────────────┼─────────────────────────────┼───────────────────────────
  1                     │2.002000                     │2.002000
  2                     │2.902900                     │0.900900
  3                     │4.004000                     │1.101100
  4                     │6.006000                     │2.002000
  5                     │8.008000                     │2.002000
  6                     │10.010000                    │2.002000
  7                     │12.012000                    │2.002000
  8                     │14.014000                    │2.002000
  9                     │16.016000                    │2.002000
  10                    │18.018000                    │2.002000
```
