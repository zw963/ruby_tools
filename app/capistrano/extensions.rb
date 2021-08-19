# following method used in rake tasks.
def test_running(cap_pid_file_sym)
  pid_file = fetch(cap_pid_file_sym)
  test("[ -f #{pid_file} ] && kill -0 `cat #{pid_file}`")
end

def pid(cap_pid_file_sym)
  pid_file = fetch(cap_pid_file_sym)
  "`cat #{pid_file}`"
end
