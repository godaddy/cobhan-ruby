# frozen_string_literal: true

require 'tempfile'

class CobhanApp
  extend Cobhan

  def self.add_int32(first, second)
    addInt32(first, second)
  end
end

RSpec.describe Cobhan do
  let(:input) { 'test' }

  describe 'version' do
    it 'has a version number' do
      expect(Cobhan::VERSION).not_to be nil
    end
  end

  describe 'library_file_name' do
    it 'returns file name for supported OS / ARCH combinations' do
      {
        ['linux', 'x86_64'] => 'lib-x64.so',
        ['linux', 'aarch64'] => 'lib-arm64.so',
        ['darwin', 'x86_64'] => 'lib-x64.dylib',
        ['darwin', 'aarch64'] => 'lib-arm64.dylib',
        ['windows', 'x86_64'] => 'lib-x64.dll',
        ['windows', 'aarch64'] => 'lib-arm64.dll'
      }.each_pair do |(os, arch), file|
        stub_const('FFI::Platform::OS', os)
        stub_const('FFI::Platform::ARCH', arch)

        expect(CobhanApp.library_file_name('lib')).to eq(file)
      end
    end

    it 'raises unsupported OS error' do
      stub_const('FFI::Platform::OS', 'other')

      expect {
        CobhanApp.library_file_name('lib')
      }.to raise_error(Cobhan::UnsupportedPlatformError) do |e|
        expect(e.message).to eq('Unsupported OS: other')
      end
    end

    it 'raises unsupported CPU error' do
      stub_const('FFI::Platform::ARCH', 'other')

      expect {
        CobhanApp.library_file_name('lib')
      }.to raise_error(Cobhan::UnsupportedPlatformError) do |e|
        expect(e.message).to eq('Unsupported CPU: other')
      end
    end
  end

  describe 'load_library' do
    it 'loads library and defines FFI functions' do
      expect {
        CobhanApp.add_int32(1, 2)
      }.to raise_error(NoMethodError) do |e|
        expect(e.message).to include("undefined method `addInt32'")
      end

      CobhanApp.load_library(
        LIB_ROOT_PATH, LIB_NAME,
        [[:addInt32, [:int32, :int32], :int32]]
      )

      expect(CobhanApp.add_int32(1, 1)).to eq(2)
    end
  end

  describe 'string_to_cbuffer' do
    it 'return a memory pointer to C buffer' do
      memory_pointer = CobhanApp.string_to_cbuffer(input)
      expect(memory_pointer.get_int32(0)).to eq(input.bytesize)
      expect(memory_pointer.get_int32(Cobhan::SIZEOF_INT32)).to eq(0)
      expect(memory_pointer.get_bytes(Cobhan::BUFFER_HEADER_SIZE, input.bytesize)).to eq(input)
    end
  end

  describe 'cbuffer_to_string' do
    it 'returns a string from C buffer' do
      memory_pointer = CobhanApp.string_to_cbuffer(input)
      output = CobhanApp.cbuffer_to_string(memory_pointer)
      expect(output).to eq(input)
      expect(output.encoding).to eq(Encoding::UTF_8)
    end

    it 'returns a string from C buffer pointing to a temp file' do
      CobhanApp.load_library(
        LIB_ROOT_PATH, LIB_NAME,
        [[:toUpper, [:pointer, :pointer], :int32]]
      )

      in_buffer = CobhanApp.string_to_cbuffer('a' * 2048)
      # Output buffer size must be big enough for storing the temp file name at least
      estimated_max_size_of_tmp_fize_name = 128
      out_buffer = CobhanApp.allocate_cbuffer(estimated_max_size_of_tmp_fize_name)

      result = CobhanApp.toUpper(in_buffer, out_buffer)
      expect(result).to eq(0)

      expect(CobhanApp).to receive(:temp_to_string).and_call_original
      output = CobhanApp.cbuffer_to_string(out_buffer)
      expect(output).to eq('A' * 2048)
      expect(output.encoding).to eq(Encoding::UTF_8)
    end
  end

  describe 'temp_to_string' do
    it 'returns a string from temp file pointed by C buffer and deletes the temp file' do
      file = Tempfile.new('test')
      file.print('content')
      file.close

      expect(File.exist?(file.path)).to eq(true)

      length = -file.path.bytesize
      buffer_ptr = FFI::MemoryPointer.new(1, Cobhan::BUFFER_HEADER_SIZE + file.path.bytesize, false)
      buffer_ptr.put_int32(0, length)
      buffer_ptr.put_int32(Cobhan::SIZEOF_INT32, 0)
      buffer_ptr.put_bytes(Cobhan::BUFFER_HEADER_SIZE, file.path)

      expect(CobhanApp.temp_to_string(buffer_ptr, length)).to eq('content')
      expect(File.exist?(file.path)).to eq(false)
    end
  end

  describe 'allocate_cbuffer' do
    it 'returns a memory pointer to C buffer with requested size' do
      memory_pointer = CobhanApp.allocate_cbuffer(10)
      expect(memory_pointer.get_int32(0)).to eq(10)
      expect(memory_pointer.get_int32(Cobhan::SIZEOF_INT32)).to eq(0)
      expect(memory_pointer.size).to eq(10 + Cobhan::BUFFER_HEADER_SIZE)
    end
  end

  describe 'int_to_buffer' do
    it 'creates a buffer for interger value' do
      number = (2**63) - 1
      memory_pointer = CobhanApp.int_to_buffer(number)
      expect(memory_pointer.get_int64(0)).to eq(number)
      expect(memory_pointer.size).to eq(Cobhan::SIZEOF_INT32 * 2)
    end
  end

  describe 'buffer_to_int' do
    it 'converts a buffer to integer value' do
      number = (2**63) - 1
      memory_pointer = CobhanApp.int_to_buffer(number)
      expect(CobhanApp.buffer_to_int(memory_pointer)).to eq(number)
    end
  end
end
