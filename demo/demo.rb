# frozen_string_literal: true

require 'cobhan'
require_relative '../spec/support/build_binary'
require_relative '../spec/support/measure_time'
require_relative '../spec/support/cobhan_module'

LIB_ROOT_PATH =  File.join(__dir__, '../tmp')
LIB_NAME = 'libcobhandemo'

build_binary(LIB_ROOT_PATH, LIB_NAME)

# CobhanDemo class
class CobhanDemo
  include CobhanModule

  FFI.init(LIB_ROOT_PATH, LIB_NAME)
end

demo = CobhanDemo.new
puts demo.add_int32(2.9, 2.0)
puts demo.add_int64(2.9, 2.0)
puts demo.add_double(2.9, 2.0)
puts demo.to_upper('foo bar baz')
puts demo.filter_json('{"foo":"bar","baz":"qux"}', 'foo')
puts demo.base64_encode('Test')
puts "Sleep: #{measure_time { demo.sleep_test(1) }}"
