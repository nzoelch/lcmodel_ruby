class FiTinfo
	
	attr_reader :examination_name,\
				:name_act,\
				:name_ref,\
				:search_ref_scan,\
				:get_ref_info,\
				:search_pattern,\
				:exclude_pattern,\
				:folders,\
				:basis_sets,\
				:auswertung_folder,\
				:result_path,\
				:delete,\
				:dyn_series,\
				:mrsi_scan,\
				:mrsi_order,\
				#
				:use_misc_info,\
				#
				:tabelle_andi,\
				#
				:b1map,\
				:b1_raw_file,\
				:b1_rec_file,\
				#
				:receive_sensitivity,\
				:receive_file,\
				#
				:use_distance,\
				:distance_file,\
				#
				:sim_profile,\
				:sim_profile_file,\
				:phantom_profile,\
				:phantom_profile_file,\
				#
				:patient_search,\
				:add_info,\
				:add_info_result,\
				# 
				:print_metabolite,\
				#
				:phantom,\
				#
				:mrecon_area,\
				#
				:seperate_eretic,\
				:seperate_folder,\
				#
				:water_measurement,\
				#
				:special_concentrations,\
				#
				:drive_scale,\
				#
				:calib_conc_eretic,\
				:calib_conc_folder,\
				:calib_conc_met,\
				#
				:calib_conc_ds,\
				:calib_conc_ds_folder,\
				:calib_conc_ds_met,\
				:calib_conc_voxel,\
				#
				:qbc_water_ds,\
				:qbc_water_folder,\
				:qbc_search_string,\
				# 
				:sense_water_ds,\
				:sense_water_folder,\
				:sense_search_string,\
				#
				:calib_average,\
				#
				:segmentation,\
				:segment_folder2split,\
				:segment_file,\
				:segment_search,\
				:given_segm,\
				#
				:alpha,\
				:relax_times,\
				:ref_conc,\
				:references,\
				#
				:read_in_relax,\
				:relax_file,\
				:relax_search

	def initialize(filename, auswertung)	
		@search_pattern		= Hash.new
		@exclude_pattern	= Array.new
		@print_metabolite	= Array.new
		@folders		= Array.new
		@basis_sets		= Array.new
		@references             = Hash.new
		@auswertung_folder	= auswertung
		@dyn_series 	= false
		@mrsi_scan		= false
		@mrsi_order		= "normal"
		@search_ref_scan=false;
		@get_ref_info = ""
		@use_misc_info	= false
		@tabelle_andi	= false
		@b1map			= false
		@b1_raw_file	= ""
		@b1_rec_file	= ""
		@receive_sensitivity= false
		@receive_file	= ""
		@use_distance= false
		@distance_file= ''
		@sim_profile	= false
		@sim_profile_file= ""
		@phantom_profile = false
		@phantom_profile_file= ""
		@patient_search= ""
		@add_info    	= Hash.new
		@add_info_result = Hash.new
		@phantom        = false
		@mrecon_area    = false
		@seperate_eretic= false
		@seperate_folder= ""
		@water_measurement= false
		@drive_scale	= false
		@calib_conc_eretic= false
		@calib_conc_folder  = ""
		@calib_conc_met  = ""
		#
		@special_concentrations=false
		#
		@calib_conc_ds= false
		@calib_conc_ds_folder  = ""
		@calib_conc_ds_met  = ""
		@calib_average  = false
		@calib_conc_voxel= Array.new(3)
		#
		@qbc_water_ds= false
		@qbc_water_folder=""
		@qbc_search_string=""
		#
		@sense_water_ds= false
		@sense_water_folder=""
		@sense_search_string=""
		#
		@segmentation 	= false
		@segment_folder2split=""
		@segment_file   = ""
		@segment_search   = ""
		@given_segm   = ""
		@relax_times    = Hash.new
		@ref_conc    	= Hash.new
		@alpha		 = Array.new(3)
		folder_counter          = 0
		basis_sets_counter	= 0		
		ref_name        	= Array.new
		#
		@read_in_relax = false
		@relax_file=''
		@relax_search=''
		#
		file_to_read = File.new(filename,"r")
		file_content=file_to_read.readlines
		file_to_read.close
		#
		file_content.each_index{|line_nr|
			line=file_content[line_nr]			  	
			case line.chomp!
				when /^examination_name/
		  			@examination_name		= get_text(line, 's')
		  		when /^name_act_scan/
		  			@name_act			= get_text(line, 's')
		  		when /^name_ref_scan/
		  			@name_ref			= get_text(line, 's')
				when /^search_ref_scan/
		  			@search_ref_scan = get_text(line, 'b')
				when /^get_ref_info/
		  			@get_ref_info			= get_text(line, 's')
		  		when /^search_pattern/
		  			@search_pattern[line[15..18]] 	= get_text(line, 's')
				when /^exclude_pattern/
		  			@exclude_pattern[exclude_pattern.count] 	= get_text(line, 's')
				when /^print_metabolite/
		  			@print_metabolite[print_metabolite.count] 	= get_text(line, 's')
				when /^folder/
					@folders[folder_counter]	= get_text(line, 's')
					folder_counter+=1
				when /^basis_set/
					if File.exists?("#{@auswertung_folder}/LCModel_Basis/#{get_text(line, 's')}"+".basis")							
						@basis_sets[basis_sets_counter]	= "#{@auswertung_folder}/LCModel_Basis/#{get_text(line, 's')}"+".basis"
						basis_sets_counter+=1
					else
						puts "#{get_text(line, 's')}"+".basis"+" not found!" 
					end
				when /^ref_conc/
					met_name= line.split(' : ')[1]
					@ref_conc[met_name]=line.split(' : ')[2].to_f
				when /^relax/
					met_name= line.split(' : ')[1]
					@relax_times[met_name]=Hash.new
					get_relax(file_content[line_nr+1..file_content.length],met_name)	
				when /^reference/
					ref_name = line.split(' : ')[1]
					@references[ref_name]=Array.new
					# the content from the file form line_nr+1 to the end is given to get_reference						
					get_reference(file_content[line_nr+1..file_content.length],ref_name)
				when /^result_path/
					@result_path=auswertung+get_text(line, 's')
				when /^delete/			
					@delete=get_text(line, 's')	
				when /^dyn_series/			
					@dyn_series=get_text(line, 'b')	
				when /^mrsi_scan/			
					@mrsi_scan=get_text(line, 'b')
				when /^mrsi_order/			
					@mrsi_order=get_text(line, 's')
				when /^use_misc_info/
					@use_misc_info=get_text(line, 'b')
				when /^tabelle_andi/
					@tabelle_andi=get_text(line, 'b')
				when /^b1map/
					@b1map=get_text(line, 'b')
				when /^b1_raw_file/
					@b1_raw_file= get_text(line, 's')
				when /^b1_rec_file/
					@b1_rec_file= get_text(line, 's')
				when /^receive_sensitivity/
					@receive_sensitivity=get_text(line, 'b')
				when /^receive_file/
					@receive_file= get_text(line, 's')
				when /^use_distance/
					@use_distance=get_text(line, 'b')
				when /^distance_file/
					@distance_file= get_text(line, 's')
				when /^sim_profile/
					@sim_profile= get_text(line, 'b')
				when /^profile_file/
					@sim_profile_file= get_text(line, 's')
				when /^ph_profile/
					@phantom_profile= get_text(line, 'b')
				when /^ph_file/
					@phantom_profile_file= get_text(line, 's')
				when /^patient_search/
					@patient_search= get_text(line, 's')
				when /^add_info/
					info_name= line.split(' : ')[1]
					@add_info[info_name]=line.split(' : ')[2]
				when /^phantom/			
					@phantom=get_text(line, 'b')	
				when /^special_concentrations/			
					@special_concentrations=get_text(line, 'b')	
				when /^mrecon_area/			
					@mrecon_area=get_text(line, 'b')	
				when /^seperate_eretic/			
					@seperate_eretic=get_text(line, 'b')
				when /^seperate_folder/			
					@seperate_folder=get_text(line, 's')
				when /^water_measurement/
					@water_measurement=get_text(line, 'b')
				when /^drive_scale/			
					@drive_scale=get_text(line, 'b')
				when /^calib_conc_eretic/			
					@calib_conc_eretic=get_text(line, 'b')
				when /^calib_conc_folder/			
					@calib_conc_folder=get_text(line, 's')		
				when /^calib_conc_met/			
					@calib_conc_met=get_text(line, 's')
				when /^use_calib_conc_ds/			
					@calib_conc_ds=get_text(line, 'b')
				when /^calib_conc_ds_folder/			
					@calib_conc_ds_folder=get_text(line, 's')		
				when /^calib_conc_ds_met/			
					@calib_conc_ds_met=get_text(line, 's')
				when /^calib_conc_voxel/
					ap_rl=get_text(line, 's').split(' ')
					@calib_conc_voxel[0]=ap_rl[0].to_i
					@calib_conc_voxel[1]=ap_rl[1].to_i					
				when /^calib_average/			
					@calib_average=get_text(line, 'b')	
				when /^use_qbc_water_ds/			
					@qbc_water_ds=get_text(line, 'b')
				when /^qbc_water_folder/			
					@qbc_water_folder=get_text(line, 's')	
				when /^qbc_search_string/			
					@qbc_search_string=get_text(line, 's')
				when /^use_sense_water_ds/			
					@sense_water_ds=get_text(line, 'b')
				when /^sense_water_folder/			
					@sense_water_folder=get_text(line, 's')	
				when /^sense_search_string/			
					@sense_search_string=get_text(line, 's')						
				when /^segmentation/			
					@segmentation=get_text(line, 'b')	
				when /^segment_folder2split/			
					@segment_folder2split=get_text(line, 's')	
				when /^segment_file/			
					@segment_file=get_text(line, 's')	
				when /^segment_search/			
					@segment_search=get_text(line, 's')	
				when /^given_segm/			
					@given_segm=get_text(line, 's')	
				when /^alpha/
					all_alphas=get_text(line, 's').split(' ')
					alpha[0]=Float(all_alphas[0])
					alpha[1]=Float(all_alphas[1])
					alpha[2]=Float(all_alphas[2])
				when /^read_in_relax/
					@read_in_relax=get_text(line, 'b')
				when /^rel_file/
					@relax_file=get_text(line, 's')	
				when /^rel_search/
					@relax_search=get_text(line, 's')	
				 
			end
		}		
	end


	private
	
	def get_text(line, obj_type)
		
		@tmp = line.split(' : ')[1]
		case obj_type
			when 'i' then return @tmp.to_i
			when 'f' then return @tmp.to_f
			when 's' then return @tmp.to_s														
			when 'b' then return boolean(@tmp)
		end
	end
	# get relaxation times
	def get_relax(content,name)		
		content.each{ |line|
			break if line.match(/^(end of relax)/)
			next if line.match(/^(\#)/)
			tissue=line.split(':')[0].strip
			@relax_times[name][tissue]=Array.new(2)
			@relax_times[name][tissue][0]=Float(line.split(':')[1].split('/')[0])
			@relax_times[name][tissue][1]=Float(line.split(':')[1].split('/')[1])
		}
	end
	# get reference	
	def get_reference(content,name)
		counter=0			
		content.each{ |line|
			break if line.match(/^(end of reference)/)
			next if line.match(/^(\#)/)		
			@references[name][counter]=line
			counter+=1
		}
	end
	# converst string into boolean
	def boolean(string)
		return true if string==true || string=~(/(true|t|yes|y|1)$/i)	
		return false if string==false || string=~(/(false|f|no|n|0)$/i)	
	end

end
