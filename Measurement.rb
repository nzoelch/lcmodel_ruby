class Measurement
	
	attr_accessor :met,\
				:conc,\
				:sd,\
				:ratio,\
				:date_scan,\
				:filename,\
				:name_scan,\
				:nr_scan,\
				:nr_patient,\
				:name_patient,\
				:exam_name,\
				:slice,\
				:row,\
				:col,\
				:te,\
				:tr,\
				:position,\
				:samples,\
				#--------------voi
				:voi_ap,\
				:voi_lr,\
				:voi_cc,\
				:voi_vol,\
				:offcenter_ap,\
				:offcenter_lr,\
				:offcenter_cc,\
				:dist_voxel_coil,\
				:par_fwhm_hz,\
				:par_fwhm_hz_2,\
				#---------------misc
				:fwhm_hz,\
				:fwhm_ppm,\
				:snr,\
				:data_shift,\
				:zero_phase,\
				:first_phase,\
				#---------------b1
				:b1raw_per,\
				:b1raw_cf,\
				:b1rec_per,\
				:b1rec_cf,\
				:b1rec_max,\
				#----------------receive
				:receive,\
				:receive_scaled,\
				:receive_b1map,\
				:receive_ratio,\
				#---------------sim_profile
				:sim_mr_mxy,\
				:sim_abs_mxy,\
				#---------------phantom_profile
				:mxy_phantom,\
				#---------------segementation
				:f_gm_vol,\
				:f_wm_vol,\
				:f_csf_vol,\
				:f_gm_mol,\
				:f_wm_mol,\
				:f_csf_mol,\
				:s_r_corr,\
				:r_gm,\
				:r_wm,\
				:r_csf,\
				:r_pa,\
				#----------------------------
				# Das ist nur fuer relxation eingelesen von file individuell also overall relaxation gemessen nicht tissue specific
				# hauptsaechlich fuers wasser
				#----------------------------
				:t1,\
				:t2,\
				#-----------------------------
				# gussew info eingelesen via spar file direkt
				#-----------------------------
				:gussew_t2,\
				:gussew_ratio,\
				#---------------
				:temp_freq_shift,\
				#-----------------
				:fcalib,\
				# molal concentration of MR visible concentration obtained with segmentation mmol/kg				
				:h2o,\
				# wasser signal voll relaxiert: nur meoglich wenn segmentierung und t1 t2 daten
				:sh2o_r,\
				# wasser signal voll relaxiert: berechnet mit gussew messung
				:sh2o_gr,\
				#
				:area,\
				# simple ratios
				:to_water,\
				:to_eretic,\
				:to_cre,\
				# concentrations
				# using water
				:c_wm,\
				:c_bv_H2O,\
				#special concentrations
				:c_wm_csf,\
				:c_wm_tot_H2O,\
				# using creatine
				:c_bv_Cr,\
				# using eretic not updated yet 10.2014
				:c_bv_eretic,\
				# receive corrected
				:cR_bv_eretic,\
				# using ds not updated yet 10.2014
				:c_bv_DS,\
				:c_totvol_DS,\
				:c_wm_tot_DS,\
				# receive corrected
				:cR_bv_DS,\
				# profil corrected
				:cS_bv_DS,\
				# profil corrected
				:cPR_bv_DS,\
				#
				:eretic_calib_conc,\
				:eretic_normalized_calib_conc,\
				:drive_scale,\
				:one_over_drive,\
				:qbc_water_area,\
				:qbc_drive_scale,\
				#
				:sense_water_area,\
				:sense_drive_scale,\
				#
				:ds_normalized_calib_conc,\
				# wurde die calib_conc gemittelt ueber mehrere daten
				:ds_calib_averaged,\
				# ------------------------- area from mrecon water and eretic
				:mrecon_w,\
				:mrecon_td_w,\
				:mrecon_e		
				
	
	def initialize
	
		@met			= ""
		@conc			= 0	
		@sd 	        = 0
		@ratio			= 0
		@date_scan		= Array.new(3)
		@filename		= ""
		@name_scan		= ""
		@nr_scan 	    = 0
		@nr_patient	    = 0
		@name_patient	= ""
		@exam_name		=""
		# mrsi
		@slice			= 0
		@row			= 0
		@col            = 0
		#
		@te				= 0
		@tr				= 0
		@samples		= 0
		@position		=""
		# t1 und t2
		@t1				=Hash.new
		@t2				=Hash.new
		#
		@gussew_t2 		=0 
		@gussew_ratio   =0
		#
		@temp_freq_shift=0
		#
		#voi volume im mm^3
		@voi_ap         = 0
		@voi_lr			= 0	
		@voi_cc			= 0
		@voi_vol		= 0
		#offcentre
		@offcenter_ap   = 0
		@offcenter_lr   = 0
		@offcenter_cc   = 0
		@dist_voxel_coil= 0
		# info from par
		@par_fwhm_hz = 0
		@par_fwhm_hz_2 = 0
		#misc
		@fwhm_hz		= 0
		@fwhm_ppm		= 0
		@snr			= 0
		@data_shift		= 0
		@zero_phase		= 0
		@first_phase	= 0
		#
		@b1raw_per		= 0
		@b1raw_cf       = 1
		@b1rec_per		= 0
		@b1rec_max		= 0
		@b1rec_cf       = 1
		#
		@receive		=1
		@receive_scaled =1
		@receive_b1map	=1
		@receive_ratio =1
		#
		@sim_mr_mxy  	=1
		@sim_abs_mxy	=1
		#-------------------
		@f_gm_vol		= 0
		@f_wm_vol	    = 0
		@f_csf_vol		= 0
		@f_gm_mol			= 0
		@f_wm_mol		    = 0
		@f_csf_mol			= 0
		@s_r_corr		= 1
		@r_gm			= 1
		@r_wm			= 1
		@r_csf			= 1
		@r_pa			= 1
		#water only
		@fcalib			= 0 
		@sh2o_r			= 0
		@sh2o_gr			= 0
		# pure water
		@h2o			= 55556 	
		#
		@area			=""
		@to_water 		="-"
		@to_eretic 		="-"
		@to_cre 		="-"
		# concentrations
		# using water
		@c_wm		 	="-"
		@c_bv_H2O		="-"
		# special concentrations
		@c_wm_csf		 ="-"
		@c_wm_tot_H2O		 ="-"
		# using creatine
		@c_bv_Cr		="-"
		#
		@c_bv_eretic ="-"
		@cR_bv_eretic ="-"
		#
		# using drive scale
		@c_bv_DS		="-"
		@c_totvol_DS	="-"
		@c_wm_tot_DS	="-"
		@cR_bv_DS		="-"
		@cS_bv_DS		="-"
		@cPR_bv_DS		="-"
		#
		#aufpassen
		@eretic_calib_conc = 1
		@eretic_normalized_calib_conc = 1
		#
		@drive_scale = 1
		@one_over_drive=1
		@ds_normalized_calib_conc=1
		#
		@qbc_water_area=0
		@qbc_drive_scale=0
		#
		@sense_water_area=0
		@sense_drive_scale=0
		#
		@mrecon_w = 0
		@mrecon_td_w = 0
		@mrecon_e = 0
					
	end
	
	def create_method( name, &block )
        self.class.send( :define_method, name, &block )
    end

    def create_attr( name )
        create_method( "#{name}=".to_sym ) { |val| 
            instance_variable_set( "@" + name, val)
        }

        create_method( name.to_sym ) { 
            instance_variable_get( "@" + name ) 
        }
    end
	#
	def set_special(string,value)
		var_name = "@#{string}"  # the '@' is required
		self.instance_variable_set(var_name, value)
	end
	# segmentation
	# has to be called before calculate ratios
	def calculate_f_mol(fitinfo)
		# volume fraction determined by segmentation "converted" into molal water fractions
		# müsste ich nicht für jeden metaboliten machen, aber für jede Messung aber egal
		@f_gm_mol=@f_gm_vol*fitinfo.alpha[0]/(@f_gm_vol*fitinfo.alpha[0]+@f_wm_vol*fitinfo.alpha[1]+@f_csf_vol*fitinfo.alpha[2])
		@f_wm_mol=@f_wm_vol*fitinfo.alpha[1]/(@f_gm_vol*fitinfo.alpha[0]+@f_wm_vol*fitinfo.alpha[1]+@f_csf_vol*fitinfo.alpha[2])
		@f_csf_mol=@f_csf_vol*fitinfo.alpha[2]/(@f_gm_vol*fitinfo.alpha[0]+@f_wm_vol*fitinfo.alpha[1]+@f_csf_vol*fitinfo.alpha[2])
	end
	def calculate_relax(fitinfo)
		# When there are no relaxation times availaibe
		# @_r_pa is used and set to 1 
		@r_pa = 1
		# es ist moeglich eine andere water reference zu laden, zum Beispiel mit einer laengeren TR zum fitten search_ref_scan = true
		# dann kann man ueberen einen weitere zeile tr und te von diesem scan setzen 
		# 
		if fitinfo.search_ref_scan && @met.eql?("water") 
			if fitinfo.relax_times[@met].has_key?("tr")
				@tr=fitinfo.relax_times[@met]["tr"][0]
			end
			if fitinfo.relax_times[@met].has_key?("te")
				@te=fitinfo.relax_times[@met]["te"][0]
			end
		end
		# fuer MRSI and wenn ganz spezifisch b1_raw_file nicht leer ist
		# das ist nicht sauber programmiert, weil es ist auch vom rec file ist aber es muss jetzt einfach schnell gehen 
		b1_0to1=1
		if fitinfo.mrsi_scan && !fitinfo.b1_raw_file.empty?
			b1_0to1=@b1raw_per
			#puts "b1 included in relaxation"
		end
		
		# Wenn es eingelesen wurde
		# --------------------------------------------------------------------------------------
		if !(@t1.empty?) && !(@t2.empty?)
				 # mit 9999 zeige ich das mann lit values benuten soll--------------------------------------------------------------------------------------------------------------------------------------------------
				 # die muessen dann da sein
				 if @t1["pa"]==9999 || @t1["csf"]==9999 || @t2["csf"]==9999 || @t2["pa"]==9999
				 # check if somm are 9999
					puts " some read from literature "
					# Hier die verschiedenen Faelle abgreifen
					# Das ist wenn nur T2 bekannt ist : z.B. ICSUGAR
					if @t1["pa"]==9999 && @t1["csf"]==9999 && @t2["csf"]==9999
						puts "   all but t2 pa from lit (gussew) "
						eone=Math.exp(-@tr/fitinfo.relax_times[@met]["gm"][0])
						@r_gm=Math.exp(-@te/@t2["pa"])*(1-eone)/(1-Math.cos(b1_0to1*Math::PI/2)*eone)
				 
						eone=Math.exp(-@tr/fitinfo.relax_times[@met]["wm"][0])
						@r_wm=Math.exp(-@te/@t2["pa"])*(1-eone)/(1-Math.cos(b1_0to1*Math::PI/2)*eone)
				 
						eone=Math.exp(-@tr/fitinfo.relax_times[@met]["csf"][0])
						@r_csf=Math.exp(-@te/fitinfo.relax_times[@met]["csf"][1])*(1-eone)/(1-Math.cos(b1_0to1*Math::PI/2)*eone)
					end
				 
				 else
					#-------------------------------------------------------------------------
					eone=Math.exp(-@tr/@t1["pa"])
					@r_pa=Math.exp(-@te/@t2["pa"])*(1-eone)/(1-Math.cos(b1_0to1*Math::PI/2)*eone)
					# damit ist es moeglich auch fuer wasser r_pa zu definieren
					# das kann dann einfach z.B eine gemessene sein.
					@r_gm=@r_pa
					@r_wm=@r_pa
				 
					# Das ist vielleicht gleich wie "pa" aber das wird im relaxationtimes geregelt
					eone=Math.exp(-@tr/@t1["csf"])
					@r_csf=Math.exp(-@te/@t2["csf"])*(1-eone)/(1-Math.cos(b1_0to1*Math::PI/2)*eone)
				 end
		else
		# Wenn es Informationen gibt dann wird er 
		# Soweit habe ich fuer die metaboliten nur relaxations zeiten fur wm_gm gemischt: pa
		if fitinfo.relax_times.has_key?(@met)
			if fitinfo.relax_times[@met].has_key?("pa")
				# ohne b1
				#@r_pa=Math.exp(-@te/fitinfo.relax_times[@met]["pa"][1])*(1-Math.exp(-@tr/fitinfo.relax_times[@met]["pa"][0]))
				
				eone=Math.exp(-@tr/fitinfo.relax_times[@met]["pa"][0])
				@r_pa=Math.exp(-@te/fitinfo.relax_times[@met]["pa"][1])*(1-eone)/(1-Math.cos(b1_0to1*Math::PI/2)*eone)
				# damit ist es moeglich auch fuer wasser r_pa zu definieren
				# das kann dann einfach z.B eine gemessene sein.
				@r_gm=@r_pa
				@r_wm=@r_pa
				@r_csf=@r_pa
			end
			if fitinfo.relax_times[@met].has_key?("gm")
				# ohne b1
				#@r_gm=Math.exp(-@te/fitinfo.relax_times[@met]["gm"][1])*(1-Math.exp(-@tr/fitinfo.relax_times[@met]["gm"][0]))

				eone=Math.exp(-@tr/fitinfo.relax_times[@met]["gm"][0])
				@r_gm=Math.exp(-@te/fitinfo.relax_times[@met]["gm"][1])*(1-eone)/(1-Math.cos(b1_0to1*Math::PI/2)*eone)
			end
			if fitinfo.relax_times[@met].has_key?("wm")
				# ohne b1
				#@r_wm=Math.exp(-@te/fitinfo.relax_times[@met]["wm"][1])*(1-Math.exp(-@tr/fitinfo.relax_times[@met]["wm"][0]))
				
				eone=Math.exp(-@tr/fitinfo.relax_times[@met]["wm"][0])
				@r_wm=Math.exp(-@te/fitinfo.relax_times[@met]["wm"][1])*(1-eone)/(1-Math.cos(b1_0to1*Math::PI/2)*eone)
			end
			# this is only for the water, since there are no metabolites in the csf
			if fitinfo.relax_times[@met].has_key?("csf")
				#@r_csf=Math.exp(-@te/fitinfo.relax_times[@met]["csf"][1])*(1-Math.exp(-@tr/fitinfo.relax_times[@met]["csf"][0]))
				
				eone=Math.exp(-@tr/fitinfo.relax_times[@met]["csf"][0])
				@r_csf=Math.exp(-@te/fitinfo.relax_times[@met]["csf"][1])*(1-eone)/(1-Math.cos(b1_0to1*Math::PI/2)*eone)
			end
			
		end
	end
	end
	#------------------------------------------------------------------------------------------------------------------------------
	def use_internal_water(fitinfo, water)
		if (!@met.eql?("water") && !@met.eql?("eretic"))
			
				#puts " ERROR if in LCModel WCONC is not set to 55556 and ATTH2O = 1 "
				# die zahl @area ist nichts anderes als wie oft die Flaeche im Basis Set in dem gefitteten spektrum
				# platz hat //viellfaches der basisnorm
				# schon korrigiert fuer anzahl protonen die zu einer resonanz beitragen
				
				# so wird fcalib in LCModel berechnet // darum auch obige Fehlermeldung
				# Basis_norm ist die Flaeche von cre im basis set
				# Basis_norm = area_cre/[N1HMET x Conc_met x ATTMET]
				# fcalib= Basis_norm / Water_norm
				# fcalib= Basis_norm/ area_water/(2*(WCONC=55556)*(ATTH20=1))
				basis_norm=water.fcalib*(water.area/(2*55556*1))
				if fitinfo.mrsi_scan && fitinfo.sim_profile
					# water fit problem im phantom
					# in vivo stimmen die fits überein
					basis_norm=2
				end
				
				#puts "Here beim water Basis Norm: #{basis_norm}"
				# -----------------------------------------------------------------------------
				# - voll relaxierte flaeche des metaboliten // TR= unendl; TE =0
				# @r_pa kann auch eins sein!
				# -----------------------------------------------------------------------------
				area_r=@area/@r_pa  # ist S_obs_m/R_WM/GM in Gleichung
				if fitinfo.relax_times.has_key?(@met)
					if fitinfo.relax_times[@met].has_key?("gm") and fitinfo.relax_times[@met].has_key?("wm")
						# Falls ich gtrennte relaxationszeiten haette, koennte ich das hier machen
						#area_r=
						puts " Not possible yet to use other than pa for relaxation correction"
					end
				end
				
				# -----------------------------------------------------------------------------
				# neu hier oben einmal
				# -----------------------------------------------------------------------------
				if fitinfo.mrsi_scan && fitinfo.sim_profile
					sh2o_r=@sim_mr_mxy/(water.f_gm_mol*water.r_gm+water.f_wm_mol*water.r_wm+water.f_csf_mol*water.r_csf)
				else
					# standard 
					sh2o_r=water.area/(water.f_gm_mol*water.r_gm+water.f_wm_mol*water.r_wm+water.f_csf_mol*water.r_csf) # ist S_obs_H2O/(f_mol_csf *R_CSF+f_mol_gm *R_GM+f_mol_wm *R_WM) in Gleichung
					
					# gussew instead of estimated relaxation times
					# vorsicht hier wird lokal sh2o_berechnet
					# das ist entweder mit relaxation oder gussew
					# beim wasser werden beide abgespeichert
					if fitinfo.get_ref_info == "gussew"
						puts "sh2o_r caluclated with gussew"
						puts "#{water.gussew_ratio}"
						#
						sh2o_r=water.area*water.gussew_ratio
					end
				end
				
				# -----------------------------------------------------------------------------
				# c_wm : Moles of Metabolite per Mass of Brain Water (Excluding CSF) - Molal- mol/kg
				# -----------------------------------------------------------------------------
				
				wM_H2O=0.0180152  # kg/mol
				@c_wm=area_r*basis_norm/(sh2o_r*(1-water.f_csf_mol))*(2/1)*1/wM_H2O
				# -----------------------------------------------------------------------------
				# c_wm_csf : Moles of Metabolite per Mass of Brain Water ( IN THE CSF) - Molal- mol/kg
				# -----------------------------------------------------------------------------
				# This is for example used in Ethanol measurements in the Liquor
				# Das ist metaboliten /pro Wasser im CSF in kg
				# Weiss aber natuerlich nicht genau, wie die anteile von Alkohol im Gewebe ist
				if fitinfo.special_concentrations
					# so war es vorher
					#@c_wm_csf=area_r*basis_norm/(sh2o_r*(water.f_csf_mol))*(2/1)*1/wM_H2O
					@c_wm_csf=area_r*basis_norm/(sh2o_r*((water.f_gm_mol+water.f_wm_mol)*0.6+water.f_csf_mol))*(2/1)*1/wM_H2O
					# Das ist einfach pro kg wasser im gemessen voxel
					@c_wm_tot_H2O=area_r*basis_norm/(sh2o_r)*(2/1)*1/wM_H2O
				end
				# -----------------------------------------------------------------------------
				# c_bv : Moles of Metabolite per Volume of Brain Tissue (Excluding CSF) - Molar
				# -----------------------------------------------------------------------------
				#sh2o_r_plus=water.area/(@f_gm_vol*fitinfo.alpha[0]*water.r_gm+@f_wm_vol*fitinfo.alpha[1]*water.r_wm+@f_csf_vol*fitinfo.alpha[2]*water.r_csf)# ist S_obs_H2O/(f_mol_csf a_csf*R_CSF+f_mol_gm*a_gm*R_GM+f_mol_wm*a_wm*R_WM) in Gleichung
				#c_H2O=55.126 # mol/l at 37.8 Celsius (Dichte: 0.993112) / (0.018015 kg/mol) 
				#
				#@c_bv_H2O=area_r*basis_norm/(sh2o_r_plus*(1-water.f_csf_vol))*(2/1)*c_H2O
				# -----------------------------------------------------------------------------
				# c_bv : Moles of Metabolite per Volume of Brain Tissue (Excluding CSF) - Molar
				# Die folgenden Gleichungen sind identisch mit denen oben  mit sh20_r_plus
				# -----------------------------------------------------------------------------
				c_H2O=55.126 # mol/l at 37.8 Celsius (Dichte: 0.993112) / (0.018015 kg/mol) 
				#
				@c_bv_H2O=area_r*basis_norm/(sh2o_r)*1/(1-water.f_csf_vol)*(2/1)*c_H2O*(@f_gm_vol*fitinfo.alpha[0]+@f_wm_vol*fitinfo.alpha[1]+@f_csf_vol*fitinfo.alpha[2])
				#
				#test
				# save the full relaxed water used to calculate 
				@sh2o_r=sh2o_r
		end
		if (@met.eql?("water"))
		    # noch nicht bearbeitet:
			# hier schreibe ich einfach die mit der Segmentierung erwartete Wasserkonzentration 
			# total concentration of the water in the total voxel mol/l
			@h2o=55.126*(@f_gm_vol*fitinfo.alpha[0]+@f_wm_vol*fitinfo.alpha[1]+@f_csf_vol*fitinfo.alpha[2])
			# Waere es interessant die wasser concentration pro brainvolume( minus csf)?
			#
			# Fully relaxed water gemaess gasparovic
			# Das ist das voll relaxierte wassersignal
			# nur moeglich mit info von segmentierung
			@sh2o_r=@area/(@f_gm_mol*@r_gm+@f_wm_mol*@r_wm+@f_csf_mol*@r_csf)
			
			# gussew instead of estimated relaxation times
			if fitinfo.get_ref_info == "gussew"
				puts "sh2o_gr caluclated with gussew"
				puts "#{@gussew_ratio}"
				#
				@sh2o_gr=@area*@gussew_ratio
			end
			
			# Diskussion
			# Wie muss ich genau die @h20 pro brainmass?
			# @h2o=55556*(@f_gm_vol*fitinfo.alpha[0]+@f_wm_vol*fitinfo.alpha[1])/(1-@f_csf_vol)
		end
	end
	#------------------------------------------------------------------------------------------------------------------------------
	def use_internal_creatine(fitinfo, creatine)
		if (!@met.eql?("eretic"))
			if creatine.area==0
				@to_cre_corr=sprintf('%.4f',0.0)
			else
				# ---------------------------------------------------------------------------------------------------
				# c_bv_Cr : Moles of Metabolite per Volume of Brain Tissue (Excluding CSF) - Molar determined with Cr
				# ---------------------------------------------------------------------------------------------------
				# Wrong values
				# Konzentration mol/l Creatine GM
				#c_Cr_GM= 0.00959
				c_Cr_GM= 0.00825
				#c_Cr_GM= 1
				# Konzentration mol/l Creatine WM
				#c_Cr_WM= 0.00483
				c_Cr_WM= 0.00447
				#c_Cr_WM= 1
				if (!@met.eql?("water"))
					c_bv_Cr=@area/creatine.area*(creatine.r_pa/@r_pa)*(@f_gm_vol*c_Cr_GM+@f_wm_vol*c_Cr_WM)/(@f_gm_vol+@f_wm_vol)
				else
					#water
					# noch unsicher
					basis_norm=@fcalib*(@area/(2*55556*1))
					#-
					sh2o_r=@area/(@f_gm_mol*@r_gm+@f_wm_mol*@r_wm+@f_csf_mol*@r_csf)
					#-
					c_bv_Cr=sh2o_r/(creatine.area*basis_norm)*1/2*(creatine.r_pa)*(@f_gm_vol*c_Cr_GM+@f_wm_vol*c_Cr_WM)/(@f_gm_vol+@f_wm_vol)*(1-@f_csf_vol)
					#-*(1-@f_csf_vol) weil wasser von ueberall und cre nur von GM WM
				end
				# Formel ergaent mit (@f_gm_vol+@f_wm_vol)
				#@c_bv_Cr=sprintf('%.4f',c_bv_Cr)
				@c_bv_Cr=c_bv_Cr
			end
		end			
		
	end
	#------------------------------------------------------------------------------------------------------------------------------
	def use_eretic(fitinfo, eretic, normalized_area)
		# normalied area is 1 if there is no calibration
		# then eretic_calib_conc should be 1
		if fitinfo.mrsi_scan
		#not updated 2014
			if( fitinfo.relax_times.has_key?(@met))
				if @met.eql?("water")
					#
					# ö/2*S_water/S_eretic=[M]_water wobei ö übersetzung der eretic S ist hier noch 1
					# S_water aber nur aus GM und WM 
					#@c_bv_eretic=sprintf('%.5f',@area/eretic.area*(1-@f_csf_mol)/(2*(1-eretic.f_csf_vol)*(@f_gm_mol*@r_gm+@f_wm_mol*@r_wm+@f_csf_mol*@r_csf)))
					@c_bv_eretic=sprintf('%.5f',@area*(1-@f_csf_mol)/(@f_gm_mol*@r_gm+@f_wm_mol*@r_wm+@f_csf_mol*@r_csf))
				else
					#@to_eretic=sprintf('%.5f',@conc/eretic.conc)
					@c_bv_eretic=sprintf('%.5f',@area*1/(1-@f_csf_vol)*1/@r_pa)
				end
			else
				@c_bv_eretic=sprintf('%.5f',@area*1/(1-@f_csf_vol))
			end
		else
			if(!@met.eql?("eretic"))
				# Stand MCERETIC 2013
				# Wenn keine Aquivalenten Concentrationen vorhanden sind dann ist @eretic_normalized_calib_conc =1
				# ansonsten ist dort die Konzentration des ERETIC peaks dividiert durch die Fläche des Cre Spektrums im Basisset
				if @met.eql?("water")
					# Fuer Wasser 
					# Basis_norm ist die Flaeche von cre im basis set
					# Basis_norm = area_cre/[N1HMET x Conc_met x ATTMET]
					# fcalib= Basis_norm / Water_norm
					# fcalib= Basis_norm/ area_water/(2*(WCONC=55556)*(ATTH20=1))
					
					# eigentlich kann ich (eretic.to_water)^-1 benutzen
					# eretic.to_water=@area*fcalib=@area*Basis_norm/area_water/(2*55556*1)
					# davon das inverse und die konzentration von wasser brauche ich nicht ersetze ich durch @eretic_normalized_calib_conc*normalized_area
					# normalized_area wegen unterschiedlicher basis sets invivo phantom.
					# die zwei steht weil 2 protonen fuers wasser dass muss ich im fall der metaboliten nicht machen da das in lcmodel schon getan wird
					# fully relaxed water
					# basis_norm=@fcalib*(@area/(2*55556*1))
					# Fully relaxed water
					#-
					sh2o_r=@area/(@f_gm_mol*@r_gm+@f_wm_mol*@r_wm+@f_csf_mol*@r_csf)
					#-
					#sh2o_r=@area/(@f_gm_vol*fitinfo.alpha[0]*@r_gm+@f_wm_vol*fitinfo.alpha[1]*@r_wm+@f_csf_vol*fitinfo.alpha[2]*@r_csf)
					#frueher habe ich hier noch eine rechnerei mit basis_norm und normalized area gehabt, die sind aber gleich
					# version war so
					# c_bv_eretic=sh2o_r/(eretic.area*basis_norm*2)*@eretic_normalized_calib_conc*normalized_area
					# wenn die gleich sind, was der fall ist, streichen sich die raus, und es bleibt
					#
					#-------------------------------------------------------------------
					#orig
					@c_bv_eretic=sh2o_r/(eretic.area*2)*@eretic_normalized_calib_conc
					#-------------------------------------------------------------------
					#test
					#@c_bv_eretic=@area/(eretic.area*2)*@eretic_normalized_calib_conc	
				else
					#Metaboliten
					#voll relaxiertes signal/flaeche
					area_r=@area/@r_pa
					# partial volume correction
					# 1/(1-eretic.f_csf_vol)   // warum f_csf_vol und nicht f_csf?
					#------------------------------------------------------------------------------------------------------
					#@c_bv_eretic=area_r/eretic.area*1/(1-eretic.f_csf_vol)*@eretic_normalized_calib_conc*normalized_area
					@c_bv_eretic=area_r/eretic.area*1/(1-eretic.f_csf_vol)*@eretic_normalized_calib_conc*normalized_area
					#------------------------------------------------------------------------------------------------------
					#puts " normalized area #{normalized_area}"
					#Muss es noch mal normalized_area sein?
				end
				if fitinfo.receive_sensitivity
					@cR_bv_eretic=@c_bv_eretic/@receive_scaled
				end
			end	
			
		end
		
	end
	#----------------------------------------
	# Drive Scale
	#----------------------------------------
	def use_ds(fitinfo, normalized_area)
		# normalied area is 1 if there is no calibration
		# then eretic_calib_conc should be 1
		# at some point I should implement that the normalized_area is calculated as in the use_internal_water
		# normalized area is the same as basis_norm
		# basis_norm=water.fcalib*(water.area/(2*55556*1))
		
		if(!@met.eql?("eretic"))
			# Stand 2015
			# Wenn keine Aquivalenten Concentrationen vorhanden sind dann ist @ds_normalized_calib_conc =1
			if @met.eql?("water")
				# Fuer Wasser 
				# Fully relaxed water (ist das richtig ohne alpha?)
				if fitinfo.mrsi_scan && fitinfo.sim_profile
					# water fit problem im phantom
					# in vivo stimmen die fits überein
					sh2o_r=@sim_mr_mxy/(@f_gm_mol*@r_gm+@f_wm_mol*@r_wm+@f_csf_mol*@r_csf)
				else
					sh2o_r=@area/(@f_gm_mol*@r_gm+@f_wm_mol*@r_wm+@f_csf_mol*@r_csf)
				end
				if !fitinfo.calib_conc_ds
					@ds_normalized_calib_conc=1
				end
				
				#sh2o_r=@area/(@f_gm_vol*fitinfo.alpha[0]*@r_gm+@f_wm_vol*fitinfo.alpha[1]*@r_wm+@f_csf_vol*fitinfo.alpha[2]*@r_csf)
				#-------------------------------------------------------------------
				
				@c_bv_DS=sh2o_r*@drive_scale*1/2*@ds_normalized_calib_conc
				#-------------------------------------------------------------------
				if fitinfo.phantom_profile
					#normal
					#@cPR_bv_DS=sh2o_r*@drive_scale*1/2*1/(@mxy_phantom*0.9516)*1/0.413632*55.395*2
					#sharp refo
					@cPR_bv_DS=sh2o_r*@drive_scale*1/2*1/(@mxy_phantom*0.9516)*1/0.4127*55.395*2
				end
			else
				#Metaboliten
				#voll relaxiertes signal/flaeche
				area_r=@area/@r_pa
				# partial volume correction
				# 1/(1-eretic.f_csf_vol)   // warum f_csf_vol und nicht f_csf?
				if fitinfo.sim_profile && fitinfo.mrsi_scan
					# hier lese ich das wasser vom selber gefitteten ein, weil ich bei LCModel Phantom fits Fehler gesehen habe
					# invivo macht es dasselbe, aber ich brauch hier dann trotzdem keine normalied_area mehr
					normalized_area=2
					# 2 is wegen Anzahl spins pro Wasser
				end
				if !fitinfo.calib_conc_ds
					@ds_normalized_calib_conc=1
				end
				#------------------------------------------------------------------------------------------------------
				@c_bv_DS=area_r*@drive_scale*1/(1-@f_csf_vol)*@ds_normalized_calib_conc*normalized_area
				#------------------------------------------------------------------------------------------------------
				if fitinfo.special_concentrations
					# Das ist einfach pro Volumen
					@c_totvol_DS=area_r*@drive_scale*@ds_normalized_calib_conc*normalized_area 
					# Dann brauche ich aber auch noch etwas in Gewicht Wasser?
				end
				#@c_bv_DS=area_r*0.413632*1/(1-@f_csf_vol)*@ds_normalized_calib_conc*normalized_area
				#puts "ACHTUNG ACHTUNG nur fuer nods"
				if fitinfo.phantom_profile
					#normal
					#@cPR_bv_DS=area_r*@drive_scale*1/(1-@f_csf_vol)*normalized_area*1/(@mxy_phantom*0.9516)*1/0.413632*55.395*2
					#sharp refo
					@cPR_bv_DS=area_r*@drive_scale*1/(1-@f_csf_vol)*normalized_area*1/(@mxy_phantom*0.9516)*1/0.4127*55.395*2
				end
				
			end
			if fitinfo.receive_sensitivity
				@cR_bv_DS=@c_bv_DS*@receive_ratio
			end
			if fitinfo.sim_profile
				# Wenn es ein Simuliertes Profil ( eigentlich erwartetes signal) gibt dann so
				# dass beinhaltet Reception, B1 und Pulse Profil
				@cS_bv_DS=@c_bv_DS/@sim_abs_mxy
			end
			
		end	
	
	end
	def use_ds_body_water(fitinfo, water, normalized_area)
		# this is used when body coil is used for transmit and other coil to receive
		# normalied area is 1 if there is no calibration
		# then eretic_calib_conc should be 1
		#
		# ratio_qbc_sense calculated here
		# when used water reference is not acquired with same te tr as qbc take other given in file 
		#
		ratio_qbc_sense=water.qbc_water_area/water.area
		if fitinfo.sense_water_ds 
			ratio_qbc_sense=water.qbc_water_area/@sense_water_area
		end
		#
		if(!@met.eql?("eretic"))
			# Stand 2015
			# Wenn keine Aquivalenten Concentrationen vorhanden sind dann ist @ds_normalized_calib_conc =1
			if @met.eql?("water")
				# Fuer Wasser 
				# Fully relaxed water (ist das richtig ohne alpha?)
				sh2o_r=@area/(@f_gm_mol*@r_gm+@f_wm_mol*@r_wm+@f_csf_mol*@r_csf)
				#sh2o_r=@area/(@f_gm_vol*fitinfo.alpha[0]*@r_gm+@f_wm_vol*fitinfo.alpha[1]*@r_wm+@f_csf_vol*fitinfo.alpha[2]*@r_csf)
				
				# gussew instead of estimated relaxation times
				# vorsicht hier wird lokal sh2o_berechnet
				# das ist entweder mit relaxation oder gussew
				# beim wasser werden beide abgespeichert
				if fitinfo.get_ref_info == "gussew"
					 puts "sh2o_r caluclated with gussew"
					 puts "#{@gussew_ratio}"
					 #
					 sh2o_r=@area*@gussew_ratio
				end
				#-------------------------------------------------------------------
				
				
				
				#-------------------------------------------------------------------
				#orig
				#@c_bv_DS=sh2o_r/@area*@qbc_water_area*@drive_scale*1/2*@ds_normalized_calib_conc
				@c_bv_DS=sh2o_r*ratio_qbc_sense*@drive_scale*1/2*@ds_normalized_calib_conc
				
				# So this is at then end just:
				#sh2o_qbc_r=@qbc_water_area/(@f_gm_mol*@r_gm+@f_wm_mol*@r_wm+@f_csf_mol*@r_csf)
				#c_bv_DS=sh2o_qbc_r*@drive_scale*1/2*@ds_normalized_calib_conc
				# i just write it down like that to clearify that it is the same as for the metabolites
				# but this only works if te and tr of the qbc scan are equal (make a test).
				#---------------------------------------------------------------------------------
				# das oben ist richtig wenn
				# - der water scan mit gleichen settings aufgenommen tr und te wurde wie der qbc scan
				# - mit gussew geht das im allgemeinen nicht
				# darum lade ich dem Fall den sense separat rein

				if fitinfo.special_concentrations
					# Das ist einfach pro Volumen
					# Fuer Wasser ist das gleiche
					@c_totvol_DS=@c_bv_DS
				end		
				
				
			else
				#puts " ERROR if in LCModel WCONC is not set to 55556 and ATTH2O = 1 "
				# die zahl @area ist nichts anderes als wie oft die Flaeche im Basis Set in dem gefitteten spektrum
				# platz hat //viellfaches der basisnorm
				# schon korrigiert fuer anzahl protonen die zu einer resonanz beitragen
				
				# so wird fcalib in LCModel berechnet // darum auch obige Fehlermeldung
				# Basis_norm ist die Flaeche von cre im basis set
				# Basis_norm = area_cre/[N1HMET x Conc_met x ATTMET]
				# fcalib= Basis_norm / Water_norm
				# fcalib= Basis_norm/ area_water/(2*(WCONC=55556)*(ATTH20=1))
				basis_norm=water.fcalib*(water.area/(2*55556*1))
				#puts "Basis Norm: #{basis_norm} ist gleich wie normalized_area: #{normalized_area} "
				# -----------------------------------------------------------------------------
				# - voll relaxierte flaeche des metaboliten // TR= unendl; TE =0
				# @r_pa kann auch eins sein!
				# -----------------------------------------------------------------------------
				area_r=@area/@r_pa  # ist S_obs_m/R_WM/GM in Gleichung
				if fitinfo.relax_times.has_key?(@met)
					if fitinfo.relax_times[@met].has_key?("gm") and fitinfo.relax_times[@met].has_key?("wm")
						# Falls ich gtrennte relaxationszeiten haette, koennte ich das hier machen
						#area_r=
						puts " Not possible yet to use other than pa for relaxation correction"
					end
				end
				
				
				# -----------------------------------------------------------------------------
				# c_bv : Moles of Metabolite per Volume of Brain Tissue (Excluding CSF) - Molar
				# neuer versuch die sind identisch!
				# -----------------------------------------------------------------------------
				# before ratio
				#@c_bv_DS=area_r/water.area*water.qbc_water_area*@drive_scale*1/(1-@f_csf_vol)*@ds_normalized_calib_conc*normalized_area
				@c_bv_DS=area_r*ratio_qbc_sense*@drive_scale*1/(1-@f_csf_vol)*@ds_normalized_calib_conc*normalized_area
				if fitinfo.special_concentrations
					# Das ist einfach pro Volumen
					#@c_totvol_DS=area_r/water.area*water.qbc_water_area*@drive_scale*@ds_normalized_calib_conc*normalized_area
					@c_totvol_DS=area_r*ratio_qbc_sense*@drive_scale*@ds_normalized_calib_conc*normalized_area
					# Dann brauche ich aber auch noch etwas in Gewicht Wasser?
					d_H2O=0.993112  # kg/l
					density_in_voxel=d_H2O*(@f_gm_vol*fitinfo.alpha[0]+@f_wm_vol*fitinfo.alpha[1]+@f_csf_vol*fitinfo.alpha[2])
					#puts density_in_voxel
					#@c_wm_tot_DS=area_r/water.area*water.qbc_water_area*@drive_scale*@ds_normalized_calib_conc*normalized_area*1/density_in_voxel
					@c_wm_tot_DS=area_r*ratio_qbc_sense*@drive_scale*@ds_normalized_calib_conc*normalized_area*1/density_in_voxel
					# Dann brauche ich aber auch noch etwas in Gewicht Wasser?
				end
			end
			if fitinfo.receive_sensitivity
				@cR_bv_DS=@c_bv_DS*@receive_ratio
			end
		end	
	
	end
	# Calibration--------------------------------------------------------------------------------------------------------------------
	def eretic_calibration(fitinfo, eretic,normalized_area_basis)
		# Temperaturkorrektur siehe Tofts
		# 0.9452 20 273.2+T/310.2
		# 0.9516 22
		# 0.9549 23
		# eretic_calib_conc ist die equivalente concentration at 37 C
		#original
		# das ist die fuer invivo bei
		if !@met.eql?("water")
			# das ist die fuer im phantom
			@eretic_calib_conc=eretic.area/@area*fitinfo.ref_conc[@met]
			area_37C_fully_relaxed=@area/@r_pa*0.9516
			# wird noch mit der area des singlets im basis set normalisiert
			@eretic_normalized_calib_conc=eretic.area/(area_37C_fully_relaxed)*fitinfo.ref_conc[@met]/normalized_area_basis
		else
			#puts " normalized area #{normalized_area_basis}"
			#old 
			#@eretic_calib_conc=eretic.to_water*fitinfo.ref_conc[@met]
			@eretic_calib_conc=eretic.area/@area*fitinfo.ref_conc[@met]
			# not useful yet	
			puts "Position Correction"
			area_37C_fully_relaxed=@area/@r_pa*0.9516
			#puts area_37C_fully_relaxed
			# so wie ich es hatte
			#@eretic_normalized_calib_conc=eretic.to_water*fitinfo.ref_conc[@met]*1/0.9516*@r_pa
			puts "Position Correction *1.14"
			@eretic_normalized_calib_conc=eretic.area/(area_37C_fully_relaxed)*fitinfo.ref_conc[@met]*2*1.14
			# versuch
			#@eretic_normalized_calib_conc=eretic.to_water*fitinfo.ref_conc[@met]*1/0.9516*@r_pa
		end
		
		
	end
	# Drive Scale Calibration
	#-------------------------
	def ds_calibration(fitinfo,normalized_area_basis)
		if !@met.eql?("water")
			# das ist die fuer im phantom
			#@ds_calib_conc=eretic.area/@area*fitinfo.ref_conc[@met]
			area_37C_fully_relaxed=@area*0.9516/@r_pa
			# wird noch mit der area des singlets im basis set normalisiert
			@ds_normalized_calib_conc=1/(area_37C_fully_relaxed)*1/(@drive_scale)*fitinfo.ref_conc[@met]/normalized_area_basis
		else
			#old 
			if fitinfo.mrsi_scan && fitinfo.sim_profile
				puts " water from MRecon fit used"
				# mit lcmodel habe ich nie gute phantom fits bekommen
				# lese die eigenen fits mit MRECON ueber das simulierte profil text file ein
				# sim_mr_mxy
				area_37C_fully_relaxed=@sim_mr_mxy/sim_abs_mxy*0.9516/@r_pa
				#area_37C_fully_relaxed=@sim_mr_mxy*0.9516/@r_pa
			
			else
				# ohne mrsi und wenn keine simuliertes profil vorhanden ist 
				area_37C_fully_relaxed=@area*0.9516/@r_pa
			end
			#puts area_37C_fully_relaxed
			#
			@ds_normalized_calib_conc=1/(area_37C_fully_relaxed)*1/(@drive_scale)*fitinfo.ref_conc[@met]*2
		end
		
		
	end
	#------------------------------------------------------------------------------------------------------------------------------
	def calculate_area(fitinfo,fcalib, debug)
		#wenn wasser vorhanden, dann ist fcalib ungleich 1
		case @met
			when "water"
				@area=@conc
				#neu
				@to_water=1
			when "eretic"
				if fitinfo.seperate_eretic
					if debug
						puts "ERETIC peak fitted seperately, attention fcalib "
						puts "  fcalib: #{fcalib}"
					end
					@area=@conc
					@to_water=@conc*fcalib
				else
					# wie unten 
					@area=@conc/fcalib
					@to_water=@conc
				end
			else
				#@area=sprintf('%.4f',@conc/fcalib)
				@area=@conc/fcalib
				#@to_water=sprintf('%.4f',@conc)
				@to_water=@conc
		end
			
		# if @met.eql?("water")
			# #@area=sprintf('%.4f',@conc)
			# @area=@conc
		# else
			# #@area=sprintf('%.4f',@conc/fcalib)
			# @area=@conc/fcalib
			# #@to_water=sprintf('%.4f',@conc)
			# @to_water=@conc
		# end
	end
	#---------------------------------------------------
	def simple_ratio_to_eretic(area_eretic)
		#only call after calculate area
		#@to_eretic=sprintf('%.5f',@area/area_eretic)
		@to_eretic=@area/area_eretic
	end
	#---------------------------------------------------
	def simple_ratio_to_cre(area_creatine)
		#only call after calculate area
		if area_creatine ==0.0
			# neu fuer neuer output
			#@to_cre=sprintf('%.5f',0.0)
			@to_cre=0.0
		else
			#@to_cre=sprintf('%.5f',@area/area_creatine)
			@to_cre=@area/area_creatine
		end
	end
	#---------------------------------------------------
	#
	def write_to_file_table_one(file,column_names)
		
		for i in 0..(column_names.size-1)
			if column_names[i].eql?("date_scan")
				 eval("file.write @#{column_names[i]}[0]")
				 file.write "."
				 eval("file.write @#{column_names[i]}[1]")
			 else
				 eval("file.write @#{column_names[i]}")
			 end
			 file.write ";"
		 end
		 file.write "\n"
	end
	
	def write_to_file_table_two(file,column_names)
		
		for i in 0..(column_names.size-1)
			if column_names[i].eql?("date_scan")
				#puts "#{@date_scan[0]}.#{@date_scan[1]}"
				 eval("file.write @#{column_names[i]}[0]")
				 file.write "."
				 eval("file.write @#{column_names[i]}[1]")
			 else
				#if @sd.to_f < 50
					eval("file.write @#{column_names[i]}")
				#else
				#	file.write ""
				#end
			 end
			 file.write ";"
		 end
	end


