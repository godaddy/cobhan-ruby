def measure_time
  start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  yield
  finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  finish - start
end
