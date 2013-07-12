$au_username = 'ubnt'
$au_password = 'ubnt'

$su_username = 'ubnt'
$su_password = 'ubnt'

require 'net/ssh'
require 'net/scp'
require 'timeout'
require 'json'

ip = ARGV[0] ? ARGV[0] : '192.168.1.20'
file = ARGV[1]

# Fill with subscriber ips, given sector ip
def fill(ip)
  Net::SSH.start(ip, $au_username, :password => $au_password, :paranoid => false).inject([]) do |ary,ssh|
    ary << JSON.parse(ssh.exec!('wstalist')).each.inject([]){ |a,d| a << d["lastip"] }
  end
end

def config(subscribers,changes)
  subscribers.each do |sub|
    begin
      hash = {}; changeshash = {}; newhash = {}
    
      puts "  [*] Processing #{sub.ip}"
      Net::SSH.start(sub.ip, $su_username, :password => $su_password, :paranoid => false) do |ssh|
        $base = ssh.exec!("cat /tmp/running.cfg")
      end
      
      puts "    [{] Hashifying Original File"; sleep 2
      
      # Hashify the original file
      hash = hashify($base)
      
      puts "    [}] Hashifying Changes"; sleep 2
      
      # Parse in the changes
      changeshash = hashify(changes)
      
      puts "    [O] Merging Changes"
      newhash = hash.merge(changeshash)
      
      # newhash.each_pair{ |k,v| puts "K: #{k}\nV: #{v || ""}"; sleep 0.2 }
      
      puts "    [+] Creating newfile"
      newfile = ""
      newhash.each_pair{ |k,v| newfile << "#{k}=#{v}\n" }
      
      # newfile.each_line{ |line| puts line; sleep 0.2 }
      
      puts "    [^] Uploading"
      Net::SSH.start(sub.ip, $su_username, :password => $su_password, :paranoid => false) do |ssh|
        # puts "Made it in!"
        
        # puts ssh.exec!("echo 'Hi'")
        ssh.exec!('rm /tmp/changed.cfg') # Delete old Skeletons
        newfile.each_line do |line|
          ssh.exec!("echo '#{line.strip}' >> /tmp/changed.cfg")
        end
        
        puts "    [V] Rebooting Unit"
        ssh.exec!("cfgmtd -f /tmp/changed.cfg -w")
        ssh.exec!("save")
        ssh.exec!("reboot")
      end
      
      puts
    rescue
      puts "    [X] Failed on #{sub.ip}\n"
    end
  end
end

def hashify(file)
  hash = {}

  file.each_line do |line|
    val = line.split '='
    hash[val[0]] = val[1].strip || "" # Short Circuit evaluation in case of no value present.
  end
end

def run 
  config(fill(ip),file)
end
