class Profile

	attr_reader :mr_mxy, \
				:abs_mxy
				

		
	def initialize(filename,row_nr,col_nr)
		#--------------------------------------------------------------------
		# Im txt file
		# 1. Zeile: Sim profile date patient (nr) b1 (file_of_b1_map_used_for sim)
		# 2. zeile: Row Col imag_mxy abs_mxy 
		# Determined in Matlab file simulate_profil_mrsi_loop
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
		@mr_mxy=info_from_voxel[0].split(' ')[2]
		@abs_mxy=info_from_voxel[0].split(' ')[3]
		#
		#puts "#{@imag_mxy}"
		#puts "#{@abs_mxy}"
		#
	end
	

end

class PhantomProfile

	attr_reader :mxy_phantom,\
				:r_pa
				

		
	def initialize(filename,row_nr,col_nr)
		# liest summary file ein
		# looks for file
		summary_file=Dir.glob("#{filename}/*.csv")
		# reads the file
		file= File.new(summary_file[0],"r")
		content=file.readlines
		file.close
		
		conc=Array.new
	
		line_conc=content.grep(/Concentration of water/)
			if !line_conc.empty?
				nr_line_conc=content.index(line_conc[0])
				info_col=content[nr_line_conc+1].split(';')
				# sucht nach eretic_normalized_calib_conc
				index_sim_mr_mxy=info_col.index('sim_mr_mxy')
				index_rpa=info_col.index('r_pa')
				#
				puts " Phantom Profil Read MRSI"
				puts "   search for voxel ap #{row_nr} rl #{col_nr}"
				info_conc=content.grep(/.*;#{row_nr};#{col_nr};/)
				

				if info_conc.empty?
					puts "THIS doesn't work"
					
				end
				info_conc=info_conc.grep(/water/)
				#puts info_conc
				puts " Number of voxels founf #{info_conc.size}"
				puts info_conc
				if info_conc.size == 1
					mr_mxy=info_conc[0].split(';')[index_sim_mr_mxy].to_f
					r_pa=info_conc[0].split(';')[index_rpa].to_f
				
				end
				
				
				@mxy_phantom=mr_mxy/r_pa   # eingelesene flaeche vom phantom relaxations korrigiert
				@r_pa=r_pa
			
			end
	end	

end