end

class MetaboliteInfo
# Information about one metabolite (over all scans)
	attr_accessor 		:name,\
						:mean_sd,\
						:column_names_general,\
						:column_names_met,\
						:column_names,\
						:info_area,\
						:info_to_water,\
						:info_to_cre
						
						
	def initialize(name)

		@name				= name
		@mean_sd			= 999
		@column_names_general	= Array.new
		@column_names_met	= Array.new
		@column_names		= Array.new
		#
		@info_area			=[0,0,0,0]
		@info_to_water		=[0,0,0,0]
		@info_to_cre		=[0,0,0,0]
	end
	
	#
	# Das ist fuer die Tabellenform:
	# Metaboliten untereinander
	#
	def create_column_names(fitinfo,water,eretic,cre)
		ciln=Array.new
		ciln[ciln.count]	=	"date_scan"
		ciln[ciln.count]	=	"nr_patient"		# speperate eretic depends on this order nr_patient name_scan nr_scan
		ciln[ciln.count]	=   "name_scan"
		ciln[ciln.count]	=   "nr_scan"
		ciln[ciln.count]	=   "filename"
		ciln[ciln.count]	=   "name_patient"
		ciln[ciln.count]	=   "position"
		ciln[ciln.count]	=   "samples"
		# for Ketamin
		ciln[ciln.count]	=   "exam_name"
		#
		if fitinfo.use_misc_info
			ciln[ciln.count]	=	"fwhm_hz"
			#ciln[ciln.count]	=	"fwhm_ppm"
			ciln[ciln.count]	=	"snr"
			ciln[ciln.count]	=	"data_shift"
			ciln[ciln.count]	=	"zero_phase"
			ciln[ciln.count]	=	"first_phase"
		end
		# voi
		ciln[ciln.count]	=   "voi_vol"
		ciln[ciln.count]	=   "voi_ap"
		ciln[ciln.count]	=   "voi_lr"
		ciln[ciln.count]	=   "voi_cc"
		#
		ciln[ciln.count]	=   "offcenter_ap"
		ciln[ciln.count]	=   "offcenter_lr"
		ciln[ciln.count]	=   "offcenter_cc"
		#
		ciln[ciln.count] = "dist_voxel_coil"
		#
		if fitinfo.mrsi_scan
			ciln[ciln.count]	=	"row"
			ciln[ciln.count]	=	"col"
		end
		#
		ciln[ciln.count]	=   "area"
		ciln[ciln.count] 	=	"sd"
		#ratios
		if water
			#  area_to_water or fcalib 
			ciln[ciln.count]	= @name.eql?("water") ? "fcalib" : "to_water"
			if fitinfo.segmentation
				ciln[ciln.count]="c_wm"
				ciln[ciln.count]="c_bv_H2O"
			end
		end
		if eretic
			ciln[ciln.count] =	"to_eretic"
			if fitinfo.segmentation
				ciln[ciln.count]="c_bv_eretic"
			end
		end
		if fitinfo.calib_conc_eretic
			ciln[ciln.count] = "eretic_calib_conc"
		end
		if cre 
			ciln[ciln.count] =	"to_cre"
			if fitinfo.segmentation
				ciln[ciln.count]="c_bv_Cr"
			end
		end
		# important to show
		ciln[ciln.count] =	"r_pa"
		if fitinfo.phantom
			if eretic
				ciln[ciln.count] =	"eretic_calib_conc"
				ciln[ciln.count] =	"eretic_normalized_calib_conc"
			end
			if fitinfo.drive_scale
				ciln[ciln.count] =	"ds_normalized_calib_conc"
			end
		end
		# receive sensitivity so far only read for water
		if fitinfo.receive_sensitivity
			ciln[ciln.count]="receive"
			ciln[ciln.count]="receive_scaled"
			ciln[ciln.count]="receive_b1map"
			ciln[ciln.count]="receive_ratio"
		end
		# profile
		if fitinfo.sim_profile
			ciln[ciln.count]="sim_mr_mxy"
			ciln[ciln.count]="sim_abs_mxy"
		end
		# segmentation
		if fitinfo.segmentation
			ciln[ciln.count]	=	"f_gm_vol"
			ciln[ciln.count]	=	"f_wm_vol"
			ciln[ciln.count]	=	"f_csf_vol"
			ciln[ciln.count]	=	"f_gm_mol"
			ciln[ciln.count]	=	"f_wm_mol"
			ciln[ciln.count]	=	"f_csf_mol"
			ciln[ciln.count]	=	"r_gm"
			ciln[ciln.count]	=	"r_wm"
			ciln[ciln.count]	=	"r_csf"
			ciln[ciln.count]	=	"h2o"
			ciln[ciln.count]	=	"sh2o_r"
		end
		# b1map
		if fitinfo.b1map
			if !fitinfo.b1_raw_file.empty?
				ciln[ciln.count]="b1raw_per"
				#ciln[ciln.count]="b1raw_cf"
			end
			if !fitinfo.b1_rec_file.empty?
				ciln[ciln.count]="b1rec_per"
				ciln[ciln.count]="b1rec_max"
				ciln[ciln.count]="b1rec_cf"
			end
		end
		#
		if fitinfo.drive_scale
			if fitinfo.segmentation
				ciln[ciln.count]="c_bv_DS"
				if fitinfo.receive_sensitivity
					ciln[ciln.count]="cR_bv_DS"
				end
				if fitinfo.sim_profile
					ciln[ciln.count]="cS_bv_DS"
				end
			end
			ciln[ciln.count]="drive_scale"
			ciln[ciln.count]="one_over_drive"
		end
		if fitinfo.calib_conc_ds
			ciln[ciln.count] = "ds_normalized_calib_conc"
		end
		#
		if fitinfo.mrecon_area
				ciln[ciln.count]="mrecon_w"
				ciln[ciln.count]="mrecon_td_w"
				ciln[ciln.count]="mrecon_e"
		end
		# metabolite
		ciln[ciln.count] 	=   "met"
		
		#
		@column_names =ciln
	end
	#---------------------------------------------------------------
	# Das ist fuer die Tabellenform:
	# Metaboliten nebeneinander
	#
	def create_column_names_general(fitinfo,water,eretic,cre)
		ciln=Array.new
		ciln[ciln.count]	=	"date_scan"
		ciln[ciln.count]	=	"nr_patient"					# speperate eretic depends on this order nr_patient name_scan nr_scan
		ciln[ciln.count]	=   "name_scan"
		ciln[ciln.count]	=   "nr_scan"
		ciln[ciln.count]	=   "filename"
		ciln[ciln.count]	=   "name_patient"
		# for Ketamin
		ciln[ciln.count]	=   "exam_name"
		#ciln[ciln.count]	=   "tr"
		ciln[ciln.count]	=   "te"
		ciln[ciln.count]	=   "samples"
		ciln[ciln.count]	=   "position"
		#
		if !fitinfo.add_info.empty?
			fitinfo.add_info_result.each{|key, value| 
			ciln[ciln.count]= "#{key}"
			}
		end
		#
		ciln[ciln.count]	=	"par_fwhm_hz"
		ciln[ciln.count]	=	"par_fwhm_hz_2"
		#
		if fitinfo.use_misc_info
			ciln[ciln.count]	=	"fwhm_hz"
			ciln[ciln.count]	=	"fwhm_ppm"
			ciln[ciln.count]	=	"snr"
			ciln[ciln.count]	=	"data_shift"
			ciln[ciln.count]	=	"zero_phase"
			ciln[ciln.count]	=	"first_phase"
		end
		
		# voi volume im mm^3
		ciln[ciln.count]	=   "voi_vol"
		ciln[ciln.count]	=   "voi_ap"
		ciln[ciln.count]	=   "voi_lr"
		ciln[ciln.count]	=   "voi_cc"
		#
		ciln[ciln.count]	=   "offcenter_ap"
		ciln[ciln.count]	=   "offcenter_lr"
		ciln[ciln.count]	=   "offcenter_cc"
		ciln[ciln.count] = "dist_voxel_coil"
		#
		if fitinfo.mrsi_scan
			ciln[ciln.count]	=	"row"
			ciln[ciln.count]	=	"col"
		end
		# segmentation
		if fitinfo.segmentation
			ciln[ciln.count]	=	"f_gm_vol"
			ciln[ciln.count]	=	"f_wm_vol"
			ciln[ciln.count]	=	"f_csf_vol"
			ciln[ciln.count]	=	"f_gm_mol"
			ciln[ciln.count]	=	"f_wm_mol"
			ciln[ciln.count]	=	"f_csf_mol"			
		end
		# b1map
		if fitinfo.b1map
			if !fitinfo.b1_raw_file.empty?
				ciln[ciln.count]="b1raw_per"
				#ciln[ciln.count]="b1raw_cf"
			end
			if !fitinfo.b1_rec_file.empty?
				ciln[ciln.count]="b1rec_per"
				ciln[ciln.count]="b1rec_max"
				ciln[ciln.count]="b1rec_cf"
			end
		end
		# profile
		if fitinfo.sim_profile
			ciln[ciln.count]="sim_mr_mxy"
			ciln[ciln.count]="sim_abs_mxy"
		end	
		if fitinfo.phantom_profile
			ciln[ciln.count]="mxy_phantom"
		end
		
		#
		@column_names_general =ciln
	end
	def create_column_names_met(fitinfo,water,eretic,cre)
		ciln=Array.new
		ciln[ciln.count]	=   "tr"
		ciln[ciln.count]	=   "area"
		ciln[ciln.count] 	=	"sd"
		#ratios
		#-----------------------------------
		if water
			#  area_to_water or fcalib 
			ciln[ciln.count]	= @name.eql?("water") ? "fcalib" : "to_water"
			if fitinfo.segmentation
			#puts fitinfo.special_concentrations
				if fitinfo.special_concentrations
					ciln[ciln.count]    =   "c_wm_tot_H2O"
					ciln[ciln.count]    =   "c_wm_csf"
					ciln[ciln.count]	=	"sh2o_r"
					ciln[ciln.count]	=	"h2o"
				else
					ciln[ciln.count]    =   "c_wm"
					ciln[ciln.count]    =   "c_bv_H2O"
					ciln[ciln.count]	=	"sh2o_r"
					ciln[ciln.count]	=	"h2o"
				end
			end
			
			if fitinfo.get_ref_info =="gussew"
				ciln[ciln.count]    = "sh2o_gr"
				ciln[ciln.count]    = "gussew_t2"
				ciln[ciln.count]    = "gussew_ratio"
			end
			#
			ciln[ciln.count]    = "temp_freq_shift"
		end
		if eretic
			ciln[ciln.count] =	"to_eretic"
			if fitinfo.segmentation
				ciln[ciln.count]="c_bv_eretic"
				if fitinfo.receive_sensitivity
					ciln[ciln.count]="cR_bv_eretic"
				end
			end
		end
		if fitinfo.calib_conc_eretic
			ciln[ciln.count] = "eretic_normalized_calib_conc"
		end
		if cre 
			ciln[ciln.count] =	"to_cre"
			if fitinfo.segmentation
				ciln[ciln.count]="c_bv_Cr"
			end
		end
		if fitinfo.drive_scale
			if fitinfo.segmentation
				if !fitinfo.special_concentrations
					ciln[ciln.count]="c_bv_DS"
				else
					ciln[ciln.count]="c_totvol_DS"
					ciln[ciln.count]="c_wm_tot_DS"
				end
				if fitinfo.receive_sensitivity
					ciln[ciln.count]="cR_bv_DS"
				end
				if fitinfo.sim_profile
					ciln[ciln.count]="cS_bv_DS"
				end
				if fitinfo.phantom_profile
					ciln[ciln.count]="cPR_bv_DS"
				end
			end
		end
		if fitinfo.calib_conc_ds
			ciln[ciln.count] = "ds_normalized_calib_conc"
			ciln[ciln.count] = "ds_calib_averaged"
		end
		if fitinfo.qbc_water_ds
			ciln[ciln.count] = "qbc_water_area"
			ciln[ciln.count] = "qbc_drive_scale"
		end
		# important to show because only when this is not 1 something has been done
		# relaxation correction
		#-----------------------------------
		if fitinfo.segmentation
			if @name.eql?("water")
			ciln[ciln.count]	=	"r_gm"
			ciln[ciln.count]	=	"r_wm"
			ciln[ciln.count]	=	"r_csf"
			else
			ciln[ciln.count] =	"r_pa"
			end
		end
		if fitinfo.read_in_relax
			ciln[ciln.count]	=	"t1"
			ciln[ciln.count]	=	"t2"
		end
		#-----------------------------------
		if fitinfo.phantom
			if eretic
			ciln[ciln.count] =	"eretic_normalized_calib_conc"
			end
			
		end
		#areas for ERETIC
		if fitinfo.mrsi_scan
				ciln[ciln.count]="c_bv_eretic"
		end
		if fitinfo.drive_scale
				ciln[ciln.count]="drive_scale"
				ciln[ciln.count]="one_over_drive"
		end
		if fitinfo.mrecon_area
				ciln[ciln.count]="mrecon_w"
				ciln[ciln.count]="mrecon_td_w"
				ciln[ciln.count]="mrecon_e"
		end
		# receive sensitivity so far only read for water
		if fitinfo.receive_sensitivity
			ciln[ciln.count]="receive"
			ciln[ciln.count]="receive_scaled"
			ciln[ciln.count]="receive_b1map"
			ciln[ciln.count]="receive_ratio"
		end
		# metabolite
		#ciln[ciln.count] 	=   "met"
		#
		@column_names_met =ciln
	end
	
	
	
end
