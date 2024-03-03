# frozen_string_literal: true
require 'YAML'
require 'thor'
require 'date'
require 'command_line/global'
require 'fileutils'
require_relative "check_new_bins/version"

module CheckNewBins
  class Error < StandardError; end
  # Your code goes here...
#  option = ARGV[0]

  class CLI < Thor
    p $conf_file = "#{File.join(ENV['HOME'], '.chen_new_bins_conf.yml')}"

    package_name "check_new_bins"
    map "-v" => :version
    map "--version" => :version

    desc "version", "show version"

    def version
      print "put_rake #{VERSION}"
    end

    desc "init", "init or show configuration"
    def init
      if File.exist?($conf_file)
        system "cat #{$conf_file}"
      else
        system "emacs -nw #{$conf_file}"
      end
    end

    desc "list", "list bin dirs"
    def list(*args)
      p target_file = args[0] || ''
      target_files = []
      p dirs = YAML.load(File.read($conf_file))
      data = {}
      p date = Date.today
      data[:date] = date
      dirs.each do |dir|
        bin_dirs = "#{dir}/**/bin"
        Dir.glob(File.join(ENV['HOME'], bin_dirs)).each do |bin_dir|
          p bin_dir
          res = command_line "ls -lat #{bin_dir}"
          res.stdout.split("\n").each do |line|
            if line.include?(target_file)
              puts line
              file = line.split(' ')[-1]
              target_files << File.join(bin_dir, file)
            end
          end
        end
      end
      target_files.each_with_index do |file, i |
        p [i, file]
      end

      copy_files = args[1] || nil
      unless copy_files==nil
        from, to = copy_files.split(' ')
        from = target_files[from.to_i]
        to = target_files[to.to_i]
        #        FileUtils::DryRun.cp(from, to, verbose: true)
        FileUtils.cp(from, to, verbose: true)
      end
    end
  end
end
