require 'fileutils'

class Simulation
	def create name, description, input
		@name = name
		@description = description
				
		Dir.mkdir("output") unless Dir.exist?("output")
		Dir.chdir("output")
		Dir.mkdir(@name) unless Dir.exist?(@name)
		Dir.chdir(@name)
		
		file = File.open "description", "w"
		file.write @description
		file.close
		
		FileUtils.cp("../../input/" + input, "input.dat")
		
		Dir.chdir("..")
		Dir.chdir("..")
	end
	
	def load name
		@name = name
		path = "output/" + @name + "/description"
		
		unless File.exist? path
			puts "Simulation does not exist!"
			exit
		end
		
		file = File.open path
		@desc = file.read
		file.close
		puts @name + ": " + @desc
	end
	
	def run name
		load name
		setRestart 0
		
		path = "output/" + @name + "/"
		
		input = path + "input.dat"
		
		output_file = @name
				
		puts "mpirun -np3 baci-release " + input + " " + path + output_file + " | tee " + path + @name + Time.now.strftime("-%m-%d-%H_%M") + ".log"
	end
	
	def restart name,timestep,which
		load name
		setRestart timestep
		
		path = "output/" + @name + "/"
		
		input = path + "input.dat"
		
		output_file = @name
		output_file = output_file + "_" + which unless which == nil
		
		puts "mpirun -np3 baci-release " + input + " " + path + output_file + " | tee " + path + @name + Time.now.strftime("-%m-%d-%H_%M") + ".log"
	end

	def setRestart timestep
		path = "output/" + @name + "/input.dat"
		
		restart_line = -1
		
		file = File.open(path, "r")
			until file.eof?
				line = file.gets.downcase
								
				if(line.include? "restart")
					restart_line = $.
					break
				end
			end
		file.close
		
		FileUtils.mv(path, path + ".tmp")
		
		old = File.open(path + ".tmp")
		new = File.open(path, "w")
		
		while old.gets do
			if $. == restart_line then
				new.puts "RESTART " + timestep.to_s
			else
				new.print $_
			end
		end
		
	end
	
end

class ConsoleHandler
	def processArguments
		case ARGV[0]
		when "create"
			ARGV.clear
			puts "Enter name"
			name = gets.chomp
			puts "Enter description"
			desc = gets.chomp
			puts "Enter input file name (in input dir)"
			input = gets.chomp
			
			Simulation.new.create name, desc, input
		
		when "load"
			ARGV.clear
			puts "Enter name"
			name = gets.chomp
			
			Simulation.new.load name
			
		when "run"
			Simulation.new.run ARGV[1].chomp
		
		when "restart"
			Simulation.new.restart ARGV[1],ARGV[2],ARGV[3]
		
		when ""
			puts "no command provided"
		else
			puts "command unknown"
		end
	end
end

if __FILE__ == $0
	ConsoleHandler.new.processArguments
end