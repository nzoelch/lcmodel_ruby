class Spar

	attr_reader :f0, \
				:te, \
				:tr, \
				:pat_name, \
				:exam_date, \
				:exam_time, \
				:nsa, \
				:pts, \
				:bw, \
				:exam_name, \
				:scan_id, \
				:pat_birth, \
				:pat_pos, \
				:pat_ori, \
				:voi_size, \
				:offcenter, \
				:voi_ang, \
				:drive_scale,\
				:mrecon_area_w,\
				:mrecon_td_w_null,\
				:mrecon_area_e,\
				:temp_freq_shift,\
				:a_water,\
				:a_water_ratio,\
				:t2_water,\
				:fwhm_water_1,\
				:fwhm_water_2
				
				
	@@time_regex 	= Regexp.new(/(\d{2}\:){2}\d{2}/)
	@@date_regex 	= Regexp.new(/(\d{1,4}?\.){2}\d{1,2}/)
		
	def initialize(filename)
	
		@voi_size       = Hash.new
		@offcenter      = Hash.new
		@voi_ang        = Hash.new
		@drive_scale    = ''
		@mrecon_area_w    = ''
		@mrecon_td_w_null = ''
		@mrecon_area_e    = ''
		@exam_time    	= ''
		@exam_date    	= ''
		@exam_name    	= ''
		@fo		    	= 0
		@te		    	= 0
		@tr		    	= 0
		@pts		    = 0
		@bw		        = 0
		@temp_freq_shift= 0
		@a_water		= 0
		@a_water_ratio  = 0
		@t2_water	    = 0
		@fwhm_water_1   = 0
		@fwhm_water_2   = 0
		
		File.open(filename, 'r') do |file|
		  file.each_line do |line|
			  	case line.chomp!
			  		when /^scan_date/ 
			  			@exam_time = line.slice(@@time_regex)
			  			if line.slice(@@date_regex).nil?
							@exam_date = ''
						else
							@exam_date = line.slice(@@date_regex)
						end
			  		when /^synthesizer_frequency/
			  			@f0		 = get_text(line, 'f')
			  		when /^echo_time/
			  			@te		 = get_text(line, 'f')
			  		when /^repetition_time/
			  			@tr		 = get_text(line, 'f')
			  		when /^averages/
			  			@nsa	 = get_text(line, 'i')
			  		when /^samples/
			  			@pts	 = get_text(line, 'i')
			  		when /^sample_frequency/
			  			@bw		 = get_text(line, 'f')
			  		when /^patient_name/
			  			@pat_name = get_text(line, 's')
			  		when /^examination_name/
			  			@exam_name = get_text(line, 's')
			  		when /^scan_id/
			  			@scan_id = get_text(line, 's')
			  		when /^patient_birth_date/
			  			@pat_birth = line.slice(@@date_regex)
			  		when /^patient_position/
			  			@pat_pos = get_text(line, 's')
					when /^drive_scale/
			  			@drive_scale = get_text(line, 'f')
					when /^water_area/
			  			@mrecon_area_w = get_text(line, 'f')
					when /^water_td_null/
			  			@mrecon_td_w_null = get_text(line, 'f')
					when /^eretic_area/
			  			@mrecon_area_e = get_text(line, 'f')
			  		when /^patient_orientation/
			  			@pat_ori = get_text(line, 's')
			  		when /^ap_size/, /^lr_size/, /^cc_size/
			  			@voi_size[line[0..1]] = get_text(line, 'f')
			  		when /^ap_off_center/, /^lr_off_center/, /^cc_off_center/ 
			  			@offcenter[line[0..1]] = get_text(line, 'f')
					when /^freq_shift/
			  			@temp_freq_shift = get_text(line, 'f')
			  		when /^a_water /
			  			@a_water = get_text(line, 'f')
					when /^a_water_ratio/
			  			@a_water_ratio = get_text(line, 'f')
					when /^t2_water/
			  			@t2_water= get_text(line, 'f')
					when /^fwhm_water_1/
			  			@fwhm_water_1= get_text(line, 'f')
					when /^fwhm_water_2/
			  			@fwhm_water_2= get_text(line, 'f')
			  	end
			end
		end		
	end
	
	private
	
	def get_text(line, obj_type)
		
		@tmp = line.split(' : ')[1]
		case obj_type
			when 'i' then return @tmp.to_i
			when 'f' then return @tmp.to_f
			when 's' then return @tmp.to_s
		end
	end

end
