require 'find'

update =  ARGV[0] == "update"

Find.find("./") do |path|
	if File.extname(path) == ".pdf"
		dest = File.dirname(path) + "/" + File.basename(path,".pdf") + ".eps"
		
		next if File.exists?(dest) and not update

		command = "pdftops -eps #{path}"
		puts command
		system command
	end
end
