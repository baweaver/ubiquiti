require 'net/ssh'

$user = 'ubnt'
$password = 'ubnt'
ip = ARGV[0] ? ARGV[0] : '192.168.1.20'

# Get the Frequency of a Ubiquiti Unit
def get_ubnt_freq(ip)
	begin
    # Begin SSH Connection
		Net::SSH.start(ip, $user, :password => $password, :paranoid => false) do |ssh|
      # Unit Name
      name          = ssh.exec!('grep "resolv.host.1.name=" /tmp/running.cfg | cut -d "=" -f 2 | tr -d "\n"')
      # Current Running Frequency
      frequency_raw = ssh.exec!('iwconfig ath0 | grep Frequency | sed \'s/^.*Frequency/Frequency/\' | sed \'s/Hz .*$/Hz/\' | cut -d: -f2').strip
      # Current Running Channel
      chanraw       = ssh.exec!('grep \'radio.1.clksel\' /tmp/system.cfg | cut -d= -f2').strip     
      freq_mhz      = "0"
		
      if frequency_raw.include? 'MHz'
        freq_mhz = frequency_raw.to_i.to_s
      else
        freq_mhz = (frequency_raw.to_f * 1000).to_i.to_s
      end

      # UBNT information is sparse, and the only noticeable settings are these ones.
      case chanraw
      when '1'
        chan = 'Auto 20/40 MHz'
      when '2'
        chan = '10'
      when '4'
        chan = '5'
      else
        chan = 'unknown'
      end

      puts "#{ip}, #{name}, #{freq_mhz}, #{chan}" 
    end # End SSH
    
	rescue
		puts "#{ip}, COMM ERROR, 0, 0"
	end
end

get_ubnt_freq(ip)
