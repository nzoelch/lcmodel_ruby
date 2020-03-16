require 'descriptive_statistics'

class Seperate_ERETIC

	attr_reader :area,\
				:sd
				

		
	def initialize(fitinfo,nr_patient,name_scan,nr_scan)
		#
		seperate_file=Dir.glob("#{fitinfo.seperate_folder}/*.csv")
		#
		file= File.new(seperate_file[0],"r");
		content=file.readlines
		file.close
		# sucht die linie mit Concentration of ERETIC
		# rechnet danach mit col
		line_eretic=content.grep(/Concentration of ERETIC/)
		if !line_eretic.empty?
			nr_line_eretic=content.index(line_eretic[0])
			# nimmt die naechste linie 
			info_col=content[nr_line_eretic+1].split(';')
			index_area=info_col.index('area')
			index_sd=info_col.index('sd')
			# sucht die passende Zeile im summary
			search_eretic="#{nr_patient}"+";"+"#{name_scan}"+";"+"#{nr_scan}"+";"
			# schreibt sie in den info
			info_eretic=content.grep(/(?i:#{search_eretic})/)
			#
			info=info_eretic[0].split(';')
			@area=info[index_area]
			@sd=info[index_sd]
			
			# misc info 
			# so konnte man das brauchen, wie wird es aber weiter verarbeitet
			# if fitinfo.use_misc_info
				# index_misc=Array.new(6)
				# index_misc[0]=info_col.index('fwhm_hz')
				# index_misc[1]=info_col.index('fwhm_ppm')
				# index_misc[2]=info_col.index('snr')	
				# index_misc[3]=info_col.index('data_shift')
				# index_misc[4]=info_col.index('zero_phase')
				# index_misc[5]=info_col.index('first_phase')				
			# end
		else
			puts "  ERETIC values could not be found in seperate file"
			@area=0
			@sd=0
		end
	end

end
class ERETIC_Calib_Conc
	#Da wir die normailisierte einegelesen in
	#eretic_calib_conc
	attr_reader :eretic_calib_conc,\
				:sd
				

		
	def initialize(fitinfo,exam_date)
		# looks for file
		calib_conc_file=Dir.glob("#{fitinfo.calib_conc_folder}/*.csv")
		# reads the file
		file= File.new(calib_conc_file[0],"r")
		content=file.readlines
		file.close
		# looks for metabolite
		date=exam_date.split('.')
		#
		#puts "year #{date[0]}"
		#puts "month #{date[1]}"
		#puts "day #{date[2]}"
		#
		conc=Array.new
		#
		line_conc=content.grep(/Concentration of #{fitinfo.calib_conc_met}/)
		if !line_conc.empty?
			nr_line_conc=content.index(line_conc[0])
			info_col=content[nr_line_conc+1].split(';')
			# sucht nach eretic_normalized_calib_conc
			index_calib_conc=info_col.index('eretic_normalized_calib_conc')
			
			info_conc=content.grep(/^#{date[2]}.#{date[1]}/)
			info_conc=info_conc.grep(/#{fitinfo.calib_conc_met}/)
			
			#puts " Number of calibs #{info_conc.size}"
			for ii in 0..(info_conc.size-1)
				conc[ii]=info_conc[ii].split(';')[index_calib_conc].to_f
			end
			
			@eretic_calib_conc=conc.mean
			@sd=conc.standard_deviation
		
			#puts @eretic_calib_conc
			#puts @sd
		else
			puts " ERETIC Calib conc could not be found in seperate file"
	
		end
	end

end

class DS_Calib_Conc
	#Da wir die normailisierte einegelesen in
	#ds_calib_conc
	attr_reader :ds_calib_conc,\
				:ds_sd,\
				:ds_calib_averaged
				
		
	def initialize(fitinfo,exam_date,patient_nr,file_sdat)
		# looks for file
		calib_conc_file=Dir.glob("#{fitinfo.calib_conc_ds_folder}/*.csv")
		puts "#{fitinfo.calib_conc_ds_folder}"
		# reads the file
		file= File.new(calib_conc_file[0],"r")
		content=file.readlines
		file.close
		# looks for metabolite
		date=exam_date.split('.')
		#
		#date[2].sub!(/^0/, "")
		#puts "year #{date[0]}"
		#puts "month #{date[1]}"
		#puts "day #{date[2]}"
		#
		conc=Array.new
		#--------------------------------------------------
		# Use the calibrated Drive Scale
		#--------------------------------------------------
		if fitinfo.calib_conc_ds
			line_conc=content.grep(/Concentration of #{fitinfo.calib_conc_ds_met}/)
			if !line_conc.empty?
				nr_line_conc=content.index(line_conc[0])
				info_col=content[nr_line_conc+1].split(';')
				# sucht nach eretic_normalized_calib_conc
				index_calib_conc=info_col.index('ds_normalized_calib_conc')
				#
				#--------------------------------------------------
				# MRSI 
				#--------------------------------------------------
				if !fitinfo.mrsi_scan 
					info_conc=content.grep(/^#{date[2]}.#{date[1]}/)
				else
					puts "   DS Calibration MRSI"
					puts "   search for voxel ap #{fitinfo.calib_conc_voxel[0]} rl #{fitinfo.calib_conc_voxel[1]}"
					#info_conc=content.grep(/^#{date[2]}.#{date[1]}.*#{fitinfo.calib_conc_voxel[0]};#{fitinfo.calib_conc_voxel[1]}/)
					info_conc=content.grep(/.*;#{fitinfo.calib_conc_voxel[0]};#{fitinfo.calib_conc_voxel[1]};/)
				end
				#--------------------------------------------------
				# When there is no calibration available at that date
				#--------------------------------------------------
				#
				@ds_calib_averaged=false
				#
				if info_conc.empty?
					puts " No Calibration for date #{date[2]}.#{date[1]}"
					if fitinfo.calib_average
							puts " Attention ::::::::::::::::::::: All calibrations averaged for that date"
							# Jetzt ist es so, dass wenn nichts gefunden wird, werden die calibrations messungen von allen anderen Daten geaveraget
							# when fitinfo.calib_average auf true
							info_conc=content.grep(/#{fitinfo.calib_conc_ds_met}\;+$/)
							@ds_calib_averaged=true
							#
							#puts info_conc
					end
					
					# Das war ein Spezial fuer die LASER Daten
					#else
					#puts " Special for LASER"
				
						# # double check 
						# if (Float(date[2])==10) && (Float(date[1])==12)
							# info_conc=content[nr_line_conc+7 .. nr_line_conc+13]
							# #puts info_conc
						# end
					# end
					
				end
				
				info_conc=info_conc.grep(/#{fitinfo.calib_conc_ds_met}\;+$/)
				#puts info_conc
				puts " Number of calibs #{info_conc.size}"
				for ii in 0..(info_conc.size-1)
					conc[ii]=info_conc[ii].split(';')[index_calib_conc].to_f
				end
				
				@ds_calib_conc=conc.mean
				@ds_sd=conc.standard_deviation
			
				#puts @ds_calib_conc
				#puts @ds_sd
			else
				puts " Concentration of #{fitinfo.calib_conc_ds_met} could not be found in seperate file for ds calibration "
				
			end
		end
	end

end

class Read_QBC_water
	#
	attr_reader :qbc_drive_scale,\
				:qbc_water_area

	
	def initialize(fitinfo,exam_date,patient_nr,file_sdat)
		# looks for file
		qbc_meas_file=Dir.glob("#{fitinfo.qbc_water_folder}/*.csv")
		# reads the file
		file= File.new(qbc_meas_file[0],"r")
		content=file.readlines
		file.close
		#looking for the date
		date=exam_date.split('.')
		#--------------------------------------------------
		# Read the water and drive scale from the qbc measurement
		#--------------------------------------------------
		# Checks (TR / TE)
		# suchen nach drive scale, te , tr und water area
		
		# das ist nur um die spalten namen zu finden
		line_col_names=content.grep(/area water/)
		
			if !line_col_names.empty?
				# te
				index_qbc_te=line_col_names[0].split(';').index('te')
				# tr water
				index_qbc_tr_water=line_col_names[0].split(';').index('tr water')
				# area water
				index_qbc_area_water=line_col_names[0].split(';').index('area water')
				# drive scale water
				index_qbc_drive_scale_water=line_col_names[0].split(';').index('drive_scale water')
				#
				extra=""
				# Das ist extra fuer Body Drive Scale 2015
				if match=file_sdat[0].match(/_(\d*)_1_\w*press_s8_auto_(\w{1,2})(_|V)/)
					#liest den buchstaben aus dem Namen des scans mit der receive spule und setzt es gleich dem wert
					#der in der tabelle der qbc werte erwartet wird
					act_scan_nr=match[1].to_i
					pos=match[2]
					extra = case pos
					when "m" then "mitte"
					when "l" then "links"
					when "r" then "rechts"
					when "lo" then "lo"
					else
					"unknown"
					end
				end
				puts "Position bestimmt in qbc file: #{extra}"
				# sucht die passende Zeile im summary
				search_patient_scan="^#{date[2]}.#{date[1]}"+";"+"#{patient_nr}"+";"+"\.*;#{extra};"
				puts "Here puts #{eval(fitinfo.qbc_search_string)}" 
				if !fitinfo.qbc_search_string.empty?
					search_patient_scan=eval(fitinfo.qbc_search_string)
				end
				puts "Sucht nacht: #{search_patient_scan}  in qbc file" 
				# schreibt sie in den info
				info_patient=content.grep(/(?i:#{search_patient_scan})/)
				#
				@qbc_water_area=info_patient[0].split(';')[index_qbc_area_water].to_f
				@qbc_drive_scale=info_patient[0].split(';')[index_qbc_drive_scale_water].to_f
				#
				qbc_tr_water=info_patient[0].split(';')[index_qbc_tr_water].to_f
				qbc_te=info_patient[0].split(';')[index_qbc_te].to_f
				
				puts " qbc scan measured with TE: #{qbc_te} and TR: #{qbc_tr_water}"
				
			else
				puts " drive scale calib conc could not be found in seperate file"
		
			end
			
		end
end



class Read_SENSE_water
	#
	attr_reader :sense_drive_scale,\
				:sense_water_area

	
	def initialize(fitinfo,exam_date,patient_nr,file_sdat)
		# looks for file
		sense_meas_file=Dir.glob("#{fitinfo.sense_water_folder}/*.csv")
		# reads the file
		file= File.new(sense_meas_file[0],"r")
		content=file.readlines
		file.close
		#looking for the date
		date=exam_date.split('.')
		#--------------------------------------------------
		# Read the water and drive scale from the qbc measurement
		#--------------------------------------------------
		# Checks (TR / TE)
		# suchen nach drive scale, te , tr und water area
		
		# das ist nur um die spalten namen zu finden
		line_col_names=content.grep(/area water/)
		
			if !line_col_names.empty?
				# te
				index_sense_te=line_col_names[0].split(';').index('te')
				# tr water
				index_sense_tr_water=line_col_names[0].split(';').index('tr water')
				# area water
				index_sense_area_water=line_col_names[0].split(';').index('area water')
				# drive scale water
				index_sense_drive_scale_water=line_col_names[0].split(';').index('drive_scale water')
				#
				extra=""
				# # not needed just to show possible code
				# if match=file_sdat[0].match(/_(\d*)_1_\w*press_s8_auto_(\w{1,2})(_|V)/)
					# #liest den buchstaben aus dem Namen des scans mit der receive spule und setzt es gleich dem wert
					# #der in der tabelle der qbc werte erwartet wird
					# act_scan_nr=match[1].to_i
					# pos=match[2]
					# extra = case pos
					# when "m" then "mitte"
					# when "l" then "links"
					# when "r" then "rechts"
					# when "lo" then "lo"
					# else
					# "unknown"
					# end
				#end
				puts "Position bestimmt in sense file: #{extra}"
				# sucht die passende Zeile im summary
				search_patient_scan="^#{date[2]}.#{date[1]}"+";"+"#{patient_nr}"+";"+"\.*;#{extra};"
				puts "Here puts #{eval(fitinfo.sense_search_string)}" 
				if !fitinfo.sense_search_string.empty?
					search_patient_scan=eval(fitinfo.sense_search_string)
				end
				puts "Sucht nacht: #{search_patient_scan}  in sense file" 
				# schreibt sie in den info
				info_patient=content.grep(/(?i:#{search_patient_scan})/)
				#
				@sense_water_area=info_patient[0].split(';')[index_sense_area_water].to_f
				@sense_drive_scale=info_patient[0].split(';')[index_sense_drive_scale_water].to_f
				#
				sense_tr_water=info_patient[0].split(';')[index_sense_tr_water].to_f
				sense_te=info_patient[0].split(';')[index_sense_te].to_f
				
				puts " sense scan measured with TE: #{sense_te} and TR: #{sense_tr_water}"
				
			else
				puts " drive scale calib conc could not be found in seperate file"
		
			end
			
		end
end