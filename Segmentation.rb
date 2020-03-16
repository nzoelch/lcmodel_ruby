class Segmentation

	attr_reader :nr_scans, \
				:info_col, \
				:comp
				

		
	def initialize(filename,scan_nr,row_nr,col_nr,debug, fitinfo)
		if filename.empty?
			@info_col=''
			@comp=fitinfo.given_segm.split(' ')
		else
		
			file= File.new(filename,"r");
			content=file.readlines
			file.close
			@info_col=content[1].split(' ')
			# info col contains this
			# scan row col GM WM CSF SUM #voxel GMe WMe CSFe typ 
			# don't change
			
			# no difference between SV and MRSI
			# scan row col c1 c2 c3
			# for sv row=1 col=1
			#puts " Attention Segmentation done the old way "
			if !fitinfo.mrsi_scan
				if fitinfo.segment_search.empty?
					search_voxel="^#{scan_nr}"+" "+"#{row_nr}"+" "+"#{col_nr}"+" "
				else
					search_voxel=eval(fitinfo.segment_search)
				end
					
				comp_voxel=content.grep(/(?i:#{search_voxel})/)
				if !comp_voxel[0].nil?
					@comp=comp_voxel[0].split(' ')
				else
					puts "  No Segmentation info for scan #{scan_nr}"
				end
				
				if debug
					# This has to be Ioannis Skript Output
					puts "  Only working for SV"
					puts "  Searching for #{search_voxel}"
					puts "  in line #{comp_voxel}"
				end
			else
				#----------------------------------------------
				# Thats how I did it before I had Ioannis Skript
				# and how I still have to do it in case of MRSI
				#----------------------------------------------
				#welches voxel
				search_voxel=" "+"#{row_nr}"+" "+"#{col_nr}"+" "
				comp_voxel=content.grep(/(?i:#{search_voxel})/)
				if !comp_voxel[0].nil?
					@comp=comp_voxel[0].split(' ')
				else
					puts "  No Segmentation info for scan #{scan_nr}"
				end
				
				if debug
					# This has to be Ioannis Skript Output
					puts "  Only working for SV"
					puts "  Searching for #{search_voxel}"
					puts "  in line #{comp_voxel}"
				end
				
				
				
				# so habe ich das gemacht wenn verschieden scans drin waren
				# #puts search_voxel
				# comp_voxel=content.grep(/(?i:#{search_voxel})/)
				# # composition of that voxel possibly in several scans
				# # scan has to be selected, next step
				# composition=Array.new(comp_voxel.size)
				# scan_numbers=Array.new(comp_voxel.size)
				# #
				# for i in 0..(comp_voxel.size-1)
					# composition[i]=Array.new(@info_col.size)
					# # 2 information lines
					# composition[i]=comp_voxel[i].split(' ')
					# scan_numbers[i]=Integer(comp_voxel[i].split(' ')[0])
					# #puts "#{Integer(content[2+i].split(' ')[0])}"
				# end
				# # highest numnber smaller than the scan nr
				# # is the one choosen for the segmentation infos.
				# a=scan_numbers.select{|b| b < scan_nr}
				# #
				# @comp=composition[scan_numbers.index(a.max)]
				# #
				# #puts @comp
				#
			end
		end		
	end

end
