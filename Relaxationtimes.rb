class Relaxationtimes

	attr_reader :t1_read, \
				:t2_read
				

		
	def initialize(patient_nr,debug,fitinfo)
		# vorerst only for water
		#------------------------
		file= File.new(fitinfo.relax_file,"r");
		content=file.readlines
		file.close
		
		# this is only for water see seperate eretic how to do it more advanced
		if debug
		puts " Relaxation times read from file"
		puts " Erste Zeile : #{content[1]}"
		end
		info_col=content[1].split(';')
		
		# Das sind die, die ich erwarte
		#
		index_t1_csf=info_col.index("T1_CSF")
		index_t1_pa=info_col.index("T1_PA")
		index_t2_csf=info_col.index("T2_CSF")
		index_t2_pa=info_col.index("T2_PA")
		#
		search_voxel=eval(fitinfo.relax_search)
		# standard ist
		#search_voxel="^#{patient_nr}"
		#
		#
		relaxation_patient=content.grep(/(?i:#{search_voxel})/)	
		#
		if debug
			puts " Patient: #{relaxation_patient}"
			puts " Looking for: #{fitinfo.relax_search} which is #{search_voxel}"
		end
		#
		#
		#
		@t1_read=Hash.new
		@t2_read=Hash.new
		if !relaxation_patient[0].nil?
			line=relaxation_patient[0].split(';')
			#
			if Float(line[index_t1_csf])==0 or Float(line[index_t1_pa])==0
				# Wenn eines der beiden Null ist setzt es beide gleich
				if Float(line[index_t1_csf])==0
					@t1_read["csf"]=Float(line[index_t1_pa])
					@t1_read["pa"]=Float(line[index_t1_pa])
				else
					@t1_read["csf"]=Float(line[index_t1_csf])
					@t1_read["pa"]=Float(line[index_t1_csf])
				end
			else
				@t1_read["csf"]=Float(line[index_t1_csf])
				@t1_read["pa"]=Float(line[index_t1_pa])
			end
			# T2
			if Float(line[index_t2_csf])==0 or Float(line[index_t2_pa])==0
				# Wenn eines der beiden Null ist setzt es beide gleich
				if Float(line[index_t2_csf])==0
					@t2_read["csf"]=Float(line[index_t2_pa])
					@t2_read["pa"]=Float(line[index_t2_pa])
				else
					@t2_read["csf"]=Float(line[index_t2_csf])
					@t2_read["pa"]=Float(line[index_t2_csf])
				end
			else
				@t2_read["csf"]=Float(line[index_t2_csf])
				@t2_read["pa"]=Float(line[index_t2_pa])
			end
			#
			# for debug
			#puts @t1_read["csf"]
			#puts @t1_read["pa"]
			#puts @t2_read["csf"]
			#puts @t2_read["pa"]
		else
			puts "  No Relaxation times for patient #{patient_nr}"
		end		
	
	end

end
