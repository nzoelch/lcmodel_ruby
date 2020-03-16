require 'find'
require './Spar'
require './FiTinfo'
require './Fitted_Files'
require 'fileutils'
require 'net/ssh'
require 'net/sftp'

def lcm_fit(auswertung,fix_settings,debug)
#---------------------------------------------------------
#**************************************************************************************************
# PRESET
# Don't edit here normally deduced from fitinfo
#**************************************************************************************************
#-------------------------------------------------------------------------------------------------
fitinfo = FiTinfo.new("#{auswertung}/FiTinfo.txt", auswertung)
# Info about previous fitted files
fitted_files=false
if File.exist?("#{auswertung}/Fitted_Files.txt")
	fitted_files_exist=true
	previous_fitted = Fitted_Files.new("#{auswertung}/Fitted_Files.txt")
end
#----------------------------------------------------------------
#--------------------------------------------------------------------------------------------------
# delete what
#-------------------------------------------------------------------------------------------------
filesdb = Hash.new
case fitinfo.delete 
	when "all"
		# everything is deleted
		FileUtils.rm_rf(Dir.glob("#{fitinfo.result_path}*"))
	when "changed"
		# delete the folders where someting is changed
		fitinfo.basis_sets.each { |basis_set|
			fitinfo.references.each_key{ |ref|		
				FileUtils.rm_r(Dir.glob("#{fitinfo.result_path}#{File.basename(basis_set, ".basis")}/#{ref}/*"))
			}
		}
	when "none"
		# nothing is deleted and previous fitted files are not fitted again
		if fitted_files_exist
			#previous_fitted = Fitted_Files.new("#{auswertung}/Fitted_Files.txt")
			#
			puts "WARNING: #{previous_fitted.files.count} Previous fitted files not deleted  "
			puts "\n"
			previous_fitted.files.each{ |fi|
			puts fi
			}
			puts "\n"
			puts "It is not secured by the programm that the previous fitted files and the now fitted files are fitted with the same LCModel Parameters \n"
			puts "Check and choose carefully"
		else
			puts "No previous_fitted"
		end
		
	else
		puts "Wrong Option chosen for fitinfo.delete"
