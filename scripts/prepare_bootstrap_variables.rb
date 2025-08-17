#!/usr/bin/env ruby

# This script takes the Bootstrap variables file and comments out all variable declarations
# while preserving section comments and structure

input_file = ARGV[0] || File.join(__dir__, '..', 'bootstrap', 'scss', '_variables.scss')
output_file = ARGV[1] || File.join(__dir__, '..', 'templates', 'partials', 'bootstrap_variables_commented.scss')

unless File.exist?(input_file)
  puts "Error: Input file not found at #{input_file}"
  exit 1
end

content = File.read(input_file)

output_lines = []
output_lines << "// Bootstrap Overrides"
output_lines << "// Uncomment and modify any variables below to customize Bootstrap's appearance"
output_lines << "// Original source: https://github.com/twbs/bootstrap/blob/main/scss/_variables.scss"
output_lines << ""
output_lines << "// This file is imported BEFORE Bootstrap in application.bootstrap.scss:"
output_lines << "// @import 'bootstrap-overrides';"
output_lines << "// @import 'bootstrap/scss/bootstrap';"
output_lines << ""
output_lines << "// ============================================"
output_lines << ""

content.each_line do |line|
  # Keep empty lines
  if line.strip.empty?
    output_lines << ""
  # Keep existing comments as-is
  elsif line.strip.start_with?('//')
    output_lines << line.rstrip
  # Comment out variable declarations
  elsif line.include?('$') && line.include?(':')
    # Remove !default and comment out the line
    clean_line = line.rstrip.gsub(' !default', '')
    output_lines << "// #{clean_line}"
  # Keep other lines (like scss-docs markers) as comments
  else
    output_lines << "// #{line.rstrip}" unless line.strip.empty?
  end
end

require 'fileutils'
FileUtils.mkdir_p(File.dirname(output_file))
File.write(output_file, output_lines.join("\n") + "\n")

puts "Commented Bootstrap variables file created at: #{output_file}"
puts "Total lines: #{output_lines.length}"