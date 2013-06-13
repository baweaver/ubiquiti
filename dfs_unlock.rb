# DFS Unlocker for a single IP. Can easily be made to run on multiple units
# and I'll be updating it to do so some time later.
# 
# The DFS Unlock script on the unit will return and tell you if it's already
# been unlocked

$DFS_Company = ''
$DFS_Key = ''

$su_user = 'ubnt'
$su_pass = 'ubnt'

ip = ARGV[0]

def dfsunlock(ip)
  begin
    Net::SSH.start(ip, $su_user, :password => $su_pass, :paranoid => false) do |ssh|
      puts "[ ] Unlocking DFS"
      puts "\t" +ssh.exec!("/bin/ubntbox dfs-unlock '#{$DFS_Company}' '#{$DFS_Key}'")
    end
  rescue
    puts "[X] Failed to unlock!"
  end
end

dfsunlock(ip)
