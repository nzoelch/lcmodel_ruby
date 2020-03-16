#!/usr/bin/ruby -rubygems

# shall be run on colombo 07-09 only

require 'find'
require 'fileutils'
require 'descriptive_statistics'
#require 'rinruby'
require './FiTinfo'
require './Fitted_Files'
require './Measurement'
require './Spar'
require './Segmentation'
require './Seperate_ERETIC'
require './B1map'
require './Profile'
require './Receive'
require './Relaxationtimes'

def table_read(auswertung,debug,collect,generate_met_info)
filesdb = Hash.new
search_pattern=Hash.new
#
misc_info=Hash.new
conc_info=Hash.new
#
which_metabolites=Hash.new
#***************************************************************************************************
#---------------------------------------------------------
# search_pattern
search_pattern["table"] = Regexp.new(/(?i:\.table$)/)
#---------------------------------------------------------
#---------------------------------------------------------
# save where (grob) (sollte ins fitinfo)
add_result_path="/summary"
#---------------------------------------------------------
# only take metabolites with %sd smaller than
sd_limit=1000
# when set to 1000 all metabolites are read in the table
#---------------------------------------------------------
#***************************************************************************************************
# loads the info about this analyse
fitinfo = FiTinfo.new("#{auswertung}/FiTinfo.txt", auswertung)
fitted_files = Fitted_Files.new("#{auswertung}/Fitted_Files.txt")
#*****************************************************************************************

#*****************************************************************************************
# Which folder are analized?
# All that are change, according to fitinfo
ftoanalyze=Array.new
fitinfo.basis_sets.each { |basis_set|
  		fitinfo.references.each_key{ |ref|		
			ftoanalyze[ftoanalyze.count]="#{fitinfo.result_path}#{fitinfo.basis_sets.index(basis_set)}/#{ref}/"
	}
}
#-----------------------------------------------------------
# when all should be collected loop over several auswertungen
#------------------------------------------------------------
if collect[0]
	result_path=collect[1]
	puts " results collected in #{result_path}"	
