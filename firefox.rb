require 'pathname'
require 'nokogiri'

provides 'apps/browsers/firefox'

require_plugin "apps/browsers"

# TODO: How to bail out if the following fails?
firefox = Mash.new unless apps[:browsers][:firefox]

# Version number
cmd = "firefox -v"
status, stdout, stderr = run_command(:no_status_check => true, :command => cmd)
if status == 0
  firefox[:version] = stdout
end

extdir = "/usr/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"

firefox[:extdir] = extdir
firefox[:extensions] = Array.new

# Logic: enter every directory under the extensions directory.
# If the directory contains an install.rdf file, we assume that
# we have found an extension. We read the file using some simple
# XML parsing, and return a stack of values.

dirs = Pathname.new(extdir).children.select { |c| c.directory? }.collect { |p| p.to_s }

for d in dirs
  rdf = "#{d}/install.rdf"
  if File.exists?(rdf) then
    f = File.open (rdf)
    doc = Nokogiri::XML(f)
    id = doc.xpath('//xmlns:RDF/xmlns:Description/em:id').children[0].to_s
    name = doc.xpath('//xmlns:RDF/xmlns:Description/em:name').children[0].to_s
    version = doc.xpath('//xmlns:RDF/xmlns:Description/em:version').children[0].to_s
    description = doc.xpath('//xmlns:RDF/xmlns:Description/em:description').children[0].to_s
    firefox[:extensions] << { "id" => id, "name" => name, "version" => version, "description" => description }
  end 
end

apps[:browsers][:firefox] = firefox
