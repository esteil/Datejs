require 'fileutils'

BINDIR="../bin/"
LOCALEDIR="../src/globalization/"
COMPILER="compiler/compiler.jar"
SRCDIR="../src/"

def create_bindir(name)
  FileUtils.mkdir_p(name) unless File.exist? name
end

def compile(locale, compiler, srcdir, to)
  file = "#{locale}.js"
  puts "Compiling #{locale}"
  puts `java -jar #{compiler} --js=#{LOCALEDIR}#{file} --js=#{srcdir}core.js \
  --js=#{srcdir}sugarpak.js --js=#{srcdir}parser.js \
  --js=#{srcdir}extras.js --js=#{srcdir}time.js \
  --js_output_file=#{to}date-#{locale}.js`
end

create_bindir(BINDIR)

if ARGV.empty?
  puts "Building the default locale en-US"
  compile("en-US", COMPILER, SRCDIR, BINDIR)
elsif ARGV.include? "all"
  Dir.foreach(LOCALEDIR) do |f|
    compile(f.split(".").first, COMPILER, SRCDIR, BINDIR)
  end
else
  ARGV.each { |locale| compile(locale, COMPILER, SRCDIR, BINDIR) }
end
  