end
#------------------------------------------
#
# loop over all folders that are analyzed
ftoanalyze.each{ |frf|	#frf:finalresultfolder
	#------------------------------
	if !collect[0]
		result_path=frf+add_result_path	
		# delete the old 	f added
		FileUtils.rm_rf(Dir.glob("#{result_path}*"))			
	end
	puts "\n*********************************************"
	puts "#{ftoanalyze.index(frf)+1}"+" of "+"#{ftoanalyze.length}"
	puts "#{frf}"
	puts "*********************************************"
	if fitinfo.sim_profile
		puts "Used for Profile Correction:"
		puts "#{fitinfo.sim_profile_file}\n"
		puts "\n"
	end
	# all files that match the search_pattern 
	# are stored in the array files	
	files = Dir.glob("#{frf}/*")
	search_pattern.each_key{ |criteria|			
		files = files.grep(search_pattern[criteria])
		#puts criteria			
	}
	#----------------------------------------
	# Exclude some
	# This allows to exclude some without repeating the fit
	#----------------------------------------
	if !(fitinfo.exclude_pattern.empty?)
		fitinfo.exclude_pattern.each{ |exclude|
			puts "Files excluded after fit : #{files.grep(/(?i:#{exclude})/)}"
			files = files-files.grep(/(?i:#{exclude})/)
		}
	end
	#---------------------------------------
	# loop over the file found in the folder		
	#---------------------------------------
	metabolites=Hash.new
	metabolites_info=Array.new
	counter=Hash.new
	# counter tables
	counter_tables=0
	#How many tabelles couldn't be used
	counter_bad_tables=0
	# How many metabolites are present
	met_counter=0
	# give the line number where in this particular table file, the $$CONC (or $$MISC) can be found "start"
	# how many lines are there "length"
	conc_lines=Hash.new
	#misc_lines=Hash.new
	#
	# area in basis set under specific singlet (default = cre)
	normalized_area_basis=1
	#
	files.each { |file|
		counter_tables=counter_tables+1
		if debug			
			puts "------------------------------------------------------------------"
			puts ".table file #{counter_tables} of #{files.size} to be analyzed ... "
			puts "  File : #{File.basename(file)}"
		end
		file_to_read = File.new(file,"r");
		# everthing from the file is read into file_content
		#	
		file_content=file_to_read.readlines
		file_to_read.close
		# here out of spar infos are taken
		# more is possible check Spar.rb
		#
		file_name=File.basename(file,".table")
		# Check ##############################################
		line_conc=file_content.grep(/\$\$CONC/)
		if line_conc.empty?
			counter_bad_tables=counter_bad_tables+1
			puts " No CONC info in this file"
			puts "#{file_name}"
			# habe ich ausgeschalten, sollte ok sein wenns durchlaueft
			#next
		end 
		# MRSI specific ######################################
		if fitinfo.mrsi_scan
			mrsi_file_name=file_name.split('_sl')
			#
			file_name=mrsi_file_name[0]
			#
			slice_info=mrsi_file_name[1].split('_')[0]
			voxel_info=mrsi_file_name[1].split('_')[1]
			#
			mrsi_slice=Integer(slice_info)
			mrsi_voxel_row=Integer(voxel_info.split('-')[0])
			mrsi_voxel_col=Integer(voxel_info.split('-')[1])
			#
		end
		######################################################
		# find the according spar file
		######################################################
		file_name=file_name.gsub('^','\^')
		puts "---------------------------"
		puts file_name
		#puts file_name[0..-10] 
		puts "---------------------------"
		#search_file=Regexp.new(/(\/#{file_name})/)
		search_file=Regexp.new(/(\/#{file_name[0..-10]})/)
		puts "----------------------------------------"
		file_sdat = fitted_files.files.grep(search_file)
		puts file_sdat[0]
		#------------------------------------------------------------------
		# patient nr
		#------------------------------------------------------------------
		if fitinfo.patient_search.empty?
			patient_nr=1
		else
			# strip to remove any whitespace
			#puts file_sdat[0]
			if match_nr=file_sdat[0].match(/#{fitinfo.patient_search.strip}(\d*)/)
				patient_nr=match_nr[1].to_i
			else
				puts "Patient Nr set to 1"
				patient_nr=1
			end
		end
		#------------------------------------------------------------------
		# derive additional information from the folder name
		#------------------------------------------------------------------
		if !fitinfo.add_info.empty?
			if debug
				puts "additional information derived from the datapath"
			end
			fitinfo.add_info.each{|key, value| 
			if match_nr=file_sdat[0].match(/#{value}/)
				#puts "#{key} is #{match_nr[1]}" 
				fitinfo.add_info_result[key]=match_nr[1]	
			else
				puts "#{key} with #{value} is not found" 
			end
			}
			# now i create this variables in the Measurement class
			info=Measurement.new
			fitinfo.add_info_result.each{|key, value| 
				info.create_attr( key )
			}
		end
	
		# find the folder where the sdat is saved
		#-------------------------------------------------------------------
		if file_sdat[0].include?'raw_data'
			measurement_folder = "#{file_sdat[0].split('raw_data')[0]}"
		else 
			if file_sdat[0].include?'scanner_data'
				measurement_folder = "#{file_sdat[0].split('scanner_data')[0]}"
			end
		end
		#-------------------------------------------------------------------
		#
		if File.extname(file_sdat[0]).eql?".SDAT"			# Capital lettre
			spar_suffix= ".SPAR"
		else
			spar_suffix= ".spar"
		end
		# here it is the spar
		spar = Spar.new(file_sdat[0].gsub(/(?i:\.sdat$)/,spar_suffix))
		#
		######################################################
		# Use infos from spar or raw data name
		######################################################
		if debug
			puts "Infos from spar file or raw_data name"
		end
		# scan nr
		#--------------------------------
		# if possible from raw_data name		
		# scan date set to empty
		scan_date="" 
		#first checks if sdat/spar file from raw_data with standard name
		if match=file_name.match(/(\w{2})_(\d{8})_\d*_(\d*)_1/)
			patient_name=match[1]
			scan_date=[match[2][0..1],match[2][2..3],match[2][4..7]]
			scan_nr=match[3].to_i
		else
			#or if its a sdat/spar file written by scanner
			info_test=file_name.split('_')
			# if not, so no standard name it sets the scan number to 0
			scan_nr = Integer(info_test[info_test.count-4]) rescue 0
			
			# je nach sdat
			#patient_name=info_test[0]
			patient_name=spar.pat_name
		end
		# scan date
		#--------------------------------
		if scan_date.empty?
		# wurde es schon vom raw ermittelt?
			if spar.exam_date.empty? 
				if debug
					puts "  No date for this scan in spar file"
				end
				puts "  Scan date set for this scan"
				scan_date=["01","01","1001"]	
			else
				scan_date=[spar.exam_date[8..9],spar.exam_date[5..6],spar.exam_date[0..3]]
			end
		end
		if debug
			puts " Scan Nr: #{scan_nr}"
			puts " Scan Date: #{scan_date[0..2]}"
			puts " Patient_nr : #{patient_nr}"
			puts " Patient Name : #{patient_name}"
		end
		
		position='unknown'
		# #special for EF measurements 
		# #---------------------------
		# if pos=file_name.match(/_(\w{1})V4/)
			# position=pos[1]
		# end
		# #special for DS measurements 
		# #---------------------------
		if pos=file_name.match(/\_([a-zA-Z]*)\w{0,1}V4/)
				position=pos[1]
		end
		#puts position
		######################################################
		# MISC info
		######################################################
		# man koennte auch alles mit grep, versuche ich aber zu vermeiden
		# line_fwhm=file_content.grep(/FWHM = \d.\d+\s*ppm/)
		# mit klammern und $1 koennte man auch eines direkt auslesen, 2 habe ich aber noch nicht geschafft
		#--------------------------------------------------------------------------------------------------
		if fitinfo.use_misc_info
			# find line with $$MISC
			line_misc=file_content.grep(/\$\$MISC/)
			if !line_misc.empty?
				nr_line_misc=file_content.index(line_misc[0])
				# match fwhm and snr: zeile +1
				match_output=file_content[nr_line_misc+1].match(/FWHM\s*=\s*(\d.\d+)\s*ppm\s*S\/N\s*=\s*(\d*)/ )
				fwhm_ppm=match_output[1].to_f
				fwhm_hz=fwhm_ppm/1000000*spar.f0
				snr=match_output[2]
				# match data shift: zeile +2
				match_output=file_content[nr_line_misc+2].match(/Data shift\s*=\s*(\W*\d.\d+)\s*ppm/ )
				data_shift=match_output[1]
				# match phase and first order: zeile +3\s*(\d*.\d*)\s*deg\/ppm
				#puts file_content[nr_line_misc+3]
				match_output=file_content[nr_line_misc+3].match(/Ph:\s*\W*(\d*\W*\d*)\s*deg\s*(\W*\d*.\d*)\s*deg\/ppm/ )
				zero_phase=match_output[1]
				first_phase=match_output[2]
			end
			
		end
		######################################################
        # b1map info
		######################################################
		if fitinfo.b1map		
			if !fitinfo.b1_raw_file.empty?
				b1_raw_file="#{measurement_folder}" + "#{fitinfo.b1_raw_file}"
				#
				#puts b1_raw_file
				
				if fitinfo.mrsi_scan
					b1_raw= B1map.new(b1_raw_file,mrsi_voxel_row,mrsi_voxel_col)
				else
					b1_raw= B1map.new(b1_raw_file,1,1)
				end
			end
			#
			if !fitinfo.b1_rec_file.empty?
				b1_rec_file="#{measurement_folder}" + "#{fitinfo.b1_rec_file}"
				# ACHTUNG B1map_DS anstatt B1map Class
				b1_rec= B1map_DS.new(b1_rec_file,scan_nr);
			end
		end
		######################################################
        # Receive info
		######################################################
		if fitinfo.receive_sensitivity		
				receive_file_path="#{measurement_folder}" + "#{fitinfo.receive_file}"
				if debug
					puts "Receive Sensitivity"
					puts "  File : #{receive_file_path}"
					puts "  Searching for : #{spar.offcenter}"
				end
				receive_sens=Receive.new(receive_file_path, spar.offcenter)
				if debug
					puts "  Results: "
					puts "  receive : #{receive_sens.receive}"
					puts "  receive_scaled : #{receive_sens.receive_scaled}"
					puts "  receive_b1map : #{receive_sens.receive_b1map}"
					puts "  ratio : #{receive_sens.receive_ratio}"
				end
		end
		######################################################
        # sim b1map and pulse profil
		######################################################
		#puts fitinfo.sim_profile
		if fitinfo.sim_profile	
			if !fitinfo.sim_profile_file.empty?
				sim_profile_file="#{measurement_folder}" + "#{fitinfo.sim_profile_file}"
				#
				profile=Profile.new(sim_profile_file,mrsi_voxel_row,mrsi_voxel_col);
				
			end

		end
	    # Profil vom Phantom einlesen
		if fitinfo.phantom_profile
			puts "phantom"
			phantom_profile=PhantomProfile.new(fitinfo.phantom_profile_file,mrsi_voxel_row,mrsi_voxel_col);
		end
		#####################################################
        # Use distance to head
		######################################################
		if fitinfo.use_distance
			distance_file_path="#{measurement_folder}" + "#{fitinfo.distance_file}"
			distance_to_head=Distance.new(distance_file_path)
			# halbes fov vom survey -distance_to_head - cc_offcenter ergibt unegefaehre distance vom voxel zur spule
			dist_voxel_to_coil= 125-distance_to_head.min-spar.offcenter["cc"]
		end
		######################################################
        # segmentation info
		######################################################
		if fitinfo.segmentation
			if !fitinfo.segment_file.empty?
			# decude the measurement folder from the .sdat----------------------
				if fitinfo.segment_folder2split.empty?
					if file_sdat[0].include?'raw_data'
						measurement_folder = "#{file_sdat[0].split('raw_data')[0]}"
					else 
						if file_sdat[0].include?'scanner_data'
						measurement_folder = "#{file_sdat[0].split('scanner_data')[0]}"
						end
					end
				else
					measurement_folder = "#{file_sdat[0].split(fitinfo.segment_folder2split)[0]}"
				end
					
				#puts "#{measurement_folder}" + "#{fitinfo.segment_file}"
				segm_file="#{measurement_folder}" + "#{fitinfo.segment_file}"
				if debug
					puts "Segmentation"
					puts "  Sdat File : #{file_sdat[0]}"
					puts "  File : #{segm_file}"
					puts "  Patient Nummer : #{patient_nr}"
				end
				if fitinfo.mrsi_scan
					segment_results = Segmentation.new(segm_file,scan_nr,mrsi_voxel_row,mrsi_voxel_col,debug,fitinfo);
				else
					segment_results = Segmentation.new(segm_file,scan_nr,1,1,debug,fitinfo);
				end
				if debug
					puts "  Results: "
					for nn in 0..(segment_results.info_col.size-1)
						puts "  #{segment_results.info_col[nn]} : #{segment_results.comp[nn]}"
					end
				end
			else
				puts "Segmentation NOT READ FROM FILE"
				puts fitinfo.given_segm
				segment_results = Segmentation.new("",0,1,1,debug,fitinfo);
			
			end
			
		end
		######################################################
        # Relaxation times
		######################################################
		#
		if fitinfo.read_in_relax
			puts "Relaxation Times read from external file"
			water_relaxation = Relaxationtimes.new(patient_nr,debug,fitinfo);
		end
		######################################################
        # Concentration from calibration ERETIC
		######################################################
		if fitinfo.calib_conc_eretic
			info_calibration=ERETIC_Calib_Conc.new(fitinfo,spar.exam_date)
		end
		######################################################
        # Concentration from calibration DS
		######################################################
		if fitinfo.calib_conc_ds 
			info_calibration_ds=DS_Calib_Conc.new(fitinfo,spar.exam_date,patient_nr,file_sdat)
		end
		######################################################
        # Info from qbc (or any other transmit receive coil)
		# water area and drive scale
		# test for te/tr (to do)
		######################################################
		if fitinfo.qbc_water_ds 
			info_qbc=Read_QBC_water.new(fitinfo,spar.exam_date,patient_nr,file_sdat)
		end
		######################################################
        # Info from sense (or any other transmit receive coil)
		# needed for drive scale
		######################################################
		if fitinfo.sense_water_ds 
			info_sense=Read_SENSE_water.new(fitinfo,spar.exam_date,patient_nr,file_sdat)
			#puts "SENSE"
			#puts "---------------------------"
			#puts info_sense.sense_water_area
			#puts "---------------------------"
		end
		
		######################################################
        # Seperate ERETIC
		######################################################
		if fitinfo.seperate_eretic
			if debug
				puts "Seperate ERETIC"
				puts "  Folder : #{fitinfo.seperate_folder}"
				puts "  Patient Name : #{patient_name}"
				puts "  Patient Nr : #{patient_nr}"
			end
			seperate_eretic=Seperate_ERETIC.new(fitinfo,patient_nr,spar.scan_id,scan_nr)
			#------------------------------------------------
			if !(metabolites.has_key?("eretic"))
				metabolites["eretic"]=Array.new
				counter["eretic"]=0
				# Information about the metabolites over all scans collected
				metabolites_info[metabolites_info.count]=MetaboliteInfo.new("eretic")
			end
			
			metabolites["eretic"][counter["eretic"]]=Measurement.new
			#----------------------------------------------------------------
			# In fitinfo zusaetzliche Informationen aus dem folder namen gesucht
			# wenn gefunden, dann werden sie hier gesetzt
	
			if !fitinfo.add_info_result.empty?
	
				fitinfo.add_info_result.each{|key, value| 
					metabolites["eretic"][counter["eretic"]].set_special(key,value)
				}
			end
			#----------------------------------------------------------------

			
			# ACHTUNG ACHTUNG wegen fcalib
			metabolites["eretic"][counter["eretic"]].conc=Float(seperate_eretic.area)
			metabolites["eretic"][counter["eretic"]].sd=Float(seperate_eretic.sd)
			metabolites["eretic"][counter["eretic"]].met="eretic"
			metabolites["eretic"][counter["eretic"]].tr=spar.tr
			metabolites["eretic"][counter["eretic"]].te=spar.te
			metabolites["eretic"][counter["eretic"]].samples=spar.pts
			metabolites["eretic"][counter["eretic"]].date_scan=scan_date
			metabolites["eretic"][counter["eretic"]].name_scan=spar.scan_id
			metabolites["eretic"][counter["eretic"]].filename=file_name
			metabolites["eretic"][counter["eretic"]].nr_scan=scan_nr
			metabolites["eretic"][counter["eretic"]].nr_patient=patient_nr
			metabolites["eretic"][counter["eretic"]].name_patient=patient_name
			metabolites["eretic"][counter["eretic"]].exam_name=spar.exam_name
			metabolites["eretic"][counter["eretic"]].position=position
			#voi 
			metabolites["eretic"][counter["eretic"]].voi_ap=spar.voi_size["ap"]
			metabolites["eretic"][counter["eretic"]].voi_lr=spar.voi_size["lr"]
			metabolites["eretic"][counter["eretic"]].voi_cc=spar.voi_size["cc"]
			metabolites["eretic"][counter["eretic"]].voi_vol=spar.voi_size["ap"]*spar.voi_size["lr"]*spar.voi_size["cc"]
			# information not from the eretic measurement
			metabolites["eretic"][counter["eretic"]].offcenter_ap=spar.offcenter["ap"]
			metabolites["eretic"][counter["eretic"]].offcenter_lr=spar.offcenter["lr"]
			metabolites["eretic"][counter["eretic"]].offcenter_cc=spar.offcenter["cc"]
			metabolites["eretic"][counter["eretic"]].dist_voxel_coil=dist_voxel_to_coil
			#
			metabolites["eretic"][counter["eretic"]].par_fwhm_hz=spar.fwhm_water_1
			metabolites["eretic"][counter["eretic"]].par_fwhm_hz_2=spar.fwhm_water_2
			#mrsi 
			if fitinfo.mrsi_scan
					
				metabolites["eretic"][counter["eretic"]].slice=mrsi_slice
				metabolites["eretic"][counter["eretic"]].row=mrsi_voxel_row
				metabolites["eretic"][counter["eretic"]].col=mrsi_voxel_col
					
			end
			if !fitinfo.b1_raw_file.empty?
				metabolites["eretic"][counter["eretic"]].b1raw_per=b1_raw.percentage
				metabolites["eretic"][counter["eretic"]].b1raw_cf=b1_raw.cfactor
			end
			if !fitinfo.b1_rec_file.empty?
				metabolites["eretic"][counter["eretic"]].b1rec_max=b1_rec.max
				metabolites["eretic"][counter["eretic"]].b1rec_per=b1_rec.percentage
				metabolites["eretic"][counter["eretic"]].b1rec_cf=b1_rec.cfactor
			end
			if fitinfo.sim_profile
				metabolites["eretic"][counter["eretic"]].sim_mr_mxy=Float(profile.mr_mxy)
				metabolites["eretic"][counter["eretic"]].sim_abs_mxy=Float(profile.abs_mxy)
			end
			if fitinfo.segmentation
				metabolites["eretic"][counter["eretic"]].f_gm_vol=Float(segment_results.comp[3])
				metabolites["eretic"][counter["eretic"]].f_wm_vol=Float(segment_results.comp[4])
				metabolites["eretic"][counter["eretic"]].f_csf_vol=Float(segment_results.comp[5])
			end
			if fitinfo.use_misc_info
				if debug
				puts "  Attention Misc Info for ERETIC not from seperate scan "
				end
				metabolites["eretic"][counter["eretic"]].fwhm_hz=fwhm_hz
				metabolites["eretic"][counter["eretic"]].fwhm_ppm=fwhm_ppm
				metabolites["eretic"][counter["eretic"]].snr=snr
				metabolites["eretic"][counter["eretic"]].data_shift=data_shift
				metabolites["eretic"][counter["eretic"]].zero_phase=zero_phase
				metabolites["eretic"][counter["eretic"]].first_phase=first_phase
							
			end
			if fitinfo.receive_sensitivity
				metabolites["eretic"][counter["eretic"]].receive=receive_sens.receive
				metabolites["eretic"][counter["eretic"]].receive_scaled=receive_sens.receive_scaled
				metabolites["eretic"][counter["eretic"]].receive_b1map=receive_sens.receive_b1map
				metabolites["eretic"][counter["eretic"]].receive_ratio=receive_sens.receive_ratio
			end
			#if fitinfo.drive_scale
			#			metabolites["eretic"][counter["eretic"]].drive_scale=spar.drive_scale
			#			metabolites["eretic"][counter["eretic"]].one_over_drive=1/spar.drive_scale
			#end
			if fitinfo.calib_conc_eretic
						metabolites["eretic"][counter["eretic"]].eretic_normalized_calib_conc=info_calibration.eretic_calib_conc
			end
			if fitinfo.calib_conc_ds 
						metabolites["eretic"][counter["eretic"]].ds_normalized_calib_conc=info_calibration_ds.ds_calib_conc
						metabolites["eretic"][counter["eretic"]].ds_calib_averaged=info_calibration_ds.ds_calib_averaged
			end
			if fitinfo.qbc_water_ds 
				metabolites["eretic"][counter["eretic"]].qbc_water_area=info_qbc.qbc_water_area
				metabolites["eretic"][counter["eretic"]].qbc_drive_scale=info_qbc.qbc_drive_scale
			end
					
			counter["eretic"]=counter["eretic"]+1

		end
		######################################################
        # get info about the water from .print file
		######################################################
		water_present=false
		area_line_nr=0
		fcalib_line_nr=0
		# 
		if fitinfo.water_measurement
			water_present=true
			water_conc=1
			water_fcalib=1
			if debug
				puts "Water Measurement"
				puts "  No water_conc in .print file, set to 1"
				puts "  No water_fcalib in .print file, set to 1"
				puts "  mrecon_w taken from spar"
			end
		else
			#
			print_file=file.gsub(/(?:\.table$)/,".print")
			#
			print_file_to_read = File.new(print_file,"r");
			print_file_content=print_file_to_read.readlines
			print_file_to_read.close
			#--------------------------------
			# area in basis set under specific singlet (default = cre)
			#--------------------------------
			line_normalized_area_basis=print_file_content.grep(/^(Normalized area of reference Basis singlet)/)
			if !line_normalized_area_basis.empty?
				normalized_area_basis=Float(line_normalized_area_basis[0].split('=')[1])
				#puts normalized_area_basis
			end
			#
			print_file_content.each_index{|line_nr|
				if print_file_content[line_nr].match(/^(Area of unsuppressed water peak)/)			
					area_line_nr=line_nr
					fcalib_line_nr=line_nr+1
					water_present=true
				end
			}
			if water_present
				water_conc=Float(print_file_content[area_line_nr].split('=')[1])
				water_fcalib=Float(print_file_content[fcalib_line_nr].split('=')[1])
			end				
		end
		#
		if water_present
			
			if !(metabolites.has_key?("water"))
				metabolites["water"]=Array.new
				counter["water"]=0
				# Information about the metabolites over all scans collected
				metabolites_info[metabolites_info.count]=MetaboliteInfo.new("water")
			end
			
			#puts "#{Float(file_content[fcalib_line_nr].split('=')[1])}"
			
			metabolites["water"][counter["water"]]=Measurement.new	
			
			#----------------------------------------------------------------
			# In fitinfo zusaetzliche Informationen aus dem folder namen gesucht
			# wenn gefunden, dann werden sie hier gesetzt
			
			if !fitinfo.add_info_result.empty?
			
				fitinfo.add_info_result.each{|key, value| 
				metabolites["water"][counter["water"]].set_special(key,value)
				}
			end
			#----------------------------------------------------------------
			#
			#-----------------------------------------------------------------------------
			#
			#metabolites["water"][counter["water"]].conc=Float(print_file_content[area_line_nr].split('=')[1])	
			metabolites["water"][counter["water"]].conc=water_conc
			metabolites["water"][counter["water"]].sd=0
			metabolites["water"][counter["water"]].met="water"
			metabolites["water"][counter["water"]].tr=spar.tr
			metabolites["water"][counter["water"]].te=spar.te
			metabolites["water"][counter["water"]].samples=spar.pts
			#metabolites["water"][counter["water"]].fcalib=Float(print_file_content[fcalib_line_nr].split('=')[1])
			metabolites["water"][counter["water"]].fcalib=water_fcalib
			metabolites["water"][counter["water"]].date_scan=scan_date
			metabolites["water"][counter["water"]].name_scan=spar.scan_id
			metabolites["water"][counter["water"]].filename=file_name
			metabolites["water"][counter["water"]].nr_scan=scan_nr
			metabolites["water"][counter["water"]].nr_patient=patient_nr
			metabolites["water"][counter["water"]].name_patient=patient_name
			metabolites["water"][counter["water"]].exam_name=spar.exam_name
			metabolites["water"][counter["water"]].position=position
			#voi
			metabolites["water"][counter["water"]].voi_ap=spar.voi_size["ap"]
			metabolites["water"][counter["water"]].voi_lr=spar.voi_size["lr"]
			metabolites["water"][counter["water"]].voi_cc=spar.voi_size["cc"]
			metabolites["water"][counter["water"]].voi_vol=spar.voi_size["ap"]*spar.voi_size["lr"]*spar.voi_size["cc"]
			# offcenter
			metabolites["water"][counter["water"]].offcenter_ap=spar.offcenter["ap"]
			metabolites["water"][counter["water"]].offcenter_lr=spar.offcenter["lr"]
			metabolites["water"][counter["water"]].offcenter_cc=spar.offcenter["cc"]
			metabolites["water"][counter["water"]].dist_voxel_coil=dist_voxel_to_coil
			#
			metabolites["water"][counter["water"]].par_fwhm_hz=spar.fwhm_water_1
			metabolites["water"][counter["water"]].par_fwhm_hz_2=spar.fwhm_water_2
			#mrsi 
			
			if fitinfo.mrsi_scan
					
				metabolites["water"][counter["water"]].slice=mrsi_slice
				metabolites["water"][counter["water"]].row=mrsi_voxel_row
				metabolites["water"][counter["water"]].col=mrsi_voxel_col
					
			end
			if fitinfo.use_misc_info
					
				metabolites["water"][counter["water"]].fwhm_hz=fwhm_hz
				metabolites["water"][counter["water"]].fwhm_ppm=fwhm_ppm
				metabolites["water"][counter["water"]].snr=snr
				metabolites["water"][counter["water"]].data_shift=data_shift
				metabolites["water"][counter["water"]].zero_phase=zero_phase
				metabolites["water"][counter["water"]].first_phase=first_phase
					
			end
			if !fitinfo.b1_raw_file.empty?
				metabolites["water"][counter["water"]].b1raw_per=b1_raw.percentage
				metabolites["water"][counter["water"]].b1raw_cf=b1_raw.cfactor
			end
			if !fitinfo.b1_rec_file.empty?
				metabolites["water"][counter["water"]].b1rec_max=b1_rec.max
				metabolites["water"][counter["water"]].b1rec_per=b1_rec.percentage
				metabolites["water"][counter["water"]].b1rec_cf=b1_rec.cfactor
			end
			#
			if fitinfo.receive_sensitivity
				metabolites["water"][counter["water"]].receive=receive_sens.receive
				metabolites["water"][counter["water"]].receive_scaled=receive_sens.receive_scaled
				metabolites["water"][counter["water"]].receive_b1map=receive_sens.receive_b1map
				metabolites["water"][counter["water"]].receive_ratio=receive_sens.receive_ratio
			end
			#
			if fitinfo.sim_profile
				metabolites["water"][counter["water"]].sim_mr_mxy=Float(profile.mr_mxy)
				metabolites["water"][counter["water"]].sim_abs_mxy=Float(profile.abs_mxy)
			end
			if fitinfo.phantom_profile
				metabolites["water"][counter["water"]].mxy_phantom=phantom_profile.mxy_phantom
			end
			if fitinfo.segmentation
				metabolites["water"][counter["water"]].f_gm_vol=Float(segment_results.comp[3])
				metabolites["water"][counter["water"]].f_wm_vol=Float(segment_results.comp[4])
				metabolites["water"][counter["water"]].f_csf_vol=Float(segment_results.comp[5])
			end
			if fitinfo.read_in_relax
				metabolites["water"][counter["water"]].t1=water_relaxation.t1_read
				metabolites["water"][counter["water"]].t2=water_relaxation.t2_read
			end
			# added 2019
			# ausbau moeglich
			if fitinfo.get_ref_info=="gussew"
				metabolites["water"][counter["water"]].gussew_t2=spar.t2_water
				metabolites["water"][counter["water"]].gussew_ratio=spar.a_water_ratio
			end
			#
			metabolites["water"][counter["water"]].temp_freq_shift=spar.temp_freq_shift
			#
			if fitinfo.drive_scale
				if debug
				  puts "Drive Scale"
				  puts "  Value from spar: #{spar.drive_scale}"
				end
				metabolites["water"][counter["water"]].drive_scale=spar.drive_scale
				metabolites["water"][counter["water"]].one_over_drive=1/spar.drive_scale
			end
			#
			if fitinfo.mrecon_area
				metabolites["water"][counter["water"]].mrecon_w=spar.mrecon_area_w
				metabolites["water"][counter["water"]].mrecon_td_w=spar.mrecon_td_w_null
				metabolites["water"][counter["water"]].mrecon_e=spar.mrecon_area_e
			end
			#
			if fitinfo.calib_conc_eretic
						metabolites["water"][counter["water"]].eretic_normalized_calib_conc=info_calibration.eretic_calib_conc
			end
			#
			if fitinfo.calib_conc_ds 
						metabolites["water"][counter["water"]].ds_normalized_calib_conc=info_calibration_ds.ds_calib_conc
						metabolites["water"][counter["water"]].ds_calib_averaged=info_calibration_ds.ds_calib_averaged
			end
			if fitinfo.qbc_water_ds 
				metabolites["water"][counter["water"]].qbc_water_area=info_qbc.qbc_water_area
				metabolites["water"][counter["water"]].qbc_drive_scale=info_qbc.qbc_drive_scale
			end	
			if fitinfo.sense_water_ds 
				metabolites["water"][counter["water"]].sense_water_area=info_sense.sense_water_area
				metabolites["water"][counter["water"]].sense_drive_scale=info_sense.sense_drive_scale
			end	
			counter["water"]=counter["water"]+1
			#
		end
		# End Information from .print
		######################################################################################
		# give the line number where in this particular table file, the $$CONC and $$MISC line can be found 	
		conc_lines.clear
		#misc_lines.clear
		#
		file_content.each_index{|line_nr|
			if file_content[line_nr].match(/^(\$\$CONC)/)			
				conc_lines["length"]=Integer(file_content[line_nr].match(/([0-9])+/)[0])			
				conc_lines["start"]=line_nr		
				puts conc_lines["start"]
				puts conc_lines["length"]
			else
			end
			
			if !conc_lines.empty?		
				#puts conc_lines["start"]+1
				#puts conc_lines["start"]+conc_lines["length"]
				#puts "**************************************"
				if (line_nr > conc_lines["start"]+1 && line_nr <= conc_lines["start"]+conc_lines["length"])
					#------------------------------------------------------------
					# sometime LCModel writes wrong number of lines in table data
					# this line checks if there is still something in the read line.
                    break if !file_content[line_nr].match(/.+/)
					#------------------------------------------------------------
					#splitted_line=file_content[line_nr].gsub('+-',' -').split(' ')
					#
					# info_table[1]=conc
					# info_table[3]=sd
					# info_table[4]=ratio
					# info_table[6]=name
					info_table=file_content[line_nr].match(/\W*(\d*.\d*(\d*|E\W\d*))\W*(\d*%)\W*(\d*.\d*(\d*|E\W\d*))\W*([a-zA-Z]\w.*)$/)
					#puts file_content[line_nr]
					#puts info_table[1]
					#puts info_table[3]
					#puts info_table[4]
					#puts info_table[6]
					#match=file_content[line_nr].match(/([a-zA-Z]\w.*)$/)
					
					# old part still here if the upper part does not work
					# splitted_line=file_content[line_nr].split(' ')
					# if splitted_line.length == 4
						# met_name=splitted_line[3]
						# if debug
							# puts " Metabolite Name: #{met_name}"
						# end
						# # idee for later
						# #puts met_name.match(/\W*\w*\W*\w*\W*\w*/)
					# else #sometimes there is a + instead of a ' '
						# plus_splitted=splitted_line[2].split('+')
						# # das war falsch
						# #met_name=plus_splitted[1..plus_splitted.length]
						# met_name=plus_splitted[1]
						# if debug
							# puts " Metabolite Name with a plus: #{met_name}"
						# end
						# splitted_line[2]=plus_splitted[0]
					# end
					
					met_name=info_table[6].strip
					if debug
							puts " Metabolite Name: #{met_name}"
					end
					if !(metabolites.has_key?("#{met_name}"))
						metabolites["#{met_name}"]=Array.new
						counter["#{met_name}"]=0
						# Information about the metabolites over all scans collected
						metabolites_info[metabolites_info.count]=MetaboliteInfo.new("#{met_name}")
					end
					#
					metabolites["#{met_name}"][counter["#{met_name}"]]=Measurement.new	
					
					#----------------------------------------------------------------
					# In fitinfo zusaetzliche Informationen aus dem folder namen gesucht
					# wenn gefunden, dann werden sie hier gesetzt
			
					if !fitinfo.add_info_result.empty?
			
						fitinfo.add_info_result.each{|key, value| 
							metabolites["#{met_name}"][counter["#{met_name}"]].set_special(key,value)
						}
					end
					#----------------------------------------------------------------
					#
					metabolites["#{met_name}"][counter["#{met_name}"]].conc=Float(info_table[1])			#Float(splitted_line[0])	
					metabolites["#{met_name}"][counter["#{met_name}"]].sd=Float(info_table[3].delete"%")	#Float(splitted_line[1].delete"%")
					metabolites["#{met_name}"][counter["#{met_name}"]].ratio=Float(info_table[4])			#splitted_line[2]
					metabolites["#{met_name}"][counter["#{met_name}"]].met=met_name
					metabolites["#{met_name}"][counter["#{met_name}"]].te=spar.te
					metabolites["#{met_name}"][counter["#{met_name}"]].tr=spar.tr
					metabolites["#{met_name}"][counter["#{met_name}"]].samples=spar.pts
					metabolites["#{met_name}"][counter["#{met_name}"]].date_scan=scan_date
					metabolites["#{met_name}"][counter["#{met_name}"]].name_scan=spar.scan_id
					metabolites["#{met_name}"][counter["#{met_name}"]].filename=file_name
					metabolites["#{met_name}"][counter["#{met_name}"]].nr_scan=scan_nr
					metabolites["#{met_name}"][counter["#{met_name}"]].nr_patient=patient_nr 
					metabolites["#{met_name}"][counter["#{met_name}"]].name_patient=patient_name
					metabolites["#{met_name}"][counter["#{met_name}"]].exam_name=spar.exam_name
					metabolites["#{met_name}"][counter["#{met_name}"]].position=position
					#voi
					metabolites["#{met_name}"][counter["#{met_name}"]].voi_ap=spar.voi_size["ap"]
					metabolites["#{met_name}"][counter["#{met_name}"]].voi_lr=spar.voi_size["lr"]
					metabolites["#{met_name}"][counter["#{met_name}"]].voi_cc=spar.voi_size["cc"]
					metabolites["#{met_name}"][counter["#{met_name}"]].voi_vol=spar.voi_size["ap"]*spar.voi_size["lr"]*spar.voi_size["cc"]
					#
					metabolites["#{met_name}"][counter["#{met_name}"]].offcenter_ap=spar.offcenter["ap"]
					metabolites["#{met_name}"][counter["#{met_name}"]].offcenter_lr=spar.offcenter["lr"]
					metabolites["#{met_name}"][counter["#{met_name}"]].offcenter_cc=spar.offcenter["cc"]
					metabolites["#{met_name}"][counter["#{met_name}"]].dist_voxel_coil=dist_voxel_to_coil
					#
					metabolites["#{met_name}"][counter["#{met_name}"]].par_fwhm_hz=spar.fwhm_water_1
					metabolites["#{met_name}"][counter["#{met_name}"]].par_fwhm_hz_2=spar.fwhm_water_2
					#mrsi 
					if fitinfo.mrsi_scan
						metabolites["#{met_name}"][counter["#{met_name}"]].slice=mrsi_slice
						metabolites["#{met_name}"][counter["#{met_name}"]].row=mrsi_voxel_row
						metabolites["#{met_name}"][counter["#{met_name}"]].col=mrsi_voxel_col
					end
					#misc
					if fitinfo.use_misc_info
						metabolites["#{met_name}"][counter["#{met_name}"]].fwhm_hz=fwhm_hz
						metabolites["#{met_name}"][counter["#{met_name}"]].fwhm_ppm=fwhm_ppm
						metabolites["#{met_name}"][counter["#{met_name}"]].snr=snr
						metabolites["#{met_name}"][counter["#{met_name}"]].data_shift=data_shift
						metabolites["#{met_name}"][counter["#{met_name}"]].zero_phase=zero_phase
						metabolites["#{met_name}"][counter["#{met_name}"]].first_phase=first_phase
							
					end
					#b1
					if !fitinfo.b1_raw_file.empty?
						metabolites["#{met_name}"][counter["#{met_name}"]].b1raw_per=b1_raw.percentage
						metabolites["#{met_name}"][counter["#{met_name}"]].b1raw_cf=b1_raw.cfactor
					end
					if !fitinfo.b1_rec_file.empty?
						metabolites["#{met_name}"][counter["#{met_name}"]].b1rec_max=b1_rec.max
						metabolites["#{met_name}"][counter["#{met_name}"]].b1rec_per=b1_rec.percentage
						metabolites["#{met_name}"][counter["#{met_name}"]].b1rec_cf=b1_rec.cfactor
					end
					#profile (and b1)
					if fitinfo.sim_profile
						metabolites["#{met_name}"][counter["#{met_name}"]].sim_mr_mxy=Float(profile.mr_mxy)
						metabolites["#{met_name}"][counter["#{met_name}"]].sim_abs_mxy=Float(profile.abs_mxy)
					end
					if fitinfo.phantom_profile
						metabolites["#{met_name}"][counter["#{met_name}"]].mxy_phantom=phantom_profile.mxy_phantom
					end
					if fitinfo.receive_sensitivity
						metabolites["#{met_name}"][counter["#{met_name}"]].receive=receive_sens.receive
						metabolites["#{met_name}"][counter["#{met_name}"]].receive_scaled=receive_sens.receive_scaled
						metabolites["#{met_name}"][counter["#{met_name}"]].receive_b1map=receive_sens.receive_b1map
						metabolites["#{met_name}"][counter["#{met_name}"]].receive_ratio=receive_sens.receive_ratio
					end
					#segmentation
					if fitinfo.segmentation
						metabolites["#{met_name}"][counter["#{met_name}"]].f_gm_vol=Float(segment_results.comp[3])
						metabolites["#{met_name}"][counter["#{met_name}"]].f_wm_vol=Float(segment_results.comp[4])
						metabolites["#{met_name}"][counter["#{met_name}"]].f_csf_vol=Float(segment_results.comp[5])
					end
					#drive scale
					if fitinfo.drive_scale
						metabolites["#{met_name}"][counter["#{met_name}"]].drive_scale=spar.drive_scale
						metabolites["#{met_name}"][counter["#{met_name}"]].one_over_drive=1/spar.drive_scale
					end
					#mrecon area only for eretic and water
					if fitinfo.mrecon_area
						metabolites["#{met_name}"][counter["#{met_name}"]].mrecon_w=spar.mrecon_area_w
						metabolites["#{met_name}"][counter["#{met_name}"]].mrecon_td_w=spar.mrecon_td_w_null
						metabolites["#{met_name}"][counter["#{met_name}"]].mrecon_e=spar.mrecon_area_e
					end
					#
					if fitinfo.calib_conc_eretic
						metabolites["#{met_name}"][counter["#{met_name}"]].eretic_normalized_calib_conc=info_calibration.eretic_calib_conc
					end
					if fitinfo.calib_conc_ds 
						metabolites["#{met_name}"][counter["#{met_name}"]].ds_normalized_calib_conc=info_calibration_ds.ds_calib_conc
						metabolites["#{met_name}"][counter["#{met_name}"]].ds_calib_averaged=info_calibration_ds.ds_calib_averaged
					end
					#
					if fitinfo.qbc_water_ds 
						metabolites["#{met_name}"][counter["#{met_name}"]].qbc_water_area=info_qbc.qbc_water_area
						metabolites["#{met_name}"][counter["#{met_name}"]].qbc_drive_scale=info_qbc.qbc_drive_scale
					end	
					#
					if fitinfo.sense_water_ds 
						metabolites["#{met_name}"][counter["#{met_name}"]].sense_water_area=info_sense.sense_water_area
						metabolites["#{met_name}"][counter["#{met_name}"]].sense_drive_scale=info_sense.sense_drive_scale
					end	
					#
					counter["#{met_name}"]=counter["#{met_name}"]+1
					
				end	
			end
		
		} 

		#file_to_read.close
	}
	#-------------------------------------------------------------------------------------------------------------------------------------
	if metabolites.has_key?("water")
		puts "Number of Metabolites including water: #{metabolites.size}"
	else
		puts "Number of Metabolites: #{metabolites.size}"
	end
	# information when tables were not useful, fitting failed-----------------------------------------------------------------------------
	if counter_bad_tables > 0
		puts "\n"
		puts "                         ATTENTION                                     "
		puts "\n"
	end
	puts "Number of tables empty: #{counter_bad_tables} of #{files.size}\n"
	puts "\n"
	#-------------------------------------------------------------------------------------------------------------------------------------
	#########################################################################
	# Specials
	#########################################################################
	nr_tables=files.size
	#
	#----------------------------------------------------------------------
	# Calculate Areas and Ratio to Area Water if possible
	#----------------------------------------------------------------------
	if metabolites.has_key?("water")
		metabolites.each_key{|meta| 
			for nr_meas in 0..(counter[meta]-1) #nr tables
				metabolites[meta][nr_meas].calculate_area(fitinfo,metabolites["water"][nr_meas].fcalib,debug)
			end
			}		 
	else
		metabolites.each_key{|meta| 
			for nr_meas in 0..(counter[meta]-1) #nr tables
				metabolites[meta][nr_meas].calculate_area(fitinfo,1,debug)
			end
		} 
	end
	#----------------------------------------------------------------------
	# Basis Norm == normalized_area_basis check
	#----------------------------------------------------------------------
	# When I used DS or ERETIC I read from the print file the *Normalized area of reference Basis singlet* 
	# and use this as the basisnorm, but I have seen situation when this value was not == calculated(basisnorm)
	# So I check this here
	if (fitinfo.drive_scale || fitinfo.calib_conc_eretic )
	  puts " Check if Normalized area of reference Basis singlet is equal to the calculated basisnorm "
	  # should be the same
	  # why arent they same, what happens if there is no water
		if metabolites.has_key?("water")
			for nr_meas in 0..(counter["water"]-1) #nr tables
				calculated_basis_norm=metabolites["water"][nr_meas].fcalib*(metabolites["water"][nr_meas].area/(2*55556*1))
				if !(calculated_basis_norm.round(7) == normalized_area_basis.round(7))
			        puts calculated_basis_norm.round(7)
					puts normalized_area_basis.round(7)
					#abort or use the calculated
					#-------------------------------------------
					#abort
					#-------------------------------------------
					normalized_area_basis=calculated_basis_norm
					#-------------------------------------------
					puts " -----------------------Warning--------------------------------------"
					puts " -----------------------Warning--------------------------------------"
					puts " normalized_area_basis changed used from now"
					normalized_area_basis_changed=true;
				end
			end
		end
	end
	#----------------------------------------------------------------------
	# Calculate uncorrected Eretic Ratio
	#----------------------------------------------------------------------
	if metabolites.has_key?("eretic")
		metabolites.each_key{|meta| 
			for nr_meas in 0..(counter[meta]-1) #nr tables
				metabolites[meta][nr_meas].simple_ratio_to_eretic(metabolites["eretic"][nr_meas].area)
			end
		} 
	end
	#----------------------------------------------------------------------
	# Calculate uncorrected Cre Ratio
	#----------------------------------------------------------------------
	if metabolites.has_key?("Cre")
		if metabolites.has_key?("PCr")
			puts "simple ratio to cre to cre and pcr"
			metabolites.each_key{|meta| 
				#puts meta
				for nr_meas in 0..(counter[meta]-1) #nr tables
					#puts nr_meas
					metabolites[meta][nr_meas].simple_ratio_to_cre(metabolites["Cre"][nr_meas].area+metabolites["PCr"][nr_meas].area)
				end
			}
		else
			puts "simple ratio to cre only to cre"
			metabolites.each_key{|meta| 
				#puts meta
				for nr_meas in 0..(counter[meta]-1) #nr tables
					#puts nr_meas
					metabolites[meta][nr_meas].simple_ratio_to_cre(metabolites["Cre"][nr_meas].area)
				end
			}
		
		end
	end
	#----------------------------------------------------------------------
	# Create Column Names
	#----------------------------------------------------------------------
	metabolites_info.each{|met|
		if !fitinfo.tabelle_andi
			met.create_column_names(fitinfo,metabolites.has_key?("water"),metabolites.has_key?("eretic"),metabolites.has_key?("Cre"))
		else
			#tabelle wie andi
			met.create_column_names_met(fitinfo,metabolites.has_key?("water"),metabolites.has_key?("eretic"),metabolites.has_key?("Cre"))
			met.create_column_names_general(fitinfo,metabolites.has_key?("water"),metabolites.has_key?("eretic"),metabolites.has_key?("Cre"))
		end
	}
	#----------------------------------------------------------------------
	# Concentration References
	#----------------------------------------------------------------------
	if !fitinfo.phantom
		#invivo Messung
		if fitinfo.segmentation
			# Soweit mache ich die ganzen Korrekturen nur, wenn Segmentierung vorhanden ist, könnte man auch ändern
			#--------------------------------------
			# segmetation and relax
			#
			# All Informations for all metabolites and measurements
			# are used 
			#--------------------------------------
			metabolites.each_key{|meta| 
				for nr_meas in 0..(counter[meta]-1) #nr tables
					# calculate the teilchen fraction f_mol from f_vol
					metabolites[meta][nr_meas].calculate_f_mol(fitinfo)
					# calculate realxation 
					metabolites[meta][nr_meas].calculate_relax(fitinfo)
				end	
			}
		
			#-------------------------------------------------------
			# water as reference
			#-------------------------------------------------------
			if metabolites.has_key?("water")
				puts " use of tissue water as concentration reference"
				metabolites.each_key{|meta| 
						for nr_meas in 0..(counter[meta]-1) #nr tables
							metabolites[meta][nr_meas].use_internal_water(fitinfo, metabolites["water"][nr_meas])
						end
					}
			end
			#-------------------------------------------------------
			# creatine as reference
			#-------------------------------------------------------
			if metabolites.has_key?("Cre")
			
				puts " use of Creatine as concentration reference"
				metabolites.each_key{|meta| 
						for nr_meas in 0..(counter[meta]-1) #nr tables
							metabolites[meta][nr_meas].use_internal_creatine(fitinfo,metabolites["Cre"][nr_meas] )
						end
					}
				
			end
			#-------------------------------------------------------
			# eretic as reference
			#-------------------------------------------------------
			if metabolites.has_key?("eretic") 
				if fitinfo.calib_conc_eretic
					puts " use of eretic as concentration reference"
					puts " calibrated "
					if normalized_area_basis_changed
						puts " normalized_area_basis changed, used a calculated one, check carefully!"
					end
					metabolites.each_key{|meta| 
						for nr_meas in 0..(counter[meta]-1) #nr tables
							metabolites[meta][nr_meas].use_eretic(fitinfo,metabolites["eretic"][nr_meas],normalized_area_basis )
						end
					}
				else
					puts " use of eretic as concentration reference"
					puts " not calibrated "
					metabolites.each_key{|meta| 
						for nr_meas in 0..(counter[meta]-1) #nr tables
							#change 1 to normalized_area_basis in the future?
							metabolites[meta][nr_meas].use_eretic(fitinfo,metabolites["eretic"][nr_meas],1 )
						end
					}
				end
				
			end
			#-------------------------------------------------------
			# drive scale as reference
			#-------------------------------------------------------
			if fitinfo.drive_scale 
				if 	fitinfo.calib_conc_ds && fitinfo.qbc_water_ds
						puts " use drive scale as concentration reference"
						puts " and qbc water because receive only coil is used "
						puts " calibrated "
						if normalized_area_basis_changed
						puts " normalized_area_basis changed, used a calculated one, check carefully!"
						end
						metabolites.each_key{|meta| 
							for nr_meas in 0..(counter[meta]-1) #nr tables
								metabolites[meta][nr_meas].use_ds_body_water(fitinfo,metabolites["water"][nr_meas],normalized_area_basis )
							end
						}
							
				end
				
				if fitinfo.calib_conc_ds && !(fitinfo.qbc_water_ds)
					puts " use of drive scale as concentration reference"
					puts " transmit/receive coil must be used "
					puts " calibrated "
					if normalized_area_basis_changed
						puts " normalized_area_basis changed, used a calculated one, check carefully!"
					end
					metabolites.each_key{|meta| 
						for nr_meas in 0..(counter[meta]-1) #nr tables
							metabolites[meta][nr_meas].use_ds(fitinfo,normalized_area_basis )
						end
					}
				end
				
				if !fitinfo.calib_conc_ds && fitinfo.qbc_water_ds
							puts "Calibration is needed"
							puts "Aborted"
							abort
				end
				if 	(!fitinfo.calib_conc_ds) && !(fitinfo.qbc_water_ds)
						puts " use of drive scale as concentration reference"
						puts " not calibrated "
						metabolites.each_key{|meta| 
							for nr_meas in 0..(counter[meta]-1) #nr tables
								metabolites[meta][nr_meas].use_ds(fitinfo,normalized_area_basis )
							end
						}
				end
				
			end
			# mrsi nie direkt mit ERETIC
			# 
			# if fitinfo.mrsi_scan
				# puts  " areas calculated to use for eretic"
				# metabolites.each_key{|meta| 
						# for nr_meas in 0..(counter[meta]-1) #nr tables
							# metabolites[meta][nr_meas].use_eretic(fitinfo,1 )
						# end
					# }
			# end
		end
	else
		# Phantom Messung
		#--------------------
		metabolites.each_key{|meta| 
			for nr_meas in 0..(counter[meta]-1) #nr tables
				metabolites[meta][nr_meas].calculate_relax(fitinfo)
			end

		}
		# ERETIC Calibration
		if metabolites.has_key?("eretic") 
			metabolites.each_key{|meta| 
				if (fitinfo.relax_times.has_key?(meta) )# meta.eql?("water") )
					puts "eretic calibration with #{meta}"
					if !meta.eql?("water")
						puts "  normalized"
						puts "  with normalized area from basis #{normalized_area_basis}"
						puts "  temperature correction applied 25 C * 0.9613"
					end
				
					for nr_meas in 0..(counter[meta]-1) #nr tables
						metabolites[meta][nr_meas].eretic_calibration(fitinfo,metabolites["eretic"][nr_meas],normalized_area_basis)
					end
				end			
			}
		end
		#
		# Drive Scale Calibration
		if fitinfo.drive_scale
			metabolites.each_key{|meta| 
				if (fitinfo.relax_times.has_key?(meta) || meta.eql?("water") )
					puts "drive scale calibration with #{meta}"
					for nr_meas in 0..(counter[meta]-1) #nr tables
						metabolites[meta][nr_meas].ds_calibration(fitinfo,normalized_area_basis)
					end
				end			
			}
		end
		
	
	end
	if generate_met_info
		#----------------------------------------------------------------------
		# Create Mean and Std
		#----------------------------------------------------------------------
		metabolites_info.each{|met|
			# Measurments of this metabolite with sd > 50
			meta_50=metabolites[met.name].find_all{|a| a.sd < 50}
			if !meta_50.empty? 
				#----------------------------
				area=meta_50.map{|m| m.area}
				met.info_area=[area.mean,area.standard_deviation,area.standard_deviation/area.mean, area.number]
				#----------------------------
				to_water=meta_50.map{|m| m.to_water}
				met.info_to_water=[to_water.mean,to_water.standard_deviation,to_water.standard_deviation/to_water.mean,to_water.number]
				#-----------------------------
				to_cre=meta_50.map{|m| m.to_cre}
				met.info_to_cre=[to_cre.mean,to_cre.standard_deviation,to_cre.standard_deviation/to_cre.mean,to_cre.number]
			end
			
			
		}
	end
	#----------------------------------------------------------------------------------------------
	################################################################################################
	#write conc file
	#including water
	################################################################################################
	#-------------------------------------------
	if !File.directory?("#{result_path}")
		#puts " folder created"
		Dir.mkdir("#{result_path}" )
	end
	#------------------------------------------
	if false
		# RinRuby Test	
		#----------------------------------------------------------------------
		# Create Mean and Std
		#----------------------------------------------------------------------
		# metabolites_info.each{|met|
			# # Measurments of this metabolite with sd > 50
			# meta_50=metabolites[met.name].find_all{|a| a.sd < 50}
			# if (!meta_50.empty? && met.name=="NAA+NAAG")
				# #puts met.name
				# #----------------------------
				# area=meta_50.map{|m| m.area}
				# #R.x = area
				# #R.eval "summary(x)"
				# #R.eval "sd(x)"
				# #----------------------------
				# aaa=meta_50.map{|m| m.to_water_corr}
				# R.x = aaa
				# bbb=meta_50.map{|m| m.c_bv_eretic}
				# R.y= bbb
				# #to_eretic=meta_50.map{|m| m.to_eretic}
				# #R.z= to_eretic
				# #c_bv_eretic=meta_50.map{|m| m.c_bv_eretic}
				# #R.w= c_bv_eretic
				# #
				# R.eval "pdf('#{result_path}/faithful_histogram.pdf')"
				# R.eval "boxplot(x,y)"
				# R.eval "t.test(x,y)"
			# end
			
			meta_50_eretic=metabolites["eretic"].find_all{|a| a.sd < 50}
			R.x = meta_50_eretic.map{|m| m.area}
			meta_50_water=metabolites["water"].find_all{|a| a.sd < 50}
			R.y = meta_50_water.map{|m| m.area}
			R.eval "fm <- lm(y~x)"
			R.eval "pdf('#{result_path}/faithful_histogram.pdf')"
			R.eval "plot(x,y)"
			R.eval "abline(fm, col='red')"
		#}
	end
	# different name for the different summmary files
	name_summary=frf.gsub("#{fitinfo.result_path}","")
	name_summary=name_summary.gsub("\/","\_")
	#
	# Not all Metabolites have to be printed
	#-----------------------------------------------------------------------------
	if !(fitinfo.print_metabolite.empty?)
		if !collect[0]
			puts "Only a selection of metabolites printed in the final table"
			metabolites_info=metabolites_info.find_all{|m| fitinfo.print_metabolite.include?(m.name)}
		else
			puts "Selection of metabolites ignored because of collect = true"
		end
	end
	# measure mean_sd for a good order
	#-----------------------------------------------------------------------------
	metabolites_info.each{|met|
				sd=metabolites[met.name].map{|m| m.sd}
				met.mean_sd=sd.mean
	}
	# metabolites sorted
	#-----------------------------------------------------------------------------
	# orignal
	met_info_sorted=metabolites_info.sort_by{|s| [s.mean_sd,s.name]} #s.name_scan,
	#met_info_sorted=metabolites_info.sort_by{|s| [s.name]} #s.name_scan,
	#------------------------------------------------------------------------------
	if collect[0]
	# wenn ich verschiedene auswertungen in einem sammle
	#------------------------------------------------------
		if !collect[2].nil?
			# fuer alle weiterenauswertungen wird die Ordnung der ersten Auswertung genommen
			met_info_sorted=collect[2]
			#puts met_info_sorted
		 else
			# mit der ersten Auswertung wird Ordnung festgeschrieben und dann fuer alle folgenden
			# Auswertungen beibehalten
			 collect[2]=met_info_sorted
			 #puts "test"
			 #puts met_info_sorted
		 end
	#---------------------------------------------------------
		if !File.exist?("#{result_path}" + "/conc_summary.csv")
			conc_file = File.new("#{result_path}" + "/conc_summary.csv", "w")
			conc_file.write "sep=;\n"
			conc_file.write "#{frf}\n"  
			conc_file.write "#{fitinfo.examination_name} \n"
		else
			conc_file=File.open("#{result_path}" + "/conc_summary.csv","a")
			conc_file.write "\n"
			conc_file.write "\n"		
			conc_file.write "#{frf}\n"  
			conc_file.write "#{fitinfo.examination_name} \n"
		end
	else
		# file
		# old
		# conc_file = File.new("#{result_path}" + "/#{fitinfo.examination_name}"+"_conc_summary.table", "w")
		# csv ------------------------------------------------------------------------------------------------
		output_csv_file_name="#{result_path}" + "/#{fitinfo.examination_name}"+"_conc_summary.csv"
		conc_file = File.new(output_csv_file_name, "w")
		conc_file.write "sep=;\n"
		#----------------------------------------------------------------------------------------------------
	end
	conc_file.write "Concentration Summary // #{Time.now.asctime}\n"
	conc_file.write "Metabolites with %SD greater than #{sd_limit}% ignored\n"
	#
	conc_file.write "Number of tables analyzed: #{files.size-counter_bad_tables} (empty) of #{files.size}\n"
	#
	if fitinfo.segmentation
		conc_file.write "Areas to water corrected with Volume Fractions\n"
	else
		conc_file.write "\n"
	end
	#
	conc_file.write "\n"
	# tradionelle tabelle
	if !fitinfo.tabelle_andi
		column_names=Array.new
		column_names_list=""
		
		met_info_sorted.each{ |met|
		
			if met.mean_sd <  sd_limit
				#
				metabolites_info.each{|meta|
							if meta.name.eql?("#{met.name}")
								column_names=meta.column_names
								column_names_list=meta.column_names.join(";")+"\n"
								break
							end
				}
				# here for every metabolites all the measurements get sorted
				# different for mrsi_scan and sv scan
				if fitinfo.mrsi_scan
					case fitinfo.mrsi_order
					when "normal"
						sorted_met=metabolites[met.name].sort_by{|s| [s.date_scan[2],s.date_scan[1],s.date_scan[0],s.nr_patient,s.nr_scan,s.row,s.col] }
					when "row_col"
						sorted_met=metabolites[met.name].sort_by{|s| [s.row,s.col,s.nr_patient,s.nr_scan] }
					else
						puts "ERROR: Unknown sort method"
						sorted_met=metabolites[met.name]
					end
				else
					# orig
					sorted_met=metabolites[met.name].sort_by{|s| [s.date_scan[2],s.date_scan[1],s.date_scan[0],s.nr_patient,s.nr_scan]}
				end
				#
				conc_file.write "Concentration of #{met.name}\n"		#seperate eretic depend on this order Concentration / columns
				conc_file.write "#{column_names_list}"
				#		
				sorted_met.each_index{ |nr|
					# original
					sorted_met[nr].write_to_file_table_one(conc_file,column_names)
				}
			end
		}
	else
		#--------------neue variante tabelle -------------------------------------- #
		sorted_met=Array.new
		column_names=Array.new
		column_names_list=""
		column_met_names=""
		#--------------------------
		met_info_sorted.each{ |met|
			if met.mean_sd <  sd_limit
				#
				metabolites_info.each{|meta|
					if meta.name.eql?("#{met.name}")
						if column_names.count == 0
									column_names[column_names.count]=meta.column_names_general+meta.column_names_met
									# metabolite name is added to the column_names in the column_names_list
									column_names_list=column_names_list+meta.column_names_general.join(";")+";"+meta.column_names_met.join(" #{met.name}"+";")+" #{met.name}"+";"
									column_met_names=column_met_names+";"*meta.column_names_general.size+met.name+";"+";"*(meta.column_names_met.size-1)
						else
									column_names[column_names.count]=meta.column_names_met
									# metabolite name is added to the column_names in the column_names_list
									column_names_list=column_names_list+meta.column_names_met.join(" #{met.name}"+";")+" #{met.name}"+";"
									column_met_names=column_met_names+met.name+";"+";"*(meta.column_names_met.size-1)
						end
					end
				}
				# here for every metabolites all the measurements get sorted
				# different for mrsi_scan and sv scan
				if fitinfo.mrsi_scan
					case fitinfo.mrsi_order
					when "normal"
						sorted_met[sorted_met.count]=metabolites[met.name].sort_by{|s| [s.date_scan[2],s.date_scan[1],s.date_scan[0],s.nr_patient,s.nr_scan,s.row,s.col] }
					when "row_col"
						sorted_met[sorted_met.count]=metabolites[met.name].sort_by{|s| [s.row,s.col,s.nr_patient,s.nr_scan] }
					else
						puts "ERROR: Unknown sort method"
						sorted_met[sorted_met.count]=metabolites[met.name]
					end
				else
					#sorted_met[sorted_met.count]=metabolites[met.name].sort_by{|s| [s.date_scan[2],s.date_scan[1],s.date_scan[0],s.nr_patient,s.nr_scan]}
					sorted_met[sorted_met.count]=metabolites[met.name].sort_by{|s| [s.position,s.date_scan[2],s.date_scan[1],s.date_scan[0],s.nr_patient,s.nr_scan]}
				end	

			end
		}
		# name list
		conc_file.write "#{column_met_names} \n"
		# list of column names
		conc_file.write "#{column_names_list} \n"
		for ii in 0..(sorted_met[0].size-1)
			sorted_met.each_index{ |nr|
				#puts "#{sorted_met[nr][ii].met} is #{nr} from #{sorted_met.size-1} Metabolites, scan #{ii} from total #{sorted_met[0].size-1} scans"
				sorted_met[nr][ii].write_to_file_table_two(conc_file,column_names[nr])
					 
			}
			conc_file.write "\n"
		end
	end
	#--------------neue variante tabelle ende -------------------------------------- #
	conc_file.close
	# create trunc file mainly to use in R
	# nur wenn keine collect
	if !collect[0]

				
				# write info to spar of the acual scan 
				# first make copy to make it work
				csv_input=output_csv_file_name
				csv_copy="#{result_path}" + "/#{fitinfo.examination_name}"+"_conc_summary_trunc.csv"
				line_nr=0
				File.open(csv_copy, "w") do |out_file|
					File.foreach(csv_input) {|line|
					    line_nr=line_nr+1
					    #puts line_nr
						if line_nr > 7 							
							out_file.puts line 
						end
					}

				end

	end
	
	
	if generate_met_info
		#--------------neuer output -------------------------------------- #
		# sehr unallgemein achtung
		if collect[0]
			if !File.exist?("#{result_path}" + "/met_info_summary.csv")
				met_info_file = File.new("#{result_path}" + "/met_info_summary.csv", "w")
				met_info_file.write "sep=;\n"
				#met_info_file.write "#{frf}\n"  
				#met_info_file.write "#{fitinfo.examination_name} \n"
			else
				met_info_file=File.open("#{result_path}" + "/met_info_summary.csv","a")
				#met_info_file.write "\n"
				#met_info_file.write "\n"		
				#met_info_file.write "#{frf}\n"  
				#met_info_file.write "#{fitinfo.examination_name} \n"
			end
		else
			# csv ------------------------------------------------------------------------------------------------
			met_info_file = File.new("#{result_path}" + "/#{fitinfo.examination_name}"+"_met_info_summary.csv", "w")
			met_info_file.write "sep=;\n"
			#----------------------------------------------------------------------------------------------------
		end
		# some info --------------------------------
		region=fitinfo.examination_name.match(/^\w*/)
		fit= frf.match(/\/(\w*)\/$/)
		#--------------------------------------------
		met_info_sorted.each{ |met|
			#puts met.name
			met_info_file.write fit[1]+";"
			met_info_file.write region[0]+";"
			met_info_file.write "#{met.name};"
			met_info_file.write "#{met.info_to_cre.join(";")}"+";"
			}
		met_info_file.write "\n"	
		met_info_file.close
	end
}
end

