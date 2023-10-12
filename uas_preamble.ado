*!Version 1.1
*!Updated 10/12/2023: Updated file paths to reflect switch to OD
*!Updated 10/31/2022 to change organizational structure and to add an option to save an intermediate dataset for the current wave.
*!Updated 10/18/2022 to add Amie to user list.
*!Updated 9/23/2022 to update paths for Marshall's Macbook
*!Updated 11/10 to fix the Box paths due to an update in September 2021.
*!Created by mwg 5/22/2020
//Adapted from preamble.ado
capture program drop uas_preamble
program define uas_preamble
	version 9.2
	syntax [anything], ///
		WAVE(string) ///
		[LOGName(string) ///
		LOGPath(string) ///
		GIT ///
		FIGtypes(string) ///
		RESULTSFILE(string) ///
		ADOs(string) ///
		SEED(integer 3456789) ///
		SORTSEED(integer 825920) ///
		NEWWAve ///
		USING(string asis) ///
		CLEANing(string asis) ///
		]

	//Get user's CWD
	local cwd `"`c(pwd)'"'
	*Date cleanup
	global date
	global date `"`=subinstr("`:di %td (date("`c(current_date)'", "DMY"))'", ":", "_", .)'"'

	*Error checking
	if !missing("`newwave'") & missing("`wave'") {
		di as error "Must specify wave using the -wave- option if -newwave- option is entered."
		exit 110
	}

	if "`cleaning'"!="" & "`using'"=="" {
		di as error "If -cleaning- option is used, you must specify the data file you're cleaning in the -using- option."
		exit 110
	}

	if !missing("`cleaning'") & regexm("`cleaning'", `"(\.ado|\.do)$"')==0 {
		di as error "Enter the file type of the cleaning program (.do, .ado)."
		exit 110
	}

	*1. Detecting OS
	** windows
	global root
	if `"`c(os)'"' == `"Windows"' global root `"C:/Users/"'
	** mac/^nix
	if (`"`c(os)'"' == `"MacOSX"' | `"`c(os)'"'=="Unix") global root `"/Users/"'
	if "${root}" == "" {
		di as error "Root folder empty. Program only works on Unix, Mac, or Windows machines."
		exit 110
	}

	*2. Detecing username and combining
	local username "`c(username)'"
	local root "${root}/`username'/"

	*3. Confirming dependencies installed
	//First, .ados
	local dependencies "confirmdir smrtbl"
	if "`ados'"!="" {
		local dependencies "`dependencies' `ados'"
	}
	foreach x of local dependencies {
		cap which `x'
		if _rc!=0 {
			quietly ssc install `x'
		}
	}

	//Now, packages
	local pkg "_gvar.ado ldir dirtree"
	foreach x of local pkg {
		cap which `x'
		if _rc!=0 {
			quietly ssc install `x'
		}
	}

	*4. Creating globals
	//Add primary project team and edu project teams here
	//And, confirm main and sf directories exist!
	//Updated 10/12/2023

	//Updated 10/31/2022
	if "`c(username)'"=="garlandm" & "`c(machine_type)'"=="Mac (Apple Silicon)" {
		global main "`root'/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofSouthernCalifornia/CESR-Education - Data/UAS/surveys/"
		global edu "`root'/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofSouthernCalifornia/CESR-Education - Data/UAS/UAS_COVID/"
		global sf "`root'/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofSouthernCalifornia/"
	}
	else if "`c(username)'"=="amierapaport" {
		global main "`root'/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofSouthernCalifornia/CESR-Education - Data/UAS/surveys/"
		global edu "`root'/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofSouthernCalifornia/CESR-Education - Data/UAS/UAS_COVID/"
		global sf "`root'/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofSouthernCalifornia/"
	}
	else {
		global main "`root'/`c(username)'//University of Southern California/CESR-Education - Data/UAS/surveys/"
		global sf "`root'/`c(username)'//University of Southern California/CESR-Education - Data/UAS/UAS_COVID/"
		global edu "`root'/`c(username)'//University of Southern California/"
	}

	foreach x in main sf {
		quietly confirmdir "${`x'}"
		if `r(confirmdir)'!=0 {
			di as error "Path ${`x''} doesn't exist on user `c(username)'s computer."
			exit 110
		}
	}

	if "`git'"!="" {
		if "`username'"!="garlandm" {
			di as error "The Git option is only available under garlandm's profile."
			exit 110
		}
			global git "${root}/Sites/UAS/Cleaning Code/_Education/"
	}

	//Confirming wave is a valid number
	cap confirm number `wave'
	if _rc!=0 {
		di as error "Invalid wave value (`wave'). Enter wave number as an integer (e.g., 230, 235, 240)."
		exit 110
	}

	global wave `wave'
	local wave "/uas_${wave}/"
	global wavepath${wave} "${main}/`wave'/"

	//Creating new wave project folder if -newwave- specified
	if !mi("`newwave'") {
		cap mkdir "${wavepath${wave}}"
	}

	//Globals in the main UAS directory. The content of these folders' is used across multiple UAS waves, so they are not stored in the wave-specific directory.
	global rawdata "$sf/Data/Raw/"
	global cleandata "$sf/Data/Clean/"
	global csvdata "$sf/Data/CSV/"
	global coviddata "$sf/Data/COVID/"
	global code "$sf/Code/_ChildFiles/"
	global extras "$main/Code/Extras/"
	global masterdata "${cleandata}Masterdataset/"
	global intermediate "${cleandata}Intermediate Datasets/"
	global other "${main}/Code/Other/"
	global securedata "${main}/Data/Secure Data/"
	global ccddata "$main/CCD_data/"

	//Create wave folders and confirm the path exists on the user's machine.
	local fcreate raw clean code documentation logs output results tracker qc toplines instrument
	foreach w in `fcreate' {
		global `w'${wave} "$main/`wave'/`w'"
		quietly confirmdir "${`w'${wave}}"
		if `r(confirmdir)'!=0 & "`newwave'"=="" {
			di as error "Path ${`w'${wave}} doesn't exist. Check base path or specify -newwave- option to create a new wave subfolder."
			exit 110
		}
		if `r(confirmdir)'!=0 & "`newwave'"!="" {
			cap mkdir "${`w'${wave}}"
		}
	}

	*Adding primary project team globlals for mgarland only, since i have access to the main dbox
	if "`username'"=="garlandm" {
		global dbox "${root}/`c(username)'//Dropbox/TEAM UAS COVID-19/"
		global dboxdata "${dbox}/Data/"
		global d_documentation "${dbox}/Documentation/data description/crosswalks/"
		global d_masterdata "${dboxdata}/Clean/Masterdataset/"
		global d_intermediate "${dboxdata}/Clean/Intermediate Datasets/"
	}

	**Colors
	global uscred "144 53 59"
	global uscyellow "255 210 0"
	global uscgray "200 200 200"
	global uscblack "0 0 0"
	global uscturq "228 172 226"
	global uscblue "6 49 155"
	global uscdbrown "102 71 47"
	global usclbrown "180 148 114"

	*5. Now, resultsfilename
	if !missing("`resultsfile") {
		global resultsfile "`resultsfile'_`username'_${date}.xlsx"
	}

	*6. Creating log file
	local log
	cap log close
	if "`logname'"!="" & "`logpath'"!="" {
		local log "`logpath'//`logname'_`username'_${date}"
		log using "`log'", replace text
	}
	if "`logname'"!="" & "`logpath'"=="" {
		local log "${logs${wave}}//`logname'_`username'_${date}"
		di as txt "Log path not specified:{bf: using ${logs${wave}}"
		log using "`log'", replace text
	}
	if "`logpath'"!="" & "`logname'"=="" {
		di as error "Specified -logpath- option without a -logname-. Please enter the log name using the -logname- option."
		exit 110
	}

	*7. Setting scheme: default is usc
	quietly adopath ++ "${extras}"
	local scheme="usc"
	set scheme `scheme'

	*8. Figtypes
	*Default is .png
	local out
	local valid ps eps svg wmf emf pdf png tif gif jpg
	if "`figtypes'"=="" {
		global figtypes png
	}
	if "`figtypes'"!="" {
		*First, confirming each element in the list is a valid graph type
		local test : list figtypes in valid
		if `test'==0 {
			di as error "At least one graph type in your -figtypes- option is not a valid Stata graph type."
			exit 110
		}
		if `test'==1 {
			global figtypes `figtypes'
		}
	}

	*9. Seed
	set seed `seed'

	*9a. Sortseed
	set sortseed `sortseed'

	*10. Using.
	local use
	local use "`using'"
	if "`use'"!="" {
		cap confirm file "${raw${wave}}/`use'.dta"
		if _rc!=0 {
			di as error "File `use' not found in ${raw${wave}}"
		}
		else {
			use "${raw${wave}}/`use'", clear
		}
	}

	*11. Cleaning
	if "`cleaning'"!="" {
		tokenize "`cleaning'", parse(",")
		while "`1'"!="" {
			cap confirm file "${code}`1'"
			local inmaster=_rc
			assert !missing(`inmaster')
			*In master, running
			if `inmaster'==0 {
				di as result "`1' found in ${code}: executing."
				quietly do "${code}`1'"
			}
			*Not in master, but -wave- option specified
			if `inmaster'!=0 & "`wave'"!="" {
				cap confirm file "${code${wave}}`1'"
				*Not found in the master folder or the subfolder
				if _rc!=0 {
					di as error "`1' not found in ${code} or ${code${wave}}: Nothing executed."
				}
				*not found in master, but found in the subfolder.
				else {
					di as result "`1' found in ${code${wave}}: executing."
					quietly do "${code${wave}}`1'"
				}
			}
			mac shift 2
		}
	}

	//Printout directory structure!
	qui cd "${wavepath${wave}}"
	di as result "Welcome `c(username)'!: Below are the sub-folders in the " in red "UAS ${wave}" as result " directory"
	dirtree, dir(${wavepath${wave}})
	di as text "Click the [uas_${wave}] link below to change your working directory to the UAS ${wave} folder:"
	di as result `"{stata `"cd `"${wavepath${wave}}"'"':[uas_${wave}]}
	qui cd "`cwd'"
end
