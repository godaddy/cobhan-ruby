def build_binary(lib_root_path, lib_name)
  file_name = Class.new.extend(Cobhan).library_file_name(lib_name)
  lib_path = File.join(lib_root_path, file_name)

  unless File.exist?(lib_path)
    if ENV['AUTO_CONFIRM_BUILD'] != 'true'
      puts "#{lib_path} is not present, do you want to build it? [y/N]"
      input = STDIN.gets.chomp
      abort("Aborted.") unless input.downcase == "y"
    end

    Dir.mkdir(lib_root_path) unless File.exist?(lib_root_path)
    system("./spec/support/#{lib_name}/build.sh", exception: true)
  end
end

