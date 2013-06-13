# Ubiquiti Firmware Updater
# -------------------------
# 
# Given an AU IP, updates all subscriber units firmware in sequence

$debug = false 
$firmware_name = "firmware_5.5.4.bin"
$firmware_version = '5.5.4'
$au_username = 'ubnt'
$au_password = 'ubnt'

$su_username = 'ubnt'
$su_password = 'ubnt'
$subs = []
ip = ARGV[0] ? ARGV[0] : '192.168.1.20'


#----------#
# REQUIRES #
#----------#

require 'net/ssh'
require 'net/scp'
require 'timeout'
require 'json'

# Fill with subscriber ips, given sector ip
def fill(ip)
  Net::SSH.start(ip, $au_username, :password => $au_password, :paranoid => false) do |ssh|
    $subs = JSON.parse(ssh.exec!('wstalist')).each.inject([]){ |a,d| a << d["lastip"] }
  end # End NetSSH
end # End Ubiquiti Fill

def run(ip)
  fill(ip)
  $subs.each{ |ip| check_firmware(ip) }
end

#---------------------#
#  AUXILARY METHODS   #
#---------------------#

  def ping(ip)
    system("ping -n 1 -w 1000 #{ip} > NUL")
  end

  def up?(ip)
    ping ip
  end

  def wait(ip)
    until up?(ip)
      sleep 1
      print "."
    end
    puts
  end

#------------------#
# Firmware Updater #
#------------------#
 
  def check_firmware(ip)
    begin
      Net::SSH.start(ip, $su_username, :password => $su_password, :paranoid => false) do |ssh|
        version = ssh.exec!('cat /etc/version | sed \'s/^XM\.v//\'').chomp
        type   = ssh.exec!('iwconfig ath0 | grep Frequency | sed \'s/^.*ncy://\' | sed \'s/\.... GH.*$//\'').chomp
        puts "\n[O] #{ip} - #{type}GHz Unit running XM. v#{version}"
        
        unless version.include? $firmware_version
          sleep until update_firmware(ip)
          puts "  [O] Getting ready to execute! This process normally takes 1:30 to complete" 
          
          begin 
            Timeout::timeout(90){ ssh.exec!('/sbin/ubntbox fwupdate.real -m /tmp/firmware') }
          rescue
            # puts "[ ] Restarting the script now"
            sleep 5
            check_firmware(ip)
          end
          
          wait(ip)
        
        end
      end
    rescue
      print "."
      sleep 5
      check_firmware(ip)
    end
  end

  def update_firmware(ip)
    Net::SCP.start(ip, $su_username, :password => $su_password, :paranoid => false) do |scp|
      scp.upload! $firmware_name, "/tmp/firmware"
      puts "  [O] Firmware Uploaded"
      return true
    end
  end
  
  run(ip)
