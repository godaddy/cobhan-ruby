# frozen_string_literal: true

require_relative 'cobhan/version'

require 'ffi'

# Cobhan module includes helper functions to manage unsafe data marshaling.
module Cobhan
  UnsupportedPlatformError = Class.new(StandardError)

  include FFI::Library

  EXTS = { 'linux' => 'so', 'darwin' => 'dylib', 'windows' => 'dll' }.freeze
  CPU_ARCHS = { 'x86_64' => 'x64', 'aarch64' => 'arm64' }.freeze

  SIZEOF_INT32 = 32 / 8
  BUFFER_HEADER_SIZE = SIZEOF_INT32 * 2

  def library_file_name(name)
    ext = EXTS[FFI::Platform::OS]
    raise UnsupportedPlatformError, "Unsupported OS: #{FFI::Platform::OS}" unless ext

    cpu_arch = CPU_ARCHS[FFI::Platform::ARCH]
    raise UnsupportedPlatformError, "Unsupported CPU: #{FFI::Platform::ARCH}" unless cpu_arch

    libc_suffix = RbConfig::CONFIG['host_os'] == 'linux-musl' ? '-musl' : ''

    "#{name}-#{cpu_arch}#{libc_suffix}.#{ext}"
  end

  def load_library(lib_root_path, name, functions)
    # To load other libs that depend on relative paths, chdir to lib path dir.
    Dir.chdir(lib_root_path) do
      ffi_lib File.join(lib_root_path, library_file_name(name))
    end

    functions.each do |function|
      attach_function(*function)
    end
  end

  def string_to_cbuffer(input)
    buffer_ptr = FFI::MemoryPointer.new(1, BUFFER_HEADER_SIZE + input.bytesize, false)
    buffer_ptr.put_int32(0, input.bytesize)
    buffer_ptr.put_int32(SIZEOF_INT32, 0) # Reserved - must be zero
    buffer_ptr.put_bytes(BUFFER_HEADER_SIZE, input)
    buffer_ptr
  end

  def cbuffer_to_string(buffer)
    length = buffer.get_int32(0)
    if length >= 0
      buffer.get_bytes(BUFFER_HEADER_SIZE, length)
    else
      temp_to_string(buffer, length)
    end.force_encoding(Encoding::UTF_8)
  end

  def temp_to_string(buffer, length)
    length = 0 - length
    filename = buffer.get_bytes(BUFFER_HEADER_SIZE, length)
    # Read file with name in payload, and replace payload
    bytes = File.binread(filename)
    File.delete(filename)
    bytes
  end

  def allocate_cbuffer(size)
    buffer_ptr = FFI::MemoryPointer.new(1, BUFFER_HEADER_SIZE + size, false)
    buffer_ptr.put_int32(0, size)
    buffer_ptr.put_int32(SIZEOF_INT32, 0) # Reserved - must be zero
    buffer_ptr
  end

  def int_to_buffer(number)
    buffer_ptr = FFI::MemoryPointer.new(1, SIZEOF_INT32 * 2, false)
    buffer_ptr.put_int64(0, number)
    buffer_ptr
  end

  def buffer_to_int(buffer_ptr)
    buffer_ptr.get_int64(0)
  end
end
