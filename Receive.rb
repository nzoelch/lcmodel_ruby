class Receive

	attr_reader :receive, \
				:receive_scaled,\
				:receive_b1map,\
				:receive_ratio
				

		
	def initialize(filename,position)
		#--------------------------------------------------------------------
		# Im txt file
		# 1. Zeile: SV receive raw patient 
		# 2. zeile: AP RL FH Receive Receive_Scaled B1_map
		# Determined in Matlab file WANG_date_svs.m
		#--------------------------------------------------------------------
		if File.file?(filename)
			puts " Reveive Filename "
			puts "#{filename}"
			file= File.new(filename,"r");
			content=file.readlines
			#
			#puts content
			#
			file.close
			#welche position % AP RL FH
			#wie im .spar
			#info_from_pos=content.grep(/(#{position["ap"]}\d*\s*#{position["lr"]}\d*\s*#{position["cc"]})/)
			if position["ap"].to_s.match(/^-/)
				#puts "minus"
				info_from_pos=content.grep(/^(#{position["ap"]}\d*\s*#{position["lr"]}\d*\s*#{position["cc"]})/)
			else
				#puts "plus"
				info_from_pos=content.grep(/\s(#{position["ap"]}\d*\s*#{position["lr"]}\d*\s*#{position["cc"]})/)
			end
			#
			#puts "#{position["ap"]}\d*\s*#{position["lr"]}\d*\s*#{position["cc"]}"
			if info_from_pos.empty?
				puts "  Attention Receive Info not found, search again "
				puts "  for #{content[0]}"
				#puts "  Looked for #{position["ap"].to_i} #{position["lr"].to_i} #{position["cc"].to_i} "
				info_from_pos=content.grep(/(?i:#{position["ap"].to_i}\.\d*\s*#{position["lr"].to_i}\.\d*\s*#{position["cc"].to_i})/)
			end
			
			if info_from_pos.empty?
				puts "  Receive Info not found even in second round, all set to 1 "
				puts "  for #{content[0]}"
				@receive=1
				@receive_scaled=1
				@receive_b1map=1
				@receive_ratio=1
			else
				@receive=Float(info_from_pos[0].split(' ')[3])
				@receive_scaled=Float(info_from_pos[0].split(' ')[4])
				@receive_b1map=Float(info_from_pos[0].split(' ')[5])
				@receive_ratio=Float(info_from_pos[0].split(' ')[6])
			end
		else
			
			puts "no file found for receive sensitivity"
			@receive=1
			@receive_scaled=1
			@receive_b1map=1
			@receive_ratio=1
			
		end
	end
	

end

class Distance

	attr_reader :min, \
				:mean
				

		
	def initialize(filename)
		#--------------------------------------------------------------------
		# Im txt file
		# 1. Zeile: Distance to head EF_ 
		# 2. zeile: patient min mean
		# Determined in Matlab file read_raw_eretic2014_image.m
		#--------------------------------------------------------------------
		if File.file?(filename)
			file= File.new(filename,"r");
			content=file.readlines
			#
			#puts content
			#
			file.close
		
			@min=Float(content[2].split(' ')[1])
			@mean=Float(content[2].split(' ')[2])
				
		else
			
			puts "no file found for receive sensitivity"
			@min=1
			@mean=1

		end
	end
	

end