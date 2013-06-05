require 'fileutils'

BINDIR="../bin/"
LOCALEDIR="../src/globalization/"
SRCDIR="../src/"

def create_bindir(name)
  FileUtils.mkdir_p(name) unless File.exist? name
end

def compile(locale, srcdir, to)
  puts "Compiling #{locale}"
  # Compile locale, cofe, sugarpak, parser, extras and time in that order
  puts `coffee -j #{to}date-#{locale}_cof.js -c #{LOCALEDIR}#{locale}.coffee #{srcdir}core.coffee #{srcdir}sugarpak.coffee #{srcdir}parser.coffee #{srcdir}extras.coffee #{srcdir}time.coffee`
end

create_bindir(BINDIR)

if ARGV.empty?
  puts "Building the default locale en-US"
  compile("en-US", SRCDIR, BINDIR)
elsif ARGV.include? "all"
  Dir.foreach(LOCALEDIR) do |f|
    compile(f.split(".").first, SRCDIR, BINDIR)
  end
else
  ARGV.each { |locale| compile(locale, SRCDIR, BINDIR) }
end

