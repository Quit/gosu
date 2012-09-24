#!/usr/bin/env ruby

WINDOWS_HINTS = %w(-win32 win32- mswin mingw32)

if defined? RUBY_PLATFORM and WINDOWS_HINTS.any? { |hint| RUBY_PLATFORM.include? hint } then
  puts 'This gem is not meant to be installed on Windows. Instead, please use:'
  puts 'gem install gosu --platform=i386-mingw32'
  exit 1
end

puts 'The Gosu gem requires some libraries to be installed system-wide.'
puts 'See the following site for a list:'
puts 'https://github.com/jlnr/gosu/wiki/Getting-Started-on-Linux'
puts

BASE_FILES = %w(
  DirectoriesUnix.cpp
  FileUnix.cpp
  Graphics/Bitmap.cpp
  Graphics/BitmapColorKey.cpp
  Graphics/BitmapUtils.cpp
  Graphics/BlockAllocator.cpp
  Graphics/Color.cpp
  Graphics/Font.cpp
  Graphics/Graphics.cpp
  Graphics/Image.cpp
  Graphics/LargeImageData.cpp
  Graphics/TexChunk.cpp
  Graphics/Text.cpp
  Graphics/Texture.cpp
  Graphics/Transform.cpp
  Inspection.cpp
  IO.cpp
  Math.cpp
  RubyGosu_wrap.cxx
  Utility.cpp
)

MAC_FILES = %w(
  Audio/AudioOpenAL.mm
  Graphics/BitmapApple.mm
  Graphics/TextMac.cpp
  Graphics/TextTouch.mm
  InputMac.mm
  TextInputMac.mm
  TimingApple.cpp
  UtilityApple.mm
  WindowMac.mm
)

LINUX_FILES = %w(
  Audio/AudioOpenAL.cpp
  Graphics/BitmapFreeImage.cpp
  Graphics/TextUnix.cpp
  InputX.cpp
  TextInputX.cpp
  TimingUnix.cpp
  WindowX.cpp
)

OGG_VORBIS_FILES = Dir['../dependencies/libogg/src/*.c'] +
                   Dir['../dependencies/libvorbis/lib/vorbisfile.c'] +
                   %w(analysis bitrate block codebook envelope floor0 floor1
                      info lookup lpc lsp mapping0 mdct psy registry res0
                      sharedbook smallft synthesis window).map do |basename|
                     "../dependencies/libvorbis/lib/#{basename}.c"
                   end

require 'mkmf'
require 'fileutils'

$INCFLAGS << " -I../ -I../GosuImpl"

if `uname`.chomp == 'Darwin' then
  SOURCE_FILES = BASE_FILES + MAC_FILES + OGG_VORBIS_FILES
  
  # Apple curiously distributes libpng only inside X11
  $INCFLAGS  << " -I/usr/X11/include"
  # Use included libogg, libvorbis to make Gosu easier to install on OS X
  $INCFLAGS  << " -I../dependencies/libogg/include"
  $INCFLAGS  << " -I../dependencies/libvorbis/include"
  $INCFLAGS  << " -I../dependencies/libvorbis/lib"
  # To make everything work with the Objective C runtime
  $CFLAGS    << " -x objective-c -fobjc-gc -DNDEBUG"
  CONFIG['CXXFLAGS'] =  "#{CONFIG['CXXFLAGS']} -x objective-c++" # cheat a little here
  $LDFLAGS   << " -L/usr/X11/lib -liconv"
  %w(AudioToolbox IOKit OpenAL OpenGL AppKit ApplicationServices Foundation Carbon).each do |f|
    $LDFLAGS << " -framework #{f}"
  end
  
  # Symlink our pretty gosu.so into ../lib
  # FIXME gosu.rb should just look in the right place.
  FileUtils.ln_s("../linux/gosu.bundle", "../lib/gosu.bundle")
else
  SOURCE_FILES = BASE_FILES + LINUX_FILES

  # Symlink our pretty gosu.so into ../lib
  # FIXME gosu.rb should just look in the right place.
  FileUtils.ln_s("../linux/gosu.so", "../lib/gosu.so")

  pkg_config("sdl")
  pkg_config("pangoft2")
  pkg_config("x11")
  
  pkg_config("gl")
  pkg_config("vorbisfile")
  pkg_config("openal")
  pkg_config("sndfile")
  
  have_header('SDL_ttf.h')   if have_library('SDL_ttf', 'TTF_RenderUTF8_Blended')
  have_header('FreeImage.h') if have_library('freeimage', 'FreeImage_ConvertFromRawBits')
  have_header('AL/al.h')     if have_library('openal')
end

# Copy all relevant C++ files into the current directory
# FIXME Could be done by gem task instead.
SOURCE_FILES.each do |file|
  FileUtils.cp("../GosuImpl/#{file}", File.basename(file).sub(/\.mm$/, '.cpp'))
end

create_makefile("gosu")
