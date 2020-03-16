class B1map

	attr_reader :nr_scans, \
				:percentage,\
				:cfactor
				

		
	def initialize(filename,row_nr,col_nr)
		#--------------------------------------------------------------------
		# Im txt file
		# 1. Zeile: B1 Map patient ()  from file ()
		# 2. zeile: Row Col Percent Correction_Factor 
		# Determined in Matlab file read_raw_b1map_loop_folder
		#--------------------------------------------------------------------
		file= File.new(filename,"r");
		content=file.readlines
		file.close
		#
		#welches voxel
		search_voxel="^#{row_nr}"+" "+"#{col_nr}"+" "
		#puts search_voxel
		info_from_voxel=content.grep(/(?i:#{search_voxel})/)
		#
		@percentage=Float(info_from_voxel[0].split(' ')[2])
		@cfactor=Float(info_from_voxel[0].split(' ')[3])
		#
		#puts "#{@imag_mxy}"
		#puts "#{@abs_mxy}"
		
		
		
		
		# # Im txt file
		# #1. zeile: SV B1 raw patient E$
		# #2. zeile: scan percentage correction_factor
		# file= File.new(filename,"r");
		# content=file.readlines
		# file.close
		# #
		# if content[0].split(' ')[0].eql?('SV')
			# #
			# @nr_scans=content.size-2
			# composition=Array.new(nr_scans)
			# scan_numbers=Array.new(nr_scans)
			# @info_col=content[1].split(' ')
			# #
			# for i in 0..(nr_scans-1)
				# composition[i]=Array.new(info_col.size)
				# # 2 information lines
				# composition[i]=content[2+i].split(' ')
				# scan_numbers[i]=Integer(content[2+i].split(' ')[0])
				# #puts "#{Integer(content[2+i].split(' ')[0])}"
			# end
			# # Here I can add something to choose the appropriate scan nummber
			# # --------------Ideas see segmentation---------------------------
		    # choosen_scan=0
			# @percentage=composition[choosen_scan][1]
			# @cfactor=composition[choosen_scan][2]
			 
			# # puts @percentage
			# # puts @cfactor
			
		# else
		 # puts "fuck it"
		# end
		# #
		
	end
	

end
class B1map_DS

	attr_reader :percentage, \
				:max, \
				:cfactor				
	# gemittelter prozent vom gewuenschten flip winkel im voxel			
	# max prozent vom gewuenschten flip winkel im voxel
	# noch nicht gebraucht hier
	def initialize(filename,scan_nr)
		#--------------------------------------------------------------------
		# Lines in the Matlab file to write this txt files
		#['SV B1 BS raw patient ',kuerzel,num2str(folder_to_process(loop_folder)),' \r\n']
		#'sv_scan_nr B1_mean B1_max \r\n'
		# z.B B1_2015_01_23
		#--------------------------------------------------------------------		
		#
		@cfactor =1
		#
		if File.file?(filename)
			file= File.new(filename,"r");
			content=file.readlines
			file.close
			
			#welcher scan 
			search_scan_nr="^#{scan_nr}"+" "
			info_from_pos=content.grep(/(?i:#{search_scan_nr})/)
			#
			if info_from_pos.empty?
				puts "  B1 map Info not found, all set to 1 "
				puts "  #{filename}"
				@percentage=1
				@max=1
			else
				@percentage=Float(info_from_pos[0].split(' ')[1])
				@max=Float(info_from_pos[0].split(' ')[2])
			end
		else
			
			puts "no file found for b1map"
			@percentage=1
			@max=1
			
		end
		
	
		
	end
	

end