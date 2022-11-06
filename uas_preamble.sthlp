{smcl}
{hline}
help for {hi:uas_preamble}
{hline}

{title:Simplifying the .do file preamble setup for the UAS project}

{p 8 12 2}
{cmd:uas_preamble}
[
{cmd:,}
{cmdab:logn:ame}[{cmd:(}{it:"logname"}{cmd:)}]
{cmdab:logp:path}[{cmd:(}{it:"logpath"}{cmd:)}]
{cmdab:fig:types}[{cmd:(}{it:fileformat}{cmd:)}]
{cmd:wave(}{it:#}{cmd:)}
{cmd:resultsfile}[{cmd:(}{it:"output_file_name"}{cmd:)}]
{cmd:waveout}[{cmd:(}{it:"Path and name of wave-only file"}{cmd:)}]
{cmdab:ado:s}{cmd:(}{it:ados_to_install,}{cmd:)}
{cmd:seed(}{it:#}{cmd:)}
{cmd:sortseed(}{it:#}{cmd:)}
{cmdab:neww:ave}
{cmd:using}
{cmdab:clean:ing}{cmd:(}{it:ados_and_dos_to_run,}{cmd:)}
]

{title:Options}

{p 4 8 2}{cmd:wave} Enter the number of the current UAS wave. This option is {bf:required}.

{p 4 8 2}{cmd:logname} Creates a log file matching the name entered.

{p 4 8 2}{cmd:logpath} Defines the path to save the log file. Default is
to save in current survey path path defined in the {bf:logs} global macro. If specified, logname
must be entered.

{p 4 8 2}{cmd:figtypes} Places the {it:fileformat}s of the figures created
in the .do file in a global macro named {bf:figtypes}. This can be used with the
{cmd:graphsout} command to export a graph to multiple format types. The default is .png.
Figure types should be separated by spaces. See {help graph_export} for available export types.

{p 4 8 2}{cmd:resultsfile} Name of the output file for exporting results to a spreadsheet.
Excel format is .xlsx. Creation date is automatically added as a suffix to the file name.

{p 4 8 2}{cmd:ados} Ado files to install during the session. Unique ados should be separated by commas.

{p 4 8 2}{cmd:seed} Seed number for random number generator. Default is {bf:3456789}.

{p 4 8 2}{cmd:sortseed} Sort seed number for random number generator for sorting. Default is {bf:825920}.

{p 4 8 2}{cmd:newwave} Option creates directories
and sub-directories for the new wave and corresponding global macros. Type -macro dir- to
view directories stored in global macros. If option is entered, {cmd:wave} must be populated
with the new wave.

{p 4 8 2}{cmd:using} Enter the name of the source file (e.g., covidpanel_us_stata_jun_10_2020).
Only opens files in the /raw/ folder in the current survey wave directory.

{p 4 8 2}{cmd:cleaning} Cleaning scripts to run. Multiple scripts should be separated by commas.
The program searches through two directories to locate the file specified by the user: the master code folder
and the sub-folder associated with the wave included in the -wave- option. The user must enter the suffix
of the do or ado file (e.g., foo.do, foo.ado). {bf: This option is mostly deprectated, since all of the cleaning scripts are consolidated into the 01_clean.do file!}

{title:Author}

{p 4 4 2}Marshall W. Garland{break}
         University of Southern California{break}
