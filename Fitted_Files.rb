class Fitted_Files		
	attr_accessor		:files
	#
	def initialize(filename)
		@files=Array.new
		#
		file_to_read = File.new(filename,"r")
		file_content=file_to_read.readlines
		file_to_read.close		
		#		
		file_content.each{ |line|
			break if line.match(/^(END)/)
			next if line.match(/^(\#)/)					
			if File.exists?(line.chomp)							
				@files[files.count]=line.chomp
			end
		}	
		
	end
end
