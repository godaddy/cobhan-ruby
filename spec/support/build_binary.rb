# frozen_string_literal: true

def build_binary(lib_root_path, lib_name)
  file_name = Class.new.extend(Cobhan).library_file_name(lib_name)
  lib_path = File.join(lib_root_path, file_name)

  return if File.exist?(lib_path)

  if ENV.fetch('AUTO_CONFIRM_BUILD', nil) != 'true'
    puts "#{lib_path} is not present, do you want to build it? [y/N]"
    input = $stdin.gets.chomp
    abort('Aborted.') unless input.downcase == 'y'
  end

  Dir.mkdir_p(lib_root_path)
  system("./spec/support/#{lib_name}/build.sh", exception: true)
end
