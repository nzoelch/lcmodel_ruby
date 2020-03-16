#!/usr/bin/ruby -rubygems

# shall be run on casseri01 only

require 'net/ssh'
require 'net/sftp'

ssh_options = {:auth_methods => ['publickey'], :keys => "#{ENV['HOME']}/.ssh/id_rsa"}
Net::SSH.start('chap02.ethz.ch', 'zoelchn', ssh_options) { |ssh|

	ssh.sftp.connect! { |sftp|

					result = ssh.exec!("ls -l")
					puts result
					 sftp.mkdir! "current_fit"
					 sftp.upload!("/home/zoelchn/LCModel/transfer_dir/test_upload.txt", "")
		
	
	}
}

