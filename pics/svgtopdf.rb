require 'find'

update =  ARGV[0] == "update"

Find.find("./") do |path|
	if File.extname(path) == ".svg"
		dest = File.dirname(path) + "/" + File.basename(path,".svg") + ".pdf"
		
		next if File.exists?(dest) and not update

		command = "inkscape -z --file=#{path} --export-pdf=#{dest}"
		puts command
		system command
	end
end