end
#--------------------------------------------------------------------------------------------------
# search_pattern
#--------------------------------------------------------------------------------------------------
search_pattern=Hash.new
fitinfo.search_pattern.each_key{|such|
	search_pattern[such] = Regexp.new(/(?i:#{fitinfo.search_pattern[such]})/)
}
search_pattern["act"]=Regexp.new(/(?i:#{fitinfo.name_act})/) # only search for actuall scan
#--------------------------------------------------------------------------------------------------
# Possible output files from LCModel
output_files=Hash.new
possible_files=Array.new
possible_files[0]="table"
possible_files[1]="csv"
possible_files[2]="ps"
possible_files[3]="print"
possible_files[4]="coord"
possible_files[5]="coraw"
#--------------------------------------------------------------------------------------------------
#where to find bin2raw on BLI-PC17-0031
bin2raw_path='~/.lcmodel/philips/bin2raw'
# **************************************************************************************************
#puts "*********************************************"
#puts " START main procedure"
#puts "*********************************************"
# *************************************************************************************************** 
# create file database
# fitinfo.folders contains all folder in which it should be search for files
total_nr_of_files=0
fitinfo.folders.each_index { |key|
	
	files = Dir.glob("#{fitinfo.folders[key]}*")
	if debug
		puts files
	end
	search_pattern.each_key{ |criteria|			
	files = files.grep(search_pattern[criteria])
	if debug 
			puts "For search criteria: #{criteria} \n"
			puts "This files have been found: \n"
			puts "*****************************"
			puts files
	end
	}
	#
	if !(fitinfo.exclude_pattern.empty?)
		fitinfo.exclude_pattern.each{ |exclude|
			files = files-files.grep(/(?i:#{exclude})/)
		}
	end
		
	#
	# when fitinfo.delete is none and there is a Fitted_Files.txt file
	# only those files from the found files (files) are taken, which are not in listed in the Fitted_Files.txt
	if fitted_files_exist and fitinfo.delete.eql?"none"
		previous_fitted.files.each{ |pre_fit_file|
			files = files.select{ |ff| 
			  !ff.eql?"#{pre_fit_file}"
			  }
		}
	end	
	
	if !(files.empty?)
		if !(filesdb.has_key?(key))
			filesdb[key] = Array.new
		end	
		filesdb[key].concat(files)
		total_nr_of_files=total_nr_of_files+filesdb[key].length
		#puts  filesdb[key]
	else
	puts "WARNING: No matching file in folder #{fitinfo.folders[key]} "
	puts "WARNING: Problem may be fitinfo.delete: #{fitinfo.delete}"
	end
}
if total_nr_of_files==0
	puts "ERROR: No matching file for this auswertung"
	return error=true
end
# Write the files that are evaluated into a file
# Not used here but in nz_lcm_table_read
fitted_files= File.new("#{auswertung}/Fitted_Files.txt", "w")
# start writing
# previous fitted 
#if File.exist?("#{auswertung}/Fitted_Files.txt") and fitinfo.delete.eql?"none"
if fitted_files_exist and fitinfo.delete.eql?"none"
	fitted_files.write "# Previous Fitted Files "+"\r\n"
	previous_fitted.files.each{ |pre_fit_file|
			fitted_files.write "#{pre_fit_file}" + "\r\n"
			
	}
end
#now fitted
fitted_files.write "# Now Fitted Files " + "#{Time.now}"+"\r\n"
filesdb.each_key { |folder|
	filesdb[folder].each { |file|
		fitted_files.write file + "\r\n"
	}
}
fitted_files.write "# END\n"
fitted_files.close()
#
#
file_counter=0
#
filesdb.each_key { |folder|
	filesdb[folder].each { |file|
	
		if File.file?(file)
		#
		file_counter=file_counter+1
		#
		puts file
		# 
		sdat_file 		= File.basename(file)	
		sdat_base		= File.basename(file, "#{File.extname(sdat_file)}")
		# check on .sdat
		if File.extname(sdat_file).eql?".SDAT"			# Capital lettre
			spar_suffix= ".SPAR"
		else
			spar_suffix= ".spar"
		end
		# Output		
		table_file 		= sdat_base + ".table"
		csv_file		= sdat_base + ".csv"
		ps_file			= sdat_base + ".ps"
		print_file		= sdat_base + ".print"
		coord_file		= sdat_base + ".coord"
		coraw_file		= sdat_base + ".coraw"
		#		
		save_path 		= File.dirname(file)
		current_fit_path	= fix_settings["cfp"]
		transfer_path		= fix_settings["tp"]
		# part 1 for log in terminal
		#-------------------------------------------------------------------------------------------------------
		puts "#{file_counter} of #{total_nr_of_files} *********************************************************"
		puts "fitting #{File.basename(file)} " 					##{Time.now}		
		#-------------------------------------------------------------------------------------------------------
		# unsupressed water file if available 			
		ref_file=Hash.new		
		#---------------------------------------------------------
		#------------------------------------------------------------------
		# derive additional information from the folder name
		#------------------------------------------------------------------
		# initial used on the table read part
		if !fitinfo.add_info.empty?
			if debug
				puts "additional information derived from the datapath"
			end
			fitinfo.add_info.each{|key, value| 
			# needed to change that from sdat file to save path
			# don't know why 2017
			search_that=save_path+sdat_file
			if match_nr=search_that.match(/#{value}/)
				puts "#{key} is #{match_nr[1]}" 
				fitinfo.add_info_result[key]=match_nr[1]	
			else
				puts "#{key} with #{value} is not found" 
			end
			}
		end
		#--------------------------------------------------------------------
		if fitinfo.search_ref_scan
			# special for ERETIC 2014
			# diese suche sollte in zukunft mit fitinfo.add_info vereinfacht werden
			# und vor allem im fitinfo geregelt sein und nicht wie hier im file selber
			#------------------------
			act_scan_nr=0
			position=''
			if match=sdat_file.match(/_(\d*)_1_\w*press_yneretic_(\w{1})/)
				act_scan_nr=match[1].to_i
				pos=match[2]
				position = case pos
				when "m" then "mitte"
				when "l" then "links"
				when "r" then "rechts"
				else
				"unknown"
				end
			end
			#Special
			if match=sdat_file.match(/_(\d*)_1_\w*press_s8_auto_(\w{1,2})(_|V)/)
				act_scan_nr=match[1].to_i
				pos=match[2]
				position = case pos
				when "m" then "mitte"
				when "l" then "links"
				when "r" then "rechts"
				when "lo" then "lo"
				else
				"unknown"
				end
			end
			#puts "#{fitinfo.name_ref}"
			# ------------------------------------------------------
			if fitinfo.name_ref.include? "fitinfo.add_info_result"
			        search_for=eval(fitinfo.name_ref)
					puts search_for
					search_ref=Regexp.new(/(?i:#{search_for})/)
				else
					search_ref=Regexp.new(/(?i:#{fitinfo.name_ref})/)
			end
			# ------------------------------------------------------
			# suche nach pos special EF 2014
			search_pos=Regexp.new(/(?i:#{position})/)
			search_pattern["sdat"]
			# alle in diesem ordner
			reference_files = Dir.glob("#{save_path}/*")
			reference_files=reference_files.grep(search_ref)
			#puts "found files"
			#puts reference_files
			reference_files=reference_files.grep(search_pos)
			reference_file=reference_files.grep(search_pattern["sdat"])
			puts "Fitted with the Reference File: "
			#puts reference_file
			if reference_file.count==1
				puts "  #{reference_file[0]}"
				ref_file["sdat"]= reference_file[0]
			else
				# give it another try!
				search_nr=Regexp.new(/(?i:_#{act_scan_nr+1}_1_)/)
				reference_file=reference_file.grep(search_nr)
					
				if reference_file.count==1
					puts "  #{reference_file[0]}"
					ref_file["sdat"]= reference_file[0]
				else
					
					puts "  Reference File not found "
					puts "  Fitting aborted "
					abort
				end
					
			end
		else
			# NORMALER FALL
			ref_file["sdat"]=file.gsub("#{fitinfo.name_act}","#{fitinfo.name_ref}")
		end
		ref_file["exist"]=File.exist?(ref_file["sdat"])
		# added to check ob gross oder klein geschrieben
		match_sdat=ref_file["sdat"].match(/(?i:\.sdat$)/)
		
		if match_sdat
			if match_sdat[0] =~ /[A-Z]/
				puts "sdat gross geschrieben"
				ref_file["spar"]=ref_file["sdat"].gsub(/(?i:\.sdat$)/,".SPAR")
			else
				puts "sdat klein geschrieben"
				ref_file["spar"]=ref_file["sdat"].gsub(/(?i:\.sdat$)/,".spar")
			end
		else
			# zur sicherheit wie es vorher war
			ref_file["spar"]=ref_file["sdat"].gsub(/(?i:\.sdat$)/,"#{spar_suffix}")
		end
		if debug
			if ref_file["exist"]
				puts " Water unsuppressed file found #{ref_file["sdat"]}"
			end
		end
		#----------------------------------------------------------
		# get information from ref file spar
		#----------------------------------------------------------
		# added 2019 to allow copy of the gussew information stored in the ref file
		# potentially also interesting for other applications
		if !fitinfo.get_ref_info.empty?
			
			case fitinfo.get_ref_info
			
			when "gussew"
				puts "Get info from ref Gussew file"
				# get the information from the ref spar file
				spar_ref = Spar.new(ref_file["spar"])
				
				# write info to spar of the acual scan 
				# first make copy to make it work
				spar_input="#{save_path}/#{sdat_base}"+"#{spar_suffix}"
				spar_copy="#{save_path}/copy"+"#{spar_suffix}"
				
				File.open(spar_copy, "w") do |out_file|
					File.foreach(spar_input) {|line|
						if line.chomp ==  "! Water Reference Information"
						 break
						else					
							out_file.puts line 
						end
					}
					# extra line
					out_file.puts ""
				end
				# add the information to the copy
				File.open(spar_copy, "a") {|f|
					f.puts "! Water Reference Information"
					f.puts ""
					f.puts "water_tr : #{spar_ref.tr}"
					f.puts ""
					f.puts "a_water : #{spar_ref.a_water}"
					f.puts ""
					f.puts "a_water_ratio : #{spar_ref.a_water_ratio}"
					f.puts ""
					f.puts "t2_water : #{spar_ref.t2_water}"
					f.puts ""
				}
				FileUtils.mv(spar_copy, spar_input)
			else
				puts "Error: wrong option get_ref_info #{fitinfo.get_ref_info}"  
			end
		end
		#
		if debug
			puts "Nummber of Basis Sets : #{fitinfo.basis_sets.length}"
		end
		#----------------------------------------------------------
		fitinfo.basis_sets.each { |basis_set|
			# part 2 for log in terminal
			puts "basis #{File.basename(basis_set)}"
			fitinfo.references.each_key{ |ref|
			# part 3 for log in terminal
			puts "ref #{ref}"
			# water measurement
			# 
			if fitinfo.water_measurement
				puts "Water Measurement fitting faked"
				fit_result_path = fitinfo.result_path+"#{fitinfo.basis_sets.index(basis_set)}"+"/"+ref
					if !File.exists?(fit_result_path)
						FileUtils.mkpath(fit_result_path)
					end
				tablefile = File.new("#{fit_result_path}" + "/" + sdat_base + ".table", "w")
				tablefile.write "$$CONC 2 lines in following concentration table = NCONC+1\n"
				tablefile.write "Conc.  %SD   /Cre   Metabolite\n"
				#tablefile.write "1  0   0   fake\n"
				tablefile.close()
			else
			#
			# clean content of transfer_dir and subfolder folder but leaving
			# subfolder names untouched 			
			if !File.directory?("#{transfer_path}")
				FileUtils.mkdir_p("#{transfer_path}/met") # creates all the folder (also parent) if needed 
			else
				FileUtils.rm_r(Dir.glob("#{transfer_path}/*"))
				FileUtils.mkdir_p("#{transfer_path}/met")
			end
			if ref_file["exist"]
				FileUtils.mkdir("#{transfer_path}/h2o")				
			end			
			
			# copying current basis set file to transfer folder
			if debug			
			puts "LOCAL"			
			puts "\tCopying basis set file to transfer folder..."
			end
			FileUtils.cp("#{basis_set}" , "#{transfer_path}/")

			# copy files to be fitted to transfer folder
			if debug			
			puts "\tCopying sdat and spar file to transfer folder..."	
			end		
			FileUtils.cp(file, "#{transfer_path}/")
			FileUtils.cp("#{save_path}/#{sdat_base}"+"#{spar_suffix}", "#{transfer_path}/")
			
			# copy ref file to transfer folder and bin2raw it, if it exist
			if ref_file["exist"]
				 FileUtils.cp(ref_file["sdat"], "#{transfer_path}/")
				 FileUtils.cp(ref_file["spar"], "#{transfer_path}/")
			end
		        
			spar = Spar.new(file.gsub("#{File.extname(sdat_file)}","#{spar_suffix}"))	# war vorher aussheralb for if
			#title = "Title #{spar.exam_date}, TE/TR/NSA: #{(spar.te*100.0).round/100.0}/#{spar.tr.round}/#{spar.nsa}"
			#title = "Title #{spar.exam_date}, #{spar.scan_id} TE/TR/NSA: #{(spar.te*100.0).round/100.0}/#{spar.tr.round}/#{spar.nsa} Size AP/RL/CC #{spar.voi_size["ap"]}/#{spar.voi_size["lr"]}/#{spar.voi_size["cc"]}  "
			# simple title
			title = sdat_base
			# spar.voi_size["ap"], spar.voi_size["lr"], spar.voi_size["cc"]
			
			# spar check
			if spar.f0 == 0 || spar.pts == 0 || spar.te == 0 || spar.bw == 0
				puts "spar check"
				puts "  One of the needed entries for the LCModel control file are not present"
				puts "	This fit will fail"
			end
			
			#
			output_files.clear
			# check which of the possible output files (pofile) are demanded in the control parameters
			# and create the necessary path in output_files
			possible_files.each{ |pofile|
				fitinfo.references[ref].each{ |line|
					if line.match(/(#{pofile})/)
						output_files[pofile]=" fil"+"#{pofile[0..2]}"+"= "+"'#{current_fit_path}/"+"#{sdat_base}" + "."+"#{pofile}"+"'\n"
						break
					end
				}
			}

			# write control file with fitting parameters
			if debug
			puts "\tWriting control file..."
			end
			controlfile = File.new("#{transfer_path}" + "/" + sdat_base + ".control", "w")
			# start writing
			controlfile.write " $LCMODL\n"
			fitinfo.references[ref].each{ |control_parameter|
				controlfile.write control_parameter + "\n"
			}
			controlfile.write " title= '#{title}'\n"
			controlfile.write " nunfil= #{spar.pts}\n"
			controlfile.write " hzpppm= #{sprintf("%.5e", spar.f0 / 1.0e6)}\n"
			controlfile.write " filtab= '#{current_fit_path}/#{table_file}'\n"
			if ref_file["exist"]
				controlfile.write " filh2o= '#{current_fit_path}/h2o/RAW'\n"
			end
			controlfile.write " filraw= '#{current_fit_path}/met/RAW'\n"
			# all
			output_files.each_value{ |output_file_end|
				if debug
				puts "line_command"+"#{output_file_end}"
				end
				controlfile.write output_file_end
			}
			controlfile.write " filbas= '#{current_fit_path}/"+File.basename(basis_set)+"'\n"
			controlfile.write " echot= #{spar.te}\n"
			controlfile.write " deltat= #{sprintf("%.5e", 1.0/spar.bw)}\n"
			controlfile.write " $END\n"
			controlfile.close()

			# transfer the created files to linux machine (chap02 or wherever you have the licence) -> run lcmodel and download the results again
			#
			Net::SSH.start(fix_settings["linux_name"], "#{fix_settings["user"]}", password: "#{fix_settings["password"]}") do |ssh|
				ssh.sftp.connect! { |sftp|

					# clean remote location
					if debug
					puts "REMOTE"
					puts "\tCleaning remote location..."
					#result = ssh.exec!("ls -l")
					#puts result
					end
					ssh.exec!("rm -r #{current_fit_path}")
					#
					ssh.exec!("mkdir #{current_fit_path}")
					#ssh.exec!("mkdir -p #{current_fit_path}/met")
					#
					# put all transfer_folder for lcmodel to chap02
					if debug
					puts "\tCopying files to remote location..."
					end
					# there is a problem with net_sftp version higher than 2.05
					# with this upload -> check later
					sftp.upload!("#{transfer_path}", "#{current_fit_path}" )
					#
					if debug
					result = ssh.exec!("ls -l #{current_fit_path}/")
					puts result
					end
					if debug			
						puts("\tExecute bin2raw met on remote machine ")
						#puts "#{bin2raw_path}"
					end
					cmd_met = "#{bin2raw_path} #{current_fit_path}/#{sdat_file} #{current_fit_path}/  met > #{current_fit_path}/met/bin2raw.log"
					puts cmd_met
					ssh.exec!(cmd_met)	
					if ref_file["exist"]
				
						if debug				
							puts("\tExecute bin2raw h2o on remote machine")
						end
						cmd_h2o = "#{bin2raw_path} #{current_fit_path}/#{File.basename(ref_file["sdat"])} #{current_fit_path}/ h2o > #{current_fit_path}/h2o/bin2raw.log"
						#puts cmd_h2o
						ssh.exec!(cmd_h2o)	
					end					
					
					# LCModel ausfuerhren
					if debug			
					puts("\tExecute LCModel...")
					end
					ssh.exec!("~/.lcmodel/bin/lcmodel < #{current_fit_path}/#{sdat_base}.control &> #{current_fit_path}/lcmodel_fit.log")
					if debug
					puts("\tdone")
					end
					# prepare local folder to save result files
					# old changed to keep the path short for the ps2pdf
					# fit_result_path = fitinfo.result_path+File.basename(basis_set, ".basis")+"/"+ref
					# if you change here also change in tableread
					fit_result_path = fitinfo.result_path+"#{fitinfo.basis_sets.index(basis_set)}"+"/"+ref
					if !File.exists?(fit_result_path)
						FileUtils.mkpath(fit_result_path)
					end
					# neu fuer puk ps2pdf auf dem lcmodel rechner
					ps_files = ssh.exec!("find #{current_fit_path} -regex '.*\.\\(ps\\)$'")
					# das ist ein string der mehrere enthalten kann
					# 
					ps_files_sp=ps_files.split
					#
					ps_files_sp.each do |hpsfile|
						hpsfile=hpsfile.chomp
						#
						cmd_to_pdf= "ps2pdfwr "+"#{hpsfile}"+" #{current_fit_path}"+"/"+File.basename(hpsfile,".ps")+".pdf"
						if debug
							puts cmd_to_pdf
							puts "#{hpsfile}"
						end
						ssh.exec!("#{cmd_to_pdf}")
					end
					
					# neu
					# get resulting files from server
					# the double back slashes are just needed within ruby. in the regular bash you would just use single ones
					result_files = ssh.exec!("find #{current_fit_path} -regex '.*\.\\(ps\\|pdf\\|csv\\|coraw\\|print\\|table\\|coord\\|control\\)$'")
					if debug
					puts "\tCopying files from remote location to fit_results folder..."
					end
					result_files.each_line { |downfile|
						downfile = downfile.chomp
						sftp.download!(downfile, "#{fit_result_path}/"+File.basename(downfile))
						if debug
								puts "\tDownloaded file #{downfile} from remote location to fit_results folder..."
						end
					}
				}
			end
			end
		}# ref loop
        
		}# basis set loop
		puts "***************************************************************"
		
	end	
	}
}
return error=false
end



